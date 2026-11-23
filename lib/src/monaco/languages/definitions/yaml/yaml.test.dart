// Generated 1:1 from languages/definitions/yaml/yaml.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('yaml')
void runLanguagesDefinitionsYamlYamlTestCases() {
  TR.testTokenization('yaml', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '%YAML 1.2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.directive.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#Comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '---',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operators.directivesEnd.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '...',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operators.documentEnd.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '!<tag:clarkevans.com,2002:invoice>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key: value',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '":": value',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '!!str string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.yaml'),
          TR.IRelaxedToken(5, 'white.yaml'),
          TR.IRelaxedToken(6, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'anchor: &anchor',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(6, 'operators.yaml'),
          TR.IRelaxedToken(7, 'white.yaml'),
          TR.IRelaxedToken(8, 'namespace.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'alias: *alias',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(5, 'operators.yaml'),
          TR.IRelaxedToken(6, 'white.yaml'),
          TR.IRelaxedToken(7, 'namespace.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.yaml'),
          TR.IRelaxedToken(2, 'string.invalid.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operators.yaml'),
        ],
      ),
      TR.ITestItem(
        '  String',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '- one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operators.yaml'),
          TR.IRelaxedToken(1, 'white.yaml'),
          TR.IRelaxedToken(2, 'string.yaml'),
        ],
      ),
      TR.ITestItem(
        '? two',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operators.yaml'),
          TR.IRelaxedToken(1, 'white.yaml'),
          TR.IRelaxedToken(2, 'string.yaml'),
        ],
      ),
      TR.ITestItem(
        ': three',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operators.yaml'),
          TR.IRelaxedToken(1, 'white.yaml'),
          TR.IRelaxedToken(2, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '{key: value, number: 123}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.bracket.yaml'),
          TR.IRelaxedToken(1, 'type.yaml'),
          TR.IRelaxedToken(4, 'operators.yaml'),
          TR.IRelaxedToken(5, 'white.yaml'),
          TR.IRelaxedToken(6, 'string.yaml'),
          TR.IRelaxedToken(11, 'delimiter.comma.yaml'),
          TR.IRelaxedToken(12, 'white.yaml'),
          TR.IRelaxedToken(13, 'type.yaml'),
          TR.IRelaxedToken(19, 'operators.yaml'),
          TR.IRelaxedToken(20, 'white.yaml'),
          TR.IRelaxedToken(21, 'number.yaml'),
          TR.IRelaxedToken(24, 'delimiter.bracket.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'this is a single quote string\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"this is a double \\quote string\\n"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.yaml'),
          TR.IRelaxedToken(18, 'string.escape.invalid.yaml'),
          TR.IRelaxedToken(20, 'string.yaml'),
          TR.IRelaxedToken(31, 'string.escape.yaml'),
          TR.IRelaxedToken(33, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[string,"double",\'single\',1,1.1,2002-04-28]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.yaml'),
          TR.IRelaxedToken(1, 'string.yaml'),
          TR.IRelaxedToken(7, 'delimiter.comma.yaml'),
          TR.IRelaxedToken(8, 'string.yaml'),
          TR.IRelaxedToken(16, 'delimiter.comma.yaml'),
          TR.IRelaxedToken(17, 'string.yaml'),
          TR.IRelaxedToken(25, 'delimiter.comma.yaml'),
          TR.IRelaxedToken(26, 'number.yaml'),
          TR.IRelaxedToken(27, 'delimiter.comma.yaml'),
          TR.IRelaxedToken(28, 'number.float.yaml'),
          TR.IRelaxedToken(31, 'delimiter.comma.yaml'),
          TR.IRelaxedToken(32, 'number.date.yaml'),
          TR.IRelaxedToken(42, 'delimiter.square.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'text: Pretty vector drawing. #this is comment doesn\'t have proper syntax higlighting',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(4, 'operators.yaml'),
          TR.IRelaxedToken(5, 'white.yaml'),
          TR.IRelaxedToken(6, 'string.yaml'),
          TR.IRelaxedToken(28, 'white.yaml'),
          TR.IRelaxedToken(29, 'comment.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'number: 3 #this comment also doesn\'t have proper syntax highlighting',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(6, 'operators.yaml'),
          TR.IRelaxedToken(7, 'white.yaml'),
          TR.IRelaxedToken(8, 'string.yaml'),
          TR.IRelaxedToken(9, 'white.yaml'),
          TR.IRelaxedToken(10, 'comment.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key: "va: lue"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key: \'va: lue\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key: \'va#lue\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key: "va#lue"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key: va#lue',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key: value #comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
          TR.IRelaxedToken(10, 'white.yaml'),
          TR.IRelaxedToken(11, 'comment.yaml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key: value #comment: also comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.yaml'),
          TR.IRelaxedToken(3, 'operators.yaml'),
          TR.IRelaxedToken(4, 'white.yaml'),
          TR.IRelaxedToken(5, 'string.yaml'),
          TR.IRelaxedToken(10, 'white.yaml'),
          TR.IRelaxedToken(11, 'comment.yaml'),
        ],
      ),
    ],
  ]);
}

