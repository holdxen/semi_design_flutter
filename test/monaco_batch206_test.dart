// Truth replay for batch206:
//   `editor/common/languages/supports/tokenization.ts`
//
// Expectations come from `tool/ts2dart/batch206_truth.json`, produced by
// `tool/ts2dart/_batch206_truth.cjs` (the real transpiled source). The
// scenarios follow the official
// `editor/test/common/modes/supports/tokenization.test.ts` cases and extend
// them with the CSS generation exports.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/platform.dart' as platform;
import '../lib/src/monaco/editor/common/languages/supports/tokenization.dart'
    as tok;
import '../lib/src/monaco/platform/theme/common/themeService.dart'
    show IFontTokenOptions;

/// The truth is recorded per host platform because `sanitizeFontFamily`
/// falls back to the platform default family; pick the run for this machine.
Map<String, dynamic> _truth() {
  final Map<String, dynamic> variants = _map(jsonDecode(
      File('tool/ts2dart/batch206_truth.json').readAsStringSync()));
  final String key = platform.isMacintosh
      ? 'mac'
      : (platform.isWindows ? 'win' : 'linux');
  return _map(variants[key]);
}

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, Object?> _externalToJson(Object? element) {
  final tok.ExternalThemeTrieElement node =
      element as tok.ExternalThemeTrieElement;
  return <String, Object?>{
    'metadata': node.mainRule.metadata,
    'children': <String, Object?>{
      for (final MapEntry<String, tok.ExternalThemeTrieElement> entry
          in node.children.entries)
        entry.key: _externalToJson(entry.value),
    },
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('parseTokenTheme', () {
    final List<tok.ParsedTokenThemeRule> parsed =
        tok.parseTokenTheme(<tok.ITokenThemeRule>[
      tok.ITokenThemeRule(
        token: '',
        fontStyle: 'italic bold',
        foreground: 'FF0000',
        background: '00FF00',
      ),
      tok.ITokenThemeRule(token: 'keyword', fontStyle: 'underline'),
      tok.ITokenThemeRule(token: 'string.quoted'),
      tok.ITokenThemeRule(token: '', foreground: '000000'),
    ]);

    expect(
      parsed
          .map((tok.ParsedTokenThemeRule rule) => <String, Object?>{
                'token': rule.token,
                'index': rule.index,
                'fontStyle': rule.fontStyle,
                'foreground': rule.foreground,
                'background': rule.background,
              })
          .toList(),
      _exp(truth['parsed']),
    );
    expect(tok.parseTokenTheme(<tok.ITokenThemeRule>[]).length,
        _exp(truth['parsedEmpty']));
  });

  test('ColorMap: ids, dedupe and invalid input', () {
    final tok.ColorMap colorMap = tok.ColorMap();
    final List<String?> colors = colorMap
        .getColorMap()
        .map((Object? color) => color == null ? null : '$color')
        .toList();
    final Map<String, dynamic> expected = _map(truth['colorMap']);

    expect(colorMap.getId(null), _exp(expected['nullId']));
    expect(colorMap.getId('FF0000'), _exp(expected['redUpper']));
    expect(colorMap.getId('#ff0000'), _exp(expected['redLower']));
    expect(colorMap.getId('00ff00'), _exp(expected['green']));
    expect(colorMap.getId('11223344'), _exp(expected['withAlpha']));
    expect(
      colorMap
          .getColorMap()
          .map((Object? color) => color == null ? null : '$color')
          .toList(),
      _exp(expected['colors']),
    );
    expect(colors.length, colors.length);
    expect(
      () => tok.ColorMap().getId('XX'),
      throwsA(isA<StateError>()),
    );
    expect(
      () => tok.ColorMap().getId('FFF'),
      throwsA(isA<StateError>()),
    );
  });

  test('TokenTheme: inheritance, matching and trie structure', () {
    final tok.TokenTheme theme = tok.TokenTheme.createFromRawTokenTheme(
      <tok.ITokenThemeRule>[
        tok.ITokenThemeRule(
          token: '',
          fontStyle: 'italic',
          foreground: '000000',
          background: 'FFFFFF',
        ),
        tok.ITokenThemeRule(
            token: 'keyword', fontStyle: 'bold', foreground: 'FF0000'),
        tok.ITokenThemeRule(token: 'keyword.json', foreground: '00FF00'),
        tok.ITokenThemeRule(token: 'string', foreground: '0000FF'),
      ],
      <String>['ABCDEF'],
    );

    final Map<String, dynamic> expected = _map(truth['themeMatch']);
    expect(
      <String, Object?>{
        'keyword': theme.match(1, 'keyword'),
        'keywordJson': theme.match(1, 'keyword.json'),
        'keywordJsonDeep': theme.match(1, 'keyword.json.property'),
        'stringQuoted': theme.match(2, 'string.quoted'),
        'unknown': theme.match(3, 'unknown'),
        'empty': theme.match(4, ''),
        'comment': theme.match(5, 'comment.line'),
        'regex': theme.match(6, 'regex'),
        'regexp': theme.match(7, 'regexp'),
        'cacheRepeat': theme.match(1, 'keyword'),
        'colorMapSize': theme.getColorMap().length,
        'colorMapFirst': '${theme.getColorMap()[1]}',
      },
      _exp(expected),
    );

    expect(_externalToJson(theme.getThemeTrieElement()),
        _exp(truth['themeTrie']));

    final Map<String, dynamic> rules = _map(truth['matchRule']);
    expect(theme.matchRule('keyword').metadata, _exp(rules['keyword']));
    expect(theme.matchRule('keyword.json').metadata, _exp(rules['keywordJson']));
    expect(theme.matchRule('').metadata, _exp(rules['empty']));
  });

  test('toStandardTokenType / strcmp', () {
    expect(
      <String, Object?>{
        for (final String token in <String>[
          'comment',
          'string.quoted',
          'regex',
          'regexp',
          'keyword',
          'my-comment-line',
          'regexes',
        ])
          token: tok.toStandardTokenType(token),
      },
      _exp(<String, Object?>{
        for (final Map<String, Object?> entry
            in (truth['standardTokenTypes'] as List).cast<Map<String, Object?>>())
          entry['token'] as String: entry['type'],
      }),
    );

    expect(
      <String, Object?>{
        'less': tok.strcmp('a', 'b'),
        'greater': tok.strcmp('b', 'a'),
        'equal': tok.strcmp('a', 'a'),
        'prefix': tok.strcmp('ab', 'a'),
      },
      _exp(truth['strcmp']),
    );
  });

  test('CSS generation', () {
    final tok.TokenTheme theme = tok.TokenTheme.createFromRawTokenTheme(
      <tok.ITokenThemeRule>[
        tok.ITokenThemeRule(
          token: '',
          fontStyle: 'italic',
          foreground: '000000',
          background: 'FFFFFF',
        ),
        tok.ITokenThemeRule(
            token: 'keyword', fontStyle: 'bold', foreground: 'FF0000'),
        tok.ITokenThemeRule(token: 'keyword.json', foreground: '00FF00'),
        tok.ITokenThemeRule(token: 'string', foreground: '0000FF'),
      ],
      <String>['ABCDEF'],
    );

    expect(tok.generateTokensCSSForColorMap(theme.getColorMap()),
        _exp(truth['cssForColorMap']));

    final IFontTokenOptions empty = IFontTokenOptions();
    final IFontTokenOptions fira = IFontTokenOptions()
      ..fontFamily = 'Fira Code'
      ..fontSizeMultiplier = 1.5;
    final IFontTokenOptions bad = IFontTokenOptions()
      ..fontFamily = 'bad;family'
      ..fontSizeMultiplier = 0.5;
    final IFontTokenOptions numeric = IFontTokenOptions()
      ..fontSizeMultiplier = 2;

    expect(
      tok.generateTokensCSSForFontMap(<IFontTokenOptions?>[
        null,
        empty,
        fira,
        IFontTokenOptions()
          ..fontFamily = 'Fira Code'
          ..fontSizeMultiplier = 1.5,
        bad,
        numeric,
      ]),
      _exp(truth['cssForFontMap']),
    );

    expect(
      <String>[
        tok.classNameForFontTokenDecorations('Fira Code', 1.5),
        tok.classNameForFontTokenDecorations('', 0),
        tok.classNameForFontTokenDecorations('A B', 2),
        tok.classNameForFontTokenDecorations('  Fira  Code  ', 1),
      ],
      _exp(truth['classNames']),
    );
  });
}