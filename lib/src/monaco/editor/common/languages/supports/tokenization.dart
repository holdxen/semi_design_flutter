// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/supports/tokenization.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `FontStyle`/`ColorId`/`StandardTokenType` are `int` carriers here (see
//    `encodedTokenAttributes.dart`), so the TS type annotations on those
//    members become `int`.
//  * `Color[]` from `ColorMap` is a JS sparse array → `List<Color?>` (index 0
//    stays unused, exactly like the source).
//  * JS `String(number)` drops the fraction for integer-valued numbers
//    (`${1.5 * 2}` is `"3"`), Dart prints `3.0` → `_jsNum` helper.
//  * `Map` default parameter `new Map<string, ExternalThemeTrieElement>()` is
//    kept; the plain-object branch of that constructor is carried through
//    `Map<String, ExternalThemeTrieElement>` only (`ExternalThemeTrieElement`
//    is built from `Map` in this port).
// ---------------------------------------------------------------------------
import '../../../../base/common/color.dart' show Color;
import '../../../../platform/theme/common/themeService.dart'
    show IFontTokenOptions;
import '../../config/fontInfo.dart' show sanitizeFontFamily;
import '../../encodedTokenAttributes.dart'
    show ColorId, FontStyle, MetadataConsts, StandardTokenType;

class ITokenThemeRule {
  ITokenThemeRule({required this.token, this.foreground, this.background, this.fontStyle});

  String token;
  String? foreground;
  String? background;
  String? fontStyle;
}

/// JS `String(number)` semantics: integer-valued numbers carry no `.0`.
String _jsNum(num value) {
  if (value is int) {
    return value.toString();
  }
  final double asDouble = value.toDouble();
  if (asDouble.isFinite && asDouble == asDouble.truncateToDouble()) {
    return asDouble.toInt().toString();
  }
  return asDouble.toString();
}

class ParsedTokenThemeRule {
  // ignore: unused_field
  final Object? _parsedThemeRuleBrand = null;

  final String token;
  final int index;

  /// -1 if not set. An or mask of `FontStyle` otherwise.
  final int fontStyle;
  final String? foreground;
  final String? background;

  ParsedTokenThemeRule(
    this.token,
    this.index,
    this.fontStyle,
    this.foreground,
    this.background,
  );
}

/// Parse a raw theme into rules.
List<ParsedTokenThemeRule> parseTokenTheme(List<ITokenThemeRule> source) {
  if (source.isEmpty) {
    return <ParsedTokenThemeRule>[];
  }
  final List<ParsedTokenThemeRule> result = <ParsedTokenThemeRule>[];
  for (int i = 0, len = source.length; i < len; i++) {
    final ITokenThemeRule entry = source[i];

    int fontStyle = FontStyle.notSet;
    final String? entryFontStyle = entry.fontStyle;
    if (entryFontStyle != null) {
      fontStyle = FontStyle.none;

      final List<String> segments = entryFontStyle.split(' ');
      for (final String segment in segments) {
        switch (segment) {
          case 'italic':
            fontStyle = fontStyle | FontStyle.italic;
            break;
          case 'bold':
            fontStyle = fontStyle | FontStyle.bold;
            break;
          case 'underline':
            fontStyle = fontStyle | FontStyle.underline;
            break;
          case 'strikethrough':
            fontStyle = fontStyle | FontStyle.strikethrough;
            break;
        }
      }
    }

    final String? foreground = entry.foreground;
    final String? background = entry.background;

    result.add(ParsedTokenThemeRule(
      entry.token,
      i,
      fontStyle,
      foreground,
      background,
    ));
  }

  return result;
}

/// Resolve rules (i.e. inheritance).
TokenTheme _resolveParsedTokenThemeRules(
    List<ParsedTokenThemeRule> parsedThemeRules, List<String> customTokenColors) {
  // Sort rules lexicographically, and then by index if necessary
  parsedThemeRules.sort((ParsedTokenThemeRule a, ParsedTokenThemeRule b) {
    final int r = strcmp(a.token, b.token);
    if (r != 0) {
      return r;
    }
    return a.index - b.index;
  });

  // Determine defaults
  int defaultFontStyle = FontStyle.none;
  String defaultForeground = '000000';
  String defaultBackground = 'ffffff';
  while (parsedThemeRules.isNotEmpty && parsedThemeRules[0].token == '') {
    final ParsedTokenThemeRule incomingDefaults = parsedThemeRules.removeAt(0);
    if (incomingDefaults.fontStyle != FontStyle.notSet) {
      defaultFontStyle = incomingDefaults.fontStyle;
    }
    if (incomingDefaults.foreground != null) {
      defaultForeground = incomingDefaults.foreground!;
    }
    if (incomingDefaults.background != null) {
      defaultBackground = incomingDefaults.background!;
    }
  }
  final ColorMap colorMap = ColorMap();

  // start with token colors from custom token themes
  for (final String color in customTokenColors) {
    colorMap.getId(color);
  }

  final int foregroundColorId = colorMap.getId(defaultForeground);
  final int backgroundColorId = colorMap.getId(defaultBackground);

  final ThemeTrieElementRule defaults = ThemeTrieElementRule(
      defaultFontStyle, foregroundColorId, backgroundColorId);
  final ThemeTrieElement root = ThemeTrieElement(defaults);
  for (int i = 0, len = parsedThemeRules.length; i < len; i++) {
    final ParsedTokenThemeRule rule = parsedThemeRules[i];
    root.insert(rule.token, rule.fontStyle, colorMap.getId(rule.foreground),
        colorMap.getId(rule.background));
  }

  return TokenTheme(colorMap, root);
}

final RegExp colorRegExp = RegExp(r'^#?([0-9A-Fa-f]{6})([0-9A-Fa-f]{2})?$');

class ColorMap {
  int _lastColorId = 0;
  final List<Color?> _id2color = <Color?>[];
  final Map<String, int> _color2id = <String, int>{};

  int getId(String? color) {
    if (color == null) {
      return 0;
    }
    final RegExpMatch? match = colorRegExp.firstMatch(color);
    if (match == null) {
      throw StateError('Illegal value for token color: $color');
    }
    color = match.group(1)!.toUpperCase();
    int? value = _color2id[color];
    if (value != null && value != 0) {
      return value;
    }
    value = ++_lastColorId;
    _color2id[color] = value;
    final int index = value;
    while (_id2color.length <= index) {
      _id2color.add(null);
    }
    _id2color[index] = Color.fromHex('#$color');
    return value;
  }

  List<Color?> getColorMap() {
    return List<Color?>.of(_id2color);
  }
}

class TokenTheme {
  static TokenTheme createFromRawTokenTheme(
          List<ITokenThemeRule> source, List<String> customTokenColors) =>
      createFromParsedTokenTheme(parseTokenTheme(source), customTokenColors);

  static TokenTheme createFromParsedTokenTheme(
          List<ParsedTokenThemeRule> source, List<String> customTokenColors) =>
      _resolveParsedTokenThemeRules(source, customTokenColors);

  final ColorMap _colorMap;
  final ThemeTrieElement _root;
  final Map<String, int> _cache = <String, int>{};

  TokenTheme(this._colorMap, this._root);

  List<Color?> getColorMap() {
    return _colorMap.getColorMap();
  }

  /// used for testing purposes
  ExternalThemeTrieElement getThemeTrieElement() {
    return _root.toExternalThemeTrieElement();
  }

  /// TS: `public _match(token)`.
  ThemeTrieElementRule matchRule(String token) {
    return _root.match(token);
  }

  int match(int languageId, String token) {
    // The cache contains the metadata without the language bits set.
    int? result = _cache[token];
    if (result == null) {
      final ThemeTrieElementRule rule = matchRule(token);
      final int standardToken = toStandardTokenType(token);
      result = (rule.metadata |
              (standardToken << MetadataConsts.tokenTypeOffset)) &
          0xFFFFFFFF;
      _cache[token] = result;
    }

    return (result | (languageId << MetadataConsts.languageIdOffset)) &
        0xFFFFFFFF;
  }
}

final RegExp STANDARD_TOKEN_TYPE_REGEXP =
    RegExp(r'\b(comment|string|regex|regexp)\b');

int toStandardTokenType(String tokenType) {
  final RegExpMatch? m = STANDARD_TOKEN_TYPE_REGEXP.firstMatch(tokenType);
  if (m == null) {
    return StandardTokenType.other;
  }
  switch (m.group(1)) {
    case 'comment':
      return StandardTokenType.comment;
    case 'string':
      return StandardTokenType.string;
    case 'regex':
      return StandardTokenType.regEx;
    case 'regexp':
      return StandardTokenType.regEx;
  }
  throw StateError('Unexpected match for standard token type!');
}

int strcmp(String a, String b) {
  if (a.compareTo(b) < 0) {
    return -1;
  }
  if (a.compareTo(b) > 0) {
    return 1;
  }
  return 0;
}

class ThemeTrieElementRule {
  // ignore: unused_field
  final Object? _themeTrieElementRuleBrand = null;

  int _fontStyle;
  int _foreground;
  int _background;
  int metadata;

  ThemeTrieElementRule(this._fontStyle, this._foreground, this._background)
      : metadata = ((_fontStyle << MetadataConsts.fontStyleOffset) |
                (_foreground << MetadataConsts.foregroundOffset) |
                (_background << MetadataConsts.backgroundOffset)) &
            0xFFFFFFFF;

  ThemeTrieElementRule clone() {
    return ThemeTrieElementRule(_fontStyle, _foreground, _background);
  }

  void acceptOverwrite(int fontStyle, int foreground, int background) {
    if (fontStyle != FontStyle.notSet) {
      _fontStyle = fontStyle;
    }
    if (foreground != ColorId.none) {
      _foreground = foreground;
    }
    if (background != ColorId.none) {
      _background = background;
    }
    metadata = ((_fontStyle << MetadataConsts.fontStyleOffset) |
            (_foreground << MetadataConsts.foregroundOffset) |
            (_background << MetadataConsts.backgroundOffset)) &
        0xFFFFFFFF;
  }
}

class ExternalThemeTrieElement {
  final ThemeTrieElementRule mainRule;
  final Map<String, ExternalThemeTrieElement> children;

  ExternalThemeTrieElement(
    this.mainRule, [
    Map<String, ExternalThemeTrieElement>? children,
  ]) : children = children ?? <String, ExternalThemeTrieElement>{};
}

class ThemeTrieElement {
  // ignore: unused_field
  final Object? _themeTrieElementBrand = null;

  final ThemeTrieElementRule _mainRule;
  final Map<String, ThemeTrieElement> _children = <String, ThemeTrieElement>{};

  ThemeTrieElement(this._mainRule);

  /// used for testing purposes
  ExternalThemeTrieElement toExternalThemeTrieElement() {
    final Map<String, ExternalThemeTrieElement> children =
        <String, ExternalThemeTrieElement>{};
    _children.forEach((String index, ThemeTrieElement element) {
      children[index] = element.toExternalThemeTrieElement();
    });
    return ExternalThemeTrieElement(_mainRule, children);
  }

  ThemeTrieElementRule match(String token) {
    if (token == '') {
      return _mainRule;
    }

    final int dotIndex = token.indexOf('.');
    String head;
    String tail;
    if (dotIndex == -1) {
      head = token;
      tail = '';
    } else {
      head = token.substring(0, dotIndex);
      tail = token.substring(dotIndex + 1);
    }

    final ThemeTrieElement? child = _children[head];
    if (child != null) {
      return child.match(tail);
    }

    return _mainRule;
  }

  void insert(String token, int fontStyle, int foreground, int background) {
    if (token == '') {
      // Merge into the main rule
      _mainRule.acceptOverwrite(fontStyle, foreground, background);
      return;
    }

    final int dotIndex = token.indexOf('.');
    String head;
    String tail;
    if (dotIndex == -1) {
      head = token;
      tail = '';
    } else {
      head = token.substring(0, dotIndex);
      tail = token.substring(dotIndex + 1);
    }

    ThemeTrieElement? child = _children[head];
    if (child == null) {
      child = ThemeTrieElement(_mainRule.clone());
      _children[head] = child;
    }

    child.insert(tail, fontStyle, foreground, background);
  }
}

String generateTokensCSSForColorMap(List<Color?> colorMap) {
  // TS writes `rules[i] = ...` starting at index 1, so index 0 stays a hole
  // and `join('\n')` renders it as an empty line; reproduced with a nullable
  // fixed-length carrier.
  final List<String?> rules = <String?>[];
  for (int i = 1, len = colorMap.length; i < len; i++) {
    while (rules.length < i) {
      rules.add(null); // hole in the JS array
    }
    rules.add('.mtk$i { color: ${colorMap[i]}; }');
  }
  rules.add('.mtki { font-style: italic; }');
  rules.add('.mtkb { font-weight: bold; }');
  rules.add(
      '.mtku { text-decoration: underline; text-underline-position: under; }');
  rules.add('.mtks { text-decoration: line-through; }');
  rules.add(
      '.mtks.mtku { text-decoration: underline line-through; text-underline-position: under; }');
  return rules.map((String? rule) => rule ?? '').join('\n');
}

String generateTokensCSSForFontMap(List<IFontTokenOptions?> fontMap) {
  final List<String> rules = <String>[];
  final Set<String> fonts = <String>{};
  for (int i = 1, len = fontMap.length; i < len; i++) {
    final IFontTokenOptions? font = fontMap[i];
    if (font == null) {
      continue;
    }
    final String? fontFamily = font.fontFamily;
    final num? fontSizeMultiplier = font.fontSizeMultiplier;
    if ((fontFamily == null || fontFamily.isEmpty) &&
        (fontSizeMultiplier == null || fontSizeMultiplier == 0)) {
      continue;
    }
    final String className = classNameForFontTokenDecorations(
        fontFamily ?? '', fontSizeMultiplier ?? 0);
    if (fonts.contains(className)) {
      continue;
    }
    fonts.add(className);
    String rule = '.$className {';
    if (fontFamily != null && fontFamily.isNotEmpty) {
      rule += 'font-family: ${sanitizeFontFamily(fontFamily)};';
    }
    if (fontSizeMultiplier is num &&
        fontSizeMultiplier.isFinite &&
        fontSizeMultiplier > 0) {
      rule +=
          'font-size: calc(var(--editor-font-size)*${_jsNum(fontSizeMultiplier)});';
    }
    rule += '}';
    rules.add(rule);
  }
  return rules.join('\n');
}

String classNameForFontTokenDecorations(String fontFamily, num fontSize) {
  final String safeFontFamily = _sanitizeFontFamilyForClassName(fontFamily);
  return _cleanClassName('font-decoration-$safeFontFamily-${_jsNum(fontSize)}');
}

String _sanitizeFontFamilyForClassName(String fontFamily) {
  final String normalized = fontFamily.toLowerCase().trim();
  if (normalized.isEmpty) {
    return 'default';
  }
  return _cleanClassName(normalized);
}

String _cleanClassName(String className) {
  return className.replaceAll(RegExp(r'[^a-z0-9_-]', caseSensitive: false), '-');
}