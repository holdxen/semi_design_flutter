// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/browser/controller/common.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c (17 lines)
// Translated 1:1 from TypeScript.
//
// Adaptations:
//   - `ICodeEditor` / `InlineCompletionsController` come from pending modules;
//     both are erased to `Object` (the source only passes them through).
//   - The module-level getter slot is nullable; `?.call() ?? null` collapses to
//     `?.call()` in Dart because the call already yields `Object?`.
// ---------------------------------------------------------------------------

Object? Function(Object editor)? _getInlineCompletionsController;

/// 1:1: `export function getInlineCompletionsController(editor)`
Object? getInlineCompletionsController(Object editor) {
  return _getInlineCompletionsController?.call(editor);
}

/// 1:1: `export function setInlineCompletionsControllerGetter(getter)`
void setInlineCompletionsControllerGetter(
  Object? Function(Object editor) getter,
) {
  _getInlineCompletionsController = getter;
}
