// Port of `packages/core/src/common/math.ts` (the pieces the editor needs).
import 'package:flutter/foundation.dart';

import '../internal/data_grid/semi_geometry.dart';
import '../internal/data_grid/semi_types.dart';

/// `combineRects` (`math.ts:62-68`).
SemiRectangle combineRects(SemiRectangle a, SemiRectangle b) {
  final x = mathMin(a.x, b.x);
  final y = mathMin(a.y, b.y);
  final width = mathMax(a.x + a.width, b.x + b.width) - x;
  final height = mathMax(a.y + a.height, b.y + b.height) - y;
  return SemiRectangle(x: x, y: y, width: width, height: height);
}

double mathMin(double a, double b) => a < b ? a : b;
double mathMax(double a, double b) => a > b ? a : b;

/// `pointInRect` (`math.ts:58-60`).
bool pointInRect(SemiRectangle rect, double x, double y) =>
    x >= rect.x &&
    x <= rect.x + rect.width &&
    y >= rect.y &&
    y <= rect.y + rect.height;

/// `rectContains` (`math.ts:70-72`).
bool rectContains(SemiRectangle a, SemiRectangle b) =>
    a.x <= b.x &&
    a.y <= b.y &&
    a.x + a.width >= b.x + b.width &&
    a.y + a.height >= b.y + b.height;

/// `getClosestRect` (`math.ts:5-43`): the rectangle that grows [rect] toward
/// `[px, py]` along the nearest allowed edge. Returns null when the point is
/// already inside the rectangle.
SemiRectangle? getClosestRect(
  SemiRectangle rect,
  int px,
  int py,
  SemiFillHandleDirection allowedDirections,
) {
  if (allowedDirections == SemiFillHandleDirection.any) {
    return combineRects(
      rect,
      SemiRectangle(x: px.toDouble(), y: py.toDouble(), width: 1, height: 1),
    );
  }
  var x = px;
  var y = py;
  if (allowedDirections == SemiFillHandleDirection.vertical) x = rect.x.toInt();
  if (allowedDirections == SemiFillHandleDirection.horizontal) {
    y = rect.y.toInt();
  }

  if (itemIsInRect(SemiItem(x, y), rect)) return null;

  final distanceToLeft = x - rect.x;
  final distanceToRight = rect.x + rect.width - x;
  final distanceToTop = y - rect.y + 1;
  final distanceToBottom = rect.y + rect.height - y;

  final unlimited = 1 << 30;
  final minDistance = mathMin(
    mathMin(
      allowedDirections == SemiFillHandleDirection.vertical
          ? unlimited.toDouble()
          : distanceToLeft,
      allowedDirections == SemiFillHandleDirection.vertical
          ? unlimited.toDouble()
          : distanceToRight,
    ),
    mathMin(
      allowedDirections == SemiFillHandleDirection.horizontal
          ? unlimited.toDouble()
          : distanceToTop,
      allowedDirections == SemiFillHandleDirection.horizontal
          ? unlimited.toDouble()
          : distanceToBottom,
    ),
  );

  if (minDistance == distanceToBottom) {
    return SemiRectangle(
      x: rect.x,
      y: rect.y + rect.height,
      width: rect.width,
      height: y - rect.y - rect.height + 1,
    );
  }
  if (minDistance == distanceToTop) {
    return SemiRectangle(
      x: rect.x,
      y: y.toDouble(),
      width: rect.width,
      height: rect.y - y,
    );
  }
  if (minDistance == distanceToRight) {
    return SemiRectangle(
      x: rect.x + rect.width,
      y: rect.y,
      width: x - rect.x - rect.width + 1,
      height: rect.height,
    );
  }
  return SemiRectangle(
    x: x.toDouble(),
    y: rect.y,
    width: rect.x - x,
    height: rect.height,
  );
}

/// `FillPatternEventArgs` (`event-args.ts:124-127`).
@immutable
class SemiFillPatternArgs {
  const SemiFillPatternArgs({
    required this.patternSource,
    required this.fillDestination,
    required this.preventDefault,
  });

  final SemiRectangle patternSource;
  final SemiRectangle fillDestination;
  final void Function() preventDefault;
}
