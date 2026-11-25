// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/model/indentationGuesser.ts (221 lines).
//
// `guessIndentation` inspects at most the first 10k lines of a text buffer and
// scores the observed indentation deltas to pick `tabSize` / `insertSpaces`.
//
// Adaptations:
//   - `ITextBuffer` is an erased interface; the buffer is `Object?` and the four
//     members used (`getLineCount`, `getLineLength`, `getLineContent`,
//     `getLineCharCode`) are read dynamically.
//   - `String.prototype.charCodeAt` -> `String.codeUnitAt`.
//   - `IGuessedIndentation` is a plain carrier class (the TS interface has no
//     runtime, but the returned object literal needs a shape).
//   - The local `spacesDiff` counters inside `spacesDiff()` shadow the function
//     name in TS; the port renames the function to `_spacesDiff` (same body).
// ---------------------------------------------------------------------------

import 'dart:math' show min;

import '../../../base/common/charCode.dart' show CharCode;

class _SpacesDiffResult {
  int spacesDiff = 0;
  bool looksLikeAlignment = false;
}

/// Compute the diff in spaces between two line's indentation.
void _spacesDiff(
    String a, int aLength, String b, int bLength, _SpacesDiffResult result) {
  result.spacesDiff = 0;
  result.looksLikeAlignment = false;

  // This can go both ways (e.g.):
  //  - a: "\t"
  //  - b: "\t    "
  //  => This should count 1 tab and 4 spaces

  int i;

  for (i = 0; i < aLength && i < bLength; i++) {
    final int aCharCode = a.codeUnitAt(i);
    final int bCharCode = b.codeUnitAt(i);

    if (aCharCode != bCharCode) {
      break;
    }
  }

  int aSpacesCnt = 0, aTabsCount = 0;
  for (int j = i; j < aLength; j++) {
    final int aCharCode = a.codeUnitAt(j);
    if (aCharCode == CharCode.Space) {
      aSpacesCnt++;
    } else {
      aTabsCount++;
    }
  }

  int bSpacesCnt = 0, bTabsCount = 0;
  for (int j = i; j < bLength; j++) {
    final int bCharCode = b.codeUnitAt(j);
    if (bCharCode == CharCode.Space) {
      bSpacesCnt++;
    } else {
      bTabsCount++;
    }
  }

  if (aSpacesCnt > 0 && aTabsCount > 0) {
    return;
  }
  if (bSpacesCnt > 0 && bTabsCount > 0) {
    return;
  }

  final int tabsDiff = (aTabsCount - bTabsCount).abs();
  final int spacesDiff = (aSpacesCnt - bSpacesCnt).abs();

  if (tabsDiff == 0) {
    // check if the indentation difference might be caused by alignment reasons
    // sometime folks like to align their code, but this should not be used as a hint
    result.spacesDiff = spacesDiff;

    if (spacesDiff > 0 &&
        0 <= bSpacesCnt - 1 &&
        bSpacesCnt - 1 < a.length &&
        bSpacesCnt < b.length) {
      if (b.codeUnitAt(bSpacesCnt) != CharCode.Space &&
          a.codeUnitAt(bSpacesCnt - 1) == CharCode.Space) {
        if (a.codeUnitAt(a.length - 1) == CharCode.Comma) {
          // This looks like an alignment desire: e.g.
          // const a = b + c,
          //       d = b - c;
          result.looksLikeAlignment = true;
        }
      }
    }
    return;
  }
  if (spacesDiff % tabsDiff == 0) {
    result.spacesDiff = spacesDiff ~/ tabsDiff;
    return;
  }
}

/// Result for a guessIndentation
class IGuessedIndentation {
  IGuessedIndentation(this.tabSize, this.insertSpaces);

  /// If indentation is based on spaces (`insertSpaces` = true), then what is the
  /// number of spaces that make an indent?
  final int tabSize;

  /// Is indentation based on spaces?
  final bool insertSpaces;
}

IGuessedIndentation guessIndentation(
    Object? source, int defaultTabSize, bool defaultInsertSpaces) {
  final dynamic buffer = source;

  // Look at most at the first 10k lines
  final int linesCount = min(buffer.getLineCount() as int, 10000);

  int linesIndentedWithTabsCount = 0; // number of lines that contain at least one tab in indentation
  int linesIndentedWithSpacesCount = 0; // number of lines that contain only spaces in indentation

  String previousLineText = ''; // content of latest line that contained non-whitespace chars
  int previousLineIndentation = 0; // index at which latest line contained the first non-whitespace char

  const List<int> ALLOWED_TAB_SIZE_GUESSES = <int>[
    2,
    4,
    6,
    8,
    3,
    5,
    7
  ]; // prefer even guesses for `tabSize`, limit to [2, 8].
  const int MAX_ALLOWED_TAB_SIZE_GUESS = 8; // max(ALLOWED_TAB_SIZE_GUESSES) = 8

  final List<int> spacesDiffCount = <int>[0, 0, 0, 0, 0, 0, 0, 0, 0]; // `tabSize` scores
  final _SpacesDiffResult tmp = _SpacesDiffResult();

  for (int lineNumber = 1; lineNumber <= linesCount; lineNumber++) {
    final int currentLineLength = buffer.getLineLength(lineNumber) as int;
    final String currentLineText = buffer.getLineContent(lineNumber) as String;

    // if the text buffer is chunk based, so long lines are cons-string, v8 will flattern the string when we check charCode.
    // checking charCode on chunks directly is cheaper.
    final bool useCurrentLineText = (currentLineLength <= 65536);

    bool currentLineHasContent = false; // does `currentLineText` contain non-whitespace chars
    int currentLineIndentation = 0; // index at which `currentLineText` contains the first non-whitespace char
    int currentLineSpacesCount = 0; // count of spaces found in `currentLineText` indentation
    int currentLineTabsCount = 0; // count of tabs found in `currentLineText` indentation
    for (int j = 0, lenJ = currentLineLength; j < lenJ; j++) {
      final int charCode = useCurrentLineText
          ? currentLineText.codeUnitAt(j)
          : buffer.getLineCharCode(lineNumber, j) as int;

      if (charCode == CharCode.Tab) {
        currentLineTabsCount++;
      } else if (charCode == CharCode.Space) {
        currentLineSpacesCount++;
      } else {
        // Hit non whitespace character on this line
        currentLineHasContent = true;
        currentLineIndentation = j;
        break;
      }
    }

    // Ignore empty or only whitespace lines
    if (!currentLineHasContent) {
      continue;
    }

    if (currentLineTabsCount > 0) {
      linesIndentedWithTabsCount++;
    } else if (currentLineSpacesCount > 1) {
      linesIndentedWithSpacesCount++;
    }

    _spacesDiff(previousLineText, previousLineIndentation, currentLineText,
        currentLineIndentation, tmp);

    if (tmp.looksLikeAlignment) {
      // if defaultInsertSpaces === true && the spaces count == tabSize, we may want to count it as valid indentation
      //
      // - item1
      //   - item2
      //
      // otherwise skip this line entirely
      //
      // const a = 1,
      //       b = 2;

      if (!(defaultInsertSpaces && defaultTabSize == tmp.spacesDiff)) {
        continue;
      }
    }

    final int currentSpacesDiff = tmp.spacesDiff;
    if (currentSpacesDiff <= MAX_ALLOWED_TAB_SIZE_GUESS) {
      spacesDiffCount[currentSpacesDiff]++;
    }

    previousLineText = currentLineText;
    previousLineIndentation = currentLineIndentation;
  }

  bool insertSpaces = defaultInsertSpaces;
  if (linesIndentedWithTabsCount != linesIndentedWithSpacesCount) {
    insertSpaces = (linesIndentedWithTabsCount < linesIndentedWithSpacesCount);
  }

  int tabSize = defaultTabSize;

  // Guess tabSize only if inserting spaces...
  if (insertSpaces) {
    int tabSizeScore = 0;
    for (final int possibleTabSize in ALLOWED_TAB_SIZE_GUESSES) {
      final int possibleTabSizeScore = spacesDiffCount[possibleTabSize];
      if (possibleTabSizeScore > tabSizeScore) {
        tabSizeScore = possibleTabSizeScore;
        tabSize = possibleTabSize;
      }
    }

    // Let a tabSize of 2 win over 4 only if it has at least 2/3 of the occurrences of 4
    // This helps detect 2-space indentation in cases like YAML files where there might be
    // some 4-space diffs from deeper nesting, while still preferring 4 when it's clearly predominant
    if (tabSize == 4 &&
        spacesDiffCount[4] > 0 &&
        spacesDiffCount[2] > 0 &&
        spacesDiffCount[2] >= spacesDiffCount[4] * 2 / 3) {
      tabSize = 2;
    }
  }

  return IGuessedIndentation(tabSize, insertSpaces);
}