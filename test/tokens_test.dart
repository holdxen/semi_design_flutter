import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  const light = SemiThemeData.light();
  const dark = SemiThemeData.dark();
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
