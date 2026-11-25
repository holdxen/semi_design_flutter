// batch266: languageFeatureDebounce.ts truth replay.
// Truth from tool/ts2dart/batch266_truth.json (recursive TS transpile+vm,
// real debounce service with fake log/env/model and real registries).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/languageFeatureRegistry.dart'
    show LanguageFeatureRegistry;
import 'package:semi_design_flutter/src/monaco/editor/common/services/languageFeatureDebounce.dart'
    show
        IDebounceEnvironmentService,
        IDebounceLogService,
        IDebounceModel,
        IFeatureDebounceInformation,
        LanguageFeatureDebounceService;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch266_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Log implements IDebounceLogService {
  final List<Map<String, dynamic>> logs = <Map<String, dynamic>>[];

  @override
  void trace(String message) =>
      logs.add(<String, dynamic>{'level': 'trace', 'message': message});

  @override
  void debug(String message) =>
      logs.add(<String, dynamic>{'level': 'debug', 'message': message});
}

class _Env implements IDebounceEnvironmentService {
  @override
  final bool isExtensionDevelopment;
  @override
  final bool isBuilt;

  _Env(Map<String, dynamic> def)
      : isExtensionDevelopment = def['isExtensionDevelopment'] as bool,
        isBuilt = def['isBuilt'] as bool;
}

class _Model implements IDebounceModel {
  @override
  final String id;
  @override
  final URI uri;
  final String _languageId;
  final bool _tooLarge;
  @override
  final bool isForSimpleWidget;

  _Model(Map<String, dynamic> def)
      : id = def['id'] as String,
        uri = URI.parse(def['uri'] as String),
        _languageId = def['languageId'] as String,
        _tooLarge = def['tooLarge'] as bool? ?? false,
        isForSimpleWidget = def['simpleWidget'] as bool? ?? false;

  @override
  String getLanguageId() => _languageId;

  @override
  bool isTooLargeForSyncing() => _tooLarge;
}

Map<String, Object?>? _config(Object? raw) {
  if (raw == null) return null;
  return (raw as Map).map<String, Object?>(
    (k, v) => MapEntry<String, Object?>(k as String, v),
  );
}

void main() {
  final t = _truth();

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b266 ${c['name']}: debounce values and logs match TS truth', () {
      final log = _Log();
      final service = LanguageFeatureDebounceService(log, _Env(c['env'] as Map<String, dynamic>));

      final registries = <LanguageFeatureRegistry<Object?>>[];
      for (final rawRegistry in c['registries'] as List<dynamic>) {
        final registry = LanguageFeatureRegistry<Object?>();
        for (final _ in rawRegistry['providers'] as List<dynamic>) {
          registry.register('typescript', Object());
        }
        registries.add(registry);
      }

      final infos = <IFeatureDebounceInformation>[];
      final outputs = <Object?>[];
      for (final rawOp in c['ops'] as List<dynamic>) {
        final op = rawOp as Map<String, dynamic>;
        switch (op['op'] as String) {
          case 'for':
            infos.add(service.forFeature(
              registries[op['registry'] as int],
              op['name'] as String,
              _config(op['config']),
            ));
            outputs.add(null);
            break;
          case 'get':
            outputs.add(infos[op['info'] as int]
                .get(_Model(op['model'] as Map<String, dynamic>)));
            break;
          case 'update':
            outputs.add(infos[op['info'] as int].update(
              _Model(op['model'] as Map<String, dynamic>),
              op['value'] as num,
            ));
            break;
          case 'default':
            outputs.add(infos[op['info'] as int].defaultValue());
            break;
          case 'same':
            outputs.add(identical(
                infos[op['a'] as int], infos[op['b'] as int]));
            break;
          default:
            fail('unsupported op: ${op['op']}');
        }
      }

      expect(outputs, c['outputs']);
      expect(log.logs, c['logs']);
    });
  }
}
