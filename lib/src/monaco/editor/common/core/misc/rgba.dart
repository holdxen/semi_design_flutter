// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/misc/rgba.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

/// A very VM friendly rgba datastructure.
/// Please don't touch unless you take a look at the IR.
class RGBA8 {
  // TS `_rgba8Brand: void = undefined` is a nominal-typing brand with no
  // runtime behaviour in Dart; it is intentionally omitted.

  static final RGBA8 Empty = RGBA8(0, 0, 0, 0);

  /// Red: integer in [0-255]
  final num r;

  /// Green: integer in [0-255]
  final num g;

  /// Blue: integer in [0-255]
  final num b;

  /// Alpha: integer in [0-255]
  final num a;

  RGBA8(num r, num g, num b, num a)
      : r = _clamp(r),
        g = _clamp(g),
        b = _clamp(b),
        a = _clamp(a);

  bool equals(RGBA8 other) {
    return this.r == other.r &&
        this.g == other.g &&
        this.b == other.b &&
        this.a == other.a;
  }

  /// TS: `return c | 0;` coerces to an integer. Dart uses truncation via [toInt].
  static num _clamp(num c) {
    if (c < 0) {
      return 0;
    }
    if (c > 255) {
      return 255;
    }
    return c.toInt();
  }
}
