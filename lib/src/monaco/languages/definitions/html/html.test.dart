// Generated 1:1 from languages/definitions/html/html.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('html')
void runLanguagesDefinitionsHtmlHtmlTestCases() {
  TR.testTokenization(<String>['html', 'css', 'javascript'], <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<input',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '< abc',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '< abc>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'i <len;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.html'),
          TR.IRelaxedToken(3, 'tag.html'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '</a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(2, 'tag.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc >',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<foo:bar>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '</abc>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(2, 'tag.html'),
          TR.IRelaxedToken(5, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '</abc  >',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(2, 'tag.html'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(7, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc />',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/javascript">var i= 10;</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'attribute.value.html'),
          TR.IRelaxedToken(30, 'delimiter.html'),
          TR.IRelaxedToken(31, 'keyword.js'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'identifier.js'),
          TR.IRelaxedToken(36, 'delimiter.js'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'number.js'),
          TR.IRelaxedToken(40, 'delimiter.js'),
          TR.IRelaxedToken(41, 'delimiter.html'),
          TR.IRelaxedToken(43, 'tag.html'),
          TR.IRelaxedToken(49, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/javascript">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'attribute.value.html'),
          TR.IRelaxedToken(30, 'delimiter.html'),
        ],
      ),
      TR.ITestItem(
        'var i= 10;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, 'delimiter.js'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.js'),
          TR.IRelaxedToken(9, 'delimiter.js'),
        ],
      ),
      TR.ITestItem(
        '</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(2, 'tag.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/javascript">var i= 10;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'attribute.value.html'),
          TR.IRelaxedToken(30, 'delimiter.html'),
          TR.IRelaxedToken(31, 'keyword.js'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'identifier.js'),
          TR.IRelaxedToken(36, 'delimiter.js'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'number.js'),
          TR.IRelaxedToken(40, 'delimiter.js'),
        ],
      ),
      TR.ITestItem(
        '</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(2, 'tag.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/javascript">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'attribute.value.html'),
          TR.IRelaxedToken(30, 'delimiter.html'),
        ],
      ),
      TR.ITestItem(
        'var i= 10;</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.js'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.js'),
          TR.IRelaxedToken(5, 'delimiter.js'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.js'),
          TR.IRelaxedToken(9, 'delimiter.js'),
          TR.IRelaxedToken(10, 'delimiter.html'),
          TR.IRelaxedToken(12, 'tag.html'),
          TR.IRelaxedToken(18, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/plain">a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'attribute.value.html'),
          TR.IRelaxedToken(25, 'delimiter.html'),
          TR.IRelaxedToken(26, ''),
        ],
      ),
      TR.ITestItem(
        '<a</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.html'),
          TR.IRelaxedToken(4, 'tag.html'),
          TR.IRelaxedToken(10, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script>a</script><script>b</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, 'delimiter.html'),
          TR.IRelaxedToken(8, 'identifier.js'),
          TR.IRelaxedToken(9, 'delimiter.html'),
          TR.IRelaxedToken(11, 'tag.html'),
          TR.IRelaxedToken(17, 'delimiter.html'),
          TR.IRelaxedToken(19, 'tag.html'),
          TR.IRelaxedToken(25, 'delimiter.html'),
          TR.IRelaxedToken(26, 'identifier.js'),
          TR.IRelaxedToken(27, 'delimiter.html'),
          TR.IRelaxedToken(29, 'tag.html'),
          TR.IRelaxedToken(35, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/javascript"></script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'attribute.value.html'),
          TR.IRelaxedToken(30, 'delimiter.html'),
          TR.IRelaxedToken(33, 'tag.html'),
          TR.IRelaxedToken(39, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script>var i= 10;</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, 'delimiter.html'),
          TR.IRelaxedToken(8, 'keyword.js'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.js'),
          TR.IRelaxedToken(13, 'delimiter.js'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.js'),
          TR.IRelaxedToken(17, 'delimiter.js'),
          TR.IRelaxedToken(18, 'delimiter.html'),
          TR.IRelaxedToken(20, 'tag.html'),
          TR.IRelaxedToken(26, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/javascript" src="main.js"></script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'attribute.value.html'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'attribute.name.html'),
          TR.IRelaxedToken(34, 'delimiter.html'),
          TR.IRelaxedToken(35, 'attribute.value.html'),
          TR.IRelaxedToken(44, 'delimiter.html'),
          TR.IRelaxedToken(47, 'tag.html'),
          TR.IRelaxedToken(53, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="module">var i= 10;</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'attribute.value.html'),
          TR.IRelaxedToken(21, 'delimiter.html'),
          TR.IRelaxedToken(22, 'keyword.js'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'identifier.js'),
          TR.IRelaxedToken(27, 'delimiter.js'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'number.js'),
          TR.IRelaxedToken(31, 'delimiter.js'),
          TR.IRelaxedToken(32, 'delimiter.html'),
          TR.IRelaxedToken(34, 'tag.html'),
          TR.IRelaxedToken(40, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo="bar">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
          TR.IRelaxedToken(9, 'attribute.value.html'),
          TR.IRelaxedToken(14, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo=\'bar\'>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
          TR.IRelaxedToken(9, 'attribute.value.html'),
          TR.IRelaxedToken(14, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo="">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
          TR.IRelaxedToken(9, 'attribute.value.html'),
          TR.IRelaxedToken(11, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo="bar" bar=\'foo\'>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
          TR.IRelaxedToken(9, 'attribute.value.html'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'attribute.name.html'),
          TR.IRelaxedToken(18, 'delimiter.html'),
          TR.IRelaxedToken(19, 'attribute.value.html'),
          TR.IRelaxedToken(24, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo=bar bar=help-me>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
          TR.IRelaxedToken(9, 'attribute.name.html'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'attribute.name.html'),
          TR.IRelaxedToken(16, 'delimiter.html'),
          TR.IRelaxedToken(17, 'attribute.name.html'),
          TR.IRelaxedToken(24, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo=  "bar">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(11, 'attribute.value.html'),
          TR.IRelaxedToken(16, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo = "bar">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.html'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.html'),
          TR.IRelaxedToken(16, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo bar>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'attribute.name.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo!@#="bar">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(11, 'delimiter.html'),
          TR.IRelaxedToken(12, 'attribute.value.html'),
          TR.IRelaxedToken(17, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc #myinput (click)="bar" [value]="someProperty" *ngIf="someCondition">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(6, 'attribute.name.html'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(15, 'attribute.name.html'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.html'),
          TR.IRelaxedToken(22, 'attribute.value.html'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(29, 'attribute.name.html'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'delimiter.html'),
          TR.IRelaxedToken(36, 'attribute.value.html'),
          TR.IRelaxedToken(50, ''),
          TR.IRelaxedToken(52, 'attribute.name.html'),
          TR.IRelaxedToken(56, 'delimiter.html'),
          TR.IRelaxedToken(57, 'attribute.value.html'),
          TR.IRelaxedToken(72, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc foo=">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'attribute.name.html'),
          TR.IRelaxedToken(8, 'delimiter.html'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!--a-->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.html'),
          TR.IRelaxedToken(4, 'comment.content.html'),
          TR.IRelaxedToken(5, 'comment.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!--a>foo bar</a -->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.html'),
          TR.IRelaxedToken(4, 'comment.content.html'),
          TR.IRelaxedToken(17, 'comment.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!--a>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.html'),
          TR.IRelaxedToken(4, 'comment.content.html'),
        ],
      ),
      TR.ITestItem(
        'foo ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.content.html'),
        ],
      ),
      TR.ITestItem(
        'bar</a -->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.content.html'),
          TR.IRelaxedToken(7, 'comment.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!DOCTYPE a>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.html'),
          TR.IRelaxedToken(9, 'metatag.content.html'),
          TR.IRelaxedToken(11, 'metatag.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!doctype a>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.html'),
          TR.IRelaxedToken(9, 'metatag.content.html'),
          TR.IRelaxedToken(11, 'metatag.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!DOCTYPE a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.html'),
          TR.IRelaxedToken(9, 'metatag.content.html'),
        ],
      ),
      TR.ITestItem(
        '"foo" \'bar\'>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.content.html'),
          TR.IRelaxedToken(11, 'metatag.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<asdf:bar>asd</asdf:bar>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(9, 'delimiter.html'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(13, 'delimiter.html'),
          TR.IRelaxedToken(15, 'tag.html'),
          TR.IRelaxedToken(23, 'delimiter.html'),
        ],
      ),
    ],
  ]);
}

