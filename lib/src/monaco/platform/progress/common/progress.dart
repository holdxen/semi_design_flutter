// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/progress/common/progress.ts
// Translated 1:1. `const enum` -> class of static const ints. Interfaces ->
// abstract classes (a `Type` suffix disambiguates const/interface collisions).
// `Object.freeze` -> immutable final instances. Runtime truth:
// tool/ts2dart/_batch154_truth.cjs (real transpiled source).
// ---------------------------------------------------------------------------

import 'dart:async' show Future, Timer;

import '../../../base/common/async.dart' show DeferredPromise;
import '../../../base/common/cancellation.dart'
    show CancellationToken, CancellationTokenSource;
import '../../../base/common/lifecycle.dart'
    show Disposable, DisposableStore, toDisposable;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../notification/common/notificationLegacy.dart'
    show LegacyExtensionLinkParsing;
import '../../notification/common/notificationTelemetry.dart'
    show NotificationTelemetry;

/// 1:1: `export const IProgressService = createDecorator(...)`.
final ServiceIdentifier<IProgressServiceType> IProgressService =
    createDecorator<IProgressServiceType>('progressService');

/// 1:1: `export interface IProgressService` (Type-suffixed).
abstract class IProgressServiceType {
  Future<R> withProgress<R>(
    Object options,
    Future<R> Function(IProgress<IProgressStep> progress) task, [
    void Function([int? choice])? onDidCancel,
  ]);
}

/// 1:1: `export interface IProgressIndicator`.
abstract class IProgressIndicator {
  IProgressRunner show(Object infiniteOrTotal, [num? delay]);
  Future<void> showWhile(Future<Object?> promise, [num? delay]);
}

/// 1:1: `export const enum ProgressLocation`.
class ProgressLocation {
  static const int Explorer = 1;
  static const int Scm = 3;
  static const int Extensions = 5;
  static const int Window = 10;
  static const int Notification = 15;
  static const int Dialog = 20;
}

/// 1:1: `export interface IProgressOptions`.
class IProgressOptions {
  IProgressOptions({
    required this.location,
    this.title,
    this.source,
    this.total,
    this.cancellable,
    this.telemetry,
    this.legacyExtensionLinkParsing,
  });
  final Object location; // ProgressLocation | INotificationSource
  final String? title;
  final String? source;
  final num? total;
  final bool? cancellable;
  final NotificationTelemetry? telemetry;
  final LegacyExtensionLinkParsing? legacyExtensionLinkParsing;
}

/// 1:1: `export interface IProgressNotificationOptions extends IProgressOptions`.
class IProgressNotificationOptions extends IProgressOptions {
  IProgressNotificationOptions({
    required super.location,
    this.partial,
    super.title,
    super.source,
    super.total,
    super.cancellable,
    super.telemetry,
    super.legacyExtensionLinkParsing,
  });
  final bool? partial;
}

/// 1:1: `export interface IProgressDialogOptions extends IProgressOptions`.
class IProgressDialogOptions extends IProgressOptions {
  IProgressDialogOptions({
    required super.location,
    this.detail,
    super.title,
    super.source,
    super.total,
    super.cancellable,
    super.telemetry,
    super.legacyExtensionLinkParsing,
  });
  final String? detail;
}

/// 1:1: `export interface IProgressWindowOptions extends IProgressOptions`.
class IProgressWindowOptions extends IProgressOptions {
  IProgressWindowOptions({
    required super.location,
    this.detail,
    super.title,
    super.source,
    super.total,
    super.cancellable,
    super.telemetry,
    super.legacyExtensionLinkParsing,
  });
  final String? detail;
}

/// 1:1: `export interface IProgressCompositeOptions extends IProgressOptions`.
class IProgressCompositeOptions extends IProgressOptions {
  IProgressCompositeOptions({
    required super.location,
    this.sticky,
    super.title,
    super.source,
    super.total,
    super.cancellable,
    super.telemetry,
    super.legacyExtensionLinkParsing,
  });
  final bool? sticky;
}

/// 1:1: `export interface IProgressStep`.
class IProgressStep {
  IProgressStep({this.message, this.increment, this.total});
  final Object? message; // string | NotificationText
  final num? increment;
  final num? total;
}

/// 1:1: `export interface IProgressRunner`.
abstract class IProgressRunner {
  void total(num value);
  void worked(num value);
  void done();
}

/// 1:1: `export const emptyProgressRunner = Object.freeze<IProgressRunner>(...)`.
final IProgressRunner emptyProgressRunner = _EmptyProgressRunner();

class _EmptyProgressRunner implements IProgressRunner {
  @override
  void total(num value) {}
  @override
  void worked(num value) {}
  @override
  void done() {}
}

/// 1:1: `export interface IProgress<T>`.
abstract class IProgress<T> {
  void report(T item);
}

/// 1:1: `export class Progress<T> implements IProgress<T>`.
class Progress<T> implements IProgress<T> {
  Progress(this._callback);

  final void Function(T data) _callback;
  T? _value;
  T? get value => _value;

  /// 1:1: `static readonly None = Object.freeze<IProgress<unknown>>({report(){}})`.
  static final IProgress<Object?> None = _NoneProgress();

  @override
  void report(T item) {
    _value = item;
    _callback(_value as T);
  }
}

class _NoneProgress implements IProgress<Object?> {
  @override
  void report(Object? item) {}
}

/// 1:1: `export interface IOperation`.
class IOperation {
  IOperation({
    required this.id,
    required this.isCurrent,
    required this.token,
    required this.stop,
  });
  final int id;
  final bool Function() isCurrent;
  final CancellationToken token;
  final void Function() stop;
}

/// 1:1: `export class UnmanagedProgress extends Disposable`.
class UnmanagedProgress extends Disposable {
  UnmanagedProgress(Object options, IProgressServiceType progressService)
      : super() {
    final DeferredPromise<void> deferred = DeferredPromise<void>();
    progressService.withProgress<void>(options, (IProgress<IProgressStep> reporter) {
      _reporter = reporter;
      final IProgressStep? last = _lastStep;
      if (last != null) {
        reporter.report(last);
      }
      return deferred.p;
    });
    // 1:1: `this._register(toDisposable(() => this.deferred.complete()))`.
    register(toDisposable(() => deferred.complete(null)));
  }

  IProgress<IProgressStep>? _reporter;
  IProgressStep? _lastStep;

  /// 1:1: `report(step)`.
  void report(IProgressStep step) {
    final IProgress<IProgressStep>? reporter = _reporter;
    if (reporter != null) {
      reporter.report(step);
    } else {
      _lastStep = step;
    }
  }
}

/// 1:1: `export class LongRunningOperation extends Disposable`.
class LongRunningOperation extends Disposable {
  LongRunningOperation(this._progressIndicator) : super();

  final IProgressIndicator _progressIndicator;
  int _currentOperationId = 0;
  final DisposableStore _currentOperationDisposables =
      DisposableStore(); // registered below via initializer gate
  IProgressRunner? _currentProgressRunner;
  Timer? _currentProgressTimeout;

  /// Lazily registers the disposables store with the base Disposable once.
  bool _storeRegistered = false;
  DisposableStore get _store {
    if (!_storeRegistered) {
      _storeRegistered = true;
      register(_currentOperationDisposables);
    }
    return _currentOperationDisposables;
  }

  /// 1:1: `start(progressDelay): IOperation`.
  IOperation start(num progressDelay) {
    stop();
    final int newOperationId = ++_currentOperationId;
    final CancellationTokenSource newOperationToken = CancellationTokenSource();
    final DisposableStore store = _store;
    _currentProgressTimeout = Timer(
        Duration(milliseconds: progressDelay.round()), () {
      if (newOperationId == _currentOperationId) {
        _currentProgressRunner = _progressIndicator.show(true);
      }
    });
    store.add(toDisposable(() => _currentProgressTimeout?.cancel()));
    store.add(toDisposable(() => newOperationToken.cancel()));
    store.add(toDisposable(() {
      final IProgressRunner? r = _currentProgressRunner;
      if (r != null) r.done();
    }));
    return IOperation(
      id: newOperationId,
      token: newOperationToken.token,
      stop: () => _doStop(newOperationId),
      isCurrent: () => _currentOperationId == newOperationId,
    );
  }

  /// 1:1: `stop()`.
  void stop() {
    _doStop(_currentOperationId);
  }

  void _doStop(int operationId) {
    if (_currentOperationId == operationId) {
      _store.clear();
    }
  }
}

/// 1:1: `export const IEditorProgressService = createDecorator(...)`.
final ServiceIdentifier<IEditorProgressServiceType> IEditorProgressService =
    createDecorator<IEditorProgressServiceType>('editorProgressService');

/// 1:1: `export interface IEditorProgressService extends IProgressIndicator`.
abstract class IEditorProgressServiceType implements IProgressIndicator {}
