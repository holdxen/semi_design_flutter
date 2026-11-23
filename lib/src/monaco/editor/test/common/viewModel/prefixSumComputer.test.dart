// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/viewModel/prefixSumComputer.test.ts
// Translated 1:1. The mocha suite's active cases become Dart functions.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted. `toUint32Array` maps through `toUint32`, matching
// the TS helper; both PrefixSumComputer and ConstantTimePrefixSumComputer are
// exercised via `createBoth`/`forBoth`.
// ---------------------------------------------------------------------------

import '../../../../base/common/uint.dart' show toUint32;
import '../../../common/model/prefixSumComputer.dart'
    show ConstantTimePrefixSumComputer, PrefixSumComputer, PrefixSumIndexOfResult;

/// Interface carrier mirroring `interface IPrefixSumComputer`.
abstract class IPrefixSumComputer {
  int getTotalSum();
  int getPrefixSum(int count);
  PrefixSumIndexOfResult getIndexOf(num sum);
  void setValue(int index, int value);
  void insertValues(int insertIndex, List<int> insertArr);
  void removeValues(int start, int deleteCount);
}

class _WrappedPsc implements IPrefixSumComputer {
  final PrefixSumComputer _psc;
  _WrappedPsc(this._psc);
  @override int getTotalSum() => _psc.getTotalSum();
  @override int getPrefixSum(int count) => count == 0 ? 0 : _psc.getPrefixSum(count - 1);
  @override PrefixSumIndexOfResult getIndexOf(num sum) => _psc.getIndexOf(sum);
  @override void setValue(int index, int value) { _psc.setValue(index, value); }
  @override void insertValues(int insertIndex, List<int> insertArr) {
    _psc.insertValues(insertIndex, _toUint32Array(insertArr));
  }
  @override void removeValues(int start, int deleteCount) { _psc.removeValues(start, deleteCount); }
}

class _WrappedCt implements IPrefixSumComputer {
  final ConstantTimePrefixSumComputer _ct;
  _WrappedCt(this._ct);
  @override int getTotalSum() => _ct.getTotalSum();
  @override int getPrefixSum(int count) => _ct.getPrefixSum(count);
  @override PrefixSumIndexOfResult getIndexOf(num sum) => _ct.getIndexOf(sum as int);
  @override void setValue(int index, int value) { _ct.setValue(index, value); }
  @override void insertValues(int insertIndex, List<int> insertArr) {
    _ct.insertValues(insertIndex, insertArr);
  }
  @override void removeValues(int start, int deleteCount) { _ct.removeValues(start, deleteCount); }
}

List<int> _toUint32Array(List<int> arr) => arr.map(toUint32).toList();

List<IPrefixSumComputer> createBoth(List<int> values) {
  final psc = PrefixSumComputer(_toUint32Array(values));
  final wrapped = _WrappedPsc(psc);
  final ct = ConstantTimePrefixSumComputer(List<int>.from(values));
  final wrappedCt = _WrappedCt(ct);
  return [wrapped, wrappedCt];
}

void forBoth(List<int> values, void Function(IPrefixSumComputer psc) callback) {
  for (final psc in createBoth(values)) { callback(psc); }
}

// comprehensive setValue and getIndexOf
void _test01() {
  forBoth(<int>[1, 1, 2, 1, 3], (psc) {
    assert(psc.getTotalSum() == 8);
    assert(psc.getPrefixSum(0) == 0);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 2);
    assert(psc.getPrefixSum(3) == 4);
    assert(psc.getPrefixSum(4) == 5);
    assert(psc.getPrefixSum(5) == 8);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(2, 0));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(2, 1));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(3, 0));
    assert(psc.getIndexOf(5) == PrefixSumIndexOfResult(4, 0));
    assert(psc.getIndexOf(6) == PrefixSumIndexOfResult(4, 1));
    assert(psc.getIndexOf(7) == PrefixSumIndexOfResult(4, 2));
    assert(psc.getIndexOf(8) == PrefixSumIndexOfResult(4, 3));
    // [1, 2, 2, 1, 3]
    psc.setValue(1, 2);
    assert(psc.getTotalSum() == 9);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 3);
    assert(psc.getPrefixSum(3) == 5);
    assert(psc.getPrefixSum(4) == 6);
    assert(psc.getPrefixSum(5) == 9);
    // [1, 0, 2, 1, 3]
    psc.setValue(1, 0);
    assert(psc.getTotalSum() == 7);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 1);
    assert(psc.getPrefixSum(3) == 3);
    assert(psc.getPrefixSum(4) == 4);
    assert(psc.getPrefixSum(5) == 7);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(2, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(2, 1));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(3, 0));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(4, 0));
    assert(psc.getIndexOf(5) == PrefixSumIndexOfResult(4, 1));
    assert(psc.getIndexOf(6) == PrefixSumIndexOfResult(4, 2));
    // [1, 0, 0, 1, 3]
    psc.setValue(2, 0);
    assert(psc.getTotalSum() == 5);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 1);
    assert(psc.getPrefixSum(3) == 1);
    assert(psc.getPrefixSum(4) == 2);
    assert(psc.getPrefixSum(5) == 5);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(3, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(4, 0));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(4, 1));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(4, 2));
    // [1, 0, 0, 0, 3]
    psc.setValue(3, 0);
    assert(psc.getTotalSum() == 4);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 1);
    assert(psc.getPrefixSum(3) == 1);
    assert(psc.getPrefixSum(4) == 1);
    assert(psc.getPrefixSum(5) == 4);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(4, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(4, 1));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(4, 2));
    // [1, 1, 0, 1, 1]
    psc.setValue(1, 1);
    psc.setValue(3, 1);
    psc.setValue(4, 1);
    assert(psc.getTotalSum() == 4);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 2);
    assert(psc.getPrefixSum(3) == 2);
    assert(psc.getPrefixSum(4) == 3);
    assert(psc.getPrefixSum(5) == 4);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(3, 0));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(4, 0));
  });
}

// getTotalSum with typical values
void _test02() {
  forBoth(<int>[1, 1, 2, 1, 3], (psc) { assert(psc.getTotalSum() == 8); });
  forBoth(<int>[10], (psc) { assert(psc.getTotalSum() == 10); });
  forBoth(<int>[5, 5, 5], (psc) { assert(psc.getTotalSum() == 15); });
}

// getTotalSum with all zeroes
void _test03() {
  forBoth(<int>[0, 0, 0], (psc) { assert(psc.getTotalSum() == 0); });
  forBoth(<int>[0], (psc) { assert(psc.getTotalSum() == 0); });
}

// getTotalSum with empty array
void _test04() {
  forBoth(<int>[], (psc) { assert(psc.getTotalSum() == 0); });
}

// getTotalSum with single element
void _test05() {
  forBoth(<int>[0], (psc) { assert(psc.getTotalSum() == 0); });
  forBoth(<int>[1], (psc) { assert(psc.getTotalSum() == 1); });
  forBoth(<int>[100], (psc) { assert(psc.getTotalSum() == 100); });
}

// getPrefixSum with typical values
void _test06() {
  forBoth(<int>[1, 1, 2, 1, 3], (psc) {
    assert(psc.getPrefixSum(0) == 0);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 2);
    assert(psc.getPrefixSum(3) == 4);
    assert(psc.getPrefixSum(4) == 5);
    assert(psc.getPrefixSum(5) == 8);
  });
}

// getPrefixSum with all zeroes
void _test07() {
  forBoth(<int>[0, 0, 0], (psc) {
    assert(psc.getPrefixSum(0) == 0);
    assert(psc.getPrefixSum(1) == 0);
    assert(psc.getPrefixSum(2) == 0);
    assert(psc.getPrefixSum(3) == 0);
  });
}

// getPrefixSum with single element
void _test08() {
  forBoth(<int>[7], (psc) {
    assert(psc.getPrefixSum(0) == 0);
    assert(psc.getPrefixSum(1) == 7);
  });
}

// getPrefixSum with empty array
void _test09() {
  forBoth(<int>[], (psc) {
    assert(psc.getPrefixSum(0) == 0);
  });
}

// getPrefixSum with leading/trailing zeroes
void _test10() {
  forBoth(<int>[0, 0, 3, 0, 0], (psc) {
    assert(psc.getPrefixSum(0) == 0);
    assert(psc.getPrefixSum(1) == 0);
    assert(psc.getPrefixSum(2) == 0);
    assert(psc.getPrefixSum(3) == 3);
    assert(psc.getPrefixSum(4) == 3);
    assert(psc.getPrefixSum(5) == 3);
  });
}

// getIndexOf with typical values
void _test11() {
  forBoth(<int>[1, 1, 2, 1, 3], (psc) {
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(2, 0));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(2, 1));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(3, 0));
    assert(psc.getIndexOf(5) == PrefixSumIndexOfResult(4, 0));
    assert(psc.getIndexOf(6) == PrefixSumIndexOfResult(4, 1));
    assert(psc.getIndexOf(7) == PrefixSumIndexOfResult(4, 2));
    assert(psc.getIndexOf(8) == PrefixSumIndexOfResult(4, 3));
  });
}

// getIndexOf with all zeroes
void _test12() {
  forBoth(<int>[0, 0, 0], (psc) {
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(2, 0));
  });
}

// getIndexOf with single zero
void _test13() {
  forBoth(<int>[0], (psc) {
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
  });
}

// getIndexOf with single element
void _test14() {
  forBoth(<int>[5], (psc) {
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(0, 1));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(0, 4));
  });
}

// getIndexOf with leading zeroes
void _test15() {
  forBoth(<int>[0, 0, 3], (psc) {
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(2, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(2, 1));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(2, 2));
  });
}

// getIndexOf with trailing zeroes
void _test16() {
  forBoth(<int>[3, 0, 0], (psc) {
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(0, 1));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(0, 2));
  });
}

// getIndexOf with interleaved zeroes
void _test17() {
  forBoth(<int>[0, 1, 0, 2, 0], (psc) {
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(3, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(3, 1));
  });
}

// getIndexOf with all ones
void _test18() {
  forBoth(<int>[1, 1, 1, 1, 1], (psc) {
    for (int i = 0; i < 5; i++) {
      assert(psc.getIndexOf(i) == PrefixSumIndexOfResult(i, 0));
    }
  });
}

// getIndexOf with large value in single element
void _test19() {
  forBoth(<int>[1000], (psc) {
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(500) == PrefixSumIndexOfResult(0, 500));
    assert(psc.getIndexOf(999) == PrefixSumIndexOfResult(0, 999));
  });
}

// setValue no-op when value unchanged
void _test20() {
  forBoth(<int>[1, 2, 3], (psc) {
    assert(psc.getTotalSum() == 6);
    psc.setValue(1, 2);
    assert(psc.getTotalSum() == 6);
  });
}

// setValue increase
void _test21() {
  forBoth(<int>[1, 2, 3], (psc) {
    psc.setValue(1, 5);
    assert(psc.getTotalSum() == 9);
    assert(psc.getPrefixSum(2) == 6);
    assert(psc.getPrefixSum(3) == 9);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(5) == PrefixSumIndexOfResult(1, 4));
    assert(psc.getIndexOf(6) == PrefixSumIndexOfResult(2, 0));
  });
}

// setValue decrease
void _test22() {
  forBoth(<int>[1, 5, 3], (psc) {
    psc.setValue(1, 2);
    assert(psc.getTotalSum() == 6);
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(1, 1));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(2, 0));
  });
}

// setValue to zero
void _test23() {
  forBoth(<int>[1, 2, 3], (psc) {
    psc.setValue(1, 0);
    assert(psc.getTotalSum() == 4);
    assert(psc.getPrefixSum(2) == 1);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(2, 0));
  });
}

// setValue from zero
void _test24() {
  forBoth(<int>[0, 0, 0], (psc) {
    psc.setValue(1, 3);
    assert(psc.getTotalSum() == 3);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(1, 2));
  });
}

// setValue on first element
void _test25() {
  forBoth(<int>[1, 2, 3], (psc) {
    psc.setValue(0, 10);
    assert(psc.getTotalSum() == 15);
    assert(psc.getPrefixSum(1) == 10);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(9) == PrefixSumIndexOfResult(0, 9));
    assert(psc.getIndexOf(10) == PrefixSumIndexOfResult(1, 0));
  });
}

// setValue on last element
void _test26() {
  forBoth(<int>[1, 2, 3], (psc) {
    psc.setValue(2, 10);
    assert(psc.getTotalSum() == 13);
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(2, 0));
    assert(psc.getIndexOf(12) == PrefixSumIndexOfResult(2, 9));
  });
}

// set all values to zero then restore
void _test27() {
  forBoth(<int>[1, 2, 3], (psc) {
    psc.setValue(0, 0);
    psc.setValue(1, 0);
    psc.setValue(2, 0);
    assert(psc.getTotalSum() == 0);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(2, 0));
    psc.setValue(0, 4);
    assert(psc.getTotalSum() == 4);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(0, 3));
  });
}

// setValue multiple times on same index
void _test28() {
  forBoth(<int>[1, 1, 1], (psc) {
    psc.setValue(1, 5);
    psc.setValue(1, 2);
    psc.setValue(1, 10);
    assert(psc.getTotalSum() == 12);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(10) == PrefixSumIndexOfResult(1, 9));
    assert(psc.getIndexOf(11) == PrefixSumIndexOfResult(2, 0));
  });
}

// insertValues at beginning
void _test29() {
  forBoth(<int>[3, 4], (psc) {
    psc.insertValues(0, <int>[1, 2]);
    assert(psc.getTotalSum() == 10);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 3);
    assert(psc.getPrefixSum(3) == 6);
    assert(psc.getPrefixSum(4) == 10);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(2, 0));
  });
}

// insertValues at end
void _test30() {
  forBoth(<int>[1, 2], (psc) {
    psc.insertValues(2, <int>[3, 4]);
    assert(psc.getTotalSum() == 10);
    assert(psc.getPrefixSum(3) == 6);
    assert(psc.getPrefixSum(4) == 10);
  });
}

// insertValues in the middle
void _test31() {
  forBoth(<int>[1, 4], (psc) {
    psc.insertValues(1, <int>[2, 3]);
    assert(psc.getTotalSum() == 10);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 3);
    assert(psc.getPrefixSum(3) == 6);
    assert(psc.getPrefixSum(4) == 10);
  });
}

// insertValues with zeroes
void _test32() {
  forBoth(<int>[1, 2], (psc) {
    psc.insertValues(1, <int>[0, 0]);
    assert(psc.getTotalSum() == 3);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 1);
    assert(psc.getPrefixSum(3) == 1);
    assert(psc.getPrefixSum(4) == 3);
  });
}

// insertValues into all-zeroes
void _test33() {
  forBoth(<int>[0, 0, 0], (psc) {
    psc.insertValues(1, <int>[2, 3]);
    assert(psc.getTotalSum() == 5);
    assert(psc.getPrefixSum(1) == 0);
    assert(psc.getPrefixSum(2) == 2);
    assert(psc.getPrefixSum(3) == 5);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(2, 0));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(2, 2));
  });
}

// insertValues into empty computer
void _test34() {
  forBoth(<int>[], (psc) {
    psc.insertValues(0, <int>[5, 3]);
    assert(psc.getTotalSum() == 8);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(0, 4));
    assert(psc.getIndexOf(5) == PrefixSumIndexOfResult(1, 0));
  });
}

// removeValues from beginning
void _test35() {
  forBoth(<int>[1, 2, 3, 4], (psc) {
    psc.removeValues(0, 2);
    assert(psc.getTotalSum() == 7);
    assert(psc.getPrefixSum(1) == 3);
    assert(psc.getPrefixSum(2) == 7);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(1, 0));
  });
}

// removeValues from end
void _test36() {
  forBoth(<int>[1, 2, 3, 4], (psc) {
    psc.removeValues(2, 2);
    assert(psc.getTotalSum() == 3);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 3);
  });
}

// removeValues from the middle
void _test37() {
  forBoth(<int>[1, 2, 3, 4], (psc) {
    psc.removeValues(1, 2);
    assert(psc.getTotalSum() == 5);
    assert(psc.getPrefixSum(1) == 1);
    assert(psc.getPrefixSum(2) == 5);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(1, 3));
  });
}

// removeValues all
void _test38() {
  forBoth(<int>[1, 2, 3], (psc) {
    psc.removeValues(0, 3);
    assert(psc.getTotalSum() == 0);
  });
}

// removeValues single element
void _test39() {
  forBoth(<int>[5, 10, 15], (psc) {
    psc.removeValues(1, 1);
    assert(psc.getTotalSum() == 20);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(5) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(19) == PrefixSumIndexOfResult(1, 14));
  });
}

// removeValues zero-valued elements
void _test40() {
  forBoth(<int>[0, 0, 5, 0, 0], (psc) {
    psc.removeValues(0, 2);
    assert(psc.getTotalSum() == 5);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(0, 4));
  });
}

// insert then remove
void _test41() {
  forBoth(<int>[1, 2, 3], (psc) {
    psc.insertValues(1, <int>[10, 20]);
    assert(psc.getTotalSum() == 36);
    psc.removeValues(1, 2);
    assert(psc.getTotalSum() == 6);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(3) == PrefixSumIndexOfResult(2, 0));
  });
}

// remove then insert at same position
void _test42() {
  forBoth(<int>[1, 2, 3], (psc) {
    psc.removeValues(1, 1);
    psc.insertValues(1, <int>[5]);
    assert(psc.getTotalSum() == 9);
    assert(psc.getIndexOf(1) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(5) == PrefixSumIndexOfResult(1, 4));
    assert(psc.getIndexOf(6) == PrefixSumIndexOfResult(2, 0));
  });
}

// setValue then insert then remove
void _test43() {
  forBoth(<int>[1, 1, 1], (psc) {
    psc.setValue(0, 5);
    psc.insertValues(1, <int>[10]);
    psc.removeValues(3, 1);
    // [5, 10, 1]
    assert(psc.getTotalSum() == 16);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(4) == PrefixSumIndexOfResult(0, 4));
    assert(psc.getIndexOf(5) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(14) == PrefixSumIndexOfResult(1, 9));
    assert(psc.getIndexOf(15) == PrefixSumIndexOfResult(2, 0));
  });
}

// multiple queries between mutations are consistent
void _test44() {
  forBoth(<int>[2, 3, 5], (psc) {
    assert(psc.getTotalSum() == 10);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    psc.setValue(1, 0);
    assert(psc.getTotalSum() == 7);
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(2, 0));
    psc.setValue(1, 3);
    assert(psc.getTotalSum() == 10);
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(1, 0));
  });
}

// large values
void _test45() {
  forBoth(<int>[100, 200, 300], (psc) {
    assert(psc.getTotalSum() == 600);
    assert(psc.getPrefixSum(1) == 100);
    assert(psc.getPrefixSum(2) == 300);
    assert(psc.getPrefixSum(3) == 600);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(0, 0));
    assert(psc.getIndexOf(99) == PrefixSumIndexOfResult(0, 99));
    assert(psc.getIndexOf(100) == PrefixSumIndexOfResult(1, 0));
    assert(psc.getIndexOf(299) == PrefixSumIndexOfResult(1, 199));
    assert(psc.getIndexOf(300) == PrefixSumIndexOfResult(2, 0));
    assert(psc.getIndexOf(599) == PrefixSumIndexOfResult(2, 299));
  });
}

// many elements
void _test46() {
  forBoth(List<int>.filled(100, 1), (psc) {
    assert(psc.getTotalSum() == 100);
    assert(psc.getPrefixSum(50) == 50);
    for (int i = 0; i < 100; i++) {
      assert(psc.getIndexOf(i) == PrefixSumIndexOfResult(i, 0));
    }
  });
}

// many elements all zeroes
void _test47() {
  forBoth(List<int>.filled(100, 0), (psc) {
    assert(psc.getTotalSum() == 0);
    for (int i = 0; i <= 100; i++) {
      assert(psc.getPrefixSum(i) == 0);
    }
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(99, 0));
  });
}

// setValue between queries re-validates correctly
void _test48() {
  forBoth(<int>[1, 1, 1, 1, 1], (psc) {
    assert(psc.getTotalSum() == 5);
    psc.setValue(2, 10);
    assert(psc.getTotalSum() == 14);
    assert(psc.getPrefixSum(3) == 12);
    assert(psc.getIndexOf(2) == PrefixSumIndexOfResult(2, 0));
    assert(psc.getIndexOf(11) == PrefixSumIndexOfResult(2, 9));
    assert(psc.getIndexOf(12) == PrefixSumIndexOfResult(3, 0));
    assert(psc.getIndexOf(13) == PrefixSumIndexOfResult(4, 0));
    psc.setValue(0, 0);
    assert(psc.getTotalSum() == 13);
    assert(psc.getIndexOf(0) == PrefixSumIndexOfResult(1, 0));
  });
}

void runAll() {
  _test01();
  _test02();
  _test03();
  _test04();
  _test05();
  _test06();
  _test07();
  _test08();
  _test09();
  _test10();
  _test11();
  _test12();
  _test13();
  _test14();
  _test15();
  _test16();
  _test17();
  _test18();
  _test19();
  _test20();
  _test21();
  _test22();
  _test23();
  _test24();
  _test25();
  _test26();
  _test27();
  _test28();
  _test29();
  _test30();
  _test31();
  _test32();
  _test33();
  _test34();
  _test35();
  _test36();
  _test37();
  _test38();
  _test39();
  _test40();
  _test41();
  _test42();
  _test43();
  _test44();
  _test45();
  _test46();
  _test47();
  _test48();
}
