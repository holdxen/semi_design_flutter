// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/test/common/virtualScheduling/index.ts
// Greenfield virtual scheduling primitives barrel.
//
// The TS source is a pure re-export barrel. Dart expresses the same
// `export { ... }` semantics with `export` directives; `export type { ... }`
// (type-only re-exports) are already public symbols in the Dart ports and so
// need no separate directive — exporting the library covers them.
// ---------------------------------------------------------------------------

export 'timeApi.dart';
export 'virtualClock.dart';
export 'trace.dart';
export 'embedding.dart';
export 'processor.dart';
export 'globalTimeApi.dart';
export 'virtualTimeApi.dart';
export 'loggingTimeApi.dart';
export 'recordingTimeApi.dart';
export 'traceLogger.dart';
export 'runWithFakedTimers.dart';
