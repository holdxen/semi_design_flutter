// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/utils/runOnChange.ts
// Translated 1:1. TS conditional type `RemoveUndefined<T>` -> `Object?`
// carrier; `Promise<void>` -> `Future<void>`; the inline change-tracker object
// literal -> a private carrier implementing IChangeTracker.
// ---------------------------------------------------------------------------

import '../base.dart' show IObservableWithChange, IReader;
import '../changeTracker.dart' show IChangeContext, IChangeTracker;
import '../commonFacade/cancellation.dart' show CancellationToken, cancelOnDispose;
import '../commonFacade/deps.dart' show DisposableStore, IDisposable, toDisposable;
import '../reactions/autorun.dart' show AutorunHandleChangesOpts, autorunWithStoreHandleChanges;

/// 1:1: `export type RemoveUndefined<T> = T extends undefined ? never : T`
/// Dart has no `undefined` in the union; deltas are carried as `Object?`.
typedef RemoveUndefined<T> = Object?;

/// 1:1: `{ deltas: RemoveUndefined<TChange>[]; didChange: boolean }`
class _ChangeSummary {
  final List<RemoveUndefined<Object?>> deltas = <RemoveUndefined<Object?>>[];
  bool didChange = false;
}

/// 1:1: inline changeTracker object literal in `runOnChange`.
class _RunOnChangeTracker<T, TChange> implements IChangeTracker<_ChangeSummary> {
  _RunOnChangeTracker(this._observable);
  final IObservableWithChange<T, TChange> _observable;

  @override
  _ChangeSummary createChangeSummary(_ChangeSummary? previous) => _ChangeSummary();

  @override
  bool handleChange(IChangeContext context, _ChangeSummary changeSummary) {
    if (context.didChange(_observable)) {
      final Object? e = context.change;
      // 1:1: `if (e !== undefined)` — Dart represents JS undefined as null.
      if (e != null) {
        changeSummary.deltas.add(e);
      }
      changeSummary.didChange = true;
    }
    return true;
  }

  @override
  void beforeUpdate(IReader reader, _ChangeSummary change) {
    // TS declares beforeUpdate optional and this tracker does not define it.
  }
}

/// 1:1: `export function runOnChange<T, TChange>(observable, cb)`
IDisposable runOnChange<T, TChange>(
  IObservableWithChange<T, TChange> observable,
  void Function(T value, T previousValue, List<RemoveUndefined<TChange>> deltas)
      cb,
) {
  T? previousValue;
  bool firstRun = true;
  return autorunWithStoreHandleChanges<_ChangeSummary>(
    AutorunHandleChangesOpts<_ChangeSummary>(
      changeTracker: _RunOnChangeTracker<T, TChange>(observable),
    ),
    (reader, changeSummary, store) {
      final T value = observable.read(reader);
      final T? previous = previousValue;
      if (changeSummary.didChange) {
        previousValue = value;
        // didChange can never be true on the first autorun, so previous is defined.
        cb(
          value,
          previous as T,
          changeSummary.deltas.cast<RemoveUndefined<TChange>>(),
        );
      }
      if (firstRun) {
        firstRun = false;
        previousValue = value;
      }
    },
  );
}

/// 1:1: `export function runOnChangeWithStore<T, TChange>(observable, cb)`
IDisposable runOnChangeWithStore<T, TChange>(
  IObservableWithChange<T, TChange> observable,
  void Function(
    T value,
    T previousValue,
    List<RemoveUndefined<TChange>> deltas,
    DisposableStore store,
  ) cb,
) {
  final DisposableStore store = DisposableStore();
  final IDisposable disposable = runOnChange<T, TChange>(
    observable,
    (value, previous, deltas) {
      store.clear();
      cb(value, previous, deltas, store);
    },
  );
  return toDisposable(() {
    disposable.dispose();
    store.dispose();
  });
}

/// 1:1: `export function runOnChangeWithCancellationToken<T, TChange>(observable, cb)`
IDisposable runOnChangeWithCancellationToken<T, TChange>(
  IObservableWithChange<T, TChange> observable,
  Future<void> Function(
    T value,
    T previousValue,
    List<RemoveUndefined<TChange>> deltas,
    CancellationToken token,
  ) cb,
) {
  return runOnChangeWithStore<T, TChange>(observable, (value, previous, deltas, store) {
    cb(value, previous, deltas, cancelOnDispose(store));
  });
}
