/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

// 1:1 翻译自 vscode/src/vs/editor/contrib/snippet/browser/snippetParser.ts
// 关键 JS 语义适配：
//  - const enum TokenType -> class static const int
//  - JS RegExp（.source/.global/.ignoreCase + replace 回调）-> JsRegExp carrier
//  - if (value = _accept(...)) 赋值表达式 -> 局部提升
//  - toLocaleUpperCase/LowerCase -> toUpperCase/toLowerCase（Dart 无 locale 参数，语义对齐）

import '../../../../base/common/charCode.dart';

/// 1:1: `export const enum TokenType`
class TokenType {
  static const int Dollar = 0;
  static const int Colon = 1;
  static const int Comma = 2;
  static const int CurlyOpen = 3;
  static const int CurlyClose = 4;
  static const int Backslash = 5;
  static const int Forwardslash = 6;
  static const int Pipe = 7;
  static const int Int = 8;
  static const int VariableName = 9;
  static const int Format = 10;
  static const int Plus = 11;
  static const int Dash = 12;
  static const int QuestionMark = 13;
  static const int EOF = 14;
}

/// 1:1: `export interface Token`
class Token {
  int type;
  final int pos;
  final int len;
  Token(this.type, this.pos, this.len);
}

/// 1:1: `export class Scanner`
class Scanner {
  static final Map<int, int> _table = <int, int>{
    CharCode.DollarSign: TokenType.Dollar,
    CharCode.Colon: TokenType.Colon,
    CharCode.Comma: TokenType.Comma,
    CharCode.OpenCurlyBrace: TokenType.CurlyOpen,
    CharCode.CloseCurlyBrace: TokenType.CurlyClose,
    CharCode.Backslash: TokenType.Backslash,
    CharCode.Slash: TokenType.Forwardslash,
    CharCode.Pipe: TokenType.Pipe,
    CharCode.Plus: TokenType.Plus,
    CharCode.Dash: TokenType.Dash,
    CharCode.QuestionMark: TokenType.QuestionMark,
  };

  static bool isDigitCharacter(int ch) =>
      ch >= CharCode.Digit0 && ch <= CharCode.Digit9;

  static bool isVariableCharacter(int ch) =>
      ch == CharCode.Underline ||
      (ch >= CharCode.a && ch <= CharCode.z) ||
      (ch >= CharCode.A && ch <= CharCode.Z);

  String value = '';
  int pos = 0;

  void text(String value) {
    this.value = value;
    pos = 0;
  }

  /// 1:1: `tokenText(token)` — JS `substr`
  String tokenText(Token token) =>
      value.substring(token.pos, token.pos + token.len);

  /// JS `String.charCodeAt(i)` 越界返回 NaN；Dart 用 -1 哨兵（不等于任何
  /// digit/variable/static table 项，format 循环的 isNaN 语义由下方保护）。
  int _charCodeAt(int i) => (i >= 0 && i < value.length) ? value.codeUnitAt(i) : -1;

  /// 1:1: `next()`
  Token next() {
    if (pos >= value.length) {
      return Token(TokenType.EOF, pos, 0);
    }

    final int startPos = pos;
    int len = 0;
    int ch = _charCodeAt(startPos);
    int type;

    // static types
    type = _table[ch] ?? -1;
    if (type != -1) {
      pos += 1;
      return Token(type, startPos, 1);
    }

    // number
    if (isDigitCharacter(ch)) {
      type = TokenType.Int;
      do {
        len += 1;
        ch = _charCodeAt(startPos + len);
      } while (isDigitCharacter(ch));
      pos += len;
      return Token(type, startPos, len);
    }

    // variable name
    if (isVariableCharacter(ch)) {
      type = TokenType.VariableName;
      do {
        ch = _charCodeAt(startPos + (++len));
      } while (isVariableCharacter(ch) || isDigitCharacter(ch));
      pos += len;
      return Token(type, startPos, len);
    }

    // format
    type = TokenType.Format;
    do {
      len += 1;
      ch = _charCodeAt(startPos + len);
    } while (
        // JS `!isNaN(ch)` — codeUnitAt is always a valid number within bounds;
        // at EOF charCodeAt returns NaN. We detect EOF via pos+len >= length.
        (startPos + len) < value.length &&
        _table[ch] == null &&
        !isDigitCharacter(ch) &&
        !isVariableCharacter(ch));
    pos += len;
    return Token(type, startPos, len);
  }
}

/// 1:1: `export abstract class Marker`
abstract class Marker {
  List<Marker> _children = <Marker>[];
  Marker? parent;

  Marker appendChild(Marker child) {
    if (child is Text && _children.isNotEmpty && _children.last is Text) {
      // this and previous child are text -> merge them
      (_children.last as Text).value += child.value;
    } else {
      // normal adoption of child
      child.parent = this;
      _children.add(child);
    }
    return this;
  }

  void replace(Marker child, List<Marker> others) {
    final Marker? parent = child.parent;
    if (parent == null) {
      throw StateError('Marker.replace: child has no parent');
    }
    final int idx = parent.children.indexOf(child);
    final List<Marker> newChildren = List<Marker>.from(parent.children);
    newChildren.removeRange(idx, idx + 1);
    newChildren.insertAll(idx, others);
    parent._children = newChildren;

    void fixParent(List<Marker> children, Marker parent) {
      for (final Marker child in children) {
        child.parent = parent;
        fixParent(child.children, child);
      }
    }

    fixParent(others, parent);
  }

  List<Marker> get children => _children;

  Marker get rightMostDescendant {
    if (_children.isNotEmpty) {
      return _children.last.rightMostDescendant;
    }
    return this;
  }

  TextmateSnippet? get snippet {
    Marker? candidate = this;
    while (true) {
      if (candidate == null) {
        return null;
      }
      if (candidate is TextmateSnippet) {
        return candidate;
      }
      candidate = candidate.parent;
    }
  }

  @override
  String toString() =>
      children.map((c) => c.toString()).fold('', (prev, cur) => prev + cur);

  String toTextmateString();

  int len() => 0;

  Marker clone();
}

/// 1:1: `export class Text`
class Text extends Marker {
  String value;
  static String escape(String value) =>
      value.replaceAllMapped(RegExp(r'\$|}|\\'), (m) => '\\${m.group(0)}');

  Text(this.value);

  @override
  String toString() => value;

  @override
  String toTextmateString() => Text.escape(value);

  @override
  int len() => value.length;

  @override
  Text clone() => Text(value);
}

/// 1:1: `export abstract class TransformableMarker`
abstract class TransformableMarker extends Marker {
  Transform? transform;
}

/// 1:1: `export class Placeholder`
class Placeholder extends TransformableMarker {
  static int compareByIndex(Placeholder a, Placeholder b) {
    if (a.index == b.index) {
      return 0;
    } else if (a.isFinalTabstop) {
      return 1;
    } else if (b.isFinalTabstop) {
      return -1;
    } else if (a.index < b.index) {
      return -1;
    } else if (a.index > b.index) {
      return 1;
    } else {
      return 0;
    }
  }

  final int index;
  Placeholder(this.index);

  bool get isFinalTabstop => index == 0;

  Choice? get choice => children.length == 1 && children[0] is Choice
      ? children[0] as Choice
      : null;

  @override
  String toTextmateString() {
    String transformString = '';
    final Transform? transform = this.transform;
    if (transform != null) {
      transformString = transform.toTextmateString();
    }
    if (children.isEmpty && transform == null) {
      return '\$$index';
    } else if (children.isEmpty) {
      return '\${$index$transformString}';
    } else if (choice != null) {
      return '\${$index|${choice!.toTextmateString()}|$transformString}';
    } else {
      return '\${$index:${children.map((c) => c.toTextmateString()).join('')}$transformString}';
    }
  }

  @override
  Placeholder clone() {
    final Placeholder ret = Placeholder(index);
    final Transform? transform = this.transform;
    if (transform != null) {
      ret.transform = transform.clone();
    }
    ret._children = children.map((c) => c.clone()).toList();
    return ret;
  }
}

/// 1:1: `export class Choice`
class Choice extends Marker {
  final List<Text> options = <Text>[];

  @override
  Marker appendChild(Marker marker) {
    if (marker is Text) {
      marker.parent = this;
      options.add(marker);
    }
    return this;
  }

  @override
  String toString() => options[0].value;

  @override
  String toTextmateString() => options
      .map((option) => option.value.replaceAllMapped(RegExp(r'\||,|\\'), (m) => '\\${m.group(0)}'))
      .join(',');

  @override
  int len() => options[0].len();

  @override
  Choice clone() {
    final Choice ret = Choice();
    for (final Text option in options) {
      ret.appendChild(option.clone());
    }
    return ret;
  }
}

/// 1:1: JS RegExp 承载：保存 source/flags 并提供 `replace(value, replacer)` 语义。
/// 源码 `regexp: RegExp = new RegExp('')` 且可读写 `.source/.global/.ignoreCase`。
class JsRegExp {
  String _source;
  bool global;
  bool ignoreCase;
  RegExp? _compiled;

  JsRegExp(this._source, {this.global = false, this.ignoreCase = false});

  static JsRegExp empty() => JsRegExp('');

  /// 1:1: `new RegExp(regexValue, regexOptions)`；无效正则返回 null（源码 catch）
  static JsRegExp? compile(String source, String options) {
    // 1:1: JS RegExp flag validation — only [dgimsuvy] are legal, and each at
    // most once. `new RegExp('x','GMI')` / `'funky'` throw, which the source
    // catches and treats as "invalid regexp" (whole placeholder becomes text).
    // Dart's RegExp ignores unknown flags, so validate explicitly here.
    const String legalFlags = 'dgimsuvy';
    final Set<String> seen = <String>{};
    for (int k = 0; k < options.length; k++) {
      final String f = options[k];
      if (!legalFlags.contains(f) || !seen.add(f)) {
        return null;
      }
    }
    bool g = false, i = false;
    for (int k = 0; k < options.length; k++) {
      final String f = options[k];
      if (f == 'g') g = true;
      if (f == 'i') i = true;
    }
    try {
      // 1:1: JS flags 顺序无关；Dart caseSensitive 与 ignoreCase 相反
      final RegExp re = RegExp(source, caseSensitive: !i);
      return JsRegExp(source, global: g, ignoreCase: i).._compiled = re;
    } catch (_) {
      return null;
    }
  }

  String get source => _source;

  RegExp get regexp =>
      _compiled ??= RegExp(_source, caseSensitive: !ignoreCase);

  /// 1:1: `value.replace(this.regexp, fn)` — fn 收到 groups=[match,p1,p2,...]
  /// 返回 (result, didMatch)。非 global 只替换首处。
  (String, bool) replaceWithGroups(
      String value, String Function(List<String> groups) replacer) {
    final RegExp re = regexp;
    bool didMatch = false;
    final Iterable<Match> matches =
        global ? re.allMatches(value) : () {
          final Match? m = re.firstMatch(value);
          return m == null ? <Match>[] : <Match>[m];
        }();

    final StringBuffer out = StringBuffer();
    int lastEnd = 0;
    for (final Match m in matches) {
      didMatch = true;
      final List<String> groups = <String>[];
      for (int g = 0; g <= m.groupCount; g++) {
        groups.add(m.group(g) ?? '');
      }
      out.write(value.substring(lastEnd, m.start));
      out.write(replacer(groups));
      lastEnd = m.end;
      // 1:1: 非 global 只替换首处；global 的零宽匹配需要推进（近似：跳过）
      if (!global) break;
      if (m.start == m.end && m.end < value.length) {
        out.write(value[m.end]);
        lastEnd = m.end + 1;
      }
    }
    out.write(value.substring(lastEnd));
    return (out.toString(), didMatch);
  }

  /// 1:1: clone: `new RegExp(this.regexp.source, flags)`
  JsRegExp cloneRegExp() {
    return JsRegExp(_source, global: global, ignoreCase: ignoreCase)
      .._compiled = RegExp(_source, caseSensitive: !ignoreCase);
  }
}

/// 1:1: `export class Transform`
class Transform extends Marker {
  JsRegExp regexp = JsRegExp.empty();

  /// 1:1: `resolve(value)`
  String resolve(String value) {
    bool didMatch = false;
    final String ret = regexp.replaceWithGroups(value, (List<String> groups) {
      didMatch = true;
      return _replace(groups);
    }).$1;
    // when the regex didn't match and when the transform has
    // else branches, then run those
    if (!didMatch &&
        _children.any((child) =>
            child is FormatString &&
            (child.elseValue != null && child.elseValue!.isNotEmpty))) {
      return _replace(<String>[]);
    }
    return ret;
  }

  /// 1:1: `_replace(groups)`
  String _replace(List<String> groups) {
    String ret = '';
    for (final Marker marker in _children) {
      if (marker is FormatString) {
        String value = marker.index < groups.length ? groups[marker.index] : '';
        value = marker.resolve(value);
        ret += value;
      } else {
        ret += marker.toString();
      }
    }
    return ret;
  }

  @override
  String toString() => '';

  @override
  String toTextmateString() =>
      '/${regexp.source}/${children.map((c) => c.toTextmateString()).join('')}/${(regexp.ignoreCase ? 'i' : '') + (regexp.global ? 'g' : '')}';

  @override
  Transform clone() {
    final Transform ret = Transform();
    ret.regexp = regexp.cloneRegExp();
    ret._children = children.map((c) => c.clone()).toList();
    return ret;
  }
}

/// 1:1: `export class FormatString`
class FormatString extends Marker {
  final int index;
  final String? shorthandName;
  final String? ifValue;
  final String? elseValue;

  FormatString(this.index, [this.shorthandName, this.ifValue, this.elseValue]);

  /// 1:1: `resolve(value?)`
  String resolve([String? value]) {
    if (shorthandName == 'upcase') {
      return (value == null || value.isEmpty) ? '' : value.toUpperCase();
    } else if (shorthandName == 'downcase') {
      return (value == null || value.isEmpty) ? '' : value.toLowerCase();
    } else if (shorthandName == 'capitalize') {
      return (value == null || value.isEmpty)
          ? ''
          : (value[0].toUpperCase() + value.substring(1));
    } else if (shorthandName == 'pascalcase') {
      return (value == null || value.isEmpty) ? '' : _toPascalCase(value);
    } else if (shorthandName == 'camelcase') {
      return (value == null || value.isEmpty) ? '' : _toCamelCase(value);
    } else if (shorthandName == 'kebabcase') {
      return (value == null || value.isEmpty) ? '' : _toKebabCase(value);
    } else if (shorthandName == 'snakecase') {
      return (value == null || value.isEmpty) ? '' : _toSnakeCase(value);
    } else if ((value != null && value.isNotEmpty) && ifValue != null) {
      return ifValue!;
    } else if (!(value != null && value.isNotEmpty) && elseValue != null) {
      return elseValue!;
    } else {
      return value ?? '';
    }
  }

  /// 1:1: `_toKebabCase(value)` — Unicode property escapes (unicode: true)
  String _toKebabCase(String value) {
    final RegExp words = RegExp(r'[\p{L}0-9]+', unicode: true);
    final Iterable<Match> match = words.allMatches(value);
    if (match.isEmpty) {
      return value;
    }

    if (!RegExp(r'[\p{L}0-9]', unicode: true).hasMatch(value)) {
      return value
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'^_+|_+$'), '')
          .replaceAll(RegExp(r'[\s_]+'), '-');
    }

    final String cleaned = value.trim().replaceAll(RegExp(r'^_+|_+$'), '');

    final Iterable<Match> match2 = RegExp(
            r'\p{Lu}{2,}(?=\p{Lu}\p{Ll}+[0-9]*|[\s_-]|$)|\p{Lu}?\p{Ll}+[0-9]*|\p{Lu}(?=\p{Lu}\p{Ll})|\p{Lu}(?=[\s_-]|$)|[0-9]+',
            unicode: true)
        .allMatches(cleaned);

    if (match2.isEmpty) {
      return cleaned
          .split(RegExp(r'[\s_-]+'))
          .where((word) => word.isNotEmpty)
          .map((word) => word.toLowerCase())
          .join('-');
    }

    return match2.map((m) => m.group(0)!.toLowerCase()).join('-');
  }

  /// 1:1: `_toPascalCase(value)`
  String _toPascalCase(String value) {
    final Iterable<Match> match =
        RegExp(r'[\p{L}0-9]+', unicode: true).allMatches(value);
    if (match.isEmpty) {
      return value;
    }
    return match.map((m) {
      final String word = m.group(0)!;
      return word[0].toUpperCase() + word.substring(1);
    }).join('');
  }

  /// 1:1: `_toCamelCase(value)`
  String _toCamelCase(String value) {
    final Iterable<Match> match =
        RegExp(r'[\p{L}0-9]+', unicode: true).allMatches(value);
    if (match.isEmpty) {
      return value;
    }
    int idx = 0;
    return match.map((m) {
      final String word = m.group(0)!;
      if (idx++ == 0) {
        return word[0].toLowerCase() + word.substring(1);
      }
      return word[0].toUpperCase() + word.substring(1);
    }).join('');
  }

  /// 1:1: `_toSnakeCase(value)`
  String _toSnakeCase(String value) => value
      .replaceAllMapped(RegExp(r'(\p{Ll})(\p{Lu})', unicode: true),
          (m) => '${m.group(1)}_${m.group(2)}')
      .replaceAll(RegExp(r'[\s\-]+'), '_')
      .toLowerCase();

  @override
  String toTextmateString() {
    String value = r'${';
    value += index.toString();
    if (shorthandName != null) {
      value += ':/$shorthandName';
    } else if (ifValue != null && elseValue != null) {
      value += ':?$ifValue:$elseValue';
    } else if (ifValue != null) {
      value += ':+$ifValue';
    } else if (elseValue != null) {
      value += ':-$elseValue';
    }
    value += '}';
    return value;
  }

  @override
  FormatString clone() =>
      FormatString(index, shorthandName, ifValue, elseValue);
}

/// 1:1: `export class Variable`
class Variable extends TransformableMarker {
  String name;
  Variable(this.name);

  /// 1:1: `resolve(resolver)`
  bool resolve(VariableResolver resolver) {
    String? value = resolver.resolve(this);
    final Transform? transform = this.transform;
    if (transform != null) {
      value = transform.resolve(value ?? '');
    }
    if (value != null) {
      _children = <Marker>[Text(value)];
      return true;
    }
    return false;
  }

  @override
  String toTextmateString() {
    String transformString = '';
    final Transform? transform = this.transform;
    if (transform != null) {
      transformString = transform.toTextmateString();
    }
    if (children.isEmpty) {
      return '\${$name$transformString}';
    } else {
      return '\${$name:${children.map((c) => c.toTextmateString()).join('')}$transformString}';
    }
  }

  @override
  Variable clone() {
    final Variable ret = Variable(name);
    final Transform? transform = this.transform;
    if (transform != null) {
      ret.transform = transform.clone();
    }
    ret._children = children.map((c) => c.clone()).toList();
    return ret;
  }
}

/// 1:1: `export interface VariableResolver`
abstract class VariableResolver {
  String? resolve(Variable variable);
}

/// 1:1: `function walk(marker, visitor)`
void walk(List<Marker> marker, bool Function(Marker) visitor) {
  final List<Marker> stack = List<Marker>.from(marker);
  while (stack.isNotEmpty) {
    final Marker marker = stack.removeAt(0);
    final bool recurse = visitor(marker);
    if (!recurse) {
      break;
    }
    stack.insertAll(0, marker.children);
  }
}

/// 1:1: `export class TextmateSnippet`
class TextmateSnippet extends Marker {
  ({List<Placeholder> all, Placeholder? last})? _placeholders;

  ({List<Placeholder> all, Placeholder? last}) get placeholderInfo {
    final cache = _placeholders;
    if (cache == null) {
      // fill in placeholders
      final List<Placeholder> all = <Placeholder>[];
      Placeholder? last;
      walkMine((Marker candidate) {
        if (candidate is Placeholder) {
          all.add(candidate);
          last = (last == null || last!.index < candidate.index)
              ? candidate
              : last;
        }
        return true;
      });
      final result = (all: all, last: last);
      _placeholders = result;
      return result;
    }
    return cache;
  }

  List<Placeholder> get placeholders => placeholderInfo.all;

  /// 1:1: `offset(marker)`
  int offset(Marker marker) {
    int pos = 0;
    bool found = false;
    walkMine((Marker candidate) {
      if (candidate == marker) {
        found = true;
        return false;
      }
      pos += candidate.len();
      return true;
    });
    if (!found) {
      return -1;
    }
    return pos;
  }

  /// 1:1: `fullLen(marker)`
  int fullLen(Marker marker) {
    int ret = 0;
    walk(<Marker>[marker], (Marker marker) {
      ret += marker.len();
      return true;
    });
    return ret;
  }

  /// 1:1: `enclosingPlaceholders(placeholder)`
  List<Placeholder> enclosingPlaceholders(Placeholder placeholder) {
    final List<Placeholder> ret = <Placeholder>[];
    Marker? parent = placeholder.parent;
    while (parent != null) {
      if (parent is Placeholder) {
        ret.add(parent);
      }
      parent = parent.parent;
    }
    return ret;
  }

  /// 1:1: `resolveVariables(resolver)`
  TextmateSnippet resolveVariables(VariableResolver resolver) {
    walkMine((Marker candidate) {
      if (candidate is Variable) {
        if (candidate.resolve(resolver)) {
          _placeholders = null;
        }
      }
      return true;
    });
    return this;
  }

  @override
  Marker appendChild(Marker child) {
    _placeholders = null;
    return super.appendChild(child);
  }

  @override
  void replace(Marker child, List<Marker> others) {
    _placeholders = null;
    super.replace(child, others);
  }

  @override
  String toTextmateString() =>
      children.map((c) => c.toTextmateString()).fold('', (p, c) => p + c);

  @override
  TextmateSnippet clone() {
    final TextmateSnippet ret = TextmateSnippet();
    ret._children = children.map((c) => c.clone()).toList();
    return ret;
  }

  /// 1:1: `walk(visitor)`
  void walkMine(bool Function(Marker) visitor) => walk(children, visitor);
}

/// 1:1: `export class SnippetParser`
class SnippetParser {
  static String escape(String value) =>
      value.replaceAllMapped(RegExp(r'\$|}|\\'), (m) => '\\${m.group(0)}');

  /// 1:1: `static asInsertText(value)`
  static String asInsertText(String value) =>
      SnippetParser().parse(value).toString();

  /// 1:1: `static guessNeedsClipboard(template)`
  static bool guessNeedsClipboard(String template) =>
      RegExp(r'\${?CLIPBOARD').hasMatch(template);

  final Scanner _scanner = Scanner();
  Token _token = Token(TokenType.EOF, 0, 0);

  /// 1:1: `parse(value, insertFinalTabstop?, enforceFinalTabstop?)`
  TextmateSnippet parse(String value,
      [bool? insertFinalTabstop, bool? enforceFinalTabstop]) {
    final TextmateSnippet snippet = TextmateSnippet();
    parseFragment(value, snippet);
    ensureFinalTabstop(snippet, enforceFinalTabstop ?? false,
        insertFinalTabstop ?? false);
    return snippet;
  }

  /// 1:1: `parseFragment(value, snippet)`
  List<Marker> parseFragment(String value, TextmateSnippet snippet) {
    final int offset = snippet.children.length;
    _scanner.text(value);
    _token = _scanner.next();
    while (_parse(snippet)) {
      // nothing
    }

    // fill in values for placeholders
    final Map<int, List<Marker>?> placeholderDefaultValues =
        <int, List<Marker>?>{};
    final List<Placeholder> incompletePlaceholders = <Placeholder>[];
    snippet.walkMine((Marker marker) {
      if (marker is Placeholder) {
        if (marker.isFinalTabstop) {
          placeholderDefaultValues[0] = null;
        } else if (!placeholderDefaultValues.containsKey(marker.index) &&
            marker.children.isNotEmpty) {
          placeholderDefaultValues[marker.index] = marker.children;
        } else {
          incompletePlaceholders.add(marker);
        }
      }
      return true;
    });

    void fillInIncompletePlaceholder(Placeholder placeholder, Set<int> stack) {
      final List<Marker>? defaultValues =
          placeholderDefaultValues[placeholder.index];
      if (defaultValues == null) {
        return;
      }
      final Placeholder clone = Placeholder(placeholder.index);
      clone.transform = placeholder.transform;
      for (final Marker child in defaultValues) {
        final Marker newChild = child.clone();
        clone.appendChild(newChild);

        // "recurse" on children that are again placeholders
        if (newChild is Placeholder &&
            placeholderDefaultValues.containsKey(newChild.index) &&
            !stack.contains(newChild.index)) {
          stack.add(newChild.index);
          fillInIncompletePlaceholder(newChild, stack);
          stack.remove(newChild.index);
        }
      }
      snippet.replace(placeholder, <Marker>[clone]);
    }

    final Set<int> stack = <int>{};
    for (final Placeholder placeholder in incompletePlaceholders) {
      fillInIncompletePlaceholder(placeholder, stack);
    }

    return snippet.children.sublist(offset);
  }

  /// 1:1: `ensureFinalTabstop(snippet, enforce, insert)`
  void ensureFinalTabstop(TextmateSnippet snippet, bool enforceFinalTabstop,
      bool insertFinalTabstop) {
    if (enforceFinalTabstop ||
        (insertFinalTabstop && snippet.placeholders.isNotEmpty)) {
      final Placeholder? finalTabstop = snippet.placeholders
          .cast<Placeholder?>()
          .firstWhere((p) => p?.index == 0, orElse: () => null);
      if (finalTabstop == null) {
        // the snippet uses placeholders but has no final tabstop defined
        snippet.appendChild(Placeholder(0));
      }
    }
  }

  /// 1:1: `_accept(type?, value)` 重载 — bool 形式
  bool _acceptBool([int? type]) {
    if (type == null || _token.type == type) {
      _token = _scanner.next();
      return true;
    }
    return false;
  }

  /// 1:1: `_accept(type, value:true)` 重载 — string 形式
  /// 返回 null 表示不匹配（源码返回 false，这里用 null 承载 falsy）
  String? _acceptValue([int? type]) {
    if (type == null || _token.type == type) {
      final String ret = _scanner.tokenText(_token);
      _token = _scanner.next();
      return ret;
    }
    return null;
  }

  /// 1:1: `_backTo(token)`
  bool _backTo(Token token) {
    _scanner.pos = token.pos + token.len;
    _token = token;
    return false;
  }

  /// 1:1: `_until(type)` — 返回 null 表示 false
  String? _until(int type) {
    final Token start = _token;
    while (_token.type != type) {
      if (_token.type == TokenType.EOF) {
        return null;
      } else if (_token.type == TokenType.Backslash) {
        final Token nextToken = _scanner.next();
        if (nextToken.type != TokenType.Dollar &&
            nextToken.type != TokenType.CurlyClose &&
            nextToken.type != TokenType.Backslash) {
          return null;
        }
      }
      _token = _scanner.next();
    }
    final String value = _scanner.value
        .substring(start.pos, _token.pos)
        .replaceAllMapped(RegExp(r'\\(\$|}|\\)'), (m) => m.group(1)!);
    _token = _scanner.next();
    return value;
  }

  /// 1:1: `_parse(marker)`
  bool _parse(Marker marker) =>
      _parseEscaped(marker) ||
      _parseTabstopOrVariableName(marker) ||
      _parseComplexPlaceholder(marker) ||
      _parseComplexVariable(marker) ||
      _parseAnything(marker);

  /// 1:1: `_parseEscaped(marker)`
  bool _parseEscaped(Marker marker) {
    String? value = _acceptValue(TokenType.Backslash);
    if (value != null && value.isNotEmpty) {
      // saw a backslash, append escaped token or that backslash
      value = _acceptValue(TokenType.Dollar) ??
          _acceptValue(TokenType.CurlyClose) ??
          _acceptValue(TokenType.Backslash) ??
          value;
      marker.appendChild(Text(value));
      return true;
    }
    return false;
  }

  /// 1:1: `_parseTabstopOrVariableName(parent)`
  bool _parseTabstopOrVariableName(Marker parent) {
    final Token token = _token;
    final bool dollar = _acceptBool(TokenType.Dollar);
    String? value;
    if (dollar) {
      value = _acceptValue(TokenType.VariableName) ??
          _acceptValue(TokenType.Int);
    }
    final bool match = dollar && value != null && value.isNotEmpty;
    if (!match) {
      return _backTo(token);
    }

    parent.appendChild(RegExp(r'^\d+$').hasMatch(value)
        ? Placeholder(int.parse(value))
        : Variable(value));
    return true;
  }

  /// 1:1: `_parseComplexPlaceholder(parent)`
  bool _parseComplexPlaceholder(Marker parent) {
    final Token token = _token;
    bool match = _acceptBool(TokenType.Dollar) &&
        _acceptBool(TokenType.CurlyOpen);
    String? index;
    if (match) {
      index = _acceptValue(TokenType.Int);
      match = index != null && index.isNotEmpty;
    }
    if (!match) {
      return _backTo(token);
    }

    final Placeholder placeholder = Placeholder(int.parse(index!));

    if (_acceptBool(TokenType.Colon)) {
      // ${1:<children>}
      while (true) {
        // ...} -> done
        if (_acceptBool(TokenType.CurlyClose)) {
          parent.appendChild(placeholder);
          return true;
        }
        if (_parse(placeholder)) {
          continue;
        }
        // fallback
        parent.appendChild(Text('\${$index:'));
        for (final Marker child in placeholder.children) {
          parent.appendChild(child);
        }
        return true;
      }
    } else if (placeholder.index > 0 && _acceptBool(TokenType.Pipe)) {
      // ${1|one,two,three|}
      final Choice choice = Choice();
      while (true) {
        if (_parseChoiceElement(choice)) {
          if (_acceptBool(TokenType.Comma)) {
            // opt, -> more
            continue;
          }
          if (_acceptBool(TokenType.Pipe)) {
            placeholder.appendChild(choice);
            if (_acceptBool(TokenType.CurlyClose)) {
              // ..|} -> done
              parent.appendChild(placeholder);
              return true;
            }
          }
        }
        return _backTo(token);
      }
    } else if (_acceptBool(TokenType.Forwardslash)) {
      // ${1/<regex>/<format>/<options>}
      if (_parseTransform(placeholder)) {
        parent.appendChild(placeholder);
        return true;
      }
      return _backTo(token);
    } else if (_acceptBool(TokenType.CurlyClose)) {
      // ${1}
      parent.appendChild(placeholder);
      return true;
    } else {
      // ${1 <- missing curly or colon
      return _backTo(token);
    }
  }

  /// 1:1: `_parseChoiceElement(parent)`
  bool _parseChoiceElement(Choice parent) {
    final Token token = _token;
    final List<String> values = <String>[];

    while (true) {
      if (_token.type == TokenType.Comma || _token.type == TokenType.Pipe) {
        break;
      }
      String? value = _acceptValue(TokenType.Backslash);
      if (value != null && value.isNotEmpty) {
        // \, \|, or \\
        value = _acceptValue(TokenType.Comma) ??
            _acceptValue(TokenType.Pipe) ??
            _acceptValue(TokenType.Backslash) ??
            value;
      } else {
        value = _acceptValue();
      }
      if (value == null || value.isEmpty) {
        // EOF
        return _backTo(token);
      }
      values.add(value);
    }

    if (values.isEmpty) {
      return _backTo(token);
    }

    parent.appendChild(Text(values.join('')));
    return true;
  }

  /// 1:1: `_parseComplexVariable(parent)`
  bool _parseComplexVariable(Marker parent) {
    final Token token = _token;
    bool match = _acceptBool(TokenType.Dollar) && _acceptBool(TokenType.CurlyOpen);
    String? name;
    if (match) {
      name = _acceptValue(TokenType.VariableName);
      match = name != null && name.isNotEmpty;
    }
    if (!match) {
      return _backTo(token);
    }

    final Variable variable = Variable(name!);

    if (_acceptBool(TokenType.Colon)) {
      // ${foo:<children>}
      while (true) {
        // ...} -> done
        if (_acceptBool(TokenType.CurlyClose)) {
          parent.appendChild(variable);
          return true;
        }
        if (_parse(variable)) {
          continue;
        }
        // fallback
        parent.appendChild(Text('\${$name:'));
        for (final Marker child in variable.children) {
          parent.appendChild(child);
        }
        return true;
      }
    } else if (_acceptBool(TokenType.Forwardslash)) {
      // ${foo/<regex>/<format>/<options>}
      if (_parseTransform(variable)) {
        parent.appendChild(variable);
        return true;
      }
      return _backTo(token);
    } else if (_acceptBool(TokenType.CurlyClose)) {
      // ${foo}
      parent.appendChild(variable);
      return true;
    } else {
      // ${foo <- missing curly or colon
      return _backTo(token);
    }
  }

  /// 1:1: `_parseTransform(parent)`
  bool _parseTransform(TransformableMarker parent) {
    // ...<regex>/<format>/<options>}
    final Transform transform = Transform();
    String regexValue = '';
    String regexOptions = '';

    // (1) /regex
    while (true) {
      if (_acceptBool(TokenType.Forwardslash)) {
        break;
      }
      String? escaped = _acceptValue(TokenType.Backslash);
      if (escaped != null && escaped.isNotEmpty) {
        escaped = _acceptValue(TokenType.Forwardslash) ?? escaped;
        regexValue += escaped;
        continue;
      }
      if (_token.type != TokenType.EOF) {
        regexValue += _acceptValue() ?? '';
        continue;
      }
      return false;
    }

    // (2) /format
    while (true) {
      if (_acceptBool(TokenType.Forwardslash)) {
        break;
      }
      String? escaped = _acceptValue(TokenType.Backslash);
      if (escaped != null && escaped.isNotEmpty) {
        escaped = _acceptValue(TokenType.Backslash) ??
            _acceptValue(TokenType.Forwardslash) ??
            escaped;
        transform.appendChild(Text(escaped));
        continue;
      }
      if (_parseFormatString(transform) || _parseAnything(transform)) {
        continue;
      }
      return false;
    }

    // (3) /option
    while (true) {
      if (_acceptBool(TokenType.CurlyClose)) {
        break;
      }
      if (_token.type != TokenType.EOF) {
        regexOptions += _acceptValue() ?? '';
        continue;
      }
      return false;
    }

    final JsRegExp? compiled = JsRegExp.compile(regexValue, regexOptions);
    if (compiled == null) {
      // invalid regexp
      return false;
    }
    transform.regexp = compiled;
    parent.transform = transform;
    return true;
  }

  /// 1:1: `_parseFormatString(parent)`
  bool _parseFormatString(Transform parent) {
    final Token token = _token;
    if (!_acceptBool(TokenType.Dollar)) {
      return false;
    }

    bool complex = false;
    if (_acceptBool(TokenType.CurlyOpen)) {
      complex = true;
    }

    final String? index = _acceptValue(TokenType.Int);
    if (index == null || index.isEmpty) {
      return _backTo(token);
    } else if (!complex) {
      // $1
      parent.appendChild(FormatString(int.parse(index)));
      return true;
    } else if (_acceptBool(TokenType.CurlyClose)) {
      // ${1}
      parent.appendChild(FormatString(int.parse(index)));
      return true;
    } else if (!_acceptBool(TokenType.Colon)) {
      return _backTo(token);
    }

    if (_acceptBool(TokenType.Forwardslash)) {
      // ${1:/upcase}
      final String? shorthand = _acceptValue(TokenType.VariableName);
      if (shorthand == null || shorthand.isEmpty ||
          !_acceptBool(TokenType.CurlyClose)) {
        return _backTo(token);
      } else {
        parent.appendChild(FormatString(int.parse(index), shorthand));
        return true;
      }
    } else if (_acceptBool(TokenType.Plus)) {
      // ${1:+<if>}
      final String? ifValue = _until(TokenType.CurlyClose);
      if (ifValue != null) {
        parent.appendChild(
            FormatString(int.parse(index), null, ifValue, null));
        return true;
      }
    } else if (_acceptBool(TokenType.Dash)) {
      // ${2:-<else>}
      final String? elseValue = _until(TokenType.CurlyClose);
      if (elseValue != null) {
        parent.appendChild(
            FormatString(int.parse(index), null, null, elseValue));
        return true;
      }
    } else if (_acceptBool(TokenType.QuestionMark)) {
      // ${2:?<if>:<else>}
      final String? ifValue = _until(TokenType.Colon);
      if (ifValue != null) {
        final String? elseValue = _until(TokenType.CurlyClose);
        if (elseValue != null) {
          parent.appendChild(
              FormatString(int.parse(index), null, ifValue, elseValue));
          return true;
        }
      }
    } else {
      // ${1:<else>}
      final String? elseValue = _until(TokenType.CurlyClose);
      if (elseValue != null) {
        parent.appendChild(
            FormatString(int.parse(index), null, null, elseValue));
        return true;
      }
    }

    return _backTo(token);
  }

  /// 1:1: `_parseAnything(marker)`
  bool _parseAnything(Marker marker) {
    if (_token.type != TokenType.EOF) {
      marker.appendChild(Text(_scanner.tokenText(_token)));
      _acceptBool();
      return true;
    }
    return false;
  }
}
