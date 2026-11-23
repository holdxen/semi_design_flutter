// Generated 1:1 from languages/definitions/coffee/coffee.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('coffeescript')
void runLanguagesDefinitionsCoffeeCoffeeTestCases() {
  TR.testTokenization('coffeescript', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    # a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = 1 # my comment # is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = 1e #is a exponent number',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.float.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = 0x1F #is a hex number',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.hex.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'new x = switch()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.new.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.switch.coffee'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test [do]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.square.coffee'),
          TR.IRelaxedToken(7, 'keyword.do.coffee'),
          TR.IRelaxedToken(9, 'delimiter.square.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'this do',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'keyword.do.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    new    ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.new.coffee'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '### a simple comment ###',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'new x = ### a simple comment ### 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.new.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.coffee'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'number.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'new x = ### comment ### 1 ###',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.new.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.coffee'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'number.coffee'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = ######s',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.coffee'),
          TR.IRelaxedToken(10, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = ###/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '### a multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'can actually span',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'multiple lines ###',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'new x = ### start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.new.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'and end it ### new a = 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'keyword.new.coffee'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(21, 'delimiter.coffee'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'number.coffee'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'b(\'\'\'asdads\'\'\')',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(2, 'string.coffee'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo(""" var i = \'foo\'; """)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(4, 'string.coffee'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'for a = \'a\';',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.for.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.coffee'),
          TR.IRelaxedToken(11, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"use strict";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'b = a + " \'cool\'  "',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping \\"quotes\\" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
          TR.IRelaxedToken(10, 'string.escape.coffee'),
          TR.IRelaxedToken(12, 'string.coffee'),
          TR.IRelaxedToken(18, 'string.escape.coffee'),
          TR.IRelaxedToken(20, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\\\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
          TR.IRelaxedToken(1, 'string.escape.coffee'),
          TR.IRelaxedToken(3, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'be careful \\not to escape\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
          TR.IRelaxedToken(12, 'string.escape.coffee'),
          TR.IRelaxedToken(14, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'a multiline string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        'second line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"for a = \'a\'; #{ new } works"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'keyword.new.coffee'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"a comment with nested code #{ 2 / 3 } works"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.coffee'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'delimiter.coffee'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'number.coffee'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'number.coffee'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
          TR.IRelaxedToken(1, 'delimiter.coffee'),
          TR.IRelaxedToken(2, 'number.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
          TR.IRelaxedToken(3, 'delimiter.coffee'),
          TR.IRelaxedToken(4, 'number.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '01239',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[1,2,3]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.coffee'),
          TR.IRelaxedToken(1, 'number.coffee'),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, 'number.coffee'),
          TR.IRelaxedToken(4, 'delimiter.coffee'),
          TR.IRelaxedToken(5, 'number.coffee'),
          TR.IRelaxedToken(6, 'delimiter.square.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo(123);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(4, 'number.coffee'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(8, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '(a:(b:[]))',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, 'delimiter.square.coffee'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = \'[{()}]\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/ /',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/abc\\/asd/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'new r = /sweet"regular exp" \\/ cool/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.new.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'regexp.coffee'),
          TR.IRelaxedToken(36, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5 / 3;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.coffee'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/// a multiline regex',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
        ],
      ),
      TR.ITestItem(
        'can actually span',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
        ],
      ),
      TR.ITestItem(
        'multiplelines with # comments',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
          TR.IRelaxedToken(19, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'multiple lines ///',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '///',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
        ],
      ),
      TR.ITestItem(
        '#comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; # comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(7, 'comment.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2 / x / b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(10, 'delimiter.coffee'),
          TR.IRelaxedToken(11, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a /ads/ b;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /foo/.test(\'\')',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'regexp.coffee'),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(15, 'string.coffee'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = 1 + f(2 / 3, /foo/)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(10, 'number.coffee'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.coffee'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.coffee'),
          TR.IRelaxedToken(15, 'delimiter.coffee'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'regexp.coffee'),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1/(2/3)/2/3;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.coffee'),
          TR.IRelaxedToken(1, 'delimiter.coffee'),
          TR.IRelaxedToken(2, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(3, 'number.coffee'),
          TR.IRelaxedToken(4, 'delimiter.coffee'),
          TR.IRelaxedToken(5, 'number.coffee'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, 'number.coffee'),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, 'number.coffee'),
          TR.IRelaxedToken(11, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{ key: 123 }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.coffee'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.curly.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[1,2,3]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.coffee'),
          TR.IRelaxedToken(1, 'number.coffee'),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, 'number.coffee'),
          TR.IRelaxedToken(4, 'delimiter.coffee'),
          TR.IRelaxedToken(5, 'number.coffee'),
          TR.IRelaxedToken(6, 'delimiter.square.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo(123);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(4, 'number.coffee'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(8, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{a:{b:[]}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.coffee'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, 'delimiter.curly.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, 'delimiter.square.coffee'),
          TR.IRelaxedToken(8, 'delimiter.curly.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = \'[{()}]\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.coffee'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"/api/v2/course/#{ \$stateParams.courseId }/grading/student/#{\$stateParams.studentId}",',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(31, 'delimiter.coffee'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(41, 'string.coffee'),
          TR.IRelaxedToken(61, ''),
          TR.IRelaxedToken(73, 'delimiter.coffee'),
          TR.IRelaxedToken(74, ''),
          TR.IRelaxedToken(83, 'string.coffee'),
          TR.IRelaxedToken(85, 'delimiter.coffee'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# Assignment:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'number   = 42',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        'opposite = true',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.true.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Conditions:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'number = -42 if opposite',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, 'number.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.if.coffee'),
          TR.IRelaxedToken(15, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Functions:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'square = (x) -> x * x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.coffee'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(18, 'delimiter.coffee'),
          TR.IRelaxedToken(19, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Arrays:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'list = [1, 2, 3, 4, 5]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.square.coffee'),
          TR.IRelaxedToken(8, 'number.coffee'),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.coffee'),
          TR.IRelaxedToken(12, 'delimiter.coffee'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.coffee'),
          TR.IRelaxedToken(15, 'delimiter.coffee'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'number.coffee'),
          TR.IRelaxedToken(18, 'delimiter.coffee'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'number.coffee'),
          TR.IRelaxedToken(21, 'delimiter.square.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Objects:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'math =',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '  root:   Math.sqrt',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(14, 'delimiter.coffee'),
          TR.IRelaxedToken(15, ''),
        ],
      ),
      TR.ITestItem(
        '  square: square',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
      TR.ITestItem(
        '  cube:   (x) -> x * square x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.coffee'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(19, 'delimiter.coffee'),
          TR.IRelaxedToken(20, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Splats:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'race = (winner, runners...) ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(14, 'delimiter.coffee'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(23, 'delimiter.coffee'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '  print winner, runners',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(14, 'delimiter.coffee'),
          TR.IRelaxedToken(15, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Existence:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'alert "I knew it!" if elvis?',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'string.coffee'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'keyword.if.coffee'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(27, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Array comprehensions:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'cubes = (math.cube num for num in list)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(13, 'delimiter.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(23, 'keyword.for.coffee'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(31, 'keyword.in.coffee'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(38, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'fill = (container, liquid = "coffee") ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(17, 'delimiter.coffee'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(26, 'delimiter.coffee'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'string.coffee'),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '  "Filling the #{container} with #{liquid}..."',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.coffee'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(26, 'string.coffee'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(41, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'ong = ["do", "re", "mi", "fa", "so"]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.square.coffee'),
          TR.IRelaxedToken(7, 'string.coffee'),
          TR.IRelaxedToken(11, 'delimiter.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'string.coffee'),
          TR.IRelaxedToken(17, 'delimiter.coffee'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'string.coffee'),
          TR.IRelaxedToken(23, 'delimiter.coffee'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'string.coffee'),
          TR.IRelaxedToken(29, 'delimiter.coffee'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'string.coffee'),
          TR.IRelaxedToken(35, 'delimiter.square.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'singers = {Jagger: "Rock", Elvis: "Roll"}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.curly.coffee'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(17, 'delimiter.coffee'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'string.coffee'),
          TR.IRelaxedToken(25, 'delimiter.coffee'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(32, 'delimiter.coffee'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'string.coffee'),
          TR.IRelaxedToken(40, 'delimiter.curly.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'bitlist = [',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.square.coffee'),
        ],
      ),
      TR.ITestItem(
        '  1, 0, 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'number.coffee'),
          TR.IRelaxedToken(3, 'delimiter.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.coffee'),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        '  0, 0, 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'number.coffee'),
          TR.IRelaxedToken(3, 'delimiter.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.coffee'),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        '  1, 1, 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'number.coffee'),
          TR.IRelaxedToken(3, 'delimiter.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.coffee'),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        ']',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'kids =',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '  brother:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '    name: "Max"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '    age:  11',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(10, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        '  sister:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '    name: "Ida"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '    age:  9',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(10, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '\$(\'.account\').attr class: \'active\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(2, 'string.coffee'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(13, 'delimiter.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(19, 'keyword.class.coffee'),
          TR.IRelaxedToken(24, 'delimiter.coffee'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        'log object.class',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(10, 'delimiter.coffee'),
          TR.IRelaxedToken(11, 'keyword.class.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'outer = 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        'changeNumbers = ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(14, 'delimiter.coffee'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        'inner = -1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        'outer = 10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        'inner = changeNumbers()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'mood = greatlyImproved if singing',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(23, 'keyword.if.coffee'),
          TR.IRelaxedToken(25, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'if happy and knowsIt',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.if.coffee'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(9, 'keyword.and.coffee'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        '  clapsHands()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        '  chaChaCha()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        'else',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.else.coffee'),
        ],
      ),
      TR.ITestItem(
        '  showIt()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'date = if friday then sue else jill',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.if.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(17, 'keyword.then.coffee'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(26, 'keyword.else.coffee'),
          TR.IRelaxedToken(30, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'options or= defaults',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'keyword.or.coffee'),
          TR.IRelaxedToken(10, 'delimiter.coffee'),
          TR.IRelaxedToken(11, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Eat lunch.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'eat food for food in [\'toast\', \'cheese\', \'wine\']',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'keyword.for.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(18, 'keyword.in.coffee'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.square.coffee'),
          TR.IRelaxedToken(22, 'string.coffee'),
          TR.IRelaxedToken(29, 'delimiter.coffee'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'string.coffee'),
          TR.IRelaxedToken(39, 'delimiter.coffee'),
          TR.IRelaxedToken(40, ''),
          TR.IRelaxedToken(41, 'string.coffee'),
          TR.IRelaxedToken(47, 'delimiter.square.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Fine five course dining.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'courses = [\'greens\', \'caviar\', \'truffles\', \'roast\', \'cake\']',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.square.coffee'),
          TR.IRelaxedToken(11, 'string.coffee'),
          TR.IRelaxedToken(19, 'delimiter.coffee'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'string.coffee'),
          TR.IRelaxedToken(29, 'delimiter.coffee'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'string.coffee'),
          TR.IRelaxedToken(41, 'delimiter.coffee'),
          TR.IRelaxedToken(42, ''),
          TR.IRelaxedToken(43, 'string.coffee'),
          TR.IRelaxedToken(50, 'delimiter.coffee'),
          TR.IRelaxedToken(51, ''),
          TR.IRelaxedToken(52, 'string.coffee'),
          TR.IRelaxedToken(58, 'delimiter.square.coffee'),
        ],
      ),
      TR.ITestItem(
        'menu i + 1, dish for dish, i in courses',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'number.coffee'),
          TR.IRelaxedToken(10, 'delimiter.coffee'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(17, 'keyword.for.coffee'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(25, 'delimiter.coffee'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(29, 'keyword.in.coffee'),
          TR.IRelaxedToken(31, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Health conscious meal.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'foods = [\'broccoli\', \'spinach\', \'chocolate\']',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.square.coffee'),
          TR.IRelaxedToken(9, 'string.coffee'),
          TR.IRelaxedToken(19, 'delimiter.coffee'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'string.coffee'),
          TR.IRelaxedToken(30, 'delimiter.coffee'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'string.coffee'),
          TR.IRelaxedToken(43, 'delimiter.square.coffee'),
        ],
      ),
      TR.ITestItem(
        'eat food for food in foods when food isnt \'chocolate\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'keyword.for.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(18, 'keyword.in.coffee'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(27, 'keyword.when.coffee'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(37, 'keyword.isnt.coffee'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'countdown = (num for num in [10..1])',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(10, 'delimiter.coffee'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(17, 'keyword.for.coffee'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(25, 'keyword.in.coffee'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.square.coffee'),
          TR.IRelaxedToken(29, 'number.coffee'),
          TR.IRelaxedToken(31, 'delimiter.coffee'),
          TR.IRelaxedToken(33, 'number.coffee'),
          TR.IRelaxedToken(34, 'delimiter.square.coffee'),
          TR.IRelaxedToken(35, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'yearsOld = max: 10, ida: 9, tim: 11',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(14, 'delimiter.coffee'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'number.coffee'),
          TR.IRelaxedToken(18, 'delimiter.coffee'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(23, 'delimiter.coffee'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'number.coffee'),
          TR.IRelaxedToken(26, 'delimiter.coffee'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(31, 'delimiter.coffee'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'ages = for child, age of yearsOld',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.for.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(16, 'delimiter.coffee'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(22, 'keyword.of.coffee'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
      TR.ITestItem(
        '  "#{child} is #{age}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(10, 'string.coffee'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(20, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Econ 101',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'if this.studyingEconomics',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.if.coffee'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'variable.predefined.coffee'),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
        ],
      ),
      TR.ITestItem(
        '  buy()  while supply > demand',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(9, 'keyword.while.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(22, 'delimiter.coffee'),
          TR.IRelaxedToken(23, ''),
        ],
      ),
      TR.ITestItem(
        '  sell() until supply > demand',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.until.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(22, 'delimiter.coffee'),
          TR.IRelaxedToken(23, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Nursery Rhyme',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'num = 6',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        'lyrics = while num -= 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.while.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(19, 'delimiter.coffee'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        '  "#{num} little monkeys, jumping on the bed.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(8, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '    One fell out and bumped his head."',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '# Everything is an Expression (at least, as much as possible)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'grade = (student) ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '  if student.excellentWork',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.if.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(12, 'delimiter.coffee'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
      TR.ITestItem(
        '    "A+"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '  else if student.okayStuff',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.else.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.if.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(17, 'delimiter.coffee'),
          TR.IRelaxedToken(18, ''),
        ],
      ),
      TR.ITestItem(
        '    if student.triedHard then "B" else "B-"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.if.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(14, 'delimiter.coffee'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(25, 'keyword.then.coffee'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'string.coffee'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'keyword.else.coffee'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '  else',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.else.coffee'),
        ],
      ),
      TR.ITestItem(
        '    "C"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'eldest = if 24 > 21 then "Liz" else "Ike"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.if.coffee'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'number.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.coffee'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'number.coffee'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'keyword.then.coffee'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'string.coffee'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'keyword.else.coffee'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(36, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#Classes, Inheritance and Super',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'class Animal',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.class.coffee'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
      TR.ITestItem(
        '  constructor: (@name) ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(13, 'delimiter.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(16, 'variable.predefined.coffee'),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '  move: (meters) ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '    alert @name + " moved #{meters}m."',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(10, 'variable.predefined.coffee'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.coffee'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.coffee'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(34, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'class Snake extends Animal',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.class.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(12, 'keyword.extends.coffee'),
          TR.IRelaxedToken(19, ''),
        ],
      ),
      TR.ITestItem(
        '  move: ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '    alert "Slithering..."',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(10, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '    super 5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.super.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'class Horse extends Animal',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.class.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(12, 'keyword.extends.coffee'),
          TR.IRelaxedToken(19, ''),
        ],
      ),
      TR.ITestItem(
        '  move: ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '    alert "Galloping..."',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(10, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '    super 45',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.super.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'sam = new Snake "Sammy the Python"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.new.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(16, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        'tom = new Horse "Tommy the Palomino"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.coffee'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.new.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(16, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'sam.move()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        'tom.move()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.coffee'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#Function binding',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'Account = (customer, cart) ->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(19, 'delimiter.coffee'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(25, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '  @customer = customer',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.predefined.coffee'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.coffee'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
      TR.ITestItem(
        '  @cart = cart',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.predefined.coffee'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.coffee'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '  \$(\'.shopping_cart\').bind \'click\', (event) =>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(4, 'string.coffee'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(21, 'delimiter.coffee'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(27, 'string.coffee'),
          TR.IRelaxedToken(34, 'delimiter.coffee'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(42, 'delimiter.parenthesis.coffee'),
          TR.IRelaxedToken(43, ''),
          TR.IRelaxedToken(44, 'delimiter.coffee'),
        ],
      ),
      TR.ITestItem(
        '    @customer.purchase @cart',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'variable.predefined.coffee'),
          TR.IRelaxedToken(13, 'delimiter.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(23, 'variable.predefined.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#Switch/When/Else\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'switch day',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.switch.coffee'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
      TR.ITestItem(
        '  when "Mon" then go work',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.when.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.then.coffee'),
          TR.IRelaxedToken(17, ''),
        ],
      ),
      TR.ITestItem(
        '  when "Tue" then go relax',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.when.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.then.coffee'),
          TR.IRelaxedToken(17, ''),
        ],
      ),
      TR.ITestItem(
        '  when "Thu" then go iceFishing',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.when.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.then.coffee'),
          TR.IRelaxedToken(17, ''),
        ],
      ),
      TR.ITestItem(
        '  when "Fri", "Sat"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.when.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.coffee'),
          TR.IRelaxedToken(12, 'delimiter.coffee'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '    if day is bingoDay',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.if.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(11, 'keyword.is.coffee'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
      TR.ITestItem(
        '      go bingo',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '      go dancing',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '  when "Sun" then go church',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.when.coffee'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.coffee'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.then.coffee'),
          TR.IRelaxedToken(17, ''),
        ],
      ),
      TR.ITestItem(
        '  else go work',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.else.coffee'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
      TR.ITestItem(
        ' ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '#Try/Catch/Finally',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'try',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.try.coffee'),
        ],
      ),
      TR.ITestItem(
        '  allHellBreaksLoose()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        '  catsAndDogsLivingTogether()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        'catch error',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.catch.coffee'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
      TR.ITestItem(
        '  print error',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        'finally',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.finally.coffee'),
        ],
      ),
      TR.ITestItem(
        '  cleanUp()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#String Interpolation and Block Comments',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'author = "Wittgenstein"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        'quote  = "A picture is a fact. -- #{ author }"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'delimiter.coffee'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.coffee'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(44, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'sentence = "#{ 22 / 7 } is a decent approximation of p"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.coffee'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.coffee'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.coffee'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'number.coffee'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'mobyDick = "Call me Ishmael. Some years ago --',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        ' never mind how long precisely -- having little',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        ' or no money in my purse, and nothing particular',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        ' to interest me on shore, I thought I would sail',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        ' about a little and see the watery part of the',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        ' world..."',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#Extended Regular Expressions',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        'OPERATOR = /// ^ (',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'delimiter.coffee'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'regexp.coffee'),
        ],
      ),
      TR.ITestItem(
        '  ?: [-=]>             # function',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
          TR.IRelaxedToken(23, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        '   | [-+*/%<>&|^!?=]=  # compound assign / compare',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
          TR.IRelaxedToken(23, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        '   | >>>=?             # zero-fill right shift',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
          TR.IRelaxedToken(23, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        '   | ([-+:])\\1         # doubles',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
          TR.IRelaxedToken(23, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        '   | ([&|<>])\\2=?      # logic / shift',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
          TR.IRelaxedToken(23, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        '   | \\?\\.              # soak access',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
          TR.IRelaxedToken(23, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        '   | \\.{2,3}           # range or splat',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
          TR.IRelaxedToken(23, 'comment.coffee'),
        ],
      ),
      TR.ITestItem(
        ') ///',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.coffee'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
  ]);
}

