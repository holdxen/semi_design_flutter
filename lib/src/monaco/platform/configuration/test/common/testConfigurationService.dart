// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/configuration/test/common/testConfigurationService.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS carriers:
//   - `Record<string, unknown>` -> `Map<String, Object?>` with insertion order.
//   - `undefined` -> [jsUndefined] (distinct from Dart `null` = JS `null`).
//   - `TernarySearchTree.forPaths` -> the already-ported Dart TST.
//   - `Promise.resolve` -> `Future.value`.
//   - `Registry.as<IConfigurationRegistry>(Extensions.Configuration)` ->
//     `platformRegistry.Registry.as(configurationRegistry.Extensions.Configuration)`.
// ---------------------------------------------------------------------------

import '../../../../base/common/event.dart' as events;
import '../../../../base/common/ternarySearchTree.dart' as tst;
import '../../../../base/common/uri.dart' as uri;
import '../../common/configuration.dart' as config;
import '../../common/configurationRegistry.dart' as configurationRegistry;
import '../../../registry/common/platform.dart' as platformRegistry;

/// 1:1: JS `undefined`. Kept public so truth tests can distinguish it from
/// Dart `null` (which is the carrier for JS `null`).
final Object jsUndefined = Object();

/// 1:1: `export class TestConfigurationService implements IConfigurationService`
class TestConfigurationService implements config.IConfigurationServiceType {
  TestConfigurationService([Map<String, Object?>? configuration])
      : _configuration = configuration ?? <String, Object?>{};

  final Map<String, Object?> _configuration;

  /// 1:1: `readonly onDidChangeConfigurationEmitter = new Emitter<...>()`.
  final events.Emitter<config.IConfigurationChangeEvent>
      onDidChangeConfigurationEmitter =
      events.Emitter<config.IConfigurationChangeEvent>();

  /// 1:1: `readonly onDidChangeConfiguration = ...event`.
  @override
  events.Event<config.IConfigurationChangeEvent>
      get onDidChangeConfiguration => onDidChangeConfigurationEmitter.event;

  /// 1:1: `private configurationByRoot = TernarySearchTree.forPaths<...>()`.
  final tst.TernarySearchTree<String, Map<String, Object?>> _configurationByRoot =
      tst.TernarySearchTree.forPaths<Map<String, Object?>>();

  /// 1:1: `private overrideIdentifiers: Map<string, string[]> = new Map()`.
  final Map<String, List<String>> _overrideIdentifiers =
      <String, List<String>>{};

  // ignore: unused_element
  Object? get _serviceBrand => jsUndefined;

  /// 1:1: `public reloadConfiguration<T>(): Promise<T>`.
  @override
  Future<Object?> reloadConfiguration([Object? target]) async => getValue$0();

  /// Direct truth carrier for the generic `Promise<T>` result.
  Future<Object?> reloadConfigurationData() => reloadConfiguration();

  /// 1:1 shared implementation of the four `getValue` overloads.
  ///
  /// Extra dynamic overload mirroring the TypeScript body so truth tests can
  /// also exercise invalid override objects (which the typed overloads cannot
  /// express in Dart).
  Object? getValueDynamic(Object? arg1, [Object? arg2]) {
    final Object? overrides = _isConfigurationOverridesDynamic(arg1)
        ? arg1
        : _isConfigurationOverridesDynamic(arg2)
            ? arg2
            : null;

    Map<String, Object?>? configuration;
    if (overrides != null) {
      final Map<String, Object?> overridesMap =
          overrides as Map<String, Object?>;
      final Object? resource = overridesMap['resource'];
      if (resource is uri.URI) {
        configuration = _configurationByRoot.findSubstr(resource.fsPath);
      }
    }
    configuration ??= _configuration;

    if (arg1 is String) {
      // TS: `configuration[arg1] ?? getConfigurationValue(configuration, arg1)`.
      final Object? direct = configuration[arg1];
      if (direct != null) return direct;
      return config.getConfigurationValue(configuration, arg1, jsUndefined);
    }
    return configuration;
  }

  @override
  Object? getValue$0() => getValueDynamic(null);

  @override
  Object? getValue$1(String section) => getValueDynamic(section);

  @override
  Object? getValue$2(config.IConfigurationOverrides overrides) =>
      getValueDynamic(_overridesToMap(overrides));

  @override
  Object? getValue$3(String section, config.IConfigurationOverrides overrides) =>
      getValueDynamic(section, _overridesToMap(overrides));

  /// 1:1: `public updateValue(key, value): Promise<void>` — deliberately a
  /// no-op in the source test service.
  @override
  Future<void> updateValue$2(String key, Object? value) async {}

  @override
  Future<void> updateValue$3(String key, Object? value, int target) async {}

  @override
  Future<void> updateValue$4(String key, Object? value, Object? overrides) async {}

  @override
  Future<void> updateValue$5(String key, Object? value, Object? overrides,
      int target, [config.IConfigurationUpdateOptions? options]) async {}

  /// 1:1: `public setUserConfiguration(key, value, root?)`.
  Future<void> setUserConfiguration(String key, Object? value,
      [uri.URI? root]) async {
    if (root != null) {
      final Map<String, Object?> configForRoot =
          _configurationByRoot.get(root.fsPath) ?? <String, Object?>{};
      configForRoot[key] = value;
      _configurationByRoot.set(root.fsPath, configForRoot);
    } else {
      _configuration[key] = value;
    }
  }

  /// 1:1: `public setOverrideIdentifiers(key, identifiers)`.
  void setOverrideIdentifiers(String key, List<String> identifiers) {
    _overrideIdentifiers[key] = identifiers;
  }

  /// 1:1: `public inspect<T>(key, overrides?)`.
  @override
  Map<String, Object?> inspect(String key,
      [config.IConfigurationOverrides? overrides]) {
    final Object? value = getValueDynamic(
      key,
      overrides == null ? null : _overridesToMap(overrides),
    );
    return <String, Object?>{
      'value': value,
      'defaultValue': jsUndefined,
      'userValue': value,
      'userLocalValue': value,
      'overrideIdentifiers': _overrideIdentifiers[key] ?? jsUndefined,
    };
  }

  /// 1:1: `public keys()`.
  @override
  Map<String, Object?> keys() {
    final Object? registered = platformRegistry.Registry.as(
        configurationRegistry.Extensions.Configuration);
    final Map<String, Object?> properties = registered == null
        ? <String, Object?>{}
        : (registered as configurationRegistry.IConfigurationRegistryType)
            .getConfigurationProperties();
    return <String, Object?>{
      'default': properties.keys.toList(),
      'policy': <Object?>[],
      'user': _configuration.keys.toList(),
      'workspace': <Object?>[],
      'workspaceFolder': <Object?>[],
    };
  }

  /// 1:1: `public getConfigurationData() { return null; }`.
  @override
  Map<String, Object?>? getConfigurationData() => null;

  static Map<String, Object?> _overridesToMap(
          config.IConfigurationOverrides overrides) =>
      <String, Object?>{
        'overrideIdentifier': overrides.overrideIdentifier,
        'resource': overrides.resource,
      };

  static bool _isConfigurationOverridesDynamic(Object? obj) {
    Object? candidate = obj;
    if (candidate is config.IConfigurationOverrides) {
      candidate = _overridesToMap(candidate);
    }
    return config.isConfigurationOverrides(candidate) == true;
  }
}
