// 1:1 translation of vscode/src/vs/base/common/keybindings.ts
// Adaptations (documented inline):
//   - `const enum` BinaryKeybindingsMask → class + static const int.
//   - `type Chord = KeyCodeChord | ScanCodeChord` → abstract class Chord
//     implemented by both (Dart has no union types).
//   - `number | number[]` → Object (num or List<int>), matching other ports.
//   - `throw illegalArgument(...)` → `throw illegalArgument(...)`.

import 'errors.dart' show illegalArgument;
import 'keyCodes.dart' show KeyCode, ScanCode;
import 'platform.dart' show OperatingSystem;

/// 1:1: `const enum BinaryKeybindingsMask`
class BinaryKeybindingsMask {
  static const int ctrlCmd = 0x800; // (1 << 11) >>> 0
  static const int shift = 0x400; // (1 << 10) >>> 0
  static const int alt = 0x200; // (1 << 9) >>> 0
  static const int winCtrl = 0x100; // (1 << 8) >>> 0
  static const int keyCode = 0x000000FF;
}

/// 1:1: `decodeKeybinding(keybinding: number | number[], OS)`
///
/// [keybinding] is either an [int] or a [List<int>].
Keybinding? decodeKeybinding(Object keybinding, int OS) {
  if (keybinding is int) {
    if (keybinding == 0) {
      return null;
    }
    final int firstChord = (keybinding & 0x0000FFFF) >>> 0;
    final int secondChord = (keybinding & 0xFFFF0000) >>> 16;
    if (secondChord != 0) {
      return Keybinding([
        createSimpleKeybinding(firstChord, OS),
        createSimpleKeybinding(secondChord, OS),
      ]);
    }
    return Keybinding([createSimpleKeybinding(firstChord, OS)]);
  } else {
    final List<int> keybindings = keybinding as List<int>;
    final List<Chord> chords = <Chord>[];
    for (int i = 0; i < keybindings.length; i++) {
      chords.add(createSimpleKeybinding(keybindings[i], OS));
    }
    return Keybinding(chords);
  }
}

/// 1:1: `createSimpleKeybinding(keybinding, OS)`
KeyCodeChord createSimpleKeybinding(int keybinding, int OS) {
  final bool ctrlCmd = (keybinding & BinaryKeybindingsMask.ctrlCmd) != 0;
  final bool winCtrl = (keybinding & BinaryKeybindingsMask.winCtrl) != 0;

  final bool ctrlKey = OS == OperatingSystem.Macintosh ? winCtrl : ctrlCmd;
  final bool shiftKey = (keybinding & BinaryKeybindingsMask.shift) != 0;
  final bool altKey = (keybinding & BinaryKeybindingsMask.alt) != 0;
  final bool metaKey = OS == OperatingSystem.Macintosh ? ctrlCmd : winCtrl;
  final int keyCode = keybinding & BinaryKeybindingsMask.keyCode;

  return KeyCodeChord(ctrlKey, shiftKey, altKey, metaKey, keyCode);
}

/// 1:1: `export interface Modifiers`
abstract class Modifiers {
  bool get ctrlKey;
  bool get shiftKey;
  bool get altKey;
  bool get metaKey;
}

/// 1:1: `export type Chord = KeyCodeChord | ScanCodeChord`
abstract class Chord implements Modifiers {
  bool equals(Chord other);
  String getHashCode();
  bool isDuplicateModifierCase();
}

/// 1:1: `export class KeyCodeChord`
class KeyCodeChord extends Chord {
  @override
  final bool ctrlKey;
  @override
  final bool shiftKey;
  @override
  final bool altKey;
  @override
  final bool metaKey;
  final int keyCode;

  KeyCodeChord(this.ctrlKey, this.shiftKey, this.altKey, this.metaKey, this.keyCode);

  @override
  bool equals(Chord other) {
    return other is KeyCodeChord &&
        other.ctrlKey == ctrlKey &&
        other.shiftKey == shiftKey &&
        other.altKey == altKey &&
        other.metaKey == metaKey &&
        other.keyCode == keyCode;
  }

  @override
  String getHashCode() {
    final String ctrl = ctrlKey ? '1' : '0';
    final String shift = shiftKey ? '1' : '0';
    final String alt = altKey ? '1' : '0';
    final String meta = metaKey ? '1' : '0';
    return 'K$ctrl$shift$alt$meta$keyCode';
  }

  bool isModifierKey() {
    return keyCode == KeyCode.Unknown ||
        keyCode == KeyCode.Ctrl ||
        keyCode == KeyCode.Meta ||
        keyCode == KeyCode.Alt ||
        keyCode == KeyCode.Shift;
  }

  Keybinding toKeybinding() => Keybinding([this]);

  @override
  bool isDuplicateModifierCase() {
    return (ctrlKey && keyCode == KeyCode.Ctrl) ||
        (shiftKey && keyCode == KeyCode.Shift) ||
        (altKey && keyCode == KeyCode.Alt) ||
        (metaKey && keyCode == KeyCode.Meta);
  }
}

/// 1:1: `export class ScanCodeChord`
class ScanCodeChord extends Chord {
  @override
  final bool ctrlKey;
  @override
  final bool shiftKey;
  @override
  final bool altKey;
  @override
  final bool metaKey;
  final int scanCode;

  ScanCodeChord(this.ctrlKey, this.shiftKey, this.altKey, this.metaKey, this.scanCode);

  @override
  bool equals(Chord other) {
    return other is ScanCodeChord &&
        other.ctrlKey == ctrlKey &&
        other.shiftKey == shiftKey &&
        other.altKey == altKey &&
        other.metaKey == metaKey &&
        other.scanCode == scanCode;
  }

  @override
  String getHashCode() {
    final String ctrl = ctrlKey ? '1' : '0';
    final String shift = shiftKey ? '1' : '0';
    final String alt = altKey ? '1' : '0';
    final String meta = metaKey ? '1' : '0';
    return 'S$ctrl$shift$alt$meta$scanCode';
  }

  @override
  bool isDuplicateModifierCase() {
    return (ctrlKey &&
            (scanCode == ScanCode.ControlLeft || scanCode == ScanCode.ControlRight)) ||
        (shiftKey &&
            (scanCode == ScanCode.ShiftLeft || scanCode == ScanCode.ShiftRight)) ||
        (altKey && (scanCode == ScanCode.AltLeft || scanCode == ScanCode.AltRight)) ||
        (metaKey && (scanCode == ScanCode.MetaLeft || scanCode == ScanCode.MetaRight));
  }
}

/// 1:1: `export class Keybinding`
class Keybinding {
  final List<Chord> chords;

  Keybinding(this.chords) {
    if (chords.isEmpty) {
      throw illegalArgument('chords');
    }
  }

  String getHashCode() {
    String result = '';
    for (int i = 0, len = chords.length; i < len; i++) {
      if (i != 0) {
        result += ';';
      }
      result += chords[i].getHashCode();
    }
    return result;
  }

  bool equals(Keybinding? other) {
    if (other == null) {
      return false;
    }
    if (chords.length != other.chords.length) {
      return false;
    }
    for (int i = 0; i < chords.length; i++) {
      if (!chords[i].equals(other.chords[i])) {
        return false;
      }
    }
    return true;
  }
}

/// 1:1: `export class ResolvedChord`
class ResolvedChord {
  final bool ctrlKey;
  final bool shiftKey;
  final bool altKey;
  final bool metaKey;
  final String? keyLabel;
  final String? keyAriaLabel;

  ResolvedChord(this.ctrlKey, this.shiftKey, this.altKey, this.metaKey, this.keyLabel,
      this.keyAriaLabel);
}

/// 1:1: `export type SingleModifierChord = 'ctrl' | 'shift' | 'alt' | 'meta'`
class SingleModifierChord {
  static const String ctrl = 'ctrl';
  static const String shift = 'shift';
  static const String alt = 'alt';
  static const String meta = 'meta';
}

/// 1:1: `export abstract class ResolvedKeybinding`
abstract class ResolvedKeybinding {
  String? getLabel();
  String? getAriaLabel();
  String? getElectronAccelerator();
  String? getUserSettingsLabel();
  bool isWYSIWYG();
  bool hasMultipleChords();
  List<ResolvedChord> getChords();
  List<String?> getDispatchChords();
  List<String?> getSingleModifierDispatchChords();
}
