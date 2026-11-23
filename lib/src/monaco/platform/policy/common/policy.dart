// 1:1 port of vs/platform/policy/common/policy.ts
// TS `IStringDictionary<V>` -> Dart `Map<String, V>` (no runtime body in TS).
import '../../../base/common/event.dart' show Emitter, Event, eventNone;
import '../../../base/common/iterator.dart' show IterableX;
import '../../../base/common/lifecycle.dart' show Disposable;
import '../../../base/common/policy.dart' show PolicyName;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export type PolicyValue = string | number | boolean`
typedef PolicyValue = Object?;

/// 1:1: `export const enum PolicyValueSource`
class PolicyValueSource {
  static const String Device = 'device';
  static const String NativeMdm = 'nativeMdm';
  static const String ServerManagedSettings = 'serverManagedSettings';
  static const String FileManagedSettings = 'fileManagedSettings';
  static const String MixedManagedSettings = 'mixedManagedSettings';
  static const String Account = 'account';
  static const String AccountGate = 'accountGate';

  const PolicyValueSource._();
}

/// 1:1: `export type PolicyDefinition`
class PolicyDefinition {
  final String type;
  final PolicyValue? Function(Object? policyData)? value;
  /// Carrier for TS `IManagedSettingsPolicyDefinitions` (opaque pass-through).
  final Object? managedSettings;
  final PolicyValue? restrictedValue;

  PolicyDefinition({
    required this.type,
    this.value,
    this.managedSettings,
    this.restrictedValue,
  });
}

/// 1:1: `toSerializablePolicyDefinition(definition)` — drops the non-cloneable
/// `value` callback by building a fresh [PolicyDefinition] without it.
PolicyDefinition toSerializablePolicyDefinition(PolicyDefinition definition) =>
    PolicyDefinition(
      type: definition.type,
      managedSettings: definition.managedSettings,
      restrictedValue: definition.restrictedValue,
    );

/// 1:1: `getRestrictedPolicyValue(definition)`
PolicyValue getRestrictedPolicyValue(PolicyDefinition definition) {
  // TS `!== undefined`: keep falsy restricted values (false/0/'') intact.
  if (definition.restrictedValue != null) {
    return definition.restrictedValue;
  }
  switch (definition.type) {
    case 'boolean':
      return false;
    case 'number':
      return 0;
    case 'string':
      return '';
  }
  // TS switch has no default; falls through to `undefined` return.
  return null;
}

/// 1:1: `export const IPolicyService = createDecorator<IPolicyService>('policy')`
final ServiceIdentifier<IPolicyServiceType> IPolicyService =
    createDecorator<IPolicyServiceType>('policy');

/// 1:1: `export interface IPolicyService` (Type suffix avoids clash with the
/// decorator value above).
abstract class IPolicyServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Event<List<PolicyName>> get onDidChange;

  Future<Map<String, PolicyValue>> updatePolicyDefinitions(
      Map<String, PolicyDefinition> policyDefinitions);

  PolicyValue? getPolicyValue(PolicyName name);

  String? getPolicyValueSource(PolicyName name);

  Map<String, Map<String, Object?>>? serialize();

  Map<String, PolicyDefinition> get policyDefinitions;
}

/// 1:1: `export abstract class AbstractPolicyService extends Disposable implements IPolicyService`
abstract class AbstractPolicyService extends Disposable
    implements IPolicyServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  Map<String, PolicyDefinition> policyDefinitions = <String, PolicyDefinition>{};

  /// 1:1: `protected policies = new Map<PolicyName, PolicyValue>()`
  /// Made public for cross-library subclassing (Dart has no `protected`).
  final Map<PolicyName, PolicyValue> policies = <PolicyName, PolicyValue>{};

  /// 1:1: `private readonly policyValueSources`
  final Map<PolicyName, String> _policyValueSources = <PolicyName, String>{};

  /// 1:1: `protected readonly _onDidChange = this._register(new Emitter<readonly PolicyName[]>())`
  late final Emitter<List<PolicyName>> _onDidChange;

  @override
  late final Event<List<PolicyName>> onDidChange;

  AbstractPolicyService() {
    _onDidChange = register(Emitter<List<PolicyName>>());
    onDidChange = _onDidChange.event;
  }

  /// 1:1: `async updatePolicyDefinitions(policyDefinitions)`
  @override
  Future<Map<String, PolicyValue>> updatePolicyDefinitions(
      Map<String, PolicyDefinition> policyDefinitions) async {
    // Identity comparison avoids redundant watcher churn.
    bool changed = false;
    for (final name in policyDefinitions.keys) {
      if (!identical(this.policyDefinitions[name], policyDefinitions[name])) {
        this.policyDefinitions[name] = policyDefinitions[name]!;
        changed = true;
      }
    }
    if (changed) {
      await updatePolicyDefinitionsInternal(this.policyDefinitions);
    }
    return getPolicyValues();
  }

  @override
  PolicyValue? getPolicyValue(PolicyName name) => policies[name];

  @override
  String? getPolicyValueSource(PolicyName name) =>
      getStoredPolicyValueSource(name);

  /// 1:1: `private getStoredPolicyValueSource(name)`
  String? getStoredPolicyValueSource(PolicyName name) {
    if (!policies.containsKey(name)) {
      return null;
    }
    return _policyValueSources[name] ?? PolicyValueSource.Device;
  }

  /// 1:1: `serialize()`
  @override
  Map<String, Map<String, Object?>> serialize() {
    return IterableX.reduce<MapEntry<PolicyName, PolicyDefinition>,
        Map<String, Map<String, Object?>>>(
      policyDefinitions.entries,
      (r, entry) => <String, Map<String, Object?>>{
        ...r,
        entry.key: <String, Object?>{
          'definition': toSerializablePolicyDefinition(entry.value),
          'value': policies[entry.key],
        },
      },
      <String, Map<String, Object?>>{},
    );
  }

  /// 1:1: `protected getPolicyValues()`
  Map<String, PolicyValue> getPolicyValues() {
    return IterableX.reduce<MapEntry<PolicyName, PolicyValue>,
        Map<String, PolicyValue>>(
      policies.entries,
      (r, entry) => <String, PolicyValue>{...r, entry.key: entry.value},
      <String, PolicyValue>{},
    );
  }

  /// 1:1: `protected updatePolicyValue(name, value, source)`
  bool updatePolicyValue(
    PolicyName name,
    PolicyValue? value, [
    String source = PolicyValueSource.Device,
  ]) {
    if (value == null) {
      final valueDeleted = policies.remove(name) != null;
      final sourceDeleted = _policyValueSources.remove(name) != null;
      return valueDeleted || sourceDeleted;
    }

    final valueChanged = policies[name] != value;
    final sourceChanged = getStoredPolicyValueSource(name) != source;
    if (!valueChanged && !sourceChanged) {
      return false;
    }

    policies[name] = value;
    _policyValueSources[name] = source;
    return true;
  }

  /// 1:1: `protected clearPolicyValues()`
  void clearPolicyValues() {
    policies.clear();
    _policyValueSources.clear();
  }

  /// 1:1: `protected abstract _updatePolicyDefinitions(policyDefinitions)`
  /// Public (no underscore) so cross-library subclasses can override it (Dart
  /// has no `protected`, and a leading `_` is library-private).
  Future<void> updatePolicyDefinitionsInternal(
      Map<String, PolicyDefinition> policyDefinitions);

  /// Bridge for tests: fires the real emitter along the production path.
  void fireOnDidChange(List<PolicyName> names) => _onDidChange.fire(names);
}

/// 1:1: `export class NullPolicyService implements IPolicyService`
class NullPolicyService implements IPolicyServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  Event<List<PolicyName>> get onDidChange => eventNone;

  @override
  Future<Map<String, PolicyValue>> updatePolicyDefinitions(
          Map<String, PolicyDefinition> policyDefinitions) async =>
      <String, PolicyValue>{};

  @override
  PolicyValue? getPolicyValue([PolicyName? name]) => null;

  @override
  String? getPolicyValueSource([PolicyName? name]) => null;

  @override
  Map<String, Map<String, Object?>>? serialize() => null;

  @override
  Map<String, PolicyDefinition> policyDefinitions = <String, PolicyDefinition>{};
}
