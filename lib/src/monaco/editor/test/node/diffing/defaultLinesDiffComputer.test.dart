// 1:1 port of vscode/src/vs/editor/test/node/diffing/defaultLinesDiffComputer.test.ts
//
// Exposes the official cases as data so a truth test can replay every
// assertion against the JSON recorded by the real transpiled TypeScript test.

import 'dart:convert';

import '../../../../base/test/common/utils.dart'
    show ensureNoDisposablesAreLeakedInTestSuite;
import '../../../common/core/edits/textEdit.dart' show TextEdit;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import '../../../common/core/text/abstractText.dart' show ArrayText;
import '../../../common/diff/defaultLinesDiffComputer/algorithms/diffAlgorithm.dart'
    show forceDateTimeoutInvalidForTesting;
import '../../../common/diff/defaultLinesDiffComputer/algorithms/myersDiffAlgorithm.dart'
    show MyersDiffAlgorithm;
import '../../../common/diff/defaultLinesDiffComputer/defaultLinesDiffComputer.dart'
    show DefaultLinesDiffComputer;
import '../../../common/diff/defaultLinesDiffComputer/linesSliceCharSequence.dart'
    show LinesSliceCharSequence;
import '../../../common/diff/linesDiffComputer.dart'
    show ILinesDiffComputerOptions, LinesDiff, MovedText;
import '../../../common/diff/rangeMapping.dart'
    show
      DetailedLineRangeMapping,
      RangeMapping,
      getLineRangeMapping;

Map<String, Object?> _jRange(Range r) => <String, Object?>{
      'startLineNumber': r.startLineNumber,
      'startColumn': r.startColumn,
      'endLineNumber': r.endLineNumber,
      'endColumn': r.endColumn,
    };

Map<String, Object?> _jLineRange(dynamic r) => <String, Object?>{
      'startLineNumber': r.startLineNumber,
      'endLineNumberExclusive': r.endLineNumberExclusive,
    };

Map<String, Object?> _jRangeMapping(RangeMapping m) => <String, Object?>{
      'originalRange': _jRange(m.originalRange),
      'modifiedRange': _jRange(m.modifiedRange),
    };

Map<String, Object?> _jDetailed(DetailedLineRangeMapping c) =>
    <String, Object?>{
      'original': _jLineRange(c.original),
      'modified': _jLineRange(c.modified),
      'innerChanges': c.innerChanges?.map(_jRangeMapping).toList(),
    };

Map<String, Object?> _jMovedText(MovedText m) => <String, Object?>{
      'lineRangeMapping': <String, Object?>{
        'original': _jLineRange(m.lineRangeMapping.original),
        'modified': _jLineRange(m.lineRangeMapping.modified),
      },
      'changes': m.changes.map(_jDetailed).toList(),
    };

Map<String, Object?> _jLinesDiff(LinesDiff d) => <String, Object?>{
      'changes': d.changes.map(_jDetailed).toList(),
      'moves': d.moves.map(_jMovedText).toList(),
      'hitTimeout': d.hitTimeout,
    };

Map<String, Object?> _deepEqualAssertion(
  Object? actual,
  Object? expected,
) =>
    <String, Object?>{
      'kind': 'deepStrictEqual',
      'actual': actual,
      'expected': expected,
    };

Map<String, Object?> _case(String suite, String name,
        List<Map<String, Object?>> assertions) =>
    <String, Object?>{
      'suite': suite,
      'name': name,
      'assertions': assertions,
    };

ILinesDiffComputerOptions _options([
  bool ignoreTrimWhitespace = false,
  int maxComputationTimeMs = 0,
  bool computeMoves = false,
  bool extendToSubwords = false,
]) =>
    ILinesDiffComputerOptions(
      ignoreTrimWhitespace: ignoreTrimWhitespace,
      maxComputationTimeMs: maxComputationTimeMs,
      computeMoves: computeMoves,
      extendToSubwords: extendToSubwords,
    );

/// 1:1: all four suites in the official test file.
List<Map<String, Object?>> runDefaultLinesDiffComputerOfficialCases() {
  ensureNoDisposablesAreLeakedInTestSuite();
  final List<Map<String, Object?>> cases = <Map<String, Object?>>[];
  const String suiteName = 'DefaultLinesDiffComputer raw changes';

  // test('captures short matches without changing display ranges', ...)
  {
    final DefaultLinesDiffComputer computer = DefaultLinesDiffComputer();
    final ILinesDiffComputerOptions options = _options();
    const List<String> before = <String>['a a a a'];
    const List<String> after = <String>['b b b b'];
    final ({LinesDiff diff, List<RangeMapping> rawChanges}) result =
        computer.computeDiffWithRawChanges(before, after, options);

    final List<RangeMapping> expectedRawChanges = <int>[0, 2, 4, 6]
        .map((int offset) => RangeMapping(
              Range(1, offset + 1, 1, offset + 2),
              Range(1, offset + 1, 1, offset + 2),
            ))
        .toList();
    cases.add(_case(
      suiteName,
      'captures short matches without changing display ranges',
      <Map<String, Object?>>[
        _deepEqualAssertion(
          <String, Object?>{
            'diff': _jLinesDiff(result.diff),
            'rawChanges': result.rawChanges.map(_jRangeMapping).toList(),
          },
          <String, Object?>{
            'diff': _jLinesDiff(computer.computeDiff(before, after, options)),
            'rawChanges':
                expectedRawChanges.map(_jRangeMapping).toList(),
          },
        ),
      ],
    ));
  }

  // test('preserves the timeout signal for raw character changes', ...)
  {
    forceDateTimeoutInvalidForTesting = true;
    try {
      final ArrayText original = ArrayText(<String>['a a a a']);
      final ArrayText modified = ArrayText(<String>['b b b b']);
      final ({LinesDiff diff, List<RangeMapping> rawChanges}) result =
          DefaultLinesDiffComputer().computeDiffWithRawChanges(
        original.getLines(),
        modified.getLines(),
        _options(false, 5000, false),
      );
      final TextEdit edit = TextEdit(
          result.rawChanges.map((RangeMapping c) => c.toTextEdit(modified)).toList());
      cases.add(_case(
        suiteName,
        'preserves the timeout signal for raw character changes',
        <Map<String, Object?>>[
          _deepEqualAssertion(
            <String, Object?>{
              'hitTimeout': result.diff.hitTimeout,
              'reconstructed': edit.apply(original),
            },
            <String, Object?>{
              'hitTimeout': true,
              'reconstructed': 'b b b b',
            },
          ),
        ],
      ));
    } finally {
      forceDateTimeoutInvalidForTesting = false;
    }
  }

  // for (const [before, after] of [...]) { test(`raw changes reconstruct ...`) }
  const List<List<String>> fixtures = <List<String>>[
    <String>['same', 'same'],
    <String>['', 'new\nfile\n'],
    <String>['old\nfile\n', ''],
    <String>['a\nb\nc', '\ta\nb\n\tc'],
    <String>['first\n\nlast', 'FIRST\n\nLAST'],
    <String>['a a\nunchanged\nz z', 'b b\nunchanged\ny y'],
    <String>['😀a😀a', '😀b😀b'],
    <String>['one\ntwo\nthree\nfour', 'three\nfour\none\ntwo'],
  ];
  for (final List<String> fixture in fixtures) {
    final String before = fixture[0];
    final String after = fixture[1];
    final DefaultLinesDiffComputer computer = DefaultLinesDiffComputer();
    final ILinesDiffComputerOptions options =
        _options(false, 0, true, true);
    final ArrayText original = ArrayText(before.split('\n'));
    final ArrayText modified = ArrayText(after.split('\n'));
    final ({LinesDiff diff, List<RangeMapping> rawChanges}) result =
        computer.computeDiffWithRawChanges(
      original.getLines(),
      modified.getLines(),
      options,
    );
    final TextEdit edit = TextEdit(
        result.rawChanges.map((RangeMapping c) => c.toTextEdit(modified)).toList());
    cases.add(_case(
      suiteName,
      'raw changes reconstruct ${jsonEncode(before)} to ${jsonEncode(after)}',
      <Map<String, Object?>>[
        _deepEqualAssertion(
          <String, Object?>{
            'diff': _jLinesDiff(result.diff),
            'reconstructed': edit.apply(original),
          },
          <String, Object?>{
            'diff': _jLinesDiff(computer.computeDiff(
                before.split('\n'), after.split('\n'), options)),
            'reconstructed': after,
          },
        ),
      ],
    ));
  }

  // test('move detection does not throw ...', ...)
  {
    const List<String> original = <String>[
      '\t\t\t\t// ignore',
      '\t\t\t}',
      '\t}',
      '\t\tthis._recommendations = [];',
      '\t\tthis._ignoredRecommendations = [];',
      '\t\t\t\t\t}',
    ];
    const List<String> modified = <String>[
      '\t\tthis._recommendations = [];',
      '\t\tthis._ignoredRecommendations = [];',
      '',
      '\t\t\t\t// ignore',
      '\t\t\t}',
      '\t\t}',
    ];
    final LinesDiff diff = DefaultLinesDiffComputer().computeDiff(
      original,
      modified,
      _options(false, 0, true),
    );
    cases.add(_case(
      suiteName,
      'move detection does not throw when a move starts in the first line of only one side',
      <Map<String, Object?>>[
        _deepEqualAssertion(diff.moves.map(_jMovedText).toList(), <Object?>[]),
      ],
    ));
  }

  // suite('myers')
  {
    final LinesSliceCharSequence s1 = LinesSliceCharSequence(
      <String>['hello world'],
      Range(1, 1, 1, 9007199254740991),
      true,
    );
    final LinesSliceCharSequence s2 = LinesSliceCharSequence(
      <String>['hallo welt'],
      Range(1, 1, 1, 9007199254740991),
      true,
    );
    MyersDiffAlgorithm().compute(s1, s2);
    cases.add(_case(
      'myers',
      '1',
      <Map<String, Object?>>[],
    ));
  }

  // suite('lineRangeMapping')
  {
    final DetailedLineRangeMapping simple = getLineRangeMapping(
      RangeMapping(Range(2, 1, 3, 1), Range(2, 1, 2, 1)),
      ArrayText(<String>[
        'const abc = "helloworld".split("");',
        '',
        ''
      ]),
      ArrayText(<String>[
        'const asciiLower = "helloworld".split("");',
        ''
      ]),
    );
    cases.add(_case(
      'lineRangeMapping',
      'Simple',
      <Map<String, Object?>>[
        _deepEqualAssertion(simple.toString(), '{[2,3)->[2,2)}'),
      ],
    ));

    final DetailedLineRangeMapping emptyLines = getLineRangeMapping(
      RangeMapping(Range(2, 1, 2, 1), Range(2, 1, 4, 1)),
      ArrayText(<String>['', '']),
      ArrayText(<String>['', '', '', '']),
    );
    cases.add(_case(
      'lineRangeMapping',
      'Empty Lines',
      <Map<String, Object?>>[
        _deepEqualAssertion(emptyLines.toString(), '{[2,2)->[2,4)}'),
      ],
    ));
  }

  // suite('LinesSliceCharSequence')
  {
    final LinesSliceCharSequence sequence = LinesSliceCharSequence(
      <String>[
        'line1: foo',
        'line2: fizzbuzz',
        'line3: barr',
        'line4: hello world',
        'line5: bazz',
      ],
      Range(2, 1, 5, 1),
      true,
    );

    final List<String> translated = OffsetRange.ofLength(sequence.length)
        .map<String>((int offset) =>
            sequence.translateOffset(offset).toString());
    cases.add(_case(
      'LinesSliceCharSequence',
      'translateOffset',
      <Map<String, Object?>>[
        _deepEqualAssertion(
          <String, Object?>{'result': translated},
          <String, Object?>{
            'result': <String>[
              '(2,1)', '(2,2)', '(2,3)', '(2,4)', '(2,5)', '(2,6)', '(2,7)', '(2,8)', '(2,9)', '(2,10)', '(2,11)',
              '(2,12)', '(2,13)', '(2,14)', '(2,15)', '(2,16)',
              '(3,1)', '(3,2)', '(3,3)', '(3,4)', '(3,5)', '(3,6)', '(3,7)', '(3,8)', '(3,9)', '(3,10)', '(3,11)', '(3,12)',
              '(4,1)', '(4,2)', '(4,3)', '(4,4)', '(4,5)', '(4,6)', '(4,7)', '(4,8)', '(4,9)',
              '(4,10)', '(4,11)', '(4,12)', '(4,13)', '(4,14)', '(4,15)', '(4,16)', '(4,17)',
              '(4,18)', '(4,19)',
            ],
          },
        ),
      ],
    ));

    cases.add(_case(
      'LinesSliceCharSequence',
      'extendToFullLines',
      <Map<String, Object?>>[
        _deepEqualAssertion(
          <String, Object?>{
            'result': sequence.getText(
                sequence.extendToFullLines(OffsetRange(20, 25)))
          },
          <String, Object?>{'result': 'line3: barr\n'},
        ),
        _deepEqualAssertion(
          <String, Object?>{
            'result': sequence.getText(
                sequence.extendToFullLines(OffsetRange(20, 45)))
          },
          <String, Object?>{'result': 'line3: barr\nline4: hello world\n'},
        ),
      ],
    ));
  }

  return cases;
}
