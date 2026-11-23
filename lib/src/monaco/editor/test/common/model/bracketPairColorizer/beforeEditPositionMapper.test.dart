// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/model/bracketPairColorizer/beforeEditPositionMapper.test.ts
// Translated 1:1. The mocha suite's active cases become Dart functions; each
// case is a visual grid comparison produced by compute().
//   - TextEdit (extends TextEditInfo) -> subclass with newText field.
//   - Range.fromPositions(start, end) -> named `end:`.
//   - Range.lift(...) returns nullable in the port -> `!`.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../../../base/common/strings.dart' show splitLines;
import '../../../../common/core/position.dart' show Position;
import '../../../../common/core/range.dart' show Range;
import '../../../../common/model/bracketPairsTextModelPart/bracketPairsTree/beforeEditPositionMapper.dart'
    show BeforeEditPositionMapper, TextEditInfo;
import '../../../../common/model/bracketPairsTextModelPart/bracketPairsTree/length.dart'
    show
        Length,
        lengthOfString,
        lengthToObj,
        lengthToPosition,
        toLength;

class TextEdit extends TextEditInfo {
  final String newText;
  TextEdit(Length startOffset, Length endOffset, this.newText)
      : super(startOffset, endOffset, lengthOfString(newText));
}

void testSingleLine1() {
  _assertCompute(
    ['0123456789'],
    [TextEdit(toLength(0, 4), toLength(0, 7), 'xy')],
    [
      '0  1  2  3  x  y  7  8  9  ',
      '0  0  0  0  0  0  0  0  0  0  ',
      '0  1  2  3  4  5  7  8  9  10 ',
      '0  0  0  0  0  0  ∞  ∞  ∞  ∞  ',
      '4  3  2  1  0  0  ∞  ∞  ∞  ∞  ',
    ],
  );
}

void testSingleLine2() {
  _assertCompute(
    ['0123456789'],
    [
      TextEdit(toLength(0, 2), toLength(0, 4), 'xxxx'),
      TextEdit(toLength(0, 6), toLength(0, 6), 'yy'),
    ],
    [
      '0  1  x  x  x  x  4  5  y  y  6  7  8  9  ',
      '0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  ',
      '0  1  2  3  4  5  4  5  6  7  6  7  8  9  10 ',
      '0  0  0  0  0  0  0  0  0  0  ∞  ∞  ∞  ∞  ∞  ',
      '2  1  0  0  0  0  2  1  0  0  ∞  ∞  ∞  ∞  ∞  ',
    ],
  );
}

void testMultiLineReplace1() {
  _assertCompute(
    ['₀₁₂₃₄₅₆₇₈₉', '0123456789', '⁰¹²³⁴⁵⁶⁷⁸⁹'],
    [TextEdit(toLength(0, 3), toLength(1, 3), 'xy')],
    [
      '₀  ₁  ₂  x  y  3  4  5  6  7  8  9  ',
      '0  0  0  0  0  1  1  1  1  1  1  1  1  ',
      '0  1  2  3  4  3  4  5  6  7  8  9  10 ',
      '0  0  0  0  0  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '3  2  1  0  0  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '⁰  ¹  ²  ³  ⁴  ⁵  ⁶  ⁷  ⁸  ⁹  ',
      '2  2  2  2  2  2  2  2  2  2  2  ',
      '0  1  2  3  4  5  6  7  8  9  10 ',
      '∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
    ],
  );
}

void testMultiLineReplace2() {
  _assertCompute(
    ['₀₁₂₃₄₅₆₇₈₉', '012345678', '⁰¹²³⁴⁵⁶⁷⁸⁹'],
    [
      TextEdit(toLength(0, 3), toLength(1, 0), 'ab'),
      TextEdit(toLength(1, 5), toLength(1, 7), 'c'),
    ],
    [
      '₀  ₁  ₂  a  b  0  1  2  3  4  c  7  8  ',
      '0  0  0  0  0  1  1  1  1  1  1  1  1  1  ',
      '0  1  2  3  4  0  1  2  3  4  5  7  8  9  ',
      '0  0  0  0  0  0  0  0  0  0  0  ∞  ∞  ∞  ',
      '3  2  1  0  0  5  4  3  2  1  0  ∞  ∞  ∞  ',
      '⁰  ¹  ²  ³  ⁴  ⁵  ⁶  ⁷  ⁸  ⁹  ',
      '2  2  2  2  2  2  2  2  2  2  2  ',
      '0  1  2  3  4  5  6  7  8  9  10 ',
      '∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
    ],
  );
}

void testMultiLineReplace3() {
  _assertCompute(
    ['₀₁₂₃₄₅₆₇₈₉', '012345678', '⁰¹²³⁴⁵⁶⁷⁸⁹'],
    [
      TextEdit(toLength(0, 3), toLength(1, 0), 'ab'),
      TextEdit(toLength(1, 5), toLength(1, 7), 'c'),
      TextEdit(toLength(1, 8), toLength(2, 4), 'd'),
    ],
    [
      '₀  ₁  ₂  a  b  0  1  2  3  4  c  7  d  ⁴  ⁵  ⁶  ⁷  ⁸  ⁹  ',
      '0  0  0  0  0  1  1  1  1  1  1  1  1  2  2  2  2  2  2  2  ',
      '0  1  2  3  4  0  1  2  3  4  5  7  8  4  5  6  7  8  9  10 ',
      '0  0  0  0  0  0  0  0  0  0  0  0  0  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '3  2  1  0  0  5  4  3  2  1  0  1  0  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
    ],
  );
}

void testMultiLineInsert1() {
  _assertCompute(
    ['012345678'],
    [TextEdit(toLength(0, 3), toLength(0, 5), 'a\nb')],
    [
      '0  1  2  a  ',
      '0  0  0  0  0  ',
      '0  1  2  3  4  ',
      '0  0  0  0  0  ',
      '3  2  1  0  0  ',
      'b  5  6  7  8  ',
      '1  0  0  0  0  0  ',
      '0  5  6  7  8  9  ',
      '0  ∞  ∞  ∞  ∞  ∞  ',
      '0  ∞  ∞  ∞  ∞  ∞  ',
    ],
  );
}

void testMultiLineInsert2() {
  _assertCompute(
    ['012345678'],
    [
      TextEdit(toLength(0, 3), toLength(0, 5), 'a\nb'),
      TextEdit(toLength(0, 7), toLength(0, 8), 'x\ny'),
    ],
    [
      '0  1  2  a  ',
      '0  0  0  0  0  ',
      '0  1  2  3  4  ',
      '0  0  0  0  0  ',
      '3  2  1  0  0  ',
      'b  5  6  x  ',
      '1  0  0  0  0  ',
      '0  5  6  7  8  ',
      '0  0  0  0  0  ',
      '0  2  1  0  0  ',
      'y  8  ',
      '1  0  0  ',
      '0  8  9  ',
      '0  ∞  ∞  ',
      '0  ∞  ∞  ',
    ],
  );
}

void testMultiLineReplaceInsert1() {
  _assertCompute(
    ['₀₁₂₃₄₅₆₇₈₉', '012345678', '⁰¹²³⁴⁵⁶⁷⁸⁹'],
    [TextEdit(toLength(0, 3), toLength(1, 1), 'aaa\nbbb')],
    [
      '₀  ₁  ₂  a  a  a  ',
      '0  0  0  0  0  0  0  ',
      '0  1  2  3  4  5  6  ',
      '0  0  0  0  0  0  0  ',
      '3  2  1  0  0  0  0  ',
      'b  b  b  1  2  3  4  5  6  7  8  ',
      '1  1  1  1  1  1  1  1  1  1  1  1  ',
      '0  1  2  1  2  3  4  5  6  7  8  9  ',
      '0  0  0  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '0  0  0  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '⁰  ¹  ²  ³  ⁴  ⁵  ⁶  ⁷  ⁸  ⁹  ',
      '2  2  2  2  2  2  2  2  2  2  2  ',
      '0  1  2  3  4  5  6  7  8  9  10 ',
      '∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
    ],
  );
}

void testMultiLineReplaceInsert2() {
  _assertCompute(
    ['₀₁₂₃₄₅₆₇₈₉', '012345678', '⁰¹²³⁴⁵⁶⁷⁸⁹'],
    [
      TextEdit(toLength(0, 3), toLength(1, 1), 'aaa\nbbb'),
      TextEdit(toLength(1, 5), toLength(1, 5), 'x\ny'),
      TextEdit(toLength(1, 7), toLength(2, 4), 'k\nl'),
    ],
    [
      '₀  ₁  ₂  a  a  a  ',
      '0  0  0  0  0  0  0  ',
      '0  1  2  3  4  5  6  ',
      '0  0  0  0  0  0  0  ',
      '3  2  1  0  0  0  0  ',
      'b  b  b  1  2  3  4  x  ',
      '1  1  1  1  1  1  1  1  1  ',
      '0  1  2  1  2  3  4  5  6  ',
      '0  0  0  0  0  0  0  0  0  ',
      '0  0  0  4  3  2  1  0  0  ',
      'y  5  6  k  ',
      '2  1  1  1  1  ',
      '0  5  6  7  8  ',
      '0  0  0  0  0  ',
      '0  2  1  0  0  ',
      'l  ⁴  ⁵  ⁶  ⁷  ⁸  ⁹  ',
      '2  2  2  2  2  2  2  2  ',
      '0  4  5  6  7  8  9  10 ',
      '0  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
      '0  ∞  ∞  ∞  ∞  ∞  ∞  ∞  ',
    ],
  );
}

// ------------------------------ helper -------------------------------------

void _assertCompute(List<String> inputArr, List<TextEdit> edits, List<String> expected) {
  final List<String> actual = compute(inputArr, edits);
  assert(actual.length == expected.length);
  for (int i = 0; i < expected.length; i++) {
    assert(actual[i] == expected[i], 'line[$i]: expected "${expected[i]}" got "${actual[i]}"');
  }
}

/// @pure / 1:1: `function compute`
List<String> compute(List<String> inputArr, List<TextEdit> edits) {
  final List<String> newLines = splitLines(applyLineColumnEdits(
    inputArr.join('\n'),
    edits
        .map((TextEdit e) => _VisualEdit(
              text: e.newText,
              range: Range.fromPositions(
                lengthToPosition(e.startOffset),
                end: lengthToPosition(e.endOffset),
              ),
            ))
        .toList(),
  ));

  final BeforeEditPositionMapper mapper = BeforeEditPositionMapper(edits);

  final List<String> result = <String>[];

  int lineIdx = 0;
  for (final String line in newLines) {
    final StringBuffer lineLine = StringBuffer();
    final StringBuffer colLine = StringBuffer();
    final StringBuffer lineStr = StringBuffer();
    final StringBuffer colDist = StringBuffer();
    final StringBuffer lineDist = StringBuffer();

    for (int colIdx = 0; colIdx <= line.length; colIdx++) {
      final Length before = mapper.getOffsetBeforeChange(toLength(lineIdx, colIdx));
      final beforeObj = lengthToObj(before);
      if (colIdx < line.length) {
        lineStr.write(rightPad(line[colIdx], 3));
      }
      lineLine.write(rightPad('' + beforeObj.lineCount.toString(), 3));
      colLine.write(rightPad('' + beforeObj.columnCount.toString(), 3));

      final Length? distLen =
          mapper.getDistanceToNextChange(toLength(lineIdx, colIdx));
      if (distLen == null) {
        lineDist.write('∞  ');
        colDist.write('∞  ');
      } else {
        final dist = lengthToObj(distLen);
        lineDist.write(rightPad('' + dist.lineCount.toString(), 3));
        colDist.write(rightPad('' + dist.columnCount.toString(), 3));
      }
    }
    result.add(lineStr.toString());
    result.add(lineLine.toString());
    result.add(colLine.toString());
    result.add(lineDist.toString());
    result.add(colDist.toString());
    lineIdx++;
  }

  return result;
}

class _VisualEdit {
  final String text;
  final Range range;
  _VisualEdit({required this.text, required this.range});
}

class _PositionOffsetTransformer {
  final List<int> lineStartOffsetByLineIdx = <int>[0];

  _PositionOffsetTransformer(String text) {
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '\n') {
        lineStartOffsetByLineIdx.add(i + 1);
      }
    }
  }

  int getOffset(Position position) =>
      lineStartOffsetByLineIdx[position.lineNumber - 1] + position.column - 1;
}

String applyLineColumnEdits(String text, List<_VisualEdit> edits) {
  final _PositionOffsetTransformer transformer = _PositionOffsetTransformer(text);
  final List<_OffsetEdit> offsetEdits = edits.map((_VisualEdit e) {
    final Range range = Range.lift(e.range)!;
    return _OffsetEdit(
      startOffset: transformer.getOffset(range.getStartPosition()),
      endOffset: transformer.getOffset(range.getEndPosition()),
      text: e.text,
    );
  }).toList();

  offsetEdits.sort((a, b) => b.startOffset - a.startOffset);

  for (final _OffsetEdit edit in offsetEdits) {
    text = text.substring(0, edit.startOffset) +
        edit.text +
        text.substring(edit.endOffset);
  }
  return text;
}

class _OffsetEdit {
  final int startOffset;
  final int endOffset;
  final String text;
  _OffsetEdit({required this.startOffset, required this.endOffset, required this.text});
}

String rightPad(String str, int len) {
  while (str.length < len) {
    str += ' ';
  }
  return str;
}

void runAll() {
  testSingleLine1();
  testSingleLine2();
  testMultiLineReplace1();
  testMultiLineReplace2();
  testMultiLineReplace3();
  testMultiLineInsert1();
  testMultiLineInsert2();
  testMultiLineReplaceInsert1();
  testMultiLineReplaceInsert2();
}
