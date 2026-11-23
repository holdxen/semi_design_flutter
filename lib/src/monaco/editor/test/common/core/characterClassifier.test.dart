// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/characterClassifier.test.ts
// Translated 1:1. The mocha case becomes a Dart function carrying the exact
// `strictEqual` assertions.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here (the outer runner performs that check).
// ---------------------------------------------------------------------------

import '../../../../base/common/charCode.dart' show CharCode;
import '../../../common/core/characterClassifier.dart'
    show CharacterClassifier;

/// 1:1: `test('works')`
void testWorks() {
  final CharacterClassifier<int> classifier = CharacterClassifier<int>(0);

  assert(classifier.get(-1) == 0);
  assert(classifier.get(0) == 0);
  assert(classifier.get(CharCode.a) == 0);
  assert(classifier.get(CharCode.b) == 0);
  assert(classifier.get(CharCode.z) == 0);
  assert(classifier.get(255) == 0);
  assert(classifier.get(1000) == 0);
  assert(classifier.get(2000) == 0);

  classifier.set(CharCode.a, 1);
  classifier.set(CharCode.z, 2);
  classifier.set(1000, 3);

  assert(classifier.get(-1) == 0);
  assert(classifier.get(0) == 0);
  assert(classifier.get(CharCode.a) == 1);
  assert(classifier.get(CharCode.b) == 0);
  assert(classifier.get(CharCode.z) == 2);
  assert(classifier.get(255) == 0);
  assert(classifier.get(1000) == 3);
  assert(classifier.get(2000) == 0);
}

void runAll() {
  testWorks();
}
