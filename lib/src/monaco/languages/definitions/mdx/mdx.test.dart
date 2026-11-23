// Generated 1:1 from languages/definitions/mdx/mdx.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('mdx')
void runLanguagesDefinitionsMdxMdxTestCases() {
  TR.testTokenization(<String>['mdx', 'yaml'], <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '# header 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
        ],
      ),
      TR.ITestItem(
        '## header 2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
        ],
      ),
      TR.ITestItem(
        '### header 3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
        ],
      ),
      TR.ITestItem(
        '#### header 4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
        ],
      ),
      TR.ITestItem(
        '##### header 5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
        ],
      ),
      TR.ITestItem(
        '###### header 6',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '- apple',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
          TR.IRelaxedToken(1, 'white.mdx'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '* pear',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
          TR.IRelaxedToken(1, 'white.mdx'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '+ pineapple',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mdx'),
          TR.IRelaxedToken(1, 'white.mdx'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '1. orange',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.mdx'),
          TR.IRelaxedToken(2, 'white.mdx'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '---',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.mdx'),
        ],
      ),
      TR.ITestItem(
        'frontmatter: yaml',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(11, 'operators.yaml'),
          TR.IRelaxedToken(12, 'white.yaml'),
          TR.IRelaxedToken(13, 'string.yaml'),
        ],
      ),
      TR.ITestItem(
        '---',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.mdx'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[MDX](https://mdxjs.com)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'type.identifier.mdx'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(6, 'string.link.mdx'),
          TR.IRelaxedToken(23, ''),
        ],
      ),
      TR.ITestItem(
        '[monaco][monaco]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'type.identifier.mdx'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(9, 'type.identifier.mdx'),
          TR.IRelaxedToken(15, ''),
        ],
      ),
      TR.ITestItem(
        '[monaco][]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'type.identifier.mdx'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
      TR.ITestItem(
        '[monaco]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'type.identifier.mdx'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
      TR.ITestItem(
        '[monaco]: https://github.com/microsoft/monaco-editor',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'type.identifier.mdx'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(10, 'string.link.mdx'),
        ],
      ),
    ],
  ]);
}

