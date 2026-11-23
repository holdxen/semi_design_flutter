// 1:1 port of vs/platform/policy/common/copilotManagedSettings.ts
// Truth driven by tool/ts2dart/_batch90_truth.cjs (real TS modules via vm).
// Mapping notes:
//   - type-only imports erased; `ManagedSettingValue/ManagedSettingsData` come
//     from base/common/policy.dart, `IPolicyData` from base/common/defaultAccount.dart.
//   - `Event.None` -> `eventNone`; `createDecorator<T>` -> ServiceIdentifier<T>.
//   - JS `undefined` is carried as Dart `null`; JS `Object.hasOwn` -> containsKey.
//   - `new URL(value).href` -> Uri.parse + trailing-slash normalization (jsUrlHref).
//   - JS `typeof` / truthiness helpers mirror the runtime where it matters.
import 'dart:convert';

import '../../../base/common/defaultAccount.dart' show IPolicyData;
import '../../../base/common/event.dart' show Event, eventNone;
import '../../../base/common/json.dart' show ParseError, ParseOptions, parse;
import '../../../base/common/managedSettings.dart'
    show
        ExtraKnownMarketplacesConfigDict,
        GithubMarketplaceEntry,
        GithubMarketplaceSource,
        GitMarketplaceEntry,
        GitMarketplaceSource,
        IExtraKnownMarketplaceEntry,
        extraKnownMarketplacesToConfigDict;
import '../../../base/common/policy.dart'
    show
        IManagedSettingPolicyDefinition,
        IManagedSettingsPolicyDefinitions,
        ManagedSettingValue,
        ManagedSettingsData;
import '../../../base/common/types.dart' show isEmptyObject;
import '../../configuration/common/configuration.dart'
    show IConfigurationServiceType;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import 'policy.dart' show PolicyDefinition;

/// 1:1: `export type { ManagedSettingsData } from base/common/policy`
export '../../../base/common/policy.dart' show ManagedSettingsData;

/// 1:1: `export type RawManagedSettingsData = Readonly<Record<string, unknown>>`
typedef RawManagedSettingsData = Map<String, Object?>;

/// Carrier for JS `undefined`, which is distinct from `null`: a present key
/// with `undefined` is dropped by the normalizer, while `null` is encoded as
/// the string `'null'`. Pass this where the TS source passes `undefined`.
final Object jsUndefined = Object();

/// 1:1 JS `typeof` for the value types present in managed settings.
String _jsTypeOf(Object? value) {
  if (value == null) return 'object';
  if (value is String) return 'string';
  if (value is bool) return 'boolean';
  if (value is num) return 'number';
  if (value is Function) return 'function';
  return 'object';
}

bool _isObject(Object? value) => value is Map && value is! List;

/// 1:1 JS `String(value)` for the primitive coercions used by encodeStringMap.
String _jsString(Object? value) {
  if (value is String) return value;
  if (value is bool) return value ? 'true' : 'false';
  if (value is int) return value.toString();
  if (value is double) {
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }
  return '$value';
}

/// `new URL(value).href` for accepted http/https URLs. Dart Uri already
/// lowercases the scheme/host and drops default ports; JS additionally appends
/// a trailing `/` for host-only URLs, which Uri.replace reproduces.
String _jsUrlHref(Uri u) => (u.path.isEmpty ? u.replace(path: '/') : u).toString();

// --- governance helpers ---

/// 1:1: `isManagedSettingInBlock`
bool isManagedSettingInBlock(String key, String block) =>
    key == block || key.startsWith('$block.');

/// 1:1: `export function isManagedSettingGovernanceActive`
bool isManagedSettingGovernanceActive(String key) =>
    !HARNESS_PERMISSION_KEYS.any((control) =>
        isManagedSettingInBlock(key, control)) &&
    !isManagedSettingInBlock(key, _communicationBlockKey);

/// 1:1: `export function hasRawManagedSettings`
bool hasRawManagedSettings(RawManagedSettingsData? data) {
  if (data == null) return false;
  return data.entries.any((entry) {
    final key = entry.key;
    final value = entry.value;
    if (key == _vscodeBlockKey &&
        _isObject(value) &&
        HARNESS_PERMISSION_KEYS.any((control) =>
            (value as Map).containsKey(control.substring(_vscodeBlockKey.length + 1)))) {
      return (value as Map).keys.any((k) =>
          isManagedSettingGovernanceActive('$_vscodeBlockKey.$k'));
    }
    return isManagedSettingGovernanceActive(key);
  });
}

// --- constants (1:1) ---

const String GITHUB_COPILOT_WIN32_REGISTRY_PATH = 'SOFTWARE\\Policies\\GitHubCopilot';
const String GITHUB_COPILOT_WIN32_POLICY_NAME = 'GitHubCopilot';
const String GITHUB_COPILOT_MACOS_BUNDLE_ID = 'com.github.copilot';
const String COPILOT_DISABLE_BYPASS_PERMISSIONS_MODE_KEY =
    'permissions.disableBypassPermissionsMode';
const String COPILOT_DISABLE_ASSISTED_PERMISSIONS_MODE_KEY =
    'permissions.disableAssistedPermissionsMode';
const String COPILOT_DEFAULT_PERMISSIONS_MODE_KEY = 'permissions.defaultMode';
const List<String> COPILOT_PERMISSION_RULES_KEYS = <String>[
  'permissions.ask',
  'permissions.allow',
  'permissions.deny',
];
const String COPILOT_ENABLED_PLUGINS_KEY = 'enabledPlugins';
const String COPILOT_EXTRA_MARKETPLACES_KEY = 'extraKnownMarketplaces';
const String COPILOT_STRICT_MARKETPLACES_KEY = 'strictKnownMarketplaces';
const String COPILOT_ALLOWED_MCP_SERVERS_KEY = 'allowedMcpServers';
const String COPILOT_DENIED_MCP_SERVERS_KEY = 'deniedMcpServers';
const String COPILOT_STRICT_PLUGIN_ONLY_CUSTOMIZATION_KEY =
    'strictPluginOnlyCustomization';
const String COPILOT_ALLOW_MANAGED_MCP_SERVERS_ONLY_KEY =
    'allowManagedMcpServersOnly';
const String COPILOT_ALLOW_MANAGED_HOOKS_ONLY_KEY = 'allowManagedHooksOnly';
const String COPILOT_FORCE_REMOTE_SETTINGS_REFRESH_KEY =
    'forceRemoteSettingsRefresh';
const String COPILOT_TEMPORARY_DEFAULT_TO_LOCAL_HARNESS_KEY =
    'vscode.temporaryDefaultToLocalHarness';
const String COPILOT_TEMPORARY_ALLOW_LOCAL_HARNESS_KEY =
    'vscode.temporaryAllowLocalHarness';
const String COPILOT_ALLOWED_HARNESSES_KEY = 'vscode.allowedHarnesses';

const String _vscodeBlockKey = 'vscode';
const List<String> HARNESS_PERMISSION_KEYS = <String>[
  COPILOT_TEMPORARY_ALLOW_LOCAL_HARNESS_KEY,
  COPILOT_ALLOWED_HARNESSES_KEY,
];

/// 1:1: `ManagedThirdPartyHarness = 'claude' | 'codex'`
typedef ManagedThirdPartyHarness = String;
const List<String> MANAGED_THIRD_PARTY_HARNESSES = <String>['claude', 'codex'];

bool _isManagedThirdPartyHarness(Object? value) =>
    value is String && MANAGED_THIRD_PARTY_HARNESSES.contains(value);

/// 1:1: `interface IAllowedHarnesses`
class IAllowedHarnesses {
  final List<String> harnesses;
  final bool hasUnrecognizedEntries;
  IAllowedHarnesses(this.harnesses, this.hasUnrecognizedEntries);
}

/// 1:1: `export function parseAllowedHarnesses`
IAllowedHarnesses? parseAllowedHarnesses(ManagedSettingValue value) {
  if (value is! String) return null;
  final errors = <ParseError>[];
  final entries = parse(value, errors,
      ParseOptions(disallowComments: true, allowTrailingComma: false));
  if (errors.isNotEmpty || entries is! List) return null;
  final harnesses =
      entries.where(_isManagedThirdPartyHarness).cast<String>().toList();
  return IAllowedHarnesses(
      harnesses, harnesses.length != entries.length);
}

const String TemporaryDefaultToLocalHarnessSettingId =
    'chat.temporaryDefaultToLocalHarness';

const String COPILOT_SANDBOX_ENABLED_KEY = 'sandbox.enabled';
const String COPILOT_SANDBOX_MCP_SERVERS_KEY = 'sandbox.sandboxMcpServers';
const String COPILOT_SANDBOX_LSP_SERVERS_KEY = 'sandbox.sandboxLspServers';
const String COPILOT_SANDBOX_AUTH_GIT_KEY = 'sandbox.auth.git';
const String COPILOT_SANDBOX_AUTH_GH_KEY = 'sandbox.auth.gh';
const String COPILOT_SANDBOX_ALLOW_BYPASS_KEY = 'sandbox.allowBypass';
const String COPILOT_SANDBOX_ALLOW_OUTBOUND_KEY =
    'sandbox.userPolicy.network.allowOutbound';
const String COPILOT_SANDBOX_ALLOW_LOCAL_NETWORK_KEY =
    'sandbox.userPolicy.network.allowLocalNetwork';
const String COPILOT_SANDBOX_ALLOWED_HOSTS_KEY =
    'sandbox.userPolicy.network.allowedHosts';
const String COPILOT_SANDBOX_READWRITE_PATHS_KEY =
    'sandbox.userPolicy.filesystem.readwritePaths';
const String COPILOT_SANDBOX_READONLY_PATHS_KEY =
    'sandbox.userPolicy.filesystem.readonlyPaths';
const String COPILOT_SANDBOX_DENIED_PATHS_KEY =
    'sandbox.userPolicy.filesystem.deniedPaths';
const String COPILOT_SANDBOX_ALLOW_DEV_TOOL_ACCESS_KEY =
    'sandbox.allowDevToolAccess';
const String COPILOT_COMMUNICATION_SUPPORT_URL_KEY = 'communication.support.url';
const String COPILOT_AUTO_TIER_KEY = 'autoTier';
const String COPILOT_FUSION_TIER_KEY = 'fusionTier';

const String _telemetryBlockKey = 'telemetry';
const String _communicationBlockKey = 'communication';

/// 1:1: `MANAGED_SETTINGS_WHOLE_BLOCK_KEYS`
const List<String> MANAGED_SETTINGS_WHOLE_BLOCK_KEYS = <String>[
  _telemetryBlockKey,
  _communicationBlockKey,
];

/// 1:1: `getManagedSettingsWholeBlock`
String? getManagedSettingsWholeBlock(String key) {
  for (final block in MANAGED_SETTINGS_WHOLE_BLOCK_KEYS) {
    if (isManagedSettingInBlock(key, block)) return block;
  }
  return null;
}

/// 1:1: `MANAGED_SETTINGS_CONTROL_DEFINITIONS`
final IManagedSettingsPolicyDefinitions MANAGED_SETTINGS_CONTROL_DEFINITIONS =
    <String, IManagedSettingPolicyDefinition>{
  for (final key in COPILOT_PERMISSION_RULES_KEYS)
    key: IManagedSettingPolicyDefinition('string'),
  COPILOT_DEFAULT_PERMISSIONS_MODE_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_DISABLE_ASSISTED_PERMISSIONS_MODE_KEY:
      IManagedSettingPolicyDefinition('boolean'),
  COPILOT_DISABLE_BYPASS_PERMISSIONS_MODE_KEY:
      IManagedSettingPolicyDefinition('string'),
  'permissions.limitTo': IManagedSettingPolicyDefinition('string'),
  COPILOT_MODEL_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_FORCE_REMOTE_SETTINGS_REFRESH_KEY:
      IManagedSettingPolicyDefinition('boolean'),
  COPILOT_STRICT_MARKETPLACES_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_TEMPORARY_ALLOW_LOCAL_HARNESS_KEY:
      IManagedSettingPolicyDefinition('boolean'),
  COPILOT_ALLOWED_HARNESSES_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_SANDBOX_ENABLED_KEY: IManagedSettingPolicyDefinition('boolean'),
  COPILOT_SANDBOX_MCP_SERVERS_KEY: IManagedSettingPolicyDefinition('boolean'),
  COPILOT_SANDBOX_LSP_SERVERS_KEY: IManagedSettingPolicyDefinition('boolean'),
  COPILOT_SANDBOX_AUTH_GIT_KEY: IManagedSettingPolicyDefinition('boolean'),
  COPILOT_SANDBOX_AUTH_GH_KEY: IManagedSettingPolicyDefinition('boolean'),
  COPILOT_SANDBOX_ALLOW_BYPASS_KEY: IManagedSettingPolicyDefinition('boolean'),
  COPILOT_SANDBOX_ALLOW_OUTBOUND_KEY: IManagedSettingPolicyDefinition('boolean'),
  COPILOT_SANDBOX_ALLOW_LOCAL_NETWORK_KEY:
      IManagedSettingPolicyDefinition('boolean'),
  COPILOT_SANDBOX_ALLOWED_HOSTS_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_SANDBOX_READWRITE_PATHS_KEY:
      IManagedSettingPolicyDefinition('string'),
  COPILOT_SANDBOX_READONLY_PATHS_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_SANDBOX_DENIED_PATHS_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_SANDBOX_ALLOW_DEV_TOOL_ACCESS_KEY:
      IManagedSettingPolicyDefinition('boolean'),
  COPILOT_AUTO_TIER_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_FUSION_TIER_KEY: IManagedSettingPolicyDefinition('string'),
  COPILOT_COMMUNICATION_SUPPORT_URL_KEY:
      IManagedSettingPolicyDefinition('string'),
  'telemetry.capture.prompts': IManagedSettingPolicyDefinition('boolean'),
  'telemetry.capture.responses': IManagedSettingPolicyDefinition('boolean'),
  'telemetry.capture.toolArguments': IManagedSettingPolicyDefinition('boolean'),
  'telemetry.capture.toolOutput': IManagedSettingPolicyDefinition('boolean'),
  'telemetry.capture.policyDetail': IManagedSettingPolicyDefinition('boolean'),
};

const String COPILOT_STRICT_PLUGIN_ONLY_CUSTOMIZATION_CONFIG =
    'chat.customizations.strictPluginOnlyCustomization';
const String COPILOT_ALLOW_MANAGED_MCP_SERVERS_ONLY_CONFIG =
    'chat.mcp.allowManagedServersOnly';
const String COPILOT_ALLOW_MANAGED_HOOKS_ONLY_CONFIG =
    'chat.hooks.allowManagedOnly';

const String COPILOT_MODEL_KEY = 'permissions.model';
const String COPILOT_TOP_LEVEL_MODEL_KEY = 'model';

const String COPILOT_OTEL_ENABLED_KEY = 'telemetry.enabled';
const String COPILOT_OTEL_ENDPOINT_KEY = 'telemetry.endpoint';
const String COPILOT_OTEL_FILE_PATH_KEY = 'telemetry.filePath';
const String COPILOT_OTEL_PROTOCOL_KEY = 'telemetry.protocol';
const String COPILOT_OTEL_CAPTURE_CONTENT_KEY = 'telemetry.captureContent';
const String COPILOT_OTEL_CAPTURE_IDENTITY_KEY = 'telemetry.capture.identity';
const String COPILOT_OTEL_LOCK_CAPTURE_CONTENT_KEY =
    'telemetry.lockCaptureContent';
const String COPILOT_OTEL_SERVICE_NAME_KEY = 'telemetry.serviceName';
const String COPILOT_OTEL_RESOURCE_ATTRIBUTES_KEY =
    'telemetry.resourceAttributes';
const String COPILOT_OTEL_HEADERS_KEY = 'telemetry.headers';

// --- managedSettingValue (memoized callbacks) ---

typedef _ManagedSettingCallback = ManagedSettingValue Function(IPolicyData);
final Map<String, _ManagedSettingCallback> _managedSettingValueCallbacks =
    <String, _ManagedSettingCallback>{};

/// 1:1: `export function managedSettingValue`
_ManagedSettingCallback managedSettingValue(String key) {
  var callback = _managedSettingValueCallbacks[key];
  if (callback == null) {
    callback = (policyData) => policyData.managedSettings?[key];
    _managedSettingValueCallbacks[key] = callback;
  }
  return callback;
}

// --- force remote settings refresh ---

/// 1:1: `IForceRemoteSettingsRefreshResolution`
class IForceRemoteSettingsRefreshResolution {
  final bool effective;
  final String? source;
  IForceRemoteSettingsRefreshResolution(this.effective, this.source);
}

/// 1:1: `export function resolveForceRemoteSettingsRefresh`
IForceRemoteSettingsRefreshResolution resolveForceRemoteSettingsRefresh(
  ManagedSettingsData? nativeMdm,
  ManagedSettingsData? server,
  ManagedSettingsData? file,
) {
  final resolution =
      pickManagedSettings(nativeMdm, server, file).resolutions[COPILOT_FORCE_REMOTE_SETTINGS_REFRESH_KEY];
  if (resolution == null) {
    return IForceRemoteSettingsRefreshResolution(false, null);
  }
  for (final candidate in resolution.contributions) {
    if (candidate.value is bool) {
      return candidate.value == true
          ? IForceRemoteSettingsRefreshResolution(true, candidate.channel)
          : IForceRemoteSettingsRefreshResolution(false, null);
    }
  }
  return IForceRemoteSettingsRefreshResolution(false, null);
}

// --- IManagedSettingsService ---

/// 1:1: `export const IManagedSettingsService = createDecorator(...)`
final ServiceIdentifier<IManagedSettingsServiceType> IManagedSettingsService =
    createDecorator<IManagedSettingsServiceType>('managedSettingsService');

/// 1:1: `export interface IManagedSettingsService`
abstract class IManagedSettingsServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;
  Event<void> get onDidChangeManagedSettings;
  ManagedSettingsData getManagedSettings();
  ManagedSettingValue getManagedSettingValue(String key);
}

/// 1:1: `export class NullManagedSettingsService`
class NullManagedSettingsService implements IManagedSettingsServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;
  @override
  Event<void> get onDidChangeManagedSettings => eventNone;
  @override
  ManagedSettingsData getManagedSettings() => <String, ManagedSettingValue>{};
  @override
  ManagedSettingValue getManagedSettingValue(String _key) => null;
}

/// 1:1: `export function getManagedSupportUrl`
String? getManagedSupportUrl(IManagedSettingsServiceType service) {
  final value = service.getManagedSettingValue(COPILOT_COMMUNICATION_SUPPORT_URL_KEY);
  if (value is! String || value.trim() != value) return null;
  Uri url;
  try {
    url = Uri.parse(value);
  } catch (_) {
    return null;
  }
  return (url.scheme == 'https' || url.scheme == 'http') && url.host.isNotEmpty
      ? _jsUrlHref(url)
      : null;
}

/// 1:1: `export function hasManagedPermissionDenials`
bool hasManagedPermissionDenials(IManagedSettingsServiceType service) {
  final value = service.getManagedSettingValue('permissions.deny');
  if (value == null) return false;
  if (value is! String) return true;
  final errors = <ParseError>[];
  final rules = parse(value, errors,
      ParseOptions(disallowComments: true, allowTrailingComma: false));
  return errors.isNotEmpty || rules is! List || rules.isNotEmpty;
}

/// 1:1: `export function isTemporaryDefaultToLocalHarnessEnabled`
bool isTemporaryDefaultToLocalHarnessEnabled(
    IConfigurationServiceType configurationService) {
  return configurationService
      .inspect(TemporaryDefaultToLocalHarnessSettingId)['policyValue'] ==
      true;
}

/// 1:1: `export function requiresCopilotAgentHost`
bool requiresCopilotAgentHost(
  IManagedSettingsServiceType service,
  IConfigurationServiceType? configurationService,
) {
  if (service.getManagedSettingValue(COPILOT_TEMPORARY_ALLOW_LOCAL_HARNESS_KEY) ==
      false) {
    return true;
  }
  final configValue = configurationService == null
      ? null
      : configurationService
          .inspect(TemporaryDefaultToLocalHarnessSettingId)['policyValue'];
  final temporaryDefaultToLocal = configValue ??
      service.getManagedSettingValue(COPILOT_TEMPORARY_DEFAULT_TO_LOCAL_HARNESS_KEY);
  if (temporaryDefaultToLocal == true) {
    return false;
  }
  return service.getManagedSettingValue(COPILOT_SANDBOX_ENABLED_KEY) == true ||
      hasManagedPermissionDenials(service);
}

// --- model id normalization ---

const String COPILOT_FUSION_MODEL_ALIAS = 'fusion';
_ManagedSettingCallback? _managedModelValueCallback;

/// 1:1: `export function normalizeManagedModelId`
String? normalizeManagedModelId(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed.toLowerCase() == COPILOT_FUSION_MODEL_ALIAS ? 'auto' : trimmed;
}

String? _normalizeModelValue(ManagedSettingValue value) =>
    value is String ? normalizeManagedModelId(value) : null;

/// 1:1: `export function managedModelValue` (memoized)
_ManagedSettingCallback managedModelValue() {
  final callback = _managedModelValueCallback ??= (policyData) {
    final settings = policyData.managedSettings;
    final topLevel = _normalizeModelValue(
        settings == null ? null : settings[COPILOT_TOP_LEVEL_MODEL_KEY]);
    if (topLevel != null) return topLevel;
    return _normalizeModelValue(
        settings == null ? null : settings[COPILOT_MODEL_KEY]);
  };
  return callback;
}

/// 1:1: `export function managedDefaultConfigurationValue`
String? managedDefaultConfigurationValue(IPolicyData policyData) {
  final settings = policyData.managedSettings;
  final mode = settings == null
      ? null
      : settings[COPILOT_DEFAULT_PERMISSIONS_MODE_KEY];
  if (mode is! String) return null;
  var approvals = 'manual';
  if (mode == 'assisted' &&
      (settings == null ||
          settings[COPILOT_DISABLE_ASSISTED_PERMISSIONS_MODE_KEY] != true)) {
    approvals = 'assisted';
  } else if (mode == 'allow-all' &&
      (settings == null ||
          settings[COPILOT_DISABLE_BYPASS_PERMISSIONS_MODE_KEY] != 'disable')) {
    approvals = 'allowAll';
  }
  return jsonEncode(<String, String>{'approvals': approvals});
}

/// 1:1: `export function managedSettingsDisabledValue`
bool? managedSettingsDisabledValue(IPolicyData policyData) =>
    policyData.managedSettingsActive == true ? false : null;

// --- thirdPartyAgentEnabledValue (memoized per harness) ---

final Map<ManagedThirdPartyHarness, _ManagedSettingCallback>
    _thirdPartyAgentEnabledValueCallbacks =
    <ManagedThirdPartyHarness, _ManagedSettingCallback>{};

/// 1:1: `export function thirdPartyAgentEnabledValue`
_ManagedSettingCallback thirdPartyAgentEnabledValue(
    ManagedThirdPartyHarness harness) {
  var callback = _thirdPartyAgentEnabledValueCallbacks[harness];
  if (callback == null) {
    callback = (policyData) {
      final managedSettings = policyData.managedSettings;
      if (policyData.chat_preview_features_enabled == false ||
          (managedSettings != null &&
              managedSettings[COPILOT_TEMPORARY_ALLOW_LOCAL_HARNESS_KEY] ==
                  false)) {
        return false;
      }
      if (managedSettings == null ||
          !managedSettings.containsKey(COPILOT_ALLOWED_HARNESSES_KEY)) {
        return managedSettingsDisabledValue(policyData);
      }
      final allowedHarnesses = managedSettings[COPILOT_ALLOWED_HARNESSES_KEY];
      final parsed = parseAllowedHarnesses(allowedHarnesses);
      return (parsed != null && parsed.harnesses.contains(harness))
          ? null
          : false;
    };
    _thirdPartyAgentEnabledValueCallbacks[harness] = callback;
  }
  return callback;
}

// --- INativeManagedSettingsService ---

/// 1:1: `export const INativeManagedSettingsService = createDecorator(...)`
final ServiceIdentifier<INativeManagedSettingsServiceType>
    INativeManagedSettingsService =
    createDecorator<INativeManagedSettingsServiceType>(
        'nativeManagedSettingsService');

/// 1:1: `export interface INativeManagedSettingsService`
abstract class INativeManagedSettingsServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;
  ManagedSettingsData get managedSettings;
  Event<ManagedSettingsData> get onDidChangeManagedSettings;
  Future<ManagedSettingsData> initialize();
  Future<ManagedSettingsData> updatePolicyDefinitions(
      Map<String, PolicyDefinition> policyDefinitions);
}

/// 1:1: `export class NullNativeManagedSettingsService`
class NullNativeManagedSettingsService
    implements INativeManagedSettingsServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;
  @override
  final ManagedSettingsData managedSettings = <String, ManagedSettingValue>{};
  @override
  Event<ManagedSettingsData> get onDidChangeManagedSettings => eventNone;
  @override
  Future<ManagedSettingsData> initialize() async => managedSettings;
  @override
  Future<ManagedSettingsData> updatePolicyDefinitions(
          [Map<String, PolicyDefinition>? policyDefinitions]) async =>
      managedSettings;
}

// --- flatten / collect / project ---

/// 1:1: `flattenManagedSettingsValue`
void _flattenManagedSettingsValue(
  Object? value,
  String? prefix,
  Map<String, Object?> result,
) {
  if (value is String || value is num || value is bool) {
    if (prefix != null) result[prefix] = value;
    return;
  }
  if (!_isObject(value)) return;
  final map = value as Map;
  for (final entry in map.entries) {
    final key = entry.key as String;
    _flattenManagedSettingsValue(
      entry.value,
      (prefix != null && prefix.isNotEmpty) ? '$prefix.$key' : key,
      result,
    );
  }
}

/// 1:1: `flattenManagedSettings`
Map<String, Object?> _flattenManagedSettings(Object? object) {
  final result = <String, Object?>{};
  _flattenManagedSettingsValue(object, null, result);
  return result;
}

/// 1:1: `export function collectManagedSettingsDefinitions`
IManagedSettingsPolicyDefinitions collectManagedSettingsDefinitions(
    Map<String, PolicyDefinition> policyDefinitions) {
  final definitions = <String, IManagedSettingPolicyDefinition>{};
  for (final entry in policyDefinitions.entries) {
    final policyManagedSettings = entry.value.managedSettings;
    if (policyManagedSettings is Map) {
      for (final msEntry in policyManagedSettings.entries) {
        definitions[msEntry.key as String] =
            msEntry.value as IManagedSettingPolicyDefinition;
      }
    }
  }
  return definitions;
}

/// 1:1: `export function hasManagedSettingsDefinitions`
bool hasManagedSettingsDefinitions(
    Map<String, PolicyDefinition> policyDefinitions) {
  for (final entry in policyDefinitions.entries) {
    final policyManagedSettings = entry.value.managedSettings;
    if (policyManagedSettings != null &&
        !isEmptyObject(policyManagedSettings)) {
      return true;
    }
  }
  return false;
}

/// 1:1: `export function projectManagedSettings`
ManagedSettingsData projectManagedSettings(
  ManagedSettingsData values,
  IManagedSettingsPolicyDefinitions definitions, [
  void Function(String msg)? onWarn,
]) {
  final projected = <String, ManagedSettingValue>{};
  for (final entry in definitions.entries) {
    final key = entry.key;
    if (!values.containsKey(key)) continue;
    final value = values[key];
    if (_jsTypeOf(value) == entry.value.type) {
      projected[key] = value;
    } else {
      onWarn?.call(
          'Ignoring managed setting "$key": expected ${entry.value.type}, got ${_jsTypeOf(value)}');
    }
  }
  return projected;
}

// --- pickManagedSettings ---

/// 1:1: `ManagedSettingsChannel` / `ManagedSettingsSource`
typedef ManagedSettingsChannel = String;
typedef ManagedSettingsSource = String;

/// 1:1: `MANAGED_SETTINGS_CHANNELS`
const List<ManagedSettingsChannel> MANAGED_SETTINGS_CHANNELS = <String>[
  'nativeMdm',
  'server',
  'file',
];

/// 1:1: `IManagedSettingsContribution`
class IManagedSettingsContribution {
  final ManagedSettingsChannel channel;
  final ManagedSettingValue value;
  IManagedSettingsContribution(this.channel, this.value);
}

/// 1:1: `IManagedSettingResolution`
class IManagedSettingResolution {
  final ManagedSettingValue value;
  final ManagedSettingsChannel source;
  final List<IManagedSettingsContribution> contributions;
  IManagedSettingResolution(this.value, this.source, this.contributions);
}

/// 1:1: `IManagedSettingsPick`
class IManagedSettingsPick {
  final ManagedSettingsData values;
  final Map<String, IManagedSettingResolution> resolutions;
  final Map<String, List<IManagedSettingsContribution>>
      excludedBlockContributions;
  final List<ManagedSettingsChannel> activeSources;
  IManagedSettingsPick(
    this.values,
    this.resolutions,
    this.excludedBlockContributions,
    this.activeSources,
  );
}

/// 1:1: `export function pickManagedSettings`
IManagedSettingsPick pickManagedSettings(
  ManagedSettingsData? nativeMdm,
  ManagedSettingsData? server,
  ManagedSettingsData? file,
) {
  final bags = <ManagedSettingsChannel, ManagedSettingsData?>{
    'nativeMdm': nativeMdm,
    'server': server,
    'file': file,
  };

  final resolutions =
      <String, IManagedSettingResolution>{};
  final excludedBlockContributions =
      <String, List<IManagedSettingsContribution>>{};
  final blockSources = <String, ManagedSettingsChannel>{};

  for (final channel in MANAGED_SETTINGS_CHANNELS) {
    final bag = bags[channel];
    if (bag == null) continue;
    for (final key in bag.keys) {
      final value = bag[key];
      if (value == null) continue;
      final existing = resolutions[key];
      final block = getManagedSettingsWholeBlock(key);
      if (block != null) {
        final blockSource = blockSources[block] ?? channel;
        blockSources[block] = blockSource;
        if (channel != blockSource && existing == null) {
          final contributions =
              excludedBlockContributions[key] ?? <IManagedSettingsContribution>[];
          contributions.add(IManagedSettingsContribution(channel, value));
          excludedBlockContributions[key] = contributions;
          continue;
        }
      }
      if (existing != null) {
        existing.contributions.add(IManagedSettingsContribution(channel, value));
        final forceOnKeys = <String>{
          COPILOT_SANDBOX_ENABLED_KEY,
          COPILOT_SANDBOX_MCP_SERVERS_KEY,
          COPILOT_SANDBOX_LSP_SERVERS_KEY,
        };
        final denyWinsKeys = <String>{
          COPILOT_SANDBOX_ALLOW_BYPASS_KEY,
          COPILOT_SANDBOX_ALLOW_OUTBOUND_KEY,
          COPILOT_SANDBOX_ALLOW_LOCAL_NETWORK_KEY,
          COPILOT_SANDBOX_ALLOW_DEV_TOOL_ACCESS_KEY,
          COPILOT_SANDBOX_AUTH_GIT_KEY,
          COPILOT_SANDBOX_AUTH_GH_KEY,
        };
        final forceOn =
            forceOnKeys.contains(key) && value == true && existing.value != true;
        final denyWins =
            denyWinsKeys.contains(key) && value == false && existing.value != false;
        if (forceOn || denyWins) {
          // Build a new resolution with the winning value/source but the grown
          // contributions list (fields are final, so replace the object).
          resolutions[key] = IManagedSettingResolution(
              value, channel, existing.contributions);
        }
      } else {
        resolutions[key] = IManagedSettingResolution(
            value, channel, <IManagedSettingsContribution>[
          IManagedSettingsContribution(channel, value),
        ]);
      }
    }
  }

  final activeSet = <ManagedSettingsChannel>{};
  final values = <String, ManagedSettingValue>{};
  for (final entry in resolutions.entries) {
    values[entry.key] = entry.value.value;
    activeSet.add(entry.value.source);
  }

  return IManagedSettingsPick(
    values,
    resolutions,
    excludedBlockContributions,
    MANAGED_SETTINGS_CHANNELS.where(activeSet.contains).toList(),
  );
}

// --- File-based managed settings ---

const String MANAGED_SETTINGS_MACOS_FILE_PATH =
    '/Library/Application Support/GitHubCopilot/managed-settings.json';
const String MANAGED_SETTINGS_LINUX_FILE_PATH =
    '/etc/github-copilot/managed-settings.json';
const String MANAGED_SETTINGS_WINDOWS_DIR = 'GitHubCopilot';
const String MANAGED_SETTINGS_FILE_NAME = 'managed-settings.json';

/// 1:1: `IStructuredManagedSetting`
typedef _StructuredEncoder = Object? Function(
    Object? value, [void Function(String msg)? onWarn]);

class IStructuredManagedSetting {
  final String key;
  final _StructuredEncoder encode;
  IStructuredManagedSetting(this.key, this.encode);
}

/// 1:1: `encodeStringMap`
Map<String, String>? _encodeStringMap(Object? value) {
  if (!_isObject(value)) return null;
  final out = <String, String>{};
  for (final entry in (value as Map).entries) {
    final k = entry.key as String;
    if (k == '__proto__' || k == 'constructor' || k == 'prototype') continue;
    final v = entry.value;
    if (v is String) {
      out[k] = v;
    } else if (v is num || v is bool) {
      out[k] = _jsString(v);
    }
  }
  return out;
}

/// 1:1: `encodeObject`
Object? _encodeObject(Object? value) => _isObject(value) ? value : null;

/// 1:1: `encodeArray`
Object? _encodeArray(Object? value) => value is List ? value : null;

/// 1:1: `encodeExtraMarketplaces`
ExtraKnownMarketplacesConfigDict? _encodeExtraMarketplaces(
    Object? value, [void Function(String msg)? onWarn]) {
  return extraKnownMarketplacesToConfigDict(
      _normalizeExtraKnownMarketplaces(value, onWarn));
}

/// 1:1: `STRUCTURED_MANAGED_SETTINGS`
final List<IStructuredManagedSetting> STRUCTURED_MANAGED_SETTINGS =
    <IStructuredManagedSetting>[
  for (final key in COPILOT_PERMISSION_RULES_KEYS)
    IStructuredManagedSetting(key, (v, [w]) => v),
  IStructuredManagedSetting(COPILOT_ALLOWED_HARNESSES_KEY, (v, [w]) => v),
  IStructuredManagedSetting(COPILOT_SANDBOX_ALLOWED_HOSTS_KEY,
      (v, [w]) => _encodeArray(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_SANDBOX_READWRITE_PATHS_KEY,
      (v, [w]) => _encodeArray(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_SANDBOX_READONLY_PATHS_KEY,
      (v, [w]) => _encodeArray(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_SANDBOX_DENIED_PATHS_KEY,
      (v, [w]) => _encodeArray(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_AUTO_TIER_KEY, (v, [w]) => v),
  IStructuredManagedSetting(COPILOT_FUSION_TIER_KEY, (v, [w]) => v),
  IStructuredManagedSetting(COPILOT_ENABLED_PLUGINS_KEY,
      (v, [w]) => _encodeObject(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_STRICT_MARKETPLACES_KEY,
      (v, [w]) => _encodeArray(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_ALLOWED_MCP_SERVERS_KEY,
      (v, [w]) => _encodeArray(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_DENIED_MCP_SERVERS_KEY,
      (v, [w]) => _encodeArray(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_EXTRA_MARKETPLACES_KEY,
      (v, [w]) => _encodeExtraMarketplaces(v, w) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_OTEL_RESOURCE_ATTRIBUTES_KEY,
      (v, [w]) => _encodeStringMap(v) ?? jsUndefined),
  IStructuredManagedSetting(COPILOT_OTEL_HEADERS_KEY,
      (v, [w]) => _encodeStringMap(v) ?? jsUndefined),
];

/// 1:1: `readNestedManagedKey`
Object? _readNestedManagedKey(Map<String, Object?> obj, String dottedKey) {
  Object? current = obj;
  for (final segment in dottedKey.split('.')) {
    if (!_isObject(current)) return jsUndefined;
    final map = current as Map;
    // JS `obj[segment]` returns `undefined` only for a missing key; a present
    // key with value `null` must stay `null` (JSON.stringify(null) === 'null').
    if (!map.containsKey(segment)) return jsUndefined;
    current = map[segment];
  }
  return current;
}

/// 1:1: `withNestedManagedKeyDeleted`
Map<String, Object?> _withNestedManagedKeyDeleted(
    Map<String, Object?> obj, String dottedKey) {
  final dot = dottedKey.indexOf('.');
  if (dot == -1) {
    final clone = <String, Object?>{...obj};
    clone.remove(dottedKey);
    return clone;
  }
  final head = dottedKey.substring(0, dot);
  final child = obj[head];
  if (!_isObject(child)) return obj;
  return <String, Object?>{
    ...obj,
    head: _withNestedManagedKeyDeleted(
        (child as Map).cast<String, Object?>(), dottedKey.substring(dot + 1)),
  };
}

/// 1:1: `export function normalizeManagedSettings`
ManagedSettingsData normalizeManagedSettings(
  Map<String, Object?> parsed, [
  void Function(String msg)? onWarn,
]) {
  var scalarRest = <String, Object?>{...parsed};
  final presentBlocks = MANAGED_SETTINGS_WHOLE_BLOCK_KEYS.where((block) =>
      parsed.containsKey(block) && _isObject(parsed[block])).toList();
  for (final block in MANAGED_SETTINGS_WHOLE_BLOCK_KEYS) {
    if (!presentBlocks.contains(block)) scalarRest.remove(block);
  }
  for (final setting in STRUCTURED_MANAGED_SETTINGS) {
    scalarRest = _withNestedManagedKeyDeleted(scalarRest, setting.key);
  }

  final result = <String, ManagedSettingValue>{
    ..._flattenManagedSettings(scalarRest),
  };

  for (final setting in STRUCTURED_MANAGED_SETTINGS) {
    final encoded =
        setting.encode(_readNestedManagedKey(parsed, setting.key), onWarn);
    if (identical(encoded, jsUndefined)) continue;
    result[setting.key] = jsonEncode(encoded);
  }

  for (final block in presentBlocks) {
    if (!result.keys.any((key) => isManagedSettingInBlock(key, block))) {
      result[block] = '{}';
    }
  }

  final permissions = parsed['permissions'];
  if (_isObject(permissions)) {
    for (final entry in (permissions as Map).entries) {
      final flatKey = 'permissions.${entry.key}';
      final value = entry.value;
      if (value != null &&
          !result.keys.any((k) =>
              k == flatKey || k.startsWith('$flatKey.'))) {
        result[flatKey] = jsonEncode(value);
      }
    }
  }

  return result;
}

/// 1:1: `normalizeExtraKnownMarketplaces`
List<Object?>? _normalizeExtraKnownMarketplaces(
    Object? value, [void Function(String msg)? onWarn]) {
  if (!_isObject(value)) return null;
  final seen = <String>{};
  final entries = <Object?>[];
  for (final entry in (value as Map).entries) {
    final name = entry.key as String;
    final raw = entry.value;
    if (!_isObject(raw) || !_isObject((raw as Map)['source'])) {
      onWarn?.call(
          'Skipping malformed extraKnownMarketplaces entry "$name": expected { source: { source, repo|url } }');
      continue;
    }
    final rawEntry = raw as Map<String, Object?>;
    final src = (rawEntry['source'] as Map).cast<String, Object?>();
    final autoUpdateRaw = rawEntry['autoUpdate'];
    final bool? autoUpdate = autoUpdateRaw is bool ? autoUpdateRaw : null;
    if (autoUpdateRaw != null && autoUpdate == null) {
      onWarn?.call(
          'Ignoring invalid autoUpdate for extraKnownMarketplaces entry "$name": expected boolean');
    }
    final refValue = src['ref'];
    final String? ref =
        (refValue is String && refValue.isNotEmpty) ? refValue : null;
    IExtraKnownMarketplaceEntry? normalized;
    final srcSource = src['source'];
    if (srcSource == 'github' && src['repo'] is String) {
      normalized = GithubMarketplaceEntry(
          name, GithubMarketplaceSource(src['repo'] as String, ref), autoUpdate);
    } else if (srcSource == 'git' && src['url'] is String) {
      normalized = GitMarketplaceEntry(
          name, GitMarketplaceSource(src['url'] as String, ref), autoUpdate);
    } else if (srcSource == 'github' || srcSource == 'git') {
      onWarn?.call(
          'Skipping extraKnownMarketplaces entry "$name": source "$srcSource" requires ${srcSource == 'github' ? '"repo"' : '"url"'}');
    } else {
      onWarn?.call(
          'Skipping extraKnownMarketplaces entry "$name": unknown source type "$srcSource"');
    }
    if (normalized != null && !seen.contains(name)) {
      seen.add(name);
      entries.add(normalized);
    }
  }
  return entries;
}

// --- IFileManagedSettingsService ---

/// 1:1: `export const IFileManagedSettingsService = createDecorator(...)`
final ServiceIdentifier<IFileManagedSettingsServiceType>
    IFileManagedSettingsService =
    createDecorator<IFileManagedSettingsServiceType>('fileManagedSettingsService');

/// 1:1: `export interface IFileManagedSettingsService`
abstract class IFileManagedSettingsServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;
  RawManagedSettingsData get rawManagedSettings;
  ManagedSettingsData get managedSettings;
  Event<RawManagedSettingsData> get onDidChangeRawManagedSettings;
  Event<ManagedSettingsData> get onDidChangeManagedSettings;
  Future<ManagedSettingsData> initialize();
}

/// 1:1: `export class NullFileManagedSettingsService`
class NullFileManagedSettingsService implements IFileManagedSettingsServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;
  @override
  final RawManagedSettingsData rawManagedSettings = <String, Object?>{};
  @override
  final ManagedSettingsData managedSettings = <String, ManagedSettingValue>{};
  @override
  Event<RawManagedSettingsData> get onDidChangeRawManagedSettings => eventNone;
  @override
  Event<ManagedSettingsData> get onDidChangeManagedSettings => eventNone;
  @override
  Future<ManagedSettingsData> initialize() async => managedSettings;
}
