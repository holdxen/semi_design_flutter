// Generated 1:1 from languages/definitions/st/st.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('st')
void runLanguagesDefinitionsStStTestCases() {
  TR.testTokenization('st', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'xVar : BOOL;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.st'),
          TR.IRelaxedToken(4, 'white.st'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'white.st'),
          TR.IRelaxedToken(7, 'type.st'),
          TR.IRelaxedToken(11, 'delimiter.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'xStart AT %IX0.0.1: BOOL := TRUE;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.st'),
          TR.IRelaxedToken(6, 'white.st'),
          TR.IRelaxedToken(7, 'keyword.st'),
          TR.IRelaxedToken(9, 'white.st'),
          TR.IRelaxedToken(10, 'tag.st'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'white.st'),
          TR.IRelaxedToken(20, 'type.st'),
          TR.IRelaxedToken(24, 'white.st'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(27, 'white.st'),
          TR.IRelaxedToken(28, 'constant.st'),
          TR.IRelaxedToken(32, 'delimiter.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'IF a > 2#0000_0110 THEN (* Something \' happens *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.st'),
          TR.IRelaxedToken(2, 'white.st'),
          TR.IRelaxedToken(3, 'identifier.st'),
          TR.IRelaxedToken(4, 'white.st'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'white.st'),
          TR.IRelaxedToken(7, 'number.binary.st'),
          TR.IRelaxedToken(18, 'white.st'),
          TR.IRelaxedToken(19, 'keyword.st'),
          TR.IRelaxedToken(23, 'white.st'),
          TR.IRelaxedToken(24, 'comment.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'TON1(IN := TRUE, PT := T#20ms, Q => xStart); // Run timer',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.st'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.st'),
          TR.IRelaxedToken(5, 'identifier.st'),
          TR.IRelaxedToken(7, 'white.st'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(10, 'white.st'),
          TR.IRelaxedToken(11, 'constant.st'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'white.st'),
          TR.IRelaxedToken(17, 'identifier.st'),
          TR.IRelaxedToken(19, 'white.st'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(22, 'white.st'),
          TR.IRelaxedToken(23, 'tag.st'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'white.st'),
          TR.IRelaxedToken(31, 'identifier.st'),
          TR.IRelaxedToken(32, 'white.st'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(35, 'white.st'),
          TR.IRelaxedToken(36, 'identifier.st'),
          TR.IRelaxedToken(42, 'delimiter.parenthesis.st'),
          TR.IRelaxedToken(43, 'delimiter.st'),
          TR.IRelaxedToken(44, 'white.st'),
          TR.IRelaxedToken(45, 'comment.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2#000_0101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '16#0f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.st'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.st'),
        ],
      ),
    ],
  ]);
}

