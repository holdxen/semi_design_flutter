// Truth replay for batch227 (editorOptions.ts lines 4894-5082):
//   bracketPairColorization + guides regions:
//     IBracketPairColorizationOptions/InternalBracketPairColorizationOptions,
//     BracketPairColorization (defaults, full schema, validate) with its
//     `boolean` boundary behavior; IGuidesOptions/InternalGuidesOptions,
//     GuideOptions (defaults, full schema, validate) with its `primitiveSet`
//     boundary behavior; plus the shared `primitiveSet` truth table.
//
// Expectations come from `tool/ts2dart/batch227_truth.json`, produced by
// `tool/ts2dart/_batch227_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; the classes/helper exposed via a probe tail). JS
// `undefined` is replayed as Dart `null` for optional inputs, per the
// convention documented in editorOptions.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth(String file) =>
    _map(jsonDecode(File('tool/ts2dart/$file').readAsStringSync()));

Map<String, Object?> _bracketPairColorization(
        opts.InternalBracketPairColorizationOptions value) =>
    <String, Object?>{
      'enabled': value.enabled,
      'independentColorPoolPerBracketType':
          value.independentColorPoolPerBracketType,
    };

Map<String, Object?> _guides(opts.InternalGuidesOptions value) =>
    <String, Object?>{
      'bracketPairs': value.bracketPairs,
      'bracketPairsHorizontal': value.bracketPairsHorizontal,
      'highlightActiveBracketPair': value.highlightActiveBracketPair,
      'indentation': value.indentation,
      'highlightActiveIndentation': value.highlightActiveIndentation,
    };

// Inputs for every captured `BracketPairColorization.validate` branch (mirrors
// the harness).
Map<String, Object?> _bracketPairColorizationInputs() =>
    <String, Object?>{
      'undefined': null,
      'null': null,
      'number': 42,
      'string': 'bracketPairColorization',
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
      'independentTrue': <String, Object?>{
        'independentColorPoolPerBracketType': true
      },
      'independentFalse': <String, Object?>{
        'independentColorPoolPerBracketType': false
      },
      'independentStringFalse': <String, Object?>{
        'independentColorPoolPerBracketType': 'false'
      },
      'independentNumber': <String, Object?>{
        'independentColorPoolPerBracketType': 0
      },
      'independentUndefined': <String, Object?>{
        'independentColorPoolPerBracketType': null
      },
      'allFields': <String, Object?>{
        'enabled': false,
        'independentColorPoolPerBracketType': true,
      },
      'allBogus': <String, Object?>{
        'enabled': 'bogus',
        'independentColorPoolPerBracketType': 42,
      },
    };

// Inputs for every captured `GuideOptions.validate` branch (mirrors the
// harness).
Map<String, Object?> _guidesInputs() => <String, Object?>{
      'undefined': null,
      'null': null,
      'number': 42,
      'string': 'guides',
      'boolean': true,
      'array': <Object?>[],
      'emptyObject': <String, Object?>{},
      'unknownKey': <String, Object?>{'bogus': 1},
      'bracketPairsTrue': <String, Object?>{'bracketPairs': true},
      'bracketPairsFalse': <String, Object?>{'bracketPairs': false},
      'bracketPairsActive': <String, Object?>{'bracketPairs': 'active'},
      'bracketPairsAlways': <String, Object?>{'bracketPairs': 'always'},
      'bracketPairsBogus': <String, Object?>{'bracketPairs': 'bogus'},
      'bracketPairsNumber': <String, Object?>{'bracketPairs': 0},
      'bracketPairsNull': <String, Object?>{'bracketPairs': null},
      'bracketPairsHorizontalTrue': <String, Object?>{
        'bracketPairsHorizontal': true
      },
      'bracketPairsHorizontalFalse': <String, Object?>{
        'bracketPairsHorizontal': false
      },
      'bracketPairsHorizontalActive': <String, Object?>{
        'bracketPairsHorizontal': 'active'
      },
      'bracketPairsHorizontalAlways': <String, Object?>{
        'bracketPairsHorizontal': 'always'
      },
      'bracketPairsHorizontalBogus': <String, Object?>{
        'bracketPairsHorizontal': 'bogus'
      },
      'bracketPairsHorizontalNumber': <String, Object?>{
        'bracketPairsHorizontal': 1
      },
      'bracketPairsHorizontalNull': <String, Object?>{
        'bracketPairsHorizontal': null
      },
      'highlightActiveBracketPairTrue': <String, Object?>{
        'highlightActiveBracketPair': true
      },
      'highlightActiveBracketPairFalse': <String, Object?>{
        'highlightActiveBracketPair': false
      },
      'highlightActiveBracketPairStringFalse': <String, Object?>{
        'highlightActiveBracketPair': 'false'
      },
      'highlightActiveBracketPairNumber': <String, Object?>{
        'highlightActiveBracketPair': 0
      },
      'highlightActiveBracketPairUndefined': <String, Object?>{
        'highlightActiveBracketPair': null
      },
      'indentationTrue': <String, Object?>{'indentation': true},
      'indentationFalse': <String, Object?>{'indentation': false},
      'indentationStringFalse': <String, Object?>{'indentation': 'false'},
      'indentationNumber': <String, Object?>{'indentation': 0},
      'indentationUndefined': <String, Object?>{'indentation': null},
      'highlightActiveIndentationTrue': <String, Object?>{
        'highlightActiveIndentation': true
      },
      'highlightActiveIndentationFalse': <String, Object?>{
        'highlightActiveIndentation': false
      },
      'highlightActiveIndentationAlways': <String, Object?>{
        'highlightActiveIndentation': 'always'
      },
      'highlightActiveIndentationActive': <String, Object?>{
        'highlightActiveIndentation': 'active'
      },
      'highlightActiveIndentationBogus': <String, Object?>{
        'highlightActiveIndentation': 'bogus'
      },
      'highlightActiveIndentationNumber': <String, Object?>{
        'highlightActiveIndentation': 1
      },
      'highlightActiveIndentationNull': <String, Object?>{
        'highlightActiveIndentation': null
      },
      'allFields': <String, Object?>{
        'bracketPairs': 'active',
        'bracketPairsHorizontal': false,
        'highlightActiveBracketPair': false,
        'indentation': false,
        'highlightActiveIndentation': 'always',
      },
      'allBogus': <String, Object?>{
        'bracketPairs': 'bogus',
        'bracketPairsHorizontal': 'active-that-is-not-allowed',
        'highlightActiveBracketPair': 'false',
        'indentation': 0,
        'highlightActiveIndentation': 'active',
      },
    };

void main() {
  final Map<String, dynamic> truth = _truth('batch227_truth.json');
  final Map<String, dynamic> bp = _map(truth['bracketPairColorization']);
  final Map<String, dynamic> guides = _map(truth['guides']);
  final opts.BracketPairColorization bpOption =
      opts.BracketPairColorization();
  final opts.GuideOptions guideOption = opts.GuideOptions();

  test('BracketPairColorization id, name, defaults and full schema match source',
      () {
    expect(bpOption.id, bp['id']);
    expect(bpOption.name, bp['name']);
    expect(_bracketPairColorization(bpOption.defaultValue), bp['defaultValue']);
    expect(bpOption.schema, bp['schema']);
  });

  test('BracketPairColorization validate matches every source branch', () {
    final Map<String, dynamic> cases = _map(bp['validate']);
    final Map<String, Object?> inputs = _bracketPairColorizationInputs();
    cases.forEach((String key, Object? value) {
      expect(inputs.containsKey(key), isTrue, reason: key);
      final opts.InternalBracketPairColorizationOptions result =
          bpOption.validate(inputs[key]);
      expect(_bracketPairColorization(result), value, reason: key);
    });
    expect(inputs.length, cases.length);
  });

  test('GuideOptions id, name, defaults and full schema match source', () {
    expect(guideOption.id, guides['id']);
    expect(guideOption.name, guides['name']);
    expect(_guides(guideOption.defaultValue), guides['defaultValue']);
    expect(guideOption.schema, guides['schema']);
  });

  test('GuideOptions validate matches every source branch and boundary', () {
    final Map<String, dynamic> cases = _map(guides['validate']);
    final Map<String, Object?> inputs = _guidesInputs();
    cases.forEach((String key, Object? value) {
      expect(inputs.containsKey(key), isTrue, reason: key);
      final opts.InternalGuidesOptions result = guideOption.validate(inputs[key]);
      expect(_guides(result), value, reason: key);
    });
    expect(inputs.length, cases.length);
  });

  test('primitiveSet matches the real-source truth table', () {
    final List<Object?> cases = (truth['primitiveSet'] as List).cast<Object?>();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      final Object? value = c['value'];
      final Object defaultValue = c['defaultValue'] as Object;
      final List<Object> allowed =
          (c['allowedValues'] as List).cast<Object>();
      expect(
        opts.primitiveSet<Object>(value, defaultValue, allowed),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('no platform-specific schema strings in this region', () {
    expect(truth['platformSchemaStrings'], isEmpty);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
