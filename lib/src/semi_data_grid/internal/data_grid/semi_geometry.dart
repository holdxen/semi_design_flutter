// Port of `packages/core/src/internal/data-grid/render/data-grid-lib.ts`.
//
// The geometry is pure arithmetic and is ported line by line. Two Web-only
// pieces are replaced:
// - `useMappedColumns` is a React hook upstream; here it is a pure function
//   and the memoization belongs to the widget (`SemiDataGrid`).
// - text metrics use `TextPainter` instead of `CanvasRenderingContext2D`;
//   `getMiddleCenterBias` becomes [SemiTextMetrics.middleCenterBias], derived
//   from font ascent/descent instead of canvas bounding boxes.
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../common/semi_data_grid_theme.dart';
import 'semi_types.dart';

/// `number | ((row: number) => number)` (`data-grid.tsx:108`).
@immutable
class SemiRowHeight {
  const SemiRowHeight.fixed(double height)
    : _fixed = height,
      _variable = null;

  const SemiRowHeight.variable(double Function(int row) height)
    : _fixed = null,
      _variable = height;

  final double? _fixed;
  final double Function(int row)? _variable;

  bool get isFixed => _fixed != null;

  double call(int row) => _fixed ?? _variable!(row);

  /// `getFreezeTrailingHeight` (`data-grid-lib.ts:189-203`).
  double trailingHeight(int rows, int freezeTrailingRows) {
    if (_fixed case final h?) return freezeTrailingRows * h;
    var result = 0.0;
    for (var i = rows - freezeTrailingRows; i < rows; i++) {
      result += _variable!(i);
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      other is SemiRowHeight &&
      other._fixed == _fixed &&
      // The variable form has to compare its function, otherwise every
      // `SemiRowHeight.variable` instance is "equal" and a grid that swaps
      // row-height formulas would never repaint.
      identical(other._variable, _variable);

  @override
  int get hashCode =>
      _fixed?.hashCode ?? identityHashCode(_variable);
}

/// `MappedGridColumn` (`data-grid-lib.ts:17-20`).
@immutable
class SemiMappedColumn {
  const SemiMappedColumn({
    required this.sourceIndex,
    required this.sticky,
    required this.title,
    required this.width,
    this.id,
    this.group,
    this.icon,
    this.overlayIcon,
    this.menuIcon,
    this.indicatorIcon,
    this.hasMenu = false,
    this.grow,
    this.style,
    this.themeOverride,
    this.trailingRowOptions,
    this.extension,
  });

  final int sourceIndex;
  final bool sticky;
  final String title;
  final double width;
  final String? id;
  final String? group;
  final SemiColumnIcon? icon;
  final SemiColumnIcon? overlayIcon;
  final SemiColumnMenuIcon? menuIcon;
  final SemiColumnIcon? indicatorIcon;
  final bool hasMenu;
  final int? grow;
  final SemiColumnStyle? style;
  final SemiThemeOverride? themeOverride;
  final SemiTrailingRowOptions? trailingRowOptions;
  final SemiInnerColumnExtension? extension;

  SemiMappedColumn copyWith({bool? sticky, double? width}) => SemiMappedColumn(
    sourceIndex: sourceIndex,
    sticky: sticky ?? this.sticky,
    title: title,
    width: width ?? this.width,
    id: id,
    group: group,
    icon: icon,
    overlayIcon: overlayIcon,
    menuIcon: menuIcon,
    indicatorIcon: indicatorIcon,
    hasMenu: hasMenu,
    grow: grow,
    style: style,
    themeOverride: themeOverride,
    trailingRowOptions: trailingRowOptions,
    extension: extension,
  );
}

/// `useMappedColumns` (`data-grid-lib.ts:22-55`).
List<SemiMappedColumn> mapColumns(
  List<SemiGridColumn> columns,
  int freezeColumns,
) => [
  for (var i = 0; i < columns.length; i++)
    SemiMappedColumn(
      sourceIndex: i,
      sticky: i < freezeColumns,
      title: columns[i].title,
      width: columns[i].width ?? 0,
      id: columns[i].id,
      group: columns[i].group,
      icon: columns[i].icon,
      overlayIcon: columns[i].overlayIcon,
      menuIcon: columns[i].menuIcon,
      indicatorIcon: columns[i].indicatorIcon,
      hasMenu: columns[i].hasMenu,
      grow: columns[i].grow,
      style: columns[i].style,
      themeOverride: columns[i].themeOverride,
      trailingRowOptions: columns[i].trailingRowOptions,
      extension: columns[i].extension,
    ),
];

/// `isGroupEqual` (`data-grid-lib.ts:71-73`).
bool isGroupEqual(String? left, String? right) => (left ?? '') == (right ?? '');

/// `cellIsSelected` (`data-grid-lib.ts:75-85`).
bool cellIsSelected(
  SemiItem location,
  SemiGridCell cell,
  SemiGridSelection selection,
) {
  final current = selection.current;
  if (current == null) return false;
  if (location.row != current.cell.row) return false;
  final span = cell.span;
  if (span == null) return current.cell.col == location.col;
  return current.cell.col >= span.start && current.cell.col <= span.end;
}

/// `itemIsInRect` (`data-grid-lib.ts:87-91`).
bool itemIsInRect(SemiItem location, SemiRectangle rect) =>
    rect.containsItem(location);

/// `itemsAreEqual` (`data-grid-lib.ts:93-95`).
bool itemsAreEqual(SemiItem? a, SemiItem? b) =>
    a?.col == b?.col && a?.row == b?.row;

/// `rectBottomRight` (`data-grid-lib.ts:97-99`).
SemiItem rectBottomRight(SemiRectangle rect) =>
    SemiItem(rect.x.toInt() + rect.width.toInt() - 1,
        rect.y.toInt() + rect.height.toInt() - 1);

/// `cellIsInRect` (`data-grid-lib.ts:101-120`).
bool _cellIsInRect(SemiItem location, SemiGridCell cell, SemiRectangle rect) {
  final startX = rect.x;
  final endX = rect.x + rect.width - 1;
  final startY = rect.y;
  final endY = rect.y + rect.height - 1;

  final cellCol = location.col;
  final cellRow = location.row;
  if (cellRow < startY || cellRow > endY) return false;

  final span = cell.span;
  if (span == null) return cellCol >= startX && cellCol <= endX;

  return (span.start >= startX && span.start <= endX) ||
      (span.end >= startX && span.start <= endX) ||
      (span.start < startX && span.end > endX);
}

/// `cellIsInRange` (`data-grid-lib.ts:122-142`).
int cellIsInRange(
  SemiItem location,
  SemiGridCell cell,
  SemiGridSelection selection,
  bool includeSingleSelection,
) {
  var result = 0;
  final current = selection.current;
  if (current == null) return result;

  final range = current.range;
  if ((includeSingleSelection || range.height * range.width > 1) &&
      _cellIsInRect(location, cell, range)) {
    result++;
  }
  for (final r in current.rangeStack) {
    if (_cellIsInRect(location, cell, r)) result++;
  }
  return result;
}

/// `remapForDnDState` (`data-grid-lib.ts:144-169`).
List<SemiMappedColumn> remapForDndState(
  List<SemiMappedColumn> columns,
  SemiColumnDndState? dndState,
) {
  if (dndState == null) return columns;
  final writable = [...columns];
  final temp = writable[dndState.src];
  if (dndState.src > dndState.dest) {
    writable.removeAt(dndState.src);
    writable.insert(dndState.dest, temp);
  } else {
    writable.insert(dndState.dest + 1, temp);
    writable.removeAt(dndState.src);
  }
  return [
    for (var i = 0; i < writable.length; i++)
      writable[i].copyWith(sticky: columns[i].sticky),
  ];
}

/// `{ src: number; dest: number }` from `remapForDnDState`.
@immutable
class SemiColumnDndState {
  const SemiColumnDndState({required this.src, required this.dest});

  final int src;
  final int dest;

  @override
  bool operator ==(Object other) =>
      other is SemiColumnDndState && other.src == src && other.dest == dest;

  @override
  int get hashCode => Object.hash(src, dest);
}

/// `getHeaderMenuBounds` (`data-grid-render.header.ts:289-297`): the box the
/// header menu button occupies, in grid coordinates. The RTL branch is
/// dropped along with the rest of the port's RTL support.
///
/// Lives here rather than in the painter because the hit test
/// (`data-grid.tsx:1044-1056`) needs the exact same rectangle the painter
/// draws into.
SemiRectangle getHeaderMenuBounds(
  double x,
  double y,
  double width,
  double height,
) {
  const size = 30.0; // `menuButtonSize`
  return SemiRectangle(
    x: x + width - size,
    y: math.max(y, y + height / 2 - size / 2),
    width: size,
    height: math.min(size, height),
  );
}

/// `HeaderLayout` (`data-grid-render.header.ts:324-330`).
///
/// `textBounds` and `menuBounds` are non-nullable because upstream only types
/// them as optional through `flipHorizontal`, which this port drops along with
/// RTL — both are always produced.
@immutable
class SemiHeaderLayout {
  const SemiHeaderLayout({
    required this.textBounds,
    required this.menuBounds,
    this.iconBounds,
    this.iconOverlayBounds,
    this.indicatorIconBounds,
  });

  final SemiRectangle textBounds;
  final SemiRectangle menuBounds;
  final SemiRectangle? iconBounds;
  final SemiRectangle? iconOverlayBounds;
  final SemiRectangle? indicatorIconBounds;
}

/// `computeHeaderLayout` (`data-grid-render.header.ts:342-414`): where a
/// header's icon, overlay icon, title and indicator icon sit.
///
/// [metrics] is upstream's `ctx`. It is only read when the column has an
/// `indicatorIcon`, and upstream's hit-test path (`isOverHeaderElement`)
/// passes `undefined` there to fall back on `getMeasuredTextCache(...)?.width
/// ?? 0`. Measuring unconditionally is equivalent in practice: that fallback
/// can only return 0 before the first paint, and a header cannot be hit
/// before it has been painted.
SemiHeaderLayout computeHeaderLayout({
  required SemiMappedColumn c,
  required double x,
  required double y,
  required double width,
  required double height,
  required SemiDataGridTheme theme,
  required SemiTextMetrics metrics,
}) {
  final xPad = theme.cellHorizontalPadding;
  final headerIconSize = theme.headerIconSize;
  final menuBounds = getHeaderMenuBounds(x, y, width, height);

  var drawX = x + xPad;
  final iconBounds = c.icon == null
      ? null
      : SemiRectangle(
          x: drawX,
          y: y + (height - headerIconSize) / 2,
          width: headerIconSize,
          height: headerIconSize,
        );

  final iconOverlayBounds =
      iconBounds == null || c.overlayIcon == null
          ? null
          : SemiRectangle(
              x: iconBounds.x + 9,
              y: iconBounds.y + 6,
              width: 18,
              height: 18,
            );

  if (iconBounds != null) {
    drawX += (headerIconSize * 1.3).ceilToDouble();
  }

  // `width - drawX` mixes the cell width with an absolute x, so this is only
  // meaningful for `x == 0`. Upstream reads it solely in the RTL branch and
  // overwrites it with the measured title width when an indicator is present;
  // both uses are preserved here without the RTL branch.
  var textBounds = SemiRectangle(
    x: drawX,
    y: y,
    width: width - drawX,
    height: height,
  );

  SemiRectangle? indicatorIconBounds;
  if (c.indicatorIcon != null) {
    final textWidth = metrics.width(c.title, theme.headerTextStyle);
    textBounds = textBounds.copyWith(width: textWidth);
    drawX += textWidth + xPad;
    indicatorIconBounds = SemiRectangle(
      x: drawX,
      y: y + (height - headerIconSize) / 2,
      width: headerIconSize,
      height: headerIconSize,
    );
  }

  return SemiHeaderLayout(
    textBounds: textBounds,
    menuBounds: menuBounds,
    iconBounds: iconBounds,
    iconOverlayBounds: iconOverlayBounds,
    indicatorIconBounds: indicatorIconBounds,
  );
}

/// `opacityX` (`data-grid.tsx:1878-1880`): how far the frozen-column shadow
/// has faded in. It is off entirely without frozen columns or when
/// `fixedShadowX` is disabled, snaps to full once the scroll has moved past
/// the frozen region, and otherwise ramps in over the first 100px of
/// horizontal scroll.
double semiStickyShadowOpacityX({
  required int freezeColumns,
  required int cellXOffset,
  required double translateX,
  required bool fixedShadowX,
}) {
  if (freezeColumns == 0 || !fixedShadowX) return 0;
  if (cellXOffset > freezeColumns) return 1;
  return (-translateX / 100).clamp(0.0, 1.0).toDouble();
}

/// `opacityY` (`data-grid.tsx:1881-1882`).
///
/// Deviation: upstream hardcodes a 32px row height
/// (`-cellYOffset * 32 + translateY`), which only holds for fixed 32px rows;
/// the grid's own row height is substituted so variable-height rows fade on
/// the same curve as fixed ones.
double semiStickyShadowOpacityY({
  required int cellYOffset,
  required double translateY,
  required double rowHeight,
  required bool fixedShadowY,
}) {
  if (!fixedShadowY) return 0;
  final absoluteOffsetY = -cellYOffset * rowHeight + translateY;
  return (-absoluteOffsetY / 100).clamp(0.0, 1.0).toDouble();
}

/// `getStickyWidth` (`data-grid-lib.ts:171-187`).
double getStickyWidth(
  List<SemiMappedColumn> columns, [
  SemiColumnDndState? dndState,
]) {
  var result = 0.0;
  final remapped = remapForDndState(columns, dndState);
  for (final c in remapped) {
    if (c.sticky) {
      result += c.width;
    } else {
      break;
    }
  }
  return result;
}

/// `getEffectiveColumns` (`data-grid-lib.ts:205-246`).
List<SemiMappedColumn> getEffectiveColumns(
  List<SemiMappedColumn> columns,
  int cellXOffset,
  double width, [
  SemiColumnDndState? dndState,
  double? tx,
]) {
  final mappedCols = remapForDndState(columns, dndState);

  final sticky = <SemiMappedColumn>[];
  for (final c in mappedCols) {
    if (c.sticky) {
      sticky.add(c);
    } else {
      break;
    }
  }
  if (sticky.isNotEmpty) {
    for (final c in sticky) {
      width -= c.width;
    }
  }
  var endIndex = cellXOffset;
  var curX = tx ?? 0;

  while (curX <= width && endIndex < mappedCols.length) {
    curX += mappedCols[endIndex].width;
    endIndex++;
  }

  for (var i = cellXOffset; i < endIndex; i++) {
    final c = mappedCols[i];
    if (!c.sticky) sticky.add(c);
  }

  return sticky;
}

/// `getColumnIndexForX` (`data-grid-lib.ts:248-262`).
int getColumnIndexForX(
  double targetX,
  List<SemiMappedColumn> effectiveColumns, [
  double? translateX,
]) {
  var x = 0.0;
  for (final c in effectiveColumns) {
    final cx = c.sticky ? x : x + (translateX ?? 0);
    if (targetX <= cx + c.width) return c.sourceIndex;
    x += c.width;
  }
  return -1;
}

/// `getRowIndexForY` (`data-grid-lib.ts:264-306`).
int? getRowIndexForY({
  required double targetY,
  required double height,
  required bool hasGroups,
  required double headerHeight,
  required double groupHeaderHeight,
  required int rows,
  required SemiRowHeight rowHeight,
  required int cellYOffset,
  required double translateY,
  required int freezeTrailingRows,
}) {
  final totalHeaderHeight = headerHeight + groupHeaderHeight;
  if (hasGroups && targetY <= groupHeaderHeight) return SemiItem.groupHeaderRow;
  if (targetY <= totalHeaderHeight) return SemiItem.headerRow;

  var y = height;
  for (var fr = 0; fr < freezeTrailingRows; fr++) {
    final row = rows - 1 - fr;
    final rh = rowHeight(row);
    y -= rh;
    if (targetY >= y) return row;
  }

  final effectiveRows = rows - freezeTrailingRows;

  final ty = targetY - translateY;
  if (rowHeight.isFixed) {
    final target =
        ((ty - totalHeaderHeight) / rowHeight(0)).floor() + cellYOffset;
    if (target >= effectiveRows) return null;
    return target;
  } else {
    var curY = totalHeaderHeight;
    for (var i = cellYOffset; i < effectiveRows; i++) {
      final rh = rowHeight(i);
      if (ty <= curY + rh) return i;
      curY += rh;
    }
    return null;
  }
}

/// `computeBounds` (`data-grid-lib.ts:759-870`).
SemiRectangle computeBounds({
  required int col,
  required int row,
  required double width,
  required double height,
  required double groupHeaderHeight,
  required double totalHeaderHeight,
  required int cellXOffset,
  required int cellYOffset,
  required double translateX,
  required double translateY,
  required int rows,
  required int freezeColumns,
  required int freezeTrailingRows,
  required List<SemiMappedColumn> mappedColumns,
  required SemiRowHeight rowHeight,
}) {
  var x = 0.0;
  var y = totalHeaderHeight + translateY;
  var w = 0.0;
  var h = 0.0;

  if (col >= mappedColumns.length || row >= rows || row < -2 || col < 0) {
    return SemiRectangle.empty();
  }

  final headerHeight = totalHeaderHeight - groupHeaderHeight;

  if (col >= freezeColumns) {
    final dir = cellXOffset > col ? -1 : 1;
    final freezeWidth = getStickyWidth(mappedColumns);
    x += freezeWidth + translateX;
    for (var i = cellXOffset; i != col; i += dir) {
      x += mappedColumns[dir == 1 ? i : i - 1].width * dir;
    }
  } else {
    for (var i = 0; i < col; i++) {
      x += mappedColumns[i].width;
    }
  }
  w = mappedColumns[col].width + 1;

  if (row == SemiItem.headerRow) {
    y = groupHeaderHeight;
    h = headerHeight;
  } else if (row == SemiItem.groupHeaderRow) {
    y = 0;
    h = groupHeaderHeight;

    var start = col;
    final group = mappedColumns[col].group;
    final sticky = mappedColumns[col].sticky;
    while (start > 0 &&
        isGroupEqual(mappedColumns[start - 1].group, group) &&
        mappedColumns[start - 1].sticky == sticky) {
      final c = mappedColumns[start - 1];
      x -= c.width;
      w += c.width;
      start--;
    }

    var end = col;
    while (end + 1 < mappedColumns.length &&
        isGroupEqual(mappedColumns[end + 1].group, group) &&
        mappedColumns[end + 1].sticky == sticky) {
      final c = mappedColumns[end + 1];
      w += c.width;
      end++;
    }
    if (!sticky) {
      final freezeWidth = getStickyWidth(mappedColumns);
      final clip = x - freezeWidth;
      if (clip < 0) {
        x -= clip;
        w += clip;
      }
      if (x + w > width) w = width - x;
    }
  } else if (row >= rows - freezeTrailingRows) {
    var dy = rows - row;
    y = height;
    while (dy > 0) {
      final r = row + dy - 1;
      h = rowHeight(r);
      y -= h;
      dy--;
    }
    h += 1;
  } else {
    final dir = cellYOffset > row ? -1 : 1;
    if (rowHeight.isFixed) {
      final delta = row - cellYOffset;
      y += delta * rowHeight(0);
    } else {
      for (var r = cellYOffset; r != row; r += dir) {
        y += rowHeight(r) * dir;
      }
    }
    h = rowHeight(row) + 1;
  }

  return SemiRectangle(x: x, y: y, width: w, height: h);
}

/// `measureTextCached` (`data-grid-lib.ts:332-352`).
///
/// Web caches `TextMetrics` from the canvas. Flutter's `TextPainter` has to be
/// laid out before it reports `width`, so the cache is keyed by text + style
/// and stores the painter itself (layout is the expensive part).
class SemiTextMetrics {
  SemiTextMetrics({this.maxEntries = 10000});

  final int maxEntries;
  final Map<String, TextPainter> _cache = {};

  TextPainter painter(
    String text,
    TextStyle style, {
    double maxWidth = double.infinity,
    int? maxLines,
    TextAlign textAlign = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    bool ellipsis = false,
  }) {
    final key = '${style.hashCode}|$text|$maxWidth|$maxLines|$ellipsis';
    final cached = _cache[key];
    if (cached != null) return cached;

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textAlign: textAlign,
      maxLines: maxLines,
      ellipsis: ellipsis ? '…' : null,
    )..layout(maxWidth: maxWidth);

    if (_cache.length >= maxEntries) _cache.clear();
    _cache[key] = tp;
    return tp;
  }

  double width(String text, TextStyle style) =>
      painter(text, style, maxWidth: double.infinity).width;

  /// `getMiddleCenterBias` (`data-grid-lib.ts:359-399`).
  ///
  /// Canvas needs a bias because `textBaseline` positions outside the em box;
  /// Flutter's centering works off the em box already, so the bias is 0 as
  /// long as [paintText] centers by `rect` rather than by baseline.
  double middleCenterBias(TextStyle style) => 0;

  void clear() => _cache.clear();
}

/// `getEmHeight` (`data-grid-lib.ts:490-493`).
double getEmHeight(TextStyle style) {
  final tp = TextPainter(
    text: TextSpan(text: 'ABCi09jgqpy', style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return tp.height;
}

/// `drawLastUpdateUnderlay` (`data-grid-lib.ts:401-428`) animates for 500ms.
const int lastUpdateAnimationMs = 500;

/// Flutter replacement for the canvas `roundedRect` helper: builds a [Path].
Path roundedRectPath(
  SemiRectangle rect,
  double radius, {
  double? tl,
  double? tr,
  double? bl,
  double? br,
}) {
  final h = rect.height;
  final w = rect.width;
  final maxRadius = math.min(h / 2, w / 2);
  double clampRadius(double r) => r.clamp(0, maxRadius).toDouble();
  final rtl = clampRadius(tl ?? radius);
  final rtr = clampRadius(tr ?? radius);
  final rbl = clampRadius(bl ?? radius);
  final rbr = clampRadius(br ?? radius);
  return Path()
    ..moveTo(rect.x + rtl, rect.y)
    ..lineTo(rect.x + w - rtr, rect.y)
    ..arcToPoint(Offset(rect.x + w, rect.y + rtr), radius: Radius.circular(rtr))
    ..lineTo(rect.x + w, rect.y + h - rbr)
    ..arcToPoint(
      Offset(rect.x + w - rbr, rect.y + h),
      radius: Radius.circular(rbr),
    )
    ..lineTo(rect.x + rbl, rect.y + h)
    ..arcToPoint(Offset(rect.x, rect.y + h - rbl), radius: Radius.circular(rbl))
    ..lineTo(rect.x, rect.y + rtl)
    ..arcToPoint(Offset(rect.x + rtl, rect.y), radius: Radius.circular(rtl))
    ..close();
}
