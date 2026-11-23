// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/window.ts
// Translated 1:1 from TypeScript. The DOM `Window` type is represented as
// [Object] (no DOM in the Dart port). `CodeWindow` is a carrier holding the
// `vscodeWindowId` property; the browser global `window` is bridged through an
// injectable top-level [mainWindow] (same convention as `globalThis` in
// platform.dart / network.dart). `Object.defineProperty` getter -> a lazily
// bound id on the carrier.
// ---------------------------------------------------------------------------

/// 1:1: `export type CodeWindow = Window & typeof globalThis & { readonly
/// vscodeWindowId: number }`
class CodeWindow {
  CodeWindow(this._window, [this._vscodeWindowId]);

  /// The underlying DOM window (an [Object] in the Dart port).
  final Object _window;

  int? _vscodeWindowId;

  /// 1:1: `readonly vscodeWindowId: number`
  int get vscodeWindowId => _vscodeWindowId ?? 0;

  void set vscodeWindowId(int value) => _vscodeWindowId = value;

  Object get window => _window;

  @override
  String toString() => 'CodeWindow(vscodeWindowId: $vscodeWindowId)';
}

/// 1:1: `ensureCodeWindow` — defines a `vscodeWindowId` getter on [targetWindow]
/// when it is not already a number. Returns the (possibly upgraded) carrier.
CodeWindow ensureCodeWindow(dynamic targetWindow, int fallbackWindowId) {
  if (targetWindow is CodeWindow) {
    if (targetWindow._vscodeWindowId == null) {
      // Object.defineProperty(..., { get: () => fallbackWindowId })
      targetWindow._vscodeWindowId = fallbackWindowId;
    }
    return targetWindow;
  }
  // The source mutates a plain `Window` via defineProperty. In the Dart port a
  // fresh [CodeWindow] carrier stands in for the augmented window object.
  final CodeWindow codeWindow = CodeWindow(targetWindow as Object, fallbackWindowId);
  return codeWindow;
}

/// 1:1: `export const mainWindow = window as CodeWindow`
/// Dart has no browser global `window`; a top-level injectable carrier is used.
CodeWindow mainWindow = CodeWindow(Object(), 0);

/// 1:1: `export function isAuxiliaryWindow`
bool isAuxiliaryWindow(dynamic obj) {
  if (identical(obj, mainWindow)) {
    return false;
  }
  final CodeWindow? candidate = obj is CodeWindow ? obj : null;
  return candidate?._vscodeWindowId != null;
}
