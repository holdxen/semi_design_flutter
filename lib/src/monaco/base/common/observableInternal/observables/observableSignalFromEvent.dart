// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/observableSignalFromEvent.ts
// Translated 1:1. `Event<any>` is the callable listener-registration typedef;
// `undefined` change is carried as Dart `null`.
// ---------------------------------------------------------------------------

import '../base.dart' show IObservable;
import '../commonFacade/deps.dart' show Event, IDisposable;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData, DebugOwner;
import '../transaction.dart' show transaction;
import 'baseObservable.dart' show BaseObservable;

/// 1:1: `observableSignalFromEvent(owner, event, debugLocation?)`
IObservable<void> observableSignalFromEvent(
  DebugOwner owner,
  Event<Object?> event, [
  DebugLocation? debugLocation,
]) {
  return FromEventObservableSignal(
    owner is String ? owner : DebugNameData(owner, null, null),
    event,
    debugLocation ?? DebugLocation.ofCaller(),
  );
}

/// 1:1: `class FromEventObservableSignal extends BaseObservable<void>`
class FromEventObservableSignal extends BaseObservable<void, Object?>
    implements IObservable<void> {
  FromEventObservableSignal(
    this._debugNameDataOrName,
    this._event,
    DebugLocation? debugLocation,
  ) : super(debugLocation);

  final Object _debugNameDataOrName;
  final Event<Object?> _event;
  IDisposable? _subscription;

  @override
  late final String debugName = _debugNameDataOrName is String
      ? _debugNameDataOrName
      : (_debugNameDataOrName as DebugNameData).getDebugName(this) ??
          'Observable Signal From Event';

  @override
  void onFirstObserverAdded() {
    _subscription = _event(handleEvent);
  }

  /// 1:1: the `handleEvent` field arrow — wraps updates in a transaction.
  void handleEvent([Object? args]) {
    transaction(
      (tx) {
        for (final o in debugGetObservers()) {
          tx.updateObserver(o, this as dynamic);
          o.handleChange<void, Object?>(this, null);
        }
      },
      () => debugName,
    );
  }

  @override
  void onLastObserverRemoved() {
    _subscription!.dispose();
    _subscription = null;
  }

  @override
  void get() {
    // NO OP
  }
}
