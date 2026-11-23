// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/range.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Syntax adapted to Dart: TS allows a static and
// an instance member to share a name, Dart does not, so static overloads are
// suffixed `Static` (source name noted on each). Structure/members/semantics kept.
// ---------------------------------------------------------------------------

import './position.dart';

/// A range in the editor. This interface is suitable for serialization.
abstract class IRange {
  /// Line number on which the range starts (starts at 1).
  int get startLineNumber;

  /// Column on which the range starts in line `startLineNumber` (starts at 1).
  int get startColumn;

  /// Line number on which the range ends.
  int get endLineNumber;

  /// Column on which the range ends in line `endLineNumber`.
  int get endColumn;
}

/// A range in the editor. (startLineNumber,startColumn) <= (endLineNumber,endColumn)
class Range implements IRange {
  /// Line number on which the range starts (starts at 1).
  /// Line number on which the range starts (starts at 1).
  @override
  late final int startLineNumber;

  /// Column on which the range starts in line `startLineNumber` (starts at 1).
  @override
  late final int startColumn;

  /// Line number on which the range ends.
  @override
  late final int endLineNumber;

  /// Column on which the range ends in line `endLineNumber`.
  @override
  late final int endColumn;

  Range(int startLineNumber, int startColumn, int endLineNumber, int endColumn) {
    if ((startLineNumber > endLineNumber) ||
        (startLineNumber == endLineNumber && startColumn > endColumn)) {
      this.startLineNumber = endLineNumber;
      this.startColumn = endColumn;
      this.endLineNumber = startLineNumber;
      this.endColumn = startColumn;
    } else {
      this.startLineNumber = startLineNumber;
      this.startColumn = startColumn;
      this.endLineNumber = endLineNumber;
      this.endColumn = endColumn;
    }
  }

  /// Test if this range is empty.
  bool isEmpty() => Range.isEmptyStatic(this);

  /// Test if `range` is empty. (source: static isEmpty)
  static bool isEmptyStatic(IRange range) =>
      range.startLineNumber == range.endLineNumber && range.startColumn == range.endColumn;

  /// Test if position is in this range. If the position is at the edges, will return true.
  bool containsPosition(IPosition position) => Range.containsPositionStatic(this, position);

  /// Test if `position` is in `range`. If the position is at the edges, will return true. (source: static containsPosition)
  static bool containsPositionStatic(IRange range, IPosition position) {
    if (position.lineNumber < range.startLineNumber || position.lineNumber > range.endLineNumber) {
      return false;
    }
    if (position.lineNumber == range.startLineNumber && position.column < range.startColumn) {
      return false;
    }
    if (position.lineNumber == range.endLineNumber && position.column > range.endColumn) {
      return false;
    }
    return true;
  }

  /// Test if `position` is in `range`. If the position is at the edges, will return false. @internal (source: static strictContainsPosition)
  static bool strictContainsPositionStatic(IRange range, IPosition position) {
    if (position.lineNumber < range.startLineNumber || position.lineNumber > range.endLineNumber) {
      return false;
    }
    if (position.lineNumber == range.startLineNumber && position.column <= range.startColumn) {
      return false;
    }
    if (position.lineNumber == range.endLineNumber && position.column >= range.endColumn) {
      return false;
    }
    return true;
  }

  /// Test if range is in this range. If the range is equal to this range, will return true.
  bool containsRange(IRange range) => Range.containsRangeStatic(this, range);

  /// Test if `otherRange` is in `range`. If the ranges are equal, will return true. (source: static containsRange)
  static bool containsRangeStatic(IRange range, IRange otherRange) {
    if (otherRange.startLineNumber < range.startLineNumber || otherRange.endLineNumber < range.startLineNumber) {
      return false;
    }
    if (otherRange.startLineNumber > range.endLineNumber || otherRange.endLineNumber > range.endLineNumber) {
      return false;
    }
    if (otherRange.startLineNumber == range.startLineNumber && otherRange.startColumn < range.startColumn) {
      return false;
    }
    if (otherRange.endLineNumber == range.endLineNumber && otherRange.endColumn > range.endColumn) {
      return false;
    }
    return true;
  }

  /// Test if `range` is strictly in this range. (source method delegates to static)
  bool strictContainsRange(IRange range) => Range.strictContainsRangeStatic(this, range);

  /// Test if `otherRange` is strictly in `range` (must start after, and end before). (source: static strictContainsRange)
  static bool strictContainsRangeStatic(IRange range, IRange otherRange) {
    if (otherRange.startLineNumber < range.startLineNumber || otherRange.endLineNumber < range.startLineNumber) {
      return false;
    }
    if (otherRange.startLineNumber > range.endLineNumber || otherRange.endLineNumber > range.endLineNumber) {
      return false;
    }
    if (otherRange.startLineNumber == range.startLineNumber && otherRange.startColumn <= range.startColumn) {
      return false;
    }
    if (otherRange.endLineNumber == range.endLineNumber && otherRange.endColumn >= range.endColumn) {
      return false;
    }
    return true;
  }

  /// A reunion of the two ranges.
  Range plusRange(IRange range) => Range.plusRangeStatic(this, range);

  /// A reunion of the two ranges. (source: static plusRange)
  static Range plusRangeStatic(IRange a, IRange b) {
    late final int startLineNumber;
    late final int startColumn;
    late final int endLineNumber;
    late final int endColumn;

    if (b.startLineNumber < a.startLineNumber) {
      startLineNumber = b.startLineNumber;
      startColumn = b.startColumn;
    } else if (b.startLineNumber == a.startLineNumber) {
      startLineNumber = b.startLineNumber;
      startColumn = b.startColumn < a.startColumn ? b.startColumn : a.startColumn;
    } else {
      startLineNumber = a.startLineNumber;
      startColumn = a.startColumn;
    }

    if (b.endLineNumber > a.endLineNumber) {
      endLineNumber = b.endLineNumber;
      endColumn = b.endColumn;
    } else if (b.endLineNumber == a.endLineNumber) {
      endLineNumber = b.endLineNumber;
      endColumn = b.endColumn > a.endColumn ? b.endColumn : a.endColumn;
    } else {
      endLineNumber = a.endLineNumber;
      endColumn = a.endColumn;
    }

    return Range(startLineNumber, startColumn, endLineNumber, endColumn);
  }

  /// A intersection of the two ranges.
  Range? intersectRanges(IRange range) => Range.intersectRangesStatic(this, range);

  /// A intersection of the two ranges. (source: static intersectRanges)
  static Range? intersectRangesStatic(IRange a, IRange b) {
    int resultStartLineNumber = a.startLineNumber;
    int resultStartColumn = a.startColumn;
    int resultEndLineNumber = a.endLineNumber;
    int resultEndColumn = a.endColumn;
    final int otherStartLineNumber = b.startLineNumber;
    final int otherStartColumn = b.startColumn;
    final int otherEndLineNumber = b.endLineNumber;
    final int otherEndColumn = b.endColumn;

    if (resultStartLineNumber < otherStartLineNumber) {
      resultStartLineNumber = otherStartLineNumber;
      resultStartColumn = otherStartColumn;
    } else if (resultStartLineNumber == otherStartLineNumber) {
      resultStartColumn = resultStartColumn > otherStartColumn ? resultStartColumn : otherStartColumn;
    }

    if (resultEndLineNumber > otherEndLineNumber) {
      resultEndLineNumber = otherEndLineNumber;
      resultEndColumn = otherEndColumn;
    } else if (resultEndLineNumber == otherEndLineNumber) {
      resultEndColumn = resultEndColumn < otherEndColumn ? resultEndColumn : otherEndColumn;
    }

    // Check if selection is now empty
    if (resultStartLineNumber > resultEndLineNumber) {
      return null;
    }
    if (resultStartLineNumber == resultEndLineNumber && resultStartColumn > resultEndColumn) {
      return null;
    }
    return Range(resultStartLineNumber, resultStartColumn, resultEndLineNumber, resultEndColumn);
  }

  /// Test if this range equals other.
  bool equalsRange(IRange? other) => Range.equalsRangeStatic(this, other);

  /// Test if range `a` equals `b`. (source: static equalsRange)
  static bool equalsRangeStatic(IRange? a, IRange? b) {
    if (a == null && b == null) {
      return true;
    }
    return a != null &&
        b != null &&
        a.startLineNumber == b.startLineNumber &&
        a.startColumn == b.startColumn &&
        a.endLineNumber == b.endLineNumber &&
        a.endColumn == b.endColumn;
  }

  /// Return the end position (which will be after or equal to the start position)
  Position getEndPosition() => Range.getEndPositionStatic(this);

  /// Return the end position (which will be after or equal to the start position) (source: static getEndPosition)
  static Position getEndPositionStatic(IRange range) => Position(range.endLineNumber, range.endColumn);

  /// Return the start position (which will be before or equal to the end position)
  Position getStartPosition() => Range.getStartPositionStatic(this);

  /// Return the start position (which will be before or equal to the end position) (source: static getStartPosition)
  static Position getStartPositionStatic(IRange range) => Position(range.startLineNumber, range.startColumn);

  /// Transform to a user presentable string representation.
  @override
  String toString() => '[' + this.startLineNumber.toString() + ',' + this.startColumn.toString() +
      ' -> ' + this.endLineNumber.toString() + ',' + this.endColumn.toString() + ']';

  /// Create a new range using this range's start position, and using endLineNumber and endColumn as the end position.
  Range setEndPosition(int endLineNumber, int endColumn) =>
      Range(this.startLineNumber, this.startColumn, endLineNumber, endColumn);

  /// Create a new range using this range's end position, and using startLineNumber and startColumn as the start position.
  Range setStartPosition(int startLineNumber, int startColumn) =>
      Range(startLineNumber, startColumn, this.endLineNumber, this.endColumn);

  /// Create a new empty range using this range's start position.
  Range collapseToStart() => Range.collapseToStartStatic(this);

  /// Create a new empty range using this range's start position. (source: static collapseToStart)
  static Range collapseToStartStatic(IRange range) =>
      Range(range.startLineNumber, range.startColumn, range.startLineNumber, range.startColumn);

  /// Create a new empty range using this range's end position.
  Range collapseToEnd() => Range.collapseToEndStatic(this);

  /// Create a new empty range using this range's end position. (source: static collapseToEnd)
  static Range collapseToEndStatic(IRange range) =>
      Range(range.endLineNumber, range.endColumn, range.endLineNumber, range.endColumn);

  /// Moves the range by the given amount of lines.
  Range delta(int lineCount) =>
      Range(this.startLineNumber + lineCount, this.startColumn, this.endLineNumber + lineCount, this.endColumn);

  /// Test if this range starts and ends on the same line.
  bool isSingleLine() => this.startLineNumber == this.endLineNumber;

  // ---

  /// TS signature: `fromPositions(start, end = start)`. [end] is named optional.
  static Range fromPositions(IPosition start, {IPosition? end}) {
    final IPosition e = end ?? start;
    return Range(start.lineNumber, start.column, e.lineNumber, e.column);
  }

  /// Create a `Range` from an `IRange`.
  static Range? lift(IRange? range) {
    if (range == null) {
      return null;
    }
    return Range(range.startLineNumber, range.startColumn, range.endLineNumber, range.endColumn);
  }

  /// Test if `obj` is an `IRange`.
  static bool isIRange(Object? obj) {
    if (obj == null) {
      return false;
    }
    if (obj is IRange) {
      return true;
    }
    if (obj is Map) {
      return obj['startLineNumber'] is num &&
          obj['startColumn'] is num &&
          obj['endLineNumber'] is num &&
          obj['endColumn'] is num;
    }
    return false;
  }

  /// Test if the two ranges are touching in any way.
  static bool areIntersectingOrTouching(IRange a, IRange b) {
    // Check if `a` is before `b`
    if (a.endLineNumber < b.startLineNumber ||
        (a.endLineNumber == b.startLineNumber && a.endColumn < b.startColumn)) {
      return false;
    }
    // Check if `b` is before `a`
    if (b.endLineNumber < a.startLineNumber ||
        (b.endLineNumber == a.startLineNumber && b.endColumn < a.startColumn)) {
      return false;
    }
    // These ranges must intersect
    return true;
  }

  /// Test if the two ranges are intersecting. If the ranges are touching it returns true.
  static bool areIntersecting(IRange a, IRange b) {
    // Check if `a` is before `b`
    if (a.endLineNumber < b.startLineNumber ||
        (a.endLineNumber == b.startLineNumber && a.endColumn <= b.startColumn)) {
      return false;
    }
    // Check if `b` is before `a`
    if (b.endLineNumber < a.startLineNumber ||
        (b.endLineNumber == a.startLineNumber && b.endColumn <= a.startColumn)) {
      return false;
    }
    // These ranges must intersect
    return true;
  }

  /// Test if the two ranges are intersecting, but not touching at all.
  static bool areOnlyIntersecting(IRange a, IRange b) {
    // Check if `a` is before `b`
    if (a.endLineNumber < (b.startLineNumber - 1) ||
        (a.endLineNumber == b.startLineNumber && a.endColumn < (b.startColumn - 1))) {
      return false;
    }
    // Check if `b` is before `a`
    if (b.endLineNumber < (a.startLineNumber - 1) ||
        (b.endLineNumber == a.startLineNumber && b.endColumn < (a.startColumn - 1))) {
      return false;
    }
    // These ranges must intersect
    return true;
  }

  /// A function that compares ranges, useful for sorting ranges
  /// It will first compare ranges on the startPosition and then on the endPosition.
  /// TS uses `| 0` to coerce to int; fields are already [int].
  static int compareRangesUsingStarts(IRange? a, IRange? b) {
    if (a != null && b != null) {
      final int aStartLineNumber = a.startLineNumber | 0;
      final int bStartLineNumber = b.startLineNumber | 0;

      if (aStartLineNumber == bStartLineNumber) {
        final int aStartColumn = a.startColumn | 0;
        final int bStartColumn = b.startColumn | 0;

        if (aStartColumn == bStartColumn) {
          final int aEndLineNumber = a.endLineNumber | 0;
          final int bEndLineNumber = b.endLineNumber | 0;

          if (aEndLineNumber == bEndLineNumber) {
            final int aEndColumn = a.endColumn | 0;
            final int bEndColumn = b.endColumn | 0;
            return aEndColumn - bEndColumn;
          }
          return aEndLineNumber - bEndLineNumber;
        }
        return aStartColumn - bStartColumn;
      }
      return aStartLineNumber - bStartLineNumber;
    }
    final int aExists = (a != null ? 1 : 0);
    final int bExists = (b != null ? 1 : 0);
    return aExists - bExists;
  }

  /// A function that compares ranges, useful for sorting ranges
  /// It will first compare ranges on the endPosition and then on the startPosition.
  static int compareRangesUsingEnds(IRange a, IRange b) {
    if (a.endLineNumber == b.endLineNumber) {
      if (a.endColumn == b.endColumn) {
        if (a.startLineNumber == b.startLineNumber) {
          return a.startColumn - b.startColumn;
        }
        return a.startLineNumber - b.startLineNumber;
      }
      return a.endColumn - b.endColumn;
    }
    return a.endLineNumber - b.endLineNumber;
  }

  /// Test if the range spans multiple lines.
  static bool spansMultipleLines(IRange range) => range.endLineNumber > range.startLineNumber;

  IRange toJSON() => this;
}
