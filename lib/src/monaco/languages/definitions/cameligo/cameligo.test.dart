// Generated 1:1 from languages/definitions/cameligo/cameligo.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('cameligo')
void runLanguagesDefinitionsCameligoCameligoTestCases() {
  TR.testTokenization('cameligo', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.cameligo'),
          TR.IRelaxedToken(4, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(**)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    (* a comment *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.cameligo'),
          TR.IRelaxedToken(4, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* a comment *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(*sticky comment*)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* start of multiline comment ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
      TR.ITestItem(
        'a comment between curly',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let check if Current.amount',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.cameligo'),
          TR.IRelaxedToken(3, 'white.cameligo'),
          TR.IRelaxedToken(4, 'identifier.cameligo'),
          TR.IRelaxedToken(9, 'white.cameligo'),
          TR.IRelaxedToken(10, 'keyword.if.cameligo'),
          TR.IRelaxedToken(12, 'white.cameligo'),
          TR.IRelaxedToken(13, 'keyword.current.cameligo'),
          TR.IRelaxedToken(20, 'delimiter.cameligo'),
          TR.IRelaxedToken(21, 'identifier.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cameligo'),
          TR.IRelaxedToken(1, 'delimiter.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2.4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2.4;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cameligo'),
          TR.IRelaxedToken(3, 'delimiter.cameligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$123FF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cameligo'),
        ],
      ),
    ],
  ]);
}

