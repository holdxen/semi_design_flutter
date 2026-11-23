// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/fonts.ts
// Translated 1:1. `mainWindow.queryLocalFonts()` is an injectable provider;
// `console.error` is an injectable sink so library code has no runtime deps.
// ---------------------------------------------------------------------------

import '../common/jsonSchema.dart' show IJSONSchemaSnippet;
import '../common/platform.dart' show isElectron, isMacintosh, isWindows;

/// 1:1: `FontData` carrier (`readonly family: string`).
class FontData {
  const FontData({required this.family});
  final String family;
}

/// 1:1: `mainWindow.queryLocalFonts()` injectable provider.
Future<List<FontData>> Function()? queryLocalFontsProvider;

/// 1:1: injectable `console.error`.
void Function(String) fontsConsoleError = (String message) {};

/// 1:1: `export const DEFAULT_FONT_FAMILY`
String get DEFAULT_FONT_FAMILY => isWindows
    ? '"Segoe WPC", "Segoe UI", sans-serif'
    : isMacintosh
        ? '-apple-system, BlinkMacSystemFont, sans-serif'
        : 'system-ui, "Ubuntu", "Droid Sans", sans-serif';

/// 1:1: `export const getFonts = async (): Promise<string[]>`
Future<List<String>> getFonts() async {
  try {
    final Future<List<FontData>> Function()? provider = queryLocalFontsProvider;
    final List<FontData> fonts = provider == null
        ? <FontData>[]
        : await provider();
    final List<FontData> fontsArray = List<FontData>.from(fonts);
    final List<String> families =
        fontsArray.map((FontData font) => font.family).toList();
    return families;
  } catch (error) {
    fontsConsoleError('Failed to query fonts: $error');
    return <String>[];
  }
}

/// 1:1: `export const getFontSnippets = async (): Promise<IJSONSchemaSnippet[]>`
Future<List<IJSONSchemaSnippet>> getFontSnippets() async {
  if (!isElectron) {
    return <IJSONSchemaSnippet>[];
  }
  final List<String> fonts = await getFonts();
  final List<IJSONSchemaSnippet> snippets = fonts.map((String font) {
    return IJSONSchemaSnippet()..body = font;
  }).toList();
  return snippets;
}
