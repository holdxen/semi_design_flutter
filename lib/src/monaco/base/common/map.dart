// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/map.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure, members, algorithms and control
// flow are preserved. Dart language adaptations (no semantic change):
//   - `ResourceMapKeyFn` interface-call-signature -> Dart typedef.
//   - `MapIterator<T>` / `*generator` -> `Iterator<T>` via `Iterable<T>` and
//     sync* generators; the `_state` "modified during iteration" guard is
//     preserved by checking on every `moveNext()`.
//   - `[Symbol.toStringTag]` / `[Symbol.iterator]` -> ordinary members
//     `symbolToStringTag` / `iterable` (Dart has no computed symbol keys).
//   - `readonly (readonly [URI, T])[]` tuples -> `List<(URI, T)>` records.
//   - `const enum Touch` -> `class Touch { static const ... }`.
//   - `new Error(msg)` -> `StateError(msg)`.
//   - `T | undefined` for map lookups -> `T?`.
// ---------------------------------------------------------------------------

import 'dart:math' as math;

import 'uri.dart';

/// Source: `interface ResourceMapKeyFn { (resource: URI): string; }`.
typedef ResourceMapKeyFn = String Function(URI resource);

V getOrSet<K, V>(Map<K, V> map, K key, V value) {
  V? result = map[key];
  if (result == null) {
    result = value;
    map[key] = value;
  }

  return result!;
}

String mapToString<K, V>(Map<K, V> map) {
  final List<String> entries = <String>[];
  map.forEach((K key, V value) {
    entries.add('$key => $value');
  });

  return 'Map(${map.length}) {${entries.join(', ')}}';
}

String setToString<K>(Set<K> set) {
  final List<K> entries = <K>[];
  set.forEach((K value) {
    entries.add(value);
  });

  return 'Set(${set.length}) {${entries.join(', ')}}';
}

class ResourceMapEntry<T> {
  final URI uri;
  final T value;

  ResourceMapEntry(this.uri, this.value);
}

bool isEntries<T>(dynamic arg) => arg is List;

class ResourceMap<T> {
  static String defaultToKey(URI resource) => resource.toString();

  /// Source: `readonly [Symbol.toStringTag] = 'ResourceMap'`.
  final String symbolToStringTag = 'ResourceMap';

  final Map<String, ResourceMapEntry<T>> map;
  ResourceMapKeyFn toKey;

  /// Source varargs overloads collapsed into one generative constructor.
  ResourceMap([dynamic arg, ResourceMapKeyFn? toKey])
      : map = <String, ResourceMapEntry<T>>{},
        toKey = toKey ?? (arg is ResourceMap<T> ? arg.toKey : defaultToKey) {
    if (arg is ResourceMap<T>) {
      this.toKey = toKey ?? arg.toKey;
      if (identical(this.toKey, arg.toKey)) {
        map.clear();
        arg.map.forEach((String k, ResourceMapEntry<T> v) => map[k] = v);
      } else {
        for (final ResourceMapEntry<T> entry in arg.map.values) {
          set(entry.uri, entry.value);
        }
      }
    } else if (isEntries<T>(arg)) {
      for (final dynamic pair in (arg as List)) {
        final List<dynamic> tuple = pair as List<dynamic>;
        set(tuple[0] as URI, tuple[1] as T);
      }
    }
  }

  ResourceMap<T> set(URI resource, T value) {
    map[toKey(resource)] = ResourceMapEntry<T>(resource, value);
    return this;
  }

  T? get(URI resource) => map[toKey(resource)]?.value;

  bool has(URI resource) => map.containsKey(toKey(resource));

  int get size => map.length;

  void clear() => map.clear();

  bool delete(URI resource) => map.remove(toKey(resource)) != null;

  void forEach(void Function(T value, URI key, ResourceMap<T> map) clb, [Object? thisArg]) {
    // `thisArg` binding has no Dart analogue; the closure already carries it.
    for (final ResourceMapEntry<T> entry in map.values) {
      clb(entry.value, entry.uri, this);
    }
  }

  Iterable<T> values() sync* {
    for (final ResourceMapEntry<T> entry in map.values) {
      yield entry.value;
    }
  }

  Iterable<URI> keys() sync* {
    for (final ResourceMapEntry<T> entry in map.values) {
      yield entry.uri;
    }
  }

  Iterable<(URI, T)> entries() sync* {
    for (final ResourceMapEntry<T> entry in map.values) {
      yield (entry.uri, entry.value);
    }
  }

  /// Source: `*[Symbol.iterator]()`.
  Iterable<(URI, T)> get iterable => entries();
}

class ResourceSet {
  /// Source: `readonly [Symbol.toStringTag]`.
  final String symbolToStringTag = 'ResourceSet';

  final ResourceMap<URI> _map;

  ResourceSet([dynamic entriesOrKey, ResourceMapKeyFn? toKey])
      : _map = (entriesOrKey == null || entriesOrKey is Function)
            ? ResourceMap<URI>(entriesOrKey)
            : ResourceMap<URI>(toKey) {
    if (entriesOrKey != null && entriesOrKey is! Function) {
      for (final URI value in (entriesOrKey as List<URI>)) {
        add(value);
      }
    }
  }

  int get size => _map.size;

  ResourceSet add(URI value) {
    _map.set(value, value);
    return this;
  }

  void clear() => _map.clear();

  bool delete(URI value) => _map.delete(value);

  void forEach(void Function(URI value, URI value2, ResourceSet set) callbackfn, [Object? thisArg]) {
    _map.forEach((URI _value, URI key, ResourceMap<URI> map) => callbackfn(key, key, this));
  }

  bool has(URI value) => _map.has(value);

  Iterable<(URI, URI)> entries() => _map.entries();
  Iterable<URI> keys() => _map.keys();
  Iterable<URI> values() => _map.keys();

  /// Source: `[Symbol.iterator]()`.
  Iterable<URI> get iterable => keys();
}

/// Source: `interface Item<K, V> { previous; next; key; value; }`.
class Item<K, V> {
  Item<K, V>? previous;
  Item<K, V>? next;
  final K key;
  V value;

  Item(this.key, this.value);
}

/// Source: `const enum Touch`.
class Touch {
  const Touch._();
  static const int None = 0;
  static const int AsOld = 1;
  static const int AsNew = 2;
}

class LinkedMap<K, V> {
  /// Source: `readonly [Symbol.toStringTag] = 'LinkedMap'`.
  final String symbolToStringTag = 'LinkedMap';

  late final Map<K, Item<K, V>> _map;
  Item<K, V>? _head;
  Item<K, V>? _tail;
  int _size = 0;
  int _state = 0;

  LinkedMap() {
    _map = <K, Item<K, V>>{};
  }

  void clear() {
    _map.clear();
    _head = null;
    _tail = null;
    _size = 0;
    _state++;
  }

  bool isEmpty() => _head == null && _tail == null;

  int get size => _size;

  V? get first => _head?.value;

  V? get last => _tail?.value;

  bool has(K key) => _map.containsKey(key);

  V? get(K key, [int touch = Touch.None]) {
    final Item<K, V>? item = _map[key];
    if (item == null) {
      return null;
    }
    if (touch != Touch.None) {
      touchItem(item, touch);
    }
    return item.value;
  }

  LinkedMap<K, V> set(K key, V value, [int touch = Touch.None]) {
    Item<K, V>? item = _map[key];
    if (item != null) {
      item.value = value;
      if (touch != Touch.None) {
        touchItem(item, touch);
      }
    } else {
      item = Item<K, V>(key, value);
      switch (touch) {
        case Touch.None:
          addItemLast(item);
          break;
        case Touch.AsOld:
          addItemFirst(item);
          break;
        case Touch.AsNew:
          addItemLast(item);
          break;
        default:
          addItemLast(item);
          break;
      }
      _map[key] = item;
      _size++;
    }
    return this;
  }

  bool delete(K key) => remove(key) != null;

  V? remove(K key) {
    final Item<K, V>? item = _map[key];
    if (item == null) {
      return null;
    }
    _map.remove(key);
    removeItem(item);
    _size--;
    return item.value;
  }

  V? shift() {
    if (_head == null && _tail == null) {
      return null;
    }
    if (_head == null || _tail == null) {
      throw StateError('Invalid list');
    }
    final Item<K, V> item = _head!;
    _map.remove(item.key);
    removeItem(item);
    _size--;
    return item.value;
  }

  void forEach(void Function(V value, K key, LinkedMap<K, V> map) callbackfn, [Object? thisArg]) {
    final int state = _state;
    Item<K, V>? current = _head;
    while (current != null) {
      callbackfn(current.value, current.key, this);
      if (_state != state) {
        throw StateError('LinkedMap got modified during iteration.');
      }
      current = current.next;
    }
  }

  /// The JS source builds an iterator object eagerly, capturing `_state` and
  /// `_head` at call time; Dart `sync*` is lazy. The outer method captures
  /// both eagerly and the inner generator consumes the captured values so the
  /// "modified during iteration" guard has identical behaviour.
  Iterable<K> keys() {
    final int state = _state;
    Item<K, V>? current = _head;
    return _keysFrom(state, current);
  }

  Iterable<K> _keysFrom(int state, Item<K, V>? current) sync* {
    while (current != null) {
      if (_state != state) {
        throw StateError('LinkedMap got modified during iteration.');
      }
      yield current.key;
      current = current.next;
    }
  }

  Iterable<V> values() {
    final int state = _state;
    Item<K, V>? current = _head;
    return _valuesFrom(state, current);
  }

  Iterable<V> _valuesFrom(int state, Item<K, V>? current) sync* {
    while (current != null) {
      if (_state != state) {
        throw StateError('LinkedMap got modified during iteration.');
      }
      yield current.value;
      current = current.next;
    }
  }

  Iterable<(K, V)> entries() {
    final int state = _state;
    Item<K, V>? current = _head;
    return _entriesFrom(state, current);
  }

  Iterable<(K, V)> _entriesFrom(int state, Item<K, V>? current) sync* {
    while (current != null) {
      if (_state != state) {
        throw StateError('LinkedMap got modified during iteration.');
      }
      yield (current.key, current.value);
      current = current.next;
    }
  }

  /// Source: `*[Symbol.iterator]()`.
  Iterable<(K, V)> get iterable => entries();

  void trimOld(int newSize) {
    if (newSize >= size) {
      return;
    }
    if (newSize == 0) {
      clear();
      return;
    }
    Item<K, V>? current = _head;
    int currentSize = size;
    while (current != null && currentSize > newSize) {
      _map.remove(current.key);
      current = current.next;
      currentSize--;
    }
    _head = current;
    _size = currentSize;
    if (current != null) {
      current.previous = null;
    }
    _state++;
  }

  void trimNew(int newSize) {
    if (newSize >= size) {
      return;
    }
    if (newSize == 0) {
      clear();
      return;
    }
    Item<K, V>? current = _tail;
    int currentSize = size;
    while (current != null && currentSize > newSize) {
      _map.remove(current.key);
      current = current.previous;
      currentSize--;
    }
    _tail = current;
    _size = currentSize;
    if (current != null) {
      current.next = null;
    }
    _state++;
  }

  void addItemFirst(Item<K, V> item) {
    // First time Insert
    if (_head == null && _tail == null) {
      _tail = item;
    } else if (_head == null) {
      throw StateError('Invalid list');
    } else {
      item.next = _head;
      _head!.previous = item;
    }
    _head = item;
    _state++;
  }

  void addItemLast(Item<K, V> item) {
    // First time Insert
    if (_head == null && _tail == null) {
      _head = item;
    } else if (_tail == null) {
      throw StateError('Invalid list');
    } else {
      item.previous = _tail;
      _tail!.next = item;
    }
    _tail = item;
    _state++;
  }

  void removeItem(Item<K, V> item) {
    if (identical(item, _head) && identical(item, _tail)) {
      _head = null;
      _tail = null;
    } else if (identical(item, _head)) {
      // This can only happen if size === 1 which is handled
      // by the case above.
      if (item.next == null) {
        throw StateError('Invalid list');
      }
      item.next!.previous = null;
      _head = item.next;
    } else if (identical(item, _tail)) {
      // This can only happen if size === 1 which is handled
      // by the case above.
      if (item.previous == null) {
        throw StateError('Invalid list');
      }
      item.previous!.next = null;
      _tail = item.previous;
    } else {
      final Item<K, V>? next = item.next;
      final Item<K, V>? previous = item.previous;
      if (next == null || previous == null) {
        throw StateError('Invalid list');
      }
      next.previous = previous;
      previous.next = next;
    }
    item.next = null;
    item.previous = null;
    _state++;
  }

  void touchItem(Item<K, V> item, int touch) {
    if (_head == null || _tail == null) {
      throw StateError('Invalid list');
    }
    if (touch != Touch.AsOld && touch != Touch.AsNew) {
      return;
    }

    if (touch == Touch.AsOld) {
      if (identical(item, _head)) {
        return;
      }

      final Item<K, V>? next = item.next;
      final Item<K, V>? previous = item.previous;

      // Unlink the item
      if (identical(item, _tail)) {
        // previous must be defined since item was not head but is tail
        // So there are more than on item in the map
        previous!.next = null;
        _tail = previous;
      } else {
        // Both next and previous are not undefined since item was neither head nor tail.
        next!.previous = previous;
        previous!.next = next;
      }

      // Insert the node at head
      item.previous = null;
      item.next = _head;
      _head!.previous = item;
      _head = item;
      _state++;
    } else if (touch == Touch.AsNew) {
      if (identical(item, _tail)) {
        return;
      }

      final Item<K, V>? next = item.next;
      final Item<K, V>? previous = item.previous;

      // Unlink the item.
      if (identical(item, _head)) {
        // next must be defined since item was not tail but is head
        // So there are more than on item in the map
        next!.previous = null;
        _head = next;
      } else {
        // Both next and previous are not undefined since item was neither head nor tail.
        next!.previous = previous;
        previous!.next = next;
      }
      item.next = null;
      item.previous = _tail;
      _tail!.next = item;
      _tail = item;
      _state++;
    }
  }

  List<(K, V)> toJSON() {
    final List<(K, V)> data = <(K, V)>[];

    forEach((V value, K key, LinkedMap<K, V> map) {
      data.add((key, value));
    });

    return data;
  }

  void fromJSON(List<(K, V)> data) {
    clear();

    for (final (K, V) pair in data) {
      set(pair.$1, pair.$2);
    }
  }
}

abstract class Cache<K, V> extends LinkedMap<K, V> {
  int _limit;
  num _ratio;

  Cache(int limit, [num ratio = 1]) : _limit = limit, _ratio = math.min(math.max(0, ratio), 1);

  int get limit => _limit;
  set limit(int limit) {
    _limit = limit;
    checkTrim();
  }

  num get ratio => _ratio;
  set ratio(num ratio) {
    _ratio = math.min(math.max(0, ratio), 1);
    checkTrim();
  }

  @override
  V? get(K key, [int touch = Touch.AsNew]) => super.get(key, touch);

  V? peek(K key) => super.get(key, Touch.None);

  @override
  Cache<K, V> set(K key, V value, [int touch = Touch.None]) {
    super.set(key, value, Touch.AsNew);
    return this;
  }

  void checkTrim() {
    if (size > _limit) {
      trim((_limit * _ratio).round());
    }
  }

  void trim(int newSize);
}

class LRUCache<K, V> extends Cache<K, V> {
  LRUCache(int limit, [num ratio = 1]) : super(limit, ratio);

  @override
  void trim(int newSize) {
    trimOld(newSize);
  }

  @override
  LRUCache<K, V> set(K key, V value, [int touch = Touch.None]) {
    super.set(key, value);
    checkTrim();
    return this;
  }
}

class MRUCache<K, V> extends Cache<K, V> {
  MRUCache(int limit, [num ratio = 1]) : super(limit, ratio);

  @override
  void trim(int newSize) {
    trimNew(newSize);
  }

  @override
  MRUCache<K, V> set(K key, V value, [int touch = Touch.None]) {
    if (_limit <= size && !has(key)) {
      trim((_limit * _ratio).round() - 1);
    }

    super.set(key, value);
    return this;
  }
}

class CounterSet<T> {
  final Map<T, int> map = <T, int>{};

  CounterSet<T> add(T value) {
    map[value] = (map[value] ?? 0) + 1;
    return this;
  }

  bool delete(T value) {
    int counter = map[value] ?? 0;

    if (counter == 0) {
      return false;
    }

    counter--;

    if (counter == 0) {
      map.remove(value);
    } else {
      map[value] = counter;
    }

    return true;
  }

  bool has(T value) => map.containsKey(value);
}

/// A map that allows access both by keys and values.
/// **NOTE**: values need to be unique.
class BidirectionalMap<K, V> {
  final Map<K, V> _m1 = <K, V>{};
  final Map<V, K> _m2 = <V, K>{};

  BidirectionalMap([List<(K, V)>? entries]) {
    if (entries != null) {
      for (final (K, V) pair in entries) {
        set(pair.$1, pair.$2);
      }
    }
  }

  void clear() {
    _m1.clear();
    _m2.clear();
  }

  void set(K key, V value) {
    final V? previousValue = _m1[key];
    if (previousValue != null) {
      _m2.remove(previousValue);
    }
    _m1[key] = value;
    _m2[value] = key;
  }

  V? get(K key) => _m1[key];

  K? getKey(V value) => _m2[value];

  bool delete(K key) {
    final V? value = _m1[key];
    if (value == null) {
      return false;
    }
    _m1.remove(key);
    _m2.remove(value);
    return true;
  }

  void forEach(void Function(V value, K key, BidirectionalMap<K, V> map) callbackfn, [Object? thisArg]) {
    _m1.forEach((K key, V value) {
      callbackfn(value, key, this);
    });
  }

  Iterable<K> keys() => _m1.keys;
  Iterable<V> values() => _m1.values;
}

class SetMap<K, V> {
  final Map<K, Set<V>> map = <K, Set<V>>{};

  void add(K key, V value) {
    Set<V>? values = map[key];

    if (values == null) {
      values = <V>{};
      map[key] = values;
    }

    values.add(value);
  }

  void delete(K key, V value) {
    final Set<V>? values = map[key];

    if (values == null) {
      return;
    }

    values.remove(value);

    if (values.isEmpty) {
      map.remove(key);
    }
  }

  void forEach(K key, void Function(V value) fn) {
    final Set<V>? values = map[key];

    if (values == null) {
      return;
    }

    values.forEach(fn);
  }

  Set<V> get(K key) {
    final Set<V>? values = map[key];
    if (values == null) {
      return <V>{};
    }
    return values;
  }
}

bool mapsStrictEqualIgnoreOrder(Map<dynamic, dynamic> a, Map<dynamic, dynamic> b) {
  if (identical(a, b)) {
    return true;
  }

  if (a.length != b.length) {
    return false;
  }

  for (final dynamic key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) {
      return false;
    }
  }

  for (final dynamic key in b.keys) {
    if (!a.containsKey(key)) {
      return false;
    }
  }

  return true;
}

/// A map that is addressable with an arbitrary number of keys. This is useful in high performance
/// scenarios where creating a composite key whenever the data is accessed is too expensive.
class NKeyMap<TValue, TKeys extends List<Object>> {
  final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};

  /// Sets a value on the map. Note that unlike a standard `Map`, the first argument is the value.
  /// Source varargs `...keys` -> `List<Object> keys`.
  void set(TValue value, List<Object> keys) {
    Map<dynamic, dynamic> currentMap = _data;
    for (int i = 0; i < keys.length - 1; i++) {
      Map<dynamic, dynamic>? nextMap = currentMap[keys[i]] as Map<dynamic, dynamic>?;
      if (nextMap == null) {
        nextMap = <dynamic, dynamic>{};
        currentMap[keys[i]] = nextMap;
      }
      currentMap = nextMap;
    }
    currentMap[keys[keys.length - 1]] = value;
  }

  TValue? get(List<Object> keys) {
    Map<dynamic, dynamic> currentMap = _data;
    for (int i = 0; i < keys.length - 1; i++) {
      final Map<dynamic, dynamic>? nextMap = currentMap[keys[i]] as Map<dynamic, dynamic>?;
      if (nextMap == null) {
        return null;
      }
      currentMap = nextMap;
    }
    return currentMap[keys[keys.length - 1]] as TValue?;
  }

  bool delete(List<Object> keys) {
    final List<Map<dynamic, dynamic>> maps = <Map<dynamic, dynamic>>[_data];
    Map<dynamic, dynamic> currentMap = _data;
    for (int i = 0; i < keys.length - 1; i++) {
      final Map<dynamic, dynamic>? nextMap = currentMap[keys[i]] as Map<dynamic, dynamic>?;
      if (nextMap == null) {
        return false;
      }
      currentMap = nextMap;
      maps.add(currentMap);
    }
    final bool deleted = currentMap.remove(keys[keys.length - 1]) != null;
    for (int i = keys.length - 2; deleted && i >= 0; i--) {
      if (maps[i + 1].isEmpty) {
        maps[i].remove(keys[i]);
      }
    }
    return deleted;
  }

  bool deleteAll(List<Object?> keys) {
    if (keys.isEmpty) {
      final bool hadData = _data.isNotEmpty;
      _data.clear();
      return hadData;
    }
    final List<Map<dynamic, dynamic>> maps = <Map<dynamic, dynamic>>[_data];
    Map<dynamic, dynamic> currentMap = _data;
    for (int i = 0; i < keys.length - 1; i++) {
      final Map<dynamic, dynamic>? nextMap = currentMap[keys[i]] as Map<dynamic, dynamic>?;
      if (nextMap == null) {
        return false;
      }
      currentMap = nextMap;
      maps.add(currentMap);
    }
    final bool deleted = currentMap.remove(keys[keys.length - 1]) != null;
    for (int i = keys.length - 2; deleted && i >= 0; i--) {
      if (maps[i + 1].isEmpty) {
        maps[i].remove(keys[i]);
      }
    }
    return deleted;
  }

  void clear() {
    _data.clear();
  }

  Iterable<TValue> getAll(List<Object?> keys) sync* {
    Map<dynamic, dynamic> currentMap = _data;
    for (final Object? key in keys) {
      final Map<dynamic, dynamic>? nextMap = currentMap[key] as Map<dynamic, dynamic>?;
      if (nextMap == null) {
        return;
      }
      currentMap = nextMap;
    }
    yield* _values(currentMap);
  }

  Iterable<TValue> values() sync* {
    yield* _values(_data);
  }

  Iterable<TValue> _values(Map<dynamic, dynamic> map) sync* {
    for (final dynamic value in map.values) {
      if (value is Map) {
        yield* _values(value);
      } else {
        yield value as TValue;
      }
    }
  }

  /// Get a textual representation of the map for debugging purposes.
  @override
  String toString() {
    String printMap(Map<dynamic, dynamic> map, int depth) {
      String result = '';
      for (final MapEntry<dynamic, dynamic> entry in map.entries) {
        result += '${'  ' * depth}${entry.key}: ';
        if (entry.value is Map) {
          result += '\n' + printMap(entry.value as Map<dynamic, dynamic>, depth + 1);
        } else {
          result += '${entry.value}\n';
        }
      }
      return result;
    }

    return printMap(_data, 0);
  }
}
