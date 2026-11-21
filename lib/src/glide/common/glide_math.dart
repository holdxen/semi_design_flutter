// Port of `packages/core/src/common/math.ts` (the pieces the editor needs).
import 'package:flutter/foundation.dart';

import '../internal/data_grid/glide_geometry.dart';
import '../internal/data_grid/glide_types.dart';

/// `combineRects` (`math.ts:62-68`).
GlideRectangle combineRects(GlideRectangle a, GlideRectangle b) {
  final x = mathMin(a.x, b.x);
  final y = mathMin(a.y, b.y);
  final width = mathMax(a.x + a.width, b.x + b.width) - x;
  final height = mathMax(a.y + a.height, b.y + b.height) - y;
  return GlideRectangle(x: x, y: y, width: width, height: height);
}

double mathMin(double a, double b) => a < b ? a : b;
double mathMax(double a, double b) => a > b ? a : b;

/// `pointInRect` (`math.ts:58-60`).
bool pointInRect(GlideRectangle rect, double x, double y) =>
    x >= rect.x &&
    x <= rect.x + rect.width &&
    y >= rect.y &&
    y <= rect.y + rect.height;

/// `rectContains` (`math.ts:70-72`).
bool rectContains(GlideRectangle a, GlideRectangle b) =>
    a.x <= b.x &&
    a.y <= b.y &&
    a.x + a.width >= b.x + b.width &&
    a.y + a.height >= b.y + b.height;

/// `getClosestRect` (`math.ts:5-43`): the rectangle that grows [rect] toward
/// `[px, py]` along the nearest allowed edge. Returns null when the point is
/// already inside the rectangle.
GlideRectangle? getClosestRect(
  GlideRectangle rect,
  int px,
  int py,
  GlideFillHandleDirection allowedDirections,
) {
  if (allowedDirections == GlideFillHandleDirection.any) {
    return combineRects(
      rect,
      GlideRectangle(x: px.toDouble(), y: py.toDouble(), width: 1, height: 1),
    );
  }
  var x = px;
  var y = py;
  if (allowedDirections == GlideFillHandleDirection.vertical) x = rect.x.toInt();
  if (allowedDirections == GlideFillHandleDirection.horizontal) {
    y = rect.y.toInt();
  }

  if (itemIsInRect(GlideItem(x, y), rect)) return null;

  final distanceToLeft = x - rect.x;
  final distanceToRight = rect.x + rect.width - x;
  final distanceToTop = y - rect.y + 1;
  final distanceToBottom = rect.y + rect.height - y;

  final unlimited = 1 << 30;
  final minDistance = mathMin(
    mathMin(
      allowedDirections == GlideFillHandleDirection.vertical
          ? unlimited.toDouble()
          : distanceToLeft,
      allowedDirections == GlideFillHandleDirection.vertical
          ? unlimited.toDouble()
          : distanceToRight,
    ),
    mathMin(
      allowedDirections == GlideFillHandleDirection.horizontal
          ? unlimited.toDouble()
          : distanceToTop,
      allowedDirections == GlideFillHandleDirection.horizontal
          ? unlimited.toDouble()
          : distanceToBottom,
    ),
  );

  if (minDistance == distanceToBottom) {
    return GlideRectangle(
      x: rect.x,
      y: rect.y + rect.height,
      width: rect.width,
      height: y - rect.y - rect.height + 1,
    );
  }
  if (minDistance == distanceToTop) {
    return GlideRectangle(
      x: rect.x,
      y: y.toDouble(),
      width: rect.width,
      height: rect.y - y,
    );
  }
  if (minDistance == distanceToRight) {
    return GlideRectangle(
      x: rect.x + rect.width,
      y: rect.y,
      width: x - rect.x - rect.width + 1,
      height: rect.height,
    );
  }
  return GlideRectangle(
    x: x.toDouble(),
    y: rect.y,
    width: rect.x - x,
    height: rect.height,
  );
}

/// `FillPatternEventArgs` (`event-args.ts:124-127`).
@immutable
class GlideFillPatternArgs {
  const GlideFillPatternArgs({
    required this.patternSource,
    required this.fillDestination,
    required this.preventDefault,
  });

  final GlideRectangle patternSource;
  final GlideRectangle fillDestination;
  final void Function() preventDefault;
}
