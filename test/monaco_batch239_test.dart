// Truth replay for batch239: editor/test/browser/config/
// editorLayoutProvider.test.dart (1:1 port of the 810-line TS test file).
//
// Expectations come from `tool/ts2dart/batch239_truth.json`, produced by
// `tool/ts2dart/_batch239_truth.cjs`, which transpiles and executes the REAL TS
// test alongside the REAL editorOptions.ts (EditorLayoutInfoComputer.computeLayout)
// and editorConfiguration.ts (ComputedEditorOptions). The mocha globals are
// stubbed so every test runs and every `deepStrictEqual(actual, expected)`
// pair is captured. All 21 captured cases are replayed here.
//
// NOTE: relative `../lib/...` imports are intentional (all batch tests do this).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/test/browser/config/editorLayoutProvider.test.dart'
    as layout;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch239_truth.json').readAsStringSync()));

/// Deep JSON-equality: missing key == explicit null, `num` compares by value.
bool _jsonEqual(Object? a, Object? b) {
  if (a == null || b == null) return a == null && b == null;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    final Set<String> keys = <String>{
      ...a.keys.map((Object? k) => k.toString()),
      ...b.keys.map((Object? k) => k.toString()),
    };
    for (final String key in keys) {
      if (!_jsonEqual(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_jsonEqual(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

String _describe(Object? value) => jsonEncode(value);

void main() {
  final truth = _truth();
  final List<dynamic> cases = (truth['cases'] as List).cast<dynamic>();

  test('truth file captured every mocha case', () {
    expect(truth['testCount'], 21);
    expect(truth['assertionCount'], 21);
    expect(cases.length, 21);
    expect(
      cases.map<Object?>((Object? e) => _map(e)['name']).toSet().length,
      21,
      reason: 'case names must be unique',
    );
  });

  test('the ported Dart functions still satisfy their own assertions', () {
    layout.runAllEditorLayoutProviderTests();
  });

  test('every captured case replays against the real TS source', () {
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      final String name = c['name'] as String;
      final List<dynamic> assertions =
          (c['assertions'] as List).cast<dynamic>();
      expect(assertions.length, 1, reason: 'one deepStrictEqual per case: $name');

      final Map<String, dynamic> assertion = _map(assertions.single);
      final Object? truthActual = assertion['actual'];
      final Object? truthExpected = assertion['expected'];

      // The harness validates the source's own assertion before capturing;
      // assert it here too so a mutated truth file cannot pass silently.
      expect(
        _jsonEqual(truthActual, truthExpected),
        isTrue,
        reason: 'truth actual must equal source expected for $name',
      );

      final Object? dartActual = layout.actualForCaseNameForTest(name);
      expect(
        dartActual,
        isNotNull,
        reason: 'no Dart case registered for "$name"',
      );
      expect(
        _jsonEqual(dartActual, truthActual),
        isTrue,
        reason: 'replay mismatch for $name\n'
            '  Dart:  ${_describe(dartActual)}\n'
            '  truth: ${_describe(truthActual)}',
      );

      final Object? dartExpected = layout.expectedForCaseNameForTest(name);
      if (dartExpected != null) {
        expect(
          _jsonEqual(dartExpected, truthExpected),
          isTrue,
          reason: 'port expected literal mismatch for $name\n'
              '  Dart:  ${_describe(dartExpected)}\n'
              '  truth: ${_describe(truthExpected)}',
        );
      }
    }
  });
}
