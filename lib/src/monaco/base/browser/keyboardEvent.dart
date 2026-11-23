// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/keyboardEvent.ts
// Translated 1:1 from TypeScript. The DOM `KeyboardEvent`/`HTMLElement` types
// are represented as opaque carriers; `getModifierState` and
// `preventDefault`/`stopPropagation` are surfaced as injectable function slots
// on the carrier so the source control-flow stays unchanged.
// ---------------------------------------------------------------------------

import '../common/keyCodes.dart'
    show EVENT_KEY_CODE_MAP, KeyCode, KeyCodeUtils, KeyMod, isModifierKey;
import '../common/keybindings.dart' show KeyCodeChord;
import '../common/platform.dart' as platform;
import 'browser.dart' as browser;

/// 1:1: `KeyboardEvent` carrier. Every DOM property used by the ported code is
/// an injectable field; functions mirror the optional DOM methods.
class KeyboardEvent {
  KeyboardEvent({
    this.charCode = 0,
    required this.keyCode,
    this.ctrlKey = false,
    this.shiftKey = false,
    this.altKey = false,
    this.metaKey = false,
    this.code = '',
    this.key = '',
    this.isComposing = false,
    this.target,
    this.getModifierState,
    this.preventDefaultFn,
    this.stopPropagationFn,
    this.type = '',
  });

  /// 1:1: DOM `Event.type`.
  final String type;

  final int charCode;
  final int keyCode;
  final bool ctrlKey;
  final bool shiftKey;
  final bool altKey;
  final bool metaKey;
  final String code;
  final String key;
  final bool isComposing;
  final Object? target;

  /// 1:1: `e.getModifierState?.('AltGraph')`
  final bool Function(String modifier)? getModifierState;

  final void Function()? preventDefaultFn;
  final void Function()? stopPropagationFn;

  void preventDefault() => preventDefaultFn?.call();
  void stopPropagation() => stopPropagationFn?.call();
}

/// Injectable browser flag overrides for the `extractKeyCode` quirks.
/// Defaults read the browser.dart flags (which mirror `navigator.userAgent`);
/// tests can inject to exercise each browser branch in isolation.
bool Function()? isFirefoxOverride;
bool Function()? isWebKitOverride;

bool _isFirefox() => isFirefoxOverride?.call() ?? browser.isFirefox;
bool _isWebKit() => isWebKitOverride?.call() ?? browser.isWebKit;
bool Function()? isMacintoshOverride;
bool Function()? isLinuxOverride;
bool _isMacintosh() => isMacintoshOverride?.call() ?? platform.isMacintosh;
bool _isLinux() => isLinuxOverride?.call() ?? platform.isLinux;

/// 1:1: `function extractKeyCode(e: KeyboardEvent): KeyCode`
int extractKeyCode(KeyboardEvent e) {
  if (e.charCode != 0) {
    // "keypress" events mostly
    final String char = String.fromCharCode(e.charCode).toUpperCase();
    return KeyCodeUtils.fromString(char);
  }

  final int keyCode = e.keyCode;

  // browser quirks
  if (keyCode == 3) {
    return KeyCode.PauseBreak;
  } else if (_isFirefox()) {
    switch (keyCode) {
      case 59:
        return KeyCode.Semicolon;
      case 60:
        if (_isLinux()) {
          return KeyCode.IntlBackslash;
        }
        break;
      case 61:
        return KeyCode.Equal;
      // based on: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/keyCode#numpad_keys
      case 107:
        return KeyCode.NumpadAdd;
      case 109:
        return KeyCode.NumpadSubtract;
      case 173:
        return KeyCode.Minus;
      case 224:
        if (_isMacintosh()) {
          return KeyCode.Meta;
        }
        break;
    }
  } else if (_isWebKit()) {
    if (_isMacintosh() && keyCode == 93) {
      // the two meta keys in the Mac have different key codes (91 and 93)
      return KeyCode.Meta;
    } else if (!_isMacintosh() && keyCode == 92) {
      return KeyCode.Meta;
    }
  }

  // cross browser keycodes: `EVENT_KEY_CODE_MAP[keyCode] || KeyCode.Unknown`
  final int mapped = (keyCode >= 0 && keyCode < EVENT_KEY_CODE_MAP.length)
      ? EVENT_KEY_CODE_MAP[keyCode]
      : 0;
  return mapped != 0 ? mapped : KeyCode.Unknown;
}

/// 1:1: `interface IKeyboardEvent`
abstract class IKeyboardEvent {
  /// 1:1: `readonly _standardKeyboardEventBrand: true` (structural brand).
  bool get standardKeyboardEventBrand;
  KeyboardEvent get browserEvent;
  Object? get target;
  bool get ctrlKey;
  bool get shiftKey;
  bool get altKey;
  bool get metaKey;
  bool get altGraphKey;
  int get keyCode;
  String get code;
  KeyCodeChord toKeyCodeChord();
  bool equals(int keybinding);
  void preventDefault();
  void stopPropagation();
}

/// 1:1: const `ctrlKeyMod` / `altKeyMod` / `shiftKeyMod` / `metaKeyMod`
/// resolved at load time in the source (platform flags are compile-time there).
/// In the Dart port they are getters so injected platform flags stay honoured.
int get ctrlKeyMod =>
    _isMacintosh() ? KeyMod.WinCtrl : KeyMod.CtrlCmd;
int get altKeyMod => KeyMod.Alt;
int get shiftKeyMod => KeyMod.Shift;
int get metaKeyMod =>
    _isMacintosh() ? KeyMod.CtrlCmd : KeyMod.WinCtrl;

/// 1:1: `export function printKeyboardEvent(e: KeyboardEvent): string`
String printKeyboardEvent(KeyboardEvent e) {
  final List<String> modifiers = <String>[];
  if (e.ctrlKey) {
    modifiers.add('ctrl');
  }
  if (e.shiftKey) {
    modifiers.add('shift');
  }
  if (e.altKey) {
    modifiers.add('alt');
  }
  if (e.metaKey) {
    modifiers.add('meta');
  }
  return 'modifiers: [${modifiers.join(',')}], code: ${e.code}, '
      'keyCode: ${e.keyCode}, key: ${e.key}';
}

/// 1:1: `export function printStandardKeyboardEvent(e: StandardKeyboardEvent)`
String printStandardKeyboardEvent(StandardKeyboardEvent e) {
  final List<String> modifiers = <String>[];
  if (e.ctrlKey) {
    modifiers.add('ctrl');
  }
  if (e.shiftKey) {
    modifiers.add('shift');
  }
  if (e.altKey) {
    modifiers.add('alt');
  }
  if (e.metaKey) {
    modifiers.add('meta');
  }
  return 'modifiers: [${modifiers.join(',')}], code: ${e.code}, '
      'keyCode: ${e.keyCode} (\'${KeyCodeUtils.toStringValue(e.keyCode)}\')';
}

/// 1:1: `export function hasModifierKeys(keyStatus): boolean`
bool hasModifierKeys({
  required bool ctrlKey,
  required bool shiftKey,
  required bool altKey,
  required bool metaKey,
}) {
  return ctrlKey || shiftKey || altKey || metaKey;
}

/// 1:1: `export class StandardKeyboardEvent implements IKeyboardEvent`
class StandardKeyboardEvent implements IKeyboardEvent {
  @override
  final bool standardKeyboardEventBrand = true;

  @override
  final KeyboardEvent browserEvent;

  @override
  late final Object? target;

  @override
  late bool ctrlKey;
  @override
  late bool shiftKey;
  @override
  late bool altKey;
  @override
  late bool metaKey;
  @override
  late final bool altGraphKey;
  @override
  late final int keyCode;
  @override
  late final String code;

  late final int _asKeybinding;
  late final KeyCodeChord _asKeyCodeChord;

  StandardKeyboardEvent(KeyboardEvent source) : browserEvent = source {
    final KeyboardEvent e = source;

    target = e.target;

    ctrlKey = e.ctrlKey;
    shiftKey = e.shiftKey;
    altKey = e.altKey;
    metaKey = e.metaKey;
    altGraphKey = e.getModifierState?.call('AltGraph') ?? false;
    code = e.code;

    // IME composition normalization (1:1 with source comments):
    // most keystrokes arrive as keyCode 229 (KEY_IN_COMPOSITION), but some
    // platform/IME combinations report the real key code. Normalize so that
    // "the IME owns this keystroke" has a single representation.
    keyCode = e.isComposing ? KeyCode.KEY_IN_COMPOSITION : extractKeyCode(e);

    // (console.info tracing in source omitted — no runtime effect)

    ctrlKey = ctrlKey || keyCode == KeyCode.Ctrl;
    altKey = altKey || keyCode == KeyCode.Alt;
    shiftKey = shiftKey || keyCode == KeyCode.Shift;
    metaKey = metaKey || keyCode == KeyCode.Meta;

    _asKeybinding = _computeKeybinding();
    _asKeyCodeChord = _computeKeyCodeChord();
  }

  @override
  void preventDefault() {
    // 1:1: `if (this.browserEvent && this.browserEvent.preventDefault)`
    final void Function()? fn = browserEvent.preventDefaultFn;
    if (fn != null) {
      fn();
    }
  }

  @override
  void stopPropagation() {
    // 1:1: `if (this.browserEvent && this.browserEvent.stopPropagation)`
    final void Function()? fn = browserEvent.stopPropagationFn;
    if (fn != null) {
      fn();
    }
  }

  @override
  KeyCodeChord toKeyCodeChord() => _asKeyCodeChord;

  @override
  bool equals(int other) => _asKeybinding == other;

  int _computeKeybinding() {
    int key = KeyCode.Unknown;
    if (!isModifierKey(keyCode)) {
      key = keyCode;
    }

    int result = 0;
    if (ctrlKey) {
      result |= ctrlKeyMod;
    }
    if (altKey) {
      result |= altKeyMod;
    }
    if (shiftKey) {
      result |= shiftKeyMod;
    }
    if (metaKey) {
      result |= metaKeyMod;
    }
    result |= key;

    return result;
  }

  KeyCodeChord _computeKeyCodeChord() {
    int key = KeyCode.Unknown;
    if (!isModifierKey(keyCode)) {
      key = keyCode;
    }
    return KeyCodeChord(ctrlKey, shiftKey, altKey, metaKey, key);
  }
}
