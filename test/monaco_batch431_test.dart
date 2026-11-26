import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/event.dart' show Emitter, Event;
import '../lib/src/monaco/editor/contrib/codelens/browser/codeLensCache.dart'
    show CodeLensCache, RunWhenIdle;
import '../lib/src/monaco/editor/contrib/codelens/browser/codelens.dart'
    show CodeLens, CodeLensList, CodeLensModel, ICodeLensProvider;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/platform/storage/common/storage.dart'
    show
        IStorageServiceType,
        StorageScope,
        StorageTarget,
        WillSaveStateEvent,
        WillSaveStateReason;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch431_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _Storage implements IStorageServiceType {
  Map<String, String> stored;
  final List<Map<String, Object?>> writes = <Map<String, Object?>>[];
  final List<Map<String, Object?>> removed = <Map<String, Object?>>[];
  final Emitter<WillSaveStateEvent> _onWillSaveState =
      Emitter<WillSaveStateEvent>();

  _Storage(this.stored);

  @override
  String? get(String key, int scope, [String? fallbackValue]) =>
      stored.containsKey(key) ? stored[key] : fallbackValue;
  @override
  void store(String key, Object? value, int scope, int target,
      [bool external = false]) {
    stored[key] = value as String;
    writes.add(<String, Object?>{'key': key, 'value': value, 'scope': scope, 'target': target});
  }

  @override
  void remove(String key, int scope, [bool external = false]) {
    removed.add(<String, Object?>{'key': key, 'scope': scope});
    stored.remove(key);
  }

  @override
  Event<WillSaveStateEvent> get onWillSaveState => _onWillSaveState.event;

  void fire(int reason) => _onWillSaveState.fire(WillSaveStateEvent(reason));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Uri {
  final String value;
  _Uri(this.value);
  @override
  String toString() => value;
}

// Bridge: cache reads `m.uri.toString()`, so expose `uri` via a getter.
class _ModelBridge {
  final String path;
  final int lineCount;
  _ModelBridge(this.path, this.lineCount);
  Object get uri => _Uri(path);
  int getLineCount() => lineCount;
}

Map<String, Object?> _lensesJson(CodeLensModel? m) {
  if (m == null) return <String, Object?>{'lenses': <Object?>[]};
  return <String, Object?>{
    'lenses': m.lenses.map((dynamic item) {
      final CodeLens sym = (item as dynamic).symbol as CodeLens;
      final Object? cmd = sym.command;
      return <String, Object?>{
        'start': sym.range.startLineNumber,
        'command': cmd == null
            ? null
            : <String, Object?>{
                'id': (cmd as Map)['id'],
                'title': cmd['title'],
              },
      };
    }).toList(),
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('code lens cache truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // Case 1+2: put/get/delete roundtrip (command id stripped, title kept).
    final _Storage s1 = _Storage(<String, String>{});
    final CodeLensCache c1 = CodeLensCache(s1, (void Function() cb) {});
    final _ModelBridge m = _ModelBridge('file:///a.ts', 10);
    final CodeLensModel data = CodeLensModel();
    data.add(
      CodeLensList(<CodeLens>[
        CodeLens(Range(1, 1, 1, 5), <String, Object?>{'id': 'cmd1', 'title': 'Do It'}),
        CodeLens(Range(3, 1, 3, 5)),
      ]),
      _FakeProvider() as ICodeLensProvider,
    );
    c1.put(m, data);
    final CodeLensModel? got = c1.get(m);
    actual['put-get'] = <String, Object?>{
      'stored': (_lensesJson(got)['lenses'] as List),
      'ids': got == null
          ? <Object?>[]
          : got.lenses
              .map((dynamic i) => (i as dynamic).symbol.command == null
                  ? null
                  : ((i as dynamic).symbol.command as Map)['id'])
              .toList(),
    };
    actual['wrong-line-count'] = <String, Object?>{
      'got': c1.get(_ModelBridge('file:///a.ts', 11)) != null,
    };
    c1.delete(m);
    actual['after-delete'] = <String, Object?>{'got': c1.get(m) != null};

    // Case 3: restore from serialized data.
    final _Storage s2 = _Storage(<String, String>{
      'codelens/cache2': jsonEncode(<String, Object?>{
        'file:///b.ts': <String, Object?>{'lineCount': 5, 'lines': <int>[1, 3, 7]},
      }),
    });
    final CodeLensCache c2 = CodeLensCache(s2, (void Function() cb) {});
    final CodeLensModel? restored = c2.get(_ModelBridge('file:///b.ts', 5));
    actual['restore'] = <String, Object?>{
      'lenses': restored == null
          ? null
          : restored.lenses.map((dynamic i) {
              final CodeLens sym = (i as dynamic).symbol as CodeLens;
              return <Object?>[
                sym.range.startLineNumber,
                sym.range.startColumn,
                sym.range.endColumn,
              ];
            }).toList(),
    };

    // Case 4: serialize on shutdown (non-shutdown ignored).
    final _Storage s3 = _Storage(<String, String>{});
    final List<void Function()> idleCbs = <void Function()>[];
    final CodeLensCache c3 = CodeLensCache(
      s3,
      (void Function() cb) => idleCbs.add(cb),
    );
    final CodeLensModel data3 = CodeLensModel();
    data3.add(
      CodeLensList(<CodeLens>[
        CodeLens(Range(2, 1, 2, 4)),
        CodeLens(Range(2, 6, 2, 9)),
        CodeLens(Range(5, 1, 5, 3)),
      ]),
      _FakeProvider() as ICodeLensProvider,
    );
    c3.put(_ModelBridge('file:///c.ts', 8), data3);
    s3.fire(WillSaveStateReason.NONE);
    final int afterNone = s3.writes.length;
    s3.fire(WillSaveStateReason.SHUTDOWN);
    actual['shutdown'] = <String, Object?>{
      'afterNone': afterNone,
      'writes': s3.writes,
      'removed': s3.removed,
    };

    // Case 5: corrupt stored data ignored.
    final _Storage s4 =
        _Storage(<String, String>{'codelens/cache2': 'not json'});
    final CodeLensCache c4 = CodeLensCache(s4, (void Function() cb) {});
    actual['corrupt'] = <String, Object?>{
      'got': c4.get(_ModelBridge('file:///x.ts', 1)) != null,
    };

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}

class _FakeProvider implements ICodeLensProvider {
  @override
  Future<CodeLensList?> provideCodeLenses(Object model, Object token) =>
      throw StateError('not supported');
  @override
  Future<CodeLens?> Function(Object, CodeLens, Object)? get resolveCodeLens => null;
}
