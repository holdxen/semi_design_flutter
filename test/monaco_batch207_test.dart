// Truth replay for batch207:
//   `editor/standalone/common/standaloneTheme.ts`
//   `editor/standalone/common/themes.ts`
//
// Expectations come from `tool/ts2dart/batch207_truth.json`, produced by
// `tool/ts2dart/_batch207_truth.cjs` (the real transpiled sources). `themes.ts`
// is pure data, so the dumps below are the authoritative theme tables; the
// ported `themes.dart` was generated from the same truth.
//
// `theme.colors` is keyed by the runtime values of the ported color-id
// constants, so comparing the whole colors map also validates that the
// constants carry the exact registry ids used by the source's computed keys
// (`[editorBackground]: ...`).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/languages/supports/tokenization.dart'
    as tok;
import '../lib/src/monaco/editor/standalone/common/standaloneTheme.dart'
    as standalone;
import '../lib/src/monaco/editor/standalone/common/standaloneTheme.dart'
    show BuiltinTheme, IStandaloneThemeService;
import '../lib/src/monaco/editor/standalone/common/themes.dart'
    show hc_black, hc_light, vs, vs_dark;

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch207_truth.json').readAsStringSync()));

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, Object?> _ruleToTruth(tok.ITokenThemeRule rule) =>
    <String, Object?>{
      'token': rule.token,
      'foreground': rule.foreground,
      'background': rule.background,
      'fontStyle': rule.fontStyle,
    };

Map<String, Object?> _themeToTruth(standalone.IStandaloneThemeData theme) =>
    <String, Object?>{
      'base': theme.base,
      'inherit': theme.inherit,
      'rules': theme.rules.map(_ruleToTruth).toList(),
      'encodedTokensColors': theme.encodedTokensColors,
      'colors': theme.colors,
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('themes: the four built-in tables match the real source', () {
    final Map<String, dynamic> expected = _map(truth['themes']);

    expect(_themeToTruth(vs), _exp(expected['vs']));
    expect(_themeToTruth(vs_dark), _exp(expected['vs_dark']));
    expect(_themeToTruth(hc_black), _exp(expected['hc_black']));
    expect(_themeToTruth(hc_light), _exp(expected['hc_light']));
  });

  test('builtin theme name constants', () {
    expect(BuiltinTheme.vs, 'vs');
    expect(BuiltinTheme.vsDark, 'vs-dark');
    expect(BuiltinTheme.hcBlack, 'hc-black');
    expect(BuiltinTheme.hcLight, 'hc-light');
  });

  test('IStandaloneThemeService decorator id', () {
    expect(IStandaloneThemeService.toString(),
        _exp(truth['standaloneThemeServiceId']));
  });
}