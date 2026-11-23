// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/commonFacade/cancellation.ts
// Translated 1:1 from TypeScript.
//
// Source is a pure re-export facade:
//   export { CancellationError } from '../../errors.js';
//   export { CancellationToken, CancellationTokenSource, cancelOnDispose } from '../../cancellation.js';
// Dart expresses the same with export directives.
// ---------------------------------------------------------------------------

export '../../cancellation.dart' show CancellationToken, CancellationTokenSource, cancelOnDispose;
export '../../errors.dart' show CancellationError;
