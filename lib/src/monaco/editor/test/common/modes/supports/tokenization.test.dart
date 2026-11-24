// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/modes/supports/tokenization.test.ts
// Translated 1:1. The 4 mocha suites become Dart functions carrying the exact
// `deepStrictEqual` / `strictEqual` assertions; `runAll()` executes every
// suite in order.
//   - `deepStrictEqual(actual, new ThemeTrieElementRule(fs, fg, bg))`: the
//     port's `ThemeTrieElementRule` has no structural `==`, so equality goes
//     through `metadata`, which is derived 1:1 from (fontStyle, foreground,
//     background) — same fields the JS comparison reads.
//   - `deepStrictEqual(actual.getThemeTrieElement(), root)`: both sides are
//     converted with the same `_toJson` walker (mainRule.metadata + ordered
//     children map), matching JS's recursive object comparison.
//   - `assert.deepStrictEqual(actual.getColorMap(), colorMap.getColorMap())`:
//     compared as `String(color)` lists.
//   - the nonnumeric `fontSizeMultiplier` JSON case relies on the runtime
//     `typeof === 'number'` guard; the port's `generateTokensCSSForFontMap`
//     carries `List<Object?>` for exactly that reason.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook
// and is intentionally omitted here (same as the other mirrored tests).
// ---------------------------------------------------------------------------

import 'dart:convert';

import '../../../../../platform/theme/common/themeService.dart'
    show IFontTokenOptions;
import '../../../../common/config/fontInfo.dart' show EDITOR_FONT_DEFAULTS;
import '../../../../common/encodedTokenAttributes.dart' show FontStyle;
import '../../../../common/languages/supports/tokenization.dart'
    show
        ColorMap,
        ExternalThemeTrieElement,
        ITokenThemeRule,
        ParsedTokenThemeRule,
        ThemeTrieElementRule,
        TokenTheme,
        classNameForFontTokenDecorations,
        generateTokensCSSForFontMap,
        parseTokenTheme,
        strcmp;

void _check(Object? actual, Object? expected, [String message = '']) {
  if (actual is List && expected is List) {
    if (actual.length != expected.length) {
      throw StateError('$message deepStrictEqual: length '
          '${actual.length} != ${expected.length}\n  actual: $actual\n  expected: $expected');
    }
    for (int i = 0; i < actual.length; i++) {
      _check(actual[i], expected[i], message);
    }
    return;
  }
  if (actual is Map && expected is Map) {
    if (actual.length != expected.length) {
      throw StateError('$message deepStrictEqual: map size '
          '${actual.length} != ${expected.length}');
    }
    for (final Object? key in actual.keys) {
      if (!expected.containsKey(key)) {
        throw StateError('$message deepStrictEqual: missing key $key');
      }
      _check(actual[key], expected[key], message);
    }
    return;
  }
  if (actual != expected) {
    throw StateError(
        '$message deepStrictEqual:\n  actual: $actual\n  expected: $expected');
  }
}

Object? _toJson(Object? element) {
  if (element is ExternalThemeTrieElement) {
    final Map<String, Object?> children = <String, Object?>{};
    final List<String> keys = element.children.keys.toList()..sort();
    for (final String key in keys) {
      children[key] = _toJson(element.children[key]);
    }
    return <String, Object?>{
      'metadata': element.mainRule.metadata,
      'children': children,
    };
  }
  return element;
}

List<Object?> _colorMapJson(List<Object?> colorMap) =>
    colorMap.map((Object? color) => color == null ? null : '$color').toList();

// ---------------------------------------------------------------------------
// suite('Token font CSS')
// ---------------------------------------------------------------------------

/// 1:1: `test('preserves font lists and positive fractional sizes and
/// deduplicates rules')`
void testPreservesFontListsAndDeduplicatesRules() {
  const String fontFamily = '"Fira Code", monospace';
  final IFontTokenOptions font = IFontTokenOptions()
    ..fontFamily = fontFamily
    ..fontSizeMultiplier = 1.2;
  _check(
    generateTokensCSSForFontMap(<Object?>[
      IFontTokenOptions(),
      font,
      font,
      IFontTokenOptions()..fontSizeMultiplier = 0.75,
    ]),
    <String>[
      '.${classNameForFontTokenDecorations(fontFamily, 1.2)} '
          '{font-family: $fontFamily;font-size: calc(var(--editor-font-size)*1.2);}',
      '.${classNameForFontTokenDecorations('', 0.75)} '
          '{font-size: calc(var(--editor-font-size)*0.75);}',
    ].join('\n'),
  );
}

/// 1:1: `test('sanitizes font families before inserting them into CSS')`
void testSanitizesFontFamilies() {
  final List<String> fontFamilies = <String>[
    'monospace; color: red',
    'monospace} .token-font-injection {color: red',
    'monospace/*',
  ];
  _check(
    fontFamilies
        .map((String fontFamily) => generateTokensCSSForFontMap(<Object?>[
              IFontTokenOptions(),
              IFontTokenOptions()
                ..fontFamily = fontFamily
                ..fontSizeMultiplier = 1.2,
            ]))
        .toList(),
    fontFamilies
        .map((String fontFamily) =>
            '.${classNameForFontTokenDecorations(fontFamily, 1.2)} '
            '{font-family: ${EDITOR_FONT_DEFAULTS.fontFamily};font-size: calc(var(--editor-font-size)*1.2);}')
        .toList(),
  );
}

/// 1:1: `test('ignores nonpositive and nonfinite sizes without dropping the
/// font family')`
void testIgnoresNonpositiveAndNonfiniteSizes() {
  final List<num> fontSizes = <num>[0, -1, double.nan, double.infinity, double.negativeInfinity];
  _check(
    fontSizes
        .map((num fontSizeMultiplier) => generateTokensCSSForFontMap(
            <Object?>[
              IFontTokenOptions(),
              IFontTokenOptions()
                ..fontFamily = 'monospace'
                ..fontSizeMultiplier = fontSizeMultiplier,
            ]))
        .toList(),
    fontSizes
        .map((num fontSizeMultiplier) =>
            '.${classNameForFontTokenDecorations('monospace', fontSizeMultiplier)} '
            '{font-family: monospace;}')
        .toList(),
  );
}

/// 1:1: `test('does not interpolate nonnumeric font sizes from
/// configuration')`
void testDoesNotInterpolateNonnumericFontSizes() {
  // 1:1: `JSON.parse('[{}, {"fontFamily": ... }, ...]')` — the elements are
  // plain JS objects; the Dart carrier keeps the decoded maps as-is.
  final List<Object?> fontMap =
      (jsonDecode('[{}, {"fontFamily": "monospace", "fontSizeMultiplier": "1);color:red"}, {"fontFamily": "serif", "fontSizeMultiplier": "1.2"}, {"fontFamily": "sans-serif", "fontSizeMultiplier": true}]')
              as List<dynamic>)
          .cast<Object?>()
          .toList();
  final List<String> rules =
      generateTokensCSSForFontMap(fontMap).split('\n');
  _check(
    rules
        .map((String rule) =>
            rule.substring(rule.indexOf('{')))
        .toList(),
    <String>[
      '{font-family: monospace;}',
      '{font-family: serif;}',
      '{font-family: sans-serif;}',
    ],
  );
}

// ---------------------------------------------------------------------------
// suite('Token theme matching')
// ---------------------------------------------------------------------------

/// 1:1: `test('gives higher priority to deeper matches')`
void testGivesHigherPriorityToDeeperMatches() {
  final TokenTheme theme = TokenTheme.createFromRawTokenTheme(
    <ITokenThemeRule>[
      ITokenThemeRule(token: '', foreground: '100000', background: '200000'),
      ITokenThemeRule(
          token: 'punctuation.definition.string.begin.html',
          foreground: '300000'),
      ITokenThemeRule(
          token: 'punctuation.definition.string', foreground: '400000'),
    ],
    <String>[],
  );

  final ColorMap colorMap = ColorMap();
  colorMap.getId('100000');
  final int b = colorMap.getId('200000');
  colorMap.getId('400000');
  final int d = colorMap.getId('300000');

  final ThemeTrieElementRule actual =
      theme.matchRule('punctuation.definition.string.begin.html');

  _check(actual.metadata,
      ThemeTrieElementRule(FontStyle.none, d, b).metadata);
}

/// 1:1: `test('can match')`
void testCanMatch() {
  final TokenTheme theme = TokenTheme.createFromRawTokenTheme(
    <ITokenThemeRule>[
      ITokenThemeRule(token: '', foreground: 'F8F8F2', background: '272822'),
      ITokenThemeRule(token: 'source', background: '100000'),
      ITokenThemeRule(token: 'something', background: '100000'),
      ITokenThemeRule(token: 'bar', background: '200000'),
      ITokenThemeRule(token: 'baz', background: '200000'),
      ITokenThemeRule(token: 'bar', fontStyle: 'bold'),
      ITokenThemeRule(
          token: 'constant', fontStyle: 'italic', foreground: '300000'),
      ITokenThemeRule(token: 'constant.numeric', foreground: '400000'),
      ITokenThemeRule(token: 'constant.numeric.hex', fontStyle: 'bold'),
      ITokenThemeRule(
          token: 'constant.numeric.oct', fontStyle: 'bold italic underline'),
      ITokenThemeRule(
          token: 'constant.numeric.bin', fontStyle: 'bold strikethrough'),
      ITokenThemeRule(
          token: 'constant.numeric.dec', fontStyle: '', foreground: '500000'),
      ITokenThemeRule(
          token: 'storage.object.bar', fontStyle: '', foreground: '600000'),
    ],
    <String>[],
  );

  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('F8F8F2');
  final int b = colorMap.getId('272822');
  final int c = colorMap.getId('200000');
  final int d = colorMap.getId('300000');
  final int e = colorMap.getId('400000');
  final int f = colorMap.getId('500000');
  final int g = colorMap.getId('100000');
  final int h = colorMap.getId('600000');

  void assertMatch(String scopeName, ThemeTrieElementRule expected) {
    final ThemeTrieElementRule actual = theme.matchRule(scopeName);
    _check(actual.metadata, expected.metadata,
        'when matching <<$scopeName>>');
  }

  void assertSimpleMatch(
      String scopeName, int fontStyle, int foreground, int background) {
    assertMatch(scopeName, ThemeTrieElementRule(fontStyle, foreground, background));
  }

  void assertNoMatch(String scopeName) {
    assertMatch(scopeName, ThemeTrieElementRule(FontStyle.none, a, b));
  }

  // matches defaults
  assertNoMatch('');
  assertNoMatch('bazz');
  assertNoMatch('asdfg');

  // matches source
  assertSimpleMatch('source', FontStyle.none, a, g);
  assertSimpleMatch('source.ts', FontStyle.none, a, g);
  assertSimpleMatch('source.tss', FontStyle.none, a, g);

  // matches something
  assertSimpleMatch('something', FontStyle.none, a, g);
  assertSimpleMatch('something.ts', FontStyle.none, a, g);
  assertSimpleMatch('something.tss', FontStyle.none, a, g);

  // matches baz
  assertSimpleMatch('baz', FontStyle.none, a, c);
  assertSimpleMatch('baz.ts', FontStyle.none, a, c);
  assertSimpleMatch('baz.tss', FontStyle.none, a, c);

  // matches constant
  assertSimpleMatch('constant', FontStyle.italic, d, b);
  assertSimpleMatch('constant.string', FontStyle.italic, d, b);
  assertSimpleMatch('constant.hex', FontStyle.italic, d, b);

  // matches constant.numeric
  assertSimpleMatch('constant.numeric', FontStyle.italic, e, b);
  assertSimpleMatch('constant.numeric.baz', FontStyle.italic, e, b);

  // matches constant.numeric.hex
  assertSimpleMatch('constant.numeric.hex', FontStyle.bold, e, b);
  assertSimpleMatch('constant.numeric.hex.baz', FontStyle.bold, e, b);

  // matches constant.numeric.oct
  assertSimpleMatch('constant.numeric.oct',
      FontStyle.bold | FontStyle.italic | FontStyle.underline, e, b);
  assertSimpleMatch('constant.numeric.oct.baz',
      FontStyle.bold | FontStyle.italic | FontStyle.underline, e, b);

  // matches constant.numeric.bin
  assertSimpleMatch('constant.numeric.bin',
      FontStyle.bold | FontStyle.strikethrough, e, b);
  assertSimpleMatch('constant.numeric.bin.baz',
      FontStyle.bold | FontStyle.strikethrough, e, b);

  // matches constant.numeric.dec
  assertSimpleMatch('constant.numeric.dec', FontStyle.none, f, b);
  assertSimpleMatch('constant.numeric.dec.baz', FontStyle.none, f, b);

  // matches storage.object.bar
  assertSimpleMatch('storage.object.bar', FontStyle.none, h, b);
  assertSimpleMatch('storage.object.bar.baz', FontStyle.none, h, b);

  // does not match storage.object.bar
  assertSimpleMatch('storage.object.bart', FontStyle.none, a, b);
  assertSimpleMatch('storage.object', FontStyle.none, a, b);
  assertSimpleMatch('storage', FontStyle.none, a, b);

  assertSimpleMatch('bar', FontStyle.bold, a, c);
}

// ---------------------------------------------------------------------------
// suite('Token theme parsing')
// ---------------------------------------------------------------------------

/// 1:1: `test('can parse')`
void testCanParse() {
  final List<ParsedTokenThemeRule> actual = parseTokenTheme(<ITokenThemeRule>[
    ITokenThemeRule(token: '', foreground: 'F8F8F2', background: '272822'),
    ITokenThemeRule(token: 'source', background: '100000'),
    ITokenThemeRule(token: 'something', background: '100000'),
    ITokenThemeRule(token: 'bar', background: '010000'),
    ITokenThemeRule(token: 'baz', background: '010000'),
    ITokenThemeRule(token: 'bar', fontStyle: 'bold'),
    ITokenThemeRule(
        token: 'constant', fontStyle: 'italic', foreground: 'ff0000'),
    ITokenThemeRule(token: 'constant.numeric', foreground: '00ff00'),
    ITokenThemeRule(token: 'constant.numeric.hex', fontStyle: 'bold'),
    ITokenThemeRule(
        token: 'constant.numeric.oct', fontStyle: 'bold italic underline'),
    ITokenThemeRule(
        token: 'constant.numeric.dec', fontStyle: '', foreground: '0000ff'),
  ]);

  final List<ParsedTokenThemeRule> expected = <ParsedTokenThemeRule>[
    ParsedTokenThemeRule('', 0, FontStyle.notSet, 'F8F8F2', '272822'),
    ParsedTokenThemeRule('source', 1, FontStyle.notSet, null, '100000'),
    ParsedTokenThemeRule('something', 2, FontStyle.notSet, null, '100000'),
    ParsedTokenThemeRule('bar', 3, FontStyle.notSet, null, '010000'),
    ParsedTokenThemeRule('baz', 4, FontStyle.notSet, null, '010000'),
    ParsedTokenThemeRule('bar', 5, FontStyle.bold, null, null),
    ParsedTokenThemeRule('constant', 6, FontStyle.italic, 'ff0000', null),
    ParsedTokenThemeRule('constant.numeric', 7, FontStyle.notSet, '00ff00', null),
    ParsedTokenThemeRule('constant.numeric.hex', 8, FontStyle.bold, null, null),
    ParsedTokenThemeRule('constant.numeric.oct', 9,
        FontStyle.bold | FontStyle.italic | FontStyle.underline, null, null),
    ParsedTokenThemeRule('constant.numeric.dec', 10, FontStyle.none, '0000ff', null),
  ];

  _check(
    actual
        .map((ParsedTokenThemeRule rule) => <String, Object?>{
              'token': rule.token,
              'index': rule.index,
              'fontStyle': rule.fontStyle,
              'foreground': rule.foreground,
              'background': rule.background,
            })
        .toList(),
    expected
        .map((ParsedTokenThemeRule rule) => <String, Object?>{
              'token': rule.token,
              'index': rule.index,
              'fontStyle': rule.fontStyle,
              'foreground': rule.foreground,
              'background': rule.background,
            })
        .toList(),
  );
}

// ---------------------------------------------------------------------------
// suite('Token theme resolving')
// ---------------------------------------------------------------------------

/// 1:1: `test('strcmp works')`
void testStrcmpWorks() {
  final List<String> actual = <String>['bar', 'z', 'zu', 'a', 'ab', '']
    ..sort(strcmp);

  const List<String> expected = <String>['', 'a', 'ab', 'bar', 'z', 'zu'];
  _check(actual, expected);
}

/// 1:1: `test('always has defaults')`
void testAlwaysHasDefaults() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[], <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('000000');
  final int b = colorMap.getId('ffffff');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  _check(
      _toJson(actual.getThemeTrieElement()),
      _toJson(ExternalThemeTrieElement(
          ThemeTrieElementRule(FontStyle.none, a, b))));
}

/// 1:1: `test('respects incoming defaults 1')`
void testRespectsIncomingDefaults1() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.notSet, null, null)
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('000000');
  final int b = colorMap.getId('ffffff');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  _check(
      _toJson(actual.getThemeTrieElement()),
      _toJson(ExternalThemeTrieElement(
          ThemeTrieElementRule(FontStyle.none, a, b))));
}

/// 1:1: `test('respects incoming defaults 2')`
void testRespectsIncomingDefaults2() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.none, null, null)
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('000000');
  final int b = colorMap.getId('ffffff');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  _check(
      _toJson(actual.getThemeTrieElement()),
      _toJson(ExternalThemeTrieElement(
          ThemeTrieElementRule(FontStyle.none, a, b))));
}

/// 1:1: `test('respects incoming defaults 3')`
void testRespectsIncomingDefaults3() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.bold, null, null)
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('000000');
  final int b = colorMap.getId('ffffff');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  _check(
      _toJson(actual.getThemeTrieElement()),
      _toJson(ExternalThemeTrieElement(
          ThemeTrieElementRule(FontStyle.bold, a, b))));
}

/// 1:1: `test('respects incoming defaults 4')`
void testRespectsIncomingDefaults4() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.notSet, 'ff0000', null)
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('ff0000');
  final int b = colorMap.getId('ffffff');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  _check(
      _toJson(actual.getThemeTrieElement()),
      _toJson(ExternalThemeTrieElement(
          ThemeTrieElementRule(FontStyle.none, a, b))));
}

/// 1:1: `test('respects incoming defaults 5')`
void testRespectsIncomingDefaults5() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.notSet, null, 'ff0000')
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('000000');
  final int b = colorMap.getId('ff0000');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  _check(
      _toJson(actual.getThemeTrieElement()),
      _toJson(ExternalThemeTrieElement(
          ThemeTrieElementRule(FontStyle.none, a, b))));
}

/// 1:1: `test('can merge incoming defaults')`
void testCanMergeIncomingDefaults() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.notSet, null, 'ff0000'),
        ParsedTokenThemeRule('', -1, FontStyle.notSet, '00ff00', null),
        ParsedTokenThemeRule('', -1, FontStyle.bold, null, null),
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('00ff00');
  final int b = colorMap.getId('ff0000');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  _check(
      _toJson(actual.getThemeTrieElement()),
      _toJson(ExternalThemeTrieElement(
          ThemeTrieElementRule(FontStyle.bold, a, b))));
}

/// 1:1: `test('defaults are inherited')`
void testDefaultsAreInherited() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.notSet, 'F8F8F2', '272822'),
        ParsedTokenThemeRule('var', -1, FontStyle.notSet, 'ff0000', null)
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('F8F8F2');
  final int b = colorMap.getId('272822');
  final int c = colorMap.getId('ff0000');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  final ExternalThemeTrieElement root = ExternalThemeTrieElement(
      ThemeTrieElementRule(FontStyle.none, a, b),
      <String, ExternalThemeTrieElement>{
        'var': ExternalThemeTrieElement(
            ThemeTrieElementRule(FontStyle.none, c, b)),
      });
  _check(_toJson(actual.getThemeTrieElement()), _toJson(root));
}

/// 1:1: `test('same rules get merged')`
void testSameRulesGetMerged() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.notSet, 'F8F8F2', '272822'),
        ParsedTokenThemeRule('var', 1, FontStyle.bold, null, null),
        ParsedTokenThemeRule('var', 0, FontStyle.notSet, 'ff0000', null),
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('F8F8F2');
  final int b = colorMap.getId('272822');
  final int c = colorMap.getId('ff0000');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  final ExternalThemeTrieElement root = ExternalThemeTrieElement(
      ThemeTrieElementRule(FontStyle.none, a, b),
      <String, ExternalThemeTrieElement>{
        'var': ExternalThemeTrieElement(
            ThemeTrieElementRule(FontStyle.bold, c, b)),
      });
  _check(_toJson(actual.getThemeTrieElement()), _toJson(root));
}

/// 1:1: `test('rules are inherited 1')`
void testRulesAreInherited1() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.notSet, 'F8F8F2', '272822'),
        ParsedTokenThemeRule('var', -1, FontStyle.bold, 'ff0000', null),
        ParsedTokenThemeRule('var.identifier', -1, FontStyle.notSet, '00ff00', null),
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('F8F8F2');
  final int b = colorMap.getId('272822');
  final int c = colorMap.getId('ff0000');
  final int d = colorMap.getId('00ff00');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  final ExternalThemeTrieElement root = ExternalThemeTrieElement(
      ThemeTrieElementRule(FontStyle.none, a, b),
      <String, ExternalThemeTrieElement>{
        'var': ExternalThemeTrieElement(
            ThemeTrieElementRule(FontStyle.bold, c, b),
            <String, ExternalThemeTrieElement>{
              'identifier': ExternalThemeTrieElement(
                  ThemeTrieElementRule(FontStyle.bold, d, b)),
            }),
      });
  _check(_toJson(actual.getThemeTrieElement()), _toJson(root));
}

/// 1:1: `test('rules are inherited 2')`
void testRulesAreInherited2() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('', -1, FontStyle.notSet, 'F8F8F2', '272822'),
        ParsedTokenThemeRule('var', -1, FontStyle.bold, 'ff0000', null),
        ParsedTokenThemeRule('var.identifier', -1, FontStyle.notSet, '00ff00', null),
        ParsedTokenThemeRule('constant', 4, FontStyle.italic, '100000', null),
        ParsedTokenThemeRule('constant.numeric', 5, FontStyle.notSet, '200000', null),
        ParsedTokenThemeRule('constant.numeric.hex', 6, FontStyle.bold, null, null),
        ParsedTokenThemeRule('constant.numeric.oct', 7,
            FontStyle.bold | FontStyle.italic | FontStyle.underline, null, null),
        ParsedTokenThemeRule('constant.numeric.dec', 8, FontStyle.none, '300000', null),
      ],
      <String>[]);
  final ColorMap colorMap = ColorMap();
  final int a = colorMap.getId('F8F8F2');
  final int b = colorMap.getId('272822');
  final int c = colorMap.getId('100000');
  final int d = colorMap.getId('200000');
  final int e = colorMap.getId('300000');
  final int f = colorMap.getId('ff0000');
  final int g = colorMap.getId('00ff00');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
  final ExternalThemeTrieElement root = ExternalThemeTrieElement(
      ThemeTrieElementRule(FontStyle.none, a, b),
      <String, ExternalThemeTrieElement>{
        'var': ExternalThemeTrieElement(
            ThemeTrieElementRule(FontStyle.bold, f, b),
            <String, ExternalThemeTrieElement>{
              'identifier': ExternalThemeTrieElement(
                  ThemeTrieElementRule(FontStyle.bold, g, b)),
            }),
        'constant': ExternalThemeTrieElement(
            ThemeTrieElementRule(FontStyle.italic, c, b),
            <String, ExternalThemeTrieElement>{
              'numeric': ExternalThemeTrieElement(
                  ThemeTrieElementRule(FontStyle.italic, d, b),
                  <String, ExternalThemeTrieElement>{
                    'hex': ExternalThemeTrieElement(
                        ThemeTrieElementRule(FontStyle.bold, d, b)),
                    'oct': ExternalThemeTrieElement(ThemeTrieElementRule(
                        FontStyle.bold |
                            FontStyle.italic |
                            FontStyle.underline,
                        d,
                        b)),
                    'dec': ExternalThemeTrieElement(
                        ThemeTrieElementRule(FontStyle.none, e, b)),
                  }),
            }),
      });
  _check(_toJson(actual.getThemeTrieElement()), _toJson(root));
}

/// 1:1: `test('custom colors are first in color map')`
void testCustomColorsAreFirstInColorMap() {
  final TokenTheme actual = TokenTheme.createFromParsedTokenTheme(
      <ParsedTokenThemeRule>[
        ParsedTokenThemeRule('var', -1, FontStyle.notSet, 'F8F8F2', null)
      ],
      <String>['000000', 'FFFFFF', '0F0F0F']);
  final ColorMap colorMap = ColorMap();
  colorMap.getId('000000');
  colorMap.getId('FFFFFF');
  colorMap.getId('0F0F0F');
  colorMap.getId('F8F8F2');
  _check(_colorMapJson(actual.getColorMap()), _colorMapJson(colorMap.getColorMap()));
}

// ---------------------------------------------------------------------------
// runAll
// ---------------------------------------------------------------------------

/// Executes every mocha suite in source order.
void runAll() {
  // suite('Token font CSS')
  testPreservesFontListsAndDeduplicatesRules();
  testSanitizesFontFamilies();
  testIgnoresNonpositiveAndNonfiniteSizes();
  testDoesNotInterpolateNonnumericFontSizes();

  // suite('Token theme matching')
  testGivesHigherPriorityToDeeperMatches();
  testCanMatch();

  // suite('Token theme parsing')
  testCanParse();

  // suite('Token theme resolving')
  testStrcmpWorks();
  testAlwaysHasDefaults();
  testRespectsIncomingDefaults1();
  testRespectsIncomingDefaults2();
  testRespectsIncomingDefaults3();
  testRespectsIncomingDefaults4();
  testRespectsIncomingDefaults5();
  testCanMergeIncomingDefaults();
  testDefaultsAreInherited();
  testSameRulesGetMerged();
  testRulesAreInherited1();
  testRulesAreInherited2();
  testCustomColorsAreFirstInColorMap();
}
