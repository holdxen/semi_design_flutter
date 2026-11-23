// Generated 1:1 from languages/definitions/redis/redis.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('redis')
void runLanguagesDefinitionsRedisRedisTestCases() {
  TR.testTokenization('redis', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '-123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.redis'),
          TR.IRelaxedToken(1, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xaBc123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0XaBc123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0xAB_CD',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
          TR.IRelaxedToken(4, 'identifier.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$-123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$-+-123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$123.5678',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$0.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$99.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$0.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '123.5678',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.99',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '99.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E-2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E+2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1.E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.1E2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'SET key1 "Hello"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.redis'),
          TR.IRelaxedToken(3, 'white.redis'),
          TR.IRelaxedToken(4, 'identifier.redis'),
          TR.IRelaxedToken(8, 'white.redis'),
          TR.IRelaxedToken(9, 'string.double.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'SET key1 \'Hello\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.redis'),
          TR.IRelaxedToken(3, 'white.redis'),
          TR.IRelaxedToken(4, 'identifier.redis'),
          TR.IRelaxedToken(8, 'white.redis'),
          TR.IRelaxedToken(9, 'string.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'DEL key1 key2 key3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.redis'),
          TR.IRelaxedToken(3, 'white.redis'),
          TR.IRelaxedToken(4, 'identifier.redis'),
          TR.IRelaxedToken(8, 'white.redis'),
          TR.IRelaxedToken(9, 'identifier.redis'),
          TR.IRelaxedToken(13, 'white.redis'),
          TR.IRelaxedToken(14, 'identifier.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'GEOADD Sicily 13.361389 38.115556 "Palermo" 15.087269 37.502669 "Catania"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.redis'),
          TR.IRelaxedToken(6, 'white.redis'),
          TR.IRelaxedToken(7, 'identifier.redis'),
          TR.IRelaxedToken(13, 'white.redis'),
          TR.IRelaxedToken(14, 'number.redis'),
          TR.IRelaxedToken(23, 'white.redis'),
          TR.IRelaxedToken(24, 'number.redis'),
          TR.IRelaxedToken(33, 'white.redis'),
          TR.IRelaxedToken(34, 'string.double.redis'),
          TR.IRelaxedToken(43, 'white.redis'),
          TR.IRelaxedToken(44, 'number.redis'),
          TR.IRelaxedToken(53, 'white.redis'),
          TR.IRelaxedToken(54, 'number.redis'),
          TR.IRelaxedToken(63, 'white.redis'),
          TR.IRelaxedToken(64, 'string.double.redis'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'HGET myhash field1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.redis'),
          TR.IRelaxedToken(4, 'white.redis'),
          TR.IRelaxedToken(5, 'identifier.redis'),
          TR.IRelaxedToken(11, 'white.redis'),
          TR.IRelaxedToken(12, 'identifier.redis'),
        ],
      ),
    ],
  ]);
}

