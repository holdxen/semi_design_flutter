// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/canIUse.ts
// Translated 1:1. DOM `document`/`navigator`/`mainWindow` capability probes are
// surfaced as injectable slots so the feature-detection logic stays unchanged.
// ---------------------------------------------------------------------------

import 'browser.dart' as browser;
import 'window.dart' show mainWindow;
import '../common/platform.dart' as platform;

/// 1:1: `const enum KeyboardSupport`
class KeyboardSupport {
  static const int Always = 0;
  static const int FullScreen = 1;
  static const int None = 2;
}

/// 1:1: `document.queryCommandSupported?.(command)` — null when API absent.
bool Function(String command)? queryCommandSupportedProvider;

/// 1:1: `navigator` capability carrier. Null fields mirror absent DOM APIs.
class NavigatorCapabilities {
  const NavigatorCapabilities({
    this.clipboardWriteText = false,
    this.clipboardReadText = false,
    this.keyboard = false,
    this.maxTouchPoints = 0,
  });

  final bool clipboardWriteText;
  final bool clipboardReadText;
  final bool keyboard;
  final int maxTouchPoints;
}

/// 1:1: injectable `navigator`.
NavigatorCapabilities Function() navigatorProvider =
    () => const NavigatorCapabilities();

/// Injectable browser env overrides (defaults read browser.dart flags).
bool Function()? isStandaloneOverride;
bool Function()? isSafariOverride;

bool _isStandalone() => isStandaloneOverride?.call() ?? browser.isStandalone();
bool _isSafari() => isSafariOverride?.call() ?? browser.isSafari;
bool Function()? isNativeOverride;
bool _isNative() => isNativeOverride?.call() ?? platform.isNative;

/// 1:1: `'ontouchstart' in mainWindow` probe.
bool Function(Object window)? hasTouchStartProvider = (Object w) => false;

/// 1:1: `mainWindow.PointerEvent` probe.
bool Function(Object window)? hasPointerEventProvider = (Object w) => false;

/// 1:1: `BrowserFeatures.clipboard` nested carrier.
final class ClipboardFeatures {
  const ClipboardFeatures({required this.writeText, required this.readText});
  final bool writeText;
  final bool readText;
}

/// 1:1: `export const BrowserFeatures`
final class BrowserFeaturesValue {
  const BrowserFeaturesValue({
    required this.clipboard,
    required this.keyboard,
    required this.touch,
    required this.pointerEvents,
  });

  final ClipboardFeatures clipboard;
  final int keyboard;
  final bool touch;
  final bool pointerEvents;
}

/// Source evaluates `BrowserFeatures` at module load via an IIFE. The Dart
/// port evaluates it on first access through a lazy final so injected
/// capability providers set before first use are honoured.
final BrowserFeaturesValue BrowserFeatures = computeBrowserFeatures();

/// Source IIFE body, exposed so tests can exercise capability combinations.
BrowserFeaturesValue computeBrowserFeatures() {
  final NavigatorCapabilities nav = navigatorProvider();
  final Object window = mainWindow;

  final bool writeText = _isNative() ||
      (queryCommandSupportedProvider != null &&
          queryCommandSupportedProvider!('copy')) ||
      nav.clipboardWriteText;
  final bool readText = _isNative() || nav.clipboardReadText;

  final int keyboard = () {
    if (_isNative() || _isStandalone()) {
      return KeyboardSupport.Always;
    }
    if (nav.keyboard || _isSafari()) {
      return KeyboardSupport.FullScreen;
    }
    return KeyboardSupport.None;
  }();

  // 1:1: `'ontouchstart' in mainWindow || navigator.maxTouchPoints > 0`
  final bool ontouchstart = hasTouchStartProvider?.call(window) ?? false;
  final bool touch = ontouchstart || nav.maxTouchPoints > 0;

  // 1:1: `mainWindow.PointerEvent && ('ontouchstart' in mainWindow || ...)`
  final bool hasPointerEvent = hasPointerEventProvider?.call(window) ?? false;
  final bool pointerEvents = hasPointerEvent && touch;

  return BrowserFeaturesValue(
    clipboard: ClipboardFeatures(writeText: writeText, readText: readText),
    keyboard: keyboard,
    touch: touch,
    pointerEvents: pointerEvents,
  );
}
