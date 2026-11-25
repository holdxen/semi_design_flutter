// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/editorMarkdownSanitizer.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * `ICodeEditor` is reduced to the single `getOption` member actually read.
//  * `MarkdownSanitizerConfig` carrier comes from base/browser/markdownRenderer.
// ---------------------------------------------------------------------------
import '../../base/browser/markdownRenderer.dart' show MarkdownSanitizerConfig;
import '../common/config/editorOptions.dart'
    show EditorMarkdownImagesOptions, EditorOption, isMarkdownImageAllowed;

/// 1:1: `ICodeEditor.getOption` member (erased interface).
abstract class IEditorForMarkdownSanitizer {
  Object? getOption(Object? id);
}

/// 1:1: `export function getEditorMarkdownSanitizerConfig(editor)`.
MarkdownSanitizerConfig? getEditorMarkdownSanitizerConfig(
    IEditorForMarkdownSanitizer editor) {
  final EditorMarkdownImagesOptions options =
      editor.getOption(EditorOption.markdownImages) as EditorMarkdownImagesOptions;
  if (options.allowedOrigins == true) {
    return null;
  }
  return MarkdownSanitizerConfig(
    // Keep the URL encoded: decoding it can change its authority (`%2F`
    // becomes `/`) and thus its origin.
    remoteImageIsAllowed: (uri) =>
        isMarkdownImageAllowed(options, uri.toString()),
  );
}
