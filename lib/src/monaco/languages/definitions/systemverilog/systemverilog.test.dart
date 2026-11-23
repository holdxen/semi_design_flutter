// Generated 1:1 from languages/definitions/systemverilog/systemverilog.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('systemverilog')
void runLanguagesDefinitionsSystemverilogSystemverilogTestCases() {
  TR.testTokenization('systemverilog', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'module mux2to1 (input wire a, b, sel, output logic y);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.module.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.sv'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(16, 'keyword.input.sv'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'keyword.wire.sv'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'identifier.sv'),
          TR.IRelaxedToken(28, 'delimiter.sv'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'identifier.sv'),
          TR.IRelaxedToken(31, 'delimiter.sv'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'identifier.sv'),
          TR.IRelaxedToken(36, 'delimiter.sv'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'keyword.output.sv'),
          TR.IRelaxedToken(44, ''),
          TR.IRelaxedToken(45, 'keyword.logic.sv'),
          TR.IRelaxedToken(50, ''),
          TR.IRelaxedToken(51, 'identifier.sv'),
          TR.IRelaxedToken(52, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(53, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a !== b',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '!n',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.sv'),
          TR.IRelaxedToken(1, 'identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'assign r = c + i;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.assign.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.sv'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'identifier.sv'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'delimiter.sv'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.sv'),
          TR.IRelaxedToken(16, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'assert(req1 || req2)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.assert.sv'),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(7, 'identifier.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.sv'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.sv'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'assign enable = set & interrupt;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.assign.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.sv'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.sv'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.sv'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'delimiter.sv'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'identifier.sv'),
          TR.IRelaxedToken(31, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'arrayB[i][j+:2] == arrayA[k][m-:2]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(6, 'delimiter.square.sv'),
          TR.IRelaxedToken(7, 'identifier.sv'),
          TR.IRelaxedToken(8, 'delimiter.square.sv'),
          TR.IRelaxedToken(10, 'identifier.sv'),
          TR.IRelaxedToken(11, 'delimiter.sv'),
          TR.IRelaxedToken(13, 'number.sv'),
          TR.IRelaxedToken(14, 'delimiter.square.sv'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.sv'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'identifier.sv'),
          TR.IRelaxedToken(25, 'delimiter.square.sv'),
          TR.IRelaxedToken(26, 'identifier.sv'),
          TR.IRelaxedToken(27, 'delimiter.square.sv'),
          TR.IRelaxedToken(29, 'identifier.sv'),
          TR.IRelaxedToken(30, 'delimiter.sv'),
          TR.IRelaxedToken(32, 'number.sv'),
          TR.IRelaxedToken(33, 'delimiter.square.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'assert property (@(clk) go ##1 get[*2] |-> !stop throughout put[->2]);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.assert.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'keyword.property.sv'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(19, 'identifier.sv'),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'identifier.sv'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(29, 'number.sv'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'identifier.sv'),
          TR.IRelaxedToken(34, 'delimiter.square.sv'),
          TR.IRelaxedToken(35, 'delimiter.sv'),
          TR.IRelaxedToken(36, 'number.sv'),
          TR.IRelaxedToken(37, 'delimiter.square.sv'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'delimiter.sv'),
          TR.IRelaxedToken(42, ''),
          TR.IRelaxedToken(43, 'delimiter.sv'),
          TR.IRelaxedToken(44, 'identifier.sv'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(49, 'keyword.throughout.sv'),
          TR.IRelaxedToken(59, ''),
          TR.IRelaxedToken(60, 'identifier.sv'),
          TR.IRelaxedToken(63, 'delimiter.square.sv'),
          TR.IRelaxedToken(64, 'delimiter.sv'),
          TR.IRelaxedToken(66, 'number.sv'),
          TR.IRelaxedToken(67, 'delimiter.square.sv'),
          TR.IRelaxedToken(68, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(69, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'always_ff @(posedge clk) gnt <= req & avail;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.always-ff.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(11, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(12, 'keyword.posedge.sv'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'identifier.sv'),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'identifier.sv'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'delimiter.sv'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'identifier.sv'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(36, 'delimiter.sv'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'identifier.sv'),
          TR.IRelaxedToken(43, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'parameter type t_3 = int;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.parameter.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'keyword.type.sv'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.sv'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.sv'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'keyword.int.sv'),
          TR.IRelaxedToken(24, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'typedef union packed {',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.typedef.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.union.sv'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'keyword.packed.sv'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'delimiter.curly.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a = 8\'hFF;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.hex.sv'),
          TR.IRelaxedToken(9, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a = 2\'b01;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.binary.sv'),
          TR.IRelaxedToken(9, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a = 6\'o654;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.octal.sv'),
          TR.IRelaxedToken(10, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'a = 8\'d98;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.sv'),
          TR.IRelaxedToken(9, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '10\'bxxxx_zxxxx',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.binary.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1\'H?z',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.hex.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '64E435456',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '64.4e3445',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.float.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'if( my_var[3:0] == 4\'b0101)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.if.sv'),
          TR.IRelaxedToken(2, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sv'),
          TR.IRelaxedToken(10, 'delimiter.square.sv'),
          TR.IRelaxedToken(11, 'number.sv'),
          TR.IRelaxedToken(12, 'delimiter.sv'),
          TR.IRelaxedToken(13, 'number.sv'),
          TR.IRelaxedToken(14, 'delimiter.square.sv'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.sv'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'number.binary.sv'),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'typedef enum int {FAST_SIM = 0, RANDOM = 1, NOMINAL = 2, START_UP = 3} clock_plan_e;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.typedef.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'keyword.enum.sv'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'keyword.int.sv'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.curly.sv'),
          TR.IRelaxedToken(18, 'identifier.sv'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'delimiter.sv'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'number.sv'),
          TR.IRelaxedToken(30, 'delimiter.sv'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'identifier.sv'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'delimiter.sv'),
          TR.IRelaxedToken(40, ''),
          TR.IRelaxedToken(41, 'number.sv'),
          TR.IRelaxedToken(42, 'delimiter.sv'),
          TR.IRelaxedToken(43, ''),
          TR.IRelaxedToken(44, 'identifier.sv'),
          TR.IRelaxedToken(51, ''),
          TR.IRelaxedToken(52, 'delimiter.sv'),
          TR.IRelaxedToken(53, ''),
          TR.IRelaxedToken(54, 'number.sv'),
          TR.IRelaxedToken(55, 'delimiter.sv'),
          TR.IRelaxedToken(56, ''),
          TR.IRelaxedToken(57, 'identifier.sv'),
          TR.IRelaxedToken(65, ''),
          TR.IRelaxedToken(66, 'delimiter.sv'),
          TR.IRelaxedToken(67, ''),
          TR.IRelaxedToken(68, 'number.sv'),
          TR.IRelaxedToken(69, 'delimiter.curly.sv'),
          TR.IRelaxedToken(70, ''),
          TR.IRelaxedToken(71, 'identifier.sv'),
          TR.IRelaxedToken(83, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'if( my_var[31:0] === 32\'h2aB0_113C )',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.if.sv'),
          TR.IRelaxedToken(2, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sv'),
          TR.IRelaxedToken(10, 'delimiter.square.sv'),
          TR.IRelaxedToken(11, 'number.sv'),
          TR.IRelaxedToken(13, 'delimiter.sv'),
          TR.IRelaxedToken(14, 'number.sv'),
          TR.IRelaxedToken(15, 'delimiter.square.sv'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'delimiter.sv'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'number.hex.sv'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'delimiter.parenthesis.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`include"tb_test.sv"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.sv'),
          TR.IRelaxedToken(8, 'string.include.identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`include "path/to/my/file.sv"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.include.identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`include                      "file.sv"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(30, 'string.include.identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   `include "file.sv"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'string.include.identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '   `include     "file.sv"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(16, 'string.include.identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`include<tb_test.sv>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.sv'),
          TR.IRelaxedToken(8, 'string.include.identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`include <path/to/my/file.sv>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.directive.include.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'string.include.identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`__FILE__',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '      `begin_keywords',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`define wordsize 8',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.sv'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'number.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    `define variable',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`      else',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`timescale 1ns/1ps',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.sv'),
          TR.IRelaxedToken(14, 'delimiter.sv'),
          TR.IRelaxedToken(15, 'number.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`timescale 1 ns / 1 ps',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.sv'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.sv'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'number.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`MACRO (1, 2, 3)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(8, 'number.sv'),
          TR.IRelaxedToken(9, 'delimiter.sv'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'number.sv'),
          TR.IRelaxedToken(12, 'delimiter.sv'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'number.sv'),
          TR.IRelaxedToken(15, 'delimiter.parenthesis.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`ifdef wow',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`ifndef AGENT',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`endif // AGENT',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`pragma protect encoding=(enctype="raw")',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.sv'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.sv'),
          TR.IRelaxedToken(24, 'delimiter.sv'),
          TR.IRelaxedToken(25, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(26, 'identifier.sv'),
          TR.IRelaxedToken(33, 'delimiter.sv'),
          TR.IRelaxedToken(34, 'string.sv'),
          TR.IRelaxedToken(39, 'delimiter.parenthesis.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`undef macro_name',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`celldefine    ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(11, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '`default_nettype none',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.sv'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'pdisplay ("display msg");',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(10, 'string.sv'),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(24, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"multi\\n line\\n string"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sv'),
          TR.IRelaxedToken(6, 'string.escape.sv'),
          TR.IRelaxedToken(8, 'string.sv'),
          TR.IRelaxedToken(13, 'string.escape.sv'),
          TR.IRelaxedToken(15, 'string.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'pdisplay ("%s : %d\\n", c.name, c );',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(10, 'string.sv'),
          TR.IRelaxedToken(18, 'string.escape.sv'),
          TR.IRelaxedToken(20, 'string.sv'),
          TR.IRelaxedToken(21, 'delimiter.sv'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'identifier.sv'),
          TR.IRelaxedToken(29, 'delimiter.sv'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'identifier.sv'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(34, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"Valid escapes \\b \\f \\v"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sv'),
          TR.IRelaxedToken(15, 'string.escape.invalid.sv'),
          TR.IRelaxedToken(17, 'string.sv'),
          TR.IRelaxedToken(18, 'string.escape.sv'),
          TR.IRelaxedToken(20, 'string.sv'),
          TR.IRelaxedToken(21, 'string.escape.sv'),
          TR.IRelaxedToken(23, 'string.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"Valid escapes \\o \\j \\z"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.sv'),
          TR.IRelaxedToken(15, 'string.escape.invalid.sv'),
          TR.IRelaxedToken(17, 'string.sv'),
          TR.IRelaxedToken(18, 'string.escape.invalid.sv'),
          TR.IRelaxedToken(20, 'string.sv'),
          TR.IRelaxedToken(21, 'string.escape.invalid.sv'),
          TR.IRelaxedToken(23, 'string.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'bit [8*12:1] stringvar = "Hello world\\n";',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.bit.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'delimiter.square.sv'),
          TR.IRelaxedToken(5, 'number.sv'),
          TR.IRelaxedToken(6, 'delimiter.sv'),
          TR.IRelaxedToken(7, 'number.sv'),
          TR.IRelaxedToken(9, 'delimiter.sv'),
          TR.IRelaxedToken(10, 'number.sv'),
          TR.IRelaxedToken(11, 'delimiter.square.sv'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.sv'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'delimiter.sv'),
          TR.IRelaxedToken(24, ''),
          TR.IRelaxedToken(25, 'string.sv'),
          TR.IRelaxedToken(37, 'string.escape.sv'),
          TR.IRelaxedToken(39, 'string.sv'),
          TR.IRelaxedToken(40, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    // a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '// a comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//sticky comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* //*/ a',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 / 2; /* comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.sv'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.sv'),
          TR.IRelaxedToken(5, 'delimiter.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = 1; // COMMENT // COMMENT COMMENT',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.sv'),
          TR.IRelaxedToken(9, 'delimiter.sv'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a simple comment */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'int x = /* a simple comment */ 1;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.int.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'comment.sv'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.sv'),
          TR.IRelaxedToken(32, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'logic x = /* comment */ 1; */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.logic.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'identifier.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'comment.sv'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'number.sv'),
          TR.IRelaxedToken(25, 'delimiter.sv'),
          TR.IRelaxedToken(26, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'x = /**/;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'delimiter.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'comment.sv'),
          TR.IRelaxedToken(8, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//! @param',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '//!< @param',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* temp_byte = data[0:7]; \\n m_buffer.push_back(temp_byte) */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '/* a = b; \\n b = c; \\n c = d */',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'wire a = 12\'hx123456;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wire.sv'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'delimiter.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'number.hex.sv'),
          TR.IRelaxedToken(20, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  wire ab = \'h e17fF;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.wire.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'number.hex.sv'),
          TR.IRelaxedToken(20, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'wire sn = 5 \'D 3;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wire.sv'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.sv'),
          TR.IRelaxedToken(16, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'wire dc = 5 \'she;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.wire.sv'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.hex.sv'),
          TR.IRelaxedToken(16, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  assign value = 256.12_7563_e-22;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.assign.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.sv'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.sv'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'number.float.sv'),
          TR.IRelaxedToken(33, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'input #1step my_wire=\'1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.input.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(7, 'number.sv'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.sv'),
          TR.IRelaxedToken(20, 'delimiter.sv'),
          TR.IRelaxedToken(21, 'number.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ' my_checker #(0, 1) instance (clk, \'b1, en);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'identifier.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(13, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(14, 'number.sv'),
          TR.IRelaxedToken(15, 'delimiter.sv'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'number.sv'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'type.sv'),
          TR.IRelaxedToken(28, ''),
          TR.IRelaxedToken(29, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(30, 'identifier.sv'),
          TR.IRelaxedToken(33, 'delimiter.sv'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'number.binary.sv'),
          TR.IRelaxedToken(38, 'delimiter.sv'),
          TR.IRelaxedToken(39, ''),
          TR.IRelaxedToken(40, 'identifier.sv'),
          TR.IRelaxedToken(42, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(43, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'and #(.p1("string"), .p2(int)) u5 (i,o);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.and.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.sv'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(10, 'string.sv'),
          TR.IRelaxedToken(18, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(19, 'delimiter.sv'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(22, 'identifier.sv'),
          TR.IRelaxedToken(24, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(25, 'keyword.int.sv'),
          TR.IRelaxedToken(28, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'type.sv'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(34, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(35, 'identifier.sv'),
          TR.IRelaxedToken(36, 'delimiter.sv'),
          TR.IRelaxedToken(37, 'identifier.sv'),
          TR.IRelaxedToken(38, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(39, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  mod #(\\n\t\t/* comment */\t) inst ();',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.sv'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(12, 'comment.sv'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'type.sv'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(35, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'm_t myStructs[1:0] = \'{\'{1, 1.0}, \'{2, 2.0}};',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.sv'),
          TR.IRelaxedToken(13, 'delimiter.square.sv'),
          TR.IRelaxedToken(14, 'number.sv'),
          TR.IRelaxedToken(15, 'delimiter.sv'),
          TR.IRelaxedToken(16, 'number.sv'),
          TR.IRelaxedToken(17, 'delimiter.square.sv'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'delimiter.sv'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(22, 'delimiter.curly.sv'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'delimiter.curly.sv'),
          TR.IRelaxedToken(25, 'number.sv'),
          TR.IRelaxedToken(26, 'delimiter.sv'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'number.float.sv'),
          TR.IRelaxedToken(31, 'delimiter.curly.sv'),
          TR.IRelaxedToken(32, 'delimiter.sv'),
          TR.IRelaxedToken(33, ''),
          TR.IRelaxedToken(35, 'delimiter.curly.sv'),
          TR.IRelaxedToken(36, 'number.sv'),
          TR.IRelaxedToken(37, 'delimiter.sv'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'number.float.sv'),
          TR.IRelaxedToken(42, 'delimiter.curly.sv'),
          TR.IRelaxedToken(44, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '    sig_a ##1 sig_b ##10 sig_c ##1 done;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(4, 'identifier.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(12, 'number.sv'),
          TR.IRelaxedToken(15, 'identifier.sv'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(22, 'number.sv'),
          TR.IRelaxedToken(26, 'identifier.sv'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(33, 'number.sv'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'identifier.sv'),
          TR.IRelaxedToken(39, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'addr[32:10] = \$urandom( 254 ); // my comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(4, 'delimiter.square.sv'),
          TR.IRelaxedToken(5, 'number.sv'),
          TR.IRelaxedToken(7, 'delimiter.sv'),
          TR.IRelaxedToken(8, 'number.sv'),
          TR.IRelaxedToken(10, 'delimiter.square.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'delimiter.sv'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'variable.predefined.sv'),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'number.sv'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(29, 'delimiter.sv'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'comment.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '  my_struct instA, instB;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'identifier.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.sv'),
          TR.IRelaxedToken(17, 'delimiter.sv'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'identifier.sv'),
          TR.IRelaxedToken(24, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'myMod #(.PARAM(\$bits({mySignal[4:0]}))) inst (.*);',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'identifier.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.sv'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(15, 'variable.predefined.sv'),
          TR.IRelaxedToken(20, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'identifier.sv'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'number.sv'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'number.sv'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(36, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(39, ''),
          TR.IRelaxedToken(40, 'type.sv'),
          TR.IRelaxedToken(44, ''),
          TR.IRelaxedToken(45, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(46, ''),
          TR.IRelaxedToken(48, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(49, 'delimiter.sv'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'table',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.table.sv'),
        ],
      ),
      TR.ITestItem(
        '  //  clk  d    q    q+',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'comment.sv'),
        ],
      ),
      TR.ITestItem(
        '  r  ?  0 : ? : - ;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.predefined.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(5, 'variable.predefined.sv'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'variable.predefined.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'variable.predefined.sv'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.sv'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'variable.predefined.sv'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'delimiter.sv'),
        ],
      ),
      TR.ITestItem(
        '  0 x (01) : 0 : 1; // Comment ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'variable.predefined.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'variable.predefined.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(7, 'variable.predefined.sv'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.sv'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'delimiter.sv'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'variable.predefined.sv'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'delimiter.sv'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'variable.predefined.sv'),
          TR.IRelaxedToken(18, 'delimiter.sv'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'comment.sv'),
        ],
      ),
      TR.ITestItem(
        '0 0 1 : 0 : 1 ;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.predefined.sv'),
          TR.IRelaxedToken(1, ''),
          TR.IRelaxedToken(2, 'variable.predefined.sv'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'variable.predefined.sv'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'delimiter.sv'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'variable.predefined.sv'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'delimiter.sv'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'variable.predefined.sv'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'delimiter.sv'),
        ],
      ),
      TR.ITestItem(
        'endtable',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.endtable.sv'),
        ],
      ),
    ],
  ]);
}

