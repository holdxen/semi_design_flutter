// Generated 1:1 from languages/definitions/ruby/ruby.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('ruby')
void runLanguagesDefinitionsRubyRubyTestCases() {
  TR.testTokenization('ruby', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'class Klass def init() end',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.class.ruby'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constructor.identifier.ruby'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'keyword.def.ruby'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.ruby'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.ruby'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'keyword.def.ruby'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x == 1 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ruby'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.ruby'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.ruby'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'text =~ /Ruby/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ruby'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'operator.ruby'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'regexp.delim.ruby'),
          TR.IRelaxedToken(9, 'regexp.ruby'),
          TR.IRelaxedToken(13, 'regexp.delim.ruby'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'text.sub!(/Rbuy/, "Ruby")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ruby'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.ruby'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.ruby'),
          TR.IRelaxedToken(10, 'regexp.delim.ruby'),
          TR.IRelaxedToken(11, 'regexp.ruby'),
          TR.IRelaxedToken(15, 'regexp.delim.ruby'),
          TR.IRelaxedToken(16, 'delimiter.ruby'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.d.delim.ruby'),
          TR.IRelaxedToken(19, 'string.\$S2.ruby'),
          TR.IRelaxedToken(23, 'string.d.delim.ruby'),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.ruby'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a / b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ruby'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.ruby'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.ruby'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<<HERE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.delimiter.ruby'),
        ],
      ),
      TR.ITestItem(
        'do some string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.ruby'),
        ],
      ),
      TR.ITestItem(
        'HERE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.delimiter.ruby'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x <<HERE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ruby'),
          TR.IRelaxedToken(1, 'string.heredoc.delimiter.ruby'),
        ],
      ),
      TR.ITestItem(
        'do some string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.ruby'),
        ],
      ),
      TR.ITestItem(
        'HERE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.delimiter.ruby'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x<<HERE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ruby'),
          TR.IRelaxedToken(1, 'operator.ruby'),
          TR.IRelaxedToken(3, 'constructor.identifier.ruby'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x<<-HERE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ruby'),
          TR.IRelaxedToken(1, 'string.heredoc.delimiter.ruby'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x<<~HERE',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.ruby'),
          TR.IRelaxedToken(1, 'string.heredoc.delimiter.ruby'),
        ],
      ),
    ],
  ]);
}

