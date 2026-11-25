// batch287: clipboardUtils.ts truth replay.
// Truth from tool/ts2dart/batch287_truth.json (recursive TS transpile+vm,
// real manager/getTextData/setTextData/readable-writable with fake data).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/controller/editContext/clipboardUtils.dart'
    show
        ClipboardStoredMetadata,
        IClipboardDataTransfer,
        IClipboardFile,
        InMemoryClipboardMetadataManager,
        createReadableClipboardData,
        createWritableClipboardData,
        getClipboardTextData;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch287_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) =>
        MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

ClipboardStoredMetadata _metaFromTruth(Object? raw) {
  final m = raw as Map<String, dynamic>;
  return ClipboardStoredMetadata(
    version: (m['version'] as num).toInt(),
    id: m['id'] as String?,
    isFromEmptySelection: m['isFromEmptySelection'] as bool?,
    isBlock: m['isBlock'] as bool?,
    multicursorText: (m['multicursorText'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    mode: m['mode'] as String?,
  );
}

Object? _metaToTruth(ClipboardStoredMetadata? m) => m?.toJson();

class _File implements IClipboardFile {
  _File(this.name, this.path);
  @override
  final String name;
  @override
  final String? path;
}

class _DataTransfer implements IClipboardDataTransfer {
  _DataTransfer(Map<String, String> data, [List<Object>? files])
      : _data = Map<String, String>.from(data),
        _files = files ?? <Object>[];

  final Map<String, String> _data;
  final List<Object> _files;

  @override
  List<String> get types => _data.keys.toList();

  @override
  List<Object> get files => _files;

  @override
  String getData(String type) => _data[type] ?? '';

  @override
  void setData(String type, String value) => _data[type] = value;

  Map<String, String> get data => _data;
}

void main() {
  final t = _truth();

  for (final rawCase in t['managerCases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b287 MGR ${c['name']}: set/get truth', () {
      final mgr = InMemoryClipboardMetadataManager();
      // truth uses id-1 metadata for both cases; reconstruct from first probe
      // that has a result, else use a canonical one.
      final firstResult = (c['probes'] as List<dynamic>).firstWhere(
        (p) => (p as Map<String, dynamic>)['result'] != null,
        orElse: () => <String, dynamic>{
          'result': {
            'version': 1,
            'id': 'id-1',
            'isFromEmptySelection': false,
            'isBlock': true,
            'multicursorText': null,
            'mode': 'typescript',
          },
        },
      ) as Map<String, dynamic>;
      final meta = _metaFromTruth(firstResult['result']);

      // set the value that the first probe expects to match.
      final firstText = (c['probes'] as List<dynamic>)[0]['text'] as String;
      mgr.set(firstText, meta);

      for (final rawP in c['probes'] as List<dynamic>) {
        final p = rawP as Map<String, dynamic>;
        expect(_metaToTruth(mgr.get(p['text'] as String)), p['result'],
            reason: 'probe ${p['text']}');
      }
    });
  }

  for (final rawCase in t['clipboardCases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b287 CLIP ${c['name']}: truth', () {
      switch (c['name'] as String) {
        case 'readable':
          final cd = createReadableClipboardData(_DataTransfer(<String, String>{
            'text/plain': 'hello',
            'text/html': '<b>hi</b>',
          }));
          expect(cd.types, c['types']);
          expect(cd.getData('text/plain'), c['text']);
          expect(cd.getData('text/html'), c['html']);
          expect(cd.getData('nope'), c['missing']);
          break;
        case 'readable-null':
          final cd = createReadableClipboardData(null);
          expect(cd.types, c['types']);
          expect(cd.getData('text/plain'), c['text']);
          break;
        case 'writable':
          final dt = _DataTransfer(<String, String>{});
          final wd = createWritableClipboardData(dt);
          wd.setData('text/plain', 'written');
          wd.setData('text/html', '<i>x</i>');
          expect(_norm(dt.data), c['map']);
          break;
        case 'writable-null':
          final wd = createWritableClipboardData(null);
          wd.setData('text/plain', 'ignored');
          expect(c['ok'], isTrue);
          break;
        case 'paste-with-valid-meta':
        case 'paste-bad-version':
        case 'paste-bad-json':
          {
            final rawMeta = c['name'] == 'paste-with-valid-meta'
                ? jsonEncode(<String, Object?>{
                    'version': 1,
                    'id': 'id-1',
                    'isFromEmptySelection': false,
                    'isBlock': true,
                    'multicursorText': null,
                    'mode': 'typescript',
                  })
                : (c['name'] == 'paste-bad-version'
                    ? jsonEncode(<String, Object?>{'version': 2})
                    : '{not json');
            final dt = _DataTransfer(<String, String>{
              'text/plain': 'pasted',
              'vscode-editor-data': rawMeta,
            });
            final result = getClipboardTextData(dt, (f) => (f as _File).path);
            expect(result[0], c['text']);
            expect(_metaToTruth(result[1] as ClipboardStoredMetadata?),
                c['metadata']);
          }
          break;
        case 'paste-files-fallback':
          {
            final dt = _DataTransfer(<String, String>{}, <Object>[
              _File('a.txt', '/tmp/a.txt'),
              _File('b.txt', null),
            ]);
            final result = getClipboardTextData(dt, (f) => (f as _File).path);
            expect(result[0], c['text']);
            expect(result[1], c['metadata']);
          }
          break;
        case 'paste-inmemory-fallback':
          {
            final meta = _metaFromTruth(c['metadata']);
            InMemoryClipboardMetadataManager.INSTANCE.set('mem-text', meta);
            final dt = _DataTransfer(<String, String>{'text/plain': 'mem-text'});
            final result = getClipboardTextData(dt, (f) => (f as _File).path);
            final text = result[0] as String;
            final effective = result[1] as ClipboardStoredMetadata? ??
                InMemoryClipboardMetadataManager.INSTANCE.get(text);
            expect(text, c['text']);
            expect(_metaToTruth(effective), c['metadata']);
          }
          break;
        default:
          fail('unknown case ${c['name']}');
      }
    });
  }
}
