// Port of `DrawGridArg` (`packages/core/src/internal/data-grid/render/
// draw-grid-arg.ts`) with the browser-only fields removed (canvas contexts,
// dpr, sprite manager, image loader, render strategy).
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';

import '../../../cells/glide_cell_types.dart';
import '../../../common/glide_image_window_loader.dart';
import '../glide_cell_set.dart';

/// `GroupDetails`: per-group theme override.
@immutable
/// `GroupDetails` (`data-grid-render.cells.ts:42-50`).
@immutable
class GlideGroupDetails {
  const GlideGroupDetails({
    required this.name,
    this.icon,
    this.overrideTheme,
    this.actions,
  });

  final String name;

  /// Upstream is a sprite name (`GridColumnIcon | string`); this port has no
  /// sprite manager, so a Flutter [IconData] is used instead.
  final IconData? icon;
  final GlideThemeOverride? overrideTheme;
  final List<GlideGroupAction>? actions;
}

/// One entry of `GroupDetails.actions` (`data-grid-render.cells.ts:45-49`).
@immutable
class GlideGroupAction {
  const GlideGroupAction({
    required this.title,
    required this.onClick,
    this.icon,
  });

  final String title;
  final IconData? icon;

  /// Upstream receives the `GridMouseGroupHeaderEventArgs`; the group name is
  /// already closed over by the callback's owner, so only the bounds that the
  /// rename editor positions itself with are passed.
  final void Function(GlideRectangle bounds) onClick;
}

/// `getActionBoundsForGroup` (`data-grid-render.header.ts`): 26px boxes
/// counted back from the right edge of the group header.
List<GlideRectangle> getActionBoundsForGroup(
  GlideRectangle box,
  List<GlideGroupAction> actions,
) {
  final result = <GlideRectangle>[];
  var x = box.x + box.width - 26 * actions.length;
  for (var i = 0; i < actions.length; i++) {
    result.add(
      GlideRectangle(
        x: x,
        y: box.y + box.height / 2 - 13,
        width: 26,
        height: 26,
      ),
    );
    x += 26;
  }
  return result;
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
    this.hyperWrapping = false,
    this.enqueue,
    this.minimumCellWidth = 10,
    this.dragAndDropState,
    this.isResizing = false,
    this.resizeColumn,
    this.resizeIndicator = GlideResizeIndicator.full,
    this.imageLoader,
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
  final bool hyperWrapping;
  final void Function(GlideItem item)? enqueue;
  final double minimumCellWidth;

  /// `dragAndDropState` (`draw-grid-arg.ts:44`): swaps the two columns in
  /// `getEffectiveColumns` so the preview shows the reordered header.
  final GlideColumnDndState? dragAndDropState;
  final bool isResizing;
  final int? resizeColumn;
  final GlideResizeIndicator resizeIndicator;
  final GlideImageWindowLoader? imageLoader;
}
