// Generated 1:1 from languages/definitions/mips/mips.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('mips')
void runLanguagesDefinitionsMipsMipsTestCases() {
  TR.testTokenization('mips', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    # a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x, 1 # my comment # is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.mips'),
          TR.IRelaxedToken(2, 'delimiter.mips'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.mips'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x, 1e #is a exponent number',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.mips'),
          TR.IRelaxedToken(2, 'delimiter.mips'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.float.mips'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x, 0x1F #is a hex number',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.mips'),
          TR.IRelaxedToken(2, 'delimiter.mips'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.hex.mips'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'li \$r0, 5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.li.mips'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'variable.predefined.mips'),
          TR.IRelaxedToken(6, 'delimiter.mips'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.data # Data declaration',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword..data.mips'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'even_str: .asciiz "The number is even!" # Output string for even integer',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.mips'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(18, 'string.mips'),
          TR.IRelaxedToken(39, ''),
          TR.IRelaxedToken(40, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    add    ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.add.mips'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '### a simple comment ###',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'move \$x, ### a simple comment ### 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.move.mips'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'variable.predefined.mips'),
          TR.IRelaxedToken(7, 'delimiter.mips'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x ###/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.mips'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'comment.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.mips'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.mips'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '01239',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.mips'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1,2,3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.mips'),
          TR.IRelaxedToken(1, 'delimiter.mips'),
          TR.IRelaxedToken(2, 'number.mips'),
          TR.IRelaxedToken(3, 'delimiter.mips'),
          TR.IRelaxedToken(4, 'number.mips'),
        ],
      ),
    ],
  ]);
}

