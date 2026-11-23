// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/actions.ts
// Translated 1:1 from TypeScript.
// Adaptations (documented inline):
//   - `interface` -> `abstract class`; inline object types -> Dart record types
//     (`AltModeModifiers`) or carrier classes (`ActionProps`).
//   - property `class` -> `cssClass` (Dart reserved word).
//   - `Promise<void>` -> `Future<void>`; `unknown` -> `Object?`.
//   - rest `join(...actionLists)` -> `join(Iterable<List<IAction>> actionLists)`.
// ---------------------------------------------------------------------------

import 'dart:async';

import '../../nls.dart' as nls;
import 'event.dart' as event;
import 'lifecycle.dart' as lifecycle;
import 'platform.dart' as platform;

/// 1:1: `export interface ITelemetryData` (index signature omitted — no port
/// code reads arbitrary keys; use a `Map<String, Object?>` carrier if needed).
abstract class ITelemetryData {
  String? get from;
  String? get target;
}

/// 1:1: `export type WorkbenchActionExecutedClassification`
/// Type alias carries only metadata in TS; no runtime body.
typedef WorkbenchActionExecutedClassification = Object;

/// 1:1: `export type WorkbenchActionExecutedEvent`
class WorkbenchActionExecutedEvent {
  final String id;
  final String from;
  final String? detail;

  WorkbenchActionExecutedEvent(this.id, this.from, [this.detail]);
}

/// 1:1: `export interface IAction`
abstract class IAction {
  String get id;
  String get label;
  String get tooltip;

  /// 1:1: `class: string | undefined` (Dart keyword adaptation).
  String? get cssClass;

  bool get enabled;
  bool? get checked;

  /// Alternative action for this item.
  IAction? get alt;

  FutureOr<Object?> run([Object? event, Object? data]);
}

/// 1:1: inline `modifiers` type of `getActionForAltMode`.
typedef AltModeModifiers = ({bool? altKey, bool? shiftKey});

/// 1:1: `export function getActionForAltMode`
IAction getActionForAltMode(IAction action, AltModeModifiers modifiers) {
  final bool useAlternative = (modifiers.altKey ?? false) ||
      ((platform.isWindows || platform.isLinux) &&
          (modifiers.shiftKey ?? false));
  return useAlternative && action.enabled && action.alt?.enabled == true
      ? action.alt!
      : action;
}

/// 1:1: `export interface IActionRunner extends IDisposable`
abstract class IActionRunner implements lifecycle.IDisposable {
  event.Event<IRunEvent> get onDidRun;
  event.Event<IRunEvent> get onWillRun;

  Object? run(IAction action, [Object? context]);
}

/// 1:1: `export interface IActionChangeEvent`
class IActionChangeEvent {
  final String? label;
  final String? tooltip;
  final String? cssClass;
  final bool? enabled;
  final bool? checked;

  IActionChangeEvent({
    this.label,
    this.tooltip,
    this.cssClass,
    this.enabled,
    this.checked,
  });
}

/// 1:1: `export class Action extends Disposable implements IAction`
class Action extends lifecycle.Disposable implements IAction {
  late final event.Emitter<IActionChangeEvent> _onDidChange =
      register(event.Emitter<IActionChangeEvent>());

  event.Event<IActionChangeEvent> get onDidChange => _onDidChange.event;

  @override
  final String id;

  String _label;
  String? _tooltip;
  String? _cssClass;
  bool _enabled;
  bool? _checked;
  final FutureOr<void> Function(Object? event)? _actionCallback;

  Action(
    this.id, [
    String label = '',
    String cssClass = '',
    bool enabled = true,
    FutureOr<void> Function(Object? event)? actionCallback,
  ])   : _label = label,
        _cssClass = cssClass,
        _enabled = enabled,
        _actionCallback = actionCallback;

  @override
  String get label => _label;
  set label(String value) => _setLabel(value);

  void _setLabel(String value) {
    if (_label != value) {
      _label = value;
      _onDidChange.fire(IActionChangeEvent(label: value));
    }
  }

  @override
  String get tooltip => _tooltip ?? '';
  set tooltip(String value) => _setTooltip(value);

  void _setTooltip(String value) {
    if (_tooltip != value) {
      _tooltip = value;
      _onDidChange.fire(IActionChangeEvent(tooltip: value));
    }
  }

  @override
  String? get cssClass => _cssClass;
  set cssClass(String? value) => _setClass(value);

  void _setClass(String? value) {
    if (_cssClass != value) {
      _cssClass = value;
      _onDidChange.fire(IActionChangeEvent(cssClass: value));
    }
  }

  @override
  bool get enabled => _enabled;
  set enabled(bool value) => _setEnabled(value);

  void _setEnabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      _onDidChange.fire(IActionChangeEvent(enabled: value));
    }
  }

  @override
  bool? get checked => _checked;
  set checked(bool? value) => _setChecked(value);

  void _setChecked(bool? value) {
    if (_checked != value) {
      _checked = value;
      _onDidChange.fire(IActionChangeEvent(checked: value));
    }
  }

  @override
  IAction? get alt => null;

  @override
  Future<void> run([Object? event, Object? data]) async {
    final FutureOr<void> Function(Object? event)? callback = _actionCallback;
    if (callback != null) {
      await callback(event);
    }
  }
}

/// 1:1: `export interface IRunEvent`
class IRunEvent {
  final IAction action;

  /// TS `error?: Error` — Dart catch can carry any `Object`.
  final Object? error;

  IRunEvent(this.action, [this.error]);
}

/// 1:1: `export class ActionRunner extends Disposable implements IActionRunner`
class ActionRunner extends lifecycle.Disposable implements IActionRunner {
  late final event.Emitter<IRunEvent> _onWillRun =
      register(event.Emitter<IRunEvent>());

  @override
  event.Event<IRunEvent> get onWillRun => _onWillRun.event;

  late final event.Emitter<IRunEvent> _onDidRun =
      register(event.Emitter<IRunEvent>());

  @override
  event.Event<IRunEvent> get onDidRun => _onDidRun.event;

  @override
  Future<void> run(IAction action, [Object? context]) async {
    if (!action.enabled) {
      return;
    }

    _onWillRun.fire(IRunEvent(action));

    Object? error;
    try {
      await runAction(action, context);
    } catch (e) {
      error = e;
    }

    _onDidRun.fire(IRunEvent(action, error));
  }

  /// 1:1: `protected async runAction`
  Future<void> runAction(IAction action, [Object? context]) async {
    await action.run(context);
  }
}

/// 1:1: `export class Separator implements IAction`
class Separator implements IAction {
  static const String ID = 'vs.actions.separator';

  /// 1:1: `public static join(...actionLists: readonly IAction[][])`
  static List<IAction> join(Iterable<List<IAction>> actionLists) {
    List<IAction> out = <IAction>[];
    for (final List<IAction> list in actionLists) {
      if (list.isEmpty) {
        // skip
      } else if (out.isNotEmpty) {
        out = <IAction>[...out, Separator(), ...list];
      } else {
        out = list;
      }
    }
    return out;
  }

  /// 1:1: `public static clean(actions: IAction[]): IAction[]`
  static List<IAction> clean(List<IAction> actions) {
    while (actions.isNotEmpty && actions[0].id == Separator.ID) {
      actions.removeAt(0);
    }
    while (actions.isNotEmpty &&
        actions[actions.length - 1].id == Separator.ID) {
      actions.removeLast();
    }
    for (int i = actions.length - 2; i >= 0; i--) {
      if (actions[i].id == Separator.ID &&
          actions[i + 1].id == Separator.ID) {
        actions.removeAt(i + 1);
      }
    }
    return actions;
  }

  @override
  final String id = ID;
  @override
  final String tooltip = '';
  @override
  final String cssClass = 'separator';
  @override
  final bool enabled = false;
  @override
  final bool? checked;
  @override
  final IAction? alt = null;

  @override
  final String label;

  Separator([this.label = '', this.checked]);

  @override
  Future<void> run([Object? event, Object? data]) async {}
}

/// 1:1: `export class SubmenuAction implements IAction`
class SubmenuAction implements IAction {
  @override
  final String id;
  @override
  final String label;
  @override
  final String? cssClass;
  @override
  final String tooltip = '';
  @override
  final bool enabled = true;
  @override
  final bool? checked;
  @override
  final IAction? alt = null;

  final List<IAction> _actions;

  List<IAction> get actions => _actions;

  SubmenuAction(this.id, this.label, List<IAction> actions,
      [this.cssClass, this.checked])
      : _actions = actions;

  @override
  Future<void> run([Object? event, Object? data]) async {}
}

/// 1:1: `export class EmptySubmenuAction extends Action`
class EmptySubmenuAction extends Action {
  static const String ID = 'vs.actions.empty';

  EmptySubmenuAction()
      : super(ID, nls.localize('submenu.empty', '(empty)'), '', false);
}

/// 1:1: inline `props` type of `toAction`.
class ActionProps {
  final String id;
  final String label;
  final String? tooltip;
  final bool? enabled;
  final bool? checked;
  final String? cssClass;
  final IAction? alt;
  final Function run;

  ActionProps({
    required this.id,
    required this.label,
    this.tooltip,
    this.enabled,
    this.checked,
    this.cssClass,
    this.alt,
    required this.run,
  });
}

/// 1:1 carrier for `toAction`'s returned object literal.
class _ActionFromProps implements IAction {
  final ActionProps props;

  _ActionFromProps(this.props);

  @override
  String get id => props.id;

  @override
  String get label => props.label;

  @override
  String get tooltip => props.tooltip ?? props.label;

  @override
  String? get cssClass => props.cssClass;

  @override
  bool get enabled => props.enabled ?? true;

  @override
  bool? get checked => props.checked;

  @override
  IAction? get alt => props.alt;

  @override
  Object? run([Object? event, Object? data]) => Function.apply(props.run, [
        ?event,
        ?data,
      ]);
}

/// 1:1: `export function toAction`
IAction toAction(ActionProps props) => _ActionFromProps(props);
