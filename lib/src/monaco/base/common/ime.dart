// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/ime.ts
// Translated 1:1 from TypeScript. `Emitter<void>.fire()` -> `fire(null)`
// per the port's Emitter convention.
// ---------------------------------------------------------------------------

import './event.dart' show Emitter, Event;

/// 1:1: `export class IMEImpl`
class IMEImpl {
  final Emitter<void> _onDidChange = Emitter<void>();

  late final Event<void> onDidChange;

  bool _enabled = true;

  IMEImpl() {
    onDidChange = _onDidChange.event;
  }

  bool get enabled => _enabled;

  /// Enable IME
  void enable() {
    _enabled = true;
    _onDidChange.fire(null);
  }

  /// Disable IME
  void disable() {
    _enabled = false;
    _onDidChange.fire(null);
  }
}

/// 1:1: `export const IME`
final IMEImpl IME = IMEImpl();
