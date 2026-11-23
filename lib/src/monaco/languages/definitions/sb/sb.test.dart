// Generated 1:1 from languages/definitions/sb/sb.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('sb')
void runLanguagesDefinitionsSbSbTestCases() {
  TR.testTokenization('sb', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    \' a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\' a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 \' 2< \' comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sb'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'comment.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x=1 \' my comment \'\' is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.name.sb'),
          TR.IRelaxedToken(1, 'operator.sb'),
          TR.IRelaxedToken(2, 'number.sb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 -0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sb'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.sb'),
          TR.IRelaxedToken(3, 'number.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sb'),
          TR.IRelaxedToken(3, 'operator.sb'),
          TR.IRelaxedToken(4, 'number.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sb'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.sb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'For i = 0 To 10 Step 2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.for.sb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'variable.name.sb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.sb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.sb'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.to.sb'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'number.sb'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'keyword.step.sb'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'number.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'if x <> 23.7 thEn',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.if.sb'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'variable.name.sb'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'operator.sb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.float.sb'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.then.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'ElseIf b[i] And col Then',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.elseif.sb'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'variable.name.sb'),
          TR.IRelaxedToken(8, 'delimiter.array.sb'),
          TR.IRelaxedToken(9, 'variable.name.sb'),
          TR.IRelaxedToken(10, 'delimiter.array.sb'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'operator.sb'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'variable.name.sb'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'keyword.then.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'GoTo location',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.goto.sb'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'variable.name.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        's = "string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.name.sb'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.sb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"use strict";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sb'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'sub ToString',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sub.sb'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'variable.name.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'While For If Sub EndWhile EndFor EndIf endsub',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.while.sb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.for.sb'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.if.sb'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.sub.sb'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'keyword.endwhile.sb'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'keyword.endfor.sb'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'keyword.endif.sb'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'keyword.endsub.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'While while WHILE WHile whiLe',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.while.sb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.while.sb'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'keyword.while.sb'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'keyword.while.sb'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'keyword.while.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Else TextWindow.Write("text")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.else.sb'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'type.sb'),
          TR.IRelaxedToken(15, 'delimiter.sb'),
          TR.IRelaxedToken(16, 'type.member.sb'),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.sb'),
          TR.IRelaxedToken(22, 'string.sb'),
          TR.IRelaxedToken(28, 'delimiter.parenthesis.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'class.method (x, y)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.sb'),
          TR.IRelaxedToken(5, 'delimiter.sb'),
          TR.IRelaxedToken(6, 'type.member.sb'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.sb'),
          TR.IRelaxedToken(14, 'variable.name.sb'),
          TR.IRelaxedToken(15, 'delimiter.sb'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'variable.name.sb'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.sb'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'const = Math.PI',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.name.sb'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.sb'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'type.sb'),
          TR.IRelaxedToken(12, 'delimiter.sb'),
          TR.IRelaxedToken(13, 'type.member.sb'),
        ],
      ),
    ],
  ]);
}

