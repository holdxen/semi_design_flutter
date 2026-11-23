// Generated 1:1 from languages/definitions/restructuredtext/restructuredtext.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('restructuredtext')
void runLanguagesDefinitionsRestructuredtextRestructuredtextTestCases() {
  TR.testTokenization('restructuredtext', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'some property = Text::ProxyLibrary::ProxyInterfaceTest::DeleteProxyInterface();',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#####',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'strong **strong**',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'strong.rst'),
        ],
      ),
      TR.ITestItem(
        'emphasis *emphasis*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'emphasis.rst'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.. [23] This is the footnote',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
      TR.ITestItem(
        '.. [#ab] This is the footnote',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
      TR.ITestItem(
        '.. [#] This is the footnote',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
      TR.ITestItem(
        '.. [*] This is the footnote',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(5, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        ' .. [23] This is not the footnote',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[23]_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'string.link.rst'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        '[*]_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'string.link.rst'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '[#]_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'string.link.rst'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '[#abc]_ [#]_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'string.link.rst'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(9, 'string.link.rst'),
          TR.IRelaxedToken(10, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.. [A3] This is the citation',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' .. [A3] This is not the citation',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.. [A3] This is the citation',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
      TR.ITestItem(
        ' first line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        ' second line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        'new line starts',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[A3]_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'string.link.rst'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Interpreted Text `text`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        ' .. _`text`: paragraph',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'string.link.rst'),
          TR.IRelaxedToken(10, ''),
        ],
      ),
      TR.ITestItem(
        'Interpreted Text :role:`text`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(18, 'keyword.rst'),
          TR.IRelaxedToken(22, ''),
        ],
      ),
      TR.ITestItem(
        'Interpreted Text `text`:role:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(24, 'keyword.rst'),
          TR.IRelaxedToken(28, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.. note:: This is a directive',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.rst'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'link .. _link: this is not a hyperlink',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '.. _link: this is a hyperlink',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(10, 'string.link.rst'),
        ],
      ),
      TR.ITestItem(
        '.. _`link`: this is a hyperlink',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(12, 'string.link.rst'),
        ],
      ),
      TR.ITestItem(
        '.. __: this is a anonymous hyperlink',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(7, 'string.link.rst'),
        ],
      ),
      TR.ITestItem(
        '__: this is a anonymous hyperlink',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '...... _`this is a inline internal target`',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(9, 'string.link.rst'),
          TR.IRelaxedToken(41, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.. |biohazard| image:: biohazard.png',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.link.rst'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(15, 'keyword.rst'),
          TR.IRelaxedToken(20, ''),
        ],
      ),
      TR.ITestItem(
        '... |biohazard| ...',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(5, 'string.link.rst'),
          TR.IRelaxedToken(14, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'ref_ `ref`_ ref__ `ref`__',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.link.rst'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(5, 'string.link.rst'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(12, 'string.link.rst'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(18, 'string.link.rst'),
          TR.IRelaxedToken(23, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.... `title <http://google.com>`_',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'string.link.rst'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'string.link.rst'),
          TR.IRelaxedToken(30, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '::',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        ' first line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
      TR.ITestItem(
        ' second line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        ' paragraph',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'desc ::',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'keyword.rst'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '>>first line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
        ],
      ),
      TR.ITestItem(
        '>second line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(1, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        ' paragraph',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.. comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'comment.rst'),
        ],
      ),
      TR.ITestItem(
        ' firstline',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.rst'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        ' paragraph',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '==',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '===',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1. item',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        'a. item',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        '* item',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '- item',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '1) item',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        '(a) item',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
          TR.IRelaxedToken(4, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '+------------------------+------------+----------+----------+',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
        ],
      ),
      TR.ITestItem(
        '+========================+============+==========+==========+',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.rst'),
        ],
      ),
    ],
  ]);
}

