// 1:1 replay of
// `editor/contrib/gotoSymbol/test/browser/referencesModel.test.ts` (42 lines).
// Truth: `tool/ts2dart/_batch451_truth.cjs` -> `batch451_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/contrib/gotoSymbol/browser/referencesModel.dart'
    show ReferenceLocation, ReferencesModel;
import '../lib/src/monaco/editor/contrib/gotoSymbol/test/browser/referencesModel.test.dart'
    as official;
import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch451_truth.json').readAsStringSync()));

void main() {
  final truth = _truth();

  test('the official suite runs', () {
    official.runAll();
  });

  test('nearestReference matches the real TS results', () {
    final model = ReferencesModel(<ReferenceLocation>[
      ReferenceLocation(URI.file('/out/obj/can'), Range(1, 1, 1, 1)),
      ReferenceLocation(URI.file('/out/obj/can2'), Range(1, 1, 1, 1)),
      ReferenceLocation(URI.file('/src/can'), Range(1, 1, 1, 1)),
    ], 'FOO');

    expect(model.references.length, truth['count']);
    expect(model.title, truth['title']);

    final paths = <String, String?>{};
    for (final raw in (truth['results'] as List)) {
      final entry = _map(raw);
      final label = entry['label'] as String;
      final String? actual =
          model.nearestReference(URI.file(entry['path'] as String), Position(1, 1))
              ?.uri
              .path;
      paths[label] = actual;
    }
    // Expected values are the official assertions (identical in the TS run).
    expect(paths, <String, String?>{
      'srcCan': '/src/can',
      'srcOther': '/src/can',
      'outOther': '/out/obj/can',
      'outCan2222': '/out/obj/can2',
    });
  });
}
