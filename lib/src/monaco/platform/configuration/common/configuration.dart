// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/configuration/common/configuration.ts
// Translated 1:1. `const enum` -> class of static const ints; const/interface
// name clash -> const keeps `IConfigurationService`, interface gets `Type`;
// overloads -> `$n` suffix with a single shared real implementation; TS object
// structural types -> Map<String, Object?> carriers; `unknown` -> Object?.
// Runtime truth: tool/ts2dart/_configuration_truth.cjs (recursive TS
// transpile+vm, real uri.ts / instantiation.ts / json.ts / types.ts).
// ---------------------------------------------------------------------------

import 'dart:async' show Future;

import '../../../base/common/assert.dart' show assertNever;
import '../../../base/common/event.dart' show Event;
import '../../../base/common/json.dart' show setObjectProperty;
import '../../../base/common/types.dart' show isObject;
import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IConfigurationService = createDecorator<IConfigurationService>('configurationService')`
final ServiceIdentifier<IConfigurationServiceType> IConfigurationService =
    createDecorator<IConfigurationServiceType>('configurationService');

/// 1:1 JS truthiness — falsy for null/false/0/''/NaN (used by the `&&` guard
/// chains below, whose operands are `unknown`).
bool _jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// 1:1: `!thing.resource || thing.resource instanceof URI`.
bool _isFalsyOrUri(Object? resource) =>
    !_jsTruthy(resource) || resource is URI;

/// 1:1: `!x || typeof x === 'string'`.
bool _isFalsyOrString(Object? x) => !_jsTruthy(x) || x is String;

/// 1:1: `(!x || Array.isArray(x))`.
bool _isFalsyOrArray(Object? x) => !_jsTruthy(x) || x is List;

/// 1:1: `export function isConfigurationOverrides(obj): obj is IConfigurationOverrides`
///
/// The JS `&&` chain returns the first falsy operand itself (e.g. `null` when
/// `obj == null`, `false` for a non-object), so the return type is `Object?`
/// and the short-circuit value is reproduced exactly.
Object? isConfigurationOverrides(Object? obj) {
  final thing = obj;
  if (!_jsTruthy(thing)) return thing;
  if (thing is! Map<String, Object?>) return false;
  if (!_isFalsyOrString(thing['overrideIdentifier'])) return false;
  if (!_isFalsyOrUri(thing['resource'])) return false;
  return true;
}

/// 1:1: `export interface IConfigurationOverrides`
abstract class IConfigurationOverrides {
  String? get overrideIdentifier;
  URI? get resource;
}

/// 1:1: `export function isConfigurationUpdateOverrides(obj): obj is IConfigurationUpdateOverrides`
Object? isConfigurationUpdateOverrides(Object? obj) {
  final thing = obj;
  if (!_jsTruthy(thing)) return thing;
  if (thing is! Map<String, Object?>) return false;
  if (!_isFalsyOrArray(thing['overrideIdentifiers'])) return false;
  if (_jsTruthy(thing['overrideIdentifier'])) return false;
  if (!_isFalsyOrUri(thing['resource'])) return false;
  return true;
}

/// 1:1: `export type IConfigurationUpdateOverrides = Omit<IConfigurationOverrides, 'overrideIdentifier'> & { overrideIdentifiers?: string[] | null }`
/// Structural type -> Map carrier (no runtime body in TS).
typedef IConfigurationUpdateOverrides = Map<String, Object?>;

/// 1:1: `export const enum ConfigurationTarget`
class ConfigurationTarget {
  static const int APPLICATION = 1;
  static const int USER = 2;
  static const int USER_LOCAL = 3;
  static const int USER_REMOTE = 4;
  static const int WORKSPACE = 5;
  static const int WORKSPACE_FOLDER = 6;
  static const int DEFAULT = 7;
  static const int MEMORY = 8;
}

/// 1:1: `export function ConfigurationTargetToString(configurationTarget)`
String? ConfigurationTargetToString(int configurationTarget) {
  switch (configurationTarget) {
    case ConfigurationTarget.APPLICATION:
      return 'APPLICATION';
    case ConfigurationTarget.USER:
      return 'USER';
    case ConfigurationTarget.USER_LOCAL:
      return 'USER_LOCAL';
    case ConfigurationTarget.USER_REMOTE:
      return 'USER_REMOTE';
    case ConfigurationTarget.WORKSPACE:
      return 'WORKSPACE';
    case ConfigurationTarget.WORKSPACE_FOLDER:
      return 'WORKSPACE_FOLDER';
    case ConfigurationTarget.DEFAULT:
      return 'DEFAULT';
    case ConfigurationTarget.MEMORY:
      return 'MEMORY';
  }
  return null; // JS: implicit undefined for out-of-range values.
}

/// 1:1: `export interface IConfigurationChange`
abstract class IConfigurationChange {
  List<String> get keys;
  List<List<Object?>> get overrides;
}

/// 1:1: `export interface IConfigurationChangeEvent`
abstract class IConfigurationChangeEvent {
  int get source;
  Set<String> get affectedKeys;
  IConfigurationChange get change;
  bool affectsConfiguration(String configuration,
      [IConfigurationOverrides? overrides]);
}

/// 1:1: `export interface IInspectValue<T>`
abstract class IInspectValue<T> {
  T? get value;
  T? get override;
  List<Map<String, Object?>>? get overrides;
}

/// 1:1: `export interface IConfigurationValue<T>`
abstract class IConfigurationValue<T> {
  T? get defaultValue;
  T? get applicationValue;
  T? get userValue;
  T? get userLocalValue;
  T? get userRemoteValue;
  T? get workspaceValue;
  T? get workspaceFolderValue;
  T? get memoryValue;
  T? get policyValue;
  T? get value;

  IInspectValue<T>? get default_;
  IInspectValue<T>? get application;
  IInspectValue<T>? get user;
  IInspectValue<T>? get userLocal;
  IInspectValue<T>? get userRemote;
  IInspectValue<T>? get workspace;
  IInspectValue<T>? get workspaceFolder;
  IInspectValue<T>? get memory;
  Map<String, Object?>? get policy;

  List<String>? get overrideIdentifiers;
}

/// 1:1: `export function getConfigValueInTarget<T>(configValue, scope): T | undefined`
Object? getConfigValueInTarget(Map<String, Object?> configValue, int scope) {
  switch (scope) {
    case ConfigurationTarget.APPLICATION:
      return configValue['applicationValue'];
    case ConfigurationTarget.USER:
      return configValue['userValue'];
    case ConfigurationTarget.USER_LOCAL:
      return configValue['userLocalValue'];
    case ConfigurationTarget.USER_REMOTE:
      return configValue['userRemoteValue'];
    case ConfigurationTarget.WORKSPACE:
      return configValue['workspaceValue'];
    case ConfigurationTarget.WORKSPACE_FOLDER:
      return configValue['workspaceFolderValue'];
    case ConfigurationTarget.DEFAULT:
      return configValue['defaultValue'];
    case ConfigurationTarget.MEMORY:
      return configValue['memoryValue'];
    default:
      return assertNever(scope);
  }
}

/// 1:1: `export function isConfigured<T>(configValue): configValue is ... & { value: T }`
///
/// Source checks `!== undefined` (not truthiness), so `null`, `0` and `''` all
/// count as configured. A Dart Map's `containsKey` is the `!== undefined`
/// carrier: a present key (even holding `null`) is a configured value.
bool isConfigured(Map<String, Object?> configValue) =>
    configValue.containsKey('applicationValue') ||
    configValue.containsKey('userValue') ||
    configValue.containsKey('userLocalValue') ||
    configValue.containsKey('userRemoteValue') ||
    configValue.containsKey('workspaceValue') ||
    configValue.containsKey('workspaceFolderValue');

/// 1:1: `export interface IConfigurationUpdateOptions`
abstract class IConfigurationUpdateOptions {
  bool? get donotNotifyError;
  String? get handleDirtyFile; // 'save' | 'revert'
}

/// 1:1: `export interface IConfigurationService` (const keeps the bare name)
abstract class IConfigurationServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Event<IConfigurationChangeEvent> get onDidChangeConfiguration;

  Map<String, Object?>? getConfigurationData();

  /// 1:1 overloads (shared carrier): `getValue<T>()` / `(section)` /
  /// `(overrides)` / `(section, overrides)`.
  Object? getValue$0();
  Object? getValue$1(String section);
  Object? getValue$2(IConfigurationOverrides overrides);
  Object? getValue$3(String section, IConfigurationOverrides overrides);

  /// 1:1 overloads (shared carrier): `updateValue` with 2..5 args.
  Future<void> updateValue$2(String key, Object? value);
  Future<void> updateValue$3(String key, Object? value, int target);
  Future<void> updateValue$4(String key, Object? value,
      Object? overrides); // IConfigurationOverrides | IConfigurationUpdateOverrides
  Future<void> updateValue$5(String key, Object? value, Object? overrides,
      int target, [IConfigurationUpdateOptions? options]);

  Map<String, Object?> inspect(String key, [IConfigurationOverrides? overrides]);

  Future<void> reloadConfiguration([Object? target]); // int | IWorkspaceFolder

  Map<String, Object?> keys();
}

/// 1:1: `export interface IConfigurationModel`
abstract class IConfigurationModel {
  Map<String, Object?> get contents;
  List<String> get keys;
  List<Map<String, Object?>> get overrides;
  Object? get raw;
}

/// 1:1: `export interface IOverrides`
abstract class IOverrides {
  List<String> get keys;
  Map<String, Object?> get contents;
  List<String> get identifiers;
}

/// 1:1: `export interface IConfigurationData`
abstract class IConfigurationData {
  IConfigurationModel get defaults;
  IConfigurationModel get policy;
  IConfigurationModel get application;
  IConfigurationModel get userLocal;
  IConfigurationModel get userRemote;
  IConfigurationModel get workspace;
  List<List<Object?>> get folders; // [UriComponents, IConfigurationModel][]
}

/// 1:1: `export interface IConfigurationCompareResult`
abstract class IConfigurationCompareResult {
  List<String> get added;
  List<String> get removed;
  List<String> get updated;
  List<List<Object?>> get overrides;
}

/// 1:1 JS `JSON.stringify(value)` for the conflict messages below. Integral
/// doubles print without `.0` (matching TS `_jsNum` convention).
String _jsStringify(Object? value) {
  if (value == null) return 'null';
  if (value is String) return '"${value.replaceAll('"', '\\"')}"';
  if (value is bool) return value ? 'true' : 'false';
  if (value is int) return value.toString();
  if (value is double) {
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }
  if (value is List) {
    return '[${value.map((e) => _jsStringify(e)).join(',')}]';
  }
  if (value is Map) {
    return '{${value.entries
        .map((e) => '"${e.key}":${_jsStringify(e.value)}')
        .join(',')}}';
  }
  return '"${value}"';
}

/// 1:1: `export function toValuesTree(properties, conflictReporter)`
Map<String, Object?> toValuesTree(Map<String, Object?> properties,
    void Function(String message) conflictReporter) {
  final root = <String, Object?>{}; // Object.create(null)
  properties.forEach((key, value) {
    addToValueTree(root, key, value, conflictReporter);
  });
  return root;
}

/// 1:1: `export function addToValueTree(settingsTreeRoot, key, value, conflictReporter)`
void addToValueTree(Map<String, Object?> settingsTreeRoot, String key,
    Object? value, void Function(String message) conflictReporter) {
  final segments = key.split('.');
  final last = segments.removeLast();

  Map<String, Object?> curr = settingsTreeRoot;
  for (int i = 0; i < segments.length; i++) {
    final s = segments[i];
    final prefix = segments.sublist(0, i + 1).join('.');
    Object? obj;
    if (!curr.containsKey(s)) {
      // JS: `Object.hasOwn(curr, s) ? curr[s] : undefined` -> typeof 'undefined'
      obj = <String, Object?>{}; // Object.create(null)
      setObjectProperty(curr, s, obj);
    } else {
      obj = curr[s];
      if (obj == null) {
        // Dart `null` carrier = JS null here (key present), so typeof 'object'
        // with `obj === null`.
        conflictReporter('Ignoring $key as $prefix is null');
        return;
      }
      if (obj is! Map<String, Object?> && obj is! List) {
        conflictReporter('Ignoring $key as $prefix is ${_jsStringify(obj)}');
        return;
      }
    }
    // JS `curr = obj as IStringDictionary` — a JS array also accepts string
    // properties; the detached carrier mirrors that (the truth normalizer
    // exposes only Map keys, so array-hosted props stay unobservable).
    curr = obj is Map<String, Object?> ? obj : <String, Object?>{};
  }

  // JS: `typeof curr === 'object' && curr !== null` — Dart `curr` is always a
  // Map here (a non-null object), so assignment succeeds. `try/catch` mirrors
  // the source's workaround for frozen objects (issue #13606).
  try {
    curr[last] = value;
  } catch (e) {
    conflictReporter(
        'Ignoring $key as ${segments.join('.')} is ${_jsStringify(curr)}');
  }
}

/// 1:1: `export function removeFromValueTree(valueTree, key)`
void removeFromValueTree(Map<String, Object?> valueTree, String key) {
  final segments = key.split('.');
  _doRemoveFromValueTree(valueTree, segments);
}

/// 1:1: `function doRemoveFromValueTree(valueTree, segments)`
void _doRemoveFromValueTree(Object? valueTree, List<String> segments) {
  if (!_jsTruthy(valueTree)) return;

  final valueTreeRecord = valueTree as Map<String, Object?>;
  final first = segments.removeAt(0);
  if (segments.isEmpty) {
    valueTreeRecord.remove(first);
    return;
  }

  if (valueTreeRecord.containsKey(first)) {
    final value = valueTreeRecord[first];
    if (value is Map<String, Object?>) {
      _doRemoveFromValueTree(value, segments);
      if (value.isEmpty) {
        valueTreeRecord.remove(first);
      }
    }
  }
}

/// Marker for the JS `undefined` produced by `accessSetting` when a path
/// component is missing or a non-object is traversed. Distinct from Dart
/// `null` (= JS `null` when a key exists holding null), matching the source's
/// `typeof result === 'undefined' ? defaultValue : result`.
final Object _jsUndefined = Object();

/// 1:1: `export function getConfigurationValue<T>(config, settingPath, defaultValue?)`
///
/// Overloads:
///   `getConfigurationValue<T>(config, settingPath): T | undefined`
///   `getConfigurationValue<T>(config, settingPath, defaultValue: T): T`
Object? getConfigurationValue(Map<String, Object?> config, String settingPath,
    [Object? defaultValue]) {
  Object? accessSetting(Object? config, List<String> path) {
    Object? current = config;
    for (final component in path) {
      // JS: `typeof current !== 'object' || current === null` -> undefined.
      // Both Map and List are JS objects; a JS array accepts numeric-string
      // component access (`arr['1']`), so mirror that for Lists.
      if (current is Map<String, Object?>) {
        if (!current.containsKey(component)) return _jsUndefined;
        current = current[component];
      } else if (current is List) {
        final idx = int.tryParse(component);
        if (idx == null || idx < 0 || idx >= current.length) return _jsUndefined;
        current = current[idx];
      } else {
        return _jsUndefined;
      }
    }
    return current;
  }

  final path = settingPath.split('.');
  final result = accessSetting(config, path);
  return identical(result, _jsUndefined) ? defaultValue : result;
}

/// 1:1: `export function merge(base, add, overwrite)`
void merge(Map<String, Object?> base, Map<String, Object?> add, bool overwrite) {
  add.forEach((key, addValue) {
    if (key != '__proto__') {
      if (base.containsKey(key)) {
        final baseValue = base[key];
        if (isObject(baseValue) && isObject(addValue)) {
          merge(baseValue as Map<String, Object?>,
              addValue as Map<String, Object?>, overwrite);
        } else if (overwrite) {
          base[key] = addValue;
        }
      } else {
        base[key] = addValue;
      }
    }
  });
}

/// 1:1: `export function getLanguageTagSettingPlainKey(settingKey)`
String getLanguageTagSettingPlainKey(String settingKey) => settingKey
    .replaceAll(RegExp(r'^\['), '')
    .replaceAll(RegExp(r']$'), '')
    .replaceAll(RegExp(r'\]\['), ', ');
