// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/controller/cursorAtomicMoveOperations.test.ts
// Translated 1:1. The two mocha cases become Dart functions carrying the exact
// `deepStrictEqual` assertions over the test-case tables.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../common/cursor/cursorAtomicMoveOperations.dart'
    show AtomicTabMoveOperations, Direction;

void _assertListEquals(List<int> actual, List<int> expected, String label) {
  assert(actual.length == expected.length, '$label length');
  for (int i = 0; i < expected.length; i++) {
    assert(actual[i] == expected[i], '$label[$i]: ${actual[i]} != ${expected[i]}');
  }
}

/// 1:1: `test('Test whitespaceVisibleColumn')`
void testWhitespaceVisibleColumn() {
  final List<Map<String, Object>> testCases = <Map<String, Object>>[
    <String, Object>{
      'lineContent': '        ',
      'tabSize': 4,
      'prevPos': <int>[-1, 0, 0, 0, 0, 4, 4, 4, 4, -1],
      'prevCol': <int>[-1, 0, 0, 0, 0, 4, 4, 4, 4, -1],
      'visible': <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, -1],
    },
    <String, Object>{
      'lineContent': '  ',
      'tabSize': 4,
      'prevPos': <int>[-1, 0, 0, -1],
      'prevCol': <int>[-1, 0, 0, -1],
      'visible': <int>[0, 1, 2, -1],
    },
    <String, Object>{
      'lineContent': '\t',
      'tabSize': 4,
      'prevPos': <int>[-1, 0, -1],
      'prevCol': <int>[-1, 0, -1],
      'visible': <int>[0, 4, -1],
    },
    <String, Object>{
      'lineContent': '\t ',
      'tabSize': 4,
      'prevPos': <int>[-1, 0, 1, -1],
      'prevCol': <int>[-1, 0, 4, -1],
      'visible': <int>[0, 4, 5, -1],
    },
    <String, Object>{
      'lineContent': ' \t\t ',
      'tabSize': 4,
      'prevPos': <int>[-1, 0, 0, 2, 3, -1],
      'prevCol': <int>[-1, 0, 0, 4, 8, -1],
      'visible': <int>[0, 1, 4, 8, 9, -1],
    },
    <String, Object>{
      'lineContent': ' \tA',
      'tabSize': 4,
      'prevPos': <int>[-1, 0, 0, -1, -1],
      'prevCol': <int>[-1, 0, 0, -1, -1],
      'visible': <int>[0, 1, 4, -1, -1],
    },
    <String, Object>{
      'lineContent': 'A',
      'tabSize': 4,
      'prevPos': <int>[-1, -1, -1],
      'prevCol': <int>[-1, -1, -1],
      'visible': <int>[0, -1, -1],
    },
    <String, Object>{
      'lineContent': '',
      'tabSize': 4,
      'prevPos': <int>[-1, -1],
      'prevCol': <int>[-1, -1],
      'visible': <int>[0, -1],
    },
  ];

  for (final Map<String, Object> tc in testCases) {
    final String lineContent = tc['lineContent'] as String;
    final int tabSize = tc['tabSize'] as int;
    final List<int> prevPos = tc['prevPos'] as List<int>;
    final List<int> prevCol = tc['prevCol'] as List<int>;
    final List<int> visible = tc['visible'] as List<int>;
    final int maxPosition = visible.length;
    for (int position = 0; position < maxPosition; position++) {
      final List<int> actual = AtomicTabMoveOperations.whitespaceVisibleColumn(
          lineContent, position, tabSize);
      _assertListEquals(actual, <int>[
        prevPos[position],
        prevCol[position],
        visible[position],
      ], 'whitespaceVisibleColumn($position)');
    }
  }
}

/// 1:1: `test('Test atomicPosition')`
void testAtomicPosition() {
  final List<Map<String, Object>> testCases = <Map<String, Object>>[
    <String, Object>{
      'lineContent': '        ',
      'left': <int>[-1, 0, 0, 0, 0, 4, 4, 4, 4, -1],
      'right': <int>[4, 4, 4, 4, 8, 8, 8, 8, -1, -1],
      'nearest': <int>[0, 0, 0, 4, 4, 4, 4, 8, 8, -1],
    },
    <String, Object>{
      'lineContent': ' \t',
      'left': <int>[-1, 0, 0, -1],
      'right': <int>[2, 2, -1, -1],
      'nearest': <int>[0, 0, 2, -1],
    },
    <String, Object>{
      'lineContent': '\t ',
      'left': <int>[-1, 0, -1, -1],
      'right': <int>[1, -1, -1, -1],
      'nearest': <int>[0, 1, -1, -1],
    },
    <String, Object>{
      'lineContent': ' \t ',
      'left': <int>[-1, 0, 0, -1, -1],
      'right': <int>[2, 2, -1, -1, -1],
      'nearest': <int>[0, 0, 2, -1, -1],
    },
    <String, Object>{
      'lineContent': '        A',
      'left': <int>[-1, 0, 0, 0, 0, 4, 4, 4, 4, -1, -1],
      'right': <int>[4, 4, 4, 4, 8, 8, 8, 8, -1, -1, -1],
      'nearest': <int>[0, 0, 0, 4, 4, 4, 4, 8, 8, -1, -1],
    },
    <String, Object>{
      'lineContent': '      foo',
      'left': <int>[-1, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1],
      'right': <int>[4, 4, 4, 4, -1, -1, -1, -1, -1, -1, -1],
      'nearest': <int>[0, 0, 0, 4, 4, -1, -1, -1, -1, -1, -1],
    },
  ];

  for (final Map<String, Object> tc in testCases) {
    final String lineContent = tc['lineContent'] as String;
    for (final MapEntry<int, String> de in <int, String>{
      Direction.Left: 'left',
      Direction.Right: 'right',
      Direction.Nearest: 'nearest',
    }.entries) {
      final int direction = de.key;
      final List<int> expected = tc[de.value] as List<int>;
      final List<int> actual = List<int>.generate(
          expected.length,
          (int i) => AtomicTabMoveOperations.atomicPosition(
              lineContent, i, 4, direction));
      _assertListEquals(actual, expected, 'atomicPosition($direction)');
    }
  }
}

void runAll() {
  testWhitespaceVisibleColumn();
  testAtomicPosition();
}
