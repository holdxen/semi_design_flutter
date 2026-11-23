// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/instantiation/common/extensions.ts
// Translated 1:1. The two TS `registerSingleton` overloads collapse to one
// Dart function with an optional delayed-instantiation flag; the runtime
// branch (`instanceof SyncDescriptor` / wrap-in-SyncDescriptor) is preserved.
// ---------------------------------------------------------------------------

import 'descriptors.dart';
import 'instantiation.dart' show ServiceIdentifier;

/// 1:1: `const _registry: [ServiceIdentifier<any>, SyncDescriptor<any>][] = []`
final List<List<Object?>> _registry = <List<Object?>>[];

/// 1:1: `export const enum InstantiationType { Eager = 0, Delayed = 1 }`
class InstantiationType {
  static const int Eager = 0;
  static const int Delayed = 1;
  const InstantiationType._();
}

/// 1:1: `registerSingleton<T, Services>(id, ctorOrDescriptor, supportsDelayedInstantiation?)`
void registerSingleton<T>(
  ServiceIdentifier<T> id,
  Object ctorOrDescriptor, [
  Object? supportsDelayedInstantiation,
]) {
  var value = ctorOrDescriptor;
  if (value is! SyncDescriptor) {
    value = SyncDescriptor<T>(
      value as Function,
      <Object?>[],
      supportsDelayedInstantiation == null ? false : _toBool(supportsDelayedInstantiation),
    );
  }
  _registry.add(<Object?>[id, value]);
}

/// 1:1: `Boolean(supportsDelayedInstantiation)` — TS truthiness coercion.
bool _toBool(Object? v) {
  if (v == null || v == false || v == 0 || v == '') return false;
  return true;
}

/// 1:1: `getSingletonServiceDescriptors(): [ServiceIdentifier, SyncDescriptor][]`
List<List<Object?>> getSingletonServiceDescriptors() => _registry;
