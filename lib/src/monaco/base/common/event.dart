// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/event.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations:
//   - `interface Event<T>` (callable) -> Dart typedef (callable function type)
//   - `namespace Event` -> top-level class `EventNs` + static functions; the
//     source's `Event.xxx` calls become top-level helpers where convenient
//   - FinalizationRegistry / AbortSignal / DOM — no weak refs / DOM in Dart
//   - `[Symbol.iterator]` -> IterableMixin
//   - `Object.freeze` singletons -> const/final instances
//   - `Error.stack` -> StackTrace-based stack text
//   - TS overloads collapsed to single nullable/dynamic signatures
// ---------------------------------------------------------------------------

import 'dart:async';

import 'async.dart' as async;
import 'cancellation.dart' as cancellation;
import 'collections.dart' as collections;
import 'errors.dart' as errors;
import 'functional.dart' as functional;
import 'lifecycle.dart' as lifecycle;
import 'linkedList.dart' as linkedList;
import 'observable.dart' as observable;
import 'process.dart' as process;
import 'stopwatch.dart' as stopwatch;
import 'symbols.dart' as symbols;

const bool _enableDisposeWithListenerWarning = false;
const bool _enableSnapshotPotentialLeakWarning = false;
const int _bufferLeakWarnCountThreshold = 100;
const int _bufferLeakWarnTimeThreshold = 60000;

bool _isBufferLeakWarningEnabled() => process.env['VSCODE_DEV'] != null;

/// 1:1: `export interface Event<T>`
/// Callable listener registration. `listener` is `void Function(T)` (dynamic to
/// allow contravariant use), `thisArgs` is the JS `this` binding, `disposables`
/// is `IDisposable[] | DisposableStore`.
typedef Event<T> = lifecycle.IDisposable Function(
  dynamic listener, [
  dynamic thisArgs,
  dynamic disposables,
]);

// ---------------------------------------------------------------------------
// namespace Event — helpers that operate on [Event]s.
// ---------------------------------------------------------------------------

/// 1:1: `Event.None`
final Event<dynamic> eventNone = (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
    lifecycle.Disposable.none;

void _addLeakageTraceLogic(EmitterOptions options) {
  if (_enableSnapshotPotentialLeakWarning) {
    final Function? origListenerDidAdd = options.onDidAddListener;
    final Stacktrace stack = Stacktrace.create();
    int count = 0;
    options.onDidAddListener = () {
      if (++count == 2) {
        // console.warn(...) — no-op in this port.
        stack.print();
      }
      origListenerDidAdd?.call();
    };
  }
}

/// 1:1: `Event.defer`
Event<void> eventDefer(Event<dynamic> event, [bool? flushOnListenerRemove, lifecycle.DisposableStore? disposable]) =>
    eventDebounce<dynamic, void>(event, (dynamic last, dynamic e) => null,
        delay: 0,
        leading: true,
        flushOnListenerRemove: flushOnListenerRemove ?? true,
        disposable: disposable);

/// 1:1: `Event.once`
Event<T> eventOnce<T>(Event<T> event) => (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
      bool didFire = false;
      late lifecycle.IDisposable result;
      bool resultAssigned = false;
      result = event((dynamic e) {
        if (didFire) {
          return;
        } else if (resultAssigned) {
          result.dispose();
        } else {
          didFire = true;
        }
        return listener(e);
      }, null, disposables);
      resultAssigned = true;

      if (didFire) {
        result.dispose();
      }
      return result;
    };

/// 1:1: `Event.onceIf`
Event<T> eventOnceIf<T>(Event<T> event, bool Function(T e) condition) =>
    eventOnce(eventFilter(event, condition));

/// 1:1: `Event.map`
Event<O> eventMap<I, O>(Event<I> event, O Function(I i) map, [lifecycle.DisposableStore? disposable]) =>
    eventSnapshot<O>((dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
        event((dynamic i) => listener(map(i as I)), null, disposables), disposable);

/// 1:1: `Event.forEach`
Event<I> eventForEach<I>(Event<I> event, void Function(I i) each, [lifecycle.DisposableStore? disposable]) =>
    eventSnapshot<I>((dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
        event((dynamic i) {
          each(i as I);
          listener(i);
        }, null, disposables), disposable);

/// 1:1: `Event.filter`
Event<T> eventFilter<T>(Event<T> event, bool Function(T e) filter, [lifecycle.DisposableStore? disposable]) =>
    eventSnapshot<T>((dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
        event((dynamic e) {
          if (filter(e as T)) {
            listener(e);
          }
        }, null, disposables), disposable);

/// 1:1: `Event.signal`
Event<void> eventSignal<T>(Event<T> event) => event;

/// 1:1: `Event.any`
Event<T> eventAny<T>(List<Event<T>> events) => (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
      final lifecycle.IDisposable disposable = lifecycle.combinedDisposable(
        events.map((Event<T> event) => event((dynamic e) => listener(e))).toList(),
      );
      return _addAndReturnDisposable(disposable, disposables);
    };

/// 1:1: `Event.reduce`
Event<O> eventReduce<I, O>(
  Event<I> event,
  O Function(O? last, I event) merge, [
  O? initial,
  lifecycle.DisposableStore? disposable,
]) {
  O? output = initial;
  return eventMap<I, O>(event, (I e) {
    output = merge(output, e);
    return output!;
  }, disposable);
}

/// 1:1: `snapshot` helper
Event<R> eventSnapshot<R>(Event<R> event, lifecycle.DisposableStore? disposable) {
  lifecycle.IDisposable? listener;
  late final Emitter<R> emitter;

  final EmitterOptions options = EmitterOptions(
    onWillAddFirstListener: () {
      listener = event((dynamic e) => emitter.fire(e), emitter);
    },
    onDidRemoveLastListener: () {
      listener?.dispose();
    },
  );

  if (disposable == null) {
    _addLeakageTraceLogic(options);
  }

  emitter = Emitter<R>(options);
  disposable?.add(emitter);
  return emitter.event;
}

/// 1:1: `addAndReturnDisposable`
T _addAndReturnDisposable<T extends lifecycle.IDisposable>(T d, dynamic store) {
  if (store is List) {
    store.add(d);
  } else if (store != null) {
    (store as lifecycle.DisposableStore).add(d);
  }
  return d;
}

/// 1:1: `Event.debounce`
Event<O> eventDebounce<I, O>(
  Event<I> event,
  O Function(O? last, I event) merge, {
  Object delay = 100,
  bool leading = false,
  bool flushOnListenerRemove = false,
  int? leakWarningThreshold,
  lifecycle.DisposableStore? disposable,
}) {
  late final Emitter<O> emitter;
  lifecycle.IDisposable subscription = lifecycle.Disposable.none;
  O? output;
  Object? handle; // Timer when delay is num; marker when microtask
  int numDebouncedCalls = 0;
  void Function()? doFire;

  final EmitterOptions options = EmitterOptions(
    leakWarningThreshold: leakWarningThreshold,
    onWillAddFirstListener: () {
      subscription = event((dynamic cur) {
        numDebouncedCalls++;
        output = merge(output, cur as I);

        if (leading && handle == null) {
          emitter.fire(output as O);
          output = null;
        }

        doFire = () {
          final O? _output = output;
          output = null;
          handle = null;
          if (!leading || numDebouncedCalls > 1) {
            emitter.fire(_output as O);
          }
          numDebouncedCalls = 0;
        };

        if (delay is num) {
          if (handle is Timer) {
            (handle as Timer).cancel();
          }
          handle = Timer(Duration(milliseconds: delay.round()), doFire!);
        } else {
          if (handle == null) {
            handle = symbols.MicrotaskDelay;
            scheduleMicrotask(doFire!);
          }
        }
      });
    },
    onWillRemoveListener: () {
      if (flushOnListenerRemove && numDebouncedCalls > 0) {
        doFire?.call();
      }
    },
    onDidRemoveLastListener: () {
      doFire = null;
      subscription.dispose();
    },
  );

  if (disposable == null) {
    _addLeakageTraceLogic(options);
  }
  emitter = Emitter<O>(options);
  disposable?.add(emitter);
  return emitter.event;
}

/// 1:1: `Event.accumulate`
Event<List<T>> eventAccumulate<T>(
  Event<T> event, {
  Object delay = 0,
  bool? flushOnListenerRemove,
  lifecycle.DisposableStore? disposable,
}) =>
    eventDebounce<T, List<T>>(event, (List<T>? last, T e) {
      if (last == null) {
        return <T>[e];
      }
      last.add(e);
      return last;
    },
        delay: delay,
        flushOnListenerRemove: flushOnListenerRemove ?? true,
        disposable: disposable);

/// 1:1: `Event.throttle`
Event<O> eventThrottle<I, O>(
  Event<I> event,
  O Function(O? last, I event) merge, {
  Object delay = 100,
  bool leading = true,
  bool trailing = true,
  int? leakWarningThreshold,
  lifecycle.DisposableStore? disposable,
}) {
  late final Emitter<O> emitter;
  late lifecycle.IDisposable subscription;
  O? output;
  Object? handle;
  int numThrottledCalls = 0;

  final EmitterOptions options = EmitterOptions(
    leakWarningThreshold: leakWarningThreshold,
    onWillAddFirstListener: () {
      subscription = event((dynamic cur) {
        numThrottledCalls++;
        output = merge(output, cur as I);

        if (handle == null) {
          if (leading) {
            emitter.fire(output as O);
            output = null;
            numThrottledCalls = 0;
          }
          if (delay is num) {
            handle = Timer(Duration(milliseconds: delay.round()), () {
              if (trailing && numThrottledCalls > 0) {
                emitter.fire(output as O);
              }
              output = null;
              handle = null;
              numThrottledCalls = 0;
            });
          } else {
            handle = 0; // marker that a microtask is pending
            scheduleMicrotask(() {
              if (trailing && numThrottledCalls > 0) {
                emitter.fire(output as O);
              }
              output = null;
              handle = null;
              numThrottledCalls = 0;
            });
          }
        }
      });
    },
    onDidRemoveLastListener: () {
      subscription.dispose();
    },
  );

  if (disposable == null) {
    _addLeakageTraceLogic(options);
  }
  emitter = Emitter<O>(options);
  disposable?.add(emitter);
  return emitter.event;
}

/// 1:1: `Event.latch`
Event<T> eventLatch<T>(
  Event<T> event, [
  bool Function(T a, T b)? equals,
  lifecycle.DisposableStore? disposable,
]) {
  bool firstCall = true;
  late T cache;
  return eventFilter(event, (T value) {
    final bool shouldEmit = firstCall || !equals!(value, cache);
    firstCall = false;
    cache = value;
    return shouldEmit;
  }, disposable);
}

/// 1:1: `Event.split`
List<Event<dynamic>> eventSplit<T, U>(
  Event<dynamic> event,
  bool Function(dynamic e) isT, [
  lifecycle.DisposableStore? disposable,
]) =>
    <Event<dynamic>>[
      eventFilter(event, isT, disposable),
      eventFilter(event, (dynamic e) => !isT(e), disposable),
    ];

/// 1:1: `Event.buffer`
Event<T> eventBuffer<T>(
  Event<T> event,
  String debugName, [
  bool flushAfterTimeout = false,
  List<T>? buffer,
  lifecycle.DisposableStore? disposable,
]) {
  final List<T>? sourceBuffer = buffer;
  List<T>? buf = sourceBuffer == null ? <T>[] : List<T>.from(sourceBuffer);

  _BufferLeakData? bufferLeakWarningData;
  if (_isBufferLeakWarningEnabled()) {
    bufferLeakWarningData = _BufferLeakData(
      stack: Stacktrace.create(),
      timerId: Timer(const Duration(milliseconds: _bufferLeakWarnTimeThreshold), () {
        if (buf != null && buf!.isNotEmpty && bufferLeakWarningData != null && !bufferLeakWarningData.warned) {
          bufferLeakWarningData.warned = true;
          // console.warn(...) — no-op in this port.
          bufferLeakWarningData.stack.print();
        }
      }),
      warned: false,
    );
    if (disposable != null) {
      disposable.add(lifecycle.toDisposable(() => bufferLeakWarningData!.timerId.cancel()));
    }
  }

  void clearLeakWarningTimer() {
    bufferLeakWarningData?.timerId.cancel();
  }

  late final Emitter<T> emitter;
  late lifecycle.IDisposable listener;
  listener = event((dynamic e) {
    if (buf != null) {
      buf!.add(e as T);
      if (_isBufferLeakWarningEnabled() &&
          bufferLeakWarningData != null &&
          !bufferLeakWarningData.warned &&
          buf!.length >= _bufferLeakWarnCountThreshold) {
        bufferLeakWarningData.warned = true;
        // console.warn(...) — no-op in this port.
        bufferLeakWarningData.stack.print();
      }
    } else {
      emitter.fire(e as T);
    }
  });

  if (disposable != null) {
    disposable.add(listener);
  }

  void flush() {
    buf?.forEach((T e) => emitter.fire(e));
    buf = null;
    clearLeakWarningTimer();
  }

  emitter = Emitter<T>(EmitterOptions(
    onWillAddFirstListener: () {
      // Source: `if (!listener)` — listener is always set above, so no-op.
    },
    onDidAddFirstListener: () {
      if (buf != null) {
        if (flushAfterTimeout) {
          Timer(Duration.zero, flush);
        } else {
          flush();
        }
      }
    },
    onDidRemoveLastListener: () {
      listener.dispose();
      clearLeakWarningTimer();
    },
  ));

  if (disposable != null) {
    disposable.add(emitter);
  }
  return emitter.event;
}

class _BufferLeakData {
  final Stacktrace stack;
  final Timer timerId;
  bool warned;
  _BufferLeakData({required this.stack, required this.timerId, required this.warned});
}

/// 1:1: `Event.chain`
Event<R> eventChain<T, R>(
  Event<T> event,
  IChainableSynthesis<dynamic> Function(IChainableSynthesis<dynamic> synth) synthesize,
) {
  Event<R> fn = (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
    final ChainableSynthesis cs = synthesize(ChainableSynthesis<T>()) as ChainableSynthesis;
    return event((dynamic value) {
      final dynamic result = cs.evaluate(value);
      if (!identical(result, haltChainable)) {
        listener(result);
      }
    }, null, disposables);
  };
  return fn;
}

final Object haltChainable = Object();

/// 1:1: `interface IChainableSythensis<T>` (source typo preserved in name)
abstract class IChainableSynthesis<T> {
  IChainableSynthesis<dynamic> map<O>(O Function(dynamic i) fn);
  IChainableSynthesis<T> forEach(void Function(dynamic i) fn);
  IChainableSynthesis<dynamic> filter(bool Function(dynamic e) fn);
  IChainableSynthesis<dynamic> reduce(dynamic Function(dynamic last, dynamic event) merge, [dynamic initial]);
  IChainableSynthesis<T> latch([bool Function(dynamic a, dynamic b)? equals]);
}

/// 1:1: `class ChainableSynthesis`
class ChainableSynthesis<T> implements IChainableSynthesis<dynamic> {
  final List<dynamic Function(dynamic input)> steps = <dynamic Function(dynamic)>[];

  @override
  ChainableSynthesis map<O>(O Function(dynamic i) fn) {
    steps.add(fn);
    return this;
  }

  @override
  ChainableSynthesis forEach(void Function(dynamic i) fn) {
    steps.add((dynamic v) {
      fn(v);
      return v;
    });
    return this;
  }

  @override
  ChainableSynthesis filter(bool Function(dynamic e) fn) {
    steps.add((dynamic v) => fn(v) ? v : haltChainable);
    return this;
  }

  @override
  ChainableSynthesis reduce(dynamic Function(dynamic last, dynamic event) merge, [dynamic initial]) {
    dynamic last = initial;
    steps.add((dynamic v) {
      last = merge(last, v);
      return last;
    });
    return this;
  }

  @override
  ChainableSynthesis latch([bool Function(dynamic a, dynamic b)? equals]) {
    equals ??= (dynamic a, dynamic b) => a == b;
    bool firstCall = true;
    dynamic cache;
    steps.add((dynamic value) {
      final bool shouldEmit = firstCall || !equals!(value, cache);
      firstCall = false;
      cache = value;
      return shouldEmit ? value : haltChainable;
    });
    return this;
  }

  dynamic evaluate(dynamic value) {
    for (final dynamic Function(dynamic) step in steps) {
      value = step(value);
      if (identical(value, haltChainable)) {
        break;
      }
    }
    return value;
  }
}

/// 1:1: `interface NodeEventEmitter`
abstract class NodeEventEmitter {
  Object? on(Object event, Function listener);
  Object? removeListener(Object event, Function listener);
}

/// 1:1: `Event.fromNodeEventEmitter`
Event<T> eventFromNodeEventEmitter<T>(
  NodeEventEmitter emitter,
  Object eventName, [
  T Function(List<dynamic> args)? map,
]) {
  map ??= (List<dynamic> args) => args.isEmpty ? null as T : args.first as T;
  late final Emitter<T> emitterResult;
  void fn(List<dynamic> args) => emitterResult.fire(map!(args));
  void onFirstListenerAdd() => emitter.on(eventName, fn);
  void onLastListenerRemove() => emitter.removeListener(eventName, fn);
  emitterResult = Emitter<T>(EmitterOptions(
    onWillAddFirstListener: onFirstListenerAdd,
    onDidRemoveLastListener: onLastListenerRemove,
  ));
  return emitterResult.event;
}

/// 1:1: `interface DOMEventEmitter`
abstract class DOMEventEmitter {
  void addEventListener(Object event, Function listener);
  void removeEventListener(Object event, Function listener);
}

/// 1:1: `Event.fromDOMEventEmitter`
Event<T> eventFromDOMEventEmitter<T>(
  DOMEventEmitter emitter,
  Object eventName, [
  T Function(List<dynamic> args)? map,
]) {
  map ??= (List<dynamic> args) => args.isEmpty ? null as T : args.first as T;
  late final Emitter<T> emitterResult;
  void fn(List<dynamic> args) => emitterResult.fire(map!(args));
  void onFirstListenerAdd() => emitter.addEventListener(eventName, fn);
  void onLastListenerRemove() => emitter.removeEventListener(eventName, fn);
  emitterResult = Emitter<T>(EmitterOptions(
    onWillAddFirstListener: onFirstListenerAdd,
    onDidRemoveLastListener: onLastListenerRemove,
  ));
  return emitterResult.event;
}

/// 1:1: `Event.toPromise`
async.CancelablePromise<T> eventToPromise<T>(
  Event<T> event, [
  dynamic disposables,
]) {
  late void Function() cancelRef;
  late lifecycle.IDisposable listener;
  final Completer<T> completer = Completer<T>();
  listener = eventOnce(event)((dynamic resolve) => completer.complete(resolve as T));
  _addToDisposables(listener, disposables);

  cancelRef = () {
    _disposeAndRemove(listener, disposables);
  };

  final Future<T> promise = completer.future;
  if (disposables != null) {
    promise.whenComplete(() => _disposeAndRemove(listener, disposables));
  }
  return _CancelablePromiseImpl<T>(promise, cancelRef);
}

class _CancelablePromiseImpl<T> implements async.CancelablePromise<T> {
  final Future<T> _future;
  void Function()? _cancel;
  _CancelablePromiseImpl(this._future, this._cancel);

  @override
  void cancel() => _cancel?.call();

  @override
  Future<void> get done => _future.then((_) {});

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) action, {Function? onError}) =>
      _future.then(action, onError: onError);

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);
}

/// 1:1: `Event.forward`
lifecycle.IDisposable eventForward<T>(Event<T> from, Emitter<T> to) =>
    from((dynamic e) => to.fire(e as T));

/// 1:1: `Event.runAndSubscribe`
lifecycle.IDisposable eventRunAndSubscribe<T>(
  Event<T> event,
  void Function(T? e) handler, [
  T? initial,
]) {
  handler(initial);
  return event((dynamic e) => handler(e as T));
}

/// 1:1: class EmitterObserver (fromObservable)
class EmitterObserver<T> implements observable.IObserver {
  late final Emitter<T> emitter;
  int _counter = 0;
  bool _hasChanged = false;

  final observable.IObservable<T> _observable;

  EmitterObserver(this._observable, lifecycle.DisposableStore? store) {
    final EmitterOptions options = EmitterOptions(
      onWillAddFirstListener: () {
        _observable.addObserver(this);
        _observable.reportChanges();
      },
      onDidRemoveLastListener: () {
        _observable.removeObserver(this);
      },
    );
    if (store == null) {
      _addLeakageTraceLogic(options);
    }
    emitter = Emitter<T>(options);
    if (store != null) {
      store.add(emitter);
    }
  }

  @override
  void beginUpdate<T>(Object obs) {
    _counter++;
  }

  @override
  void handlePossibleChange<T>(Object obs) {}

  @override
  void handleChange<T, TChange>(Object obs, TChange change) {
    _hasChanged = true;
  }

  @override
  void endUpdate<T>(Object obs) {
    _counter--;
    if (_counter == 0) {
      _observable.reportChanges();
      if (_hasChanged) {
        _hasChanged = false;
        emitter.fire(_observable.get());
      }
    }
  }
}

/// 1:1: `Event.fromObservable`
Event<T> eventFromObservable<T>(observable.IObservable<T> obs, [lifecycle.DisposableStore? store]) {
  final EmitterObserver<T> observer = EmitterObserver<T>(obs, store);
  return observer.emitter.event;
}

/// 1:1: `Event.fromObservableLight`
Event<void> eventFromObservableLight(observable.IObservable<dynamic> observableValue) =>
    (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
      int count = 0;
      bool didChange = false;
      final observable.IObserver observer = _LightObserver(
        () {
          count++;
        },
        () {
          count--;
          if (count == 0) {
            observableValue.reportChanges();
            if (didChange) {
              didChange = false;
              listener();
            }
          }
        },
        () {
          didChange = true;
        },
      );
      observableValue.addObserver(observer);
      observableValue.reportChanges();
      final lifecycle.IDisposable disposable = lifecycle.toDisposable(() {
        observableValue.removeObserver(observer);
      });
      _addToDisposables(disposable, disposables);
      return disposable;
    };

class _LightObserver implements observable.IObserver {
  final void Function() _begin;
  final void Function() _end;
  final void Function() _change;
  _LightObserver(this._begin, this._end, this._change);

  @override
  void beginUpdate<T>(Object observable) => _begin();
  @override
  void endUpdate<T>(Object observable) => _end();
  @override
  void handlePossibleChange<T>(Object observable) {}
  @override
  void handleChange<T, TChange>(Object observable, TChange change) => _change();
}

// ---------------------------------------------------------------------------
// EmitterOptions
// ---------------------------------------------------------------------------

/// 1:1: `export interface EmitterOptions`
class EmitterOptions {
  Function? onWillAddFirstListener;
  Function? onDidAddFirstListener;
  Function? onDidAddListener;
  Function? onDidRemoveLastListener;
  Function? onWillRemoveListener;
  void Function(dynamic e)? onListenerError;
  int? leakWarningThreshold;
  String? leakWarningName;
  EventDeliveryQueue? deliveryQueue;
  String? profName;

  EmitterOptions({
    this.onWillAddFirstListener,
    this.onDidAddFirstListener,
    this.onDidAddListener,
    this.onDidRemoveLastListener,
    this.onWillRemoveListener,
    this.onListenerError,
    this.leakWarningThreshold,
    this.leakWarningName,
    this.deliveryQueue,
    this.profName,
  });
}

/// 1:1: `export class EventProfiling`
class EventProfiling {
  static final Set<EventProfiling> all = <EventProfiling>{};
  static int _idPool = 0;

  final String name;
  int listenerCount = 0;
  int invocationCount = 0;
  num elapsedOverall = 0;
  final List<num> durations = <num>[];

  stopwatch.StopWatch? _stopWatch;

  EventProfiling(String name) : name = '${name}_${_idPool++}' {
    EventProfiling.all.add(this);
  }

  void start(int listenerCount) {
    _stopWatch = stopwatch.StopWatch();
    this.listenerCount = listenerCount;
  }

  void stop() {
    if (_stopWatch != null) {
      final num elapsed = _stopWatch!.elapsed();
      durations.add(elapsed);
      elapsedOverall += elapsed;
      invocationCount += 1;
      _stopWatch = null;
    }
  }
}

int _globalLeakWarningThreshold = -1;

/// 1:1: `export function setGlobalLeakWarningThreshold`
lifecycle.IDisposable setGlobalLeakWarningThreshold(int n) {
  final int oldValue = _globalLeakWarningThreshold;
  _globalLeakWarningThreshold = n;
  return lifecycle.toDisposable(() {
    _globalLeakWarningThreshold = oldValue;
  });
}

int leakageMonitorId = 1;
String nextLeakageMonitorName() => (leakageMonitorId++).toRadixString(16).padLeft(3, '0');

/// 1:1: `class LeakageMonitor`
class LeakageMonitor {
  Map<String, int>? _stacks;
  num _warnCountdown = 0;

  final void Function(Object err) _errorHandler;
  final int threshold;
  final String name;

  LeakageMonitor(this._errorHandler, this.threshold, [String? name])
      : name = name ?? nextLeakageMonitorName();

  void dispose() {
    _stacks?.clear();
  }

  void Function()? check(Stacktrace stack, int listenerCount) {
    final int threshold = this.threshold;
    if (threshold <= 0 || listenerCount < threshold) {
      return null;
    }
    _stacks ??= <String, int>{};
    final String stackKey = stack.value;
    final int count = _stacks![stackKey] ?? 0;
    _stacks![stackKey] = count + 1;
    _warnCountdown -= 1;

    if (_warnCountdown <= 0) {
      _warnCountdown = threshold * 0.5;
      final ({String stack, int count}) top = getMostFrequentStack()!;
      final String? emitterName = RegExp(r'^[0-9a-f]+$', caseSensitive: false).hasMatch(name) ? null : name;
      final String message =
          '[$name] potential listener LEAK detected, having $listenerCount listeners already. MOST frequent listener (${top.count}):';
      // console.warn(message) / console.warn(topStack) — no-op in this port.
      final String kind = top.count / listenerCount > 0.3 ? 'dominated' : 'popular';
      final ListenerLeakError error =
          ListenerLeakError(kind, message, top.stack, listenerCount, emitterName);
      _errorHandler(error);
    }

    return () {
      final int count = _stacks![stackKey] ?? 0;
      if (count <= 1) {
        _stacks!.remove(stackKey);
      } else {
        _stacks![stackKey] = count - 1;
      }
    };
  }

  ({String stack, int count})? getMostFrequentStack() {
    if (_stacks == null) {
      return null;
    }
    ({String stack, int count})? topStack;
    int topCount = 0;
    for (final MapEntry<String, int> entry in _stacks!.entries) {
      if (topStack == null || topCount < entry.value) {
        topStack = (stack: entry.key, count: entry.value);
        topCount = entry.value;
      }
    }
    return topStack;
  }
}

/// 1:1: `class Stacktrace`
class Stacktrace {
  static Stacktrace create() {
    final StackTrace current = StackTrace.current;
    return Stacktrace(current.toString());
  }

  final String value;
  Stacktrace(this.value);

  void print() {
    // console.warn(value.split('\n').slice(2).join('\n')) — no-op in this port.
  }
}

/// 1:1: `export class ListenerLeakError`
class ListenerLeakError implements Exception {
  final String kind;
  final int listenerCount;
  final String details;
  final String stack;
  final String message;

  ListenerLeakError(String kind, this.details, this.stack, this.listenerCount, [String? emitterName])
      : kind = kind,
        message = emitterName != null
            ? '[$emitterName] potential listener LEAK detected, $kind'
            : 'potential listener LEAK detected, $kind';

  static bool isLeak(Object? err) {
    return err is ListenerLeakError;
  }

  @override
  String toString() => message;
}

/// 1:1: `export class ListenerRefusalError`
class ListenerRefusalError extends ListenerLeakError {
  ListenerRefusalError(String kind, String details, String stack, int listenerCount, [String? emitterName])
      : super(kind, details, stack, listenerCount, emitterName);

  @override
  String toString() => 'ListenerRefusalError: $message';
}

int uniqueContainerId = 0;

/// 1:1: `class UniqueContainer<T>`
class UniqueContainer<T> {
  Stacktrace? stack;
  final int id = uniqueContainerId++;
  final T value;
  UniqueContainer(this.value);
}

const int compactionThreshold = 2;

/// 1:1: `ListenerContainer<T>` / `ListenerOrListeners<T>`
typedef ListenerContainer<T> = UniqueContainer<void Function(T data)>;
typedef ListenerOrListeners<T> = Object; // UniqueContainer<T> | List<UniqueContainer<T>?>

/// 1:1: `forEachListener`
void forEachListener<T>(Object listeners, void Function(ListenerContainer<T> c) fn) {
  if (listeners is UniqueContainer) {
    fn(listeners as ListenerContainer<T>);
  } else {
    final List<dynamic> list = listeners as List<dynamic>;
    for (int i = 0; i < list.length; i++) {
      final dynamic l = list[i];
      if (l != null) {
        fn(l as ListenerContainer<T>);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Emitter
// ---------------------------------------------------------------------------

/// 1:1: `export class Emitter<T>`
class Emitter<T> implements lifecycle.IDisposable {
  final EmitterOptions? _options;
  int? _leakWarningThreshold;
  String? _leakWarningName;
  void Function(Object err)? _leakWarningErrorHandler;
  LeakageMonitor? _leakageMon;
  EventProfiling? _perfMon;
  bool? _disposed;
  Event<T>? _event;

  /// A single listener or a (possibly sparse) list of listeners.
  Object? _listeners;
  EventDeliveryQueuePrivate? _deliveryQueue;
  int _size = 0;

  Emitter([EmitterOptions? options])
      : _options = options {
    if (_globalLeakWarningThreshold > 0 || options?.leakWarningThreshold != null) {
      _leakWarningThreshold = options?.leakWarningThreshold ?? _globalLeakWarningThreshold;
      _leakWarningName = options?.leakWarningName;
      _leakWarningErrorHandler = options?.onListenerError as void Function(Object)? ?? errors.onUnexpectedError;
    }
    _perfMon = options?.profName != null ? EventProfiling(options!.profName!) : null;
    _deliveryQueue = options?.deliveryQueue as EventDeliveryQueuePrivate?;
  }

  LeakageMonitor? _getLeakageMonitor() {
    if (_leakWarningThreshold == null || _leakWarningErrorHandler == null) {
      return null;
    }
    return _leakageMon ??= LeakageMonitor(
        _leakWarningErrorHandler!, _leakWarningThreshold!, _leakWarningName);
  }

  @override
  void dispose() {
    if (_disposed != true) {
      _disposed = true;
      if (_deliveryQueue?.current == this) {
        _deliveryQueue!.reset();
      }
      if (_listeners != null) {
        if (_enableDisposeWithListenerWarning) {
          final Object listeners = _listeners!;
          scheduleMicrotask(() {
            forEachListener(listeners, (ListenerContainer<dynamic> l) {
              l.stack?.print();
            });
          });
        }
        _listeners = null;
        _size = 0;
      }
      _options?.onDidRemoveLastListener?.call();
      _leakageMon?.dispose();
    }
  }

  /// 1:1: `get event(): Event<T>`
  Event<T> get event {
    _event ??= (dynamic callback, [dynamic thisArgs, dynamic disposables]) {
      if (_leakWarningThreshold != null && _size > _leakWarningThreshold! * _leakWarningThreshold!) {
        final LeakageMonitor? leakageMon = _getLeakageMonitor();
        if (leakageMon != null) {
          final String message =
              '[${leakageMon.name}] REFUSES to accept new listeners because it exceeded its threshold by far ($_size vs ${leakageMon.threshold})';
          // console.warn(message) — no-op in this port.
          final ({String stack, int count}) tuple =
              leakageMon.getMostFrequentStack() ?? (stack: 'UNKNOWN stack', count: -1);
          final String kind = tuple.count / _size > 0.3 ? 'dominated' : 'popular';
          final ListenerRefusalError error = ListenerRefusalError(
              kind,
              '$message. HINT: Stack shows most frequent listener (${tuple.count}-times)',
              tuple.stack,
              _size,
              _options?.leakWarningName);
          final void Function(Object) errorHandler =
              _options?.onListenerError as void Function(Object)? ?? errors.onUnexpectedError;
          errorHandler(error);
          return lifecycle.Disposable.none;
        }
      }

      if (_disposed == true) {
        return lifecycle.Disposable.none;
      }

      // Source: `if (thisArgs) callback = callback.bind(thisArgs)`.
      // Dart has no `this` rebinding; keep callback as-is.
      final UniqueContainer<void Function(dynamic)> contained =
          UniqueContainer<void Function(dynamic)>(callback as void Function(dynamic));

      void Function()? removeMonitor;
      if (_leakWarningThreshold != null &&
          _size >= (_leakWarningThreshold! * 0.2).ceil()) {
        final LeakageMonitor? leakageMon = _getLeakageMonitor();
        if (leakageMon != null && _size + 1 >= leakageMon.threshold) {
          contained.stack = Stacktrace.create();
          removeMonitor = leakageMon.check(contained.stack!, _size + 1);
        }
      }
      if (_enableDisposeWithListenerWarning) {
        contained.stack ??= Stacktrace.create();
      }

      if (_listeners == null) {
        _options?.onWillAddFirstListener?.call();
        _listeners = contained;
        _options?.onDidAddFirstListener?.call();
      } else if (_listeners is UniqueContainer) {
        _deliveryQueue ??= EventDeliveryQueuePrivate();
        _listeners = <Object?>[_listeners, contained];
      } else {
        (_listeners as List<Object?>).add(contained);
      }
      _options?.onDidAddListener?.call();
      _size++;

      final lifecycle.IDisposable result = lifecycle.toDisposable(() {
        removeMonitor?.call();
        _removeListener(contained);
      });
      _addToDisposables(result, disposables);
      return result;
    };
    return _event!;
  }

  void _removeListener(Object listener) {
    _options?.onWillRemoveListener?.call();
    if (_listeners == null) {
      return;
    }
    if (_size == 1) {
      _listeners = null;
      _options?.onDidRemoveLastListener?.call();
      _size = 0;
      return;
    }
    final List<Object?> listeners = _listeners as List<Object?>;
    final int index = listeners.indexOf(listener);
    if (index == -1) {
      throw StateError('Attempted to dispose unknown listener');
    }
    _size--;
    listeners[index] = null;

    final bool adjustDeliveryQueue = _deliveryQueue?.current == this;
    if (_size * compactionThreshold <= listeners.length) {
      int n = 0;
      for (int i = 0; i < listeners.length; i++) {
        if (listeners[i] != null) {
          listeners[n++] = listeners[i];
        } else if (adjustDeliveryQueue && n < _deliveryQueue!.end) {
          _deliveryQueue!.end--;
          if (n < _deliveryQueue!.i) {
            _deliveryQueue!.i--;
          }
        }
      }
      // JS `listeners.length = n`; Dart list is growable — truncate via removeRange.
      if (listeners.length > n) {
        listeners.removeRange(n, listeners.length);
      }
    }
  }

  void _deliver(UniqueContainer<void Function(dynamic)>? listener, dynamic value) {
    if (listener == null) {
      return;
    }
    final void Function(Object)? errorHandler =
        _options?.onListenerError as void Function(Object)? ?? errors.onUnexpectedError;
    try {
      listener.value(value);
    } catch (e) {
      errorHandler?.call(e);
    }
  }

  void _deliverQueue(EventDeliveryQueuePrivate dq) {
    final List<Object?> listeners = dq.current!._listeners as List<Object?>;
    while (dq.i < dq.end) {
      final Object? l = listeners[dq.i++];
      if (l is UniqueContainer) {
        _deliver(l as UniqueContainer<void Function(dynamic)>, dq.value);
      }
    }
    dq.reset();
  }

  /// 1:1: `fire(event: T)`
  void fire(T event) {
    if (_deliveryQueue?.current != null) {
      _deliverQueue(_deliveryQueue!);
      _perfMon?.stop();
    }
    _perfMon?.start(_size);

    if (_listeners == null) {
      // no-op
    } else if (_listeners is UniqueContainer) {
      _deliver(_listeners as UniqueContainer<void Function(dynamic)>, event);
    } else {
      final EventDeliveryQueuePrivate dq = _deliveryQueue!;
      dq.enqueue(this, event, (_listeners as List).length);
      _deliverQueue(dq);
    }
    _perfMon?.stop();
  }

  bool hasListeners() => _size > 0;
}

// ---------------------------------------------------------------------------
// EventDeliveryQueue
// ---------------------------------------------------------------------------

/// 1:1: `export interface EventDeliveryQueue`
abstract class EventDeliveryQueue {
  bool get isEventDeliveryQueue;
}

EventDeliveryQueue createEventDeliveryQueue() => EventDeliveryQueuePrivate();

/// 1:1: `class EventDeliveryQueuePrivate`
class EventDeliveryQueuePrivate implements EventDeliveryQueue {
  int i = -1;
  int end = 0;
  Emitter<dynamic>? current;
  dynamic value;

  @override
  bool get isEventDeliveryQueue => true;

  void enqueue<T>(Emitter<T> emitter, T value, int end) {
    this.i = 0;
    this.end = end;
    this.current = emitter as Emitter<dynamic>;
    this.value = value;
  }

  void reset() {
    i = end;
    current = null;
    value = null;
  }
}

// ---------------------------------------------------------------------------
// AsyncEmitter
// ---------------------------------------------------------------------------

/// 1:1: `export interface IWaitUntil`
abstract class IWaitUntil {
  cancellation.CancellationToken get token;
  void waitUntil(Future<dynamic> thenable);
}

/// 1:1: `export type IWaitUntilData<T> = Omit<Omit<T,'waitUntil'>,'token'>`
typedef IWaitUntilData<T> = T;

/// 1:1: `export class AsyncEmitter<T extends IWaitUntil>`
class AsyncEmitter<T extends IWaitUntil> extends Emitter<T> {
  linkedList.LinkedList<dynamic>? _asyncDeliveryQueue;

  AsyncEmitter([EmitterOptions? options]) : super(options);

  Future<void> fireAsync(
    IWaitUntilData<T> data,
    cancellation.CancellationToken token, [
    Future<dynamic> Function(Future<dynamic> p, Function listener)? promiseJoin,
  ]) async {
    if (_listeners == null) {
      return;
    }
    _asyncDeliveryQueue ??= linkedList.LinkedList<dynamic>();
    forEachListener(_listeners!, (ListenerContainer<T> listener) {
      _asyncDeliveryQueue!.push(<dynamic>[listener.value, data]);
    });

    while (_asyncDeliveryQueue!.size > 0 && !token.isCancellationRequested) {
      final List<dynamic> entry = _asyncDeliveryQueue!.shift() as List<dynamic>;
      final void Function(dynamic) listener = entry[0] as void Function(dynamic);
      final dynamic eventData = entry[1];
      final List<Future<dynamic>> thenables = <Future<dynamic>>[];
      bool frozen = false;

      final Map<String, dynamic> event = <String, dynamic>{
        ...(eventData as Map<String, dynamic>),
        'token': token,
        'waitUntil': (Future<dynamic> p) {
          if (frozen) {
            throw StateError('waitUntil can NOT be called asynchronous');
          }
          if (promiseJoin != null) {
            p = promiseJoin(p, listener);
          }
          thenables.add(p);
        },
      };

      try {
        listener(event);
      } catch (e) {
        errors.onUnexpectedError(e);
        continue;
      }
      frozen = true;
      await Future.wait(thenables, eagerError: false).then((List<dynamic> values) {});
    }
  }
}

// ---------------------------------------------------------------------------
// PauseableEmitter / DebounceEmitter / MicrotaskEmitter
// ---------------------------------------------------------------------------

class EmitterOptionsWithMerge<T> extends EmitterOptions {
  T Function(List<T> input)? merge;
  EmitterOptionsWithMerge([this.merge]);
}

/// 1:1: `export class PauseableEmitter<T>`
class PauseableEmitter<T> extends Emitter<T> {
  int _isPaused = 0;
  final linkedList.LinkedList<T> _eventQueue = linkedList.LinkedList<T>();
  T Function(List<T> input)? _mergeFn;

  bool get isPaused => _isPaused != 0;

  PauseableEmitter([EmitterOptions? options]) : super(options) {
    if (options is EmitterOptionsWithMerge<T>) {
      _mergeFn = options.merge;
    }
  }

  void pause() {
    _isPaused++;
  }

  void resume() {
    if (_isPaused != 0 && --_isPaused == 0) {
      if (_mergeFn != null) {
        if (_eventQueue.size > 0) {
          final List<T> events = List<T>.from(_eventQueue.iterable);
          _eventQueue.clear();
          super.fire(_mergeFn!(events));
        }
      } else {
        while (_isPaused == 0 && _eventQueue.size != 0) {
          super.fire(_eventQueue.shift()!);
        }
      }
    }
  }

  @override
  void fire(T event) {
    if (_size != 0) {
      if (_isPaused != 0) {
        _eventQueue.push(event);
      } else {
        super.fire(event);
      }
    }
  }
}

/// 1:1: `export class DebounceEmitter<T>`
class DebounceEmitter<T> extends PauseableEmitter<T> {
  int _delay = 100;
  Timer? _handle;

  DebounceEmitter(EmitterOptionsWithMerge<T> options) : super(options) {
    _delay = options.delay ?? 100;
  }

  @override
  void fire(T event) {
    if (_handle == null) {
      pause();
      _handle = Timer(Duration(milliseconds: _delay), () {
        _handle = null;
        resume();
      });
    }
    super.fire(event);
  }
}

extension _DelayOnOptions on EmitterOptionsWithMerge {
  int? get delay => null;
}

/// 1:1: `export class MicrotaskEmitter<T>`
class MicrotaskEmitter<T> extends Emitter<T> {
  final List<T> _queuedEvents = <T>[];
  T Function(List<T> input)? _mergeFn;

  MicrotaskEmitter([EmitterOptions? options]) : super(options) {
    if (options is EmitterOptionsWithMerge<T>) {
      _mergeFn = options.merge;
    }
  }

  @override
  void fire(T event) {
    if (!hasListeners()) {
      return;
    }
    _queuedEvents.add(event);
    if (_queuedEvents.length == 1) {
      scheduleMicrotask(() {
        if (_mergeFn != null) {
          super.fire(_mergeFn!(_queuedEvents));
        } else {
          for (final T e in List<T>.from(_queuedEvents)) {
            super.fire(e);
          }
        }
        _queuedEvents.clear();
      });
    }
  }
}

// ---------------------------------------------------------------------------
// EventMultiplexer / DynamicListEventMultiplexer
// ---------------------------------------------------------------------------

/// 1:1: `export class EventMultiplexer<T>`
class EventMultiplexer<T> implements lifecycle.IDisposable {
  late final Emitter<T> emitter;
  bool hasListeners = false;
  List<_MultiplexEntry<T>> events = <_MultiplexEntry<T>>[];

  EventMultiplexer() {
    emitter = Emitter<T>(EmitterOptions(
      onWillAddFirstListener: () => onFirstListenerAdd(),
      onDidRemoveLastListener: () => onLastListenerRemove(),
    ));
  }

  Event<T> get event => emitter.event;

  lifecycle.IDisposable add(Event<T> event) {
    final _MultiplexEntry<T> e = _MultiplexEntry<T>(event, null);
    events.add(e);
    if (hasListeners) {
      hook(e);
    }
    void disposeFn() {
      if (hasListeners) {
        unhook(e);
      }
      final int idx = events.indexOf(e);
      events.removeAt(idx);
    }
    return lifecycle.toDisposable(functional.createSingleCallFunction(disposeFn));
  }

  void onFirstListenerAdd() {
    hasListeners = true;
    for (final _MultiplexEntry<T> e in events) {
      hook(e);
    }
  }

  void onLastListenerRemove() {
    hasListeners = false;
    for (final _MultiplexEntry<T> e in events) {
      unhook(e);
    }
  }

  void hook(_MultiplexEntry<T> e) {
    e.listener = e.event((dynamic r) => emitter.fire(r as T));
  }

  void unhook(_MultiplexEntry<T> e) {
    e.listener?.dispose();
    e.listener = null;
  }

  @override
  void dispose() {
    emitter.dispose();
    for (final _MultiplexEntry<T> e in events) {
      e.listener?.dispose();
    }
    events = <_MultiplexEntry<T>>[];
  }
}

class _MultiplexEntry<T> {
  final Event<T> event;
  lifecycle.IDisposable? listener;
  _MultiplexEntry(this.event, this.listener);
}

/// 1:1: `interface IDynamicListEventMultiplexer`
abstract class IDynamicListEventMultiplexer<TEventType> implements lifecycle.IDisposable {
  Event<TEventType> get event;
}

/// 1:1: `export class DynamicListEventMultiplexer`
class DynamicListEventMultiplexer<TItem, TEventType>
    implements IDynamicListEventMultiplexer<TEventType> {
  final lifecycle.DisposableStore _store = lifecycle.DisposableStore();

  @override
  late final Event<TEventType> event;

  DynamicListEventMultiplexer(
    List<TItem> items,
    Event<TItem> onAddItem,
    Event<TItem> onRemoveItem,
    Event<TEventType> Function(TItem item) getEvent,
  ) {
    final EventMultiplexer<TEventType> multiplexer =
        _store.add(EventMultiplexer<TEventType>());
    final lifecycle.DisposableMap<TItem, lifecycle.IDisposable> itemListeners =
        _store.add(lifecycle.DisposableMap<TItem, lifecycle.IDisposable>());

    void addItem(TItem instance) {
      itemListeners.set(instance, multiplexer.add(getEvent(instance)));
    }

    for (final TItem instance in items) {
      addItem(instance);
    }
    _store.add(onAddItem((dynamic instance) => addItem(instance as TItem)));
    _store.add(onRemoveItem((dynamic instance) {
      itemListeners.deleteAndDispose(instance as TItem);
    }));
    event = multiplexer.event;
  }

  @override
  void dispose() {
    _store.dispose();
  }
}

// ---------------------------------------------------------------------------
// EventBufferer
// ---------------------------------------------------------------------------

/// 1:1: `export class EventBufferer`
class EventBufferer {
  final List<_BufferData> data = <_BufferData>[];

  /// 1:1: `wrapEvent` (overloads collapsed)
  Event<dynamic> wrapEvent<O>(
    Event<dynamic> event, [
    O Function(O? last, dynamic event)? reduce,
    O? initial,
  ]) =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
        return event((dynamic i) {
          final _BufferData? data = this.data.isEmpty ? null : this.data.last;

          if (reduce == null) {
            if (data != null) {
              data.buffers.add(() => listener(i));
            } else {
              listener(i);
            }
            return;
          }

          if (data == null) {
            listener(reduce(initial, i));
            return;
          }

          data.items ??= <dynamic>[];
          data.items!.add(i);
          if (data.buffers.isEmpty) {
            data.buffers.add(() {
              data.reducedResult ??= initial != null
                  ? data.items!.fold<dynamic>(initial, (dynamic acc, dynamic e) => reduce(acc as O, e) as dynamic)
                  : data.items!.fold<dynamic>(null, (dynamic acc, dynamic e) => reduce(acc, e) as dynamic);
              listener(data.reducedResult);
            });
          }
        }, null, disposables);
      };

  /// 1:1: `bufferEvents<R = void>(fn)`
  R bufferEvents<R>(R Function() fn) {
    final _BufferData data = _BufferData(<void Function()>[]);
    this.data.add(data);
    final R r = fn();
    this.data.removeLast();
    for (final void Function() flush in data.buffers) {
      flush();
    }
    return r;
  }
}

class _BufferData {
  final List<void Function()> buffers;
  List<dynamic>? items;
  dynamic reducedResult;
  _BufferData(this.buffers);
}

// ---------------------------------------------------------------------------
// Relay / ValueWithChangeEvent / trackSetChanges
// ---------------------------------------------------------------------------

/// 1:1: `export class Relay<T>`
class Relay<T> implements lifecycle.IDisposable {
  bool listening = false;
  Event<T> inputEvent = eventNone;
  lifecycle.IDisposable inputEventListener = lifecycle.Disposable.none;

  late final Emitter<T> emitter;
  late final Event<T> event;

  Relay() {
    emitter = Emitter<T>(EmitterOptions(
      onDidAddFirstListener: () {
        listening = true;
        inputEventListener = inputEvent((dynamic e) => emitter.fire(e), emitter);
      },
      onDidRemoveLastListener: () {
        listening = false;
        inputEventListener.dispose();
      },
    ));
    event = emitter.event;
  }

  set input(Event<T> event) {
    inputEvent = event;
    if (listening) {
      inputEventListener.dispose();
      inputEventListener = event((dynamic e) => emitter.fire(e), emitter);
    }
  }

  @override
  void dispose() {
    inputEventListener.dispose();
    emitter.dispose();
  }
}

/// 1:1: `export interface IValueWithChangeEvent<T>`
abstract class IValueWithChangeEvent<T> {
  Event<void> get onDidChange;
  T get value;
}

/// 1:1: `export class ValueWithChangeEvent<T>`
class ValueWithChangeEvent<T> implements IValueWithChangeEvent<T> {
  static IValueWithChangeEvent<T> constValue<T>(T value) =>
      ConstValueWithChangeEvent<T>(value);

  final Emitter<void> _onDidChange = Emitter<void>();
  @override
  late final Event<void> onDidChange;

  T _value;
  ValueWithChangeEvent(this._value) {
    onDidChange = _onDidChange.event;
  }

  @override
  T get value => _value;

  set value(T value) {
    if (value != _value) {
      _value = value;
      _onDidChange.fire(null);
    }
  }
}

/// 1:1: `class ConstValueWithChangeEvent<T>`
class ConstValueWithChangeEvent<T> implements IValueWithChangeEvent<T> {
  @override
  final Event<void> onDidChange = eventNone;
  @override
  final T value;
  ConstValueWithChangeEvent(this.value);
}

/// 1:1: `export function trackSetChanges`
lifecycle.IDisposable trackSetChanges<T>(
  Set<T> Function() getData,
  Event<dynamic> onDidChangeData,
  lifecycle.IDisposable Function(T d) handleItem,
) {
  final lifecycle.DisposableMap<T, lifecycle.IDisposable> map =
      lifecycle.DisposableMap<T, lifecycle.IDisposable>();
  Set<T> oldData = getData().toSet();
  for (final T d in oldData) {
    map.set(d, handleItem(d));
  }
  final lifecycle.DisposableStore store = lifecycle.DisposableStore();
  store.add(onDidChangeData((dynamic _) {
    final Set<T> newData = getData().toSet();
    final ({List<T> removed, List<T> added}) diff = collections.diffSets(oldData, newData);
    for (final T r in diff.removed) {
      map.deleteAndDispose(r);
    }
    for (final T a in diff.added) {
      map.set(a, handleItem(a));
    }
    oldData = newData.toSet();
  }));
  store.add(map);
  return store;
}

void _addToDisposables(lifecycle.IDisposable result, dynamic disposables) {
  if (disposables is lifecycle.DisposableStore) {
    disposables.add(result);
  } else if (disposables is List) {
    disposables.add(result);
  }
}

void _disposeAndRemove(lifecycle.IDisposable result, dynamic disposables) {
  if (disposables is lifecycle.DisposableStore) {
    disposables.delete(result);
  } else if (disposables is List) {
    final int index = disposables.indexOf(result);
    if (index != -1) {
      disposables.removeAt(index);
    }
  }
  result.dispose();
}
