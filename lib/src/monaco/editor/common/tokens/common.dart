// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/common.ts
// Translated 1:1 from TypeScript. `Date.now()` -> DateTime.now().millisecondsSinceEpoch
// (same wall-clock milliseconds as JS Date.now).
// ---------------------------------------------------------------------------

/// 1:1: `export class RateLimiter`
class RateLimiter {
  /// 1:1: `public readonly timesPerSecond`
  final num timesPerSecond;

  int _lastRun;
  final double _minimumTimeBetweenRuns;

  /// 1:1: `constructor(public readonly timesPerSecond: number = 5)`
  /// `this._lastRun = 0; this._minimumTimeBetweenRuns = 1000 / timesPerSecond;`
  RateLimiter([this.timesPerSecond = 5])
      : _lastRun = 0,
        _minimumTimeBetweenRuns = 1000 / timesPerSecond;

  /// 1:1: `public runIfNotLimited(callback: () => void): void`
  void runIfNotLimited(void Function() callback) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastRun >= _minimumTimeBetweenRuns) {
      _lastRun = now;
      callback();
    }
  }
}
