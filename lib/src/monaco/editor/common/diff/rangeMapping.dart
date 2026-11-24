// 1:1 port of vscode/src/vs/editor/common/diff/rangeMapping.ts
// `IChange` from legacyLinesDiffComputer.ts is type-only in the source, so it
// is mirrored here as a small structural interface without a runtime import.

import '../../../base/common/arrays.dart' show groupAdjacentBy;
import '../../../base/common/assert.dart' show assertFn, checkAdjacentItems;
import '../../../base/common/errors.dart' show BugIndicatingError;
import '../core/position.dart' show Position;
import '../core/range.dart' show Range;
import '../core/edits/textEdit.dart' show TextEdit, TextReplacement;
import '../core/ranges/lineRange.dart' show LineRange;
import '../core/text/abstractText.dart' show AbstractText;

/// 1:1: `interface IChange` (structural type from legacyLinesDiffComputer.ts)
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

/// Maps a line range in the original text model to a line range in the
/// modified text model.
class LineRangeMapping {
  static List<LineRangeMapping> inverse(
    List<LineRangeMapping> mapping,
    int originalLineCount,
    int modifiedLineCount,
  ) {
    final List<LineRangeMapping> result = <LineRangeMapping>[];
    int lastOriginalEndLineNumber = 1;
    int lastModifiedEndLineNumber = 1;

    for (final LineRangeMapping m in mapping) {
      final LineRangeMapping r = LineRangeMapping(
        LineRange(lastOriginalEndLineNumber, m.original.startLineNumber),
        LineRange(lastModifiedEndLineNumber, m.modified.startLineNumber),
      );
      if (!r.modified.isEmpty) {
        result.add(r);
      }
      lastOriginalEndLineNumber = m.original.endLineNumberExclusive;
      lastModifiedEndLineNumber = m.modified.endLineNumberExclusive;
    }
    final LineRangeMapping r = LineRangeMapping(
      LineRange(lastOriginalEndLineNumber, originalLineCount + 1),
      LineRange(lastModifiedEndLineNumber, modifiedLineCount + 1),
    );
    if (!r.modified.isEmpty) {
      result.add(r);
    }
    return result;
  }

  static List<LineRangeMapping> clip(
    List<LineRangeMapping> mapping,
    LineRange originalRange,
    LineRange modifiedRange,
  ) {
    final List<LineRangeMapping> result = <LineRangeMapping>[];
    for (final LineRangeMapping m in mapping) {
      final LineRange? original = m.original.intersect(originalRange);
      final LineRange? modified = m.modified.intersect(modifiedRange);
      if (original != null && !original.isEmpty &&
          modified != null && !modified.isEmpty) {
        result.add(LineRangeMapping(original, modified));
      }
    }
    return result;
  }

  final LineRange original;
  final LineRange modified;

  LineRangeMapping(this.original, this.modified);

  @override
  String toString() => '{${original.toString()}->${modified.toString()}}';

  LineRangeMapping flip() => LineRangeMapping(modified, original);

  LineRangeMapping join(LineRangeMapping other) => LineRangeMapping(
        original.join(other.original),
        modified.join(other.modified),
      );

  int get changedLineCount =>
      original.length > modified.length ? original.length : modified.length;

  RangeMapping toRangeMapping() {
    final Range? origInclusiveRange = original.toInclusiveRange();
    final Range? modInclusiveRange = modified.toInclusiveRange();
    if (origInclusiveRange != null && modInclusiveRange != null) {
      return RangeMapping(origInclusiveRange, modInclusiveRange);
    } else if (original.startLineNumber == 1 || modified.startLineNumber == 1) {
      if (!(modified.startLineNumber == 1 && original.startLineNumber == 1)) {
        throw BugIndicatingError('not a valid diff');
      }
      return RangeMapping(
        Range(original.startLineNumber, 1, original.endLineNumberExclusive, 1),
        Range(modified.startLineNumber, 1, modified.endLineNumberExclusive, 1),
      );
    } else {
      return RangeMapping(
        Range(original.startLineNumber - 1, 9007199254740991,
            original.endLineNumberExclusive - 1, 9007199254740991),
        Range(modified.startLineNumber - 1, 9007199254740991,
            modified.endLineNumberExclusive - 1, 9007199254740991),
      );
    }
  }

  RangeMapping toRangeMapping2(List<String> originalLines, List<String> modifiedLines) {
    if (isValidLineNumber(original.endLineNumberExclusive, originalLines) &&
        isValidLineNumber(modified.endLineNumberExclusive, modifiedLines)) {
      return RangeMapping(
        Range(original.startLineNumber, 1, original.endLineNumberExclusive, 1),
        Range(modified.startLineNumber, 1, modified.endLineNumberExclusive, 1),
      );
    }

    if (!original.isEmpty && !modified.isEmpty) {
      return RangeMapping(
        Range.fromPositions(
          Position(original.startLineNumber, 1),
          end: normalizePosition(
            Position(original.endLineNumberExclusive - 1, 9007199254740991),
            originalLines,
          ),
        ),
        Range.fromPositions(
          Position(modified.startLineNumber, 1),
          end: normalizePosition(
            Position(modified.endLineNumberExclusive - 1, 9007199254740991),
            modifiedLines,
          ),
        ),
      );
    }

    if (original.startLineNumber > 1 && modified.startLineNumber > 1) {
      return RangeMapping(
        Range.fromPositions(
          normalizePosition(
            Position(original.startLineNumber - 1, 9007199254740991),
            originalLines,
          ),
          end: normalizePosition(
            Position(original.endLineNumberExclusive - 1, 9007199254740991),
            originalLines,
          ),
        ),
        Range.fromPositions(
          normalizePosition(
            Position(modified.startLineNumber - 1, 9007199254740991),
            modifiedLines,
          ),
          end: normalizePosition(
            Position(modified.endLineNumberExclusive - 1, 9007199254740991),
            modifiedLines,
          ),
        ),
      );
    }

    throw BugIndicatingError();
  }
}

Position normalizePosition(Position position, List<String> content) {
  if (position.lineNumber < 1) {
    return Position(1, 1);
  }
  if (position.lineNumber > content.length) {
    return Position(content.length, content[content.length - 1].length + 1);
  }
  final String line = content[position.lineNumber - 1];
  if (position.column > line.length + 1) {
    return Position(position.lineNumber, line.length + 1);
  }
  return position;
}

bool isValidLineNumber(int lineNumber, List<String> lines) =>
    lineNumber >= 1 && lineNumber <= lines.length;

/// Maps a line range in the original text model to a line range in the modified
/// text model, including inner range mappings.
class DetailedLineRangeMapping extends LineRangeMapping {
  /// If inner changes have not been computed, this is undefined. Otherwise it
  /// represents the character-level diff in this line range.
  final List<RangeMapping>? innerChanges;

  DetailedLineRangeMapping(LineRange originalRange, LineRange modifiedRange,
      this.innerChanges)
      : super(originalRange, modifiedRange);

  static TextEdit toTextEdit(
      List<DetailedLineRangeMapping> mapping, AbstractText modified) {
    final List<TextReplacement> replacements = <TextReplacement>[];
    for (final DetailedLineRangeMapping m in mapping) {
      for (final RangeMapping r in m.innerChanges ?? <RangeMapping>[]) {
        replacements.add(r.toTextEdit(modified));
      }
    }
    return TextEdit(replacements);
  }

  static DetailedLineRangeMapping fromRangeMappings(List<RangeMapping> rangeMappings) {
    final LineRange originalRange = LineRange.joinStatic(
        rangeMappings.map((RangeMapping r) =>
            LineRange.fromRangeInclusive(r.originalRange)).toList());
    final LineRange modifiedRange = LineRange.joinStatic(
        rangeMappings.map((RangeMapping r) =>
            LineRange.fromRangeInclusive(r.modifiedRange)).toList());
    return DetailedLineRangeMapping(originalRange, modifiedRange, rangeMappings);
  }

  @override
  DetailedLineRangeMapping flip() => DetailedLineRangeMapping(
        modified,
        original,
        innerChanges?.map((RangeMapping c) => c.flip()).toList(),
      );

  DetailedLineRangeMapping withInnerChangesFromLineRanges() =>
      DetailedLineRangeMapping(original, modified, <RangeMapping>[toRangeMapping()]);
}

/// Maps a range in the original text model to a range in the modified model.
class RangeMapping {
  static List<RangeMapping> fromEdit(TextEdit edit) {
    final List<Range> newRanges = edit.getNewRanges();
    return edit.replacements
        .asMap()
        .entries
        .map((MapEntry<int, TextReplacement> e) => RangeMapping(
              e.value.range,
              newRanges[e.key],
            ))
        .toList();
  }

  static RangeMapping fromEditJoin(TextEdit edit) => joinStatic(fromEdit(edit));

  static RangeMapping joinStatic(List<RangeMapping> rangeMappings) {
    if (rangeMappings.isEmpty) {
      throw BugIndicatingError('Cannot join an empty list of range mappings');
    }
    RangeMapping result = rangeMappings[0];
    for (int i = 1; i < rangeMappings.length; i++) {
      result = result.join(rangeMappings[i]);
    }
    return result;
  }

  static void assertSorted(List<RangeMapping> rangeMappings) {
    for (int i = 1; i < rangeMappings.length; i++) {
      final RangeMapping previous = rangeMappings[i - 1];
      final RangeMapping current = rangeMappings[i];
      if (!(
          previous.originalRange.getEndPosition().isBeforeOrEqual(
                  current.originalRange.getStartPosition()) &&
              previous.modifiedRange.getEndPosition().isBeforeOrEqual(
                  current.modifiedRange.getStartPosition()))) {
        throw BugIndicatingError('Range mappings must be sorted');
      }
    }
  }

  final Range originalRange;
  final Range modifiedRange;

  RangeMapping(this.originalRange, this.modifiedRange);

  @override
  String toString() => '{${originalRange.toString()}->${modifiedRange.toString()}}';

  RangeMapping flip() => RangeMapping(modifiedRange, originalRange);

  /// Creates a single text edit describing the change from original to modified.
  TextReplacement toTextEdit(AbstractText modified) =>
      TextReplacement(originalRange, modified.getValueOfRange(modifiedRange));

  RangeMapping join(RangeMapping other) => RangeMapping(
        originalRange.plusRange(other.originalRange),
        modifiedRange.plusRange(other.modifiedRange),
      );
}

List<DetailedLineRangeMapping> lineRangeMappingFromRangeMappings(
  List<RangeMapping> alignments,
  AbstractText originalLines,
  AbstractText modifiedLines, [
  bool dontAssertStartLine = false,
]) {
  final List<DetailedLineRangeMapping> changes = <DetailedLineRangeMapping>[];
  for (final List<DetailedLineRangeMapping> g in groupAdjacentBy<DetailedLineRangeMapping>(
    alignments
        .map((RangeMapping a) =>
            getLineRangeMapping(a, originalLines, modifiedLines))
        .toList(),
    (DetailedLineRangeMapping a1, DetailedLineRangeMapping a2) =>
        a1.original.intersectsOrTouches(a2.original) ||
        a1.modified.intersectsOrTouches(a2.modified),
  )) {
    final DetailedLineRangeMapping first = g[0];
    final DetailedLineRangeMapping last = g[g.length - 1];
    changes.add(DetailedLineRangeMapping(
      first.original.join(last.original),
      first.modified.join(last.modified),
      g.map((DetailedLineRangeMapping a) => a.innerChanges![0]).toList(),
    ));
  }

  assertFn(() {
    if (!dontAssertStartLine && changes.isNotEmpty) {
      if (changes[0].modified.startLineNumber !=
          changes[0].original.startLineNumber) {
        return false;
      }
      if (modifiedLines.length.lineCount -
              changes[changes.length - 1].modified.endLineNumberExclusive !=
          originalLines.length.lineCount -
              changes[changes.length - 1].original.endLineNumberExclusive) {
        return false;
      }
    }
    return checkAdjacentItems<DetailedLineRangeMapping>(
      changes,
      (DetailedLineRangeMapping m1, DetailedLineRangeMapping m2) =>
          m2.original.startLineNumber - m1.original.endLineNumberExclusive ==
                  m2.modified.startLineNumber -
                      m1.modified.endLineNumberExclusive &&
              m1.original.endLineNumberExclusive < m2.original.startLineNumber &&
              m1.modified.endLineNumberExclusive < m2.modified.startLineNumber,
    );
  });

  return changes;
}

DetailedLineRangeMapping getLineRangeMapping(
  RangeMapping rangeMapping,
  AbstractText originalLines,
  AbstractText modifiedLines,
) {
  int lineStartDelta = 0;
  int lineEndDelta = 0;

  if (rangeMapping.modifiedRange.endColumn == 1 &&
      rangeMapping.originalRange.endColumn == 1 &&
      rangeMapping.originalRange.startLineNumber + lineStartDelta <=
          rangeMapping.originalRange.endLineNumber &&
      rangeMapping.modifiedRange.startLineNumber + lineStartDelta <=
          rangeMapping.modifiedRange.endLineNumber) {
    lineEndDelta = -1;
  }

  if (rangeMapping.modifiedRange.startColumn - 1 >=
          modifiedLines.getLineLength(rangeMapping.modifiedRange.startLineNumber) &&
      rangeMapping.originalRange.startColumn - 1 >=
          originalLines.getLineLength(rangeMapping.originalRange.startLineNumber) &&
      rangeMapping.originalRange.startLineNumber <=
          rangeMapping.originalRange.endLineNumber + lineEndDelta &&
      rangeMapping.modifiedRange.startLineNumber <=
          rangeMapping.modifiedRange.endLineNumber + lineEndDelta) {
    lineStartDelta = 1;
  }

  final LineRange originalLineRange = LineRange(
    rangeMapping.originalRange.startLineNumber + lineStartDelta,
    rangeMapping.originalRange.endLineNumber + 1 + lineEndDelta,
  );
  final LineRange modifiedLineRange = LineRange(
    rangeMapping.modifiedRange.startLineNumber + lineStartDelta,
    rangeMapping.modifiedRange.endLineNumber + 1 + lineEndDelta,
  );

  return DetailedLineRangeMapping(
      originalLineRange, modifiedLineRange, <RangeMapping>[rangeMapping]);
}

LineRangeMapping lineRangeMappingFromChange(IChange change) {
  late final LineRange originalRange;
  if (change.originalEndLineNumber == 0) {
    originalRange = LineRange(change.originalStartLineNumber + 1,
        change.originalStartLineNumber + 1);
  } else {
    originalRange = LineRange(change.originalStartLineNumber,
        change.originalEndLineNumber + 1);
  }

  late final LineRange modifiedRange;
  if (change.modifiedEndLineNumber == 0) {
    modifiedRange = LineRange(change.modifiedStartLineNumber + 1,
        change.modifiedStartLineNumber + 1);
  } else {
    modifiedRange = LineRange(change.modifiedStartLineNumber,
        change.modifiedEndLineNumber + 1);
  }

  return LineRangeMapping(originalRange, modifiedRange);
}
