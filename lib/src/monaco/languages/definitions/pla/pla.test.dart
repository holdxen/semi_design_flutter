// Generated 1:1 from languages/definitions/pla/pla.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('pla')
void runLanguagesDefinitionsPlaPlaTestCases() {
  TR.testTokenization('pla', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        '.i 50',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.i.pla'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'number.pla'),
        ],
      ),
      TR.ITestItem(
        '  .i 333 # Input',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(2, 'keyword.i.pla'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'number.pla'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'comment.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.o 7',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.o.pla'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'number.pla'),
        ],
      ),
      TR.ITestItem(
        '\t.o\t1000 ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.o.pla'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.pla'),
          TR.IRelaxedToken(8, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.mv 9 4 3 21 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mv.pla'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.pla'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.pla'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'number.pla'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'number.pla'),
        ],
      ),
      TR.ITestItem(
        '.mv 22 22',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mv.pla'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.pla'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.ilb in1 in2 in3 in4 in5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ilb.pla'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.pla'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.pla'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.pla'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'identifier.pla'),
          TR.IRelaxedToken(20, ''),
          TR.IRelaxedToken(21, 'identifier.pla'),
        ],
      ),
      TR.ITestItem(
        '.ilb input<0> input<1> input<2> input<3>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ilb.pla'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.pla'),
          TR.IRelaxedToken(10, 'delimiter.angle.pla'),
          TR.IRelaxedToken(11, 'number.pla'),
          TR.IRelaxedToken(12, 'delimiter.angle.pla'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.pla'),
          TR.IRelaxedToken(19, 'delimiter.angle.pla'),
          TR.IRelaxedToken(20, 'number.pla'),
          TR.IRelaxedToken(21, 'delimiter.angle.pla'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'identifier.pla'),
          TR.IRelaxedToken(28, 'delimiter.angle.pla'),
          TR.IRelaxedToken(29, 'number.pla'),
          TR.IRelaxedToken(30, 'delimiter.angle.pla'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'identifier.pla'),
          TR.IRelaxedToken(37, 'delimiter.angle.pla'),
          TR.IRelaxedToken(38, 'number.pla'),
          TR.IRelaxedToken(39, 'delimiter.angle.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.ob out1 out2 out3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ob.pla'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pla'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.pla'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.pla'),
        ],
      ),
      TR.ITestItem(
        '.ob output<0> output<1>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ob.pla'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pla'),
          TR.IRelaxedToken(10, 'delimiter.angle.pla'),
          TR.IRelaxedToken(11, 'number.pla'),
          TR.IRelaxedToken(12, 'delimiter.angle.pla'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.pla'),
          TR.IRelaxedToken(20, 'delimiter.angle.pla'),
          TR.IRelaxedToken(21, 'number.pla'),
          TR.IRelaxedToken(22, 'delimiter.angle.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.label in1 in2 in3 in4 in5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.label.pla'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.pla'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'identifier.pla'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.pla'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'identifier.pla'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(23, 'identifier.pla'),
        ],
      ),
      TR.ITestItem(
        '.label  var=5 part1 part2 part3 part4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.label.pla'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(8, 'identifier.pla'),
          TR.IRelaxedToken(11, 'delimiter.pla'),
          TR.IRelaxedToken(12, 'number.pla'),
          TR.IRelaxedToken(13, ''),
          TR.IRelaxedToken(14, 'identifier.pla'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'identifier.pla'),
          TR.IRelaxedToken(25, ''),
          TR.IRelaxedToken(26, 'identifier.pla'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'identifier.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.type fr',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.type.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'type.pla'),
        ],
      ),
      TR.ITestItem(
        '\t.type\tfdr\t# Comment ',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.type.pla'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'type.pla'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'comment.pla'),
        ],
      ),
      TR.ITestItem(
        '.type other',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.type.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'type.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.phase 010',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.phase.pla'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'number.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.pair 2 (aa bb) (cc dd) ## Comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.pair.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.pla'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.pla'),
          TR.IRelaxedToken(9, 'identifier.pla'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'identifier.pla'),
          TR.IRelaxedToken(14, 'delimiter.parenthesis.pla'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'delimiter.parenthesis.pla'),
          TR.IRelaxedToken(17, 'identifier.pla'),
          TR.IRelaxedToken(19, ''),
          TR.IRelaxedToken(20, 'identifier.pla'),
          TR.IRelaxedToken(22, 'delimiter.parenthesis.pla'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'comment.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.symbolic aa<2> aa<1> aa<0> ; BB CC DD ;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.symbolic.pla'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.pla'),
          TR.IRelaxedToken(12, 'delimiter.angle.pla'),
          TR.IRelaxedToken(13, 'number.pla'),
          TR.IRelaxedToken(14, 'delimiter.angle.pla'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'identifier.pla'),
          TR.IRelaxedToken(18, 'delimiter.angle.pla'),
          TR.IRelaxedToken(19, 'number.pla'),
          TR.IRelaxedToken(20, 'delimiter.angle.pla'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'identifier.pla'),
          TR.IRelaxedToken(24, 'delimiter.angle.pla'),
          TR.IRelaxedToken(25, 'number.pla'),
          TR.IRelaxedToken(26, 'delimiter.angle.pla'),
          TR.IRelaxedToken(27, ''),
          TR.IRelaxedToken(28, 'delimiter.pla'),
          TR.IRelaxedToken(29, ''),
          TR.IRelaxedToken(30, 'identifier.pla'),
          TR.IRelaxedToken(32, ''),
          TR.IRelaxedToken(33, 'identifier.pla'),
          TR.IRelaxedToken(35, ''),
          TR.IRelaxedToken(36, 'identifier.pla'),
          TR.IRelaxedToken(38, ''),
          TR.IRelaxedToken(39, 'delimiter.pla'),
        ],
      ),
      TR.ITestItem(
        '.symbolic state<3> state<2>;aaa bbb; # comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.symbolic.pla'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.pla'),
          TR.IRelaxedToken(15, 'delimiter.angle.pla'),
          TR.IRelaxedToken(16, 'number.pla'),
          TR.IRelaxedToken(17, 'delimiter.angle.pla'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'identifier.pla'),
          TR.IRelaxedToken(24, 'delimiter.angle.pla'),
          TR.IRelaxedToken(25, 'number.pla'),
          TR.IRelaxedToken(26, 'delimiter.angle.pla'),
          TR.IRelaxedToken(27, 'delimiter.pla'),
          TR.IRelaxedToken(28, 'identifier.pla'),
          TR.IRelaxedToken(31, ''),
          TR.IRelaxedToken(32, 'identifier.pla'),
          TR.IRelaxedToken(35, 'delimiter.pla'),
          TR.IRelaxedToken(36, ''),
          TR.IRelaxedToken(37, 'comment.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.symbolic-output out<2> out<1> out<0> ; signal_a signal_b signal_c ;',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.symbolic-output.pla'),
          TR.IRelaxedToken(16, ''),
          TR.IRelaxedToken(17, 'identifier.pla'),
          TR.IRelaxedToken(20, 'delimiter.angle.pla'),
          TR.IRelaxedToken(21, 'number.pla'),
          TR.IRelaxedToken(22, 'delimiter.angle.pla'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(24, 'identifier.pla'),
          TR.IRelaxedToken(27, 'delimiter.angle.pla'),
          TR.IRelaxedToken(28, 'number.pla'),
          TR.IRelaxedToken(29, 'delimiter.angle.pla'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'identifier.pla'),
          TR.IRelaxedToken(34, 'delimiter.angle.pla'),
          TR.IRelaxedToken(35, 'number.pla'),
          TR.IRelaxedToken(36, 'delimiter.angle.pla'),
          TR.IRelaxedToken(37, ''),
          TR.IRelaxedToken(38, 'delimiter.pla'),
          TR.IRelaxedToken(39, ''),
          TR.IRelaxedToken(40, 'identifier.pla'),
          TR.IRelaxedToken(48, ''),
          TR.IRelaxedToken(49, 'identifier.pla'),
          TR.IRelaxedToken(57, ''),
          TR.IRelaxedToken(58, 'identifier.pla'),
          TR.IRelaxedToken(66, ''),
          TR.IRelaxedToken(67, 'delimiter.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.kiss #.kiss',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.kiss.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'comment.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.p 400',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.p.pla'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'number.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '\t.e\t',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, ''),
          TR.IRelaxedToken(1, 'keyword.e.pla'),
          TR.IRelaxedToken(3, ''),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '0-010|1000|100000000000000000000000000|0010000000',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pla'),
        ],
      ),
      TR.ITestItem(
        '--------------0 00000000000010',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pla'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'string.pla'),
        ],
      ),
      TR.ITestItem(
        '0~~0 1-0\t# Comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pla'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'string.pla'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'comment.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.i 4',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.i.pla'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'number.pla'),
        ],
      ),
      TR.ITestItem(
        '.o 3',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.o.pla'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'number.pla'),
        ],
      ),
      TR.ITestItem(
        '',
        <TR.IRelaxedToken>[
        ],
      ),
      TR.ITestItem(
        '# Comment only line',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.pla'),
        ],
      ),
      TR.ITestItem(
        '.ilb Q1 Q0 D N',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ilb.pla'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.pla'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'identifier.pla'),
          TR.IRelaxedToken(10, ''),
          TR.IRelaxedToken(11, 'identifier.pla'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.pla'),
        ],
      ),
      TR.ITestItem(
        '.ob T1 T0 input_1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ob.pla'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pla'),
          TR.IRelaxedToken(6, ''),
          TR.IRelaxedToken(7, 'identifier.pla'),
          TR.IRelaxedToken(9, ''),
          TR.IRelaxedToken(10, 'identifier.pla'),
        ],
      ),
      TR.ITestItem(
        '.p 5',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.p.pla'),
          TR.IRelaxedToken(2, ''),
          TR.IRelaxedToken(3, 'number.pla'),
        ],
      ),
      TR.ITestItem(
        '0--- 100',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pla'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'string.pla'),
        ],
      ),
      TR.ITestItem(
        '1-1- 010',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pla'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'string.pla'),
        ],
      ),
      TR.ITestItem(
        '.e',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.e.pla'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '.mv 8 5 -10 -10 6',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.mv.pla'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'number.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'number.pla'),
          TR.IRelaxedToken(7, ''),
          TR.IRelaxedToken(8, 'number.pla'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(12, 'number.pla'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(16, 'number.pla'),
        ],
      ),
      TR.ITestItem(
        '.ilb in1 in0 wait ack nack',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ilb.pla'),
          TR.IRelaxedToken(4, ''),
          TR.IRelaxedToken(5, 'identifier.pla'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.pla'),
          TR.IRelaxedToken(12, ''),
          TR.IRelaxedToken(13, 'identifier.pla'),
          TR.IRelaxedToken(17, ''),
          TR.IRelaxedToken(18, 'identifier.pla'),
          TR.IRelaxedToken(21, ''),
          TR.IRelaxedToken(22, 'identifier.pla'),
        ],
      ),
      TR.ITestItem(
        '.ob wait wait2 in3 pending ack delay',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.ob.pla'),
          TR.IRelaxedToken(3, ''),
          TR.IRelaxedToken(4, 'identifier.pla'),
          TR.IRelaxedToken(8, ''),
          TR.IRelaxedToken(9, 'identifier.pla'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(15, 'identifier.pla'),
          TR.IRelaxedToken(18, ''),
          TR.IRelaxedToken(19, 'identifier.pla'),
          TR.IRelaxedToken(26, ''),
          TR.IRelaxedToken(27, 'identifier.pla'),
          TR.IRelaxedToken(30, ''),
          TR.IRelaxedToken(31, 'identifier.pla'),
        ],
      ),
      TR.ITestItem(
        '.type fr',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.type.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(6, 'type.pla'),
        ],
      ),
      TR.ITestItem(
        '.kiss',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.kiss.pla'),
        ],
      ),
      TR.ITestItem(
        '--1--     -        wait     110000',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(10, 'string.pla'),
          TR.IRelaxedToken(11, ''),
          TR.IRelaxedToken(19, 'identifier.pla'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(28, 'string.pla'),
        ],
      ),
      TR.ITestItem(
        '--1--     wait    wait2     110000 # row comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(10, 'identifier.pla'),
          TR.IRelaxedToken(14, ''),
          TR.IRelaxedToken(18, 'identifier.pla'),
          TR.IRelaxedToken(23, ''),
          TR.IRelaxedToken(28, 'string.pla'),
          TR.IRelaxedToken(34, ''),
          TR.IRelaxedToken(35, 'comment.pla'),
        ],
      ),
      TR.ITestItem(
        '--0-1     delay    ack     101000',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.pla'),
          TR.IRelaxedToken(5, ''),
          TR.IRelaxedToken(10, 'identifier.pla'),
          TR.IRelaxedToken(15, ''),
          TR.IRelaxedToken(19, 'identifier.pla'),
          TR.IRelaxedToken(22, ''),
          TR.IRelaxedToken(27, 'string.pla'),
        ],
      ),
      TR.ITestItem(
        '.end',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.end.pla'),
        ],
      ),
    ],
  ]);
}

