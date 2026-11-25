// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/sparseTokensStore.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * `Uint32Array` -> `Uint32List`; JS `>>> 0` -> [_u32] (Dart int is unbounded).
//  * Interfaces `ILanguageIdCodec` / `ITextModel` are carried by the existing
//    repo contracts; `_pieces` is exposed via [pieces] for truth replay only.
//  * `Array.splice` -> `List.removeAt` / `List.setRange` equivalents.
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import '../../../base/common/arrays.dart' show arrayInsert;
import '../core/range.dart' show IRange, Range;
import '../encodedTokenAttributes.dart' show MetadataConsts;
import './lineTokens.dart' show ILanguageIdCodec, LineTokens;
import './sparseMultilineTokens.dart'
    show ITextModelForSparseTokens, SparseLineTokens, SparseMultilineTokens;

/// 1:1: JS `>>> 0` (unsigned 32-bit normalization).
int _u32(int v) => v & 0xFFFFFFFF;

/// Represents sparse tokens in a text model.
class SparseTokensStore {
  List<SparseMultilineTokens> _pieces;
  bool _isComplete;
  final ILanguageIdCodec _languageIdCodec;

  SparseTokensStore(ILanguageIdCodec languageIdCodec)
      : _pieces = <SparseMultilineTokens>[],
        _isComplete = false,
        _languageIdCodec = languageIdCodec;

  /// Replay-only view of `_pieces` (TS private field is reachable at runtime).
  List<SparseMultilineTokens> get pieces => _pieces;

  void flush() {
    _pieces = <SparseMultilineTokens>[];
    _isComplete = false;
  }

  bool isEmpty() {
    return (_pieces.length == 0);
  }

  void set(List<SparseMultilineTokens>? pieces, bool isComplete,
      [ITextModelForSparseTokens? textModel]) {
    _pieces = pieces ?? <SparseMultilineTokens>[];
    _isComplete = isComplete;

    if (textModel != null) {
      for (final SparseMultilineTokens p in _pieces) {
        p.reportIfInvalid(textModel);
      }
    }
  }

  Range setPartial(Range _range, List<SparseMultilineTokens> pieces) {
    Range range = _range;
    if (pieces.isNotEmpty) {
      final Range? _firstRange = pieces[0].getRange();
      final Range? _lastRange = pieces[pieces.length - 1].getRange();
      if (_firstRange == null || _lastRange == null) {
        return _range;
      }
      range = range.plusRange(_firstRange).plusRange(_lastRange);
    }

    int? insertPosition;
    for (int i = 0, len = _pieces.length; i < len; i++) {
      final SparseMultilineTokens piece = _pieces[i];
      if (piece.endLineNumber < range.startLineNumber) {
        // this piece is before the range
        continue;
      }

      if (piece.startLineNumber > range.endLineNumber) {
        // this piece is after the range, so mark the spot before this piece
        // as a good insertion position and stop looping
        insertPosition ??= i;
        break;
      }

      // this piece might intersect with the range
      piece.removeTokens(range);

      if (piece.isEmpty()) {
        // remove the piece if it became empty
        _pieces.removeAt(i);
        i--;
        len--;
        continue;
      }

      if (piece.endLineNumber < range.startLineNumber) {
        // after removal, this piece is before the range
        continue;
      }

      if (piece.startLineNumber > range.endLineNumber) {
        // after removal, this piece is after the range
        insertPosition ??= i;
        continue;
      }

      // after removal, this piece contains the range
      final List<SparseMultilineTokens> split = piece.split(range);
      final SparseMultilineTokens a = split[0];
      final SparseMultilineTokens b = split[1];
      if (a.isEmpty()) {
        // this piece is actually after the range
        insertPosition ??= i;
        continue;
      }
      if (b.isEmpty()) {
        // this piece is actually before the range
        continue;
      }
      // Dart: JS `_pieces.splice(i, 1, a, b)`
      _pieces[i] = a;
      _pieces.insert(i + 1, b);
      i++;
      len++;

      insertPosition ??= i;
    }

    insertPosition ??= _pieces.length;

    if (pieces.isNotEmpty) {
      _pieces = arrayInsert<SparseMultilineTokens>(
          _pieces, insertPosition, pieces);
    }

    return range;
  }

  bool isComplete() {
    return _isComplete;
  }

  LineTokens addSparseTokens(int lineNumber, LineTokens aTokens) {
    if (aTokens.getTextLength() == 0) {
      // Don't do anything for empty lines
      return aTokens;
    }

    final List<SparseMultilineTokens> pieces = _pieces;

    if (pieces.isEmpty) {
      return aTokens;
    }

    final int pieceIndex =
        SparseTokensStore._findFirstPieceWithLine(pieces, lineNumber);
    final SparseLineTokens? bTokens = pieces[pieceIndex].getLineTokens(lineNumber);

    if (bTokens == null) {
      return aTokens;
    }

    final int aLen = aTokens.getCount();
    final int bLen = bTokens.getCount();

    int aIndex = 0;
    final List<int> result = <int>[];
    int lastEndOffset = 0;

    void emitToken(int endOffset, int metadata) {
      if (endOffset <= lastEndOffset) {
        return;
      }
      lastEndOffset = endOffset;
      // Dart: JS `result[resultLen++] = v` -> `result.add(v)` (sequential).
      result.add(endOffset);
      result.add(metadata);
    }

    for (int bIndex = 0; bIndex < bLen; bIndex++) {
      // bTokens is not validated yet, but aTokens is. We want to make sure
      // that the LineTokens we return are valid, so clamp the ranges.
      final int bStartCharacter = _min(
          bTokens.getStartCharacter(bIndex), aTokens.getTextLength());
      final int bEndCharacter =
          _min(bTokens.getEndCharacter(bIndex), aTokens.getTextLength());
      final int bMetadata = bTokens.getMetadata(bIndex);

      final int bMask = _u32(
        ((bMetadata & MetadataConsts.semanticUseItalic) != 0
                ? MetadataConsts.italicMask
                : 0) |
            ((bMetadata & MetadataConsts.semanticUseBold) != 0
                ? MetadataConsts.boldMask
                : 0) |
            ((bMetadata & MetadataConsts.semanticUseUnderline) != 0
                ? MetadataConsts.underlineMask
                : 0) |
            ((bMetadata & MetadataConsts.semanticUseStrikethrough) != 0
                ? MetadataConsts.strikethroughMask
                : 0) |
            ((bMetadata & MetadataConsts.semanticUseForeground) != 0
                ? MetadataConsts.foregroundMask
                : 0) |
            ((bMetadata & MetadataConsts.semanticUseBackground) != 0
                ? MetadataConsts.backgroundMask
                : 0),
      );
      final int aMask = _u32(~bMask);

      // push any token from `a` that is before `b`
      while (aIndex < aLen && aTokens.getEndOffset(aIndex) <= bStartCharacter) {
        emitToken(aTokens.getEndOffset(aIndex), aTokens.getMetadata(aIndex));
        aIndex++;
      }

      // push the token from `a` if it intersects the token from `b`
      if (aIndex < aLen && aTokens.getStartOffset(aIndex) < bStartCharacter) {
        emitToken(bStartCharacter, aTokens.getMetadata(aIndex));
      }

      // skip any tokens from `a` that are contained inside `b`
      while (aIndex < aLen && aTokens.getEndOffset(aIndex) < bEndCharacter) {
        emitToken(aTokens.getEndOffset(aIndex),
            _u32((aTokens.getMetadata(aIndex) & aMask) | (bMetadata & bMask)));
        aIndex++;
      }

      if (aIndex < aLen) {
        emitToken(bEndCharacter,
            _u32((aTokens.getMetadata(aIndex) & aMask) | (bMetadata & bMask)));
        if (aTokens.getEndOffset(aIndex) == bEndCharacter) {
          // `a` ends exactly at the same spot as `b`!
          aIndex++;
        }
      } else {
        final int aMergeIndex =
            _max(0, aIndex - 1) > aLen - 1 ? aLen - 1 : _max(0, aIndex - 1);

        // push the token from `b`
        emitToken(bEndCharacter,
            _u32((aTokens.getMetadata(aMergeIndex) & aMask) | (bMetadata & bMask)));
      }
    }

    // push the remaining tokens from `a`
    while (aIndex < aLen) {
      emitToken(aTokens.getEndOffset(aIndex), aTokens.getMetadata(aIndex));
      aIndex++;
    }

    return LineTokens(
        Uint32List.fromList(result), aTokens.getLineContent(), _languageIdCodec);
  }

  static int _findFirstPieceWithLine(
      List<SparseMultilineTokens> pieces, int lineNumber) {
    int low = 0;
    int high = pieces.length - 1;

    while (low < high) {
      int mid = low + ((high - low) / 2).floor();

      if (pieces[mid].endLineNumber < lineNumber) {
        low = mid + 1;
      } else if (pieces[mid].startLineNumber > lineNumber) {
        high = mid - 1;
      } else {
        while (mid > low &&
            pieces[mid - 1].startLineNumber <= lineNumber &&
            lineNumber <= pieces[mid - 1].endLineNumber) {
          mid--;
        }
        return mid;
      }
    }

    return low;
  }

  void acceptEdit(IRange range, int eolCount, int firstLineLength,
      int lastLineLength, int firstCharCode) {
    for (int i = 0; i < _pieces.length; i++) {
      final SparseMultilineTokens piece = _pieces[i];
      piece.acceptEdit(
          range, eolCount, firstLineLength, lastLineLength, firstCharCode);

      if (piece.isEmpty()) {
        // Remove empty pieces
        _pieces.removeAt(i);
        i--;
      }
    }
  }
}

int _min(int a, int b) => a < b ? a : b;
int _max(int a, int b) => a > b ? a : b;
