// Truth replay for batch242:
//   `editor/common/editorAction.ts`
//   `editor/contrib/quickAccess/browser/commandsQuickAccess.ts`.
//
// Expectations come from `tool/ts2dart/batch242_truth.json`, produced by
// `tool/ts2dart/_batch242_truth.cjs` (real transpiled sources; the platform
// `AbstractCommandsQuickAccessProvider` is stubbed, `iconLabels` /
// `action.isLocalizedString` are real).
//
// NOTE: neither file has an official test; truth comes from executing the real
// source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/cancellation.dart' show CancellationToken;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/editor/common/editorAction.dart' as editorAction;
import '../lib/src/monaco/editor/contrib/quickAccess/browser/commandsQuickAccess.dart'
    as contrib;
import '../lib/src/monaco/platform/action/common/action.dart'
    show ILocalizedString;
import '../lib/src/monaco/platform/commands/common/commands.dart'
    show ICommandMetadata, ICommandServiceType;
import '../lib/src/monaco/platform/configuration/common/configuration.dart'
    show IConfigurationService, IConfigurationServiceType;
import '../lib/src/monaco/platform/contextkey/common/contextkey.dart'
    show ContextKeyExpr, ContextKeyExpression, IContextKeyServiceType;
import '../lib/src/monaco/platform/dialogs/common/dialogs.dart'
    show IDialogServiceType;
import '../lib/src/monaco/platform/instantiation/common/instantiation.dart'
    show IInstantiationServiceType, ServicesAccessor;
import '../lib/src/monaco/platform/keybinding/common/keybinding.dart'
    show IKeybindingServiceType;
import '../lib/src/monaco/platform/log/common/log.dart'
    show ILogService, ILogServiceType;
import '../lib/src/monaco/platform/quickinput/browser/commandsQuickAccess.dart'
    as cq;
import '../lib/src/monaco/platform/storage/common/storage.dart'
    show IStorageService, IStorageServiceType;
import '../lib/src/monaco/platform/telemetry/common/telemetry.dart'
    show ITelemetryServiceType;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch242_truth.json').readAsStringSync()));

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

class _FakeContextKeyService implements IContextKeyServiceType {
  _FakeContextKeyService(this.matches);

  final bool matches;

  @override
  bool contextMatchesRules(Object? rules) => matches;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeStorage implements IStorageServiceType {
  @override
  String? get(String key, int scope, [String? fallbackValue]) => fallbackValue;
  @override
  num? getNumber(String key, int scope, [num? fallbackValue]) => fallbackValue;
  @override
  void store(String key, Object? value, int scope, int target,
      [bool external = false]) {}
  @override
  lifecycle.IDisposable Function(dynamic listener,
          [dynamic thisArgs, dynamic disposables])
      get onWillSaveState =>
          (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
              lifecycle.toDisposable(() {});
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeConfiguration implements IConfigurationServiceType {
  @override
  Object? getValue$0() => <String, Object?>{
        'workbench': <String, Object?>{
          'commandPalette': <String, Object?>{'history': 50, 'preserveInput': true},
        },
      };
  @override
  lifecycle.IDisposable Function(dynamic listener,
          [dynamic thisArgs, dynamic disposables])
      get onDidChangeConfiguration =>
          (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
              lifecycle.toDisposable(() {});
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeLog implements ILogServiceType {
  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Accessor implements ServicesAccessor {
  _Accessor(this.storage, this.configuration, this.log);

  final IStorageServiceType storage;
  final IConfigurationServiceType configuration;
  final ILogServiceType log;

  @override
  Object? get(Object id) {
    if (id == IStorageService) return storage;
    if (id == IConfigurationService) return configuration;
    if (id == ILogService) return log;
    return null;
  }
}

class _Stub implements
    IInstantiationServiceType,
    IKeybindingServiceType,
    ICommandServiceType,
    ITelemetryServiceType,
    IDialogServiceType {
  @override
  Object? invokeFunction(Object fn, List<Object?> args) => (fn as dynamic)(
      _Accessor(_FakeStorage(), _FakeConfiguration(), _FakeLog()));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAction {
  _FakeAction({
    required this.id,
    required this.label,
    this.alias,
    this.metadata,
  });

  final String id;
  final String label;
  final String? alias;
  final ICommandMetadata? metadata;
}

class _FakeControl {
  _FakeControl(this.actions);

  final List<_FakeAction> actions;

  List<_FakeAction> getSupportedActions() => actions;
}

class _Provider extends contrib.AbstractEditorCommandsQuickAccessProvider {
  _Provider(this.control)
      : super(cq.ICommandsQuickAccessOptions(showAlias: false), _Stub(),
            _Stub(), _Stub(), _Stub(), _Stub());

  final Object? control;

  @override
  Object? get activeTextEditorControl => control;

  @override
  Future<List<cq.ICommandQuickPick>> getCommandPicks(
          CancellationToken token) async =>
      <cq.ICommandQuickPick>[];

  @override
  bool hasAdditionalCommandPicks(String filter, CancellationToken token) =>
      false;

  @override
  Future<List<Object>> getAdditionalCommandPicks(
    List<cq.ICommandQuickPick> allPicks,
    List<cq.ICommandQuickPick> picksSoFar,
    String filter,
    CancellationToken token,
  ) async =>
      <Object>[];
}

Map<String, Object?> _project(cq.ICommandQuickPick pick) => <String, Object?>{
      'commandId': pick.commandId,
      'label': pick.label,
      'commandAlias': pick.commandAlias,
      'commandDescription': pick.commandDescription == null
          ? null
          : <String, Object?>{
              'value': pick.commandDescription!.value,
              'original': pick.commandDescription!.original,
            },
      'id': pick.id,
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch242 InternalEditorAction gates run() on isSupported()', () async {
    final List<Object?> calls = <Object?>[];
    final editorAction.InternalEditorAction action =
        editorAction.InternalEditorAction(
      'test.id',
      'Test Label',
      'testAlias',
      null,
      null,
      (Object? args) async => calls.add(args),
      _FakeContextKeyService(true),
    );

    final Map<String, dynamic> expected = _map(truth['editorActionSupported']);
    expect(action.isSupported(), expected['isSupported']);
    expect(action.id, expected['id']);
    expect(action.label, expected['label']);
    expect(action.alias, expected['alias']);
    expect(action.metadata, expected['metadata']);

    await action.run(<String, Object?>{'arg': 1});
    expect(calls.length, 1);
    expect(_map(truth['editorActionRunSupported'])['after'],
        isA<List<dynamic>>());

    final List<Object?> blockedCalls = <Object?>[];
    final editorAction.InternalEditorAction blocked =
        editorAction.InternalEditorAction(
      'blocked.id',
      'Blocked',
      'blockedAlias',
      ICommandMetadata(description: 'meta'),
      null,
      (Object? args) async => blockedCalls.add(args),
      _FakeContextKeyService(false),
    );
    final Map<String, dynamic> blockedExpected =
        _map(truth['editorActionBlocked']);
    expect(blocked.isSupported(), blockedExpected['isSupported']);
    await blocked.run('payload');
    expect(blockedCalls, _exp(blockedExpected['calls']));
  });

  test('batch242 getCodeEditorCommandPicks returns nothing without an editor',
      () {
    expect(_Provider(null).getCodeEditorCommandPicks().map(_project).toList(),
        truth['noActiveEditor']);
  });

  test('batch242 getCodeEditorCommandPicks maps actions to command picks', () {
    final _Provider provider = _Provider(_FakeControl(<_FakeAction>[
      _FakeAction(
        id: 'cmd.a',
        label: '\$(zap) Do It',
        alias: 'doit',
        metadata: ICommandMetadata(description: 'plain description'),
      ),
      _FakeAction(
        id: 'cmd.b',
        label: '\$(zap)',
        metadata: ICommandMetadata(
          description: ILocalizedString(value: 'localized', original: 'orig'),
        ),
      ),
      _FakeAction(id: 'cmd.c', label: 'Plain Label', alias: ''),
    ]));

    expect(provider.getCodeEditorCommandPicks().map(_project).toList(),
        _exp(truth['commandPicks']));
  });

  test('batch242 ContextKeyExpression is only carried structurally', () {
    final ContextKeyExpression? expression = ContextKeyExpr.true_();
    final editorAction.InternalEditorAction action =
        editorAction.InternalEditorAction('id', 'label', 'alias', null,
            expression, (Object? args) async {}, _FakeContextKeyService(true));
    expect(action.isSupported(), isTrue);
  });
}
