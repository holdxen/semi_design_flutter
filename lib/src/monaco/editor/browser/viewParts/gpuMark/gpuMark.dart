// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/gpuMark/gpuMark.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `ViewContext` / `ViewGpuContext` / `ViewLineOptions` are used through
//    file-local narrow carriers except `ViewLineOptions`, which is the real
//    ported class. The member surface read matches the TS source.
//  * `canRenderDetailed` returns a list of opaque reason strings; no GPU
//    runtime is needed to replay the overlay logic.
// ---------------------------------------------------------------------------

import '../../../../platform/theme/common/theme.dart' show ColorScheme;
import '../../../common/config/editorConfiguration.dart'
    show IEditorConfiguration;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart' show RenderingContext;
import '../viewLines/viewLineOptions.dart' show ViewLineOptions;

/// 1:1: `ITheme` subset used by this overlay.
abstract class IGpuMarkTheme {
  ColorScheme get type;
}

/// 1:1: `ViewContext` subset used by this overlay (opaque carrier).
abstract class IGpuMarkViewContext {
  IEditorConfiguration get configuration;
  IGpuMarkTheme get theme;
  void addEventHandler(ViewEventHandler eventHandler);
  void removeEventHandler(ViewEventHandler eventHandler);
}

/// 1:1: `ViewGpuContext` subset used by this overlay (opaque carrier).
abstract class IGpuMarkGpuContext {
  List<String> canRenderDetailed(
    ViewLineOptions options,
    Object? viewportData,
    int lineNumber,
  );
}

/// 1:1: `GpuMarkOverlay` from gpuMark.ts.
class GpuMarkOverlay extends DynamicViewOverlay {
  static const String CLASS_NAME = 'gpu-mark';

  final IGpuMarkViewContext _context;
  final IGpuMarkGpuContext _viewGpuContext;
  List<String>? _renderResult;

  GpuMarkOverlay(this._context, this._viewGpuContext) {
    _renderResult = null;
    _context.addEventHandler(this);
  }

  @override
  void dispose() {
    _context.removeEventHandler(this);
    _renderResult = null;
    super.dispose();
  }

  // --- begin event handlers

  @override
  bool onConfigurationChanged(Object e) => true;

  @override
  bool onCursorStateChanged(Object e) => true;

  @override
  bool onFlushed(Object e) => true;

  @override
  bool onLinesChanged(Object e) => true;

  @override
  bool onLinesDeleted(Object e) => true;

  @override
  bool onLinesInserted(Object e) => true;

  @override
  bool onScrollChanged(Object e) =>
      e is Map && e['scrollTopChanged'] == true;

  @override
  bool onZonesChanged(Object e) => true;

  @override
  bool onDecorationsChanged(Object e) => true;

  // --- end event handlers

  @override
  void prepareRender(RenderingContext ctx) {
    final int visibleStartLineNumber = ctx.visibleRange.startLineNumber;
    final int visibleEndLineNumber = ctx.visibleRange.endLineNumber;

    final Object viewportData = ctx.viewportData;
    final ViewLineOptions options =
        ViewLineOptions(_context.configuration, _context.theme.type);

    final List<String> output = <String>[];
    for (int lineNumber = visibleStartLineNumber;
        lineNumber <= visibleEndLineNumber;
        lineNumber++) {
      final List<String> cannotRenderReasons = _viewGpuContext
          .canRenderDetailed(options, viewportData, lineNumber);
      output.add(cannotRenderReasons.isEmpty
          ? ''
          : '<div class="${GpuMarkOverlay.CLASS_NAME}" '
              'title="Cannot render on GPU: ${cannotRenderReasons.join(', ')}">'
              '</div>');
    }

    _renderResult = output;
  }

  @override
  String render(int startLineNumber, int lineNumber) {
    final List<String>? result = _renderResult;
    if (result == null) {
      return '';
    }
    final int lineIndex = lineNumber - startLineNumber;
    if (lineIndex < 0 || lineIndex >= result.length) {
      return '';
    }
    return result[lineIndex];
  }
}
