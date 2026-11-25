// batch264: languageFeatureRegistry.ts truth replay.
// Truth from tool/ts2dart/batch264_truth.json (recursive TS transpile+vm,
// real LanguageFeatureRegistry driven by a generic op script).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/languageFeatureRegistry.dart'
    show
        ILanguageFeatureModel,
        LanguageFeatureRegistry,
        NotebookInfo,
        NotebookInfoResolver;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch264_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _selector(Object? raw) {
  if (raw is Map) {
    return raw.map<String, Object?>(
      (k, v) => MapEntry<String, Object?>(k as String, _selector(v)),
    );
  }
  if (raw is List) {
    return raw.map(_selector).toList();
  }
  return raw;
}

class _Model implements ILanguageFeatureModel {
  @override
  final URI uri;
  final String _languageId;
  final bool _tooLarge;
  @override
  final bool isForSimpleWidget;

  _Model(Map<String, dynamic> def)
      : uri = URI.parse(def['uri'] as String),
        _languageId = def['languageId'] as String,
        _tooLarge = def['tooLarge'] as bool? ?? false,
        isForSimpleWidget = def['simpleWidget'] as bool? ?? false;

  @override
  String getLanguageId() => _languageId;

  @override
  bool isTooLargeForSyncing() => _tooLarge;
}

void main() {
  final t = _truth();

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b264 ${c['name']}: registry ops match TS truth', () {
      NotebookInfoResolver? resolver;
      final notebook = c['notebook'];
      if (notebook != null) {
        final nb = notebook as Map<String, dynamic>;
        final nbUriValue = nb['uri'] as String;
        final nbUri = URI.parse(nbUriValue);
        final nbType = nb['type'] as String;
        resolver = (URI uri) => uri.toString() == nbUriValue
            ? NotebookInfo(nbUri, nbType)
            : null;
      }

      final registry = LanguageFeatureRegistry<String>(resolver);
      final events = <int>[];
      registry.onDidChange((n) => events.add(n));

      final disposables = <IDisposable>[];
      final outputs = <Object?>[];

      for (final rawOp in c['ops'] as List<dynamic>) {
        final op = rawOp as Map<String, dynamic>;
        switch (op['op'] as String) {
          case 'register':
            disposables.add(registry.register(
              _selector(op['selector']),
              op['provider'] as String,
            ));
            outputs.add(null);
            break;
          case 'dispose':
            disposables[op['index'] as int].dispose();
            outputs.add(null);
            break;
          case 'has':
            outputs.add(registry.has(_Model(op['model'] as Map<String, dynamic>)));
            break;
          case 'hasForResource':
            outputs.add(registry.hasForResource(
              URI.parse(op['uri'] as String),
              op['languageId'] as String,
            ));
            break;
          case 'all':
            outputs.add(registry.all(_Model(op['model'] as Map<String, dynamic>)));
            break;
          case 'allNoModel':
            outputs.add(registry.allNoModel());
            break;
          case 'registeredLanguageIds':
            outputs.add(registry.registeredLanguageIds.toList());
            break;
          case 'ordered':
            outputs.add(registry.ordered(
              _Model(op['model'] as Map<String, dynamic>),
              op['recursive'] as bool? ?? false,
            ));
            break;
          case 'orderedGroups':
            outputs.add(
                registry.orderedGroups(_Model(op['model'] as Map<String, dynamic>)));
            break;
          default:
            fail('unsupported op: ${op['op']}');
        }
      }

      expect(outputs, c['outputs']);
      expect(events, c['events']);
    });
  }
}
