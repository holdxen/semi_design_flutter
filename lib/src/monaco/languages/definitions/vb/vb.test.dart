// Generated 1:1 from languages/definitions/vb/vb.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('vb')
void runLanguagesDefinitionsVbVbTestCases() {
  TR.testTokenization('vb', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    \' a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\' a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 \' 2; \' comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.vb'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'comment.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Dim x = 1; \' my comment \'\' is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dim.vb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.vb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.vb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.vb'),
          TR.IRelaxedToken(9, 'delimiter.vb'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'REM this is a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2 + 5 REM comment starts',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.vb'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.vb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.vb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '&h123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5r',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3r',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3r',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3r',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5R',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5r',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3!',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.vb'),
          TR.IRelaxedToken(1, 'delimiter.vb'),
          TR.IRelaxedToken(2, 'number.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.vb'),
          TR.IRelaxedToken(3, 'delimiter.vb'),
          TR.IRelaxedToken(4, 'number.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.vb'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.vb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Imports Microsoft.VisualBasic',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.imports.vb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.vb'),
          TR.IRelaxedToken(17, 'delimiter.vb'),
          TR.IRelaxedToken(18, 'identifier.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Private Sub Foo(ByVal sender As String)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.private.vb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.tag-sub.vb'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.vb'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.vb'),
          TR.IRelaxedToken(16, 'keyword.byval.vb'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'identifier.vb'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'keyword.as.vb'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'keyword.string.vb'),
          TR.IRelaxedToken(38, 'delimiter.parenthesis.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = "string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.string.vb'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.vb'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.vb'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.quote.vb'),
          TR.IRelaxedToken(12, 'string.vb'),
          TR.IRelaxedToken(18, 'string.quote.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"use strict";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(11, 'string.quote.vb'),
          TR.IRelaxedToken(12, 'delimiter.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a""b"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(2, 'string.escape.vb'),
          TR.IRelaxedToken(4, 'string.vb'),
          TR.IRelaxedToken(5, 'string.quote.vb'),
        ],
      ),
      TR.ITestItem(
        '"a““b"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(2, 'string.escape.vb'),
          TR.IRelaxedToken(4, 'string.vb'),
          TR.IRelaxedToken(5, 'string.quote.vb'),
        ],
      ),
      TR.ITestItem(
        '"a””b"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(2, 'string.escape.vb'),
          TR.IRelaxedToken(4, 'string.vb'),
          TR.IRelaxedToken(5, 'string.quote.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"mixed quotes 1“',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(15, 'string.quote.vb'),
        ],
      ),
      TR.ITestItem(
        '"mixed quotes 2”',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(15, 'string.quote.vb'),
        ],
      ),
      TR.ITestItem(
        '“mixed quotes 3"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(15, 'string.quote.vb'),
        ],
      ),
      TR.ITestItem(
        '“mixed quotes 4”',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(15, 'string.quote.vb'),
        ],
      ),
      TR.ITestItem(
        '”mixed quotes 5"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(15, 'string.quote.vb'),
        ],
      ),
      TR.ITestItem(
        '”mixed quotes 6“',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.vb'),
          TR.IRelaxedToken(1, 'string.vb'),
          TR.IRelaxedToken(15, 'string.quote.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Public Sub ToString()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.public.vb'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.tag-sub.vb'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'identifier.vb'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'public sub ToString()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.public.vb'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.tag-sub.vb'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'identifier.vb'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'While Do Continue While End While',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-while.vb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.tag-do.vb'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.tag-continue.vb'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'keyword.tag-while.vb'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'keyword.tag-while.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'While while WHILE WHile whiLe',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-while.vb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.tag-while.vb'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'keyword.tag-while.vb'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'keyword.tag-while.vb'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'keyword.tag-while.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'If b(i) = col Then',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-if.vb'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'identifier.vb'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.vb'),
          TR.IRelaxedToken(5, 'identifier.vb'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.vb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.vb'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.vb'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.then.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Do stuff While True Loop',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-do.vb'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'identifier.vb'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.tag-while.vb'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'keyword.true.vb'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'keyword.tag-do.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'For i = 0 To 10 DoStuff Next',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-for.vb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.vb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.vb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.vb'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.to.vb'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'number.vb'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.vb'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'keyword.tag-for.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'For stuff End For',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-for.vb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.vb'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.end.vb'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.tag-for.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'For stuff end for',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-for.vb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.vb'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.end.vb'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.tag-for.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Dim x = "hello',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dim.vb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.vb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.vb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.quote.vb'),
          TR.IRelaxedToken(9, 'string.vb'),
        ],
      ),
      TR.ITestItem(
        'world"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.vb'),
          TR.IRelaxedToken(5, 'string.quote.vb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'End qweqweqweqweqwe\'here always becomes highlighted Loop ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.end.vb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.vb'),
          TR.IRelaxedToken(19, 'comment.vb'),
        ],
      ),
    ],
  ]);
}

