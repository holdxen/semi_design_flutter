// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/services/editorBaseApi.ts (44 lines).
//
// `KeyMod` is a thin wrapper over the global `KeyMod` constants, and
// `createMonacoBaseAPI()` builds the subset of the public `monaco` namespace
// that the standalone editor exposes before `editor` / `languages` are
// overwritten by the API hosts.
//
// Adaptations:
//   - TS returns an object literal typed as `typeof monaco`; Dart has no
//     ambient namespace, so the carrier is a `Map<String, Object?>` with the
//     same keys **in the same order**.
//   - `editor` / `languages` are `undefined!` in TS -> `null` here.
//   - JS constructor references (`CancellationTokenSource`, `Emitter`,
//     `Position`, ...) and enum objects (`KeyCode`, `MarkerSeverity`, ...) are
//     carried as Dart `Type` values; they are type-level tokens with no
//     runtime construction semantics, exactly like the object-literal entries.
//   - `Selection as unknown as typeof monaco.Selection` is just `Selection`.
// ---------------------------------------------------------------------------

import '../../../base/common/cancellation.dart' show CancellationTokenSource;
import '../../../base/common/event.dart' show Emitter;
import '../../../base/common/keyCodes.dart' as keyCodes show KeyMod, KeyChord;
import '../../../base/common/uri.dart' show URI;
import '../standalone/standaloneEnums.dart' as standaloneEnums;
import '../core/position.dart' show Position;
import '../core/range.dart' show Range;
import '../core/selection.dart' show Selection;
import '../languages.dart' show Token;

class KeyMod {
  static const int CtrlCmd = keyCodes.KeyMod.CtrlCmd;
  static const int Shift = keyCodes.KeyMod.Shift;
  static const int Alt = keyCodes.KeyMod.Alt;
  static const int WinCtrl = keyCodes.KeyMod.WinCtrl;

  const KeyMod._();

  static int chord(int firstPart, int secondPart) =>
      keyCodes.KeyChord(firstPart, secondPart);
}

/// 1:1: `export function createMonacoBaseAPI(): typeof monaco`
Map<String, Object?> createMonacoBaseAPI() => <String, Object?>{
      'editor': null, // undefined override expected here
      'languages': null, // undefined override expected here
      'CancellationTokenSource': CancellationTokenSource,
      'Emitter': Emitter,
      'KeyCode': standaloneEnums.KeyCode,
      'KeyMod': KeyMod,
      'Position': Position,
      'Range': Range,
      'Selection': Selection,
      'SelectionDirection': standaloneEnums.SelectionDirection,
      'MarkerSeverity': standaloneEnums.MarkerSeverity,
      'MarkerTag': standaloneEnums.MarkerTag,
      'Uri': URI,
      'Token': Token,
    };
