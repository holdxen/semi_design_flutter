// 1:1 translation of
// vscode/src/vs/editor/common/model/bracketPairsTextModelPart/bracketPairsTree/smallImmutableSet.ts

const List<int> emptyArr = <int>[];

/// 1:1: `interface IDenseKeyProvider<T>`
abstract class IDenseKeyProvider<T> {
  int getKey(T value);
}

/// Represents an immutable set that works best for a small number of elements.
/// It uses bits to encode element membership efficiently.
///
/// Dart adaptation: the TS cache stores `SmallImmutableSet<any>` and returns it
/// for every `T`. Dart has reified generics, so one instance cannot serve all
/// `T` (a `SmallImmutableSet<Never>` would reject `add(String)` at runtime).
/// Instead the cache is bucketed by `Type`: each `T` gets its own 129-slot
/// cache, preserving the source's identity-sharing semantics per element type.
class SmallImmutableSet<T> {
  static final Map<Type, List<SmallImmutableSet<dynamic>?>> _cache =
      <Type, List<SmallImmutableSet<dynamic>?>>{};

  static SmallImmutableSet<T> _create<T>(
      int items, List<int> additionalItems) {
    final List<SmallImmutableSet<dynamic>?> cache =
        _cache.putIfAbsent(T, () => List<SmallImmutableSet<dynamic>?>.filled(129, null));
    if (items <= 128 && additionalItems.isEmpty) {
      // We create a cache of 128=2^7 elements to cover all sets with up to 7
      // (dense) elements.
      SmallImmutableSet<dynamic>? cached = cache[items];
      if (cached == null) {
        cached = SmallImmutableSet<T>._(items, additionalItems);
        cache[items] = cached;
      }
      return cached as SmallImmutableSet<T>;
    }

    return SmallImmutableSet<T>._(items, additionalItems);
  }

  /// 1:1: `static getEmpty<T>()` (empty is the cache entry for items == 0)
  static SmallImmutableSet<T> getEmpty<T>() => _create<T>(0, emptyArr);

  final int items;
  final List<int> additionalItems;

  SmallImmutableSet._(this.items, this.additionalItems);

  /// 1:1: `add(value, keyProvider)`
  SmallImmutableSet<T> add(T value, IDenseKeyProvider<T> keyProvider) {
    final int key = keyProvider.getKey(value);
    int idx = key >> 5; // divided by 32
    if (idx == 0) {
      // fast path
      final int newItem = (1 << key) | items;
      if (newItem == items) {
        return this;
      }
      return _create<T>(newItem, additionalItems);
    }
    idx--;

    final List<int> newItems = additionalItems.sublist(0);
    // JS `newItems[idx] |= ...` auto-extends a sparse array to idx+1 when idx
    // equals length; Dart lists throw, so fill through idx inclusive.
    while (newItems.length <= idx) {
      newItems.add(0);
    }
    newItems[idx] |= 1 << (key & 31);

    return _create<T>(items, newItems);
  }

  /// 1:1: `has(value, keyProvider)`
  bool has(T value, IDenseKeyProvider<T> keyProvider) {
    final int key = keyProvider.getKey(value);
    int idx = key >> 5; // divided by 32
    if (idx == 0) {
      // fast path
      return (items & (1 << key)) != 0;
    }
    idx--;

    return (((idx < additionalItems.length ? additionalItems[idx] : 0)) &
            (1 << (key & 31))) !=
        0;
  }

  /// 1:1: `merge(other)`
  SmallImmutableSet<T> merge(SmallImmutableSet<T> other) {
    final int merged = items | other.items;

    if (identical(additionalItems, emptyArr) &&
        identical(other.additionalItems, emptyArr)) {
      // fast path
      if (merged == items) {
        return this;
      }
      if (merged == other.items) {
        return other;
      }
      return _create<T>(merged, emptyArr);
    }

    // This can be optimized, but it's not a common case
    final List<int> newItems = <int>[];
    final int maxLen = additionalItems.length > other.additionalItems.length
        ? additionalItems.length
        : other.additionalItems.length;
    for (int i = 0; i < maxLen; i++) {
      final int item1 = i < additionalItems.length ? additionalItems[i] : 0;
      final int item2 =
          i < other.additionalItems.length ? other.additionalItems[i] : 0;
      newItems.add(item1 | item2);
    }

    return _create<T>(merged, newItems);
  }

  /// 1:1: `intersects(other)`
  bool intersects(SmallImmutableSet<T> other) {
    if ((items & other.items) != 0) {
      return true;
    }

    final int minLen = additionalItems.length < other.additionalItems.length
        ? additionalItems.length
        : other.additionalItems.length;
    for (int i = 0; i < minLen; i++) {
      if ((additionalItems[i] & other.additionalItems[i]) != 0) {
        return true;
      }
    }

    return false;
  }

  /// 1:1: `equals(other)`
  bool equals(SmallImmutableSet<T> other) {
    if (items != other.items) {
      return false;
    }

    if (additionalItems.length != other.additionalItems.length) {
      return false;
    }

    for (int i = 0; i < additionalItems.length; i++) {
      if (additionalItems[i] != other.additionalItems[i]) {
        return false;
      }
    }

    return true;
  }
}

/// 1:1: `identityKeyProvider`
final IDenseKeyProvider<int> identityKeyProvider = _IdentityKeyProvider();

class _IdentityKeyProvider implements IDenseKeyProvider<int> {
  @override
  int getKey(int value) => value;
}

/// Assigns values a unique incrementing key.
/// 1:1: `class DenseKeyProvider<T>`
class DenseKeyProvider<T> implements IDenseKeyProvider<T> {
  final Map<T, int> _items = <T, int>{};

  @override
  int getKey(T value) {
    int? existing = _items[value];
    if (existing == null) {
      existing = _items.length;
      _items[value] = existing;
    }
    return existing;
  }

  /// 1:1: `reverseLookup(value): T | undefined`
  T? reverseLookup(int value) {
    for (final MapEntry<T, int> entry in _items.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return null;
  }

  /// 1:1: `reverseLookupSet(set): T[]`
  List<T> reverseLookupSet(SmallImmutableSet<T> set) {
    final List<T> result = <T>[];
    for (final T key in _items.keys) {
      if (set.has(key, this)) {
        result.add(key);
      }
    }
    return result;
  }

  /// 1:1: `keys(): IterableIterator<T>`
  Iterable<T> keys() => _items.keys;
}
