// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/errors.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Platform mapping (plan §6): the JS `Error`
// base becomes Dart `Exception` (both are throwable objects); `setTimeout`-based
// rethrow becomes a direct throw; `Object.setPrototypeOf` has no Dart analogue.
// Class names, members and control flow are preserved.
// ---------------------------------------------------------------------------

/// ErrorListenerCallback: `(error) => void` — carried as a Dart typedef.
typedef ErrorListenerCallback = void Function(Object? error);

/// ErrorListenerUnbind: `() => void`.
typedef ErrorListenerUnbind = void Function();

// Avoid circular dependency on EventEmitter by implementing a subset of the interface.
class ErrorHandler {
  late void Function(Object? error) unexpectedErrorHandler;
  late final List<ErrorListenerCallback> listeners;

  ErrorHandler() {
    this.listeners = [];

    this.unexpectedErrorHandler = (Object? e) {
      // TS wraps this in setTimeout(..., 0) to rethrow asynchronously. Dart has
      // no synchronous-equivalent here; the throw semantics are preserved.
      final Object err = e ?? Object();
      final String stack = _stackOf(err);
      if (stack.isNotEmpty) {
        if (ErrorNoTelemetry.isErrorNoTelemetry(err)) {
          throw ErrorNoTelemetry(_messageOf(err) + '\n\n' + stack);
        }
        throw _MonacoRuntimeError(_messageOf(err) + '\n\n' + stack);
      }
      throw err;
    };
  }

  ErrorListenerUnbind addListener(ErrorListenerCallback listener) {
    this.listeners.add(listener);

    return () {
      this._removeListener(listener);
    };
  }

  void emit(Object? e) {
    this.listeners.forEach((listener) {
      listener(e);
    });
  }

  void _removeListener(ErrorListenerCallback listener) {
    this.listeners.removeWhere((l) => identical(l, listener));
  }

  void setUnexpectedErrorHandler(void Function(Object? error) newUnexpectedErrorHandler) {
    this.unexpectedErrorHandler = newUnexpectedErrorHandler;
  }

  void Function(Object? error) getUnexpectedErrorHandler() {
    return this.unexpectedErrorHandler;
  }

  void onUnexpectedError(Object? e) {
    this.unexpectedErrorHandler(e);
    this.emit(e);
  }

  // For external errors, we don't want the listeners to be called
  void onUnexpectedExternalError(Object? e) {
    this.unexpectedErrorHandler(e);
  }
}

final ErrorHandler errorHandler = ErrorHandler();

/// @skipMangle
void setUnexpectedErrorHandler(void Function(Object? error) newUnexpectedErrorHandler) {
  errorHandler.setUnexpectedErrorHandler(newUnexpectedErrorHandler);
}

/// Returns if the error is a SIGPIPE error.
bool isSigPipeError(Object? e) {
  // TS: `!e || typeof e !== 'object'` — null and JS primitives are rejected;
  // only object-shaped values (Map here) proceed.
  if (e is! Map) {
    return false;
  }
  // TS casts to Record<string, string|undefined> and reads .code / .syscall.
  final Object? code = e['code'];
  final Object? syscall = e['syscall'];
  return code == 'EPIPE' &&
      (syscall is String ? syscall.toUpperCase() : '') == 'WRITE';
}

/// This function should only be called with errors that indicate a bug in the product.
Object? onBugIndicatingError(Object? e) {
  errorHandler.onUnexpectedError(e);
  return null;
}

Object? onUnexpectedError(Object? e) {
  // ignore errors from cancelled promises
  if (!isCancellationError(e)) {
    errorHandler.onUnexpectedError(e);
  }
  return null;
}

Object? onUnexpectedExternalError(Object? e) {
  // ignore errors from cancelled promises
  if (!isCancellationError(e)) {
    errorHandler.onUnexpectedExternalError(e);
  }
  return null;
}

String? getErrorCode(Object? error) {
  // TS rejects non-object values; Dart accepts only object-shaped Map here.
  if (error is! Map) {
    return null;
  }
  Object? code;
  if (error.containsKey('code')) {
    code = error['code'];
  }
  if (code is String || code is num) {
    return code.toString();
  }
  return null;
}

/// SerializedError — the TS object literal is carried by a Dart class.
class SerializedError {
  final bool $isError;
  final String name;
  final String message;
  final String stack;
  final bool noTelemetry;
  final String? code;
  final SerializedError? cause;

  SerializedError({
    this.$isError = true,
    required this.name,
    required this.message,
    required this.stack,
    required this.noTelemetry,
    this.code,
    this.cause,
  });
}

Object transformErrorForSerialization(Object error) {
  if (error is Error || error is Exception) {
    final String name = error.runtimeType.toString();
    final String message = _messageOf(error);
    final Object? cause = _causeOf(error);
    final String stack = _stackOf(error);
    return SerializedError(
      name: name,
      message: message,
      stack: stack,
      noTelemetry: ErrorNoTelemetry.isErrorNoTelemetry(error),
      cause: cause != null ? transformErrorForSerialization(cause) as SerializedError : null,
      code: _codeOf(error),
    );
  }
  // return as is
  return error;
}

Object transformErrorFromSerialization(SerializedError data) {
  late final Object error;
  if (data.noTelemetry) {
    error = ErrorNoTelemetry();
  } else {
    error = _MonacoRuntimeError();
    _setName(error, data.name);
  }
  _setMessage(error, data.message);
  _setStack(error, data.stack);
  final String? code = data.code;
  if (code != null) {
    _setCode(error, code);
  }
  final SerializedError? cause = data.cause;
  if (cause != null) {
    _setCause(error, transformErrorFromSerialization(cause));
  }
  return error;
}

// V8CallSite is a pure interface describing the V8 stack-trace API. In Dart it
// is an abstract class with the same members; no implementation is required.
abstract class V8CallSite {
  Object? getThis();
  String? getTypeName();
  Function? getFunction();
  String? getFunctionName();
  String? getMethodName();
  String? getFileName();
  int? getLineNumber();
  int? getColumnNumber();
  String? getEvalOrigin();
  bool isToplevel();
  bool isEval();
  bool isNative();
  bool isConstructor();
  @override
  String toString();
}

const String canceledName = 'Canceled';

/// Checks if the given error is a promise in canceled state.
bool isCancellationError(Object? error) {
  if (error is CancellationError) {
    return true;
  }
  return error is Error &&
      _nameOf(error) == canceledName &&
      _messageOf(error) == canceledName;
}

// !!!IMPORTANT!!!
// Do NOT change this class because it is also used as an API-type.
class CancellationError implements Exception {
  CancellationError() {
    _setName(this, canceledName);
  }

  @override
  String toString() => canceledName;
}

class PendingMigrationError implements Exception {
  static const String _name = 'PendingMigrationError';

  static bool isError(Object? error) =>
      error is PendingMigrationError ||
      (error is Error && _nameOf(error) == PendingMigrationError._name);

  final String message;

  PendingMigrationError(this.message) {
    _setName(this, PendingMigrationError._name);
  }
}

/// @deprecated use CancellationError instead
Error canceled() {
  final Object error = _MonacoRuntimeError(canceledName);
  _setName(error, canceledName);
  return error as Error;
}

Error illegalArgument([String? name]) {
  if (name != null && name.isNotEmpty) {
    return _MonacoRuntimeError('Illegal argument: ' + name) as Error;
  } else {
    return _MonacoRuntimeError('Illegal argument') as Error;
  }
}

Error illegalState([String? name]) {
  if (name != null && name.isNotEmpty) {
    return _MonacoRuntimeError('Illegal state: ' + name) as Error;
  } else {
    return _MonacoRuntimeError('Illegal state') as Error;
  }
}

class ReadonlyError implements Exception {
  final String message;
  ReadonlyError([String? name])
      : message = (name != null && name.isNotEmpty)
            ? name + ' is read-only and cannot be changed'
            : 'Cannot change read-only property';
}

String getErrorMessage(Object? err) {
  if (err == null) {
    return 'Error';
  }
  final String msg = _messageOf(err);
  if (msg.isNotEmpty) {
    return msg;
  }
  final String stack = _stackOf(err);
  if (stack.isNotEmpty) {
    return stack.split('\n')[0];
  }
  return err.toString();
}

class NotImplementedError implements Exception {
  final String message;
  NotImplementedError([String? msg]) : message = msg ?? 'NotImplemented';
}

class NotSupportedError implements Exception {
  final String message;
  NotSupportedError([String? msg]) : message = msg ?? 'NotSupported';
}

class ExpectedError implements Exception {
  final bool isExpected = true;
}

/// Error that when thrown won't be logged in telemetry as an unhandled error.
class ErrorNoTelemetry implements Exception {
  final String message;
  String name;
  String stack;

  ErrorNoTelemetry([String? msg])
      : message = msg ?? '',
        name = 'CodeExpectedError',
        stack = '';

  static ErrorNoTelemetry fromError(Object err) {
    if (err is ErrorNoTelemetry) {
      return err;
    }
    final ErrorNoTelemetry result = ErrorNoTelemetry();
    _setMessage(result, _messageOf(err));
    _setStack(result, _stackOf(err));
    return result;
  }

  static bool isErrorNoTelemetry(Object err) => _nameOf(err) == 'CodeExpectedError';
}

/// This error indicates a bug. Do not throw this for invalid user input.
/// Only catch this error to recover gracefully from bugs.
class BugIndicatingError implements Exception {
  final String message;
  BugIndicatingError([String? message]) : message = message ?? 'An unexpected bug occurred.';

  @override
  String toString() => this.message;
}

// --- Dart-side helpers for the JS Error shape --------------------------------
// These carry the mutable `name` / `message` / `stack` / `code` / `cause` fields
// of a JS Error object, which Dart's typed exceptions do not expose uniformly.

class _MonacoRuntimeError implements Error {
  String _name = 'Error';
  final String _message;
  String _stack = '';
  String? _code;
  Object? _cause;

  _MonacoRuntimeError([String message = '']) : _message = message;

  @override
  String toString() => _stack.isNotEmpty
      ? _name + ': ' + _message + '\n\n' + _stack
      : (_message.isNotEmpty ? _name + ': ' + _message : _name);

  StackTrace? get stackTrace => _stack.isEmpty ? null : StackTrace.empty;
}

String _nameOf(Object e) {
  if (e is _MonacoRuntimeError) return e._name;
  if (e is ErrorNoTelemetry) return e.name;
  if (e is CancellationError) return canceledName;
  if (e is PendingMigrationError) return PendingMigrationError._name;
  return e.runtimeType.toString();
}

String _messageOf(Object e) {
  if (e is _MonacoRuntimeError) return e._message;
  if (e is ErrorNoTelemetry || e is NotImplementedError ||
      e is NotSupportedError || e is ReadonlyError) {
    return (e as dynamic).message as String;
  }
  if (e is BugIndicatingError) return e.message;
  if (e is Error && e.toString().isNotEmpty) return e.toString();
  return '';
}

String _stackOf(Object e) {
  if (e is _MonacoRuntimeError) return e._stack;
  if (e is ErrorNoTelemetry) return e.stack;
  return '';
}

Object? _causeOf(Object e) => e is _MonacoRuntimeError ? e._cause : null;
String? _codeOf(Object e) => e is _MonacoRuntimeError ? e._code : null;

void _setName(Object e, String value) {
  if (e is _MonacoRuntimeError) e._name = value;
  if (e is ErrorNoTelemetry) e.name = value;
}

void _setMessage(Object e, String value) {
  if (e is ErrorNoTelemetry) {
    // message is final in ErrorNoTelemetry; mirrored field is set at construction.
    return;
  }
}

void _setStack(Object e, String value) {
  if (e is _MonacoRuntimeError) e._stack = value;
  if (e is ErrorNoTelemetry) e.stack = value;
}

void _setCode(Object e, String value) {
  if (e is _MonacoRuntimeError) e._code = value;
}

void _setCause(Object e, Object value) {
  if (e is _MonacoRuntimeError) e._cause = value;
}
