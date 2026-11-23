// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/test/browser/layout.test.ts
// Translated 1:1. The mocha suite's active cases become Dart functions.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../../common/core/2d/size.dart' show Size2D;
import '../../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import '../../browser/view/inlineEdits/utils/towersLayout.dart'
    show getMaxTowerHeightInAvailableArea;

num _h(OffsetRange range, List<Size2D> areas) =>
    getMaxTowerHeightInAvailableArea(range, areas);

void testTowerFitsWithinSingleArea() {
  assert(_h(OffsetRange(5, 15), [Size2D(50, 30)]) == 30);
}

void testMaxHeightAvailableInArea() {
  assert(_h(OffsetRange(5, 15), [Size2D(50, 30)]) == 30);
}

void testTowerExtendsBeyondAvailableWidth() {
  assert(_h(OffsetRange(0, 60), [Size2D(50, 30)]) == 0);
}

void testTowerFitsAcrossMultipleAreas() {
  assert(_h(OffsetRange(10, 40), [
    Size2D(20, 30),
    Size2D(20, 25),
    Size2D(20, 30),
  ]) == 25);
}

void testMinHeightAcrossOverlappingAreas() {
  assert(_h(OffsetRange(10, 40), [
    Size2D(20, 30),
    Size2D(20, 15),
    Size2D(20, 30),
  ]) == 15);
}

void testTowerAtLeftEdge() {
  assert(_h(OffsetRange(0, 10), [Size2D(50, 30)]) == 30);
}

void testTowerAtRightEdge() {
  assert(_h(OffsetRange(40, 50), [Size2D(50, 30)]) == 30);
}

void testTowerExactlyMatchesArea() {
  assert(_h(OffsetRange(0, 50), [Size2D(50, 30)]) == 30);
}

void testEmptyAvailableAreas() {
  assert(_h(OffsetRange(0, 10), <Size2D>[]) == 0);
}

void testTowerSpansExactlyTwoAreas() {
  assert(_h(OffsetRange(10, 50), [
    Size2D(30, 25),
    Size2D(30, 25),
  ]) == 25);
}

void testTowerStartsAtBoundaryBetweenTwoAreas() {
  assert(_h(OffsetRange(30, 50), [
    Size2D(30, 25),
    Size2D(30, 25),
  ]) == 25);
}

void testTowerWithVaryingHeightAreas() {
  assert(_h(OffsetRange(0, 50), [
    Size2D(10, 30),
    Size2D(10, 15),
    Size2D(10, 25),
    Size2D(10, 30),
    Size2D(10, 40),
  ]) == 15);
}

void testTowerBeyondAllAreasRight() {
  assert(_h(OffsetRange(100, 110), [Size2D(50, 30)]) == 0);
}

void runAll() {
  testTowerFitsWithinSingleArea();
  testMaxHeightAvailableInArea();
  testTowerExtendsBeyondAvailableWidth();
  testTowerFitsAcrossMultipleAreas();
  testMinHeightAcrossOverlappingAreas();
  testTowerAtLeftEdge();
  testTowerAtRightEdge();
  testTowerExactlyMatchesArea();
  testEmptyAvailableAreas();
  testTowerSpansExactlyTwoAreas();
  testTowerStartsAtBoundaryBetweenTwoAreas();
  testTowerWithVaryingHeightAreas();
  testTowerBeyondAllAreasRight();
}
