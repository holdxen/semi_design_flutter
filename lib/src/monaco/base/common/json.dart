/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

// 1:1 port of vs/base/common/json.ts
//
// PORT NOTES (surface only, algorithms unchanged):
// - `const enum` (ScanError/SyntaxKind/ParseErrorCode/CharacterCodes) → class + static const int.
// - `interface` with mutable impl (NodeImpl) → Dart class with mutable fields.
// - `throw earlyReturnException` (a sentinel Object) → throw a Dart object, caught with identical().
// - `JSON.parse(numberString)` → num.parse; `Object.create(null)` → plain Map (no prototype in Dart).
// - Visitor callbacks → nullable function fields on a JSONVisitor value class.

/// 1:1: `export const enum ScanError`
class ScanError {
  static const int none = 0;
  static const int unexpectedEndOfComment = 1;
  static const int unexpectedEndOfString = 2;
  static const int unexpectedEndOfNumber = 3;
  static const int invalidUnicode = 4;
  static const int invalidEscapeCharacter = 5;
  static const int invalidCharacter = 6;
}

/// 1:1: `export const enum SyntaxKind`
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

/// 1:1: `export const enum ParseErrorCode`
class ParseErrorCode {
  static const int invalidSymbol = 1;
  static const int invalidNumberFormat = 2;
  static const int propertyNameExpected = 3;
  static const int valueExpected = 4;
  static const int colonExpected = 5;
  static const int commaExpected = 6;
  static const int closeBraceExpected = 7;
  static const int closeBracketExpected = 8;
  static const int endOfFileExpected = 9;
  static const int invalidCommentToken = 10;
  static const int unexpectedEndOfComment = 11;
  static const int unexpectedEndOfString = 12;
  static const int unexpectedEndOfNumber = 13;
  static const int invalidUnicode = 14;
  static const int invalidEscapeCharacter = 15;
  static const int invalidCharacter = 16;
}

/// 1:1: `const enum CharacterCodes`
class CharacterCodes {
  static const int nullCharacter = 0;
  static const int maxAsciiCharacter = 0x7F;
  static const int lineFeed = 0x0A;
  static const int carriageReturn = 0x0D;
  static const int lineSeparator = 0x2028;
  static const int paragraphSeparator = 0x2029;
  static const int nextLine = 0x0085;
  static const int space = 0x0020;
  static const int nonBreakingSpace = 0x00A0;
  static const int enQuad = 0x2000;
  static const int emQuad = 0x2001;
  static const int enSpace = 0x2002;
  static const int emSpace = 0x2003;
  static const int threePerEmSpace = 0x2004;
  static const int fourPerEmSpace = 0x2005;
  static const int sixPerEmSpace = 0x2006;
  static const int figureSpace = 0x2007;
  static const int punctuationSpace = 0x2008;
  static const int thinSpace = 0x2009;
  static const int hairSpace = 0x200A;
  static const int zeroWidthSpace = 0x200B;
  static const int narrowNoBreakSpace = 0x202F;
  static const int ideographicSpace = 0x3000;
  static const int mathematicalSpace = 0x205F;
  static const int ogham = 0x1680;
  static const int underscore = 0x5F;
  static const int dollar = 0x24;
  static const int _0 = 0x30;
  static const int _1 = 0x31;
  static const int _2 = 0x32;
  static const int _3 = 0x33;
  static const int _4 = 0x34;
  static const int _5 = 0x35;
  static const int _6 = 0x36;
  static const int _7 = 0x37;
  static const int _8 = 0x38;
  static const int _9 = 0x39;
  static const int a = 0x61;
  static const int b = 0x62;
  static const int c = 0x63;
  static const int d = 0x64;
  static const int e = 0x65;
  static const int f = 0x66;
  static const int g = 0x67;
  static const int h = 0x68;
  static const int i = 0x69;
  static const int j = 0x6A;
  static const int k = 0x6B;
  static const int l = 0x6C;
  static const int m = 0x6D;
  static const int n = 0x6E;
  static const int o = 0x6F;
  static const int p = 0x70;
  static const int q = 0x71;
  static const int r = 0x72;
  static const int s = 0x73;
  static const int t = 0x74;
  static const int u = 0x75;
  static const int v = 0x76;
  static const int w = 0x77;
  static const int x = 0x78;
  static const int y = 0x79;
  static const int z = 0x7A;
  static const int A = 0x41;
  static const int B = 0x42;
  static const int C = 0x43;
  static const int D = 0x44;
  static const int E = 0x45;
  static const int F = 0x46;
  static const int G = 0x47;
  static const int H = 0x48;
  static const int I = 0x49;
  static const int J = 0x4A;
  static const int K = 0x4B;
  static const int L = 0x4C;
  static const int M = 0x4D;
  static const int N = 0x4E;
  static const int O = 0x4F;
  static const int P = 0x50;
  static const int Q = 0x51;
  static const int R = 0x52;
  static const int S = 0x53;
  static const int T = 0x54;
  static const int U = 0x55;
  static const int V = 0x56;
  static const int W = 0x57;
  static const int X = 0x58;
  static const int Y = 0x59;
  static const int Z = 0x5A;
  static const int ampersand = 0x26;
  static const int asterisk = 0x2A;
  static const int at = 0x40;
  static const int backslash = 0x5C;
  static const int bar = 0x7C;
  static const int caret = 0x5E;
  static const int closeBrace = 0x7D;
  static const int closeBracket = 0x5D;
  static const int closeParen = 0x29;
  static const int colon = 0x3A;
  static const int comma = 0x2C;
  static const int dot = 0x2E;
  static const int doubleQuote = 0x22;
  static const int equals = 0x3D;
  static const int exclamation = 0x21;
  static const int greaterThan = 0x3E;
  static const int lessThan = 0x3C;
  static const int minus = 0x2D;
  static const int openBrace = 0x7B;
  static const int openBracket = 0x5B;
  static const int openParen = 0x28;
  static const int percent = 0x25;
  static const int plus = 0x2B;
  static const int question = 0x3F;
  static const int semicolon = 0x3B;
  static const int singleQuote = 0x27;
  static const int slash = 0x2F;
  static const int tilde = 0x7E;
  static const int backspace = 0x08;
  static const int formFeed = 0x0C;
  static const int byteOrderMark = 0xFEFF;
  static const int tab = 0x09;
  static const int verticalTab = 0x0B;
}

/// 1:1: `export interface ParseError`
class ParseError {
  final int error;
  final int offset;
  final int length;
  ParseError(this.error, this.offset, this.length);
}

/// 1:1: `export type NodeType`
class NodeType {
  static const String object = 'object';
  static const String array = 'array';
  static const String property = 'property';
  static const String string = 'string';
  static const String number = 'number';
  static const String boolean = 'boolean';
  static const String nullValue = 'null';
}

/// 1:1: `export interface Node` / `interface NodeImpl`
class Node {
  String type;
  Object? value;
  int offset;
  int length;
  int? colonOffset;
  Node? parent;
  List<Node>? children;

  Node(this.type, this.offset, this.length, {this.value, this.colonOffset, this.parent, this.children});
}

/// 1:1: `export type Segment = string | number` — Dart `Object` (String or int).
typedef Segment = Object;
/// 1:1: `export type JSONPath = Segment[]`
typedef JSONPath = List<Object>;

/// 1:1: `export interface Location`
class Location {
  Node? previousNode;
  List<Object> path;
  bool isAtPropertyKey;
  bool Function(List<Object> patterns) matches;
  Location(this.path, this.isAtPropertyKey, this.matches, {this.previousNode});
}

/// 1:1: `export interface ParseOptions` + `namespace ParseOptions.DEFAULT`
class ParseOptions {
  bool? disallowComments;
  bool? allowTrailingComma;
  bool? allowEmptyContent;
  ParseOptions({this.disallowComments, this.allowTrailingComma, this.allowEmptyContent});

  static final ParseOptions DEFAULT = ParseOptions(allowTrailingComma: true);
}

/// 1:1: `export interface JSONVisitor`
class JSONVisitor {
  void Function(int offset, int length)? onObjectBegin;
  void Function(Object? property, int offset, int length)? onObjectProperty;
  void Function(int offset, int length)? onObjectEnd;
  void Function(int offset, int length)? onArrayBegin;
  void Function(int offset, int length)? onArrayEnd;
  void Function(Object? value, int offset, int length)? onLiteralValue;
  void Function(Object? character, int offset, int length)? onSeparator;
  void Function(int offset, int length)? onComment;
  void Function(Object? error, int offset, int length)? onError;

  JSONVisitor({
    this.onObjectBegin,
    this.onObjectProperty,
    this.onObjectEnd,
    this.onArrayBegin,
    this.onArrayEnd,
    this.onLiteralValue,
    this.onSeparator,
    this.onComment,
    this.onError,
  });
}

/// 1:1: `export interface JSONScanner`
abstract class JSONScanner {
  void setPosition(int pos);
  int scan();
  int getPosition();
  int getToken();
  String getTokenValue();
  int getTokenOffset();
  int getTokenLength();
  int getTokenError();
}

class _JSONScannerImpl implements JSONScanner {
  final String text;
  final bool ignoreTrivia;
  int pos = 0;
  late final int len;
  String value = '';
  int tokenOffset = 0;
  int token = SyntaxKind.unknown;
  int scanError = ScanError.none;

  _JSONScannerImpl(this.text, this.ignoreTrivia) : len = text.length;

  @override
  void setPosition(int newPosition) {
    pos = newPosition;
    value = '';
    tokenOffset = 0;
    token = SyntaxKind.unknown;
    scanError = ScanError.none;
  }

  int _charCodeAt(int i) => (i >= 0 && i < len) ? text.codeUnitAt(i) : -1;

  int _scanHexDigits(int count) {
    int digits = 0;
    int hexValue = 0;
    while (digits < count) {
      final int ch = _charCodeAt(pos);
      if (ch >= CharacterCodes._0 && ch <= CharacterCodes._9) {
        hexValue = hexValue * 16 + ch - CharacterCodes._0;
      } else if (ch >= CharacterCodes.A && ch <= CharacterCodes.F) {
        hexValue = hexValue * 16 + ch - CharacterCodes.A + 10;
      } else if (ch >= CharacterCodes.a && ch <= CharacterCodes.f) {
        hexValue = hexValue * 16 + ch - CharacterCodes.a + 10;
      } else {
        break;
      }
      pos++;
      digits++;
    }
    if (digits < count) hexValue = -1;
    return hexValue;
  }

  String _scanNumber() {
    final int start = pos;
    if (_charCodeAt(pos) == CharacterCodes._0) {
      pos++;
    } else {
      pos++;
      while (pos < len && _isDigit(_charCodeAt(pos))) pos++;
    }
    if (pos < len && _charCodeAt(pos) == CharacterCodes.dot) {
      pos++;
      if (pos < len && _isDigit(_charCodeAt(pos))) {
        pos++;
        while (pos < len && _isDigit(_charCodeAt(pos))) pos++;
      } else {
        scanError = ScanError.unexpectedEndOfNumber;
        return text.substring(start, pos);
      }
    }
    int end = pos;
    if (pos < len && (_charCodeAt(pos) == CharacterCodes.E || _charCodeAt(pos) == CharacterCodes.e)) {
      pos++;
      if (_charCodeAt(pos) == CharacterCodes.plus || _charCodeAt(pos) == CharacterCodes.minus) pos++;
      if (pos < len && _isDigit(_charCodeAt(pos))) {
        pos++;
        while (pos < len && _isDigit(_charCodeAt(pos))) pos++;
        end = pos;
      } else {
        scanError = ScanError.unexpectedEndOfNumber;
      }
    }
    return text.substring(start, end);
  }

  String _scanString() {
    String result = '';
    int start = pos;
    while (true) {
      if (pos >= len) {
        result += text.substring(start, pos);
        scanError = ScanError.unexpectedEndOfString;
        break;
      }
      final int ch = _charCodeAt(pos);
      if (ch == CharacterCodes.doubleQuote) {
        result += text.substring(start, pos);
        pos++;
        break;
      }
      if (ch == CharacterCodes.backslash) {
        result += text.substring(start, pos);
        pos++;
        if (pos >= len) {
          scanError = ScanError.unexpectedEndOfString;
          break;
        }
        final int ch2 = _charCodeAt(pos++);
        switch (ch2) {
          case CharacterCodes.doubleQuote: result += '"'; break;
          case CharacterCodes.backslash: result += '\\'; break;
          case CharacterCodes.slash: result += '/'; break;
          case CharacterCodes.b: result += '\b'; break;
          case CharacterCodes.f: result += '\f'; break;
          case CharacterCodes.n: result += '\n'; break;
          case CharacterCodes.r: result += '\r'; break;
          case CharacterCodes.t: result += '\t'; break;
          case CharacterCodes.u: {
            final int ch3 = _scanHexDigits(4);
            if (ch3 >= 0) {
              result += String.fromCharCode(ch3);
            } else {
              scanError = ScanError.invalidUnicode;
            }
            break;
          }
          default: scanError = ScanError.invalidEscapeCharacter;
        }
        start = pos;
        continue;
      }
      if (ch >= 0 && ch <= 0x1F) {
        if (_isLineBreak(ch)) {
          result += text.substring(start, pos);
          scanError = ScanError.unexpectedEndOfString;
          break;
        } else {
          scanError = ScanError.invalidCharacter;
        }
      }
      pos++;
    }
    return result;
  }

  int _scanNext() {
    value = '';
    scanError = ScanError.none;
    tokenOffset = pos;
    if (pos >= len) {
      tokenOffset = len;
      return token = SyntaxKind.eof;
    }
    int code = _charCodeAt(pos);
    if (_isWhitespace(code)) {
      do {
        pos++;
        value += String.fromCharCode(code);
        code = _charCodeAt(pos);
      } while (_isWhitespace(code));
      return token = SyntaxKind.trivia;
    }
    if (_isLineBreak(code)) {
      pos++;
      value += String.fromCharCode(code);
      if (code == CharacterCodes.carriageReturn && _charCodeAt(pos) == CharacterCodes.lineFeed) {
        pos++;
        value += '\n';
      }
      return token = SyntaxKind.lineBreakTrivia;
    }
    switch (code) {
      case CharacterCodes.openBrace: pos++; return token = SyntaxKind.openBraceToken;
      case CharacterCodes.closeBrace: pos++; return token = SyntaxKind.closeBraceToken;
      case CharacterCodes.openBracket: pos++; return token = SyntaxKind.openBracketToken;
      case CharacterCodes.closeBracket: pos++; return token = SyntaxKind.closeBracketToken;
      case CharacterCodes.colon: pos++; return token = SyntaxKind.colonToken;
      case CharacterCodes.comma: pos++; return token = SyntaxKind.commaToken;
      case CharacterCodes.doubleQuote:
        pos++;
        value = _scanString();
        return token = SyntaxKind.stringLiteral;
      case CharacterCodes.slash: {
        // JS `substring` clamps negative indices to 0; mirror that for Dart.
        final int start = pos - 1 < 0 ? 0 : pos - 1;
        if (_charCodeAt(pos + 1) == CharacterCodes.slash) {
          pos += 2;
          while (pos < len) {
            if (_isLineBreak(_charCodeAt(pos))) break;
            pos++;
          }
          value = text.substring(start, pos);
          return token = SyntaxKind.lineCommentTrivia;
        }
        if (_charCodeAt(pos + 1) == CharacterCodes.asterisk) {
          pos += 2;
          final int safeLength = len - 1;
          bool commentClosed = false;
          while (pos < safeLength) {
            final int ch = _charCodeAt(pos);
            if (ch == CharacterCodes.asterisk && _charCodeAt(pos + 1) == CharacterCodes.slash) {
              pos += 2;
              commentClosed = true;
              break;
            }
            pos++;
          }
          if (!commentClosed) {
            pos++;
            scanError = ScanError.unexpectedEndOfComment;
          }
          value = text.substring(start, pos);
          return token = SyntaxKind.blockCommentTrivia;
        }
        value += String.fromCharCode(code);
        pos++;
        return token = SyntaxKind.unknown;
      }
      case CharacterCodes.minus:
        value += String.fromCharCode(code);
        pos++;
        if (pos == len || !_isDigit(_charCodeAt(pos))) return token = SyntaxKind.unknown;
        // Dart switch does not fall through non-empty cases like C/TS; inline the digit body.
        value += _scanNumber();
        return token = SyntaxKind.numericLiteral;
      case CharacterCodes._0:
      case CharacterCodes._1:
      case CharacterCodes._2:
      case CharacterCodes._3:
      case CharacterCodes._4:
      case CharacterCodes._5:
      case CharacterCodes._6:
      case CharacterCodes._7:
      case CharacterCodes._8:
      case CharacterCodes._9:
        value += _scanNumber();
        return token = SyntaxKind.numericLiteral;
      default:
        while (pos < len && _isUnknownContentCharacter(code)) {
          pos++;
          code = _charCodeAt(pos);
        }
        if (tokenOffset != pos) {
          value = text.substring(tokenOffset, pos);
          switch (value) {
            case 'true': return token = SyntaxKind.trueKeyword;
            case 'false': return token = SyntaxKind.falseKeyword;
            case 'null': return token = SyntaxKind.nullKeyword;
          }
          return token = SyntaxKind.unknown;
        }
        value += String.fromCharCode(code);
        pos++;
        return token = SyntaxKind.unknown;
    }
  }

  int _scanNextNonTrivia() {
    int result;
    do {
      result = _scanNext();
    } while (result >= SyntaxKind.lineCommentTrivia && result <= SyntaxKind.trivia);
    return result;
  }

  @override
  int scan() => ignoreTrivia ? _scanNextNonTrivia() : _scanNext();
  @override
  int getPosition() => pos;
  @override
  int getToken() => token;
  @override
  String getTokenValue() => value;
  @override
  int getTokenOffset() => tokenOffset;
  @override
  int getTokenLength() => pos - tokenOffset;
  @override
  int getTokenError() => scanError;
}

bool _isWhitespace(int ch) =>
    ch == CharacterCodes.space || ch == CharacterCodes.tab || ch == CharacterCodes.verticalTab || ch == CharacterCodes.formFeed ||
    ch == CharacterCodes.nonBreakingSpace || ch == CharacterCodes.ogham || (ch >= CharacterCodes.enQuad && ch <= CharacterCodes.zeroWidthSpace) ||
    ch == CharacterCodes.narrowNoBreakSpace || ch == CharacterCodes.mathematicalSpace || ch == CharacterCodes.ideographicSpace || ch == CharacterCodes.byteOrderMark;

bool _isLineBreak(int ch) => ch == CharacterCodes.lineFeed || ch == CharacterCodes.carriageReturn || ch == CharacterCodes.lineSeparator || ch == CharacterCodes.paragraphSeparator;

bool _isDigit(int ch) => ch >= CharacterCodes._0 && ch <= CharacterCodes._9;

bool _isUnknownContentCharacter(int code) {
  if (_isWhitespace(code) || _isLineBreak(code)) return false;
  switch (code) {
    case CharacterCodes.closeBrace:
    case CharacterCodes.closeBracket:
    case CharacterCodes.openBrace:
    case CharacterCodes.openBracket:
    case CharacterCodes.doubleQuote:
    case CharacterCodes.colon:
    case CharacterCodes.comma:
    case CharacterCodes.slash:
      return false;
  }
  return true;
}

/// 1:1: `export function createScanner(text, ignoreTrivia = false)`
JSONScanner createScanner(String text, [bool ignoreTrivia = false]) => _JSONScannerImpl(text, ignoreTrivia);

/// 1:1: `export function getLocation(text, position)`
Location getLocation(String text, int position) {
  final List<Object> segments = <Object>[];
  final Object earlyReturnException = Object();
  Node? previousNode;
  final Node previousNodeInst = Node(NodeType.object, 0, 0, value: <String, Object?>{}, parent: null);
  bool isAtPropertyKey = false;

  void setPreviousNode(Object? value, int offset, int length, String type) {
    previousNodeInst.value = value;
    previousNodeInst.offset = offset;
    previousNodeInst.length = length;
    previousNodeInst.type = type;
    previousNodeInst.colonOffset = null;
    previousNode = previousNodeInst;
  }

  try {
    visit(text, JSONVisitor(
      onObjectBegin: (int offset, int length) {
        if (position <= offset) throw earlyReturnException;
        previousNode = null;
        isAtPropertyKey = position > offset;
        segments.add('');
      },
      onObjectProperty: (Object? name, int offset, int length) {
        if (position < offset) throw earlyReturnException;
        setPreviousNode(name as String, offset, length, NodeType.property);
        segments[segments.length - 1] = name;
        if (position <= offset + length) throw earlyReturnException;
      },
      onObjectEnd: (int offset, int length) {
        if (position <= offset) throw earlyReturnException;
        previousNode = null;
        segments.removeLast();
      },
      onArrayBegin: (int offset, int length) {
        if (position <= offset) throw earlyReturnException;
        previousNode = null;
        segments.add(0);
      },
      onArrayEnd: (int offset, int length) {
        if (position <= offset) throw earlyReturnException;
        previousNode = null;
        segments.removeLast();
      },
      onLiteralValue: (Object? value, int offset, int length) {
        if (position < offset) throw earlyReturnException;
        setPreviousNode(value, offset, length, getNodeType(value));
        if (position <= offset + length) throw earlyReturnException;
      },
      onSeparator: (Object? sepRaw, int offset, int length) {
        final String sep = sepRaw as String;
        if (position <= offset) throw earlyReturnException;
        if (sep == ':' && previousNode != null && previousNode!.type == NodeType.property) {
          previousNode!.colonOffset = offset;
          isAtPropertyKey = false;
          previousNode = null;
        } else if (sep == ',') {
          final Object last = segments.last;
          if (last is int) {
            segments[segments.length - 1] = last + 1;
          } else {
            isAtPropertyKey = true;
            segments[segments.length - 1] = '';
          }
          previousNode = null;
        }
      },
    ));
  } catch (e) {
    if (!identical(e, earlyReturnException)) rethrow;
  }

  return Location(segments, isAtPropertyKey, (List<Object> pattern) {
    int k = 0;
    for (int i = 0; k < pattern.length && i < segments.length; i++) {
      if (pattern[k] == segments[i] || pattern[k] == '*') {
        k++;
      } else if (pattern[k] != '**') {
        return false;
      }
    }
    return k == pattern.length;
  }, previousNode: previousNode);
}

/// 1:1: `export function setObjectProperty(obj, key, value)`
void setObjectProperty(Map<String, Object?> obj, String key, Object? value) {
  // Dart Maps have no prototype, so `__proto__` is an ordinary own key — matching
  // the source's Object.defineProperty intent without prototype pollution.
  obj[key] = value;
}

/// 1:1: `export function parse(text, errors = [], options = DEFAULT)`
Object? parse(String text, [List<ParseError>? errorsIn, ParseOptions? optionsIn]) {
  final List<ParseError> errors = errorsIn ?? <ParseError>[];
  final ParseOptions options = optionsIn ?? ParseOptions.DEFAULT;
  String? currentProperty;
  Object currentParent = <Object?>[];
  final List<Object> previousParents = <Object>[];

  void onValue(Object? value) {
    if (currentParent is List) {
      final List<Object?> list = currentParent as List<Object?>;
      list.add(value);
    } else if (currentProperty != null) {
      setObjectProperty(currentParent as Map<String, Object?>, currentProperty!, value);
    }
  }

  visit(text, JSONVisitor(
    onObjectBegin: (int offset, int length) {
      final Map<String, Object?> object = <String, Object?>{};
      onValue(object);
      previousParents.add(currentParent);
      currentParent = object;
      currentProperty = null;
    },
    onObjectProperty: (Object? name, int offset, int length) => currentProperty = name as String,
    onObjectEnd: (int offset, int length) => currentParent = previousParents.removeLast(),
    onArrayBegin: (int offset, int length) {
      final List<Object?> array = <Object?>[];
      onValue(array);
      previousParents.add(currentParent);
      currentParent = array;
      currentProperty = null;
    },
    onArrayEnd: (int offset, int length) => currentParent = previousParents.removeLast(),
    onLiteralValue: (Object? value, int offset, int length) => onValue(value),
    onError: (Object? error, int offset, int length) => errors.add(ParseError(error as int, offset, length)),
  ), options);
  return (currentParent as List).isEmpty ? null : (currentParent as List)[0];
}

/// 1:1: `export function parseTree(text, errors = [], options = DEFAULT)`
/// TS returns `Node | undefined` (guarded by `if (result) delete result.parent`).
Node? parseTree(String text, [List<ParseError>? errorsIn, ParseOptions? optionsIn]) {
  final List<ParseError> errors = errorsIn ?? <ParseError>[];
  final ParseOptions options = optionsIn ?? ParseOptions.DEFAULT;
  Node currentParent = Node(NodeType.array, -1, -1, children: <Node>[], parent: null); // artificial root

  void ensurePropertyComplete(int endOffset) {
    if (currentParent.type == NodeType.property) {
      currentParent.length = endOffset - currentParent.offset;
      currentParent = currentParent.parent!;
    }
  }

  Node onValueNode(Node valueNode) {
    currentParent.children!.add(valueNode);
    return valueNode;
  }

  visit(text, JSONVisitor(
    onObjectBegin: (int offset, int length) {
      currentParent = onValueNode(Node(NodeType.object, offset, -1, parent: currentParent, children: <Node>[]));
    },
    onObjectProperty: (Object? name, int offset, int length) {
      currentParent = onValueNode(Node(NodeType.property, offset, -1, parent: currentParent, children: <Node>[]));
      currentParent.children!.add(Node(NodeType.string, offset, length, value: name, parent: currentParent));
    },
    onObjectEnd: (int offset, int length) {
      currentParent.length = offset + length - currentParent.offset;
      currentParent = currentParent.parent!;
      ensurePropertyComplete(offset + length);
    },
    onArrayBegin: (int offset, int length) {
      currentParent = onValueNode(Node(NodeType.array, offset, -1, parent: currentParent, children: <Node>[]));
    },
    onArrayEnd: (int offset, int length) {
      currentParent.length = offset + length - currentParent.offset;
      currentParent = currentParent.parent!;
      ensurePropertyComplete(offset + length);
    },
    onLiteralValue: (Object? value, int offset, int length) {
      onValueNode(Node(getNodeType(value), offset, length, parent: currentParent, value: value));
      ensurePropertyComplete(offset + length);
    },
    onSeparator: (Object? sepRaw, int offset, int length) {
      final String sep = sepRaw as String;
      if (currentParent.type == NodeType.property) {
        if (sep == ':') {
          currentParent.colonOffset = offset;
        } else if (sep == ',') {
          ensurePropertyComplete(offset);
        }
      }
    },
    onError: (Object? error, int offset, int length) => errors.add(ParseError(error as int, offset, length)),
  ), options);

  final Node? result = currentParent.children!.isEmpty ? null : currentParent.children![0];
  if (result != null) {
    result.parent = null; // source: `if (result) { delete result.parent; }`
  }
  return result;
}

/// 1:1: `export function findNodeAtLocation(root, path)`
Node? findNodeAtLocation(Node? root, JSONPath path) {
  if (root == null) return null;
  Node node = root;
  for (final Object segment in path) {
    if (segment is String) {
      if (node.type != NodeType.object || node.children == null) return null;
      bool found = false;
      for (final Node propertyNode in node.children!) {
        if (propertyNode.children != null && propertyNode.children![0].value == segment) {
          node = propertyNode.children![1];
          found = true;
          break;
        }
      }
      if (!found) return null;
    } else {
      final int index = segment as int;
      if (node.type != NodeType.array || index < 0 || node.children == null || index >= node.children!.length) return null;
      node = node.children![index];
    }
  }
  return node;
}

/// 1:1: `export function getNodePath(node)`
JSONPath getNodePath(Node node) {
  if (node.parent == null || node.parent!.children == null) return <Object>[];
  final JSONPath path = getNodePath(node.parent!);
  if (node.parent!.type == NodeType.property) {
    path.add(node.parent!.children![0].value as Object);
  } else if (node.parent!.type == NodeType.array) {
    final int index = node.parent!.children!.indexOf(node);
    if (index != -1) path.add(index);
  }
  return path;
}

/// 1:1: `export function getNodeValue(node)`
Object? getNodeValue(Node node) {
  switch (node.type) {
    case NodeType.array:
      return node.children!.map((Node n) => getNodeValue(n)).toList();
    case NodeType.object: {
      final Map<String, Object?> obj = <String, Object?>{};
      for (final Node prop in node.children!) {
        final Node valueNode = prop.children![1];
        obj[prop.children![0].value as String] = getNodeValue(valueNode);
      }
      return obj;
    }
    case NodeType.nullValue:
    case NodeType.string:
    case NodeType.number:
    case NodeType.boolean:
      return node.value;
    default:
      return null;
  }
}

/// 1:1: `export function contains(node, offset, includeRightBound = false)`
bool contains(Node node, int offset, [bool includeRightBound = false]) =>
    (offset >= node.offset && offset < (node.offset + node.length)) || (includeRightBound && (offset == (node.offset + node.length)));

/// 1:1: `export function findNodeAtOffset(node, offset, includeRightBound = false)`
Node? findNodeAtOffset(Node node, int offset, [bool includeRightBound = false]) {
  if (contains(node, offset, includeRightBound)) {
    final List<Node>? children = node.children;
    if (children != null) {
      for (int i = 0; i < children.length && children[i].offset <= offset; i++) {
        final Node? item = findNodeAtOffset(children[i], offset, includeRightBound);
        if (item != null) return item;
      }
    }
    return node;
  }
  return null;
}

/// 1:1: `export function visit(text, visitor, options = DEFAULT)`
bool visit(String text, JSONVisitor visitor, [ParseOptions? optionsIn]) {
  final ParseOptions options = optionsIn ?? ParseOptions.DEFAULT;
  final JSONScanner scanner = createScanner(text, false);

  void Function(int, int)? noArg(void Function(int, int)? f) =>
      f == null ? null : (int offset, int length) => f(offset, length);
  void Function(Object?, int, int)? oneArg(void Function(Object?, int, int)? f) =>
      f == null ? null : (Object? arg, int offset, int length) => f(arg, offset, length);

  final void Function(int, int)? onObjectBegin = noArg(visitor.onObjectBegin);
  final void Function(Object?, int, int)? onObjectProperty = oneArg(visitor.onObjectProperty);
  final void Function(int, int)? onObjectEnd = noArg(visitor.onObjectEnd);
  final void Function(int, int)? onArrayBegin = noArg(visitor.onArrayBegin);
  final void Function(int, int)? onArrayEnd = noArg(visitor.onArrayEnd);
  final void Function(Object?, int, int)? onLiteralValue = oneArg(visitor.onLiteralValue);
  final void Function(Object?, int, int)? onSeparatorRaw = oneArg(visitor.onSeparator);
  final void Function(int, int)? onComment = noArg(visitor.onComment);
  final void Function(Object?, int, int)? onErrorRaw = oneArg(visitor.onError);

  void onSeparator(String s) => onSeparatorRaw?.call(s, scanner.getTokenOffset(), scanner.getTokenLength());
  void onError(int e) => onErrorRaw?.call(e, scanner.getTokenOffset(), scanner.getTokenLength());
  void callNoArg(void Function(int, int)? f) => f?.call(scanner.getTokenOffset(), scanner.getTokenLength());
  void callOneArg(void Function(Object?, int, int)? f, Object? v) => f?.call(v, scanner.getTokenOffset(), scanner.getTokenLength());

  final bool disallowComments = options.disallowComments ?? false;
  final bool allowTrailingComma = options.allowTrailingComma ?? false;

  late final void Function(int, [List<int>, List<int>]) handleError;
  late final bool Function() parseValue;

  int scanNext() {
    while (true) {
      final int token = scanner.scan();
      switch (scanner.getTokenError()) {
        case ScanError.invalidUnicode: handleError(ParseErrorCode.invalidUnicode); break;
        case ScanError.invalidEscapeCharacter: handleError(ParseErrorCode.invalidEscapeCharacter); break;
        case ScanError.unexpectedEndOfNumber: handleError(ParseErrorCode.unexpectedEndOfNumber); break;
        case ScanError.unexpectedEndOfComment:
          if (!disallowComments) handleError(ParseErrorCode.unexpectedEndOfComment);
          break;
        case ScanError.unexpectedEndOfString: handleError(ParseErrorCode.unexpectedEndOfString); break;
        case ScanError.invalidCharacter: handleError(ParseErrorCode.invalidCharacter); break;
      }
      switch (token) {
        case SyntaxKind.lineCommentTrivia:
        case SyntaxKind.blockCommentTrivia:
          if (disallowComments) {
            handleError(ParseErrorCode.invalidCommentToken);
          } else {
            callNoArg(onComment);
          }
          break;
        case SyntaxKind.unknown: handleError(ParseErrorCode.invalidSymbol); break;
        case SyntaxKind.trivia:
        case SyntaxKind.lineBreakTrivia: break;
        default: return token;
      }
    }
  }

  handleError = (int error, [List<int> skipUntilAfter = const <int>[], List<int> skipUntil = const <int>[]]) {
    onError(error);
    if (skipUntilAfter.length + skipUntil.length > 0) {
      int token = scanner.getToken();
      while (token != SyntaxKind.eof) {
        if (skipUntilAfter.contains(token)) {
          scanNext();
          break;
        } else if (skipUntil.contains(token)) {
          break;
        }
        token = scanNext();
      }
    }
  };

  bool parseString(bool isValue) {
    final String value = scanner.getTokenValue();
    if (isValue) {
      callOneArg(onLiteralValue, value);
    } else {
      callOneArg(onObjectProperty, value);
    }
    scanNext();
    return true;
  }

  bool parseLiteral() {
    switch (scanner.getToken()) {
      case SyntaxKind.numericLiteral: {
        Object value = 0;
        try {
          final String s = scanner.getTokenValue();
          value = s.contains('.') || s.contains('e') || s.contains('E') ? double.parse(s) : int.parse(s);
          // JSON.parse always yields a number for a numeric literal token.
        } catch (_) {
          handleError(ParseErrorCode.invalidNumberFormat);
        }
        callOneArg(onLiteralValue, value);
        break;
      }
      case SyntaxKind.nullKeyword: callOneArg(onLiteralValue, null); break;
      case SyntaxKind.trueKeyword: callOneArg(onLiteralValue, true); break;
      case SyntaxKind.falseKeyword: callOneArg(onLiteralValue, false); break;
      default: return false;
    }
    scanNext();
    return true;
  }

  bool parseProperty() {
    if (scanner.getToken() != SyntaxKind.stringLiteral) {
      handleError(ParseErrorCode.propertyNameExpected, const <int>[], <int>[SyntaxKind.closeBraceToken, SyntaxKind.commaToken]);
      return false;
    }
    parseString(false);
    if (scanner.getToken() == SyntaxKind.colonToken) {
      onSeparator(':');
      scanNext();
      if (!parseValue()) {
        handleError(ParseErrorCode.valueExpected, const <int>[], <int>[SyntaxKind.closeBraceToken, SyntaxKind.commaToken]);
      }
    } else {
      handleError(ParseErrorCode.colonExpected, const <int>[], <int>[SyntaxKind.closeBraceToken, SyntaxKind.commaToken]);
    }
    return true;
  }

  bool parseObject() {
    callNoArg(onObjectBegin);
    scanNext();
    bool needsComma = false;
    while (scanner.getToken() != SyntaxKind.closeBraceToken && scanner.getToken() != SyntaxKind.eof) {
      if (scanner.getToken() == SyntaxKind.commaToken) {
        if (!needsComma) handleError(ParseErrorCode.valueExpected, const <int>[], const <int>[]);
        onSeparator(',');
        scanNext();
        if (scanner.getToken() == SyntaxKind.closeBraceToken && allowTrailingComma) break;
      } else if (needsComma) {
        handleError(ParseErrorCode.commaExpected, const <int>[], const <int>[]);
      }
      if (!parseProperty()) {
        handleError(ParseErrorCode.valueExpected, const <int>[], <int>[SyntaxKind.closeBraceToken, SyntaxKind.commaToken]);
      }
      needsComma = true;
    }
    callNoArg(onObjectEnd);
    if (scanner.getToken() != SyntaxKind.closeBraceToken) {
      handleError(ParseErrorCode.closeBraceExpected, <int>[SyntaxKind.closeBraceToken], const <int>[]);
    } else {
      scanNext();
    }
    return true;
  }

  bool parseArray() {
    callNoArg(onArrayBegin);
    scanNext();
    bool needsComma = false;
    while (scanner.getToken() != SyntaxKind.closeBracketToken && scanner.getToken() != SyntaxKind.eof) {
      if (scanner.getToken() == SyntaxKind.commaToken) {
        if (!needsComma) handleError(ParseErrorCode.valueExpected, const <int>[], const <int>[]);
        onSeparator(',');
        scanNext();
        if (scanner.getToken() == SyntaxKind.closeBracketToken && allowTrailingComma) break;
      } else if (needsComma) {
        handleError(ParseErrorCode.commaExpected, const <int>[], const <int>[]);
      }
      if (!parseValue()) {
        handleError(ParseErrorCode.valueExpected, const <int>[], <int>[SyntaxKind.closeBracketToken, SyntaxKind.commaToken]);
      }
      needsComma = true;
    }
    callNoArg(onArrayEnd);
    if (scanner.getToken() != SyntaxKind.closeBracketToken) {
      handleError(ParseErrorCode.closeBracketExpected, <int>[SyntaxKind.closeBracketToken], const <int>[]);
    } else {
      scanNext();
    }
    return true;
  }

  parseValue = () {
    switch (scanner.getToken()) {
      case SyntaxKind.openBracketToken: return parseArray();
      case SyntaxKind.openBraceToken: return parseObject();
      case SyntaxKind.stringLiteral: return parseString(true);
      default: return parseLiteral();
    }
  };

  scanNext();
  if (scanner.getToken() == SyntaxKind.eof) {
    if (options.allowEmptyContent == true) return true;
    handleError(ParseErrorCode.valueExpected, const <int>[], const <int>[]);
    return false;
  }
  if (!parseValue()) {
    handleError(ParseErrorCode.valueExpected, const <int>[], const <int>[]);
    return false;
  }
  if (scanner.getToken() != SyntaxKind.eof) {
    handleError(ParseErrorCode.endOfFileExpected, const <int>[], const <int>[]);
  }
  return true;
}

/// 1:1: `export function getNodeType(value)`
String getNodeType(Object? value) {
  if (value is bool) return NodeType.boolean;
  if (value is num) return NodeType.number;
  if (value is String) return NodeType.string;
  if (value == null) return NodeType.nullValue;
  if (value is List) return NodeType.array;
  if (value is Map) return NodeType.object;
  return NodeType.nullValue;
}

