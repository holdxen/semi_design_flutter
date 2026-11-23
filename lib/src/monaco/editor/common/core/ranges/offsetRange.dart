// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/ranges/offsetRange.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Static `equals` suffixed `Static` (Dart forbids
// static/instance name collision); JS `Array.splice` mapped to Dart
// `replaceRange`/`insert`. Structure/members/semantics preserved.
// ---------------------------------------------------------------------------

import '../../../../base/common/errors.dart';

abstract class IOffsetRange {
  int get start;
  int get endExclusive;
}

/// A range of offsets (0-based).
class OffsetRange implements IOffsetRange {
  static OffsetRange fromTo(int start, int endExclusive) => OffsetRange(start, endExclusive);

  /// Test if `r1` equals `r2`. (source: static equals)
  static bool equalsStatic(IOffsetRange r1, IOffsetRange r2) =>
      r1.start == r2.start && r1.endExclusive == r2.endExclusive;

  static void addRange(OffsetRange range, List<OffsetRange> sortedRanges) {
    int i = 0;
    while (i < sortedRanges.length && sortedRanges[i].endExclusive < range.start) {
      i++;
    }
    int j = i;
    while (j < sortedRanges.length && sortedRanges[j].start <= range.endExclusive) {
      j++;
    }
    if (i == j) {
      sortedRanges.insert(i, range);
    } else {
      final int start = range.start < sortedRanges[i].start ? range.start : sortedRanges[i].start;
      final int end = range.endExclusive > sortedRanges[j - 1].endExclusive
          ? range.endExclusive
          : sortedRanges[j - 1].endExclusive;
      sortedRanges.replaceRange(i, j, <OffsetRange>[OffsetRange(start, end)]);
    }
  }

  static OffsetRange? tryCreate(int start, int endExclusive) {
    if (start > endExclusive) {
      return null;
    }
    return OffsetRange(start, endExclusive);
  }

  static OffsetRange ofLength(int length) => OffsetRange(0, length);

  static OffsetRange ofStartAndLength(int start, int length) => OffsetRange(start, start + length);

  static OffsetRange emptyAt(int offset) => OffsetRange(offset, offset);

  @override
  final int start;

  @override
  final int endExclusive;

  OffsetRange(int start, int endExclusive)
      : start = start,
        endExclusive = endExclusive {
    if (start > endExclusive) {
      throw BugIndicatingError('Invalid range: ' + this.toString());
    }
  }

  bool get isEmpty => this.start == this.endExclusive;

  OffsetRange delta(int offset) => OffsetRange(this.start + offset, this.endExclusive + offset);

  OffsetRange deltaStart(int offset) => OffsetRange(this.start + offset, this.endExclusive);

  OffsetRange deltaEnd(int offset) => OffsetRange(this.start, this.endExclusive + offset);

  int get length => this.endExclusive - this.start;

  @override
  String toString() => '[' + this.start.toString() + ', ' + this.endExclusive.toString() + ')';

  bool equals(OffsetRange other) => this.start == other.start && this.endExclusive == other.endExclusive;

  bool containsRange(OffsetRange other) =>
      this.start <= other.start && other.endExclusive <= this.endExclusive;

  bool contains(int offset) => this.start <= offset && offset < this.endExclusive;

  /// for all numbers n: range1.contains(n) or range2.contains(n) => range1.join(range2).contains(n)
  /// The joined range is the smallest range that contains both ranges.
  OffsetRange join(OffsetRange other) => OffsetRange(
        this.start < other.start ? this.start : other.start,
        this.endExclusive > other.endExclusive ? this.endExclusive : other.endExclusive,
      );

  /// for all numbers n: range1.contains(n) and range2.contains(n) <=> range1.intersect(range2).contains(n)
  /// The resulting range is empty if the ranges do not intersect, but touch.
  /// If the ranges don't even touch, the result is undefined.
  OffsetRange? intersect(OffsetRange other) {
    final int start = this.start > other.start ? this.start : other.start;
    final int end = this.endExclusive < other.endExclusive ? this.endExclusive : other.endExclusive;
    if (start <= end) {
      return OffsetRange(start, end);
    }
    return null;
  }

  int intersectionLength(OffsetRange range) {
    final int start = this.start > range.start ? this.start : range.start;
    final int end = this.endExclusive < range.endExclusive ? this.endExclusive : range.endExclusive;
    return (0 > end - start) ? 0 : end - start;
  }

  /// `a.intersects(b)` iff there exists a number n so that a.contains(n) and b.contains(n).
  /// Warning: If one range is empty, this method returns always false.
  bool intersects(OffsetRange other) {
    final int start = this.start > other.start ? this.start : other.start;
    final int end = this.endExclusive < other.endExclusive ? this.endExclusive : other.endExclusive;
    return start < end;
  }

  bool intersectsOrTouches(OffsetRange other) {
    final int start = this.start > other.start ? this.start : other.start;
    final int end = this.endExclusive < other.endExclusive ? this.endExclusive : other.endExclusive;
    return start <= end;
  }

  bool isBefore(OffsetRange other) => this.endExclusive <= other.start;

  bool isAfter(OffsetRange other) => this.start >= other.endExclusive;

  List<T> slice<T>(List<T> arr) => arr.sublist(this.start, this.endExclusive);

  String substring(String str) => str.substring(this.start, this.endExclusive);

  /// Returns the given value if it is contained in this instance, otherwise the closest value that is contained.
  /// The range must not be empty.
  int clip(int value) {
    if (this.isEmpty) {
      throw BugIndicatingError('Invalid clipping range: ' + this.toString());
    }
    final int hi = this.endExclusive - 1;
    return this.start > (hi < value ? hi : value) ? this.start : (hi < value ? hi : value);
  }

  /// Returns `r := value + k * length` such that `r` is contained in this range.
  /// The range must not be empty.
  int clipCyclic(int value) {
    if (this.isEmpty) {
      throw BugIndicatingError('Invalid clipping range: ' + this.toString());
    }
    if (value < this.start) {
      return this.endExclusive - ((this.start - value) % this.length);
    }
    if (value >= this.endExclusive) {
      return this.start + ((value - this.start) % this.length);
    }
    return value;
  }

  List<T> map<T>(T Function(int offset) f) {
    final List<T> result = <T>[];
    for (int i = this.start; i < this.endExclusive; i++) {
      result.add(f(i));
    }
    return result;
  }

  void forEach(void Function(int offset) f) {
    for (int i = this.start; i < this.endExclusive; i++) {
      f(i);
    }
  }

  /// this: [ 5, 10), range: [10, 15) => [5, 15)
  /// Throws if the ranges are not touching.
  OffsetRange joinRightTouching(OffsetRange range) {
    if (this.endExclusive != range.start) {
      throw BugIndicatingError('Invalid join: ' + this.toString() + ' and ' + range.toString());
    }
    return OffsetRange(this.start, range.endExclusive);
  }

  /// TS overloads: withMargin(margin) / withMargin(marginStart, marginEnd).
  /// [marginEnd] is named optional; when omitted it equals [marginStart].
  OffsetRange withMargin(int marginStart, {int? marginEnd}) {
    final int me = marginEnd ?? marginStart;
    return OffsetRange(this.start - marginStart, this.endExclusive + me);
  }
}

class OffsetRangeSet {
  final List<OffsetRange> _sortedRanges = <OffsetRange>[];

  List<OffsetRange> get ranges => List<OffsetRange>.from(this._sortedRanges);

  void addRange(OffsetRange range) {
    int i = 0;
    while (i < this._sortedRanges.length && this._sortedRanges[i].endExclusive < range.start) {
      i++;
    }
    int j = i;
    while (j < this._sortedRanges.length && this._sortedRanges[j].start <= range.endExclusive) {
      j++;
    }
    if (i == j) {
      this._sortedRanges.insert(i, range);
    } else {
      final int start = range.start < this._sortedRanges[i].start
          ? range.start
          : this._sortedRanges[i].start;
      final int end = range.endExclusive > this._sortedRanges[j - 1].endExclusive
          ? range.endExclusive
          : this._sortedRanges[j - 1].endExclusive;
      this._sortedRanges.replaceRange(i, j, <OffsetRange>[OffsetRange(start, end)]);
    }
  }

  @override
  String toString() => this._sortedRanges.map((r) => r.toString()).join(', ');

  /// Returns if there is a value that is contained in this instance and the given range.
  bool intersectsStrict(OffsetRange other) {
    // TODO use binary search
    int i = 0;
    while (i < this._sortedRanges.length && this._sortedRanges[i].endExclusive <= other.start) {
      i++;
    }
    return i < this._sortedRanges.length && this._sortedRanges[i].start < other.endExclusive;
  }

  OffsetRangeSet intersectWithRange(OffsetRange other) {
    // TODO use binary search + slice
    final OffsetRangeSet result = OffsetRangeSet();
    for (final OffsetRange range in this._sortedRanges) {
      final OffsetRange? intersection = range.intersect(other);
      if (intersection != null) {
        result.addRange(intersection);
      }
    }
    return result;
  }

  int intersectWithRangeLength(OffsetRange other) => this.intersectWithRange(other).length;

  int get length => this._sortedRanges.fold<int>(0, (prev, cur) => prev + cur.length);
}
