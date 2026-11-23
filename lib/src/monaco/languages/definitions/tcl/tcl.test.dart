// Generated 1:1 from languages/definitions/tcl/tcl.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('tcl')
void runLanguagesDefinitionsTclTclTestCases() {
  TR.testTokenization('tcl', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'set var 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.flow.tcl'),
          TR.IRelaxedToken(3, 'source.tcl'),
          TR.IRelaxedToken(4, 'type.tcl'),
          TR.IRelaxedToken(7, 'white.tcl'),
          TR.IRelaxedToken(8, 'number.tcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'proc func {a b} {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.flow.tcl'),
          TR.IRelaxedToken(4, 'source.tcl'),
          TR.IRelaxedToken(5, 'type.tcl'),
          TR.IRelaxedToken(9, 'white.tcl'),
          TR.IRelaxedToken(10, 'delimiter.curly.tcl'),
          TR.IRelaxedToken(11, 'operator.scss.tcl'),
          TR.IRelaxedToken(12, 'white.tcl'),
          TR.IRelaxedToken(13, 'operator.scss.tcl'),
          TR.IRelaxedToken(14, 'delimiter.curly.tcl'),
          TR.IRelaxedToken(15, 'white.tcl'),
          TR.IRelaxedToken(16, 'delimiter.curly.tcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'if 1 return',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.tcl'),
          TR.IRelaxedToken(2, 'white.tcl'),
          TR.IRelaxedToken(3, 'number.tcl'),
          TR.IRelaxedToken(4, 'white.tcl'),
          TR.IRelaxedToken(5, 'keyword.tcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$var1 \$::var2 \$\$var3 \${var 4} \$::{var 5}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.tcl'),
          TR.IRelaxedToken(5, 'white.tcl'),
          TR.IRelaxedToken(6, 'type.identifier.tcl'),
          TR.IRelaxedToken(13, 'white.tcl'),
          TR.IRelaxedToken(14, 'type.identifier.tcl'),
          TR.IRelaxedToken(20, 'white.tcl'),
          TR.IRelaxedToken(21, 'identifier.tcl'),
          TR.IRelaxedToken(23, 'type.identifier.tcl'),
          TR.IRelaxedToken(28, 'identifier.tcl'),
          TR.IRelaxedToken(29, 'white.tcl'),
          TR.IRelaxedToken(30, 'identifier.tcl'),
          TR.IRelaxedToken(34, 'type.identifier.tcl'),
          TR.IRelaxedToken(39, 'identifier.tcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'puts "\$var1 + \${var 2} = [expr \$var1 + \${var 2}]"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.tcl'),
          TR.IRelaxedToken(4, 'white.tcl'),
          TR.IRelaxedToken(5, 'string.quote.tcl'),
          TR.IRelaxedToken(6, 'type.identifier.tcl'),
          TR.IRelaxedToken(11, 'string.tcl'),
          TR.IRelaxedToken(14, 'identifier.tcl'),
          TR.IRelaxedToken(16, 'type.identifier.tcl'),
          TR.IRelaxedToken(21, 'identifier.tcl'),
          TR.IRelaxedToken(22, 'string.tcl'),
          TR.IRelaxedToken(25, 'delimiter.square.tcl'),
          TR.IRelaxedToken(26, 'keyword.tcl'),
          TR.IRelaxedToken(30, 'white.tcl'),
          TR.IRelaxedToken(31, 'type.identifier.tcl'),
          TR.IRelaxedToken(36, 'white.tcl'),
          TR.IRelaxedToken(37, 'operator.tcl'),
          TR.IRelaxedToken(38, 'white.tcl'),
          TR.IRelaxedToken(39, 'identifier.tcl'),
          TR.IRelaxedToken(41, 'type.identifier.tcl'),
          TR.IRelaxedToken(46, 'identifier.tcl'),
          TR.IRelaxedToken(47, 'delimiter.square.tcl'),
          TR.IRelaxedToken(48, 'string.quote.tcl'),
        ],
      ),
    ],
  ]);
}

