// 1:1 port of vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/computeMovedLines.ts
// 严格 1:1 翻译；禁止自作主张改写算法语义。

import '../../../../base/common/arrays.dart'
    show compareBy, numberComparator, pushMany, reverseOrder;
import '../../../../base/common/arraysFind.dart'
    show MonotonousArray, findLastMonotonous;
import '../../../../base/common/map.dart' show SetMap;
import '../../core/range.dart' show Range;
import '../../core/ranges/lineRange.dart' show LineRange, LineRangeSet;
import '../rangeMapping.dart' show DetailedLineRangeMapping, LineRangeMapping;
import 'algorithms/diffAlgorithm.dart' show ITimeout, SequenceDiff;
import 'algorithms/myersDiffAlgorithm.dart' show MyersDiffAlgorithm;
import 'linesSliceCharSequence.dart' show LinesSliceCharSequence;
import 'utils.dart' show LineRangeFragment, isSpace;

class _HashedRange {
  final LineRange range;

  _HashedRange(this.range);
}

/// 1:1: `interface PossibleMapping` (local to `computeUnchangedMoves`)
class _PossibleMapping {
  LineRange modifiedLineRange;
  LineRange originalLineRange;

  _PossibleMapping(this.modifiedLineRange, this.originalLineRange);
}

class _MoveComputationResult {
  final List<LineRangeMapping> moves;
  final Set<DetailedLineRangeMapping> excludedChanges;

  _MoveComputationResult(this.moves, this.excludedChanges);
}

/// 1:1: `export function computeMovedLines`
List<LineRangeMapping> computeMovedLines(
  List<DetailedLineRangeMapping> changes,
  List<String> originalLines,
  List<String> modifiedLines,
  List<int> hashedOriginalLines,
  List<int> hashedModifiedLines,
  ITimeout timeout,
) {
  final _MoveComputationResult initial =
      _computeMovesFromSimpleDeletionsToSimpleInsertions(
          changes, originalLines, modifiedLines, timeout);
  List<LineRangeMapping> moves = initial.moves;
  final Set<DetailedLineRangeMapping> excludedChanges =
      initial.excludedChanges;

  if (!timeout.isValid()) {
    return <LineRangeMapping>[];
  }

  final List<DetailedLineRangeMapping> filteredChanges = changes
      .where((DetailedLineRangeMapping c) => !excludedChanges.contains(c))
      .toList();
  final List<LineRangeMapping> unchangedMoves = _computeUnchangedMoves(
    filteredChanges,
    hashedOriginalLines,
    hashedModifiedLines,
    originalLines,
    modifiedLines,
    timeout,
  );
  pushMany<LineRangeMapping>(moves, unchangedMoves);

  moves = _joinCloseConsecutiveMoves(moves);
  // Ignore too short moves
  moves = moves.where((LineRangeMapping current) {
    final List<String> lines = current.original
        .toOffsetRange()
        .slice<String>(originalLines)
        .map((String l) => l.trim())
        .toList();
    final String originalText = lines.join('\n');
    return originalText.length >= 15 &&
        _countWhere<String>(lines, (String l) => l.length >= 2) >= 2;
  }).toList();
  moves = _removeMovesInSameDiff(changes, moves);

  return moves;
}

/// 1:1: `function countWhere`
int _countWhere<T>(List<T> arr, bool Function(T t) predicate) {
  int count = 0;
  for (final T t in arr) {
    if (predicate(t)) {
      count++;
    }
  }
  return count;
}

/// 1:1: `function computeMovesFromSimpleDeletionsToSimpleInsertions`
_MoveComputationResult _computeMovesFromSimpleDeletionsToSimpleInsertions(
  List<DetailedLineRangeMapping> changes,
  List<String> originalLines,
  List<String> modifiedLines,
  ITimeout timeout,
) {
  final List<LineRangeMapping> moves = <LineRangeMapping>[];

  final List<LineRangeFragment> deletions = changes
      .where((DetailedLineRangeMapping c) =>
          c.modified.isEmpty && c.original.length >= 3)
      .map((DetailedLineRangeMapping d) =>
          LineRangeFragment(d.original, originalLines, d))
      .toList();
  final Set<LineRangeFragment> insertions = <LineRangeFragment>{};
  for (final DetailedLineRangeMapping d in changes
      .where((DetailedLineRangeMapping c) =>
          c.original.isEmpty && c.modified.length >= 3)) {
    insertions.add(LineRangeFragment(d.modified, modifiedLines, d));
  }

  final Set<DetailedLineRangeMapping> excludedChanges =
      <DetailedLineRangeMapping>{};

  for (final LineRangeFragment deletion in deletions) {
    double highestSimilarity = -1;
    LineRangeFragment? best;
    for (final LineRangeFragment insertion in insertions) {
      final double similarity = deletion.computeSimilarity(insertion);
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        best = insertion;
      }
    }

    if (highestSimilarity > 0.90 && best != null) {
      insertions.remove(best);
      moves.add(LineRangeMapping(deletion.range, best.range));
      excludedChanges.add(deletion.source);
      excludedChanges.add(best.source);
    }

    if (!timeout.isValid()) {
      return _MoveComputationResult(moves, excludedChanges);
    }
  }

  return _MoveComputationResult(moves, excludedChanges);
}

/// 1:1: `function computeUnchangedMoves`
List<LineRangeMapping> _computeUnchangedMoves(
  List<DetailedLineRangeMapping> changes,
  List<int> hashedOriginalLines,
  List<int> hashedModifiedLines,
  List<String> originalLines,
  List<String> modifiedLines,
  ITimeout timeout,
) {
  final List<LineRangeMapping> moves = <LineRangeMapping>[];

  final SetMap<String, _HashedRange> original3LineHashes =
      SetMap<String, _HashedRange>();

  for (final DetailedLineRangeMapping change in changes) {
    for (int i = change.original.startLineNumber;
        i < change.original.endLineNumberExclusive - 2;
        i++) {
      final String key = '${hashedOriginalLines[i - 1]}:'
          '${hashedOriginalLines[i + 1 - 1]}:'
          '${hashedOriginalLines[i + 2 - 1]}';
      original3LineHashes.add(key, _HashedRange(LineRange(i, i + 3)));
    }
  }

  final List<_PossibleMapping> possibleMappings = <_PossibleMapping>[];

  changes.sort(compareBy<DetailedLineRangeMapping, int>(
      (DetailedLineRangeMapping c) => c.modified.startLineNumber,
      numberComparator));

  for (final DetailedLineRangeMapping change in changes) {
    List<_PossibleMapping> lastMappings = <_PossibleMapping>[];
    for (int i = change.modified.startLineNumber;
        i < change.modified.endLineNumberExclusive - 2;
        i++) {
      final String key = '${hashedModifiedLines[i - 1]}:'
          '${hashedModifiedLines[i + 1 - 1]}:'
          '${hashedModifiedLines[i + 2 - 1]}';
      final LineRange currentModifiedRange = LineRange(i, i + 3);

      final List<_PossibleMapping> nextMappings = <_PossibleMapping>[];
      original3LineHashes.forEach(key, (_HashedRange value) {
        final LineRange range = value.range;
        for (final _PossibleMapping lastMapping in lastMappings) {
          // does this match extend some last match?
          if (lastMapping.originalLineRange.endLineNumberExclusive + 1 ==
                  range.endLineNumberExclusive &&
              lastMapping.modifiedLineRange.endLineNumberExclusive + 1 ==
                  currentModifiedRange.endLineNumberExclusive) {
            lastMapping.originalLineRange = LineRange(
                lastMapping.originalLineRange.startLineNumber,
                range.endLineNumberExclusive);
            lastMapping.modifiedLineRange = LineRange(
                lastMapping.modifiedLineRange.startLineNumber,
                currentModifiedRange.endLineNumberExclusive);
            nextMappings.add(lastMapping);
            return;
          }
        }

        final _PossibleMapping mapping = _PossibleMapping(
          currentModifiedRange,
          range,
        );
        possibleMappings.add(mapping);
        nextMappings.add(mapping);
      });
      lastMappings = nextMappings;
    }

    if (!timeout.isValid()) {
      return <LineRangeMapping>[];
    }
  }

  possibleMappings.sort(reverseOrder<_PossibleMapping>(compareBy<_PossibleMapping, int>(
      (_PossibleMapping m) => m.modifiedLineRange.length,
      numberComparator)));

  final LineRangeSet modifiedSet = LineRangeSet();
  final LineRangeSet originalSet = LineRangeSet();

  for (final _PossibleMapping mapping in possibleMappings) {
    final int diffOrigToMod = mapping.modifiedLineRange.startLineNumber -
        mapping.originalLineRange.startLineNumber;
    final LineRangeSet modifiedSections =
        modifiedSet.subtractFrom(mapping.modifiedLineRange);
    final LineRangeSet originalTranslatedSections = originalSet
        .subtractFrom(mapping.originalLineRange)
        .getWithDelta(diffOrigToMod);

    final LineRangeSet modifiedIntersectedSections =
        modifiedSections.getIntersection(originalTranslatedSections);

    for (final LineRange s in modifiedIntersectedSections.ranges) {
      if (s.length < 3) {
        continue;
      }
      final LineRange modifiedLineRange = s;
      final LineRange originalLineRange = s.delta(-diffOrigToMod);

      moves.add(LineRangeMapping(originalLineRange, modifiedLineRange));

      modifiedSet.addRange(modifiedLineRange);
      originalSet.addRange(originalLineRange);
    }
  }

  moves.sort(compareBy<LineRangeMapping, int>(
      (LineRangeMapping m) => m.original.startLineNumber,
      numberComparator));

  final MonotonousArray<DetailedLineRangeMapping> monotonousChanges =
      MonotonousArray<DetailedLineRangeMapping>(changes);
  for (int i = 0; i < moves.length; i++) {
    final LineRangeMapping move = moves[i];
    final DetailedLineRangeMapping firstTouchingChangeOrig =
        monotonousChanges.findLastMonotonous((DetailedLineRangeMapping c) =>
            c.original.startLineNumber <= move.original.startLineNumber)!;
    final DetailedLineRangeMapping firstTouchingChangeMod =
        findLastMonotonous<DetailedLineRangeMapping>(
            changes,
            (DetailedLineRangeMapping c) =>
                c.modified.startLineNumber <= move.modified.startLineNumber)!;
    final int linesAbove = _max(
      move.original.startLineNumber -
          firstTouchingChangeOrig.original.startLineNumber,
      move.modified.startLineNumber -
          firstTouchingChangeMod.modified.startLineNumber,
    );

    final DetailedLineRangeMapping lastTouchingChangeOrig =
        monotonousChanges.findLastMonotonous((DetailedLineRangeMapping c) =>
            c.original.startLineNumber < move.original.endLineNumberExclusive)!;
    final DetailedLineRangeMapping lastTouchingChangeMod =
        findLastMonotonous<DetailedLineRangeMapping>(
            changes,
            (DetailedLineRangeMapping c) =>
                c.modified.startLineNumber < move.modified.endLineNumberExclusive)!;
    final int linesBelow = _max(
      lastTouchingChangeOrig.original.endLineNumberExclusive -
          move.original.endLineNumberExclusive,
      lastTouchingChangeMod.modified.endLineNumberExclusive -
          move.modified.endLineNumberExclusive,
    );

    int extendToTop = 0;
    for (extendToTop = 0; extendToTop < linesAbove; extendToTop++) {
      final int origLine = move.original.startLineNumber - extendToTop - 1;
      final int modLine = move.modified.startLineNumber - extendToTop - 1;
      if (origLine < 1 || modLine < 1) {
        break;
      }
      if (modifiedSet.contains(modLine) || originalSet.contains(origLine)) {
        break;
      }
      if (!_areLinesSimilar(originalLines[origLine - 1],
          modifiedLines[modLine - 1], timeout)) {
        break;
      }
    }

    if (extendToTop > 0) {
      originalSet.addRange(LineRange(
          move.original.startLineNumber - extendToTop,
          move.original.startLineNumber));
      modifiedSet.addRange(LineRange(
          move.modified.startLineNumber - extendToTop,
          move.modified.startLineNumber));
    }

    int extendToBottom = 0;
    for (extendToBottom = 0; extendToBottom < linesBelow; extendToBottom++) {
      final int origLine = move.original.endLineNumberExclusive + extendToBottom;
      final int modLine = move.modified.endLineNumberExclusive + extendToBottom;
      if (origLine > originalLines.length || modLine > modifiedLines.length) {
        break;
      }
      if (modifiedSet.contains(modLine) || originalSet.contains(origLine)) {
        break;
      }
      if (!_areLinesSimilar(originalLines[origLine - 1],
          modifiedLines[modLine - 1], timeout)) {
        break;
      }
    }

    if (extendToBottom > 0) {
      originalSet.addRange(LineRange(
          move.original.endLineNumberExclusive,
          move.original.endLineNumberExclusive + extendToBottom));
      modifiedSet.addRange(LineRange(
          move.modified.endLineNumberExclusive,
          move.modified.endLineNumberExclusive + extendToBottom));
    }

    if (extendToTop > 0 || extendToBottom > 0) {
      moves[i] = LineRangeMapping(
        LineRange(
          move.original.startLineNumber - extendToTop,
          move.original.endLineNumberExclusive + extendToBottom,
        ),
        LineRange(
          move.modified.startLineNumber - extendToTop,
          move.modified.endLineNumberExclusive + extendToBottom,
        ),
      );
    }
  }

  return moves;
}

int _max(int a, int b) => a > b ? a : b;

/// 1:1: `function areLinesSimilar`
bool _areLinesSimilar(String line1, String line2, ITimeout timeout) {
  if (line1.trim() == line2.trim()) {
    return true;
  }
  if (line1.length > 300 && line2.length > 300) {
    return false;
  }

  final MyersDiffAlgorithm myersDiffingAlgorithm = MyersDiffAlgorithm();
  final result = myersDiffingAlgorithm.compute(
    LinesSliceCharSequence(
        <String>[line1], Range(1, 1, 1, line1.length), false),
    LinesSliceCharSequence(
        <String>[line2], Range(1, 1, 1, line2.length), false),
    timeout,
  );
  int commonNonSpaceCharCount = 0;
  final List<SequenceDiff> inverted =
      SequenceDiff.invert(result.diffs, line1.length);
  for (final SequenceDiff seq in inverted) {
    seq.seq1Range.forEach((int idx) {
      if (!isSpace(line1.codeUnitAt(idx))) {
        commonNonSpaceCharCount++;
      }
    });
  }

  // Source quirk preserved: the loop bound is `line1.length`, while the indexed
  // string is `str` (which may be line2).
  int countNonWsChars(String str) {
    int count = 0;
    for (int i = 0; i < line1.length; i++) {
      if (!isSpace(str.codeUnitAt(i))) {
        count++;
      }
    }
    return count;
  }

  final int longerLineLength = countNonWsChars(
      line1.length > line2.length ? line1 : line2);
  final bool r = commonNonSpaceCharCount / longerLineLength > 0.6 &&
      longerLineLength > 10;
  return r;
}

/// 1:1: `function joinCloseConsecutiveMoves`
List<LineRangeMapping> _joinCloseConsecutiveMoves(
    List<LineRangeMapping> moves) {
  if (moves.isEmpty) {
    return moves;
  }

  moves.sort(compareBy<LineRangeMapping, int>(
      (LineRangeMapping m) => m.original.startLineNumber,
      numberComparator));

  final List<LineRangeMapping> result = <LineRangeMapping>[moves[0]];
  for (int i = 1; i < moves.length; i++) {
    final LineRangeMapping last = result[result.length - 1];
    final LineRangeMapping current = moves[i];

    final int originalDist =
        current.original.startLineNumber - last.original.endLineNumberExclusive;
    final int modifiedDist =
        current.modified.startLineNumber - last.modified.endLineNumberExclusive;
    final bool currentMoveAfterLast = originalDist >= 0 && modifiedDist >= 0;

    if (currentMoveAfterLast && originalDist + modifiedDist <= 2) {
      result[result.length - 1] = last.join(current);
      continue;
    }

    result.add(current);
  }
  return result;
}

/// 1:1: `function removeMovesInSameDiff`
List<LineRangeMapping> _removeMovesInSameDiff(
  List<DetailedLineRangeMapping> changes,
  List<LineRangeMapping> moves,
) {
  final MonotonousArray<DetailedLineRangeMapping> changesMonotonous =
      MonotonousArray<DetailedLineRangeMapping>(changes);
  final List<LineRangeMapping> result = moves.where((LineRangeMapping m) {
    final LineRangeMapping diffBeforeEndOfMoveOriginal =
        changesMonotonous.findLastMonotonous((DetailedLineRangeMapping c) =>
                c.original.startLineNumber < m.original.endLineNumberExclusive) ??
            LineRangeMapping(LineRange(1, 1), LineRange(1, 1));
    final DetailedLineRangeMapping? diffBeforeEndOfMoveModified =
        findLastMonotonous<DetailedLineRangeMapping>(
            changes,
            (DetailedLineRangeMapping c) =>
                c.modified.startLineNumber < m.modified.endLineNumberExclusive);

    final bool differentDiffs =
        diffBeforeEndOfMoveOriginal != diffBeforeEndOfMoveModified;
    return differentDiffs;
  }).toList();
  return result;
}
