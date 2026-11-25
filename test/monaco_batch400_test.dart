// 1:1 replay of
// `editor/contrib/semanticTokens/common/semanticTokensConfig.ts` (22 lines).
// Truth: `tool/ts2dart/_batch400_truth.cjs` -> `batch400_truth.json`.
//
// NOTE: this file bounced between numbers 331/332, both already owned by a
// concurrent session, so it was parked at 400 to stay out of the way.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/editor/contrib/semanticTokens/common/semanticTokensConfig.dart'
    as config;
import '../lib/src/monaco/platform/configuration/common/configuration.dart'
    show IConfigurationOverrides, IConfigurationServiceType;
import '../lib/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme, IThemeServiceType;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch400_truth.json').readAsStringSync()));

class _FakeModel {
  String getLanguageId() => 'typescript';

  URI get uri => URI.parse('file:///a.ts');
}

class _FakeConfig implements IConfigurationServiceType {
  _FakeConfig(this.value);

  final Object? value;
  final List<List<Object?>> calls = <List<Object?>>[];

  @override
  Object? getValue$3(String section, IConfigurationOverrides overrides) {
    calls.add(<Object?>[
      section,
      overrides.overrideIdentifier,
      overrides.resource?.toString(),
    ]);
    return value;
  }

  @override
  Object? get _serviceBrand => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeThemeService implements IThemeServiceType {
  _FakeThemeService(this.semanticHighlighting);

  final bool semanticHighlighting;

  @override
  IColorTheme getColorTheme() => _FakeTheme(semanticHighlighting);

  @override
  Object? get _serviceBrand => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTheme implements IColorTheme {
  _FakeTheme(this.semanticHighlighting);

  @override
  final bool semanticHighlighting;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final truth = _truth();
  final model = _FakeModel();

  test('setting constant', () {
    expect(config.SEMANTIC_HIGHLIGHTING_SETTING_ID, truth['constant']);
  });

  test('enabled flag resolution and theme fallback', () {
    for (final raw in (truth['cases'] as List)) {
      final entry = raw as List;
      final String name = entry[0] as String;
      final bool withThemeOff = entry[1] as bool;
      final bool withThemeOn = entry[2] as bool;
      final Object? Function() value = _valueFor(name);

      final off = _FakeConfig(value());
      expect(
          config.isSemanticColoringEnabled(
              model, _FakeThemeService(false), off),
          withThemeOff,
          reason: '$name (theme off)');
      expect(off.calls.last, <Object?>[
        'editor.semanticHighlighting',
        'typescript',
        'file:///a.ts',
      ]);
      expect(
          config.isSemanticColoringEnabled(
              model, _FakeThemeService(true), _FakeConfig(value())),
          withThemeOn,
          reason: '$name (theme on)');
    }
  });
}

Object? Function() _valueFor(String name) {
  switch (name) {
    case 'true':
      return () => true;
    case 'false':
      return () => false;
    case 'enabledTrue':
      return () => <String, Object?>{'enabled': true};
    case 'enabledFalse':
      return () => <String, Object?>{'enabled': false};
    case 'configuredByTheme':
      return () => <String, Object?>{'enabled': 'configuredByTheme'};
    case 'enabledMissing':
      return () => <String, Object?>{};
    case 'undefined':
      return () => null;
    case 'null':
      return () => null;
    case 'enabledNull':
      return () => <String, Object?>{'enabled': null};
    case 'number':
      return () => 1;
    case 'stringTrue':
      return () => 'true';
  }
  throw StateError('unknown case $name');
}
