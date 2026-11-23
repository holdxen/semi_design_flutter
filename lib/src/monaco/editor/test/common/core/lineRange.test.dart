// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/lineRange.test.ts
// Translated 1:1. The four mocha cases become Dart functions carrying the exact
// `deepStrictEqual` assertions.
// ---------------------------------------------------------------------------

import '../../../common/core/ranges/lineRange.dart'
    show LineRange, LineRangeSet;

/// 1:1: `suite('LineRange') / test('contains')`
void testContains() {
  final LineRange r = LineRange(2, 3);
  assert(r.contains(1) == false);
  assert(r.contains(2) == true);
  assert(r.contains(3) == false);
  assert(r.contains(4) == false);
}

/// 1:1: `suite('LineRangeSet') / test('addRange')`
void testAddRange() {
  final LineRangeSet set = LineRangeSet();
  set.addRange(LineRange(2, 3));
  set.addRange(LineRange(3, 4));
  set.addRange(LineRange(10, 20));
  assert(set.toString() == '[2,4), [10,20)');

  set.addRange(LineRange(3, 21));
  assert(set.toString() == '[2,21)');
}

/// 1:1: `test('getUnion')`
void testGetUnion() {
  final LineRangeSet set1 = LineRangeSet(<LineRange>[
    LineRange(2, 3),
    LineRange(5, 7),
    LineRange(10, 20),
  ]);
  final LineRangeSet set2 = LineRangeSet(<LineRange>[
    LineRange(3, 4),
    LineRange(6, 8),
    LineRange(9, 11),
  ]);
  final LineRangeSet union = set1.getUnion(set2);
  assert(union.toString() == '[2,4), [5,8), [9,20)');
}

/// 1:1: `test('intersects')`
void testIntersects() {
  final LineRangeSet set1 = LineRangeSet(<LineRange>[
    LineRange(2, 3),
    LineRange(5, 7),
    LineRange(10, 20),
  ]);
  assert(set1.intersects(LineRange(1, 2)) == false);
  assert(set1.intersects(LineRange(1, 3)) == true);
  assert(set1.intersects(LineRange(3, 5)) == false);
}

void runAll() {
  testContains();
  testAddRange();
  testGetUnion();
  testIntersects();
}
