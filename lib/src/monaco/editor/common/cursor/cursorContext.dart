// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/cursor/cursorContext.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c (24 lines)
// Translated 1:1 from TypeScript.
//
// Adaptations:
//   - `ITextModel` and the `cursorCommon.ts` pair (`ICursorSimpleModel`,
//     `CursorConfiguration`) are not ported yet -> opaque carriers here.
//   - `ICoordinatesConverter` is reused from the ported coordinatesConverter.
//   - `_cursorContextBrand` is a TypeScript-only brand field with no runtime
//     meaning; omitted (unused private fields would warn in Dart).
// ---------------------------------------------------------------------------

import '../coordinatesConverter.dart' show ICoordinatesConverter;

/// 1:1: `ITextModel` (opaque carrier).
abstract class ITextModelForCursorContext {}

/// 1:1: `ICursorSimpleModel` (opaque carrier).
abstract class ICursorSimpleModelForCursorContext {}

/// 1:1: `CursorConfiguration` (opaque carrier until cursorCommon.ts lands).
abstract class CursorConfigurationForCursorContext {}

/// 1:1: `export class CursorContext`.
class CursorContext {
  /// 1:1: `public readonly model: ITextModel`
  final ITextModelForCursorContext model;

  /// 1:1: `public readonly viewModel: ICursorSimpleModel`
  final ICursorSimpleModelForCursorContext viewModel;

  /// 1:1: `public readonly coordinatesConverter: ICoordinatesConverter`
  final ICoordinatesConverter coordinatesConverter;

  /// 1:1: `public readonly cursorConfig: CursorConfiguration`
  final CursorConfigurationForCursorContext cursorConfig;

  CursorContext(
    this.model,
    this.viewModel,
    this.coordinatesConverter,
    this.cursorConfig,
  );
}
