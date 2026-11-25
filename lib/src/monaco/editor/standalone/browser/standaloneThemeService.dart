// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/standalone/browser/standaloneThemeService.ts
// (436 lines).
//
// Runtime surface: the four theme-name constants, the module-private
// `StandaloneTheme` implementation, `isBuiltinTheme`, `getBuiltinRules`,
// `newBuiltInTheme` and the exported `StandaloneThemeService`.
//
// Adaptations:
//   - `IStandaloneThemeData` / `IStandaloneTheme` are the already-ported
//     interfaces from `standaloneTheme.dart`; `IEnvironmentService` stays
//     erased and is mirrored by a `noSuchMethod` carrier (TS uses
//     `Object.create(null)`). Theming participants that actually read the
//     environment would fail in TS too.
//   - `mainWindow.matchMedia(query)` is bridged through
//     `browser.matchMediaProvider`, the repo's established seam for the DOM
//     `window.matchMedia` (see `base/browser/browser.dart`).
//   - `{[rule: string]: boolean}` -> `Map<String, bool>`; the
//     `ICssStyleCollector` object literal -> `_RuleCollector`.
//   - `ColorScheme` is a Dart enum (port of theme.ts); string values are
//     compared through the enum members.
//   - `_environment` is passed to participants typed as
//     `IEnvironmentServiceType`, so the empty carrier implements it via
//     `noSuchMethod`.
// ---------------------------------------------------------------------------

import '../../../base/browser/browser.dart' as browser
    show
        addMatchMediaChangeListener,
        matchMediaProvider,
        MediaQueryList,
        MediaQueryListEvent;
import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/domStylesheets.dart' as domStylesheets;
import '../../../base/browser/window.dart' show mainWindow;
import '../../../base/common/color.dart' show Color;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart'
    show Disposable, IDisposable, toDisposable;
import '../../../platform/environment/common/environment.dart'
    show IEnvironmentServiceType;
import '../../../platform/registry/common/platform.dart' show Registry;
import '../../../platform/theme/browser/iconsStyleSheet.dart'
    show IIconsStyleSheet, UnthemedProductIconTheme, getIconsStyleSheet;
import '../../../platform/theme/common/colorRegistry.dart'
    show Extensions, IColorRegistry, asCssVariableName;
import '../../../platform/theme/common/theme.dart' show ColorScheme, isDark, isHighContrast;
import '../../../platform/theme/common/themeService.dart' as themeService;
import '../../common/languages.dart' show TokenizationRegistry;
import '../../common/encodedTokenAttributes.dart' show FontStyle, TokenMetadata;
import '../../common/languages/supports/tokenization.dart'
    show
        ITokenThemeRule,
        ThemeTrieElementRule,
        TokenTheme,
        generateTokensCSSForColorMap;
import '../common/standaloneTheme.dart'
    show IStandaloneTheme, IStandaloneThemeData, IStandaloneThemeServiceType;
import '../common/themes.dart' as themes;

const String VS_LIGHT_THEME_NAME = 'vs';
const String VS_DARK_THEME_NAME = 'vs-dark';
const String HC_BLACK_THEME_NAME = 'hc-black';
const String HC_LIGHT_THEME_NAME = 'hc-light';

final IColorRegistry colorRegistry =
    Registry.as(Extensions.ColorContribution) as IColorRegistry;
final themeService.IThemingRegistry themingRegistry =
    Registry.as(themeService.ThemeServiceExtensions.ThemingContribution) as themeService.IThemingRegistry;

class StandaloneTheme implements IStandaloneTheme {
  StandaloneTheme(String name, this.themeData)
      : id = _computeId(name, themeData.base),
        themeName = name.isNotEmpty ? name : themeData.base,
        colors = null,
        _tokenTheme = null;

  static String _computeId(String name, String base) {
    if (name.isNotEmpty) {
      if (isBuiltinTheme(name)) {
        return name;
      }
      return '$base $name';
    }
    return base;
  }

  final String id;

  @override
  final String themeName;

  final IStandaloneThemeData themeData;
  Map<String, Color>? colors;

  /// TS `{ [colorId: string]: Color | undefined }` from `Object.create(null)`.
  final Map<String, Color?> defaultColors = <String, Color?>{};
  TokenTheme? _tokenTheme;

  @override
  String get label => themeName;

  String get base => themeData.base;

  void notifyBaseUpdated() {
    if (themeData.inherit) {
      colors = null;
      _tokenTheme = null;
    }
  }

  Map<String, Color> getColors() {
    Map<String, Color>? colors = this.colors;
    if (colors == null) {
      colors = <String, Color>{};
      for (final MapEntry<String, String> entry in themeData.colors.entries) {
        colors[entry.key] = Color.fromHex(entry.value);
      }
      if (themeData.inherit) {
        final IStandaloneThemeData baseData = getBuiltinRules(themeData.base);
        for (final MapEntry<String, String> entry in baseData.colors.entries) {
          if (!colors.containsKey(entry.key)) {
            colors[entry.key] = Color.fromHex(entry.value);
          }
        }
      }
      this.colors = colors;
    }
    return colors;
  }

  @override
  Color? getColor(String colorId, [bool? useDefault]) {
    final Color? color = getColors()[colorId];
    if (color != null) {
      return color;
    }
    if (useDefault != false) {
      return getDefault(colorId);
    }
    return null;
  }

  Color? getDefault(String colorId) {
    Color? color = defaultColors[colorId];
    if (color != null) {
      return color;
    }
    color = colorRegistry.resolveDefaultColor(colorId, this);
    defaultColors[colorId] = color;
    return color;
  }

  @override
  bool defines(String colorId) => getColors().containsKey(colorId);

  @override
  ColorScheme get type {
    switch (base) {
      case VS_LIGHT_THEME_NAME:
        return ColorScheme.light;
      case HC_BLACK_THEME_NAME:
        return ColorScheme.highContrastDark;
      case HC_LIGHT_THEME_NAME:
        return ColorScheme.highContrastLight;
      default:
        return ColorScheme.dark;
    }
  }

  @override
  TokenTheme get tokenTheme {
    TokenTheme? tokenTheme = _tokenTheme;
    if (tokenTheme == null) {
      List<ITokenThemeRule> rules = <ITokenThemeRule>[];
      List<String> encodedTokensColors = <String>[];
      if (themeData.inherit) {
        final IStandaloneThemeData baseData = getBuiltinRules(themeData.base);
        rules = List<ITokenThemeRule>.of(baseData.rules);
        final List<String>? baseEncoded = baseData.encodedTokensColors;
        if (baseEncoded != null) {
          encodedTokensColors = baseEncoded;
        }
      }
      // Pick up default colors from `editor.foreground` and `editor.background` if available
      final String? editorForeground = themeData.colors['editor.foreground'];
      final String? editorBackground = themeData.colors['editor.background'];
      if (editorForeground != null || editorBackground != null) {
        final ITokenThemeRule rule = ITokenThemeRule(token: '');
        if (editorForeground != null) {
          rule.foreground = editorForeground;
        }
        if (editorBackground != null) {
          rule.background = editorBackground;
        }
        rules.add(rule);
      }
      rules = rules.toList()..addAll(themeData.rules);
      final List<String>? themeEncoded = themeData.encodedTokensColors;
      if (themeEncoded != null) {
        encodedTokensColors = themeEncoded;
      }
      tokenTheme = TokenTheme.createFromRawTokenTheme(rules, encodedTokensColors);
      _tokenTheme = tokenTheme;
    }
    return tokenTheme;
  }

  @override
  themeService.ITokenStyle? getTokenStyleMetadata(
      String type, List<String> modifiers, String modelLanguage) {
    // use theme rules match
    final ThemeTrieElementRule style =
        tokenTheme.matchRule(<String>[type, ...modifiers].join('.'));
    final int metadata = style.metadata;
    final int foreground = TokenMetadata.getForeground(metadata);
    final int fontStyle = TokenMetadata.getFontStyle(metadata);
    return themeService.ITokenStyle(
      foreground: foreground,
      italic: 0 != (fontStyle & FontStyle.italic),
      bold: 0 != (fontStyle & FontStyle.bold),
      underline: 0 != (fontStyle & FontStyle.underline),
      strikethrough: 0 != (fontStyle & FontStyle.strikethrough),
    );
  }

  @override
  List<String> get tokenColorMap => <String>[];

  @override
  List<themeService.IFontTokenOptions> get tokenFontMap =>
      <themeService.IFontTokenOptions>[];

  @override
  final bool semanticHighlighting = false;
}

bool isBuiltinTheme(String themeName) {
  return themeName == VS_LIGHT_THEME_NAME ||
      themeName == VS_DARK_THEME_NAME ||
      themeName == HC_BLACK_THEME_NAME ||
      themeName == HC_LIGHT_THEME_NAME;
}

IStandaloneThemeData getBuiltinRules(String builtinTheme) {
  switch (builtinTheme) {
    case VS_LIGHT_THEME_NAME:
      return themes.vs;
    case VS_DARK_THEME_NAME:
      return themes.vs_dark;
    case HC_BLACK_THEME_NAME:
      return themes.hc_black;
    case HC_LIGHT_THEME_NAME:
      return themes.hc_light;
  }
  // TS switch is exhaustive over the `BuiltinTheme` union.
  throw StateError('Unknown builtin theme: $builtinTheme');
}

StandaloneTheme newBuiltInTheme(String builtinTheme) {
  final IStandaloneThemeData themeData = getBuiltinRules(builtinTheme);
  return StandaloneTheme(builtinTheme, themeData);
}

class StandaloneThemeService extends Disposable
    implements IStandaloneThemeServiceType {
  StandaloneThemeService() {
    _onColorThemeChange = register(Emitter<IStandaloneTheme>());
    onDidColorThemeChange = _onColorThemeChange.event;

    _onFileIconThemeChange = register(Emitter<themeService.IFileIconTheme>());
    onDidFileIconThemeChange = _onFileIconThemeChange.event;

    _onProductIconThemeChange = register(Emitter<themeService.IProductIconTheme>());
    onDidProductIconThemeChange = _onProductIconThemeChange.event;

    _autoDetectHighContrast = true;

    _knownThemes = <String, StandaloneTheme>{};
    _knownThemes![VS_LIGHT_THEME_NAME] = newBuiltInTheme(VS_LIGHT_THEME_NAME);
    _knownThemes![VS_DARK_THEME_NAME] = newBuiltInTheme(VS_DARK_THEME_NAME);
    _knownThemes![HC_BLACK_THEME_NAME] = newBuiltInTheme(HC_BLACK_THEME_NAME);
    _knownThemes![HC_LIGHT_THEME_NAME] = newBuiltInTheme(HC_LIGHT_THEME_NAME);

    final IIconsStyleSheet iconsStyleSheet = register(getIconsStyleSheet(this));

    _codiconCSS = iconsStyleSheet.getCSS();
    _themeCSS = '';
    _allCSS = '$_codiconCSS\n$_themeCSS';
    _globalStyleElement = null;
    _styleElements = <dom.DomElement>[];
    _colorMapOverride = null;
    setTheme(VS_LIGHT_THEME_NAME);
    _onOSSchemeChanged();

    register(iconsStyleSheet.onDidChange((dynamic _) {
      _codiconCSS = iconsStyleSheet.getCSS();
      _updateCSS();
    }));

    browser.addMatchMediaChangeListener(
        mainWindow, '(forced-colors: active)', (browser.MediaQueryListEvent _) {
      // Update theme selection for auto-detecting high contrast
      _onOSSchemeChanged();
    });
  }

  // TS `declare readonly _serviceBrand: undefined` (compile-time brand only).
  @override
  Object? get _serviceBrand => null;

  late final Emitter<IStandaloneTheme> _onColorThemeChange;

  @override
  late final Event<IStandaloneTheme> onDidColorThemeChange;

  late final Emitter<themeService.IFileIconTheme> _onFileIconThemeChange;

  @override
  late final Event<themeService.IFileIconTheme> onDidFileIconThemeChange;

  late final Emitter<themeService.IProductIconTheme> _onProductIconThemeChange;

  @override
  late final Event<themeService.IProductIconTheme> onDidProductIconThemeChange;

  /// TS `private readonly _environment: IEnvironmentService = Object.create(null)`.
  final IEnvironmentServiceType _environment = _EmptyEnvironmentService();

  late final Map<String, StandaloneTheme>? _knownThemes;
  late bool _autoDetectHighContrast;
  late String _codiconCSS;
  late String _themeCSS;
  late String _allCSS;
  dom.DomElement? _globalStyleElement;
  late List<dom.DomElement> _styleElements;
  late List<Color>? _colorMapOverride;

  /// TS `private _theme!: IStandaloneTheme` (read before assignment inside
  /// `_updateActualTheme`, which yields `undefined` there).
  IStandaloneTheme? _theme;

  final UnthemedProductIconTheme _builtInProductIconTheme =
      UnthemedProductIconTheme();

  IDisposable registerEditorContainer(dom.DomElement domNode) {
    if (dom.isInShadowDOM(domNode)) {
      return _registerShadowDomContainer(domNode);
    }
    return _registerRegularEditorContainer();
  }

  IDisposable _registerRegularEditorContainer() {
    if (_globalStyleElement == null) {
      _globalStyleElement = domStylesheets.createStyleSheet(
          null, (dom.DomElement style) {
        style.className = 'monaco-colors';
        style.textContent = _allCSS;
      });
      _styleElements.add(_globalStyleElement!);
    }
    return Disposable.none;
  }

  IDisposable _registerShadowDomContainer(dom.DomElement domNode) {
    final dom.DomElement styleElement =
        domStylesheets.createStyleSheet(domNode, (dom.DomElement style) {
      style.className = 'monaco-colors';
      style.textContent = _allCSS;
    });
    _styleElements.add(styleElement);
    return _ShadowStyleElementDisposable(_styleElements, styleElement);
  }

  @override
  void defineTheme(String themeName, IStandaloneThemeData themeData) {
    if (!RegExp(r'^[a-z0-9\-]+$', caseSensitive: false).hasMatch(themeName)) {
      throw StateError('Illegal theme name!');
    }
    if (!isBuiltinTheme(themeData.base) && !isBuiltinTheme(themeName)) {
      throw StateError('Illegal theme base!');
    }
    // set or replace theme
    _knownThemes![themeName] = StandaloneTheme(themeName, themeData);

    if (isBuiltinTheme(themeName)) {
      _knownThemes!.forEach((String name, StandaloneTheme theme) {
        if (theme.base == themeName) {
          theme.notifyBaseUpdated();
        }
      });
    }
    if (_theme!.themeName == themeName) {
      setTheme(themeName); // refresh theme
    }
  }

  @override
  IStandaloneTheme getColorTheme() => _theme!;

  @override
  void setColorMapOverride(List<Color>? colorMapOverride) {
    _colorMapOverride = colorMapOverride;
    _updateThemeOrColorMap();
  }

  @override
  void setTheme(String themeName) {
    StandaloneTheme? theme;
    if (_knownThemes!.containsKey(themeName)) {
      theme = _knownThemes![themeName];
    } else {
      theme = _knownThemes![VS_LIGHT_THEME_NAME];
    }
    _updateActualTheme(theme);
  }

  void _updateActualTheme(IStandaloneTheme? desiredTheme) {
    if (desiredTheme == null || identical(_theme, desiredTheme)) {
      // Nothing to do
      return;
    }
    _theme = desiredTheme;
    _updateThemeOrColorMap();
  }

  void _onOSSchemeChanged() {
    if (_autoDetectHighContrast) {
      final bool wantsHighContrast = _matchMedia('(forced-colors: active)').matches;
      if (wantsHighContrast != isHighContrast(_theme!.type)) {
        // switch to high contrast or non-high contrast but stick to dark or light
        String newThemeName;
        if (isDark(_theme!.type)) {
          newThemeName =
              wantsHighContrast ? HC_BLACK_THEME_NAME : VS_DARK_THEME_NAME;
        } else {
          newThemeName =
              wantsHighContrast ? HC_LIGHT_THEME_NAME : VS_LIGHT_THEME_NAME;
        }
        _updateActualTheme(_knownThemes![newThemeName]);
      }
    }
  }

  @override
  void setAutoDetectHighContrast(bool autoDetectHighContrast) {
    _autoDetectHighContrast = autoDetectHighContrast;
    _onOSSchemeChanged();
  }

  void _updateThemeOrColorMap() {
    final List<String> cssRules = <String>[];
    final Map<String, bool> hasRule = <String, bool>{};
    final _RuleCollector ruleCollector = _RuleCollector(cssRules, hasRule);
    for (final participant in themingRegistry.getThemingParticipants()) {
      participant(_theme!, ruleCollector, _environment);
    }

    final List<String> colorVariables = <String>[];
    for (final item in colorRegistry.getColors()) {
      final Color? color = _theme!.getColor(item.id, true);
      if (color != null) {
        colorVariables.add('${asCssVariableName(item.id)}: ${color.toString()};');
      }
    }
    ruleCollector.addRule(
        '.monaco-editor, .monaco-diff-editor, .monaco-component { ${colorVariables.join('\n')} }');

    final List<Color?> colorMap =
        _colorMapOverride ?? _theme!.tokenTheme.getColorMap();
    ruleCollector.addRule(generateTokensCSSForColorMap(colorMap));

    // If the OS has forced-colors active, disable forced color adjustment for
    // Monaco editor elements so that VS Code's built-in high contrast themes
    // (hc-black / hc-light) are used instead of the OS forcing system colors.
    ruleCollector.addRule(
        '.monaco-editor, .monaco-diff-editor, .monaco-component { forced-color-adjust: none; }');

    _themeCSS = cssRules.join('\n');
    _updateCSS();

    TokenizationRegistry.setColorMap(colorMap);
    _onColorThemeChange.fire(_theme!);
  }

  void _updateCSS() {
    _allCSS = '$_codiconCSS\n$_themeCSS';
    for (final styleElement in _styleElements) {
      styleElement.textContent = _allCSS;
    }
  }

  @override
  themeService.IFileIconTheme getFileIconTheme() => _FileIconTheme();

  @override
  themeService.IProductIconTheme getProductIconTheme() => _builtInProductIconTheme;
}

/// TS object literal `{ hasFileIcons: false, hasFolderIcons: false, hidesExplorerArrows: false }`.
class _FileIconTheme implements themeService.IFileIconTheme {
  @override
  bool get hasFileIcons => false;

  @override
  bool get hasFolderIcons => false;

  @override
  bool get hidesExplorerArrows => false;
}

/// TS object literal implementing `ICssStyleCollector`, with rule de-duplication.
class _RuleCollector implements themeService.ICssStyleCollector {
  _RuleCollector(this.cssRules, this.hasRule);

  final List<String> cssRules;
  final Map<String, bool> hasRule;

  @override
  void addRule(String rule) {
    if (hasRule[rule] != true) {
      cssRules.add(rule);
      hasRule[rule] = true;
    }
  }
}

/// TS object literal returned by `_registerShadowDomContainer`.
class _ShadowStyleElementDisposable implements IDisposable {
  _ShadowStyleElementDisposable(this.styleElements, this.styleElement);

  final List<dom.DomElement> styleElements;
  final dom.DomElement styleElement;

  @override
  void dispose() {
    for (int i = 0; i < styleElements.length; i++) {
      if (identical(styleElements[i], styleElement)) {
        styleElements.removeAt(i);
        return;
      }
    }
  }
}

/// TS `Object.create(null)` standing in for `IEnvironmentService`.
///
/// Participants that read members would observe `undefined` in TS; here they
/// observe a `noSuchMethod` failure, which is the same "empty carrier" intent.
class _EmptyEnvironmentService implements IEnvironmentServiceType {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

browser.MediaQueryList _matchMedia(String query) =>
    browser.matchMediaProvider!(mainWindow, query);