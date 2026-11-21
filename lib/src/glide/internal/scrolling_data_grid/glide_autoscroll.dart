// Port of `packages/core/src/data-editor/use-autoscroll.ts`.
//
// Upstream runs a `requestAnimationFrame` loop while the pointer sits on a
// viewport edge during a drag. Flutter gives us a `Ticker` instead, so the
// ramp is driven by [GlideAutoscroll.advance] with the elapsed time between
// frames.
import 'dart:math' as math;

class GlideAutoscroll {
  static const double maxPxPerMs = 2;
  static const double msToFullSpeed = 1300;

  double _speedScalar = 0;
  int xDir = 0;
  int yDir = 0;

  bool get isActive => xDir != 0 || yDir != 0;

  /// `scrollDirection` (`use-autoscroll.ts:13`).
  void setDirection(int x, int y) {
    if (x == 0 && y == 0) _speedScalar = 0;
    xDir = x;
    yDir = y;
  }

  /// The scroll delta for a frame of [dtMs]; mirrors the ramp in
  /// `use-autoscroll.ts:20-32`.
  (double, double) advance(double dtMs) {
    if (!isActive || dtMs <= 0) return (0, 0);
    _speedScalar = math.min(1, _speedScalar + dtMs / msToFullSpeed);
    final motion = math.pow(_speedScalar, 1.618) * dtMs * maxPxPerMs;
    return (xDir * motion, yDir * motion);
  }
}
