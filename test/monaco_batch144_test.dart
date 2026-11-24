import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/actions.dart'
    show IAction;
import 'package:semi_design_flutter/src/monaco/platform/action/common/action.dart'
    show ICommandAction;
import 'package:semi_design_flutter/src/monaco/platform/actions/common/actions.dart' as a;

final Map<String, Object?> _truth =
    json.decode(File('tool/ts2dart/batch144_truth.json').readAsStringSync())
        as Map<String, Object?>;

List<Object?> _list(Object? v) => (v as List).cast<Object>();

class _Cmd {
  _Cmd(this.id, this.title, [this.shortTitle]);
  final String id;
  final Object title;
  final Object? shortTitle;
}

class _Group implements a.IMenuGroup {
  _Group(this.group, this.title);
  @override
  final String group;
  @override
  final String title;
}

void main() {
  test('isIMenuItem / isISubmenuItem 1:1 truth', () {
    expect(a.isIMenuItem(<String, Object?>{'command': <String, Object?>{'id': 'x'}}),
        _truth['isIMenuItem_true']);
    expect(a.isIMenuItem(<String, Object?>{'submenu': <String, Object?>{}}),
        _truth['isIMenuItem_false']);
    expect(a.isIMenuItem(<String, Object?>{}), _truth['isIMenuItem_undefined']);
    expect(a.isISubmenuItem(<String, Object?>{'submenu': <String, Object?>{}}),
        _truth['isISubmenuItem_true']);
    expect(a.isISubmenuItem(<String, Object?>{'command': <String, Object?>{}}),
        _truth['isISubmenuItem_false']);
  });

  test('MenuId.for reuse / constructor / label 1:1 truth', () {
    final m1 = a.MenuId.forId('TestMenuXYZ');
    final m2 = a.MenuId.forId('TestMenuXYZ');
    expect(identical(m1, m2), _truth['menuId_reuse']);
    expect(m1.id, _truth['menuId_id']);
    expect(a.MenuId.CommandPalette.id, _truth['menuId_cp']);
    // duplicate constructor throws
    Object? caught;
    try {
      a.MenuId('TestMenuXYZ');
    } catch (e) {
      caught = e;
    }
    expect(caught, isNotNull);
    expect(caught.toString(), contains("already exists"));
  });

  test('MenuItemAction.label 1:1 truth', () {
    final cmdStr = _Cmd('a', 'Full Title');
    final cmdLoc = _Cmd(
        'b',
        <String, String>{'value': 'Localized', 'original': 'Orig'},
        <String, String>{'value': 'ShortLoc', 'original': 'ShortOrig'});
    // Build ICommandAction via dynamic cast of a Map-like carrier is not possible;
    // use a minimal class implementing the needed getters through a subclass.
    expect(a.MenuItemAction.labelStatic(_IA(cmdStr)), _truth['label_full']);
    expect(a.MenuItemAction.labelStatic(_IA(cmdLoc), _ShortOpts()),
        _truth['label_short']);
    expect(a.MenuItemAction.labelStatic(_IA(cmdLoc), _FullOpts()),
        _truth['label_noShort']);
    expect(a.MenuItemAction.labelStatic(_IA(_Cmd('c', 'T', 'S')), _ShortOpts()),
        _truth['label_stringShort']);
  });

  test('MenuRegistry commands / items / groups 1:1 truth', () {
    final r = a.MenuRegistry;
    final m1 = a.MenuId.forId('ItemsMenu');
    expect(r.getMenuItems(m1).length, _truth['items_empty']);

    final c1 = _IA(_Cmd('cmd.1', 'One'));
    final c2 = _IA(_Cmd('cmd.2', 'Two'));
    final dc1 = r.addCommand(c1);
    final dc2 = r.addCommand(c2);
    expect(r.getCommand('cmd.1'), isNotNull);
    expect(r.getCommand('nope'), isNull);
    expect(r.getCommands().length, _truth['getCommands_size']);

    r.appendMenuItem(m1, <String, Object?>{'command': c1});
    r.appendMenuItem(
        m1, <String, Object?>{'command': _IA(_Cmd('extra', 'Extra'))});
    final itemIds = r.getMenuItems(m1).map((e) {
      final cmd = (e as dynamic)['command'] as ICommandAction;
      return cmd.id;
    }).toList();
    expect(itemIds, _list(_truth['items_two']));

    // CommandPalette implicit
    final cp = a.MenuId.CommandPalette;
    r.appendMenuItem(cp, <String, Object?>{'command': c1});
    final cpIds = r.getMenuItems(cp).map((e) {
      final cmd = (e is Map) ? e['command'] as ICommandAction : (e as dynamic).command as ICommandAction;
      return cmd.id;
    }).toList();
    expect(cpIds, _list(_truth['cp_items']));

    // groups: latest first
    final gm = a.MenuId.forId('GroupMenu');
    expect(r.getMenuGroup(gm, 'nav'), isNull);
    r.appendMenuGroup(gm, _Group('nav', 'Navigation'));
    final found = r.getMenuGroup(gm, 'nav');
    expect(found?.title, (_truth['group_found'] as Map)['title']);
    r.appendMenuGroup(gm, _Group('nav', 'Newest'));
    expect(r.getMenuGroup(gm, 'nav')?.title,
        (_truth['group_latest'] as Map)['title']);

    dc1.dispose();
    dc2.dispose();
  });

  test('MenuRegistry onDidChangeMenu merge 1:1 truth', () async {
    final r = a.MenuRegistry;
    final e1 = a.MenuId.forId('EventMenu1');
    final e2 = a.MenuId.forId('EventMenu2');
    final observed = <a.IMenuRegistryChangeEvent>[];
    final sub = r.onDidChangeMenu((e) {
      observed.add(e);
    });
    final d1 = r.appendMenuItem(
        e1, <String, Object?>{'command': _IA(_Cmd('cmd.e1', 'E1'))});
    final d2 = r.appendMenuItem(
        e2, <String, Object?>{'command': _IA(_Cmd('cmd.e2', 'E2'))});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(observed.length, _truth['registry_events_count']);
    if (observed.isNotEmpty) {
      for (final ev in observed) {
        expect(ev.has(e1), (_list(_truth['registry_event_has_E1']))[0]);
        expect(ev.has(e2), (_list(_truth['registry_event_has_E2']))[0]);
        expect(ev.has(a.MenuId.forId('NeverChanged')),
            (_list(_truth['registry_event_has_other']))[0]);
      }
    }
    d1.dispose();
    d2.dispose();
    sub.dispose();
  });

  test('getMenuActionGroupTitle plain -> null 1:1 truth', () {
    expect(a.getMenuActionGroupTitle(_PlainAction()),
        _truth['groupTitle_plain']);
  });
}

// ---- helpers ----

ICommandAction _IA(_Cmd c) => ICommandAction(
      id: c.id,
      title: c.title,
      shortTitle: c.shortTitle,
    );

class _ShortOpts implements a.IMenuActionOptions {
  @override
  Object? get arg => null;
  @override
  List<Object?>? get args => null;
  @override
  bool? get shouldForwardArgs => null;
  @override
  bool get renderShortTitle => true;
}

class _FullOpts implements a.IMenuActionOptions {
  @override
  Object? get arg => null;
  @override
  List<Object?>? get args => null;
  @override
  bool? get shouldForwardArgs => null;
  @override
  bool get renderShortTitle => false;
}

class _PlainAction implements IAction {
  @override
  String get id => 'plain';
  @override
  String get label => 'plain';
  @override
  String? get cssClass => null;
  @override
  String get tooltip => '';
  @override
  bool get enabled => true;
  @override
  bool? get checked => null;
  @override
  IAction? get alt => null;
  @override
  Future<void> run([Object? event, Object? data]) async {}
}
