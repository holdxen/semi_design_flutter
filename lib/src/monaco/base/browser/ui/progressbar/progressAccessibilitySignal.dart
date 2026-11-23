// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/ui/progressbar/progressAccessibilitySignal.ts
// Translated 1:1. The scheduler factory is a top-level injectable slot; the
// null factory mirrors the source's no-op delegate.
// ---------------------------------------------------------------------------

import '../../../common/lifecycle.dart' show IDisposable;

/// 1:1: `interface IScopedAccessibilityProgressSignalDelegate extends IDisposable`
abstract class IScopedAccessibilityProgressSignalDelegate implements IDisposable {
  int get msLoopTime;
  int get msDelayTime;
}

/// 1:1: default no-op delegate (`msLoopTime: -1, msDelayTime: -1, dispose() {}`).
class _NullScopedAccessibilityProgressSignalDelegate
    implements IScopedAccessibilityProgressSignalDelegate {
  @override
  int get msLoopTime => -1;
  @override
  int get msDelayTime => -1;
  @override
  void dispose() {}
}

/// 1:1: `nullScopedAccessibilityProgressSignalFactory`
IScopedAccessibilityProgressSignalDelegate
    nullScopedAccessibilityProgressSignalFactory() =>
        _NullScopedAccessibilityProgressSignalDelegate();

/// 1:1: `progressAccessibilitySignalSchedulerFactory`
typedef AccessibilitySignalSchedulerFactory
    = IScopedAccessibilityProgressSignalDelegate Function(
        int msDelayTime, [int? msLoopTime]);

AccessibilitySignalSchedulerFactory
    progressAccessibilitySignalSchedulerFactory =
    (int msDelayTime, [int? msLoopTime]) =>
        nullScopedAccessibilityProgressSignalFactory();

/// 1:1: `export function setProgressAccessibilitySignalScheduler(...)`
void setProgressAccessibilitySignalScheduler(
        AccessibilitySignalSchedulerFactory scheduler) =>
    progressAccessibilitySignalSchedulerFactory = scheduler;

/// 1:1: `export function getProgressAccessibilitySignalScheduler(...)`
IScopedAccessibilityProgressSignalDelegate getProgressAccessibilitySignalScheduler(
        int msDelayTime, [int? msLoopTime]) =>
    progressAccessibilitySignalSchedulerFactory(msDelayTime, msLoopTime);
