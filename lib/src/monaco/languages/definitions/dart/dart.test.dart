// Generated 1:1 from languages/definitions/dart/dart.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('dart')
void runLanguagesDefinitionsDartDartTestCases() {
  TR.testTokenization('dart', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.dart'),
          TR.IRelaxedToken(1, 'identifier.dart'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.dart'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.dart'),
          TR.IRelaxedToken(5, 'delimiter.dart'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.dart'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.dart'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.dart'),
          TR.IRelaxedToken(9, 'delimiter.dart'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.dart'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.dart'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.dart'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.dart'),
          TR.IRelaxedToken(32, 'delimiter.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.dart'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.dart'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.dart'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.dart'),
          TR.IRelaxedToken(23, 'delimiter.dart'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.dart'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.dart'),
          TR.IRelaxedToken(8, 'delimiter.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.dart'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* start of multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.dart'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.dart'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.dart'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
        ],
      ),
      TR.ITestItem(
        'and end it */ 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dart'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.dart'),
          TR.IRelaxedToken(15, 'delimiter.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = function() { };',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.dart'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.dart'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.dart'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.dart'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.bracket.dart'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.bracket.dart'),
          TR.IRelaxedToken(22, 'delimiter.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    var    ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.dart'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(1, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b1010_0101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0B001',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5_______2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '3._1415F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(1, 'delimiter.dart'),
          TR.IRelaxedToken(2, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '999_99_9999_L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(11, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(2, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0_x52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(1, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x_52',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(1, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x52_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.dart'),
          TR.IRelaxedToken(4, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '052_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.dart'),
          TR.IRelaxedToken(3, 'identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.dart'),
          TR.IRelaxedToken(4, 'type.identifier.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(1, 'delimiter.dart'),
          TR.IRelaxedToken(2, 'number.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(3, 'delimiter.dart'),
          TR.IRelaxedToken(4, 'number.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.dart'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var s = \'s\';',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dart'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.dart'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.dart'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.dart'),
          TR.IRelaxedToken(11, 'delimiter.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'String s = "concatenated" + " String" ;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.dart'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.dart'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.dart'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.dart'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'delimiter.dart'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'string.dart'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'delimiter.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"quote in a string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping \\"quotes\\" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.dart'),
          TR.IRelaxedToken(10, 'string.escape.dart'),
          TR.IRelaxedToken(12, 'string.dart'),
          TR.IRelaxedToken(18, 'string.escape.dart'),
          TR.IRelaxedToken(20, 'string.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"\\"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.invalid.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.dart'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@Override',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.dart'),
        ],
      ),
    ],
  ]);
}

