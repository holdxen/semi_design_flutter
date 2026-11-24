// Truth-driven tests for platform/actions/common/menuService.ts.
// Truth: tool/ts2dart/batch163_truth.json (real transpiled TypeScript module).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/actions.dart' as baseActions;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/keybindings.dart' as keybindings;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/platform/actions/common/actions.dart' as actions;
import 'package:semi_design_flutter/src/monaco/platform/actions/common/menuService.dart' as menuService;
import 'package:semi_design_flutter/src/monaco/platform/action/common/action.dart' as action;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart' as commands;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart' as contextkey;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/keybinding.dart' as keybinding;
import 'package:semi_design_flutter/src/monaco/platform/storage/common/storage.dart' as storage;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch163_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _sec(String k) => T[k] as Map<String, dynamic>;
List<dynamic> _list(String k) => T[k] as List<dynamic>;

// ---- fakes ----------------------------------------------------------------

class FakeStorage implements storage.IStorageServiceType {
  FakeStorage([String raw = '{}']) : _raw = raw;

  String _raw;
  final List<Map<String, Object?>> storeLog = <Map<String, Object?>>[];
  final event.Emitter<Object?> _onDidChange = event.Emitter<Object?>();

  void fireChange() => _onDidChange.fire(null);

  @override
  String? get(String key, int scope, [String? fallbackValue]) => _raw;

  @override
  void store(String key, Object? value, int scope, int target,
      [bool external = false]) {
    _raw = value as String;
    storeLog.add(<String, Object?>{
      'key': key,
      'value': value,
      'scope': scope,
      'target': target,
    });
  }

  @override
  event.Event<storage.StorageValueChangeEvent> onDidChangeValue(
          int scope, String? key, lifecycle.DisposableStore disposable) =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
        final lifecycle.IDisposable d = _onDidChange.event(listener, thisArgs, disposables);
        disposable.add(d);
        return d;
      };

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeCommandService implements commands.ICommandServiceType {
  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];

  @override
  Future<Object?> executeCommand(String commandId, List<Object?> args) async {
    calls.add(<String, Object?>{'id': commandId, 'args': args[0]});
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeKeybindingService implements keybinding.IKeybindingServiceType {
  FakeKeybindingService([bool Function(String)? lookup])
      : _lookup = lookup;

  final bool Function(String)? _lookup;

  @override
  keybindings.ResolvedKeybinding? lookupKeybinding(
    String commandId, [
    contextkey.IContextKeyServiceType? context,
    bool enforceContextCheck = false,
  ]) =>
      (_lookup != null && _lookup!(commandId)) ? _FakeResolvedKeybinding() : null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeResolvedKeybinding extends keybindings.ResolvedKeybinding {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeContextKeyService implements contextkey.IContextKeyServiceType {
  FakeContextKeyService([bool Function(contextkey.ContextKeyExpression?)? matches])
      : _matches = matches;

  final bool Function(contextkey.ContextKeyExpression?)? _matches;
  final event.Emitter<contextkey.IContextKeyChangeEvent> _changes =
      event.Emitter<contextkey.IContextKeyChangeEvent>();

  void fireChange(contextkey.IContextKeyChangeEvent e) => _changes.fire(e);

  @override
  bool contextMatchesRules(contextkey.ContextKeyExpression? rules) =>
      rules == null || (_matches != null ? _matches!(rules) : true);

  @override
  Object get onDidChangeContext => _changes.event;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeChangeEvent implements contextkey.IContextKeyChangeEvent {
  FakeChangeEvent(this._keys);
  final Set<String> _keys;

  @override
  bool affectsSome(contextkey.IReadableSet<String> keys) =>
      _keys.any((String k) => keys.has(k));

  @override
  bool allKeysContainedIn(contextkey.IReadableSet<String> keys) =>
      _keys.every((String k) => keys.has(k));
}

// ---- helpers --------------------------------------------------------------

// Concrete carriers implementing the actions interfaces (the real TS source
// uses structural objects; these classes carry the same fields).
class _Cmd extends action.ICommandAction {
  _Cmd(String id, Object title, {Object? toggled, Object? precondition})
      : super(
          id: id,
          title: title,
          toggled: toggled,
          precondition: precondition as contextkey.ContextKeyExpression?,
        );
}

class _MI implements actions.IMenuItem {
  _MI(this.command,
      {this.alt, this.when, this.group, this.order, this.isHiddenByDefault});

  @override
  final action.ICommandAction command;
  @override
  final action.ICommandAction? alt;
  @override
  final contextkey.ContextKeyExpression? when;
  @override
  final String? group;
  @override
  final num? order;
  @override
  final bool? isHiddenByDefault;
}

class _SI implements actions.ISubmenuItem {
  _SI(this.submenu, this.title, {this.when, this.toggled, this.group});

  @override
  final actions.MenuId submenu;
  @override
  final Object title;
  @override
  final contextkey.ContextKeyExpression? when;
  @override
  final contextkey.ContextKeyExpression? toggled;
  @override
  final String? group;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

actions.IMenuItem item(String id, Object title,
        {String? group,
        num? order,
        bool? isHiddenByDefault,
        contextkey.ContextKeyExpression? when,
        action.ICommandAction? alt,
        Object? toggled,
        contextkey.ContextKeyExpression? precondition}) =>
    _MI(
      _Cmd(id, title, toggled: toggled, precondition: precondition),
      group: group,
      order: order,
      isHiddenByDefault: isHiddenByDefault,
      when: when,
      alt: alt,
    );

actions.ISubmenuItem subitem(actions.MenuId submenu, Object title,
        {String? group,
        contextkey.ContextKeyExpression? when,
        contextkey.ContextKeyExpression? toggled}) =>
    _SI(submenu, title, group: group, when: when, toggled: toggled);

class _GroupCarrier implements actions.IMenuGroup {
  _GroupCarrier(this.group, this.title);
  @override
  final String group;
  @override
  final String title;
}

final actions.MenuId mTruth = actions.MenuId('testo/truth');
final actions.MenuId mTruthSub = actions.MenuId('testo/truth/sub');
final actions.MenuId mTruthSub2 = actions.MenuId('testo/truth/sub2');
final actions.MenuId mSort = actions.MenuId('testo/sort');
final actions.MenuId mTitles = actions.MenuId('testo/titles');
final actions.MenuId mOrder = actions.MenuId('testo/order');
final actions.MenuId mLocalized = actions.MenuId('testo/localized');
final actions.MenuId mFilter = actions.MenuId('testo/filter');
final actions.MenuId mGroupTitle = actions.MenuId('testo/grouptitle');
final actions.MenuId mSubmenu = actions.MenuId('testo/submenu');
final actions.MenuId mKeys = actions.MenuId('testo/keys');
final actions.MenuId mEvents = actions.MenuId('testo/events');

final contextkey.ContextKeyExpression exWhenA = contextkey.ContextKeyExpr.has('a');
final contextkey.ContextKeyExpression exPreB = contextkey.ContextKeyExpr.has('b');
final contextkey.ContextKeyExpression exToggC = contextkey.ContextKeyExpr.has('c');

List<List<Object>> groupIds(menuService.ActionGroups groups) => groups
    .map((g) => <Object>[g.id, g.items.map((a) => a.id).toList()])
    .toList();

Map<String, Object?> hideState(actions.IMenuItemHide h) =>
    <String, Object?>{'hidden': h.isHidden, 'modified': h.isModifiedFromDefault};

List<Map<String, Object?>> storeValues(FakeStorage storage) => storage.storeLog
    .map((e) => <String, Object?>{
          'scope': e['scope'],
          'target': e['target'],
          'value': jsonDecode(e['value'] as String),
        })
    .toList();

menuService.MenuService newService(FakeStorage storage,
        {FakeCommandService? commands, FakeKeybindingService? keybindings}) =>
    menuService.MenuService(
      commands ?? FakeCommandService(),
      keybindings ?? FakeKeybindingService(),
      storage,
    );

void main() {
  setUpAll(() {
    // Register all registry fixtures once (MenuId is a unique global map).
    actions.MenuRegistry.appendMenuItems(<({actions.MenuId id, Object item})>[
      (id: mTruth, item: item('dhidden', 'Default Hidden', isHiddenByDefault: true)),
      (id: mTruth, item: item('visible', 'Visible')),
      (id: mTruthSub, item: item('s1', 'S1', when: exWhenA)),
      (id: mTruthSub, item: item('s2', 'S2', toggled: exToggC)),
    ]);
    actions.MenuRegistry.appendMenuGroup(mGroupTitle, _GroupCarrier('primary', 'Primary Title'));
    actions.MenuRegistry.appendMenuItem(mGroupTitle, item('a', 'A', group: 'primary'));

    actions.MenuRegistry.appendMenuItems(<({actions.MenuId id, Object item})>[
      (id: mSort, item: item('one', 'FOO', group: '0_hello')),
      (id: mSort, item: item('two', 'FOO', group: 'hello')),
      (id: mSort, item: item('three', 'FOO', group: 'Hello')),
      (id: mSort, item: item('four', 'FOO', group: '')),
      (id: mSort, item: item('five', 'FOO', group: 'navigation')),
      (id: mTitles, item: item('a', 'aaa', group: 'Hello')),
      (id: mTitles, item: item('b', 'fff', group: 'Hello')),
      (id: mTitles, item: item('c', 'zzz', group: 'Hello')),
      (id: mOrder, item: item('a', 'aaa', group: 'Hello', order: 10)),
      (id: mOrder, item: item('b', 'fff', group: 'Hello')),
      (id: mOrder, item: item('c', 'zzz', group: 'Hello', order: -1)),
      (id: mOrder, item: item('d', 'yyy', group: 'Hello', order: -1)),
      (id: mLocalized, item: item('a', action.ILocalizedString(value: 'ZZZ', original: 'AAA'), group: 'primary')),
      (id: mLocalized, item: item('b', 'BBB', group: 'primary')),
      (id: mLocalized, item: item('c', 'AAA', group: 'primary')),
      (id: mFilter, item: item('z', 'Z')),
      (id: mFilter, item: item('a', 'A')),
      (id: mFilter, item: item('gated', 'G', when: exWhenA)),
      (id: mSubmenu, item: subitem(mTruthSub, 'Sub', when: exWhenA, toggled: exToggC)),
      (id: mSubmenu, item: subitem(mTruthSub2, 'Empty')),
      (id: mKeys, item: item('k', 'K',
          when: exWhenA, precondition: exPreB,
          toggled: <Object, Object?>{'condition': exToggC})),
    ]);
  });

  test('default hide state / updateHidden / reset', () {
    final Map<String, dynamic> tr = _sec('defaultHidden');
    final FakeStorage storage = FakeStorage();
    final menuService.MenuService svc = newService(storage);
    final menuService.ActionGroups groups =
        svc.getMenuActions(mTruth, FakeContextKeyService());
    expect(groupIds(groups), tr['groups']);

    final baseActions.IAction dh = groups[0].items.firstWhere((a) => a.id == 'dhidden');
    final baseActions.IAction vis = groups[0].items.firstWhere((a) => a.id == 'visible');
    final actions.IMenuItemHide dhh = (dh as actions.MenuItemAction).hideActions!;
    final actions.IMenuItemHide vish = (vis as actions.MenuItemAction).hideActions!;

    expect(hideState(dhh), tr['dhInitial']);
    expect(hideState(vish), tr['visInitial']);

    vish.hide.run();
    expect(hideState(vish), tr['visAfterHide']);
    expect(storeValues(storage), tr['storeAfterHide']);
    vish.toggle.run();
    expect(hideState(vish), tr['visAfterToggleBack']);

    final Map<String, Object?> before = hideState(dhh);
    dhh.toggle.run();
    expect(<String, Object?>{'before': before, 'after': hideState(dhh)},
        tr['dhAfterToggle']);

    svc.resetHiddenStates();
    expect(<Object?>[hideState(dhh), hideState(vish)], tr['afterReset']['dh'] == null
        ? <Object?>[]
        : <Object?>[tr['afterReset']['dh'], tr['afterReset']['vis']]);
    expect(storage.storeLog.map((e) => jsonDecode(e['value'] as String)).toList(),
        tr['afterReset']['store']);
  });

  test('hidden state reloads on storage change event', () {
    final Map<String, dynamic> tr = _sec('storageChange');
    final FakeStorage storage = FakeStorage(jsonEncode(<String, Object?>{'testo/truth': <String>['visible']}));
    final menuService.MenuService svc = newService(storage);
    final menuService.ActionGroups groups =
        svc.getMenuActions(mTruth, FakeContextKeyService());
    final actions.IMenuItemHide vish =
        (groups[0].items.firstWhere((a) => a.id == 'visible') as actions.MenuItemAction).hideActions!;
    expect(hideState(vish), tr['before']);
    storage._raw = jsonEncode(<String, Object?>{'testo/truth': <String>[]});
    storage.fireChange();
    expect(hideState(vish), tr['after']);
  });

  test('group / title / order / localized sorting', () {
    final FakeContextKeyService ctx = FakeContextKeyService();
    final menuService.MenuService svc = newService(FakeStorage());
    expect(groupIds(svc.getMenuActions(mSort, ctx)), _list('groupSort'));
    expect(groupIds(svc.getMenuActions(mTitles, ctx)), _list('titleSort'));
    expect(groupIds(svc.getMenuActions(mOrder, ctx)), _list('orderSort'));
    expect(groupIds(svc.getMenuActions(mLocalized, ctx)), _list('localizedSort'));
  });

  test('filter before sort', () {
    final Map<String, dynamic> tr = _sec('filter');
    final menuService.MenuService svc = newService(FakeStorage());
    expect(groupIds(svc.getMenuActions(mFilter, FakeContextKeyService())), tr['all']);
    expect(
      groupIds(svc.getMenuActions(
          mFilter, FakeContextKeyService((e) => e != exWhenA))),
      tr['filtered'],
    );
  });

  test('group title injection', () {
    final Map<String, dynamic> tr = _sec('groupTitle');
    final menuService.MenuService svc = newService(FakeStorage());
    final menuService.ActionGroups groups =
        svc.getMenuActions(mGroupTitle, FakeContextKeyService());
    expect(groupIds(groups), tr['actions']);
    expect(groups.expand((g) => g.items).map((a) => (a as actions.MenuItemAction).groupTitle).toList(),
        tr['groupTitles']);
  });

  test('submenu recursion / empty omission / context keys', () async {
    final Map<String, dynamic> tr = _sec('submenu');
    final menuService.MenuService svc = newService(FakeStorage());
    final menuService.ActionGroups groups =
        svc.getMenuActions(mSubmenu, FakeContextKeyService());
    expect(groupIds(groups), tr['groups']);
    expect(svc.getMenuContexts(mSubmenu).toList()..sort(), tr['contexts']);

    final menuService.MenuImpl menu = svc.createMenu(
      mSubmenu,
      FakeContextKeyService(),
      menuService.MenuCreateOptions(emitEventsForSubmenuChanges: true, eventDebounceDelay: 5),
    );
    final List<Map<String, Object?>> events = <Map<String, Object?>>[];
    final lifecycle.IDisposable d = menu.onDidChange((dynamic e) {
      final actions.IMenuChangeEvent ce = e as actions.IMenuChangeEvent;
      events.add(<String, Object?>{
        's': ce.isStructuralChange,
        'en': ce.isEnablementChange,
        't': ce.isToggleChange,
      });
    });
    await Future<void>.delayed(const Duration(milliseconds: 150));
    actions.MenuRegistry.appendMenuItem(mTruthSub, item('s3', 'S3'));
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(events, tr['nestedRebuild']);
    d.dispose();
    menu.dispose();
  });

  test('context key collection', () {
    final menuService.MenuService svc = newService(FakeStorage());
    expect(svc.getMenuContexts(mKeys).toList()..sort(), _list('contextKeys'));
  });

  test('configure keybinding action', () {
    final Map<String, dynamic> tr = _sec('configureKeybinding');
    final FakeCommandService commands = FakeCommandService();
    final FakeKeybindingService kb = FakeKeybindingService();
    final baseActions.IAction act = menuService.createConfigureKeybindingAction(
      commands, kb, 'some.command', exWhenA);
    act.run();
    expect(act.id, tr['id']);
    expect(act.label, tr['label']);
    expect(commands.calls, tr['calls']);

    final FakeKeybindingService kb2 = FakeKeybindingService((id) => true);
    final baseActions.IAction act2 = menuService.createConfigureKeybindingAction(
      commands, kb2, 'bound.command', exWhenA);
    act2.run();
    expect(commands.calls, tr['boundCalls']);
  });

  test('context change events merge with debounce', () async {
    final Map<String, dynamic> tr = _sec('events');
    final FakeContextKeyService ctx = FakeContextKeyService();
    final menuService.MenuService svc = newService(FakeStorage());
    actions.MenuRegistry.appendMenuItem(mEvents, item('e', 'E',
        when: exWhenA, precondition: exPreB,
        toggled: <Object, Object?>{'condition': exToggC}));
    final menuService.MenuImpl menu = svc.createMenu(
      mEvents, ctx,
      menuService.MenuCreateOptions(eventDebounceDelay: 5),
    );
    final List<Map<String, Object?>> events = <Map<String, Object?>>[];
    final lifecycle.IDisposable d = menu.onDidChange((dynamic e) {
      final actions.IMenuChangeEvent ce = e as actions.IMenuChangeEvent;
      events.add(<String, Object?>{
        's': ce.isStructuralChange,
        'en': ce.isEnablementChange,
        't': ce.isToggleChange,
      });
    });
    await Future<void>.delayed(const Duration(milliseconds: 150));
    ctx.fireChange(FakeChangeEvent(<String>{'a'}));
    await Future<void>.delayed(const Duration(milliseconds: 150));
    ctx.fireChange(FakeChangeEvent(<String>{'b'}));
    ctx.fireChange(FakeChangeEvent(<String>{'c'}));
    ctx.fireChange(FakeChangeEvent(<String>{'a'}));
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(events, tr['merged']);

    d.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final List<Object?> events2 = <Object?>[];
    menu.onDidChange((dynamic e) => events2.add(e));
    ctx.fireChange(FakeChangeEvent(<String>{'a'}));
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(events2.length, tr['afterReListen']);
    menu.dispose();
  });
}
