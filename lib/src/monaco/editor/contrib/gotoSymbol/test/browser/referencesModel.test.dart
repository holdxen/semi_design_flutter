// 1:1 port of
// vscode/src/vs/editor/contrib/gotoSymbol/test/browser/referencesModel.test.ts
// (42 lines).
//
// The official mocha suite becomes Dart functions carrying the same
// assertions; `runAll()` executes them in source order. `assert.strictEqual`
// becomes [StateError] on mismatch (repo convention for mirrored tests), and
// the suite-level `ensureNoDisposablesAreLeakedInTestSuite()` hook is omitted.
import '../../../../../base/common/uri.dart' show URI;
import '../../../../common/core/position.dart' show Position;
import '../../../../common/core/range.dart' show Range;
import '../../browser/referencesModel.dart'
    show ReferenceLocation, ReferencesModel;

void _assertEquals(Object? actual, Object? expected, String message) {
  if (actual != expected) {
    throw StateError('$message: expected <$expected>, got <$actual>');
  }
}

void runAll() {
  // suite('references')
  final ReferencesModel model = ReferencesModel(<ReferenceLocation>[
    ReferenceLocation(URI.file('/out/obj/can'), Range(1, 1, 1, 1)),
    ReferenceLocation(URI.file('/out/obj/can2'), Range(1, 1, 1, 1)),
    ReferenceLocation(URI.file('/src/can'), Range(1, 1, 1, 1)),
  ], 'FOO');

  // test('nearestReference')
  _assertEquals(
      model.nearestReference(URI.file('/src/can'), Position(1, 1))!.uri.path,
      '/src/can',
      'exact match');
  _assertEquals(
      model
          .nearestReference(URI.file('/src/someOtherFileInSrc'), Position(1, 1))!
          .uri
          .path,
      '/src/can',
      'nearest in /src');
  _assertEquals(
      model
          .nearestReference(URI.file('/out/someOtherFile'), Position(1, 1))!
          .uri
          .path,
      '/out/obj/can',
      'nearest in /out');
  _assertEquals(
      model.nearestReference(URI.file('/out/obj/can2222'), Position(1, 1))!.uri.path,
      '/out/obj/can2',
      'nearest with common prefix');
}
