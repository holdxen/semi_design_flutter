// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/utils/utils.ts
// Translated 1:1. JS setTimeout/clearTimeout map to dart:async Timer;
// `Object.assign(observable, {...})` becomes a delegating wrapper exposing the
// extra methods; module-side-effect setters use idempotent registration.
// ---------------------------------------------------------------------------

import 'dart:async';

import '../base.dart'
    show
        IObservable,
        IObservableWithChange,
        IObserver,
        IReader,
        ITransaction;
import '../commonFacade/deps.dart'
    show DisposableStore, Event, IDisposable, toDisposable;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugOwner;
import '../observables/baseObservable.dart' show setKeepObserved, setRecomputeInitiallyAndOnChange;
import '../observables/derived.dart' show derived, derivedOpts, DerivedOpts;
import '../observables/observableFromEvent.dart' show observableFromEvent;
import '../observables/observableSignal.dart'
    show IObservableSignal, observableSignal;
import '../observables/observableValue.dart' show observableValue;
import '../reactions/autorun.dart' show autorun;

/// 1:1: `observableFromPromise`
IObservable<ObservedPromiseValue<T>> observableFromPromise<T>(
  Future<T> promise,
) {
  final observable = observableValue<ObservedPromiseValue<T>, Object?>(
      'promiseValue', ObservedPromiseValue<T>());
  promise.then((value) {
    observable.set(ObservedPromiseValue<T>(value: value), null, null);
  });
  return observable;
}

/// 1:1: `{ value?: T }`
class ObservedPromiseValue<T> {
  ObservedPromiseValue({this.value});
  T? value;
}

/// 1:1: `signalFromObservable`
IObservable<void> signalFromObservable<T>(
  DebugOwner? owner,
  IObservable<T> observable,
) {
  return derivedOpts<void>(
    DerivedOpts<void>(owner: owner, equalsFn: (a, b) => false),
    (IReader reader) {
      observable.read(reader);
    },
  );
}

/// 1:1: `debouncedObservable`
IObservable<T> debouncedObservable<T>(
  IObservable<T> observable,
  Object debounceMs, [
  DebugLocation? debugLocation,
]) {
  bool hasValue = false;
  T? lastValue;
  Timer? timeout;

  return observableFromEvent<T, void>(
    null,
    (dynamic cb, [dynamic thisArgs, dynamic disposables]) {
      final IDisposable d = autorun((reader) {
        final T value = observable.read(reader);
        if (!hasValue) {
          hasValue = true;
          lastValue = value;
        } else {
          timeout?.cancel();
          final int debounceDuration = debounceMs is int
              ? debounceMs
              : (debounceMs as int Function(T?, T))(lastValue, value);
          if (debounceDuration == 0) {
            lastValue = value;
            (cb as void Function())();
            return;
          }
          timeout = Timer(Duration(milliseconds: debounceDuration), () {
            lastValue = value;
            (cb as void Function())();
          });
        }
      });
      return toDisposable(() {
        d.dispose();
        if (timeout != null) {
          timeout!.cancel();
          timeout = null;
        }
        hasValue = false;
        lastValue = null;
      });
    },
    (void _) {
      if (hasValue) {
        return lastValue as T;
      } else {
        return observable.get();
      }
    },
    debugLocation,
  );
}

/// 1:1: `throttledObservable`
IObservable<T> throttledObservable<T>(
  IObservable<T> observable,
  int throttleMs, [
  DebugLocation? debugLocation,
]) {
  bool hasValue = false;
  T? lastValue;
  Timer? timeout;

  return observableFromEvent<T, void>(
    null,
    (dynamic cb, [dynamic thisArgs, dynamic disposables]) {
      final IDisposable d = autorun((reader) {
        final T value = observable.read(reader);
        if (!hasValue) {
          hasValue = true;
          lastValue = value;
        } else if (timeout == null) {
          timeout = Timer(Duration(milliseconds: throttleMs), () {
            timeout = null;
            lastValue = observable.read(null);
            (cb as void Function())();
          });
        }
      });
      return toDisposable(() {
        d.dispose();
        if (timeout != null) {
          timeout!.cancel();
          timeout = null;
        }
        hasValue = false;
        lastValue = null;
      });
    },
    (void _) {
      if (hasValue) {
        return lastValue as T;
      } else {
        return observable.get();
      }
    },
    debugLocation,
  );
}

/// 1:1: `debouncedObservable2`
IObservable<T> debouncedObservable2<T>(
  IObservable<T> observable,
  Object debounceMs, [
  DebugLocation? debugLocation,
]) {
  final IObservableSignal<void> s = observableSignal<void>('handleTimeout');
  T? currentValue;
  Timer? timeout;

  return derivedOpts<T>(
    DerivedOpts<T>(
      owner: null,
      onLastObserverRemoved: () {
        currentValue = null;
      },
    ),
    (IReader reader) {
      final T val = observable.read(reader);
      s.read(reader);
      if (val != currentValue) {
        final int debounceDuration = debounceMs is int
            ? debounceMs
            : (debounceMs as int Function(T?, T))(currentValue, val);
        if (debounceDuration == 0) {
          currentValue = val;
          return val;
        }
        timeout?.cancel();
        timeout = Timer(Duration(milliseconds: debounceDuration), () {
          currentValue = val;
          s.trigger(null, null);
        });
      }
      return currentValue as T;
    },
    debugLocation,
  );
}

/// 1:1: `wasEventTriggeredRecently`
IObservable<bool> wasEventTriggeredRecently(
  Event<Object?> event,
  int timeoutMs,
  DisposableStore disposableStore,
) {
  final observable = observableValue<bool, Object?>('triggeredRecently', false);
  Timer? timeout;
  disposableStore.add(event((dynamic arg, [dynamic thisArgs, dynamic disposables]) {
    observable.set(true, null, null);
    timeout?.cancel();
    timeout = Timer(Duration(milliseconds: timeoutMs), () {
      observable.set(false, null, null);
    });
  }) as IDisposable);
  return observable;
}

/// 1:1: `keepObserved`
IDisposable keepObserved<T>(IObservable<T> observable) {
  _ensureKeepObservedRegistered();
  final o = KeepAliveObserver(false, null);
  observable.addObserver(o);
  return toDisposable(() {
    observable.removeObserver(o);
  });
}

bool _keepObservedRegistered = false;
void _ensureKeepObservedRegistered() {
  if (_keepObservedRegistered) return;
  setKeepObserved((o) => keepObserved(o as IObservable<Object?>));
  _keepObservedRegistered = true;
}

/// 1:1: `recomputeInitiallyAndOnChange`
IDisposable recomputeInitiallyAndOnChange<T>(
  IObservable<T> observable, [
  void Function(T value)? handleValue,
]) {
  _ensureRecomputeRegistered();
  final o = KeepAliveObserver(true, handleValue == null
      ? null
      : (v) => handleValue(v as T));
  observable.addObserver(o);
  try {
    o.beginUpdate(observable as IObservableWithChange<Object?, Object?>);
  } finally {
    o.endUpdate(observable as IObservableWithChange<Object?, Object?>);
  }
  return toDisposable(() {
    observable.removeObserver(o);
  });
}

bool _recomputeRegistered = false;
void _ensureRecomputeRegistered() {
  if (_recomputeRegistered) return;
  setRecomputeInitiallyAndOnChange((o, [handleValue]) =>
      recomputeInitiallyAndOnChange(o as IObservable<Object?>,
          handleValue == null ? null : (v) => handleValue(v)) as Object);
  _recomputeRegistered = true;
}

/// 1:1: `class KeepAliveObserver implements IObserver`
class KeepAliveObserver implements IObserver {
  KeepAliveObserver(this._forceRecompute, this._handleValue);

  final bool _forceRecompute;
  final void Function(Object? value)? _handleValue;
  int _counter = 0;

  @override
  void beginUpdate<T>(IObservableWithChange<T, Object?> observable) {
    _counter++;
  }

  @override
  void endUpdate<T>(IObservableWithChange<T, Object?> observable) {
    if (_counter == 1 && _forceRecompute) {
      final handle = _handleValue;
      if (handle != null) {
        handle(observable.get());
      } else {
        observable.reportChanges();
      }
    }
    _counter--;
  }

  @override
  void handlePossibleChange<T>(IObservableWithChange<T, Object?> observable) {
    // NO OP
  }

  @override
  void handleChange<T, TChange>(
    IObservableWithChange<T, TChange> observable,
    TChange change,
  ) {
    // NO OP
  }
}

/// 1:1: `derivedObservableWithCache`
IObservable<T> derivedObservableWithCache<T>(
  DebugOwner owner,
  T Function(IReader reader, T? lastValue) computeFn,
) {
  T? lastValue;
  return derivedOpts<T>(
    DerivedOpts<T>(owner: owner, debugReferenceFn: computeFn),
    (IReader reader) {
      lastValue = computeFn(reader, lastValue);
      return lastValue as T;
    },
  );
}

/// 1:1: `derivedObservableWithWritableCache` result shape.
abstract class WritableCachedObservable<T> implements IObservable<T> {
  void clearCache(ITransaction tx);
  void setCache(T? newValue, ITransaction? tx);
}

class _WritableCachedObservable<T> implements WritableCachedObservable<T> {
  _WritableCachedObservable(this._observable);
  final IObservable<T> _observable;
  void Function(T? newValue, ITransaction? tx)? _setCacheFn;

  void setSetter(void Function(T? newValue, ITransaction? tx) fn) =>
      _setCacheFn = fn;

  @override
  T get() => _observable.get();
  @override
  void reportChanges() => _observable.reportChanges();
  @override
  void addObserver(IObserver observer) => _observable.addObserver(observer);
  @override
  void removeObserver(IObserver observer) => _observable.removeObserver(observer);
  @override
  T read(IReader? reader) => _observable.read(reader);
  @override
  IObservable<T> recomputeInitiallyAndOnChange(Object store,
          [void Function(T value)? handleValue]) =>
      _observable.recomputeInitiallyAndOnChange(store, handleValue);
  @override
  IObservable<T> keepObserved(Object store) => _observable.keepObserved(store);
  @override
  IObservable<TNew> map<TNew>(TNew Function(T value, IReader reader) fn) =>
      _observable.map(fn);
  @override
  IObservable<TNew> flatten<TNew>() => _observable.flatten<TNew>();
  @override
  IObservableWithChange<T, Object?> log() => _observable.log();
  @override
  String get debugName => _observable.debugName;

  @override
  void clearCache(ITransaction tx) => setCache(null, tx);

  @override
  void setCache(T? newValue, ITransaction? tx) =>
      _setCacheFn!.call(newValue, tx);
}

/// 1:1: `derivedObservableWithWritableCache`
WritableCachedObservable<T> derivedObservableWithWritableCache<T>(
  Object owner,
  T Function(IReader reader, T? lastValue) computeFn,
) {
  T? lastValue;
  final onChange = observableSignal<T?>('derivedObservableWithWritableCache');
  final observable = derived<T, void>(
    owner,
    (IReader reader) {
      onChange.read(reader);
      lastValue = computeFn(reader, lastValue);
      return lastValue as T;
    },
  );
  // The cache must be settable from outside. Keep the value in a holder shared
  // with the wrapper instead of the local (Dart closures capture by reference,
  // so assigning here updates the same cell the computeFn reads).
  void setCache(T? newValue, ITransaction? tx) {
    lastValue = newValue;
    onChange.trigger(tx, newValue);
  }

  void clearCache(ITransaction tx) => setCache(null, tx);

  final wrapper = _WritableCachedObservable<T>(observable);
  wrapper.setSetter(setCache);
  return wrapper;
}

/// 1:1: `mapObservableArrayCached`
IObservable<List<TOut>> mapObservableArrayCached<TIn, TOut, TKey>(
  DebugOwner owner,
  IObservable<List<TIn>> items,
  TOut Function(TIn input, DisposableStore store) map, [
  TKey Function(TIn input)? keySelector,
]) {
  ArrayMap<TIn, TOut, TKey> m = ArrayMap<TIn, TOut, TKey>(map, keySelector);
  return derivedOpts<List<TOut>>(
    DerivedOpts<List<TOut>>(
      owner: owner,
      debugReferenceFn: map,
      onLastObserverRemoved: () {
        m.dispose();
        m = ArrayMap<TIn, TOut, TKey>(map, null);
      },
    ),
    (IReader reader) {
      final List<TIn> i = items.read(reader);
      m.setItems(i);
      return m.getItems();
    },
  );
}

/// 1:1: `class ArrayMap<TIn, TOut, TKey> implements IDisposable`
class ArrayMap<TIn, TOut, TKey> implements IDisposable {
  ArrayMap(this._map, [this._keySelector]);

  final TOut Function(TIn input, DisposableStore store) _map;
  final TKey Function(TIn input)? _keySelector;
  final Map<TKey, _ArrayMapEntry<TOut>> _cache =
      <TKey, _ArrayMapEntry<TOut>>{};
  List<TOut> _items = <TOut>[];

  @override
  void dispose() {
    _cache.forEach((key, entry) => entry.store.dispose());
    _cache.clear();
  }

  void setItems(List<TIn> items) {
    final List<TOut> newItems = <TOut>[];
    final Set<TKey> itemsToRemove = _cache.keys.toSet();
    for (final TIn item in items) {
      final TKey key = _keySelector != null
          ? _keySelector!(item)
          : item as TKey;
      _ArrayMapEntry<TOut>? entry = _cache[key];
      if (entry == null) {
        final store = DisposableStore();
        final TOut out = _map(item, store);
        entry = _ArrayMapEntry<TOut>(out, store);
        _cache[key] = entry;
      } else {
        itemsToRemove.remove(key);
      }
      newItems.add(entry.out);
    }
    for (final TKey item in itemsToRemove) {
      final entry = _cache[item]!;
      entry.store.dispose();
      _cache.remove(item);
    }
    _items = newItems;
  }

  List<TOut> getItems() => _items;
}

class _ArrayMapEntry<TOut> {
  _ArrayMapEntry(this.out, this.store);
  final TOut out;
  final DisposableStore store;
}

/// 1:1: `isObservable`
bool isObservable<T>(Object? obj) {
  if (obj == null) return false;
  final dynamic value = obj;
  try {
    return value.read != null && value.reportChanges != null;
  } catch (_) {
    return false;
  }
}

/// Register the module side effects. Called lazily by [keepObserved] and
/// [recomputeInitiallyAndOnChange] on first use, mirroring TS import-time
/// `_setKeepObserved(keepObserved)` / `_setRecomputeInitiallyAndOnChange(...)`.
void ensureUtilsSideEffectsRegistered() {
  _ensureKeepObservedRegistered();
  _ensureRecomputeRegistered();
}
