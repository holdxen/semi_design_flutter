// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/keybinding/common/resolvedKeybindingItem.ts
// Translated 1:1. The constructor body is kept verbatim, including the
// single-modifier fallback branch and the JS-truthiness test `if (!element)`
// in toEmptyArrayIfContainsNull (captured via `_isFalsy` so that '' / 0 /
// false behave exactly as in TypeScript).
// ---------------------------------------------------------------------------

import '../../../base/common/charCode.dart' show CharCode;
import '../../../base/common/keybindings.dart' show ResolvedKeybinding;
import '../../contextkey/common/contextkey.dart' show ContextKeyExpression;

/// JS truthiness for `!x` — TS `if (!element)` rejects null/undefined/false/0/''.
bool _isFalsy(Object? v) => v == null || v == false || v == 0 || v == '';

/// 1:1: `export function toEmptyArrayIfContainsNull<T>(arr: (T | null)[]): T[]`
List<T> toEmptyArrayIfContainsNull<T>(List<T?> arr) {
  final List<T> result = <T>[];
  for (int i = 0, len = arr.length; i < len; i++) {
    final T? element = arr[i];
    if (_isFalsy(element)) {
      return <T>[];
    }
    result.add(element as T);
  }
  return result;
}

/// 1:1: `export class ResolvedKeybindingItem`
class ResolvedKeybindingItem {
  /// 1:1: `_resolvedKeybindingItemBrand: void = undefined;`
  // ignore: unused_field, avoid_init_to_null, prefer_final_fields
  final Object? _resolvedKeybindingItemBrand = null;

  late final ResolvedKeybinding? resolvedKeybinding;
  late final List<String> chords;
  late final bool bubble;
  late final String? command;
  final Object? commandArgs;
  final ContextKeyExpression? when;
  final bool isDefault;
  final String? extensionId;
  final bool isBuiltinExtension;

  /// Whether this keybinding was declared as a system-wide (OS global) shortcut via
  /// `keybindings.json`. Only ever `true` for user keybindings; defaults/extension keybindings
  /// are always `false`.
  final bool systemWide;

  /// 1:1: constructor(resolvedKeybinding, command, commandArgs, when, isDefault,
  /// extensionId, isBuiltinExtension, systemWide = false)
  ResolvedKeybindingItem(
    ResolvedKeybinding? resolvedKeybinding,
    String? command,
    this.commandArgs,
    this.when,
    this.isDefault,
    this.extensionId,
    this.isBuiltinExtension, [
    this.systemWide = false,
  ]) {
    this.resolvedKeybinding = resolvedKeybinding;
    var chords = resolvedKeybinding != null
        ? toEmptyArrayIfContainsNull<String>(
            resolvedKeybinding.getDispatchChords())
        : <String>[];
    if (resolvedKeybinding != null && chords.isEmpty) {
      // handle possible single modifier chord keybindings
      chords = toEmptyArrayIfContainsNull<String>(
          resolvedKeybinding.getSingleModifierDispatchChords());
    }
    this.chords = chords;
    // TS: `(command ? command.charCodeAt(0) === CharCode.Caret : false)`.
    // JS `''.charCodeAt(0)` is NaN, hence `isNotEmpty` keeps the same falsy path.
    bubble = command != null &&
        command.isNotEmpty &&
        command.codeUnitAt(0) == CharCode.Caret;
    this.command = bubble ? command!.substring(1) : command;
  }
}
