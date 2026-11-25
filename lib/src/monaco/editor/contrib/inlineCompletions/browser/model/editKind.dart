// 1:1 port of
// vs/editor/contrib/inlineCompletions/browser/model/editKind.ts
// Erased TS interfaces are carriers with `toJson()` mirroring the exact
// object shape that JS `JSON.stringify` emits (undefined keys are omitted).
// Runtime truth: tool/ts2dart/_batch270_truth.cjs (recursive TS transpile+vm).

import 'dart:convert';

import '../../../../common/core/edits/stringEdit.dart'
    show StringEdit, StringReplacement;
import '../../../../common/core/position.dart' show Position;

const Set<String> _syntacticalChars = <String>{
  ';', ',', '=', '+', '-', '*', '/', '{', '}', '(', ')', '[', ']', '<', '>',
  ':', '.', '!', '?', '&', '|', '^', '%', '@', '#', '~', '`', '\\', '\'',
  '"', r'$',
};

bool _isSyntacticalChar(String char) => _syntacticalChars.contains(char);

bool _isIdentifierChar(String char) =>
    RegExp(r'[a-zA-Z0-9_]').hasMatch(char);

bool _isWhitespaceChar(String char) => char == ' ' || char == '\t';

class TextShape {
  final String kind;
  final bool? isSingleCharacter;
  final String? singleCharacterKind;
  final bool? isWord;
  final bool? isMultipleWords;
  final bool? isMultipleWhitespace;
  final bool? hasDuplicatedWhitespace;
  final int? lineCount;

  const TextShape._singleLine({
    required this.isSingleCharacter,
    required this.singleCharacterKind,
    required this.isWord,
    required this.isMultipleWords,
    required this.isMultipleWhitespace,
    required this.hasDuplicatedWhitespace,
  })  : kind = 'singleLine',
        lineCount = null;

  const TextShape._multiLine(this.lineCount)
      : kind = 'multiLine',
        isSingleCharacter = null,
        singleCharacterKind = null,
        isWord = null,
        isMultipleWords = null,
        isMultipleWhitespace = null,
        hasDuplicatedWhitespace = null;

  Map<String, Object?> toJson() {
    if (kind == 'multiLine') {
      return <String, Object?>{'kind': kind, 'lineCount': lineCount};
    }
    final Map<String, Object?> out = <String, Object?>{
      'kind': kind,
      'isSingleCharacter': isSingleCharacter,
      'isWord': isWord,
      'isMultipleWords': isMultipleWords,
      'isMultipleWhitespace': isMultipleWhitespace,
      'hasDuplicatedWhitespace': hasDuplicatedWhitespace,
    };
    // JS JSON.stringify omits undefined properties.
    if (singleCharacterKind != null) {
      out['singleCharacterKind'] = singleCharacterKind;
    }
    return out;
  }
}

TextShape analyzeTextShape(String text) {
  final List<String> lines = text.split(RegExp(r'\r\n|\r|\n'));
  if (lines.length > 1) {
    return TextShape._multiLine(lines.length);
  }

  final bool isSingleChar = text.length == 1;
  String? singleCharKind;
  if (isSingleChar) {
    if (_isSyntacticalChar(text)) {
      singleCharKind = 'syntactical';
    } else if (_isIdentifierChar(text)) {
      singleCharKind = 'identifier';
    } else if (_isWhitespaceChar(text)) {
      singleCharKind = 'whitespace';
    }
  }

  final List<String> whitespaceMatches = RegExp(r'[ \t]+')
      .allMatches(text)
      .map((m) => m.group(0)!)
      .toList();
  final bool isMultipleWhitespace =
      whitespaceMatches.any((ws) => ws.length > 1);
  final bool hasDuplicatedWhitespace = whitespaceMatches.any(
      (ws) => ws.contains('  ') || ws.contains('\t\t'));

  final List<String> words = text
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  final bool isWord = words.length == 1 &&
      RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(words[0]);
  final bool isMultipleWords = words.length > 1;

  return TextShape._singleLine(
    isSingleCharacter: isSingleChar,
    singleCharacterKind: singleCharKind,
    isWord: isWord,
    isMultipleWords: isMultipleWords,
    isMultipleWhitespace: isMultipleWhitespace,
    hasDuplicatedWhitespace: hasDuplicatedWhitespace,
  );
}

class InsertLocationRelativeToCursor {
  final bool atCursor;
  final bool beforeCursorOnSameLine;
  final bool afterCursorOnSameLine;
  final int? linesAbove;
  final int? linesBelow;

  const InsertLocationRelativeToCursor({
    required this.atCursor,
    required this.beforeCursorOnSameLine,
    required this.afterCursorOnSameLine,
    this.linesAbove,
    this.linesBelow,
  });

  Map<String, Object?> toJson() {
    final Map<String, Object?> out = <String, Object?>{
      'atCursor': atCursor,
      'beforeCursorOnSameLine': beforeCursorOnSameLine,
      'afterCursorOnSameLine': afterCursorOnSameLine,
    };
    if (linesAbove != null) out['linesAbove'] = linesAbove;
    if (linesBelow != null) out['linesBelow'] = linesBelow;
    return out;
  }
}

class InsertProperties {
  final TextShape textShape;
  final String locationShape;
  final InsertLocationRelativeToCursor? relativeToCursor;

  const InsertProperties(this.textShape, this.locationShape, this.relativeToCursor);

  Map<String, Object?> toJson() {
    final Map<String, Object?> out = <String, Object?>{
      'textShape': textShape.toJson(),
      'locationShape': locationShape,
    };
    if (relativeToCursor != null) {
      out['relativeToCursor'] = relativeToCursor!.toJson();
    }
    return out;
  }
}

class DeleteProperties {
  final TextShape textShape;
  final bool isAtEndOfLine;
  final bool deletesEntireLineContent;

  const DeleteProperties(
      this.textShape, this.isAtEndOfLine, this.deletesEntireLineContent);

  Map<String, Object?> toJson() => <String, Object?>{
        'textShape': textShape.toJson(),
        'isAtEndOfLine': isAtEndOfLine,
        'deletesEntireLineContent': deletesEntireLineContent,
      };
}

class ReplaceProperties {
  final bool isWordToWordReplacement;
  final bool isAdditive;
  final bool isSubtractive;
  final bool isSingleLineToSingleLine;
  final bool isSingleLineToMultiLine;
  final bool isMultiLineToSingleLine;

  const ReplaceProperties(
    this.isWordToWordReplacement,
    this.isAdditive,
    this.isSubtractive,
    this.isSingleLineToSingleLine,
    this.isSingleLineToMultiLine,
    this.isMultiLineToSingleLine,
  );

  Map<String, Object?> toJson() => <String, Object?>{
        'isWordToWordReplacement': isWordToWordReplacement,
        'isAdditive': isAdditive,
        'isSubtractive': isSubtractive,
        'isSingleLineToSingleLine': isSingleLineToSingleLine,
        'isSingleLineToMultiLine': isSingleLineToMultiLine,
        'isMultiLineToSingleLine': isMultiLineToSingleLine,
      };
}

class InlineSuggestionEditKindEdit {
  final String operation;
  final Object properties;
  final int charactersInserted;
  final int charactersDeleted;
  final int linesInserted;
  final int linesDeleted;

  const InlineSuggestionEditKindEdit(
    this.operation,
    this.properties,
    this.charactersInserted,
    this.charactersDeleted,
    this.linesInserted,
    this.linesDeleted,
  );

  Map<String, Object?> toJson() => <String, Object?>{
        'operation': operation,
        'properties': (properties as dynamic).toJson() as Object?,
        'charactersInserted': charactersInserted,
        'charactersDeleted': charactersDeleted,
        'linesInserted': linesInserted,
        'linesDeleted': linesDeleted,
      };
}

class InlineSuggestionEditKind {
  final List<InlineSuggestionEditKindEdit> edits;

  InlineSuggestionEditKind(this.edits);

  @override
  String toString() => jsonEncode(<String, Object?>{
        'edits': edits.map((e) => e.toJson()).toList(),
      });
}

/// 1:1: erased `ITextModel` members consumed here.
abstract class IEditKindTextModel {
  String getValue();
  Position getPositionAt(int offset);
  String getLineContent(int lineNumber);
}

/// 1:1: `computeEditKind(edit, textModel, cursorPosition?)`
InlineSuggestionEditKind? computeEditKind(
  StringEdit edit,
  IEditKindTextModel textModel, [
  Position? cursorPosition,
]) {
  if (edit.replacements.isEmpty) {
    return null;
  }
  return InlineSuggestionEditKind(edit.replacements
      .map((rep) => _computeSingleEditKind(rep, textModel, cursorPosition))
      .toList());
}

int _countLines(String text) {
  if (text.isEmpty) return 0;
  return text.split(RegExp(r'\r\n|\r|\n')).length - 1;
}

InlineSuggestionEditKindEdit _computeSingleEditKind(
  StringReplacement replacement,
  IEditKindTextModel textModel, [
  Position? cursorPosition,
]) {
  final replaceRange = replacement.replaceRange;
  final String newText = replacement.newText;
  final int deletedLength = replaceRange.length;
  final int insertedLength = newText.length;
  final int linesInserted = _countLines(newText);

  final String kind = replaceRange.isEmpty
      ? 'insert'
      : (newText.isEmpty ? 'delete' : 'replace');
  switch (kind) {
    case 'insert':
      return InlineSuggestionEditKindEdit(
        'insert',
        _computeInsertProperties(
            replaceRange.start, newText, textModel, cursorPosition),
        insertedLength,
        0,
        linesInserted,
        0,
      );
    case 'delete':
      final String deletedText = textModel
          .getValue()
          .substring(replaceRange.start, replaceRange.endExclusive);
      return InlineSuggestionEditKindEdit(
        'delete',
        _computeDeleteProperties(
            replaceRange.start, replaceRange.endExclusive, textModel),
        0,
        deletedLength,
        0,
        _countLines(deletedText),
      );
    default:
      final String oldText = textModel
          .getValue()
          .substring(replaceRange.start, replaceRange.endExclusive);
      return InlineSuggestionEditKindEdit(
        'replace',
        _computeReplaceProperties(oldText, newText),
        insertedLength,
        deletedLength,
        linesInserted,
        _countLines(oldText),
      );
  }
}

InsertProperties _computeInsertProperties(
  int offset,
  String newText,
  IEditKindTextModel textModel, [
  Position? cursorPosition,
]) {
  final TextShape textShape = analyzeTextShape(newText);
  final Position insertPosition = textModel.getPositionAt(offset);
  final String lineContent = textModel.getLineContent(insertPosition.lineNumber);
  final int lineLength = lineContent.length;

  late final String locationShape;
  final bool isLineEmpty = lineContent.trim().isEmpty;
  final bool isAtEndOfLine = insertPosition.column > lineLength;
  final bool isAtStartOfLine = insertPosition.column == 1;

  if (isLineEmpty) {
    locationShape = 'emptyLine';
  } else if (isAtEndOfLine) {
    locationShape = 'endOfLine';
  } else if (isAtStartOfLine) {
    locationShape = 'startOfLine';
  } else {
    locationShape = 'middleOfLine';
  }

  InsertLocationRelativeToCursor? relativeToCursor;
  if (cursorPosition != null) {
    final int cursorLine = cursorPosition.lineNumber;
    final int insertLine = insertPosition.lineNumber;
    final int cursorColumn = cursorPosition.column;
    final int insertColumn = insertPosition.column;

    relativeToCursor = InsertLocationRelativeToCursor(
      atCursor: cursorLine == insertLine && cursorColumn == insertColumn,
      beforeCursorOnSameLine:
          cursorLine == insertLine && insertColumn < cursorColumn,
      afterCursorOnSameLine:
          cursorLine == insertLine && insertColumn > cursorColumn,
      linesAbove: insertLine < cursorLine ? cursorLine - insertLine : null,
      linesBelow: insertLine > cursorLine ? insertLine - cursorLine : null,
    );
  }

  return InsertProperties(textShape, locationShape, relativeToCursor);
}

DeleteProperties _computeDeleteProperties(
  int startOffset,
  int endOffset,
  IEditKindTextModel textModel,
) {
  final String deletedText =
      textModel.getValue().substring(startOffset, endOffset);
  final TextShape textShape = analyzeTextShape(deletedText);

  final Position startPosition = textModel.getPositionAt(startOffset);
  final Position endPosition = textModel.getPositionAt(endOffset);
  final String lineContent = textModel.getLineContent(endPosition.lineNumber);
  final bool isAtEndOfLine = endPosition.column > lineContent.length;
  final bool deletesEntireLineContent =
      startPosition.lineNumber == endPosition.lineNumber &&
          startPosition.column == 1 &&
          endPosition.column > lineContent.length;

  return DeleteProperties(textShape, isAtEndOfLine, deletesEntireLineContent);
}

ReplaceProperties _computeReplaceProperties(String oldText, String newText) {
  final TextShape oldShape = analyzeTextShape(oldText);
  final TextShape newShape = analyzeTextShape(newText);

  final bool oldIsWord = oldShape.kind == 'singleLine' && oldShape.isWord == true;
  final bool newIsWord = newShape.kind == 'singleLine' && newShape.isWord == true;
  final bool isWordToWordReplacement = oldIsWord && newIsWord;
  final bool isAdditive = newText.length > oldText.length;
  final bool isSubtractive = newText.length < oldText.length;
  final bool isSingleLineToSingleLine =
      oldShape.kind == 'singleLine' && newShape.kind == 'singleLine';
  final bool isSingleLineToMultiLine =
      oldShape.kind == 'singleLine' && newShape.kind == 'multiLine';
  final bool isMultiLineToSingleLine =
      oldShape.kind == 'multiLine' && newShape.kind == 'singleLine';

  return ReplaceProperties(
    isWordToWordReplacement,
    isAdditive,
    isSubtractive,
    isSingleLineToSingleLine,
    isSingleLineToMultiLine,
    isMultiLineToSingleLine,
  );
}
