// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/commonFacade/deps.ts
// Translated 1:1 from TypeScript. Source is a pure re-export facade; Dart
// expresses the same with export directives (type-only re-exports need no
// separate directive in Dart).
// ---------------------------------------------------------------------------

export '../../assert.dart' show assertFn;
export '../../equals.dart' show EqualityComparer, strictEquals;
export '../../errors.dart' show BugIndicatingError, onBugIndicatingError, onUnexpectedError;
export '../../event.dart' show Event, IValueWithChangeEvent;
export '../../lifecycle.dart'
    show DisposableStore, IDisposable, markAsDisposed, toDisposable, trackDisposable;
