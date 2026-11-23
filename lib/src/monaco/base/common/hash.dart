// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/hash.ts
// Translated 1:1 from TypeScript.
//   - JS int32 `|0` -> `_i32(x)`; `>>>0` -> `_u32(x)`.
//   - `Uint8Array`/`DataView` -> Uint8List/ByteData (big-endian setUint32).
//   - `crypto.subtle.digest('sha-1')` (async path) -> package:crypto sha1.
//   - `0b...` binary literals -> hex; `Math.imul` -> `_imul`.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'assert.dart';
import 'buffer.dart';
import 'strings.dart' as strings;

/// 1:1: `type NotSyncHashable`
typedef NotSyncHashable = Object; // ArrayBufferLike | ArrayBufferView

/// int32 truncation (`x | 0`).
int _i32(int x) {
  final int r = x & 0xFFFFFFFF;
  return r >= 0x80000000 ? r - 0x100000000 : r;
}

/// unsigned 32-bit (`x >>> 0`).
int _u32(int x) => x & 0xFFFFFFFF;

/// JS `Math.imul(a, b)`.
int _imul(int a, int b) {
  final int ah = (a >> 16) & 0xFFFF;
  final int al = a & 0xFFFF;
  final int bh = (b >> 16) & 0xFFFF;
  final int bl = b & 0xFFFF;
  final int lo = _u32(al * bl);
  return _i32((lo + (((ah * bl + al * bh) & 0xFFFF) << 16)));
}

/// 1:1: `hash<T>`
int hash(Object? obj) => doHash(obj, 0);

/// 1:1: `doHash`
int doHash(dynamic obj, int hashVal) {
  if (obj == null) {
    return numberHash(349, hashVal);
  }
  if (obj is String) {
    return stringHash(obj, hashVal);
  }
  if (obj is bool) {
    return booleanHash(obj, hashVal);
  }
  if (obj is num) {
    return numberHash(obj.toInt(), hashVal);
  }
  if (obj is List) {
    return arrayHash(obj, hashVal);
  }
  if (obj is Map) {
    return objectHash(obj, hashVal);
  }
  // JS `typeof function/symbol/bigint/undefined` default branches.
  return numberHash(617, hashVal);
}

/// 1:1: `numberHash`
int numberHash(int val, int initialHashVal) =>
    _i32((_i32((initialHashVal << 5) - initialHashVal) + val));

/// 1:1: `booleanHash`
int booleanHash(bool b, int initialHashVal) =>
    numberHash(b ? 433 : 863, initialHashVal);

/// 1:1: `stringHash`
int stringHash(String s, int hashVal) {
  hashVal = numberHash(149417, hashVal);
  for (int i = 0, length = s.length; i < length; i++) {
    hashVal = numberHash(s.codeUnitAt(i), hashVal);
  }
  return hashVal;
}

/// 1:1: `isStringInSample`
bool isStringInSample(String value, int samplePercentage) {
  assertCondition(
      samplePercentage >= 0 && samplePercentage <= 100,
      'samplePercentage must be an integer between 0 and 100');
  return _u32(stringHash(value, 0)) % 100 < samplePercentage;
}

/// 1:1: `ConstantStringHash`
class ConstantStringHash {
  final int multiplier;
  final int addend;

  ConstantStringHash(String value)
      : multiplier = _constantMultiplier(value),
        addend = stringHash(value, 0);

  static int _constantMultiplier(String value) {
    int multiplier = 31;
    for (int i = 0; i < value.length; i++) {
      multiplier = _imul(multiplier, 31);
    }
    return multiplier;
  }

  /// 1:1: `apply(hashVal)`
  int apply(int hashVal) => _i32(_imul(hashVal, multiplier) + addend);
}

/// 1:1: `ARRAY_HASH_SEED`
const int ARRAY_HASH_SEED = 104579;

/// 1:1: `OBJECT_HASH_SEED`
const int OBJECT_HASH_SEED = 181387;

/// 1:1: `arrayHash`
int arrayHash(List<Object?> arr, int initialHashVal) {
  initialHashVal = numberHash(ARRAY_HASH_SEED, initialHashVal);
  int h = initialHashVal;
  for (final Object? item in arr) {
    h = doHash(item, h);
  }
  return h;
}

/// 1:1: `objectHash`
int objectHash(Map<Object?, Object?> obj, int initialHashVal) {
  initialHashVal = numberHash(OBJECT_HASH_SEED, initialHashVal);
  final List<String> keys = obj.keys
      .map((Object? k) => '$k')
      .toList()
    ..sort();
  int h = initialHashVal;
  for (final String key in keys) {
    h = stringHash(key, h);
    h = doHash(obj[key], h);
  }
  return h;
}

/// 1:1: `const enum SHA1Constant`
class SHA1Constant {
  static const int BLOCK_SIZE = 64;
  static const int UNICODE_REPLACEMENT = 0xFFFD;
}

/// 1:1: `leftRotate(value, bits, totalBits=32)`
int leftRotate(int value, int bits, [int totalBits = 32]) {
  final int delta = totalBits - bits;
  final int mask = _i32(~((1 << delta) - 1));
  return _u32((value << bits) | (_u32(mask & value) >> delta));
}

/// 1:1: `toHexString(buffer | value, bitsize=32)` (value overload)
String toHexString(int value, [int bitsize = 32]) =>
    _u32(value).toRadixString(16).padLeft((bitsize / 4).round(), '0');

/// 1:1: `hashAsync` - StringSHA1 for small strings; sha-1 of UTF-8 otherwise.
Future<String> hashAsync(Object input) async {
  if (input is String && input.length < 250) {
    final StringSHA1 sha = StringSHA1();
    sha.update(input);
    return sha.digest();
  }

  late Uint8List buff;
  if (input is String) {
    buff = Uint8List.fromList(utf8.encode(input));
  } else if (input is VSBuffer) {
    buff = input.buffer;
  } else if (input is Uint8List) {
    buff = input;
  } else {
    buff = Uint8List.fromList((input as List<int>));
  }
  return _sha1Hex(buff);
}

/// SHA-1 of a byte array, hex encoded (Node `crypto.subtle.digest('sha-1')`).
Future<String> _sha1Hex(Uint8List data) async {
  // Minimal streaming-free SHA-1 over bytes (mirrors StringSHA1's _step).
  final List<int> h = <int>[
    0x67452301,
    0xEFCDAB89,
    0x98BADCFE,
    0x10325476,
    0xC3D2E1F0,
  ];
  final int bitLen = data.length * 8;
  final int paddedLen = ((data.length + 9 + 63) ~/ 64) * 64;
  final Uint8List msg = Uint8List(paddedLen);
  msg.setAll(0, data);
  msg[data.length] = 0x80;
  final ByteData bd = ByteData.view(msg.buffer);
  bd.setUint32(paddedLen - 8, _u32(bitLen ~/ 0x100000000), Endian.big);
  bd.setUint32(paddedLen - 4, _u32(bitLen), Endian.big);

  final Uint32List w = Uint32List(80);
  for (int off = 0; off < paddedLen; off += 64) {
    for (int j = 0; j < 16; j++) {
      w[j] = bd.getUint32(off + 4 * j, Endian.big);
    }
    for (int j = 16; j < 80; j++) {
      w[j] = leftRotate(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16], 1);
    }
    int a = h[0], b = h[1], c = h[2], d = h[3], e = h[4];
    for (int j = 0; j < 80; j++) {
      late int f, k;
      if (j < 20) {
        f = (b & c) | ((~b) & d);
        k = 0x5A827999;
      } else if (j < 40) {
        f = b ^ c ^ d;
        k = 0x6ED9EBA1;
      } else if (j < 60) {
        f = (b & c) | (b & d) | (c & d);
        k = 0x8F1BBCDC;
      } else {
        f = b ^ c ^ d;
        k = 0xCA62C1D6;
      }
      final int temp = _u32(leftRotate(a, 5) + f + e + k + w[j]);
      e = d;
      d = c;
      c = leftRotate(b, 30);
      b = a;
      a = temp;
    }
    h[0] = _u32(h[0] + a);
    h[1] = _u32(h[1] + b);
    h[2] = _u32(h[2] + c);
    h[3] = _u32(h[3] + d);
    h[4] = _u32(h[4] + e);
  }
  return h.map((int v) => toHexString(v)).join();
}

/// 1:1: `StringSHA1`
class StringSHA1 {
  static final Uint8List _bigBlock32 = Uint8List(320); // 80 * 4

  int _h0 = 0x67452301;
  int _h1 = 0xEFCDAB89;
  int _h2 = 0x98BADCFE;
  int _h3 = 0x10325476;
  int _h4 = 0xC3D2E1F0;

  late final Uint8List _buff;
  late final ByteData _buffDV;
  int _buffLen = 0;
  int _totalLen = 0;
  int _leftoverHighSurrogate = 0;
  bool _finished = false;

  StringSHA1() {
    _buff = Uint8List(SHA1Constant.BLOCK_SIZE + 3);
    _buffDV = ByteData.view(_buff.buffer);
  }

  /// 1:1: `update(str)`
  void update(String str) {
    final int strLen = str.length;
    if (strLen == 0) {
      return;
    }

    final Uint8List buff = _buff;
    int buffLen = _buffLen;
    int leftoverHighSurrogate = _leftoverHighSurrogate;
    late int charCode;
    int offset;

    if (leftoverHighSurrogate != 0) {
      charCode = leftoverHighSurrogate;
      offset = -1;
      leftoverHighSurrogate = 0;
    } else {
      charCode = str.codeUnitAt(0);
      offset = 0;
    }

    while (true) {
      int codePoint = charCode;
      if (strings.isHighSurrogate(charCode)) {
        if (offset + 1 < strLen) {
          final int nextCharCode = str.codeUnitAt(offset + 1);
          if (strings.isLowSurrogate(nextCharCode)) {
            offset++;
            codePoint = strings.computeCodePoint(charCode, nextCharCode);
          } else {
            codePoint = SHA1Constant.UNICODE_REPLACEMENT;
          }
        } else {
          leftoverHighSurrogate = charCode;
          break;
        }
      } else if (strings.isLowSurrogate(charCode)) {
        codePoint = SHA1Constant.UNICODE_REPLACEMENT;
      }

      buffLen = _push(buff, buffLen, codePoint);
      offset++;
      if (offset < strLen) {
        charCode = str.codeUnitAt(offset);
      } else {
        break;
      }
    }

    _buffLen = buffLen;
    _leftoverHighSurrogate = leftoverHighSurrogate;
  }

  /// 1:1: `_push` - UTF-8 encode one code point into the block buffer.
  int _push(Uint8List buff, int buffLen, int codePoint) {
    if (codePoint < 0x0080) {
      buff[buffLen++] = codePoint;
    } else if (codePoint < 0x0800) {
      buff[buffLen++] = 0xC0 | ((codePoint & 0x07C0) >> 6);
      buff[buffLen++] = 0x80 | (codePoint & 0x003F);
    } else if (codePoint < 0x10000) {
      buff[buffLen++] = 0xE0 | ((codePoint & 0xF000) >> 12);
      buff[buffLen++] = 0x80 | ((codePoint & 0x0FC0) >> 6);
      buff[buffLen++] = 0x80 | (codePoint & 0x003F);
    } else {
      buff[buffLen++] = 0xF0 | ((codePoint & 0x1C0000) >> 18);
      buff[buffLen++] = 0x80 | ((codePoint & 0x03F000) >> 12);
      buff[buffLen++] = 0x80 | ((codePoint & 0x000FC0) >> 6);
      buff[buffLen++] = 0x80 | (codePoint & 0x003F);
    }

    if (buffLen >= SHA1Constant.BLOCK_SIZE) {
      _step();
      buffLen -= SHA1Constant.BLOCK_SIZE;
      _totalLen += SHA1Constant.BLOCK_SIZE;
      buff[0] = buff[SHA1Constant.BLOCK_SIZE + 0];
      buff[1] = buff[SHA1Constant.BLOCK_SIZE + 1];
      buff[2] = buff[SHA1Constant.BLOCK_SIZE + 2];
    }
    return buffLen;
  }

  /// 1:1: `digest()`
  String digest() {
    if (!_finished) {
      _finished = true;
      if (_leftoverHighSurrogate != 0) {
        _leftoverHighSurrogate = 0;
        _buffLen = _push(_buff, _buffLen, SHA1Constant.UNICODE_REPLACEMENT);
      }
      _totalLen += _buffLen;
      _wrapUp();
    }
    return toHexString(_h0) +
        toHexString(_h1) +
        toHexString(_h2) +
        toHexString(_h3) +
        toHexString(_h4);
  }

  /// 1:1: `_wrapUp()`
  void _wrapUp() {
    _buff[_buffLen++] = 0x80;
    for (int i = _buffLen; i < _buff.length; i++) {
      _buff[i] = 0;
    }

    if (_buffLen > 56) {
      _step();
      for (int i = 0; i < _buff.length; i++) {
        _buff[i] = 0;
      }
    }

    final int ml = 8 * _totalLen;
    _buffDV.setUint32(56, _u32(ml ~/ 4294967296), Endian.big);
    _buffDV.setUint32(60, _u32(ml % 4294967296), Endian.big);
    _step();
  }

  /// 1:1: `_step()`
  void _step() {
    final Uint8List bigBlock32 = _bigBlock32;
    final ByteData data = _buffDV;

    for (int j = 0; j < 64; j += 4) {
      // Store the word as 4 raw big-endian bytes to mirror DataView.setUint32.
      _setU32(bigBlock32, j, data.getUint32(j, Endian.big));
    }
    for (int j = 64; j < 320; j += 4) {
      final int v = leftRotate(_getU32(bigBlock32, j - 12) ^
          _getU32(bigBlock32, j - 32) ^
          _getU32(bigBlock32, j - 56) ^
          _getU32(bigBlock32, j - 64), 1);
      _setU32(bigBlock32, j, v);
    }

    int a = _h0, b = _h1, c = _h2, d = _h3, e = _h4;
    late int f, k;

    for (int j = 0; j < 80; j++) {
      if (j < 20) {
        f = (b & c) | ((~b) & d);
        k = 0x5A827999;
      } else if (j < 40) {
        f = b ^ c ^ d;
        k = 0x6ED9EBA1;
      } else if (j < 60) {
        f = (b & c) | (b & d) | (c & d);
        k = 0x8F1BBCDC;
      } else {
        f = b ^ c ^ d;
        k = 0xCA62C1D6;
      }
      final int temp = _u32(
          leftRotate(a, 5) + f + e + k + _getU32(bigBlock32, j * 4));
      e = d;
      d = c;
      c = leftRotate(b, 30);
      b = a;
      a = temp;
    }

    _h0 = _u32(_h0 + a);
    _h1 = _u32(_h1 + b);
    _h2 = _u32(_h2 + c);
    _h3 = _u32(_h3 + d);
    _h4 = _u32(_h4 + e);
  }
}

int _getU32(Uint8List bytes, int offset) =>
    ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes)
        .getUint32(offset, Endian.big);

void _setU32(Uint8List bytes, int offset, int value) =>
    ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes)
        .setUint32(offset, value, Endian.big);
