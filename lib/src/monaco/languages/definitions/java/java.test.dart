// Generated 1:1 from languages/definitions/java/java.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('java')
void runLanguagesDefinitionsJavaJavaTestCases() {
  TR.testTokenization('java', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.java'),
          TR.IRelaxedToken(1, 'identifier.java'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.java'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.java'),
          TR.IRelaxedToken(5, 'delimiter.java'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.java'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.java'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.java'),
          TR.IRelaxedToken(9, 'delimiter.java'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.java'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.java'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.java'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.java'),
          TR.IRelaxedToken(32, 'delimiter.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.java'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.java'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.java'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.java'),
          TR.IRelaxedToken(23, 'delimiter.java'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.java'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.java'),
          TR.IRelaxedToken(8, 'delimiter.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.java'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* start of multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.java'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.java'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.java'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
        ],
      ),
      TR.ITestItem(
        'and end it */ 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.java'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.java'),
          TR.IRelaxedToken(15, 'delimiter.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/** start of Java Doc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.java'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.java'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'package test; class Program { static void main(String[] args) {} } }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.package.java'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.java'),
          TR.IRelaxedToken(12, 'delimiter.java'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.class.java'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'identifier.java'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.curly.java'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'keyword.static.java'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'keyword.void.java'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'identifier.java'),
          TR.IRelaxedToken(46, 'delimiter.parenthesis.java'),
          TR.IRelaxedToken(47, 'identifier.java'),
          TR.IRelaxedToken(53, 'delimiter.square.java'),
          TR.IRelaxedToken(55, ''),
          TR.IRelaxedToken(56, 'identifier.java'),
          TR.IRelaxedToken(60, 'delimiter.parenthesis.java'),
          TR.IRelaxedToken(61, ''),
          TR.IRelaxedToken(62, 'delimiter.curly.java'),
          TR.IRelaxedToken(64, ''),
          TR.IRelaxedToken(65, 'delimiter.curly.java'),
          TR.IRelaxedToken(66, ''),
          TR.IRelaxedToken(67, 'delimiter.curly.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(1, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '023L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '05_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b1010_0101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B001',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E-3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e-3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_______2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3_.1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(1, 'identifier.java'),
          TR.IRelaxedToken(2, 'delimiter.java'),
          TR.IRelaxedToken(3, 'number.float.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3._1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(1, 'delimiter.java'),
          TR.IRelaxedToken(2, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '999_99_9999_L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(11, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(2, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_x52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(1, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(1, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.java'),
          TR.IRelaxedToken(4, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '052_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.java'),
          TR.IRelaxedToken(3, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.java'),
          TR.IRelaxedToken(4, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(1, 'delimiter.java'),
          TR.IRelaxedToken(2, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(3, 'delimiter.java'),
          TR.IRelaxedToken(4, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.java'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = "I\'m a Java String";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.java'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.java'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.java'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.java'),
          TR.IRelaxedToken(30, 'delimiter.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = "concatenated" + " String" ;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.java'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.java'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.java'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.java'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'delimiter.java'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'string.java'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'delimiter.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"quote in a string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping \\"quotes\\" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.java'),
          TR.IRelaxedToken(10, 'string.escape.java'),
          TR.IRelaxedToken(12, 'string.java'),
          TR.IRelaxedToken(18, 'string.escape.java'),
          TR.IRelaxedToken(20, 'string.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"\\"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.invalid.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@Override',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@SuppressWarnings(value = "aString")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.java'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.java'),
          TR.IRelaxedToken(18, 'identifier.java'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'delimiter.java'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'string.java'),
          TR.IRelaxedToken(35, 'delimiter.parenthesis.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@ AnnotationWithKeywordAfter private',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.java'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'keyword.private.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = """Multiline string""";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.java'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.java'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.java'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.java'),
          TR.IRelaxedToken(33, 'delimiter.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = """',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.java'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.java'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.java'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.java'),
        ],
      ),
      TR.ITestItem(
        '     <html></html>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.java'),
        ],
      ),
      TR.ITestItem(
        '     """;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.java'),
          TR.IRelaxedToken(8, 'delimiter.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = """',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.java'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.java'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.java'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.java'),
        ],
      ),
      TR.ITestItem(
        '     \\"""Triple quoted string inside text block\\"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.java'),
          TR.IRelaxedToken(5, 'string.escape.java'),
          TR.IRelaxedToken(7, 'string.java'),
          TR.IRelaxedToken(47, 'string.escape.java'),
          TR.IRelaxedToken(49, 'string.java'),
        ],
      ),
      TR.ITestItem(
        '     """;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.java'),
          TR.IRelaxedToken(8, 'delimiter.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'yield "123"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.yield.java'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'public sealed class Shape permits Circle, Square { }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.public.java'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.sealed.java'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.class.java'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'identifier.java'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'keyword.permits.java'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'identifier.java'),
          TR.IRelaxedToken(40, 'delimiter.java'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'identifier.java'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(49, 'delimiter.curly.java'),
          TR.IRelaxedToken(50, ''),
          TR.IRelaxedToken(51, 'delimiter.curly.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'public non-sealed class Shape',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.public.java'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.non-sealed.java'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'keyword.class.java'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'identifier.java'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = y-z;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.java'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.java'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.java'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.java'),
          TR.IRelaxedToken(9, 'delimiter.java'),
          TR.IRelaxedToken(10, 'identifier.java'),
          TR.IRelaxedToken(11, 'delimiter.java'),
        ],
      ),
    ],
  ]);
}

