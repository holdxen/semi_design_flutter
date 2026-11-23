// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/positionOffsetTransformer.test.ts
// Translated 1:1. The two mocha cases become Dart functions carrying the exact
// `deepStrictEqual` / `strictEqual` assertions.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here (the outer runner performs that check).
// ---------------------------------------------------------------------------

import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import '../../../common/core/text/positionToOffset.dart'
    show PositionOffsetTransformer;

const String _str = '123456\nabcdef\nghijkl\nmnopqr';

/// 1:1: `test('getPosition')`
void testGetPosition() {
  final PositionOffsetTransformer t = PositionOffsetTransformer(_str);
  final List<String> expected = <String>[
    '(1,1)', '(1,2)', '(1,3)', '(1,4)', '(1,5)', '(1,6)', '(1,7)',
    '(2,1)', '(2,2)', '(2,3)', '(2,4)', '(2,5)', '(2,6)', '(2,7)',
    '(3,1)', '(3,2)', '(3,3)', '(3,4)', '(3,5)', '(3,6)', '(3,7)',
    '(4,1)', '(4,2)', '(4,3)', '(4,4)', '(4,5)', '(4,6)', '(4,7)',
    '(4,8)',
  ];
  final List<String> actual = OffsetRange(0, _str.length + 2)
      .map<String>((int i) => t.getPosition(i).toString());
  assert(actual.length == expected.length);
  for (int i = 0; i < expected.length; i++) {
    assert(actual[i] == expected[i]);
  }
}

/// 1:1: `test('getOffset')`
void testGetOffset() {
  final PositionOffsetTransformer t = PositionOffsetTransformer(_str);
  for (int i = 0; i < _str.length + 1; i++) {
    assert(t.getOffset(t.getPosition(i)) == i);
  }
}

void runAll() {
  testGetPosition();
  testGetOffset();
}
