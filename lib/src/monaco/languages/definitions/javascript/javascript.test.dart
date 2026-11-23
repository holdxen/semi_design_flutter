// Generated 1:1 from languages/definitions/javascript/javascript.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('javascript')
void runLanguagesDefinitionsJavascriptJavascriptTestCases() {
  TR.testTokenization('javascript', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = function() { };',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.js'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.bracket.js'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.bracket.js'),
          TR.IRelaxedToken(22, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    var    ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.js'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(3, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo() { return 1; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.bracket.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.js'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.js'),
          TR.IRelaxedToken(16, 'delimiter.js'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.bracket.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#foo;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(4, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#foo() { return 1; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.bracket.js'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.js'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'number.js'),
          TR.IRelaxedToken(17, 'delimiter.js'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.bracket.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment /*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment /**',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.js'),
          TR.IRelaxedToken(9, 'delimiter.js'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.js'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.js'),
          TR.IRelaxedToken(32, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.js'),
          TR.IRelaxedToken(8, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
      TR.ITestItem(
        'can actually span',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
      TR.ITestItem(
        'multiple lines */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.js'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
      TR.ITestItem(
        'and end it */ var a = 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.js'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'identifier.js'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'delimiter.js'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.js'),
          TR.IRelaxedToken(23, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var a = \'a\';',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.js'),
          TR.IRelaxedToken(11, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"use strict";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.js'),
          TR.IRelaxedToken(12, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'b = a + " \'cool\'  "',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping \\"quotes\\" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.js'),
          TR.IRelaxedToken(10, 'string.escape.js'),
          TR.IRelaxedToken(12, 'string.js'),
          TR.IRelaxedToken(18, 'string.escape.js'),
          TR.IRelaxedToken(20, 'string.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.js'),
          TR.IRelaxedToken(2, 'string.invalid.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\\\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.js'),
          TR.IRelaxedToken(1, 'string.escape.js'),
          TR.IRelaxedToken(3, 'string.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'be careful \\not to escape\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.js'),
          TR.IRelaxedToken(12, 'string.escape.js'),
          TR.IRelaxedToken(14, 'string.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.js'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(1, 'delimiter.js'),
          TR.IRelaxedToken(2, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(3, 'delimiter.js'),
          TR.IRelaxedToken(4, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '01239',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.js'),
          TR.IRelaxedToken(4, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0o123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0O123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(1, 'identifier.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0X123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0n ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.js'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0n ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0n+0n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100n+10n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(4, 'delimiter.js'),
          TR.IRelaxedToken(5, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0n + 0n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.js'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b101n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0o123n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/**/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/***/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5 / 3;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.js'),
          TR.IRelaxedToken(5, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.js'),
          TR.IRelaxedToken(5, 'delimiter.js'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2 / x / b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.js'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.js'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.js'),
          TR.IRelaxedToken(13, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /foo/.test(\'\')',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'regexp.js'),
          TR.IRelaxedToken(9, 'delimiter.js'),
          TR.IRelaxedToken(10, 'identifier.js'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(15, 'string.js'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/foo/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/foo/g',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.js'),
          TR.IRelaxedToken(5, 'keyword.other.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/foo/dgimsuy',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.js'),
          TR.IRelaxedToken(5, 'keyword.other.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/foo/q',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.js'),
          TR.IRelaxedToken(1, 'identifier.js'),
          TR.IRelaxedToken(4, 'delimiter.js'),
          TR.IRelaxedToken(5, 'identifier.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = 1 + f(2 / 3, /foo/)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.js'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.js'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(10, 'number.js'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.js'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.js'),
          TR.IRelaxedToken(15, 'delimiter.js'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'regexp.js'),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a /ads/ b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, 'identifier.js'),
          TR.IRelaxedToken(6, 'delimiter.js'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.js'),
          TR.IRelaxedToken(9, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1/(2/3)/2/3;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.js'),
          TR.IRelaxedToken(1, 'delimiter.js'),
          TR.IRelaxedToken(2, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(3, 'number.js'),
          TR.IRelaxedToken(4, 'delimiter.js'),
          TR.IRelaxedToken(5, 'number.js'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(7, 'delimiter.js'),
          TR.IRelaxedToken(8, 'number.js'),
          TR.IRelaxedToken(9, 'delimiter.js'),
          TR.IRelaxedToken(10, 'number.js'),
          TR.IRelaxedToken(11, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{ key: 123 }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.bracket.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'identifier.js'),
          TR.IRelaxedToken(5, 'delimiter.js'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.js'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.bracket.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[1,2,3]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.js'),
          TR.IRelaxedToken(1, 'number.js'),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, 'number.js'),
          TR.IRelaxedToken(4, 'delimiter.js'),
          TR.IRelaxedToken(5, 'number.js'),
          TR.IRelaxedToken(6, 'delimiter.square.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo(123);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(4, 'number.js'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(8, 'delimiter.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{a:{b:[]}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.bracket.js'),
          TR.IRelaxedToken(1, 'identifier.js'),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, 'delimiter.bracket.js'),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, 'delimiter.js'),
          TR.IRelaxedToken(6, 'delimiter.square.js'),
          TR.IRelaxedToken(8, 'delimiter.bracket.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = "[{()}]"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'test ? 1 : 2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.js'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.js'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.js'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'couldBeNullish ?? 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.js'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.js'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'number.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`\${5 + \'x\' + 3}a\${4}`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.js'),
          TR.IRelaxedToken(1, 'delimiter.bracket.js'),
          TR.IRelaxedToken(3, 'number.js'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.js'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.js'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.js'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'number.js'),
          TR.IRelaxedToken(14, 'delimiter.bracket.js'),
          TR.IRelaxedToken(15, 'string.js'),
          TR.IRelaxedToken(16, 'delimiter.bracket.js'),
          TR.IRelaxedToken(18, 'number.js'),
          TR.IRelaxedToken(19, 'delimiter.bracket.js'),
          TR.IRelaxedToken(20, 'string.js'),
        ],
      ),
    ],
  ]);
}

