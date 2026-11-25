// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/testLineToken.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// This is a test-infrastructure helper: several IViewLineTokens members are
// unimplemented in the source (`throw new Error('Not implemented')`) and are
// mirrored here with `UnsupportedError`.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../../common/encodedTokenAttributes.dart';
import '../../../common/tokens/lineTokens.dart';

/// A token on a line — 1:1 `export class TestLineToken`.
class TestLineToken {
  /// last char index of this token (not inclusive).
  final int endIndex;
  final int _metadata;

  TestLineToken(this.endIndex, this._metadata);

  int getStandardTokenType() => TokenMetadata.getTokenType(_metadata);
  int getForeground() => TokenMetadata.getForeground(_metadata);
  String getType() => TokenMetadata.getClassNameFromMetadata(_metadata);
  String getInlineStyle(List<String> colorMap) =>
      TokenMetadata.getInlineStyleFromMetadata(_metadata, colorMap);
  ITokenPresentation getPresentation() =>
      TokenMetadata.getPresentationFromMetadata(_metadata);

  static bool _equals(TestLineToken a, TestLineToken b) =>
      a.endIndex == b.endIndex && a._metadata == b._metadata;

  static bool equalsArr(List<TestLineToken> a, List<TestLineToken> b) {
    final int aLen = a.length;
    final int bLen = b.length;
    if (aLen != bLen) return false;
    for (int i = 0; i < aLen; i++) {
      if (!_equals(a[i], b[i])) return false;
    }
    return true;
  }
}

/// 1:1: `export class TestLineTokens implements IViewLineTokens`
class TestLineTokens implements IViewLineTokens {
  final List<TestLineToken> _actual;

  TestLineTokens(this._actual);

  @override
  bool equals(Object? other) {
    if (other is TestLineTokens) {
      return TestLineToken.equalsArr(_actual, other._actual);
    }
    return false;
  }

  @override
  int getCount() => _actual.length;

  @override
  int getStandardTokenType(int tokenIndex) =>
      _actual[tokenIndex].getStandardTokenType();

  @override
  int getForeground(int tokenIndex) => _actual[tokenIndex].getForeground();

  @override
  int getEndOffset(int tokenIndex) => _actual[tokenIndex].endIndex;

  @override
  String getClassName(int tokenIndex) => _actual[tokenIndex].getType();

  @override
  String getInlineStyle(int tokenIndex, List<String> colorMap) =>
      _actual[tokenIndex].getInlineStyle(colorMap);

  @override
  ITokenPresentation getPresentation(int tokenIndex) =>
      _actual[tokenIndex].getPresentation();

  @override
  int findTokenIndexAtOffset(int offset) =>
      throw UnsupportedError('Not implemented');

  @override
  String getLineContent() => throw UnsupportedError('Not implemented');

  @override
  int getMetadata(int tokenIndex) =>
      throw UnsupportedError('Method not implemented.');

  @override
  String getLanguageId(int tokenIndex) =>
      throw UnsupportedError('Method not implemented.');

  @override
  String getTokenText(int tokenIndex) =>
      throw UnsupportedError('Method not implemented.');

  @override
  void forEach(void Function(int tokenIndex) callback) =>
      throw UnsupportedError('Not implemented');

  @override
  ILanguageIdCodec get languageIdCodec =>
      throw UnsupportedError('Not implemented');
}

/// 1:1: `export class TestLineTokenFactory`
class TestLineTokenFactory {
  /// 1:1: `public static inflateArr(tokens: Uint32Array): TestLineToken[]`
  static List<TestLineToken> inflateArr(Uint32List tokens) {
    final int tokensCount = (tokens.length >> 1);
    final List<TestLineToken> result = List<TestLineToken>.filled(
        tokensCount, TestLineToken(0, 0), growable: false);
    for (int i = 0; i < tokensCount; i++) {
      final int endOffset = tokens[i << 1];
      final int metadata = tokens[(i << 1) + 1];
      result[i] = TestLineToken(endOffset, metadata);
    }
    return result;
  }
}
