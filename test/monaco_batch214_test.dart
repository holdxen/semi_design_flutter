// Truth replay for batch214:
//   `editor/browser/config/migrateOptions.ts`.
//
// Expectations come from `tool/ts2dart/batch214_truth.json`, produced by
// `tool/ts2dart/_batch214_truth.cjs` (the real module: loading it registers all
// 30 `EditorSettingMigration`s; each scenario records the mutated options as
// ordered `[key, value]` pairs with explicit nulls for `undefined`).
//
// NOTE: `migrateOptions.ts` has no official test of its own; truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/config/migrateOptions.dart' as migrate;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch214_truth.json').readAsStringSync()));

/// Ordered `[key, value]` pairs (JS `Object.entries` order) with explicit nulls
/// where the truth harness saw `undefined`.
Object? _norm(Object? value) {
  if (value is Map) {
    return value.entries
        .map((MapEntry<Object?, Object?> e) =>
            <Object?>[e.key.toString(), _norm(e.value)])
        .toList();
  }
  if (value is List) {
    return value.map(_norm).toList();
  }
  return value;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  setUpAll(() {
    // TS registers every migration at module load; the port does it lazily.
    migrate.editorSettingMigrations;
  });

  test('batch214 registers every migration in source order', () {
    expect(
        migrate.EditorSettingMigration.items
            .map((migrate.EditorSettingMigration m) => m.key)
            .toList(),
        (truth['keys'] as List<dynamic>).cast<String>());
  });

  Map<String, Object?> migrated(Map<String, Object?> input) {
    migrate.migrateOptions(input);
    return input;
  }

  test('batch214 simple value migrations', () {
    expect(
        _norm(migrated(<String, Object?>{
          'wordWrap': true,
          'lineNumbers': false,
          'cursorBlinking': 'visible',
          'renderWhitespace': true,
          'renderLineHighlight': false,
          'acceptSuggestionOnEnter': false,
          'tabCompletion': false,
          'autoIndent': false,
          'matchBrackets': true,
          'renderFinalNewline': false,
          'cursorSmoothCaretAnimation': true,
          'occurrencesHighlight': true,
          'wordBasedSuggestions': false,
          'defaultColorDecorators': true,
          'minimap': <String, Object?>{'autohide': false},
          'unrelated': 'kept',
        })),
        truth['simpleBooleans']);
  });

  test('batch214 object-valued simple migrations', () {
    expect(
        _norm(migrated(<String, Object?>{
          'hover': true,
          'parameterHints': false,
        })),
        truth['hoverAndHints']);
  });

  test('batch214 autoClosingBrackets cascades', () {
    expect(
        _norm(migrated(<String, Object?>{'autoClosingBrackets': false})),
        truth['autoClosingBrackets']);
    expect(
        _norm(migrated(<String, Object?>{
          'autoClosingBrackets': false,
          'autoClosingQuotes': 'always',
          'autoSurround': 'languageDefined',
        })),
        truth['autoClosingBracketsPreset']);
    expect(
        _norm(migrated(<String, Object?>{'autoClosingBrackets': true})),
        truth['autoClosingBracketsTrue']);
  });

  test('batch214 indentation guides migrations', () {
    expect(
        _norm(migrated(<String, Object?>{'renderIndentGuides': false})),
        truth['indentGuides']);
    expect(
        _norm(migrated(<String, Object?>{
          'renderIndentGuides': false,
          'guides': <String, Object?>{'indentation': true},
        })),
        truth['indentGuidesPreset']);
    expect(
        _norm(migrated(<String, Object?>{'highlightActiveIndentGuide': true})),
        truth['highlightActiveIndent']);
  });

  test('batch214 suggest.filteredTypes expands into show* flags', () {
    expect(
        _norm(migrated(<String, Object?>{
          'suggest': <String, Object?>{
            'filteredTypes': <String, Object?>{
              'method': false,
              'function': true,
            },
          },
        })),
        truth['suggestFilteredTypes']);
  });

  test('batch214 quickSuggestions migrations', () {
    expect(
        _norm(migrated(<String, Object?>{'quickSuggestions': true})),
        truth['quickSuggestionsOn']);
    expect(
        _norm(migrated(<String, Object?>{'quickSuggestions': false})),
        truth['quickSuggestionsOff']);
    expect(
        _norm(migrated(<String, Object?>{
          'quickSuggestions': <String, Object?>{'comments': 'on'},
        })),
        truth['quickSuggestionsObject']);
  });

  test('batch214 sticky scroll migrations', () {
    expect(
        _norm(migrated(<String, Object?>{
          'experimental': <String, Object?>{
            'stickyScroll': <String, Object?>{'enabled': true, 'maxLineCount': 3},
          },
        })),
        truth['stickyScroll']);
    expect(
        _norm(migrated(<String, Object?>{
          'experimental': <String, Object?>{
            'stickyScroll': <String, Object?>{'enabled': true, 'maxLineCount': 3},
          },
          'stickyScroll': <String, Object?>{'enabled': false, 'maxLineCount': 9},
        })),
        truth['stickyScrollPreset']);
  });

  test('batch214 edit context migration', () {
    expect(
        _norm(migrated(<String, Object?>{
          'editor': <String, Object?>{'experimentalEditContextEnabled': false},
        })),
        truth['editContext']);
  });

  test('batch214 codeActionsOnSave booleans become explicit/never', () {
    expect(
        _norm(migrated(<String, Object?>{
          'codeActionsOnSave': <String, Object?>{
            'organizeImports': true,
            'fixAll': false,
            'other': 'x',
          },
        })),
        truth['codeActionsOnSave']);
    expect(
        _norm(migrated(<String, Object?>{
          'codeActionsOnSave': <String, Object?>{'organizeImports': 'explicit'},
        })),
        truth['codeActionsOnSaveStrings']);
  });

  test('batch214 quick fix, lightbulb, code shifting, hover', () {
    expect(
        _norm(migrated(<String, Object?>{
          'codeActionWidget': <String, Object?>{'includeNearbyQuickfixes': true},
        })),
        truth['quickFix']);
    expect(_norm(migrated(<String, Object?>{
      'lightbulb': <String, Object?>{'enabled': true},
    })), truth['lightbulbOn']);
    expect(_norm(migrated(<String, Object?>{
      'lightbulb': <String, Object?>{'enabled': false},
    })), truth['lightbulbOff']);
    expect(_norm(migrated(<String, Object?>{
      'lightbulb': <String, Object?>{'enabled': 'off'},
    })), truth['lightbulbString']);
    expect(
        _norm(migrated(<String, Object?>{
          'inlineSuggest': <String, Object?>{
            'edits': <String, Object?>{'codeShifting': true},
          },
        })),
        truth['codeShiftingOn']);
    expect(
        _norm(migrated(<String, Object?>{
          'inlineSuggest': <String, Object?>{
            'edits': <String, Object?>{'codeShifting': false},
          },
        })),
        truth['codeShiftingOff']);
    expect(
        _norm(migrated(<String, Object?>{
          'hover': <String, Object?>{'enabled': false},
        })),
        truth['hoverEnabled']);
  });

  test('batch214 absent values leave the options untouched', () {
    expect(
        _norm(migrated(<String, Object?>{
          'wordWrap': null,
          'autoClosingBrackets': null,
          'hover': null,
          'lightbulb': null,
        })),
        truth['undefinedInputs']);
  });
}
