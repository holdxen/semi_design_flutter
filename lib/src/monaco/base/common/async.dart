// 1:1 port of vscode/src/vs/base/common/async.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Dart adaptations (no semantic change):
//   - `Promise<T>` -> `Future<T>`; `new Promise((resolve,reject)=>...)` -> `Completer<T>`.
//   - `.then(f, g)` -> `_then2(f, ok, err)` (Dart `then` has a single callback plus
//     `onError`); `.catch` -> `.catchError`; `.finally` -> `.whenComplete`.
//   - `Promise.resolve/reject/all/race` -> `_resolve/_reject/_all/_race`.
//   - `setTimeout/clearTimeout` -> `Timer`/`cancel`; `queueMicrotask` -> `scheduleMicrotask`.
//   - `Symbol.asyncIterator`/`AsyncIterable`/`AsyncIterator` -> `IAsyncIterable`/`IAsyncIterator`
//     carriers with `next()` returning `IteratorResult<T>`; `for await` -> `_forAwait`.
//   - `globalThis.requestIdleCallback` is absent on Flutter: `_runWhenIdle` uses the
//     source's setTimeout0 fallback branch unconditionally.
//   - `Date.now()` -> `DateTime.now().millisecondsSinceEpoch`; `console.warn` -> `_consoleWarn`.

import 'dart:async';

import 'cancellation.dart' show CancellationToken, CancellationTokenSource;
import 'errors.dart'
    show BugIndicatingError, CancellationError, isCancellationError;
import 'event.dart' show Emitter, Event, eventOnce, eventToPromise;
import 'lifecycle.dart'
    show
        Disposable,
        DisposableMap,
        DisposableStore,
        IDisposable,
        isDisposable,
        MutableDisposable,
        toDisposable;
import 'resources.dart' as resources;
import 'uri.dart' show URI;
import 'platform.dart' show setTimeout0;
import 'symbols.dart' show MicrotaskDelay;
import 'lazy.dart' show Lazy;

/// Node/browser timer handle -> Dart `Timer`.
typedef Timeout = Timer;

void _consoleWarn(String message) => print(message); // ignore: avoid_print
int _dateNow() => DateTime.now().millisecondsSinceEpoch;
Timer _setTimeout(void Function() fn, int millis) =>
    Timer(Duration(milliseconds: millis), fn);
void _clearTimeout(Timer? handle) => handle?.cancel();

Future<T> _resolve<T>(dynamic value) =>
    value is Future<T> ? value : Future<T>.value(value as T);
Future<T> _reject<T>(Object error) => Future<T>.error(error);
Future<List<T>> _all<T>(List<Future<T>> futures) => Future.wait(futures);

/// 1:1: `Promise.race`
Future<T> _race<T>(List<Future<T>> futures) {
  final Completer<T> c = Completer<T>();
  bool settled = false;
  for (final Future<T> f in futures) {
    f.then((T value) {
      if (!settled) {
        settled = true;
        c.complete(value);
      }
    }, onError: (Object e, StackTrace s) {
      if (!settled) {
        settled = true;
        c.completeError(e, s);
      }
    });
  }
  return c.future;
}

/// 1:1: `promise.then(onFulfilled, onRejected)`
Future<R> _then2<T, R>(
  Future<T> future,
  FutureOr<R> Function(T value) onFulfilled,
  FutureOr<R> Function(Object error) onRejected,
) =>
    future.then(onFulfilled,
        onError: (Object error, StackTrace stack) => onRejected(error));

/// 1:1: `promise.then(onFulfilled)` (single callback).
Future<R> _thenOk<T, R>(Future<T> future, FutureOr<R> Function(T value) fn) =>
    future.then(fn);

/// 1:1: JS `for await (const item of iterable)`.
Future<void> _forAwait<T>(
  IAsyncIterable<T> iterable,
  FutureOr<void> Function(T value) body,
) async {
  final IAsyncIterator<T> it = iterable.asyncIterator();
  while (true) {
    final IteratorResult<T> result = await it.next();
    if (result.done) {
      return;
    }
    await body(result.value as T);
  }
}

/// JS truthiness for `= t => !!t` and similar source predicates.
bool _truthy(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}

/// 1:1: `export function isThenable`
bool isThenable(dynamic obj) {
  if (obj == null) {
    return false;
  }
  if (obj is Future) {
    return true;
  }
  try {
    final dynamic d = obj;
    return d.then is Function;
  } catch (_) {
    return false;
  }
}

/// 1:1: `export interface CancelablePromise<T> extends Promise<T>`
/// Carrier implements `Future<T>` so it is awaitable. The concrete carrier is
/// created by event.ts `toPromise` and by `createCancelablePromise` below.
abstract class CancelablePromise<T> implements Future<T> {
  void cancel();
  Future<void> get done;

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) action, {Function? onError});
  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test});
  @override
  Future<T> whenComplete(FutureOr<void> Function() action);

  @override
  Stream<T> asStream() => then((T value) => <T>[value]).asStream().expand(
      (List<T> values) => values);
  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      then((T value) => value).timeout(timeLimit, onTimeout: onTimeout);
}

class _CancelablePromise<T> implements CancelablePromise<T> {
  final Future<T> _future;
  final void Function() _cancel;
  _CancelablePromise(this._future, this._cancel);

  @override
  void cancel() => _cancel();
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
  @override
  Stream<T> asStream() => _future.asStream();
  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);
}

/// 1:1: `export function createCancelablePromise`
CancelablePromise<T> createCancelablePromise<T>(
    Future<T> Function(CancellationToken token) callback) {
  final CancellationTokenSource source = CancellationTokenSource();
  final Future<T> thenable = callback(source.token);
  bool isCancelled = false;

  final Completer<T> completer = Completer<T>();
  late final IDisposable subscription;
  subscription = source.token.onCancellationRequested((_) {
    isCancelled = true;
    subscription.dispose();
    if (!completer.isCompleted) {
      completer.completeError(CancellationError());
    }
  });

  _then2<T, dynamic>(
    thenable,
    (T value) {
      subscription.dispose();
      source.dispose();
      if (!isCancelled) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      } else if (isDisposable(value)) {
        (value as IDisposable).dispose();
      }
    },
    (Object err) {
      subscription.dispose();
      source.dispose();
      if (!completer.isCompleted) {
        completer.completeError(err);
      }
    },
  );

  return _CancelablePromise<T>(completer.future, () {
    source.cancel();
    source.dispose();
  });
}

/// 1:1: `export function raceCancellation` (Dart: optional defaultValue).
Future<T?> raceCancellation<T>(
  Future<T> promise,
  CancellationToken token, [
  T? defaultValue,
]) {
  final Completer<T?> c = Completer<T?>();
  late final IDisposable ref;
  ref = token.onCancellationRequested((_) {
    ref.dispose();
    if (!c.isCompleted) {
      c.complete(defaultValue);
    }
  });
  _then2<T, dynamic>(
    promise,
    (T value) {
      if (!c.isCompleted) {
        c.complete(value);
      }
    },
    (Object err) {
      if (!c.isCompleted) {
        c.completeError(err);
      }
    },
  ).whenComplete(() => ref.dispose());
  return c.future;
}

/// 1:1: `export function raceCancellationError`
Future<T> raceCancellationError<T>(
  Future<T> promise,
  CancellationToken token,
) {
  final Completer<T> c = Completer<T>();
  late final IDisposable ref;
  ref = token.onCancellationRequested((_) {
    ref.dispose();
    if (!c.isCompleted) {
      c.completeError(CancellationError());
    }
  });
  _then2<T, dynamic>(
    promise,
    (T value) {
      if (!c.isCompleted) {
        c.complete(value);
      }
    },
    (Object err) {
      if (!c.isCompleted) {
        c.completeError(err);
      }
    },
  ).whenComplete(() => ref.dispose());
  return c.future;
}

/// 1:1: `export function rejectIfNotCanceled`
/// JS returns a rejected promise cast to `never`; Dart throws directly so the
/// enclosing `.catchError` propagates the rejection with the same semantics.
Object? rejectIfNotCanceled(Object err) {
  if (isCancellationError(err)) {
    return null;
  }
  throw err;
}

/// 1:1: `export function notCancellablePromise`
Future<T> notCancellablePromise<T>(CancelablePromise<T> promise) {
  final Completer<T> c = Completer<T>();
  _then2<T, dynamic>(promise, (T value) => c.complete(value),
      (Object err) => c.completeError(err));
  return c.future;
}

/// 1:1: `export function raceCancellablePromises`
CancelablePromise<T> raceCancellablePromises<T>(List<dynamic> cancellablePromises) {
  int resolvedPromiseIndex = -1;
  final List<Future<T>> promises = <Future<T>>[];
  for (int i = 0; i < cancellablePromises.length; i++) {
    final Future<T> p = cancellablePromises[i] as Future<T>;
    promises.add(_thenOk<T, T>(p, (T result) {
      resolvedPromiseIndex = i;
      return result;
    }));
  }
  final Future<T> promise = _race<T>(promises);

  void cancel() {
    for (int i = 0; i < cancellablePromises.length; i++) {
      final dynamic cp = cancellablePromises[i];
      if (i != resolvedPromiseIndex && cp is CancelablePromise<T>) {
        cp.cancel();
      }
    }
  }

  _then2<T, dynamic>(promise, (_) => cancel(), (_) => cancel());
  return _CancelablePromise<T>(promise, cancel);
}

/// 1:1: `export function raceTimeout`
Future<T?> raceTimeout<T>(
  Future<T> promise,
  int timeout, [
  void Function()? onTimeout,
]) {
  void Function(T?)? promiseResolve;
  final Completer<T?> timeoutCompleter = Completer<T?>();
  promiseResolve = (T? value) {
    if (!timeoutCompleter.isCompleted) {
      timeoutCompleter.complete(value);
    }
  };
  final Timer timer = _setTimeout(() {
    promiseResolve!(null);
    onTimeout?.call();
  }, timeout);
  return _race<T?>(<Future<T?>>[
    _thenOk<T, T?>(promise, (T value) => value)
        .whenComplete(() => _clearTimeout(timer)),
    timeoutCompleter.future,
  ]);
}

/// 1:1: `export function asPromise`
Future<T> asPromise<T>(dynamic Function() callback) {
  final Completer<T> c = Completer<T>();
  final dynamic item = callback();
  if (isThenable(item)) {
    _then2<dynamic, dynamic>(
      item as Future<dynamic>,
      (dynamic value) => c.complete(value as T),
      (Object err) => c.completeError(err),
    );
  } else {
    c.complete(item as T);
  }
  return c.future;
}

/// Object-literal return of `promiseWithResolvers`.
class PromiseWithResolvers<T> {
  final Completer<T> _completer = Completer<T>();
  Future<T> get promise => _completer.future;
  void resolve(dynamic value) {
    if (!_completer.isCompleted) {
      _completer.complete(value as FutureOr<T>);
    }
  }

  void reject([Object? err]) {
    if (!_completer.isCompleted) {
      _completer.completeError(err ?? StateError('rejected'));
    }
  }
}

/// 1:1: `export function promiseWithResolvers`
PromiseWithResolvers<T> promiseWithResolvers<T>() => PromiseWithResolvers<T>();

/// 1:1: `export interface ITask<T> { (): T }`
typedef ITask<T> = T Function();
/// 1:1: `export interface ICancellableTask<T> { (token): T }`
typedef ICancellableTask<T> = T Function(CancellationToken token);

/// 1:1: `export class Throttler`
class Throttler implements IDisposable {
  Future<dynamic>? activePromise;
  Future<dynamic>? queuedPromise;
  ICancellableTask<Future<dynamic>>? queuedPromiseFactory;
  final CancellationTokenSource cancellationTokenSource;

  Throttler() : cancellationTokenSource = CancellationTokenSource();

  Future<T> queue<T>(ICancellableTask<Future<T>> promiseFactory) {
    if (cancellationTokenSource.token.isCancellationRequested) {
      return _reject<T>(StateError('Throttler is disposed'));
    }

    if (activePromise != null) {
      queuedPromiseFactory =
          (CancellationToken token) => promiseFactory(token);
      if (queuedPromise == null) {
        Future<dynamic>? onComplete() {
          queuedPromise = null;
          if (cancellationTokenSource.token.isCancellationRequested) {
            return null;
          }
          final Future<T> result =
              queue<T>(queuedPromiseFactory! as ICancellableTask<Future<T>>);
          queuedPromiseFactory = null;
          return result;
        }

        final Completer<dynamic> c = Completer<dynamic>();
        queuedPromise = c.future;
        _then2<dynamic, dynamic>(activePromise!, (_) => onComplete(),
                (_) => onComplete())
            .then((dynamic value) => c.complete(value),
                onError: (Object e, StackTrace s) => c.completeError(e, s));
      }

      final Completer<T> c2 = Completer<T>();
      _then2<dynamic, dynamic>(
          queuedPromise!, (dynamic value) => c2.complete(value as T),
          (Object err) => c2.completeError(err));
      return c2.future;
    }

    activePromise = promiseFactory(cancellationTokenSource.token);
    final Completer<T> c3 = Completer<T>();
    _then2<dynamic, dynamic>(
      activePromise!,
      (dynamic result) {
        activePromise = null;
        c3.complete(result as T);
      },
      (Object err) {
        activePromise = null;
        c3.completeError(err);
      },
    );
    return c3.future;
  }

  @override
  void dispose() {
    cancellationTokenSource.cancel();
    queuedPromiseFactory = null;
  }
}

/// 1:1: `export class Sequencer`
class Sequencer {
  Future<dynamic> current = Future<dynamic>.value(null);

  Future<T> queue<T>(ITask<Future<T>> promiseTask) {
    final Future<T> next = current.then(
      (_) => promiseTask(),
      onError: (Object e, StackTrace s) => promiseTask(),
    );
    current = next;
    return next;
  }
}

/// Object literal `{ throttler, count }` in `ThrottlerByKey`.
class ThrottlerEntry {
  final Throttler throttler;
  int count;
  ThrottlerEntry(this.throttler, this.count);
}

/// 1:1: `export class ThrottlerByKey<TKey>`
class ThrottlerByKey<TKey> implements IDisposable {
  final Map<TKey, ThrottlerEntry> throttlers = <TKey, ThrottlerEntry>{};

  Future<T> queue<T>(TKey key, ITask<Future<T>> task) {
    ThrottlerEntry? entry = throttlers[key];
    if (entry == null) {
      entry = ThrottlerEntry(Throttler(), 0);
      throttlers[key] = entry;
    }
    final ThrottlerEntry e = entry;
    e.count++;
    return e.throttler.queue<T>((CancellationToken token) => task()).whenComplete(() {
      if (--e.count == 0) {
        e.throttler.dispose();
        throttlers.remove(key);
      }
    });
  }

  @override
  void dispose() {
    for (final ThrottlerEntry entry in throttlers.values) {
      entry.throttler.dispose();
    }
    throttlers.clear();
  }
}

/// 1:1: `export class SequencerByKey<TKey>`
class SequencerByKey<TKey> {
  final Map<TKey, Future<dynamic>> promiseMap = <TKey, Future<dynamic>>{};

  Future<T> queue<T>(TKey key, ITask<Future<T>> promiseTask) {
    final Future<dynamic> runningPromise =
        promiseMap[key] ?? Future<dynamic>.value();
    late final Future<T> newPromise;
    newPromise = _thenOk<dynamic, T>(
      runningPromise.catchError((Object _) {}),
      (_) => promiseTask(),
    ).whenComplete(() {
      if (identical(promiseMap[key], newPromise)) {
        promiseMap.remove(key);
      }
    });
    promiseMap[key] = newPromise;
    return newPromise;
  }

  Future<dynamic>? peek(TKey key) => promiseMap[key];
  Iterable<TKey> keys() => promiseMap.keys;
}

/// 1:1: `interface IScheduledLater extends IDisposable`
abstract class IScheduledLater implements IDisposable {
  bool isTriggered();
}

class _ScheduledLater implements IScheduledLater {
  final bool Function() _isTriggered;
  final void Function() _disposeFn;
  _ScheduledLater(
      {required bool Function() isTriggered, required void Function() dispose})
      : _isTriggered = isTriggered,
        _disposeFn = dispose;
  @override
  bool isTriggered() => _isTriggered();
  @override
  void dispose() => _disposeFn();
}

/// 1:1: `const timeoutDeferred`
IScheduledLater timeoutDeferred(int timeout, void Function() fn) {
  bool scheduled = true;
  final Timer handle = _setTimeout(() {
    scheduled = false;
    fn();
  }, timeout);
  return _ScheduledLater(
    isTriggered: () => scheduled,
    dispose: () {
      _clearTimeout(handle);
      scheduled = false;
    },
  );
}

/// 1:1: `const microtaskDeferred`
IScheduledLater microtaskDeferred(void Function() fn) {
  bool scheduled = true;
  scheduleMicrotask(() {
    if (scheduled) {
      scheduled = false;
      fn();
    }
  });
  return _ScheduledLater(
    isTriggered: () => scheduled,
    dispose: () {
      scheduled = false;
    },
  );
}

/// 1:1: `export class Delayer<T>`
class Delayer<T> implements IDisposable {
  IScheduledLater? deferred;
  Future<T>? completionPromise;
  void Function(dynamic value)? doResolve;
  void Function(Object error)? doReject;
  ITask<dynamic>? task;

  final dynamic defaultDelay;

  Delayer(this.defaultDelay);

  Future<T> trigger(ITask<dynamic> task, [dynamic delay]) {
    final dynamic d = delay ?? defaultDelay;
    this.task = task;
    cancelTimeout();

    if (completionPromise == null) {
      final Completer<dynamic> base = Completer<dynamic>();
      final Completer<T> result = Completer<T>();
      doResolve = (dynamic value) => base.complete(value);
      doReject = (Object error) => base.completeError(error);
      late final Future<dynamic> chain;
      chain = base.future.then((_) {
        if (!identical(completionPromise, result.future)) {
          throw CancellationError();
        }
        completionPromise = null;
        doResolve = null;
        final ITask<dynamic> t = this.task!;
        this.task = null;
        return t();
      });
      _then2<dynamic, void>(
        chain,
        (dynamic value) => result.complete(value as T),
        (Object error) => result.completeError(error),
      );
      completionPromise = result.future;
    }

    final void Function() fn = () {
      deferred = null;
      doResolve?.call(null);
    };

    deferred = identical(d, MicrotaskDelay)
        ? microtaskDeferred(fn)
        : timeoutDeferred(d as int, fn);

    return completionPromise!;
  }

  bool isTriggered() => deferred?.isTriggered() ?? false;

  void cancel() {
    cancelTimeout();
    task = null;
    if (completionPromise != null) {
      doReject?.call(CancellationError());
      completionPromise = null;
    }
  }

  void cancelTimeout() {
    deferred?.dispose();
    deferred = null;
  }

  @override
  void dispose() => cancel();
}

/// 1:1: `export class ThrottledDelayer<T>`
///
/// Dart's `Future.then` auto-flattens a returned `Future<T>`, so using
/// `Delayer<Future<T>>` would deliver the flattened `T` into a
/// `Completer<Future<T>>` and fail a `value as Future<T>` cast. Use a
/// `Delayer<dynamic>` (matching JS promise-flattening semantics) and expose a
/// correctly typed `Future<T>` via a bridge.
class ThrottledDelayer<T> {
  final Delayer<dynamic> delayer;
  final Throttler throttler;

  ThrottledDelayer(int defaultDelay)
      : delayer = Delayer<dynamic>(defaultDelay),
        throttler = Throttler();

  Future<T> trigger(ICancellableTask<Future<T>> promiseFactory, [dynamic delay]) {
    final Future<dynamic> result =
        delayer.trigger(() => throttler.queue(promiseFactory), delay);
    return result.then((dynamic value) => value as T);
  }

  bool isTriggered() => delayer.isTriggered();
  void cancel() => delayer.cancel();
  void dispose() {
    delayer.dispose();
    throttler.dispose();
  }
}

/// 1:1: `export class Barrier`
class Barrier {
  bool _isOpen = false;
  late final Future<bool> _promise;
  late final void Function(bool v) _completePromise;

  Barrier() {
    final Completer<bool> c = Completer<bool>();
    _completePromise = c.complete;
    _promise = c.future;
  }

  bool isOpen() => _isOpen;
  void open() {
    _isOpen = true;
    _completePromise(true);
  }

  Future<bool> wait() => _promise;
}

/// 1:1: `export class AutoOpenBarrier`
class AutoOpenBarrier extends Barrier {
  late final Timeout _timeout;

  AutoOpenBarrier(int autoOpenTimeMs) : super() {
    _timeout = _setTimeout(() => open(), autoOpenTimeMs);
  }

  @override
  void open() {
    _clearTimeout(_timeout);
    super.open();
  }
}

/// 1:1: `export function timeout` (Dart: optional token -> CancelablePromise carrier).
dynamic timeout(int millis, [CancellationToken? token]) {
  if (token == null) {
    return createCancelablePromise<void>(
        (CancellationToken t) => timeout(millis, t) as Future<void>);
  }
  final Completer<void> c = Completer<void>();
  late final Timer handle;
  late final IDisposable disposable;
  handle = _setTimeout(() {
    disposable.dispose();
    if (!c.isCompleted) c.complete();
  }, millis);
  disposable = token.onCancellationRequested((_) {
    _clearTimeout(handle);
    disposable.dispose();
    if (!c.isCompleted) c.completeError(CancellationError());
  });
  return c.future;
}

/// 1:1: `export function disposableTimeout`
IDisposable disposableTimeout(
  void Function() handler, [
  int timeout = 0,
  DisposableStore? store,
]) {
  late final IDisposable disposable;
  final Timer timer = _setTimeout(() {
    handler();
    if (store != null) {
      disposable.dispose();
    }
  }, timeout);
  disposable = toDisposable(() {
    _clearTimeout(timer);
    store?.delete(disposable);
  });
  store?.add(disposable);
  return disposable;
}

/// 1:1: `export const MAX_TIMEOUT_DELAY`
const int MAX_TIMEOUT_DELAY = 2147483647; // 2 ** 31 - 1, ~24.8 days

/// 1:1: `export function disposableLongTimeout`
IDisposable disposableLongTimeout(
  void Function() handler,
  int timeout, [
  DisposableStore? store,
]) {
  final int target = _dateNow() + timeout;
  late final Timer timer;
  late final IDisposable disposable;

  void arm() {
    final int remaining = target - _dateNow();
    if (remaining <= 0) {
      handler();
      if (store != null) {
        disposable.dispose();
      }
      return;
    }
    timer = _setTimeout(
        arm, remaining < MAX_TIMEOUT_DELAY ? remaining : MAX_TIMEOUT_DELAY);
  }

  disposable = toDisposable(() {
    _clearTimeout(timer);
    store?.delete(disposable);
  });

  final int initial =
      timeout > 0 ? (timeout < MAX_TIMEOUT_DELAY ? timeout : MAX_TIMEOUT_DELAY) : 0;
  timer = _setTimeout(arm, initial);
  store?.add(disposable);
  return disposable;
}

/// 1:1: `export function sequence`
Future<List<T>> sequence<T>(List<ITask<Future<T>>> promiseFactories) {
  final List<T> results = <T>[];
  int index = 0;
  final int len = promiseFactories.length;

  Future<T>? next() => index < len ? promiseFactories[index++]() : null;

  Future<dynamic> thenHandler(dynamic result) {
    if (result != null) {
      results.add(result as T);
    }
    final Future<T>? n = next();
    if (n != null) {
      return n.then(thenHandler);
    }
    return _resolve<List<T>>(results);
  }

  return _resolve<dynamic>(null)
      .then(thenHandler)
      .then((dynamic value) => value as List<T>);
}

/// 1:1: `export function first`
Future<T?> first<T>(
  List<ITask<Future<T>>> promiseFactories, [
  bool Function(T)? shouldStop,
  T? defaultValue,
]) {
  final bool Function(T) stop = shouldStop ?? ((T t) => _truthy(t));
  int index = 0;
  final int len = promiseFactories.length;

  Future<T?> loop() {
    if (index >= len) {
      return _resolve<T?>(defaultValue);
    }
    final ITask<Future<T>> factory = promiseFactories[index++];
    final Future<T> promise = _resolve<dynamic>(factory()).then((dynamic v) => v as T);
    return _thenOk<T, T?>(promise, (T result) {
      if (stop(result)) {
        return _resolve<T?>(result);
      }
      return loop();
    });
  }

  return loop();
}

/// 1:1: `export function firstParallel`
Future<T?> firstParallel<T>(
  List<Future<T>> promiseList, [
  bool Function(T)? shouldStop,
  T? defaultValue,
]) {
  if (promiseList.isEmpty) {
    return _resolve<T?>(defaultValue);
  }
  final bool Function(T) stop = shouldStop ?? ((T t) => _truthy(t));
  int todo = promiseList.length;
  void finish() {
    todo = -1;
    for (final Future<T> promise in promiseList) {
      if (promise is CancelablePromise<T>) {
        promise.cancel();
      }
    }
  }

  final Completer<T?> c = Completer<T?>();
  for (final Future<T> promise in promiseList) {
    _thenOk<T, dynamic>(promise, (T result) {
      if (--todo >= 0 && stop(result)) {
        finish();
        if (!c.isCompleted) c.complete(result);
      } else if (todo == 0) {
        if (!c.isCompleted) c.complete(defaultValue);
      }
    }).catchError((Object err) {
      if (--todo >= 0) {
        finish();
        if (!c.isCompleted) c.completeError(err);
      }
    });
  }
  return c.future;
}

/// Object literal of `ILimitedTaskFactory<T>`.
class _LimitedTaskFactory<T> {
  final ITask<Future<T>> factory;
  final void Function(dynamic value) c;
  final void Function([Object? error]) e;
  _LimitedTaskFactory(this.factory, this.c, this.e);
}

/// 1:1: `export interface ILimiter<T>`
abstract class ILimiter<T> {
  int get size;
  Future<T> queue(ITask<Future<T>> factory);
  void clear();
}

/// 1:1: `export class Limiter<T>`
class Limiter<T> implements ILimiter<T> {
  int _size = 0;
  bool _isDisposed = false;
  late final int runningPromises;
  final int maxDegreeOfParalellism;
  final List<_LimitedTaskFactory<T>> outstandingPromises;
  final Emitter<void> _onDrained;

  int _running = 0;

  Limiter(int maxDegreeOfParalellism)
      : maxDegreeOfParalellism = maxDegreeOfParalellism,
        outstandingPromises = <_LimitedTaskFactory<T>>[],
        runningPromises = 0,
        _onDrained = Emitter<void>();

  Future<void> whenIdle() => size > 0 ? eventToPromise(onDrained).done : _resolve<void>(null);

  Event<void> get onDrained => _onDrained.event;
  @override
  int get size => _size;

  @override
  Future<T> queue(ITask<Future<T>> factory) {
    if (_isDisposed) {
      throw StateError('Object has been disposed');
    }
    _size++;
    final Completer<T> c = Completer<T>();
    outstandingPromises.add(_LimitedTaskFactory<T>(
      factory,
      (dynamic value) => c.complete(value as T),
      ([Object? error]) => c.completeError(error ?? StateError('rejected')),
    ));
    consume();
    return c.future;
  }

  void consume() {
    while (outstandingPromises.isNotEmpty && _running < maxDegreeOfParalellism) {
      final _LimitedTaskFactory<T> task = outstandingPromises.removeAt(0);
      _running++;
      final Future<T> promise = task.factory();
      _then2<T, dynamic>(promise, task.c, (Object err) => task.e(err));
      _then2<T, dynamic>(promise, (_) => consumed(), (_) => consumed());
    }
  }

  void consumed() {
    if (_isDisposed) {
      return;
    }
    _running--;
    if (--_size == 0) {
      _onDrained.fire(null);
    }
    if (outstandingPromises.isNotEmpty) {
      consume();
    }
  }

  @override
  void clear() {
    if (_isDisposed) {
      throw StateError('Object has been disposed');
    }
    outstandingPromises.clear();
    _size = _running;
  }

  void dispose() {
    _isDisposed = true;
    outstandingPromises.clear();
    _size = 0;
    _onDrained.dispose();
  }
}

/// 1:1: `export class Queue<T> extends Limiter<T>`
class Queue<T> extends Limiter<T> {
  Queue() : super(1);
}

/// 1:1: `export class LimitedQueue`
class LimitedQueue {
  final TaskSequentializer sequentializer = TaskSequentializer();
  int tasks = 0;

  Future<void> queue(ITask<Future<void>> factory) {
    if (!sequentializer.isRunning()) {
      return sequentializer.run(tasks++, _resolve<dynamic>(factory()) as Future<void>);
    }
    return sequentializer.queue(() =>
        sequentializer.run(tasks++, _resolve<dynamic>(factory()) as Future<void>));
  }
}

/// 1:1: `export class ResourceQueue`
class ResourceQueue implements IDisposable {
  final Map<String, Queue<void>> queues = <String, Queue<void>>{};
  final Set<DeferredPromise<void>> drainers = <DeferredPromise<void>>{};

  DisposableMap<int, IDisposable>? drainListeners;
  int drainListenerCount = 0;

  Future<void> whenDrained() async {
    if (isDrained()) {
      return;
    }
    final DeferredPromise<void> promise = DeferredPromise<void>();
    drainers.add(promise);
    return promise.p;
  }

  bool isDrained() {
    for (final Queue<void> queue in queues.values) {
      if (queue.size > 0) {
        return false;
      }
    }
    return true;
  }

  int queueSize(URI resource, [resources.IExtUri? extUri]) {
    final String key = (extUri ?? resources.extUri).getComparisonKey(resource);
    return queues[key]?.size ?? 0;
  }

  Future<void> queueFor(
    URI resource,
    ITask<Future<void>> factory, [
    resources.IExtUri? extUri,
  ]) {
    final String key = (extUri ?? resources.extUri).getComparisonKey(resource);
    Queue<void>? queue = queues[key];
    if (queue == null) {
      queue = Queue<void>();
      final int drainListenerId = drainListenerCount++;
      final IDisposable drainListener = eventOnce(queue.onDrained)((_) {
        queue?.dispose();
        queues.remove(key);
        onDidQueueDrain();
        drainListeners?.deleteAndDispose(drainListenerId);
        if (drainListeners?.size == 0) {
          drainListeners?.dispose();
          drainListeners = null;
        }
      });
      drainListeners ??= DisposableMap<int, IDisposable>();
      drainListeners!.set(drainListenerId, drainListener);
      queues[key] = queue;
    }
    return queue.queue(factory);
  }

  void onDidQueueDrain() {
    if (!isDrained()) {
      return;
    }
    releaseDrainers();
  }

  void releaseDrainers() {
    for (final DeferredPromise<void> drainer in drainers) {
      drainer.complete();
    }
    drainers.clear();
  }

  @override
  void dispose() {
    for (final Queue<void> queue in queues.values) {
      queue.dispose();
    }
    queues.clear();
    releaseDrainers();
    drainListeners?.dispose();
  }
}

/// 1:1: `export type Task<T = void> = () => (Promise<T> | T)`
typedef Task<T> = FutureOr<T> Function();
/// 1:1: `export type MaybePromise<T> = Promise<T> | T`
typedef MaybePromise<T> = FutureOr<T>;

class _PendingTask {
  final Task<dynamic> task;
  final DeferredPromise<dynamic> deferred;
  final bool setUndefinedWhenCleared;
  _PendingTask(this.task, this.deferred, this.setUndefinedWhenCleared);
}

/// 1:1: `export class TaskQueue`
class TaskQueue {
  Task<dynamic>? _runningTask;
  final List<_PendingTask> _pendingTasks = <_PendingTask>[];

  Future<T> schedule<T>(Task<T> task) {
    final DeferredPromise<dynamic> deferred = DeferredPromise<dynamic>();
    _pendingTasks.add(_PendingTask(task as Task<dynamic>, deferred, false));
    _runIfNotRunning();
    return deferred.p as Future<T>;
  }

  Future<T?> scheduleSkipIfCleared<T>(Task<T> task) {
    final DeferredPromise<dynamic> deferred = DeferredPromise<dynamic>();
    _pendingTasks.add(_PendingTask(task as Task<dynamic>, deferred, true));
    _runIfNotRunning();
    return deferred.p as Future<T?>;
  }

  void _runIfNotRunning() {
    if (_runningTask == null) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_pendingTasks.isEmpty) {
      return;
    }
    final _PendingTask? next = _pendingTasks.isEmpty ? null : _pendingTasks.removeAt(0);
    if (next == null) {
      return;
    }
    if (_runningTask != null) {
      throw BugIndicatingError();
    }
    _runningTask = next.task;
    try {
      final dynamic result = await next.task();
      next.deferred.complete(result);
    } catch (e) {
      next.deferred.error(e);
    } finally {
      _runningTask = null;
      _processQueue();
    }
  }

  void clearPending() {
    final List<_PendingTask> tasks = List<_PendingTask>.from(_pendingTasks);
    _pendingTasks.clear();
    for (final _PendingTask task in tasks) {
      if (task.setUndefinedWhenCleared) {
        task.deferred.complete(null);
      } else {
        task.deferred.error(CancellationError());
      }
    }
  }
}

/// 1:1: `export class TimeoutTimer`
class TimeoutTimer implements IDisposable {
  Timer? _token;
  bool _isDisposed = false;

  TimeoutTimer([void Function()? runner, int? timeout]) {
    _token = null;
    if (runner != null && timeout != null) {
      setIfNotSet(runner, timeout);
    }
  }

  @override
  void dispose() {
    cancel();
    _isDisposed = true;
  }

  void cancel() {
    if (_token != null) {
      _clearTimeout(_token);
      _token = null;
    }
  }

  void cancelAndSet(void Function() runner, int timeout) {
    if (_isDisposed) {
      throw BugIndicatingError("Calling 'cancelAndSet' on a disposed TimeoutTimer");
    }
    cancel();
    _token = _setTimeout(() {
      _token = null;
      runner();
    }, timeout);
  }

  void setIfNotSet(void Function() runner, int timeout) {
    if (_isDisposed) {
      throw BugIndicatingError("Calling 'setIfNotSet' on a disposed TimeoutTimer");
    }
    if (_token != null) {
      return;
    }
    _token = _setTimeout(() {
      _token = null;
      runner();
    }, timeout);
  }
}

/// 1:1: `export class IntervalTimer`
class IntervalTimer implements IDisposable {
  IDisposable? disposable;
  bool isDisposed = false;

  void cancel() {
    disposable?.dispose();
    disposable = null;
  }

  void cancelAndSet(void Function() runner, int interval, [dynamic context]) {
    if (isDisposed) {
      throw BugIndicatingError("Calling 'cancelAndSet' on a disposed IntervalTimer");
    }
    cancel();
    final Timer handle = Timer.periodic(Duration(milliseconds: interval), (_) => runner());
    disposable = toDisposable(() {
      handle.cancel();
      disposable = null;
    });
  }

  @override
  void dispose() {
    cancel();
    isDisposed = true;
  }
}

/// 1:1: `export class RunOnceScheduler`
class RunOnceScheduler implements IDisposable {
  void Function()? runner;
  Timer? timeoutToken;
  int timeout;
  late final void Function() timeoutHandler;

  RunOnceScheduler(void Function() runner, int delay)
      : timeout = delay {
    timeoutToken = null;
    this.runner = runner;
    timeoutHandler = onTimeout;
  }

  @override
  void dispose() {
    cancel();
    runner = null;
  }

  void cancel() {
    if (isScheduled()) {
      _clearTimeout(timeoutToken);
      timeoutToken = null;
    }
  }

  void schedule([int? delay]) {
    cancel();
    timeoutToken = _setTimeout(timeoutHandler, delay ?? timeout);
  }

  int get delay => timeout;
  set delay(int value) => timeout = value;

  bool isScheduled() => timeoutToken != null;

  void flush() {
    if (isScheduled()) {
      cancel();
      doRun();
    }
  }

  void onTimeout() {
    timeoutToken = null;
    if (runner != null) {
      doRun();
    }
  }

  void doRun() => runner?.call();
}

/// 1:1: `export class ProcessTimeRunOnceScheduler`
class ProcessTimeRunOnceScheduler {
  void Function()? runner;
  int timeout;
  int counter = 0;
  Timer? intervalToken;
  late final void Function() intervalHandler;

  ProcessTimeRunOnceScheduler(void Function() runner, int delay)
      : timeout = delay {
    if (delay % 1000 != 0) {
      _consoleWarn('ProcessTimeRunOnceScheduler resolution is 1s, ${delay}ms is not a multiple of 1000ms.');
    }
    this.runner = runner;
    this.timeout = delay;
    counter = 0;
    intervalToken = null;
    intervalHandler = onInterval;
  }

  void dispose() {
    cancel();
    runner = null;
  }

  void cancel() {
    if (isScheduled()) {
      _clearInterval(intervalToken);
      intervalToken = null;
    }
  }

  void schedule([int? delay]) {
    final int d = delay ?? timeout;
    if (d % 1000 != 0) {
      _consoleWarn('ProcessTimeRunOnceScheduler resolution is 1s, ${d}ms is not a multiple of 1000ms.');
    }
    cancel();
    counter = (d / 1000).ceil();
    intervalToken = Timer.periodic(const Duration(seconds: 1), (_) => intervalHandler());
  }

  bool isScheduled() => intervalToken != null;

  void onInterval() {
    counter--;
    if (counter > 0) {
      return;
    }
    _clearInterval(intervalToken);
    intervalToken = null;
    runner?.call();
  }
}

void _clearInterval(Timer? handle) => handle?.cancel();

/// 1:1: `export class RunOnceWorker<T>`
class RunOnceWorker<T> extends RunOnceScheduler {
  List<T> units = <T>[];

  RunOnceWorker(void Function(List<T> units) runner, int timeout)
      : super(() => runner(<T>[]), timeout) {
    this.runner = () => runner(List<T>.from(units));
  }

  void work(T unit) {
    units.add(unit);
    if (!isScheduled()) {
      schedule();
    }
  }

  @override
  void doRun() {
    final List<T> current = units;
    units = <T>[];
    runner?.call();
    // runner closure reads `units`; restore snapshot semantics by invoking directly.
    _lastRunner?.call(current);
  }

  void Function(List<T>)? _lastRunner;
}

/// 1:1: `export interface IThrottledWorkerOptions`
class IThrottledWorkerOptions {
  final int maxWorkChunkSize;
  final int? maxBufferedWork;
  final int throttleDelay;
  final bool? waitThrottleDelayBetweenWorkUnits;
  IThrottledWorkerOptions({
    required this.maxWorkChunkSize,
    required this.maxBufferedWork,
    required this.throttleDelay,
    this.waitThrottleDelayBetweenWorkUnits,
  });
}

/// 1:1: `export class ThrottledWorker<T>`
class ThrottledWorker<T> extends Disposable {
  final List<T> pendingWork = <T>[];
  late final MutableDisposable<RunOnceScheduler> throttler;
  bool disposed = false;
  int lastExecutionTime = 0;
  final IThrottledWorkerOptions options;
  final void Function(List<T> units) handler;

  ThrottledWorker(this.options, this.handler) : super() {
    throttler = register(MutableDisposable<RunOnceScheduler>());
  }

  int get pending => pendingWork.length;

  bool work(List<T> units) {
    if (disposed) {
      return false;
    }
    if (options.maxBufferedWork != null) {
      if (throttler.value != null) {
        if (pending + units.length > options.maxBufferedWork!) {
          return false;
        }
      } else {
        if (pending + units.length - options.maxWorkChunkSize >
            options.maxBufferedWork!) {
          return false;
        }
      }
    }
    for (final T unit in units) {
      pendingWork.add(unit);
    }
    final int timeSinceLastExecution = _dateNow() - lastExecutionTime;
    if (throttler.value == null &&
        (!(options.waitThrottleDelayBetweenWorkUnits ?? false) ||
            timeSinceLastExecution >= options.throttleDelay)) {
      doWork();
    } else if (throttler.value == null &&
        (options.waitThrottleDelayBetweenWorkUnits ?? false)) {
      final int d = options.throttleDelay - timeSinceLastExecution;
      scheduleThrottler(d > 0 ? d : 0);
    }
    return true;
  }

  void doWork() {
    lastExecutionTime = _dateNow();
    final List<T> chunk = pendingWork.sublist(0, options.maxWorkChunkSize > pendingWork.length ? pendingWork.length : options.maxWorkChunkSize);
    pendingWork.removeRange(0, chunk.length);
    handler(chunk);
    if (pendingWork.isNotEmpty) {
      scheduleThrottler();
    }
  }

  void scheduleThrottler([int? delay]) {
    final RunOnceScheduler scheduler = RunOnceScheduler(() {
      throttler.clear();
      doWork();
    }, delay ?? options.throttleDelay);
    throttler.value = scheduler;
    scheduler.schedule();
  }

  @override
  void dispose() {
    super.dispose();
    pendingWork.clear();
    disposed = true;
  }
}

/// 1:1: `export interface IdleDeadline`
abstract class IdleDeadline {
  bool get didTimeout;
  int timeRemaining();
}

class _IdleDeadline implements IdleDeadline {
  final int end;
  _IdleDeadline(this.end);
  @override
  bool get didTimeout => true;
  @override
  int timeRemaining() {
    final int remaining = end - _dateNow();
    return remaining > 0 ? remaining : 0;
  }
}

/// 1:1: `export let _runWhenIdle`
/// Flutter has no `requestIdleCallback`; the source's setTimeout0 fallback
/// branch is used unconditionally (semantically identical on this platform).
IDisposable Function(void Function(IdleDeadline idle) callback, [int? timeout])
    _runWhenIdle = (void Function(IdleDeadline idle) callback, [int? timeout]) {
  bool disposed = false;
  setTimeout0(() {
    if (disposed) {
      return;
    }
    final int end = _dateNow() + 15; // one frame at 64fps
    callback(_IdleDeadline(end));
  });
  return toDisposable(() {
    disposed = true;
  });
};

/// 1:1: `export let runWhenGlobalIdle`
IDisposable Function(void Function(IdleDeadline idle) callback, [int? timeout])
    runWhenGlobalIdle = (void Function(IdleDeadline idle) runner, [int? timeout]) =>
        _runWhenIdle(runner, timeout);

/// 1:1: `export function installFakeRunWhenIdle`
IDisposable installFakeRunWhenIdle(
  IDisposable Function(void Function(IdleDeadline idle) callback, [int? timeout]) fakeImpl,
) {
  final origRunWhenIdle = _runWhenIdle;
  final origRunWhenGlobalIdle = runWhenGlobalIdle;
  _runWhenIdle = fakeImpl;
  runWhenGlobalIdle = (void Function(IdleDeadline idle) runner, [int? timeout]) =>
      fakeImpl(runner, timeout);
  return toDisposable(() {
    _runWhenIdle = origRunWhenIdle;
    runWhenGlobalIdle = origRunWhenGlobalIdle;
  });
}

/// 1:1: `export abstract class AbstractIdleValue<T>`
abstract class AbstractIdleValue<T> {
  late final void Function() _executor;
  late final IDisposable _handle;
  bool _didRun = false;
  T? _value;
  Object? _error;

  AbstractIdleValue(dynamic targetWindow, T Function() executor) {
    _executor = () {
      try {
        _value = executor();
      } catch (err) {
        _error = err;
      } finally {
        _didRun = true;
      }
    };
    _handle = _runWhenIdle((_) => _executor());
  }

  void dispose() => _handle.dispose();

  T get value {
    if (!_didRun) {
      _handle.dispose();
      _executor();
    }
    if (_error != null) {
      throw _error!;
    }
    return _value as T;
  }

  bool get isInitialized => _didRun;
}

/// 1:1: `export class GlobalIdleValue<T>`
class GlobalIdleValue<T> extends AbstractIdleValue<T> {
  GlobalIdleValue(T Function() executor) : super(null, executor);
}

/// 1:1: `export async function retry`
Future<T> retry<T>(ITask<Future<T>> task, int delay, int retries) async {
  Object? lastError;
  for (int i = 0; i < retries; i++) {
    try {
      return await task();
    } catch (error) {
      lastError = error;
      await (timeout(delay) as Future<void>);
    }
  }
  throw lastError ?? StateError('retry failed');
}

/// Object literals of TaskSequentializer.
class _RunningTask {
  final int taskId;
  final void Function() cancel;
  final Future<void> promise;
  _RunningTask(this.taskId, this.cancel, this.promise);
}

class _QueuedTask {
  final Future<void> promise;
  final void Function() promiseResolve;
  final void Function(Object error) promiseReject;
  ITask<Future<void>> run;
  _QueuedTask(this.promise, this.promiseResolve, this.promiseReject, this.run);
}

/// 1:1: `export interface ITaskSequentializerWithRunningTask`
abstract class ITaskSequentializerWithRunningTask {
  Future<void>? get running;
}

/// 1:1: `export interface ITaskSequentializerWithQueuedTask`
abstract class ITaskSequentializerWithQueuedTask {
  _QueuedTask get queued;
}

/// 1:1: `export class TaskSequentializer`
class TaskSequentializer
    implements ITaskSequentializerWithRunningTask, ITaskSequentializerWithQueuedTask {
  _RunningTask? _running;
  _QueuedTask? _queued;

  bool isRunning([int? taskId]) {
    if (taskId != null) {
      return _running?.taskId == taskId;
    }
    return _running != null;
  }

  @override
  Future<void>? get running => _running?.promise;

  void cancelRunning() => _running?.cancel();

  Future<void> run(int taskId, Future<void> promise, [void Function()? onCancel]) {
    _running = _RunningTask(taskId, () => onCancel?.call(), promise);
    _then2<void, dynamic>(promise, (_) => doneRunning(taskId), (_) => doneRunning(taskId));
    return promise;
  }

  void doneRunning(int taskId) {
    if (_running != null && taskId == _running!.taskId) {
      _running = null;
      runQueued();
    }
  }

  void runQueued() {
    if (_queued != null) {
      final _QueuedTask queued = _queued!;
      _queued = null;
      _then2<void, dynamic>(queued.run(), (_) => queued.promiseResolve(),
          (Object error) => queued.promiseReject(error));
    }
  }

  Future<void> queue(ITask<Future<void>> run) {
    if (_queued == null) {
      final PromiseWithResolvers<void> resolvers = promiseWithResolvers<void>();
      _queued = _QueuedTask(
        resolvers.promise,
        () => resolvers.resolve(null),
        (Object error) => resolvers.reject(error),
        run,
      );
    } else {
      _queued!.run = run;
    }
    return _queued!.promise;
  }

  @override
  _QueuedTask get queued => _queued!;

  bool hasQueued() => _queued != null;

  Future<void> join() async =>
      _queued?.promise ?? _running?.promise ?? _resolve<void>(null);
}

/// 1:1: `export class IntervalCounter`
class IntervalCounter {
  int lastIncrementTime = 0;
  int value = 0;
  final int interval;
  final int Function() nowFn;

  IntervalCounter(this.interval, [int Function()? nowFn])
      : nowFn = nowFn ?? _dateNow;

  int increment() {
    final int now = nowFn();
    if (now - lastIncrementTime > interval) {
      lastIncrementTime = now;
      value = 0;
    }
    value++;
    return value;
  }
}

/// 1:1: `export type ValueCallback<T> = (value: T | Promise<T>) => void`
typedef ValueCallback<T> = void Function(dynamic value);

/// 1:1: `const enum DeferredOutcome`
class DeferredOutcome {
  static const int Resolved = 0;
  static const int Rejected = 1;
}

/// 1:1: `export class DeferredPromise<T>`
class DeferredPromise<T> {
  late final void Function(dynamic value) completeCallback;
  late final void Function(Object error) errorCallback;
  ({int outcome, dynamic value})? outcome;

  bool get isRejected => outcome?.outcome == DeferredOutcome.Rejected;
  bool get isResolved => outcome?.outcome == DeferredOutcome.Resolved;
  bool get isSettled => outcome != null;
  dynamic get value =>
      outcome?.outcome == DeferredOutcome.Resolved ? outcome?.value : null;

  late final Future<T> p;

  DeferredPromise() {
    final Completer<T> c = Completer<T>();
    completeCallback = (dynamic value) => c.complete(value as FutureOr<T>);
    errorCallback = (Object err) => c.completeError(err);
    p = c.future;
  }

  /// 1:1: `static fromPromise`
  static DeferredPromise<T> fromPromise<T>(Future<T> promise) {
    final DeferredPromise<T> deferred = DeferredPromise<T>();
    deferred.settleWith(promise);
    return deferred;
  }

  Future<void> complete([dynamic value]) {
    if (isSettled) {
      return _resolve<void>(null);
    }
    final Completer<void> c = Completer<void>();
    completeCallback(value);
    outcome = (outcome: DeferredOutcome.Resolved, value: value);
    c.complete();
    return c.future;
  }

  Future<void> error(Object err) {
    if (isSettled) {
      return _resolve<void>(null);
    }
    final Completer<void> c = Completer<void>();
    errorCallback(err);
    outcome = (outcome: DeferredOutcome.Rejected, value: err);
    c.complete();
    return c.future;
  }

  Future<void> settleWith(Future<T> promise) => _then2<T, Future<void>>(
      promise, (T value) => complete(value), (Object err) => error(err));

  Future<void> cancel() => error(CancellationError());
}

/// 1:1: `export namespace Promises`
class Promises {
  /// 1:1: `settled`
  static Future<List<T>> settled<T>(List<Future<T>> promises) async {
    Object? firstError;
    final List<dynamic> result = await _all<dynamic>(promises
        .map((Future<T> promise) => _thenOk<T, dynamic>(promise, (T value) => value)
            .catchError((Object error) {
          firstError ??= error;
          return null;
        }))
        .toList());
    if (firstError != null) {
      throw firstError!;
    }
    return result.cast<T>();
  }

  /// 1:1: `withAsyncBody`
  static Future<T> withAsyncBody<T, E extends Object>(
    Future<dynamic> Function(void Function(dynamic value) resolve,
        void Function(E error) reject) bodyFn,
  ) {
    final Completer<T> c = Completer<T>();
    (() async {
      try {
        await bodyFn(
          (dynamic value) => c.complete(value as FutureOr<T>),
          (E error) => c.completeError(error),
        );
      } catch (error) {
        if (!c.isCompleted) {
          c.completeError(error);
        }
      }
    })();
    return c.future;
  }
}

/// 1:1: `export class StatefulPromise<T>`
class StatefulPromise<T> {
  T? _value;
  T? get value => _value;
  Object? _error;
  Object? get error => _error;
  bool _isResolved = false;
  bool get isResolved => _isResolved;

  late final Future<T> promise;

  StatefulPromise(Future<T> promise) {
    this.promise = promise.then((T value) {
      _value = value;
      _isResolved = true;
      return value;
    }, onError: (Object err, StackTrace s) {
      _error = err;
      _isResolved = true;
      throw err;
    });
  }

  /// 1:1: `requireValue`
  T requireValue() {
    if (!_isResolved) {
      throw BugIndicatingError('Promise is not resolved yet');
    }
    if (_error != null) {
      throw _error!;
    }
    return _value as T;
  }
}

/// 1:1: `export class LazyStatefulPromise<T>`
class LazyStatefulPromise<T> {
  late final Lazy<StatefulPromise<T>> _promise;

  LazyStatefulPromise(Future<T> Function() compute) {
    _promise = Lazy<StatefulPromise<T>>(() => StatefulPromise<T>(compute()));
  }

  T requireValue() => _promise.value.requireValue();
  Future<T> getPromise() => _promise.value.promise;
  T? get currentValue => _promise.rawValue?.value;
}

/// 1:1: `const enum AsyncIterableSourceState`
class AsyncIterableSourceState {
  static const int Initial = 0;
  static const int DoneOK = 1;
  static const int DoneError = 2;
}

/// 1:1: `IteratorResult` carrier for JS `{ done, value }`.
class IteratorResult<T> {
  final bool done;
  final T? value;
  IteratorResult(this.done, this.value);
}

/// 1:1: `AsyncIterator<T>` carrier (JS `[Symbol.asyncIterator]()`).
abstract class IAsyncIterator<T> {
  Future<IteratorResult<T>> next();
  Future<IteratorResult<T>>? throwError(Object e);
  Future<IteratorResult<T>>? returnValue();
}

/// 1:1: `AsyncIterable<T>` carrier.
abstract class IAsyncIterable<T> {
  IAsyncIterator<T> asyncIterator();
}

/// 1:1: `export interface AsyncIterableEmitter<T>`
abstract class AsyncIterableEmitter<T> {
  void emitOne(T value);
  void emitMany(List<T> values);
  void reject(Object error);
}

class _AsyncIterableEmitter<T> implements AsyncIterableEmitter<T> {
  final void Function(T) _emitOne;
  final void Function(List<T>) _emitMany;
  final void Function(Object) _reject;
  _AsyncIterableEmitter(this._emitOne, this._emitMany, this._reject);
  @override
  void emitOne(T value) => _emitOne(value);
  @override
  void emitMany(List<T> values) => _emitMany(values);
  @override
  void reject(Object error) => _reject(error);
}

/// 1:1: `export interface AsyncIterableExecutor<T>`
typedef AsyncIterableExecutor<T> = dynamic Function(AsyncIterableEmitter<T> emitter);

class _AsyncIterableIterator<T> implements IAsyncIterator<T> {
  final AsyncIterableObject<T> _owner;
  int _i = 0;
  _AsyncIterableIterator(this._owner);

  @override
  Future<IteratorResult<T>> next() async {
    do {
      if (_owner._state == AsyncIterableSourceState.DoneError) {
        throw _owner._error ?? StateError('iterable error');
      }
      if (_i < _owner._results.length) {
        return IteratorResult<T>(false, _owner._results[_i++]);
      }
      if (_owner._state == AsyncIterableSourceState.DoneOK) {
        return IteratorResult<T>(true, null);
      }
      await eventToPromise(_owner._onStateChanged.event).done;
    } while (true);
  }

  @override
  Future<IteratorResult<T>> returnValue() async {
    await _owner._onReturn?.call();
    return IteratorResult<T>(true, null);
  }

  @override
  Future<IteratorResult<T>>? throwError(Object e) => null;
}

/// 1:1: `export class AsyncIterableObject<T>`
class AsyncIterableObject<T> implements IAsyncIterable<T> {
  int _state = AsyncIterableSourceState.Initial;
  List<T> _results = <T>[];
  Object? _error;
  final FutureOr<void> Function()? _onReturn;
  final Emitter<void> _onStateChanged;

  AsyncIterableObject(AsyncIterableExecutor<T> executor, [this._onReturn])
      : _onStateChanged = Emitter<void>() {
    scheduleMicrotask(() async {
      final AsyncIterableEmitter<T> writer = _AsyncIterableEmitter<T>(
        (T item) => emitOne(item),
        (List<T> items) => emitMany(items),
        (Object error) => reject(error),
      );
      try {
        await _resolve<dynamic>(executor(writer));
        resolve();
      } catch (err) {
        reject(err);
      } finally {
        // Executor settled: emitting afterwards is a no-op (source contract).
        (writer as _AsyncIterableEmitter<T>)._emitNoOp();
      }
    });
  }

  @override
  IAsyncIterator<T> asyncIterator() => _AsyncIterableIterator<T>(this);

  static AsyncIterableObject<T> fromArray<T>(List<T> items) =>
      AsyncIterableObject<T>((writer) {
        writer.emitMany(items);
        return null;
      });

  static AsyncIterableObject<T> fromPromise<T>(Future<List<T>> promise) =>
      AsyncIterableObject<T>((writer) async {
        writer.emitMany(await promise);
        return null;
      });

  static AsyncIterableObject<T> fromPromisesResolveOrder<T>(
          List<Future<T>> promises) =>
      AsyncIterableObject<T>((writer) async {
        await _all<dynamic>(promises
            .map((Future<T> p) => _thenOk<T, dynamic>(
                p, (T value) => writer.emitOne(value)))
            .toList());
        return null;
      });

  static AsyncIterableObject<T> merge<T>(List<IAsyncIterable<T>> iterables) =>
      AsyncIterableObject<T>((writer) async {
        await _all<dynamic>(iterables
            .map((IAsyncIterable<T> iterable) => (() async {
                  await _forAwait<T>(iterable, (T item) => writer.emitOne(item));
                })())
            .toList());
        return null;
      });

  static AsyncIterableObject<dynamic> EMPTY =
      AsyncIterableObject.fromArray<dynamic>(<dynamic>[]);

  /// 1:1 static `map` (renamed: Dart forbids static/instance name clash).
  static AsyncIterableObject<R> mapStatic<T, R>(
          IAsyncIterable<T> iterable, R Function(T item) mapFn) =>
      AsyncIterableObject<R>((writer) async {
        await _forAwait<T>(iterable, (T item) => writer.emitOne(mapFn(item)));
        return null;
      });

  AsyncIterableObject<R> map<R>(R Function(T item) mapFn) =>
      AsyncIterableObject.mapStatic<T, R>(this, mapFn);

  /// 1:1 static `filter`.
  static AsyncIterableObject<T> filterStatic<T>(
          IAsyncIterable<T> iterable, bool Function(T item) filterFn) =>
      AsyncIterableObject<T>((writer) async {
        await _forAwait<T>(iterable, (T item) {
          if (filterFn(item)) {
            writer.emitOne(item);
          }
        });
        return null;
      });

  AsyncIterableObject<T> filter(bool Function(T item) filterFn) =>
      AsyncIterableObject.filterStatic<T>(this, filterFn);

  /// 1:1 static `coalesce`.
  static AsyncIterableObject<T> coalesceStatic<T>(
          IAsyncIterable<T?> iterable) =>
      AsyncIterableObject.filterStatic<T>(
          iterable as IAsyncIterable<T>, (T item) => _truthy(item));

  AsyncIterableObject<T> coalesce() =>
      AsyncIterableObject.coalesceStatic<T>(this as IAsyncIterable<T?>);

  /// 1:1 static `toPromise`.
  static Future<List<T>> toPromiseStatic<T>(IAsyncIterable<T> iterable) async {
    final List<T> result = <T>[];
    await _forAwait<T>(iterable, (T item) => result.add(item));
    return result;
  }

  Future<List<T>> toPromise() => AsyncIterableObject.toPromiseStatic<T>(this);

  void emitOne(T value) {
    if (_state != AsyncIterableSourceState.Initial) {
      return;
    }
    _results.add(value);
    _onStateChanged.fire(null);
  }

  void emitMany(List<T> values) {
    if (_state != AsyncIterableSourceState.Initial) {
      return;
    }
    _results = List<T>.from(_results)..addAll(values);
    _onStateChanged.fire(null);
  }

  void resolve() {
    if (_state != AsyncIterableSourceState.Initial) {
      return;
    }
    _state = AsyncIterableSourceState.DoneOK;
    _onStateChanged.fire(null);
  }

  void reject(Object error) {
    if (_state != AsyncIterableSourceState.Initial) {
      return;
    }
    _state = AsyncIterableSourceState.DoneError;
    _error = error;
    _onStateChanged.fire(null);
  }
}

extension _EmitterNoOp<T> on _AsyncIterableEmitter<T> {
  void _emitNoOp() {
    // The source reassigns writer methods to no-ops after executor settles.
    // Dart final fields cannot be reassigned; the guards in emitOne/emitMany/
    // reject already make post-settle calls no-ops because _state != Initial.
  }
}

/// 1:1: `export function createCancelableAsyncIterableProducer`
CancelableAsyncIterableProducer<T> createCancelableAsyncIterableProducer<T>(
  IAsyncIterable<T> Function(CancellationToken token) callback,
) {
  final CancellationTokenSource source = CancellationTokenSource();
  final IAsyncIterable<T> innerIterable = callback(source.token);
  return CancelableAsyncIterableProducer<T>(source, (AsyncIterableEmitter<T> emitter) async {
    late final IDisposable subscription;
    subscription = source.token.onCancellationRequested((_) {
      subscription.dispose();
      source.dispose();
      emitter.reject(CancellationError());
    });
    try {
      final IAsyncIterator<T> it = innerIterable.asyncIterator();
      while (true) {
        final IteratorResult<T> r = await it.next();
        if (r.done) {
          break;
        }
        if (source.token.isCancellationRequested) {
          return;
        }
        emitter.emitOne(r.value as T);
      }
    } catch (err) {
      emitter.reject(err);
    }
  });
}

/// 1:1: `export class AsyncIterableSource<T>`
class AsyncIterableSource<T> {
  final DeferredPromise<void> _deferred = DeferredPromise<void>();
  late final AsyncIterableObject<T> _asyncIterable;

  late final void Function(Object error) _errorFn;
  late final void Function(T item) _emitOneFn;
  late final void Function(List<T> items) _emitManyFn;

  AsyncIterableSource([FutureOr<void> Function()? onReturn]) {
    Object? earlyError;
    List<T>? earlyItems;

    _asyncIterable = AsyncIterableObject<T>((AsyncIterableEmitter<T> emitter) {
      if (earlyError != null) {
        emitter.reject(earlyError!);
        return null;
      }
      if (earlyItems != null) {
        emitter.emitMany(earlyItems!);
      }
      _errorFn = (Object error) => emitter.reject(error);
      _emitOneFn = (T item) => emitter.emitOne(item);
      _emitManyFn = (List<T> items) => emitter.emitMany(items);
      return _deferred.p;
    }, onReturn ?? () {});

    _errorFn = (Object error) {
      earlyError ??= error;
    };
    _emitOneFn = (T item) {
      earlyItems ??= <T>[];
      earlyItems!.add(item);
    };
    _emitManyFn = (List<T> items) {
      if (earlyItems == null) {
        earlyItems = List<T>.from(items);
      } else {
        for (final T item in items) {
          earlyItems!.add(item);
        }
      }
    };
  }

  AsyncIterableObject<T> get asyncIterable => _asyncIterable;
  void resolve() => _deferred.complete();
  void reject(Object error) {
    _errorFn(error);
    _deferred.complete();
  }
  void emitOne(T item) => _emitOneFn(item);
  void emitMany(List<T> items) => _emitManyFn(items);
}

class _CancellableIterator<T> implements IAsyncIterator<T> {
  final IAsyncIterator<T> _iterator;
  final CancellationToken _token;
  _CancellableIterator(this._iterator, this._token);

  @override
  Future<IteratorResult<T>> next() async {
    if (_token.isCancellationRequested) {
      return IteratorResult<T>(true, null);
    }
    final IteratorResult<T>? result =
        await raceCancellation<IteratorResult<T>>(_iterator.next(), _token);
    return result ?? IteratorResult<T>(true, null);
  }

  @override
  Future<IteratorResult<T>>? throwError(Object e) => _iterator.throwError(e);
  @override
  Future<IteratorResult<T>>? returnValue() => _iterator.returnValue();
}

/// 1:1: `export function cancellableIterable`
IAsyncIterable<T> cancellableIterable<T>(
  dynamic iterableOrIterator,
  CancellationToken token,
) {
  final IAsyncIterator<T> iterator = iterableOrIterator is IAsyncIterable<T>
      ? iterableOrIterator.asyncIterator()
      : iterableOrIterator as IAsyncIterator<T>;
  final IAsyncIterator<T> cancellable = _CancellableIterator<T>(iterator, token);
  return _SingleIteratorIterable<T>(cancellable);
}

class _SingleIteratorIterable<T> implements IAsyncIterable<T> {
  final IAsyncIterator<T> _it;
  _SingleIteratorIterable(this._it);
  @override
  IAsyncIterator<T> asyncIterator() => _it;
}

/// `ProducerConsumerValue<T>` carrier.
class ProducerConsumerValue<T> {
  final bool ok;
  final T? value;
  final Object? error;
  ProducerConsumerValue.ok(this.value) : ok = true, error = null;
  ProducerConsumerValue.err(this.error) : ok = false, value = null;
}

/// 1:1: `class ProducerConsumer<T>`
class ProducerConsumer<T> {
  final List<DeferredPromise<T>> _unsatisfiedConsumers = <DeferredPromise<T>>[];
  final List<ProducerConsumerValue<T>> _unconsumedValues = <ProducerConsumerValue<T>>[];
  ProducerConsumerValue<T>? _finalValue;

  bool get hasFinalValue => _finalValue != null;

  void produce(ProducerConsumerValue<T> value) {
    _ensureNoFinalValue();
    if (_unsatisfiedConsumers.isNotEmpty) {
      final DeferredPromise<T> deferred = _unsatisfiedConsumers.removeAt(0);
      _resolveOrRejectDeferred(deferred, value);
    } else {
      _unconsumedValues.add(value);
    }
  }

  void produceFinal(ProducerConsumerValue<T> value) {
    _ensureNoFinalValue();
    _finalValue = value;
    for (final DeferredPromise<T> deferred in _unsatisfiedConsumers) {
      _resolveOrRejectDeferred(deferred, value);
    }
    _unsatisfiedConsumers.clear();
  }

  void _ensureNoFinalValue() {
    if (_finalValue != null) {
      throw BugIndicatingError(
          'ProducerConsumer: cannot produce after final value has been set');
    }
  }

  void _resolveOrRejectDeferred(
      DeferredPromise<T> deferred, ProducerConsumerValue<T> value) {
    if (value.ok) {
      deferred.complete(value.value);
    } else {
      deferred.error(value.error ?? StateError('producer error'));
    }
  }

  Future<T> consume() {
    if (_unconsumedValues.isNotEmpty || _finalValue != null) {
      final ProducerConsumerValue<T> value = _unconsumedValues.isNotEmpty
          ? _unconsumedValues.removeAt(0)
          : _finalValue!;
      if (value.ok) {
        return _resolve<T>(value.value);
      }
      return _reject<T>(value.error ?? StateError('producer error'));
    }
    final DeferredPromise<T> deferred = DeferredPromise<T>();
    _unsatisfiedConsumers.add(deferred);
    return deferred.p;
  }
}

class _ProducerIterator<T> implements IAsyncIterator<T> {
  final ProducerConsumer<IteratorResult<T>> pc;
  final void Function()? onReturn;
  _ProducerIterator(this.pc, this.onReturn);

  @override
  Future<IteratorResult<T>> next() => pc.consume();
  @override
  Future<IteratorResult<T>> returnValue() {
    onReturn?.call();
    return _resolve<IteratorResult<T>>(IteratorResult<T>(true, null));
  }
  @override
  Future<IteratorResult<T>> throwError(Object e) async {
    if (!pc.hasFinalValue) {
      pc.produceFinal(ProducerConsumerValue<IteratorResult<T>>.err(e));
    }
    return IteratorResult<T>(true, null);
  }
}

/// 1:1: `export class AsyncIterableProducer<T>`
class AsyncIterableProducer<T> implements IAsyncIterable<T> {
  final ProducerConsumer<IteratorResult<T>> _producerConsumer =
      ProducerConsumer<IteratorResult<T>>();
  final void Function()? _onReturn;
  late final IAsyncIterator<T> _iterator;

  AsyncIterableProducer(AsyncIterableExecutor<T> executor, [this._onReturn]) {
    _iterator = _ProducerIterator<T>(_producerConsumer, _onReturn);
    scheduleMicrotask(() async {
      final dynamic p = executor(_AsyncIterableEmitter<T>(
        (T value) => _producerConsumer.produce(
            ProducerConsumerValue<IteratorResult<T>>.ok(IteratorResult<T>(false, value))),
        (List<T> values) {
          for (final T value in values) {
            _producerConsumer.produce(
                ProducerConsumerValue<IteratorResult<T>>.ok(IteratorResult<T>(false, value)));
          }
        },
        (Object error) => _finishError(error),
      ));
      if (!_producerConsumer.hasFinalValue) {
        try {
          await _resolve<dynamic>(p);
          _finishOk();
        } catch (error) {
          _finishError(error);
        }
      }
    });
  }

  @override
  IAsyncIterator<T> asyncIterator() => _iterator;

  static AsyncIterableProducer<T> fromArray<T>(List<T> items) =>
      AsyncIterableProducer<T>((writer) {
        writer.emitMany(items);
        return null;
      });

  static AsyncIterableProducer<T> fromPromise<T>(Future<List<T>> promise) =>
      AsyncIterableProducer<T>((writer) async {
        writer.emitMany(await promise);
        return null;
      });

  static AsyncIterableProducer<T> fromPromisesResolveOrder<T>(
          List<Future<T>> promises) =>
      AsyncIterableProducer<T>((writer) async {
        await _all<dynamic>(promises
            .map((Future<T> p) => _thenOk<T, dynamic>(
                p, (T value) => writer.emitOne(value)))
            .toList());
        return null;
      });

  static AsyncIterableProducer<T> merge<T>(List<IAsyncIterable<T>> iterables) =>
      AsyncIterableProducer<T>((writer) async {
        await _all<dynamic>(iterables
            .map((IAsyncIterable<T> iterable) => (() async {
                  await _forAwait<T>(iterable, (T item) => writer.emitOne(item));
                })())
            .toList());
        return null;
      });

  static AsyncIterableProducer<dynamic> EMPTY =
      AsyncIterableProducer.fromArray<dynamic>(<dynamic>[]);

  /// 1:1 static `map` (renamed: Dart forbids static/instance name clash).
  static AsyncIterableProducer<R> mapStatic<T, R>(
          IAsyncIterable<T> iterable, R Function(T item) mapFn) =>
      AsyncIterableProducer<R>((writer) async {
        await _forAwait<T>(iterable, (T item) => writer.emitOne(mapFn(item)));
        return null;
      });

  static List<AsyncIterableProducer<T>> tee<T>(IAsyncIterable<T> iterable) {
    AsyncIterableEmitter<T>? emitter1;
    AsyncIterableEmitter<T>? emitter2;
    final DeferredPromise<void> defer = DeferredPromise<void>();

    Future<void> start() async {
      if (emitter1 == null || emitter2 == null) {
        return;
      }
      try {
        await _forAwait<T>(iterable, (T item) {
          emitter1!.emitOne(item);
          emitter2!.emitOne(item);
        });
      } catch (err) {
        emitter1!.reject(err);
        emitter2!.reject(err);
      } finally {
        defer.complete();
      }
    }

    final AsyncIterableProducer<T> p1 = AsyncIterableProducer<T>((emitter) {
      emitter1 = emitter;
      start();
      return defer.p;
    });
    final AsyncIterableProducer<T> p2 = AsyncIterableProducer<T>((emitter) {
      emitter2 = emitter;
      start();
      return defer.p;
    });
    return <AsyncIterableProducer<T>>[p1, p2];
  }

  AsyncIterableProducer<R> map<R>(R Function(T item) mapFn) =>
      AsyncIterableProducer.mapStatic<T, R>(this, mapFn);

  /// 1:1 static `coalesce`.
  static AsyncIterableProducer<T> coalesceStatic<T>(IAsyncIterable<T?> iterable) =>
      AsyncIterableProducer.filterStatic<T>(
          iterable as IAsyncIterable<T>, (T item) => _truthy(item));

  AsyncIterableProducer<T> coalesce() =>
      AsyncIterableProducer.coalesceStatic<T>(this as IAsyncIterable<T?>);

  /// 1:1 static `filter`.
  static AsyncIterableProducer<T> filterStatic<T>(
          IAsyncIterable<T> iterable, bool Function(T item) filterFn) =>
      AsyncIterableProducer<T>((writer) async {
        await _forAwait<T>(iterable, (T item) {
          if (filterFn(item)) {
            writer.emitOne(item);
          }
        });
        return null;
      });

  AsyncIterableProducer<T> filter(bool Function(T item) filterFn) =>
      AsyncIterableProducer.filterStatic<T>(this, filterFn);

  void _finishOk() {
    if (!_producerConsumer.hasFinalValue) {
      _producerConsumer.produceFinal(ProducerConsumerValue<IteratorResult<T>>.ok(
          IteratorResult<T>(true, null)));
    }
  }

  void _finishError(Object error) {
    if (!_producerConsumer.hasFinalValue) {
      _producerConsumer.produceFinal(
          ProducerConsumerValue<IteratorResult<T>>.err(error));
    }
  }
}

/// 1:1: `export class CancelableAsyncIterableProducer<T>`
class CancelableAsyncIterableProducer<T> extends AsyncIterableProducer<T> {
  final CancellationTokenSource _source;

  CancelableAsyncIterableProducer(this._source, AsyncIterableExecutor<T> executor)
      : super(executor);

  void cancel() => _source.cancel();
}

/// 1:1: `export const AsyncReaderEndOfStream`
final Object AsyncReaderEndOfStream = Object();

/// 1:1: `export class AsyncReader<T>`
class AsyncReader<T> {
  final List<T> _buffer = <T>[];
  bool _atEnd = false;
  Future<void>? _extendBufferPromise;
  final IAsyncIterator<T> _source;

  bool get endOfStream => _buffer.isEmpty && _atEnd;

  AsyncReader(this._source);

  Future<dynamic> read() async {
    if (_buffer.isEmpty && !_atEnd) {
      await _extendBuffer();
    }
    if (_buffer.isEmpty) {
      return AsyncReaderEndOfStream;
    }
    return _buffer.removeAt(0);
  }

  Future<void> readWhile(bool Function(T value) predicate,
      FutureOr<void> Function(T element) callback) async {
    do {
      final dynamic piece = await peek();
      if (identical(piece, AsyncReaderEndOfStream)) {
        break;
      }
      if (!predicate(piece as T)) {
        break;
      }
      await read(); // consume
      await callback(piece);
    } while (true);
  }

  dynamic readBufferedOrThrow() {
    final dynamic value = peekBufferedOrThrow();
    _buffer.removeAt(0);
    return value;
  }

  Future<void> consumeToEnd() async {
    while (!endOfStream) {
      await read();
    }
  }

  Future<dynamic> peek() async {
    if (_buffer.isEmpty && !_atEnd) {
      await _extendBuffer();
    }
    if (_buffer.isEmpty) {
      return AsyncReaderEndOfStream;
    }
    return _buffer[0];
  }

  dynamic peekBufferedOrThrow() {
    if (_buffer.isEmpty) {
      if (_atEnd) {
        return AsyncReaderEndOfStream;
      }
      throw BugIndicatingError('No buffered elements');
    }
    return _buffer[0];
  }

  Future<dynamic> peekTimeout(int timeoutMs) async {
    if (_buffer.isEmpty && !_atEnd) {
      await raceTimeout<void>(_extendBuffer(), timeoutMs);
    }
    if (_atEnd) {
      return AsyncReaderEndOfStream;
    }
    if (_buffer.isEmpty) {
      return null;
    }
    return _buffer[0];
  }

  Future<void> _extendBuffer() {
    if (_atEnd) {
      return _resolve<void>(null);
    }
    if (_extendBufferPromise == null) {
      _extendBufferPromise = (() async {
        final IteratorResult<T> r = await _source.next();
        _extendBufferPromise = null;
        if (r.done) {
          _atEnd = true;
        } else {
          _buffer.add(r.value as T);
        }
      })();
    }
    return _extendBufferPromise!;
  }
}

/// 1:1: `export function createTimeout`
IDisposable createTimeout(int ms, void Function() cb) {
  final Timer t = _setTimeout(cb, ms);
  return toDisposable(() => _clearTimeout(t));
}
