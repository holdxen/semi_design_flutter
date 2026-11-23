// Generated 1:1 from languages/definitions/lexon/lexon.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('lexon')
void runLanguagesDefinitionsLexonLexonTestCases() {
  TR.testTokenization('lexon', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'LEX Paid Escrow',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.lexon'),
          TR.IRelaxedToken(3, 'white.lexon'),
          TR.IRelaxedToken(4, 'identifier.lexon'),
          TR.IRelaxedToken(8, 'white.lexon'),
          TR.IRelaxedToken(9, 'identifier.lexon'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'LEXON: 0.2.20',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.lexon'),
          TR.IRelaxedToken(5, 'delimiter.lexon'),
          TR.IRelaxedToken(6, 'white.lexon'),
          TR.IRelaxedToken(7, 'number.semver.lexon'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'COMMENT: 3.f - an escrow that is controlled by a third party for a fee.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.lexon'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"Payer" is a person.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.lexon'),
          TR.IRelaxedToken(1, 'identifier.lexon'),
          TR.IRelaxedToken(6, 'identifier.quote.lexon'),
          TR.IRelaxedToken(7, 'white.lexon'),
          TR.IRelaxedToken(8, 'operator.lexon'),
          TR.IRelaxedToken(10, 'white.lexon'),
          TR.IRelaxedToken(11, 'identifier.lexon'),
          TR.IRelaxedToken(12, 'white.lexon'),
          TR.IRelaxedToken(13, 'keyword.type.lexon'),
          TR.IRelaxedToken(19, 'delimiter.lexon'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"Fee" is an amount.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.quote.lexon'),
          TR.IRelaxedToken(1, 'identifier.lexon'),
          TR.IRelaxedToken(4, 'identifier.quote.lexon'),
          TR.IRelaxedToken(5, 'white.lexon'),
          TR.IRelaxedToken(6, 'operator.lexon'),
          TR.IRelaxedToken(8, 'white.lexon'),
          TR.IRelaxedToken(9, 'identifier.lexon'),
          TR.IRelaxedToken(11, 'white.lexon'),
          TR.IRelaxedToken(12, 'keyword.type.lexon'),
          TR.IRelaxedToken(18, 'delimiter.lexon'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'The Payer pays an Amount into escrow,',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.lexon'),
          TR.IRelaxedToken(3, 'white.lexon'),
          TR.IRelaxedToken(4, 'identifier.lexon'),
          TR.IRelaxedToken(9, 'white.lexon'),
          TR.IRelaxedToken(10, 'keyword.lexon'),
          TR.IRelaxedToken(14, 'white.lexon'),
          TR.IRelaxedToken(15, 'identifier.lexon'),
          TR.IRelaxedToken(17, 'white.lexon'),
          TR.IRelaxedToken(18, 'keyword.type.lexon'),
          TR.IRelaxedToken(24, 'white.lexon'),
          TR.IRelaxedToken(25, 'keyword.lexon'),
          TR.IRelaxedToken(29, 'white.lexon'),
          TR.IRelaxedToken(30, 'identifier.lexon'),
          TR.IRelaxedToken(36, 'delimiter.lexon'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'appoints the Payee,',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.lexon'),
          TR.IRelaxedToken(8, 'white.lexon'),
          TR.IRelaxedToken(9, 'identifier.lexon'),
          TR.IRelaxedToken(12, 'white.lexon'),
          TR.IRelaxedToken(13, 'identifier.lexon'),
          TR.IRelaxedToken(18, 'delimiter.lexon'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'and also fixes the Fee.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.lexon'),
          TR.IRelaxedToken(3, 'white.lexon'),
          TR.IRelaxedToken(4, 'identifier.lexon'),
          TR.IRelaxedToken(8, 'white.lexon'),
          TR.IRelaxedToken(9, 'identifier.lexon'),
          TR.IRelaxedToken(14, 'white.lexon'),
          TR.IRelaxedToken(15, 'identifier.lexon'),
          TR.IRelaxedToken(18, 'white.lexon'),
          TR.IRelaxedToken(19, 'identifier.lexon'),
          TR.IRelaxedToken(22, 'delimiter.lexon'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'CLAUSE: Pay Out.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.lexon'),
          TR.IRelaxedToken(6, 'delimiter.lexon'),
          TR.IRelaxedToken(7, 'white.lexon'),
          TR.IRelaxedToken(8, 'identifier.lexon'),
          TR.IRelaxedToken(15, 'delimiter.lexon'),
        ],
      ),
    ],
  ]);
}

