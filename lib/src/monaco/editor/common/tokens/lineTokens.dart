// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/lineTokens.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `Uint32Array` -> `Uint32List`; `new Uint32Array(n)` -> `Uint32List(n)`;
//    `new Uint32Array(list)` -> `Uint32List.fromList(list)`.
//  * `tokens.length >>> 1` -> `tokens.length >> 1` (same value for the
//    non-negative lengths used here).
//  * JS `String.prototype.substring` clamps/swaps out-of-range indices, Dart
//    throws -> `_jsSubstring` helper keeps the JS semantics at the same
//    call sites.
//  * `ILanguageIdCodec` / `ITextModel` come from `../languages.ts` and
//    `../model.ts`, which are still pending. They are carried locally with the
//    exact TS shape (same convention as `languages/features/json/tokenization.dart`).
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import '../../../base/common/errors.dart' show onUnexpectedError;
import '../core/position.dart' show IPosition;
import '../core/ranges/offsetRange.dart' show OffsetRange;
import '../encodedTokenAttributes.dart'
    show
        ColorId,
        FontStyle,
        ITokenPresentation,
        MetadataConsts,
        TokenMetadata;

/// 1:1: `export interface ILanguageIdCodec` (from `../languages.ts`, pending).
abstract class ILanguageIdCodec {
  int encodeLanguageId(String languageId);
  String decodeLanguageId(int languageId);
}

/// 1:1: `export interface IViewLineTokens`.
abstract class IViewLineTokens {
  ILanguageIdCodec get languageIdCodec;
  bool equals(Object? other);
  int getCount();
  int getStandardTokenType(int tokenIndex);
  int getForeground(int tokenIndex);
  int getEndOffset(int tokenIndex);
  String getClassName(int tokenIndex);
  String getInlineStyle(int tokenIndex, List<String> colorMap);
  ITokenPresentation getPresentation(int tokenIndex);
  int findTokenIndexAtOffset(int offset);
  String getLineContent();
  int getMetadata(int tokenIndex);
  String getLanguageId(int tokenIndex);
  String getTokenText(int tokenIndex);
  void forEach(void Function(int tokenIndex) callback);
}

/// JS `String.prototype.substring`: clamps to `[0, length]` and swaps the
/// bounds when `start > end`.
String _jsSubstring(String text, int start, int end) {
  int from = start < 0 ? 0 : (start > text.length ? text.length : start);
  int to = end < 0 ? 0 : (end > text.length ? text.length : end);
  if (from > to) {
    final int tmp = from;
    from = to;
    to = tmp;
  }
  return text.substring(from, to);
}

/// 1:1: `export class LineTokens implements IViewLineTokens`.
class LineTokens implements IViewLineTokens {
  static LineTokens createEmpty(String lineContent, ILanguageIdCodec decoder) {
    final int defaultMetadata = LineTokens.defaultTokenMetadata;

    final Uint32List tokens = Uint32List(2);
    tokens[0] = lineContent.length;
    tokens[1] = defaultMetadata;

    return LineTokens(tokens, lineContent, decoder);
  }

  static LineTokens createFromTextAndMetadata(
      List<({String text, int metadata})> data, ILanguageIdCodec decoder) {
    int offset = 0;
    String fullText = '';
    final List<int> tokens = <int>[];
    for (final ({String text, int metadata}) entry in data) {
      tokens.add(offset + entry.text.length);
      tokens.add(entry.metadata);
      offset += entry.text.length;
      fullText += entry.text;
    }
    return LineTokens(Uint32List.fromList(tokens), fullText, decoder);
  }

  static void convertToEndOffset(Uint32List tokens, int lineTextLength) {
    final int tokenCount = tokens.length >> 1;
    final int lastTokenIndex = tokenCount - 1;
    for (int tokenIndex = 0; tokenIndex < lastTokenIndex; tokenIndex++) {
      tokens[tokenIndex << 1] = tokens[(tokenIndex + 1) << 1];
    }
    tokens[lastTokenIndex << 1] = lineTextLength;
  }

  static int findIndexInTokensArray(Uint32List tokens, int desiredIndex) {
    if (tokens.length <= 2) {
      return 0;
    }

    int low = 0;
    int high = (tokens.length >> 1) - 1;

    while (low < high) {
      final int mid = low + ((high - low) / 2).floor();
      final int endOffset = tokens[(mid << 1)];

      if (endOffset == desiredIndex) {
        return mid + 1;
      } else if (endOffset < desiredIndex) {
        low = mid + 1;
      } else if (endOffset > desiredIndex) {
        high = mid;
      }
    }

    return low;
  }

  // ignore: unused_field
  final Object? _lineTokensBrand = null;

  final Uint32List _tokens;
  final int _tokensCount;
  final String _text;

  @override
  final ILanguageIdCodec languageIdCodec;

  static int defaultTokenMetadata =
      ((FontStyle.none << MetadataConsts.fontStyleOffset) |
              (ColorId.defaultForeground << MetadataConsts.foregroundOffset) |
              (ColorId.defaultBackground << MetadataConsts.backgroundOffset)) &
          0xFFFFFFFF;

  LineTokens(Uint32List tokens, String text, ILanguageIdCodec decoder)
      : _tokens = tokens,
        _tokensCount = tokens.length >> 1,
        _text = text,
        languageIdCodec = decoder {
    final int tokensLength = tokens.length > 1 ? tokens[tokens.length - 2] : 0;
    if (tokensLength != text.length) {
      onUnexpectedError(StateError('Token length and text length do not match!'));
    }
  }

  int getTextLength() {
    return _text.length;
  }

  @override
  bool equals(Object? other) {
    if (other is LineTokens) {
      return slicedEquals(other, 0, _tokensCount);
    }
    return false;
  }

  bool slicedEquals(LineTokens other, int sliceFromTokenIndex, int sliceTokenCount) {
    if (_text != other._text) {
      return false;
    }
    if (_tokensCount != other._tokensCount) {
      return false;
    }
    final int from = sliceFromTokenIndex << 1;
    final int to = from + (sliceTokenCount << 1);
    for (int i = from; i < to; i++) {
      if (_tokens[i] != other._tokens[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  String getLineContent() {
    return _text;
  }

  @override
  int getCount() {
    return _tokensCount;
  }

  int getStartOffset(int tokenIndex) {
    if (tokenIndex > 0) {
      return _tokens[(tokenIndex - 1) << 1];
    }
    return 0;
  }

  @override
  int getMetadata(int tokenIndex) {
    return _tokens[(tokenIndex << 1) + 1];
  }

  @override
  String getLanguageId(int tokenIndex) {
    final int metadata = _tokens[(tokenIndex << 1) + 1];
    final int languageId = TokenMetadata.getLanguageId(metadata);
    return languageIdCodec.decodeLanguageId(languageId);
  }

  @override
  int getStandardTokenType(int tokenIndex) {
    final int metadata = _tokens[(tokenIndex << 1) + 1];
    return TokenMetadata.getTokenType(metadata);
  }

  @override
  int getForeground(int tokenIndex) {
    final int metadata = _tokens[(tokenIndex << 1) + 1];
    return TokenMetadata.getForeground(metadata);
  }

  @override
  String getClassName(int tokenIndex) {
    final int metadata = _tokens[(tokenIndex << 1) + 1];
    return TokenMetadata.getClassNameFromMetadata(metadata);
  }

  @override
  String getInlineStyle(int tokenIndex, List<String> colorMap) {
    final int metadata = _tokens[(tokenIndex << 1) + 1];
    return TokenMetadata.getInlineStyleFromMetadata(metadata, colorMap);
  }

  @override
  ITokenPresentation getPresentation(int tokenIndex) {
    final int metadata = _tokens[(tokenIndex << 1) + 1];
    return TokenMetadata.getPresentationFromMetadata(metadata);
  }

  @override
  int getEndOffset(int tokenIndex) {
    return _tokens[tokenIndex << 1];
  }

  /// Find the token containing offset `offset`.
  /// @param offset The search offset
  /// @return The index of the token containing the offset.
  @override
  int findTokenIndexAtOffset(int offset) {
    return LineTokens.findIndexInTokensArray(_tokens, offset);
  }

  IViewLineTokens inflate() {
    return this;
  }

  IViewLineTokens sliceAndInflate(
      int startOffset, int endOffset, int deltaOffset) {
    return SliceLineTokens(this, startOffset, endOffset, deltaOffset);
  }

  IViewLineTokens sliceZeroCopy(OffsetRange range) {
    return sliceAndInflate(range.start, range.endExclusive, 0);
  }

  /// @pure
  /// @param insertTokens Must be sorted by offset.
  LineTokens withInserted(
      List<({int offset, String text, int tokenMetadata})> insertTokens) {
    if (insertTokens.isEmpty) {
      return this;
    }

    int nextOriginalTokenIdx = 0;
    int nextInsertTokenIdx = 0;
    String text = '';
    final List<int> newTokens = <int>[];

    int originalEndOffset = 0;
    while (true) {
      final int nextOriginalTokenEndOffset = nextOriginalTokenIdx < _tokensCount
          ? _tokens[nextOriginalTokenIdx << 1]
          : -1;
      final ({int offset, String text, int tokenMetadata})? nextInsertToken =
          nextInsertTokenIdx < insertTokens.length
              ? insertTokens[nextInsertTokenIdx]
              : null;

      if (nextOriginalTokenEndOffset != -1 &&
          (nextInsertToken == null ||
              nextOriginalTokenEndOffset <= nextInsertToken.offset)) {
        // original token ends before next insert token
        text += _jsSubstring(_text, originalEndOffset, nextOriginalTokenEndOffset);
        final int metadata = _tokens[(nextOriginalTokenIdx << 1) + 1];
        newTokens.add(text.length);
        newTokens.add(metadata);
        nextOriginalTokenIdx++;
        originalEndOffset = nextOriginalTokenEndOffset;
      } else if (nextInsertToken != null) {
        if (nextInsertToken.offset > originalEndOffset) {
          // insert token is in the middle of the next token.
          text += _jsSubstring(_text, originalEndOffset, nextInsertToken.offset);
          final int metadata = _tokens[(nextOriginalTokenIdx << 1) + 1];
          newTokens.add(text.length);
          newTokens.add(metadata);
          originalEndOffset = nextInsertToken.offset;
        }

        text += nextInsertToken.text;
        newTokens.add(text.length);
        newTokens.add(nextInsertToken.tokenMetadata);
        nextInsertTokenIdx++;
      } else {
        break;
      }
    }

    return LineTokens(Uint32List.fromList(newTokens), text, languageIdCodec);
  }

  TokenArray getTokensInRange(OffsetRange range) {
    final TokenArrayBuilder builder = TokenArrayBuilder();

    final int startTokenIndex = findTokenIndexAtOffset(range.start);
    final int endTokenIndex = findTokenIndexAtOffset(range.endExclusive);

    for (int tokenIndex = startTokenIndex;
        tokenIndex <= endTokenIndex;
        tokenIndex++) {
      final OffsetRange tokenRange =
          OffsetRange(getStartOffset(tokenIndex), getEndOffset(tokenIndex));
      final int length = tokenRange.intersectionLength(range);
      if (length > 0) {
        builder.add(length, getMetadata(tokenIndex));
      }
    }

    return builder.build();
  }

  @override
  String getTokenText(int tokenIndex) {
    final int startOffset = getStartOffset(tokenIndex);
    final int endOffset = getEndOffset(tokenIndex);
    final String text = _jsSubstring(_text, startOffset, endOffset);
    return text;
  }

  @override
  void forEach(void Function(int tokenIndex) callback) {
    final int tokenCount = getCount();
    for (int tokenIndex = 0; tokenIndex < tokenCount; tokenIndex++) {
      callback(tokenIndex);
    }
  }

  @override
  String toString() {
    String result = '';
    forEach((int i) {
      result += '[${getTokenText(i)}]{${getClassName(i)}}';
    });
    return result;
  }
}

class SliceLineTokens implements IViewLineTokens {
  SliceLineTokens(this._source, this._startOffset, this._endOffset, this._deltaOffset)
      : languageIdCodec = _source.languageIdCodec {
    _firstTokenIndex = _source.findTokenIndexAtOffset(_startOffset);

    int tokensCount = 0;
    for (int i = _firstTokenIndex, len = _source.getCount(); i < len; i++) {
      final int tokenStartOffset = _source.getStartOffset(i);
      if (tokenStartOffset >= _endOffset) {
        break;
      }
      tokensCount++;
    }
    _tokensCount = tokensCount;
  }

  final LineTokens _source;
  final int _startOffset;
  final int _endOffset;
  final int _deltaOffset;

  late final int _firstTokenIndex;
  late int _tokensCount;

  @override
  final ILanguageIdCodec languageIdCodec;

  @override
  int getMetadata(int tokenIndex) {
    return _source.getMetadata(_firstTokenIndex + tokenIndex);
  }

  @override
  String getLanguageId(int tokenIndex) {
    return _source.getLanguageId(_firstTokenIndex + tokenIndex);
  }

  @override
  String getLineContent() {
    return _jsSubstring(
        _source.getLineContent(), _startOffset, _endOffset);
  }

  @override
  bool equals(Object? other) {
    if (other is SliceLineTokens) {
      return (_startOffset == other._startOffset &&
          _endOffset == other._endOffset &&
          _deltaOffset == other._deltaOffset &&
          _source.slicedEquals(
              other._source, _firstTokenIndex, _tokensCount));
    }
    return false;
  }

  @override
  int getCount() {
    return _tokensCount;
  }

  @override
  int getStandardTokenType(int tokenIndex) {
    return _source.getStandardTokenType(_firstTokenIndex + tokenIndex);
  }

  @override
  int getForeground(int tokenIndex) {
    return _source.getForeground(_firstTokenIndex + tokenIndex);
  }

  @override
  int getEndOffset(int tokenIndex) {
    final int tokenEndOffset =
        _source.getEndOffset(_firstTokenIndex + tokenIndex);
    final int min = _endOffset < tokenEndOffset ? _endOffset : tokenEndOffset;
    return min - _startOffset + _deltaOffset;
  }

  @override
  String getClassName(int tokenIndex) {
    return _source.getClassName(_firstTokenIndex + tokenIndex);
  }

  @override
  String getInlineStyle(int tokenIndex, List<String> colorMap) {
    return _source.getInlineStyle(_firstTokenIndex + tokenIndex, colorMap);
  }

  @override
  ITokenPresentation getPresentation(int tokenIndex) {
    return _source.getPresentation(_firstTokenIndex + tokenIndex);
  }

  @override
  int findTokenIndexAtOffset(int offset) {
    return _source.findTokenIndexAtOffset(
            offset + _startOffset - _deltaOffset) -
        _firstTokenIndex;
  }

  @override
  String getTokenText(int tokenIndex) {
    final int adjustedTokenIndex = _firstTokenIndex + tokenIndex;
    final int tokenStartOffset = _source.getStartOffset(adjustedTokenIndex);
    final int tokenEndOffset = _source.getEndOffset(adjustedTokenIndex);
    String text = _source.getTokenText(adjustedTokenIndex);
    if (tokenStartOffset < _startOffset) {
      text = _jsSubstring(text, _startOffset - tokenStartOffset, text.length);
    }
    if (tokenEndOffset > _endOffset) {
      text = _jsSubstring(
          text, 0, text.length - (tokenEndOffset - _endOffset));
    }
    return text;
  }

  @override
  void forEach(void Function(int tokenIndex) callback) {
    for (int tokenIndex = 0; tokenIndex < getCount(); tokenIndex++) {
      callback(tokenIndex);
    }
  }
}

/// 1:1: `ITextModel` (from `../model.ts`, pending) — only the members
/// `getStandardTokenTypeAtPosition` reads.
abstract class ITextModel {
  ITokenizationTextModelPart get tokenization;

  /// Used by `contiguousTokensStore.setMultilineTokens`.
  String getLanguageId();

  /// Used by `contiguousTokensStore.setMultilineTokens`.
  int getLineLength(int lineNumber);
}

/// 1:1: `ITextModel['tokenization']` shape used by
/// `getStandardTokenTypeAtPosition` (from `../model.ts`, pending).
abstract class ITokenizationTextModelPart {
  bool isCheapToTokenize(int lineNumber);
  void forceTokenization(int lineNumber);
  IViewLineTokens getLineTokens(int lineNumber);
}

int? getStandardTokenTypeAtPosition(ITextModel model, IPosition position) {
  final int lineNumber = position.lineNumber;
  if (!model.tokenization.isCheapToTokenize(lineNumber)) {
    return null;
  }
  model.tokenization.forceTokenization(lineNumber);
  final IViewLineTokens lineTokens = model.tokenization.getLineTokens(lineNumber);
  final int tokenIndex = lineTokens.findTokenIndexAtOffset(position.column - 1);
  final int tokenType = lineTokens.getStandardTokenType(tokenIndex);
  return tokenType;
}

/// This class represents a sequence of tokens.
/// Conceptually, each token has a length and a metadata number.
/// A token array might be used to annotate a string with metadata.
/// Use [TokenArrayBuilder] to efficiently create a token array.
class TokenArray {
  static TokenArray fromLineTokens(LineTokens lineTokens) {
    final List<TokenInfo> tokenInfo = <TokenInfo>[];
    for (int i = 0; i < lineTokens.getCount(); i++) {
      tokenInfo.add(TokenInfo(
          lineTokens.getEndOffset(i) - lineTokens.getStartOffset(i),
          lineTokens.getMetadata(i)));
    }
    return TokenArray.create(tokenInfo);
  }

  static TokenArray create(List<TokenInfo> tokenInfo) {
    return TokenArray._(tokenInfo);
  }

  TokenArray._(this._tokenInfo);

  final List<TokenInfo> _tokenInfo;

  LineTokens toLineTokens(String lineContent, ILanguageIdCodec decoder) {
    return LineTokens.createFromTextAndMetadata(
        map((OffsetRange r, TokenInfo t) =>
            (text: _jsSubstring(lineContent, r.start, r.endExclusive), metadata: t.metadata)),
        decoder);
  }

  void forEach(void Function(OffsetRange range, TokenInfo tokenInfo) cb) {
    int lengthSum = 0;
    for (final TokenInfo tokenInfo in _tokenInfo) {
      final OffsetRange range = OffsetRange(lengthSum, lengthSum + tokenInfo.length);
      cb(range, tokenInfo);
      lengthSum += tokenInfo.length;
    }
  }

  List<T> map<T>(T Function(OffsetRange range, TokenInfo tokenInfo) cb) {
    final List<T> result = <T>[];
    int lengthSum = 0;
    for (final TokenInfo tokenInfo in _tokenInfo) {
      final OffsetRange range = OffsetRange(lengthSum, lengthSum + tokenInfo.length);
      result.add(cb(range, tokenInfo));
      lengthSum += tokenInfo.length;
    }
    return result;
  }

  TokenArray slice(OffsetRange range) {
    final List<TokenInfo> result = <TokenInfo>[];
    int lengthSum = 0;
    for (final TokenInfo tokenInfo in _tokenInfo) {
      final int tokenStart = lengthSum;
      final int tokenEndEx = tokenStart + tokenInfo.length;
      if (tokenEndEx > range.start) {
        if (tokenStart >= range.endExclusive) {
          break;
        }

        final int deltaBefore = range.start - tokenStart > 0 ? range.start - tokenStart : 0;
        final int deltaAfter =
            tokenEndEx - range.endExclusive > 0 ? tokenEndEx - range.endExclusive : 0;

        result.add(TokenInfo(
            tokenInfo.length - deltaBefore - deltaAfter, tokenInfo.metadata));
      }

      lengthSum += tokenInfo.length;
    }
    return TokenArray.create(result);
  }

  TokenArray append(TokenArray other) {
    final List<TokenInfo> result = <TokenInfo>[
      ..._tokenInfo,
      ...other._tokenInfo,
    ];
    return TokenArray.create(result);
  }
}

typedef ITokenMetadata = int;

class TokenInfo {
  const TokenInfo(this.length, this.metadata);

  final int length;
  final ITokenMetadata metadata;
}

class TokenArrayBuilder {
  final List<TokenInfo> _tokens = <TokenInfo>[];

  void add(int length, ITokenMetadata metadata) {
    _tokens.add(TokenInfo(length, metadata));
  }

  TokenArray build() {
    return TokenArray.create(_tokens);
  }
}