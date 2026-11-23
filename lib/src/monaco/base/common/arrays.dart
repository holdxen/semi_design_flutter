// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/arrays.ts
// Translated 1:1 from TypeScript.
// Adaptations (documented inline):
//   - tuple returns -> Dart records; namespace `CompareResult` -> top-level
//     `compareResult*` helpers (Dart cannot have a typedef and class with the
//     same name).
//   - JS truthiness -> `_isFalsy`; `Array.splice` semantics -> explicit
//     `removeRange`/`insertAll`; `Object.create(null)` -> LinkedHashMap.
//   - `Promise` -> `Future`; `TypeError` -> `ArgumentError` (Dart TypeError is
//     not constructible with a message).
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'arraysFind.dart' as arraysFind;
import 'cancellation.dart' as cancellation;
import 'errors.dart' as errors;
import 'sequence.dart' as seq;

/// JS truthiness (`!!value`).
bool _isFalsy(Object? value) {
  if (value == null) return true;
  if (value is bool) return !value;
  if (value is num) return value == 0 || value.isNaN;
  if (value is String) return value.isEmpty;
  return false;
}

/// 1:1: `export function tail<T>`
({List<T> rest, T last}) tail<T>(List<T> arr) {
  if (arr.isEmpty) {
    throw StateError('Invalid tail call');
  }
  return (rest: arr.sublist(0, arr.length - 1), last: arr.last);
}

/// 1:1: `export function equals<T>`
bool equals<T>(List<T>? one, List<T>? other,
    [bool Function(T a, T b)? itemEquals]) {
  final bool Function(T a, T b) eq = itemEquals ?? ((T a, T b) => a == b);
  if (identical(one, other)) {
    return true;
  }
  if (one == null || other == null) {
    return false;
  }
  if (one.length != other.length) {
    return false;
  }
  for (int i = 0, len = one.length; i < len; i++) {
    if (!eq(one[i], other[i])) {
      return false;
    }
  }
  return true;
}

/// 1:1: `export function removeFastWithoutKeepingOrder<T>`
void removeFastWithoutKeepingOrder<T>(List<T> array, int index) {
  final int last = array.length - 1;
  if (index < last) {
    array[index] = array[last];
  }
  array.removeLast();
}

/// 1:1: `export function binarySearch<T>`
int binarySearch<T>(List<T> array, T key, Comparator<T> comparator) {
  return binarySearch2(array.length, (int i) => comparator(array[i], key));
}

/// 1:1: `export function binarySearch2`
int binarySearch2(int length, int Function(int index) compareToKey) {
  int low = 0;
  int high = length - 1;
  while (low <= high) {
    final int mid = ((low + high) / 2).truncate();
    final int comp = compareToKey(mid);
    if (comp < 0) {
      low = mid + 1;
    } else if (comp > 0) {
      high = mid - 1;
    } else {
      return mid;
    }
  }
  return -(low + 1);
}

/// 1:1: `export function quickSelect<T>`
T quickSelect<T>(num nth0, List<T> data, Comparator<T> compare) {
  if (nth0.isNaN || nth0.isInfinite || nth0 < 0 || nth0 >= data.length) {
    throw ArgumentError('invalid index');
  }
  final int nth = nth0.truncate();

  final T pivotValue =
      data[(data.length * math.Random().nextDouble()).floor()];
  final List<T> lower = <T>[];
  final List<T> higher = <T>[];
  final List<T> pivots = <T>[];

  for (final T value in data) {
    final int val = compare(value, pivotValue);
    if (val < 0) {
      lower.add(value);
    } else if (val > 0) {
      higher.add(value);
    } else {
      pivots.add(value);
    }
  }

  if (nth < lower.length) {
    return quickSelect(nth, lower, compare);
  } else if (nth < lower.length + pivots.length) {
    return pivots[0];
  }
  return quickSelect(nth - (lower.length + pivots.length), higher, compare);
}

/// 1:1: `export function groupBy<T>`
List<List<T>> groupBy<T>(List<T> data, Comparator<T> compare) {
  final List<List<T>> result = <List<T>>[];
  List<T>? currentGroup;
  for (final T element in List<T>.from(data)..sort(compare)) {
    if (currentGroup == null || compare(currentGroup[0], element) != 0) {
      currentGroup = <T>[element];
      result.add(currentGroup);
    } else {
      currentGroup.add(element);
    }
  }
  return result;
}

/// 1:1: `export function* groupAdjacentBy<T>`
Iterable<List<T>> groupAdjacentBy<T>(
    Iterable<T> items, bool Function(T item1, T item2) shouldBeGrouped) sync* {
  List<T>? currentGroup;
  T? last;
  bool hasLast = false;
  for (final T item in items) {
    if (hasLast && shouldBeGrouped(last as T, item)) {
      currentGroup!.add(item);
    } else {
      if (currentGroup != null) {
        yield currentGroup;
      }
      currentGroup = <T>[item];
    }
    last = item;
    hasLast = true;
  }
  if (currentGroup != null) {
    yield currentGroup;
  }
}

/// 1:1: `export function forEachAdjacent<T>`
void forEachAdjacent<T>(
    List<T> arr, void Function(T? item1, T? item2) f) {
  for (int i = 0; i <= arr.length; i++) {
    f(i == 0 ? null : arr[i - 1], i == arr.length ? null : arr[i]);
  }
}

/// 1:1: `export function forEachWithNeighbors<T>`
void forEachWithNeighbors<T>(
    List<T> arr, void Function(T? before, T element, T? after) f) {
  for (int i = 0; i < arr.length; i++) {
    f(i == 0 ? null : arr[i - 1], arr[i],
        i + 1 == arr.length ? null : arr[i + 1]);
  }
}

/// 1:1: `export function concatArrays<T>`
List<T> concatArrays<T>(List<List<T>> arrays) {
  final List<T> result = <T>[];
  for (final List<T> array in arrays) {
    result.addAll(array);
  }
  return result;
}

/// 1:1: `interface IMutableSplice<T>`
class _MutableSplice<T> implements seq.ISplice<T> {
  @override
  final int start;
  @override
  int deleteCount;
  @override
  final List<T> toInsert;

  _MutableSplice(this.start, this.deleteCount, this.toInsert);
}

/// 1:1: `export function sortedDiff<T>`
List<seq.ISplice<T>> sortedDiff<T>(
    List<T> before, List<T> after, Comparator<T> compare) {
  final List<_MutableSplice<T>> result = <_MutableSplice<T>>[];

  void pushSplice(int start, int deleteCount, List<T> toInsert) {
    if (deleteCount == 0 && toInsert.isEmpty) {
      return;
    }
    final _MutableSplice<T>? latest =
        result.isEmpty ? null : result[result.length - 1];
    if (latest != null && latest.start + latest.deleteCount == start) {
      latest.deleteCount += deleteCount;
      latest.toInsert.addAll(toInsert);
    } else {
      result.add(_MutableSplice<T>(start, deleteCount, toInsert));
    }
  }

  int beforeIdx = 0;
  int afterIdx = 0;
  while (true) {
    if (beforeIdx == before.length) {
      pushSplice(beforeIdx, 0, after.sublist(afterIdx));
      break;
    }
    if (afterIdx == after.length) {
      pushSplice(beforeIdx, before.length - beforeIdx, <T>[]);
      break;
    }
    final T beforeElement = before[beforeIdx];
    final T afterElement = after[afterIdx];
    final int n = compare(beforeElement, afterElement);
    if (n == 0) {
      beforeIdx += 1;
      afterIdx += 1;
    } else if (n < 0) {
      pushSplice(beforeIdx, 1, <T>[]);
      beforeIdx += 1;
    } else if (n > 0) {
      pushSplice(beforeIdx, 0, <T>[afterElement]);
      afterIdx += 1;
    }
  }
  return List<seq.ISplice<T>>.from(result);
}

/// 1:1: `export function delta<T>`
({List<T> removed, List<T> added}) delta<T>(
    List<T> before, List<T> after, Comparator<T> compare) {
  final List<seq.ISplice<T>> splices = sortedDiff(before, after, compare);
  final List<T> removed = <T>[];
  final List<T> added = <T>[];
  for (final seq.ISplice<T> splice in splices) {
    removed.addAll(before.sublist(
        splice.start, splice.start + splice.deleteCount));
    added.addAll(splice.toInsert);
  }
  return (removed: removed, added: added);
}

/// 1:1: `export function top<T>`
List<T> top<T>(List<T> array, Comparator<T> compare, int n) {
  if (n == 0) {
    return <T>[];
  }
  final List<T> result = List<T>.from(array.take(n))..sort(compare);
  topStep(array, compare, result, n, array.length);
  return result;
}

/// 1:1: `export function topAsync<T>`
Future<List<T>> topAsync<T>(
  List<T> array,
  Comparator<T> compare,
  int n,
  int batch, [
  cancellation.CancellationToken? token,
]) async {
  if (n == 0) {
    return <T>[];
  }
  final int o = array.length;
  final List<T> result = List<T>.from(array.take(n))..sort(compare);
  int m = math.min(n + batch, o);
  for (int i = n; i < o;
      i = m, m = math.min(m + batch, o)) {
    if (i > n) {
      await Future<void>.delayed(Duration.zero);
    }
    if (token != null && token.isCancellationRequested) {
      throw errors.CancellationError();
    }
    topStep(array, compare, result, i, m);
  }
  return result;
}

/// 1:1: `function topStep<T>`
void topStep<T>(
    List<T> array, Comparator<T> compare, List<T> result, int i, int m) {
  final int n = result.length;
  for (; i < m; i++) {
    final T element = array[i];
    if (compare(element, result[n - 1]) < 0) {
      result.removeLast();
      final int j = arraysFind.findFirstIdxMonotonousOrArrLen<T>(
          result, (T e) => compare(element, e) < 0);
      result.insert(j, element);
    }
  }
}

/// 1:1: `export function coalesce<T>`
List<T> coalesce<T>(List<T?> array) {
  final List<T> result = <T>[];
  for (final T? e in array) {
    if (!_isFalsy(e)) {
      result.add(e as T);
    }
  }
  return result;
}

/// 1:1: `export function coalesceInPlace<T>`
void coalesceInPlace<T>(List<T?> array) {
  int to = 0;
  for (int i = 0; i < array.length; i++) {
    if (!_isFalsy(array[i])) {
      array[to] = array[i];
      to += 1;
    }
  }
  array.removeRange(to, array.length);
}

/// 1:1: `export function move`
void move(List<Object?> array, int from, int to) {
  final Object? value = array.removeAt(from);
  array.insert(to, value);
}

/// 1:1: `export function isFalsyOrEmpty`
bool isFalsyOrEmpty(Object? obj) => obj is! List || obj.isEmpty;

/// 1:1: `export function isNonEmptyArray<T>`
bool isNonEmptyArray<T>(Object? obj) => obj is List && obj.isNotEmpty;

/// 1:1: `export function distinct<T>`
List<T> distinct<T>(List<T> array, [Object? Function(T value)? keyFn]) {
  final Set<Object?> seen = <Object?>{};
  return array.where((T element) {
    final Object? key = (keyFn ?? (T value) => value)(element);
    if (seen.contains(key)) {
      return false;
    }
    seen.add(key);
    return true;
  }).toList();
}

/// 1:1: `export function uniqueFilter<T, R>`
bool Function(T) uniqueFilter<T, R>(R Function(T t) keyFn) {
  final Set<R> seen = <R>{};
  return (T element) {
    final R key = keyFn(element);
    if (seen.contains(key)) {
      return false;
    }
    seen.add(key);
    return true;
  };
}

/// 1:1: `export function commonPrefixLength<T>`
int commonPrefixLength<T>(List<T> one, List<T> other,
    [bool Function(T a, T b)? equalsFn]) {
  final bool Function(T a, T b) eq = equalsFn ?? ((T a, T b) => a == b);
  int result = 0;
  for (int i = 0, len = math.min(one.length, other.length);
      i < len && eq(one[i], other[i]);
      i++) {
    result++;
  }
  return result;
}

/// 1:1: `export function range` (both overloads collapsed)
List<int> range(int fromOrTo, [int? to]) {
  final int from = to == null ? 0 : fromOrTo;
  final int end = to ?? fromOrTo;
  final List<int> result = <int>[];
  if (from <= end) {
    for (int i = from; i < end; i++) {
      result.add(i);
    }
  } else {
    for (int i = from; i > end; i--) {
      result.add(i);
    }
  }
  return result;
}

/// 1:1: `export function index<T, R>`
Map<String, Object?> index<T, R>(List<T> array, String Function(T t) indexer,
    [R Function(T t)? mapper]) {
  final Map<String, Object?> result = LinkedHashMap<String, Object?>();
  for (final T t in array) {
    result[indexer(t)] = mapper != null ? mapper(t) : t;
  }
  return result;
}

/// 1:1: `export function insert<T>`
void Function() insert<T>(List<T> array, T element) {
  array.add(element);
  return () => remove(array, element);
}

/// 1:1: `export function remove<T>`
T? remove<T>(List<T> array, T element) {
  final int index = array.indexOf(element);
  if (index > -1) {
    array.removeAt(index);
    return element;
  }
  return null;
}

/// 1:1: `export function arrayInsert<T>`
List<T> arrayInsert<T>(List<T> target, int insertIndex, List<T> insertArr) {
  return <T>[...target.take(insertIndex), ...insertArr, ...target.skip(insertIndex)];
}

/// 1:1: `export function shuffle<T>`
void shuffle<T>(List<T> array, [num? seed]) {
  late final double Function() rand;
  if (seed != null) {
    num s = seed;
    rand = () {
      final double x = math.sin(s.toDouble()) * 179426549;
      s += 1;
      return x - x.floor();
    };
  } else {
    final math.Random random = math.Random();
    rand = random.nextDouble;
  }

  for (int i = array.length - 1; i > 0; i -= 1) {
    final int j = (rand() * (i + 1)).floor();
    final T temp = array[i];
    array[i] = array[j];
    array[j] = temp;
  }
}

/// 1:1: `export function pushToStart<T>`
void pushToStart<T>(List<T> arr, T value) {
  final int index = arr.indexOf(value);
  if (index > -1) {
    arr.removeAt(index);
    arr.insert(0, value);
  }
}

/// 1:1: `export function pushToEnd<T>`
void pushToEnd<T>(List<T> arr, T value) {
  final int index = arr.indexOf(value);
  if (index > -1) {
    arr.removeAt(index);
    arr.add(value);
  }
}

/// 1:1: `export function pushMany<T>`
void pushMany<T>(List<T> arr, List<T> items) {
  for (final T item in items) {
    arr.add(item);
  }
}

/// 1:1: `export function mapArrayOrNot<T, U>`
Object? mapArrayOrNot<T, U>(Object? items, U Function(T t) fn) {
  if (items is List) {
    return items.map((Object? e) => fn(e as T)).toList();
  }
  return fn(items as T);
}

/// 1:1: `export function mapFilter<T, U>`
List<U> mapFilter<T, U>(List<T> array, U? Function(T t) fn) {
  final List<U> result = <U>[];
  for (final T item in array) {
    final U? mapped = fn(item);
    if (mapped != null) {
      result.add(mapped);
    }
  }
  return result;
}

/// 1:1: `export function withoutDuplicates<T>`
List<T> withoutDuplicates<T>(List<T> array) => <T>{...array}.toList();

/// 1:1: `export function asArray<T>`
List<T> asArray<T>(Object? x) {
  if (x is List) {
    return x.cast<T>();
  }
  return <T>[x as T];
}

/// 1:1: `export function getRandomElement<T>`
T? getRandomElement<T>(List<T> arr) {
  if (arr.isEmpty) {
    return null;
  }
  return arr[(math.Random().nextDouble() * arr.length).floor()];
}

/// 1:1: `export function insertInto<T>`
void insertInto<T>(List<T> array, int start, List<T> newItems) {
  array.insertAll(getActualStartIndex(array, start), newItems);
}

/// 1:1: `export function splice<T>`
List<T> splice<T>(List<T> array, int start, int deleteCount, List<T> newItems) {
  final int index = getActualStartIndex(array, start);
  final int end = math.min(index + deleteCount, array.length);
  final List<T> result = array.sublist(index, end);
  array.removeRange(index, end);
  insertInto(array, index, newItems);
  return result;
}

/// 1:1: `function getActualStartIndex<T>`
int getActualStartIndex<T>(List<T> array, int start) {
  return start < 0
      ? math.max(start + array.length, 0)
      : math.min(start, array.length);
}

/// 1:1: `export type CompareResult = number`
typedef CompareResult = int;

/// 1:1: `namespace CompareResult` — Dart cannot give a typedef and class the
/// same name, so the namespace members are top-level helpers.
bool compareResultIsLessThan(num result) => result < 0;
bool compareResultIsLessThanOrEqual(num result) => result <= 0;
bool compareResultIsGreaterThan(num result) => result > 0;
bool compareResultIsNeitherLessOrGreaterThan(num result) => result == 0;
const num compareResultGreaterThan = 1;
const num compareResultLessThan = -1;
const num compareResultNeitherLessOrGreaterThan = 0;

/// 1:1: `export type Comparator<T>`
typedef Comparator<T> = int Function(T a, T b);

/// 1:1: `export function compareBy<TItem, TCompareBy>`
Comparator<TItem> compareBy<TItem, TCompareBy>(
  TCompareBy Function(TItem item) selector,
  Comparator<TCompareBy> comparator,
) =>
    (TItem a, TItem b) => comparator(selector(a), selector(b));

/// 1:1: `export function tieBreakComparators<TItem>`
Comparator<TItem> tieBreakComparators<TItem>(
    List<Comparator<TItem>> comparators) {
  return (TItem item1, TItem item2) {
    for (final Comparator<TItem> comparator in comparators) {
      final int result = comparator(item1, item2);
      if (!compareResultIsNeitherLessOrGreaterThan(result)) {
        return result;
      }
    }
    return compareResultNeitherLessOrGreaterThan as int;
  };
}

/// 1:1: `export const numberComparator`
final Comparator<int> numberComparator = (int a, int b) => a - b;

/// 1:1: `export const booleanComparator`
final Comparator<bool> booleanComparator = (bool a, bool b) =>
    numberComparator(a ? 1 : 0, b ? 1 : 0);

/// 1:1: `export function reverseOrder<TItem>`
Comparator<TItem> reverseOrder<TItem>(Comparator<TItem> comparator) =>
    (TItem a, TItem b) => -comparator(a, b);

/// 1:1: `export function compareUndefinedSmallest<T>`
Comparator<T?> compareUndefinedSmallest<T>(Comparator<T> comparator) {
  return (T? a, T? b) {
    if (a == null) {
      return b == null
          ? compareResultNeitherLessOrGreaterThan as int
          : compareResultLessThan as int;
    }
    if (b == null) {
      return compareResultGreaterThan as int;
    }
    return comparator(a, b);
  };
}

/// 1:1: `export class ArrayQueue<T>`
class ArrayQueue<T> {
  final List<T> items;
  int firstIdx = 0;
  int lastIdx;

  ArrayQueue(List<T> items)
      : items = items,
        lastIdx = items.length - 1;

  int get length => lastIdx - firstIdx + 1;

  /// 1:1: `takeWhile`
  List<T>? takeWhile(bool Function(T value) predicate) {
    int startIdx = firstIdx;
    while (startIdx <= lastIdx && predicate(items[startIdx])) {
      startIdx++;
    }
    final List<T>? result = startIdx == firstIdx
        ? null
        : items.sublist(firstIdx, startIdx);
    firstIdx = startIdx;
    return result;
  }

  /// 1:1: `takeFromEndWhile`
  List<T>? takeFromEndWhile(bool Function(T value) predicate) {
    int endIdx = lastIdx;
    while (endIdx >= firstIdx && predicate(items[endIdx])) {
      endIdx--;
    }
    final List<T>? result = endIdx == lastIdx
        ? null
        : items.sublist(endIdx + 1, lastIdx + 1);
    lastIdx = endIdx;
    return result;
  }

  T? peek() {
    if (length == 0) return null;
    return items[firstIdx];
  }

  T? peekLast() {
    if (length == 0) return null;
    return items[lastIdx];
  }

  T? dequeue() {
    // Source has no length check (JS out-of-bounds read yields `undefined`).
    final T result = items[firstIdx];
    firstIdx++;
    return result;
  }

  T? removeLast() {
    final T result = items[lastIdx];
    lastIdx--;
    return result;
  }

  List<T> takeCount(int count) {
    final List<T> result = items.sublist(firstIdx, firstIdx + count);
    firstIdx += count;
    return result;
  }
}

/// 1:1: `export class CallbackIterable<T>`
class CallbackIterable<T> {
  static final CallbackIterable<Never> empty =
      CallbackIterable<Never>((bool Function(Never item) callback) {});

  final void Function(bool Function(T item) callback) iterate;

  CallbackIterable(this.iterate);

  void forEach(void Function(T item) handler) {
    iterate((T item) {
      handler(item);
      return true;
    });
  }

  List<T> toArray() {
    final List<T> result = <T>[];
    iterate((T item) {
      result.add(item);
      return true;
    });
    return result;
  }

  CallbackIterable<T> filter(bool Function(T item) predicate) {
    return CallbackIterable<T>((bool Function(T item) cb) =>
        iterate((T item) => predicate(item) ? cb(item) : true));
  }

  CallbackIterable<TResult> map<TResult>(TResult Function(T item) mapFn) {
    return CallbackIterable<TResult>(
        (bool Function(TResult item) cb) => iterate((T item) => cb(mapFn(item))));
  }

  bool some(bool Function(T item) predicate) {
    bool result = false;
    iterate((T item) {
      result = predicate(item);
      return !result;
    });
    return result;
  }

  T? findFirst(bool Function(T item) predicate) {
    T? result;
    iterate((T item) {
      if (predicate(item)) {
        result = item;
        return false;
      }
      return true;
    });
    return result;
  }

  T? findLast(bool Function(T item) predicate) {
    T? result;
    iterate((T item) {
      if (predicate(item)) {
        result = item;
      }
      return true;
    });
    return result;
  }

  T? findLastMaxBy(Comparator<T> comparator) {
    T? result;
    bool first = true;
    iterate((T item) {
      if (first || compareResultIsGreaterThan(comparator(item, result as T))) {
        first = false;
        result = item;
      }
      return true;
    });
    return result;
  }
}

/// 1:1: `export class Permutation`
class Permutation {
  final List<int> _indexMap;

  Permutation(this._indexMap);

  static Permutation createSortPermutation<T>(
      List<T> arr, Comparator<T> compareFn) {
    final List<int> sortIndices = List<int>.generate(arr.length, (int i) => i)
      ..sort((int index1, int index2) =>
          compareFn(arr[index1], arr[index2]));
    return Permutation(sortIndices);
  }

  List<T> apply<T>(List<T> arr) => List<T>.generate(
      arr.length, (int index) => arr[_indexMap[index]]);

  Permutation inverse() {
    final List<int> inverseIndexMap = List<int>.from(_indexMap);
    for (int i = 0; i < _indexMap.length; i++) {
      inverseIndexMap[_indexMap[i]] = i;
    }
    return Permutation(inverseIndexMap);
  }
}

/// 1:1: `export async function findAsync<T>`
Future<T?> findAsync<T>(
    List<T> array, Future<bool> Function(T element, int index) predicate) async {
  final List<({T element, bool ok})> results = await Future.wait(
    List<Future<({T element, bool ok})>>.generate(array.length, (int index) async {
      final T element = array[index];
      return (element: element, ok: await predicate(element, index));
    }),
  );
  for (final ({T element, bool ok}) r in results) {
    if (r.ok) return r.element;
  }
  return null;
}

/// 1:1: `export function sum`
num sum(List<num> array) => array.fold<num>(0, (num acc, num value) => acc + value);

/// 1:1: `export function sumBy<T>`
num sumBy<T>(List<T> array, num Function(T value) selector) =>
    array.fold<num>(0, (num acc, T value) => acc + selector(value));
