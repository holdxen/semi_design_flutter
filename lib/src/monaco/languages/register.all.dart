// 1:1 translation of monaco-editor/src/languages/register.all.ts
// Source is a pure re-export facade (`export * from ...`).
// Re-exports whose Dart target is already ported become real `export`
// directives; the rest keep the exact specifier 1:1 as a comment until
// their targets are ported (same convention as CSS imports / register.all).

export './definitions/register.all.dart';
// export './features/register.all.dart';  // from './features/register.all'
