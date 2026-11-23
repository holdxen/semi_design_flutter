// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/2d/point.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

class Point {
  /// Test if `a` equals `b`. (source: static equals)
  static bool equals(Point a, Point b) => a.x == b.x && a.y == b.y;

  final num x;
  final num y;

  Point(this.x, this.y);

  Point add(Point other) => Point(this.x + other.x, this.y + other.y);

  Point deltaX(num delta) => Point(this.x + delta, this.y);

  Point deltaY(num delta) => Point(this.x, this.y + delta);

  @override
  String toString() => '(' + this.x.toString() + ',' + this.y.toString() + ')';

  Point subtract(Point other) => Point(this.x - other.x, this.y - other.y);

  Point scale(num factor) => Point(this.x * factor, this.y * factor);

  Point mapComponents(num Function(num value) map) => Point(map(this.x), map(this.y));

  bool isZero() => this.x == 0 && this.y == 0;

  Point withThreshold(num threshold) {
    return this.mapComponents((num axisVal) {
      if (axisVal > threshold) {
        return axisVal - threshold;
      } else if (axisVal < -threshold) {
        return axisVal + threshold;
      }
      return 0;
    });
  }
}
