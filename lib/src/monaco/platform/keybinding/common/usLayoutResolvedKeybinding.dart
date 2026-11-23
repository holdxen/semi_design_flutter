// 1:1 port of vs/platform/keybinding/common/usLayoutResolvedKeybinding.ts
// A resolved keybinding seeded with the US keyboard layout.
import '../../../base/common/keyCodes.dart' as kc;
import '../../../base/common/keybindings.dart' as kb;
import '../../../base/common/platform.dart' as plat;
import 'baseResolvedKeybinding.dart' show BaseResolvedKeybinding;
import 'resolvedKeybindingItem.dart' show toEmptyArrayIfContainsNull;

/// 1:1: `export class USLayoutResolvedKeybinding extends BaseResolvedKeybinding<KeyCodeChord>`
class USLayoutResolvedKeybinding extends BaseResolvedKeybinding<kb.KeyCodeChord> {
  /// 1:1: `constructor(chords: KeyCodeChord[], os: OperatingSystem) { super(os, chords); }`
  USLayoutResolvedKeybinding(List<kb.KeyCodeChord> chords, int os) : super(os, chords);

  /// 1:1: `private _keyCodeToUILabel(keyCode: KeyCode): string`
  String _keyCodeToUILabel(int keyCode) {
    if (os == plat.OperatingSystem.Macintosh) {
      switch (keyCode) {
        case kc.KeyCode.LeftArrow:
          return '←';
        case kc.KeyCode.UpArrow:
          return '↑';
        case kc.KeyCode.RightArrow:
          return '→';
        case kc.KeyCode.DownArrow:
          return '↓';
      }
    }
    return kc.KeyCodeUtils.toStringValue(keyCode);
  }

  /// 1:1: `protected _getLabel(chord): string | null`
  @override
  String? getLabelFor(kb.KeyCodeChord chord) {
    if (chord.isDuplicateModifierCase()) {
      return '';
    }
    return _keyCodeToUILabel(chord.keyCode);
  }

  /// 1:1: `protected _getAriaLabel(chord): string | null`
  @override
  String? getAriaLabelFor(kb.KeyCodeChord chord) {
    if (chord.isDuplicateModifierCase()) {
      return '';
    }
    return kc.KeyCodeUtils.toStringValue(chord.keyCode);
  }

  /// 1:1: `protected _getElectronAccelerator(chord): string | null`
  @override
  String? getElectronAcceleratorFor(kb.KeyCodeChord chord) {
    return kc.KeyCodeUtils.toElectronAccelerator(chord.keyCode);
  }

  /// 1:1: `protected _getUserSettingsLabel(chord): string | null`
  @override
  String? getUserSettingsLabelFor(kb.KeyCodeChord chord) {
    if (chord.isDuplicateModifierCase()) {
      return '';
    }
    final String result = kc.KeyCodeUtils.toUserSettingsUS(chord.keyCode);
    // 1:1: `(result ? result.toLowerCase() : result)` — JS truthiness.
    return (result.isNotEmpty) ? result.toLowerCase() : result;
  }

  /// 1:1: `protected _isWYSIWYG(): boolean`
  @override
  bool isWYSIWYGFor(kb.KeyCodeChord chord) => true;

  /// 1:1: `protected _getChordDispatch(chord): string | null`
  @override
  String? getChordDispatch(kb.KeyCodeChord chord) =>
      USLayoutResolvedKeybinding.getDispatchStr(chord);

  /// 1:1: `public static getDispatchStr(chord): string | null`
  static String? getDispatchStr(kb.KeyCodeChord chord) {
    if (chord.isModifierKey()) {
      return null;
    }
    String result = '';
    if (chord.ctrlKey) {
      result += 'ctrl+';
    }
    if (chord.shiftKey) {
      result += 'shift+';
    }
    if (chord.altKey) {
      result += 'alt+';
    }
    if (chord.metaKey) {
      result += 'meta+';
    }
    result += kc.KeyCodeUtils.toStringValue(chord.keyCode);
    return result;
  }

  /// 1:1: `protected _getSingleModifierChordDispatch(keybinding): SingleModifierChord | null`
  @override
  String? getSingleModifierChordDispatch(kb.KeyCodeChord keybinding) {
    if (keybinding.keyCode == kc.KeyCode.Ctrl &&
        !keybinding.shiftKey &&
        !keybinding.altKey &&
        !keybinding.metaKey) {
      return kb.SingleModifierChord.ctrl;
    }
    if (keybinding.keyCode == kc.KeyCode.Shift &&
        !keybinding.ctrlKey &&
        !keybinding.altKey &&
        !keybinding.metaKey) {
      return kb.SingleModifierChord.shift;
    }
    if (keybinding.keyCode == kc.KeyCode.Alt &&
        !keybinding.ctrlKey &&
        !keybinding.shiftKey &&
        !keybinding.metaKey) {
      return kb.SingleModifierChord.alt;
    }
    if (keybinding.keyCode == kc.KeyCode.Meta &&
        !keybinding.ctrlKey &&
        !keybinding.shiftKey &&
        !keybinding.altKey) {
      return kb.SingleModifierChord.meta;
    }
    return null;
  }

  /// 1:1: `private static _scanCodeToKeyCode(scanCode): KeyCode`
  /// NOTE: check return value for `KeyCode.Unknown`.
  static int _scanCodeToKeyCode(int scanCode) {
    final List<int> immutable = kc.IMMUTABLE_CODE_TO_KEY_CODE;
    final int immutableKeyCode = immutable[scanCode];
    if (immutableKeyCode != kc.KeyCode.DependsOnKbLayout) {
      return immutableKeyCode;
    }

    switch (scanCode) {
      case kc.ScanCode.KeyA: return kc.KeyCode.KeyA;
      case kc.ScanCode.KeyB: return kc.KeyCode.KeyB;
      case kc.ScanCode.KeyC: return kc.KeyCode.KeyC;
      case kc.ScanCode.KeyD: return kc.KeyCode.KeyD;
      case kc.ScanCode.KeyE: return kc.KeyCode.KeyE;
      case kc.ScanCode.KeyF: return kc.KeyCode.KeyF;
      case kc.ScanCode.KeyG: return kc.KeyCode.KeyG;
      case kc.ScanCode.KeyH: return kc.KeyCode.KeyH;
      case kc.ScanCode.KeyI: return kc.KeyCode.KeyI;
      case kc.ScanCode.KeyJ: return kc.KeyCode.KeyJ;
      case kc.ScanCode.KeyK: return kc.KeyCode.KeyK;
      case kc.ScanCode.KeyL: return kc.KeyCode.KeyL;
      case kc.ScanCode.KeyM: return kc.KeyCode.KeyM;
      case kc.ScanCode.KeyN: return kc.KeyCode.KeyN;
      case kc.ScanCode.KeyO: return kc.KeyCode.KeyO;
      case kc.ScanCode.KeyP: return kc.KeyCode.KeyP;
      case kc.ScanCode.KeyQ: return kc.KeyCode.KeyQ;
      case kc.ScanCode.KeyR: return kc.KeyCode.KeyR;
      case kc.ScanCode.KeyS: return kc.KeyCode.KeyS;
      case kc.ScanCode.KeyT: return kc.KeyCode.KeyT;
      case kc.ScanCode.KeyU: return kc.KeyCode.KeyU;
      case kc.ScanCode.KeyV: return kc.KeyCode.KeyV;
      case kc.ScanCode.KeyW: return kc.KeyCode.KeyW;
      case kc.ScanCode.KeyX: return kc.KeyCode.KeyX;
      case kc.ScanCode.KeyY: return kc.KeyCode.KeyY;
      case kc.ScanCode.KeyZ: return kc.KeyCode.KeyZ;
      case kc.ScanCode.Digit1: return kc.KeyCode.Digit1;
      case kc.ScanCode.Digit2: return kc.KeyCode.Digit2;
      case kc.ScanCode.Digit3: return kc.KeyCode.Digit3;
      case kc.ScanCode.Digit4: return kc.KeyCode.Digit4;
      case kc.ScanCode.Digit5: return kc.KeyCode.Digit5;
      case kc.ScanCode.Digit6: return kc.KeyCode.Digit6;
      case kc.ScanCode.Digit7: return kc.KeyCode.Digit7;
      case kc.ScanCode.Digit8: return kc.KeyCode.Digit8;
      case kc.ScanCode.Digit9: return kc.KeyCode.Digit9;
      case kc.ScanCode.Digit0: return kc.KeyCode.Digit0;
      case kc.ScanCode.Minus: return kc.KeyCode.Minus;
      case kc.ScanCode.Equal: return kc.KeyCode.Equal;
      case kc.ScanCode.BracketLeft: return kc.KeyCode.BracketLeft;
      case kc.ScanCode.BracketRight: return kc.KeyCode.BracketRight;
      case kc.ScanCode.Backslash: return kc.KeyCode.Backslash;
      case kc.ScanCode.IntlHash: return kc.KeyCode.Unknown; // missing
      case kc.ScanCode.Semicolon: return kc.KeyCode.Semicolon;
      case kc.ScanCode.Quote: return kc.KeyCode.Quote;
      case kc.ScanCode.Backquote: return kc.KeyCode.Backquote;
      case kc.ScanCode.Comma: return kc.KeyCode.Comma;
      case kc.ScanCode.Period: return kc.KeyCode.Period;
      case kc.ScanCode.Slash: return kc.KeyCode.Slash;
      case kc.ScanCode.IntlBackslash: return kc.KeyCode.IntlBackslash;
    }
    return kc.KeyCode.Unknown;
  }

  /// 1:1: `private static _toKeyCodeChord(chord: Chord | null): KeyCodeChord | null`
  static kb.KeyCodeChord? _toKeyCodeChord(kb.Chord? chord) {
    if (chord == null) {
      return null;
    }
    if (chord is kb.KeyCodeChord) {
      return chord;
    }
    final int keyCode = _scanCodeToKeyCode((chord as kb.ScanCodeChord).scanCode);
    if (keyCode == kc.KeyCode.Unknown) {
      return null;
    }
    return kb.KeyCodeChord(
        chord.ctrlKey, chord.shiftKey, chord.altKey, chord.metaKey, keyCode);
  }

  /// 1:1: `public static resolveKeybinding(keybinding, os): USLayoutResolvedKeybinding[]`
  static List<USLayoutResolvedKeybinding> resolveKeybinding(
      kb.Keybinding keybinding, int os) {
    final List<kb.KeyCodeChord> chords = toEmptyArrayIfContainsNull<kb.KeyCodeChord>(
        keybinding.chords.map((chord) => _toKeyCodeChord(chord)).toList());
    if (chords.isNotEmpty) {
      return [USLayoutResolvedKeybinding(chords, os)];
    }
    return [];
  }
}
