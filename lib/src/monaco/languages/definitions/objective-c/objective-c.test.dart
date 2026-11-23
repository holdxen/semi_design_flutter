// Generated 1:1 from languages/definitions/objective-c/objective-c.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('objective-c')
void runLanguagesDefinitionsObjectiveCObjectiveCTestCases() {
  TR.testTokenization('objective-c', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '-(id) initWithParams:(id<anObject>) aHandler withDeviceStateManager:(id<anotherObject>) deviceStateManager',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.parenthesis.objective-c'),
          TR.IRelaxedToken(2, 'keyword.objective-c'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.objective-c'),
          TR.IRelaxedToken(5, 'white.objective-c'),
          TR.IRelaxedToken(6, 'identifier.objective-c'),
          TR.IRelaxedToken(20, 'delimiter.objective-c'),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.objective-c'),
          TR.IRelaxedToken(22, 'keyword.objective-c'),
          TR.IRelaxedToken(24, 'delimiter.angle.objective-c'),
          TR.IRelaxedToken(25, 'identifier.objective-c'),
          TR.IRelaxedToken(33, 'delimiter.angle.objective-c'),
          TR.IRelaxedToken(34, 'delimiter.parenthesis.objective-c'),
          TR.IRelaxedToken(35, 'white.objective-c'),
          TR.IRelaxedToken(36, 'identifier.objective-c'),
          TR.IRelaxedToken(44, 'white.objective-c'),
          TR.IRelaxedToken(45, 'identifier.objective-c'),
          TR.IRelaxedToken(67, 'delimiter.objective-c'),
          TR.IRelaxedToken(68, 'delimiter.parenthesis.objective-c'),
          TR.IRelaxedToken(69, 'keyword.objective-c'),
          TR.IRelaxedToken(71, 'delimiter.angle.objective-c'),
          TR.IRelaxedToken(72, 'identifier.objective-c'),
          TR.IRelaxedToken(85, 'delimiter.angle.objective-c'),
          TR.IRelaxedToken(86, 'delimiter.parenthesis.objective-c'),
          TR.IRelaxedToken(87, 'white.objective-c'),
          TR.IRelaxedToken(88, 'identifier.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'white.objective-c'),
          TR.IRelaxedToken(4, 'comment.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.objective-c'),
          TR.IRelaxedToken(1, 'identifier.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
          TR.IRelaxedToken(8, 'identifier.objective-c'),
          TR.IRelaxedToken(9, 'white.objective-c'),
          TR.IRelaxedToken(10, 'identifier.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.objective-c'),
          TR.IRelaxedToken(1, 'white.objective-c'),
          TR.IRelaxedToken(2, 'operator.objective-c'),
          TR.IRelaxedToken(3, 'white.objective-c'),
          TR.IRelaxedToken(4, 'number.objective-c'),
          TR.IRelaxedToken(5, 'delimiter.objective-c'),
          TR.IRelaxedToken(6, 'white.objective-c'),
          TR.IRelaxedToken(7, 'comment.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.objective-c'),
          TR.IRelaxedToken(3, 'white.objective-c'),
          TR.IRelaxedToken(4, 'identifier.objective-c'),
          TR.IRelaxedToken(5, 'white.objective-c'),
          TR.IRelaxedToken(6, 'operator.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
          TR.IRelaxedToken(8, 'number.objective-c'),
          TR.IRelaxedToken(9, 'delimiter.objective-c'),
          TR.IRelaxedToken(10, 'white.objective-c'),
          TR.IRelaxedToken(11, 'comment.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* embedded comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.objective-c'),
          TR.IRelaxedToken(3, 'white.objective-c'),
          TR.IRelaxedToken(4, 'identifier.objective-c'),
          TR.IRelaxedToken(5, 'white.objective-c'),
          TR.IRelaxedToken(6, 'operator.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
          TR.IRelaxedToken(8, 'comment.objective-c'),
          TR.IRelaxedToken(30, 'white.objective-c'),
          TR.IRelaxedToken(31, 'number.objective-c'),
          TR.IRelaxedToken(32, 'delimiter.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* comment and syntax error*/ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.objective-c'),
          TR.IRelaxedToken(3, 'white.objective-c'),
          TR.IRelaxedToken(4, 'identifier.objective-c'),
          TR.IRelaxedToken(5, 'white.objective-c'),
          TR.IRelaxedToken(6, 'operator.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
          TR.IRelaxedToken(8, 'comment.objective-c'),
          TR.IRelaxedToken(37, 'white.objective-c'),
          TR.IRelaxedToken(38, 'number.objective-c'),
          TR.IRelaxedToken(39, 'delimiter.objective-c'),
          TR.IRelaxedToken(40, 'white.objective-c'),
          TR.IRelaxedToken(41, 'operator.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.objective-c'),
          TR.IRelaxedToken(1, 'white.objective-c'),
          TR.IRelaxedToken(2, 'operator.objective-c'),
          TR.IRelaxedToken(3, 'white.objective-c'),
          TR.IRelaxedToken(4, 'comment.objective-c'),
          TR.IRelaxedToken(8, 'delimiter.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.objective-c'),
          TR.IRelaxedToken(1, 'white.objective-c'),
          TR.IRelaxedToken(2, 'operator.objective-c'),
          TR.IRelaxedToken(3, 'white.objective-c'),
          TR.IRelaxedToken(4, 'comment.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#import <GTLT.h>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
          TR.IRelaxedToken(8, 'delimiter.angle.objective-c'),
          TR.IRelaxedToken(9, 'identifier.objective-c'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.objective-c'),
          TR.IRelaxedToken(15, 'delimiter.angle.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.objective-c'),
          TR.IRelaxedToken(1, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.objective-c'),
          TR.IRelaxedToken(2, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.objective-c'),
          TR.IRelaxedToken(5, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(4, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(6, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(6, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5F ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(5, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5f ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(5, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3F ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72E3f ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3F ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.72e3f ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.objective-c'),
          TR.IRelaxedToken(7, 'white.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.objective-c'),
          TR.IRelaxedToken(1, 'operator.objective-c'),
          TR.IRelaxedToken(2, 'number.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.objective-c'),
          TR.IRelaxedToken(3, 'operator.objective-c'),
          TR.IRelaxedToken(4, 'number.objective-c'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.objective-c'),
          TR.IRelaxedToken(1, 'white.objective-c'),
          TR.IRelaxedToken(2, 'operator.objective-c'),
          TR.IRelaxedToken(3, 'white.objective-c'),
          TR.IRelaxedToken(4, 'number.objective-c'),
        ],
      ),
    ],
  ]);
}

