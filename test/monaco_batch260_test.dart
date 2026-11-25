// batch260: editor/common/services/markerDecorations.ts — declaration-only truth.
// Truth from tool/ts2dart/batch260_truth.json (recursive TS transpile+vm loader
// for the decorator; source AST for erased interface shapes).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/services/markerDecorations.dart'
    show IMarkerDecorationsService;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;
import 'package:semi_design_flutter/src/monaco/platform/markers/common/markers.dart'
    show IMarkerService;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch260_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final t = _truth();

  test('b260 decorator id + memoize match truth', () {
    final d = t['decorator'] as Map<String, dynamic>;
    expect(d['exportedName'], 'IMarkerDecorationsService');
    expect(IMarkerDecorationsService.toString(), d['id']);
    expect(identical(createDecorator(d['serviceId'] as String),
        IMarkerDecorationsService), isTrue);
    expect(d['memoized'], isTrue);
    expect(d['typeOf'], 'function');
  });

  test('b260 TS runtime export is only the decorator', () {
    expect(t['exportKeys'], <String>['IMarkerDecorationsService']);
  });

  test('b260 decorator identity distinct from IMarkerService', () {
    expect(t['distinctFromMarkerService'], isTrue);
    expect(identical(IMarkerDecorationsService, IMarkerService), isFalse);
  });

  test('b260 interface AST shapes match 1:1 Dart declarations', () {
    final interfaces = t['interfaces'] as Map<String, dynamic>;
    final limitNames = (interfaces['IMarkerLimit'] as List)
        .map((e) => e['name'] as String)
        .toList();
    final svcNames = (interfaces['IMarkerDecorationsService'] as List)
        .map((e) => e['name'] as String)
        .toList();

    expect(limitNames, <String>[
      'isMarkersSourceTruncated',
      'isMarkersTruncated',
    ]);
    expect(svcNames, <String>[
      '_serviceBrand',
      'onDidChangeMarker',
      'onDidChangeMarkerLimit',
      'getMarker',
      'getLiveMarkers',
      'getMarkerLimits',
      'addMarkerSuppression',
    ]);

    final limitTypes = (interfaces['IMarkerLimit'] as List)
        .map((e) => e['type'] as String)
        .toList();
    final svcTypes = (interfaces['IMarkerDecorationsService'] as List)
        .map((e) => e['type'] as String)
        .toList();
    expect(limitTypes, <String>['boolean', 'number | undefined']);
    expect(svcTypes, <String>[
      'undefined',
      'Event<ITextModel>',
      'Event<ITextModel>',
      'IMarker | null',
      '[Range, IMarker][]',
      'IMarkerLimit | undefined',
      'IDisposable',
    ]);

    final src = File(
      'lib/src/monaco/editor/common/services/markerDecorations.dart',
    ).readAsStringSync();
    for (final name in [...limitNames, ...svcNames]) {
      expect(src.contains(name), isTrue, reason: 'missing Dart member: $name');
    }
    // Key TS->Dart adaptations that must stay in sync with the AST truth.
    expect(src, contains('num? get isMarkersTruncated'));
    expect(src, contains('List<(Range, IMarker)> getLiveMarkers'));
    expect(src, contains('IMarkerLimit? getMarkerLimits'));
    expect(src, contains('Event<ITextModelForMarkerDecorations>'));
  });
}
