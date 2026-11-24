// 1:1 port of vscode/src/vs/base/browser/ui/scrollbar/horizontalScrollbar.ts
import '../../mouseEvent.dart' as mouse;
import '../../../common/codicons.dart' as codicons;
import '../../../common/scrollable.dart' as scr;
import 'abstractScrollbar.dart'
    show AbstractScrollbar, AbstractScrollbarOptions, ScrollbarHost, pointerPageX, pointerPageY;
import 'scrollableElementOptions.dart' show ScrollableElementResolvedOptions;
import 'scrollbarArrow.dart' show ARROW_IMG_SIZE, ScrollbarArrowOptions;
import 'scrollbarState.dart' show ScrollbarState;

/// 1:1: `export class HorizontalScrollbar extends AbstractScrollbar`
class HorizontalScrollbar extends AbstractScrollbar {
  HorizontalScrollbar(scr.Scrollable scrollable,
      ScrollableElementResolvedOptions options, ScrollbarHost host)
      : super(buildOpts(scrollable, options, host)) {
    if (options.horizontalHasArrows) {
      final num arrowDelta = (options.arrowSize - ARROW_IMG_SIZE) / 2;
      final num scrollbarDelta =
          (options.horizontalScrollbarSize - ARROW_IMG_SIZE) / 2;

      createArrow(ScrollbarArrowOptions(
        className: 'scra',
        icon: codicons.Codicon['scrollbarButtonLeft']!,
        top: scrollbarDelta,
        left: arrowDelta,
        bgWidth: options.arrowSize,
        bgHeight: options.horizontalScrollbarSize,
        onActivate: () => host.onMouseWheel(mouse.StandardWheelEvent(null, 1, 0)),
      ));

      createArrow(ScrollbarArrowOptions(
        className: 'scra',
        icon: codicons.Codicon['scrollbarButtonRight']!,
        top: scrollbarDelta,
        right: arrowDelta,
        bgWidth: options.arrowSize,
        bgHeight: options.horizontalScrollbarSize,
        onActivate: () => host.onMouseWheel(mouse.StandardWheelEvent(null, -1, 0)),
      ));
    }

    createSlider(
        ((options.horizontalScrollbarSize - options.horizontalSliderSize) / 2).floor(),
        0,
        null,
        options.horizontalSliderSize);
  }

  static AbstractScrollbarOptions buildOpts(scr.Scrollable scrollable,
      ScrollableElementResolvedOptions options, ScrollbarHost host) {
    final scr.IScrollDimensions scrollDimensions =
        scrollable.getScrollDimensions();
    final scr.IScrollPosition scrollPosition =
        scrollable.getCurrentScrollPosition();
    return AbstractScrollbarOptions(
      lazyRender: options.lazyRender,
      host: host,
      scrollbarState: ScrollbarState(
        options.horizontalHasArrows ? options.arrowSize : 0,
        options.horizontal == scr.ScrollbarVisibility.Hidden
            ? 0
            : options.horizontalScrollbarSize,
        options.vertical == scr.ScrollbarVisibility.Hidden
            ? 0
            : options.verticalScrollbarSize,
        scrollDimensions.width,
        scrollDimensions.scrollWidth,
        scrollPosition.scrollLeft,
      ),
      visibility: options.horizontal,
      extraScrollbarClassName: 'horizontal',
      scrollable: scrollable,
      scrollByPage: options.scrollByPage,
    );
  }

  @override
  void updateSlider(num sliderSize, num sliderPosition) {
    slider.setWidth(sliderSize);
    slider.setLeft(sliderPosition);
  }

  @override
  void renderDomNode(num largeSize, num smallSize) {
    domNode.setWidth(largeSize);
    domNode.setHeight(smallSize);
    domNode.setLeft(0);
    domNode.setBottom(0);
  }

  /// 1:1: `public onDidScroll(e)`
  bool onDidScroll(scr.ScrollEvent e) {
    shouldRender = onElementScrollSize(e.scrollWidth) || shouldRender;
    shouldRender = onElementScrollPosition(e.scrollLeft) || shouldRender;
    shouldRender = onElementSize(e.width) || shouldRender;
    return shouldRender;
  }

  @override
  num pointerDownRelativePosition(num offsetX, num offsetY) => offsetX;

  @override
  num sliderPointerPosition(Object e) => pointerPageX(e);

  @override
  num sliderOrthogonalPointerPosition(Object e) => pointerPageY(e);

  @override
  void updateScrollbarSizeImpl(num size) => slider.setHeight(size);

  @override
  void writeScrollPosition(scr.NewScrollPosition target, num scrollPosition) {
    target.scrollLeft = scrollPosition;
  }

  /// 1:1: `public updateOptions(options)`
  void updateOptions(ScrollableElementResolvedOptions options) {
    updateScrollbarSize(options.horizontal == scr.ScrollbarVisibility.Hidden
        ? 0
        : options.horizontalScrollbarSize);
    scrollbarState.setOppositeScrollbarSize(
        options.vertical == scr.ScrollbarVisibility.Hidden
            ? 0
            : options.verticalScrollbarSize);
    visibilityController.setVisibility(options.horizontal);
    setScrollByPage(options.scrollByPage);
  }
}
