// Port of `packages/core/src/cells/boolean-cell.tsx`.
import 'package:flutter/widgets.dart';

import '../common/semi_utils.dart';
import '../internal/data_grid/render/semi_draw_checkbox.dart';
import 'semi_cell_types.dart';

/// `isOverEditableRegion` (`boolean-cell.tsx:15-38`).
bool isOverEditableBooleanRegion({
  required SemiBooleanCell cell,
  required double posX,
  required double posY,
  required SemiRectangle bounds,
  required SemiDataGridTheme theme,
}) {
  final width = bounds.width;
  final height = bounds.height;
  final cellX = bounds.x;
  final cellY = bounds.y;
  final maxWidth = cell.maxSize ?? theme.checkboxMaxSize;
  final cellCenterY = (bounds.y + height / 2).floorToDouble();
  final checkBoxWidth = getSquareWidth(
    maxWidth,
    height,
    theme.cellVerticalPadding,
  );
  final x = getSquareXPosFromAlign(
    cell.contentAlign ?? SemiContentAlign.center,
    cellX,
    width,
    theme.cellHorizontalPadding,
    checkBoxWidth,
  );
  final bb = getSquareBb(x, cellCenterY, checkBoxWidth);
  final checkBoxClicked = pointIsWithinBb(
    cellX + posX,
    cellY + posY,
    bb,
  );
  return cell.isEditable && checkBoxClicked;
}

/// `booleanCellRenderer` (`boolean-cell.tsx:40-89`).
class SemiBooleanCellRenderer extends SemiCellRenderer {
  const SemiBooleanCellRenderer();

  @override
  SemiCellKind get kind => SemiCellKind.boolean;

  @override
  bool get needsHover => true;

  @override
  bool get needsHoverPosition => true;

  @override
  double? measure(
    SemiGridCell cell,
    SemiDataGridTheme theme,
    SemiTextMetrics metrics,
  ) => 50;

  @override
  void draw(SemiDrawCellArgs args) {
    final cell = args.cell as SemiBooleanCell;
    drawBoolean(
      args,
      cell.data,
      cell.isEditable,
      cell.maxSize ?? args.theme.checkboxMaxSize,
      cell.hoverEffectIntensity ?? 0.35,
    );
  }

  /// `drawBoolean` (`boolean-cell.tsx:91-135`).
  void drawBoolean(
    SemiDrawCellArgs args,
    SemiBooleanValue data,
    bool canEdit,
    double maxSize,
    double hoverEffectIntensity,
  ) {
    if (!canEdit && data == SemiBooleanValue.empty) return;

    final rect = args.rect;
    final theme = args.theme;
    var alpha = 1.0;

    if (hoverEffectIntensity > 0) {
      alpha = canEdit
          ? 1 - hoverEffectIntensity + hoverEffectIntensity * args.hoverAmount
          : 0.4;
      if (data == SemiBooleanValue.empty) alpha *= args.hoverAmount;
      if (alpha == 0) return;
    }

    final canvas = args.canvas;
    final needsAlpha = alpha < 1;
    if (needsAlpha) {
      canvas.saveLayer(
        Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
      );
    }

    drawCheckbox(
      canvas,
      theme,
      data,
      rect.x,
      rect.y,
      rect.width,
      rect.height,
      highlighted: args.highlighted,
      hoverX: args.hoverX ?? -20,
      hoverY: args.hoverY ?? -20,
      maxSize: maxSize,
      alignment: (args.cell as SemiBooleanCell).contentAlign ??
          SemiContentAlign.center,
    );

    if (needsAlpha) canvas.restore();
  }

  /// `onDelete` (`boolean-cell.tsx:55-58`).
  @override
  SemiGridCell? onDelete(SemiGridCell cell) =>
      (cell as SemiBooleanCell).copyWith(data: SemiBooleanValue.unchecked);

  /// `onSelect` (`boolean-cell.tsx:59-63`).
  @override
  void onSelect(SemiCellEventArgs args) {
    final cell = args.cell as SemiBooleanCell;
    if (isOverEditableBooleanRegion(
      cell: cell,
      posX: args.posX,
      posY: args.posY,
      bounds: args.bounds,
      theme: args.theme,
    )) {
      args.preventDefault?.call();
    }
  }

  /// `onClick` (`boolean-cell.tsx:64-72`): toggling a boolean commits without
  /// opening an overlay.
  @override
  SemiGridCell? onClick(SemiCellEventArgs args) {
    final cell = args.cell as SemiBooleanCell;
    if (isOverEditableBooleanRegion(
      cell: cell,
      posX: args.posX,
      posY: args.posY,
      bounds: args.bounds,
      theme: args.theme,
    )) {
      return cell.copyWith(data: toggleBoolean(cell.data));
    }
    return null;
  }

  /// `onPaste` (`boolean-cell.tsx:73-88`).
  @override
  SemiGridCell? onPaste(
    String toPaste,
    SemiGridCell cell,
    SemiPasteDetails details,
  ) {
    final booleanCell = cell as SemiBooleanCell;
    final lower = toPaste.toLowerCase();
    final newVal = switch (lower) {
      'true' => SemiBooleanValue.checked,
      'false' => SemiBooleanValue.unchecked,
      'indeterminate' => SemiBooleanValue.indeterminate,
      _ => SemiBooleanValue.empty,
    };
    if (newVal == booleanCell.data) return null;
    return booleanCell.copyWith(data: newVal);
  }

  @override
  String getAccessibilityString(SemiGridCell cell) {
    final value = (cell as SemiBooleanCell).data;
    return switch (value) {
      SemiBooleanValue.checked => 'true',
      SemiBooleanValue.indeterminate => 'indeterminate',
      _ => 'false',
    };
  }
}
