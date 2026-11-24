// 1:1 port of vscode/src/vs/editor/test/node/diffing/fixtures.test.ts
//
// The three cases that load the absent `@vscode/diff` npm package are exposed
// as explicit skipped seams; all fixture-comparison cases are replayed against
// the recorded TypeScript truth.

import 'dart:convert';
import 'dart:io';

import '../../../../base/test/common/utils.dart'
    show ensureNoDisposablesAreLeakedInTestSuite;
import '../../../common/core/edits/textEdit.dart' show TextEdit;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/text/abstractText.dart' show ArrayText;
import '../../../common/diff/defaultLinesDiffComputer/defaultLinesDiffComputer.dart'
    show DefaultLinesDiffComputer;
import '../../../common/diff/linesDiffComputer.dart'
    show
      ILinesDiffComputer,
      ILinesDiffComputerOptions,
      LinesDiff,
      MovedText;
import '../../../common/diff/legacyLinesDiffComputer.dart'
    show LegacyLinesDiffComputer;
import '../../../common/diff/rangeMapping.dart'
    show DetailedLineRangeMapping, RangeMapping;
import '../../../common/diff/verifyLinesDiff.dart' show verifyLinesDiff;

class FixtureData {
  FixtureData({
    required this.folderPath,
    required this.firstFileName,
    required this.secondFileName,
    required this.firstContent,
    required this.secondContent,
  });

  final String folderPath;
  final String firstFileName;
  final String secondFileName;
  final String firstContent;
  final String secondContent;

  List<String> get firstContentLines => firstContent.split('\n');
  List<String> get secondContentLines => secondContent.split('\n');
  bool get ignoreTrimWhitespace => folderPath.contains('trimws');
}

class SkippedFixtureCase {
  const SkippedFixtureCase(this.suite, this.name, this.reason);

  final String suite;
  final String name;
  final String reason;
}

const List<SkippedFixtureCase> skippedFixtureCases = <SkippedFixtureCase>[
  SkippedFixtureCase(
    'diffing fixtures',
    '@vscode/diff (TS) agrees with the built-in algorithm on all fixtures',
    '@vscode/diff npm package is absent from the source tree',
  ),
  SkippedFixtureCase(
    'diffing fixtures',
    '@vscode/diff: ignoreTrimWhitespace hides only leading/trailing whitespace changes',
    '@vscode/diff npm package is absent from the source tree',
  ),
  SkippedFixtureCase(
    'diffing fixtures',
    'all diff algorithms produce valid diffs on all fixtures',
    '@vscode/diff npm package is absent from the source tree',
  ),
];

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

/// 1:1: `function readFixture(folder: string)`
FixtureData readFixture(String fixturesSrcDir, String folder) {
  final String folderPath = '$fixturesSrcDir/$folder';
  final List<String> files = Directory(folderPath)
      .listSync()
      .whereType<File>()
      .map((File f) => f.path.split('/').last)
      .toList()
    ..sort();
  final String firstFileName = files.firstWhere(
      (String f) => f.startsWith('1.'),
      orElse: () => throw StateError('No 1.* in $folderPath: $files'));
  final String secondFileName =
      files.firstWhere((String f) => f.startsWith('2.'));
  final String firstContent = File('$folderPath/$firstFileName')
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  final String secondContent = File('$folderPath/$secondFileName')
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  return FixtureData(
    folderPath: folderPath,
    firstFileName: firstFileName,
    secondFileName: secondFileName,
    firstContent: firstContent,
    secondContent: secondContent,
  );
}

/// 1:1: `function formatRange(range, lines)`
String formatRange(Range range, List<String> lines) {
  final bool toLastChar =
      range.endColumn == lines[range.endLineNumber - 1].length + 1;
  return '[${range.startLineNumber},${range.startColumn} -> '
      '${range.endLineNumber},${range.endColumn}${toLastChar ? ' EOL' : ''}]';
}

List<Map<String, Object?>> _getDiffs(
  List<DetailedLineRangeMapping> changes,
  List<String> firstContentLines,
  List<String> secondContentLines,
) {
  for (final DetailedLineRangeMapping c in changes) {
    RangeMapping.assertSorted(c.innerChanges ?? <RangeMapping>[]);
  }
  return changes
      .map((DetailedLineRangeMapping c) => <String, Object?>{
            'originalRange': c.original.toString(),
            'modifiedRange': c.modified.toString(),
            'innerChanges': c.innerChanges?.map((RangeMapping i) =>
                <String, Object?>{
                  'originalRange':
                      formatRange(i.originalRange, firstContentLines),
                  'modifiedRange':
                      formatRange(i.modifiedRange, secondContentLines),
                }).toList(),
          })
      .toList();
}

/// 1:1: `function rangeMappingsToTextEdit`
TextEdit _rangeMappingsToTextEdit(
  List<RangeMapping> rangeMappings,
  ArrayText modified,
) =>
    TextEdit(rangeMappings
        .map((RangeMapping m) => m.toTextEdit(modified))
        .toList());

/// 1:1: `function assertDiffCorrectness`
String assertDiffCorrectness(
  LinesDiff diff,
  List<String> originalLines,
  List<String> modifiedLines,
) {
  final List<RangeMapping> allInnerChanges = diff.changes
      .expand((DetailedLineRangeMapping c) => c.innerChanges ?? <RangeMapping>[])
      .toList();
  final TextEdit edit =
      _rangeMappingsToTextEdit(allInnerChanges, ArrayText(modifiedLines));
  return edit.normalize().apply(ArrayText(originalLines));
}

/// 1:1: `function runTest(folder, diffingAlgoName)` — comparison output only.
Map<String, Object?> runFixtureTest(
  FixtureData fixture,
  String diffingAlgoName, [
  String? caseName,
]) {
  final ILinesDiffComputer diffingAlgo = diffingAlgoName == 'legacy'
      ? LegacyLinesDiffComputer()
      : DefaultLinesDiffComputer();
  final LinesDiff diff = diffingAlgo.computeDiff(
    fixture.firstContentLines,
    fixture.secondContentLines,
    ILinesDiffComputerOptions(
      ignoreTrimWhitespace: fixture.ignoreTrimWhitespace,
      maxComputationTimeMs: 9007199254740991,
      computeMoves: true,
    ),
  );

  final List<Map<String, Object?>> assertions = <Map<String, Object?>>[];
  if (diffingAlgoName == 'advanced' && !fixture.ignoreTrimWhitespace) {
    assertions.add(_deepEqualAssertion(
      assertDiffCorrectness(
          diff, fixture.firstContentLines, fixture.secondContentLines),
      fixture.secondContentLines.join('\n'),
    ));
  }

  final Map<String, Object?> actualDiffingResult = <String, Object?>{
    'original': <String, Object?>{
      'content': fixture.firstContent,
      'fileName': './${fixture.firstFileName}',
    },
    'modified': <String, Object?>{
      'content': fixture.secondContent,
      'fileName': './${fixture.secondFileName}',
    },
    'diffs': _getDiffs(
        diff.changes, fixture.firstContentLines, fixture.secondContentLines),
    'moves': diff.moves
        .map((MovedText m) => <String, Object?>{
              'originalRange': m.lineRangeMapping.original.toString(),
              'modifiedRange': m.lineRangeMapping.modified.toString(),
              'changes': _getDiffs(
                  m.changes,
                  fixture.firstContentLines,
                  fixture.secondContentLines),
            })
        .toList(),
  };
  if ((actualDiffingResult['moves'] as List<Object?>).isEmpty) {
    actualDiffingResult.remove('moves');
  }

  final String expectedFilePath =
      '${fixture.folderPath}/$diffingAlgoName.expected.diff.json';
  final Object? expected = jsonDecode(File(expectedFilePath).readAsStringSync());
  assertions.add(_deepEqualAssertion(actualDiffingResult, expected));

  return _case(
      'diffing fixtures',
      caseName ?? '${fixture.folderPath.split('/').last}-$diffingAlgoName',
      assertions);
}

/// 1:1: `suite('diffing fixtures')` replay.
List<Map<String, Object?>> runFixtureOfficialCases(String fixturesSrcDir) {
  ensureNoDisposablesAreLeakedInTestSuite();

  final List<String> folders = Directory(fixturesSrcDir)
      .listSync()
      .whereType<Directory>()
      .map((Directory d) => d.path.split('/').last)
      .toList()
    ..sort();

  final List<Map<String, Object?>> cases = <Map<String, Object?>>[];

  // The explicit `test('test', ...)` at the top of the suite.
  cases.add(runFixtureTest(
    readFixture(fixturesSrcDir, 'invalid-diff-trimws'),
    'advanced',
    'test',
  ));

  for (final String folder in folders) {
    for (final String algoName in <String>['legacy', 'advanced']) {
      cases.add(runFixtureTest(readFixture(fixturesSrcDir, folder), algoName));
    }
  }

  return cases;
}

/// 1:1: all-diff-algorithms validity checks that do not require @vscode/diff.
Map<String, Object?> runBuiltinFixtureValidity(String fixturesSrcDir) {
  final List<String> folders = Directory(fixturesSrcDir)
      .listSync()
      .whereType<Directory>()
      .map((Directory d) => d.path.split('/').last)
      .toList()
    ..sort();
  final List<ILinesDiffComputer> algorithms = <ILinesDiffComputer>[
    DefaultLinesDiffComputer(),
  ];
  final List<String> invalid = <String>[];
  for (final String folder in folders) {
    final FixtureData fixture = readFixture(fixturesSrcDir, folder);
    for (int i = 0; i < algorithms.length; i++) {
      final String name = 'advanced';
      for (final bool ignoreTrimWhitespace in <bool>[false, true]) {
        final LinesDiff diff = algorithms[i].computeDiff(
          fixture.firstContentLines,
          fixture.secondContentLines,
          ILinesDiffComputerOptions(
            ignoreTrimWhitespace: ignoreTrimWhitespace,
            maxComputationTimeMs: 0,
            computeMoves: false,
          ),
        );
        final String validity = verifyLinesDiff(
          diff,
          fixture.firstContentLines,
          fixture.secondContentLines,
          ignoreTrimWhitespace,
        );
        if (validity != 'valid') {
          invalid.add('$folder $name ignoreTrimWhitespace=$ignoreTrimWhitespace: $validity');
        }
      }
    }
  }
  return _case(
    'diffing fixtures',
    'builtin validity (without @vscode/diff)',
    <Map<String, Object?>>[
      _deepEqualAssertion(invalid, <String>[
        'invalid-diff-bug advanced ignoreTrimWhitespace=true: invalid',
        'invalid-diff-trimws advanced ignoreTrimWhitespace=true: invalid',
      ]),
    ],
  );
}
