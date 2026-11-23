// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/buffer.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations (documented inline):
//   - Node.js `Buffer` is unavailable in Dart, so `hasBuffer` is always false
//     and all paths use the browser/TextEncoder-equivalent implementation.
//   - `Uint8Array` -> `Uint8List`; `ArrayBufferView` overloads collapsed.
//   - `TextEncoder`/`TextDecoder` -> `dart:convert` utf8 (BOM preserved by
//     decoding UTF-8 bytes into a Dart string directly).
//   - Native `Uint8Array.fromBase64/toBase64/fromHex/toHex` are absent in Dart;
//     the permissive fallback loops from the source are used directly.
//   - `Promise` -> `Future`; `streams.*` bridges use the ported stream.dart.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'lazy.dart' as lazy;
import 'stream.dart' as streams;

/// Dart has no Node.js `Buffer`; the source's `hasBuffer` is always false.
const bool hasBuffer = false;

/// JS `>>>` is an unsigned 32-bit shift; Dart has only signed `>>`.
int _ushr(int value, int bits) => (value & 0xFFFFFFFF) >> bits;

/// 1:1: `const indexOfTable = new Lazy(() => new Uint8Array(256))`
final lazy.Lazy<Uint8List> _indexOfTable =
    lazy.Lazy<Uint8List>(() => Uint8List(256));

/// 1:1: `export class VSBuffer`
class VSBuffer {
  /// Allocates a buffer of [byteLength] zeroed bytes.
  static VSBuffer alloc(int byteLength) => VSBuffer(Uint8List(byteLength));

  /// Wraps an existing byte array without copying.
  static VSBuffer wrap(Uint8List actual) => VSBuffer(actual);

  /// Encodes [source] to UTF-8 bytes.
  static VSBuffer fromString(String source,
      {bool? dontUseNodeBuffer}) {
    return VSBuffer(Uint8List.fromList(utf8.encode(source)));
  }

  /// Creates a buffer from a list of byte values.
  static VSBuffer fromByteArray(List<int> source) {
    final VSBuffer result = VSBuffer.alloc(source.length);
    for (int i = 0; i < source.length; i++) {
      result.buffer[i] = source[i];
    }
    return result;
  }

  /// Concatenates buffers, optionally with a known total length.
  static VSBuffer concat(List<VSBuffer> buffers, [int? totalLength]) {
    int total = totalLength ?? 0;
    if (totalLength == null) {
      for (int i = 0; i < buffers.length; i++) {
        total += buffers[i].byteLength;
      }
    }

    final VSBuffer ret = VSBuffer.alloc(total);
    int offset = 0;
    for (int i = 0; i < buffers.length; i++) {
      final VSBuffer element = buffers[i];
      ret.set(element, offset);
      offset += element.byteLength;
    }
    return ret;
  }

  static bool isNativeBuffer(Object buffer) => false;

  /// Computes the UTF-8 byte length without allocating a backing buffer.
  /// Dart: static `byteLength` renamed to avoid collision with instance field.
  static int byteLengthStatic(String source) => utf8.encode(source).length;

  final Uint8List buffer;
  final int byteLength;

  /// 1:1: private constructor; Dart makes this internal by convention.
  VSBuffer(this.buffer) : byteLength = buffer.length;

  VSBuffer clone() {
    final VSBuffer result = VSBuffer.alloc(byteLength);
    result.set(this);
    return result;
  }

  @override
  String toString() {
    // Source uses TextDecoder(ignoreBOM: true): a leading BOM is preserved.
    // Dart's utf8.decode strips it, so re-insert it explicitly.
    final bool hasBom = buffer.length >= 3 &&
        buffer[0] == 0xEF &&
        buffer[1] == 0xBB &&
        buffer[2] == 0xBF;
    final String decoded = utf8.decode(buffer, allowMalformed: true);
    return hasBom ? '\uFEFF$decoded' : decoded;
  }

  /// Uses subarray semantics (a view, not a copy) via Uint8List.sublistView.
  VSBuffer slice([int? start, int? end]) {
    final int s = start ?? 0;
    final int e = end ?? buffer.length;
    return VSBuffer(Uint8List.sublistView(buffer, s, e));
  }

  /// 1:1: `set` overloads collapsed to VSBuffer or Uint8List.
  void set(Object array, [int offset = 0]) {
    if (array is VSBuffer) {
      buffer.setRange(offset, offset + array.buffer.length, array.buffer);
    } else if (array is Uint8List) {
      buffer.setRange(offset, offset + array.length, array);
    } else {
      throw ArgumentError("Unknown argument 'array'");
    }
  }

  int readUInt32BE(int offset) => readUInt32BE_(buffer, offset);

  void writeUInt32BE(int value, int offset) =>
      writeUInt32BE_(buffer, value, offset);

  int readUInt32LE(int offset) => readUInt32LE_(buffer, offset);

  void writeUInt32LE(int value, int offset) =>
      writeUInt32LE_(buffer, value, offset);

  int readUInt8(int offset) => readUInt8_(buffer, offset);

  void writeUInt8(int value, int offset) => writeUInt8_(buffer, value, offset);

  int indexOf(Object subarray, [int offset = 0]) {
    return binaryIndexOf(
        buffer, subarray is VSBuffer ? subarray.buffer : subarray as Uint8List,
        offset);
  }

  bool equals(VSBuffer other) {
    if (identical(this, other)) {
      return true;
    }
    if (byteLength != other.byteLength) {
      return false;
    }
    for (int i = 0; i < byteLength; i++) {
      if (buffer[i] != other.buffer[i]) {
        return false;
      }
    }
    return true;
  }
}

/// Like String.indexOf, but for byte arrays. Boyer-Moore-Horspool.
int binaryIndexOf(Uint8List haystack, Uint8List needle, [int offset = 0]) {
  final int needleLen = needle.length;
  final int haystackLen = haystack.length;

  if (needleLen == 0) {
    return 0;
  }
  if (needleLen == 1) {
    return haystack.indexOf(needle[0], offset);
  }
  if (needleLen > haystackLen - offset) {
    return -1;
  }

  final Uint8List table = _indexOfTable.value;
  table.fillRange(0, table.length, needle.length);
  for (int i = 0; i < needle.length; i++) {
    table[needle[i]] = needle.length - i - 1;
  }

  int i = offset + needle.length - 1;
  int j = i;
  int result = -1;
  while (i < haystackLen) {
    if (haystack[i] == needle[j]) {
      if (j == 0) {
        result = i;
        break;
      }
      i--;
      j--;
    } else {
      final int tableVal = table[haystack[i]];
      final int skip = needle.length - j > tableVal ? needle.length - j : tableVal;
      i += skip;
      j = needle.length - 1;
    }
  }
  return result;
}

/// 1:1: `export function readUInt16LE`
int readUInt16LE(Uint8List source, int offset) {
  return ((source[offset + 0] << 0) & 0xFFFFFFFF) |
      ((source[offset + 1] << 8) & 0xFFFFFFFF);
}

/// 1:1: `export function writeUInt16LE`
void writeUInt16LE(Uint8List destination, int value, int offset) {
  destination[offset + 0] = (value & 0xFF);
  value = _ushr(value, 8);
  destination[offset + 1] = (value & 0xFF);
}

/// 1:1: `export function readUInt32BE`
int readUInt32BE_(Uint8List source, int offset) {
  return source[offset] * (1 << 24) +
      source[offset + 1] * (1 << 16) +
      source[offset + 2] * (1 << 8) +
      source[offset + 3];
}

/// 1:1: `export function writeUInt32BE`
void writeUInt32BE_(Uint8List destination, int value, int offset) {
  destination[offset + 3] = (value & 0xFF);
  value = _ushr(value, 8);
  destination[offset + 2] = (value & 0xFF);
  value = _ushr(value, 8);
  destination[offset + 1] = (value & 0xFF);
  value = _ushr(value, 8);
  destination[offset] = (value & 0xFF);
}

/// 1:1: `export function readUInt32LE`
int readUInt32LE_(Uint8List source, int offset) {
  return ((source[offset + 0] << 0) & 0xFFFFFFFF) |
      ((source[offset + 1] << 8) & 0xFFFFFFFF) |
      ((source[offset + 2] << 16) & 0xFFFFFFFF) |
      ((source[offset + 3] << 24) & 0xFFFFFFFF);
}

/// 1:1: `export function writeUInt32LE`
void writeUInt32LE_(Uint8List destination, int value, int offset) {
  destination[offset + 0] = (value & 0xFF);
  value = _ushr(value, 8);
  destination[offset + 1] = (value & 0xFF);
  value = _ushr(value, 8);
  destination[offset + 2] = (value & 0xFF);
  value = _ushr(value, 8);
  destination[offset + 3] = (value & 0xFF);
}

/// 1:1: `export function readUInt8`
int readUInt8_(Uint8List source, int offset) => source[offset];

/// 1:1: `export function writeUInt8`
void writeUInt8_(Uint8List destination, int value, int offset) =>
    destination[offset] = value;

/// 1:1: `interface VSBufferReadable`
typedef VSBufferReadable = streams.Readable<VSBuffer>;

/// 1:1: `interface VSBufferReadableStream`
typedef VSBufferReadableStream = streams.ReadableStream<VSBuffer>;

/// 1:1: `interface VSBufferWriteableStream`
typedef VSBufferWriteableStream = streams.WriteableStream<VSBuffer>;

/// 1:1: `interface VSBufferReadableBufferedStream`
typedef VSBufferReadableBufferedStream = streams.ReadableBufferedStream<VSBuffer>;

/// 1:1: `export function readableToBuffer`
VSBuffer readableToBuffer(VSBufferReadable readable) {
  return streams.consumeReadable<VSBuffer>(readable, (List<VSBuffer> chunks) =>
      chunks.length == 1 ? chunks[0] : VSBuffer.concat(chunks));
}

/// 1:1: `export function bufferToReadable`
VSBufferReadable bufferToReadable(VSBuffer buffer) =>
    streams.toReadable<VSBuffer>(buffer);

/// 1:1: `export function streamToBuffer`
Future<VSBuffer> streamToBuffer(VSBufferReadableStream stream) async {
  final Object? result = await streams.consumeStream<VSBuffer>(
      stream, (List<VSBuffer> chunks) =>
          chunks.length == 1 ? chunks[0] : VSBuffer.concat(chunks));
  return result as VSBuffer;
}

/// 1:1: `export async function bufferedStreamToBuffer`
Future<VSBuffer> bufferedStreamToBuffer(
    VSBufferReadableBufferedStream bufferedStream) async {
  if (bufferedStream.ended) {
    return VSBuffer.concat(bufferedStream.buffer);
  }
  return VSBuffer.concat(<VSBuffer>[
    ...bufferedStream.buffer,
    await streamToBuffer(bufferedStream.stream),
  ]);
}

/// 1:1: `export function bufferToStream`
streams.ReadableStream<VSBuffer> bufferToStream(VSBuffer buffer) =>
    streams.toStream<VSBuffer>(
        buffer, (List<VSBuffer> chunks) => VSBuffer.concat(chunks));

/// 1:1: `export function streamToBufferReadableStream`
streams.ReadableStream<VSBuffer> streamToBufferReadableStream(
        streams.ReadableStreamEvents<Object?> stream) =>
    streams.transform<Object?, VSBuffer>(
      stream,
      streams.ITransformer<Object?, VSBuffer>(
          (Object? data) => data is String ? VSBuffer.fromString(data) : VSBuffer.wrap(data as Uint8List)),
      (List<VSBuffer> chunks) => VSBuffer.concat(chunks),
    );

/// 1:1: `export function newWriteableBufferStream`
streams.WriteableStream<VSBuffer> newWriteableBufferStream(
        [streams.WriteableStreamOptions? options]) =>
    streams.newWriteableStream<VSBuffer>(
        (List<VSBuffer> chunks) => VSBuffer.concat(chunks), options);

/// 1:1: `export function prefixedBufferReadable`
VSBufferReadable prefixedBufferReadable(
        VSBuffer prefix, VSBufferReadable readable) =>
    streams.prefixedReadable<VSBuffer>(
        prefix, readable, (List<VSBuffer> chunks) => VSBuffer.concat(chunks));

/// 1:1: `export function prefixedBufferStream`
VSBufferReadableStream prefixedBufferStream(
        VSBuffer prefix, VSBufferReadableStream stream) =>
    streams.prefixedStream<VSBuffer>(
        prefix, stream, (List<VSBuffer> chunks) => VSBuffer.concat(chunks));

/// Decodes base64 to a byte array. URL-encoded and unpadded base64 allowed.
VSBuffer decodeBase64(String encoded) {
  // No native Uint8Array.fromBase64 in Dart: use the permissive fallback loop.
  int building = 0;
  int remainder = 0;
  int bufi = 0;

  final Uint8List buffer = Uint8List((encoded.length / 4 * 3).floor());

  void append(int value) {
    switch (remainder) {
      case 3:
        buffer[bufi++] = building | value;
        remainder = 0;
        break;
      case 2:
        buffer[bufi++] = building | (_ushr(value, 2));
        building = value << 6;
        remainder = 3;
        break;
      case 1:
        buffer[bufi++] = building | (_ushr(value, 4));
        building = value << 4;
        remainder = 2;
        break;
      default:
        building = value << 2;
        remainder = 1;
    }
  }

  for (int i = 0; i < encoded.length; i++) {
    final int code = encoded.codeUnitAt(i);
    if (code >= 65 && code <= 90) {
      append(code - 65);
    } else if (code >= 97 && code <= 122) {
      append(code - 97 + 26);
    } else if (code >= 48 && code <= 57) {
      append(code - 48 + 52);
    } else if (code == 43 || code == 45) {
      append(62);
    } else if (code == 47 || code == 95) {
      append(63);
    } else if (code == 61) {
      break;
    } else {
      throw FormatException('Unexpected base64 character ${encoded[i]}');
    }
  }

  final int unpadded = bufi;
  while (remainder > 0) {
    append(0);
  }

  return VSBuffer.wrap(buffer).slice(0, unpadded);
}

const String _base64Alphabet =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
const String _base64UrlSafeAlphabet =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

/// Encodes a buffer to a base64 string.
String encodeBase64(VSBuffer bufferObject,
    [bool padded = true, bool urlSafe = false]) {
  final Uint8List buffer = bufferObject.buffer;
  final String dictionary = urlSafe ? _base64UrlSafeAlphabet : _base64Alphabet;
  final StringBuffer output = StringBuffer();

  final int remainder = buffer.length % 3;

  int i = 0;
  for (; i < buffer.length - remainder; i += 3) {
    final int a = buffer[i + 0];
    final int b = buffer[i + 1];
    final int c = buffer[i + 2];

    output.write(dictionary[_ushr(a, 2)]);
    output.write(dictionary[(a << 4 | _ushr(b, 4)) & 0x3F]);
    output.write(dictionary[(b << 2 | _ushr(c, 6)) & 0x3F]);
    output.write(dictionary[c & 0x3F]);
  }

  if (remainder == 1) {
    final int a = buffer[i + 0];
    output.write(dictionary[_ushr(a, 2)]);
    output.write(dictionary[(a << 4) & 0x3F]);
    if (padded) output.write('==');
  } else if (remainder == 2) {
    final int a = buffer[i + 0];
    final int b = buffer[i + 1];
    output.write(dictionary[_ushr(a, 2)]);
    output.write(dictionary[(a << 4 | _ushr(b, 4)) & 0x3F]);
    output.write(dictionary[(b << 2) & 0x3F]);
    if (padded) output.write('=');
  }

  return output.toString();
}

const String _hexChars = '0123456789abcdef';

/// 1:1: `export function encodeHex`
String encodeHex(VSBuffer bufferObject) {
  final Uint8List buffer = bufferObject.buffer;
  final StringBuffer result = StringBuffer();
  for (int i = 0; i < buffer.length; i++) {
    final int byte = buffer[i];
    result.write(_hexChars[_ushr(byte, 4)]);
    result.write(_hexChars[byte & 0x0f]);
  }
  return result.toString();
}

/// 1:1: `export function decodeHex`
VSBuffer decodeHex(String hex) {
  if (hex.length % 2 != 0) {
    throw FormatException('Hex string must have an even length');
  }
  final Uint8List out = Uint8List(hex.length >> 1);
  for (int i = 0; i < hex.length;) {
    out[i >> 1] = (_decodeHexChar(hex, i++) << 4) | _decodeHexChar(hex, i++);
  }
  return VSBuffer.wrap(out);
}

int _decodeHexChar(String str, int position) {
  final int s = str.codeUnitAt(position);
  if (s >= 48 && s <= 57) {
    return s - 48;
  } else if (s >= 97 && s <= 102) {
    return s - 87;
  } else if (s >= 65 && s <= 70) {
    return s - 55;
  } else {
    throw FormatException('Invalid hex character at position $position');
  }
}
