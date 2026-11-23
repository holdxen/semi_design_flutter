// Truth-driven tests for batch127: keybinding.ts.
// Runtime truth: decorator id/exports. AST truth: erased TS interface members.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    as instantiation;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/keybinding.dart'
    as keybinding;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch127_truth.json').readAsStringSync())
        as Map<String, dynamic>;

const String _dartSource =
    'lib/src/monaco/platform/keybinding/common/keybinding.dart';

Map<String, dynamic> _decorator() =>
    (_truth['decorator'] as Map).cast<String, dynamic>();

Map<String, dynamic> _interface(String name) => (_truth['interfaces'] as List)
    .cast<Map<String, dynamic>>()
    .firstWhere((Map<String, dynamic> i) => i['name'] == name);

String _dartClassBody(String className) {
  final String source = File(_dartSource).readAsStringSync();
  final int at = source.indexOf('abstract class $className ')
      .takeIf((int v) => v >= 0) ??
      source.indexOf('class $className ');
  expect(at, isNot(-1), reason: 'class $className exists');
  final int open = source.indexOf('{', at);
  int depth = 0;
  for (int i = open; i < source.length; i++) {
    if (source[i] == '{') depth++;
    if (source[i] == '}') {
      depth--;
      if (depth == 0) return source.substring(open, i + 1);
    }
  }
  fail('unterminated class $className');
}

extension _TakeIf<T> on T {
  T? takeIf(bool Function(T value) predicate) => predicate(this) ? this : null;
}

void main() {
  test('b127 decorator id and runtime export surface', () {
    final d = _decorator();
    final List<dynamic> calls = d['calls'] as List<dynamic>;
    expect(calls, <dynamic>['keybindingService']);
    expect(keybinding.IKeybindingService.serviceId, calls.single);
    expect(keybinding.IKeybindingService.toString(), calls.single);
    expect(
      identical(instantiation.createDecorator(calls.single as String),
          keybinding.IKeybindingService),
      isTrue,
    );
    expect(_truth['runtimeExports'], <dynamic>['IKeybindingService']);
  });

  test('b127 IUserFriendlyKeybinding fields match TS AST truth', () {
    final iface = _interface('IUserFriendlyKeybinding');
    final List<dynamic> members = iface['members'] as List<dynamic>;
    expect(members.map((dynamic m) => m['name']).toList(), <dynamic>[
      'key', 'command', 'args', 'when', 'systemWide'
    ]);
    expect(
        members
            .map((dynamic m) => m['optional'] as bool)
            .toList(),
        <bool>[false, false, true, true, true]);

    final full = keybinding.IUserFriendlyKeybinding(
        key: 'cmd+k', command: 'workbench.action.x',
        args: <String, Object?>{'a': 1}, when: 'editorTextFocus', systemWide: true);
    expect(full.key, 'cmd+k');
    expect(full.command, 'workbench.action.x');
    expect(full.args, <String, Object?>{'a': 1});
    expect(full.when, 'editorTextFocus');
    expect(full.systemWide, true);

    final minimal =
        keybinding.IUserFriendlyKeybinding(key: 'cmd+p', command: 'quickOpen');
    expect(minimal.args, isNull);
    expect(minimal.when, isNull);
    expect(minimal.systemWide, isNull);
  });

  test('b127 erased interfaces align with Dart structural declarations', () {
    const Map<String, String> renames = <String, String>{
      'IKeybindingService': 'IKeybindingServiceType',
      '_standardKeyboardEventBrand': 'standardKeyboardEventBrand',
    };
    for (final dynamic raw in _truth['interfaces'] as List<dynamic>) {
      final Map<String, dynamic> iface = raw as Map<String, dynamic>;
      final String className =
          renames[iface['name']] ?? iface['name'] as String;
      final String body = _dartClassBody(className);
      for (final dynamic rawMember in iface['members'] as List<dynamic>) {
        final Map<String, dynamic> member = rawMember as Map<String, dynamic>;
        final String name = member['name'] as String;
        final String dartName = renames[name] ?? name;
        expect(
          RegExp('\\b' + RegExp.escape(dartName) + r'\b').hasMatch(body),
          isTrue,
          reason: '$className.$dartName',
        );
      }
    }

    final service = _dartClassBody('IKeybindingServiceType');
    for (final String token in <String>[
      'Future<void>?', 'ResolutionResult', 'IContextKeyServiceTarget',
      'ResolvedKeybindingItem', 'Event<void>', 'IDisposable',
      'bool enforceContextCheck', 'String? commandId',
    ]) {
      expect(service, contains(token), reason: 'IKeybindingServiceType $token');
    }
  });
}
