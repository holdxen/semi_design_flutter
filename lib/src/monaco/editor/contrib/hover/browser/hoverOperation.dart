// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/hover/browser/hoverOperation.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `Debouncer` uses `RunOnceScheduler` by default, but a scheduler factory is
//    injectable so the state machine can be replayed with controlled timers.
//  * `IAsyncIterable` / `createCancelableAsyncIterableProducer` / `Emitter` /
//    `Disposable` are reused from the real port.
//  * `ICodeEditor` is an erased carrier; only `getOption(EditorOption.hover)`
//    is read.
//  * JS `for await (const item of iterable)` maps to an `IAsyncIterator` loop.
// ---------------------------------------------------------------------------

import '../../../../base/common/async.dart'
    show
        CancelableAsyncIterableProducer,
        IAsyncIterable,
        IAsyncIterator,
        IteratorResult,
        RunOnceScheduler,
        createCancelableAsyncIterableProducer;
import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart' show onUnexpectedError;
import '../../../../base/common/event.dart' show Emitter, Event;
import '../../../../base/common/lifecycle.dart' show IDisposable;
import '../../../common/config/editorOptions.dart' show EditorOption;

/// 1:1: `IHoverComputer<TArgs, TResult>`.
abstract class IHoverComputer<TArgs, TResult> {
  // 1:1: optional members (`computeAsync?` / `computeSync?` in TS).
  IAsyncIterable<TResult>? computeAsync(TArgs args, CancellationToken token);
  List<TResult>? computeSync(TArgs args);
}

/// 1:1: `enum HoverOperationState`.
class HoverOperationState {
  const HoverOperationState._();
  static const int Idle = 0;
  static const int FirstWait = 1;
  static const int SecondWait = 2;
  static const int WaitingForAsync = 3;
  static const int WaitingForAsyncShowingLoading = 4;
}

/// 1:1: `const enum HoverStartMode`.
class HoverStartMode {
  const HoverStartMode._();
  static const int Delayed = 0;
  static const int Immediate = 1;
}

/// 1:1: `const enum HoverStartSource`.
class HoverStartSource {
  const HoverStartSource._();
  static const int Mouse = 0;
  static const int Click = 1;
  static const int Keyboard = 2;
}

/// 1:1: `HoverResult<TArgs, TResult>`.
class HoverResult<TArgs, TResult> {
  final List<TResult> value;
  final bool isComplete;
  final bool hasLoadingMessage;
  final TArgs options;

  HoverResult(this.value, this.isComplete, this.hasLoadingMessage, this.options);
}

/// 1:1: `Debouncer<TArgs>`.
class Debouncer<TArgs> implements IDisposable {
  final RunOnceScheduler _scheduler;
  final void Function(TArgs options) _runner;
  TArgs? _options;

  Debouncer(void Function(TArgs options) runner, int debounceTimeMs)
      : _runner = runner,
        _scheduler = RunOnceScheduler(() {}, debounceTimeMs) {
    _scheduler.runner = _invoke;
  }

  /// Inject a pre-built scheduler (replay). Kept separate from the TS surface.
  Debouncer.withScheduler(this._scheduler, void Function(TArgs options) runner)
      : _runner = runner {
    // The injected scheduler's runner must route through [_options].
    _scheduler.runner = _invoke;
  }

  void _invoke() => _runner(_options as TArgs);

  void schedule(TArgs options, int debounceTimeMs) {
    _options = options;
    _scheduler.schedule(debounceTimeMs);
  }

  void cancel() => _scheduler.cancel();

  @override
  void dispose() => _scheduler.dispose();
}

/// 1:1: `HoverOperation<TArgs, TResult>`.
class HoverOperation<TArgs, TResult> implements IDisposable {
  final Emitter<HoverResult<TArgs, TResult>> _onResult =
      Emitter<HoverResult<TArgs, TResult>>();
  late final Event<HoverResult<TArgs, TResult>> onResult;

  late final Debouncer<TArgs> _asyncComputationScheduler;
  late final Debouncer<TArgs> _syncComputationScheduler;
  late final Debouncer<TArgs> _loadingMessageScheduler;

  int _state = HoverOperationState.Idle;
  CancelableAsyncIterableProducer<TResult>? _asyncIterable;
  bool _asyncIterableDone = false;
  List<TResult> _result = <TResult>[];
  TArgs? _options;

  final Object _editor;
  final IHoverComputer<TArgs, TResult> _computer;

  /// [schedulerFactory] is a replay hook; production passes null.
  HoverOperation(
    this._editor,
    this._computer, [
    RunOnceScheduler Function(void Function() runner, int delay)?
        schedulerFactory,
  ]) {
    onResult = _onResult.event;
    RunOnceScheduler make(void Function() runner, int delay) =>
        schedulerFactory != null
            ? schedulerFactory(runner, delay)
            : RunOnceScheduler(runner, delay);

    final void Function(TArgs) asyncRunner = (TArgs options) =>
        _triggerAsyncComputation(options);
    final void Function(TArgs) syncRunner = (TArgs options) =>
        _triggerSyncComputation(options);
    final void Function(TArgs) loadingRunner = (TArgs options) =>
        _triggerLoadingMessage(options);

    _asyncComputationScheduler = Debouncer.withScheduler(
      make(() {}, 0),
      asyncRunner,
    );
    _syncComputationScheduler = Debouncer.withScheduler(
      make(() {}, 0),
      syncRunner,
    );
    _loadingMessageScheduler = Debouncer.withScheduler(
      make(() {}, 0),
      loadingRunner,
    );
  }

  @override
  void dispose() {
    if (_asyncIterable != null) {
      _asyncIterable!.cancel();
      _asyncIterable = null;
    }
    _options = null;
    _onResult.dispose();
  }

  int get _hoverTime {
    final Object hover = (_editor as dynamic)
        .getOption(EditorOption.hover) as Object;
    return (hover as dynamic).delay as int;
  }

  int get _firstWaitTime => _hoverTime ~/ 2;
  int get _secondWaitTime => _hoverTime - _firstWaitTime;
  int get _loadingMessageTime => 3 * _hoverTime;

  void _setState(int state, TArgs options) {
    _options = options;
    _state = state;
    _fireResult(options);
  }

  void _triggerAsyncComputation(TArgs options) {
    _setState(HoverOperationState.SecondWait, options);
    _syncComputationScheduler.schedule(options, _secondWaitTime);

    final IAsyncIterable<TResult>? computed =
        _computer.computeAsync(options, CancellationToken.none);
    if (computed != null) {
      _asyncIterableDone = false;
      _asyncIterable = createCancelableAsyncIterableProducer<TResult>(
        (CancellationToken token) => computed,
      );
      _consumeAsync(options);
    } else {
      _asyncIterableDone = true;
    }
  }

  Future<void> _consumeAsync(TArgs options) async {
    final CancelableAsyncIterableProducer<TResult> iterable =
        _asyncIterable!;
    try {
      final IAsyncIterator<TResult> it = iterable.asyncIterator();
      while (true) {
        final IteratorResult<TResult> r = await it.next();
        if (r.done) break;
        final TResult? item = r.value;
        if (item != null) {
          _result.add(item);
          _fireResult(options);
        }
      }
      _asyncIterableDone = true;
      if (_state == HoverOperationState.WaitingForAsync ||
          _state == HoverOperationState.WaitingForAsyncShowingLoading) {
        _setState(HoverOperationState.Idle, options);
      }
    } catch (e) {
      onUnexpectedError(e);
    }
  }

  void _triggerSyncComputation(TArgs options) {
    final List<TResult>? sync = _computer.computeSync(options);
    if (sync != null) {
      _result = <TResult>[..._result, ...sync];
    }
    _setState(
      _asyncIterableDone
          ? HoverOperationState.Idle
          : HoverOperationState.WaitingForAsync,
      options,
    );
  }

  void _triggerLoadingMessage(TArgs options) {
    if (_state == HoverOperationState.WaitingForAsync) {
      _setState(HoverOperationState.WaitingForAsyncShowingLoading, options);
    }
  }

  void _fireResult(TArgs options) {
    if (_state == HoverOperationState.FirstWait ||
        _state == HoverOperationState.SecondWait) {
      return;
    }
    final bool isComplete = _state == HoverOperationState.Idle;
    final bool hasLoadingMessage =
        _state == HoverOperationState.WaitingForAsyncShowingLoading;
    _onResult.fire(HoverResult<TArgs, TResult>(
      List<TResult>.from(_result),
      isComplete,
      hasLoadingMessage,
      options,
    ));
  }

  void start(int mode, TArgs options) {
    if (mode == HoverStartMode.Delayed) {
      if (_state == HoverOperationState.Idle) {
        _setState(HoverOperationState.FirstWait, options);
        _asyncComputationScheduler.schedule(options, _firstWaitTime);
        _loadingMessageScheduler.schedule(options, _loadingMessageTime);
      }
    } else {
      switch (_state) {
        case HoverOperationState.Idle:
          _triggerAsyncComputation(options);
          _syncComputationScheduler.cancel();
          _triggerSyncComputation(options);
          break;
        case HoverOperationState.SecondWait:
          _syncComputationScheduler.cancel();
          _triggerSyncComputation(options);
          break;
      }
    }
  }

  void cancel() {
    _asyncComputationScheduler.cancel();
    _syncComputationScheduler.cancel();
    _loadingMessageScheduler.cancel();
    if (_asyncIterable != null) {
      _asyncIterable!.cancel();
      _asyncIterable = null;
    }
    _result = <TResult>[];
    _options = null;
    _state = HoverOperationState.Idle;
  }

  TArgs? get options => _options;
}
