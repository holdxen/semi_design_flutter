// Generated 1:1 from languages/definitions/hcl/hcl.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('hcl')
void runLanguagesDefinitionsHclHclTestCases() {
  TR.testTokenization('hcl', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '// Foo',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        '/* Bar */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        '/*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        '/*',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        'Baz',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        '*/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        '# Another',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Multiple',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        '# Lines',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        'foo = "bar"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = [',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.square.hcl'),
        ],
      ),
      TR.ITestItem(
        '"1",',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.hcl'),
          TR.IRelaxedToken(3, 'delimiter.hcl'),
        ],
      ),
      TR.ITestItem(
        '"2", # comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.hcl'),
          TR.IRelaxedToken(3, 'delimiter.hcl'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'comment.hcl'),
        ],
      ),
      TR.ITestItem(
        ']',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource = [{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'operator.hcl'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.square.hcl'),
          TR.IRelaxedToken(12, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '"foo": {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.hcl'),
          TR.IRelaxedToken(5, 'operator.hcl'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '"bar": {},',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.hcl'),
          TR.IRelaxedToken(5, 'operator.hcl'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.curly.hcl'),
          TR.IRelaxedToken(9, 'delimiter.hcl'),
        ],
      ),
      TR.ITestItem(
        '"baz": [1, 2, "foo"],',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.hcl'),
          TR.IRelaxedToken(5, 'operator.hcl'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.square.hcl'),
          TR.IRelaxedToken(8, 'number.hcl'),
          TR.IRelaxedToken(9, 'delimiter.hcl'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.hcl'),
          TR.IRelaxedToken(12, 'delimiter.hcl'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'string.hcl'),
          TR.IRelaxedToken(19, 'delimiter.square.hcl'),
          TR.IRelaxedToken(20, 'delimiter.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '}]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
          TR.IRelaxedToken(1, 'delimiter.square.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'variable "foo" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  default = "bar"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'operator.hcl'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '  description = "bar"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'operator.hcl'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'provider "aws" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'provider "do" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  api_key = "\${var.foo}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'operator.hcl'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'string.hcl'),
          TR.IRelaxedToken(13, 'delimiter.hcl'),
          TR.IRelaxedToken(15, 'keyword.var.hcl'),
          TR.IRelaxedToken(18, 'delimiter.hcl'),
          TR.IRelaxedToken(19, 'variable.hcl'),
          TR.IRelaxedToken(22, 'delimiter.hcl'),
          TR.IRelaxedToken(23, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource "aws_security_group" "firewall" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'string.hcl'),
          TR.IRelaxedToken(40, ''),
          TR.IRelaxedToken(41, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  count = 5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'operator.hcl'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource aws_security_group firewall {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'string.hcl'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource "aws_security_group" firewall {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'string.hcl'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource aws_security_group "firewall" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'string.hcl'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource aws_instance "web" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'string.hcl'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  ami = "\${var.foo}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.hcl'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.hcl'),
          TR.IRelaxedToken(9, 'delimiter.hcl'),
          TR.IRelaxedToken(11, 'keyword.var.hcl'),
          TR.IRelaxedToken(14, 'delimiter.hcl'),
          TR.IRelaxedToken(15, 'variable.hcl'),
          TR.IRelaxedToken(18, 'delimiter.hcl'),
          TR.IRelaxedToken(19, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '  security_groups = [',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'operator.hcl'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'delimiter.square.hcl'),
        ],
      ),
      TR.ITestItem(
        '    "foo",',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.hcl'),
          TR.IRelaxedToken(9, 'delimiter.hcl'),
        ],
      ),
      TR.ITestItem(
        '    "\${aws_security_group.firewall.foo}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'string.hcl'),
          TR.IRelaxedToken(5, 'delimiter.hcl'),
          TR.IRelaxedToken(7, 'variable.hcl'),
          TR.IRelaxedToken(25, 'delimiter.hcl'),
          TR.IRelaxedToken(26, 'variable.hcl'),
          TR.IRelaxedToken(34, 'delimiter.hcl'),
          TR.IRelaxedToken(35, 'variable.hcl'),
          TR.IRelaxedToken(38, 'delimiter.hcl'),
          TR.IRelaxedToken(39, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '  ]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.square.hcl'),
        ],
      ),
      TR.ITestItem(
        '  network_interface {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.hcl'),
          TR.IRelaxedToken(20, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '    device_index = 0',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'variable.hcl'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'operator.hcl'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'number.hcl'),
        ],
      ),
      TR.ITestItem(
        '    description = "Main network interface"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'variable.hcl'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'operator.hcl'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '  }',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource "aws_instance" "db" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'string.hcl'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  security_groups = "\${aws_security_group.firewall.*.id}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'operator.hcl'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'string.hcl'),
          TR.IRelaxedToken(21, 'delimiter.hcl'),
          TR.IRelaxedToken(23, 'variable.hcl'),
          TR.IRelaxedToken(41, 'delimiter.hcl'),
          TR.IRelaxedToken(42, 'variable.hcl'),
          TR.IRelaxedToken(50, 'delimiter.hcl'),
          TR.IRelaxedToken(51, 'operator.hcl'),
          TR.IRelaxedToken(52, 'delimiter.hcl'),
          TR.IRelaxedToken(53, 'variable.hcl'),
          TR.IRelaxedToken(55, 'delimiter.hcl'),
          TR.IRelaxedToken(56, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '  VPC = "foo"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.hcl'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '  depends_on = ["aws_instance.web"]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'operator.hcl'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.square.hcl'),
          TR.IRelaxedToken(16, 'string.hcl'),
          TR.IRelaxedToken(34, 'delimiter.square.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'output "web_ip" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'string.hcl'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        'value = "\${aws_instance.web.private_ip}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.hcl'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.hcl'),
          TR.IRelaxedToken(9, 'delimiter.hcl'),
          TR.IRelaxedToken(11, 'variable.hcl'),
          TR.IRelaxedToken(23, 'delimiter.hcl'),
          TR.IRelaxedToken(24, 'variable.hcl'),
          TR.IRelaxedToken(27, 'delimiter.hcl'),
          TR.IRelaxedToken(28, 'variable.hcl'),
          TR.IRelaxedToken(38, 'delimiter.hcl'),
          TR.IRelaxedToken(39, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = [1, 2, "foo"]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.square.hcl'),
          TR.IRelaxedToken(7, 'number.hcl'),
          TR.IRelaxedToken(8, 'delimiter.hcl'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.hcl'),
          TR.IRelaxedToken(11, 'delimiter.hcl'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'string.hcl'),
          TR.IRelaxedToken(18, 'delimiter.square.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = [1, 2, "foo",]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.square.hcl'),
          TR.IRelaxedToken(7, 'number.hcl'),
          TR.IRelaxedToken(8, 'delimiter.hcl'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.hcl'),
          TR.IRelaxedToken(11, 'delimiter.hcl'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'string.hcl'),
          TR.IRelaxedToken(18, 'delimiter.hcl'),
          TR.IRelaxedToken(19, 'delimiter.square.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'default = {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'operator.hcl'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  "eu-west-1": "ami-b1cf19c6",',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'string.hcl'),
          TR.IRelaxedToken(13, 'operator.hcl'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'string.hcl'),
          TR.IRelaxedToken(29, 'delimiter.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource "foo" "bar" {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'string.hcl'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = "bar"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'bar = 7',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'baz = [1,2,3]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.square.hcl'),
          TR.IRelaxedToken(7, 'number.hcl'),
          TR.IRelaxedToken(8, 'delimiter.hcl'),
          TR.IRelaxedToken(9, 'number.hcl'),
          TR.IRelaxedToken(10, 'delimiter.hcl'),
          TR.IRelaxedToken(11, 'number.hcl'),
          TR.IRelaxedToken(12, 'delimiter.square.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = -12',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.hcl'),
          TR.IRelaxedToken(7, 'number.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'bar = 3.14159',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.float.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = true',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.true.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'bar = false',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'keyword.false.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'resource = [{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'operator.hcl'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.square.hcl'),
          TR.IRelaxedToken(12, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  foo = [{',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.hcl'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.square.hcl'),
          TR.IRelaxedToken(9, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '    bar = {}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'variable.hcl'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'operator.hcl'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  }]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'delimiter.curly.hcl'),
          TR.IRelaxedToken(3, 'delimiter.square.hcl'),
        ],
      ),
      TR.ITestItem(
        '}]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
          TR.IRelaxedToken(1, 'delimiter.square.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'bar = "\${file("bing/bong.txt")}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
          TR.IRelaxedToken(7, 'delimiter.hcl'),
          TR.IRelaxedToken(9, 'type.hcl'),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.hcl'),
          TR.IRelaxedToken(14, 'string.hcl'),
          TR.IRelaxedToken(29, 'delimiter.parenthesis.hcl'),
          TR.IRelaxedToken(30, 'delimiter.hcl'),
          TR.IRelaxedToken(31, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo-bar="baz"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(7, 'operator.hcl'),
          TR.IRelaxedToken(8, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'key "foo/" {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'string.hcl'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.curly.hcl'),
        ],
      ),
      TR.ITestItem(
        '  policy = "write"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'operator.hcl'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.curly.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = "bar\\"baz\\\\n"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
          TR.IRelaxedToken(10, 'string.escape.hcl'),
          TR.IRelaxedToken(12, 'string.hcl'),
          TR.IRelaxedToken(15, 'string.escape.hcl'),
          TR.IRelaxedToken(17, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'bar = "new\\nline"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
          TR.IRelaxedToken(10, 'string.escape.hcl'),
          TR.IRelaxedToken(12, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'qux = "back\\\\slash"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
          TR.IRelaxedToken(11, 'string.escape.hcl'),
          TR.IRelaxedToken(13, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'qax = "slash\\\\:colon"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
          TR.IRelaxedToken(12, 'string.escape.hcl'),
          TR.IRelaxedToken(14, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'nested = "\${HH\\\\:mm\\\\:ss}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'operator.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.hcl'),
          TR.IRelaxedToken(10, 'delimiter.hcl'),
          TR.IRelaxedToken(12, 'variable.hcl'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(16, 'operator.hcl'),
          TR.IRelaxedToken(17, 'variable.hcl'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(21, 'operator.hcl'),
          TR.IRelaxedToken(22, 'variable.hcl'),
          TR.IRelaxedToken(24, 'delimiter.hcl'),
          TR.IRelaxedToken(25, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'nestedquotes = "\${"\\"stringwrappedinquotes\\""}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'operator.hcl'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'string.hcl'),
          TR.IRelaxedToken(16, 'delimiter.hcl'),
          TR.IRelaxedToken(18, 'string.hcl'),
          TR.IRelaxedToken(19, 'string.escape.hcl'),
          TR.IRelaxedToken(21, 'string.hcl'),
          TR.IRelaxedToken(42, 'string.escape.hcl'),
          TR.IRelaxedToken(44, 'string.hcl'),
          TR.IRelaxedToken(45, 'delimiter.hcl'),
          TR.IRelaxedToken(46, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  foo = <<-EOF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'operator.hcl'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'string.heredoc.delimiter.hcl'),
        ],
      ),
      TR.ITestItem(
        '  bar',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.hcl'),
        ],
      ),
      TR.ITestItem(
        '  EOF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.hcl'),
          TR.IRelaxedToken(2, 'string.heredoc.delimiter.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = <<EOF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.heredoc.delimiter.hcl'),
        ],
      ),
      TR.ITestItem(
        'bar',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.hcl'),
        ],
      ),
      TR.ITestItem(
        'EOF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.heredoc.delimiter.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = <EOF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.angle.hcl'),
          TR.IRelaxedToken(7, 'variable.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo = <<-EOF',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.heredoc.delimiter.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'multiline_literal = "hello',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'operator.hcl'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        '  world"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        'foo = "bar"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'multiline_literal_with_hil = "\${hello',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'operator.hcl'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'string.hcl'),
          TR.IRelaxedToken(30, 'delimiter.hcl'),
          TR.IRelaxedToken(32, 'variable.hcl'),
        ],
      ),
      TR.ITestItem(
        ' world}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'variable.hcl'),
          TR.IRelaxedToken(6, 'delimiter.hcl'),
          TR.IRelaxedToken(7, 'string.hcl'),
        ],
      ),
      TR.ITestItem(
        'foo = "bar"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'operator.hcl'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'string.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a = 1e-10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.float.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'b = 1e+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.float.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'c = 1e10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.float.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'd = 1.2e-10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.float.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'e = 1.2e+10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.float.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'f = 1.2e10',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'operator.hcl'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.float.hcl'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'map.key1 = "Value"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.hcl'),
          TR.IRelaxedToken(3, 'delimiter.hcl'),
          TR.IRelaxedToken(4, 'variable.hcl'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'operator.hcl'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'string.hcl'),
        ],
      ),
    ],
  ]);
}

