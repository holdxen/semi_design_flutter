// Truth replay for batch238: editor/common/config/editorConfigurationSchema.ts
// (the whole 387-line file). Expectations come from
// `tool/ts2dart/batch238_truth.json`, produced by
// `tool/ts2dart/_batch238_truth.cjs`, which transpiles and executes the REAL TS
// source (all 180 real editorOptions + registry, real diffEditor.ts,
// textModelDefaults.ts, configurationRegistry.ts and platform.ts; nls + platform
// stubbed to match the Dart host). Every captured value comes from executing
// the real source, never from a handmade expected list.
//
// NOTE: relative `../lib/...` imports are intentional (all batch tests do this).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/jsonSchema.dart' show IJSONSchemaSnippet;
import '../lib/src/monaco/editor/common/config/editorConfigurationSchema.dart'
    as schema;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch238_truth.json').readAsStringSync()));

/// Deep JSON-equality.
///   - A missing map key and an explicit `null` are treated as equal: the TS
///     truth normalizes `undefined` -> `null`, while Dart omits absent keys.
///   - `num` compares by value (int 4 == double 4.0), matching JS numbers.
///   - [IJSONSchemaSnippet] instances are converted to their JSON form so a
///     stored `defaultSnippets` list can be compared to the captured truth.
bool _jsonEqual(Object? a, Object? b) {
  a = _snippetToJson(a);
  b = _snippetToJson(b);
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

Object? _snippetToJson(Object? value) {
  if (value is IJSONSchemaSnippet) {
    return <String, Object?>{
      if (value.label != null) 'label': value.label,
      if (value.description != null) 'description': value.description,
      if (value.body != null) 'body': value.body,
      if (value.bodyText != null) 'bodyText': value.bodyText,
    };
  }
  if (value is List) {
    return value.map<Object?>(_snippetToJson).toList();
  }
  return value;
}

String _describe(Object? value) => jsonEncode(_snippetToJson(value));

List<IJSONSchemaSnippet> _snippetsFromJson(Object? value) {
  final List<dynamic> list = (value as List).cast<dynamic>();
  return list.map<IJSONSchemaSnippet>((Object? e) {
    final Map<String, dynamic> m = _map(e);
    return IJSONSchemaSnippet()
      ..label = m['label'] as String?
      ..description = m['description'] as String?
      ..body = m['body']
      ..bodyText = m['bodyText'] as String?;
  }).toList();
}

void main() {
  final truth = _truth();

  test('baseNode fields match real source', () {
    final Map<String, dynamic> expected = _map(truth['baseNode']);
    final node = schema.editorConfigurationBaseNode;
    expect(node.id, expected['id']);
    expect(node.order, expected['order']);
    expect(node.type, expected['type']);
    expect(node.title, expected['title']);
    expect(node.scope, expected['scope']);
  });

  test('editorConfiguration node metadata matches real source', () {
    final Map<String, dynamic> expected = _map(truth['nodeMeta']);
    final node = schema.editorConfiguration;
    expect(node.id, expected['id']);
    expect(node.order, expected['order']);
    expect(node.type, expected['type']);
    expect(node.title, expected['title']);
    expect(node.scope, expected['scope']);
  });

  test('property key set and count match real source', () {
    final List<String> expectedKeys =
        (truth['propertyKeys'] as List).map((Object? e) => e as String).toList();
    final List<String> actualKeys =
        schema.editorConfiguration.properties!.keys.toList()..sort();
    expect(actualKeys, expectedKeys);
    expect(actualKeys.length, truth['propertyCount']);
  });

  test('every property schema matches real source', () {
    final Map<String, dynamic> expected = _map(truth['properties']);
    final Map<String, Map<String, Object?>> actual =
        schema.editorConfiguration.properties!;
    for (final String key in expected.keys) {
      expect(
        actual.containsKey(key),
        isTrue,
        reason: 'missing property $key',
      );
      expect(
        _jsonEqual(actual[key], expected[key]),
        isTrue,
        reason: 'schema mismatch for $key\n'
            '  actual:   ${_describe(actual[key])}\n'
            '  expected: ${_describe(expected[key])}',
      );
    }
    expect(actual.length, expected.length);
  });

  test('hand-written and injected property subsets match real source', () {
    final Map<String, dynamic> handWritten = _map(truth['handWritten']);
    final Map<String, dynamic> injected = _map(truth['injected']);
    final Map<String, Map<String, Object?>> actual =
        schema.editorConfiguration.properties!;

    for (final String key in handWritten.keys) {
      final Object? expected = handWritten[key];
      if (expected == null) {
        // `included: false` -> removed from properties at registration.
        expect(actual.containsKey(key), isFalse, reason: 'excluded key $key');
      } else {
        expect(
          _jsonEqual(actual[key], expected),
          isTrue,
          reason: 'hand-written mismatch for $key',
        );
      }
    }
    for (final String key in injected.keys) {
      expect(
        _jsonEqual(actual[key], injected[key]),
        isTrue,
        reason: 'injected mismatch for $key',
      );
    }
  });

  test('isConfigurationPropertySchema truth table', () {
    for (final Object? e in truth['guardCases'] as List) {
      final Map<String, dynamic> c = _map(e);
      final Map<String, Object?> input = _map(c['input']);
      expect(
        schema.isConfigurationPropertySchema(input),
        c['result'],
        reason: 'guard case ${c['label']}',
      );
    }
  });

  test('key predicate truth tables', () {
    for (final Object? e in truth['keyCases'] as List) {
      final Map<String, dynamic> c = _map(e);
      final String key = c['key'] as String;
      final bool result = c['fn'] == 'isEditorConfigurationKey'
          ? schema.isEditorConfigurationKey(key)
          : schema.isDiffEditorConfigurationKey(key);
      expect(result, c['result'], reason: '${c['fn']}($key)');
    }
  });

  test('registerEditorFontConfigurations effect', () async {
    final Map<String, dynamic> fc = _map(truth['fontConfigurations']);
    final Map<String, Map<String, Object?>> properties =
        schema.editorConfiguration.properties!;
    expect(
      _jsonEqual(properties['editor.fontFamily']!['defaultSnippets'], fc['before']),
      isTrue,
      reason: 'defaultSnippets before registration must match',
    );

    final List<IJSONSchemaSnippet> snippets =
        _snippetsFromJson(fc['input']);
    int calls = 0;
    await schema.registerEditorFontConfigurations(() async {
      calls++;
      return snippets;
    });
    expect(calls, fc['getFontSnippetsCalled']);
    expect(
      _jsonEqual(properties['editor.fontFamily']!['defaultSnippets'], fc['after']),
      isTrue,
      reason: 'defaultSnippets after registration must match',
    );
  });
}
