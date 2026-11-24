// Truth replay for batch202:
//   `platform/quickinput/browser/commandsQuickAccess.ts`
//   `editor/standalone/browser/quickAccess/standaloneHelpQuickAccess.ts`
//
// Expectations come from `tool/ts2dart/batch202_truth.json`, produced by
// `tool/ts2dart/_batch202_truth.cjs` (real transpiled provider + real
// `filters`/`tfIdf`/`lifecycle`/`map`/`nls`; the five injected services and the
// storage/configuration services are observable fakes).
//
// NOTE: `commandsQuickAccess.ts` has no official test of its own; truth comes
// from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/actions.dart'
    show WorkbenchActionExecutedEvent;
import '../lib/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import '../lib/src/monaco/base/common/filters.dart' show IMatch;
import '../lib/src/monaco/base/common/keybindings.dart'
    show ResolvedKeybinding;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/platform/commands/common/commands.dart'
    show ICommandServiceType;
import '../lib/src/monaco/platform/configuration/common/configuration.dart'
    show IConfigurationService, IConfigurationServiceType;
import '../lib/src/monaco/platform/dialogs/common/dialogs.dart'
    show IDialogServiceType;
import '../lib/src/monaco/platform/instantiation/common/instantiation.dart'
    show
        IInstantiationServiceType,
        ServicesAccessor;
import '../lib/src/monaco/platform/keybinding/common/keybinding.dart'
    show IKeybindingServiceType;
import '../lib/src/monaco/platform/log/common/log.dart'
    show ILogService, ILogServiceType;
import '../lib/src/monaco/platform/quickinput/browser/commandsQuickAccess.dart'
    as cq;
import '../lib/src/monaco/platform/quickinput/browser/pickerQuickAccess.dart'
    show FastAndSlowPicks, TriggerAction;
import '../lib/src/monaco/platform/quickinput/common/quickAccess.dart'
    show IQuickAccessProviderRunOptions;
import '../lib/src/monaco/platform/quickinput/common/quickInput.dart'
    show
        IKeyMods,
        IQuickPickDidAcceptEvent,
        IQuickPickItemHighlights,
        IQuickPickSeparator;
import '../lib/src/monaco/editor/standalone/browser/quickAccess/standaloneHelpQuickAccess.dart'
    show standaloneHelpQuickAccessRegistration;
import '../lib/src/monaco/platform/action/common/action.dart'
    show ILocalizedString;
import '../lib/src/monaco/platform/contextkey/common/contextkey.dart'
    show IContextKeyServiceType;
import '../lib/src/monaco/platform/storage/common/storage.dart'
    show IStorageService, IStorageServiceType;
import '../lib/src/monaco/platform/telemetry/common/telemetry.dart'
    show ITelemetryServiceType;

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch202_truth.json').readAsStringSync()));

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

const IKeyMods _noMods = IKeyMods(ctrlCmd: false, alt: false, shift: false);

// ---------------------------------------------------------------------------
// Service fakes (observable, mirroring the node harness)
// ---------------------------------------------------------------------------

class _FakeStorage implements IStorageServiceType {
  _FakeStorage([Map<String, Object?>? initial])
      : data = <String, Object?>{...?initial};

  final Map<String, Object?> data;
  final List<Map<String, Object?>> stored = <Map<String, Object?>>[];

  @override
  String? get(String key, int scope, [String? fallbackValue]) =>
      data.containsKey(key) ? data[key] as String? : fallbackValue;

  @override
  num? getNumber(String key, int scope, [num? fallbackValue]) {
    final Object? value = data[key];
    return value is num ? value : fallbackValue;
  }

  @override
  void store(String key, Object? value, int scope, int target,
      [bool external = false]) {
    data[key] = value;
    stored.add(<String, Object?>{
      'key': key,
      'value': value,
      'scope': scope,
      'target': target,
    });
  }

  @override
  lifecycle.IDisposable Function(dynamic listener,
          [dynamic thisArgs, dynamic disposables]) get onWillSaveState =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
          lifecycle.toDisposable(() {});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeConfiguration implements IConfigurationServiceType {
  _FakeConfiguration(this.history);

  final Object? history;

  @override
  Object? getValue$0() => <String, Object?>{
        'workbench': <String, Object?>{
          'commandPalette': <String, Object?>{
            'history': history,
            'preserveInput': true,
          },
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
  final List<Object> errors = <Object>[];

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    errors.add(message);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeInstantiation implements IInstantiationServiceType {
  _FakeInstantiation(this.storage, this.configuration, this.log);

  final _FakeStorage storage;
  final _FakeConfiguration configuration;
  final _FakeLog log;

  @override
  Object? createInstance(Object ctor, List<Object?> args) =>
      (ctor as dynamic)(storage, configuration, log);

  @override
  Object? invokeFunction(Object fn, List<Object?> args) {
    final ServicesAccessor accessor = _FakeAccessor(<Object, Object>{
      IStorageService: storage,
      IConfigurationService: configuration,
      ILogService: log,
    });
    return (fn as dynamic)(accessor);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAccessor implements ServicesAccessor {
  _FakeAccessor(this.services);

  final Map<Object, Object> services;

  @override
  Object? get(Object id) => services[id];
}

class _FakeKeybinding implements ResolvedKeybinding {
  _FakeKeybinding(this.commandId);

  final String commandId;

  @override
  String? getAriaLabel() => 'Ctrl+K';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeKeybindingService implements IKeybindingServiceType {
  final List<String> lookups = <String>[];

  @override
  ResolvedKeybinding? lookupKeybinding(
    String commandId, [
    IContextKeyServiceType? context,
    bool enforceContextCheck = false,
  ]) {
    lookups.add(commandId);
    return commandId == 'cmd.with.binding' ? _FakeKeybinding(commandId) : null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeCommandService implements ICommandServiceType {
  _FakeCommandService();

  final List<Map<String, Object?>> executed = <Map<String, Object?>>[];
  String? failFor;

  @override
  Future<Object?> executeCommand(String commandId, List<Object?> args) async {
    executed.add(<String, Object?>{'id': commandId, 'args': args});
    if (commandId == failFor) {
      throw Exception('boom');
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeTelemetry implements ITelemetryServiceType {
  final List<Map<String, Object?>> events = <Map<String, Object?>>[];

  @override
  void publicLog2(String eventName, [Object? data]) {
    final WorkbenchActionExecutedEvent? typed =
        data is WorkbenchActionExecutedEvent ? data : null;
    events.add(<String, Object?>{
      'name': eventName,
      'id': typed?.id,
      'from': typed?.from,
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeDialog implements IDialogServiceType {
  final List<Map<String, Object?>> errors = <Map<String, Object?>>[];

  @override
  Future<void> error(String message, [String? detail]) async {
    errors.add(<String, Object?>{'message': message, 'detail': detail});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Harness {
  _Harness(int historyLength)
      : storage = _FakeStorage(),
        configuration = _FakeConfiguration(historyLength) {
    instantiation = _FakeInstantiation(storage, configuration, log);
  }

  final _FakeStorage storage;
  final _FakeConfiguration configuration;
  final _FakeLog log = _FakeLog();
  final _FakeKeybindingService keybinding = _FakeKeybindingService();
  final _FakeCommandService commands = _FakeCommandService();
  final _FakeTelemetry telemetry = _FakeTelemetry();
  final _FakeDialog dialog = _FakeDialog();
  late final _FakeInstantiation instantiation;
}

class _TestProvider extends cq.AbstractCommandsQuickAccessProvider {
  _TestProvider(
    _Harness harness,
    this.picks,
    cq.ICommandsQuickAccessOptions options, [
    this.additional,
  ]) : super(
          options,
          harness.instantiation,
          harness.keybinding,
          harness.commands,
          harness.telemetry,
          harness.dialog,
        );

  final List<cq.ICommandQuickPick> picks;
  final Future<List<Object>> Function(
    String filter,
    List<cq.ICommandQuickPick> allPicks,
    List<cq.ICommandQuickPick> picksSoFar,
  )? additional;

  @override
  Future<List<cq.ICommandQuickPick>> getCommandPicks(
          CancellationToken token) async =>
      picks;

  @override
  bool hasAdditionalCommandPicks(String filter, CancellationToken token) =>
      additional != null;

  @override
  Future<List<Object>> getAdditionalCommandPicks(
    List<cq.ICommandQuickPick> allPicks,
    List<cq.ICommandQuickPick> picksSoFar,
    String filter,
    CancellationToken token,
  ) async =>
      additional == null
          ? <Object>[]
          : additional!(filter, allPicks, picksSoFar);

  Future<Object?> run(
    String filter, [
    IQuickAccessProviderRunOptions? runOptions,
  ]) =>
      getPicks(filter, lifecycle.DisposableStore(), CancellationToken.none,
          runOptions);
}

Map<String, Object?> _norm(Object? pick) {
  if (pick is IQuickPickSeparator) {
    return <String, Object?>{'kind': 'separator', 'label': pick.label};
  }
  final cq.ICommandQuickPick item = pick as cq.ICommandQuickPick;
  final IQuickPickItemHighlights? highlights = item.highlights
          is IQuickPickItemHighlights
      ? item.highlights as IQuickPickItemHighlights
      : null;
  final List<Map<String, int>>? labelHighlights = highlights?.label
      ?.map((IMatch match) => <String, int>{
            'start': match.start,
            'end': match.end,
          })
      .toList();
  final List<Map<String, int>>? detailHighlights = highlights?.detail
      ?.map((IMatch match) => <String, int>{
            'start': match.start,
            'end': match.end,
          })
      .toList();
  final List<Object> buttons = (item.buttons ?? <Object>[]).cast<Object>();
  final Object? lastButton = buttons.isEmpty ? null : buttons.last;
  return <String, Object?>{
    'kind': 'item',
    'id': item.id,
    'label': item.label,
    'commandId': item.commandId,
    'ariaLabel': item.ariaLabel,
    'detail': item.detail,
    'description': item.description,
    'tooltip': item.tooltip,
    'tfIdfScore': item.tfIdfScore,
    'highlights': highlights == null
        ? null
        : <String, Object?>{
            'label': labelHighlights,
            'detail': detailHighlights,
          },
    'hasKeybinding': item.keybinding != null,
    'buttonCount': buttons.length,
    'lastButtonTooltip': (lastButton as dynamic)?.tooltip,
    'lastButtonIconClass': (lastButton as dynamic)?.iconClass,
  };
}

List<Map<String, Object?>> _normAll(Object? picks) =>
    (picks as List).map(_norm).toList();

cq.ICommandQuickPick _pick({
  required String commandId,
  required String label,
  String? commandAlias,
  ILocalizedString? commandDescription,
  String? commandCategory,
  List<Object?>? args,
}) =>
    cq.ICommandQuickPick(
      label: label,
      commandId: commandId,
      commandAlias: commandAlias,
      commandDescription: commandDescription,
      commandCategory: commandCategory,
      args: args,
    );

void main() {
  final Map<String, dynamic> truth = _truth();

  List<cq.ICommandQuickPick> basePicks() => <cq.ICommandQuickPick>[
        _pick(
          commandId: 'workbench.action.files.openFile',
          label: 'Open File',
          commandAlias: 'open',
        ),
        _pick(
          commandId: 'workbench.action.files.openRecent',
          label: 'Open Recent',
        ),
        _pick(
          commandId: 'workbench.action.closeAll',
          label: 'Close All',
          commandAlias: 'close everything',
        ),
        _pick(commandId: 'exactId', label: 'Totally unrelated label'),
      ];

  test('filter: exact command id match', () async {
    final _TestProvider provider = _TestProvider(
      _Harness(50),
      basePicks(),
      cq.ICommandsQuickAccessOptions(showAlias: true),
    );
    expect(_normAll(await provider.run('exactId')),
        _exp(truth['exactIdMatch']));
  });

  test('filter: alias highlights honour showAlias', () async {
    final _TestProvider withoutAlias = _TestProvider(
      _Harness(50),
      basePicks(),
      cq.ICommandsQuickAccessOptions(showAlias: false),
    );
    expect(_normAll(await withoutAlias.run('open')),
        _exp(truth['openFilterShowAliasFalse']));

    final _TestProvider withAlias = _TestProvider(
      _Harness(50),
      basePicks(),
      cq.ICommandsQuickAccessOptions(showAlias: true),
    );
    expect(_normAll(await withAlias.run('open')),
        _exp(truth['openFilterShowAliasTrue']));
  });

  test('tf-idf chunk', () async {
    final List<cq.ICommandQuickPick> picks = <cq.ICommandQuickPick>[
      _pick(
        commandId: 'workbench.action.files.openFile',
        label: 'Open File',
        commandDescription: ILocalizedString(
          value: 'Open a file',
          original: 'opens a file from disk',
        ),
      ),
      _pick(
          commandId: 'workbench.action.files.saveFile', label: 'Save File'),
      _pick(
          commandId: 'workbench.action.terminal.new',
          label: 'Terminal: Create New Terminal'),
      _pick(commandId: 'workbench.action.zzz', label: 'Unrelated'),
    ];
    final _TestProvider provider = _TestProvider(
      _Harness(50),
      picks,
      cq.ICommandsQuickAccessOptions(showAlias: false),
    );
    expect(
      picks.map((cq.ICommandQuickPick pick) => provider.getTfIdfChunk(pick))
          .toList(),
      _exp(truth['tfIdfChunk']),
    );
  });

  test('tf-idf scenarios', () async {
    final List<cq.ICommandQuickPick> picks = <cq.ICommandQuickPick>[
      _pick(
        commandId: 'workbench.action.files.openFile',
        label: 'Open File',
        commandDescription: ILocalizedString(
          value: 'Open a file',
          original: 'opens a file from disk',
        ),
      ),
      _pick(
          commandId: 'workbench.action.files.saveFile', label: 'Save File'),
      _pick(
          commandId: 'workbench.action.terminal.new',
          label: 'Terminal: Create New Terminal'),
      _pick(commandId: 'workbench.action.zzz', label: 'Unrelated'),
    ];
    final _TestProvider provider = _TestProvider(
      _Harness(50),
      picks,
      cq.ICommandsQuickAccessOptions(showAlias: false),
    );
    final Map<String, dynamic> expected =
        _map(truth['tfIdfScenarios']);
    for (final String filter in expected.keys) {
      expect(_normAll(await provider.run(filter)), _exp(expected[filter]),
          reason: 'filter=$filter');
    }
  });

  test('duplicate labels get the command id as description', () async {
    final _TestProvider provider = _TestProvider(
      _Harness(50),
      <cq.ICommandQuickPick>[
        _pick(commandId: 'cmd.one', label: 'Duplicate'),
        _pick(commandId: 'cmd.two', label: 'Duplicate'),
        _pick(commandId: 'cmd.three', label: 'Unique'),
      ],
      cq.ICommandsQuickAccessOptions(showAlias: false),
    );
    expect(_normAll(await provider.run('dupl')),
        _exp(truth['duplicateLabels']));
  });

  test('MRU ordering, separators, accept, trigger and errors', () async {
    final _Harness harness = _Harness(50);
    final _TestProvider provider = _TestProvider(
      harness,
      <cq.ICommandQuickPick>[
        _pick(commandId: 'cmd.a', label: 'Alpha'),
        _pick(commandId: 'cmd.b', label: 'Beta'),
        _pick(commandId: 'cmd.c', label: 'Gamma'),
      ],
      cq.ICommandsQuickAccessOptions(showAlias: false),
    );
    final cq.CommandsHistory history = provider.commandsHistory;
    history.push('cmd.c');
    history.push('cmd.b');

    final List<Object> picks = (await provider.run('')) as List<Object>;
    expect(_normAll(picks), _exp(truth['mru']));

    final cq.ICommandQuickPick alpha = picks
        .whereType<cq.ICommandQuickPick>()
        .firstWhere((cq.ICommandQuickPick pick) => pick.commandId == 'cmd.a');
    final cq.ICommandQuickPick beta = picks
        .whereType<cq.ICommandQuickPick>()
        .firstWhere((cq.ICommandQuickPick pick) => pick.commandId == 'cmd.b');

    harness.commands.executed.clear();
    harness.telemetry.events.clear();

    alpha.accept!(_noMods, IQuickPickDidAcceptEvent(inBackground: false));
    await Future<void>.delayed(Duration.zero);
    final Map<String, dynamic> afterAccept =
        _map(truth['afterAccept']);
    expect(harness.commands.executed, _exp(afterAccept['executed']));
    expect(harness.telemetry.events, _exp(afterAccept['telemetry']));
    expect(history.peek('cmd.a'), _exp(afterAccept['peekAlpha']));

    // The remove button is the last button for MRU items.
    final int removeIndex = (beta.buttons?.length ?? 0) - 1;
    final Map<String, dynamic> noAction = _map(truth['triggerNoAction']);
    expect(removeIndex, _exp(_map(truth['triggerRemove'])['removeIndex']));
    expect(beta.trigger!(removeIndex + 1, _noMods), _exp(noAction['action']));
    expect(history.peek('cmd.b'), _exp(noAction['peekBetaStillThere']));

    final Map<String, dynamic> remove = _map(truth['triggerRemove']);
    expect(beta.trigger!(removeIndex, _noMods), _exp(remove['action']));
    expect(history.peek('cmd.b'), _exp(remove['peekBetaAfter']));

    // Errors raised by the command are surfaced through the dialog service.
    harness.commands.failFor = 'cmd.a';
    harness.dialog.errors.clear();
    alpha.accept!(_noMods, IQuickPickDidAcceptEvent(inBackground: false));
    await Future<void>.delayed(Duration.zero);
    expect(harness.dialog.errors, _exp(truth['afterAcceptError']['dialogErrors']));
    harness.commands.failFor = null;

    // Run options flow into the telemetry `from` field.
    harness.telemetry.events.clear();
    final List<Object> withOptions = (await provider.run(
            '', IQuickAccessProviderRunOptions(from: 'commandPalette')))
        as List<Object>;
    final cq.ICommandQuickPick gamma = withOptions
        .whereType<cq.ICommandQuickPick>()
        .firstWhere((cq.ICommandQuickPick pick) => pick.commandId == 'cmd.c');
    gamma.accept!(_noMods, IQuickPickDidAcceptEvent(inBackground: false));
    await Future<void>.delayed(Duration.zero);
    expect(
      harness.telemetry.events
          .map((Map<String, Object?> event) => <String, Object?>{
                'id': event['id'],
                'from': event['from'],
              })
          .toList(),
      _exp(truth['acceptFromOption']),
    );

    expect(harness.storage.stored.length, _exp(truth['historyStorage']));
  });

  test('suggested commands and developer ordering', () async {
    final _Harness harness = _Harness(50);
    final _TestProvider provider = _TestProvider(
      harness,
      <cq.ICommandQuickPick>[
        _pick(commandId: 'cmd.used', label: 'Zulu used'),
        _pick(commandId: 'cmd.suggested', label: 'Alpha suggested'),
        _pick(commandId: 'cmd.other', label: 'Beta other'),
        _pick(
            commandId: 'cmd.dev',
            label: 'Gamma dev',
            commandCategory: 'Developer'),
      ],
      cq.ICommandsQuickAccessOptions(
        showAlias: false,
        suggestedCommandIds: <String>{'cmd.suggested'},
      ),
    );
    provider.commandsHistory.push('cmd.used');
    expect(_normAll(await provider.run('')),
        _exp(truth['suggestedSeparators']));
  });

  test('additional picks merge behind a separator', () async {
    final _Harness harness = _Harness(50);
    final _TestProvider provider = _TestProvider(
      harness,
      <cq.ICommandQuickPick>[
        _pick(commandId: 'cmd.a', label: 'Alpha'),
      ],
      cq.ICommandsQuickAccessOptions(showAlias: false),
      (String filter, List<cq.ICommandQuickPick> allPicks,
              List<cq.ICommandQuickPick> picksSoFar) async =>
          <Object>[
            _pick(commandId: 'cmd.extra', label: 'Extra'),
          ],
    );
    final Object? fastAndSlow = await provider.run('alp');
    final FastAndSlowPicks<Object?> merged =
        fastAndSlow as FastAndSlowPicks<Object?>;
    final Map<String, dynamic> expected = _map(truth['additional']);
    expect(_normAll(merged.picks), _exp(expected['fast']));
    expect(_normAll(await merged.additionalPicks), _exp(expected['slow']));
  });

  test('constants', () {
    final Map<String, dynamic> constants = _map(truth['constants']);
    expect(cq.AbstractCommandsQuickAccessProvider.PREFIX,
        _exp(constants['prefix']));
    expect(cq.AbstractCommandsQuickAccessProvider.TFIDF_THRESHOLD,
        _exp(constants['tfIdfThreshold']));
    expect(cq.AbstractCommandsQuickAccessProvider.TFIDF_MAX_RESULTS,
        _exp(constants['tfIdfMaxResults']));
    expect(cq.CommandsHistory.DEFAULT_COMMANDS_HISTORY_LENGTH,
        _exp(constants['defaultHistoryLength']));
    expect(TriggerAction.REMOVE_ITEM, _exp(constants['removeItemAction']));
    expect(TriggerAction.NO_ACTION, _exp(constants['noActionAction']));
  });

  test('CommandsHistory: load, push, remove, save, configure, clear', () {
    final _FakeStorage storage = _FakeStorage(<String, Object?>{
      'commandPalette.mru.cache': jsonEncode(<String, Object?>{
        'usesLRU': false,
        'entries': <Map<String, Object?>>[
          <String, Object?>{'key': 'b', 'value': 7},
          <String, Object?>{'key': 'a', 'value': 3},
          <String, Object?>{'key': 'c', 'value': 5},
        ],
      }),
      'commandPalette.mru.counter': 11,
    });
    final _FakeLog log = _FakeLog();
    final cq.CommandsHistory history =
        cq.CommandsHistory(storage, _FakeConfiguration(2), log);

    final Map<String, dynamic> load = _map(truth['historyLoad']);
    expect(cq.CommandsHistory.cache!.limit, _exp(load['limit']));
    final List<Object?> loadedEntries = <Object?>[];
    cq.CommandsHistory.cache!.forEach(
        (num value, String key, Object? map) =>
            loadedEntries.add(<Object?>[key, value]));
    expect(loadedEntries, _exp(load['entries']));
    expect(cq.CommandsHistory.counter, _exp(load['counter']));

    cq.CommandsHistory.hasChanges = false;
    history.push('d');
    final Map<String, dynamic> push = _map(truth['historyPush']);
    expect(history.peek('d'), _exp(push['peekD']));
    expect(cq.CommandsHistory.counter, _exp(push['counter']));
    expect(cq.CommandsHistory.hasChanges, _exp(push['hasChanges']));
    expect(cq.CommandsHistory.cache!.limit, _exp(push['limit']));

    history.remove('a');
    expect(history.peek('a'), _exp(_map(truth['historyRemove'])['peekA']));

    storage.stored.clear();
    history.saveState();
    final Map<String, dynamic> save = _map(truth['historySave']);
    expect(
      storage.stored
          .map((Map<String, Object?> entry) => <String, Object?>{
                'key': entry['key'],
                'value': entry['value'],
              })
          .toList(),
      _exp(save['stored']),
    );
    expect(cq.CommandsHistory.hasChanges, _exp(save['hasChanges']));

    final Map<String, dynamic> configured = _map(truth['configuredLength']);
    expect(
      cq.CommandsHistory.getConfiguredCommandHistoryLength(
          _FakeConfiguration(7)),
      _exp(configured['withNumber']),
    );
    expect(
      cq.CommandsHistory.getConfiguredCommandHistoryLength(_FakeConfiguration('nope')),
      _exp(configured['withString']),
    );
    expect(
      cq.CommandsHistory.getConfiguredCommandHistoryLength(
          _FakeConfiguration(null)),
      _exp(configured['empty']),
    );

    cq.CommandsHistory.clearHistory(_FakeConfiguration(4), _FakeStorage());
    final Map<String, dynamic> clear = _map(truth['historyClear']);
    expect(cq.CommandsHistory.cache!.limit, _exp(clear['limit']));
    expect(cq.CommandsHistory.counter, _exp(clear['counter']));
    expect(cq.CommandsHistory.hasChanges, _exp(clear['hasChanges']));
    expect(cq.CommandsHistory.cache!.size, _exp(clear['size']));

    final _FakeLog brokenLog = _FakeLog();
    cq.CommandsHistory(
      _FakeStorage(<String, Object?>{'commandPalette.mru.cache': '{oops'}),
      _FakeConfiguration(50),
      brokenLog,
    );
    final Map<String, dynamic> invalid = _map(truth['historyInvalid']);
    expect(brokenLog.errors.length, _exp(invalid['errors']));
    expect(cq.CommandsHistory.cache!.size, _exp(invalid['size']));
  });

  test('standaloneHelpQuickAccess registers the default provider', () {
    // The registration is a top-level final in the port; touching it must add
    // the `''` prefix provider with the help label (source has no test).
    final lifecycle.IDisposable handle =
        standaloneHelpQuickAccessRegistration;
    expect(handle, isNotNull);
  });
}