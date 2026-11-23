// Generated 1:1 from languages/definitions/postiats/postiats.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('postiats')
void runLanguagesDefinitionsPostiatsPostiatsTestCases() {
  TR.testTokenization('postiats', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'implement main(argc, argv) =',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.pats'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(15, 'identifier.pats'),
          TR.IRelaxedToken(19, 'delimiter.comma.pats'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'identifier.pats'),
          TR.IRelaxedToken(25, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'keyword.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.pats'),
          TR.IRelaxedToken(1, 'identifier.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.pats'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.decimal.pats'),
          TR.IRelaxedToken(5, 'delimiter.semicolon.pats'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val x:int = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(5, 'keyword.pats'),
          TR.IRelaxedToken(6, 'type.pats'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.pats'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'number.decimal.pats'),
          TR.IRelaxedToken(13, 'delimiter.semicolon.pats'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x : int = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'type.pats'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'keyword.pats'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'comment.pats'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'number.decimal.pats'),
          TR.IRelaxedToken(38, 'delimiter.semicolon.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.pats'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.decimal.pats'),
          TR.IRelaxedToken(23, 'delimiter.semicolon.pats'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'operator.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.pats'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.pats'),
          TR.IRelaxedToken(8, 'delimiter.semicolon.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.pats'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* a simple comment *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* a simple (* nested *) comment *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* ****** ****** *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x : int = (* a simple comment *) 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'type.pats'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'keyword.pats'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'comment.pats'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'number.decimal.pats'),
          TR.IRelaxedToken(38, 'delimiter.semicolon.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val x = (* comment *) 1; *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.pats'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.decimal.pats'),
          TR.IRelaxedToken(23, 'delimiter.semicolon.pats'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'operator.pats'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = (**);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.pats'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.pats'),
          TR.IRelaxedToken(8, 'delimiter.semicolon.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(*)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '12l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '34U',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '55LL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '34ul',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '55llU',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x100aafllU',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0342325',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
          TR.IRelaxedToken(1, 'operator.pats'),
          TR.IRelaxedToken(2, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
          TR.IRelaxedToken(3, 'operator.pats'),
          TR.IRelaxedToken(4, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.decimal.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"{\$LIBATSCC2JS}/staloadall.hats"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.pats'),
          TR.IRelaxedToken(1, 'string.escape.pats'),
          TR.IRelaxedToken(3, 'identifier.pats'),
          TR.IRelaxedToken(14, 'string.escape.pats'),
          TR.IRelaxedToken(15, 'string.pats'),
          TR.IRelaxedToken(31, 'string.quote.pats'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#include "/path/to/my/file.h"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.srp.pats'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.quote.pats'),
          TR.IRelaxedToken(10, 'string.pats'),
          TR.IRelaxedToken(28, 'string.quote.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#ifdef VAR #then',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.srp.pats'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.pats'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.srp.pats'),
        ],
      ),
      TR.ITestItem(
        '#define SUM(A,B) (A) + (B)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.srp.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.pats'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(12, 'identifier.pats'),
          TR.IRelaxedToken(13, 'delimiter.comma.pats'),
          TR.IRelaxedToken(14, 'identifier.pats'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(18, 'identifier.pats'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'operator.pats'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(24, 'identifier.pats'),
          TR.IRelaxedToken(25, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        'staload Asdf_CDE = "./myfile.sats"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.pats'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'keyword.pats'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'string.quote.pats'),
          TR.IRelaxedToken(20, 'string.pats'),
          TR.IRelaxedToken(33, 'string.quote.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'implement main(argc, argv)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.pats'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(15, 'identifier.pats'),
          TR.IRelaxedToken(19, 'delimiter.comma.pats'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'identifier.pats'),
          TR.IRelaxedToken(25, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        ' = begin',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.pats'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'keyword.pats'),
        ],
      ),
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.decimal.pats'),
        ],
      ),
      TR.ITestItem(
        'end',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'dataprop FACT (int, int) =',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.pats'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(15, 'type.pats'),
          TR.IRelaxedToken(18, 'delimiter.comma.pats'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'type.pats'),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'keyword.pats'),
        ],
      ),
      TR.ITestItem(
        ' | FACTbas (0, 1) of ()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.pats'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'identifier.pats'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(12, 'number.decimal.pats'),
          TR.IRelaxedToken(13, 'delimiter.comma.pats'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.decimal.pats'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'keyword.pats'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        ' | {n:pos}{r:int} FACTind (n, n*r) of FACT (n-1, r)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.pats'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.curly.pats'),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(5, 'keyword.pats'),
          TR.IRelaxedToken(6, 'identifier.pats'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(10, 'delimiter.curly.pats'),
          TR.IRelaxedToken(11, 'identifier.pats'),
          TR.IRelaxedToken(12, 'keyword.pats'),
          TR.IRelaxedToken(13, 'type.pats'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'identifier.pats'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(27, 'identifier.pats'),
          TR.IRelaxedToken(28, 'delimiter.comma.pats'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'identifier.pats'),
          TR.IRelaxedToken(31, 'operator.pats'),
          TR.IRelaxedToken(32, 'identifier.pats'),
          TR.IRelaxedToken(33, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'keyword.pats'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'identifier.pats'),
          TR.IRelaxedToken(42, ''),
          TR.IRelaxedToken(43, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(44, 'identifier.pats'),
          TR.IRelaxedToken(45, 'operator.pats'),
          TR.IRelaxedToken(46, 'number.decimal.pats'),
          TR.IRelaxedToken(47, 'delimiter.comma.pats'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(49, 'identifier.pats'),
          TR.IRelaxedToken(50, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'fun fact {n:nat} .<n>. (x: int n) : [r:int] (FACT(n, r) | int(r)) = (',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.curly.pats'),
          TR.IRelaxedToken(10, 'identifier.pats'),
          TR.IRelaxedToken(11, 'keyword.pats'),
          TR.IRelaxedToken(12, 'identifier.pats'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'identifier.sym.pats'),
          TR.IRelaxedToken(19, 'identifier.pats'),
          TR.IRelaxedToken(20, 'keyword.pats'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(24, 'identifier.pats'),
          TR.IRelaxedToken(25, 'keyword.pats'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'type.pats'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'identifier.pats'),
          TR.IRelaxedToken(32, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'keyword.pats'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(36, 'delimiter.square.pats'),
          TR.IRelaxedToken(37, 'identifier.pats'),
          TR.IRelaxedToken(38, 'keyword.pats'),
          TR.IRelaxedToken(39, 'type.pats'),
          TR.IRelaxedToken(42, 'delimiter.square.pats'),
          TR.IRelaxedToken(43, ''),
          TR.IRelaxedToken(44, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(45, 'identifier.pats'),
          TR.IRelaxedToken(49, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(50, 'identifier.pats'),
          TR.IRelaxedToken(51, 'delimiter.comma.pats'),
          TR.IRelaxedToken(52, ''),
          TR.IRelaxedToken(53, 'identifier.pats'),
          TR.IRelaxedToken(54, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(55, ''),
          TR.IRelaxedToken(56, 'keyword.pats'),
          TR.IRelaxedToken(57, ''),
          TR.IRelaxedToken(58, 'type.pats'),
          TR.IRelaxedToken(61, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(62, 'identifier.pats'),
          TR.IRelaxedToken(63, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(65, ''),
          TR.IRelaxedToken(66, 'keyword.pats'),
          TR.IRelaxedToken(67, ''),
          TR.IRelaxedToken(68, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        'if x > 0 then let',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'identifier.pats'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'keyword.pats'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.decimal.pats'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.pats'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.pats'),
        ],
      ),
      TR.ITestItem(
        '  val [r1:int] (pf1 | r1) = fact (x-1)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.pats'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.square.pats'),
          TR.IRelaxedToken(7, 'identifier.pats'),
          TR.IRelaxedToken(9, 'keyword.pats'),
          TR.IRelaxedToken(10, 'type.pats'),
          TR.IRelaxedToken(13, 'delimiter.square.pats'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(16, 'identifier.pats'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'keyword.pats'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'identifier.pats'),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'keyword.pats'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'identifier.pats'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(34, 'identifier.pats'),
          TR.IRelaxedToken(35, 'operator.pats'),
          TR.IRelaxedToken(36, 'number.decimal.pats'),
          TR.IRelaxedToken(37, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        '  prval pf = FACTind {n}{r1} (pf1)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.pats'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.pats'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.pats'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.curly.pats'),
          TR.IRelaxedToken(22, 'identifier.pats'),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(24, 'delimiter.curly.pats'),
          TR.IRelaxedToken(25, 'identifier.pats'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(30, 'identifier.pats'),
          TR.IRelaxedToken(33, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        '  val r = x * r1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.pats'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.pats'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.pats'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'operator.pats'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.pats'),
        ],
      ),
      TR.ITestItem(
        'in',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
        ],
      ),
      TR.ITestItem(
        '  (pf | r)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(3, 'identifier.pats'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.pats'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.pats'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        'end // end of [then]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.pats'),
        ],
      ),
      TR.ITestItem(
        'else (FACTbas () | 1)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(6, 'identifier.pats'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'keyword.pats'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'number.decimal.pats'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        ') (* end of [fact] *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'comment.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'local',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
        ],
      ),
      TR.ITestItem(
        'var __count: int = 0 // it is statically allocated',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(11, 'keyword.pats'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'type.pats'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'keyword.pats'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'number.decimal.pats'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'comment.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'val theCount =',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.pats'),
        ],
      ),
      TR.ITestItem(
        '  ref_make_viewptr{int}(view@(__count) | addr@(__count))',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.pats'),
          TR.IRelaxedToken(18, 'delimiter.curly.pats'),
          TR.IRelaxedToken(19, 'type.pats'),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(24, 'keyword.pats'),
          TR.IRelaxedToken(29, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(30, 'identifier.pats'),
          TR.IRelaxedToken(37, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'keyword.pats'),
          TR.IRelaxedToken(40, ''),
          TR.IRelaxedToken(41, 'keyword.pats'),
          TR.IRelaxedToken(46, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(47, 'identifier.pats'),
          TR.IRelaxedToken(54, 'delimiter.parenthesis.pats'),
        ],
      ),
      TR.ITestItem(
        '// end of [val]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'in (* in of [local] *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'comment.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'fun theCount_get (): int = !theCount',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(19, 'keyword.pats'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'type.pats'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'keyword.pats'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'keyword.pats'),
          TR.IRelaxedToken(28, 'identifier.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'fun theCount_inc (): void = !theCount := !theCount + 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pats'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.pats'),
          TR.IRelaxedToken(19, 'keyword.pats'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'type.pats'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'keyword.pats'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'keyword.pats'),
          TR.IRelaxedToken(29, 'identifier.pats'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'operator.pats'),
          TR.IRelaxedToken(40, ''),
          TR.IRelaxedToken(41, 'keyword.pats'),
          TR.IRelaxedToken(42, 'identifier.pats'),
          TR.IRelaxedToken(50, ''),
          TR.IRelaxedToken(51, 'operator.pats'),
          TR.IRelaxedToken(52, ''),
          TR.IRelaxedToken(53, 'number.decimal.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'end // end of [local]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pats'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.pats'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#endif',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.srp.pats'),
        ],
      ),
    ],
  ]);
}

