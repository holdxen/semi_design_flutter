// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/edits/lineEdit.ts
// Translated 1:1 from TypeScript.
//   - `assert(checkAdjacentItems(...))` -> `assertCondition(checkAdjacentItems(...))`
//     (source `assert` is base/common/assert's runtime assertion, not a no-op).
//   - readonly arrays -> `List`, `.slice` -> `.sublist`.
//   - namespace `SerializedLineReplacement.is` -> class static method.
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart'
    show compareBy, groupAdjacentBy, numberComparator;
import '../../../../base/common/assert.dart' show assertCondition, checkAdjacentItems;
import '../../../../base/common/strings.dart' show splitLines;
import '../position.dart' show Position;
import '../ranges/lineRange.dart' show LineRange;
import '../range.dart' show Range;
import '../text/abstractText.dart' show AbstractText;
import 'stringEdit.dart' show BaseStringEdit, StringEdit, StringReplacement;
import 'textEdit.dart' show TextEdit, TextReplacement;

class LineEdit {
  static final LineEdit empty = LineEdit(<LineReplacement>[]);

  static LineEdit deserialize(List<SerializedLineReplacement> data) =>
      LineEdit(data.map((e) => LineReplacement.deserialize(e)).toList());

  static LineEdit fromStringEdit(BaseStringEdit edit, AbstractText initialValue) {
    final TextEdit textEdit = TextEdit.fromStringEdit(edit, initialValue);
    return LineEdit.fromTextEdit(textEdit, initialValue);
  }

  static LineEdit fromTextEdit(TextEdit edit, AbstractText initialValue) {
    final List<TextReplacement> edits = edit.replacements;

    final List<LineReplacement> result = <LineReplacement>[];
    final List<TextReplacement> currentEdits = <TextReplacement>[];
    for (int i = 0; i < edits.length; i++) {
      final TextReplacement edit = edits[i];
      final TextReplacement? nextEditRange = i + 1 < edits.length ? edits[i + 1] : null;
      currentEdits.add(edit);
      if (nextEditRange != null &&
          nextEditRange.range.startLineNumber == edit.range.endLineNumber) {
        continue;
      }

      final TextReplacement singleEdit =
          TextReplacement.joinReplacements(currentEdits, initialValue);
      currentEdits.clear();

      final LineReplacement singleLineEdit =
          LineReplacement.fromSingleTextEdit(singleEdit, initialValue);
      result.add(singleLineEdit);
    }

    return LineEdit(result);
  }

  static LineEdit createFromUnsorted(List<LineReplacement> edits) {
    final List<LineReplacement> result = edits.toList();
    result.sort(compareBy<LineReplacement, int>(
        (i) => i.lineRange.startLineNumber, numberComparator));
    return LineEdit(result);
  }

  final List<LineReplacement> replacements;

  /// Have to be sorted by start line number and non-intersecting.
  LineEdit(this.replacements) {
    assertCondition(checkAdjacentItems<LineReplacement>(replacements,
        (i1, i2) => i1.lineRange.endLineNumberExclusive <= i2.lineRange.startLineNumber));
  }

  bool isEmpty() => this.replacements.isEmpty;

  StringEdit toEdit(AbstractText initialValue) {
    final List<StringReplacement> edits = <StringReplacement>[];
    for (final LineReplacement edit in this.replacements) {
      final StringReplacement singleEdit = edit.toSingleEdit(initialValue);
      edits.add(singleEdit);
    }
    return StringEdit(edits);
  }

  @override
  String toString() => this.replacements.map((e) => e.toString()).join(',');

  List<SerializedLineReplacement> serialize() =>
      this.replacements.map((e) => e.serialize()).toList();

  List<LineRange> getNewLineRanges() {
    final List<LineRange> ranges = <LineRange>[];
    int offset = 0;
    for (final LineReplacement e in this.replacements) {
      ranges.add(LineRange.ofLength(
          e.lineRange.startLineNumber + offset, e.newLines.length));
      offset += e.newLines.length - e.lineRange.length;
    }
    return ranges;
  }

  int mapLineNumber(int lineNumber) {
    int lineDelta = 0;
    for (final LineReplacement e in this.replacements) {
      if (e.lineRange.endLineNumberExclusive > lineNumber) {
        break;
      }
      lineDelta += e.newLines.length - e.lineRange.length;
    }
    return lineNumber + lineDelta;
  }

  LineRange mapLineRange(LineRange lineRange) => LineRange(
        this.mapLineNumber(lineRange.startLineNumber),
        this.mapLineNumber(lineRange.endLineNumberExclusive),
      );

  /// TODO improve, dont require originalLines
  LineRange mapBackLineRange(LineRange lineRange, List<String> originalLines) {
    final LineEdit i = this.inverse(originalLines);
    return i.mapLineRange(lineRange);
  }

  bool touches(LineEdit other) => this.replacements.any((e1) =>
      other.replacements.any((e2) => e1.lineRange.intersect(e2.lineRange) != null));

  LineEdit rebase(LineEdit base) => LineEdit(this.replacements
      .map((e) => LineReplacement(base.mapLineRange(e.lineRange), e.newLines))
      .toList());

  String humanReadablePatch(List<String> originalLines) {
    final List<String> result = <String>[];

    void pushLine(int originalLineNumber, int modifiedLineNumber, String kind, String? content) {
      final String specialChar = (kind == 'unmodified'
          ? ' '
          : (kind == 'deleted' ? '-' : '+'));

      if (content == null) {
        content = '[[[[[ WARNING: LINE DOES NOT EXIST ]]]]]';
      }

      final String origLn = originalLineNumber == -1 ? '   ' : originalLineNumber.toString().padLeft(3, ' ');
      final String modLn = modifiedLineNumber == -1 ? '   ' : modifiedLineNumber.toString().padLeft(3, ' ');

      result.add('$specialChar $origLn $modLn $content');
    }

    void pushSeperator() {
      result.add('---');
    }

    int lineDelta = 0;
    bool first = true;

    for (final List<LineReplacement> edits in groupAdjacentBy<LineReplacement>(
        this.replacements,
        (e1, e2) => e1.lineRange.distanceToRange(e2.lineRange) <= 5)) {
      if (!first) {
        pushSeperator();
      } else {
        first = false;
      }

      int lastLineNumber = edits[0].lineRange.startLineNumber - 2;

      for (final LineReplacement edit in edits) {
        for (int i = _max(1, lastLineNumber); i < edit.lineRange.startLineNumber; i++) {
          pushLine(i, i + lineDelta, 'unmodified', originalLines[i - 1]);
        }

        final LineRange range = edit.lineRange;
        final List<String> newLines = edit.newLines;
        for (final int replaceLineNumber in range.mapToLineArray<int>((n) => n)) {
          final String line = originalLines[replaceLineNumber - 1];
          pushLine(replaceLineNumber, -1, 'deleted', line);
        }
        for (int i = 0; i < newLines.length; i++) {
          final String line = newLines[i];
          pushLine(-1, range.startLineNumber + lineDelta + i, 'added', line);
        }

        lastLineNumber = range.endLineNumberExclusive;
        lineDelta += edit.newLines.length - edit.lineRange.length;
      }

      for (int i = lastLineNumber; i <= _min(lastLineNumber + 2, originalLines.length); i++) {
        pushLine(i, i + lineDelta, 'unmodified', originalLines[i - 1]);
      }
    }

    return result.join('\n');
  }

  List<String> apply(List<String> lines) {
    final List<String> result = <String>[];
    int currentLineIndex = 0;

    for (final LineReplacement edit in this.replacements) {
      while (currentLineIndex < edit.lineRange.startLineNumber - 1) {
        result.add(lines[currentLineIndex]);
        currentLineIndex++;
      }
      for (final String newLine in edit.newLines) {
        result.add(newLine);
      }
      currentLineIndex = edit.lineRange.endLineNumberExclusive - 1;
    }

    while (currentLineIndex < lines.length) {
      result.add(lines[currentLineIndex]);
      currentLineIndex++;
    }
    return result;
  }

  LineEdit inverse(List<String> originalLines) {
    final List<LineRange> newRanges = this.getNewLineRanges();
    return LineEdit(this.replacements
        .asMap()
        .entries
        .map((e) => LineReplacement(
              newRanges[e.key],
              originalLines.sublist(
                  e.value.lineRange.startLineNumber - 1,
                  e.value.lineRange.endLineNumberExclusive - 1),
            ))
        .toList());
  }
}

class LineReplacement {
  static LineReplacement deserialize(SerializedLineReplacement e) =>
      LineReplacement(LineRange.ofLength(e.$1, e.$2 - e.$1), e.$3);

  static LineReplacement fromSingleTextEdit(TextReplacement edit, AbstractText initialValue) {
    final List<String> newLines = splitLines(edit.text);
    int startLineNumber = edit.range.startLineNumber;
    final String survivingFirstLineText = initialValue.getValueOfRange(Range.fromPositions(
      Position(edit.range.startLineNumber, 1),
      end: edit.range.getStartPosition(),
    ));
    newLines[0] = survivingFirstLineText + newLines[0];

    int endLineNumberEx = edit.range.endLineNumber + 1;
    final int editEndLineNumberMaxColumn =
        initialValue.getTransformer().getLineLength(edit.range.endLineNumber) + 1;
    final String survivingEndLineText = initialValue.getValueOfRange(Range.fromPositions(
      edit.range.getEndPosition(),
      end: Position(edit.range.endLineNumber, editEndLineNumberMaxColumn),
    ));
    newLines[newLines.length - 1] = newLines[newLines.length - 1] + survivingEndLineText;

    // Replacing [startLineNumber, endLineNumberEx) with newLines would be correct,
    // however it might not be minimal.
    final bool startBeforeNewLine = edit.range.startColumn ==
        initialValue.getTransformer().getLineLength(edit.range.startLineNumber) + 1;
    final bool endAfterNewLine = edit.range.endColumn == 1;

    if (startBeforeNewLine && newLines[0].length == survivingFirstLineText.length) {
      // the replacement would not delete any text on the first line
      startLineNumber++;
      newLines.removeAt(0);
    }

    if (newLines.isNotEmpty &&
        startLineNumber < endLineNumberEx &&
        endAfterNewLine &&
        newLines[newLines.length - 1].length == survivingEndLineText.length) {
      // the replacement would not delete any text on the last line
      endLineNumberEx--;
      newLines.removeLast();
    }

    return LineReplacement(LineRange(startLineNumber, endLineNumberEx), newLines);
  }

  final LineRange lineRange;
  final List<String> newLines;

  LineReplacement(this.lineRange, this.newLines);

  TextReplacement toSingleTextEdit(AbstractText initialValue) {
    if (this.newLines.isEmpty) {
      // Deletion
      final textLen = initialValue.getTransformer().textLength;
      if (this.lineRange.endLineNumberExclusive == textLen.lineCount + 2) {
        late Position startPos;
        if (this.lineRange.startLineNumber > 1) {
          final int startLineNumber = this.lineRange.startLineNumber - 1;
          final int startColumn =
              initialValue.getTransformer().getLineLength(startLineNumber) + 1;
          startPos = Position(startLineNumber, startColumn);
        } else {
          // Delete everything. In terms of lines, this would end up with 0 lines.
          // However, a string has always 1 line (which can be empty).
          startPos = Position(1, 1);
        }
        final Position lastPosition = textLen.addToPosition(Position(1, 1));
        return TextReplacement(Range.fromPositions(startPos, end: lastPosition), '');
      } else {
        return TextReplacement(
            Range(this.lineRange.startLineNumber, 1,
                this.lineRange.endLineNumberExclusive, 1),
            '');
      }
    } else if (this.lineRange.isEmpty) {
      // Insertion
      late int endLineNumber;
      late int column;
      late String text;
      final int insertionLine = this.lineRange.startLineNumber;
      if (insertionLine ==
          initialValue.getTransformer().textLength.lineCount + 2) {
        endLineNumber = insertionLine - 1;
        column = initialValue.getTransformer().getLineLength(endLineNumber) + 1;
        text = this.newLines.map((l) => '\n' + l).join('');
      } else {
        endLineNumber = insertionLine;
        column = 1;
        text = this.newLines.map((l) => l + '\n').join('');
      }
      return TextReplacement(
          Range.fromPositions(Position(endLineNumber, column)), text);
    } else {
      final int endLineNumber = this.lineRange.endLineNumberExclusive - 1;
      final int endLineNumberMaxColumn =
          initialValue.getTransformer().getLineLength(endLineNumber) + 1;
      final Range range = Range(
        this.lineRange.startLineNumber,
        1,
        endLineNumber,
        endLineNumberMaxColumn,
      );
      // Don't add \n to the last line. This is because we subtract one from
      // lineRange.endLineNumberExclusive for endLineNumber.
      final String text = this.newLines.join('\n');
      return TextReplacement(range, text);
    }
  }

  StringReplacement toSingleEdit(AbstractText initialValue) {
    final TextReplacement textEdit = this.toSingleTextEdit(initialValue);
    final range = initialValue.getTransformer().getOffsetRange(textEdit.range);
    return StringReplacement(range, textEdit.text);
  }

  @override
  String toString() => '${this.lineRange}->${_jsonString(this.newLines)}';

  SerializedLineReplacement serialize() => (
        this.lineRange.startLineNumber,
        this.lineRange.endLineNumberExclusive,
        this.newLines,
      );

  LineReplacement removeCommonSuffixPrefixLines(AbstractText initialValue) {
    int startLineNumber = this.lineRange.startLineNumber;
    int endLineNumberEx = this.lineRange.endLineNumberExclusive;

    int trimStartCount = 0;
    while (startLineNumber < endLineNumberEx &&
        trimStartCount < this.newLines.length &&
        this.newLines[trimStartCount] == initialValue.getLineAt(startLineNumber)) {
      startLineNumber++;
      trimStartCount++;
    }

    int trimEndCount = 0;
    while (startLineNumber < endLineNumberEx &&
        trimEndCount + trimStartCount < this.newLines.length &&
        this.newLines[this.newLines.length - 1 - trimEndCount] ==
            initialValue.getLineAt(endLineNumberEx - 1)) {
      endLineNumberEx--;
      trimEndCount++;
    }

    if (trimStartCount == 0 && trimEndCount == 0) {
      return this;
    }
    return LineReplacement(
      LineRange(startLineNumber, endLineNumberEx),
      this.newLines.sublist(trimStartCount, this.newLines.length - trimEndCount),
    );
  }

  LineEdit toLineEdit() => LineEdit(<LineReplacement>[this]);
}

/// 1:1: `export type SerializedLineEdit = SerializedLineReplacement[]`
typedef SerializedLineEdit = List<SerializedLineReplacement>;

/// 1:1: `[startLineNumber, endLineNumber, newLines]` tuple.
typedef SerializedLineReplacement = (int, int, List<String>);

/// 1:1: `namespace SerializedLineReplacement.is`
class SerializedLineReplacementX {
  static bool is_(Object? thing) {
    if (thing is! List || thing.length != 3) return false;
    return thing[0] is int &&
        thing[1] is int &&
        thing[2] is List &&
        (thing[2] as List).every((e) => e is String);
  }
}

// --- helpers ---------------------------------------------------------------

int _max(int a, int b) => a > b ? a : b;
int _min(int a, int b) => a < b ? a : b;

/// Minimal JSON array string mirroring JSON.stringify for a string list.
String _jsonString(List<String> s) {
  final StringBuffer out = StringBuffer('[');
  for (int i = 0; i < s.length; i++) {
    if (i > 0) out.write(',');
    out.write(_jsonStringScalar(s[i]));
  }
  out.write(']');
  return out.toString();
}

String _jsonStringScalar(String s) {
  final StringBuffer out = StringBuffer('"');
  for (int i = 0; i < s.length; i++) {
    final int c = s.codeUnitAt(i);
    switch (c) {
      case 0x22:
        out.write(r'\"');
        break;
      case 0x5c:
        out.write(r'\\');
        break;
      case 0x0a:
        out.write(r'\n');
        break;
      case 0x0d:
        out.write(r'\r');
        break;
      case 0x09:
        out.write(r'\t');
        break;
      default:
        out.writeCharCode(c);
    }
  }
  out.write('"');
  return out.toString();
}
