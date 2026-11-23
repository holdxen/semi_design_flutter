// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/collections.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `Record<K,V>` -> Dart `Map<K,V>`;
// `Object.create(null)` -> `{}`; `SetWithKey implements Set` -> `SetMixin`.
// Type aliases IStringDictionary/INumberDictionary have no runtime body and are
// documented at the bottom. Function bodies and control flow are identical.
// ---------------------------------------------------------------------------

import 'dart:collection';

/// Groups the collection into a dictionary based on the provided group function.
Map<K, List<V>> groupBy<K, V>(List<V> data, K Function(V element) groupFn) {
  final Map<K, List<V>> result = {};
  for (final V element in data) {
    final K key = groupFn(element);
    List<V>? target = result[key];
    if (target == null) {
      target = result[key] = <V>[];
    }
    target.add(element);
  }
  return result;
}

Map<K, List<V>> groupByMap<K, V>(List<V> data, K Function(V element) groupFn) {
  final Map<K, List<V>> result = <K, List<V>>{};
  for (final V element in data) {
    final K key = groupFn(element);
    List<V>? target = result[key];
    if (target == null) {
      target = <V>[];
      result[key] = target;
    }
    target.add(element);
  }
  return result;
}

({List<T> removed, List<T> added}) diffSets<T>(Set<T> before, Set<T> after) {
  final List<T> removed = [];
  final List<T> added = [];
  for (final T element in before) {
    if (!after.contains(element)) {
      removed.add(element);
    }
  }
  for (final T element in after) {
    if (!before.contains(element)) {
      added.add(element);
    }
  }
  return (removed: removed, added: added);
}

/// Checks whether two sets contain exactly the same elements.
bool equalSets<T>(Set<T> a, Set<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (final T element in a) {
    if (!b.contains(element)) {
      return false;
    }
  }
  return true;
}

({List<V> removed, List<V> added}) diffMaps<K, V>(Map<K, V> before, Map<K, V> after) {
  final List<V> removed = [];
  final List<V> added = [];
  for (final MapEntry<K, V> entry in before.entries) {
    if (!after.containsKey(entry.key)) {
      removed.add(entry.value);
    }
  }
  for (final MapEntry<K, V> entry in after.entries) {
    if (!before.containsKey(entry.key)) {
      added.add(entry.value);
    }
  }
  return (removed: removed, added: added);
}

/// Computes the intersection of two sets.
Set<T> intersection<T>(Set<T> setA, Iterable<T> setB) {
  final Set<T> result = <T>{};
  for (final T elem in setB) {
    if (setA.contains(elem)) {
      result.add(elem);
    }
  }
  return result;
}

/// A set that uses a key function for equality, mirroring a JS Set keyed by value.
class SetWithKey<T> with SetMixin<T> {
  final Map<Object?, T> _map = <Object?, T>{};
  final Object? Function(T t) toKey;

  SetWithKey(List<T> values, this.toKey) {
    for (final T value in values) {
      add(value);
    }
  }

  @override
  bool add(T value) {
    final Object? key = toKey(value);
    final bool wasPresent = _map.containsKey(key);
    _map[key] = value;
    return !wasPresent;
  }

  /// TS Set.delete; Dart Set uses [remove] (implemented below).
  bool delete(T value) => _map.remove(toKey(value)) != null;

  @override
  bool contains(Object? value) => value is T && _map.containsKey(toKey(value));

  @override
  Iterator<T> get iterator => _map.values.iterator;

  @override
  int get length => _map.length;

  @override
  void clear() {
    _map.clear();
  }

  @override
  T? lookup(Object? value) => value is T ? _map[toKey(value)] : null;

  @override
  bool remove(Object? value) {
    if (value is! T) return false;
    return _map.remove(toKey(value)) != null;
  }

  @override
  Set<T> toSet() => _map.values.toSet();
}

// TS type aliases with no Dart runtime counterpart (not emitted):
//   IStringDictionary<V> = Record<string, V>  -> Map<String, V>
//   INumberDictionary<V> = Record<number, V>  -> Map<num, V>
