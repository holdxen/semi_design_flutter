// 1:1 translation of
// vscode/src/vs/base/common/observableInternal/debugName.ts
// Mirrors DebugNameData, getDebugName/computeDebugName, findKey, formatOwner,
// getClassName and getFunctionName file-for-file.
// Platform adaptations: JS WeakMap -> identity HashMap (no weak refs in Dart);
// `for (const key in obj)` has no object-enumeration analogue, so Map owners are
// supported and other owners fall through, matching the `undefined` result.

import 'dart:collection';

/// 1:1: `export interface IDebugNameData`
abstract class IDebugNameData {
  Object? get owner;
  Object? get debugName;
  Function? get debugReferenceFn;
}

/// Value carrier for `IDebugNameData` object literals.
class DebugNameDataLike implements IDebugNameData {
  @override
  final Object? owner;
  @override
  final Object? debugName;
  @override
  final Function? debugReferenceFn;

  DebugNameDataLike({this.owner, this.debugName, this.debugReferenceFn});
}

/// 1:1: `export class DebugNameData`
class DebugNameData {
  final Object? owner;
  final Object? debugNameSource;
  final Function? referenceFn;

  DebugNameData(this.owner, this.debugNameSource, this.referenceFn);

  /// 1:1: `public getDebugName(target: object): string | undefined`
  /// Delegates to a private impl because the instance method shadows the
  /// top-level `getDebugName(target, data)` function in Dart name resolution.
  String? getDebugName(Object target) => _getDebugNameImpl(target, this);
}

/// 1:1: `export type DebugOwner = object | undefined`
typedef DebugOwner = Object?;

/// 1:1: `export type DebugNameSource = string | (() => string | undefined)`
typedef DebugNameSource = Object?;

final Map<String, int> countPerName = <String, int>{};
final Map<Object, String> cachedDebugName = HashMap<Object, String>.identity();

/// 1:1: `export function getDebugName(target, data): string | undefined`
String? getDebugName(Object target, DebugNameData data) =>
    _getDebugNameImpl(target, data);

String? _getDebugNameImpl(Object target, DebugNameData data) {
  final String? cached = cachedDebugName[target];
  if (cached != null) {
    return cached;
  }

  final String? dbgName = computeDebugName(target, data);
  if (dbgName != null) {
    int count = countPerName[dbgName] ?? 0;
    count++;
    countPerName[dbgName] = count;
    final String result = count == 1 ? dbgName : '$dbgName#$count';
    cachedDebugName[target] = result;
    return result;
  }
  return null;
}

/// 1:1: `function computeDebugName(self, data): string | undefined`
String? computeDebugName(Object self, DebugNameData data) {
  final String? cached = cachedDebugName[self];
  if (cached != null) {
    return cached;
  }

  final String ownerStr = data.owner != null ? '${formatOwner(data.owner!)}.' : '';

  String? result;
  final DebugNameSource debugNameSource = data.debugNameSource;
  if (debugNameSource != null) {
    if (debugNameSource is Function) {
      result = (debugNameSource() as Object?) as String?;
      if (result != null) {
        return ownerStr + result;
      }
    } else {
      return ownerStr + debugNameSource.toString();
    }
  }

  final Function? referenceFn = data.referenceFn;
  if (referenceFn != null) {
    result = getFunctionName(referenceFn);
    if (result != null) {
      return ownerStr + result;
    }
  }

  if (data.owner != null) {
    final String? key = findKey(data.owner!, self);
    if (key != null) {
      return ownerStr + key;
    }
  }
  return null;
}

/// 1:1: `function findKey(obj, value): string | undefined`
/// JS `for (const key in obj)` has no Dart analogue for arbitrary objects;
/// Map owners preserve the identity lookup, other owners return undefined.
String? findKey(Object obj, Object value) {
  if (obj is Map) {
    for (final Object? key in obj.keys) {
      if (identical(obj[key], value)) {
        return key.toString();
      }
    }
  }
  return null;
}

final Map<String, int> countPerClassName = <String, int>{};
final Map<Object, String> ownerId = HashMap<Object, String>.identity();

/// 1:1: `function formatOwner(owner): string`
String formatOwner(Object owner) {
  final String? id = ownerId[owner];
  if (id != null) {
    return id;
  }
  final String className = getClassName(owner) ?? 'Object';
  int count = countPerClassName[className] ?? 0;
  count++;
  countPerClassName[className] = count;
  final String result = count == 1 ? className : '$className#$count';
  ownerId[owner] = result;
  return result;
}

/// 1:1: `export function getClassName(obj): string | undefined`
String? getClassName(Object obj) {
  final Type ctor = obj.runtimeType;
  if (ctor == Object) {
    return null;
  }
  return ctor.toString();
}

/// 1:1: `export function getFunctionName(fn): string | undefined`
/// Dart closures do not carry the JSDoc source that the TS regex scans; the
/// regex and control flow are preserved, so annotated sources still match.
String? getFunctionName(Function fn) {
  final String fnSrc = fn.toString();
  final RegExp regexp = RegExp(r'/\*\*\s*@description\s*([^*]*)\*/');
  final RegExpMatch? match = regexp.firstMatch(fnSrc);
  final String? result = match?.group(1);
  return result?.trim();
}
