// Generated 1:1 from languages/definitions/css/css.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('css')
void runLanguagesDefinitionsCssCssTestCases() {
  TR.testTokenization('css', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '      body',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'tag.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'body {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '  margin: 0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'attribute.value.number.css'),
          TR.IRelaxedToken(11, 'delimiter.css'),
        ],
      ),
      TR.ITestItem(
        '  padding: 3em 6em;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.number.css'),
          TR.IRelaxedToken(12, 'attribute.value.unit.css'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'attribute.value.number.css'),
          TR.IRelaxedToken(16, 'attribute.value.unit.css'),
          TR.IRelaxedToken(18, 'delimiter.css'),
        ],
      ),
      TR.ITestItem(
        '  font-family: tahoma, arial, sans-serif;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'attribute.value.css'),
          TR.IRelaxedToken(21, 'delimiter.css'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'attribute.value.css'),
          TR.IRelaxedToken(28, 'delimiter.css'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'attribute.value.css'),
          TR.IRelaxedToken(40, 'delimiter.css'),
        ],
      ),
      TR.ITestItem(
        '  text-decoration: none !important;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'attribute.value.css'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'keyword.css'),
          TR.IRelaxedToken(34, 'delimiter.css'),
        ],
      ),
      TR.ITestItem(
        '  color: #000',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'attribute.value.hex.css'),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '* { padding: 3em -9pt -0.5px; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.bracket.css'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'attribute.name.css'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'attribute.value.number.css'),
          TR.IRelaxedToken(14, 'attribute.value.unit.css'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'attribute.value.number.css'),
          TR.IRelaxedToken(19, 'attribute.value.unit.css'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'attribute.value.number.css'),
          TR.IRelaxedToken(26, 'attribute.value.unit.css'),
          TR.IRelaxedToken(28, 'delimiter.css'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '* { padding: -',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.bracket.css'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'attribute.name.css'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'h1 /*comment*/ p {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'comment.css'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'tag.css'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'h1 /*com',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'comment.css'),
        ],
      ),
      TR.ITestItem(
        'ment*/ p',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.css'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'tag.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#myID {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.myID {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@import url("something.css");',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.css'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.value.css'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(12, 'string.css'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(28, 'delimiter.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'body {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '  content: "con\\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.css'),
        ],
      ),
      TR.ITestItem(
        'tent";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.css'),
          TR.IRelaxedToken(5, 'delimiter.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'body {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '  content: "";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.css'),
          TR.IRelaxedToken(13, 'delimiter.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@font-face {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.css'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '  font-family: "Opificio";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'string.css'),
          TR.IRelaxedToken(25, 'delimiter.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"s\\"tr" ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.css'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@-webkit-keyframes infinite-spinning {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.css'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'attribute.value.css'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '  from {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.value.css'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '  -webkit-transform: rotate(0deg);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'attribute.value.css'),
          TR.IRelaxedToken(28, 'attribute.value.number.css'),
          TR.IRelaxedToken(29, 'attribute.value.unit.css'),
          TR.IRelaxedToken(32, 'attribute.value.css'),
          TR.IRelaxedToken(33, 'delimiter.css'),
        ],
      ),
      TR.ITestItem(
        '\t }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '  to {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.value.css'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '  -webkit-transform: rotate(360deg);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'attribute.name.css'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'attribute.value.css'),
          TR.IRelaxedToken(28, 'attribute.value.number.css'),
          TR.IRelaxedToken(31, 'attribute.value.unit.css'),
          TR.IRelaxedToken(34, 'attribute.value.css'),
          TR.IRelaxedToken(35, 'delimiter.css'),
        ],
      ),
      TR.ITestItem(
        '\t }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@import url("something.css");',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.css'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.value.css'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(12, 'string.css'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(28, 'delimiter.css'),
        ],
      ),
      TR.ITestItem(
        '.rule1{}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(6, 'delimiter.bracket.css'),
        ],
      ),
      TR.ITestItem(
        '.rule2{}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(6, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '""""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"""""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@import url("something.css");@import url("something.css");',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.css'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.value.css'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(12, 'string.css'),
          TR.IRelaxedToken(27, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(28, 'delimiter.css'),
          TR.IRelaxedToken(29, 'keyword.css'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'attribute.value.css'),
          TR.IRelaxedToken(40, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(41, 'string.css'),
          TR.IRelaxedToken(56, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(57, 'delimiter.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.a{background:#f5f9fc !important}.b{font-family:"Helvetica Neue", Helvetica;height:31px;}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(2, 'delimiter.bracket.css'),
          TR.IRelaxedToken(3, 'attribute.name.css'),
          TR.IRelaxedToken(14, 'attribute.value.hex.css'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'keyword.css'),
          TR.IRelaxedToken(32, 'delimiter.bracket.css'),
          TR.IRelaxedToken(33, 'tag.css'),
          TR.IRelaxedToken(35, 'delimiter.bracket.css'),
          TR.IRelaxedToken(36, 'attribute.name.css'),
          TR.IRelaxedToken(48, 'string.css'),
          TR.IRelaxedToken(64, 'delimiter.css'),
          TR.IRelaxedToken(65, ''),
          TR.IRelaxedToken(66, 'attribute.value.css'),
          TR.IRelaxedToken(75, 'delimiter.css'),
          TR.IRelaxedToken(76, 'attribute.name.css'),
          TR.IRelaxedToken(83, 'attribute.value.number.css'),
          TR.IRelaxedToken(85, 'attribute.value.unit.css'),
          TR.IRelaxedToken(87, 'delimiter.css'),
          TR.IRelaxedToken(88, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.even { background: #fff url(data:image/gif;base64,R0lGODlhBgASALMAAOfn5+rq6uvr6+zs7O7u7vHx8fPz8/b29vj4+P39/f///wAAAAAAAAAAAAAAAAAAACwAAAAABgASAAAIMAAVCBxIsKDBgwgTDkzAsKGAhxARSJx4oKJFAxgzFtjIkYDHjwNCigxAsiSAkygDAgA7) repeat-x bottom}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.bracket.css'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'attribute.name.css'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'attribute.value.hex.css'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'attribute.value.css'),
          TR.IRelaxedToken(28, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(29, 'string.css'),
          TR.IRelaxedToken(215, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(216, ''),
          TR.IRelaxedToken(217, 'attribute.value.css'),
          TR.IRelaxedToken(225, ''),
          TR.IRelaxedToken(226, 'attribute.value.css'),
          TR.IRelaxedToken(232, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.a{background:url(/a.jpg)}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(2, 'delimiter.bracket.css'),
          TR.IRelaxedToken(3, 'attribute.name.css'),
          TR.IRelaxedToken(14, 'attribute.value.css'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(18, 'string.css'),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.css'),
          TR.IRelaxedToken(25, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'p{}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(1, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'p:nth() {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'tag.css'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(8, 'delimiter.bracket.css'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@import \'https://example.com/test.css\';',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.css'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.css'),
          TR.IRelaxedToken(38, 'delimiter.css'),
        ],
      ),
    ],
  ]);
}

