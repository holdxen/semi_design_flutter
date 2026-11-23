// Generated 1:1 from languages/definitions/typescript/typescript.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('typescript')
void runLanguagesDefinitionsTypescriptTypescriptTestCases() {
  TR.testTokenization('typescript', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = function() { };',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.ts'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(22, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    var    ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.ts'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(3, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo() { return 1; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.ts'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.ts'),
          TR.IRelaxedToken(16, 'delimiter.ts'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.bracket.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#foo;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(4, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#foo() { return 1; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.ts'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'number.ts'),
          TR.IRelaxedToken(17, 'delimiter.ts'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.bracket.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment /*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment /**',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.ts'),
          TR.IRelaxedToken(9, 'delimiter.ts'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.ts'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.ts'),
          TR.IRelaxedToken(32, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.ts'),
          TR.IRelaxedToken(8, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
      TR.ITestItem(
        'can actually span',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
      TR.ITestItem(
        'multiple lines */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.ts'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
      TR.ITestItem(
        'and end it */ var a = 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.ts'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'identifier.ts'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'delimiter.ts'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.ts'),
          TR.IRelaxedToken(23, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var a = \'a\';',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.ts'),
          TR.IRelaxedToken(11, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"use strict";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ts'),
          TR.IRelaxedToken(12, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'b = a + " \'cool\'  "',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping \\"quotes\\" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ts'),
          TR.IRelaxedToken(10, 'string.escape.ts'),
          TR.IRelaxedToken(12, 'string.ts'),
          TR.IRelaxedToken(18, 'string.escape.ts'),
          TR.IRelaxedToken(20, 'string.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ts'),
          TR.IRelaxedToken(2, 'string.invalid.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\\\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ts'),
          TR.IRelaxedToken(1, 'string.escape.ts'),
          TR.IRelaxedToken(3, 'string.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'be careful \\not to escape\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ts'),
          TR.IRelaxedToken(12, 'string.escape.ts'),
          TR.IRelaxedToken(14, 'string.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.ts'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(1, 'delimiter.ts'),
          TR.IRelaxedToken(2, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(3, 'delimiter.ts'),
          TR.IRelaxedToken(4, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '01239',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.ts'),
          TR.IRelaxedToken(4, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0o123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0O123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(1, 'identifier.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0X123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0n ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.ts'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0n ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0n+0n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100n+10n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(4, 'delimiter.ts'),
          TR.IRelaxedToken(5, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0n + 0n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ts'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b101n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0o123n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/**/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/***/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5 / 3;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.ts'),
          TR.IRelaxedToken(5, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.ts'),
          TR.IRelaxedToken(5, 'delimiter.ts'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2 / x / b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.ts'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.ts'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.ts'),
          TR.IRelaxedToken(13, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /foo/.test(\'\')',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'regexp.ts'),
          TR.IRelaxedToken(9, 'delimiter.ts'),
          TR.IRelaxedToken(10, 'identifier.ts'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(15, 'string.ts'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = !/`/.test(\'a\');',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.ts'),
          TR.IRelaxedToken(9, 'regexp.ts'),
          TR.IRelaxedToken(12, 'delimiter.ts'),
          TR.IRelaxedToken(13, 'identifier.ts'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(18, 'string.ts'),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(22, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/foo/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/foo/g',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.ts'),
          TR.IRelaxedToken(5, 'keyword.other.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/foo/dgimsuy',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.ts'),
          TR.IRelaxedToken(5, 'keyword.other.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/foo/q',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.ts'),
          TR.IRelaxedToken(1, 'identifier.ts'),
          TR.IRelaxedToken(4, 'delimiter.ts'),
          TR.IRelaxedToken(5, 'identifier.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = 1 + f(2 / 3, /foo/)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.ts'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(10, 'number.ts'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.ts'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.ts'),
          TR.IRelaxedToken(15, 'delimiter.ts'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'regexp.ts'),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a /ads/ b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, 'identifier.ts'),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.ts'),
          TR.IRelaxedToken(9, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1/(2/3)/2/3;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ts'),
          TR.IRelaxedToken(1, 'delimiter.ts'),
          TR.IRelaxedToken(2, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(3, 'number.ts'),
          TR.IRelaxedToken(4, 'delimiter.ts'),
          TR.IRelaxedToken(5, 'number.ts'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(7, 'delimiter.ts'),
          TR.IRelaxedToken(8, 'number.ts'),
          TR.IRelaxedToken(9, 'delimiter.ts'),
          TR.IRelaxedToken(10, 'number.ts'),
          TR.IRelaxedToken(11, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{ key: 123 }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'identifier.ts'),
          TR.IRelaxedToken(5, 'delimiter.ts'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.ts'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.bracket.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[1,2,3]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.ts'),
          TR.IRelaxedToken(1, 'number.ts'),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, 'number.ts'),
          TR.IRelaxedToken(4, 'delimiter.ts'),
          TR.IRelaxedToken(5, 'number.ts'),
          TR.IRelaxedToken(6, 'delimiter.square.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo(123);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(4, 'number.ts'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(8, 'delimiter.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{a:{b:[]}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(1, 'identifier.ts'),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, 'delimiter.ts'),
          TR.IRelaxedToken(6, 'delimiter.square.ts'),
          TR.IRelaxedToken(8, 'delimiter.bracket.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = "[{()}]"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'test ? 1 : 2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.ts'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.ts'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.ts'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'couldBeNullish ?? 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ts'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.ts'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'number.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`\${5 + \'x\' + (<any>)3}a\${4}`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ts'),
          TR.IRelaxedToken(1, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(3, 'number.ts'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.ts'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.ts'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.ts'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(14, 'delimiter.angle.ts'),
          TR.IRelaxedToken(15, 'keyword.ts'),
          TR.IRelaxedToken(18, 'delimiter.angle.ts'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.ts'),
          TR.IRelaxedToken(20, 'number.ts'),
          TR.IRelaxedToken(21, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(22, 'string.ts'),
          TR.IRelaxedToken(23, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(25, 'number.ts'),
          TR.IRelaxedToken(26, 'delimiter.bracket.ts'),
          TR.IRelaxedToken(27, 'string.ts'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let x = 2 / 2; //asd',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ts'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ts'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ts'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.ts'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.ts'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'number.ts'),
          TR.IRelaxedToken(13, 'delimiter.ts'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'comment.ts'),
        ],
      ),
    ],
  ]);
}

