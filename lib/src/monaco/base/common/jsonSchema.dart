/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

// 1:1 port of vs/base/common/jsonSchema.ts
//
// PORT NOTE: the TypeScript type-level helpers (TypeFromJsonSchema, SchemaPrimitiveTypeNameToType,
// UnionOf, IsRequired, AdditionalPropertiesType, MapSchemaToType) exist only at compile time and
// have no Dart equivalent. They are documented below but intentionally not ported, matching the
// treatment of all other `type X<T> = ...` declarations in this port. Runtime values (interfaces,
// getCompressedContent, traverseNodes) are ported 1:1.

import 'dart:collection';
import 'dart:convert';

/// `export type JSONSchemaType = 'string' | ...`
class JSONSchemaType {
  static const String string = 'string';
  static const String number = 'number';
  static const String integer = 'integer';
  static const String boolean = 'boolean';
  static const String nullValue = 'null';
  static const String array = 'array';
  static const String object = 'object';
}

/// 1:1 shape of `interface IJSONSchema` — represented as a map literal, matching how the source
/// constructs schema nodes (object literals) and accesses them dynamically.
typedef IJSONSchema = Map<String, Object?>;

/// `interface IJSONSchemaMap { [name: string]: IJSONSchema }`
typedef IJSONSchemaMap = Map<String, IJSONSchema>;

/// `interface IJSONSchemaSnippet`
class IJSONSchemaSnippet {
  String? label;
  String? description;
  Object? body;
  String? bodyText;
}

// The following are compile-time-only TypeScript types with no runtime counterpart:
//   TypeFromJsonSchema<T>, SchemaPrimitiveTypeNameToType<T>, UnionOf<T>, IsRequired<K, L>,
//   AdditionalPropertiesType<Schema>, MapSchemaToType<T>.

/// 1:1: `interface Equals { schemas: IJSONSchema[]; id?: string }`
class Equals {
  List<IJSONSchema> schemas;
  String? id;
  Equals(this.schemas, [this.id]);
}

/// 1:1: `export function getCompressedContent(schema: IJSONSchema): string`
String getCompressedContent(IJSONSchema schema) {
  bool hasDups = false;

  // visit all schema nodes and collect the ones that are equal
  final Map<String, Equals> equalsByString = <String, Equals>{};
  // Source uses object identity as the key (`new Map<IJSONSchema, Equals>()`).
  final Map<IJSONSchema, Equals> nodeToEquals = HashMap<IJSONSchema, Equals>.identity();

  bool visitSchemas(IJSONSchema next) {
    if (identical(schema, next)) {
      return true;
    }
    final String val = jsonEncode(next);
    if (val.length < 30) {
      // the $ref takes around 25 chars, so we don't save anything
      return true;
    }
    final Equals? eq = equalsByString[val];
    if (eq == null) {
      final Equals newEq = Equals(<IJSONSchema>[next]);
      equalsByString[val] = newEq;
      nodeToEquals[next] = newEq;
      return true;
    }
    eq.schemas.add(next);
    nodeToEquals[next] = eq;
    hasDups = true;
    return false;
  }

  _traverseNodes(schema, visitSchemas);
  equalsByString.clear();

  if (!hasDups) {
    return jsonEncode(schema);
  }

  String defNodeName = r'$defs';
  while (schema.containsKey(defNodeName)) {
    defNodeName += '_';
  }

  // used to collect all schemas that are later put in `$defs`. The index in the array is the id of the schema.
  final List<IJSONSchema> definitions = <IJSONSchema>[];

  String stringify(IJSONSchema root) {
    return _jsonStringify(root, (String key, Object? value) {
      if (!identical(value, root)) {
        final Equals? eq = value is Map ? nodeToEquals[value as IJSONSchema] : null;
        if (eq != null && eq.schemas.length > 1) {
          if (eq.id == null) {
            eq.id = '_${definitions.length}';
            definitions.add(eq.schemas[0]);
          }
          return <String, Object?>{r'$ref': r'#/$defs/' + eq.id!};
        }
      }
      return value;
    });
  }

  // stringify the schema and replace duplicate subtrees with $ref
  // this will add new items to the definitions array
  final String str = stringify(schema);

  // now stringify the definitions. Each invocation of stringify can add new items to the definitions array, so the length can grow while we iterate
  final List<String> defStrings = <String>[];
  for (int i = 0; i < definitions.length; i++) {
    defStrings.add('"_$i":${stringify(definitions[i])}');
  }
  if (defStrings.isNotEmpty) {
    return '${str.substring(0, str.length - 1)},"$defNodeName":{${defStrings.join(',')}}}';
  }
  return str;
}

/// JSON.stringify-equivalent with a `(key, value) => value` replacer.
/// The replacer is invoked for the root (key `''`) and each member, receiving the ORIGINAL
/// object reference — matching JS, which is why `nodeToEquals.get(value)` works by identity.
String _jsonStringify(Object? value, Object? Function(String key, Object? value) replacer) {
  return _stringifyValue(value, '', replacer);
}

String _stringifyValue(Object? value, String key, Object? Function(String key, Object? value) replacer) {
  final Object? replaced = replacer(key, value);
  if (replaced is Map) {
    final List<String> parts = <String>[];
    replaced.forEach((Object? k, Object? v) {
      parts.add('${jsonEncode(k.toString())}:${_stringifyValue(v, k.toString(), replacer)}');
    });
    return '{${parts.join(',')}}';
  }
  if (replaced is List) {
    final List<String> parts = <String>[];
    for (int i = 0; i < replaced.length; i++) {
      parts.add(_stringifyValue(replaced[i], i.toString(), replacer));
    }
    return '[${parts.join(',')}]';
  }
  return jsonEncode(replaced);
}

/// 1:1: `type IJSONSchemaRef = IJSONSchema | boolean`
typedef IJSONSchemaRef = Object; // IJSONSchema or bool

bool _isObject(Object? thing) => thing is Map;

/// 1:1: `function traverseNodes(root, visit)`
void _traverseNodes(IJSONSchema root, bool Function(IJSONSchema schema) visit) {
  // Source guard `if (!root || typeof root !== 'object') return;` is implicit here:
  // IJSONSchema is always a non-null Map in Dart.
  final List<IJSONSchema> toWalk = <IJSONSchema>[root];

  void collectEntries(List<Object?> entries) {
    for (final Object? entry in entries) {
      if (_isObject(entry)) {
        toWalk.add(entry as IJSONSchema);
      }
    }
  }

  void collectMapEntries(List<Object?> maps) {
    for (final Object? map in maps) {
      if (map is Map) {
        map.forEach((Object? key, Object? entry) {
          if (_isObject(entry)) {
            toWalk.add(entry as IJSONSchema);
          }
        });
      }
    }
  }

  void collectArrayEntries(List<Object?> arrays) {
    for (final Object? array in arrays) {
      if (array is List) {
        for (final Object? entry in array) {
          if (_isObject(entry)) {
            toWalk.add(entry as IJSONSchema);
          }
        }
      }
    }
  }

  void collectEntryOrArrayEntries(Object? items) {
    if (items is List) {
      for (final Object? entry in items) {
        if (_isObject(entry)) {
          toWalk.add(entry as IJSONSchema);
        }
      }
    } else if (_isObject(items)) {
      toWalk.add(items as IJSONSchema);
    }
  }

  IJSONSchema? next = toWalk.isNotEmpty ? toWalk.removeLast() : null;
  while (next != null) {
    final bool visitChildren = visit(next);
    if (visitChildren) {
      collectEntries(<Object?>[
        next['additionalItems'], next['additionalProperties'], next['not'], next['contains'],
        next['propertyNames'], next['if'], next['then'], next['else'],
        next['unevaluatedItems'], next['unevaluatedProperties'],
      ]);
      collectMapEntries(<Object?>[
        next['definitions'], next[r'$defs'], next['properties'], next['patternProperties'],
        next['dependencies'], next['dependentSchemas'],
      ]);
      collectArrayEntries(<Object?>[next['anyOf'], next['allOf'], next['oneOf'], next['prefixItems']]);
      collectEntryOrArrayEntries(next['items']);
    }
    next = toWalk.isNotEmpty ? toWalk.removeLast() : null;
  }
}
