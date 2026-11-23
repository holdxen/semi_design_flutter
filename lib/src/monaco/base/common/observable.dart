// ---------------------------------------------------------------------------
// Facade for vscode/src/vs/base/common/observable.ts (1:1).
//
// Source observable.ts is `export * from './observableInternal/index.js'`:
// there is exactly ONE IObservable / IObserver / IObservableWithChange
// definition. This was an INCREMENTAL skeleton (only the interfaces needed by
// event.ts's fromObservable) while the observableInternal SCC was being ported.
// Now that core is ported, the facade re-exports those exact types so that
// `eventFromObservableLight` accepts real observables (e.g. observableValue),
// matching the single-type TS source.
// ---------------------------------------------------------------------------

export 'observableInternal/base.dart'
    show IObserver, IObservableWithChange, IObservable;
