import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    as instantiation;
import 'package:semi_design_flutter/src/monaco/platform/action/common/action.dart'
    as action;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart'
    as commands;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch124_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

void _expectDeep(Object? actual, Object? expected, [String label = 'value']) {
  if (expected is Map) {
    expect(actual, isA<Map>(), reason: label);
    final Map act = actual as Map;
    for (final Object? key in expected.keys) {
      _expectDeep(act[key], expected[key], '$label.$key');
    }
  } else if (expected is List) {
    expect(actual, isA<List>(), reason: label);
    final List act = actual as List;
    expect(act.length, expected.length, reason: '$label.length');
    for (int i = 0; i < expected.length; i++) {
      _expectDeep(act[i], expected[i], '$label[$i]');
    }
  } else {
    expect(actual, expected, reason: label);
  }
}

Object? _commandView(commands.ICommand? command) =>
    command == null ? 'undefined' : <String, Object?>{'id': command.id};

List<String> _ids(commands.ICommandsMap map) => map.keys.toList();

String _message(Object error) =>
    error.toString().replaceFirst('Bad state: ', '');

class _CountingTracker implements lifecycle.IDisposableTracker {
  int singletons = 0;

  @override
  void trackDisposable(lifecycle.IDisposable disposable) {}
  @override
  void setParent(lifecycle.IDisposable child, lifecycle.IDisposable? parent) {}
  @override
  void markAsDisposed(lifecycle.IDisposable disposable) {}
  @override
  void markAsSingleton(lifecycle.IDisposable disposable) => singletons++;
}

class _FakeCommandService implements commands.ICommandServiceType {
  _FakeCommandService(this.executions);

  final List<Map<String, Object?>> executions;

  @override
  lifecycle.IDisposable Function(dynamic, [dynamic, dynamic])
      get onWillExecuteCommand => (_, [__, ___]) => lifecycle.Disposable.none;

  @override
  lifecycle.IDisposable Function(dynamic, [dynamic, dynamic])
      get onDidExecuteCommand => (_, [__, ___]) => lifecycle.Disposable.none;

  @override
  Future<Object?> executeCommand(String commandId, List<Object?> args) async {
    executions.add(<String, Object?>{'commandId': commandId, 'args': args});
    return 'alias-result';
  }
}

class _FakeAccessor extends instantiation.ServicesAccessor {
  _FakeAccessor(this.executions);

  final List<Map<String, Object?>> executions;

  @override
  Object? get(instantiation.ServiceIdentifier id) {
    if (identical(id, commands.ICommandService)) {
      return _FakeCommandService(executions);
    }
    throw StateError('unexpected service');
  }
}

void main() {
  setUp(() {});
  tearDown(() {
    lifecycle.setDisposableTracker(null);
  });

  test('action.ts structural predicates', () {
    final expected = _section('predicates');
    final actual = <bool>[
      action.isLocalizedString(null),
      action.isLocalizedString(Object()),
      action.isLocalizedString(<String, Object?>{}),
      action.isLocalizedString(<String, Object?>{'value': 'v'}),
      action.isLocalizedString(<String, Object?>{'original': 'o'}),
      action.isLocalizedString(<String, Object?>{'value': 'v', 'original': 'o'}),
      action.isLocalizedString('string'),
      action.isLocalizedString(StringBuffer('x')),
    ];
    expect(actual, expected['isLocalizedString']);
    expect(<bool>[
      action.isICommandActionToggleInfo(null),
      action.isICommandActionToggleInfo(Object()),
      action.isICommandActionToggleInfo(<String, Object?>{}),
      action.isICommandActionToggleInfo(<String, Object?>{'condition': 'ctx'}),
    ], expected['isToggle']);
  });

  test('initial registry installs noop', () {
    final expected = _section('initial');
    expect(_ids(commands.CommandsRegistry.getCommands()), expected['commands']);
    _expectDeep(
        _commandView(commands.CommandsRegistry.getCommand('noop')),
        expected['noop'],
        'noop');
    expect(
        _commandView(commands.CommandsRegistry.getCommand('missing')),
        expected['missing']);
    expect(commands.ICommandService.serviceId, expected['serviceId']);
  });

  test('register / overwrite / dispose ordering and events', () {
    final expected = _section('register');
    final tracker = _CountingTracker();
    lifecycle.setDisposableTracker(tracker);
    final events = <String>[];
    final calls = <Object?>[];
    final listener = commands.CommandsRegistry.onDidRegisterCommand(
        (dynamic id) => events.add(id as String));

    final reg1 = commands.CommandsRegistry.registerCommand(
        'truth.cmd', (accessor, args) {
      calls.add(args.isEmpty ? null : args[0]);
      return (args[0] as int) * 2;
    });
    final afterRegister = <String, Object?>{
      'events': events.toList(),
      'keys': _ids(commands.CommandsRegistry.getCommands()),
      'invoke': commands.CommandsRegistry.getCommand('truth.cmd')!
          .handler(_FakeAccessor(<Map<String, Object?>>[]), <Object?>[21]),
      'calls': calls.toList(),
      // truth counts the `noop` registration at module load; tracker is
      // installed afterwards, so add that baseline back.
      'singletons': tracker.singletons + 1,
    };
    _expectDeep(afterRegister, expected['afterRegister'], 'afterRegister');

    final reg2 = commands.CommandsRegistry.registerCommand(
        'truth.cmd', (accessor, args) => 'second');
    _expectDeep(
        <String, Object?>{
          'invoke': commands.CommandsRegistry.getCommand('truth.cmd')!
              .handler(_FakeAccessor(<Map<String, Object?>>[]), <Object?>[]),
          'events': events.toList(),
        },
        expected['afterOverwrite'],
        'afterOverwrite');

    reg1.dispose();
    _expectDeep(
        <String, Object?>{
          'invoke': commands.CommandsRegistry.getCommand('truth.cmd')!
              .handler(_FakeAccessor(<Map<String, Object?>>[]), <Object?>[]),
          'keys': _ids(commands.CommandsRegistry.getCommands()),
        },
        expected['afterDisposeFirst'],
        'afterDisposeFirst');

    reg2.dispose();
    reg2.dispose();
    _expectDeep(
        <String, Object?>{
          'missing': _commandView(commands.CommandsRegistry.getCommand('truth.cmd')),
          'keys': _ids(commands.CommandsRegistry.getCommands()),
          'events': events.toList(),
          'singletons': tracker.singletons + 1,
        },
        expected['afterDisposeAll'],
        'afterDisposeAll');
    listener.dispose();
  });

  test('invalid registration forms', () {
    final expected = _section('invalid');
    final errors = <Object>[];
    try {
      commands.CommandsRegistry.registerCommand('');
    } catch (e) {
      errors.add(_message(e));
    }
    try {
      commands.CommandsRegistry.registerCommand('truth.noHandler');
    } catch (e) {
      errors.add(_message(e));
    }
    expect(errors, expected['errors']);
    expect(_ids(commands.CommandsRegistry.getCommands()), expected['keys']);
  });

  test('metadata constraints wrap the handler', () {
    final expected = _section('constraints');
    final seen = <List<Object?>>[];
    final reg = commands.CommandsRegistry.registerCommand(commands.ICommand(
      id: 'truth.constrained',
      handler: (accessor, args) {
        seen.add(args.toList());
        return args[0];
      },
      metadata: commands.ICommandMetadata(
        description: 'constrained command',
        args: <commands.ICommandMetadataArg>[
          commands.ICommandMetadataArg(name: 'a', constraint: 'string'),
          commands.ICommandMetadataArg(
              name: 'b',
              constraint: (Object? v) => v is int && v == 7),
        ],
      ),
    ));

    String validError = 'none';
    Object? validResult;
    final accessor = _FakeAccessor(<Map<String, Object?>>[]);
    try {
      validResult = commands.CommandsRegistry.getCommand('truth.constrained')!
          .handler(accessor, <Object?>['x', 7]);
    } catch (e) {
      validError = _message(e);
    }
    final invalidErrors = <String>[];
    for (final List<Object?> args in <List<Object?>>[
      <Object?>[7, 7],
      <Object?>['x', '7'],
    ]) {
      try {
        commands.CommandsRegistry.getCommand('truth.constrained')!
            .handler(accessor, args);
      } catch (e) {
        invalidErrors.add(_message(e));
      }
    }
    reg.dispose();
    _expectDeep(
        <String, Object?>{
          'validError': validError,
          'validResult': validResult,
          'seen': seen,
          'invalidErrors': invalidErrors,
          'missing': _commandView(
              commands.CommandsRegistry.getCommand('truth.constrained')),
        },
        expected,
        'constraints');
  });

  test('registerCommandAlias delegates through ICommandService', () async {
    final expected = _section('alias');
    final executions = <Map<String, Object?>>[];
    final target = commands.CommandsRegistry.registerCommand(
        'truth.target', (accessor, args) => 'target');
    final alias = commands.CommandsRegistry.registerCommandAlias(
        'truth.alias', 'truth.target');
    final Object? result = await commands.CommandsRegistry
        .getCommand('truth.alias')!
        .handler(_FakeAccessor(executions), <Object?>[1, 'x']);
    final keys = _ids(commands.CommandsRegistry.getCommands());
    alias.dispose();
    target.dispose();
    _expectDeep(
        <String, Object?>{
          'result': result,
          'executions': executions,
          'keys': keys,
          'aliasMissing':
              _commandView(commands.CommandsRegistry.getCommand('truth.alias')),
        },
        expected,
        'alias');
  });
}
