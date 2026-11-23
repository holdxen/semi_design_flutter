// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/experimental/reducer.ts
// Translated 1:1. TS union `T | (() => T)` is carried as Object? and
// dispatched with `is Function`; the `SimplifyObservableWithChange` conditional
// type collapses to IObservableWithChange at runtime.
// ---------------------------------------------------------------------------

import '../base.dart' show IObservableWithChange, ISettableObservable, ITransaction;
import '../changeTracker.dart' show IChangeTracker;
import '../commonFacade/deps.dart'
    show BugIndicatingError, EqualityComparer, strictEquals;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData, DebugOwner;
import '../observables/derivedImpl.dart' show DerivedWithSetter, IDerivedReader;
import '../transaction.dart' show subtransaction;

/// 1:1: `export interface IReducerOptions`
class IReducerOptions<T, TChangeSummary, TOutChange> {
  IReducerOptions({
    required this.initial,
    this.disposeFinal,
    this.changeTracker,
    this.equalityComparer,
    required this.update,
  });

  /// 1:1: `initial: T | (() => T)`
  final Object? initial;
  final void Function(T value)? disposeFinal;
  final IChangeTracker<TChangeSummary>? changeTracker;
  final EqualityComparer<T>? equalityComparer;
  final T Function(
    IDerivedReader<TOutChange> reader,
    T previousValue,
    TChangeSummary changes,
  ) update;
}

/// 1:1: `observableReducer` - returns IObservable<T> when TChange is void,
/// otherwise IObservableWithChange<T, TChange>. Dart keeps the change type slot.
IObservableWithChange<T, TOutChange> observableReducer<T, TInChanges,
    TOutChange>(
  DebugOwner owner,
  IReducerOptions<T, TInChanges, TOutChange> options,
) {
  return observableReducerSettable<T, TInChanges, TOutChange>(owner, options);
}

/// 1:1: `observableReducerSettable`
ISettableObservable<T, TOutChange> observableReducerSettable<T, TInChanges,
    TOutChange>(
  DebugOwner owner,
  IReducerOptions<T, TInChanges, TOutChange> options,
) {
  T? prevValue;
  bool hasValue = false;

  late final DerivedWithSetter<T, TInChanges, TOutChange> d;
  d = DerivedWithSetter<T, TInChanges, TOutChange>(
    DebugNameData(owner, null, options.update),
    (IDerivedReader<TOutChange> reader, TInChanges changeSummary) {
      if (!hasValue) {
        final Object? initial = options.initial;
        prevValue = initial is Function ? initial() as T : initial as T;
        hasValue = true;
      }
      final T newValue = options.update(reader, prevValue as T, changeSummary);
      prevValue = newValue;
      return newValue;
    },
    options.changeTracker,
    () {
      if (hasValue) {
        options.disposeFinal?.call(prevValue as T);
        hasValue = false;
      }
    },
    options.equalityComparer ?? strictEquals,
    (T value, ITransaction? tx, TOutChange change) {
      if (!hasValue) {
        throw BugIndicatingError(
            'Can only set when there is a listener! This is to prevent leaks.');
      }
      subtransaction(tx, (ITransaction tx) {
        prevValue = value;
        d.setValue(value, tx, change);
      });
    },
    DebugLocation.ofCaller(),
  );

  return d;
}
