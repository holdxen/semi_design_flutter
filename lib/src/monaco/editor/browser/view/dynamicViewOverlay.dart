// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/view/dynamicViewOverlay.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c (15 lines)
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import '../../common/viewEventHandler.dart' show ViewEventHandler;
import 'renderingContext.dart' show RenderingContext;

/// 1:1: `export abstract class DynamicViewOverlay extends ViewEventHandler`.
abstract class DynamicViewOverlay extends ViewEventHandler {
  /// 1:1: `public abstract prepareRender(ctx: RenderingContext): void`
  void prepareRender(RenderingContext ctx);

  /// 1:1: `public abstract render(startLineNumber: number, lineNumber: number): string`
  String render(int startLineNumber, int lineNumber);
}
