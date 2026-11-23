// Generated 1:1 from languages/definitions/kotlin/kotlin.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('kotlin')
void runLanguagesDefinitionsKotlinKotlinTestCases() {
  TR.testTokenization('kotlin', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'inline fun <reified T : Any> foo()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.inline.kt'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.fun.kt'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.angle.kt'),
          TR.IRelaxedToken(12, 'keyword.reified.kt'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'type.identifier.kt'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'delimiter.kt'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'type.identifier.kt'),
          TR.IRelaxedToken(27, 'delimiter.angle.kt'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'identifier.kt'),
          TR.IRelaxedToken(32, 'delimiter.parenthesis.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val x: X=5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.val.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.kt'),
          TR.IRelaxedToken(5, 'delimiter.kt'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'type.identifier.kt'),
          TR.IRelaxedToken(8, 'delimiter.kt'),
          TR.IRelaxedToken(9, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.kt'),
          TR.IRelaxedToken(1, 'identifier.kt'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.kt'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.kt'),
          TR.IRelaxedToken(5, 'delimiter.kt'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* a simple comment */ 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.var.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.kt'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.kt'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.kt'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.var.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.kt'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.kt'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.kt'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.kt'),
          TR.IRelaxedToken(23, 'delimiter.kt'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.kt'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /** start a Java Doc comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.var.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.kt'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.kt'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.doc.kt'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.kt'),
        ],
      ),
      TR.ITestItem(
        'and end it */ 2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.kt'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/** start of Java Doc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.kt'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.kt'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'package test class Program { fun main(vararg args: String) {} } }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.package.kt'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.kt'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.class.kt'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'type.identifier.kt'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'delimiter.curly.kt'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'keyword.fun.kt'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'identifier.kt'),
          TR.IRelaxedToken(37, 'delimiter.parenthesis.kt'),
          TR.IRelaxedToken(38, 'keyword.vararg.kt'),
          TR.IRelaxedToken(44, ''),
          TR.IRelaxedToken(45, 'identifier.kt'),
          TR.IRelaxedToken(49, 'delimiter.kt'),
          TR.IRelaxedToken(50, ''),
          TR.IRelaxedToken(51, 'type.identifier.kt'),
          TR.IRelaxedToken(57, 'delimiter.parenthesis.kt'),
          TR.IRelaxedToken(58, ''),
          TR.IRelaxedToken(59, 'delimiter.curly.kt'),
          TR.IRelaxedToken(61, ''),
          TR.IRelaxedToken(62, 'delimiter.curly.kt'),
          TR.IRelaxedToken(63, ''),
          TR.IRelaxedToken(64, 'delimiter.curly.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(1, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0Xff_81_00L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123u',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123U',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123uL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123UL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '023L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(4, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '05_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b1010_0101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B001',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b0101L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B0101u',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B1__0U',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B0101uL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B1__0UL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.001f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
          TR.IRelaxedToken(4, 'type.identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
          TR.IRelaxedToken(4, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
          TR.IRelaxedToken(6, 'type.identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
          TR.IRelaxedToken(6, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E-3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
          TR.IRelaxedToken(7, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
          TR.IRelaxedToken(6, 'type.identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
          TR.IRelaxedToken(6, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e-3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.kt'),
          TR.IRelaxedToken(7, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(2, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23u',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23U',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23uL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23UL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_______2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3_.1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(1, 'identifier.kt'),
          TR.IRelaxedToken(2, 'number.float.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3._1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(1, 'delimiter.kt'),
          TR.IRelaxedToken(2, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '999_99_9999_L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(11, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(2, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_x52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(1, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(1, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.kt'),
          TR.IRelaxedToken(4, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '052_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(3, 'identifier.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(1, 'delimiter.kt'),
          TR.IRelaxedToken(2, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(3, 'delimiter.kt'),
          TR.IRelaxedToken(4, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.kt'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var s = "I\'m a Kotlin String"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.var.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.kt'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.kt'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var s = "concatenated" + " String"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.var.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.kt'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.kt'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.kt'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.kt'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'string.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"quote in a string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping \\"quotes\\" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.kt'),
          TR.IRelaxedToken(10, 'string.escape.kt'),
          TR.IRelaxedToken(12, 'string.kt'),
          TR.IRelaxedToken(18, 'string.escape.kt'),
          TR.IRelaxedToken(20, 'string.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"\\"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.invalid.kt'),
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
        '@Inject',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@SuppressWarnings("aString")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.kt'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.kt'),
          TR.IRelaxedToken(18, 'string.kt'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@ AnnotationWithKeywordAfter private',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.kt'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'keyword.private.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'fun /* /* */ */ main() {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.fun.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.kt'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.kt'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.kt'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.curly.kt'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'val text = """',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.val.kt'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.kt'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.kt'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.kt'),
        ],
      ),
      TR.ITestItem(
        '    for (c in "foo")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.kt'),
        ],
      ),
      TR.ITestItem(
        '        print(c)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.kt'),
        ],
      ),
      TR.ITestItem(
        '"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.kt'),
        ],
      ),
    ],
  ]);
}

