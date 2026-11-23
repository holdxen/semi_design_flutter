// ---------------------------------------------------------------------------
// Port of monaco-editor/src/deprecated/editor/editor.worker.ts
// Translated 1:1 from TypeScript.
//   - module-level `self.onmessage = ...` side effect -> `install()` function
//     (Dart has no import-time side effect; the host calls install once).
//   - `worker.start(() => ({}))` -> injectable `workerStart` slot from
//     internal/common/initialize.dart.
//   - `export { initialize }` -> re-export below.
// ---------------------------------------------------------------------------

import '../../internal/common/initialize.dart'
    show isWorkerInitialized, workerSelf, workerStart;

export '../../internal/common/initialize.dart' show initialize;

/// 1:1: module-init `self.onmessage = () => { ... }`.
///
/// Installing twice simply overwrites the handler, matching the TS assignment.
void install() {
  workerSelf.onmessage = (Object? message) {
    if (!isWorkerInitialized()) {
      // 1:1: worker.start(() => { return {}; })
      workerStart((Object? ctx) => <String, Object?>{});
    } else {
      // this is handled because the worker is already initialized
    }
  };
}
