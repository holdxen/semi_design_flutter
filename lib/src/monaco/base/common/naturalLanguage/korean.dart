// 1:1 translation of vscode/src/vs/base/common/naturalLanguage/korean.ts
// Adaptations (documented inline):
//   - `const enum` → class + static const int.
//   - `ArrayLike<number>` / `Uint32Array` / `Uint8Array` / `Uint16Array` → List<int>.
//   - `codeBuffer.subarray(0, len)` → `List.unmodifiable(codeBuffer.sublist(0, len))`
//     (getKoreanAltChars returns an immutable snapshot like the TS Uint32Array view).
//   - Numeric literal tables parsed verbatim from the TS source (combo values
//     precomputed exactly as the TS `const enum AsciiCodeCombo` expressions).

/// 1:1: `const enum HangulRangeStartCode`
class HangulRangeStartCode {
  static const int initialConsonant = 0x1100;
  static const int vowel = 0x1161;
  static const int finalConsonant = 0x11A8;
  static const int compatibilityJamo = 0x3131;
}

/// 1:1: `const enum AsciiCode`
class AsciiCode {
  static const int NUL = 0;
  static const int A = 65, B = 66, C = 67, D = 68, E = 69, F = 70, G = 71;
  static const int H = 72, I = 73, J = 74, K = 75, L = 76, M = 77, N = 78, O = 79;
  static const int P = 80, Q = 81, R = 82, S = 83, T = 84, U = 85, V = 86, W = 87;
  static const int X = 88, Y = 89, Z = 90;
  static const int a = 97, b = 98, c = 99, d = 100, e = 101, f = 102, g = 103;
  static const int h = 104, i = 105, j = 106, k = 107, l = 108, m = 109, n = 110;
  static const int o = 111, p = 112, q = 113, r = 114, s = 115, t = 116, u = 117;
  static const int v = 118, w = 119, x = 120, y = 121, z = 122;
}

/// 1:1: `const enum AsciiCodeCombo` — precomputed `X << 8 | Y`.
class AsciiCodeCombo {
  static const int fa = 24934; // a << 8 | f
  static const int fg = 26470;
  static const int fq = 29030;
  static const int fr = 29286;
  static const int ft = 29798;
  static const int fv = 30310;
  static const int fx = 30822;
  static const int hk = 27496;
  static const int hl = 27752;
  static const int ho = 28520;
  static const int ml = 27757;
  static const int nj = 27246;
  static const int nl = 27758;
  static const int np = 28782;
  static const int qt = 29809;
  static const int rt = 29810;
  static const int sg = 26483;
  static const int sw = 30579;
}

/// 1:1: `modernConsonants = new Uint8Array([...])` — U+1100..U+1112
const List<int> modernConsonants = <int>[
  AsciiCode.r, // ㄱ
  AsciiCode.R, // ㄲ
  AsciiCode.s, // ㄴ
  AsciiCode.e, // ㄷ
  AsciiCode.E, // ㄸ
  AsciiCode.f, // ㄹ
  AsciiCode.a, // ㅁ
  AsciiCode.q, // ㅂ
  AsciiCode.Q, // ㅃ
  AsciiCode.t, // ㅅ
  AsciiCode.T, // ㅆ
  AsciiCode.d, // ㅇ
  AsciiCode.w, // ㅈ
  AsciiCode.W, // ㅉ
  AsciiCode.c, // ㅊ
  AsciiCode.z, // ㅋ
  AsciiCode.x, // ㅌ
  AsciiCode.v, // ㅍ
  AsciiCode.g, // ㅎ
];

/// 1:1: `modernVowels = new Uint16Array([...])` — U+1161..U+1175
const List<int> modernVowels = <int>[
  AsciiCode.k, // ㅏ
  AsciiCode.o, // ㅐ
  AsciiCode.i, // ㅑ
  AsciiCode.O, // ㅒ
  AsciiCode.j, // ㅓ
  AsciiCode.p, // ㅔ
  AsciiCode.u, // ㅕ
  AsciiCode.P, // ㅖ
  AsciiCode.h, // ㅗ
  AsciiCodeCombo.hk, // ㅘ
  AsciiCodeCombo.ho, // ㅙ
  AsciiCodeCombo.hl, // ㅚ
  AsciiCode.y, // ㅛ
  AsciiCode.n, // ㅜ
  AsciiCodeCombo.nj, // ㅝ
  AsciiCodeCombo.np, // ㅞ
  AsciiCodeCombo.nl, // ㅟ
  AsciiCode.b, // ㅠ
  AsciiCode.m, // ㅡ
  AsciiCodeCombo.ml, // ㅢ
  AsciiCode.l, // ㅣ
];

/// 1:1: `modernFinalConsonants = new Uint16Array([...])` — U+11A8..U+11C2
const List<int> modernFinalConsonants = <int>[
  AsciiCode.r, // ㄱ
  AsciiCode.R, // ㄲ
  AsciiCodeCombo.rt, // ㄳ
  AsciiCode.s, // ㄴ
  AsciiCodeCombo.sw, // ㄵ
  AsciiCodeCombo.sg, // ㄶ
  AsciiCode.e, // ㄷ
  AsciiCode.f, // ㄹ
  AsciiCodeCombo.fr, // ㄺ
  AsciiCodeCombo.fa, // ㄻ
  AsciiCodeCombo.fq, // ㄼ
  AsciiCodeCombo.ft, // ㄽ
  AsciiCodeCombo.fx, // ㄾ
  AsciiCodeCombo.fv, // ㄿ
  AsciiCodeCombo.fg, // ㅀ
  AsciiCode.a, // ㅁ
  AsciiCode.q, // ㅂ
  AsciiCodeCombo.qt, // ㅄ
  AsciiCode.t, // ㅅ
  AsciiCode.T, // ㅆ
  AsciiCode.d, // ㅇ
  AsciiCode.w, // ㅈ
  AsciiCode.c, // ㅊ
  AsciiCode.z, // ㅋ
  AsciiCode.x, // ㅌ
  AsciiCode.v, // ㅍ
  AsciiCode.g, // ㅎ
];

/// 1:1: `compatibilityJamo = new Uint16Array([...])` — U+3131..U+318F
/// (archaic jamo after Hangul Filler are represented by NUL and ignored)
const List<int> compatibilityJamo = <int>[
  AsciiCode.r, // ㄱ
  AsciiCode.R, // ㄲ
  AsciiCodeCombo.rt, // ㄳ
  AsciiCode.s, // ㄴ
  AsciiCodeCombo.sw, // ㄵ
  AsciiCodeCombo.sg, // ㄶ
  AsciiCode.e, // ㄷ
  AsciiCode.E, // ㄸ
  AsciiCode.f, // ㄹ
  AsciiCodeCombo.fr, // ㄺ
  AsciiCodeCombo.fa, // ㄻ
  AsciiCodeCombo.fq, // ㄼ
  AsciiCodeCombo.ft, // ㄽ
  AsciiCodeCombo.fx, // ㄾ
  AsciiCodeCombo.fv, // ㄿ
  AsciiCodeCombo.fg, // ㅀ
  AsciiCode.a, // ㅁ
  AsciiCode.q, // ㅂ
  AsciiCode.Q, // ㅃ
  AsciiCodeCombo.qt, // ㅄ
  AsciiCode.t, // ㅅ
  AsciiCode.T, // ㅆ
  AsciiCode.d, // ㅇ
  AsciiCode.w, // ㅈ
  AsciiCode.W, // ㅉ
  AsciiCode.c, // ㅊ
  AsciiCode.z, // ㅋ
  AsciiCode.x, // ㅌ
  AsciiCode.v, // ㅍ
  AsciiCode.g, // ㅎ
  AsciiCode.k, // ㅏ
  AsciiCode.o, // ㅐ
  AsciiCode.i, // ㅑ
  AsciiCode.O, // ㅒ
  AsciiCode.j, // ㅓ
  AsciiCode.p, // ㅔ
  AsciiCode.u, // ㅕ
  AsciiCode.P, // ㅖ
  AsciiCode.h, // ㅗ
  AsciiCodeCombo.hk, // ㅘ
  AsciiCodeCombo.ho, // ㅙ
  AsciiCodeCombo.hl, // ㅚ
  AsciiCode.y, // ㅛ
  AsciiCode.n, // ㅜ
  AsciiCodeCombo.nj, // ㅝ
  AsciiCodeCombo.np, // ㅞ
  AsciiCodeCombo.nl, // ㅟ
  AsciiCode.b, // ㅠ
  AsciiCode.m, // ㅡ
  AsciiCodeCombo.ml, // ㅢ
  AsciiCode.l, // ㅣ
];

int _codeBufferLength = 0;
final List<int> _codeBuffer = List<int>.filled(10, 0);

/// 1:1: `getKoreanAltChars(code)`
List<int>? getKoreanAltChars(int code) {
  final List<int>? result = disassembleKorean(code);
  if (result != null && result.isNotEmpty) {
    return result;
  }
  return null;
}

/// 1:1: `disassembleKorean(code)`
List<int>? disassembleKorean(int code) {
  _codeBufferLength = 0;

  // Initial consonants (초성)
  getCodesFromArray(code, modernConsonants, HangulRangeStartCode.initialConsonant);
  if (_codeBufferLength > 0) {
    return List<int>.unmodifiable(_codeBuffer.sublist(0, _codeBufferLength));
  }

  // Vowels (중성)
  getCodesFromArray(code, modernVowels, HangulRangeStartCode.vowel);
  if (_codeBufferLength > 0) {
    return List<int>.unmodifiable(_codeBuffer.sublist(0, _codeBufferLength));
  }

  // Final consonants (종성)
  getCodesFromArray(code, modernFinalConsonants, HangulRangeStartCode.finalConsonant);
  if (_codeBufferLength > 0) {
    return List<int>.unmodifiable(_codeBuffer.sublist(0, _codeBufferLength));
  }

  // Hangul Compatibility Jamo
  getCodesFromArray(code, compatibilityJamo, HangulRangeStartCode.compatibilityJamo);
  if (_codeBufferLength != 0) {
    return List<int>.unmodifiable(_codeBuffer.sublist(0, _codeBufferLength));
  }

  // Hangul Syllables
  if (code >= 0xAC00 && code <= 0xD7A3) {
    final int hangulIndex = code - 0xAC00;
    final int vowelAndFinalConsonantProduct = hangulIndex % 588;

    // 0-based starting at 0x1100
    final int initialConsonantIndex = (hangulIndex / 588).floor();
    // 0-based starting at 0x1161
    final int vowelIndex = (vowelAndFinalConsonantProduct / 28).floor();
    // 0-based starting at 0x11A8; subtract 1 as index 0 means no final consonant
    final int finalConsonantIndex = vowelAndFinalConsonantProduct % 28 - 1;

    if (initialConsonantIndex < modernConsonants.length) {
      getCodesFromArray(initialConsonantIndex, modernConsonants, 0);
    } else if (HangulRangeStartCode.initialConsonant + initialConsonantIndex -
            HangulRangeStartCode.compatibilityJamo <
        compatibilityJamo.length) {
      getCodesFromArray(
          HangulRangeStartCode.initialConsonant + initialConsonantIndex,
          compatibilityJamo,
          HangulRangeStartCode.compatibilityJamo);
    }

    if (vowelIndex < modernVowels.length) {
      getCodesFromArray(vowelIndex, modernVowels, 0);
    } else if (HangulRangeStartCode.vowel + vowelIndex -
            HangulRangeStartCode.compatibilityJamo <
        compatibilityJamo.length) {
      getCodesFromArray(
          HangulRangeStartCode.vowel + vowelIndex - HangulRangeStartCode.compatibilityJamo,
          compatibilityJamo,
          HangulRangeStartCode.compatibilityJamo);
    }

    if (finalConsonantIndex >= 0) {
      if (finalConsonantIndex < modernFinalConsonants.length) {
        getCodesFromArray(finalConsonantIndex, modernFinalConsonants, 0);
      } else if (HangulRangeStartCode.finalConsonant + finalConsonantIndex -
              HangulRangeStartCode.compatibilityJamo <
          compatibilityJamo.length) {
        getCodesFromArray(
            HangulRangeStartCode.finalConsonant + finalConsonantIndex -
                HangulRangeStartCode.compatibilityJamo,
            compatibilityJamo,
            HangulRangeStartCode.compatibilityJamo);
      }
    }

    if (_codeBufferLength > 0) {
      return List<int>.unmodifiable(_codeBuffer.sublist(0, _codeBufferLength));
    }
  }
  return null;
}

/// 1:1: `getCodesFromArray(code, array, arrayStartIndex)`
void getCodesFromArray(int code, List<int> array, int arrayStartIndex) {
  if (code >= arrayStartIndex && code < arrayStartIndex + array.length) {
    addCodesToBuffer(array[code - arrayStartIndex]);
  }
}

/// 1:1: `addCodesToBuffer(codes)`
void addCodesToBuffer(int codes) {
  // NUL is ignored, used for archaic characters to avoid a Map for the data.
  if (codes == AsciiCode.NUL) {
    return;
  }
  // Number stored in format: OptionalThirdCode << 16 | OptionalSecondCode << 8 | Code
  _codeBuffer[_codeBufferLength++] = codes & 0xFF;
  if (codes >> 8 != 0) {
    _codeBuffer[_codeBufferLength++] = (codes >> 8) & 0xFF;
  }
  if (codes >> 16 != 0) {
    _codeBuffer[_codeBufferLength++] = (codes >> 16) & 0xFF;
  }
}
