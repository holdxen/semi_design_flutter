// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/stringBuilder.ts
// Translated 1:1 from TypeScript.
//   - JS TextDecoder('UTF-16LE'/'UTF-16BE') -> ByteData with explicit endian;
//     StringBuilder._buildBuffer uses String.fromCharCodes(Uint16List) since a
//     Dart String is exactly a sequence of UTF-16 code units (the decoder's
//     platform-endian behaviour is thus reproduced without a decoder object).
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../../base/common/buffer.dart';
import '../../../base/common/platform.dart';
import '../../../base/common/strings.dart' as strings;

/// 1:1: `getPlatformTextDecoder()` - returns the Endian used to decode UTF-16
/// on the current platform.
Endian getPlatformTextDecoder() =>
    isLittleEndian() ? Endian.little : Endian.big;

/// 1:1: `decodeUTF16LE(source, offset, len)`
String decodeUTF16LE(Uint8List source, int offset, int len) {
  // `new Uint16Array(source.buffer, offset, len)` -> view over len units.
  final int first = len > 0
      ? _readU16(source, offset, Endian.little)
      : 0;
  if (len > 0 && (first == 0xFEFF || first == 0xFFFE)) {
    return _compatDecodeUTF16LE(source, offset, len);
  }
  return _decodeUTF16(source, offset, len, Endian.little);
}

/// 1:1: `compatDecodeUTF16LE` - manual decode that keeps a leading BOM.
String _compatDecodeUTF16LE(Uint8List source, int offset, int len) {
  final StringBuffer result = StringBuffer();
  int o = offset;
  for (int i = 0; i < len; i++) {
    final int charCode = readUInt16LE(source, o);
    o += 2;
    result.writeCharCode(charCode);
  }
  return result.toString();
}

/// Decode [len] UTF-16 code units starting at byte offset [offset].
String _decodeUTF16(Uint8List source, int offset, int len, Endian endian) {
  final List<int> units = List<int>.filled(len, 0);
  for (int i = 0; i < len; i++) {
    units[i] = _readU16(source, offset + 2 * i, endian);
  }
  return String.fromCharCodes(units);
}

int _readU16(Uint8List bytes, int offset, Endian endian) {
  final ByteData view = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);
  return view.getUint16(offset, endian);
}

/// 1:1: `export class StringBuilder`
class StringBuilder {
  final int _capacity;
  final Uint16List _buffer;

  List<String>? _completedStrings;
  int _bufferLength;

  StringBuilder(int capacity)
      : _capacity = capacity,
        _buffer = Uint16List(capacity),
        _bufferLength = 0;

  /// 1:1: `reset()`
  void reset() {
    _completedStrings = null;
    _bufferLength = 0;
  }

  /// 1:1: `build()`
  String build() {
    if (_completedStrings != null) {
      _flushBuffer();
      return _completedStrings!.join('');
    }
    return _buildBuffer();
  }

  /// 1:1: `_buildBuffer()`
  String _buildBuffer() {
    if (_bufferLength == 0) {
      return '';
    }
    // Source decodes a Uint16Array view of length _bufferLength with the
    // platform TextDecoder. Dart's String is UTF-16 code units, so this is the
    // exact equivalent (including BOM preservation).
    return String.fromCharCodes(_buffer.sublist(0, _bufferLength));
  }

  /// 1:1: `_flushBuffer()`
  void _flushBuffer() {
    final String bufferString = _buildBuffer();
    _bufferLength = 0;

    if (_completedStrings == null) {
      _completedStrings = <String>[bufferString];
    } else {
      _completedStrings!.add(bufferString);
    }
  }

  /// 1:1: `appendCharCode(charCode)`
  void appendCharCode(int charCode) {
    final int remainingSpace = _capacity - _bufferLength;

    if (remainingSpace <= 1) {
      if (remainingSpace == 0 || strings.isHighSurrogate(charCode)) {
        _flushBuffer();
      }
    }

    _buffer[_bufferLength++] = charCode;
  }

  /// 1:1: `appendASCIICharCode(charCode)`
  void appendASCIICharCode(int charCode) {
    if (_bufferLength == _capacity) {
      _flushBuffer();
    }
    _buffer[_bufferLength++] = charCode;
  }

  /// 1:1: `appendString(str)`
  void appendString(String str) {
    final int strLen = str.length;

    if (_bufferLength + strLen >= _capacity) {
      _flushBuffer();
      _completedStrings!.add(str);
      return;
    }

    for (int i = 0; i < strLen; i++) {
      _buffer[_bufferLength++] = str.codeUnitAt(i);
    }
  }
}
