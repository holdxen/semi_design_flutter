// Generated 1:1 from languages/definitions/powerquery/powerquery.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('powerquery')
void runLanguagesDefinitionsPowerqueryPowerqueryTestCases() {
  TR.testTokenization('powerquery', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.pq'),
          TR.IRelaxedToken(4, 'comment.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// /* #A */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/*ABCD12\$!()\\u000D%%%%%*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '42 /* + 45 */ /*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.pq'),
          TR.IRelaxedToken(2, 'white.pq'),
          TR.IRelaxedToken(3, 'comment.pq'),
          TR.IRelaxedToken(13, 'white.pq'),
          TR.IRelaxedToken(14, 'comment.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pq'),
          TR.IRelaxedToken(7, 'white.pq'),
          TR.IRelaxedToken(8, 'identifier.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.pq'),
          TR.IRelaxedToken(1, 'white.pq'),
          TR.IRelaxedToken(2, 'operators.pq'),
          TR.IRelaxedToken(3, 'white.pq'),
          TR.IRelaxedToken(4, 'number.pq'),
          TR.IRelaxedToken(5, 'delimiter.pq'),
          TR.IRelaxedToken(6, 'white.pq'),
          TR.IRelaxedToken(7, 'comment.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#"Change Types"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#"A  B" = 1+2,',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.pq'),
          TR.IRelaxedToken(7, 'white.pq'),
          TR.IRelaxedToken(8, 'operators.pq'),
          TR.IRelaxedToken(9, 'white.pq'),
          TR.IRelaxedToken(10, 'number.pq'),
          TR.IRelaxedToken(11, 'operators.pq'),
          TR.IRelaxedToken(12, 'number.pq'),
          TR.IRelaxedToken(13, 'delimiter.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a = #"escap ed"+ 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.pq'),
          TR.IRelaxedToken(1, 'white.pq'),
          TR.IRelaxedToken(2, 'operators.pq'),
          TR.IRelaxedToken(3, 'white.pq'),
          TR.IRelaxedToken(4, 'identifier.quote.pq'),
          TR.IRelaxedToken(15, 'operators.pq'),
          TR.IRelaxedToken(16, 'white.pq'),
          TR.IRelaxedToken(17, 'number.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0Xabc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xA',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1e1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5 / 1.2e+2 + 0x1234abc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.pq'),
          TR.IRelaxedToken(1, 'white.pq'),
          TR.IRelaxedToken(2, 'operators.pq'),
          TR.IRelaxedToken(3, 'white.pq'),
          TR.IRelaxedToken(4, 'number.float.pq'),
          TR.IRelaxedToken(10, 'white.pq'),
          TR.IRelaxedToken(11, 'operators.pq'),
          TR.IRelaxedToken(12, 'white.pq'),
          TR.IRelaxedToken(13, 'number.hex.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xb *(.2)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.pq'),
          TR.IRelaxedToken(3, 'white.pq'),
          TR.IRelaxedToken(4, 'operators.pq'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.pq'),
          TR.IRelaxedToken(6, 'number.float.pq'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.23e34+1.2e-2-.3e2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pq'),
          TR.IRelaxedToken(7, 'operators.pq'),
          TR.IRelaxedToken(8, 'number.float.pq'),
          TR.IRelaxedToken(14, 'operators.pq'),
          TR.IRelaxedToken(15, 'number.float.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  "string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.pq'),
          TR.IRelaxedToken(2, 'string.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"string" & "another"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pq'),
          TR.IRelaxedToken(8, 'white.pq'),
          TR.IRelaxedToken(9, 'operators.pq'),
          TR.IRelaxedToken(10, 'white.pq'),
          TR.IRelaxedToken(11, 'string.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"with  ""escaped "" \'text',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pq'),
          TR.IRelaxedToken(7, 'string.escape.pq'),
          TR.IRelaxedToken(9, 'string.pq'),
          TR.IRelaxedToken(17, 'string.escape.pq'),
          TR.IRelaxedToken(19, 'string.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'And as Each each _',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.pq'),
          TR.IRelaxedToken(3, 'white.pq'),
          TR.IRelaxedToken(4, 'keyword.pq'),
          TR.IRelaxedToken(6, 'white.pq'),
          TR.IRelaxedToken(7, 'identifier.pq'),
          TR.IRelaxedToken(11, 'white.pq'),
          TR.IRelaxedToken(12, 'keyword.pq'),
          TR.IRelaxedToken(16, 'white.pq'),
          TR.IRelaxedToken(17, 'identifier.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  #table({})',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.pq'),
          TR.IRelaxedToken(2, 'constructor.pq'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.pq'),
          TR.IRelaxedToken(9, 'delimiter.brackets.pq'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'param as number',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.pq'),
          TR.IRelaxedToken(5, 'white.pq'),
          TR.IRelaxedToken(6, 'keyword.pq'),
          TR.IRelaxedToken(8, 'white.pq'),
          TR.IRelaxedToken(9, 'type.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'type table',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pq'),
          TR.IRelaxedToken(4, 'white.pq'),
          TR.IRelaxedToken(5, 'type.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'if (a = #nan) then null else a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pq'),
          TR.IRelaxedToken(2, 'white.pq'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.pq'),
          TR.IRelaxedToken(4, 'identifier.pq'),
          TR.IRelaxedToken(5, 'white.pq'),
          TR.IRelaxedToken(6, 'operators.pq'),
          TR.IRelaxedToken(7, 'white.pq'),
          TR.IRelaxedToken(8, 'constant.pq'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.pq'),
          TR.IRelaxedToken(13, 'white.pq'),
          TR.IRelaxedToken(14, 'keyword.pq'),
          TR.IRelaxedToken(18, 'white.pq'),
          TR.IRelaxedToken(19, 'type.pq'),
          TR.IRelaxedToken(23, 'white.pq'),
          TR.IRelaxedToken(24, 'keyword.pq'),
          TR.IRelaxedToken(28, 'white.pq'),
          TR.IRelaxedToken(29, 'identifier.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Text.From(1)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.function.pq'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.pq'),
          TR.IRelaxedToken(10, 'number.pq'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Text.ToBinary("123", BinaryEncoding.Base64)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.function.pq'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.pq'),
          TR.IRelaxedToken(14, 'string.pq'),
          TR.IRelaxedToken(19, 'delimiter.pq'),
          TR.IRelaxedToken(20, 'white.pq'),
          TR.IRelaxedToken(21, 'constant.pq'),
          TR.IRelaxedToken(42, 'delimiter.parenthesis.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Int8.Type',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'DB2.Database',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.function.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'RelativePosition.Type',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[version="1.0.0.1"] section Foo; shared Member.Name = 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.pq'),
          TR.IRelaxedToken(1, 'identifier.pq'),
          TR.IRelaxedToken(8, 'operators.pq'),
          TR.IRelaxedToken(9, 'string.pq'),
          TR.IRelaxedToken(18, 'delimiter.square.pq'),
          TR.IRelaxedToken(19, 'white.pq'),
          TR.IRelaxedToken(20, 'keyword.pq'),
          TR.IRelaxedToken(27, 'white.pq'),
          TR.IRelaxedToken(28, 'identifier.pq'),
          TR.IRelaxedToken(31, 'delimiter.pq'),
          TR.IRelaxedToken(32, 'white.pq'),
          TR.IRelaxedToken(33, 'keyword.pq'),
          TR.IRelaxedToken(39, 'white.pq'),
          TR.IRelaxedToken(40, 'identifier.pq'),
          TR.IRelaxedToken(51, 'white.pq'),
          TR.IRelaxedToken(52, 'operators.pq'),
          TR.IRelaxedToken(53, 'white.pq'),
          TR.IRelaxedToken(54, 'number.pq'),
          TR.IRelaxedToken(55, 'delimiter.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'isFunctionthen = 1;// comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.pq'),
          TR.IRelaxedToken(14, 'white.pq'),
          TR.IRelaxedToken(15, 'operators.pq'),
          TR.IRelaxedToken(16, 'white.pq'),
          TR.IRelaxedToken(17, 'number.pq'),
          TR.IRelaxedToken(18, 'delimiter.pq'),
          TR.IRelaxedToken(19, 'comment.pq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@RecursiveFunction()+@Rec.Func()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operators.pq'),
          TR.IRelaxedToken(1, 'identifier.pq'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.pq'),
          TR.IRelaxedToken(20, 'operators.pq'),
          TR.IRelaxedToken(22, 'identifier.pq'),
          TR.IRelaxedToken(30, 'delimiter.parenthesis.pq'),
        ],
      ),
    ],
  ]);
}

