// Generated 1:1 from languages/definitions/python/python.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('python')
void runLanguagesDefinitionsPythonPythonTestCases() {
  TR.testTokenization('python', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'def func():',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.python'),
          TR.IRelaxedToken(3, 'white.python'),
          TR.IRelaxedToken(4, 'identifier.python'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.python'),
          TR.IRelaxedToken(10, 'delimiter.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'func(str Y3)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.python'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.python'),
          TR.IRelaxedToken(5, 'keyword.python'),
          TR.IRelaxedToken(8, 'white.python'),
          TR.IRelaxedToken(9, 'identifier.python'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@Dec0_rator:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.python'),
          TR.IRelaxedToken(11, 'delimiter.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' # Comments! ## "jfkd" ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.python'),
          TR.IRelaxedToken(1, 'comment.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'s0\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.python'),
          TR.IRelaxedToken(1, 'string.python'),
          TR.IRelaxedToken(3, 'string.escape.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"\' " "',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.python'),
          TR.IRelaxedToken(1, 'string.python'),
          TR.IRelaxedToken(3, 'string.escape.python'),
          TR.IRelaxedToken(4, 'white.python'),
          TR.IRelaxedToken(5, 'string.escape.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\'\'Lots of string\'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"""Lots \'\'\'     \'\'\'"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\'\'Lots \'\'\'0.3e-5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
          TR.IRelaxedToken(11, 'number.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'def f():',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.python'),
          TR.IRelaxedToken(3, 'white.python'),
          TR.IRelaxedToken(4, 'identifier.python'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.python'),
          TR.IRelaxedToken(7, 'delimiter.python'),
        ],
      ),
      TR.ITestItem(
        '   """multi',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.python'),
          TR.IRelaxedToken(3, 'string.python'),
        ],
      ),
      TR.ITestItem(
        '   line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
        ],
      ),
      TR.ITestItem(
        '   comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
        ],
      ),
      TR.ITestItem(
        '   """ + """',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
          TR.IRelaxedToken(6, 'white.python'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'white.python'),
          TR.IRelaxedToken(9, 'string.python'),
        ],
      ),
      TR.ITestItem(
        '   another',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
        ],
      ),
      TR.ITestItem(
        '   multi',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
        ],
      ),
      TR.ITestItem(
        '   line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
        ],
      ),
      TR.ITestItem(
        '   comment"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.python'),
        ],
      ),
      TR.ITestItem(
        '   code',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.python'),
          TR.IRelaxedToken(3, 'identifier.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xAcBFd',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x0cH',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.python'),
          TR.IRelaxedToken(4, 'identifier.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '456.7e-7j',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'f"str {var} str"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.python'),
          TR.IRelaxedToken(2, 'string.python'),
          TR.IRelaxedToken(6, 'identifier.python'),
          TR.IRelaxedToken(11, 'string.python'),
          TR.IRelaxedToken(15, 'string.escape.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'f\'\'\'str {var} str\'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.python'),
          TR.IRelaxedToken(4, 'string.python'),
          TR.IRelaxedToken(8, 'identifier.python'),
          TR.IRelaxedToken(13, 'string.python'),
          TR.IRelaxedToken(17, 'string.escape.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'f"{var:.3f}{var!r}{var=}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.python'),
          TR.IRelaxedToken(2, 'identifier.python'),
          TR.IRelaxedToken(6, 'string.python'),
          TR.IRelaxedToken(10, 'identifier.python'),
          TR.IRelaxedToken(15, 'string.python'),
          TR.IRelaxedToken(17, 'identifier.python'),
          TR.IRelaxedToken(22, 'string.python'),
          TR.IRelaxedToken(23, 'identifier.python'),
          TR.IRelaxedToken(24, 'string.escape.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'f"\' " "',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.python'),
          TR.IRelaxedToken(2, 'string.python'),
          TR.IRelaxedToken(4, 'string.escape.python'),
          TR.IRelaxedToken(5, 'white.python'),
          TR.IRelaxedToken(6, 'string.escape.python'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"{var}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.python'),
          TR.IRelaxedToken(1, 'string.python'),
          TR.IRelaxedToken(6, 'string.escape.python'),
        ],
      ),
    ],
  ]);
}

