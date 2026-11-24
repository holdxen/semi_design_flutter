// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/actions/common/menuService.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers / adaptations (mirrors sibling ports):
//   - TS `[string, T[]]` tuples -> `({String id, List<T> items})` records.
//   - `Event<void>.fire()` -> `fire(null)`.
//   - `String.localeCompare` -> `_jsLocaleCompare` (JS locale order: lower-case
//     letters sort before upper-case; otherwise code-unit order).
//   - `IMenuService`/`IMenuCreateOptions` in the pre-existing `actions.dart`
//     carry a slightly older signature; this file follows the source 1:1 and
//     therefore does not `implements` that earlier interface.
// ---------------------------------------------------------------------------

import 'dart:async' show FutureOr;
import 'dart:convert' as convert;

import '../../../base/common/actions.dart' as baseActions;
import '../../../base/common/arrays.dart' as arrays;
import '../../../base/common/async.dart' as async;
import '../../../base/common/event.dart' as event;
import '../../../base/common/iterator.dart' as iterator;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../nls.dart' as nls;
import '../../action/common/action.dart' as action;
import '../../commands/common/commands.dart' as commands;
import '../../contextkey/common/contextkey.dart' as contextkey;
import '../../keybinding/common/keybinding.dart' as keybinding;
import '../../storage/common/storage.dart' as storage;
import 'actions.dart' as actions;

/// 1:1: `type MenuItemGroup = [string, Array<IMenuItem | ISubmenuItem>]`.
typedef MenuItemGroup = ({String id, List<Object> items});

/// 1:1: `[string, Array<MenuItemAction | SubmenuItemAction>][]`.
typedef ActionGroups = List<({String id, List<baseActions.IAction> items})>;

/// 1:1: `interface IMenuCreateOptions`. The pre-existing `actions.IMenuCreateOptions`
/// declares `eventDebounceMs` as `bool?` (a historical transcription bug); the
/// source uses a numeric `eventDebounceDelay`, so this carrier follows the
/// source and reads either field name from arbitrary option objects.
class MenuCreateOptions {
  MenuCreateOptions({
    this.emitEventsForSubmenuChanges,
    int? eventDebounceDelay,
  }) : _eventDebounceDelay = eventDebounceDelay;

  final bool? emitEventsForSubmenuChanges;
  final int? _eventDebounceDelay;
}

int _asIntDelay(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return 50;
}

int _createOptionsDelay(Object? options) {
  if (options == null) return 50;
  if (options is MenuCreateOptions) {
    return options._eventDebounceDelay ?? 50;
  }
  final dynamic d = options;
  try {
    final Object? delay = d.eventDebounceDelay ?? d.eventDebounceMs;
    if (delay != null) return _asIntDelay(delay);
  } catch (_) {}
  return 50;
}

bool _createOptionsEmitSubmenus(Object? options) {
  if (options is MenuCreateOptions) {
    return options.emitEventsForSubmenuChanges ?? false;
  }
  if (options == null) return false;
  final dynamic d = options;
  try {
    return d.emitEventsForSubmenuChanges as bool? ?? false;
  } catch (_) {
    return false;
  }
}

/// JS `String.prototype.localeCompare` ordering for the ASCII identifiers used
/// by menu groups/titles: case-insensitive code-unit compare first, then
/// lower-case before upper-case on folded-equal characters.
int _jsLocaleCompare(String a, String b) {
  if (a == b) return 0;
  final int folded = a.toLowerCase().compareTo(b.toLowerCase());
  if (folded != 0) return folded < 0 ? -1 : 1;
  final int n = a.length < b.length ? a.length : b.length;
  for (int i = 0; i < n; i++) {
    final int ca = a.codeUnitAt(i);
    final int cb = b.codeUnitAt(i);
    if (ca == cb) continue;
    final bool aLower = ca >= 0x61 && ca <= 0x7A;
    final bool bLower = cb >= 0x61 && cb <= 0x7A;
    if (aLower != bLower) return aLower ? -1 : 1;
    return ca < cb ? -1 : 1;
  }
  return a.length.compareTo(b.length);
}

Object? _field(Object item, String name) {
  if (item is Map) return item[name];
  final dynamic d = item;
  try {
    switch (name) {
      case 'command':
        return d.command;
      case 'alt':
        return d.alt;
      case 'when':
        return d.when;
      case 'group':
        return d.group;
      case 'order':
        return d.order;
      case 'isHiddenByDefault':
        return d.isHiddenByDefault;
      case 'submenu':
        return d.submenu;
      case 'title':
        return d.title;
      case 'toggled':
        return d.toggled;
      case 'id':
        return d.id;
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

String _titleValue(Object title) => title is String
    ? title
    : (title is action.ILocalizedString
        ? title.value
        : (title is Map ? (title['value'] as String? ?? '') : ''));

// ---------------------------------------------------------------------------
// PersistedMenuHideState
// ---------------------------------------------------------------------------

/// 1:1: `class PersistedMenuHideState implements IDisposable` (private to the
/// source module; exposed here so the truth tests can drive it).
class PersistedMenuHideState implements lifecycle.IDisposable {
  static const String _key = 'menu.hiddenCommands';

  final lifecycle.DisposableStore _disposables = lifecycle.DisposableStore();
  final event.Emitter<void> _onDidChange = event.Emitter<void>();
  late final event.Event<void> onDidChange;

  bool _ignoreChangeEvent = false;
  Map<String, List<String>> _data = <String, List<String>>{};
  final Map<String, bool> _hiddenByDefaultCache = <String, bool>{};

  PersistedMenuHideState(this._storageService) {
    onDidChange = _onDidChange.event;
    try {
      final String raw = _storageService.get(_key, storage.StorageScope.PROFILE, '{}') ?? '{}';
      final Object? parsed = convert.jsonDecode(raw);
      _data = parsed is Map
          ? parsed.map<String, List<String>>((Object? k, Object? v) => MapEntry<String, List<String>>(
                k.toString(),
                v is List ? v.map((Object? e) => e.toString()).toList() : <String>[],
              ))
          : <String, List<String>>{};
    } catch (_) {
      _data = <String, List<String>>{};
    }

    _disposables.add(_storageService.onDidChangeValue(
      storage.StorageScope.PROFILE,
      _key,
      _disposables,
    )((dynamic e) {
      if (!_ignoreChangeEvent) {
        try {
          final String raw = _storageService.get(_key, storage.StorageScope.PROFILE, '{}') ?? '{}';
          final Object? parsed = convert.jsonDecode(raw);
          _data = parsed is Map
              ? parsed.map<String, List<String>>((Object? k, Object? v) => MapEntry<String, List<String>>(
                    k.toString(),
                    v is List ? v.map((Object? e) => e.toString()).toList() : <String>[],
                  ))
              : <String, List<String>>{};
        } catch (err) {
          nls.localize; // keep nls import live (source uses console.log here)
        }
      }
      _onDidChange.fire(null);
    }));
  }

  final storage.IStorageServiceType _storageService;

  @override
  void dispose() {
    _onDidChange.dispose();
    _disposables.dispose();
  }

  bool isModifiedFromDefault(actions.MenuId menu, String commandId) =>
      isHidden(menu, commandId) != _isHiddenByDefault(menu, commandId);

  bool _isHiddenByDefault(actions.MenuId menu, String commandId) =>
      _hiddenByDefaultCache['${menu.id}/$commandId'] ?? false;

  void setDefaultState(actions.MenuId menu, String commandId, bool hidden) {
    final String key = '${menu.id}/$commandId';
    if (hidden) {
      _hiddenByDefaultCache[key] = true;
    } else {
      _hiddenByDefaultCache.remove(key);
    }
  }

  bool isHidden(actions.MenuId menu, String commandId) {
    final bool hiddenByDefault = _isHiddenByDefault(menu, commandId);
    final bool state = _data[menu.id]?.contains(commandId) ?? false;
    return hiddenByDefault ? !state : state;
  }

  void updateHidden(actions.MenuId menu, String commandId, bool hidden) {
    bool effective = hidden;
    final bool hiddenByDefault = _isHiddenByDefault(menu, commandId);
    if (hiddenByDefault) {
      effective = !effective;
    }
    final List<String>? entries = _data[menu.id];
    if (!effective) {
      if (entries != null) {
        final int idx = entries.indexOf(commandId);
        if (idx >= 0) {
          arrays.removeFastWithoutKeepingOrder(entries, idx);
        }
        if (entries.isEmpty) {
          _data.remove(menu.id);
        }
      }
    } else {
      if (entries == null) {
        _data[menu.id] = <String>[commandId];
      } else {
        final int idx = entries.indexOf(commandId);
        if (idx < 0) {
          entries.add(commandId);
        }
      }
    }
    _persist();
  }

  void reset([List<actions.MenuId>? menus]) {
    if (menus == null) {
      _data = <String, List<String>>{};
      _persist();
    } else {
      for (final actions.MenuId menu in menus) {
        _data.remove(menu.id);
      }
      _persist();
    }
  }

  void _persist() {
    try {
      _ignoreChangeEvent = true;
      final String raw = convert.jsonEncode(_data);
      _storageService.store(_key, raw, storage.StorageScope.PROFILE,
          storage.StorageTarget.USER);
    } finally {
      _ignoreChangeEvent = false;
    }
  }
}

// ---------------------------------------------------------------------------
// MenuService
// ---------------------------------------------------------------------------

/// 1:1: `export class MenuService extends Disposable implements IMenuService`.
class MenuService extends lifecycle.Disposable {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  late final PersistedMenuHideState _hiddenStates;

  MenuService(
    this._commandService,
    this._keybindingService,
    storage.IStorageServiceType storageService,
  ) {
    _hiddenStates = register(PersistedMenuHideState(storageService));
  }

  final commands.ICommandServiceType _commandService;
  final keybinding.IKeybindingServiceType _keybindingService;

  MenuImpl createMenu(
    actions.MenuId id,
    contextkey.IContextKeyServiceType contextKeyService, [
    Object? options,
  ]) {
    return MenuImpl(
      id,
      _hiddenStates,
      <Object>[
        _createOptionsEmitSubmenus(options),
        _createOptionsDelay(options),
      ],
      _commandService,
      _keybindingService,
      contextKeyService,
    );
  }

  ActionGroups getMenuActions(
    actions.MenuId id,
    contextkey.IContextKeyServiceType contextKeyService, [
    actions.IMenuActionOptions? options,
  ]) {
    return createMenuActionGroups(
      id, options, _hiddenStates, _commandService, _keybindingService, contextKeyService);
  }

  Set<String> getMenuContexts(actions.MenuId id) {
    final MenuInfoSnapshot menuInfo = MenuInfoSnapshot(id, false);
    return <String>{
      ...menuInfo.structureContextKeys,
      ...menuInfo.preconditionContextKeys,
      ...menuInfo.toggledContextKeys,
    };
  }

  void resetHiddenStates([List<actions.MenuId>? ids]) => _hiddenStates.reset(ids);
}

// ---------------------------------------------------------------------------
// Grouping / action creation
// ---------------------------------------------------------------------------

/// 1:1: `function groupMenuItems(...)`.
List<MenuItemGroup> groupMenuItems(List<Object> menuItems) {
  final List<MenuItemGroup> result = <MenuItemGroup>[];
  for (final List<Object> items in arrays.groupAdjacentBy<Object>(
    menuItems,
    (Object a, Object b) =>
        (_field(a, 'group') as String? ?? '') == (_field(b, 'group') as String? ?? ''),
  )) {
    result.add((id: _field(items[0], 'group') as String? ?? '', items: items));
  }
  return result;
}

/// 1:1: `function createMenuActionGroups(...)`.
ActionGroups createMenuActionGroups(
  actions.MenuId id,
  Object? options,
  PersistedMenuHideState hiddenStates,
  commands.ICommandServiceType commandService,
  keybinding.IKeybindingServiceType keybindingService,
  contextkey.IContextKeyServiceType contextKeyService,
) {
  final List<Object> menuItems = actions.MenuRegistry.getMenuItems(id)
      .where((Object item) => contextKeyService.contextMatchesRules(
          _field(item, 'when') as contextkey.ContextKeyExpression?))
      .toList();
  menuItems.sort(MenuInfo.compareMenuItems);
  return buildActionGroups(
    id, groupMenuItems(menuItems), options, hiddenStates, commandService,
    keybindingService, contextKeyService);
}

/// 1:1: `function createActionGroups(...)` (renamed to avoid method shadowing).
ActionGroups buildActionGroups(
  actions.MenuId menuId,
  Iterable<MenuItemGroup> menuGroups,
  Object? options,
  PersistedMenuHideState hiddenStates,
  commands.ICommandServiceType commandService,
  keybinding.IKeybindingServiceType keybindingService,
  contextkey.IContextKeyServiceType contextKeyService,
) {
  final ActionGroups result = <({String id, List<baseActions.IAction> items})>[];

  for (final MenuItemGroup group in menuGroups) {
    final String id = group.id;
    final String? groupTitle =
        actions.MenuRegistry.getMenuGroup(menuId, id)?.title;
    final actions.IMenuItemActionOptions? actionOptions = groupTitle != null
        ? _MenuItemActionOptionsCarrier(options, groupTitle)
        : (options is actions.IMenuItemActionOptions ? options : null);
    final List<baseActions.IAction> activeActions = <baseActions.IAction>[];

    for (final Object item in group.items) {
      final bool isMenuItem = actions.isIMenuItem(item);
      if (isMenuItem) {
        final Object? command = _field(item, 'command');
        hiddenStates.setDefaultState(
          menuId,
          (command as action.ICommandAction).id,
          _field(item, 'isHiddenByDefault') as bool? ?? false,
        );
      }

      final Object hideCommand = isMenuItem ? _field(item, 'command')! : item;
      final actions.IMenuItemHide menuHide =
          createMenuHide(menuId, hideCommand, hiddenStates);
      if (isMenuItem) {
        final Object? command = _field(item, 'command');
        final baseActions.IAction menuKeybinding = createConfigureKeybindingAction(
          commandService,
          keybindingService,
          (command as action.ICommandAction).id,
          _field(item, 'when') as contextkey.ContextKeyExpression?,
        );
        activeActions.add(actions.MenuItemAction(
          command,
          _field(item, 'alt') as action.ICommandAction?,
          actionOptions,
          menuHide,
          menuKeybinding,
          contextKeyService,
          commandService,
        ));
      } else {
        final actions.MenuId submenu = _field(item, 'submenu') as actions.MenuId;
        final ActionGroups groups = createMenuActionGroups(
          submenu, options, hiddenStates, commandService, keybindingService,
          contextKeyService);
        final List<baseActions.IAction> submenuActions =
            baseActions.Separator.join(groups.map((g) => g.items));
        if (submenuActions.isNotEmpty) {
          final Object? toggled = _field(item, 'toggled');
          activeActions.add(actions.SubmenuItemAction(
            item as actions.ISubmenuItem,
            menuHide,
            submenuActions,
            toggled != null
                ? contextKeyService.contextMatchesRules(
                    toggled as contextkey.ContextKeyExpression?)
                : null,
            groupTitle,
          ));
        }
      }
    }
    if (activeActions.isNotEmpty) {
      result.add((id: id, items: activeActions));
    }
  }
  return result;
}

class _MenuItemActionOptionsCarrier implements actions.IMenuItemActionOptions {
  _MenuItemActionOptionsCarrier(this._base, this.groupTitle);

  final Object? _base;
  @override
  final String? groupTitle;

  dynamic get _d => _base;
  @override
  Object? get arg { try { return _d?.arg; } catch (_) { return null; } }
  @override
  List<Object?>? get args { try { return _d?.args as List<Object?>?; } catch (_) { return null; } }
  @override
  bool? get shouldForwardArgs { try { return _d?.shouldForwardArgs as bool?; } catch (_) { return null; } }
  @override
  bool? get renderShortTitle { try { return _d?.renderShortTitle as bool?; } catch (_) { return null; } }
}

// ---------------------------------------------------------------------------
// MenuInfoSnapshot / MenuInfo
// ---------------------------------------------------------------------------

/// 1:1: `class MenuInfoSnapshot`.
class MenuInfoSnapshot {
  List<MenuItemGroup> _menuGroups = <MenuItemGroup>[];
  final Set<actions.MenuId> _allMenuIds = <actions.MenuId>{};
  final Set<String> _structureContextKeys = <String>{};
  final Set<String> _preconditionContextKeys = <String>{};
  final Set<String> _toggledContextKeys = <String>{};

  MenuInfoSnapshot(this._id, this._collectContextKeysForSubmenus) {
    refresh();
  }

  final actions.MenuId _id;
  final bool _collectContextKeysForSubmenus;

  Set<actions.MenuId> get allMenuIds => _allMenuIds;
  Set<String> get structureContextKeys => _structureContextKeys;
  Set<String> get preconditionContextKeys => _preconditionContextKeys;
  Set<String> get toggledContextKeys => _toggledContextKeys;
  List<MenuItemGroup> get menuGroups => _menuGroups;

  void refresh() {
    _allMenuIds.clear();
    _structureContextKeys.clear();
    _preconditionContextKeys.clear();
    _toggledContextKeys.clear();

    final List<Object> menuItems = _sort(actions.MenuRegistry.getMenuItems(_id));
    _menuGroups = groupMenuItems(menuItems);
    for (final Object item in menuItems) {
      _collectContextKeysAndSubmenuIds(item);
    }
    _allMenuIds.add(_id);
  }

  List<Object> _sort(List<Object> menuItems) => menuItems;

  void _collectContextKeysAndSubmenuIds(Object item) {
    _fillInKbExprKeys(_field(item, 'when') as contextkey.ContextKeyExpression?,
        _structureContextKeys);

    if (actions.isIMenuItem(item)) {
      final action.ICommandAction? command = _field(item, 'command') as action.ICommandAction?;
      final Object? precondition = command?.precondition;
      if (precondition != null) {
        _fillInKbExprKeys(precondition as contextkey.ContextKeyExpression?,
            _preconditionContextKeys);
      }
      final Object? toggled = command?.toggled;
      if (toggled != null) {
        final Object? toggledExpression = _toggledCondition(toggled);
        _fillInKbExprKeys(toggledExpression as contextkey.ContextKeyExpression?,
            _toggledContextKeys);
      }
    } else {
      _fillInKbExprKeys(_field(item, 'toggled') as contextkey.ContextKeyExpression?,
          _toggledContextKeys);
      if (_collectContextKeysForSubmenus) {
        final actions.MenuId submenu = _field(item, 'submenu') as actions.MenuId;
        for (final Object child in actions.MenuRegistry.getMenuItems(submenu)) {
          _collectContextKeysAndSubmenuIds(child);
        }
        _allMenuIds.add(submenu);
      }
    }
  }

  static void _fillInKbExprKeys(
      contextkey.ContextKeyExpression? exp, Set<String> set) {
    if (exp != null) {
      for (final String key in exp.keys()) {
        set.add(key);
      }
    }
  }
}

Object? _toggledCondition(Object toggled) {
  Object? condition;
  if (toggled is Map) {
    condition = toggled['condition'];
  } else {
    final dynamic d = toggled;
    try {
      condition = d.condition;
    } catch (_) {}
  }
  return condition ?? toggled;
}

/// 1:1: `class MenuInfo extends MenuInfoSnapshot`.
class MenuInfo extends MenuInfoSnapshot {
  MenuInfo(
    super._id,
    this._hiddenStates,
    super._collectContextKeysForSubmenus,
    this._commandService,
    this._keybindingService,
    this._contextKeyService,
  );

  final PersistedMenuHideState _hiddenStates;
  final commands.ICommandServiceType _commandService;
  final keybinding.IKeybindingServiceType _keybindingService;
  final contextkey.IContextKeyServiceType _contextKeyService;

  ActionGroups createActionGroups([Object? options]) {
    final Iterable<MenuItemGroup> groups = iterator.IterableX.map(
      _menuGroups,
      (MenuItemGroup g, int index) => (
        id: g.id,
        items: g.items
            .where((Object item) => _contextKeyService.contextMatchesRules(
                _field(item, 'when') as contextkey.ContextKeyExpression?))
            .toList(),
      ),
    );
    return buildActionGroups(
      _id, groups, options, _hiddenStates, _commandService, _keybindingService,
      _contextKeyService);
  }

  @override
  List<Object> _sort(List<Object> menuItems) {
    menuItems.sort(compareMenuItems);
    return menuItems;
  }

  /// 1:1: `static compareMenuItems(a, b)`.
  static int compareMenuItems(Object a, Object b) {
    final String aGroup = _field(a, 'group') as String? ?? '';
    final String bGroup = _field(b, 'group') as String? ?? '';

    if (aGroup != bGroup) {
      if (aGroup.isEmpty) return 1;
      if (bGroup.isEmpty) return -1;
      if (aGroup == 'navigation') return -1;
      if (bGroup == 'navigation') return 1;
      final int value = _jsLocaleCompare(aGroup, bGroup);
      if (value != 0) return value;
    }

    final num aPrio = (_field(a, 'order') as num?) ?? 0;
    final num bPrio = (_field(b, 'order') as num?) ?? 0;
    if (aPrio < bPrio) return -1;
    if (aPrio > bPrio) return 1;

    return _compareTitles(
      actions.isIMenuItem(a)
          ? (_field(a, 'command') as action.ICommandAction).title
          : _field(a, 'title') ?? '',
      actions.isIMenuItem(b)
          ? (_field(b, 'command') as action.ICommandAction).title
          : _field(b, 'title') ?? '',
    );
  }

  static int _compareTitles(Object a, Object b) {
    final String aStr = a is String
        ? a
        : (a is action.ILocalizedString
            ? a.original
            : (a is Map ? (a['original'] as String? ?? '') : ''));
    final String bStr = b is String
        ? b
        : (b is action.ILocalizedString
            ? b.original
            : (b is Map ? (b['original'] as String? ?? '') : ''));
    return _jsLocaleCompare(aStr, bStr);
  }
}

// ---------------------------------------------------------------------------
// MenuImpl
// ---------------------------------------------------------------------------

/// 1:1: `class MenuImpl implements IMenu`. `getActions` returns the source's
/// `[string, actions][]` shape (ActionGroups) directly; the pre-existing
/// `IMenu` interface types this as `List<List<Object>>`, so this class does not
/// formally implement that earlier interface.
class MenuImpl implements actions.IMenu {
  late final MenuInfo _menuInfo;
  final lifecycle.DisposableStore _disposables = lifecycle.DisposableStore();

  late final event.Emitter<actions.IMenuChangeEvent> _onDidChange;
  @override
  late final event.Event<actions.IMenuChangeEvent> onDidChange;

  MenuImpl(
    actions.MenuId id,
    PersistedMenuHideState hiddenStates,
    List<Object> options,
    commands.ICommandServiceType commandService,
    keybinding.IKeybindingServiceType keybindingService,
    contextkey.IContextKeyServiceType contextKeyService,
  ) {
    final bool emitSubmenus = options[0] as bool;
    final int delay = options[1] as int;
    _menuInfo = MenuInfo(id, hiddenStates, emitSubmenus, commandService,
        keybindingService, contextKeyService);

    final async.RunOnceScheduler rebuildMenuSoon = async.RunOnceScheduler(() {
      _menuInfo.refresh();
      _onDidChange.fire(_MenuChangeEventCarrier(
        this,
        isStructuralChange: true,
        isEnablementChange: true,
        isToggleChange: true,
      ));
    }, delay);
    _disposables.add(rebuildMenuSoon);
    _disposables.add(actions.MenuRegistry.onDidChangeMenu((dynamic e) {
      for (final actions.MenuId id in _menuInfo.allMenuIds) {
        if ((e as actions.IMenuRegistryChangeEvent).has(id)) {
          rebuildMenuSoon.schedule();
          break;
        }
      }
    }));

    final lifecycle.DisposableStore lazyListener =
        _disposables.add(lifecycle.DisposableStore());

    actions.IMenuChangeEvent merge(List<actions.IMenuChangeEvent> events) {
      bool isStructuralChange = false;
      bool isEnablementChange = false;
      bool isToggleChange = false;
      for (final actions.IMenuChangeEvent item in events) {
        isStructuralChange = isStructuralChange || item.isStructuralChange;
        isEnablementChange = isEnablementChange || item.isEnablementChange;
        isToggleChange = isToggleChange || item.isToggleChange;
        if (isStructuralChange && isEnablementChange && isToggleChange) break;
      }
      return _MenuChangeEventCarrier(
        this,
        isStructuralChange: isStructuralChange,
        isEnablementChange: isEnablementChange,
        isToggleChange: isToggleChange,
      );
    }

    void startLazyListener() {
      lazyListener.add((contextKeyService.onDidChangeContext as dynamic)((dynamic e) {
        final contextkey.IContextKeyChangeEvent change = e as contextkey.IContextKeyChangeEvent;
        final bool isStructuralChange =
            change.affectsSome(_ReadableSetAdapter(_menuInfo.structureContextKeys));
        final bool isEnablementChange =
            change.affectsSome(_ReadableSetAdapter(_menuInfo.preconditionContextKeys));
        final bool isToggleChange =
            change.affectsSome(_ReadableSetAdapter(_menuInfo.toggledContextKeys));
        if (isStructuralChange || isEnablementChange || isToggleChange) {
          _onDidChange.fire(_MenuChangeEventCarrier(
            this,
            isStructuralChange: isStructuralChange,
            isEnablementChange: isEnablementChange,
            isToggleChange: isToggleChange,
          ));
        }
      }));
      lazyListener.add(hiddenStates.onDidChange((dynamic e) {
        _onDidChange.fire(_MenuChangeEventCarrier(
          this,
          isStructuralChange: true,
          isEnablementChange: false,
          isToggleChange: false,
        ));
      }));
    }

    final event.EmitterOptionsWithMerge<actions.IMenuChangeEvent> opts =
        event.EmitterOptionsWithMerge<actions.IMenuChangeEvent>(merge);
    opts.onWillAddFirstListener = startLazyListener;
    opts.onDidRemoveLastListener = lazyListener.clear;
    _onDidChange = event.DebounceEmitter<actions.IMenuChangeEvent>(opts);
    onDidChange = _onDidChange.event;
  }

  /// 1:1: `getActions(options)` returns `[group, actions][]` as a Dart
  /// `List<List<Object>>` to satisfy the pre-existing `IMenu` interface.
  @override
  List<List<Object>> getActions([actions.IMenuActionOptions? options]) {
    return getActionGroups(options)
        .map((g) => <Object>[g.id, g.items])
        .toList();
  }

  /// Typed access to `getActions`' `[group, actions][]` result (truth tests).
  ActionGroups getActionGroups([Object? options]) =>
      _menuInfo.createActionGroups(options);

  @override
  void dispose() {
    _disposables.dispose();
    _onDidChange.dispose();
  }
}

class _MenuChangeEventCarrier implements actions.IMenuChangeEvent {
  _MenuChangeEventCarrier(
    this.menu, {
    required this.isStructuralChange,
    required this.isEnablementChange,
    required this.isToggleChange,
  });

  @override
  final actions.IMenu menu;
  @override
  final bool isStructuralChange;
  @override
  final bool isEnablementChange;
  @override
  final bool isToggleChange;
}

// ---------------------------------------------------------------------------
// createMenuHide / createConfigureKeybindingAction
// ---------------------------------------------------------------------------

/// 1:1: `function createMenuHide(menu, command, states): IMenuItemHide`.
actions.IMenuItemHide createMenuHide(
  actions.MenuId menu,
  Object command,
  PersistedMenuHideState states,
) {
  // source: `const id = isISubmenuItem(command) ? command.submenu.id : command.id`
  final String id = actions.isISubmenuItem(command)
      ? (command as actions.ISubmenuItem).submenu.id
      : (command as action.ICommandAction).id;
  final String title = _titleValue(_field(command, 'title') ?? '');

  final baseActions.IAction hide = _CallbackAction(
    id: 'hide/${menu.id}/$id',
    label: nls.localize('hide.label', "Hide '{0}'", <Object>[title]),
    checkedGetter: () => null,
    runFn: () {
      states.updateHidden(menu, id, true);
      return null;
    },
  );

  // `toggle` is referenced inside its own `run` (as in the source); declare the
  // checked/run closures through a late holder to preserve that.
  late final _CallbackAction toggle;
  toggle = _CallbackAction(
    id: 'toggle/${menu.id}/$id',
    label: title,
    checkedGetter: () => !states.isHidden(menu, id),
    runFn: () {
      states.updateHidden(menu, id, toggle.checked ?? false);
      return null;
    },
  );

  return _MenuItemHideCarrier(
    hide: hide,
    toggle: toggle,
    isHiddenGetter: () => !(toggle.checked ?? false),
    isModifiedFromDefaultGetter: () => states.isModifiedFromDefault(menu, id),
  );
}

/// Generic IAction backed by closures (source `toAction` object literal with
/// dynamic `get checked()` / `run()`).
class _CallbackAction implements baseActions.IAction {
  _CallbackAction({
    required this.id,
    required this.label,
    required bool? Function() checkedGetter,
    required Object? Function() runFn,
  })  : _checkedGetter = checkedGetter,
        _runFn = runFn;

  @override
  final String id;
  @override
  final String label;
  @override
  String get tooltip => label;
  @override
  String? get cssClass => null;
  @override
  bool get enabled => true;
  @override
  baseActions.IAction? get alt => null;
  @override
  bool? get checked => _checkedGetter();
  @override
  FutureOr<Object?> run([Object? event, Object? data]) => _runFn();

  final bool? Function() _checkedGetter;
  final Object? Function() _runFn;
}

class _MenuItemHideCarrier implements actions.IMenuItemHide {
  _MenuItemHideCarrier({
    required this.hide,
    required this.toggle,
    required bool Function() isHiddenGetter,
    required bool Function() isModifiedFromDefaultGetter,
  })  : _isHiddenGetter = isHiddenGetter,
        _isModifiedFromDefaultGetter = isModifiedFromDefaultGetter;

  @override
  final baseActions.IAction hide;
  @override
  final baseActions.IAction toggle;
  @override
  bool get isHidden => _isHiddenGetter();
  @override
  bool get isModifiedFromDefault => _isModifiedFromDefaultGetter();

  final bool Function() _isHiddenGetter;
  final bool Function() _isModifiedFromDefaultGetter;
}

class _ReadableSetAdapter implements contextkey.IReadableSet<String> {
  _ReadableSetAdapter(this._set);
  final Set<String> _set;
  @override
  bool has(String value) => _set.contains(value);
}

/// 1:1: `export function createConfigureKeybindingAction(...)`.
baseActions.IAction createConfigureKeybindingAction(
  commands.ICommandServiceType commandService,
  keybinding.IKeybindingServiceType keybindingService,
  String commandId, [
  contextkey.ContextKeyExpression? when,
  bool enabled = true,
]) {
  return baseActions.toAction(baseActions.ActionProps(
    id: 'configureKeybinding/$commandId',
    label: nls.localize('configure keybinding', 'Configure Keybinding'),
    enabled: enabled,
    run: () {
      final bool hasKeybinding =
          keybindingService.lookupKeybinding(commandId) != null;
      final String? whenValue = !hasKeybinding && when != null
          ? when.serialize()
          : null;
      commandService.executeCommand(
        'workbench.action.openGlobalKeybindings',
        <Object?>[
          '@command:$commandId${whenValue != null ? ' +when:$whenValue' : ''}'
        ],
      );
    },
  ));
}
