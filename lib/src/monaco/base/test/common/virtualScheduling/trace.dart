// 1:1 port of vs/base/test/common/virtualScheduling/trace.ts
//
// `Trace` is an immutable value identifying a causal chain. Dart has no JS
// `Error.stack` string field, so a captured error is carried as [CapturedStack]
// whose [stack] is the formatted string (deferred until diagnostics need it).

import '../../../common/errors.dart' show BugIndicatingError;

/// A captured error whose stack is formatted lazily. 1:1: the `Error` arm of
/// the source `stack: string | Error | undefined`.
class CapturedStack {
  final String stack;
  const CapturedStack(this.stack);
}

/// 1:1: `export class Trace`
class Trace {
  static int _idCounter = 0;

  /// Source: `public readonly id = ++Trace._idCounter` (1-based).
  final int id;
  final Trace? parent;
  final String label;
  final Object? _stack;

  /// The head of the chain (source: `readonly root: Trace`).
  late final Trace root;
  final int depth;

  Trace(this.parent, this.label, [this._stack])
      : id = ++Trace._idCounter,
        depth = (parent?.depth ?? -1) + 1 {
    // `this.root = parent?.root ?? this` — Dart cannot reference `this` in an
    // initializer list, so assign the self-reference in the constructor body.
    root = parent?.root ?? this;
  }

  /// Captured errors defer stack formatting until diagnostics need it.
  String? get stack {
    if (_stack is String) {
      return _stack;
    }
    if (_stack is CapturedStack) {
      return _stack.stack;
    }
    return null;
  }

  /// 1:1: `child(label, stack?)`
  Trace child(String label, [Object? stack]) => Trace(this, label, stack);

  /// "#id label ← #id label ← … ← #id label"
  String describe() {
    final List<String> parts = <String>[];
    for (Trace? t = this; t != null; t = t.parent) {
      parts.add('#${t.id} ${t.label}');
    }
    return parts.join(' \u2190 ');
  }

  @override
  String toString() => describe();
}

/// 1:1: `export const ROOT_TRACE: Trace = new Trace(undefined, '<root>')`
final Trace ROOT_TRACE = Trace(null, '<root>');

/// 1:1: `export function createTraceRoot`
Trace createTraceRoot(String label, [Object? stack]) =>
    Trace(null, label, stack);

/// 1:1: `interface Frame`
class Frame {
  final Trace trace;
  final Frame? prev;
  const Frame(this.trace, this.prev);
}

/// 1:1: `const ROOT_FRAME: Frame`
final Frame ROOT_FRAME = Frame(ROOT_TRACE, null);

/// 1:1: `export interface RunAsHandlerOptions`
///
/// The interface has a single method `afterMicrotaskClosure(reset)`, carried as
/// a callable typedef.
typedef RunAsHandlerOptions = void Function(void Function() reset);

/// 1:1: `export class TraceContext`
class TraceContext {
  /// 1:1: `public static readonly instance = new TraceContext()`
  static final TraceContext instance = TraceContext();

  Frame _current = ROOT_FRAME;
  bool _isHandlerRunning = false;

  Trace currentTrace() => _current.trace;

  /// Install [t] as current for the synchronous duration of [fn], then
  /// restore. Nestable.
  T runWithTrace<T>(Trace t, T Function() fn) {
    final Frame prev = _current;
    final Frame next = Frame(t, prev);
    _current = next;
    try {
      return fn();
    } finally {
      if (!identical(_current, next)) {
        throw BugIndicatingError('runWithTrace: unexpected mutation of current frame.');
      }
      _current = prev;
    }
  }

  /// Install [t] as current and run [fn]; the trace stays current through the
  /// microtask closure that follows [fn]. Reset is dispatched via
  /// [options.afterMicrotaskClosure].
  T runAsHandler<T>(Trace t, T Function() fn, RunAsHandlerOptions options) {
    if (_isHandlerRunning) {
      throw StateError(
        'runAsHandler: re-entrant invocation. '
        'current=${_current.trace.describe()}, incoming=${t.describe()}',
      );
    }
    final Frame prev = _current;
    final Frame next = Frame(t, prev);
    _current = next;
    _isHandlerRunning = true;
    try {
      return fn();
    } finally {
      _isHandlerRunning = false;
      options(() {
        // Identity guard: another handler may have run between us queuing this
        // reset and it firing. Each run mints a fresh frame, so reference
        // equality detects staleness.
        if (identical(_current, next)) {
          _current = prev;
        }
      });
    }
  }

  /// 1:1: `_resetForTesting()`
  void resetForTesting() {
    _current = ROOT_FRAME;
    _isHandlerRunning = false;
  }
}
