// Generated 1:1 from languages/definitions/wgsl/wgsl.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('wgsl')
void runLanguagesDefinitionsWgslWgslTestCases() {
  TR.testTokenization('wgsl', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'alias a=ptr<function,i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'operator.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.wgsl'),
          TR.IRelaxedToken(21, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(24, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias b=ptr<private,i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'operator.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
          TR.IRelaxedToken(20, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(23, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias c=ptr<workgroup,i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'operator.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
          TR.IRelaxedToken(22, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(25, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias d=ptr<uniform,i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'operator.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
          TR.IRelaxedToken(20, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(23, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias e=ptr<storage,i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'operator.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
          TR.IRelaxedToken(20, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(23, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@id(0) override x:i32 = 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(4, 'number.wgsl'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(6, 'white.wgsl'),
          TR.IRelaxedToken(7, 'keyword.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'identifier.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'operator.wgsl'),
          TR.IRelaxedToken(23, 'white.wgsl'),
          TR.IRelaxedToken(24, 'number.wgsl'),
          TR.IRelaxedToken(25, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@ id(1) override y:i32 = 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'annotation.wgsl'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'keyword.wgsl'),
          TR.IRelaxedToken(16, 'white.wgsl'),
          TR.IRelaxedToken(17, 'identifier.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
          TR.IRelaxedToken(19, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(22, 'white.wgsl'),
          TR.IRelaxedToken(23, 'operator.wgsl'),
          TR.IRelaxedToken(24, 'white.wgsl'),
          TR.IRelaxedToken(25, 'number.wgsl'),
          TR.IRelaxedToken(26, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@//comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(1, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        'id(1) override z:i32 = 3;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(2, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(3, 'number.wgsl'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'keyword.wgsl'),
          TR.IRelaxedToken(14, 'white.wgsl'),
          TR.IRelaxedToken(15, 'identifier.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(20, 'white.wgsl'),
          TR.IRelaxedToken(21, 'operator.wgsl'),
          TR.IRelaxedToken(22, 'white.wgsl'),
          TR.IRelaxedToken(23, 'number.wgsl'),
          TR.IRelaxedToken(24, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@must_use fn foo() -> i32 { return 32; }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'keyword.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'identifier.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(18, 'white.wgsl'),
          TR.IRelaxedToken(19, 'operator.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'delimiter.curly.wgsl'),
          TR.IRelaxedToken(27, 'white.wgsl'),
          TR.IRelaxedToken(28, 'keyword.wgsl'),
          TR.IRelaxedToken(34, 'white.wgsl'),
          TR.IRelaxedToken(35, 'number.wgsl'),
          TR.IRelaxedToken(37, 'delimiter.wgsl'),
          TR.IRelaxedToken(38, 'white.wgsl'),
          TR.IRelaxedToken(39, 'delimiter.curly.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' /**/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.wgsl'),
          TR.IRelaxedToken(1, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        ' /*block with newline',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.wgsl'),
          TR.IRelaxedToken(1, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        '  */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        ' /*block with line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.wgsl'),
          TR.IRelaxedToken(1, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        ' ending comment//  */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        ' /* nested /*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.wgsl'),
          TR.IRelaxedToken(1, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        '  */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        '  */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'alias boolean=bool;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(13, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias bvec2=vec2<bool>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias bvec3=vec3<bool>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias bvec4=vec4<bool>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'const one = array(1)[0];',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(18, 'number.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.square.wgsl'),
          TR.IRelaxedToken(21, 'number.wgsl'),
          TR.IRelaxedToken(22, 'delimiter.square.wgsl'),
          TR.IRelaxedToken(23, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'fn none() {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(2, 'white.wgsl'),
          TR.IRelaxedToken(3, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.curly.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'const a = 0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.wgsl'),
          TR.IRelaxedToken(11, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const au = 0u;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.wgsl'),
          TR.IRelaxedToken(13, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const ai = 0i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.wgsl'),
          TR.IRelaxedToken(13, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const b = 12345;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const bu = 12345u;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const bi= 12345i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const c = 0x0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.hex.wgsl'),
          TR.IRelaxedToken(13, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const cu = 0x0u;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const ci = 0x0i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const d = 0x12345;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.hex.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const di = 0x12345i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const du = 0x12345u;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const eh = 0h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(13, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const ef = 0f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(13, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const f = 1.;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(12, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const fh = 1.h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const ff = 1.f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const g = .1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(12, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const gh = .1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const gf = .1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const g = 1e1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(13, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const gh = 1e1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const gf = 1e1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const h = 1e+1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const hh = 1e+1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const hf = 1e+1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const i = 1e-1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const ih = 1e-1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const if = 1e-1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'keyword.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const j = 1.0e+1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const jh = 1.0e+1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const jf= 1.0e+1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const k = 1.0e-1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const kh = 1.0e-1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.float.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const kf= 1.0e-1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.float.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const l = 0x1p1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.hex.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const lh = 0x1p1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const lf = 0x1p1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const m = 0x1p+1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.hex.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const mh = 0x1p+1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const mf = 0x1p+1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const n = 0x1p-1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.hex.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const nh = 0x1p-1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const nf = 0x1p-1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const oo = 0x1.p1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const ooh = 0x1.p1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'number.hex.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const oof = 0x1.p1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'number.hex.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const p = 0x.1p1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'operator.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'number.hex.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const ph = 0x.1p1h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const pf = 0x.1p1f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.hex.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@group(0) @binding(1) var texture_depth_2d;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(42, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(2) var texture_depth_2d_array;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(48, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(4) var texture_depth_cube;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(5) var texture_depth_cube_array;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(50, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(5) var texture_depth_multisampled_2d;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'enable f16;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(6, 'white.wgsl'),
          TR.IRelaxedToken(7, 'meta.content.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'requires v1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'meta.content.wgsl'),
          TR.IRelaxedToken(11, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'diagnostic(error,derivative_uniformity);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(11, 'meta.content.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
          TR.IRelaxedToken(17, 'meta.content.wgsl'),
          TR.IRelaxedToken(38, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(39, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'diagnostic(warning,derivative_uniformity);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(11, 'meta.content.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
          TR.IRelaxedToken(19, 'meta.content.wgsl'),
          TR.IRelaxedToken(40, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(41, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'diagnostic(off,derivative_uniformity);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(11, 'meta.content.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
          TR.IRelaxedToken(15, 'meta.content.wgsl'),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(37, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'diagnostic(info,derivative_uniformity);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(11, 'meta.content.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
          TR.IRelaxedToken(16, 'meta.content.wgsl'),
          TR.IRelaxedToken(37, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(38, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '@diagnostic(off,derviative_uniformity) fn main() {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(12, 'identifier.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
          TR.IRelaxedToken(16, 'identifier.wgsl'),
          TR.IRelaxedToken(37, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(38, 'white.wgsl'),
          TR.IRelaxedToken(39, 'keyword.wgsl'),
          TR.IRelaxedToken(41, 'white.wgsl'),
          TR.IRelaxedToken(42, 'identifier.wgsl'),
          TR.IRelaxedToken(46, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(48, 'white.wgsl'),
          TR.IRelaxedToken(49, 'delimiter.curly.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@group(0) @binding(5) var texture_external;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(42, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'alias',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'break',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'case',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const_assert',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'continue',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'continuing',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'default',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'diagnostic',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
        ],
      ),
      TR.ITestItem(
        'discard',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'else',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'enable',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'false',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'fn',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'for',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'if',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'let',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'loop',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'override',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'requires',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'return',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'struct',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'switch',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'true',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'var',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
      TR.ITestItem(
        'while',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'meta.content.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  // this is a line-ending comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.wgsl'),
          TR.IRelaxedToken(2, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        ' //* embed a bock comment start, after a space',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.wgsl'),
          TR.IRelaxedToken(1, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        '// /* embed a bock comment start, v2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@group(0) @binding(5) var texture_multisampled_2d<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(49, 'operator.wgsl'),
          TR.IRelaxedToken(50, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(53, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'enable f16;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(6, 'white.wgsl'),
          TR.IRelaxedToken(7, 'meta.content.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias int=i32;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(13, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias uint=u32;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias float=f32;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias half=f16;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias ivec2=vec2i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias uvec2=vec2u;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias vec2=vec2f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias ivec3=vec3i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias uvec3=vec3u;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias vec3=vec3f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias ivec4=vec4i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias uvec4=vec4u;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias ivec2_=vec2<i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias uvec2_=vec2<u32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias vec2_=vec2<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias ivec3_=vec3<i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias uvec3_=vec3<u32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias vec3_=vec3<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias ivec4_=vec4<i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias uvec4_=vec4<u32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias vec4_=vec4<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias hvec2=vec2h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias hvec3=vec3h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias hvec4=vec4h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias hvec4_=vec4<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m22=mat2x2f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m23=mat2x3f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m24=mat2x4f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m32=mat3x2f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m33=mat3x3f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m34=mat3x4f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m42=mat4x2f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m43=mat4x3f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m44=mat4x4f;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m22_=mat2x2<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m23_=mat2x3<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m24_=mat2x4<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m32_=mat3x2<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m33_=mat3x3<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m34_=mat3x4<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m42_=mat4x2<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m43_=mat4x3<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m44_=mat4x4<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m22=mat2x2h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias m23=mat2x3h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h24=mat2x4h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h32=mat3x2h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h33=mat3x3h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h34=mat3x4h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h42=mat4x2h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h43=mat4x3h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h44=mat4x4h;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h22_=mat2x2<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h23_=mat2x3<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h24_=mat2x4<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h32_=mat3x2<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h33_=mat3x3<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h34_=mat3x4<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h42_=mat4x2<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h43_=mat4x3<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias h44_=mat4x4<f16>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'const add = 0+1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'number.wgsl'),
          TR.IRelaxedToken(13, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'number.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const sub = 0-1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'number.wgsl'),
          TR.IRelaxedToken(13, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'number.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const mult = 1*0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'number.wgsl'),
          TR.IRelaxedToken(14, 'operator.wgsl'),
          TR.IRelaxedToken(15, 'number.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const div = 1/0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'number.wgsl'),
          TR.IRelaxedToken(13, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'number.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const rem = 2%1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'number.wgsl'),
          TR.IRelaxedToken(13, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'number.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const xor = 1^2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'number.wgsl'),
          TR.IRelaxedToken(13, 'delimiter.wgsl'),
          TR.IRelaxedToken(14, 'number.wgsl'),
          TR.IRelaxedToken(15, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const or = 1|2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'operator.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'number.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'number.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const not = !false;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'operator.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'delimiter.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const complement = ~1u;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(16, 'white.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'white.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
          TR.IRelaxedToken(20, 'number.wgsl'),
          TR.IRelaxedToken(22, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const less = 1<0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'number.wgsl'),
          TR.IRelaxedToken(14, 'operator.wgsl'),
          TR.IRelaxedToken(15, 'number.wgsl'),
          TR.IRelaxedToken(16, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const lesseq = 1<=0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'white.wgsl'),
          TR.IRelaxedToken(15, 'number.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'number.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const equal = 1==2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'white.wgsl'),
          TR.IRelaxedToken(14, 'number.wgsl'),
          TR.IRelaxedToken(15, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'number.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const greater = 1>2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(13, 'white.wgsl'),
          TR.IRelaxedToken(14, 'operator.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'number.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'number.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const greatereq = 1>=2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'white.wgsl'),
          TR.IRelaxedToken(18, 'number.wgsl'),
          TR.IRelaxedToken(19, 'operator.wgsl'),
          TR.IRelaxedToken(21, 'number.wgsl'),
          TR.IRelaxedToken(22, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const noteq = 1!=2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'white.wgsl'),
          TR.IRelaxedToken(14, 'number.wgsl'),
          TR.IRelaxedToken(15, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'number.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const leftshift = 1<<2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'operator.wgsl'),
          TR.IRelaxedToken(17, 'white.wgsl'),
          TR.IRelaxedToken(18, 'number.wgsl'),
          TR.IRelaxedToken(19, 'operator.wgsl'),
          TR.IRelaxedToken(21, 'number.wgsl'),
          TR.IRelaxedToken(22, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const rightshift = 2>>1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(16, 'white.wgsl'),
          TR.IRelaxedToken(17, 'operator.wgsl'),
          TR.IRelaxedToken(18, 'white.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'operator.wgsl'),
          TR.IRelaxedToken(22, 'number.wgsl'),
          TR.IRelaxedToken(23, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'fn arith() -> i32 {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(2, 'white.wgsl'),
          TR.IRelaxedToken(3, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(13, 'white.wgsl'),
          TR.IRelaxedToken(14, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'white.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.curly.wgsl'),
        ],
      ),
      TR.ITestItem(
        'var a: i32;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(3, 'white.wgsl'),
          TR.IRelaxedToken(4, 'identifier.wgsl'),
          TR.IRelaxedToken(5, 'delimiter.wgsl'),
          TR.IRelaxedToken(6, 'white.wgsl'),
          TR.IRelaxedToken(7, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a += 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a -= 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a *= 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a /= 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a %= 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a ^= 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a &= 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a |= 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'number.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a <<= 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'number.wgsl'),
          TR.IRelaxedToken(7, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a >>= 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'white.wgsl'),
          TR.IRelaxedToken(2, 'operator.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'number.wgsl'),
          TR.IRelaxedToken(7, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a++;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'a--;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.wgsl'),
          TR.IRelaxedToken(1, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'let b = true&&false;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(3, 'white.wgsl'),
          TR.IRelaxedToken(4, 'identifier.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'operator.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'let c = true||false;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(3, 'white.wgsl'),
          TR.IRelaxedToken(4, 'identifier.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'operator.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(12, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'return a;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(6, 'white.wgsl'),
          TR.IRelaxedToken(7, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'read write read_write',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'function private workgroup uniform storage',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'white.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(26, 'white.wgsl'),
          TR.IRelaxedToken(27, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(34, 'white.wgsl'),
          TR.IRelaxedToken(35, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'perspective linear flat',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(18, 'white.wgsl'),
          TR.IRelaxedToken(19, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'center centroid sample',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(6, 'white.wgsl'),
          TR.IRelaxedToken(7, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'vertex_index instance_index position front_facing frag_depth',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(27, 'white.wgsl'),
          TR.IRelaxedToken(28, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(36, 'white.wgsl'),
          TR.IRelaxedToken(37, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(49, 'white.wgsl'),
          TR.IRelaxedToken(50, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'local_invocation_id local_invocation_index',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(19, 'white.wgsl'),
          TR.IRelaxedToken(20, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'global_invocation_id workgroup_id num_workgroups',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(20, 'white.wgsl'),
          TR.IRelaxedToken(21, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(33, 'white.wgsl'),
          TR.IRelaxedToken(34, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'sample_index sample_mask',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba8unorm',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba8snorm',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba8uint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba8sint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba16uint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba16sint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba16float',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'r32uint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'r32sint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'r32float',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rg32uint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rg32sint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rg32float',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba32uint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba32sint',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'rgba32float',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'bgra8unorm',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'bool',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'f16',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'f32',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'i32',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'sampler sampler_comparison',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_depth_2d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_depth_2d_array',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_depth_cube',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_depth_cube_array',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_depth_multisampled_2d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_external',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_external',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'u32',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'array',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'atomic',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat2x2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat2x3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat2x4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat3x2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat3x3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat3x4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat4x2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat4x3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat4x4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'ptr',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_1d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_2d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_2d_array',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_cube',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_cube_array',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_multisampled_2d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_storage_1d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_storage_2d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_storage_2d_array',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'texture_storage_3d',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'vec2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'vec3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'vec4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'vec2i vec3i vec4i',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'vec2u vec3u vec4u',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'vec2f vec3f vec4f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'vec2h vec3h vec4h',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat2x2f mat2x3f mat2x4f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat3x2f mat3x3f mat3x4f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat4x2f mat4x3f mat4x4f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat2x2h mat2x3h mat2x4h',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat3x2h mat3x3h mat3x4h',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mat4x2h mat4x3h mat4x4h',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'bitcast all any select arrayLength abs acos acosh asin asinh atan atanh atan2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(22, 'white.wgsl'),
          TR.IRelaxedToken(23, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(34, 'white.wgsl'),
          TR.IRelaxedToken(35, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(38, 'white.wgsl'),
          TR.IRelaxedToken(39, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(43, 'white.wgsl'),
          TR.IRelaxedToken(44, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(49, 'white.wgsl'),
          TR.IRelaxedToken(50, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(54, 'white.wgsl'),
          TR.IRelaxedToken(55, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(60, 'white.wgsl'),
          TR.IRelaxedToken(61, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(65, 'white.wgsl'),
          TR.IRelaxedToken(66, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(71, 'white.wgsl'),
          TR.IRelaxedToken(72, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'ceil clamp cos cosh countLeadingZeros countOneBits countTrailingZeros cross',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(4, 'white.wgsl'),
          TR.IRelaxedToken(5, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(14, 'white.wgsl'),
          TR.IRelaxedToken(15, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(19, 'white.wgsl'),
          TR.IRelaxedToken(20, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(37, 'white.wgsl'),
          TR.IRelaxedToken(38, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(50, 'white.wgsl'),
          TR.IRelaxedToken(51, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(69, 'white.wgsl'),
          TR.IRelaxedToken(70, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'degrees determinant distance dot exp exp2 extractBits faceForward firstLeadingBit',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(7, 'white.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(19, 'white.wgsl'),
          TR.IRelaxedToken(20, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(28, 'white.wgsl'),
          TR.IRelaxedToken(29, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(32, 'white.wgsl'),
          TR.IRelaxedToken(33, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(36, 'white.wgsl'),
          TR.IRelaxedToken(37, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(41, 'white.wgsl'),
          TR.IRelaxedToken(42, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(53, 'white.wgsl'),
          TR.IRelaxedToken(54, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(65, 'white.wgsl'),
          TR.IRelaxedToken(66, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'firstTrailingBit floor fma fract frexp inverseBits inverseSqrt ldexp length',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'white.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(22, 'white.wgsl'),
          TR.IRelaxedToken(23, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(26, 'white.wgsl'),
          TR.IRelaxedToken(27, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(32, 'white.wgsl'),
          TR.IRelaxedToken(33, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(38, 'white.wgsl'),
          TR.IRelaxedToken(39, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(50, 'white.wgsl'),
          TR.IRelaxedToken(51, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(62, 'white.wgsl'),
          TR.IRelaxedToken(63, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(68, 'white.wgsl'),
          TR.IRelaxedToken(69, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'log log2 max min mix modf normalize pow quantizeToF16 radians reflect refract',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(3, 'white.wgsl'),
          TR.IRelaxedToken(4, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'white.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(20, 'white.wgsl'),
          TR.IRelaxedToken(21, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(35, 'white.wgsl'),
          TR.IRelaxedToken(36, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(39, 'white.wgsl'),
          TR.IRelaxedToken(40, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(53, 'white.wgsl'),
          TR.IRelaxedToken(54, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'white.wgsl'),
          TR.IRelaxedToken(62, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(69, 'white.wgsl'),
          TR.IRelaxedToken(70, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'reverseBits round saturate sign sin sinh smoothstep sqrt step tan tanh transpose',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'white.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'white.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(26, 'white.wgsl'),
          TR.IRelaxedToken(27, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(31, 'white.wgsl'),
          TR.IRelaxedToken(32, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(35, 'white.wgsl'),
          TR.IRelaxedToken(36, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(40, 'white.wgsl'),
          TR.IRelaxedToken(41, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(51, 'white.wgsl'),
          TR.IRelaxedToken(52, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(56, 'white.wgsl'),
          TR.IRelaxedToken(57, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'white.wgsl'),
          TR.IRelaxedToken(62, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(65, 'white.wgsl'),
          TR.IRelaxedToken(66, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(70, 'white.wgsl'),
          TR.IRelaxedToken(71, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'trunc dpdx dpdxCoarse dpdxFine dpdy dpdyCoarse dpdyFine fwidth fwidthCoarse fwidthFine',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(10, 'white.wgsl'),
          TR.IRelaxedToken(11, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(30, 'white.wgsl'),
          TR.IRelaxedToken(31, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(35, 'white.wgsl'),
          TR.IRelaxedToken(36, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(46, 'white.wgsl'),
          TR.IRelaxedToken(47, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'white.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(62, 'white.wgsl'),
          TR.IRelaxedToken(63, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(75, 'white.wgsl'),
          TR.IRelaxedToken(76, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'textureDimensions textureGather textureGatherCompare textureLoad textureNumLayers',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'white.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(31, 'white.wgsl'),
          TR.IRelaxedToken(32, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(52, 'white.wgsl'),
          TR.IRelaxedToken(53, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(64, 'white.wgsl'),
          TR.IRelaxedToken(65, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'textureNumLevels textureNumSamples textureSample textureSampleBias textureSampleCompare',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(16, 'white.wgsl'),
          TR.IRelaxedToken(17, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(34, 'white.wgsl'),
          TR.IRelaxedToken(35, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(48, 'white.wgsl'),
          TR.IRelaxedToken(49, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(66, 'white.wgsl'),
          TR.IRelaxedToken(67, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'textureSampleCompareLevel textureSampleGrad textureSampleLevel textureSampleBaseClampToEdge',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(43, 'white.wgsl'),
          TR.IRelaxedToken(44, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(62, 'white.wgsl'),
          TR.IRelaxedToken(63, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'textureStore atomicLoad atomicStore atomicAdd atomicSub atomicMax atomicMin',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(23, 'white.wgsl'),
          TR.IRelaxedToken(24, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(35, 'white.wgsl'),
          TR.IRelaxedToken(36, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(45, 'white.wgsl'),
          TR.IRelaxedToken(46, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'white.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(65, 'white.wgsl'),
          TR.IRelaxedToken(66, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'atomicAnd atomicOr atomicXor atomicExchange atomicCompareExchangeWeak pack4x8snorm',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(18, 'white.wgsl'),
          TR.IRelaxedToken(19, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(28, 'white.wgsl'),
          TR.IRelaxedToken(29, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(43, 'white.wgsl'),
          TR.IRelaxedToken(44, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(69, 'white.wgsl'),
          TR.IRelaxedToken(70, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'pack4x8unorm pack2x16snorm pack2x16unorm pack2x16float unpack4x8snorm unpack4x8unorm',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(12, 'white.wgsl'),
          TR.IRelaxedToken(13, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(26, 'white.wgsl'),
          TR.IRelaxedToken(27, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(40, 'white.wgsl'),
          TR.IRelaxedToken(41, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(54, 'white.wgsl'),
          TR.IRelaxedToken(55, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(69, 'white.wgsl'),
          TR.IRelaxedToken(70, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'unpack2x16snorm unpack2x16unorm unpack2x16float storageBarrier workgroupBarrier',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(15, 'white.wgsl'),
          TR.IRelaxedToken(16, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(31, 'white.wgsl'),
          TR.IRelaxedToken(32, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(47, 'white.wgsl'),
          TR.IRelaxedToken(48, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(62, 'white.wgsl'),
          TR.IRelaxedToken(63, 'variable.predefined.wgsl'),
        ],
      ),
      TR.ITestItem(
        'workgroupUniformLoad',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'NULL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'Self',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'abstract',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'active',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alignas',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alignof',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'as',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'asm',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'asm_fragment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'async',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'attribute',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'auto',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'await',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'become',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'binding_array',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'cast',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'catch',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'class',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'co_await',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'co_return',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'co_yield',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'coherent',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'column_major',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'common',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'compile',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'compile_fragment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'concept',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'const_cast',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'consteval',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'constexpr',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'constinit',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'crate',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'debugger',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'decltype',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'delete',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'demote',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'demote_to_helper',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'do',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'dynamic_cast',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'enum',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'explicit',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'export',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'extends',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'extern',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'external',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'fallthrough',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'filter',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'final',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'finally',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'friend',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'from',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'fxgroup',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'get',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'goto',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'groupshared',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'highp',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'impl',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'implements',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'import',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'inline',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'instanceof',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'interface',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'layout',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'lowp',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'macro',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'macro_rules',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'match',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mediump',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'meta',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mod',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'module',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'move',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mut',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'mutable',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'namespace',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'new',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'nil',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'noexcept',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'noinline',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'nointerpolation',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'noperspective',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'null',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'nullptr',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'of',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'operator',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'package',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'packoffset',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'partition',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'pass',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'patch',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'pixelfragment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'precise',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'precision',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'premerge',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'priv',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'protected',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'pub',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'public',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'readonly',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'ref',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'regardless',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'register',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'reinterpret_cast',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'require',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'resource',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'restrict',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'self',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'set',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'shared',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'sizeof',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'smooth',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'snorm',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'static',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'static_assert',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'static_cast',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'std',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'subroutine',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'super',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'target',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'template',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'this',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'thread_local',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'throw',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'trait',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'try',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'type',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'typedef',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'typeid',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'typename',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'typeof',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'union',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'unless',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'unorm',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'unsafe',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'unsized',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'use',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'using',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'varying',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'virtual',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'volatile',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'wgsl',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'where',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'with',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'writeonly',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
      TR.ITestItem(
        'yield',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'invalid.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@group(0) @binding(0) var texture_1d<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(36, 'operator.wgsl'),
          TR.IRelaxedToken(37, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(40, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(1) var texture_2d<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(36, 'operator.wgsl'),
          TR.IRelaxedToken(37, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(40, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(2) var texture_2d_array<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(42, 'operator.wgsl'),
          TR.IRelaxedToken(43, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(46, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(3) var texture_3d<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(36, 'operator.wgsl'),
          TR.IRelaxedToken(37, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(40, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(4) var texture_cube<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(38, 'operator.wgsl'),
          TR.IRelaxedToken(39, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(42, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(5) var texture_cube_array<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(48, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@group(0) @binding(0) var texture_storage_1d<rgba8unorm,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(1) var texture_storage_2d<rgba8unorm,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(2) var texture_storage_2d_array<rgba8unorm,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(50, 'operator.wgsl'),
          TR.IRelaxedToken(51, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
          TR.IRelaxedToken(62, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(67, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(3) var texture_storage_3d<rgba8unorm,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@group(0) @binding(0) var texture_storage_2d<rgba8unorm,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(1) var texture_storage_2d<rgba8snorm,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(2) var texture_storage_2d<rgba8uint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(54, 'delimiter.wgsl'),
          TR.IRelaxedToken(55, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(60, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(3) var texture_storage_2d<rgba8sint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(54, 'delimiter.wgsl'),
          TR.IRelaxedToken(55, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(60, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(4) var texture_storage_2d<rgba16uint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(5) var texture_storage_2d<rgba16sint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(6) var texture_storage_2d<rgba16float,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(56, 'delimiter.wgsl'),
          TR.IRelaxedToken(57, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(62, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(7) var texture_storage_2d<r32uint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(52, 'delimiter.wgsl'),
          TR.IRelaxedToken(53, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(58, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(8) var texture_storage_2d<r32sint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(52, 'delimiter.wgsl'),
          TR.IRelaxedToken(53, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(58, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(0) @binding(9) var texture_storage_2d<r32float,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(53, 'delimiter.wgsl'),
          TR.IRelaxedToken(54, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(59, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(1) @binding(0) var texture_storage_2d<rg32uint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(53, 'delimiter.wgsl'),
          TR.IRelaxedToken(54, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(59, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(1) @binding(1) var texture_storage_2d<rg32sint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(53, 'delimiter.wgsl'),
          TR.IRelaxedToken(54, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(59, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(1) @binding(2) var texture_storage_2d<rg32float,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(54, 'delimiter.wgsl'),
          TR.IRelaxedToken(55, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(60, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(1) @binding(3) var texture_storage_2d<rgba32uint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(1) @binding(4) var texture_storage_2d<rgba32sint,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(1) @binding(5) var texture_storage_2d<rgba32float,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(56, 'delimiter.wgsl'),
          TR.IRelaxedToken(57, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(62, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '@group(1) @binding(6) var texture_storage_2d<bgra8unorm,write>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(7, 'number.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'white.wgsl'),
          TR.IRelaxedToken(10, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'keyword.wgsl'),
          TR.IRelaxedToken(25, 'white.wgsl'),
          TR.IRelaxedToken(26, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(44, 'operator.wgsl'),
          TR.IRelaxedToken(45, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(55, 'delimiter.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'delimiter.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@vertex',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
        ],
      ),
      TR.ITestItem(
        'fn vmain(@location(0) v: vec4<f32>) -> @builtin(position) vec4f {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(2, 'white.wgsl'),
          TR.IRelaxedToken(3, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'annotation.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(19, 'number.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(21, 'white.wgsl'),
          TR.IRelaxedToken(22, 'identifier.wgsl'),
          TR.IRelaxedToken(23, 'delimiter.wgsl'),
          TR.IRelaxedToken(24, 'white.wgsl'),
          TR.IRelaxedToken(25, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(29, 'operator.wgsl'),
          TR.IRelaxedToken(30, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(33, 'operator.wgsl'),
          TR.IRelaxedToken(34, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(35, 'white.wgsl'),
          TR.IRelaxedToken(36, 'operator.wgsl'),
          TR.IRelaxedToken(38, 'white.wgsl'),
          TR.IRelaxedToken(39, 'annotation.wgsl'),
          TR.IRelaxedToken(47, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(48, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(56, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(57, 'white.wgsl'),
          TR.IRelaxedToken(58, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(63, 'white.wgsl'),
          TR.IRelaxedToken(64, 'delimiter.curly.wgsl'),
        ],
      ),
      TR.ITestItem(
        '  return v;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.wgsl'),
          TR.IRelaxedToken(2, 'keyword.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'identifier.wgsl'),
          TR.IRelaxedToken(10, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.wgsl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '@fragment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.wgsl'),
        ],
      ),
      TR.ITestItem(
        'fn fmain(@builtin(position) pos: vec4f) -> @location(0) vec4f {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(2, 'white.wgsl'),
          TR.IRelaxedToken(3, 'identifier.wgsl'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(9, 'annotation.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(18, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(27, 'white.wgsl'),
          TR.IRelaxedToken(28, 'identifier.wgsl'),
          TR.IRelaxedToken(31, 'delimiter.wgsl'),
          TR.IRelaxedToken(32, 'white.wgsl'),
          TR.IRelaxedToken(33, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(38, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(39, 'white.wgsl'),
          TR.IRelaxedToken(40, 'operator.wgsl'),
          TR.IRelaxedToken(42, 'white.wgsl'),
          TR.IRelaxedToken(43, 'annotation.wgsl'),
          TR.IRelaxedToken(52, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(53, 'number.wgsl'),
          TR.IRelaxedToken(54, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(55, 'white.wgsl'),
          TR.IRelaxedToken(56, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(61, 'white.wgsl'),
          TR.IRelaxedToken(62, 'delimiter.curly.wgsl'),
        ],
      ),
      TR.ITestItem(
        '  return vec4f(0.25,0.25,1.0,1.0);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.wgsl'),
          TR.IRelaxedToken(2, 'keyword.wgsl'),
          TR.IRelaxedToken(8, 'white.wgsl'),
          TR.IRelaxedToken(9, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(15, 'number.float.wgsl'),
          TR.IRelaxedToken(19, 'delimiter.wgsl'),
          TR.IRelaxedToken(20, 'number.float.wgsl'),
          TR.IRelaxedToken(24, 'delimiter.wgsl'),
          TR.IRelaxedToken(25, 'number.float.wgsl'),
          TR.IRelaxedToken(28, 'delimiter.wgsl'),
          TR.IRelaxedToken(29, 'number.float.wgsl'),
          TR.IRelaxedToken(32, 'delimiter.parenthesis.wgsl'),
          TR.IRelaxedToken(33, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.wgsl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// Test predeclared type generators, other than vector, matrix, and texture.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias a=array<f32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'operator.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(13, 'operator.wgsl'),
          TR.IRelaxedToken(14, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(17, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias b=atomic<i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'operator.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(14, 'operator.wgsl'),
          TR.IRelaxedToken(15, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(18, 'delimiter.wgsl'),
        ],
      ),
      TR.ITestItem(
        'alias c=ptr<function,i32>;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wgsl'),
          TR.IRelaxedToken(5, 'white.wgsl'),
          TR.IRelaxedToken(6, 'identifier.wgsl'),
          TR.IRelaxedToken(7, 'operator.wgsl'),
          TR.IRelaxedToken(8, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(11, 'operator.wgsl'),
          TR.IRelaxedToken(12, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(20, 'delimiter.wgsl'),
          TR.IRelaxedToken(21, 'variable.predefined.wgsl'),
          TR.IRelaxedToken(24, 'delimiter.wgsl'),
        ],
      ),
    ],
  ]);
}

