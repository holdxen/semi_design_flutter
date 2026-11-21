// Port of `DrawGridArg` (`packages/core/src/internal/data-grid/render/
// draw-grid-arg.ts`) with the browser-only fields removed (canvas contexts,
// dpr, sprite manager, image loader, render strategy).
import 'package:flutter/widgets.dart';

import '../../../cells/glide_cell_types.dart';
import '../glide_cell_set.dart';

/// `GroupDetails`: per-group theme override.
@immutable
class GlideGroupDetails {
  const GlideGroupDetails({this.overrideTheme});

  final GlideThemeOverride? overrideTheme;
}

/// `GetRowThemeCallback`.
typedef GlideGetRowThemeOverride = GlideThemeOverride? Function(int row);

/// `HoverValues`: `[item, hoverAmount]` pairs.
typedef GlideHoverValues = Map<GlideItem, double>;

/// `Highlight`: overlay range with a color.
@immutable
class GlideHighlight {
  const GlideHighlight({
    required this.range,
    required this.color,
    this.style = GlideHighlightStyle.solidOutline,
  });

  final GlideRectangle range;
  final Color color;
  final GlideHighlightStyle style;
}

/// `Highlight.style` (`"solid-outline" | "dashed-outline" | "no-outline"`).
enum GlideHighlightStyle { solidOutline, dashedOutline, noOutline }

/// `DrawGridArg` (`draw-grid-arg.ts:30-83`).
class GlideDrawGridArg {
  const GlideDrawGridArg({
    required this.width,
    required this.height,
    required this.headerHeight,
    required this.groupHeaderHeight,
    required this.enableGroups,
    required this.cellXOffset,
    required this.cellYOffset,
    required this.translateX,
    required this.translateY,
    required this.mappedColumns,
    required this.freezeColumns,
    required this.freezeTrailingRows,
    required this.rows,
    required this.rowHeight,
    required this.theme,
    required this.selection,
    required this.isFocused,
    required this.drawFocus,
    required this.verticalBorder,
    required this.getCellContent,
    required this.getCellRenderer,
    required this.metrics,
    this.getRowThemeOverride,
    this.getGroupDetails,
    this.hoverValues = const {},
    this.hoverInfo,
    this.hoverPosition,
    this.damage,
    this.hasAppendRow = false,
    this.touchMode = false,
    this.fillHandle,
    this.disabledRows = const GlideCompactSelection.empty(),
    this.prelightCells,
    this.highlightRegions,
    this.frameTime = 0,
    this.hyperWrapping = false,
    this.enqueue,
    this.minimumCellWidth = 10,
    this.dragAndDropState,
    this.isResizing = false,
    this.resizeColumn,
    this.resizeIndicator = GlideResizeIndicator.full,
  });

  final double width;
  final double height;
  final double headerHeight;
  final double groupHeaderHeight;
  final bool enableGroups;
  final int cellXOffset;
  final int cellYOffset;
  final double translateX;
  final double translateY;
  final List<GlideMappedColumn> mappedColumns;
  final int freezeColumns;
  final int freezeTrailingRows;
  final int rows;
  final GlideRowHeight rowHeight;
  final GlideTheme theme;
  final GlideGridSelection selection;
  final bool isFocused;
  final bool drawFocus;
  final bool Function(int col) verticalBorder;
  final GlideGridCell Function(GlideItem item) getCellContent;
  final GlideGetCellRenderer getCellRenderer;
  final GlideTextMetrics metrics;
  final GlideGetRowThemeOverride? getRowThemeOverride;
  final GlideGroupDetails Function(String group)? getGroupDetails;
  final GlideHoverValues hoverValues;
  final GlideItem? hoverInfo;
  final Offset? hoverPosition;
  final GlideCellSet? damage;
  final bool hasAppendRow;
  final bool touchMode;
  final GlideFillHandleConfig? fillHandle;
  final GlideCompactSelection disabledRows;
  final List<GlideItem>? prelightCells;
  final List<GlideHighlight>? highlightRegions;
  final int frameTime;
  final bool hyperWrapping;
  final void Function(GlideItem item)? enqueue;
  final double minimumCellWidth;

  /// `dragAndDropState` (`draw-grid-arg.ts:44`): swaps the two columns in
  /// `getEffectiveColumns` so the preview shows the reordered header.
  final GlideColumnDndState? dragAndDropState;
  final bool isResizing;
  final int? resizeColumn;
  final GlideResizeIndicator resizeIndicator;
}
