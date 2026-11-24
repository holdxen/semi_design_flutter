// Truth replay for batch218 (editorOptions.ts segment 3b chunk 1):
//   `WrappingStrategy`, `ShowLightbulbIconMode`, `EditorLightbulb`,
//   `EditorStickyScroll`.
//
// Expectations come from `tool/ts2dart/batch218_truth.json`, produced by
// `tool/ts2dart/_batch218_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private classes exposed through a probe tail).
//
// NOTE: editorOptions.ts has no official unit test; truth comes from executing
// the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch218_truth.json').readAsStringSync()));

class _FakeComputedOptions implements opts.IComputedEditorOptions {
  _FakeComputedOptions(this.accessibilitySupport);

  final int accessibilitySupport;

  @override
  Object? get(Object id) =>
      id == opts.EditorOption.accessibilitySupport ? accessibilitySupport : null;
}

/// `WrappingStrategy.compute` ignores the environment; no member is read.
class _UnusedEnv implements opts.IEnvironmentalOptions {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch218 ShowLightbulbIconMode values match truth', () {
    expect(<String, Object?>{
      'Off': opts.ShowLightbulbIconMode.Off,
      'OnCode': opts.ShowLightbulbIconMode.OnCode,
      'On': opts.ShowLightbulbIconMode.On,
    }, _map(truth['showLightbulbIconMode']));
  });

  test('batch218 WrappingStrategy validates and computes like source', () {
    final Map<String, dynamic> expected = _map(truth['wrappingStrategy']);
    final opts.WrappingStrategy option = opts.WrappingStrategy();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, _map(expected['schema']));

    final Map<String, dynamic> validate = _map(expected['validate']);
    expect(option.validate('simple'), validate['simple']);
    expect(option.validate('advanced'), validate['advanced']);
    expect(option.validate('bogus'), validate['bogus']);
    expect(option.validate(null), validate['undefined']);

    final Map<String, dynamic> compute = _map(expected['compute']);
    expect(
        option.compute(
            _UnusedEnv(),
            _FakeComputedOptions(AccessibilitySupport.Enabled),
            'simple'),
        compute['enabled']);
    expect(
        option.compute(
            _UnusedEnv(),
            _FakeComputedOptions(AccessibilitySupport.Disabled),
            'simple'),
        compute['disabled']);
    expect(
        option.compute(
            _UnusedEnv(),
            _FakeComputedOptions(AccessibilitySupport.Unknown),
            'advanced'),
        compute['unknown']);
  });

  test('batch218 EditorLightbulb matches truth', () {
    final Map<String, dynamic> expected = _map(truth['lightbulb']);
    final opts.EditorLightbulb option = opts.EditorLightbulb();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(<String, Object?>{'enabled': option.defaultValue.enabled},
        _map(expected['defaultValue']));
    expect(option.schema, _map(expected['schema']));

    final Map<String, dynamic> validate = _map(expected['validate']);
    Map<String, Object?> project(opts.EditorLightbulbOptions value) =>
        <String, Object?>{'enabled': value.enabled};

    expect(project(option.validate(null)), _map(validate['undefined']));
    expect(project(option.validate(<String, Object?>{})),
        _map(validate['emptyObject']));
    expect(project(option.validate(<String, Object?>{'enabled': 'off'})),
        _map(validate['off']));
    expect(project(option.validate(<String, Object?>{'enabled': 'on'})),
        _map(validate['on']));
    expect(project(option.validate(<String, Object?>{'enabled': 'bogus'})),
        _map(validate['bogus']));
    expect(project(option.validate(42)), _map(validate['number']));
  });

  test('batch218 EditorStickyScroll clamps and defaults like source', () {
    final Map<String, dynamic> expected = _map(truth['stickyScroll']);
    final opts.EditorStickyScroll option = opts.EditorStickyScroll();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    Map<String, Object?> project(opts.EditorStickyScrollOptions value) =>
        <String, Object?>{
          'enabled': value.enabled,
          'maxLineCount': value.maxLineCount,
          'defaultModel': value.defaultModel,
          'scrollWithEditor': value.scrollWithEditor,
        };

    expect(project(option.defaultValue), _map(expected['defaultValue']));
    expect(option.schema, _map(expected['schema']));

    final Map<String, dynamic> validate = _map(expected['validate']);
    expect(project(option.validate(null)), _map(validate['undefined']));
    expect(project(option.validate(<String, Object?>{})),
        _map(validate['emptyObject']));
    expect(
        project(option.validate(<String, Object?>{'maxLineCount': 0})),
        _map(validate['clampedLow']));
    expect(
        project(option.validate(<String, Object?>{'maxLineCount': 99})),
        _map(validate['clampedHigh']));
    expect(
        project(option.validate(<String, Object?>{'maxLineCount': '7'})),
        _map(validate['stringNumber']));
    expect(
        project(option
            .validate(<String, Object?>{'defaultModel': 'bogus'})),
        _map(validate['bogusModel']));
    expect(
        project(option.validate(
            <String, Object?>{'defaultModel': 'foldingProviderModel'})),
        _map(validate['foldingModel']));
    expect(
        project(option.validate(<String, Object?>{
          'enabled': false,
          'scrollWithEditor': false,
        })),
        _map(validate['booleans']));
  });

  test('batch218 registry records the source size for later chunks', () {
    // The registry is filled by the remaining segments; the source has 180
    // entries (`editorOptionsRegistryLength` in the truth).
    expect(truth['editorOptionsRegistryLength'], 180);
    expect(opts.editorOptionsRegistry, isA<List<Object?>>());
  });
}
