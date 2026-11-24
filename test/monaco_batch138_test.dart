// Truth-driven test for batch138:
// editor/test/browser/controller/nativeEditContextUtils.test.ts
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/test/browser/controller/nativeEditContextUtils.test.dart'
    as suite;

final Map<String, Object?> _truth =
    jsonDecode(File('tool/ts2dart/batch138_truth.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _obj(Object? value) =>
    (value as Map).cast<String, Object?>();

List<Object?> _list(Object? value) => (value as List).cast<Object?>();

void main() {
  test('NativeEditContextUtils suite scenario', () {
    final Map<String, Object?> actual = suite.runSuite();
    expect(actual['suiteName'], _truth['suiteName']);
    expect(actual['testName'], _truth['testName']);
    final List<Object?> truthResults = _list(_truth['results']);
    final List<Object?> actualResults = _list(actual['results']);
    expect(actualResults.length, truthResults.length);
    for (int i = 0; i < truthResults.length; i++) {
      final Map<String, Object?> e = _obj(truthResults[i]);
      final Map<String, Object?> a = _obj(actualResults[i]);
      expect(_obj(a['actual']), _obj(e['actual']));
      expect(_obj(a['expected']), _obj(e['expected']));
      expect(a['equal'], e['equal']);
    }
    expect(actual['focusCalls'], _truth['focusCalls']);
  });
}
