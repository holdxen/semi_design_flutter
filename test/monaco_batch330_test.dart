// 1:1 replay of `editor/common/model/textModelText.ts` (29 lines).
//
// Truth: `tool/ts2dart/_batch330_truth.cjs` -> `batch330_truth.json`.
// Transformer-based helpers of `AbstractText` are covered by that class' own
// batch, so this replay stays on the surface `TextModelText` overrides plus the
// inherited range/position composition.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/model/textModelText.dart' as text;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch330_truth.json').readAsStringSync()));

class _FakeModel {
  _FakeModel(this.lines) : value = lines.join('\n') {
    starts = <int>[0];
    for (var i = 0; i < value.length; i++) {
      if (value[i] == '\n') starts.add(i + 1);
    }
  }

  final List<String> lines;
  final String value;
  late final List<int> starts;

  int getLineCount() => lines.length;

  int getLineLength(int lineNumber) => lines[lineNumber - 1].length;

  int _offsetAt(dynamic position) =>
      starts[(position.lineNumber as int) - 1] + (position.column as int) - 1;

  String getValueInRange(Range range) => value.substring(
      _offsetAt(range.getStartPosition()), _offsetAt(range.getEndPosition()));
}

void main() {
  final truth = _truth();
  final model = _FakeModel(<String>['alpha', 'beta gamma', '', 'delta']);
  final textModel = text.TextModelText(model);

  test('length is derived from the last line number and length', () {
    expect(textModel.length.lineCount, (truth['length'] as List)[0]);
    expect(textModel.length.columnCount, (truth['length'] as List)[1]);
    expect(<int>[1, 2, 3, 4].map(textModel.getLineLength).toList(),
        truth['lineLengths']);
    expect(textModel.getValue(), truth['getValue']);
  });

  test('getValueOfRange delegates to the model (incl. reversed ranges)', () {
    expect(textModel.getValueOfRange(Range(2, 2, 3, 1)),
        truth['valueOfRange']);
    expect(textModel.getValueOfRange(Range(1, 1, 4, 6)),
        truth['valueOfFullRange']);
    expect(textModel.getValueOfRange(Range(3, 1, 2, 2)),
        truth['valueOfReversedRange']);
  });

  test('inherited endPositionExclusive / lineRange use the derived length', () {
    expect(
        <int>[
          textModel.endPositionExclusive.lineNumber,
          textModel.endPositionExclusive.column,
        ],
        truth['endPositionExclusive']);
    expect(<int>[
      textModel.lineRange.startLineNumber,
      textModel.lineRange.endLineNumberExclusive,
    ], truth['lineRange']);
  });
}
