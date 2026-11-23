// Port of `packages/core/src/internal/data-grid/render/data-grid-render.walk.ts`.
import '../semi_geometry.dart';
import '../semi_types.dart';

/// `getSkipPoint` (`walk.ts:4-11`).
double? getSkipPoint(List<SemiRectangle> drawRegions) {
  if (drawRegions.isEmpty) return null;
  double? lowest;
  for (final dr in drawRegions) {
    lowest = lowest == null ? dr.y : (dr.y < lowest ? dr.y : lowest);
  }
  return lowest;
}

/// `WalkRowsCallback` (`walk.ts:13-19`).
typedef SemiWalkRowsCallback =
    bool? Function(
      double drawY,
      int row,
      double rowHeight,
      bool isSticky,
      bool isTrailingRow,
    );

/// `walkRowsInCol` (`walk.ts:21-56`).
void walkRowsInCol({
  required int startRow,
  required double drawY,
  required double height,
  required int rows,
  required SemiRowHeight getRowHeight,
  required int freezeTrailingRows,
  required bool hasAppendRow,
  double? skipToY,
  required SemiWalkRowsCallback cb,
}) {
  final skip = skipToY ?? drawY;
  var y = drawY;
  var row = startRow;
  final rowEnd = rows - freezeTrailingRows;
  var didBreak = false;

  while (y < height && row < rowEnd) {
    final rh = getRowHeight(row);
    if (y + rh > skip &&
        cb(y, row, rh, false, hasAppendRow && row == rows - 1) == true) {
      didBreak = true;
      break;
    }
    y += rh;
    row++;
  }

  if (didBreak) return;

  y = height;
  for (var fr = 0; fr < freezeTrailingRows; fr++) {
    row = rows - 1 - fr;
    final rh = getRowHeight(row);
    y -= rh;
    cb(y, row, rh, true, hasAppendRow && row == rows - 1);
  }
}

/// `WalkColsCallback` (`walk.ts:58-64`).
typedef SemiWalkColsCallback =
    bool? Function(
      SemiMappedColumn col,
      double drawX,
      double drawY,
      double clipX,
      int startRow,
    );

/// `walkColumns` (`walk.ts:66-86`).
void walkColumns({
  required List<SemiMappedColumn> effectiveCols,
  required int cellYOffset,
  required double translateX,
  required double translateY,
  required double totalHeaderHeight,
  required SemiWalkColsCallback cb,
}) {
  var x = 0.0;
  var clipX = 0.0; // total width of sticky cols
  final drawY = totalHeaderHeight + translateY;
  for (final c in effectiveCols) {
    final drawX = c.sticky ? clipX : x + translateX;
    if (cb(c, drawX, drawY, c.sticky ? 0 : clipX, cellYOffset) == true) break;
    x += c.width;
    clipX += c.sticky ? c.width : 0;
  }
}

/// `WalkGroupsCallback` (`walk.ts:89-96`).
typedef SemiWalkGroupsCallback =
    void Function(
      (int, int) colSpan,
      String group,
      double x,
      double y,
      double width,
      double height,
    );

/// `walkGroups` (`walk.ts:98-144`).
void walkGroups({
  required List<SemiMappedColumn> effectiveCols,
  required double width,
  required double translateX,
  required double groupHeaderHeight,
  required SemiWalkGroupsCallback cb,
}) {
  var x = 0.0;
  var clipX = 0.0;
  for (var index = 0; index < effectiveCols.length; index++) {
    final startCol = effectiveCols[index];

    var end = index + 1;
    var boxWidth = startCol.width;
    if (startCol.sticky) clipX += boxWidth;
    while (end < effectiveCols.length &&
        isGroupEqual(effectiveCols[end].group, startCol.group) &&
        effectiveCols[end].sticky == effectiveCols[index].sticky) {
      final endCol = effectiveCols[end];
      boxWidth += endCol.width;
      end++;
      index++;
      if (endCol.sticky) clipX += endCol.width;
    }

    final t = startCol.sticky ? 0.0 : translateX;
    final localX = x + t;
    final delta = startCol.sticky ? 0.0 : (clipX - localX > 0 ? clipX - localX : 0.0);
    final w = boxWidth - delta < width - (localX + delta)
        ? boxWidth - delta
        : width - (localX + delta);
    cb(
      (startCol.sourceIndex, effectiveCols[end - 1].sourceIndex),
      startCol.group ?? '',
      localX + delta,
      0,
      w,
      groupHeaderHeight,
    );

    x += boxWidth;
  }
}

/// `getSpanBounds` (`walk.ts:146-200`).
(SemiRectangle?, SemiRectangle?) getSpanBounds({
  required SemiSpan span,
  required double cellX,
  required double cellY,
  required double cellW,
  required double cellH,
  required SemiMappedColumn column,
  required List<SemiMappedColumn> allColumns,
}) {
  final startCol = span.start;
  final endCol = span.end;

  SemiRectangle? frozenRect;
  SemiRectangle? contentRect;

  final firstNonSticky = allColumns.where((c) => !c.sticky).firstOrNull?.sourceIndex ?? 0;
  if (endCol > firstNonSticky) {
    final renderFromCol = startCol > firstNonSticky ? startCol : firstNonSticky;
    var tempX = cellX;
    var tempW = cellW;
    for (var x = column.sourceIndex - 1; x >= renderFromCol; x--) {
      tempX -= allColumns[x].width;
      tempW += allColumns[x].width;
    }
    for (var x = column.sourceIndex + 1; x <= endCol; x++) {
      tempW += allColumns[x].width;
    }
    contentRect = SemiRectangle(
      x: tempX,
      y: cellY,
      width: tempW,
      height: cellH,
    );
  }

  if (firstNonSticky > startCol) {
    final renderToCol = endCol < firstNonSticky - 1 ? endCol : firstNonSticky - 1;
    var tempX = cellX;
    var tempW = cellW;
    for (var x = column.sourceIndex - 1; x >= startCol; x--) {
      tempX -= allColumns[x].width;
      tempW += allColumns[x].width;
    }
    for (var x = column.sourceIndex + 1; x <= renderToCol; x++) {
      tempW += allColumns[x].width;
    }
    frozenRect = SemiRectangle(
      x: tempX,
      y: cellY,
      width: tempW,
      height: cellH,
    );
  }

  return (frozenRect, contentRect);
}

/// `intersectRect` (`common/math.ts`).
bool intersectRect(
  double aX,
  double aY,
  double aW,
  double aH,
  double bX,
  double bY,
  double bW,
  double bH,
) => aX < bX + bW && aX + aW > bX && aY < bY + bH && aY + aH > bY;
