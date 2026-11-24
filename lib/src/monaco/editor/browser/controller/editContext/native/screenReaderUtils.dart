// 1:1 port of
// vscode/src/vs/editor/browser/controller/editContext/native/screenReaderUtils.ts
//
// The TS file declares a single interface (`IScreenReaderContent`) and has no
// runtime behaviour.
import '../../../../common/config/editorOptions.dart'
    show IComputedEditorOptions;
import '../../../../common/core/selection.dart' show Selection;

/// 1:1: `export interface IScreenReaderContent`.
abstract class IScreenReaderContent {
  void dispose();

  /// Handle screen reader content before cutting the content.
  void onWillCut();

  /// Handle screen reader content before pasting the content.
  void onWillPaste();

  /// Handle focus changes.
  void onFocusChange(bool newFocusValue);

  /// Handle configuration changes.
  void onConfigurationChanged(IComputedEditorOptions options);

  /// Update the screen reader content given the selection. It will update the
  /// content and set the range within the screen reader content if needed.
  void updateScreenReaderContent(Selection primarySelection);

  /// Update the scroll top value of the screen reader content.
  void updateScrollTop(Selection primarySelection);
}
