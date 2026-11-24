// Truth replay for batch234: editor/common/config/fontInfoFromSettings.ts
// (the whole 2-function file):
//   - createBareFontInfoFromValidatedSettings
//   - createBareFontInfoFromRawSettings
//
// Expectations come from `tool/ts2dart/batch234_truth.json`, produced by
// `tool/ts2dart/_batch234_truth.cjs`, which transpiles and executes the REAL
// `fontInfoFromSettings.ts` (full import chain, `nls` + `platform` stubbed to
// match the Dart macOS host). Every captured BareFontInfo snapshot comes from
// running the real functions, never from a handmade expected list.
//
// `ignoreEditorZoom` is true in every case so the global EditorZoom level
// (mutable state, owned by the already-tested fontInfo.ts batch) cannot make
// the replay non-deterministic. JS `undefined` is normalized to Dart `null`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/editor/common/config/fontInfo.dart'
    show BareFontInfo, IValidatedEditorOptions;
import '../lib/src/monaco/editor/common/config/fontInfoFromSettings.dart' as fis;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch234_truth.json').readAsStringSync()));

/// Serialize a [BareFontInfo] to the same field snapshot the harness captured.
Map<String, Object?> _snap(BareFontInfo bf) => <String, Object?>{
      'pixelRatio': bf.pixelRatio,
      'fontFamily': bf.fontFamily,
      'fontWeight': bf.fontWeight,
      'fontSize': bf.fontSize,
      'fontFeatureSettings': bf.fontFeatureSettings,
      'fontVariationSettings': bf.fontVariationSettings,
      'lineHeight': bf.lineHeight,
      'letterSpacing': bf.letterSpacing,
      'id': bf.getId(),
    };

/// Fake validated-options carrier: `get(id)` returns the value the harness
/// placed at the corresponding REAL `EditorOption` id.
class _ValidatedOptions implements IValidatedEditorOptions {
  _ValidatedOptions(this._values);

  final Map<int, Object?> _values;

  @override
  Object? get(Object id) => _values[id as int];
}

_ValidatedOptions _validated(Map<String, dynamic> values) {
  final Map<int, Object?> byId = <int, Object?>{
    opts.EditorOption.fontFamily: values['fontFamily'],
    opts.EditorOption.fontWeight: values['fontWeight'],
    opts.EditorOption.fontSize: values['fontSize'],
    opts.EditorOption.fontLigatures: values['fontLigatures'],
    opts.EditorOption.fontVariations: values['fontVariations'],
    opts.EditorOption.lineHeight: values['lineHeight'],
    opts.EditorOption.letterSpacing: values['letterSpacing'],
  };
  return _ValidatedOptions(byId);
}

fis.RawFontSettingsOptions _raw(Map<String, dynamic> o) =>
    fis.RawFontSettingsOptions(
      fontFamily: o['fontFamily'],
      fontWeight: o['fontWeight'],
      fontSize: o['fontSize'],
      fontLigatures: o['fontLigatures'],
      fontVariations: o['fontVariations'],
      lineHeight: o['lineHeight'],
      letterSpacing: o['letterSpacing'],
    );

void main() {
  final truth = _truth();

  group('batch234 truth replay - createBareFontInfoFromValidatedSettings', () {
    for (final entry in truth['validated'] as List) {
      final c = _map(entry);
      test('validated: ${c['label']}', () {
        final bf = fis.createBareFontInfoFromValidatedSettings(
          _validated(_map(c['values'])),
          (c['pixelRatio'] as num).toDouble(),
          c['ignoreEditorZoom'] as bool,
        );
        expect(_snap(bf), _map(c['result']));
      });
    }
  });

  group('batch234 truth replay - createBareFontInfoFromRawSettings', () {
    for (final entry in truth['raw'] as List) {
      final c = _map(entry);
      test('raw: ${c['label']}', () {
        final bf = fis.createBareFontInfoFromRawSettings(
          _raw(_map(c['opts'])),
          (c['pixelRatio'] as num).toDouble(),
          c['ignoreEditorZoom'] as bool,
        );
        expect(_snap(bf), _map(c['result']));
      });
    }
  });
}
