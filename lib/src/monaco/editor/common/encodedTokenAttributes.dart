// 1:1 translation of
// vscode/src/vs/editor/common/encodedTokenAttributes.ts
// const enums -> class + static const; bit operations mirror the TS source.
// Dart int is arbitrary precision, so `>>> 0` (unsigned 32-bit) is emulated
// where the source relies on it; masks here are non-negative so plain `>>`
// yields the same result for every field.

/// 1:1: `const enum LanguageId` (open ended at runtime)
class LanguageId {
  static const int nullId = 0; // source: Null (Dart keyword)
  static const int plainText = 1;
}

/// 1:1: `const enum FontStyle`
class FontStyle {
  static const int notSet = -1;
  static const int none = 0;
  static const int italic = 1;
  static const int bold = 2;
  static const int underline = 4;
  static const int strikethrough = 8;
}

/// 1:1: `const enum ColorId`
class ColorId {
  static const int none = 0;
  static const int defaultForeground = 1;
  static const int defaultBackground = 2;
}

/// 1:1: `const enum StandardTokenType`
class StandardTokenType {
  static const int other = 0;
  static const int comment = 1;
  static const int string = 2;
  static const int regEx = 3;
}

/// 1:1: `const enum MetadataConsts`
class MetadataConsts {
  static const int languageIdMask = 0x000000FF;
  static const int tokenTypeMask = 0x00000300;
  static const int balancedBracketsMask = 0x00000400;
  static const int fontStyleMask = 0x00007800;
  static const int foregroundMask = 0x00FF8000;
  static const int backgroundMask = 0xFF000000;

  static const int italicMask = 0x00000800;
  static const int boldMask = 0x00001000;
  static const int underlineMask = 0x00002000;
  static const int strikethroughMask = 0x00004000;

  // Semantic tokens cannot set the language id, so we can
  // use the first 8 bits for control purposes
  static const int semanticUseItalic = 0x00000001;
  static const int semanticUseBold = 0x00000002;
  static const int semanticUseUnderline = 0x00000004;
  static const int semanticUseStrikethrough = 0x00000008;
  static const int semanticUseForeground = 0x00000010;
  static const int semanticUseBackground = 0x00000020;

  static const int languageIdOffset = 0;
  static const int tokenTypeOffset = 8;
  static const int balancedBracketsOffset = 10;
  static const int fontStyleOffset = 11;
  static const int foregroundOffset = 15;
  static const int backgroundOffset = 24;
}

/// 1:1: `export class TokenMetadata`
class TokenMetadata {
  static int getLanguageId(int metadata) =>
      (metadata & MetadataConsts.languageIdMask) >> MetadataConsts.languageIdOffset;

  static int getTokenType(int metadata) =>
      (metadata & MetadataConsts.tokenTypeMask) >> MetadataConsts.tokenTypeOffset;

  static bool containsBalancedBrackets(int metadata) =>
      (metadata & MetadataConsts.balancedBracketsMask) != 0;

  static int getFontStyle(int metadata) =>
      (metadata & MetadataConsts.fontStyleMask) >> MetadataConsts.fontStyleOffset;

  static int getForeground(int metadata) =>
      (metadata & MetadataConsts.foregroundMask) >> MetadataConsts.foregroundOffset;

  static int getBackground(int metadata) =>
      (metadata & MetadataConsts.backgroundMask) >> MetadataConsts.backgroundOffset;

  static String getClassNameFromMetadata(int metadata) {
    final int foreground = getForeground(metadata);
    String className = 'mtk$foreground';

    final int fontStyle = getFontStyle(metadata);
    if (fontStyle & FontStyle.italic != 0) {
      className += ' mtki';
    }
    if (fontStyle & FontStyle.bold != 0) {
      className += ' mtkb';
    }
    if (fontStyle & FontStyle.underline != 0) {
      className += ' mtku';
    }
    if (fontStyle & FontStyle.strikethrough != 0) {
      className += ' mtks';
    }

    return className;
  }

  static String getInlineStyleFromMetadata(int metadata, List<String> colorMap) {
    final int foreground = getForeground(metadata);
    final int fontStyle = getFontStyle(metadata);

    String result = 'color: ${colorMap[foreground]};';
    if (fontStyle & FontStyle.italic != 0) {
      result += 'font-style: italic;';
    }
    if (fontStyle & FontStyle.bold != 0) {
      result += 'font-weight: bold;';
    }
    String textDecoration = '';
    if (fontStyle & FontStyle.underline != 0) {
      textDecoration += ' underline';
    }
    if (fontStyle & FontStyle.strikethrough != 0) {
      textDecoration += ' line-through';
    }
    if (textDecoration.isNotEmpty) {
      result += 'text-decoration:$textDecoration;';
    }
    return result;
  }

  static ITokenPresentation getPresentationFromMetadata(int metadata) {
    final int foreground = getForeground(metadata);
    final int fontStyle = getFontStyle(metadata);
    return ITokenPresentation(
      foreground: foreground,
      italic: fontStyle & FontStyle.italic != 0,
      bold: fontStyle & FontStyle.bold != 0,
      underline: fontStyle & FontStyle.underline != 0,
      strikethrough: fontStyle & FontStyle.strikethrough != 0,
    );
  }
}

/// 1:1: `export interface ITokenPresentation`
class ITokenPresentation {
  final int foreground;
  final bool italic;
  final bool bold;
  final bool underline;
  final bool strikethrough;

  ITokenPresentation({
    required this.foreground,
    required this.italic,
    required this.bold,
    required this.underline,
    required this.strikethrough,
  });
}
