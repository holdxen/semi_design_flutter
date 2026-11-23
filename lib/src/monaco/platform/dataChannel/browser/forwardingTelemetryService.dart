// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/dataChannel/browser/forwardingTelemetryService.ts
// Translated 1:1 from TypeScript.
//   - `@ITelemetryService` / `@IDataChannelService` DI decorators -> explicit
//     service-type constructor params.
//   - `shouldForwardToChannel` is a Symbol-keyed marker on an object; carried
//     as a `Map<Object?, Object?>` with the same Symbol key.
//   - TS GDPR generic type parameters (`ClassifiedEvent`, `OmitMetadata`, ...)
//     are compile-time only; Dart uses Object? for the data payloads.
// ---------------------------------------------------------------------------

import '../common/dataChannel.dart' show IDataChannelServiceType;
import '../../telemetry/common/telemetry.dart'
    show ITelemetryData, ITelemetryServiceType;

/// 1:1: `export interface IEditTelemetryData`
class IEditTelemetryData {
  final String eventName;
  final Map<String, Object?> data;
  IEditTelemetryData(this.eventName, this.data);
}

/// 1:1: `export class InterceptingTelemetryService implements ITelemetryService`
class InterceptingTelemetryService implements ITelemetryServiceType {
  final ITelemetryServiceType _baseService;
  final void Function(String eventName, Object? data) _intercept;

  InterceptingTelemetryService(this._baseService, this._intercept);

  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  int get telemetryLevel => _baseService.telemetryLevel;
  @override
  String get sessionId => _baseService.sessionId;
  @override
  String get machineId => _baseService.machineId;
  @override
  String get sqmId => _baseService.sqmId;
  @override
  String get devDeviceId => _baseService.devDeviceId;
  @override
  String get firstSessionDate => _baseService.firstSessionDate;
  @override
  bool? get msftInternal => _baseService.msftInternal;
  @override
  bool get sendErrorTelemetry => _baseService.sendErrorTelemetry;

  @override
  void publicLog(String eventName, [ITelemetryData? data]) {
    _intercept(eventName, data);
    _baseService.publicLog(eventName, data);
  }

  @override
  void publicLog2(String eventName, [Object? data]) {
    _intercept(eventName, data);
    _baseService.publicLog2(eventName, data);
  }

  @override
  void publicLogError(String errorEventName, [ITelemetryData? data]) {
    _intercept(errorEventName, data);
    _baseService.publicLogError(errorEventName, data);
  }

  @override
  void publicLogError2(String errorEventName, [Object? data]) {
    _intercept(errorEventName, data);
    _baseService.publicLogError2(errorEventName, data);
  }

  @override
  void setExperimentProperty(String name, String value) {
    _baseService.setExperimentProperty(name, value);
  }

  @override
  void setCommonProperty(String name, Object? value) {
    _baseService.setCommonProperty(name, value);
  }
}

/// 1:1: `const shouldForwardToChannel = Symbol('shouldForwardToChannel')`
final Symbol shouldForwardToChannel = const Symbol('shouldForwardToChannel');

/// 1:1: `export class DataChannelForwardingTelemetryService extends InterceptingTelemetryService`
class DataChannelForwardingTelemetryService
    extends InterceptingTelemetryService {
  DataChannelForwardingTelemetryService(
    ITelemetryServiceType telemetryService,
    IDataChannelServiceType dataChannelService,
  ) : super(telemetryService, (eventName, data) {
          // filter for extension
          bool forward = true;
          if (data is Map && data.containsKey(shouldForwardToChannel)) {
            // TS: `Boolean(data[shouldForwardToChannel])` (JS truthiness).
            final Object? marker = data[shouldForwardToChannel];
            forward = marker == true;
          }

          if (forward) {
            dataChannelService
                .getDataChannel<IEditTelemetryData>('editTelemetry')
                .sendData(IEditTelemetryData(
                    eventName, data == null ? <String, Object?>{} : _asMap(data)));
          }
        });

  static Map<String, Object?> _asMap(Object data) =>
      data is Map<String, Object?> ? data : <String, Object?>{};
}

/// 1:1: `export function forwardToChannelIf(value: boolean): Record<string, unknown>`
/// Returns a Map carrier with the Symbol marker key (JSON-invisible in TS).
Map<Object?, Object?> forwardToChannelIf(bool value) =>
    <Object?, Object?>{shouldForwardToChannel: value};

/// 1:1: `export function isCopilotLikeExtension(extensionId: string | undefined): boolean`
bool isCopilotLikeExtension(String? extensionId) {
  if (extensionId == null || extensionId.isEmpty) {
    return false;
  }
  final String extIdLowerCase = extensionId.toLowerCase();
  return extIdLowerCase == 'github.copilot' ||
      extIdLowerCase == 'github.copilot-chat';
}
