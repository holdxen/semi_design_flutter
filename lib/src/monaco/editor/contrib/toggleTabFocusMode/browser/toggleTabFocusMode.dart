// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/toggleTabFocusMode/browser/toggleTabFocusMode.ts
// Translated 1:1. Action2 subclass. Runtime truth:
// tool/ts2dart/_batch155_truth.cjs (real transpiled source, stubbed deps).
// ---------------------------------------------------------------------------

import 'dart:collection' show MapBase;

import '../../../../base/browser/ui/aria/aria.dart' show alert;
import '../../../../base/common/keyCodes.dart' show KeyCode, KeyMod;
import '../../../../nls.dart' show ILocalizeInfo, localize, localize2;
import '../../../../platform/action/common/action.dart' as action;
import '../../../../platform/actions/common/actions.dart'
    show Action2, registerAction2;
import '../../../../platform/commands/common/commands.dart'
    show ICommandMetadata;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServicesAccessor;
import '../../../../platform/keybinding/common/keybindingsRegistry.dart'
    show KeybindingWeight;
import '../../../browser/config/tabFocus.dart' show TabFocus;

/// Descriptor object literal passed to `super({...})` in the TS source.
/// Extends [action.ICommandAction] so `registerAction2`'s `f1` menu path can
/// register it directly (TS plain object is structurally ICommandAction).
class _ToggleTabFocusModeDesc extends action.ICommandAction {
  _ToggleTabFocusModeDesc()
      : super(
          id: ToggleTabFocusModeAction.ID,
          title: _buildTitle(),
          metadata: _buildMetadata(),
        );

  static action.ILocalizedString _buildTitle() {
    final nlsValue = localize2(
      ILocalizeInfo('toggle.tabMovesFocus', <String>[
        'Turn on/off use of tab key for moving focus around VS Code'
      ]),
      'Toggle Tab Key Moves Focus',
    );
    return action.ILocalizedString(
      value: nlsValue.value,
      original: nlsValue.original,
    );
  }

  static ICommandMetadata _buildMetadata() {
    return ICommandMetadata(
      description: localize2(
        'tabMovesFocusDescriptions',
        'Determines whether the tab key moves focus around the workbench or inserts the tab character in the current editor. This is also called tab trapping, tab navigation, or tab focus mode.',
      ),
    );
  }

  // Extra IAction2Options fields read by registerAction2 via dynamic access.
  // TS source leaves `menu` as undefined (absent key); Dart dynamic access
  // needs an explicit null getter to mirror JS `undefined`.
  Object? get menu => null;

  final Object keybinding = _KeybindingDesc();
  final bool f1 = true;
}

/// Keybinding object literal. Extends [MapBase] so `registerAction2`'s
/// `kb is Map` spread path works, while the `when` getter mirrors the absent
/// TS `when` key as `undefined` (Dart null) for dynamic access.
class _KeybindingDesc extends MapBase<String, Object?> {
  final Map<String, Object?> _data = <String, Object?>{
    'primary': KeyMod.CtrlCmd | KeyCode.KeyM,
    'mac': <String, Object?>{
      'primary': KeyMod.WinCtrl | KeyMod.Shift | KeyCode.KeyM,
    },
    'weight': KeybindingWeight.EditorContrib,
  };

  Object? get when => null;

  @override
  Object? operator [](Object? key) => _data[key];
  @override
  void operator []=(String key, Object? value) => _data[key] = value;
  @override
  Iterable<String> get keys => _data.keys;
  @override
  Object? remove(Object? key) => _data.remove(key);
  @override
  void clear() => _data.clear();
}

/// 1:1: `export class ToggleTabFocusModeAction extends Action2`.
class ToggleTabFocusModeAction extends Action2 {
  ToggleTabFocusModeAction() : super(_ToggleTabFocusModeDesc());

  /// 1:1: `public static readonly ID = 'editor.action.toggleTabFocusMode'`.
  static const String ID = 'editor.action.toggleTabFocusMode';

  /// 1:1: `public run(): void`.
  @override
  void run(ServicesAccessor accessor, [List<Object?> args = const <Object?>[]]) {
    final bool oldValue = TabFocus.getTabFocusMode();
    final bool newValue = !oldValue;
    TabFocus.setTabFocusMode(newValue);
    if (newValue) {
      alert(localize('toggle.tabMovesFocus.on',
          'Pressing Tab will now move focus to the next focusable element'));
    } else {
      alert(localize('toggle.tabMovesFocus.off',
          'Pressing Tab will now insert the tab character'));
    }
  }
}

/// 1:1: `registerAction2(ToggleTabFocusModeAction)` top-level side effect.
/// Dart top-level initializers are lazy, so registration is exposed via an
/// idempotent gate (same pattern used for other module-level side effects).
bool _registered = false;

void ensureRegistered() {
  if (_registered) return;
  _registered = true;
  registerAction2(() => ToggleTabFocusModeAction());
}
