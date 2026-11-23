// ---------------------------------------------------------------------------
// Port of monaco-editor/src/internal/common/initialize.ts
// Translated 1:1 from TypeScript.
//   - `import * as worker from '.../editor.worker.start'` -> injectable
//     `workerStart` slot (the TS module is a side-effect worker bootstrap).
//   - `self.onmessage` -> injectable `workerSelf` carrier so the global
//     message handler can be installed and observed without a real worker.
// ---------------------------------------------------------------------------

/// 1:1: the `editor.worker.start` module's `start(callback)` entry point.
/// `start` receives a factory `(ctx) => handler` and bootstraps the worker.
void Function(Object? Function(Object? ctx) factory) workerStart = (
  Object? Function(Object? ctx) factory,
) {};

/// 1:1: the worker global scope (`self`) carrying `onmessage`.
class WorkerSelf {
  WorkerSelf();

  void Function(Object? message)? onmessage;

  /// Deliver a message through the installed handler, if any.
  void deliver(Object? message) => onmessage?.call(message);
}

/// Injectable worker global scope.
WorkerSelf workerSelf = WorkerSelf();

bool _initialized = false;

/// 1:1: `export function isWorkerInitialized(): boolean`
bool isWorkerInitialized() => _initialized;

/// 1:1: `export function initialize(callback: (ctx, createData) => any): void`
void initialize(Object? Function(Object? ctx, Object? createData) callback) {
  _initialized = true;
  workerSelf.onmessage = (Object? m) {
    workerStart((Object? ctx) {
      return callback(ctx, _messageData(m));
    });
  };
}

/// 1:1: `m.data` access on the incoming message.
Object? _messageData(Object? m) {
  if (m is Map) {
    return m['data'];
  }
  return null;
}

/// Test hook: reset the module-level `initialized` flag.
void resetInitializedForTest() {
  _initialized = false;
  workerSelf = WorkerSelf();
}
