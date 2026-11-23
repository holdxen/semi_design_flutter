// Port of `packages/core/src/internal/scrolling-data-grid/scrolling-data-grid.tsx`.
//
// Upstream the scroller is a React component around a DOM element whose
// `onScroll` feeds `processArgs`; here the same math is a pure function over
// Flutter's `ScrollController` offsets, and the "virtual scroll position" the
// browser maintains for us is a `SemiVirtualScroll` value.
import 'package:flutter/widgets.dart';

import '../data_grid/semi_geometry.dart';
import '../data_grid/semi_types.dart';

/// `onVisibleRegionChanged` callback signature
/// (`scrolling-data-grid.tsx:222-234`).
typedef SemiOnVisibleRegionChanged =
    void Function(
      SemiRectangle region,
      double width,
      double height,
      double paddingRight,
      double translateX,
      double translateY,
    );

/// Result of `processArgs` (`scrolling-data-grid.tsx:202-207`).
@immutable
class SemiVisibleRegion {
  const SemiVisibleRegion({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.translateX,
    required this.translateY,
  });

  final int x;
  final int y;
  final int width;
  final int height;
  final double translateX;
  final double translateY;

  SemiRectangle get rect => SemiRectangle(
    x: x.toDouble(),
    y: y.toDouble(),
    width: width.toDouble(),
    height: height.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      other is SemiVisibleRegion &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height &&
      other.translateX == translateX &&
      other.translateY == translateY;

  @override
  int get hashCode =>
      Object.hash(x, y, width, height, translateX, translateY);
}

/// `processArgs` (`scrolling-data-grid.tsx:121-240`).
///
/// `scrollX`/`scrollY` are the raw offsets; `translateX`/`translateY` are the
/// sub-cell offsets the painter needs when `smoothScrollX/Y` is on.
SemiVisibleRegion computeVisibleRegion({
  required double scrollX,
  required double scrollY,
  required double clientWidth,
  required double clientHeight,
  required List<SemiMappedColumn> columns,
  required SemiRowHeight rowHeight,
  required int rows,
  required int freezeColumns,
  bool smoothScrollX = false,
  bool smoothScrollY = false,
}) {
  var x = 0.0;
  var tx = scrollX < 0 ? -scrollX : 0.0;
  var cellX = 0;
  var cellRight = 0;

  var argsX = scrollX < 0 ? 0.0 : scrollX;

  var stickyColWidth = 0.0;
  for (var i = 0; i < freezeColumns && i < columns.length; i++) {
    stickyColWidth += columns[i].width;
  }

  for (final c in columns) {
    final cx = x - stickyColWidth;
    if (argsX >= cx + c.width) {
      x += c.width;
      cellX++;
      cellRight++;
    } else if (argsX > cx) {
      x += c.width;
      if (smoothScrollX) {
        tx += cx - argsX;
      } else {
        cellX++;
      }
      cellRight++;
    } else if (argsX + clientWidth > cx) {
      x += c.width;
      cellRight++;
    } else {
      break;
    }
  }

  var ty = 0.0;
  var cellY = 0;
  var cellBottom = 0;
  if (rowHeight.isFixed) {
    final rh = rowHeight(0);
    if (smoothScrollY) {
      cellY = (scrollY / rh).floor();
      ty = cellY * rh - scrollY;
    } else {
      cellY = (scrollY / rh).ceil();
    }
    cellBottom = (clientHeight / rh).ceil() + cellY;
    if (ty < 0) cellBottom++;
  } else {
    var y = 0.0;
    for (var row = 0; row < rows; row++) {
      final rh = rowHeight(row);
      final cy = y + (smoothScrollY ? 0 : rh / 2);
      if (scrollY >= y + rh) {
        y += rh;
        cellY++;
        cellBottom++;
      } else if (scrollY > cy) {
        y += rh;
        if (smoothScrollY) {
          ty += cy - scrollY;
        } else {
          cellY++;
        }
        cellBottom++;
      } else if (scrollY + clientHeight > rh / 2 + y) {
        y += rh;
        cellBottom++;
      } else {
        break;
      }
    }
  }

  // Safeguard against out-of-bounds access with large datasets.
  cellY = cellY < 0 ? 0 : (cellY > rows - 1 ? rows - 1 : cellY);
  cellBottom = cellBottom < cellY ? cellY : (cellBottom > rows ? rows : cellBottom);

  return SemiVisibleRegion(
    x: cellX,
    y: cellY,
    width: cellRight - cellX,
    height: cellBottom - cellY,
    translateX: tx,
    translateY: ty,
  );
}

/// `VisibleRegion.extras` (`visible-region.ts:9-20`).
@immutable
class SemiVisibleRegionExtras {
  const SemiVisibleRegionExtras({
    this.selected,
    this.freezeRegion,
    this.freezeRegions = const [],
  });

  /// `extras.selected` (`data-editor.ts:2594-2597`): the current cell, in
  /// marker-free coordinates.
  final SemiItem? selected;

  /// The frozen columns' rect (`data-editor.ts:2599-2607`).
  final SemiRectangle? freezeRegion;

  /// Frozen columns plus the frozen trailing rows (`:2609-2627`).
  final List<SemiRectangle> freezeRegions;
}

/// Scroll extent of the virtual content (`scrolling-data-grid.tsx:105-117`).
SemiSize computeScrollExtent({
  required List<SemiMappedColumn> columns,
  required SemiRowHeight rowHeight,
  required int rows,
  required int headerHeight,
  required int groupHeaderHeight,
  required bool enableGroups,
  double overscrollX = 0,
  double overscrollY = 0,
}) {
  var width = columns.fold<double>(0, (sum, c) => sum + c.width) + overscrollX;
  var height = (enableGroups
          ? headerHeight + groupHeaderHeight
          : headerHeight)
      .toDouble();
  if (rowHeight.isFixed) {
    height += rows * rowHeight(0);
  } else {
    for (var r = 0; r < rows; r++) {
      height += rowHeight(r);
    }
  }
  height += overscrollY;
  return SemiSize(width, height);
}

/// Minimal `Size`-like value for scroll extents.
@immutable
class SemiSize {
  const SemiSize(this.width, this.height);
  final double width;
  final double height;

  @override
  bool operator ==(Object other) =>
      other is SemiSize && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(width, height);
}

/// `InfiniteScroller` (`infinite-scroller.tsx`) for the Flutter case: a plain
/// `ScrollController` on a `Viewport` sized to [SemiSize] whose offsets are
/// translated into a [SemiVisibleRegion] on every scroll tick.
class SemiScrollerState {
  SemiScrollerState({
    required this.columns,
    required this.rowHeight,
    required this.rows,
    required this.freezeColumns,
    required this.smoothScrollX,
    required this.smoothScrollY,
    required this.onVisibleRegionChanged,
  });

  final List<SemiMappedColumn> columns;
  final SemiRowHeight rowHeight;
  final int rows;
  final int freezeColumns;
  final bool smoothScrollX;
  final bool smoothScrollY;
  final SemiOnVisibleRegionChanged onVisibleRegionChanged;

  SemiVisibleRegion? lastRegion;
  Offset? lastOffset;
  Size? lastSize;

  void update(double scrollX, double scrollY, double width, double height) {
    final region = computeVisibleRegion(
      scrollX: scrollX,
      scrollY: scrollY,
      clientWidth: width,
      clientHeight: height,
      columns: columns,
      rowHeight: rowHeight,
      rows: rows,
      freezeColumns: freezeColumns,
      smoothScrollX: smoothScrollX,
      smoothScrollY: smoothScrollY,
    );

    if (region != lastRegion ||
        lastOffset != Offset(scrollX, scrollY) ||
        lastSize != Size(width, height)) {
      lastRegion = region;
      lastOffset = Offset(scrollX, scrollY);
      lastSize = Size(width, height);
      onVisibleRegionChanged(
        region.rect,
        width,
        height,
        0,
        region.translateX,
        region.translateY,
      );
    }
  }
}
