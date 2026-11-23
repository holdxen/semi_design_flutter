// Generated 1:1 from languages/definitions/shell/shell.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('shell')
void runLanguagesDefinitionsShellShellTestCases() {
  TR.testTokenization('shell', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'if while',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.shell'),
          TR.IRelaxedToken(2, 'white.shell'),
          TR.IRelaxedToken(3, 'keyword.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'ps -aux | grep code',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.shell'),
          TR.IRelaxedToken(2, 'white.shell'),
          TR.IRelaxedToken(3, 'attribute.name.shell'),
          TR.IRelaxedToken(7, 'white.shell'),
          TR.IRelaxedToken(8, 'delimiter.shell'),
          TR.IRelaxedToken(9, 'white.shell'),
          TR.IRelaxedToken(10, 'type.identifier.shell'),
          TR.IRelaxedToken(14, 'white.shell'),
          TR.IRelaxedToken(15, ''),
        ],
      ),
      TR.ITestItem(
        'foo-bar --baz gorp -123 --abc-123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'white.shell'),
          TR.IRelaxedToken(8, 'attribute.name.shell'),
          TR.IRelaxedToken(13, 'white.shell'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(18, 'white.shell'),
          TR.IRelaxedToken(19, 'attribute.name.shell'),
          TR.IRelaxedToken(23, 'white.shell'),
          TR.IRelaxedToken(24, 'attribute.name.shell'),
        ],
      ),
      TR.ITestItem(
        'foo | foo-bar | foo-bar-1 | foo-bar-2021-1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'white.shell'),
          TR.IRelaxedToken(4, 'delimiter.shell'),
          TR.IRelaxedToken(5, 'white.shell'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(13, 'white.shell'),
          TR.IRelaxedToken(14, 'delimiter.shell'),
          TR.IRelaxedToken(15, 'white.shell'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(25, 'white.shell'),
          TR.IRelaxedToken(26, 'delimiter.shell'),
          TR.IRelaxedToken(27, 'white.shell'),
          TR.IRelaxedToken(28, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.shell'),
        ],
      ),
      TR.ITestItem(
        'cd tree',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.shell'),
          TR.IRelaxedToken(2, 'white.shell'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#!/bin/env bash',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    # a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.shell'),
          TR.IRelaxedToken(4, 'comment.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.shell'),
          TR.IRelaxedToken(1, 'delimiter.shell'),
          TR.IRelaxedToken(2, 'number.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.shell'),
          TR.IRelaxedToken(3, 'delimiter.shell'),
          TR.IRelaxedToken(4, 'number.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.shell'),
          TR.IRelaxedToken(1, 'white.shell'),
          TR.IRelaxedToken(2, 'delimiter.shell'),
          TR.IRelaxedToken(3, 'white.shell'),
          TR.IRelaxedToken(4, 'number.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'test string\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"test string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'test',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.shell'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'string\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"test',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.shell'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\${string:position}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.shell'),
          TR.IRelaxedToken(8, 'delimiter.shell'),
          TR.IRelaxedToken(9, 'variable.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$(pwd)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'echo \$hello | less',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.shell'),
          TR.IRelaxedToken(4, 'white.shell'),
          TR.IRelaxedToken(5, 'variable.shell'),
          TR.IRelaxedToken(11, 'white.shell'),
          TR.IRelaxedToken(12, 'delimiter.shell'),
          TR.IRelaxedToken(13, 'white.shell'),
          TR.IRelaxedToken(14, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<< word',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'constants.shell'),
          TR.IRelaxedToken(2, 'white.shell'),
          TR.IRelaxedToken(3, 'string.heredoc.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<<- "word"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'constants.shell'),
          TR.IRelaxedToken(3, 'white.shell'),
          TR.IRelaxedToken(4, 'string.heredoc.delimiter.shell'),
          TR.IRelaxedToken(5, 'string.heredoc.shell'),
          TR.IRelaxedToken(9, 'string.heredoc.delimiter.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<<< word',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'constants.shell'),
          TR.IRelaxedToken(3, 'white.shell'),
          TR.IRelaxedToken(4, 'string.heredoc.shell'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'echo \$( echo "hi" )',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.shell'),
          TR.IRelaxedToken(4, 'white.shell'),
          TR.IRelaxedToken(5, 'variable.shell'),
        ],
      ),
    ],
  ]);
}

