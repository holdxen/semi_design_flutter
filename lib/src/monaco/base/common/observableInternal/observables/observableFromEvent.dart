// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/observableFromEvent.ts
// Translated 1:1. The two TS overloads are merged into one function that
// dispatches on argument count; `namespace observableFromEvent` members become
// top-level helpers (Observer typedef + batchEventsGlobally), matching the
// project's established namespace porting convention. `undefined` is null.
// ---------------------------------------------------------------------------

import '../base.dart' show IObservable, ITransaction;
import '../commonFacade/deps.dart' show EqualityComparer, Event, IDisposable, strictEquals;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData, IDebugNameData;
import '../logging/logging.dart' show IChangeInformation, getLogger;
import '../transaction.dart' show subtransaction;
import 'baseObservable.dart' show BaseObservable;

/// 1:1: `observableFromEvent(owner, event, getValue, debugLocation?)` and
/// `observableFromEvent(event, getValue)` overloads, dispatched by arg count.
IObservable<T> observableFromEvent<T, TArgs>(
  Object? ownerOrEvent,
  Function eventOrGetValue, [
  Function? getValueOpt,
  DebugLocation? debugLocation,
]) {
  final bool twoArgs = getValueOpt == null;
  final Object? owner = twoArgs ? null : ownerOrEvent;
  final Event<TArgs> event =
      (twoArgs ? ownerOrEvent : eventOrGetValue) as Event<TArgs>;
  final T Function(TArgs?) getValue =
      (twoArgs ? eventOrGetValue : getValueOpt) as T Function(TArgs?);
  return FromEventObservable<TArgs, T>(
    DebugNameData(owner, null, getValue),
    event,
    getValue,
    () => FromEventObservable.globalTransaction,
    strictEquals,
    debugLocation ?? DebugLocation.ofCaller(),
  );
}

/// 1:1: `IDebugNameData & { equalsFn?, getTransaction? }` options carrier.
class ObservableFromEventOpts implements IDebugNameData {
  ObservableFromEventOpts({
    this.owner,
    this.debugName,
    this.debugReferenceFn,
    this.equalsFn,
    this.getTransaction,
  });

  @override
  final Object? owner;
  @override
  final Object? debugName;
  @override
  final Function? debugReferenceFn;
  final EqualityComparer? equalsFn;
  final ITransaction? Function()? getTransaction;
}

/// 1:1: `observableFromEventOpts(options, event, getValue, debugLocation?)`
IObservable<T> observableFromEventOpts<T, TArgs>(
  ObservableFromEventOpts options,
  Event<TArgs> event,
  T Function(TArgs?) getValue, [
  DebugLocation? debugLocation,
]) {
  return FromEventObservable<TArgs, T>(
    DebugNameData(
      options.owner,
      options.debugName,
      options.debugReferenceFn ?? getValue,
    ),
    event,
    getValue,
    () => options.getTransaction?.call() ?? FromEventObservable.globalTransaction,
    (options.equalsFn as EqualityComparer<T>?) ?? strictEquals,
    debugLocation ?? DebugLocation.ofCaller(),
  );
}

/// 1:1: `export class FromEventObservable<TArgs, T> extends BaseObservable<T>`
class FromEventObservable<TArgs, T> extends BaseObservable<T, Object?>
    implements IObservable<T> {
  /// 1:1: `public static globalTransaction: ITransaction | undefined`
  static ITransaction? globalTransaction;

  FromEventObservable(
    this._debugNameData,
    this.event,
    this._getValue,
    this._getTransaction,
    this._equalityComparator,
    DebugLocation? debugLocation,
  ) : super(debugLocation);

  final DebugNameData _debugNameData;
  final Event<TArgs> event;
  final T Function(TArgs?) _getValue;
  final ITransaction? Function() _getTransaction;
  final EqualityComparer<T> _equalityComparator;

  T? _value;
  bool _hasValue = false;
  IDisposable? _subscription;

  String? getDebugName() => _debugNameData.getDebugName(this);

  @override
  String get debugName {
    final name = getDebugName();
    return 'From Event' + (name != null && name.isNotEmpty ? ': $name' : '');
  }

  @override
  void onFirstObserverAdded() {
    _subscription = event(handleEvent);
  }

  /// 1:1: `private readonly handleEvent = (args) => { ... }`
  void handleEvent([TArgs? args]) {
    final T newValue = _getValue(args);
    final T? oldValue = _value;
    final bool hadValue = _hasValue;

    final bool didChange =
        !hadValue || !_equalityComparator(oldValue as T, newValue);
    bool didRunTransaction = false;

    if (didChange) {
      _value = newValue;
      _hasValue = true;
      if (hadValue) {
        didRunTransaction = true;
        subtransaction(
          _getTransaction(),
          (tx) {
            getLogger()?.handleObservableUpdated(
              this,
              IChangeInformation(
                oldValue: oldValue,
                newValue: newValue,
                change: null,
                didChange: didChange,
                hadValue: hadValue,
              ),
            );
            for (final o in debugGetObservers()) {
              tx.updateObserver(o, this as dynamic);
              o.handleChange<T, Object?>(this, null);
            }
          },
          () {
            final name = getDebugName();
            return 'Event fired' + (name != null ? ': $name' : '');
          },
        );
      }
    }

    if (!didRunTransaction) {
      getLogger()?.handleObservableUpdated(
        this,
        IChangeInformation(
          oldValue: oldValue,
          newValue: newValue,
          change: null,
          didChange: didChange,
          hadValue: hadValue,
        ),
      );
    }
  }

  @override
  void onLastObserverRemoved() {
    _subscription!.dispose();
    _subscription = null;
    _hasValue = false;
    _value = null;
  }

  @override
  T get() {
    if (_subscription != null) {
      if (!_hasValue) {
        handleEvent(null);
      }
      return _value as T;
    } else {
      // no cache, as there are no subscribers to keep it updated
      return _getValue(null);
    }
  }

  void debugSetValue(Object? value) {
    _value = value as T;
  }

  Map<String, Object?> debugGetState() =>
      <String, Object?>{'value': _value, 'hasValue': _hasValue};
}

/// 1:1: `namespace observableFromEvent { export const Observer = FromEventObservable }`
typedef ObservableFromEventObserver<TArgs, T> = FromEventObservable<TArgs, T>;

/// 1:1: `namespace observableFromEvent.batchEventsGlobally(tx, fn)`
void batchEventsGlobally(ITransaction tx, void Function() fn) {
  bool didSet = false;
  if (FromEventObservable.globalTransaction == null) {
    FromEventObservable.globalTransaction = tx;
    didSet = true;
  }
  try {
    fn();
  } finally {
    if (didSet) {
      FromEventObservable.globalTransaction = null;
    }
  }
}
