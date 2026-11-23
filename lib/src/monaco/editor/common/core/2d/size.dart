// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/2d/size.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

import './dimension.dart';

class Size2D {
  /// Test if `a` equals `b`. (source: static equals)
  static bool equals(Size2D a, Size2D b) => a.width == b.width && a.height == b.height;

  final num width;
  final num height;

  Size2D(this.width, this.height);

  Size2D add(Size2D other) => Size2D(this.width + other.width, this.height + other.height);

  Size2D deltaX(num delta) => Size2D(this.width + delta, this.height);

  Size2D deltaY(num delta) => Size2D(this.width, this.height + delta);

  @override
  String toString() => '(' + this.width.toString() + ',' + this.height.toString() + ')';

  Size2D subtract(Size2D other) => Size2D(this.width - other.width, this.height - other.height);

  Size2D scale(num factor) => Size2D(this.width * factor, this.height * factor);

  Size2D scaleWidth(num factor) => Size2D(this.width * factor, this.height);

  Size2D mapComponents(num Function(num value) map) => Size2D(map(this.width), map(this.height));

  bool isZero() => this.width == 0 && this.height == 0;

  Size2D transpose() => Size2D(this.height, this.width);

  /// Source returns the object literal `{ width: this.width, height: this.height }`
  /// typed as `IDimension`; Dart carries it with the `Dimension` value class.
  IDimension toDimension() => Dimension(this.width, this.height);
}
