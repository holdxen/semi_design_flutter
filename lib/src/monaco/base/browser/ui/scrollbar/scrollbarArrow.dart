// 1:1 port of vscode/src/vs/base/browser/ui/scrollbar/scrollbarArrow.ts
//
// The arrow is a small Widget placed on a scrollbar track. Construction is a
// pure DOM-structure pass (two divs with absolute positioning + codicon
// classes). Pointer interaction activates the arrow once, schedules a repeating
// activate timer (1000/24 ms) via a 200 ms delay timer, and monitors the pointer
// until release, at which point both timers are cancelled.
//
// Timer construction and pointer monitoring go through injectable factories so
// the truth-driven tests can observe scheduling deterministically; the default
// factories use the real dom/async implementations and preserve TS semantics.

import '../../../common/async.dart' as async;
import '../../../common/lifecycle.dart' show IDisposable;
import '../../../common/themables.dart' show ThemeIcon;
import '../../dom.dart' as dom;
import '../../globalPointerMoveMonitor.dart' show GlobalPointerMoveMonitor;
import '../widget.dart' show Widget;

/// 1:1: `export const ARROW_IMG_SIZE = 11`
const int ARROW_IMG_SIZE = 11;

/// 1:1: `export interface ScrollbarArrowOptions`
class ScrollbarArrowOptions {
  ScrollbarArrowOptions({
    required this.onActivate,
    required this.className,
    required this.icon,
    required this.bgWidth,
    required this.bgHeight,
    this.top,
    this.left,
    this.bottom,
    this.right,
  });

  final void Function() onActivate;
  final String className;
  final ThemeIcon icon;
  final num bgWidth;
  final num bgHeight;
  final num? top;
  final num? left;
  final num? bottom;
  final num? right;
}

/// 1:1 runtime surface shared by the repeat (interval) and schedule (timeout)
/// timers. JS passes a floating-point interval (`1000 / 24`); Dart's real timer
/// APIs take ints, so adapters round only at the boundary while the recorded
/// value stays faithful for truth verification.
abstract class ScrollbarArrowTimer implements IDisposable {
  void cancel();
  void cancelAndSet(void Function() runner, num value, [Object? context]);
}

class _IntervalTimerAdapter implements ScrollbarArrowTimer {
  _IntervalTimerAdapter(this._timer);
  final dom.WindowIntervalTimer _timer;
  @override
  void cancel() => _timer.cancel();
  @override
  void cancelAndSet(void Function() runner, num value, [Object? context]) =>
      _timer.cancelAndSet(runner, value.round(), context);
  @override
  void dispose() => _timer.dispose();
}

class _TimeoutTimerAdapter implements ScrollbarArrowTimer {
  _TimeoutTimerAdapter(this._timer);
  final async.TimeoutTimer _timer;
  @override
  void cancel() => _timer.cancel();
  @override
  void cancelAndSet(void Function() runner, num value, [Object? context]) =>
      _timer.cancelAndSet(runner, value.round());
  @override
  void dispose() => _timer.dispose();
}

/// Injectable timer factories (default = real implementations).
ScrollbarArrowTimer Function() repeatTimerFactory =
    () => _IntervalTimerAdapter(dom.WindowIntervalTimer());
ScrollbarArrowTimer Function() scheduleTimerFactory =
    () => _TimeoutTimerAdapter(async.TimeoutTimer());

/// Injectable pointer-monitor factory (default = real implementation).
GlobalPointerMoveMonitor Function() pointerMoveMonitorFactory =
    () => GlobalPointerMoveMonitor();

/// Broadly read a field off a raw pointer/DOM event. The port dispatches raw
/// DOM events (`DomEvent`) that carry target/buttons; synthetic truth events
/// additionally carry `pointerId`, matching the TS `PointerEvent` shape.
Object? _eventField(Object e, String name) {
  if (e is Map) return e[name];
  switch (name) {
    case 'target':
      return e is dom.DomEvent ? e.target : (e as dynamic).target;
    case 'buttons':
      if (e is dom.DomEvent) return e.buttons;
      return (e as dynamic).buttons;
    case 'pointerId':
      if (e is dom.DomEvent) return 0;
      try {
        return (e as dynamic).pointerId;
      } catch (_) {
        return 0;
      }
    default:
      return null;
  }
}

void _preventDefault(Object e) {
  if (e is dom.DomEvent) {
    e.preventDefault();
    return;
  }
  (e as dynamic).preventDefault();
}

/// 1:1: `export class ScrollbarArrow extends Widget`
class ScrollbarArrow extends Widget {
  ScrollbarArrow(ScrollbarArrowOptions opts) : super() {
    _onActivate = opts.onActivate;

    bgDomNode = dom.document.createElement('div');
    bgDomNode.className = 'arrow-background';
    bgDomNode.style['position'] = 'absolute';
    bgDomNode.style['width'] = '${opts.bgWidth}px';
    bgDomNode.style['height'] = '${opts.bgHeight}px';
    if (opts.top != null) bgDomNode.style['top'] = '0px';
    if (opts.left != null) bgDomNode.style['left'] = '0px';
    if (opts.bottom != null) bgDomNode.style['bottom'] = '0px';
    if (opts.right != null) bgDomNode.style['right'] = '0px';

    domNode = dom.document.createElement('div');
    domNode.className = opts.className;
    for (final String cls in ThemeIcon.asClassNameArray(opts.icon)) {
      domNode.classList.add(cls);
    }

    domNode.style['position'] = 'absolute';
    domNode.style['width'] = '${ARROW_IMG_SIZE}px';
    domNode.style['height'] = '${ARROW_IMG_SIZE}px';
    if (opts.top != null) domNode.style['top'] = '${opts.top}px';
    if (opts.left != null) domNode.style['left'] = '${opts.left}px';
    if (opts.bottom != null) domNode.style['bottom'] = '${opts.bottom}px';
    if (opts.right != null) domNode.style['right'] = '${opts.right}px';

    _pointerMoveMonitor = register(pointerMoveMonitorFactory());
    register(dom.addStandardDisposableListener(
        bgDomNode, dom.EventType.POINTER_DOWN, (Object e) => arrowPointerDown(e)));
    register(dom.addStandardDisposableListener(
        domNode, dom.EventType.POINTER_DOWN, (Object e) => arrowPointerDown(e)));

    _pointerdownRepeatTimer = register(repeatTimerFactory());
    _pointerdownScheduleRepeatTimer = register(scheduleTimerFactory());
  }

  late final void Function() _onActivate;

  /// Test seam: invoke the activation callback (1:1: the `opts.onActivate`
  /// closure), mirroring a real pointer activation without a live timer.
  void activate() => _onActivate();

  late final dom.DomElement bgDomNode;
  late final dom.DomElement domNode;
  late final ScrollbarArrowTimer _pointerdownRepeatTimer;
  late final ScrollbarArrowTimer _pointerdownScheduleRepeatTimer;
  late final GlobalPointerMoveMonitor _pointerMoveMonitor;

  /// 1:1: `private _arrowPointerDown(e: PointerEvent)`.
  /// Public for truth-driven verification (mirrors the port convention of
  /// exposing private methods that tests must observe).
  void arrowPointerDown(Object e) {
    final Object? target = _eventField(e, 'target');
    if (target == null || target is! dom.DomElement) {
      return;
    }

    final int pointerId = (_eventField(e, 'pointerId') as num?)?.toInt() ?? 0;
    final int buttons = (_eventField(e, 'buttons') as num?)?.toInt() ?? 0;

    final void Function() scheduleRepeater = () {
      _pointerdownRepeatTimer.cancelAndSet(
          () => _onActivate(), 1000 / 24, dom.getWindow(e));
    };

    _onActivate();
    _pointerdownRepeatTimer.cancel();
    _pointerdownScheduleRepeatTimer.cancelAndSet(scheduleRepeater, 200);

    _pointerMoveMonitor.startMonitoring(
      target,
      pointerId,
      buttons,
      (dom.DomEvent event) { /* Intentional empty */ },
      ([Object? browserEvent]) {
        _pointerdownRepeatTimer.cancel();
        _pointerdownScheduleRepeatTimer.cancel();
      },
    );

    _preventDefault(e);
  }
}
