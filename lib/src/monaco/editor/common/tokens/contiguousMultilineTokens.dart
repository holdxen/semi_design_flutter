// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/contiguousMultilineTokens.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `Uint32Array | ArrayBuffer | null` → `Object?` (union carrier).
//  * `new Uint32Array(buff.buffer)` → `Uint32List.view(buff.buffer)` (both are
//    views over the whole buffer).
//  * `view32.subarray(a, b)` → `Uint32List.sublistView(view32, a, b)`.
//  * `new Uint8Array(lineTokens.buffer)` → `Uint8List.view(lineTokens.buffer)`.
//  * `countEOL` returns a Dart record of 4 ints (source destructures 2).
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import '../../../base/common/arrays.dart' as arrays;
import '../../../base/common/buffer.dart' as buffer;
import '../core/misc/eolCounter.dart' show countEOL;
import '../core/position.dart' show Position;
import '../core/range.dart' show IRange;
import '../core/ranges/lineRange.dart' show LineRange;
import './contiguousTokensEditing.dart' show ContiguousTokensEditing;

/// Represents contiguous tokens over a contiguous range of lines.
class ContiguousMultilineTokens {
  static int deserialize(
      Uint8List buff, int offset, List<ContiguousMultilineTokens> result) {
    final Uint32List view32 = Uint32List.view(buff.buffer);
    final int startLineNumber = buffer.readUInt32BE_(buff, offset);
    offset += 4;
    final int count = buffer.readUInt32BE_(buff, offset);
    offset += 4;
    final List<Uint32List> tokens = <Uint32List>[];
    for (int i = 0; i < count; i++) {
      final int byteCount = buffer.readUInt32BE_(buff, offset);
      offset += 4;
      tokens.add(Uint32List.sublistView(
          view32, offset ~/ 4, offset ~/ 4 + byteCount ~/ 4));
      offset += byteCount;
    }
    result.add(ContiguousMultilineTokens(startLineNumber, tokens));
    return offset;
  }

  /// The start line number for this block of tokens.
  int _startLineNumber;

  /// The tokens are stored in a binary format. There is an element for each
  /// line, so `tokens[index]` contains all tokens on line
  /// `startLineNumber + index`.
  ///
  /// On a specific line, each token occupies two array indices. For token i:
  ///  - at offset 2*i => endOffset
  ///  - at offset 2*i + 1 => metadata
  List<Object?> _tokens;

  /// (Inclusive) start line number for these tokens.
  int get startLineNumber {
    return _startLineNumber;
  }

  /// (Inclusive) end line number for these tokens.
  int get endLineNumber {
    return _startLineNumber + _tokens.length - 1;
  }

  ContiguousMultilineTokens(int startLineNumber, List<Uint32List> tokens)
      : _startLineNumber = startLineNumber,
        _tokens = List<Object?>.from(tokens);

  LineRange getLineRange() {
    return LineRange(_startLineNumber, _startLineNumber + _tokens.length);
  }

  /// @see [_tokens]
  Object? getLineTokens(int lineNumber) {
    return _tokens[lineNumber - _startLineNumber];
  }

  void appendLineTokens(Uint32List lineTokens) {
    _tokens.add(lineTokens);
  }

  int serializeSize() {
    int result = 0;
    result += 4; // 4 bytes for the start line number
    result += 4; // 4 bytes for the line count
    for (int i = 0; i < _tokens.length; i++) {
      final Object? lineTokens = _tokens[i];
      if (lineTokens is! Uint32List) {
        throw StateError('Not supported!');
      }
      result += 4; // 4 bytes for the byte count
      result += lineTokens.lengthInBytes;
    }
    return result;
  }

  int serialize(Uint8List destination, int offset) {
    buffer.writeUInt32BE_(destination, _startLineNumber, offset);
    offset += 4;
    buffer.writeUInt32BE_(destination, _tokens.length, offset);
    offset += 4;
    for (int i = 0; i < _tokens.length; i++) {
      final Object? lineTokens = _tokens[i];
      if (lineTokens is! Uint32List) {
        throw StateError('Not supported!');
      }
      // TS copies `new Uint8Array(lineTokens.buffer)` (the whole buffer) but
      // advances by `lineTokens.byteLength`; reproduced verbatim.
      final Uint8List bytes = Uint8List.view(lineTokens.buffer);
      buffer.writeUInt32BE_(destination, lineTokens.lengthInBytes, offset);
      offset += 4;
      destination.setRange(offset, offset + bytes.length, bytes);
      offset += lineTokens.lengthInBytes;
    }
    return offset;
  }

  void applyEdit(IRange range, String text) {
    final (int, int, int, int) eol = countEOL(text);
    final int eolCount = eol.$1;
    final int firstLineLength = eol.$2;
    _acceptDeleteRange(range);
    _acceptInsertText(
        Position(range.startLineNumber, range.startColumn), eolCount,
        firstLineLength);
  }

  void _acceptDeleteRange(IRange range) {
    if (range.startLineNumber == range.endLineNumber &&
        range.startColumn == range.endColumn) {
      // Nothing to delete
      return;
    }

    final int firstLineIndex = range.startLineNumber - _startLineNumber;
    final int lastLineIndex = range.endLineNumber - _startLineNumber;

    if (lastLineIndex < 0) {
      // this deletion occurs entirely before this block, so we only need to
      // adjust line numbers
      final int deletedLinesCount = lastLineIndex - firstLineIndex;
      _startLineNumber -= deletedLinesCount;
      return;
    }

    if (firstLineIndex >= _tokens.length) {
      // this deletion occurs entirely after this block, so there is nothing to do
      return;
    }

    if (firstLineIndex < 0 && lastLineIndex >= _tokens.length) {
      // this deletion completely encompasses this block
      _startLineNumber = 0;
      _tokens = <Object?>[];
      return;
    }

    if (firstLineIndex == lastLineIndex) {
      // a delete on a single line
      _tokens[firstLineIndex] = ContiguousTokensEditing.delete(
          _tokens[firstLineIndex],
          range.startColumn - 1,
          range.endColumn - 1);
      return;
    }

    if (firstLineIndex >= 0) {
      // The first line survives
      _tokens[firstLineIndex] = ContiguousTokensEditing.deleteEnding(
          _tokens[firstLineIndex], range.startColumn - 1);

      if (lastLineIndex < _tokens.length) {
        // The last line survives
        final Object? lastLineTokens = ContiguousTokensEditing.deleteBeginning(
            _tokens[lastLineIndex], range.endColumn - 1);

        // Take remaining text on last line and append it to remaining text on
        // first line
        _tokens[firstLineIndex] = ContiguousTokensEditing.append(
            _tokens[firstLineIndex], lastLineTokens);

        // Delete middle lines
        _tokens.removeRange(firstLineIndex + 1, lastLineIndex + 1);
      } else {
        // The last line does not survive

        // Take remaining text on last line and append it to remaining text on
        // first line
        _tokens[firstLineIndex] = ContiguousTokensEditing.append(
            _tokens[firstLineIndex], null);

        // Delete lines
        _tokens = _tokens.sublist(0, firstLineIndex + 1);
      }
    } else {
      // The first line does not survive

      final int deletedBefore = -firstLineIndex;
      _startLineNumber -= deletedBefore;

      // Remove beginning from last line
      _tokens[lastLineIndex] = ContiguousTokensEditing.deleteBeginning(
          _tokens[lastLineIndex], range.endColumn - 1);

      // Delete lines
      _tokens = _tokens.sublist(lastLineIndex);
    }
  }

  void _acceptInsertText(
      Position position, int eolCount, int firstLineLength) {
    if (eolCount == 0 && firstLineLength == 0) {
      // Nothing to insert
      return;
    }

    final int lineIndex = position.lineNumber - _startLineNumber;

    if (lineIndex < 0) {
      // this insertion occurs before this block, so we only need to adjust
      // line numbers
      _startLineNumber += eolCount;
      return;
    }

    if (lineIndex >= _tokens.length) {
      // this insertion occurs after this block, so there is nothing to do
      return;
    }

    if (eolCount == 0) {
      // Inserting text on one line
      _tokens[lineIndex] = ContiguousTokensEditing.insert(
          _tokens[lineIndex], position.column - 1, firstLineLength);
      return;
    }

    _tokens[lineIndex] = ContiguousTokensEditing.deleteEnding(
        _tokens[lineIndex], position.column - 1);
    _tokens[lineIndex] = ContiguousTokensEditing.insert(
        _tokens[lineIndex], position.column - 1, firstLineLength);

    _insertLines(position.lineNumber, eolCount);
  }

  void _insertLines(int insertIndex, int insertCount) {
    if (insertCount == 0) {
      return;
    }
    final List<Object?> lineTokens = <Object?>[];
    for (int i = 0; i < insertCount; i++) {
      lineTokens.add(null);
    }
    _tokens = arrays.arrayInsert(_tokens, insertIndex, lineTokens);
  }
}