// 1:1 port of vscode/src/vs/editor/test/node/diffing/verifyLinesDiff.test.ts
//
// Exposes the official cases as data so a truth test can replay every
// assertion against the JSON recorded by the real transpiled TypeScript test.

import '../../../../base/test/common/utils.dart'
    show ensureNoDisposablesAreLeakedInTestSuite;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/ranges/lineRange.dart' show LineRange;
import '../../../common/diff/defaultLinesDiffComputer/defaultLinesDiffComputer.dart'
    show DefaultLinesDiffComputer;
import '../../../common/diff/linesDiffComputer.dart'
    show ILinesDiffComputerOptions, LinesDiff, MovedText;
import '../../../common/diff/rangeMapping.dart'
    show DetailedLineRangeMapping, RangeMapping;
import '../../../common/diff/verifyLinesDiff.dart' show verifyLinesDiff;

Map<String, Object?> _deepEqualAssertion(
  Object? actual,
  Object? expected,
) =>
    <String, Object?>{
      'kind': 'deepStrictEqual',
      'actual': actual,
      'expected': expected,
    };

/// 1:1: `suite('verifyLinesDiff', ...)`
List<Map<String, Object?>> runVerifyLinesDiffOfficialCases() {
  ensureNoDisposablesAreLeakedInTestSuite();

  const List<String> original = <String>['a', '\tb', 'c'];
  const List<String> modified = <String>['a', '  B', 'c'];

  LinesDiff computeDiff(bool ignoreTrimWhitespace) =>
      DefaultLinesDiffComputer().computeDiff(
        original,
        modified,
        ILinesDiffComputerOptions(
          ignoreTrimWhitespace: ignoreTrimWhitespace,
          maxComputationTimeMs: 0,
          computeMoves: false,
        ),
      );

  LinesDiff singleChange(List<RangeMapping>? innerChanges) => LinesDiff(
        <DetailedLineRangeMapping>[
          DetailedLineRangeMapping(
            LineRange(2, 3),
            LineRange(2, 3),
            innerChanges,
          ),
        ],
        <MovedText>[],
        false,
      );

  final Map<String, Object?> actual = <String, Object?>{
    'correct': verifyLinesDiff(computeDiff(false), original, modified, false),
    'correctIgnoringTrimWhitespace':
        verifyLinesDiff(computeDiff(true), original, modified, true),
    // Ignoring trim whitespace drops the indentation change, so the text is only reproduced up to trimming.
    'ignoringTrimWhitespaceCheckedStrictly':
        verifyLinesDiff(computeDiff(true), original, modified, false),
    // Deletes `b` instead of replacing it with `B`.
    'wrongEdit': verifyLinesDiff(
      singleChange(<RangeMapping>[
        RangeMapping(Range(2, 2, 2, 3), Range(2, 3, 2, 3)),
      ]),
      original,
      modified,
      true,
    ),
    'noInnerChanges':
        verifyLinesDiff(singleChange(null), original, modified, false),
  };
  final Map<String, Object?> expected = <String, Object?>{
    'correct': 'valid',
    'correctIgnoringTrimWhitespace': 'valid',
    'ignoringTrimWhitespaceCheckedStrictly': 'invalid',
    'wrongEdit': 'invalid',
    'noInnerChanges': 'unverified',
  };

  return <Map<String, Object?>>[
    <String, Object?>{
      'suite': 'verifyLinesDiff',
      'name': 'valid, invalid and unverified diffs',
      'assertions': <Object?>[_deepEqualAssertion(actual, expected)],
    },
  ];
}
