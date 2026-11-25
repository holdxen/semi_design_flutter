// 1:1 replay of `editor/standalone/browser/standaloneThemeService.ts` (436 lines).
//
// `tool/ts2dart/_batch246_truth.cjs` executes the real TypeScript module with
// only the browser surface stubbed (`dom.isInShadowDOM`,
// `domStylesheets.createStyleSheet`, `window.mainWindow`); the color registry,
// theming registry, token theme and icon style sheet are all real.
//
// The service scenarios replay the harness **in the same order**, because the
// observable values are sequence-sensitive (event counts, participant calls,
// theme fallbacks). Three truth fields are environment-bound and therefore
// asserted structurally instead of numerically:
//   - generated CSS byte lengths depend on how many colors are registered (the
//     Dart color modules register per identifier, lazily);
//   - cumulative style-sheet counters are harness artifacts, replaced by the
//     increments observed on the document;
//   - harness-private reads (`_themeCSS`, `_styleElements`) are replaced by
//     their observable effects (style elements, tokenization color map).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/browser.dart' as browser;
import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/window.dart' show mainWindow;
import '../lib/src/monaco/base/common/color.dart' show Color;
import '../lib/src/monaco/editor/common/languages/supports/tokenization.dart'
    show ITokenThemeRule;
import '../lib/src/monaco/editor/common/languages.dart' as languages;
import '../lib/src/monaco/editor/standalone/browser/standaloneThemeService.dart'
    as themeService;
import '../lib/src/monaco/editor/standalone/common/standaloneTheme.dart'
    show IStandaloneThemeData;
import '../lib/src/monaco/platform/theme/browser/iconsStyleSheet.dart'
    show UnthemedProductIconTheme;
import '../lib/src/monaco/platform/theme/common/colors/editorColors.dart'
    show editorBackground, editorForeground, editorSelectionBackground;
import '../lib/src/monaco/platform/theme/common/themeService.dart'
    show registerThemingParticipant;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch246_truth.json').readAsStringSync()));

IStandaloneThemeData _data({
  required String base,
  required bool inherit,
  List<Map<String, String>> rules = const <Map<String, String>>[],
  Map<String, String> colors = const <String, String>{},
  List<String>? encodedTokensColors,
}) {
  return IStandaloneThemeData(
    base: base,
    inherit: inherit,
    rules: <ITokenThemeRule>[
      for (final rule in rules)
        ITokenThemeRule(
          token: rule['token']!,
          foreground: rule['foreground'],
          background: rule['background'],
          fontStyle: rule['fontStyle'],
        ),
    ],
    encodedTokensColors: encodedTokensColors,
    colors: colors,
  );
}

Map<String, Object?> _projectTheme(Object? theme) {
  final t = theme as themeService.StandaloneTheme;
  return <String, Object?>{
    'id': t.id,
    'themeName': t.themeName,
    'label': t.label,
    'base': t.base,
    'type': t.type.value,
    'definesEditorBackground': t.defines('editor.background'),
    'tokenColorMapLength': t.tokenColorMap.length,
    'tokenFontMapLength': t.tokenFontMap.length,
    'semanticHighlighting': t.semanticHighlighting,
  };
}

Map<String, Object?> _tokenStyle(Object? style) {
  final s = style as dynamic;
  return <String, Object?>{
    'foreground': s.foreground,
    'italic': s.italic,
    'bold': s.bold,
    'underline': s.underline,
    'strikethrough': s.strikethrough,
  };
}

class _FakeMediaQueryList implements browser.MediaQueryList {
  _FakeMediaQueryList(this.matches);

  bool matches;

  @override
  void addEventListener(
      String type, void Function(browser.MediaQueryListEvent ev) cb) {}
}

String _themeId(themeService.StandaloneThemeService service) =>
    (service.getColorTheme() as themeService.StandaloneTheme).id;

List<dom.DomElement> _styleElementsIn(dom.DomNode parent) => parent.childNodes
    .whereType<dom.DomElement>()
    .where((e) => e.className == 'monaco-colors')
    .toList();

void main() {
  final truth = _truth();
  final mediaLists = <String, _FakeMediaQueryList>{};

  setUpAll(() {
    // The Dart color registry registers per identifier, on first touch; the
    // truth reads defaults for these three, so register them explicitly.
    expect(editorBackground, 'editor.background');
    expect(editorForeground, 'editor.foreground');
    expect(editorSelectionBackground, 'editor.selectionBackground');

    browser.matchMediaProvider = (Object targetWindow, String query) =>
        mediaLists.putIfAbsent(query, () => _FakeMediaQueryList(false));
  });

  group('constants and builtin helpers', () {
    test('theme-name constants', () {
      expect(<String, String>{
        'VS_LIGHT_THEME_NAME': themeService.VS_LIGHT_THEME_NAME,
        'VS_DARK_THEME_NAME': themeService.VS_DARK_THEME_NAME,
        'HC_BLACK_THEME_NAME': themeService.HC_BLACK_THEME_NAME,
        'HC_LIGHT_THEME_NAME': themeService.HC_LIGHT_THEME_NAME,
      }, _map(truth['constants']));
    });

    test('isBuiltinTheme matrix', () {
      final expected = <String, bool>{
        for (final entry in (truth['isBuiltinTheme'] as List))
          (entry as List)[0] as String: entry[1] as bool,
      };
      expect(themeService.isBuiltinTheme('vs'), expected['vs']);
      expect(themeService.isBuiltinTheme('vs-dark'), expected['vs-dark']);
      expect(themeService.isBuiltinTheme('hc-black'), expected['hc-black']);
      expect(themeService.isBuiltinTheme('hc-light'), expected['hc-light']);
      expect(themeService.isBuiltinTheme('custom'), expected['custom']);
      expect(themeService.isBuiltinTheme(''), expected['empty']);
    });

    test('getBuiltinRules returns the four shipped themes', () {
      final expected = _map(truth['builtinRules']);
      for (final entry in <String, String>{
        'vs': 'vs',
        'vsDark': 'vs-dark',
        'hcBlack': 'hc-black',
        'hcLight': 'hc-light',
      }.entries) {
        final data = themeService.getBuiltinRules(entry.value);
        expect(<String, Object?>{
          'base': data.base,
          'inherit': data.inherit,
        }, _map(expected[entry.key]));
      }
    });
  });

  group('StandaloneTheme', () {
    final customData = _data(
      base: 'vs',
      inherit: false,
      rules: <Map<String, String>>[
        <String, String>{'token': 'keyword', 'foreground': '0000FF'},
      ],
      colors: <String, String>{
        'editor.foreground': '#123456',
        'editor.background': '#654321',
      },
    );

    test('id / themeName / label / type follow the TS rules', () {
      final expected = _map(truth['themeIdentity']);
      final themes = <String, themeService.StandaloneTheme>{
        'named': themeService.StandaloneTheme('my-theme', customData),
        'builtinNamed': themeService.StandaloneTheme(
            'vs-dark', _data(base: 'vs-dark', inherit: false)),
        'unnamed': themeService.StandaloneTheme(
            '', _data(base: 'hc-light', inherit: false)),
      };
      for (final entry in themes.entries) {
        expect(_projectTheme(entry.value), _map(expected[entry.key]),
            reason: entry.key);
      }
    });

    test('type maps each base to its ColorScheme', () {
      final expected = _map(truth['themeTypes']);
      final themes = <String, themeService.StandaloneTheme>{
        'vs': themeService.StandaloneTheme('t1', _data(base: 'vs', inherit: false)),
        'vsDark': themeService.StandaloneTheme(
            't2', _data(base: 'vs-dark', inherit: false)),
        'hcBlack': themeService.StandaloneTheme(
            't3', _data(base: 'hc-black', inherit: false)),
        'hcLight': themeService.StandaloneTheme(
            't4', _data(base: 'hc-light', inherit: false)),
      };
      for (final entry in themes.entries) {
        expect(entry.value.type.value, expected[entry.key], reason: entry.key);
      }
    });

    test('getColor / defines / default color caching', () {
      final theme = themeService.StandaloneTheme('my-theme', customData);
      final expected = _map(truth['namedTheme']);
      expect(theme.getColor('editor.foreground').toString(),
          expected['definedForeground']);
      expect(theme.getColor('editor.background').toString(),
          expected['definedBackground']);
      expect(theme.getColor('editor.selectionBackground').toString(),
          expected['missingWithDefault']);
      expect(theme.getColor('editor.selectionBackground', false),
          expected['missingWithoutDefault']);
      expect(theme.defines('editor.foreground'), expected['definesForeground']);
      expect(theme.defines('editor.selectionBackground'),
          expected['definesSelection']);
      expect(theme.getColor('editor.selectionBackground').toString(),
          expected['defaultColorCached']);
    });

    test('inherit merges base colors and token rules', () {
      final theme = themeService.StandaloneTheme(
          'inherit-theme',
          _data(
            base: 'vs-dark',
            inherit: true,
            rules: <Map<String, String>>[
              <String, String>{'token': 'string', 'foreground': '00FF00'},
            ],
            colors: <String, String>{'editor.foreground': '#010203'},
          ));
      final expected = _map(truth['inheritedTheme']);
      expect(theme.getColor('editor.foreground').toString(),
          expected['foreground']);
      expect(theme.getColor('editor.background').toString(),
          expected['baseBackground']);
      expect(theme.defines('editor.background'), expected['definesBaseColor']);
      expect(theme.tokenTheme.getColorMap().length, expected['tokenMapLength']);
      expect(
          theme.tokenTheme
              .getColorMap()
              .take(3)
              .map((c) => c?.toString())
              .toList(),
          expected['tokenMapFirst']);
    });

    test('tokenFontMap / tokenColorMap stay empty; semanticHighlighting false',
        () {
      final theme = themeService.StandaloneTheme('my-theme', customData);
      expect(theme.tokenColorMap, isEmpty);
      expect(theme.tokenFontMap, isEmpty);
      expect(theme.semanticHighlighting, isFalse);
    });

    test('getTokenStyleMetadata resolves rules like the TS trie', () {
      final theme = themeService.StandaloneTheme('my-theme', customData);
      final emptyRules = themeService.StandaloneTheme(
          'empty-rules', _data(base: 'vs', inherit: false));
      final expected = _map(truth['tokenTheme']);
      final actual = <String, Map<String, Object?>>{
        'keywordStyle': _tokenStyle(
            theme.getTokenStyleMetadata('keyword', <String>[], 'plaintext')),
        'keywordModifierStyle': _tokenStyle(theme.getTokenStyleMetadata(
            'keyword', <String>['readonly'], 'plaintext')),
        'unknownStyle': _tokenStyle(
            theme.getTokenStyleMetadata('nosuchtoken', <String>[], 'plaintext')),
        'plainStyle': _tokenStyle(
            emptyRules.getTokenStyleMetadata('keyword', <String>[], 'plaintext')),
      };
      for (final entry in actual.entries) {
        expect(entry.value, _map(expected[entry.key]), reason: entry.key);
      }
    });

    test('notifyBaseUpdated is a no-op unless the theme inherits', () {
      final inherited = themeService.StandaloneTheme(
          'n1',
          _data(
            base: 'vs',
            inherit: true,
            colors: <String, String>{'editor.foreground': '#111111'},
          ));
      final expected = _map(truth['notifyBaseUpdated']);
      expect(inherited.getColor('editor.foreground').toString(),
          expected['beforeNotify']);
      inherited.themeData.colors['editor.foreground'] = '#222222';
      // still cached: no notification yet
      expect(inherited.getColor('editor.foreground').toString(),
          expected['staleColor']);
      inherited.notifyBaseUpdated();
      expect(inherited.getColor('editor.foreground').toString(),
          expected['freshColor']);

      final fixed = themeService.StandaloneTheme(
          'n2',
          _data(
            base: 'vs',
            inherit: false,
            colors: <String, String>{'editor.foreground': '#111111'},
          ));
      // inherit=false -> notifyBaseUpdated is a no-op, but the harness never
      // populated the cache before mutating, so a fresh read sees the mutation.
      fixed.themeData.colors['editor.foreground'] = '#222222';
      fixed.notifyBaseUpdated();
      expect(fixed.getColor('editor.foreground').toString(),
          expected['fixedThemeKeepsCache']);
    });
  });

  // Mirrors the harness call sequence exactly (event counts are cumulative).
  group('StandaloneThemeService', () {
    test('mirrors the truth scenario sequence', () {
      mediaLists.clear();
      final participantCalls = <String>[];
      registerThemingParticipant((theme, collector, environment) {
        participantCalls.add(theme.label);
        collector.addRule('.participant-rule { color: red; }');
        collector.addRule('.participant-rule { color: red; }');
      });

      final service = themeService.StandaloneThemeService();
      final colorEvents = <String>[];
      final fileIconEvents = <bool>[];
      final productIconEvents = <bool>[];
      service.onDidColorThemeChange((t) => colorEvents.add(t.id));
      service.onDidFileIconThemeChange(
          (t) => fileIconEvents.add(t.hasFileIcons));
      service.onDidProductIconThemeChange((t) => productIconEvents.add(true));

      // --- initial state
      final initial = _map(truth['serviceInitial']);
      expect(<String, Object?>{
        'themeId': _themeId(service),
        'themeName': service.getColorTheme().themeName,
        'fileIconTheme': <String, Object?>{
          'hasFileIcons': service.getFileIconTheme().hasFileIcons,
          'hasFolderIcons': service.getFileIconTheme().hasFolderIcons,
          'hidesExplorerArrows': service.getFileIconTheme().hidesExplorerArrows,
        },
        'productIconThemeIsBuiltIn':
            service.getProductIconTheme() is UnthemedProductIconTheme,
      }, <String, Object?>{
        'themeId': initial['themeId'],
        'themeName': initial['themeName'],
        'fileIconTheme': initial['fileIconTheme'],
        'productIconThemeIsBuiltIn': initial['productIconThemeIsBuiltIn'],
      });

      // --- setTheme
      service.setTheme('vs-dark');
      final afterDark = _map(truth['serviceAfterDark']);
      expect(_themeId(service), afterDark['themeId']);
      expect(colorEvents, afterDark['colorEvents']);
      expect(participantCalls, afterDark['participantCalls']);

      service.setTheme('vs-dark');
      expect(colorEvents, _map(truth['serviceIdempotentSet'])['colorEvents']);

      service.setTheme('no-such-theme');
      final fallback = _map(truth['serviceFallback']);
      expect(_themeId(service), fallback['themeId']);
      expect(colorEvents, fallback['colorEvents']);

      // --- defineTheme validation
      final errors = _map(truth['defineThemeErrors']);
      expect(
          () => service.defineTheme(
              'bad name', _data(base: 'vs', inherit: false)),
          throwsA(isA<StateError>()
              .having((e) => e.message, 'message', errors['illegalName'])));
      expect(
          () => service.defineTheme(
              'good-name', _data(base: 'nope', inherit: false)),
          throwsA(isA<StateError>()
              .having((e) => e.message, 'message', errors['illegalBase'])));

      // --- custom theme + CSS generation
      service.defineTheme(
          'custom-one',
          _data(
            base: 'vs',
            inherit: true,
            rules: <Map<String, String>>[
              <String, String>{
                'token': 'keyword',
                'foreground': 'FF0000',
                'fontStyle': 'bold',
              },
            ],
            colors: <String, String>{'editor.background': '#101010'},
          ));
      service.setTheme('custom-one');
      final custom = _map(truth['customTheme']);
      expect(_themeId(service), custom['themeId']);
      expect(service.getColorTheme().label, custom['label']);
      expect(colorEvents, custom['colorEvents']);

      // --- registerEditorContainer: regular path (only once)
      final beforeRegular = _styleElementsIn(dom.mainDocument.head).length;
      service.registerEditorContainer(dom.DomElement('div'));
      final regular = _map(truth['registerRegular']);
      expect(_styleElementsIn(dom.mainDocument.head).length - beforeRegular,
          regular['added']);
      final regularStyle = _styleElementsIn(dom.mainDocument.head).last;
      expect(regularStyle.className, regular['lastClassName']);
      final css = regularStyle.textContent;

      expect(css.contains('.participant-rule { color: red; }'),
          custom['cssHasParticipantRule']);
      expect(RegExp(r'\.participant-rule').allMatches(css).length,
          custom['participantRuleCount']);
      expect(css.contains('--vscode-editor-background: #101010;'),
          custom['cssHasColorVariable']);
      expect(css.contains('forced-color-adjust: none;'),
          custom['cssHasForcedColorAdjust']);
      expect(css.contains('mtk'), custom['cssHasTokensRule']);

      final beforeSecond = _styleElementsIn(dom.mainDocument.head).length;
      service.registerEditorContainer(dom.DomElement('div'));
      expect(_styleElementsIn(dom.mainDocument.head).length - beforeSecond,
          _map(truth['registerRegularSecondTime'])['added']);

      // --- registerEditorContainer: shadow DOM path
      final host = dom.DomElement('div');
      final shadowRoot = dom.DomShadowRoot(host);
      shadowRoot.appendChild(host); // `getShadowRoot` walks parent nodes
      final beforeShadow = _styleElementsIn(host).length;
      final shadowDisposable = service.registerEditorContainer(host);
      expect(_styleElementsIn(host).length - beforeShadow, 1);
      shadowDisposable.dispose();
      // disposal untracks the element; the DOM node itself stays.
      expect(_styleElementsIn(host).length, 1);

      // --- setColorMapOverride
      final override = <Color>[
        Color.fromHex('#abcdef'),
        Color.fromHex('#123456'),
      ];
      service.setColorMapOverride(override);
      final mapOverride = _map(truth['colorMapOverride']);
      expect(mapOverride['applied'], isTrue);
      expect(colorEvents.length, mapOverride['events']);
      expect(languages.TokenizationRegistry.getColorMap(), same(override));

      service.setColorMapOverride(null);
      expect(languages.TokenizationRegistry.getColorMap(),
          service.getColorTheme().tokenTheme.getColorMap());

      // --- auto-detect high contrast
      const forcedColors = '(forced-colors: active)';
      browser.matchMediaProvider!(mainWindow, forcedColors);
      mediaLists[forcedColors]!.matches = true;
      service.setTheme('vs');
      service.setAutoDetectHighContrast(true);
      expect(_themeId(service),
          _map(truth['autoDetectOn'])['themeId']);

      service.setTheme('vs');
      mediaLists[forcedColors]!.matches = false;
      expect(_themeId(service),
          _map(truth['autoDetectOffBackToLight'])['themeId']);

      service.setAutoDetectHighContrast(false);
      mediaLists[forcedColors]!.matches = true;
      service.setTheme('vs-dark');
      expect(_themeId(service),
          _map(truth['autoDetectDisabled'])['themeId']);

      // --- event plumbing
      final events = _map(truth['events']);
      expect(colorEvents.length, events['colorEventCount']);
      expect(colorEvents.last, events['lastColorEvent']);
      expect(fileIconEvents, events['fileIconEvents']);
      expect(productIconEvents, events['productIconEvents']);
    });
  });
}
