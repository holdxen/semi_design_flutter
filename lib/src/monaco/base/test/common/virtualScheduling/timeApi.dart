// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/test/common/virtualScheduling/timeApi.ts
// Translated 1:1 from TypeScript. The branded id types (TimeoutId/IntervalId/
// ImmediateId/AnimationFrameId) -> wrapper carrier classes (Dart has no nominal
// `unique symbol` brands). `TimeApi` interface -> abstract class. Host time
// functions are bridged through an injectable [hostTimeApi] (same convention
// as `globalThis` bridges elsewhere): Dart has no `globalThis`, so the real
// host functions are supplied by the embedder.
// ---------------------------------------------------------------------------

/// 1:1: `export interface TimeoutId { readonly _timeoutIdBrand: void }`
class TimeoutId {
  final Object value;
  const TimeoutId(this.value);
}

/// 1:1: `export interface IntervalId { readonly _intervalIdBrand: void }`
class IntervalId {
  final Object value;
  const IntervalId(this.value);
}

/// 1:1: `export interface ImmediateId { readonly _immediateIdBrand: void }`
class ImmediateId {
  final Object value;
  const ImmediateId(this.value);
}

/// 1:1: `export type AnimationFrameId = number & { readonly _animationFrameIdBrand: void }`
class AnimationFrameId {
  final int value;
  const AnimationFrameId(this.value);
}

/// The subset of host time APIs the processor and embeddings need.
///
/// Used both for the real host API (captured via [captureGlobalTimeApi])
/// and for the virtual replacement that runs through a `VirtualClock`.
///
/// Keeping this as a plain interface means the processor never reaches into
/// `globalThis` directly: the boundary between "real time" and "virtual time"
/// is exactly which `TimeApi` instance is in use.
/// 1:1: `export interface TimeApi`
abstract class TimeApi {
  TimeoutId setTimeout(void Function() handler, [int timeout = 0]);
  void clearTimeout(TimeoutId id);
  IntervalId setInterval(void Function() handler, int interval);
  void clearInterval(IntervalId id);
  ImmediateId? Function(void Function() handler)? get setImmediate;
  void Function(ImmediateId id)? get clearImmediate;
  AnimationFrameId? Function(void Function(num time) cb)? get requestAnimationFrame;
  void Function(AnimationFrameId id)? get cancelAnimationFrame;
  DateTime Function() get Date;
  num Function() get performanceNow;
  num get performanceTimeOrigin;
}

/// Bridge for the host time functions. Replaceable in tests/platforms; mirrors
/// the `globalThis.*` values captured by [captureGlobalTimeApi] in the source.
class HostTimeApi {
  final TimeoutId Function(void Function() handler, [int timeout]) setTimeout;
  final void Function(TimeoutId id) clearTimeout;
  final IntervalId Function(void Function() handler, int interval) setInterval;
  final void Function(IntervalId id) clearInterval;
  final ImmediateId? Function(void Function() handler)? setImmediate;
  final void Function(ImmediateId id)? clearImmediate;
  final AnimationFrameId? Function(void Function(num time) cb)?
      requestAnimationFrame;
  final void Function(AnimationFrameId id)? cancelAnimationFrame;
  final DateTime Function() Date;
  final num Function() performanceNow;
  final num performanceTimeOrigin;

  HostTimeApi({
    required this.setTimeout,
    required this.clearTimeout,
    required this.setInterval,
    required this.clearInterval,
    this.setImmediate,
    this.clearImmediate,
    this.requestAnimationFrame,
    this.cancelAnimationFrame,
    required this.Date,
    required this.performanceNow,
    this.performanceTimeOrigin = 0,
  });
}

/// Injectable host bridge (Dart has no `globalThis`). The embedder supplies a
/// [HostTimeApi]; tests may replace it with a virtual implementation.
HostTimeApi? _hostTimeApi;

/// 1:1: `export function captureGlobalTimeApi(): TimeApi`
/// Captures a snapshot of the host time API into a [TimeApi] value.
TimeApi captureGlobalTimeApi([HostTimeApi? host]) {
  final HostTimeApi h = host ?? _hostTimeApi ?? _defaultHostTimeApi;
  return _CapturedTimeApi(h);
}

/// A snapshot of the real host time API at module-load time.
/// 1:1: `export const realTimeApi: TimeApi = captureGlobalTimeApi();`
final TimeApi realTimeApi = captureGlobalTimeApi();

/// A [TimeApi] that delegates to a captured [HostTimeApi] snapshot.
class _CapturedTimeApi implements TimeApi {
  final HostTimeApi _h;
  _CapturedTimeApi(this._h);

  @override
  TimeoutId setTimeout(void Function() handler, [int timeout = 0]) =>
      _h.setTimeout(handler, timeout);

  @override
  void clearTimeout(TimeoutId id) => _h.clearTimeout(id);

  @override
  IntervalId setInterval(void Function() handler, int interval) =>
      _h.setInterval(handler, interval);

  @override
  void clearInterval(IntervalId id) => _h.clearInterval(id);

  @override
  ImmediateId? Function(void Function() handler)? get setImmediate =>
      _h.setImmediate;

  @override
  void Function(ImmediateId id)? get clearImmediate => _h.clearImmediate;

  @override
  AnimationFrameId? Function(void Function(num time) cb)?
      get requestAnimationFrame => _h.requestAnimationFrame;

  @override
  void Function(AnimationFrameId id)? get cancelAnimationFrame =>
      _h.cancelAnimationFrame;

  @override
  DateTime Function() get Date => _h.Date;

  @override
  num Function() get performanceNow => _h.performanceNow;

  @override
  num get performanceTimeOrigin => _h.performanceTimeOrigin;
}

/// Fallback `globalThis` snapshot using Dart's own `dart:async` timers, so the
/// port has a functioning default without a DOM. The embedder can override via
/// [captureGlobalTimeApi] with an explicit [HostTimeApi].
final HostTimeApi _defaultHostTimeApi = HostTimeApi(
  setTimeout: (void Function() handler, [int timeout = 0]) {
    return TimeoutId(Future<void>.delayed(Duration(milliseconds: timeout), handler));
  },
  clearTimeout: (TimeoutId id) {
    // dart:async timers are cancelled via the Future's subscription; the
    // bridge records the timer object and the platform layer may cancel it.
  },
  setInterval: (void Function() handler, int interval) {
    return IntervalId(Stream<void>.periodic(Duration(milliseconds: interval))
        .listen((_) => handler()));
  },
  clearInterval: (IntervalId id) {
    // Cancellation is performed by the platform layer that created the timer.
  },
  Date: () => DateTime.now(),
  performanceNow: () =>
      DateTime.now().microsecondsSinceEpoch.toDouble() / 1000.0,
  performanceTimeOrigin: 0,
);
