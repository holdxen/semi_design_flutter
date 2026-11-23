// 1:1 port of vs/base/test/common/virtualScheduling/virtualTimeApi.ts
//
// Dart has no `new Error().stack`, so stacks come from the shared
// [debugStackProvider] (loggingTimeApi.dart) and are carried as [CapturedStack]
// when handed to `Trace.child`. The JS `Date` exotic object (callable + `new`
// + statics) is represented by [VirtualDateFn]; installed as [TimeApi.Date] via
// a zero-arg closure. Virtual timer ids are the `IDisposable`s returned by
// `VirtualClock.schedule`, wrapped in the branded [TimeoutId]/[IntervalId].

import '../../../common/lifecycle.dart' show IDisposable, toDisposable;
import 'globalTimeApi.dart' show SetTimeoutFn, wrapSetTimeout;
import 'loggingTimeApi.dart' show debugStackProvider;
import 'timeApi.dart'
    show
        AnimationFrameId,
        ImmediateId,
        IntervalId,
        TimeApi,
        TimeoutId,
        realTimeApi;
import 'trace.dart' show CapturedStack, Trace, TraceContext;
import 'virtualClock.dart'
    show EventSource, VirtualClock, VirtualEvent;

export 'globalTimeApi.dart' show pushGlobalTimeApi;

/// 1:1: `function asDisposable(id: unknown): IDisposable | undefined`
/// In the Dart port the branded timer ids wrap the scheduled [IDisposable] as
/// their [TimeoutId.value]/[IntervalId.value], so unwrap before checking.
IDisposable? asDisposable(Object? id) {
  if (id == null) {
    return null;
  }
  final Object candidate = id is TimeoutId
      ? id.value
      : (id is IntervalId ? id.value : id);
  return candidate is IDisposable ? candidate : null;
}

/// 1:1: `export interface CreateVirtualTimeApiOptions`
abstract class CreateVirtualTimeApiOptions {
  bool get fakeRequestAnimationFrame;
}

/// Value carrier for [CreateVirtualTimeApiOptions].
class VirtualTimeApiOptions implements CreateVirtualTimeApiOptions {
  @override
  final bool fakeRequestAnimationFrame;
  VirtualTimeApiOptions({this.fakeRequestAnimationFrame = false});
}

/// The faux `Date` callable + statics. 1:1: `VirtualDate`.
class VirtualDateFn {
  final VirtualClock _clock;
  final DateTime Function() _originalDate;

  VirtualDateFn(this._clock, this._originalDate);

  /// 1:1: zero-arg call → `new OriginalDate(clock.now)`.
  DateTime call([List<Object?> args = const []]) {
    if (args.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(_clock.now as int);
    }
    // Host bridge exposes only a zero-arg factory; forward as closest carrier.
    return _originalDate();
  }

  /// 1:1: `dateStatics.now = () => clock.now`
  int now() => _clock.now as int;

  /// 1:1: `dateStatics.parse = OriginalDate.parse`
  DateTime parse(String s) => DateTime.parse(s);

  /// 1:1: `dateStatics.UTC = OriginalDate.UTC`
  DateTime utc(int year, [int month = 1, int day = 1, int hour = 0,
      int minute = 0, int second = 0, int ms = 0]) =>
      DateTime.utc(year, month, day, hour, minute, second, ms);
}

/// 1:1: `export function createVirtualTimeApi(clock, options?): TimeApi`
TimeApi createVirtualTimeApi(
  VirtualClock clock, [
  CreateVirtualTimeApiOptions? options,
]) {
  final num performanceTimeOrigin = clock.now;

  Object? stackArg() {
    final String? s = debugStackProvider();
    return s == null ? null : CapturedStack(s);
  }

  TimeoutId virtualSetTimeout(void Function() handler, [int timeout = 0]) {
    final stack = stackArg();
    final Trace trace = TraceContext.instance
        .currentTrace()
        .child('setTimeout(${timeout}ms)', stack);
    final IDisposable d = clock.schedule(_VirtualEvent(
      time: clock.now + timeout,
      run: handler,
      source: _LabelSource('setTimeout', debugStackProvider()),
      trace: trace,
    ));
    return TimeoutId(d);
  }

  void virtualClearTimeout(Object? id) => asDisposable(id)?.dispose();

  IntervalId virtualSetInterval(void Function() handler, int interval) {
    final stack = stackArg();
    final Trace baseTrace = TraceContext.instance
        .currentTrace()
        .child('setInterval(${interval}ms)', stack);
    int iter = 0;
    bool disposed = false;
    late IDisposable lastDisposable;

    void arm() {
      iter++;
      final int myIter = iter;
      lastDisposable = clock.schedule(_VirtualEvent(
        time: clock.now + interval,
        run: () {
          if (disposed) {
            return;
          }
          arm(); // schedule next tick first, so a throwing handler doesn't kill it
          handler();
        },
        source: _LabelSource('setInterval (iteration $myIter)', debugStackProvider()),
        trace: baseTrace.child('tick #$myIter'),
      ));
    }

    arm();
    return IntervalId(toDisposable(() {
      if (disposed) {
        return;
      }
      disposed = true;
      lastDisposable.dispose();
    }));
  }

  void virtualClearInterval(Object? id) => asDisposable(id)?.dispose();

  final VirtualDateFn virtualDate =
      VirtualDateFn(clock, realTimeApi.Date);
  final DateTime Function() dateFn = () => virtualDate.call();

  final _VirtualTimeApi api = _VirtualTimeApi(
    setTimeout: virtualSetTimeout,
    clearTimeout: virtualClearTimeout,
    setInterval: virtualSetInterval,
    clearInterval: virtualClearInterval,
    Date: dateFn,
    performanceNow: () => clock.now - performanceTimeOrigin,
    performanceTimeOrigin: performanceTimeOrigin,
  );

  // Expose the real setTimeout as `originalFn` back-door.
  final SetTimeoutFn setTimeoutFn = wrapSetTimeout((
    void Function() handler, [
    int timeout = 0,
  ]) =>
      virtualSetTimeout(handler, timeout));
  setTimeoutFn.originalFn = wrapSetTimeout((void Function() handler,
          [int timeout = 0]) =>
      realTimeApi.setTimeout(handler, timeout));
  api.virtualDate = virtualDate;
  api.setTimeoutFn = setTimeoutFn;

  if (options?.fakeRequestAnimationFrame == true) {
    int rafIdCounter = 0;
    final Map<int, IDisposable> rafDisposables = <int, IDisposable>{};

    api.requestAnimationFrameImpl =
        (void Function(num time) callback) {
      final int id = ++rafIdCounter;
      final stack = stackArg();
      final Trace trace = TraceContext.instance
          .currentTrace()
          .child('requestAnimationFrame', stack);
      final IDisposable d = clock.schedule(_VirtualEvent(
        time: clock.now + 16,
        preferRealAnimationFrame: true,
        run: () {
          rafDisposables.remove(id);
          callback(api.performanceNow());
        },
        source: _LabelSource('requestAnimationFrame', debugStackProvider()),
        trace: trace,
      ));
      rafDisposables[id] = d;
      return AnimationFrameId(id);
    };

    api.cancelAnimationFrameImpl = (AnimationFrameId id) {
      final IDisposable? d = rafDisposables[id.value];
      if (d != null) {
        d.dispose();
        rafDisposables.remove(id.value);
      }
    };
  }

  // Source has `void ROOT_TRACE;` (trace defaults safety net for callers
  // stepping the clock manually). Dart needs no tree-shaking guard; ROOT_TRACE
  // is documented here via the import above.
  return api;
}

/// Event object literal passed to [VirtualClock.schedule]:
/// `{ time, run, source, trace?, preferRealAnimationFrame? }`.
class _VirtualEvent implements VirtualEvent {
  @override
  final num time;
  final void Function() runFn;
  @override
  final EventSource source;
  @override
  final Trace? trace;
  @override
  final bool preferRealAnimationFrame;

  _VirtualEvent({
    required this.time,
    required void Function() run,
    required this.source,
    required this.trace,
    this.preferRealAnimationFrame = false,
  }) : runFn = run;

  @override
  void run() => runFn();
}

/// Debug source: `{ toString: () => label, get stackTrace() { return stack; } }`.
class _LabelSource implements EventSource {
  final String label;
  @override
  final String? stackTrace;
  _LabelSource(this.label, this.stackTrace);
  @override
  String toString() => label;
}

/// Concrete [TimeApi] for virtual time. Optional rAF slots plus the diagnostic
/// [virtualDate]/[setTimeoutFn] carriers are exposed as mutable fields.
class _VirtualTimeApi implements TimeApi {
  final TimeoutId Function(void Function(), [int]) _setTimeout;
  final void Function(Object?) _clearTimeout;
  final IntervalId Function(void Function(), int) _setInterval;
  final void Function(Object?) _clearInterval;
  final DateTime Function() _date;
  final num Function() _performanceNow;
  @override
  final num performanceTimeOrigin;

  AnimationFrameId? Function(void Function(num time) cb)?
      requestAnimationFrameImpl;
  void Function(AnimationFrameId id)? cancelAnimationFrameImpl;
  VirtualDateFn? virtualDate;
  SetTimeoutFn? setTimeoutFn;

  _VirtualTimeApi({
    required TimeoutId Function(void Function(), [int]) setTimeout,
    required void Function(Object?) clearTimeout,
    required IntervalId Function(void Function(), int) setInterval,
    required void Function(Object?) clearInterval,
    required DateTime Function() Date,
    required num Function() performanceNow,
    required this.performanceTimeOrigin,
  })  : _setTimeout = setTimeout,
        _clearTimeout = clearTimeout,
        _setInterval = setInterval,
        _clearInterval = clearInterval,
        _date = Date,
        _performanceNow = performanceNow;

  @override
  TimeoutId setTimeout(void Function() handler, [int timeout = 0]) =>
      _setTimeout(handler, timeout);

  @override
  void clearTimeout(TimeoutId id) => _clearTimeout(id);

  @override
  IntervalId setInterval(void Function() handler, int interval) =>
      _setInterval(handler, interval);

  @override
  void clearInterval(IntervalId id) => _clearInterval(id);

  @override
  ImmediateId? Function(void Function() handler)? get setImmediate => null;

  @override
  void Function(ImmediateId id)? get clearImmediate => null;

  @override
  AnimationFrameId? Function(void Function(num time) cb)?
      get requestAnimationFrame => requestAnimationFrameImpl;

  @override
  void Function(AnimationFrameId id)? get cancelAnimationFrame =>
      cancelAnimationFrameImpl;

  @override
  DateTime Function() get Date => _date;

  @override
  num Function() get performanceNow => _performanceNow;
}
