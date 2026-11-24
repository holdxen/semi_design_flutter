// Truth-driven tests for platform/storage/common/storage.ts.
// Truth: tool/ts2dart/batch161_truth.json (real transpiled TypeScript module).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/async.dart' as async;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as lifecycle;
import 'package:semi_design_flutter/src/monaco/base/common/performance.dart'
    as performance;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/base/parts/storage/common/storage.dart'
    as baseStorage;
import 'package:semi_design_flutter/src/monaco/platform/storage/common/storage.dart'
    as storage;
import 'package:semi_design_flutter/src/monaco/platform/userDataProfile/common/userDataProfile.dart'
    as udp;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch161_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _section(String key) => T[key] as Map<String, dynamic>;

List<List<Object?>> _entriesOf(Map<dynamic, dynamic> map) => map.entries
    .map((MapEntry<dynamic, dynamic> e) => <Object?>[e.key, e.value])
    .toList();

List<Map<String, Object?>> _eventsJson(
        List<storage.StorageValueChangeEvent> events) =>
    events.map((storage.StorageValueChangeEvent e) => e.toJson()).toList();

List<Map<String, Object?>> _targetsJson(
        List<storage.StorageTargetChangeEvent> events) =>
    events.map((storage.StorageTargetChangeEvent e) => e.toJson()).toList();

class TestStorage implements baseStorage.IStorage {
  TestStorage(this._flushLog, [Map<String, String>? initial]) {
    _items.addAll(initial ?? <String, String>{});
  }

  final Map<String, String> _items = <String, String>{};
  final List<Object?> _flushLog;
  final event.Emitter<baseStorage.StorageChangeEvent> _emitter =
      event.Emitter<baseStorage.StorageChangeEvent>();

  @override
  event.Event<baseStorage.StorageChangeEvent> get onDidChangeStorage =>
      _emitter.event;

  @override
  Map<String, String> get items => _items;

  @override
  int get size => _items.length;

  @override
  Future<void> init() async {}

  @override
  String? get(String key, [String? fallbackValue]) {
    final String? value = _items[key];
    return value == null ? fallbackValue : value;
  }

  @override
  bool? getBoolean(String key, [bool? fallbackValue]) {
    final String? value = get(key);
    return value == null ? fallbackValue : value == 'true';
  }

  @override
  num? getNumber(String key, [num? fallbackValue]) {
    final String? value = get(key);
    return value == null ? fallbackValue : int.tryParse(value);
  }

  @override
  Object? getObject(String key, [Object? fallbackValue]) {
    final String? value = get(key);
    return value == null ? fallbackValue : jsonDecode(value);
  }

  @override
  Future<void> set(String key, Object? value, [bool external = false]) async {
    if (value == null) {
      return delete(key, external);
    }
    final String str = value is Map || value is List
        ? jsonEncode(value)
        : value.toString();
    if (_items[key] == str) {
      return;
    }
    _items[key] = str;
    _emitter.fire(baseStorage.StorageChangeEvent(key, external: external));
  }

  @override
  Future<void> delete(String key, [bool external = false]) async {
    if (!_items.containsKey(key)) {
      return;
    }
    _items.remove(key);
    _emitter.fire(baseStorage.StorageChangeEvent(key, external: external));
  }

  @override
  Future<void> flush([int? delay]) async {
    _flushLog.add(delay ?? 0);
  }

  @override
  Future<void> whenFlushed() async {
    _flushLog.add('whenFlushed');
  }

  @override
  Future<void> optimize() async {
    _flushLog.add('optimize');
  }

  @override
  Future<void> close() async {}

  @override
  void dispose() {}
}

class TestService extends storage.AbstractStorageService {
  TestService(this._storages, this._flushLog, [storage.StorageServiceOptions? options])
      : super(options) {
    for (final int scope in <int>[
      storage.StorageScope.APPLICATION_SHARED,
      storage.StorageScope.APPLICATION,
      storage.StorageScope.PROFILE,
      storage.StorageScope.WORKSPACE,
    ]) {
      register(onDidChangeValue(scope, null, lifecycle.DisposableStore())(
          (dynamic e) => events.add(e as storage.StorageValueChangeEvent)));
      final TestStorage? s = _storages[scope];
      if (s != null) {
        register(s.onDidChangeStorage((dynamic e) => emitDidChangeValue(
            scope, e as baseStorage.StorageChangeEvent)));
      }
    }
    register(onDidChangeTarget(
        (dynamic e) => targetEvents.add(e as storage.StorageTargetChangeEvent)));
    register(onWillSaveState(
        (dynamic e) => willEvents.add(e as storage.WillSaveStateEvent)));
  }

  final Map<int, TestStorage> _storages;
  final List<Object?> _flushLog;
  final List<storage.StorageValueChangeEvent> events =
      <storage.StorageValueChangeEvent>[];
  final List<storage.StorageTargetChangeEvent> targetEvents =
      <storage.StorageTargetChangeEvent>[];
  final List<storage.WillSaveStateEvent> willEvents =
      <storage.WillSaveStateEvent>[];
  final List<List<Object?>> calls = <List<Object?>>[];

  @override
  baseStorage.IStorage? getStorage(int scope) {
    calls.add(<Object?>['getStorage', scope]);
    return _storages[scope];
  }

  @override
  String? getLogDetails(int scope) => 'scope-$scope';

  @override
  bool hasScope(Object scope) => scope == 'workspace-1';

  @override
  Future<void> doInitialize() async {
    calls.add(<Object?>['doInitialize']);
  }

  @override
  Future<void> switchToProfile(
      udp.IUserDataProfile toProfile, bool preserveData) async {
    calls.add(<Object?>['switchToProfile', toProfile.id, preserveData]);
  }

  @override
  Future<void> switchToWorkspace(Object toWorkspace, bool preserveData) async {
    calls.add(<Object?>['switchToWorkspace', toWorkspace.toString(), preserveData]);
  }

  void emitDiff(int scope, baseStorage.StorageChangeEvent e) =>
      emitDidChangeValue(scope, e);

  void emitWill(int reason) => emitWillSaveState(reason);

  bool canSwitch(udp.IUserDataProfile from, udp.IUserDataProfile to) =>
      canSwitchProfile(from, to);

  void switchDataPublic(Map<String, String> oldStorage,
          baseStorage.IStorage newStorage, int scope) =>
      switchData(oldStorage, newStorage, scope);

  storage.KeyTargets targets(int scope) => getKeyTargets(scope);
}

class ProfileStub implements udp.IUserDataProfile {
  ProfileStub(this.id, this.isDefault, this.name, [this.useDefaultFlags]);

  static final uri.URI _location = uri.URI.parse('file:///profile');

  @override
  final String id;

  @override
  bool isDefault;

  @override
  final String name;

  @override
  final Map<String, Object?>? useDefaultFlags;

  @override
  String? get icon => null;

  @override
  uri.URI get location => _location;

  @override
  uri.URI get globalStorageHome => _location;

  @override
  uri.URI get settingsResource => _location;

  @override
  uri.URI get keybindingsResource => _location;

  @override
  uri.URI get tasksResource => _location;

  @override
  uri.URI get snippetsHome => _location;

  @override
  uri.URI get promptsHome => _location;

  @override
  uri.URI get extensionsResource => _location;

  @override
  uri.URI get mcpResource => _location;

  @override
  uri.URI get languageModelsResource => _location;

  @override
  uri.URI get agentPluginsHome => _location;

  @override
  uri.URI get cacheHome => _location;

  @override
  bool? get isInternal => null;

  @override
  bool? get isTransient => null;

  @override
  bool? get isAgentsWindowProfile => null;

  @override
  List<uri.URI>? workspaces;
}

final originalIdle = async.runWhenGlobalIdle;

void main() {
  final List<String> idleLog = <String>[];

  setUpAll(() {
    async.runWhenGlobalIdle = (void Function(async.IdleDeadline idle) runner,
        [int? timeout]) {
      idleLog.add('idle');
      return lifecycle.Disposable.none;
    };
    storage.consoleSink = <List<Object?>>[];
  });

  tearDownAll(() {
    async.runWhenGlobalIdle = originalIdle;
    storage.consoleSink = null;
  });

  test('constants match transpiled truth', () {
    final Map<String, dynamic> c = _section('constants');
    expect(storage.IS_NEW_KEY, c['isNewKey']);
    expect(storage.TARGET_KEY, c['targetKey']);
    expect(storage.IStorageService.serviceId, c['serviceId']);
    final Map<String, dynamic> reason =
        c['willSaveStateReason'] as Map<String, dynamic>;
    expect(storage.WillSaveStateReason.NONE, reason['NONE']);
    expect(storage.WillSaveStateReason.SHUTDOWN, reason['SHUTDOWN']);
    final Map<String, dynamic> scope = c['storageScope'] as Map<String, dynamic>;
    expect(storage.StorageScope.APPLICATION_SHARED, scope['APPLICATION_SHARED']);
    expect(storage.StorageScope.APPLICATION, scope['APPLICATION']);
    expect(storage.StorageScope.PROFILE, scope['PROFILE']);
    expect(storage.StorageScope.WORKSPACE, scope['WORKSPACE']);
    final Map<String, dynamic> target = c['storageTarget'] as Map<String, dynamic>;
    expect(storage.StorageTarget.USER, target['USER']);
    expect(storage.StorageTarget.MACHINE, target['MACHINE']);
  });

  test('loadKeyTargets mirrors JSON.parse failures', () {
    final Map<String, dynamic> truth = _section('loadKeyTargets');
    final List<Object?> flushLog = <Object?>[];
    final cases = <String, TestStorage>{
      'empty': TestStorage(flushLog),
      'good': TestStorage(flushLog, <String, String>{
        storage.TARGET_KEY: '{"a":0,"b":1}',
      }),
      'bad': TestStorage(flushLog, <String, String>{
        storage.TARGET_KEY: '{not json',
      }),
      'falsy': TestStorage(flushLog, <String, String>{
        storage.TARGET_KEY: '',
      }),
    };
    for (final MapEntry<String, TestStorage> entry in cases.entries) {
      final Map<String, dynamic> expected =
          truth[entry.key] as Map<String, dynamic>;
      expect(_entriesOf(storage.loadKeyTargets(entry.value)),
          expected['items'],
          reason: 'loadKeyTargets ${entry.key}');
    }
  });

  test('isProfileUsingDefaultStorage', () {
    final Map<String, dynamic> truth = _section('isProfileUsingDefaultStorage');
    expect(
        storage.isProfileUsingDefaultStorage(ProfileStub('d', true, 'profile-d')),
        truth['default']);
    expect(
        storage.isProfileUsingDefaultStorage(
            ProfileStub('f', false, 'profile-f', <String, Object?>{'globalState': true})),
        truth['flagTrue']);
    expect(
        storage.isProfileUsingDefaultStorage(
            ProfileStub('n', false, 'profile-n', <String, Object?>{'globalState': false})),
        truth['flagFalse']);
    expect(
        storage.isProfileUsingDefaultStorage(ProfileStub('n', false, 'profile-n')),
        truth['none']);
  });

  test('AbstractStorageService full truth sequence', () async {
    final Map<String, dynamic> truth = _section('service');
    final List<Object?> flushLog = <Object?>[];
    final Map<int, TestStorage> storages = <int, TestStorage>{
      storage.StorageScope.APPLICATION_SHARED: TestStorage(flushLog),
      storage.StorageScope.APPLICATION: TestStorage(flushLog),
      storage.StorageScope.PROFILE: TestStorage(flushLog),
      storage.StorageScope.WORKSPACE: TestStorage(flushLog),
    };
    final TestService svc = TestService(
        storages, flushLog,
        const storage.StorageServiceOptions(flushInterval: 5));

    // initialize
    performance.clearMarks();
    await svc.initialize();
    final Map<String, dynamic> init = truth['initialize'] as Map<String, dynamic>;
    expect(performance.getMarks().map((dynamic m) => (m as dynamic).name).toList(),
        init['marks']);
    expect(svc.flushWhenIdleScheduler.isScheduled(), true);
    expect(svc.calls, init['calls']);
    svc.calls.clear();

    // store / storeAll / remove
    svc.store('alpha', 'one', storage.StorageScope.WORKSPACE,
        storage.StorageTarget.USER);
    svc.store('beta', 2, storage.StorageScope.WORKSPACE,
        storage.StorageTarget.MACHINE);
    svc.store('gamma', 'x', storage.StorageScope.PROFILE,
        storage.StorageTarget.USER, true);
    Map<String, dynamic> expected =
        truth['afterStore'] as Map<String, dynamic>;
    expect(_entriesOf(storages[1]!.items), expected['workspace']);
    expect(_entriesOf(storages[0]!.items), expected['profile']);
    expect(_eventsJson(svc.events), expected['events']);
    expect(_targetsJson(svc.targetEvents), expected['targetEvents']);
    svc.events.clear();
    svc.targetEvents.clear();

    svc.storeAll(<storage.StorageEntry>[
      const storage.StorageEntry(
          key: 'bulk1', value: 'v1', scope: 1, target: 0),
      const storage.StorageEntry(
          key: 'bulk2', value: 'v2', scope: 1, target: 1),
      const storage.StorageEntry(
          key: 'alpha', value: 'changed', scope: 1, target: 1),
    ], true);
    expected = truth['afterStoreAll'] as Map<String, dynamic>;
    expect(_entriesOf(storages[1]!.items), expected['workspace']);
    expect(_eventsJson(svc.events), expected['events']);
    expect(_targetsJson(svc.targetEvents), expected['targetEvents']);
    svc.events.clear();
    svc.targetEvents.clear();

    svc.remove('alpha', 1);
    svc.store('missing', null, 1, 0);
    svc.store('nullish', null, 1, 0);
    expected = truth['afterRemove'] as Map<String, dynamic>;
    expect(_entriesOf(storages[1]!.items), expected['workspace']);
    expect(_eventsJson(svc.events), expected['events']);
    expect(_targetsJson(svc.targetEvents), expected['targetEvents']);
    svc.events.clear();
    svc.targetEvents.clear();

    // readers
    await storages[1]!.set('bool', 'true');
    await storages[1]!.set('num', '42');
    await storages[1]!.set('obj', '{"x":1}');
    final Map<String, dynamic> readers = truth['readers'] as Map<String, dynamic>;
    expect(svc.get('bool', 1, 'fallback'), readers['string']);
    expect(svc.get('none', 1, 'fallback'), readers['stringMissing']);
    expect(svc.getBoolean('bool', 1), readers['boolean']);
    expect(svc.getBoolean('none', 1, true), readers['booleanMissing']);
    expect(svc.getNumber('num', 1), readers['number']);
    expect(svc.getNumber('none', 1, 99), readers['numberMissing']);
    expect(svc.getObject('obj', 1), readers['object']);
    expect(svc.getObject('none', 1, <String, Object?>{'fallback': true}),
        readers['objectMissing']);
    final List<String> allKeys = svc.keys(1)..sort();
    final List<String> userKeys = svc.keys(1, 0)..sort();
    final List<String> machineKeys = svc.keys(1, 1)..sort();
    expect(allKeys, readers['keysAll']);
    expect(userKeys, readers['keysUser']);
    expect(machineKeys, readers['keysMachine']);

    // isNew
    await storages[0]!.set(storage.IS_NEW_KEY, 'true');
    final Map<String, dynamic> isNew = truth['isNew'] as Map<String, dynamic>;
    expect(svc.isNew(0), isNew['profile']);
    expect(svc.isNew(1), isNew['workspace']);

    // shared helpers
    final Map<String, dynamic> shared = truth['shared'] as Map<String, dynamic>;
    await storages[-2]!.set('sharedKey', 'before');
    expect(await svc.readApplicationSharedValue('sharedKey'), shared['read']);
    expect(
        await svc.compareAndSwapApplicationSharedValue(
            'sharedKey', 'before', 'after'),
        shared['swapOk']);
    expect(
        await svc.compareAndSwapApplicationSharedValue(
            'sharedKey', 'before', 'again'),
        shared['swapBad']);
    expect(_entriesOf(storages[-2]!.items), shared['items']);

    // TARGET_KEY event + target cache invalidation
    svc.events.clear();
    svc.targetEvents.clear();
    svc.emitDiff(1,
        baseStorage.StorageChangeEvent(storage.TARGET_KEY, external: true));
    final Map<String, dynamic> targetKeyEvent =
        truth['targetKeyEvent'] as Map<String, dynamic>;
    expect(_eventsJson(svc.events), targetKeyEvent['events']);
    expect(_targetsJson(svc.targetEvents), targetKeyEvent['targetEvents']);
    expect(_entriesOf(svc.targets(1)), targetKeyEvent['cached']);
    svc.events.clear();
    svc.targetEvents.clear();
    svc.store('after-target', 'v', 1, 1);
    final Map<String, dynamic> after =
        targetKeyEvent['after'] as Map<String, dynamic>;
    expect(_eventsJson(svc.events), after['events']);
    expect(_targetsJson(svc.targetEvents), after['targetEvents']);
    expect(_entriesOf(svc.targets(1)), after['cached']);

    // filtered event
    final lifecycle.DisposableStore scopeStore = lifecycle.DisposableStore();
    final List<storage.StorageValueChangeEvent> filtered =
        <storage.StorageValueChangeEvent>[];
    svc.onDidChangeValue(1, 'filtered', scopeStore)(
        (dynamic e) => filtered.add(e as storage.StorageValueChangeEvent));
    svc.store('filtered', '1', 1, 0);
    svc.store('other', '1', 1, 0);
    scopeStore.clear();
    svc.store('filtered', '2', 1, 0);
    expect(_eventsJson(filtered), truth['filtered']);

    // flush NONE / SHUTDOWN
    flushLog.clear();
    svc.willEvents.clear();
    await svc.flush();
    Map<String, dynamic> flushTruth = truth['flushNone'] as Map<String, dynamic>;
    expect(svc.willEvents.map((dynamic e) => (e as dynamic).reason).toList(),
        (flushTruth['will'] as List<dynamic>)
            .map((dynamic e) => (e as Map<String, dynamic>)['reason'])
            .toList());
    expect(flushLog, flushTruth['log']);

    flushLog.clear();
    svc.willEvents.clear();
    await svc.flush(storage.WillSaveStateReason.SHUTDOWN);
    flushTruth = truth['flushShutdown'] as Map<String, dynamic>;
    expect(svc.willEvents.map((dynamic e) => (e as dynamic).reason).toList(),
        (flushTruth['will'] as List<dynamic>)
            .map((dynamic e) => (e as Map<String, dynamic>)['reason'])
            .toList());
    expect(flushLog, flushTruth['log']);

    // idle scheduler
    idleLog.clear();
    svc.doFlushWhenIdle();
    final Map<String, dynamic> idle = truth['idle'] as Map<String, dynamic>;
    expect(idleLog, idle['idleLog']);
    expect(svc.flushWhenIdleScheduler.isScheduled(), true);
    svc.stopFlushWhenIdle();
    expect(svc.flushWhenIdleScheduler.runner, isNull);
    expect((truth['stopIdle'] as Map<String, dynamic>)['disposed'], true);

    // switch / canSwitch / switchData / optimize
    svc.calls.clear();
    svc.willEvents.clear();
    await svc.switchTo(ProfileStub('p', false, 'profile-p'), true);
    await svc.switchTo('workspace-1', false);
    final Map<String, dynamic> switchTruth = truth['switch'] as Map<String, dynamic>;
    expect(svc.calls, switchTruth['calls']);
    expect(svc.willEvents.map((dynamic e) => (e as dynamic).reason).toList(),
        (switchTruth['will'] as List<dynamic>)
            .map((dynamic e) => (e as Map<String, dynamic>)['reason'])
            .toList());

    final Map<String, dynamic> canSwitch =
        truth['canSwitch'] as Map<String, dynamic>;
    expect(svc.canSwitch(ProfileStub('x', false, 'x'), ProfileStub('x', false, 'x')),
        canSwitch['same']);
    expect(svc.canSwitch(ProfileStub('a', true, 'a'), ProfileStub('b', true, 'b')),
        canSwitch['bothDefault']);
    expect(
        svc.canSwitch(
            ProfileStub('a', false, 'a', <String, Object?>{'globalState': true}),
            ProfileStub('b', false, 'b', <String, Object?>{'globalState': true})),
        canSwitch['flagDefault']);
    expect(svc.canSwitch(ProfileStub('a', false, 'a'), ProfileStub('b', false, 'b')),
        canSwitch['different']);

    final Map<String, dynamic> switchDataTruth =
        truth['switchData'] as Map<String, dynamic>;
    final TestStorage next = TestStorage(flushLog, <String, String>{
      'same': 'v',
      'changed': 'new',
      'added': 'y',
    });
    svc.events.clear();
    svc.switchDataPublic(<String, String>{
      'same': 'v',
      'changed': 'old',
      'gone': 'x',
    }, next, 1);
    expect(_eventsJson(svc.events), switchDataTruth['events']);

    flushLog.clear();
    await svc.optimize(1);
    expect(flushLog, truth['optimize']);
  });

  test('InMemoryStorageService truth', () async {
    final Map<String, dynamic> truth = _section('inMemory');
    final storage.InMemoryStorageService mem = storage.InMemoryStorageService();
    await mem.initialize();

    mem.store('a', '1', storage.StorageScope.WORKSPACE, storage.StorageTarget.USER);
    mem.store('b', 'true', storage.StorageScope.PROFILE, storage.StorageTarget.MACHINE);
    mem.store('c', '3', storage.StorageScope.APPLICATION, storage.StorageTarget.USER);
    mem.store('d', '4', storage.StorageScope.APPLICATION_SHARED,
        storage.StorageTarget.MACHINE);
    final List<storage.StorageValueChangeEvent> memEvents =
        <storage.StorageValueChangeEvent>[];
    mem.onDidChangeValue(storage.StorageScope.WORKSPACE, null,
        lifecycle.DisposableStore())(
        (dynamic e) => memEvents.add(e as storage.StorageValueChangeEvent));
    mem.store('e', '5', storage.StorageScope.WORKSPACE, storage.StorageTarget.USER);

    final Map<String, dynamic> items = truth['items'] as Map<String, dynamic>;
    expect(_entriesOf(mem.getStorage(-1)!.items), items['application']);
    expect(_entriesOf(mem.getStorage(-2)!.items), items['applicationShared']);
    expect(_entriesOf(mem.getStorage(0)!.items), items['profile']);
    expect(_entriesOf(mem.getStorage(1)!.items), items['workspace']);
    expect(<int>[-2, -1, 0, 1].map((int s) => mem.getLogDetails(s)).toList(),
        truth['logDetails']);
    expect(mem.shouldFlushWhenIdle(), truth['shouldFlushWhenIdle']);
    expect(<bool>[
      mem.hasScope(ProfileStub('p', false, 'p')),
      mem.hasScope('workspace-1'),
    ], truth['hasScope']);
    final Map<String, dynamic> values = truth['values'] as Map<String, dynamic>;
    expect(mem.get('a', 1), values['a']);
    expect(mem.getBoolean('b', 0), values['b']);
    expect(mem.get('d', -2), values['d']);
    expect(mem.get('missing', 1, 'fallback'), values['missing']);
    expect(_eventsJson(memEvents), truth['events']);

    await mem.switchTo(ProfileStub('p', false, 'p'), true);
    expect(
        _entriesOf(mem.getStorage(1)!.items),
        (truth['afterSwitch'] as Map<String, dynamic>)['workspace']);
  });

  test('logStorage console truth', () async {
    storage.consoleSink = <List<Object?>>[];
    final Map<String, dynamic> truth = _section('logStorage');

    List<Object?> plainConsole() => (storage.consoleSink ?? <List<Object?>>[])
        .map((List<Object?> entry) {
      final String op = entry[0] as String;
      if (op == 'groupEnd') return <Object?>[op];
      if (op == 'log') {
        final Map<dynamic, dynamic> map = entry[1] as Map<dynamic, dynamic>;
        return <Object?>[
          op,
          map.entries
              .map((MapEntry<dynamic, dynamic> e) => <Object?>[e.key, e.value])
              .toList(),
        ];
      }
      return <Object?>[op, entry[1]];
    }).toList();

    await storage.logStorage(
      <String, String>{'a': '1', 'b': '{"x":1}', 'bad': '{oops'},
      <String, String>{'s': '"quoted"'},
      <String, String>{'p': 'true'},
      <String, String>{'w': '42'},
      '/app',
      '/app',
      '/profile',
      '/workspace',
    );
    expect(plainConsole(), truth['samePaths']);

    storage.consoleSink = <List<Object?>>[];
    await storage.logStorage(
      <String, String>{'a': '1'},
      <String, String>{},
      <String, String>{'p': '2'},
      <String, String>{},
      '/app',
      '/shared',
      '/profile',
      '/workspace',
    );
    expect(plainConsole(), truth['differentPaths']);
  });
}
