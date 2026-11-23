// Generated 1:1 from languages/definitions/pascal/pascal.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('pascal')
void runLanguagesDefinitionsPascalPascalTestCases() {
  TR.testTokenization('pascal', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.pascal'),
          TR.IRelaxedToken(4, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    { a comment }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.pascal'),
          TR.IRelaxedToken(4, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{ a comment }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{sticky comment}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{ start of multiline comment ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
      TR.ITestItem(
        'a comment between curly',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'program Test; begin writeln(\'hello\'); end.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.program.pascal'),
          TR.IRelaxedToken(7, 'white.pascal'),
          TR.IRelaxedToken(8, 'identifier.pascal'),
          TR.IRelaxedToken(12, 'delimiter.pascal'),
          TR.IRelaxedToken(13, 'white.pascal'),
          TR.IRelaxedToken(14, 'keyword.begin.pascal'),
          TR.IRelaxedToken(19, 'white.pascal'),
          TR.IRelaxedToken(20, 'identifier.pascal'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.pascal'),
          TR.IRelaxedToken(28, 'string.pascal'),
          TR.IRelaxedToken(34, 'string.quote.pascal'),
          TR.IRelaxedToken(35, 'delimiter.parenthesis.pascal'),
          TR.IRelaxedToken(36, 'delimiter.pascal'),
          TR.IRelaxedToken(37, 'white.pascal'),
          TR.IRelaxedToken(38, 'keyword.end.pascal'),
          TR.IRelaxedToken(41, 'delimiter.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.pascal'),
          TR.IRelaxedToken(1, 'delimiter.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2.4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2.4;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.pascal'),
          TR.IRelaxedToken(3, 'delimiter.pascal'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$123FF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.pascal'),
        ],
      ),
    ],
  ]);
}

