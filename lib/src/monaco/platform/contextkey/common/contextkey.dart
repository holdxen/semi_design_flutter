// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/contextkey/common/contextkey.ts
// Translated 1:1 from TypeScript. TypeScript's discriminated union
// `ContextKeyExpression` becomes the abstract interface `ContextKeyExpression`
// implemented by all 16 concrete expr classes; `const enum ContextKeyExprType`
// becomes a class of int constants; the JS RegExp carrier is `ContextKeyRegexp`
// (source + flags + test) so serialize/evaluate stay faithful. Expression
// factories normalize exactly as in TS (constant folding, dedup, OR
// distribution, redundant-term elimination). Runtime truth for the parser and
// expression behavior is captured by tool/ts2dart/_ctxkey_truth.cjs.
// ---------------------------------------------------------------------------

import '../../../base/common/charCode.dart' show CharCode;
import '../../../base/common/platform.dart' show
    isMacintosh, isLinux, isWindows, isChromeOS, isWeb, isEdge, isFirefox, isChrome, isSafari;
import '../../../base/common/strings.dart' show isFalsyOrWhitespace;
import '../../../base/common/errors.dart' show illegalArgument;
import '../../../nls.dart' show localize;
import '../../instantiation/common/instantiation.dart' show createDecorator, ServiceIdentifier;
import 'scanner.dart' show Scanner, LexingError, Token, TokenType;

/// 1:1: `const CONSTANT_VALUES = new Map<string, boolean>()`
final Map<String, bool> CONSTANT_VALUES = <String, bool>{
  'false': false,
  'true': true,
  'isMac': isMacintosh,
  'isLinux': isLinux,
  'isWindows': isWindows,
  'isChromeOS': isChromeOS,
  'isWeb': isWeb,
  'isMacNative': isMacintosh && !isWeb,
  'isEdge': isEdge,
  'isFirefox': isFirefox,
  'isChrome': isChrome,
  'isSafari': isSafari,
};

/// 1:1: `setConstant(key, value)`
void setConstant(String key, bool value) {
  if (CONSTANT_VALUES.containsKey(key)) {
    throw illegalArgument('contextkey.setConstant(k, v) invoked with already set constant `k`');
  }
  CONSTANT_VALUES[key] = value;
}

/// 1:1: `const hasOwnProperty = Object.prototype.hasOwnProperty`
bool _hasOwnProperty(Object object, String prop) =>
    object is Map ? object.containsKey(prop) : (_objKeys(object).contains(prop));
List<String> _objKeys(Object object) => object is Map
    ? object.keys.map((k) => k.toString()).toList()
    : <String>[];

/// 1:1: `export const enum ContextKeyExprType`
class ContextKeyExprType {
  static const int False = 0;
  static const int True = 1;
  static const int Defined = 2;
  static const int Not = 3;
  static const int Equals = 4;
  static const int NotEquals = 5;
  static const int And = 6;
  static const int Regex = 7;
  static const int NotRegex = 8;
  static const int Or = 9;
  static const int In = 10;
  static const int NotIn = 11;
  static const int Greater = 12;
  static const int GreaterEquals = 13;
  static const int Smaller = 14;
  static const int SmallerEquals = 15;
  const ContextKeyExprType._();
}

/// 1:1: `export interface IContextKeyExprMapper`
abstract class IContextKeyExprMapper {
  ContextKeyExpression mapDefined(String key);
  ContextKeyExpression mapNot(String key);
  ContextKeyExpression mapEquals(String key, Object? value);
  ContextKeyExpression mapNotEquals(String key, Object? value);
  ContextKeyExpression mapGreater(String key, Object? value);
  ContextKeyExpression mapGreaterEquals(String key, Object? value);
  ContextKeyExpression mapSmaller(String key, Object? value);
  ContextKeyExpression mapSmallerEquals(String key, Object? value);
  ContextKeyExpression mapRegex(String key, ContextKeyRegexp? regexp);
  ContextKeyExpression mapIn(String key, String valueKey);
  ContextKeyExpression mapNotIn(String key, String valueKey);
}

/// 1:1: `export interface IContext`
abstract class IContext {
  Object? getValue(String key);
}

/// 1:1: `export interface IContextKeyExpression`
abstract class IContextKeyExpression {
  int get type;
  int cmp(ContextKeyExpression other);
  bool equals(ContextKeyExpression other);
  ContextKeyExpression? substituteConstants();
  bool evaluate(IContext context);
  String serialize();
  List<String> keys();
  ContextKeyExpression map(IContextKeyExprMapper mapFnc);
  ContextKeyExpression negate();
}

/// 1:1: `export type ContextKeyExpression = (...16 expr classes...)`
/// The TS discriminated union is represented by its common interface.
typedef ContextKeyExpression = IContextKeyExpression;

/// 1:1: `export type ParserConfig = { regexParsingWithErrorRecovery: boolean }`
class ParserConfig {
  final bool regexParsingWithErrorRecovery;
  const ParserConfig({this.regexParsingWithErrorRecovery = true});
}

/// 1:1: `const defaultConfig: ParserConfig = { regexParsingWithErrorRecovery: true }`
const ParserConfig defaultConfig = ParserConfig(regexParsingWithErrorRecovery: true);

/// 1:1: `export type ParsingError = { message; offset; lexeme; additionalInfo? }`
class ParsingError {
  final String message;
  final int offset;
  final String lexeme;
  final String? additionalInfo;
  ParsingError(this.message, this.offset, this.lexeme, [this.additionalInfo]);
}

/// 1:1: `export type ContextKeyValue = ...`
typedef ContextKeyValue = Object?;

/// 1:1: `RegExp` carrier: source + flags + test(value).
/// Dart's RegExp lacks `.source`/`.flags`, so we keep the JS lexical form.
class ContextKeyRegexp {
  final String source;
  final String flags;
  final RegExp _regexp;
  ContextKeyRegexp(this.source, this.flags, this._regexp);

  /// Build a carrier from a JS-style `/source/flags` lexeme or raw source+flags.
  factory ContextKeyRegexp.fromSource(String source, [String flags = '']) {
    bool caseInsensitive = false;
    bool multiLine = false;
    bool dotAll = false;
    for (final f in flags.split('')) {
      if (f == 'i') caseInsensitive = true;
      if (f == 'm') multiLine = true;
      if (f == 's') dotAll = true;
    }
    return ContextKeyRegexp(source, flags,
        RegExp(source, caseSensitive: !caseInsensitive, multiLine: multiLine, dotAll: dotAll));
  }

  bool test(Object? value) => _regexp.hasMatch(value == null ? 'null' : value.toString());
  @override
  String toString() => '/$source/$flags';
}

// localize error/hint messages (1:1 keys + English defaults from TS source)
const String _errorEmptyString = 'Empty context key expression';
const String _hintEmptyString = "Did you forget to write an expression? You can also put 'false' or 'true' to always evaluate to false or true, respectively.";
const String _errorNoInAfterNot = "'in' after 'not'.";
const String _errorClosingParenthesis = "closing parenthesis ')'";
const String _errorUnexpectedToken = 'Unexpected token';
const String _hintUnexpectedToken = 'Did you forget to put && or || before the token?';
const String _errorUnexpectedEOF = 'Unexpected end of expression';
const String _hintUnexpectedEOF = 'Did you forget to put a context key?';

String _localizeMsg(String key, String message, [List<Object?> args = const <Object?>[]]) =>
    localize(key, message, args);

/// 1:1: `export class Parser`
class Parser {
  /// 1:1: `private static _parseError = new Error()`
  static final Object _parseError = Object();

  final Scanner _scanner = Scanner();
  List<Token> _tokens = <Token>[];
  int _current = 0;
  List<ParsingError> _parsingErrors = <ParsingError>[];
  final ParserConfig _config;

  Parser([ParserConfig? config]) : _config = config ?? defaultConfig;

  List<LexingError> get lexingErrors => _scanner.errors;
  List<ParsingError> get parsingErrors => _parsingErrors;

  /// 1:1: `parse(input)`
  ContextKeyExpression? parse(String input) {
    if (input == '') {
      _parsingErrors.add(ParsingError(_errorEmptyString, 0, '', _hintEmptyString));
      return null;
    }
    _tokens = _scanner.reset(input).scan();
    _current = 0;
    _parsingErrors = <ParsingError>[];
    try {
      final expr = _expr();
      if (!_isAtEnd()) {
        final peek = _peek();
        final additionalInfo = peek.type == TokenType.Str ? _hintUnexpectedToken : null;
        _parsingErrors.add(ParsingError(
            _errorUnexpectedToken, peek.offset, Scanner.getLexeme(peek), additionalInfo));
        throw _parseError;
      }
      return expr;
    } catch (e) {
      if (!identical(e, _parseError)) rethrow;
      return null;
    }
  }

  ContextKeyExpression? _expr() => _or();

  ContextKeyExpression? _or() {
    final expr = <ContextKeyExpression?>[_and()];
    while (_matchOne(TokenType.Or)) {
      expr.add(_and());
    }
    return expr.length == 1 ? expr[0] : ContextKeyExpr.or(expr);
  }

  ContextKeyExpression? _and() {
    final expr = <ContextKeyExpression?>[_term()];
    while (_matchOne(TokenType.And)) {
      expr.add(_term());
    }
    return expr.length == 1 ? expr[0] : ContextKeyExpr.and(expr);
  }

  ContextKeyExpression? _term() {
    if (_matchOne(TokenType.Neg)) {
      final peek = _peek();
      switch (peek.type) {
        case TokenType.True:
          _advance();
          return ContextKeyFalseExpr.INSTANCE;
        case TokenType.False:
          _advance();
          return ContextKeyTrueExpr.INSTANCE;
        case TokenType.LParen:
          _advance();
          final expr = _expr();
          _consume(TokenType.RParen, _errorClosingParenthesis);
          return expr?.negate();
        case TokenType.Str:
          _advance();
          return ContextKeyNotExpr.create(_lex(peek));
        default:
          throw _errExpectedButGot("KEY | true | false | '(' expression ')'", peek);
      }
    }
    return _primary();
  }

  ContextKeyExpression? _primary() {
    final peek = _peek();
    switch (peek.type) {
      case TokenType.True:
        _advance();
        return ContextKeyExpr.true_();
      case TokenType.False:
        _advance();
        return ContextKeyExpr.false_();
      case TokenType.LParen:
        _advance();
        final expr = _expr();
        _consume(TokenType.RParen, _errorClosingParenthesis);
        return expr;
      case TokenType.Str:
        return _parseKeyExpr();
      case TokenType.EOF:
        _parsingErrors.add(
            ParsingError(_errorUnexpectedEOF, peek.offset, '', _hintUnexpectedEOF));
        throw _parseError;
      default:
        throw _errExpectedButGot(
            "true | false | KEY \n\t| KEY '=~' REGEX \n\t| KEY ('==' | '!=' | '<' | '<=' | '>' | '>=' | 'in' | 'not' 'in') value",
            peek);
    }
  }

  /// Factored body of the TS `case TokenType.Str` branch in `_primary()`.
  ContextKeyExpression? _parseKeyExpr() {
    final peek = _peek();
    final key = _lex(peek);
    _advance();

    // =~ regex
    if (_matchOne(TokenType.RegexOp)) {
      final expr = _peek();
      if (!_config.regexParsingWithErrorRecovery) {
        _advance();
        if (expr.type != TokenType.RegexStr) {
          throw _errExpectedButGot('REGEX', expr);
        }
        final regexLexeme = _lex(expr);
        final closingSlashIndex = regexLexeme.lastIndexOf('/');
        final flags = closingSlashIndex == regexLexeme.length - 1
            ? null
            : _removeFlagsGY(regexLexeme.substring(closingSlashIndex + 1));
        ContextKeyRegexp? regexp;
        try {
          regexp = ContextKeyRegexp.fromSource(
              regexLexeme.substring(1, closingSlashIndex), flags ?? '');
        } catch (_) {
          throw _errExpectedButGot('REGEX', expr);
        }
        return ContextKeyRegexExpr.create(key, regexp);
      }
      switch (expr.type) {
        case TokenType.RegexStr:
        case TokenType.Error:
          final lexemeReconstruction = <String>[_lex(expr)];
          _advance();
          Token followingToken = _peek();
          int parenBalance = 0;
          final exprLex = _lex(expr);
          for (int i = 0; i < exprLex.length; i++) {
            if (exprLex.codeUnitAt(i) == CharCode.OpenParen) parenBalance++;
            else if (exprLex.codeUnitAt(i) == CharCode.CloseParen) parenBalance--;
          }
          while (!_isAtEnd() &&
              followingToken.type != TokenType.And &&
              followingToken.type != TokenType.Or) {
            switch (followingToken.type) {
              case TokenType.LParen: parenBalance++; break;
              case TokenType.RParen: parenBalance--; break;
              case TokenType.RegexStr:
              case TokenType.QuotedStr:
                final fl = _lex(followingToken);
                for (int i = 0; i < fl.length; i++) {
                  if (fl.codeUnitAt(i) == CharCode.OpenParen) parenBalance++;
                  // 1:1: original checks `expr.lexeme` (not followingToken) here.
                  else if (exprLex.codeUnitAt(i) == CharCode.CloseParen) parenBalance--;
                }
                break;
            }
            if (parenBalance < 0) break;
            lexemeReconstruction.add(Scanner.getLexeme(followingToken));
            _advance();
            followingToken = _peek();
          }
          final regexLexeme = lexemeReconstruction.join('');
          final closingSlashIndex = regexLexeme.lastIndexOf('/');
          final flags = closingSlashIndex == regexLexeme.length - 1
              ? null
              : _removeFlagsGY(regexLexeme.substring(closingSlashIndex + 1));
          ContextKeyRegexp? regexp;
          try {
            regexp = ContextKeyRegexp.fromSource(
                regexLexeme.substring(1, closingSlashIndex), flags ?? '');
          } catch (_) {
            throw _errExpectedButGot('REGEX', expr);
          }
          return ContextKeyExpr.regex(key, regexp!);
        case TokenType.QuotedStr:
          final serializedValue = _lex(expr);
          _advance();
          ContextKeyRegexp? regex;
          if (!isFalsyOrWhitespace(serializedValue)) {
            final start = serializedValue.indexOf('/');
            final end = serializedValue.lastIndexOf('/');
            if (start != end && start >= 0) {
              final value = serializedValue.substring(start + 1, end);
              final caseIgnoreFlag = end + 1 < serializedValue.length && serializedValue[end + 1] == 'i';
              try {
                regex = ContextKeyRegexp.fromSource(value, caseIgnoreFlag ? 'i' : '');
              } catch (_) {
                throw _errExpectedButGot('REGEX', expr);
              }
            }
          }
          if (regex == null) throw _errExpectedButGot('REGEX', expr);
          return ContextKeyRegexExpr.create(key, regex);
        default:
          throw _errExpectedButGot('REGEX', _peek());
      }
    }

    // [ 'not' 'in' value ]
    if (_matchOne(TokenType.Not)) {
      _consume(TokenType.In, _errorNoInAfterNot);
      final right = _value();
      return ContextKeyExpr.notIn(key, right);
    }

    final maybeOp = _peek().type;
    switch (maybeOp) {
      case TokenType.Eq:
        _advance();
        final right = _value();
        if (_previous().type == TokenType.QuotedStr) {
          return ContextKeyExpr.equals(key, right);
        }
        switch (right) {
          case 'true': return ContextKeyExpr.has(key);
          case 'false': return ContextKeyExpr.not(key);
          default: return ContextKeyExpr.equals(key, right);
        }
      case TokenType.NotEq:
        _advance();
        final right = _value();
        if (_previous().type == TokenType.QuotedStr) {
          return ContextKeyExpr.notEquals(key, right);
        }
        switch (right) {
          case 'true': return ContextKeyExpr.not(key);
          case 'false': return ContextKeyExpr.has(key);
          default: return ContextKeyExpr.notEquals(key, right);
        }
      case TokenType.Lt:
        _advance();
        return ContextKeyGreaterSmaller.smaller(key, _value());
      case TokenType.LtEq:
        _advance();
        return ContextKeyGreaterSmaller.smallerEquals(key, _value());
      case TokenType.Gt:
        _advance();
        return ContextKeyGreaterSmaller.greater(key, _value());
      case TokenType.GtEq:
        _advance();
        return ContextKeyGreaterSmaller.greaterEquals(key, _value());
      case TokenType.In:
        _advance();
        return ContextKeyExpr.in_(key, _value());
      default:
        return ContextKeyExpr.has(key);
    }
  }

  String _value() {
    final token = _peek();
    switch (token.type) {
      case TokenType.Str:
      case TokenType.QuotedStr:
        _advance();
        return _lex(token);
      case TokenType.True:
        _advance();
        return 'true';
      case TokenType.False:
        _advance();
        return 'false';
      case TokenType.In:
        _advance();
        return 'in';
      default:
        return '';
    }
  }

  static final RegExp _flagsGYRe = RegExp(r'[gy]');
  String _removeFlagsGY(String flags) => flags.replaceAll(_flagsGYRe, '');

  Token _previous() => _tokens[_current - 1];
  bool _matchOne(int token) {
    if (_check(token)) { _advance(); return true; }
    return false;
  }
  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }
  Token _consume(int type, String message) {
    if (_check(type)) return _advance();
    throw _errExpectedButGot(message, _peek());
  }
  Object _errExpectedButGot(String expected, Token got, [String? additionalInfo]) {
    final lexeme = Scanner.getLexeme(got);
    final message = _localizeMsg('contextkey.parser.error.expectedButGot',
        'Expected: {0}\nReceived: \'{1}\'.', [expected, lexeme]);
    _parsingErrors.add(ParsingError(message, got.offset, lexeme, additionalInfo));
    return _parseError;
  }
  bool _check(int type) => _peek().type == type;
  Token _peek() => _tokens[_current];
  bool _isAtEnd() => _peek().type == TokenType.EOF;
  String _lex(Token t) => t.lexeme ?? '';
}

/// 1:1: `export abstract class ContextKeyExpr` (static factories)
abstract class ContextKeyExpr {
  static ContextKeyExpression false_() => ContextKeyFalseExpr.INSTANCE;
  static ContextKeyExpression true_() => ContextKeyTrueExpr.INSTANCE;
  static ContextKeyExpression has(String key) => ContextKeyDefinedExpr.create(key);
  static ContextKeyExpression equals(String key, Object? value) => ContextKeyEqualsExpr.create(key, value);
  static ContextKeyExpression notEquals(String key, Object? value) => ContextKeyNotEqualsExpr.create(key, value);
  static ContextKeyExpression regex(String key, ContextKeyRegexp value) => ContextKeyRegexExpr.create(key, value);
  static ContextKeyExpression in_(String key, String value) => ContextKeyInExpr.create(key, value);
  static ContextKeyExpression notIn(String key, String value) => ContextKeyNotInExpr.create(key, value);
  static ContextKeyExpression not(String key) => ContextKeyNotExpr.create(key);
  static ContextKeyExpression? and(List<ContextKeyExpression?> expr) => ContextKeyAndExpr.create(expr, null, true);
  static ContextKeyExpression? or(List<ContextKeyExpression?> expr) => ContextKeyOrExpr.create(expr, null, true);
  static ContextKeyExpression greater(String key, num value) => ContextKeyGreaterExpr.create(key, value);
  static ContextKeyExpression greaterEquals(String key, num value) => ContextKeyGreaterEqualsExpr.create(key, value);
  static ContextKeyExpression smaller(String key, num value) => ContextKeySmallerExpr.create(key, value);
  static ContextKeyExpression smallerEquals(String key, num value) => ContextKeySmallerEqualsExpr.create(key, value);

  static final Parser _parser = Parser(const ParserConfig(regexParsingWithErrorRecovery: false));
  static ContextKeyExpression? deserialize(String? serialized) {
    if (serialized == null) return null;
    return _parser.parse(serialized);
  }
}

/// 1:1: `validateWhenClauses(whenClauses)`
List<List<Map<String, Object?>>> validateWhenClauses(List<String> whenClauses) {
  final parser = Parser(const ParserConfig(regexParsingWithErrorRecovery: false));
  return whenClauses.map((whenClause) {
    parser.parse(whenClause);
    if (parser.lexingErrors.isNotEmpty) {
      return parser.lexingErrors.map((LexingError se) => <String, Object?>{
        'errorMessage': se.additionalInfo != null
            ? _localizeMsg('contextkey.scanner.errorForLinterWithHint',
                'Unexpected token. Hint: {0}', [se.additionalInfo])
            : _localizeMsg('contextkey.scanner.errorForLinter', 'Unexpected token.'),
        'offset': se.offset,
        'length': se.lexeme.length,
      }).toList();
    } else if (parser.parsingErrors.isNotEmpty) {
      return parser.parsingErrors.map((ParsingError pe) => <String, Object?>{
        'errorMessage': pe.additionalInfo != null ? '${pe.message}. ${pe.additionalInfo}' : pe.message,
        'offset': pe.offset,
        'length': pe.lexeme.length,
      }).toList();
    }
    return <Map<String, Object?>>[];
  }).toList();
}

/// 1:1: `expressionsAreEqualWithConstantSubstitution`
bool expressionsAreEqualWithConstantSubstitution(
    ContextKeyExpression? a, ContextKeyExpression? b) {
  final aExpr = a?.substituteConstants();
  final bExpr = b?.substituteConstants();
  if (aExpr == null && bExpr == null) return true;
  if (aExpr == null || bExpr == null) return false;
  return aExpr.equals(bExpr);
}

int _cmp(ContextKeyExpression a, ContextKeyExpression b) => a.cmp(b);
int cmp1(String key1, String key2) => key1 == key2 ? 0 : (key1.compareTo(key2) < 0 ? -1 : 1);
int cmp2(String key1, Object? value1, String key2, Object? value2) {
  final c = cmp1(key1, key2);
  if (c != 0) return c;
  final v = _jsCompare(value1, value2);
  return v;
}
int _jsCompare(Object? a, Object? b) {
  if (a == null || b == null) return a == b ? 0 : (a == null ? -1 : 1);
  final as = a.toString(), bs = b.toString();
  return as == bs ? 0 : (as.compareTo(bs) < 0 ? -1 : 1);
}

/// 1:1: `withFloatOrStr`
ContextKeyExpression _withFloatOrStr(
    Object? value, ContextKeyExpression Function(Object?) callback) {
  if (value is String) {
    final n = double.tryParse(value);
    if (n != null) value = n;
  }
  if (value is String || value is num) return callback(value);
  return ContextKeyFalseExpr.INSTANCE;
}


/// 1:1: JS `${number}` stringification (integral doubles print without `.0`).
String _jsNum(Object? v) {
  if (v is int) return v.toString();
  if (v is double) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toString();
  }
  return v.toString();
}

/// 1:1: JS loose equality (`==`) used by EqualsExpr.evaluate.
bool _jsLooseEq(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a is num && b is num) return a == b;
  if (a is String && b is num) return (double.tryParse(a) ?? double.nan) == b;
  if (a is num && b is String) return a == (double.tryParse(b) ?? double.nan);
  return a == b;
}
bool _jsLooseNotEq(Object? a, Object? b) => !_jsLooseEq(a, b);

/// 1:1: `export class ContextKeyFalseExpr`
class ContextKeyFalseExpr implements IContextKeyExpression {
  static final ContextKeyFalseExpr INSTANCE = ContextKeyFalseExpr._();
  ContextKeyFalseExpr._();

  @override int get type => ContextKeyExprType.False;
  @override int cmp(ContextKeyExpression other) => type - other.type;
  @override bool equals(ContextKeyExpression other) => other.type == type;
  @override ContextKeyExpression? substituteConstants() => this;
  @override bool evaluate(IContext context) => false;
  @override String serialize() => 'false';
  @override List<String> keys() => <String>[];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => this;
  @override ContextKeyExpression negate() => ContextKeyTrueExpr.INSTANCE;
}

/// 1:1: `export class ContextKeyTrueExpr`
class ContextKeyTrueExpr implements IContextKeyExpression {
  static final ContextKeyTrueExpr INSTANCE = ContextKeyTrueExpr._();
  ContextKeyTrueExpr._();

  @override int get type => ContextKeyExprType.True;
  @override int cmp(ContextKeyExpression other) => type - other.type;
  @override bool equals(ContextKeyExpression other) => other.type == type;
  @override ContextKeyExpression? substituteConstants() => this;
  @override bool evaluate(IContext context) => true;
  @override String serialize() => 'true';
  @override List<String> keys() => <String>[];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => this;
  @override ContextKeyExpression negate() => ContextKeyFalseExpr.INSTANCE;
}

/// 1:1: `export class ContextKeyDefinedExpr`
class ContextKeyDefinedExpr implements IContextKeyExpression {
  static ContextKeyExpression create(String key, [ContextKeyExpression? negated]) {
    final constantValue = CONSTANT_VALUES[key];
    if (constantValue != null) {
      return constantValue ? ContextKeyTrueExpr.INSTANCE : ContextKeyFalseExpr.INSTANCE;
    }
    return ContextKeyDefinedExpr(key, negated);
  }

  final String key;
  ContextKeyExpression? negated;
  ContextKeyDefinedExpr(this.key, [this.negated]);

  @override int get type => ContextKeyExprType.Defined;
  @override int cmp(ContextKeyExpression other) =>
      other.type != type ? type - other.type : cmp1(key, (other as ContextKeyDefinedExpr).key);
  @override bool equals(ContextKeyExpression other) =>
      other.type == type && key == (other as ContextKeyDefinedExpr).key;
  @override ContextKeyExpression? substituteConstants() {
    final constantValue = CONSTANT_VALUES[key];
    if (constantValue != null) {
      return constantValue ? ContextKeyTrueExpr.INSTANCE : ContextKeyFalseExpr.INSTANCE;
    }
    return this;
  }
  @override bool evaluate(IContext context) => context.getValue(key) != null && context.getValue(key) != false && context.getValue(key) != '' && context.getValue(key) != 0;
  @override String serialize() => key;
  @override List<String> keys() => <String>[key];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapDefined(key);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeyNotExpr.create(key, this);
    return negated!;
  }
}

/// 1:1: `export class ContextKeyEqualsExpr`
class ContextKeyEqualsExpr implements IContextKeyExpression {
  static ContextKeyExpression create(String key, Object? value, [ContextKeyExpression? negated]) {
    if (value is bool) {
      return value
          ? ContextKeyDefinedExpr.create(key, negated)
          : ContextKeyNotExpr.create(key, negated);
    }
    final constantValue = CONSTANT_VALUES[key];
    if (constantValue != null) {
      final trueValue = constantValue ? 'true' : 'false';
      return value == trueValue ? ContextKeyTrueExpr.INSTANCE : ContextKeyFalseExpr.INSTANCE;
    }
    return ContextKeyEqualsExpr(key, value, negated);
  }

  final String key;
  final Object? value;
  ContextKeyExpression? negated;
  ContextKeyEqualsExpr(this.key, this.value, [this.negated]);

  @override int get type => ContextKeyExprType.Equals;
  @override int cmp(ContextKeyExpression other) =>
      other.type != type ? type - other.type : cmp2(key, value, (other as ContextKeyEqualsExpr).key, (other as ContextKeyEqualsExpr).value);
  @override bool equals(ContextKeyExpression other) {
    if (other.type == type) {
      final o = other as ContextKeyEqualsExpr;
      return key == o.key && value == o.value;
    }
    return false;
  }
  @override ContextKeyExpression? substituteConstants() {
    final constantValue = CONSTANT_VALUES[key];
    if (constantValue != null) {
      final trueValue = constantValue ? 'true' : 'false';
      return value == trueValue ? ContextKeyTrueExpr.INSTANCE : ContextKeyFalseExpr.INSTANCE;
    }
    return this;
  }
  @override bool evaluate(IContext context) => _jsLooseEq(context.getValue(key), value);
  @override String serialize() => "$key == '${_jsNum(value)}'";
  @override List<String> keys() => <String>[key];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapEquals(key, value);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeyNotEqualsExpr.create(key, value, this);
    return negated!;
  }
}

/// 1:1: `export class ContextKeyNotEqualsExpr`
class ContextKeyNotEqualsExpr implements IContextKeyExpression {
  static ContextKeyExpression create(String key, Object? value, [ContextKeyExpression? negated]) {
    if (value is bool) {
      return value
          ? ContextKeyNotExpr.create(key, negated)
          : ContextKeyDefinedExpr.create(key, negated);
    }
    final constantValue = CONSTANT_VALUES[key];
    if (constantValue != null) {
      final falseValue = constantValue ? 'true' : 'false';
      return value == falseValue ? ContextKeyFalseExpr.INSTANCE : ContextKeyTrueExpr.INSTANCE;
    }
    return ContextKeyNotEqualsExpr(key, value, negated);
  }

  final String key;
  final Object? value;
  ContextKeyExpression? negated;
  ContextKeyNotEqualsExpr(this.key, this.value, [this.negated]);

  @override int get type => ContextKeyExprType.NotEquals;
  @override int cmp(ContextKeyExpression other) =>
      other.type != type ? type - other.type : cmp2(key, value, (other as ContextKeyNotEqualsExpr).key, (other as ContextKeyNotEqualsExpr).value);
  @override bool equals(ContextKeyExpression other) {
    if (other.type == type) {
      final o = other as ContextKeyNotEqualsExpr;
      return key == o.key && value == o.value;
    }
    return false;
  }
  @override ContextKeyExpression? substituteConstants() {
    final constantValue = CONSTANT_VALUES[key];
    if (constantValue != null) {
      final falseValue = constantValue ? 'true' : 'false';
      return value == falseValue ? ContextKeyFalseExpr.INSTANCE : ContextKeyTrueExpr.INSTANCE;
    }
    return this;
  }
  @override bool evaluate(IContext context) => _jsLooseNotEq(context.getValue(key), value);
  @override String serialize() => "$key != '${_jsNum(value)}'";
  @override List<String> keys() => <String>[key];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapNotEquals(key, value);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeyEqualsExpr.create(key, value, this);
    return negated!;
  }
}

/// 1:1: `export class ContextKeyNotExpr`
class ContextKeyNotExpr implements IContextKeyExpression {
  static ContextKeyExpression create(String key, [ContextKeyExpression? negated]) {
    final constantValue = CONSTANT_VALUES[key];
    if (constantValue != null) {
      return constantValue ? ContextKeyFalseExpr.INSTANCE : ContextKeyTrueExpr.INSTANCE;
    }
    return ContextKeyNotExpr(key, negated);
  }

  final String key;
  ContextKeyExpression? negated;
  ContextKeyNotExpr(this.key, [this.negated]);

  @override int get type => ContextKeyExprType.Not;
  @override int cmp(ContextKeyExpression other) =>
      other.type != type ? type - other.type : cmp1(key, (other as ContextKeyNotExpr).key);
  @override bool equals(ContextKeyExpression other) =>
      other.type == type && key == (other as ContextKeyNotExpr).key;
  @override ContextKeyExpression? substituteConstants() {
    final constantValue = CONSTANT_VALUES[key];
    if (constantValue != null) {
      return constantValue ? ContextKeyFalseExpr.INSTANCE : ContextKeyTrueExpr.INSTANCE;
    }
    return this;
  }
  @override bool evaluate(IContext context) {
    final v = context.getValue(key);
    return v == null || v == false || v == '' || v == 0;
  }
  @override String serialize() => '!$key';
  @override List<String> keys() => <String>[key];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapNot(key);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeyDefinedExpr.create(key, this);
    return negated!;
  }
}

/// 1:1: `export class ContextKeyInExpr`
class ContextKeyInExpr implements IContextKeyExpression {
  static ContextKeyInExpr create(String key, String valueKey) => ContextKeyInExpr(key, valueKey);
  final String key;
  final String valueKey;
  ContextKeyExpression? negated;
  ContextKeyInExpr(this.key, this.valueKey);

  @override int get type => ContextKeyExprType.In;
  @override int cmp(ContextKeyExpression other) {
    if (other.type != type) return type - other.type;
    final o = other as ContextKeyInExpr;
    return cmp2(key, valueKey, o.key, o.valueKey);
  }
  @override bool equals(ContextKeyExpression other) {
    if (other.type == type) {
      final o = other as ContextKeyInExpr;
      return key == o.key && valueKey == o.valueKey;
    }
    return false;
  }
  @override ContextKeyExpression? substituteConstants() => this;
  @override bool evaluate(IContext context) {
    final source = context.getValue(valueKey);
    final item = context.getValue(key);
    if (source is List) {
      if (source.any((s) => s == item)) return true;
      if (isWindows && item is String && item.startsWith('file:///')) {
        final itemLower = item.toLowerCase();
        return source.any((s) => s is String && s.toLowerCase() == itemLower);
      }
      return false;
    }
    if (item is String && source is Map) {
      if (_hasOwnProperty(source, item)) return true;
      if (isWindows && item.startsWith('file:///')) {
        final itemLower = item.toLowerCase();
        return source.keys.any((k) => k.toString().toLowerCase() == itemLower);
      }
      return false;
    }
    return false;
  }
  @override String serialize() => "$key in '$valueKey'";
  @override List<String> keys() => <String>[key, valueKey];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapIn(key, valueKey);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeyNotInExpr.create(key, valueKey);
    return negated!;
  }
}

/// 1:1: `export class ContextKeyNotInExpr`
class ContextKeyNotInExpr implements IContextKeyExpression {
  static ContextKeyNotInExpr create(String key, String valueKey) => ContextKeyNotInExpr(key, valueKey);
  final String key;
  final String valueKey;
  late final ContextKeyInExpr _negated;
  ContextKeyNotInExpr(this.key, this.valueKey) {
    _negated = ContextKeyInExpr.create(key, valueKey);
  }
  @override int get type => ContextKeyExprType.NotIn;
  @override int cmp(ContextKeyExpression other) =>
      other.type != type ? type - other.type : _negated.cmp((other as ContextKeyNotInExpr)._negated);
  @override bool equals(ContextKeyExpression other) =>
      other.type == type && _negated.equals((other as ContextKeyNotInExpr)._negated);
  @override ContextKeyExpression? substituteConstants() => this;
  @override bool evaluate(IContext context) => !_negated.evaluate(context);
  @override String serialize() => "$key not in '$valueKey'";
  @override List<String> keys() => _negated.keys();
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapNotIn(key, valueKey);
  @override ContextKeyExpression negate() => _negated;
}

/// 1:1: numeric comparison expr (Greater / GreaterEquals / Smaller / SmallerEquals).
/// Generated as one class per TS class via subclasses of a shared base.
abstract class _CmpExpr implements IContextKeyExpression {
  final String key;
  final Object? value; // num | String
  ContextKeyExpression? negated;
  _CmpExpr(this.key, this.value, [this.negated]);

  @override int cmp(ContextKeyExpression other) {
    if (other.type != type) return type - other.type;
    final o = other as _CmpExpr;
    return cmp2(key, value, o.key, o.value);
  }
  @override bool equals(ContextKeyExpression other) {
    if (other.type == type) {
      final o = other as _CmpExpr;
      return key == o.key && value == o.value;
    }
    return false;
  }
  @override ContextKeyExpression? substituteConstants() => this;
  bool _numValue(IContext context) {
    if (value is String) return false;
    return true;
  }
  double _ctxNum(IContext context) => double.tryParse(context.getValue(key)?.toString() ?? '') ?? double.nan;
  @override List<String> keys() => <String>[key];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc);
}

/// 1:1: `ContextKeyGreaterExpr`
class ContextKeyGreaterExpr extends _CmpExpr {
  static ContextKeyExpression create(String key, Object? value, [ContextKeyExpression? negated]) =>
      _withFloatOrStr(value, (v) => ContextKeyGreaterExpr(key, v, negated));
  ContextKeyGreaterExpr(String key, Object? value, [ContextKeyExpression? negated]) : super(key, value, negated);
  @override int get type => ContextKeyExprType.Greater;
  @override bool evaluate(IContext context) => value is String ? false : _ctxNum(context) > (value as num);
  @override String serialize() => "$key > ${_jsNum(value)}";
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapGreater(key, value);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeySmallerEqualsExpr.create(key, value, this);
    return negated!;
  }
}

/// 1:1: `ContextKeyGreaterEqualsExpr`
class ContextKeyGreaterEqualsExpr extends _CmpExpr {
  static ContextKeyExpression create(String key, Object? value, [ContextKeyExpression? negated]) =>
      _withFloatOrStr(value, (v) => ContextKeyGreaterEqualsExpr(key, v, negated));
  ContextKeyGreaterEqualsExpr(String key, Object? value, [ContextKeyExpression? negated]) : super(key, value, negated);
  @override int get type => ContextKeyExprType.GreaterEquals;
  @override bool evaluate(IContext context) => value is String ? false : _ctxNum(context) >= (value as num);
  @override String serialize() => "$key >= ${_jsNum(value)}";
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapGreaterEquals(key, value);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeySmallerExpr.create(key, value, this);
    return negated!;
  }
}

/// 1:1: `ContextKeySmallerExpr`
class ContextKeySmallerExpr extends _CmpExpr {
  static ContextKeyExpression create(String key, Object? value, [ContextKeyExpression? negated]) =>
      _withFloatOrStr(value, (v) => ContextKeySmallerExpr(key, v, negated));
  ContextKeySmallerExpr(String key, Object? value, [ContextKeyExpression? negated]) : super(key, value, negated);
  @override int get type => ContextKeyExprType.Smaller;
  @override bool evaluate(IContext context) => value is String ? false : _ctxNum(context) < (value as num);
  @override String serialize() => "$key < ${_jsNum(value)}";
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapSmaller(key, value);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeyGreaterEqualsExpr.create(key, value, this);
    return negated!;
  }
}

/// 1:1: `ContextKeySmallerEqualsExpr`
class ContextKeySmallerEqualsExpr extends _CmpExpr {
  static ContextKeyExpression create(String key, Object? value, [ContextKeyExpression? negated]) =>
      _withFloatOrStr(value, (v) => ContextKeySmallerEqualsExpr(key, v, negated));
  ContextKeySmallerEqualsExpr(String key, Object? value, [ContextKeyExpression? negated]) : super(key, value, negated);
  @override int get type => ContextKeyExprType.SmallerEquals;
  @override bool evaluate(IContext context) => value is String ? false : _ctxNum(context) <= (value as num);
  @override String serialize() => "$key <= ${_jsNum(value)}";
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapSmallerEquals(key, value);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeyGreaterExpr.create(key, value, this);
    return negated!;
  }
}

/// 1:1 factory façade matching the TS `ContextKeySmallerExpr.create` call sites
/// used by the parser (kept separate from ContextKeyExpr which holds `num`).
class ContextKeyGreaterSmaller {
  static ContextKeyExpression greater(String key, Object? value) => ContextKeyGreaterExpr.create(key, value);
  static ContextKeyExpression greaterEquals(String key, Object? value) => ContextKeyGreaterEqualsExpr.create(key, value);
  static ContextKeyExpression smaller(String key, Object? value) => ContextKeySmallerExpr.create(key, value);
  static ContextKeyExpression smallerEquals(String key, Object? value) => ContextKeySmallerEqualsExpr.create(key, value);
}

/// 1:1: `export class ContextKeyRegexExpr`
class ContextKeyRegexExpr implements IContextKeyExpression {
  static ContextKeyRegexExpr create(String key, ContextKeyRegexp? regexp) => ContextKeyRegexExpr(key, regexp);
  final String key;
  final ContextKeyRegexp? regexp;
  ContextKeyExpression? negated;
  ContextKeyRegexExpr(this.key, this.regexp);
  @override int get type => ContextKeyExprType.Regex;
  @override int cmp(ContextKeyExpression other) {
    if (other.type != type) return type - other.type;
    final o = other as ContextKeyRegexExpr;
    final c = cmp1(key, o.key);
    if (c != 0) return c;
    final thisSource = regexp?.source ?? '';
    final otherSource = o.regexp?.source ?? '';
    return thisSource == otherSource ? 0 : (thisSource.compareTo(otherSource) < 0 ? -1 : 1);
  }
  @override bool equals(ContextKeyExpression other) {
    if (other.type == type) {
      final o = other as ContextKeyRegexExpr;
      return key == o.key && (regexp?.source ?? '') == (o.regexp?.source ?? '');
    }
    return false;
  }
  @override ContextKeyExpression? substituteConstants() => this;
  @override bool evaluate(IContext context) => regexp?.test(context.getValue(key)) ?? false;
  @override String serialize() => "$key =~ /${regexp?.source ?? 'invalid'}/${regexp?.flags ?? ''}";
  @override List<String> keys() => <String>[key];
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => mapFnc.mapRegex(key, regexp);
  @override ContextKeyExpression negate() {
    negated ??= ContextKeyNotRegexExpr.create(this);
    return negated!;
  }
}

/// 1:1: `export class ContextKeyNotRegexExpr`
class ContextKeyNotRegexExpr implements IContextKeyExpression {
  static ContextKeyExpression create(ContextKeyRegexExpr actual) => ContextKeyNotRegexExpr(actual);
  final ContextKeyRegexExpr _actual;
  ContextKeyNotRegexExpr(this._actual);
  @override int get type => ContextKeyExprType.NotRegex;
  @override int cmp(ContextKeyExpression other) =>
      other.type != type ? type - other.type : _actual.cmp((other as ContextKeyNotRegexExpr)._actual);
  @override bool equals(ContextKeyExpression other) =>
      other.type == type && _actual.equals((other as ContextKeyNotRegexExpr)._actual);
  @override ContextKeyExpression? substituteConstants() => this;
  @override bool evaluate(IContext context) => !_actual.evaluate(context);
  @override String serialize() => '!(${_actual.serialize()})';
  @override List<String> keys() => _actual.keys();
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) => ContextKeyNotRegexExpr(_actual.map(mapFnc) as ContextKeyRegexExpr);
  @override ContextKeyExpression negate() => _actual;
}

/// 1:1: `eliminateConstantsInArray(arr)`
/// Returns the same list instance if nothing changed (identity matters).
List<ContextKeyExpression?> eliminateConstantsInArray(List<ContextKeyExpression> arr) {
  List<ContextKeyExpression?>? newArr;
  for (int i = 0; i < arr.length; i++) {
    final newExpr = arr[i].substituteConstants();
    if (!identical(arr[i], newExpr)) {
      if (newArr == null) {
        newArr = <ContextKeyExpression?>[];
        for (int j = 0; j < i; j++) newArr.add(arr[j]);
      }
    }
    if (newArr != null) newArr.add(newExpr);
  }
  return newArr ?? List<ContextKeyExpression?>.from(arr);
}

/// 1:1: `export class ContextKeyAndExpr`
class ContextKeyAndExpr implements IContextKeyExpression {
  static ContextKeyExpression? create(List<ContextKeyExpression?> expr, ContextKeyExpression? negated, bool extraRedundantCheck) =>
      _normalizeArr(expr, negated, extraRedundantCheck);

  final List<ContextKeyExpression> expr;
  ContextKeyExpression? negated;
  ContextKeyAndExpr(this.expr, [this.negated]);

  @override int get type => ContextKeyExprType.And;
  @override int cmp(ContextKeyExpression other) {
    if (other.type != type) return type - other.type;
    final o = other as ContextKeyAndExpr;
    if (expr.length < o.expr.length) return -1;
    if (expr.length > o.expr.length) return 1;
    for (int i = 0; i < expr.length; i++) {
      final r = _cmp(expr[i], o.expr[i]);
      if (r != 0) return r;
    }
    return 0;
  }
  @override bool equals(ContextKeyExpression other) {
    if (other.type == type) {
      final o = other as ContextKeyAndExpr;
      if (expr.length != o.expr.length) return false;
      for (int i = 0; i < expr.length; i++) {
        if (!expr[i].equals(o.expr[i])) return false;
      }
      return true;
    }
    return false;
  }
  @override ContextKeyExpression? substituteConstants() {
    final exprArr = eliminateConstantsInArray(expr);
    final changed = exprArr.length != expr.length ||
        !_listIdenticalByIndex(exprArr, expr);
    if (!changed) return this;
    return ContextKeyAndExpr.create(exprArr, negated, false);
  }
  @override bool evaluate(IContext context) {
    for (final e in expr) {
      if (!e.evaluate(context)) return false;
    }
    return true;
  }

  static ContextKeyExpression? _normalizeArr(
      List<ContextKeyExpression?> arr, ContextKeyExpression? negated, bool extraRedundantCheck) {
    final expr = <ContextKeyExpression>[];
    bool hasTrue = false;
    for (final e in arr) {
      if (e == null) continue;
      if (e.type == ContextKeyExprType.True) { hasTrue = true; continue; }
      if (e.type == ContextKeyExprType.False) return ContextKeyFalseExpr.INSTANCE;
      if (e.type == ContextKeyExprType.And) { expr.addAll((e as ContextKeyAndExpr).expr); continue; }
      expr.add(e);
    }
    if (expr.isEmpty && hasTrue) return ContextKeyTrueExpr.INSTANCE;
    if (expr.isEmpty) return null;
    if (expr.length == 1) return expr[0];

    expr.sort(_cmp);
    _dedupSorted(expr);
    if (expr.length == 1) return expr[0];

    // distribute OR over AND
    while (expr.length > 1) {
      int orIndex = -1;
      for (int i = expr.length - 1; i >= 0; i--) {
        if (expr[i].type == ContextKeyExprType.Or) { orIndex = i; break; }
      }
      if (orIndex == -1) break;
      final lastElement = expr.removeAt(orIndex) as ContextKeyOrExpr;
      final secondToLastElement = expr.removeLast();
      final isFinished = expr.isEmpty;
      final resultElement = ContextKeyOrExpr.create(
        lastElement.expr.map((el) => ContextKeyAndExpr.create([el, secondToLastElement], null, extraRedundantCheck)).toList(),
        null, isFinished);
      if (resultElement != null) {
        if (resultElement.type == ContextKeyExprType.False) return ContextKeyFalseExpr.INSTANCE;
        expr.add(resultElement);
        expr.sort(_cmp);
      }
    }
    if (expr.length == 1) return expr[0];

    if (expr.any((e) => e.type == ContextKeyExprType.And)) {
      final terms = <ContextKeyExpression>[];
      for (final e in expr) {
        if (e.type == ContextKeyExprType.And) terms.addAll((e as ContextKeyAndExpr).expr);
        else terms.add(e);
      }
      terms.sort(_cmp);
      expr.clear();
      for (final term in terms) {
        if (expr.isEmpty || !expr.last.equals(term)) expr.add(term);
      }
    }

    if (extraRedundantCheck) {
      for (int i = 0; i < expr.length; i++) {
        for (int j = i + 1; j < expr.length; j++) {
          if (expr[i].negate().equals(expr[j])) return ContextKeyFalseExpr.INSTANCE;
        }
      }
      if (expr.length == 1) return expr[0];
    }
    return ContextKeyAndExpr(expr, negated);
  }

  @override String serialize() => expr.map((e) => e.serialize()).join(' && ');
  @override List<String> keys() {
    final result = <String>[];
    for (final e in expr) result.addAll(e.keys());
    return result;
  }
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) =>
      ContextKeyAndExpr(expr.map((e) => e.map(mapFnc)).toList(), null);
  @override ContextKeyExpression negate() {
    if (negated == null) {
      final result = expr.map((e) => e.negate()).toList();
      negated = ContextKeyOrExpr.create(result, this, true)!;
    }
    return negated!;
  }
}

/// 1:1: `export class ContextKeyOrExpr`
class ContextKeyOrExpr implements IContextKeyExpression {
  static ContextKeyExpression? create(List<ContextKeyExpression?> expr, ContextKeyExpression? negated, bool extraRedundantCheck) =>
      _normalizeArr(expr, negated, extraRedundantCheck);

  final List<ContextKeyExpression> expr;
  ContextKeyExpression? negated;
  ContextKeyOrExpr(this.expr, [this.negated]);

  @override int get type => ContextKeyExprType.Or;
  @override int cmp(ContextKeyExpression other) {
    if (other.type != type) return type - other.type;
    final o = other as ContextKeyOrExpr;
    if (expr.length < o.expr.length) return -1;
    if (expr.length > o.expr.length) return 1;
    for (int i = 0; i < expr.length; i++) {
      final r = _cmp(expr[i], o.expr[i]);
      if (r != 0) return r;
    }
    return 0;
  }
  @override bool equals(ContextKeyExpression other) {
    if (other.type == type) {
      final o = other as ContextKeyOrExpr;
      if (expr.length != o.expr.length) return false;
      for (int i = 0; i < expr.length; i++) {
        if (!expr[i].equals(o.expr[i])) return false;
      }
      return true;
    }
    return false;
  }
  @override ContextKeyExpression? substituteConstants() {
    final exprArr = eliminateConstantsInArray(expr);
    final changed = exprArr.length != expr.length || !_listIdenticalByIndex(exprArr, expr);
    if (!changed) return this;
    return ContextKeyOrExpr.create(exprArr, negated, false);
  }
  @override bool evaluate(IContext context) {
    for (final e in expr) {
      if (e.evaluate(context)) return true;
    }
    return false;
  }

  static ContextKeyExpression? _normalizeArr(
      List<ContextKeyExpression?> arr, ContextKeyExpression? negated, bool extraRedundantCheck) {
    var expr = <ContextKeyExpression>[];
    bool hasFalse = false;
    for (final e in arr) {
      if (e == null) continue;
      if (e.type == ContextKeyExprType.False) { hasFalse = true; continue; }
      if (e.type == ContextKeyExprType.True) return ContextKeyTrueExpr.INSTANCE;
      if (e.type == ContextKeyExprType.Or) { expr.addAll((e as ContextKeyOrExpr).expr); continue; }
      expr.add(e);
    }
    if (expr.isEmpty && hasFalse) return ContextKeyFalseExpr.INSTANCE;
    expr.sort(_cmp);
    if (expr.isEmpty) return null;
    if (expr.length == 1) return expr[0];

    _dedupSorted(expr);
    if (expr.length == 1) return expr[0];

    if (extraRedundantCheck) {
      for (int i = 0; i < expr.length; i++) {
        for (int j = i + 1; j < expr.length; j++) {
          if (expr[i].negate().equals(expr[j])) return ContextKeyTrueExpr.INSTANCE;
        }
      }
      if (expr.length == 1) return expr[0];
    }
    return ContextKeyOrExpr(expr, negated);
  }

  @override String serialize() => expr.map((e) => e.serialize()).join(' || ');
  @override List<String> keys() {
    final result = <String>[];
    for (final e in expr) result.addAll(e.keys());
    return result;
  }
  @override ContextKeyExpression map(IContextKeyExprMapper mapFnc) =>
      ContextKeyOrExpr(expr.map((e) => e.map(mapFnc)).toList(), null);
  @override ContextKeyExpression negate() {
    if (negated == null) {
      final result = expr.map((e) => e.negate()).toList();
      while (result.length > 1) {
        final left = result.removeAt(0);
        final right = result.removeAt(0);
        final all = <ContextKeyExpression>[];
        for (final l in _getTerminals(left)) {
          for (final r in _getTerminals(right)) {
            all.add(ContextKeyAndExpr.create([l, r], null, false)!);
          }
        }
        result.insert(0, ContextKeyOrExpr.create(all, null, false)!);
      }
      negated = ContextKeyOrExpr.create(result, this, true)!;
    }
    return negated!;
  }
}

/// 1:1: `getTerminals(node)`
List<ContextKeyExpression> _getTerminals(ContextKeyExpression node) =>
    node.type == ContextKeyExprType.Or ? (node as ContextKeyOrExpr).expr : <ContextKeyExpression>[node];

bool _listIdenticalByIndex(List<ContextKeyExpression?> a, List<ContextKeyExpression> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (!identical(a[i], b[i])) return false;
  }
  return true;
}

void _dedupSorted(List<ContextKeyExpression> expr) {
  for (int i = 1; i < expr.length; i++) {
    if (expr[i - 1].equals(expr[i])) {
      expr.removeAt(i);
      i--;
    }
  }
}

/// 1:1: `export interface ContextKeyInfo`
class ContextKeyInfo {
  final String key;
  final String? type;
  final String? description;
  ContextKeyInfo(this.key, {this.type, this.description});
}

/// 1:1: `export class RawContextKey<T extends ContextKeyValue> extends ContextKeyDefinedExpr`
class RawContextKey<T> extends ContextKeyDefinedExpr {
  static final List<ContextKeyInfo> _info = <ContextKeyInfo>[];
  static Iterable<ContextKeyInfo> all() => _info;

  final T? _defaultValue;
  RawContextKey(String key, this._defaultValue, [Object? metaOrHide]) : super(key, null) {
    if (metaOrHide is Map) {
      _info.add(ContextKeyInfo(key,
          type: metaOrHide['type']?.toString(),
          description: metaOrHide['description']?.toString()));
    } else if (metaOrHide != true) {
      _info.add(ContextKeyInfo(key,
          description: metaOrHide?.toString(),
          type: (_defaultValue != null) ? _defaultValue.runtimeType.toString() : null));
    }
  }

  IContextKey<T> bindTo(IContextKeyServiceType target) => target.createKey<T>(key, _defaultValue);
  T? getValue(IContextKeyServiceType target) => target.getContextKeyValue<T>(key);
  ContextKeyExpression toNegated() => negate();
  ContextKeyExpression isEqualTo(Object? value) => ContextKeyEqualsExpr.create(key, value);
  ContextKeyExpression notEqualsTo(Object? value) => ContextKeyNotEqualsExpr.create(key, value);
  ContextKeyExpression greater(Object? value) => ContextKeyGreaterExpr.create(key, value);
}

/// 1:1: `export interface IContextKey<T>`
abstract class IContextKey<T> {
  void set(T value);
  void reset();
  T? get_();
}

/// 1:1: `export interface IContextKeyServiceTarget`
abstract class IContextKeyServiceTarget {
  IContextKeyServiceTarget? get parentElement;
  void setAttribute(String attr, String value);
  void removeAttribute(String attr);
  bool hasAttribute(String attr);
  String? getAttribute(String attr);
}

/// 1:1: `export const IContextKeyService = createDecorator<IContextKeyService>('contextKeyService')`
final ServiceIdentifier<IContextKeyServiceType> IContextKeyService =
    createDecorator<IContextKeyServiceType>('contextKeyService');

/// 1:1: `export interface IReadableSet<T>`
abstract class IReadableSet<T> {
  bool has(T value);
}

/// 1:1: `export interface IContextKeyChangeEvent`
abstract class IContextKeyChangeEvent {
  bool affectsSome(IReadableSet<String> keys);
  bool allKeysContainedIn(IReadableSet<String> keys);
}

/// 1:1: `export type IScopedContextKeyService = IContextKeyService & IDisposable`
abstract class IScopedContextKeyService implements IContextKeyServiceType {
  void dispose();
}

/// 1:1: `export interface IContextKeyService`
abstract class IContextKeyServiceType {
  Object? get _serviceBrand;
  Object get onDidChangeContext;
  void bufferChangeEvents(void Function() callback);
  IContextKey<T> createKey<T>(String key, T? defaultValue);
  bool contextMatchesRules(ContextKeyExpression? rules);
  T? getContextKeyValue<T>(String key);
  IScopedContextKeyService createScoped(IContextKeyServiceTarget target);
  IContextKeyServiceType createOverlay(Iterable<List<Object?>> overlay);
  IContext getContext(IContextKeyServiceTarget? target);
  void updateParent(IContextKeyServiceType parentContextKeyService);
}

/// 1:1: `implies(p, q)`
bool implies(ContextKeyExpression p, ContextKeyExpression q) {
  if (p.type == ContextKeyExprType.False || q.type == ContextKeyExprType.True) return true;
  if (p.type == ContextKeyExprType.Or) {
    if (q.type == ContextKeyExprType.Or) {
      return _allElementsIncluded((p as ContextKeyOrExpr).expr, (q as ContextKeyOrExpr).expr);
    }
    return false;
  }
  if (q.type == ContextKeyExprType.Or) {
    for (final element in (q as ContextKeyOrExpr).expr) {
      if (implies(p, element)) return true;
    }
    return false;
  }
  if (p.type == ContextKeyExprType.And) {
    if (q.type == ContextKeyExprType.And) {
      return _allElementsIncluded((q as ContextKeyAndExpr).expr, (p as ContextKeyAndExpr).expr);
    }
    for (final element in (p as ContextKeyAndExpr).expr) {
      if (implies(element, q)) return true;
    }
    return false;
  }
  return p.equals(q);
}

/// 1:1: `allElementsIncluded(p, q)` — arrays assumed sorted.
bool _allElementsIncluded(List<ContextKeyExpression> p, List<ContextKeyExpression> q) {
  int pIndex = 0, qIndex = 0;
  while (pIndex < p.length && qIndex < q.length) {
    final c = p[pIndex].cmp(q[qIndex]);
    if (c < 0) return false;
    if (c == 0) { pIndex++; qIndex++; }
    else qIndex++;
  }
  return pIndex == p.length;
}
