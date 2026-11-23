// Generated 1:1 from languages/definitions/csharp/csharp.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('csharp')
void runLanguagesDefinitionsCsharpCsharpTestCases() {
  TR.testTokenization('csharp', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'using System;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.using.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'namespace.cs'),
          TR.IRelaxedToken(12, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        'using System.Collections.Generic;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.using.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'namespace.cs'),
          TR.IRelaxedToken(12, 'delimiter.cs'),
          TR.IRelaxedToken(13, 'namespace.cs'),
          TR.IRelaxedToken(24, 'delimiter.cs'),
          TR.IRelaxedToken(25, 'namespace.cs'),
          TR.IRelaxedToken(32, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        'using System.Diagnostics;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.using.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'namespace.cs'),
          TR.IRelaxedToken(12, 'delimiter.cs'),
          TR.IRelaxedToken(13, 'namespace.cs'),
          TR.IRelaxedToken(24, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        'using System.Linq;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.using.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'namespace.cs'),
          TR.IRelaxedToken(12, 'delimiter.cs'),
          TR.IRelaxedToken(13, 'namespace.cs'),
          TR.IRelaxedToken(17, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        'using System.Text;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.using.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'namespace.cs'),
          TR.IRelaxedToken(12, 'delimiter.cs'),
          TR.IRelaxedToken(13, 'namespace.cs'),
          TR.IRelaxedToken(17, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        'using System.Threading.Tasks;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.using.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'namespace.cs'),
          TR.IRelaxedToken(12, 'delimiter.cs'),
          TR.IRelaxedToken(13, 'namespace.cs'),
          TR.IRelaxedToken(22, 'delimiter.cs'),
          TR.IRelaxedToken(23, 'namespace.cs'),
          TR.IRelaxedToken(28, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'namespace VS',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.namespace.cs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'namespace.cs'),
        ],
      ),
      TR.ITestItem(
        '{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\tclass Program',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.class.cs'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cs'),
        ],
      ),
      TR.ITestItem(
        '\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\tstatic void Main(string[] args)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.static.cs'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.void.cs'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.cs'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(19, 'keyword.string.cs'),
          TR.IRelaxedToken(25, 'delimiter.square.cs'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'identifier.cs'),
          TR.IRelaxedToken(32, 'delimiter.parenthesis.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\tProcessStartInfo si = new ProcessStartInfo();',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'identifier.cs'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'identifier.cs'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.cs'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'keyword.new.cs'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'identifier.cs'),
          TR.IRelaxedToken(45, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(47, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\tfloat load= 3.2e02f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.float.cs'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.cs'),
          TR.IRelaxedToken(13, 'delimiter.cs'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.float.cs'),
          TR.IRelaxedToken(22, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '\t\t\tsi.FileName = @"tools\\\\node.exe";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'identifier.cs'),
          TR.IRelaxedToken(5, 'delimiter.cs'),
          TR.IRelaxedToken(6, 'identifier.cs'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.cs'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'string.quote.cs'),
          TR.IRelaxedToken(19, 'string.cs'),
          TR.IRelaxedToken(34, 'string.quote.cs'),
          TR.IRelaxedToken(35, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\tsi.Arguments = "tools\\\\simpl3server.js";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'identifier.cs'),
          TR.IRelaxedToken(5, 'delimiter.cs'),
          TR.IRelaxedToken(6, 'identifier.cs'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.cs'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.quote.cs'),
          TR.IRelaxedToken(19, 'string.cs'),
          TR.IRelaxedToken(24, 'string.escape.cs'),
          TR.IRelaxedToken(26, 'string.cs'),
          TR.IRelaxedToken(41, 'string.quote.cs'),
          TR.IRelaxedToken(42, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t\t\tstring someString = \$"hello{outside+variable}the string again {{ escaped";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.string.cs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.cs'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.cs'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'string.quote.cs'),
          TR.IRelaxedToken(25, 'string.cs'),
          TR.IRelaxedToken(30, 'string.quote.cs'),
          TR.IRelaxedToken(31, 'identifier.cs'),
          TR.IRelaxedToken(38, 'delimiter.cs'),
          TR.IRelaxedToken(39, 'identifier.cs'),
          TR.IRelaxedToken(47, 'string.quote.cs'),
          TR.IRelaxedToken(48, 'string.cs'),
          TR.IRelaxedToken(65, 'string.escape.cs'),
          TR.IRelaxedToken(67, 'string.cs'),
          TR.IRelaxedToken(75, 'string.quote.cs'),
          TR.IRelaxedToken(76, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\tvar @string = 5;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.var.cs'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cs'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.cs'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'number.cs'),
          TR.IRelaxedToken(18, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t\t\tif (x == 4)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.if.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(7, 'identifier.cs'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.cs'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'number.cs'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\tfor (int i = 4; i<10; i++)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.for.cs'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(9, 'keyword.int.cs'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.cs'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.cs'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'number.cs'),
          TR.IRelaxedToken(18, 'delimiter.cs'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'identifier.cs'),
          TR.IRelaxedToken(21, 'delimiter.angle.cs'),
          TR.IRelaxedToken(22, 'number.cs'),
          TR.IRelaxedToken(24, 'delimiter.cs'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'identifier.cs'),
          TR.IRelaxedToken(27, 'delimiter.cs'),
          TR.IRelaxedToken(29, 'delimiter.parenthesis.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\t\tvar d = i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'keyword.var.cs'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.cs'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.cs'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.cs'),
          TR.IRelaxedToken(14, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\telse',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.else.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\treturn;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.return.cs'),
          TR.IRelaxedToken(10, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '\t\t\tProcess.Start(si);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'identifier.cs'),
          TR.IRelaxedToken(10, 'delimiter.cs'),
          TR.IRelaxedToken(11, 'identifier.cs'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(17, 'identifier.cs'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(20, 'delimiter.cs'),
        ],
      ),
      TR.ITestItem(
        '\t\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#pragma region /MapLayer/*Image* /// ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'namespace.cpp.cs'),
        ],
      ),
      TR.ITestItem(
        'namespace ShouldNotBeAComment {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.namespace.cs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'namespace.cs'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'delimiter.curly.cs'),
        ],
      ),
      TR.ITestItem(
        '#pragma endregion Region_1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'namespace.cpp.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'namespace VS { class Program { static void Main(string[] args) {} } }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.namespace.cs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'namespace.cs'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.curly.cs'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'keyword.class.cs'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'identifier.cs'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'delimiter.curly.cs'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'keyword.static.cs'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'keyword.void.cs'),
          TR.IRelaxedToken(42, ''),
          TR.IRelaxedToken(43, 'identifier.cs'),
          TR.IRelaxedToken(47, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(48, 'keyword.string.cs'),
          TR.IRelaxedToken(54, 'delimiter.square.cs'),
          TR.IRelaxedToken(56, ''),
          TR.IRelaxedToken(57, 'identifier.cs'),
          TR.IRelaxedToken(61, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(62, ''),
          TR.IRelaxedToken(63, 'delimiter.curly.cs'),
          TR.IRelaxedToken(65, ''),
          TR.IRelaxedToken(66, 'delimiter.curly.cs'),
          TR.IRelaxedToken(67, ''),
          TR.IRelaxedToken(68, 'delimiter.curly.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.cs'),
          TR.IRelaxedToken(1, 'identifier.cs'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.cs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.cs'),
          TR.IRelaxedToken(5, 'delimiter.cs'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.var.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.cs'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.cs'),
          TR.IRelaxedToken(9, 'delimiter.cs'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.var.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.cs'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.cs'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.cs'),
          TR.IRelaxedToken(32, 'delimiter.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'var x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.var.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cs'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.cs'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.cs'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.cs'),
          TR.IRelaxedToken(23, 'delimiter.cs'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.cs'),
          TR.IRelaxedToken(8, 'delimiter.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123_456',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cs'),
          TR.IRelaxedToken(1, 'identifier.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cs'),
          TR.IRelaxedToken(1, 'identifier.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123_456',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0b1010_0001',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1_23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '2_3.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '456_123.5D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.720_123E3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3D',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cs'),
          TR.IRelaxedToken(1, 'delimiter.cs'),
          TR.IRelaxedToken(2, 'number.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cs'),
          TR.IRelaxedToken(3, 'delimiter.cs'),
          TR.IRelaxedToken(4, 'number.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = "string";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.quote.cs'),
          TR.IRelaxedToken(5, 'string.cs'),
          TR.IRelaxedToken(11, 'string.quote.cs'),
          TR.IRelaxedToken(12, 'delimiter.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = "stri\\"ng";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.quote.cs'),
          TR.IRelaxedToken(5, 'string.cs'),
          TR.IRelaxedToken(9, 'string.escape.cs'),
          TR.IRelaxedToken(11, 'string.cs'),
          TR.IRelaxedToken(13, 'string.quote.cs'),
          TR.IRelaxedToken(14, 'delimiter.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = @"verbatimstring";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.quote.cs'),
          TR.IRelaxedToken(6, 'string.cs'),
          TR.IRelaxedToken(20, 'string.quote.cs'),
          TR.IRelaxedToken(21, 'delimiter.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = @"verbatim""string";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.quote.cs'),
          TR.IRelaxedToken(6, 'string.cs'),
          TR.IRelaxedToken(14, 'string.escape.cs'),
          TR.IRelaxedToken(16, 'string.cs'),
          TR.IRelaxedToken(22, 'string.quote.cs'),
          TR.IRelaxedToken(23, 'delimiter.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = @"verbatim\\string\\";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.quote.cs'),
          TR.IRelaxedToken(6, 'string.cs'),
          TR.IRelaxedToken(22, 'string.quote.cs'),
          TR.IRelaxedToken(23, 'delimiter.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = @"verbatim',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.quote.cs'),
          TR.IRelaxedToken(6, 'string.cs'),
        ],
      ),
      TR.ITestItem(
        'string";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.cs'),
          TR.IRelaxedToken(6, 'string.quote.cs'),
          TR.IRelaxedToken(7, 'delimiter.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = \$@"verbatim {interpolated} string{{}}"" ";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cs'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cs'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.quote.cs'),
          TR.IRelaxedToken(7, 'string.cs'),
          TR.IRelaxedToken(16, 'string.quote.cs'),
          TR.IRelaxedToken(17, 'identifier.cs'),
          TR.IRelaxedToken(29, 'string.quote.cs'),
          TR.IRelaxedToken(30, 'string.cs'),
          TR.IRelaxedToken(37, 'string.escape.cs'),
          TR.IRelaxedToken(39, 'string.cs'),
          TR.IRelaxedToken(41, 'string.escape.cs'),
          TR.IRelaxedToken(43, 'string.cs'),
          TR.IRelaxedToken(44, 'string.quote.cs'),
          TR.IRelaxedToken(45, 'delimiter.cs'),
        ],
      ),
    ],
  ]);
}

