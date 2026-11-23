// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/transaction.ts
// Translated 1:1.
// ---------------------------------------------------------------------------

import 'base.dart'
    show
        IObservableWithChange,
        IObserver,
        ITransaction,
        handleBugIndicatingErrorRecovery;
import 'debugName.dart' show getFunctionName;
import 'logging/logging.dart' show getLogger;

/// 1:1: `export function transaction(fn, getDebugName?)`
void transaction(void Function(ITransaction tx) fn, [String Function()? getDebugName]) {
  final tx = TransactionImpl(fn, getDebugName);
  try {
    fn(tx);
  } finally {
    tx.finish();
  }
}

/// 1:1: `let _globalTransaction: ITransaction | undefined`
ITransaction? _globalTransaction;

/// 1:1: `export function globalTransaction(fn)`
void globalTransaction(void Function(ITransaction tx) fn) {
  final current = _globalTransaction;
  if (current != null) {
    fn(current);
  } else {
    final tx = TransactionImpl(fn, null);
    _globalTransaction = tx;
    try {
      fn(tx);
    } finally {
      // During finish, more actions might be added to the transaction.
      tx.finish();
      // Which is why we only clear the global transaction after finish.
      _globalTransaction = null;
    }
  }
}

/// 1:1: `export async function asyncTransaction(fn, getDebugName?)`
Future<void> asyncTransaction(Future<void> Function(ITransaction tx) fn,
    [String Function()? getDebugName]) async {
  final tx = TransactionImpl(fn, getDebugName);
  try {
    await fn(tx);
  } finally {
    tx.finish();
  }
}

/// 1:1: `export function subtransaction(tx, fn, getDebugName?)`
void subtransaction(ITransaction? tx, void Function(ITransaction tx) fn,
    [String Function()? getDebugName]) {
  if (tx == null) {
    transaction(fn, getDebugName);
  } else {
    fn(tx);
  }
}

/// 1:1: `export class TransactionImpl implements ITransaction`
class TransactionImpl implements ITransaction {
  /// 1:1: `_updatingObservers: {...}[] | null = []`
  List<UpdatingObserver>? _updatingObservers = <UpdatingObserver>[];

  TransactionImpl(this._fn, [this._getDebugName]) {
    getLogger()?.handleBeginTransaction(this);
  }

  /// 1:1: `public readonly _fn: Function`
  final Function _fn;
  final String Function()? _getDebugName;

  /// 1:1: `getDebugName()`
  String? getDebugName() {
    final g = _getDebugName;
    if (g != null) {
      return g();
    }
    return getFunctionName(_fn);
  }

  @override
  void updateObserver(IObserver observer, IObservableWithChange<Object?, Object?> observable) {
    final updating = _updatingObservers;
    if (updating == null) {
      // Transaction already finished! Error recovery: re-route to a fresh one.
      handleBugIndicatingErrorRecovery('Transaction already finished!');
      transaction((tx) {
        tx.updateObserver(observer, observable);
      });
      return;
    }
    // When this gets called while finish is active, they will still get considered.
    // Source passes `observable` (typed IObservableWithChange<any,any>) to
    // observer.beginUpdate (IObservable<any>). Dart generics are invariant, so
    // bridge with `dynamic` at this boundary; the runtime object is unchanged.
    updating.add(UpdatingObserver(observer, observable));
    observer.beginUpdate(observable);
  }

  /// 1:1: `finish()`
  void finish() {
    final updatingObservers = _updatingObservers;
    if (updatingObservers == null) {
      handleBugIndicatingErrorRecovery('transaction.finish() has already been called!');
      return;
    }
    for (final entry in updatingObservers) {
      entry.observer.endUpdate(entry.observable);
    }
    // Prevent anyone from updating observers from now on.
    _updatingObservers = null;
    getLogger()?.handleEndTransaction(this);
  }

  /// 1:1: `debugGetUpdatingObservers()`
  List<UpdatingObserver>? debugGetUpdatingObservers() => _updatingObservers;
}

/// 1:1: `{ observer: IObserver; observable: IObservable<any> }`
class UpdatingObserver {
  UpdatingObserver(this.observer, this.observable);
  final IObserver observer;
  final IObservableWithChange<Object?, Object?> observable;
}
