/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

// 1:1 port of vs/base/common/normalization.ts
//
// PORT NOTE: JavaScript's `String.prototype.normalize(form)` has no equivalent in the Dart
// standard library. `_nfdDecompose` / `_nfcCompose` are minimal carrier implementations using
// the Unicode canonical decomposition table for Latin scripts (the ranges VS Code uses for
// accent folding). The surrounding control flow (LRUCache, nonAscii fast path, IIFE closure)
// is kept identical to the source.

import 'package:semi_design_flutter/src/monaco/base/common/map.dart';

final LRUCache<String, String> _nfcCache = LRUCache<String, String>(10000); // bounded to 10000 elements

/// 1:1: `export function normalizeNFC(str: string): string`
String normalizeNFC(String str) => _normalize(str, 'NFC', _nfcCache);

final LRUCache<String, String> _nfdCache = LRUCache<String, String>(10000); // bounded to 10000 elements

/// 1:1: `export function normalizeNFD(str: string): string`
String normalizeNFD(String str) => _normalize(str, 'NFD', _nfdCache);

// PORT NOTE: `/[^\u0000-\u0080]/` — the source pattern treats U+0080 as ASCII,
// so the fast path applies to strings whose code units are all <= 0x80.
bool _hasNonAsciiCharacters(String str) => str.codeUnits.any((int c) => c > 0x80);

/// 1:1: `function normalize(str, form, normalizedCache)`
String _normalize(String str, String form, LRUCache<String, String> normalizedCache) {
  if (str.isEmpty) {
    return str;
  }

  final String? cached = normalizedCache.get(str);
  if (cached != null) {
    return cached;
  }

  final String res = _hasNonAsciiCharacters(str) ? _normalizeString(str, form) : str;

  // Use the cache for fast lookup
  normalizedCache.set(str, res);

  return res;
}

String _normalizeString(String str, String form) => form == 'NFD' ? _nfdDecompose(str) : _nfcCompose(str);

/// Unicode canonical decomposition (NFD) for Latin scripts.
/// Maps a precomposed code point to its base + combining mark sequence.
const Map<int, String> _nfdTable = <int, String>{
  // Latin-1 Supplement — uppercase
  0x00C0: 'A\u0300', 0x00C1: 'A\u0301', 0x00C2: 'A\u0302', 0x00C3: 'A\u0303',
  0x00C4: 'A\u0308', 0x00C5: 'A\u030A', 0x00C7: 'C\u0327',
  0x00C8: 'E\u0300', 0x00C9: 'E\u0301', 0x00CA: 'E\u0302', 0x00CB: 'E\u0308',
  0x00CC: 'I\u0300', 0x00CD: 'I\u0301', 0x00CE: 'I\u0302', 0x00CF: 'I\u0308',
  0x00D1: 'N\u0303',
  0x00D2: 'O\u0300', 0x00D3: 'O\u0301', 0x00D4: 'O\u0302', 0x00D5: 'O\u0303', 0x00D6: 'O\u0308',
  0x00D9: 'U\u0300', 0x00DA: 'U\u0301', 0x00DB: 'U\u0302', 0x00DC: 'U\u0308',
  0x00DD: 'Y\u0301',
  // Latin-1 Supplement — lowercase
  0x00E0: 'a\u0300', 0x00E1: 'a\u0301', 0x00E2: 'a\u0302', 0x00E3: 'a\u0303',
  0x00E4: 'a\u0308', 0x00E5: 'a\u030A', 0x00E7: 'c\u0327',
  0x00E8: 'e\u0300', 0x00E9: 'e\u0301', 0x00EA: 'e\u0302', 0x00EB: 'e\u0308',
  0x00EC: 'i\u0300', 0x00ED: 'i\u0301', 0x00EE: 'i\u0302', 0x00EF: 'i\u0308',
  0x00F1: 'n\u0303',
  0x00F2: 'o\u0300', 0x00F3: 'o\u0301', 0x00F4: 'o\u0302', 0x00F5: 'o\u0303', 0x00F6: 'o\u0308',
  0x00F9: 'u\u0300', 0x00FA: 'u\u0301', 0x00FB: 'u\u0302', 0x00FC: 'u\u0308',
  0x00FD: 'y\u0301', 0x00FF: 'y\u0308',
  // Latin Extended-A — A
  0x0100: 'A\u0304', 0x0101: 'a\u0304', 0x0102: 'A\u0306', 0x0103: 'a\u0306',
  0x0104: 'A\u0328', 0x0105: 'a\u0328', 0x0106: 'C\u0301', 0x0107: 'c\u0301',
  0x0108: 'C\u0302', 0x0109: 'c\u0302', 0x010A: 'C\u0307', 0x010B: 'c\u0307',
  0x010C: 'C\u030C', 0x010D: 'c\u030C', 0x010E: 'D\u030C', 0x010F: 'd\u030C',
  0x0110: 'D\u0304', 0x0111: 'd\u0304',
  0x0112: 'E\u0304', 0x0113: 'e\u0304', 0x0114: 'E\u0306', 0x0115: 'e\u0306',
  0x0116: 'E\u0307', 0x0117: 'e\u0307', 0x0118: 'E\u0328', 0x0119: 'e\u0328',
  0x011A: 'E\u030C', 0x011B: 'e\u030C',
  0x011C: 'G\u0302', 0x011D: 'g\u0302', 0x011E: 'G\u0306', 0x011F: 'g\u0306',
  0x0120: 'G\u0307', 0x0121: 'g\u0307', 0x0122: 'G\u0327', 0x0123: 'g\u0327',
  0x0124: 'H\u0302', 0x0125: 'h\u0302', 0x0126: 'H\u0304', 0x0127: 'h\u0304',
  0x0128: 'I\u0303', 0x0129: 'i\u0303', 0x012A: 'I\u0304', 0x012B: 'i\u0304',
  0x012C: 'I\u0306', 0x012D: 'i\u0306', 0x012E: 'I\u0328', 0x012F: 'i\u0328',
  0x0130: 'I\u0307',
  0x0134: 'J\u0302', 0x0135: 'j\u0302',
  0x0136: 'K\u0327', 0x0137: 'k\u0327',
  0x0139: 'L\u0301', 0x013A: 'l\u0301', 0x013B: 'L\u0327', 0x013C: 'l\u0327',
  0x013D: 'L\u030C', 0x013E: 'l\u030C',
  0x0142: 'l\u0307',
  0x0143: 'N\u0301', 0x0144: 'n\u0301', 0x0145: 'N\u0327', 0x0146: 'n\u0327',
  0x0147: 'N\u030C', 0x0148: 'n\u030C',
  0x014C: 'O\u0304', 0x014D: 'o\u0304', 0x014E: 'O\u0306', 0x014F: 'o\u0306',
  0x0150: 'O\u030B', 0x0151: 'o\u030B',
  0x0154: 'R\u0301', 0x0155: 'r\u0301', 0x0156: 'R\u0327', 0x0157: 'r\u0327',
  0x0158: 'R\u030C', 0x0159: 'r\u030C',
  0x015A: 'S\u0301', 0x015B: 's\u0301', 0x015C: 'S\u0302', 0x015D: 's\u0302',
  0x015E: 'S\u0327', 0x015F: 's\u0327', 0x0160: 'S\u030C', 0x0161: 's\u030C',
  0x0162: 'T\u0327', 0x0163: 't\u0327', 0x0164: 'T\u030C', 0x0165: 't\u030C',
  0x0168: 'U\u0303', 0x0169: 'u\u0303', 0x016A: 'U\u0304', 0x016B: 'u\u0304',
  0x016C: 'U\u0306', 0x016D: 'u\u0306', 0x016E: 'U\u030A', 0x016F: 'u\u030A',
  0x0170: 'U\u030B', 0x0171: 'u\u030B', 0x0172: 'U\u0328', 0x0173: 'u\u0328',
  0x0174: 'W\u0302', 0x0175: 'w\u0302',
  0x0176: 'Y\u0302', 0x0177: 'y\u0302', 0x0178: 'Y\u0308',
  0x0179: 'Z\u0301', 0x017A: 'z\u0301', 0x017B: 'Z\u0307', 0x017C: 'z\u0307',
  0x017D: 'Z\u030C', 0x017E: 'z\u030C',
  // Latin Extended-B (common)
  0x01FA: 'A\u030A\u0301', 0x01FB: 'a\u030A\u0301',
};

String _nfdDecompose(String str) {
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    final String d = _nfdTable[str.codeUnitAt(i)] ?? str[i];
    out.write(d);
  }
  return out.toString();
}

// Canonical composition (NFC) is the inverse of the NFD table above.
final Map<String, String> _nfcTable = Map<String, String>.unmodifiable(
  _nfdTable.map((int key, String value) => MapEntry<String, String>(value, String.fromCharCode(key))),
);

String _nfcCompose(String str) {
  final String decomposed = _nfdDecompose(str);
  // Hangul / multi-mark sequences are left decomposed (carrier limitation, same as source
  // for the Latin ranges used by VS Code accent folding).
  final StringBuffer out = StringBuffer();
  int i = 0;
  while (i < decomposed.length) {
    final String? composed = _nfcTable[decomposed[i]];
    if (composed != null) {
      out.write(composed);
      i += 1;
    } else if (i + 1 < decomposed.length) {
      final String pair = decomposed.substring(i, i + 2);
      final String? composedPair = _nfcTable[pair];
      if (composedPair != null) {
        out.write(composedPair);
        i += 2;
      } else {
        out.write(decomposed[i]);
        i++;
      }
    } else {
      out.write(decomposed[i]);
      i++;
    }
  }
  return out.toString();
}

/// 1:1: `export const tryNormalizeToBase = function () { ... }()`
final String Function(String) tryNormalizeToBase = _createTryNormalizeToBase();

String Function(String) _createTryNormalizeToBase() {
  final LRUCache<String, String> cache = LRUCache<String, String>(10000); // bounded to 10000 elements

  return (String str) {
    final String? cached = cache.get(str);
    if (cached != null) {
      return cached;
    }

    final String noAccents = normalizeNFD(str).replaceAll(RegExp('[\\u0300-\\u036f]'), '');
    final String result = (noAccents.length == str.length ? noAccents : str).toLowerCase();
    cache.set(str, result);
    return result;
  };
}
