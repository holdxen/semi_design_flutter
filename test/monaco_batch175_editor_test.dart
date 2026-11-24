// Truth-driven tests for batch175: editor/common/core/editorColorRegistry.ts
// Truth source: tool/ts2dart/batch175_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/color.dart' as color;
import 'package:semi_design_flutter/src/monaco/editor/common/core/editorColorRegistry.dart' as reg;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/colorUtils.dart' as cu;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart' as ts;
import 'package:semi_design_flutter/src/monaco/platform/theme/test/common/testThemeService.dart' as testing;
import 'package:semi_design_flutter/src/monaco/platform/registry/common/platform.dart' as platform;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch175_truth.json').readAsStringSync())
        as Map<String, dynamic>;

const int _generatedColorCount = 71;

Map<String, dynamic> get e =>
    truth['editorColorRegistry'] as Map<String, dynamic>;

int touchEditorColors() {
  final List<Object?> result = <Object?>[];
  result.add(reg.editorLineHighlight);
  result.add(reg.editorInactiveLineHighlight);
  result.add(reg.editorLineHighlightBorder);
  result.add(reg.editorRangeHighlight);
  result.add(reg.editorRangeHighlightBorder);
  result.add(reg.editorSymbolHighlight);
  result.add(reg.editorSymbolHighlightBorder);
  result.add(reg.editorCursorForeground);
  result.add(reg.editorCursorBackground);
  result.add(reg.editorMultiCursorPrimaryForeground);
  result.add(reg.editorMultiCursorPrimaryBackground);
  result.add(reg.editorMultiCursorSecondaryForeground);
  result.add(reg.editorMultiCursorSecondaryBackground);
  result.add(reg.editorWhitespaces);
  result.add(reg.editorWordWrapIndicator);
  result.add(reg.editorLineNumbers);
  result.add(reg.deprecatedEditorIndentGuides);
  result.add(reg.deprecatedEditorActiveIndentGuides);
  result.add(reg.editorIndentGuide1);
  result.add(reg.editorIndentGuide2);
  result.add(reg.editorIndentGuide3);
  result.add(reg.editorIndentGuide4);
  result.add(reg.editorIndentGuide5);
  result.add(reg.editorIndentGuide6);
  result.add(reg.editorActiveIndentGuide1);
  result.add(reg.editorActiveIndentGuide2);
  result.add(reg.editorActiveIndentGuide3);
  result.add(reg.editorActiveIndentGuide4);
  result.add(reg.editorActiveIndentGuide5);
  result.add(reg.editorActiveIndentGuide6);
  result.add(reg.editorActiveLineNumberForeground);
  result.add(reg.editorActiveLineNumber);
  result.add(reg.editorDimmedLineNumber);
  result.add(reg.editorRuler);
  result.add(reg.editorCodeLensForeground);
  result.add(reg.editorBracketMatchBackground);
  result.add(reg.editorBracketMatchBorder);
  result.add(reg.editorBracketMatchForeground);
  result.add(reg.editorOverviewRulerBorder);
  result.add(reg.editorOverviewRulerBackground);
  result.add(reg.editorGutter);
  result.add(reg.editorUnnecessaryCodeBorder);
  result.add(reg.editorUnnecessaryCodeOpacity);
  result.add(reg.ghostTextBorder);
  result.add(reg.ghostTextForeground);
  result.add(reg.ghostTextBackground);
  result.add(reg.overviewRulerRangeHighlight);
  result.add(reg.overviewRulerError);
  result.add(reg.overviewRulerWarning);
  result.add(reg.overviewRulerInfo);
  result.add(reg.editorBracketHighlightingForeground1);
  result.add(reg.editorBracketHighlightingForeground2);
  result.add(reg.editorBracketHighlightingForeground3);
  result.add(reg.editorBracketHighlightingForeground4);
  result.add(reg.editorBracketHighlightingForeground5);
  result.add(reg.editorBracketHighlightingForeground6);
  result.add(reg.editorBracketHighlightingUnexpectedBracketForeground);
  result.add(reg.editorBracketPairGuideBackground1);
  result.add(reg.editorBracketPairGuideBackground2);
  result.add(reg.editorBracketPairGuideBackground3);
  result.add(reg.editorBracketPairGuideBackground4);
  result.add(reg.editorBracketPairGuideBackground5);
  result.add(reg.editorBracketPairGuideBackground6);
  result.add(reg.editorBracketPairGuideActiveBackground1);
  result.add(reg.editorBracketPairGuideActiveBackground2);
  result.add(reg.editorBracketPairGuideActiveBackground3);
  result.add(reg.editorBracketPairGuideActiveBackground4);
  result.add(reg.editorBracketPairGuideActiveBackground5);
  result.add(reg.editorBracketPairGuideActiveBackground6);
  result.add(reg.editorUnicodeHighlightBorder);
  result.add(reg.editorUnicodeHighlightBackground);
  result.add(reg.editorThemingParticipant);
  return result.length;
}

Object? serializeValue(Object? v) {
  if (v == null) return null;
  if (v is color.Color) {
    return <String, Object?>{
      'color': <String, Object?>{
        'r': v.rgba.r, 'g': v.rgba.g, 'b': v.rgba.b, 'a': v.rgba.a,
      }
    };
  }
  if (v is cu.ColorDefaults) {
    return <String, Object?>{
      'light': serializeValue(v.light),
      'dark': serializeValue(v.dark),
      'hcDark': serializeValue(v.hcDark),
      'hcLight': serializeValue(v.hcLight),
    };
  }
  return v;
}

class _Collector implements ts.ICssStyleCollector {
  final List<String> rules = <String>[];
  @override
  void addRule(String rule) => rules.add(rule);
}

void main() {
  final int touched = touchEditorColors();

  group('editorColorRegistry.ts (truth-driven)', () {
    test('touch helper references all exports', () {
      expect(touched, _generatedColorCount + 1);
      expect(e['duplicates'], isEmpty);
    });

    test('all registerColor calls registered exactly once', () {
      final cu.IColorRegistry registry = cu.getColorRegistry();
      final Map<String, cu.ColorContribution> byId = <String, cu.ColorContribution>{
        for (final cu.ColorContribution c in registry.getColors()) c.id: c
      };
      for (final dynamic raw in e['registerCalls'] as List<dynamic>) {
        final Map<String, dynamic> c = raw as Map<String, dynamic>;
        final String id = c['id'] as String;
        expect(byId.containsKey(id), true, reason: 'missing $id');
      }
    });

    test('descriptions, flags and defaults match executed TS truth', () {
      final cu.IColorRegistry registry = cu.getColorRegistry();
      final Map<String, cu.ColorContribution> byId = <String, cu.ColorContribution>{
        for (final cu.ColorContribution c in registry.getColors()) c.id: c
      };
      for (final dynamic raw in e['registerCalls'] as List<dynamic>) {
        final Map<String, dynamic> c = raw as Map<String, dynamic>;
        final String id = c['id'] as String;
        final cu.ColorContribution? contribution = byId[id];
        expect(contribution, isNotNull, reason: 'missing $id');
        expect(contribution!.description, c['description'], reason: '$id description');
        expect(contribution.needsTransparency, c['needsTransparency'],
            reason: '$id transparency');
        expect(contribution.deprecationMessage, c['deprecationMessage'],
            reason: '$id deprecation');
        expect(serializeValue(contribution.defaults), c['defaults'],
            reason: '$id defaults');
      }
    });

    test('theming participant builds the IME rule from theme colors', () {
      final dynamic registry = platform.Registry.as(
          ts.ThemeServiceExtensions.ThemingContribution);
      final List<dynamic> participants =
          (registry as ts.IThemingRegistry).getThemingParticipants().cast<dynamic>();
      expect(participants.length, e['participants']);
      for (final Map<String, dynamic> caseData
          in (e['theming'] as List<dynamic>).cast<Map<String, dynamic>>()) {
        final Map<String, String> colors = <String, String>{
          'editor.background': '#111213',
        };
        if (caseData['label'] == 'opaque') {
          colors['editor.lineHighlightBackground'] = '#28323c';
        } else if (caseData['label'] == 'transparent') {
          colors['editor.lineHighlightBackground'] = '#28323c00';
        }
        final ts.IColorTheme theme = testing.TestColorTheme(colors);
        final _Collector collector = _Collector();
        (participants.last as dynamic)(theme, collector, null);
        expect(collector.rules, caseData['rules']);
      }
    });
  });
}
