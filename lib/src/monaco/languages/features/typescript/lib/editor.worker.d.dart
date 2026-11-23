// 1:1 translation of monaco-editor/src/languages/features/typescript/lib/editor.worker.d.ts
// Type-only ambient module declaration. Dart has no `declare module`, so the
// `start` function signature is mirrored as a callable typedef carrier; no
// runtime logic exists in the source and none is added here.

/// 1:1: `import type { worker } from 'monaco-editor-core';`
/// `worker.IWorkerContext<THost>` is represented as the opaque host context.
typedef WorkerContext = Object?;

// 1:1: `export function start<THost extends object, TClient extends object>(
//        createClient: (ctx: worker.IWorkerContext<THost>) => TClient): TClient;`
/// Generic THost/TClient collapse to `Object?` in Dart (no static TS generics).
typedef WorkerStartFunction = Object? Function(
    Object? Function(WorkerContext ctx) createClient);
