// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewLayout/linePart.ts
// Translated 1:1 from TypeScript. `const enum LinePartMetadata` -> class with
// static const members (bit masks preserved verbatim, incl. 0b literals).
// The `_linePartBrand: void` nominal field -> a private marker field.
// ---------------------------------------------------------------------------

/// 1:1: `export const enum LinePartMetadata`
class LinePartMetadata {
  static const int IS_WHITESPACE = 1;
  static const int PSEUDO_BEFORE = 2;
  static const int PSEUDO_AFTER = 4;

  // Source uses binary literals 0b001 / 0b010 / 0b100 (Dart has no 0b form);
  // decimal values are identical.
  static const int IS_WHITESPACE_MASK = 1; // 0b001
  static const int PSEUDO_BEFORE_MASK = 2; // 0b010
  static const int PSEUDO_AFTER_MASK = 4; // 0b100
}

/// 1:1: `export class LinePart`
class LinePart {
  /// Nominal brand field (source: `_linePartBrand: void = undefined`).
  // ignore: unused_field
  final Object? _linePartBrand;

  /// last char index of this token (not inclusive).
  final int endIndex;
  final String type;
  final int metadata;
  final bool containsRTL;

  LinePart(this.endIndex, this.type, this.metadata, this.containsRTL)
      : _linePartBrand = null;

  /// 1:1: `public isWhitespace(): boolean`
  bool isWhitespace() {
    return (metadata & LinePartMetadata.IS_WHITESPACE_MASK) != 0;
  }

  /// 1:1: `public isPseudoAfter(): boolean`
  bool isPseudoAfter() {
    return (metadata & LinePartMetadata.PSEUDO_AFTER_MASK) != 0;
  }
}
