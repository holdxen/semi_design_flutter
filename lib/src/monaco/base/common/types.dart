// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/types.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS type-only constructs that have no Dart
// runtime counterpart (type predicates `x is T`, `asserts` predicates, mapped /
// conditional types: AtLeastOne, OmitOptional, Mutable, DeepImmutable,
// AddFirstParameterToFunctions, WithDefinedProps, DeepRequiredNonNullable,
// DeepPartial, PartialExcept, hasKey's narrow type) are listed in the comment
// block at the bottom and are intentionally not emitted as classes: they carry
// no runtime behavior. All runtime functions and their control flow are ported.
// ---------------------------------------------------------------------------

import './assert.dart' as assert_;

/// @returns whether the provided parameter is a String.
bool isString(Object? str) => str is String;

/// @returns whether the provided parameter is a List and each element is a String.
bool isStringArray(Object? value) => isArrayOf(value, isString);

/// @returns whether the provided parameter is a List and each element satisfies [check].
bool isArrayOf<T>(Object? value, bool Function(Object? item) check) =>
    value is List && value.every(check);

/// @returns whether the parameter is an object but not null/array/regexp/date.
/// Dart's closest counterpart to a JS plain object is [Map].
bool isObject(Object? obj) =>
    obj is Map && obj is! List && obj is! RegExp && obj is! DateTime;

/// @returns whether the provided parameter is a typed array (Uint8List etc.)
bool isTypedArray(Object? obj) => obj is List<int>;

/// In contrast to just checking `typeof` this returns false for NaN.
bool isNumber(Object? obj) => obj is num && !obj.isNaN;

/// @returns whether the provided parameter is an Iterable.
bool isIterable<T>(Object? obj) => obj is Iterable;

/// @returns whether the provided parameter is an AsyncIterable.
bool isAsyncIterable<T>(Object? obj) => obj is Stream;

/// @returns whether the provided parameter is a bool.
bool isBoolean(Object? obj) => obj is bool;

/// @returns whether the provided parameter is null (Dart has no `undefined`;
/// null covers both JS `undefined` and `null`).
bool isUndefined(Object? obj) => obj == null;

/// @returns whether the provided parameter is defined (non-null).
bool isDefined<T>(T? arg) => !isUndefinedOrNull(arg);

/// @returns whether the provided parameter is null (covers JS undefined|null).
bool isUndefinedOrNull(Object? obj) => obj == null;

void assertType(Object? condition, [String? type]) {
  if (condition == null || condition == false) {
    throw StateError(type != null ? "Unexpected type, expected '$type'" : 'Unexpected type');
  }
}

/// Asserts that the argument passed in is neither null.
T assertReturnsDefined<T>(T? arg) {
  assert_.assertCondition(arg != null, 'Argument is `undefined` or `null`.');
  return arg!;
}

/// Asserts that a provided value is defined, throwing [error] if null.
void assertDefined<T>(T? value, Object error) {
  if (value == null) {
    final Object errorToThrow = error is String ? StateError(error) : error;
    throw errorToThrow;
  }
}

/// Asserts that each argument passed in is neither null.
List<Object?> assertReturnsAllDefined(List<Object?> args) {
  final Object? result = [];
  final List<Object?> out = result as List<Object?>;

  for (int i = 0; i < args.length; i++) {
    final Object? arg = args[i];

    if (isUndefinedOrNull(arg)) {
      throw StateError('Assertion Failed: argument at index $i is undefined or null');
    }

    out.add(arg);
  }

  return out;
}

/// Checks if the provided value is one of the values in the provided list.
bool isOneOf<TType>(TType value, List<TType> validValues) => validValues.contains(value);

/// Compile-time type check (no-op at runtime).
void typeCheck<T>(Object? thing) {}

/// @returns whether the provided parameter is an empty Object (Map with no keys).
bool isEmptyObject(Object? obj) {
  if (!isObject(obj)) {
    return false;
  }
  return (obj as Map).isEmpty;
}

/// @returns whether the provided parameter is a Function.
bool isFunction(Object? obj) => obj is Function;

/// @returns whether the provided parameters are Functions.
bool areFunctions(List<Object?> objects) =>
    objects.isNotEmpty && objects.every(isFunction);

/// Type constraint: a String (typeof) or a Function (instanceof/constructor/call).
typedef TypeConstraint = Object;

void validateConstraints(List<Object?> args, List<TypeConstraint?> constraints) {
  final int len = args.length < constraints.length ? args.length : constraints.length;
  for (int i = 0; i < len; i++) {
    validateConstraint(args[i], constraints[i]);
  }
}

void validateConstraint(Object? arg, TypeConstraint? constraint) {
  if (isString(constraint)) {
    final String c = constraint as String;
    final String actual = arg is String
        ? 'string'
        : arg is num
            ? 'number'
            : arg is bool
                ? 'boolean'
                : arg is Function
                    ? 'function'
                    : 'object';
    if (actual != c) {
      throw StateError('argument does not match constraint: typeof $c');
    }
  } else if (isFunction(constraint)) {
    final Function fn = constraint as Function;
    try {
      if (arg != null && _instanceOf(arg, fn)) {
        return;
      }
    } catch (_) {
      // ignore
    }
    if (!isUndefinedOrNull(arg) && arg.runtimeType == fn) {
      return;
    }
    if (_callPredicateWithOneArg(fn, arg) == true) {
      return;
    }
    throw StateError('argument does not match one of these constraints: arg instanceof constraint, arg.constructor === constraint, nor constraint(arg) === true');
  }
}

bool _instanceOf(Object arg, Function type) => arg.runtimeType == type;

Object? _callPredicateWithOneArg(Function fn, Object? arg) {
  try {
    return Function.apply(fn, [arg]);
  } catch (_) {
    return false;
  }
}

/// Helper type assertion that safely upcasts a type to a supertype.
Base upcast<Base, Sub extends Base>(Sub x) => x;

/// Type guard that checks if an object has specific keys.
bool hasKey(Map<dynamic, dynamic> x, Map<dynamic, dynamic> key) {
  for (final dynamic k in key.keys) {
    if (!x.containsKey(k)) {
      return false;
    }
  }
  return true;
}

// ---------------------------------------------------------------------------
// TS type-only declarations with no Dart runtime counterpart (not emitted):
//   AddFirstParameterToFunctions, AtLeastOne, OmitOptional, Mutable,
//   DeepImmutable, SingleOrMany, WithDefinedProps, DeepRequiredNonNullable,
//   DeepPartial, PartialExcept, TypeConstraint (represented as Object above).
// Type predicates (`obj is T`) are expressed as `bool` functions + Dart `is`.
// ---------------------------------------------------------------------------
