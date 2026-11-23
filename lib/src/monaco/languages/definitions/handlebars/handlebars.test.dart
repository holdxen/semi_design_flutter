// Generated 1:1 from languages/definitions/handlebars/handlebars.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('handlebars')
void runLanguagesDefinitionsHandlebarsHandlebarsTestCases() {
  TR.testTokenization(<String>['handlebars', 'css'], <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '<h1>handlebars!</h1>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(3, 'delimiter.html'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(15, 'delimiter.html'),
          TR.IRelaxedToken(17, 'tag.html'),
          TR.IRelaxedToken(19, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<h1>{{ title }}</h1>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(3, 'delimiter.html'),
          TR.IRelaxedToken(4, 'delimiter.handlebars'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.handlebars'),
          TR.IRelaxedToken(15, 'delimiter.html'),
          TR.IRelaxedToken(17, 'tag.html'),
          TR.IRelaxedToken(19, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<h1>{{title}}</h1>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(3, 'delimiter.html'),
          TR.IRelaxedToken(4, 'delimiter.handlebars'),
          TR.IRelaxedToken(6, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(11, 'delimiter.handlebars'),
          TR.IRelaxedToken(13, 'delimiter.html'),
          TR.IRelaxedToken(15, 'tag.html'),
          TR.IRelaxedToken(17, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<h1>{{{ title }}}</h1>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(3, 'delimiter.html'),
          TR.IRelaxedToken(4, 'delimiter.handlebars'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.handlebars'),
          TR.IRelaxedToken(17, 'delimiter.html'),
          TR.IRelaxedToken(19, 'tag.html'),
          TR.IRelaxedToken(21, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<ul>{{#each items}}<li>{{item}}</li>{{/each}}</ul>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(3, 'delimiter.html'),
          TR.IRelaxedToken(4, 'delimiter.handlebars'),
          TR.IRelaxedToken(6, 'keyword.helper.handlebars'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(17, 'delimiter.handlebars'),
          TR.IRelaxedToken(19, 'delimiter.html'),
          TR.IRelaxedToken(20, 'tag.html'),
          TR.IRelaxedToken(22, 'delimiter.html'),
          TR.IRelaxedToken(23, 'delimiter.handlebars'),
          TR.IRelaxedToken(25, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(29, 'delimiter.handlebars'),
          TR.IRelaxedToken(31, 'delimiter.html'),
          TR.IRelaxedToken(33, 'tag.html'),
          TR.IRelaxedToken(35, 'delimiter.html'),
          TR.IRelaxedToken(36, 'delimiter.handlebars'),
          TR.IRelaxedToken(38, 'keyword.helper.handlebars'),
          TR.IRelaxedToken(43, 'delimiter.handlebars'),
          TR.IRelaxedToken(45, 'delimiter.html'),
          TR.IRelaxedToken(47, 'tag.html'),
          TR.IRelaxedToken(49, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<div>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, 'delimiter.html'),
        ],
      ),
      TR.ITestItem(
        '{{#if foo}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.handlebars'),
          TR.IRelaxedToken(2, 'keyword.helper.handlebars'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(9, 'delimiter.handlebars'),
        ],
      ),
      TR.ITestItem(
        '<span>{{bar}}</span>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(5, 'delimiter.html'),
          TR.IRelaxedToken(6, 'delimiter.handlebars'),
          TR.IRelaxedToken(8, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(11, 'delimiter.handlebars'),
          TR.IRelaxedToken(13, 'delimiter.html'),
          TR.IRelaxedToken(15, 'tag.html'),
          TR.IRelaxedToken(19, 'delimiter.html'),
        ],
      ),
      TR.ITestItem(
        '{{/if}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.handlebars'),
          TR.IRelaxedToken(2, 'keyword.helper.handlebars'),
          TR.IRelaxedToken(5, 'delimiter.handlebars'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '</div>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(2, 'tag.html'),
          TR.IRelaxedToken(5, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/x-handlebars-template"><h1>{{ title }}</h1></script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name'),
          TR.IRelaxedToken(12, 'delimiter'),
          TR.IRelaxedToken(13, 'attribute.value'),
          TR.IRelaxedToken(41, 'delimiter.html'),
          TR.IRelaxedToken(42, 'delimiter.html'),
          TR.IRelaxedToken(43, 'tag.html'),
          TR.IRelaxedToken(45, 'delimiter.html'),
          TR.IRelaxedToken(46, 'delimiter.handlebars'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(49, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(54, ''),
          TR.IRelaxedToken(55, 'delimiter.handlebars'),
          TR.IRelaxedToken(57, 'delimiter.html'),
          TR.IRelaxedToken(59, 'tag.html'),
          TR.IRelaxedToken(61, 'delimiter.html'),
          TR.IRelaxedToken(62, 'delimiter.html'),
          TR.IRelaxedToken(64, 'tag.html'),
          TR.IRelaxedToken(70, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script type="text/x-handlebars-template">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name'),
          TR.IRelaxedToken(12, 'delimiter'),
          TR.IRelaxedToken(13, 'attribute.value'),
          TR.IRelaxedToken(41, 'delimiter.html'),
        ],
      ),
      TR.ITestItem(
        '<h1>{{ title }}</h1>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(3, 'delimiter.html'),
          TR.IRelaxedToken(4, 'delimiter.handlebars'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.handlebars'),
          TR.IRelaxedToken(15, 'delimiter.html'),
          TR.IRelaxedToken(17, 'tag.html'),
          TR.IRelaxedToken(19, 'delimiter.html'),
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
        '{{foo}}<script></script>{{bar}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.handlebars'),
          TR.IRelaxedToken(2, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(5, 'delimiter.handlebars'),
          TR.IRelaxedToken(7, 'delimiter.html'),
          TR.IRelaxedToken(8, 'tag.html'),
          TR.IRelaxedToken(14, 'delimiter.html'),
          TR.IRelaxedToken(17, 'tag.html'),
          TR.IRelaxedToken(23, 'delimiter.html'),
          TR.IRelaxedToken(24, 'delimiter.handlebars'),
          TR.IRelaxedToken(26, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(29, 'delimiter.handlebars'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{{else}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.handlebars'),
          TR.IRelaxedToken(2, 'keyword.helper.handlebars'),
          TR.IRelaxedToken(6, 'delimiter.handlebars'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{{elseFoo}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.handlebars'),
          TR.IRelaxedToken(2, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(9, 'delimiter.handlebars'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<a href="/posts/{{permalink}}">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'attribute.name'),
          TR.IRelaxedToken(7, 'delimiter'),
          TR.IRelaxedToken(8, 'attribute.value'),
          TR.IRelaxedToken(30, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{{test "coloring/looks broken"}}">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.handlebars'),
          TR.IRelaxedToken(2, 'variable.parameter.handlebars'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.handlebars'),
          TR.IRelaxedToken(30, 'delimiter.handlebars'),
          TR.IRelaxedToken(32, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{{!-- block comment --}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.block.start.handlebars'),
          TR.IRelaxedToken(5, 'comment.content.handlebars'),
          TR.IRelaxedToken(20, 'comment.block.end.handlebars'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{{!-- block comment }} with mustache --}}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.block.start.handlebars'),
          TR.IRelaxedToken(5, 'comment.content.handlebars'),
          TR.IRelaxedToken(37, 'comment.block.end.handlebars'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{{! comment }}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.start.handlebars'),
          TR.IRelaxedToken(3, 'comment.content.handlebars'),
          TR.IRelaxedToken(12, 'comment.end.handlebars'),
        ],
      ),
    ],
  ]);
}

