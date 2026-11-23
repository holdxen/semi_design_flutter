// Generated 1:1 from languages/definitions/pug/pug.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('pug')
void runLanguagesDefinitionsPugPugTestCases() {
  TR.testTokenization('pug', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'p 5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'div#container.stuff',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(3, 'tag.id.pug'),
          TR.IRelaxedToken(13, 'tag.class.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'div.container#stuff',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(3, 'tag.class.pug'),
          TR.IRelaxedToken(13, 'tag.id.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'div.container#stuff .container',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(3, 'tag.class.pug'),
          TR.IRelaxedToken(13, 'tag.id.pug'),
          TR.IRelaxedToken(19, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#tag-id-1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.id.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.tag-id-1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.class.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'input(type="checkbox")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.pug'),
          TR.IRelaxedToken(6, 'attribute.name.pug'),
          TR.IRelaxedToken(10, 'delimiter.pug'),
          TR.IRelaxedToken(11, 'attribute.value.pug'),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'input (type="checkbox")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'input(type="checkbox",name="agreement",checked)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.pug'),
          TR.IRelaxedToken(6, 'attribute.name.pug'),
          TR.IRelaxedToken(10, 'delimiter.pug'),
          TR.IRelaxedToken(11, 'attribute.value.pug'),
          TR.IRelaxedToken(21, 'attribute.delimiter.pug'),
          TR.IRelaxedToken(22, 'attribute.name.pug'),
          TR.IRelaxedToken(26, 'delimiter.pug'),
          TR.IRelaxedToken(27, 'attribute.value.pug'),
          TR.IRelaxedToken(38, 'attribute.delimiter.pug'),
          TR.IRelaxedToken(39, 'attribute.name.pug'),
          TR.IRelaxedToken(46, 'delimiter.parenthesis.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'input(type="checkbox"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.pug'),
          TR.IRelaxedToken(6, 'attribute.name.pug'),
          TR.IRelaxedToken(10, 'delimiter.pug'),
          TR.IRelaxedToken(11, 'attribute.value.pug'),
        ],
      ),
      TR.ITestItem(
        'name="agreement"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'attribute.name.pug'),
          TR.IRelaxedToken(4, 'delimiter.pug'),
          TR.IRelaxedToken(5, 'attribute.value.pug'),
        ],
      ),
      TR.ITestItem(
        'checked)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'attribute.name.pug'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.pug'),
        ],
      ),
      TR.ITestItem(
        'body',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'input(type="checkbox"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.pug'),
          TR.IRelaxedToken(6, 'attribute.name.pug'),
          TR.IRelaxedToken(10, 'delimiter.pug'),
          TR.IRelaxedToken(11, 'attribute.value.pug'),
        ],
      ),
      TR.ITestItem(
        'disabled',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'attribute.name.pug'),
        ],
      ),
      TR.ITestItem(
        'checked)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'attribute.name.pug'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.pug'),
        ],
      ),
      TR.ITestItem(
        'body',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'p print #{count} lines',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(8, 'interpolation.delimiter.pug'),
          TR.IRelaxedToken(10, 'interpolation.pug'),
          TR.IRelaxedToken(15, 'interpolation.delimiter.pug'),
          TR.IRelaxedToken(16, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'p print "#{count}" lines',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(9, 'interpolation.delimiter.pug'),
          TR.IRelaxedToken(11, 'interpolation.pug'),
          TR.IRelaxedToken(16, 'interpolation.delimiter.pug'),
          TR.IRelaxedToken(17, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{ key: 123 }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.pug'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(5, 'delimiter.pug'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.pug'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.curly.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// html#id1.class1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'body hello // not a comment 123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(4, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pug'),
        ],
      ),
      TR.ITestItem(
        '    should be a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pug'),
        ],
      ),
      TR.ITestItem(
        '    should still be a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pug'),
        ],
      ),
      TR.ITestItem(
        'div should not be a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '- var a = 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.var.pug'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(8, 'delimiter.pug'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'each item in items',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.each.pug'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(10, 'keyword.in.pug'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '- var html = "<script></script>"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.var.pug'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(11, 'delimiter.pug'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'string.pug'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'doctype 5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.doctype.pug'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.pug'),
        ],
      ),
      TR.ITestItem(
        'html(lang="en")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.pug'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.pug'),
          TR.IRelaxedToken(5, 'attribute.name.pug'),
          TR.IRelaxedToken(9, 'delimiter.pug'),
          TR.IRelaxedToken(10, 'attribute.value.pug'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.pug'),
        ],
      ),
      TR.ITestItem(
        '    head',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'tag.pug'),
        ],
      ),
      TR.ITestItem(
        '        title= pageTitle',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'tag.pug'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
      TR.ITestItem(
        '        script(type=\'text/javascript\')',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'tag.pug'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.pug'),
          TR.IRelaxedToken(15, 'attribute.name.pug'),
          TR.IRelaxedToken(19, 'delimiter.pug'),
          TR.IRelaxedToken(20, 'attribute.value.pug'),
          TR.IRelaxedToken(37, 'delimiter.parenthesis.pug'),
        ],
      ),
      TR.ITestItem(
        '            if (foo) {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(12, 'keyword.if.pug'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.pug'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.pug'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.curly.pug'),
        ],
      ),
      TR.ITestItem(
        '                bar()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.pug'),
        ],
      ),
      TR.ITestItem(
        '            }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(12, 'delimiter.curly.pug'),
        ],
      ),
      TR.ITestItem(
        '    body',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'tag.pug'),
        ],
      ),
      TR.ITestItem(
        '        // Disclaimer: You will need to turn insertSpaces to true in order for the',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pug'),
        ],
      ),
      TR.ITestItem(
        '         syntax highlighting to kick in properly (especially for comments)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pug'),
        ],
      ),
      TR.ITestItem(
        '            Enjoy :)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pug'),
        ],
      ),
      TR.ITestItem(
        '        h1 Pug - node template engine if in',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'tag.pug'),
          TR.IRelaxedToken(10, ''),
        ],
      ),
      TR.ITestItem(
        '        p.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'tag.pug'),
          TR.IRelaxedToken(9, 'delimiter.pug'),
        ],
      ),
      TR.ITestItem(
        '          text ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '            text',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '          #container',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '         #container',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '        #container',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(8, 'tag.id.pug'),
        ],
      ),
      TR.ITestItem(
        '          if youAreUsingPug',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(10, 'keyword.if.pug'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        '            p You are amazing',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(12, 'tag.pug'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
      TR.ITestItem(
        '          else',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(10, 'keyword.else.pug'),
        ],
      ),
      TR.ITestItem(
        '            p Get on it!',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(12, 'tag.pug'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
      TR.ITestItem(
        '     p Text can be included in a number of different ways.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'tag.pug'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
    ],
  ]);
}

