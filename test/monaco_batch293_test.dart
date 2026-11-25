// batch293: languageService.ts truth replay.
// Truth from tool/ts2dart/batch293_truth.json (recursive TS transpile + vm,
// real LanguageService / LanguagesRegistry / observable selection).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/languages/language.dart'
    show ILanguageExtensionPoint, ILanguageIcon, ILanguageSelection;
import 'package:semi_design_flutter/src/monaco/editor/common/services/languageService.dart'
    show LanguageService;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch293_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) => MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

String? _s(Object? v) => v as String?;
List<String>? _ss(Object? v) =>
    (v as List<dynamic>?)?.map((e) => e as String).toList();

ILanguageExtensionPoint _def(Map<String, dynamic> d) => ILanguageExtensionPoint(
      id: d['id'] as String,
      extensions: _ss(d['extensions']),
      filenames: _ss(d['filenames']),
      filenamePatterns: _ss(d['filenamePatterns']),
      firstLine: _s(d['firstLine']),
      aliases: _ss(d['aliases']),
      mimetypes: _ss(d['mimetypes']),
      configuration: d['configuration'] == null
          ? null
          : URI.parse(d['configuration'] as String),
      icon: d['icon'] == null
          ? null
          : ILanguageIcon(
              URI.parse((d['icon'] as Map<String, dynamic>)['light'] as String),
              URI.parse((d['icon'] as Map<String, dynamic>)['dark'] as String),
            ),
    );

Object? _icon(ILanguageIcon? icon) => icon == null
    ? null
    : <String, Object?>{
        'light': icon.light.toString(),
        'dark': icon.dark.toString(),
      };

Map<String, Object?> _snapshot(LanguageService service, String label,
    List<ILanguageSelection> selections, Map<String, List<Object?>> events) {
  final List<Object?> probes = <Object?>[
    'typescript', 'javascript', 'python', 'json', 'plaintext', 'unknown', null,
  ];
  final List<Object?> queries = probes.map((Object? id) {
    final String? sid = id as String?;
    return <String, Object?>{
      'id': id,
      'registered': service.isRegisteredLanguageId(sid),
      'name': sid == null ? null : service.getLanguageName(sid),
      'mime': sid == null ? null : service.getMimeType(sid),
      'icon': sid == null ? null : _icon(service.getIcon(sid)),
      'extensions': sid == null ? <Object?>[] : service.getExtensions(sid),
      'filenames': sid == null ? <Object?>[] : service.getFilenames(sid),
      'configs': sid == null
          ? <Object?>[]
          : service.getConfigurationFiles(sid).map((u) => u.toString()).toList(),
      'byName': sid == null ? null : service.getLanguageIdByLanguageName(sid),
      'byMime': service.getLanguageIdByMimeType(sid),
      'guessFile': service.guessLanguageIdByFilepathOrFirstLine(
        sid == null
            ? null
            : URI.parse('file:///tmp/a${sid.startsWith('.') ? sid : '.$sid'}'),
      ),
      'guessFirstLine': service.guessLanguageIdByFilepathOrFirstLine(
        URI.parse('file:///tmp/unknown.zzz'),
        sid,
      ),
    };
  }).toList();
  return <String, Object?>{
    'label': label,
    'instanceCount': LanguageService.instanceCount,
    'registered': service.getRegisteredLanguageIds(),
    'names': service
        .getSortedRegisteredLanguageNames()
        .map((n) => <String, Object?>{
              'languageName': n.languageName,
              'languageId': n.languageId,
            })
        .toList(),
    'codec': <Object?>[
      'typescript', 'python', 'json',
    ].map((Object? id) {
      final int encoded = service.languageIdCodec.encodeLanguageId(id as String);
      return <Object?>[
        encoded,
        service.languageIdCodec.decodeLanguageId(encoded),
      ];
    }).toList(),
    'queries': queries,
    'selections': selections.map((s) => s.languageId).toList(),
    'basicEvents': events['basic'],
    'richEvents': events['rich'],
    'changeEvents': events['change'],
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();
  group('batch293 languageService truth replay', () {
    for (final dynamic rawCase in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = rawCase as Map<String, dynamic>;
      test(c['name'] as String, () {
        final LanguageService service =
            LanguageService(c['warnOnOverwrite'] as bool);
        final List<ILanguageSelection> selections = <ILanguageSelection>[];
        final Map<String, List<Object?>> events = <String, List<Object?>>{
          'basic': <Object?>[],
          'rich': <Object?>[],
          'change': <Object?>[],
        };
        service.onDidRequestBasicLanguageFeatures((id) => events['basic']!.add(id));
        service.onDidRequestRichLanguageFeatures((id) => events['rich']!.add(id));
        service.onDidChange((_) => events['change']!.add('change'));

        final List<dynamic> ops = c['ops'] as List<dynamic>;
        final List<dynamic> results = c['results'] as List<dynamic>;
        int resultIndex = 0;
        for (final dynamic rawOp in ops) {
          final Map<String, dynamic> op = rawOp as Map<String, dynamic>;
          final String label = op['label'] as String;
          late Map<String, Object?> snap;
          switch (op['kind'] as String) {
            case 'snapshot':
              snap = _snapshot(service, label, selections, events);
              break;
            case 'register':
              final d = service.registerLanguage(_def(op['language'] as Map<String, dynamic>));
              if (op['dispose'] == true) d.dispose();
              snap = _snapshot(service, label, selections, events);
              break;
            case 'select':
              final String factory = op['factory'] as String;
              if (factory == 'id') {
                selections.add(service.createById(_s(op['value'])));
              } else if (factory == 'mime') {
                selections.add(service.createByMimeType(_s(op['value'])));
              } else {
                selections.add(service.createByFilepathOrFirstLine(
                  op['uri'] == null ? null : URI.parse(op['uri'] as String),
                  _s(op['firstLine']),
                ));
              }
              snap = _snapshot(service, label, selections, events);
              break;
            case 'requestBasic':
              service.requestBasicLanguageFeatures(op['id'] as String);
              snap = _snapshot(service, label, selections, events);
              break;
            case 'requestRich':
              service.requestRichLanguageFeatures(op['id'] as String);
              snap = _snapshot(service, label, selections, events);
              break;
            default:
              fail('unknown op ${op['kind']}');
          }
          expect(snap, _norm(results[resultIndex++] as Object?));
        }
        expect(resultIndex, results.length);
        service.dispose();
        expect(LanguageService.instanceCount,
            c['instanceCountAfterDispose'] as int);
      });
    }
  });
}
