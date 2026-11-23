// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/inputMode.ts
// Translated 1:1 from TypeScript. The string union `'overtype' | 'insert'` is
// represented by the [InputModeType] enum (with `.value` matching the TS string).
// The anonymous impl singleton -> a private impl + top-level final instance.
// ---------------------------------------------------------------------------

import '../../base/common/event.dart' show Emitter, Event;

/// 1:1: `'overtype' | 'insert'` (named [InputModeType] to avoid colliding
/// with the exported `InputMode` singleton)
enum InputModeType {
  overtype('overtype'),
  insert('insert');

  const InputModeType(this.value);
  final String value;

  static InputModeType? fromValue(String value) {
    for (final InputModeType m in InputModeType.values) {
      if (m.value == value) return m;
    }
    return null;
  }
}

/// 1:1: `class InputModeImpl`
class _InputModeImpl {
  InputModeType _inputMode = InputModeType.insert;

  final Emitter<InputModeType> _onDidChangeInputMode = Emitter<InputModeType>();

  late final Event<InputModeType> onDidChangeInputMode =
      _onDidChangeInputMode.event;

  InputModeType getInputMode() => _inputMode;

  void setInputMode(InputModeType inputMode) {
    _inputMode = inputMode;
    _onDidChangeInputMode.fire(_inputMode);
  }
}

/// Controls the type mode, whether insert or overtype.
///
/// 1:1: `export const InputMode = new InputModeImpl()`
final _InputModeImpl InputMode = _InputModeImpl();
