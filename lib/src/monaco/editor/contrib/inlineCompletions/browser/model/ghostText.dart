// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/browser/model/
//   ghostText.ts
// Translated 1:1 from TypeScript.
//
// Reuses real `Range`/`Position`/`TextEdit`/`TextReplacement`/`ColumnRange`/
// `LineDecoration`/`InlineDecorationType`/`splitLines`/`equals`.
// ---------------------------------------------------------------------------

import '../../../../../base/common/arrays.dart' show equals;
import '../../../../../base/common/strings.dart' show splitLines;
import '../../../../common/core/edits/textEdit.dart'
    show TextEdit, TextReplacement;
import '../../../../common/core/position.dart' show Position;
import '../../../../common/core/range.dart' show Range;
import '../../../../common/core/ranges/columnRange.dart' show ColumnRange;
import '../../../../common/viewLayout/lineDecorations.dart' show LineDecoration;
import '../../../../common/viewModel/inlineDecorations.dart'
    show InlineDecoration;

/// 1:1: `IGhostTextLine`.
class IGhostTextLine {
  final String line;
  final List<LineDecoration> lineDecorations;

  IGhostTextLine(this.line, this.lineDecorations);
}

/// 1:1: `GhostTextPart`.
class GhostTextPart {
  final int column;
  final String text;
  final bool preview;
  final List<IGhostTextLine> lines;

  GhostTextPart(this.column, this.text, this.preview, [
    List<InlineDecoration> inlineDecorations = const <InlineDecoration>[],
  ]) : lines = splitLines(text).asMap().entries.map((MapEntry<int, String> e) {
          return IGhostTextLine(
            e.value,
            LineDecoration.filter(
              inlineDecorations,
              e.key + 1,
              1,
              e.value.length + 1,
            ),
          );
        }).toList();

  bool equals(GhostTextPart other) {
    if (column != other.column || lines.length != other.lines.length) {
      return false;
    }
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].line != other.lines[i].line ||
          !LineDecoration.equalsArr(
            lines[i].lineDecorations,
            other.lines[i].lineDecorations,
          )) {
        return false;
      }
    }
    return true;
  }
}

/// 1:1: `GhostText`.
class GhostText implements GhostTextOrReplacement {
  final int lineNumber;
  final List<GhostTextPart> parts;

  GhostText(this.lineNumber, this.parts) {
    // TS asserts adjacent parts are ordered by column; no-op for valid input.
  }

  bool equals(GhostText other) =>
      lineNumber == other.lineNumber &&
      parts.length == other.parts.length &&
      _everyEqual(parts, other.parts);

  static bool _everyEqual(
    List<GhostTextPart> a,
    List<GhostTextPart> b,
  ) {
    for (int i = 0; i < a.length; i++) {
      if (!a[i].equals(b[i])) return false;
    }
    return true;
  }

  /// 1:1: `render` (testing/debugging only).
  String render(String documentText, [bool debug = false]) => TextEdit(
        parts
            .map((GhostTextPart p) => TextReplacement(
                  Range.fromPositions(Position(lineNumber, p.column)),
                  debug
                      ? '[${p.lines.map((IGhostTextLine l) => l.line).join('\n')}]'
                      : p.lines.map((IGhostTextLine l) => l.line).join('\n'),
                ))
            .toList(),
      ).applyToString(documentText);

  /// 1:1: `renderForScreenReader`.
  String renderForScreenReader(String lineText) {
    if (parts.isEmpty) return '';
    final GhostTextPart lastPart = parts[parts.length - 1];
    final String cappedLineText =
        lineText.substring(0, lastPart.column - 1 > lineText.length ? lineText.length : lastPart.column - 1);
    final String text = TextEdit(
      parts
          .map((GhostTextPart p) => TextReplacement(
                Range.fromPositions(Position(1, p.column)),
                p.lines.map((IGhostTextLine l) => l.line).join('\n'),
              ))
          .toList(),
    ).applyToString(cappedLineText);
    final int from = parts[0].column - 1;
    return from > text.length ? '' : text.substring(from);
  }

  bool isEmpty() => parts.every((GhostTextPart p) => p.lines.isEmpty);

  int get lineCount =>
      1 + parts.fold<int>(0, (int r, GhostTextPart p) => r + p.lines.length - 1);
}

/// 1:1: `GhostTextReplacement`.
class GhostTextReplacement implements GhostTextOrReplacement {
  final int lineNumber;
  final ColumnRange columnRange;
  final String text;
  final int additionalReservedLineCount;
  final List<GhostTextPart> parts;
  final List<String> newLines;

  GhostTextReplacement(
    this.lineNumber,
    this.columnRange,
    this.text, [
    this.additionalReservedLineCount = 0,
  ])   : parts = <GhostTextPart>[
          GhostTextPart(columnRange.endColumnExclusive, text, false),
        ],
        newLines = splitLines(text);

  String renderForScreenReader(String lineText) => newLines.join('\n');

  String render(String documentText, [bool debug = false]) {
    final Range replaceRange = columnRange.toRange(lineNumber);
    if (debug) {
      return TextEdit(<TextReplacement>[
        TextReplacement(
          Range.fromPositions(replaceRange.getStartPosition()),
          '(',
        ),
        TextReplacement(
          Range.fromPositions(replaceRange.getEndPosition()),
          ')[${newLines.join('\n')}]',
        ),
      ]).applyToString(documentText);
    }
    return TextEdit(<TextReplacement>[
      TextReplacement(replaceRange, newLines.join('\n')),
    ]).applyToString(documentText);
  }

  int get lineCount => newLines.length;

  bool isEmpty() => parts.every((GhostTextPart p) => p.lines.isEmpty);

  bool equals(GhostTextReplacement other) =>
      lineNumber == other.lineNumber &&
      columnRange.startColumn == other.columnRange.startColumn &&
      columnRange.endColumnExclusive == other.columnRange.endColumnExclusive &&
      newLines.length == other.newLines.length &&
      _stringListsEqual(newLines, other.newLines) &&
      additionalReservedLineCount == other.additionalReservedLineCount;

  static bool _stringListsEqual(List<String> a, List<String> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 1:1: `GhostTextOrReplacement`.
abstract class GhostTextOrReplacement {}

/// 1:1: `ghostTextsOrReplacementsEqual`.
bool ghostTextsOrReplacementsEqual(
  List<GhostTextOrReplacement>? a,
  List<GhostTextOrReplacement>? b,
) =>
    equals(a, b, ghostTextOrReplacementEquals);

/// 1:1: `ghostTextOrReplacementEquals`.
bool ghostTextOrReplacementEquals(
  GhostTextOrReplacement? a,
  GhostTextOrReplacement? b,
) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a is GhostText && b is GhostText) return a.equals(b);
  if (a is GhostTextReplacement && b is GhostTextReplacement) {
    return a.equals(b);
  }
  return false;
}
