// Generated 1:1 from languages/definitions/dockerfile/dockerfile.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('dockerfile')
void runLanguagesDefinitionsDockerfileDockerfileTestCases() {
  TR.testTokenization('dockerfile', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'FROM mono:3.12',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(4, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'ENV KRE_FEED https://www.myget.org/F/aspnetvnext/api/v2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'variable.dockerfile'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        'ENV KRE_USER_HOME /opt/kre',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'variable.dockerfile'),
          TR.IRelaxedToken(17, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'RUN apt-get -qq update && apt-get -qqy install unzip ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'ONBUILD RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/kvminstall.sh | sh',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.dockerfile'),
          TR.IRelaxedToken(11, ''),
        ],
      ),
      TR.ITestItem(
        'ONBUILD RUN bash -c "source \$KRE_USER_HOME/kvm/kvm.sh \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.dockerfile'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(20, 'string.dockerfile'),
          TR.IRelaxedToken(28, 'variable.dockerfile'),
          TR.IRelaxedToken(42, 'string.dockerfile'),
        ],
      ),
      TR.ITestItem(
        '    && kvm install latest -a default \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.dockerfile'),
        ],
      ),
      TR.ITestItem(
        '    && kvm alias default | xargs -i ln -s \$KRE_USER_HOME/packages/{} \$KRE_USER_HOME/packages/default"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.dockerfile'),
          TR.IRelaxedToken(42, 'variable.dockerfile'),
          TR.IRelaxedToken(56, 'string.dockerfile'),
          TR.IRelaxedToken(69, 'variable.dockerfile'),
          TR.IRelaxedToken(83, 'string.dockerfile'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dockerfile'),
        ],
      ),
      TR.ITestItem(
        'RUN apt-get -qqy install \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        '    autoconf \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '    automake \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '    build-essential \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '    libtool ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        'RUN LIBUV_VERSION=1.0.0-rc2 \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        '    && curl -sSL https://github.com/joyent/libuv/archive/v\${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(58, 'variable.dockerfile'),
          TR.IRelaxedToken(74, ''),
        ],
      ),
      TR.ITestItem(
        '    && cd /usr/local/src/libuv-\$LIBUV_VERSION \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(31, 'variable.dockerfile'),
          TR.IRelaxedToken(45, ''),
        ],
      ),
      TR.ITestItem(
        '    && sh autogen.sh && ./configure && make && make install \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '    && rm -rf /usr/local/src/libuv-\$LIBUV_VERSION \\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(35, 'variable.dockerfile'),
          TR.IRelaxedToken(49, ''),
        ],
      ),
      TR.ITestItem(
        '    && ldconfig',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'ENV PATH \$PATH:\$KRE_USER_HOME/packages/default/bin',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'variable.dockerfile'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'variable.dockerfile'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'variable.dockerfile'),
          TR.IRelaxedToken(29, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Extra things to test',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.dockerfile'),
        ],
      ),
      TR.ITestItem(
        'RUN echo "string at end"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(9, 'string.dockerfile'),
        ],
      ),
      TR.ITestItem(
        'RUN echo must work \'some str\' and some more',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(19, 'string.dockerfile'),
          TR.IRelaxedToken(29, ''),
        ],
      ),
      TR.ITestItem(
        'RUN echo hi this is # not a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        'RUN echo \'String with \${VAR} and another \$one here\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(9, 'string.dockerfile'),
          TR.IRelaxedToken(22, 'variable.dockerfile'),
          TR.IRelaxedToken(28, 'string.dockerfile'),
          TR.IRelaxedToken(41, 'variable.dockerfile'),
          TR.IRelaxedToken(45, 'string.dockerfile'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'RUN \\\'e\\\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
      TR.ITestItem(
        'RUN echo hi this is # not a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.dockerfile'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
  ]);
}

