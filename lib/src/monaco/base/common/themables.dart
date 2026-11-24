// 1:1 port of vscode/src/vs/base/common/themables.ts

/// 1:1: `export type ColorIdentifier = string`
typedef ColorIdentifier = String;

/// 1:1: `export type IconIdentifier = string`
typedef IconIdentifier = String;

/// 1:1: `export interface ThemeColor`
class ThemeColor {
  ThemeColor(this.id);

  final String id;

  /// 1:1: `ThemeColor.isThemeColor(obj: unknown)`
  static bool isThemeColor(Object? obj) =>
      obj != null && _idOf(obj) is String;
}

Object? _idOf(Object obj) {
  if (obj is ThemeColor) return obj.id;
  if (obj is ThemeIcon) return obj.id;
  if (obj is Map) return obj['id'];
  return null;
}

Object? _colorOf(Object obj) {
  if (obj is ThemeIcon) return obj.color;
  if (obj is Map) return obj['color'];
  return null;
}

/// 1:1: `export function themeColorFromId`
ThemeColor themeColorFromId(ColorIdentifier id) => ThemeColor(id);

/// 1:1: `export interface ThemeIcon` + `export namespace ThemeIcon`
class ThemeIcon {
  ThemeIcon(this.id, [this.color]);

  final String id;
  final ThemeColor? color;

  static const String iconNameSegment = r'[A-Za-z0-9]+';
  static const String iconNameExpression = r'[A-Za-z0-9-]+';
  static const String iconModifierExpression = r'~[A-Za-z]+';
  static const String iconNameCharacter = r'[A-Za-z0-9~-]';

  static final RegExp _themeIconIdRegex = RegExp(
      '^($iconNameExpression)($iconModifierExpression)?\$');

  /// 1:1: `ThemeIcon.asClassNameArray`
  static List<String> asClassNameArray(ThemeIcon icon) {
    final RegExpMatch? match = _themeIconIdRegex.firstMatch(icon.id);
    if (match == null) {
      return asClassNameArray(codiconErrorProvider());
    }
    final String id = match.group(1)!;
    final String? modifier = match.group(2);
    final List<String> classNames = <String>['codicon', 'codicon-$id'];
    if (modifier != null) {
      classNames.add('codicon-modifier-${modifier.substring(1)}');
    }
    return classNames;
  }

  /// 1:1: `ThemeIcon.asClassName`
  static String asClassName(ThemeIcon icon) =>
      asClassNameArray(icon).join(' ');

  /// 1:1: `ThemeIcon.asCSSSelector`
  static String asCSSSelector(ThemeIcon icon) =>
      '.${asClassNameArray(icon).join('.')}';

  /// 1:1: `ThemeIcon.isThemeIcon`
  static bool isThemeIcon(Object? obj) {
    if (obj == null) return false;
    final Object? id = _idOf(obj);
    if (id is! String) return false;
    final Object? color = _colorOf(obj);
    return color == null || ThemeColor.isThemeColor(color);
  }

  static final RegExp _regexFromString = RegExp(
      '^\\\$(${iconNameExpression}(?:${iconModifierExpression})?\\)\$');

  /// 1:1: `ThemeIcon.fromString`
  static ThemeIcon? fromString(String str) {
    final RegExpMatch? match = _regexFromString.firstMatch(str);
    if (match == null) return null;
    return ThemeIcon(match.group(1)!);
  }

  /// 1:1: `ThemeIcon.fromId`
  static ThemeIcon fromId(String id) => ThemeIcon(id);

  /// 1:1: `ThemeIcon.modify`
  static ThemeIcon modify(ThemeIcon icon, String? modifier) {
    String id = icon.id;
    final int tildeIndex = id.lastIndexOf('~');
    if (tildeIndex != -1) {
      id = id.substring(0, tildeIndex);
    }
    if (modifier != null) {
      id = '$id~$modifier';
    }
    return ThemeIcon(id);
  }

  /// 1:1: `ThemeIcon.getModifier`
  static String? getModifier(ThemeIcon icon) {
    final int tildeIndex = icon.id.lastIndexOf('~');
    if (tildeIndex != -1) {
      return icon.id.substring(tildeIndex + 1);
    }
    return null;
  }

  /// 1:1: `ThemeIcon.isEqual`
  static bool isEqual(ThemeIcon ti1, ThemeIcon ti2) =>
      ti1.id == ti2.id && ti1.color?.id == ti2.color?.id;

  /// 1:1: `ThemeIcon.isFile`
  static bool isFile(ThemeIcon? icon) =>
      icon?.id == codiconFileProvider().id;

  /// 1:1: `ThemeIcon.isFolder`
  static bool isFolder(ThemeIcon? icon) =>
      icon?.id == codiconFolderProvider().id;
}

/// Cycle-breaking providers for the `codicons.ts` imports in the source.
ThemeIcon Function() codiconErrorProvider = () => ThemeIcon('error');
ThemeIcon Function() codiconFileProvider = () => ThemeIcon('file');
ThemeIcon Function() codiconFolderProvider = () => ThemeIcon('folder');
