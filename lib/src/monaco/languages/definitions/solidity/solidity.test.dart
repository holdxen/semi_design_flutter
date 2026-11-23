// Generated 1:1 from languages/definitions/solidity/solidity.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('sol')
void runLanguagesDefinitionsSoliditySolidityTestCases() {
  TR.testTokenization('sol', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'pragma solidity ^0.4.0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pragma.sol'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.solidity.sol'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.sol'),
          TR.IRelaxedToken(17, 'number.float.sol'),
          TR.IRelaxedToken(22, 'delimiter.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'contract Ballot {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.contract.sol'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.sol'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.curly.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'struct Voter {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.struct.sol'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.sol'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.curly.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'address chairperson;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.address.sol'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.sol'),
          TR.IRelaxedToken(19, 'delimiter.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int weight;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.sol'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sol'),
          TR.IRelaxedToken(10, 'delimiter.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'mapping(address => Voter) voters;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mapping.sol'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.sol'),
          TR.IRelaxedToken(8, 'keyword.address.sol'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(19, 'identifier.sol'),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.sol'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'identifier.sol'),
          TR.IRelaxedToken(32, 'delimiter.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'function Ballot(uint8 _numProposals) {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.function.sol'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.sol'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.sol'),
          TR.IRelaxedToken(16, 'keyword.uint8.sol'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'identifier.sol'),
          TR.IRelaxedToken(35, 'delimiter.parenthesis.sol'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'delimiter.curly.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.sol'),
          TR.IRelaxedToken(1, 'identifier.sol'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.sol'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sol'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sol'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sol'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.sol'),
          TR.IRelaxedToken(5, 'delimiter.sol'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.sol'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sol'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.sol'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.sol'),
          TR.IRelaxedToken(9, 'delimiter.sol'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.sol'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sol'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.sol'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.sol'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.sol'),
          TR.IRelaxedToken(32, 'delimiter.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.sol'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sol'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.sol'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.sol'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.sol'),
          TR.IRelaxedToken(23, 'delimiter.sol'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sol'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sol'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.sol'),
          TR.IRelaxedToken(8, 'delimiter.sol'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sol'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sol'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.sol'),
        ],
      ),
    ],
  ]);
}

