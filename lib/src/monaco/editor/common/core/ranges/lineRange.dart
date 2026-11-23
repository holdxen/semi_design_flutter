// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/ranges/lineRange.ts
// Translated 1:1 from TypeScript.
// Adaptations:
//   - `number` -> `int` (line numbers are integers throughout this file)
//   - tuple `ISerializedLineRange` -> Dart record `(int, int)`
//   - `readonly T[]` -> `List<T>` / `List<T>.unmodifiable` where returned
//   - static/instance name collisions use `Static` suffix only where required
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart' as arrays;
import '../../../../base/common/arraysFind.dart' as arraysFind;
import '../../../../base/common/errors.dart' as errors;
import '../range.dart' as range;
import 'offsetRange.dart' as offsetRange;

/// 1:1: `export type ISerializedLineRange`
typedef ISerializedLineRange = ({int startLineNumber, int endLineNumberExclusive});

/// 1:1: `export class LineRange`
class LineRange {
  static LineRange ofLength(int startLineNumber, int length) =>
      LineRange(startLineNumber, startLineNumber + length);

  static LineRange fromRange(range.IRange r) =>
      LineRange(r.startLineNumber, r.endLineNumber);

  static LineRange fromRangeInclusive(range.IRange r) =>
      LineRange(r.startLineNumber, r.endLineNumber + 1);

  static final arrays.Comparator<LineRange> compareByStart = arrays.compareBy<
      LineRange, int>(
      (LineRange l) => l.startLineNumber, arrays.numberComparator);

  static List<LineRange> subtract(LineRange a, LineRange? b) {
    if (b == null) {
      return <LineRange>[a];
    }
    if (a.startLineNumber < b.startLineNumber &&
        b.endLineNumberExclusive < a.endLineNumberExclusive) {
      return <LineRange>[
        LineRange(a.startLineNumber, b.startLineNumber),
        LineRange(b.endLineNumberExclusive, a.endLineNumberExclusive),
      ];
    } else if (b.startLineNumber <= a.startLineNumber &&
        a.endLineNumberExclusive <= b.endLineNumberExclusive) {
      return <LineRange>[];
    } else if (b.endLineNumberExclusive < a.endLineNumberExclusive) {
      return <LineRange>[
        LineRange(
            b.endLineNumberExclusive > a.startLineNumber
                ? b.endLineNumberExclusive
                : a.startLineNumber,
            a.endLineNumberExclusive),
      ];
    } else {
      return <LineRange>[
        LineRange(
            a.startLineNumber,
            b.startLineNumber < a.endLineNumberExclusive
                ? b.startLineNumber
                : a.endLineNumberExclusive),
      ];
    }
  }

  /// An array of arrays of sorted line ranges.
  static List<LineRange> joinMany(List<List<LineRange>> lineRanges) {
    if (lineRanges.isEmpty) {
      return <LineRange>[];
    }
    LineRangeSet result = LineRangeSet(List<LineRange>.from(lineRanges[0]));
    for (int i = 1; i < lineRanges.length; i++) {
      result = result.getUnion(LineRangeSet(List<LineRange>.from(lineRanges[i])));
    }
    return result.ranges;
  }

  /// Dart: static `join` renamed to avoid collision with instance [join].
  static LineRange joinStatic(List<LineRange> lineRanges) {
    if (lineRanges.isEmpty) {
      throw errors.BugIndicatingError('lineRanges cannot be empty');
    }
    int startLineNumber = lineRanges[0].startLineNumber;
    int endLineNumberExclusive = lineRanges[0].endLineNumberExclusive;
    for (int i = 1; i < lineRanges.length; i++) {
      startLineNumber =
          startLineNumber < lineRanges[i].startLineNumber
              ? startLineNumber
              : lineRanges[i].startLineNumber;
      endLineNumberExclusive =
          endLineNumberExclusive > lineRanges[i].endLineNumberExclusive
              ? endLineNumberExclusive
              : lineRanges[i].endLineNumberExclusive;
    }
    return LineRange(startLineNumber, endLineNumberExclusive);
  }

  static LineRange deserialize(ISerializedLineRange lineRange) => LineRange(
      lineRange.startLineNumber, lineRange.endLineNumberExclusive);

  /// The start line number.
  final int startLineNumber;

  /// The end line number (exclusive).
  final int endLineNumberExclusive;

  LineRange(this.startLineNumber, this.endLineNumberExclusive) {
    if (startLineNumber > endLineNumberExclusive) {
      throw errors.BugIndicatingError(
          'startLineNumber $startLineNumber cannot be after endLineNumberExclusive $endLineNumberExclusive');
    }
  }

  /// Indicates if this line range contains the given line number.
  bool contains(int lineNumber) =>
      startLineNumber <= lineNumber && lineNumber < endLineNumberExclusive;

  bool containsRange(LineRange r) =>
      startLineNumber <= r.startLineNumber &&
      r.endLineNumberExclusive <= endLineNumberExclusive;

  /// Indicates if this line range is empty.
  bool get isEmpty => startLineNumber == endLineNumberExclusive;

  /// Moves this line range by the given offset of line numbers.
  LineRange delta(int offset) =>
      LineRange(startLineNumber + offset, endLineNumberExclusive + offset);

  LineRange deltaLength(int offset) =>
      LineRange(startLineNumber, endLineNumberExclusive + offset);

  /// The number of lines this line range spans.
  int get length => endLineNumberExclusive - startLineNumber;

  /// Creates a line range that combines this and the given line range.
  LineRange join(LineRange other) => LineRange(
      startLineNumber < other.startLineNumber
          ? startLineNumber
          : other.startLineNumber,
      endLineNumberExclusive > other.endLineNumberExclusive
          ? endLineNumberExclusive
          : other.endLineNumberExclusive);

  @override
  String toString() => '[$startLineNumber,$endLineNumberExclusive)';

  /// Result is empty if ranges do not intersect but touch; undefined if they
  /// don't even touch.
  LineRange? intersect(LineRange other) {
    final int s = startLineNumber > other.startLineNumber
        ? startLineNumber
        : other.startLineNumber;
    final int e = endLineNumberExclusive < other.endLineNumberExclusive
        ? endLineNumberExclusive
        : other.endLineNumberExclusive;
    if (s <= e) {
      return LineRange(s, e);
    }
    return null;
  }

  bool intersectsStrict(LineRange other) =>
      startLineNumber < other.endLineNumberExclusive &&
      other.startLineNumber < endLineNumberExclusive;

  bool intersectsOrTouches(LineRange other) =>
      startLineNumber <= other.endLineNumberExclusive &&
      other.startLineNumber <= endLineNumberExclusive;

  bool equals(LineRange b) =>
      startLineNumber == b.startLineNumber &&
      endLineNumberExclusive == b.endLineNumberExclusive;

  range.Range? toInclusiveRange() {
    if (isEmpty) {
      return null;
    }
    return range.Range(startLineNumber, 1, endLineNumberExclusive - 1, 9007199254740991);
  }

  /// @deprecated end position is not guaranteed to be a valid position.
  range.Range toExclusiveRange() =>
      range.Range(startLineNumber, 1, endLineNumberExclusive, 1);

  List<T> mapToLineArray<T>(T Function(int lineNumber) f) {
    final List<T> result = <T>[];
    for (int lineNumber = startLineNumber;
        lineNumber < endLineNumberExclusive;
        lineNumber++) {
      result.add(f(lineNumber));
    }
    return result;
  }

  void forEach(void Function(int lineNumber) f) {
    for (int lineNumber = startLineNumber;
        lineNumber < endLineNumberExclusive;
        lineNumber++) {
      f(lineNumber);
    }
  }

  ISerializedLineRange serialize() =>
      (startLineNumber: startLineNumber, endLineNumberExclusive: endLineNumberExclusive);

  /// Converts this 1-based line range to a 0-based offset range (subtracts 1!).
  offsetRange.OffsetRange toOffsetRange() =>
      offsetRange.OffsetRange(startLineNumber - 1, endLineNumberExclusive - 1);

  int distanceToRange(LineRange other) {
    if (endLineNumberExclusive <= other.startLineNumber) {
      return other.startLineNumber - endLineNumberExclusive;
    }
    if (other.endLineNumberExclusive <= startLineNumber) {
      return startLineNumber - other.endLineNumberExclusive;
    }
    return 0;
  }

  int distanceToLine(int lineNumber) {
    if (contains(lineNumber)) {
      return 0;
    }
    if (lineNumber < startLineNumber) {
      return startLineNumber - lineNumber;
    }
    return lineNumber - endLineNumberExclusive;
  }

  LineRange addMargin(int marginTop, int marginBottom) => LineRange(
      startLineNumber - marginTop, endLineNumberExclusive + marginBottom);
}

/// 1:1: `export class LineRangeSet`
class LineRangeSet {
  /// Sorted by start line number. No two line ranges are touching or
  /// intersecting.
  final List<LineRange> _normalizedRanges;

  LineRangeSet([List<LineRange>? normalizedRanges])
      : _normalizedRanges = normalizedRanges ?? <LineRange>[];

  List<LineRange> get ranges => _normalizedRanges;

  void addRange(LineRange range) {
    if (range.length == 0) {
      return;
    }

    // idx of first element that touches range or that is after range
    final int joinRangeStartIdx = arraysFind.findFirstIdxMonotonousOrArrLen<
        LineRange>(
        _normalizedRanges,
        (LineRange r) => r.endLineNumberExclusive >= range.startLineNumber);
    // idx of element after last element that touches/before range
    final int joinRangeEndIdxExclusive = arraysFind.findLastIdxMonotonous<
            LineRange>(
        _normalizedRanges,
        (LineRange r) => r.startLineNumber <= range.endLineNumberExclusive) +
        1;

    if (joinRangeStartIdx == joinRangeEndIdxExclusive) {
      _normalizedRanges.insert(joinRangeStartIdx, range);
    } else if (joinRangeStartIdx == joinRangeEndIdxExclusive - 1) {
      final LineRange joinRange = _normalizedRanges[joinRangeStartIdx];
      _normalizedRanges[joinRangeStartIdx] = joinRange.join(range);
    } else {
      final LineRange joinRange = _normalizedRanges[joinRangeStartIdx]
          .join(_normalizedRanges[joinRangeEndIdxExclusive - 1])
          .join(range);
      _normalizedRanges.replaceRange(
          joinRangeStartIdx, joinRangeEndIdxExclusive, <LineRange>[joinRange]);
    }
  }

  bool contains(int lineNumber) {
    final LineRange? rangeThatStartsBeforeEnd = arraysFind.findLastMonotonous<
        LineRange>(
        _normalizedRanges, (LineRange r) => r.startLineNumber <= lineNumber);
    return rangeThatStartsBeforeEnd != null &&
        rangeThatStartsBeforeEnd.endLineNumberExclusive > lineNumber;
  }

  bool intersects(LineRange range) {
    final LineRange? rangeThatStartsBeforeEnd = arraysFind.findLastMonotonous<
        LineRange>(
        _normalizedRanges,
        (LineRange r) => r.startLineNumber < range.endLineNumberExclusive);
    return rangeThatStartsBeforeEnd != null &&
        rangeThatStartsBeforeEnd.endLineNumberExclusive > range.startLineNumber;
  }

  LineRangeSet getUnion(LineRangeSet other) {
    if (_normalizedRanges.isEmpty) {
      return other;
    }
    if (other._normalizedRanges.isEmpty) {
      return this;
    }

    final List<LineRange> result = <LineRange>[];
    int i1 = 0;
    int i2 = 0;
    LineRange? current;
    while (i1 < _normalizedRanges.length || i2 < other._normalizedRanges.length) {
      LineRange? next;
      if (i1 < _normalizedRanges.length && i2 < other._normalizedRanges.length) {
        final LineRange lineRange1 = _normalizedRanges[i1];
        final LineRange lineRange2 = other._normalizedRanges[i2];
        if (lineRange1.startLineNumber < lineRange2.startLineNumber) {
          next = lineRange1;
          i1++;
        } else {
          next = lineRange2;
          i2++;
        }
      } else if (i1 < _normalizedRanges.length) {
        next = _normalizedRanges[i1];
        i1++;
      } else {
        next = other._normalizedRanges[i2];
        i2++;
      }

      if (current == null) {
        current = next;
      } else {
        if (current.endLineNumberExclusive >= next.startLineNumber) {
          current = LineRange(
              current.startLineNumber,
              current.endLineNumberExclusive > next.endLineNumberExclusive
                  ? current.endLineNumberExclusive
                  : next.endLineNumberExclusive);
        } else {
          result.add(current);
          current = next;
        }
      }
    }
    if (current != null) {
      result.add(current);
    }
    return LineRangeSet(result);
  }

  /// Subtracts all ranges in this set from `range` and returns the result.
  LineRangeSet subtractFrom(LineRange range) {
    final int joinRangeStartIdx = arraysFind.findFirstIdxMonotonousOrArrLen<
        LineRange>(
        _normalizedRanges,
        (LineRange r) => r.endLineNumberExclusive >= range.startLineNumber);
    final int joinRangeEndIdxExclusive = arraysFind.findLastIdxMonotonous<
            LineRange>(
        _normalizedRanges,
        (LineRange r) => r.startLineNumber <= range.endLineNumberExclusive) +
        1;

    if (joinRangeStartIdx == joinRangeEndIdxExclusive) {
      return LineRangeSet(<LineRange>[range]);
    }

    final List<LineRange> result = <LineRange>[];
    int startLineNumber = range.startLineNumber;
    for (int i = joinRangeStartIdx; i < joinRangeEndIdxExclusive; i++) {
      final LineRange r = _normalizedRanges[i];
      if (r.startLineNumber > startLineNumber) {
        result.add(LineRange(startLineNumber, r.startLineNumber));
      }
      startLineNumber = r.endLineNumberExclusive;
    }
    if (startLineNumber < range.endLineNumberExclusive) {
      result.add(LineRange(startLineNumber, range.endLineNumberExclusive));
    }

    return LineRangeSet(result);
  }

  @override
  String toString() =>
      _normalizedRanges.map((LineRange r) => r.toString()).join(', ');

  LineRangeSet getIntersection(LineRangeSet other) {
    final List<LineRange> result = <LineRange>[];

    int i1 = 0;
    int i2 = 0;
    while (i1 < _normalizedRanges.length && i2 < other._normalizedRanges.length) {
      final LineRange r1 = _normalizedRanges[i1];
      final LineRange r2 = other._normalizedRanges[i2];

      final LineRange? i = r1.intersect(r2);
      if (i != null && !i.isEmpty) {
        result.add(i);
      }

      if (r1.endLineNumberExclusive < r2.endLineNumberExclusive) {
        i1++;
      } else {
        i2++;
      }
    }

    return LineRangeSet(result);
  }

  LineRangeSet getWithDelta(int value) =>
      LineRangeSet(_normalizedRanges.map((LineRange r) => r.delta(value)).toList());
}
