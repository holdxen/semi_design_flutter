// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/performance.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. JS globals (`globalThis`/`performance`/
// `process`) have no Dart equivalent: the `globalThis`-backed shared singleton
// becomes a library-level instance; the polyfill uses `DateTime.now()` as the
// `Date.now()` equivalent. Control flow and the mark data layout are identical.
// ---------------------------------------------------------------------------

class PerformanceMark {
  final String name;
  final num startTime;
  PerformanceMark(this.name, this.startTime);
}

class _MarksApi {
  final List<Object?> _data = <Object?>[];

  _MarksApi(num? timeOrigin) {
    if (timeOrigin != null) {
      _data.add('code/timeOrigin');
      _data.add(timeOrigin);
    }
  }

  void mark(String name, [Object? markOptions]) {
    num? start;
    if (markOptions is Map && markOptions['startTime'] != null) {
      start = markOptions['startTime'] as num;
    }
    _data.add(name);
    _data.add(start ?? DateTime.now().millisecondsSinceEpoch);
  }

  List<PerformanceMark> getMarks() {
    final List<PerformanceMark> result = <PerformanceMark>[];
    for (int i = 0; i < _data.length; i += 2) {
      result.add(PerformanceMark(_data[i] as String, _data[i + 1] as num));
    }
    return result;
  }

  void clearMarks([String? name]) {
    if (name == null) {
      final bool hasTimeOrigin = _data.length >= 2 && _data[0] == 'code/timeOrigin';
      final Object? timeOriginValue = hasTimeOrigin ? _data[1] : null;
      _data.clear();
      if (hasTimeOrigin) {
        _data.add('code/timeOrigin');
        _data.add(timeOriginValue);
      }
    } else {
      for (int i = _data.length - 2; i >= 0; i -= 2) {
        if (_data[i] == name) {
          _data.removeRange(i, i + 2);
        }
      }
    }
  }
}

_MarksApi _definePolyfillMarks([num? timeOrigin]) => _MarksApi(timeOrigin);

// Dart VM: no browser `performance` object and no Node `process`; the source's
// browser/native and node branches are unreachable here, so take the polyfill.
_MarksApi _define() => _definePolyfillMarks();

final _MarksApi perf = _define();

final void Function(String name, [Object? markOptions]) mark = perf.mark;

/// Clears performance marks. If a name is given, only marks with that exact
/// name are removed. If no name is given, all marks are removed.
final void Function([String? name]) clearMarks = perf.clearMarks;

/// Returns all marks, sorted by `startTime`.
final List<PerformanceMark> Function() getMarks = perf.getMarks;
