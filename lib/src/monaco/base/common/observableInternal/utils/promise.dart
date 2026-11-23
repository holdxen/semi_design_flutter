// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/utils/promise.ts
// Translated 1:1. TS `Promise` -> `Future`; the `.then(onOk, onErr)` dual
// handler maps to `then(...).catchError(...)` with the error rethrown, matching
// the source's `throw error` in the rejection branch.
// ---------------------------------------------------------------------------

import 'dart:async';

import '../../lifecycle.dart' show DisposableStore;
import '../base.dart' show IObservable, ISettableObservable;
import '../observables/derived.dart' show derived;
import '../observables/observableValue.dart' show observableValue;
import '../reactions/autorun.dart' show autorun;
import '../transaction.dart' show transaction;

/// 1:1: `class ObservableLazy<T>`
class ObservableLazy<T> {
  ObservableLazy(this._computeValue);

  final T Function() _computeValue;
  late final ISettableObservable<T?, Object?> _value =
      observableValue<T?, Object?>(this, null);

  /// 1:1: `get cachedValue()`
  IObservable<T?> get cachedValue => _value;

  /// 1:1: `getValue()`
  T getValue() {
    T? v = _value.get();
    if (v == null) {
      v = _computeValue();
      _value.set(v, null, null);
    }
    return v as T;
  }
}

/// 1:1: `class PromiseResult<T>`
class PromiseResult<T> {
  PromiseResult(this.data, this.error);

  /// 1:1: `data`
  final T? data;

  /// 1:1: `error`
  final Object? error;

  /// 1:1: `getDataOrThrow()`
  T getDataOrThrow() {
    final e = error;
    if (e != null) {
      throw e;
    }
    return data as T;
  }
}

/// 1:1: `class ObservablePromise<T>`
class ObservablePromise<T> {
  ObservablePromise(Future<T> promise) {
    _value = observableValue<PromiseResult<T>?, Object?>(this, null);
    promiseResult = _value;
    resolvedValue = derived<T?, Object?>(
      this,
      (reader) {
        final result = _value.read(reader);
        if (result == null) return null;
        return result.getDataOrThrow();
      },
    );
    this.promise = promise.then((value) {
      transaction((tx) {
        _value.set(PromiseResult<T>(value, null), tx, null);
      });
      return value;
    }).catchError((Object error) {
      transaction((tx) {
        _value.set(PromiseResult<T>(null, error), tx, null);
      });
      throw error;
    });
  }

  /// 1:1: `ObservablePromise.fromFn`
  static ObservablePromise<T> fromFn<T>(Future<T> Function() fn) =>
      ObservablePromise<T>(fn());

  /// 1:1: `ObservablePromise.resolved`
  factory ObservablePromise.resolved(T value) =>
      ObservablePromise<T>(Future<T>.value(value));

  late final ISettableObservable<PromiseResult<T>?, Object?> _value;

  /// 1:1: `promise`
  late final Future<T> promise;

  /// 1:1: `promiseResult`
  late final IObservable<PromiseResult<T>?> promiseResult;

  /// 1:1: `resolvedValue`
  late final IObservable<T?> resolvedValue;
}

/// 1:1: `class ObservableResolvedPromise<T>`
class ObservableResolvedPromise<T> {
  ObservableResolvedPromise(
    IObservable<ObservablePromise<T>> source,
    T initialValue,
    DisposableStore store,
  ) {
    _isResolving = observableValue<bool, Object?>(this, false);
    _lastResolved = observableValue<T, Object?>(this, initialValue);
    lastResolved = _lastResolved;
    store.add(autorun((reader) {
      final current = source.read(reader);
      _runningPromise = current;
      final result = current.promiseResult.read(reader);
      if (result != null) {
        if (identical(current, _runningPromise)) {
          _isResolving.set(false, null, null);
          _lastResolved.set(result.getDataOrThrow(), null, null);
        }
      } else {
        _isResolving.set(true, null, null);
      }
    }));
  }

  late final ISettableObservable<T, Object?> _lastResolved;
  late final ISettableObservable<bool, Object?> _isResolving;

  /// 1:1: `lastResolved`
  late final IObservable<T> lastResolved;

  /// 1:1: `isResolving`
  IObservable<bool> get isResolving => _isResolving;

  ObservablePromise<T>? _runningPromise;
}

/// 1:1: `class ObservableLazyPromise<T>`
class ObservableLazyPromise<T> {
  ObservableLazyPromise(this._computePromise) {
    _lazyValue = ObservableLazy<ObservablePromise<T>>(
        () => ObservablePromise<T>(_computePromise()));
    cachedPromiseResult = derived<PromiseResult<T>?, Object?>(
      this,
      (reader) => _lazyValue.cachedValue.read(reader)?.promiseResult.read(reader),
    );
  }

  final Future<T> Function() _computePromise;

  late final ObservableLazy<ObservablePromise<T>> _lazyValue;

  /// 1:1: `cachedPromiseResult`
  late final IObservable<PromiseResult<T>?> cachedPromiseResult;

  /// 1:1: `getPromise()`
  Future<T> getPromise() => _lazyValue.getValue().promise;
}
