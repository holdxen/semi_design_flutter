// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/ui/contextview/contextview.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS carriers:
//   - `HTMLElement` -> `dom.DomElement`; `ShadowRoot` -> `dom.DomShadowRoot`.
//   - `Event`/`UIEvent` -> `dom.DomEvent` via `addStandardDisposableListener`.
//   - `Disposable`/`DisposableStore` -> `lifecycle` equivalents.
//   - `setTimeout` -> `dart:async.Timer`.
//   - `getComputedStyle` -> injectable `computedStyleProvider`.
//   - `showPopover`/`hidePopover`/`isConnected` -> injectable popover hooks.
// ---------------------------------------------------------------------------

import 'dart:async';

import '../../dom.dart' as dom;
import '../../mouseEvent.dart' as mouse;
import '../../keyboardEvent.dart' as keyboard;
import '../../window.dart' as window;
import '../../domStylesheets.dart' as domStylesheets;
import '../../browser.dart' as browser;
import '../../canIUse.dart' as canIUse;
import '../../../common/errors.dart' as errors;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/layout.dart' as lay;
import '../../../common/platform.dart' as platform;
import 'windowControlsOverlay.dart' as wco;

export '../../../common/layout.dart'
    show AnchorAlignment, AnchorAxisAlignment, AnchorPosition, IRect;

/// 1:1: `export const enum ContextViewDOMPosition`.
class ContextViewDOMPosition {
  static const int ABSOLUTE = 1;
  static const int FIXED = 2;
  static const int FIXED_SHADOW = 3;
  static const int POPOVER = 4;
  static const int POPOVER_SHADOW = 5;
}

/// 1:1: `isPopoverDOMPosition(domPosition)`.
bool isPopoverDOMPosition(int domPosition) =>
    domPosition == ContextViewDOMPosition.POPOVER ||
    domPosition == ContextViewDOMPosition.POPOVER_SHADOW;

/// 1:1: `export interface IContextViewRenderContext`.
class IContextViewRenderContext {
  IContextViewRenderContext(this.domPosition);
  final int domPosition;
}

/// 1:1: `export interface IContextViewOptions`.
class IContextViewOptions {
  IContextViewOptions({this.getFallbackContainer});

  final dom.DomElement Function(dom.DomElement owner)? getFallbackContainer;
}

/// 1:1: `export interface IAnchor`.
class IAnchor {
  IAnchor(this.x, this.y, [this.width, this.height]);
  final num x;
  final num y;
  final num? width;
  final num? height;
}

/// 1:1: `isAnchor(obj)`.
bool isAnchor(Object? obj) {
  if (obj == null) return false;
  if (obj is Map) {
    return obj['x'] is num && obj['y'] is num;
  }
  // ignore: unnecessary_type_check
  if (obj is IAnchor) return true;
  if (obj is dom.DomElement || obj is dom.DomMouseEvent) return false;
  final dynamic d = obj;
  try {
    return d.x is num && d.y is num;
  } catch (_) {
    return false;
  }
}

/// 1:1: `export interface IDelegate`.
abstract class IDelegate {
  Object getAnchor();
  lifecycle.IDisposable? render(
      dom.DomElement container, [IContextViewRenderContext? context]);
  void focus();
  void layout();
  int? get anchorAlignment;
  int? get anchorPosition;
  int? get anchorAxisAlignment;
  bool? get canRelayout;
  /// 1:1: `onDOMEvent?(e: Event, activeElement: HTMLElement): void;`
  /// Runtime events may be `StandardMouseEvent` / `StandardKeyboardEvent`
  /// wrappers produced by `addStandardDisposableListener`.
  void Function(Object e, dom.DomElement activeElement)? onDOMEventHandler;
  void onHide([Object? data]);
  IContextViewCloseAnimation? get closeAnimation;
  int? get layer;
}

/// 1:1: `export interface IContextViewCloseAnimation`.
class IContextViewCloseAnimation {
  IContextViewCloseAnimation({required this.className, required this.duration,
      this.requiredAncestorClasses});

  final String className;
  final int duration;
  final List<Object>? requiredAncestorClasses;
}

/// 1:1: `hasRequiredAncestorClasses(element, classNames)`.
bool hasRequiredAncestorClasses(
  dom.DomElement element,
  List<Object>? classNames,
) {
  if (classNames == null || classNames.isEmpty) return true;

  dom.DomNode? candidate = element;
  while (candidate != null) {
    final dom.DomNode current = candidate;
    if (current is dom.DomElement) {
      final bool all = classNames.every((Object requirement) {
        if (requirement is String) {
          return current.classList.contains(requirement);
        }
        final List<Object> names = requirement as List<Object>;
        return names.any((Object n) => current.classList.contains(n as String));
      });
      if (all) return true;
    }

    final dom.DomElement? parent = current.parentElement;
    if (parent != null) {
      candidate = parent;
    } else {
      final dom.DomNode root = current.getRootNode();
      // ignore: unnecessary_type_check
      if (root is dom.DomShadowRoot && root.host is dom.DomElement) {
        candidate = root.host;
      } else {
        candidate = null;
      }
    }
  }
  return false;
}

const String CONTEXT_VIEW_MENU_MOTION_CLASS = 'context-view-menu-motion';
const String CONTEXT_VIEW_MENU_MOTION_CLOSING_CLASS =
    'context-view-menu-motion-closing';
const int CONTEXT_VIEW_MENU_MOTION_CLOSE_ANIMATION_DURATION = 150;
const List<Object> CONTEXT_VIEW_MENU_MOTION_ANCESTOR_CLASSES = <Object>[
  <String>['modern-ui', 'modern-ui-frosted-glass'],
  'monaco-enable-motion',
];
const String CONTEXT_VIEW_CLOSE_ANIMATION_DURATION_VARIABLE =
    '--vscode-context-view-close-animation-duration';
const String CONTEXT_VIEW_MENU_MOTION_SHADOW_VARIABLE =
    '--vscode-context-view-menu-motion-shadow';
const String CONTEXT_VIEW_MENU_MOTION_BACKDROP_OPACITY_VARIABLE =
    '--vscode-context-view-menu-motion-backdrop-opacity';
const String CONTEXT_VIEW_MENU_MOTION_CLOSE_START_OPACITY_VARIABLE =
    '--vscode-context-view-menu-motion-close-start-opacity';
const String CONTEXT_VIEW_MENU_MOTION_CLOSE_START_TRANSFORM_VARIABLE =
    '--vscode-context-view-menu-motion-close-start-transform';
const int CONTEXT_VIEW_MENU_MOTION_OPEN_DURATION_MS = 250;
const String CONTEXT_VIEW_MENU_MOTION_EASING = 'cubic-bezier(0.22, 1, 0.36, 1)';

final IContextViewCloseAnimation contextViewMenuCloseAnimation =
    IContextViewCloseAnimation(
  className: CONTEXT_VIEW_MENU_MOTION_CLOSING_CLASS,
  duration: CONTEXT_VIEW_MENU_MOTION_CLOSE_ANIMATION_DURATION,
  requiredAncestorClasses: CONTEXT_VIEW_MENU_MOTION_ANCESTOR_CLASSES,
);

/// 1:1: `getContextViewMenuMotionCss(enabledSelectorPrefix)`.
String getContextViewMenuMotionCss(String enabledSelectorPrefix) => '''
	$enabledSelectorPrefix .context-view.$CONTEXT_VIEW_MENU_MOTION_CLASS {
		animation: none;
		box-shadow: none;
		overflow: visible;
	}
	$enabledSelectorPrefix .context-view.$CONTEXT_VIEW_MENU_MOTION_CLASS > .monaco-scrollable-element {
		animation: context-view-menu-motion-open ${CONTEXT_VIEW_MENU_MOTION_OPEN_DURATION_MS}ms $CONTEXT_VIEW_MENU_MOTION_EASING backwards;
		box-shadow: var($CONTEXT_VIEW_MENU_MOTION_SHADOW_VARIABLE);
		transform-origin: top left;
		will-change: opacity;
	}
	$enabledSelectorPrefix .context-view.$CONTEXT_VIEW_MENU_MOTION_CLASS.right > .monaco-scrollable-element { transform-origin: top right; }
	$enabledSelectorPrefix .context-view.$CONTEXT_VIEW_MENU_MOTION_CLASS.top > .monaco-scrollable-element { transform-origin: bottom left; }
	$enabledSelectorPrefix .context-view.$CONTEXT_VIEW_MENU_MOTION_CLASS.top.right > .monaco-scrollable-element { transform-origin: bottom right; }
	$enabledSelectorPrefix .context-view.$CONTEXT_VIEW_MENU_MOTION_CLASS.$CONTEXT_VIEW_MENU_MOTION_CLOSING_CLASS > .monaco-scrollable-element {
		animation: context-view-menu-motion-close var($CONTEXT_VIEW_CLOSE_ANIMATION_DURATION_VARIABLE) $CONTEXT_VIEW_MENU_MOTION_EASING both;
		pointer-events: none;
	}
	@keyframes context-view-menu-motion-open {
		from, to { $CONTEXT_VIEW_MENU_MOTION_BACKDROP_OPACITY_VARIABLE: 100%; }
		0% { opacity: 0; transform: scale(0.97); }
		100% { opacity: 1; transform: scale(1); }
	}
	@keyframes context-view-menu-motion-close {
		from, to { $CONTEXT_VIEW_MENU_MOTION_BACKDROP_OPACITY_VARIABLE: 100%; }
		0% { opacity: var($CONTEXT_VIEW_MENU_MOTION_CLOSE_START_OPACITY_VARIABLE, 1); transform: var($CONTEXT_VIEW_MENU_MOTION_CLOSE_START_TRANSFORM_VARIABLE, scale(1)); }
		100% { opacity: 0; transform: scale(0.99); }
	}''';

dom.DomElement? _contextViewMenuMotionStyleSheet;

void ensureContextViewMenuMotionStyleSheet() {
  _contextViewMenuMotionStyleSheet ??= domStylesheets.createStyleSheet(null,
      (dom.DomElement style) {
    style.textContent =
        getContextViewMenuMotionCss('.modern-ui.monaco-enable-motion');
  });
}

/// 1:1: `export interface IContextViewProvider`.
abstract class IContextViewProvider {
  void showContextView(IDelegate delegate, [dom.DomElement? container]);
  void hideContextView();
  void layout();
}

/// 1:1: `getViewDevicePixelAlignmentOffset(...)`.
num getViewDevicePixelAlignmentOffset(
  num start,
  num size,
  num anchorStart,
  num anchorSize,
  num renderedStart,
  num renderedSize,
  num viewportSize,
  num devicePixelRatio,
) {
  const num epsilon = 0.01;
  final bool before = start + size <= anchorStart + epsilon;
  final bool beside = before || start + epsilon >= anchorStart + anchorSize;
  final bool endsWithAnchor =
      (start + size - (anchorStart + anchorSize)).abs() <= epsilon &&
          (start - anchorStart).abs() > epsilon;
  final List<String> roundings = <String>[
    (before || (!beside && endsWithAnchor)) ? 'nearestEnd' : 'nearest',
  ];
  if (!beside) {
    roundings.addAll(<String>['start', 'end']);
  }
  final num anchorEdge = before ? anchorStart : anchorStart + anchorSize;
  final num? anchorEnd =
      (start + size - anchorEdge).abs() <= epsilon
          ? anchorEdge - start + renderedStart
          : null;
  for (final String rounding in roundings) {
    final num offset = dom.getDevicePixelAlignmentOffset(
        renderedStart, devicePixelRatio, rounding, renderedSize, anchorEnd);
    if ((offset >= 0 || renderedStart + offset >= -0.001) &&
        (offset <= 0 ||
            renderedStart + renderedSize + offset <= viewportSize + 0.001)) {
      return offset;
    }
  }
  return 0;
}

/// 1:1: `alignViewToDevicePixels(...)`.
wco.IWindowControlsOverlayPosition alignViewToDevicePixels(
  wco.IWindowControlsOverlayPosition position,
  wco.IWindowControlsOverlaySize layoutSize,
  wco.IWindowControlsOverlaySize renderedSize,
  lay.IRect anchor,
  wco.IWindowControlsOverlayViewport viewport,
  num devicePixelRatio,
  wco.IWindowControlsOverlayTitlebarRect? titlebarAreaRect,
) {
  num align(num start, num viewLayoutSize, num viewRenderedSize,
          num anchorStart, num anchorSize, num viewportStart, num viewportSize) =>
      start +
      getViewDevicePixelAlignmentOffset(
          start,
          viewLayoutSize,
          anchorStart,
          anchorSize,
          start - viewportStart,
          viewRenderedSize,
          viewportSize,
          devicePixelRatio);
  final wco.IWindowControlsOverlayPosition aligned =
      wco.WindowControlsOverlayPosition(
    top: align(position.top, layoutSize.height, renderedSize.height, anchor.top,
        anchor.height, viewport.top, viewport.height),
    left: align(position.left, layoutSize.width, renderedSize.width, anchor.left,
        anchor.width, viewport.left, viewport.width),
  );
  bool clearOfWindowControls(wco.IWindowControlsOverlayPosition candidate) =>
      identical(
          wco.avoidWindowControlsOverlay(
              titlebarAreaRect, viewport, renderedSize, candidate),
          candidate);
  if (!clearOfWindowControls(position)) return aligned;
  final List<wco.IWindowControlsOverlayPosition> candidates = <
      wco.IWindowControlsOverlayPosition>[
    aligned,
    wco.WindowControlsOverlayPosition(top: position.top, left: aligned.left),
    wco.WindowControlsOverlayPosition(top: aligned.top, left: position.left),
  ];
  for (final c in candidates) {
    if (clearOfWindowControls(c)) return c;
  }
  return position;
}

/// 1:1: `getAnchorRect(anchor)`.
lay.IRect getAnchorRect(Object anchor) {
  if (anchor is dom.DomElement) {
    final dom.IDomNodePagePosition p = dom.getDomNodePagePosition(anchor);
    return lay.IRect(p.top, p.left, p.width, p.height);
  }
  if (isAnchor(anchor)) {
    final dynamic a = anchor is Map
        ? anchor
        : anchor is IAnchor
            ? anchor
            : anchor;
    final num x = a is Map ? (a['x'] as num) : (a.x as num);
    final num y = a is Map ? (a['y'] as num) : (a.y as num);
    final num? w = a is Map ? a['width'] as num? : a.width;
    final num? h = a is Map ? a['height'] as num? : a.height;
    return lay.IRect(y, x, (w ?? 0) != 0 ? w! : 1, (h ?? 0) != 0 ? h! : 2);
  }
  final dom.DomMouseEvent mouse = anchor as dom.DomMouseEvent;
  return lay.IRect(mouse.pageY, mouse.pageX, 2, 2);
}

/// 1:1: `getDeepActiveElement(doc)`.
dom.DomNode? getDeepActiveElement(dom.DomDocument doc) {
  dom.DomNode? result = doc.activeElement;
  while (result is dom.DomElement && result.shadowRoot?.activeElement != null) {
    result = result.shadowRoot!.activeElement;
  }
  return result;
}

/// 1:1: `getFocusedContextView(doc)`.
dom.DomElement? getFocusedContextView(dom.DomDocument doc) {
  final dom.DomNode? active = getDeepActiveElement(doc);
  if (active is dom.DomElement) {
    return dom.findParentWithClass(active, 'context-view');
  }
  return null;
}

/// 1:1: `isContextViewFocused(doc)`.
bool isContextViewFocused(dom.DomDocument doc) =>
    getFocusedContextView(doc) != null;

const List<String> _bubbleUpEvents = <String>['click', 'keydown', 'focus', 'blur'];
const List<String> _bubbleDownEvents = <String>['click'];
const List<String> _isolatedKeyEvents = <String>[
  'keydown',
  'keyup',
  'keypress'
];

/// 1:1: computed-style carrier for `prepareMenuCloseAnimation`.
Map<String, String> Function(dom.DomElement surface)? computedStyleProvider;

/// 1:1: popover API carrier flags.
bool Function(dom.DomElement element) isConnectedProvider =
    (dom.DomElement element) => true;
bool Function(dom.DomElement element) popoverOpenProvider =
    (dom.DomElement element) => false;
void Function(dom.DomElement element)? showPopoverProvider;
void Function(dom.DomElement element)? hidePopoverProvider;
void Function(dom.DomElement element)? adoptPopoverResetStylesProvider;

/// 1:1: `e.composedPath()` on pointer events.
List<Object?> Function(dom.DomEvent event)? eventComposedPathProvider;

bool _isPopoverEnabled(dom.DomElement el) => showPopoverProvider != null;

void _showPopover(dom.DomElement el) => showPopoverProvider?.call(el);
void _hidePopoverApi(dom.DomElement el) => hidePopoverProvider?.call(el);

// ignore: unused_element
const String _popoverResetCss = '''
	.context-view[popover],
	.shadow-root-host[popover] {
		position: fixed; inset: auto; width: auto; height: auto;
		margin: 0; padding: 0; border: 0; overflow: visible;
		color: inherit; background: transparent;
	}''';

final lifecycle.IDisposable _none = lifecycle.Disposable.none;
final Expando<bool> _inertFlags = Expando<bool>();

class _HidingContextView {
  _HidingContextView({
    required this.disposable,
    required this.toDispose,
    required this.className,
  });

  final lifecycle.IDisposable disposable;
  final lifecycle.IDisposable toDispose;
  final String className;
}

/// 1:1: `export class ContextView extends Disposable`.
class ContextView extends lifecycle.Disposable {
  ContextView(
    dom.DomElement container,
    int domPosition, [
    IContextViewOptions? options,
  ]) : super() {
    _options = options ?? IContextViewOptions();
    ensureContextViewMenuMotionStyleSheet();
    _view = dom.DomElement('div')..className = 'context-view';
    dom.hide(<dom.DomElement>[_view]);
    setContainer(container, domPosition);
    register(lifecycle.toDisposable(
        () => setContainer(null, ContextViewDOMPosition.ABSOLUTE)));
  }

  dom.DomElement? _container;
  late final dom.DomElement _view;
  bool _useFixedPosition = false;
  bool _useShadowDOM = false;
  IDelegate? _delegate;
  lifecycle.IDisposable _toDisposeOnClean = lifecycle.Disposable.none;
  lifecycle.IDisposable _toDisposeOnSetContainer = lifecycle.Disposable.none;
  _HidingContextView? _hidingContextView;
  dom.DomShadowRoot? _shadowRoot;
  dom.DomElement? _shadowRootHostElement;
  int _domPosition = ContextViewDOMPosition.ABSOLUTE;
  late final lifecycle.DisposableStore _toDisposeOnPopoverHide = register(
      lifecycle.DisposableStore());
  dom.DomElement? _focusToRestore;
  int _showCount = 0;
  late final IContextViewOptions _options;

  dom.DomElement getViewElement() => _view;

  /// 1:1: `getEffectiveDOMPosition()`.
  int getEffectiveDOMPosition() => _domPosition;

  /// 1:1: `setContainer(container, domPosition)`.
  void setContainer(dom.DomElement? container, int domPosition) {
    final int previousDOMPosition = _domPosition;
    final bool usedShadowDOM = _useShadowDOM;
    final bool useShadowDOM =
        domPosition == ContextViewDOMPosition.FIXED_SHADOW ||
            domPosition == ContextViewDOMPosition.POPOVER_SHADOW;
    final bool unchanged = identical(container, _container) &&
        usedShadowDOM == useShadowDOM &&
        isPopoverDOMPosition(previousDOMPosition) ==
            isPopoverDOMPosition(domPosition);

    if (_container != null &&
        !unchanged &&
        isPopoverDOMPosition(previousDOMPosition)) {
      hide(null, true);
      completeHideAnimation();
    }

    _domPosition = domPosition;
    _useFixedPosition = domPosition != ContextViewDOMPosition.ABSOLUTE;
    _useShadowDOM = useShadowDOM;

    if (unchanged) return;

    if (_container != null) {
      _toDisposeOnSetContainer.dispose();
      _view.remove();
      _view.removeAttribute('popover');
      if (_shadowRoot != null) {
        _shadowRoot = null;
        _shadowRootHostElement?.remove();
        _shadowRootHostElement = null;
      }
      _container = null;
    }

    if (container == null) return;
    _container = container;
    final bool isPopover = isPopoverDOMPosition(domPosition);

    if (_useShadowDOM) {
      _shadowRootHostElement = dom.DomElement('div')
        ..className = 'shadow-root-host';
      _shadowRootHostElement!.style
        ..['position'] = 'fixed'
        ..['top'] = '0'
        ..['left'] = '0'
        ..['width'] = '0'
        ..['height'] = '0';
      if (isPopover) {
        _shadowRootHostElement!.setAttribute('popover', 'manual');
      } else {
        container.appendChild(_shadowRootHostElement!);
      }
      _shadowRoot = dom.DomShadowRoot(_shadowRootHostElement!);
      final dom.DomElement style = dom.document.createElement('style')
        ..textContent = _shadowRootCss;
      _shadowRoot!.appendChild(style);
      _shadowRoot!.appendChild(_view);
      _shadowRoot!.appendChild(dom.DomElement('slot'));
    } else {
      if (isPopover) {
        _view.setAttribute('popover', 'manual');
      } else {
        container.appendChild(_view);
      }
    }

    final lifecycle.DisposableStore store = lifecycle.DisposableStore();
    if (isPopover) {
      final dom.DomElement popoverElement = _getPopoverElement();
      for (final String event in _isolatedKeyEvents) {
        store.add(dom.addDisposableListener(popoverElement, event,
            (dom.DomEvent e) => dom.EventHelper.stopDom(e)));
      }
    }
    for (final String event in _bubbleUpEvents) {
      store.add(dom.addStandardDisposableListener(
          container, event, (Object e) => _onDOMEvent(e, false)));
    }
    for (final String event in _bubbleDownEvents) {
      store.add(dom.addStandardDisposableListener(
          container, event, (Object e) => _onDOMEvent(e, true), true));
    }
    _toDisposeOnSetContainer = store;
  }

  /// 1:1: `show(delegate)`.
  void show(IDelegate delegate) {
    _showCount++;
    completeHideAnimation();
    if (_isVisible()) hide(null, true);

    final dom.DomDocument ownerDocument =
        _container?.ownerDocument ?? dom.getActiveDocument();
    final dom.DomNode? active = getDeepActiveElement(ownerDocument);
    _focusToRestore = active is dom.DomElement ? active : null;

    if (isPopoverDOMPosition(_domPosition)) _showPopoverHost();

    dom.clearNode(_view);
    _view.className = 'context-view monaco-component';
    _view.style['top'] = '0px';
    _view.style['left'] = '0px';
    final String zIndex = '${2575 + (delegate.layer ?? 0)}';
    _view.style['zIndex'] = zIndex;
    if (_shadowRootHostElement != null) {
      _shadowRootHostElement!.style['zIndex'] = zIndex;
    }
    _view.style['position'] = _useFixedPosition ? 'fixed' : 'absolute';
    dom.show(<dom.DomElement>[_view]);

    _toDisposeOnClean =
        delegate.render(_view, IContextViewRenderContext(_domPosition)) ?? _none;
    _delegate = delegate;

    if (isPopoverDOMPosition(_domPosition)) _trackPopoverOwner();

    _doLayout();

    if (!identical(_delegate, delegate)) return;
    delegate.focus();
  }

  dom.DomElement _getPopoverElement() =>
      _shadowRootHostElement ?? _view;

  void _showPopoverHost() {
    final dom.DomElement? owner = _container;
    if (owner == null) return;
    final dom.DomElement popoverElement = _getPopoverElement();
    if (_isPopoverEnabled(popoverElement) && isConnectedProvider(owner)) {
      try {
        if (!identical(popoverElement.parentElement, owner)) {
          adoptPopoverResetStylesProvider?.call(owner);
          owner.appendChild(popoverElement);
        }
        if (!popoverOpenProvider(popoverElement)) {
          _showPopover(popoverElement);
        }
        return;
      } catch (e) {
        errors.onUnexpectedError(e);
      }
    }
    popoverElement.remove();
    final dom.DomElement fallbackContainer =
        _options.getFallbackContainer?.call(owner) ??
            dom.windowCarrier(dom.getWindow(owner)).document.body;
    setContainer(
        fallbackContainer,
        _domPosition == ContextViewDOMPosition.POPOVER_SHADOW
            ? ContextViewDOMPosition.FIXED_SHADOW
            : ContextViewDOMPosition.FIXED);
  }

  void _trackPopoverOwner() {
    final dom.DomElement? owner = _container;
    if (owner == null) return;
    final dom.DomElement popoverElement = _getPopoverElement();
    final Object targetWindow = dom.getWindow(owner);
    _toDisposeOnPopoverHide.add(dom.addDisposableTargetListener(
        targetWindow,
        'pointerdown',
        (dom.DomEvent e) {
          final List<Object?> path = eventComposedPathProvider?.call(e) ?? <Object?>[];
          if (!path.contains(popoverElement) && !path.contains(owner)) {
            _hideWithoutRestoringFocus();
          }
        },
        true));

    // ResizeObserver is a browser API with no Dart equivalent; the owner
    // check is still performed from `layout()` via `_checkPopoverOwner`.
  }

  bool _isPopoverOwnerLost() {
    final dom.DomElement? owner = _container;
    return owner == null || !isConnectedProvider(owner);
  }

  bool _checkPopoverOwner() {
    if (_isVisible() &&
        isPopoverDOMPosition(_domPosition) &&
        _isPopoverOwnerLost()) {
      _hideWithoutRestoringFocus();
      return false;
    }
    return true;
  }

  void _hideWithoutRestoringFocus() {
    _focusToRestore = null;
    hide(null, true);
  }

  void _restorePopoverFocus() {
    final dom.DomElement? focusToRestore = _focusToRestore;
    _focusToRestore = null;
    if (focusToRestore == null || !isConnectedProvider(focusToRestore)) return;
    final dom.DomNode? active =
        getDeepActiveElement(focusToRestore.ownerDocument!);
    if (active != null &&
        (identical(active, focusToRestore.ownerDocument!.body) ||
            dom.isAncestor(active, _view))) {
      focusToRestore.focus();
    }
  }

  void _hidePopover() {
    _toDisposeOnPopoverHide.clear();
    final dom.DomElement popoverElement = _getPopoverElement();
    if (popoverElement.hasAttribute('popover') &&
        popoverOpenProvider(popoverElement)) {
      _hidePopoverApi(popoverElement);
    }
    popoverElement.remove();
  }

  /// 1:1: `layout()`.
  void layout() {
    if (!_isVisible()) return;
    if (_delegate!.canRelayout == false &&
        !(platform.isIOS && canIUse.BrowserFeatures.pointerEvents)) {
      hide();
      return;
    }
    _delegate?.layout();
    _doLayout();
  }

  void _doLayout() {
    if (!_isVisible()) return;
    if (!_checkPopoverOwner()) return;

    final lay.IRect anchor = getAnchorRect(_delegate!.getAnchor());
    final window.CodeWindow containerWindow =
        _container != null ? dom.getWindow(_container) : dom.getActiveWindow();
    final dom.DomWindowCarrier wc = dom.windowCarrier(containerWindow);
    final wco.WindowControlsOverlayViewport viewport =
        wco.WindowControlsOverlayViewport(
      top: wc.scrollY,
      left: wc.scrollX,
      width: wc.innerWidth,
      height: wc.innerHeight,
    );
    _view.classList.toggle('fixed', _useFixedPosition);
    _view.style['top'] = '0px';
    _view.style['left'] = '0px';
    final dom.IDomNodePagePosition positioningOrigin =
        dom.getDomNodePagePosition(_view);
    final num viewZoom = dom.getDomNodeZoomLevel(_view);
    final wco.WindowControlsOverlaySize view = wco.WindowControlsOverlaySize(
      width: dom.getTotalWidth(_view) * viewZoom,
      height: dom.getTotalHeight(_view) * viewZoom,
    );
    final int anchorAlignment =
        _delegate!.anchorAlignment ?? lay.AnchorAlignment.LEFT;
    final int anchorPosition =
        _delegate!.anchorPosition ?? lay.AnchorPosition.BELOW;
    final int anchorAxisAlignment =
        _delegate!.anchorAxisAlignment ?? lay.AnchorAxisAlignment.VERTICAL;
    final lay.ILayout2DResult layoutResult = lay.layout2d(
      lay.IRect(viewport.top, viewport.left, viewport.width, viewport.height),
      lay.ISize(view.width, view.height),
      anchor,
      lay.ILayout2DOptions(
        anchorAlignment: anchorAlignment,
        anchorPosition: anchorPosition,
        anchorAxisAlignment: anchorAxisAlignment,
      ),
    );
    final browser.DOMRect? rect =
        browser.getVisibleWCOTitlebarAreaRect(containerWindow);
    final wco.IWindowControlsOverlayTitlebarRect? titlebarAreaRect =
        rect == null ? null : wco.WindowControlsOverlayTitlebarRect(
            x: rect.x, y: rect.y, width: rect.width, height: rect.height);
    final wco.IWindowControlsOverlayPosition layoutPos =
        wco.WindowControlsOverlayPosition(
            top: layoutResult.top, left: layoutResult.left);
    final wco.IWindowControlsOverlayPosition adjusted =
        wco.avoidWindowControlsOverlay(titlebarAreaRect, viewport, view,
            layoutPos);

    for (final String c in const <String>['top', 'bottom', 'left', 'right']) {
      _view.classList.remove(c);
    }
    if (identical(adjusted, layoutPos)) {
      _view.classList.add(layoutResult.anchorPosition == lay.AnchorPosition.BELOW
          ? 'bottom'
          : 'top');
      _view.classList.add(layoutResult.anchorAlignment == lay.AnchorAlignment.LEFT
          ? 'left'
          : 'right');
    } else {
      _view.classList.add(adjusted.top >= anchor.top + anchor.height
          ? 'bottom'
          : 'top');
      _view.classList.add(adjusted.left >= anchor.left ? 'left' : 'right');
    }

    final wco.IWindowControlsOverlayPosition aligned = alignViewToDevicePixels(
      adjusted,
      view,
      wco.WindowControlsOverlaySize(
          width: positioningOrigin.width, height: positioningOrigin.height),
      anchor,
      viewport,
      wc.devicePixelRatio,
      titlebarAreaRect,
    );
    _view.style['top'] = '${_jsNum((aligned.top - positioningOrigin.top) / viewZoom)}px';
    _view.style['left'] = '${_jsNum((aligned.left - positioningOrigin.left) / viewZoom)}px';
    _view.style['width'] = 'initial';
  }

  /// 1:1: `hide(data?, skipAnimation = false)`.
  void hide([Object? data, bool skipAnimation = false]) {
    if (_hidingContextView != null) {
      if (skipAnimation) completeHideAnimation();
      return;
    }
    final IDelegate? delegate = _delegate;
    _delegate = null;
    if (delegate == null) return;

    final lifecycle.IDisposable toDispose = _toDisposeOnClean;
    _toDisposeOnClean = lifecycle.Disposable.none;
    delegate.onHide(data);

    final bool isPopover = isPopoverDOMPosition(_domPosition);
    if (isPopover) {
      _toDisposeOnPopoverHide.clear();
      final int showCount = _showCount;
      _restorePopoverFocus();
      if (_showCount != showCount) {
        toDispose.dispose();
        return;
      }
    } else {
      _focusToRestore = null;
    }

    final IContextViewCloseAnimation? closeAnimation = delegate.closeAnimation;
    if (!skipAnimation &&
        closeAnimation != null &&
        closeAnimation.duration > 0 &&
        hasRequiredAncestorClasses(
            _view, closeAnimation.requiredAncestorClasses)) {
      _view.style.setProperty(CONTEXT_VIEW_CLOSE_ANIMATION_DURATION_VARIABLE,
          '${closeAnimation.duration}ms');
      _prepareMenuCloseAnimation();
      _inertFlags[_view] = true;
      _view.classList.add(closeAnimation.className);
      final Timer timeout =
          Timer(Duration(milliseconds: closeAnimation.duration), () {
        completeHideAnimation();
      });
      _hidingContextView = _HidingContextView(
        disposable: lifecycle.toDisposable(() => timeout.cancel()),
        toDispose: toDispose,
        className: closeAnimation.className,
      );
      return;
    }

    dom.hide(<dom.DomElement>[_view]);
    if (isPopover) _hidePopover();
    toDispose.dispose();
  }

  bool _isVisible() => _delegate != null;

  /// 1:1: `completeHideAnimation()`.
  void completeHideAnimation() {
    final _HidingContextView? hiding = _hidingContextView;
    if (hiding == null) return;
    _hidingContextView = null;
    hiding.disposable.dispose();
    _view.classList.remove(hiding.className);
    _view.style.remove(CONTEXT_VIEW_CLOSE_ANIMATION_DURATION_VARIABLE);
    _view.style.remove(CONTEXT_VIEW_MENU_MOTION_CLOSE_START_OPACITY_VARIABLE);
    _view.style.remove(CONTEXT_VIEW_MENU_MOTION_CLOSE_START_TRANSFORM_VARIABLE);
    dom.hide(<dom.DomElement>[_view]);
    _inertFlags[_view] = false;
    if (isPopoverDOMPosition(_domPosition)) _hidePopover();
    hiding.toDispose.dispose();
  }

  void _prepareMenuCloseAnimation() {
    if (!_view.classList.contains(CONTEXT_VIEW_MENU_MOTION_CLASS)) return;
    dom.DomElement? surface;
    for (final dom.DomNode child in _view.childNodes) {
      if (child is dom.DomElement &&
          child.classList.contains('monaco-scrollable-element')) {
        surface = child;
        break;
      }
    }
    if (surface == null) return;
    final Map<String, String> computed =
        computedStyleProvider?.call(surface) ?? <String, String>{};
    _view.style.setProperty(CONTEXT_VIEW_MENU_MOTION_CLOSE_START_OPACITY_VARIABLE,
        computed['opacity'] ?? '');
    _view.style.setProperty(
        CONTEXT_VIEW_MENU_MOTION_CLOSE_START_TRANSFORM_VARIABLE,
        computed['transform'] ?? '');
  }

  void _onDOMEvent(Object e, bool onCapture) {
    final IDelegate? delegate = _delegate;
    if (delegate == null) return;
    final Object? target = e is dom.DomEvent
        ? e.target
        : e is mouse.IMouseEvent
            ? e.target
            : e is keyboard.IKeyboardEvent
                ? e.target
                : null;
    final void Function(Object, dom.DomElement)? handler =
        delegate.onDOMEventHandler;
    if (handler != null) {
      handler(e,
          dom.windowCarrier(dom.getWindow(e)).document.activeElement as dom.DomElement);
    } else if (onCapture &&
        !dom.isAncestor(
            target is dom.DomNode ? target : null, _container)) {
      hide();
    }
  }

  @override
  void dispose() {
    hide(null, true);
    completeHideAnimation();
    super.dispose();
  }
}

String _jsNum(num value) {
  if (value is double && value == value.toInt()) return value.toInt().toString();
  return value.toString();
}

const String _shadowRootCss = '''
	:host { all: initial; }
	.codicon[class*='codicon-'] {
		font: normal normal normal 16px/1 codicon; display: inline-block;
		text-decoration: none; text-rendering: auto; text-align: center;
		-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale;
		user-select: none; -webkit-user-select: none; -ms-user-select: none;
	}
	:host { font-family: -apple-system, BlinkMacSystemFont, "Segoe WPC", "Segoe UI", "HelveticaNeue-Light", system-ui, "Ubuntu", "Droid Sans", sans-serif; }
	:host-context(.mac) { font-family: -apple-system, BlinkMacSystemFont, sans-serif; }
	:host-context(.windows) { font-family: "Segoe WPC", "Segoe UI", sans-serif; }
	:host-context(.linux) { font-family: system-ui, "Ubuntu", "Droid Sans", sans-serif; }
''';
