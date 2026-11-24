// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/contiguousTokensStore.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `Uint32Array | ArrayBuffer | null` → `Object?` (union carrier, see
//    `contiguousTokensEditing.dart`).
//  * `const enum` member names follow this port's `encodedTokenAttributes.dart`
//    spelling (`MetadataConsts.languageIdOffset`,
//    `StandardTokenType.other`, `FontStyle.none`, `ColorId.defaultForeground`).
//  * `tokens.byteOffset`/`byteLength` → `offsetInBytes`/`lengthInBytes`.
//  * `splice` → `removeRange`; `arrayInsert` reused from `base/common/arrays.dart`.
//  * `{ changes: [...] }` return literal → a Dart record with the same shape.
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import '../../../base/common/arrays.dart' as arrays;
import '../core/position.dart' show Position;
import '../core/range.dart' show IRange;
import '../encodedTokenAttributes.dart'
    show ColorId, FontStyle, MetadataConsts, StandardTokenType, TokenMetadata;
import './contiguousMultilineTokens.dart' show ContiguousMultilineTokens;
import './contiguousTokensEditing.dart'
    show ContiguousTokensEditing, EMPTY_LINE_TOKENS, toUint32Array;
import './lineTokens.dart' show ILanguageIdCodec, ITextModel, LineTokens;

/// Represents contiguous tokens in a text model.
class ContiguousTokensStore {
  List<Object?> _lineTokens;
  int _len;
  final ILanguageIdCodec _languageIdCodec;

  ContiguousTokensStore(this._languageIdCodec)
      : _lineTokens = <Object?>[],
        _len = 0;

  void flush() {
    _lineTokens = <Object?>[];
    _len = 0;
  }

  bool get hasTokens => _lineTokens.isNotEmpty;

  LineTokens getTokens(
      String topLevelLanguageId, int lineIndex, String lineText) {
    Object? rawLineTokens;
    if (lineIndex < _len) {
      rawLineTokens = _lineTokens[lineIndex];
    }

    if (rawLineTokens != null && !identical(rawLineTokens, EMPTY_LINE_TOKENS)) {
      return LineTokens(
          toUint32Array(rawLineTokens), lineText, _languageIdCodec);
    }

    final Uint32List lineTokens = Uint32List(2);
    lineTokens[0] = lineText.length;
    lineTokens[1] = _getDefaultMetadata(
        _languageIdCodec.encodeLanguageId(topLevelLanguageId));
    return LineTokens(lineTokens, lineText, _languageIdCodec);
  }

  static Object _massageTokens(int topLevelLanguageId, int lineTextLength,
      Object? _tokens) {
    final Uint32List? tokens = _tokens != null ? toUint32Array(_tokens) : null;

    if (lineTextLength == 0) {
      bool hasDifferentLanguageId = false;
      if (tokens != null && tokens.length > 1) {
        hasDifferentLanguageId =
            (TokenMetadata.getLanguageId(tokens[1]) != topLevelLanguageId);
      }

      if (!hasDifferentLanguageId) {
        return EMPTY_LINE_TOKENS;
      }
    }

    if (tokens == null || tokens.isEmpty) {
      final Uint32List tokens = Uint32List(2);
      tokens[0] = lineTextLength;
      tokens[1] = _getDefaultMetadata(topLevelLanguageId);
      return tokens.buffer;
    }

    // Ensure the last token covers the end of the text
    tokens[tokens.length - 2] = lineTextLength;

    if (tokens.offsetInBytes == 0 &&
        tokens.lengthInBytes == tokens.buffer.lengthInBytes) {
      // Store directly the ArrayBuffer pointer to save an object
      return tokens.buffer;
    }
    return tokens;
  }

  void _ensureLine(int lineIndex) {
    while (lineIndex >= _len) {
      _lineTokens.add(null);
      _len++;
    }
  }

  void _deleteLines(int start, int deleteCount) {
    if (deleteCount == 0) {
      return;
    }
    if (start + deleteCount > _len) {
      deleteCount = _len - start;
    }
    _lineTokens.removeRange(start, start + deleteCount);
    _len -= deleteCount;
  }

  void _insertLines(int insertIndex, int insertCount) {
    if (insertCount == 0) {
      return;
    }
    final List<Object?> lineTokens = <Object?>[];
    for (int i = 0; i < insertCount; i++) {
      lineTokens.add(null);
    }
    _lineTokens = arrays.arrayInsert(_lineTokens, insertIndex, lineTokens);
    _len += insertCount;
  }

  bool setTokens(String topLevelLanguageId, int lineIndex, int lineTextLength,
      Object? _tokens, bool checkEquality) {
    final Object tokens = ContiguousTokensStore._massageTokens(
        _languageIdCodec.encodeLanguageId(topLevelLanguageId),
        lineTextLength,
        _tokens);
    _ensureLine(lineIndex);
    final Object? oldTokens = _lineTokens[lineIndex];
    _lineTokens[lineIndex] = tokens;

    if (checkEquality) {
      return !ContiguousTokensStore._equals(oldTokens, tokens);
    }
    return false;
  }

  static bool _equals(Object? _a, Object? _b) {
    if (_a == null || _b == null) {
      return _a == null && _b == null;
    }

    final Uint32List a = toUint32Array(_a);
    final Uint32List b = toUint32Array(_b);

    if (a.length != b.length) {
      return false;
    }
    for (int i = 0, len = a.length; i < len; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  //#region Editing

  void acceptEdit(IRange range, int eolCount, int firstLineLength) {
    _acceptDeleteRange(range);
    _acceptInsertText(
        Position(range.startLineNumber, range.startColumn), eolCount,
        firstLineLength);
  }

  void _acceptDeleteRange(IRange range) {
    final int firstLineIndex = range.startLineNumber - 1;
    if (firstLineIndex >= _len) {
      return;
    }

    if (range.startLineNumber == range.endLineNumber) {
      if (range.startColumn == range.endColumn) {
        // Nothing to delete
        return;
      }

      _lineTokens[firstLineIndex] = ContiguousTokensEditing.delete(
          _lineTokens[firstLineIndex],
          range.startColumn - 1,
          range.endColumn - 1);
      return;
    }

    _lineTokens[firstLineIndex] = ContiguousTokensEditing.deleteEnding(
        _lineTokens[firstLineIndex], range.startColumn - 1);

    final int lastLineIndex = range.endLineNumber - 1;
    Object? lastLineTokens;
    if (lastLineIndex < _len) {
      lastLineTokens = ContiguousTokensEditing.deleteBeginning(
          _lineTokens[lastLineIndex], range.endColumn - 1);
    }

    // Take remaining text on last line and append it to remaining text on
    // first line
    _lineTokens[firstLineIndex] = ContiguousTokensEditing.append(
        _lineTokens[firstLineIndex], lastLineTokens);

    // Delete middle lines
    _deleteLines(
        range.startLineNumber, range.endLineNumber - range.startLineNumber);
  }

  void _acceptInsertText(Position position, int eolCount, int firstLineLength) {
    if (eolCount == 0 && firstLineLength == 0) {
      // Nothing to insert
      return;
    }

    final int lineIndex = position.lineNumber - 1;
    if (lineIndex >= _len) {
      return;
    }

    if (eolCount == 0) {
      // Inserting text on one line
      _lineTokens[lineIndex] = ContiguousTokensEditing.insert(
          _lineTokens[lineIndex], position.column - 1, firstLineLength);
      return;
    }

    _lineTokens[lineIndex] = ContiguousTokensEditing.deleteEnding(
        _lineTokens[lineIndex], position.column - 1);
    _lineTokens[lineIndex] = ContiguousTokensEditing.insert(
        _lineTokens[lineIndex], position.column - 1, firstLineLength);

    _insertLines(position.lineNumber, eolCount);
  }

  //#endregion

  ({List<({int fromLineNumber, int toLineNumber})> changes}) setMultilineTokens(
      List<ContiguousMultilineTokens> tokens, ITextModel textModel) {
    if (tokens.isEmpty) {
      return (changes: <({int fromLineNumber, int toLineNumber})>[]);
    }

    final List<({int fromLineNumber, int toLineNumber})> ranges =
        <({int fromLineNumber, int toLineNumber})>[];

    for (int i = 0, len = tokens.length; i < len; i++) {
      final ContiguousMultilineTokens element = tokens[i];
      int minChangedLineNumber = 0;
      int maxChangedLineNumber = 0;
      bool hasChange = false;
      for (int lineNumber = element.startLineNumber;
          lineNumber <= element.endLineNumber;
          lineNumber++) {
        if (hasChange) {
          setTokens(
              textModel.getLanguageId(),
              lineNumber - 1,
              textModel.getLineLength(lineNumber),
              element.getLineTokens(lineNumber),
              false);
          maxChangedLineNumber = lineNumber;
        } else {
          final bool lineHasChange = setTokens(
              textModel.getLanguageId(),
              lineNumber - 1,
              textModel.getLineLength(lineNumber),
              element.getLineTokens(lineNumber),
              true);
          if (lineHasChange) {
            hasChange = true;
            minChangedLineNumber = lineNumber;
            maxChangedLineNumber = lineNumber;
          }
        }
      }
      if (hasChange) {
        ranges.add((
          fromLineNumber: minChangedLineNumber,
          toLineNumber: maxChangedLineNumber,
        ));
      }
    }

    return (changes: ranges);
  }
}

int _getDefaultMetadata(int topLevelLanguageId) {
  return ((topLevelLanguageId << MetadataConsts.languageIdOffset) |
          (StandardTokenType.other << MetadataConsts.tokenTypeOffset) |
          (FontStyle.none << MetadataConsts.fontStyleOffset) |
          (ColorId.defaultForeground << MetadataConsts.foregroundOffset) |
          (ColorId.defaultBackground << MetadataConsts.backgroundOffset)
      // If there is no grammar, we just take a guess and try to match brackets.
      |
      (MetadataConsts.balancedBracketsMask)) &
      0xFFFFFFFF;
}