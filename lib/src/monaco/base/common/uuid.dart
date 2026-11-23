// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/uuid.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. JS `crypto.getRandomValues` -> Dart
// `Random.secure()`; the `crypto.randomUUID` fast path is a no-op here (Dart
// has no equivalent), the version-bit + hex assembly path is kept identical.
// ---------------------------------------------------------------------------

import 'dart:math';
import 'dart:typed_data';

final RegExp _UUIDPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);

bool isUUID(String value) {
  return _UUIDPattern.hasMatch(value);
}

final String Function() generateUuid = _initGenerateUuid();

String Function() _initGenerateUuid() {
  // use `randomUUID` if possible
  // see https://developer.mozilla.org/en-US/docs/Web/API/Window/crypto
  // > Although crypto is available on all windows, the returned Crypto object only has one
  // > usable feature in insecure contexts: the getRandomValues() method.
  // > In general, you should use this API only in secure contexts.
  // Dart: no `crypto.randomUUID`; always take the `getRandomValues` path below.

  // prep-work
  final Uint8List _data = Uint8List(16);
  final List<String> _hex = <String>[];
  for (int i = 0; i < 256; i++) {
    _hex.add(i.toRadixString(16).padLeft(2, '0'));
  }

  final Random _random = Random.secure();

  return () {
    // get data
    for (int i = 0; i < 16; i++) {
      _data[i] = _random.nextInt(256);
    }

    // set version bits
    _data[6] = (_data[6] & 0x0f) | 0x40;
    _data[8] = (_data[8] & 0x3f) | 0x80;

    // print as string
    int i = 0;
    String result = '';
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += '-';
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += '-';
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += '-';
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += '-';
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    result += _hex[_data[i++]];
    return result;
  };
}

/// Namespace should be 3 letters, e.g. `abc-<uuid>`.
String prefixedUuid(String namespace) {
  return '$namespace-${generateUuid()}';
}
