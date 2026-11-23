// Generated 1:1 from languages/definitions/azcli/azcli.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('azcli')
void runLanguagesDefinitionsAzcliAzcliTestCases() {
  TR.testTokenization('azcli', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# az find -q secret',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    # az find -q secret',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
          TR.IRelaxedToken(4, 'comment.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#az find -q secret',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'az find -q secret',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
          TR.IRelaxedToken(7, 'key.identifier.azcli'),
          TR.IRelaxedToken(11, 'string.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '--assignee',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.identifier.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    --service-principal',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
          TR.IRelaxedToken(3, 'key.identifier.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'az ad sp create-for-rb  --name ServicePrincipalName --password PASSWORD',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
          TR.IRelaxedToken(23, 'key.identifier.azcli'),
          TR.IRelaxedToken(31, 'string.azcli'),
          TR.IRelaxedToken(52, 'key.identifier.azcli'),
          TR.IRelaxedToken(63, 'string.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '--name!~`"\$%^&*(|/.,-=+',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.identifier.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '--name#some comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.identifier.azcli'),
          TR.IRelaxedToken(6, 'comment.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '--query osPro ``````',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.identifier.azcli'),
          TR.IRelaxedToken(8, 'string.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'az ad sp create-for-rbac',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123456789',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '- abc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.identifier.azcli'),
          TR.IRelaxedToken(2, 'string.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '- @!\$()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'key.identifier.azcli'),
          TR.IRelaxedToken(2, 'string.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// some text',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'APP_ID\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.azcli'),
        ],
      ),
    ],
  ]);
}

