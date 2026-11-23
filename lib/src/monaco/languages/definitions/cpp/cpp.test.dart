// Generated 1:1 from languages/definitions/cpp/cpp.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('cpp')
void runLanguagesDefinitionsCppCppTestCases() {
  TR.testTokenization('cpp', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'int _tmain(int argc, _TCHAR* argv[])',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cpp'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(11, 'keyword.int.cpp'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.cpp'),
          TR.IRelaxedToken(19, 'delimiter.cpp'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'identifier.cpp'),
          TR.IRelaxedToken(27, 'delimiter.cpp'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'identifier.cpp'),
          TR.IRelaxedToken(33, 'delimiter.square.cpp'),
          TR.IRelaxedToken(35, 'delimiter.parenthesis.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.cpp'),
          TR.IRelaxedToken(1, 'identifier.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.cpp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.cpp'),
          TR.IRelaxedToken(5, 'delimiter.cpp'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.cpp'),
          TR.IRelaxedToken(9, 'delimiter.cpp'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.cpp'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.cpp'),
          TR.IRelaxedToken(32, 'delimiter.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.cpp'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.cpp'),
          TR.IRelaxedToken(23, 'delimiter.cpp'),
          TR.IRelaxedToken(24, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cpp'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.cpp'),
          TR.IRelaxedToken(8, 'delimiter.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.cpp'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '12l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '34U',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '55LL',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '34ul',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '55llU',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '5\'5llU',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100\'000\'000',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x100\'aafllU',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0342\'325',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.octal.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3F',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3f',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3L',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3l',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
          TR.IRelaxedToken(1, 'delimiter.cpp'),
          TR.IRelaxedToken(2, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
          TR.IRelaxedToken(3, 'delimiter.cpp'),
          TR.IRelaxedToken(4, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.cpp'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#include<iostream>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.cpp'),
          TR.IRelaxedToken(8, 'keyword.directive.include.begin.cpp'),
          TR.IRelaxedToken(9, 'string.include.identifier.cpp'),
          TR.IRelaxedToken(17, 'keyword.directive.include.end.cpp'),
        ],
      ),
      TR.ITestItem(
        '#include "/path/to/my/file.h"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.cpp'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'keyword.directive.include.begin.cpp'),
          TR.IRelaxedToken(10, 'string.include.identifier.cpp'),
          TR.IRelaxedToken(28, 'keyword.directive.include.end.cpp'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#ifdef VAR',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.cpp'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cpp'),
        ],
      ),
      TR.ITestItem(
        '#define SUM(A,B) (A) + (B)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.cpp'),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(12, 'identifier.cpp'),
          TR.IRelaxedToken(13, 'delimiter.cpp'),
          TR.IRelaxedToken(14, 'identifier.cpp'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(18, 'identifier.cpp'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.cpp'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(24, 'identifier.cpp'),
          TR.IRelaxedToken(25, 'delimiter.parenthesis.cpp'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'int main(int argc, char** argv)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cpp'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(9, 'keyword.int.cpp'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.cpp'),
          TR.IRelaxedToken(17, 'delimiter.cpp'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'keyword.char.cpp'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(26, 'identifier.cpp'),
          TR.IRelaxedToken(30, 'delimiter.parenthesis.cpp'),
        ],
      ),
      TR.ITestItem(
        '{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\treturn 0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.return.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.cpp'),
          TR.IRelaxedToken(9, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'namespace TestSpace',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.namespace.cpp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.cpp'),
        ],
      ),
      TR.ITestItem(
        '{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\tusing Asdf.CDE;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.using.cpp'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cpp'),
          TR.IRelaxedToken(11, 'delimiter.cpp'),
          TR.IRelaxedToken(12, 'identifier.cpp'),
          TR.IRelaxedToken(15, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '\ttemplate <typename T>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.template.cpp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.angle.cpp'),
          TR.IRelaxedToken(11, 'keyword.typename.cpp'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'identifier.cpp'),
          TR.IRelaxedToken(21, 'delimiter.angle.cpp'),
        ],
      ),
      TR.ITestItem(
        '\tclass CoolClass : protected BaseClass',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.class.cpp'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cpp'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.cpp'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'keyword.protected.cpp'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'identifier.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\tprivate:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.private.cpp'),
          TR.IRelaxedToken(9, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t\tstatic T field;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.static.cpp'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.cpp'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'identifier.cpp'),
          TR.IRelaxedToken(16, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t\tpublic:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.public.cpp'),
          TR.IRelaxedToken(8, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t\t[[deprecated]]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'annotation.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\tfoo method() const override',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.cpp'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'keyword.const.cpp'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'keyword.override.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t\tauto s = new Bar();',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.auto.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.cpp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.cpp'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'keyword.new.cpp'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.cpp'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(21, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t\t\tif (s.field) {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.if.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(7, 'identifier.cpp'),
          TR.IRelaxedToken(8, 'delimiter.cpp'),
          TR.IRelaxedToken(9, 'identifier.cpp'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\tfor(const auto & b : s.field) {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.for.cpp'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(8, 'keyword.const.cpp'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.auto.cpp'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.cpp'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'identifier.cpp'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.cpp'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'identifier.cpp'),
          TR.IRelaxedToken(26, 'delimiter.cpp'),
          TR.IRelaxedToken(27, 'identifier.cpp'),
          TR.IRelaxedToken(32, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\t\tbreak;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'keyword.break.cpp'),
          TR.IRelaxedToken(10, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t\tstd::string s = "hello wordld\\n";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(7, 'identifier.cpp'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.cpp'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.cpp'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.cpp'),
          TR.IRelaxedToken(31, 'string.escape.cpp'),
          TR.IRelaxedToken(33, 'string.cpp'),
          TR.IRelaxedToken(34, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t\tint number = 123\'123\'123Ull;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.int.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.cpp'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.cpp'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.cpp'),
          TR.IRelaxedToken(29, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.cpp'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '#endif',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.cpp'),
        ],
      ),
      TR.ITestItem(
        '#    ifdef VAR',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.cpp'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'identifier.cpp'),
        ],
      ),
      TR.ITestItem(
        '#\tdefine SUM(A,B) (A) + (B)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.cpp'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.cpp'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(13, 'identifier.cpp'),
          TR.IRelaxedToken(14, 'delimiter.cpp'),
          TR.IRelaxedToken(15, 'identifier.cpp'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(19, 'identifier.cpp'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'delimiter.cpp'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(25, 'identifier.cpp'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.cpp'),
        ],
      ),
      TR.ITestItem(
        'uR"V0G0N(abc)V0G0N"def',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.raw.begin.cpp'),
          TR.IRelaxedToken(9, 'string.raw.cpp'),
          TR.IRelaxedToken(12, 'string.raw.end.cpp'),
          TR.IRelaxedToken(19, 'identifier.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'auto sv = R"({ "message": "Hello World" })""\\n"sv;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.auto.cpp'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.cpp'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'string.raw.begin.cpp'),
          TR.IRelaxedToken(13, 'string.raw.cpp'),
          TR.IRelaxedToken(41, 'string.raw.end.cpp'),
          TR.IRelaxedToken(43, 'string.cpp'),
          TR.IRelaxedToken(44, 'string.escape.cpp'),
          TR.IRelaxedToken(46, 'string.cpp'),
          TR.IRelaxedToken(47, 'identifier.cpp'),
          TR.IRelaxedToken(49, 'delimiter.cpp'),
        ],
      ),
      TR.ITestItem(
        '    // This is a comment, not a string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[[nodiscard]]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[[using CC: opt(1), debug]]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.cpp'),
          TR.IRelaxedToken(2, 'keyword.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'annotation.cpp'),
          TR.IRelaxedToken(10, 'delimiter.cpp'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'annotation.cpp'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(16, 'annotation.cpp'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(18, 'delimiter.cpp'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'annotation.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[[nodiscard /*commented*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.cpp'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'comment.cpp'),
        ],
      ),
      TR.ITestItem(
        ']] int i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.cpp'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'keyword.int.cpp'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.cpp'),
          TR.IRelaxedToken(8, 'delimiter.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[ [nodiscard] ]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'annotation.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' # if defined(SOMETHING)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.cpp'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.cpp'),
          TR.IRelaxedToken(14, 'identifier.cpp'),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.cpp'),
        ],
      ),
      TR.ITestItem(
        '        #include <io.h>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.cpp'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'keyword.directive.include.begin.cpp'),
          TR.IRelaxedToken(18, 'string.include.identifier.cpp'),
          TR.IRelaxedToken(22, 'keyword.directive.include.end.cpp'),
        ],
      ),
      TR.ITestItem(
        '      #  include <io.h>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.cpp'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'keyword.directive.include.begin.cpp'),
          TR.IRelaxedToken(18, 'string.include.identifier.cpp'),
          TR.IRelaxedToken(22, 'keyword.directive.include.end.cpp'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// this is a comment \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cpp'),
        ],
      ),
      TR.ITestItem(
        'this is still a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.cpp'),
        ],
      ),
      TR.ITestItem(
        'int x = 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.cpp'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.cpp'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.cpp'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.cpp'),
          TR.IRelaxedToken(9, 'delimiter.cpp'),
        ],
      ),
    ],
  ]);
}

