// Port of `DrawGridArg` (`packages/core/src/internal/data-grid/render/
// draw-grid-arg.ts`) with the browser-only fields removed (canvas contexts,
// dpr, sprite manager, image loader, render strategy).
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';

import '../../../cells/semi_cell_types.dart';
import '../../../common/semi_image_window_loader.dart';
import '../semi_sprite_manager.dart';
import '../semi_cell_set.dart';

/// `GroupDetails`: per-group theme override.
@immutable
/// `GroupDetails` (`data-grid-render.cells.ts:42-50`).
@immutable
class SemiGroupDetails {
  const SemiGroupDetails({
    required this.name,
    this.icon,
    this.overrideTheme,
    this.actions,
  });

  final String name;

  /// Upstream is a sprite name (`GridColumnIcon | string`); this port has no
  /// sprite manager, so a Flutter [IconData] is used instead.
  final IconData? icon;
  final SemiThemeOverride? overrideTheme;
  final List<SemiGroupAction>? actions;
}

/// One entry of `GroupDetails.actions` (`data-grid-render.cells.ts:45-49`).
@immutable
class SemiGroupAction {
  const SemiGroupAction({
    required this.title,
    required this.onClick,
    this.icon,
  });

  final String title;
  final IconData? icon;

  /// Upstream receives the `GridMouseGroupHeaderEventArgs`; the group name is
  /// already closed over by the callback's owner, so only the bounds that the
  /// rename editor positions itself with are passed.
  final void Function(SemiRectangle bounds) onClick;
}

/// `getActionBoundsForGroup` (`data-grid-render.header.ts`): 26px boxes
/// counted back from the right edge of the group header.
List<SemiRectangle> getActionBoundsForGroup(
  SemiRectangle box,
  List<SemiGroupAction> actions,
) {
  final result = <SemiRectangle>[];
  var x = box.x + box.width - 26 * actions.length;
  for (var i = 0; i < actions.length; i++) {
    result.add(
      SemiRectangle(
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
typedef SemiGetRowThemeOverride = SemiThemeOverride? Function(int row);

/// `HoverValues`: `[item, hoverAmount]` pairs.
typedef SemiHoverValues = Map<SemiItem, double>;

/// `Highlight`: overlay range with a color.
@immutable
class SemiDataGridHighlight {
  const SemiDataGridHighlight({
    required this.range,
    required this.color,
    this.style = SemiDataGridHighlightStyle.solidOutline,
  });

  final SemiRectangle range;
  final Color color;
  final SemiDataGridHighlightStyle style;

  @override
  bool operator ==(Object other) =>
      other is SemiDataGridHighlight &&
      other.range == range &&
      other.color == color &&
      other.style == style;

  @override
  int get hashCode => Object.hash(range, color, style);
}

/// `Highlight.style` (`"solid-outline" | "dashed-outline" | "no-outline"`).
enum SemiDataGridHighlightStyle { solidOutline, dashedOutline, noOutline }

/// `DrawGridArg` (`draw-grid-arg.ts:30-83`).
class SemiDrawGridArg {
  const SemiDrawGridArg({
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
    this.disabledRows = const SemiCompactSelection.empty(),
    this.prelightCells,
    this.highlightRegions,
    this.drawHeaderCallback,
    this.drawCellCallback,
    this.fixedShadowX = true,
    this.fixedShadowY = true,
    this.hyperWrapping = false,
    this.enqueue,
    this.minimumCellWidth = 10,
    this.dragAndDropState,
    this.isResizing = false,
    this.resizeColumn,
    this.resizeIndicator = SemiResizeIndicator.full,
    this.imageLoader,
    this.spriteManager,
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
  final List<SemiMappedColumn> mappedColumns;
  final int freezeColumns;
  final int freezeTrailingRows;
  final int rows;
  final SemiRowHeight rowHeight;
  final SemiDataGridTheme theme;
  final SemiGridSelection selection;
  final bool isFocused;
  final bool drawFocus;
  final bool Function(int col) verticalBorder;
  final SemiGridCell Function(SemiItem item) getCellContent;
  final SemiGetCellRenderer getCellRenderer;
  final SemiTextMetrics metrics;
  final SemiGetRowThemeOverride? getRowThemeOverride;
  final SemiGroupDetails Function(String group)? getGroupDetails;
  final SemiHoverValues hoverValues;
  final SemiItem? hoverInfo;
  final Offset? hoverPosition;
  final SemiCellSet? damage;
  final bool hasAppendRow;
  final bool touchMode;
  final SemiFillHandleConfig? fillHandle;
  final SemiCompactSelection disabledRows;
  final List<SemiItem>? prelightCells;
  final List<SemiDataGridHighlight>? highlightRegions;

  /// `drawHeaderCallback` / `drawCellCallback` (`draw-grid-arg.ts:65-66`).
  final SemiDrawHeaderCallback? drawHeaderCallback;
  final SemiDrawCellCallback? drawCellCallback;
  final bool fixedShadowX;
  final bool fixedShadowY;

  final bool hyperWrapping;
  final void Function(SemiItem item)? enqueue;
  final double minimumCellWidth;

  /// `dragAndDropState` (`draw-grid-arg.ts:44`): swaps the two columns in
  /// `getEffectiveColumns` so the preview shows the reordered header.
  final SemiColumnDndState? dragAndDropState;
  final bool isResizing;
  final int? resizeColumn;
  final SemiResizeIndicator resizeIndicator;
  final SemiImageWindowLoader? imageLoader;

  /// `spriteManager` (`draw-grid-arg.ts:74`). Null makes every sprite draw a
  /// no-op, which is what upstream gets from `headerIcons: undefined` merged
  /// with an empty built-in map — see [SemiDataGridProps.headerIcons].
  final SemiSpriteManager? spriteManager;
}
