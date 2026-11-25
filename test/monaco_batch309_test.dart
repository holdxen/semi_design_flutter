// batch309: imeRecordedTypes.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/test/browser/controller/imeRecordedTypes.dart'
    as t;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch309_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final Map<String, dynamic> truth = _truth();

  test('erased declarations match truth', () {
    final List<dynamic> decls = truth['declarations'] as List<dynamic>;
    expect(
      decls.map((d) => (d as Map<String, dynamic>)['name']).toList(),
      <String>[
        'IRecordedTextareaState',
        'IRecordedKeyboardEvent',
        'IRecordedCompositionEvent',
        'IRecordedInputEvent',
        'IRecordedEvent',
        'IRecorded',
      ],
    );
    expect(truth['runtimeExports'], isEmpty);
  });

  test('carriers are constructible and union marker holds', () {
    final t.IRecordedTextareaState state = t.IRecordedTextareaState(
      selectionDirection: 'forward',
      selectionEnd: 3,
      selectionStart: 1,
      value: 'abc',
    );
    final t.IRecordedEvent keyboard =
        t.IRecordedKeyboardEvent(state: state, key: 'a');
    final t.IRecordedEvent composition =
        t.IRecordedCompositionEvent(state: state, data: 'a');
    final t.IRecordedEvent input = t.IRecordedInputEvent(state: state);
    final t.IRecorded recorded = t.IRecorded(
      env: t.IRecordedEnv(1, Object()),
      initial: state,
      events: <t.IRecordedEvent>[keyboard, composition, input],
      finalState: state,
    );
    expect(keyboard, isA<t.IRecordedKeyboardEvent>());
    expect(composition, isA<t.IRecordedCompositionEvent>());
    expect(input, isA<t.IRecordedInputEvent>());
    expect(recorded.events.length, 3);
    expect(recorded.finalState.value, 'abc');
  });
}
