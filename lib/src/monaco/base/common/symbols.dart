// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/symbols.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. JS `Symbol('MicrotaskDelay')` -> a unique Dart
// object used as an opaque sentinel (identity comparison via `identical`).
// ---------------------------------------------------------------------------

/// Can be passed into the Delayed to defer using a microtask.
final Object MicrotaskDelay = Object();
