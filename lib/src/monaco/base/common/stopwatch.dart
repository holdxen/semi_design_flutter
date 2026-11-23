// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/stopwatch.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. JS `performance.now()` -> a persistent Dart
// `Stopwatch` read as elapsed microseconds/1000; `Date.now()` ->
// `DateTime.now().microsecondsSinceEpoch ~/ 1000`. Structure, names and control
// flow are otherwise identical.
// ---------------------------------------------------------------------------

/// A stop watch measuring elapsed time, with optional high resolution.
class StopWatch {
  final Stopwatch? _perfStopwatch;
  late final int Function() _now;

  int _startTime = 0;
  int _stopTime = -1;

  static StopWatch create([bool? highResolution]) => StopWatch(highResolution);

  StopWatch([bool? highResolution])
      : _perfStopwatch = (highResolution == false) ? null : (Stopwatch()..start()) {
    _now = highResolution == false
        ? () => DateTime.now().microsecondsSinceEpoch ~/ 1000
        : () => (_perfStopwatch!.elapsedMicroseconds / 1000).round();
    _startTime = _now();
    _stopTime = -1;
  }

  void stop() {
    _stopTime = _now();
  }

  void reset() {
    _startTime = _now();
    _stopTime = -1;
  }

  num elapsed() {
    if (_stopTime != -1) {
      return _stopTime - _startTime;
    }
    return _now() - _startTime;
  }
}
