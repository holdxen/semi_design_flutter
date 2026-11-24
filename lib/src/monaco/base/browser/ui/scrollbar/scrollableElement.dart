// 1:1 port of vscode/src/vs/base/browser/ui/scrollbar/scrollableElement.ts
//
// Owns a Scrollable, the horizontal/vertical scrollbars, mouse-wheel handling
// (incl. the physical-wheel classifier + inertial scrolling), shadows, and
// scroll-driven auto-hide. MouseWheelClassifier is a pure ring-buffer scorer
// driven by the official vscode test corpus (see batch168_truth.json).

import 'dart:math' as math;

import '../../../common/async.dart' as async;
import '../../../common/event.dart' as event;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/platform.dart' as platform;
import '../../../common/scrollable.dart' as scr;
import '../../dom.dart' as dom;
import '../../fastDomNode.dart' as fdn;
import '../../mouseEvent.dart' as mouse;
import '../widget.dart' show Widget;
import 'abstractScrollbar.dart' show ScrollbarHost;
import 'horizontalScrollbar.dart' show HorizontalScrollbar;
import 'scrollableElementOptions.dart'
    show
        ScrollableElementChangeOptions,
        ScrollableElementCreationOptions,
        ScrollableElementResolvedOptions;
import 'verticalScrollbar.dart' show VerticalScrollbar;

// --- module constants -------------------------------------------------------
const int HIDE_TIMEOUT = 500;
const int SCROLL_WHEEL_SENSITIVITY = 50;
const bool SCROLL_WHEEL_SMOOTH_SCROLL_ENABLED = true;

int _revealOnScrollDisabledCount = 0;

/// 1:1: `disableScrollbarRevealOnScroll()`
lifecycle.IDisposable disableScrollbarRevealOnScroll() {
  _revealOnScrollDisabledCount++;
  return lifecycle.toDisposable(() => _revealOnScrollDisabledCount--);
}

/// Reset hook for tests (isolate the module-global counter between suites).
void resetRevealOnScrollDisabledCountForTest() =>
    _revealOnScrollDisabledCount = 0;
int get revealOnScrollDisabledCountForTest => _revealOnScrollDisabledCount;

const int DEFAULT_SCROLLBAR_SIZE = 10;
int _globalDefaultScrollbarSize = DEFAULT_SCROLLBAR_SIZE;
final event.Emitter<int> _onDidChangeDefaultScrollbarSizeEmitter =
    event.Emitter<int>();
event.Event<int> get onDidChangeDefaultScrollbarSize =>
    _onDidChangeDefaultScrollbarSizeEmitter.event;

/// 1:1: `setGlobalDefaultScrollbarSize(size)`
void setGlobalDefaultScrollbarSize(int size) {
  if (size != _globalDefaultScrollbarSize) {
    _globalDefaultScrollbarSize = size;
    _onDidChangeDefaultScrollbarSizeEmitter.fire(size);
  }
}

int get globalDefaultScrollbarSizeForTest => _globalDefaultScrollbarSize;
void resetGlobalDefaultScrollbarSizeForTest() =>
    _globalDefaultScrollbarSize = DEFAULT_SCROLLBAR_SIZE;

/// 1:1: `interface IOverviewRulerLayoutInfo`
class IOverviewRulerLayoutInfo {
  IOverviewRulerLayoutInfo({required this.parent, required this.insertBefore});
  final dom.DomElement parent;
  final dom.DomElement insertBefore;
}

// --- MouseWheelClassifier ---------------------------------------------------

class _MouseWheelClassifierItem {
  _MouseWheelClassifierItem(this.timestamp, this.deltaX, this.deltaY);
  final num timestamp;
  final num deltaX;
  final num deltaY;
  num score = 0;
}

/// 1:1: `export class MouseWheelClassifier`
class MouseWheelClassifier {
  MouseWheelClassifier();

  static final MouseWheelClassifier INSTANCE = MouseWheelClassifier();

  final int _capacity = 5;
  final List<_MouseWheelClassifierItem?> _memory =
      List<_MouseWheelClassifierItem?>.filled(5, null);
  int _front = -1;
  int _rear = -1;

  /// 1:1: `isPhysicalMouseWheel()`
  bool isPhysicalMouseWheel() {
    if (_front == -1 && _rear == -1) return false;

    num remainingInfluence = 1;
    num score = 0;
    int iteration = 1;

    int index = _rear;
    while (true) {
      final num influence = index == _front
          ? remainingInfluence
          : math.pow(2, -iteration);
      remainingInfluence -= influence;
      score += _memory[index]!.score * influence;

      if (index == _front) break;

      index = (_capacity + index - 1) % _capacity;
      iteration++;
    }

    return score <= 0.5;
  }

  /// 1:1: `acceptStandardWheelEvent(e)` (non-Chrome path; platform always
  /// stubbed to non-Chrome in the port runtime).
  void acceptStandardWheelEvent(mouse.StandardWheelEvent e) {
    accept(DateTime.now().microsecondsSinceEpoch / 1000, e.deltaX, e.deltaY);
  }

  /// 1:1: `accept(timestamp, deltaX, deltaY)`
  void accept(num timestamp, num deltaX, num deltaY) {
    _MouseWheelClassifierItem? previousItem;
    final item = _MouseWheelClassifierItem(timestamp, deltaX, deltaY);

    if (_front == -1 && _rear == -1) {
      _memory[0] = item;
      _front = 0;
      _rear = 0;
    } else {
      previousItem = _memory[_rear];
      _rear = (_rear + 1) % _capacity;
      if (_rear == _front) {
        _front = (_front + 1) % _capacity;
      }
      _memory[_rear] = item;
    }

    item.score = _computeScore(item, previousItem);
  }

  /// 1:1: `_computeScore(item, previousItem)`
  num _computeScore(_MouseWheelClassifierItem item,
      _MouseWheelClassifierItem? previousItem) {
    if (item.deltaX.abs() > 0 && item.deltaY.abs() > 0) return 1;

    num score = 0.5;
    if (!_isAlmostInt(item.deltaX) || !_isAlmostInt(item.deltaY)) {
      score += 0.25;
    }

    if (previousItem != null) {
      final num absDeltaX = item.deltaX.abs();
      final num absDeltaY = item.deltaY.abs();
      final num absPreviousDeltaX = previousItem.deltaX.abs();
      final num absPreviousDeltaY = previousItem.deltaY.abs();

      final num minDeltaX =
          math.max(math.min(absDeltaX, absPreviousDeltaX), 1);
      final num minDeltaY =
          math.max(math.min(absDeltaY, absPreviousDeltaY), 1);
      final num maxDeltaX = math.max(absDeltaX, absPreviousDeltaX);
      final num maxDeltaY = math.max(absDeltaY, absPreviousDeltaY);

      final bool isSameModulo =
          maxDeltaX % minDeltaX == 0 && maxDeltaY % minDeltaY == 0;
      if (isSameModulo) score -= 0.5;
    }

    return math.min(math.max(score, 0), 1);
  }

  /// 1:1: `_isAlmostInt(value)`
  bool _isAlmostInt(num value) {
    const num epsilon = 2.220446049250313e-16 * 100;
    final num delta = (value.round() - value).abs();
    return delta < 0.01 + epsilon;
  }
}

// --- resolveOptions ---------------------------------------------------------

/// 1:1: `resolveOptions(opts)`
ScrollableElementResolvedOptions resolveOptions(
    ScrollableElementCreationOptions opts) {
  final int defaultSize = _globalDefaultScrollbarSize;
  final result = ScrollableElementResolvedOptions(
    lazyRender: opts.lazyRender ?? false,
    className: opts.className ?? '',
    useShadows: opts.useShadows ?? true,
    handleMouseWheel: opts.handleMouseWheel ?? true,
    flipAxes: opts.flipAxes ?? false,
    consumeMouseWheelIfScrollbarIsNeeded:
        opts.consumeMouseWheelIfScrollbarIsNeeded ?? false,
    alwaysConsumeMouseWheel: opts.alwaysConsumeMouseWheel ?? false,
    scrollYToX: opts.scrollYToX ?? false,
    mouseWheelScrollSensitivity: opts.mouseWheelScrollSensitivity ?? 1,
    fastScrollSensitivity: opts.fastScrollSensitivity ?? 5,
    scrollPredominantAxis: opts.scrollPredominantAxis ?? true,
    mouseWheelSmoothScroll: opts.mouseWheelSmoothScroll ?? true,
    inertialScroll: opts.inertialScroll ?? false,
    arrowSize: opts.arrowSize ?? 11,
    listenOnDomNode: opts.listenOnDomNode,
    horizontal: opts.horizontal ?? scr.ScrollbarVisibility.Auto,
    horizontalScrollbarSize: opts.horizontalScrollbarSize ?? defaultSize,
    horizontalSliderSize: opts.horizontalSliderSize ?? 0,
    horizontalHasArrows: opts.horizontalHasArrows ?? false,
    vertical: opts.vertical ?? scr.ScrollbarVisibility.Auto,
    verticalScrollbarSize: opts.verticalScrollbarSize ?? defaultSize,
    verticalHasArrows: opts.verticalHasArrows ?? false,
    verticalSliderSize: opts.verticalSliderSize ?? 0,
    scrollByPage: opts.scrollByPage ?? false,
  );

  result.horizontalSliderSize =
      opts.horizontalSliderSize ?? result.horizontalScrollbarSize;
  result.verticalSliderSize =
      opts.verticalSliderSize ?? result.verticalScrollbarSize;

  if (platform.isMacintosh) {
    result.className += ' mac';
  }

  return result;
}

// --- injectable factories (test seams) -------------------------------------

HorizontalScrollbar Function(scr.Scrollable, ScrollableElementResolvedOptions,
        ScrollbarHost) horizontalScrollbarFactory =
    (scr.Scrollable s, ScrollableElementResolvedOptions o, ScrollbarHost h) =>
        HorizontalScrollbar(s, o, h);
VerticalScrollbar Function(scr.Scrollable, ScrollableElementResolvedOptions,
        ScrollbarHost) verticalScrollbarFactory =
    (scr.Scrollable s, ScrollableElementResolvedOptions o, ScrollbarHost h) =>
        VerticalScrollbar(s, o, h);
async.TimeoutTimer Function() hideTimeoutFactory =
    () => async.TimeoutTimer();

// --- AbstractScrollableElement ----------------------------------------------

/// Structural reader for a wheel event's `defaultPrevented`.
bool _wheelDefaultPrevented(Object? e) {
  if (e == null) return false;
  if (e is dom.DomEvent) return e.defaultPrevented;
  try {
    // ignore: avoid_dynamic_calls
    return (e as dynamic).defaultPrevented == true;
  } catch (_) {
    return false;
  }
}

/// 1:1: `export abstract class AbstractScrollableElement extends Widget`
abstract class AbstractScrollableElement extends Widget {
  AbstractScrollableElement(
      dom.DomElement element,
      ScrollableElementCreationOptions options,
      scr.Scrollable scrollable)
      : super() {
    element.style['overflow'] = 'hidden';
    options_ = resolveOptions(options);
    _scrollable = scrollable;

    register(_scrollable.onScroll((dynamic v) {
      final scr.ScrollEvent e = v as scr.ScrollEvent;
      _onWillScroll.fire(e);
      onDidScrollInternal(e);
      _onScroll.fire(e);
    }));

    final scrollbarHost = _ScrollbarHostImpl(this);
    _verticalScrollbar = register(
        verticalScrollbarFactory(_scrollable, options_, scrollbarHost));
    _horizontalScrollbar = register(
        horizontalScrollbarFactory(_scrollable, options_, scrollbarHost));

    _domNode = dom.document.createElement('div');
    _domNode.className = 'monaco-scrollable-element ${options_.className}';
    _domNode.setAttribute('role', 'presentation');
    _domNode.style['position'] = 'relative';
    _domNode.style['overflow'] = 'hidden';
    _domNode.appendChild(element);
    _domNode.appendChild(_horizontalScrollbar.realDomNode);
    _domNode.appendChild(_verticalScrollbar.realDomNode);

    if (options_.useShadows) {
      _leftShadowDomNode =
          _shadowNode();
      _topShadowDomNode = _shadowNode();
      _topLeftShadowDomNode = _shadowNode();
    } else {
      _leftShadowDomNode = null;
      _topShadowDomNode = null;
      _topLeftShadowDomNode = null;
    }

    _listenOnDomNode =
        options_.listenOnDomNode as dom.DomElement? ?? _domNode;

    _mouseWheelToDispose = <lifecycle.IDisposable>[];
    setListeningToMouseWheel(options_.handleMouseWheel);

    onmouseover(_listenOnDomNode, (mouse.IMouseEvent e) => onMouseOverInternal(e));
    onmouseleave(
        _listenOnDomNode, (mouse.IMouseEvent e) => onMouseLeaveInternal(e));

    _hideTimeout = register(hideTimeoutFactory());
    _isDragging = false;
    _mouseIsOver = false;
    shouldRender = true;
    _revealOnScroll = true;

    final bool hSizeExplicit = options.horizontalScrollbarSize != null;
    final bool vSizeExplicit = options.verticalScrollbarSize != null;
    if (!hSizeExplicit || !vSizeExplicit) {
      register(onDidChangeDefaultScrollbarSize((dynamic v) {
        final int newSize = v as int;
        updateOptions(ScrollableElementChangeOptions()
          ..horizontalScrollbarSize = hSizeExplicit ? null : newSize
          ..verticalScrollbarSize = vSizeExplicit ? null : newSize);
      }));
    }
  }

  fdn.FastDomNode? _shadowNode() {
    final node = fdn.createFastDomNode<_ShadowEl>(
        _ShadowEl(dom.document.createElement('div')));
    node.setClassName('shadow');
    _domNode.appendChild(node.domNode.real);
    return node;
  }

  late final ScrollableElementResolvedOptions options_;
  late final scr.Scrollable _scrollable;
  late final VerticalScrollbar _verticalScrollbar;
  late final HorizontalScrollbar _horizontalScrollbar;
  late final dom.DomElement _domNode;

  fdn.FastDomNode? _leftShadowDomNode;
  fdn.FastDomNode? _topShadowDomNode;
  fdn.FastDomNode? _topLeftShadowDomNode;

  late final dom.DomElement _listenOnDomNode;
  late List<lifecycle.IDisposable> _mouseWheelToDispose;

  bool _isDragging = false;
  bool _mouseIsOver = false;
  late final async.TimeoutTimer _hideTimeout;
  bool shouldRender = false;
  bool _revealOnScroll = false;

  async.TimeoutTimer? _inertialTimeout;
  final Map<String, num> _inertialSpeed = <String, num>{'X': 0, 'Y': 0};

  final event.Emitter<scr.ScrollEvent> _onScroll = event.Emitter<scr.ScrollEvent>();
  event.Event<scr.ScrollEvent> get onScroll => _onScroll.event;
  final event.Emitter<scr.ScrollEvent> _onWillScroll =
      event.Emitter<scr.ScrollEvent>();
  event.Event<scr.ScrollEvent> get onWillScroll => _onWillScroll.event;

  ScrollableElementResolvedOptions get options => options_;

  @override
  void dispose() {
    lifecycle.dispose(_mouseWheelToDispose);
    _mouseWheelToDispose = <lifecycle.IDisposable>[];
    if (_inertialTimeout != null) {
      _inertialTimeout!.dispose();
      _inertialTimeout = null;
    }
    super.dispose();
  }

  dom.DomElement getDomNode() => _domNode;

  IOverviewRulerLayoutInfo getOverviewRulerLayoutInfo() =>
      IOverviewRulerLayoutInfo(
          parent: _domNode,
          insertBefore: _verticalScrollbar.realDomNode);

  void delegateVerticalScrollbarPointerDown(Object browserEvent) =>
      _verticalScrollbar.delegatePointerDown(browserEvent);

  scr.IScrollDimensions getScrollDimensions() =>
      _scrollable.getScrollDimensions();

  void setScrollDimensions(scr.NewScrollDimensions dimensions) =>
      _scrollable.setScrollDimensions(dimensions, false);

  void updateClassName(String newClassName) {
    options_.className = newClassName;
    if (platform.isMacintosh) options_.className += ' mac';
    _domNode.className = 'monaco-scrollable-element ${options_.className}';
  }

  void updateOptions(ScrollableElementChangeOptions newOptions) {
    if (newOptions.handleMouseWheel != null) {
      options_.handleMouseWheel = newOptions.handleMouseWheel!;
      setListeningToMouseWheel(options_.handleMouseWheel);
    }
    if (newOptions.mouseWheelScrollSensitivity != null) {
      options_.mouseWheelScrollSensitivity =
          newOptions.mouseWheelScrollSensitivity!;
    }
    if (newOptions.fastScrollSensitivity != null) {
      options_.fastScrollSensitivity = newOptions.fastScrollSensitivity!;
    }
    if (newOptions.scrollPredominantAxis != null) {
      options_.scrollPredominantAxis = newOptions.scrollPredominantAxis!;
    }
    if (newOptions.horizontal != null) options_.horizontal = newOptions.horizontal!;
    if (newOptions.vertical != null) options_.vertical = newOptions.vertical!;
    if (newOptions.horizontalScrollbarSize != null) {
      options_.horizontalScrollbarSize = newOptions.horizontalScrollbarSize!;
    }
    if (newOptions.verticalScrollbarSize != null) {
      options_.verticalScrollbarSize = newOptions.verticalScrollbarSize!;
    }
    if (newOptions.scrollByPage != null) {
      options_.scrollByPage = newOptions.scrollByPage!;
    }
    _horizontalScrollbar.updateOptions(options_);
    _verticalScrollbar.updateOptions(options_);
    if (!options_.lazyRender) renderInternal();
  }

  void setRevealOnScroll(bool value) => _revealOnScroll = value;

  void delegateScrollFromMouseWheelEvent(Object browserEvent) =>
      onMouseWheel(new mouse.StandardWheelEvent(null));

  Future<void> periodicSync() async {
    bool scheduleAgain = false;
    if (_inertialSpeed['X'] != 0 || _inertialSpeed['Y'] != 0) {
      final scr.IScrollPosition pos = _scrollable.getCurrentScrollPosition();
      _scrollable.setScrollPositionNow(scr.NewScrollPosition(
          scrollTop: pos.scrollTop - _inertialSpeed['Y']! * 100,
          scrollLeft: pos.scrollLeft - _inertialSpeed['X']! * 100));
      _inertialSpeed['X'] = _inertialSpeed['X']! * 0.9;
      _inertialSpeed['Y'] = _inertialSpeed['Y']! * 0.9;
      if (_inertialSpeed['X']!.abs() < 0.01) _inertialSpeed['X'] = 0;
      if (_inertialSpeed['Y']!.abs() < 0.01) _inertialSpeed['Y'] = 0;
      scheduleAgain = _inertialSpeed['X'] != 0 || _inertialSpeed['Y'] != 0;
    }
    if (scheduleAgain) {
      _inertialTimeout ??= async.TimeoutTimer();
      _inertialTimeout!.cancelAndSet(() => periodicSync(), (1000 / 60).round());
    } else {
      _inertialTimeout?.dispose();
      _inertialTimeout = null;
    }
  }

  void setListeningToMouseWheel(bool shouldListen) {
    final bool isListening = _mouseWheelToDispose.isNotEmpty;
    if (isListening == shouldListen) return;
    lifecycle.dispose(_mouseWheelToDispose);
    _mouseWheelToDispose = <lifecycle.IDisposable>[];
    if (shouldListen) {
      _mouseWheelToDispose.add(dom.addDisposableListener(
          _listenOnDomNode, dom.EventType.MOUSE_WHEEL, (dom.DomEvent e) {
        onMouseWheel(mouse.StandardWheelEvent(null));
      }, false));
    }
  }

  /// 1:1: `_onMouseWheel(e)` — wheel delta classification + application.
  void onMouseWheel(mouse.StandardWheelEvent e) {
    if (_wheelDefaultPrevented(e.browserEvent)) return;

    final classifier = MouseWheelClassifier.INSTANCE;
    if (SCROLL_WHEEL_SMOOTH_SCROLL_ENABLED) {
      classifier.acceptStandardWheelEvent(e);
    }

    bool didScroll = false;
    if (e.deltaY != 0 || e.deltaX != 0) {
      num deltaY = e.deltaY * options_.mouseWheelScrollSensitivity;
      num deltaX = e.deltaX * options_.mouseWheelScrollSensitivity;

      if (options_.scrollPredominantAxis) {
        if (options_.scrollYToX && deltaX + deltaY == 0) {
          deltaX = 0;
          deltaY = 0;
        } else if (deltaY.abs() >= deltaX.abs()) {
          deltaX = 0;
        } else {
          deltaY = 0;
        }
      }

      if (options_.flipAxes) {
        final num t = deltaY;
        deltaY = deltaX;
        deltaX = t;
      }

      final bool shiftConvert = !platform.isMacintosh &&
          e.browserEvent != null &&
          e.browserEvent!.shiftKey;
      if ((options_.scrollYToX || shiftConvert) && deltaX == 0) {
        deltaX = deltaY;
        deltaY = 0;
      }

      if (e.browserEvent != null && e.browserEvent!.altKey) {
        deltaX = deltaX * options_.fastScrollSensitivity;
        deltaY = deltaY * options_.fastScrollSensitivity;
      }

      final scr.IScrollPosition futureScrollPosition =
          _scrollable.getFutureScrollPosition();

      scr.NewScrollPosition desiredScrollPosition = scr.NewScrollPosition();
      if (deltaY != 0) {
        final num deltaScrollTop = SCROLL_WHEEL_SENSITIVITY * deltaY;
        final num desiredScrollTop = futureScrollPosition.scrollTop -
            (deltaScrollTop < 0
                ? deltaScrollTop.floor()
                : deltaScrollTop.ceil());
        _verticalScrollbar.writeScrollPosition(
            desiredScrollPosition, desiredScrollTop);
      }
      if (deltaX != 0) {
        final num deltaScrollLeft = SCROLL_WHEEL_SENSITIVITY * deltaX;
        final num desiredScrollLeft = futureScrollPosition.scrollLeft -
            (deltaScrollLeft < 0
                ? deltaScrollLeft.floor()
                : deltaScrollLeft.ceil());
        _horizontalScrollbar.writeScrollPosition(
            desiredScrollPosition, desiredScrollLeft);
      }

      final scr.IScrollPosition validated =
          _scrollable.validateScrollPosition(desiredScrollPosition);
      final num? desiredLeft = validated.scrollLeft;
      final num? desiredTop = validated.scrollTop;

      if (options_.inertialScroll &&
          (deltaX != 0 || deltaY != 0) &&
          !classifier.isPhysicalMouseWheel()) {
        bool startPeriodic = false;
        if (_inertialSpeed['X'] == 0 && _inertialSpeed['Y'] == 0) {
          startPeriodic = true;
        }
        _inertialSpeed['Y'] =
            (deltaY < 0 ? -1 : 1) * math.pow(deltaY.abs(), 1.02);
        _inertialSpeed['X'] =
            (deltaX < 0 ? -1 : 1) * math.pow(deltaX.abs(), 1.02);
        if (startPeriodic) periodicSync();
      }

      if (futureScrollPosition.scrollLeft != desiredLeft ||
          futureScrollPosition.scrollTop != desiredTop) {
        final bool canPerformSmoothScroll = SCROLL_WHEEL_SMOOTH_SCROLL_ENABLED &&
            options_.mouseWheelSmoothScroll &&
            classifier.isPhysicalMouseWheel();
        final scr.NewScrollPosition apply = scr.NewScrollPosition(
            scrollLeft: desiredLeft, scrollTop: desiredTop);
        if (canPerformSmoothScroll) {
          _scrollable.setScrollPositionSmooth(apply);
        } else {
          _scrollable.setScrollPositionNow(apply);
        }
        didScroll = true;
      }
    }

    bool consumeMouseWheel = didScroll;
    if (!consumeMouseWheel && options_.alwaysConsumeMouseWheel) {
      consumeMouseWheel = true;
    }
    if (!consumeMouseWheel &&
        options_.consumeMouseWheelIfScrollbarIsNeeded &&
        (_verticalScrollbar.isNeeded() || _horizontalScrollbar.isNeeded())) {
      consumeMouseWheel = true;
    }

    if (consumeMouseWheel) {
      if (e.browserEvent is dom.DomEvent) {
        (e.browserEvent as dom.DomEvent).preventDefault();
        (e.browserEvent as dom.DomEvent).stopPropagation();
      }
    }
  }

  void onDidScrollInternal(scr.ScrollEvent e) {
    shouldRender = _horizontalScrollbar.onDidScroll(e) || shouldRender;
    shouldRender = _verticalScrollbar.onDidScroll(e) || shouldRender;
    if (options_.useShadows) shouldRender = true;
    if (_revealOnScroll && _revealOnScrollDisabledCount == 0) revealInternal();
    if (!options_.lazyRender) renderInternal();
  }

  void renderNow() {
    if (!options_.lazyRender) {
      throw StateError('Please use `lazyRender` together with `renderNow`!');
    }
    renderInternal();
  }

  void renderInternal() {
    if (!shouldRender) return;
    shouldRender = false;
    _horizontalScrollbar.render();
    _verticalScrollbar.render();
    if (options_.useShadows) {
      final scr.IScrollPosition scrollState =
          _scrollable.getCurrentScrollPosition();
      final bool enableTop = scrollState.scrollTop > 0;
      final bool enableLeft = scrollState.scrollLeft > 0;
      final String leftClassName = enableLeft ? ' left' : '';
      final String topClassName = enableTop ? ' top' : '';
      final String topLeftClassName =
          enableLeft || enableTop ? ' top-left-corner' : '';
      _leftShadowDomNode!.setClassName('shadow$leftClassName');
      _topShadowDomNode!.setClassName('shadow$topClassName');
      _topLeftShadowDomNode!.setClassName(
          'shadow$topLeftClassName$topClassName$leftClassName');
    }
  }

  void onDragStartInternal() {
    _isDragging = true;
    revealInternal();
  }

  void onDragEndInternal() {
    _isDragging = false;
    hideInternal();
  }

  void onMouseLeaveInternal(mouse.IMouseEvent e) {
    _mouseIsOver = false;
    hideInternal();
  }

  void onMouseOverInternal(mouse.IMouseEvent e) {
    _mouseIsOver = true;
    revealInternal();
  }

  void revealInternal() {
    _verticalScrollbar.beginReveal();
    _horizontalScrollbar.beginReveal();
    scheduleHideInternal();
  }

  void hideInternal() {
    if (!_mouseIsOver && !_isDragging) {
      _verticalScrollbar.beginHide();
      _horizontalScrollbar.beginHide();
    }
  }

  void scheduleHideInternal() {
    if (!_mouseIsOver && !_isDragging) {
      _hideTimeout.cancelAndSet(() => hideInternal(), HIDE_TIMEOUT);
    }
  }
}

/// 1:1: `ScrollbarHost` implementation forwarding to the scrollable element.
class _ScrollbarHostImpl implements ScrollbarHost {
  _ScrollbarHostImpl(this._owner);
  final AbstractScrollableElement _owner;
  @override
  void onMouseWheel(mouse.StandardWheelEvent e) => _owner.onMouseWheel(e);
  @override
  void onDragStart() => _owner.onDragStartInternal();
  @override
  void onDragEnd() => _owner.onDragEndInternal();
}

/// Minimal FastDomNode-compatible element for shadow divs.
class _ShadowEl implements fdn.DomElement {
  _ShadowEl(this.real);
  final dom.DomElement real;
  @override
  Map<String, String> get style => real.style;
  @override
  String get className => real.className;
  @override
  set className(String v) => real.className = v;
  @override
  fdn.DomTokenList get classList => real.classList;
  @override
  void focus() => real.focus();
  @override
  void setAttribute(String n, String v) => real.setAttribute(n, v);
  @override
  void removeAttribute(String n) => real.removeAttribute(n);
  @override
  void appendChild(fdn.DomElement c) => real.appendChild((c as _ShadowEl).real);
  @override
  void removeChild(fdn.DomElement c) => real.removeChild((c as _ShadowEl).real);
}

// --- concrete subclasses ----------------------------------------------------

/// 1:1: `export class ScrollableElement extends AbstractScrollableElement`
class ScrollableElement extends AbstractScrollableElement {
  ScrollableElement(dom.DomElement element, ScrollableElementCreationOptions options)
      : this._build(element, options);

  ScrollableElement._build(
      dom.DomElement element, ScrollableElementCreationOptions options)
      : super(element, _prep(options, true), _makeScrollable(element, true)) {
    register(_scrollableFor(element, true)!);
  }

  static final Map<dom.DomElement, scr.Scrollable> _scrollables =
      <dom.DomElement, scr.Scrollable>{};

  static ScrollableElementCreationOptions _prep(
          ScrollableElementCreationOptions options, bool integer) =>
      options..mouseWheelSmoothScroll = false;

  static scr.Scrollable _makeScrollable(
      dom.DomElement element, bool integer) {
    final scr.Scrollable s = scr.Scrollable(scr.ScrollableOptions(
      forceIntegerValues: integer,
      smoothScrollDuration: 0,
      scheduleAtNextAnimationFrame: (cb) =>
          dom.scheduleAtNextAnimationFrame(dom.getWindow(element), cb),
    ));
    _scrollables[element] = s;
    return s;
  }

  static scr.Scrollable? _scrollableFor(
      dom.DomElement? element, bool integer) =>
      element == null ? null : _scrollables[element];

  void setScrollPosition(scr.NewScrollPosition update) =>
      _scrollable.setScrollPositionNow(update);
  scr.IScrollPosition getScrollPosition() =>
      _scrollable.getCurrentScrollPosition();
}

/// 1:1: `export class SmoothScrollableElement`
class SmoothScrollableElement extends AbstractScrollableElement {
  SmoothScrollableElement(dom.DomElement element,
      ScrollableElementCreationOptions options, scr.Scrollable scrollable)
      : super(element, options, scrollable);

  void setScrollPosition(scr.NewScrollPosition update,
      [bool reuseAnimation = false]) {
    if (reuseAnimation) {
      _scrollable.setScrollPositionSmooth(update, reuseAnimation);
    } else {
      _scrollable.setScrollPositionNow(update);
    }
  }
  scr.IScrollPosition getScrollPosition() =>
      _scrollable.getCurrentScrollPosition();
}

/// 1:1: `export class DomScrollableElement`
class DomScrollableElement extends AbstractScrollableElement {
  DomScrollableElement(this._element, ScrollableElementCreationOptions options)
      : super(_element, _prep(options), _makeScrollable(_element)) {
    register(_scrollable);
    register(onScroll((dynamic v) {
      final scr.ScrollEvent e = v as scr.ScrollEvent;
      if (e.scrollTopChanged) _element.scrollTop = e.scrollTop as int;
      if (e.scrollLeftChanged) _element.scrollLeft = e.scrollLeft as int;
    }));
    scanDomNode();
  }

  final dom.DomElement _element;

  /// Test seam: number of `scanDomNode()` calls observed on this element.
  /// Mirrors the counter used by the hoverWidget truth harness stub.
  int scans = 0;

  static ScrollableElementCreationOptions _prep(
          ScrollableElementCreationOptions options) =>
      options..mouseWheelSmoothScroll = false;

  static scr.Scrollable _makeScrollable(dom.DomElement element) =>
      scr.Scrollable(scr.ScrollableOptions(
        forceIntegerValues: false,
        smoothScrollDuration: 0,
        scheduleAtNextAnimationFrame: (cb) =>
            dom.scheduleAtNextAnimationFrame(dom.getWindow(element), cb),
      ));

  void setScrollPosition(scr.NewScrollPosition update) =>
      _scrollable.setScrollPositionNow(update);
  scr.IScrollPosition getScrollPosition() =>
      _scrollable.getCurrentScrollPosition();

  void scanDomNode() {
    scans++;
    setScrollDimensions(scr.NewScrollDimensions(
        width: _element.clientWidth,
        scrollWidth: _element.scrollWidth,
        height: _element.clientHeight,
        scrollHeight: _element.scrollHeight));
    setScrollPosition(scr.NewScrollPosition(
        scrollLeft: _element.scrollLeft, scrollTop: _element.scrollTop));
  }
}
