// Generated 1:1 from languages/definitions/sophia/sophia.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('aes')
void runLanguagesDefinitionsSophiaSophiaTestCases() {
  TR.testTokenization('aes', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'contract HackBG =',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.contract.aes'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.aes'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'record state = { developers : list(developer) }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.record.aes'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.state.aes'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.aes'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.curly.aes'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'identifier.aes'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.aes'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'keyword.list.aes'),
          TR.IRelaxedToken(34, 'delimiter.parenthesis.aes'),
          TR.IRelaxedToken(35, 'identifier.aes'),
          TR.IRelaxedToken(44, 'delimiter.parenthesis.aes'),
          TR.IRelaxedToken(45, ''),
          TR.IRelaxedToken(46, 'delimiter.curly.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'record developer = {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.record.aes'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.aes'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.aes'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.curly.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'name : string,',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.aes'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.aes'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.string.aes'),
          TR.IRelaxedToken(13, 'delimiter.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'experience : int,',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.aes'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.aes'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.int.aes'),
          TR.IRelaxedToken(16, 'delimiter.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'skillset : list(string) }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.aes'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.aes'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.list.aes'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.aes'),
          TR.IRelaxedToken(16, 'keyword.string.aes'),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.aes'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'delimiter.curly.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'entrypoint init() = { developers = {} }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.entrypoint.aes'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'identifier.aes'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.aes'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.aes'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'delimiter.curly.aes'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'identifier.aes'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'delimiter.aes'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'delimiter.curly.aes'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'delimiter.curly.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.aes'),
          TR.IRelaxedToken(1, 'identifier.aes'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.aes'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.aes'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2 /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.aes'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.aes'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.aes'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let x : int = 1 // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.aes'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.aes'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.aes'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.int.aes'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.aes'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.aes'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'comment.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let x : int = /* a simple comment */ 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.aes'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.aes'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.aes'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.int.aes'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.aes'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'comment.aes'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'number.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let x = /* comment */ 1 */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.aes'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.aes'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.aes'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.aes'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.aes'),
          TR.IRelaxedToken(23, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let x = /**/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.aes'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.aes'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.aes'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.aes'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let x = /*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.aes'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.aes'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.aes'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.aes'),
        ],
      ),
    ],
  ]);
}

