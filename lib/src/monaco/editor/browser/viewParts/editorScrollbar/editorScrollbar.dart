// 1:1 port of vscode/src/vs/editor/browser/viewParts/editorScrollbar/editorScrollbar.ts
// Adaptations (documented inline):
//   - `ViewPart._context` is library-private in the Dart port, so the subclass
//     keeps its own reference to the same ViewContext.
//   - `ViewContext` carriers are read via `dynamic` (configuration.options,
//     viewLayout.getScrollable/getCurrentScrollTop, viewModel.viewLayout).
//   - base handler overrides take `Object` (Dart cannot narrow override
//     parameters) and cast to the concrete view event.
//   - `ThemeTypeSelector` is a Dart enum; `.value` matches the TS string.
//   - `FastDomNode<HTMLElement>` is a narrow carrier (IFastDomNode) with a
//     dom.dart DomElement underneath, following margin.dart's pattern, so the
//     part can be replayed without a browser.
// Runtime truth: tool/ts2dart/_batch340_truth.cjs.

import '../../../../base/browser/dom.dart'
    show DomElement, DomEvent, addDisposableListener;
import '../../../../base/browser/fastDomNode.dart' show numberAsPixels;
import '../../../../base/browser/ui/scrollbar/scrollableElement.dart'
    show IOverviewRulerLayoutInfo, SmoothScrollableElement;
import '../../../../base/browser/ui/scrollbar/scrollableElementOptions.dart'
    show ScrollableElementChangeOptions, ScrollableElementCreationOptions;
import '../../../../base/common/scrollable.dart' show NewScrollPosition, Scrollable;
import '../../../../platform/theme/common/themeService.dart'
    show getThemeTypeSelector;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/editorCommon.dart' show ScrollType;
import '../../../common/viewEvents.dart'
    show ViewConfigurationChangedEvent;
import '../../../common/viewModel/viewContext.dart' show ViewContext;
import '../../view/renderingContext.dart'
    show RenderingContext, RestrictedRenderingContext;
import '../../view/viewPart.dart'
    show PartFingerprint, PartFingerprints, ViewPart;

/// 1:1: `FastDomNode<HTMLElement>` subset used here (opaque carrier).
abstract class IFastDomNode {
  DomElement get domNode;
  void setPosition(String position);
  void setLeft(Object left);
  void setWidth(Object width);
  void setHeight(Object height);
  void setAttribute(String name, String value);
}

/// 1:1: `createFastDomNode(this.scrollbar.getDomNode())`.
class _FastDomNodeCarrier implements IFastDomNode {
  _FastDomNodeCarrier(this.domNode);

  @override
  final DomElement domNode;

  @override
  void setPosition(String position) => domNode.style['position'] = position;

  @override
  void setLeft(Object left) => domNode.style['left'] = numberAsPixels(left);

  @override
  void setWidth(Object width) => domNode.style['width'] = numberAsPixels(width);

  @override
  void setHeight(Object height) =>
      domNode.style['height'] = numberAsPixels(height);

  @override
  void setAttribute(String name, String value) =>
      domNode.setAttribute(name, value);
}

/// 1:1: `export class EditorScrollbar extends ViewPart`.
class EditorScrollbar extends ViewPart {
  late final SmoothScrollableElement scrollbar;
  late final IFastDomNode scrollbarDomNode;
  late final ViewContext _ctx;

  EditorScrollbar(
    ViewContext context,
    IFastDomNode linesContent,
    IFastDomNode viewDomNode,
    IFastDomNode overflowGuardDomNode,
  ) : super(context) {
    _ctx = context;

    final dynamic options = (context.configuration as dynamic).options;
    final dynamic scrollbarOptionsRaw = options.get(EditorOption.scrollbar);
    final num mouseWheelScrollSensitivity =
        options.get(EditorOption.mouseWheelScrollSensitivity) as num;
    final num fastScrollSensitivity =
        options.get(EditorOption.fastScrollSensitivity) as num;
    final bool scrollPredominantAxis =
        options.get(EditorOption.scrollPredominantAxis) == true;
    final bool inertialScroll = options.get(EditorOption.inertialScroll) == true;

    final ScrollableElementCreationOptions scrollbarOptions =
        ScrollableElementCreationOptions()
      ..listenOnDomNode = viewDomNode.domNode
      ..className = 'editor-scrollable ${getThemeTypeSelector(context.theme.type).value}'
      ..useShadows = false
      ..lazyRender = true
      ..vertical = scrollbarOptionsRaw.vertical as int
      ..horizontal = scrollbarOptionsRaw.horizontal as int
      ..verticalHasArrows = scrollbarOptionsRaw.verticalHasArrows as bool
      ..horizontalHasArrows = scrollbarOptionsRaw.horizontalHasArrows as bool
      ..verticalScrollbarSize = scrollbarOptionsRaw.verticalScrollbarSize as num
      ..verticalSliderSize = scrollbarOptionsRaw.verticalSliderSize as num
      ..horizontalScrollbarSize =
          scrollbarOptionsRaw.horizontalScrollbarSize as num
      ..horizontalSliderSize = scrollbarOptionsRaw.horizontalSliderSize as num
      ..handleMouseWheel = scrollbarOptionsRaw.handleMouseWheel as bool
      ..alwaysConsumeMouseWheel =
          scrollbarOptionsRaw.alwaysConsumeMouseWheel as bool
      ..arrowSize = scrollbarOptionsRaw.arrowSize as num
      ..mouseWheelScrollSensitivity = mouseWheelScrollSensitivity
      ..fastScrollSensitivity = fastScrollSensitivity
      ..scrollPredominantAxis = scrollPredominantAxis
      ..scrollByPage = scrollbarOptionsRaw.scrollByPage as bool
      ..inertialScroll = inertialScroll;

    scrollbar = register(SmoothScrollableElement(
      linesContent.domNode,
      scrollbarOptions,
      (context.viewLayout as dynamic).getScrollable() as Scrollable,
    ));
    PartFingerprints.write(
        scrollbar.getDomNode(), PartFingerprint.ScrollableElement);

    scrollbarDomNode = _FastDomNodeCarrier(scrollbar.getDomNode());
    scrollbarDomNode.setPosition('absolute');
    _setLayout();

    void onBrowserDesperateReveal(DomElement domNode, bool lookAtScrollTop,
        bool lookAtScrollLeft) {
      final NewScrollPosition newScrollPosition = NewScrollPosition();

      if (lookAtScrollTop) {
        final int deltaTop = domNode.scrollTop;
        if (deltaTop != 0) {
          newScrollPosition.scrollTop =
              (context.viewLayout as dynamic).getCurrentScrollTop() + deltaTop;
          domNode.scrollTop = 0;
        }
      }

      if (lookAtScrollLeft) {
        final int deltaLeft = domNode.scrollLeft;
        if (deltaLeft != 0) {
          newScrollPosition.scrollLeft =
              (context.viewLayout as dynamic).getCurrentScrollLeft() + deltaLeft;
          domNode.scrollLeft = 0;
        }
      }

      (context.viewModel.viewLayout as dynamic)
          .setScrollPosition(newScrollPosition, ScrollType.Immediate);
    }

    register(addDisposableListener(viewDomNode.domNode, 'scroll',
        (DomEvent e) =>
            onBrowserDesperateReveal(viewDomNode.domNode, true, true)));
    register(addDisposableListener(linesContent.domNode, 'scroll',
        (DomEvent e) =>
            onBrowserDesperateReveal(linesContent.domNode, true, false)));
    register(addDisposableListener(overflowGuardDomNode.domNode, 'scroll',
        (DomEvent e) =>
            onBrowserDesperateReveal(overflowGuardDomNode.domNode, true, false)));
    register(addDisposableListener(scrollbarDomNode.domNode, 'scroll',
        (DomEvent e) =>
            onBrowserDesperateReveal(scrollbarDomNode.domNode, true, false)));
  }

  /// 1:1: `private _setLayout()`.
  void _setLayout() {
    final dynamic options = (_ctx.configuration as dynamic).options;
    final dynamic layoutInfo = options.get(EditorOption.layoutInfo);

    scrollbarDomNode.setLeft(layoutInfo.contentLeft);

    final dynamic minimap = options.get(EditorOption.minimap);
    if (minimap.side == 'right') {
      scrollbarDomNode
          .setWidth(layoutInfo.contentWidth + layoutInfo.minimap.minimapWidth);
    } else {
      scrollbarDomNode.setWidth(layoutInfo.contentWidth);
    }
    scrollbarDomNode.setHeight(layoutInfo.height);
  }

  /// 1:1: `public getOverviewRulerLayoutInfo()`.
  IOverviewRulerLayoutInfo getOverviewRulerLayoutInfo() =>
      scrollbar.getOverviewRulerLayoutInfo();

  /// 1:1: `public getDomNode()`.
  IFastDomNode getDomNode() => scrollbarDomNode;

  /// 1:1: `public delegateVerticalScrollbarPointerDown()`.
  void delegateVerticalScrollbarPointerDown(Object browserEvent) =>
      scrollbar.delegateVerticalScrollbarPointerDown(browserEvent);

  /// 1:1: `public delegateScrollFromMouseWheelEvent()`.
  void delegateScrollFromMouseWheelEvent(Object browserEvent) =>
      scrollbar.delegateScrollFromMouseWheelEvent(browserEvent);

  // --- begin event handlers

  @override
  bool onConfigurationChanged(Object e) {
    final ViewConfigurationChangedEvent event = e as ViewConfigurationChangedEvent;
    if (event.hasChanged(EditorOption.scrollbar) ||
        event.hasChanged(EditorOption.mouseWheelScrollSensitivity) ||
        event.hasChanged(EditorOption.fastScrollSensitivity)) {
      final dynamic options = (_ctx.configuration as dynamic).options;
      final dynamic scrollbarOptions = options.get(EditorOption.scrollbar);
      final ScrollableElementChangeOptions newOpts =
          ScrollableElementChangeOptions()
        ..vertical = scrollbarOptions.vertical as int
        ..horizontal = scrollbarOptions.horizontal as int
        ..verticalScrollbarSize = scrollbarOptions.verticalScrollbarSize as num
        ..horizontalScrollbarSize =
            scrollbarOptions.horizontalScrollbarSize as num
        ..scrollByPage = scrollbarOptions.scrollByPage as bool
        ..handleMouseWheel = scrollbarOptions.handleMouseWheel as bool
        ..mouseWheelScrollSensitivity =
            options.get(EditorOption.mouseWheelScrollSensitivity) as num
        ..fastScrollSensitivity =
            options.get(EditorOption.fastScrollSensitivity) as num
        ..scrollPredominantAxis =
            options.get(EditorOption.scrollPredominantAxis) == true;
      scrollbar.updateOptions(newOpts);
    }
    if (event.hasChanged(EditorOption.layoutInfo)) {
      _setLayout();
    }
    return true;
  }

  @override
  bool onScrollChanged(Object e) => true;

  @override
  bool onThemeChanged(Object e) {
    scrollbar.updateClassName(
        'editor-scrollable ${getThemeTypeSelector(_ctx.theme.type).value}');
    return true;
  }

  // --- end event handlers

  @override
  void prepareRender(RenderingContext ctx) {}

  @override
  void render(RestrictedRenderingContext ctx) => scrollbar.renderNow();
}
