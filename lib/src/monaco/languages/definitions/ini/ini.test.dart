// Generated 1:1 from languages/definitions/ini/ini.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('ini')
void runLanguagesDefinitionsIniIniTestCases() {
  TR.testTokenization('ini', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '; comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ini'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ini'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    ; indented comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ini'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\t# indented comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ini'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[section]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.ini'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key = value',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.ini'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.ini'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    indented-key = value',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(13, 'key.ini'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.ini'),
          TR.IRelaxedToken(18, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'color = #ff0000',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.ini'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ini'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(11, 'number.ini'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key = value ; trailing',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.ini'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.ini'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key = "value 1"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.ini'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.ini'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.ini'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[Section]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.ini'),
        ],
      ),
      TR.ITestItem(
        '    ; Long comment explaining why',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ini'),
        ],
      ),
      TR.ITestItem(
        '    key = value',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'key.ini'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.ini'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
    ],
  ]);
}

