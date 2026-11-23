// batch62: configuration.ts. All assertions are data-driven from
// configuration_truth.json (Node TS transpile+vm real evaluation of the file
// and its real local dependency chain).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/configuration_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

/// JS `undefined` marker used as an input value (distinct from Dart `null` =
/// JS `null`), so the truth's `__undefined__` sentinels can be reproduced.
final Object jsUndef = Object();

/// Encode a Dart value into the truth's normalized form:
/// null -> '__null__', [jsUndef] -> '__undefined__', URI -> {'__uri__': ...},
/// Map/List recursively.
Object? enc(Object? v) {
  if (v == null) return '__null__';
  if (identical(v, jsUndef)) return '__undefined__';
  if (v is URI) return <String, Object?>{'__uri__': v.toString()};
  if (v is Map) {
    return v.map((k, val) => MapEntry<String, Object?>(k.toString(), enc(val)));
  }
  if (v is List) return v.map(enc).toList();
  return v;
}

/// Both nullish sentinels are interchangeable at Dart's `null` boundary.
bool _sentinelEq(Object? a, Object? b) {
  if (a == b) return true;
  const nullish = <String>{'__null__', '__undefined__'};
  return nullish.contains(a) && nullish.contains(b);
}

void expectEnc(Object? actual, Object? expected, String reason) {
  final a = enc(actual);
  if (!_sentinelEq(a, expected)) {
    expect(a, expected, reason: reason);
  }
}

void main() {
  final truth = _truth();
  final uriA = URI.parse('file:///a/b');

  test('b62 decorator id and memoize', () {
    final d = truth['decorator'] as Map<String, dynamic>;
    expect(IConfigurationService.toString(), d['id']);
    expect(
        identical(createDecorator('configurationService'), IConfigurationService),
        d['memoized'] as bool);
  });

  test('b62 ConfigurationTarget enum values', () {
    final e = truth['targetEnum'] as Map<String, dynamic>;
    expect(ConfigurationTarget.APPLICATION, e['APPLICATION']);
    expect(ConfigurationTarget.USER, e['USER']);
    expect(ConfigurationTarget.USER_LOCAL, e['USER_LOCAL']);
    expect(ConfigurationTarget.USER_REMOTE, e['USER_REMOTE']);
    expect(ConfigurationTarget.WORKSPACE, e['WORKSPACE']);
    expect(ConfigurationTarget.WORKSPACE_FOLDER, e['WORKSPACE_FOLDER']);
    expect(ConfigurationTarget.DEFAULT, e['DEFAULT']);
    expect(ConfigurationTarget.MEMORY, e['MEMORY']);
  });

  test('b62 ConfigurationTargetToString all + out of range', () {
    const byName = <String, int>{
      'APPLICATION': ConfigurationTarget.APPLICATION,
      'USER': ConfigurationTarget.USER,
      'USER_LOCAL': ConfigurationTarget.USER_LOCAL,
      'USER_REMOTE': ConfigurationTarget.USER_REMOTE,
      'WORKSPACE': ConfigurationTarget.WORKSPACE,
      'WORKSPACE_FOLDER': ConfigurationTarget.WORKSPACE_FOLDER,
      'DEFAULT': ConfigurationTarget.DEFAULT,
      'MEMORY': ConfigurationTarget.MEMORY,
    };
    for (final c in truth['targetToString'] as List) {
      final m = c as Map<String, dynamic>;
      final input = byName[m['in'] as String] ?? int.parse(m['in'] as String);
      final result = ConfigurationTargetToString(input);
      expect(result ?? '__undefined__', m['result'], reason: '${m['in']}');
    }
  });

  test('b62 isConfigurationOverrides JS && short-circuit truth', () {
    final inputs = <String, Object?>{
      'null': null,
      'undefined': null,
      'false': false,
      '0': 0,
      'empty-string': '',
      'string': 'abc',
      'number': 42,
      'empty-object': <String, Object?>{},
      'overrideIdentifier-string': {'overrideIdentifier': 'python'},
      'overrideIdentifier-number': {'overrideIdentifier': 42},
      'overrideIdentifier-null': {'overrideIdentifier': null},
      'overrideIdentifier-empty': {'overrideIdentifier': ''},
      'resource-uri': {'resource': uriA},
      'resource-string': {'resource': 'file:///a/b'},
      'resource-null': {'resource': null},
      'resource-false': {'resource': false},
      'both-valid': {'overrideIdentifier': 'python', 'resource': uriA},
      'both-bad': {'overrideIdentifier': 1, 'resource': 'x'},
    };
    for (final c in truth['isConfigurationOverrides'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      expectEnc(isConfigurationOverrides(inputs[name]), m['result'], name);
    }
  });

  test('b62 isConfigurationUpdateOverrides JS && short-circuit truth', () {
    final inputs = <String, Object?>{
      'null': null,
      'undefined': null,
      'false': false,
      '0': 0,
      'empty-string': '',
      'empty-object': <String, Object?>{},
      'overrideIdentifiers-array': {'overrideIdentifiers': ['python', 'js']},
      'overrideIdentifiers-empty-array': {'overrideIdentifiers': <String>[]},
      'overrideIdentifiers-null': {'overrideIdentifiers': null},
      'overrideIdentifiers-string': {'overrideIdentifiers': 'python'},
      'overrideIdentifiers-number': {'overrideIdentifiers': 42},
      'has-overrideIdentifier': {'overrideIdentifier': 'python'},
      'has-overrideIdentifier-falsy': {'overrideIdentifier': ''},
      'resource-uri': {'resource': uriA},
      'resource-string': {'resource': 'x'},
      'both-valid': {'resource': uriA, 'overrideIdentifiers': ['python']},
      'both-bad': {
        'resource': 'x',
        'overrideIdentifier': 'python',
        'overrideIdentifiers': ['python'],
      },
    };
    for (final c in truth['isConfigurationUpdateOverrides'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      expectEnc(isConfigurationUpdateOverrides(inputs[name]), m['result'], name);
    }
  });

  test('b62 getConfigValueInTarget all scopes + assertNever default', () {
    final cv = <String, Object?>{
      'applicationValue': 'app',
      'userValue': 'user',
      'userLocalValue': 'local',
      'userRemoteValue': 'remote',
      'workspaceValue': 'ws',
      'workspaceFolderValue': 'wsf',
      'defaultValue': 'def',
      'memoryValue': 'mem',
      'policyValue': 'policy',
      'value': 'value',
    };
    const byScope = <String, int>{
      'APPLICATION': ConfigurationTarget.APPLICATION,
      'USER': ConfigurationTarget.USER,
      'USER_LOCAL': ConfigurationTarget.USER_LOCAL,
      'USER_REMOTE': ConfigurationTarget.USER_REMOTE,
      'WORKSPACE': ConfigurationTarget.WORKSPACE,
      'WORKSPACE_FOLDER': ConfigurationTarget.WORKSPACE_FOLDER,
      'DEFAULT': ConfigurationTarget.DEFAULT,
      'MEMORY': ConfigurationTarget.MEMORY,
    };
    for (final c in truth['getConfigValueInTarget'] as List) {
      final m = c as Map<String, dynamic>;
      final scope = m['scope'] as String;
      if (m.containsKey('error')) {
        expect(() => getConfigValueInTarget(cv, int.parse(scope)),
            throwsA(isA<StateError>()),
            reason: scope);
      } else {
        expect(getConfigValueInTarget(cv, byScope[scope]!), m['result'],
            reason: scope);
      }
    }
  });

  test('b62 isConfigured uses !== undefined semantics', () {
    final inputs = <String, Map<String, Object?>>{
      'empty': {},
      'application': {'applicationValue': 1},
      'user': {'userValue': 1},
      'userLocal': {'userLocalValue': 1},
      'userRemote': {'userRemoteValue': 1},
      'workspace': {'workspaceValue': 1},
      'workspaceFolder': {'workspaceFolderValue': 1},
      'default-only': {'defaultValue': 1},
      'memory-only': {'memoryValue': 1},
      'policy-only': {'policyValue': 1},
      'value-only': {'value': 1},
      'app-null': {'applicationValue': null},
      'app-zero': {'applicationValue': 0},
      'app-empty-string': {'applicationValue': ''},
    };
    for (final c in truth['isConfigured'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      expect(isConfigured(inputs[name]!), m['result'], reason: name);
    }
  });

  test('b62 toValuesTree dotted keys, conflicts, null parents, __proto__', () {
    final inputs = <String, Map<String, Object?>>{
      'simple': {'a.b': 1, 'a.c': 2, 'd': 3},
      'conflict': {'a.b': 1, 'a.b.c': 2},
      'null-parent': {'a.b.c': 1, 'a': null},
      'scalar-parent': {'a.b.c': 1, 'a': 5},
      'array-parent': {'a.b.c': 1, 'a': [1, 2]},
      'proto-pollute': {'__proto__.polluted': true, 'a.b': 1},
      'top-level-dotted': {'a.b.c.d': 4},
      'empty-key': {'': 1},
    };
    for (final c in truth['toValuesTree'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      final conflicts = <String>[];
      final tree = toValuesTree(inputs[name]!, conflicts.add);
      expectEnc(<String, Object?>{'tree': tree, 'conflicts': conflicts},
          m['result'], name);
    }
  });

  test('b62 addToValueTree conflict semantics', () {
    final inputs = <String, List<Object?>>{
      'fresh': [<String, Object?>{}, 'a.b.c', 1],
      'existing-leaf': [{'a': {'b': 1}}, 'a.b', 2],
      'null-intermediate': [{'a': null}, 'a.b.c', 1],
      'scalar-intermediate': [{'a': 5}, 'a.b.c', 1],
      'array-intermediate': [{'a': [1]}, 'a.b.c', 1],
      'proto-key': [<String, Object?>{}, '__proto__.x', 1],
      'single-segment': [<String, Object?>{}, 'key', 'value'],
    };
    for (final c in truth['addToValueTree'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      final arg = inputs[name]!;
      final root = Map<String, Object?>.from(arg[0] as Map<String, Object?>);
      final conflicts = <String>[];
      addToValueTree(root, arg[1] as String, arg[2], conflicts.add);
      expectEnc(<String, Object?>{'tree': root, 'conflicts': conflicts},
          m['result'], name);
    }
  });

  test('b62 removeFromValueTree official scenarios', () {
    final inputs = <String, List<Object?>>{
      'non-existing': [{'a': {'b': 1}}, 'x'],
      'multi-part': [{'a': {'b': 1, 'c': 2}, 'd': 3}, 'a.b'],
      'single-segment': [{'a': 1, 'b': 2}, 'a'],
      'single-undefined': [{'a': jsUndef, 'b': 2}, 'a'],
      'multi-undefined': [{'a': {'b': null, 'c': 2}}, 'a.b'],
      'multi-array': [{'a': {'b': [1, 2], 'c': 3}}, 'a.b'],
      'first-array': [{'a': [1, 2], 'b': 3}, 'a.b'],
      'first-segment': [{'a': {'b': 1}, 'c': 2}, 'a'],
      'first-node-more': [{'a': {'b': 1, 'c': 2}, 'd': 3}, 'a.b'],
      'in-between-more': [{'a': {'b': {'c': 1, 'd': 2}, 'e': 3}}, 'a.b.c'],
      'last-but-one-more': [{'a': {'b': {'c': 1, 'd': 2}}}, 'a.b.c'],
    };
    for (final c in truth['removeFromValueTree'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      final arg = inputs[name]!;
      final tree = Map<String, Object?>.from(arg[0] as Map<String, Object?>);
      removeFromValueTree(tree, arg[1] as String);
      expectEnc(tree, m['result'], name);
    }
  });

  test('b62 getConfigurationValue undefined vs null and array index', () {
    final cfg = <String, Object?>{
      'a': {'b': {'c': 42}},
      'x': null,
      'y': false,
      'z': 0,
      'arr': [1, 2, 3],
    };
    for (final c in truth['getConfigurationValue'] as List) {
      final m = c as Map<String, dynamic>;
      final path = m['settingPath'] as String;
      final expected = m['result'] as Map<String, dynamic>;
      final noDefault = getConfigurationValue(cfg, path);
      final withDefault = getConfigurationValue(cfg, path, 'FALLBACK');
      expectEnc(noDefault, expected['noDefault'], '$path noDefault');
      expectEnc(withDefault, expected['withDefault'], '$path withDefault');
    }
  });

  test('b62 merge simple/object/array/__proto__/type-mismatch', () {
    final inputs = <String, List<Object?>>{
      'simple-true': [{'a': 1, 'b': 2}, {'a': 3, 'c': 4}, true],
      'simple-false': [{'a': 1, 'b': 2}, {'a': 3, 'c': 4}, false],
      'object-true': [
        {'a': {'b': 1, 'c': true, 'd': 2}},
        {'a': {'b': jsUndef, 'c': false, 'e': 'a'}},
        true,
      ],
      'object-false': [
        {'a': {'b': 1, 'c': true}},
        {'a': {'b': 2, 'd': 3}},
        false,
      ],
      'array-true': [{'a': ['b', 'c']}, {'a': ['d']}, true],
      'array-false': [{'a': ['b', 'c']}, {'a': ['d']}, false],
      'proto-key': [
        <String, Object?>{},
        {'__proto__': {'polluted': true}, 'a': 1},
        true,
      ],
      'type-mismatch': [{'a': 1}, {'a': {'b': 2}}, true],
    };
    for (final c in truth['merge'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      final arg = inputs[name]!;
      final base = Map<String, Object?>.from(arg[0] as Map<String, Object?>);
      merge(base, arg[1] as Map<String, Object?>, arg[2] as bool);
      expectEnc(base, m['result'], name);
    }
  });

  test('b62 getLanguageTagSettingPlainKey regex chain', () {
    for (final c in truth['languageTagKey'] as List) {
      final m = c as Map<String, dynamic>;
      expect(getLanguageTagSettingPlainKey(m['in'] as String), m['result'],
          reason: '${m['in']}');
    }
  });
}
