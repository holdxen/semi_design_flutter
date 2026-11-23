// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/range.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `namespace Range` -> class + static const;
// object literals `{ start, end }` -> `IRange` value class (call sites keep the
// same shape).
// ---------------------------------------------------------------------------

import 'dart:math' as math;

class IRange {
  num start;
  num end;

  IRange(this.start, this.end);
}

class IRangedGroup {
  IRange range;
  num size;

  IRangedGroup(this.range, this.size);
}

class Range {
  /// Returns the intersection between two ranges as a range itself.
  /// Returns `IRange(0, 0)` if the intersection is empty.
  static IRange intersect(IRange one, IRange other) {
    if (one.start >= other.end || other.start >= one.end) {
      return IRange(0, 0);
    }

    final num start = math.max(one.start, other.start);
    final num end = math.min(one.end, other.end);

    if (end - start <= 0) {
      return IRange(0, 0);
    }

    return IRange(start, end);
  }

  static bool isEmpty(IRange range) {
    return range.end - range.start <= 0;
  }

  static bool intersects(IRange one, IRange other) {
    return !isEmpty(intersect(one, other));
  }

  static List<IRange> relativeComplement(IRange one, IRange other) {
    final List<IRange> result = <IRange>[];
    final IRange first = IRange(one.start, math.min(other.start, one.end));
    final IRange second = IRange(math.max(other.end, one.start), one.end);

    if (!isEmpty(first)) {
      result.add(first);
    }

    if (!isEmpty(second)) {
      result.add(second);
    }

    return result;
  }
}
