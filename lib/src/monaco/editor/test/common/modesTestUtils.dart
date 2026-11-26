// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/modesTestUtils.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch426).
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../common/encodedTokenAttributes.dart' show MetadataConsts;
import '../../common/languages/supports.dart'
    show ScopedLineTokens, createScopedLineTokens;
import '../../common/services/languagesRegistry.dart' show LanguageIdCodec;
import '../../common/tokens/lineTokens.dart'
    show ILanguageIdCodec, LineTokens;

/// 1:1: `TokenText`.
class TokenText {
  final String text;
  final int type;

  TokenText(this.text, this.type);
}

/// 1:1: `createFakeScopedLineTokens`.
ScopedLineTokens createFakeScopedLineTokens(List<TokenText> rawTokens) {
  final Uint32List tokens = Uint32List(rawTokens.length << 1);
  String line = '';

  for (int i = 0, len = rawTokens.length; i < len; i++) {
    final TokenText rawToken = rawTokens[i];

    final int startOffset = line.length;
    final int metadata =
        (rawToken.type << MetadataConsts.tokenTypeOffset) & 0xFFFFFFFF;

    tokens[i << 1] = startOffset;
    tokens[(i << 1) + 1] = metadata;
    line += rawToken.text;
  }

  LineTokens.convertToEndOffset(tokens, line.length);
  return createScopedLineTokens(
    LineTokens(tokens, line, _CodecAdapter(LanguageIdCodec())),
    0,
  );
}


/// Adapter: the ported `LanguageIdCodec` has the same method surface as
/// `ILanguageIdCodec` but does not declare the interface (Dart port gap).
class _CodecAdapter implements ILanguageIdCodec {
  final LanguageIdCodec _codec;
  _CodecAdapter(this._codec);

  @override
  int encodeLanguageId(String languageId) => _codec.encodeLanguageId(languageId);

  @override
  String decodeLanguageId(int languageId) => _codec.decodeLanguageId(languageId);
}
