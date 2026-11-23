// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/minimap/minimapCharSheet.ts
// Translated 1:1 from TypeScript.
//   - `const enum Constants` -> class with static const members.
//   - The IIFE that builds `allCharCodes` -> a top-level initializer function.
// ---------------------------------------------------------------------------

/// 1:1: `export const enum Constants`
class Constants {
  static const int START_CH_CODE = 32; // Space
  static const int END_CH_CODE = 126; // Tilde (~)
  static const int UNKNOWN_CODE = 65533; // UTF placeholder code
  static const int CHAR_COUNT = END_CH_CODE - START_CH_CODE + 2;

  static const int SAMPLED_CHAR_HEIGHT = 16;
  static const int SAMPLED_CHAR_WIDTH = 10;

  static const int BASE_CHAR_HEIGHT = 2;
  static const int BASE_CHAR_WIDTH = 1;

  static const int RGBA_CHANNELS_CNT = 4;
  static const int RGBA_SAMPLED_ROW_WIDTH = RGBA_CHANNELS_CNT * CHAR_COUNT * SAMPLED_CHAR_WIDTH;
}

/// 1:1: `export const allCharCodes: ReadonlyArray<number> = (() => {...})()`
final List<int> allCharCodes = _buildAllCharCodes();

List<int> _buildAllCharCodes() {
  final List<int> v = <int>[];
  for (int i = Constants.START_CH_CODE; i <= Constants.END_CH_CODE; i++) {
    v.add(i);
  }
  v.add(Constants.UNKNOWN_CODE);
  return v;
}

/// 1:1: `export const getCharIndex = (chCode, fontScale) => {...}`
int getCharIndex(int chCode, int fontScale) {
  chCode -= Constants.START_CH_CODE;
  if (chCode < 0 || chCode > Constants.CHAR_COUNT) {
    if (fontScale <= 2) {
      // for smaller scales, we can get away with using any ASCII character...
      return (chCode + Constants.CHAR_COUNT) % Constants.CHAR_COUNT;
    }
    return Constants.CHAR_COUNT - 1; // unknown symbol
  }
  return chCode;
}
