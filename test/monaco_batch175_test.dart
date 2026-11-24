// Truth-driven tests for batch175:
//   platform/theme/browser/iconsStyleSheet.ts
//   platform/theme/test/common/testThemeService.ts
// Truth source: tool/ts2dart/batch175_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/color.dart' as color;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/themables.dart' as themables;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/theme/browser/iconsStyleSheet.dart' as iss;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/iconRegistry.dart' as icons;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart' as theme;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart' as ts;
import 'package:semi_design_flutter/src/monaco/platform/theme/test/common/testThemeService.dart' as testing;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch175_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> get issTruth =>
    truth['iconsStyleSheet'] as Map<String, dynamic>;
Map<String, dynamic> get svcTruth =>
    truth['testThemeService'] as Map<String, dynamic>;

class _FontContribution implements icons.IconFontContribution {
  _FontContribution(this.id, this.definition);
  @override
  final String id;
  @override
  final icons.IconFontDefinition definition;
}

class _FakeIconRegistry implements icons.IIconRegistry {
  _FakeIconRegistry(this._icons);
  final event.Emitter<void> _onDidChange = event.Emitter<void>();
  final List<icons.IconContribution> _icons;

  @override
  event.Event<void> get onDidChange => _onDidChange.event;
  @override
  List<icons.IconContribution> getIcons() => _icons;
  @override
  icons.IconContribution? getIcon(String id) {
    for (final icons.IconContribution c in _icons) {
      if (c.id == id) return c;
    }
    return null;
  }

  void fire() => _onDidChange.fire(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeProductTheme implements ts.IProductIconTheme {
  _FakeProductTheme(this._definition);
  final icons.IconDefinition? Function(icons.IconContribution) _definition;
  @override
  icons.IconDefinition? getIcon(icons.IconContribution c) => _definition(c);
}

class _FakeThemeService implements ts.IThemeServiceType {
  _FakeThemeService(this._productTheme);
  final ts.IProductIconTheme _productTheme;
  final event.Emitter<ts.IProductIconTheme> _onProduct =
      event.Emitter<ts.IProductIconTheme>();

  @override
  ts.IProductIconTheme getProductIconTheme() => _productTheme;
  @override
  event.Event<ts.IProductIconTheme> get onDidProductIconThemeChange =>
      _onProduct.event;
  void fireProduct() => _onProduct.fire(_productTheme);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

late _FakeIconRegistry _registry;
late List<icons.IconContribution> contributions;
late icons.IconDefinition defFile;
late icons.IconDefinition defFolder;
late icons.IconDefinition defPlain;
late icons.IconDefinition customDef;

void main() {
  setUpAll(() {
    final icons.IconFontDefinition alphaDefinition =
        icons.IconFontDefinitionCarrier(
      weight: 'bold',
      style: 'italic',
      src: <icons.IconFontSource>[
        icons.IconFontSource(
            location: URI.parse('https://example.com/alpha'), format: 'woff2'),
        icons.IconFontSource(location: URI.parse('https://example.com/beta'), format: 'woff'),
      ],
    );
    final icons.IconFontContribution alphaFont =
        _FontContribution('alphaFont', alphaDefinition);
    defFile = icons.IconDefinitionCarrier(
        font: alphaFont, fontCharacter: '\uEA01');
    defFolder = icons.IconDefinitionCarrier(fontCharacter: '\uEA02');
    defPlain = icons.IconDefinitionCarrier(fontCharacter: '\uEA03');
    customDef = icons.IconDefinitionCarrier(
      font: _FontContribution(
          'customFont',
          icons.IconFontDefinitionCarrier(src: <icons.IconFontSource>[
            icons.IconFontSource(
                location: URI.parse('https://example.com/gamma'), format: 'truetype'),
          ])),
      fontCharacter: '\uEAFF',
    );
    contributions = <icons.IconContribution>[
      icons.IconContributionCarrier(id: 'file', defaults: defFile),
      icons.IconContributionCarrier(id: 'folder', defaults: defFolder),
      icons.IconContributionCarrier(
          id: 'alias', defaults: themables.ThemeIcon.fromId('file')),
      icons.IconContributionCarrier(
          id: 'missingRef', defaults: themables.ThemeIcon.fromId('doesNotExist')),
      icons.IconContributionCarrier(id: 'plain', defaults: defPlain),
    ];
    _registry = _FakeIconRegistry(contributions);
    iss.iconRegistryProvider = () => _registry;
  });

  group('iconsStyleSheet.ts (truth-driven)', () {
    test('exports match truth', () {
      expect(<dynamic>[
        'UnthemedProductIconTheme',
        'getIconsStyleSheet',
      ], issTruth['exports']);
      // Referencing both keeps lazy initialization honest.
      expect(iss.UnthemedProductIconTheme(), isNotNull);
      expect(iss.getIconsStyleSheet(null), isNotNull);
    });

    test('UnthemedProductIconTheme resolves defaults and chains', () {
      final iss.UnthemedProductIconTheme unthemed =
          iss.UnthemedProductIconTheme();
      final Map<String, dynamic> e =
          issTruth['unthemed'] as Map<String, dynamic>;
      final icons.IconDefinition? plain =
          unthemed.getIcon(contributions[4]);
      expect(plain?.fontCharacter, (e['plain'] as Map<String, dynamic>)['fontCharacter']);
      final icons.IconDefinition? chained =
          unthemed.getIcon(contributions[2]);
      expect(chained?.fontCharacter,
          (e['chained'] as Map<String, dynamic>)['fontCharacter']);
      expect((chained?.font as icons.IconFontContribution).id,
          (e['chained'] as Map<String, dynamic>)['font']);
      expect(unthemed.getIcon(contributions[3]), isNull);
      expect(e['missing'], isNull);
    });

    test('getCSS without themeService matches executed TS string', () {
      expect(iss.getIconsStyleSheet(null).getCSS(), issTruth['cssNoTheme']);
    });

    test('getCSS with product icon theme matches executed TS string', () {
      final _FakeThemeService service = _FakeThemeService(
          _FakeProductTheme((icons.IconContribution c) =>
              c.id == 'file' ? customDef : null));
      expect(iss.getIconsStyleSheet(service).getCSS(), issTruth['cssWithTheme']);
    });

    test('onDidChange fires for registry + theme changes, then stops after dispose', () {
      final _FakeThemeService service = _FakeThemeService(
          _FakeProductTheme((icons.IconContribution c) => null));
      final iss.IIconsStyleSheet style = iss.getIconsStyleSheet(service);
      final Map<String, dynamic> e = issTruth['events'] as Map<String, dynamic>;
      int a = 0;
      int b = 0;
      style.onDidChange((dynamic _) => a++);
      style.onDidChange((dynamic _) => b++);
      _registry.fire();
      service.fireProduct();
      expect(a, e['registry'] + e['theme']);
      expect(b, e['registry'] + e['theme']);
      style.dispose();
      _registry.fire();
      service.fireProduct();
      expect(a, e['registry'] + e['theme'] + (e['afterDispose'] as int) * 2);
      expect(b, a);
    });
  });

  group('testThemeService.ts (truth-driven)', () {
    test('exports match truth', () {
      expect(<dynamic>['TestColorTheme', 'TestThemeService'],
          svcTruth['exports']);
    });

    test('TestColorTheme matches executed TS behavior', () {
      final Map<String, dynamic> e =
          svcTruth['colorTheme'] as Map<String, dynamic>;
      final testing.TestColorTheme t =
          testing.TestColorTheme(<String, String>{'known': '#ff0000ff'});
      expect(t.label, e['label']);
      expect(t.type.value, e['type']);
      expect(t.semanticHighlighting, e['semanticHighlighting']);
      final color.Color? known = t.getColor('known');
      expect(<num>[known!.rgba.r, known.rgba.g, known.rgba.b, known.rgba.a],
          <num>[
            (e['known'] as Map<String, dynamic>)['r'] as num,
            (e['known'] as Map<String, dynamic>)['g'] as num,
            (e['known'] as Map<String, dynamic>)['b'] as num,
            (e['known'] as Map<String, dynamic>)['a'] as num,
          ]);
      expect(t.getColor('unknown'), isNull);
      expect(e['unknown'], isNull);
      expect(t.getTokenStyleMetadata('type', <String>[], 'ts'), isNull);
      expect(e['tokenStyle'], isNull);
      expect(t.tokenColorMap, e['tokenColorMap']);
      expect(t.tokenFontMap.isEmpty, (e['tokenFontMap'] as List<dynamic>).isEmpty);
      expect(() => t.defines('known'), throwsA(isA<StateError>()));
      expect(svcTruth['definesThrows'], true);
    });

    test('TestThemeService defaults and setters fire events like truth', () {
      final Map<String, dynamic> d =
          svcTruth['defaults'] as Map<String, dynamic>;
      final Map<String, dynamic> after =
          svcTruth['afterChanges'] as Map<String, dynamic>;
      final testing.TestThemeService svc = testing.TestThemeService();
      expect(svc.getColorTheme().label, d['colorLabel']);
      expect(<bool>[
        svc.getFileIconTheme().hasFileIcons,
        svc.getFileIconTheme().hasFolderIcons,
        svc.getFileIconTheme().hidesExplorerArrows,
      ], d['fileIcons']);
      expect(svc.getProductIconTheme().getIcon(contributions[0]), isNull);
      expect(d['productIcon'], isNull);

      final List<List<dynamic>> events = <List<dynamic>>[];
      svc.onDidColorThemeChange((dynamic t) =>
          events.add(<dynamic>['color', (t as ts.IColorTheme).label]));
      svc.onDidFileIconThemeChange((dynamic t) => events.add(<dynamic>[
            'file',
            (t as ts.IFileIconTheme).hasFileIcons,
          ]));
      svc.onDidProductIconThemeChange((dynamic _) {});
      svc.setTheme(testing.TestColorTheme(<String, String>{}, theme.ColorScheme.light));
      svc.setFileIconTheme(_FakeFileIcons());
      expect(svc.getColorTheme().label, after['colorLabel']);
      expect(svc.getColorTheme().type.value, after['colorType']);
      expect(<bool>[
        svc.getFileIconTheme().hasFileIcons,
        svc.getFileIconTheme().hasFolderIcons,
        svc.getFileIconTheme().hidesExplorerArrows,
      ], after['fileIcons']);
      // The third truth event uses a private emitter in TS; Dart cannot fire it
      // from another library, but listener registration is verified above.
      expect(events, (after['events'] as List<dynamic>).sublist(0, 2));
    });

    test('custom constructor arguments are preserved', () {
      final Map<String, dynamic> e =
          svcTruth['customCtor'] as Map<String, dynamic>;
      final testing.TestColorTheme t = testing.TestColorTheme(
          <String, String>{'a': '#00ff00'}, theme.ColorScheme.dark, true);
      expect(t.label, e['label']);
      expect(t.type.value, e['type']);
      expect(t.semanticHighlighting, e['semanticHighlighting']);
      expect(t.getColor('a')!.rgba.g, (e['color'] as Map<String, dynamic>)['g']);
    });
  });
}

class _FakeFileIcons implements ts.IFileIconTheme {
  @override
  bool hasFileIcons = true;
  @override
  bool hasFolderIcons = false;
  @override
  bool hidesExplorerArrows = true;
}
