// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/base.ts
// Translated 1:1. TypeScript interfaces become Dart abstract classes; the
// type-only `readonly TChange` marker member is omitted (compile-time only).
// `console.error` is injected via `consoleError` to keep the port platform
// neutral (Dart has no browser console).
// ---------------------------------------------------------------------------

import '../errors.dart' show onUnexpectedError;

/// Injectable `console.error`, mirroring the source's `console.error(...)`.
/// Defaults to `print`; clients (tests / host) may override.
void Function(Object message, Object error) consoleError = (message, error) {
  print('$message $error');
};

/// 1:1: `interface IObservable<T> extends IObservableWithChange<T, unknown>`
abstract class IObservable<T> implements IObservableWithChange<T, Object?> {}

/// 1:1: `interface IObservableWithChange<T, TChange = unknown>`
abstract class IObservableWithChange<T, TChange> {
  T get();
  void reportChanges();
  void addObserver(IObserver observer);
  void removeObserver(IObserver observer);
  T read(IReader? reader);
  IObservable<T> recomputeInitiallyAndOnChange(Object store, [void Function(T value)? handleValue]);
  IObservable<T> keepObserved(Object store);
  IObservable<TNew> map<TNew>(TNew Function(T value, IReader reader) fn);
  IObservable<TNew> flatten<TNew>();
  IObservableWithChange<T, TChange> log();
  String get debugName;
}

/// 1:1: `interface IObserver`
abstract class IObserver {
  void beginUpdate<T>(IObservable<T> observable);
  void endUpdate<T>(IObservable<T> observable);
  void handlePossibleChange<T>(IObservable<T> observable);
  void handleChange<T, TChange>(IObservableWithChange<T, TChange> observable, TChange change);
}

/// 1:1: `interface IReader`
abstract class IReader {
  T readObservable<T>(IObservableWithChange<T, Object?> observable);
}

/// 1:1: `interface ISettable<T, TChange = void>`
abstract class ISettable<T, TChange> {
  void set(T value, ITransaction? transaction, TChange change);
}

/// 1:1: `interface ITransaction`
abstract class ITransaction {
  void updateObserver(IObserver observer, IObservableWithChange<Object?, Object?> observable);
}

/// 1:1: `function handleBugIndicatingErrorRecovery(message: string)`
void handleBugIndicatingErrorRecovery(String message) {
  final err = StateError('BugIndicatingErrorRecovery: ' + message);
  onUnexpectedError(err);
  consoleError('recovered from an error that indicates a bug', err);
}

/// 1:1: `interface ISettableObservable<T, TChange = void>`
abstract class ISettableObservable<T, TChange>
    implements IObservableWithChange<T, TChange>, ISettable<T, TChange> {}

/// 1:1: `interface IReaderWithStore extends IReader`
abstract class IReaderWithStore implements IReader {
  Object get store;
  Object get delayedStore;
}
