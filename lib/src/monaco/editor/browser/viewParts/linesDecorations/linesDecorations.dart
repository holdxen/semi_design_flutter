// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/linesDecorations/
//   linesDecorations.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `DedupOverlay` / `DecorationToRender` / `LineDecorationToRender` /
//    `VisibleLineDecorationsToRender` come from `glyphMargin.ts`, which is not
//    yet ported; their exact logic is carried locally (1:1) so this overlay can
//    be replayed. When glyphMargin.ts lands, these carriers can be swapped.
//  * ViewContext / IEditorConfiguration / RenderingContext are used via
//    file-local narrow carriers; the member surface read matches the TS source.
//  * JS `number.toString()` uses `_jsNum` to avoid trailing `.0`.
// ---------------------------------------------------------------------------

import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart' show RenderingContext;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/viewModel.dart' show ViewModelDecoration;

/// JS number-to-string (no trailing `.0` for integral doubles).
String _jsNum(num value) {
  if (value is int) return value.toString();
  if (value == value.truncate()) return value.toInt().toString();
  return value.toString();
}

/// 1:1: `IEditorConfiguration.options` subset read here.
abstract class ILinesDecorationsEditorOptions {
  Object? get(Object id);
}

/// 1:1: `IEditorConfiguration` subset read here (opaque carrier).
abstract class ILinesDecorationsConfiguration {
  ILinesDecorationsEditorOptions get options;
}

/// 1:1: `ViewContext` subset used by this overlay (opaque carrier).
abstract class ILinesDecorationsViewContext {
  ILinesDecorationsConfiguration get configuration;
  void addEventHandler(ViewEventHandler eventHandler);
  void removeEventHandler(ViewEventHandler eventHandler);
}

// --- carriers from glyphMargin.ts (1:1) ---

/// 1:1: `DecorationToRender`.
class DecorationToRender {
  final int startLineNumber;
  final int endLineNumber;
  final String className;
  final String? tooltip;
  final int zIndex;

  DecorationToRender(
    this.startLineNumber,
    this.endLineNumber,
    this.className,
    this.tooltip,
    int? zIndex,
  )   : zIndex = zIndex ?? 0;
}

/// 1:1: `LineDecorationToRender`.
class LineDecorationToRender {
  final String className;
  final int zIndex;
  final String? tooltip;

  LineDecorationToRender(this.className, this.zIndex, this.tooltip);
}

/// 1:1: `VisibleLineDecorationsToRender`.
class VisibleLineDecorationsToRender {
  final List<LineDecorationToRender> _decorations =
      <LineDecorationToRender>[];

  void add(LineDecorationToRender decoration) => _decorations.add(decoration);

  List<LineDecorationToRender> getDecorations() => _decorations;
}

/// 1:1: `DedupOverlay._render` from glyphMargin.ts, carried locally.
List<VisibleLineDecorationsToRender> dedupRender(
  int visibleStartLineNumber,
  int visibleEndLineNumber,
  List<DecorationToRender> decorations,
) {
  final List<VisibleLineDecorationsToRender> output =
      <VisibleLineDecorationsToRender>[];
  for (int lineNumber = visibleStartLineNumber;
      lineNumber <= visibleEndLineNumber;
      lineNumber++) {
    output.add(VisibleLineDecorationsToRender());
  }

  if (decorations.isEmpty) {
    return output;
  }

  // Sort by className, then startLineNumber, then endLineNumber.
  final List<DecorationToRender> sorted = List<DecorationToRender>.from(
    decorations,
  );
  sorted.sort((DecorationToRender a, DecorationToRender b) {
    if (a.className == b.className) {
      if (a.startLineNumber == b.startLineNumber) {
        return a.endLineNumber - b.endLineNumber;
      }
      return a.startLineNumber - b.startLineNumber;
    }
    return a.className.compareTo(b.className) < 0 ? -1 : 1;
  });

  String? prevClassName;
  int prevEndLineIndex = 0;
  for (final DecorationToRender d in sorted) {
    final String className = d.className;
    final int zIndex = d.zIndex;
    int startLineIndex = _max(d.startLineNumber, visibleStartLineNumber) -
        visibleStartLineNumber;
    int endLineIndex = _min(d.endLineNumber, visibleEndLineNumber) -
        visibleStartLineNumber;

    if (prevClassName == className) {
      startLineIndex = _max(prevEndLineIndex + 1, startLineIndex);
      prevEndLineIndex = _max(prevEndLineIndex, endLineIndex);
    } else {
      prevClassName = className;
      prevEndLineIndex = endLineIndex;
    }

    for (int lineIndex = startLineIndex;
        lineIndex <= prevEndLineIndex;
        lineIndex++) {
      output[lineIndex].add(
        LineDecorationToRender(className, zIndex, d.tooltip),
      );
    }
  }

  return output;
}

int _max(int a, int b) => a > b ? a : b;
int _min(int a, int b) => a < b ? a : b;

/// The lines decorations overlay renders CSS classes along view lines.
class LinesDecorationsOverlay extends DynamicViewOverlay {
  final ILinesDecorationsViewContext _context;
  int _decorationsLeft;
  int _decorationsWidth;
  List<String>? _renderResult;

  LinesDecorationsOverlay(this._context)
      : _decorationsLeft = _readLeft(_context.configuration),
        _decorationsWidth = _readWidth(_context.configuration) {
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
  bool onConfigurationChanged(Object e) {
    _decorationsLeft = _readLeft(_context.configuration);
    _decorationsWidth = _readWidth(_context.configuration);
    return true;
  }

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
    final List<DecorationToRender> result = <DecorationToRender>[];
    for (final ViewModelDecoration d in decorations) {
      final dynamic options = d.options;
      final String? linesDecorationsClassName =
          options.linesDecorationsClassName as String?;
      final int? zIndex = options.zIndex as int?;
      if (linesDecorationsClassName != null) {
        result.add(DecorationToRender(
          d.range.startLineNumber,
          d.range.endLineNumber,
          linesDecorationsClassName,
          options.linesDecorationsTooltip as String?,
          zIndex,
        ));
      }
      final String? firstLineDecorationClassName =
          options.firstLineDecorationClassName as String?;
      if (firstLineDecorationClassName != null) {
        result.add(DecorationToRender(
          d.range.startLineNumber,
          d.range.startLineNumber,
          firstLineDecorationClassName,
          options.linesDecorationsTooltip as String?,
          zIndex,
        ));
      }
    }
    return result;
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

    final String left = _jsNum(_decorationsLeft);
    final String width = _jsNum(_decorationsWidth);
    const String common = '" style="left:';

    final List<String> output = <String>[];
    for (int lineNumber = visibleStartLineNumber;
        lineNumber <= visibleEndLineNumber;
        lineNumber++) {
      final int lineIndex = lineNumber - visibleStartLineNumber;
      final List<LineDecorationToRender> decorations =
          toRender[lineIndex].getDecorations();
      String lineOutput = '';
      for (final LineDecorationToRender decoration in decorations) {
        String addition = '<div class="cldr ${decoration.className}';
        if (decoration.tooltip != null) {
          // The tooltip is already escaped.
          addition += '" title="${decoration.tooltip}';
        }
        addition += common + left + 'px;width:' + width + 'px;"></div>';
        lineOutput += addition;
      }
      output.add(lineOutput);
    }
    this._renderResult = output;
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

int _readLeft(ILinesDecorationsConfiguration config) {
  final Object? layoutInfo =
      config.options.get(EditorOption.layoutInfo);
  return layoutInfo == null
      ? 0
      : (layoutInfo as dynamic).decorationsLeft as int;
}

int _readWidth(ILinesDecorationsConfiguration config) {
  final Object? layoutInfo =
      config.options.get(EditorOption.layoutInfo);
  return layoutInfo == null
      ? 0
      : (layoutInfo as dynamic).decorationsWidth as int;
}
