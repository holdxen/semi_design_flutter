// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/test/common/virtualScheduling/globalTimeApi.ts
// Translated 1:1 from TypeScript. `globalThis.setTimeout` etc. are bridged
// through the single swappable `activeHostTimeApi` from timeApi.dart (Dart has
// no `globalThis`); push/restore operate on that bridge instead of patching
// global functions. `Object.defineProperty(performance,'now'|'timeOrigin')`
// -> fields on [HostTimeApi] (performanceNow / performanceTimeOrigin). The
// `setTimeout.originalFn` back-door -> [SetTimeoutFn.originalFn] on a wrapper
// implementing the same callable shape.
// ---------------------------------------------------------------------------

import '../../../common/lifecycle.dart' show IDisposable, toDisposable;
import 'timeApi.dart'
    show
        HostTimeApi,
        TimeApi,
        TimeoutId,
        activeHostTimeApi,
        captureGlobalTimeApi,
        hostFromTimeApi,
        realTimeApi;

/// A callable `setTimeout` that can carry the `originalFn` back-door property
/// the source attaches with `(realTimeApi.setTimeout as ...).originalFn = ...`.
/// Implements the same `TimeoutId Function(void Function(), [int])` shape as
/// [HostTimeApi.setTimeout], so it can be installed in its place.
class SetTimeoutFn {
  final TimeoutId Function(void Function() handler, [int timeout]) _fn;
  SetTimeoutFn? originalFn;

  SetTimeoutFn(this._fn, [this.originalFn]);

  TimeoutId call(void Function() handler, [int timeout = 0]) =>
      _fn(handler, timeout);
}

/// 1:1: `ensureSetTimeoutOriginalFn(fn, previousFn)`
/// Guarantees the installed [fn] exposes an [originalFn] back-door, preferring
/// an existing tag, then one inherited from [previousFn], then the real
/// setTimeout (which itself is tagged at module load below).
SetTimeoutFn ensureSetTimeoutOriginalFn(
    SetTimeoutFn fn, SetTimeoutFn previousFn) {
  if (fn.originalFn == null) {
    fn.originalFn = previousFn.originalFn ?? _realSetTimeoutTagged.originalFn ??
        _realSetTimeoutTagged;
  }
  return fn;
}

/// Wrap a raw `setTimeout` function into a [SetTimeoutFn] carrier.
SetTimeoutFn wrapSetTimeout(
        TimeoutId Function(void Function() handler, [int timeout]) fn) =>
    SetTimeoutFn(fn);

/// 1:1: the module-load tag on the *real* setTimeout:
/// `(realTimeApi.setTimeout as {...}).originalFn = realTimeApi.setTimeout;`
/// The bridge has no separate real function object, so the tagged carrier
/// delegates to [realTimeApi.setTimeout] and points `originalFn` at itself.
final SetTimeoutFn _realSetTimeoutTagged = SetTimeoutFn(
  (void Function() handler, [int timeout = 0]) =>
      realTimeApi.setTimeout(handler, timeout),
);

/// Snapshot of the host bridge before an install, so restore can put back the
/// exact same functions (mirrors the source's `previousGlobals` + `previous`).
class _PreviousGlobals {
  final HostTimeApi host;
  _PreviousGlobals(this.host);
}

/// 1:1: `export function pushGlobalTimeApi(api: TimeApi): IDisposable`
/// Replaces the global time API with [api]; the returned disposable restores
/// the previously installed bridge. The previous value is captured at install
/// time, so nested installs compose correctly.
IDisposable pushGlobalTimeApi(TimeApi api) {
  final HostTimeApi previous = activeHostTimeApi ?? hostFromTimeApi(captureGlobalTimeApi());
  final _PreviousGlobals previousGlobals = _PreviousGlobals(previous);

  // Install the incoming API as the active bridge.
  activeHostTimeApi = hostFromTimeApi(api);

  return toDisposable(() {
    // Restore to whatever was current at install time.
    activeHostTimeApi = previousGlobals.host;
  });
}
