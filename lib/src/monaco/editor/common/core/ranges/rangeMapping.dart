// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/edits/rangeMapping.ts
//   (source: editor/common/core/ranges/rangeMapping.ts)
// Translated 1:1 from TypeScript.
//   - `Position | undefined` / `Range | undefined` -> nullable Dart types.
//   - private constructor of PositionOrRange kept via named private ctor.
// ---------------------------------------------------------------------------

import '../../../../base/common/arraysFind.dart' as arraysFind;
import '../position.dart';
import '../range.dart';
import '../text/textLength.dart';

/// 1:1: `RangeMapping` — a list of mappings of ranges from one document to another.
class RangeMapping {
  final List<SingleRangeMapping> mappings;

  RangeMapping(this.mappings);

  PositionOrRange mapPosition(Position position) {
    final SingleRangeMapping? mapping = arraysFind.findLastMonotonous(
      this.mappings,
      (SingleRangeMapping m) => m.original.getStartPosition().isBeforeOrEqual(position),
    );
    if (mapping == null) {
      return PositionOrRange.positionStatic(position);
    }
    if (mapping.original.containsPosition(position)) {
      return PositionOrRange.rangeStatic(mapping.modified);
    }
    final TextLength l = TextLength.betweenPositions(mapping.original.getEndPosition(), position);
    return PositionOrRange.positionStatic(l.addToPosition(mapping.modified.getEndPosition()));
  }

  Range mapRange(Range range) {
    final PositionOrRange start = this.mapPosition(range.getStartPosition());
    final PositionOrRange end = this.mapPosition(range.getEndPosition());
    return Range.fromPositions(
      start.range?.getStartPosition() ?? start.position!,
      end: end.range?.getEndPosition() ?? end.position!,
    );
  }

  RangeMapping reverse() => RangeMapping(this.mappings.map((SingleRangeMapping mapping) => mapping.reverse()).toList());
}

/// 1:1: `SingleRangeMapping`
class SingleRangeMapping {
  final Range original;
  final Range modified;

  SingleRangeMapping(this.original, this.modified);

  SingleRangeMapping reverse() => SingleRangeMapping(this.modified, this.original);

  @override
  String toString() => '${this.original.toString()} -> ${this.modified.toString()}';
}

/// 1:1: `PositionOrRange` (a tagged union of exactly one of [position]/[range]).
class PositionOrRange {
  final Position? position;
  final Range? range;

  PositionOrRange._(this.position, this.range);

  /// 1:1: static `position` (renamed to avoid clash with the instance field).
  static PositionOrRange positionStatic(Position position) => PositionOrRange._(position, null);

  /// 1:1: static `range` (renamed to avoid clash with the instance field).
  static PositionOrRange rangeStatic(Range range) => PositionOrRange._(null, range);
}
