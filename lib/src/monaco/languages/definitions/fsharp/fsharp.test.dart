// Generated 1:1 from languages/definitions/fsharp/fsharp.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('fsharp')
void runLanguagesDefinitionsFsharpFsharpTestCases() {
  TR.testTokenization('fsharp', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '// one line comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.fs'),
          TR.IRelaxedToken(1, 'identifier.fs'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.fs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(/*almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.parenthesis.fs'),
          TR.IRelaxedToken(1, 'delimiter.fs'),
          TR.IRelaxedToken(3, 'identifier.fs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.fs'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; (* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.fs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.fs'),
          TR.IRelaxedToken(5, 'delimiter.fs'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.fs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.fs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.fs'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.fs'),
          TR.IRelaxedToken(9, 'delimiter.fs'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'namespace Application1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.namespace.fs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'type MyType',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.type.fs'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'module App =',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.module.fs'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.fs'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let AppName = "App1"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.fs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.fs'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.fs'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'string.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* a simple comment *)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let x = (* a simple comment *) 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.let.fs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.fs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.fs'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.fs'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = (**)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.fs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.fs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = (*)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.fs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.fs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.fs'),
          TR.IRelaxedToken(5, 'delimiter.fs'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5M',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5m',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3M',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3m',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3M',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3m',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
          TR.IRelaxedToken(1, 'delimiter.fs'),
          TR.IRelaxedToken(2, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
          TR.IRelaxedToken(3, 'delimiter.fs'),
          TR.IRelaxedToken(4, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.fs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b00000101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.bin.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86y',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b00000101y',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.bin.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86s',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86us',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86u',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86ul',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x00002D3Fn',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x00002D3Fun',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '86UL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '9999999999999999999999999999I',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x00002D3FLF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.fs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(* This operator -> (*) should be ignored *) let i = 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.fs'),
          TR.IRelaxedToken(44, ''),
          TR.IRelaxedToken(45, 'keyword.let.fs'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(49, 'identifier.fs'),
          TR.IRelaxedToken(50, ''),
          TR.IRelaxedToken(51, 'delimiter.fs'),
          TR.IRelaxedToken(52, ''),
          TR.IRelaxedToken(53, 'number.fs'),
        ],
      ),
    ],
  ]);
}

