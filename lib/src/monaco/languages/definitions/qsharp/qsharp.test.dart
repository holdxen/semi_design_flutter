// Generated 1:1 from languages/definitions/qsharp/qsharp.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('qsharp')
void runLanguagesDefinitionsQsharpQsharpTestCases() {
  TR.testTokenization('qsharp', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'open Microsoft.Quantum.Arrays;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.open.qsharp'),
          TR.IRelaxedToken(4, 'white.qsharp'),
          TR.IRelaxedToken(5, 'namespace.qsharp'),
          TR.IRelaxedToken(14, 'delimiter.qsharp'),
          TR.IRelaxedToken(15, 'namespace.qsharp'),
          TR.IRelaxedToken(22, 'delimiter.qsharp'),
          TR.IRelaxedToken(23, 'namespace.qsharp'),
          TR.IRelaxedToken(29, 'delimiter.qsharp'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'operation SampleRandomNumber(nQubits : Int) : Result[] {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.qsharp'),
          TR.IRelaxedToken(9, 'white.qsharp'),
          TR.IRelaxedToken(10, 'identifier.qsharp'),
          TR.IRelaxedToken(28, 'delimiter.parenthesis.qsharp'),
          TR.IRelaxedToken(29, 'identifier.qsharp'),
          TR.IRelaxedToken(36, 'white.qsharp'),
          TR.IRelaxedToken(37, 'operator.qsharp'),
          TR.IRelaxedToken(38, 'white.qsharp'),
          TR.IRelaxedToken(39, 'type.qsharp'),
          TR.IRelaxedToken(42, 'delimiter.parenthesis.qsharp'),
          TR.IRelaxedToken(43, 'white.qsharp'),
          TR.IRelaxedToken(44, 'operator.qsharp'),
          TR.IRelaxedToken(45, 'white.qsharp'),
          TR.IRelaxedToken(46, 'type.qsharp'),
          TR.IRelaxedToken(52, 'delimiter.square.qsharp'),
          TR.IRelaxedToken(54, 'white.qsharp'),
          TR.IRelaxedToken(55, 'delimiter.curly.qsharp'),
        ],
      ),
      TR.ITestItem(
        '\t// We prepare a register of qubits in a uniform',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.qsharp'),
          TR.IRelaxedToken(1, 'comment.qsharp'),
        ],
      ),
      TR.ITestItem(
        '\tuse register = Qubit[nQubits] {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.qsharp'),
          TR.IRelaxedToken(1, 'keyword.qsharp'),
          TR.IRelaxedToken(4, 'white.qsharp'),
          TR.IRelaxedToken(5, 'identifier.qsharp'),
          TR.IRelaxedToken(13, 'white.qsharp'),
          TR.IRelaxedToken(14, 'operator.qsharp'),
          TR.IRelaxedToken(15, 'white.qsharp'),
          TR.IRelaxedToken(16, 'type.qsharp'),
          TR.IRelaxedToken(21, 'delimiter.square.qsharp'),
          TR.IRelaxedToken(22, 'identifier.qsharp'),
          TR.IRelaxedToken(29, 'delimiter.square.qsharp'),
          TR.IRelaxedToken(30, 'white.qsharp'),
          TR.IRelaxedToken(31, 'delimiter.curly.qsharp'),
        ],
      ),
      TR.ITestItem(
        '\t\tApplyToEachA(H, register);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.qsharp'),
          TR.IRelaxedToken(2, 'identifier.qsharp'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.qsharp'),
          TR.IRelaxedToken(15, 'keyword.qsharp'),
          TR.IRelaxedToken(16, 'delimiter.qsharp'),
          TR.IRelaxedToken(17, 'white.qsharp'),
          TR.IRelaxedToken(18, 'identifier.qsharp'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.qsharp'),
          TR.IRelaxedToken(27, 'delimiter.qsharp'),
        ],
      ),
      TR.ITestItem(
        '\t\treturn ForEach(MResetZ, register);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.qsharp'),
          TR.IRelaxedToken(2, 'keyword.qsharp'),
          TR.IRelaxedToken(8, 'white.qsharp'),
          TR.IRelaxedToken(9, 'identifier.qsharp'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.qsharp'),
          TR.IRelaxedToken(17, 'identifier.qsharp'),
          TR.IRelaxedToken(24, 'delimiter.qsharp'),
          TR.IRelaxedToken(25, 'white.qsharp'),
          TR.IRelaxedToken(26, 'identifier.qsharp'),
          TR.IRelaxedToken(34, 'delimiter.parenthesis.qsharp'),
          TR.IRelaxedToken(35, 'delimiter.qsharp'),
        ],
      ),
      TR.ITestItem(
        '\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.qsharp'),
          TR.IRelaxedToken(1, 'delimiter.curly.qsharp'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.qsharp'),
        ],
      ),
      TR.ITestItem(
        'struct Foo { First : Int, Second : Int }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.qsharp'),
          TR.IRelaxedToken(6, 'white.qsharp'),
          TR.IRelaxedToken(7, 'identifier.qsharp'),
          TR.IRelaxedToken(10, 'white.qsharp'),
          TR.IRelaxedToken(11, 'delimiter.curly.qsharp'),
          TR.IRelaxedToken(12, 'white.qsharp'),
          TR.IRelaxedToken(13, 'identifier.qsharp'),
          TR.IRelaxedToken(18, 'white.qsharp'),
          TR.IRelaxedToken(19, 'operator.qsharp'),
          TR.IRelaxedToken(20, 'white.qsharp'),
          TR.IRelaxedToken(21, 'type.qsharp'),
          TR.IRelaxedToken(24, 'delimiter.qsharp'),
          TR.IRelaxedToken(25, 'white.qsharp'),
          TR.IRelaxedToken(26, 'identifier.qsharp'),
          TR.IRelaxedToken(32, 'white.qsharp'),
          TR.IRelaxedToken(33, 'operator.qsharp'),
          TR.IRelaxedToken(34, 'white.qsharp'),
          TR.IRelaxedToken(35, 'type.qsharp'),
          TR.IRelaxedToken(38, 'white.qsharp'),
          TR.IRelaxedToken(39, 'delimiter.curly.qsharp'),
        ],
      ),
      TR.ITestItem(
        'Foo.First',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.qsharp'),
          TR.IRelaxedToken(3, 'operator.qsharp'),
          TR.IRelaxedToken(4, 'identifier.qsharp'),
        ],
      ),
      TR.ITestItem(
        'import Microsoft.Quantum.Math, Microsoft.Quantum.Diagnostics.*;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.import.qsharp'),
          TR.IRelaxedToken(6, 'white.qsharp'),
          TR.IRelaxedToken(7, 'namespace.qsharp'),
          TR.IRelaxedToken(16, 'delimiter.qsharp'),
          TR.IRelaxedToken(17, 'namespace.qsharp'),
          TR.IRelaxedToken(24, 'delimiter.qsharp'),
          TR.IRelaxedToken(25, 'identifier.qsharp'),
          TR.IRelaxedToken(29, 'delimiter.qsharp'),
          TR.IRelaxedToken(30, 'white.qsharp'),
          TR.IRelaxedToken(31, 'namespace.qsharp'),
          TR.IRelaxedToken(40, 'delimiter.qsharp'),
          TR.IRelaxedToken(41, 'namespace.qsharp'),
          TR.IRelaxedToken(48, 'delimiter.qsharp'),
          TR.IRelaxedToken(49, 'namespace.qsharp'),
          TR.IRelaxedToken(60, 'delimiter.qsharp'),
          TR.IRelaxedToken(61, 'wildcard.qsharp'),
          TR.IRelaxedToken(62, 'delimiter.qsharp'),
        ],
      ),
      TR.ITestItem(
        'export A, B, C;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.qsharp'),
          TR.IRelaxedToken(6, 'white.qsharp'),
          TR.IRelaxedToken(7, 'identifier.qsharp'),
          TR.IRelaxedToken(8, 'delimiter.qsharp'),
          TR.IRelaxedToken(9, 'white.qsharp'),
          TR.IRelaxedToken(10, 'identifier.qsharp'),
          TR.IRelaxedToken(11, 'delimiter.qsharp'),
          TR.IRelaxedToken(12, 'white.qsharp'),
          TR.IRelaxedToken(13, 'identifier.qsharp'),
          TR.IRelaxedToken(14, 'delimiter.qsharp'),
        ],
      ),
    ],
  ]);
}

