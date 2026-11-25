// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/decorations/decorations.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * ViewContext / IEditorConfiguration are used via file-local narrow
//    carriers; the member surface read matches the TS source.
//  * `HorizontalRange` / `LineVisibleRanges` / `Range` / `ViewModelDecoration`
//    are reused from the real port. `Range` statics map to named Dart methods.
//  * JS `String(number)` uses `_jsNum` to avoid trailing `.0`.
// ---------------------------------------------------------------------------

import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart'
    show HorizontalRange, LineVisibleRanges, RenderingContext;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/core/range.dart' show Range;
import '../../../common/viewModel.dart' show ViewModelDecoration;

/// JS `String(number)` (no trailing `.0` for integral doubles).
String _jsNum(num value) {
  if (value is int) return value.toString();
  if (value == value.truncate()) return value.toInt().toString();
  return value.toString();
}

/// JS `Math.round` (floor(x + 0.5)).
num _jsRound(num value) => (value + 0.5).floor();

/// 1:1: `IEditorConfiguration.options` subset read here.
abstract class IDecorationsEditorOptions {
  Object? get(Object id);
}

/// 1:1: `IEditorConfiguration` subset read here (opaque carrier).
abstract class IDecorationsConfiguration {
  IDecorationsEditorOptions get options;
}

/// 1:1: `ViewContext` subset used by this overlay (opaque carrier).
abstract class IDecorationsViewContext {
  IDecorationsConfiguration get configuration;
  Object get viewModel;
  void addEventHandler(ViewEventHandler eventHandler);
  void removeEventHandler(ViewEventHandler eventHandler);
}

/// The decorations overlay renders CSS classes for view-model decorations.
class DecorationsOverlay extends DynamicViewOverlay {
  final IDecorationsViewContext _context;
  num _typicalHalfwidthCharacterWidth;
  List<String>? _renderResult;

  DecorationsOverlay(this._context)
      : _typicalHalfwidthCharacterWidth =
            _readHalfWidth(_context.configuration) {
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
    _typicalHalfwidthCharacterWidth = _readHalfWidth(_context.configuration);
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
      e is Map &&
      (e['scrollTopChanged'] == true || e['scrollWidthChanged'] == true);

  @override
  bool onZonesChanged(Object e) => true;

  // --- end event handlers

  @override
  void prepareRender(RenderingContext ctx) {
    final List<ViewModelDecoration> source = ctx.getDecorationsInViewport();

    // Keep only decorations with `className`.
    final List<ViewModelDecoration> decorations =
        <ViewModelDecoration>[];
    for (final ViewModelDecoration d in source) {
      if (_opts(d).className != null) {
        decorations.add(d);
      }
    }

    // Sort for consistent render output: zIndex, className, then range starts.
    decorations.sort((ViewModelDecoration a, ViewModelDecoration b) {
      final num? az = _opts(a).zIndex as num?;
      final num? bz = _opts(b).zIndex as num?;
      final int azi = az?.toInt() ?? 0;
      final int bzi = bz?.toInt() ?? 0;
      if (azi < bzi) return -1;
      if (azi > bzi) return 1;
      final String ac = _opts(a).className as String;
      final String bc = _opts(b).className as String;
      if (ac.compareTo(bc) < 0) return -1;
      if (ac.compareTo(bc) > 0) return 1;
      return Range.compareRangesUsingStarts(a.range, b.range);
    });

    final int visibleStartLineNumber = ctx.visibleRange.startLineNumber;
    final int visibleEndLineNumber = ctx.visibleRange.endLineNumber;
    final List<String> output = List<String>.filled(
      visibleEndLineNumber - visibleStartLineNumber + 1,
      '',
    );

    // Render whole-line decorations first, then normal decorations.
    _renderWholeLineDecorations(ctx, decorations, output);
    _renderNormalDecorations(ctx, decorations, output);
    _renderResult = output;
  }

  void _renderWholeLineDecorations(
    RenderingContext ctx,
    List<ViewModelDecoration> decorations,
    List<String> output,
  ) {
    final int visibleStartLineNumber = ctx.visibleRange.startLineNumber;
    final int visibleEndLineNumber = ctx.visibleRange.endLineNumber;

    for (final ViewModelDecoration d in decorations) {
      final dynamic options = _opts(d);
      if (options.isWholeLine != true) continue;

      final String decorationOutput = '<div class="cdr ${options.className}'
        '" style="left:0;width:100%;"></div>';

      final int startLineNumber =
          _max(d.range.startLineNumber, visibleStartLineNumber);
      final int endLineNumber =
          _min(d.range.endLineNumber, visibleEndLineNumber);
      for (int j = startLineNumber; j <= endLineNumber; j++) {
        output[j - visibleStartLineNumber] += decorationOutput;
      }
    }
  }

  void _renderNormalDecorations(
    RenderingContext ctx,
    List<ViewModelDecoration> decorations,
    List<String> output,
  ) {
    final int visibleStartLineNumber = ctx.visibleRange.startLineNumber;

    String? prevClassName;
    bool prevShowIfCollapsed = false;
    Range? prevRange;
    bool prevShouldFillLineOnLineBreak = false;

    for (final ViewModelDecoration d in decorations) {
      final dynamic options = _opts(d);
      if (options.isWholeLine == true) continue;

      final String className = options.className as String;
      final bool showIfCollapsed = options.showIfCollapsed == true;

      Range range = d.range;
      if (showIfCollapsed &&
          range.endColumn == 1 &&
          range.endLineNumber != range.startLineNumber) {
        final int maxCol = (_context.viewModel as dynamic)
            .getLineMaxColumn(range.endLineNumber - 1) as int;
        range = Range(
          range.startLineNumber,
          range.startColumn,
          range.endLineNumber - 1,
          maxCol,
        );
      }

      if (prevClassName == className &&
          prevShowIfCollapsed == showIfCollapsed &&
          prevRange != null &&
          Range.areIntersectingOrTouching(prevRange, range)) {
        prevRange = prevRange.plusRange(range);
        continue;
      }

      if (prevClassName != null && prevRange != null) {
        _renderNormalDecoration(
          ctx,
          prevRange,
          prevClassName,
          prevShouldFillLineOnLineBreak,
          prevShowIfCollapsed,
          visibleStartLineNumber,
          output,
        );
      }

      prevClassName = className;
      prevShowIfCollapsed = showIfCollapsed;
      prevRange = range;
      prevShouldFillLineOnLineBreak =
          options.shouldFillLineOnLineBreak == true;
    }

    if (prevClassName != null && prevRange != null) {
      _renderNormalDecoration(
        ctx,
        prevRange,
        prevClassName,
        prevShouldFillLineOnLineBreak,
        prevShowIfCollapsed,
        visibleStartLineNumber,
        output,
      );
    }
  }

  void _renderNormalDecoration(
    RenderingContext ctx,
    Range range,
    String className,
    bool shouldFillLineOnLineBreak,
    bool showIfCollapsed,
    int visibleStartLineNumber,
    List<String> output,
  ) {
    final List<LineVisibleRanges>? linesVisibleRanges =
        ctx.linesVisibleRangesForRange(range, className == 'findMatch');
    if (linesVisibleRanges == null) return;

    for (final LineVisibleRanges lineVisibleRanges in linesVisibleRanges) {
      if (lineVisibleRanges.outsideRenderedLine) continue;
      final int lineIndex =
          lineVisibleRanges.lineNumber - visibleStartLineNumber;

      if (showIfCollapsed && lineVisibleRanges.ranges.length == 1) {
        final HorizontalRange singleVisibleRange =
            lineVisibleRanges.ranges[0];
        if (singleVisibleRange.width < _typicalHalfwidthCharacterWidth) {
          // Expand a collapsed/very small range, keeping it centered.
          final num center = _jsRound(
            singleVisibleRange.left + singleVisibleRange.width / 2,
          );
          final num left = _maxNum(
            0,
            _jsRound(center - _typicalHalfwidthCharacterWidth / 2),
          );
          lineVisibleRanges.ranges[0] =
              HorizontalRange(left, _typicalHalfwidthCharacterWidth);
        }
      }

      for (int k = 0; k < lineVisibleRanges.ranges.length; k++) {
        final bool expandToLeft = shouldFillLineOnLineBreak &&
            lineVisibleRanges.continuesOnNextLine &&
            lineVisibleRanges.ranges.length == 1;
        final HorizontalRange visibleRange = lineVisibleRanges.ranges[k];
        final String widthPart = expandToLeft
            ? '100%;'
            : '${_jsNum(visibleRange.width)}px;';
        output[lineIndex] += '<div class="cdr $className" style="left:'
            '${_jsNum(visibleRange.left)}px;width:$widthPart"></div>';
      }
    }
  }

  @override
  String render(int startLineNumber, int lineNumber) {
    final List<String>? result = _renderResult;
    if (result == null) return '';
    final int lineIndex = lineNumber - startLineNumber;
    if (lineIndex < 0 || lineIndex >= result.length) return '';
    return result[lineIndex];
  }
}

dynamic _opts(ViewModelDecoration d) => d.options as dynamic;

num _readHalfWidth(IDecorationsConfiguration config) {
  final Object? fontInfo = config.options.get(EditorOption.fontInfo);
  return fontInfo == null
      ? 0
      : (fontInfo as dynamic).typicalHalfwidthCharacterWidth as num;
}

int _max(int a, int b) => a > b ? a : b;
int _min(int a, int b) => a < b ? a : b;
num _maxNum(num a, num b) => a > b ? a : b;
