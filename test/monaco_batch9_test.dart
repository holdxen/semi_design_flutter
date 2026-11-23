// 1:1 port regression tests for batch 9:
//   base/common/dataTransfer.ts
//   base/parts/storage/common/storage.ts
//   editor/common/model/tokens/annotations.ts
// Assertions mirror the semantics of the TypeScript originals.

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/dataTransfer.dart' as dt;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/base/parts/storage/common/storage.dart' as st;
import 'package:semi_design_flutter/src/monaco/editor/common/core/edits/stringEdit.dart' as se;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart' show OffsetRange;
import 'package:semi_design_flutter/src/monaco/editor/common/model/tokens/annotations.dart' as an;

void main() {
  group('dataTransfer', () {
    test('createStringDataTransferItem string & promise', () async {
      final dt.IDataTransferItem a =
          dt.createStringDataTransferItem('hello', 'id-1');
      expect(a.id, 'id-1');
      expect(a.value, 'hello');
      expect(await a.asString(), 'hello');
      expect(a.asFile(), isNull);

      final dt.IDataTransferItem b =
          dt.createStringDataTransferItem(Future<String>.value('world'));
      expect(b.id, isNull);
      expect(b.value, isNull);
      expect(await b.asString(), 'world');
    });

    test('createFileDataTransferItem', () async {
      final dt.IDataTransferItem item = dt.createFileDataTransferItem(
          'a.txt', URI.file('/a.txt'), () async => <int>[1, 2, 3], 'fid');
      expect(item.id, 'fid');
      expect(item.value, isNull);
      expect(await item.asString(), '');
      final dt.IDataTransferFile? file = item.asFile();
      expect(file, isNotNull);
      expect(file!.name, 'a.txt');
      expect(file.uri, isNotNull);
      expect(await file.data(), <int>[1, 2, 3]);
      expect(file.id, isNotEmpty);
    });

    test('matchesMimeType exact/wildcard/any', () {
      expect(dt.matchesMimeType('text/plain', <String>['text/plain']), isTrue);
      expect(dt.matchesMimeType('TEXT/PLAIN', <String>['text/plain']), isTrue);
      expect(dt.matchesMimeType('image/*', <String>['image/png']), isTrue);
      expect(dt.matchesMimeType('image/*', <String>['text/plain']), isFalse);
      expect(dt.matchesMimeType('*/*', <String>['a/b']), isTrue);
      expect(dt.matchesMimeType('*/*', <String>[]), isFalse);
      expect(dt.matchesMimeType('bad', <String>['a/b']), isFalse);
    });

    test('VSDataTransfer append/replace/delete/get/size', () {
      final dt.VSDataTransfer transfer = dt.VSDataTransfer();
      expect(transfer.size, 0);
      expect(transfer.has('text/plain'), isFalse);

      // source `append` looks up existing with the RAW mimeType (not toKey),
      // so differently-cased keys do not merge; the later normalized write wins.
      transfer.append('text/plain', dt.createStringDataTransferItem('a'));
      transfer.append('TEXT/PLAIN', dt.createStringDataTransferItem('b'));
      expect(transfer.size, 1);
      expect(transfer.has('text/plain'), isTrue);
      expect(transfer.get('text/plain')!.value, 'b');
      expect(transfer.entries().length, 1);

      // Same-case append does merge via the raw-key lookup.
      transfer.append('text/plain', dt.createStringDataTransferItem('c'));
      expect(transfer.entries().length, 2);

      transfer.replace('text/plain', dt.createStringDataTransferItem('d'));
      expect(transfer.get('text/plain')!.value, 'd');
      expect(transfer.entries().length, 1);

      transfer.delete('text/plain');
      expect(transfer.size, 0);
      expect(transfer.get('text/plain'), isNull);
    });

    test('VSDataTransfer matches with files', () {
      final dt.VSDataTransfer transfer = dt.VSDataTransfer();
      transfer.append('image/png', dt.createFileDataTransferItem(
          'a.png', null, () async => <int>[]));
      expect(transfer.matches('files'), isTrue);
      expect(transfer.matches('image/*'), isTrue);
    });

    test('UriList create/split/parse', () {
      expect(dt.UriList.create(<Object>['a', 'b', 'a']), 'a\r\nb');
      expect(dt.UriList.split('a\r\nb'), <String>['a', 'b']);
      expect(dt.UriList.parse('#comment\r\na\r\n#x\r\nb'),
          <String>['a', 'b']);
    });
  });

  group('storage', () {
    test('isStorageItemsChangeEvent', () {
      expect(st.isStorageItemsChangeEvent(
          st.StorageItemsChangeEvent(changed: <String, String>{})), isTrue);
      expect(st.isStorageItemsChangeEvent(
          st.StorageItemsChangeEvent(deleted: <String>{})), isTrue);
      expect(st.isStorageItemsChangeEvent(Object()), isFalse);
      expect(st.isStorageItemsChangeEvent(null), isFalse);
    });

    test('basics: fallback get/getBoolean/getNumber/getObject', () async {
      final st.Storage storage = st.Storage(st.InMemoryStorageDatabase());
      await storage.init();
      expect(storage.get('foo', 'bar'), 'bar');
      expect(storage.getNumber('foo', 55), 55);
      expect(storage.getBoolean('foo', true), isTrue);
      expect(storage.getObject('foo', <String, String>{'bar': 'baz'}),
          <String, String>{'bar': 'baz'});

      await storage.set('s', 'foo');
      await storage.set('n', 55);
      await storage.set('b', true);
      await storage.set('o', <String, Object>{'bar': 'baz'});
      expect(storage.get('s'), 'foo');
      expect(storage.getNumber('n'), 55);
      expect(storage.getBoolean('b'), isTrue);
      expect(storage.getObject('o'), isA<Map>());
      await storage.close();
    });

    test('set same value emits no event; delete removes', () async {
      final st.Storage storage = st.Storage(st.InMemoryStorageDatabase());
      await storage.init();
      final Set<String> changes = <String>{};
      storage.onDidChangeStorage((dynamic l) =>
          changes.add((l as st.StorageChangeEvent).key));

      await storage.set('k', 'v');
      expect(changes, <String>{'k'});
      changes.clear();
      await storage.set('k', 'v');
      expect(changes.isEmpty, isTrue);

      await storage.delete('k');
      expect(storage.get('k'), isNull);
      expect(changes, <String>{'k'});
      changes.clear();
      await storage.delete('k');
      expect(changes.isEmpty, isTrue);
      await storage.close();
    });

    test('set undefined/null deletes', () async {
      final st.Storage storage = st.Storage(st.InMemoryStorageDatabase());
      await storage.init();
      await storage.set('k', 'v');
      expect(storage.get('k'), 'v');
      await storage.set('k', null);
      expect(storage.get('k'), isNull);
      await storage.close();
    });

    test('whenFlushed returns immediately when no pending', () async {
      final st.Storage storage = st.Storage(st.InMemoryStorageDatabase());
      await storage.init();
      await storage.whenFlushed();
      expect(true, isTrue);
      await storage.close();
    });

    test('external changes update cache and emit external=true', () async {
      final event.Emitter<st.StorageItemsChangeEvent> emitter =
          event.Emitter<st.StorageItemsChangeEvent>();
      final _TestDb db = _TestDb(emitter.event);
      final st.Storage storage = st.Storage(db);
      final List<st.StorageChangeEvent> events = <st.StorageChangeEvent>[];
      storage.onDidChangeStorage((dynamic l) =>
          events.add(l as st.StorageChangeEvent));
      await storage.init();

      await storage.set('foo', 'bar');
      events.clear();
      // same value -> no event
      emitter.fire(st.StorageItemsChangeEvent(
          changed: <String, String>{'foo': 'bar'}));
      expect(events.isEmpty, isTrue);

      emitter.fire(st.StorageItemsChangeEvent(
          changed: <String, String>{'foo': 'bar1'}));
      expect(events.length, 1);
      expect(events.first.key, 'foo');
      expect(events.first.external, isTrue);
      expect(storage.get('foo'), 'bar1');

      events.clear();
      emitter.fire(st.StorageItemsChangeEvent(deleted: <String>{'foo'}));
      expect(events.length, 1);
      expect(storage.get('foo'), isNull);
      await storage.close();
    });

    test('in-memory hint skips database items', () async {
      final st.Storage storage = st.Storage(
          st.InMemoryStorageDatabase(),
          st.StorageOptions(hint: st.StorageHint.storageInMemory));
      expect(storage.isInMemory(), isTrue);
      await storage.init();
      await storage.set('k', 'v');
      expect(storage.get('k'), 'v');
      await storage.close();
    });

    test('close is idempotent and blocks further writes', () async {
      final st.Storage storage = st.Storage(st.InMemoryStorageDatabase());
      await storage.init();
      await storage.close();
      await storage.close();
      await storage.set('k', 'v');
      expect(storage.get('k'), isNull);
    });

    test('MigratingStorage migrates from fallback on get', () async {
      final st.Storage fallback = st.Storage(st.InMemoryStorageDatabase());
      await fallback.init();
      await fallback.set('old', 'from-fallback');

      final st.MigratingStorage migrating =
          st.MigratingStorage(st.InMemoryStorageDatabase());
      await migrating.init();
      migrating.setFallbackStorage(fallback, false);

      expect(migrating.get('old'), 'from-fallback');
      // second get reads from migrated cache, fallback no longer has it
      expect(migrating.get('old'), 'from-fallback');
      expect(fallback.get('old'), isNull);
      // the marker key is persisted into the migrated storage itself and,
      // being an internal key, is not subject to fallback migration.
      expect(migrating.get(st.migratedKey), '["old"]');
      await migrating.close();
      await fallback.close();
    });
  });

  group('annotations', () {
    se.StringEdit _replace(int start, int endEx, String text) =>
        se.StringEdit(<se.StringReplacement>[
          se.StringReplacement(OffsetRange(start, endEx), text)
        ]);

    an.AnnotationsUpdate<String> _set(int start, int endEx, String ann) =>
        an.AnnotationsUpdate<String>(<an.IAnnotationUpdate<String>>[
          an.IAnnotationUpdate<String>(OffsetRange(start, endEx), ann)
        ]);

    List<String> _anns(an.AnnotatedString<String> s) => s
        .getAllAnnotations()
        .map((an.IAnnotation<String> a) =>
            '${a.range.start}-${a.range.endExclusive}:${a.annotation}')
        .toList();

    test('setAnnotations insert and delete', () {
      final an.AnnotatedString<String> s = an.AnnotatedString<String>(
          <an.IAnnotation<String>>[
            an.IAnnotation<String>(OffsetRange(0, 5), '1'),
            an.IAnnotation<String>(OffsetRange(6, 11), '2'),
          ]);
      s.setAnnotations(_set(0, 3, '4'));
      expect(_anns(s), <String>['0-3:4', '6-11:2']);
      // delete annotation part
      s.setAnnotations(an.AnnotationsUpdate<String>(
          <an.IAnnotationUpdate<String>>[
            an.IAnnotationUpdate<String>(OffsetRange(0, 3), null)
          ]));
      expect(_anns(s), <String>['6-11:2']);
    });

    test('getAnnotationsIntersecting', () {
      final an.AnnotatedString<String> s = an.AnnotatedString<String>(
          <an.IAnnotation<String>>[
            an.IAnnotation<String>(OffsetRange(0, 5), '1'),
            an.IAnnotation<String>(OffsetRange(6, 11), '2'),
            an.IAnnotation<String>(OffsetRange(12, 17), '3'),
          ]);
      final List<an.IAnnotation<String>> hit =
          s.getAnnotationsIntersecting(OffsetRange(4, 7));
      expect(hit.length, 2);
      expect(hit[0].annotation, '1');
      expect(hit[1].annotation, '2');
    });

    test('applyEdit shifts and shrinks annotations', () {
      final an.AnnotatedString<String> s = an.AnnotatedString<String>(
          <an.IAnnotation<String>>[
            an.IAnnotation<String>(OffsetRange(0, 5), '1'),
            an.IAnnotation<String>(OffsetRange(6, 11), '2'),
          ]);
      // insert 3 chars at offset 5 -> annotation 1 stays, annotation 2 shifts
      s.applyEdit(_replace(5, 5, 'XYZ'));
      expect(_anns(s), <String>['0-5:1', '9-14:2']);
    });

    test('applyEdit deletes fully-covered annotation', () {
      final an.AnnotatedString<String> s = an.AnnotatedString<String>(
          <an.IAnnotation<String>>[
            an.IAnnotation<String>(OffsetRange(0, 3), '1'),
          ]);
      final List<an.IAnnotation<String>> deleted =
          s.applyEdit(_replace(0, 3, ''));
      expect(s.getAllAnnotations().isEmpty, isTrue);
      expect(deleted.length, 1);
    });

    test('clone is shallow copy', () {
      final an.AnnotatedString<String> s = an.AnnotatedString<String>(
          <an.IAnnotation<String>>[
            an.IAnnotation<String>(OffsetRange(0, 3), '1'),
          ]);
      final an.IAnnotatedString<String> c = s.clone();
      expect(_anns(c as an.AnnotatedString<String>), <String>['0-3:1']);
      c.setAnnotations(an.AnnotationsUpdate<String>(
          <an.IAnnotationUpdate<String>>[
            an.IAnnotationUpdate<String>(OffsetRange(0, 3), null)
          ]));
      expect(s.getAllAnnotations().length, 1);
    });

    test('AnnotationsUpdate rebase/serialize/deserialize', () {
      an.AnnotationsUpdate<String> u = an.AnnotationsUpdate.create<String>(
          <an.IAnnotationUpdate<String>>[
            an.IAnnotationUpdate<String>(OffsetRange(0, 3), 'A'),
            an.IAnnotationUpdate<String>(OffsetRange(5, 7), 'B'),
          ]);
      u.rebase(_replace(0, 0, 'XX'));
      expect(u.annotations[0].range.start, 2);
      expect(u.annotations[1].range.start, 7);

      final List<an.ISerializedAnnotation<String>> serialized =
          u.serialize<String>((String a) => a);
      expect(serialized.length, 2);
      expect(serialized[0].annotation, 'A');
      final an.AnnotationsUpdate<String> restored =
          an.AnnotationsUpdate.deserialize<String, String>(
              serialized, (String a) => a);
      expect(restored.annotations.length, 2);
      expect(restored.annotations[0].annotation, 'A');
    });
  });
}

class _TestDb implements st.IStorageDatabase {
  final event.Event<st.StorageItemsChangeEvent> onDidChangeItemsExternal;
  final Map<String, String> _items = <String, String>{};

  _TestDb(this.onDidChangeItemsExternal);

  @override
  Future<Map<String, String>> getItems() async => _items;

  @override
  Future<void> updateItems(st.UpdateRequest request) async {
    request.insert?.forEach((String v, String k) => _items[k] = v);
    request.delete?.forEach((String k) => _items.remove(k));
  }

  @override
  Future<void> optimize() async {}

  @override
  Future<void> close([Map<String, String> Function()? recovery]) async {}
}
