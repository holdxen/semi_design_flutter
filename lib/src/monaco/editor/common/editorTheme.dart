// 1:1 port of vscode/src/vs/editor/common/editorTheme.ts

import '../../base/common/color.dart' show Color;
import '../../platform/theme/common/colorRegistry.dart' show ColorIdentifier;
import '../../platform/theme/common/theme.dart' show ColorScheme;
import '../../platform/theme/common/themeService.dart' show IColorTheme;

class EditorTheme {
  late IColorTheme _theme;

  /// 1:1: `public get type(): ColorScheme`
  ColorScheme get type => _theme.type;

  /// 1:1: `public get value(): IColorTheme`
  IColorTheme get value => _theme;

  EditorTheme(IColorTheme theme) {
    _theme = theme;
  }

  /// 1:1: `public update(theme: IColorTheme): void`
  void update(IColorTheme theme) {
    _theme = theme;
  }

  /// 1:1: `public getColor(color: ColorIdentifier): Color | undefined`
  Color? getColor(ColorIdentifier color) => _theme.getColor(color);
}
