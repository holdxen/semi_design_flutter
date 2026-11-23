// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/model/bracketPairColorizer/length.test.ts
// Translated 1:1. The two mocha cases become Dart functions carrying the exact
// `strictEqual` / `deepStrictEqual` assertions.
// `lengthToObj(...).toString()` in TS yields `'<lineCount>,<columnCount>'`;
// Dart's TextLength has no such toString, so `_toStr` formats the two fields
// explicitly to preserve the asserted values.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here (the outer runner performs that check).
// ---------------------------------------------------------------------------

import '../../../../common/model/bracketPairsTextModelPart/bracketPairsTree/length.dart'
    show Length, lengthAdd, lengthDiffNonNegative, lengthToObj, toLength;

/// 1:1: `function toStr(length: Length): string`
String _toStr(Length length) {
  final obj = lengthToObj(length);
  return '${obj.lineCount},${obj.columnCount}';
}

/// 1:1: `test('Basic')`
void testBasic() {
  final Length l1 = toLength(100, 10);
  assert(lengthToObj(l1).lineCount == 100);
  assert(lengthToObj(l1).columnCount == 10);

  assert(_toStr(lengthAdd(l1, toLength(100, 10))) == '200,10');
  assert(_toStr(lengthAdd(l1, toLength(0, 10))) == '100,20');
}

/// 1:1: `test('lengthDiffNonNeg')`
void testLengthDiffNonNeg() {
  assert(_toStr(lengthDiffNonNegative(toLength(100, 10), toLength(100, 20))) ==
      '0,10');
  assert(_toStr(lengthDiffNonNegative(toLength(100, 10), toLength(101, 20))) ==
      '1,20');
  assert(_toStr(lengthDiffNonNegative(toLength(101, 30), toLength(101, 20))) ==
      '0,0');
  assert(_toStr(lengthDiffNonNegative(toLength(102, 10), toLength(101, 20))) ==
      '0,0');
}

void runAll() {
  testBasic();
  testLengthDiffNonNeg();
}
