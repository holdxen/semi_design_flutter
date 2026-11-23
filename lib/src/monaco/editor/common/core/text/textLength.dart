// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/textLength.ts (core/text/textLength.ts)
// Translated 1:1 from TypeScript.
//   - `for (const c of text)` iterates Unicode code points; each `c.length`
//     counts UTF-16 code units. Dart `runes` + `String.fromCharCode(r).length`
//     reproduces that exactly (surrogate pairs count as 2).
// ---------------------------------------------------------------------------

import '../position.dart';
import '../range.dart';
import '../ranges/lineRange.dart';
import '../ranges/offsetRange.dart';

/// 1:1: `export class TextLength`
class TextLength {
  static TextLength zero = TextLength(0, 0);

  /// 1:1: `static lengthDiffNonNegative`
  static TextLength lengthDiffNonNegative(TextLength start, TextLength end) {
    if (end.isLessThan(start)) {
      return zero;
    }
    if (start.lineCount == end.lineCount) {
      return TextLength(0, end.columnCount - start.columnCount);
    } else {
      return TextLength(end.lineCount - start.lineCount, end.columnCount);
    }
  }

  /// 1:1: `static betweenPositions`
  static TextLength betweenPositions(Position position1, Position position2) {
    if (position1.lineNumber == position2.lineNumber) {
      return TextLength(0, position2.column - position1.column);
    } else {
      return TextLength(
          position2.lineNumber - position1.lineNumber, position2.column - 1);
    }
  }

  /// 1:1: `static fromPosition`
  static TextLength fromPosition(Position pos) =>
      TextLength(pos.lineNumber - 1, pos.column - 1);

  /// 1:1: `static ofRange`
  static TextLength ofRange(Range range) => betweenPositions(
      range.getStartPosition(), range.getEndPosition());

  /// 1:1: `static ofText`
  static TextLength ofText(String text) {
    int line = 0;
    int column = 0;
    for (final int rune in text.runes) {
      final String c = String.fromCharCode(rune);
      if (c == '\n') {
        line++;
        column = 0;
      } else {
        column += c.length; // UTF-16 code units (surrogate pair -> 2)
      }
    }
    return TextLength(line, column);
  }

  /// 1:1: `static ofSubstr`
  static TextLength ofSubstr(String str, OffsetRange range) =>
      ofText(range.substring(str));

  /// 1:1: `static sum<T>`
  static TextLength sum<T>(
          List<T> fragments, TextLength Function(T) getLength) =>
      fragments.fold<TextLength>(
          zero, (TextLength acc, T f) => acc.add(getLength(f)));

  final int lineCount;
  final int columnCount;

  TextLength(this.lineCount, this.columnCount);

  /// 1:1: `isZero()`
  bool isZero() => lineCount == 0 && columnCount == 0;

  /// 1:1: `isLessThan`
  bool isLessThan(TextLength other) {
    if (lineCount != other.lineCount) {
      return lineCount < other.lineCount;
    }
    return columnCount < other.columnCount;
  }

  /// 1:1: `isGreaterThan`
  bool isGreaterThan(TextLength other) {
    if (lineCount != other.lineCount) {
      return lineCount > other.lineCount;
    }
    return columnCount > other.columnCount;
  }

  /// 1:1: `isGreaterThanOrEqualTo`
  bool isGreaterThanOrEqualTo(TextLength other) {
    if (lineCount != other.lineCount) {
      return lineCount > other.lineCount;
    }
    return columnCount >= other.columnCount;
  }

  /// 1:1: `equals`
  bool equals(TextLength other) =>
      lineCount == other.lineCount && columnCount == other.columnCount;

  /// 1:1: `compare`
  int compare(TextLength other) {
    if (lineCount != other.lineCount) {
      return lineCount - other.lineCount;
    }
    return columnCount - other.columnCount;
  }

  /// 1:1: `add`
  TextLength add(TextLength other) {
    if (other.lineCount == 0) {
      return TextLength(lineCount, columnCount + other.columnCount);
    } else {
      return TextLength(lineCount + other.lineCount, other.columnCount);
    }
  }

  /// 1:1: `createRange`
  Range createRange(Position startPosition) {
    if (lineCount == 0) {
      return Range(startPosition.lineNumber, startPosition.column,
          startPosition.lineNumber, startPosition.column + columnCount);
    } else {
      return Range(startPosition.lineNumber, startPosition.column,
          startPosition.lineNumber + lineCount, columnCount + 1);
    }
  }

  /// 1:1: `toRange`
  Range toRange() => Range(1, 1, lineCount + 1, columnCount + 1);

  /// 1:1: `toLineRange`
  LineRange toLineRange() => LineRange.ofLength(1, lineCount + 1);

  /// 1:1: `addToPosition`
  Position addToPosition(Position position) {
    if (lineCount == 0) {
      return Position(position.lineNumber, position.column + columnCount);
    } else {
      return Position(position.lineNumber + lineCount, columnCount + 1);
    }
  }

  /// 1:1: `addToRange`
  Range addToRange(Range range) => Range.fromPositions(
      addToPosition(range.getStartPosition()),
      end: addToPosition(range.getEndPosition()));

  @override
  String toString() => '$lineCount,$columnCount';
}
