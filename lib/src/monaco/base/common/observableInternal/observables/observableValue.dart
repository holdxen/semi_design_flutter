// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/observableValue.ts
// Translated 1:1.
// ---------------------------------------------------------------------------

import '../base.dart' show ISettableObservable, ITransaction;
import '../commonFacade/deps.dart' show EqualityComparer, strictEquals;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData;
import '../../lifecycle.dart' show IDisposable;
import '../logging/logging.dart' show IChangeInformation, getLogger;
import '../transaction.dart' show TransactionImpl;
import 'baseObservable.dart' show BaseObservable;

/// 1:1: `observableValue<T,TChange>(name, initialValue)` (string | owner overloads)
ISettableObservable<T, TChange> observableValue<T, TChange>(
  Object nameOrOwner,
  T initialValue, [
  DebugLocation? debugLocation,
]) {
  final DebugNameData debugNameData = nameOrOwner is String
      ? DebugNameData(null, nameOrOwner, null)
      : DebugNameData(nameOrOwner, null, null);
  return ObservableValue<T, TChange>(
      debugNameData, initialValue, strictEquals, debugLocation);
}

/// 1:1: `export class ObservableValue<T, TChange = void>`
class ObservableValue<T, TChange> extends BaseObservable<T, TChange>
    implements ISettableObservable<T, TChange> {
  ObservableValue(
    this._debugNameData,
    T initialValue,
    this._equalityComparator,
    DebugLocation? debugLocation,
  )   : _value = initialValue,
        super(debugLocation) {
    getLogger()?.handleObservableUpdated(this, IChangeInformation(
          hadValue: false,
          newValue: initialValue,
          change: null,
          didChange: true,
          oldValue: null,
        ));
  }

  final DebugNameData _debugNameData;
  final EqualityComparer<T> _equalityComparator;

  /// 1:1: `protected _value: T`
  T _value;

  @override
  String get debugName => _debugNameData.getDebugName(this) ?? 'ObservableValue';

  @override
  T get() => _value;

  @override
  void set(T value, ITransaction? tx, TChange change) {
    // 1:1: `if (change === undefined && _equalityComparator(...)) return;`
    if (change == null && _equalityComparator(_value, value)) {
      return;
    }

    TransactionImpl? localTx;
    if (tx == null) {
      localTx = TransactionImpl((_) {}, () => 'Setting $debugName');
      tx = localTx;
    }
    try {
      final T oldValue = _value;
      _setValue(value);
      getLogger()?.handleObservableUpdated(this, IChangeInformation(
            oldValue: oldValue,
            newValue: value,
            change: change,
            didChange: true,
            hadValue: true,
          ));
      for (final observer in debugGetObservers()) {
        tx.updateObserver(observer, this as dynamic);
        observer.handleChange<T, TChange>(this, change);
      }
    } finally {
      localTx?.finish();
    }
  }

  @override
  String toString() => '$debugName: $_value';

  /// 1:1: `protected _setValue(newValue)`
  void _setValue(T newValue) => _value = newValue;

  /// 1:1: `debugGetState()`
  Map<String, Object?> debugGetState() => <String, Object?>{'value': _value};

  /// 1:1: `debugSetValue(value)`
  void debugSetValue(Object? value) => _value = value as T;
}

/// 1:1: `disposableObservableValue<T extends IDisposable | undefined>(...)`
ISettableObservable<T, TChange> disposableObservableValue<T extends Object?, TChange>(
  Object nameOrOwner,
  T initialValue, [
  DebugLocation? debugLocation,
]) {
  final DebugNameData debugNameData = nameOrOwner is String
      ? DebugNameData(null, nameOrOwner, null)
      : DebugNameData(nameOrOwner, null, null);
  return DisposableObservableValue<T, TChange>(
      debugNameData, initialValue, strictEquals, debugLocation);
}

/// 1:1: `export class DisposableObservableValue<T, TChange>`
class DisposableObservableValue<T extends Object?, TChange>
    extends ObservableValue<T, TChange> implements IDisposable {
  DisposableObservableValue(
    super.debugNameData,
    super.initialValue,
    super.equalityComparator,
    super.debugLocation,
  );

  @override
  void _setValue(T newValue) {
    if (_value == newValue) {
      return;
    }
    final old = _value;
    if (old is IDisposable) {
      old.dispose();
    }
    _value = newValue;
  }

  @override
  void dispose() {
    final v = _value;
    if (v is IDisposable) {
      v.dispose();
    }
  }
}
