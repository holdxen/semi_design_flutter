// Truth-replay test for batch241: editor/common/editorCommon.ts runtime
// symbols (ScrollType / Handler / EditorType / isThemeColor).
// Truth is produced by tool/ts2dart/_batch241_truth.cjs executing the REAL
// transpiled source; this test feeds the same inputs to the Dart port.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/editorCommon.dart';

Map<String, Object?> _loadTruth() {
  final File f = File('tool/ts2dart/batch241_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
}

void main() {
  final Map<String, Object?> truth = _loadTruth();

  test('ScrollType const enum values match real source', () {
    final Map<String, Object?> t = truth['ScrollType'] as Map<String, Object?>;
    expect(ScrollType.Smooth, t['Smooth']);
    expect(ScrollType.Immediate, t['Immediate']);
    expect(t['0'], 'Smooth');
    expect(t['1'], 'Immediate');
  });

  test('Handler const enum values match real source', () {
    final Map<String, Object?> t = truth['Handler'] as Map<String, Object?>;
    expect(Handler.CompositionStart, t['CompositionStart']);
    expect(Handler.CompositionEnd, t['CompositionEnd']);
    expect(Handler.Type, t['Type']);
    expect(Handler.ReplacePreviousChar, t['ReplacePreviousChar']);
    expect(Handler.CompositionType, t['CompositionType']);
    expect(Handler.Paste, t['Paste']);
    expect(Handler.Cut, t['Cut']);
  });

  test('EditorType const object matches real source', () {
    final Map<String, Object?> t = truth['EditorType'] as Map<String, Object?>;
    expect(EditorType.ICodeEditor, t['ICodeEditor']);
    expect(EditorType.IDiffEditor, t['IDiffEditor']);
  });

  test('isThemeColor truth table matches real source', () {
    final List<Object?> cases = truth['isThemeColor'] as List<Object?>;
    for (final Object? raw in cases) {
      final Map<String, Object?> c = raw as Map<String, Object?>;
      final String label = c['label'] as String;
      final bool expected = c['result'] as bool;
      final Object? input = _materialize(c['input']);
      expect(isThemeColor(input), expected, reason: 'isThemeColor case: $label');
    }
  });
}

/// Recreate the JS-shaped input the harness fed to the real function.
/// Plain objects become Dart Maps (the ported `_idOf` bridge reads Map['id']).
Object? _materialize(Object? json) {
  if (json is Map<String, Object?>) {
    return json.map((String k, Object? v) => MapEntry<String, Object?>(k, _materialize(v)));
  }
  if (json is List<Object?>) {
    return json.map(_materialize).toList();
  }
  return json;
}
