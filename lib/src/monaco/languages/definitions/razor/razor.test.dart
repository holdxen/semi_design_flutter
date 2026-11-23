// Generated 1:1 from languages/definitions/razor/razor.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('razor')
void runLanguagesDefinitionsRazorRazorTestCases() {
  TR.testTokenization('razor', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '@{ var x; <b>x</b> }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.cs'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'keyword.cs'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cs'),
          TR.IRelaxedToken(8, 'delimiter.cs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.html'),
          TR.IRelaxedToken(11, 'tag.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'identifier.cs'),
          TR.IRelaxedToken(14, 'delimiter.html'),
          TR.IRelaxedToken(16, 'tag.html'),
          TR.IRelaxedToken(17, 'delimiter.html'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'metatag.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@{ var x; @* comment *@ x= 0; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.cs'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'keyword.cs'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cs'),
          TR.IRelaxedToken(8, 'delimiter.cs'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'comment.cs'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'identifier.cs'),
          TR.IRelaxedToken(25, 'delimiter.cs'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'number.cs'),
          TR.IRelaxedToken(28, 'delimiter.cs'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'metatag.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@{ var total = 0; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.cs'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'keyword.cs'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cs'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.cs'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.cs'),
          TR.IRelaxedToken(16, 'delimiter.cs'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'metatag.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'test@xyz<br>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'metatag.cs'),
          TR.IRelaxedToken(5, 'identifier.cs'),
          TR.IRelaxedToken(8, 'delimiter.html'),
          TR.IRelaxedToken(9, 'tag.html'),
          TR.IRelaxedToken(11, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'test@xyz',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'metatag.cs'),
          TR.IRelaxedToken(5, 'identifier.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'test @ xyz',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'metatag.cs'),
          TR.IRelaxedToken(6, 'identifier.cs'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'test @(foo) xyz',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'metatag.cs'),
          TR.IRelaxedToken(7, 'identifier.cs'),
          TR.IRelaxedToken(10, 'metatag.cs'),
          TR.IRelaxedToken(11, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'test @(foo(")")) xyz',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'metatag.cs'),
          TR.IRelaxedToken(7, 'identifier.cs'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(11, 'string.cs'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.cs'),
          TR.IRelaxedToken(15, 'metatag.cs'),
          TR.IRelaxedToken(16, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'test@@xyz',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
  ]);
}

