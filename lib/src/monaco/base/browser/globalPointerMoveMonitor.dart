// 1:1 port of vscode/src/vs/base/browser/globalPointerMoveMonitor.ts
import 'dom.dart' as DOM
    show
        DomElement,
        DomEvent,
        EventType,
        addDisposableTargetListener,
        getWindow;
import '../common/lifecycle.dart' show DisposableStore, IDisposable, toDisposable;

/// 1:1: `interface IPointerMoveCallback`
typedef IPointerMoveCallback = void Function(DOM.DomEvent event);

/// 1:1: `interface IOnStopCallback`
typedef IOnStopCallback = void Function([Object? browserEvent]);

/// 1:1: `class GlobalPointerMoveMonitor implements IDisposable`
class GlobalPointerMoveMonitor implements IDisposable {
  final DisposableStore _hooks = DisposableStore();
  IPointerMoveCallback? _pointerMoveCallback;
  IOnStopCallback? _onStopCallback;

  @override
  void dispose() {
    stopMonitoring(false);
    _hooks.dispose();
  }

  void stopMonitoring(bool invokeStopCallback, [Object? browserEvent]) {
    if (!isMonitoring()) return;

    _hooks.clear();
    _pointerMoveCallback = null;
    final IOnStopCallback? callback = _onStopCallback;
    _onStopCallback = null;

    if (invokeStopCallback && callback != null) {
      callback(browserEvent);
    }
  }

  bool isMonitoring() => _pointerMoveCallback != null;

  void startMonitoring(
    DOM.DomElement initialElement,
    int pointerId,
    int initialButtons,
    IPointerMoveCallback pointerMoveCallback,
    IOnStopCallback onStopCallback,
  ) {
    if (isMonitoring()) {
      stopMonitoring(false);
    }
    _pointerMoveCallback = pointerMoveCallback;
    _onStopCallback = onStopCallback;

    Object eventSource = initialElement;
    try {
      initialElement.setPointerCapture(pointerId);
      _hooks.add(toDisposable(() {
        try {
          initialElement.releasePointerCapture(pointerId);
        } catch (_) {
          // releasePointerCapture may fail when the active pointer is gone.
        }
      }));
    } catch (_) {
      // setPointerCapture may fail on mousedown on some platforms; bind to window.
      eventSource = DOM.getWindow(initialElement);
    }

    _hooks.add(DOM.addDisposableTargetListener(
      eventSource,
      DOM.EventType.POINTER_MOVE,
      (DOM.DomEvent e) {
        if (e.buttons != initialButtons) {
          stopMonitoring(true);
          return;
        }
        e.preventDefault();
        _pointerMoveCallback!(e);
      },
    ));

    _hooks.add(DOM.addDisposableTargetListener(
      eventSource,
      DOM.EventType.POINTER_UP,
      (DOM.DomEvent e) => stopMonitoring(true),
    ));
  }
}
