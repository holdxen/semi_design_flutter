// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/config/tabFocus.ts
// Translated 1:1 from TypeScript. `TabFocusImpl extends Disposable` with an
// Emitter<boolean>; the `export const TabFocus` singleton -> top-level final.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable;

/// 1:1: `class TabFocusImpl extends Disposable`
class TabFocusImpl extends Disposable {
  bool _tabFocus = false;

  final Emitter<bool> _onDidChangeTabFocus = Emitter<bool>();
  late final Event<bool> onDidChangeTabFocus = _onDidChangeTabFocus.event;

  TabFocusImpl() : super() {
    // 1:1: `this._register(new Emitter<boolean>())`
    register(_onDidChangeTabFocus);
  }

  /// 1:1: `public getTabFocusMode(): boolean`
  bool getTabFocusMode() => _tabFocus;

  /// 1:1: `public setTabFocusMode(tabFocusMode: boolean): void`
  void setTabFocusMode(bool tabFocusMode) {
    _tabFocus = tabFocusMode;
    _onDidChangeTabFocus.fire(_tabFocus);
  }
}

/**
 * Control what pressing Tab does.
 * If it is false, pressing Tab or Shift-Tab will be handled by the editor.
 * If it is true, pressing Tab or Shift-Tab will move the browser focus.
 * Defaults to false.
 */
/// 1:1: `export const TabFocus = new TabFocusImpl();`
final TabFocusImpl TabFocus = TabFocusImpl();
