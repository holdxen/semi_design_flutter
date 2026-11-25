// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/sparseMultilineTokens.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * `Uint32Array` -> `Uint32List`; `subarray` -> `Uint32List.sublistView`.
//  * JS out-of-bounds typed array reads (undefined) -> explicit bounds checks
//    at the two sites that can observe them (`getLineTokens` on empty storage).
//  * `console.error` -> injectable [sparseTokensConsoleError] provider.
//  * `ITextModel` (from `../model.ts`) is erased to the minimal structural
//    contract actually read by `reportIfInvalid` (repo convention for TS
//    interfaces).
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import '../../../base/common/charCode.dart' show CharCode;
import '../core/misc/eolCounter.dart' show countEOL;
import '../core/position.dart' show Position;
import '../core/range.dart' show IRange, Range;
import './common.dart' show RateLimiter;

/// 1:1: `console.error` used by `reportIfInvalid`.
void Function(String message) sparseTokensConsoleError = (String message) {};

/// 1:1: `ITextModel` members read by `reportIfInvalid`.
abstract class ITextModelForSparseTokens {
  int getLineCount();
  int getLineLength(int lineNumber);
}

/// Represents sparse tokens over a contiguous range of lines.
class SparseMultilineTokens {
  late int _startLineNumber;
  late int _endLineNumber;
  final SparseMultilineTokensStorage _tokens;

  /// 1:1: `public static create(startLineNumber: number, tokens: Uint32Array)`
  static SparseMultilineTokens create(int startLineNumber, Uint32List tokens) {
    return SparseMultilineTokens._(
        startLineNumber, SparseMultilineTokensStorage(tokens));
  }

  /// (Inclusive) start line number for these tokens.
  int get startLineNumber {
    return _startLineNumber;
  }

  /// (Inclusive) end line number for these tokens.
  int get endLineNumber {
    return _endLineNumber;
  }

  SparseMultilineTokens._(int startLineNumber, SparseMultilineTokensStorage tokens)
      : _tokens = tokens {
    _startLineNumber = startLineNumber;
    _endLineNumber = _startLineNumber + _tokens.getMaxDeltaLine();
  }

  @override
  String toString() {
    return _tokens.toString(_startLineNumber);
  }

  void _updateEndLineNumber() {
    _endLineNumber = _startLineNumber + _tokens.getMaxDeltaLine();
  }

  bool isEmpty() {
    return _tokens.isEmpty();
  }

  SparseLineTokens? getLineTokens(int lineNumber) {
    if (_startLineNumber <= lineNumber && lineNumber <= _endLineNumber) {
      return _tokens.getLineTokens(lineNumber - _startLineNumber);
    }
    return null;
  }

  Range? getRange() {
    final Range? deltaRange = _tokens.getRange();
    if (deltaRange == null) {
      return deltaRange;
    }
    return Range(
        _startLineNumber + deltaRange.startLineNumber,
        deltaRange.startColumn,
        _startLineNumber + deltaRange.endLineNumber,
        deltaRange.endColumn);
  }

  void removeTokens(Range range) {
    final int startLineIndex = range.startLineNumber - _startLineNumber;
    final int endLineIndex = range.endLineNumber - _startLineNumber;

    _startLineNumber += _tokens.removeTokens(startLineIndex,
        range.startColumn - 1, endLineIndex, range.endColumn - 1);
    _updateEndLineNumber();
  }

  List<SparseMultilineTokens> split(Range range) {
    // split tokens to two:
    // a) all the tokens before `range`
    // b) all the tokens after `range`
    final int startLineIndex = range.startLineNumber - _startLineNumber;
    final int endLineIndex = range.endLineNumber - _startLineNumber;

    final List<Object> parts = _tokens.split(
        startLineIndex, range.startColumn - 1, endLineIndex, range.endColumn - 1);
    final SparseMultilineTokensStorage a = parts[0] as SparseMultilineTokensStorage;
    final SparseMultilineTokensStorage b = parts[1] as SparseMultilineTokensStorage;
    final int bDeltaLine = parts[2] as int;
    return [
      SparseMultilineTokens._(_startLineNumber, a),
      SparseMultilineTokens._(_startLineNumber + bDeltaLine, b),
    ];
  }

  void applyEdit(IRange range, String text) {
    final (int eolCount, int firstLineLength, int lastLineLength, int _) =
        countEOL(text);
    acceptEdit(
        range,
        eolCount,
        firstLineLength,
        lastLineLength,
        text.isNotEmpty ? text.codeUnitAt(0) : CharCode.Null);
  }

  void acceptEdit(IRange range, int eolCount, int firstLineLength,
      int lastLineLength, int firstCharCode) {
    _acceptDeleteRange(range);
    _acceptInsertText(
        Position(range.startLineNumber, range.startColumn),
        eolCount,
        firstLineLength,
        lastLineLength,
        firstCharCode);
    _updateEndLineNumber();
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
      // this deletion occurs entirely before this block, so we only need to adjust line numbers
      final int deletedLinesCount = lastLineIndex - firstLineIndex;
      _startLineNumber -= deletedLinesCount;
      return;
    }

    final int tokenMaxDeltaLine = _tokens.getMaxDeltaLine();

    if (firstLineIndex >= tokenMaxDeltaLine + 1) {
      // this deletion occurs entirely after this block, so there is nothing to do
      return;
    }

    if (firstLineIndex < 0 && lastLineIndex >= tokenMaxDeltaLine + 1) {
      // this deletion completely encompasses this block
      _startLineNumber = 0;
      _tokens.clear();
      return;
    }

    if (firstLineIndex < 0) {
      final int deletedBefore = -firstLineIndex;
      _startLineNumber -= deletedBefore;

      _tokens.acceptDeleteRange(
          range.startColumn - 1, 0, 0, lastLineIndex, range.endColumn - 1);
    } else {
      _tokens.acceptDeleteRange(0, firstLineIndex, range.startColumn - 1,
          lastLineIndex, range.endColumn - 1);
    }
  }

  void _acceptInsertText(Position position, int eolCount, int firstLineLength,
      int lastLineLength, int firstCharCode) {
    if (eolCount == 0 && firstLineLength == 0) {
      // Nothing to insert
      return;
    }

    final int lineIndex = position.lineNumber - _startLineNumber;

    if (lineIndex < 0) {
      // this insertion occurs before this block, so we only need to adjust line numbers
      _startLineNumber += eolCount;
      return;
    }

    final int tokenMaxDeltaLine = _tokens.getMaxDeltaLine();

    if (lineIndex >= tokenMaxDeltaLine + 1) {
      // this insertion occurs after this block, so there is nothing to do
      return;
    }

    _tokens.acceptInsertText(lineIndex, position.column - 1, eolCount,
        firstLineLength, lastLineLength, firstCharCode);
  }

  void reportIfInvalid(ITextModelForSparseTokens model) {
    _tokens.reportIfInvalid(model, _startLineNumber);
  }
}

class SparseMultilineTokensStorage {
  /// The encoding of tokens is:
  ///  4*i    deltaLine (from `startLineNumber`)
  ///  4*i+1  startCharacter (from the line start)
  ///  4*i+2  endCharacter (from the line start)
  ///  4*i+3  metadata
  final Uint32List _tokens;
  int _tokenCount;

  SparseMultilineTokensStorage(Uint32List tokens)
      : _tokens = tokens,
        _tokenCount = tokens.length ~/ 4;

  /// Dart: `Object.toString()` has no parameters, so the TS
  /// `toString(startLineNumber)` becomes an optional positional parameter.
  @override
  String toString([int startLineNumber = 0]) {
    final List<String> pieces = <String>[];
    for (int i = 0; i < _tokenCount; i++) {
      pieces.add('(${_getDeltaLine(i) + startLineNumber},'
          '${_getStartCharacter(i)}-${_getEndCharacter(i)})');
    }
    return '[${pieces.join(',')}]';
  }

  int getMaxDeltaLine() {
    final int tokenCount = _getTokenCount();
    if (tokenCount == 0) {
      return -1;
    }
    return _getDeltaLine(tokenCount - 1);
  }

  Range? getRange() {
    final int tokenCount = _getTokenCount();
    if (tokenCount == 0) {
      return null;
    }
    final int startChar = _getStartCharacter(0);
    final int maxDeltaLine = _getDeltaLine(tokenCount - 1);
    final int endChar = _getEndCharacter(tokenCount - 1);
    return Range(0, startChar + 1, maxDeltaLine, endChar + 1);
  }

  int _getTokenCount() {
    return _tokenCount;
  }

  int _getDeltaLine(int tokenIndex) {
    return _tokens[4 * tokenIndex];
  }

  int _getStartCharacter(int tokenIndex) {
    return _tokens[4 * tokenIndex + 1];
  }

  int _getEndCharacter(int tokenIndex) {
    return _tokens[4 * tokenIndex + 2];
  }

  bool isEmpty() {
    return (_getTokenCount() == 0);
  }

  SparseLineTokens? getLineTokens(int deltaLine) {
    int low = 0;
    int high = _getTokenCount() - 1;

    while (low < high) {
      final int mid = low + ((high - low) >> 1);
      final int midDeltaLine = _getDeltaLine(mid);

      if (midDeltaLine < deltaLine) {
        low = mid + 1;
      } else if (midDeltaLine > deltaLine) {
        high = mid - 1;
      } else {
        int min = mid;
        while (min > low && _getDeltaLine(min - 1) == deltaLine) {
          min--;
        }
        int max = mid;
        while (max < high && _getDeltaLine(max + 1) == deltaLine) {
          max++;
        }
        return SparseLineTokens(
            Uint32List.sublistView(_tokens, 4 * min, 4 * max + 4));
      }
    }

    // JS: `this._tokens[4 * low]` is `undefined` for an empty storage, which
    // never equals a number. The explicit guard reproduces that observable.
    if (low < _getTokenCount() && _getDeltaLine(low) == deltaLine) {
      return SparseLineTokens(
          Uint32List.sublistView(_tokens, 4 * low, 4 * low + 4));
    }

    return null;
  }

  void clear() {
    _tokenCount = 0;
  }

  int removeTokens(
      int startDeltaLine, int startChar, int endDeltaLine, int endChar) {
    final Uint32List tokens = _tokens;
    final int tokenCount = _tokenCount;
    int newTokenCount = 0;
    bool hasDeletedTokens = false;
    int firstDeltaLine = 0;
    for (int i = 0; i < tokenCount; i++) {
      final int srcOffset = 4 * i;
      final int tokenDeltaLine = tokens[srcOffset];
      final int tokenStartCharacter = tokens[srcOffset + 1];
      final int tokenEndCharacter = tokens[srcOffset + 2];
      final int tokenMetadata = tokens[srcOffset + 3];

      if ((tokenDeltaLine > startDeltaLine ||
              (tokenDeltaLine == startDeltaLine &&
                  tokenEndCharacter >= startChar)) &&
          (tokenDeltaLine < endDeltaLine ||
              (tokenDeltaLine == endDeltaLine &&
                  tokenStartCharacter <= endChar))) {
        hasDeletedTokens = true;
      } else {
        if (newTokenCount == 0) {
          firstDeltaLine = tokenDeltaLine;
        }
        if (hasDeletedTokens) {
          // must move the token to the left
          final int destOffset = 4 * newTokenCount;
          tokens[destOffset] = tokenDeltaLine - firstDeltaLine;
          tokens[destOffset + 1] = tokenStartCharacter;
          tokens[destOffset + 2] = tokenEndCharacter;
          tokens[destOffset + 3] = tokenMetadata;
        } else if (firstDeltaLine != 0) {
          // must adjust the delta line in place
          tokens[srcOffset] = tokenDeltaLine - firstDeltaLine;
        }
        newTokenCount++;
      }
    }

    _tokenCount = newTokenCount;

    return firstDeltaLine;
  }

  /// Dart carrier for the TS `[SparseMultilineTokensStorage,
  /// SparseMultilineTokensStorage, number]` tuple.
  List<Object> split(int startDeltaLine, int startChar, int endDeltaLine,
      int endChar) {
    final Uint32List tokens = _tokens;
    final int tokenCount = _tokenCount;
    final List<int> aTokens = <int>[];
    final List<int> bTokens = <int>[];
    List<int> destTokens = aTokens;
    int destFirstDeltaLine = 0;
    for (int i = 0; i < tokenCount; i++) {
      final int srcOffset = 4 * i;
      final int tokenDeltaLine = tokens[srcOffset];
      final int tokenStartCharacter = tokens[srcOffset + 1];
      final int tokenEndCharacter = tokens[srcOffset + 2];
      final int tokenMetadata = tokens[srcOffset + 3];

      if ((tokenDeltaLine > startDeltaLine ||
          (tokenDeltaLine == startDeltaLine &&
              tokenEndCharacter >= startChar))) {
        if ((tokenDeltaLine < endDeltaLine ||
            (tokenDeltaLine == endDeltaLine &&
                tokenStartCharacter <= endChar))) {
          // this token is touching the range
          continue;
        } else {
          // this token is after the range
          if (!identical(destTokens, bTokens)) {
            // this token is the first token after the range
            destTokens = bTokens;
            destFirstDeltaLine = tokenDeltaLine;
          }
        }
      }

      // Dart: JS `destTokens[destOffset++] = v` -> `destTokens.add(v)`.
      // The offsets are sequential by construction, so this is equivalent.
      destTokens.add(tokenDeltaLine - destFirstDeltaLine);
      destTokens.add(tokenStartCharacter);
      destTokens.add(tokenEndCharacter);
      destTokens.add(tokenMetadata);
    }

    return [
      SparseMultilineTokensStorage(Uint32List.fromList(aTokens)),
      SparseMultilineTokensStorage(Uint32List.fromList(bTokens)),
      destFirstDeltaLine,
    ];
  }

  void acceptDeleteRange(int horizontalShiftForFirstLineTokens,
      int startDeltaLine, int startCharacter, int endDeltaLine, int endCharacter) {
    // This is a bit complex, here are the cases I used to think about this:
    //
    // 1. The token starts before the deletion range
    // 1a. The token is completely before the deletion range
    // 1b. The token starts before, the deletion range ends after the token
    // 1c. The token starts before, the deletion range ends precisely with the token
    // 1d. The token starts before, the deletion range is inside the token
    //
    // 2. The token starts at the same position with the deletion range
    // 2a. The token starts at the same position, and ends inside the deletion range
    // 2b. The token starts at the same position, and ends at the same position as the deletion range
    // 2c. The token starts at the same position, and ends after the deletion range
    //
    // 3. The token starts inside the deletion range
    // 3a. The token is inside the deletion range
    // 3b. The token starts inside the deletion range, and ends at the same position as the deletion range
    // 3c. The token starts inside the deletion range, and ends after the deletion range
    //
    // 4. The token starts after the deletion range
    final Uint32List tokens = _tokens;
    final int tokenCount = _tokenCount;
    final int deletedLineCount = (endDeltaLine - startDeltaLine);
    int newTokenCount = 0;
    bool hasDeletedTokens = false;
    for (int i = 0; i < tokenCount; i++) {
      final int srcOffset = 4 * i;
      int tokenDeltaLine = tokens[srcOffset];
      int tokenStartCharacter = tokens[srcOffset + 1];
      int tokenEndCharacter = tokens[srcOffset + 2];
      final int tokenMetadata = tokens[srcOffset + 3];

      if (tokenDeltaLine < startDeltaLine ||
          (tokenDeltaLine == startDeltaLine &&
              tokenEndCharacter <= startCharacter)) {
        // 1a. The token is completely before the deletion range
        // => nothing to do
        newTokenCount++;
        continue;
      } else if (tokenDeltaLine == startDeltaLine &&
          tokenStartCharacter < startCharacter) {
        // 1b, 1c, 1d
        // => the token survives, but it needs to shrink
        if (tokenDeltaLine == endDeltaLine && tokenEndCharacter > endCharacter) {
          // 1d. The token starts before, the deletion range is inside the token
          // => the token shrinks by the deletion character count
          tokenEndCharacter -= (endCharacter - startCharacter);
        } else {
          // 1b. The token starts before, the deletion range ends after the token
          // 1c. The token starts before, the deletion range ends precisely with the token
          // => the token shrinks its ending to the deletion start
          tokenEndCharacter = startCharacter;
        }
      } else if (tokenDeltaLine == startDeltaLine &&
          tokenStartCharacter == startCharacter) {
        // 2a, 2b, 2c
        if (tokenDeltaLine == endDeltaLine && tokenEndCharacter > endCharacter) {
          // 2c. The token starts at the same position, and ends after the deletion range
          // => the token shrinks by the deletion character count
          tokenEndCharacter -= (endCharacter - startCharacter);
        } else {
          // 2a. The token starts at the same position, and ends inside the deletion range
          // 2b. The token starts at the same position, and ends at the same position as the deletion range
          // => the token is deleted
          hasDeletedTokens = true;
          continue;
        }
      } else if (tokenDeltaLine < endDeltaLine ||
          (tokenDeltaLine == endDeltaLine &&
              tokenStartCharacter < endCharacter)) {
        // 3a, 3b, 3c
        if (tokenDeltaLine == endDeltaLine && tokenEndCharacter > endCharacter) {
          // 3c. The token starts inside the deletion range, and ends after the deletion range
          // => the token moves to continue right after the deletion
          tokenDeltaLine = startDeltaLine;
          tokenStartCharacter = startCharacter;
          tokenEndCharacter = tokenStartCharacter + (tokenEndCharacter - endCharacter);
        } else {
          // 3a. The token is inside the deletion range
          // 3b. The token starts inside the deletion range, and ends at the same position as the deletion range
          // => the token is deleted
          hasDeletedTokens = true;
          continue;
        }
      } else if (tokenDeltaLine > endDeltaLine) {
        // 4. (partial) The token starts after the deletion range, on a line below...
        if (deletedLineCount == 0 && !hasDeletedTokens) {
          // early stop, there is no need to walk all the tokens and do nothing...
          newTokenCount = tokenCount;
          break;
        }
        tokenDeltaLine -= deletedLineCount;
      } else if (tokenDeltaLine == endDeltaLine &&
          tokenStartCharacter >= endCharacter) {
        // 4. (continued) The token starts after the deletion range, on the last line where a deletion occurs
        if (horizontalShiftForFirstLineTokens != 0 && tokenDeltaLine == 0) {
          tokenStartCharacter += horizontalShiftForFirstLineTokens;
          tokenEndCharacter += horizontalShiftForFirstLineTokens;
        }
        tokenDeltaLine -= deletedLineCount;
        tokenStartCharacter -= (endCharacter - startCharacter);
        tokenEndCharacter -= (endCharacter - startCharacter);
      } else {
        throw StateError('Not possible!');
      }

      final int destOffset = 4 * newTokenCount;
      tokens[destOffset] = tokenDeltaLine;
      tokens[destOffset + 1] = tokenStartCharacter;
      tokens[destOffset + 2] = tokenEndCharacter;
      tokens[destOffset + 3] = tokenMetadata;
      newTokenCount++;
    }

    _tokenCount = newTokenCount;
  }

  void acceptInsertText(int deltaLine, int character, int eolCount,
      int firstLineLength, int lastLineLength, int firstCharCode) {
    // Here are the cases I used to think about this:
    //
    // 1. The token is completely before the insertion point
    // 2. The token ends precisely at the insertion point
    // 3. The token contains the insertion point
    // 4. The token starts precisely at the insertion point
    // 5. The token is completely after the insertion point
    final bool isInsertingPreciselyOneWordCharacter = (eolCount == 0 &&
        firstLineLength == 1 &&
        ((firstCharCode >= CharCode.Digit0 &&
                firstCharCode <= CharCode.Digit9) ||
            (firstCharCode >= CharCode.A && firstCharCode <= CharCode.Z) ||
            (firstCharCode >= CharCode.a && firstCharCode <= CharCode.z)));
    final Uint32List tokens = _tokens;
    final int tokenCount = _tokenCount;
    for (int i = 0; i < tokenCount; i++) {
      final int offset = 4 * i;
      int tokenDeltaLine = tokens[offset];
      int tokenStartCharacter = tokens[offset + 1];
      int tokenEndCharacter = tokens[offset + 2];

      if (tokenDeltaLine < deltaLine ||
          (tokenDeltaLine == deltaLine && tokenEndCharacter < character)) {
        // 1. The token is completely before the insertion point
        // => nothing to do
        continue;
      } else if (tokenDeltaLine == deltaLine &&
          tokenEndCharacter == character) {
        // 2. The token ends precisely at the insertion point
        // => expand the end character only if inserting precisely one character that is a word character
        if (isInsertingPreciselyOneWordCharacter) {
          tokenEndCharacter += 1;
        } else {
          continue;
        }
      } else if (tokenDeltaLine == deltaLine &&
          tokenStartCharacter < character &&
          character < tokenEndCharacter) {
        // 3. The token contains the insertion point
        if (eolCount == 0) {
          // => just expand the end character
          tokenEndCharacter += firstLineLength;
        } else {
          // => cut off the token
          tokenEndCharacter = character;
        }
      } else {
        // 4. or 5.
        if (tokenDeltaLine == deltaLine && tokenStartCharacter == character) {
          // 4. The token starts precisely at the insertion point
          // => grow the token (by keeping its start constant) only if inserting precisely one character that is a word character
          // => otherwise behave as in case 5.
          if (isInsertingPreciselyOneWordCharacter) {
            continue;
          }
        }
        // => the token must move and keep its size constant
        if (tokenDeltaLine == deltaLine) {
          tokenDeltaLine += eolCount;
          // this token is on the line where the insertion is taking place
          if (eolCount == 0) {
            tokenStartCharacter += firstLineLength;
            tokenEndCharacter += firstLineLength;
          } else {
            final int tokenLength = tokenEndCharacter - tokenStartCharacter;
            tokenStartCharacter =
                lastLineLength + (tokenStartCharacter - character);
            tokenEndCharacter = tokenStartCharacter + tokenLength;
          }
        } else {
          tokenDeltaLine += eolCount;
        }
      }

      tokens[offset] = tokenDeltaLine;
      tokens[offset + 1] = tokenStartCharacter;
      tokens[offset + 2] = tokenEndCharacter;
    }
  }

  static final RateLimiter _rateLimiter = RateLimiter(10 / 60); // limit to 10 times per minute

  void reportIfInvalid(ITextModelForSparseTokens model, int startLineNumber) {
    for (int i = 0; i < _tokenCount; i++) {
      final int lineNumber = _getDeltaLine(i) + startLineNumber;

      if (lineNumber < 1) {
        SparseMultilineTokensStorage._rateLimiter.runIfNotLimited(() {
          sparseTokensConsoleError(
              'Invalid Semantic Tokens Data From Extension: lineNumber < 1');
        });
      } else if (lineNumber > model.getLineCount()) {
        SparseMultilineTokensStorage._rateLimiter.runIfNotLimited(() {
          sparseTokensConsoleError(
              'Invalid Semantic Tokens Data From Extension: lineNumber > model.getLineCount()');
        });
      } else if (_getEndCharacter(i) > model.getLineLength(lineNumber)) {
        SparseMultilineTokensStorage._rateLimiter.runIfNotLimited(() {
          sparseTokensConsoleError(
              'Invalid Semantic Tokens Data From Extension: end character > model.getLineLength(lineNumber)');
        });
      }
    }
  }
}

class SparseLineTokens {
  final Uint32List _tokens;

  SparseLineTokens(Uint32List tokens) : _tokens = tokens;

  int getCount() {
    return _tokens.length ~/ 4;
  }

  int getStartCharacter(int tokenIndex) {
    return _tokens[4 * tokenIndex + 1];
  }

  int getEndCharacter(int tokenIndex) {
    return _tokens[4 * tokenIndex + 2];
  }

  int getMetadata(int tokenIndex) {
    return _tokens[4 * tokenIndex + 3];
  }
}
