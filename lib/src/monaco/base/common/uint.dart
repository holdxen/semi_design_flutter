// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/uint.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `const enum Constants` carried as a class
// with `static const` so call sites `Constants.X` are unchanged. `v | 0` -> toInt.
// ---------------------------------------------------------------------------

class Constants {
  const Constants._();

  /// MAX SMI (SMall Integer) as defined in v8.
  /// one bit is lost for boxing/unboxing flag.
  /// one bit is lost for sign flag.
  static const int MAX_SAFE_SMALL_INTEGER = 1 << 30;

  /// MIN SMI (SMall Integer) as defined in v8.
  /// one bit is lost for boxing/unboxing flag.
  /// one bit is lost for sign flag.
  static const int MIN_SAFE_SMALL_INTEGER = -(1 << 30);

  /// Max unsigned integer that fits on 8 bits.
  static const int MAX_UINT_8 = 255; // 2^8 - 1

  /// Max unsigned integer that fits on 16 bits.
  static const int MAX_UINT_16 = 65535; // 2^16 - 1

  /// Max unsigned integer that fits on 32 bits.
  static const int MAX_UINT_32 = 4294967295; // 2^32 - 1

  static const int UNICODE_SUPPLEMENTARY_PLANE_BEGIN = 0x010000;
}

int toUint8(num v) {
  if (v < 0) {
    return 0;
  }
  if (v > Constants.MAX_UINT_8) {
    return Constants.MAX_UINT_8;
  }
  return v.toInt();
}

int toUint32(num v) {
  if (v < 0) {
    return 0;
  }
  if (v > Constants.MAX_UINT_32) {
    return Constants.MAX_UINT_32;
  }
  return v.toInt();
}
