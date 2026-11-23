// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/marshalling.ts
// Translated 1:1 from TypeScript.
//   - `JSON.stringify(obj, replacer)` -> recursive serializer that applies the
//     RegExp replacer and calls URI.toJSON() (mirrors JSON's toJSON protocol).
//   - `JSON.parse` -> dart:convert jsonDecode.
//   - `revive<T>` walks the decoded tree in place, same as the source.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'buffer.dart';
import 'marshallingIds.dart';
import 'uri.dart';

/// 1:1: `export function stringify`
String stringify(Object? obj) => _stringifyValue(obj);

/// Replacer equivalent: RegExp -> { $mid, source, flags }, URI -> toJSON().
Object? _replacer(Object? value) {
  if (value is RegExp) {
    return <String, Object?>{
      '\$mid': MarshalledId.Regexp,
      'source': value.pattern,
      'flags': _flagsOf(value),
    };
  }
  if (value is URI) {
    return _uriToJson(value);
  }
  return value;
}

/// Reconstruct a JS-style flags string from a Dart RegExp. Dart RegExp exposes
/// only case-sensitivity and multiline (`g` is implicit in `allMatches`); there
/// are no `dotAll`/`unicode` getters, so those flags are not observable here.
String _flagsOf(RegExp re) {
  final StringBuffer sb = StringBuffer();
  if (!re.isCaseSensitive) {
    sb.write('i');
  }
  if (re.isMultiLine) {
    sb.write('m');
  }
  return sb.toString();
}

/// URI.toJSON() returns the UriComponents shape. The JS runtime stamps `$mid`
/// onto serialized URI state (UriState.$mid) so `revive` can distinguish a URI
/// from a plain component object; we emit it explicitly to preserve that
/// round-trip contract.
Map<String, Object?> _uriToJson(URI uri) => <String, Object?>{
      '\$mid': MarshalledId.Uri,
      'scheme': uri.scheme,
      'authority': uri.authority,
      'path': uri.path,
      'query': uri.query,
      'fragment': uri.fragment,
    };

String _stringifyValue(Object? value) {
  final Object? replaced = _replacer(value);
  if (replaced is Map) {
    final List<String> parts = <String>[];
    replaced.forEach((Object? k, Object? v) {
      parts.add('${jsonEncode(k as String)}:${_stringifyValue(v)}');
    });
    return '{${parts.join(',')}}';
  }
  if (replaced is List) {
    final List<String> parts = <String>[];
    for (final Object? item in replaced) {
      parts.add(_stringifyValue(item));
    }
    return '[${parts.join(',')}]';
  }
  return jsonEncode(replaced);
}

/// 1:1: `export function parse`
dynamic parse(String text) {
  dynamic data = jsonDecode(text);
  data = revive(data);
  return data;
}

/// 1:1: `export interface MarshalledObject`
abstract class MarshalledObject {
  int get mid;
}

/// 1:1: `export function revive<T = any>`
dynamic revive(dynamic obj, [int depth = 0]) {
  if (obj == null || depth > 200) {
    return obj;
  }

  if (obj is Map) {
    final dynamic mid = obj['\$mid'];

    switch (mid) {
      case MarshalledId.Uri:
        // Source reuses the plain decoded object as UriComponents (JS structural
        // typing). Dart needs an explicit UriComponents carrier.
        final UriComponents components = UriComponents(
          scheme: (obj['scheme'] as String?) ?? '',
          authority: obj['authority'] as String?,
          path: obj['path'] as String?,
          query: obj['query'] as String?,
          fragment: obj['fragment'] as String?,
        );
        final URI? revived = URI.revive(components);
        return revived ?? obj;
      case MarshalledId.Regexp:
        return _reviveRegExp(obj['source'] as String, obj['flags'] as String?);
      case MarshalledId.Date:
        return DateTime.parse(obj['source'] as String);
    }

    if (obj is VSBuffer || obj is Uint8List) {
      return obj;
    }

    for (final Object? key in obj.keys.toList()) {
      obj[key] = revive(obj[key], depth + 1);
    }
  } else if (obj is List) {
    for (int i = 0; i < obj.length; i++) {
      obj[i] = revive(obj[i], depth + 1);
    }
  }

  return obj;
}

/// 1:1: `new RegExp(obj.source, obj.flags)`
RegExp _reviveRegExp(String source, String? flags) {
  final String f = flags ?? '';
  return RegExp(
    source,
    caseSensitive: !f.contains('i'),
    multiLine: f.contains('m'),
    dotAll: f.contains('s'),
    unicode: f.contains('u'),
  );
}
