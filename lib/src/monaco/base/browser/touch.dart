// 1:1 port of vs/base/browser/touch.ts
//
// Gesture recognizer over touch events. Dart has no DOM, so touch events,
// targets and custom-event creation are bridged through carrier types and
// injectable providers; the gesture state machine (tap/contextmenu/move/
// inertia) is transcribed verbatim.

import 'dart:collection' show HashMap;

import '../common/decorators.dart' show memoize;
import '../common/event.dart' as event;
import '../common/lifecycle.dart' as lifecycle;
import '../common/linkedList.dart' show LinkedList;
import 'dom.dart'
    show
        DomElement,
        DomEvent,
        DomEventListenerOptions,
        DomNode,
        IRegisteredCodeWindow,
        addDisposableTargetListener,
        onDidRegisterWindow,
        scheduleAtNextAnimationFrame,
        windowCarrier;
import 'pixelRatio.dart' show matchMediaProvider;
import 'window.dart' show CodeWindow, mainWindow;

/// 1:1: `export namespace EventType`
class EventType {
  static const String Tap = '-monaco-gesturetap';
  static const String Change = '-monaco-gesturechange';
  static const String Start = '-monaco-gesturestart';
  static const String End = '-monaco-gesturesend';
  static const String Contextmenu = '-monaco-gesturecontextmenu';
}

/// DOM `Touch` subset used by [DomTouchList].
class DomTouch {
  final int identifier;
  final Object target;
  final num pageX;
  final num pageY;
  DomTouch(this.identifier, this.target, this.pageX, this.pageY);
}

/// 1:1: `interface TouchList`
class DomTouchList {
  final List<DomTouch> touches;
  DomTouchList(this.touches);
  int get length => touches.length;
  DomTouch item(int index) => touches[index];
}

/// 1:1: `interface TouchEvent`
class DomTouchEvent {
  final DomTouchList targetTouches;
  final DomTouchList changedTouches;
  bool defaultPreventedFlag = false;
  DomTouchEvent(this.targetTouches, this.changedTouches);
  void preventDefault() => defaultPreventedFlag = true;
  void stopPropagation() {}
}

/// 1:1: `export interface GestureEvent extends MouseEvent`
class GestureEvent {
  String type;
  Object? initialTarget;
  num translationX = 0;
  num translationY = 0;
  num pageX = 0;
  num pageY = 0;
  int tapCount = 0;
  GestureEvent(this.type);
}

/// Injectable `document.createEvent('CustomEvent')` + `initEvent`.
GestureEvent Function(String type) gestureEventFactory = (String type) => GestureEvent(type);

/// Injectable `Date.now()` / `new Date().getTime()`.
int Function() touchNowProvider = () => DateTime.now().millisecondsSinceEpoch;

/// Injectable `'ontouchstart' in mainWindow || navigator.maxTouchPoints > 0`.
bool Function() touchDeviceProvider = () => false;

/// 1:1: `interface TouchData`
class _TouchData {
  final int id;
  final Object initialTarget;
  final int initialTimeStamp;
  final num initialPageX;
  final num initialPageY;
  final List<int> rollingTimestamps;
  final List<num> rollingPageX;
  final List<num> rollingPageY;
  _TouchData(
    this.id,
    this.initialTarget,
    this.initialTimeStamp,
    this.initialPageX,
    this.initialPageY,
    this.rollingTimestamps,
    this.rollingPageX,
    this.rollingPageY,
  );
}

/// 1:1: `export class Gesture extends Disposable`
class Gesture extends lifecycle.Disposable {
  static const num _SCROLL_FRICTION = -0.005;
  static Gesture? _instance;
  static const int _HOLD_DELAY = 700;
  static const int _CLEAR_TAP_COUNT_TIME = 400;

  bool _dispatched = false;
  final LinkedList<DomNode> _targets = LinkedList<DomNode>();
  final LinkedList<DomNode> _ignoreTargets = LinkedList<DomNode>();
  lifecycle.IDisposable? handle;

  final HashMap<int, _TouchData> _activeTouches = HashMap<int, _TouchData>();
  int _lastSetTapCountTime = 0;

  final lifecycle.DisposableStore _windowDisposables = lifecycle.DisposableStore();

  Gesture._() {
    register(_windowDisposables);
    register(event.eventRunAndSubscribe<IRegisteredCodeWindow>(
        onDidRegisterWindow, (IRegisteredCodeWindow? e) {
      final CodeWindow window = e?.window ?? mainWindow;
      final lifecycle.DisposableStore disposables =
          e?.disposables ?? _windowDisposables;
      final DomNode document = windowCarrier(window).document;
      disposables.add(addDisposableTargetListener(
          document, 'touchstart', (DomEvent ev) => onTouchStart(_touchOf(ev)),
          const DomEventListenerOptions()));
      disposables.add(addDisposableTargetListener(
          document, 'touchend',
          (DomEvent ev) => onTouchEnd(window, _touchOf(ev))));
      disposables.add(addDisposableTargetListener(
          document, 'touchmove', (DomEvent ev) => onTouchMove(_touchOf(ev)),
          const DomEventListenerOptions()));
    }, IRegisteredCodeWindow(mainWindow, _windowDisposables)));
  }

  /// 1:1: `Gesture.addTarget(element)`.
  static lifecycle.IDisposable addTarget(DomNode element) {
    if (!isTouchDevice()) return lifecycle.Disposable.none;
    _instance ??= Gesture._();
    final void Function() remove = _instance!._targets.push(element);
    return lifecycle.toDisposable(remove);
  }

  /// 1:1: `Gesture.ignoreTarget(element)`.
  static lifecycle.IDisposable ignoreTarget(DomNode element) {
    if (!isTouchDevice()) return lifecycle.Disposable.none;
    _instance ??= Gesture._();
    final void Function() remove = _instance!._ignoreTargets.push(element);
    return lifecycle.toDisposable(remove);
  }

  /// 1:1: `@memoize static isTouchDevice()`.
  static bool isTouchDevice() =>
      memoize(Gesture, 'isTouchDevice', () => touchDeviceProvider())() as bool;

  /// 1:1: `@memoize static isHoverDevice()`.
  static bool isHoverDevice() => memoize(Gesture, 'isHoverDevice', () {
        final String q = '(hover: hover)';
        return matchMediaProvider(mainWindow, q).matches;
      })() as bool;

  @override
  void dispose() {
    if (handle != null) {
      handle!.dispose();
      handle = null;
    }
    super.dispose();
  }

  DomTouchEvent _touchOf(DomEvent ev) => (ev.touchEvent ?? ev) as DomTouchEvent;

  void onTouchStart(DomTouchEvent e) {
    final int timestamp = touchNowProvider();

    if (handle != null) {
      handle!.dispose();
      handle = null;
    }

    for (int i = 0; i < e.targetTouches.length; i++) {
      final DomTouch touch = e.targetTouches.item(i);
      _activeTouches[touch.identifier] = _TouchData(
        touch.identifier,
        touch.target,
        timestamp,
        touch.pageX,
        touch.pageY,
        <int>[timestamp],
        <num>[touch.pageX],
        <num>[touch.pageY],
      );

      final GestureEvent evt = _newGestureEvent(EventType.Start, touch.target);
      evt.pageX = touch.pageX;
      evt.pageY = touch.pageY;
      _dispatchEvent(evt);
    }

    if (_dispatched) {
      e.preventDefault();
      e.stopPropagation();
      _dispatched = false;
    }
  }

  void onTouchEnd(CodeWindow targetWindow, DomTouchEvent e) {
    final int timestamp = touchNowProvider();
    final int activeTouchCount = _activeTouches.length;

    for (int i = 0; i < e.changedTouches.length; i++) {
      final DomTouch touch = e.changedTouches.item(i);
      final _TouchData? data = _activeTouches[touch.identifier];
      if (data == null) {
        continue;
      }

      final int holdTime = touchNowProvider() - data.initialTimeStamp;
      final num finalX = data.rollingPageX.last;
      final num finalY = data.rollingPageY.last;

      if (holdTime < _HOLD_DELAY &&
          (data.initialPageX - finalX).abs() < 30 &&
          (data.initialPageY - finalY).abs() < 30) {
        final GestureEvent evt =
            _newGestureEvent(EventType.Tap, data.initialTarget);
        evt.pageX = finalX;
        evt.pageY = finalY;
        _dispatchEvent(evt);
      } else if (holdTime >= _HOLD_DELAY &&
          (data.initialPageX - finalX).abs() < 30 &&
          (data.initialPageY - finalY).abs() < 30) {
        final GestureEvent evt =
            _newGestureEvent(EventType.Contextmenu, data.initialTarget);
        evt.pageX = finalX;
        evt.pageY = finalY;
        _dispatchEvent(evt);
      } else if (activeTouchCount == 1) {
        final int deltaT = data.rollingTimestamps.last - data.rollingTimestamps.first;
        final num deltaX = finalX - data.rollingPageX.first;
        final num deltaY = finalY - data.rollingPageY.first;
        final List<DomNode> dispatchTo = _targets.iterable
            .where((DomNode t) =>
                data.initialTarget is DomNode &&
                t.contains(data.initialTarget as DomNode))
            .toList();
        _inertia(
          targetWindow,
          dispatchTo,
          timestamp,
          deltaX.abs() / deltaT,
          deltaX > 0 ? 1 : -1,
          finalX,
          deltaY.abs() / deltaT,
          deltaY > 0 ? 1 : -1,
          finalY,
        );
      }

      _dispatchEvent(_newGestureEvent(EventType.End, data.initialTarget));
      _activeTouches.remove(touch.identifier);
    }

    if (_dispatched) {
      e.preventDefault();
      e.stopPropagation();
      _dispatched = false;
    }
  }

  GestureEvent _newGestureEvent(String type, [Object? initialTarget]) {
    final GestureEvent event = gestureEventFactory(type);
    event.initialTarget = initialTarget;
    event.tapCount = 0;
    return event;
  }

  void _dispatchEvent(GestureEvent event) {
    if (event.type == EventType.Tap) {
      final int currentTime = touchNowProvider();
      int setTapCount;
      if (currentTime - _lastSetTapCountTime > _CLEAR_TAP_COUNT_TIME) {
        setTapCount = 1;
      } else {
        setTapCount = 2;
      }
      _lastSetTapCountTime = currentTime;
      event.tapCount = setTapCount;
    } else if (event.type == EventType.Change ||
        event.type == EventType.Contextmenu) {
      _lastSetTapCountTime = 0;
    }

    if (event.initialTarget is DomNode) {
      final DomNode target = event.initialTarget as DomNode;
      for (final DomNode ignoreTarget in _ignoreTargets.iterable) {
        if (ignoreTarget.contains(target)) return;
      }

      final List<(int, DomNode)> targets = <(int, DomNode)>[];
      for (final DomNode t in _targets.iterable) {
        if (t.contains(target)) {
          int depth = 0;
          DomNode? now = target;
          while (now != null && now != t) {
            depth++;
            now = now.parentElement;
          }
          targets.add((depth, t));
        }
      }
      targets.sort((a, b) => a.$1.compareTo(b.$1));
      for (final (_, DomNode t) in targets) {
        t.dispatchEvent(event.type, _asDomEvent(event));
        _dispatched = true;
      }
    }
  }

  /// Bridge [GestureEvent] to a DOM dispatch event carrying the gesture payload.
  DomEvent _asDomEvent(GestureEvent e) {
    final DomEvent ev = DomEvent(e.type);
    ev.gestureEvent = e;
    return ev;
  }

  void _inertia(
    CodeWindow targetWindow,
    List<DomNode> dispatchTo,
    int t1,
    num vX,
    int dirX,
    num x,
    num vY,
    int dirY,
    num y,
  ) {
    handle = scheduleAtNextAnimationFrame(targetWindow, () {
      final int now = touchNowProvider();
      final int deltaT = now - t1;
      num deltaPosX = 0;
      num deltaPosY = 0;
      bool stopped = true;

      vX += _SCROLL_FRICTION * deltaT;
      vY += _SCROLL_FRICTION * deltaT;
      if (vX > 0) {
        stopped = false;
        deltaPosX = dirX * vX * deltaT;
      }
      if (vY > 0) {
        stopped = false;
        deltaPosY = dirY * vY * deltaT;
      }

      final GestureEvent evt = _newGestureEvent(EventType.Change);
      evt.translationX = deltaPosX;
      evt.translationY = deltaPosY;
      for (final DomNode d in dispatchTo) {
        d.dispatchEvent(evt.type, _asDomEvent(evt));
      }

      if (!stopped) {
        _inertia(targetWindow, dispatchTo, now, vX, dirX, x + deltaPosX,
            vY, dirY, y + deltaPosY);
      }
    });
  }

  void onTouchMove(DomTouchEvent e) {
    final int timestamp = touchNowProvider();
    for (int i = 0; i < e.changedTouches.length; i++) {
      final DomTouch touch = e.changedTouches.item(i);
      final _TouchData? data = _activeTouches[touch.identifier];
      if (data == null) continue;

      final GestureEvent evt =
          _newGestureEvent(EventType.Change, data.initialTarget);
      evt.translationX = touch.pageX - data.rollingPageX.last;
      evt.translationY = touch.pageY - data.rollingPageY.last;
      evt.pageX = touch.pageX;
      evt.pageY = touch.pageY;
      _dispatchEvent(evt);

      if (data.rollingPageX.length > 3) {
        data.rollingPageX.removeAt(0);
        data.rollingPageY.removeAt(0);
        data.rollingTimestamps.removeAt(0);
      }
      data.rollingPageX.add(touch.pageX);
      data.rollingPageY.add(touch.pageY);
      data.rollingTimestamps.add(timestamp);
    }

    if (_dispatched) {
      e.preventDefault();
      e.stopPropagation();
      _dispatched = false;
    }
  }
}
