// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/browser/gpu/bufferDirtyTracker.test.ts
// Translated 1:1. The two mocha cases become Dart functions carrying the exact
// `strictEqual` assertions.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here (the outer runner performs that check).
// ---------------------------------------------------------------------------

import '../../../browser/gpu/bufferDirtyTracker.dart'
    show BufferDirtyTracker;

/// 1:1: `assertState` helper — reads state via the reader getters.
void _assertState(BufferDirtyTracker bdt, int? dataOffset, int? dirtySize) {
  assert(bdt.dataOffset == dataOffset);
  assert(bdt.dirtySize == dirtySize);
  assert(bdt.isDirty == (dataOffset != null));
}

/// 1:1: `test('flag(index)')`
void testFlagIndex() {
  final BufferDirtyTracker bdt = BufferDirtyTracker();
  assert(bdt.flag(0) == 0);
  _assertState(bdt, 0, 1);
  assert(bdt.flag(31) == 31);
  _assertState(bdt, 0, 32);
  bdt.clear();
  _assertState(bdt, null, null);
  assert(bdt.flag(10) == 10);
  _assertState(bdt, 10, 1);
  assert(bdt.flag(15) == 15);
  _assertState(bdt, 10, 6);
}

/// 1:1: `test('flag(index, length)')`
void testFlagIndexLength() {
  final BufferDirtyTracker bdt = BufferDirtyTracker();
  bdt.flag(0, 32);
  _assertState(bdt, 0, 32);
  bdt.clear();
  _assertState(bdt, null, null);
  bdt.flag(10, 6);
  _assertState(bdt, 10, 6);
}

void runAll() {
  testFlagIndex();
  testFlagIndexLength();
}
