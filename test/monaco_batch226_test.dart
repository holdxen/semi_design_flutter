// Truth replay for batch226 (editorOptions.ts lines 4595-4892):
//   IInlineSuggestOptions/InternalInlineSuggestOptions (+ nested edits/
//   experimental interfaces+carriers), class InlineEditorSuggest (defaults,
//   full schema, validate, _validateEdits, _validateExperimental) and its
//   clampedInt/stringSet/boolean/string boundary behavior.
//
// Expectations come from `tool/ts2dart/batch226_truth.json`, produced by
// `tool/ts2dart/_batch226_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; the class + private methods exposed via a probe
// tail). JS `undefined` is replayed as Dart `null` for optional inputs, per
// the convention documented in editorOptions.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth(String file) =>
    _map(jsonDecode(File('tool/ts2dart/$file').readAsStringSync()));

Map<String, Object?> _edits(opts.InternalInlineSuggestEditsOptions value) =>
    <String, Object?>{
      'enabled': value.enabled,
      'showCollapsed': value.showCollapsed,
      'renderSideBySide': value.renderSideBySide,
      'allowCodeShifting': value.allowCodeShifting,
      'showLongDistanceHint': value.showLongDistanceHint,
      'longDistanceHintContextLineCount':
          value.longDistanceHintContextLineCount,
    };

Map<String, Object?> _experimental(
        opts.InternalInlineSuggestExperimentalOptions value) =>
    <String, Object?>{
      'suppressInlineSuggestions': value.suppressInlineSuggestions,
      'showOnSuggestConflict': value.showOnSuggestConflict,
      'emptyResponseInformation': value.emptyResponseInformation,
    };

Map<String, Object?> _inlineSuggest(
        opts.InternalInlineSuggestOptions value) =>
    <String, Object?>{
      'enabled': value.enabled,
      'mode': value.mode,
      'showToolbar': value.showToolbar,
      'suppressSuggestions': value.suppressSuggestions,
      'keepOnBlur': value.keepOnBlur,
      'fontFamily': value.fontFamily,
      'syntaxHighlightingEnabled': value.syntaxHighlightingEnabled,
      'minShowDelay': value.minShowDelay,
      'suppressInSnippetMode': value.suppressInSnippetMode,
      'edits': _edits(value.edits),
      'triggerCommandOnProviderChange': value.triggerCommandOnProviderChange,
      'experimental': _experimental(value.experimental),
    };

Map<String, Object?> _fullEdits() => <String, Object?>{
      'enabled': false,
      'showCollapsed': true,
      'allowCodeShifting': 'horizontal',
      'showLongDistanceHint': false,
      'longDistanceHintContextLineCount': 7,
      'renderSideBySide': 'never',
    };

// Inputs for every captured top-level `validate` branch (mirrors the harness).
Map<String, Object?> _validationInputs() => <String, Object?>{
      'undefined': null,
      'null': null,
      'number': 42,
      'string': 'inlineSuggest',
      'boolean': true,
      'array': <Object?>[],
      'emptyObject': <String, Object?>{},
      'unknownKey': <String, Object?>{'bogus': 1},
      'enabledTrue': <String, Object?>{'enabled': true},
      'enabledFalse': <String, Object?>{'enabled': false},
      'enabledStringFalse': <String, Object?>{'enabled': 'false'},
      'enabledStringTrue': <String, Object?>{'enabled': 'true'},
      'enabledNumber': <String, Object?>{'enabled': 0},
      'enabledUndefined': <String, Object?>{'enabled': null},
      'modePrefix': <String, Object?>{'mode': 'prefix'},
      'modeSubword': <String, Object?>{'mode': 'subword'},
      'modeSubwordSmart': <String, Object?>{'mode': 'subwordSmart'},
      'modeBogus': <String, Object?>{'mode': 'bogus'},
      'modeNonString': <String, Object?>{'mode': 0},
      'modeNull': <String, Object?>{'mode': null},
      'showToolbarAlways': <String, Object?>{'showToolbar': 'always'},
      'showToolbarOnHover': <String, Object?>{'showToolbar': 'onHover'},
      'showToolbarNever': <String, Object?>{'showToolbar': 'never'},
      'showToolbarBogus': <String, Object?>{'showToolbar': 'bogus'},
      'suppressSuggestions': <String, Object?>{
        'suppressSuggestions': false,
        'keepOnBlur': true,
        'syntaxHighlightingEnabled': false,
        'suppressInSnippetMode': false,
      },
      'suppressSuggestionsCoerced': <String, Object?>{
        'suppressSuggestions': 'false',
        'keepOnBlur': 0,
        'syntaxHighlightingEnabled': 'yes',
        'suppressInSnippetMode': null,
      },
      'fontFamilyDefault': <String, Object?>{'fontFamily': 'default'},
      'fontFamilyCustom': <String, Object?>{
        'fontFamily': 'Menlo, monospace'
      },
      'fontFamilyEmpty': <String, Object?>{'fontFamily': ''},
      'fontFamilyNonString': <String, Object?>{'fontFamily': 42},
      'minShowDelayNegative': <String, Object?>{'minShowDelay': -1},
      'minShowDelayZero': <String, Object?>{'minShowDelay': 0},
      'minShowDelayFive': <String, Object?>{'minShowDelay': 5},
      'minShowDelayMax': <String, Object?>{'minShowDelay': 10000},
      'minShowDelayOver': <String, Object?>{'minShowDelay': 10001},
      'minShowDelayString': <String, Object?>{'minShowDelay': '7'},
      'minShowDelayBadString': <String, Object?>{'minShowDelay': 'abc'},
      'minShowDelayFloat': <String, Object?>{'minShowDelay': 5.9},
      'minShowDelayBoolean': <String, Object?>{'minShowDelay': true},
      'minShowDelayNull': <String, Object?>{'minShowDelay': null},
      'editsEmpty': <String, Object?>{'edits': <String, Object?>{}},
      'editsNull': <String, Object?>{'edits': null},
      'editsNonObject': <String, Object?>{'edits': 'bogus'},
      'editsFull': <String, Object?>{'edits': _fullEdits()},
      'editsBogus': <String, Object?>{
        'edits': <String, Object?>{
          'enabled': 'false',
          'showCollapsed': 0,
          'allowCodeShifting': 'bogus',
          'showLongDistanceHint': 'yes',
          'longDistanceHintContextLineCount': 99,
          'renderSideBySide': 'bogus',
        }
      },
      'experimentalEmpty': <String, Object?>{
        'experimental': <String, Object?>{}
      },
      'experimentalNull': <String, Object?>{'experimental': null},
      'experimentalNonObject': <String, Object?>{'experimental': 42},
      'experimentalFull': <String, Object?>{
        'experimental': <String, Object?>{
          'suppressInlineSuggestions': 'pub1,pub2',
          'showOnSuggestConflict': 'whenSuggestListIsIncomplete',
          'emptyResponseInformation': false,
        }
      },
      'experimentalBogus': <String, Object?>{
        'experimental': <String, Object?>{
          'suppressInlineSuggestions': 0,
          'showOnSuggestConflict': 'bogus',
          'emptyResponseInformation': 'false',
        }
      },
      'triggerCommandOnProviderChange': <String, Object?>{
        'triggerCommandOnProviderChange': true
      },
      'allFields': <String, Object?>{
        'enabled': false,
        'mode': 'prefix',
        'showToolbar': 'always',
        'suppressSuggestions': true,
        'keepOnBlur': true,
        'fontFamily': 'default',
        'syntaxHighlightingEnabled': false,
        'minShowDelay': 123,
        'suppressInSnippetMode': false,
        'edits': <String, Object?>{
          'enabled': true,
          'showCollapsed': true,
          'allowCodeShifting': 'never',
          'showLongDistanceHint': false,
          'longDistanceHintContextLineCount': 3,
          'renderSideBySide': 'auto',
        },
        'triggerCommandOnProviderChange': true,
        'experimental': <String, Object?>{
          'suppressInlineSuggestions': 'x',
          'showOnSuggestConflict': 'always',
          'emptyResponseInformation': false,
        },
      },
    };

// Inputs for the captured nested `_validateEdits` branches.
Map<String, Object?> _editInputs() => <String, Object?>{
      'undefined': null,
      'null': null,
      'number': 42,
      'string': 'edits',
      'boolean': true,
      'array': <Object?>[],
      'empty': <String, Object?>{},
      'enabledFalse': <String, Object?>{'enabled': false},
      'enabledStringFalse': <String, Object?>{'enabled': 'false'},
      'showCollapsedTrue': <String, Object?>{'showCollapsed': true},
      'allowCodeShiftingAlways': <String, Object?>{
        'allowCodeShifting': 'always'
      },
      'allowCodeShiftingHorizontal': <String, Object?>{
        'allowCodeShifting': 'horizontal'
      },
      'allowCodeShiftingNever': <String, Object?>{
        'allowCodeShifting': 'never'
      },
      'allowCodeShiftingBogus': <String, Object?>{
        'allowCodeShifting': 'bogus'
      },
      'showLongDistanceHintFalse': <String, Object?>{
        'showLongDistanceHint': false
      },
      'contextNegative': <String, Object?>{
        'longDistanceHintContextLineCount': -1
      },
      'contextZero': <String, Object?>{
        'longDistanceHintContextLineCount': 0
      },
      'contextTen': <String, Object?>{
        'longDistanceHintContextLineCount': 10
      },
      'contextOver': <String, Object?>{
        'longDistanceHintContextLineCount': 11
      },
      'contextString': <String, Object?>{
        'longDistanceHintContextLineCount': '4'
      },
      'contextBadString': <String, Object?>{
        'longDistanceHintContextLineCount': 'nope'
      },
      'contextFloat': <String, Object?>{
        'longDistanceHintContextLineCount': 3.8
      },
      'renderSideBySideNever': <String, Object?>{
        'renderSideBySide': 'never'
      },
      'renderSideBySideAuto': <String, Object?>{
        'renderSideBySide': 'auto'
      },
      'renderSideBySideBogus': <String, Object?>{
        'renderSideBySide': 'bogus'
      },
      'all': <String, Object?>{
        'enabled': true,
        'showCollapsed': true,
        'allowCodeShifting': 'horizontal',
        'showLongDistanceHint': true,
        'longDistanceHintContextLineCount': 9,
        'renderSideBySide': 'never',
      },
    };

// Inputs for the captured nested `_validateExperimental` branches.
Map<String, Object?> _experimentalInputs() => <String, Object?>{
      'undefined': null,
      'null': null,
      'number': 42,
      'string': 'experimental',
      'boolean': true,
      'array': <Object?>[],
      'empty': <String, Object?>{},
      'suppressString': <String, Object?>{
        'suppressInlineSuggestions': 'pub.a,pub.b'
      },
      'suppressNonString': <String, Object?>{
        'suppressInlineSuggestions': 0
      },
      'conflictAlways': <String, Object?>{
        'showOnSuggestConflict': 'always'
      },
      'conflictNever': <String, Object?>{
        'showOnSuggestConflict': 'never'
      },
      'conflictIncomplete': <String, Object?>{
        'showOnSuggestConflict': 'whenSuggestListIsIncomplete'
      },
      'conflictBogus': <String, Object?>{
        'showOnSuggestConflict': 'bogus'
      },
      'infoFalse': <String, Object?>{'emptyResponseInformation': false},
      'infoStringFalse': <String, Object?>{
        'emptyResponseInformation': 'false'
      },
      'all': <String, Object?>{
        'suppressInlineSuggestions': 'p1',
        'showOnSuggestConflict': 'always',
        'emptyResponseInformation': false,
      },
    };

void main() {
  final Map<String, dynamic> truth = _truth('batch226_truth.json');
  final Map<String, dynamic> expected = _map(truth['inlineSuggest']);
  final opts.InlineEditorSuggest option = opts.InlineEditorSuggest();

  test('InlineEditorSuggest id, name, defaults and full schema match source', () {
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_inlineSuggest(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);
    expect(truth['platformSchemaStrings'], isEmpty);
  });

  test('top-level validate matches every source branch and boundary', () {
    final Map<String, dynamic> cases = _map(expected['validate']);
    final Map<String, Object?> inputs = _validationInputs();
    cases.forEach((String key, Object? value) {
      expect(inputs.containsKey(key), isTrue, reason: key);
      final opts.InternalInlineSuggestOptions result =
          option.validate(inputs[key]);
      expect(_inlineSuggest(result), value, reason: key);
    });
    expect(inputs.length, cases.length);
  });

  test('nested _validateEdits matches every source branch and boundary', () {
    final Map<String, dynamic> cases = _map(truth['validateEdits']);
    final Map<String, Object?> inputs = _editInputs();
    cases.forEach((String key, Object? value) {
      expect(inputs.containsKey(key), isTrue, reason: key);
      expect(_edits(option.validateEdits(inputs[key])), value, reason: key);
    });
    expect(inputs.length, cases.length);
  });

  test('nested _validateExperimental matches every source branch', () {
    final Map<String, dynamic> cases = _map(truth['validateExperimental']);
    final Map<String, Object?> inputs = _experimentalInputs();
    cases.forEach((String key, Object? value) {
      expect(inputs.containsKey(key), isTrue, reason: key);
      expect(_experimental(option.validateExperimental(inputs[key])), value,
          reason: key);
    });
    expect(inputs.length, cases.length);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
