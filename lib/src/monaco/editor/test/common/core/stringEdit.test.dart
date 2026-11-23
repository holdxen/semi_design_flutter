// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/stringEdit.test.ts
// Translated 1:1. The mocha suites' active cases become Dart functions:
//   - StringEdit: basic, inverse (1000 seeded cases), compose (1000 seeded
//     cases), equals, getNewRanges, getJoinedReplaceRange, getLengthDelta,
//     rebase variants.
//   - ArrayEdit: basic, compose (100 seeded cases).
//   - tryRebase invariants: 1000 seeded cases.
// `test.skip('fuzz')` cases and the suite-level
// `ensureNoDisposablesAreLeakedInTestSuite()` hook are intentionally omitted.
// ---------------------------------------------------------------------------

import '../../../common/core/edits/arrayEdit.dart' show ArrayEdit, ArrayReplacement;
import '../../../common/core/edits/stringEdit.dart' show StringEdit, StringReplacement;
import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import 'random.dart' show Random;

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

void _rangeEq(OffsetRange a, OffsetRange b) {
  assert(a.start == b.start && a.endExclusive == b.endExclusive);
}

StringEdit getRandomEdit(String str, int count, Random rng) {
  final List<StringReplacement> edits = <StringReplacement>[];
  int i = 0;
  for (int j = 0; j < count; j++) {
    if (i >= str.length) {
      break;
    }
    edits.add(getRandomSingleEdit(str, i, rng));
    i = edits[j].replaceRange.endExclusive + 1;
  }
  return StringEdit.create(edits);
}

StringReplacement getRandomSingleEdit(String str, int rangeOffsetStart, Random rng) {
  final int offsetStart = rng.nextIntRange(rangeOffsetStart, str.length);
  final int offsetEnd = rng.nextIntRange(offsetStart, str.length);

  final int textStart = rng.nextIntRange(0, str.length);
  final int textLen = rng.nextIntRange(0, _min(7, str.length - textStart));

  return StringReplacement(
    OffsetRange(offsetStart, offsetEnd),
    str.substring(textStart, textStart + textLen),
  );
}

int _min(int a, int b) => a < b ? a : b;

// --------------------------- StringEdit ------------------------------------

void testStringEditBasic() {
  const String arr = '0123456789';
  final StringEdit edit = StringEdit.replace(OffsetRange(4, 6), 'xyz');
  final String result = edit.apply(arr);
  assert(result == '0123xyz6789');
}

void _runInverseTest(int seed) {
  final Random rng = Random.create(seed);
  const String s0 = 'abcde\nfghij\nklmno\npqrst\n';
  final StringEdit e = getRandomEdit(s0, rng.nextIntRange(1, 4), rng);
  final StringEdit eInv = e.inverse(s0);
  assert(eInv.apply(e.apply(s0)) == s0);
}

void runInverseCases() {
  for (int i = 0; i < 1000; i++) {
    _runInverseTest(i);
  }
}

void _runComposeTest(int seed) {
  final Random rng = Random.create(seed);
  const String s0 = 'abcde\nfghij\nklmno\npqrst\n';
  final StringEdit edits1 = getRandomEdit(s0, rng.nextIntRange(1, 4), rng);
  final String s1 = edits1.apply(s0);
  final StringEdit edits2 = getRandomEdit(s1, rng.nextIntRange(1, 4), rng);
  final String s2 = edits2.apply(s1);
  final StringEdit combinedEdits = edits1.compose(edits2);
  final String s2C = combinedEdits.apply(s0);
  assert(s2C == s2);
}

void runComposeCases() {
  for (int i = 0; i < 1000; i++) {
    _runComposeTest(i);
  }
}

void testStringEditEquals() {
  final StringEdit edit1 = StringEdit.replace(OffsetRange(4, 6), 'xyz');
  final StringEdit edit2 = StringEdit.replace(OffsetRange(4, 6), 'xyz');
  final StringEdit edit3 = StringEdit.replace(OffsetRange(5, 6), 'xyz');
  final StringEdit edit4 = StringEdit.replace(OffsetRange(4, 6), 'xy');

  assert(edit1.equals(edit1));
  assert(edit1.equals(edit2));
  assert(edit2.equals(edit1));

  assert(!edit1.equals(edit3));
  assert(!edit1.equals(edit4));
}

void testStringEditGetNewRanges() {
  final StringEdit edit = StringEdit.create([
    StringReplacement(OffsetRange(4, 6), 'abcde'),
    StringReplacement(OffsetRange(7, 9), 'a'),
  ]);
  final List<OffsetRange> ranges = edit.getNewRanges();
  assert(ranges.length == 2);
  _rangeEq(ranges[0], OffsetRange(4, 9));
  _rangeEq(ranges[1], OffsetRange(10, 11));
}

void testStringEditGetJoinedReplaceRange() {
  final StringEdit edit = StringEdit.create([
    StringReplacement(OffsetRange(4, 6), 'abcde'),
    StringReplacement(OffsetRange(7, 9), 'a'),
  ]);
  final OffsetRange? range = edit.getJoinedReplaceRange();
  assert(range != null);
  _rangeEq(range!, OffsetRange(4, 9));
}

void testStringEditGetLengthDelta() {
  final StringEdit edit = StringEdit.create([
    StringReplacement(OffsetRange(4, 6), 'abcde'),
    StringReplacement(OffsetRange(7, 9), 'a'),
  ]);
  assert(edit.getLengthDelta() == 2);
  assert(edit.replacements[0].getLengthDelta() == 3);
  assert(edit.replacements[1].getLengthDelta() == -1);
}

void testAdjacentEditAndInsertRebase() {
  final StringEdit firstEdit = StringEdit.create([
    StringReplacement.replaceStatic(OffsetRange(1826, 1838), 'function fib(n: number): number {'),
  ]);
  final StringEdit followupEdit = StringEdit.create([
    StringReplacement.replaceStatic(OffsetRange(1838, 1838),
        '\n\tif (n <= 1) {\n\t\treturn n;\n\t}\n\treturn fib(n - 1) + fib(n - 2);\n}'),
  ]);
  final StringEdit? rebasedEdit = followupEdit.tryRebase(firstEdit);

  assert(rebasedEdit != null);
  assert(rebasedEdit!.replacements[0].replaceRange.start == 1859);
  assert(rebasedEdit!.replacements[0].replaceRange.endExclusive == 1859);
}

void testConcurrentInsertsConflict() {
  final StringEdit firstEdit = StringEdit.create([
    StringReplacement.replaceStatic(OffsetRange(1838, 1838), '1'),
  ]);
  final StringEdit followupEdit = StringEdit.create([
    StringReplacement.replaceStatic(OffsetRange(1838, 1838), '2'),
  ]);
  final StringEdit? rebasedEdit = followupEdit.tryRebase(firstEdit);
  assert(rebasedEdit == null);
}

void testTryRebaseNonDisjointNegativeOffset() {
  final StringEdit ourEdit = StringEdit.create([
    StringReplacement(OffsetRange(100, 110), 'A'),
    StringReplacement(OffsetRange.emptyAt(120), 'B'),
  ]);
  final StringEdit baseEdit = StringEdit.create([
    StringReplacement(OffsetRange(110, 125), ''),
  ]);
  final StringEdit? result = ourEdit.tryRebase(baseEdit);
  assert(result == null);
}

void testTryRebaseSucceedsDisjoint() {
  final StringEdit ourEdit = StringEdit.create([
    StringReplacement(OffsetRange(100, 110), 'A'),
    StringReplacement(OffsetRange(200, 210), 'B'),
  ]);
  final StringEdit baseEdit = StringEdit.create([
    StringReplacement(OffsetRange(50, 60), ''),
  ]);
  final StringEdit? result = ourEdit.tryRebase(baseEdit);
  assert(result != null);
  assert(result!.replacements[0].replaceRange.start == 90);
  assert(result!.replacements[1].replaceRange.start == 190);
}

void testRebaseSkipConflicting() {
  final StringEdit ourEdit = StringEdit.create([
    StringReplacement(OffsetRange(100, 110), 'A'),
    StringReplacement(OffsetRange.emptyAt(120), 'B'),
  ]);
  final StringEdit baseEdit = StringEdit.create([
    StringReplacement(OffsetRange(110, 125), ''),
  ]);
  final StringEdit result = ourEdit.rebaseSkipConflicting(baseEdit);
  assert(result.replacements.length == 1);
  assert(result.replacements[0].replaceRange.start == 100);
}

// --------------------------- ArrayEdit -------------------------------------

void testArrayEditBasic() {
  final List<String> arr = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  final ArrayEdit<String> edit = ArrayEdit.replace(OffsetRange(4, 6), <String>['x', 'y', 'z']);
  final List<String> result = edit.apply(arr);
  assert(_listEq(result, ['0', '1', '2', '3', 'x', 'y', 'z', '6', '7', '8', '9']));
}

void _runArrayComposeTest(int seed) {
  final Random rng = Random.create(seed);
  const String s0 = 'abcde\nfghij\nklmno\npqrst\n';

  final StringEdit e1 = getRandomEdit(s0, rng.nextIntRange(1, 4), rng);
  final String s1 = e1.apply(s0);
  final StringEdit e2 = getRandomEdit(s1, rng.nextIntRange(1, 4), rng);

  final ArrayEdit<String> ae1 = ArrayEdit.create(
      e1.replacements.map((StringReplacement r) => ArrayReplacement<String>(r.replaceRange, r.newText.split(''))).toList());
  final ArrayEdit<String> ae2 = ArrayEdit.create(
      e2.replacements.map((StringReplacement r) => ArrayReplacement<String>(r.replaceRange, r.newText.split(''))).toList());
  final List<String> as0 = s0.split('');
  final List<String> as1 = ae1.apply(as0);
  final List<String> as2 = ae2.apply(as1);
  final ArrayEdit<String> aCombinedEdits = ae1.compose(ae2);

  final List<String> as2C = aCombinedEdits.apply(as0);
  assert(_listEq(as2, as2C));
}

void runArrayComposeCases() {
  for (int i = 0; i < 100; i++) {
    _runArrayComposeTest(i);
  }
}

// ----------------------- tryRebase invariants --------------------------------

void _runInvariantTest(int seed) {
  final Random rng = Random.create(seed);
  const String s0 = 'abcde\nfghij\nklmno\npqrst\n';

  final StringEdit e1 = getRandomEdit(s0, rng.nextIntRange(1, 4), rng);
  final StringEdit e2 = getRandomEdit(s0, rng.nextIntRange(1, 4), rng);

  final StringEdit? e1RebasedOnE2 = e1.tryRebase(e2);
  final StringEdit? e2RebasedOnE1 = e2.tryRebase(e1);

  // Invariant 1: e1.rebase(e2) != undefined <=> e2.rebase(e1) != undefined
  assert((e1RebasedOnE2 != null) == (e2RebasedOnE1 != null));

  // Invariant 2: e1.rebase(e2) != undefined => e1.compose(e2.rebase(e1)) = e2.compose(e1.rebase(e2))
  if (e1RebasedOnE2 != null && e2RebasedOnE1 != null) {
    final StringEdit path1 = e1.compose(e2RebasedOnE1);
    final StringEdit path2 = e2.compose(e1RebasedOnE2);
    final String result1 = path1.apply(s0);
    final String result2 = path2.apply(s0);
    assert(result1 == result2);
  }

  // Invariant 3: empty.rebase(e) = empty
  final StringEdit? emptyRebasedOnE1 = StringEdit.empty.tryRebase(e1);
  assert(emptyRebasedOnE1 != null);
  assert(emptyRebasedOnE1!.isEmpty());

  // Invariant 4: e.rebase(empty) = e
  final StringEdit? e1RebasedOnEmpty = e1.tryRebase(StringEdit.empty);
  assert(e1RebasedOnEmpty != null);
  assert(e1.equals(e1RebasedOnEmpty!));

  // Invariant 5 (TP2)
  final StringEdit e3 = getRandomEdit(s0, rng.nextIntRange(1, 4), rng);
  final StringEdit? e2OnE1 = e2.tryRebase(e1);
  final StringEdit? e1OnE2 = e1.tryRebase(e2);
  final StringEdit? e3OnE1 = e3.tryRebase(e1);
  final StringEdit? e3OnE2 = e3.tryRebase(e2);

  if (e2OnE1 != null && e1OnE2 != null && e3OnE1 != null && e3OnE2 != null) {
    final StringEdit? path1 = e3OnE1.tryRebase(e2OnE1);
    final StringEdit? path2 = e3OnE2.tryRebase(e1OnE2);
    if (path1 != null && path2 != null) {
      assert(path1.equals(path2));
    }
  }
}

void runInvariantCases() {
  for (int i = 0; i < 1000; i++) {
    _runInvariantTest(i);
  }
}

void runAll() {
  testStringEditBasic();
  runInverseCases();
  runComposeCases();
  testStringEditEquals();
  testStringEditGetNewRanges();
  testStringEditGetJoinedReplaceRange();
  testStringEditGetLengthDelta();
  testAdjacentEditAndInsertRebase();
  testConcurrentInsertsConflict();
  testTryRebaseNonDisjointNegativeOffset();
  testTryRebaseSucceedsDisjoint();
  testRebaseSkipConflicting();
  testArrayEditBasic();
  runArrayComposeCases();
  runInvariantCases();
}
