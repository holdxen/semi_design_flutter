// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/browser/view/minimap/minimapDirtyRows.test.ts
// Translated 1:1. The mocha case becomes a Dart function carrying the exact
// `deepStrictEqual` assertion over an array of `IDirtyRows | null`.
// `IDirtyRows` has no `==` override in the port, so equality is compared by
// fields to reproduce `deepStrictEqual` semantics.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../browser/viewParts/minimap/minimapDirtyRows.dart'
    show IDirtyRows, RowSignatures;

/// 1:1: `type Drawing = [y, height, signature, uniform]`
class Drawing {
  final num y;
  final num height;
  final String signature;
  final bool uniform;
  const Drawing(this.y, this.height, this.signature, this.uniform);
}

/// 1:1: `function rows(drawings, height = 10)`
RowSignatures _rows(List<Drawing> drawings, [int height = 10]) {
  final RowSignatures result = RowSignatures(height);
  for (final Drawing d in drawings) {
    result.add(d.y, d.height, d.signature, d.uniform);
  }
  return result;
}

bool _dirtyEq(IDirtyRows? a, IDirtyRows? b) {
  if (a == null || b == null) return a == null && b == null;
  return a.start == b.start && a.end == b.end;
}

String _dirtyStr(IDirtyRows? r) => r == null ? 'null' : '{start: ${r.start}, end: ${r.end}}';

/// 1:1: `test('finds the band of rows drawn differently')`
void testFindsBandOfRowsDrawnDifferently() {
  const Drawing cursor = Drawing(2, 2, 'red', true);
  const Drawing label = Drawing(5, 3, 'Header', false);

  final List<IDirtyRows?> actual = <IDirtyRows?>[
    RowSignatures.diff(null, _rows(<Drawing>[])),
    RowSignatures.diff(_rows(<Drawing>[]), _rows(<Drawing>[])),
    RowSignatures.diff(_rows(<Drawing>[cursor, label]), _rows(<Drawing>[cursor, label])),
    RowSignatures.diff(_rows(<Drawing>[cursor]), _rows(<Drawing>[Drawing(3, 2, 'red', true)])),
    RowSignatures.diff(_rows(<Drawing>[cursor]), _rows(<Drawing>[Drawing(2, 2, 'blue', true)])),
    RowSignatures.diff(_rows(<Drawing>[cursor]), _rows(<Drawing>[Drawing(2, 2.5, 'red', true)])),
    RowSignatures.diff(_rows(<Drawing>[Drawing(1, 4, 'red', true)]),
        _rows(<Drawing>[Drawing(1, 2, 'red', true), Drawing(3, 2, 'red', true)])),
    RowSignatures.diff(_rows(<Drawing>[label]), _rows(<Drawing>[Drawing(6, 3, 'Header', false)])),
    RowSignatures.diff(_rows(<Drawing>[cursor, Drawing(3, 3, 'Header', false)]),
        _rows(<Drawing>[Drawing(3, 3, 'Header', false), cursor])),
    RowSignatures.diff(
        _rows(<Drawing>[Drawing(0, 1, 'a', true), Drawing(9, 1, 'a', true)]),
        _rows(<Drawing>[Drawing(0, 1, 'b', true), Drawing(9, 1, 'b', true)])),
    RowSignatures.diff(_rows(<Drawing>[], 10), _rows(<Drawing>[], 8)),
  ];
  final List<IDirtyRows?> expected = <IDirtyRows?>[
    IDirtyRows(0, 10),
    null,
    null,
    IDirtyRows(2, 5),
    IDirtyRows(2, 4),
    IDirtyRows(4, 5),
    null,
    IDirtyRows(5, 9),
    IDirtyRows(3, 4),
    IDirtyRows(0, 10),
    IDirtyRows(0, 8),
  ];
  assert(actual.length == expected.length);
  for (int i = 0; i < expected.length; i++) {
    assert(_dirtyEq(actual[i], expected[i]),
        'index $i: ${_dirtyStr(actual[i])} != ${_dirtyStr(expected[i])}');
  }
}

void runAll() {
  testFindsBandOfRowsDrawnDifferently();
}
