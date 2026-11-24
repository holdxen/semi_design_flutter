// 1:1 translation of vscode/src/vs/platform/configuration/common/configurations.ts
//
// Adaptations (documented inline where non-trivial):
//   - Structural object literals -> carrier classes / Map<String, Object?>.
//   - TS `protected` members stay public so cross-library tests can subclass.
//   - JS `undefined` is mapped to Dart `null`; the local [_jsUndefined] sentinel
//     is only used where a value must be distinguished from an explicit null.
//   - `Registry.as` may fall back to the ported global registry because Dart
//     top-level lazy initialization does not necessarily run the TS-style
//     module registration side effect before first use.
import '../../../base/common/errors.dart' as errors;
import '../../../base/common/event.dart' as event;
import '../../../base/common/json.dart' as json;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/objects.dart' as objects;
import '../../../base/common/policy.dart' as base_policy;
import '../../../base/common/types.dart' as types;
import '../../log/common/log.dart' as log;
import '../../policy/common/policy.dart' as policy;
import '../../registry/common/platform.dart' as platform_registry;
import 'configurationModels.dart' as models;
import 'configurationRegistry.dart' as registry;

/// JS `undefined` carrier for map lookups (`!== undefined` in TS).
final Object _jsUndefined = Object();

/// 1:1: payload of `Emitter<{ defaults: ConfigurationModel; properties: string[] }>`.
class DefaultConfigurationChange {
  final models.ConfigurationModel defaults;
  final List<String> properties;

  DefaultConfigurationChange(this.defaults, this.properties);
}

/// 1:1: `export interface IPolicyConfiguration`.
abstract class IPolicyConfiguration {
  event.Event<models.ConfigurationModel> get onDidChangeConfiguration;
  models.ConfigurationModel get configurationModel;
  Future<models.ConfigurationModel> initialize();
}

/// 1:1: `type ParsedType = IStringDictionary<unknown> | Array<unknown>`.
typedef ParsedType = Object?;

/// TS module-level `Registry.as<IConfigurationRegistry>(Extensions.Configuration)`.
registry.IConfigurationRegistryType _configurationRegistry() {
  final Object? registered =
      platform_registry.Registry.as(registry.Extensions.Configuration);
  if (registered is registry.IConfigurationRegistryType) return registered;
  // Dart adaptation: the TS module registration hook is lazily initialized.
  return registry.configurationRegistry;
}

Map<String, Object?> _asStringMap(Object? value) {
  if (value == null) return <String, Object?>{};
  if (value is Map<String, Object?>) return value;
  return (value as Map).map(
    (Object? key, Object? value) =>
        MapEntry<String, Object?>(key as String, value),
  );
}

Object? _mapValue(Object? config, String key) {
  if (config is Map<String, Object?>) return config[key];
  if (config is Map) return config[key];
  return null;
}

String? _policyNameFrom(Object? config) {
  final Object? direct = _mapValue(config, 'policy');
  final Object? directName = _mapValue(direct, 'name');
  if (directName is String) return directName;
  final Object? reference = _mapValue(config, 'policyReference');
  final Object? referenceName = _mapValue(reference, 'name');
  return referenceName is String ? referenceName : null;
}

String _jsTypeText(Object? value) {
  if (value == null || identical(value, _jsUndefined)) return 'undefined';
  if (value is List) {
    // JS Array#toString: a single element stringifies as the element itself.
    if (value.length == 1) return _jsTypeText(value.first);
    return value.map(_jsTypeText).join(',');
  }
  return value.toString();
}

/// 1:1: `export class DefaultConfiguration extends Disposable`.
class DefaultConfiguration extends lifecycle.Disposable {
  late final event.Emitter<DefaultConfigurationChange>
      _onDidChangeConfiguration;
  late final event.Event<DefaultConfigurationChange> onDidChangeConfiguration;

  /// TS `private readonly logService`.
  final log.ILogServiceType logService;

  late models.ConfigurationModel _configurationModel;

  DefaultConfiguration(this.logService) : super() {
    _onDidChangeConfiguration =
        register(event.Emitter<DefaultConfigurationChange>());
    onDidChangeConfiguration = _onDidChangeConfiguration.event;
    _configurationModel =
        models.ConfigurationModel.createEmptyModel(logService);
  }

  /// 1:1: `get configurationModel(): ConfigurationModel`.
  models.ConfigurationModel get configurationModel => _configurationModel;

  /// 1:1: `async initialize(): Promise<ConfigurationModel>`.
  Future<models.ConfigurationModel> initialize() async {
    resetConfigurationModel();
    _configurationRegistry().onDidUpdateConfiguration((dynamic e) {
      final update = e as registry.IConfigurationUpdateConfigurationEvent;
      final Object? defaultsOverrides = update.defaultsOverrides;
      onDidUpdateConfiguration(
        update.properties.toList(),
        defaultsOverrides is bool ? defaultsOverrides : null,
      );
    });
    return configurationModel;
  }

  /// 1:1: `reload(): ConfigurationModel`.
  models.ConfigurationModel reload() {
    resetConfigurationModel();
    return configurationModel;
  }

  /// 1:1: `protected onDidUpdateConfiguration(...)`.
  void onDidUpdateConfiguration(List<String> properties,
      [bool? defaultsOverrides]) {
    updateConfigurationModel(properties, getConfigurationProperties());
    _onDidChangeConfiguration
        .fire(DefaultConfigurationChange(configurationModel, properties));
  }

  /// 1:1: `protected getConfigurationDefaultOverrides()`.
  Map<String, Object?> getConfigurationDefaultOverrides() =>
      <String, Object?>{};

  /// 1:1: `private resetConfigurationModel()`.
  void resetConfigurationModel() {
    _configurationModel =
        models.ConfigurationModel.createEmptyModel(logService);
    final properties = getConfigurationProperties();
    updateConfigurationModel(properties.keys.toList(), properties);
  }

  /// 1:1: `private getConfigurationProperties()`.
  Map<String, registry.IRegisteredConfigurationPropertySchema>
      getConfigurationProperties() {
    final reg = _configurationRegistry();
    final Map<String, registry.IRegisteredConfigurationPropertySchema>
        properties = <String, registry.IRegisteredConfigurationPropertySchema>{
      ...reg.getConfigurationProperties(),
    };
    // Hidden experimental settings need defaults and change events too.
    for (final MapEntry<String, registry.IRegisteredConfigurationPropertySchema>
        entry in reg.getExcludedConfigurationProperties().entries) {
      if (_mapValue(entry.value, 'experiment') != null) {
        properties[entry.key] = entry.value;
      }
    }
    return properties;
  }

  /// 1:1: `private updateConfigurationModel(...)`.
  void updateConfigurationModel(
    List<String> properties,
    Map<String, registry.IRegisteredConfigurationPropertySchema>
        configurationProperties,
  ) {
    final Map<String, Object?> configurationDefaultsOverrides =
        getConfigurationDefaultOverrides();
    for (final String key in properties) {
      final Object? defaultOverrideValue = configurationDefaultsOverrides
          .containsKey(key)
          ? configurationDefaultsOverrides[key]
          : _jsUndefined;
      final Object? propertySchema = configurationProperties[key];
      if (!identical(defaultOverrideValue, _jsUndefined)) {
        _configurationModel.setValue(key, defaultOverrideValue);
      } else if (propertySchema != null) {
        _configurationModel.setValue(
            key, getDefaultValue(key, _asStringMap(propertySchema)));
      } else {
        _configurationModel.removeValue(key);
      }
    }
  }

  /// 1:1: `protected getDefaultValue(...)`.
  Object? getDefaultValue(
      String key, registry.IRegisteredConfigurationPropertySchema propertySchema) {
    return objects.deepClone(propertySchema['default']);
  }
}

/// 1:1: `export class NullPolicyConfiguration implements IPolicyConfiguration`.
class NullPolicyConfiguration implements IPolicyConfiguration {
  @override
  final event.Event<models.ConfigurationModel> onDidChangeConfiguration =
      event.eventNone;

  @override
  final models.ConfigurationModel configurationModel =
      models.ConfigurationModel.createEmptyModel(log.NullLogService());

  @override
  Future<models.ConfigurationModel> initialize() async => configurationModel;
}

/// 1:1: one entry of the TS `changed: [string, unknown][]`.
class _PolicyChange {
  final String key;
  final Object? value;
  final bool remove;

  _PolicyChange(this.key, this.value, this.remove);
}

/// 1:1: `export class PolicyConfiguration extends Disposable implements IPolicyConfiguration`.
class PolicyConfiguration extends lifecycle.Disposable
    implements IPolicyConfiguration {
  late final event.Emitter<models.ConfigurationModel> _onDidChangeConfiguration;
  @override
  late final event.Event<models.ConfigurationModel> onDidChangeConfiguration;

  /// TS `private readonly configurationRegistry`.
  late final registry.IConfigurationRegistryType configurationRegistry;

  /// TS `private readonly defaultConfiguration`.
  final DefaultConfiguration defaultConfiguration;

  /// TS `private readonly policyService`.
  final policy.IPolicyServiceType policyService;

  /// TS `private readonly logService`.
  final log.ILogServiceType logService;

  late models.ConfigurationModel _configurationModel;

  /// TS `private readonly _submittedPolicyDefinitions`.
  final Map<base_policy.PolicyName, policy.PolicyDefinition>
      _submittedPolicyDefinitions =
      <base_policy.PolicyName, policy.PolicyDefinition>{};

  /// TS `private readonly _policyNameByKey`.
  final Map<String, base_policy.PolicyName> _policyNameByKey =
      <String, base_policy.PolicyName>{};

  PolicyConfiguration(
    this.defaultConfiguration,
    this.policyService,
    this.logService,
  ) : super() {
    _onDidChangeConfiguration =
        register(event.Emitter<models.ConfigurationModel>());
    onDidChangeConfiguration = _onDidChangeConfiguration.event;
    _configurationModel =
        models.ConfigurationModel.createEmptyModel(logService);
    configurationRegistry = _configurationRegistry();
  }

  /// 1:1: `get configurationModel(): ConfigurationModel`.
  @override
  models.ConfigurationModel get configurationModel => _configurationModel;

  /// 1:1: `async initialize(): Promise<ConfigurationModel>`.
  @override
  Future<models.ConfigurationModel> initialize() async {
    logService.trace('PolicyConfiguration#initialize');

    update(
      await updatePolicyDefinitions(<String>[
        ...defaultConfiguration.configurationModel.keys,
        ...configurationRegistry.getExcludedConfigurationProperties().keys,
      ]),
      false,
    );
    register(policyService.onDidChange((dynamic names) {
      onDidChangePolicies(List<base_policy.PolicyName>.from(names as List));
    }));
    register(defaultConfiguration.onDidChangeConfiguration((dynamic e) async {
      final change = e as DefaultConfigurationChange;
      update(await updatePolicyDefinitions(change.properties), true);
    }));
    return _configurationModel;
  }

  /// 1:1: `private toPolicyDefinitionType(...)`.
  String? toPolicyDefinitionType(Object? configType, base_policy.PolicyName policyName) {
    final List<Object?> configTypes = configType is List
        ? List<Object?>.from(configType)
        : <Object?>[configType];
    final List<Object?> supportedTypes = configTypes
        .where((Object? type) =>
            type == 'string' ||
            type == 'number' ||
            type == 'array' ||
            type == 'object' ||
            type == 'boolean')
        .toList();
    if (supportedTypes.isEmpty) {
      logService.warn(
        "PolicyConfiguration#updatePolicyDefinitions - policy '$policyName' has unsupported type '${_jsTypeText(configType)}'",
      );
      return null;
    }
    if (supportedTypes.contains('number')) return 'number';
    if (supportedTypes.contains('boolean')) return 'boolean';
    return 'string';
  }

  /// 1:1: `private async updatePolicyDefinitions(properties)`.
  Future<List<String>> updatePolicyDefinitions(List<String> properties) async {
    logService.trace(
        'PolicyConfiguration#updatePolicyDefinitions', properties);
    final List<String> keys = <String>[];
    final Set<base_policy.PolicyName> policyNames = <base_policy.PolicyName>{};
    final Map<String, registry.IRegisteredConfigurationPropertySchema>
        configurationProperties =
        configurationRegistry.getConfigurationProperties();
    final Map<String, registry.IRegisteredConfigurationPropertySchema>
        excludedConfigurationProperties =
        configurationRegistry.getExcludedConfigurationProperties();

    for (final String key in properties) {
      final Object? config =
          configurationProperties[key] ?? excludedConfigurationProperties[key];
      if (config == null) {
        keys.add(key); // deregistered — update() will clear this key's value
        final base_policy.PolicyName? removedPolicyName = _policyNameByKey.remove(key);
        if (removedPolicyName != null) policyNames.add(removedPolicyName);
        continue;
      }
      final base_policy.PolicyName? policyName = _policyNameFrom(config);
      if (policyName != null) {
        keys.add(key);
        policyNames.add(policyName);
        _policyNameByKey[key] = policyName;
      }
    }

    final Map<String, policy.PolicyDefinition> changedDefinitions =
        <String, policy.PolicyDefinition>{};
    for (final base_policy.PolicyName policyName in policyNames) {
      final policy.PolicyDefinition? definition =
          resolvePolicyDefinition(policyName);
      if (definition != null &&
          !isSamePolicyDefinition(
              _submittedPolicyDefinitions[policyName], definition)) {
        _submittedPolicyDefinitions[policyName] = definition;
        changedDefinitions[policyName] = definition;
      }
    }

    if (!types.isEmptyObject(changedDefinitions)) {
      await policyService.updatePolicyDefinitions(changedDefinitions);
    }

    return keys;
  }

  /// 1:1: `private isSamePolicyDefinition(a, b)`.
  bool isSamePolicyDefinition(
      policy.PolicyDefinition? a, policy.PolicyDefinition b) {
    return a != null &&
        a.type == b.type &&
        a.value == b.value &&
        a.managedSettings == b.managedSettings &&
        a.restrictedValue == b.restrictedValue;
  }

  /// 1:1: `private resolvePolicyDefinition(policyName)`.
  policy.PolicyDefinition? resolvePolicyDefinition(base_policy.PolicyName policyName) {
    final Map<String, registry.IRegisteredConfigurationPropertySchema>
        configurationProperties =
        configurationRegistry.getConfigurationProperties();
    final Map<String, registry.IRegisteredConfigurationPropertySchema>
        excludedConfigurationProperties =
        configurationRegistry.getExcludedConfigurationProperties();

    final String? ownerKey =
        configurationRegistry.getPolicyConfigurations()[policyName];
    if (ownerKey != null) {
      final Object? config =
          configurationProperties[ownerKey] ?? excludedConfigurationProperties[ownerKey];
      final Object? definition = _mapValue(config, 'policy');
      if (definition != null) {
        final String? type = toPolicyDefinitionType(_mapValue(config, 'type'), policyName);
        if (type != null) {
          return policy.PolicyDefinition(
            type: type,
            value: _asPolicyValueFunction(_mapValue(definition, 'value')),
            managedSettings: _mapValue(definition, 'managedSettings'),
            restrictedValue: _mapValue(definition, 'restrictedValue'),
          );
        }
      }
    }

    final Set<String>? referenceKeys =
        configurationRegistry.getPolicyReferenceConfigurations()[policyName];
    for (final String referenceKey in referenceKeys ?? <String>{}) {
      final Object? config =
          configurationProperties[referenceKey] ??
              excludedConfigurationProperties[referenceKey];
      if (_mapValue(config, 'policyReference') != null) {
        final String? type =
            toPolicyDefinitionType(_mapValue(config, 'type'), policyName);
        return type == null ? null : policy.PolicyDefinition(type: type);
      }
    }

    return null;
  }

  policy.PolicyValue? Function(Object?)? _asPolicyValueFunction(Object? value) =>
      value is policy.PolicyValue? Function(Object?) ? value : null;

  /// 1:1: `private onDidChangePolicies(policyNames)`.
  void onDidChangePolicies(List<base_policy.PolicyName> policyNames) {
    logService.trace('PolicyConfiguration#onDidChangePolicies', policyNames);
    final Map<base_policy.PolicyName, String> policyConfigurations =
        configurationRegistry.getPolicyConfigurations();
    final Map<base_policy.PolicyName, Set<String>> policyReferenceConfigurations =
        configurationRegistry.getPolicyReferenceConfigurations();
    final List<String> keys = <String>[];
    for (final base_policy.PolicyName policyName in policyNames) {
      final String? owner = policyConfigurations[policyName];
      if (owner != null) keys.add(owner);
      final Set<String>? references =
          policyReferenceConfigurations[policyName];
      if (references != null) keys.addAll(references);
    }
    update(keys, true);
  }

  /// 1:1: `private update(keys, trigger)`.
  void update(List<String> keys, bool trigger) {
    logService.trace('PolicyConfiguration#update', keys);
    final Map<String, registry.IRegisteredConfigurationPropertySchema>
        configurationProperties =
        configurationRegistry.getConfigurationProperties();
    final Map<String, registry.IRegisteredConfigurationPropertySchema>
        excludedConfigurationProperties =
        configurationRegistry.getExcludedConfigurationProperties();
    final List<_PolicyChange> changed = <_PolicyChange>[];
    final bool wasEmpty = _configurationModel.isEmpty();

    for (final String key in keys) {
      final Object? property =
          configurationProperties[key] ?? excludedConfigurationProperties[key];
      final base_policy.PolicyName? policyName = _policyNameFrom(property);
      if (policyName != null) {
        Object? policyValue = policyService.getPolicyValue(policyName);
        final Object? propertyType = _mapValue(property, 'type');
        final bool acceptsStringType = propertyType is List
            ? propertyType.contains('string')
            : propertyType == 'string';
        if (types.isString(policyValue) && !acceptsStringType) {
          try {
            policyValue = parse(policyValue as String);
          } catch (e) {
            logService.error(
              'Error parsing policy value $policyName:',
              <Object?>[errors.getErrorMessage(e)],
            );
            continue;
          }
        }
        final Object? currentValue = _configurationModel.getValue(key);
        final bool shouldChange = wasEmpty
            ? policyValue != null
            : !objects.equals(currentValue, policyValue);
        if (shouldChange) {
          changed.add(_PolicyChange(key, policyValue, false));
        }
      } else {
        if (_configurationModel.getValue(key) != null) {
          changed.add(_PolicyChange(key, null, true));
        }
      }
    }

    if (changed.isNotEmpty) {
      logService.trace(
        'PolicyConfiguration#changed',
        <Object?>[
          for (final _PolicyChange c in changed)
            <Object?>[c.key, c.remove ? _jsUndefined : c.value],
        ],
      );
      final models.ConfigurationModel old = _configurationModel;
      _configurationModel =
          models.ConfigurationModel.createEmptyModel(logService);
      for (final String key in old.keys) {
        _configurationModel.setValue(key, old.getValue(key));
      }
      for (final _PolicyChange c in changed) {
        if (c.remove) {
          _configurationModel.removeValue(c.key);
        } else {
          _configurationModel.setValue(c.key, c.value);
        }
      }
      if (trigger) {
        _onDidChangeConfiguration.fire(_configurationModel);
      }
    }
  }

  /// 1:1: `private parse(content): ParsedType`.
  ParsedType parse(String content) {
    ParsedType raw = <String, Object?>{};
    String? currentProperty;
    Object currentParent = <Object?>[];
    final List<Object> previousParents = <Object>[];
    final List<json.ParseError> parseErrors = <json.ParseError>[];

    void onValue(Object? value) {
      if (currentParent is List) {
        final List parent = currentParent as List;
        parent.add(value);
      } else if (currentProperty != null) {
        final Map<String, Object?> object = currentParent as Map<String, Object?>;
        if (object.containsKey(currentProperty)) {
          throw errors.BugIndicatingError(
              'Duplicate property found: $currentProperty');
        }
        json.setObjectProperty(object, currentProperty!, value);
      }
    }

    final json.JSONVisitor visitor = json.JSONVisitor(
      onObjectBegin: (int offset, int length) {
        final Map<String, Object?> object = <String, Object?>{};
        onValue(object);
        previousParents.add(currentParent);
        currentParent = object;
        currentProperty = null;
      },
      onObjectProperty: (Object? name, int offset, int length) {
        currentProperty = name as String?;
      },
      onObjectEnd: (int offset, int length) {
        currentParent = previousParents.removeLast();
      },
      onArrayBegin: (int offset, int length) {
        final List<Object?> array = <Object?>[];
        onValue(array);
        previousParents.add(currentParent);
        currentParent = array;
        currentProperty = null;
      },
      onArrayEnd: (int offset, int length) {
        currentParent = previousParents.removeLast();
      },
      onLiteralValue: (Object? value, int offset, int length) {
        onValue(value);
      },
      onError: (Object? error, int offset, int length) {
        parseErrors.add(
          json.ParseError(error is int ? error : 0, offset, length),
        );
      },
    );

    if (content.isNotEmpty) {
      json.visit(content, visitor);
      final List<Object?> stack = currentParent as List<Object?>;
      final Object? first = stack.isEmpty ? null : stack.first;
      if (first is Map<String, Object?> || first is List) {
        raw = first;
      }
    }

    if (parseErrors.isNotEmpty) {
      throw errors.BugIndicatingError(parseErrors
          .map((json.ParseError e) => errors.getErrorMessage(e.error))
          .join('\n'));
    }

    return raw;
  }
}
