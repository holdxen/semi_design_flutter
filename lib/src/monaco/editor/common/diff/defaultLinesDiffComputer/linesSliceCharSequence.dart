// 1:1 port of vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/linesSliceCharSequence.ts

import '../../../../base/common/arraysFind.dart'
    show findFirstMonotonous, findLastIdxMonotonous, findLastMonotonous;
import '../../../../base/common/charCode.dart' show CharCode;
import '../../core/position.dart' show Position;
import '../../core/range.dart' show Range;
import '../../core/ranges/offsetRange.dart' show OffsetRange;
import 'algorithms/diffAlgorithm.dart' show ISequence;
import 'utils.dart' show isSpace;

class LinesSliceCharSequence implements ISequence {
  final List<int> _elements = <int>[];
  final List<int> _firstElementOffsetByLineIdx = <int>[];
  final List<int> _lineStartOffsets = <int>[];
  final List<int> _trimmedWsLengthsByLineIdx = <int>[];

  final List<String> lines;
  final Range range;
  final bool considerWhitespaceChanges;

  LinesSliceCharSequence(this.lines, this.range, this.considerWhitespaceChanges) {
    _firstElementOffsetByLineIdx.add(0);
    for (int lineNumber = range.startLineNumber;
        lineNumber <= range.endLineNumber;
        lineNumber++) {
      String line = lines[lineNumber - 1];
      int lineStartOffset = 0;
      if (lineNumber == range.startLineNumber && range.startColumn > 1) {
        lineStartOffset = range.startColumn - 1;
        line = line.substring(lineStartOffset);
      }
      _lineStartOffsets.add(lineStartOffset);

      int trimmedWsLength = 0;
      if (!considerWhitespaceChanges) {
        final String trimmedStartLine = line.trimLeft();
        trimmedWsLength = line.length - trimmedStartLine.length;
        line = trimmedStartLine.trimRight();
      }
      _trimmedWsLengthsByLineIdx.add(trimmedWsLength);

      final int lineLength = lineNumber == range.endLineNumber
          ? mathMin(range.endColumn - 1 - lineStartOffset - trimmedWsLength,
              line.length)
          : line.length;
      for (int i = 0; i < lineLength; i++) {
        _elements.add(line.codeUnitAt(i));
      }

      if (lineNumber < range.endLineNumber) {
        _elements.add(CharCode.LineFeed);
        _firstElementOffsetByLineIdx.add(_elements.length);
      }
    }
  }

  static int mathMin(int a, int b) => a < b ? a : b;

  @override
  String toString() => 'Slice: "$text"';

  String get text => getText(OffsetRange(0, length));

  String getText(OffsetRange range) => String.fromCharCodes(
      _elements.sublist(range.start, range.endExclusive));

  @override
  int getElement(int offset) => _elements[offset];

  @override
  int get length => _elements.length;

  @override
  int getBoundaryScore(int length) {
    final int prevCategory =
        getCategory(length > 0 ? _elements[length - 1] : -1);
    final int nextCategory =
        getCategory(length < _elements.length ? _elements[length] : -1);

    if (prevCategory == CharBoundaryCategory.LineBreakCR &&
        nextCategory == CharBoundaryCategory.LineBreakLF) {
      return 0;
    }
    if (prevCategory == CharBoundaryCategory.LineBreakLF) {
      return 150;
    }

    int score = 0;
    if (prevCategory != nextCategory) {
      score += 10;
      if (prevCategory == CharBoundaryCategory.WordLower &&
          nextCategory == CharBoundaryCategory.WordUpper) {
        score += 1;
      }
    }

    score += getCategoryBoundaryScore(prevCategory);
    score += getCategoryBoundaryScore(nextCategory);
    return score;
  }

  /// 1:1: `translateOffset(offset, preference = 'right')`
  Position translateOffset(int offset, [String preference = 'right']) {
    final int i = findLastIdxMonotonous<int>(
        _firstElementOffsetByLineIdx, (int value) => value <= offset);
    final int lineOffset = offset - _firstElementOffsetByLineIdx[i];
    return Position(
      range.startLineNumber + i,
      1 +
          _lineStartOffsets[i] +
          lineOffset +
          ((lineOffset == 0 && preference == 'left')
              ? 0
              : _trimmedWsLengthsByLineIdx[i]),
    );
  }

  Range translateRange(OffsetRange range) {
    final Position pos1 = translateOffset(range.start, 'right');
    final Position pos2 = translateOffset(range.endExclusive, 'left');
    if (pos2.isBefore(pos1)) {
      return Range.fromPositions(pos2, end: pos2);
    }
    return Range.fromPositions(pos1, end: pos2);
  }

  /// Finds the word that contains the character at the given offset.
  OffsetRange? findWordContaining(int offset) {
    if (offset < 0 || offset >= _elements.length) {
      return null;
    }
    if (!isWordChar(_elements[offset])) {
      return null;
    }

    int start = offset;
    while (start > 0 && isWordChar(_elements[start - 1])) {
      start--;
    }
    int end = offset;
    while (end < _elements.length && isWordChar(_elements[end])) {
      end++;
    }
    return OffsetRange(start, end);
  }

  /// `fooBar` has the two sub-words `foo` and `bar`.
  OffsetRange? findSubWordContaining(int offset) {
    if (offset < 0 || offset >= _elements.length) {
      return null;
    }
    if (!isWordChar(_elements[offset])) {
      return null;
    }

    int start = offset;
    while (start > 0 &&
        isWordChar(_elements[start - 1]) &&
        !isUpperCase(_elements[start])) {
      start--;
    }
    int end = offset;
    while (end < _elements.length &&
        isWordChar(_elements[end]) &&
        !isUpperCase(_elements[end])) {
      end++;
    }
    return OffsetRange(start, end);
  }

  int countLinesIn(OffsetRange range) =>
      translateOffset(range.endExclusive).lineNumber -
      translateOffset(range.start).lineNumber;

  @override
  bool isStronglyEqual(int offset1, int offset2) =>
      _elements[offset1] == _elements[offset2];

  OffsetRange extendToFullLines(OffsetRange range) {
    final int start =
        findLastMonotonous<int>(_firstElementOffsetByLineIdx, (int x) => x <= range.start) ?? 0;
    final int end = findFirstMonotonous<int>(_firstElementOffsetByLineIdx,
            (int x) => range.endExclusive <= x) ??
        _elements.length;
    return OffsetRange(start, end);
  }
}

bool isWordChar(int charCode) =>
    (charCode >= CharCode.a && charCode <= CharCode.z) ||
    (charCode >= CharCode.A && charCode <= CharCode.Z) ||
    (charCode >= CharCode.Digit0 && charCode <= CharCode.Digit9);

bool isUpperCase(int charCode) =>
    charCode >= CharCode.A && charCode <= CharCode.Z;

/// 1:1: `const enum CharBoundaryCategory`
class CharBoundaryCategory {
  static const int WordLower = 0;
  static const int WordUpper = 1;
  static const int WordNumber = 2;
  static const int End = 3;
  static const int Other = 4;
  static const int Separator = 5;
  static const int Space = 6;
  static const int LineBreakCR = 7;
  static const int LineBreakLF = 8;
}

const List<int> _categoryScores = <int>[0, 0, 0, 10, 2, 30, 3, 10, 10];

int getCategoryBoundaryScore(int category) => _categoryScores[category];

int getCategory(int charCode) {
  if (charCode == CharCode.LineFeed) {
    return CharBoundaryCategory.LineBreakLF;
  } else if (charCode == CharCode.CarriageReturn) {
    return CharBoundaryCategory.LineBreakCR;
  } else if (isSpace(charCode)) {
    return CharBoundaryCategory.Space;
  } else if (charCode >= CharCode.a && charCode <= CharCode.z) {
    return CharBoundaryCategory.WordLower;
  } else if (charCode >= CharCode.A && charCode <= CharCode.Z) {
    return CharBoundaryCategory.WordUpper;
  } else if (charCode >= CharCode.Digit0 && charCode <= CharCode.Digit9) {
    return CharBoundaryCategory.WordNumber;
  } else if (charCode == -1) {
    return CharBoundaryCategory.End;
  } else if (charCode == CharCode.Comma || charCode == CharCode.Semicolon) {
    return CharBoundaryCategory.Separator;
  } else {
    return CharBoundaryCategory.Other;
  }
}
