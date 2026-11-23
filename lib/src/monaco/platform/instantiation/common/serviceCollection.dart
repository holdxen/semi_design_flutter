// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/instantiation/common/serviceCollection.ts
// Translated 1:1. The TS `Map<ServiceIdentifier<any>, any>` becomes a Dart
// `Map` keyed by ServiceIdentifier (identity equality — see instantiation.dart).
// ---------------------------------------------------------------------------

import 'instantiation.dart' show ServiceIdentifier;

/// 1:1: `export class ServiceCollection`
class ServiceCollection {
  /// 1:1: `private _entries = new Map<ServiceIdentifier<any>, any>()`
  final Map<ServiceIdentifier, Object?> _entries = <ServiceIdentifier, Object?>{};

  /// 1:1: `constructor(...entries: [ServiceIdentifier<any>, any][])`
  ServiceCollection([List<List<Object?>> entries = const <List<Object?>>[]]) {
    for (final entry in entries) {
      set(entry[0] as ServiceIdentifier, entry[1]);
    }
  }

  /// 1:1: `set<T>(id, instanceOrDescriptor): T | SyncDescriptor<T>`
  Object? set<T>(ServiceIdentifier<T> id, Object? instanceOrDescriptor) {
    final result = _entries[id];
    _entries[id] = instanceOrDescriptor;
    return result;
  }

  /// 1:1: `has(id): boolean`
  bool has(ServiceIdentifier id) => _entries.containsKey(id);

  /// 1:1: `get<T>(id): T | SyncDescriptor<T>`
  Object? get<T>(ServiceIdentifier<T> id) => _entries[id];

  /// 1:1: `clone(): ServiceCollection`
  ServiceCollection clone() {
    final copy = ServiceCollection();
    _entries.forEach((k, v) => copy._entries[k] = v);
    return copy;
  }
}
