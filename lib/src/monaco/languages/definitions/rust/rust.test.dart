// Generated 1:1 from languages/definitions/rust/rust.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('rust')
void runLanguagesDefinitionsRustRustTestCases() {
  TR.testTokenization('rust', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'let a = "This is a string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rust'),
          TR.IRelaxedToken(3, 'white.rust'),
          TR.IRelaxedToken(4, 'identifier.rust'),
          TR.IRelaxedToken(5, 'white.rust'),
          TR.IRelaxedToken(6, 'operator.rust'),
          TR.IRelaxedToken(7, 'white.rust'),
          TR.IRelaxedToken(8, 'string.quote.rust'),
          TR.IRelaxedToken(9, 'string.rust'),
          TR.IRelaxedToken(25, 'string.quote.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'r"This is a raw string" ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.rust'),
          TR.IRelaxedToken(2, 'string.rust'),
          TR.IRelaxedToken(22, 'string.quote.rust'),
          TR.IRelaxedToken(23, 'white.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'r#"This is a raw string"# ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.rust'),
          TR.IRelaxedToken(3, 'string.rust'),
          TR.IRelaxedToken(23, 'string.quote.rust'),
          TR.IRelaxedToken(25, 'white.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'r##"This is a# raw string"## ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.rust'),
          TR.IRelaxedToken(4, 'string.rust'),
          TR.IRelaxedToken(25, 'string.quote.rust'),
          TR.IRelaxedToken(28, 'white.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'r###"This is multi-line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.rust'),
          TR.IRelaxedToken(5, 'string.rust'),
        ],
      ),
      TR.ITestItem(
        'raw "##string"### ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.rust'),
          TR.IRelaxedToken(13, 'string.quote.rust'),
          TR.IRelaxedToken(17, 'white.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let a = \'c\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rust'),
          TR.IRelaxedToken(3, 'white.rust'),
          TR.IRelaxedToken(4, 'identifier.rust'),
          TR.IRelaxedToken(5, 'white.rust'),
          TR.IRelaxedToken(6, 'operator.rust'),
          TR.IRelaxedToken(7, 'white.rust'),
          TR.IRelaxedToken(8, 'string.byteliteral.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\\"\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.byteliteral.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\\0\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.byteliteral.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// This is a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* This is a block comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* This is a block comment // with a comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'static NAME: &\'static str = "John"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rust'),
          TR.IRelaxedToken(6, 'white.rust'),
          TR.IRelaxedToken(7, 'identifier.rust'),
          TR.IRelaxedToken(11, 'operator.rust'),
          TR.IRelaxedToken(12, 'white.rust'),
          TR.IRelaxedToken(13, 'operator.rust'),
          TR.IRelaxedToken(14, 'identifier.rust'),
          TR.IRelaxedToken(21, 'white.rust'),
          TR.IRelaxedToken(22, 'keyword.type.rust'),
          TR.IRelaxedToken(25, 'white.rust'),
          TR.IRelaxedToken(26, 'operator.rust'),
          TR.IRelaxedToken(27, 'white.rust'),
          TR.IRelaxedToken(28, 'string.quote.rust'),
          TR.IRelaxedToken(29, 'string.rust'),
          TR.IRelaxedToken(33, 'string.quote.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'let logical: bool = true',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rust'),
          TR.IRelaxedToken(3, 'white.rust'),
          TR.IRelaxedToken(4, 'identifier.rust'),
          TR.IRelaxedToken(11, 'operator.rust'),
          TR.IRelaxedToken(12, 'white.rust'),
          TR.IRelaxedToken(13, 'keyword.type.rust'),
          TR.IRelaxedToken(17, 'white.rust'),
          TR.IRelaxedToken(18, 'operator.rust'),
          TR.IRelaxedToken(19, 'white.rust'),
          TR.IRelaxedToken(20, 'keyword.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1000_000_00u32',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.0f32',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xFA_01i32',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.0E-8234987_f64',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b0_1u8',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.rust'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0o0000_0010u64',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.rust'),
        ],
      ),
    ],
  ]);
}

