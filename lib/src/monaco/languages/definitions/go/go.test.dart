// Generated 1:1 from languages/definitions/go/go.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('go')
void runLanguagesDefinitionsGoGoTestCases() {
  TR.testTokenization('go', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '/* Block comment. */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.go'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// Inline comment.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'import {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.import.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  "io"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'type name struct {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.type.go'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.go'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.struct.go'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  firstname string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'keyword.string.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  lastname string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.string.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'func testTypes() {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.func.go'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.go'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a int;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.int.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  b uint;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.uint.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  c uintptr;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.uintptr.go'),
          TR.IRelaxedToken(11, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  d string;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.string.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  e byte;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.byte.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  f rune;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.rune.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  g uint8;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.uint8.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  h uint16;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.uint16.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  i uint32;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.uint32.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  j uint64;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.uint64.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  k int8;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.int8.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  l int16;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.int16.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  m int32;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.int32.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  n int64;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.int64.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  o float32;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.float32.go'),
          TR.IRelaxedToken(11, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  p float64;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.float64.go'),
          TR.IRelaxedToken(11, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  q complex64;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.complex64.go'),
          TR.IRelaxedToken(13, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  r complex128;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'keyword.complex128.go'),
          TR.IRelaxedToken(14, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'func testOperators() {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.func.go'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.go'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  var a;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.var.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  var b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.var.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a + b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a - b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a * b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a / b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a % b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a & b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a | b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a ^ b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a << b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a >> b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a &^ b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a += b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a -= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a *= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a /= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a %= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a &= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a |= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a ^= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a <<= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a >>= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a &^= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a && b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a || b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a <- b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a++;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  b--;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a == b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a < b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.angle.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a > b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.angle.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a = b; ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
          TR.IRelaxedToken(8, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  !a;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.go'),
          TR.IRelaxedToken(3, 'identifier.go'),
          TR.IRelaxedToken(4, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a != b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a <= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a >= b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a := b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a...;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  (a)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(3, 'identifier.go'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  [a]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.square.go'),
          TR.IRelaxedToken(3, 'identifier.go'),
          TR.IRelaxedToken(4, 'delimiter.square.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a.b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, 'delimiter.go'),
          TR.IRelaxedToken(4, 'identifier.go'),
          TR.IRelaxedToken(5, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a, b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, 'delimiter.go'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.go'),
          TR.IRelaxedToken(6, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  a : b; ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.go'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
          TR.IRelaxedToken(8, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'func keywords() {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.func.go'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.go'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  var a;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.var.go'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  break;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.break.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  switch(a) {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.switch.go'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(9, 'identifier.go'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    case 1:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.case.go'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'number.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '      fallthrough;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'keyword.fallthrough.go'),
          TR.IRelaxedToken(17, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    default:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.default.go'),
          TR.IRelaxedToken(11, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '      break;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'keyword.break.go'),
          TR.IRelaxedToken(11, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  chan;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.chan.go'),
          TR.IRelaxedToken(6, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  const;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.const.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  continue;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.continue.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  defer;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.defer.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  if (a)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.if.go'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(6, 'identifier.go'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    return;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.return.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  else',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.else.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    return;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.return.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   for (i = 0; i < 10; i++);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.for.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(8, 'identifier.go'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.go'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'number.go'),
          TR.IRelaxedToken(13, 'delimiter.go'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.go'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.angle.go'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'number.go'),
          TR.IRelaxedToken(21, 'delimiter.go'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'identifier.go'),
          TR.IRelaxedToken(24, 'delimiter.go'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.go'),
          TR.IRelaxedToken(27, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   go;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.go.go'),
          TR.IRelaxedToken(5, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   goto;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.goto.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   interface;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.interface.go'),
          TR.IRelaxedToken(12, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   map;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.map.go'),
          TR.IRelaxedToken(6, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   package;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.package.go'),
          TR.IRelaxedToken(10, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   range;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.range.go'),
          TR.IRelaxedToken(8, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   return;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.return.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   select;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.select.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   struct;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.struct.go'),
          TR.IRelaxedToken(9, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   type;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.type.go'),
          TR.IRelaxedToken(7, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   var x = true;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.var.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.go'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.true.go'),
          TR.IRelaxedToken(15, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   var y = false;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.var.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.go'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.false.go'),
          TR.IRelaxedToken(16, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   var z = nil;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.var.go'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.go'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.go'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.nil.go'),
          TR.IRelaxedToken(14, 'delimiter.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.go'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`Hello world() ""`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.go'),
        ],
      ),
    ],
  ]);
}

