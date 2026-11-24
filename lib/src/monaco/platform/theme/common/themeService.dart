// 1:1 port of vscode/src/vs/platform/theme/common/themeService.ts

import '../../../base/common/color.dart' show Color;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable, IDisposable, toDisposable;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../registry/common/platform.dart' show Registry;
import '../../environment/common/environment.dart' show IEnvironmentServiceType;
import './theme.dart' as theme;
import './iconRegistry.dart' show IconContribution, IconDefinition;
import './colorRegistry.dart' show ColorIdentifier;
import '../../../base/common/codicons.dart' show Codicon;
import '../../../base/common/themables.dart' show ThemeIcon;

/// 1:1: `export const IThemeService = createDecorator<IThemeService>('themeService')`
final ServiceIdentifier<IThemeServiceType> IThemeService =
    createDecorator<IThemeServiceType>('themeService');

/// 1:1: `export function themeColorFromId(id)`
Map<String, Object?> themeColorFromId(ColorIdentifier id) =>
    <String, Object?>{'id': id};

/// 1:1: `export const FileThemeIcon = Codicon.file`
final ThemeIcon FileThemeIcon = Codicon['file']!;

/// 1:1: `export const FolderThemeIcon = Codicon.folder`
final ThemeIcon FolderThemeIcon = Codicon['folder']!;

/// 1:1: `export function getThemeTypeSelector(type)`
theme.ThemeTypeSelector getThemeTypeSelector(theme.ColorScheme type) {
  switch (type) {
    case theme.ColorScheme.dark:
      return theme.ThemeTypeSelector.vsDark;
    case theme.ColorScheme.highContrastDark:
      return theme.ThemeTypeSelector.hcBlack;
    case theme.ColorScheme.highContrastLight:
      return theme.ThemeTypeSelector.hcLight;
    default:
      return theme.ThemeTypeSelector.vs;
  }
}

/// 1:1: `export interface ITokenStyle`
class ITokenStyle {
  final int? foreground;
  final bool? bold;
  final bool? underline;
  final bool? strikethrough;
  final bool? italic;
  ITokenStyle({
    this.foreground,
    this.bold,
    this.underline,
    this.strikethrough,
    this.italic,
  });
}

/// 1:1: `export interface IColorTheme`
abstract class IColorTheme {
  theme.ColorScheme get type;
  String get label;
  Color? getColor(ColorIdentifier color, [bool? useDefault]);
  bool defines(ColorIdentifier color);
  ITokenStyle? getTokenStyleMetadata(
      String type, List<String> modifiers, String modelLanguage);
  List<String> get tokenColorMap;
  List<IFontTokenOptions> get tokenFontMap;
  bool get semanticHighlighting;
}

/// 1:1: `export class IFontTokenOptions`
class IFontTokenOptions {
  String? fontFamily;
  num? fontSizeMultiplier;
  num? lineHeightMultiplier;
}

/// 1:1: `export interface IFileIconTheme`
abstract class IFileIconTheme {
  bool get hasFileIcons;
  bool get hasFolderIcons;
  bool get hidesExplorerArrows;
}

/// 1:1: `export interface IProductIconTheme`
abstract class IProductIconTheme {
  IconDefinition? getIcon(IconContribution iconContribution);
}

/// 1:1: `export interface ICssStyleCollector`
abstract class ICssStyleCollector {
  void addRule(String rule);
}

/// 1:1: `export interface IThemingParticipant`
typedef IThemingParticipant = void Function(
    IColorTheme theme, ICssStyleCollector collector, IEnvironmentServiceType environment);

/// 1:1: `export interface IThemeService`
abstract class IThemeServiceType {
  Object? get _serviceBrand;
  IColorTheme getColorTheme();
  Event<IColorTheme> get onDidColorThemeChange;
  IFileIconTheme getFileIconTheme();
  Event<IFileIconTheme> get onDidFileIconThemeChange;
  IProductIconTheme getProductIconTheme();
  Event<IProductIconTheme> get onDidProductIconThemeChange;
}

/// 1:1: `export const Extensions`
class ThemeServiceExtensions {
  static const String ThemingContribution = 'base.contributions.theming';
}

/// 1:1: `export interface IThemingRegistry`
abstract class IThemingRegistry {
  IDisposable onColorThemeChange(IThemingParticipant participant);
  List<IThemingParticipant> getThemingParticipants();
  Event<IThemingParticipant> get onThemingParticipantAdded;
}

/// 1:1: `class ThemingRegistry extends Disposable implements IThemingRegistry`
class ThemingRegistry extends Disposable implements IThemingRegistry {
  final List<IThemingParticipant> _themingParticipants = <IThemingParticipant>[];
  late final Emitter<IThemingParticipant> _onThemingParticipantAddedEmitter;

  ThemingRegistry() : super() {
    _onThemingParticipantAddedEmitter =
        register(Emitter<IThemingParticipant>());
  }

  @override
  IDisposable onColorThemeChange(IThemingParticipant participant) {
    _themingParticipants.add(participant);
    _onThemingParticipantAddedEmitter.fire(participant);
    return toDisposable(() {
      final int idx = _themingParticipants.indexOf(participant);
      if (idx != -1) _themingParticipants.removeAt(idx);
    });
  }

  @override
  Event<IThemingParticipant> get onThemingParticipantAdded =>
      _onThemingParticipantAddedEmitter.event;

  @override
  List<IThemingParticipant> getThemingParticipants() => _themingParticipants;
}

final ThemingRegistry _themingRegistry = ThemingRegistry();

void _ensureRegistered() {
  if (!Registry.knows(ThemeServiceExtensions.ThemingContribution)) {
    Registry.add(ThemeServiceExtensions.ThemingContribution, _themingRegistry);
  }
}

/// 1:1: `export function registerThemingParticipant(participant)`
IDisposable registerThemingParticipant(IThemingParticipant participant) {
  _ensureRegistered();
  return _themingRegistry.onColorThemeChange(participant);
}

/// 1:1: `export class Themable extends Disposable`
class Themable extends Disposable {
  late IColorTheme theme;
  final IThemeServiceType themeService;

  Themable(this.themeService) : super() {
    theme = themeService.getColorTheme();
    register(themeService.onDidColorThemeChange((dynamic t) => onThemeChange(t as IColorTheme)));
  }

  void onThemeChange(IColorTheme newTheme) {
    theme = newTheme;
    updateStyles();
  }

  void updateStyles() {
    // Subclasses to override
  }

  /// 1:1: `protected getColor(id, modify?)`
  String? getColor(String id,
      [Color Function(Color color, IColorTheme theme)? modify]) {
    Color? color = theme.getColor(id);
    if (color != null && modify != null) {
      color = modify(color, theme);
    }
    return color?.toString();
  }
}

/// 1:1: `export interface IPartsSplash` — data carrier, mirrors the TS shape.
class IPartsSplash {
  num? zoomLevel;
  theme.ThemeTypeSelector? baseTheme;
  Map<String, Object?>? colorInfo;
  Map<String, Object?>? layoutInfo;

  IPartsSplash();
}

/// 1:1: `export interface IPartsSplashPartBounds`
class IPartsSplashPartBounds {
  num top = 0;
  num left = 0;
  num width = 0;
  num height = 0;
  num? cornerRadius;
  Map<String, Object?>? outerEdges;
}
