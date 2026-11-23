// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/map.ts (1:1).
//
// Bridge note: TS `ObservableMap<K,V> implements Map<K,V>` uses the JS
// `Map.forEach(value, key, map)` callback order. Dart's `Map.forEach` uses
// `(key, value)`; implementing Dart's `Map` interface would change observable
// callback semantics. This class therefore mirrors the TS class surface as a
// standalone type backed by a Dart Map, preserving 1:1 behavior (verified by
// batch82_truth.json). `_obs.set(this, ...)` carries the ObservableMap itself
// as the observable value, exactly like TS.
// ---------------------------------------------------------------------------

import '../observable.dart' show IObservable, ISettableObservable, ITransaction;
import 'observables/observableValueOpts.dart'
    show ObservableValueOpts, observableValueOpts;

class ObservableMap<K, V> {
  ObservableMap() {
    _obs = observableValueOpts<Object?, Object?>(
      ObservableValueOpts<Object?>(equalsFn: (a, b) => false),
      this,
    );
    observable = _obs;
  }

  final Map<K, V> _data = <K, V>{};

  late final ISettableObservable<Object?, Object?> _obs;

  /// 1:1: `readonly observable` typed `IObservable<Map>` = `this._obs`
  /// (Dart carries the value as Object? to avoid a Map interface mismatch.)
  late final IObservable<Object?> observable;

  int get size => _data.length;

  bool has(K key) => _data.containsKey(key);

  V? get(K key) => _data[key];

  ObservableMap<K, V> set(K key, V value, [ITransaction? tx]) {
    final hadKey = _data.containsKey(key);
    final oldValue = _data[key];
    if (!hadKey || oldValue != value) {
      _data[key] = value;
      _obs.set(this, tx, null);
    }
    return this;
  }

  bool delete(K key, [ITransaction? tx]) {
    // JS Map.delete returns true iff the key existed. Check containsKey before
    // removal because Dart's Map.remove also returns null for a null value.
    final hadKey = _data.containsKey(key);
    if (hadKey) {
      _data.remove(key);
    }
    if (hadKey) {
      _obs.set(this, tx, null);
    }
    return hadKey;
  }

  void clear([ITransaction? tx]) {
    if (_data.isNotEmpty) {
      _data.clear();
      _obs.set(this, tx, null);
    }
  }

  /// 1:1: JS `Map.forEach((value, key, map) => ..., thisArg)`
  void forEach(void Function(V value, K key, ObservableMap<K, V> map) callbackfn,
      [Object? thisArg]) {
    for (final entry in _data.entries) {
      callbackfn(entry.value, entry.key, this);
    }
  }

  Iterable<MapEntry<K, V>> entries() => _data.entries;

  Iterable<K> keys() => _data.keys;

  Iterable<V> values() => _data.values;

  Iterable<MapEntry<K, V>> get iterator => _data.entries;

  String get tag => 'ObservableMap';
}
