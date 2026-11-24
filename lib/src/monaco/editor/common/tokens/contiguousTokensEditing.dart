// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/contiguousTokensEditing.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `Uint32Array | ArrayBuffer | null` → `Object?` (union carrier, same
//    convention as the rest of the port); callers pass a `Uint32List`, a
//    `ByteBuffer` or `null`.
//  * `=== EMPTY_LINE_TOKENS` identity checks → `identical(...)`.
//  * `new Uint32Array(dest)` + `set(...)` + `.buffer` (a fresh, exactly-sized
//    buffer) → `Uint32List(dest)` + `setRange(...)` + `.buffer`.
//  * `tokens.subarray(0, dest)` inside `tmp.set(...)` is folded into
//    `setRange(0, dest, tokens, 0)`.
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import './lineTokens.dart' show LineTokens;

final ByteBuffer EMPTY_LINE_TOKENS = Uint32List(0).buffer;

class ContiguousTokensEditing {
  static Object? deleteBeginning(Object? lineTokens, int toChIndex) {
    if (lineTokens == null || identical(lineTokens, EMPTY_LINE_TOKENS)) {
      return lineTokens;
    }
    return ContiguousTokensEditing.delete(lineTokens, 0, toChIndex);
  }

  static Object? deleteEnding(Object? lineTokens, int fromChIndex) {
    if (lineTokens == null || identical(lineTokens, EMPTY_LINE_TOKENS)) {
      return lineTokens;
    }

    final Uint32List tokens = toUint32Array(lineTokens);
    final int lineTextLength = tokens[tokens.length - 2];
    return ContiguousTokensEditing.delete(
        lineTokens, fromChIndex, lineTextLength);
  }

  static Object? delete(Object? lineTokens, int fromChIndex, int toChIndex) {
    if (lineTokens == null ||
        identical(lineTokens, EMPTY_LINE_TOKENS) ||
        fromChIndex == toChIndex) {
      return lineTokens;
    }

    final Uint32List tokens = toUint32Array(lineTokens);
    final int tokensCount = (tokens.length >> 1);

    // special case: deleting everything
    if (fromChIndex == 0 && tokens[tokens.length - 2] == toChIndex) {
      return EMPTY_LINE_TOKENS;
    }

    final int fromTokenIndex =
        LineTokens.findIndexInTokensArray(tokens, fromChIndex);
    final int fromTokenStartOffset =
        (fromTokenIndex > 0 ? tokens[(fromTokenIndex - 1) << 1] : 0);
    final int fromTokenEndOffset = tokens[fromTokenIndex << 1];

    if (toChIndex < fromTokenEndOffset) {
      // the delete range is inside a single token
      final int delta = (toChIndex - fromChIndex);
      for (int i = fromTokenIndex; i < tokensCount; i++) {
        tokens[i << 1] -= delta;
      }
      return lineTokens;
    }

    int dest;
    int lastEnd;
    if (fromTokenStartOffset != fromChIndex) {
      tokens[fromTokenIndex << 1] = fromChIndex;
      dest = ((fromTokenIndex + 1) << 1);
      lastEnd = fromChIndex;
    } else {
      dest = (fromTokenIndex << 1);
      lastEnd = fromTokenStartOffset;
    }

    final int delta = (toChIndex - fromChIndex);
    for (int tokenIndex = fromTokenIndex + 1;
        tokenIndex < tokensCount;
        tokenIndex++) {
      final int tokenEndOffset = tokens[tokenIndex << 1] - delta;
      if (tokenEndOffset > lastEnd) {
        tokens[dest++] = tokenEndOffset;
        tokens[dest++] = tokens[(tokenIndex << 1) + 1];
        lastEnd = tokenEndOffset;
      }
    }

    if (dest == tokens.length) {
      // nothing to trim
      return lineTokens;
    }

    final Uint32List tmp = Uint32List(dest);
    tmp.setRange(0, dest, tokens);
    return tmp.buffer;
  }

  static Object? append(Object? lineTokens, Object? _otherTokens) {
    if (identical(_otherTokens, EMPTY_LINE_TOKENS)) {
      return lineTokens;
    }
    if (identical(lineTokens, EMPTY_LINE_TOKENS)) {
      return _otherTokens;
    }
    if (lineTokens == null) {
      return lineTokens;
    }
    if (_otherTokens == null) {
      // cannot determine combined line length...
      return null;
    }
    final Uint32List myTokens = toUint32Array(lineTokens);
    final Uint32List otherTokens = toUint32Array(_otherTokens);
    final int otherTokensCount = (otherTokens.length >> 1);

    final Uint32List result =
        Uint32List(myTokens.length + otherTokens.length);
    result.setRange(0, myTokens.length, myTokens);
    int dest = myTokens.length;
    final int delta = myTokens[myTokens.length - 2];
    for (int i = 0; i < otherTokensCount; i++) {
      result[dest++] = otherTokens[(i << 1)] + delta;
      result[dest++] = otherTokens[(i << 1) + 1];
    }
    return result.buffer;
  }

  static Object? insert(Object? lineTokens, int chIndex, int textLength) {
    if (lineTokens == null || identical(lineTokens, EMPTY_LINE_TOKENS)) {
      // nothing to do
      return lineTokens;
    }

    final Uint32List tokens = toUint32Array(lineTokens);
    final int tokensCount = (tokens.length >> 1);

    int fromTokenIndex = LineTokens.findIndexInTokensArray(tokens, chIndex);
    if (fromTokenIndex > 0) {
      final int fromTokenStartOffset = tokens[(fromTokenIndex - 1) << 1];
      if (fromTokenStartOffset == chIndex) {
        fromTokenIndex--;
      }
    }
    for (int tokenIndex = fromTokenIndex;
        tokenIndex < tokensCount;
        tokenIndex++) {
      tokens[tokenIndex << 1] += textLength;
    }
    return lineTokens;
  }
}

Uint32List toUint32Array(Object arr) {
  if (arr is Uint32List) {
    return arr;
  } else {
    return Uint32List.view(arr as ByteBuffer);
  }
}