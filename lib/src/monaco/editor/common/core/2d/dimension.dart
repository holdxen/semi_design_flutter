// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/2d/dimension.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

/// Source: `export interface IDimension { width: number; height: number; }`
abstract class IDimension {
  num get width;
  num get height;
}

// Dart has no structural object literals. The TS `{ width, height }` value
// returned by e.g. `Size2D.toDimension()` is carried by this value class, which
// implements the source interface without adding fields or behaviour.
class Dimension implements IDimension {
  @override
  final num width;

  @override
  final num height;

  const Dimension(this.width, this.height);
}
