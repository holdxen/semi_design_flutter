// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/environment/common/environment.ts
// Translated 1:1 from TypeScript. Pure ambient declarations (interfaces +
// decorators + type aliases). TS value/type namespace clashes
// (IEnvironmentService / INativeEnvironmentService) -> const keeps the name,
// interface gets the `Type` suffix. String-literal unions -> String typedef;
// `boolean | string[]` -> Object? carrier. `break` (Dart keyword) -> `break_()`.
// ---------------------------------------------------------------------------

import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator, refineServiceDecorator;
import 'argv.dart' show NativeParsedArgs;

/// 1:1: `export const IEnvironmentService = createDecorator<IEnvironmentService>('environmentService')`
final ServiceIdentifier<IEnvironmentServiceType> IEnvironmentService =
    createDecorator<IEnvironmentServiceType>('environmentService');

/// 1:1: `export const INativeEnvironmentService = refineServiceDecorator<IEnvironmentService, INativeEnvironmentService>(IEnvironmentService)`
/// Dart generics are invariant (variance annotations are still experimental),
/// so the phantom `T` stays at the base type. TS `refineServiceDecorator` is
/// an identity return, so the runtime object and serviceId are unchanged.
final ServiceIdentifier<IEnvironmentServiceType> INativeEnvironmentService =
    refineServiceDecorator<IEnvironmentServiceType, IEnvironmentServiceType>(
        IEnvironmentService);

/// 1:1: `export interface IDebugParams`
abstract class IDebugParams {
  num? get port;

  /// 1:1: `break: boolean` — Dart keyword, suffixed with `_`.
  bool get break_;
}

/// 1:1: `export interface IExtensionHostDebugParams extends IDebugParams`
abstract class IExtensionHostDebugParams implements IDebugParams {
  @override
  num? get port;

  @override
  bool get break_;

  String? get debugId;
  Map<String, String>? get env;
}

/// 1:1: `export type ExtensionKind = 'ui' | 'workspace' | 'web'`
typedef ExtensionKind = String;

/// 1:1: `export interface IEnvironmentService`
abstract class IEnvironmentServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  // --- user roaming data
  URI get stateResource;
  URI get userRoamingDataHome;
  URI get keyboardLayoutResource;
  URI get argvResource;

  // --- data paths
  URI get untitledWorkspacesHome;
  URI get workspaceStorageHome;
  URI get localHistoryHome;
  URI get cacheHome;
  URI get appSharedDataHome;

  // --- settings sync
  URI get userDataSyncHome;
  String? get sync;

  // --- continue edit session
  String? get continueOn;
  String? get editSessionId;

  // --- extension development
  IExtensionHostDebugParams get debugExtensionHost;
  bool get isExtensionDevelopment;

  /// TS `boolean | string[]` -> Object? carrier.
  Object? get disableExtensions;
  List<String>? get skipBuiltinExtensions;
  List<String>? get enableExtensions;
  List<URI>? get extensionDevelopmentLocationURI;
  List<ExtensionKind>? get extensionDevelopmentKind;
  URI? get extensionTestsLocationURI;

  // --- logging
  URI get logsHome;
  String? get logLevel;
  List<List<String>>? get extensionLogLevel;
  bool get verbose;
  bool get isBuilt;

  // --- telemetry/exp
  bool get disableTelemetry;
  bool get disableExperiments;
  URI get serviceMachineIdResource;

  // --- agent sessions workspace
  URI get agentSessionsWorkspace;

  // --- Policy
  URI? get policyFile;
}

/// 1:1: `export interface INativeEnvironmentService extends IEnvironmentService`
abstract class INativeEnvironmentServiceType implements IEnvironmentServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand;

  // --- CLI Arguments
  NativeParsedArgs get args;

  // --- data paths
  /// Root path of the JavaScript sources.
  String get appRoot;
  String get appBundleRoot;
  URI get userHome;
  URI get appSettingsHome;
  URI get tmpDir;
  String get userDataPath;

  // --- extensions
  String get extensionsPath;
  URI get extensionsDownloadLocation;
  String get builtinExtensionsPath;

  // --- use in-memory Secret Storage
  bool? get useInMemorySecretStorage;

  bool? get crossOriginIsolated;
  String? get exportPolicyData;
  String? get exportDefaultKeybindings;
}
