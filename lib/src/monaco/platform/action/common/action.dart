// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/action/common/action.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `URI` / `UriDto` -> `uri.URI` / `uri.UriDto` (type-only here).
//   - `ContextKeyExpression` -> `contextkey.ContextKeyExpression`.
//   - `ThemeIcon` is type-only in this module; `base/common/themables.dart`
//     joins the codicons cycle and is not ported yet, so the union arm is
//     carried as `Object` until that module is available.
//   - `keyof typeof Categories` -> `Object` (Dart has no keyof).
// ---------------------------------------------------------------------------

import '../../../base/common/uri.dart' as uri;
import '../../contextkey/common/contextkey.dart' as contextkey;
import '../../commands/common/commands.dart' as commands;

/// 1:1: `export interface ILocalizedString`.
class ILocalizedString {
  ILocalizedString({required this.value, required this.original});

  String value;
  String original;
}

/// 1:1: `export function isLocalizedString(thing: unknown): thing is ILocalizedString`.
/// JS structural check is preserved with dynamic property reads so plain maps
/// and class instances behave identically.
bool isLocalizedString(Object? thing) {
  if (thing == null) return false;
  final dynamic t = thing;
  return _stringProperty(t, 'original') && _stringProperty(t, 'value');
}

bool _stringProperty(dynamic t, String key) {
  try {
    final Object? value = t is Map ? t[key] : _readProperty(t, key);
    return value is String;
  } catch (_) {
    return false;
  }
}

Object? _readProperty(dynamic t, String key) {
  switch (key) {
    case 'value':
      return t.value;
    case 'original':
      return t.original;
    default:
      return null;
  }
}

Object? _definedProperty(dynamic t, String key) {
  try {
    return t is Map ? t[key] : t.condition;
  } catch (_) {
    return null;
  }
}

/// 1:1: `export interface ICommandActionTitle extends ILocalizedString`.
class ICommandActionTitle extends ILocalizedString {
  ICommandActionTitle({
    required super.value,
    required super.original,
    this.mnemonicTitle,
  });

  String? mnemonicTitle;
}

/// 1:1: `export type Icon = { dark?: URI; light?: URI } | ThemeIcon`.
/// Dart has no structural union; `Object` is the opaque carrier for either arm.
typedef Icon = Object;

/// 1:1: `export interface ICommandActionToggleInfo`.
class ICommandActionToggleInfo {
  ICommandActionToggleInfo({
    required this.condition,
    this.icon,
    this.tooltip,
    this.title,
    this.mnemonicTitle,
  });

  contextkey.ContextKeyExpression condition;
  Icon? icon;
  String? tooltip;
  String? title;
  String? mnemonicTitle;
}

/// 1:1: `export function isICommandActionToggleInfo(thing: ...): thing is ...`.
bool isICommandActionToggleInfo(Object? thing) {
  if (thing == null) return false;
  return _definedProperty(thing, 'condition') != null;
}

/// 1:1: `export interface ICommandActionSource`.
class ICommandActionSource {
  ICommandActionSource({required this.id, required this.title});

  final String id;
  final String title;
}

/// 1:1: `export interface ICommandAction`.
class ICommandAction {
  ICommandAction({
    required this.id,
    required this.title,
    this.shortTitle,
    this.metadata,
    this.category,
    this.tooltip,
    this.icon,
    this.source,
    this.precondition,
    this.toggled,
  });

  String id;
  Object title;
  Object? shortTitle;
  commands.ICommandMetadata? metadata;
  Object? category;
  Object? tooltip;
  Icon? icon;
  ICommandActionSource? source;
  contextkey.ContextKeyExpression? precondition;
  Object? toggled;
}

/// 1:1: `export type ISerializableCommandAction = UriDto<ICommandAction>`.
typedef ISerializableCommandAction = uri.UriDto<ICommandAction>;
