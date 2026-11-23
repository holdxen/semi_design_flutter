// Port of the geometry helpers in `packages/core/src/common/utils.tsx:51-79`
// plus a few small helpers the editor needs (`toggleBoolean` from
// `data-editor-fns.ts`).
import 'package:flutter/widgets.dart';

import '../internal/data_grid/semi_types.dart';

/// `BoundingBox` (`utils.tsx:77`).
@immutable
class SemiBoundingBox {
  const SemiBoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  final double x1;
  final double y1;
  final double x2;
  final double y2;
}

/// `getSquareBB` (`utils.tsx:51-56`).
SemiBoundingBox getSquareBb(double posX, double posY, double side) =>
    SemiBoundingBox(
      x1: posX - side / 2,
      y1: posY - side / 2,
      x2: posX + side / 2,
      y2: posY + side / 2,
    );

/// `getSquareXPosFromAlign` (`utils.tsx:58-73`).
double getSquareXPosFromAlign(
  SemiContentAlign alignment,
  double containerX,
  double containerWidth,
  double horizontalPadding,
  double squareWidth,
) => switch (alignment) {
  SemiContentAlign.left =>
    containerX.floorToDouble() + horizontalPadding + squareWidth / 2,
  SemiContentAlign.center => (containerX + containerWidth / 2).floorToDouble(),
  SemiContentAlign.right =>
    (containerX + containerWidth).floorToDouble() -
        horizontalPadding -
        squareWidth / 2,
};

/// `getSquareWidth` (`utils.tsx:74-75`).
double getSquareWidth(
  double maxSize,
  double containerHeight,
  double verticalPadding,
) => maxSize < containerHeight - verticalPadding * 2
    ? maxSize
    : containerHeight - verticalPadding * 2;

/// `pointIsWithinBB` (`utils.tsx:78-79`).
bool pointIsWithinBb(double x, double y, SemiBoundingBox bb) =>
    bb.x1 <= x && x <= bb.x2 && bb.y1 <= y && y <= bb.y2;

/// `toggleBoolean` (`data-editor-fns.ts`): empty/indeterminate → checked,
/// checked → unchecked.
SemiBooleanValue toggleBoolean(SemiBooleanValue value) =>
    value == SemiBooleanValue.checked
    ? SemiBooleanValue.unchecked
    : SemiBooleanValue.checked;

/// `clamp` used by selection expansion and scrolling.
double clampDouble(double value, double min, double max) =>
    value < min ? min : (value > max ? max : value);

int clampInt(int value, int min, int max) =>
    value < min ? min : (value > max ? max : value);

/// `isEditableGridCell` (`data-grid-types.ts:221-232`).
bool semiIsEditableGridCell(SemiGridCell cell) => switch (cell.kind) {
  SemiCellKind.loading ||
  SemiCellKind.bubble ||
  SemiCellKind.rowID ||
  SemiCellKind.protected ||
  SemiCellKind.drilldown => false,
  _ => true,
};

/// `isInnerOnlyCell` (`data-grid-types.ts:256-258`): marker and new-row
/// cells exist only inside the grid.
bool semiIsInnerOnlyCell(SemiGridCell cell) =>
    cell.kind == SemiCellKind.marker || cell.kind == SemiCellKind.newRow;

/// `isReadWriteCell` (`data-grid-types.ts:261-275`).
bool semiIsReadWriteCell(SemiGridCell cell) {
  if (!semiIsEditableGridCell(cell) || cell.kind == SemiCellKind.image) {
    return false;
  }
  return switch (cell.kind) {
    SemiCellKind.text ||
    SemiCellKind.number ||
    SemiCellKind.markdown ||
    SemiCellKind.uri ||
    SemiCellKind.custom ||
    SemiCellKind.boolean => !cell.isReadonly,
    // Every remaining kind was filtered out above; upstream reaches
    // `assertNever` here.
    _ => false,
  };
}

/// The string a number cell shows for [value]: `fixedDecimals` when set,
/// otherwise the shortest round-tripping form (so `1234.0` renders `1234`).
String semiNumberToDisplay(num value, int? fixedDecimals) {
  if (fixedDecimals != null) return value.toStringAsFixed(fixedDecimals);
  return value.truncateToDouble() == value
      ? value.toStringAsFixed(0)
      : '$value';
}
