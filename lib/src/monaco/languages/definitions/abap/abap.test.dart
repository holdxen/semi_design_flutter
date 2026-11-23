// Generated 1:1 from languages/definitions/abap/abap.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('abap')
void runLanguagesDefinitionsAbapAbapTestCases() {
  TR.testTokenization('abap', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' " comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'comment.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'write hello.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.abap'),
          TR.IRelaxedToken(11, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'IF 2 = 3.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'number.abap'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'key.abap'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.abap'),
          TR.IRelaxedToken(8, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'hello\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '|hello|',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'write: hello, world.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(5, 'delimiter.abap'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.abap'),
          TR.IRelaxedToken(12, 'delimiter.abap'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.abap'),
          TR.IRelaxedToken(19, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'method_call( param ).',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.abap'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.abap'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(20, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'he\'\' llo\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '|hel\\|lo|',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'FIELD-SYMBOLS <foo>.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.abap'),
          TR.IRelaxedToken(19, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'IF foo IS NOT INITIAL.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'identifier.abap'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.abap'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.abap'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.abap'),
          TR.IRelaxedToken(21, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'WRITE `moo`.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.abap'),
          TR.IRelaxedToken(11, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'FORM foo.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.abap'),
          TR.IRelaxedToken(8, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'moo = CONV #( 1 ).',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.abap'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'key.abap'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.abap'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'key.abap'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.abap'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(17, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'WRITE foo ##pragma.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.abap'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'comment.abap'),
          TR.IRelaxedToken(18, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'SELECT * FROM foo02 INTO @foo.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'key.abap'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.abap'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.abap'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'keyword.abap'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'identifier.abap'),
          TR.IRelaxedToken(29, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'li = lines( itab ).',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.abap'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'key.abap'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'keyword.abap'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.abap'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(18, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = \'bar\' && \'baz\'.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.abap'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'key.abap'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.abap'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'key.abap'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'string.abap'),
          TR.IRelaxedToken(20, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'DATA num TYPE n.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.abap'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.abap'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'type.abap'),
          TR.IRelaxedToken(15, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'CLASS-METHODS class_constructor.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'type.abap'),
          TR.IRelaxedToken(31, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'super->constructor( ).',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.abap'),
          TR.IRelaxedToken(5, 'tag.abap'),
          TR.IRelaxedToken(7, 'type.abap'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(21, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo->my_method( ).',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.abap'),
          TR.IRelaxedToken(3, 'tag.abap'),
          TR.IRelaxedToken(5, 'identifier.abap'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(17, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo=>const_bar.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.abap'),
          TR.IRelaxedToken(3, 'tag.abap'),
          TR.IRelaxedToken(5, 'identifier.abap'),
          TR.IRelaxedToken(14, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo-bar+42(42).',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.abap'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.abap'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(11, 'number.abap'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.abap'),
          TR.IRelaxedToken(14, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@EndUserText.label: \'hallo\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.abap'),
          TR.IRelaxedToken(12, 'delimiter.abap'),
          TR.IRelaxedToken(13, 'identifier.abap'),
          TR.IRelaxedToken(18, 'delimiter.abap'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'string.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'IF foo = abap_true.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'identifier.abap'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'key.abap'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'type.abap'),
          TR.IRelaxedToken(18, 'delimiter.abap'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'LOOP AT screen.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.abap'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'keyword.abap'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'type.abap'),
          TR.IRelaxedToken(14, 'delimiter.abap'),
        ],
      ),
    ],
  ]);
}

