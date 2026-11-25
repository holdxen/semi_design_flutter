// 1:1 replay of `editor/contrib/inlineCompletions/browser/model/typingSpeed.ts`.
// Truth: `tool/ts2dart/_batch421_truth.cjs` -> `batch421_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;

import '../lib/src/monaco/editor/contrib/inlineCompletions/browser/model/typingSpeed.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch421_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _Change implements ITypingContentChangedEvent {
  @override
  final List<Object> changes;
  @override
  final List<Object>? detailedReasons;
  _Change(this.changes, this.detailedReasons);
}

class _Reason {
  final Object metadata;
  _Reason(this.metadata);
}

class _Metadata {
  final String source;
  final Object? kind;
  final bool isUndoing;
  final bool isRedoing;
  _Metadata(this.source, this.kind, [this.isUndoing = false, this.isRedoing = false]);
}

class _Model implements ITypingTextModel {
  final List<void Function(Object)> listeners = <void Function(Object)>[];

  @override
  Object get onDidChangeContent => (void Function(Object) l) {
        listeners.add(l);
        return _Disposable();
      };

  void fire(Object e) {
    for (final void Function(Object) l in listeners.toList()) l(e);
  }
}

class _Disposable implements IDisposable {
  @override
  void dispose() {}
}

_Change change(String text, int rangeLength,
        [String source = 'cursor', Object? kind, bool undo = false]) =>
    _Change(
      <Object>[<String, Object>{'text': text, 'rangeLength': rangeLength}],
      <Object>[
        _Reason(_Metadata(source, kind, undo, false)),
      ],
    );

_Change nonTypingChange(String text, int rangeLength) => _Change(
      <Object>[<String, Object>{'text': text, 'rangeLength': rangeLength}],
      <Object>[],
    );

Map<String, Object?> _resultJson(TypingIntervalResult r) => <String, Object?>{
      'averageInterval': r.averageInterval,
      'characterCount': r.characterCount,
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('typing speed replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // empty
    {
      int now = 0;
      final TypingInterval t = TypingInterval(_Model(), () => now);
      actual['empty'] = <String, Object?>{
        'result': _resultJson(t.getTypingInterval()),
      };
      t.dispose();
    }

    // single session
    {
      int now = 0;
      final _Model model = _Model();
      final TypingInterval t = TypingInterval(model, () => now);
      now = 1000;
      for (int i = 0; i < 20; i++) {
        now = 1000 + i * 100;
        model.fire(change('a', 0, 'cursor', 'type'));
      }
      now = 3000;
      actual['single-session'] = <String, Object?>{
        'result': _resultJson(t.getTypingInterval()),
      };
      t.dispose();
    }

    // two sessions
    {
      int now = 0;
      final _Model model = _Model();
      final TypingInterval t = TypingInterval(model, () => now);
      for (int i = 0; i < 10; i++) {
        now = i * 100;
        model.fire(change('a', 0, 'cursor', 'type'));
      }
      now = 5000;
      t.getTypingInterval();
      for (int i = 0; i < 15; i++) {
        now = 5000 + i * 80;
        model.fire(change('b', 0, 'cursor', 'type'));
      }
      now = 7000;
      model.fire(change('pasted', 0, 'paste', null));
      actual['two-sessions'] = <String, Object?>{
        'result': _resultJson(t.getTypingInterval()),
      };
      t.dispose();
    }

    // undo only
    {
      int now = 0;
      final _Model model = _Model();
      final TypingInterval t = TypingInterval(model, () => now);
      for (int i = 0; i < 5; i++) {
        now = i * 100;
        model.fire(change('a', 0, 'cursor', 'type', true));
      }
      now = 2000;
      actual['undo-only'] = <String, Object?>{
        'result': _resultJson(t.getTypingInterval()),
      };
      t.dispose();
    }

    // deletions
    {
      int now = 0;
      final _Model model = _Model();
      final TypingInterval t = TypingInterval(model, () => now);
      for (int i = 0; i < 12; i++) {
        now = i * 100;
        model.fire(change('', 3, 'cursor', 'type'));
      }
      now = 2000;
      actual['deletions'] = <String, Object?>{
        'result': _resultJson(t.getTypingInterval()),
      };
      t.dispose();
    }

    // reset
    {
      int now = 0;
      final _Model model = _Model();
      final TypingInterval t = TypingInterval(model, () => now);
      for (int i = 0; i < 25; i++) {
        now = i * 90;
        model.fire(change('x', 0, 'cursor', 'type'));
      }
      final Map<String, Object?> before = _resultJson(t.getTypingInterval());
      now = 5000;
      t.reset();
      actual['reset'] = <String, Object?>{
        'before': before,
        'after': _resultJson(t.getTypingInterval()),
      };
      t.dispose();
    }

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
