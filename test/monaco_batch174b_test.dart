// Truth-driven tests for batch174b: the 11 color definition files under
// platform/theme/common/colors/. Truth source: batch174b_truth.json.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/theme/common/colorUtils.dart' as cu;

import 'monaco_batch174b_all.dart' as gen;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch174b_truth.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  // Force all color constants to initialize (registerColor calls).
  final int touched = gen.touchAllColors();

  group('color definition files (truth-driven)', () {
    test('touch helper references all exports', () {
      final int expected = (truth['files'] as Map<String, dynamic>).values
          .map((dynamic f) => (f['exports'] as List<dynamic>).length)
          .reduce((int a, int b) => a + b);
      expect(touched, expected);
    });

    test('all 259 registered ids present exactly once', () {
      final List<dynamic> allIds = truth['allIds'] as List<dynamic>;
      expect(allIds.length, truth['totalRegisterCalls']);
      expect(truth['duplicateIds'], isEmpty);

      final cu.IColorRegistry reg = cu.getColorRegistry();
      final Map<String, cu.ColorContribution> byId = <String, cu.ColorContribution>{
        for (final cu.ColorContribution c in reg.getColors()) c.id: c
      };
      for (final dynamic id in allIds) {
        expect(byId.containsKey(id as String), true, reason: 'missing $id');
      }
    });

    for (final MapEntry<String, dynamic> file
        in (truth['files'] as Map<String, dynamic>).entries) {
      final String name = file.key;
      final Map<String, dynamic> f = file.value;
      final List<dynamic> calls = f['registerCalls'] as List<dynamic>;

      test('$name: registerColor descriptions + flags match truth', () {
        final cu.IColorRegistry reg = cu.getColorRegistry();
        final Map<String, cu.ColorContribution> byId = <String, cu.ColorContribution>{
          for (final cu.ColorContribution c in reg.getColors()) c.id: c
        };
        for (final dynamic raw in calls) {
          final Map<String, dynamic> c = raw as Map<String, dynamic>;
          final String id = c['id'] as String;
          final cu.ColorContribution? contribution = byId[id];
          expect(contribution, isNotNull, reason: 'missing $id');
          expect(contribution!.description, c['description'], reason: '$id description');
          expect(contribution.needsTransparency, c['needsTransparency'],
              reason: '$id transparency');
          expect(contribution.deprecationMessage, c['deprecationMessage'],
              reason: '$id deprecation');
        }
      });
    }

    test('ColorDefaults structure resolves via truth defaults', () {
      // A few representative colors validate that default maps were emitted as
      // ColorDefaults / ColorTransform with the executed-TS values.
      final cu.IColorRegistry reg = cu.getColorRegistry();
      final Map<String, cu.ColorContribution> byId = <String, cu.ColorContribution>{
        for (final cu.ColorContribution c in reg.getColors()) c.id: c
      };
      final cu.ColorContribution fg = byId['foreground']!;
      expect(fg.defaults, isA<cu.ColorDefaults>());
      final cu.ColorDefaults d = fg.defaults as cu.ColorDefaults;
      // truth baseColors.foreground dark = #CCCCCC
      expect(d.dark, '#CCCCCC');
      expect(d.light, '#616161');
    });

    test('ColorTransform defaults (opacity/transparent) emitted', () {
      final cu.IColorRegistry reg = cu.getColorRegistry();
      final Map<String, cu.ColorContribution> byId = <String, cu.ColorContribution>{
        for (final cu.ColorContribution c in reg.getColors()) c.id: c
      };
      // minimap.findMatchHighlight uses withOpacity transform (op 8)
      final cu.ColorContribution c = byId['minimap.findMatchHighlight']!;
      expect(c.defaults, isA<cu.ColorDefaults>());
      final cu.ColorDefaults d = c.defaults as cu.ColorDefaults;
      expect(d.light, isA<cu.ColorTransform>());
      expect((d.light as cu.ColorTransform).op, cu.ColorTransformType.Opacity);
      expect((d.light as cu.ColorTransform).opacity, 0.8);
    });
  });
}
