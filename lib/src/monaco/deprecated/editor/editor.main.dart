// 1:1 translation of monaco-editor/src/deprecated/editor/editor.main.ts
// Source (single line): export * from '../../index';
//
// Pure re-export facade. `../../index` resolves to monaco-editor/src/index.ts,
// ported at lib/src/monaco/index.dart, so the relative Dart target is
// `../../index.dart`. No logic is introduced.
export '../../index.dart';
