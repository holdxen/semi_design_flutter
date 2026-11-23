// Generated 1:1 from languages/definitions/powershell/powershell.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('powershell')
void runLanguagesDefinitionsPowershellPowershellTestCases() {
  TR.testTokenization('powershell', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    # a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '# a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '#sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '##still a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2 /# comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ps1'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.ps1'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.ps1'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ps1'),
          TR.IRelaxedToken(7, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x = 1 # my comment # is a nice one',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.ps1'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<# a simple comment #>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x = <# a simple comment #> 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'comment.ps1'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'number.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$yy = <# comment #> 14',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.ps1'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.ps1'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'number.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x = <##>7',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'comment.ps1'),
          TR.IRelaxedToken(9, 'number.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x = <#<85',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<# start of multiline comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        'a comment between',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        'end of multiline comment#>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$x = <# start a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        ' a ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        'and end it #> 2',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foreach(\$i in \$b) {if (7) continue}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.foreach.ps1'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(8, 'variable.ps1'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'keyword.in.ps1'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'variable.ps1'),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.curly.ps1'),
          TR.IRelaxedToken(19, 'keyword.if.ps1'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(23, 'number.ps1'),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'keyword.continue.ps1'),
          TR.IRelaxedToken(34, 'delimiter.curly.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$i > output1.txt',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(12, 'delimiter.ps1'),
          TR.IRelaxedToken(13, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0.10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0X123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0x123',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5e-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5E-3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '23.5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0+0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ps1'),
          TR.IRelaxedToken(1, 'delimiter.ps1'),
          TR.IRelaxedToken(2, 'number.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '100+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ps1'),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, 'number.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10 + 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$s = "I am a String"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'I am also a ( String\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$s = "concatenated" + " String"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'string.ps1'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'delimiter.ps1'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"escaping `"quotes`" is cool"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
          TR.IRelaxedToken(10, 'string.escape.ps1'),
          TR.IRelaxedToken(12, 'string.ps1'),
          TR.IRelaxedToken(18, 'string.escape.ps1'),
          TR.IRelaxedToken(20, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\'`\'end of the string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
          TR.IRelaxedToken(1, 'string.escape.ps1'),
          TR.IRelaxedToken(3, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@"I am an expandable String"@',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@\'I am also an expandable String\'@',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$s = @\'I am also an expandable String\'@',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$s = @\'I am also an expandable String\'@+7',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'delimiter.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'string.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@\'I am a multiline string,',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        'and this is the middle line,',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        'and this is NOT the end of the string\'@foreach \$i',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '\'@',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '\${script:foo}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
        ],
      ),
      TR.ITestItem(
        'foreach \$i',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.foreach.ps1'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'variable.ps1'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\$SelectedObjectNames=@();',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(20, 'delimiter.ps1'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(24, 'delimiter.ps1'),
        ],
      ),
      TR.ITestItem(
        '\$XenCenterNodeSelected = 0;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.ps1'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'number.ps1'),
          TR.IRelaxedToken(26, 'delimiter.ps1'),
        ],
      ),
      TR.ITestItem(
        '#the object info array contains hashmaps, each of which represent a parameter set and describe a target in the XenCenter resource list',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        'foreach(\$parameterSet in \$ObjInfoArray)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.foreach.ps1'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(8, 'variable.ps1'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'keyword.in.ps1'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'variable.ps1'),
          TR.IRelaxedToken(38, 'delimiter.parenthesis.ps1'),
        ],
      ),
      TR.ITestItem(
        '{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '\tif (\$parameterSet["class"] -eq "blank")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.if.ps1'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(5, 'variable.ps1'),
          TR.IRelaxedToken(18, 'delimiter.square.ps1'),
          TR.IRelaxedToken(19, 'string.ps1'),
          TR.IRelaxedToken(26, 'delimiter.square.ps1'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.ps1'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(32, 'string.ps1'),
          TR.IRelaxedToken(39, 'delimiter.parenthesis.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t#When the XenCenter node is selected a parameter set is created for each of your connected servers with the class and objUuid keys marked as blank',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\tif (\$XenCenterNodeSelected)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.if.ps1'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(6, 'variable.ps1'),
          TR.IRelaxedToken(28, 'delimiter.parenthesis.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t\tcontinue',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(3, 'keyword.continue.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t\$XenCenterNodeSelected = 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.ps1'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'delimiter.ps1'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'number.ps1'),
          TR.IRelaxedToken(28, 'delimiter.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t\$SelectedObjectNames += "XenCenter"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.ps1'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.ps1'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '\telseif (\$parameterSet["sessionRef"] -eq "null")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.elseif.ps1'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.ps1'),
          TR.IRelaxedToken(9, 'variable.ps1'),
          TR.IRelaxedToken(22, 'delimiter.square.ps1'),
          TR.IRelaxedToken(23, 'string.ps1'),
          TR.IRelaxedToken(35, 'delimiter.square.ps1'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'delimiter.ps1'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(41, 'string.ps1'),
          TR.IRelaxedToken(47, 'delimiter.parenthesis.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t#When a disconnected server is selected there is no session information, we get null for everything except class',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t\$SelectedObjectNames += "a disconnected server"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.ps1'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.ps1'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '\telse',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.else.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\tConnect-XenServer -url \$parameterSet["url"] -opaqueref \$parameterSet["sessionRef"]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(20, 'delimiter.ps1'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(25, 'variable.ps1'),
          TR.IRelaxedToken(38, 'delimiter.square.ps1'),
          TR.IRelaxedToken(39, 'string.ps1'),
          TR.IRelaxedToken(44, 'delimiter.square.ps1'),
          TR.IRelaxedToken(45, ''),
          TR.IRelaxedToken(46, 'delimiter.ps1'),
          TR.IRelaxedToken(47, ''),
          TR.IRelaxedToken(57, 'variable.ps1'),
          TR.IRelaxedToken(70, 'delimiter.square.ps1'),
          TR.IRelaxedToken(71, 'string.ps1'),
          TR.IRelaxedToken(83, 'delimiter.square.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t#Use \$class to determine which server objects to get',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t#-properties allows us to filter the results to just include the selected object',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t\$exp = "Get-XenServer:{0} -properties @{{uuid=\'{1}\'}}" -f \$parameterSet["class"], \$parameterSet["objUuid"]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.ps1'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.ps1'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.ps1'),
          TR.IRelaxedToken(56, ''),
          TR.IRelaxedToken(57, 'delimiter.ps1'),
          TR.IRelaxedToken(58, ''),
          TR.IRelaxedToken(60, 'variable.ps1'),
          TR.IRelaxedToken(73, 'delimiter.square.ps1'),
          TR.IRelaxedToken(74, 'string.ps1'),
          TR.IRelaxedToken(81, 'delimiter.square.ps1'),
          TR.IRelaxedToken(82, 'delimiter.ps1'),
          TR.IRelaxedToken(83, ''),
          TR.IRelaxedToken(84, 'variable.ps1'),
          TR.IRelaxedToken(97, 'delimiter.square.ps1'),
          TR.IRelaxedToken(98, 'string.ps1'),
          TR.IRelaxedToken(107, 'delimiter.square.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t\$obj = Invoke-Expression \$exp',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.ps1'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.ps1'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(27, 'variable.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t\t\$SelectedObjectNames += \$obj.name_label;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.ps1'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.ps1'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'variable.ps1'),
          TR.IRelaxedToken(30, 'delimiter.ps1'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(41, 'delimiter.ps1'),
        ],
      ),
      TR.ITestItem(
        '\t} ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'delimiter.curly.ps1'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.ps1'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '\$test = "in string var\$test"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.ps1'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.ps1'),
          TR.IRelaxedToken(22, 'variable.ps1'),
          TR.IRelaxedToken(27, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '\$another = \'not a \$var\'',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.ps1'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '\$third = "a \$var and not `\$var string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.ps1'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.ps1'),
          TR.IRelaxedToken(12, 'variable.ps1'),
          TR.IRelaxedToken(16, 'string.ps1'),
          TR.IRelaxedToken(25, 'string.escape.ps1'),
          TR.IRelaxedToken(27, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        ':aLabel',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'metatag.ps1'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '<#',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '.SYNOPSIS',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.keyword.synopsis.ps1'),
        ],
      ),
      TR.ITestItem(
        '  some text',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '  ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '.LINK',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.keyword.link.ps1'),
        ],
      ),
      TR.ITestItem(
        '  some more text',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '#>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.ps1'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '\$hereString = @"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.ps1'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.ps1'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '  a string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '  still "@ a string \$withVar',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
          TR.IRelaxedToken(20, 'variable.ps1'),
        ],
      ),
      TR.ITestItem(
        '  still a string `\$noVar',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
          TR.IRelaxedToken(17, 'string.escape.ps1'),
          TR.IRelaxedToken(19, 'string.ps1'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '"@ still a string',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.ps1'),
          TR.IRelaxedToken(2, ''),
        ],
      ),
    ],
  ]);
}

