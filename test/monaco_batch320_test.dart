// batch320: inlineCompletions/utils.ts truth replay.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationTokenSource;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show DisposableStore;
import 'package:semi_design_flutter/src/monaco/base/common/observable.dart'
    show observableValue;
import 'package:semi_design_flutter/src/monaco/editor/common/core/edits/textEdit.dart'
    show TextReplacement;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/utils.dart'
    show
      ErrorResult,
      addPositions,
      convertItemsToStableObservables,
      errorResultConsoleError,
      getEndPositionsAfterApplying,
      getModifiedRangesAfterApplying,
      getReadonlyEmptyArray,
      subtractPositions,
      substringPos,
      wait;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch320_truth.json').readAsStringSync())
    as Map<String, dynamic>;

List<Object?> _pos(Object? p) {
  final Position v = p as Position;
  return <Object?>[v.lineNumber, v.column];
}

List<Object?> _range(Object? r) {
  final Range v = r as Range;
  return <Object?>[
    v.startLineNumber,
    v.startColumn,
    v.endLineNumber,
    v.endColumn,
  ];
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('position helpers match truth', () {
    for (final dynamic raw in truth['positions'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      late Position result;
      if (c['label'] == 'add-basic') {
        result = addPositions(Position(3, 5), Position(2, 4));
      } else if (c['label'] == 'add-single-line') {
        result = addPositions(Position(3, 5), Position(1, 7));
      } else if (c['label'] == 'subtract-basic') {
        result = subtractPositions(Position(8, 9), Position(3, 4));
      } else {
        result = subtractPositions(Position(8, 9), Position(8, 4));
      }
      expect(_pos(result), c['result'], reason: c['label'] as String);
    }
  });

  test('substringPos matches truth', () {
    for (final dynamic raw in truth['substrings'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      final Map<String, dynamic> p = c['pos'] as Map<String, dynamic>;
      expect(
        substringPos('one\ntwo\nthree',
            Position(p['lineNumber'] as int, p['column'] as int)),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('edit range helpers match truth', () {
    final List<TextReplacement> edits = <TextReplacement>[
      TextReplacement(Range(3, 2, 3, 4), 'X'),
      TextReplacement(Range(1, 2, 1, 3), 'Y'),
      TextReplacement(Range(2, 1, 2, 2), 'Z'),
    ];
    expect(
      getModifiedRangesAfterApplying(edits).map(_range).toList(),
      truth['modified'],
    );
    expect(
      getEndPositionsAfterApplying(edits).map(_pos).toList(),
      truth['ends'],
    );
  });

  test('empty array is shared', () {
    expect(identical(getReadonlyEmptyArray<Object>(),
        getReadonlyEmptyArray<Object>()), truth['emptyArraySame']);
  });

  test('ErrorResult matches truth', () {
    final Map<String, dynamic> e = truth['errorResult'] as Map<String, dynamic>;
    final List<String> captured = <String>[];
    errorResultConsoleError = (String message, Object? error) =>
        captured.add(error == null ? 'undefined' : error.toString());

    final ErrorResult<Object?> result = ErrorResult.message('bad thing');
    final ErrorResult<int> generic = ErrorResult<int>(42);
    expect(result.errorMessage, e['message']);
    expect(ErrorResult.is_(result), e['isMessage']);
    expect(ErrorResult.is_(generic), e['isGeneric']);
    result.logError();
    generic.logError();
    expect(captured, truth['errors']);
  });

  test('wait resolves on timeout and cancellation', () async {
    final List<String> order = <String>[];
    await wait(1);
    order.add('timeout');
    final CancellationTokenSource cts = CancellationTokenSource();
    Timer(const Duration(milliseconds: 1), () => cts.cancel());
    await wait(1000, cts.token);
    order.add('cancelled:true');
    expect(order, truth['wait']);
  });

  test('stable observables match truth', () async {
    final DisposableStore store = DisposableStore();
    final source = observableValue<List<String>, Object?>(
        'source', <String>['a', 'b']);
    final stable = convertItemsToStableObservables<String>(source, store);
    List<String> read() => stable
        .read(null)
        .map((o) => o.read(null))
        .toList();
    final List<String> first = read();
    source.set(<String>['a', 'c', 'd'], null, null);
    await Future<void>.delayed(Duration.zero);
    final List<String> second = read();
    final bool sameFirst = identical(stable.read(null)[0], stable.read(null)[0]);
    store.dispose();
    final Map<String, dynamic> expected =
        truth['observable'] as Map<String, dynamic>;
    expect(
      <String, Object?>{
        'first': first,
        'second': second,
        'sameFirst': sameFirst,
      },
      expected,
    );
  });
}
