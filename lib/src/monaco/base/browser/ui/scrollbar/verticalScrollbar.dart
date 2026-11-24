// 1:1 port of vscode/src/vs/base/browser/ui/scrollbar/verticalScrollbar.ts
import '../../mouseEvent.dart' as mouse;
import '../../../common/codicons.dart' as codicons;
import '../../../common/scrollable.dart' as scr;
import 'abstractScrollbar.dart'
    show AbstractScrollbar, AbstractScrollbarOptions, ScrollbarHost, pointerPageX, pointerPageY;
import 'scrollableElementOptions.dart' show ScrollableElementResolvedOptions;
import 'scrollbarArrow.dart' show ARROW_IMG_SIZE, ScrollbarArrowOptions;
import 'scrollbarState.dart' show ScrollbarState;

/// 1:1: `export class VerticalScrollbar extends AbstractScrollbar`
class VerticalScrollbar extends AbstractScrollbar {
  VerticalScrollbar(scr.Scrollable scrollable,
      ScrollableElementResolvedOptions options, ScrollbarHost host)
      : super(buildOpts(scrollable, options, host)) {
    if (options.verticalHasArrows) {
      final num arrowDelta = (options.arrowSize - ARROW_IMG_SIZE) / 2;
      final num scrollbarDelta =
          (options.verticalScrollbarSize - ARROW_IMG_SIZE) / 2;

      createArrow(ScrollbarArrowOptions(
        className: 'scra',
        icon: codicons.Codicon['scrollbarButtonUp']!,
        top: arrowDelta,
        left: scrollbarDelta,
        bgWidth: options.verticalScrollbarSize,
        bgHeight: options.arrowSize,
        onActivate: () => host.onMouseWheel(mouse.StandardWheelEvent(null, 0, 1)),
      ));

      createArrow(ScrollbarArrowOptions(
        className: 'scra',
        icon: codicons.Codicon['scrollbarButtonDown']!,
        left: scrollbarDelta,
        bottom: arrowDelta,
        bgWidth: options.verticalScrollbarSize,
        bgHeight: options.arrowSize,
        onActivate: () => host.onMouseWheel(mouse.StandardWheelEvent(null, 0, -1)),
      ));
    }

    createSlider(
        0,
        ((options.verticalScrollbarSize - options.verticalSliderSize) / 2).floor(),
        options.verticalSliderSize,
        null);
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
        options.verticalHasArrows ? options.arrowSize : 0,
        options.vertical == scr.ScrollbarVisibility.Hidden
            ? 0
            : options.verticalScrollbarSize,
        // 1:1: give priority to vertical scrollbar over horizontal.
        0,
        scrollDimensions.height,
        scrollDimensions.scrollHeight,
        scrollPosition.scrollTop,
      ),
      visibility: options.vertical,
      extraScrollbarClassName: 'vertical',
      scrollable: scrollable,
      scrollByPage: options.scrollByPage,
    );
  }

  @override
  void updateSlider(num sliderSize, num sliderPosition) {
    slider.setHeight(sliderSize);
    slider.setTop(sliderPosition);
  }

  @override
  void renderDomNode(num largeSize, num smallSize) {
    domNode.setWidth(smallSize);
    domNode.setHeight(largeSize);
    domNode.setRight(0);
    domNode.setTop(0);
  }

  /// 1:1: `public onDidScroll(e)`
  bool onDidScroll(scr.ScrollEvent e) {
    shouldRender = onElementScrollSize(e.scrollHeight) || shouldRender;
    shouldRender = onElementScrollPosition(e.scrollTop) || shouldRender;
    shouldRender = onElementSize(e.height) || shouldRender;
    return shouldRender;
  }

  @override
  num pointerDownRelativePosition(num offsetX, num offsetY) => offsetY;

  @override
  num sliderPointerPosition(Object e) => pointerPageY(e);

  @override
  num sliderOrthogonalPointerPosition(Object e) => pointerPageX(e);

  @override
  void updateScrollbarSizeImpl(num size) => slider.setWidth(size);

  @override
  void writeScrollPosition(scr.NewScrollPosition target, num scrollPosition) {
    target.scrollTop = scrollPosition;
  }

  /// 1:1: `public updateOptions(options)`
  void updateOptions(ScrollableElementResolvedOptions options) {
    updateScrollbarSize(options.vertical == scr.ScrollbarVisibility.Hidden
        ? 0
        : options.verticalScrollbarSize);
    // 1:1: give priority to vertical scrollbar over horizontal.
    scrollbarState.setOppositeScrollbarSize(0);
    visibilityController.setVisibility(options.vertical);
    setScrollByPage(options.scrollByPage);
  }
}
