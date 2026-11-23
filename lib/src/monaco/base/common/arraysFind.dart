// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/arraysFind.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. `Comparator<T>` is dart:core's identical
// typedef (int Function(T,T)), so no local redeclaration is needed. TS overloads
// collapsed to a single nullable-returning Dart signature (source names kept).
// ---------------------------------------------------------------------------

// Source imports `Comparator` from arrays.ts; Dart's dart:core Comparator<T>
// is the identical `(a,b) => int` typedef, so no import is needed here.

T? findLast<T>(List<T> array, bool Function(T item, int index) predicate, [int? fromIndex]) {
  final int idx = findLastIdx(array, predicate, fromIndex ?? array.length - 1);
  if (idx == -1) {
    return null;
  }
  return array[idx];
}

int findLastIdx<T>(List<T> array, bool Function(T item, int index) predicate, [int? fromIndex]) {
  for (int i = fromIndex ?? array.length - 1; i >= 0; i--) {
    final T element = array[i];
    if (predicate(element, i)) {
      return i;
    }
  }
  return -1;
}

T? findFirst<T>(List<T> array, bool Function(T item, int index) predicate, [int? fromIndex]) {
  final int idx = findFirstIdx(array, predicate, fromIndex ?? 0);
  if (idx == -1) {
    return null;
  }
  return array[idx];
}

int findFirstIdx<T>(List<T> array, bool Function(T item, int index) predicate, [int? fromIndex]) {
  for (int i = fromIndex ?? 0; i < array.length; i++) {
    final T element = array[i];
    if (predicate(element, i)) {
      return i;
    }
  }
  return -1;
}

/// Finds the last item where predicate is true using binary search.
/// `predicate` must be monotonous, i.e. `arr.map(predicate)` must be like `[true, ..., true, false, ..., false]`!
/// @returns `undefined` if no item matches, otherwise the last item that matches the predicate.
T? findLastMonotonous<T>(List<T> array, bool Function(T item) predicate) {
  final int idx = findLastIdxMonotonous(array, predicate);
  return idx == -1 ? null : array[idx];
}

/// Finds the last item where predicate is true using binary search.
/// `predicate` must be monotonous, i.e. `arr.map(predicate)` must be like `[true, ..., true, false, ..., false]`!
/// @returns `startIdx - 1` if predicate is false for all items, otherwise the index of the last matching item.
int findLastIdxMonotonous<T>(List<T> array, bool Function(T item) predicate,
    [int startIdx = 0, int? endIdxEx]) {
  int i = startIdx;
  int j = endIdxEx ?? array.length;
  while (i < j) {
    final int k = ((i + j) / 2).floor();
    if (predicate(array[k])) {
      i = k + 1;
    } else {
      j = k;
    }
  }
  return i - 1;
}

/// Finds the first item where predicate is true using binary search.
/// `predicate` must be monotonous, i.e. `arr.map(predicate)` must be like `[false, ..., false, true, ..., true]`!
/// @returns `undefined` if no item matches, otherwise the first item that matches the predicate.
T? findFirstMonotonous<T>(List<T> array, bool Function(T item) predicate) {
  final int idx = findFirstIdxMonotonousOrArrLen(array, predicate);
  return idx == array.length ? null : array[idx];
}

/// Finds the first item where predicate is true using binary search.
/// `predicate` must be monotonous, i.e. `arr.map(predicate)` must be like `[false, ..., false, true, ..., true]`!
/// @returns `endIdxEx` if predicate is false for all items, otherwise the index of the first matching item.
int findFirstIdxMonotonousOrArrLen<T>(List<T> array, bool Function(T item) predicate,
    [int startIdx = 0, int? endIdxEx]) {
  int i = startIdx;
  int j = endIdxEx ?? array.length;
  while (i < j) {
    final int k = ((i + j) / 2).floor();
    if (predicate(array[k])) {
      j = k;
    } else {
      i = k + 1;
    }
  }
  return i;
}

int findFirstIdxMonotonous<T>(List<T> array, bool Function(T item) predicate,
    [int startIdx = 0, int? endIdxEx]) {
  final int idx = findFirstIdxMonotonousOrArrLen(array, predicate, startIdx, endIdxEx);
  return idx == array.length ? -1 : idx;
}

/// Use this when
/// * You have a sorted array
/// * You query this array with a monotonous predicate to find the last item that has a certain property.
/// * You query this array multiple times with monotonous predicates that get weaker and weaker.
class MonotonousArray<T> {
  static bool assertInvariants = false;

  int _findLastMonotonousLastIdx = 0;
  bool Function(T item)? _prevFindLastPredicate;

  final List<T> _array;

  MonotonousArray(this._array);

  /// The predicate must be monotonous, i.e. `arr.map(predicate)` must be like `[true, ..., true, false, ..., false]`!
  /// For subsequent calls, current predicate must be weaker than (or equal to) the previous predicate.
  T? findLastMonotonous(bool Function(T item) predicate) {
    if (MonotonousArray.assertInvariants) {
      if (this._prevFindLastPredicate != null) {
        for (final T item in this._array) {
          if (this._prevFindLastPredicate!(item) && !predicate(item)) {
            throw StateError('MonotonousArray: current predicate must be weaker than (or equal to) the previous predicate.');
          }
        }
      }
      this._prevFindLastPredicate = predicate;
    }

    final int idx = findLastIdxMonotonous(this._array, predicate, this._findLastMonotonousLastIdx);
    this._findLastMonotonousLastIdx = idx + 1;
    return idx == -1 ? null : this._array[idx];
  }
}

/// Returns the first item that is equal to or greater than every other item.
T? findFirstMax<T>(List<T> array, Comparator<T> comparator) {
  if (array.isEmpty) {
    return null;
  }
  T max = array[0];
  for (int i = 1; i < array.length; i++) {
    final T item = array[i];
    if (comparator(item, max) > 0) {
      max = item;
    }
  }
  return max;
}

/// Returns the last item that is equal to or greater than every other item.
T? findLastMax<T>(List<T> array, Comparator<T> comparator) {
  if (array.isEmpty) {
    return null;
  }
  T max = array[0];
  for (int i = 1; i < array.length; i++) {
    final T item = array[i];
    if (comparator(item, max) >= 0) {
      max = item;
    }
  }
  return max;
}

/// Returns the first item that is equal to or less than every other item.
T? findFirstMin<T>(List<T> array, Comparator<T> comparator) =>
    findFirstMax(array, (T a, T b) => -comparator(a, b));

int findMaxIdx<T>(List<T> array, Comparator<T> comparator) {
  if (array.isEmpty) {
    return -1;
  }
  int maxIdx = 0;
  for (int i = 1; i < array.length; i++) {
    final T item = array[i];
    if (comparator(item, array[maxIdx]) > 0) {
      maxIdx = i;
    }
  }
  return maxIdx;
}

/// Returns the first mapped value of the array which is not undefined.
R? mapFindFirst<T, R>(Iterable<T> items, R? Function(T value) mapFn) {
  for (final T value in items) {
    final R? mapped = mapFn(value);
    if (mapped != null) {
      return mapped;
    }
  }
  return null;
}
