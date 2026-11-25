// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/nullTokenize.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// TS `IState` is an erased interface; [NullState] is the runtime singleton.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../encodedTokenAttributes.dart';
import '../languages.dart';

/// 1:1: `export const NullState: IState = new class implements IState { ... }`
class NullState {
  const NullState._();

  static final NullState instance = NullState._();

  /// 1:1: `public clone(): IState { return this; }`
  Object clone() => this;

  /// 1:1: `public equals(other: IState): boolean { return this === other; }`
  bool equals(Object? other) => identical(this, other);
}

/// 1:1: `export function nullTokenize(languageId: string, state: IState)`
TokenizationResult nullTokenize(String languageId, Object? state) {
  return TokenizationResult([Token(0, '', languageId)], state);
}

/// 1:1: `export function nullTokenizeEncoded(languageId: LanguageId, state)`
EncodedTokenizationResult nullTokenizeEncoded(int languageId, Object? state) {
  final tokens = Uint32List(2);
  tokens[0] = 0;
  tokens[1] = (
        (languageId << MetadataConsts.languageIdOffset) |
        (StandardTokenType.other << MetadataConsts.tokenTypeOffset) |
        (FontStyle.none << MetadataConsts.fontStyleOffset) |
        (ColorId.defaultForeground << MetadataConsts.foregroundOffset) |
        (ColorId.defaultBackground << MetadataConsts.backgroundOffset)
      );
  return EncodedTokenizationResult(
    tokens,
    [],
    state ?? NullState.instance,
  );
}
