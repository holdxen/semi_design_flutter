// Generated 1:1 from languages/definitions/lua/lua.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('lua')
void runLanguagesDefinitionsLuaLuaTestCases() {
  TR.testTokenization('lua', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'local x, y = 1, 10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.local.lua'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.lua'),
          TR.IRelaxedToken(7, 'delimiter.lua'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.lua'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.lua'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'number.lua'),
          TR.IRelaxedToken(14, 'delimiter.lua'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'number.lua'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = "Hello" .. "World"; local foo = foo',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.lua'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.lua'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.lua'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.lua'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'string.lua'),
          TR.IRelaxedToken(24, 'delimiter.lua'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'keyword.local.lua'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'identifier.lua'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(36, 'delimiter.lua'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'identifier.lua'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '--[[ text ]] x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.lua'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.lua'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '--[===[ text ]===] x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.lua'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'identifier.lua'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '--[===[ text ]==] x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.lua'),
        ],
      ),
    ],
  ]);
}

