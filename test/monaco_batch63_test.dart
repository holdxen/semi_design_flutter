// batch63: markers.ts. All assertions are data-driven from
// markers_truth.json (Node TS transpile+vm real evaluation of the file and its
// real local dependency chain: severity.ts / strings.ts / instantiation.ts /
// uri.ts / event.ts).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/severity.dart'
    show Severity;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;
import 'package:semi_design_flutter/src/monaco/platform/markers/common/markers.dart';

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/markers_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

/// JS undefined carrier (switch fall-through in fromSeverity/toSeverity).
const _undef = '__undefined__';

void main() {
  final truth = _truth();

  test('b63 decorator id and memoize', () {
    final d = truth['decorator'] as Map<String, dynamic>;
    expect(IMarkerService.toString(), d['id']);
    expect(identical(createDecorator('markerService'), IMarkerService),
        d['memoized'] as bool);
  });

  test('b63 MarkerTag const enum values', () {
    final e = truth['markerTag'] as Map<String, dynamic>;
    expect(MarkerTag.Unnecessary, e['Unnecessary']);
    expect(MarkerTag.Deprecated, e['Deprecated']);
  });

  test('b63 MarkerSeverity enum values (power-of-two)', () {
    final e = truth['severityEnum'] as Map<String, dynamic>;
    expect(MarkerSeverity.Hint, e['Hint']);
    expect(MarkerSeverity.Info, e['Info']);
    expect(MarkerSeverity.Warning, e['Warning']);
    expect(MarkerSeverity.Error, e['Error']);
  });

  test('b63 MarkerSeverity.compare = b - a', () {
    for (final c in truth['compare'] as List) {
      final m = c as Map<String, dynamic>;
      expect(MarkerSeverity.compare(m['a'] as int, m['b'] as int), m['result'],
          reason: '${m['a']}-${m['b']}');
    }
  });

  test('b63 MarkerSeverity.toString / toStringPlural display + fallback', () {
    for (final c in truth['toString'] as List) {
      final m = c as Map<String, dynamic>;
      expect(MarkerSeverity.toStringStatic(m['in'] as int), m['result'],
          reason: 'toString ${m['in']}');
    }
    for (final c in truth['toStringPlural'] as List) {
      final m = c as Map<String, dynamic>;
      expect(MarkerSeverity.toStringPlural(m['in'] as int), m['result'],
          reason: 'toStringPlural ${m['in']}');
    }
  });

  test('b63 MarkerSeverity.fromSeverity / toSeverity round-trip', () {
    const byName = <String, int>{
      'Ignore': Severity.Ignore,
      'Info': Severity.Info,
      'Warning': Severity.Warning,
      'Error': Severity.Error,
    };
    for (final c in truth['fromSeverity'] as List) {
      final m = c as Map<String, dynamic>;
      expect(MarkerSeverity.fromSeverity(byName[m['in'] as String]!),
          m['result'], reason: 'fromSeverity ${m['in']}');
    }
    for (final c in truth['toSeverity'] as List) {
      final m = c as Map<String, dynamic>;
      final value = <String, int>{
        'Error': MarkerSeverity.Error,
        'Warning': MarkerSeverity.Warning,
        'Info': MarkerSeverity.Info,
        'Hint': MarkerSeverity.Hint,
        'zero': 0,
        '99': 99,
      }[m['in'] as String]!;
      final result = MarkerSeverity.toSeverity(value);
      expect(result ?? _undef, m['result'], reason: 'toSeverity ${m['in']}');
    }
  });

  test('b63 IMarkerData.makeKey all optional branches + pipe escape', () {
    final cases = _markerCases();
    for (final c in truth['makeKey'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      expect(IMarkerData.makeKey(cases[name]!), m['result'], reason: name);
    }
  });

  test('b63 IMarkerData.makeKeyOptionalMessage useMessage true/false', () {
    final cases = _markerCases();
    for (final c in truth['makeKeyOptionalMessage'] as List) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      final useMessage = m['useMessage'] as bool;
      expect(IMarkerData.makeKeyOptionalMessage(cases[name]!, useMessage),
          m['result'], reason: '$name useMessage=$useMessage');
    }
  });
}

/// Rebuild the exact markerData objects used by the truth generator.
Map<String, Map<String, Object?>> _markerCases() {
  Map<String, Object?> marker([Map<String, Object?> overrides = const {}]) =>
      <String, Object?>{
        'severity': MarkerSeverity.Error,
        'message': 'msg',
        'startLineNumber': 1,
        'startColumn': 2,
        'endLineNumber': 3,
        'endColumn': 4,
      }..addAll(overrides);
  return <String, Map<String, Object?>>{
    'full': marker({'source': 'ts', 'code': 'code1'}),
    'no-source-code': marker(),
    'code-object': marker({
      'code': {'value': 'V', 'target': {'__uri__': 'file:///t'}},
    }),
    'code-empty-string': marker({'code': ''}),
    'source-empty': marker({'source': ''}),
    'pipe-in-source': marker({'source': 'a¦b¦c'}),
    'pipe-in-code': marker({'code': 'x¦y¦z'}),
    'pipe-in-message': marker({'message': 'm¦n¦o'}),
    'severity-undefined': marker({'severity': null}),
    'severity-null': marker({'severity': null}),
    'severity-info': marker({'severity': 2}),
    'positions-null': marker({
      'startLineNumber': null,
      'startColumn': null,
      'endLineNumber': null,
      'endColumn': null,
    }),
    'positions-zero': marker({
      'startLineNumber': 0,
      'startColumn': 0,
      'endLineNumber': 0,
      'endColumn': 0,
    }),
    'message-empty': marker({'message': ''}),
    'all-empty': marker({
      'source': '',
      'code': '',
      'message': '',
      'severity': null,
      'startLineNumber': null,
      'startColumn': null,
      'endLineNumber': null,
      'endColumn': null,
    }),
  };
}
