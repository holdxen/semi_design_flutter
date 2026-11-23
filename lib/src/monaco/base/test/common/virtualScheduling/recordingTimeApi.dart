// 1:1 port of vs/base/test/common/virtualScheduling/recordingTimeApi.ts
//
// Dart has no `new Error().stack`, so the captured stack is carried as an opaque
// string from [debugStackProvider] (loggingTimeApi.dart). The `Date.now()` call
// maps to `DateTime.now().millisecondsSinceEpoch`. The optional host functions
// are read via the [TimeApi] getters.

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
import 'virtualClock.dart' show EventSource;

/// 1:1: `export interface RecordedTimerEvent`
abstract class RecordedTimerEvent {
  num get time;
  EventSource get source;
  Trace? get trace;
}

/// Value carrier for [RecordedTimerEvent].
class RecordedTimerEventValue implements RecordedTimerEvent {
  @override
  final num time;
  @override
  final EventSource source;
  @override
  final Trace? trace;

  RecordedTimerEventValue({
    required this.time,
    required this.source,
    required this.trace,
  });
}

/// Debug source carrying the label and the captured stack text.
class _RecordedSource implements EventSource {
  final String label;
  @override
  final String? stackTrace;
  _RecordedSource(this.label, this.stackTrace);
  @override
  String toString() => label;
}

Object? _stackArg() {
  final String? s = debugStackProvider();
  return s == null ? null : CapturedStack(s);
}

/// 1:1: `export function createRecordingRealTimeApi(history): TimeApi`
TimeApi createRecordingRealTimeApi(List<RecordedTimerEvent> history) {
  final TimeoutId Function(void Function(), [int]) realSetTimeout =
      realTimeApi.setTimeout;

  void record(String label, String? stack, Trace trace) {
    history.add(RecordedTimerEventValue(
      time: DateTime.now().millisecondsSinceEpoch,
      source: _RecordedSource(label, stack),
      trace: trace,
    ));
  }

  void runAsHandlerReal(Trace trace, void Function() handler) {
    TraceContext.instance.runAsHandler<void>(trace, handler, (void Function() cb) {
      realSetTimeout(cb, 0);
    });
  }

  ImmediateId? Function(void Function())? makeImmediate() {
    final ImmediateId? Function(void Function())? hostImmediate =
        realTimeApi.setImmediate;
    if (hostImmediate == null) {
      return null;
    }
    return (void Function() handler) {
      final stack = debugStackProvider();
      final trace = TraceContext.instance
          .currentTrace()
          .child('setImmediate', _stackArg());
      return hostImmediate(() {
        record('setImmediate', stack, trace);
        runAsHandlerReal(trace, handler);
      });
    };
  }

  AnimationFrameId? Function(void Function(num time))? makeAnimationFrame() {
    final AnimationFrameId? Function(void Function(num time))? hostRaf =
        realTimeApi.requestAnimationFrame;
    if (hostRaf == null) {
      return null;
    }
    return (void Function(num time) cb) {
      final stack = debugStackProvider();
      final trace = TraceContext.instance
          .currentTrace()
          .child('requestAnimationFrame', _stackArg());
      return hostRaf((t) {
        record('requestAnimationFrame', stack, trace);
        runAsHandlerReal(trace, () => cb(t));
      });
    };
  }

  return _RecordingTimeApi(
    history: history,
    realSetTimeout: realSetTimeout,
    record: record,
    runAsHandlerReal: runAsHandlerReal,
    setImmediateFn: makeImmediate(),
    requestAnimationFrameFn: makeAnimationFrame(),
  );
}

class _RecordingTimeApi implements TimeApi {
  final TimeoutId Function(void Function(), [int]) realSetTimeout;
  final void Function(String, String?, Trace) record;
  final void Function(Trace, void Function()) runAsHandlerReal;

  _RecordingTimeApi({
    required List<RecordedTimerEvent> history,
    required this.realSetTimeout,
    required this.record,
    required this.runAsHandlerReal,
    required ImmediateId? Function(void Function())? setImmediateFn,
    required AnimationFrameId? Function(void Function(num time))?
        requestAnimationFrameFn,
  })  : _setImmediateFn = setImmediateFn,
        _requestAnimationFrameFn = requestAnimationFrameFn;

  final ImmediateId? Function(void Function())? _setImmediateFn;
  final AnimationFrameId? Function(void Function(num time))?
      _requestAnimationFrameFn;

  @override
  TimeoutId setTimeout(void Function() handler, [int ms = 0]) {
    final stack = debugStackProvider();
    final trace = TraceContext.instance
        .currentTrace()
        .child('setTimeout(${ms}ms)', _stackArg());
    return realSetTimeout(() {
      record('setTimeout', stack, trace);
      runAsHandlerReal(trace, handler);
    }, ms);
  }

  @override
  void clearTimeout(TimeoutId id) => realTimeApi.clearTimeout(id);

  @override
  IntervalId setInterval(void Function() handler, int ms) {
    final stack = debugStackProvider();
    final Trace baseTrace = TraceContext.instance
        .currentTrace()
        .child('setInterval(${ms}ms)', _stackArg());
    int iter = 0;
    return realTimeApi.setInterval(() {
      iter++;
      final tickTrace = baseTrace.child('tick #$iter');
      record('setInterval (iteration $iter)', stack, tickTrace);
      runAsHandlerReal(tickTrace, handler);
    }, ms);
  }

  @override
  void clearInterval(IntervalId id) => realTimeApi.clearInterval(id);

  @override
  ImmediateId? Function(void Function() handler)? get setImmediate =>
      _setImmediateFn;

  @override
  void Function(ImmediateId id)? get clearImmediate =>
      realTimeApi.clearImmediate;

  @override
  AnimationFrameId? Function(void Function(num time) cb)?
      get requestAnimationFrame => _requestAnimationFrameFn;

  @override
  void Function(AnimationFrameId id)? get cancelAnimationFrame =>
      realTimeApi.cancelAnimationFrame;

  @override
  DateTime Function() get Date => realTimeApi.Date;

  @override
  num Function() get performanceNow => realTimeApi.performanceNow;

  @override
  num get performanceTimeOrigin => realTimeApi.performanceTimeOrigin;
}
