// 1:1 translation of vscode/src/vs/base/common/jsonFormatter.ts
// Mirrors the TypeScript source file-for-file. Adaptations (documented inline):
//   - `interface` → `class` with fields.
//   - `const enum` SyntaxKind/ScanError are reused from json.dart.
//   - JS `String.substring` clamping is not needed here because all offsets are
//     within bounds by construction; calls are kept 1:1.
//   - Dart switch does NOT fall through a non-empty case, so the TS
//     `StringLiteral` fall-through into the literal-token group is reproduced
//     via a shared local helper.

import 'dart:convert';

import 'json.dart' show JSONScanner, ScanError, SyntaxKind, createScanner;

/// 1:1: `export interface FormattingOptions`
class FormattingOptions {
  /// If indentation is based on spaces (`insertSpaces` = true), then what is
  /// the number of spaces that make an indent?
  final int? tabSize;

  /// Is indentation based on spaces?
  final bool? insertSpaces;

  /// The default 'end of line' character. If not set, '\n' is used as default.
  final String? eol;

  FormattingOptions({this.tabSize, this.insertSpaces, this.eol});
}

/// 1:1: `export interface Edit` — a text modification.
class Edit {
  /// The start offset of the modification.
  final int offset;

  /// The length of the modification. Must not be negative.
  /// Empty length represents an *insert*.
  final int length;

  /// The new content. Empty content represents a *remove*.
  final String content;

  Edit(this.offset, this.length, this.content);
}

/// 1:1: `export interface Range` — a text range in the document.
class FormatRange {
  /// The start offset of the range.
  final int offset;

  /// The length of the range. Must not be negative.
  final int length;

  FormatRange(this.offset, this.length);
}

/// 1:1: `export function format(documentText, range, options)`
List<Edit> format(String documentText, FormatRange? range, FormattingOptions options) {
  late final int initialIndentLevel;
  late final String formatText;
  late int formatTextStart; // mutated in the while loop below (TS `let`)
  late final int rangeStart;
  late final int rangeEnd;
  if (range != null) {
    rangeStart = range.offset;
    rangeEnd = rangeStart + range.length;

    formatTextStart = rangeStart;
    while (formatTextStart > 0 && !isEOL(documentText, formatTextStart - 1)) {
      formatTextStart--;
    }
    int endOffset = rangeEnd;
    while (endOffset < documentText.length && !isEOL(documentText, endOffset)) {
      endOffset++;
    }
    formatText = _substring(documentText, formatTextStart, endOffset);
    initialIndentLevel = computeIndentLevel(formatText, options);
  } else {
    formatText = documentText;
    initialIndentLevel = 0;
    formatTextStart = 0;
    rangeStart = 0;
    rangeEnd = documentText.length;
  }
  final String eol = getEOL(options, documentText);

  bool lineBreak = false;
  int indentLevel = 0;
  late final String indentValue;
  if (options.insertSpaces ?? false) {
    indentValue = repeat(' ', options.tabSize ?? 4);
  } else {
    indentValue = '\t';
  }

  final JSONScanner scanner = createScanner(formatText, false);
  bool hasError = false;

  String newLineAndIndent() => eol + repeat(indentValue, initialIndentLevel + indentLevel);

  int scanNext() {
    int token = scanner.scan();
    lineBreak = false;
    while (token == SyntaxKind.trivia || token == SyntaxKind.lineBreakTrivia) {
      lineBreak = lineBreak || (token == SyntaxKind.lineBreakTrivia);
      token = scanner.scan();
    }
    hasError = token == SyntaxKind.unknown || scanner.getTokenError() != ScanError.none;
    return token;
  }

  final List<Edit> editOperations = <Edit>[];

  void addEdit(String text, int startOffset, int endOffset) {
    if (!hasError &&
        startOffset < rangeEnd &&
        endOffset > rangeStart &&
        _substring(documentText, startOffset, endOffset) != text) {
      editOperations.add(Edit(startOffset, endOffset - startOffset, text));
    }
  }

  int firstToken = scanNext();

  // TS uses `let` because these are mutated in the loop; `late` lets the
  // shared helper below capture them by closure.
  late int secondToken;
  late String replaceContent;

  // Literal-follow logic shared by the TS `StringLiteral` fall-through case
  // and the literal keyword group. In TS these fall through into one body.
  void literalFollow() {
    if (secondToken == SyntaxKind.lineCommentTrivia ||
        secondToken == SyntaxKind.blockCommentTrivia) {
      replaceContent = ' ';
    } else if (secondToken != SyntaxKind.commaToken && secondToken != SyntaxKind.eof) {
      hasError = true;
    }
  }

  if (firstToken != SyntaxKind.eof) {
    final int firstTokenStart = scanner.getTokenOffset() + formatTextStart;
    final String initialIndent = repeat(indentValue, initialIndentLevel);
    addEdit(initialIndent, formatTextStart, firstTokenStart);
  }

  while (firstToken != SyntaxKind.eof) {
    int firstTokenEnd = scanner.getTokenOffset() + scanner.getTokenLength() + formatTextStart;
    secondToken = scanNext();

    replaceContent = '';
    while (!lineBreak &&
        (secondToken == SyntaxKind.lineCommentTrivia ||
            secondToken == SyntaxKind.blockCommentTrivia)) {
      // comments on the same line: keep them on the same line, but ignore them otherwise
      final int commentTokenStart = scanner.getTokenOffset() + formatTextStart;
      addEdit(' ', firstTokenEnd, commentTokenStart);
      firstTokenEnd = scanner.getTokenOffset() + scanner.getTokenLength() + formatTextStart;
      replaceContent = secondToken == SyntaxKind.lineCommentTrivia ? newLineAndIndent() : '';
      secondToken = scanNext();
    }

    if (secondToken == SyntaxKind.closeBraceToken) {
      if (firstToken != SyntaxKind.openBraceToken) {
        indentLevel--;
        replaceContent = newLineAndIndent();
      }
    } else if (secondToken == SyntaxKind.closeBracketToken) {
      if (firstToken != SyntaxKind.openBracketToken) {
        indentLevel--;
        replaceContent = newLineAndIndent();
      }
    } else {
      switch (firstToken) {
        case SyntaxKind.openBracketToken:
        case SyntaxKind.openBraceToken:
          indentLevel++;
          replaceContent = newLineAndIndent();
          break;
        case SyntaxKind.commaToken:
        case SyntaxKind.lineCommentTrivia:
          replaceContent = newLineAndIndent();
          break;
        case SyntaxKind.blockCommentTrivia:
          if (lineBreak) {
            replaceContent = newLineAndIndent();
          } else {
            // symbol following comment on the same line: keep on same line,
            // separate with ' '
            replaceContent = ' ';
          }
          break;
        case SyntaxKind.colonToken:
          replaceContent = ' ';
          break;
        case SyntaxKind.stringLiteral:
          if (secondToken == SyntaxKind.colonToken) {
            replaceContent = '';
            break;
          }
          // fall through (TS): reuse the literal-follow body
          literalFollow();
          break;
        case SyntaxKind.nullKeyword:
        case SyntaxKind.trueKeyword:
        case SyntaxKind.falseKeyword:
        case SyntaxKind.numericLiteral:
        case SyntaxKind.closeBraceToken:
        case SyntaxKind.closeBracketToken:
          literalFollow();
          break;
        case SyntaxKind.unknown:
          hasError = true;
          break;
      }
      if (lineBreak &&
          (secondToken == SyntaxKind.lineCommentTrivia ||
              secondToken == SyntaxKind.blockCommentTrivia)) {
        replaceContent = newLineAndIndent();
      }
    }
    final int secondTokenStart = scanner.getTokenOffset() + formatTextStart;
    addEdit(replaceContent, firstTokenEnd, secondTokenStart);
    firstToken = secondToken;
  }
  return editOperations;
}

/// 1:1: `toFormattedString(obj, options)`
///
/// Uses a deterministic JSON encoder with the requested indentation. JS
/// `JSON.stringify(obj, undefined, N)` indents with N spaces; with `'\t'` it
/// indents with a tab — Dart's [JsonEncoder.withIndent] mirrors both.
String toFormattedString(Object? obj, FormattingOptions options) {
  final String indent = options.insertSpaces ?? false
      ? ' ' * (options.tabSize ?? 4)
      : '\t';
  final String content = JsonEncoder.withIndent(indent).convert(obj);
  if (options.eol != null) {
    return content.replaceAllMapped(RegExp(r'\r\n|\r|\n'), (_) => options.eol!);
  }
  return content;
}


/// JS `String.prototype.substring` clamps out-of-range indices and swaps
/// reversed arguments; Dart's `substring` throws. Reproduce JS semantics so
/// range handling matches the TS original exactly.
String _substring(String s, int start, int end) {
  final int len = s.length;
  int a = start < 0 ? 0 : (start > len ? len : start);
  int b = end < 0 ? 0 : (end > len ? len : end);
  if (a > b) {
    final int tmp = a;
    a = b;
    b = tmp;
  }
  return s.substring(a, b);
}

/// 1:1: `repeat(s, count)`
String repeat(String s, int count) {
  final StringBuffer result = StringBuffer();
  for (int i = 0; i < count; i++) {
    result.write(s);
  }
  return result.toString();
}

/// 1:1: `computeIndentLevel(content, options)`
int computeIndentLevel(String content, FormattingOptions options) {
  int i = 0;
  int nChars = 0;
  final int tabSize = options.tabSize ?? 4;
  while (i < content.length) {
    final String ch = content[i];
    if (ch == ' ') {
      nChars++;
    } else if (ch == '\t') {
      nChars += tabSize;
    } else {
      break;
    }
    i++;
  }
  return (nChars / tabSize).floor();
}

/// 1:1: `getEOL(options, text)`
String getEOL(FormattingOptions options, String text) {
  for (int i = 0; i < text.length; i++) {
    final String ch = text[i];
    if (ch == '\r') {
      if (i + 1 < text.length && text[i + 1] == '\n') {
        return '\r\n';
      }
      return '\r';
    } else if (ch == '\n') {
      return '\n';
    }
  }
  // TS: (options && options.eol) || '\n' — an empty eol also falls back.
  final String? eol = options.eol;
  return (eol != null && eol.isNotEmpty) ? eol : '\n';
}

/// 1:1: `isEOL(text, offset)`
///
/// JS `String.charAt(outOfRange)` returns '', and `'\r\n'.indexOf('')` is 0,
/// i.e. `!== -1` → true. Reproduce that edge case explicitly.
bool isEOL(String text, int offset) {
  if (offset < 0 || offset >= text.length) {
    return true;
  }
  return '\r\n'.contains(text[offset]);
}
