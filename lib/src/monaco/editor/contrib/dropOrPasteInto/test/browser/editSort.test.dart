// 1:1 port of
// vscode/src/vs/editor/contrib/dropOrPasteInto/test/browser/editSort.test.ts
// (69 lines).
//
// Official mocha suite -> Dart functions with the same assertions; `runAll()`
// executes them in source order. `assert.deepStrictEqual` -> [StateError] on
// mismatch, per the repo's mirrored-test convention.
import '../../../../../base/common/hierarchicalKind.dart' show HierarchicalKind;
import '../../browser/edit.dart'
    show DropYieldToForEdit, IYieldToEdit, sortEditsByYieldTo;

/// `DocumentDropEdit` test carrier (the production interface is erased).
class _TestEdit implements IYieldToEdit {
  _TestEdit(this.kind, {this.handledMimeType, this.yieldTo});

  @override
  final HierarchicalKind? kind;

  @override
  final String? handledMimeType;

  @override
  final List<DropYieldToForEdit>? yieldTo;

  final String title = '';
  final String insertText = '';
}

_TestEdit _createTestEdit(String kind,
        {String? handledMimeType, List<DropYieldToForEdit>? yieldTo}) =>
    _TestEdit(HierarchicalKind(kind),
        handledMimeType: handledMimeType, yieldTo: yieldTo);

void _assertDeepEquals(Object? actual, Object? expected, String message) {
  bool same(Object? a, Object? b) {
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!same(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  if (!same(actual, expected)) {
    throw StateError('$message: expected <$expected>, got <$actual>');
  }
}

List<String?> _kindValues(List<_TestEdit> edits) =>
    sortEditsByYieldTo<_TestEdit>(edits).map((e) => e.kind?.value).toList();

void runAll() {
  // suite('sortEditsByYieldTo')

  // test('Should noop for empty edits')
  _assertDeepEquals(_kindValues(<_TestEdit>[]), <String?>[], 'empty edits');

  // test('Yielded to edit should get sorted after target')
  _assertDeepEquals(
      _kindValues(<_TestEdit>[
        _createTestEdit('a',
            yieldTo: <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('b')),
            ]),
        _createTestEdit('b'),
      ]),
      <String?>['b', 'a'],
      'single yield');

  // test('Should handle chain of yield to') — first arrangement
  _assertDeepEquals(
      _kindValues(<_TestEdit>[
        _createTestEdit('c',
            yieldTo: <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('a')),
            ]),
        _createTestEdit('a',
            yieldTo: <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('b')),
            ]),
        _createTestEdit('b'),
      ]),
      <String?>['b', 'a', 'c'],
      'chain #1');

  // test('Should handle chain of yield to') — second arrangement
  _assertDeepEquals(
      _kindValues(<_TestEdit>[
        _createTestEdit('a',
            yieldTo: <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('b')),
            ]),
        _createTestEdit('c',
            yieldTo: <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('a')),
            ]),
        _createTestEdit('b'),
      ]),
      <String?>['b', 'a', 'c'],
      'chain #2');

  // test(`Should not reorder when yield to isn't used`)
  _assertDeepEquals(
      _kindValues(<_TestEdit>[
        _createTestEdit('c',
            yieldTo: <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('x')),
            ]),
        _createTestEdit('a',
            yieldTo: <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('y')),
            ]),
        _createTestEdit('b'),
      ]),
      <String?>['c', 'a', 'b'],
      'no yield used');
}
