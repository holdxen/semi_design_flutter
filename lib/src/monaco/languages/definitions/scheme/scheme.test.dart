// Generated 1:1 from languages/definitions/scheme/scheme.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('scheme')
void runLanguagesDefinitionsSchemeSchemeTestCases() {
  TR.testTokenization('scheme', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'define-macro some',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scheme'),
          TR.IRelaxedToken(12, 'white.scheme'),
          TR.IRelaxedToken(13, 'variable.scheme'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '; comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scheme'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#| comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scheme'),
        ],
      ),
      TR.ITestItem(
        'multiline',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scheme'),
        ],
      ),
      TR.ITestItem(
        '|# cons',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scheme'),
          TR.IRelaxedToken(2, 'white.scheme'),
          TR.IRelaxedToken(3, 'keyword.scheme'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"\\n string "',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.scheme'),
          TR.IRelaxedToken(1, 'string.escape.scheme'),
          TR.IRelaxedToken(3, 'string.scheme'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '" string \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.scheme'),
        ],
      ),
      TR.ITestItem(
        'multiline',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.scheme'),
        ],
      ),
      TR.ITestItem(
        ' ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.scheme'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1e2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scheme'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#x03BB',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.scheme'),
        ],
      ),
    ],
  ]);
}

