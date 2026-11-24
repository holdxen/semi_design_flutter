// Truth replay for batch223 (editorOptions.ts lines 4101-4189):
//   rulers (IRulerOption, EditorRulers), readonly (ReadonlyMessage).
//
// Expectations come from `tool/ts2dart/batch223_truth.json`, produced by
// `tool/ts2dart/_batch223_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private classes exposed through a probe tail).
// JS `undefined` is replayed as Dart `null` for the optional inputs, and the
// harness projects the source's `color: undefined` to an explicit `null`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch223_truth.json').readAsStringSync()));

Map<String, Object?> _ruler(opts.IRulerOption ruler) => <String, Object?>{
      'column': ruler.column,
      'color': ruler.color,
    };

List<Object?> _rulers(List<opts.IRulerOption> rulers) =>
    rulers.map(_ruler).toList();

void main() {
  final Map<String, dynamic> truth = _truth();

  test('IRulerOption carries column and color', () {
    const opts.IRulerOption bare = opts.IRulerOption(column: 80, color: null);
    expect(bare.column, 80);
    expect(bare.color, isNull);

    const opts.IRulerOption colored =
        opts.IRulerOption(column: 100, color: '#ff0000');
    expect(colored.column, 100);
    expect(colored.color, '#ff0000');
  });

  test('EditorRulers matches source id, name, defaults and schema', () {
    final Map<String, dynamic> expected = _map(truth['rulers']);
    final opts.EditorRulers option = opts.EditorRulers();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_rulers(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);
  });

  test('EditorRulers validation matches source', () {
    final Map<String, dynamic> expected = _map(truth['rulers']);
    final opts.EditorRulers option = opts.EditorRulers();
    final Map<String, dynamic> cases = _map(expected['validate']);

    // Non-array inputs return `defaultValue`.
    expect(_rulers(option.validate(null)), cases['undefined']);
    expect(_rulers(option.validate(null)), cases['null']);
    expect(_rulers(option.validate(42)), cases['number']);
    expect(_rulers(option.validate('50')), cases['string']);
    expect(_rulers(option.validate(<Object?>[])), cases['emptyArray']);

    // Numeric elements: clamped to [0, 10000] and sorted by column.
    expect(_rulers(option.validate(<Object?>[300, 100, 200])),
        cases['unsorted']);
    expect(_rulers(option.validate(<Object?>[-5, -1, 0])), cases['clampedLow']);
    expect(_rulers(option.validate(<Object?>[10000, 10001, 99999])),
        cases['clampedHigh']);
    expect(_rulers(option.validate(<Object?>[50.9, -50.9])), cases['float']);
    // Strings are not numbers at the element gate, so they are skipped.
    expect(_rulers(option.validate(<Object?>['50', '70px', 'abc'])),
        cases['numericStrings']);

    // Object elements: `column` clamped, `color` forwarded verbatim (the
    // schema only declares `format: 'color-hex'`; validate does no parsing).
    expect(
      _rulers(option.validate(<Object?>[
        <String, Object?>{'column': 120, 'color': '#ff0000'},
        <String, Object?>{'column': 80},
      ])),
      cases['objects'],
    );
    expect(
      _rulers(option.validate(<Object?>[
        <String, Object?>{'column': -1, 'color': '#000000'},
        <String, Object?>{'column': 20000, 'color': null},
      ])),
      cases['objectClamps'],
    );
    expect(
      _rulers(option.validate(<Object?>[
        <String, Object?>{'column': 100, 'color': '#abc'},
        50,
        <String, Object?>{'column': 200},
      ])),
      cases['mixed'],
    );
    expect(
      _rulers(option.validate(<Object?>[
        null,
        null,
        true,
        'x',
        <String, Object?>{},
        <String, Object?>{'column': 5},
      ])),
      cases['bogusElements'],
    );
  });

  test('ReadonlyMessage matches source defaults, schema and validation', () {
    final Map<String, dynamic> expected = _map(truth['readonlyMessage']);
    final opts.ReadonlyMessage option = opts.ReadonlyMessage();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, expected['schema']);

    final Map<String, dynamic> cases = _map(expected['validate']);
    // Dart carries both JS `undefined` and JS `null` as `null`.
    expect(option.validate(null), cases['undefined']);
    expect(option.validate(null), cases['null']);
    expect(option.validate(false), cases['false']);
    expect(option.validate(0), cases['zero']);
    expect(option.validate(''), cases['emptyString']);
    expect(option.validate('hello'), cases['string']);
    // Any object (including arrays and empty maps) is forwarded unchanged.
    expect(option.validate(<String, Object?>{}), cases['emptyObject']);
    expect(
      option.validate(<String, Object?>{
        'value': 'Read only',
        'isTrusted': true,
      }),
      cases['markdown'],
    );
    expect(option.validate(<Object?>[1, 2]), cases['array']);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
