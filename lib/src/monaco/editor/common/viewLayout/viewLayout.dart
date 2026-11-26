// 1:1 port of vscode/src/vs/editor/common/viewLayout/viewLayout.ts
// Adaptations (documented inline):
//   - erased `IViewLayout` is not declared (viewModel.dart carries it as an
//     opaque interface); the public member surface is preserved verbatim.
//   - JS `value | 0` -> `.toInt()` (toward zero); pixel inputs are small.
//   - `saveState()` object literal -> `Map<String, num>`.
//   - option values are read via `dynamic`, matching the repo's option ports.
// Runtime truth: tool/ts2dart/_batch339_truth.cjs.

import 'dart:math' show max;

import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable, IDisposable;
import '../../../base/common/scrollable.dart'
    show
        IScrollPosition,
        NewScrollDimensions,
        NewScrollPosition,
        ScrollEvent,
        Scrollable,
        ScrollableOptions,
        ScrollbarVisibility;
import '../config/editorConfiguration.dart' show IEditorConfiguration;
import '../config/editorOptions.dart'
    show ConfigurationChangedEvent, EditorOption;
import '../editorCommon.dart' show ScrollType;
import '../viewModel.dart' show Viewport;
import '../viewModelEventDispatcher.dart' show ContentSizeChangedEvent;
import 'lineHeights.dart' show CustomLineHeightData;
import 'linesLayout.dart'
    show
        EditorWhitespace,
        ILineHeightChangeAccessor,
        IWhitespaceChangeAccessor,
        LinesLayout,
        PartialViewLinesViewportData,
        ViewWhitespaceViewportData;

/// 1:1: `const SMOOTH_SCROLLING_TIME = 125`.
const int SMOOTH_SCROLLING_TIME = 125;

/// 1:1: `class EditorScrollDimensions`.
class EditorScrollDimensions {
  late final int width;
  late final int contentWidth;
  late final int scrollWidth;
  late final int height;
  late final int contentHeight;
  late final int scrollHeight;

  EditorScrollDimensions(
    num widthArg,
    num contentWidthArg,
    num heightArg,
    num contentHeightArg,
  ) {
    int w = widthArg.toInt();
    int cw = contentWidthArg.toInt();
    int h = heightArg.toInt();
    int ch = contentHeightArg.toInt();

    if (w < 0) {
      w = 0;
    }
    if (cw < 0) {
      cw = 0;
    }
    if (h < 0) {
      h = 0;
    }
    if (ch < 0) {
      ch = 0;
    }

    width = w;
    contentWidth = cw;
    scrollWidth = max(w, cw);
    height = h;
    contentHeight = ch;
    scrollHeight = max(h, ch);
  }

  /// 1:1: `public equals(other)`.
  bool equals(EditorScrollDimensions other) =>
      width == other.width &&
      contentWidth == other.contentWidth &&
      height == other.height &&
      contentHeight == other.contentHeight;
}

/// 1:1: `class EditorScrollable extends Disposable`.
class EditorScrollable extends Disposable {
  late final Scrollable _scrollable;
  late EditorScrollDimensions _dimensions;

  late final Event<ScrollEvent> onDidScroll;

  late final Emitter<ContentSizeChangedEvent> _onDidContentSizeChange;
  late final Event<ContentSizeChangedEvent> onDidContentSizeChange;

  EditorScrollable(
    num smoothScrollDuration,
    IDisposable Function(void Function() callback) scheduleAtNextAnimationFrame,
  ) {
    _dimensions = EditorScrollDimensions(0, 0, 0, 0);
    _onDidContentSizeChange = register(Emitter<ContentSizeChangedEvent>());
    onDidContentSizeChange = _onDidContentSizeChange.event;
    _scrollable = register(Scrollable(ScrollableOptions(
      forceIntegerValues: true,
      smoothScrollDuration: smoothScrollDuration,
      scheduleAtNextAnimationFrame: scheduleAtNextAnimationFrame,
    )));
    onDidScroll = _scrollable.onScroll;
  }

  /// 1:1: `public getScrollable()`.
  Scrollable getScrollable() => _scrollable;

  /// 1:1: `public setSmoothScrollDuration()`.
  void setSmoothScrollDuration(num smoothScrollDuration) =>
      _scrollable.setSmoothScrollDuration(smoothScrollDuration);

  /// 1:1: `public validateScrollPosition()`.
  IScrollPosition validateScrollPosition(NewScrollPosition scrollPosition) =>
      _scrollable.validateScrollPosition(scrollPosition);

  /// 1:1: `public getScrollDimensions()`.
  EditorScrollDimensions getScrollDimensions() => _dimensions;

  /// 1:1: `public setScrollDimensions()`.
  void setScrollDimensions(EditorScrollDimensions dimensions) {
    if (_dimensions.equals(dimensions)) {
      return;
    }

    final EditorScrollDimensions oldDimensions = _dimensions;
    _dimensions = dimensions;

    _scrollable.setScrollDimensions(
      NewScrollDimensions(
        width: dimensions.width,
        scrollWidth: dimensions.scrollWidth,
        height: dimensions.height,
        scrollHeight: dimensions.scrollHeight,
      ),
      true,
    );

    final bool contentWidthChanged =
        oldDimensions.contentWidth != dimensions.contentWidth;
    final bool contentHeightChanged =
        oldDimensions.contentHeight != dimensions.contentHeight;
    if (contentWidthChanged || contentHeightChanged) {
      _onDidContentSizeChange.fire(ContentSizeChangedEvent(
        oldDimensions.contentWidth,
        oldDimensions.contentHeight,
        dimensions.contentWidth,
        dimensions.contentHeight,
      ));
    }
  }

  /// 1:1: `public getFutureScrollPosition()`.
  IScrollPosition getFutureScrollPosition() =>
      _scrollable.getFutureScrollPosition();

  /// 1:1: `public getCurrentScrollPosition()`.
  IScrollPosition getCurrentScrollPosition() =>
      _scrollable.getCurrentScrollPosition();

  /// 1:1: `public setScrollPositionNow()`.
  void setScrollPositionNow(NewScrollPosition update) =>
      _scrollable.setScrollPositionNow(update);

  /// 1:1: `public setScrollPositionSmooth()`.
  void setScrollPositionSmooth(NewScrollPosition update) =>
      _scrollable.setScrollPositionSmooth(update);

  /// 1:1: `public hasPendingScrollAnimation()`.
  bool hasPendingScrollAnimation() => _scrollable.hasPendingScrollAnimation();
}

/// 1:1: `export class ViewLayout extends Disposable implements IViewLayout`.
class ViewLayout extends Disposable {
  late final IEditorConfiguration _configuration;
  late final LinesLayout _linesLayout;
  num _maxLineWidth = 0;
  num _overlayWidgetsMinWidth = 0;

  late final EditorScrollable _scrollable;
  late final Event<ScrollEvent> onDidScroll;
  late final Event<ContentSizeChangedEvent> onDidContentSizeChange;

  ViewLayout(
    IEditorConfiguration configuration,
    int lineCount,
    List<CustomLineHeightData> customLineHeightData,
    IDisposable Function(void Function() callback) scheduleAtNextAnimationFrame,
  ) {
    _configuration = configuration;
    final dynamic options = _configuration.options;
    final dynamic layoutInfo = options.get(EditorOption.layoutInfo);
    final dynamic padding = options.get(EditorOption.padding);

    _linesLayout = LinesLayout(
      lineCount,
      options.get(EditorOption.lineHeight) as num,
      padding.top as num,
      padding.bottom as num,
      customLineHeightData,
    );
    _scrollable = register(EditorScrollable(0, scheduleAtNextAnimationFrame));
    _configureSmoothScrollDuration();

    _scrollable.setScrollDimensions(EditorScrollDimensions(
      layoutInfo.contentWidth as num,
      0,
      layoutInfo.height as num,
      0,
    ));
    onDidScroll = _scrollable.onDidScroll;
    onDidContentSizeChange = _scrollable.onDidContentSizeChange;

    _updateHeight();
  }

  /// 1:1: `public getScrollable()`.
  Scrollable getScrollable() => _scrollable.getScrollable();

  /// 1:1: `public onHeightMaybeChanged()`.
  void onHeightMaybeChanged() => _updateHeight();

  /// 1:1: `private _configureSmoothScrollDuration()`.
  void _configureSmoothScrollDuration() {
    final dynamic options = _configuration.options;
    _scrollable.setSmoothScrollDuration(
      options.get(EditorOption.smoothScrolling) == true
          ? SMOOTH_SCROLLING_TIME
          : 0,
    );
  }

  // ---- begin view event handlers

  /// 1:1: `public onConfigurationChanged(e)`.
  void onConfigurationChanged(ConfigurationChangedEvent e) {
    final dynamic options = _configuration.options;
    if (e.hasChanged(EditorOption.lineHeight)) {
      _linesLayout.setDefaultLineHeight(
          options.get(EditorOption.lineHeight) as num);
    }
    if (e.hasChanged(EditorOption.padding)) {
      final dynamic padding = options.get(EditorOption.padding);
      _linesLayout.setPadding(padding.top as num, padding.bottom as num);
    }
    if (e.hasChanged(EditorOption.layoutInfo)) {
      final dynamic layoutInfo = options.get(EditorOption.layoutInfo);
      final num width = layoutInfo.contentWidth as num;
      final num height = layoutInfo.height as num;
      final EditorScrollDimensions scrollDimensions =
          _scrollable.getScrollDimensions();
      _scrollable.setScrollDimensions(EditorScrollDimensions(
        width,
        scrollDimensions.contentWidth,
        height,
        _getContentHeight(width, height, scrollDimensions.contentWidth),
      ));
    } else {
      _updateHeight();
    }
    if (e.hasChanged(EditorOption.smoothScrolling)) {
      _configureSmoothScrollDuration();
    }
  }

  /// 1:1: `public onFlushed()`.
  void onFlushed(int lineCount, List<CustomLineHeightData> customLineHeightData) =>
      _linesLayout.onFlushed(lineCount, customLineHeightData);

  /// 1:1: `public onLinesDeleted()`.
  void onLinesDeleted(int fromLineNumber, int toLineNumber) =>
      _linesLayout.onLinesDeleted(fromLineNumber, toLineNumber);

  /// 1:1: `public onLinesInserted()`.
  void onLinesInserted(int fromLineNumber, int toLineNumber) =>
      _linesLayout.onLinesInserted(fromLineNumber, toLineNumber);

  // ---- end view event handlers

  /// 1:1: `private _getHorizontalScrollbarHeight()`.
  num _getHorizontalScrollbarHeight(num width, num scrollWidth) {
    final dynamic options = _configuration.options;
    final dynamic scrollbar = options.get(EditorOption.scrollbar);
    if (scrollbar.horizontal == ScrollbarVisibility.Hidden) {
      return 0;
    }
    if (width >= scrollWidth) {
      return 0;
    }
    return scrollbar.horizontalScrollbarSize as num;
  }

  /// 1:1: `private _getContentHeight()`.
  num _getContentHeight(num width, num height, num contentWidth) {
    final dynamic options = _configuration.options;
    num result = _linesLayout.getLinesTotalHeight();
    if (options.get(EditorOption.scrollBeyondLastLine) == true) {
      result += max(
          0,
          height -
              (options.get(EditorOption.lineHeight) as num) -
              (options.get(EditorOption.padding).bottom as num));
    } else if (options
            .get(EditorOption.scrollbar)
            .ignoreHorizontalScrollbarInContentHeight !=
        true) {
      result += _getHorizontalScrollbarHeight(width, contentWidth);
    }
    return result;
  }

  /// 1:1: `private _updateHeight()`.
  void _updateHeight() {
    final EditorScrollDimensions scrollDimensions =
        _scrollable.getScrollDimensions();
    final num width = scrollDimensions.width;
    final num height = scrollDimensions.height;
    final num contentWidth = scrollDimensions.contentWidth;
    _scrollable.setScrollDimensions(EditorScrollDimensions(
      width,
      scrollDimensions.contentWidth,
      height,
      _getContentHeight(width, height, contentWidth),
    ));
  }

  // ---- Layouting logic

  /// 1:1: `public getCurrentViewport()`.
  Viewport getCurrentViewport() {
    final EditorScrollDimensions scrollDimensions =
        _scrollable.getScrollDimensions();
    final IScrollPosition currentScrollPosition =
        _scrollable.getCurrentScrollPosition();
    return Viewport(
      currentScrollPosition.scrollTop,
      currentScrollPosition.scrollLeft,
      scrollDimensions.width,
      scrollDimensions.height,
    );
  }

  /// 1:1: `public getFutureViewport()`.
  Viewport getFutureViewport() {
    final EditorScrollDimensions scrollDimensions =
        _scrollable.getScrollDimensions();
    final IScrollPosition currentScrollPosition =
        _scrollable.getFutureScrollPosition();
    return Viewport(
      currentScrollPosition.scrollTop,
      currentScrollPosition.scrollLeft,
      scrollDimensions.width,
      scrollDimensions.height,
    );
  }

  /// 1:1: `private _computeContentWidth()`.
  num _computeContentWidth() {
    final dynamic options = _configuration.options;
    final num maxLineWidth = _maxLineWidth;
    final dynamic wrappingInfo = options.get(EditorOption.wrappingInfo);
    final dynamic fontInfo = options.get(EditorOption.fontInfo);
    final dynamic layoutInfo = options.get(EditorOption.layoutInfo);
    if (wrappingInfo.isViewportWrapping == true) {
      final dynamic minimap = options.get(EditorOption.minimap);
      if (maxLineWidth >
          layoutInfo.contentWidth +
              fontInfo.typicalHalfwidthCharacterWidth) {
        if (minimap.enabled == true && minimap.side == 'right') {
          return maxLineWidth + layoutInfo.verticalScrollbarWidth;
        }
      }
      return maxLineWidth;
    }
    final num extraHorizontalSpace = (options
                .get(EditorOption.scrollBeyondLastColumn) as num) *
            fontInfo.typicalHalfwidthCharacterWidth;
    final num whitespaceMinWidth = _linesLayout.getWhitespaceMinWidth();
    return max(
      maxLineWidth + extraHorizontalSpace + layoutInfo.verticalScrollbarWidth,
      max(whitespaceMinWidth, _overlayWidgetsMinWidth),
    );
  }

  /// 1:1: `public setMaxLineWidth()`.
  void setMaxLineWidth(num maxLineWidth) {
    _maxLineWidth = maxLineWidth;
    _updateContentWidth();
  }

  /// 1:1: `public setOverlayWidgetsMinWidth()`.
  void setOverlayWidgetsMinWidth(num maxMinWidth) {
    _overlayWidgetsMinWidth = maxMinWidth;
    _updateContentWidth();
  }

  /// 1:1: `private _updateContentWidth()`.
  void _updateContentWidth() {
    final EditorScrollDimensions scrollDimensions =
        _scrollable.getScrollDimensions();
    _scrollable.setScrollDimensions(EditorScrollDimensions(
      scrollDimensions.width,
      _computeContentWidth(),
      scrollDimensions.height,
      scrollDimensions.contentHeight,
    ));
    _updateHeight();
  }

  // ---- view state

  /// 1:1: `public saveState()` (object literal -> map).
  Map<String, num> saveState() {
    final IScrollPosition currentScrollPosition =
        _scrollable.getFutureScrollPosition();
    final num scrollTop = currentScrollPosition.scrollTop;
    final int firstLineNumberInViewport =
        _linesLayout.getLineNumberAtOrAfterVerticalOffset(scrollTop);
    final num whitespaceAboveFirstLine = _linesLayout
        .getWhitespaceAccumulatedHeightBeforeLineNumber(
            firstLineNumberInViewport);
    return <String, num>{
      'scrollTop': scrollTop,
      'scrollTopWithoutViewZones': scrollTop - whitespaceAboveFirstLine,
      'scrollLeft': currentScrollPosition.scrollLeft,
    };
  }

  // ----

  /// 1:1: `public changeWhitespace()`.
  bool changeWhitespace(void Function(IWhitespaceChangeAccessor) callback) {
    final bool hadAChange = _linesLayout.changeWhitespace(callback);
    if (hadAChange) {
      onHeightMaybeChanged();
    }
    return hadAChange;
  }

  /// 1:1: `public changeSpecialLineHeights()`.
  bool changeSpecialLineHeights(
      void Function(ILineHeightChangeAccessor) callback) {
    final bool hadAChange = _linesLayout.changeLineHeights(callback);
    if (hadAChange) {
      onHeightMaybeChanged();
    }
    return hadAChange;
  }

  /// 1:1: `public getVerticalOffsetForLineNumber()`.
  num getVerticalOffsetForLineNumber(int lineNumber,
          [bool includeViewZones = false]) =>
      _linesLayout.getVerticalOffsetForLineNumber(lineNumber, includeViewZones);

  /// 1:1: `public getVerticalOffsetAfterLineNumber()`.
  num getVerticalOffsetAfterLineNumber(int lineNumber,
          [bool includeViewZones = false]) =>
      _linesLayout.getVerticalOffsetAfterLineNumber(lineNumber, includeViewZones);

  /// 1:1: `public getLineHeightForLineNumber()`.
  num getLineHeightForLineNumber(int lineNumber) =>
      _linesLayout.getLineHeightForLineNumber(lineNumber);

  /// 1:1: `public isAfterLines()`.
  bool isAfterLines(num verticalOffset) =>
      _linesLayout.isAfterLines(verticalOffset);

  /// 1:1: `public isInTopPadding()`.
  bool isInTopPadding(num verticalOffset) =>
      _linesLayout.isInTopPadding(verticalOffset);

  /// 1:1: `public isInBottomPadding()`.
  bool isInBottomPadding(num verticalOffset) =>
      _linesLayout.isInBottomPadding(verticalOffset);

  /// 1:1: `public getLineNumberAtVerticalOffset()`.
  int getLineNumberAtVerticalOffset(num verticalOffset) =>
      _linesLayout.getLineNumberAtOrAfterVerticalOffset(verticalOffset);

  /// 1:1: `public getWhitespaceAtVerticalOffset()`.
  ViewWhitespaceViewportData? getWhitespaceAtVerticalOffset(
          num verticalOffset) =>
      _linesLayout.getWhitespaceAtVerticalOffset(verticalOffset);

  /// 1:1: `public getLinesViewportData()`.
  PartialViewLinesViewportData getLinesViewportData() {
    final Viewport visibleBox = getCurrentViewport();
    return _linesLayout.getLinesViewportData(
        visibleBox.top, visibleBox.top + visibleBox.height);
  }

  /// 1:1: `public getLinesViewportDataAtScrollTop()`.
  PartialViewLinesViewportData getLinesViewportDataAtScrollTop(num scrollTop) {
    final EditorScrollDimensions scrollDimensions =
        _scrollable.getScrollDimensions();
    if (scrollTop + scrollDimensions.height > scrollDimensions.scrollHeight) {
      scrollTop = scrollDimensions.scrollHeight - scrollDimensions.height;
    }
    if (scrollTop < 0) {
      scrollTop = 0;
    }
    return _linesLayout.getLinesViewportData(
        scrollTop, scrollTop + scrollDimensions.height);
  }

  /// 1:1: `public getWhitespaceViewportData()`.
  List<ViewWhitespaceViewportData> getWhitespaceViewportData() {
    final Viewport visibleBox = getCurrentViewport();
    return _linesLayout.getWhitespaceViewportData(
        visibleBox.top, visibleBox.top + visibleBox.height);
  }

  /// 1:1: `public getWhitespaces()`.
  List<EditorWhitespace> getWhitespaces() => _linesLayout.getWhitespaces();

  // ----

  /// 1:1: `public getContentWidth()`.
  num getContentWidth() => _scrollable.getScrollDimensions().contentWidth;

  /// 1:1: `public getScrollWidth()`.
  num getScrollWidth() => _scrollable.getScrollDimensions().scrollWidth;

  /// 1:1: `public getContentHeight()`.
  num getContentHeight() => _scrollable.getScrollDimensions().contentHeight;

  /// 1:1: `public getScrollHeight()`.
  num getScrollHeight() => _scrollable.getScrollDimensions().scrollHeight;

  /// 1:1: `public getCurrentScrollLeft()`.
  num getCurrentScrollLeft() =>
      _scrollable.getCurrentScrollPosition().scrollLeft;

  /// 1:1: `public getCurrentScrollTop()`.
  num getCurrentScrollTop() =>
      _scrollable.getCurrentScrollPosition().scrollTop;

  /// 1:1: `public validateScrollPosition()`.
  IScrollPosition validateScrollPosition(NewScrollPosition scrollPosition) =>
      _scrollable.validateScrollPosition(scrollPosition);

  /// 1:1: `public setScrollPosition()`.
  void setScrollPosition(NewScrollPosition position, int type) {
    if (type == ScrollType.Immediate) {
      _scrollable.setScrollPositionNow(position);
    } else {
      _scrollable.setScrollPositionSmooth(position);
    }
  }

  /// 1:1: `public hasPendingScrollAnimation()`.
  bool hasPendingScrollAnimation() => _scrollable.hasPendingScrollAnimation();

  /// 1:1: `public deltaScrollNow()`.
  void deltaScrollNow(num deltaScrollLeft, num deltaScrollTop) {
    final IScrollPosition currentScrollPosition =
        _scrollable.getCurrentScrollPosition();
    _scrollable.setScrollPositionNow(NewScrollPosition(
      scrollLeft: currentScrollPosition.scrollLeft + deltaScrollLeft,
      scrollTop: currentScrollPosition.scrollTop + deltaScrollTop,
    ));
  }
}
