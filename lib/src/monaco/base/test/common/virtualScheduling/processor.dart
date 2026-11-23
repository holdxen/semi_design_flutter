// 1:1 translation of
// vscode/src/vs/base/test/common/virtualScheduling/processor.ts

import 'dart:async';

import '../../../common/cancellation.dart' show CancellationToken;
import '../../../common/lifecycle.dart'
    show Disposable, DisposableStore, IDisposable, toDisposable;
import 'embedding.dart' show Embedding, nextMacrotask;
import 'timeApi.dart' show TimeApi;
import 'trace.dart' show ROOT_TRACE, Trace, TraceContext;
import 'virtualClock.dart'
    show EventSource, VirtualClock, VirtualEvent, VirtualTime;

// ============================================================================
// Termination policy
// ============================================================================

/// 1:1: `export type TerminationPolicy`
/// Tagged union carried as a class with a `kind` discriminator.
class TerminationPolicy {
  final String kind; // 'idle' | 'token' | 'time'
  final CancellationToken? token;
  final VirtualTime? time;

  const TerminationPolicy._(this.kind, this.token, this.time);

  /// 1:1: `export const untilIdle: TerminationPolicy = { kind: 'idle' }`
  static const TerminationPolicy untilIdle =
      TerminationPolicy._('idle', null, null);

  /// 1:1: `export function untilToken(token): TerminationPolicy`
  factory TerminationPolicy.untilToken(CancellationToken token) =>
      TerminationPolicy._('token', token, null);

  /// 1:1: `export function untilTime(time): TerminationPolicy`
  factory TerminationPolicy.untilTime(VirtualTime time) =>
      TerminationPolicy._('time', null, time);
}

/// 1:1: `export const untilIdle`
final TerminationPolicy untilIdle = TerminationPolicy.untilIdle;

/// 1:1: `export function untilToken(token)`
TerminationPolicy untilToken(CancellationToken token) =>
    TerminationPolicy.untilToken(token);

/// 1:1: `export function untilTime(time)`
TerminationPolicy untilTime(VirtualTime time) =>
    TerminationPolicy.untilTime(time);

/// 1:1: `export interface RunOptions`
class RunOptions {
  final TerminationPolicy until;
  /// Maximum number of virtual events this run will execute. Default: 100.
  final int? maxEvents;
  /// Maximum causal-trace depth this run will tolerate.
  final int? maxTraceDepth;

  RunOptions({
    required this.until,
    this.maxEvents,
    this.maxTraceDepth,
  });
}

// ============================================================================
// Run — internal state for a single processor.run() invocation
// ============================================================================

/// 1:1: `type RunStatus = 'continue' | 'done' | { readonly error: Error }`
class RunStatus {
  final String? kind; // 'continue' | 'done' when [error] == null
  final Object? error;

  const RunStatus._(this.kind, this.error);

  static const RunStatus cont = RunStatus._('continue', null);
  static const RunStatus done = RunStatus._('done', null);
  static RunStatus failed(Object error) => RunStatus._(null, error);

  bool get isDone => identical(this, done);
}

/// 1:1: internal `class Run`
class Run {
  static int _idCounter = 0;
  final int id = ++_idCounter;

  late final Future<void> promise;
  Completer<void>? _completer;
  bool _settled = false;
  bool get settled => _settled;

  final RunOptions options;
  final int executedAtStart;
  final int maxEvents;

  Run(this.options, this.executedAtStart, this.maxEvents) {
    final Completer<void> c = Completer<void>();
    _completer = c;
    promise = c.future;
  }

  /// 1:1: `settle(error?: Error): void`
  void settle([Object? error]) {
    if (_settled) {
      return;
    }
    _settled = true;
    final Completer<void> c = _completer!;
    if (error != null) {
      c.completeError(error);
    } else {
      c.complete();
    }
  }

  /// 1:1: `evaluate(clock, executedTotal, makeOverflow): RunStatus`
  RunStatus evaluate(
    VirtualClock clock,
    int executedTotal,
    Object Function() makeOverflow,
  ) {
    final int local = executedTotal - executedAtStart;
    if (local >= maxEvents && clock.hasEvents) {
      return RunStatus.failed(makeOverflow());
    }

    final TerminationPolicy u = options.until;
    switch (u.kind) {
      case 'idle':
        return clock.hasEvents ? RunStatus.cont : RunStatus.done;
      case 'token':
        return (u.token!.isCancellationRequested && !clock.hasEvents)
            ? RunStatus.done
            : RunStatus.cont;
      case 'time':
        // Done iff every remaining event is strictly past the deadline.
        final VirtualEvent? next = clock.peekNext();
        return (next == null || next.time > u.time!)
            ? RunStatus.done
            : RunStatus.cont;
      default:
        return RunStatus.cont;
    }
  }
}

// ============================================================================
// Step outcome
// ============================================================================

/// 1:1: `type StepOutcome = 'progress' | 'park' | 'quiesce'`
class StepOutcome {
  final String value;
  const StepOutcome._(this.value);

  static const StepOutcome progress = StepOutcome._('progress');
  static const StepOutcome park = StepOutcome._('park');
  static const StepOutcome quiesce = StepOutcome._('quiesce');
}

/// 1:1: `export interface VirtualTimeProcessorOptions`
class VirtualTimeProcessorOptions {
  final int? defaultMaxEvents;
  const VirtualTimeProcessorOptions({this.defaultMaxEvents});
}

/// Carrier implementing `EventSource` with a custom `toString()` — used for
/// the deadline sentinel (`{ toString: () => '<deadline of run #N>' }`).
class _DeadlineEventSource implements EventSource {
  final String label;
  _DeadlineEventSource(this.label);

  @override
  String toString() => label;

  @override
  String? get stackTrace => null;
}

/// 1:1: `export class VirtualTimeProcessor extends Disposable`
class VirtualTimeProcessor extends Disposable {
  final Map<Run, IDisposable> _runs = <Run, IDisposable>{};
  final List<VirtualEvent> _history = <VirtualEvent>[];
  int _executedTotal = 0;
  bool _disposed = false;

  bool _inDrive = false;
  IDisposable? _parkCleanup;

  final int _defaultMaxEvents;

  final VirtualClock _clock;
  final Embedding _embedding;
  final TimeApi _realApi;

  /// 1:1: `public get history(): readonly VirtualEvent[]`
  List<VirtualEvent> get history => List<VirtualEvent>.unmodifiable(_history);

  /// 1:1: `public get executedTotal(): number`
  int get executedTotal => _executedTotal;

  VirtualTimeProcessor(
    this._clock,
    this._embedding,
    this._realApi, [
    VirtualTimeProcessorOptions opts = const VirtualTimeProcessorOptions(),
  ])  : _defaultMaxEvents = opts.defaultMaxEvents ?? 100,
        super() {
    register(toDisposable(() => _onDispose()));
  }

  // ---- Public API -----------------------------------------------------

  /// 1:1: `run(options: RunOptions): Promise<void>`
  Future<void> run(RunOptions options) {
    final Run run = Run(
      options,
      _executedTotal,
      options.maxEvents ?? _defaultMaxEvents,
    );
    final DisposableStore cleanup = DisposableStore();

    // Wake the loop on token cancellation so the run can re-evaluate.
    if (options.until.kind == 'token') {
      cleanup.add(
        options.until.token!.onCancellationRequested((Object? _) => _wake()),
      );
    }

    // For time-based termination, schedule a sentinel event at the deadline.
    if (options.until.kind == 'time' &&
        options.until.time! > _clock.now) {
      final EventSource source =
          _DeadlineEventSource('<deadline of run #${run.id}>');
      cleanup.add(_clock.schedule(_SentinelEvent(
        time: options.until.time!,
        source: source,
      )));
    }

    _runs[run] = cleanup;
    _wake();
    return run.promise;
  }

  // ---- The pure step --------------------------------------------------

  /// 1:1: `private _step(): StepOutcome`
  StepOutcome _step() {
    if (_disposed) {
      return StepOutcome.quiesce;
    }

    _settleFinishedRuns();
    if (_runs.isEmpty) {
      return StepOutcome.quiesce;
    }

    final VirtualEvent? next = _clock.peekNext();
    if (next == null) {
      return StepOutcome.park;
    }

    // Per-run trace-depth check: reject any run whose limit this event
    // would exceed, before executing.
    final int traceDepth = next.trace?.depth ?? 0;
    bool depthOverflow = false;
    for (final Run run in _runs.keys.toList()) {
      final int? limit = run.options.maxTraceDepth;
      if (limit != null && traceDepth > limit) {
        _settleRun(run, _buildDepthOverflow(run, traceDepth));
        depthOverflow = true;
      }
    }
    if (depthOverflow) {
      return StepOutcome.progress;
    }

    _executeOne(next);
    return StepOutcome.progress;
  }

  /// 1:1: `private _executeOne(event: VirtualEvent): void`
  void _executeOne(VirtualEvent event) {
    try {
      TraceContext.instance.runAsHandler<void>(
        event.trace ?? ROOT_TRACE,
        () {
          final VirtualEvent? e = _clock.runNext();
          if (e != null) {
            _history.add(e);
            _executedTotal++;
          }
        },
        (void Function() reset) => nextMacrotask(_realApi, reset),
      );
    } catch (e) {
      final Object err = e is Error ? e : StateError('$e');
      // We can't tell which run "owned" the throwing event. Reject all
      // active runs so the failure is observed exactly once per caller.
      for (final Run run in _runs.keys.toList()) {
        _settleRun(run, err);
      }
    }
  }

  // ---- The trampoline -------------------------------------------------

  /// 1:1: `private readonly _drive = (): void => { ... }`
  late final void Function() _drive = () {
    if (_inDrive) {
      return;
    }
    _inDrive = true;
    try {
      while (true) {
        final StepOutcome outcome = _step();
        if (identical(outcome, StepOutcome.quiesce)) {
          return;
        }
        if (identical(outcome, StepOutcome.park)) {
          _park();
          return;
        }

        // 'progress': read the next event so the embedding can pick a
        // per-event primitive. If there is none, loop and let the next
        // `_step` decide between 'park' and 'quiesce'.
        final VirtualEvent? next = _clock.peekNext();
        if (next == null) {
          continue;
        }

        final String choice = _embedding(next, _drive);
        if (choice == 'cbScheduled') {
          return;
        }
        // 'continueSync': loop in place.
      }
    } finally {
      _inDrive = false;
    }
  };

  // ---- Park & wake ----------------------------------------------------

  /// 1:1: `private _park(): void`
  void _park() {
    _unpark();
    final DisposableStore store = DisposableStore();
    store.add(_clock.onEventScheduled((dynamic _) => _wake()));
    _parkCleanup = store;
  }

  /// 1:1: `private _unpark(): void`
  void _unpark() {
    _parkCleanup?.dispose();
    _parkCleanup = null;
  }

  /// 1:1: `private _wake(): void`
  void _wake() {
    if (_disposed) {
      return;
    }
    _unpark();
    nextMacrotask(_realApi, _drive);
  }

  // ---- Run lifecycle --------------------------------------------------

  /// 1:1: `private _settleFinishedRuns(): void`
  void _settleFinishedRuns() {
    for (final Run run in _runs.keys.toList()) {
      if (run.settled) {
        continue;
      }
      final RunStatus status =
          run.evaluate(_clock, _executedTotal, () => _buildOverflow(run));
      if (status.isDone) {
        _settleRun(run);
      } else if (status.error != null) {
        _settleRun(run, status.error);
      }
    }
  }

  /// 1:1: `private _settleRun(run, error?): void`
  void _settleRun(Run run, [Object? error]) {
    final IDisposable? cleanup = _runs[run];
    if (cleanup == null) {
      return;
    }
    _runs.remove(run);
    cleanup.dispose();
    run.settle(error);
  }

  /// 1:1: `private _buildOverflow(run): Error`
  StateError _buildOverflow(Run run) {
    final int local = _executedTotal - run.executedAtStart;
    return StateError(
      '[VirtualTimeProcessor] Run #${run.id} exceeded maxEvents '
      '(${run.maxEvents}) — executed $local virtual event(s) and the queue is '
      'still not empty.',
    );
  }

  /// 1:1: `private _buildDepthOverflow(run, depth): Error`
  StateError _buildDepthOverflow(Run run, int depth) {
    return StateError(
      '[VirtualTimeProcessor] Run #${run.id} exceeded maxTraceDepth '
      '(${run.options.maxTraceDepth}) — next event has trace depth $depth. '
      'This usually indicates a runaway self-rescheduling timer.',
    );
  }

  /// 1:1: `private _onDispose(): void`
  void _onDispose() {
    _disposed = true;
    _unpark();
    final StateError err = StateError('VirtualTimeProcessor disposed');
    for (final Run run in _runs.keys.toList()) {
      _settleRun(run, err);
    }
  }
}

/// Carrier for the sentinel event scheduled at a time-based run's deadline.
/// Source: `{ time, source, run: () => {} }` with default
/// `trace`/`preferRealAnimationFrame`.
class _SentinelEvent implements VirtualEvent {
  @override
  final VirtualTime time;
  @override
  final EventSource source;

  _SentinelEvent({required this.time, required this.source});

  @override
  Trace? get trace => null;

  @override
  bool get preferRealAnimationFrame => false;

  @override
  void run() {
    /* sentinel: no-op */
  }
}
