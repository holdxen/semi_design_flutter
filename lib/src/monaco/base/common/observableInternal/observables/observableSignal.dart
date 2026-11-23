// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/observableSignal.ts
// Translated 1:1.
// ---------------------------------------------------------------------------

import '../base.dart' show IObservableWithChange, ITransaction;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData;
import '../transaction.dart' show transaction;
import 'baseObservable.dart' show BaseObservable;

/// 1:1: `observableSignal<TDelta>(debugName | owner)` overloads
IObservableSignal<TChange> observableSignal<TChange>(
  Object debugNameOrOwner, [
  DebugLocation? debugLocation,
]) {
  if (debugNameOrOwner is String) {
    return ObservableSignal<TChange>(debugNameOrOwner, null, debugLocation);
  }
  return ObservableSignal<TChange>(null, debugNameOrOwner, debugLocation);
}

/// 1:1: `export interface IObservableSignal<TChange>`
abstract class IObservableSignal<TChange>
    implements IObservableWithChange<Object?, TChange> {
  void trigger(ITransaction? tx, TChange change);
}

/// 1:1: `class ObservableSignal<TChange>`
class ObservableSignal<TChange> extends BaseObservable<Object?, TChange>
    implements IObservableSignal<TChange> {
  ObservableSignal(this._debugName, this._owner, DebugLocation? debugLocation)
      : super(debugLocation);

  final String? _debugName;
  final Object? _owner;

  @override
  String get debugName =>
      DebugNameData(_owner, _debugName, null).getDebugName(this) ??
      'Observable Signal';

  @override
  String toString() => debugName;

  @override
  void trigger(ITransaction? tx, TChange change) {
    if (tx == null) {
      transaction((t) => trigger(t, change), () => 'Trigger signal $debugName');
      return;
    }
    for (final o in debugGetObservers()) {
      tx.updateObserver(o, this as dynamic);
      o.handleChange<Object?, TChange>(this, change);
    }
  }

  @override
  Object? get() {
    // NO OP
    return null;
  }
}
