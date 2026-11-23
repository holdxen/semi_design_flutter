// Generated 1:1 from languages/definitions/graphql/graphql.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('graphql')
void runLanguagesDefinitionsGraphqlGraphqlTestCases() {
  TR.testTokenization('graphql', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'scalar Date',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.gql'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'type.identifier.gql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'schema { query: Query, mutation: Mutation subscription: Subscription }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.gql'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.curly.gql'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.gql'),
          TR.IRelaxedToken(14, 'operator.gql'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'type.identifier.gql'),
          TR.IRelaxedToken(21, 'delimiter.gql'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'keyword.gql'),
          TR.IRelaxedToken(31, 'operator.gql'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'type.identifier.gql'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'keyword.gql'),
          TR.IRelaxedToken(54, 'operator.gql'),
          TR.IRelaxedToken(55, ''),
          TR.IRelaxedToken(56, 'type.identifier.gql'),
          TR.IRelaxedToken(68, ''),
          TR.IRelaxedToken(69, 'delimiter.curly.gql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'query testQuery(\$intValue:Int=3){value(arg:{string:"string" int:\$intValue}){field1 field2}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.gql'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'key.identifier.gql'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.gql'),
          TR.IRelaxedToken(16, 'argument.identifier.gql'),
          TR.IRelaxedToken(25, 'operator.gql'),
          TR.IRelaxedToken(26, 'keyword.gql'),
          TR.IRelaxedToken(29, 'operator.gql'),
          TR.IRelaxedToken(30, 'number.gql'),
          TR.IRelaxedToken(31, 'delimiter.parenthesis.gql'),
          TR.IRelaxedToken(32, 'delimiter.curly.gql'),
          TR.IRelaxedToken(33, 'key.identifier.gql'),
          TR.IRelaxedToken(38, 'delimiter.parenthesis.gql'),
          TR.IRelaxedToken(39, 'key.identifier.gql'),
          TR.IRelaxedToken(42, 'operator.gql'),
          TR.IRelaxedToken(43, 'delimiter.curly.gql'),
          TR.IRelaxedToken(44, 'key.identifier.gql'),
          TR.IRelaxedToken(50, 'operator.gql'),
          TR.IRelaxedToken(51, 'string.quote.gql'),
          TR.IRelaxedToken(52, 'string.gql'),
          TR.IRelaxedToken(58, 'string.quote.gql'),
          TR.IRelaxedToken(59, ''),
          TR.IRelaxedToken(60, 'key.identifier.gql'),
          TR.IRelaxedToken(63, 'operator.gql'),
          TR.IRelaxedToken(64, 'argument.identifier.gql'),
          TR.IRelaxedToken(73, 'delimiter.curly.gql'),
          TR.IRelaxedToken(74, 'delimiter.parenthesis.gql'),
          TR.IRelaxedToken(75, 'delimiter.curly.gql'),
          TR.IRelaxedToken(76, 'key.identifier.gql'),
          TR.IRelaxedToken(82, ''),
          TR.IRelaxedToken(83, 'key.identifier.gql'),
          TR.IRelaxedToken(89, 'delimiter.curly.gql'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.gql'),
        ],
      ),
      TR.ITestItem(
        'This is MarkDown',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.gql'),
        ],
      ),
      TR.ITestItem(
        'interface Node {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.gql'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'type.identifier.gql'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.curly.gql'),
        ],
      ),
      TR.ITestItem(
        '  id: ID!',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'key.identifier.gql'),
          TR.IRelaxedToken(4, 'operator.gql'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.gql'),
          TR.IRelaxedToken(8, 'operator.gql'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.gql'),
        ],
      ),
    ],
  ]);
}

