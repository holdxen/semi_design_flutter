// 1:1 port of vscode/src/vs/base/browser/ui/scrollbar/abstractScrollbar.ts
//
// Base class for a horizontal/vertical scrollbar. Owns the DOM node + slider,
// the visibility controller, and all pointer interaction (page jumps, slider
// dragging with cross-axis drag reset). Subclasses supply the axis-specific
// geometry hooks (render, position mapping, writeScrollPosition).
//
// Pointer events are received as raw `Object` values and read structurally so
// both the port's DomEvent and truth synthetic events can be used.

import '../../../common/platform.dart' as platform;
import '../../../common/scrollable.dart' as scr;
import '../../dom.dart' as dom;
import '../../fastDomNode.dart' as fdn;
import '../../globalPointerMoveMonitor.dart' show GlobalPointerMoveMonitor;
import '../../mouseEvent.dart' as mouse;
import '../widget.dart' show Widget;
import 'scrollbarArrow.dart' show ScrollbarArrow, ScrollbarArrowOptions;
import 'scrollbarState.dart' show ScrollbarState;
import 'scrollbarVisibilityController.dart' show ScrollbarVisibilityController;

/// 1:1: `const POINTER_DRAG_RESET_DISTANCE = 140`
const int POINTER_DRAG_RESET_DISTANCE = 140;

/// 1:1: `export interface ISimplifiedPointerEvent`
abstract class ISimplifiedPointerEvent {
  num get pageX;
  num get pageY;
}

/// 1:1: `export interface ScrollbarHost`
abstract class ScrollbarHost {
  void onMouseWheel(mouse.StandardWheelEvent mouseWheelEvent);
  void onDragStart();
  void onDragEnd();
}

/// 1:1: `export interface AbstractScrollbarOptions`
class AbstractScrollbarOptions {
  AbstractScrollbarOptions({
    required this.lazyRender,
    required this.host,
    required this.scrollbarState,
    required this.visibility,
    required this.extraScrollbarClassName,
    required this.scrollable,
    required this.scrollByPage,
  });

  final bool lazyRender;
  final ScrollbarHost host;
  final ScrollbarState scrollbarState;
  final int visibility;
  final String extraScrollbarClassName;
  final scr.Scrollable scrollable;
  final bool scrollByPage;
}

/// Injectable factories (defaults = real implementations). Used by the
/// truth-driven tests to observe visibility calls and drive pointer-move /
/// stop callbacks deterministically.
GlobalPointerMoveMonitor Function() pointerMoveMonitorFactory =
    () => GlobalPointerMoveMonitor();
ScrollbarVisibilityController Function(int, String, String)
    visibilityControllerFactory = (int visibility, String visible, String invisible) =>
        ScrollbarVisibilityController(visibility, visible, invisible);

/// Bridges a [dom.DomElement] to the narrower [fdn.DomElement] carrier used by
/// FastDomNode. Structural DOM operations keep the real element via [real].
class _ElAdapter implements fdn.DomElement {
  _ElAdapter(this.real);
  final dom.DomElement real;
  @override
  Map<String, String> get style => real.style;
  @override
  String get className => real.className;
  @override
  set className(String value) => real.className = value;
  @override
  fdn.DomTokenList get classList => real.classList;
  @override
  void focus() => real.focus();
  @override
  void setAttribute(String name, String value) => real.setAttribute(name, value);
  @override
  void removeAttribute(String name) => real.removeAttribute(name);
  @override
  void appendChild(fdn.DomElement child) =>
      real.appendChild((child as _ElAdapter).real);
  @override
  void removeChild(fdn.DomElement child) =>
      real.removeChild((child as _ElAdapter).real);
}

/// Create a FastDomNode backed by a fresh div, exposing the real element.
fdn.FastDomNode<_ElAdapter> _createDivNode() =>
    fdn.createFastDomNode<_ElAdapter>(_ElAdapter(dom.document.createElement('div')));

dom.DomElement _real(fdn.FastDomNode<_ElAdapter> node) => node.domNode.real;

// --- structural pointer-event readers --------------------------------------

num _numField(Object e, String name, [num fallback = 0]) {
  final Object? v = _rawField(e, name);
  if (v is num) return v;
  return fallback;
}

/// 1:1 structural readers for `ISimplifiedPointerEvent.pageX/pageY`, exported
/// for the horizontal/vertical subclasses' position hooks.
num pointerPageX(Object e) => _numField(e, 'pageX');
num pointerPageY(Object e) => _numField(e, 'pageY');

/// Read a field from a raw pointer event. Handles the port's DomEvent, Maps
/// (truth synthetic events), and arbitrary structural carriers.
Object? _rawField(Object e, String name) {
  if (e is Map) return e[name];
  if (e is dom.DomEvent) {
    switch (name) {
      case 'target':
        return e.target;
      case 'buttons':
        return e.buttons;
      case 'button':
        return e.button;
      case 'pointerId':
        return e.pointerId;
      case 'pointerType':
        return e.pointerType;
      case 'offsetX':
        return e.offsetX;
      case 'offsetY':
        return e.offsetY;
      case 'pageX':
        return e.pageX;
      case 'pageY':
        return e.pageY;
    }
  }
  // ignore: avoid_dynamic_calls
  final dynamic d = e;
  try {
    switch (name) {
      case 'target':
        return d.target;
      case 'buttons':
        return d.buttons;
      case 'button':
        return d.button;
      case 'pointerId':
        return d.pointerId;
      case 'pointerType':
        return d.pointerType;
      case 'offsetX':
        return d.offsetX;
      case 'offsetY':
        return d.offsetY;
      case 'pageX':
        return d.pageX;
      case 'pageY':
        return d.pageY;
    }
  } catch (_) {
    return null;
  }
  return null;
}

void _preventDefault(Object e) {
  if (e is dom.DomEvent) {
    e.preventDefault();
  } else {
    // ignore: avoid_dynamic_calls
    (e as dynamic).preventDefault();
  }
}

/// 1:1: `export abstract class AbstractScrollbar extends Widget`
abstract class AbstractScrollbar extends Widget {
  AbstractScrollbar(AbstractScrollbarOptions opts) : super() {
    _lazyRender = opts.lazyRender;
    host = opts.host;
    _scrollable = opts.scrollable;
    _scrollByPage = opts.scrollByPage;
    scrollbarState = opts.scrollbarState;
    visibilityController = register(visibilityControllerFactory(
        opts.visibility,
        'visible scrollbar ${opts.extraScrollbarClassName}',
        'invisible scrollbar ${opts.extraScrollbarClassName}'));
    visibilityController.setIsNeeded(scrollbarState.isNeeded());
    pointerMoveMonitor = register(pointerMoveMonitorFactory());
    shouldRender = true;
    domNode = _createDivNode();
    domNode.setAttribute('role', 'presentation');
    domNode.setAttribute('aria-hidden', 'true');

    visibilityController.setDomNode(domNode);
    domNode.setPosition('absolute');

    register(dom.addDisposableListener(
        _real(domNode),
        dom.EventType.POINTER_DOWN,
        (dom.DomEvent e) => domNodePointerDown(e)));
  }

  // 1:1: protected/public fields (Dart exposes them for the concrete subclasses)
  late final ScrollbarHost host;
  late final scr.Scrollable _scrollable;
  late bool _scrollByPage;
  late final bool _lazyRender;
  late final ScrollbarState scrollbarState;
  late final ScrollbarVisibilityController visibilityController;
  late final GlobalPointerMoveMonitor pointerMoveMonitor;

  late final fdn.FastDomNode<_ElAdapter> domNode;
  late final fdn.FastDomNode<_ElAdapter> slider;

  bool shouldRender = false;

  /// Real DOM element behind [domNode] (exposed for structural DOM ops/tests).
  dom.DomElement get realDomNode => _real(domNode);
  dom.DomElement get realSlider => _real(slider);

  /// Arrows created via [createArrow] (test seam, mirrors `_register` order).
  final List<ScrollbarArrow> arrows = <ScrollbarArrow>[];

  /// 1:1: `protected _createArrow(opts)`
  void createArrow(ScrollbarArrowOptions opts) {
    final ScrollbarArrow arrow = register(ScrollbarArrow(opts));
    arrows.add(arrow);
    _real(domNode).appendChild(arrow.bgDomNode);
    _real(domNode).appendChild(arrow.domNode);
  }

  /// 1:1: `protected _createSlider(top, left, width, height)`
  void createSlider(num top, num left, num? width, num? height) {
    slider = _createDivNode();
    slider.setClassName('slider');
    slider.setPosition('absolute');
    slider.setTop(top);
    slider.setLeft(left);
    if (width != null) slider.setWidth(width);
    if (height != null) slider.setHeight(height);
    slider.setLayerHinting(true);
    slider.setContain('strict');

    _real(domNode).appendChild(_real(slider));

    register(dom.addDisposableListener(
        _real(slider),
        dom.EventType.POINTER_DOWN,
        (dom.DomEvent e) {
      if (_buttonOf(e) == 0) {
        e.preventDefault();
        sliderPointerDown(e);
      }
    }));

    onclick(_real(slider), (mouse.IMouseEvent e) {
      if (e.leftButton) {
        e.stopPropagation();
      }
    });
  }

  int _buttonOf(Object e) => _numField(e, 'button').toInt();

  bool onElementSize(num visibleSize) {
    if (scrollbarState.setVisibleSize(visibleSize)) {
      visibilityController.setIsNeeded(scrollbarState.isNeeded());
      shouldRender = true;
      if (!_lazyRender) render();
    }
    return shouldRender;
  }

  bool onElementScrollSize(num elementScrollSize) {
    if (scrollbarState.setScrollSize(elementScrollSize)) {
      visibilityController.setIsNeeded(scrollbarState.isNeeded());
      shouldRender = true;
      if (!_lazyRender) render();
    }
    return shouldRender;
  }

  bool onElementScrollPosition(num elementScrollPosition) {
    if (scrollbarState.setScrollPosition(elementScrollPosition)) {
      visibilityController.setIsNeeded(scrollbarState.isNeeded());
      shouldRender = true;
      if (!_lazyRender) render();
    }
    return shouldRender;
  }

  /// 1:1: `public beginReveal()`
  void beginReveal() => visibilityController.setShouldBeVisible(true);

  /// 1:1: `public beginHide()`
  void beginHide() => visibilityController.setShouldBeVisible(false);

  /// 1:1: `public render()`
  void render() {
    if (!shouldRender) return;
    shouldRender = false;
    renderDomNode(
        scrollbarState.getRectangleLargeSize(),
        scrollbarState.getRectangleSmallSize());
    updateSlider(scrollbarState.getSliderSize(),
        scrollbarState.getArrowSize() + scrollbarState.getSliderPosition());
  }

  void domNodePointerDown(Object e) {
    if (!identical(_rawField(e, 'target'), _real(domNode))) return;
    onPointerDown(e);
  }

  /// 1:1: `public delegatePointerDown(e)`
  void delegatePointerDown(Object e) {
    final num domTop = _real(domNode).getClientRects()[0].top;
    final num sliderStart = domTop + scrollbarState.getSliderPosition();
    final num sliderStop =
        domTop + scrollbarState.getSliderPosition() + scrollbarState.getSliderSize();
    final num pointerPos = sliderPointerPosition(e);
    if (sliderStart <= pointerPos && pointerPos <= sliderStop) {
      if (_buttonOf(e) == 0) {
        _preventDefault(e);
        sliderPointerDown(e);
      }
    } else {
      onPointerDown(e);
    }
  }

  void onPointerDown(Object e) {
    num offsetX;
    num offsetY;
    final Object? target = _rawField(e, 'target');
    final Object? ox = _rawField(e, 'offsetX');
    final Object? oy = _rawField(e, 'offsetY');
    if (identical(target, _real(domNode)) &&
        ox is num &&
        oy is num) {
      offsetX = ox;
      offsetY = oy;
    } else {
      final dom.IDomNodePagePosition domNodePosition =
          dom.getDomNodePagePosition(_real(domNode));
      offsetX = _numField(e, 'pageX') - domNodePosition.left;
      offsetY = _numField(e, 'pageY') - domNodePosition.top;
    }

    final bool isMouse = _rawField(e, 'pointerType') == 'mouse';
    final bool isLeftClick = _buttonOf(e) == 0;

    if (isLeftClick || !isMouse) {
      final num offset = pointerDownRelativePosition(offsetX, offsetY);
      setDesiredScrollPositionNow(_scrollByPage
          ? scrollbarState.getDesiredScrollPositionFromOffsetPaged(offset)
          : scrollbarState.getDesiredScrollPositionFromOffset(offset));
    }

    if (isLeftClick) {
      _preventDefault(e);
      sliderPointerDown(e);
    }
  }

  void sliderPointerDown(Object e) {
    final Object? target = _rawField(e, 'target');
    if (target == null || target is! dom.DomElement) return;

    final num initialPointerPosition = sliderPointerPosition(e);
    final num initialPointerOrthogonalPosition =
        sliderOrthogonalPointerPosition(e);
    final ScrollbarState initialScrollbarState = scrollbarState.clone();
    slider.toggleClassName('active', true);

    pointerMoveMonitor.startMonitoring(
      target,
      _numField(e, 'pointerId').toInt(),
      _numField(e, 'buttons').toInt(),
      (dom.DomEvent pointerMoveData) {
        final num pointerOrthogonalPosition =
            sliderOrthogonalPointerPosition(pointerMoveData);
        final num pointerOrthogonalDelta =
            (pointerOrthogonalPosition - initialPointerOrthogonalPosition).abs();

        if (platform.isWindows &&
            pointerOrthogonalDelta > POINTER_DRAG_RESET_DISTANCE) {
          setDesiredScrollPositionNow(
              initialScrollbarState.getScrollPosition());
          return;
        }

        final num pointerPosition = sliderPointerPosition(pointerMoveData);
        final num pointerDelta = pointerPosition - initialPointerPosition;
        setDesiredScrollPositionNow(
            initialScrollbarState.getDesiredScrollPositionFromDelta(pointerDelta));
      },
      ([Object? browserEvent]) {
        slider.toggleClassName('active', false);
        host.onDragEnd();
      },
    );

    host.onDragStart();
  }

  void setDesiredScrollPositionNow(num desiredScrollPosition) {
    final scr.NewScrollPosition desiredScrollPositionObj =
        scr.NewScrollPosition();
    writeScrollPosition(desiredScrollPositionObj, desiredScrollPosition);
    _scrollable.setScrollPositionNow(desiredScrollPositionObj);
  }

  /// 1:1: `public updateScrollbarSize(scrollbarSize)`
  void updateScrollbarSize(num scrollbarSize) {
    updateScrollbarSizeImpl(scrollbarSize);
    scrollbarState.setScrollbarSize(scrollbarSize);
    shouldRender = true;
    if (!_lazyRender) render();
  }

  /// 1:1: `public isNeeded()`
  bool isNeeded() => scrollbarState.isNeeded();

  /// 1:1 protected field write: `this._scrollByPage = ...` (used by
  /// HorizontalScrollbar/VerticalScrollbar.updateOptions).
  void setScrollByPage(bool value) => _scrollByPage = value;

  // --- abstract hooks (1:1: overwrite these) -------------------------------
  void renderDomNode(num largeSize, num smallSize);
  void updateSlider(num sliderSize, num sliderPosition);
  num pointerDownRelativePosition(num offsetX, num offsetY);
  num sliderPointerPosition(Object e);
  num sliderOrthogonalPointerPosition(Object e);
  void updateScrollbarSizeImpl(num size);
  void writeScrollPosition(scr.NewScrollPosition target, num scrollPosition);
}
