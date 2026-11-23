// Generated 1:1 from languages/definitions/typespec/typespec.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('typespec')
void runLanguagesDefinitionsTypespecTypespecTestCases() {
  TR.testTokenization('typespec', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'import "@typespec/http";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.tsp'),
          TR.IRelaxedToken(23, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'using TypeSpec.Http',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.tsp'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.tsp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'namespace Foo {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.tsp'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'namespace Foo {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.tsp'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
      TR.ITestItem(
        '    model Bar {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.tsp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.tsp'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'model Foo {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.tsp'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'model Foo is Bar;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.tsp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.tsp'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.tsp'),
          TR.IRelaxedToken(16, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'model Foo extends Bar;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.tsp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.tsp'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'identifier.tsp'),
          TR.IRelaxedToken(21, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'interface Foo {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.tsp'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'union Foo {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.tsp'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'scalar foo extends string;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.tsp'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.tsp'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'identifier.tsp'),
          TR.IRelaxedToken(25, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'op test(): void;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'identifier.tsp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(11, 'keyword.tsp'),
          TR.IRelaxedToken(15, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'enum Direction { up, down }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.tsp'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(17, 'identifier.tsp'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(21, 'identifier.tsp'),
          TR.IRelaxedToken(25, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'alias Foo = "a" | "b";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.tsp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(12, 'string.tsp'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(18, 'string.tsp'),
          TR.IRelaxedToken(21, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'alias T =  """',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tsp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.tsp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(11, 'string.tsp'),
        ],
      ),
      TR.ITestItem(
        '  this',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.tsp'),
        ],
      ),
      TR.ITestItem(
        '  is',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.tsp'),
        ],
      ),
      TR.ITestItem(
        '  multiline',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.tsp'),
        ],
      ),
      TR.ITestItem(
        '  """',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.tsp'),
        ],
      ),
    ],
  ]);
}

