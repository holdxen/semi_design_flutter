// batch288: languagesRegistry.ts truth replay.
// Truth from tool/ts2dart/batch288_truth.json (recursive TS transpile+vm,
// real LanguageIdCodec + LanguagesRegistry with useModesRegistry=false).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/languages/language.dart'
    show ILanguageExtensionPoint;
import 'package:semi_design_flutter/src/monaco/editor/common/services/languagesRegistry.dart'
    show LanguageIdCodec, LanguagesRegistry;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch288_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) =>
        MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

ILanguageExtensionPoint _makeDef(Map<String, dynamic> d) =>
    ILanguageExtensionPoint(
      id: d['id'] as String,
      extensions: (d['extensions'] as List<dynamic>?)?.cast<String>(),
      filenames: (d['filenames'] as List<dynamic>?)?.cast<String>(),
      filenamePatterns:
          (d['filenamePatterns'] as List<dynamic>?)?.cast<String>(),
      firstLine: d['firstLine'] as String?,
      aliases: (d['aliases'] as List<dynamic>?)?.cast<String>(),
      mimetypes: (d['mimetypes'] as List<dynamic>?)?.cast<String>(),
      configuration: d['configuration'] == null
          ? null
          : URI.parse(
              (d['configuration'] as Map)['external'] as String? ??
                  (d['configuration'] as Map)['path'] as String),
    );

void main() {
  final t = _truth();

  test('b288 LanguageIdCodec encode/decode truth', () {
    final codec = LanguageIdCodec();
    // Replay the exact probe order from harness.
    final probes = <String>[
      'vs.editor.nullLanguage', 'plaintext', 'typescript', 'python', 'unknown-lang',
      'typescript', 'python',
    ];
    codec.register('typescript');
    codec.register('python');
    codec.register('typescript'); // duplicate
    int pi = 0;
    for (final p in t['codec']['probes'] as List<dynamic>) {
      final raw = p as Map<String, dynamic>;
      expect(raw['language'], probes[pi++]);
      final encoded = codec.encodeLanguageId(raw['language'] as String);
      expect(encoded, raw['encoded'], reason: 'encode ${raw['language']}');
      expect(codec.decodeLanguageId(encoded), raw['decoded'],
          reason: 'decode roundtrip ${raw['language']}');
    }
    for (final p in t['codec']['decode'] as List<dynamic>) {
      final raw = p as Map<String, dynamic>;
      expect(codec.decodeLanguageId((raw['id'] as num).toInt()), raw['decoded'],
          reason: 'decode ${raw['id']}');
    }
  });

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b288 ${c['name']}: registry truth', () {
      final registry = LanguagesRegistry(false, false);
      registry.registerLanguages(
          (c['defs'] as List<dynamic>).map((d) => _makeDef(d as Map<String, dynamic>)).toList());
      if ((c['dynamic'] as List<dynamic>).isNotEmpty) {
        registry.setDynamicLanguages((c['dynamic'] as List<dynamic>)
            .map((d) => _makeDef(d as Map<String, dynamic>))
            .toList());
      }

      final outputs = <Object?>[];
      for (final rawQ in c['queries'] as List<dynamic>) {
        final q = rawQ as Map<String, dynamic>;
        final arg = q['arg'];
        Object? value;
        switch (q['op'] as String) {
          case 'isRegisteredLanguageId':
            value = registry.isRegisteredLanguageId(arg as String?);
            break;
          case 'getRegisteredLanguageIds':
            value = registry.getRegisteredLanguageIds();
            break;
          case 'getLanguageName':
            value = registry.getLanguageName(arg as String);
            break;
          case 'getMimeType':
            value = registry.getMimeType(arg as String);
            break;
          case 'getExtensions':
            value = registry.getExtensions(arg as String);
            break;
          case 'getFilenames':
            value = registry.getFilenames(arg as String);
            break;
          case 'getIcon':
            value = registry.getIcon(arg as String);
            break;
          case 'getConfigurationFiles':
            value = registry.getConfigurationFiles(arg as String)
                .map((u) => u.toString())
                .toList();
            break;
          case 'getSortedRegisteredLanguageNames':
            value = registry.getSortedRegisteredLanguageNames()
                .map((p) => <String, Object?>{
                      'languageName': p.languageName,
                      'languageId': p.languageId,
                    })
                .toList();
            break;
          case 'getLanguageIdByLanguageName':
            value = registry.getLanguageIdByLanguageName(arg as String);
            break;
          case 'getLanguageIdByMimeType':
            value = registry.getLanguageIdByMimeType(arg as String?);
            break;
          case 'guessLanguageIdByFilepathOrFirstLine':
            final uri = q['uri'];
            value = registry.guessLanguageIdByFilepathOrFirstLine(
              uri == null ? null : URI.parse(uri as String),
              q['firstLine'] as String?,
            );
            break;
          default:
            fail('unknown query ${q['op']}');
        }
        outputs.add(<String, Object?>{
          'op': q['op'],
          'arg': arg,
          'uri': q['uri'],
          'firstLine': q['firstLine'],
          'value': value,
        });
      }

      expect(_norm(outputs), c['outputs'], reason: 'outputs ${c['name']}');

      final codecIds = registry.getRegisteredLanguageIds().map((id) =>
          <String, Object?>{
            'id': id,
            'encoded': registry.languageIdCodec.encodeLanguageId(id),
          }).toList();
      expect(_norm(codecIds), c['codecIds'], reason: 'codecIds ${c['name']}');

      registry.dispose();
    });
  }
}
