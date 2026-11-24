// 1:1 translation of vscode/src/vs/platform/configuration/common/configurationModels.ts
// Adaptations (documented inline where non-trivial):
//   - Structural interfaces -> abstract classes (I* naming preserved).
//   - Plain JS objects used as carriers (IOverrides/IConfigurationChange/
//     IConfigurationModel/toData payloads) -> concrete carrier classes or Maps.
//   - `undefined` vs `null` distinction preserved via `_jsUndefined` sentinel.
//   - `Object.freeze`/`deepFreeze` -> objects.deepFreeze (identity-tracking).
import '../../../base/common/arrays.dart' as arrays;
import '../../../base/common/event.dart' as event;
import '../../../base/common/json.dart' as json;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/map.dart' as map;
import '../../../base/common/objects.dart' as objects;
import '../../../base/common/resources.dart' as resources;
import '../../../base/common/types.dart' as types;
import '../../../base/common/uri.dart' as uri;
import '../../registry/common/platform.dart' as platformRegistry;
import '../../log/common/log.dart' as log;
import '../../files/common/files.dart' as files;
import '../../workspace/common/workspace.dart' as workspace;
import 'configuration.dart' as config;
import 'configurationRegistry.dart' as registry;

/// 1:1: `function freeze<T>(data: T): T`
Object? freeze(Object? data) => objects.deepFreeze(data);

/// Marker for the JS `undefined` produced by missing paths. Distinct from Dart
/// `null` (= JS null). Mirrors configuration.dart's private `_jsUndefined`.
final Object _jsUndefined = Object();

/// FileOperation.WRITE is absent from the current files.dart port; source uses it.
const int _FILE_WRITE = 4;

/// 1:1: JS plain object `{ identifiers, keys, contents }` (IOverrides).
/// Carries mutable lists/maps so merge/update can mutate in place like JS.
class OverridesCarrier implements config.IOverrides {
  List<String> identifiers;
  List<String> keys;
  Map<String, Object?> contents;
  OverridesCarrier(this.identifiers, this.keys, this.contents);
}

/// 1:1: cast a decoded JSON object into `Map<String, Object?>`.
Map<String, Object?> _asStringObjectMap(Object? value) {
  if (value == null) return <String, Object?>{};
  if (value is Map<String, Object?>) return value;
  return (value as Map).map((k, v) => MapEntry<String, Object?>(k as String, v));
}

/// 1:1: convert decoded override objects into [OverridesCarrier] instances.
List<OverridesCarrier> _parseOverrides(Object? value) {
  if (value == null) return <OverridesCarrier>[];
  final list = value as List;
  return list.map((o) {
    if (o is OverridesCarrier) return o;
    final map = _asStringObjectMap(o);
    return OverridesCarrier(
      (map['identifiers'] as List?)?.cast<String>() ?? <String>[],
      (map['keys'] as List?)?.cast<String>() ?? <String>[],
      _asStringObjectMap(map['contents']),
    );
  }).toList();
}

/// Structural carrier for `{ value, override, overrides }` inspect values,
/// with the extra `merged` getter used internally by ConfigurationModel.
class InspectValue<V> implements config.IInspectValue<V> {
  final V? value_;
  final V? override_;
  final List<Map<String, Object?>>? overrides_;
  V? mergedValue;
  InspectValue(this.value_, this.override_, this.overrides_);

  V? get value => value_;
  V? get override => override_;
  List<Map<String, Object?>>? get overrides => overrides_;
}

/// 1:1: `filter` result carrier.
class _FilterResult {
  final Map<String, Object?> raw;
  final List<String> restricted;
  final bool hasExcludedProperties;
  _FilterResult(this.raw, this.restricted, this.hasExcludedProperties);
}

/// 1:1: `filterProperty` result carrier.
class _FilterPropertyResult {
  final bool included;
  final Object? value;
  final List<String> restricted;
  final bool hasExcludedProperties;
  _FilterPropertyResult(
      this.included, this.value, this.restricted, this.hasExcludedProperties);
}

/// 1:1: `findRegisteredAncestor` result carrier.
class _Ancestor {
  final String path;
  final Object? schema;
  final Object? excludedSchema;
  _Ancestor(this.path, this.schema, this.excludedSchema);
}

/// Identity-keyed map for `WeakMap<ConfigurationModel, ConfigurationModel>`.
class _ModelIdentityMap {
  final List<ConfigurationModel> _keys = <ConfigurationModel>[];
  final List<ConfigurationModel> _values = <ConfigurationModel>[];
  ConfigurationModel? get(ConfigurationModel key) {
    final i = _keys.indexWhere((k) => identical(k, key));
    return i >= 0 ? _values[i] : null;
  }
  void set(ConfigurationModel key, ConfigurationModel value) {
    final i = _keys.indexWhere((k) => identical(k, key));
    if (i >= 0) {
      _values[i] = value;
    } else {
      _keys.add(key);
      _values.add(value);
    }
  }
}

/// 1:1: `export class ConfigurationModel implements IConfigurationModel`
class ConfigurationModel {
  /// 1:1: `static createEmptyModel(logService)`
  static ConfigurationModel createEmptyModel(log.ILogServiceType? logService) =>
      ConfigurationModel(<String, Object?>{}, <String>[], <OverridesCarrier>[], null, logService);

  /// 1:1: `private readonly overrideConfigurations = new Map<string, ConfigurationModel>()`
  final Map<String, ConfigurationModel> _overrideConfigurations =
      <String, ConfigurationModel>{};

  final Map<String, Object?> _contents;
  final List<String> _keys;
  final List<OverridesCarrier> _overrides;
  final Object? _raw;
  final log.ILogServiceType? _logService;

  ConfigurationModel(
    this._contents,
    this._keys,
    this._overrides,
    this._raw,
    this._logService,
  );

  ConfigurationModel? _rawConfiguration;

  /// 1:1: `get rawConfiguration(): ConfigurationModel`
  ConfigurationModel get rawConfiguration {
    final existing = _rawConfiguration;
    if (existing != null) return existing;
    if (_raw != null) {
      final List<Object?> rawModels = _raw is List
          ? List<Object?>.from(_raw as List)
          : <Object?>[_raw];
      final List<ConfigurationModel> parsed = rawModels.map((raw) {
        if (raw is ConfigurationModel) return raw;
        final parser = ConfigurationModelParser('', _logService);
        parser.parseRaw(raw as Map<String, Object?>);
        return parser.configurationModel;
      }).toList();
      ConfigurationModel result = parsed.first;
      for (int i = 1; i < parsed.length; i++) {
        result = identical(parsed[i], result) ? parsed[i] : result.merge(<ConfigurationModel>[parsed[i]]);
      }
      _rawConfiguration = result;
    } else {
      _rawConfiguration = this;
    }
    return _rawConfiguration!;
  }

  Map<String, Object?> get contents => _contents;

  List<OverridesCarrier> get overrides => _overrides;

  List<String> get keys => _keys;

  /// 1:1: `get raw()`
  Object? get raw {
    if (_raw == null) return null;
    if (_raw is List &&
        (_raw as List).every((r) => r is ConfigurationModel)) {
      return null;
    }
    return _raw;
  }

  /// 1:1: `isEmpty()`
  bool isEmpty() =>
      _keys.isEmpty && _contents.isEmpty && _overrides.isEmpty;

  /// 1:1: `getValue<V>(section)`
  Object? getValue(Object? section) =>
      section != null && section is String
          ? config.getConfigurationValue(_contents, section)
          : _contents;

  /// 1:1: `inspect<V>(section, overrideIdentifier?)`
  InspectValue<Object?> inspect(Object? section, [String? overrideIdentifier]) {
    final that = this;
    final sectionStr = section is String ? section : null;
    Object? getMerged() {
      if (overrideIdentifier != null) {
        return that.rawConfiguration.overrideFor(overrideIdentifier).getValue(sectionStr);
      }
      return that.rawConfiguration.getValue(sectionStr);
    }

    // value getter
    final valueVal = freeze(that.rawConfiguration.getValue(sectionStr));
    // override getter
    final overrideVal = overrideIdentifier != null
        ? freeze(that.rawConfiguration.getOverrideValue(sectionStr, overrideIdentifier))
        : null;
    // merged getter
    final mergedVal = freeze(getMerged());
    // overrides getter
    final List<Map<String, Object?>> overridesList = <Map<String, Object?>>[];
    for (final ov in that.rawConfiguration.overrides) {
      final value = ConfigurationModel(
        ov.contents, ov.keys, <OverridesCarrier>[], null, that._logService,
      ).getValue(sectionStr);
      if (!identical(value, _jsUndefined) && value != null) {
        overridesList.add(<String, Object?>{
          'identifiers': ov.identifiers,
          'value': value,
        });
      }
    }
    final overridesVal = overridesList.isNotEmpty
        ? freeze(overridesList) as List<Map<String, Object?>>?
        : null;
    return InspectValue<Object?>(valueVal, overrideVal, overridesVal)
      ..mergedValue = mergedVal;
  }

  /// 1:1: `getOverrideValue<V>(section, overrideIdentifier)`
  Object? getOverrideValue(Object? section, String overrideIdentifier) {
    final overrideContents = getContentsForOverrideIdentifier(overrideIdentifier);
    if (overrideContents != null) {
      return section != null && section is String
          ? config.getConfigurationValue(overrideContents, section)
          : overrideContents;
    }
    return null;
  }

  /// 1:1: `getKeysForOverrideIdentifier(identifier)`
  List<String> getKeysForOverrideIdentifier(String identifier) {
    final List<String> keys = <String>[];
    for (final override in _overrides) {
      if (override.identifiers.contains(identifier)) {
        keys.addAll(override.keys);
      }
    }
    return arrays.distinct(keys);
  }

  /// 1:1: `getAllOverrideIdentifiers()`
  List<String> getAllOverrideIdentifiers() {
    final List<String> result = <String>[];
    for (final override in _overrides) {
      result.addAll(override.identifiers);
    }
    return arrays.distinct(result);
  }

  /// 1:1: `override(identifier)`
  ConfigurationModel overrideFor(String identifier) {
    var model = _overrideConfigurations[identifier];
    if (model == null) {
      model = createOverrideConfigurationModel(identifier);
      _overrideConfigurations[identifier] = model;
    }
    return model;
  }

  /// 1:1: `merge(...others)`
  ConfigurationModel merge(List<ConfigurationModel> others) {
    final contents = objects.deepClone(_contents) as Map<String, Object?>;
    final overrides = _overrides
        .map((o) => OverridesCarrier(
            List<String>.from(o.identifiers),
            List<String>.from(o.keys),
            objects.deepClone(o.contents) as Map<String, Object?>))
        .toList();
    final keys = <String>[..._keys];
    final List<Object?> raws = _raw != null
        ? (_raw is List ? List<Object?>.from(_raw as List) : <Object?>[_raw])
        : <Object?>[this];

    for (final other in others) {
      raws.addAll(other._raw != null
          ? (other._raw is List
              ? List<Object?>.from(other._raw as List)
              : <Object?>[other._raw])
          : <Object?>[other]);
      if (other.isEmpty()) continue;
      mergeContents(contents, other._contents);

      for (final otherOverride in other._overrides) {
        OverridesCarrier? foundOverride;
        for (final o in overrides) {
          if (arrays.equals(o.identifiers, otherOverride.identifiers)) {
            foundOverride = o;
            break;
          }
        }
        if (foundOverride != null) {
          mergeContents(foundOverride.contents, otherOverride.contents);
          foundOverride.keys.addAll(otherOverride.keys);
          foundOverride.keys = arrays.distinct(foundOverride.keys);
        } else {
          overrides.add(objects.deepClone(otherOverride)
              as OverridesCarrier);
        }
      }
      for (final key in other._keys) {
        if (!keys.contains(key)) keys.add(key);
      }
    }
    final Object? newRaw =
        raws.isEmpty || raws.every((r) => r is ConfigurationModel)
            ? null
            : raws;
    return ConfigurationModel(contents, keys, overrides, newRaw, _logService);
  }

  /// 1:1: `createOverrideConfigurationModel(identifier)`
  ConfigurationModel createOverrideConfigurationModel(String identifier) {
    final overrideContents = getContentsForOverrideIdentifier(identifier);
    if (overrideContents == null ||
        !types.isObject(overrideContents) ||
        overrideContents.isEmpty) {
      return this;
    }

    final contents = <String, Object?>{};
    final distinctKeys = arrays.distinct(<String>[
      ..._contents.keys,
      ...overrideContents.keys,
    ]);
    for (final key in distinctKeys) {
      Object? contentsForKey = _contents[key];
      final overrideContentsForKey = overrideContents[key];
      if (overrideContentsForKey != null) {
        if (types.isObject(contentsForKey) &&
            types.isObject(overrideContentsForKey)) {
          contentsForKey = objects.deepClone(contentsForKey);
          mergeContents(contentsForKey as Map<String, Object?>,
              overrideContentsForKey as Map<String, Object?>);
        } else {
          contentsForKey = overrideContentsForKey;
        }
      }
      json.setObjectProperty(contents, key, contentsForKey);
    }
    return ConfigurationModel(
        contents, _keys, _overrides, null, _logService);
  }

  /// 1:1: `mergeContents(source, target)`
  void mergeContents(
      Map<String, Object?> source, Map<String, Object?> target) {
    for (final key in target.keys) {
      if (source.containsKey(key)) {
        if (types.isObject(source[key]) && types.isObject(target[key])) {
          mergeContents(source[key] as Map<String, Object?>,
              target[key] as Map<String, Object?>);
          continue;
        }
      }
      json.setObjectProperty(source, key, objects.deepClone(target[key]));
    }
  }

  /// 1:1: `getContentsForOverrideIdentifer(identifier)`
  Map<String, Object?>? getContentsForOverrideIdentifier(String identifier) {
    Map<String, Object?>? contentsForIdentifierOnly;
    Map<String, Object?>? contents;
    void mergeInto(Map<String, Object?>? toMerge) {
      if (toMerge != null) {
        if (contents != null) {
          mergeContents(contents!, toMerge);
        } else {
          contents = objects.deepClone(toMerge) as Map<String, Object?>;
        }
      }
    }

    for (final override in _overrides) {
      if (override.identifiers.length == 1 &&
          override.identifiers[0] == identifier) {
        contentsForIdentifierOnly = override.contents;
      } else if (override.identifiers.contains(identifier)) {
        mergeInto(override.contents);
      }
    }
    mergeInto(contentsForIdentifierOnly);
    return contents;
  }

  /// 1:1: `toJSON()`
  Map<String, Object?> toJSON() => <String, Object?>{
        'contents': _contents,
        'overrides': _overrides,
        'keys': _keys,
      };

  /// 1:1: `addValue(key, value)`
  void addValue(String key, Object? value) => updateValue(key, value, true);

  /// 1:1: `setValue(key, value)`
  void setValue(String key, Object? value) => updateValue(key, value, false);

  /// 1:1: `removeValue(key)`
  void removeValue(String key) {
    final index = _keys.indexOf(key);
    if (index == -1) return;
    _keys.removeAt(index);
    config.removeFromValueTree(_contents, key);
    if (registry.OVERRIDE_PROPERTY_REGEX.hasMatch(key)) {
      final identifiers = registry.overrideIdentifiersFromKey(key);
      final oi = _overrides.indexWhere(
          (o) => arrays.equals(o.identifiers, identifiers));
      if (oi >= 0) _overrides.removeAt(oi);
    }
  }

  /// 1:1: `updateValue(key, value, add)`
  void updateValue(String key, Object? value, bool add) {
    config.addToValueTree(
        _contents, key, value, (e) => _logService?.error(e));
    add = add || _keys.indexOf(key) == -1;
    if (add) _keys.add(key);
    if (registry.OVERRIDE_PROPERTY_REGEX.hasMatch(key)) {
      final overrideContents = _contents[key] as Map<String, Object?>;
      final identifiers = registry.overrideIdentifiersFromKey(key);
      final override = OverridesCarrier(
        identifiers,
        overrideContents.keys.toList(),
        config.toValuesTree(
            overrideContents, (m) => _logService?.error(m)),
      );
      final index = _overrides.indexWhere(
          (o) => arrays.equals(o.identifiers, identifiers));
      if (index != -1) {
        _overrides[index] = override;
      } else {
        _overrides.add(override);
      }
    }
  }
}

/// 1:1: `export interface ConfigurationParseOptions`
class ConfigurationParseOptions {
  final bool? skipUnregistered;
  final List<int>? scopes;
  final bool? skipRestricted;
  final List<String>? include;
  final List<String>? exclude;
  const ConfigurationParseOptions({
    this.skipUnregistered,
    this.scopes,
    this.skipRestricted,
    this.include,
    this.exclude,
  });
}

/// 1:1: `doParseRaw` result carrier (IConfigurationModel & extras).
class _ParsedRaw {
  final Map<String, Object?> contents;
  final List<String> keys;
  final List<OverridesCarrier> overrides;
  final List<String> restricted;
  final bool hasExcludedProperties;
  _ParsedRaw(this.contents, this.keys, this.overrides, this.restricted,
      this.hasExcludedProperties);
}

/// 1:1: `export class ConfigurationModelParser`
class ConfigurationModelParser {
  Map<String, Object?>? _raw;
  ConfigurationModel? _configurationModel;
  List<String> _restrictedConfigurations = <String>[];
  List<json.ParseError> _parseErrors = <json.ParseError>[];

  final String _name;
  final log.ILogServiceType? _logService;

  ConfigurationModelParser(this._name, this._logService);

  /// 1:1: `get configurationModel()`
  ConfigurationModel get configurationModel =>
      _configurationModel ??
      ConfigurationModel.createEmptyModel(_logService);

  /// 1:1: `get restrictedConfigurations()`
  List<String> get restrictedConfigurations => _restrictedConfigurations;

  /// 1:1: `get errors()`
  List<json.ParseError> get errors => _parseErrors;

  /// 1:1: `parse(content, options?)`
  void parse(Object? content, [ConfigurationParseOptions? options]) {
    if (!types.isUndefinedOrNull(content)) {
      final raw = doParseContent(content as String);
      parseRaw(raw, options);
    }
  }

  /// 1:1: `reparse(options)`
  void reparse(ConfigurationParseOptions options) {
    if (_raw != null) parseRaw(_raw!, options);
  }

  /// 1:1: `parseRaw(raw, options?)`
  void parseRaw(Map<String, Object?> raw, [ConfigurationParseOptions? options]) {
    _raw = raw;
    final parsed = doParseRaw(raw, options);
    _configurationModel = ConfigurationModel(
      parsed.contents,
      parsed.keys,
      parsed.overrides,
      parsed.hasExcludedProperties ? <Map<String, Object?>>[raw] : null,
      _logService,
    );
    _restrictedConfigurations = parsed.restricted;
  }

  /// 1:1: `doParseContent(content)`
  Map<String, Object?> doParseContent(String content) {
    Map<String, Object?> raw = <String, Object?>{};
    dynamic currentParent = <Object?>[];
    final List<dynamic> previousParents = <dynamic>[];
    final List<json.ParseError> parseErrors = <json.ParseError>[];


    String? currentProperty;
    void onValueFull(Object? value) {
      if (currentParent is List) {
        currentParent.add(value);
      } else if (currentParent is Map<String, Object?> &&
          currentProperty != null) {
        json.setObjectProperty(currentParent, currentProperty!, value);
      }
    }

    final visitor = json.JSONVisitor(
      onObjectBegin: (int offset, int length) {
        final dynamic object = <String, Object?>{};
        onValueFull(object);
        previousParents.add(currentParent);
        currentParent = object;
        currentProperty = null;
      },
      onObjectProperty: (Object? name, int offset, int length) {
        currentProperty = name as String;
      },
      onObjectEnd: (int offset, int length) {
        currentParent = previousParents.removeLast();
      },
      onArrayBegin: (int offset, int length) {
        final dynamic array = <Object?>[];
        onValueFull(array);
        previousParents.add(currentParent);
        currentParent = array;
        currentProperty = null;
      },
      onArrayEnd: (int offset, int length) {
        currentParent = previousParents.removeLast();
      },
      onLiteralValue: (Object? value, int offset, int length) {
        onValueFull(value);
      },
      onError: (Object? error, int offset, int length) {
        parseErrors.add(json.ParseError(
          error is int ? error : 0, offset, length));
      },
    );
    if (content.isNotEmpty) {
      try {
        json.visit(content, visitor);
        final List<Object?> parent = (currentParent as List).cast<Object?>();
        raw = parent.isNotEmpty && parent[0] is Map<String, Object?>
            ? parent[0] as Map<String, Object?>
            : <String, Object?>{};
      } catch (e) {
        _logService?.error(
            'Error while parsing settings file $_name: $e');
        _parseErrors = <json.ParseError>[
          json.ParseError(0, 0, 0),
        ];
      }
    }
    return raw;
  }

  /// 1:1: `doParseRaw(raw, options?)`
  _ParsedRaw doParseRaw(
      Map<String, Object?> raw, [ConfigurationParseOptions? options]) {
    final registryObject = platformRegistry.Registry
        .as(registry.Extensions.Configuration);
    Map<String, Object?> configurationProperties = <String, Object?>{};
    Map<String, Object?> excludedConfigurationProperties = <String, Object?>{};
    if (registryObject is registry.IConfigurationRegistryType) {
      configurationProperties = registryObject.getConfigurationProperties();
      excludedConfigurationProperties =
          registryObject.getExcludedConfigurationProperties();
    }
    final filtered = filter(raw, configurationProperties,
        excludedConfigurationProperties, true, options);
    raw = filtered.raw;
    final contents = config.toValuesTree(raw,
        (message) => _logService?.error('Conflict in settings file $_name: $message'));
    final keys = raw.keys.toList();
    final overrides = toOverrides(raw,
        (message) => _logService?.error('Conflict in settings file $_name: $message'));
    return _ParsedRaw(contents, keys, overrides, filtered.restricted,
        filtered.hasExcludedProperties);
  }

  /// 1:1: `filter(...)` result carrier.

  _FilterResult filter(
      Map<String, Object?> properties,
      Map<String, Object?> configurationProperties,
      Map<String, Object?> excludedConfigurationProperties,
      bool filterOverriddenProperties,
      ConfigurationParseOptions? options) {
    bool hasExcludedProperties = false;
    if (options?.scopes == null &&
        options?.skipRestricted != true &&
        options?.skipUnregistered != true &&
        (options?.exclude == null || options!.exclude!.isEmpty)) {
      return _FilterResult(properties, <String>[], hasExcludedProperties);
    }
    final raw = <String, Object?>{};
    final restricted = <String>[];
    for (final key in properties.keys) {
      if (!properties.containsKey(key)) continue;
      if (registry.OVERRIDE_PROPERTY_REGEX.hasMatch(key) &&
          filterOverriddenProperties) {
        final result = filter(properties[key] as Map<String, Object?>,
            configurationProperties, excludedConfigurationProperties, false,
            options);
        json.setObjectProperty(raw, key, result.raw);
        hasExcludedProperties =
            hasExcludedProperties || result.hasExcludedProperties;
        restricted.addAll(result.restricted);
      } else {
        final result = filterProperty(key, properties[key],
            configurationProperties, excludedConfigurationProperties, options);
        restricted.addAll(result.restricted);
        hasExcludedProperties =
            hasExcludedProperties || result.hasExcludedProperties;
        if (result.included) {
          json.setObjectProperty(raw, key, result.value);
        } else {
          hasExcludedProperties = true;
        }
      }
    }
    return _FilterResult(raw, restricted, hasExcludedProperties);
  }

  /// 1:1: `filterProperty` result carrier.

  _FilterPropertyResult filterProperty(
      String path,
      Object? value,
      Map<String, Object?> configurationProperties,
      Map<String, Object?> excludedConfigurationProperties,
      ConfigurationParseOptions? options) {
    final opts = options ?? const ConfigurationParseOptions();
    final Object? propertySchema = configurationProperties.containsKey(path)
        ? configurationProperties[path]
        : null;
    final Object? excludedPropertySchema =
        excludedConfigurationProperties.containsKey(path)
            ? excludedConfigurationProperties[path]
            : null;
    if (propertySchema != null) {
      final bool restricted = _schemaRestricted(propertySchema);
      return _FilterPropertyResult(
        shouldInclude(path, propertySchema, excludedPropertySchema, opts),
        value,
        restricted ? <String>[path] : <String>[],
        false,
      );
    }
    if (!types.isObject(value) || value is List) {
      return filterUnregisteredLeaf(path, value, excludedPropertySchema,
          configurationProperties, excludedConfigurationProperties, opts);
    }
    if (excludedPropertySchema != null) {
      return _FilterPropertyResult(
        shouldInclude(path, propertySchema, excludedPropertySchema, opts),
        value, <String>[], false);
    }
    if (opts.exclude != null && opts.exclude!.contains(path)) {
      return _FilterPropertyResult(false, value, <String>[], false);
    }
    final valueMap = value as Map<String, Object?>;
    final keys = valueMap.keys.toList();
    if (keys.isEmpty) {
      return filterUnregisteredLeaf(path, value, excludedPropertySchema,
          configurationProperties, excludedConfigurationProperties, opts);
    }
    final nested = <String, Object?>{};
    final restricted = <String>[];
    bool included = false;
    bool hasExcludedProperties = false;
    for (final key in keys) {
      final result = filterProperty('$path.$key', valueMap[key],
          configurationProperties, excludedConfigurationProperties, opts);
      restricted.addAll(result.restricted);
      hasExcludedProperties =
          hasExcludedProperties || result.hasExcludedProperties;
      if (result.included) {
        json.setObjectProperty(nested, key, result.value);
        included = true;
      } else {
        hasExcludedProperties = true;
      }
    }
    return _FilterPropertyResult(
        included, nested, restricted, hasExcludedProperties);
  }

  _FilterPropertyResult filterUnregisteredLeaf(
      String path,
      Object? value,
      Object? excludedPropertySchema,
      Map<String, Object?> configurationProperties,
      Map<String, Object?> excludedConfigurationProperties,
      ConfigurationParseOptions options) {
    final ancestor = excludedPropertySchema == null
        ? findRegisteredAncestor(
            path, configurationProperties, excludedConfigurationProperties)
        : null;
    if (ancestor != null) {
      return _FilterPropertyResult(
        shouldInclude(ancestor.path, ancestor.schema, ancestor.excludedSchema,
            options),
        value,
        (ancestor.schema != null && _schemaRestricted(ancestor.schema!))
            ? <String>[ancestor.path]
            : <String>[],
        false,
      );
    }
    return _FilterPropertyResult(
      shouldInclude(path, null, excludedPropertySchema, options),
      value, <String>[], false);
  }


  _Ancestor? findRegisteredAncestor(
      String path,
      Map<String, Object?> configurationProperties,
      Map<String, Object?> excludedConfigurationProperties) {
    int index = path.lastIndexOf('.');
    while (index > 0) {
      final ancestorPath = path.substring(0, index);
      final Object? schema = configurationProperties.containsKey(ancestorPath)
          ? configurationProperties[ancestorPath]
          : null;
      final Object? excludedSchema =
          excludedConfigurationProperties.containsKey(ancestorPath)
              ? excludedConfigurationProperties[ancestorPath]
              : null;
      if (schema != null || excludedSchema != null) {
        return _Ancestor(ancestorPath, schema, excludedSchema);
      }
      index = path.lastIndexOf('.', index - 1);
    }
    return null;
  }

  /// 1:1: `shouldInclude(key, propertySchema, excludedPropertySchema, options)`
  bool shouldInclude(String key, Object? propertySchema,
      Object? excludedPropertySchema, ConfigurationParseOptions options) {
    if (options.exclude != null && options.exclude!.contains(key)) return false;
    if (options.include != null && options.include!.contains(key)) return true;
    if (options.skipRestricted == true && propertySchema != null &&
        _schemaRestricted(propertySchema)) {
      return false;
    }
    if (options.skipUnregistered == true && propertySchema == null) return false;

    final schema = propertySchema ?? excludedPropertySchema;
    final int? scope = schema == null ? null : _schemaScope(schema);
    if (scope == null || options.scopes == null) return true;
    return options.scopes!.contains(scope);
  }

  bool _schemaRestricted(Object schema) {
    if (schema is Map) return schema['restricted'] == true;
    final dynamic d = schema;
    try {
      return d.restricted == true;
    } catch (_) {
      return false;
    }
  }

  int? _schemaScope(Object schema) {
    if (schema is Map) {
      final s = schema['scope'];
      return s is int ? s : null;
    }
    final dynamic d = schema;
    try {
      final s = d.scope;
      return s == null ? null : (s is int ? s : null);
    } catch (_) {
      return null;
    }
  }

  /// 1:1: `toOverrides(raw, conflictReporter)`
  List<OverridesCarrier> toOverrides(
      Map<String, Object?> raw, void Function(String message) conflictReporter) {
    final overrides = <OverridesCarrier>[];
    for (final key in raw.keys) {
      if (registry.OVERRIDE_PROPERTY_REGEX.hasMatch(key)) {
        final overrideRaw = <String, Object?>{};
        final rawKey = raw[key] as Map<String, Object?>;
        for (final keyInOverrideRaw in rawKey.keys) {
          overrideRaw[keyInOverrideRaw] = rawKey[keyInOverrideRaw];
        }
        overrides.add(OverridesCarrier(
          registry.overrideIdentifiersFromKey(key),
          overrideRaw.keys.toList(),
          config.toValuesTree(overrideRaw, conflictReporter),
        ));
      }
    }
    return overrides;
  }
}

/// 1:1: `export class UserSettings extends Disposable`
class UserSettings extends lifecycle.Disposable {
  late final ConfigurationModelParser _parser;
  ConfigurationParseOptions parseOptions;
  final uri.URI _userSettingsResource;
  final resources.IExtUri _extUri;
  final files.IFileServiceType _fileService;
  final log.ILogServiceType _logService;

  final event.Emitter<void> _onDidChange = event.Emitter<void>();
  late final event.Event<void> onDidChange;

  UserSettings(
    this._userSettingsResource,
    this.parseOptions,
    this._extUri,
    this._fileService,
    this._logService,
  ) {
    _parser = ConfigurationModelParser(
        _userSettingsResource.toString(), _logService);
    onDidChange = _onDidChange.event;
    register((_fileService as dynamic).watch(_extUri.dirname(_userSettingsResource)) as lifecycle.IDisposable);
    register((_fileService as dynamic).watch(_userSettingsResource) as lifecycle.IDisposable);
    register(event.eventAny<void>(<event.Event<dynamic>>[
      event.eventFilter<files.FileChangesEvent>(
          _fileService.onDidFilesChange,
          (e) => e.contains(_userSettingsResource)),
      event.eventFilter<dynamic>(
          (_fileService as dynamic).onDidRunOperation as event.Event<dynamic>,
          (e) =>
              (e.isOperation(files.FileOperation.CREATE) ||
                      e.isOperation(files.FileOperation.COPY) ||
                      e.isOperation(files.FileOperation.DELETE) ||
                      e.isOperation(_FILE_WRITE)) &&
                  _extUri.isEqual(e.resource, _userSettingsResource)),
    ]).call((_) => _onDidChange.fire(null)));
  }

  /// 1:1: `async loadConfiguration()`
  Future<ConfigurationModel> loadConfiguration() async {
    try {
      final content = await (_fileService as dynamic).readFile(_userSettingsResource);
      _parser.parse(content.value.toString(), parseOptions);
      return _parser.configurationModel;
    } catch (e) {
      return ConfigurationModel.createEmptyModel(_logService);
    }
  }

  /// 1:1: `reparse(parseOptions?)`
  ConfigurationModel reparse([ConfigurationParseOptions? parseOptions]) {
    if (parseOptions != null) this.parseOptions = parseOptions;
    _parser.reparse(this.parseOptions);
    return _parser.configurationModel;
  }

  /// 1:1: `getRestrictedSettings()`
  List<String> getRestrictedSettings() => _parser.restrictedConfigurations;
}

/// 1:1: `class ConfigurationInspectValue<V> implements IConfigurationValue<V>`
class ConfigurationInspectValue<V> implements config.IConfigurationValue<V> {
  final String key;
  final config.IConfigurationOverrides overrides;
  final V? _value;
  final List<String>? overrideIdentifiers;
  final ConfigurationModel defaultConfiguration;
  final ConfigurationModel? policyConfiguration;
  final ConfigurationModel? applicationConfiguration;
  final ConfigurationModel userConfiguration;
  final ConfigurationModel localUserConfiguration;
  final ConfigurationModel remoteUserConfiguration;
  final ConfigurationModel? workspaceConfiguration;
  final ConfigurationModel? folderConfigurationModel;
  final ConfigurationModel memoryConfigurationModel;

  ConfigurationInspectValue(
    this.key,
    this.overrides,
    this._value,
    this.overrideIdentifiers,
    this.defaultConfiguration,
    this.policyConfiguration,
    this.applicationConfiguration,
    this.userConfiguration,
    this.localUserConfiguration,
    this.remoteUserConfiguration,
    this.workspaceConfiguration,
    this.folderConfigurationModel,
    this.memoryConfigurationModel,
  );

  V? get value => _value == null ? null : freeze(_value) as V?;

  config.IInspectValue<V>? toInspectValue(config.IInspectValue<V>? iv) {
    if (iv == null) return null;
    return (iv.value != null || iv.override != null || iv.overrides != null)
        ? iv
        : null;
  }

  InspectValue<V>? _defaultInspectValue;
  InspectValue<V> get defaultInspectValue {
    final existing = _defaultInspectValue;
    if (existing != null) return existing;
    final iv = defaultConfiguration.inspect(key, overrides.overrideIdentifier);
    final converted = InspectValue<V>(
      iv.value as V?, iv.override as V?, iv.overrides,
    )..mergedValue = (iv as dynamic).mergedValue as V?;
    _defaultInspectValue = converted;
    return converted;
  }

  V? get defaultValue => defaultInspectValue.mergedValue as V?;
  config.IInspectValue<V>? get default_ => toInspectValue(defaultInspectValue);

  InspectValue<V>? _policyInspectValue;
  InspectValue<V>? get policyInspectValue {
    if (_policyInspectValue == null) {
      if (policyConfiguration == null) {
        _policyInspectValue = null;
      } else {
        final iv =
            policyConfiguration!.inspect(key, overrides.overrideIdentifier);
        _policyInspectValue = InspectValue<V>(
            iv.value as V?, iv.override as V?, iv.overrides)
          ..mergedValue = (iv as dynamic).mergedValue as V?;
      }
    }
    return _policyInspectValue;
  }

  V? get policyValue => policyInspectValue?.mergedValue as V?;
  Map<String, Object?>? get policy =>
      (policyInspectValue?.value != null)
          ? <String, Object?>{'value': policyInspectValue!.value}
          : null;

  InspectValue<V>? _applicationInspectValue;
  InspectValue<V>? get applicationInspectValue {
    if (_applicationInspectValue == null) {
      if (applicationConfiguration == null) {
        _applicationInspectValue = null;
      } else {
        final iv = applicationConfiguration!
            .inspect(key, overrides.overrideIdentifier);
        _applicationInspectValue = InspectValue<V>(
            iv.value as V?, iv.override as V?, iv.overrides)
          ..mergedValue = (iv as dynamic).mergedValue as V?;
      }
    }
    return _applicationInspectValue;
  }

  V? get applicationValue => applicationInspectValue?.mergedValue as V?;
  config.IInspectValue<V>? get application =>
      toInspectValue(applicationInspectValue);

  InspectValue<V>? _userInspectValue;
  InspectValue<V> get userInspectValue {
    final existing = _userInspectValue;
    if (existing != null) return existing;
    final iv = userConfiguration.inspect(key, overrides.overrideIdentifier);
    final converted = InspectValue<V>(
        iv.value as V?, iv.override as V?, iv.overrides)
      ..mergedValue = (iv as dynamic).mergedValue as V?;
    _userInspectValue = converted;
    return converted;
  }

  V? get userValue => userInspectValue.mergedValue as V?;
  config.IInspectValue<V>? get user => toInspectValue(userInspectValue);

  InspectValue<V>? _userLocalInspectValue;
  InspectValue<V> get userLocalInspectValue {
    final existing = _userLocalInspectValue;
    if (existing != null) return existing;
    final iv =
        localUserConfiguration.inspect(key, overrides.overrideIdentifier);
    final converted = InspectValue<V>(
        iv.value as V?, iv.override as V?, iv.overrides)
      ..mergedValue = (iv as dynamic).mergedValue as V?;
    _userLocalInspectValue = converted;
    return converted;
  }

  V? get userLocalValue => userLocalInspectValue.mergedValue as V?;
  config.IInspectValue<V>? get userLocal =>
      toInspectValue(userLocalInspectValue);

  InspectValue<V>? _userRemoteInspectValue;
  InspectValue<V> get userRemoteInspectValue {
    final existing = _userRemoteInspectValue;
    if (existing != null) return existing;
    final iv =
        remoteUserConfiguration.inspect(key, overrides.overrideIdentifier);
    final converted = InspectValue<V>(
        iv.value as V?, iv.override as V?, iv.overrides)
      ..mergedValue = (iv as dynamic).mergedValue as V?;
    _userRemoteInspectValue = converted;
    return converted;
  }

  V? get userRemoteValue => userRemoteInspectValue.mergedValue as V?;
  config.IInspectValue<V>? get userRemote =>
      toInspectValue(userRemoteInspectValue);

  InspectValue<V>? _workspaceInspectValue;
  InspectValue<V>? get workspaceInspectValue {
    if (_workspaceInspectValue == null) {
      if (workspaceConfiguration == null) {
        _workspaceInspectValue = null;
      } else {
        final iv = workspaceConfiguration!
            .inspect(key, overrides.overrideIdentifier);
        _workspaceInspectValue = InspectValue<V>(
            iv.value as V?, iv.override as V?, iv.overrides)
          ..mergedValue = (iv as dynamic).mergedValue as V?;
      }
    }
    return _workspaceInspectValue;
  }

  V? get workspaceValue => workspaceInspectValue?.mergedValue as V?;
  config.IInspectValue<V>? get workspace =>
      toInspectValue(workspaceInspectValue);

  InspectValue<V>? _workspaceFolderInspectValue;
  InspectValue<V>? get workspaceFolderInspectValue {
    if (_workspaceFolderInspectValue == null) {
      if (folderConfigurationModel == null) {
        _workspaceFolderInspectValue = null;
      } else {
        final iv = folderConfigurationModel!
            .inspect(key, overrides.overrideIdentifier);
        _workspaceFolderInspectValue = InspectValue<V>(
            iv.value as V?, iv.override as V?, iv.overrides)
          ..mergedValue = (iv as dynamic).mergedValue as V?;
      }
    }
    return _workspaceFolderInspectValue;
  }

  V? get workspaceFolderValue =>
      workspaceFolderInspectValue?.mergedValue as V?;
  config.IInspectValue<V>? get workspaceFolder =>
      toInspectValue(workspaceFolderInspectValue);

  InspectValue<V>? _memoryInspectValue;
  InspectValue<V> get memoryInspectValue {
    final existing = _memoryInspectValue;
    if (existing != null) return existing;
    final iv =
        memoryConfigurationModel.inspect(key, overrides.overrideIdentifier);
    final converted = InspectValue<V>(
        iv.value as V?, iv.override as V?, iv.overrides)
      ..mergedValue = (iv as dynamic).mergedValue as V?;
    _memoryInspectValue = converted;
    return converted;
  }

  V? get memoryValue => memoryInspectValue.mergedValue as V?;
  config.IInspectValue<V>? get memory => toInspectValue(memoryInspectValue);
}

/// 1:1: `export class Configuration`
class Configuration {
  ConfigurationModel? _workspaceConsolidatedConfiguration;
  final map.ResourceMap<ConfigurationModel> _foldersConsolidatedConfigurations =
      map.ResourceMap<ConfigurationModel>();
  _ModelIdentityMap _policyAppliedConfigurations =
      _ModelIdentityMap();

  ConfigurationModel _defaultConfiguration;
  ConfigurationModel _policyConfiguration;
  ConfigurationModel _applicationConfiguration;
  ConfigurationModel _localUserConfiguration;
  ConfigurationModel _remoteUserConfiguration;
  ConfigurationModel _workspaceConfiguration;
  final map.ResourceMap<ConfigurationModel> _folderConfigurations;
  final ConfigurationModel _memoryConfiguration;
  final map.ResourceMap<ConfigurationModel> _memoryConfigurationByResource;
  final log.ILogServiceType? _logService;

  Configuration(
    this._defaultConfiguration,
    this._policyConfiguration,
    this._applicationConfiguration,
    this._localUserConfiguration,
    this._remoteUserConfiguration,
    this._workspaceConfiguration,
    this._folderConfigurations,
    this._memoryConfiguration,
    this._memoryConfigurationByResource,
    this._logService,
  );

  ConfigurationModel? _userConfiguration;

  /// 1:1: `getValue(section, overrides, workspace)`
  Object? getValue(Object? section, config.IConfigurationOverrides overrides,
      workspace.Workspace? ws) {
    final consolidated = getConsolidatedConfigurationModel(section, overrides, ws);
    return consolidated.getValue(section);
  }

  /// 1:1: `updateValue(key, value, overrides)`
  void updateValue(String key, Object? value,
      [config.IConfigurationUpdateOverrides overrides = const <String, Object?>{}]) {
    late ConfigurationModel memoryConfiguration;
    final Object? resource = overrides is Map ? overrides['resource'] : null;
    if (resource != null && resource is uri.URI) {
      var mc = _memoryConfigurationByResource.get(resource);
      if (mc == null) {
        mc = ConfigurationModel.createEmptyModel(_logService);
        _memoryConfigurationByResource.set(resource, mc);
      }
      memoryConfiguration = mc;
    } else {
      memoryConfiguration = _memoryConfiguration;
    }
    if (identical(value, _jsUndefined) || value == null) {
      memoryConfiguration.removeValue(key);
    } else {
      memoryConfiguration.setValue(key, value);
    }
    if (resource == null) {
      _workspaceConsolidatedConfiguration = null;
    }
  }

  /// 1:1: `inspect<C>(key, overrides, workspace)`
  config.IConfigurationValue<Object?> inspect(String key,
      config.IConfigurationOverrides overrides, workspace.Workspace? ws) {
    final consolidated = getConsolidatedConfigurationModel(key, overrides, ws);
    final folderModel = getFolderConfigurationModelForResource(
        overrides.resource, ws);
    final memoryModel = overrides.resource != null
        ? (_memoryConfigurationByResource.get(overrides.resource!) ??
            _memoryConfiguration)
        : _memoryConfiguration;
    final overrideIdentifiers = <String>{};
    for (final ov in consolidated.overrides) {
      for (final oid in ov.identifiers) {
        if (!identical(
            consolidated.getOverrideValue(key, oid), _jsUndefined)) {
          overrideIdentifiers.add(oid);
        }
      }
    }
    return ConfigurationInspectValue<Object?>(
      key,
      overrides,
      consolidated.getValue(key),
      overrideIdentifiers.isNotEmpty ? overrideIdentifiers.toList() : null,
      _defaultConfiguration,
      _policyConfiguration.isEmpty()
          ? null
          : _policyConfiguration,
      _applicationConfiguration.isEmpty()
          ? null
          : _applicationConfiguration,
      userConfiguration,
      _localUserConfiguration,
      _remoteUserConfiguration,
      ws != null ? _workspaceConfiguration : null,
      folderModel,
      memoryModel,
    );
  }

  /// 1:1: `keys(workspace)`
  Map<String, List<String>> keys(workspace.Workspace? ws) {
    final folderModel = getFolderConfigurationModelForResource(null, ws);
    return <String, List<String>>{
      'default': <String>[..._defaultConfiguration.keys],
      'policy': <String>[..._policyConfiguration.keys],
      'user': <String>[...userConfiguration.keys],
      'workspace': <String>[..._workspaceConfiguration.keys],
      'workspaceFolder': folderModel != null
          ? <String>[...folderModel.keys]
          : <String>[],
    };
  }

  void updateDefaultConfiguration(ConfigurationModel defaultConfiguration) {
    _defaultConfiguration = defaultConfiguration;
    _workspaceConsolidatedConfiguration = null;
    _foldersConsolidatedConfigurations.clear();
  }

  void updatePolicyConfiguration(ConfigurationModel policyConfiguration) {
    _policyConfiguration = policyConfiguration;
    _policyAppliedConfigurations = _ModelIdentityMap();
  }

  void updateApplicationConfiguration(
      ConfigurationModel applicationConfiguration) {
    _applicationConfiguration = applicationConfiguration;
    _workspaceConsolidatedConfiguration = null;
    _foldersConsolidatedConfigurations.clear();
  }

  void updateLocalUserConfiguration(ConfigurationModel localUserConfiguration) {
    _localUserConfiguration = localUserConfiguration;
    _userConfiguration = null;
    _workspaceConsolidatedConfiguration = null;
    _foldersConsolidatedConfigurations.clear();
  }

  void updateRemoteUserConfiguration(ConfigurationModel remoteUserConfiguration) {
    _remoteUserConfiguration = remoteUserConfiguration;
    _userConfiguration = null;
    _workspaceConsolidatedConfiguration = null;
    _foldersConsolidatedConfigurations.clear();
  }

  void updateWorkspaceConfiguration(ConfigurationModel workspaceConfiguration) {
    _workspaceConfiguration = workspaceConfiguration;
    _workspaceConsolidatedConfiguration = null;
    _foldersConsolidatedConfigurations.clear();
  }

  void updateFolderConfiguration(uri.URI resource, ConfigurationModel configuration) {
    _folderConfigurations.set(resource, configuration);
    _foldersConsolidatedConfigurations.delete(resource);
  }

  void deleteFolderConfiguration(uri.URI resource) {
    _folderConfigurations.delete(resource);
    _foldersConsolidatedConfigurations.delete(resource);
  }

  config.IConfigurationChange compareAndUpdateDefaultConfiguration(
      ConfigurationModel defaults, [List<String>? keys]) {
    final overrides = <List<Object?>>[];
    if (keys == null) {
      final result = compare(_defaultConfiguration, defaults);
      keys = <String>[...result.added, ...result.updated, ...result.removed];
    }
    for (final key in keys) {
      for (final oid in registry.overrideIdentifiersFromKey(key)) {
        final fromKeys = _defaultConfiguration.getKeysForOverrideIdentifier(oid);
        final toKeys = defaults.getKeysForOverrideIdentifier(oid);
        final changedKeys = <String>[
          ...toKeys.where((k) => !fromKeys.contains(k)),
          ...fromKeys.where((k) => !toKeys.contains(k)),
          ...fromKeys.where((k) => !objects.equals(
              _defaultConfiguration.overrideFor(oid).getValue(k),
              defaults.overrideFor(oid).getValue(k))),
        ];
        overrides.add(<Object?>[oid, changedKeys]);
      }
    }
    updateDefaultConfiguration(defaults);
    return _ChangeCarrier(keys, overrides);
  }

  config.IConfigurationChange compareAndUpdatePolicyConfiguration(
      ConfigurationModel policyConfiguration) {
    final result = compare(_policyConfiguration, policyConfiguration);
    final keys = <String>[...result.added, ...result.updated, ...result.removed];
    if (keys.isNotEmpty) updatePolicyConfiguration(policyConfiguration);
    return _ChangeCarrier(keys, <List<Object?>>[]);
  }

  config.IConfigurationChange compareAndUpdateApplicationConfiguration(
      ConfigurationModel application) {
    final result = compare(_applicationConfiguration, application);
    final keys = <String>[...result.added, ...result.updated, ...result.removed];
    if (keys.isNotEmpty) updateApplicationConfiguration(application);
    return _ChangeCarrier(keys, result.overrides);
  }

  config.IConfigurationChange compareAndUpdateLocalUserConfiguration(
      ConfigurationModel user) {
    final result = compare(_localUserConfiguration, user);
    final keys = <String>[...result.added, ...result.updated, ...result.removed];
    if (keys.isNotEmpty) updateLocalUserConfiguration(user);
    return _ChangeCarrier(keys, result.overrides);
  }

  config.IConfigurationChange compareAndUpdateRemoteUserConfiguration(
      ConfigurationModel user) {
    final result = compare(_remoteUserConfiguration, user);
    final keys = <String>[...result.added, ...result.updated, ...result.removed];
    if (keys.isNotEmpty) updateRemoteUserConfiguration(user);
    return _ChangeCarrier(keys, result.overrides);
  }

  config.IConfigurationChange compareAndUpdateWorkspaceConfiguration(
      ConfigurationModel workspaceConfiguration) {
    final result = compare(_workspaceConfiguration, workspaceConfiguration);
    final keys = <String>[...result.added, ...result.updated, ...result.removed];
    if (keys.isNotEmpty) updateWorkspaceConfiguration(workspaceConfiguration);
    return _ChangeCarrier(keys, result.overrides);
  }

  config.IConfigurationChange compareAndUpdateFolderConfiguration(
      uri.URI resource, ConfigurationModel folderConfiguration) {
    final current = _folderConfigurations.get(resource);
    final result = compare(current, folderConfiguration);
    final keys = <String>[...result.added, ...result.updated, ...result.removed];
    if (keys.isNotEmpty || current == null) {
      updateFolderConfiguration(resource, folderConfiguration);
    }
    return _ChangeCarrier(keys, result.overrides);
  }

  config.IConfigurationChange compareAndDeleteFolderConfiguration(uri.URI folder) {
    final folderConfig = _folderConfigurations.get(folder);
    if (folderConfig == null) throw StateError('Unknown folder');
    deleteFolderConfiguration(folder);
    final result = compare(folderConfig, null);
    return _ChangeCarrier(
        <String>[...result.added, ...result.updated, ...result.removed],
        result.overrides);
  }

  ConfigurationModel get defaults => _defaultConfiguration;
  ConfigurationModel get applicationConfiguration => _applicationConfiguration;

  ConfigurationModel get userConfiguration {
    final existing = _userConfiguration;
    if (existing != null) return existing;
    if (_remoteUserConfiguration.isEmpty()) {
      _userConfiguration = _localUserConfiguration;
    } else {
      final merged =
          _localUserConfiguration.merge(<ConfigurationModel>[_remoteUserConfiguration]);
      _userConfiguration = ConfigurationModel(merged.contents, merged.keys,
          merged.overrides, null, _logService);
    }
    return _userConfiguration!;
  }

  ConfigurationModel get localUserConfiguration => _localUserConfiguration;
  ConfigurationModel get remoteUserConfiguration => _remoteUserConfiguration;
  ConfigurationModel get workspaceConfiguration => _workspaceConfiguration;
  map.ResourceMap<ConfigurationModel> get folderConfigurations =>
      _folderConfigurations;
  ConfigurationModel get memoryConfiguration => _memoryConfiguration;
  map.ResourceMap<ConfigurationModel> get memoryConfigurationByResource =>
      _memoryConfigurationByResource;

  ConfigurationModel getConsolidatedConfigurationModel(Object? section,
      config.IConfigurationOverrides overrides, workspace.Workspace? ws) {
    var model = getConsolidatedConfigurationModelForResource(overrides, ws);
    final oid = overrides.overrideIdentifier;
    if (oid != null) model = model.overrideFor(oid);
    if (!_policyConfiguration.isEmpty() &&
        !identical(_policyConfiguration.getValue(section), _jsUndefined) &&
        _policyConfiguration.getValue(section) != null) {
      model = getPolicyAppliedConfigurationModel(model);
    }
    return model;
  }

  ConfigurationModel getPolicyAppliedConfigurationModel(
      ConfigurationModel configurationModel) {
    var applied = _policyAppliedConfigurations.get(configurationModel);
    if (applied == null) {
      applied = configurationModel.merge(<ConfigurationModel>[]);
      for (final key in _policyConfiguration.keys) {
        applied.setValue(key, _policyConfiguration.getValue(key));
      }
      _policyAppliedConfigurations.set(configurationModel, applied);
    }
    return applied;
  }

  ConfigurationModel getConsolidatedConfigurationModelForResource(
      config.IConfigurationOverrides overrides, workspace.Workspace? ws) {
    var consolidate = getWorkspaceConsolidatedConfiguration();
    final resource = overrides.resource;
    if (ws != null && resource != null) {
      final root = ws.getFolder(resource);
      if (root != null) {
        consolidate = getFolderConsolidatedConfiguration(root.uri) ?? consolidate;
      }
      final memoryForResource = _memoryConfigurationByResource.get(resource);
      if (memoryForResource != null) {
        consolidate = consolidate.merge(<ConfigurationModel>[memoryForResource]);
      }
    }
    return consolidate;
  }

  ConfigurationModel getWorkspaceConsolidatedConfiguration() {
    final existing = _workspaceConsolidatedConfiguration;
    if (existing != null) return existing;
    _workspaceConsolidatedConfiguration = _defaultConfiguration.merge(
      <ConfigurationModel>[
        _applicationConfiguration,
        userConfiguration,
        _workspaceConfiguration,
        _memoryConfiguration,
      ],
    );
    return _workspaceConsolidatedConfiguration!;
  }

  ConfigurationModel getFolderConsolidatedConfiguration(uri.URI folder) {
    var folderConsolidated = _foldersConsolidatedConfigurations.get(folder);
    if (folderConsolidated == null) {
      final wsConsolidated = getWorkspaceConsolidatedConfiguration();
      final folderConfiguration = _folderConfigurations.get(folder);
      if (folderConfiguration != null) {
        folderConsolidated =
            wsConsolidated.merge(<ConfigurationModel>[folderConfiguration]);
        _foldersConsolidatedConfigurations.set(folder, folderConsolidated);
      } else {
        folderConsolidated = wsConsolidated;
      }
    }
    return folderConsolidated;
  }

  ConfigurationModel? getFolderConfigurationModelForResource(
      uri.URI? resource, workspace.Workspace? ws) {
    if (ws != null && resource != null) {
      final root = ws.getFolder(resource);
      if (root != null) return _folderConfigurations.get(root.uri);
    }
    return null;
  }

  /// 1:1: `toData()`
  Map<String, Object?> toData() {
    return <String, Object?>{
      'defaults': <String, Object?>{
        'contents': _defaultConfiguration.contents,
        'overrides': _defaultConfiguration.overrides,
        'keys': _defaultConfiguration.keys,
      },
      'policy': <String, Object?>{
        'contents': _policyConfiguration.contents,
        'overrides': _policyConfiguration.overrides,
        'keys': _policyConfiguration.keys,
      },
      'application': <String, Object?>{
        'contents': _applicationConfiguration.contents,
        'overrides': _applicationConfiguration.overrides,
        'keys': _applicationConfiguration.keys,
        'raw': _applicationConfiguration.raw is List
            ? null
            : _applicationConfiguration.raw,
      },
      'userLocal': <String, Object?>{
        'contents': _localUserConfiguration.contents,
        'overrides': _localUserConfiguration.overrides,
        'keys': _localUserConfiguration.keys,
        'raw': _localUserConfiguration.raw is List
            ? null
            : _localUserConfiguration.raw,
      },
      'userRemote': <String, Object?>{
        'contents': _remoteUserConfiguration.contents,
        'overrides': _remoteUserConfiguration.overrides,
        'keys': _remoteUserConfiguration.keys,
        'raw': _remoteUserConfiguration.raw is List
            ? null
            : _remoteUserConfiguration.raw,
      },
      'workspace': <String, Object?>{
        'contents': _workspaceConfiguration.contents,
        'overrides': _workspaceConfiguration.overrides,
        'keys': _workspaceConfiguration.keys,
      },
      'folders': _folderConfigurations.keys().map((folder) {
        final m = _folderConfigurations.get(folder)!;
        return <Object?>[
          folder.toJSON(),
          <String, Object?>{
            'contents': m.contents,
            'overrides': m.overrides,
            'keys': m.keys,
          },
        ];
      }).toList(),
    };
  }

  /// 1:1: `allKeys()`
  List<String> allKeys() {
    final keys = <String>{};
    _defaultConfiguration.keys.forEach(keys.add);
    userConfiguration.keys.forEach(keys.add);
    _workspaceConfiguration.keys.forEach(keys.add);
    _folderConfigurations.forEach((m, _, __) {
      m.keys.forEach(keys.add);
    });
    return keys.toList();
  }

  /// 1:1: `allOverrideIdentifiers()`
  List<String> allOverrideIdentifiers() {
    final keys = <String>{};
    _defaultConfiguration.getAllOverrideIdentifiers().forEach(keys.add);
    userConfiguration.getAllOverrideIdentifiers().forEach(keys.add);
    _workspaceConfiguration.getAllOverrideIdentifiers().forEach(keys.add);
    _folderConfigurations.forEach((m, _, __) {
      m.getAllOverrideIdentifiers().forEach(keys.add);
    });
    return keys.toList();
  }

  /// 1:1: `getAllKeysForOverrideIdentifier(overrideIdentifier)`
  List<String> getAllKeysForOverrideIdentifier(String overrideIdentifier) {
    final keys = <String>{};
    _defaultConfiguration
        .getKeysForOverrideIdentifier(overrideIdentifier)
        .forEach(keys.add);
    userConfiguration
        .getKeysForOverrideIdentifier(overrideIdentifier)
        .forEach(keys.add);
    _workspaceConfiguration
        .getKeysForOverrideIdentifier(overrideIdentifier)
        .forEach(keys.add);
    _folderConfigurations.forEach((m, _, __) {
      m.getKeysForOverrideIdentifier(overrideIdentifier).forEach(keys.add);
    });
    return keys.toList();
  }

  /// 1:1: `static parse(data, logService)`
  static Configuration parse(
      Map<String, Object?> data, log.ILogServiceType? logService) {
    ConfigurationModel parseModel(Object? model) =>
        parseConfigurationModel(model as Map<String, Object?>, logService);
    final defaultConfiguration = parseModel(data['defaults']);
    final policyConfiguration = parseModel(data['policy']);
    final applicationConfiguration = parseModel(data['application']);
    final userLocalConfiguration = parseModel(data['userLocal']);
    final userRemoteConfiguration = parseModel(data['userRemote']);
    final workspaceConfiguration = parseModel(data['workspace']);
    final folders = map.ResourceMap<ConfigurationModel>();
    final foldersList = (data['folders'] as List?) ?? <Object?>[];
    for (final value in foldersList) {
      final tuple = value as List;
      folders.set(uri.URI.revive(tuple[0])!, parseModel(tuple[1]));
    }
    return Configuration(
      defaultConfiguration,
      policyConfiguration,
      applicationConfiguration,
      userLocalConfiguration,
      userRemoteConfiguration,
      workspaceConfiguration,
      folders,
      ConfigurationModel.createEmptyModel(logService),
      map.ResourceMap<ConfigurationModel>(),
      logService,
    );
  }

  static ConfigurationModel parseConfigurationModel(
      Map<String, Object?> model, log.ILogServiceType? logService) {
    return ConfigurationModel(
      _asStringObjectMap(model['contents']),
      (model['keys'] as List?)?.cast<String>() ?? <String>[],
      _parseOverrides(model['overrides']),
      model['raw'],
      logService,
    );
  }
}

/// 1:1: `export function mergeChanges(...changes)`
config.IConfigurationChange mergeChanges(List<config.IConfigurationChange> changes) {
  if (changes.isEmpty) {
    return _ChangeCarrier(<String>[], <List<Object?>>[]);
  }
  if (changes.length == 1) return changes.first;
  final keysSet = <String>{};
  final overridesMap = <String, Set<String>>{};
  for (final change in changes) {
    for (final key in change.keys) {
      keysSet.add(key);
    }
    for (final entry in change.overrides) {
      final identifier = entry[0] as String;
      final keys = entry[1] as List;
      final result =
          map.getOrSet(overridesMap, identifier, <String>{});
      for (final key in keys) {
        result.add(key as String);
      }
    }
  }
  final overrides = <List<Object?>>[];
  overridesMap.forEach((identifier, keys) {
    overrides.add(<Object?>[identifier, keys.toList()]);
  });
  return _ChangeCarrier(keysSet.toList(), overrides);
}

/// 1:1: `export class ConfigurationChangeEvent`
class ConfigurationChangeEvent implements config.IConfigurationChangeEvent {
  final String _marker = '\n';
  late final int _markerCode1;
  late final int _markerCode2;
  late final String _affectsConfigStr;

  final Set<String> affectedKeys = <String>{};
  late final int source;
  final config.IConfigurationChange change;
  final Map<String, Object?>? previous;
  final Configuration currentConfiguraiton;
  final workspace.Workspace? currentWorkspace;
  final log.ILogServiceType? _logService;

  ConfigurationChangeEvent(
    this.change,
    this.previous,
    this.currentConfiguraiton,
    this.currentWorkspace,
    this._logService,
  ) {
    _markerCode1 = _marker.codeUnitAt(0);
    _markerCode2 = '.'.codeUnitAt(0);
    for (final key in change.keys) {
      affectedKeys.add(key);
    }
    for (final entry in change.overrides) {
      for (final key in entry[1] as List) {
        affectedKeys.add(key as String);
      }
    }
    final buffer = StringBuffer(_marker);
    for (final key in affectedKeys) {
      buffer.write(key);
      buffer.write(_marker);
    }
    _affectsConfigStr = buffer.toString();
  }

  Configuration? _previousConfiguration;
  Configuration? get previousConfiguration {
    final existing = _previousConfiguration;
    if (existing == null && previous != null) {
      _previousConfiguration =
          Configuration.parse(previous!['data'] as Map<String, Object?>, _logService);
    }
    return _previousConfiguration;
  }

  bool affectsConfiguration(String section,
      [config.IConfigurationOverrides? overrides]) {
    final needle = _marker + section;
    final idx = _affectsConfigStr.indexOf(needle);
    if (idx < 0) return false;
    final pos = idx + needle.length;
    if (pos >= _affectsConfigStr.length) return false;
    final code = _affectsConfigStr.codeUnitAt(pos);
    if (code != _markerCode1 && code != _markerCode2) return false;
    if (overrides != null) {
      final value1 = previousConfiguration?.getValue(section, overrides,
          previous?['workspace'] as workspace.Workspace?);
      final value2 = currentConfiguraiton.getValue(
          section, overrides, currentWorkspace);
      return !objects.equals(value1, value2);
    }
    return true;
  }
}

/// 1:1: `function compare(from, to)`
_CmpResult compare(ConfigurationModel? from, ConfigurationModel? to) {
  final toRaw = to?.rawConfiguration;
  final fromRaw = from?.rawConfiguration;
  final contentsResult = compareConfigurationContents(
    toRaw == null ? null : _ContentsKeys(toRaw.contents, toRaw.keys),
    fromRaw == null ? null : _ContentsKeys(fromRaw.contents, fromRaw.keys),
  );
  final overrides = <List<Object?>>[];
  final fromOverrideIdentifiers = from?.getAllOverrideIdentifiers() ?? <String>[];
  final toOverrideIdentifiers = to?.getAllOverrideIdentifiers() ?? <String>[];
  if (to != null) {
    final added = toOverrideIdentifiers
        .where((key) => !fromOverrideIdentifiers.contains(key));
    for (final identifier in added) {
      overrides.add(<Object?>[
        identifier,
        to.getKeysForOverrideIdentifier(identifier),
      ]);
    }
  }
  if (from != null) {
    final removed = fromOverrideIdentifiers
        .where((key) => !toOverrideIdentifiers.contains(key));
    for (final identifier in removed) {
      overrides.add(<Object?>[
        identifier,
        from.getKeysForOverrideIdentifier(identifier),
      ]);
    }
  }
  if (to != null && from != null) {
    for (final identifier in fromOverrideIdentifiers) {
      if (toOverrideIdentifiers.contains(identifier)) {
        final result = compareConfigurationContents(
          _ContentsKeys(
            from.getOverrideValue(null, identifier) as Map<String, Object?>? ??
                <String, Object?>{},
            from.getKeysForOverrideIdentifier(identifier),
          ),
          _ContentsKeys(
            to.getOverrideValue(null, identifier) as Map<String, Object?>? ??
                <String, Object?>{},
            to.getKeysForOverrideIdentifier(identifier),
          ),
        );
        overrides.add(<Object?>[
          identifier,
          <String>[
            ...result.added,
            ...result.removed,
            ...result.updated,
          ],
        ]);
      }
    }
  }
  return _CmpResult(contentsResult.added, contentsResult.removed,
      contentsResult.updated, overrides);
}

/// 1:1: `function compareConfigurationContents(to, from)`
class _ContentsKeys {
  final Map<String, Object?> contents;
  final List<String> keys;
  _ContentsKeys(this.contents, this.keys);
}

class _CmpResult {
  final List<String> added;
  final List<String> removed;
  final List<String> updated;
  final List<List<Object?>> overrides;
  _CmpResult(this.added, this.removed, this.updated, this.overrides);
}

_CmpResult compareConfigurationContents(
    _ContentsKeys? to, _ContentsKeys? from) {
  final added = to != null
      ? (from != null
          ? to.keys.where((k) => !from.keys.contains(k)).toList()
          : <String>[...to.keys])
      : <String>[];
  final removed = from != null
      ? (to != null
          ? from.keys.where((k) => !to.keys.contains(k)).toList()
          : <String>[...from.keys])
      : <String>[];
  final updated = <String>[];
  if (to != null && from != null) {
    for (final key in from.keys) {
      if (to.keys.contains(key)) {
        final value1 = config.getConfigurationValue(from.contents, key);
        final value2 = config.getConfigurationValue(to.contents, key);
        if (!objects.equals(value1, value2)) updated.add(key);
      }
    }
  }
  return _CmpResult(added, removed, updated, <List<Object?>>[]);
}

/// 1:1: `IConfigurationChange` concrete carrier.
class _ChangeCarrier implements config.IConfigurationChange {
  final List<String> keys;
  final List<List<Object?>> overrides;
  _ChangeCarrier(this.keys, this.overrides);
}
