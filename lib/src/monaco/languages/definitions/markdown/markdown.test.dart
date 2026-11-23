// Generated 1:1 from languages/definitions/markdown/markdown.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('markdown')
void runLanguagesDefinitionsMarkdownMarkdownTestCases() {
  TR.testTokenization('markdown', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '# Some header',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.md'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '* Some list item',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.md'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'some `code`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'variable.md'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'some ![link](http://link.com)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'string.link.md'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(11, 'string.link.md'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<div>content</div>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.md'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(12, 'tag.md'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<custom-component>content</custom-component>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.md'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(25, 'tag.md'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<div',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.md'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<custom-',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.md'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<custom-component',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.md'),
        ],
      ),
    ],
  ]);
}

