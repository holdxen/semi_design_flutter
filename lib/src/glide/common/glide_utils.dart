// Port of the geometry helpers in `packages/core/src/common/utils.tsx:51-79`
// plus a few small helpers the editor needs (`toggleBoolean` from
// `data-editor-fns.ts`).
import 'package:flutter/widgets.dart';

import '../internal/data_grid/glide_types.dart';

/// `BoundingBox` (`utils.tsx:77`).
@immutable
class GlideBoundingBox {
  const GlideBoundingBox({
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
GlideBoundingBox getSquareBb(double posX, double posY, double side) =>
    GlideBoundingBox(
      x1: posX - side / 2,
      y1: posY - side / 2,
      x2: posX + side / 2,
      y2: posY + side / 2,
    );

/// `getSquareXPosFromAlign` (`utils.tsx:58-73`).
double getSquareXPosFromAlign(
  GlideContentAlign alignment,
  double containerX,
  double containerWidth,
  double horizontalPadding,
  double squareWidth,
) => switch (alignment) {
  GlideContentAlign.left =>
    containerX.floorToDouble() + horizontalPadding + squareWidth / 2,
  GlideContentAlign.center => (containerX + containerWidth / 2).floorToDouble(),
  GlideContentAlign.right =>
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
bool pointIsWithinBb(double x, double y, GlideBoundingBox bb) =>
    bb.x1 <= x && x <= bb.x2 && bb.y1 <= y && y <= bb.y2;

/// `toggleBoolean` (`data-editor-fns.ts`): empty/indeterminate → checked,
/// checked → unchecked.
GlideBooleanValue toggleBoolean(GlideBooleanValue value) =>
    value == GlideBooleanValue.checked
    ? GlideBooleanValue.unchecked
    : GlideBooleanValue.checked;

/// `clamp` used by selection expansion and scrolling.
double clampDouble(double value, double min, double max) =>
    value < min ? min : (value > max ? max : value);

int clampInt(int value, int min, int max) =>
    value < min ? min : (value > max ? max : value);
