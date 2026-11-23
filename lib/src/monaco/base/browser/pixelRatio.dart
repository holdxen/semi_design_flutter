// 1:1 port of vscode/src/vs/base/browser/pixelRatio.ts (126 lines).
// Browser globals (`matchMedia`, canvas backing store) are injectable slots,
// matching the carrier convention used by dom.dart / browser.dart.
//
// Truth: tool/ts2dart/batch94_truth.json

import '../common/event.dart' as event;
import '../common/lifecycle.dart' as lifecycle;
import 'dom.dart' show getWindowId, onDidUnregisterWindow, windowCarrier;
import 'window.dart' show CodeWindow;

/// 1:1: DOM `MediaQueryList` subset used by DevicePixelRatioMonitor.
class DomMediaQueryList {
  final String query;
  /// Browser `MediaQueryList.matches` (injected by the embedder). 1:1.
  bool matches = false;
  final List<void Function()> _listeners = <void Function()>[];

  DomMediaQueryList(this.query);

  void addEventListener(String type, void Function() handler) =>
      _listeners.add(handler);

  void removeEventListener(String type, void Function() handler) =>
      _listeners.removeWhere((void Function() h) => identical(h, handler));

  /// Test/runtime seam for the browser's `change` event.
  void fireChange() => _listeners.toList().forEach((void Function() h) => h());
}

/// 1:1: `targetWindow.matchMedia(query)`.
DomMediaQueryList Function(CodeWindow targetWindow, String query)
    matchMediaProvider = (CodeWindow targetWindow, String query) =>
    DomMediaQueryList(query);

/// 1:1: `BackingStoreContext` (canvas 2d context + vendor pixel ratios).
class BackingStoreContext {
  double? webkitBackingStorePixelRatio;
  double? mozBackingStorePixelRatio;
  double? msBackingStorePixelRatio;
  double? oBackingStorePixelRatio;
  double? backingStorePixelRatio;
}

/// 1:1: `document.createElement('canvas').getContext('2d')`.
BackingStoreContext? Function() canvasContextProvider = () => null;

/// JS number-to-string: integral doubles have no `.0` suffix.
String _jsNumString(num value) =>
    value is double && value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();

/// 1:1: `class DevicePixelRatioMonitor extends Disposable`
class DevicePixelRatioMonitor extends lifecycle.Disposable {
  final event.Emitter<void> _onDidChange = event.Emitter<void>();
  late final event.Event<void> onDidChange = _onDidChange.event;
  late final void Function() _listener;
  DomMediaQueryList? _mediaQueryList;

  DevicePixelRatioMonitor(CodeWindow targetWindow) {
    _listener = () => _handleChange(targetWindow, true);
    _mediaQueryList = null;
    _handleChange(targetWindow, false);

    register(lifecycle.toDisposable(() =>
        _mediaQueryList?.removeEventListener('change', _listener)));
  }

  void _handleChange(CodeWindow targetWindow, bool fireEvent) {
    _mediaQueryList?.removeEventListener('change', _listener);
    _mediaQueryList = matchMediaProvider(targetWindow,
        '(resolution: ${_jsNumString(windowCarrier(targetWindow).devicePixelRatio)}dppx)');
    _mediaQueryList!.addEventListener('change', _listener);
    if (fireEvent) _onDidChange.fire(null);
  }
}

/// 1:1: `interface IPixelRatioMonitor`
abstract class IPixelRatioMonitor {
  num get value;
  event.Event<num> get onDidChange;
}

/// 1:1: `class PixelRatioMonitorImpl extends Disposable`
class PixelRatioMonitorImpl extends lifecycle.Disposable
    implements IPixelRatioMonitor {
  final event.Emitter<num> _onDidChange = event.Emitter<num>();

  @override
  late final event.Event<num> onDidChange = _onDidChange.event;

  num _value = 0;

  @override
  num get value => _value;

  PixelRatioMonitorImpl(CodeWindow targetWindow) {
    _value = _getPixelRatio(targetWindow);
    final DevicePixelRatioMonitor dprMonitor =
        register(DevicePixelRatioMonitor(targetWindow));
    register(dprMonitor.onDidChange((dynamic _) {
      _value = _getPixelRatio(targetWindow);
      _onDidChange.fire(_value);
    }));
  }

  num _getPixelRatio(CodeWindow targetWindow) {
    final BackingStoreContext? ctx = canvasContextProvider();
    final num dpr = windowCarrier(targetWindow).devicePixelRatio != 0
        ? windowCarrier(targetWindow).devicePixelRatio
        : 1;
    final num bsr = ctx?.webkitBackingStorePixelRatio ??
        ctx?.mozBackingStorePixelRatio ??
        ctx?.msBackingStorePixelRatio ??
        ctx?.oBackingStorePixelRatio ??
        ctx?.backingStorePixelRatio ??
        1;
    return dpr / bsr;
  }
}

/// 1:1: `class PixelRatioMonitorFacade`
class PixelRatioMonitorFacade {
  final Map<int, PixelRatioMonitorImpl> _mapWindowIdToPixelRatioMonitor =
      <int, PixelRatioMonitorImpl>{};

  PixelRatioMonitorImpl _getOrCreatePixelRatioMonitor(CodeWindow targetWindow) {
    final int targetWindowId = getWindowId(targetWindow);
    PixelRatioMonitorImpl? pixelRatioMonitor =
        _mapWindowIdToPixelRatioMonitor[targetWindowId];
    if (pixelRatioMonitor == null) {
      pixelRatioMonitor = lifecycle.markAsSingleton(
          PixelRatioMonitorImpl(targetWindow));
      _mapWindowIdToPixelRatioMonitor[targetWindowId] = pixelRatioMonitor;
      late final lifecycle.IDisposable unregisterListener;
      unregisterListener = lifecycle.markAsSingleton(
          onDidUnregisterWindow((dynamic e) {
        final int id = (e as CodeWindow).vscodeWindowId;
        if (id == targetWindowId) {
          unregisterListener.dispose();
          pixelRatioMonitor?.dispose();
          _mapWindowIdToPixelRatioMonitor.remove(targetWindowId);
        }
      }));
    }
    return pixelRatioMonitor;
  }

  /// 1:1: `getInstance(targetWindow)`
  IPixelRatioMonitor getInstance(CodeWindow targetWindow) =>
      _getOrCreatePixelRatioMonitor(targetWindow);
}

/// 1:1: `export const PixelRatio = new PixelRatioMonitorFacade()`
final PixelRatioMonitorFacade PixelRatio = PixelRatioMonitorFacade();
