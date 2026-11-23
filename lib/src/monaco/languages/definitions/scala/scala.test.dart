// Generated 1:1 from languages/definitions/scala/scala.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('scala')
void runLanguagesDefinitionsScalaScalaTestCases() {
  TR.testTokenization('scala', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'var a = 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'variable.scala'),
          TR.IRelaxedToken(5, 'white.scala'),
          TR.IRelaxedToken(6, 'operator.scala'),
          TR.IRelaxedToken(7, 'white.scala'),
          TR.IRelaxedToken(8, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.scala'),
          TR.IRelaxedToken(4, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.scala'),
          TR.IRelaxedToken(1, 'identifier.scala'),
          TR.IRelaxedToken(7, 'white.scala'),
          TR.IRelaxedToken(8, 'identifier.scala'),
          TR.IRelaxedToken(9, 'white.scala'),
          TR.IRelaxedToken(10, 'identifier.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(1, 'white.scala'),
          TR.IRelaxedToken(2, 'operator.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'number.scala'),
          TR.IRelaxedToken(5, 'delimiter.scala'),
          TR.IRelaxedToken(6, 'white.scala'),
          TR.IRelaxedToken(7, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val x: Int = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'variable.scala'),
          TR.IRelaxedToken(5, 'operator.scala'),
          TR.IRelaxedToken(6, 'white.scala'),
          TR.IRelaxedToken(7, 'type.scala'),
          TR.IRelaxedToken(10, 'white.scala'),
          TR.IRelaxedToken(11, 'operator.scala'),
          TR.IRelaxedToken(12, 'white.scala'),
          TR.IRelaxedToken(13, 'number.scala'),
          TR.IRelaxedToken(14, 'delimiter.scala'),
          TR.IRelaxedToken(15, 'white.scala'),
          TR.IRelaxedToken(16, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val x: Int = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'variable.scala'),
          TR.IRelaxedToken(5, 'operator.scala'),
          TR.IRelaxedToken(6, 'white.scala'),
          TR.IRelaxedToken(7, 'type.scala'),
          TR.IRelaxedToken(10, 'white.scala'),
          TR.IRelaxedToken(11, 'operator.scala'),
          TR.IRelaxedToken(12, 'white.scala'),
          TR.IRelaxedToken(13, 'comment.scala'),
          TR.IRelaxedToken(35, 'white.scala'),
          TR.IRelaxedToken(36, 'number.scala'),
          TR.IRelaxedToken(37, 'delimiter.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val x: Int = /* a simple comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'variable.scala'),
          TR.IRelaxedToken(5, 'operator.scala'),
          TR.IRelaxedToken(6, 'white.scala'),
          TR.IRelaxedToken(7, 'type.scala'),
          TR.IRelaxedToken(10, 'white.scala'),
          TR.IRelaxedToken(11, 'operator.scala'),
          TR.IRelaxedToken(12, 'white.scala'),
          TR.IRelaxedToken(13, 'comment.scala'),
          TR.IRelaxedToken(35, 'white.scala'),
          TR.IRelaxedToken(36, 'number.scala'),
          TR.IRelaxedToken(37, 'delimiter.scala'),
          TR.IRelaxedToken(38, 'white.scala'),
          TR.IRelaxedToken(39, 'operator.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.scala'),
          TR.IRelaxedToken(1, 'white.scala'),
          TR.IRelaxedToken(2, 'operator.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'comment.scala'),
          TR.IRelaxedToken(8, 'delimiter.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.scala'),
          TR.IRelaxedToken(1, 'white.scala'),
          TR.IRelaxedToken(2, 'operator.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* start of multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val x: Int = /* start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'variable.scala'),
          TR.IRelaxedToken(5, 'operator.scala'),
          TR.IRelaxedToken(6, 'white.scala'),
          TR.IRelaxedToken(7, 'type.scala'),
          TR.IRelaxedToken(10, 'white.scala'),
          TR.IRelaxedToken(11, 'operator.scala'),
          TR.IRelaxedToken(12, 'white.scala'),
          TR.IRelaxedToken(13, 'comment.scala'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
      TR.ITestItem(
        'and end it */ 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
          TR.IRelaxedToken(13, 'white.scala'),
          TR.IRelaxedToken(14, 'number.scala'),
          TR.IRelaxedToken(15, 'delimiter.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/** start of Scala Doc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'package test; object Program { def main(args: Array[String]): Unit = {} }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scala'),
          TR.IRelaxedToken(7, 'white.scala'),
          TR.IRelaxedToken(8, 'identifier.scala'),
          TR.IRelaxedToken(12, 'delimiter.scala'),
          TR.IRelaxedToken(13, 'white.scala'),
          TR.IRelaxedToken(14, 'keyword.scala'),
          TR.IRelaxedToken(20, 'white.scala'),
          TR.IRelaxedToken(21, 'type.scala'),
          TR.IRelaxedToken(28, 'white.scala'),
          TR.IRelaxedToken(29, 'delimiter.curly.scala'),
          TR.IRelaxedToken(30, 'white.scala'),
          TR.IRelaxedToken(31, 'keyword.scala'),
          TR.IRelaxedToken(34, 'white.scala'),
          TR.IRelaxedToken(35, 'identifier.scala'),
          TR.IRelaxedToken(39, 'delimiter.parenthesis.scala'),
          TR.IRelaxedToken(40, 'variable.scala'),
          TR.IRelaxedToken(44, 'operator.scala'),
          TR.IRelaxedToken(45, 'white.scala'),
          TR.IRelaxedToken(46, 'type.scala'),
          TR.IRelaxedToken(51, 'operator.square.scala'),
          TR.IRelaxedToken(52, 'type.scala'),
          TR.IRelaxedToken(58, 'operator.square.scala'),
          TR.IRelaxedToken(59, 'delimiter.parenthesis.scala'),
          TR.IRelaxedToken(60, 'operator.scala'),
          TR.IRelaxedToken(61, 'white.scala'),
          TR.IRelaxedToken(62, 'type.scala'),
          TR.IRelaxedToken(66, 'white.scala'),
          TR.IRelaxedToken(67, 'operator.scala'),
          TR.IRelaxedToken(68, 'white.scala'),
          TR.IRelaxedToken(69, 'delimiter.curly.scala'),
          TR.IRelaxedToken(71, 'white.scala'),
          TR.IRelaxedToken(72, 'delimiter.curly.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(1, 'identifier.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E-3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e-3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_______2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3_.1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(1, 'keyword.scala'),
          TR.IRelaxedToken(2, 'delimiter.scala'),
          TR.IRelaxedToken(3, 'number.float.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3._1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(1, 'operator.scala'),
          TR.IRelaxedToken(2, 'identifier.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '999_99_9999_L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(11, 'identifier.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(2, 'keyword.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_x52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(1, 'identifier.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(1, 'identifier.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.scala'),
          TR.IRelaxedToken(4, 'keyword.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.scala'),
          TR.IRelaxedToken(4, 'type.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(1, 'operator.scala'),
          TR.IRelaxedToken(2, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(3, 'operator.scala'),
          TR.IRelaxedToken(4, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.scala'),
          TR.IRelaxedToken(1, 'white.scala'),
          TR.IRelaxedToken(2, 'operator.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'number.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val s: String = "I\'m a Scala String";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'variable.scala'),
          TR.IRelaxedToken(5, 'operator.scala'),
          TR.IRelaxedToken(6, 'white.scala'),
          TR.IRelaxedToken(7, 'type.scala'),
          TR.IRelaxedToken(13, 'white.scala'),
          TR.IRelaxedToken(14, 'operator.scala'),
          TR.IRelaxedToken(15, 'white.scala'),
          TR.IRelaxedToken(16, 'string.quote.scala'),
          TR.IRelaxedToken(17, 'string.scala'),
          TR.IRelaxedToken(35, 'string.quote.scala'),
          TR.IRelaxedToken(36, 'delimiter.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val s: String = "concatenated" + " String" ;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.scala'),
          TR.IRelaxedToken(3, 'white.scala'),
          TR.IRelaxedToken(4, 'variable.scala'),
          TR.IRelaxedToken(5, 'operator.scala'),
          TR.IRelaxedToken(6, 'white.scala'),
          TR.IRelaxedToken(7, 'type.scala'),
          TR.IRelaxedToken(13, 'white.scala'),
          TR.IRelaxedToken(14, 'operator.scala'),
          TR.IRelaxedToken(15, 'white.scala'),
          TR.IRelaxedToken(16, 'string.quote.scala'),
          TR.IRelaxedToken(17, 'string.scala'),
          TR.IRelaxedToken(29, 'string.quote.scala'),
          TR.IRelaxedToken(30, 'white.scala'),
          TR.IRelaxedToken(31, 'operator.scala'),
          TR.IRelaxedToken(32, 'white.scala'),
          TR.IRelaxedToken(33, 'string.quote.scala'),
          TR.IRelaxedToken(34, 'string.scala'),
          TR.IRelaxedToken(41, 'string.quote.scala'),
          TR.IRelaxedToken(42, 'white.scala'),
          TR.IRelaxedToken(43, 'delimiter.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"quote in a string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.scala'),
          TR.IRelaxedToken(1, 'string.scala'),
          TR.IRelaxedToken(18, 'string.quote.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping \\"quotes\\" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.scala'),
          TR.IRelaxedToken(1, 'string.scala'),
          TR.IRelaxedToken(10, 'string.escape.scala'),
          TR.IRelaxedToken(12, 'string.scala'),
          TR.IRelaxedToken(18, 'string.escape.scala'),
          TR.IRelaxedToken(20, 'string.scala'),
          TR.IRelaxedToken(28, 'string.quote.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"\\"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.scala'),
          TR.IRelaxedToken(1, 'string.escape.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@uncheckedStable',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@silent("deprecated")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.scala'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.scala'),
          TR.IRelaxedToken(8, 'string.quote.scala'),
          TR.IRelaxedToken(9, 'string.scala'),
          TR.IRelaxedToken(19, 'string.quote.scala'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.scala'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@AnnotationWithKeywordAfter private',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.scala'),
          TR.IRelaxedToken(27, 'white.scala'),
          TR.IRelaxedToken(28, 'keyword.modifier.scala'),
        ],
      ),
    ],
  ]);
}

