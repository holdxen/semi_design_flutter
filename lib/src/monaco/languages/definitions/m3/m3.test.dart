// Generated 1:1 from languages/definitions/m3/m3.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('m3')
void runLanguagesDefinitionsM3M3TestCases() {
  TR.testTokenization('m3', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '(**)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.m3'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    (* a comment *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.m3'),
          TR.IRelaxedToken(4, 'comment.m3'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* Lorem ipsum dolor sit amet, consectetur ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.m3'),
        ],
      ),
      TR.ITestItem(
        '   adipiscing elit, sed do eiusmod tempor',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.m3'),
        ],
      ),
      TR.ITestItem(
        '  incididunt ut labore et dolore magna aliqua. *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.m3'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* Lorem ipsum dolor sit amet (*, consectetur ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.m3'),
        ],
      ),
      TR.ITestItem(
        '   adipiscing elit, sed do eiusmod tempor',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.m3'),
        ],
      ),
      TR.ITestItem(
        '  incididunt*) ut labore et dolore magna aliqua. *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.m3'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'MODULE Test EXPORTS Main; FROM IO IMPORT Put; BEGIN Put("test\\n") END Test.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.MODULE.m3'),
          TR.IRelaxedToken(6, 'white.m3'),
          TR.IRelaxedToken(7, 'identifier.m3'),
          TR.IRelaxedToken(11, 'white.m3'),
          TR.IRelaxedToken(12, 'keyword.EXPORTS.m3'),
          TR.IRelaxedToken(19, 'white.m3'),
          TR.IRelaxedToken(20, 'identifier.m3'),
          TR.IRelaxedToken(24, 'delimiter.m3'),
          TR.IRelaxedToken(25, 'white.m3'),
          TR.IRelaxedToken(26, 'keyword.FROM.m3'),
          TR.IRelaxedToken(30, 'white.m3'),
          TR.IRelaxedToken(31, 'identifier.m3'),
          TR.IRelaxedToken(33, 'white.m3'),
          TR.IRelaxedToken(34, 'keyword.IMPORT.m3'),
          TR.IRelaxedToken(40, 'white.m3'),
          TR.IRelaxedToken(41, 'identifier.m3'),
          TR.IRelaxedToken(44, 'delimiter.m3'),
          TR.IRelaxedToken(45, 'white.m3'),
          TR.IRelaxedToken(46, 'keyword.BEGIN.m3'),
          TR.IRelaxedToken(51, 'white.m3'),
          TR.IRelaxedToken(52, 'identifier.m3'),
          TR.IRelaxedToken(55, 'delimiter.parenthesis.m3'),
          TR.IRelaxedToken(56, 'string.text.m3'),
          TR.IRelaxedToken(61, 'string.escape.m3'),
          TR.IRelaxedToken(63, 'string.text.m3'),
          TR.IRelaxedToken(64, 'delimiter.parenthesis.m3'),
          TR.IRelaxedToken(65, 'white.m3'),
          TR.IRelaxedToken(66, 'keyword.END.m3'),
          TR.IRelaxedToken(69, 'white.m3'),
          TR.IRelaxedToken(70, 'identifier.m3'),
          TR.IRelaxedToken(74, 'operators.m3'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.m3'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-16_B33f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operators.m3'),
          TR.IRelaxedToken(1, 'number.m3'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2.0D-5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.m3'),
        ],
      ),
    ],
  ]);
}

