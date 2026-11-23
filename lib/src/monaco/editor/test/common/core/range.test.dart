// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/range.test.ts
// Translated 1:1. The six mocha cases become Dart functions carrying the exact
// `strictEqual` / `ok` assertions.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;

/// 1:1: `test('empty range')`
void testEmptyRange() {
  final Range s = Range(1, 1, 1, 1);
  assert(s.startLineNumber == 1);
  assert(s.startColumn == 1);
  assert(s.endLineNumber == 1);
  assert(s.endColumn == 1);
  assert(s.isEmpty() == true);
}

/// 1:1: `test('swap start and stop same line')`
void testSwapStartAndStopSameLine() {
  final Range s = Range(1, 2, 1, 1);
  assert(s.startLineNumber == 1);
  assert(s.startColumn == 1);
  assert(s.endLineNumber == 1);
  assert(s.endColumn == 2);
  assert(s.isEmpty() == false);
}

/// 1:1: `test('swap start and stop')`
void testSwapStartAndStop() {
  final Range s = Range(2, 1, 1, 2);
  assert(s.startLineNumber == 1);
  assert(s.startColumn == 2);
  assert(s.endLineNumber == 2);
  assert(s.endColumn == 1);
  assert(s.isEmpty() == false);
}

/// 1:1: `test('no swap same line')`
void testNoSwapSameLine() {
  final Range s = Range(1, 1, 1, 2);
  assert(s.startLineNumber == 1);
  assert(s.startColumn == 1);
  assert(s.endLineNumber == 1);
  assert(s.endColumn == 2);
  assert(s.isEmpty() == false);
}

/// 1:1: `test('no swap')`
void testNoSwap() {
  final Range s = Range(1, 1, 2, 1);
  assert(s.startLineNumber == 1);
  assert(s.startColumn == 1);
  assert(s.endLineNumber == 2);
  assert(s.endColumn == 1);
  assert(s.isEmpty() == false);
}

/// 1:1: `test('compareRangesUsingEnds')`
void testCompareRangesUsingEnds() {
  assert(Range.compareRangesUsingEnds(Range(1, 1, 1, 3), Range(1, 2, 1, 4)) < 0);
  assert(Range.compareRangesUsingEnds(Range(1, 1, 1, 3), Range(1, 1, 1, 4)) < 0);
  assert(Range.compareRangesUsingEnds(Range(1, 2, 1, 3), Range(1, 1, 1, 4)) < 0);
  assert(Range.compareRangesUsingEnds(Range(1, 1, 1, 4), Range(1, 2, 1, 4)) < 0);
  assert(Range.compareRangesUsingEnds(Range(1, 1, 1, 4), Range(1, 1, 1, 4)) == 0);
  assert(Range.compareRangesUsingEnds(Range(1, 2, 1, 4), Range(1, 1, 1, 4)) > 0);
  assert(Range.compareRangesUsingEnds(Range(1, 1, 1, 5), Range(1, 2, 1, 4)) > 0);
  assert(Range.compareRangesUsingEnds(Range(1, 1, 2, 4), Range(1, 1, 1, 4)) > 0);
  assert(Range.compareRangesUsingEnds(Range(1, 2, 5, 1), Range(1, 1, 1, 4)) > 0);
}

/// 1:1: `test('containsPosition')`
void testContainsPosition() {
  final Range r = Range(2, 2, 5, 10);
  assert(r.containsPosition(Position(1, 3)) == false);
  assert(r.containsPosition(Position(2, 1)) == false);
  assert(r.containsPosition(Position(2, 2)) == true);
  assert(r.containsPosition(Position(2, 3)) == true);
  assert(r.containsPosition(Position(3, 1)) == true);
  assert(r.containsPosition(Position(5, 9)) == true);
  assert(r.containsPosition(Position(5, 10)) == true);
  assert(r.containsPosition(Position(5, 11)) == false);
  assert(r.containsPosition(Position(6, 1)) == false);
}

/// 1:1: `test('containsRange')`
void testContainsRange() {
  final Range r = Range(2, 2, 5, 10);
  assert(r.containsRange(Range(1, 3, 2, 2)) == false);
  assert(r.containsRange(Range(2, 1, 2, 2)) == false);
  assert(r.containsRange(Range(2, 2, 5, 11)) == false);
  assert(r.containsRange(Range(2, 2, 6, 1)) == false);
  assert(r.containsRange(Range(5, 9, 6, 1)) == false);
  assert(r.containsRange(Range(5, 10, 6, 1)) == false);
  assert(r.containsRange(Range(2, 2, 5, 10)) == true);
  assert(r.containsRange(Range(2, 3, 5, 9)) == true);
  assert(r.containsRange(Range(3, 100, 4, 100)) == true);
}

/// 1:1: `test('areIntersecting')`
void testAreIntersecting() {
  assert(Range.areIntersecting(Range(2, 2, 3, 2), Range(4, 2, 5, 2)) == false);
  assert(Range.areIntersecting(Range(4, 2, 5, 2), Range(2, 2, 3, 2)) == false);
  assert(Range.areIntersecting(Range(4, 2, 5, 2), Range(5, 2, 6, 2)) == false);
  assert(Range.areIntersecting(Range(5, 2, 6, 2), Range(4, 2, 5, 2)) == false);
  assert(Range.areIntersecting(Range(2, 2, 2, 7), Range(2, 4, 2, 6)) == true);
  assert(Range.areIntersecting(Range(2, 2, 2, 7), Range(2, 4, 2, 9)) == true);
  assert(Range.areIntersecting(Range(2, 4, 2, 9), Range(2, 2, 2, 7)) == true);
}

void runAll() {
  testEmptyRange();
  testSwapStartAndStopSameLine();
  testSwapStartAndStop();
  testNoSwapSameLine();
  testNoSwap();
  testCompareRangesUsingEnds();
  testContainsPosition();
  testContainsRange();
  testAreIntersecting();
}
