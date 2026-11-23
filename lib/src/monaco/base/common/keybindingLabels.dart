// 1:1 translation of vscode/src/vs/base/common/keybindingLabels.ts
// Adaptations (documented inline):
//   - `interface` → class; `KeyLabelProvider<T>` generic function type → typedef.
//   - `ModifierLabels[]` with a null slot at index 0 → List<ModifierLabels?>.
//   - `nls.localize({key, comment}, "X")` → nls.localize(map, "X"); since the
//     data object is not an int, nls returns the message verbatim (same as TS
//     in the default en locale), while preserving the metadata shape 1:1.

import '../../nls.dart' as nls;
import 'keybindings.dart' show Modifiers;
import 'platform.dart' show OperatingSystem;

/// 1:1: `export interface ModifierLabels`
class ModifierLabels {
  final String ctrlKey;
  final String shiftKey;
  final String altKey;
  final String metaKey;
  final String separator;

  const ModifierLabels({
    required this.ctrlKey,
    required this.shiftKey,
    required this.altKey,
    required this.metaKey,
    required this.separator,
  });
}

/// 1:1: `export interface KeyLabelProvider<T extends Modifiers>`
typedef KeyLabelProvider<T extends Modifiers> = String? Function(T keybinding);

/// 1:1: `export class ModifierLabelProvider`
class ModifierLabelProvider {
  late final List<ModifierLabels?> modifierLabels;

  ModifierLabelProvider(ModifierLabels mac, ModifierLabels windows,
      [ModifierLabels? linux]) {
    linux ??= windows;
    modifierLabels = List<ModifierLabels?>.filled(4, null); // index 0 never accessed
    modifierLabels[OperatingSystem.Macintosh] = mac;
    modifierLabels[OperatingSystem.Windows] = windows;
    modifierLabels[OperatingSystem.Linux] = linux;
  }

  String? toLabel<T extends Modifiers>(
      int OS, List<T> chords, KeyLabelProvider<T> keyLabelProvider) {
    if (chords.isEmpty) {
      return null;
    }

    final List<String> result = List<String>.filled(chords.length, '');
    for (int i = 0, len = chords.length; i < len; i++) {
      final T chord = chords[i];
      final String? keyLabel = keyLabelProvider(chord);
      if (keyLabel == null) {
        // this keybinding cannot be expressed...
        return null;
      }
      result[i] = _simpleAsString(chord, keyLabel, modifierLabels[OS]!);
    }
    return result.join(' ');
  }
}

// nls metadata helper — mirrors the `{ key, comment }` object literal passed
// as the first argument to `nls.localize` in the TS source.
Map<String, Object> _nls(String key, String comment) =>
    <String, Object>{'key': key, 'comment': <String>[comment]};

/// 1:1: `UILabelProvider`
final ModifierLabelProvider UILabelProvider = ModifierLabelProvider(
  const ModifierLabels(
    ctrlKey: '\u2303',
    shiftKey: '⇧',
    altKey: '⌥',
    metaKey: '⌘',
    separator: '',
  ),
  ModifierLabels(
    ctrlKey: nls.localize(_nls('ctrlKey', 'This is the short form for the Control key on the keyboard'), 'Ctrl'),
    shiftKey: nls.localize(_nls('shiftKey', 'This is the short form for the Shift key on the keyboard'), 'Shift'),
    altKey: nls.localize(_nls('altKey', 'This is the short form for the Alt key on the keyboard'), 'Alt'),
    metaKey: nls.localize(_nls('windowsKey', 'This is the short form for the Windows key on the keyboard'), 'Windows'),
    separator: '+',
  ),
  ModifierLabels(
    ctrlKey: nls.localize(_nls('ctrlKey', 'This is the short form for the Control key on the keyboard'), 'Ctrl'),
    shiftKey: nls.localize(_nls('shiftKey', 'This is the short form for the Shift key on the keyboard'), 'Shift'),
    altKey: nls.localize(_nls('altKey', 'This is the short form for the Alt key on the keyboard'), 'Alt'),
    metaKey: nls.localize(_nls('superKey', 'This is the short form for the Super key on the keyboard'), 'Super'),
    separator: '+',
  ),
);

/// 1:1: `AriaLabelProvider`
final ModifierLabelProvider AriaLabelProvider = ModifierLabelProvider(
  ModifierLabels(
    ctrlKey: nls.localize(_nls('ctrlKey.long', 'This is the long form for the Control key on the keyboard'), 'Control'),
    shiftKey: nls.localize(_nls('shiftKey.long', 'This is the long form for the Shift key on the keyboard'), 'Shift'),
    altKey: nls.localize(_nls('optKey.long', 'This is the long form for the Alt/Option key on the keyboard'), 'Option'),
    metaKey: nls.localize(_nls('cmdKey.long', 'This is the long form for the Command key on the keyboard'), 'Command'),
    separator: '+',
  ),
  ModifierLabels(
    ctrlKey: nls.localize(_nls('ctrlKey.long', 'This is the long form for the Control key on the keyboard'), 'Control'),
    shiftKey: nls.localize(_nls('shiftKey.long', 'This is the long form for the Shift key on the keyboard'), 'Shift'),
    altKey: nls.localize(_nls('altKey.long', 'This is the long form for the Alt key on the keyboard'), 'Alt'),
    metaKey: nls.localize(_nls('windowsKey.long', 'This is the long form for the Windows key on the keyboard'), 'Windows'),
    separator: '+',
  ),
  ModifierLabels(
    ctrlKey: nls.localize(_nls('ctrlKey.long', 'This is the long form for the Control key on the keyboard'), 'Control'),
    shiftKey: nls.localize(_nls('shiftKey.long', 'This is the long form for the Shift key on the keyboard'), 'Shift'),
    altKey: nls.localize(_nls('altKey.long', 'This is the long form for the Alt key on the keyboard'), 'Alt'),
    metaKey: nls.localize(_nls('superKey.long', 'This is the long form for the Super key on the keyboard'), 'Super'),
    separator: '+',
  ),
);

/// 1:1: `ElectronAcceleratorLabelProvider`
final ModifierLabelProvider ElectronAcceleratorLabelProvider = ModifierLabelProvider(
  const ModifierLabels(
    ctrlKey: 'Ctrl',
    shiftKey: 'Shift',
    altKey: 'Alt',
    metaKey: 'Cmd',
    separator: '+',
  ),
  const ModifierLabels(
    ctrlKey: 'Ctrl',
    shiftKey: 'Shift',
    altKey: 'Alt',
    metaKey: 'Super',
    separator: '+',
  ),
);

/// 1:1: `UserSettingsLabelProvider`
final ModifierLabelProvider UserSettingsLabelProvider = ModifierLabelProvider(
  const ModifierLabels(
    ctrlKey: 'ctrl',
    shiftKey: 'shift',
    altKey: 'alt',
    metaKey: 'cmd',
    separator: '+',
  ),
  const ModifierLabels(
    ctrlKey: 'ctrl',
    shiftKey: 'shift',
    altKey: 'alt',
    metaKey: 'win',
    separator: '+',
  ),
  const ModifierLabels(
    ctrlKey: 'ctrl',
    shiftKey: 'shift',
    altKey: 'alt',
    metaKey: 'meta',
    separator: '+',
  ),
);

/// 1:1: `_simpleAsString(modifiers, key, labels)`
String _simpleAsString(Modifiers modifiers, String? key, ModifierLabels labels) {
  // TS declares `key: string` but guards `key === null`; use String? to carry
  // that exact guard (the caller already checks the provider result for null).
  if (key == null) {
    return '';
  }

  final List<String> result = <String>[];

  // translate modifier keys: Ctrl-Shift-Alt-Meta
  if (modifiers.ctrlKey) {
    result.add(labels.ctrlKey);
  }
  if (modifiers.shiftKey) {
    result.add(labels.shiftKey);
  }
  if (modifiers.altKey) {
    result.add(labels.altKey);
  }
  if (modifiers.metaKey) {
    result.add(labels.metaKey);
  }

  // the actual key
  if (key.isNotEmpty) {
    result.add(key);
  }
  // (key is non-null here; Dart promotes String? to String after the guard)

  return result.join(labels.separator);
}
