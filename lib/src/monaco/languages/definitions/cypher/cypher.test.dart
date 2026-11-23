// Generated 1:1 from languages/definitions/cypher/cypher.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('cypher')
void runLanguagesDefinitionsCypherCypherTestCases() {
  TR.testTokenization('cypher', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '// Single line comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'MATCH /* comment part */ xyz',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.cypher'),
          TR.IRelaxedToken(5, 'white.cypher'),
          TR.IRelaxedToken(6, 'comment.cypher'),
          TR.IRelaxedToken(24, 'white.cypher'),
          TR.IRelaxedToken(25, 'identifier.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* multi line comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cypher'),
        ],
      ),
      TR.ITestItem(
        'comment continues MATCH // not done yet',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cypher'),
        ],
      ),
      TR.ITestItem(
        'comment ends */ MATCH',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cypher'),
          TR.IRelaxedToken(15, 'white.cypher'),
          TR.IRelaxedToken(16, 'keyword.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '13',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-40000',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3.14',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.314',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-.314',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '6.022E23',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-6.022e23',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '12E10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '12e10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '12e-10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '12E-10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x13af',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xFC3A9',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-0x66eff',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '01372',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '02127',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-05671',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"two \'words\'"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"two \\"words\\""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'two "words"\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'two \\\'words\\\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`variable`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.escape.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`A variable with weird stuff in it[]!`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.escape.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`Escaped \\`variable\\``',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.escape.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1+2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cypher'),
          TR.IRelaxedToken(1, 'delimiter.cypher'),
          TR.IRelaxedToken(2, 'number.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1++2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cypher'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(3, 'number.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'true',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'predefined.literal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'false',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'predefined.literal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'TRUE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'predefined.literal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'FALSE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'predefined.literal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'null',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'predefined.literal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'NULL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'predefined.literal.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'properties(node)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'predefined.function.cypher'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.cypher'),
          TR.IRelaxedToken(11, 'identifier.cypher'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'left(right("Hello Cypher"))',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'predefined.function.cypher'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.cypher'),
          TR.IRelaxedToken(5, 'predefined.function.cypher'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.cypher'),
          TR.IRelaxedToken(11, 'string.cypher'),
          TR.IRelaxedToken(25, 'delimiter.parenthesis.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'MATCH (n) RETURN n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.cypher'),
          TR.IRelaxedToken(5, 'white.cypher'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.cypher'),
          TR.IRelaxedToken(7, 'identifier.cypher'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.cypher'),
          TR.IRelaxedToken(9, 'white.cypher'),
          TR.IRelaxedToken(10, 'keyword.cypher'),
          TR.IRelaxedToken(16, 'white.cypher'),
          TR.IRelaxedToken(17, 'identifier.cypher'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(n:NodeLabel1)-[:RelationshipType]->(:NodeLabel2:NodeLabel3)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.parenthesis.cypher'),
          TR.IRelaxedToken(1, 'identifier.cypher'),
          TR.IRelaxedToken(2, 'type.identifier.cypher'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.cypher'),
          TR.IRelaxedToken(14, 'delimiter.cypher'),
          TR.IRelaxedToken(15, 'delimiter.bracket.cypher'),
          TR.IRelaxedToken(16, 'type.identifier.cypher'),
          TR.IRelaxedToken(33, 'delimiter.bracket.cypher'),
          TR.IRelaxedToken(34, 'delimiter.cypher'),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.cypher'),
          TR.IRelaxedToken(37, 'type.identifier.cypher'),
          TR.IRelaxedToken(59, 'delimiter.parenthesis.cypher'),
        ],
      ),
    ],
  ]);
}

