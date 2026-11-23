// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/errorMessage.ts
// Translated 1:1 from TypeScript.
//   - `any` exception/errors -> dynamic field access.
//   - `nls.localize(key, msg, ...args)` -> localize(key, msg, [args]).
// ---------------------------------------------------------------------------

import '../../nls.dart' as nls;
import 'actions.dart';
import 'arrays.dart';
import 'types.dart' as types;

/// JS property access on an arbitrary value returns `undefined` for a missing
/// member; Dart throws `NoSuchMethodError`. These helpers reproduce the JS
/// semantics used throughout the source's `any`-typed exception handling.
dynamic _stack(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.stack;
  } on NoSuchMethodError {
    return null;
  }
}

dynamic _stacktrace(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.stacktrace;
  } on NoSuchMethodError {
    return null;
  }
}

dynamic _code(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.code;
  } on NoSuchMethodError {
    return null;
  }
}

dynamic _errno(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.errno;
  } on NoSuchMethodError {
    return null;
  }
}

dynamic _syscall(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.syscall;
  } on NoSuchMethodError {
    return null;
  }
}

dynamic _message(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.message;
  } on NoSuchMethodError {
    return null;
  }
}

dynamic _detail(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.detail;
  } on NoSuchMethodError {
    return null;
  }
}

dynamic _innerError(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.error;
  } on NoSuchMethodError {
    return null;
  }
}

dynamic _innerException(dynamic o) {
  try {
    // ignore: avoid_dynamic_calls
    return o.exception;
  } on NoSuchMethodError {
    return null;
  }
}

/// 1:1: `function exceptionToErrorMessage`
String exceptionToErrorMessage(dynamic exception, bool verbose) {
  final dynamic stack = _stack(exception);
  final dynamic stacktrace = _stacktrace(exception);
  if (verbose && (stack != null || stacktrace != null)) {
    return nls.localize('stackTrace.format', '{0}: {1}', [
      detectSystemErrorMessage(exception),
      stackToString(stack) ?? stackToString(stacktrace) ?? '',
    ]);
  }

  return detectSystemErrorMessage(exception);
}

/// 1:1: `function stackToString`
String? stackToString(dynamic stack) {
  if (stack is List) {
    return stack.join('\n');
  }
  if (stack is String) {
    return stack;
  }
  return null;
}

/// 1:1: `function detectSystemErrorMessage`
String detectSystemErrorMessage(dynamic exception) {
  if (exception == null) {
    return nls.localize('error.defaultMessage',
        'An unknown error occurred. Please consult the log for more details.');
  }

  // Custom node.js error from us
  final dynamic code = _code(exception);
  if (code == 'ERR_UNC_HOST_NOT_ALLOWED') {
    return "${_message(exception)}. Please update the 'security.allowedUNCHosts' setting if you want to allow this host.";
  }

  // See https://nodejs.org/api/errors.html#errors_class_system_error
  final dynamic errno = _errno(exception);
  final dynamic syscall = _syscall(exception);
  if (code is String && errno is num && syscall is String) {
    return nls.localize('nodeExceptionMessage', 'A system error occurred ({0})',
        [_message(exception)]);
  }

  final dynamic message = _message(exception);
  return (message is String && message.isNotEmpty)
      ? message
      : nls.localize('error.defaultMessage',
          'An unknown error occurred. Please consult the log for more details.');
}

/// 1:1: `export function toErrorMessage`
String toErrorMessage([dynamic error, bool verbose = false]) {
  if (error == null || error == false || error == '') {
    return nls.localize('error.defaultMessage',
        'An unknown error occurred. Please consult the log for more details.');
  }

  if (error is List) {
    final List<dynamic> errors = coalesce(error.cast<dynamic>());
    final String msg = toErrorMessage(errors.isEmpty ? null : errors[0], verbose);

    if (errors.length > 1) {
      return nls.localize('error.moreErrors', '{0} ({1} errors in total)',
          [msg, errors.length]);
    }

    return msg;
  }

  if (types.isString(error)) {
    return error as String;
  }

  final dynamic detail = _detail(error);
  if (detail != null) {
    final dynamic detailError = _innerError(detail);
    if (detailError != null) {
      return exceptionToErrorMessage(detailError, verbose);
    }
    final dynamic detailException = _innerException(detail);
    if (detailException != null) {
      return exceptionToErrorMessage(detailException, verbose);
    }
  }

  final dynamic stack = _stack(error);
  if (stack != null) {
    return exceptionToErrorMessage(error, verbose);
  }

  final dynamic message = _message(error);
  if (message != null) {
    return '$message';
  }

  return nls.localize('error.defaultMessage',
      'An unknown error occurred. Please consult the log for more details.');
}

/// 1:1: `export interface IErrorWithActions extends Error`
class IErrorWithActions implements Exception {
  final String message;
  List<IAction> actions;

  IErrorWithActions(this.message, this.actions);

  @override
  String toString() => message;
}

/// 1:1: `export function isErrorWithActions`
bool isErrorWithActions(Object? obj) => obj is IErrorWithActions;

/// 1:1: `export function createErrorWithActions`
IErrorWithActions createErrorWithActions(
    Object messageOrError, List<IAction> actions) {
  final IErrorWithActions error;
  if (messageOrError is String) {
    error = IErrorWithActions(messageOrError, actions);
  } else {
    error = messageOrError as IErrorWithActions;
  }

  error.actions = actions;

  return error;
}
