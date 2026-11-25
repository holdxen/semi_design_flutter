// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/browser/gpu/gpu.ts (41 lines).
//
// `BindingId` (const enum) -> class + static const. `IGpuRenderStrategy` is an
// interface with no runtime and is ERASED per repo convention; its event types
// (`ViewLinesDeletedEvent`, ...) and `GPUBindGroupEntry` are DOM/erased carriers
// that no ported consumer needs yet.
// ---------------------------------------------------------------------------

/// 1:1: `export const enum BindingId`.
class BindingId {
  static const int GlyphInfo = 0;
  static const int Cells = 1;
  static const int TextureSampler = 2;
  static const int Texture = 3;
  static const int LayoutInfoUniform = 4;
  static const int AtlasDimensionsUniform = 5;
  static const int ScrollOffset = 6;

  const BindingId._();
}
