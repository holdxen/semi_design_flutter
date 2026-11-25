// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/derived.ts
// Translated 1:1. The `_setDerivedOpts(derivedOpts)` module side effect at the
// bottom of the TS file is preserved via a top-level final initializer that
// registers a bridge into `setDerivedOpts`. TS overloads are unified into a
// single Dart function with optional trailing params (dispatched by null
// checks, exactly as the source's implementation signature does).
// ---------------------------------------------------------------------------

import '../base.dart'
    show
        IObservable,
        IObservableWithChange,
        IReader,
        ISettableObservable,
        ITransaction;
import '../changeTracker.dart' show IChangeTracker;
import '../commonFacade/deps.dart' show EqualityComparer, strictEquals;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData, DebugOwner, IDebugNameData;
import '../../lifecycle.dart' show DisposableStore, IDisposable;
import 'baseObservable.dart' show setDerivedOpts;
import 'derivedImpl.dart'
    show Derived, DerivedWithSetter, IDerivedReader;

/// 1:1: `derived<T,TChange>(computeFn)` / `derived(owner, computeFn, debugLocation?)`
IObservable<T> derived<T, TChange>(Object computeFnOrOwner,
    [Function? computeFn, DebugLocation? debugLocation]) {
  _ensureDerivedOptsRegistered();
  final DebugLocation? loc = debugLocation ?? DebugLocation.ofCaller();
  if (computeFn != null) {
    // TS passes a 1-arg `(reader) => T` where the compute slot is 2-arg;
    // JS ignores the extra changeSummary. Wrap to preserve that behavior.
    final fn = computeFn as Function;
    return Derived<T, Object?, TChange>(
      DebugNameData(computeFnOrOwner, null, computeFn),
      (reader, _) => fn(reader) as T,
      null,
      null,
      strictEquals,
      loc,
    );
  }
  final fn = computeFnOrOwner as Function;
  return Derived<T, Object?, TChange>(
    DebugNameData(null, null, fn),
    (reader, _) => fn(reader) as T,
    null,
    null,
    strictEquals,
    loc,
  );
}

/// 1:1: `derivedWithSetter<T>(owner, computeFn, setter, debugLocation?)`
ISettableObservable<T, void> derivedWithSetter<T>(
  DebugOwner owner,
  T Function(IReader reader) computeFn,
  void Function(T value, ITransaction? transaction) setter, [
  DebugLocation? debugLocation,
]) {
  _ensureDerivedOptsRegistered();
  final DebugLocation? loc = debugLocation ?? DebugLocation.ofCaller();
  return DerivedWithSetter<T, Object?, void>(
    DebugNameData(owner, null, computeFn),
    (IDerivedReader<void> reader, Object? changeSummary) => computeFn(reader),
    null,
    null,
    strictEquals,
    (T value, ITransaction? tx, void change) => setter(value, tx),
    loc,
  );
}

/// 1:1: `IDebugNameData & { equalsFn?, onLastObserverRemoved? }`
class DerivedOpts<T> implements IDebugNameData {
  DerivedOpts({
    this.owner,
    this.debugName,
    this.debugReferenceFn,
    this.equalsFn,
    this.onLastObserverRemoved,
  });

  @override
  final Object? owner;
  @override
  final Object? debugName;
  @override
  final Function? debugReferenceFn;
  final EqualityComparer<T>? equalsFn;
  final void Function()? onLastObserverRemoved;
}

/// 1:1: `derivedOpts<T>(options, computeFn, debugLocation?)`
IObservable<T> derivedOpts<T>(
  DerivedOpts<T> options,
  T Function(IReader reader) computeFn, [
  DebugLocation? debugLocation,
]) {
  _ensureDerivedOptsRegistered();
  final DebugLocation? loc = debugLocation ?? DebugLocation.ofCaller();
  return Derived<T, Object?, void>(
    DebugNameData(options.owner, options.debugName, options.debugReferenceFn),
    (IDerivedReader<void> reader, Object? changeSummary) => computeFn(reader),
    null,
    options.onLastObserverRemoved,
    options.equalsFn ?? strictEquals,
    loc,
  );
}

/// 1:1: `IDebugNameData & { changeTracker, equalityComparer? }`
class DerivedHandleChangesOpts<TChangeSummary, T>
    implements IDebugNameData {
  DerivedHandleChangesOpts({
    this.owner,
    this.debugName,
    this.debugReferenceFn,
    required this.changeTracker,
    this.equalityComparer,
  });

  @override
  final Object? owner;
  @override
  final Object? debugName;
  @override
  final Function? debugReferenceFn;
  final IChangeTracker<TChangeSummary> changeTracker;
  final EqualityComparer<T>? equalityComparer;
}

/// 1:1: `derivedHandleChanges<T,TDelta,TChangeSummary>(options, computeFn, debugLocation?)`
IObservableWithChange<T, TDelta> derivedHandleChanges<T, TDelta,
    TChangeSummary>(
  DerivedHandleChangesOpts<TChangeSummary, T> options,
  T Function(IDerivedReader<TDelta> reader, TChangeSummary changeSummary)
      computeFn, [
  DebugLocation? debugLocation,
]) {
  _ensureDerivedOptsRegistered();
  final DebugLocation? loc = debugLocation ?? DebugLocation.ofCaller();
  return Derived<T, TChangeSummary, TDelta>(
    DebugNameData(options.owner, options.debugName, null),
    computeFn,
    options.changeTracker,
    null,
    options.equalityComparer ?? strictEquals,
    loc,
  );
}

/// 1:1: `derivedWithStore<T>(computeFn)` / `(owner, computeFn, debugLocation?)`
IObservable<T> derivedWithStore<T>(Object computeFnOrOwner,
    [Function? computeFnOrUndefined, DebugLocation? debugLocation]) {
  _ensureDerivedOptsRegistered();
  final DebugLocation? loc = debugLocation ?? DebugLocation.ofCaller();
  late Function computeFn;
  late DebugOwner owner;
  if (computeFnOrUndefined == null) {
    computeFn = computeFnOrOwner as Function;
    owner = null;
  } else {
    owner = computeFnOrOwner;
    computeFn = computeFnOrUndefined as Function;
  }

  // Intentionally re-assigned in case an inactive observable is re-used later
  DisposableStore store = DisposableStore();

  return Derived<T, Object?, void>(
    DebugNameData(owner, null, computeFn),
    (IDerivedReader<void> reader, Object? changeSummary) {
      if (store.isDisposed) {
        store = DisposableStore();
      } else {
        store.clear();
      }
      return computeFn(reader, store) as T;
    },
    null,
    () => store.dispose(),
    strictEquals,
    loc,
  );
}

/// 1:1: `derivedDisposable<T extends IDisposable | undefined>(...)`
IObservable<T> derivedDisposable<T extends Object?>(Object computeFnOrOwner,
    [Function? computeFnOrUndefined, DebugLocation? debugLocation]) {
  _ensureDerivedOptsRegistered();
  final DebugLocation? loc = debugLocation ?? DebugLocation.ofCaller();
  late Function computeFn;
  late DebugOwner owner;
  if (computeFnOrUndefined == null) {
    computeFn = computeFnOrOwner as Function;
    owner = null;
  } else {
    owner = computeFnOrOwner;
    computeFn = computeFnOrUndefined as Function;
  }

  DisposableStore? store;
  return Derived<T, Object?, void>(
    DebugNameData(owner, null, computeFn),
    (IDerivedReader<void> reader, Object? changeSummary) {
      store ??= DisposableStore();
      store!.clear();
      final T result = computeFn(reader) as T;
      if (result != null) {
        store!.add(result as IDisposable);
      }
      return result;
    },
    null,
    () {
      if (store != null) {
        store!.dispose();
        store = null;
      }
    },
    strictEquals,
    loc,
  );
}

/// 1:1: `_setDerivedOpts(derivedOpts)` at the bottom of derived.ts.
/// Dart has no import-time module side effects and top-level finals initialize
/// lazily, so the bridge is installed by an idempotent guard called from every
/// factory below. This guarantees `baseObservable.dart`'s `map`/`flatten`
/// find the slot before use. The data argument is the options object literal
/// those methods pass (a `Map`; or a `DerivedOpts` when called directly).
bool _derivedOptsRegisteredFlag = false;

/// Public entry for modules that need the derived-opts bridge installed before
/// calling `ConvenientObservable.map`/`flatten` (TS gets this from importing
/// derived.ts at module load).
void ensureDerivedOptsRegistered() => _ensureDerivedOptsRegistered();

void _ensureDerivedOptsRegistered() {
  if (_derivedOptsRegisteredFlag) {
    return;
  }
  setDerivedOpts(_derivedOptsBridge);
  _derivedOptsRegisteredFlag = true;
}

Object? _derivedOptsBridge(
  Object data,
  Object? Function(IReader reader) compute, [
  Object? debugLocation,
]) {
  final DerivedOpts<Object?> opts;
  if (data is DerivedOpts<Object?>) {
    opts = data;
  } else {
    final map = data as Map<Object?, Object?>;
    opts = DerivedOpts<Object?>(
      owner: map['owner'],
      debugName: map['debugName'],
      debugReferenceFn: map['debugReferenceFn'] as Function?,
    );
  }
  // Dart: `derivedOpts` builds `Derived<T, Object?, void>`, which cannot be
  // viewed as `IObservable<T>` (= `IObservableWithChange<T, Object?>`) because
  // Dart's `void` is a top type, not a subtype of `Object?`. Build the same
  // Derived with `TChange = Object?` so `ConvenientObservable.map`/`flatten`
  // can return a well-typed observable (TS has no runtime reified generics).
  return Derived<Object?, Object?, Object?>(
    DebugNameData(opts.owner, opts.debugName, opts.debugReferenceFn),
    (IDerivedReader<Object?> reader, Object? changeSummary) => compute(reader),
    null,
    opts.onLastObserverRemoved,
    opts.equalsFn ?? strictEquals,
    debugLocation as DebugLocation?,
  );
}
