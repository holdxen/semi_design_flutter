// 1:1 port of vscode/src/vs/base/browser/browser.ts
// Browser DOM globals have no Dart equivalent: `Window` -> Object,
// `navigator`/`matchMedia`/`windowControlsOverlay`/`globalThis.MonacoEnvironment`
// are bridged through injectable top-level slots (same convention as
// platform.dart). WindowManager's zoom/fullscreen state machine is preserved.

import '../common/event.dart' show Emitter, Event;
import '../common/platform.dart' as platform;
import '../common/platform.dart' show isIOS;
import 'window.dart' show CodeWindow, mainWindow;

// ---- DOM carriers ---------------------------------------------------------

/// 1:1: DOM `MediaQueryListEvent`.
class MediaQueryListEvent {
  final bool matches;
  const MediaQueryListEvent(this.matches);
}

/// 1:1: DOM `MediaQueryList`.
abstract class MediaQueryList {
  bool get matches;
  void addEventListener(String type, void Function(MediaQueryListEvent ev) cb);
}

/// 1:1: DOM `DOMRect` (fields used by the WCO helpers).
class DOMRect {
  final num x;
  final num y;
  final num width;
  final num height;
  const DOMRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// 1:1: `Navigator.windowControlsOverlay`.
abstract class WindowControlsOverlayLike {
  bool get visible;
  DOMRect? getTitlebarAreaRect();
}

/// 1:1: `interface IMonacoEnvironment`
class IMonacoEnvironment {
  /// `createTrustedTypesPolicy?<Options>(policyName, policyOptions?)`
  final Function? createTrustedTypesPolicy;
  /// `getWorker?(moduleId, label): Worker | Promise<Worker>`
  final Object? Function(String moduleId, String label)? getWorker;
  /// `getWorkerUrl?(moduleId, label): string`
  final String Function(String moduleId, String label)? getWorkerUrl;
  final bool? globalAPI;

  const IMonacoEnvironment({
    this.createTrustedTypesPolicy,
    this.getWorker,
    this.getWorkerUrl,
    this.globalAPI,
  });
}

// ---- injectable browser globals -------------------------------------------

/// 1:1: `navigator.userAgent`. Defaults to the platform bridge's snapshot.
String Function() userAgentProvider = () => platform.userAgent ?? '';

/// 1:1: `targetWindow.matchMedia(query)`. `null` means the method is absent.
MediaQueryList Function(Object targetWindow, String query)? matchMediaProvider;

/// 1:1: `navigator` for a given target window (`null` -> global navigator).
dynamic Function([Object? targetWindow]) navigatorProvider =
    ([Object? targetWindow]) => null;

/// 1:1: `globalThis.MonacoEnvironment`.
IMonacoEnvironment? monacoEnvironmentGlobal;

/// 1:1: `navigator` derived WindowControlsOverlay, read structurally.
WindowControlsOverlayLike? _wco(dynamic navigator) {
  if (navigator == null) {
    return null;
  }
  final dynamic wco = navigator.windowControlsOverlay;
  return wco is WindowControlsOverlayLike ? wco : null;
}

// ---- WindowManager --------------------------------------------------------

/// 1:1: `class WindowManager` (module-private singleton).
class _WindowManager {
  static final _WindowManager INSTANCE = _WindowManager();

  final Map<int, num> mapWindowIdToZoomLevel = <int, num>{};
  final Emitter<int> _onDidChangeZoomLevel = Emitter<int>();
  late final Event<int> onDidChangeZoomLevel = _onDidChangeZoomLevel.event;

  final Map<int, num> mapWindowIdToZoomFactor = <int, num>{};

  final Emitter<int> _onDidChangeFullscreen = Emitter<int>();
  late final Event<int> onDidChangeFullscreen = _onDidChangeFullscreen.event;
  final Map<int, bool> mapWindowIdToFullScreen = <int, bool>{};

  num getZoomLevel(Object targetWindow) =>
      mapWindowIdToZoomLevel[getWindowId(targetWindow)] ?? 0;

  void setZoomLevel(num zoomLevel, Object targetWindow) {
    if (getZoomLevel(targetWindow) == zoomLevel) {
      return;
    }
    final int targetWindowId = getWindowId(targetWindow);
    mapWindowIdToZoomLevel[targetWindowId] = zoomLevel;
    _onDidChangeZoomLevel.fire(targetWindowId);
  }

  num getZoomFactor(Object targetWindow) =>
      mapWindowIdToZoomFactor[getWindowId(targetWindow)] ?? 1;

  void setZoomFactor(num zoomFactor, Object targetWindow) =>
      mapWindowIdToZoomFactor[getWindowId(targetWindow)] = zoomFactor;

  void setFullscreen(bool fullscreen, Object targetWindow) {
    if (isFullscreen(targetWindow) == fullscreen) {
      return;
    }
    final int windowId = getWindowId(targetWindow);
    mapWindowIdToFullScreen[windowId] = fullscreen;
    _onDidChangeFullscreen.fire(windowId);
  }

  bool isFullscreen(Object targetWindow) =>
      mapWindowIdToFullScreen[getWindowId(targetWindow)] ?? false;

  /// 1:1: `(targetWindow as CodeWindow).vscodeWindowId`
  int getWindowId(Object targetWindow) =>
      (targetWindow as CodeWindow).vscodeWindowId;
}

// ---- exported state machine facade ----------------------------------------

/// 1:1: `export function addMatchMediaChangeListener(targetWindow, query, callback)`
void addMatchMediaChangeListener(
  Object targetWindow,
  Object query,
  void Function(MediaQueryListEvent ev) callback,
) {
  final MediaQueryList mediaQueryList = query is String
      ? matchMediaProvider!(targetWindow, query)
      : query as MediaQueryList;
  mediaQueryList.addEventListener('change', callback);
}

/// 1:1: `export function setZoomLevel(zoomLevel, targetWindow)`
void setZoomLevel(num zoomLevel, Object targetWindow) =>
    _WindowManager.INSTANCE.setZoomLevel(zoomLevel, targetWindow);

/// 1:1: `export function getZoomLevel(targetWindow)`
num getZoomLevel(Object targetWindow) =>
    _WindowManager.INSTANCE.getZoomLevel(targetWindow);

/// 1:1: `export const onDidChangeZoomLevel`
Event<int> get onDidChangeZoomLevel => _WindowManager.INSTANCE.onDidChangeZoomLevel;

/// 1:1: `export function getZoomFactor(targetWindow)`
num getZoomFactor(Object targetWindow) =>
    _WindowManager.INSTANCE.getZoomFactor(targetWindow);

/// 1:1: `export function setZoomFactor(zoomFactor, targetWindow)`
void setZoomFactor(num zoomFactor, Object targetWindow) =>
    _WindowManager.INSTANCE.setZoomFactor(zoomFactor, targetWindow);

/// 1:1: `export function setFullscreen(fullscreen, targetWindow)`
void setFullscreen(bool fullscreen, Object targetWindow) =>
    _WindowManager.INSTANCE.setFullscreen(fullscreen, targetWindow);

/// 1:1: `export function isFullscreen(targetWindow)`
bool isFullscreen(Object targetWindow) =>
    _WindowManager.INSTANCE.isFullscreen(targetWindow);

/// 1:1: `export const onDidChangeFullscreen`
Event<int> get onDidChangeFullscreen =>
    _WindowManager.INSTANCE.onDidChangeFullscreen;

// ---- user-agent derived constants -----------------------------------------

final String _userAgent = userAgentProvider();

/// 1:1: `export const isFirefox`
bool get isFirefox => _userAgent.contains('Firefox');

/// 1:1: `export const isWebKit`
bool get isWebKit => _userAgent.contains('AppleWebKit');

/// 1:1: `export const isChrome`
bool get isChrome => _userAgent.contains('Chrome');

/// 1:1: `export const isSafari`
bool get isSafari => !isChrome && _userAgent.contains('Safari');

/// 1:1: `export const isWebkitWebView`
bool get isWebkitWebView => !isChrome && !isSafari && isWebKit;

/// 1:1: `export const isElectron`
bool get isElectron => _userAgent.contains('Electron/');

/// 1:1: `export const isAndroid`
bool get isAndroid => _userAgent.contains('Android');

// ---- standalone (PWA) detection -------------------------------------------

/// Holds the mutable `standalone` flag and its one-time module-load init.
class _StandaloneState {
  bool value = false;
  final List<MediaQueryListEvent> standaloneChanges = <MediaQueryListEvent>[];

  void init() {
    final MediaQueryList Function(Object, String)? mm = matchMediaProvider;
    if (mm == null) {
      return;
    }
    final MediaQueryList standaloneMatchMedia = mm(
        mainWindow,
        '(display-mode: standalone) or (display-mode: window-controls-overlay)');
    final MediaQueryList fullScreenMatchMedia =
        mm(mainWindow, '(display-mode: fullscreen)');
    value = standaloneMatchMedia.matches;
    standaloneMatchMedia.addEventListener('change', (ev) {
      // entering fullscreen changes standaloneMatchMedia.matches to false;
      // skip when running as PWA and entering fullscreen.
      if (value && fullScreenMatchMedia.matches) {
        return;
      }
      value = ev.matches;
    });
  }
}

final _StandaloneState _standaloneState = _StandaloneState()
  ..init();

/// 1:1: `export function isStandalone()`: boolean
bool isStandalone() => _standaloneState.value;

/// 1:1: `export function isMobileStandalone()`: boolean
bool isMobileStandalone() => isStandalone() && (isIOS || isAndroid);

// ---- window controls overlay helpers --------------------------------------

/// 1:1: `export function isWCOEnabled()`: boolean
bool isWCOEnabled() => _wco(navigatorProvider())?.visible ?? false;

/// 1:1: `export function getWCOTitlebarAreaRect(targetWindow): DOMRect | undefined`
DOMRect? getWCOTitlebarAreaRect(Object targetWindow) =>
    _wco(navigatorProvider(targetWindow))?.getTitlebarAreaRect();

/// 1:1: `export function getVisibleWCOTitlebarAreaRect(targetWindow)`
DOMRect? getVisibleWCOTitlebarAreaRect(Object targetWindow) {
  final WindowControlsOverlayLike? overlay =
      _wco(navigatorProvider(targetWindow));
  return (overlay?.visible ?? false) ? overlay!.getTitlebarAreaRect() : null;
}

/// 1:1: `export function getMonacoEnvironment(): IMonacoEnvironment | undefined`
IMonacoEnvironment? getMonacoEnvironment() => monacoEnvironmentGlobal;
