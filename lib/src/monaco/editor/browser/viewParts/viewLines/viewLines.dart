// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/viewLines/viewLines.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `viewLayer.ts` (VisibleLinesCollection/IVisibleLine) is still pending, so
//    the collection and per-line surfaces are narrow carriers supplied by
//    `configureViewLinesVisibleLinesFactoryForReplay`.
//  * `ViewLineOptions` is rebuilt locally to avoid a cycle with viewLine.dart;
//    its read surface is identical to the real port.
//  * DOM nodes, schedulers and the text-range resting spot are injectable so
//    the rendering and reveal logic can be replayed deterministically.
//  * Erased `IViewLayout` / `IViewModel` interfaces become local carriers.
// ---------------------------------------------------------------------------

import '../../../../base/common/platform.dart' as platform;
import '../../../../base/common/uint.dart' show Constants;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/selection.dart' show Selection;
import '../../../common/editorCommon.dart' show ScrollType;
import '../../../common/model.dart' show TextDirection;
import '../../../common/viewEvents.dart' show VerticalRevealType;
import '../../../common/viewLayout/viewLinesViewportData.dart' show ViewportData;
import '../../../common/viewModel.dart' show Viewport;
import '../../../common/viewModel/viewContext.dart' show ViewContext;
import '../../config/domFontInfo.dart' show applyFontInfo;
import '../../view/renderingContext.dart'
    show
        HorizontalPosition,
        HorizontalRange,
        IViewLines,
        LineVisibleRanges,
        VisibleRanges;
import '../../view/viewPart.dart'
    show PartFingerprint, PartFingerprints, ViewPart;
import '../viewLines/domReadingContext.dart' show DomReadingContext;
import '../viewLines/viewLine.dart'
    show IViewLineSpan, ViewLine, IViewLineOptionsForLine;
import '../../../../platform/theme/common/theme.dart' show ColorScheme;
import '../../../../base/browser/ui/mouseCursor/mouseCursor.dart'
    show MOUSE_CURSOR_TEXT_CSS_CLASS_NAME;

/// 1:1: `FastDomNode<HTMLElement>` subset used by ViewLines.
abstract class IViewLinesFastDomNode {
  Object get domNode;
  void setClassName(String className);
  void setWidth(num width);
  void setHeight(num height);
  void setTop(num top);
  void setLeft(num left);
  void setLayerHinting(bool enabled);
  void setContain(String value);
  void setAttribute(String name, String value);
}

/// 1:1: `IVisibleLine` surface used by `ViewLines`.
abstract class IViewLineForViewLines {
  Object? getDomNode();
  void onOptionsChanged(IViewLineOptionsForLine options);
  bool onSelectionChanged();
  void onDecorationsChanged();
  int getColumnOfNodeOffset(Object spanNode, int offset);
  num getWidth(DomReadingContext? context);
  bool getWidthIsFast();
  void resetCachedWidth();
  VisibleRanges? getVisibleRangesForRange(
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  );
  bool isRenderedRTL();
  bool needsMonospaceFontCheck();
  bool monospaceAssumptionsAreValid();
  void onMonospaceAssumptionsInvalidated();
}

/// 1:1: `VisibleLinesCollection<ViewLine>` surface used by `ViewLines`.
abstract class IVisibleLinesForViewLines {
  IViewLinesFastDomNode get domNode;
  void onConfigurationChanged(Object e);
  bool onFlushed(Object e, bool useGpu);
  bool onLinesChanged(Object e);
  bool onLinesDeleted(Object e);
  bool onLinesInserted(Object e);
  bool onScrollChanged(Object e);
  bool onTokensChanged(Object e);
  bool onZonesChanged(Object e);
  int getStartLineNumber();
  int getEndLineNumber();
  IViewLineForViewLines getVisibleLine(int lineNumber);
  void renderLines(ViewportData viewportData);
}

/// 1:1: `RunOnceScheduler` surface used by `ViewLines`.
abstract class IViewLinesScheduler {
  bool isScheduled();
  void schedule();
  void cancel();
  void dispose();
  void flush();
}

/// 1:1: `IComputedEditorOptions` subset used by `ViewLines`.
abstract class IOptionsForViewLines {
  Object? get(Object id);
}

/// 1:1: `IEditorConfiguration` subset used by `ViewLines`.
abstract class IConfigurationForViewLines {
  IOptionsForViewLines get options;
}

/// 1:1: `IViewLayout` subset used by `ViewLines`.
abstract class IViewLayoutForViewLines {
  Viewport getFutureViewport();
  Viewport getCurrentViewport();
  Map<String, num> validateScrollPosition(Map<String, num> position);
  num getCurrentScrollTop();
  num getCurrentScrollLeft();
  num getScrollWidth();
  num getScrollHeight();
  num getVerticalOffsetForLineNumber(int lineNumber);
  void setMaxLineWidth(num maxLineWidth);
  void setScrollPosition(Map<String, num> position, int scrollType);
}

/// 1:1: `IViewModel` subset used by `ViewLines`.
abstract class IViewModelForViewLines {
  IViewLayoutForViewLines get viewLayout;
  int getLineCount();
  int getLineMinColumn(int lineNumber);
  int getLineMaxColumn(int lineNumber);
  int getTextDirection(int lineNumber);
  Object get coordinatesConverter;
}

/// 1:1: local `ViewLineOptions` carrier (mirrors viewLineOptions.dart).
class ViewLineOptionsForViewLines implements IViewLineOptionsForLine {
  ViewLineOptionsForViewLines(IConfigurationForViewLines config, this.themeType) {
    final IOptionsForViewLines options = config.options;
    final dynamic fontInfo = options.get(EditorOption.fontInfo);
    renderWhitespace = options.get(EditorOption.renderWhitespace) as String;
    experimentalWhitespaceRendering =
        options.get(EditorOption.experimentalWhitespaceRendering) as String;
    renderControlCharacters =
        options.get(EditorOption.renderControlCharacters) as bool;
    spaceWidth = fontInfo.spaceWidth as num;
    middotWidth = fontInfo.middotWidth as num;
    wsmiddotWidth = fontInfo.wsmiddotWidth as num;
    useMonospaceOptimizations = (fontInfo.isMonospace as bool) &&
        !(options.get(EditorOption.disableMonospaceOptimizations) as bool);
    canUseHalfwidthRightwardsArrow =
        fontInfo.canUseHalfwidthRightwardsArrow as bool;
    lineHeight = options.get(EditorOption.lineHeight) as num;
    stopRenderingLineAfter =
        options.get(EditorOption.stopRenderingLineAfter) as num;
    fontLigatures = options.get(EditorOption.fontLigatures) as String;
    verticalScrollbarSize = (options.get(EditorOption.scrollbar) as dynamic)
        .verticalScrollbarSize as num;
    useGpu = options.get(EditorOption.experimentalGpuAcceleration) == 'on';
    useTwoCellFullwidthCharacters =
        options.get(EditorOption.effectiveFullwidthCharacterWidth) == 'twoCells';
  }

  @override
  final ColorScheme themeType;
  @override
  late final String renderWhitespace;
  @override
  late final String experimentalWhitespaceRendering;
  @override
  late final bool renderControlCharacters;
  @override
  late final num spaceWidth;
  @override
  late final num middotWidth;
  @override
  late final num wsmiddotWidth;
  @override
  late final bool useMonospaceOptimizations;
  @override
  late final bool canUseHalfwidthRightwardsArrow;
  late final num lineHeight;
  @override
  late final num stopRenderingLineAfter;
  @override
  late final String fontLigatures;
  @override
  late final num verticalScrollbarSize;
  @override
  late final bool useGpu;
  @override
  late final bool useTwoCellFullwidthCharacters;

  /// 1:1: `equals`.
  bool equals(ViewLineOptionsForViewLines other) =>
      themeType == other.themeType &&
      renderWhitespace == other.renderWhitespace &&
      experimentalWhitespaceRendering == other.experimentalWhitespaceRendering &&
      renderControlCharacters == other.renderControlCharacters &&
      spaceWidth == other.spaceWidth &&
      middotWidth == other.middotWidth &&
      wsmiddotWidth == other.wsmiddotWidth &&
      useMonospaceOptimizations == other.useMonospaceOptimizations &&
      canUseHalfwidthRightwardsArrow == other.canUseHalfwidthRightwardsArrow &&
      lineHeight == other.lineHeight &&
      stopRenderingLineAfter == other.stopRenderingLineAfter &&
      fontLigatures == other.fontLigatures &&
      verticalScrollbarSize == other.verticalScrollbarSize &&
      useGpu == other.useGpu &&
      useTwoCellFullwidthCharacters == other.useTwoCellFullwidthCharacters;
}

typedef ViewLinesSchedulerFactoryForReplay =
    IViewLinesScheduler Function(void Function() runner, int delay);
typedef ViewLinesCollectionFactoryForReplay = IVisibleLinesForViewLines Function(
  ViewContext context,
  IViewLineForViewLines Function() createLine,
);
typedef ViewLinesRestingSpotFactoryForReplay = Object Function();

ViewLinesSchedulerFactoryForReplay? _schedulerFactoryForReplay;
ViewLinesCollectionFactoryForReplay? _collectionFactoryForReplay;
ViewLinesRestingSpotFactoryForReplay? _restingSpotFactoryForReplay;
bool? _isLinuxForReplay;

/// Override `platform.isLinux` for deterministic replay of the monospace check.
void setIsLinuxForViewLinesReplay(bool value) => _isLinuxForReplay = value;

bool _isLinux() => _isLinuxForReplay ?? platform.isLinux;

/// Install the scheduler factory used for line-width/monospace checks.
void configureViewLinesSchedulerFactoryForReplay(
        ViewLinesSchedulerFactoryForReplay factory) =>
    _schedulerFactoryForReplay = factory;

/// Install the `VisibleLinesCollection` factory.
void configureViewLinesCollectionFactoryForReplay(
        ViewLinesCollectionFactoryForReplay factory) =>
    _collectionFactoryForReplay = factory;

/// Install the `document.createElement('div')` replacement.
void configureViewLinesRestingSpotFactoryForReplay(
        ViewLinesRestingSpotFactoryForReplay factory) =>
    _restingSpotFactoryForReplay = factory;

IViewLinesScheduler _createScheduler(void Function() runner, int delay) {
  final ViewLinesSchedulerFactoryForReplay? factory = _schedulerFactoryForReplay;
  if (factory == null) {
    throw StateError('scheduler factory is not configured for ViewLines');
  }
  return factory(runner, delay);
}

Object _createRestingSpot() {
  final ViewLinesRestingSpotFactoryForReplay? factory =
      _restingSpotFactoryForReplay;
  return factory != null ? factory() : Object();
}


class _ViewLineAdapter implements IViewLineForViewLines {
  _ViewLineAdapter(this._line);
  final ViewLine _line;

  @override
  Object? getDomNode() => _line.getDomNode();
  @override
  void onOptionsChanged(IViewLineOptionsForLine options) =>
      _line.onOptionsChanged(options);
  @override
  bool onSelectionChanged() => _line.onSelectionChanged();
  @override
  void onDecorationsChanged() => _line.onDecorationsChanged();
  @override
  int getColumnOfNodeOffset(Object spanNode, int offset) =>
      _line.getColumnOfNodeOffset(spanNode as IViewLineSpan, offset);
  @override
  num getWidth(DomReadingContext? context) => _line.getWidth(context);
  @override
  bool getWidthIsFast() => _line.getWidthIsFast();
  @override
  void resetCachedWidth() => _line.resetCachedWidth();
  @override
  VisibleRanges? getVisibleRangesForRange(
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  ) =>
      _line.getVisibleRangesForRange(
          lineNumber, startColumn, endColumn, context);
  @override
  bool isRenderedRTL() => _line.isRenderedRTL();
  @override
  bool needsMonospaceFontCheck() => _line.needsMonospaceFontCheck();
  @override
  bool monospaceAssumptionsAreValid() => _line.monospaceAssumptionsAreValid();
  @override
  void onMonospaceAssumptionsInvalidated() =>
      _line.onMonospaceAssumptionsInvalidated();
}

class LastRenderedData {
  LastRenderedData() : _currentVisibleRange = Range(1, 1, 1, 1);

  Range _currentVisibleRange;

  Range getCurrentVisibleRange() => _currentVisibleRange;
  void setCurrentVisibleRange(Range currentVisibleRange) =>
      _currentVisibleRange = currentVisibleRange;
}

class HorizontalRevealRangeRequest {
  HorizontalRevealRangeRequest(
    this.minimalReveal,
    this.lineNumber,
    this.startColumn,
    this.endColumn,
    this.startScrollTop,
    this.stopScrollTop,
    this.scrollType,
  )   : type = 'range',
        minLineNumber = lineNumber,
        maxLineNumber = lineNumber;

  final String type;
  final bool minimalReveal;
  final int lineNumber;
  final int startColumn;
  final int endColumn;
  final num startScrollTop;
  final num stopScrollTop;
  final int scrollType;
  final int minLineNumber;
  final int maxLineNumber;
}

class HorizontalRevealSelectionsRequest {
  HorizontalRevealSelectionsRequest(
    this.minimalReveal,
    this.selections,
    this.startScrollTop,
    this.stopScrollTop,
    this.scrollType,
  )   : type = 'selections',
        minLineNumber = _minSelectionLine(selections),
        maxLineNumber = _maxSelectionLine(selections);

  final String type;
  final bool minimalReveal;
  final List<Selection> selections;
  final num startScrollTop;
  final num stopScrollTop;
  final int scrollType;
  final int minLineNumber;
  final int maxLineNumber;
}

int _minSelectionLine(List<Selection> selections) {
  int result = selections[0].startLineNumber;
  for (int i = 1; i < selections.length; i++) {
    final int value = selections[i].startLineNumber;
    if (value < result) result = value;
  }
  return result;
}

int _maxSelectionLine(List<Selection> selections) {
  int result = selections[0].endLineNumber;
  for (int i = 1; i < selections.length; i++) {
    final int value = selections[i].endLineNumber;
    if (value > result) result = value;
  }
  return result;
}

typedef HorizontalRevealRequest = Object;

class _ScrollLeftResult {
  const _ScrollLeftResult(this.scrollLeft, this.maxHorizontalOffset, this.hasRTL);
  final num scrollLeft;
  final num maxHorizontalOffset;
  final bool hasRTL;
}

/// 1:1: `export class ViewLines`.
class ViewLines extends ViewPart implements IViewLines {
  static const int HORIZONTAL_EXTRA_PX = 30;

  ViewLines(
    ViewContext context,
    Object? viewGpuContext,
    IViewLinesFastDomNode linesContent,
  )   : _viewLinesContext = context,
        _textRangeRestingSpot = _createRestingSpot(),
        super(context) {
    final IConfigurationForViewLines conf =
        _viewLinesContext.configuration as IConfigurationForViewLines;
    final IOptionsForViewLines options = conf.options;
    final dynamic fontInfo = options.get(EditorOption.fontInfo);
    final dynamic wrappingInfo = options.get(EditorOption.wrappingInfo);

    _lineHeight = options.get(EditorOption.lineHeight) as num;
    _typicalHalfwidthCharacterWidth =
        fontInfo.typicalHalfwidthCharacterWidth as num;
    _isViewportWrapping = wrappingInfo.isViewportWrapping as bool;
    _revealHorizontalRightPadding =
        options.get(EditorOption.revealHorizontalRightPadding) as num;
    _cursorSurroundingLines =
        options.get(EditorOption.cursorSurroundingLines) as num;
    _cursorSurroundingLinesStyle =
        options.get(EditorOption.cursorSurroundingLinesStyle) as String;
    _canUseLayerHinting = !(options.get(EditorOption.disableLayerHinting) as bool);
    _viewLineOptions =
        ViewLineOptionsForViewLines(conf, _viewLinesContext.theme.type);

    _linesContent = linesContent;
    final ViewLinesCollectionFactoryForReplay? collectionFactory =
        _collectionFactoryForReplay;
    if (collectionFactory == null) {
      throw StateError('VisibleLinesCollection factory is not configured');
    }
    _visibleLines = collectionFactory(_viewLinesContext, () {
      final Object? gpu = viewGpuContext;
      return _ViewLineAdapter(ViewLine(gpu, _viewLineOptions));
    });
    domNode = _visibleLines.domNode;

    PartFingerprints.write(domNode as dynamic, PartFingerprint.ViewLines);
    domNode.setClassName('view-lines $MOUSE_CURSOR_TEXT_CSS_CLASS_NAME');
    applyFontInfo(domNode as dynamic, fontInfo as dynamic);

    _maxLineWidth = 0;
    _asyncUpdateLineWidths = _createScheduler(_updateLineWidthsSlow, 200);
    _asyncCheckMonospaceFontAssumptions =
        _createScheduler(_checkMonospaceFontAssumptions, 2000);
    _lastRenderedData = LastRenderedData();
    _horizontalRevealRequest = null;

    final dynamic stickyScroll = options.get(EditorOption.stickyScroll);
    _stickyScrollEnabled = stickyScroll.enabled as bool;
    _maxNumberStickyLines = stickyScroll.maxLineCount as num;
  }

  late final ViewContext _viewLinesContext;
  late final IViewLinesFastDomNode _linesContent;
  final Object _textRangeRestingSpot;
  late final IVisibleLinesForViewLines _visibleLines;
  late final IViewLinesFastDomNode domNode;

  late num _lineHeight;
  late num _typicalHalfwidthCharacterWidth;
  late bool _isViewportWrapping;
  late num _revealHorizontalRightPadding;
  late num _cursorSurroundingLines;
  late String _cursorSurroundingLinesStyle;
  late bool _canUseLayerHinting;
  late ViewLineOptionsForViewLines _viewLineOptions;

  num _maxLineWidth = 0;
  late final IViewLinesScheduler _asyncUpdateLineWidths;
  late final IViewLinesScheduler _asyncCheckMonospaceFontAssumptions;

  Object? _horizontalRevealRequest;
  late final LastRenderedData _lastRenderedData;

  late bool _stickyScrollEnabled;
  late num _maxNumberStickyLines;

  IViewLayoutForViewLines get _layout =>
      _viewLinesContext.viewLayout as IViewLayoutForViewLines;
  IViewModelForViewLines get _model =>
      _viewLinesContext.viewModel as IViewModelForViewLines;

  @override
  void dispose() {
    _asyncUpdateLineWidths.dispose();
    _asyncCheckMonospaceFontAssumptions.dispose();
    super.dispose();
  }

  IViewLinesFastDomNode getDomNode() => domNode;

  /// Replay-only access to the private `LastRenderedData` carrier.
  void setCurrentVisibleRangeForReplay(Range range) =>
      _lastRenderedData.setCurrentVisibleRange(range);

  /// Replay-only flush of the line-width scheduler.
  void flushUpdateLineWidthsForReplay() => _asyncUpdateLineWidths.flush();

  /// Replay-only flush of the monospace-assumption scheduler.
  void flushMonospaceCheckForReplay() =>
      _asyncCheckMonospaceFontAssumptions.flush();

  // ---- begin view event handlers

  @override
  bool onConfigurationChanged(Object e) {
    _visibleLines.onConfigurationChanged(e);
    final dynamic configEvent = e;
    if (configEvent.hasChanged(EditorOption.wrappingInfo) as bool) {
      _maxLineWidth = 0;
    }

    final IConfigurationForViewLines conf =
        _viewLinesContext.configuration as IConfigurationForViewLines;
    final IOptionsForViewLines options = conf.options;
    final dynamic fontInfo = options.get(EditorOption.fontInfo);
    final dynamic wrappingInfo = options.get(EditorOption.wrappingInfo);

    _lineHeight = options.get(EditorOption.lineHeight) as num;
    _typicalHalfwidthCharacterWidth =
        fontInfo.typicalHalfwidthCharacterWidth as num;
    _isViewportWrapping = wrappingInfo.isViewportWrapping as bool;
    _revealHorizontalRightPadding =
        options.get(EditorOption.revealHorizontalRightPadding) as num;
    _cursorSurroundingLines =
        options.get(EditorOption.cursorSurroundingLines) as num;
    _cursorSurroundingLinesStyle =
        options.get(EditorOption.cursorSurroundingLinesStyle) as String;
    _canUseLayerHinting = !(options.get(EditorOption.disableLayerHinting) as bool);

    final dynamic stickyScroll = options.get(EditorOption.stickyScroll);
    _stickyScrollEnabled = stickyScroll.enabled as bool;
    _maxNumberStickyLines = stickyScroll.maxLineCount as num;

    applyFontInfo(domNode as dynamic, fontInfo as dynamic);
    _onOptionsMaybeChanged();

    if (configEvent.hasChanged(EditorOption.layoutInfo) as bool) {
      _maxLineWidth = 0;
    }
    return true;
  }

  bool _onOptionsMaybeChanged() {
    final IConfigurationForViewLines conf =
        _viewLinesContext.configuration as IConfigurationForViewLines;
    final ViewLineOptionsForViewLines newViewLineOptions =
        ViewLineOptionsForViewLines(conf, _viewLinesContext.theme.type);
    if (!_viewLineOptions.equals(newViewLineOptions)) {
      _viewLineOptions = newViewLineOptions;
      final int startLineNumber = _visibleLines.getStartLineNumber();
      final int endLineNumber = _visibleLines.getEndLineNumber();
      for (int lineNumber = startLineNumber;
          lineNumber <= endLineNumber;
          lineNumber++) {
        _visibleLines.getVisibleLine(lineNumber).onOptionsChanged(_viewLineOptions);
      }
      return true;
    }
    return false;
  }

  @override
  bool onCursorStateChanged(Object e) {
    final int rendStartLineNumber = _visibleLines.getStartLineNumber();
    final int rendEndLineNumber = _visibleLines.getEndLineNumber();
    bool r = false;
    for (int lineNumber = rendStartLineNumber;
        lineNumber <= rendEndLineNumber;
        lineNumber++) {
      r = _visibleLines.getVisibleLine(lineNumber).onSelectionChanged() || r;
    }
    return r;
  }

  @override
  bool onDecorationsChanged(Object e) {
    final int rendStartLineNumber = _visibleLines.getStartLineNumber();
    final int rendEndLineNumber = _visibleLines.getEndLineNumber();
    for (int lineNumber = rendStartLineNumber;
        lineNumber <= rendEndLineNumber;
        lineNumber++) {
      _visibleLines.getVisibleLine(lineNumber).onDecorationsChanged();
    }
    return true;
  }

  @override
  bool onFlushed(Object e) {
    final bool shouldRender =
        _visibleLines.onFlushed(e, _viewLineOptions.useGpu);
    _maxLineWidth = 0;
    return shouldRender;
  }

  @override
  bool onLinesChanged(Object e) => _visibleLines.onLinesChanged(e);

  @override
  bool onLinesDeleted(Object e) => _visibleLines.onLinesDeleted(e);

  @override
  bool onLinesInserted(Object e) => _visibleLines.onLinesInserted(e);

  @override
  bool onRevealRangeRequest(Object e) {
    final dynamic event = e;
    final num desiredScrollTop = _computeScrollTopToRevealRange(
      _layout.getFutureViewport(),
      event.source as String?,
      event.minimalReveal as bool,
      event.range as Range?,
      event.selections as List<Selection>?,
      event.verticalType as int,
    );
    if (desiredScrollTop == -1) return false;

    Map<String, num> newScrollPosition =
        _layout.validateScrollPosition(<String, num>{'scrollTop': desiredScrollTop});
    if (event.revealHorizontal as bool) {
      final Range? range = event.range as Range?;
      if (range != null && range.startLineNumber != range.endLineNumber) {
        newScrollPosition = <String, num>{
          'scrollTop': newScrollPosition['scrollTop'] ?? 0,
          'scrollLeft': 0,
        };
      } else if (range != null) {
        _horizontalRevealRequest = HorizontalRevealRangeRequest(
          event.minimalReveal as bool,
          range.startLineNumber,
          range.startColumn,
          range.endColumn,
          _layout.getCurrentScrollTop(),
          newScrollPosition['scrollTop'] ?? 0,
          event.scrollType as int,
        );
      } else if (event.selections != null &&
          (event.selections as List).isNotEmpty) {
        _horizontalRevealRequest = HorizontalRevealSelectionsRequest(
          event.minimalReveal as bool,
          event.selections as List<Selection>,
          _layout.getCurrentScrollTop(),
          newScrollPosition['scrollTop'] ?? 0,
          event.scrollType as int,
        );
      }
    } else {
      _horizontalRevealRequest = null;
    }

    final num scrollTopDelta =
        (_layout.getCurrentScrollTop() - (newScrollPosition['scrollTop'] ?? 0)).abs();
    final int scrollType =
        scrollTopDelta <= _lineHeight ? ScrollType.Immediate : event.scrollType as int;
    _model.viewLayout.setScrollPosition(newScrollPosition, scrollType);
    return true;
  }

  @override
  bool onScrollChanged(Object e) {
    final dynamic event = e;
    final Object? request = _horizontalRevealRequest;
    if (request != null && event.scrollLeftChanged as bool) {
      _horizontalRevealRequest = null;
    }
    if (request != null && event.scrollTopChanged as bool) {
      final num min = _minNum((request as dynamic).startScrollTop as num,
          (request as dynamic).stopScrollTop as num);
      final num max = _maxNum((request as dynamic).startScrollTop as num,
          (request as dynamic).stopScrollTop as num);
      final num scrollTop = event.scrollTop as num;
      if (scrollTop < min || scrollTop > max) {
        _horizontalRevealRequest = null;
      }
    }
    domNode.setWidth(event.scrollWidth as num);
    return _visibleLines.onScrollChanged(e) ||
        event.scrollTopChanged as bool ||
        event.scrollLeftChanged as bool;
  }

  @override
  bool onTokensChanged(Object e) => _visibleLines.onTokensChanged(e);

  @override
  bool onZonesChanged(Object e) {
    _model.viewLayout.setMaxLineWidth(_maxLineWidth);
    return _visibleLines.onZonesChanged(e);
  }

  @override
  bool onThemeChanged(Object e) => _onOptionsMaybeChanged();

  // ---- end view event handlers

  // ----------- HELPERS FOR OTHERS

  Position? getPositionFromDOMInfo(Object spanNode, int offset) {
    final Object? viewLineDomNode = _getViewLineDomNode(spanNode);
    if (viewLineDomNode == null) return null;
    final int lineNumber = _getLineNumberFor(viewLineDomNode);
    if (lineNumber == -1) return null;
    if (lineNumber < 1 || lineNumber > _model.getLineCount()) return null;
    if (_model.getLineMaxColumn(lineNumber) == 1) {
      return Position(lineNumber, 1);
    }

    final int rendStartLineNumber = _visibleLines.getStartLineNumber();
    final int rendEndLineNumber = _visibleLines.getEndLineNumber();
    if (lineNumber < rendStartLineNumber || lineNumber > rendEndLineNumber) {
      return null;
    }

    int column = _visibleLines
        .getVisibleLine(lineNumber)
        .getColumnOfNodeOffset(spanNode, offset);
    final int minColumn = _model.getLineMinColumn(lineNumber);
    if (column < minColumn) column = minColumn;
    return Position(lineNumber, column);
  }

  Object? _getViewLineDomNode(Object? node) {
    while (node != null) {
      final dynamic current = node;
      if ((current.nodeType as int) != 1) break;
      if (current.className == ViewLine.CLASS_NAME) return node;
      node = current.parentElement as Object?;
    }
    return null;
  }

  int _getLineNumberFor(Object domNode) {
    final int startLineNumber = _visibleLines.getStartLineNumber();
    final int endLineNumber = _visibleLines.getEndLineNumber();
    for (int lineNumber = startLineNumber;
        lineNumber <= endLineNumber;
        lineNumber++) {
      if (identical(domNode, _visibleLines.getVisibleLine(lineNumber).getDomNode())) {
        return lineNumber;
      }
    }
    return -1;
  }

  num getLineWidth(int lineNumber) {
    final int rendStartLineNumber = _visibleLines.getStartLineNumber();
    final int rendEndLineNumber = _visibleLines.getEndLineNumber();
    if (lineNumber < rendStartLineNumber || lineNumber > rendEndLineNumber) {
      return -1;
    }
    final DomReadingContext context = DomReadingContext(
      _textRangeRestingSpot as dynamic,
      _textRangeRestingSpot,
    );
    final num result = _visibleLines.getVisibleLine(lineNumber).getWidth(context);
    _updateLineWidthsSlowIfDomDidLayout(context);
    return result;
  }

  void resetLineWidthCaches() {
    final int rendStartLineNumber = _visibleLines.getStartLineNumber();
    final int rendEndLineNumber = _visibleLines.getEndLineNumber();
    for (int lineNumber = rendStartLineNumber;
        lineNumber <= rendEndLineNumber;
        lineNumber++) {
      _visibleLines.getVisibleLine(lineNumber).resetCachedWidth();
    }
  }

  @override
  List<LineVisibleRanges>? linesVisibleRangesForRange(
    Range range,
    bool includeNewLines,
  ) {
    final int originalEndLineNumber = range.endLineNumber;
    final Range? intersection =
        Range.intersectRangesStatic(range, _lastRenderedData.getCurrentVisibleRange());
    if (intersection == null) return null;

    final List<LineVisibleRanges> visibleRanges = <LineVisibleRanges>[];
    final DomReadingContext domReadingContext = DomReadingContext(
      _textRangeRestingSpot as dynamic,
      _textRangeRestingSpot,
    );

    int nextLineModelLineNumber = 0;
    if (includeNewLines) {
      nextLineModelLineNumber = _convertToModelLineNumber(
        Position(intersection.startLineNumber, 1),
      );
    }

    final int rendStartLineNumber = _visibleLines.getStartLineNumber();
    final int rendEndLineNumber = _visibleLines.getEndLineNumber();
    for (int lineNumber = intersection.startLineNumber;
        lineNumber <= intersection.endLineNumber;
        lineNumber++) {
      if (lineNumber < rendStartLineNumber || lineNumber > rendEndLineNumber) {
        continue;
      }
      final int startColumn =
          lineNumber == intersection.startLineNumber ? intersection.startColumn : 1;
      final bool continuesInNextLine = lineNumber != originalEndLineNumber;
      final int endColumn = continuesInNextLine
          ? _model.getLineMaxColumn(lineNumber)
          : intersection.endColumn;
      final VisibleRanges? visibleRangesForLine = _visibleLines
          .getVisibleLine(lineNumber)
          .getVisibleRangesForRange(
              lineNumber, startColumn, endColumn, domReadingContext);
      if (visibleRangesForLine == null) continue;

      if (includeNewLines && lineNumber < originalEndLineNumber) {
        final int currentLineModelLineNumber = nextLineModelLineNumber;
        nextLineModelLineNumber = _convertToModelLineNumber(
          Position(lineNumber + 1, 1),
        );
        if (currentLineModelLineNumber != nextLineModelLineNumber) {
          final dynamic last =
              visibleRangesForLine.ranges[visibleRangesForLine.ranges.length - 1];
          last.width += _typicalHalfwidthCharacterWidth;
          if (_model.getTextDirection(currentLineModelLineNumber) ==
              TextDirection.RTL) {
            last.left -= _typicalHalfwidthCharacterWidth;
          }
        }
      }

      visibleRanges.add(LineVisibleRanges(
        visibleRangesForLine.outsideRenderedLine,
        lineNumber,
        HorizontalRange.from(visibleRangesForLine.ranges),
        continuesInNextLine,
      ));
    }

    _updateLineWidthsSlowIfDomDidLayout(domReadingContext);
    if (visibleRanges.isEmpty) return null;
    return visibleRanges;
  }

  int _convertToModelLineNumber(Position position) {
    final dynamic converter = _model.coordinatesConverter;
    final Position modelPosition =
        converter.convertViewPositionToModelPosition(position) as Position;
    return modelPosition.lineNumber;
  }

  VisibleRanges? _visibleRangesForLineRange(
    int lineNumber,
    int startColumn,
    int endColumn,
  ) {
    if (lineNumber < _visibleLines.getStartLineNumber() ||
        lineNumber > _visibleLines.getEndLineNumber()) {
      return null;
    }
    final DomReadingContext domReadingContext = DomReadingContext(
      _textRangeRestingSpot as dynamic,
      _textRangeRestingSpot,
    );
    final VisibleRanges? result = _visibleLines
        .getVisibleLine(lineNumber)
        .getVisibleRangesForRange(
            lineNumber, startColumn, endColumn, domReadingContext);
    _updateLineWidthsSlowIfDomDidLayout(domReadingContext);
    return result;
  }

  bool _lineIsRenderedRTL(int lineNumber) {
    if (lineNumber < _visibleLines.getStartLineNumber() ||
        lineNumber > _visibleLines.getEndLineNumber()) {
      return false;
    }
    return _visibleLines.getVisibleLine(lineNumber).isRenderedRTL();
  }

  @override
  HorizontalPosition? visibleRangeForPosition(Position position) {
    final VisibleRanges? visibleRanges = _visibleRangesForLineRange(
      position.lineNumber,
      position.column,
      position.column,
    );
    if (visibleRanges == null) return null;
    return HorizontalPosition(
      visibleRanges.outsideRenderedLine,
      visibleRanges.ranges[0].left,
    );
  }

  // --- implementation

  void updateLineWidths() => _updateLineWidths(false);
  bool _updateLineWidthsFast() => _updateLineWidths(true);
  void _updateLineWidthsSlow() => _updateLineWidths(false);

  void _updateLineWidthsSlowIfDomDidLayout(DomReadingContext domReadingContext) {
    if (!domReadingContext.didDomLayout) return;
    if (!_asyncUpdateLineWidths.isScheduled()) return;
    _asyncUpdateLineWidths.cancel();
    _updateLineWidthsSlow();
  }

  bool _updateLineWidths([bool fast = false]) {
    final int rendStartLineNumber = _visibleLines.getStartLineNumber();
    final int rendEndLineNumber = _visibleLines.getEndLineNumber();

    num localMaxLineWidth = 1;
    bool allWidthsComputed = true;
    for (int lineNumber = rendStartLineNumber;
        lineNumber <= rendEndLineNumber;
        lineNumber++) {
      final IViewLineForViewLines visibleLine =
          _visibleLines.getVisibleLine(lineNumber);
      if (fast && !visibleLine.getWidthIsFast()) {
        allWidthsComputed = false;
        continue;
      }
      localMaxLineWidth =
          _maxNum(localMaxLineWidth, visibleLine.getWidth(null));
    }

    if (allWidthsComputed &&
        rendStartLineNumber == 1 &&
        rendEndLineNumber == _model.getLineCount()) {
      _maxLineWidth = 0;
    }
    _ensureMaxLineWidth(localMaxLineWidth);
    return allWidthsComputed;
  }

  void _checkMonospaceFontAssumptions() {
    int longestLineNumber = -1;
    num longestWidth = -1;
    final int rendStartLineNumber = _visibleLines.getStartLineNumber();
    final int rendEndLineNumber = _visibleLines.getEndLineNumber();
    for (int lineNumber = rendStartLineNumber;
        lineNumber <= rendEndLineNumber;
        lineNumber++) {
      final IViewLineForViewLines visibleLine =
          _visibleLines.getVisibleLine(lineNumber);
      if (visibleLine.needsMonospaceFontCheck()) {
        final num lineWidth = visibleLine.getWidth(null);
        if (lineWidth > longestWidth) {
          longestWidth = lineWidth;
          longestLineNumber = lineNumber;
        }
      }
    }
    if (longestLineNumber == -1) return;
    if (!_visibleLines
        .getVisibleLine(longestLineNumber)
        .monospaceAssumptionsAreValid()) {
      for (int lineNumber = rendStartLineNumber;
          lineNumber <= rendEndLineNumber;
          lineNumber++) {
        _visibleLines
            .getVisibleLine(lineNumber)
            .onMonospaceAssumptionsInvalidated();
      }
    }
  }

  @override
  void prepareRender([Object? ctx]) {
    throw StateError('Not supported');
  }

  @override
  void render([Object? ctx]) {
    throw StateError('Not supported');
  }

  void renderText(ViewportData viewportData) {
    _visibleLines.renderLines(viewportData);
    _lastRenderedData.setCurrentVisibleRange(viewportData.visibleRange);
    domNode.setWidth(_layout.getScrollWidth());
    domNode.setHeight(_minNum(_layout.getScrollHeight(), 1000000));

    final Object? request = _horizontalRevealRequest;
    if (request != null) {
      final dynamic r = request;
      if (viewportData.startLineNumber <= (r.minLineNumber as int) &&
          (r.maxLineNumber as int) <= viewportData.endLineNumber) {
        _horizontalRevealRequest = null;
        onDidRender();
        final _ScrollLeftResult? newScrollLeft =
            _computeScrollLeftToReveal(request);
        if (newScrollLeft != null) {
          if (!_isViewportWrapping && !newScrollLeft.hasRTL) {
            _ensureMaxLineWidth(newScrollLeft.maxHorizontalOffset);
          }
          _model.viewLayout.setScrollPosition(<String, num>{
            'scrollLeft': newScrollLeft.scrollLeft,
          }, r.scrollType as int);
        }
      }
    }

    if (!_updateLineWidthsFast()) {
      _asyncUpdateLineWidths.schedule();
    } else {
      _asyncUpdateLineWidths.cancel();
    }

    if (_isLinux() && !_asyncCheckMonospaceFontAssumptions.isScheduled()) {
      final int rendStartLineNumber = _visibleLines.getStartLineNumber();
      final int rendEndLineNumber = _visibleLines.getEndLineNumber();
      for (int lineNumber = rendStartLineNumber;
          lineNumber <= rendEndLineNumber;
          lineNumber++) {
        if (_visibleLines.getVisibleLine(lineNumber).needsMonospaceFontCheck()) {
          _asyncCheckMonospaceFontAssumptions.schedule();
          break;
        }
      }
    }

    _linesContent.setLayerHinting(_canUseLayerHinting);
    _linesContent.setContain('strict');
    final num adjustedScrollTop =
        _layout.getCurrentScrollTop() - viewportData.bigNumbersDelta;
    _linesContent.setTop(-adjustedScrollTop);
    _linesContent.setLeft(-_layout.getCurrentScrollLeft());
  }

  // --- width

  void _ensureMaxLineWidth(num lineWidth) {
    if (_viewLineOptions.useGpu) return;
    final int iLineWidth = lineWidth.ceil();
    if (_maxLineWidth < iLineWidth) {
      _maxLineWidth = iLineWidth;
      _model.viewLayout.setMaxLineWidth(_maxLineWidth);
    }
  }

  num _computeScrollTopToRevealRange(
    Viewport viewport,
    String? source,
    bool minimalReveal,
    Range? range,
    List<Selection>? selections,
    int verticalType,
  ) {
    final num viewportStartY = viewport.top;
    final num viewportHeight = viewport.height;
    final num viewportEndY = viewportStartY + viewportHeight;
    late bool boxIsSingleRange;
    late num boxStartY;
    late num boxEndY;

    if (selections != null && selections.isNotEmpty) {
      final int minLineNumber = _minSelectionLine(selections);
      final int maxLineNumber = _maxSelectionLine(selections);
      boxIsSingleRange = false;
      boxStartY = _layout.getVerticalOffsetForLineNumber(minLineNumber);
      boxEndY =
          _layout.getVerticalOffsetForLineNumber(maxLineNumber) + _lineHeight;
    } else if (range != null) {
      boxIsSingleRange = true;
      boxStartY = _layout.getVerticalOffsetForLineNumber(range.startLineNumber);
      boxEndY = _layout.getVerticalOffsetForLineNumber(range.endLineNumber) +
          _lineHeight;
    } else {
      return -1;
    }

    final bool shouldIgnoreScrollOff = (source == 'mouse' || minimalReveal) &&
        _cursorSurroundingLinesStyle == 'default';

    num paddingTop = 0;
    num paddingBottom = 0;
    if (!shouldIgnoreScrollOff) {
      final num maxLinesInViewport = viewportHeight / _lineHeight;
      final num surroundingLines = _maxNum(
        _cursorSurroundingLines,
        _stickyScrollEnabled ? _maxNumberStickyLines : 0,
      );
      final num contextPadding =
          _minNum(maxLinesInViewport / 2, surroundingLines);
      paddingTop = contextPadding * _lineHeight;
      paddingBottom = _maxNum(0, contextPadding - 1) * _lineHeight;
    } else if (!minimalReveal) {
      paddingTop = _lineHeight;
    }
    if (!minimalReveal &&
        (verticalType == VerticalRevealType.Simple ||
            verticalType == VerticalRevealType.Bottom)) {
      paddingBottom += _lineHeight;
    }

    boxStartY -= paddingTop;
    boxEndY += paddingBottom;
    late num newScrollTop;

    if (boxEndY - boxStartY > viewportHeight) {
      if (!boxIsSingleRange) return -1;
      newScrollTop = boxStartY;
    } else if (verticalType == VerticalRevealType.NearTop ||
        verticalType == VerticalRevealType.NearTopIfOutsideViewport) {
      if (verticalType == VerticalRevealType.NearTopIfOutsideViewport &&
          viewportStartY <= boxStartY &&
          boxEndY <= viewportEndY) {
        newScrollTop = viewportStartY;
      } else {
        final num desiredGapAbove =
            _maxNum(5 * _lineHeight, viewportHeight * 0.2);
        final num desiredScrollTop = boxStartY - desiredGapAbove;
        final num minScrollTop = boxEndY - viewportHeight;
        newScrollTop = _maxNum(minScrollTop, desiredScrollTop);
      }
    } else if (verticalType == VerticalRevealType.Center ||
        verticalType == VerticalRevealType.CenterIfOutsideViewport) {
      if (verticalType == VerticalRevealType.CenterIfOutsideViewport &&
          viewportStartY <= boxStartY &&
          boxEndY <= viewportEndY) {
        newScrollTop = viewportStartY;
      } else {
        final num boxMiddleY = (boxStartY + boxEndY) / 2;
        newScrollTop = _maxNum(0, boxMiddleY - viewportHeight / 2);
      }
    } else {
      newScrollTop = _computeMinimumScrolling(
        viewportStartY,
        viewportEndY,
        boxStartY,
        boxEndY,
        verticalType == VerticalRevealType.Top,
        verticalType == VerticalRevealType.Bottom,
      );
    }
    return newScrollTop;
  }

  _ScrollLeftResult? _computeScrollLeftToReveal(
    HorizontalRevealRequest horizontalRevealRequest,
  ) {
    final dynamic request = horizontalRevealRequest;
    final Viewport viewport = _layout.getCurrentViewport();
    final dynamic layoutInfo = _optionsForViewLines().get(EditorOption.layoutInfo);
    final num viewportStartX = viewport.left;
    final num viewportEndX =
        viewportStartX + viewport.width - (layoutInfo.verticalScrollbarWidth as num);

    num boxStartX = Constants.MAX_SAFE_SMALL_INTEGER.toDouble();
    num boxEndX = 0;
    bool hasRTL = false;
    if (request.type == 'range') {
      hasRTL = _lineIsRenderedRTL(request.lineNumber as int);
      final VisibleRanges? visibleRanges = _visibleRangesForLineRange(
        request.lineNumber as int,
        request.startColumn as int,
        request.endColumn as int,
      );
      if (visibleRanges == null) return null;
      for (final dynamic visibleRange in visibleRanges.ranges) {
        boxStartX = _minNum(boxStartX, _jsRound(visibleRange.left as num));
        boxEndX = _maxNum(
          boxEndX,
          _jsRound((visibleRange.left as num) + (visibleRange.width as num)),
        );
      }
    } else {
      final List<Selection> selections = request.selections as List<Selection>;
      for (final Selection selection in selections) {
        if (selection.startLineNumber != selection.endLineNumber) return null;
        final VisibleRanges? visibleRanges = _visibleRangesForLineRange(
          selection.startLineNumber,
          selection.startColumn,
          selection.endColumn,
        );
        hasRTL = hasRTL || _lineIsRenderedRTL(selection.startLineNumber);
        if (visibleRanges == null) return null;
        for (final dynamic visibleRange in visibleRanges.ranges) {
          boxStartX = _minNum(boxStartX, _jsRound(visibleRange.left as num));
          boxEndX = _maxNum(
            boxEndX,
            _jsRound((visibleRange.left as num) + (visibleRange.width as num)),
          );
        }
      }
    }

    if (!(request.minimalReveal as bool)) {
      boxStartX = _maxNum(0, boxStartX - HORIZONTAL_EXTRA_PX);
      boxEndX += _revealHorizontalRightPadding;
    }
    if (request.type == 'selections' && boxEndX - boxStartX > viewport.width) {
      return null;
    }

    final num newScrollLeft = _computeMinimumScrolling(
      viewportStartX,
      viewportEndX,
      boxStartX,
      boxEndX,
    );
    return _ScrollLeftResult(newScrollLeft, boxEndX, hasRTL);
  }

  IOptionsForViewLines _optionsForViewLines() =>
      (_viewLinesContext.configuration as IConfigurationForViewLines).options;

  num _computeMinimumScrolling(
    num viewportStart,
    num viewportEnd,
    num boxStart,
    num boxEnd, [
    bool revealAtStart = false,
    bool revealAtEnd = false,
  ]) {
    final int start = _jsToInt32(viewportStart);
    final int end = _jsToInt32(viewportEnd);
    final int bStart = _jsToInt32(boxStart);
    final int bEnd = _jsToInt32(boxEnd);
    final int viewportLength = end - start;
    final int boxLength = bEnd - bStart;

    if (boxLength < viewportLength) {
      if (revealAtStart) return bStart;
      if (revealAtEnd) return _maxNum(0, bEnd - viewportLength);
      if (bStart < start) return bStart;
      if (bEnd > end) return _maxNum(0, bEnd - viewportLength);
    } else {
      return bStart;
    }
    return start;
  }
}

num _minNum(num a, num b) => a < b ? a : b;
num _maxNum(num a, num b) => a > b ? a : b;

int _jsRound(num value) => (value + 0.5).floor();

int _jsToInt32(num value) {
  final int v = value.toInt();
  if (v >= -2147483648 && v <= 2147483647) return v;
  return ((v + 0x80000000) % 0x100000000).toInt() - 0x80000000;
}
