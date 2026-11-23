// 1:1 translation of vscode/src/vs/base/browser/ui/list/rangeMap.ts

import '../../../common/range.dart' show IRange, IRangedGroup, Range;

/// 1:1: `interface IItem`
class IItem {
  num size;
  IItem(this.size);
}

// IRangedGroup is from base/common/range.dart (same shape: { range, size }).

/// Returns the intersection between a ranged group and a range.
/// Returns `[]` if the intersection is empty.
/// 1:1: `groupIntersect(range, groups)`
List<IRangedGroup> groupIntersect(IRange range, List<IRangedGroup> groups) {
  final List<IRangedGroup> result = <IRangedGroup>[];

  for (final IRangedGroup r in groups) {
    if (range.start >= r.range.end) {
      continue;
    }

    if (range.end < r.range.start) {
      break;
    }

    final IRange intersection = Range.intersect(range, r.range);

    if (Range.isEmpty(intersection)) {
      continue;
    }

    result.add(IRangedGroup(intersection, r.size));
  }

  return result;
}

/// Shifts a range by that `much`.
/// 1:1: `shift({ start, end }, much)`
IRange shift(IRange range, num much) =>
    IRange(range.start + much, range.end + much);

/// Consolidates a collection of ranged groups.
/// 1:1: `consolidate(groups)`
List<IRangedGroup> consolidate(List<IRangedGroup> groups) {
  final List<IRangedGroup> result = <IRangedGroup>[];
  IRangedGroup? previousGroup;

  for (final IRangedGroup group in groups) {
    final num start = group.range.start;
    final num end = group.range.end;
    final num size = group.size;

    if (previousGroup != null && size == previousGroup.size) {
      previousGroup.range.end = end;
      continue;
    }

    previousGroup = IRangedGroup(IRange(start, end), size);
    result.add(previousGroup);
  }

  return result;
}

/// Concatenates several collections of ranged groups into a single collection.
/// 1:1: `concat(...groups)`
List<IRangedGroup> concat(List<List<IRangedGroup>> groups) {
  final List<IRangedGroup> flat = <IRangedGroup>[];
  for (final List<IRangedGroup> g in groups) {
    flat.addAll(g);
  }
  return consolidate(flat);
}

/// 1:1: `interface IRangeMap`
abstract class IRangeMap {
  num get size;
  int get count;
  num get paddingTop;
  set paddingTop(num value);
  void splice(int index, int deleteCount, [List<IItem> items = const <IItem>[]]);
  int indexAt(num position);
  int indexAfter(num position);
  num positionAt(int index);
}

/// 1:1: `class RangeMap implements IRangeMap`
class RangeMap implements IRangeMap {
  List<IRangedGroup> groups = <IRangedGroup>[];
  num _size = 0;
  num _paddingTop = 0;

  @override
  num get paddingTop => _paddingTop;

  @override
  set paddingTop(num paddingTop) {
    _size = _size + paddingTop - _paddingTop;
    _paddingTop = paddingTop;
  }

  /// 1:1: `constructor(topPadding?)`
  RangeMap([num? topPadding]) {
    _paddingTop = topPadding ?? 0;
    _size = _paddingTop;
  }

  @override
  void splice(int index, int deleteCount, [List<IItem> items = const <IItem>[]]) {
    final int diff = items.length - deleteCount;
    final List<IRangedGroup> before =
        groupIntersect(IRange(0, index), groups);
    final List<IRangedGroup> after = groupIntersect(
            IRange(index + deleteCount, double.infinity), groups)
        .map<IRangedGroup>((IRangedGroup g) => IRangedGroup(shift(g.range, diff), g.size))
        .toList();

    final List<IRangedGroup> middle = <IRangedGroup>[];
    for (int i = 0; i < items.length; i++) {
      middle.add(IRangedGroup(IRange(index + i, index + i + 1), items[i].size));
    }

    groups = concat(<List<IRangedGroup>>[before, middle, after]);
    num sum = 0;
    for (final IRangedGroup g in groups) {
      sum += g.size * (g.range.end - g.range.start);
    }
    _size = _paddingTop + sum;
  }

  /// Returns the number of items in the range map.
  @override
  int get count {
    final int len = groups.length;
    if (len == 0) {
      return 0;
    }
    return groups[len - 1].range.end as int;
  }

  /// Returns the sum of the sizes of all items in the range map.
  @override
  num get size => _size;

  /// Returns the index of the item at the given position.
  @override
  int indexAt(num position) {
    if (position < 0) {
      return -1;
    }

    if (position < _paddingTop) {
      return 0;
    }

    int index = 0;
    num size = _paddingTop;

    for (final IRangedGroup group in groups) {
      final num count = group.range.end - group.range.start;
      final num newSize = size + (count * group.size);

      if (position < newSize) {
        return index + ((position - size) / group.size).floor();
      }

      index += count as int;
      size = newSize;
    }

    return index;
  }

  /// Returns the index of the item right after the item at the given position.
  @override
  int indexAfter(num position) {
    final int v = indexAt(position) + 1;
    return v < count ? v : count;
  }

  /// Returns the start position of the item at the given index.
  @override
  num positionAt(int index) {
    if (index < 0) {
      return -1;
    }

    num position = 0;
    int count = 0;

    for (final IRangedGroup group in groups) {
      final int groupCount = (group.range.end - group.range.start) as int;
      final int newCount = count + groupCount;

      if (index < newCount) {
        return _paddingTop + position + ((index - count) * group.size);
      }

      position += groupCount * group.size;
      count = newCount;
    }

    return -1;
  }
}
