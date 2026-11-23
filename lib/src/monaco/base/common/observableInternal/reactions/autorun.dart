// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/reactions/autorun.ts
// Translated 1:1. TS `const enum`/namespaces -> static const/toplevel; object
// literal option bags -> carrier classes; `bind(reader)` is implicit for Dart
// method tears; `Map` uses Dart value equality (the project's standard
// translation of JS `Map`).
// ---------------------------------------------------------------------------

import '../base.dart'
    show
        IObservable,
        IObservableWithChange,
        IReader,
        IReaderWithStore,
        ISettableObservable;
import '../changeTracker.dart' show IChangeTracker;
import '../commonFacade/deps.dart'
    show DisposableStore, IDisposable, toDisposable;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData, DebugNameDataLike, IDebugNameData;
import '../observables/observableValue.dart' show observableValue;
import '../transaction.dart' show transaction;
import 'autorunImpl.dart' show AutorunObserver;

/// 1:1: `export function autorun(fn, debugLocation = DebugLocation.ofCaller())`
IDisposable autorun(
  void Function(IReaderWithStore reader) fn, [
  DebugLocation? debugLocation,
]) {
  return AutorunObserver<Object?>(
    DebugNameData(null, null, fn),
    (reader, changeSummary) => fn(reader),
    null,
    debugLocation ?? DebugLocation.ofCaller(),
  );
}

/// 1:1: `export function autorunOpts(options, fn, debugLocation = DebugLocation.ofCaller())`
IDisposable autorunOpts(
  IDebugNameData options,
  void Function(IReaderWithStore reader) fn, [
  DebugLocation? debugLocation,
]) {
  return AutorunObserver<Object?>(
    DebugNameData(
      options.owner,
      options.debugName,
      options.debugReferenceFn ?? fn,
    ),
    (reader, changeSummary) => fn(reader),
    null,
    debugLocation ?? DebugLocation.ofCaller(),
  );
}

/// Carrier for `IDebugNameData & { changeTracker }` object literals.
class AutorunHandleChangesOpts<TChangeSummary> implements IDebugNameData {
  AutorunHandleChangesOpts({
    this.owner,
    this.debugName,
    this.debugReferenceFn,
    required this.changeTracker,
  });

  @override
  final Object? owner;
  @override
  final Object? debugName;
  @override
  final Function? debugReferenceFn;
  final IChangeTracker<TChangeSummary> changeTracker;
}

/// 1:1: `export function autorunHandleChanges<TChangeSummary>(options, fn, debugLocation)`
IDisposable autorunHandleChanges<TChangeSummary>(
  AutorunHandleChangesOpts<TChangeSummary> options,
  void Function(IReader reader, TChangeSummary changeSummary) fn, [
  DebugLocation? debugLocation,
]) {
  return AutorunObserver<TChangeSummary>(
    DebugNameData(
      options.owner,
      options.debugName,
      options.debugReferenceFn ?? fn,
    ),
    (reader, changeSummary) => fn(reader, changeSummary),
    options.changeTracker,
    debugLocation ?? DebugLocation.ofCaller(),
  );
}

/// 1:1: `export function autorunWithStoreHandleChanges<TChangeSummary>(options, fn)`
IDisposable autorunWithStoreHandleChanges<TChangeSummary>(
  AutorunHandleChangesOpts<TChangeSummary> options,
  void Function(
    IReader reader,
    TChangeSummary changeSummary,
    DisposableStore store,
  ) fn,
) {
  final DisposableStore store = DisposableStore();
  final IDisposable disposable = autorunHandleChanges<TChangeSummary>(
    AutorunHandleChangesOpts<TChangeSummary>(
      owner: options.owner,
      debugName: options.debugName,
      debugReferenceFn: options.debugReferenceFn ?? fn,
      changeTracker: options.changeTracker,
    ),
    (reader, changeSummary) {
      store.clear();
      fn(reader, changeSummary, store);
    },
  );
  return toDisposable(() {
    disposable.dispose();
    store.dispose();
  });
}

/// 1:1: `export function autorunWithStore(fn)`
IDisposable autorunWithStore(
  void Function(IReader reader, DisposableStore store) fn,
) {
  final DisposableStore store = DisposableStore();
  final IDisposable disposable = autorunOpts(
    DebugNameDataLike(debugReferenceFn: fn),
    (reader) {
      store.clear();
      fn(reader, store);
    },
  );
  return toDisposable(() {
    disposable.dispose();
    store.dispose();
  });
}

/// 1:1: `{ lastValue: T | undefined; newValue: T }` argument object.
class AutorunDeltaArgs<T> {
  AutorunDeltaArgs({required this.lastValue, required this.newValue});
  final T? lastValue;
  final T newValue;
}

/// 1:1: `export function autorunDelta<T>(observable, handler)`
IDisposable autorunDelta<T>(
  IObservable<T> observable,
  void Function(AutorunDeltaArgs<T> args) handler,
) {
  T? lastValue;
  return autorunOpts(
    DebugNameDataLike(debugReferenceFn: handler),
    (reader) {
      final T newValue = observable.read(reader);
      final T? previous = lastValue;
      lastValue = newValue;
      handler(AutorunDeltaArgs<T>(lastValue: previous, newValue: newValue));
    },
  );
}

/// 1:1: `{ addedValues: T[]; removedValues: T[] }` argument object.
class AutorunIterableDeltaArgs<T> {
  AutorunIterableDeltaArgs({
    required this.addedValues,
    required this.removedValues,
  });
  final List<T> addedValues;
  final List<T> removedValues;
}

/// 1:1: `export function autorunIterableDelta<T>(getValue, handler, getUniqueIdentifier = v => v)`
IDisposable autorunIterableDelta<T>(
  Iterable<T> Function(IReader reader) getValue,
  void Function(AutorunIterableDeltaArgs<T> args) handler, [
  Object Function(T value)? getUniqueIdentifier,
]) {
  final Object Function(T value) getUniqueIdentifierFn =
      getUniqueIdentifier ?? ((value) => value as Object);
  final Map<Object, T> lastValues = <Object, T>{};
  return autorunOpts(
    DebugNameDataLike(debugReferenceFn: getValue),
    (reader) {
      final Map<Object, T> newValues = <Object, T>{};
      final Map<Object, T> removedValues = <Object, T>{...lastValues};
      for (final T value in getValue(reader)) {
        final Object id = getUniqueIdentifierFn(value);
        if (lastValues.containsKey(id)) {
          removedValues.remove(id);
        } else {
          newValues[id] = value;
          lastValues[id] = value;
        }
      }
      for (final Object id in removedValues.keys) {
        lastValues.remove(id);
      }

      if (newValues.isNotEmpty || removedValues.isNotEmpty) {
        handler(AutorunIterableDeltaArgs<T>(
          addedValues: newValues.values.toList(),
          removedValues: removedValues.values.toList(),
        ));
      }
    },
  );
}

/// 1:1: `interface ICell { readonly value: ISettableObservable<TIn>; readonly store: DisposableStore; }`
class _Cell<TIn> {
  _Cell(this.value, this.store);
  final ISettableObservable<TIn, Object?> value;
  final DisposableStore store;
}

/// 1:1: `{ key: TKey; cell: ICell }` addition record.
class _Addition<TKey, TIn> {
  _Addition(this.key, this.cell);
  final TKey key;
  final _Cell<TIn> cell;
}

/// 1:1: `export function autorunPerKeyedItem<TIn, TKey>(items, keyFn, setup, debugLocation)`
IDisposable autorunPerKeyedItem<TIn, TKey>(
  IObservable<List<TIn>> items,
  TKey Function(TIn input) keyFn,
  void Function(TKey key, IObservable<TIn> value, DisposableStore store) setup, [
  DebugLocation? debugLocation,
]) {
  final Map<TKey, _Cell<TIn>> cells = <TKey, _Cell<TIn>>{};
  final IDisposable ar = autorunOpts(
    DebugNameDataLike(debugReferenceFn: setup),
    (reader) {
      final List<TIn> arr = items.read(reader);
      final Set<TKey> seen = <TKey>{};
      final List<_Addition<TKey, TIn>> additions = <_Addition<TKey, TIn>>[];
      transaction((tx) {
        for (final TIn item in arr) {
          final TKey key = keyFn(item);
          seen.add(key);
          final _Cell<TIn>? existing = cells[key];
          if (existing != null) {
            existing.value.set(item, tx, null);
          } else {
            final DisposableStore store = DisposableStore();
            final ISettableObservable<TIn, Object?> value =
                observableValue<TIn, Object?>('keyedItem', item);
            final _Cell<TIn> cell = _Cell<TIn>(value, store);
            cells[key] = cell;
            additions.add(_Addition<TKey, TIn>(key, cell));
          }
        }
        for (final MapEntry<TKey, _Cell<TIn>> entry in cells.entries.toList()) {
          if (!seen.contains(entry.key)) {
            entry.value.store.dispose();
            cells.remove(entry.key);
          }
        }
      });
      // Setup runs after the transaction so per-key autoruns observe the
      // final cell values on their first read.
      for (final _Addition<TKey, TIn> addition in additions) {
        setup(addition.key, addition.cell.value as dynamic, addition.cell.store);
      }
    },
    debugLocation,
  );
  return toDisposable(() {
    ar.dispose();
    for (final _Cell<TIn> cell in cells.values) {
      cell.store.dispose();
    }
    cells.clear();
  });
}

/// 1:1: `export interface IReaderWithDispose extends IReaderWithStore, IDisposable`
abstract class IReaderWithDispose implements IReaderWithStore, IDisposable {}

/// Carrier reader that adds a `dispose()` callback onto an IReaderWithStore.
class _SelfDisposableReader implements IReaderWithDispose {
  _SelfDisposableReader(this._reader, this._disposeFn);
  final IReaderWithStore _reader;
  final void Function() _disposeFn;

  @override
  Object get store => _reader.store;
  @override
  Object get delayedStore => _reader.delayedStore;
  @override
  T readObservable<T>(IObservableWithChange<T, Object?> observable) =>
      _reader.readObservable(observable);
  @override
  void dispose() => _disposeFn();
}

/// 1:1: `export function autorunSelfDisposable(fn, debugLocation)`
IDisposable autorunSelfDisposable(
  void Function(IReaderWithDispose reader) fn, [
  DebugLocation? debugLocation,
]) {
  IDisposable? ar;
  bool disposed = false;
  ar = autorun((reader) {
    fn(_SelfDisposableReader(reader, () {
      ar?.dispose();
      disposed = true;
    }));
  }, debugLocation);
  if (disposed) {
    ar.dispose();
  }
  return ar;
}

/// 1:1: `export function registerAutorunSelfDisposable(store, fn, debugLocation)`
void registerAutorunSelfDisposable(
  DisposableStore store,
  void Function(IReaderWithDispose reader) fn, [
  DebugLocation? debugLocation,
]) {
  IDisposable? ar;
  bool disposeSync = false;
  ar = autorun((reader) {
    fn(_SelfDisposableReader(reader, () {
      final IDisposable? current = ar;
      if (current == null) {
        // dispose on first run, ar is not initialized yet.
        disposeSync = true;
      } else {
        // dispose on reaction, ar is already registered.
        store.delete(current);
      }
    }));
  }, debugLocation);
  if (disposeSync) {
    ar.dispose();
  } else {
    store.add(ar);
  }
}
