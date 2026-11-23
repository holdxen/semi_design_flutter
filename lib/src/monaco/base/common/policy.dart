// 1:1 port of vs/base/common/policy.ts
import '../../nls.dart' show localize;
import 'defaultAccount.dart' show IPolicyData;

/// 1:1: `export const LINUX_SYSTEM_POLICY_FILE_PATH`
const String LINUX_SYSTEM_POLICY_FILE_PATH = '/etc/vscode/policy.json';

/// 1:1: `export type PolicyName = string`
typedef PolicyName = String;

/// 1:1: `export type LocalizedValue = { key: string; value: string }`
class LocalizedValue {
  final String key;
  final String value;
  LocalizedValue(this.key, this.value);
}

/// 1:1: `export type PolicyValue = string | number | boolean`
/// Carried as [Object?] (JS union).
typedef PolicyValue = Object?;

/// 1:1: `export type ManagedSettingValue = PolicyValue`
typedef ManagedSettingValue = Object?;

/// 1:1: `export type ManagedSettingsData = Readonly<Record<string, ManagedSettingValue>>`
typedef ManagedSettingsData = Map<String, ManagedSettingValue>;

/// 1:1: `export interface IManagedSettingPolicyDefinition`
class IManagedSettingPolicyDefinition {
  /// TS: `'string' | 'number' | 'boolean'`
  final String type;
  IManagedSettingPolicyDefinition(this.type);
}

/// 1:1: `export type IManagedSettingsPolicyDefinitions`
typedef IManagedSettingsPolicyDefinitions =
    Map<String, IManagedSettingPolicyDefinition>;

/// 1:1: `export enum PolicyCategory` (string enum)
class PolicyCategory {
  static const String Extensions = 'Extensions';
  static const String IntegratedTerminal = 'IntegratedTerminal';
  static const String InteractiveSession = 'InteractiveSession';
  static const String Telemetry = 'Telemetry';
  static const String Update = 'Update';

  const PolicyCategory._();
}

/// 1:1: `export const PolicyCategoryData`
final Map<String, Map<String, LocalizedValue>> PolicyCategoryData =
    <String, Map<String, LocalizedValue>>{
  PolicyCategory.Extensions: <String, LocalizedValue>{
    'name': LocalizedValue('extensionsConfigurationTitle',
        localize('extensionsConfigurationTitle', 'Extensions')),
  },
  PolicyCategory.IntegratedTerminal: <String, LocalizedValue>{
    'name': LocalizedValue('terminalIntegratedConfigurationTitle',
        localize('terminalIntegratedConfigurationTitle', 'Integrated Terminal')),
  },
  PolicyCategory.InteractiveSession: <String, LocalizedValue>{
    'name': LocalizedValue('interactiveSessionConfigurationTitle',
        localize('interactiveSessionConfigurationTitle', 'Chat')),
  },
  PolicyCategory.Telemetry: <String, LocalizedValue>{
    'name': LocalizedValue('telemetryConfigurationTitle',
        localize('telemetryConfigurationTitle', 'Telemetry')),
  },
  PolicyCategory.Update: <String, LocalizedValue>{
    'name': LocalizedValue('updateConfigurationTitle',
        localize('updateConfigurationTitle', 'Update')),
  },
};

/// 1:1: `export interface IPolicy`
class IPolicy {
  final PolicyName name;
  final String category;
  final String minimumVersion; // `${number}.${number}`
  final IPolicyLocalization localization;
  final Object? Function(IPolicyData policyData)? value;
  final IManagedSettingsPolicyDefinitions? managedSettings;
  final Object? restrictedValue;

  IPolicy({
    required this.name,
    required this.category,
    required this.minimumVersion,
    required this.localization,
    this.value,
    this.managedSettings,
    this.restrictedValue,
  });
}

/// 1:1: `IPolicy.localization` nested type
class IPolicyLocalization {
  final LocalizedValue description;
  final List<LocalizedValue>? enumDescriptions;
  IPolicyLocalization({required this.description, this.enumDescriptions});
}

/// 1:1: `export interface IPolicyReference`
class IPolicyReference {
  final PolicyName name;
  IPolicyReference(this.name);
}

/// 1:1: `export interface IExtensionConfigurationPolicyReference`
class IExtensionConfigurationPolicyReference {
  final IPolicyReference policyReference;
  IExtensionConfigurationPolicyReference(this.policyReference);
}
