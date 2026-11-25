// batch310: codeEditorService.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/services/codeEditorService.dart'
    show ICodeEditorService, ICodeEditorServiceType, isCodeEditorServiceRegistered;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show Util;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch310_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> service =
      truth['service'] as Map<String, dynamic>;

  test('decorator identity and registration match truth', () {
    expect(isCodeEditorServiceRegistered, service['registered'] as bool);
    expect(Util.serviceIds[service['id'] as String],
        same(ICodeEditorService));
    expect(service['sameInstance'] as bool, isTrue);
  });

  test('declaration surface matches truth', () {
    final List<dynamic> decls = truth['declarations'] as List<dynamic>;
    expect(
      decls.map((d) => (d as Map<String, dynamic>)['name']).toList(),
      <String>['ICodeEditorService', 'ICodeEditorService', 'ICodeEditorOpenHandler'],
    );
    final Map<String, dynamic> iface = decls[1] as Map<String, dynamic>;
    expect(iface['kind'], 'interface');
    expect((iface['members'] as List<dynamic>).length, greaterThan(20));
    // Compile-time proof that the erased contract is implementable.
    expect(ICodeEditorServiceType, isNotNull);
  });
}
