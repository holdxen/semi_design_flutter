// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/stringBuilder.test.ts
// Translated 1:1. The 3 `decodeUTF16LE` cases and the 1 `StringBuilder` case
// become Dart functions carrying the exact assertions.
// ---------------------------------------------------------------------------

import 'dart:typed_data' show Uint8List;

import '../../../../base/common/buffer.dart' show writeUInt16LE;
import '../../../../base/common/charCode.dart' show CharCode;
import '../../../common/core/stringBuilder.dart'
    show StringBuilder, decodeUTF16LE;

/// 1:1: `test('issue #118041: unicode character undo bug 1')`
void testDecodeUtf16LeBug1() {
  final Uint8List buff = Uint8List(2);
  writeUInt16LE(buff, '\uFEFF'.codeUnitAt(0), 0);
  final String actual = decodeUTF16LE(buff, 0, 1);
  assert(actual == '\uFEFF');
}

/// 1:1: `test('issue #118041: unicode character undo bug 2')`
void testDecodeUtf16LeBug2() {
  final Uint8List buff = Uint8List(4);
  writeUInt16LE(buff, 'a\uFEFF'.codeUnitAt(0), 0);
  writeUInt16LE(buff, 'a\uFEFF'.codeUnitAt(1), 2);
  final String actual = decodeUTF16LE(buff, 0, 2);
  assert(actual == 'a\uFEFF');
}

/// 1:1: `test('issue #118041: unicode character undo bug 3')`
void testDecodeUtf16LeBug3() {
  final Uint8List buff = Uint8List(6);
  writeUInt16LE(buff, 'a\uFEFFb'.codeUnitAt(0), 0);
  writeUInt16LE(buff, 'a\uFEFFb'.codeUnitAt(1), 2);
  writeUInt16LE(buff, 'a\uFEFFb'.codeUnitAt(2), 4);
  final String actual = decodeUTF16LE(buff, 0, 3);
  assert(actual == 'a\uFEFFb');
}

/// 1:1: `test('basic')`
void testStringBuilderBasic() {
  final StringBuilder sb = StringBuilder(100);
  sb.appendASCIICharCode(CharCode.A);
  sb.appendASCIICharCode(CharCode.Space);
  sb.appendString('😊');
  assert(sb.build() == 'A 😊');
}

void runAll() {
  testDecodeUtf16LeBug1();
  testDecodeUtf16LeBug2();
  testDecodeUtf16LeBug3();
  testStringBuilderBasic();
}
