// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/model/bracketPairColorizer/smallImmutableSet.test.ts
// Translated 1:1. The two mocha cases become Dart functions carrying the exact
// `strictEqual` assertions.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here (the outer runner performs that check).
// ---------------------------------------------------------------------------

import '../../../../common/model/bracketPairsTextModelPart/bracketPairsTree/smallImmutableSet.dart'
    show DenseKeyProvider, SmallImmutableSet;

/// 1:1: `test('Basic')`
void testBasic() {
  final DenseKeyProvider<String> keyProvider = DenseKeyProvider<String>();

  final SmallImmutableSet<String> empty = SmallImmutableSet.getEmpty<String>();
  final SmallImmutableSet<String> items1 = empty.add('item1', keyProvider);
  final SmallImmutableSet<String> items12 = items1.add('item2', keyProvider);
  final SmallImmutableSet<String> items2 = empty.add('item2', keyProvider);
  final SmallImmutableSet<String> items21 = items2.add('item1', keyProvider);

  final SmallImmutableSet<String> items3 = empty.add('item3', keyProvider);

  assert(items12.intersects(items1) == true);
  assert(items12.has('item1', keyProvider) == true);

  assert(items12.intersects(items3) == false);
  assert(items12.has('item3', keyProvider) == false);

  assert(items21.equals(items12) == true);
  assert(items21.equals(items2) == false);
}

/// 1:1: `test('Many Elements')`
void testManyElements() {
  final DenseKeyProvider<String> keyProvider = DenseKeyProvider<String>();

  SmallImmutableSet<String> set = SmallImmutableSet.getEmpty<String>();

  for (int i = 0; i < 100; i++) {
    keyProvider.getKey('item$i');
    if (i % 2 == 0) {
      set = set.add('item$i', keyProvider);
    }
  }

  for (int i = 0; i < 100; i++) {
    assert(set.has('item$i', keyProvider) == (i % 2 == 0));
  }
}

void runAll() {
  testBasic();
  testManyElements();
}
