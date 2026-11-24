// Truth replay for batch229 (editorOptions.ts lines 5585–5711):
//   smartSelect region: ISmartSelectOptions / SmartSelectOptions and class
//     SmartSelect (defaults, full schema, validate) plus the `boolean` helper
//     its validate uses;
//   tabFocusMode region: class EditorTabFocusMode (inherited boolean
//     validate/default/schema and its `compute` override driven by
//     `env.tabFocusMode`);
//   wordSegmenterLocales region: class WordSegmenterLocales (defaults, full
//     schema, validate) including the `Intl.Segmenter.supportedLocalesOf`
//     gate, replayed through `validate` so the private carrier needs no
//     public surface.
//
// Expectations come from `tool/ts2dart/batch229_truth.json`, produced by
// `tool/ts2dart/_batch229_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private classes exposed via a probe tail). Every
// validate case carries its own normalized input, so this replay needs no
// hand-mirrored input table. JS `undefined` is replayed as Dart `null`, per the
// convention documented in editorOptions.dart.
//
// No platform selection is needed: none of these three regions reads
// `platform.*`. The runtime-dependent `Intl.Segmenter.supportedLocalesOf`
// truth is captured from the real (Node/full-ICU) source under
// `segmenterSupportedLocalesOf` and replayed via single-string `validate`
// calls (supported => `[locale]`, otherwise `[]`).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth(String file) =>
    _map(jsonDecode(File('tool/ts2dart/$file').readAsStringSync()));

Map<String, Object?> _smartSelect(opts.SmartSelectOptions value) =>
    <String, Object?>{
      'selectLeadingAndTrailingWhitespace':
          value.selectLeadingAndTrailingWhitespace,
      'selectSubwords': value.selectSubwords,
    };

/// Only `tabFocusMode` is read by `EditorTabFocusMode.compute`; every other
/// member of `IEnvironmentalOptions` is unused.
class _FakeEnv implements opts.IEnvironmentalOptions {
  _FakeEnv(this.tabFocusMode);

  @override
  bool tabFocusMode;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeComputedOptions implements opts.IComputedEditorOptions {
  @override
  Object? get(Object id) => null;
}

/// Mirrors the truth harness's platform-token scan so any token-bearing schema
/// string captured from the real source must also be present in the Dart port.
final RegExp _platformToken = RegExp(
    r'\b(linux|macintosh|macos|windows|web|native|browser|electron)\b',
    caseSensitive: false);

void _collectPlatformStrings(Object? value, String path, List<Object?> out) {
  if (value is String) {
    if (_platformToken.hasMatch(value)) {
      out.add(<String, Object?>{'path': path, 'value': value});
    }
  } else if (value is List) {
    for (int i = 0; i < value.length; i++) {
      _collectPlatformStrings(value[i], '$path[$i]', out);
    }
  } else if (value is Map) {
    value.forEach((Object? key, Object? v) {
      _collectPlatformStrings(v, path.isEmpty ? '$key' : '$path.$key', out);
    });
  }
}

void main() {
  final Map<String, dynamic> truth = _truth('batch229_truth.json');

  test('SmartSelect id, name, defaults and full schema match source', () {
    final Map<String, dynamic> expected = _map(truth['smartSelect']);
    final opts.SmartSelect option = opts.SmartSelect();
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_smartSelect(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);
  });

  test('SmartSelect validate matches every captured branch and boundary', () {
    final List<Object?> cases =
        (_map(truth['smartSelect'])['validate'] as List).cast<Object?>();
    final opts.SmartSelect option = opts.SmartSelect();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      expect(
        _smartSelect(option.validate(c['input'])),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('boolean matches the real-source truth table', () {
    final List<Object?> cases = (truth['boolean'] as List).cast<Object?>();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      expect(
        opts.boolean(c['value'] as Object?, c['defaultValue'] as bool),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('EditorTabFocusMode defaults, schema, validate and compute match source',
      () {
    final Map<String, dynamic> expected = _map(truth['tabFocusMode']);
    final opts.EditorTabFocusMode option = opts.EditorTabFocusMode();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, expected['schema']);

    final Map<String, dynamic> validate = _map(expected['validate']);
    expect(option.validate(null), validate['undefined']);
    expect(option.validate('false'), validate['stringFalse']);
    expect(option.validate('true'), validate['stringTrue']);
    expect(option.validate(0), validate['zero']);
    expect(option.validate(1), validate['one']);
    expect(option.validate(true), validate['true']);
    expect(option.validate(false), validate['false']);

    final Map<String, dynamic> compute = _map(expected['compute']);
    expect(
      option.compute(_FakeEnv(true), _FakeComputedOptions(), false),
      compute['envTrue_valueFalse'],
    );
    expect(
      option.compute(_FakeEnv(false), _FakeComputedOptions(), true),
      compute['envFalse_valueTrue'],
    );
  });

  test('WordSegmenterLocales id, name, defaults and full schema match source',
      () {
    final Map<String, dynamic> expected =
        _map(truth['wordSegmenterLocales']);
    final opts.WordSegmenterLocales option = opts.WordSegmenterLocales();
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, expected['schema']);
  });

  test('WordSegmenterLocales validate matches every captured branch', () {
    final List<Object?> cases =
        (_map(truth['wordSegmenterLocales'])['validate'] as List)
            .cast<Object?>();
    final opts.WordSegmenterLocales option = opts.WordSegmenterLocales();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      expect(
        option.validate(c['input']),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('Segmenter locale predicate matches the real-source truth table', () {
    final List<Object?> cases =
        (truth['segmenterSupportedLocalesOf'] as List).cast<Object?>();
    final opts.WordSegmenterLocales option = opts.WordSegmenterLocales();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      final String locale = c['locale'] as String;
      final List<String> expected =
          c['result'] == true ? <String>[locale] : <String>[];
      expect(
        option.validate(locale),
        expected,
        reason: locale,
      );
    }
  });

  test('platform-token schema strings match the real source', () {
    final List<Object?> captured = <Object?>[];
    _collectPlatformStrings(opts.SmartSelect().schema, '', captured);
    _collectPlatformStrings(opts.EditorTabFocusMode().schema, '', captured);
    _collectPlatformStrings(opts.WordSegmenterLocales().schema, '', captured);
    expect(captured, truth['platformSchemaStrings']);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
