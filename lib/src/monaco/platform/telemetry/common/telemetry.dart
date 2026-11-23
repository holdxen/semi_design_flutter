// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/telemetry/common/telemetry.ts
// Translated 1:1 from TypeScript. TS value/type namespace clashes
// (ITelemetryService, ICustomEndpointTelemetryService) -> const keeps the name,
// interface gets the `Type` suffix. const enums -> class of consts. GDPR
// type-level generics -> Object? carriers (no runtime logic in TS either).
// ---------------------------------------------------------------------------

import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
// GDPR type-only generics (ClassifiedEvent/IGDPRProperty/OmitMetadata/
// StrictPropertyCheck from gdprTypings.dart) have no Dart runtime analogue;
// their data parameters are carried as Object? exactly as in the TS.

/// 1:1: `export const ITelemetryService = createDecorator<ITelemetryService>('telemetryService')`
final ServiceIdentifier<ITelemetryServiceType> ITelemetryService =
    createDecorator<ITelemetryServiceType>('telemetryService');

/// 1:1: `export interface ITelemetryData`
abstract class ITelemetryData {
  String? get from;
  String? get target;
}

/// 1:1: `export interface ITelemetryService`
abstract class ITelemetryServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  int get telemetryLevel;
  String get sessionId;
  String get machineId;
  String get sqmId;
  String get devDeviceId;
  String get firstSessionDate;
  bool? get msftInternal;

  /// Whether error telemetry will get sent. If false, `publicLogError` will no-op.
  bool get sendErrorTelemetry;

  /// @deprecated Use publicLog2 and the typescript GDPR annotation where possible
  void publicLog(String eventName, [ITelemetryData? data]);

  /// Sends a telemetry event that has been privacy approved.
  void publicLog2(String eventName, [Object? data]);

  /// @deprecated Use publicLogError2 and the typescript GDPR annotation where possible
  void publicLogError(String errorEventName, [ITelemetryData? data]);
  void publicLogError2(String errorEventName, [Object? data]);

  void setExperimentProperty(String name, String value);

  /// Sets a common property attached to all telemetry events.
  void setCommonProperty(String name, Object? value);
}

/// 1:1: `export function telemetryLevelEnabled(service, level): boolean`
bool telemetryLevelEnabled(ITelemetryServiceType service, int level) =>
    service.telemetryLevel >= level;

/// 1:1: `export const MODEL_ROUTER_TELEMETRY_ID = 'modelRouter'`
const String MODEL_ROUTER_TELEMETRY_ID = 'modelRouter';

/// 1:1: `normalizeModelRouterTelemetryId<T>(modelId: T): T | typeof MODEL_ROUTER_TELEMETRY_ID`
/// JS `modelId?.includes(...)` -> Dart null-aware; string carrier for `T`.
Object? normalizeModelRouterTelemetryId(Object? modelId) {
  if (modelId is String && modelId.contains('model-router:')) {
    return MODEL_ROUTER_TELEMETRY_ID;
  }
  return modelId;
}

/// 1:1: `escapeModelIdForTelemetry(modelId): string | undefined`
/// Replaces `/` and `\` with `|`; chained optional call so null/undefined -> null.
String? escapeModelIdForTelemetry(Object? modelId) {
  final normalized = normalizeModelRouterTelemetryId(modelId);
  if (normalized == null) return null;
  return normalized.toString().replaceAll(RegExp(r'[\\/]'), '|');
}

/// 1:1: `export interface ITelemetryEndpoint`
abstract class ITelemetryEndpoint {
  String get id;
  String get aiKey;
  bool get sendErrorTelemetry;
}

/// 1:1: `export const ICustomEndpointTelemetryService = createDecorator(...)`
final ServiceIdentifier<ICustomEndpointTelemetryServiceType>
    ICustomEndpointTelemetryService =
    createDecorator<ICustomEndpointTelemetryServiceType>(
        'customEndpointTelemetryService');

/// 1:1: `export interface ICustomEndpointTelemetryService`
abstract class ICustomEndpointTelemetryServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;
  void publicLog(ITelemetryEndpoint endpoint, String eventName,
      [ITelemetryData? data]);
  void publicLogError(ITelemetryEndpoint endpoint, String errorEventName,
      [ITelemetryData? data]);
}

// Keys
const String currentSessionDateStorageKey = 'telemetry.currentSessionDate';
const String firstSessionDateStorageKey = 'telemetry.firstSessionDate';
const String lastSessionDateStorageKey = 'telemetry.lastSessionDate';
const String machineIdKey = 'telemetry.machineId';
const String sqmIdKey = 'telemetry.sqmId';
const String devDeviceIdKey = 'telemetry.devDeviceId';

// Configuration Keys
const String TELEMETRY_SECTION_ID = 'telemetry';
const String TELEMETRY_SETTING_ID = 'telemetry.telemetryLevel';
const String TELEMETRY_CRASH_REPORTER_SETTING_ID =
    'telemetry.enableCrashReporter';
const String TELEMETRY_OLD_SETTING_ID = 'telemetry.enableTelemetry';

/// 1:1: `export const enum TelemetryLevel`
class TelemetryLevel {
  static const int NONE = 0;
  static const int CRASH = 1;
  static const int ERROR = 2;
  static const int USAGE = 3;
  const TelemetryLevel._();
}

/// 1:1: `export const enum TelemetryConfiguration`
class TelemetryConfiguration {
  static const String OFF = 'off';
  static const String CRASH = 'crash';
  static const String ERROR = 'error';
  static const String ON = 'all';
  const TelemetryConfiguration._();
}

/// 1:1: `export interface ICommonProperties`
abstract class ICommonProperties {
  Object? operator [](String key);
}
