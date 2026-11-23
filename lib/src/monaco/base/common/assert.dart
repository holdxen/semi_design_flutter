// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/assert.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. JS `throw new Error(msg)` -> Dart `StateError`
// (plain assertion failures) / `BugIndicatingError` (source used that type).
// TS `asserts condition` type predicate has no Dart equivalent and is dropped.
// JS function `assert(...)` -> `assertCondition(...)` because `assert` is a
// reserved keyword in Dart (cannot be a function name). Other names and the
// control flow are identical.
// ---------------------------------------------------------------------------

import './errors.dart';

/// Throws an error with the provided message if the provided value does not
/// evaluate to a truthy value.
///
/// @deprecated Use [assertCondition] instead.
void ok(Object? value, [String? message]) {
  if (value == null || value == false || value == 0 || value == '') {
    throw StateError(message != null ? 'Assertion failed ($message)' : 'Assertion Failed');
  }
}

/// Asserts a value is unreachable; always throws.
Never assertNever(Object value, [String message = 'Unreachable']) {
  throw StateError(message);
}

/// Soft version of [assertNever] - no-op.
void softAssertNever(Object value) {
  // no-op
}

/// Asserts that a condition is `truthy`.
///
/// Throws [messageOrError] if [condition] is falsy.
void assertCondition(
  bool condition, [
  Object messageOrError = 'unexpected state',
]) {
  if (!condition) {
    // if error instance is provided, use it, otherwise create a new one
    final Object errorToThrow = messageOrError is String
        ? BugIndicatingError('Assertion Failed: $messageOrError')
        : messageOrError;

    throw errorToThrow;
  }
}

/// Like [assertCondition], but doesn't throw.
void softAssert(bool condition, [String message = 'Soft Assertion Failed']) {
  if (!condition) {
    onUnexpectedError(BugIndicatingError(message));
  }
}

/// condition must be side-effect free!
void assertFn(bool Function() condition) {
  if (!condition()) {
    // Reevaluate `condition` again to make debugging easier
    condition();
    onUnexpectedError(BugIndicatingError('Assertion Failed'));
  }
}

bool checkAdjacentItems<T>(List<T> items, bool Function(T item1, T item2) predicate) {
  int i = 0;
  while (i < items.length - 1) {
    final T a = items[i];
    final T b = items[i + 1];
    if (!predicate(a, b)) {
      return false;
    }
    i++;
  }
  return true;
}
