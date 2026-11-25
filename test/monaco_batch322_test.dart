// 1:1 replay of `editor/common/model/textModelStringEdit.ts` (61 lines).
//
// Truth: `tool/ts2dart/_batch322_truth.cjs` -> `batch322_truth.json`, produced
// by running the real module against a line-based fake document.
//
// NOTE: batch number 322 was chosen because 248-321 are owned by a concurrent
// session; this file was originally written as batch248 by mistake.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/edits/stringEdit.dart'
    show StringEdit, StringReplacement;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/ranges/lineRange.dart'
    show LineRange;
import '../lib/src/monaco/editor/common/core/ranges/offsetRange.dart'
    show OffsetRange;
import '../lib/src/monaco/editor/common/diff/rangeMapping.dart'
    show DetailedLineRangeMapping, RangeMapping;
import '../lib/src/monaco/editor/common/model/mirrorTextModel.dart'
    show IModelContentChange;
import '../lib/src/monaco/editor/common/model/textModelStringEdit.dart'
    as stringEdit;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch322_truth.json').readAsStringSync()));

class _FakeDoc {
  _FakeDoc(List<String> lines) : text = lines.join('\n') {
    lineStarts = <int>[0];
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '\n') lineStarts.add(i + 1);
    }
  }

  final String text;
  late final List<int> lineStarts;

  String getValue() => text;

  Position getPositionAt(int offset) {
    var line = 0;
    while (line + 1 < lineStarts.length && lineStarts[line + 1] <= offset) {
      line++;
    }
    return Position(line + 1, offset - lineStarts[line] + 1);
  }

  int getOffsetAt(Position position) =>
      lineStarts[position.lineNumber - 1] + position.column - 1;

  String getValueInRange(Range range) {
    final int start = getOffsetAt(range.getStartPosition());
    final int end = getOffsetAt(range.getEndPosition());
    return text.substring(start, end);
  }
}

class _Change implements IModelContentChange {
  _Change(this.range, this.rangeOffset, this.rangeLength, this.text);

  @override
  final Range range;

  @override
  final int rangeOffset;

  @override
  final int rangeLength;

  @override
  final String text;
}

Map<String, Object?> _replacement(Object? r) {
  final s = r as StringReplacement;
  return <String, Object?>{
    'start': s.replaceRange.start,
    'length': s.replaceRange.length,
    'newText': s.newText,
  };
}

void main() {
  final truth = _truth();

  test('offsetEditToEditOperations maps offsets to line/column ranges', () {
    final doc = _FakeDoc(<String>['alpha', 'beta gamma', 'delta', '', 'epsilon']);
    final offsetEdit = StringEdit(<StringReplacement>[
      StringReplacement(OffsetRange.ofStartAndLength(0, 5), 'ALPHA'),
      StringReplacement(OffsetRange.ofStartAndLength(12, 5), ''),
      StringReplacement(OffsetRange.ofStartAndLength(18, 0), 'INSERTED'),
    ]);
    final operations = stringEdit.offsetEditToEditOperations(offsetEdit, doc);
    expect(
        operations
            .map((op) => <String, Object?>{
                  'range': <int>[
                    op.range.startLineNumber,
                    op.range.startColumn,
                    op.range.endLineNumber,
                    op.range.endColumn,
                  ],
                  'text': op.text,
                  'forceMoveMarkers': op.forceMoveMarkers,
                })
            .toList(),
        truth['offsetEditToEditOperations']);
  });

  test('offsetEditFromContentChanges reverses descending changes', () {
    final changes = <_Change>[
      _Change(Range(4, 1, 4, 1), 23, 0, 'new\n'),
      _Change(Range(2, 1, 2, 5), 6, 4, 'B'),
      _Change(Range(1, 6, 1, 6), 5, 0, '!'),
    ];
    final edit = stringEdit.offsetEditFromContentChanges(changes);
    final expected = _map(truth['offsetEditFromContentChanges']);
    expect(edit.toString(), expected['toString']);
    expect(edit.replacements.map(_replacement).toList(), expected['replacements']);
  });

  test('offsetEditFromLineRangeMapping uses modified text and original offsets',
      () {
    final original = _FakeDoc(<String>['one', 'two', 'three', 'four']);
    final modified = _FakeDoc(<String>['one', 'TWO!', 'three', 'four', 'five']);
    final mapping = DetailedLineRangeMapping(
      LineRange.ofLength(2, 1),
      LineRange.ofLength(2, 1),
      <RangeMapping>[
        RangeMapping(Range(2, 1, 2, 4), Range(2, 1, 2, 5)),
        RangeMapping(Range(3, 1, 3, 6), Range(3, 1, 3, 6)),
      ],
    );
    final edit = stringEdit.offsetEditFromLineRangeMapping(
        original, modified, <DetailedLineRangeMapping>[mapping]);
    final expected = _map(truth['offsetEditFromLineRangeMapping']);
    expect(edit.toString(), expected['toString']);
    expect(edit.replacements.map(_replacement).toList(), expected['replacements']);
    expect(edit.apply(original.getValue()), expected['result']);

    final withoutInner = DetailedLineRangeMapping(
        LineRange.ofLength(1, 2), LineRange.ofLength(1, 2), null);
    final empty = stringEdit.offsetEditFromLineRangeMapping(
        original, modified, <DetailedLineRangeMapping>[withoutInner]);
    final emptyExpected = _map(expected['emptyInner']);
    expect(empty.toString(), emptyExpected['toString']);
    expect(empty.replacements.length, emptyExpected['count']);
  });

  test('linesLengthEditFromModelContentChange composes line-length edits', () {
    final changes = <_Change>[
      _Change(Range(2, 1, 2, 4), 4, 3, 'TWO'),
      _Change(Range(4, 1, 5, 1), 14, 6, 'four\nfive\n'),
      _Change(Range(1, 1, 1, 1), 0, 0, 'zero\n'),
    ];
    final edit = stringEdit.linesLengthEditFromModelContentChange(changes);
    final expected = _map(truth['linesLengthEdit']);
    expect(edit.toString(), expected['toString']);

    final original = _FakeDoc(<String>['one', 'two', 'three', 'four']);
    expect(
        edit
            .replacements
            .map((r) => <String, Object?>{
                  'start': r.replaceRange.start,
                  'endExclusive': r.replaceRange.endExclusive,
                  'newLength': r.newLength,
                })
            .toList(),
        expected['replacements']);
    expect(edit.applyArray<String>(original.getValue().split('\n'), ''),
        expected['appliedToLines']);
  });
}
