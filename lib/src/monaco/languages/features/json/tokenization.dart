// ignore_for_file: constant_identifier_names, prefer_interpolation_to_compose_strings
// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/features/json/tokenization.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//   - `json.createScanner` (jsonc-parser) -> the already-ported, same-source
//     `base/common/json.dart` `createScanner` (identical MS implementation and
//     signatures: scan/getPosition/getTokenError).
//   - `languages.TokensProvider/IState/ILineTokens/IToken` (from `../../../editor`,
//     whose API facade `editor.api.ts` is still pending) -> local carriers with
//     the exact monaco.d.ts shape (same convention as _.contribution.dart).
//   - `const enum` -> class + static const int (values 1:1 with TS).
// ---------------------------------------------------------------------------

import 'package:semi_design_flutter/src/monaco/base/common/json.dart'
    show JSONScanner, createScanner;

// ---- local carriers for `languages.*` (monaco.d.ts shapes) -----------------

/// 1:1: `languages.IToken` (monaco.d.ts IToken).
class IToken {
  IToken(this.startIndex, this.scopes);

  final int startIndex;
  final String scopes;
}

/// 1:1: `languages.IState` (monaco.d.ts IState).
abstract class IState {
  IState clone();
  bool equals(IState other);
}

/// 1:1: `languages.ILineTokens` (monaco.d.ts ILineTokens).
class ILineTokens {
  ILineTokens(this.tokens, this.endState);

  final List<IToken> tokens;

  /// Not final: the TS tokenizer reassigns `ret.endState` per scanned token.
  IState endState;
}

/// 1:1: `languages.TokensProvider` (monaco.d.ts TokensProvider).
/// `tokenize` state is nullable in the TS impl signature `tokenize(line, state?)`.
abstract class TokensProvider {
  IState getInitialState();
  ILineTokens tokenize(String line, IState? state);
}

// ---- module constants ------------------------------------------------------

/// 1:1: `export function createTokenizationSupport(supportComments: boolean): languages.TokensProvider`
TokensProvider createTokenizationSupport(bool supportComments) =>
    _JSONTokenizationSupport(supportComments);

class _JSONTokenizationSupport implements TokensProvider {
  _JSONTokenizationSupport(this._supportComments);
  final bool _supportComments;

  @override
  IState getInitialState() => JSONState(null, null, false, null);

  @override
  ILineTokens tokenize(String line, IState? state) =>
      tokenizeImpl(_supportComments, line, (state ?? getInitialState()) as JSONState);
}

/// 1:1: `export const TOKEN_DELIM_OBJECT = 'delimiter.bracket.json';`
const String TOKEN_DELIM_OBJECT = 'delimiter.bracket.json';
/// 1:1: `export const TOKEN_DELIM_ARRAY = 'delimiter.array.json';`
const String TOKEN_DELIM_ARRAY = 'delimiter.array.json';
/// 1:1: `export const TOKEN_DELIM_COLON = 'delimiter.colon.json';`
const String TOKEN_DELIM_COLON = 'delimiter.colon.json';
/// 1:1: `export const TOKEN_DELIM_COMMA = 'delimiter.comma.json';`
const String TOKEN_DELIM_COMMA = 'delimiter.comma.json';
/// 1:1: `export const TOKEN_VALUE_BOOLEAN = 'keyword.json';`
const String TOKEN_VALUE_BOOLEAN = 'keyword.json';
/// 1:1: `export const TOKEN_VALUE_NULL = 'keyword.json';`
const String TOKEN_VALUE_NULL = 'keyword.json';
/// 1:1: `export const TOKEN_VALUE_STRING = 'string.value.json';`
const String TOKEN_VALUE_STRING = 'string.value.json';
/// 1:1: `export const TOKEN_VALUE_NUMBER = 'number.json';`
const String TOKEN_VALUE_NUMBER = 'number.json';
/// 1:1: `export const TOKEN_PROPERTY_NAME = 'string.key.json';`
const String TOKEN_PROPERTY_NAME = 'string.key.json';
/// 1:1: `export const TOKEN_COMMENT_BLOCK = 'comment.block.json';`
const String TOKEN_COMMENT_BLOCK = 'comment.block.json';
/// 1:1: `export const TOKEN_COMMENT_LINE = 'comment.line.json';`
const String TOKEN_COMMENT_LINE = 'comment.line.json';

/// 1:1: `const enum JSONParent`
class JSONParent {
  static const int object = 0;
  static const int array = 1;
}

/// 1:1: `class ParentsStack`
class ParentsStack {
  ParentsStack(this.parent, this.type);

  final ParentsStack? parent;
  final int type;

  /// 1:1: `public static pop(parents: ParentsStack | null): ParentsStack | null`
  static ParentsStack? pop(ParentsStack? parents) => parents?.parent;

  /// 1:1: `public static push(parents, type): ParentsStack`
  static ParentsStack push(ParentsStack? parents, int type) =>
      ParentsStack(parents, type);

  /// 1:1: `public static equals(a, b): boolean`
  static bool equals(ParentsStack? a, ParentsStack? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    while (a != null && b != null) {
      if (identical(a, b)) return true;
      if (a.type != b.type) return false;
      a = a.parent;
      b = b.parent;
    }
    return true;
  }
}

/// 1:1: `const enum ScanError` (local to tokenization.ts)
class ScanError {
  static const int none = 0;
  static const int unexpectedEndOfComment = 1;
  static const int unexpectedEndOfString = 2;
  static const int unexpectedEndOfNumber = 3;
  static const int invalidUnicode = 4;
  static const int invalidEscapeCharacter = 5;
  static const int invalidCharacter = 6;
}

/// 1:1: `const enum SyntaxKind` (local to tokenization.ts; values 1:1 with TS)
class SyntaxKind {
  static const int openBraceToken = 1;
  static const int closeBraceToken = 2;
  static const int openBracketToken = 3;
  static const int closeBracketToken = 4;
  static const int commaToken = 5;
  static const int colonToken = 6;
  static const int nullKeyword = 7;
  static const int trueKeyword = 8;
  static const int falseKeyword = 9;
  static const int stringLiteral = 10;
  static const int numericLiteral = 11;
  static const int lineCommentTrivia = 12;
  static const int blockCommentTrivia = 13;
  static const int lineBreakTrivia = 14;
  static const int trivia = 15;
  static const int unknown = 16;
  static const int eof = 17;
}

/// 1:1: `class JSONState implements languages.IState`
class JSONState implements IState {
  JSONState(this._state, this.scanError, this.lastWasColon, this.parents);

  IState? _state;

  int? scanError;
  bool lastWasColon;
  ParentsStack? parents;

  @override
  JSONState clone() => JSONState(_state, scanError, lastWasColon, parents);

  @override
  bool equals(IState other) {
    if (identical(other, this)) return true;
    if (other is! JSONState) return false;
    return scanError == other.scanError &&
        lastWasColon == other.lastWasColon &&
        ParentsStack.equals(parents, other.parents);
  }

  /// 1:1: `public getStateData(): languages.IState | null`
  IState? getStateData() => _state;

  /// 1:1: `public setStateData(state: languages.IState): void`
  void setStateData(IState state) => _state = state;
}

/// 1:1: `function tokenize(comments, line, state, offsetDelta = 0): languages.ILineTokens`
/// Exported as [tokenizeImpl] so tests can drive offsetDelta explicitly.
ILineTokens tokenizeImpl(bool comments, String line, JSONState state,
    [int offsetDelta = 0]) {
  // handle multiline strings and block comments
  int numberOfInsertedCharacters = 0;
  bool adjustOffset = false;

  switch (state.scanError) {
    case ScanError.unexpectedEndOfString:
      line = '"' + line;
      numberOfInsertedCharacters = 1;
      break;
    case ScanError.unexpectedEndOfComment:
      line = '/*' + line;
      numberOfInsertedCharacters = 2;
      break;
  }

  final JSONScanner scanner = createScanner(line);
  bool lastWasColon = state.lastWasColon;
  ParentsStack? parents = state.parents;

  final ILineTokens ret = ILineTokens(<IToken>[], state.clone());

  while (true) {
    int offset = offsetDelta + scanner.getPosition();
    String type = '';

    final int kind = scanner.scan();
    if (kind == SyntaxKind.eof) break;

    // Check that the scanner has advanced
    if (offset == offsetDelta + scanner.getPosition()) {
      throw StateError('Scanner did not advance, next 3 characters are: ' +
          _substr(line, scanner.getPosition(), 3));
    }

    // In case we inserted /* or " character, we need to adjust the offset of
    // all tokens (except the first).
    if (adjustOffset) {
      offset -= numberOfInsertedCharacters;
    }
    adjustOffset = numberOfInsertedCharacters > 0;

    // brackets and type
    switch (kind) {
      case SyntaxKind.openBraceToken:
        parents = ParentsStack.push(parents, JSONParent.object);
        type = TOKEN_DELIM_OBJECT;
        lastWasColon = false;
        break;
      case SyntaxKind.closeBraceToken:
        parents = ParentsStack.pop(parents);
        type = TOKEN_DELIM_OBJECT;
        lastWasColon = false;
        break;
      case SyntaxKind.openBracketToken:
        parents = ParentsStack.push(parents, JSONParent.array);
        type = TOKEN_DELIM_ARRAY;
        lastWasColon = false;
        break;
      case SyntaxKind.closeBracketToken:
        parents = ParentsStack.pop(parents);
        type = TOKEN_DELIM_ARRAY;
        lastWasColon = false;
        break;
      case SyntaxKind.colonToken:
        type = TOKEN_DELIM_COLON;
        lastWasColon = true;
        break;
      case SyntaxKind.commaToken:
        type = TOKEN_DELIM_COMMA;
        lastWasColon = false;
        break;
      case SyntaxKind.trueKeyword:
      case SyntaxKind.falseKeyword:
        type = TOKEN_VALUE_BOOLEAN;
        lastWasColon = false;
        break;
      case SyntaxKind.nullKeyword:
        type = TOKEN_VALUE_NULL;
        lastWasColon = false;
        break;
      case SyntaxKind.stringLiteral:
        final int currentParent = parents != null ? parents.type : JSONParent.object;
        final bool inArray = currentParent == JSONParent.array;
        type = lastWasColon || inArray ? TOKEN_VALUE_STRING : TOKEN_PROPERTY_NAME;
        lastWasColon = false;
        break;
      case SyntaxKind.numericLiteral:
        type = TOKEN_VALUE_NUMBER;
        lastWasColon = false;
        break;
    }

    // comments, iff enabled
    if (comments) {
      switch (kind) {
        case SyntaxKind.lineCommentTrivia:
          type = TOKEN_COMMENT_LINE;
          break;
        case SyntaxKind.blockCommentTrivia:
          type = TOKEN_COMMENT_BLOCK;
          break;
      }
    }

    ret.endState = JSONState(
      state.getStateData(),
      scanner.getTokenError(),
      lastWasColon,
      parents,
    );
    ret.tokens.add(IToken(offset, type));
  }

  return ret;
}

/// JS `String.prototype.substr(start, length)` (length clamped, 1:1 for the
/// scanner-error message path). Negative start counts from the end.
String _substr(String s, int start, int length) {
  final int n = s.length;
  if (start < 0) start = n + start;
  if (start < 0) start = 0;
  if (start > n) start = n;
  int end = start + length;
  if (end > n) end = n;
  return s.substring(start, end);
}
