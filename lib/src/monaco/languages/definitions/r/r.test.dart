// Generated 1:1 from languages/definitions/r/r.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('r')
void runLanguagesDefinitionsRRTestCases() {
  TR.testTokenization('r', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'function(a) { a }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.r'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.r'),
          TR.IRelaxedToken(9, 'identifier.r'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.r'),
          TR.IRelaxedToken(11, 'white.r'),
          TR.IRelaxedToken(12, 'delimiter.curly.r'),
          TR.IRelaxedToken(13, 'white.r'),
          TR.IRelaxedToken(14, 'identifier.r'),
          TR.IRelaxedToken(15, 'white.r'),
          TR.IRelaxedToken(16, 'delimiter.curly.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'while(FALSE) { break }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.r'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.r'),
          TR.IRelaxedToken(6, 'constant.r'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.r'),
          TR.IRelaxedToken(12, 'white.r'),
          TR.IRelaxedToken(13, 'delimiter.curly.r'),
          TR.IRelaxedToken(14, 'white.r'),
          TR.IRelaxedToken(15, 'keyword.r'),
          TR.IRelaxedToken(20, 'white.r'),
          TR.IRelaxedToken(21, 'delimiter.curly.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'if (a) { b } else { d }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.r'),
          TR.IRelaxedToken(2, 'white.r'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.r'),
          TR.IRelaxedToken(6, 'white.r'),
          TR.IRelaxedToken(7, 'delimiter.curly.r'),
          TR.IRelaxedToken(8, 'white.r'),
          TR.IRelaxedToken(9, 'identifier.r'),
          TR.IRelaxedToken(10, 'white.r'),
          TR.IRelaxedToken(11, 'delimiter.curly.r'),
          TR.IRelaxedToken(12, 'white.r'),
          TR.IRelaxedToken(13, 'keyword.r'),
          TR.IRelaxedToken(17, 'white.r'),
          TR.IRelaxedToken(18, 'delimiter.curly.r'),
          TR.IRelaxedToken(19, 'white.r'),
          TR.IRelaxedToken(20, 'identifier.r'),
          TR.IRelaxedToken(21, 'white.r'),
          TR.IRelaxedToken(22, 'delimiter.curly.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' # comment #',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.r'),
          TR.IRelaxedToken(1, 'comment.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' #\' @author: me ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.r'),
          TR.IRelaxedToken(1, 'comment.doc.r'),
          TR.IRelaxedToken(4, 'tag.r'),
          TR.IRelaxedToken(11, 'comment.doc.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' #\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.r'),
          TR.IRelaxedToken(1, 'comment.doc.r'),
        ],
      ),
      TR.ITestItem(
        ' ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a\\n"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.r'),
          TR.IRelaxedToken(1, 'string.r'),
          TR.IRelaxedToken(4, 'string.escape.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a\\s"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.escape.r'),
          TR.IRelaxedToken(1, 'string.r'),
          TR.IRelaxedToken(2, 'error-token.r'),
          TR.IRelaxedToken(4, 'string.escape.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-1.1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-.1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1e10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1e-10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-1e10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-1e-10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E-10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-1E10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-1E-10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a & b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a - b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a * b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a + b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a = b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a | b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a ! b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a < b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a > b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a ^ b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a ~ b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a / b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a : b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a %in% b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(6, 'white.r'),
          TR.IRelaxedToken(7, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a %->% b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(6, 'white.r'),
          TR.IRelaxedToken(7, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a == b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a != b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a %% b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a && b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a || b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a <- b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a <<- b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(5, 'white.r'),
          TR.IRelaxedToken(6, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a -> b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a ->> b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(5, 'white.r'),
          TR.IRelaxedToken(6, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a \$ b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(3, 'white.r'),
          TR.IRelaxedToken(4, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a << b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a >> b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.r'),
          TR.IRelaxedToken(1, 'white.r'),
          TR.IRelaxedToken(2, 'operator.r'),
          TR.IRelaxedToken(4, 'white.r'),
          TR.IRelaxedToken(5, 'identifier.r'),
        ],
      ),
    ],
  ]);
}

