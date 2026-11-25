// batch303: markerDecorations.ts truth replay.
// Truth from tool/ts2dart/batch303_truth.json (recursive TS transpile + vm,
// contribution ID, no-op dispose and erased class surface).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/services/markerDecorations.dart'
    show IEditorContributionForMarkerDecorations, MarkerDecorationsContribution;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch303_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> runtime = truth['runtime'] as Map<String, dynamic>;

  test('contribution ID and dispose match truth', () {
    expect(MarkerDecorationsContribution.ID, truth['id'] as String);
    final IEditorContributionForMarkerDecorations contribution =
        MarkerDecorationsContribution(Object(), Object());
    expect(runtime['constructed'] as bool, isTrue);
    contribution.dispose();
    expect(runtime['disposeReturnedUndefined'] as bool, isTrue);
  });

  test('class surface matches truth', () {
    final declarations = truth['declarations'] as List<dynamic>;
    expect(declarations.length, 1);
    final Map<String, dynamic> cls = declarations[0] as Map<String, dynamic>;
    expect(cls['kind'], 'class');
    expect(cls['name'], 'MarkerDecorationsContribution');
    // The null member is the constructor in the TS AST.
    expect((cls['members'] as List<dynamic>).whereType<String>().toList(),
        <String>['ID', 'dispose']);
  });
}
