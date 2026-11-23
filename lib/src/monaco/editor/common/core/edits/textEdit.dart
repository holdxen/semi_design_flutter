// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/edits/textEdit.ts
// Translated 1:1 from TypeScript.
//   - `Position | Range` union -> `Object` with `isPosition` checks (source
//     uses `instanceof Position`).
//   - `Number.MAX_SAFE_INTEGER` -> 0x1FFFFFFFFFFFFF.
//   - `replaceAll('\r\n', '\n')` -> Dart `replaceAll`.
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart' as arrays;
import '../../../../base/common/assert.dart' as asserts;
import '../../../../base/common/equals.dart' as equalsLib;
import '../../../../base/common/errors.dart';
import '../../../../base/common/strings.dart' as strings;
import '../editOperation.dart';
import '../position.dart';
import '../range.dart';
import '../text/abstractText.dart';
import '../text/textLength.dart';
import 'stringEdit.dart';

const int _maxSafeInteger = 0x1FFFFFFFFFFFFF;

/// 1:1: `rangeFromPositions` (module-local helper)
Range _rangeFromPositions(Position start, Position end) {
  if (start.lineNumber == end.lineNumber && start.column == _maxSafeInteger) {
    return Range.fromPositions(end, end: end);
  } else if (!start.isBeforeOrEqual(end)) {
    throw BugIndicatingError('start must be before end');
  }
  return Range(start.lineNumber, start.column, end.lineNumber, end.column);
}

/// 1:1: `TextEdit`
class TextEdit {
  final List<TextReplacement> replacements;

  TextEdit(this.replacements) {
    asserts.assertFn(() => asserts.checkAdjacentItems(
      replacements,
      (TextReplacement a, TextReplacement b) => a.range.getEndPosition().isBeforeOrEqual(b.range.getStartPosition()),
    ));
  }

  /// 1:1: `static fromStringEdit`
  static TextEdit fromStringEdit(BaseStringEdit edit, AbstractText initialState) {
    final List<TextReplacement> edits = <TextReplacement>[];
    for (final dynamic e in edit.replacements) {
      edits.add(TextReplacement.fromStringReplacement(e as StringReplacement, initialState));
    }
    return TextEdit(edits);
  }

  static TextEdit replace(Range originalRange, String newText) =>
      TextEdit(<TextReplacement>[TextReplacement(originalRange, newText)]);

  static TextEdit delete(Range range) => TextEdit(<TextReplacement>[TextReplacement.delete(range)]);

  static TextEdit insert(Position position, String newText) =>
      TextEdit(<TextReplacement>[TextReplacement(Range.fromPositions(position, end: position), newText)]);

  static TextEdit fromParallelReplacementsUnsorted(List<TextReplacement> replacements) {
    final List<TextReplacement> r = replacements.toList()
      ..sort(arrays.compareBy<TextReplacement, Range>(
        (TextReplacement i) => i.range,
        (Range a, Range b) => Range.compareRangesUsingStarts(a, b),
      ));
    return TextEdit(r);
  }

  /// 1:1: `normalize`
  TextEdit normalize() {
    final List<TextReplacement> replacements = <TextReplacement>[];
    for (final TextReplacement r in this.replacements) {
      if (replacements.isNotEmpty &&
          replacements.last.range.getEndPosition().equals(r.range.getStartPosition())) {
        final TextReplacement last = replacements.last;
        replacements[replacements.length - 1] = TextReplacement(last.range.plusRange(r.range), last.text + r.text);
      } else if (!r.isEmpty) {
        replacements.add(r);
      }
    }
    return TextEdit(replacements);
  }

  /// 1:1: `mapPosition`
  Object mapPosition(Position position) {
    int lineDelta = 0;
    int curLine = 0;
    int columnDeltaInCurLine = 0;

    for (final TextReplacement replacement in this.replacements) {
      final Position start = replacement.range.getStartPosition();
      if (position.isBeforeOrEqual(start)) {
        break;
      }
      final Position end = replacement.range.getEndPosition();
      final TextLength len = TextLength.ofText(replacement.text);
      if (position.isBefore(end)) {
        final Position startPos = Position(
          start.lineNumber + lineDelta,
          start.column + (start.lineNumber + lineDelta == curLine ? columnDeltaInCurLine : 0),
        );
        final Position endPos = len.addToPosition(startPos);
        return _rangeFromPositions(startPos, endPos);
      }

      if (start.lineNumber + lineDelta != curLine) {
        columnDeltaInCurLine = 0;
      }
      lineDelta += len.lineCount - (replacement.range.endLineNumber - replacement.range.startLineNumber);
      if (len.lineCount == 0) {
        if (end.lineNumber != start.lineNumber) {
          columnDeltaInCurLine += len.columnCount - (end.column - 1);
        } else {
          columnDeltaInCurLine += len.columnCount - (end.column - start.column);
        }
      } else {
        columnDeltaInCurLine = len.columnCount;
      }
      curLine = end.lineNumber + lineDelta;
    }

    return Position(
      position.lineNumber + lineDelta,
      position.column + (position.lineNumber + lineDelta == curLine ? columnDeltaInCurLine : 0),
    );
  }

  /// 1:1: `mapRange`
  Range mapRange(Range range) {
    Position getStart(Object p) => p is Position ? p : (p as Range).getStartPosition();
    Position getEnd(Object p) => p is Position ? p : (p as Range).getEndPosition();

    final Position start = getStart(this.mapPosition(range.getStartPosition()));
    final Position end = getEnd(this.mapPosition(range.getEndPosition()));
    return _rangeFromPositions(start, end);
  }

  /// 1:1: `inverseMapPosition`
  Object inverseMapPosition(Position positionAfterEdit, AbstractText doc) =>
      this.inverse(doc).mapPosition(positionAfterEdit);

  /// 1:1: `inverseMapRange`
  Range inverseMapRange(Range range, AbstractText doc) => this.inverse(doc).mapRange(range);

  /// 1:1: `apply`
  String apply(AbstractText text) {
    String result = '';
    Position lastEditEnd = Position(1, 1);
    for (final TextReplacement replacement in this.replacements) {
      final Range editRange = replacement.range;
      final Position editStart = editRange.getStartPosition();
      final Position editEnd = editRange.getEndPosition();
      final Range r = _rangeFromPositions(lastEditEnd, editStart);
      if (!r.isEmpty()) {
        result += text.getValueOfRange(r);
      }
      result += replacement.text;
      lastEditEnd = editEnd;
    }
    final Range r = _rangeFromPositions(lastEditEnd, text.endPositionExclusive);
    if (!r.isEmpty()) {
      result += text.getValueOfRange(r);
    }
    return result;
  }

  /// 1:1: `applyToString`
  String applyToString(String str) => this.apply(StringText(str));

  /// 1:1: `inverse`
  TextEdit inverse(AbstractText doc) {
    final List<Range> ranges = this.getNewRanges();
    return TextEdit(this.replacements
        .asMap()
        .entries
        .map((MapEntry<int, TextReplacement> entry) =>
            TextReplacement(ranges[entry.key], doc.getValueOfRange(entry.value.range)))
        .toList());
  }

  /// 1:1: `getNewRanges`
  List<Range> getNewRanges() {
    final List<Range> newRanges = <Range>[];
    int previousEditEndLineNumber = 0;
    int lineOffset = 0;
    int columnOffset = 0;
    for (final TextReplacement replacement in this.replacements) {
      final TextLength textLength = TextLength.ofText(replacement.text);
      final Position newRangeStart = Position(
        replacement.range.startLineNumber + lineOffset,
        replacement.range.startColumn +
            (replacement.range.startLineNumber == previousEditEndLineNumber ? columnOffset : 0),
      );
      final Range newRange = textLength.createRange(newRangeStart);
      newRanges.add(newRange);
      lineOffset = newRange.endLineNumber - replacement.range.endLineNumber;
      columnOffset = newRange.endColumn - replacement.range.endColumn;
      previousEditEndLineNumber = replacement.range.endLineNumber;
    }
    return newRanges;
  }

  /// 1:1: `toReplacement`
  TextReplacement toReplacement(AbstractText text) {
    if (this.replacements.isEmpty) {
      throw BugIndicatingError();
    }
    if (this.replacements.length == 1) {
      return this.replacements[0];
    }
    final Position startPos = this.replacements.first.range.getStartPosition();
    final Position endPos = this.replacements.last.range.getEndPosition();
    String newText = '';
    for (int i = 0; i < this.replacements.length; i++) {
      final TextReplacement curEdit = this.replacements[i];
      newText += curEdit.text;
      if (i < this.replacements.length - 1) {
        final TextReplacement nextEdit = this.replacements[i + 1];
        final Range gapRange = Range.fromPositions(curEdit.range.getEndPosition(), end: nextEdit.range.getStartPosition());
        newText += text.getValueOfRange(gapRange);
      }
    }
    return TextReplacement(Range.fromPositions(startPos, end: endPos), newText);
  }

  /// 1:1: `equals`
  bool equals(TextEdit other) =>
      arrays.equals<TextReplacement>(this.replacements, other.replacements, (TextReplacement a, TextReplacement b) => a.equals(b));

  /// 1:1: `compose`
  TextEdit compose(TextEdit other) {
    final TextEdit edits1 = this.normalize();
    final TextEdit edits2 = other.normalize();

    if (edits1.replacements.isEmpty) {
      return edits2;
    }
    if (edits2.replacements.isEmpty) {
      return edits1;
    }

    final List<TextReplacement> resultReplacements = <TextReplacement>[];

    int edit1Idx = 0;
    int lastEdit1EndS0Line = 1;
    int lastEdit1EndS0Col = 1;

    int headSrcRangeStartLine = 0;
    int headSrcRangeStartCol = 0;
    int headSrcRangeEndLine = 0;
    int headSrcRangeEndCol = 0;
    String? headText;
    int headLengthLine = 0;
    int headLengthCol = 0;

    bool headHasValue = false;
    bool headIsInfinite = false;

    int currentPosInS1Line = 1;
    int currentPosInS1Col = 1;

    void ensureHead() {
      if (headHasValue) {
        return;
      }
      if (edit1Idx < edits1.replacements.length) {
        final TextReplacement nextEdit = edits1.replacements[edit1Idx];
        final Position nextEditStart = nextEdit.range.getStartPosition();
        final bool gapIsEmpty = (lastEdit1EndS0Line == nextEditStart.lineNumber) && (lastEdit1EndS0Col == nextEditStart.column);
        if (!gapIsEmpty) {
          headSrcRangeStartLine = lastEdit1EndS0Line;
          headSrcRangeStartCol = lastEdit1EndS0Col;
          headSrcRangeEndLine = nextEditStart.lineNumber;
          headSrcRangeEndCol = nextEditStart.column;
          headText = null;
          if (lastEdit1EndS0Line == nextEditStart.lineNumber) {
            headLengthLine = 0;
            headLengthCol = nextEditStart.column - lastEdit1EndS0Col;
          } else {
            headLengthLine = nextEditStart.lineNumber - lastEdit1EndS0Line;
            headLengthCol = nextEditStart.column - 1;
          }
          headHasValue = true;
          lastEdit1EndS0Line = nextEditStart.lineNumber;
          lastEdit1EndS0Col = nextEditStart.column;
        } else {
          final Position nextEditEnd = nextEdit.range.getEndPosition();
          headSrcRangeStartLine = nextEditStart.lineNumber;
          headSrcRangeStartCol = nextEditStart.column;
          headSrcRangeEndLine = nextEditEnd.lineNumber;
          headSrcRangeEndCol = nextEditEnd.column;
          headText = nextEdit.text;
          int line = 0;
          int column = 0;
          final String text = nextEdit.text;
          for (int i = 0; i < text.length; i++) {
            if (text.codeUnitAt(i) == 10) {
              line++;
              column = 0;
            } else {
              column++;
            }
          }
          headLengthLine = line;
          headLengthCol = column;
          headHasValue = true;
          lastEdit1EndS0Line = nextEditEnd.lineNumber;
          lastEdit1EndS0Col = nextEditEnd.column;
          edit1Idx++;
        }
      } else {
        headIsInfinite = true;
        headSrcRangeStartLine = lastEdit1EndS0Line;
        headSrcRangeStartCol = lastEdit1EndS0Col;
        headHasValue = true;
      }
    }

    List<String> splitText(String text, int lenLine, int lenCol) {
      if (lenLine == 0 && lenCol == 0) {
        return <String>['', text];
      }
      int line = 0;
      int offset = 0;
      while (line < lenLine) {
        final int idx = text.indexOf('\n', offset);
        if (idx == -1) {
          throw BugIndicatingError('Text length mismatch');
        }
        offset = idx + 1;
        line++;
      }
      offset += lenCol;
      return <String>[text.substring(0, offset), text.substring(offset)];
    }

    for (final TextReplacement r2 in edits2.replacements) {
      final Position r2Start = r2.range.getStartPosition();
      final Position r2End = r2.range.getEndPosition();

      while (true) {
        if (currentPosInS1Line == r2Start.lineNumber && currentPosInS1Col == r2Start.column) {
          break;
        }
        ensureHead();
        if (headIsInfinite) {
          late final int distLine;
          late final int distCol;
          if (currentPosInS1Line == r2Start.lineNumber) {
            distLine = 0;
            distCol = r2Start.column - currentPosInS1Col;
          } else {
            distLine = r2Start.lineNumber - currentPosInS1Line;
            distCol = r2Start.column - 1;
          }
          currentPosInS1Line = r2Start.lineNumber;
          currentPosInS1Col = r2Start.column;
          if (distLine == 0) {
            headSrcRangeStartCol += distCol;
          } else {
            headSrcRangeStartLine += distLine;
            headSrcRangeStartCol = distCol + 1;
          }
          break;
        }

        late final int headEndInS1Line;
        late final int headEndInS1Col;
        if (headLengthLine == 0) {
          headEndInS1Line = currentPosInS1Line;
          headEndInS1Col = currentPosInS1Col + headLengthCol;
        } else {
          headEndInS1Line = currentPosInS1Line + headLengthLine;
          headEndInS1Col = headLengthCol + 1;
        }

        bool r2StartIsBeforeHeadEnd = false;
        if (r2Start.lineNumber < headEndInS1Line) {
          r2StartIsBeforeHeadEnd = true;
        } else if (r2Start.lineNumber == headEndInS1Line) {
          r2StartIsBeforeHeadEnd = r2Start.column < headEndInS1Col;
        }

        if (r2StartIsBeforeHeadEnd) {
          late final int splitLenLine;
          late final int splitLenCol;
          if (currentPosInS1Line == r2Start.lineNumber) {
            splitLenLine = 0;
            splitLenCol = r2Start.column - currentPosInS1Col;
          } else {
            splitLenLine = r2Start.lineNumber - currentPosInS1Line;
            splitLenCol = r2Start.column - 1;
          }
          late final int remainingLenLine;
          late final int remainingLenCol;
          if (splitLenLine == headLengthLine) {
            remainingLenLine = 0;
            remainingLenCol = headLengthCol - splitLenCol;
          } else {
            remainingLenLine = headLengthLine - splitLenLine;
            remainingLenCol = headLengthCol;
          }

          if (headText != null) {
            final List<String> parts = splitText(headText!, splitLenLine, splitLenCol);
            resultReplacements.add(TextReplacement(
              Range(headSrcRangeStartLine, headSrcRangeStartCol, headSrcRangeEndLine, headSrcRangeEndCol),
              parts[0],
            ));
            headText = parts[1];
            headLengthLine = remainingLenLine;
            headLengthCol = remainingLenCol;
            headSrcRangeStartLine = headSrcRangeEndLine;
            headSrcRangeStartCol = headSrcRangeEndCol;
          } else {
            late final int splitPosLine;
            late final int splitPosCol;
            if (splitLenLine == 0) {
              splitPosLine = headSrcRangeStartLine;
              splitPosCol = headSrcRangeStartCol + splitLenCol;
            } else {
              splitPosLine = headSrcRangeStartLine + splitLenLine;
              splitPosCol = splitLenCol + 1;
            }
            headSrcRangeStartLine = splitPosLine;
            headSrcRangeStartCol = splitPosCol;
            headLengthLine = remainingLenLine;
            headLengthCol = remainingLenCol;
          }
          currentPosInS1Line = r2Start.lineNumber;
          currentPosInS1Col = r2Start.column;
          break;
        }

        if (headText != null) {
          resultReplacements.add(TextReplacement(
            Range(headSrcRangeStartLine, headSrcRangeStartCol, headSrcRangeEndLine, headSrcRangeEndCol),
            headText!,
          ));
        }
        currentPosInS1Line = headEndInS1Line;
        currentPosInS1Col = headEndInS1Col;
        headHasValue = false;
      }

      int? consumedStartS0Line;
      int? consumedStartS0Col;
      int? consumedEndS0Line;
      int? consumedEndS0Col;

      while (true) {
        if (currentPosInS1Line == r2End.lineNumber && currentPosInS1Col == r2End.column) {
          break;
        }
        ensureHead();
        if (headIsInfinite) {
          late final int distLine;
          late final int distCol;
          if (currentPosInS1Line == r2End.lineNumber) {
            distLine = 0;
            distCol = r2End.column - currentPosInS1Col;
          } else {
            distLine = r2End.lineNumber - currentPosInS1Line;
            distCol = r2End.column - 1;
          }
          late final int rangeInS0EndLine;
          late final int rangeInS0EndCol;
          if (distLine == 0) {
            rangeInS0EndLine = headSrcRangeStartLine;
            rangeInS0EndCol = headSrcRangeStartCol + distCol;
          } else {
            rangeInS0EndLine = headSrcRangeStartLine + distLine;
            rangeInS0EndCol = distCol + 1;
          }
          if (consumedStartS0Line == null) {
            consumedStartS0Line = headSrcRangeStartLine;
            consumedStartS0Col = headSrcRangeStartCol;
          }
          consumedEndS0Line = rangeInS0EndLine;
          consumedEndS0Col = rangeInS0EndCol;
          currentPosInS1Line = r2End.lineNumber;
          currentPosInS1Col = r2End.column;
          headSrcRangeStartLine = rangeInS0EndLine;
          headSrcRangeStartCol = rangeInS0EndCol;
          break;
        }

        late final int headEndInS1Line;
        late final int headEndInS1Col;
        if (headLengthLine == 0) {
          headEndInS1Line = currentPosInS1Line;
          headEndInS1Col = currentPosInS1Col + headLengthCol;
        } else {
          headEndInS1Line = currentPosInS1Line + headLengthLine;
          headEndInS1Col = headLengthCol + 1;
        }

        bool r2EndIsBeforeHeadEnd = false;
        if (r2End.lineNumber < headEndInS1Line) {
          r2EndIsBeforeHeadEnd = true;
        } else if (r2End.lineNumber == headEndInS1Line) {
          r2EndIsBeforeHeadEnd = r2End.column < headEndInS1Col;
        }

        if (r2EndIsBeforeHeadEnd) {
          late final int splitLenLine;
          late final int splitLenCol;
          if (currentPosInS1Line == r2End.lineNumber) {
            splitLenLine = 0;
            splitLenCol = r2End.column - currentPosInS1Col;
          } else {
            splitLenLine = r2End.lineNumber - currentPosInS1Line;
            splitLenCol = r2End.column - 1;
          }
          late final int remainingLenLine;
          late final int remainingLenCol;
          if (splitLenLine == headLengthLine) {
            remainingLenLine = 0;
            remainingLenCol = headLengthCol - splitLenCol;
          } else {
            remainingLenLine = headLengthLine - splitLenLine;
            remainingLenCol = headLengthCol;
          }

          if (headText != null) {
            if (consumedStartS0Line == null) {
              consumedStartS0Line = headSrcRangeStartLine;
              consumedStartS0Col = headSrcRangeStartCol;
            }
            consumedEndS0Line = headSrcRangeEndLine;
            consumedEndS0Col = headSrcRangeEndCol;
            final List<String> parts = splitText(headText!, splitLenLine, splitLenCol);
            headText = parts[1];
            headLengthLine = remainingLenLine;
            headLengthCol = remainingLenCol;
            headSrcRangeStartLine = headSrcRangeEndLine;
            headSrcRangeStartCol = headSrcRangeEndCol;
          } else {
            late final int splitPosLine;
            late final int splitPosCol;
            if (splitLenLine == 0) {
              splitPosLine = headSrcRangeStartLine;
              splitPosCol = headSrcRangeStartCol + splitLenCol;
            } else {
              splitPosLine = headSrcRangeStartLine + splitLenLine;
              splitPosCol = splitLenCol + 1;
            }
            if (consumedStartS0Line == null) {
              consumedStartS0Line = headSrcRangeStartLine;
              consumedStartS0Col = headSrcRangeStartCol;
            }
            consumedEndS0Line = splitPosLine;
            consumedEndS0Col = splitPosCol;
            headSrcRangeStartLine = splitPosLine;
            headSrcRangeStartCol = splitPosCol;
            headLengthLine = remainingLenLine;
            headLengthCol = remainingLenCol;
          }
          currentPosInS1Line = r2End.lineNumber;
          currentPosInS1Col = r2End.column;
          break;
        }

        if (consumedStartS0Line == null) {
          consumedStartS0Line = headSrcRangeStartLine;
          consumedStartS0Col = headSrcRangeStartCol;
        }
        consumedEndS0Line = headSrcRangeEndLine;
        consumedEndS0Col = headSrcRangeEndCol;
        currentPosInS1Line = headEndInS1Line;
        currentPosInS1Col = headEndInS1Col;
        headHasValue = false;
      }

      if (consumedStartS0Line != null) {
        resultReplacements.add(TextReplacement(
          Range(consumedStartS0Line, consumedStartS0Col!, consumedEndS0Line!, consumedEndS0Col!),
          r2.text,
        ));
      } else {
        ensureHead();
        final int insertPosS0Line = headSrcRangeStartLine;
        final int insertPosS0Col = headSrcRangeStartCol;
        resultReplacements.add(TextReplacement(
          Range(insertPosS0Line, insertPosS0Col, insertPosS0Line, insertPosS0Col),
          r2.text,
        ));
      }
    }

    while (true) {
      ensureHead();
      if (headIsInfinite) {
        break;
      }
      if (headText != null) {
        resultReplacements.add(TextReplacement(
          Range(headSrcRangeStartLine, headSrcRangeStartCol, headSrcRangeEndLine, headSrcRangeEndCol),
          headText!,
        ));
      }
      headHasValue = false;
    }

    return TextEdit(resultReplacements).normalize();
  }

  /// 1:1: `toString`
  String toStringStatic([Object? text]) {
    if (text == null) {
      return this.replacements.map((TextReplacement edit) => edit.toString()).join('\n');
    }
    if (text is String) {
      return this.toStringStatic(StringText(text));
    }
    final AbstractText t = text as AbstractText;
    if (this.replacements.isEmpty) {
      return '';
    }
    return this.replacements.map((TextReplacement r) {
      const int maxLength = 10;
      final String originalText = t.getValueOfRange(r.range);

      final Range beforeRange = Range.fromPositions(
        Position([1, r.range.startLineNumber - 1].reduce((int a, int b) => a > b ? a : b), 1),
        end: r.range.getStartPosition(),
      );
      String beforeText = t.getValueOfRange(beforeRange);
      if (beforeText.length > maxLength) {
        beforeText = '...' + beforeText.substring(beforeText.length - maxLength);
      }

      final Range afterRange = Range.fromPositions(
        r.range.getEndPosition(),
        end: Position(r.range.endLineNumber + 1, 1),
      );
      String afterText = t.getValueOfRange(afterRange);
      if (afterText.length > maxLength) {
        afterText = afterText.substring(0, maxLength) + '...';
      }

      String replacedText = originalText;
      if (replacedText.length > maxLength) {
        final int halfMax = (maxLength / 2).floor();
        replacedText = replacedText.substring(0, halfMax) + '...' + replacedText.substring(replacedText.length - halfMax);
      }

      String newText = r.text;
      if (newText.length > maxLength) {
        final int halfMax = (maxLength / 2).floor();
        newText = newText.substring(0, halfMax) + '...' + newText.substring(newText.length - halfMax);
      }

      if (replacedText.isEmpty) {
        return '$beforeText❰$newText❱$afterText';
      }
      return '$beforeText❰$replacedText↦$newText❱$afterText';
    }).join('\n');
  }
}

/// 1:1: `TextReplacement`
class TextReplacement implements equalsLib.IEquatable<TextReplacement> {
  final Range range;
  final String text;

  static TextReplacement joinReplacements(List<TextReplacement> replacements, AbstractText initialValue) {
    if (replacements.isEmpty) {
      throw BugIndicatingError();
    }
    if (replacements.length == 1) {
      return replacements[0];
    }
    final Position startPos = replacements.first.range.getStartPosition();
    final Position endPos = replacements.last.range.getEndPosition();
    String newText = '';
    for (int i = 0; i < replacements.length; i++) {
      final TextReplacement curEdit = replacements[i];
      newText += curEdit.text;
      if (i < replacements.length - 1) {
        final TextReplacement nextEdit = replacements[i + 1];
        final Range gapRange = Range.fromPositions(curEdit.range.getEndPosition(), end: nextEdit.range.getStartPosition());
        newText += initialValue.getValueOfRange(gapRange);
      }
    }
    return TextReplacement(Range.fromPositions(startPos, end: endPos), newText);
  }

  static TextReplacement fromStringReplacement(StringReplacement replacement, AbstractText initialState) =>
      TextReplacement(initialState.getTransformer().getRange(replacement.replaceRange), replacement.newText);

  static TextReplacement delete(Range range) => TextReplacement(range, '');

  static bool equalsStatic(TextReplacement first, TextReplacement second) =>
      first.range.equalsRange(second.range) && first.text == second.text;

  TextReplacement(this.range, this.text);

  bool get isEmpty => this.range.isEmpty() && this.text.isEmpty;

  ISingleEditOperation toSingleEditOperation() => ISingleEditOperation(this.range, this.text);

  TextEdit toEdit() => TextEdit(<TextReplacement>[this]);

  @override
  bool equals(TextReplacement other) => TextReplacement.equalsStatic(this, other);

  /// 1:1: `extendToCoverRange`
  TextReplacement extendToCoverRange(Range range, AbstractText initialValue) {
    if (this.range.containsRange(range)) {
      return this;
    }
    final Range newRange = this.range.plusRange(range);
    final String textBefore = initialValue.getValueOfRange(
      Range.fromPositions(newRange.getStartPosition(), end: this.range.getStartPosition()),
    );
    final String textAfter = initialValue.getValueOfRange(
      Range.fromPositions(this.range.getEndPosition(), end: newRange.getEndPosition()),
    );
    return TextReplacement(newRange, textBefore + this.text + textAfter);
  }

  /// 1:1: `extendToFullLine`
  TextReplacement extendToFullLine(AbstractText initialValue) {
    final Range newRange = Range(
      this.range.startLineNumber,
      1,
      this.range.endLineNumber,
      initialValue.getTransformer().getLineLength(this.range.endLineNumber) + 1,
    );
    return this.extendToCoverRange(newRange, initialValue);
  }

  /// 1:1: `removeCommonPrefixAndSuffix`
  TextReplacement removeCommonPrefixAndSuffix(AbstractText text) =>
      this.removeCommonPrefix(text).removeCommonSuffix(text);

  /// 1:1: `removeCommonPrefix`
  TextReplacement removeCommonPrefix(AbstractText text) {
    final String normalizedOriginalText = text.getValueOfRange(this.range).replaceAll('\r\n', '\n');
    final String normalizedModifiedText = this.text.replaceAll('\r\n', '\n');
    final int commonPrefixLen = strings.commonPrefixLength(normalizedOriginalText, normalizedModifiedText);
    final Position start = TextLength.ofText(normalizedOriginalText.substring(0, commonPrefixLen))
        .addToPosition(this.range.getStartPosition());
    final String newText = normalizedModifiedText.substring(commonPrefixLen);
    final Range range = Range.fromPositions(start, end: this.range.getEndPosition());
    return TextReplacement(range, newText);
  }

  /// 1:1: `removeCommonSuffix`
  TextReplacement removeCommonSuffix(AbstractText text) {
    final String normalizedOriginalText = text.getValueOfRange(this.range).replaceAll('\r\n', '\n');
    final String normalizedModifiedText = this.text.replaceAll('\r\n', '\n');
    final int commonSuffixLen = strings.commonSuffixLength(normalizedOriginalText, normalizedModifiedText);
    final Position end = TextLength.ofText(normalizedOriginalText.substring(0, normalizedOriginalText.length - commonSuffixLen))
        .addToPosition(this.range.getStartPosition());
    final String newText = normalizedModifiedText.substring(0, normalizedModifiedText.length - commonSuffixLen);
    final Range range = Range.fromPositions(this.range.getStartPosition(), end: end);
    return TextReplacement(range, newText);
  }

  /// 1:1: `isEffectiveDeletion`
  bool isEffectiveDeletion(AbstractText text) {
    String newText = this.text.replaceAll('\r\n', '\n');
    String existingText = text.getValueOfRange(this.range).replaceAll('\r\n', '\n');
    final int l = strings.commonPrefixLength(newText, existingText);
    newText = newText.substring(l);
    existingText = existingText.substring(l);
    final int r = strings.commonSuffixLength(newText, existingText);
    newText = newText.substring(0, newText.length - r);
    existingText = existingText.substring(0, existingText.length - r);
    return newText.isEmpty;
  }

  @override
  String toString() {
    final Position start = this.range.getStartPosition();
    final Position end = this.range.getEndPosition();
    return '(${start.lineNumber},${start.column} -> ${end.lineNumber},${end.column}): "${this.text}"';
  }
}
