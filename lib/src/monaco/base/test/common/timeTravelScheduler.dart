// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/test/common/timeTravelScheduler.ts
// Translated 1:1 from TypeScript.
//
// The TS source is a deprecated re-export barrel. Semantics:
//   - value re-exports  -> Dart `export ... show`.
//   - aliased re-exports (`realTimeApi as originalGlobalValues`,
//     `VirtualClock as TimeTravelScheduler`) -> top-level aliases: a getter
//     and a typedef respectively, preserving the public names.
//   - type-only re-exports -> already public in the Dart barrel, no directive
//     needed beyond the value export above.
// ---------------------------------------------------------------------------

import 'virtualScheduling/index.dart' as sched;

export 'virtualScheduling/index.dart'
    show
        captureGlobalTimeApi,
        createLoggingTimeApi,
        createVirtualTimeApi,
        pushGlobalTimeApi,
        runWithFakedTimers;

/// 1:1: `realTimeApi as originalGlobalValues`
final sched.TimeApi originalGlobalValues = sched.realTimeApi;

/// 1:1: `VirtualClock as TimeTravelScheduler`
typedef TimeTravelScheduler = sched.VirtualClock;
