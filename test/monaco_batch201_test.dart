// Truth replay for batch201:
//   `platform/quickinput/browser/helpQuickAccess.ts`.
//
// Expectations come from `tool/ts2dart/batch201_truth.json`, produced by
// `tool/ts2dart/_batch201_truth.cjs` (real transpiled provider + the real
// `platform/quickinput/common` ports, `Registry` and `nls`; the quick-input,
// keybinding and context-key services are observable fakes).
//
// NOTE: `helpQuickAccess.ts` has no official test of its own; truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/cancellation.dart'
    show CancellationTokenSource;
import '../lib/src/monaco/base/common/event.dart' as event;
import '../lib/src/monaco/base/common/keybindings.dart'
    show ResolvedKeybinding;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/platform/contextkey/common/contextkey.dart'
    show IContextKeyServiceType;
import '../lib/src/monaco/platform/keybinding/common/keybinding.dart'
    show IKeybindingServiceType;
import '../lib/src/monaco/platform/quickinput/browser/helpQuickAccess.dart'
    as help;
import '../lib/src/monaco/platform/quickinput/common/quickAccess.dart'
    as quickAccess;
import '../lib/src/monaco/platform/quickinput/common/quickInput.dart'
    as quickInput;
import '../lib/src/monaco/platform/registry/common/platform.dart' as platform;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch201_truth.json').readAsStringSync()));

String _memberName(Invocation invocation) {
  final String raw = invocation.memberName.toString();
  final int start = raw.indexOf('"') + 1;
  final int end = raw.lastIndexOf('"');
  return raw.substring(start, end).replaceAll('=', '');
}

class _KeybindingStub implements ResolvedKeybinding {
  _KeybindingStub(this.commandId, this.label);

  final String commandId;
  final String label;

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
    if (commandId == 'cmd.with.binding') {
      return _KeybindingStub(commandId, 'Ctrl+K');
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeContextKeyService implements IContextKeyServiceType {
  @override
  bool contextMatchesRules(Object? rules) => true;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (_memberName(invocation) == 'contextMatchesRules') return true;
    return null;
  }
}

class _ShowCall {
  _ShowCall(this.value, this.options);

  final String? value;
  final quickAccess.IQuickAccessOptions? options;

  Map<String, Object?> toJson() => <String, Object?>{
        'value': value,
        'options': options == null
            ? null
            : <String, Object?>{'preserveValue': options!.preserveValue},
      };
}

class _FakeQuickAccessController implements quickAccess.IQuickAccessController {
  final List<_ShowCall> showCalls = <_ShowCall>[];

  @override
  void show([String? value, quickAccess.IQuickAccessOptions? options]) {
    showCalls.add(_ShowCall(value, options));
  }

  @override
  Future<List<quickInput.IQuickPickItem>?> pick(
      [String? value, quickAccess.IQuickAccessOptions? options]) async {
    return null;
  }
}

/// `IQuickAccessController` aliased so the `quickAccess` getter below does not
/// shadow the import prefix.
typedef _QAController = quickAccess.IQuickAccessController;

class _FakeQuickInputService implements quickInput.IQuickInputServiceType {
  final _FakeQuickAccessController controller = _FakeQuickAccessController();

  @override
  _QAController get quickAccess => controller;
  @override
  set quickAccess(_QAController value) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakePicker implements quickInput.IQuickPick<quickInput.IQuickPickItem> {
  final event.Emitter<quickInput.IQuickPickDidAcceptEvent> _onDidAccept =
      event.Emitter<quickInput.IQuickPickDidAcceptEvent>();
  final event.Emitter<String> _onDidChangeValue = event.Emitter<String>();

  List<Object> items = <Object>[];
  List<quickInput.IQuickPickItem> selectedItems = <quickInput.IQuickPickItem>[];

  @override
  event.Event<quickInput.IQuickPickDidAcceptEvent> get onDidAccept =>
      _onDidAccept.event;
  @override
  event.Event<String> get onDidChangeValue => _onDidChangeValue.event;

  void fireAccept() => _onDidAccept
      .fire(quickInput.IQuickPickDidAcceptEvent(inBackground: false));
  void fireChangeValue(String value) => _onDidChangeValue.fire(value);

  ({int accept, int changeValue}) listenerCounts() => (
        accept: _onDidAccept.hasListeners() ? 1 : 0,
        changeValue: _onDidChangeValue.hasListeners() ? 1 : 0,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final String name = _memberName(invocation);
    if (invocation.isGetter) {
      switch (name) {
        case 'items':
          return items;
        case 'selectedItems':
          return selectedItems;
      }
      return null;
    }
    if (invocation.isSetter) {
      final Object? value = invocation.positionalArguments.isEmpty
          ? null
          : invocation.positionalArguments.first;
      switch (name) {
        case 'items':
          items = (value as List).cast<Object>();
          return null;
        case 'selectedItems':
          selectedItems = (value as List).cast<quickInput.IQuickPickItem>();
          return null;
      }
      return null;
    }
    return null;
  }
}

quickAccess.IQuickAccessRegistry get _registry =>
    platform.Registry.as(quickAccess.Extensions.Quickaccess)
        as quickAccess.IQuickAccessRegistry;

class _Harness {
  _Harness() {
    quickInputService = _FakeQuickInputService();
    keybindingService = _FakeKeybindingService();
    provider = help.HelpQuickAccessProvider(
        quickInputService, keybindingService, _FakeContextKeyService());
  }

  late final _FakeQuickInputService quickInputService;
  late final _FakeKeybindingService keybindingService;
  late final help.HelpQuickAccessProvider provider;
  final List<lifecycle.IDisposable> registrations = <lifecycle.IDisposable>[];

  void register(String prefix, List<quickAccess.IQuickAccessProviderHelp> helpEntries) {
    final quickAccess.IQuickAccessProviderDescriptor descriptor =
        quickAccess.IQuickAccessProviderDescriptor(
      ctor: <String, Object?>{'id': 'ctor:$prefix'},
      prefix: prefix,
      helpEntries: helpEntries,
      placeholder: prefix.isEmpty ? null : '$prefix placeholder',
    );
    registrations.add(_registry.registerQuickAccessProvider(descriptor));
  }

  void disposeAll() {
    for (final lifecycle.IDisposable registration in registrations) {
      registration.dispose();
    }
    registrations.clear();
  }
}

Map<String, Object?> _pickSnapshot(Object pick) {
  final dynamic item = pick;
  final Object? keybinding = item.keybinding;
  return <String, Object?>{
    'prefix': item.prefix,
    'label': item.label,
    'description': item.description,
    'ariaLabel': item.ariaLabel,
    'keybinding': keybinding == null
        ? null
        : <String, Object?>{
            'commandId': (keybinding as dynamic).commandId,
            'label': (keybinding as dynamic).label,
          },
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch201 constants match truth', () {
    final Map<String, dynamic> expected = _map(truth['constants']);
    expect(help.HelpQuickAccessProvider.PREFIX, expected['prefix']);
    expect(quickInput.IQuickInputService.toString(),
        expected['quickInputServiceId']);
  });

  test('batch201 getQuickAccessProviders builds and sorts the picks', () {
    final _Harness h = _Harness();
    h.register('aa', <quickAccess.IQuickAccessProviderHelp>[
      quickAccess.IQuickAccessProviderHelp(
          description: 'Alpha help', commandId: 'cmd.with.binding'),
      quickAccess.IQuickAccessProviderHelp(
          prefix: 'aa-custom', description: 'Custom prefix help'),
      quickAccess.IQuickAccessProviderHelp(description: 'No binding help'),
      quickAccess.IQuickAccessProviderHelp(
          prefix: '', description: 'Empty prefix help'),
    ]);
    h.register('bb', <quickAccess.IQuickAccessProviderHelp>[
      quickAccess.IQuickAccessProviderHelp(description: 'Beta help'),
    ]);
    // An empty registration prefix becomes the registry's default provider.
    h.register('', <quickAccess.IQuickAccessProviderHelp>[
      quickAccess.IQuickAccessProviderHelp(description: 'Default help'),
    ]);
    h.register('?', <quickAccess.IQuickAccessProviderHelp>[
      quickAccess.IQuickAccessProviderHelp(description: 'Help about help'),
    ]);

    final List<Object> picks = h.provider.getQuickAccessProviders();
    expect(picks.map(_pickSnapshot).toList(), _exp(_list(truth['picks'])));
    expect(h.keybindingService.lookups,
        _exp(_list(truth['keybindingLookups'])));
    h.disposeAll();
  });

  test('batch201 provide() fills items and registers both listeners', () {
    final Map<String, dynamic> expected = _map(truth['provide']);
    final _Harness h = _Harness();
    h.register('aa', <quickAccess.IQuickAccessProviderHelp>[
      quickAccess.IQuickAccessProviderHelp(
          description: 'Alpha help', commandId: 'cmd.with.binding'),
      quickAccess.IQuickAccessProviderHelp(
          prefix: 'aa-custom', description: 'Custom prefix help'),
      quickAccess.IQuickAccessProviderHelp(description: 'No binding help'),
      quickAccess.IQuickAccessProviderHelp(
          prefix: '', description: 'Empty prefix help'),
    ]);
    h.register('bb', <quickAccess.IQuickAccessProviderHelp>[
      quickAccess.IQuickAccessProviderHelp(description: 'Beta help'),
    ]);
    h.register('', <quickAccess.IQuickAccessProviderHelp>[
      quickAccess.IQuickAccessProviderHelp(description: 'Default help'),
    ]);
    h.register('?', <quickAccess.IQuickAccessProviderHelp>[
      quickAccess.IQuickAccessProviderHelp(description: 'Help about help'),
    ]);

    final _FakePicker picker = _FakePicker();
    final lifecycle.IDisposable disposable =
        h.provider.provide(picker, CancellationTokenSource().token);

    expect(
        picker.items
            .map((Object item) => (item as dynamic).prefix)
            .toList(),
        _exp(_list(expected['itemPrefixes'])));
    expect(
        picker.items
            .map((Object item) => (item as quickInput.IQuickPickItem).label)
            .toList(),
        _exp(_list(expected['itemLabels'])));
    expect(<String, Object?>{
      'accept': picker.listenerCounts().accept,
      'changeValue': picker.listenerCounts().changeValue,
    }, _exp(_map(expected['listeners'])));

    // Accepting a selection opens quick access for that prefix.
    picker.selectedItems = <quickInput.IQuickPickItem>[_PrefixItem('bb')];
    picker.fireAccept();
    expect(h.quickInputService.controller.showCalls.map((c) => c.toJson()),
        _exp(_list(_map(truth['afterAccept'])['showCalls'])));

    // With no selection the accept is ignored.
    picker.selectedItems = <quickInput.IQuickPickItem>[];
    picker.fireAccept();
    expect(h.quickInputService.controller.showCalls.length,
        _list(_map(truth['afterAccept'])['showCalls']).length);

    // Typing the exact prefix of a provider re-opens quick access.
    h.quickInputService.controller.showCalls.clear();
    picker.fireChangeValue('?bb');
    expect(h.quickInputService.controller.showCalls.map((c) => c.toJson()),
        _exp(_list(_map(truth['afterChangeValueKnown'])['showCalls'])));

    // The help prefix itself never re-opens.
    h.quickInputService.controller.showCalls.clear();
    picker.fireChangeValue('?');
    expect(h.quickInputService.controller.showCalls.map((c) => c.toJson()),
        _exp(_list(_map(truth['afterChangeValueHelp'])['showCalls'])));

    // An unknown prefix does nothing.
    h.quickInputService.controller.showCalls.clear();
    picker.fireChangeValue('?unknown');
    expect(h.quickInputService.controller.showCalls.map((c) => c.toJson()),
        _exp(_list(_map(truth['afterChangeValueUnknown'])['showCalls'])));

    // Disposing the handle drops both listeners.
    disposable.dispose();
    final Map<String, dynamic> afterDispose = _map(truth['afterDispose']);
    expect(picker.listenerCounts().accept, afterDispose['accept']);
    expect(picker.listenerCounts().changeValue, afterDispose['changeValue']);
    h.disposeAll();
  });
}

/// `IHelpQuickAccessPickItem`-shaped selection (only `prefix` is read).
class _PrefixItem extends quickInput.IQuickPickItem {
  _PrefixItem(this.prefix) : super(label: prefix);

  final String prefix;
}