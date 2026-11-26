// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/viewLines/viewLine.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `viewLineRenderer.ts` (RenderLineInput/renderViewLine/CharacterMapping/…
//    is still pending in the Dart port, so the exact carriers are declared
//    locally. `configureViewLineRendererForReplay` supplies the renderer.
//  * DOM nodes are traversed through narrow carriers; `FastDomNode` creation is
//    injectable through `configureViewLineFastDomNodeForReplay`.
//  * Platform/browser flags are injectable so both fast/slow and normal/WebKit
//    branches can be replayed deterministically.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../../../base/browser/browser.dart' as browser;
import '../../../../base/common/platform.dart' as platform;
import '../../../../base/common/strings.dart' as strings;
import '../../../../platform/theme/common/theme.dart'
    show ColorScheme, isHighContrast;
import '../../../common/config/editorOptions.dart' show EditorFontLigatures;
import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import '../../../common/core/stringBuilder.dart' show StringBuilder;
import '../../../common/model.dart' show TextDirection;
import '../../../common/viewLayout/lineDecorations.dart' show LineDecoration;
import '../../../common/viewLayout/viewLinesViewportData.dart' show ViewportData;
import '../../../common/viewModel/inlineDecorations.dart'
    show InlineDecoration, InlineDecorationType;
import '../../view/renderingContext.dart'
    show FloatHorizontalRange, VisibleRanges;
import 'domReadingContext.dart' show DomReadingContext;
import 'rangeUtil.dart' as range_util
    show IElementNode, IRangeReadingContext, RangeUtil;

/// 1:1: `ViewLineOptions` subset used by view lines (narrow carrier).
abstract class IViewLineOptionsForLine {
  ColorScheme get themeType;
  String get renderWhitespace;
  String get experimentalWhitespaceRendering;
  bool get renderControlCharacters;
  num get spaceWidth;
  num get middotWidth;
  num get wsmiddotWidth;
  bool get useMonospaceOptimizations;
  bool get canUseHalfwidthRightwardsArrow;
  num get stopRenderingLineAfter;
  String get fontLigatures;
  num get verticalScrollbarSize;
  bool get useGpu;
  bool get useTwoCellFullwidthCharacters;
}

/// 1:1: `HTMLElement` subset needed for line measurement.
abstract class IViewLineSpan implements range_util.IElementNode {
  /// 1:1: `HTMLElement.textContent` used by `getColumnOfNodeOffset`.
  @override
  String? get textContent;
  @override
  Object? get firstChild;

  /// 1:1: `HTMLElement.offsetWidth` of the rendered span.
  num get offsetWidth;

  /// 1:1: `previousSibling` used by `getColumnOfNodeOffset`.
  IViewLineSpan? get previousSibling;
}

/// 1:1: `HTMLElement` subset used as a rendered line's DOM node.
abstract class IViewLineElement {
  IViewLineSpan? get firstChild;
  void remove();
}

/// 1:1: `FastDomNode<HTMLElement>` subset used by view lines.
abstract class IFastDomNode {
  IViewLineElement get domNode;
  void setTop(Object top);
  void setHeight(Object height);
  void setLineHeight(Object height);
}

/// 1:1: `DomPosition` from viewLineRenderer.ts (carrier).
class DomPosition {
  const DomPosition(this.partIndex, this.charIndex);
  final int partIndex;
  final int charIndex;
}

/// 1:1: `ForeignElementType` from viewLineRenderer.ts.
class ForeignElementType {
  static const int None = 0;
  static const int Before = 1;
  static const int After = 2;
}

/// 1:1: `RenderWhitespace` from viewLineRenderer.ts.
class RenderWhitespace {
  static const int None = 0;
  static const int Boundary = 1;
  static const int Selection = 2;
  static const int Trailing = 3;
  static const int All = 4;
}

/// 1:1: `CharacterMapping` from viewLineRenderer.ts (carrier).
class CharacterMapping {
  CharacterMapping(int length, int partCount)
      : length = length,
        _data = Uint32List(length),
        _horizontalOffset = Uint32List(length);

  static const int _partIndexMask = 0xFFFF0000;
  static const int _charIndexMask = 0x0000FFFF;
  static const int _partIndexOffset = 16;
  static const int _charIndexOffset = 0;

  final int length;
  final Uint32List _data;
  final Uint32List _horizontalOffset;

  static int _getPartIndex(int partData) =>
      (partData & _partIndexMask) >> _partIndexOffset;
  static int _getCharIndex(int partData) =>
      (partData & _charIndexMask) >> _charIndexOffset;

  /// 1:1: `setColumnInfo`.
  void setColumnInfo(
    int column,
    int partIndex,
    int charIndex,
    int horizontalOffset,
  ) {
    final int partData = ((partIndex << _partIndexOffset) |
            (charIndex << _charIndexOffset)) &
        0xFFFFFFFF;
    _data[column - 1] = partData;
    _horizontalOffset[column - 1] = horizontalOffset;
  }

  /// 1:1: `getHorizontalOffset` (out-of-bounds typed-array reads become NaN,
  /// matching JavaScript).
  num getHorizontalOffset(int column) {
    if (_horizontalOffset.isEmpty) return 0;
    final int index = column - 1;
    if (index < 0 || index >= _horizontalOffset.length) return double.nan;
    return _horizontalOffset[index];
  }

  int _charOffsetToPartData(int charOffset) {
    if (length == 0) return 0;
    if (charOffset < 0) return _data[0];
    if (charOffset >= length) return _data[length - 1];
    return _data[charOffset];
  }

  /// 1:1: `getDomPosition`.
  DomPosition getDomPosition(int column) {
    final int partData = _charOffsetToPartData(column - 1);
    return DomPosition(
      _getPartIndex(partData),
      _getCharIndex(partData),
    );
  }

  /// 1:1: `getColumn`.
  int getColumn(DomPosition domPosition, int partLength) =>
      _partDataToCharOffset(
            domPosition.partIndex,
            partLength,
            domPosition.charIndex,
          ) +
      1;

  int _partDataToCharOffset(int partIndex, int partLength, int charIndex) {
    if (length == 0) return 0;
    final int searchEntry = ((partIndex << _partIndexOffset) |
            (charIndex << _charIndexOffset)) &
        0xFFFFFFFF;

    int min = 0;
    int max = length - 1;
    while (min + 1 < max) {
      final int mid = (min + max) >> 1;
      final int midEntry = _data[mid];
      if (midEntry == searchEntry) {
        return mid;
      } else if (midEntry > searchEntry) {
        max = mid;
      } else {
        min = mid;
      }
    }
    if (min == max) return min;

    final int minEntry = _data[min];
    final int maxEntry = _data[max];
    if (minEntry == searchEntry) return min;
    if (maxEntry == searchEntry) return max;

    final int minPartIndex = _getPartIndex(minEntry);
    final int minCharIndex = _getCharIndex(minEntry);
    final int maxPartIndex = _getPartIndex(maxEntry);
    final int maxCharIndex = minPartIndex != maxPartIndex
        ? partLength
        : _getCharIndex(maxEntry);

    final int minEntryDistance = charIndex - minCharIndex;
    final int maxEntryDistance = maxCharIndex - charIndex;
    if (minEntryDistance <= maxEntryDistance) return min;
    return max;
  }
}

/// 1:1: `RenderLineOutput` from viewLineRenderer.ts (carrier).
class RenderLineOutput {
  RenderLineOutput(this.characterMapping, this.containsForeignElements);
  final CharacterMapping characterMapping;
  final int containsForeignElements;
}

/// 1:1: `RenderLineInput` from viewLineRenderer.ts (carrier).
class RenderLineInput {
  RenderLineInput(
    this.useMonospaceOptimizations,
    this.canUseHalfwidthRightwardsArrow,
    this.lineContent,
    this.continuesWithWrappedLine,
    this.isBasicASCII,
    this.containsRTL,
    this.fauxIndentLength,
    this.lineTokens,
    List<LineDecoration> lineDecorations,
    this.tabSize,
    this.startVisibleColumn,
    this.spaceWidth,
    num middotWidth,
    num wsmiddotWidth,
    this.stopRenderingLineAfter,
    String renderWhitespace,
    this.renderControlCharacters,
    this.fontLigatures,
    List<OffsetRange>? selectionsOnLine,
    this.textDirection,
    this.verticalScrollbarSize, [
    this.renderNewLineWhenEmpty = false,
    this.useTwoCellFullwidthCharacters = false,
  ])  : lineDecorations = List<LineDecoration>.from(lineDecorations)
          ..sort(LineDecoration.compare),
        selectionsOnLine = selectionsOnLine == null
            ? null
            : (List<OffsetRange>.from(selectionsOnLine)
              ..sort((OffsetRange a, OffsetRange b) =>
                  a.start < b.start ? -1 : 1)) {
    this.renderWhitespace = renderWhitespace == 'all'
        ? RenderWhitespace.All
        : renderWhitespace == 'boundary'
            ? RenderWhitespace.Boundary
            : renderWhitespace == 'selection'
                ? RenderWhitespace.Selection
                : renderWhitespace == 'trailing'
                    ? RenderWhitespace.Trailing
                    : RenderWhitespace.None;
    final num wsmiddotDiff = (wsmiddotWidth - spaceWidth).abs();
    final num middotDiff = (middotWidth - spaceWidth).abs();
    if (wsmiddotDiff < middotDiff) {
      renderSpaceWidth = wsmiddotWidth;
      renderSpaceCharCode = 0x2E31;
    } else {
      renderSpaceWidth = middotWidth;
      renderSpaceCharCode = 0xB7;
    }
  }

  final bool useMonospaceOptimizations;
  final bool canUseHalfwidthRightwardsArrow;
  final String lineContent;
  final bool continuesWithWrappedLine;
  final bool isBasicASCII;
  final bool containsRTL;
  final int fauxIndentLength;
  final Object lineTokens;
  final List<LineDecoration> lineDecorations;
  final int tabSize;
  final int startVisibleColumn;
  final num spaceWidth;
  late final num renderSpaceWidth;
  late final int renderSpaceCharCode;
  final num stopRenderingLineAfter;
  late final int renderWhitespace;
  final bool renderControlCharacters;
  final bool fontLigatures;
  final List<OffsetRange>? selectionsOnLine;
  final int? textDirection;
  final num verticalScrollbarSize;
  final bool renderNewLineWhenEmpty;
  final bool useTwoCellFullwidthCharacters;

  /// 1:1: `isLTR`.
  bool get isLTR =>
      !containsRTL && textDirection != TextDirection.RTL;

  bool _sameSelection(List<OffsetRange>? other) {
    final List<OffsetRange>? mine = selectionsOnLine;
    if (mine == null) return other == null;
    if (other == null || other.length != mine.length) return false;
    for (int i = 0; i < mine.length; i++) {
      if (!mine[i].equals(other[i])) return false;
    }
    return true;
  }

  /// 1:1: `equals`.
  bool equals(RenderLineInput other) {
    final dynamic myTokens = lineTokens;
    final dynamic otherTokens = other.lineTokens;
    return useMonospaceOptimizations == other.useMonospaceOptimizations &&
        canUseHalfwidthRightwardsArrow ==
            other.canUseHalfwidthRightwardsArrow &&
        lineContent == other.lineContent &&
        continuesWithWrappedLine == other.continuesWithWrappedLine &&
        isBasicASCII == other.isBasicASCII &&
        containsRTL == other.containsRTL &&
        fauxIndentLength == other.fauxIndentLength &&
        tabSize == other.tabSize &&
        startVisibleColumn == other.startVisibleColumn &&
        spaceWidth == other.spaceWidth &&
        renderSpaceWidth == other.renderSpaceWidth &&
        renderSpaceCharCode == other.renderSpaceCharCode &&
        stopRenderingLineAfter == other.stopRenderingLineAfter &&
        renderWhitespace == other.renderWhitespace &&
        renderControlCharacters == other.renderControlCharacters &&
        fontLigatures == other.fontLigatures &&
        LineDecoration.equalsArr(lineDecorations, other.lineDecorations) &&
        myTokens.equals(otherTokens) &&
        _sameSelection(other.selectionsOnLine) &&
        textDirection == other.textDirection &&
        verticalScrollbarSize == other.verticalScrollbarSize &&
        renderNewLineWhenEmpty == other.renderNewLineWhenEmpty &&
        useTwoCellFullwidthCharacters == other.useTwoCellFullwidthCharacters;
  }
}

typedef ViewLineRendererForReplay =
    RenderLineOutput Function(RenderLineInput input, StringBuilder sb);
typedef ViewLineFastDomNodeFactoryForReplay =
    IFastDomNode Function(IViewLineElement domNode);

ViewLineRendererForReplay? _renderViewLineForReplay;
ViewLineFastDomNodeFactoryForReplay? _createFastDomNodeForReplay;
bool? _canUseFastRenderedViewLineOverride;
bool? _isWebKitOverride;
bool? _monospaceAssumptionsOverride;

/// Install the `renderViewLine` implementation (pending dependency).
void configureViewLineRendererForReplay(ViewLineRendererForReplay renderer) =>
    _renderViewLineForReplay = renderer;

/// Install the `createFastDomNode` implementation used by `setDomNode`.
void configureViewLineFastDomNodeForReplay(
        ViewLineFastDomNodeFactoryForReplay factory) =>
    _createFastDomNodeForReplay = factory;

/// Override the module-load `canUseFastRenderedViewLine` computation.
void setCanUseFastRenderedViewLineForReplay(bool? value) =>
    _canUseFastRenderedViewLineOverride = value;

/// Override the module-load `browser.isWebKit` read used by `createRenderedLine`.
void setIsWebKitForViewLineReplay(bool? value) => _isWebKitOverride = value;

/// Reset the module-global monospace validity flag between replay scenarios.
void setMonospaceAssumptionsForViewLineReplay(bool value) =>
    _monospaceAssumptionsOverride = value;

bool _computeCanUseFastRenderedViewLine() {
  if (platform.isNative) return true;
  if (platform.isLinux || browser.isFirefox || browser.isSafari) return false;
  return true;
}

bool get _canUseFastRenderedViewLine =>
    _canUseFastRenderedViewLineOverride ?? _computeCanUseFastRenderedViewLine();

bool get _isWebKit => _isWebKitOverride ?? browser.isWebKit;

bool get _monospaceAssumptionsAreValid =>
    _monospaceAssumptionsOverride ?? true;

void _invalidateMonospaceAssumptions() =>
    _monospaceAssumptionsOverride = false;

int _charCodeAt(String text, int index) =>
    index < 0 || index >= text.length ? -1 : text.codeUnitAt(index);

class _RangeContextAdapter implements range_util.IRangeReadingContext {
  _RangeContextAdapter(this._context);
  final DomReadingContext _context;

  @override
  Object get endNode => _context.endNode;
  @override
  num get clientRectDeltaLeft => _context.clientRectDeltaLeft;
  @override
  num get clientRectScale => _context.clientRectScale;
  @override
  void markDidDomLayout() => _context.markDidDomLayout();
}

range_util.IRangeReadingContext _rangeContext(DomReadingContext context) =>
    _RangeContextAdapter(context);

/// 1:1: `export class ViewLine`.
class ViewLine {
  static const String CLASS_NAME = 'view-line';

  ViewLine(this._viewGpuContext, IViewLineOptionsForLine options)
      : _options = options,
        _isMaybeInvalid = true,
        _renderedViewLine = null;

  final Object? _viewGpuContext;
  IViewLineOptionsForLine _options;
  bool _isMaybeInvalid;
  IRenderedViewLine? _renderedViewLine;

  // --- begin IVisibleLineData

  /// 1:1: `getDomNode`.
  Object? getDomNode() => _renderedViewLine?.domNode?.domNode;

  /// 1:1: `setDomNode`.
  void setDomNode(IViewLineElement domNode) {
    final IRenderedViewLine? rendered = _renderedViewLine;
    if (rendered != null) {
      final ViewLineFastDomNodeFactoryForReplay? factory =
          _createFastDomNodeForReplay;
      if (factory == null) {
        throw StateError('createFastDomNode is not configured for ViewLine');
      }
      rendered.domNode = factory(domNode);
    } else {
      throw StateError(
          'I have no rendered view line to set the dom node to...');
    }
  }

  void onContentChanged() => _isMaybeInvalid = true;
  void onTokensChanged() => _isMaybeInvalid = true;
  void onDecorationsChanged() => _isMaybeInvalid = true;

  void onOptionsChanged(IViewLineOptionsForLine newOptions) {
    _isMaybeInvalid = true;
    _options = newOptions;
  }

  /// 1:1: `onSelectionChanged`.
  bool onSelectionChanged() {
    final IRenderedViewLine? rendered = _renderedViewLine;
    if (isHighContrast(_options.themeType) ||
        rendered?.input.renderWhitespace == RenderWhitespace.Selection) {
      _isMaybeInvalid = true;
      return true;
    }
    return false;
  }

  /// 1:1: `renderLine`.
  bool renderLine(
    int lineNumber,
    num deltaTop,
    num lineHeight,
    ViewportData viewportData,
    StringBuilder sb,
  ) {
    final dynamic gpu = _viewGpuContext;
    if (_options.useGpu &&
        gpu != null &&
        gpu.canRender(_options, viewportData, lineNumber) == true) {
      _renderedViewLine?.domNode?.domNode.remove();
      _renderedViewLine = null;
      return false;
    }

    if (_isMaybeInvalid == false) return false;
    _isMaybeInvalid = false;

    final dynamic lineData = viewportData.getViewLineRenderingData(lineNumber);
    final IViewLineOptionsForLine options = _options;
    final List<LineDecoration> actualInlineDecorations = LineDecoration.filter(
      lineData.inlineDecorations as List<InlineDecoration>,
      lineNumber,
      lineData.minColumn as int,
      lineData.maxColumn as int,
    );
    final String renderWhitespace =
        options.experimentalWhitespaceRendering == 'off'
            ? options.renderWhitespace
            : 'none';
    final bool allowFastRendering = lineData.hasVariableFonts != true;

    List<OffsetRange>? selectionsOnLine;
    if (isHighContrast(options.themeType) ||
        renderWhitespace == 'selection') {
      final List<dynamic> selections =
          (viewportData.selections as List).cast<dynamic>();
      for (final dynamic selection in selections) {
        if (selection.endLineNumber < lineNumber ||
            selection.startLineNumber > lineNumber) {
          continue;
        }
        final int startColumn = selection.startLineNumber == lineNumber
            ? selection.startColumn as int
            : lineData.minColumn as int;
        final int endColumn = selection.endLineNumber == lineNumber
            ? selection.endColumn as int
            : lineData.maxColumn as int;
        if (startColumn < endColumn) {
          if (isHighContrast(options.themeType)) {
            actualInlineDecorations.add(LineDecoration(
              startColumn,
              endColumn,
              'inline-selected-text',
              InlineDecorationType.Regular,
            ));
          }
          if (renderWhitespace == 'selection') {
            selectionsOnLine ??= <OffsetRange>[];
            selectionsOnLine.add(
                OffsetRange(startColumn - 1, endColumn - 1));
          }
        }
      }
    }

    final RenderLineInput renderLineInput = RenderLineInput(
      options.useMonospaceOptimizations,
      options.canUseHalfwidthRightwardsArrow,
      lineData.content as String,
      lineData.continuesWithWrappedLine as bool,
      lineData.isBasicASCII as bool,
      lineData.containsRTL as bool,
      (lineData.minColumn as int) - 1,
      lineData.tokens,
      actualInlineDecorations,
      lineData.tabSize as int,
      lineData.startVisibleColumn as int,
      options.spaceWidth,
      options.middotWidth,
      options.wsmiddotWidth,
      options.stopRenderingLineAfter,
      renderWhitespace,
      options.renderControlCharacters,
      options.fontLigatures != EditorFontLigatures.OFF,
      selectionsOnLine,
      lineData.textDirection as int?,
      options.verticalScrollbarSize,
      false,
      options.useTwoCellFullwidthCharacters,
    );

    if (_renderedViewLine?.input.equals(renderLineInput) == true) {
      return false;
    }

    sb.appendString('<div ');
    if (lineData.textDirection == TextDirection.RTL) {
      sb.appendString('dir="rtl" ');
    } else if (lineData.containsRTL == true) {
      sb.appendString('dir="ltr" ');
    }
    sb.appendString('style="top:');
    sb.appendString(_jsString(deltaTop));
    sb.appendString('px;height:');
    sb.appendString(_jsString(lineHeight));
    sb.appendString('px;line-height:');
    sb.appendString(_jsString(lineHeight));
    if (lineData.textDirection == TextDirection.RTL) {
      sb.appendString('px;padding-right:');
      sb.appendString(_jsString(options.verticalScrollbarSize));
    }
    sb.appendString('px;" class="');
    sb.appendString(ViewLine.CLASS_NAME);
    sb.appendString('">');

    final ViewLineRendererForReplay? renderer = _renderViewLineForReplay;
    if (renderer == null) {
      throw StateError('renderViewLine is not configured for ViewLine');
    }
    final RenderLineOutput output = renderer(renderLineInput, sb);

    sb.appendString('</div>');

    IRenderedViewLine? renderedViewLine;
    if (allowFastRendering &&
        _monospaceAssumptionsAreValid &&
        _canUseFastRenderedViewLine &&
        lineData.isBasicASCII == true &&
        renderLineInput.isLTR &&
        options.useMonospaceOptimizations &&
        output.containsForeignElements == ForeignElementType.None) {
      renderedViewLine = FastRenderedViewLine(
        _renderedViewLine?.domNode,
        renderLineInput,
        output.characterMapping,
      );
    }

    renderedViewLine ??= createRenderedLine(
      _renderedViewLine?.domNode,
      renderLineInput,
      output.characterMapping,
      output.containsForeignElements,
    );

    _renderedViewLine = renderedViewLine;
    return true;
  }

  /// 1:1: `layoutLine`.
  void layoutLine(int lineNumber, num deltaTop, num lineHeight) {
    final IFastDomNode? domNode = _renderedViewLine?.domNode;
    if (domNode != null) {
      domNode.setTop(deltaTop);
      domNode.setHeight(lineHeight);
      domNode.setLineHeight(lineHeight);
    }
  }

  // --- end IVisibleLineData

  /// 1:1: `isRenderedRTL`.
  bool isRenderedRTL() {
    final IRenderedViewLine? rendered = _renderedViewLine;
    if (rendered == null) return false;
    return rendered.input.textDirection == TextDirection.RTL;
  }

  /// 1:1: `getWidth`.
  num getWidth(DomReadingContext? context) =>
      _renderedViewLine?.getWidth(context) ?? 0;

  /// 1:1: `getWidthIsFast`.
  bool getWidthIsFast() => _renderedViewLine?.getWidthIsFast() ?? true;

  /// 1:1: `needsMonospaceFontCheck`.
  bool needsMonospaceFontCheck() =>
      _renderedViewLine is FastRenderedViewLine;

  /// 1:1: `monospaceAssumptionsAreValid`.
  bool monospaceAssumptionsAreValid() {
    final IRenderedViewLine? rendered = _renderedViewLine;
    if (rendered == null) return _monospaceAssumptionsAreValid;
    if (rendered is FastRenderedViewLine) {
      return rendered.monospaceAssumptionsAreValid();
    }
    return _monospaceAssumptionsAreValid;
  }

  /// 1:1: `onMonospaceAssumptionsInvalidated`.
  void onMonospaceAssumptionsInvalidated() {
    final IRenderedViewLine? rendered = _renderedViewLine;
    if (rendered is FastRenderedViewLine) {
      _renderedViewLine = rendered.toSlowRenderedLine();
    }
  }

  /// 1:1: `getVisibleRangesForRange`.
  VisibleRanges? getVisibleRangesForRange(
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  ) {
    final IRenderedViewLine? rendered = _renderedViewLine;
    if (rendered == null) return null;

    final int contentLength = rendered.input.lineContent.length;
    startColumn = _clampColumn(startColumn, 1, contentLength + 1);
    endColumn = _clampColumn(endColumn, 1, contentLength + 1);

    final num stopRenderingLineAfter = rendered.input.stopRenderingLineAfter;
    if (stopRenderingLineAfter != -1 &&
        startColumn > stopRenderingLineAfter + 1 &&
        endColumn > stopRenderingLineAfter + 1) {
      return VisibleRanges(true, <FloatHorizontalRange>[
        FloatHorizontalRange(getWidth(context), 0),
      ]);
    }
    if (stopRenderingLineAfter != -1 &&
        startColumn > stopRenderingLineAfter + 1) {
      startColumn = (stopRenderingLineAfter + 1).toInt();
    }
    if (stopRenderingLineAfter != -1 &&
        endColumn > stopRenderingLineAfter + 1) {
      endColumn = (stopRenderingLineAfter + 1).toInt();
    }

    final List<FloatHorizontalRange>? horizontalRanges =
        rendered.getVisibleRangesForRange(
            lineNumber, startColumn, endColumn, context);
    if (horizontalRanges != null && horizontalRanges.isNotEmpty) {
      return VisibleRanges(false, horizontalRanges);
    }
    return null;
  }

  /// 1:1: `getColumnOfNodeOffset`.
  int getColumnOfNodeOffset(IViewLineSpan spanNode, int offset) =>
      _renderedViewLine?.getColumnOfNodeOffset(spanNode, offset) ?? 1;

  /// 1:1: `resetCachedWidth`.
  void resetCachedWidth() => _renderedViewLine?.resetCachedWidth();
}

/// 1:1: `IRenderedViewLine`.
abstract class IRenderedViewLine {
  IFastDomNode? get domNode;
  set domNode(IFastDomNode? value);
  RenderLineInput get input;
  num getWidth(DomReadingContext? context);
  bool getWidthIsFast();
  void resetCachedWidth();
  List<FloatHorizontalRange>? getVisibleRangesForRange(
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  );
  int getColumnOfNodeOffset(IViewLineSpan spanNode, int offset);
}

/// 1:1: `Constants`.
class Constants {
  static const int MaxMonospaceDistance = 300;
}

/// 1:1: `FastRenderedViewLine`.
class FastRenderedViewLine implements IRenderedViewLine {
  FastRenderedViewLine(
    this.domNode,
    this.input,
    this._characterMapping,
  ) {
    final int keyColumnCount = (input.lineContent.length /
            Constants.MaxMonospaceDistance)
        .floor();
    if (keyColumnCount > 0) {
      Float32List cache = Float32List(keyColumnCount);
      for (int i = 0; i < keyColumnCount; i++) {
        cache[i] = -1;
      }
      _keyColumnPixelOffsetCache = cache;
    } else {
      _keyColumnPixelOffsetCache = null;
    }
    _charWidth = input.spaceWidth;
  }

  @override
  IFastDomNode? domNode;
  @override
  final RenderLineInput input;
  final CharacterMapping _characterMapping;
  late final num _charWidth;
  Float32List? _keyColumnPixelOffsetCache;
  num _cachedWidth = -1;

  static IViewLineSpan _getReadingTarget(IFastDomNode myDomNode) =>
      myDomNode.domNode.firstChild as IViewLineSpan;

  @override
  num getWidth(DomReadingContext? context) {
    if (domNode == null ||
        input.lineContent.length < Constants.MaxMonospaceDistance) {
      final num horizontalOffset =
          _characterMapping.getHorizontalOffset(_characterMapping.length);
      return _jsRound(_charWidth * horizontalOffset);
    }
    if (_cachedWidth == -1) {
      _cachedWidth = _getReadingTarget(domNode!).offsetWidth;
      context?.markDidDomLayout();
    }
    return _cachedWidth;
  }

  @override
  bool getWidthIsFast() =>
      input.lineContent.length < Constants.MaxMonospaceDistance ||
      _cachedWidth != -1;

  @override
  void resetCachedWidth() => _cachedWidth = -1;

  /// 1:1: `monospaceAssumptionsAreValid`.
  bool monospaceAssumptionsAreValid() {
    final IFastDomNode? node = domNode;
    if (node == null) return _monospaceAssumptionsAreValid;
    if (input.lineContent.length < Constants.MaxMonospaceDistance) {
      final num expectedWidth = getWidth(null);
      final num actualWidth = _getReadingTarget(node).offsetWidth;
      if ((expectedWidth - actualWidth).abs() >= 2) {
        _invalidateMonospaceAssumptions();
      }
    }
    return _monospaceAssumptionsAreValid;
  }

  /// 1:1: `toSlowRenderedLine`.
  RenderedViewLine toSlowRenderedLine() => createRenderedLine(
        domNode,
        input,
        _characterMapping,
        ForeignElementType.None,
      );

  @override
  List<FloatHorizontalRange>? getVisibleRangesForRange(
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  ) {
    final num startPosition =
        _getColumnPixelOffset(lineNumber, startColumn, context);
    final num endPosition =
        _getColumnPixelOffset(lineNumber, endColumn, context);
    return <FloatHorizontalRange>[
      FloatHorizontalRange(startPosition, endPosition - startPosition),
    ];
  }

  num _getColumnPixelOffset(
    int lineNumber,
    int column,
    DomReadingContext context,
  ) {
    if (column <= Constants.MaxMonospaceDistance) {
      return _charWidth * _characterMapping.getHorizontalOffset(column);
    }

    final int keyColumnOrdinal =
        ((column - 1) / Constants.MaxMonospaceDistance).floor() - 1;
    final int keyColumn =
        (keyColumnOrdinal + 1) * Constants.MaxMonospaceDistance + 1;
    num keyColumnPixelOffset = -1;
    final Float32List? cache = _keyColumnPixelOffsetCache;
    if (cache != null) {
      if (keyColumnOrdinal < 0 || keyColumnOrdinal >= cache.length) {
        keyColumnPixelOffset = double.nan;
      } else {
        keyColumnPixelOffset = cache[keyColumnOrdinal];
        if (keyColumnPixelOffset == -1) {
          keyColumnPixelOffset =
              _actualReadPixelOffset(lineNumber, keyColumn, context);
          cache[keyColumnOrdinal] = keyColumnPixelOffset.toDouble();
        }
      }
    }
    if (keyColumnPixelOffset == -1) {
      return _charWidth * _characterMapping.getHorizontalOffset(column);
    }
    final num keyColumnHorizontalOffset =
        _characterMapping.getHorizontalOffset(keyColumn);
    final num horizontalOffset =
        _characterMapping.getHorizontalOffset(column);
    return keyColumnPixelOffset +
        _charWidth * (horizontalOffset - keyColumnHorizontalOffset);
  }

  num _actualReadPixelOffset(
    int lineNumber,
    int column,
    DomReadingContext context,
  ) {
    final IFastDomNode? node = domNode;
    if (node == null) return -1;
    final DomPosition domPosition = _characterMapping.getDomPosition(column);
    final List<FloatHorizontalRange>? r = range_util.RangeUtil
        .readHorizontalRanges(
      _getReadingTarget(node),
      domPosition.partIndex,
      domPosition.charIndex,
      domPosition.partIndex,
      domPosition.charIndex,
      _rangeContext(context),
    );
    if (r == null || r.isEmpty) return -1;
    return r[0].left;
  }

  @override
  int getColumnOfNodeOffset(IViewLineSpan spanNode, int offset) =>
      _getColumnOfNodeOffset(_characterMapping, spanNode, offset);
}

/// 1:1: `RenderedViewLine`.
class RenderedViewLine implements IRenderedViewLine {
  RenderedViewLine(
    this.domNode,
    this.input,
    this._characterMapping,
    this._containsForeignElements,
  ) {
    _isWhitespaceOnly = RegExp(r'^\s*$').hasMatch(input.lineContent);
    _cachedWidth = -1;
    _pixelOffsetCache = null;
    if (input.isLTR) {
      Float32List cache =
          Float32List(_max(2, _characterMapping.length + 1));
      for (int column = 0; column <= _characterMapping.length; column++) {
        cache[column] = -1;
      }
      _pixelOffsetCache = cache;
    }
  }

  @override
  IFastDomNode? domNode;
  @override
  final RenderLineInput input;
  final CharacterMapping _characterMapping;
  late final bool _isWhitespaceOnly;
  final int _containsForeignElements;
  num _cachedWidth = -1;
  Float32List? _pixelOffsetCache;

  IViewLineSpan _getReadingTarget(IFastDomNode myDomNode) =>
      myDomNode.domNode.firstChild as IViewLineSpan;

  @override
  num getWidth(DomReadingContext? context) {
    final IFastDomNode? node = domNode;
    if (node == null) return 0;
    if (_cachedWidth == -1) {
      _cachedWidth = _getReadingTarget(node).offsetWidth;
      context?.markDidDomLayout();
    }
    return _cachedWidth;
  }

  @override
  bool getWidthIsFast() => _cachedWidth != -1;

  @override
  void resetCachedWidth() {
    _cachedWidth = -1;
    final Float32List? cache = _pixelOffsetCache;
    if (cache != null) {
      for (int column = 0; column < cache.length; column++) {
        cache[column] = -1;
      }
    }
  }

  @override
  List<FloatHorizontalRange>? getVisibleRangesForRange(
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  ) {
    final IFastDomNode? node = domNode;
    if (node == null) return null;
    if (_pixelOffsetCache != null) {
      final num startOffset =
          _readPixelOffset(node, lineNumber, startColumn, context);
      if (startOffset == -1) return null;
      final num endOffset =
          _readPixelOffset(node, lineNumber, endColumn, context);
      if (endOffset == -1) return null;
      return <FloatHorizontalRange>[
        FloatHorizontalRange(startOffset, endOffset - startOffset),
      ];
    }
    return _readVisibleRangesForRange(
        node, lineNumber, startColumn, endColumn, context);
  }

  List<FloatHorizontalRange>? _readVisibleRangesForRange(
    IFastDomNode domNode,
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  ) {
    if (startColumn == endColumn) {
      final num pixelOffset =
          _readPixelOffset(domNode, lineNumber, startColumn, context);
      if (pixelOffset == -1) return null;
      return <FloatHorizontalRange>[FloatHorizontalRange(pixelOffset, 0)];
    }
    return _readRawVisibleRangesForRange(
        domNode, startColumn, endColumn, context);
  }

  num _readPixelOffset(
    IFastDomNode domNode,
    int lineNumber,
    int column,
    DomReadingContext context,
  ) {
    if (input.isLTR && _characterMapping.length == 0) {
      if (_containsForeignElements == ForeignElementType.None) return 0;
      if (_containsForeignElements == ForeignElementType.After) return 0;
      if (_containsForeignElements == ForeignElementType.Before) {
        return getWidth(context);
      }
      final IViewLineSpan readingTarget = _getReadingTarget(domNode);
      final Object? firstChild = readingTarget.firstChild;
      if (firstChild != null) {
        context.markDidDomLayout();
        return (firstChild as IViewLineSpan).offsetWidth;
      }
      return 0;
    }

    final Float32List? cache = _pixelOffsetCache;
    if (cache != null) {
      if (column < 0 || column >= cache.length) return double.nan;
      final num cachedPixelOffset = cache[column];
      if (cachedPixelOffset != -1) return cachedPixelOffset;
      final num result =
          _actualReadPixelOffset(domNode, lineNumber, column, context);
      cache[column] = result.toDouble();
      return result;
    }
    return _actualReadPixelOffset(domNode, lineNumber, column, context);
  }

  num _actualReadPixelOffset(
    IFastDomNode domNode,
    int lineNumber,
    int column,
    DomReadingContext context,
  ) {
    if (_characterMapping.length == 0) {
      final List<FloatHorizontalRange>? r = range_util.RangeUtil
          .readHorizontalRanges(_getReadingTarget(domNode), 0, 0, 0, 0, _rangeContext(context));
      if (r == null || r.isEmpty) return -1;
      return r[0].left;
    }

    if (input.isLTR &&
        column == _characterMapping.length &&
        _isWhitespaceOnly &&
        _containsForeignElements == ForeignElementType.None) {
      return getWidth(context);
    }

    final DomPosition domPosition = _characterMapping.getDomPosition(column);
    if (input.useTwoCellFullwidthCharacters) {
      final IViewLineSpan target = _getReadingTarget(domNode);
      if (strings.isFullWidthCharacter(
          _charCodeAt(input.lineContent, column - 1))) {
        final FloatHorizontalRange? r = range_util.RangeUtil
            .readHorizontalRangeForElement(
                target, domPosition.partIndex, _rangeContext(context));
        if (r != null) return r.left;
      } else if (strings.isFullWidthCharacter(
          _charCodeAt(input.lineContent, column - 2))) {
        final DomPosition previousDomPosition =
            _characterMapping.getDomPosition(column - 1);
        final FloatHorizontalRange? r = range_util.RangeUtil
            .readHorizontalRangeForElement(
                target, previousDomPosition.partIndex, _rangeContext(context));
        if (r != null) return r.left + r.width;
      }
    }

    final List<FloatHorizontalRange>? r = range_util.RangeUtil
        .readHorizontalRanges(
      _getReadingTarget(domNode),
      domPosition.partIndex,
      domPosition.charIndex,
      domPosition.partIndex,
      domPosition.charIndex,
      _rangeContext(context),
    );
    if (r == null || r.isEmpty) return -1;
    final num result = r[0].left;
    if (input.isBasicASCII) {
      final num horizontalOffset =
          _characterMapping.getHorizontalOffset(column);
      final num expectedResult = _jsRound(input.spaceWidth * horizontalOffset);
      if ((expectedResult - result).abs() <= 1) return expectedResult;
    }
    return result;
  }

  List<FloatHorizontalRange>? _readRawVisibleRangesForRange(
    IFastDomNode domNode,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  ) {
    if (input.isLTR &&
        startColumn == 1 &&
        endColumn == _characterMapping.length) {
      return <FloatHorizontalRange>[FloatHorizontalRange(0, getWidth(context))];
    }
    final DomPosition startDomPosition =
        _characterMapping.getDomPosition(startColumn);
    final DomPosition endDomPosition =
        _characterMapping.getDomPosition(endColumn);
    return range_util.RangeUtil.readHorizontalRanges(
      _getReadingTarget(domNode),
      startDomPosition.partIndex,
      startDomPosition.charIndex,
      endDomPosition.partIndex,
      endDomPosition.charIndex,
      _rangeContext(context),
    );
  }

  @override
  int getColumnOfNodeOffset(IViewLineSpan spanNode, int offset) =>
      _getColumnOfNodeOffset(_characterMapping, spanNode, offset);
}

/// 1:1: `WebKitRenderedViewLine`.
class WebKitRenderedViewLine extends RenderedViewLine {
  WebKitRenderedViewLine(
    IFastDomNode? domNode,
    RenderLineInput renderLineInput,
    CharacterMapping characterMapping,
    int containsForeignElements,
  ) : super(domNode, renderLineInput, characterMapping,
            containsForeignElements);

  @override
  List<FloatHorizontalRange>? _readVisibleRangesForRange(
    IFastDomNode domNode,
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  ) {
    final List<FloatHorizontalRange>? output = super._readVisibleRangesForRange(
      domNode,
      lineNumber,
      startColumn,
      endColumn,
      context,
    );
    if (output == null ||
        output.isEmpty ||
        startColumn == endColumn ||
        (startColumn == 1 && endColumn == _characterMapping.length)) {
      return output;
    }
    if (input.isLTR) {
      final num endPixelOffset =
          _readPixelOffset(domNode, lineNumber, endColumn, context);
      if (endPixelOffset != -1) {
        final FloatHorizontalRange lastRange = output[output.length - 1];
        if (lastRange.left < endPixelOffset) {
          lastRange.width = endPixelOffset - lastRange.left;
        }
      }
    }
    return output;
  }
}

/// 1:1: `createRenderedLine` (browser-selected factory).
RenderedViewLine createRenderedLine(
  IFastDomNode? domNode,
  RenderLineInput renderLineInput,
  CharacterMapping characterMapping,
  int containsForeignElements,
) {
  if (_isWebKit) {
    return WebKitRenderedViewLine(
        domNode, renderLineInput, characterMapping, containsForeignElements);
  }
  return RenderedViewLine(
      domNode, renderLineInput, characterMapping, containsForeignElements);
}

/// 1:1: `getColumnOfNodeOffset`.
int _getColumnOfNodeOffset(
  CharacterMapping characterMapping,
  IViewLineSpan spanNode,
  int offset,
) {
  final int spanNodeTextContentLength = spanNode.textContent?.length ?? 0;
  int spanIndex = -1;
  IViewLineSpan? node = spanNode;
  while (node != null) {
    node = node.previousSibling;
    spanIndex++;
  }
  return characterMapping.getColumn(
      DomPosition(spanIndex, offset), spanNodeTextContentLength);
}

/// 1:1: exported `getColumnOfNodeOffset`.
int getColumnOfNodeOffset(
  CharacterMapping characterMapping,
  IViewLineSpan spanNode,
  int offset,
) =>
    _getColumnOfNodeOffset(characterMapping, spanNode, offset);

int _max(int a, int b) => a > b ? a : b;

int _clampColumn(int value, int min, int max) =>
    value < min ? min : (value > max ? max : value);

String _jsString(Object value) {
  if (value is double && value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toString();
}

int _jsRound(num value) {
  final double floored = value.floorToDouble();
  if (value - floored < 0.5) return floored.toInt();
  return floored.toInt() + 1;
}
