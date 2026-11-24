// Truth replay for batch197:
//   `platform/quickinput/browser/quickAccess.ts`.
//
// Expectations come from `tool/ts2dart/batch197_truth.json`, produced by
// `tool/ts2dart/_batch197_truth.cjs` (real transpiled TypeScript + the real
// `platform/quickinput/common/*`, `base/common/{async,cancellation,event,
// lifecycle}` and `platform/registry`). The quick pick and the three injected
// services are deterministic fakes, so every branch is observable.
//
// NOTE: `quickAccess.ts` has no official test of its own (the STRICT+test
// match is the usual stem heuristic false positive); truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import '../lib/src/monaco/base/common/event.dart' as event;
import '../lib/src/monaco/base/common/keybindings.dart' show ResolvedKeybinding;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/platform/contextkey/common/contextkey.dart'
    show IContextKeyServiceType;
import '../lib/src/monaco/platform/instantiation/common/instantiation.dart'
    show IInstantiationServiceType;
import '../lib/src/monaco/platform/quickinput/browser/quickAccess.dart'
    as controllerLib;
import '../lib/src/monaco/platform/quickinput/common/quickAccess.dart'
    as quickAccess;
import '../lib/src/monaco/platform/quickinput/common/quickInput.dart'
    as quickInput;
import '../lib/src/monaco/platform/registry/common/platform.dart' as platform;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() => _map(
    jsonDecode(File('tool/ts2dart/batch197_truth.json').readAsStringSync()));

String _memberName(Invocation invocation) {
  final String raw = invocation.memberName.toString();
  final int start = raw.indexOf('"') + 1;
  final int end = raw.lastIndexOf('"');
  return raw.substring(start, end).replaceAll('=', '');
}

/// `IQuickPick` fake: explicit members for the events/counters the controller
/// touches, everything else in a property map through `noSuchMethod` (the TS
/// picker is a plain mutable object).
class _FakePicker implements quickInput.IQuickPick<quickInput.IQuickPickItem> {
  final Map<String, Object?> props = <String, Object?>{};

  final event.Emitter<String> _onDidChangeValue = event.Emitter<String>();
  final event.Emitter<quickInput.IQuickPickWillAcceptEvent> _onWillAccept =
      event.Emitter<quickInput.IQuickPickWillAcceptEvent>();
  final event.Emitter<quickInput.IQuickPickDidAcceptEvent> _onDidAccept =
      event.Emitter<quickInput.IQuickPickDidAcceptEvent>();
  final event.Emitter<quickInput.IQuickInputHideEvent> _onDidHide =
      event.Emitter<quickInput.IQuickInputHideEvent>();

  int shows = 0;
  int hides = 0;
  int disposals = 0;

  @override
  event.Event<String> get onDidChangeValue => _onDidChangeValue.event;
  @override
  event.Event<quickInput.IQuickPickWillAcceptEvent> get onWillAccept =>
      _onWillAccept.event;
  @override
  event.Event<quickInput.IQuickPickDidAcceptEvent> get onDidAccept =>
      _onDidAccept.event;
  @override
  event.Event<quickInput.IQuickInputHideEvent> get onDidHide =>
      _onDidHide.event;

  @override
  void show() => shows++;
  @override
  void hide() => hides++;
  @override
  void dispose() => disposals++;

  void fireChangeValue(String value) => _onDidChangeValue.fire(value);
  void fireAccept() => _onDidAccept
      .fire(quickInput.IQuickPickDidAcceptEvent(inBackground: false));
  void fireHide() => _onDidHide.fire(quickInput.IQuickInputHideEvent(
      reason: quickInput.QuickInputHideReason.Gesture));

  /// Fires `onWillAccept` and reports the state *after* the once-listener ran
  /// (the TS truth snapshot is taken post-fire, so `listeners` is 0).
  ({int listeners, int vetoed}) fireWillAccept() {
    final List<bool> vetoed = <bool>[];
    _onWillAccept.fire(_FakeWillAcceptEvent(() => vetoed.add(true)));
    return (
      listeners: _onWillAccept.hasListeners() ? 1 : 0,
      vetoed: vetoed.length
    );
  }

  Map<String, Object?> listenerCounts() => <String, Object?>{
        'changeValue': _onDidChangeValue.hasListeners() ? 1 : 0,
        'willAccept': _onWillAccept.hasListeners() ? 1 : 0,
        'accept': _onDidAccept.hasListeners() ? 1 : 0,
        'hide': _onDidHide.hasListeners() ? 1 : 0,
      };

  Map<String, Object?> snapshot() {
    final Object? filterFn = props['filterValue'];
    return <String, Object?>{
      'value': value,
      'valueSelection': valueSelection,
      'placeholder': placeholder,
      'anchor': anchor,
      'anchorPosition': anchorPosition,
      'quickNavigate': quickNavigate == null ? null : 'set',
      'hideInput': hideInput,
      'itemActivation': itemActivation,
      'contextKey': contextKey,
      'filterValueOfPrefix': filterFn is String Function(String)
          ? filterFn('PREFIXrest')
          : null,
      'shows': shows,
      'hides': hides,
      'disposals': disposals,
      'selected':
          selectedItems.map((quickInput.IQuickPickItem i) => i.label).toList(),
      'listeners': listenerCounts(),
    };
  }

  String get value => (props['value'] as String?) ?? '';
  set value(String v) => props['value'] = v;
  List<num>? get valueSelection => (props['valueSelection'] as List<num>?);
  set valueSelection(List<num>? v) => props['valueSelection'] = v;
  String? get placeholder => (props['placeholder'] as String?);
  set placeholder(String? v) => props['placeholder'] = v;
  Object? get anchor => props['anchor'];
  set anchor(Object? v) => props['anchor'] = v;
  String? get anchorPosition => (props['anchorPosition'] as String?);
  set anchorPosition(String? v) => props['anchorPosition'] = v;
  quickInput.IQuickNavigateConfiguration? get quickNavigate =>
      (props['quickNavigate'] as quickInput.IQuickNavigateConfiguration?);
  set quickNavigate(quickInput.IQuickNavigateConfiguration? v) =>
      props['quickNavigate'] = v;
  bool get hideInput => (props['hideInput'] as bool?) ?? false;
  set hideInput(bool v) => props['hideInput'] = v;
  int get itemActivation => (props['itemActivation'] as int?) ?? 0;
  set itemActivation(int v) => props['itemActivation'] = v;
  String? get contextKey => (props['contextKey'] as String?);
  set contextKey(String? v) => props['contextKey'] = v;
  String Function(String) get filterValue =>
      (props['filterValue'] as String Function(String));
  set filterValue(String Function(String) v) => props['filterValue'] = v;
  List<quickInput.IQuickPickItem> get selectedItems =>
      (props['selectedItems'] as List<quickInput.IQuickPickItem>?) ??
      <quickInput.IQuickPickItem>[];
  set selectedItems(List<quickInput.IQuickPickItem> v) =>
      props['selectedItems'] = v;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final String name = _memberName(invocation);
    if (invocation.isGetter) {
      return props[name];
    }
    if (invocation.isSetter) {
      props[name] = invocation.positionalArguments.isEmpty
          ? null
          : invocation.positionalArguments.first;
      return null;
    }
    return null;
  }
}

class _FakeWillAcceptEvent implements quickInput.IQuickPickWillAcceptEvent {
  _FakeWillAcceptEvent(this._veto);

  final void Function() _veto;

  @override
  void veto() => _veto();
}

/// Records `provide()` calls, the cancellation token and both disposal paths.
class _FakeProvider
    implements quickAccess.IQuickAccessProvider, lifecycle.IDisposable {
  _FakeProvider({this.defaultFilterValue});

  @override
  final Object? defaultFilterValue;

  final List<Map<String, Object?>> provided = <Map<String, Object?>>[];
  final List<CancellationToken> tokens = <CancellationToken>[];
  int handleDisposals = 0;
  int providerDisposals = 0;

  @override
  lifecycle.IDisposable provide(
    quickInput.IQuickPick<quickInput.IQuickPickItem> picker,
    CancellationToken token, [
    quickAccess.IQuickAccessProviderRunOptions? options,
  ]) {
    provided.add(<String, Object?>{
      'value': picker.value,
      'hasToken': true,
      'options': options,
    });
    tokens.add(token);
    return lifecycle.toDisposable(() => handleDisposals++);
  }

  @override
  void dispose() => providerDisposals++;
}

class _Ctor {
  const _Ctor(this.id);

  final String id;
}

/// `IQuickInputService` fake: builds pickers and records the options object.
class _FakeQuickInputService implements quickInput.IQuickInputServiceType {
  final List<Object?> createQuickPickOptions = <Object?>[];
  final List<_FakePicker> pickers = <_FakePicker>[];

  @override
  quickInput.IQuickPick<quickInput.IQuickPickItem> createQuickPick(
      [Object? options]) {
    createQuickPickOptions.add(options);
    final _FakePicker picker = _FakePicker();
    pickers.add(picker);
    return picker;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// `IInstantiationService` fake: resolves registered ctors to provider fakes.
class _FakeInstantiationService implements IInstantiationServiceType {
  final Map<Object, quickAccess.IQuickAccessProvider> byCtor =
      <Object, quickAccess.IQuickAccessProvider>{};
  final List<String> instances = <String>[];

  @override
  Object? createInstance(Object ctor, List<Object?> args) {
    instances.add(ctor is _Ctor ? ctor.id : 'ctor');
    return byCtor[ctor];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// `IContextKeyService` fake: every `when` expression matches.
class _FakeContextKeyService implements IContextKeyServiceType {
  @override
  bool contextMatchesRules(Object? rules) => true;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (_memberName(invocation) == 'contextMatchesRules') {
      return true;
    }
    return null;
  }
}

quickAccess.IQuickAccessRegistry get _registry =>
    platform.Registry.as(quickAccess.Extensions.Quickaccess)
        as quickAccess.IQuickAccessRegistry;

class _Harness {
  _Harness() {
    instantiation = _FakeInstantiationService();
    service = _FakeQuickInputService();
    controller = controllerLib.QuickAccessController(
        service, instantiation, _FakeContextKeyService());
  }

  late final _FakeInstantiationService instantiation;
  late final _FakeQuickInputService service;
  late final controllerLib.QuickAccessController controller;
  final List<lifecycle.IDisposable> registrations = <lifecycle.IDisposable>[];

  void register(
    String prefix,
    _Ctor ctor,
    _FakeProvider provider, {
    String? placeholder,
    String? contextKey,
  }) {
    final quickAccess.IQuickAccessProviderDescriptor descriptor =
        quickAccess.IQuickAccessProviderDescriptor(
      ctor: ctor,
      prefix: prefix,
      placeholder: placeholder,
      helpEntries: const <quickAccess.IQuickAccessProviderHelp>[],
      contextKey: contextKey,
    );
    registrations.add(_registry.registerQuickAccessProvider(descriptor));
    instantiation.byCtor[ctor] = provider;
  }

  void disposeAll() {
    for (final lifecycle.IDisposable registration in registrations) {
      registration.dispose();
    }
    registrations.clear();
    controller.dispose();
  }
}

/// `{ value, hasToken, options: { from, placeholder } | null }` per `provide`.
List<Map<String, Object?>> _provided(
        List<Map<String, Object?>> provided) =>
    provided
        .map((Map<String, Object?> p) {
          final Object? options = p['options'];
          return <String, Object?>{
            'value': p['value'],
            'hasToken': p['hasToken'],
            'options': options is quickAccess.IQuickAccessProviderRunOptions
                ? <String, Object?>{
                    'from': options.from,
                    'placeholder': options.placeholder,
                  }
                : null,
          };
        })
        .toList();

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch197 enums match truth', () {
    final Map<String, dynamic> enums = _map(truth['enums']);
    final Map<String, dynamic> defaultFilterValue =
        _map(enums['DefaultQuickAccessFilterValue']);
    final Map<String, dynamic> itemActivation = _map(enums['ItemActivation']);
    expect(quickAccess.DefaultQuickAccessFilterValue.PRESERVE,
        defaultFilterValue['PRESERVE']);
    expect(quickAccess.DefaultQuickAccessFilterValue.LAST,
        defaultFilterValue['LAST']);
    expect(quickInput.ItemActivation.NONE, itemActivation['NONE']);
    expect(quickInput.ItemActivation.FIRST, itemActivation['FIRST']);
    expect(quickInput.ItemActivation.SECOND, itemActivation['SECOND']);
    expect(quickInput.ItemActivation.LAST, itemActivation['LAST']);
  });

  test('batch197 show() wires the picker like truth', () {
    final Map<String, dynamic> expected = _map(truth['showBasic']);
    final _Harness h = _Harness();
    final _FakeProvider provider = _FakeProvider();
    h.register('test', const _Ctor('TestProviderCtor'), provider,
        placeholder: 'Test placeholder', contextKey: 'inTest');

    h.controller.show('test');
    final _FakePicker picker = h.service.pickers[0];
    expect(h.service.createQuickPickOptions[0],
        _exp(_map(expected['createQuickPickOptions'])));
    expect(picker.snapshot(), _exp(_map(expected['picker'])));
    expect(_provided(provider.provided), _exp(_list(expected['provided'])));
    expect(h.instantiation.instances, _exp(_list(expected['instances'])));

    // A more specific value on the same provider updates the reused picker.
    final Map<String, dynamic> same = _map(truth['showSamePrefix']);
    picker.value = 'test foo';
    h.controller.show('test foo');
    expect(h.service.pickers.length, same['pickers']);
    expect(picker.snapshot(), _exp(_map(same['picker'])));

    // preserveValue keeps the typed value and only moves the cursor.
    final Map<String, dynamic> preserve = _map(truth['showPreserve']);
    picker.value = 'test foo';
    h.controller
        .show('test', quickAccess.IQuickAccessOptions(preserveValue: true));
    expect(h.service.pickers.length, preserve['pickers']);
    expect(picker.snapshot(), _exp(_map(preserve['picker'])));

    h.disposeAll();
  });

  test('batch197 pick() vetoes, resolves and cancels like truth', () async {
    final _Harness h = _Harness();
    final _FakeProvider provider = _FakeProvider();
    h.register('test', const _Ctor('PickProviderCtor'), provider);

    final Map<String, dynamic> resolvedExpected = _map(truth['pickResolve']);
    final Future<List<quickInput.IQuickPickItem>?> promise =
        h.controller.pick('test');
    final _FakePicker picker = h.service.pickers[0];
    final ({int listeners, int vetoed}) veto = picker.fireWillAccept();
    picker.selectedItems = <quickInput.IQuickPickItem>[
      quickInput.IQuickPickItem(label: 'one'),
      quickInput.IQuickPickItem(label: 'two'),
    ];
    picker.fireHide();

    final List<quickInput.IQuickPickItem>? resolved = await promise;
    expect(<String, Object?>{'listeners': veto.listeners, 'vetoed': veto.vetoed},
        _exp(_map(resolvedExpected['veto'])));
    expect(resolved!.map((i) => i.label).toList(),
        _exp(_list(resolvedExpected['resolved'])));
    expect(provider.tokens.last.isCancellationRequested,
        resolvedExpected['tokenCancelled']);
    expect(provider.handleDisposals, resolvedExpected['providerDisposed']);
    expect(picker.snapshot(), _exp(_map(resolvedExpected['picker'])));

    // No selection: the token gets cancelled instead.
    final Map<String, dynamic> cancelExpected = _map(truth['pickCancel']);
    final Future<List<quickInput.IQuickPickItem>?> promise2 =
        h.controller.pick('test');
    final _FakePicker picker2 = h.service.pickers[1];
    picker2.fireHide();
    final List<quickInput.IQuickPickItem>? resolved2 = await promise2;
    expect(resolved2!.map((i) => i.label).toList(),
        _exp(_list(cancelExpected['resolved'])));
    expect(provider.tokens.last.isCancellationRequested,
        cancelExpected['tokenCancelled']);
    expect(provider.handleDisposals, cancelExpected['providerDisposed']);
    expect(picker2.snapshot(), _exp(_map(cancelExpected['picker'])));

    h.disposeAll();
  });

  test('batch197 switches providers by rewriting the value', () {
    final Map<String, dynamic> expected = _map(truth['switchProvider']);
    final _Harness h = _Harness();
    final _FakeProvider testProvider = _FakeProvider();
    final _FakeProvider otherProvider = _FakeProvider();
    h.register('test', const _Ctor('TestCtor'), testProvider);
    h.register('other', const _Ctor('OtherCtor'), otherProvider,
        placeholder: 'Other placeholder');

    h.controller.show('test');
    final _FakePicker first = h.service.pickers[0];
    first.value = 'testxyz';
    first.fireChangeValue('testxyz');
    h.controller.show('other');

    final _FakePicker second = h.service.pickers[1];
    expect(h.service.pickers.length, expected['pickers']);
    expect(<String, Object?>{'value': first.value, 'disposals': first.disposals},
        _exp(_map(expected['first'])));
    expect(second.snapshot(), _exp(_map(expected['second'])));
    expect(_provided(otherProvider.provided), _exp(_list(expected['provided'])));

    h.disposeAll();
  });

  test('batch197 applies default filter values', () {
    final Map<String, dynamic> expected = _map(truth['defaultFilterValue']);
    final _Harness h = _Harness();
    final _FakeProvider last = _FakeProvider(
        defaultFilterValue: quickAccess.DefaultQuickAccessFilterValue.LAST);
    final _FakeProvider preset = _FakeProvider(defaultFilterValue: ' preset');
    h.register('last', const _Ctor('LastCtor'), last);
    h.register('preset', const _Ctor('PresetCtor'), preset);

    // LAST without any previous accept stays at the bare prefix.
    h.controller.show('last');
    expect(h.service.pickers[0].value, expected['before']);

    // Accept once, then reopen: the accepted value is restored.
    h.service.pickers[0].value = 'last chosen';
    h.service.pickers[0].fireAccept();
    h.service.pickers[0].fireHide();
    h.controller.show('last');
    expect(h.service.pickers[1].value, expected['after']);

    // The visible provider's suffix wins over the registered preset default.
    h.controller.show('preset');
    expect(h.service.pickers[2].value, expected['preset']);

    h.disposeAll();
  });

  test('batch197 honours enabled prefixes and providerPrefix', () {
    final Map<String, dynamic> expected = _map(truth['providerSelection']);
    final _Harness h = _Harness();
    final _FakeProvider provider = _FakeProvider();
    h.register('test', const _Ctor('EnabledCtor'), provider);

    final Map<String, dynamic> disabled = _map(expected['disabled']);
    h.controller.show(
        'test',
        quickAccess.IQuickAccessOptions(
            enabledProviderPrefixes: <String>['other']));
    expect(h.service.pickers[0].snapshot(), _exp(_map(disabled['picker'])));
    expect(provider.provided.length, disabled['provided']);
    expect(h.instantiation.instances.length, disabled['instances']);

    final Map<String, dynamic> prefixed = _map(expected['prefixed']);
    h.controller.show(
        '', quickAccess.IQuickAccessOptions(providerPrefix: 'test'));
    expect(h.service.pickers[1].snapshot(), _exp(_map(prefixed['picker'])));
    expect(provider.provided.map((p) => p['value']),
        _exp(_list(prefixed['provided'])));

    h.disposeAll();
  });

  test('batch197 quick navigate hides the input and activates second', () {
    final Map<String, dynamic> expected = _map(truth['quickNavigate']);
    final _Harness h = _Harness();
    final _FakeProvider provider = _FakeProvider();
    h.register('test', const _Ctor('NavCtor'), provider,
        placeholder: 'Nav placeholder');

    final quickInput.IQuickNavigateConfiguration quickNavigate =
        quickInput.IQuickNavigateConfiguration(
            keybindings: const <ResolvedKeybinding>[]);
    h.controller.show(
        'test',
        quickAccess.IQuickAccessOptions(
            quickNavigateConfiguration: quickNavigate));
    final _FakePicker picker = h.service.pickers[0];
    expect(picker.snapshot(), _exp(_map(expected['first'])));

    h.controller.show(
        'test',
        quickAccess.IQuickAccessOptions(
          quickNavigateConfiguration: quickNavigate,
          itemActivation: quickInput.ItemActivation.FIRST,
        ));
    // The same descriptor reuses the visible picker, which keeps activation 2.
    expect(picker.snapshot(), _exp(_map(expected['second'])));

    h.disposeAll();
  });

  test('batch197 re-enters show() when the value switches provider', () {
    final Map<String, dynamic> expected = _map(truth['changeValueSwitch']);
    final _Harness h = _Harness();
    final _FakeProvider testProvider = _FakeProvider();
    final _FakeProvider otherProvider = _FakeProvider();
    h.register('test', const _Ctor('CVTestCtor'), testProvider);
    h.register('other', const _Ctor('CVOtherCtor'), otherProvider);

    h.controller.show('test');
    final _FakePicker first = h.service.pickers[0];
    first.fireChangeValue('other thing');

    expect(h.service.pickers.length, expected['pickers']);
    expect(h.service.pickers[1].snapshot(), _exp(_map(expected['second'])));
    expect(_provided(otherProvider.provided), _exp(_list(expected['provided'])));
    expect(first.listenerCounts(), _exp(_map(expected['firstListeners'])));

    h.disposeAll();
  });

  test('batch197 passes anchor, placeholder and providerOptions through', () {
    final Map<String, dynamic> expected = _map(truth['anchors']);
    final _Harness h = _Harness();
    final _FakeProvider provider = _FakeProvider();
    h.register('test', const _Ctor('AnchorCtor'), provider,
        placeholder: 'Descriptor placeholder');

    h.controller.show(
        'test foo',
        quickAccess.IQuickAccessOptions(
          anchor: <String, int>{'x': 1, 'y': 2},
          anchorPosition: 'above',
          placeholder: 'Option placeholder',
          providerOptions:
              quickAccess.IQuickAccessProviderRunOptions(from: 'src'),
        ));

    expect(h.service.pickers[0].snapshot(), _exp(_map(expected['picker'])));
    expect(_provided(provider.provided), _exp(_list(expected['provided'])));

    h.disposeAll();
  });

  test('batch197 disposes providers and the visible picker', () {
    final Map<String, dynamic> expected = _map(truth['disposeController']);
    final _Harness h = _Harness();
    final _FakeProvider provider = _FakeProvider();
    h.register('test', const _Ctor('DisposeCtor'), provider);

    h.controller.show('test');
    final _FakePicker picker = h.service.pickers[0];
    h.disposeAll();

    expect(provider.handleDisposals, expected['handleDisposed']);
    expect(provider.providerDisposals, expected['providerDisposed']);
    expect(picker.disposals, expected['pickerDisposals']);
  });
}