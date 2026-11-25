// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/supports.ts
// Translated 1:1 from TypeScript.
//
// Reuses the real `LineTokens`, `IViewLineTokens`, `StandardTokenType` and
// `ILanguageIdCodec` from the port.
// ---------------------------------------------------------------------------

import '../tokens/lineTokens.dart'
    show ILanguageIdCodec, IViewLineTokens, LineTokens;
import '../encodedTokenAttributes.dart' show StandardTokenType;

/// 1:1: `createScopedLineTokens`.
ScopedLineTokens createScopedLineTokens(LineTokens context, int offset) {
  final int tokenCount = context.getCount();
  final int tokenIndex = context.findTokenIndexAtOffset(offset);
  final String desiredLanguageId = context.getLanguageId(tokenIndex);

  int lastTokenIndex = tokenIndex;
  while (lastTokenIndex + 1 < tokenCount &&
      context.getLanguageId(lastTokenIndex + 1) == desiredLanguageId) {
    lastTokenIndex++;
  }

  int firstTokenIndex = tokenIndex;
  while (firstTokenIndex > 0 &&
      context.getLanguageId(firstTokenIndex - 1) == desiredLanguageId) {
    firstTokenIndex--;
  }

  return ScopedLineTokens(
    context,
    desiredLanguageId,
    firstTokenIndex,
    lastTokenIndex + 1,
    context.getStartOffset(firstTokenIndex),
    context.getEndOffset(lastTokenIndex),
  );
}

/// 1:1: `ScopedLineTokens`.
class ScopedLineTokens {
  final ILanguageIdCodec languageIdCodec;
  final String languageId;
  final LineTokens _actual;
  final int _firstTokenIndex;
  final int _lastTokenIndex;
  final int firstCharOffset;
  final int _lastCharOffset;

  ScopedLineTokens(
    this._actual,
    this.languageId,
    this._firstTokenIndex,
    this._lastTokenIndex,
    this.firstCharOffset,
    this._lastCharOffset,
  ) : languageIdCodec = _actual.languageIdCodec;

  String getLineContent() => _actual
      .getLineContent()
      .substring(firstCharOffset, _lastCharOffset);

  int getLineLength() => _lastCharOffset - firstCharOffset;

  String getActualLineContentBefore(int offset) =>
      _actual.getLineContent().substring(0, firstCharOffset + offset);

  int getTokenCount() => _lastTokenIndex - _firstTokenIndex;

  int findTokenIndexAtOffset(int offset) =>
      _actual.findTokenIndexAtOffset(offset + firstCharOffset) -
      _firstTokenIndex;

  int getStandardTokenType(int tokenIndex) =>
      _actual.getStandardTokenType(tokenIndex + _firstTokenIndex);

  IViewLineTokens toIViewLineTokens() => _actual.sliceAndInflate(
        firstCharOffset,
        _lastCharOffset,
        0,
      );
}

/// 1:1: `IgnoreBracketsInTokens.value`.
const int _ignoreBracketsInTokens = StandardTokenType.comment |
    StandardTokenType.string |
    StandardTokenType.regEx;

/// 1:1: `ignoreBracketsInToken`.
bool ignoreBracketsInToken(int standardTokenType) =>
    (standardTokenType & _ignoreBracketsInTokens) != 0;
