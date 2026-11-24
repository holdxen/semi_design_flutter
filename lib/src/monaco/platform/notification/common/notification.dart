// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/notification/common/notification.ts
// Translated 1:1. TypeScript `enum` -> Dart `enum`. Interfaces -> abstract
// classes (a `Type` suffix disambiguates const/interface name collisions).
// `Event.None` -> `eventNone`. Runtime truth: tool/ts2dart/_batch152_truth.cjs.
// ---------------------------------------------------------------------------

import '../../../base/common/actions.dart' show IAction;
import '../../../base/common/event.dart' show Event, eventNone;
import '../../../base/common/severity.dart' show Severity;
import '../../../nls.dart' show localize;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import './notificationLegacy.dart' show LegacyExtensionLinkParsing;
import './notificationTelemetry.dart' show NotificationTelemetry;

/// 1:1: `export const INotificationService = createDecorator(...)`.
final ServiceIdentifier<INotificationServiceType> INotificationService =
    createDecorator<INotificationServiceType>('notificationService');

/// 1:1: `export type NotificationMessage = string | Error | NotificationText`.
typedef NotificationMessage = Object;

/// 1:1: `export enum NotificationPriority`.
enum NotificationPriority {
  DEFAULT,
  OPTIONAL,
  SILENT,
  URGENT,
}

/// 1:1: `export interface INotificationProperties`.
abstract class INotificationProperties {
  NotificationTelemetry? get telemetry;
  LegacyExtensionLinkParsing? get legacyExtensionLinkParsing;
  bool? get sticky;
  NotificationPriority? get priority;
  INeverShowAgainOptions? get neverShowAgain;
}

/// 1:1: `export enum NeverShowAgainScope`.
enum NeverShowAgainScope {
  WORKSPACE,
  PROFILE,
  APPLICATION,
}

/// 1:1: `export interface INeverShowAgainOptions`.
class INeverShowAgainOptions {
  INeverShowAgainOptions({
    required this.id,
    this.isSecondary,
    this.scope,
  });
  final String id;
  final bool? isSecondary;
  final NeverShowAgainScope? scope;
}

/// 1:1: `export interface INotificationSource`.
class INotificationSource {
  INotificationSource({required this.id, required this.label});
  final String id;
  final String label;
}

/// 1:1: `export function isNotificationSource`.
bool isNotificationSource(Object? thing) {
  if (thing != null) {
    final Object? id;
    final Object? label;
    if (thing is Map) {
      id = thing['id'];
      label = thing['label'];
    } else if (thing is INotificationSource) {
      id = thing.id;
      label = thing.label;
    } else {
      return false;
    }
    return id is String && label is String;
  }
  return false;
}

/// 1:1: `export interface INotification extends INotificationProperties`.
abstract class INotification implements INotificationProperties {
  Object? get message; // NotificationMessage
  String? get source;
  int? get severity;
  INotificationActions? get actions;
}

/// 1:1: `export interface INotificationActions`.
class INotificationActions {
  INotificationActions({this.primary, this.secondary});
  final List<IAction>? primary;
  final List<IAction>? secondary;
}

/// 1:1: `export interface INotificationProgressProperties`.
abstract class INotificationProgressProperties {
  Object? get message;
  int? get severity;
  INotificationActions? get actions;
}

/// 1:1: `export interface INotificationProgress`.
abstract class INotificationProgress {
  void infinite();
  void done();
  void total(num value);
  void worked(num value);
}

/// 1:1: `export interface INotificationHandle`.
abstract class INotificationHandle {
  INotificationProgress get progress;
  Event<void> get onDidClose;
  Event<void> get onDidChangeVisibility;
  void updateSeverity(int severity);
  void updateMessage(Object message);
  void updateActions([INotificationActions? actions]);
  void close();
}

/// 1:1: `export interface IStatusHandle`.
abstract class IStatusHandle {
  void close();
}

/// 1:1: `export interface IBasePromptChoice`.
abstract class IBasePromptChoice {
  String get label;
  IAction? get action;
  bool? get keepOpen;
  int? get runArgs;
}

/// 1:1: `export interface IPromptChoice extends IBasePromptChoice`.
abstract class IPromptChoice implements IBasePromptChoice {}

/// 1:1: `export interface IPromptChoiceWithMenu extends IPromptChoice`.
abstract class IPromptChoiceWithMenu implements IPromptChoice {
  String get menuLabel;
  bool get isMulti;
  List<IPromptChoice> get menu;
}

/// 1:1: `export interface IPromptOptions extends INotificationProperties`.
abstract class IPromptOptions implements INotificationProperties {
  bool? get cancel;
  String? get placeholder;
  Object? get icon;
}

/// 1:1: `export interface IStatusMessageOptions`.
class IStatusMessageOptions {
  IStatusMessageOptions({this.hideAfter});
  final num? hideAfter;
}

/// 1:1: `export enum NotificationsFilter`.
enum NotificationsFilter {
  OFF,
  ERROR,
}

/// 1:1: `export interface INotificationSourceFilter extends INotificationSource`.
class INotificationSourceFilter extends INotificationSource {
  INotificationSourceFilter({
    required super.id,
    required super.label,
    required this.filter,
  });
  final NotificationsFilter filter;
}

/// 1:1: `export interface INotificationService` (Type-suffixed).
abstract class INotificationServiceType {
  Event<void> get onDidChangeFilter;
  void setFilter(Object filter); // NotificationsFilter | INotificationSourceFilter
  NotificationsFilter getFilter([INotificationSource? source]);
  List<INotificationSourceFilter> getFilters();
  void removeFilter(String sourceId);
  INotificationHandle notify(INotification notification);
  void info(Object message);
  void warn(Object message);
  void error(Object message);
  INotificationHandle prompt(
    int severity,
    Object message,
    List<Object> choices, [
    IPromptOptions? options,
  ]);
  IStatusHandle status(Object message, [IStatusMessageOptions? options]);
}

/// 1:1: `export class NoOpNotification implements INotificationHandle`.
class NoOpNotification implements INotificationHandle {
  @override
  final INotificationProgress progress = NoOpProgress();

  @override
  Event<void> get onDidClose => eventNone;
  @override
  Event<void> get onDidChangeVisibility => eventNone;

  @override
  void updateSeverity(int severity) {}
  @override
  void updateMessage(Object message) {}
  @override
  void updateActions([INotificationActions? actions]) {}
  @override
  void close() {}
}

/// 1:1: `export class NoOpProgress implements INotificationProgress`.
class NoOpProgress implements INotificationProgress {
  @override
  void infinite() {}
  @override
  void done() {}
  @override
  void total(num value) {}
  @override
  void worked(num value) {}
}

/// 1:1: `export function withSeverityPrefix`.
String withSeverityPrefix(String label, int severity) {
  if (severity == Severity.Error) {
    return localize('severityPrefix.error', 'Error: {0}', <Object>[label]);
  }
  if (severity == Severity.Warning) {
    return localize('severityPrefix.warning', 'Warning: {0}', <Object>[label]);
  }
  return localize('severityPrefix.info', 'Info: {0}', <Object>[label]);
}
