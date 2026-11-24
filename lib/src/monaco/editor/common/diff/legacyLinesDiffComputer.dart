// 1:1 port of vscode/src/vs/editor/common/diff/legacyLinesDiffComputer.ts
// The LCS engine, CharCode, strings helpers, LineRange/Range and the new
// rangeMapping/linesDiffComputer are all real 1:1 ports in this library.
// `Date.now()` is mapped to `DateTime.now().millisecondsSinceEpoch`.

import 'dart:math' as math;
import 'dart:typed_data' show Int32List;

import '../../../base/common/charCode.dart' show CharCode;
import '../../../base/common/diff/diffChange.dart' show DiffChange;
import '../../../base/common/diff/diff.dart'
    show IDiffChange, IDiffResult, ISequence, LcsDiff;
import '../../../base/common/strings.dart'
    show firstNonWhitespaceIndex, lastNonWhitespaceIndex;
import '../core/range.dart' show Range;
import '../core/ranges/lineRange.dart' show LineRange;
import '../../../base/common/assert.dart' show assertFn, checkAdjacentItems;
import 'linesDiffComputer.dart'
    show ILinesDiffComputer, ILinesDiffComputerOptions, LinesDiff, MovedText;
import 'rangeMapping.dart'
    show DetailedLineRangeMapping, RangeMapping;

const int MINIMUM_MATCHING_CHARACTER_LENGTH = 3;

/// 1:1: `export class LegacyLinesDiffComputer implements ILinesDiffComputer`
class LegacyLinesDiffComputer implements ILinesDiffComputer {
  @override
  LinesDiff computeDiff(List<String> originalLines, List<String> modifiedLines,
      ILinesDiffComputerOptions options) {
    final DiffComputer diffComputer = DiffComputer(originalLines, modifiedLines,
        IDiffComputerOpts(
          maxComputationTime: options.maxComputationTimeMs,
          shouldIgnoreTrimWhitespace: options.ignoreTrimWhitespace,
          shouldComputeCharChanges: true,
          shouldMakePrettyDiff: true,
          shouldPostProcessCharChanges: true,
        ));
    final IDiffComputerResult result = diffComputer.computeDiff();
    final List<DetailedLineRangeMapping> changes =
        <DetailedLineRangeMapping>[];
    DetailedLineRangeMapping? lastChange;

    for (final LineChange c in result.changes) {
      late final LineRange originalRange;
      if (c.originalEndLineNumber == 0) {
        // Insertion
        originalRange = LineRange(c.originalStartLineNumber + 1,
            c.originalStartLineNumber + 1);
      } else {
        originalRange = LineRange(c.originalStartLineNumber,
            c.originalEndLineNumber + 1);
      }

      late final LineRange modifiedRange;
      if (c.modifiedEndLineNumber == 0) {
        // Deletion
        modifiedRange = LineRange(c.modifiedStartLineNumber + 1,
            c.modifiedStartLineNumber + 1);
      } else {
        modifiedRange = LineRange(c.modifiedStartLineNumber,
            c.modifiedEndLineNumber + 1);
      }

      DetailedLineRangeMapping change = DetailedLineRangeMapping(
        originalRange,
        modifiedRange,
        c.charChanges?.map((CharChange c) => RangeMapping(
              Range(c.originalStartLineNumber, c.originalStartColumn,
                  c.originalEndLineNumber, c.originalEndColumn),
              Range(c.modifiedStartLineNumber, c.modifiedStartColumn,
                  c.modifiedEndLineNumber, c.modifiedEndColumn),
            )).toList(),
      );
      if (lastChange != null) {
        if (lastChange.modified.endLineNumberExclusive ==
                change.modified.startLineNumber ||
            lastChange.original.endLineNumberExclusive ==
                change.original.startLineNumber) {
          change = DetailedLineRangeMapping(
            lastChange.original.join(change.original),
            lastChange.modified.join(change.modified),
            lastChange.innerChanges != null && change.innerChanges != null
                ? <RangeMapping>[
                    ...lastChange.innerChanges!,
                    ...change.innerChanges!,
                  ]
                : null,
          );
          changes.removeLast();
        }
      }

      changes.add(change);
      lastChange = change;
    }

    assertFn(() => checkAdjacentItems<DetailedLineRangeMapping>(
          changes,
          (DetailedLineRangeMapping m1, DetailedLineRangeMapping m2) =>
              m2.original.startLineNumber - m1.original.endLineNumberExclusive ==
                      m2.modified.startLineNumber -
                          m1.modified.endLineNumberExclusive &&
                  m1.original.endLineNumberExclusive <
                      m2.original.startLineNumber &&
                  m1.modified.endLineNumberExclusive <
                      m2.modified.startLineNumber,
        ));

    return LinesDiff(changes, <MovedText>[], result.quitEarly);
  }
}

/// 1:1: `interface IDiffComputationResult`
class IDiffComputationResult {
  final bool quitEarly;
  final bool identical;
  final List<LineChange> changes;
  final List<DetailedLineRangeMapping> changes2;

  IDiffComputationResult(
      this.quitEarly, this.identical, this.changes, this.changes2);
}

/// 1:1: `interface IChange`
class IChange {
  final int originalStartLineNumber;
  final int originalEndLineNumber;
  final int modifiedStartLineNumber;
  final int modifiedEndLineNumber;

  const IChange({
    required this.originalStartLineNumber,
    required this.originalEndLineNumber,
    required this.modifiedStartLineNumber,
    required this.modifiedEndLineNumber,
  });
}

/// 1:1: `interface ICharChange extends IChange`
class ICharChange {
  final int originalStartLineNumber;
  final int originalEndLineNumber;
  final int modifiedStartLineNumber;
  final int modifiedEndLineNumber;
  final int originalStartColumn;
  final int originalEndColumn;
  final int modifiedStartColumn;
  final int modifiedEndColumn;

  const ICharChange({
    required this.originalStartLineNumber,
    required this.originalEndLineNumber,
    required this.modifiedStartLineNumber,
    required this.modifiedEndLineNumber,
    required this.originalStartColumn,
    required this.originalEndColumn,
    required this.modifiedStartColumn,
    required this.modifiedEndColumn,
  });
}

/// 1:1: `interface ILineChange extends IChange`
class ILineChange {
  final int originalStartLineNumber;
  final int originalEndLineNumber;
  final int modifiedStartLineNumber;
  final int modifiedEndLineNumber;
  final List<ICharChange>? charChanges;

  const ILineChange({
    required this.originalStartLineNumber,
    required this.originalEndLineNumber,
    required this.modifiedStartLineNumber,
    required this.modifiedEndLineNumber,
    required this.charChanges,
  });
}

/// 1:1: `interface IDiffComputerResult`
class IDiffComputerResult {
  final bool quitEarly;
  final List<LineChange> changes;

  IDiffComputerResult(this.quitEarly, this.changes);
}

IDiffResult computeDiff(
  ISequence originalSequence,
  ISequence modifiedSequence,
  bool Function() continueProcessingPredicate,
  bool pretty,
) {
  final LcsDiff diffAlgo =
      LcsDiff(originalSequence, modifiedSequence,
      (int furthestOriginalIndex, num matchLengthOfLongest) =>
          continueProcessingPredicate());
  return diffAlgo.ComputeDiff(pretty);
}

/// Dart resolves an unqualified `computeDiff(...)` inside [DiffComputer] to
/// the method of the same name; this alias keeps the source's top-level call.
final IDiffResult Function(
        ISequence, ISequence, bool Function(), bool) _computeTopLevel =
    computeDiff;

/// 1:1: `class LineSequence implements ISequence`
class LineSequence implements ISequence {
  final List<String> lines;
  final List<int> _startColumns = <int>[];
  final List<int> _endColumns = <int>[];

  LineSequence(this.lines) {
    for (int i = 0, length = lines.length; i < length; i++) {
      _startColumns.add(getFirstNonBlankColumn(lines[i], 1));
      _endColumns.add(getLastNonBlankColumn(lines[i], 1));
    }
  }

  @override
  Object getElements() {
    final List<String> elements = <String>[];
    for (int i = 0, len = lines.length; i < len; i++) {
      elements.add(lines[i].substring(_startColumns[i] - 1, _endColumns[i] - 1));
    }
    // The Dart LcsDiff bridge needs an explicit typed carrier for an empty
    // sequence; JS `_getElements` keeps the empty JS array as-is.
    if (elements.isEmpty) return Int32List(0);
    return elements;
  }

  @override
  String? getStrictElement(int index) => lines[index];

  int getStartLineNumber(int i) => i + 1;

  int getEndLineNumber(int i) => i + 1;

  CharSequence createCharSequence(bool shouldIgnoreTrimWhitespace,
      int startIndex, int endIndex) {
    final List<int> charCodes = <int>[];
    final List<int> lineNumbers = <int>[];
    final List<int> columns = <int>[];
    for (int index = startIndex; index <= endIndex; index++) {
      final String lineContent = lines[index];
      final int startColumn = shouldIgnoreTrimWhitespace
          ? _startColumns[index]
          : 1;
      final int endColumn = shouldIgnoreTrimWhitespace
          ? _endColumns[index]
          : lineContent.length + 1;
      for (int col = startColumn; col < endColumn; col++) {
        charCodes.add(lineContent.codeUnitAt(col - 1));
        lineNumbers.add(index + 1);
        columns.add(col);
      }
      if (!shouldIgnoreTrimWhitespace && index < endIndex) {
        charCodes.add(CharCode.LineFeed);
        lineNumbers.add(index + 1);
        columns.add(lineContent.length + 1);
      }
    }
    return CharSequence(charCodes, lineNumbers, columns);
  }
}

/// 1:1: `class CharSequence implements ISequence`
class CharSequence implements ISequence {
  final List<int> _charCodes;
  final List<int> _lineNumbers;
  final List<int> _columns;

  CharSequence(this._charCodes, this._lineNumbers, this._columns);

  @override
  String toString() => '[' +
      _charCodes.asMap().map((int idx, int s) => MapEntry(idx,
          '${s == CharCode.LineFeed ? '\\n' : String.fromCharCode(s)}-(${_lineNumbers[idx]},${_columns[idx]})')).values.join(', ') +
      ']';

  void _assertIndex(int index, List<int> arr) {
    if (index < 0 || index >= arr.length) {
      throw StateError('Illegal index');
    }
  }

  @override
  Object getElements() => _charCodes;

  @override
  String? getStrictElement(int index) => null;

  int getStartLineNumber(int i) {
    if (i > 0 && i == _lineNumbers.length) {
      return getEndLineNumber(i - 1);
    }
    _assertIndex(i, _lineNumbers);
    return _lineNumbers[i];
  }

  int getEndLineNumber(int i) {
    if (i == -1) {
      return getStartLineNumber(i + 1);
    }
    _assertIndex(i, _lineNumbers);
    if (_charCodes[i] == CharCode.LineFeed) {
      return _lineNumbers[i] + 1;
    }
    return _lineNumbers[i];
  }

  int getStartColumn(int i) {
    if (i > 0 && i == _columns.length) {
      return getEndColumn(i - 1);
    }
    _assertIndex(i, _columns);
    return _columns[i];
  }

  int getEndColumn(int i) {
    if (i == -1) {
      return getStartColumn(i + 1);
    }
    _assertIndex(i, _columns);
    if (_charCodes[i] == CharCode.LineFeed) {
      return 1;
    }
    return _columns[i] + 1;
  }
}

/// 1:1: `class CharChange implements ICharChange`
class CharChange implements ICharChange {
  @override
  int originalStartLineNumber;
  @override
  int originalStartColumn;
  @override
  int originalEndLineNumber;
  @override
  int originalEndColumn;
  @override
  int modifiedStartLineNumber;
  @override
  int modifiedStartColumn;
  @override
  int modifiedEndLineNumber;
  @override
  int modifiedEndColumn;

  CharChange(
    this.originalStartLineNumber,
    this.originalStartColumn,
    this.originalEndLineNumber,
    this.originalEndColumn,
    this.modifiedStartLineNumber,
    this.modifiedStartColumn,
    this.modifiedEndLineNumber,
    this.modifiedEndColumn,
  );

  static CharChange createFromDiffChange(IDiffChange diffChange,
      CharSequence originalCharSequence, CharSequence modifiedCharSequence) {
    final int originalStartLineNumber = originalCharSequence
        .getStartLineNumber(diffChange.originalStart);
    final int originalStartColumn =
        originalCharSequence.getStartColumn(diffChange.originalStart);
    final int originalEndLineNumber = originalCharSequence.getEndLineNumber(
        diffChange.originalStart + diffChange.originalLength - 1);
    final int originalEndColumn = originalCharSequence.getEndColumn(
        diffChange.originalStart + diffChange.originalLength - 1);

    final int modifiedStartLineNumber =
        modifiedCharSequence.getStartLineNumber(diffChange.modifiedStart);
    final int modifiedStartColumn =
        modifiedCharSequence.getStartColumn(diffChange.modifiedStart);
    final int modifiedEndLineNumber = modifiedCharSequence.getEndLineNumber(
        diffChange.modifiedStart + diffChange.modifiedLength - 1);
    final int modifiedEndColumn = modifiedCharSequence.getEndColumn(
        diffChange.modifiedStart + diffChange.modifiedLength - 1);

    return CharChange(
      originalStartLineNumber,
      originalStartColumn,
      originalEndLineNumber,
      originalEndColumn,
      modifiedStartLineNumber,
      modifiedStartColumn,
      modifiedEndLineNumber,
      modifiedEndColumn,
    );
  }
}

/// 1:1: `function postProcessCharChanges(rawChanges)`
List<IDiffChange> postProcessCharChanges(List<IDiffChange> rawChanges) {
  if (rawChanges.length <= 1) {
    return rawChanges;
  }

  final List<IDiffChange> result = <IDiffChange>[rawChanges[0]];
  IDiffChange prevChange = result[0];

  for (int i = 1, len = rawChanges.length; i < len; i++) {
    final IDiffChange currChange = rawChanges[i];

    final int originalMatchingLength = currChange.originalStart -
        (prevChange.originalStart + prevChange.originalLength);
    final int modifiedMatchingLength = currChange.modifiedStart -
        (prevChange.modifiedStart + prevChange.modifiedLength);
    final int matchingLength =
        math.min(originalMatchingLength, modifiedMatchingLength);

    if (matchingLength < MINIMUM_MATCHING_CHARACTER_LENGTH) {
      prevChange.originalLength =
          (currChange.originalStart + currChange.originalLength) -
              prevChange.originalStart;
      prevChange.modifiedLength =
          (currChange.modifiedStart + currChange.modifiedLength) -
              prevChange.modifiedStart;
    } else {
      result.add(currChange);
      prevChange = currChange;
    }
  }

  return result;
}

/// 1:1: `class LineChange implements ILineChange`
class LineChange implements ILineChange {
  @override
  int originalStartLineNumber;
  @override
  int originalEndLineNumber;
  @override
  int modifiedStartLineNumber;
  @override
  int modifiedEndLineNumber;
  @override
  List<CharChange>? charChanges;

  LineChange(
    this.originalStartLineNumber,
    this.originalEndLineNumber,
    this.modifiedStartLineNumber,
    this.modifiedEndLineNumber,
    this.charChanges,
  );

  static LineChange createFromDiffResult(
    bool shouldIgnoreTrimWhitespace,
    IDiffChange diffChange,
    LineSequence originalLineSequence,
    LineSequence modifiedLineSequence,
    bool Function() continueCharDiff,
    bool shouldComputeCharChanges,
    bool shouldPostProcessCharChanges,
  ) {
    late final int originalStartLineNumber;
    late final int originalEndLineNumber;
    late final int modifiedStartLineNumber;
    late final int modifiedEndLineNumber;
    List<CharChange>? charChanges;

    if (diffChange.originalLength == 0) {
      originalStartLineNumber =
          originalLineSequence.getStartLineNumber(diffChange.originalStart) - 1;
      originalEndLineNumber = 0;
    } else {
      originalStartLineNumber =
          originalLineSequence.getStartLineNumber(diffChange.originalStart);
      originalEndLineNumber = originalLineSequence.getEndLineNumber(
          diffChange.originalStart + diffChange.originalLength - 1);
    }

    if (diffChange.modifiedLength == 0) {
      modifiedStartLineNumber =
          modifiedLineSequence.getStartLineNumber(diffChange.modifiedStart) - 1;
      modifiedEndLineNumber = 0;
    } else {
      modifiedStartLineNumber =
          modifiedLineSequence.getStartLineNumber(diffChange.modifiedStart);
      modifiedEndLineNumber = modifiedLineSequence.getEndLineNumber(
          diffChange.modifiedStart + diffChange.modifiedLength - 1);
    }

    if (shouldComputeCharChanges &&
        diffChange.originalLength > 0 &&
        diffChange.originalLength < 20 &&
        diffChange.modifiedLength > 0 &&
        diffChange.modifiedLength < 20 &&
        continueCharDiff()) {
      final CharSequence originalCharSequence =
          originalLineSequence.createCharSequence(
              shouldIgnoreTrimWhitespace,
              diffChange.originalStart,
              diffChange.originalStart + diffChange.originalLength - 1);
      final CharSequence modifiedCharSequence =
          modifiedLineSequence.createCharSequence(
              shouldIgnoreTrimWhitespace,
              diffChange.modifiedStart,
              diffChange.modifiedStart + diffChange.modifiedLength - 1);

      if ((originalCharSequence.getElements() as List<int>).isNotEmpty &&
          (modifiedCharSequence.getElements() as List<int>).isNotEmpty) {
        List<IDiffChange> rawChanges = computeDiff(
          originalCharSequence,
          modifiedCharSequence,
          continueCharDiff,
          true,
        ).changes;

        if (shouldPostProcessCharChanges) {
          rawChanges = postProcessCharChanges(rawChanges);
        }

        charChanges = <CharChange>[];
        for (int i = 0, length = rawChanges.length; i < length; i++) {
          charChanges.add(CharChange.createFromDiffChange(rawChanges[i],
              originalCharSequence, modifiedCharSequence));
        }
      }
    }

    return LineChange(originalStartLineNumber, originalEndLineNumber,
        modifiedStartLineNumber, modifiedEndLineNumber, charChanges);
  }
}

/// 1:1: `interface IDiffComputerOpts`
class IDiffComputerOpts {
  final bool shouldComputeCharChanges;
  final bool shouldPostProcessCharChanges;
  final bool shouldIgnoreTrimWhitespace;
  final bool shouldMakePrettyDiff;
  final int maxComputationTime;

  const IDiffComputerOpts({
    required this.shouldComputeCharChanges,
    required this.shouldPostProcessCharChanges,
    required this.shouldIgnoreTrimWhitespace,
    required this.shouldMakePrettyDiff,
    required this.maxComputationTime,
  });
}

/// 1:1: `export class DiffComputer`
class DiffComputer {
  final bool shouldComputeCharChanges;
  final bool shouldPostProcessCharChanges;
  final bool shouldIgnoreTrimWhitespace;
  final bool shouldMakePrettyDiff;
  final List<String> originalLines;
  final List<String> modifiedLines;
  final LineSequence original;
  final LineSequence modified;
  final bool Function() continueLineDiff;
  final bool Function() continueCharDiff;

  DiffComputer(this.originalLines, this.modifiedLines, IDiffComputerOpts opts)
      : shouldComputeCharChanges = opts.shouldComputeCharChanges,
        shouldPostProcessCharChanges = opts.shouldPostProcessCharChanges,
        shouldIgnoreTrimWhitespace = opts.shouldIgnoreTrimWhitespace,
        shouldMakePrettyDiff = opts.shouldMakePrettyDiff,
        original = LineSequence(originalLines),
        modified = LineSequence(modifiedLines),
        continueLineDiff =
            createContinueProcessingPredicate(opts.maxComputationTime),
        continueCharDiff = createContinueProcessingPredicate(
            opts.maxComputationTime == 0
                ? 0
                : math.min(opts.maxComputationTime, 5000));

  IDiffComputerResult computeDiff() {
    if (original.lines.length == 1 && original.lines[0].isEmpty) {
      if (modified.lines.length == 1 && modified.lines[0].isEmpty) {
        return IDiffComputerResult(false, <LineChange>[]);
      }
      return IDiffComputerResult(false, <LineChange>[
        LineChange(1, 1, 1, modified.lines.length, null),
      ]);
    }

    if (modified.lines.length == 1 && modified.lines[0].isEmpty) {
      return IDiffComputerResult(false, <LineChange>[
        LineChange(1, original.lines.length, 1, 1, null),
      ]);
    }

    final IDiffResult diffResult = _computeTopLevel(
        original, modified, continueLineDiff, shouldMakePrettyDiff);
    final List<DiffChange> rawChanges = diffResult.changes;
    final bool quitEarly = diffResult.quitEarly;

    if (shouldIgnoreTrimWhitespace) {
      final List<LineChange> lineChanges = <LineChange>[];
      for (int i = 0, length = rawChanges.length; i < length; i++) {
        lineChanges.add(LineChange.createFromDiffResult(
          shouldIgnoreTrimWhitespace,
          rawChanges[i],
          original,
          modified,
          continueCharDiff,
          shouldComputeCharChanges,
          shouldPostProcessCharChanges,
        ));
      }
      return IDiffComputerResult(quitEarly, lineChanges);
    }

    final List<LineChange> result = <LineChange>[];

    int originalLineIndex = 0;
    int modifiedLineIndex = 0;
    for (int i = -1 /* !!!! */, len = rawChanges.length; i < len; i++) {
      final IDiffChange? nextChange =
          (i + 1 < len ? rawChanges[i + 1] : null);
      final int originalStop =
          (nextChange != null ? nextChange.originalStart : originalLines.length);
      final int modifiedStop =
          (nextChange != null ? nextChange.modifiedStart : modifiedLines.length);

      while (originalLineIndex < originalStop &&
          modifiedLineIndex < modifiedStop) {
        final String originalText = originalLines[originalLineIndex];
        final String modifiedText = modifiedLines[modifiedLineIndex];

        if (originalText != modifiedText) {
          // Check the leading whitespace
          {
            int originalStartColumn =
                getFirstNonBlankColumn(originalText, 1);
            int modifiedStartColumn =
                getFirstNonBlankColumn(modifiedText, 1);
            while (originalStartColumn > 1 && modifiedStartColumn > 1) {
              final int originalChar =
                  originalText.codeUnitAt(originalStartColumn - 2);
              final int modifiedChar =
                  modifiedText.codeUnitAt(modifiedStartColumn - 2);
              if (originalChar != modifiedChar) {
                break;
              }
              originalStartColumn--;
              modifiedStartColumn--;
            }

            if (originalStartColumn > 1 || modifiedStartColumn > 1) {
              _pushTrimWhitespaceCharChange(
                result,
                originalLineIndex + 1, 1, originalStartColumn,
                modifiedLineIndex + 1, 1, modifiedStartColumn,
              );
            }
          }

          // Check the trailing whitespace
          {
            int originalEndColumn = getLastNonBlankColumn(originalText, 1);
            int modifiedEndColumn = getLastNonBlankColumn(modifiedText, 1);
            final int originalMaxColumn = originalText.length + 1;
            final int modifiedMaxColumn = modifiedText.length + 1;
            while (originalEndColumn < originalMaxColumn &&
                modifiedEndColumn < modifiedMaxColumn) {
              final int originalChar =
                  originalText.codeUnitAt(originalEndColumn - 1);
              final int modifiedChar =
                  originalText.codeUnitAt(modifiedEndColumn - 1);
              if (originalChar != modifiedChar) {
                break;
              }
              originalEndColumn++;
              modifiedEndColumn++;
            }

            if (originalEndColumn < originalMaxColumn ||
                modifiedEndColumn < modifiedMaxColumn) {
              _pushTrimWhitespaceCharChange(
                result,
                originalLineIndex + 1, originalEndColumn, originalMaxColumn,
                modifiedLineIndex + 1, modifiedEndColumn, modifiedMaxColumn,
              );
            }
          }
        }
        originalLineIndex++;
        modifiedLineIndex++;
      }

      if (nextChange != null) {
        result.add(LineChange.createFromDiffResult(
          shouldIgnoreTrimWhitespace,
          nextChange,
          original,
          modified,
          continueCharDiff,
          shouldComputeCharChanges,
          shouldPostProcessCharChanges,
        ));
        originalLineIndex += nextChange.originalLength;
        modifiedLineIndex += nextChange.modifiedLength;
      }
    }

    return IDiffComputerResult(quitEarly, result);
  }

  void _pushTrimWhitespaceCharChange(
    List<LineChange> result,
    int originalLineNumber,
    int originalStartColumn,
    int originalEndColumn,
    int modifiedLineNumber,
    int modifiedStartColumn,
    int modifiedEndColumn,
  ) {
    if (_mergeTrimWhitespaceCharChange(
      result,
      originalLineNumber,
      originalStartColumn,
      originalEndColumn,
      modifiedLineNumber,
      modifiedStartColumn,
      modifiedEndColumn,
    )) {
      return;
    }

    List<CharChange>? charChanges;
    if (shouldComputeCharChanges) {
      charChanges = <CharChange>[
        CharChange(
          originalLineNumber,
          originalStartColumn,
          originalLineNumber,
          originalEndColumn,
          modifiedLineNumber,
          modifiedStartColumn,
          modifiedLineNumber,
          modifiedEndColumn,
        ),
      ];
    }
    result.add(LineChange(
      originalLineNumber,
      originalLineNumber,
      modifiedLineNumber,
      modifiedLineNumber,
      charChanges,
    ));
  }

  bool _mergeTrimWhitespaceCharChange(
    List<LineChange> result,
    int originalLineNumber,
    int originalStartColumn,
    int originalEndColumn,
    int modifiedLineNumber,
    int modifiedStartColumn,
    int modifiedEndColumn,
  ) {
    final int len = result.length;
    if (len == 0) {
      return false;
    }

    final LineChange prevChange = result[len - 1];

    if (prevChange.originalEndLineNumber == 0 ||
        prevChange.modifiedEndLineNumber == 0) {
      return false;
    }

    if (prevChange.originalEndLineNumber == originalLineNumber &&
        prevChange.modifiedEndLineNumber == modifiedLineNumber) {
      if (shouldComputeCharChanges && prevChange.charChanges != null) {
        prevChange.charChanges!.add(CharChange(
          originalLineNumber,
          originalStartColumn,
          originalLineNumber,
          originalEndColumn,
          modifiedLineNumber,
          modifiedStartColumn,
          modifiedLineNumber,
          modifiedEndColumn,
        ));
      }
      return true;
    }

    if (prevChange.originalEndLineNumber + 1 == originalLineNumber &&
        prevChange.modifiedEndLineNumber + 1 == modifiedLineNumber) {
      prevChange.originalEndLineNumber = originalLineNumber;
      prevChange.modifiedEndLineNumber = modifiedLineNumber;
      if (shouldComputeCharChanges && prevChange.charChanges != null) {
        prevChange.charChanges!.add(CharChange(
          originalLineNumber,
          originalStartColumn,
          originalLineNumber,
          originalEndColumn,
          modifiedLineNumber,
          modifiedStartColumn,
          modifiedLineNumber,
          modifiedEndColumn,
        ));
      }
      return true;
    }

    return false;
  }
}

int getFirstNonBlankColumn(String txt, int defaultValue) {
  final int r = firstNonWhitespaceIndex(txt);
  if (r == -1) {
    return defaultValue;
  }
  return r + 1;
}

int getLastNonBlankColumn(String txt, int defaultValue) {
  final int r = lastNonWhitespaceIndex(txt);
  if (r == -1) {
    return defaultValue;
  }
  return r + 2;
}

bool Function() createContinueProcessingPredicate(int maximumRuntime) {
  if (maximumRuntime == 0) {
    return () => true;
  }
  final int startTime = DateTime.now().millisecondsSinceEpoch;
  return () => DateTime.now().millisecondsSinceEpoch - startTime < maximumRuntime;
}
