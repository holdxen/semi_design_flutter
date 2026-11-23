// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/cursorColumns.test.ts
// Translated 1:1. The mocha suite's active cases become Dart functions:
//   - visibleColumnFromColumn / toStatusbarColumn / columnFromVisibleColumn:
//     local helper functions (tvc/tsc/cfvc) with all original assertions.
//   - nextRenderTabStop / nextIndentTabStop / prevRenderTabStop /
//     prevIndentTabStop: table-driven loops, expanded to two helper calls each.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../common/core/cursorColumns.dart' show CursorColumns;

void tvc(String text, int tabSize, int column, int expected) {
  assert(CursorColumns.visibleColumnFromColumn(text, column, tabSize) == expected);
}

void testVisibleColumnFromColumn() {
  tvc('\t\tvar x = 3;', 4, 1, 0);
  tvc('\t\tvar x = 3;', 4, 2, 4);
  tvc('\t\tvar x = 3;', 4, 3, 8);
  tvc('\t\tvar x = 3;', 4, 4, 9);
  tvc('\t\tvar x = 3;', 4, 5, 10);
  tvc('\t\tvar x = 3;', 4, 6, 11);
  tvc('\t\tvar x = 3;', 4, 7, 12);
  tvc('\t\tvar x = 3;', 4, 8, 13);
  tvc('\t\tvar x = 3;', 4, 9, 14);
  tvc('\t\tvar x = 3;', 4, 10, 15);
  tvc('\t\tvar x = 3;', 4, 11, 16);
  tvc('\t\tvar x = 3;', 4, 12, 17);
  tvc('\t\tvar x = 3;', 4, 13, 18);

  tvc('\t \tvar x = 3;', 4, 1, 0);
  tvc('\t \tvar x = 3;', 4, 2, 4);
  tvc('\t \tvar x = 3;', 4, 3, 5);
  tvc('\t \tvar x = 3;', 4, 4, 8);
  tvc('\t \tvar x = 3;', 4, 5, 9);
  tvc('\t \tvar x = 3;', 4, 6, 10);
  tvc('\t \tvar x = 3;', 4, 7, 11);
  tvc('\t \tvar x = 3;', 4, 8, 12);
  tvc('\t \tvar x = 3;', 4, 9, 13);
  tvc('\t \tvar x = 3;', 4, 10, 14);
  tvc('\t \tvar x = 3;', 4, 11, 15);
  tvc('\t \tvar x = 3;', 4, 12, 16);
  tvc('\t \tvar x = 3;', 4, 13, 17);
  tvc('\t \tvar x = 3;', 4, 14, 18);

  tvc('\t  \tx\t', 4, -1, 0);
  tvc('\t  \tx\t', 4, 0, 0);
  tvc('\t  \tx\t', 4, 1, 0);
  tvc('\t  \tx\t', 4, 2, 4);
  tvc('\t  \tx\t', 4, 3, 5);
  tvc('\t  \tx\t', 4, 4, 6);
  tvc('\t  \tx\t', 4, 5, 8);
  tvc('\t  \tx\t', 4, 6, 9);
  tvc('\t  \tx\t', 4, 7, 12);
  tvc('\t  \tx\t', 4, 8, 12);
  tvc('\t  \tx\t', 4, 9, 12);

  tvc('baz', 4, 1, 0);
  tvc('baz', 4, 2, 1);
  tvc('baz', 4, 3, 2);
  tvc('baz', 4, 4, 3);

  tvc('📚az', 4, 1, 0);
  tvc('📚az', 4, 2, 1);
  tvc('📚az', 4, 3, 2);
  tvc('📚az', 4, 4, 3);
  tvc('📚az', 4, 5, 4);
}

void tsc(String text, int tabSize, int column, int expected) {
  assert(CursorColumns.toStatusbarColumn(text, column, tabSize) == expected,
      "<<t('$text', $tabSize, $column, $expected)>>");
}

void testToStatusbarColumn() {
  tsc('    spaces', 4, 1, 1);
  tsc('    spaces', 4, 2, 2);
  tsc('    spaces', 4, 3, 3);
  tsc('    spaces', 4, 4, 4);
  tsc('    spaces', 4, 5, 5);
  tsc('    spaces', 4, 6, 6);
  tsc('    spaces', 4, 7, 7);
  tsc('    spaces', 4, 8, 8);
  tsc('    spaces', 4, 9, 9);
  tsc('    spaces', 4, 10, 10);
  tsc('    spaces', 4, 11, 11);

  tsc('\ttab', 4, 1, 1);
  tsc('\ttab', 4, 2, 5);
  tsc('\ttab', 4, 3, 6);
  tsc('\ttab', 4, 4, 7);
  tsc('\ttab', 4, 5, 8);

  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 1, 1);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 2, 2);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 3, 2);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 4, 3);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 5, 3);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 6, 4);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 7, 4);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 8, 5);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 9, 5);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 10, 6);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 11, 6);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 12, 7);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 13, 7);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 14, 8);
  tsc('𐌀𐌁𐌂𐌃𐌄𐌅𐌆', 4, 15, 8);

  tsc('🎈🎈🎈🎈', 4, 1, 1);
  tsc('🎈🎈🎈🎈', 4, 2, 2);
  tsc('🎈🎈🎈🎈', 4, 3, 2);
  tsc('🎈🎈🎈🎈', 4, 4, 3);
  tsc('🎈🎈🎈🎈', 4, 5, 3);
  tsc('🎈🎈🎈🎈', 4, 6, 4);
  tsc('🎈🎈🎈🎈', 4, 7, 4);
  tsc('🎈🎈🎈🎈', 4, 8, 5);
  tsc('🎈🎈🎈🎈', 4, 9, 5);

  tsc('何何何何', 4, 1, 1);
  tsc('何何何何', 4, 2, 2);
  tsc('何何何何', 4, 3, 3);
  tsc('何何何何', 4, 4, 4);
}

void cfvc(String text, int tabSize, int visibleColumn, int expected) {
  assert(CursorColumns.columnFromVisibleColumn(text, visibleColumn, tabSize) == expected);
}

void testColumnFromVisibleColumn() {
  // testColumnFromVisibleColumn('\t\tvar x = 3;', 4, 0, 1); // commented out in source
  cfvc('\t\tvar x = 3;', 4, 1, 1);
  cfvc('\t\tvar x = 3;', 4, 2, 1);
  cfvc('\t\tvar x = 3;', 4, 3, 2);
  cfvc('\t\tvar x = 3;', 4, 4, 2);
  cfvc('\t\tvar x = 3;', 4, 5, 2);
  cfvc('\t\tvar x = 3;', 4, 6, 2);
  cfvc('\t\tvar x = 3;', 4, 7, 3);
  cfvc('\t\tvar x = 3;', 4, 8, 3);
  cfvc('\t\tvar x = 3;', 4, 9, 4);
  cfvc('\t\tvar x = 3;', 4, 10, 5);
  cfvc('\t\tvar x = 3;', 4, 11, 6);
  cfvc('\t\tvar x = 3;', 4, 12, 7);
  cfvc('\t\tvar x = 3;', 4, 13, 8);
  cfvc('\t\tvar x = 3;', 4, 14, 9);
  cfvc('\t\tvar x = 3;', 4, 15, 10);
  cfvc('\t\tvar x = 3;', 4, 16, 11);
  cfvc('\t\tvar x = 3;', 4, 17, 12);
  cfvc('\t\tvar x = 3;', 4, 18, 13);

  cfvc('\t \tvar x = 3;', 4, 0, 1);
  cfvc('\t \tvar x = 3;', 4, 1, 1);
  cfvc('\t \tvar x = 3;', 4, 2, 1);
  cfvc('\t \tvar x = 3;', 4, 3, 2);
  cfvc('\t \tvar x = 3;', 4, 4, 2);
  cfvc('\t \tvar x = 3;', 4, 5, 3);
  cfvc('\t \tvar x = 3;', 4, 6, 3);
  cfvc('\t \tvar x = 3;', 4, 7, 4);
  cfvc('\t \tvar x = 3;', 4, 8, 4);
  cfvc('\t \tvar x = 3;', 4, 9, 5);
  cfvc('\t \tvar x = 3;', 4, 10, 6);
  cfvc('\t \tvar x = 3;', 4, 11, 7);
  cfvc('\t \tvar x = 3;', 4, 12, 8);
  cfvc('\t \tvar x = 3;', 4, 13, 9);
  cfvc('\t \tvar x = 3;', 4, 14, 10);
  cfvc('\t \tvar x = 3;', 4, 15, 11);
  cfvc('\t \tvar x = 3;', 4, 16, 12);
  cfvc('\t \tvar x = 3;', 4, 17, 13);
  cfvc('\t \tvar x = 3;', 4, 18, 14);

  cfvc('\t  \tx\t', 4, -2, 1);
  cfvc('\t  \tx\t', 4, -1, 1);
  cfvc('\t  \tx\t', 4, 0, 1);
  cfvc('\t  \tx\t', 4, 1, 1);
  cfvc('\t  \tx\t', 4, 2, 1);
  cfvc('\t  \tx\t', 4, 3, 2);
  cfvc('\t  \tx\t', 4, 4, 2);
  cfvc('\t  \tx\t', 4, 5, 3);
  cfvc('\t  \tx\t', 4, 6, 4);
  cfvc('\t  \tx\t', 4, 7, 4);
  cfvc('\t  \tx\t', 4, 8, 5);
  cfvc('\t  \tx\t', 4, 9, 6);
  cfvc('\t  \tx\t', 4, 10, 6);
  cfvc('\t  \tx\t', 4, 11, 7);
  cfvc('\t  \tx\t', 4, 12, 7);
  cfvc('\t  \tx\t', 4, 13, 7);
  cfvc('\t  \tx\t', 4, 14, 7);

  cfvc('baz', 4, 0, 1);
  cfvc('baz', 4, 1, 2);
  cfvc('baz', 4, 2, 3);
  cfvc('baz', 4, 3, 4);

  cfvc('📚az', 4, 0, 1);
  cfvc('📚az', 4, 1, 1);
  cfvc('📚az', 4, 2, 3);
  cfvc('📚az', 4, 3, 4);
  cfvc('📚az', 4, 4, 5);
}

/// 1:1: table-driven loop over [nextRenderTabStop, nextIndentTabStop].
void testNextTabStops() {
  for (final int Function(int, int) fn in [
    CursorColumns.nextRenderTabStop,
    CursorColumns.nextIndentTabStop,
  ]) {
    assert(fn(0, 4) == 4);
    assert(fn(1, 4) == 4);
    assert(fn(2, 4) == 4);
    assert(fn(3, 4) == 4);
    assert(fn(4, 4) == 8);
    assert(fn(5, 4) == 8);
    assert(fn(6, 4) == 8);
    assert(fn(7, 4) == 8);
    assert(fn(8, 4) == 12);

    assert(fn(0, 2) == 2);
    assert(fn(1, 2) == 2);
    assert(fn(2, 2) == 4);
    assert(fn(3, 2) == 4);
    assert(fn(4, 2) == 6);
    assert(fn(5, 2) == 6);
    assert(fn(6, 2) == 8);
    assert(fn(7, 2) == 8);
    assert(fn(8, 2) == 10);

    assert(fn(0, 1) == 1);
    assert(fn(1, 1) == 2);
    assert(fn(2, 1) == 3);
    assert(fn(3, 1) == 4);
    assert(fn(4, 1) == 5);
    assert(fn(5, 1) == 6);
    assert(fn(6, 1) == 7);
    assert(fn(7, 1) == 8);
    assert(fn(8, 1) == 9);
  }
}

/// 1:1: table-driven loop over [prevRenderTabStop, prevIndentTabStop].
void testPrevTabStops() {
  for (final int Function(int, int) fn in [
    CursorColumns.prevRenderTabStop,
    CursorColumns.prevIndentTabStop,
  ]) {
    assert(fn(0, 4) == 0);
    assert(fn(1, 4) == 0);
    assert(fn(2, 4) == 0);
    assert(fn(3, 4) == 0);
    assert(fn(4, 4) == 0);
    assert(fn(5, 4) == 4);
    assert(fn(6, 4) == 4);
    assert(fn(7, 4) == 4);
    assert(fn(8, 4) == 4);
    assert(fn(9, 4) == 8);

    assert(fn(0, 2) == 0);
    assert(fn(1, 2) == 0);
    assert(fn(2, 2) == 0);
    assert(fn(3, 2) == 2);
    assert(fn(4, 2) == 2);
    assert(fn(5, 2) == 4);
    assert(fn(6, 2) == 4);
    assert(fn(7, 2) == 6);
    assert(fn(8, 2) == 6);
    assert(fn(9, 2) == 8);

    assert(fn(0, 1) == 0);
    assert(fn(1, 1) == 0);
    assert(fn(2, 1) == 1);
    assert(fn(3, 1) == 2);
    assert(fn(4, 1) == 3);
    assert(fn(5, 1) == 4);
    assert(fn(6, 1) == 5);
    assert(fn(7, 1) == 6);
    assert(fn(8, 1) == 7);
    assert(fn(9, 1) == 8);
  }
}

void runAll() {
  testVisibleColumnFromColumn();
  testToStatusbarColumn();
  testColumnFromVisibleColumn();
  testNextTabStops();
  testPrevTabStops();
}
