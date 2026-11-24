// 1:1 port of vscode/src/vs/editor/common/config/editorConfiguration.ts
//
// The TS file declares a single interface (`IEditorConfiguration`); nothing
// runs at runtime. The Dart port is therefore one abstract class with the
// same member surface, `implements IDisposable` included.
import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../platform/actions/common/actions.dart' show MenuId;
import '../core/2d/dimension.dart' show IDimension;
import './editorOptions.dart'
    show ConfigurationChangedEvent, IComputedEditorOptions, IEditorOptions;

/// 1:1: `export interface IEditorConfiguration extends IDisposable`.
abstract class IEditorConfiguration implements lifecycle.IDisposable {
  /// Is this a simple widget (not a real code editor)?
  bool get isSimpleWidget;

  /// The context menu id for the editor.
  MenuId get contextMenuId;

  /// Computed editor options.
  IComputedEditorOptions get options;

  /// The `options` have changed (quick event).
  Event<ConfigurationChangedEvent> get onDidChangeFast;

  /// The `options` have changed (slow event).
  Event<ConfigurationChangedEvent> get onDidChange;

  /// Get the raw options as they were passed in to the editor
  /// and merged with all calls to `updateOptions`.
  IEditorOptions getRawOptions();

  /// Update the options with new partial options. All previous
  /// options will be kept and only present keys will be overwritten.
  void updateOptions(IEditorOptions newOptions);

  /// Recompute options with new reference element dimensions.
  void observeContainer([IDimension? dimension]);

  /// Set if the current model is dominated by long lines.
  void setIsDominatedByLongLines(bool isDominatedByLongLines);

  /// Set the current model line count.
  void setModelLineCount(int modelLineCount);

  /// Set the current view model line count.
  void setViewLineCount(int viewLineCount);

  /// Set reserved height above.
  void setReservedHeight(num reservedHeight);

  /// Set the number of decoration lanes to be rendered in the glyph margin.
  void setGlyphMarginDecorationLaneCount(int decorationLaneCount);
}
