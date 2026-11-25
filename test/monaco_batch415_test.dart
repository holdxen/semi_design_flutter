// 1:1 replay of `editor/browser/services/renameSymbolTrackerService.ts`.
// Truth: `tool/ts2dart/_batch415_truth.cjs` -> `batch415_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/services/renameSymbolTrackerService.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch415_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('rename symbol tracker service replay TS truth', () {
    final NullRenameSymbolTrackerService service =
        NullRenameSymbolTrackerService();
    final Object? tracked = service.trackedWord.get();
    final Map<String, Object?> actual = <String, Object?>{
      'service-id': <String, Object?>{
        'toString': IRenameSymbolTrackerService.toString(),
      },
      'null-service': <String, Object?>{
        'trackedWord': tracked == null ? 'undefined' : tracked.toString(),
      },
    };

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
