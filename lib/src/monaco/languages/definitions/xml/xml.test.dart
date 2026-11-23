// Generated 1:1 from languages/definitions/xml/xml.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('xml')
void runLanguagesDefinitionsXmlXmlTestCases() {
  TR.testTokenization('xml', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '<person>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(7, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<person/>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(8, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<person >',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<person />',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'tag.xml'),
          TR.IRelaxedToken(9, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<person',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<input',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '< person',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '< person>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'i <person;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.xml'),
          TR.IRelaxedToken(3, 'tag.xml'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name="">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.xml'),
          TR.IRelaxedToken(13, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name="Monaco">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.xml'),
          TR.IRelaxedToken(19, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name=\'Monaco\'>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.xml'),
          TR.IRelaxedToken(19, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name="Monaco" version="1.0">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.xml'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'attribute.name.xml'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'attribute.value.xml'),
          TR.IRelaxedToken(33, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name version>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.name.xml'),
          TR.IRelaxedToken(18, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name=  "monaco">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(13, 'attribute.value.xml'),
          TR.IRelaxedToken(21, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name = "monaco">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(13, 'attribute.value.xml'),
          TR.IRelaxedToken(21, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name!@#="bar">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(15, 'attribute.name.xml'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tool name=">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.xml'),
          TR.IRelaxedToken(12, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '</person>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(8, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '</person  >',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(10, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '</person',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!-- -->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.xml'),
          TR.IRelaxedToken(4, 'comment.content.xml'),
          TR.IRelaxedToken(5, 'comment.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!--a>monaco</a -->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.xml'),
          TR.IRelaxedToken(4, 'comment.content.xml'),
          TR.IRelaxedToken(16, 'comment.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!--a>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.xml'),
          TR.IRelaxedToken(4, 'comment.content.xml'),
        ],
      ),
      TR.ITestItem(
        'monaco ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.content.xml'),
        ],
      ),
      TR.ITestItem(
        'tools</a -->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.content.xml'),
          TR.IRelaxedToken(9, 'comment.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tools><![CDATA[<person/>]]></tools>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(6, 'delimiter.xml'),
          TR.IRelaxedToken(7, 'delimiter.cdata.xml'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(25, 'delimiter.cdata.xml'),
          TR.IRelaxedToken(28, 'delimiter.xml'),
          TR.IRelaxedToken(30, 'tag.xml'),
          TR.IRelaxedToken(35, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<tools>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(6, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<![CDATA[',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.cdata.xml'),
        ],
      ),
      TR.ITestItem(
        '\t\t<person/>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t]]>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.cdata.xml'),
        ],
      ),
      TR.ITestItem(
        '</tools>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(7, 'delimiter.xml'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?xml version="1.0"?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'metatag.xml'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'attribute.value.xml'),
          TR.IRelaxedToken(19, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(1, 'tag.xml'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'attribute.name.xml'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'attribute.value.xml'),
          TR.IRelaxedToken(78, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '  <connectionStrings>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.xml'),
          TR.IRelaxedToken(3, 'tag.xml'),
          TR.IRelaxedToken(20, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '    <add name="MyDB" ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.xml'),
          TR.IRelaxedToken(5, 'tag.xml'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'attribute.name.xml'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'attribute.value.xml'),
          TR.IRelaxedToken(20, ''),
        ],
      ),
      TR.ITestItem(
        '      connectionString="value for the deployed Web.config file" ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'attribute.value.xml'),
          TR.IRelaxedToken(63, ''),
        ],
      ),
      TR.ITestItem(
        '      xdt:Transform="SetAttributes" xdt:Locator="Match(name)"/>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'attribute.value.xml'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(36, 'attribute.name.xml'),
          TR.IRelaxedToken(47, ''),
          TR.IRelaxedToken(48, 'attribute.value.xml'),
          TR.IRelaxedToken(61, 'tag.xml'),
          TR.IRelaxedToken(62, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '  </connectionStrings>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.xml'),
          TR.IRelaxedToken(4, 'tag.xml'),
          TR.IRelaxedToken(21, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '  <system.web>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.xml'),
          TR.IRelaxedToken(3, 'tag.xml'),
          TR.IRelaxedToken(13, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '    <customErrors defaultRedirect="GenericError.htm"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.xml'),
          TR.IRelaxedToken(5, 'tag.xml'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'attribute.name.xml'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'attribute.value.xml'),
        ],
      ),
      TR.ITestItem(
        '      mode="RemoteOnly" xdt:Transform="Replace">',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'attribute.name.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.value.xml'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'attribute.name.xml'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'attribute.value.xml'),
          TR.IRelaxedToken(47, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '      <error statusCode="500" redirect="InternalError.htm"/>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'delimiter.xml'),
          TR.IRelaxedToken(7, 'tag.xml'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'attribute.name.xml'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'attribute.value.xml'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'attribute.name.xml'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'attribute.value.xml'),
          TR.IRelaxedToken(58, 'tag.xml'),
          TR.IRelaxedToken(59, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '    </customErrors>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'delimiter.xml'),
          TR.IRelaxedToken(6, 'tag.xml'),
          TR.IRelaxedToken(18, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '  </system.web>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.xml'),
          TR.IRelaxedToken(4, 'tag.xml'),
          TR.IRelaxedToken(14, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '\t<!-- The stuff below was added for extra tokenizer testing -->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'comment.xml'),
          TR.IRelaxedToken(5, 'comment.content.xml'),
          TR.IRelaxedToken(60, 'comment.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<!-- A multi-line comment <with> </with>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'comment.xml'),
          TR.IRelaxedToken(5, 'comment.content.xml'),
        ],
      ),
      TR.ITestItem(
        '       <tags>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.content.xml'),
        ],
      ),
      TR.ITestItem(
        '\t\t\t\t -->',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.content.xml'),
          TR.IRelaxedToken(5, 'comment.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<!DOCTYPE another meta tag>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.xml'),
          TR.IRelaxedToken(3, 'metatag.xml'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'attribute.name.xml'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'attribute.name.xml'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'attribute.name.xml'),
          TR.IRelaxedToken(27, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<tools><![CDATA[Some text and tags <person/>]]></tools>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(7, 'delimiter.xml'),
          TR.IRelaxedToken(8, 'delimiter.cdata.xml'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(45, 'delimiter.cdata.xml'),
          TR.IRelaxedToken(48, 'delimiter.xml'),
          TR.IRelaxedToken(50, 'tag.xml'),
          TR.IRelaxedToken(55, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<aSelfClosingTag with="attribute" />',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'attribute.name.xml'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'attribute.value.xml'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'tag.xml'),
          TR.IRelaxedToken(36, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<aSelfClosingTag with="attribute"/>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'attribute.name.xml'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'attribute.value.xml'),
          TR.IRelaxedToken(34, 'tag.xml'),
          TR.IRelaxedToken(35, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<namespace:aSelfClosingTag otherspace:with="attribute"/>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'attribute.name.xml'),
          TR.IRelaxedToken(43, ''),
          TR.IRelaxedToken(44, 'attribute.value.xml'),
          TR.IRelaxedToken(55, 'tag.xml'),
          TR.IRelaxedToken(56, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<valid-name also_valid this.one=\'too is valid\'/>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'attribute.name.xml'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'attribute.name.xml'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'attribute.value.xml'),
          TR.IRelaxedToken(47, 'tag.xml'),
          TR.IRelaxedToken(48, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<aSimpleSelfClosingTag />',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'tag.xml'),
          TR.IRelaxedToken(25, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '\t<aSimpleSelfClosingTag/>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(24, 'delimiter.xml'),
        ],
      ),
      TR.ITestItem(
        '</configuration>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.xml'),
          TR.IRelaxedToken(2, 'tag.xml'),
          TR.IRelaxedToken(15, 'delimiter.xml'),
        ],
      ),
    ],
  ]);
}

