// 1:1 port of vscode/src/vs/platform/configuration/common/configurationRegistry.ts
//
// Port notes:
//   - The TS `ConfigurationRegistry` class is private; the Dart class has the
//     same name and is public so tests can create an isolated registry. Public
//     module functions still use the single global instance registered through
//     `Registry.add`, exactly like the source.
//   - JS `undefined` is represented by [_jsUndefined] where a value must
//     distinguish it from `null` (JSON schema defaults).
//   - Interfaces/schema objects are `Map<String, Object?>` carriers, matching
//     the runtime object-literal shape used by the TypeScript implementation.

import 'dart:collection';

import '../../../base/common/arrays.dart' as arrays;
import '../../../base/common/event.dart' as event;
import '../../../base/common/jsonSchema.dart' as jsonSchema;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/policy.dart' as policy;
import '../../../base/common/types.dart' as types;
import '../../../nls.dart' as nls;
import '../../jsonschemas/common/jsonContributionRegistry.dart'
    as jsonContributions;
import '../../product/common/product.dart' as product;
import '../../registry/common/platform.dart' as platformRegistry;
import 'configuration.dart' as configuration;

/// 1:1: `IStringDictionary<T>`
typedef IStringDictionary<T> = Map<String, T>;

/// 1:1: `IJSONSchema`
typedef IJSONSchema = jsonSchema.IJSONSchema;

/// 1:1: `IConfigurationPropertySchema`
typedef IConfigurationPropertySchema = Map<String, Object?>;

/// 1:1: `IRegisteredConfigurationPropertySchema`
typedef IRegisteredConfigurationPropertySchema = Map<String, Object?>;

/// 1:1: `ConfigurationDefaultSource`
typedef ConfigurationDefaultSource = Object?;

/// 1:1: `ConfigurationDefaultValueSource`
typedef ConfigurationDefaultValueSource = Object?;

/// JS `undefined` sentinel. Dart `null` maps to JS `null`.
const Object _jsUndefined = Object();

/// 1:1: `export enum EditPresentationTypes`
class EditPresentationTypes {
  static const String Multiline = 'multilineText';
  static const String Singleline = 'singlelineText';

  const EditPresentationTypes._();
}

/// 1:1: `export const Extensions`
class Extensions {
  static const String Configuration = 'base.contributions.configuration';

  const Extensions._();
}

/// 1:1: `export const enum AgentHostConfigurationSyncScope`
class AgentHostConfigurationSyncScope {
  static const String All = 'all';
  static const String Local = 'local';
  static const String Ambient = 'ambient';

  const AgentHostConfigurationSyncScope._();
}

/// 1:1: `export const enum ConfigurationScope`
class ConfigurationScope {
  static const int APPLICATION = 1;
  static const int MACHINE = 2;
  static const int APPLICATION_MACHINE = 3;
  static const int WINDOW = 4;
  static const int RESOURCE = 5;
  static const int LANGUAGE_OVERRIDABLE = 6;
  static const int MACHINE_OVERRIDABLE = 7;

  const ConfigurationScope._();
}

/// 1:1: `export interface IExtensionInfo`
class IExtensionInfo {
  final String id;
  final String? displayName;

  IExtensionInfo(this.id, [this.displayName]);
}

/// 1:1: `export interface IAgentHostConfigurationSync`
class IAgentHostConfigurationSync {
  final String key;
  final Object? Function(Object? value)? transform;
  final Map<String, Object? Function(Object? value)>? derivedKeys;
  final String? scope;

  IAgentHostConfigurationSync({
    required this.key,
    this.transform,
    this.derivedKeys,
    this.scope,
  });
}

/// 1:1: `export interface IConfigurationNode`
class IConfigurationNode {
  String? id;
  num? order;
  Object? type;
  String? title;
  String? description;
  IStringDictionary<IConfigurationPropertySchema>? properties;
  List<IConfigurationNode>? allOf;
  int? scope;
  IExtensionInfo? extensionInfo;
  List<String>? restrictedProperties;

  IConfigurationNode({
    this.id,
    this.order,
    this.type,
    this.title,
    this.description,
    this.properties,
    this.allOf,
    this.scope,
    this.extensionInfo,
    this.restrictedProperties,
  });
}

/// 1:1: `export interface IConfigurationDefaults`
class IConfigurationDefaults {
  final IStringDictionary<Object?> overrides;
  final ConfigurationDefaultSource source;
  final bool? donotCache;
  final bool? preventExperimentOverride;

  IConfigurationDefaults(
    this.overrides, {
    this.source = _jsUndefined,
    this.donotCache,
    this.preventExperimentOverride,
  });
}

/// 1:1: `export interface IConfigurationDelta`
class IConfigurationDelta {
  final List<IConfigurationDefaults>? removedDefaults;
  final List<IConfigurationNode>? removedConfigurations;
  final List<IConfigurationDefaults>? addedDefaults;
  final List<IConfigurationNode>? addedConfigurations;

  IConfigurationDelta({
    this.removedDefaults,
    this.removedConfigurations,
    this.addedDefaults,
    this.addedConfigurations,
  });
}

/// 1:1: `export interface IConfigurationDefaultOverride`
class IConfigurationDefaultOverride {
  Object? value;
  ConfigurationDefaultSource source;

  IConfigurationDefaultOverride(this.value, this.source);
}

/// 1:1: `export interface IConfigurationDefaultOverrideValue`
class IConfigurationDefaultOverrideValue {
  Object? value;
  ConfigurationDefaultValueSource source;

  IConfigurationDefaultOverrideValue(this.value, [this.source = _jsUndefined]);
}

/// 1:1: `allSettings` / `applicationSettings` / ... carriers
class ConfigurationSettings {
  final Map<String, IJSONSchema> properties = <String, IJSONSchema>{};
  final Map<String, IJSONSchema> patternProperties = <String, IJSONSchema>{};
}

/// 1:1: payload of `onDidUpdateConfiguration`
class IConfigurationUpdateConfigurationEvent {
  final Set<String> properties;
  final Object? defaultsOverrides;

  IConfigurationUpdateConfigurationEvent(
    this.properties, [
    this.defaultsOverrides = _jsUndefined,
  ]);
}

/// 1:1: `export interface IConfigurationRegistry`
abstract class IConfigurationRegistryType {
  IConfigurationNode registerConfiguration(
      IConfigurationNode configuration,
      [bool validate = true]);

  void registerConfigurations(List<IConfigurationNode> configurations,
      [bool validate = true]);

  void deregisterConfigurations(List<IConfigurationNode> configurations);

  void updateConfigurations({
    required List<IConfigurationNode> add,
    required List<IConfigurationNode> remove,
  });

  void registerDefaultConfigurations(
      List<IConfigurationDefaults> configurationDefaults);

  void deregisterDefaultConfigurations(
      List<IConfigurationDefaults> defaultConfigurations);

  void deltaConfiguration(IConfigurationDelta delta);

  List<IConfigurationDefaults> getRegisteredDefaultConfigurations();

  Map<String, IConfigurationDefaultOverrideValue>
      getConfigurationDefaultsOverrides();

  void notifyConfigurationSchemaUpdated(List<IConfigurationNode> configurations);

  event.Event<void> get onDidSchemaChange;

  event.Event<IConfigurationUpdateConfigurationEvent>
      get onDidUpdateConfiguration;

  List<IConfigurationNode> getConfigurations();

  IStringDictionary<IRegisteredConfigurationPropertySchema>
      getConfigurationProperties();

  Map<policy.PolicyName, String> getPolicyConfigurations();

  Map<policy.PolicyName, Set<String>> getPolicyReferenceConfigurations();

  Map<String, IAgentHostConfigurationSync> getAgentHostSyncConfigurations();

  IStringDictionary<IRegisteredConfigurationPropertySchema>
      getExcludedConfigurationProperties();

  void registerOverrideIdentifiers(List<String> identifiers);
}

/// Dart alias preserving the TypeScript interface name.
typedef IConfigurationRegistry = IConfigurationRegistryType;

/// 1:1: `export const allSettings`
final ConfigurationSettings allSettings = ConfigurationSettings();

/// 1:1: `export const applicationSettings`
final ConfigurationSettings applicationSettings = ConfigurationSettings();

/// 1:1: `export const applicationMachineSettings`
final ConfigurationSettings applicationMachineSettings =
    ConfigurationSettings();

/// 1:1: `export const machineSettings`
final ConfigurationSettings machineSettings = ConfigurationSettings();

/// 1:1: `export const machineOverridableSettings`
final ConfigurationSettings machineOverridableSettings =
    ConfigurationSettings();

/// 1:1: `export const windowSettings`
final ConfigurationSettings windowSettings = ConfigurationSettings();

/// 1:1: `export const resourceSettings`
final ConfigurationSettings resourceSettings = ConfigurationSettings();

/// 1:1: `export const resourceLanguageSettingsSchemaId`
const String resourceLanguageSettingsSchemaId =
    'vscode://schemas/settings/resourceLanguage';

/// 1:1: `export const configurationDefaultsSchemaId`
const String configurationDefaultsSchemaId =
    'vscode://schemas/settings/configurationDefaults';

const String OVERRIDE_IDENTIFIER_PATTERN = r'\[([^\]]+)\]';
final RegExp _overrideIdentifierRegex = RegExp(OVERRIDE_IDENTIFIER_PATTERN);

/// 1:1: `export const OVERRIDE_PROPERTY_PATTERN`
const String OVERRIDE_PROPERTY_PATTERN =
    r'^(\[([^\]]+)\])+$';

/// 1:1: `export const OVERRIDE_PROPERTY_REGEX`
final RegExp OVERRIDE_PROPERTY_REGEX = RegExp(OVERRIDE_PROPERTY_PATTERN);

/// 1:1: `export function getConfigurationExperimentName`
String getConfigurationExperimentName(
  String key,
  Map<String, Object?>? experiment,
) =>
    experiment?['name'] as String? ?? 'config.$key';

/// 1:1: `export function getConfigurationKeyExperimentName`
String getConfigurationKeyExperimentName(
  String key,
  Map<String, Object?>? experiment,
  String objectKey,
) =>
    '${getConfigurationExperimentName(key, experiment)}.$objectKey';

String? _sourceId(Object? source) {
  if (source == null || identical(source, _jsUndefined)) return null;
  if (source is String) return source;
  if (source is IExtensionInfo) return source.id;
  final Map<String, Object?>? map = _asStringMap(source);
  if (map != null) return map['id'] as String?;
  try {
    return (source as dynamic).id as String?;
  } catch (_) {
    return null;
  }
}

/// 1:1: `export function isConfigurationDefaultSourceEquals`
bool isConfigurationDefaultSourceEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null ||
      identical(a, _jsUndefined) || identical(b, _jsUndefined)) {
    return false;
  }
  if (a is String || b is String) return a == b;
  return _sourceId(a) == _sourceId(b);
}

/// 1:1: `export function overrideIdentifiersFromKey`
List<String> overrideIdentifiersFromKey(String key) {
  final List<String> identifiers = <String>[];
  if (OVERRIDE_PROPERTY_REGEX.hasMatch(key)) {
    for (final RegExpMatch match in _overrideIdentifierRegex.allMatches(key)) {
      final String identifier = match.group(1)!.trim();
      if (identifier.isNotEmpty) identifiers.add(identifier);
    }
  }
  return arrays.distinct(identifiers);
}

/// 1:1: `export function keyFromOverrideIdentifiers`
String keyFromOverrideIdentifiers(List<String> overrideIdentifiers) =>
    overrideIdentifiers.fold<String>('', (String result, String identifier) =>
        '$result[$identifier]');

/// 1:1: `export function getDefaultValue`
Object? getDefaultValue(Object? type) {
  final Object? t = type is List ? (type.isEmpty ? null : type.first) : type;
  switch (t) {
    case 'boolean':
      return false;
    case 'integer':
    case 'number':
      return 0;
    case 'string':
      return '';
    case 'array':
      return <Object?>[];
    case 'object':
      return <String, Object?>{};
    default:
      return null;
  }
}

/// 1:1: `export function parseScope`
int parseScope(String scope) {
  switch (scope) {
    case 'application':
      return ConfigurationScope.APPLICATION;
    case 'machine':
      return ConfigurationScope.MACHINE;
    case 'resource':
      return ConfigurationScope.RESOURCE;
    case 'machine-overridable':
      return ConfigurationScope.MACHINE_OVERRIDABLE;
    case 'language-overridable':
      return ConfigurationScope.LANGUAGE_OVERRIDABLE;
    default:
      return ConfigurationScope.WINDOW;
  }
}

/// 1:1: `export function getAllConfigurationProperties`
IStringDictionary<IRegisteredConfigurationPropertySchema>
    getAllConfigurationProperties(List<IConfigurationNode> configurationNode) {
  final IStringDictionary<IRegisteredConfigurationPropertySchema> result =
      <String, IRegisteredConfigurationPropertySchema>{};
  for (final IConfigurationNode configuration in configurationNode) {
    final IStringDictionary<IConfigurationPropertySchema>? properties =
        configuration.properties;
    if (properties != null) {
      for (final String key in properties.keys) {
        result[key] = properties[key]!;
      }
    }
    final List<IConfigurationNode>? subNodes = configuration.allOf;
    if (subNodes != null) {
      result.addAll(getAllConfigurationProperties(subNodes));
    }
  }
  return result;
}

Map<String, Object?>? _asStringMap(Object? value) {
  if (value == null || identical(value, _jsUndefined)) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    return value.map<String, Object?>(
        (Object? key, Object? val) => MapEntry<String, Object?>(key.toString(), val));
  }
  return null;
}

String? _stringField(Object? value, String field) {
  final Map<String, Object?>? map = _asStringMap(value);
  if (map != null) return map[field] as String?;
  if (value == null || identical(value, _jsUndefined)) return null;
  try {
    final dynamic dynamicValue = value;
    switch (field) {
      case 'name':
        return dynamicValue.name as String?;
      case 'key':
        return dynamicValue.key as String?;
      case 'id':
        return dynamicValue.id as String?;
      case 'extensionId':
        return dynamicValue.extensionId as String?;
      case 'chatExtensionId':
        return dynamicValue.chatExtensionId as String?;
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

IAgentHostConfigurationSync? _agentHostSync(Object? value) {
  if (value == null || identical(value, _jsUndefined)) return null;
  if (value is IAgentHostConfigurationSync) return value;
  final Map<String, Object?>? map = _asStringMap(value);
  if (map == null) return null;
  return IAgentHostConfigurationSync(
    key: map['key'] as String,
    transform: map['transform'] as Object? Function(Object?)?,
    derivedKeys: (map['derivedKeys'] as Map?)
        ?.cast<String, Object? Function(Object?)>(),
    scope: map['scope'] as String?,
  );
}

void _assignOptional(
    Map<String, Object?> target, String key, Object? value) {
  if (identical(value, _jsUndefined)) {
    target.remove(key);
  } else {
    target[key] = value;
  }
}

void _assignFromKey(Map<String, Object?> target, String targetKey,
    Map<String, Object?> source, String sourceKey) {
  if (source.containsKey(sourceKey)) {
    target[targetKey] = source[sourceKey];
  } else {
    target.remove(targetKey);
  }
}

Object? _mapValue(Object? value) =>
    identical(value, _jsUndefined) ? _jsUndefined : value;

class _ConfigurationDefaultOverrides {
  final List<IConfigurationDefaultOverride> configurationDefaultOverrides =
      <IConfigurationDefaultOverride>[];
  IConfigurationDefaultOverrideValue? configurationDefaultOverrideValue;
}

/// 1:1: `class ConfigurationRegistry extends Disposable`
class ConfigurationRegistry extends lifecycle.Disposable
    implements IConfigurationRegistryType {
  final List<IConfigurationDefaults> registeredConfigurationDefaults =
      <IConfigurationDefaults>[];
  final Map<String, _ConfigurationDefaultOverrides>
      configurationDefaultsOverrides =
      <String, _ConfigurationDefaultOverrides>{};

  late final IConfigurationNode defaultLanguageConfigurationOverridesNode;
  late final List<IConfigurationNode> configurationContributors;
  final IStringDictionary<IRegisteredConfigurationPropertySchema>
      configurationProperties =
      <String, IRegisteredConfigurationPropertySchema>{};
  final Map<policy.PolicyName, String> policyConfigurations =
      <policy.PolicyName, String>{};
  final Map<policy.PolicyName, Set<String>> policyReferenceConfigurations =
      <policy.PolicyName, Set<String>>{};
  final Map<String, IAgentHostConfigurationSync> agentHostSyncConfigurations =
      <String, IAgentHostConfigurationSync>{};
  final HashMap<IConfigurationNode, Set<String>> excludedConfigurationKeys =
      HashMap<IConfigurationNode, Set<String>>.identity();
  final IStringDictionary<IRegisteredConfigurationPropertySchema>
      excludedConfigurationProperties =
      <String, IRegisteredConfigurationPropertySchema>{};
  final IJSONSchema resourceLanguageSettingsSchema;
  final Set<String> overrideIdentifiers = <String>{};

  late final event.Emitter<void> _onDidSchemaChange;
  @override
  late final event.Event<void> onDidSchemaChange;

  late final event.Emitter<IConfigurationUpdateConfigurationEvent>
      _onDidUpdateConfiguration;
  @override
  late final event.Event<IConfigurationUpdateConfigurationEvent>
      onDidUpdateConfiguration;

  ConfigurationRegistry()
      : resourceLanguageSettingsSchema = <String, Object?>{
          'properties': <String, Object?>{},
          'patternProperties': <String, Object?>{},
          'additionalProperties': true,
          'allowTrailingCommas': true,
          'allowComments': true,
        } {
    _onDidSchemaChange = register(event.Emitter<void>());
    onDidSchemaChange = _onDidSchemaChange.event;
    _onDidUpdateConfiguration =
        register(event.Emitter<IConfigurationUpdateConfigurationEvent>());
    onDidUpdateConfiguration = _onDidUpdateConfiguration.event;

    defaultLanguageConfigurationOverridesNode = IConfigurationNode(
      id: 'defaultOverrides',
      title: nls.localize('defaultLanguageConfigurationOverrides.title',
          'Default Language Configuration Overrides'),
      properties: <String, IConfigurationPropertySchema>{},
    );
    configurationContributors = <IConfigurationNode>[
      defaultLanguageConfigurationOverridesNode,
    ];

    _contributionRegistry.registerSchema(
        resourceLanguageSettingsSchemaId, resourceLanguageSettingsSchema);
    registerOverridePropertyPatternKey();
  }

  // TS obtains this through `Registry.as(JSONExtensions.JSONContribution)`.
  // The Dart JSON registry is a module-level singleton carrier; using it
  // directly avoids relying on that library's private lazy registration hook.
  jsonContributions.IJSONContributionRegistry get _contributionRegistry =>
      jsonContributions.jsonContributionRegistry;

  @override
  IConfigurationNode registerConfiguration(
    IConfigurationNode configuration, [
    bool validate = true,
  ]) {
    registerConfigurations(<IConfigurationNode>[configuration], validate);
    return configuration;
  }

  @override
  void registerConfigurations(
    List<IConfigurationNode> configurations, [
    bool validate = true,
  ]) {
    final Set<String> properties = <String>{};
    _doRegisterConfigurations(configurations, validate, properties);
    _contributionRegistry.registerSchema(
        resourceLanguageSettingsSchemaId, resourceLanguageSettingsSchema);
    _onDidSchemaChange.fire(null);
    _fireUpdate(properties);
  }

  @override
  void deregisterConfigurations(List<IConfigurationNode> configurations) {
    final Set<String> properties = <String>{};
    _doDeregisterConfigurations(configurations, properties);
    _contributionRegistry.registerSchema(
        resourceLanguageSettingsSchemaId, resourceLanguageSettingsSchema);
    _onDidSchemaChange.fire(null);
    _fireUpdate(properties);
  }

  @override
  void updateConfigurations({
    required List<IConfigurationNode> add,
    required List<IConfigurationNode> remove,
  }) {
    final Set<String> properties = <String>{};
    _doDeregisterConfigurations(remove, properties);
    _doRegisterConfigurations(add, false, properties);
    _contributionRegistry.registerSchema(
        resourceLanguageSettingsSchemaId, resourceLanguageSettingsSchema);
    _onDidSchemaChange.fire(null);
    _fireUpdate(properties);
  }

  @override
  void registerDefaultConfigurations(
      List<IConfigurationDefaults> configurationDefaults) {
    final Set<String> properties = <String>{};
    _doRegisterDefaultConfigurations(configurationDefaults, properties);
    _onDidSchemaChange.fire(null);
    _fireUpdate(properties, defaultsOverrides: true);
  }

  @override
  void deregisterDefaultConfigurations(
      List<IConfigurationDefaults> defaultConfigurations) {
    final Set<String> properties = <String>{};
    _doDeregisterDefaultConfigurations(defaultConfigurations, properties);
    _onDidSchemaChange.fire(null);
    _fireUpdate(properties, defaultsOverrides: true);
  }

  @override
  void deltaConfiguration(IConfigurationDelta delta) {
    bool defaultsOverrides = false;
    final Set<String> properties = <String>{};
    final List<IConfigurationDefaults>? removedDefaults = delta.removedDefaults;
    if (removedDefaults != null) {
      _doDeregisterDefaultConfigurations(removedDefaults, properties);
      defaultsOverrides = true;
    }
    final List<IConfigurationDefaults>? addedDefaults = delta.addedDefaults;
    if (addedDefaults != null) {
      _doRegisterDefaultConfigurations(addedDefaults, properties);
      defaultsOverrides = true;
    }
    final List<IConfigurationNode>? removedConfigurations =
        delta.removedConfigurations;
    if (removedConfigurations != null) {
      _doDeregisterConfigurations(removedConfigurations, properties);
    }
    final List<IConfigurationNode>? addedConfigurations =
        delta.addedConfigurations;
    if (addedConfigurations != null) {
      _doRegisterConfigurations(addedConfigurations, false, properties);
    }
    _onDidSchemaChange.fire(null);
    _fireUpdate(properties, defaultsOverrides: defaultsOverrides);
  }

  void _fireUpdate(Set<String> properties, {Object? defaultsOverrides = _jsUndefined}) {
    _onDidUpdateConfiguration.fire(IConfigurationUpdateConfigurationEvent(
      properties,
      defaultsOverrides,
    ));
  }

  @override
  void notifyConfigurationSchemaUpdated(
      List<IConfigurationNode> configurations) {
    _onDidSchemaChange.fire(null);
  }

  @override
  void registerOverrideIdentifiers(List<String> identifiers) {
    _doRegisterOverrideIdentifiers(identifiers);
    _onDidSchemaChange.fire(null);
  }

  void _doRegisterOverrideIdentifiers(List<String> overrideIdentifiersList) {
    for (final String overrideIdentifier in overrideIdentifiersList) {
      overrideIdentifiers.add(overrideIdentifier);
    }
    _updateOverridePropertyPatternKey();
  }

  @override
  List<IConfigurationNode> getConfigurations() => configurationContributors;

  @override
  IStringDictionary<IRegisteredConfigurationPropertySchema>
      getConfigurationProperties() => configurationProperties;

  @override
  Map<policy.PolicyName, String> getPolicyConfigurations() =>
      policyConfigurations;

  @override
  Map<policy.PolicyName, Set<String>> getPolicyReferenceConfigurations() =>
      policyReferenceConfigurations;

  @override
  Map<String, IAgentHostConfigurationSync> getAgentHostSyncConfigurations() =>
      agentHostSyncConfigurations;

  @override
  IStringDictionary<IRegisteredConfigurationPropertySchema>
      getExcludedConfigurationProperties() => excludedConfigurationProperties;

  @override
  List<IConfigurationDefaults> getRegisteredDefaultConfigurations() =>
      List<IConfigurationDefaults>.of(registeredConfigurationDefaults);

  @override
  Map<String, IConfigurationDefaultOverrideValue>
      getConfigurationDefaultsOverrides() {
    final Map<String, IConfigurationDefaultOverrideValue> result =
        <String, IConfigurationDefaultOverrideValue>{};
    for (final MapEntry<String, _ConfigurationDefaultOverrides> entry
        in configurationDefaultsOverrides.entries) {
      final IConfigurationDefaultOverrideValue? value =
          entry.value.configurationDefaultOverrideValue;
      if (value != null) result[entry.key] = value;
    }
    return result;
  }

  void _doRegisterConfigurations(List<IConfigurationNode> configurations,
      bool validate, Set<String> bucket) {
    for (final IConfigurationNode configuration in configurations) {
      _validateAndRegisterProperties(
        configuration,
        validate,
        configuration.extensionInfo,
        configuration.restrictedProperties,
        ConfigurationScope.WINDOW,
        bucket,
      );
      configurationContributors.add(configuration);
      _registerJSONConfiguration(configuration);
    }
  }

  void _doDeregisterConfigurations(
      List<IConfigurationNode> configurations, Set<String> bucket) {
    void deregisterConfiguration(IConfigurationNode configuration) {
      final Set<String>? excludedKeys =
          excludedConfigurationKeys[configuration];
      if (excludedKeys != null) {
        for (final String key in excludedKeys) {
          bucket.add(key);
          agentHostSyncConfigurations.remove(key);
          final IRegisteredConfigurationPropertySchema? excludedProperty =
              excludedConfigurationProperties[key];
          if (excludedProperty != null &&
              excludedProperty.containsKey('experiment')) {
            excludedConfigurationProperties.remove(key);
          }
        }
        excludedConfigurationKeys.remove(configuration);
      }
      final IStringDictionary<IConfigurationPropertySchema>? properties =
          configuration.properties;
      if (properties != null) {
        for (final String key in properties.keys.toList()) {
          bucket.add(key);
          final IRegisteredConfigurationPropertySchema? property =
              configurationProperties[key];
          final String? policyName = _stringField(
              property == null ? null : property['policy'], 'name');
          if (property != null && policyName != null) {
            policyConfigurations.remove(policyName);
          }
          agentHostSyncConfigurations.remove(key);
          final String? policyReferenceName = _stringField(
              property == null ? null : property['policyReference'], 'name');
          if (property != null && policyReferenceName != null) {
            final Set<String>? refs =
                policyReferenceConfigurations[policyReferenceName];
            if (refs != null) {
              refs.remove(key);
              if (refs.isEmpty) {
                policyReferenceConfigurations.remove(policyReferenceName);
              }
            }
          }
          configurationProperties.remove(key);
          _removeFromSchema(key, properties[key]!);
        }
      }
      final List<IConfigurationNode>? subNodes = configuration.allOf;
      subNodes?.forEach(deregisterConfiguration);
    }

    for (final IConfigurationNode configuration in configurations) {
      deregisterConfiguration(configuration);
      final int index = configurationContributors.indexOf(configuration);
      if (index != -1) configurationContributors.removeAt(index);
    }
  }

  void _validateAndRegisterProperties(
    IConfigurationNode configuration,
    bool validate,
    IExtensionInfo? extensionInfo,
    List<String>? restrictedProperties,
    int scope,
    Set<String> bucket,
  ) {
    final int effectiveScope = configuration.scope == null
        ? scope
        : configuration.scope!;
    final IStringDictionary<IConfigurationPropertySchema>? properties =
        configuration.properties;
    if (properties != null) {
      for (final String key in properties.keys.toList()) {
        final IConfigurationPropertySchema property = properties[key]!;
        property['section'] = <String, Object?>{
          if (configuration.id != null) 'id': configuration.id!,
          if (configuration.title != null) 'title': configuration.title!,
          if (configuration.order != null) 'order': configuration.order!,
          if (configuration.extensionInfo != null)
            'extensionInfo': configuration.extensionInfo!,
        };
        if (validate && _validateProperty(key, property, extensionInfo?.id) != null) {
          properties.remove(key);
          continue;
        }

        _assignOptional(property, 'source', extensionInfo ?? _jsUndefined);
        _assignFromKey(property, 'defaultDefaultValue', property, 'default');
        _updatePropertyDefaultValue(key, property);

        if (OVERRIDE_PROPERTY_REGEX.hasMatch(key)) {
          _assignOptional(property, 'scope', _jsUndefined);
        } else {
          final Object? propertyScope = property['scope'];
          _assignOptional(property, 'scope',
              propertyScope == null ? effectiveScope : propertyScope);
          final Object? restricted = property['restricted'];
          _assignOptional(
            property,
            'restricted',
            restricted == null
                ? (restrictedProperties?.contains(key) ?? false)
                : restricted,
          );
        }

        final Object? experiment = property['experiment'];
        final List<String>? tags = (property['tags'] as List?) == null
            ? null
            : (property['tags'] as List).map((Object? e) => e.toString()).toList();
        final bool hasOnExp = tags?.any(
                (String tag) => tag.toLowerCase() == 'onexp') ??
            false;
        if (experiment != null) {
          if (!hasOnExp) {
            final List<String> updatedTags = tags ?? <String>[];
            updatedTags.add('onExP');
            property['tags'] = updatedTags;
          }
        } else if (hasOnExp) {
          property['experiment'] = <String, Object?>{'mode': 'startup'};
        }

        final bool excluded = property.containsKey('included') &&
            property['included'] == false;
        final String? policyName =
            _stringField(property['policy'], 'name');
        final String? policyReferenceName =
            _stringField(property['policyReference'], 'name');
        final IAgentHostConfigurationSync? agentHostSync =
            _agentHostSync(property['agentHost']);

        if (agentHostSync != null) {
          agentHostSyncConfigurations[key] = agentHostSync;
        }

        if (excluded) {
          excludedConfigurationProperties[key] = property;
          if (policyName != null) {
            policyConfigurations[policyName] = key;
            bucket.add(key);
          }
          if (policyReferenceName != null) {
            _addPolicyReferenceConfiguration(policyReferenceName, key);
            bucket.add(key);
          }
          if (agentHostSync != null || experiment != null) {
            bucket.add(key);
            final Set<String>? excludedKeys =
                excludedConfigurationKeys[configuration];
            if (excludedKeys == null) {
              excludedConfigurationKeys[configuration] = <String>{key};
            } else {
              excludedKeys.add(key);
            }
          }
          properties.remove(key);
        } else {
          bucket.add(key);
          if (policyName != null) policyConfigurations[policyName] = key;
          if (policyReferenceName != null) {
            _addPolicyReferenceConfiguration(policyReferenceName, key);
          }
          configurationProperties[key] = property;
          if (property.containsKey('deprecationMessage') == false &&
              property.containsKey('markdownDeprecationMessage')) {
            _assignFromKey(property, 'deprecationMessage', property,
                'markdownDeprecationMessage');
          }
        }
      }
    }

    final List<IConfigurationNode>? subNodes = configuration.allOf;
    if (subNodes != null) {
      for (final IConfigurationNode node in subNodes) {
        _validateAndRegisterProperties(
          node,
          validate,
          extensionInfo,
          restrictedProperties,
          effectiveScope,
          bucket,
        );
      }
    }
  }

  void _addPolicyReferenceConfiguration(
      policy.PolicyName policyName, String key) {
    final Set<String>? keys = policyReferenceConfigurations[policyName];
    if (keys == null) {
      policyReferenceConfigurations[policyName] = <String>{key};
    } else {
      keys.add(key);
    }
  }

  void _doRegisterDefaultConfigurations(
      List<IConfigurationDefaults> configurationDefaults, Set<String> bucket) {
    registeredConfigurationDefaults.addAll(configurationDefaults);
    final List<String> overrideIdentifiersList = <String>[];

    for (final IConfigurationDefaults configurationDefault
        in configurationDefaults) {
      for (final String key in configurationDefault.overrides.keys) {
        bucket.add(key);
        final _ConfigurationDefaultOverrides overrides =
            configurationDefaultsOverrides.putIfAbsent(
                key, _ConfigurationDefaultOverrides.new);
        final Object? value = configurationDefault.overrides[key];
        overrides.configurationDefaultOverrides.add(
            IConfigurationDefaultOverride(value, configurationDefault.source));

        if (OVERRIDE_PROPERTY_REGEX.hasMatch(key)) {
          final IConfigurationDefaultOverrideValue? newDefaultOverride =
              _mergeDefaultConfigurationsForOverrideIdentifier(
            key,
            value,
            configurationDefault.source,
            overrides.configurationDefaultOverrideValue,
          );
          if (newDefaultOverride == null) continue;
          overrides.configurationDefaultOverrideValue = newDefaultOverride;
          _updateDefaultOverrideProperty(
              key, newDefaultOverride, configurationDefault.source);
          overrideIdentifiersList.addAll(overrideIdentifiersFromKey(key));
        } else {
          final IConfigurationDefaultOverrideValue? newDefaultOverride =
              _mergeDefaultConfigurationsForConfigurationProperty(
            key,
            value,
            configurationDefault.source,
            overrides.configurationDefaultOverrideValue,
          );
          if (newDefaultOverride == null) continue;
          overrides.configurationDefaultOverrideValue = newDefaultOverride;
          final IRegisteredConfigurationPropertySchema? excludedProperty =
              excludedConfigurationProperties[key];
          final IRegisteredConfigurationPropertySchema? property =
              configurationProperties[key] ??
                  ((excludedProperty != null &&
                          excludedProperty.containsKey('experiment'))
                      ? excludedProperty
                      : null);
          if (property != null) {
            _updatePropertyDefaultValue(key, property);
            if (property['included'] != false) _updateSchema(key, property);
          }
        }
      }
    }

    _doRegisterOverrideIdentifiers(overrideIdentifiersList);
  }

  void _doDeregisterDefaultConfigurations(
      List<IConfigurationDefaults> defaultConfigurations, Set<String> bucket) {
    for (final IConfigurationDefaults defaultConfiguration
        in defaultConfigurations) {
      final int index =
          registeredConfigurationDefaults.indexOf(defaultConfiguration);
      if (index != -1) registeredConfigurationDefaults.removeAt(index);
    }

    for (final IConfigurationDefaults defaultConfiguration
        in defaultConfigurations) {
      for (final String key in defaultConfiguration.overrides.keys) {
        final _ConfigurationDefaultOverrides? overrides =
            configurationDefaultsOverrides[key];
        if (overrides == null) continue;

        final Object? source = defaultConfiguration.source;
        final Object? overrideValue = defaultConfiguration.overrides[key];
        int index = -1;
        for (int i = 0;
            i < overrides.configurationDefaultOverrides.length;
            i++) {
          final IConfigurationDefaultOverride candidate =
              overrides.configurationDefaultOverrides[i];
          final bool matches = !identical(source, _jsUndefined) &&
                  source != null
              ? isConfigurationDefaultSourceEquals(candidate.source, source)
              : identical(candidate.value, overrideValue);
          if (matches) {
            index = i;
            break;
          }
        }
        if (index == -1) continue;

        overrides.configurationDefaultOverrides.removeAt(index);
        if (overrides.configurationDefaultOverrides.isEmpty) {
          configurationDefaultsOverrides.remove(key);
        }

        if (OVERRIDE_PROPERTY_REGEX.hasMatch(key)) {
          IConfigurationDefaultOverrideValue? configurationDefaultOverrideValue;
          for (final IConfigurationDefaultOverride value
              in overrides.configurationDefaultOverrides) {
            configurationDefaultOverrideValue =
                _mergeDefaultConfigurationsForOverrideIdentifier(
              key,
              value.value,
              value.source,
              configurationDefaultOverrideValue,
            );
          }
          if (configurationDefaultOverrideValue != null &&
              !types.isEmptyObject(configurationDefaultOverrideValue.value)) {
            overrides.configurationDefaultOverrideValue =
                configurationDefaultOverrideValue;
            _updateDefaultOverrideProperty(
                key, configurationDefaultOverrideValue, source);
          } else {
            configurationDefaultsOverrides.remove(key);
            configurationProperties.remove(key);
            defaultLanguageConfigurationOverridesNode.properties?.remove(key);
          }
        } else {
          IConfigurationDefaultOverrideValue? configurationDefaultOverrideValue;
          for (final IConfigurationDefaultOverride value
              in overrides.configurationDefaultOverrides) {
            configurationDefaultOverrideValue =
                _mergeDefaultConfigurationsForConfigurationProperty(
              key,
              value.value,
              value.source,
              configurationDefaultOverrideValue,
            );
          }
          overrides.configurationDefaultOverrideValue =
              configurationDefaultOverrideValue;
          final IRegisteredConfigurationPropertySchema? excludedProperty =
              excludedConfigurationProperties[key];
          final IRegisteredConfigurationPropertySchema? property =
              configurationProperties[key] ??
                  ((excludedProperty != null &&
                          excludedProperty.containsKey('experiment'))
                      ? excludedProperty
                      : null);
          if (property != null) {
            _updatePropertyDefaultValue(key, property);
            if (property['included'] != false) _updateSchema(key, property);
          }
        }
        bucket.add(key);
      }
    }
    _updateOverridePropertyPatternKey();
  }

  void _updateDefaultOverrideProperty(
    String key,
    IConfigurationDefaultOverrideValue newDefaultOverride,
    ConfigurationDefaultSource source,
  ) {
    final IRegisteredConfigurationPropertySchema property =
        <String, Object?>{
      'section': <String, Object?>{
        'id': defaultLanguageConfigurationOverridesNode.id,
        'title': defaultLanguageConfigurationOverridesNode.title,
        if (defaultLanguageConfigurationOverridesNode.order != null)
          'order': defaultLanguageConfigurationOverridesNode.order!,
        if (defaultLanguageConfigurationOverridesNode.extensionInfo != null)
          'extensionInfo':
              defaultLanguageConfigurationOverridesNode.extensionInfo!,
      },
      'type': 'object',
      'default': newDefaultOverride.value,
      'description': nls.localize(
        'defaultLanguageConfiguration.description',
        'Configure settings to be overridden for {0}.',
        <Object?>[configuration.getLanguageTagSettingPlainKey(key)],
      ),
      r'$ref': resourceLanguageSettingsSchemaId,
      'defaultDefaultValue': newDefaultOverride.value,
    };
    _assignOptional(property, 'source', source);
    _assignOptional(property, 'defaultValueSource', source);
    configurationProperties[key] = property;
    defaultLanguageConfigurationOverridesNode.properties![key] = property;
  }

  IConfigurationDefaultOverrideValue?
      _mergeDefaultConfigurationsForOverrideIdentifier(
    String overrideIdentifier,
    Object? configurationValueObject,
    ConfigurationDefaultSource valueSource,
    IConfigurationDefaultOverrideValue? existingDefaultOverride,
  ) {
    final Map<String, Object?>? sourceMap =
        _asStringMap(existingDefaultOverride?.source);
    IConfigurationDefaultOverrideValue? existing = existingDefaultOverride;
    if (existing != null) {
      final Map<String, Object?>? check = _asStringMap(existing.source);
      if (check == null && !identical(existing.source, _jsUndefined)) {
        return null;
      }
    }
    final Map<String, Object?> defaultValue =
        existing?.value is Map<String, Object?>
            ? (existing!.value as Map<String, Object?>)
            : <String, Object?>{};
    final Map<String, Object?> source = sourceMap ?? <String, Object?>{};

    final Map<String, Object?>? values =
        _asStringMap(configurationValueObject);
    if (values == null) {
      return IConfigurationDefaultOverrideValue(defaultValue, source);
    }
    for (final String propertyKey in values.keys) {
      final Object? propertyDefaultValue = values[propertyKey];
      final bool isObjectSetting = types.isObject(propertyDefaultValue) &&
          (!defaultValue.containsKey(propertyKey) ||
              types.isObject(defaultValue[propertyKey]));
      if (isObjectSetting) {
        final Map<String, Object?> old =
            _asStringMap(defaultValue[propertyKey]) ?? <String, Object?>{};
        final Map<String, Object?> incoming =
            _asStringMap(propertyDefaultValue) ?? <String, Object?>{};
        final Map<String, Object?> merged = <String, Object?>{...old, ...incoming};
        defaultValue[propertyKey] = merged;
        if (!identical(valueSource, _jsUndefined) && valueSource != null) {
          for (final String objectKey in incoming.keys) {
            source['$propertyKey.$objectKey'] = valueSource;
          }
        }
      } else {
        defaultValue[propertyKey] = propertyDefaultValue;
        if (!identical(valueSource, _jsUndefined) && valueSource != null) {
          source[propertyKey] = valueSource;
        } else {
          source.remove(propertyKey);
        }
      }
    }
    return IConfigurationDefaultOverrideValue(defaultValue, source);
  }

  IConfigurationDefaultOverrideValue?
      _mergeDefaultConfigurationsForConfigurationProperty(
    String propertyKey,
    Object? value,
    ConfigurationDefaultSource valuesSource,
    IConfigurationDefaultOverrideValue? existingDefaultOverride,
  ) {
    final IRegisteredConfigurationPropertySchema? excludedProperty =
        excludedConfigurationProperties[propertyKey];
    final IRegisteredConfigurationPropertySchema? property =
        configurationProperties[propertyKey] ??
            ((excludedProperty != null &&
                    excludedProperty.containsKey('experiment'))
                ? excludedProperty
                : null);
    final Object? existingDefaultValue = existingDefaultOverride != null
        ? existingDefaultOverride.value
        : (property != null && property.containsKey('defaultDefaultValue'))
            ? property['defaultDefaultValue']
            : _jsUndefined;
    ConfigurationDefaultValueSource source = valuesSource;

    final bool isObjectSetting = types.isObject(value) &&
        ((property != null && property['type'] == 'object') ||
            (property == null && identical(existingDefaultValue, _jsUndefined)));

    if (isObjectSetting) {
      final Map<String, Object?>? existingSource =
          _asStringMap(existingDefaultOverride?.source);
      if (existingSource == null &&
          existingDefaultOverride != null &&
          !identical(existingDefaultOverride.source, _jsUndefined)) {
        return null;
      }
      source = existingSource ?? <String, Object?>{};
      final Map<String, Object?> incoming = _asStringMap(value)!;
      if (!identical(valuesSource, _jsUndefined) && valuesSource != null) {
        for (final String objectKey in incoming.keys) {
          (source as Map<String, Object?>)['$propertyKey.$objectKey'] =
              valuesSource;
        }
      }
      final Map<String, Object?>? existingObjectMap =
          types.isObject(existingDefaultValue)
              ? _asStringMap(existingDefaultValue)
              : <String, Object?>{};
      final Map<String, Object?> existingObject =
          existingObjectMap ?? <String, Object?>{};
      value = <String, Object?>{...existingObject, ...incoming};
    }

    return IConfigurationDefaultOverrideValue(value, source);
  }

  void _registerJSONConfiguration(IConfigurationNode configuration) {
    void register(IConfigurationNode configuration) {
      final IStringDictionary<IConfigurationPropertySchema>? properties =
          configuration.properties;
      if (properties != null) {
        for (final String key in properties.keys) {
          _updateSchema(key, properties[key]!);
        }
      }
      configuration.allOf?.forEach(register);
    }

    register(configuration);
  }

  void _updateSchema(
      String key, IConfigurationPropertySchema property) {
    allSettings.properties[key] = property;
    final Object? scopeValue = property['scope'];
    if (scopeValue is! int) return;
    switch (scopeValue) {
      case ConfigurationScope.APPLICATION:
        applicationSettings.properties[key] = property;
        break;
      case ConfigurationScope.MACHINE:
        machineSettings.properties[key] = property;
        break;
      case ConfigurationScope.APPLICATION_MACHINE:
        applicationMachineSettings.properties[key] = property;
        break;
      case ConfigurationScope.MACHINE_OVERRIDABLE:
        machineOverridableSettings.properties[key] = property;
        break;
      case ConfigurationScope.WINDOW:
        windowSettings.properties[key] = property;
        break;
      case ConfigurationScope.RESOURCE:
        resourceSettings.properties[key] = property;
        break;
      case ConfigurationScope.LANGUAGE_OVERRIDABLE:
        resourceSettings.properties[key] = property;
        (resourceLanguageSettingsSchema['properties'] as Map<String, Object?>)[key] =
            property;
        break;
    }
  }

  void _removeFromSchema(String key, IConfigurationPropertySchema property) {
    allSettings.properties.remove(key);
    final Object? scopeValue = property['scope'];
    if (scopeValue is! int) return;
    switch (scopeValue) {
      case ConfigurationScope.APPLICATION:
        applicationSettings.properties.remove(key);
        break;
      case ConfigurationScope.MACHINE:
        machineSettings.properties.remove(key);
        break;
      case ConfigurationScope.APPLICATION_MACHINE:
        applicationMachineSettings.properties.remove(key);
        break;
      case ConfigurationScope.MACHINE_OVERRIDABLE:
        machineOverridableSettings.properties.remove(key);
        break;
      case ConfigurationScope.WINDOW:
        windowSettings.properties.remove(key);
        break;
      case ConfigurationScope.RESOURCE:
      case ConfigurationScope.LANGUAGE_OVERRIDABLE:
        resourceSettings.properties.remove(key);
        (resourceLanguageSettingsSchema['properties'] as Map<String, Object?>)
            .remove(key);
        break;
    }
  }

  void _updateOverridePropertyPatternKey() {
    for (final String overrideIdentifier in overrideIdentifiers) {
      final String overrideIdentifierProperty = '[$overrideIdentifier]';
      final IJSONSchema resourceLanguagePropertiesSchema = <String, Object?>{
        'type': 'object',
        'description': nls.localize('overrideSettings.defaultDescription',
            'Configure editor settings to be overridden for a language.'),
        'errorMessage': nls.localize('overrideSettings.errorMessage',
            'This setting does not support per-language configuration.'),
        r'$ref': resourceLanguageSettingsSchemaId,
      };
      _updatePropertyDefaultValue(
          overrideIdentifierProperty, resourceLanguagePropertiesSchema);
      allSettings.properties[overrideIdentifierProperty] =
          resourceLanguagePropertiesSchema;
      applicationSettings.properties[overrideIdentifierProperty] =
          resourceLanguagePropertiesSchema;
      applicationMachineSettings.properties[overrideIdentifierProperty] =
          resourceLanguagePropertiesSchema;
      machineSettings.properties[overrideIdentifierProperty] =
          resourceLanguagePropertiesSchema;
      machineOverridableSettings.properties[overrideIdentifierProperty] =
          resourceLanguagePropertiesSchema;
      windowSettings.properties[overrideIdentifierProperty] =
          resourceLanguagePropertiesSchema;
      resourceSettings.properties[overrideIdentifierProperty] =
          resourceLanguagePropertiesSchema;
    }
  }

  void registerOverridePropertyPatternKey() {
    final IJSONSchema resourceLanguagePropertiesSchema = <String, Object?>{
      'type': 'object',
      'description': nls.localize('overrideSettings.defaultDescription',
          'Configure editor settings to be overridden for a language.'),
      'errorMessage': nls.localize('overrideSettings.errorMessage',
          'This setting does not support per-language configuration.'),
      r'$ref': resourceLanguageSettingsSchemaId,
    };
    allSettings.patternProperties[OVERRIDE_PROPERTY_PATTERN] =
        resourceLanguagePropertiesSchema;
    applicationSettings.patternProperties[OVERRIDE_PROPERTY_PATTERN] =
        resourceLanguagePropertiesSchema;
    applicationMachineSettings.patternProperties[OVERRIDE_PROPERTY_PATTERN] =
        resourceLanguagePropertiesSchema;
    machineSettings.patternProperties[OVERRIDE_PROPERTY_PATTERN] =
        resourceLanguagePropertiesSchema;
    machineOverridableSettings.patternProperties[OVERRIDE_PROPERTY_PATTERN] =
        resourceLanguagePropertiesSchema;
    windowSettings.patternProperties[OVERRIDE_PROPERTY_PATTERN] =
        resourceLanguagePropertiesSchema;
    resourceSettings.patternProperties[OVERRIDE_PROPERTY_PATTERN] =
        resourceLanguagePropertiesSchema;
    _onDidSchemaChange.fire(null);
  }

  void _updatePropertyDefaultValue(
      String key, IRegisteredConfigurationPropertySchema property) {
    final IConfigurationDefaultOverrideValue? configurationDefaultOverride =
        configurationDefaultsOverrides[key]?.configurationDefaultOverrideValue;
    Object? defaultValue = _jsUndefined;
    Object? defaultSource = _jsUndefined;
    if (configurationDefaultOverride != null &&
        (property['disallowConfigurationDefault'] != true ||
            configurationDefaultOverride.source == _jsUndefined)) {
      defaultValue = configurationDefaultOverride.value;
      defaultSource = configurationDefaultOverride.source;
    }
    if (identical(defaultValue, _jsUndefined)) {
      defaultValue = property.containsKey('defaultDefaultValue')
          ? property['defaultDefaultValue']
          : _jsUndefined;
      defaultSource = _jsUndefined;
    }
    if (identical(defaultValue, _jsUndefined)) {
      defaultValue = getDefaultValue(property['type']);
    }
    property['default'] = defaultValue;
    _assignOptional(property, 'defaultValueSource', defaultSource);
  }

  /// 1:1: `validateProperty`, but bound to this registry instance.
  String? _validateProperty(
    String property,
    IRegisteredConfigurationPropertySchema schema, [
    String? extensionId,
  ]) {
    if (property.trim().isEmpty) {
      return nls.localize(
          'config.property.empty', 'Cannot register an empty property');
    }
    if (OVERRIDE_PROPERTY_REGEX.hasMatch(property)) {
      return nls.localize(
        'config.property.languageDefault',
        "Cannot register '{0}'. This matches property pattern '\\\\[.*\\\\]\$' for describing language specific editor settings. Use 'configurationDefaults' contribution.",
        <Object?>[property],
      );
    }
    if (configurationProperties[property] != null &&
        (extensionId == null ||
            !EXTENSION_UNIFICATION_EXTENSION_IDS
                .contains(extensionId.toLowerCase()))) {
      return nls.localize(
        'config.property.duplicate',
        "Cannot register '{0}'. This property is already registered.",
        <Object?>[property],
      );
    }
    final String? schemaPolicyName = _stringField(schema['policy'], 'name');
    if (schemaPolicyName != null) {
      final String? policyReferenceName =
          _stringField(schema['policyReference'], 'name');
      if (policyReferenceName != null) {
        return nls.localize(
          'config.policy.bothPolicyAndReference',
          "Cannot register '{0}'. A setting must not declare both 'policy' and 'policyReference'.",
          <Object?>[property],
        );
      }
      final String? existing = policyConfigurations[schemaPolicyName];
      if (existing != null) {
        return nls.localize(
          'config.policy.duplicate',
          "Cannot register '{0}'. The associated policy {1} is already registered with {2}. To attach another setting to the same policy, use 'policyReference'.",
          <Object?>[property, schemaPolicyName, existing],
        );
      }
    }
    final IAgentHostConfigurationSync? agentHostSync =
        _agentHostSync(schema['agentHost']);
    if (agentHostSync != null) {
      for (final MapEntry<String, IAgentHostConfigurationSync> entry
          in agentHostSyncConfigurations.entries) {
        if (entry.value.key == agentHostSync.key && entry.key != property) {
          return nls.localize(
            'config.agentHost.duplicate',
            "Cannot register '{0}'. The agent host configuration key '{1}' is already mirrored from '{2}'.",
            <Object?>[property, agentHostSync.key, entry.key],
          );
        }
      }
    }
    return null;
  }
}

/// 1:1: `const configurationRegistry = new ConfigurationRegistry()`
final ConfigurationRegistry configurationRegistry = ConfigurationRegistry();

// ignore: unused_element
final Object? _globalRegistryRegistration = () {
  platformRegistry.Registry.add(Extensions.Configuration, configurationRegistry);
  return null;
}();

Object? _readProductField(Object? productValue, String field) {
  final Map<String, Object?>? map = _asStringMap(productValue);
  if (map != null) return map[field];
  return _stringField(productValue, field);
}

/// 1:1: `export const EXTENSION_UNIFICATION_EXTENSION_IDS`
final Set<String> EXTENSION_UNIFICATION_EXTENSION_IDS = () {
  final Object? defaultChatAgent = _readProductField(product.product, 'defaultChatAgent');
  if (defaultChatAgent == null) return <String>{};
  final Object? extensionId =
      _readProductField(defaultChatAgent, 'extensionId');
  final Object? chatExtensionId =
      _readProductField(defaultChatAgent, 'chatExtensionId');
  final List<String> ids = <String>[];
  if (extensionId is String) ids.add(extensionId.toLowerCase());
  if (chatExtensionId is String) ids.add(chatExtensionId.toLowerCase());
  return ids.toSet();
}();

/// 1:1: `export function validateProperty`
String? validateProperty(
  String property,
  IRegisteredConfigurationPropertySchema schema, [
  String? extensionId,
]) =>
    configurationRegistry._validateProperty(property, schema, extensionId);

/// 1:1: `export function getScopes`
List<List<Object?>> getScopes() {
  final List<List<Object?>> scopes = <List<Object?>>[];
  final IStringDictionary<IRegisteredConfigurationPropertySchema>
      configurationProperties = configurationRegistry.getConfigurationProperties();
  for (final String key in configurationProperties.keys) {
    scopes.add(<Object?>[key, configurationProperties[key]!['scope']]);
  }
  scopes.add(<Object?>['launch', ConfigurationScope.RESOURCE]);
  scopes.add(<Object?>['task', ConfigurationScope.RESOURCE]);
  return scopes;
}
