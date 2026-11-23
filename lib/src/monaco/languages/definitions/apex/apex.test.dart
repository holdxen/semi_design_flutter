// Generated 1:1 from languages/definitions/apex/apex.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('apex')
void runLanguagesDefinitionsApexApexTestCases() {
  TR.testTokenization('apex', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.apex'),
          TR.IRelaxedToken(1, 'identifier.apex'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.apex'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.apex'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.apex'),
          TR.IRelaxedToken(5, 'delimiter.apex'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.apex'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.apex'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.apex'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.apex'),
          TR.IRelaxedToken(9, 'delimiter.apex'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.apex'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.apex'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.apex'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.apex'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.apex'),
          TR.IRelaxedToken(32, 'delimiter.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.apex'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.apex'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.apex'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.apex'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.apex'),
          TR.IRelaxedToken(23, 'delimiter.apex'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.apex'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.apex'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.apex'),
          TR.IRelaxedToken(8, 'delimiter.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.apex'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.apex'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* start of multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.apex'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.apex'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.apex'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.apex'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
        ],
      ),
      TR.ITestItem(
        'and end it */ 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.apex'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.apex'),
          TR.IRelaxedToken(15, 'delimiter.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/** start of Apex Doc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.apex'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.apex'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.doc.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'package test; class Program { static void main(String[] args) {} } }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.package.apex'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.apex'),
          TR.IRelaxedToken(12, 'delimiter.apex'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.class.apex'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'type.identifier.apex'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.curly.apex'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'keyword.static.apex'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'keyword.void.apex'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'identifier.apex'),
          TR.IRelaxedToken(46, 'delimiter.parenthesis.apex'),
          TR.IRelaxedToken(47, 'type.identifier.apex'),
          TR.IRelaxedToken(53, 'delimiter.square.apex'),
          TR.IRelaxedToken(55, ''),
          TR.IRelaxedToken(56, 'identifier.apex'),
          TR.IRelaxedToken(60, 'delimiter.parenthesis.apex'),
          TR.IRelaxedToken(61, ''),
          TR.IRelaxedToken(62, 'delimiter.curly.apex'),
          TR.IRelaxedToken(64, ''),
          TR.IRelaxedToken(65, 'delimiter.curly.apex'),
          TR.IRelaxedToken(66, ''),
          TR.IRelaxedToken(67, 'delimiter.curly.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Package test; CLASS Program { Static void main(String[] args) {} } }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.Package.apex'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.apex'),
          TR.IRelaxedToken(12, 'delimiter.apex'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.CLASS.apex'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'type.identifier.apex'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.curly.apex'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'keyword.Static.apex'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'keyword.void.apex'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'identifier.apex'),
          TR.IRelaxedToken(46, 'delimiter.parenthesis.apex'),
          TR.IRelaxedToken(47, 'type.identifier.apex'),
          TR.IRelaxedToken(53, 'delimiter.square.apex'),
          TR.IRelaxedToken(55, ''),
          TR.IRelaxedToken(56, 'identifier.apex'),
          TR.IRelaxedToken(60, 'delimiter.parenthesis.apex'),
          TR.IRelaxedToken(61, ''),
          TR.IRelaxedToken(62, 'delimiter.curly.apex'),
          TR.IRelaxedToken(64, ''),
          TR.IRelaxedToken(65, 'delimiter.curly.apex'),
          TR.IRelaxedToken(66, ''),
          TR.IRelaxedToken(67, 'delimiter.curly.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(1, 'identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E-3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e-3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_______2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3_.1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(1, 'identifier.apex'),
          TR.IRelaxedToken(2, 'delimiter.apex'),
          TR.IRelaxedToken(3, 'number.float.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3._1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(1, 'delimiter.apex'),
          TR.IRelaxedToken(2, 'identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '999_99_9999_L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(11, 'identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(2, 'identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_x52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(1, 'identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(1, 'identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.apex'),
          TR.IRelaxedToken(4, 'type.identifier.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(1, 'delimiter.apex'),
          TR.IRelaxedToken(2, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(3, 'delimiter.apex'),
          TR.IRelaxedToken(4, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.apex'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.apex'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = "I\'m an Apex String";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.apex'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.apex'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.apex'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.apex'),
          TR.IRelaxedToken(31, 'delimiter.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = "concatenated" + " String" ;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.apex'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.apex'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.apex'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.apex'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'delimiter.apex'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'string.apex'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'delimiter.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"quote in a string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping \\"quotes\\" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.apex'),
          TR.IRelaxedToken(10, 'string.escape.apex'),
          TR.IRelaxedToken(12, 'string.apex'),
          TR.IRelaxedToken(18, 'string.escape.apex'),
          TR.IRelaxedToken(20, 'string.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"\\"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.invalid.apex'),
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
          TR.IRelaxedToken(0, 'annotation.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@SuppressWarnings(value = "aString")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.apex'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.apex'),
          TR.IRelaxedToken(18, 'identifier.apex'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'delimiter.apex'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'string.apex'),
          TR.IRelaxedToken(35, 'delimiter.parenthesis.apex'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@ AnnotationWithKeywordAfter private',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.apex'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'keyword.private.apex'),
        ],
      ),
    ],
  ]);
}

