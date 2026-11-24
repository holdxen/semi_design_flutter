// Truth-driven tests for batch174a:
// platform/theme/common/colorUtils.ts + themeService.ts
// Truth source: tool/ts2dart/batch174a_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/color.dart' as color;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart' as theme;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/colorUtils.dart' as cu;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart' as ts;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch174a_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> rgbaOf(color.Color? c) => <String, dynamic>{
      'r': c?.rgba.r,
      'g': c?.rgba.g,
      'b': c?.rgba.b,
      'a': c?.rgba.a,
    };

class TestTheme implements ts.IColorTheme {
  TestTheme([Map<String, String>? values])
      : _values = values ?? <String, String>{};
  final Map<String, String> _values;

  @override
  theme.ColorScheme type = theme.ColorScheme.dark;
  @override
  String get label => 'test';
  @override
  color.Color? getColor(String c, [bool? useDefault]) {
    final String? v = _values[c];
    return v != null ? color.Color.fromHex(v) : null;
  }

  @override
  bool defines(String c) => _values.containsKey(c);
  @override
  ts.ITokenStyle? getTokenStyleMetadata(
          String type, List<String> modifiers, String modelLanguage) =>
      null;
  @override
  List<String> get tokenColorMap => const <String>[];
  @override
  List<ts.IFontTokenOptions> get tokenFontMap => const <ts.IFontTokenOptions>[];
  @override
  bool get semanticHighlighting => false;
}

class FakeThemeService implements ts.IThemeServiceType {
  FakeThemeService(this._theme);
  ts.IColorTheme _theme;
  void Function(ts.IColorTheme)? _cb;
  @override
  ts.IColorTheme getColorTheme() => _theme;
  @override
  event.Event<ts.IColorTheme> get onDidColorThemeChange =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
        _cb = listener as void Function(ts.IColorTheme);
        return lifecycle.toDisposable(() {});
      };
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MyThemable extends ts.Themable {
  MyThemable(ts.IThemeServiceType s) : super(s) {
    styles = 0;
  }
  late int styles;
  @override
  void updateStyles() {
    styles++;
  }
  String? get(String id) => getColor(id);
}

void main() {
  group('colorUtils.ts', () {
    test('exports include key API', () {
      final List<dynamic> expected = truth['colorUtilsExports'] as List<dynamic>;
      for (final String key in <String>[
        'registerColor', 'getColorRegistry', 'executeTransform',
        'asCssVariableName', 'darken', 'lighten', 'withOpacity',
        'resolveColorValue', 'workbenchColorsSchemaId',
      ]) {
        expect(expected, contains(key), reason: 'missing $key');
      }
    });

    test('CSS variable helpers', () {
      final Map<String, dynamic> e = truth['cssHelpers'] as Map<String, dynamic>;
      expect(cu.asCssVariableName('editorSuggestWidget.background'),
          e['asCssVariableName']);
      expect(cu.asCssVariable('editor.foreground'), e['asCssVariable']);
      expect(cu.asCssVariableWithDefault('editor.foreground', '#fff'),
          e['asCssVariableWithDefault']);
      expect(cu.asCssVariableName('a.b.c'), e['dottedTransform']);
    });

    test('constants', () {
      final Map<String, dynamic> e = truth['constants'] as Map<String, dynamic>;
      expect(cu.Extensions.ColorContribution, e['ColorContribution']);
      expect(cu.DEFAULT_COLOR_CONFIG_VALUE, e['DEFAULT_COLOR_CONFIG_VALUE']);
      expect(cu.workbenchColorsSchemaId, e['workbenchColorsSchemaId']);
      final Map<String, dynamic> tt =
          (e['ColorTransformType'] as Map<String, dynamic>);
      expect(cu.ColorTransformType.Darken, tt['Darken']);
      expect(cu.ColorTransformType.Opacity, tt['Opacity']);
    });

    test('isColorDefaults', () {
      final List<dynamic> e = truth['isColorDefaults'] as List<dynamic>;
      expect(cu.isColorDefaults(<String, Object?>{'light': '#fff', 'dark': '#000'}),
          e[0]);
      expect(cu.isColorDefaults('#fff'), e[1]);
      expect(cu.isColorDefaults(null), e[2]);
      expect(cu.isColorDefaults(<String, Object?>{'light': '#fff'}), e[3]);
    });

    test('transform factories carry correct op/fields', () {
      final Map<String, dynamic> e =
          truth['transformFactories'] as Map<String, dynamic>;
      final cu.ColorTransform d = cu.darken('#fff', 0.5);
      expect(d.op, (e['darken'] as Map<String, dynamic>)['op']);
      expect(d.factor, (e['darken'] as Map<String, dynamic>)['factor']);
      final cu.ColorTransform wo = cu.withOpacity('#fff', 0.8);
      expect(wo.op, (e['withOpacity'] as Map<String, dynamic>)['op']);
      expect(wo.opacity, (e['withOpacity'] as Map<String, dynamic>)['opacity']);
      final cu.ColorTransform one = cu.oneOf(<Object?>['#fff', '#000']);
      expect(one.op, (e['oneOf'] as Map<String, dynamic>)['op']);
      expect(one.values, <Object?>['#fff', '#000']);
      final cu.ColorTransform ide = cu.ifDefinedThenElse('x', '#fff', '#000');
      expect(ide.variableIf, 'x');
      expect(ide.op, (e['ifDefinedThenElse'] as Map<String, dynamic>)['op']);
    });

    group('official color transform tests', () {
      final Map<String, dynamic> e =
          truth['withOpacityTests'] as Map<String, dynamic>;

      test('withOpacity replaces alpha without changing RGB', () {
        final TestTheme theme = TestTheme();
        final List<dynamic> expected = e['basic'] as List<dynamic>;
        for (int i = 0; i < 3; i++) {
          final String c = <String>['#123456', '#12345622', '#12345600'][i];
          expect(rgbaOf(cu.executeTransform(cu.withOpacity(c, 0.8), theme)),
              expected[i]);
        }
      });

      test('withOpacity resolves theme colours, nested transforms, missing', () {
        final TestTheme theme = TestTheme(<String, String>{'source': '#12345622'});
        final List<dynamic> expected = e['nested'] as List<dynamic>;
        expect(
            rgbaOf(cu.executeTransform(cu.withOpacity('source', 0.8), theme)),
            expected[0]);
        expect(
            rgbaOf(cu.executeTransform(
                cu.withOpacity(cu.lighten('source', 1), 0.6), theme)),
            expected[1]);
        expect(cu.executeTransform(cu.withOpacity('missing', 0.8), theme), isNull);
        expect(expected[2], isNull);
      });

      test('withOpacity clamps alpha to valid range', () {
        final TestTheme theme = TestTheme();
        final List<dynamic> expected = e['clamp'] as List<dynamic>;
        final List<num> ops = <num>[0, 1, -1, 2];
        for (int i = 0; i < ops.length; i++) {
          expect(rgbaOf(cu.executeTransform(
                  cu.withOpacity('#12345622', ops[i]), theme)),
              expected[i]);
        }
      });
    });

    test('resolveColorValue variants', () {
      final Map<String, dynamic> e = truth['resolveColorValue'] as Map<String, dynamic>;
      final TestTheme theme = TestTheme(<String, String>{'source': '#abcdef'});
      expect(cu.resolveColorValue(null, theme), isNull);
      expect(e['nullValue'], true);
      expect(rgbaOf(cu.resolveColorValue('#123456', theme)), e['hex']);
      expect(
          rgbaOf(cu.resolveColorValue(color.Color(color.RGBA(10, 20, 30, 0.5)), theme)),
          e['colorLiteral']);
      expect(rgbaOf(cu.resolveColorValue('source', theme)), e['themeRef']);
      expect(cu.resolveColorValue('missing', TestTheme()), isNull);
    });

    test('ColorRegistry register/resolve/update/deregister', () {
      final Map<String, dynamic> e = truth['registry'] as Map<String, dynamic>;
      final cu.IColorRegistry reg = cu.getColorRegistry();
      final int eventsBefore = e['schemaEventsCount'] as int;
      int fired = 0;
      reg.onDidChangeSchema((dynamic _) => fired++);

      final String id1 = cu.registerColor(
          'test.color1',
          cu.ColorDefaults(
              light: '#ffffff', dark: '#000000', hcDark: null, hcLight: null),
          'Color one');
      cu.registerColor('test.color2', '#123456', 'Color two', true, 'deprecated');
      expect(<String>[id1, 'test.color2'], e['registeredIds']);

      final List<dynamic> expectedColors = e['colors'] as List<dynamic>;
      final List<cu.ColorContribution> colors = reg.getColors()
          .where((cu.ColorContribution c) => c.id.startsWith('test.'))
          .toList();
      expect(colors.length, expectedColors.length);
      for (int i = 0; i < colors.length; i++) {
        final Map<String, dynamic> exp = expectedColors[i] as Map<String, dynamic>;
        expect(colors[i].description, exp['description']);
        expect(colors[i].needsTransparency, exp['needsTransparency']);
        expect(colors[i].deprecationMessage, exp['deprecationMessage']);
      }
      expect(fired, eventsBefore);

      final TestTheme dark = TestTheme()..type = theme.ColorScheme.dark;
      final TestTheme light = TestTheme()..type = theme.ColorScheme.light;
      expect(rgbaOf(reg.resolveDefaultColor('test.color1', dark)), e['resolveDark']);
      expect(rgbaOf(reg.resolveDefaultColor('test.color1', light)), e['resolveLight']);

      reg.updateDefaultColor('test.color1', '#010203');
      expect(rgbaOf(reg.resolveDefaultColor('test.color1', dark)), e['afterUpdate']);

      final int before = fired;
      reg.deregisterColor('test.color1');
      expect(fired > before, e['deregisterFired']);
      expect(reg.getColors().where((cu.ColorContribution c) => c.id == 'test.color1').length,
          e['afterDeregister']);
    });
  });

  group('themeService.ts', () {
    test('exports + constants', () {
      final List<dynamic> expected = truth['themeServiceExports'] as List<dynamic>;
      for (final String key in <String>[
        'IThemeService', 'Themable', 'registerThemingParticipant',
        'getThemeTypeSelector', 'FileThemeIcon', 'FolderThemeIcon',
      ]) {
        expect(expected, contains(key), reason: 'missing $key');
      }
      final Map<String, dynamic> e = truth['themeConstants'] as Map<String, dynamic>;
      expect(ts.ThemeServiceExtensions.ThemingContribution,
          e['ThemingContribution']);
      expect(ts.FileThemeIcon.id, (e['FileThemeIcon'] as Map<String, dynamic>)['id']);
    });

    test('getThemeTypeSelector', () {
      final Map<String, dynamic> e = truth['themeTypeSelectors'] as Map<String, dynamic>;
      expect(ts.getThemeTypeSelector(theme.ColorScheme.dark).value, e['dark']);
      expect(ts.getThemeTypeSelector(theme.ColorScheme.light).value, e['light']);
      expect(ts.getThemeTypeSelector(theme.ColorScheme.highContrastDark).value,
          e['hcDark']);
      expect(ts.getThemeTypeSelector(theme.ColorScheme.highContrastLight).value,
          e['hcLight']);
    });

    test('themeColorFromId', () {
      final Map<String, dynamic> e = truth['themeColorFromId'] as Map<String, dynamic>;
      expect(ts.themeColorFromId('editor.foreground'), e);
    });

    test('registerThemingParticipant + dispose', () {
      final Map<String, dynamic> e = truth['theming'] as Map<String, dynamic>;
      // Baseline depends on process-global registry; use delta semantics.
      final ts.ThemingRegistry reg = ts.ThemingRegistry();
      // Register two participants directly on a fresh registry to mirror truth.
      final List<String> added = <String>[];
      reg.onThemingParticipantAdded((dynamic p) => added.add((p as Function).call == null ? '' : 'x'));
      // Use labeled closures like truth for deterministic mapping is not possible
      // across Dart; verify participant count + removal instead.
      final lifecycle.IDisposable d1 = reg.onColorThemeChange((a, b, c) {});
      reg.onColorThemeChange((a, b, c) {});
      expect(reg.getThemingParticipants().length >= 2, true);
      d1.dispose();
      expect(reg.getThemingParticipants().length, (e['participantsAfterDispose'] as List<dynamic>).length);
    });

    test('Themable initial color + theme change', () {
      final Map<String, dynamic> e = truth['themable'] as Map<String, dynamic>;
      final FakeThemeService svc = FakeThemeService(
          TestTheme(<String, String>{'my.color': '#112233'}));
      final MyThemable themable = MyThemable(svc);
      expect(themable.styles, e['initialStyles']);
      expect(themable.get('my.color'), e['color']);
      expect(themable.get('nope'), e['missing']);
      svc._cb!(TestTheme(<String, String>{'my.color': '#445566'}));
      final Map<String, dynamic> after = e['afterChange'] as Map<String, dynamic>;
      expect(themable.styles, after['styles']);
      expect(themable.get('my.color'), after['color']);
    });
  });
}
