// 1:1 port of vscode/src/vs/platform/theme/common/colorUtils.ts

import '../../../base/common/assert.dart' show assertNever;
import '../../../base/common/async.dart' show RunOnceScheduler;
import '../../../base/common/color.dart' show Color, RGBA, ColorFormatCSS;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/jsonSchema.dart' show IJSONSchema, IJSONSchemaSnippet;
import '../../../base/common/lifecycle.dart' show Disposable;
import '../../jsonschemas/common/jsonContributionRegistry.dart'
    show IJSONContributionRegistry;
import '../../jsonschemas/common/jsonContributionRegistry.dart' as jsonReg;
import '../../registry/common/platform.dart' show Registry;
import '../../../nls.dart' show localize;
import './themeService.dart' show IColorTheme;

/// 1:1: `export type ColorIdentifier = string`
typedef ColorIdentifier = String;

/// 1:1: `export interface ColorContribution`
class ColorContribution {
  final ColorIdentifier id;
  final String description;
  final Object? defaults; // ColorDefaults | ColorValue | null
  final bool needsTransparency;
  final String? deprecationMessage;
  ColorContribution({
    required this.id,
    required this.description,
    required this.defaults,
    required this.needsTransparency,
    this.deprecationMessage,
  });
}

/// 1:1: `asCssVariableName(colorIdent)`
String asCssVariableName(ColorIdentifier colorIdent) =>
    '--vscode-${colorIdent.replaceAll('.', '-')}';

/// 1:1: `asCssVariable(color)`
String asCssVariable(ColorIdentifier color) => 'var(${asCssVariableName(color)})';

/// 1:1: `asCssVariableWithDefault(color, defaultCssValue)`
String asCssVariableWithDefault(ColorIdentifier color, String defaultCssValue) =>
    'var(${asCssVariableName(color)}, $defaultCssValue)';

/// 1:1: `export const enum ColorTransformType`
class ColorTransformType {
  static const int Darken = 0;
  static const int Lighten = 1;
  static const int Transparent = 2;
  static const int Opaque = 3;
  static const int OneOf = 4;
  static const int LessProminent = 5;
  static const int IfDefinedThenElse = 6;
  static const int Mix = 7;
  static const int Opacity = 8;
}

/// 1:1: `export type ColorTransform` — carrier with `op` discriminant.
class ColorTransform {
  final int op;
  final Object? value;
  final num? factor;
  final num? opacity;
  final Object? background;
  final List<Object?>? values;
  final ColorIdentifier? variableIf;
  final Object? thenValue;
  final Object? elseValue;
  final Object? color;
  final Object? withColor;
  final num? ratio;
  final num? transparency;
  ColorTransform({
    required this.op,
    this.value,
    this.factor,
    this.opacity,
    this.background,
    this.values,
    this.variableIf,
    this.thenValue,
    this.elseValue,
    this.color,
    this.withColor,
    this.ratio,
    this.transparency,
  });
}

/// 1:1: `export interface ColorDefaults`
class ColorDefaults {
  final Object? light;
  final Object? dark;
  final Object? hcDark;
  final Object? hcLight;
  ColorDefaults({
    required this.light,
    required this.dark,
    required this.hcDark,
    required this.hcLight,
  });
  Object? operator [](String themeType) {
    switch (themeType) {
      case 'dark':
        return dark;
      case 'light':
        return light;
      case 'hcDark':
        return hcDark;
      case 'hcLight':
        return hcLight;
      default:
        return null;
    }
  }
}

/// 1:1: `export function isColorDefaults(value)`
bool isColorDefaults(Object? value) =>
    value != null &&
    value is Map &&
    value.containsKey('light') &&
    value.containsKey('dark');

/// 1:1: `export const Extensions`
class Extensions {
  static const String ColorContribution = 'base.contributions.colors';
}

/// 1:1: `export const DEFAULT_COLOR_CONFIG_VALUE`
const String DEFAULT_COLOR_CONFIG_VALUE = 'default';

/// 1:1: `export interface IColorRegistry`
abstract class IColorRegistry {
  Event<void> get onDidChangeSchema;
  ColorIdentifier registerColor(String id, Object? defaults, String description,
      [bool? needsTransparency, String? deprecationMessage]);
  void deregisterColor(String id);
  List<ColorContribution> getColors();
  Color? resolveDefaultColor(ColorIdentifier id, IColorTheme theme);
  IJSONSchema getColorSchema();
  IJSONSchema getColorReferenceSchema();
  void updateDefaultColor(String id, Object? defaults);
  void notifyThemeUpdate(IColorTheme theme);
}

/// 1:1: `class ColorRegistry extends Disposable implements IColorRegistry`
class ColorRegistry extends Disposable implements IColorRegistry {
  final Emitter<void> _onDidChangeSchema = Emitter<void>();
  @override
  late final Event<void> onDidChangeSchema = _onDidChangeSchema.event;

  final Map<String, ColorContribution> _colorsById = <String, ColorContribution>{};
  late final IJSONSchema _defaultColorSchema;
  IJSONSchema _colorSchema = <String, Object?>{
    'type': 'object',
    'properties': <String, Object?>{},
  };
  IJSONSchema _colorReferenceSchema = <String, Object?>{
    'type': 'string',
    'enum': <String>[],
    'enumDescriptions': <String>[],
  };

  ColorRegistry() : super() {
    _defaultColorSchema = <String, Object?>{
      'type': 'string',
      'const': DEFAULT_COLOR_CONFIG_VALUE,
      'description': localize('useDefault', 'Use the default color.'),
    };
  }

  @override
  void notifyThemeUpdate(IColorTheme colorThemeData) {
    final Map<String, Object?> props =
        (_colorSchema['properties'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
    for (final String key in _colorsById.keys) {
      final Color? color = colorThemeData.getColor(key);
      if (color != null) {
        final Map<String, Object?> prop = props[key] as Map<String, Object?>;
        final List<Object?> oneOf = prop['oneOf'] as List<Object?>;
        final Map<String, Object?> schema = oneOf[0] as Map<String, Object?>;
        final List<Object?> snippets = schema['defaultSnippets'] as List<Object?>;
        (snippets[0] as Map<String, Object?>)['body'] =
            '\${1:${ColorFormatCSS.formatHexA(color, true)}}';
      }
    }
    _onDidChangeSchema.fire(null);
  }

  @override
  ColorIdentifier registerColor(String id, Object? defaults, String description,
      [bool? needsTransparency = false, String? deprecationMessage]) {
    final ColorContribution contribution = ColorContribution(
      id: id,
      description: description,
      defaults: defaults,
      needsTransparency: needsTransparency ?? false,
      deprecationMessage: deprecationMessage,
    );
    _colorsById[id] = contribution;
    final Map<String, Object?> propertySchema = <String, Object?>{
      'type': 'string',
      'format': 'color-hex',
      'defaultSnippets': <Object?>[<String, Object?>{'body': '\${1:#ff0000}'}],
    };
    if (deprecationMessage != null) {
      propertySchema['deprecationMessage'] = deprecationMessage;
    }
    if (needsTransparency == true) {
      propertySchema['pattern'] =
          '^#(?:(?<rgba>[0-9a-fA-f]{3}[0-9a-eA-E])|(?:[0-9a-fA-F]{6}(?:(?![fF]{2})(?:[0-9a-fA-F]{2}))))?\$';
      propertySchema['patternErrorMessage'] = localize('transparecyRequired',
          'This color must be transparent or it will obscure content');
    }
    (_colorSchema['properties'] as Map<String, Object?>)[id] = <String, Object?>{
      'description': description,
      'oneOf': <Object?>[propertySchema, _defaultColorSchema],
    };
    (_colorReferenceSchema['enum'] as List<String>).add(id);
    (_colorReferenceSchema['enumDescriptions'] as List<String>).add(description);

    _onDidChangeSchema.fire(null);
    return id;
  }

  @override
  void updateDefaultColor(String id, Object? defaults) {
    final ColorContribution? existing = _colorsById[id];
    if (existing != null) {
      _colorsById[id] = ColorContribution(
        id: existing.id,
        description: existing.description,
        defaults: defaults,
        needsTransparency: existing.needsTransparency,
        deprecationMessage: existing.deprecationMessage,
      );
    }
  }

  @override
  void deregisterColor(String id) {
    _colorsById.remove(id);
    (_colorSchema['properties'] as Map<String, Object?>).remove(id);
    final List<String> en = (_colorReferenceSchema['enum'] as List<String>);
    final int index = en.indexOf(id);
    if (index != -1) {
      en.removeAt(index);
      (_colorReferenceSchema['enumDescriptions'] as List<String>).removeAt(index);
    }
    _onDidChangeSchema.fire(null);
  }

  @override
  List<ColorContribution> getColors() =>
      _colorsById.keys.map((String id) => _colorsById[id]!).toList();

  @override
  Color? resolveDefaultColor(ColorIdentifier id, IColorTheme theme) {
    final ColorContribution? colorDesc = _colorsById[id];
    if (colorDesc != null && colorDesc.defaults != null) {
      final Object? defaults = colorDesc.defaults;
      Object? colorValue;
      if (defaults is ColorDefaults) {
        colorValue = defaults[theme.type.value];
      } else if (defaults is Map &&
          defaults.containsKey('light') &&
          defaults.containsKey('dark')) {
        // ColorDefaults provided via a map carrier (from color definition files).
        colorValue = defaults[theme.type.value];
      } else {
        colorValue = defaults;
      }
      return resolveColorValue(colorValue, theme);
    }
    return null;
  }

  @override
  IJSONSchema getColorSchema() => _colorSchema;

  @override
  IJSONSchema getColorReferenceSchema() => _colorReferenceSchema;

  @override
  String toString() {
    int sorter(String a, String b) {
      final int cat1 = a.indexOf('.') == -1 ? 0 : 1;
      final int cat2 = b.indexOf('.') == -1 ? 0 : 1;
      if (cat1 != cat2) return cat1 - cat2;
      return a.compareTo(b);
    }
    final List<String> keys = _colorsById.keys.toList()..sort(sorter);
    return keys
        .map((String k) => '- `$k`: ${_colorsById[k]!.description}')
        .join('\n');
  }
}

final ColorRegistry _colorRegistry = ColorRegistry();

void _ensureRegistered() {
  if (!Registry.knows(Extensions.ColorContribution)) {
    Registry.add(Extensions.ColorContribution, _colorRegistry);
  }
}

/// 1:1: `export function registerColor(...)`
ColorIdentifier registerColor(String id, Object? defaults, String description,
        [bool? needsTransparency, String? deprecationMessage]) =>
    _colorRegistry.registerColor(
        id, defaults, description, needsTransparency ?? false, deprecationMessage);

/// 1:1: `export function getColorRegistry()`
IColorRegistry getColorRegistry() => _colorRegistry;

// ----- color functions

/// 1:1: `export function executeTransform(transform, theme)`
Color? executeTransform(ColorTransform transform, IColorTheme theme) {
  switch (transform.op) {
    case ColorTransformType.Darken:
      return resolveColorValue(transform.value, theme)?.darken(transform.factor ?? 0);
    case ColorTransformType.Lighten:
      return resolveColorValue(transform.value, theme)?.lighten(transform.factor ?? 0);
    case ColorTransformType.Transparent:
      return resolveColorValue(transform.value, theme)?.transparent(transform.factor ?? 0);
    case ColorTransformType.Opacity:
      final RGBA? rgba = resolveColorValue(transform.value, theme)?.rgba;
      return rgba != null
          ? Color(RGBA(rgba.r, rgba.g, rgba.b, transform.opacity ?? 1))
          : null;
    case ColorTransformType.Mix:
      final Color primary = resolveColorValue(transform.color, theme) ?? Color.transparentColor;
      final Color other = resolveColorValue(transform.withColor, theme) ?? Color.transparentColor;
      return primary.mix(other, transform.ratio ?? 0.5);
    case ColorTransformType.Opaque:
      final Color? backgroundColor = resolveColorValue(transform.background, theme);
      if (backgroundColor == null) {
        return resolveColorValue(transform.value, theme);
      }
      return resolveColorValue(transform.value, theme)?.makeOpaque(backgroundColor);
    case ColorTransformType.OneOf:
      for (final Object? candidate in transform.values ?? const <Object?>[]) {
        final Color? color = resolveColorValue(candidate, theme);
        if (color != null) return color;
      }
      return null;
    case ColorTransformType.IfDefinedThenElse:
      return resolveColorValue(
          theme.defines(transform.variableIf!) ? transform.thenValue : transform.elseValue,
          theme);
    case ColorTransformType.LessProminent:
      final Color? from = resolveColorValue(transform.value, theme);
      if (from == null) return null;
      final Color? backgroundColor = resolveColorValue(transform.background, theme);
      if (backgroundColor == null) {
        return from.transparent((transform.factor ?? 0) * (transform.transparency ?? 0));
      }
      return from.isDarkerThan(backgroundColor)
          ? Color.getLighterColor(from, backgroundColor, transform.factor)
              .transparent(transform.transparency ?? 0)
          : Color.getDarkerColor(from, backgroundColor, transform.factor)
              .transparent(transform.transparency ?? 0);
    default:
      return assertNever(transform);
  }
}

ColorTransform darken(Object? colorValue, num factor) =>
    ColorTransform(op: ColorTransformType.Darken, value: colorValue, factor: factor);
ColorTransform lighten(Object? colorValue, num factor) =>
    ColorTransform(op: ColorTransformType.Lighten, value: colorValue, factor: factor);
ColorTransform transparent(Object? colorValue, num factor) =>
    ColorTransform(op: ColorTransformType.Transparent, value: colorValue, factor: factor);
ColorTransform withOpacity(Object? colorValue, num opacity) =>
    ColorTransform(op: ColorTransformType.Opacity, value: colorValue, opacity: opacity);
ColorTransform opaque(Object? colorValue, Object? background) =>
    ColorTransform(op: ColorTransformType.Opaque, value: colorValue, background: background);
ColorTransform oneOf(List<Object?> colorValues) =>
    ColorTransform(op: ColorTransformType.OneOf, values: colorValues);
ColorTransform ifDefinedThenElse(
        ColorIdentifier ifArg, Object? thenArg, Object? elseArg) =>
    ColorTransform(
        op: ColorTransformType.IfDefinedThenElse,
        variableIf: ifArg,
        thenValue: thenArg,
        elseValue: elseArg);
ColorTransform lessProminent(Object? colorValue, Object? backgroundColorValue,
        num factor, num transparency) =>
    ColorTransform(
        op: ColorTransformType.LessProminent,
        value: colorValue,
        background: backgroundColorValue,
        factor: factor,
        transparency: transparency);

/// 1:1: `export function resolveColorValue(colorValue, theme)`
Color? resolveColorValue(Object? colorValue, IColorTheme theme) {
  if (colorValue == null) return null;
  if (colorValue is String) {
    if (colorValue.startsWith('#')) return Color.fromHex(colorValue);
    return theme.getColor(colorValue);
  } else if (colorValue is Color) {
    return colorValue;
  } else if (colorValue is ColorTransform) {
    return executeTransform(colorValue, theme);
  }
  return null;
}

/// 1:1: `export const workbenchColorsSchemaId`
const String workbenchColorsSchemaId = 'vscode://schemas/workbench-colors';

// Module-load side effects: register schema + delayer subscription.
// In Dart these are triggered on first library access via [ensureColorUtilsInitialized].
bool _initialized = false;
void ensureColorUtilsInitialized() {
  if (_initialized) return;
  _initialized = true;
  _ensureRegistered();
  final IJSONContributionRegistry schemaRegistry =
      Registry.as(jsonReg.Extensions.JSONContribution) as IJSONContributionRegistry;
  schemaRegistry.registerSchema(workbenchColorsSchemaId, _colorRegistry.getColorSchema());
  final RunOnceScheduler delayer = RunOnceScheduler(
      () => schemaRegistry.notifySchemaChanged(workbenchColorsSchemaId), 200);
  _colorRegistry.onDidChangeSchema((dynamic _) {
    if (!delayer.isScheduled()) delayer.schedule();
  });
}
