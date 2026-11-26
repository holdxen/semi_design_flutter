// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/marginDecorations/
//   marginDecorations.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `DecorationToRender` / `DedupOverlay` come from `glyphMargin.ts`, which is
//    not yet ported. Their exact 1:1 carriers are reused from
//    `linesDecorations.dart` (same source file) instead of duplicated here.
//  * `ViewContext` is used via a file-local narrow carrier; the member surface
//    read matches the TS source.
//  * TS `render` may return `undefined` for an out-of-range index; Dart's
//    `String` return type maps that to `''` (same as the other overlays).
// ---------------------------------------------------------------------------

import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart' show RenderingContext;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../../common/viewModel.dart' show ViewModelDecoration;
import '../linesDecorations/linesDecorations.dart'
    show
        DecorationToRender,
        LineDecorationToRender,
        VisibleLineDecorationsToRender,
        dedupRender;

/// 1:1: `ViewContext` subset used by this overlay (opaque carrier).
abstract class IMarginDecorationsViewContext {
  void addEventHandler(ViewEventHandler eventHandler);
  void removeEventHandler(ViewEventHandler eventHandler);
}

/// 1:1: `MarginViewLineDecorationsOverlay` from marginDecorations.ts.
class MarginViewLineDecorationsOverlay extends DynamicViewOverlay {
  final IMarginDecorationsViewContext _context;
  List<String>? _renderResult;

  MarginViewLineDecorationsOverlay(this._context) {
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
  bool onDecorationsChanged(Object e) => true;

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

  // --- end event handlers

  List<DecorationToRender> _getDecorations(RenderingContext ctx) {
    final List<ViewModelDecoration> decorations =
        ctx.getDecorationsInViewport();
    final List<DecorationToRender> r = <DecorationToRender>[];
    for (final ViewModelDecoration d in decorations) {
      final dynamic options = d.options;
      final String? marginClassName = options.marginClassName as String?;
      final int? zIndex = options.zIndex as int?;
      if (marginClassName != null) {
        r.add(DecorationToRender(
          d.range.startLineNumber,
          d.range.endLineNumber,
          marginClassName,
          null,
          zIndex,
        ));
      }
    }
    return r;
  }

  @override
  void prepareRender(RenderingContext ctx) {
    final int visibleStartLineNumber = ctx.visibleRange.startLineNumber;
    final int visibleEndLineNumber = ctx.visibleRange.endLineNumber;
    final List<VisibleLineDecorationsToRender> toRender = dedupRender(
      visibleStartLineNumber,
      visibleEndLineNumber,
      _getDecorations(ctx),
    );

    final List<String> output = <String>[];
    for (int lineNumber = visibleStartLineNumber;
        lineNumber <= visibleEndLineNumber;
        lineNumber++) {
      final int lineIndex = lineNumber - visibleStartLineNumber;
      final List<LineDecorationToRender> decorations =
          toRender[lineIndex].getDecorations();
      String lineOutput = '';
      for (final LineDecorationToRender decoration in decorations) {
        lineOutput += '<div class="cmdr ' +
            decoration.className +
            '" style=""></div>';
      }
      output.add(lineOutput);
    }

    _renderResult = output;
  }

  @override
  String render(int startLineNumber, int lineNumber) {
    final List<String>? result = _renderResult;
    if (result == null) {
      return '';
    }
    final int index = lineNumber - startLineNumber;
    if (index < 0 || index >= result.length) return '';
    return result[index];
  }
}
