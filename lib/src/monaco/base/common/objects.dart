// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/objects.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `any` -> `Object?`; object literal ->
// `Map<String, Object?>`; array -> `List<Object?>`; `Object.entries/keys` ->
// `Map.entries/keys`; `for..in` + hasOwnProperty -> `Map` iteration;
// `typeof x === 'object'` -> `x is Map` (Dart has no `typeof`). JS `undefined`
// and `null` both map to Dart `null` (source treats them near-identically).
// `Object.freeze` -> identity `Set<Object>` marker; circular-safe JSON via a
// hand-written replacer mirroring the source algorithm (dart:convert's
// jsonEncode has no JS-style replacer `this` binding).
// ---------------------------------------------------------------------------

import 'dart:convert';

import './types.dart';

Object? deepClone(Object? obj) {
  if (obj == null || obj is! Map && obj is! List) {
    return obj;
  }
  if (obj is RegExp) {
    return obj;
  }
  final Object result = obj is List ? <Object?>[] : <String, Object?>{};
  if (result is List) {
    for (final Object? value in obj as List) {
      result.add(value != null && (value is Map || value is List) ? deepClone(value) : value);
    }
  } else {
    final Map<String, Object?> mapResult = result as Map<String, Object?>;
    (obj as Map).forEach((Object? key, Object? value) {
      mapResult[key as String] = value != null && (value is Map || value is List) ? deepClone(value) : value;
    });
  }
  return result;
}

/// Dart has no `Object.freeze`; a per-call identity set records frozen objects
/// so the traversal/shape/control-flow stays identical to the source.
Object? deepFreeze(Object? obj, [Set<Object>? frozen]) {
  if (obj == null || obj is! Map && obj is! List) {
    return obj;
  }
  final Set<Object> frozenSet = frozen ?? <Object>{};
  final List<Object?> stack = <Object?>[obj];
  for (int index = 0; index < stack.length; index++) {
    final Object? cur = stack[index];
    stack[index] = null;
    if (cur == null) {
      continue;
    }
    frozenSet.add(cur);
    if (cur is Map) {
      for (final Object? key in cur.keys) {
        final Object? prop = cur[key];
        if (prop != null && !frozenSet.contains(prop) && !isTypedArray(prop)) {
          stack.add(prop);
        }
      }
    } else if (cur is List) {
      for (final Object? prop in cur) {
        if (prop != null && !frozenSet.contains(prop) && !isTypedArray(prop)) {
          stack.add(prop);
        }
      }
    }
  }
  return obj;
}

Object? cloneAndChange(Object? obj, Object? Function(Object? orig) changer) {
  return _cloneAndChange(obj, changer, <Object>{});
}

Object? _cloneAndChange(Object? obj, Object? Function(Object? orig) changer, Set<Object> seen) {
  if (isUndefinedOrNull(obj)) {
    return obj;
  }

  final Object? changed = changer(obj);
  if (changed != null) {
    return changed;
  }

  if (obj is List) {
    final List<Object?> r1 = <Object?>[];
    for (final Object? e in obj) {
      r1.add(_cloneAndChange(e, changer, seen));
    }
    return r1;
  }

  if (isObject(obj)) {
    if (seen.contains(obj)) {
      throw StateError('Cannot clone recursive data-structure');
    }
    seen.add(obj!);
    final Map<String, Object?> r2 = <String, Object?>{};
    (obj as Map).forEach((Object? i2, Object? value) {
      r2[i2 as String] = _cloneAndChange(value, changer, seen);
    });
    seen.remove(obj);
    return r2;
  }

  return obj;
}

/// Copies all properties of source into destination. The optional parameter
/// "overwrite" allows to control if existing properties on the destination
/// should be overwritten or not. Defaults to true (overwrite).
Object? mixin(Object? destination, Object? source, [bool overwrite = true]) {
  if (!isObject(destination)) {
    return source;
  }

  if (isObject(source)) {
    final Map<String, Object?> destMap = destination as Map<String, Object?>;
    (source as Map).forEach((Object? key, Object? value) {
      final String k = key as String;
      if (destMap.containsKey(k)) {
        if (overwrite) {
          final Object? dv = destMap[k];
          if (isObject(dv) && isObject(value)) {
            mixin(dv, value, overwrite);
          } else {
            destMap[k] = value;
          }
        }
      } else {
        destMap[k] = value;
      }
    });
  }
  return destination;
}

bool equals(Object? one, Object? other) {
  if (identical(one, other)) {
    return true;
  }
  if (one == null || other == null) {
    return false;
  }
  if (one.runtimeType != other.runtimeType) {
    return false;
  }
  if (one is! Map && one is! List) {
    return false;
  }
  if ((one is List) != (other is List)) {
    return false;
  }

  int i;

  if (one is List) {
    final List<Object?> otherList = other as List<Object?>;
    if (one.length != otherList.length) {
      return false;
    }
    for (i = 0; i < one.length; i++) {
      if (!equals(one[i], otherList[i])) {
        return false;
      }
    }
  } else {
    final Map<String, Object?> oneMap = one as Map<String, Object?>;
    final Map<String, Object?> otherMap = other as Map<String, Object?>;
    final List<String> oneKeys = <String>[];

    for (final Object? k in oneMap.keys) {
      oneKeys.add(k as String);
    }
    oneKeys.sort();
    final List<String> otherKeys = <String>[];
    for (final Object? k in otherMap.keys) {
      otherKeys.add(k as String);
    }
    otherKeys.sort();
    if (!equals(oneKeys, otherKeys)) {
      return false;
    }
    for (i = 0; i < oneKeys.length; i++) {
      if (!equals(oneMap[oneKeys[i]], otherMap[oneKeys[i]])) {
        return false;
      }
    }
  }
  return true;
}

/// Calls `JSON.stringify` with a replacer to break apart any circular
/// references. This prevents stringify from throwing on circular structures.
String safeStringify(Object? obj) {
  // Track only current ancestors so shared sibling references are serialized in full.
  final List<Object?> ancestors = <Object?>[];
  return _jsonStringifyWithReplacer(obj, ancestors);
}

String _jsonStringifyWithReplacer(Object? value, List<Object?> ancestors) {
  Object? replacer(Object? holder, String key, Object? val) {
    if (val != null && (val is Map || val is List)) {
      // `this` is the object holding `key`, pop the subtrees that are already done
      while (ancestors.isNotEmpty && !identical(ancestors.last, holder)) {
        ancestors.removeLast();
      }
      if (ancestors.any((Object? a) => identical(a, val))) {
        return '[Circular]';
      }
      ancestors.add(val);
    }
    if (val is BigInt) {
      return '[BigInt ${val.toString()}]';
    }
    return val;
  }

  return _stringifyValue(value, null, '', ancestors, replacer);
}

String _stringifyValue(Object? value, Object? holder, String key, List<Object?> ancestors, Object? Function(Object?, String, Object?) replacer) {
  final Object? replaced = replacer(holder, key, value);
  if (replaced is Map) {
    final List<String> parts = <String>[];
    replaced.forEach((Object? k, Object? v) {
      final String kStr = k as String;
      parts.add('${jsonEncode(kStr)}:${_stringifyValue(v, replaced, kStr, ancestors, replacer)}');
    });
    return '{${parts.join(',')}}';
  }
  if (replaced is List) {
    final List<String> parts = <String>[];
    for (int i = 0; i < replaced.length; i++) {
      parts.add(_stringifyValue(replaced[i], replaced, i.toString(), ancestors, replacer));
    }
    return '[${parts.join(',')}]';
  }
  return jsonEncode(replaced);
}

/// Like `JSON.stringify`, but with deterministic ordering of object keys so
/// that structurally equal inputs always produce the same string.
String stableStringify(Object? value) {
  if (value == null) {
    // JS `undefined` maps to Dart null; source's top-level undefined branch.
    return 'undefined';
  }
  try {
    return _stableStringify(value, <Object>{});
  } catch (_) {
    return '';
  }
}

String _stableStringify(Object? value, Set<Object> seen) {
  if (value == null || value is! Map && value is! List) {
    return jsonEncode(value);
  }
  if (seen.contains(value)) {
    return '"[Circular]"';
  }
  seen.add(value);

  late final String result;
  if (value is List) {
    result = '[' + value.map((Object? v) => _stableStringify(v, seen)).join(',') + ']';
  } else {
    final Map<String, Object?> valueMap = value as Map<String, Object?>;
    final List<String> keys = valueMap.keys.toList()..sort();
    final List<String> parts = <String>[];
    for (final String k in keys) {
      final Object? v = valueMap[k];
      if (v == null) {
        continue;
      }
      parts.add(jsonEncode(k) + ':' + _stableStringify(v, seen));
    }
    result = '{' + parts.join(',') + '}';
  }

  // Track only ancestors so shared sibling references are serialized in full.
  seen.remove(value);
  return result;
}

typedef Obj = Map<String, Object?>;

/// Returns an object that has keys for each value that is different in the
/// base object. Keys that do not exist in the target but in the base object
/// are not considered.
Obj distinct(Obj base, Obj target) {
  final Obj result = <String, Object?>{};

  if (base.isEmpty && target.isEmpty) {
    return result;
  }

  for (final String k in target.keys) {
    final Object? baseValue = base[k];
    final Object? targetValue = target[k];

    if (!equals(baseValue, targetValue)) {
      result[k] = targetValue;
    }
  }

  return result;
}

Object? getCaseInsensitive(Obj target, String key) {
  final String lowercaseKey = key.toLowerCase();
  String? equivalentKey;
  for (final String k in target.keys) {
    if (k.toLowerCase() == lowercaseKey) {
      equivalentKey = k;
      break;
    }
  }
  return equivalentKey != null ? target[equivalentKey] : target[key];
}

Obj filter(Obj obj, bool Function(String key, Object? value) predicate) {
  final Obj result = <String, Object?>{};
  obj.forEach((String key, Object? value) {
    if (predicate(key, value)) {
      result[key] = value;
    }
  });
  return result;
}

Map<String, R> mapValues<T, R>(Map<String, T> obj, R Function(T value, String key) fn) {
  final Map<String, R> result = <String, R>{};
  obj.forEach((String key, T value) {
    result[key] = fn(value, key);
  });
  return result;
}
