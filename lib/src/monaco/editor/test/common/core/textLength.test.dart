// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/textLength.test.ts
// Translated 1:1. The two mocha cases become Dart functions carrying the exact
// `deepStrictEqual` assertions (via Dart `assert` on a comparable key).
// ---------------------------------------------------------------------------

import '../../../common/core/text/textLength.dart' show TextLength;

/// 1:1: comparable key for `TextLength` (id + lineCount + columnCount).
String _key(TextLength t) => '${t.lineCount},${t.columnCount}';

/// 1:1: `test('ofText counts UTF-16 code units')`
void testOfTextCountsUtf16CodeUnits() {
  final List<TextLength> actual = <TextLength>[
    TextLength.ofText(''),
    TextLength.ofText('abc'),
    TextLength.ofText('😀'),
    TextLength.ofText('a😀𝄞b'),
    TextLength.ofText('e\u0301'),
    TextLength.ofText('\ud83d'),
    TextLength.ofText('\ude00'),
  ];
  final List<TextLength> expected = <TextLength>[
    TextLength(0, 0),
    TextLength(0, 3),
    TextLength(0, 2),
    TextLength(0, 6),
    TextLength(0, 2),
    TextLength(0, 1),
    TextLength(0, 1),
  ];
  for (int i = 0; i < actual.length; i++) {
    assert(_key(actual[i]) == _key(expected[i]),
        'ofText case $i: ${_key(actual[i])} != ${_key(expected[i])}');
  }
}

/// 1:1: `test('ofText counts UTF-16 columns after the last newline')`
void testOfTextCountsColumnsAfterLastNewline() {
  final List<TextLength> actual = <TextLength>[
    TextLength.ofText('😀\nx'),
    TextLength.ofText('x\n😀𝄞'),
    TextLength.ofText('😀\n𝄞\n'),
  ];
  final List<TextLength> expected = <TextLength>[
    TextLength(1, 1),
    TextLength(1, 4),
    TextLength(2, 0),
  ];
  for (int i = 0; i < actual.length; i++) {
    assert(_key(actual[i]) == _key(expected[i]),
        'newline case $i: ${_key(actual[i])} != ${_key(expected[i])}');
  }
}

void runAll() {
  testOfTextCountsUtf16CodeUnits();
  testOfTextCountsColumnsAfterLastNewline();
}
