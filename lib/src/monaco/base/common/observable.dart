// ---------------------------------------------------------------------------
// Facade for vscode/src/vs/base/common/observable.ts (1:1 interface subset).
//
// Source observable.ts is `export * from './observableInternal/index.js'`.
// This is an INCREMENTAL skeleton: only the interfaces needed by dependents
// (currently event.ts's fromObservable) are declared here. They mirror
// observableInternal/base.ts 1:1. The full observable implementation will be
// filled in when the observableInternal SCC batch is ported.
// ---------------------------------------------------------------------------

/// 1:1: `export interface IObserver` (observableInternal/base.ts)
abstract class IObserver {
  void beginUpdate<T>(Object observable);
  void endUpdate<T>(Object observable);
  void handlePossibleChange<T>(Object observable);
  void handleChange<T, TChange>(Object observable, TChange change);
}

/// 1:1: `export interface IObservableWithChange<T, TChange>`
abstract class IObservableWithChange<T, TChange> {
  T get();
  void reportChanges();
  void addObserver(IObserver observer);
  void removeObserver(IObserver observer);
}

/// 1:1: `export interface IObservable<T> extends IObservableWithChange<T, unknown>`
abstract class IObservable<T> implements IObservableWithChange<T, Object?> {}
