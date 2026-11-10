import 'dart:convert';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  const light = SemiThemeData.light();
  const dark = SemiThemeData.dark();
  test('dependency rebinding and explicit precedence across copies', () {
    final changed = light.copyWith(
      palette: light.palette.copyWith(blue5: const SemiChannels(1, 2, 3, 1)),
    );
    expect(changed.colors.colorPrimary, const Color(0xff010203));
    expect(changed.colors.colorPrimaryHover, light.colors.colorPrimaryHover);
    final semantic = changed.copyWith(
      colors: changed.colors.copyWith(colorText0: const Color(0xff123456)),
    );
    expect(
      semantic.button.buttonColorfulFillSecondary,
      const Color(0xff123456),
    );
    final component = semantic.copyWith(
      button: semantic.button.copyWith(
        buttonColorfulFillSecondary: const Color(0xffabcdef),
      ),
    );
    final next = component.copyWith(
      palette: component.palette.copyWith(
        blue5: const SemiChannels(4, 5, 6, 1),
      ),
    );
    expect(next.colors.colorPrimary, const Color(0xff040506));
    expect(next.colors.colorText0, const Color(0xff123456));
    expect(next.button.buttonColorfulFillSecondary, const Color(0xffabcdef));
    expect(next.palette.grey9, light.palette.grey9);
    expect(
      next.copyWith(dark: true).colors.colorPrimary,
      const Color(0xff040506),
    );
    expect(light, const SemiThemeData.light());
    expect(light.hashCode, const SemiThemeData.light().hashCode);
  });
  test('mode strategies rebind defaults without losing overrides', () {
    final custom = light.copyWith(
      palette: light.palette.copyWith(blue5: const SemiChannels(1, 2, 3, 1)),
      colors: light.colors.copyWith(colorText0: const Color(0xff123456)),
    );
    final switched = custom.copyWith(dark: true);
    expect(switched.palette.grey9, dark.palette.grey9);
    expect(switched.palette.grey9, isNot(light.palette.grey9));
    expect(switched.colors.colorPrimary, const Color(0xff010203));
    expect(
      switched.button.buttonColorfulFillSecondary,
      const Color(0xff123456),
    );
    expect(switched.shadows, dark.shadows);
    expect(switched.copyWith(dark: false), custom);
    expect(switched.copyWith(dark: false).hashCode, custom.hashCode);
    expect(const SemiPalette(dark: true), dark.palette);
    expect(const SemiShadowTokens(dark: true), dark.shadows);
  });
  test('models have structural equality and defensive collections', () {
    final colors = [const Color(0xff123456)];
    final stops = [0.0];
    final gradient = SemiGradient(90, colors, stops);
    colors.clear();
    stops.clear();
    expect(gradient, SemiGradient(90, [const Color(0xff123456)], [0]));
    expect(
      gradient.hashCode,
      SemiGradient(90, [const Color(0xff123456)], [0]).hashCode,
    );
    expect(() => gradient.colors.clear(), throwsUnsupportedError);
    final layers = [
      const SemiShadowLayer(false, 1, 2, 3, 4, Color(0xff123456)),
    ];
    final shadows = SemiShadows(layers);
    layers.clear();
    expect(shadows.layers.length, 1);
    expect(() => shadows.layers.clear(), throwsUnsupportedError);
    expect(
      shadows,
      SemiShadows([
        const SemiShadowLayer(false, 1, 2, 3, 4, Color(0xff123456)),
      ]),
    );
  });
  test('equal cubic overrides and group reset', () {
    final a = light.copyWith(
      motion: light.motion.copyWith(
        transitionFunctionEase: Cubic(.1, .2, .3, .4),
      ),
    );
    final b = light.copyWith(
      motion: light.motion.copyWith(
        transitionFunctionEase: Cubic(.1, .2, .3, .4),
      ),
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    final pinned = light.copyWith(
      colors: light.colors.copyWith(colorPrimary: const Color(0xff123456)),
    );
    expect(pinned.copyWith(colors: const SemiColors()), light);
  });
  test('383 unique names with complete source and public field mapping', () {
    final manifest = jsonDecode(
      File('tool/token_manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final mapping = manifest['mapping'] as List;
    expect(mapping.length, 383);
    expect(mapping.map((e) => e['name']).toSet().length, 383);
    for (final entry in mapping) {
      for (final mode in ['light', 'dark']) {
        final source = entry[mode];
        expect(manifest['sources'][source['path']], isNotNull);
        expect(source['line'], greaterThan(0));
      }
      final code = File(entry['file'] as String).readAsStringSync();
      expect(code, contains('`${entry['name']}`'));
      expect(code, contains(entry['light']['path']));
    }
  });
  test('theme-specific palette and button references', () {
    expect(light.colors.colorPrimary, light.palette.blue5.toColor());
    expect(dark.colors.colorPrimary, dark.palette.blue5.toColor());
    expect(light.colors.colorPrimary, isNot(dark.colors.colorPrimary));
    expect(light.button.buttonColorfulFillSecondary, light.colors.colorText0);
    expect(dark.button.buttonColorfulFillSecondary, dark.colors.colorText0);
  });
  test('duplicate top hover is last wins, not invented active', () {
    final manifest = jsonDecode(
      File('tool/token_manifest.json').readAsStringSync(),
    );
    expect((manifest['diagnostics'] as List).length, 2);
    expect(
      light.colors.colorAiBackgroundTopHover.colors.first.a,
      closeTo(.32, .001),
    );
    expect(
      dark.colors.colorAiBackgroundTopHover.colors.first.a,
      closeTo(.72, .001),
    );
  });
  test('CSS angle uses box size and preserves nested color commas', () {
    final gradient = light.palette.aiGeneral5;
    expect(gradient.colors.length, 4);
    final square = gradient.forSize(const Size(100, 100));
    final wide = gradient.forSize(const Size(300, 100));
    expect(square.end, isNot(wide.end));
    final right = SemiGradient(
      90,
      [const Color(0xff000000), const Color(0xffffffff)],
      [0, 1],
    ).forSize(const Size(300, 100));
    expect((right.end as Alignment).x, closeTo(1, 1e-8));
    expect((right.end as Alignment).y, closeTo(0, 1e-8));
  });
  test('percent radii and runtime tooltip fallback', () {
    expect(
      light.radius.borderRadiusCircle.resolveRadius(const Size(80, 40)),
      const Radius.elliptical(40, 20),
    );
    expect(light.tooltip.tooltipArrowOffsetX.resolve(80), 40);
    expect(dark.tooltip.tooltipArrowOffsetY.resolve(40), 20);
    expect(const SemiLength.pixels(7).resolve(100), 7);
  });
  test(
    'all shadow layers retain inset, unsupported conversion is explicit',
    () {
      expect(light.shadows.shadowElevated.layers.length, 2);
      expect(light.shadows.shadowElevated.toBoxShadows().length, 2);
      expect(dark.shadows.shadowElevated.layers.first.inset, isTrue);
      expect(
        () => dark.shadows.shadowElevated.toBoxShadows(),
        throwsUnsupportedError,
      );
    },
  );
  test('effective motion excludes commented animation', () {
    final manifest = jsonDecode(
      File('tool/token_manifest.json').readAsStringSync(),
    );
    for (final entry in manifest['mapping']) {
      if (entry['type'] == 'Duration') expect(entry['light']['value'], '0ms');
    }
    expect(light.motion.transitionDurationNormal, Duration.zero);
    expect(light.motion.transformScaleSmall.scaleX, 1);
    expect(light.motion.transformRotateClockwise90deg.degrees, 90);
  });
}
