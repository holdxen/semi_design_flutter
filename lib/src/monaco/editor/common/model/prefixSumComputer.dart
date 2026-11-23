// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/model/prefixSumComputer.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations:
//   - `Uint32Array` / `Int32Array` -> `List<int>` with an explicit `_u32`
//     helper that reproduces the modulo-2^32 store semantics.
//   - Sparse array reads (`_indexBySum[sum]`) -> bounds-checked helper that
//     returns `null` for "undefined", matching JS.
//   - `PrefixSumIndexOfResult` gets value equality so it can be compared the
//     way the TS tests use `deepStrictEqual`.
// ---------------------------------------------------------------------------

import '../../../base/common/arrays.dart' as arrays;
import '../../../base/common/uint.dart' as uint;

/// Simulates storing [v] into a JS `Uint32Array` (modulo 2^32).
int _u32(int v) => v & 0xFFFFFFFF;

/// JS out-of-bounds typed-array read yields `undefined`, which behaves as 0
/// when written back into a typed array. We keep reads safe.
int _read(List<int> list, int index) =>
    index >= 0 && index < list.length ? list[index] : 0;

/// 1:1: `export class PrefixSumComputer`
class PrefixSumComputer {
  /// values[i] is the value at index i
  List<int> values;

  /// prefixSum[i] = SUM(heights[j]), 0 <= j <= i
  List<int> prefixSum;

  /// prefixSum[i], 0 <= i <= prefixSumValidIndex[0] can be trusted
  final List<int> prefixSumValidIndex;

  PrefixSumComputer(List<int> values)
      : values = List<int>.from(values).map(_u32).toList(),
        prefixSum = List<int>.filled(values.length, 0),
        prefixSumValidIndex = <int>[-1];

  int getCount() => values.length;

  bool insertValues(int insertIndex, List<int> insertValues) {
    insertIndex = uint.toUint32(insertIndex);
    final List<int> oldValues = values;
    final List<int> oldPrefixSum = prefixSum;
    final int insertValuesLen = insertValues.length;

    if (insertValuesLen == 0) {
      return false;
    }

    values = List<int>.filled(oldValues.length + insertValuesLen, 0);
    for (int i = 0; i < insertIndex && i < oldValues.length; i++) {
      values[i] = oldValues[i];
    }
    for (int i = insertIndex; i < oldValues.length; i++) {
      values[i + insertValuesLen] = oldValues[i];
    }
    for (int i = 0; i < insertValuesLen; i++) {
      values[insertIndex + i] = _u32(insertValues[i]);
    }

    if (insertIndex - 1 < prefixSumValidIndex[0]) {
      prefixSumValidIndex[0] = insertIndex - 1;
    }

    prefixSum = List<int>.filled(values.length, 0);
    if (prefixSumValidIndex[0] >= 0) {
      for (int i = 0; i <= prefixSumValidIndex[0] && i < oldPrefixSum.length; i++) {
        prefixSum[i] = oldPrefixSum[i];
      }
    }
    return true;
  }

  bool setValue(int index, int value) {
    index = uint.toUint32(index);
    value = _u32(uint.toUint32(value));

    if (_read(values, index) == value) {
      return false;
    }
    values[index] = value;
    if (index - 1 < prefixSumValidIndex[0]) {
      prefixSumValidIndex[0] = index - 1;
    }
    return true;
  }

  bool removeValues(int startIndex, int count) {
    startIndex = uint.toUint32(startIndex);
    count = uint.toUint32(count);

    final List<int> oldValues = values;
    final List<int> oldPrefixSum = prefixSum;

    if (startIndex >= oldValues.length) {
      return false;
    }

    int maxCount = oldValues.length - startIndex;
    if (count >= maxCount) {
      count = maxCount;
    }

    if (count == 0) {
      return false;
    }

    values = List<int>.filled(oldValues.length - count, 0);
    for (int i = 0; i < startIndex; i++) {
      values[i] = oldValues[i];
    }
    for (int i = startIndex + count; i < oldValues.length; i++) {
      values[i - count] = oldValues[i];
    }

    prefixSum = List<int>.filled(values.length, 0);
    if (startIndex - 1 < prefixSumValidIndex[0]) {
      prefixSumValidIndex[0] = startIndex - 1;
    }
    if (prefixSumValidIndex[0] >= 0) {
      for (int i = 0; i <= prefixSumValidIndex[0] && i < oldPrefixSum.length; i++) {
        prefixSum[i] = oldPrefixSum[i];
      }
    }
    return true;
  }

  int getTotalSum() {
    if (values.isEmpty) {
      return 0;
    }
    return _getPrefixSum(values.length - 1);
  }

  /// Returns the sum of the first `index + 1` many items.
  /// `SUM(0 <= j <= index, values[j])`.
  int getPrefixSum(int index) {
    if (index < 0) {
      return 0;
    }
    index = uint.toUint32(index);
    return _getPrefixSum(index);
  }

  int _getPrefixSum(int index) {
    if (index <= prefixSumValidIndex[0]) {
      return _read(prefixSum, index);
    }

    int startIndex = prefixSumValidIndex[0] + 1;
    if (startIndex == 0) {
      prefixSum[0] = _u32(_read(values, 0));
      startIndex++;
    }

    if (index >= values.length) {
      index = values.length - 1;
    }

    for (int i = startIndex; i <= index; i++) {
      prefixSum[i] = _u32(_read(prefixSum, i - 1) + _read(values, i));
    }
    prefixSumValidIndex[0] =
        prefixSumValidIndex[0] > index ? prefixSumValidIndex[0] : index;
    return _read(prefixSum, index);
  }

  PrefixSumIndexOfResult getIndexOf(num sumValue) {
    final int sum = sumValue.floor();

    // Compute all sums (to get a fully valid prefixSum)
    getTotalSum();

    int low = 0;
    int high = values.length - 1;
    int mid = 0;
    int midStop = 0;
    int midStart = 0;

    while (low <= high) {
      mid = (low + ((high - low) / 2)).toInt();
      midStop = _read(prefixSum, mid);
      midStart = midStop - _read(values, mid);

      if (sum < midStart) {
        high = mid - 1;
      } else if (sum >= midStop) {
        low = mid + 1;
      } else {
        break;
      }
    }

    return PrefixSumIndexOfResult(mid, sum - midStart);
  }
}

/// 1:1: `export class ConstantTimePrefixSumComputer`
class ConstantTimePrefixSumComputer {
  List<int> _values;
  bool _isValid;
  int _validEndIndex;

  /// _prefixSum[i] = SUM(values[j]), 0 <= j <= i
  final List<int> _prefixSum;

  /// _indexBySum[sum] = idx => _prefixSum[idx - 1] <= sum < _prefixSum[idx]
  final List<int> _indexBySum;

  ConstantTimePrefixSumComputer(List<int> values)
      : _values = List<int>.from(values),
        _isValid = false,
        _validEndIndex = -1,
        _prefixSum = <int>[],
        _indexBySum = <int>[];

  /// SUM(0 <= j < values.length, values[j])
  int getTotalSum() {
    _ensureValid();
    return _indexBySum.length;
  }

  /// Returns the sum of the first `count` many items.
  /// SUM(0 <= j < count, values[j]).
  int getPrefixSum(int count) {
    _ensureValid();
    if (count == 0) {
      return 0;
    }
    return _read(_prefixSum, count - 1);
  }

  /// result such that `getPrefixSum(result.index) + result.remainder = sum`
  PrefixSumIndexOfResult getIndexOf(int sum) {
    _ensureValid();
    final int? idx = (sum >= 0 && sum < _indexBySum.length)
        ? _indexBySum[sum]
        : null;
    if (idx == null) {
      // sum has no direct entry (sum >= total, or empty / all-zero array).
      final int lastIdx =
          _values.length - 1 > 0 ? _values.length - 1 : 0;
      final int lastPrefixSum = lastIdx > 0 ? _read(_prefixSum, lastIdx - 1) : 0;
      return PrefixSumIndexOfResult(lastIdx, sum - lastPrefixSum);
    }
    final int viewLinesAbove = idx > 0 ? _read(_prefixSum, idx - 1) : 0;
    return PrefixSumIndexOfResult(idx, sum - viewLinesAbove);
  }

  void removeValues(int start, int deleteCount) {
    if (start < 0) start = 0;
    if (start > _values.length) start = _values.length;
    int end = start + deleteCount;
    if (end > _values.length) end = _values.length;
    if (end < start) end = start;
    _values.removeRange(start, end);
    _invalidate(start);
  }

  void insertValues(int insertIndex, List<int> insertArr) {
    _values = arrays.arrayInsert<int>(_values, insertIndex, insertArr);
    _invalidate(insertIndex);
  }

  void _invalidate(int index) {
    _isValid = false;
    _validEndIndex = _validEndIndex < index - 1 ? _validEndIndex : index - 1;
  }

  void _ensureValid() {
    if (_isValid) {
      return;
    }

    for (int i = _validEndIndex + 1, len = _values.length; i < len; i++) {
      final int value = _values[i];
      final int sumAbove = i > 0 ? _read(_prefixSum, i - 1) : 0;

      while (_prefixSum.length <= i) {
        _prefixSum.add(0);
      }
      _prefixSum[i] = sumAbove + value;
      for (int j = 0; j < value; j++) {
        final int at = sumAbove + j;
        while (_indexBySum.length <= at) {
          _indexBySum.add(0);
        }
        _indexBySum[at] = i;
      }
    }

    // trim things
    if (_prefixSum.length > _values.length) {
      _prefixSum.removeRange(_values.length, _prefixSum.length);
    }
    final int newIndexBySumLength =
        _values.isNotEmpty ? _read(_prefixSum, _values.length - 1) : 0;
    if (_indexBySum.length > newIndexBySumLength) {
      _indexBySum.removeRange(newIndexBySumLength, _indexBySum.length);
    }

    // mark as valid
    _isValid = true;
    _validEndIndex = _values.length - 1;
  }

  void setValue(int index, int value) {
    if (_read(_values, index) == value) {
      // no change
      return;
    }
    _values[index] = value;
    _invalidate(index);
  }
}

/// 1:1: `export class PrefixSumIndexOfResult`
class PrefixSumIndexOfResult {
  final int index;
  final int remainder;

  const PrefixSumIndexOfResult(this.index, this.remainder);

  @override
  bool operator ==(Object other) =>
      other is PrefixSumIndexOfResult &&
      other.index == index &&
      other.remainder == remainder;

  @override
  int get hashCode => Object.hash(index, remainder);

  @override
  String toString() => 'PrefixSumIndexOfResult($index, $remainder)';
}
