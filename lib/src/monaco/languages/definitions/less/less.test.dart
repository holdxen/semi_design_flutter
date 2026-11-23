// Generated 1:1 from languages/definitions/less/less.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('less')
void runLanguagesDefinitionsLessLessTestCases() {
  TR.testTokenization(<String>['less', 'javascript'], <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'isnumber(10);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.less'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(9, 'attribute.value.number.less'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(12, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'iskeyword(@test) ;mix',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.less'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(10, 'variable.less'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.less'),
          TR.IRelaxedToken(18, 'keyword.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'whenn',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    round    ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.less'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'isnumber(10px);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.less'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(9, 'attribute.value.number.less'),
          TR.IRelaxedToken(11, 'attribute.value.unit.less'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(14, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'pxx ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: "I\'m a LESS String";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(25, 'string.delimiter.less'),
          TR.IRelaxedToken(26, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: "concatenated" + "String";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(20, 'string.delimiter.less'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'operator.less'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'string.delimiter.less'),
          TR.IRelaxedToken(25, 'string.less'),
          TR.IRelaxedToken(31, 'string.delimiter.less'),
          TR.IRelaxedToken(32, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: "quote in\'adasdsa\\"asd\' a string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(39, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: \'doublequote in"ada\\\'sds\\\'a"asd a string\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(47, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* start of multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        'a comment between without a star',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        'when /* start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.less'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        'and end it */ 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'attribute.value.number.less'),
          TR.IRelaxedToken(15, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'attribute.value.number.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'attribute.value.number.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' 0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'attribute.value.number.less'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'attribute.value.number.less'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: 0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'attribute.value.number.less'),
          TR.IRelaxedToken(8, 'operator.less'),
          TR.IRelaxedToken(9, 'attribute.value.number.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: 100+10.00',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'attribute.value.number.less'),
          TR.IRelaxedToken(10, 'operator.less'),
          TR.IRelaxedToken(11, 'attribute.value.number.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: 0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'attribute.value.number.less'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'operator.less'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.number.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'attribute.value.number.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#012343',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'attribute.value.hex.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[1,2,3]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.bracket.less'),
          TR.IRelaxedToken(1, 'attribute.value.number.less'),
          TR.IRelaxedToken(2, 'delimiter.less'),
          TR.IRelaxedToken(3, 'attribute.value.number.less'),
          TR.IRelaxedToken(4, 'delimiter.less'),
          TR.IRelaxedToken(5, 'attribute.value.number.less'),
          TR.IRelaxedToken(6, 'delimiter.bracket.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo(123);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(4, 'attribute.value.number.less'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(8, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: \'[{()}]\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(14, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@something : 2; // my comment // this is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.less'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'attribute.value.number.less'),
          TR.IRelaxedToken(14, 'delimiter.less'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.something(@some, @other) when (iscolor(@other)) { aname// my commen',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(11, 'variable.less'),
          TR.IRelaxedToken(16, 'delimiter.less'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'variable.less'),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'keyword.less'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(32, 'keyword.less'),
          TR.IRelaxedToken(39, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(40, 'variable.less'),
          TR.IRelaxedToken(46, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(49, 'delimiter.curly.less'),
          TR.IRelaxedToken(50, ''),
          TR.IRelaxedToken(51, 'tag.less'),
          TR.IRelaxedToken(56, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.something(@some//mycomment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(11, 'variable.less'),
          TR.IRelaxedToken(16, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@something : #2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.less'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'attribute.value.hex.less'),
          TR.IRelaxedToken(15, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/*slcomment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* slcomment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/*sl/com* ment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/**/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@something: /*comm/* * /ent*/2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(10, 'delimiter.less'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'comment.less'),
          TR.IRelaxedToken(29, 'attribute.value.number.less'),
          TR.IRelaxedToken(30, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@something: /*comment*/ 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(10, 'delimiter.less'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'comment.less'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'attribute.value.number.less'),
          TR.IRelaxedToken(25, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        'can actually span',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        'multiple lines */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@some /* start a comment here',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        ' span over this line and ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        'end it there */ : 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.less'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'attribute.value.number.less'),
          TR.IRelaxedToken(19, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.class { filter: ~"ms:alwaysHasItsOwnSyntax.For.Stuff()";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.curly.less'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'attribute.name.less'),
          TR.IRelaxedToken(15, 'delimiter.less'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'string.delimiter.less'),
          TR.IRelaxedToken(19, 'string.less'),
          TR.IRelaxedToken(55, 'string.delimiter.less'),
          TR.IRelaxedToken(56, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.class {.mixin (@a) when (@a > 10), (@a < -10) { }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.curly.less'),
          TR.IRelaxedToken(8, 'tag.class.less'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(16, 'variable.less'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'keyword.less'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(26, 'variable.less'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'operator.less'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'attribute.value.number.less'),
          TR.IRelaxedToken(33, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(34, 'delimiter.less'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(37, 'variable.less'),
          TR.IRelaxedToken(39, ''),
          TR.IRelaxedToken(40, 'operator.less'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'operator.less'),
          TR.IRelaxedToken(43, 'attribute.value.number.less'),
          TR.IRelaxedToken(45, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(46, ''),
          TR.IRelaxedToken(47, 'delimiter.curly.less'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(49, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.truth (@a) when (@a = true) { }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(8, 'variable.less'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'keyword.less'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(18, 'variable.less'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'operator.less'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'keyword.less'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'delimiter.curly.less'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.max (@a, @b) when (@a > @b) { width: @a; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(6, 'variable.less'),
          TR.IRelaxedToken(8, 'delimiter.less'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'variable.less'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.less'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(20, 'variable.less'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'operator.less'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'variable.less'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'delimiter.curly.less'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'attribute.name.less'),
          TR.IRelaxedToken(36, 'delimiter.less'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'variable.less'),
          TR.IRelaxedToken(40, 'delimiter.less'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.mixin (@a, @b: 0) when (isnumber(@b)) { }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(8, 'variable.less'),
          TR.IRelaxedToken(10, 'delimiter.less'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'variable.less'),
          TR.IRelaxedToken(14, 'delimiter.less'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'attribute.value.number.less'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'keyword.less'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(25, 'keyword.less'),
          TR.IRelaxedToken(33, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(34, 'variable.less'),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'delimiter.curly.less'),
          TR.IRelaxedToken(40, ''),
          TR.IRelaxedToken(41, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.mixin (@a, @b: black) when (iscolor(@b)) { }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(8, 'variable.less'),
          TR.IRelaxedToken(10, 'delimiter.less'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'variable.less'),
          TR.IRelaxedToken(14, 'delimiter.less'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'attribute.value.less'),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'keyword.less'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(29, 'keyword.less'),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(37, 'variable.less'),
          TR.IRelaxedToken(39, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(41, ''),
          TR.IRelaxedToken(42, 'delimiter.curly.less'),
          TR.IRelaxedToken(43, ''),
          TR.IRelaxedToken(44, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@test: `function display()` //works well',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.backtick.less'),
          TR.IRelaxedToken(8, 'keyword.js'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'identifier.js'),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.js'),
          TR.IRelaxedToken(26, 'delimiter.backtick.less'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'comment.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.box-shadow(inset 0 1px 1px rgba(0,0,0,.075), 0 0 8px rgba(82,168,236,.6));',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(12, 'attribute.value.less'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'attribute.value.number.less'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'attribute.value.number.less'),
          TR.IRelaxedToken(21, 'attribute.value.unit.less'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'attribute.value.number.less'),
          TR.IRelaxedToken(25, 'attribute.value.unit.less'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'attribute.value.less'),
          TR.IRelaxedToken(32, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(33, 'attribute.value.number.less'),
          TR.IRelaxedToken(34, 'delimiter.less'),
          TR.IRelaxedToken(35, 'attribute.value.number.less'),
          TR.IRelaxedToken(36, 'delimiter.less'),
          TR.IRelaxedToken(37, 'attribute.value.number.less'),
          TR.IRelaxedToken(38, 'delimiter.less'),
          TR.IRelaxedToken(39, 'attribute.value.number.less'),
          TR.IRelaxedToken(43, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(44, 'delimiter.less'),
          TR.IRelaxedToken(45, ''),
          TR.IRelaxedToken(46, 'attribute.value.number.less'),
          TR.IRelaxedToken(47, ''),
          TR.IRelaxedToken(48, 'attribute.value.number.less'),
          TR.IRelaxedToken(49, ''),
          TR.IRelaxedToken(50, 'attribute.value.number.less'),
          TR.IRelaxedToken(51, 'attribute.value.unit.less'),
          TR.IRelaxedToken(53, ''),
          TR.IRelaxedToken(54, 'attribute.value.less'),
          TR.IRelaxedToken(58, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(59, 'attribute.value.number.less'),
          TR.IRelaxedToken(61, 'delimiter.less'),
          TR.IRelaxedToken(62, 'attribute.value.number.less'),
          TR.IRelaxedToken(65, 'delimiter.less'),
          TR.IRelaxedToken(66, 'attribute.value.number.less'),
          TR.IRelaxedToken(69, 'delimiter.less'),
          TR.IRelaxedToken(70, 'attribute.value.number.less'),
          TR.IRelaxedToken(72, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(74, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'input[type="radio"]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(5, 'delimiter.bracket.less'),
          TR.IRelaxedToken(6, 'tag.less'),
          TR.IRelaxedToken(10, 'operator.less'),
          TR.IRelaxedToken(11, 'string.delimiter.less'),
          TR.IRelaxedToken(12, 'string.less'),
          TR.IRelaxedToken(17, 'string.delimiter.less'),
          TR.IRelaxedToken(18, 'delimiter.bracket.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~\'.offset@{index}\')',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delimiter.less'),
          TR.IRelaxedToken(2, 'string.less'),
          TR.IRelaxedToken(17, 'string.delimiter.less'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'some("\\42");',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(5, 'string.delimiter.less'),
          TR.IRelaxedToken(6, 'string.less'),
          TR.IRelaxedToken(9, 'string.delimiter.less'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(11, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' ~ "icon-"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'operator.less'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'string.delimiter.less'),
          TR.IRelaxedToken(4, 'string.less'),
          TR.IRelaxedToken(9, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'class^="icon-"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(5, 'operator.less'),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(13, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'class*="icon-"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(5, 'operator.less'),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(13, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'class~="icon-"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(5, 'operator.less'),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(13, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'class ~ = "icon-"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.less'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'operator.less'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'string.delimiter.less'),
          TR.IRelaxedToken(11, 'string.less'),
          TR.IRelaxedToken(16, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'class|="icon-"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(5, 'operator.less'),
          TR.IRelaxedToken(7, 'string.delimiter.less'),
          TR.IRelaxedToken(8, 'string.less'),
          TR.IRelaxedToken(13, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.hide-text { font: 0/0 a; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.curly.less'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'attribute.name.less'),
          TR.IRelaxedToken(17, 'delimiter.less'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'attribute.value.number.less'),
          TR.IRelaxedToken(20, 'operator.less'),
          TR.IRelaxedToken(21, 'attribute.value.number.less'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'attribute.value.less'),
          TR.IRelaxedToken(24, 'delimiter.less'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.translate3d(@x, @y, @z) { -webkit-transform: translate3d(@x, @y, @z); }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(13, 'variable.less'),
          TR.IRelaxedToken(15, 'delimiter.less'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'variable.less'),
          TR.IRelaxedToken(19, 'delimiter.less'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'variable.less'),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'delimiter.curly.less'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'attribute.name.less'),
          TR.IRelaxedToken(44, 'delimiter.less'),
          TR.IRelaxedToken(45, ''),
          TR.IRelaxedToken(46, 'attribute.value.less'),
          TR.IRelaxedToken(57, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(58, 'variable.less'),
          TR.IRelaxedToken(60, 'delimiter.less'),
          TR.IRelaxedToken(61, ''),
          TR.IRelaxedToken(62, 'variable.less'),
          TR.IRelaxedToken(64, 'delimiter.less'),
          TR.IRelaxedToken(65, ''),
          TR.IRelaxedToken(66, 'variable.less'),
          TR.IRelaxedToken(68, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(69, 'delimiter.less'),
          TR.IRelaxedToken(70, ''),
          TR.IRelaxedToken(71, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.dropdown-menu > li > a:hover > [class=" icon-"]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'operator.less'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'tag.less'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'operator.less'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'tag.less'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'operator.less'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'delimiter.bracket.less'),
          TR.IRelaxedToken(33, 'tag.less'),
          TR.IRelaxedToken(38, 'operator.less'),
          TR.IRelaxedToken(39, 'string.delimiter.less'),
          TR.IRelaxedToken(40, 'string.less'),
          TR.IRelaxedToken(46, 'string.delimiter.less'),
          TR.IRelaxedToken(47, 'delimiter.bracket.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.bw-gradient(@color: #F5F5F5, @start: 0, @stop: 255) { background: -webkit-gradient(color-stop(0, rgb(@start,@start,@start)), color-stop(1, rgb(@stop,@stop,@stop))); }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(13, 'variable.less'),
          TR.IRelaxedToken(19, 'delimiter.less'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'attribute.value.hex.less'),
          TR.IRelaxedToken(28, 'delimiter.less'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'variable.less'),
          TR.IRelaxedToken(36, 'delimiter.less'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'attribute.value.number.less'),
          TR.IRelaxedToken(39, 'delimiter.less'),
          TR.IRelaxedToken(40, ''),
          TR.IRelaxedToken(41, 'variable.less'),
          TR.IRelaxedToken(46, 'delimiter.less'),
          TR.IRelaxedToken(47, ''),
          TR.IRelaxedToken(48, 'attribute.value.number.less'),
          TR.IRelaxedToken(51, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(52, ''),
          TR.IRelaxedToken(53, 'delimiter.curly.less'),
          TR.IRelaxedToken(54, ''),
          TR.IRelaxedToken(55, 'attribute.name.less'),
          TR.IRelaxedToken(65, 'delimiter.less'),
          TR.IRelaxedToken(66, ''),
          TR.IRelaxedToken(67, 'attribute.value.less'),
          TR.IRelaxedToken(83, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(84, 'attribute.value.less'),
          TR.IRelaxedToken(94, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(95, 'attribute.value.number.less'),
          TR.IRelaxedToken(96, 'delimiter.less'),
          TR.IRelaxedToken(97, ''),
          TR.IRelaxedToken(98, 'attribute.value.less'),
          TR.IRelaxedToken(101, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(102, 'variable.less'),
          TR.IRelaxedToken(108, 'delimiter.less'),
          TR.IRelaxedToken(109, 'variable.less'),
          TR.IRelaxedToken(115, 'delimiter.less'),
          TR.IRelaxedToken(116, 'variable.less'),
          TR.IRelaxedToken(122, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(124, 'delimiter.less'),
          TR.IRelaxedToken(125, ''),
          TR.IRelaxedToken(126, 'attribute.value.less'),
          TR.IRelaxedToken(136, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(137, 'attribute.value.number.less'),
          TR.IRelaxedToken(138, 'delimiter.less'),
          TR.IRelaxedToken(139, ''),
          TR.IRelaxedToken(140, 'attribute.value.less'),
          TR.IRelaxedToken(143, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(144, 'variable.less'),
          TR.IRelaxedToken(149, 'delimiter.less'),
          TR.IRelaxedToken(150, 'variable.less'),
          TR.IRelaxedToken(155, 'delimiter.less'),
          TR.IRelaxedToken(156, 'variable.less'),
          TR.IRelaxedToken(161, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(164, 'delimiter.less'),
          TR.IRelaxedToken(165, ''),
          TR.IRelaxedToken(166, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '      body ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'tag.less'),
          TR.IRelaxedToken(10, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'body {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '  margin: 0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(8, 'delimiter.less'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'attribute.value.number.less'),
          TR.IRelaxedToken(11, 'delimiter.less'),
        ],
      ),
      TR.ITestItem(
        '  padding: 3em 6em;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(9, 'delimiter.less'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.number.less'),
          TR.IRelaxedToken(12, 'attribute.value.unit.less'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'attribute.value.number.less'),
          TR.IRelaxedToken(16, 'attribute.value.unit.less'),
          TR.IRelaxedToken(18, 'delimiter.less'),
        ],
      ),
      TR.ITestItem(
        '  font-family: tahoma, arial, sans-serif;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(13, 'delimiter.less'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'attribute.value.less'),
          TR.IRelaxedToken(21, 'delimiter.less'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'attribute.value.less'),
          TR.IRelaxedToken(28, 'delimiter.less'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'attribute.value.less'),
          TR.IRelaxedToken(40, 'delimiter.less'),
        ],
      ),
      TR.ITestItem(
        '  text-decoration: none !important;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(17, 'delimiter.less'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'attribute.value.less'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'keyword.less'),
          TR.IRelaxedToken(34, 'delimiter.less'),
        ],
      ),
      TR.ITestItem(
        '  color: #000;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(7, 'delimiter.less'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'attribute.value.hex.less'),
          TR.IRelaxedToken(13, 'delimiter.less'),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '* { padding: 3em -9pt -0.5px; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.less'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.less'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'attribute.name.less'),
          TR.IRelaxedToken(11, 'delimiter.less'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'attribute.value.number.less'),
          TR.IRelaxedToken(14, 'attribute.value.unit.less'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'operator.less'),
          TR.IRelaxedToken(18, 'attribute.value.number.less'),
          TR.IRelaxedToken(19, 'attribute.value.unit.less'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'operator.less'),
          TR.IRelaxedToken(23, 'attribute.value.number.less'),
          TR.IRelaxedToken(26, 'attribute.value.unit.less'),
          TR.IRelaxedToken(28, 'delimiter.less'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'h1 /*comment*/ p {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'comment.less'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'tag.less'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'h1 /*com',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'comment.less'),
        ],
      ),
      TR.ITestItem(
        'ment*/ p',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'tag.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#myID {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.id.less'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.myID {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@import url("something.less");',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.less'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'tag.less'),
          TR.IRelaxedToken(12, 'string.delimiter.less'),
          TR.IRelaxedToken(13, 'string.less'),
          TR.IRelaxedToken(27, 'string.delimiter.less'),
          TR.IRelaxedToken(28, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(29, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'body {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '  content: "con\\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(9, 'delimiter.less'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.delimiter.less'),
          TR.IRelaxedToken(12, 'string.less'),
        ],
      ),
      TR.ITestItem(
        'tent";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.less'),
          TR.IRelaxedToken(4, 'string.delimiter.less'),
          TR.IRelaxedToken(5, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'body {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '  content: "";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(9, 'delimiter.less'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.delimiter.less'),
          TR.IRelaxedToken(13, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@font-face {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '  font-family: "Opificio";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(13, 'delimiter.less'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'string.delimiter.less'),
          TR.IRelaxedToken(16, 'string.less'),
          TR.IRelaxedToken(24, 'string.delimiter.less'),
          TR.IRelaxedToken(25, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"s\\"tr\\"sadsad',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delimiter.less'),
          TR.IRelaxedToken(1, 'string.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'p{}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(1, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'p:nth() {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.less'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@import url("something.css");@import url("something.css");',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.less'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'tag.less'),
          TR.IRelaxedToken(12, 'string.delimiter.less'),
          TR.IRelaxedToken(13, 'string.less'),
          TR.IRelaxedToken(26, 'string.delimiter.less'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(28, 'delimiter.less'),
          TR.IRelaxedToken(29, 'keyword.less'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'tag.less'),
          TR.IRelaxedToken(41, 'string.delimiter.less'),
          TR.IRelaxedToken(42, 'string.less'),
          TR.IRelaxedToken(55, 'string.delimiter.less'),
          TR.IRelaxedToken(56, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(57, 'delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '""""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delimiter.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@import url("something.css");',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.less'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'tag.less'),
          TR.IRelaxedToken(12, 'string.delimiter.less'),
          TR.IRelaxedToken(13, 'string.less'),
          TR.IRelaxedToken(26, 'string.delimiter.less'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(28, 'delimiter.less'),
        ],
      ),
      TR.ITestItem(
        '.rule1{}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(6, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '.rule2{}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.less'),
          TR.IRelaxedToken(6, 'delimiter.curly.less'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@-webkit-keyframes infinite-spinning {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.less'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'tag.less'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '  from {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'tag.less'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '  -webkit-transform: rotate(0deg);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(19, 'delimiter.less'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'attribute.value.less'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(28, 'attribute.value.number.less'),
          TR.IRelaxedToken(29, 'attribute.value.unit.less'),
          TR.IRelaxedToken(32, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(33, 'delimiter.less'),
        ],
      ),
      TR.ITestItem(
        '\t }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '  to {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'tag.less'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '  -webkit-transform: rotate(360deg);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.less'),
          TR.IRelaxedToken(19, 'delimiter.less'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'attribute.value.less'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(28, 'attribute.value.number.less'),
          TR.IRelaxedToken(31, 'attribute.value.unit.less'),
          TR.IRelaxedToken(34, 'delimiter.parenthesis.less'),
          TR.IRelaxedToken(35, 'delimiter.less'),
        ],
      ),
      TR.ITestItem(
        '\t }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.less'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.less'),
        ],
      ),
    ],
  ]);
}

