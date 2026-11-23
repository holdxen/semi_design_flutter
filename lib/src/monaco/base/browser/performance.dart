// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/performance.ts
// Translated 1:1 from TypeScript. `namespace inputLatency` -> a class of static
// members. The browser globals `performance`, `queueMicrotask` and `setTimeout`
// have no Dart equivalent, so they are bridged through replaceable top-level
// carriers (same convention as `cssEscape` / `globalThis` bridges elsewhere).
// ---------------------------------------------------------------------------

import 'dart:async' show Timer, scheduleMicrotask;
import 'dart:math' show max, min;

import '../common/observable.dart' show ISettableObservable, observableValue;

/// Bridge for the browser `Performance` object used by inputLatency.
/// Replaceable in tests / non-browser platforms.
abstract class InputLatencyPerformance {
  void mark(String name);
  void measure(String name, String start, String end);
  List<InputLatencyMeasureEntry> getEntriesByName(String name);
  void clearMarks([String? name]);
  void clearMeasures([String? name]);
}

/// 1:1 carrier for a `PerformanceEntry` produced by `performance.measure`.
class InputLatencyMeasureEntry {
  final String name;
  final num duration;
  InputLatencyMeasureEntry(this.name, this.duration);
}

/// Default in-memory implementation of the performance carrier.
class _DefaultInputLatencyPerformance implements InputLatencyPerformance {
  final List<String> _marks = <String>[];
  final List<InputLatencyMeasureEntry> _measures =
      <InputLatencyMeasureEntry>[];

  @override
  void mark(String name) => _marks.add(name);

  @override
  void measure(String name, String start, String end) {
    _measures.add(InputLatencyMeasureEntry(name, 0));
  }

  @override
  List<InputLatencyMeasureEntry> getEntriesByName(String name) =>
      _measures.where((e) => e.name == name).toList();

  @override
  void clearMarks([String? name]) {
    if (name == null) {
      _marks.clear();
    } else {
      _marks.removeWhere((m) => m == name);
    }
  }

  @override
  void clearMeasures([String? name]) {
    if (name == null) {
      _measures.clear();
    } else {
      _measures.removeWhere((e) => e.name == name);
    }
  }
}

/// Replaceable performance carrier (browser global bridge).
InputLatencyPerformance inputLatencyPerformance =
    _DefaultInputLatencyPerformance();

/// Replaceable `queueMicrotask` bridge.
void Function(void Function()) inputLatencyQueueMicrotask =
    (fn) => scheduleMicrotask(fn);

/// Replaceable `setTimeout` bridge.
void Function(void Function()) inputLatencySetTimeout =
    (fn) => Timer.run(fn);

/// 1:1: `interface ICumulativeMeasurement`
class ICumulativeMeasurement {
  num total;
  num min;
  num max;
  ICumulativeMeasurement(this.total, this.min, this.max);
  ICumulativeMeasurement.copy(ICumulativeMeasurement other)
      : total = other.total,
        min = other.min,
        max = other.max;
}

/// 1:1: `namespace inputLatency`
class inputLatency {
  inputLatency._();

  // Measurements are recorded as totals; the average is computed at the end.
  // TS spreads `{ ...totalKeydownTime }` at module load, when the values are
  // still {total:0, min:MAX_VALUE, max:0}. Dart `static final` is lazy, so
  // copying _totalKeydownTime here would snapshot an already-mutated total;
  // use the identical literal initial state to preserve 1:1 semantics.
  static final ICumulativeMeasurement _totalKeydownTime =
      ICumulativeMeasurement(0, double.maxFinite, 0);
  static final ICumulativeMeasurement _totalInputTime =
      ICumulativeMeasurement(0, double.maxFinite, 0);
  static final ICumulativeMeasurement _totalRenderTime =
      ICumulativeMeasurement(0, double.maxFinite, 0);
  static final ICumulativeMeasurement _totalInputLatencyTime =
      ICumulativeMeasurement(0, double.maxFinite, 0);
  static int _measurementsCount = 0;

  /// 1:1: `export const sampleCount = observableValue('inputLatency.sampleCount', 0)`
  static final ISettableObservable<int, Object?> sampleCount =
      observableValue<int, Object?>('inputLatency.sampleCount', 0);

  /// 1:1: `const enum EventPhase`
  static const int _before = 0;
  static const int _inProgress = 1;
  static const int _finished = 2;

  static final Map<String, int> _state = <String, int>{
    'keydown': _before,
    'input': _before,
    'render': _before,
  };

  /// 1:1: `export function onKeyDown()`
  static void onKeyDown() {
    recordIfFinished(); // Direct Check C
    inputLatencyPerformance.mark('inputlatency/start');
    inputLatencyPerformance.mark('keydown/start');
    _state['keydown'] = _inProgress;
    inputLatencyQueueMicrotask(_markKeyDownEnd);
  }

  /// 1:1: `function markKeyDownEnd()`
  static void _markKeyDownEnd() {
    if (_state['keydown'] == _inProgress) {
      inputLatencyPerformance.mark('keydown/end');
      _state['keydown'] = _finished;
    }
  }

  /// 1:1: `export function onBeforeInput()`
  static void onBeforeInput() {
    inputLatencyPerformance.mark('input/start');
    _state['input'] = _inProgress;
    _scheduleRecordIfFinishedTask(); // Schedule Task A
  }

  /// 1:1: `export function onInput()`
  static void onInput() {
    if (_state['input'] == _before) {
      onBeforeInput();
    }
    inputLatencyQueueMicrotask(_markInputEnd);
  }

  /// 1:1: `function markInputEnd()`
  static void _markInputEnd() {
    if (_state['input'] == _inProgress) {
      inputLatencyPerformance.mark('input/end');
      _state['input'] = _finished;
    }
  }

  /// 1:1: `export function onKeyUp()`
  static void onKeyUp() {
    recordIfFinished(); // Direct Check D
  }

  /// 1:1: `export function onSelectionChange()`
  static void onSelectionChange() {
    recordIfFinished(); // Direct Check E
  }

  /// 1:1: `export function onRenderStart()`
  static void onRenderStart() {
    if (_state['keydown'] == _finished &&
        _state['input'] == _finished &&
        _state['render'] == _before) {
      inputLatencyPerformance.mark('render/start');
      _state['render'] = _inProgress;
      inputLatencyQueueMicrotask(_markRenderEnd);
      _scheduleRecordIfFinishedTask(); // Schedule Task B
    }
  }

  /// 1:1: `function markRenderEnd()`
  static void _markRenderEnd() {
    if (_state['render'] == _inProgress) {
      inputLatencyPerformance.mark('render/end');
      _state['render'] = _finished;
    }
  }

  /// 1:1: `function scheduleRecordIfFinishedTask()`
  static void _scheduleRecordIfFinishedTask() {
    inputLatencySetTimeout(recordIfFinished);
  }

  /// 1:1: `function recordIfFinished()`
  static void recordIfFinished() {
    if (_state['keydown'] == _finished &&
        _state['input'] == _finished &&
        _state['render'] == _finished) {
      inputLatencyPerformance.mark('inputlatency/end');

      inputLatencyPerformance.measure('keydown', 'keydown/start', 'keydown/end');
      inputLatencyPerformance.measure('input', 'input/start', 'input/end');
      inputLatencyPerformance.measure('render', 'render/start', 'render/end');
      inputLatencyPerformance.measure(
          'inputlatency', 'inputlatency/start', 'inputlatency/end');

      _addMeasure('keydown', _totalKeydownTime);
      _addMeasure('input', _totalInputTime);
      _addMeasure('render', _totalRenderTime);
      _addMeasure('inputlatency', _totalInputLatencyTime);

      _measurementsCount++;
      sampleCount.set(sampleCount.get() + 1, null, null);

      _reset();
    }
  }

  /// 1:1: `function addMeasure(entryName, cumulativeMeasurement)`
  static void _addMeasure(
      String entryName, ICumulativeMeasurement cumulativeMeasurement) {
    final entries = inputLatencyPerformance.getEntriesByName(entryName);
    final num duration = entries.isEmpty ? 0 : entries[0].duration;
    cumulativeMeasurement.total += duration;
    cumulativeMeasurement.min = min(cumulativeMeasurement.min, duration);
    cumulativeMeasurement.max = max(cumulativeMeasurement.max, duration);
  }

  /// 1:1: `function reset()`
  static void _reset() {
    for (final name in const <String>[
      'keydown/start',
      'keydown/end',
      'input/start',
      'input/end',
      'render/start',
      'render/end',
      'inputlatency/start',
      'inputlatency/end',
    ]) {
      inputLatencyPerformance.clearMarks(name);
    }
    for (final name in const <String>[
      'keydown',
      'input',
      'render',
      'inputlatency',
    ]) {
      inputLatencyPerformance.clearMeasures(name);
    }
    _state['keydown'] = _before;
    _state['input'] = _before;
    _state['render'] = _before;
  }

  /// 1:1: `export function getAndClearMeasurements(): IInputLatencyMeasurements | undefined`
  /// Returns a Map carrier, or `null` for the TS `undefined` case.
  static Map<String, Object?>? getAndClearMeasurements() {
    if (_measurementsCount == 0) {
      return null;
    }

    final Map<String, Object?> result = <String, Object?>{
      'keydown': _cumulativeToFinalMeasurement(_totalKeydownTime),
      'input': _cumulativeToFinalMeasurement(_totalInputTime),
      'render': _cumulativeToFinalMeasurement(_totalRenderTime),
      'total': _cumulativeToFinalMeasurement(_totalInputLatencyTime),
      'sampleCount': _measurementsCount,
    };

    _clearCumulativeMeasurement(_totalKeydownTime);
    _clearCumulativeMeasurement(_totalInputTime);
    _clearCumulativeMeasurement(_totalRenderTime);
    _clearCumulativeMeasurement(_totalInputLatencyTime);
    _measurementsCount = 0;

    return result;
  }

  /// 1:1: `function cumulativeToFinalMeasurement(cumulative)`
  static Map<String, num> _cumulativeToFinalMeasurement(
      ICumulativeMeasurement cumulative) {
    return <String, num>{
      'average': cumulative.total / _measurementsCount,
      'max': cumulative.max,
      'min': cumulative.min,
    };
  }

  /// 1:1: `function clearCumulativeMeasurement(cumulative)`
  static void _clearCumulativeMeasurement(ICumulativeMeasurement cumulative) {
    cumulative.total = 0;
    cumulative.min = double.maxFinite;
    cumulative.max = 0;
  }
}
