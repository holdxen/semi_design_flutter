// Port of `CompactSelection` (`packages/core/src/internal/data-grid/
// data-grid-types.ts:560-724`).
//
// The structure is an immutable list of half-open slices `[start, end)`.
// Operations always return a new instance; the constructor is private upstream
// and `empty()` is memoized — Dart's `const` gives us the same singleton for
// free.
import 'package:flutter/foundation.dart';

/// `Slice = [start, end]` (`data-grid-types.ts:524`).
@immutable
class SemiSlice {
  const SemiSlice(this.start, this.end) : assert(start <= end);

  final int start;
  final int end;

  int get length => end - start;

  @override
  bool operator ==(Object other) =>
      other is SemiSlice && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '[$start, $end)';
}

/// `CompactSelectionRanges` (`data-grid-types.ts:526`).
typedef SemiCompactSelectionRanges = List<SemiSlice>;

/// `mergeRanges` (`data-grid-types.ts:560-585`).
///
/// Sorts by start, then folds overlapping *and adjacent* slices into one
/// (upstream compares with `<`, not `<=`, so `[0,1)` and `[1,2)` collapse).
List<SemiSlice> _mergeRanges(List<SemiSlice> input) {
  if (input.isEmpty) return const [];
  final ranges = [...input]
    ..sort((a, b) => a.start.compareTo(b.start));

  final stack = <List<int>>[
    [ranges.first.start, ranges.first.end],
  ];

  for (final range in ranges.skip(1)) {
    final top = stack.last;
    if (top[1] < range.start) {
      stack.add([range.start, range.end]);
    } else if (top[1] < range.end) {
      top[1] = range.end;
    }
  }

  return [for (final s in stack) SemiSlice(s[0], s[1])];
}

/// `CompactSelection` (`data-grid-types.ts:590-724`).
@immutable
class SemiCompactSelection {
  const SemiCompactSelection._(this.items);

  /// `CompactSelection.empty()` (`:597-599`).
  const SemiCompactSelection.empty() : items = const [];

  /// `CompactSelection.create` (`:593-595`).
  factory SemiCompactSelection.create(List<SemiSlice> items) =>
      SemiCompactSelection._(List.unmodifiable(_mergeRanges(items)));

  /// `CompactSelection.fromSingleSelection` (`:601-603`).
  factory SemiCompactSelection.fromSingleSelection(Object selection) =>
      const SemiCompactSelection.empty().add(selection);

  /// `CompactSelection.fromArray` (`:605-610`).
  factory SemiCompactSelection.fromArray(Iterable<int> items) {
    final list = items.toList(growable: false);
    if (list.isEmpty) return const SemiCompactSelection.empty();
    final slices = [for (final s in list) SemiSlice(s, s + 1)];
    return SemiCompactSelection._(List.unmodifiable(_mergeRanges(slices)));
  }

  /// `items` (`:591`), already merged and sorted.
  final List<SemiSlice> items;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  /// `offset` (`:612-616`).
  SemiCompactSelection offset(int amount) {
    if (amount == 0) return this;
    return SemiCompactSelection._(
      List.unmodifiable([
        for (final x in items) SemiSlice(x.start + amount, x.end + amount),
      ]),
    );
  }

  /// `add` (`:618-622`). [selection] is an `int` or a [SemiSlice].
  SemiCompactSelection add(Object selection) {
    final slice = selection is int
        ? SemiSlice(selection, selection + 1)
        : selection as SemiSlice;
    return SemiCompactSelection._(
      List.unmodifiable(_mergeRanges([...items, slice])),
    );
  }

  /// `remove` (`:624-645`).
  ///
  /// Upstream splices the backing array while iterating it, which can skip an
  /// entry when two slices are affected. The intent is "subtract the selection
  /// from every slice", which is what this implementation does; the result is
  /// also not re-merged, matching upstream.
  SemiCompactSelection remove(Object selection) {
    final selMin = selection is int ? selection : (selection as SemiSlice).start;
    final selMax = selection is int ? selection + 1 : (selection as SemiSlice).end;

    final result = <SemiSlice>[];
    for (final slice in items) {
      final start = slice.start;
      final end = slice.end;
      if (start <= selMax && selMin <= end) {
        if (start < selMin) result.add(SemiSlice(start, selMin));
        if (selMax < end) result.add(SemiSlice(selMax, end));
      } else {
        result.add(slice);
      }
    }
    return SemiCompactSelection._(List.unmodifiable(result));
  }

  /// `first` (`:647-650`). Named `firstIndex` because [Iterable.first] already
  /// exists on the interface.
  int? get firstIndex => items.isEmpty ? null : items.first.start;

  /// `last` (`:652-655`). Named `lastIndex` for the same reason.
  int? get lastIndex => items.isEmpty ? null : items.last.end - 1;

  /// `hasIndex` (`:657-663`).
  bool hasIndex(int index) {
    for (final item in items) {
      if (index >= item.start && index < item.end) return true;
    }
    return false;
  }

  /// `hasAll` (`:665-670`).
  bool hasAll(SemiSlice index) {
    for (var x = index.start; x < index.end; x++) {
      if (!hasIndex(x)) return false;
    }
    return true;
  }

  /// `some` (`:672-677`).
  bool some(bool Function(int index) predicate) {
    for (final i in indices) {
      if (predicate(i)) return true;
    }
    return false;
  }

  /// `equals` (`:679-692`).
  bool equals(SemiCompactSelection other) {
    if (identical(other, this)) return true;
    if (other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  /// `toArray` (`:698-706`).
  List<int> toArray() => indices.toList();

  /// The `[Symbol.iterator]` protocol (`:717-723`), exposed as a Dart iterable.
  Iterable<int> get indices sync* {
    for (final item in items) {
      for (var x = item.start; x < item.end; x++) {
        yield x;
      }
    }
  }

  /// `length` (`:708-715`).
  int get length {
    var len = 0;
    for (final item in items) {
      len += item.length;
    }
    return len;
  }

  @override
  bool operator ==(Object other) =>
      other is SemiCompactSelection && equals(other);

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'SemiCompactSelection($items)';
}
