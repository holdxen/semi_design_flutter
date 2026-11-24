// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/notification/test/common/testNotificationService.ts
// Translated 1:1. Implements the real INotificationServiceType interface.
// Runtime truth: tool/ts2dart/_batch153_truth.cjs (real transpiled source).
// ---------------------------------------------------------------------------

import '../../../../base/common/event.dart' show Event, eventNone;
import '../../../../base/common/severity.dart' show Severity;
import '../../common/notification.dart'
    show
        INotification,
        INotificationActions,
        INotificationHandle,
        INotificationServiceType,
        INotificationSource,
        INotificationSourceFilter,
        INeverShowAgainOptions,
        IPromptOptions,
        IStatusHandle,
        IStatusMessageOptions,
        NoOpNotification,
        NotificationPriority,
        NotificationsFilter;
import '../../common/notificationTelemetry.dart' show NotificationTelemetry;

/// 1:1: `export class TestNotificationService implements INotificationService`.
class TestNotificationService implements INotificationServiceType {
  @override
  Event<void> get onDidChangeFilter => eventNone;

  /// 1:1: `declare readonly _serviceBrand: undefined`.
  // ignore: unused_element
  Object? get _serviceBrand => null;

  /// 1:1: `private static readonly NO_OP: INotificationHandle = new NoOpNotification()`.
  static final INotificationHandle _NO_OP = NoOpNotification();

  @override
  INotificationHandle info(Object message) {
    return notify(_CarrierNotification(Severity.Info, message));
  }

  @override
  INotificationHandle warn(Object message) {
    return notify(_CarrierNotification(Severity.Warning, message));
  }

  @override
  INotificationHandle error(Object error) {
    return notify(_CarrierNotification(Severity.Error, error));
  }

  @override
  INotificationHandle notify(INotification notification) {
    return _NO_OP;
  }

  @override
  INotificationHandle prompt(
    int severity,
    Object message,
    List<Object> choices, [
    IPromptOptions? options,
  ]) {
    return _NO_OP;
  }

  @override
  IStatusHandle status(Object message, [IStatusMessageOptions? options]) {
    return _NoOpStatusHandle();
  }

  @override
  void setFilter(Object filter) {}

  @override
  NotificationsFilter getFilter([INotificationSource? source]) {
    return NotificationsFilter.OFF;
  }

  @override
  List<INotificationSourceFilter> getFilters() {
    return <INotificationSourceFilter>[];
  }

  @override
  void removeFilter(String sourceId) {}
}

/// 1:1 carrier of the object literal `{ severity, message }` passed by
/// info/warn/error to `notify`. Implements the real [INotification] interface.
class _CarrierNotification implements INotification {
  _CarrierNotification(this.severity, this.message);
  @override
  final int severity;
  @override
  final Object message;
  @override
  String? get source => null;
  @override
  INotificationActions? get actions => null;
  @override
  NotificationTelemetry? get telemetry => null;
  @override
  Object? get legacyExtensionLinkParsing => null;
  @override
  bool? get sticky => null;
  @override
  NotificationPriority? get priority => null;
  @override
  INeverShowAgainOptions? get neverShowAgain => null;
}

/// 1:1: `status()` returns `{ close: () => {} }`.
class _NoOpStatusHandle implements IStatusHandle {
  @override
  void close() {}
}
