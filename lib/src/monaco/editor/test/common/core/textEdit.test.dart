// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/textEdit.test.ts
// Translated 1:1. The mocha suite's active cases become Dart functions:
//   - inverse: 3 explicit surrogate-pair cases + 20 seeded fuzz cases
//     (`test.skip('brute-force')` is a skip and is omitted).
//   - removeCommonPrefixAndSuffix: 1 case.
//   - compose: 100 seeded fuzz cases (`test.skip('fuzz')` is a skip, omitted).
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../common/core/edits/textEdit.dart'
    show TextEdit, TextReplacement;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import '../../../common/core/text/abstractText.dart' show StringText;
import 'random.dart' show Random;

/// inverse runTest(seed): 1:1
void _runInverseTest(int seed) {
  final Random rand = Random.create(seed);
  final StringText source =
      StringText(rand.nextMultiLineString(10, OffsetRange(0, 10)));
  final TextEdit edit = rand.nextTextEdit(source, rand.nextIntRange(1, 5));
  final TextEdit invEdit = edit.inverse(source);
  final String s1 = edit.apply(source);
  final String s2 = invEdit.applyToString(s1);
  assert(s2 == source.value);
}

/// 1:1: `test('insertion of a surrogate pair')`
void testInsertionOfSurrogatePair() {
  final StringText source = StringText('abc');
  final TextEdit edit = TextEdit.insert(Position(1, 2), '\uD83D\uDE00'); // 😀
  assert(edit.inverse(source).applyToString(edit.apply(source)) == source.value);
}

/// 1:1: `test('multiline replacement ending in surrogate pairs')`
void testMultilineReplacementEndingInSurrogatePairs() {
  final StringText source = StringText('abc\ndef');
  final TextEdit edit = TextEdit.replace(Range(1, 2, 2, 2), 'x\n\uD83D\uDE00\uD834\uDD1E');
  assert(edit.inverse(source).applyToString(edit.apply(source)) == source.value);
}

/// 1:1: `test('multiple replacements containing surrogate pairs on the same line')`
void testMultipleReplacementsSurrogatePairsSameLine() {
  final StringText source = StringText('abcd');
  final TextEdit edit = TextEdit(<TextReplacement>[
    TextReplacement(Range(1, 2, 1, 2), '\uD83D\uDE00'),
    TextReplacement(Range(1, 3, 1, 4), '\uD834\uDD1E'),
  ]);
  assert(edit.inverse(source).applyToString(edit.apply(source)) == source.value);
}

/// 1:1: inverse `for (let seed = 0; seed < 20; seed++) test('test ${seed}')`
void runInverseFuzzCases() {
  for (int seed = 0; seed < 20; seed++) {
    _runInverseTest(seed);
  }
}

/// 1:1: `test('preserves surrogate pairs around the changed text')`
void testRemoveCommonPrefixAndSuffixSurrogatePairs() {
  final StringText source = StringText('\uD83D\uDE00abc\uD834\uDD1E');
  final TextReplacement replacement =
      TextReplacement(Range(1, 1, 1, 8), '\uD83D\uDE00axc\uD834\uDD1E');
  final TextReplacement reduced = replacement.removeCommonPrefixAndSuffix(source);

  assert(reduced.range.startLineNumber == 1);
  assert(reduced.range.startColumn == 4);
  assert(reduced.range.endLineNumber == 1);
  assert(reduced.range.endColumn == 5);
  assert(reduced.text == 'x');
  assert(reduced.toEdit().apply(source) == '\uD83D\uDE00axc\uD834\uDD1E');
}

/// compose runTest(seed): 1:1
void _runComposeTest(int seed) {
  final Random rand = Random.create(seed);
  final StringText s0 =
      StringText(rand.nextMultiLineString(10, OffsetRange(0, 10)));
  final TextEdit edits1 = rand.nextTextEdit(s0, rand.nextIntRange(1, 4));
  final String s1 = edits1.applyToString(s0.value);
  final StringText s1Text = StringText(s1);
  final TextEdit edits2 = rand.nextTextEdit(s1Text, rand.nextIntRange(1, 4));
  final String s2 = edits2.applyToString(s1);
  final TextEdit combinedEdits = edits1.compose(edits2);
  final String s2C = combinedEdits.applyToString(s0.value);
  assert(s2C == s2);
}

/// 1:1: compose `for (let seed = 0; seed < 100; seed++) test('case ${seed}')`
void runComposeFuzzCases() {
  for (int seed = 0; seed < 100; seed++) {
    _runComposeTest(seed);
  }
}

void runAll() {
  testInsertionOfSurrogatePair();
  testMultilineReplacementEndingInSurrogatePairs();
  testMultipleReplacementsSurrogatePairsSameLine();
  runInverseFuzzCases();
  testRemoveCommonPrefixAndSuffixSurrogatePairs();
  runComposeFuzzCases();
}
