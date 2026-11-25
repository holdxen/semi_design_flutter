// batch284: languagesAssociations.ts truth replay.
// Truth from tool/ts2dart/batch284_truth.json (recursive TS transpile+vm,
// real module-level registry driven by register/clear/get queries).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/services/languagesAssociations.dart'
    show
        ILanguageAssociation,
        clearConfiguredLanguageAssociations,
        clearPlatformLanguageAssociations,
        getLanguageIds,
        getMimeTypes,
        registerConfiguredLanguageAssociation,
        registerPlatformLanguageAssociation;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch284_truth.json').readAsStringSync())
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

ILanguageAssociation _makeAssoc(Map<String, dynamic> a) {
  RegExp? firstline;
  final fl = a['firstline'];
  if (fl is Map && fl['source'] != null) {
    firstline = RegExp(fl['source'] as String,
        multiLine: (fl['flags'] as String? ?? '').contains('m'),
        caseSensitive: !(fl['flags'] as String? ?? '').contains('i'));
  }
  return ILanguageAssociation(
    id: a['id'] as String,
    mime: a['mime'] as String,
    filename: a['filename'] as String?,
    extension: a['extension'] as String?,
    filepattern: a['filepattern'] as String?,
    firstline: firstline,
  );
}

void main() {
  final t = _truth();

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b284 ${c['name']}: associations match TS truth', () {
      // Reset module-level state, mirroring harness.
      clearPlatformLanguageAssociations();
      clearConfiguredLanguageAssociations();

      for (final rawR in c['register'] as List<dynamic>) {
        final r = rawR as Map<String, dynamic>;
        final assoc = _makeAssoc(r['association'] as Map<String, dynamic>);
        if (r['kind'] == 'platform') {
          registerPlatformLanguageAssociation(assoc, r['warn'] as bool);
        } else {
          registerConfiguredLanguageAssociation(assoc);
        }
      }

      final outputs = <Object?>[];
      for (final rawOp in c['ops'] as List<dynamic>) {
        final op = rawOp as Map<String, dynamic>;
        switch (op['op'] as String) {
          case 'get':
            final URI? resource =
                op['uri'] == null ? null : URI.parse(op['uri'] as String);
            final String? firstLine = op['firstLine'] as String?;
            outputs.add(<String, Object?>{
              'mimes': getMimeTypes(resource, firstLine),
              'languageIds': getLanguageIds(resource, firstLine),
            });
            break;
          case 'clearPlatform':
            clearPlatformLanguageAssociations();
            outputs.add(null);
            break;
          case 'clearConfigured':
            clearConfiguredLanguageAssociations();
            outputs.add(null);
            break;
          default:
            fail('unknown op ${op['op']}');
        }
      }

      expect(_norm(outputs), c['outputs'], reason: 'outputs ${c['name']}');
      // The TS harness records console.warn count for conflict registration;
      // Dart port keeps the same conflict branches (commented warn sites), so
      // query behavior is validated via outputs above.
    });
  }
}
