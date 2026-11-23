// Generated 1:1 from languages/definitions/flow9/flow9.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('flow9')
void runLanguagesDefinitionsFlow9Flow9TestCases() {
  TR.testTokenization('flow9', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.flow'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/import file 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.flow'),
          TR.IRelaxedToken(1, 'keyword.flow'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.flow'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'number.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'getDefaults() -> [int] {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.flow'),
          TR.IRelaxedToken(11, 'delimiter.flow'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.flow'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.flow'),
          TR.IRelaxedToken(18, 'type.flow'),
          TR.IRelaxedToken(21, 'delimiter.flow'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '052_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.flow'),
          TR.IRelaxedToken(3, 'identifier.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.flow'),
          TR.IRelaxedToken(1, 'delimiter.flow'),
          TR.IRelaxedToken(2, 'number.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.flow'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.flow'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"simple string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.flow'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.flow'),
          TR.IRelaxedToken(2, 'string.invalid.flow'),
        ],
      ),
    ],
  ]);
}

