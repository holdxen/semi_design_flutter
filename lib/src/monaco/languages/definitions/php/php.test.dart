// Generated 1:1 from languages/definitions/php/php.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('php')
void runLanguagesDefinitionsPhpPhpTestCases() {
  TR.testTokenization(<String>['php', 'css', 'javascript'], <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
        ],
      ),
      TR.ITestItem(
        '"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.php'),
        ],
      ),
      TR.ITestItem(
        '\\',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?=',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php /* comment */ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$abc = 5; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'number.php'),
          TR.IRelaxedToken(14, 'delimiter.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$a = "chris"; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.php'),
          TR.IRelaxedToken(18, 'delimiter.php'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$myVar = -10; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.php'),
          TR.IRelaxedToken(16, 'number.php'),
          TR.IRelaxedToken(18, 'delimiter.php'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$myVar = 5 + (10 * 2); ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'number.php'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.php'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(20, 'number.php'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.php'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'number.php'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(27, 'delimiter.php'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php function myFunc() { } ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.php'),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'delimiter.bracket.php'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'delimiter.bracket.php'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php function ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php if (\$start > 52) { \$start = 0; } ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(10, 'variable.php'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.php'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'number.php'),
          TR.IRelaxedToken(21, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.bracket.php'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'variable.php'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'delimiter.php'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'number.php'),
          TR.IRelaxedToken(35, 'delimiter.php'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'delimiter.bracket.php'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php if (true) { \$start = 0; } ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(10, 'keyword.php'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.bracket.php'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'variable.php'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'delimiter.php'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'number.php'),
          TR.IRelaxedToken(28, 'delimiter.php'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'delimiter.bracket.php'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php abstract ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php and ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php array ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php as ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php break ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php case ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php catch ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php cfunction ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php class ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php clone ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php const ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php continue ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php declare ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php default ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php do ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php else ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php elseif ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php enddeclare ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php endfor ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php endforeach ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php endif ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php endswitch ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php endwhile ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php extends ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php false ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php final ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php for ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php foreach ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php function ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php global ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php goto ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php if ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php implements ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php interface ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php instanceof ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php namespace ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php new ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php null ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php object ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php old_function ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php or ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php private ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php protected ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php public ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php resource ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php static ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php switch ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php throw ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php try ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php true ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php use ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php var ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php while ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php xor ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php die ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php echo ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php empty ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php exit ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php eval ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php include ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php include_once ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php isset ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php list ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php require ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php require_once ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php return ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php print ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php unset ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __construct ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __FILE__ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constant.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$myscript = __FILE__; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.php'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'constant.php'),
          TR.IRelaxedToken(26, 'delimiter.php'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __CLASS__ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constant.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __DIR__ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constant.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __LINE__ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constant.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __NAMESPACE__ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constant.php'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __METHOD__ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constant.php'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __FUNCTION__ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constant.php'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php __TRAIT__ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'constant.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_ENV ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php echo \$_ENV; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'variable.predefined.php'),
          TR.IRelaxedToken(16, 'delimiter.php'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$GLOBALS ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_SERVER ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_GET ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_POST ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_FILES ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_REQUEST ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_SESSION ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_ENV ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$_COOKIE ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$php_errormsg ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$HTTP_RAW_POST_DATA ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$http_response_header ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$argc ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$argv ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.predefined.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php // a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php / / / not a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.php'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.php'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'identifier.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(9, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php //sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php /almost a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.php'),
          TR.IRelaxedToken(7, 'identifier.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$x = 1; // my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.php'),
          TR.IRelaxedToken(12, 'delimiter.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php /* a simple comment */ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$x = /* a simple comment */ 1; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.php'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'number.php'),
          TR.IRelaxedToken(35, 'delimiter.php'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$x = /* comment */ 1; */ ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.php'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'number.php'),
          TR.IRelaxedToken(26, 'delimiter.php'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.php'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$x = /**/; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.php'),
          TR.IRelaxedToken(15, 'delimiter.php'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$x = /*/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php /* a multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
        ],
      ),
      TR.ITestItem(
        'can actually span',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.php'),
        ],
      ),
      TR.ITestItem(
        'multiple lines */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$x = /* start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.php'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.php'),
        ],
      ),
      TR.ITestItem(
        'and end it */ var a = 2;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.php'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'identifier.php'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'delimiter.php'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'number.php'),
          TR.IRelaxedToken(23, 'delimiter.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$a = \'a\'; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.php'),
          TR.IRelaxedToken(14, 'delimiter.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \'use_strict\'; ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.php'),
          TR.IRelaxedToken(18, 'delimiter.php'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$b = \$a + " \'cool\'  " ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'variable.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.php'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'string.php'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \'\'\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php "multiline',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.php'),
        ],
      ),
      TR.ITestItem(
        'strings";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.php'),
          TR.IRelaxedToken(8, 'delimiter.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 0 ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.php'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 0+0 ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.php'),
          TR.IRelaxedToken(7, 'delimiter.php'),
          TR.IRelaxedToken(8, 'number.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 100+10 ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.php'),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, 'number.php'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 0 + 0 ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.php'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 0123 ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.octal.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 01239 ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.octal.php'),
          TR.IRelaxedToken(10, 'number.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 0x ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.php'),
          TR.IRelaxedToken(7, 'identifier.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 0x123 ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.hex.php'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php 0b1 ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.binary.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php { } ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.bracket.php'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.bracket.php'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php [1,2,3] ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.array.php'),
          TR.IRelaxedToken(7, 'number.php'),
          TR.IRelaxedToken(8, 'delimiter.php'),
          TR.IRelaxedToken(9, 'number.php'),
          TR.IRelaxedToken(10, 'delimiter.php'),
          TR.IRelaxedToken(11, 'number.php'),
          TR.IRelaxedToken(12, 'delimiter.array.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php foo(123);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.php'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(10, 'number.php'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(14, 'delimiter.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$x = "[{()}]" ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.php'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php # a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php ## a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php    # a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(9, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php #sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php \$x = 1; # my comment // is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'variable.php'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.php'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.php'),
          TR.IRelaxedToken(12, 'delimiter.php'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'comment.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php # comment?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
          TR.IRelaxedToken(15, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php # comment? ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.php'),
          TR.IRelaxedToken(17, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?=\'hi\'?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(3, 'string.php'),
          TR.IRelaxedToken(7, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php5+3?><br/><?=1?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, 'number.php'),
          TR.IRelaxedToken(6, 'delimiter.php'),
          TR.IRelaxedToken(7, 'number.php'),
          TR.IRelaxedToken(8, 'metatag.php'),
          TR.IRelaxedToken(10, 'delimiter.html'),
          TR.IRelaxedToken(11, 'tag.html'),
          TR.IRelaxedToken(13, 'delimiter.html'),
          TR.IRelaxedToken(15, 'metatag.php'),
          TR.IRelaxedToken(18, 'number.php'),
          TR.IRelaxedToken(19, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php5+3?><abc><?=1?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, 'number.php'),
          TR.IRelaxedToken(6, 'delimiter.php'),
          TR.IRelaxedToken(7, 'number.php'),
          TR.IRelaxedToken(8, 'metatag.php'),
          TR.IRelaxedToken(10, 'delimiter.html'),
          TR.IRelaxedToken(11, 'tag.html'),
          TR.IRelaxedToken(14, 'delimiter.html'),
          TR.IRelaxedToken(15, 'metatag.php'),
          TR.IRelaxedToken(18, 'number.php'),
          TR.IRelaxedToken(19, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc><?php5+3?><abc>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, 'delimiter.html'),
          TR.IRelaxedToken(5, 'metatag.php'),
          TR.IRelaxedToken(10, 'number.php'),
          TR.IRelaxedToken(11, 'delimiter.php'),
          TR.IRelaxedToken(12, 'number.php'),
          TR.IRelaxedToken(13, 'metatag.php'),
          TR.IRelaxedToken(15, 'delimiter.html'),
          TR.IRelaxedToken(16, 'tag.html'),
          TR.IRelaxedToken(19, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc><script>var i= 10;</script><?php5+3?><abc>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, 'delimiter.html'),
          TR.IRelaxedToken(6, 'tag.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'keyword.js'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'identifier.js'),
          TR.IRelaxedToken(18, 'delimiter.js'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'number.js'),
          TR.IRelaxedToken(22, 'delimiter.js'),
          TR.IRelaxedToken(23, 'delimiter.html'),
          TR.IRelaxedToken(25, 'tag.html'),
          TR.IRelaxedToken(31, 'delimiter.html'),
          TR.IRelaxedToken(32, 'metatag.php'),
          TR.IRelaxedToken(37, 'number.php'),
          TR.IRelaxedToken(38, 'delimiter.php'),
          TR.IRelaxedToken(39, 'number.php'),
          TR.IRelaxedToken(40, 'metatag.php'),
          TR.IRelaxedToken(42, 'delimiter.html'),
          TR.IRelaxedToken(43, 'tag.html'),
          TR.IRelaxedToken(46, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<abc><script>var i= 10;</script><?php5+3?><script>var x= 15;</script>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(4, 'delimiter.html'),
          TR.IRelaxedToken(6, 'tag.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'keyword.js'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'identifier.js'),
          TR.IRelaxedToken(18, 'delimiter.js'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'number.js'),
          TR.IRelaxedToken(22, 'delimiter.js'),
          TR.IRelaxedToken(23, 'delimiter.html'),
          TR.IRelaxedToken(25, 'tag.html'),
          TR.IRelaxedToken(31, 'delimiter.html'),
          TR.IRelaxedToken(32, 'metatag.php'),
          TR.IRelaxedToken(37, 'number.php'),
          TR.IRelaxedToken(38, 'delimiter.php'),
          TR.IRelaxedToken(39, 'number.php'),
          TR.IRelaxedToken(40, 'metatag.php'),
          TR.IRelaxedToken(42, 'delimiter.html'),
          TR.IRelaxedToken(43, 'tag.html'),
          TR.IRelaxedToken(49, 'delimiter.html'),
          TR.IRelaxedToken(50, 'keyword.js'),
          TR.IRelaxedToken(53, ''),
          TR.IRelaxedToken(54, 'identifier.js'),
          TR.IRelaxedToken(55, 'delimiter.js'),
          TR.IRelaxedToken(56, ''),
          TR.IRelaxedToken(57, 'number.js'),
          TR.IRelaxedToken(59, 'delimiter.js'),
          TR.IRelaxedToken(60, 'delimiter.html'),
          TR.IRelaxedToken(62, 'tag.html'),
          TR.IRelaxedToken(68, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<html>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(5, 'delimiter.html'),
        ],
      ),
      TR.ITestItem(
        '<style><?="div"?>{ color:blue; }</style>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(6, 'delimiter.html'),
          TR.IRelaxedToken(7, 'metatag.php'),
          TR.IRelaxedToken(10, 'string.php'),
          TR.IRelaxedToken(15, 'metatag.php'),
          TR.IRelaxedToken(17, 'delimiter.bracket.css'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'attribute.name.css'),
          TR.IRelaxedToken(25, 'attribute.value.css'),
          TR.IRelaxedToken(29, 'delimiter.css'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'delimiter.bracket.css'),
          TR.IRelaxedToken(32, 'delimiter.html'),
          TR.IRelaxedToken(34, 'tag.html'),
          TR.IRelaxedToken(39, 'delimiter.html'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<html><style><?="div"?> { color:blue; }</style><!--<?="HTML Comment"?>--><script>var x = 3;/* <?="JS Comment"/*</script>*/?> */var y = 4;</script></html><? \$x = 3;?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(5, 'delimiter.html'),
          TR.IRelaxedToken(7, 'tag.html'),
          TR.IRelaxedToken(12, 'delimiter.html'),
          TR.IRelaxedToken(13, 'metatag.php'),
          TR.IRelaxedToken(16, 'string.php'),
          TR.IRelaxedToken(21, 'metatag.php'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'delimiter.bracket.css'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'attribute.name.css'),
          TR.IRelaxedToken(32, 'attribute.value.css'),
          TR.IRelaxedToken(36, 'delimiter.css'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'delimiter.bracket.css'),
          TR.IRelaxedToken(39, 'delimiter.html'),
          TR.IRelaxedToken(41, 'tag.html'),
          TR.IRelaxedToken(46, 'delimiter.html'),
          TR.IRelaxedToken(47, 'comment.html'),
          TR.IRelaxedToken(51, 'metatag.php'),
          TR.IRelaxedToken(54, 'string.php'),
          TR.IRelaxedToken(68, 'metatag.php'),
          TR.IRelaxedToken(70, 'comment.html'),
          TR.IRelaxedToken(73, 'delimiter.html'),
          TR.IRelaxedToken(74, 'tag.html'),
          TR.IRelaxedToken(80, 'delimiter.html'),
          TR.IRelaxedToken(81, 'keyword.js'),
          TR.IRelaxedToken(84, ''),
          TR.IRelaxedToken(85, 'identifier.js'),
          TR.IRelaxedToken(86, ''),
          TR.IRelaxedToken(87, 'delimiter.js'),
          TR.IRelaxedToken(88, ''),
          TR.IRelaxedToken(89, 'number.js'),
          TR.IRelaxedToken(90, 'delimiter.js'),
          TR.IRelaxedToken(91, 'comment.js'),
          TR.IRelaxedToken(94, 'metatag.php'),
          TR.IRelaxedToken(97, 'string.php'),
          TR.IRelaxedToken(109, 'comment.php'),
          TR.IRelaxedToken(122, 'metatag.php'),
          TR.IRelaxedToken(124, ''),
          TR.IRelaxedToken(127, 'keyword.js'),
          TR.IRelaxedToken(130, ''),
          TR.IRelaxedToken(131, 'identifier.js'),
          TR.IRelaxedToken(132, ''),
          TR.IRelaxedToken(133, 'delimiter.js'),
          TR.IRelaxedToken(134, ''),
          TR.IRelaxedToken(135, 'number.js'),
          TR.IRelaxedToken(136, 'delimiter.js'),
          TR.IRelaxedToken(137, 'delimiter.html'),
          TR.IRelaxedToken(139, 'tag.html'),
          TR.IRelaxedToken(145, 'delimiter.html'),
          TR.IRelaxedToken(148, 'tag.html'),
          TR.IRelaxedToken(152, 'delimiter.html'),
          TR.IRelaxedToken(153, 'metatag.php'),
          TR.IRelaxedToken(155, ''),
          TR.IRelaxedToken(156, 'variable.php'),
          TR.IRelaxedToken(158, ''),
          TR.IRelaxedToken(159, 'delimiter.php'),
          TR.IRelaxedToken(160, ''),
          TR.IRelaxedToken(161, 'number.php'),
          TR.IRelaxedToken(162, 'delimiter.php'),
          TR.IRelaxedToken(163, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<!--c--><?',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.html'),
          TR.IRelaxedToken(4, 'comment.content.html'),
          TR.IRelaxedToken(5, 'comment.html'),
          TR.IRelaxedToken(8, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script>//<?',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, 'delimiter.html'),
          TR.IRelaxedToken(8, 'comment.js'),
          TR.IRelaxedToken(10, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<script>"<?php5+3?>"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.html'),
          TR.IRelaxedToken(1, 'tag.html'),
          TR.IRelaxedToken(7, 'delimiter.html'),
          TR.IRelaxedToken(8, 'string.invalid.js'),
          TR.IRelaxedToken(9, 'metatag.php'),
          TR.IRelaxedToken(14, 'number.php'),
          TR.IRelaxedToken(15, 'delimiter.php'),
          TR.IRelaxedToken(16, 'number.php'),
          TR.IRelaxedToken(17, 'metatag.php'),
          TR.IRelaxedToken(19, 'string.invalid.js'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php toString(); ?>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.php'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.php'),
          TR.IRelaxedToken(16, 'delimiter.php'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'metatag.php'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<?php',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.php'),
        ],
      ),
      TR.ITestItem(
        '  //',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'comment.php'),
        ],
      ),
      TR.ITestItem(
        'if',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.php'),
        ],
      ),
    ],
  ]);
}

