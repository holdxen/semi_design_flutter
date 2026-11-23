// Generated 1:1 from languages/definitions/perl/perl.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('perl')
void runLanguagesDefinitionsPerlPerlTestCases() {
  TR.testTokenization('perl', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'if \$msg',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.perl'),
          TR.IRelaxedToken(2, 'white.perl'),
          TR.IRelaxedToken(3, 'variable.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'log \$ARGV',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.perl'),
          TR.IRelaxedToken(3, 'white.perl'),
          TR.IRelaxedToken(4, 'variable.predefined.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#!/bin/env perl',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    # a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.perl'),
          TR.IRelaxedToken(4, 'comment.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.perl'),
          TR.IRelaxedToken(1, 'operators.perl'),
          TR.IRelaxedToken(2, 'number.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.perl'),
          TR.IRelaxedToken(3, 'operators.perl'),
          TR.IRelaxedToken(4, 'number.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.perl'),
          TR.IRelaxedToken(1, 'white.perl'),
          TR.IRelaxedToken(2, 'operators.perl'),
          TR.IRelaxedToken(3, 'white.perl'),
          TR.IRelaxedToken(4, 'number.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"test \$foo"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
          TR.IRelaxedToken(6, 'variable.perl'),
          TR.IRelaxedToken(10, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"test',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'string \$foo string2"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
          TR.IRelaxedToken(7, 'variable.perl'),
          TR.IRelaxedToken(11, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"string\\t"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
          TR.IRelaxedToken(7, 'string.escape.perl'),
          TR.IRelaxedToken(9, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'string\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'test \$foo\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'test',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'string \$foo string2\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'string\\t\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'string\\\'string2\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.perl'),
          TR.IRelaxedToken(7, 'string.escape.perl'),
          TR.IRelaxedToken(9, 'string.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$msg \$_ \$1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.perl'),
          TR.IRelaxedToken(4, 'white.perl'),
          TR.IRelaxedToken(5, 'variable.predefined.perl'),
          TR.IRelaxedToken(7, 'white.perl'),
          TR.IRelaxedToken(8, 'variable.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@array1 @array2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.perl'),
          TR.IRelaxedToken(7, 'white.perl'),
          TR.IRelaxedToken(8, 'variable.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '%var1 %var2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.perl'),
          TR.IRelaxedToken(5, 'white.perl'),
          TR.IRelaxedToken(6, 'variable.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/abc/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'm/abc/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.delim.perl'),
          TR.IRelaxedToken(2, 'regexp.perl'),
          TR.IRelaxedToken(5, 'regexp.delim.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'm/[abc]+/e',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.delim.perl'),
          TR.IRelaxedToken(2, 'regexp.perl'),
          TR.IRelaxedToken(8, 'regexp.delim.perl'),
          TR.IRelaxedToken(9, 'regexp.modifier.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$a + \$b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.perl'),
          TR.IRelaxedToken(2, 'white.perl'),
          TR.IRelaxedToken(3, 'operators.perl'),
          TR.IRelaxedToken(4, 'white.perl'),
          TR.IRelaxedToken(5, 'variable.predefined.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '=begin',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.perl'),
        ],
      ),
      TR.ITestItem(
        'this is my doc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.perl'),
        ],
      ),
      TR.ITestItem(
        '=cut',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<< HTML',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.delimiter.perl'),
        ],
      ),
      TR.ITestItem(
        'test here doc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.perl'),
        ],
      ),
      TR.ITestItem(
        'HTML',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.delimiter.perl'),
        ],
      ),
      TR.ITestItem(
        'my \$msg',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.perl'),
          TR.IRelaxedToken(2, 'white.perl'),
          TR.IRelaxedToken(3, 'variable.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<<"HTML"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.delimiter.perl'),
        ],
      ),
      TR.ITestItem(
        'test here doc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.perl'),
        ],
      ),
      TR.ITestItem(
        'HTML',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.delimiter.perl'),
        ],
      ),
      TR.ITestItem(
        'my \$msg',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.perl'),
          TR.IRelaxedToken(2, 'white.perl'),
          TR.IRelaxedToken(3, 'variable.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'm!can\'t!',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.delim.perl'),
          TR.IRelaxedToken(2, 'regexp.perl'),
          TR.IRelaxedToken(7, 'regexp.delim.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'q XfooX',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delim.perl'),
          TR.IRelaxedToken(3, 'string.perl'),
          TR.IRelaxedToken(6, 'string.delim.perl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'qq(test \$foo)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delim.perl'),
          TR.IRelaxedToken(3, 'string.perl'),
          TR.IRelaxedToken(8, 'variable.perl'),
          TR.IRelaxedToken(12, 'string.delim.perl'),
        ],
      ),
    ],
  ]);
}

