// 1:1 port of vscode/src/vs/base/test/common/virtualScheduling/runWithFakedTimers.ts
// Promise -> Future; global time API swap -> pushGlobalTimeApi bridge already
// ported. `try/finally` + `didThrow` control flow preserved verbatim so that a
// throwing `fn` never drains the virtual queue and never surfaces a rejection
// from disposal.

import '../../../common/cancellation.dart' show CancellationTokenSource;
import '../../../common/lifecycle.dart' show IDisposable;
import 'embedding.dart' show drainMicrotasksEmbedding;
import 'globalTimeApi.dart' show pushGlobalTimeApi;
import 'processor.dart'
    show
        RunOptions,
        VirtualTimeProcessor,
        VirtualTimeProcessorOptions,
        untilToken;
import 'recordingTimeApi.dart'
    show
        RecordedTimerEvent,
        RecordedTimerEventValue,
        createRecordingRealTimeApi;
import 'timeApi.dart' show TimeApi, realTimeApi;
import 'virtualClock.dart' show VirtualClock;
import 'virtualTimeApi.dart' show createVirtualTimeApi;

/// 1:1: `interface RunWithFakedTimersOptions`
class RunWithFakedTimersOptions {
  final int? startTime;
  /// Default `true`. Set `false` to bypass virtual time entirely.
  final bool? useFakeTimers;
  /// No effect in the new processor; accepted for legacy compatibility.
  final bool? useSetImmediate;
  /// Maximum number of virtual events before the run is rejected. Default 100.
  final int? maxTaskCount;
  /// If set, called once `fn` resolves with the recorded timer events.
  final void Function(List<RecordedTimerEvent>)? onHistory;

  const RunWithFakedTimersOptions({
    this.startTime,
    this.useFakeTimers,
    this.useSetImmediate,
    this.maxTaskCount,
    this.onHistory,
  });
}

/// Run `fn` with a virtual clock installed as the global time API.
///
/// 1:1: `export async function runWithFakedTimers<T>(options, fn): Promise<T>`
Future<T> runWithFakedTimers<T>(
  RunWithFakedTimersOptions options,
  Future<T> Function() fn,
) async {
  final bool useFakeTimers = options.useFakeTimers != false;
  if (!useFakeTimers) {
    if (options.onHistory == null) {
      return fn();
    }
    final List<RecordedTimerEvent> history = <RecordedTimerEvent>[];
    final IDisposable restore =
        pushGlobalTimeApi(createRecordingRealTimeApi(history));
    try {
      return await fn();
    } finally {
      restore.dispose();
      options.onHistory!(history);
    }
  }

  final VirtualClock clock = VirtualClock(options.startTime ?? 0);
  final TimeApi virtualApi = createVirtualTimeApi(clock);
  final IDisposable restoreGlobals = pushGlobalTimeApi(virtualApi);
  final VirtualTimeProcessor processor = VirtualTimeProcessor(
    clock,
    drainMicrotasksEmbedding(realTimeApi),
    realTimeApi,
    VirtualTimeProcessorOptions(
      defaultMaxEvents: options.maxTaskCount ?? 100,
    ),
  );

  final CancellationTokenSource cts = CancellationTokenSource();
  final Future<void> runPromise = processor.run(
    RunOptions(until: untilToken(cts.token)),
  );

  bool didThrow = true;
  late T result;
  try {
    result = await fn();
    didThrow = false;
  } finally {
    // Stop intercepting real-time scheduling before draining.
    restoreGlobals.dispose();
    cts.cancel();

    try {
      if (!didThrow) {
        await runPromise;
      } else {
        // Avoid an unhandled rejection in case disposal rejects the run.
        runPromise.catchError((Object _) {});
      }
    } finally {
      cts.dispose();
      final void Function(List<RecordedTimerEvent>)? onHistory =
          options.onHistory;
      // `processor.history` is `readonly VirtualEvent[]`; the source passes it
      // directly to the `readonly RecordedTimerEvent[]` callback (structural
      // typing). Bridge by projecting the overlapping fields into carriers.
      final List<RecordedTimerEvent> history = processor.history
          .map((dynamic e) => RecordedTimerEventValue(
                time: e.time as num,
                source: e.source,
                trace: e.trace,
              ))
          .toList();
      onHistory?.call(history);
      processor.dispose();
    }
  }

  return result;
}
