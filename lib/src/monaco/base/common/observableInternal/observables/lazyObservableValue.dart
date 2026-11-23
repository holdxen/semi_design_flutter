// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/lazyObservableValue.ts
// Translated 1:1.
// ---------------------------------------------------------------------------

import '../base.dart'
    show IObserver, ISettableObservable, ITransaction, IObservableWithChange;
import '../commonFacade/deps.dart' show EqualityComparer;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData;
import '../logging/logging.dart' show IChangeInformation, getLogger;
import '../transaction.dart' show TransactionImpl;
import 'baseObservable.dart' show BaseObservable;

/// 1:1: `export class LazyObservableValue<T, TChange = void>`
class LazyObservableValue<T, TChange> extends BaseObservable<T, TChange>
    implements ISettableObservable<T, TChange> {
  LazyObservableValue(
    this._debugNameData,
    T initialValue,
    this._equalityComparator,
    DebugLocation? debugLocation,
  )   : _value = initialValue,
        super(debugLocation);

  final DebugNameData _debugNameData;
  final EqualityComparer<T> _equalityComparator;

  T _value;
  bool _isUpToDate = true;
  final List<TChange> _deltas = <TChange>[];

  @override
  String get debugName => _debugNameData.getDebugName(this) ?? 'LazyObservableValue';

  @override
  T get() {
    _update();
    return _value;
  }

  /// 1:1: `private _update()`
  void _update() {
    if (_isUpToDate) {
      return;
    }
    _isUpToDate = true;
    if (_deltas.isNotEmpty) {
      for (final change in _deltas) {
        getLogger()?.handleObservableUpdated(this, IChangeInformation(
              change: change,
              didChange: true,
              oldValue: '(unknown)',
              newValue: _value,
              hadValue: true,
            ));
        for (final observer in debugGetObservers()) {
          observer.handleChange<T, TChange>(this, change);
        }
      }
      _deltas.clear();
    } else {
      getLogger()?.handleObservableUpdated(this, IChangeInformation(
            change: null,
            didChange: true,
            oldValue: '(unknown)',
            newValue: _value,
            hadValue: true,
          ));
      for (final observer in debugGetObservers()) {
        observer.handleChange<T, Object?>(this, null);
      }
    }
  }

  int _updateCounter = 0;

  /// 1:1: `private _beginUpdate()`
  void _beginUpdate() {
    _updateCounter++;
    if (_updateCounter == 1) {
      for (final observer in debugGetObservers()) {
        observer.beginUpdate(this as dynamic);
      }
    }
  }

  /// 1:1: `private _endUpdate()`
  void _endUpdate() {
    _updateCounter--;
    if (_updateCounter == 0) {
      _update();
      // End update could change the observer list.
      final observers = debugGetObservers().toList();
      for (final r in observers) {
        r.endUpdate(this as dynamic);
      }
    }
  }

  @override
  void addObserver(IObserver observer) {
    final shouldCallBeginUpdate =
        !debugGetObservers().contains(observer) && _updateCounter > 0;
    super.addObserver(observer);
    if (shouldCallBeginUpdate) {
      observer.beginUpdate(this as dynamic);
    }
  }

  @override
  void removeObserver(IObserver observer) {
    final shouldCallEndUpdate =
        debugGetObservers().contains(observer) && _updateCounter > 0;
    super.removeObserver(observer);
    if (shouldCallEndUpdate) {
      observer.endUpdate(this as dynamic);
    }
  }

  @override
  void set(T value, ITransaction? tx, TChange change) {
    if (change == null && _equalityComparator(_value, value)) {
      return;
    }

    TransactionImpl? localTx;
    if (tx == null) {
      localTx = TransactionImpl((_) {}, () => 'Setting $debugName');
      tx = localTx;
    }
    try {
      _isUpToDate = false;
      _setValue(value);
      if (change != null) {
        _deltas.add(change);
      }
      tx.updateObserver(_SelfObserver<T, TChange>(this), this as dynamic);
      if (_updateCounter > 1) {
        // Already started begin/end update, so manually call handlePossibleChange.
        for (final observer in debugGetObservers()) {
          observer.handlePossibleChange(this as dynamic);
        }
      }
    } finally {
      localTx?.finish();
    }
  }

  @override
  String toString() => '$debugName: $_value';

  void _setValue(T newValue) => _value = newValue;
}

/// 1:1: the inline observer object passed to `tx.updateObserver` in `set`.
class _SelfObserver<TVal, TChg> implements IObserver {
  _SelfObserver(this.owner);
  final LazyObservableValue<TVal, TChg> owner;

  @override
  void beginUpdate<T>(covariant IObservableWithChange<T, Object?> observable) =>
      owner._beginUpdate();
  @override
  void endUpdate<T>(covariant IObservableWithChange<T, Object?> observable) =>
      owner._endUpdate();
  @override
  void handleChange<T, C>(covariant IObservableWithChange<T, C> observable, C change) {}
  @override
  void handlePossibleChange<T>(covariant IObservableWithChange<T, Object?> observable) {}
}
