// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/standalone/common/standaloneTheme.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `type BuiltinTheme = 'vs' | 'vs-dark' | 'hc-black' | 'hc-light'` is a
//    string-union type in TS; carried as a class of string constants (same
//    convention as other string unions in this port), with `BuiltinThemeValue`
//    as the alias used by `IStandaloneThemeData.base`.
//  * `{ [colorId: string]: string }` → `Map<String, String>`.
//  * `IStandaloneThemeService extends IThemeService` → extends the ported
//    `IThemeServiceType` (`_serviceBrand` comes from there).
// ---------------------------------------------------------------------------
import '../../../base/common/color.dart' show Color;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../../platform/theme/common/themeService.dart'
    show IColorTheme, IThemeServiceType;
import '../../common/languages/supports/tokenization.dart'
    show ITokenThemeRule, TokenTheme;

/// 1:1: `export const IStandaloneThemeService = createDecorator<...>('themeService')`
/// (TS value/type namespace clash: the interface gets the `Type` suffix, same
/// convention as `telemetry.dart`.)
final ServiceIdentifier<IStandaloneThemeServiceType> IStandaloneThemeService =
    createDecorator<IStandaloneThemeServiceType>('themeService');

/// 1:1: `export type BuiltinTheme = 'vs' | 'vs-dark' | 'hc-black' | 'hc-light'`.
class BuiltinTheme {
  static const String vs = 'vs';
  static const String vsDark = 'vs-dark';
  static const String hcBlack = 'hc-black';
  static const String hcLight = 'hc-light';

  const BuiltinTheme._();
}

/// The carrier for a `BuiltinTheme` value.
typedef BuiltinThemeValue = String;

/// 1:1: `export type IColors = { [colorId: string]: string }`.
typedef IColors = Map<String, String>;

/// 1:1: `export interface IStandaloneThemeData`.
class IStandaloneThemeData {
  IStandaloneThemeData({
    required this.base,
    required this.inherit,
    required this.rules,
    this.encodedTokensColors,
    required this.colors,
  });

  final BuiltinThemeValue base;
  final bool inherit;
  final List<ITokenThemeRule> rules;
  final List<String>? encodedTokensColors;
  final IColors colors;
}

/// 1:1: `export interface IStandaloneTheme extends IColorTheme`.
abstract class IStandaloneTheme implements IColorTheme {
  TokenTheme get tokenTheme;
  String get themeName;
}

/// 1:1: `export interface IStandaloneThemeService extends IThemeService`.
abstract class IStandaloneThemeServiceType implements IThemeServiceType {
  void setTheme(String themeName);

  void setAutoDetectHighContrast(bool autoDetectHighContrast);

  void defineTheme(String themeName, IStandaloneThemeData themeData);

  IStandaloneTheme getColorTheme();

  void setColorMapOverride(List<Color>? colorMapOverride);
}