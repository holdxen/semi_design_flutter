// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/theme/common/theme.ts
// Translated 1:1 from TypeScript. TS string enums -> Dart enums with explicit
// values via a `.value` getter (Dart enums cannot have string backing
// without an explicit field).
// ---------------------------------------------------------------------------

/// Color scheme used by the OS and by color themes.
///
/// 1:1: `export enum ColorScheme`
enum ColorScheme {
  dark('dark'),
  light('light'),
  highContrastDark('hcDark'),
  highContrastLight('hcLight');

  const ColorScheme(this.value);
  final String value;
}

/// 1:1: `export enum ThemeTypeSelector`
enum ThemeTypeSelector {
  vs('vs'),
  vsDark('vs-dark'),
  hcBlack('hc-black'),
  hcLight('hc-light');

  const ThemeTypeSelector(this.value);
  final String value;
}

/// 1:1: `export function isHighContrast`
bool isHighContrast(ColorScheme scheme) =>
    scheme == ColorScheme.highContrastDark ||
    scheme == ColorScheme.highContrastLight;

/// 1:1: `export function isDark`
bool isDark(ColorScheme scheme) =>
    scheme == ColorScheme.dark || scheme == ColorScheme.highContrastDark;
