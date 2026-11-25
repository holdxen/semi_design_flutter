// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/tokenWithTextArray.ts
// Translated 1:1 from TypeScript.
//
// Reuses the real `LineTokens`, `ILanguageIdCodec` and `OffsetRange`.
// ---------------------------------------------------------------------------

import '../core/ranges/offsetRange.dart' show OffsetRange;
import 'lineTokens.dart' show ILanguageIdCodec, LineTokens;

/// 1:1: `TokenMetadata`.
typedef TokenMetadata = int;

/// 1:1: `TokenWithTextInfo`.
class TokenWithTextInfo {
  final String text;
  final TokenMetadata metadata;

  TokenWithTextInfo(this.text, this.metadata);
}

/// 1:1: `TokenWithTextArray` — a sequence of tokens with text + metadata.
class TokenWithTextArray {
  final List<TokenWithTextInfo> _tokenInfo;

  TokenWithTextArray._(this._tokenInfo);

  /// 1:1: `fromLineTokens`.
  static TokenWithTextArray fromLineTokens(LineTokens lineTokens) {
    final List<TokenWithTextInfo> tokenInfo = <TokenWithTextInfo>[];
    for (int i = 0; i < lineTokens.getCount(); i++) {
      tokenInfo.add(TokenWithTextInfo(
        lineTokens.getTokenText(i),
        lineTokens.getMetadata(i),
      ));
    }
    return TokenWithTextArray.create(tokenInfo);
  }

  /// 1:1: `create`.
  static TokenWithTextArray create(List<TokenWithTextInfo> tokenInfo) =>
      TokenWithTextArray._(tokenInfo);

  /// 1:1: `toLineTokens`.
  LineTokens toLineTokens(ILanguageIdCodec decoder) =>
      LineTokens.createFromTextAndMetadata(
        map((OffsetRange range, TokenWithTextInfo t) => (
              text: t.text,
              metadata: t.metadata,
            )),
        decoder,
      );

  /// 1:1: `forEach`.
  void forEach(void Function(OffsetRange range, TokenWithTextInfo info) cb) {
    int lengthSum = 0;
    for (final TokenWithTextInfo tokenInfo in _tokenInfo) {
      final OffsetRange range =
          OffsetRange(lengthSum, lengthSum + tokenInfo.text.length);
      cb(range, tokenInfo);
      lengthSum += tokenInfo.text.length;
    }
  }

  /// 1:1: `map`.
  List<T> map<T>(T Function(OffsetRange range, TokenWithTextInfo info) cb) {
    final List<T> result = <T>[];
    int lengthSum = 0;
    for (final TokenWithTextInfo tokenInfo in _tokenInfo) {
      final OffsetRange range =
          OffsetRange(lengthSum, lengthSum + tokenInfo.text.length);
      result.add(cb(range, tokenInfo));
      lengthSum += tokenInfo.text.length;
    }
    return result;
  }

  /// 1:1: `slice`.
  TokenWithTextArray slice(OffsetRange range) {
    final List<TokenWithTextInfo> result = <TokenWithTextInfo>[];
    int lengthSum = 0;
    for (final TokenWithTextInfo tokenInfo in _tokenInfo) {
      final int tokenStart = lengthSum;
      final int tokenEndEx = tokenStart + tokenInfo.text.length;
      if (tokenEndEx > range.start) {
        if (tokenStart >= range.endExclusive) break;

        final int deltaBefore = _max(0, range.start - tokenStart);
        final int deltaAfter = _max(0, tokenEndEx - range.endExclusive);
        result.add(TokenWithTextInfo(
          tokenInfo.text.substring(
            deltaBefore,
            tokenInfo.text.length - deltaAfter,
          ),
          tokenInfo.metadata,
        ));
      }
      lengthSum += tokenInfo.text.length;
    }
    return TokenWithTextArray.create(result);
  }

  /// 1:1: `append`.
  TokenWithTextArray append(TokenWithTextArray other) =>
      TokenWithTextArray.create(<TokenWithTextInfo>[
        ..._tokenInfo,
        ...other._tokenInfo,
      ]);

  /// Replay-only view of the token info.
  List<TokenWithTextInfo> get tokenInfo => _tokenInfo;
}

/// 1:1: `TokenWithTextArrayBuilder`.
class TokenWithTextArrayBuilder {
  final List<TokenWithTextInfo> _tokens = <TokenWithTextInfo>[];

  void add(String text, TokenMetadata metadata) =>
      _tokens.add(TokenWithTextInfo(text, metadata));

  TokenWithTextArray build() => TokenWithTextArray.create(_tokens);
}

int _max(int a, int b) => a > b ? a : b;
