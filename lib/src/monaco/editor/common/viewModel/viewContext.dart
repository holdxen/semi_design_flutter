// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewModel/viewContext.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `IEditorConfiguration` / `IViewModel` / `IViewLayout` are erased or
//     pending interfaces -> file-local opaque carriers.
//   - `EditorTheme` (concrete) and `IColorTheme` are reused from the port.
// ---------------------------------------------------------------------------

import '../../../platform/theme/common/themeService.dart' show IColorTheme;
import '../editorTheme.dart' show EditorTheme;
import '../viewEventHandler.dart' show ViewEventHandler;

/// 1:1: `IEditorConfiguration` (opaque carrier).
abstract class IEditorConfigurationForViewContext {}

/// 1:1: `IViewLayout` (opaque carrier).
abstract class IViewLayoutForViewContext {}

/// 1:1: `IViewModel` subset used by ViewContext (opaque carrier).
abstract class IViewModelForViewContext {
  IViewLayoutForViewContext get viewLayout;

  void addViewEventHandler(ViewEventHandler eventHandler);

  void removeViewEventHandler(ViewEventHandler eventHandler);
}

/// 1:1: `export class ViewContext`.
class ViewContext {
  final IEditorConfigurationForViewContext configuration;
  late final IViewModelForViewContext viewModel;
  late final IViewLayoutForViewContext viewLayout;
  late final EditorTheme theme;

  ViewContext(
    this.configuration,
    IColorTheme theme,
    IViewModelForViewContext model,
  ) {
    this.theme = EditorTheme(theme);
    viewModel = model;
    viewLayout = model.viewLayout;
  }

  /// 1:1: `public addEventHandler(eventHandler)`.
  void addEventHandler(ViewEventHandler eventHandler) {
    viewModel.addViewEventHandler(eventHandler);
  }

  /// 1:1: `public removeEventHandler(eventHandler)`.
  void removeEventHandler(ViewEventHandler eventHandler) {
    viewModel.removeViewEventHandler(eventHandler);
  }
}
