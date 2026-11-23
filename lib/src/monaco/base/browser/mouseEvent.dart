// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/mouseEvent.ts
// Translated 1:1 from TypeScript. DOM `MouseEvent`/`WheelEvent`/`Window`/
// `Node`/`DataTransfer` are opaque carriers. `navigator.userAgent` is read
// through an injectable provider (defaults to browser.userAgentProvider).
// ---------------------------------------------------------------------------

import 'browser.dart' as browser;
import 'iframe.dart' show IframeUtils, IframeWindow;
import '../common/platform.dart' as platform;

/// 1:1: injectable `navigator.userAgent` for the Chrome-version DPR check.
String Function() userAgentProvider = () => browser.userAgentProvider();

/// Injectable browser flag overrides (defaults read browser.dart flags).
bool Function()? isFirefoxOverride;
bool Function()? isChromeOverride;
bool Function()? isSafariOverride;

bool _isFirefox() => isFirefoxOverride?.call() ?? browser.isFirefox;
bool _isChrome() => isChromeOverride?.call() ?? browser.isChrome;
bool _isSafari() => isSafariOverride?.call() ?? browser.isSafari;
bool Function()? isMacintoshOverride;
bool Function()? isWindowsOverride;
bool _isMacintosh() => isMacintoshOverride?.call() ?? platform.isMacintosh;
bool _isWindows() => isWindowsOverride?.call() ?? platform.isWindows;

/// 1:1: `MouseEvent` carrier — every DOM field used by the ported code.
/// The three Gecko-axis fields and [devicePixelRatio] stand in for the
/// vendor-specific `IWebKitMouseWheelEvent`/`IGeckoMouseWheelEvent` views and
/// `e.view?.devicePixelRatio`; they are `null`/`0` when absent, mirroring
/// `undefined`/falsy in the source.
class MouseEvent {
  MouseEvent({
    this.button = 0,
    this.buttons = 0,
    this.detail = 0,
    this.type = '',
    this.target,
    this.view,
    this.ctrlKey = false,
    this.shiftKey = false,
    this.altKey = false,
    this.metaKey = false,
    this.defaultPrevented = false,
    this.pageX = 0,
    this.pageY = 0,
    this.preventDefaultFn,
    this.stopPropagationFn,
    this.dataTransfer,
    this.wheelDelta,
    this.wheelDeltaX,
    this.wheelDeltaY,
    this.deltaX = 0,
    this.deltaY = 0,
    this.deltaZ = 0,
    this.deltaMode = 0,
    this.DOM_DELTA_LINE = 1,
    this.targetNode,
    this.srcElement,
    this.geckoHorizontalAxis,
    this.geckoVerticalAxis,
    this.geckoAxis,
    this.devicePixelRatio = 0,
  });

  final int button;
  final int buttons;
  final int detail;
  final String type;
  final Object? target;
  final Object? view;
  final bool ctrlKey;
  final bool shiftKey;
  final bool altKey;
  final bool metaKey;
  final bool defaultPrevented;
  final num pageX;
  final num pageY;
  final void Function()? preventDefaultFn;
  final void Function()? stopPropagationFn;
  final Object? dataTransfer;

  // Deprecated wheel fields (may be absent -> null mirrors `undefined`).
  final num? wheelDelta;
  final num? wheelDeltaX;
  final num? wheelDeltaY;

  // Modern wheel fields.
  final num deltaX;
  final num deltaY;
  final num deltaZ;
  final int deltaMode;
  final int DOM_DELTA_LINE;
  final Object? targetNode;
  final Object? srcElement;

  // 1:1: `IGeckoMouseWheelEvent` fields and `e.view?.devicePixelRatio`.
  final int? geckoHorizontalAxis;
  final int? geckoVerticalAxis;
  final int? geckoAxis;
  final num devicePixelRatio;

  void preventDefault() => preventDefaultFn?.call();
  void stopPropagation() => stopPropagationFn?.call();
}

/// 1:1: `interface IMouseEvent`
abstract class IMouseEvent {
  MouseEvent get browserEvent;
  bool get leftButton;
  bool get middleButton;
  bool get rightButton;
  int get buttons;
  Object? get target;
  int get detail;
  num get posx;
  num get posy;
  bool get ctrlKey;
  bool get shiftKey;
  bool get altKey;
  bool get metaKey;
  int get timestamp;
  bool get defaultPrevented;
  void preventDefault();
  void stopPropagation();
}

/// 1:1: `export class StandardMouseEvent implements IMouseEvent`
class StandardMouseEvent implements IMouseEvent {
  @override
  final MouseEvent browserEvent;

  @override
  late final bool leftButton;
  @override
  late final bool middleButton;
  @override
  late final bool rightButton;
  @override
  late final int buttons;
  @override
  late final Object? target;
  @override
  late int detail;
  @override
  late final num posx;
  @override
  late final num posy;
  @override
  late final bool ctrlKey;
  @override
  late final bool shiftKey;
  @override
  late final bool altKey;
  @override
  late final bool metaKey;
  @override
  late final int timestamp;
  @override
  late final bool defaultPrevented;

  StandardMouseEvent(IframeWindow targetWindow, MouseEvent e)
      : browserEvent = e {
    // 1:1: `this.timestamp = Date.now()`
    timestamp = DateTime.now().millisecondsSinceEpoch;
    leftButton = e.button == 0;
    middleButton = e.button == 1;
    rightButton = e.button == 2;
    buttons = e.buttons;
    defaultPrevented = e.defaultPrevented;

    target = e.target;

    detail = e.detail != 0 ? e.detail : 1;
    if (e.type == 'dblclick') {
      detail = 2;
    }
    ctrlKey = e.ctrlKey;
    shiftKey = e.shiftKey;
    altKey = e.altKey;
    metaKey = e.metaKey;

    num px = e.pageX;
    num py = e.pageY;

    // Find the position of the iframe this code is executing in relative to
    // the iframe where the event was captured.
    final IframeWindow view = e.view as IframeWindow;
    final ({num top, num left}) iframeOffsets =
        IframeUtils.getPositionOfChildWindowRelativeToAncestorWindow(
            targetWindow, view);
    px -= iframeOffsets.left;
    py -= iframeOffsets.top;

    posx = px;
    posy = py;
  }

  @override
  void preventDefault() => browserEvent.preventDefault();

  @override
  void stopPropagation() => browserEvent.stopPropagation();
}

/// 1:1: `export class DragMouseEvent extends StandardMouseEvent`
class DragMouseEvent extends StandardMouseEvent {
  final Object? dataTransfer;

  DragMouseEvent(IframeWindow targetWindow, MouseEvent e)
      : dataTransfer = e.dataTransfer,
        super(targetWindow, e);
}

/// 1:1: `export class StandardWheelEvent`
class StandardWheelEvent {
  final MouseEvent? browserEvent;
  // Source declares these `readonly` but reassigns them throughout the
  // constructor; a mutable field is the faithful Dart equivalent.
  num deltaY;
  num deltaX;
  final Object? target;

  StandardWheelEvent(MouseEvent? e, [this.deltaX = 0, this.deltaY = 0])
      : browserEvent = e,
        // 1:1: `this.target = e ? (e.target || e.targetNode || e.srcElement) : null`
        target = e == null
            ? null
            : (e.target ?? e.targetNode ?? e.srcElement) {
    bool shouldFactorDPR = false;
    if (_isChrome()) {
      // Chrome version >= 123 contains the fix to factor devicePixelRatio
      // into the wheel event.
      final RegExp re = RegExp(r'Chrome/(\d+)');
      final Match? chromeVersionMatch = re.firstMatch(userAgentProvider());
      final int chromeMajorVersion = chromeVersionMatch == null
          ? 123
          : int.parse(chromeVersionMatch.group(1)!);
      shouldFactorDPR = chromeMajorVersion <= 122;
    }

    if (e != null) {
      // Old (deprecated) wheel events (IWebKit / IGecko views)
      final num? wheelDeltaY = e.wheelDeltaY;
      final int? geckoVerticalAxis = e.geckoVerticalAxis;
      final int? geckoHorizontalAxis = e.geckoHorizontalAxis;
      final int? geckoAxis = e.geckoAxis;
      final int geckoDetail = e.detail;

      // 1:1: `const devicePixelRatio = e.view?.devicePixelRatio || 1`
      final num devicePixelRatio =
          e.devicePixelRatio != 0 ? e.devicePixelRatio : 1;

      // vertical delta scroll
      if (wheelDeltaY != null) {
        if (shouldFactorDPR) {
          deltaY = wheelDeltaY / (120 * devicePixelRatio);
        } else {
          deltaY = wheelDeltaY / 120;
        }
      } else if (geckoVerticalAxis != null && geckoAxis == geckoVerticalAxis) {
        deltaY = -geckoDetail / 3;
      } else if (e.type == 'wheel') {
        // Modern wheel event
        if (e.deltaMode == e.DOM_DELTA_LINE) {
          // the deltas are expressed in lines
          if (_isFirefox() && !_isMacintosh()) {
            deltaY = -e.deltaY / 3;
          } else {
            deltaY = -e.deltaY;
          }
        } else {
          deltaY = -e.deltaY / 40;
        }
      }

      // horizontal delta scroll
      final num? wheelDeltaX = e.wheelDeltaX;
      if (wheelDeltaX != null) {
        if (_isSafari() && _isWindows()) {
          deltaX = -(wheelDeltaX / 120);
        } else if (shouldFactorDPR) {
          deltaX = wheelDeltaX / (120 * devicePixelRatio);
        } else {
          deltaX = wheelDeltaX / 120;
        }
      } else if (geckoHorizontalAxis != null &&
          geckoAxis == geckoHorizontalAxis) {
        deltaX = -e.detail / 3;
      } else if (e.type == 'wheel') {
        if (e.deltaMode == e.DOM_DELTA_LINE) {
          if (_isFirefox() && !_isMacintosh()) {
            deltaX = -e.deltaX / 3;
          } else {
            deltaX = -e.deltaX;
          }
        } else {
          deltaX = -e.deltaX / 40;
        }
      }

      // Assume a vertical scroll if nothing else worked
      if (deltaY == 0 &&
          deltaX == 0 &&
          e.wheelDelta != null &&
          e.wheelDelta != 0) {
        final num wheelDelta = e.wheelDelta!;
        if (shouldFactorDPR) {
          deltaY = wheelDelta / (120 * devicePixelRatio);
        } else {
          deltaY = wheelDelta / 120;
        }
      }
    }
  }

  void preventDefault() => browserEvent?.preventDefault();
  void stopPropagation() => browserEvent?.stopPropagation();
}
