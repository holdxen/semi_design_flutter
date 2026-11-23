// 1:1 port of vs/base/test/common/virtualScheduling/traceLogger.ts
//
// Dart has no `fn.toString()` returning source text, so [_describeFn] reads a
// replaceable [functionSourceProvider]; the regex parsing is otherwise 1:1.
// `ITraceLogEntry extends LogEntryLike` in the source is carried as a standalone
// class here because the Dart port's `LogEntryLike.trace` is a `TraceLike`
// rather than the concrete `Trace` this logger tags each entry with.

import 'trace.dart' show Trace, TraceContext;

/// 1:1: `export interface ITraceLogger`
abstract class ITraceLogger {
  void log(String message);
  void warn(String message);
  void error(String message);
  T logRun<T>(T Function() fn);
}

/// 1:1: `export interface ITraceLogEntry`
abstract class ITraceLogEntry {
  Trace get trace;
  String get level;
  String get message;
}

/// Value carrier for [ITraceLogEntry].
class TraceLogEntry implements ITraceLogEntry {
  @override
  final Trace trace;
  @override
  final String level;
  @override
  final String message;

  TraceLogEntry({
    required this.trace,
    required this.level,
    required this.message,
  });
}

/// Source-text provider for [describeFn]. The embedder can supply the JS-style
/// `fn.toString()` text; default is empty (no wrapping to collapse).
String Function(Object fn) functionSourceProvider = (Object fn) => '';

/// 1:1: `export function createTraceLogger(buffer): ITraceLogger`
ITraceLogger createTraceLogger(List<ITraceLogEntry> buffer) {
  void Function(String) make(String level) => (String message) {
        buffer.add(TraceLogEntry(
          trace: TraceContext.instance.currentTrace(),
          level: level,
          message: level == 'log' ? message : '[$level] $message',
        ));
      };
  final void Function(String) log = make('log');

  return _TraceLogger(
    log: log,
    warn: make('warn'),
    error: make('error'),
    logRun: <T>(T Function() fn) {
      log('run: ${describeFn(fn)}');
      return fn();
    },
  );
}

class _TraceLogger implements ITraceLogger {
  final void Function(String) _log;
  final void Function(String) _warn;
  final void Function(String) _error;
  final T Function<T>(T Function() fn) _logRun;

  _TraceLogger({
    required void Function(String) log,
    required void Function(String) warn,
    required void Function(String) error,
    required T Function<T>(T Function() fn) logRun,
  })  : _log = log,
        _warn = warn,
        _error = error,
        _logRun = logRun;

  @override
  void log(String message) => _log(message);

  @override
  void warn(String message) => _warn(message);

  @override
  void error(String message) => _error(message);

  @override
  T logRun<T>(T Function() fn) => _logRun<T>(fn);
}

/// 1:1: `function _describeFn(fn)` — best-effort one-line description.
String describeFn(Object fn) {
  final String src = functionSourceProvider(fn);
  final RegExp arrow = RegExp(r'^\s*(?:async\s+)?\(\s*\)\s*=>\s*([\s\S]+?)\s*$');
  final Match? arrowMatch = arrow.firstMatch(src);
  if (arrowMatch != null) {
    return collapseWhitespace(arrowMatch.group(1)!);
  }
  final RegExp fnExpr = RegExp(
      r'^\s*(?:async\s+)?function\s*\w*\s*\(\s*\)\s*\{\s*([\s\S]+?)\s*\}\s*$');
  final Match? fnMatch = fnExpr.firstMatch(src);
  if (fnMatch != null) {
    return collapseWhitespace(fnMatch.group(1)!);
  }
  return collapseWhitespace(src);
}

/// 1:1: `function _collapseWhitespace(s)`
String collapseWhitespace(String s) =>
    s.replaceAll(RegExp(r'\s+'), ' ').trim();
