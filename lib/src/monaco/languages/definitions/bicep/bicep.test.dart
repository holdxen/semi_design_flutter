// Generated 1:1 from languages/definitions/bicep/bicep.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('bicep')
void runLanguagesDefinitionsBicepBicepTestCases() {
  TR.testTokenization('bicep', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'resource test \'Microsoft.AAD/domainServices@2021-03-01\' = {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'string.quote.bicep'),
          TR.IRelaxedToken(15, 'string.bicep'),
          TR.IRelaxedToken(55, ''),
        ],
      ),
      TR.ITestItem(
        '  name: \'asdfsdf\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'string.quote.bicep'),
          TR.IRelaxedToken(9, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  // this is a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '  properties: {/*comment*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(15, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '    domainConfigurationType/*comment*/:/*comment*/\'as//notacomment!d/* also not a comment */fsdf\'// test!/*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(27, 'comment.bicep'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'comment.bicep'),
          TR.IRelaxedToken(50, 'string.quote.bicep'),
          TR.IRelaxedToken(51, 'string.bicep'),
          TR.IRelaxedToken(97, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '    /* multi',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '    line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '    comment */ domainName: /*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.bicep'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(27, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '    asdf*/\'test\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
          TR.IRelaxedToken(10, 'string.quote.bicep'),
          TR.IRelaxedToken(11, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '    // comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// test',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '/* test 2 */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        'targetScope = \'resourceGroup\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(14, 'string.quote.bicep'),
          TR.IRelaxedToken(15, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'resource avcsdd \'Microsoft.Cache/redis@2020-06-01\' = { // line comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'string.quote.bicep'),
          TR.IRelaxedToken(17, 'string.bicep'),
          TR.IRelaxedToken(50, ''),
          TR.IRelaxedToken(55, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '  name: \'def\' /* block',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'string.quote.bicep'),
          TR.IRelaxedToken(9, 'string.bicep'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '  comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '  location: \'somewhere\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(12, 'string.quote.bicep'),
          TR.IRelaxedToken(13, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  properties: {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        '    sku: {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
      TR.ITestItem(
        '      capacity: 123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'identifier.bicep'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(16, 'number.bicep'),
        ],
      ),
      TR.ITestItem(
        '      family: \'C\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(14, 'string.quote.bicep'),
          TR.IRelaxedToken(15, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '      name: \'Basic\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'identifier.bicep'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(12, 'string.quote.bicep'),
          TR.IRelaxedToken(13, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '    }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '}',
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
        'var secretsObject = {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(17, ''),
        ],
      ),
      TR.ITestItem(
        '  secrets: [',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(9, ''),
        ],
      ),
      TR.ITestItem(
        '    \'abc\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.quote.bicep'),
          TR.IRelaxedToken(5, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '    \'def\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.quote.bicep'),
          TR.IRelaxedToken(5, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  ]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '}',
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
        'var parent = \'abc\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(13, 'string.quote.bicep'),
          TR.IRelaxedToken(14, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'resource secrets0 \'Microsoft.KeyVault/vaults/secrets@2018-02-14\' = {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.quote.bicep'),
          TR.IRelaxedToken(19, 'string.bicep'),
          TR.IRelaxedToken(64, ''),
        ],
      ),
      TR.ITestItem(
        '  name: \'\${parent}/child\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'string.quote.bicep'),
          TR.IRelaxedToken(9, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(11, 'identifier.bicep'),
          TR.IRelaxedToken(17, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(18, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  properties: {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        '    attributes:  {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(14, ''),
        ],
      ),
      TR.ITestItem(
        '      enabled: true',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(6, 'identifier.bicep'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(15, 'keyword.bicep'),
        ],
      ),
      TR.ITestItem(
        '    }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        'resource secrets1 \'Microsoft.KeyVault/vaults/secrets@2018-02-14\' = if (secrets0.id == \'\') {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.quote.bicep'),
          TR.IRelaxedToken(19, 'string.bicep'),
          TR.IRelaxedToken(64, ''),
          TR.IRelaxedToken(67, 'keyword.bicep'),
          TR.IRelaxedToken(69, ''),
          TR.IRelaxedToken(71, 'identifier.bicep'),
          TR.IRelaxedToken(79, ''),
          TR.IRelaxedToken(80, 'identifier.bicep'),
          TR.IRelaxedToken(82, ''),
          TR.IRelaxedToken(86, 'string.quote.bicep'),
          TR.IRelaxedToken(87, 'string.bicep'),
          TR.IRelaxedToken(88, ''),
        ],
      ),
      TR.ITestItem(
        '  name: \'\${parent}/child1\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'string.quote.bicep'),
          TR.IRelaxedToken(9, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(11, 'identifier.bicep'),
          TR.IRelaxedToken(17, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(18, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  properties: {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '}',
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
        'resource secrets2 \'Microsoft.KeyVault/vaults/secrets@2018-02-14\' = [for secret in secretsObject.secrets: {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.quote.bicep'),
          TR.IRelaxedToken(19, 'string.bicep'),
          TR.IRelaxedToken(64, ''),
          TR.IRelaxedToken(68, 'keyword.bicep'),
          TR.IRelaxedToken(71, ''),
          TR.IRelaxedToken(72, 'identifier.bicep'),
          TR.IRelaxedToken(78, ''),
          TR.IRelaxedToken(79, 'keyword.bicep'),
          TR.IRelaxedToken(81, ''),
          TR.IRelaxedToken(82, 'identifier.bicep'),
          TR.IRelaxedToken(95, ''),
          TR.IRelaxedToken(96, 'identifier.bicep'),
          TR.IRelaxedToken(103, ''),
        ],
      ),
      TR.ITestItem(
        '  name: \'asdfsd/forloop\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'string.quote.bicep'),
          TR.IRelaxedToken(9, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  properties: {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        '}]',
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
        'resource secrets3 \'Microsoft.KeyVault/vaults/secrets@2018-02-14\' = [for secret in secretsObject.secrets: {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.quote.bicep'),
          TR.IRelaxedToken(19, 'string.bicep'),
          TR.IRelaxedToken(64, ''),
          TR.IRelaxedToken(68, 'keyword.bicep'),
          TR.IRelaxedToken(71, ''),
          TR.IRelaxedToken(72, 'identifier.bicep'),
          TR.IRelaxedToken(78, ''),
          TR.IRelaxedToken(79, 'keyword.bicep'),
          TR.IRelaxedToken(81, ''),
          TR.IRelaxedToken(82, 'identifier.bicep'),
          TR.IRelaxedToken(95, ''),
          TR.IRelaxedToken(96, 'identifier.bicep'),
          TR.IRelaxedToken(103, ''),
        ],
      ),
      TR.ITestItem(
        '  name: \'jk\${true}asdf\${23}.\\\${SDF\${secretsObject[\'secrets\'][1]}\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'string.quote.bicep'),
          TR.IRelaxedToken(9, 'string.bicep'),
          TR.IRelaxedToken(11, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(13, 'keyword.bicep'),
          TR.IRelaxedToken(17, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(18, 'string.bicep'),
          TR.IRelaxedToken(22, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(24, 'number.bicep'),
          TR.IRelaxedToken(26, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(27, 'string.bicep'),
          TR.IRelaxedToken(28, 'string.escape.bicep'),
          TR.IRelaxedToken(31, 'string.bicep'),
          TR.IRelaxedToken(34, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(36, 'identifier.bicep'),
          TR.IRelaxedToken(49, ''),
          TR.IRelaxedToken(50, 'string.quote.bicep'),
          TR.IRelaxedToken(51, 'string.bicep'),
          TR.IRelaxedToken(59, ''),
          TR.IRelaxedToken(61, 'number.bicep'),
          TR.IRelaxedToken(62, ''),
          TR.IRelaxedToken(63, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(64, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  properties: {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '}]',
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
        'resource secrets4 \'Microsoft.KeyVault/vaults/secrets@2018-02-14\' = [for secret in secretsObject.secrets: if (true) {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.quote.bicep'),
          TR.IRelaxedToken(19, 'string.bicep'),
          TR.IRelaxedToken(64, ''),
          TR.IRelaxedToken(68, 'keyword.bicep'),
          TR.IRelaxedToken(71, ''),
          TR.IRelaxedToken(72, 'identifier.bicep'),
          TR.IRelaxedToken(78, ''),
          TR.IRelaxedToken(79, 'keyword.bicep'),
          TR.IRelaxedToken(81, ''),
          TR.IRelaxedToken(82, 'identifier.bicep'),
          TR.IRelaxedToken(95, ''),
          TR.IRelaxedToken(96, 'identifier.bicep'),
          TR.IRelaxedToken(103, ''),
          TR.IRelaxedToken(105, 'keyword.bicep'),
          TR.IRelaxedToken(107, ''),
          TR.IRelaxedToken(109, 'keyword.bicep'),
          TR.IRelaxedToken(113, ''),
        ],
      ),
      TR.ITestItem(
        '  \'name\': \'test\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(10, 'string.quote.bicep'),
          TR.IRelaxedToken(11, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  properties:{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '}]',
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
        'resource virtualNetwork \'Microsoft.Network/virtualNetworks@2020-08-01\' existing = {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'string.quote.bicep'),
          TR.IRelaxedToken(25, 'string.bicep'),
          TR.IRelaxedToken(70, ''),
          TR.IRelaxedToken(71, 'keyword.bicep'),
          TR.IRelaxedToken(79, ''),
        ],
      ),
      TR.ITestItem(
        '  name: \'myVnet\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'string.quote.bicep'),
          TR.IRelaxedToken(9, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '}',
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
        'var multi = \'\'\'\'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(12, 'string.quote.bicep'),
        ],
      ),
      TR.ITestItem(
        'var multi2 = \'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(13, 'string.quote.bicep'),
        ],
      ),
      TR.ITestItem(
        '      hello!',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '\'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.quote.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'var func = resourceGroup().location',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(11, 'identifier.bicep'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(27, 'identifier.bicep'),
        ],
      ),
      TR.ITestItem(
        'var func2 = reference(\'Microsoft.KeyVault/vaults/secrets\', func)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(12, 'identifier.bicep'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'string.quote.bicep'),
          TR.IRelaxedToken(23, 'string.bicep'),
          TR.IRelaxedToken(57, ''),
          TR.IRelaxedToken(59, 'identifier.bicep'),
          TR.IRelaxedToken(63, ''),
        ],
      ),
      TR.ITestItem(
        'var func3 = union({',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(12, 'identifier.bicep'),
          TR.IRelaxedToken(17, ''),
        ],
      ),
      TR.ITestItem(
        '  \'abc\': resourceGroup().id',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(9, 'identifier.bicep'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(25, 'identifier.bicep'),
        ],
      ),
      TR.ITestItem(
        '}, {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '  \'def\': \'test\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(9, 'string.quote.bicep'),
          TR.IRelaxedToken(10, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '})',
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
        '@allowed([',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'identifier.bicep'),
          TR.IRelaxedToken(8, ''),
        ],
      ),
      TR.ITestItem(
        '  \'hello!\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  \'hi!\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '])',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '@secure()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'identifier.bicep'),
          TR.IRelaxedToken(7, ''),
        ],
      ),
      TR.ITestItem(
        'param secureParam string = \'hello!\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.bicep'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'identifier.bicep'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(27, 'string.quote.bicep'),
          TR.IRelaxedToken(28, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        'var emojis = \'💪😊😈🍕☕\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(13, 'string.quote.bicep'),
          TR.IRelaxedToken(14, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        'var ninjaCat = \'🐱‍👤\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(15, 'string.quote.bicep'),
          TR.IRelaxedToken(16, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '/* block */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '/*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '朝辞白帝彩云间',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '千里江陵一日还',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '两岸猿声啼不住',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '轻舟已过万重山',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '// greek letters in comment: Π π Φ φ plus emoji 😎',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        'var variousAlphabets = {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(20, ''),
        ],
      ),
      TR.ITestItem(
        '  \'α\': \'α\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(7, 'string.quote.bicep'),
          TR.IRelaxedToken(8, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  \'Ωω\': [',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
          TR.IRelaxedToken(6, ''),
        ],
      ),
      TR.ITestItem(
        '    \'Θμ\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.quote.bicep'),
          TR.IRelaxedToken(5, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  ]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
      TR.ITestItem(
        '  \'ążźćłóę\': \'Cześć!\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(13, 'string.quote.bicep'),
          TR.IRelaxedToken(14, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '  \'áéóúñü\': \'¡Hola!\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(12, 'string.quote.bicep'),
          TR.IRelaxedToken(13, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '  \'二头肌\': \'二头肌\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.quote.bicep'),
          TR.IRelaxedToken(3, 'string.bicep'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(9, 'string.quote.bicep'),
          TR.IRelaxedToken(10, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '}',
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
        'output concatUnicodeStrings string = concat(\'Θμ\', \'二头肌\', \'α\')',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.bicep'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'identifier.bicep'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(37, 'identifier.bicep'),
          TR.IRelaxedToken(43, ''),
          TR.IRelaxedToken(44, 'string.quote.bicep'),
          TR.IRelaxedToken(45, 'string.bicep'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(50, 'string.quote.bicep'),
          TR.IRelaxedToken(51, 'string.bicep'),
          TR.IRelaxedToken(55, ''),
          TR.IRelaxedToken(57, 'string.quote.bicep'),
          TR.IRelaxedToken(58, 'string.bicep'),
          TR.IRelaxedToken(60, ''),
        ],
      ),
      TR.ITestItem(
        'output interpolateUnicodeStrings string = \'Θμ二\${emojis}头肌\${ninjaCat}α\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.bicep'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'identifier.bicep'),
          TR.IRelaxedToken(39, ''),
          TR.IRelaxedToken(42, 'string.quote.bicep'),
          TR.IRelaxedToken(43, 'string.bicep'),
          TR.IRelaxedToken(46, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(48, 'identifier.bicep'),
          TR.IRelaxedToken(54, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(55, 'string.bicep'),
          TR.IRelaxedToken(57, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(59, 'identifier.bicep'),
          TR.IRelaxedToken(67, 'delimiter.bracket.bicep'),
          TR.IRelaxedToken(68, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '// all of these should produce the same string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        'var surrogate_char      = \'𐐷\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(26, 'string.quote.bicep'),
          TR.IRelaxedToken(27, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        'var surrogate_codepoint = \'\\u{10437}\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(26, 'string.quote.bicep'),
          TR.IRelaxedToken(27, 'string.escape.bicep'),
          TR.IRelaxedToken(36, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        'var surrogate_pairs     = \'\\u{D801}\\u{DC37}\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(26, 'string.quote.bicep'),
          TR.IRelaxedToken(27, 'string.escape.bicep'),
          TR.IRelaxedToken(43, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '// ascii escapes',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.bicep'),
        ],
      ),
      TR.ITestItem(
        'var hello = \'❆ Hello\\u{20}World\\u{21} ❁\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bicep'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.bicep'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(12, 'string.quote.bicep'),
          TR.IRelaxedToken(13, 'string.bicep'),
          TR.IRelaxedToken(20, 'string.escape.bicep'),
          TR.IRelaxedToken(26, 'string.bicep'),
          TR.IRelaxedToken(31, 'string.escape.bicep'),
          TR.IRelaxedToken(37, 'string.bicep'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
  ]);
}

