// Generated 1:1 from languages/definitions/bat/bat.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('bat')
void runLanguagesDefinitionsBatBatTestCases() {
  TR.testTokenization('bat', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '@echo off title Selfhost',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bat'),
          TR.IRelaxedToken(1, 'keyword.echo.bat'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(10, 'keyword.title.bat'),
          TR.IRelaxedToken(15, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'REM',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    REM a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'REM a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'REMnot a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.bat'),
          TR.IRelaxedToken(1, 'delimiter.bat'),
          TR.IRelaxedToken(2, 'number.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.bat'),
          TR.IRelaxedToken(3, 'delimiter.bat'),
          TR.IRelaxedToken(4, 'number.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.bat'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.bat'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'set s = "string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.set.bat'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.bat'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"use strict";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.bat'),
          TR.IRelaxedToken(12, 'delimiter.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'setlocal endlocal',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-setlocal.bat'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.tag-setlocal.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'setlocal ENDLOCAL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-setlocal.bat'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.tag-setlocal.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'SETLOCAL endlocal',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-setlocal.bat'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.tag-setlocal.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'setlocal setlocal endlocal',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-setlocal.bat'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.tag-setlocal.bat'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'keyword.tag-setlocal.bat'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'rem asdf',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bat'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'REM',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bat'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'REMOVED not a comment really',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'keyword.not.bat'),
          TR.IRelaxedToken(11, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'echo cool',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.echo.bat'),
          TR.IRelaxedToken(4, ''),
        ],
      ),
      TR.ITestItem(
        '@echo off',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bat'),
          TR.IRelaxedToken(1, 'keyword.echo.bat'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'setlocAL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-setlocal.bat'),
        ],
      ),
      TR.ITestItem(
        '\tasdf',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\tasdf',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        'endLocaL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tag-setlocal.bat'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'call',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.call.bat'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        ':MyLabel',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.bat'),
        ],
      ),
      TR.ITestItem(
        'some command',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '%sdfsdf% ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.bat'),
          TR.IRelaxedToken(8, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'this is "a string %sdf% asdf"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'string.bat'),
          TR.IRelaxedToken(18, 'variable.bat'),
          TR.IRelaxedToken(23, 'string.bat'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'FOR %%A IN (1 2 3) DO (',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.for.bat'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'variable.bat'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.bat'),
          TR.IRelaxedToken(12, 'number.bat'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.bat'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'number.bat'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.bat'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.bat'),
        ],
      ),
      TR.ITestItem(
        '\tSET VAR1=%VAR1%%%A',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.set.bat'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(9, 'delimiter.bat'),
          TR.IRelaxedToken(10, 'variable.bat'),
        ],
      ),
      TR.ITestItem(
        '\tSET VAR2=%VAR2%%%A',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.set.bat'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(9, 'delimiter.bat'),
          TR.IRelaxedToken(10, 'variable.bat'),
        ],
      ),
      TR.ITestItem(
        '\tuse \'string %%a asdf asdf\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'string.bat'),
          TR.IRelaxedToken(13, 'variable.bat'),
          TR.IRelaxedToken(16, 'string.bat'),
        ],
      ),
      TR.ITestItem(
        '\tnon terminated "string %%aaa sdf',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(16, 'string.bat'),
          TR.IRelaxedToken(24, 'variable.bat'),
          TR.IRelaxedToken(29, 'string.bat'),
        ],
      ),
      TR.ITestItem(
        '\tthis shold NOT BE red',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(12, 'keyword.not.bat'),
          TR.IRelaxedToken(15, ''),
        ],
      ),
      TR.ITestItem(
        ')',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.parenthesis.bat'),
        ],
      ),
    ],
  ]);
}

