// 1:1 port of vscode/src/vs/platform/theme/test/common/testThemeService.dart

import '../../../../base/common/color.dart' show Color;
import '../../../../base/common/event.dart' show Emitter, Event;
import '../../common/iconRegistry.dart' show IconContribution, IconDefinition;
import '../../common/theme.dart' show ColorScheme;
import '../../common/themeService.dart'
    show
        IColorTheme,
        IFileIconTheme,
        IFontTokenOptions,
        IProductIconTheme,
        ITokenStyle,
        IThemeServiceType;

/// 1:1: `export class TestColorTheme implements IColorTheme`
class TestColorTheme implements IColorTheme {
  TestColorTheme([Map<String, String>? colors, this.type = ColorScheme.dark,
      this.semanticHighlighting = false])
      : _colors = colors ?? <String, String>{};

  final Map<String, String> _colors;

  @override
  final String label = 'test';
  @override
  ColorScheme type;
  @override
  final bool semanticHighlighting;

  @override
  Color? getColor(String color, [bool? useDefault]) {
    final String? value = _colors[color];
    if (value != null) {
      return Color.fromHex(value);
    }
    return null;
  }

  @override
  bool defines(String color) => throw StateError('Method not implemented.');

  @override
  ITokenStyle? getTokenStyleMetadata(
      String type, List<String> modifiers, String modelLanguage) {
    return null;
  }

  @override
  List<String> get tokenColorMap => <String>[];

  @override
  List<IFontTokenOptions> get tokenFontMap => <IFontTokenOptions>[];
}

/// 1:1: `class TestFileIconTheme implements IFileIconTheme`
class TestFileIconTheme implements IFileIconTheme {
  @override
  bool hasFileIcons = false;
  @override
  bool hasFolderIcons = false;
  @override
  bool hidesExplorerArrows = false;
}

/// 1:1: `class UnthemedProductIconTheme implements IProductIconTheme`
class UnthemedProductIconTheme implements IProductIconTheme {
  @override
  IconDefinition? getIcon(IconContribution iconContribution) => null;
}

/// 1:1: `export class TestThemeService implements IThemeService`
class TestThemeService implements IThemeServiceType {
  TestThemeService([
    IColorTheme? theme,
    IFileIconTheme? fileIconTheme,
    IProductIconTheme? productIconTheme,
  ])   : _colorTheme = theme ?? TestColorTheme(),
        _fileIconTheme = fileIconTheme ?? TestFileIconTheme(),
        _productIconTheme = productIconTheme ?? UnthemedProductIconTheme();


  IColorTheme _colorTheme;
  IFileIconTheme _fileIconTheme;
  IProductIconTheme _productIconTheme;
  final Emitter<IColorTheme> _onThemeChange = Emitter<IColorTheme>();
  final Emitter<IFileIconTheme> _onFileIconThemeChange =
      Emitter<IFileIconTheme>();
  final Emitter<IProductIconTheme> _onProductIconThemeChange =
      Emitter<IProductIconTheme>();

  @override
  IColorTheme getColorTheme() => _colorTheme;

  /// 1:1: `setTheme(theme)`
  void setTheme(IColorTheme theme) {
    _colorTheme = theme;
    fireThemeChange();
  }

  /// 1:1: `fireThemeChange()`
  void fireThemeChange() {
    _onThemeChange.fire(_colorTheme);
  }

  @override
  Event<IColorTheme> get onDidColorThemeChange => _onThemeChange.event;

  @override
  IFileIconTheme getFileIconTheme() => _fileIconTheme;

  /// 1:1: `setFileIconTheme(theme)`
  void setFileIconTheme(IFileIconTheme theme) {
    _fileIconTheme = theme;
    _onFileIconThemeChange.fire(theme);
  }

  @override
  Event<IFileIconTheme> get onDidFileIconThemeChange =>
      _onFileIconThemeChange.event;

  @override
  IProductIconTheme getProductIconTheme() => _productIconTheme;

  @override
  Event<IProductIconTheme> get onDidProductIconThemeChange =>
      _onProductIconThemeChange.event;
}
