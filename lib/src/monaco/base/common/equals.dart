// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/equals.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations:
//   - `a === b` -> Dart `==` (value equality for primitives, identity for objects)
//   - JS plain object (Object.getPrototypeOf(x) === Object.prototype) -> Dart Map
//   - WeakMap<object, number> -> HashMap.identity() (Dart has no weak refs)
//   - JSON.stringify -> jsonEncode
//   - `namespace equals` -> top-level class `Equals` with static members
// ---------------------------------------------------------------------------

import 'dart:collection';
import 'dart:convert';

import 'arrays.dart' as arrays;

/// 1:1: `export type EqualityComparer<T> = (a: T, b: T) => boolean`
typedef EqualityComparer<T> = bool Function(T a, T b);

/// 1:1: `export interface IEquatable<T> { equals(other: T): boolean; }`
abstract class IEquatable<T> {
  bool equals(T other);
}

/// 1:1: `export function strictEquals<T>(a, b): boolean`
bool strictEquals<T>(T a, T b) => a == b;

/// 1:1: `export function strictEqualsC<T>(): EqualityComparer<T>`
EqualityComparer<T> strictEqualsC<T>() => (T a, T b) => a == b;

/// 1:1: `export function arrayEquals<T>(a, b, itemEquals?)`
bool arrayEquals<T>(List<T> a, List<T> b, [EqualityComparer<T>? itemEquals]) =>
    arrays.equals(a, b, itemEquals ?? strictEquals);

/// 1:1: `export function arrayEqualsC<T>(itemEquals?): EqualityComparer<readonly T[]>`
EqualityComparer<List<T>> arrayEqualsC<T>([EqualityComparer<T>? itemEquals]) =>
    (List<T> a, List<T> b) => arrays.equals(a, b, itemEquals ?? strictEquals);

/// 1:1: `export function structuralEquals<T>(a, b): boolean`
///
/// JS arrays -> Dart List, JS plain objects -> Dart Map. Everything else uses
/// strict (value/reference) equality, matching the source's final `return false`.
bool structuralEquals<T>(T a, T b) {
  if (a == b) {
    return true;
  }

  if (a is List && b is List) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (!structuralEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }

  if (a is Map && b is Map) {
    final Map<dynamic, dynamic> aObj = a;
    final Map<dynamic, dynamic> bObj = b;
    final List<dynamic> keysA = aObj.keys.toList();
    final List<dynamic> keysB = bObj.keys.toList();
    final Set<dynamic> keysBSet = keysB.toSet();

    if (keysA.length != keysB.length) {
      return false;
    }

    for (final dynamic key in keysA) {
      if (!keysBSet.contains(key)) {
        return false;
      }
      if (!structuralEquals(aObj[key], bObj[key])) {
        return false;
      }
    }

    return true;
  }

  return false;
}

/// 1:1: `export function structuralEqualsC<T>(): EqualityComparer<T>`
EqualityComparer<T> structuralEqualsC<T>() => (T a, T b) => structuralEquals(a, b);

/// 1:1: `export function getStructuralKey(t): string`
String getStructuralKey(Object? t) => jsonEncode(toNormalizedJsonStructure(t));

int objectId = 0;
final Map<Object, int> objIds = HashMap<Object, int>.identity();

/// 1:1: `function toNormalizedJsonStructure(t): unknown`
Object? toNormalizedJsonStructure(Object? t) {
  if (t is List) {
    return t.map(toNormalizedJsonStructure).toList();
  }

  // 1:1: `if (t && typeof t === 'object')` — only JS objects enter this branch;
  // primitives (number/string/boolean) fall through and are returned as-is.
  if (t != null && t is! num && t is! String && t is! bool) {
    if (t is Map) {
      final Map<String, Object?> res = <String, Object?>{};
      final List<String> keys = t.keys.map((dynamic k) => k.toString()).toList()..sort();
      for (final String key in keys) {
        res[key] = toNormalizedJsonStructure(t[key]);
      }
      return res;
    } else {
      int? id = objIds[t];
      if (id == null) {
        id = objectId++;
        objIds[t] = id;
      }
      // Random string to prevent collisions
      return '$id----2b76a038c20c4bcc';
    }
  }
  return t;
}

/// 1:1: `export function jsonStringifyEquals<T>(a, b): boolean`
bool jsonStringifyEquals<T>(T a, T b) => jsonEncode(a) == jsonEncode(b);

/// 1:1: `export function jsonStringifyEqualsC<T>(): EqualityComparer<T>`
EqualityComparer<T> jsonStringifyEqualsC<T>() => (T a, T b) => jsonEncode(a) == jsonEncode(b);

/// 1:1: `export function thisEqualsC<T extends IEquatable<T>>(): EqualityComparer<T>`
EqualityComparer<T> thisEqualsC<T extends IEquatable<T>>() => (T a, T b) => a.equals(b);

/// 1:1: `export function equalsIfDefined<T>(v1, v2, equals): boolean`
bool equalsIfDefined<T>(T? v1, T? v2, EqualityComparer<T> equals) {
  if (v1 == null || v2 == null) {
    return v2 == v1;
  }
  return equals(v1, v2);
}

/// 1:1: `export function equalsIfDefinedC<T>(equals): EqualityComparer<T | undefined | null>`
EqualityComparer<T?> equalsIfDefinedC<T>(EqualityComparer<T> equals) =>
    (T? v1, T? v2) {
      if (v1 == null || v2 == null) {
        return v2 == v1;
      }
      return equals(v1, v2);
    };

/// 1:1: `export namespace equals`
class Equals {
  static EqualityComparer<T> strict<T>() => strictEqualsC<T>();
  static bool strictValue<T>(T a, T b) => strictEquals(a, b);

  static EqualityComparer<List<T>> array<T>([EqualityComparer<T>? itemEquals]) =>
      arrayEqualsC<T>(itemEquals);

  static EqualityComparer<T> structural<T>() => structuralEqualsC<T>();

  static EqualityComparer<T> jsonStringify<T>() => jsonStringifyEqualsC<T>();

  static EqualityComparer<T> thisC<T extends IEquatable<T>>() => thisEqualsC<T>();

  static EqualityComparer<T?> ifDefined<T>(EqualityComparer<T> equals) =>
      equalsIfDefinedC<T>(equals);
}
