// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/browser/model/
//   computeGhostText.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `GhostText` / `GhostTextPart` come from `ghostText.ts`, not yet ported;
//    their two fields used here (lineNumber/parts and column/text/preview) are
//    carried locally, 1:1.
//  * `ITextModel` is erased; reused from `singleTextEditHelpers.dart`.
//  * `LcsDiff` / `getLeadingWhitespace` / `singleTextRemoveCommonPrefix` are
//    reused from the real port.
//  * JS `Position.delta(0, n)` maps to Dart named args.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../../../../base/common/diff/diff.dart'
    show ISequence, LcsDiff;
import '../../../../../base/common/diff/diffChange.dart' show DiffChange;
import '../../../../../base/common/strings.dart' show getLeadingWhitespace;
import '../../../../common/core/edits/textEdit.dart' show TextReplacement;
import '../../../../common/core/position.dart' show Position;
import '../../../../common/core/range.dart' show Range;
import 'singleTextEditHelpers.dart'
    show ITextModelForSingleTextEditHelpers, singleTextRemoveCommonPrefix;

// `GhostText` / `GhostTextPart` are defined in the canonical ghostText.dart.
import 'ghostText.dart' show GhostText, GhostTextPart;
export 'ghostText.dart' show GhostText, GhostTextPart;

/// 1:1: cache entry for [cachingDiff].
class _LastRequest {
  final String originalValue;
  final String newValue;
  final List<DiffChange>? changes;

  _LastRequest(this.originalValue, this.newValue, this.changes);
}

_LastRequest? _lastRequest;

/// 1:1: `computeGhostText`.
///
/// [mode] is one of `'prefix'`, `'subword'`, `'subwordSmart'`.
GhostText? computeGhostText(
  TextReplacement edit,
  ITextModelForSingleTextEditHelpers model,
  String mode, [
  Position? cursorPosition,
  int previewSuffixLength = 0,
]) {
  TextReplacement e = singleTextRemoveCommonPrefix(edit, model);

  if (e.range.endLineNumber != e.range.startLineNumber) {
    // Might span multiple lines, but the first lines must be a common prefix.
    return null;
  }

  final String sourceLine = (model as dynamic).getLineContent(
    e.range.startLineNumber,
  ) as String;
  final int sourceIndentationLength =
      getLeadingWhitespace(sourceLine).length;

  final bool suggestionTouchesIndentation =
      e.range.startColumn - 1 <= sourceIndentationLength;
  if (suggestionTouchesIndentation) {
    final int suggestionAddedIndentationLength =
        getLeadingWhitespace(e.text).length;

    final String replacedIndentation = sourceLine.substring(
      e.range.startColumn - 1,
      sourceIndentationLength,
    );

    final Position startPosition = e.range.getStartPosition();
    final Position endPosition = e.range.getEndPosition();
    final Position newStartPosition =
        startPosition.column + replacedIndentation.length <= endPosition.column
            ? startPosition.delta(deltaColumn: replacedIndentation.length)
            : endPosition;
    final Range rangeThatDoesNotReplaceIndentation =
        Range.fromPositions(newStartPosition, end: endPosition);

    final String suggestionWithoutIndentationChange =
        e.text.startsWith(replacedIndentation)
            ? e.text.substring(replacedIndentation.length)
            : e.text.substring(suggestionAddedIndentationLength);

    e = TextReplacement(
      rangeThatDoesNotReplaceIndentation,
      suggestionWithoutIndentationChange,
    );
  }

  // Single-line string.
  final String valueToBeReplaced = model.getValueInRange(e.range);
  final List<DiffChange>? changes = cachingDiff(valueToBeReplaced, e.text);
  if (changes == null) {
    // No ghost text if diff would be too slow to compute.
    return null;
  }

  final int lineNumber = e.range.startLineNumber;
  final List<GhostTextPart> parts = <GhostTextPart>[];

  if (mode == 'prefix') {
    final List<DiffChange> filteredChanges = changes
        .where((DiffChange c) => c.originalLength == 0)
        .toList();
    if (filteredChanges.length > 1 ||
        (filteredChanges.length == 1 &&
            filteredChanges[0].originalStart != valueToBeReplaced.length)) {
      // Prefixes only have a single change at the end.
      return null;
    }
  }

  final int previewStartInCompletionText =
      e.text.length - previewSuffixLength;

  for (final DiffChange c in changes) {
    final int insertColumn =
        e.range.startColumn + c.originalStart + c.originalLength;

    if (mode == 'subwordSmart' &&
        cursorPosition != null &&
        cursorPosition.lineNumber == e.range.startLineNumber &&
        insertColumn < cursorPosition.column) {
      // No ghost text before cursor.
      return null;
    }

    if (c.originalLength > 0) {
      return null;
    }
    if (c.modifiedLength == 0) {
      continue;
    }

    final int modifiedEnd = c.modifiedStart + c.modifiedLength;
    final int nonPreviewTextEnd = _max(
      c.modifiedStart,
      _min(modifiedEnd, previewStartInCompletionText),
    );
    final String nonPreviewText =
        e.text.substring(c.modifiedStart, nonPreviewTextEnd);
    final String italicText = e.text.substring(
      nonPreviewTextEnd,
      _max(c.modifiedStart, modifiedEnd),
    );

    if (nonPreviewText.isNotEmpty) {
      parts.add(GhostTextPart(insertColumn, nonPreviewText, false));
    }
    if (italicText.isNotEmpty) {
      parts.add(GhostTextPart(insertColumn, italicText, true));
    }
  }

  return GhostText(lineNumber, parts);
}

/// 1:1: `cachingDiff` (single-entry cache).
List<DiffChange>? cachingDiff(String originalValue, String newValue) {
  final _LastRequest? last = _lastRequest;
  if (last != null &&
      last.originalValue == originalValue &&
      last.newValue == newValue) {
    return last.changes;
  }

  List<DiffChange>? changes = smartDiff(originalValue, newValue, true);
  if (changes != null) {
    final int deletedChars = deletedCharacters(changes);
    if (deletedChars > 0) {
      // For performance, don't compute diff if there is nothing to improve.
      final List<DiffChange>? newChanges =
          smartDiff(originalValue, newValue, false);
      if (newChanges != null &&
          deletedCharacters(newChanges) < deletedChars) {
        changes = newChanges;
      }
    }
  }
  _lastRequest = _LastRequest(originalValue, newValue, changes);
  return changes;
}

int deletedCharacters(List<DiffChange> changes) {
  int sum = 0;
  for (final DiffChange c in changes) {
    sum += c.originalLength.toInt();
  }
  return sum;
}

/// 1:1: `ISequence` carrying a precomputed `Int32List`.
class _ElementsSequence implements ISequence {
  final Int32List elements;
  _ElementsSequence(this.elements);

  @override
  Object getElements() => elements;

  @override
  String? getStrictElement(int index) => null;
}

/// 1:1: `smartDiff` — bracket-aware LCS diff.
List<DiffChange>? smartDiff(
  String originalValue,
  String newValue,
  bool smartBracketMatching,
) {
  if (originalValue.length > 5000 || newValue.length > 5000) {
    // Don't work on strings that are too big.
    return null;
  }

  int getMaxCharCode(String val) {
    int maxCharCode = 0;
    for (int i = 0; i < val.length; i++) {
      final int charCode = val.codeUnitAt(i);
      if (charCode > maxCharCode) maxCharCode = charCode;
    }
    return maxCharCode;
  }

  final int maxCharCode =
      _max(getMaxCharCode(originalValue), getMaxCharCode(newValue));

  int getUniqueCharCode(int id) {
    if (id < 0) throw StateError('unexpected');
    return maxCharCode + id + 1;
  }

  Int32List getElements(String source) {
    int level = 0;
    int group = 0;
    final Int32List characters = Int32List(source.length);
    for (int i = 0; i < source.length; i++) {
      if (smartBracketMatching && source[i] == '(') {
        final int id = group * 100 + level;
        characters[i] = getUniqueCharCode(2 * id);
        level++;
      } else if (smartBracketMatching && source[i] == ')') {
        level = _max(level - 1, 0);
        final int id = group * 100 + level;
        characters[i] = getUniqueCharCode(2 * id + 1);
        if (level == 0) group++;
      } else {
        characters[i] = source.codeUnitAt(i);
      }
    }
    return characters;
  }

  final Int32List elements1 = getElements(originalValue);
  final Int32List elements2 = getElements(newValue);
  return LcsDiff(
    _ElementsSequence(elements1),
    _ElementsSequence(elements2),
  ).ComputeDiff(false).changes;
}

int _max(int a, int b) => a > b ? a : b;
int _min(int a, int b) => a < b ? a : b;
