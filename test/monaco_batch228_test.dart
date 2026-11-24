// Truth replay for batch228 (editorOptions.ts lines 5084-5583):
//   suggest region: ISuggestOptions / InternalSuggestOptions and class
//     EditorSuggest (defaults, full schema, validate) plus the two helpers
//     validate uses: `stringSet` and `boolean` truth tables.
//
// Expectations come from `tool/ts2dart/batch228_truth.json`, produced by
// `tool/ts2dart/_batch228_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; the class/helpers exposed via a probe tail). Every
// validate case carries its own normalized input, so this replay needs no
// hand-mirrored input table. JS `undefined` is replayed as Dart `null`, per the
// convention documented in editorOptions.dart. The source quirk where an
// `undefined` `snippetsPreventQuickSuggestions` falls back to the
// `filterGraceful` default, and the JS-array-is-an-object behavior, are both
// replayed verbatim.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth(String file) =>
    _map(jsonDecode(File('tool/ts2dart/$file').readAsStringSync()));

Map<String, Object?> _suggest(opts.InternalSuggestOptions value) =>
    <String, Object?>{
      'insertMode': value.insertMode,
      'filterGraceful': value.filterGraceful,
      'snippetsPreventQuickSuggestions': value.snippetsPreventQuickSuggestions,
      'localityBonus': value.localityBonus,
      'shareSuggestSelections': value.shareSuggestSelections,
      'selectionMode': value.selectionMode,
      'showIcons': value.showIcons,
      'showStatusBar': value.showStatusBar,
      'preview': value.preview,
      'previewMode': value.previewMode,
      'showInlineDetails': value.showInlineDetails,
      'fitWidthToDetails': value.fitWidthToDetails,
      'showMethods': value.showMethods,
      'showFunctions': value.showFunctions,
      'showConstructors': value.showConstructors,
      'showDeprecated': value.showDeprecated,
      'matchOnWordStartOnly': value.matchOnWordStartOnly,
      'showFields': value.showFields,
      'showVariables': value.showVariables,
      'showClasses': value.showClasses,
      'showStructs': value.showStructs,
      'showInterfaces': value.showInterfaces,
      'showModules': value.showModules,
      'showProperties': value.showProperties,
      'showEvents': value.showEvents,
      'showOperators': value.showOperators,
      'showUnits': value.showUnits,
      'showValues': value.showValues,
      'showConstants': value.showConstants,
      'showEnums': value.showEnums,
      'showEnumMembers': value.showEnumMembers,
      'showKeywords': value.showKeywords,
      'showWords': value.showWords,
      'showColors': value.showColors,
      'showFiles': value.showFiles,
      'showReferences': value.showReferences,
      'showFolders': value.showFolders,
      'showTypeParameters': value.showTypeParameters,
      'showIssues': value.showIssues,
      'showUsers': value.showUsers,
      'showSnippets': value.showSnippets,
    };

// Mirrors the truth harness's platform-token scan so any token-bearing schema
// string captured from the real source must also be present in the Dart port.
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
      _collectPlatformStrings(
          v, path.isEmpty ? '$key' : '$path.$key', out);
    });
  }
}

void main() {
  final Map<String, dynamic> truth = _truth('batch228_truth.json');
  final Map<String, dynamic> suggest = _map(truth['suggest']);
  final opts.EditorSuggest suggestOption = opts.EditorSuggest();

  test('EditorSuggest id, name, defaults and full schema match source', () {
    expect(suggestOption.id, suggest['id']);
    expect(suggestOption.name, suggest['name']);
    expect(_suggest(suggestOption.defaultValue), suggest['defaultValue']);
    expect(suggestOption.schema, suggest['schema']);
  });

  test('EditorSuggest validate matches every captured branch and boundary', () {
    final List<Object?> cases =
        (suggest['validate'] as List).cast<Object?>();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      final opts.InternalSuggestOptions result =
          suggestOption.validate(c['input']);
      expect(
        _suggest(result),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('stringSet matches the real-source truth table', () {
    final List<Object?> cases = (truth['stringSet'] as List).cast<Object?>();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      final Map<String, String>? renamed = c['renamedValues'] == null
          ? null
          : (c['renamedValues'] as Map).cast<String, String>();
      expect(
        opts.stringSet<String>(
          c['value'] as Object?,
          c['defaultValue'] as String,
          (c['allowedValues'] as List).cast<String>(),
          renamed,
        ),
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

  test('platform-token schema strings match the real source', () {
    final List<Object?> captured = <Object?>[];
    _collectPlatformStrings(suggestOption.schema, '', captured);
    expect(captured, truth['platformSchemaStrings']);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
