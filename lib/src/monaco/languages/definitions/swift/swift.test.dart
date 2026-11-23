// Generated 1:1 from languages/definitions/swift/swift.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('swift')
void runLanguagesDefinitionsSwiftSwiftTestCases() {
  TR.testTokenization('swift', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '@escaping',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.control.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'class App: UI, UIApp, UIView {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.swift'),
          TR.IRelaxedToken(5, 'white.swift'),
          TR.IRelaxedToken(6, 'type.identifier.swift'),
          TR.IRelaxedToken(9, 'operator.swift'),
          TR.IRelaxedToken(10, 'white.swift'),
          TR.IRelaxedToken(11, 'type.identifier.swift'),
          TR.IRelaxedToken(13, 'operator.swift'),
          TR.IRelaxedToken(14, 'white.swift'),
          TR.IRelaxedToken(15, 'type.identifier.swift'),
          TR.IRelaxedToken(20, 'operator.swift'),
          TR.IRelaxedToken(21, 'white.swift'),
          TR.IRelaxedToken(22, 'type.identifier.swift'),
          TR.IRelaxedToken(28, 'white.swift'),
          TR.IRelaxedToken(29, 'delimiter.curly.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    var window: UIWindow?',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.swift'),
          TR.IRelaxedToken(4, 'keyword.swift'),
          TR.IRelaxedToken(7, 'white.swift'),
          TR.IRelaxedToken(8, 'identifier.swift'),
          TR.IRelaxedToken(14, 'operator.swift'),
          TR.IRelaxedToken(15, 'white.swift'),
          TR.IRelaxedToken(16, 'type.identifier.swift'),
          TR.IRelaxedToken(24, 'operator.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // Comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.swift'),
          TR.IRelaxedToken(4, 'comment.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    /* Comment //Embedded */ var y = 0b10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.swift'),
          TR.IRelaxedToken(4, 'comment.swift'),
          TR.IRelaxedToken(28, 'white.swift'),
          TR.IRelaxedToken(29, 'keyword.swift'),
          TR.IRelaxedToken(32, 'white.swift'),
          TR.IRelaxedToken(33, 'identifier.swift'),
          TR.IRelaxedToken(34, 'white.swift'),
          TR.IRelaxedToken(35, 'operator.swift'),
          TR.IRelaxedToken(36, 'white.swift'),
          TR.IRelaxedToken(37, 'number.binary.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    public func app(app: App, opts:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.swift'),
          TR.IRelaxedToken(4, 'keyword.swift'),
          TR.IRelaxedToken(10, 'white.swift'),
          TR.IRelaxedToken(11, 'keyword.swift'),
          TR.IRelaxedToken(15, 'white.swift'),
          TR.IRelaxedToken(16, 'identifier.swift'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.swift'),
          TR.IRelaxedToken(20, 'identifier.swift'),
          TR.IRelaxedToken(23, 'operator.swift'),
          TR.IRelaxedToken(24, 'white.swift'),
          TR.IRelaxedToken(25, 'type.identifier.swift'),
          TR.IRelaxedToken(28, 'operator.swift'),
          TR.IRelaxedToken(29, 'white.swift'),
          TR.IRelaxedToken(30, 'identifier.swift'),
          TR.IRelaxedToken(34, 'operator.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '        [NSObject: AnyObject]?) -> Bool {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.swift'),
          TR.IRelaxedToken(8, 'delimiter.square.swift'),
          TR.IRelaxedToken(9, 'type.identifier.swift'),
          TR.IRelaxedToken(17, 'operator.swift'),
          TR.IRelaxedToken(18, 'white.swift'),
          TR.IRelaxedToken(19, 'type.identifier.swift'),
          TR.IRelaxedToken(28, 'delimiter.square.swift'),
          TR.IRelaxedToken(29, 'operator.swift'),
          TR.IRelaxedToken(30, 'delimiter.parenthesis.swift'),
          TR.IRelaxedToken(31, 'white.swift'),
          TR.IRelaxedToken(32, 'operator.swift'),
          TR.IRelaxedToken(34, 'white.swift'),
          TR.IRelaxedToken(35, 'type.identifier.swift'),
          TR.IRelaxedToken(39, 'white.swift'),
          TR.IRelaxedToken(40, 'delimiter.curly.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '        var `String` = "String w/ \\"escape\\""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.swift'),
          TR.IRelaxedToken(8, 'keyword.swift'),
          TR.IRelaxedToken(11, 'white.swift'),
          TR.IRelaxedToken(12, 'operator.swift'),
          TR.IRelaxedToken(13, 'identifier.swift'),
          TR.IRelaxedToken(19, 'operator.swift'),
          TR.IRelaxedToken(20, 'white.swift'),
          TR.IRelaxedToken(21, 'operator.swift'),
          TR.IRelaxedToken(22, 'white.swift'),
          TR.IRelaxedToken(23, 'string.quote.swift'),
          TR.IRelaxedToken(24, 'string.swift'),
          TR.IRelaxedToken(44, 'string.quote.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '        let message = "\\(y) times 2.5 is \\(Double(25) * 2.5)"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.swift'),
          TR.IRelaxedToken(8, 'keyword.swift'),
          TR.IRelaxedToken(11, 'white.swift'),
          TR.IRelaxedToken(12, 'identifier.swift'),
          TR.IRelaxedToken(19, 'white.swift'),
          TR.IRelaxedToken(20, 'operator.swift'),
          TR.IRelaxedToken(21, 'white.swift'),
          TR.IRelaxedToken(22, 'string.quote.swift'),
          TR.IRelaxedToken(23, 'operator.swift'),
          TR.IRelaxedToken(25, 'identifier.swift'),
          TR.IRelaxedToken(26, 'operator.swift'),
          TR.IRelaxedToken(27, 'string.swift'),
          TR.IRelaxedToken(41, 'operator.swift'),
          TR.IRelaxedToken(43, 'type.identifier.swift'),
          TR.IRelaxedToken(49, 'operator.swift'),
          TR.IRelaxedToken(50, 'number.swift'),
          TR.IRelaxedToken(52, 'operator.swift'),
          TR.IRelaxedToken(53, ''),
          TR.IRelaxedToken(54, 'operator.swift'),
          TR.IRelaxedToken(55, ''),
          TR.IRelaxedToken(56, 'number.float.swift'),
          TR.IRelaxedToken(59, 'operator.swift'),
          TR.IRelaxedToken(60, 'string.quote.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"""test"test',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.swift'),
          TR.IRelaxedToken(3, 'string.swift'),
        ],
      ),
      TR.ITestItem(
        ' keepsgoing"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.swift'),
          TR.IRelaxedToken(11, 'string.quote.swift'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '        let view = self.window!.contr as! UIView',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.swift'),
          TR.IRelaxedToken(8, 'keyword.swift'),
          TR.IRelaxedToken(11, 'white.swift'),
          TR.IRelaxedToken(12, 'identifier.swift'),
          TR.IRelaxedToken(16, 'white.swift'),
          TR.IRelaxedToken(17, 'operator.swift'),
          TR.IRelaxedToken(18, 'white.swift'),
          TR.IRelaxedToken(19, 'keyword.swift'),
          TR.IRelaxedToken(23, 'delimeter.swift'),
          TR.IRelaxedToken(24, 'type.identifier.swift'),
          TR.IRelaxedToken(30, 'operator.swift'),
          TR.IRelaxedToken(31, 'delimeter.swift'),
          TR.IRelaxedToken(32, 'type.identifier.swift'),
          TR.IRelaxedToken(37, 'white.swift'),
          TR.IRelaxedToken(38, 'keyword.swift'),
          TR.IRelaxedToken(40, 'operator.swift'),
          TR.IRelaxedToken(41, 'white.swift'),
          TR.IRelaxedToken(42, 'type.identifier.swift'),
        ],
      ),
    ],
  ]);
}

