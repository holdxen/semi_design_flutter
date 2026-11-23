// Generated 1:1 from languages/definitions/pascaligo/pascaligo.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('pascaligo')
void runLanguagesDefinitionsPascaligoPascaligoTestCases() {
  TR.testTokenization('pascaligo', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.pascaligo'),
          TR.IRelaxedToken(4, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(**)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    (* a comment *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.pascaligo'),
          TR.IRelaxedToken(4, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* a comment *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(*sticky comment*)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* start of multiline comment ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
      TR.ITestItem(
        'a comment between curly',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'function add (const a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.function.pascaligo'),
          TR.IRelaxedToken(8, 'white.pascaligo'),
          TR.IRelaxedToken(9, 'identifier.pascaligo'),
          TR.IRelaxedToken(12, 'white.pascaligo'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.pascaligo'),
          TR.IRelaxedToken(14, 'keyword.const.pascaligo'),
          TR.IRelaxedToken(19, 'white.pascaligo'),
          TR.IRelaxedToken(20, 'identifier.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.pascaligo'),
          TR.IRelaxedToken(1, 'delimiter.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2.4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2.4;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pascaligo'),
          TR.IRelaxedToken(3, 'delimiter.pascaligo'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$123FF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.pascaligo'),
        ],
      ),
    ],
  ]);
}

