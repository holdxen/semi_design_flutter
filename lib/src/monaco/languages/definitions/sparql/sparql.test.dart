// Generated 1:1 from languages/definitions/sparql/sparql.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('sparql')
void runLanguagesDefinitionsSparqlSparqlTestCases() {
  TR.testTokenization('sparql', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '# a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '##sticky # comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"lex"^^<https://test/ns#not-a-comment>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sql.rq'),
          TR.IRelaxedToken(5, 'operator.sql.rq'),
          TR.IRelaxedToken(7, 'tag.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(?x ns:p "abc")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.parenthesis.rq'),
          TR.IRelaxedToken(1, 'identifier.rq'),
          TR.IRelaxedToken(3, 'white.rq'),
          TR.IRelaxedToken(4, 'tag.rq'),
          TR.IRelaxedToken(8, 'white.rq'),
          TR.IRelaxedToken(9, 'string.sql.rq'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'escaped single-quote: \\\', normal double-quote: "\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sql.rq'),
          TR.IRelaxedToken(23, 'string.escape.rq'),
          TR.IRelaxedToken(25, 'string.sql.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '("escaped \\" and \\\' and also not escaped \'.")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.parenthesis.rq'),
          TR.IRelaxedToken(1, 'string.sql.rq'),
          TR.IRelaxedToken(10, 'string.escape.rq'),
          TR.IRelaxedToken(12, 'string.sql.rq'),
          TR.IRelaxedToken(17, 'string.escape.rq'),
          TR.IRelaxedToken(19, 'string.sql.rq'),
          TR.IRelaxedToken(44, 'delimiter.parenthesis.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'Invalid single string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.invalid.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"Invalid double string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.invalid.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'PREFIX a: <http://www.w3.org/2000/10/annotation-ns#>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rq'),
          TR.IRelaxedToken(6, 'white.rq'),
          TR.IRelaxedToken(7, 'tag.rq'),
          TR.IRelaxedToken(9, 'white.rq'),
          TR.IRelaxedToken(10, 'tag.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'SELECT DISTINCT ?name ?nick',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rq'),
          TR.IRelaxedToken(6, 'white.rq'),
          TR.IRelaxedToken(7, 'keyword.rq'),
          TR.IRelaxedToken(15, 'white.rq'),
          TR.IRelaxedToken(16, 'identifier.rq'),
          TR.IRelaxedToken(21, 'white.rq'),
          TR.IRelaxedToken(22, 'identifier.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(BGP [triple ?x foaf:nick ?nick])',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.parenthesis.rq'),
          TR.IRelaxedToken(1, 'identifier.rq'),
          TR.IRelaxedToken(4, 'white.rq'),
          TR.IRelaxedToken(5, 'delimiter.square.rq'),
          TR.IRelaxedToken(6, 'identifier.rq'),
          TR.IRelaxedToken(12, 'white.rq'),
          TR.IRelaxedToken(13, 'identifier.rq'),
          TR.IRelaxedToken(15, 'white.rq'),
          TR.IRelaxedToken(16, 'tag.rq'),
          TR.IRelaxedToken(25, 'white.rq'),
          TR.IRelaxedToken(26, 'identifier.rq'),
          TR.IRelaxedToken(31, 'delimiter.square.rq'),
          TR.IRelaxedToken(32, 'delimiter.parenthesis.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'SELECT*{ GRAPH :g1 { ?x } }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rq'),
          TR.IRelaxedToken(6, 'operator.sql.rq'),
          TR.IRelaxedToken(7, 'delimiter.curly.rq'),
          TR.IRelaxedToken(8, 'white.rq'),
          TR.IRelaxedToken(9, 'keyword.rq'),
          TR.IRelaxedToken(14, 'white.rq'),
          TR.IRelaxedToken(15, 'tag.rq'),
          TR.IRelaxedToken(18, 'white.rq'),
          TR.IRelaxedToken(19, 'delimiter.curly.rq'),
          TR.IRelaxedToken(20, 'white.rq'),
          TR.IRelaxedToken(21, 'identifier.rq'),
          TR.IRelaxedToken(23, 'white.rq'),
          TR.IRelaxedToken(24, 'delimiter.curly.rq'),
          TR.IRelaxedToken(25, 'white.rq'),
          TR.IRelaxedToken(26, 'delimiter.curly.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'FILTER isBlank(?c)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rq'),
          TR.IRelaxedToken(6, 'white.rq'),
          TR.IRelaxedToken(7, 'predefined.sql.rq'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.rq'),
          TR.IRelaxedToken(15, 'identifier.rq'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.rq'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"text"@en',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sql.rq'),
          TR.IRelaxedToken(6, 'metatag.html.rq'),
        ],
      ),
    ],
  ]);
}

