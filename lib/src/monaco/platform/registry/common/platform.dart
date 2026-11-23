// 1:1 translation of vscode/src/vs/platform/registry/common/platform.ts
// Adaptations (documented inline):
//   - `interface IRegistry` → abstract class.
//   - `Map<string, any>` → Map<String, Object?>.
//   - `as<T>(id): T` → `Object? as(String id)` (Dart has no reified generic
//     returns without a cast at the call site, matching the TS `as<T>` usage).
//   - `data.get(id) || null` → `data[id]` (stored values are objects/functions,
//     i.e. always truthy; a missing key maps to null exactly like the TS `|| null`).

import '../../../base/common/assert.dart' as Assert;
import '../../../base/common/types.dart' as Types;

/// 1:1: `export interface IRegistry`
abstract class IRegistry {
  void add(String id, Object data);
  bool knows(String id);
  Object? as(String id);
}

/// JS `typeof data === 'object'` carrier predicate for registry entries.
bool _isJsObject(Object? data) =>
    data != null &&
    data is! String &&
    data is! num &&
    data is! bool &&
    data is! Function &&
    data is! List &&
    data is! RegExp &&
    data is! DateTime;

/// 1:1: `class RegistryImpl implements IRegistry`
class RegistryImpl implements IRegistry {
  final Map<String, Object?> _data = <String, Object?>{};

  @override
  void add(String id, Object data) {
    Assert.ok(Types.isString(id));
    // JS `Types.isObject` accepts class instances; the generic Dart carrier in
    // `base/common/types.dart` is Map-only. Mirror the JS predicate here so
    // registry entries can carry service objects exactly as in TypeScript.
    Assert.ok(_isJsObject(data));
    Assert.ok(!_data.containsKey(id), 'There is already an extension with this id');
    _data[id] = data;
  }

  @override
  bool knows(String id) => _data.containsKey(id);

  @override
  Object? as(String id) => _data[id];

  void dispose() {
    for (final Object? value in _data.values) {
      // TS: `if (Types.isFunction(value.dispose)) value.dispose();`
      // data is `any`, so use dynamic to read the `dispose` property.
      final dynamic v = value;
      if (v != null && Types.isFunction(v.dispose)) {
        v.dispose();
      }
    }
    _data.clear();
  }
}

/// 1:1: `export const Registry: IRegistry = new RegistryImpl()`
final IRegistry Registry = RegistryImpl();
