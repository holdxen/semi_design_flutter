// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/model/fixedArray.ts
// Translated 1:1 from TypeScript. The default-filled array avoids sparse
// indices; JS `slice`/`concat` -> Dart `sublist`/spread. `arrayInsert` is the
// shared base helper.
// ---------------------------------------------------------------------------

import '../../../base/common/arrays.dart' show arrayInsert;

/// An array that avoids being sparse by always filling up unused indices with
/// a default value.
///
/// 1:1: `export class FixedArray<T>`
class FixedArray<T> {
  final List<T> _store = <T>[];

  FixedArray(this._default);

  final T _default;

  T get(int index) {
    if (index < _store.length) {
      return _store[index];
    }
    return _default;
  }

  void set(int index, T value) {
    while (index >= _store.length) {
      _store.add(_default);
    }
    _store[index] = value;
  }

  void replace(int index, int oldLength, int newLength) {
    if (index >= _store.length) {
      return;
    }

    if (oldLength == 0) {
      insert(index, newLength);
      return;
    } else if (newLength == 0) {
      delete(index, oldLength);
      return;
    }

    final List<T> before = _store.sublist(0, index);
    final List<T> after = _store.sublist(index + oldLength);
    final List<T> insertArr = _arrayFill<T>(newLength, _default);
    _store
      ..clear()
      ..addAll(before)
      ..addAll(insertArr)
      ..addAll(after);
  }

  void delete(int deleteIndex, int deleteCount) {
    if (deleteCount == 0 || deleteIndex >= _store.length) {
      return;
    }
    _store.removeRange(deleteIndex, deleteIndex + deleteCount);
  }

  void insert(int insertIndex, int insertCount) {
    if (insertCount == 0 || insertIndex >= _store.length) {
      return;
    }
    final List<T> arr = _arrayFill<T>(insertCount, _default);
    final List<T> result = arrayInsert<T>(_store, insertIndex, arr);
    _store
      ..clear()
      ..addAll(result);
  }
}

List<T> _arrayFill<T>(int length, T value) {
  final List<T> arr = <T>[];
  for (int i = 0; i < length; i++) {
    arr.add(value);
  }
  return arr;
}
