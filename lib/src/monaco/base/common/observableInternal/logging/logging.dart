// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/logging/logging.ts
// Translated 1:1. Type-only imports (AutorunObserver, Derived, TransactionImpl)
// are `Object?` carriers; DebugLocation is the existing port.
// ---------------------------------------------------------------------------

import '../debugLocation.dart' show DebugLocation;
import '../base.dart' show IObservableWithChange;

/// 1:1: `export interface IChangeInformation`
class IChangeInformation {
  IChangeInformation({
    required this.oldValue,
    required this.newValue,
    required this.change,
    required this.didChange,
    required this.hadValue,
  });
  final Object? oldValue;
  final Object? newValue;
  final Object? change;
  final bool didChange;
  final bool hadValue;
}

/// 1:1: `export interface IObservableLogger`
/// Arguments that are type-only imports in TS are [Object?] carriers here.
abstract class IObservableLogger {
  void handleObservableCreated(IObservableWithChange<Object?, Object?> observable, DebugLocation? location);
  void handleOnListenerCountChanged(IObservableWithChange<Object?, Object?> observable, int newCount);
  void handleObservableUpdated(IObservableWithChange<Object?, Object?> observable, IChangeInformation info);
  void handleAutorunCreated(Object autorun, DebugLocation? location);
  void handleAutorunDisposed(Object autorun);
  void handleAutorunDependencyChanged(Object autorun, IObservableWithChange<Object?, Object?> observable, Object? change);
  void handleAutorunStarted(Object autorun);
  void handleAutorunFinished(Object autorun);
  void handleDerivedDependencyChanged(Object derived, IObservableWithChange<Object?, Object?> observable, Object? change);
  void handleDerivedCleared(Object observable);
  void handleBeginTransaction(Object transaction);
  void handleEndTransaction(Object transaction);
}

/// 1:1: `class ComposedLogger implements IObservableLogger` — fans every call
/// out to each child logger in order.
class ComposedLogger implements IObservableLogger {
  ComposedLogger(this.loggers);

  final List<IObservableLogger> loggers;

  @override
  void handleObservableCreated(IObservableWithChange<Object?, Object?> observable, DebugLocation? location) {
    for (final l in loggers) { l.handleObservableCreated(observable, location); }
  }
  @override
  void handleOnListenerCountChanged(IObservableWithChange<Object?, Object?> observable, int newCount) {
    for (final l in loggers) { l.handleOnListenerCountChanged(observable, newCount); }
  }
  @override
  void handleObservableUpdated(IObservableWithChange<Object?, Object?> observable, IChangeInformation info) {
    for (final l in loggers) { l.handleObservableUpdated(observable, info); }
  }
  @override
  void handleAutorunCreated(Object autorun, DebugLocation? location) {
    for (final l in loggers) { l.handleAutorunCreated(autorun, location); }
  }
  @override
  void handleAutorunDisposed(Object autorun) {
    for (final l in loggers) { l.handleAutorunDisposed(autorun); }
  }
  @override
  void handleAutorunDependencyChanged(Object autorun, IObservableWithChange<Object?, Object?> observable, Object? change) {
    for (final l in loggers) { l.handleAutorunDependencyChanged(autorun, observable, change); }
  }
  @override
  void handleAutorunStarted(Object autorun) {
    for (final l in loggers) { l.handleAutorunStarted(autorun); }
  }
  @override
  void handleAutorunFinished(Object autorun) {
    for (final l in loggers) { l.handleAutorunFinished(autorun); }
  }
  @override
  void handleDerivedDependencyChanged(Object derived, IObservableWithChange<Object?, Object?> observable, Object? change) {
    for (final l in loggers) { l.handleDerivedDependencyChanged(derived, observable, change); }
  }
  @override
  void handleDerivedCleared(Object observable) {
    for (final l in loggers) { l.handleDerivedCleared(observable); }
  }
  @override
  void handleBeginTransaction(Object transaction) {
    for (final l in loggers) { l.handleBeginTransaction(transaction); }
  }
  @override
  void handleEndTransaction(Object transaction) {
    for (final l in loggers) { l.handleEndTransaction(transaction); }
  }
}

/// 1:1: `let globalObservableLogger: IObservableLogger | undefined`
IObservableLogger? globalObservableLogger;

/// 1:1: `export function addLogger(logger)`
void addLogger(IObservableLogger logger) {
  final current = globalObservableLogger;
  if (current == null) {
    globalObservableLogger = logger;
  } else if (current is ComposedLogger) {
    current.loggers.add(logger);
  } else {
    globalObservableLogger = ComposedLogger(<IObservableLogger>[current, logger]);
  }
}

/// 1:1: `export function getLogger()`
IObservableLogger? getLogger() => globalObservableLogger;

/// 1:1: `let globalObservableLoggerFn`
void Function(IObservableWithChange<Object?, Object?> observable)? globalObservableLoggerFn;

/// 1:1: `export function setLogObservableFn(fn)`
void setLogObservableFn(void Function(IObservableWithChange<Object?, Object?> observable) fn) {
  globalObservableLoggerFn = fn;
}

/// 1:1: `export function logObservable(obs)`
void logObservable(IObservableWithChange<Object?, Object?> obs) {
  globalObservableLoggerFn?.call(obs);
}
