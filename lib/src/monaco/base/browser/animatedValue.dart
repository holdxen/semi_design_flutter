// 1:1 port of vscode/src/vs/base/browser/animatedValue.ts
import 'dart:math' as math;

import 'dom.dart' show getActiveWindow, windowCarrier;
import '../common/observable.dart' show IObservableSignal, IReader, observableSignal;

/// Test seam for JS `Date.now()`.
int Function() animatedValueDateNow = () =>
    DateTime.now().millisecondsSinceEpoch;

/// 1:1: `interface IAnimatedValue`
abstract class IAnimatedValue {
  /// Once true, it can never become false again.
  bool isFinished(int nowMs);
  num getValue(int nowMs);
}

/// 1:1: `type InterpolationFunction`
typedef InterpolationFunction = num Function(
    num passedTime, num start, num length, num totalDuration);

/// 1:1: `class AnimatedValue`
class AnimatedValue implements IAnimatedValue {
  final num startValue;
  final num endValue;
  num durationMs;
  final int startTimeMs;
  final InterpolationFunction _interpolationFunction;

  AnimatedValue(
    this.startValue,
    this.endValue,
    this.durationMs,
    this.startTimeMs, [
    this._interpolationFunction = easeOutExpo,
  ]) {
    if (startValue == endValue) {
      durationMs = 0;
    }
  }

  static AnimatedValue constant(num value) =>
      AnimatedValue(value, value, 0, animatedValueDateNow());

  static AnimatedValue startNow(
    num startValue,
    num endValue,
    num durationMs, [
    InterpolationFunction interpolationFunction = easeOutExpo,
  ]) =>
      AnimatedValue(startValue, endValue, durationMs, animatedValueDateNow(),
          interpolationFunction);

  @override
  bool isFinished(int nowMs) => nowMs >= startTimeMs + durationMs;

  @override
  num getValue(int nowMs) {
    final num timePassed = nowMs - startTimeMs;
    if (timePassed >= durationMs) return endValue;
    return _interpolationFunction(
        timePassed, startValue, endValue - startValue, durationMs);
  }
}

/// 1:1: `easeOutExpo`
num easeOutExpo(
        num passedTime, num start, num length, num totalDuration) =>
    passedTime == totalDuration
        ? start + length
        : length * (-math.pow(2, -10 * passedTime / totalDuration) + 1) + start;

/// 1:1: `easeOutCubic`
num easeOutCubic(
    num passedTime, num start, num length, num totalDuration) {
  num t = passedTime / totalDuration - 1;
  return length * (t * t * t + 1) + start;
}

/// 1:1: `linear`
num linear(num passedTime, num start, num length, num totalDuration) =>
    length * passedTime / totalDuration + start;

/// 1:1: `class LoopingAnimatedValue`
class LoopingAnimatedValue implements IAnimatedValue {
  final num _startValue;
  final num _endValue;
  final num _durationMs;
  final int _startTimeMs;
  final InterpolationFunction _interpolationFunction;

  LoopingAnimatedValue(this._startValue, this._endValue, this._durationMs,
      this._startTimeMs, this._interpolationFunction);

  static LoopingAnimatedValue startNow(num startValue, num endValue,
          num durationMs, InterpolationFunction interpolationFunction) =>
      LoopingAnimatedValue(startValue, endValue, durationMs,
          animatedValueDateNow(), interpolationFunction);

  @override
  bool isFinished(int nowMs) => false;

  @override
  num getValue(int nowMs) {
    final num timePassed = (nowMs - _startTimeMs) % _durationMs;
    return _interpolationFunction(timePassed, _startValue,
        _endValue - _startValue, _durationMs);
  }
}

/// 1:1: `class ObservableAnimatedValue<T extends IAnimatedValue>`
class ObservableAnimatedValue<T extends IAnimatedValue> {
  final T _value;

  ObservableAnimatedValue(this._value);

  static ObservableAnimatedValue<AnimatedValue> constant(num value) =>
      ObservableAnimatedValue<AnimatedValue>(AnimatedValue.constant(value));

  num getValue(IReader? reader) {
    final int nowMs = animatedValueDateNow();
    if (!_value.isFinished(nowMs)) {
      AnimationFrameScheduler.instance.invalidateOnNextAnimationFrame(reader);
    }
    return _value.getValue(nowMs);
  }

  bool isFinished(IReader? reader) {
    final int nowMs = animatedValueDateNow();
    final bool finished = _value.isFinished(nowMs);
    if (!finished) {
      AnimationFrameScheduler.instance.invalidateOnNextAnimationFrame(reader);
    }
    return finished;
  }
}

/// 1:1: `class AnimationFrameScheduler`
class AnimationFrameScheduler {
  static final AnimationFrameScheduler instance = AnimationFrameScheduler();

  late final IObservableSignal<void> _counter;

  bool _isScheduled = false;

  AnimationFrameScheduler() {
    _counter = observableSignal<void>(this);
  }

  void invalidateOnNextAnimationFrame(IReader? reader) {
    _counter.read(reader);
    if (!_isScheduled) {
      _isScheduled = true;
      windowCarrier(getActiveWindow()).requestAnimationFrame(() {
        _isScheduled = false;
        _update();
      });
    }
  }

  void _update() => _counter.trigger(null, null);
}
