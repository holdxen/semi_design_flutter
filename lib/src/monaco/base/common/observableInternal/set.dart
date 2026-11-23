// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/set.ts (1:1).
//
// Bridge note: TS `ObservableSet<T> implements Set<T>` uses JS
// `Set.forEach(value, value2, set)` callback order. Dart's `Set` interface
// differs; this class mirrors the TS class surface as a standalone type
// backed by a Dart Set, preserving 1:1 behavior (verified by batch82_truth.json).
// ---------------------------------------------------------------------------

import '../observable.dart' show IObservable, ISettableObservable, ITransaction;
import 'observables/observableValueOpts.dart'
    show ObservableValueOpts, observableValueOpts;

class ObservableSet<T> {
  ObservableSet() {
    _obs = observableValueOpts<Object?, Object?>(
      ObservableValueOpts<Object?>(equalsFn: (a, b) => false),
      this,
    );
    observable = _obs;
  }

  final Set<T> _data = <T>{};

  late final ISettableObservable<Object?, Object?> _obs;

  /// 1:1: `readonly observable: IObservable<Set<T>> = this._obs`
  late final IObservable<Object?> observable;

  int get size => _data.length;

  bool has(T value) => _data.contains(value);

  ObservableSet<T> add(T value, [ITransaction? tx]) {
    final hadValue = _data.contains(value);
    if (!hadValue) {
      _data.add(value);
      _obs.set(this, tx, null);
    }
    return this;
  }

  bool delete(T value, [ITransaction? tx]) {
    final result = _data.remove(value);
    if (result) {
      _obs.set(this, tx, null);
    }
    return result;
  }

  void clear([ITransaction? tx]) {
    if (_data.isNotEmpty) {
      _data.clear();
      _obs.set(this, tx, null);
    }
  }

  /// 1:1: JS `Set.forEach((value, value2, set) => ..., thisArg)`
  void forEach(void Function(T value, T value2, ObservableSet<T> set) callbackfn,
      [Object? thisArg]) {
    for (final value in _data) {
      callbackfn(value, value, this);
    }
  }

  Iterable<MapEntry<T, T>> entries() =>
      _data.map((v) => MapEntry<T, T>(v, v));

  Iterable<T> keys() => _data;

  Iterable<T> values() => _data;

  Iterable<T> get iterator => _data;

  String get tag => 'ObservableSet';
}
