// Generated 1:1 from languages/definitions/mysql/mysql.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('mysql')
void runLanguagesDefinitionsMysqlMysqlTestCases() {
  TR.testTokenization('mysql', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '-- a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '---sticky -- comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.sql'),
          TR.IRelaxedToken(1, 'identifier.sql'),
          TR.IRelaxedToken(7, 'white.sql'),
          TR.IRelaxedToken(8, 'identifier.sql'),
          TR.IRelaxedToken(9, 'white.sql'),
          TR.IRelaxedToken(10, 'identifier.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a full line comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.quote.sql'),
          TR.IRelaxedToken(2, 'comment.sql'),
          TR.IRelaxedToken(23, 'comment.quote.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* /// *** /// */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.quote.sql'),
          TR.IRelaxedToken(2, 'comment.sql'),
          TR.IRelaxedToken(15, 'comment.quote.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'declare @x int = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sql'),
          TR.IRelaxedToken(7, 'white.sql'),
          TR.IRelaxedToken(8, 'identifier.sql'),
          TR.IRelaxedToken(10, 'white.sql'),
          TR.IRelaxedToken(11, 'keyword.sql'),
          TR.IRelaxedToken(14, 'white.sql'),
          TR.IRelaxedToken(15, 'operator.sql'),
          TR.IRelaxedToken(16, 'white.sql'),
          TR.IRelaxedToken(17, 'comment.quote.sql'),
          TR.IRelaxedToken(19, 'comment.sql'),
          TR.IRelaxedToken(37, 'comment.quote.sql'),
          TR.IRelaxedToken(39, 'white.sql'),
          TR.IRelaxedToken(40, 'number.sql'),
          TR.IRelaxedToken(41, 'delimiter.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@x=/* a /* nested comment  1*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sql'),
          TR.IRelaxedToken(2, 'operator.sql'),
          TR.IRelaxedToken(3, 'comment.quote.sql'),
          TR.IRelaxedToken(5, 'comment.sql'),
          TR.IRelaxedToken(28, 'comment.quote.sql'),
          TR.IRelaxedToken(30, 'delimiter.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@x=/* another comment */ 1*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sql'),
          TR.IRelaxedToken(2, 'operator.sql'),
          TR.IRelaxedToken(3, 'comment.quote.sql'),
          TR.IRelaxedToken(5, 'comment.sql'),
          TR.IRelaxedToken(22, 'comment.quote.sql'),
          TR.IRelaxedToken(24, 'white.sql'),
          TR.IRelaxedToken(25, 'number.sql'),
          TR.IRelaxedToken(26, 'operator.sql'),
          TR.IRelaxedToken(28, 'delimiter.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@x=/*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sql'),
          TR.IRelaxedToken(2, 'operator.sql'),
          TR.IRelaxedToken(3, 'comment.quote.sql'),
          TR.IRelaxedToken(5, 'comment.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.sql'),
          TR.IRelaxedToken(1, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xaBc123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0XaBc123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xAB_CD',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
          TR.IRelaxedToken(4, 'identifier.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$-123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$-+-123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$123.5678',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$0.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$99.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$0.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123.5678',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '99.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E-2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E+2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'declare `abc 321`;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sql'),
          TR.IRelaxedToken(7, 'white.sql'),
          TR.IRelaxedToken(8, 'identifier.quote.sql'),
          TR.IRelaxedToken(9, 'identifier.sql'),
          TR.IRelaxedToken(16, 'identifier.quote.sql'),
          TR.IRelaxedToken(17, 'delimiter.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`abc`` 321 `` xyz`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.sql'),
          TR.IRelaxedToken(1, 'identifier.sql'),
          TR.IRelaxedToken(17, 'identifier.quote.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`abc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.sql'),
          TR.IRelaxedToken(1, 'identifier.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`int`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.sql'),
          TR.IRelaxedToken(1, 'identifier.sql'),
          TR.IRelaxedToken(4, 'identifier.quote.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'declare @x=\'a string\';',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sql'),
          TR.IRelaxedToken(7, 'white.sql'),
          TR.IRelaxedToken(8, 'identifier.sql'),
          TR.IRelaxedToken(10, 'operator.sql'),
          TR.IRelaxedToken(11, 'string.sql'),
          TR.IRelaxedToken(21, 'delimiter.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'declare @x="a string";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sql'),
          TR.IRelaxedToken(7, 'white.sql'),
          TR.IRelaxedToken(8, 'identifier.sql'),
          TR.IRelaxedToken(10, 'operator.sql'),
          TR.IRelaxedToken(11, 'string.double.sql'),
          TR.IRelaxedToken(21, 'delimiter.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'a \'\' string with quotes\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a "" string with quotes"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.double.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'a " string with quotes\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a ` string with quotes"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.double.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'a -- string with comment\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a -- string with comment"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.double.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'a endless string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a endless string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.double.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'SET @x=@x+1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sql'),
          TR.IRelaxedToken(3, 'white.sql'),
          TR.IRelaxedToken(4, 'identifier.sql'),
          TR.IRelaxedToken(6, 'operator.sql'),
          TR.IRelaxedToken(7, 'identifier.sql'),
          TR.IRelaxedToken(9, 'operator.sql'),
          TR.IRelaxedToken(10, 'number.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@x^=@x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sql'),
          TR.IRelaxedToken(2, 'operator.sql'),
          TR.IRelaxedToken(4, 'identifier.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'WHERE myfield IS NOT NULL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sql'),
          TR.IRelaxedToken(5, 'white.sql'),
          TR.IRelaxedToken(6, 'identifier.sql'),
          TR.IRelaxedToken(13, 'white.sql'),
          TR.IRelaxedToken(14, 'operator.sql'),
          TR.IRelaxedToken(16, 'white.sql'),
          TR.IRelaxedToken(17, 'operator.sql'),
          TR.IRelaxedToken(20, 'white.sql'),
          TR.IRelaxedToken(21, 'operator.sql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'SELECT * FROM tbl WHERE MyColumn IN (1,2)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sql'),
          TR.IRelaxedToken(6, 'white.sql'),
          TR.IRelaxedToken(7, 'operator.sql'),
          TR.IRelaxedToken(8, 'white.sql'),
          TR.IRelaxedToken(9, 'keyword.sql'),
          TR.IRelaxedToken(13, 'white.sql'),
          TR.IRelaxedToken(14, 'identifier.sql'),
          TR.IRelaxedToken(17, 'white.sql'),
          TR.IRelaxedToken(18, 'keyword.sql'),
          TR.IRelaxedToken(23, 'white.sql'),
          TR.IRelaxedToken(24, 'identifier.sql'),
          TR.IRelaxedToken(32, 'white.sql'),
          TR.IRelaxedToken(33, 'operator.sql'),
          TR.IRelaxedToken(35, 'white.sql'),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.sql'),
          TR.IRelaxedToken(37, 'number.sql'),
          TR.IRelaxedToken(38, 'delimiter.sql'),
          TR.IRelaxedToken(39, 'number.sql'),
          TR.IRelaxedToken(40, 'delimiter.parenthesis.sql'),
        ],
      ),
    ],
  ]);
}

