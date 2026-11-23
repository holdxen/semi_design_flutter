// Generated 1:1 from languages/definitions/julia/julia.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('julia')
void runLanguagesDefinitionsJuliaJuliaTestCases() {
  TR.testTokenization('julia', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'a = 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.julia'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'source.julia'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.julia'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'b(c) = 2c',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.flow.julia'),
          TR.IRelaxedToken(1, 'delimiter.parenthesis.julia'),
          TR.IRelaxedToken(2, 'identifier.julia'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.julia'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'source.julia'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.julia'),
          TR.IRelaxedToken(8, 'identifier.julia'),
        ],
      ),
    ],
  ]);
}

