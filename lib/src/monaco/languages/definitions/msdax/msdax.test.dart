// Generated 1:1 from languages/definitions/msdax/msdax.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('msdax')
void runLanguagesDefinitionsMsdaxMsdaxTestCases() {
  TR.testTokenization('msdax', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.msdax'),
          TR.IRelaxedToken(1, 'identifier.msdax'),
          TR.IRelaxedToken(7, 'white.msdax'),
          TR.IRelaxedToken(8, 'identifier.msdax'),
          TR.IRelaxedToken(9, 'white.msdax'),
          TR.IRelaxedToken(10, 'identifier.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a full line comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.quote.msdax'),
          TR.IRelaxedToken(2, 'comment.msdax'),
          TR.IRelaxedToken(23, 'comment.quote.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* /// *** /// */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.quote.msdax'),
          TR.IRelaxedToken(2, 'comment.msdax'),
          TR.IRelaxedToken(15, 'comment.quote.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'define measure x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
          TR.IRelaxedToken(6, 'white.msdax'),
          TR.IRelaxedToken(7, 'keyword.msdax'),
          TR.IRelaxedToken(14, 'white.msdax'),
          TR.IRelaxedToken(15, 'identifier.msdax'),
          TR.IRelaxedToken(16, 'white.msdax'),
          TR.IRelaxedToken(17, 'operator.msdax'),
          TR.IRelaxedToken(18, 'white.msdax'),
          TR.IRelaxedToken(19, 'comment.quote.msdax'),
          TR.IRelaxedToken(21, 'comment.msdax'),
          TR.IRelaxedToken(39, 'comment.quote.msdax'),
          TR.IRelaxedToken(41, 'white.msdax'),
          TR.IRelaxedToken(42, 'number.msdax'),
          TR.IRelaxedToken(43, 'delimiter.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.msdax'),
          TR.IRelaxedToken(1, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xaBc123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0XaBc123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xAB_CD',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
          TR.IRelaxedToken(4, 'identifier.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123.5678',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '99.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E-2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E+2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '_abc01',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'abc01',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'evaluate filter',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
          TR.IRelaxedToken(8, 'white.msdax'),
          TR.IRelaxedToken(9, 'keyword.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[abc[[ 321 ]] xyz]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.msdax'),
          TR.IRelaxedToken(1, 'identifier.msdax'),
          TR.IRelaxedToken(17, 'identifier.quote.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[abc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.msdax'),
          TR.IRelaxedToken(1, 'identifier.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'define measure \'abc\'[def]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
          TR.IRelaxedToken(6, 'white.msdax'),
          TR.IRelaxedToken(7, 'keyword.msdax'),
          TR.IRelaxedToken(14, 'white.msdax'),
          TR.IRelaxedToken(15, 'identifier.quote.msdax'),
          TR.IRelaxedToken(16, 'identifier.msdax'),
          TR.IRelaxedToken(19, 'identifier.quote.msdax'),
          TR.IRelaxedToken(21, 'identifier.msdax'),
          TR.IRelaxedToken(24, 'identifier.quote.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[int]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.msdax'),
          TR.IRelaxedToken(1, 'identifier.msdax'),
          TR.IRelaxedToken(4, 'identifier.quote.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"abc"" 321 "" xyz"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'define var x="a string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
          TR.IRelaxedToken(6, 'white.msdax'),
          TR.IRelaxedToken(7, 'keyword.msdax'),
          TR.IRelaxedToken(10, 'white.msdax'),
          TR.IRelaxedToken(11, 'identifier.msdax'),
          TR.IRelaxedToken(12, 'operator.msdax'),
          TR.IRelaxedToken(13, 'string.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a "" string with quotes"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a // string with comment"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'N"a unicode string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a endless string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'define var x=1+3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
          TR.IRelaxedToken(6, 'white.msdax'),
          TR.IRelaxedToken(7, 'keyword.msdax'),
          TR.IRelaxedToken(10, 'white.msdax'),
          TR.IRelaxedToken(11, 'identifier.msdax'),
          TR.IRelaxedToken(12, 'operator.msdax'),
          TR.IRelaxedToken(13, 'number.msdax'),
          TR.IRelaxedToken(14, 'operator.msdax'),
          TR.IRelaxedToken(15, 'number.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'define var x=1^+abc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
          TR.IRelaxedToken(6, 'white.msdax'),
          TR.IRelaxedToken(7, 'keyword.msdax'),
          TR.IRelaxedToken(10, 'white.msdax'),
          TR.IRelaxedToken(11, 'identifier.msdax'),
          TR.IRelaxedToken(12, 'operator.msdax'),
          TR.IRelaxedToken(13, 'number.msdax'),
          TR.IRelaxedToken(14, 'operator.msdax'),
          TR.IRelaxedToken(16, 'identifier.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'EVALUATE \'Products\' ORDER BY [Product Id] DESC',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
          TR.IRelaxedToken(8, 'white.msdax'),
          TR.IRelaxedToken(9, 'identifier.quote.msdax'),
          TR.IRelaxedToken(10, 'identifier.msdax'),
          TR.IRelaxedToken(18, 'identifier.quote.msdax'),
          TR.IRelaxedToken(19, 'white.msdax'),
          TR.IRelaxedToken(20, 'keyword.msdax'),
          TR.IRelaxedToken(25, 'white.msdax'),
          TR.IRelaxedToken(26, 'keyword.msdax'),
          TR.IRelaxedToken(28, 'white.msdax'),
          TR.IRelaxedToken(29, 'identifier.quote.msdax'),
          TR.IRelaxedToken(30, 'identifier.msdax'),
          TR.IRelaxedToken(40, 'identifier.quote.msdax'),
          TR.IRelaxedToken(41, 'white.msdax'),
          TR.IRelaxedToken(42, 'keyword.msdax'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'DATATABLE("Price", STRING, {{"Low"},{"Medium"}})',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.msdax'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.msdax'),
          TR.IRelaxedToken(10, 'string.msdax'),
          TR.IRelaxedToken(17, 'delimiter.msdax'),
          TR.IRelaxedToken(18, 'white.msdax'),
          TR.IRelaxedToken(19, 'keyword.msdax'),
          TR.IRelaxedToken(25, 'delimiter.msdax'),
          TR.IRelaxedToken(26, 'white.msdax'),
          TR.IRelaxedToken(27, 'delimiter.brackets.msdax'),
          TR.IRelaxedToken(29, 'string.msdax'),
          TR.IRelaxedToken(34, 'delimiter.brackets.msdax'),
          TR.IRelaxedToken(35, 'delimiter.msdax'),
          TR.IRelaxedToken(36, 'delimiter.brackets.msdax'),
          TR.IRelaxedToken(37, 'string.msdax'),
          TR.IRelaxedToken(45, 'delimiter.brackets.msdax'),
          TR.IRelaxedToken(47, 'delimiter.parenthesis.msdax'),
        ],
      ),
    ],
  ]);
}

