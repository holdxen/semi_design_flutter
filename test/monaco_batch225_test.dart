// Truth replay for batch225 (editorOptions.ts lines 4401-4593):
//   unicodeHighlight: InUntrustedWorkspace/inUntrustedWorkspace,
//   IUnicodeHighlightOptions, InternalUnicodeHighlightOptions,
//   unicodeHighlightConfigKeys, primitiveSet, class UnicodeHighlight
//   (defaults, schema, validate, validateBooleanMap, applyUpdate).
//
// Expectations come from `tool/ts2dart/batch225_truth.json`, produced by
// `tool/ts2dart/_batch225_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private class/helper exposed through a probe tail).
// JS `undefined` is replayed as Dart `null` for optional inputs, per the
// convention documented in editorOptions.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth(String file) =>
    _map(jsonDecode(File('tool/ts2dart/$file').readAsStringSync()));

Map<String, Object?> _highlight(
        opts.InternalUnicodeHighlightOptions value) =>
    <String, Object?>{
      'nonBasicASCII': value.nonBasicASCII,
      'invisibleCharacters': value.invisibleCharacters,
      'ambiguousCharacters': value.ambiguousCharacters,
      'includeComments': value.includeComments,
      'includeStrings': value.includeStrings,
      'allowedCharacters': value.allowedCharacters,
      'allowedLocales': value.allowedLocales,
    };

/// `applyUpdate` returns the source's plain object (or a raw update value);
/// the Dart carrier stands in for that object in `validate`/`defaultValue`.
Object? _result(Object? value) => value is opts.InternalUnicodeHighlightOptions
    ? _highlight(value)
    : value;

Map<String, Object?> _freshDefaults() => <String, Object?>{
      'nonBasicASCII': opts.inUntrustedWorkspace,
      'invisibleCharacters': true,
      'ambiguousCharacters': true,
      'includeComments': opts.inUntrustedWorkspace,
      'includeStrings': true,
      'allowedCharacters': <String, Object?>{},
      'allowedLocales': <String, Object?>{'_os': true, '_vscode': true},
    };

// Inputs for every captured `validate` branch (mirrors the truth harness).
Map<String, Object?> _validationInputs() => <String, Object?>{
      'undefined': null,
      'null': null,
      'number': 42,
      'string': 'unicodeHighlight',
      'boolean': true,
      'array': <Object?>[],
      'emptyObject': <String, Object?>{},
      'primitiveTrue': <String, Object?>{
        'nonBasicASCII': true,
        'includeComments': true,
        'includeStrings': true,
      },
      'primitiveFalse': <String, Object?>{
        'nonBasicASCII': false,
        'includeComments': false,
        'includeStrings': false,
      },
      'primitiveUntrusted': <String, Object?>{
        'nonBasicASCII': opts.inUntrustedWorkspace,
        'includeComments': opts.inUntrustedWorkspace,
        'includeStrings': opts.inUntrustedWorkspace,
      },
      'primitiveBogus': <String, Object?>{
        'nonBasicASCII': 'bogus',
        'includeComments': '',
        'includeStrings': 'true',
      },
      'primitiveNonString': <String, Object?>{
        'nonBasicASCII': 0,
        'includeComments': null,
        'includeStrings': <String, Object?>{'a': true},
      },
      'booleansFalse': <String, Object?>{
        'invisibleCharacters': false,
        'ambiguousCharacters': false,
      },
      'booleansTrue': <String, Object?>{
        'invisibleCharacters': true,
        'ambiguousCharacters': true,
      },
      'booleansStringFalse': <String, Object?>{
        'invisibleCharacters': 'false',
        'ambiguousCharacters': 'false',
      },
      'booleansCoerced': <String, Object?>{
        'invisibleCharacters': 0,
        'ambiguousCharacters': 'yes',
      },
      'booleansUndefined': <String, Object?>{
        'invisibleCharacters': null,
        'ambiguousCharacters': null,
      },
      'allowedChars': <String, Object?>{
        'allowedCharacters': <String, Object?>{
          'a': true,
          'b': false,
          'c': 1,
          'd': 'true',
        },
      },
      'allowedCharsEmpty': <String, Object?>{
        'allowedCharacters': <String, Object?>{},
      },
      'allowedCharsNonObject': <String, Object?>{
        'allowedCharacters': 'abc',
      },
      'allowedCharsNull': <String, Object?>{'allowedCharacters': null},
      'allowedLocales': <String, Object?>{
        'allowedLocales': <String, Object?>{
          'en': true,
          'fr': false,
          '_os': 1,
          '_vscode': 'true',
        },
      },
      'allowedLocalesEmpty': <String, Object?>{
        'allowedLocales': <String, Object?>{},
      },
      'allowedLocalesNonObject': <String, Object?>{'allowedLocales': 42},
      'allFields': <String, Object?>{
        'nonBasicASCII': false,
        'invisibleCharacters': false,
        'ambiguousCharacters': false,
        'includeComments': false,
        'includeStrings': opts.inUntrustedWorkspace,
        'allowedCharacters': <String, Object?>{'π': true, 'x': false},
        'allowedLocales': <String, Object?>{'en': true, '_os': false},
      },
    };

// Each entry supplies fresh objects: JS `super.applyUpdate` mutates `value`.
Map<String, Object?> Function() _updateCases(opts.UnicodeHighlight option) =>
    () => <String, Object?>{
      'noUpdate': <Object?>[_freshDefaults(), <String, Object?>{}],
      'carrierValue': <Object?>[
        option.defaultValue,
        <String, Object?>{'ambiguousCharacters': false}
      ],
      'primitiveOnly': <Object?>[
        _freshDefaults(),
        <String, Object?>{'ambiguousCharacters': false}
      ],
      'primitiveUnchanged': <Object?>[
        _freshDefaults(),
        <String, Object?>{'ambiguousCharacters': true}
      ],
      'allowedCharsEqual': <Object?>[
        _freshDefaults(),
        <String, Object?>{'allowedCharacters': <String, Object?>{}}
      ],
      'allowedCharsNew': <Object?>[
        _freshDefaults(),
        <String, Object?>{
          'allowedCharacters': <String, Object?>{'a': true}
        }
      ],
      'allowedCharsReplace': <Object?>[
        <String, Object?>{
          ..._freshDefaults(),
          'allowedCharacters': <String, Object?>{'a': true}
        },
        <String, Object?>{
          'allowedCharacters': <String, Object?>{'b': true}
        }
      ],
      'allowedCharsNull': <Object?>[
        _freshDefaults(),
        <String, Object?>{'allowedCharacters': null}
      ],
      'allowedCharsFalsy': <Object?>[
        _freshDefaults(),
        <String, Object?>{'allowedCharacters': 0}
      ],
      'allowedCharsEmptyString': <Object?>[
        _freshDefaults(),
        <String, Object?>{'allowedCharacters': ''}
      ],
      'allowedCharsStringFalse': <Object?>[
        _freshDefaults(),
        <String, Object?>{'allowedCharacters': 'false'}
      ],
      'allowedLocalesEqual': <Object?>[
        _freshDefaults(),
        <String, Object?>{
          'allowedLocales': <String, Object?>{'_os': true, '_vscode': true}
        }
      ],
      'allowedLocalesNew': <Object?>[
        _freshDefaults(),
        <String, Object?>{
          'allowedLocales': <String, Object?>{'en': true}
        }
      ],
      'allowedLocalesFalse': <Object?>[
        _freshDefaults(),
        <String, Object?>{'allowedLocales': false}
      ],
      'bothMaps': <Object?>[
        _freshDefaults(),
        <String, Object?>{
          'allowedCharacters': <String, Object?>{'a': true},
          'allowedLocales': <String, Object?>{'fr': true},
        }
      ],
      'undefinedValue': <Object?>[
        null,
        <String, Object?>{'ambiguousCharacters': false}
      ],
      'nullValue': <Object?>[
        null,
        <String, Object?>{'ambiguousCharacters': false}
      ],
      'nonObjectUpdate': <Object?>[_freshDefaults(), 'bogus'],
      'allFields': <Object?>[
        _freshDefaults(),
        <String, Object?>{
          'nonBasicASCII': false,
          'invisibleCharacters': false,
          'ambiguousCharacters': false,
          'includeComments': false,
          'includeStrings': false,
          'allowedCharacters': <String, Object?>{'π': true},
          'allowedLocales': <String, Object?>{'en': true},
        }
      ],
    };

void main() {
  final Map<String, dynamic> truth = _truth('batch225_truth.json');
  final Map<String, dynamic> expected = _map(truth['unicodeHighlight']);
  final opts.UnicodeHighlight option = opts.UnicodeHighlight();

  test('InUntrustedWorkspace and config keys match source', () {
    expect(opts.inUntrustedWorkspace, truth['inUntrustedWorkspace']);
    expect(opts.InUntrustedWorkspace.value, truth['inUntrustedWorkspace']);
    expect(opts.unicodeHighlightConfigKeys, truth['configKeys']);
  });

  test('UnicodeHighlight id, name, defaults and full schema match source', () {
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_highlight(option.defaultValue as opts.InternalUnicodeHighlightOptions),
        expected['defaultValue']);
    expect(option.schema, expected['schema']);
    expect(truth['platformSchemaStrings'], isEmpty);
  });

  test('primitiveSet helper matches every source branch', () {
    final Map<String, dynamic> cases = _map(truth['primitiveSet']);
    const List<Object> allowed = <Object>[
      true,
      false,
      opts.inUntrustedWorkspace
    ];
    const Map<String, Object?> inputs = <String, Object?>{
      't': true,
      'f': false,
      'untrusted': opts.inUntrustedWorkspace,
      'bogusString': 'bogus',
      'undefined': null,
      'null': null,
      'number0': 0,
      'number1': 1,
      'stringTrue': 'true',
      'emptyString': '',
      'object': <String, Object?>{'a': true},
      'array': <Object?>[true],
    };
    inputs.forEach((String key, Object? input) {
      expect(
        opts.primitiveSet<Object>(
            input, opts.inUntrustedWorkspace, List<Object>.of(allowed)),
        cases[key],
        reason: key,
      );
    });
    expect(
      opts.primitiveSet<String>(
          'always', 'active', <String>['true', 'false', 'always']),
      cases['otherValid'],
    );
    expect(
      opts.primitiveSet<String>(
          'never', 'active', <String>['true', 'false', 'always']),
      cases['otherInvalid'],
    );
  });

  test('validateBooleanMap branches match source via nested options', () {
    final Map<String, dynamic> cases = _map(truth['validateBooleanMap']);
    final Map<String, Object?> inputs = <String, Object?>{
      'trueOnly': <String, Object?>{
        'a': true,
        'b': false,
        'c': 1,
        'd': 'true',
        'e': null,
        'f': 0,
        'g': '',
      },
      'nested': <String, Object?>{'a': <String, Object?>{'b': true}, 'c': true},
      'empty': <String, Object?>{},
      'undefined': null,
      'null': null,
      'number': 42,
      'string': 'abc',
      'boolean': true,
      'array': <Object?>['x', 'y'],
      'keyOrder': <String, Object?>{'z': true, 'a': true, 'm': false},
    };
    cases.forEach((String key, Object? value) {
      // Directly probe the source's helper with its custom default, then also
      // replay the same input through the nested `allowedCharacters` option.
      expect(
        option.validateBooleanMap(inputs[key], <String, Object?>{'d': true}),
        value,
        reason: key,
      );
      final opts.InternalUnicodeHighlightOptions result =
          option.validate(<String, Object?>{
        'allowedCharacters': inputs[key],
      }) as opts.InternalUnicodeHighlightOptions;
      expect(result.allowedCharacters, isA<Map<String, Object?>>(), reason: key);
    });
  });

  test('UnicodeHighlight validation matches every source branch', () {
    final Map<String, dynamic> cases = _map(expected['validate']);
    final Map<String, Object?> inputs = _validationInputs();
    cases.forEach((String key, Object? value) {
      expect(inputs.containsKey(key), isTrue, reason: key);
      final Object? result = option.validate(inputs[key]);
      expect(result, isA<opts.InternalUnicodeHighlightOptions>(), reason: key);
      expect(_highlight(result as opts.InternalUnicodeHighlightOptions), value,
          reason: key);
    });
  });

  test('UnicodeHighlight applyUpdate matches every source branch', () {
    final Map<String, dynamic> cases = _map(expected['applyUpdate']);
    final Map<String, Object?> Function() makeInputs = _updateCases(option);
    cases.forEach((String key, Object? value) {
      final List<Object?> inputs = makeInputs()[key] as List<Object?>;
      final Map<String, dynamic> expectedResult = _map(value);
      final opts.ApplyUpdateResult<Object?> result =
          option.applyUpdate(inputs[0], inputs[1]);
      expect(result.didChange, expectedResult['didChange'], reason: key);
      expect(_result(result.newValue), expectedResult['newValue'], reason: key);
    });
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
