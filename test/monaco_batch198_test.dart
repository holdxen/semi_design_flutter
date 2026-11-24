// Truth replay for batch198:
//   `editor/browser/services/inlineCompletionsService.ts`.
//
// Expectations come from `tool/ts2dart/batch198_truth.json`, produced by
// `tool/ts2dart/_batch198_truth.cjs` (real transpiled service + actions, real
// `base/common/{async,errors,event,lifecycle}`; nls, Action2, context-key
// primitives, registerSingleton, the three services and the quick pick service
// are deterministic stubs, and `Date.now()` is a fake clock).
//
// NOTE: `inlineCompletionsService.ts` has no official test of its own (the
// STRICT+test match is the usual stem heuristic false positive); truth comes
// from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/errors.dart' show BugIndicatingError;
import '../lib/src/monaco/editor/browser/services/inlineCompletionsService.dart'
    as svc;
import '../lib/src/monaco/platform/action/common/action.dart' as action;
import '../lib/src/monaco/platform/contextkey/common/contextkey.dart'
    as contextkey;
import '../lib/src/monaco/platform/instantiation/common/descriptors.dart'
    show SyncDescriptor;
import '../lib/src/monaco/platform/instantiation/common/extensions.dart'
    show getSingletonServiceDescriptors;
import '../lib/src/monaco/platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, ServicesAccessor;
import '../lib/src/monaco/platform/quickinput/common/quickInput.dart'
    as quickInput;
import '../lib/src/monaco/platform/storage/common/storage.dart'
    show IStorageServiceType;
import '../lib/src/monaco/platform/telemetry/common/telemetry.dart'
    show ITelemetryServiceType;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() => _map(
    jsonDecode(File('tool/ts2dart/batch198_truth.json').readAsStringSync()));

class _FakeContextKey implements contextkey.IContextKey<bool> {
  _FakeContextKey(this.values);

  final List<bool> values;

  @override
  void set(bool value) => values.add(value);
  @override
  void reset() {}
  @override
  bool? get_() => values.isEmpty ? null : values.last;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ContextKeyRecord {
  _ContextKeyRecord(this.key, this.defaultValue);

  final String key;
  final bool? defaultValue;
  final List<bool> values = <bool>[];
}

class _FakeContextKeyService implements contextkey.IContextKeyServiceType {
  final List<_ContextKeyRecord> keys = <_ContextKeyRecord>[];

  @override
  contextkey.IContextKey<T> createKey<T>(String key, T? defaultValue) {
    final _ContextKeyRecord record = _ContextKeyRecord(
        key, defaultValue is bool ? defaultValue : null);
    keys.add(record);
    return _FakeContextKey(record.values) as contextkey.IContextKey<T>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeTelemetryService implements ITelemetryServiceType {
  final List<Map<String, Object?>> entries = <Map<String, Object?>>[];

  @override
  void publicLog2(String eventName, [Object? data]) {
    entries.add(<String, Object?>{
      'name': eventName,
      'data': data is Map
          ? <String, Object?>{
              'deltaSeconds': (data)['deltaSeconds'],
              'totalSeconds': (data)['totalSeconds'],
              'lastCompletionId': (data)['lastCompletionId'],
              'recentCompletionIds': data['recentCompletionIds'] is List
                  ? (data['recentCompletionIds'] as List).toList()
                  : null,
            }
          : null,
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeQuickInputService implements quickInput.IQuickInputServiceType {
  final List<Map<String, Object?>> pickCalls = <Map<String, Object?>>[];
  final List<Map<String, Object?>> inputCalls = <Map<String, Object?>>[];
  final List<quickInput.IInputOptions> inputOptions =
      <quickInput.IInputOptions>[];

  Object? pickResult;
  String? inputResult;

  @override
  Future<Object?> pick(
    Object picks, [
    Object? options,
    Object? token,
  ]) async {
    final List<Object> items = (picks as List).cast<Object>();
    final quickInput.IPickOptions<quickInput.IQuickPickItem>? pickOptions =
        options is quickInput.IPickOptions<quickInput.IQuickPickItem>
            ? options
            : null;
    pickCalls.add(<String, Object?>{
      'labels': items
          .map((Object i) => (i as quickInput.IQuickPickItem).label)
          .toList(),
      'ids': items
          .map((Object i) => (i as quickInput.IQuickPickItem).id)
          .toList(),
      'values': items
          .map((Object i) => (i as dynamic).value)
          .toList(),
      'descriptions': items
          .map((Object i) => (i as quickInput.IQuickPickItem).description)
          .toList(),
      'placeHolder': pickOptions?.placeHolder,
      'activeValue': pickOptions?.activeItem == null
          ? null
          : (pickOptions!.activeItem as dynamic).value,
    });
    return pickResult;
  }

  @override
  Future<String?> input([quickInput.IInputOptions? options, Object? token]) async {
    if (options != null) {
      inputOptions.add(options);
    }
    inputCalls.add(<String, Object?>{
      'placeHolder': options?.placeHolder,
      'prompt': options?.prompt,
    });
    return inputResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeStorageService implements IStorageServiceType {
  num storedNumber = 300000;
  final List<Map<String, Object?>> storeCalls = <Map<String, Object?>>[];

  @override
  num? getNumber(String key, int scope, [num? fallbackValue]) {
    if (key == 'inlineCompletions.lastSnoozeDuration') {
      return storedNumber;
    }
    return fallbackValue;
  }

  @override
  void store(String key, Object? value, int scope, int target,
      [bool external = false]) {
    storeCalls.add(<String, Object?>{
      'key': key,
      'value': value,
      'scope': scope,
      'target': target,
    });
    if (key == 'inlineCompletions.lastSnoozeDuration') {
      storedNumber = value as num;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Accessor implements ServicesAccessor {
  _Accessor({
    required this.quickInputService,
    required this.inlineCompletionsService,
    required this.storageService,
  });

  final _FakeQuickInputService quickInputService;
  final svc.InlineCompletionsService inlineCompletionsService;
  final _FakeStorageService storageService;

  @override
  Object? get(ServiceIdentifier id) {
    switch (id.serviceId) {
      case 'quickInputService':
        return quickInputService;
      case 'storageService':
        return storageService;
      case 'IInlineCompletionsService':
        return inlineCompletionsService;
    }
    return null;
  }
}

class _Harness {
  _Harness() {
    contextKeyService = _FakeContextKeyService();
    telemetry = _FakeTelemetryService();
    service = svc.InlineCompletionsService(contextKeyService, telemetry);
    events = <bool>[];
    service.onDidChangeIsSnoozing((bool value) => events.add(value));
  }

  late final _FakeContextKeyService contextKeyService;
  late final _FakeTelemetryService telemetry;
  late final svc.InlineCompletionsService service;
  late final List<bool> events;

  void dispose() => service.dispose();
}

List<Map<String, Object?>> _contextKeySnapshot(_FakeContextKeyService s) =>
    s.keys
        .map((_ContextKeyRecord k) => <String, Object?>{
              'key': k.key,
              'values': k.values.toList(),
            })
        .toList();

Map<String, Object?> _titleOf(Object? title) => title is action.ILocalizedString
    ? <String, Object?>{'value': title.value, 'original': title.original}
    : <String, Object?>{'value': null, 'original': null};

void main() {
  final Map<String, dynamic> truth = _truth();

  tearDown(() => svc.dateNowOverride = null);

  test('batch198 defaults match truth', () {
    final Map<String, dynamic> expected = _map(truth['defaults']);
    final _Harness h = _Harness();
    expect(h.service.snoozeTimeLeft, expected['snoozeTimeLeft']);
    expect(h.service.isSnoozing(), expected['isSnoozing']);
    expect(h.events, _exp(_list(expected['events'])));
    h.dispose();
  });

  test('batch198 snooze() arms the timer and reports telemetry', () {
    final Map<String, dynamic> expected = _map(truth['snoozeDefault']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    h.service.snooze();

    expect(h.service.snoozeTimeLeft, expected['snoozeTimeLeft']);
    expect(h.service.isSnoozing(), expected['isSnoozing']);
    expect(h.events, _exp(_list(expected['events'])));
    expect(h.telemetry.entries, _exp(_list(expected['telemetry'])));
    expect(_contextKeySnapshot(h.contextKeyService),
        _exp(_list(expected['contextKeyValues'])));
    h.dispose();
  });

  test('batch198 snooze() extends an existing snooze', () {
    final Map<String, dynamic> expected = _map(truth['extend']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    h.service.snooze(60000);
    fakeNow += 10000; // 50s left
    h.service.snooze(30000);

    expect(h.service.snoozeTimeLeft, expected['snoozeTimeLeft']);
    expect(h.events, _exp(_list(expected['events'])));
    expect(h.telemetry.entries, _exp(_list(expected['telemetry'])));
    h.dispose();
  });

  test('batch198 setSnoozeDuration(0) cancels the snooze', () {
    final Map<String, dynamic> expected = _map(truth['setZero']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    h.service.snooze(60000);
    fakeNow += 20000;
    h.service.setSnoozeDuration(0);

    expect(h.service.snoozeTimeLeft, expected['snoozeTimeLeft']);
    expect(h.service.isSnoozing(), expected['isSnoozing']);
    expect(h.events, _exp(_list(expected['events'])));
    expect(h.telemetry.entries, _exp(_list(expected['telemetry'])));
    h.dispose();
  });

  test('batch198 negative durations throw BugIndicatingError', () {
    final Map<String, dynamic> expected = _map(truth['negative']);
    final _Harness h = _Harness();
    BugIndicatingError? thrown;
    try {
      h.service.setSnoozeDuration(-1);
    } on BugIndicatingError catch (error) {
      thrown = error;
    }
    expect(thrown, isNotNull);
    expect(thrown!.message, expected['message']);
    h.dispose();
  });

  test('batch198 the timer clears the snooze once the clock passes', () async {
    final Map<String, dynamic> expected = _map(truth['expire']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    h.service.setSnoozeDuration(30);
    final Map<String, dynamic> armed = _map(expected['armed']);
    expect(h.service.snoozeTimeLeft, armed['snoozeTimeLeft']);
    expect(h.service.isSnoozing(), armed['isSnoozing']);

    fakeNow += 31;
    final Map<String, dynamic> beforeFire = _map(expected['beforeFire']);
    expect(h.service.snoozeTimeLeft, beforeFire['snoozeTimeLeft']);
    expect(h.service.isSnoozing(), beforeFire['isSnoozing']);

    await Future<void>.delayed(const Duration(milliseconds: 80));

    final Map<String, dynamic> afterFire = _map(expected['afterFire']);
    expect(h.service.snoozeTimeLeft, afterFire['snoozeTimeLeft']);
    expect(h.service.isSnoozing(), afterFire['isSnoozing']);
    expect(h.events, _exp(_list(expected['events'])));
    expect(h.telemetry.entries, _exp(_list(expected['telemetry'])));
    h.dispose();
  });

  test('batch198 cancelSnooze() is a no-op when not snoozing', () {
    final Map<String, dynamic> expected = _map(truth['cancelNoop']);
    final _Harness h = _Harness();
    h.service.cancelSnooze();
    expect(h.events, _exp(_list(expected['events'])));
    expect(h.telemetry.entries, _exp(_list(expected['telemetry'])));
    h.dispose();
  });

  test('batch198 reportNewCompletion keeps the last five ids', () {
    final Map<String, dynamic> expected = _map(truth['reportNewCompletion']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    for (final String id in <String>['a', 'b', 'c', 'd', 'e', 'f', 'g']) {
      h.service.reportNewCompletion(id);
    }
    h.service.snooze(60000);
    expect(h.telemetry.entries, _exp(_list(expected['telemetry'])));
    h.dispose();
  });

  test('batch198 action descriptors and the singleton registration match', () {
    final Map<String, dynamic> expected = _map(truth['actionDescriptors']);
    final SnoozeInlineCompletionActionFixture fixture =
        SnoozeInlineCompletionActionFixture();

    expect(svc.SnoozeInlineCompletion.ID, expected['snoozeId']);
    expect(svc.CancelSnoozeInlineCompletion.ID, expected['cancelId']);

    final Map<String, dynamic> snoozeDesc = _map(expected['snoozeDesc']);
    final Map<String, dynamic> cancelDesc = _map(expected['cancelDesc']);
    expect(fixture.snoozeDescFields(), <String, Object?>{
      'id': snoozeDesc['id'],
      'title': _map(snoozeDesc['title']),
      'f1': snoozeDesc['f1'],
      'preconditionIsTrue': snoozeDesc['preconditionIsTrue'],
    });
    expect(fixture.cancelDescFields(), <String, Object?>{
      'id': cancelDesc['id'],
      'title': _map(cancelDesc['title']),
      'f1': cancelDesc['f1'],
      'preconditionKey': cancelDesc['preconditionKey'],
    });

    // Touching the lazy `final` mirrors the TS module-load registration.
    final List<dynamic> singletons = _list(truth['singletons']);
    svc.inlineCompletionsServiceRegistration;
    final List<List<Object?>> registered = getSingletonServiceDescriptors();
    final List<Object?> entry = registered.last;
    final Map<String, dynamic> expectedSingleton = _map(singletons.first);
    expect(entry[0].toString(), expectedSingleton['id']);
    expect(entry[1], isA<SyncDescriptor>());
    expect((entry[1] as SyncDescriptor).supportsDelayedInstantiation,
        expectedSingleton['type'] == 1);
  });

  test('batch198 snooze action honours its numeric argument', () async {
    final Map<String, dynamic> expected = _map(truth['actionArgSnooze']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    final _FakeQuickInputService quickInput = _FakeQuickInputService();
    final _FakeStorageService storage = _FakeStorageService();
    final _Accessor accessor = _Accessor(
      quickInputService: quickInput,
      inlineCompletionsService: h.service,
      storageService: storage,
    );

    await svc.SnoozeInlineCompletion().run(accessor, <Object?>[10]);

    expect(h.service.snoozeTimeLeft, expected['snoozeTimeLeft']);
    expect(quickInput.pickCalls, _exp(_list(expected['pickCalls'])));
    expect(h.telemetry.entries, _exp(_list(expected['telemetry'])));
    h.dispose();
  });

  test('batch198 snooze action picks a predefined duration', () async {
    final Map<String, dynamic> expected = _map(truth['actionPickPredefined']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    final _FakeQuickInputService quickInput = _FakeQuickInputService();
    final _FakeStorageService storage = _FakeStorageService();
    final _Accessor accessor = _Accessor(
      quickInputService: quickInput,
      inlineCompletionsService: h.service,
      storageService: storage,
    );
    // The picked item carries `value`; the port reads it dynamically.
    quickInput.pickResult =
        _ValueItem(label: '5 minutes', id: '5', value: 300000);

    await svc.SnoozeInlineCompletion().run(accessor);

    expect(quickInput.pickCalls, _exp(_list(expected['pickCalls'])));
    expect(storage.storeCalls, _exp(_list(expected['store'])));
    expect(h.service.snoozeTimeLeft, expected['snoozeTimeLeft']);
    expect(h.telemetry.entries, _exp(_list(expected['telemetry'])));
    h.dispose();
  });

  test('batch198 snooze action inserts the last custom duration in order',
      () async {
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    // 25 min → between 15 and 30
    {
      final Map<String, dynamic> expected = _map(truth['actionPickCustom']);
      final _Harness h = _Harness();
      final _FakeQuickInputService quickInput = _FakeQuickInputService();
      final _FakeStorageService storage = _FakeStorageService()
        ..storedNumber = 1500000;
      final _Accessor accessor = _Accessor(
        quickInputService: quickInput,
        inlineCompletionsService: h.service,
        storageService: storage,
      );
      quickInput.pickResult = null;
      await svc.SnoozeInlineCompletion().run(accessor);
      expect(quickInput.pickCalls, _exp(_list(expected['pickCalls'])));
      h.dispose();
    }

    // 2 min → after 1 min
    {
      final Map<String, dynamic> expected = _map(truth['actionPickLastCustom']);
      final _Harness h = _Harness();
      final _FakeQuickInputService quickInput = _FakeQuickInputService();
      final _FakeStorageService storage = _FakeStorageService()
        ..storedNumber = 120000;
      final _Accessor accessor = _Accessor(
        quickInputService: quickInput,
        inlineCompletionsService: h.service,
        storageService: storage,
      );
      quickInput.pickResult = null;
      await svc.SnoozeInlineCompletion().run(accessor);
      expect(quickInput.pickCalls, _exp(_list(expected['pickCalls'])));
      h.dispose();
    }
  });

  test('batch198 snooze action asks for a custom duration and validates it',
      () async {
    final Map<String, dynamic> expected = _map(truth['actionPickCustomFlow']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    final _FakeQuickInputService quickInput = _FakeQuickInputService();
    final _FakeStorageService storage = _FakeStorageService();
    final _Accessor accessor = _Accessor(
      quickInputService: quickInput,
      inlineCompletionsService: h.service,
      storageService: storage,
    );
    quickInput.pickResult =
        _ValueItem(label: 'Custom...', id: 'custom', value: -1);
    quickInput.inputResult = '90';

    await svc.SnoozeInlineCompletion().run(accessor);

    expect(quickInput.pickCalls, _exp(_list(expected['pickCalls'])));
    final Map<String, dynamic> inputCall =
        _map(_list(expected['inputCalls']).first);
    expect(quickInput.inputCalls, _exp(<Map<String, Object?>>[
      <String, Object?>{
        'placeHolder': inputCall['placeHolder'],
        'prompt': inputCall['prompt'],
      }
    ]));
    final Object? Function(String)? validate =
        quickInput.inputOptions.single.validateInput;
    expect(validate, isNotNull);
    final Map<String, dynamic> expectedValidate = _map(inputCall['validate']);
    final Map<String, Object?> actualValidate = <String, Object?>{};
    for (final String input in <String>['90', '2.5', '-5', '0', 'abc', 'Infinity', '']) {
      actualValidate[input] = await validate!(input);
    }
    expect(actualValidate, _exp(expectedValidate));
    expect(storage.storeCalls, _exp(_list(expected['store'])));
    expect(h.service.snoozeTimeLeft, expected['snoozeTimeLeft']);
    h.dispose();
  });

  test('batch198 cancelled custom input does not store', () async {
    final Map<String, dynamic> expected = _map(truth['actionCustomCancelled']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    final _FakeQuickInputService quickInput = _FakeQuickInputService();
    final _FakeStorageService storage = _FakeStorageService();
    final _Accessor accessor = _Accessor(
      quickInputService: quickInput,
      inlineCompletionsService: h.service,
      storageService: storage,
    );
    quickInput.pickResult =
        _ValueItem(label: 'Custom...', id: 'custom', value: -1);
    quickInput.inputResult = '';

    await svc.SnoozeInlineCompletion().run(accessor);

    expect(storage.storeCalls, _exp(_list(expected['store'])));
    h.dispose();
  });

  test('batch198 cancel action cancels the snooze', () async {
    final Map<String, dynamic> expected = _map(truth['actionCancel']);
    int fakeNow = 1000000;
    svc.dateNowOverride = () => fakeNow;

    final _Harness h = _Harness();
    final _FakeQuickInputService quickInput = _FakeQuickInputService();
    final _FakeStorageService storage = _FakeStorageService();
    final _Accessor accessor = _Accessor(
      quickInputService: quickInput,
      inlineCompletionsService: h.service,
      storageService: storage,
    );
    h.service.snooze(60000);
    await svc.CancelSnoozeInlineCompletion().run(accessor);

    expect(h.service.isSnoozing(), expected['isSnoozing']);
    expect(h.service.snoozeTimeLeft, expected['snoozeTimeLeft']);
    h.dispose();
  });
}

/// Picked item carrying the TS intersection's extra `value` field.
class _ValueItem extends quickInput.IQuickPickItem {
  _ValueItem({required super.label, super.id, required this.value});

  final int value;
}

/// Reads the private descriptor objects through `Action2.desc` (dynamic, the
/// same way `registerAction2` reads them).
class SnoozeInlineCompletionActionFixture {
  SnoozeInlineCompletionActionFixture() {
    _snooze = svc.SnoozeInlineCompletion();
    _cancel = svc.CancelSnoozeInlineCompletion();
  }

  late final svc.SnoozeInlineCompletion _snooze;
  late final svc.CancelSnoozeInlineCompletion _cancel;

  Map<String, Object?> snoozeDescFields() {
    final dynamic desc = _snooze.desc;
    return <String, Object?>{
      'id': desc.id,
      'title': _titleOf(desc.title as Object?),
      'f1': desc.f1,
      'preconditionIsTrue': _isTrueExpr(desc.precondition),
    };
  }

  Map<String, Object?> cancelDescFields() {
    final dynamic desc = _cancel.desc;
    return <String, Object?>{
      'id': desc.id,
      'title': _titleOf(desc.title as Object?),
      'f1': desc.f1,
      'preconditionKey': desc.precondition is contextkey.RawContextKey
          ? (desc.precondition as contextkey.RawContextKey).key
          : null,
    };
  }

  bool _isTrueExpr(Object? expression) =>
      identical(expression, contextkey.ContextKeyTrueExpr.INSTANCE);
}
