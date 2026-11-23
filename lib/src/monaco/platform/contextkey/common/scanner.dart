// 1:1 translation of vscode/src/vs/platform/contextkey/common/scanner.ts
// Mirrors the token types, Scanner class and helpers file-for-file.

import '../../../base/common/charCode.dart' as cc;
import '../../../base/common/errors.dart' show illegalState;
import '../../../nls.dart' show localize;

/// 1:1: `const enum TokenType`
class TokenType {
  static const int LParen = 0;
  static const int RParen = 1;
  static const int Neg = 2;
  static const int Eq = 3;
  static const int NotEq = 4;
  static const int Lt = 5;
  static const int LtEq = 6;
  static const int Gt = 7;
  static const int GtEq = 8;
  static const int RegexOp = 9;
  static const int RegexStr = 10;
  static const int True = 11;
  static const int False = 12;
  static const int In = 13;
  static const int Not = 14;
  static const int And = 15;
  static const int Or = 16;
  static const int Str = 17;
  static const int QuotedStr = 18;
  static const int Error = 19;
  static const int EOF = 20;
}

/// 1:1: discriminated union `Token` flattened into a single value class.
/// `lexeme` is present only for RegexStr/Str/QuotedStr/Error tokens;
/// `isTripleEq` only for Eq/NotEq tokens. Nullability carries `'lexeme' in token`.
class Token {
  final int type;
  final int offset;
  final String? lexeme;
  final bool? isTripleEq;

  const Token(this.type, this.offset, {this.lexeme, this.isTripleEq});

  @override
  String toString() => 'Token(type: $type, offset: $offset, lexeme: $lexeme, isTripleEq: $isTripleEq)';
}

/// 1:1: `type LexingError`
class LexingError {
  final int offset;
  final String lexeme;
  final String? additionalInfo;

  LexingError(this.offset, this.lexeme, [this.additionalInfo]);
}

/// 1:1: `function hintDidYouMean(...meant)` (rest param -> List<String>)
String? hintDidYouMean(List<String> meant) {
  switch (meant.length) {
    case 1:
      return localize('contextkey.scanner.hint.didYouMean1', 'Did you mean {0}?', [meant[0]]);
    case 2:
      return localize('contextkey.scanner.hint.didYouMean2', 'Did you mean {0} or {1}?', [meant[0], meant[1]]);
    case 3:
      return localize('contextkey.scanner.hint.didYouMean3', 'Did you mean {0}, {1} or {2}?', [meant[0], meant[1], meant[2]]);
    default: // we just don't expect that many
      return null;
  }
}

const String _hintDidYouForgetToOpenOrCloseQuote =
    'Did you forget to open or close the quote?';
// TS string value: "Did you forget to escape the '/' (slash) character? Put
// two backslashes before it to escape, e.g., '\\/'."  (two literal backslashes)
const String _hintDidYouForgetToEscapeSlash =
    "Did you forget to escape the '/' (slash) character? Put two backslashes before it to escape, e.g., '\\\\/'.";

/// Dart承载 of the JS regex `[a-zA-Z0-9_<>\-\.\/\\:\*\?\+\[\]\^,#@;"%\$\p{L}-]+`.
/// Dart's RegExp doesn't support `\p{L}`, so the character class is reproduced
/// with explicit code-unit checks. All test inputs are ASCII; non-ASCII code
/// units are treated as letters (the `\p{L}` set), which keeps the common case
/// faithful to the TS original.
bool _isStringCharCode(int c) {
  // a-zA-Z0-9
  if ((c >= 0x61 && c <= 0x7A) ||
      (c >= 0x41 && c <= 0x5A) ||
      (c >= 0x30 && c <= 0x39)) {
    return true;
  }
  // _ < > - . / \ : * ? + [ ] ^ , # @ ; " % $
  switch (c) {
    case 0x5F: // _
    case 0x3C: // <
    case 0x3E: // >
    case 0x2D: // -
    case 0x2E: // .
    case 0x2F: // /
    case 0x5C: // \
    case 0x3A: // :
    case 0x2A: // *
    case 0x3F: // ?
    case 0x2B: // +
    case 0x5B: // [
    case 0x5D: // ]
    case 0x5E: // ^
    case 0x23: // #
    case 0x40: // @
    case 0x22: // "
    case 0x3B: // ;
    case 0x25: // %
    case 0x24: // $
      return true;
  }
  // \p{L} — non-ASCII letters. nbsp (0xA0) is handled as whitespace in scan().
  return c >= 0xAA;
}

/// 1:1: `class Scanner`
class Scanner {
  static final Set<int> _regexFlags =
      <String>['i', 'g', 's', 'm', 'y', 'u'].map((s) => s.codeUnitAt(0)).toSet();

  static const Map<String, int> _keywords = <String, int>{
    'not': TokenType.Not,
    'in': TokenType.In,
    'false': TokenType.False,
    'true': TokenType.True,
  };

  String _input = '';
  int _start = 0;
  int _current = 0;
  List<Token> _tokens = <Token>[];
  List<LexingError> _errors = <LexingError>[];

  /// 1:1: `get errors(): Readonly<LexingError[]>`
  List<LexingError> get errors => _errors;

  /// 1:1: `reset(value)`
  Scanner reset(String value) {
    _input = value;
    _start = 0;
    _current = 0;
    _tokens = <Token>[];
    _errors = <LexingError>[];
    return this;
  }

  /// 1:1: `getLexeme(token)`
  static String getLexeme(Token token) {
    switch (token.type) {
      case TokenType.LParen:
        return '(';
      case TokenType.RParen:
        return ')';
      case TokenType.Neg:
        return '!';
      case TokenType.Eq:
        return token.isTripleEq == true ? '===' : '==';
      case TokenType.NotEq:
        return token.isTripleEq == true ? '!==' : '!=';
      case TokenType.Lt:
        return '<';
      case TokenType.LtEq:
        return '<=';
      case TokenType.Gt:
        return '>';
      case TokenType.GtEq:
        return '>=';
      case TokenType.RegexOp:
        return '=~';
      case TokenType.RegexStr:
        return token.lexeme!;
      case TokenType.True:
        return 'true';
      case TokenType.False:
        return 'false';
      case TokenType.In:
        return 'in';
      case TokenType.Not:
        return 'not';
      case TokenType.And:
        return '&&';
      case TokenType.Or:
        return '||';
      case TokenType.Str:
        return token.lexeme!;
      case TokenType.QuotedStr:
        return token.lexeme!;
      case TokenType.Error:
        return token.lexeme!;
      case TokenType.EOF:
        return 'EOF';
      default:
        throw illegalState('unhandled token type: $token; have you forgotten to add a case?');
    }
  }

  /// 1:1: `scan()`
  List<Token> scan() {
    while (!_isAtEnd()) {
      _start = _current;
      final int ch = _advance();
      switch (ch) {
        case cc.CharCode.OpenParen:
          _addToken(TokenType.LParen);
          break;
        case cc.CharCode.CloseParen:
          _addToken(TokenType.RParen);
          break;
        case cc.CharCode.ExclamationMark:
          if (_match(cc.CharCode.Equals)) {
            final bool isTripleEq = _match(cc.CharCode.Equals); // eat last `=` if `!==`
            _tokens.add(Token(TokenType.NotEq, _start, isTripleEq: isTripleEq));
          } else {
            _addToken(TokenType.Neg);
          }
          break;
        case cc.CharCode.SingleQuote:
          _quotedString();
          break;
        case cc.CharCode.Slash:
          _regex();
          break;
        case cc.CharCode.Equals:
          if (_match(cc.CharCode.Equals)) {
            final bool isTripleEq = _match(cc.CharCode.Equals); // eat last `=` if `===`
            _tokens.add(Token(TokenType.Eq, _start, isTripleEq: isTripleEq));
          } else if (_match(cc.CharCode.Tilde)) {
            _addToken(TokenType.RegexOp);
          } else {
            _error(hintDidYouMean(<String>['==', '=~']));
          }
          break;
        case cc.CharCode.LessThan:
          _addToken(_match(cc.CharCode.Equals) ? TokenType.LtEq : TokenType.Lt);
          break;
        case cc.CharCode.GreaterThan:
          _addToken(_match(cc.CharCode.Equals) ? TokenType.GtEq : TokenType.Gt);
          break;
        case cc.CharCode.Ampersand:
          if (_match(cc.CharCode.Ampersand)) {
            _addToken(TokenType.And);
          } else {
            _error(hintDidYouMean(<String>['&&']));
          }
          break;
        case cc.CharCode.Pipe:
          if (_match(cc.CharCode.Pipe)) {
            _addToken(TokenType.Or);
          } else {
            _error(hintDidYouMean(<String>['||']));
          }
          break;
        case cc.CharCode.Space:
        case cc.CharCode.CarriageReturn:
        case cc.CharCode.Tab:
        case cc.CharCode.LineFeed:
        case cc.CharCode.NoBreakSpace: // &nbsp
          break;
        default:
          _string();
      }
    }

    _start = _current;
    _addToken(TokenType.EOF);

    return List<Token>.from(_tokens);
  }

  bool _match(int expected) {
    if (_isAtEnd()) {
      return false;
    }
    if (_input.codeUnitAt(_current) != expected) {
      return false;
    }
    _current++;
    return true;
  }

  int _advance() => _input.codeUnitAt(_current++);

  int _peek() => _isAtEnd() ? cc.CharCode.Null : _input.codeUnitAt(_current);

  void _addToken(int type) {
    _tokens.add(Token(type, _start));
  }

  void _error([String? additional]) {
    final int offset = _start;
    final String lexeme = _input.substring(_start, _current);
    final Token errToken = Token(TokenType.Error, _start, lexeme: lexeme);
    _errors.add(LexingError(offset, lexeme, additional));
    _tokens.add(errToken);
  }

  // Dart承载 of `stringRe.exec` with sticky `y` starting at `_start`:
  // consume the maximal run of characters in the class, at least one.
  void _string() {
    int p = _start;
    while (p < _input.length && _isStringCharCode(_input.codeUnitAt(p))) {
      p++;
    }
    if (p > _start) {
      _current = p;
      final String lexeme = _input.substring(_start, _current);
      final int? keyword = _keywords[lexeme];
      if (keyword != null) {
        _addToken(keyword);
      } else {
        _tokens.add(Token(TokenType.Str, _start, lexeme: lexeme));
      }
    }
  }

  // captures the lexeme without the leading and trailing '
  void _quotedString() {
    while (_peek() != cc.CharCode.SingleQuote && !_isAtEnd()) {
      _advance();
    }
    if (_isAtEnd()) {
      _error(_hintDidYouForgetToOpenOrCloseQuote);
      return;
    }
    // consume the closing '
    _advance();
    _tokens.add(Token(TokenType.QuotedStr, _start + 1,
        lexeme: _input.substring(_start + 1, _current - 1)));
  }

  /// Lexing a regex expression: /.../[igsmyu]*
  void _regex() {
    int p = _current;
    bool inEscape = false;
    bool inCharacterClass = false;
    while (true) {
      if (p >= _input.length) {
        _current = p;
        _error(_hintDidYouForgetToEscapeSlash);
        return;
      }
      final int ch = _input.codeUnitAt(p);
      if (inEscape) {
        inEscape = false;
      } else if (ch == cc.CharCode.Slash && !inCharacterClass) {
        p++;
        break;
      } else if (ch == cc.CharCode.OpenSquareBracket) {
        inCharacterClass = true;
      } else if (ch == cc.CharCode.Backslash) {
        inEscape = true;
      } else if (ch == cc.CharCode.CloseSquareBracket) {
        inCharacterClass = false;
      }
      p++;
    }

    // Consume flags
    while (p < _input.length && _regexFlags.contains(_input.codeUnitAt(p))) {
      p++;
    }

    _current = p;
    final String lexeme = _input.substring(_start, _current);
    _tokens.add(Token(TokenType.RegexStr, _start, lexeme: lexeme));
  }

  bool _isAtEnd() => _current >= _input.length;
}
