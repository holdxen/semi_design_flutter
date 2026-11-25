// 1:1 replay of
// `editor/contrib/inlineCompletions/browser/model/InlineSuggestAlternativeAction.ts`
// (19 lines). Truth: `tool/ts2dart/_batch329_truth.cjs` -> `batch329_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/themables.dart' show ThemeIcon;
import '../lib/src/monaco/editor/contrib/inlineCompletions/browser/model/InlineSuggestAlternativeAction.dart'
    as alt;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch329_truth.json').readAsStringSync()));

void main() {
  final truth = _truth();

  Object? run(Object? Function() body, {required bool expectThrow}) {
    if (expectThrow) {
      expect(body, throwsA(anything));
      return null;
    }
    return body();
  }

  test('toStringStatic mirrors null/undefined, raw ids and command deref', () {
    final undefinedAction = _map(truth['undefinedAction']);
    final nullAction = _map(truth['nullAction']);
    final idString = _map(truth['idString']);
    final idEmpty = _map(truth['idEmpty']);
    final idNumber = _map(truth['idNumber']);
    final idMissing = _map(truth['idMissing']);
    final commandNull = _map(truth['commandNull']);
    final commandMissing = _map(truth['commandMissing']);

    Map<String, Object?> action(Object? command) =>
        <String, Object?>{'label': 'l', 'command': command};

    expect(alt.InlineSuggestAlternativeAction.toStringStatic(null),
        undefinedAction['value']);
    expect(alt.InlineSuggestAlternativeAction.toStringStatic(null),
        nullAction['value']);
    expect(
        alt.InlineSuggestAlternativeAction.toStringStatic(
            action(<String, Object?>{'id': 'cmd.x'})),
        idString['value']);
    expect(
        alt.InlineSuggestAlternativeAction.toStringStatic(
            action(<String, Object?>{'id': ''})),
        idEmpty['value']);
    expect(
        alt.InlineSuggestAlternativeAction.toStringStatic(
            action(<String, Object?>{'id': 0})),
        idNumber['value']);
    expect(
        alt.InlineSuggestAlternativeAction.toStringStatic(
            action(<String, Object?>{})),
        idMissing['value']);

    run(() => alt.InlineSuggestAlternativeAction.toStringStatic(action(null)),
        expectThrow: commandNull['threw'] as bool);
    run(
        () => alt.InlineSuggestAlternativeAction
            .toStringStatic(<String, Object?>{'label': 'l'}),
        expectThrow: commandMissing['threw'] as bool);

    expect(undefinedAction['threw'], isFalse);
    expect(nullAction['threw'], isFalse);
  });

  test('the carrier keeps the alias shape', () {
    final value = alt.InlineSuggestAlternativeAction(
      label: 'l',
      icon: ThemeIcon('l'),
      command: <String, Object?>{'id': 'c'},
      count: Future<int>.value(3),
    );
    expect(value.label, 'l');
    expect(value.command, isA<Map<String, Object?>>());
    expect(value.count, isA<Future<int>>());
  });
}
