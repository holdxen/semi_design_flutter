// 1:1 port of vscode/src/vs/platform/hover/browser/hoverWidget.ts
//
// Carriers: DOM (`dom.dart`), base `HoverWidget`/`HoverAction`/`HoverPosition`/
// `getHoverAccessibleViewHint` (`base/browser/ui/hover/hoverWidget.dart`),
// `Widget`, `AnchorAlignment`/`AnchorPosition` (`base/common/layout.dart`) and
// the injected services are the existing ports.
//
// Adaptations (documented inline; no algorithm or control-flow change):
//  * `hover.css` side-effect import dropped (styling belongs to the Flutter
//    widget layer).
//  * TS parameter decorators `@IKeybindingService` … become the positional
//    arguments 2..5 in the same order.
//  * `options.appearance ??= {}` → `options.appearance ??= IHoverAppearanceOptions()`.
//  * `typeof options.content === 'string'` → `options.content is String`.
//  * global `ResizeObserver` → the dom carrier `DomResizeObserver`.
//  * `dom.getWindow(el).innerHeight` → `dom.windowCarrier(dom.getWindow(el)).innerHeight`.
//  * `Disposable.None` → `lifecycle.Disposable.none`.
import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/keyboardEvent.dart' as keyboard;
import '../../../base/browser/markdownRenderer.dart' show RenderedMarkdown;
import '../../../base/browser/mouseEvent.dart' as mouse0;
import '../../../base/browser/window.dart' show CodeWindow;
import '../../../base/browser/ui/aria/aria.dart' as aria;
import '../../../base/browser/ui/hover/hover.dart'
    show
        HoverStyle,
        IHoverAction,
        IHoverAppearanceOptions,
        IHoverOptions,
        IHoverTarget,
        IHoverWidget;
import '../../../base/browser/ui/hover/hoverWidget.dart' as baseHover;
import '../../../base/browser/ui/widget.dart' as widget;
import '../../../base/common/async.dart' as async;
import '../../../base/common/event.dart' as event;
import '../../../base/common/htmlContent.dart' as htmlContent;
import '../../../base/common/keybindings.dart' show ResolvedKeybinding;
import '../../../base/common/keyCodes.dart' show KeyCode;
import '../../../base/common/layout.dart'
    show AnchorAlignment, AnchorPosition;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/platform.dart' show isMacintosh;
import '../../../base/common/types.dart' show isNumber;
import '../../../nls.dart' show localize;
import '../../accessibility/common/accessibility.dart' as accessibility;
import '../../configuration/common/configuration.dart' as configuration;
import '../../keybinding/common/keybinding.dart' as keybinding;
import '../../markdown/browser/markdownRenderer.dart' as markdownRenderer;

final dom.DollarFn $ = dom.$;

/// 1:1: `type TargetRect`.
class TargetRect {
  TargetRect({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.width,
    required this.height,
    required this.center,
  });

  num left;
  num right;
  num top;
  num bottom;
  final num width;
  final num height;
  final TargetRectCenter center;
}

/// TS inline `center: { x: number; y: number }` shape.
class TargetRectCenter {
  TargetRectCenter({required this.x, required this.y});

  num x;
  num y;
}

/// 1:1: `const enum Constants`.
class Constants {
  static const int PointerSize = 3;
  static const int HoverBorderWidth = 2;
  static const int HoverWindowEdgeMargin = 2;

  const Constants._();
}

/// 1:1: `export class HoverWidget extends Widget implements IHoverWidget`.
class HoverWidget extends widget.Widget implements IHoverWidget {
  final lifecycle.DisposableStore _messageListeners =
      lifecycle.DisposableStore();
  late final CompositeMouseTracker _lockMouseTracker;

  late final baseHover.HoverWidget _hover;
  late final dom.DomElement? _hoverPointer;
  late final dom.DomElement _hoverContainer;
  late final IHoverTarget _target;
  final dom.DomElement? _clippingElement;
  final int _anchorAlignment;
  final void Function(String url)? _linkHandler;

  bool _isDisposed = false;

  /// The side the hover is currently laid out on, after falling back if it did
  /// not fit.
  late int _hoverPosition;

  /// The side the hover was asked to show on. Each layout starts from it
  /// again, so a hover that had to fall back (e.g. while its image was
  /// loading) can return once it fits.
  late final int _requestedHoverPosition;
  bool _forcePosition = false;
  num _x = 0;
  num _y = 0;
  bool _isLocked = false;
  bool _enableFocusTraps = false;
  bool _addedFocusTrap = false;
  num _maxHeightRatioRelativeToWindow = 0.5;
  CompositeMouseTracker? _mouseTracker;

  CodeWindow get _targetWindow => dom.getWindow(_target.targetElements[0]);
  dom.DomElement get _targetDocumentElement =>
      dom.windowCarrier(dom.getWindow(_target.targetElements[0]))
          .document
          .documentElement;

  @override
  bool get isDisposed => _isDisposed;
  bool get isMouseIn => _lockMouseTracker.isMouseIn;
  dom.DomElement get domNode => _hover.containerDomNode;

  /// Port-only accessor: the base hover's contents node. The source never
  /// exposes it, but layout results (`maxHeight` / padding) live on it, so the
  /// port keeps it observable for renderers and tests.
  dom.DomElement get contentsDomNode => _hover.contentsDomNode;

  late final event.Emitter<void> _onDispose = register(event.Emitter<void>());
  event.Event<void> get onDispose => _onDispose.event;
  late final event.Emitter<void> _onRequestLayout =
      register(event.Emitter<void>());
  event.Event<void> get onRequestLayout => _onRequestLayout.event;

  int get anchor => _hoverPosition == baseHover.HoverPosition.BELOW
      ? AnchorPosition.BELOW
      : AnchorPosition.ABOVE;
  num get x => _x;
  num get y => _y;

  /// Whether the hover is "locked" by holding the alt/option key. When locked,
  /// the hover will not hide and can be hovered regardless of whether the
  /// `hideOnHover` hover option is set.
  bool get isLocked => _isLocked;
  set isLocked(bool value) {
    if (_isLocked == value) {
      return;
    }
    _isLocked = value;
    _hoverContainer.classList.toggle('locked', _isLocked);
  }

  /// Adds an element to be tracked by this hover's mouse tracker. Mouse events
  /// on this element will be considered as being "inside" the hover,
  /// preventing it from closing. This is used for nested hovers where the
  /// child hover's container should be treated as part of the parent hover.
  lifecycle.IDisposable addMouseTrackingElement(dom.DomElement element) {
    return _lockMouseTracker.addElement(element);
  }

  HoverWidget(
    IHoverOptions options,
    keybinding.IKeybindingServiceType? keybindingService,
    configuration.IConfigurationServiceType? configurationService,
    markdownRenderer.IMarkdownRendererServiceType? markdownRendererService,
    accessibility.IAccessibilityServiceType? accessibilityService,
  ) : _clippingElement = options.position?.clippingElement,
      _anchorAlignment =
          options.position?.anchorAlignment ?? AnchorAlignment.LEFT,
      _linkHandler = options.linkHandler,
      _target = options.target is IHoverTarget
          ? options.target as IHoverTarget
          : ElementHoverTarget(options.target as dom.DomElement),
      // TS injects the services with `@I…`; Dart supplies them positionally.
      _keybindingService = keybindingService!,
      _configurationService = configurationService!,
      _markdownRenderer = markdownRendererService!,
      _accessibilityService = accessibilityService!,
      super() {
    if (options.style != null) {
      switch (options.style) {
        case HoverStyle.Pointer:
          options.appearance ??= IHoverAppearanceOptions();
          options.appearance!.compact ??= true;
          options.appearance!.showPointer ??= true;
          break;
        case HoverStyle.Mouse:
          options.appearance ??= IHoverAppearanceOptions();
          options.appearance!.compact ??= true;
          break;
      }
    }

    final dom.DomElement? hoverPointer = options.appearance?.showPointer == true
        ? $('div.workbench-hover-pointer')
        : null;
    _hoverPointer = hoverPointer;
    _hover = register(baseHover.HoverWidget(
        options.appearance?.skipFadeInAnimation != true));
    _hover.containerDomNode.classList.add('workbench-hover');
    if (options.appearance?.compact == true) {
      _hover.containerDomNode.classList.add('workbench-hover');
      _hover.containerDomNode.classList.add('compact');
    }
    if (hoverPointer != null) {
      _hover.containerDomNode.classList.add('with-pointer');
    }
    if (options.additionalClasses != null) {
      // TS spreads `...options.additionalClasses`; the carrier adds per token.
      for (final String additionalClass in options.additionalClasses!) {
        _hover.containerDomNode.classList.add(additionalClass);
      }
    }
    if (options.position?.forcePosition == true) {
      _forcePosition = true;
    }
    if (options.trapFocus == true) {
      _enableFocusTraps = true;
    }

    final num? maxHeightRatio = options.appearance?.maxHeightRatio;
    if (maxHeightRatio != null && maxHeightRatio > 0 && maxHeightRatio <= 1) {
      _maxHeightRatioRelativeToWindow = maxHeightRatio;
    }

    // Default to position above when the position is unspecified or a mouse
    // event
    final Object? requestedPosition = options.position?.hoverPosition;
    _hoverPosition = requestedPosition == null
        ? baseHover.HoverPosition.ABOVE
        : isNumber(requestedPosition)
            ? (requestedPosition as num).toInt()
            : baseHover.HoverPosition.BELOW;
    _requestedHoverPosition = _hoverPosition;

    // Don't allow mousedown out of the widget, otherwise preventDefault will
    // call and text will not be selected.
    onmousedown(
        _hover.containerDomNode, (mouse0.IMouseEvent e) => e.stopPropagation());

    // Hide hover on escape
    onkeydown(_hover.containerDomNode, (keyboard.IKeyboardEvent e) {
      if (e.equals(KeyCode.Escape)) {
        dispose();
      }
    });

    // Hide when the window loses focus
    register(dom.addDisposableTargetListener(
        _targetWindow, 'blur', (dom.DomEvent e) => dispose()));

    final dom.DomElement rowElement = $('div.hover-row.markdown-hover');
    final dom.DomElement contentsElement = $('div.hover-contents');
    if (options.content is String) {
      contentsElement.textContent = options.content as String;
      contentsElement.style['whiteSpace'] = 'pre-wrap';
    } else if (dom.isHTMLElement(options.content)) {
      contentsElement.appendChild(options.content as dom.DomNode);
      contentsElement.classList.add('html-hover-contents');

      // Watch for size changes from dynamic HTML content (e.g. collapsible
      // regions).
      final dom.DomResizeObserver resizeObserver =
          dom.DomResizeObserver((List<dom.DomResizeObserverEntry> entries,
              dom.DomResizeObserver observer) {
        layout();
        _onRequestLayout.fire(null);
      });
      resizeObserver.observe(contentsElement);
      register(lifecycle.toDisposable(() => resizeObserver.disconnect()));
    } else {
      final Object markdown = options.content;

      final RenderedMarkdown rendered =
          register(_markdownRenderer.render(
        markdown,
        markdownRenderer.MarkdownRendererRenderOptions(
          // TS passes `linkHandler` (a `(url: string) => void`) where the
          // renderer expects `(linkContent, mdStr)`; the port adapts the arity
          // and keeps `undefined` when no link handler was supplied.
          actionHandler: _linkHandler == null
              ? null
              : (String linkContent, Object mdStr) => _linkHandler.call(linkContent),
          asyncRenderCallback: () {
            contentsElement.classList.add('code-hover-contents');
            layout();
            // This changes the dimensions of the hover so trigger a layout
            _onRequestLayout.fire(null);
          },
        ),
      ));
      contentsElement.appendChild(rendered.element as dom.DomNode);
    }
    rowElement.appendChild(contentsElement);
    _hover.contentsDomNode.appendChild(rowElement);

    final List<IHoverAction>? actions = options.actions;
    if (actions != null && actions.isNotEmpty) {
      final dom.DomElement statusBarElement = $('div.hover-row.status-bar');
      final dom.DomElement actionsElement = $('div.actions');
      for (final IHoverAction action in actions) {
        final ResolvedKeybinding? kb =
            _keybindingService.lookupKeybinding(action.commandId);
        final String? keybindingLabel = kb != null ? kb.getLabel() : null;
        register(baseHover.HoverAction.render(
          actionsElement,
          baseHover.HoverActionOptions(
            label: action.label,
            commandId: action.commandId,
            run: (dom.DomElement target) {
              action.run(target);
              dispose();
            },
            iconClass: action.iconClass,
          ),
          keybindingLabel,
        ));
      }
      statusBarElement.appendChild(actionsElement);
      _hover.containerDomNode.appendChild(statusBarElement);
    }

    _hoverContainer = $('div.workbench-hover-container');
    if (hoverPointer != null) {
      _hoverContainer.appendChild(hoverPointer);
    }
    _hoverContainer.appendChild(_hover.containerDomNode);

    // Determine whether to hide on hover
    bool hideOnHover;
    if (actions != null && actions.isNotEmpty) {
      // If there are actions, require hover so they can be accessed
      hideOnHover = false;
    } else {
      if (options.persistence?.hideOnHover == null) {
        // When unset, will default to true when it's a string or when it's
        // markdown that appears to have a link using a naive check for ']('
        // and '</a>'
        final Object content = options.content;
        if (content is String) {
          hideOnHover = true;
        } else if (htmlContent.isMarkdownString(content)) {
          final String value = (content as htmlContent.MarkdownString).value;
          hideOnHover = !value.contains('](') && !value.contains('</a>');
        } else {
          hideOnHover = false;
        }
      } else {
        // It's set explicitly
        hideOnHover = options.persistence!.hideOnHover!;
      }
    }

    // Show the hover hint if needed
    if (options.appearance?.showHoverHint == true) {
      final dom.DomElement statusBarElement = $('div.hover-row.status-bar');
      final dom.DomElement infoElement = $('div.info');
      infoElement.textContent = localize(
          'hoverhint', 'Hold {0} key to mouse over',
          <Object?>[isMacintosh ? 'Option' : 'Alt']);
      statusBarElement.appendChild(infoElement);
      _hover.containerDomNode.appendChild(statusBarElement);
    }

    final List<dom.DomElement> mouseTrackerTargets =
        List<dom.DomElement>.from(_target.targetElements);
    if (!hideOnHover) {
      mouseTrackerTargets.add(_hoverContainer);
    }
    final CompositeMouseTracker mouseTracker =
        _mouseTracker = register(CompositeMouseTracker(mouseTrackerTargets));
    register(mouseTracker.onMouseOut((dynamic _) {
      if (!_isLocked) {
        dispose();
      }
    }));

    // Setup another mouse tracker when hideOnHover is set in order to track the
    // hover as well when it is locked. This ensures the hover will hide on
    // mouseout after alt has been released to unlock the element.
    if (hideOnHover) {
      final List<dom.DomElement> mouseTracker2Targets =
          <dom.DomElement>[..._target.targetElements, _hoverContainer];
      _lockMouseTracker =
          register(CompositeMouseTracker(mouseTracker2Targets));
      register(_lockMouseTracker.onMouseOut((dynamic _) {
        if (!_isLocked) {
          dispose();
        }
      }));
    } else {
      _lockMouseTracker = mouseTracker;
    }
  }

  late final keybinding.IKeybindingServiceType _keybindingService;
  late final configuration.IConfigurationServiceType _configurationService;
  late final markdownRenderer.IMarkdownRendererServiceType _markdownRenderer;
  late final accessibility.IAccessibilityServiceType _accessibilityService;

  void _addFocusTrap() {
    if (!_enableFocusTraps || _addedFocusTrap) {
      return;
    }
    _addedFocusTrap = true;

    // Add a hover tab loop if the hover has at least one element with a valid
    // tabIndex
    final dom.DomElement firstContainerFocusElement = _hover.containerDomNode;
    final dom.DomElement? lastContainerFocusElement =
        _findLastFocusableChild(_hover.containerDomNode);
    if (lastContainerFocusElement != null) {
      final dom.DomElement beforeContainerFocusElement =
          dom.prepend(_hoverContainer, $('div'));
      final dom.DomElement afterContainerFocusElement =
          dom.append(_hoverContainer, <Object>[$('div')]) as dom.DomElement;
      beforeContainerFocusElement.tabIndex = 0;
      afterContainerFocusElement.tabIndex = 0;
      register(dom.addDisposableListener(
          afterContainerFocusElement, 'focus', (dom.DomEvent e) {
        firstContainerFocusElement.focus();
        e.preventDefault();
      }));
      register(dom.addDisposableListener(
          beforeContainerFocusElement, 'focus', (dom.DomEvent e) {
        lastContainerFocusElement.focus();
        e.preventDefault();
      }));
    }
  }

  dom.DomElement? _findLastFocusableChild(dom.DomNode root) {
    // TS `root.hasChildNodes()`; the carrier exposes the node list.
    if (root.childNodes.isNotEmpty) {
      for (int i = 0; i < root.childNodes.length; i++) {
        final dom.DomNode node =
            root.childNodes[root.childNodes.length - i - 1];
        if (node.nodeType == dom.DomNode.ELEMENT_NODE) {
          final dom.DomElement parsedNode = node as dom.DomElement;
          if (parsedNode.tabIndex >= 0) {
            return parsedNode;
          }
        }
        final dom.DomElement? recursivelyFoundElement =
            _findLastFocusableChild(node);
        if (recursivelyFoundElement != null) {
          return recursivelyFoundElement;
        }
      }
    }
    return null;
  }

  void render(dom.DomElement container) {
    _mouseTracker?.enableMouseOutSuppression();
    _lockMouseTracker.enableMouseOutSuppression();
    container.appendChild(_hoverContainer);
    final bool hoverFocused = _hoverContainer.contains(
        _hoverContainer.ownerDocument?.activeElement);
    final String accessibleViewHint = baseHover.getHoverAccessibleViewHint(
      hoverFocused &&
          _configurationService.getValue$1('accessibility.verbosity.hover') ==
              true &&
          _accessibilityService.isScreenReaderOptimized(),
      _keybindingService
          .lookupKeybinding('editor.action.accessibleView')
          ?.getAriaLabel(),
    );
    if (accessibleViewHint.isNotEmpty) {
      aria.status(accessibleViewHint);
    }
    layout();
    _addFocusTrap();
  }

  void layout() {
    // Cancel any pending mouseout timers since the hover is being repositioned
    // (e.g. due to content resize from collapsible sections). The mouse may
    // end up back inside the hover after the layout.
    _mouseTracker?.suppressPendingMouseOut();
    if (!identical(_lockMouseTracker, _mouseTracker)) {
      _lockMouseTracker.suppressPendingMouseOut();
    }

    // Re-evaluate the fallback from the requested position on every layout,
    // since the content size may have changed (e.g. an image finished loading)
    _hoverPosition = _requestedHoverPosition;
    _hover.containerDomNode.classList.remove('right-aligned');
    // Measure the full content when choosing the side, not the maximum height
    // of a previous layout
    _hover.containerDomNode.style['maxHeight'] = '';
    _hover.contentsDomNode.style['maxHeight'] = '';
    _hover.containerDomNode.style['maxWidth'] = '';

    final List<dom.DomRect> targetBounds = _target.targetElements
        .map((dom.DomElement e) => e.getBoundingClientRect())
        .toList();
    num top = targetBounds[0].top;
    num right = targetBounds[0].right;
    num bottom = targetBounds[0].bottom;
    num left = targetBounds[0].left;
    if (_clippingElement != null) {
      final dom.DomRect clip = _clippingElement.getBoundingClientRect();
      final _VisibleRect visible = _VisibleRect(
        top: num.parse(_max(top, clip.top).toString()),
        right: num.parse(_min(right, clip.right).toString()),
        bottom: num.parse(_min(bottom, clip.bottom).toString()),
        left: num.parse(_max(left, clip.left).toString()),
      );
      // Keep the whole target when none of it is visible
      if (visible.left <= visible.right && visible.top <= visible.bottom) {
        top = visible.top;
        right = visible.right;
        bottom = visible.bottom;
        left = visible.left;
      }
    }
    final num width = right - left;
    final num height = bottom - top;

    final TargetRect targetRect = TargetRect(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      width: width,
      height: height,
      center: TargetRectCenter(x: left + (width / 2), y: top + (height / 2)),
    );

    // These calls adjust the position depending on spacing.
    _adjustHorizontalHoverPosition(targetRect);
    _adjustVerticalHoverPosition(targetRect);
    // This call limits the maximum height of the hover.
    _adjustHoverMaxHeight(targetRect);

    // Offset the hover position if there is a pointer so it aligns with the
    // target element
    _hoverContainer.style['padding'] = '';
    _hoverContainer.style['margin'] = '';
    if (_hoverPointer != null) {
      switch (_hoverPosition) {
        case baseHover.HoverPosition.RIGHT:
          targetRect.left = targetRect.left + Constants.PointerSize;
          targetRect.right = targetRect.right + Constants.PointerSize;
          _hoverContainer.style['paddingLeft'] = '${Constants.PointerSize}px';
          _hoverContainer.style['marginLeft'] = '${-Constants.PointerSize}px';
          break;
        case baseHover.HoverPosition.LEFT:
          targetRect.left = targetRect.left - Constants.PointerSize;
          targetRect.right = targetRect.right - Constants.PointerSize;
          _hoverContainer.style['paddingRight'] = '${Constants.PointerSize}px';
          _hoverContainer.style['marginRight'] = '${-Constants.PointerSize}px';
          break;
        case baseHover.HoverPosition.BELOW:
          targetRect.top = targetRect.top + Constants.PointerSize;
          targetRect.bottom = targetRect.bottom + Constants.PointerSize;
          _hoverContainer.style['paddingTop'] = '${Constants.PointerSize}px';
          _hoverContainer.style['marginTop'] = '${-Constants.PointerSize}px';
          break;
        case baseHover.HoverPosition.ABOVE:
          targetRect.top = targetRect.top - Constants.PointerSize;
          targetRect.bottom = targetRect.bottom - Constants.PointerSize;
          _hoverContainer.style['paddingBottom'] = '${Constants.PointerSize}px';
          _hoverContainer.style['marginBottom'] = '${-Constants.PointerSize}px';
          break;
      }

      targetRect.center.x = targetRect.left + (width / 2);
      targetRect.center.y = targetRect.top + (height / 2);
    }

    _computeXCordinate(targetRect);
    _computeYCordinate(targetRect);

    if (_hoverPointer != null) {
      final dom.DomElement hoverPointer = _hoverPointer;
      // reset
      hoverPointer.classList.remove('top');
      hoverPointer.classList.remove('left');
      hoverPointer.classList.remove('right');
      hoverPointer.classList.remove('bottom');
      // The offset along the previous axis would override the new side's CSS
      // position
      hoverPointer.style['top'] = '';
      hoverPointer.style['left'] = '';

      _setHoverPointerPosition(targetRect);
    }
    _hover.onContentsChanged();
  }

  void _computeXCordinate(TargetRect target) {
    final num hoverWidth =
        _hover.containerDomNode.clientWidth + Constants.HoverBorderWidth;
    final int documentElementClientLeft =
        _targetDocumentElement.clientLeft;

    if (_target.x != null) {
      _x = _target.x!;
    } else if (_hoverPosition == baseHover.HoverPosition.RIGHT) {
      _x = target.right;
    } else if (_hoverPosition == baseHover.HoverPosition.LEFT) {
      _x = target.left - hoverWidth;
    } else {
      if (_anchorAlignment == AnchorAlignment.RIGHT) {
        _x = target.right - hoverWidth;
      } else if (_hoverPointer != null) {
        _x = target.center.x -
            (_hover.containerDomNode.clientWidth / 2);
      } else {
        _x = target.left;
      }

      // Hover is going beyond window towards right end
      final int documentElementClientWidth =
          _targetDocumentElement.clientWidth;
      if (_x + hoverWidth >= documentElementClientWidth) {
        _hover.containerDomNode.classList.add('right-aligned');
        _x = _max(
            documentElementClientWidth -
                hoverWidth -
                Constants.HoverWindowEdgeMargin,
            documentElementClientLeft);
      }
    }

    // Hover is going beyond window towards left end
    if (_x < documentElementClientLeft) {
      _x = target.left + Constants.HoverWindowEdgeMargin;
    }
  }

  void _computeYCordinate(TargetRect target) {
    if (_target.y != null) {
      _y = _target.y!;
    } else if (_hoverPosition == baseHover.HoverPosition.ABOVE) {
      _y = target.top;
    } else if (_hoverPosition == baseHover.HoverPosition.BELOW) {
      _y = target.bottom - 2;
    } else {
      if (_hoverPointer != null) {
        _y = target.center.y +
            (_hover.containerDomNode.clientHeight / 2);
      } else {
        _y = target.bottom;
      }

      // Keep side hovers within the window so the context view does not need
      // to move them away from the position the pointer was computed for
      if (!_forcePosition) {
        final num hoverHeight =
            _hover.containerDomNode.clientHeight + Constants.HoverBorderWidth;
        final num targetWindowInnerHeight =
            dom.windowCarrier(_targetWindow).innerHeight;
        _y = _max(
            _min(_y, targetWindowInnerHeight - Constants.HoverWindowEdgeMargin),
            hoverHeight + Constants.HoverWindowEdgeMargin);
      }
    }

    // Hover on bottom is going beyond window
    if (_y > dom.windowCarrier(_targetWindow).innerHeight) {
      _y = target.bottom;
    }
  }

  void _adjustHorizontalHoverPosition(TargetRect target) {
    // Do not adjust horizontal hover position if x cordiante is provided
    if (_target.x != null) {
      return;
    }

    if (_anchorAlignment == AnchorAlignment.RIGHT &&
        (_hoverPosition == baseHover.HoverPosition.ABOVE ||
            _hoverPosition == baseHover.HoverPosition.BELOW)) {
      final num availableWidth = target.right -
          _targetDocumentElement.clientLeft -
          Constants.HoverWindowEdgeMargin -
          Constants.HoverBorderWidth;
      if (_hover.containerDomNode.clientWidth > availableWidth) {
        _hover.containerDomNode.style['maxWidth'] =
            '${_css(_max(availableWidth, 0))}px';
      }
      return;
    }

    final num hoverPointerOffset =
        (_hoverPointer != null ? Constants.PointerSize : 0);

    // When force position is enabled, restrict max width
    if (_forcePosition) {
      final num padding = hoverPointerOffset + Constants.HoverBorderWidth;
      if (_hoverPosition == baseHover.HoverPosition.RIGHT) {
        _hover.containerDomNode.style['maxWidth'] =
            '${_css(_targetDocumentElement.clientWidth - target.right - padding)}px';
      } else if (_hoverPosition == baseHover.HoverPosition.LEFT) {
        _hover.containerDomNode.style['maxWidth'] = '${_css(target.left - padding)}px';
      }
      return;
    }

    // Position hover on right to target
    if (_hoverPosition == baseHover.HoverPosition.RIGHT) {
      final num roomOnRight = _targetDocumentElement.clientWidth - target.right;
      // Hover on the right is going beyond window.
      if (roomOnRight <
          _hover.containerDomNode.clientWidth + hoverPointerOffset) {
        final num roomOnLeft = target.left;
        // There's enough room on the left, flip the hover position
        if (roomOnLeft >=
            _hover.containerDomNode.clientWidth + hoverPointerOffset) {
          _hoverPosition = baseHover.HoverPosition.LEFT;
        }
        // Hover on the left would go beyond window too
        else {
          _hoverPosition = baseHover.HoverPosition.BELOW;
        }
      }
    }
    // Position hover on left to target
    else if (_hoverPosition == baseHover.HoverPosition.LEFT) {
      final num roomOnLeft = target.left;
      // Hover on the left is going beyond window.
      if (roomOnLeft <
          _hover.containerDomNode.clientWidth + hoverPointerOffset) {
        final num roomOnRight =
            _targetDocumentElement.clientWidth - target.right;
        // There's enough room on the right, flip the hover position
        if (roomOnRight >=
            _hover.containerDomNode.clientWidth + hoverPointerOffset) {
          _hoverPosition = baseHover.HoverPosition.RIGHT;
        }
        // Hover on the right would go beyond window too
        else {
          _hoverPosition = baseHover.HoverPosition.BELOW;
        }
      }
      // Hover on the left is going beyond window. Only applies while the hover
      // is still on the left, so the BELOW fallback chosen above is not
      // overridden
      if (_hoverPosition == baseHover.HoverPosition.LEFT &&
          target.left -
                  _hover.containerDomNode.clientWidth -
                  hoverPointerOffset <=
              _targetDocumentElement.clientLeft) {
        _hoverPosition = baseHover.HoverPosition.RIGHT;
      }
    }
  }

  void _adjustVerticalHoverPosition(TargetRect target) {
    // Do not adjust vertical hover position if the y coordinate is provided
    // or the position is forced
    if (_target.y != null || _forcePosition) {
      return;
    }

    final num hoverPointerOffset =
        (_hoverPointer != null ? Constants.PointerSize : 0);
    // Compare against the height the hover will have once its maximum height is
    // applied
    final num maxHeight = dom.windowCarrier(_targetWindow).innerHeight *
        _maxHeightRatioRelativeToWindow;

    // Position hover on top of the target
    if (_hoverPosition == baseHover.HoverPosition.ABOVE) {
      // Hover on top is going beyond window
      if (target.top -
                  _min(_hover.containerDomNode.clientHeight, maxHeight) -
                  hoverPointerOffset <
              0) {
        _hoverPosition = baseHover.HoverPosition.BELOW;
      }
    }
    // Position hover below the target
    else if (_hoverPosition == baseHover.HoverPosition.BELOW) {
      // Hover on bottom is going beyond window
      if (target.bottom +
                  _min(_hover.containerDomNode.offsetHeight, maxHeight) +
                  hoverPointerOffset >
              dom.windowCarrier(_targetWindow).innerHeight) {
        _hoverPosition = baseHover.HoverPosition.ABOVE;
      }
    }
  }

  void _adjustHoverMaxHeight(TargetRect target) {
    num maxHeight = dom.windowCarrier(_targetWindow).innerHeight *
        _maxHeightRatioRelativeToWindow;

    // When force position is enabled, restrict max height
    if (_forcePosition) {
      final num padding =
          (_hoverPointer != null ? Constants.PointerSize : 0) +
              Constants.HoverBorderWidth;
      if (_hoverPosition == baseHover.HoverPosition.ABOVE) {
        maxHeight = _min(maxHeight, target.top - padding);
      } else if (_hoverPosition == baseHover.HoverPosition.BELOW) {
        maxHeight = _min(maxHeight,
            dom.windowCarrier(_targetWindow).innerHeight - target.bottom - padding);
      }
    }

    _hover.containerDomNode.style['maxHeight'] = '';
    final num heightOutsideContents =
        _hover.containerDomNode.offsetHeight -
            _hover.contentsDomNode.offsetHeight;
    final num contentsMaxHeight = _max(0, maxHeight - heightOutsideContents);

    _hover.containerDomNode.style['maxHeight'] = '${_css(maxHeight)}px';
    _hover.contentsDomNode.style['maxHeight'] = '${_css(contentsMaxHeight)}px';
    if (_hover.contentsDomNode.clientHeight <
        _hover.contentsDomNode.scrollHeight) {
      // Add padding for a vertical scrollbar
      final String extraRightPadding =
          '${_hover.scrollbar.options.verticalScrollbarSize}px';
      if (_hover.contentsDomNode.style['paddingRight'] != extraRightPadding) {
        _hover.contentsDomNode.style['paddingRight'] = extraRightPadding;
      }
    }
  }

  void _setHoverPointerPosition(TargetRect target) {
    if (_hoverPointer == null) {
      return;
    }
    final dom.DomElement hoverPointer = _hoverPointer;

    switch (_hoverPosition) {
      case baseHover.HoverPosition.LEFT:
      case baseHover.HoverPosition.RIGHT:
        hoverPointer.classList.add(
            _hoverPosition == baseHover.HoverPosition.LEFT ? 'right' : 'left');
        final num hoverHeight = _hover.containerDomNode.clientHeight;

        // If hover is taller than target, then show the pointer at the center
        // of target
        if (hoverHeight > target.height) {
          hoverPointer.style['top'] =
              '${_css(target.center.y - (_y - hoverHeight) - Constants.PointerSize)}px';
        }
        // Otherwise show the pointer at the center of hover, unrounded so it
        // stays centred
        else {
          hoverPointer.style['top'] =
              '${_css((hoverHeight / 2) - Constants.PointerSize)}px';
        }
        break;
      case baseHover.HoverPosition.ABOVE:
      case baseHover.HoverPosition.BELOW:
        hoverPointer.classList
            .add(_hoverPosition == baseHover.HoverPosition.ABOVE
                ? 'bottom'
                : 'top');
        final num hoverWidth = _hover.containerDomNode.clientWidth;

        // Position pointer at the center of the hover, unrounded so it stays
        // centred
        num pointerLeftPosition = (hoverWidth / 2) - Constants.PointerSize;

        // If pointer goes beyond target then position it at the center of the
        // target
        final num pointerX = _x + pointerLeftPosition;
        if (pointerX < target.left || pointerX > target.right) {
          pointerLeftPosition =
              target.center.x - _x - Constants.PointerSize;
        }

        hoverPointer.style['left'] = '${_css(pointerLeftPosition)}px';
        break;
    }
  }

  void focus() {
    _hover.containerDomNode.focus();
  }

  void hide() {
    dispose();
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _onDispose.fire(null);
      final IHoverTarget target = _target;
      if (target is _DisposableHoverTarget) {
        target.dispose();
      }
      _hoverContainer.remove();
      _messageListeners.dispose();
      super.dispose();
    }
    _isDisposed = true;
  }
}

/// `IHoverTarget.dispose?()` — TS calls it through optional chaining, so the
/// carrier exposes an optional-dispose marker.
abstract class _DisposableHoverTarget implements IHoverTarget {
  void dispose();
}

class _VisibleRect {
  _VisibleRect({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  final num top;
  final num right;
  final num bottom;
  final num left;
}

/// JS number → CSS string: integers have no fractional part in JS
/// (`${400}` is `'400'`), Dart would render `'400.0'`.
String _css(num value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

num _max(num a, num b) => a > b ? a : b;
num _min(num a, num b) => a < b ? a : b;

/// 1:1: `class CompositeMouseTracker extends Widget`.
class CompositeMouseTracker extends widget.Widget {
  bool _isMouseIn = true;
  bool _canSuppressMouseOut = false;
  bool _isPendingMouseOutSuppressible = false;
  bool _suppressNextMouseOut = false;

  late final lifecycle.MutableDisposable<async.TimeoutTimer> _mouseTimer =
      register(lifecycle.MutableDisposable<async.TimeoutTimer>());

  late final event.Emitter<void> _onMouseOut = register(event.Emitter<void>());
  event.Event<void> get onMouseOut => _onMouseOut.event;

  bool get isMouseIn => _isMouseIn;

  /// @param _elements The target elements to track mouse in/out events on.
  /// @param _eventDebounceDelay The delay in ms to debounce the event firing.
  /// This is used to allow a short period for the mouse to move into the hover
  /// or a nearby target element. For example hovering a scroll bar will not
  /// hide the hover immediately.
  CompositeMouseTracker(this._elements, [this._eventDebounceDelay = 200]) {
    for (final dom.DomElement element in _elements) {
      onmouseover(
          element, (mouse0.IMouseEvent e) => _onTargetMouseOver());
      onmouseleave(
          element, (mouse0.IMouseEvent e) => _onTargetMouseLeave());
    }
  }

  final List<dom.DomElement> _elements;
  final int _eventDebounceDelay;

  void _onTargetMouseOver() {
    _isMouseIn = true;
    _suppressNextMouseOut = false;
    _mouseTimer.clear();
  }

  void _onTargetMouseLeave() {
    _isMouseIn = false;
    _isPendingMouseOutSuppressible = _canSuppressMouseOut;
    // Evaluate whether the mouse is still outside asynchronously such that
    // other mouse targets have the opportunity to first their mouse in event.
    _mouseTimer.value =
        async.TimeoutTimer(() => _fireIfMouseOutside(), _eventDebounceDelay);
  }

  void _fireIfMouseOutside() {
    if (!_isMouseIn && !_suppressNextMouseOut) {
      _onMouseOut.fire(null);
    }
  }

  /// Allows [suppressPendingMouseOut] to suppress mouseouts that start after
  /// this call. Call this when the tracked elements are shown: a mouseout that
  /// started before cannot be caused by them being resized or repositioned,
  /// for example when the mouse left the target while a delayed hover was
  /// pending.
  void enableMouseOutSuppression() {
    _canSuppressMouseOut = true;
  }

  /// Suppresses the next pending mouseout dismissal. Call this when tracked
  /// elements are being resized or repositioned to avoid spurious dismissals
  /// caused by the element shrinking away from the cursor. The suppression is
  /// cleared when the mouse next enters a tracked element.
  void suppressPendingMouseOut() {
    if (!_isMouseIn && _isPendingMouseOutSuppressible) {
      _suppressNextMouseOut = true;
    }
  }

  /// Adds an element to be tracked by this mouse tracker. Mouse events on this
  /// element will be considered as being "inside" the tracked area.
  lifecycle.IDisposable addElement(dom.DomElement element) {
    if (_elements.contains(element)) {
      return lifecycle.Disposable.none;
    }
    _elements.add(element);
    final lifecycle.DisposableStore store = lifecycle.DisposableStore();
    store.add(dom.addDisposableListener(
        element, dom.EventType.MOUSE_OVER, (dom.DomEvent e) => _onTargetMouseOver()));
    store.add(dom.addDisposableListener(
        element, dom.EventType.MOUSE_LEAVE, (dom.DomEvent e) => _onTargetMouseLeave()));
    store.add(lifecycle.toDisposable(() {
      final int index = _elements.indexOf(element);
      if (index >= 0) {
        _elements.removeAt(index);
      }
    }));
    return store;
  }
}

/// 1:1: `class ElementHoverTarget implements IHoverTarget`.
class ElementHoverTarget implements _DisposableHoverTarget {
  ElementHoverTarget(this._element) {
    targetElements = <dom.DomElement>[_element];
  }

  final dom.DomElement _element;

  @override
  late final List<dom.DomElement> targetElements;

  @override
  num? get x => null;

  @override
  num? get y => null;

  void dispose() {}
}