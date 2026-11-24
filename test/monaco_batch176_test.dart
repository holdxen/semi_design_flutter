// Truth-driven tests for batch176: multiDiffEditor colors, symbolIcons and
// editorTheme. Truth source: tool/ts2dart/batch176_truth.json.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/color.dart' as color;
import 'package:semi_design_flutter/src/monaco/editor/common/editorTheme.dart' as et;
import 'package:semi_design_flutter/src/monaco/editor/browser/widget/multiDiffEditor/colors.dart' as md;
import 'package:semi_design_flutter/src/monaco/editor/contrib/symbolIcons/browser/symbolIcons.dart' as si;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/colorUtils.dart' as cu;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart' as theme;
import 'package:semi_design_flutter/src/monaco/platform/theme/test/common/testThemeService.dart' as testing;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch176_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> fileTruth(String key) =>
    truth[key] as Map<String, dynamic>;

int touchmultiDiffColors() {
  final List<Object?> result = <Object?>[
    md.multiDiffEditorHeaderBackground,
    md.multiDiffEditorBackground,
    md.multiDiffEditorBorder,
  ];
  return result.length;
}
int touchsymbolIcons() {
  final List<Object?> result = <Object?>[
    si.SYMBOL_ICON_ARRAY_FOREGROUND,
    si.SYMBOL_ICON_BOOLEAN_FOREGROUND,
    si.SYMBOL_ICON_CLASS_FOREGROUND,
    si.SYMBOL_ICON_COLOR_FOREGROUND,
    si.SYMBOL_ICON_CONSTANT_FOREGROUND,
    si.SYMBOL_ICON_CONSTRUCTOR_FOREGROUND,
    si.SYMBOL_ICON_ENUMERATOR_FOREGROUND,
    si.SYMBOL_ICON_ENUMERATOR_MEMBER_FOREGROUND,
    si.SYMBOL_ICON_EVENT_FOREGROUND,
    si.SYMBOL_ICON_FIELD_FOREGROUND,
    si.SYMBOL_ICON_FILE_FOREGROUND,
    si.SYMBOL_ICON_FOLDER_FOREGROUND,
    si.SYMBOL_ICON_FUNCTION_FOREGROUND,
    si.SYMBOL_ICON_INTERFACE_FOREGROUND,
    si.SYMBOL_ICON_KEY_FOREGROUND,
    si.SYMBOL_ICON_KEYWORD_FOREGROUND,
    si.SYMBOL_ICON_METHOD_FOREGROUND,
    si.SYMBOL_ICON_MODULE_FOREGROUND,
    si.SYMBOL_ICON_NAMESPACE_FOREGROUND,
    si.SYMBOL_ICON_NULL_FOREGROUND,
    si.SYMBOL_ICON_NUMBER_FOREGROUND,
    si.SYMBOL_ICON_OBJECT_FOREGROUND,
    si.SYMBOL_ICON_OPERATOR_FOREGROUND,
    si.SYMBOL_ICON_PACKAGE_FOREGROUND,
    si.SYMBOL_ICON_PROPERTY_FOREGROUND,
    si.SYMBOL_ICON_REFERENCE_FOREGROUND,
    si.SYMBOL_ICON_SNIPPET_FOREGROUND,
    si.SYMBOL_ICON_STRING_FOREGROUND,
    si.SYMBOL_ICON_STRUCT_FOREGROUND,
    si.SYMBOL_ICON_TEXT_FOREGROUND,
    si.SYMBOL_ICON_TYPEPARAMETER_FOREGROUND,
    si.SYMBOL_ICON_UNIT_FOREGROUND,
    si.SYMBOL_ICON_VARIABLE_FOREGROUND,
  ];
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

void main() {
  final int mdTouched = touchmultiDiffColors();
  final int siTouched = touchsymbolIcons();

  group('batch176 color registration (truth-driven)', () {
    test('touch helpers reference every exported color', () {
      expect(mdTouched, fileTruth('multiDiffColors')['exports'].length);
      expect(siTouched, fileTruth('symbolIcons')['exports'].length);
      expect(fileTruth('multiDiffColors')['duplicates'], isEmpty);
      expect(fileTruth('symbolIcons')['duplicates'], isEmpty);
    });

    for (final String key in <String>['multiDiffColors', 'symbolIcons']) {
      test('$key: descriptions, flags and defaults match executed TS', () {
        final cu.IColorRegistry reg = cu.getColorRegistry();
        final Map<String, cu.ColorContribution> byId =
            <String, cu.ColorContribution>{
          for (final cu.ColorContribution c in reg.getColors()) c.id: c
        };
        for (final dynamic raw
            in (fileTruth(key)['registerCalls'] as List<dynamic>)) {
          final Map<String, dynamic> c = raw as Map<String, dynamic>;
          final String id = c['id'] as String;
          final cu.ColorContribution? contribution = byId[id];
          expect(contribution, isNotNull, reason: 'missing $id');
          expect(contribution!.description, c['description'],
              reason: '$id description');
          expect(contribution.needsTransparency, c['needsTransparency'],
              reason: '$id transparency');
          expect(contribution.deprecationMessage, c['deprecationMessage'],
              reason: '$id deprecation');
          expect(serializeValue(contribution.defaults), c['defaults'],
              reason: '$id defaults');
        }
      });
    }
  });

  group('editorTheme.ts (truth-driven)', () {
    test('exports + initial state match truth', () {
      final Map<String, dynamic> e = fileTruth('editorTheme');
      expect(<dynamic>['EditorTheme'], e['exports']);
      final Map<String, dynamic> b = e['before'] as Map<String, dynamic>;
      final et.EditorTheme t = et.EditorTheme(
          testing.TestColorTheme(<String, String>{'a': '#ff0000ff'},
              theme.ColorScheme.dark));
      expect(t.type.value, b['type']);
      expect(t.value.label, b['valueLabel']);
      final color.Color? known = t.getColor('a');
      expect(<num>[known!.rgba.r, known.rgba.g, known.rgba.b, known.rgba.a],
          <num>[
            (b['known'] as Map<String, dynamic>)['r'] as num,
            (b['known'] as Map<String, dynamic>)['g'] as num,
            (b['known'] as Map<String, dynamic>)['b'] as num,
            (b['known'] as Map<String, dynamic>)['a'] as num,
          ]);
      expect(t.getColor('b'), isNull);
      expect(b['unknown'], isNull);
    });

    test('update replaces the wrapped theme', () {
      final Map<String, dynamic> a =
          (fileTruth('editorTheme')['after'] as Map<String, dynamic>);
      final et.EditorTheme t = et.EditorTheme(
          testing.TestColorTheme(<String, String>{'a': '#ff0000ff'},
              theme.ColorScheme.dark));
      t.update(testing.TestColorTheme(<String, String>{'b': '#00ff00'},
          theme.ColorScheme.light));
      expect(t.type.value, a['type']);
      expect(t.value.label, a['valueLabel']);
      expect(t.getColor('a'), isNull);
      expect(t.getColor('b')!.rgba.g,
          (a['nowKnown'] as Map<String, dynamic>)['g'] as num);
    });
  });
}
