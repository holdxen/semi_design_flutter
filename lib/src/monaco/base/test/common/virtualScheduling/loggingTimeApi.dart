// 1:1 port of vs/base/test/common/virtualScheduling/loggingTimeApi.ts
//
// Dart has no `new Error().stack`, so the stack argument passed to [onCall] is
// an opaque string supplied by the embedder (null when unavailable). The
// wrapped [TimeApi] is an implementing class over the underlying api.

import 'timeApi.dart'
    show
        AnimationFrameId,
        ImmediateId,
        IntervalId,
        TimeApi,
        TimeoutId;

/// Signature of the `onCall` diagnostic callback.
/// 1:1: `(name: string, stack: string | undefined, handler?: () => void) => void`
typedef LoggingOnCall = void Function(
  String name,
  String? stack, [
  Object? handler,
]);

/// Stack provider for the `new Error().stack` diagnostic. The embedder can
/// replace this; by default no stack is captured (null).
String? Function() debugStackProvider = () => null;

/// 1:1: `export function createLoggingTimeApi`
TimeApi createLoggingTimeApi(TimeApi underlying, LoggingOnCall onCall) =>
    _LoggingTimeApi(underlying, onCall);

class _LoggingTimeApi implements TimeApi {
  final TimeApi _underlying;
  final LoggingOnCall _onCall;

  _LoggingTimeApi(this._underlying, this._onCall);

  @override
  TimeoutId setTimeout(void Function() handler, [int timeout = 0]) {
    _onCall('setTimeout', debugStackProvider(), handler);
    return _underlying.setTimeout(handler, timeout);
  }

  @override
  void clearTimeout(TimeoutId id) => _underlying.clearTimeout(id);

  @override
  IntervalId setInterval(void Function() handler, int interval) {
    _onCall('setInterval', debugStackProvider(), handler);
    return _underlying.setInterval(handler, interval);
  }

  @override
  void clearInterval(IntervalId id) => _underlying.clearInterval(id);

  @override
  ImmediateId? Function(void Function() handler)? get setImmediate {
    final ImmediateId? Function(void Function() handler)? underlying = _underlying.setImmediate;
    if (underlying == null) {
      return null;
    }
    return (void Function() handler) {
      _onCall('setImmediate', debugStackProvider(), handler);
      return underlying(handler);
    };
  }

  @override
  void Function(ImmediateId id)? get clearImmediate => _underlying.clearImmediate;

  @override
  AnimationFrameId? Function(void Function(num time) cb)? get requestAnimationFrame {
    final AnimationFrameId? Function(void Function(num time) cb)? underlying =
        _underlying.requestAnimationFrame;
    if (underlying == null) {
      return null;
    }
    return (void Function(num time) cb) {
      _onCall('requestAnimationFrame', debugStackProvider(), cb);
      return underlying(cb);
    };
  }

  @override
  void Function(AnimationFrameId id)? get cancelAnimationFrame =>
      _underlying.cancelAnimationFrame;

  @override
  DateTime Function() get Date => _underlying.Date;

  @override
  num Function() get performanceNow => _underlying.performanceNow;

  @override
  num get performanceTimeOrigin => _underlying.performanceTimeOrigin;
}
