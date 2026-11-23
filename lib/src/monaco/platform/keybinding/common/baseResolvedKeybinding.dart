// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/keybinding/common/baseResolvedKeybinding.ts
// Translated 1:1 from TypeScript.
// Adaptations (documented inline):
//   - `abstract class BaseResolvedKeybinding<T extends Chord>` -> Dart abstract
//     class; protected abstract methods stay protected by `_` prefix is NOT
//     used so subclasses can implement them (same names as TS).
// ---------------------------------------------------------------------------

import '../../../base/common/errors.dart' as errors;
import '../../../base/common/keybindingLabels.dart' as keybindingLabels;
import '../../../base/common/keybindings.dart' as keybindings;

/// 1:1: `export abstract class BaseResolvedKeybinding<T extends Chord>`
abstract class BaseResolvedKeybinding<T extends keybindings.Chord>
    extends keybindings.ResolvedKeybinding {
  final int os;
  final List<T> chords;

  BaseResolvedKeybinding(this.os, List<T> chords) : chords = chords {
    if (chords.isEmpty) {
      throw errors.illegalArgument('chords');
    }
  }

  @override
  String? getLabel() {
    return keybindingLabels.UILabelProvider.toLabel<T>(
        os, chords, (keybinding) => getLabelFor(keybinding));
  }

  @override
  String? getAriaLabel() {
    return keybindingLabels.AriaLabelProvider.toLabel<T>(
        os, chords, (keybinding) => getAriaLabelFor(keybinding));
  }

  @override
  String? getElectronAccelerator() {
    if (chords.length > 1) {
      // Electron cannot handle chords.
      return null;
    }
    if (chords[0].isDuplicateModifierCase()) {
      // Electron cannot handle modifier-only keybindings, e.g. "shift shift".
      return null;
    }
    return keybindingLabels.ElectronAcceleratorLabelProvider.toLabel<T>(
        os, chords, (keybinding) => getElectronAcceleratorFor(keybinding));
  }

  @override
  String? getUserSettingsLabel() {
    return keybindingLabels.UserSettingsLabelProvider.toLabel<T>(
        os, chords, (keybinding) => getUserSettingsLabelFor(keybinding));
  }

  @override
  bool isWYSIWYG() => chords.every((keybinding) => isWYSIWYGFor(keybinding));

  @override
  bool hasMultipleChords() => chords.length > 1;

  @override
  List<keybindings.ResolvedChord> getChords() =>
      chords.map((keybinding) => getChord(keybinding)).toList();

  keybindings.ResolvedChord getChord(T keybinding) => keybindings.ResolvedChord(
        keybinding.ctrlKey,
        keybinding.shiftKey,
        keybinding.altKey,
        keybinding.metaKey,
        getLabelFor(keybinding),
        getAriaLabelFor(keybinding),
      );

  @override
  List<String?> getDispatchChords() =>
      chords.map((keybinding) => getChordDispatch(keybinding)).toList();

  @override
  List<String?> getSingleModifierDispatchChords() => chords
      .map((keybinding) => getSingleModifierChordDispatch(keybinding))
      .toList();

  /// 1:1: `protected abstract _getLabel`
  String? getLabelFor(T keybinding);

  /// 1:1: `protected abstract _getAriaLabel`
  String? getAriaLabelFor(T keybinding);

  /// 1:1: `protected abstract _getElectronAccelerator`
  String? getElectronAcceleratorFor(T keybinding);

  /// 1:1: `protected abstract _getUserSettingsLabel`
  String? getUserSettingsLabelFor(T keybinding);

  /// 1:1: `protected abstract _isWYSIWYG`
  bool isWYSIWYGFor(T keybinding);

  /// 1:1: `protected abstract _getChordDispatch`
  String? getChordDispatch(T keybinding);

  /// 1:1: `protected abstract _getSingleModifierChordDispatch`
  String? getSingleModifierChordDispatch(T keybinding);
}
