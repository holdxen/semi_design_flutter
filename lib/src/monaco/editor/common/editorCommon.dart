// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/editorCommon.ts (783 lines).
//
// This file is overwhelmingly type-level: 30 `interface` declarations and 4
// `type` aliases are ERASED per the repo's established convention (see
// PORT_PROGRESS.md). Only the 4 runtime declarations are ported:
//   - `ScrollType` (const enum, L216-219)
//   - `isThemeColor` (function, L612-614)
//   - `EditorType` (const object, L741-744)
//   - `Handler` (const enum, L750-758)
//
// NOTE: `standalone/standaloneEnums.dart` also declares a `ScrollType` (from
// standaloneEnums.ts). They are separate libraries, so there is no conflict;
// each source file keeps its own 1:1 declaration.
// ---------------------------------------------------------------------------

import '../../base/common/themables.dart' as themables;

/// 1:1: `export const enum ScrollType`.
class ScrollType {
  static const int Smooth = 0;
  static const int Immediate = 1;

  const ScrollType._();
}

/// 1:1: `export function isThemeColor(o: unknown): o is ThemeColor`
/// Source: `return !!o && typeof (o as ThemeColor).id === 'string';`
/// Delegates to the ported `ThemeColor.isThemeColor` in themables.dart, whose
/// source (base/common/themables.ts) performs the identical duck-typed check
/// via an `_idOf` bridge (ThemeColor / ThemeIcon / Map carriers).
bool isThemeColor(Object? o) => themables.ThemeColor.isThemeColor(o);

/// 1:1: `export const EditorType`.
class EditorType {
  static const String ICodeEditor = 'vs.editor.ICodeEditor';
  static const String IDiffEditor = 'vs.editor.IDiffEditor';

  const EditorType._();
}

/// 1:1: `export const enum Handler`.
class Handler {
  static const String CompositionStart = 'compositionStart';
  static const String CompositionEnd = 'compositionEnd';
  static const String Type = 'type';
  static const String ReplacePreviousChar = 'replacePreviousChar';
  static const String CompositionType = 'compositionType';
  static const String Paste = 'paste';
  static const String Cut = 'cut';

  const Handler._();
}
