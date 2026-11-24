// 1:1 port of vscode/src/vs/platform/theme/common/iconRegistry.ts

import '../../../base/common/async.dart' show RunOnceScheduler;
import '../../../base/common/codicons.dart' show Codicon;
import '../../../base/common/codiconsUtil.dart' show getCodiconFontCharacters;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/jsonSchema.dart' show IJSONSchema;
import '../../../base/common/lifecycle.dart' show Disposable;
import '../../../base/common/themables.dart' show IconIdentifier, ThemeIcon;
import '../../../base/common/types.dart' as types;
import '../../../base/common/uri.dart' show URI;
import '../../../nls.dart' show localize;
import '../../jsonschemas/common/jsonContributionRegistry.dart'
    show IJSONContributionRegistry, jsonContributionRegistry;
import '../../jsonschemas/common/jsonContributionRegistry.dart'
    as JSONContributionRegistry show Extensions;
import '../../registry/common/platform.dart' show Registry;

//  ------ API types

/// 1:1: `export const Extensions = { IconContribution: 'base.contributions.icons' }`
class Extensions {
  static const String IconContribution = 'base.contributions.icons';
}

/// 1:1: `export type IconDefaults = ThemeIcon | IconDefinition` (Object carrier).
typedef IconDefaults = Object;

/// 1:1: `export interface IconDefinition`
abstract class IconDefinition {
  Object? get font; // IconFontContribution?
  String get fontCharacter;
}

/// A structural carrier for [IconDefinition] (plain-object semantics).
class IconDefinitionCarrier implements IconDefinition {
  IconDefinitionCarrier({this.font, required this.fontCharacter});
  @override
  final Object? font;
  @override
  final String fontCharacter;
}

/// 1:1: `export interface IconContribution`
abstract class IconContribution {
  String get id;
  String? description;
  String? get deprecationMessage;
  Object get defaults; // IconDefaults
}

/// Structural carrier for [IconContribution].
class IconContributionCarrier implements IconContribution {
  IconContributionCarrier({
    required this.id,
    this.description,
    this.deprecationMessage,
    required this.defaults,
  });
  @override
  String id;
  @override
  String? description;
  @override
  final String? deprecationMessage;
  @override
  final Object defaults;
}

/// 1:1: `IconContribution.getDefinition(contribution, registry)`
IconDefinition? iconContributionGetDefinition(
    IconContribution contribution, IIconRegistry registry) {
  Object definition = contribution.defaults;
  while (ThemeIcon.isThemeIcon(definition)) {
    final IconContribution? c = registry.getIcon((definition as ThemeIcon).id);
    if (c == null) {
      return null;
    }
    definition = c.defaults;
  }
  return definition as IconDefinition;
}

/// 1:1: `export interface IconFontContribution`
abstract class IconFontContribution {
  String get id;
  IconFontDefinition get definition;
}

/// 1:1: `export interface IconFontDefinition`
abstract class IconFontDefinition {
  String? get weight;
  String? get style;
  List<IconFontSource> get src;
}

/// 1:1: `IconFontDefinition.toJSONObject(iconFont)`
Map<String, Object?> iconFontDefinitionToJSONObject(IconFontDefinition iconFont) =>
    <String, Object?>{
      'weight': iconFont.weight,
      'style': iconFont.style,
      'src': iconFont.src
          .map((s) => <String, Object?>{
                'format': s.format,
                'location': s.location.toString(),
              })
          .toList(),
    };

/// 1:1: `IconFontDefinition.fromJSONObject(json)`
IconFontDefinition? iconFontDefinitionFromJSONObject(Object? json) {
  String? stringOrUndef(Object? s) => types.isString(s) ? s as String : null;
  if (json is Map &&
      json['src'] is List &&
      (json['src'] as List).every((dynamic s) =>
          types.isString(s['format']) && types.isString(s['location']))) {
    return IconFontDefinitionCarrier(
      weight: stringOrUndef(json['weight']),
      style: stringOrUndef(json['style']),
      src: (json['src'] as List)
          .map((dynamic s) => IconFontSource(
                format: s['format'] as String,
                location: URI.parse(s['location'] as String),
              ))
          .toList(),
    );
  }
  return null;
}

class IconFontDefinitionCarrier implements IconFontDefinition {
  IconFontDefinitionCarrier({this.weight, this.style, required this.src});
  @override
  final String? weight;
  @override
  final String? style;
  @override
  final List<IconFontSource> src;
}

/// 1:1: `export interface IconFontSource`
class IconFontSource {
  IconFontSource({required this.location, required this.format});
  final URI location;
  final String format;
}

/// 1:1: `export interface IIconRegistry`
abstract class IIconRegistry {
  Event<void> get onDidChange;
  ThemeIcon registerIcon(IconIdentifier id, IconDefaults defaults,
      [String? description, String? deprecationMessage]);
  void deregisterIcon(IconIdentifier id);
  List<IconContribution> getIcons();
  IconContribution? getIcon(IconIdentifier id);
  IJSONSchema getIconSchema();
  IJSONSchema getIconReferenceSchema();
  IconFontDefinition registerIconFont(String id, IconFontDefinition definition);
  void deregisterIconFont(String id);
  IconFontDefinition? getIconFont(String id);
}

// regexes for validation of font properties
// 1:1: source strings preserved; Dart has no `RegExp.source`, so keep consts.
const String fontIdRegexSource = r'^([\w_-]+)$';
const String fontStyleRegexSource = r'^(normal|italic|(oblique[ \w\s-]+))$';
const String fontWeightRegexSource = r'^(normal|bold|lighter|bolder|(\d{0-1000}))$';
const String fontSizeRegexSource = r'^([\w_.%+-]+)$';
const String fontFormatRegexSource = r'^woff|woff2|truetype|opentype|embedded-opentype|svg$';
const String fontColorRegexSource = r'^#[0-9a-fA-F]{0,6}$';

final RegExp fontIdRegex = RegExp(fontIdRegexSource);
final RegExp fontStyleRegex = RegExp(fontStyleRegexSource);
final RegExp fontWeightRegex = RegExp(fontWeightRegexSource);
final RegExp fontSizeRegex = RegExp(fontSizeRegexSource);
final RegExp fontFormatRegex = RegExp(fontFormatRegexSource);
final RegExp fontColorRegex = RegExp(fontColorRegexSource);

final String fontIdErrorMessage = localize('schema.fontId.formatError',
    'The font ID must only contain letters, numbers, underscores and dashes.');

/// 1:1: `class IconRegistry extends Disposable implements IIconRegistry`
class IconRegistry extends Disposable implements IIconRegistry {
  final Emitter<void> _onDidChange = Emitter<void>();
  @override
  late final Event<void> onDidChange = _onDidChange.event;

  late final Map<String, IconContribution> _iconsById;
  late final Map<String, Object?> _iconSchema;
  late final Map<String, IJSONSchema> _iconSchemaProperties;
  late final List<String> _refEnum;
  late final List<String> _refEnumDescriptions;
  late final Map<String, Object?> _refSchema;
  late final Map<String, IconFontDefinition> _iconFontsById;

  IconRegistry() : super() {
    register(_onDidChange);
    _iconsById = <String, IconContribution>{};
    _iconFontsById = <String, IconFontDefinition>{};
    _iconSchemaProperties = <String, IJSONSchema>{};
    _refEnum = <String>[];
    _refEnumDescriptions = <String>[];

    // 1:1: iconSchema initializer
    _iconSchema = <String, Object?>{
      'definitions': <String, Object?>{
        'icons': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'fontId': <String, Object?>{
              'type': 'string',
              'description': localize(
                  'iconDefinition.fontId',
                  'The id of the font to use. If not set, the font that is defined first is used.'),
              'pattern': fontIdRegexSource,
              'patternErrorMessage': fontIdErrorMessage,
            },
            'fontCharacter': <String, Object?>{
              'type': 'string',
              'description': localize('iconDefinition.fontCharacter',
                  'The font character associated with the icon definition.'),
            },
          },
          'additionalProperties': false,
          'defaultSnippets': <Object?>[
            <String, Object?>{
              'body': <String, Object?>{'fontCharacter': r'\\e030'},
            },
          ],
        },
      },
      'type': 'object',
      'properties': _iconSchemaProperties,
    };
    // 1:1: iconReferenceSchema initializer
    _refSchema = <String, Object?>{
      'type': 'string',
      'pattern': '^${ThemeIcon.iconNameExpression}\$',
      'enum': _refEnum,
      'enumDescriptions': _refEnumDescriptions,
    };
  }

  @override
  ThemeIcon registerIcon(
    IconIdentifier id,
    IconDefaults defaults, [
    String? description,
    String? deprecationMessage,
  ]) {
    final IconContribution? existing = _iconsById[id];
    if (existing != null) {
      if (description != null && existing.description == null) {
        existing.description = description;
        final IJSONSchema props = _iconSchemaProperties[id]!;
        props['markdownDescription'] = '${description} \$($id)';
        final int enumIndex = _refEnum.indexOf(id);
        if (enumIndex != -1) {
          _refEnumDescriptions[enumIndex] = description;
        }
        _onDidChange.fire(null);
      }
      return ThemeIcon(existing.id);
    }
    final IconContribution iconContribution = IconContributionCarrier(
      id: id,
      description: description,
      defaults: defaults,
      deprecationMessage: deprecationMessage,
    );
    _iconsById[id] = iconContribution;
    final IJSONSchema propertySchema = <String, Object?>{
      r'$ref': '#/definitions/icons',
    };
    if (deprecationMessage != null) {
      propertySchema['deprecationMessage'] = deprecationMessage;
    }
    if (description != null) {
      propertySchema['markdownDescription'] = '${description}: \$($id)';
    }
    _iconSchemaProperties[id] = propertySchema;
    _refEnum.add(id);
    _refEnumDescriptions.add(description ?? '');
    _onDidChange.fire(null);
    return ThemeIcon(id);
  }

  @override
  void deregisterIcon(IconIdentifier id) {
    _iconsById.remove(id);
    _iconSchemaProperties.remove(id);
    final int index = _refEnum.indexOf(id);
    if (index != -1) {
      _refEnum.removeAt(index);
      _refEnumDescriptions.removeAt(index);
    }
    _onDidChange.fire(null);
  }

  @override
  List<IconContribution> getIcons() => _iconsById.values.toList();

  @override
  IconContribution? getIcon(IconIdentifier id) => _iconsById[id];

  @override
  IJSONSchema getIconSchema() => _iconSchema;

  @override
  IJSONSchema getIconReferenceSchema() => _refSchema;

  @override
  IconFontDefinition registerIconFont(
      String id, IconFontDefinition definition) {
    final IconFontDefinition? existing = _iconFontsById[id];
    if (existing != null) {
      return existing;
    }
    _iconFontsById[id] = definition;
    _onDidChange.fire(null);
    return definition;
  }

  @override
  void deregisterIconFont(String id) {
    _iconFontsById.remove(id);
  }

  @override
  IconFontDefinition? getIconFont(String id) => _iconFontsById[id];

  @override
  String toString() {
    int sorter(IconContribution i1, IconContribution i2) =>
        i1.id.compareTo(i2.id);
    String classNames(IconContribution i) {
      IconContribution cur = i;
      while (ThemeIcon.isThemeIcon(cur.defaults)) {
        final IconContribution? next = _iconsById[(cur.defaults as ThemeIcon).id];
        if (next == null) break;
        cur = next;
      }
      return 'codicon codicon-${cur.id}';
    }

    final List<String> reference = <String>[];
    reference.add('| preview     | identifier                        | default codicon ID                | description');
    reference.add('| ----------- | --------------------------------- | --------------------------------- | --------------------------------- |');
    final List<IconContribution> contributions = _iconsById.values.toList();
    final List<IconContribution> withDesc = contributions
        .where((i) => i.description != null && i.description!.isNotEmpty)
        .toList()
      ..sort((a, b) => sorter(a, b));
    for (final IconContribution i in withDesc) {
      final String defId = ThemeIcon.isThemeIcon(i.defaults)
          ? (i.defaults as ThemeIcon).id
          : i.id;
      reference.add('|<i class="${classNames(i)}"></i>|${i.id}|$defId|${i.description ?? ''}|');
    }
    reference.add('| preview     | identifier                        ');
    reference.add('| ----------- | --------------------------------- |');
    final List<IconContribution> nonTheme = contributions
        .where((i) => !ThemeIcon.isThemeIcon(i.defaults))
        .toList()
      ..sort((a, b) => sorter(a, b));
    for (final IconContribution i in nonTheme) {
      reference.add('|<i class="${classNames(i)}"></i>|${i.id}|');
    }
    return reference.join('\n');
  }
}

/// 1:1: `const iconRegistry = new IconRegistry();`
final IconRegistry iconRegistry = IconRegistry();

/// 1:1: module-level `platform.Registry.add(Extensions.IconContribution, iconRegistry);`
// ignore: unused_element
final Object? _iconRegistryRegistration = () {
  Registry.add(Extensions.IconContribution, iconRegistry);
  return null;
}();

/// Ensures module-level side effects run in TS source order:
/// `initialize()` -> schema registration -> common icons. Dart top-level
/// initializers are lazy, so this explicit gate replaces module evaluation.
bool _initialized = false;
void _ensureInitialized() {
  if (_initialized) return;
  _initialized = true;
  _initialize();
  _schemaRegistrationGate();
  // Force common-icon top-level initializers (they call registerIcon, which
  // re-enters _ensureInitialized but is short-circuited by the guard above).
  if (widgetClose.id.isEmpty ||
      gotoPreviousLocation.id.isEmpty ||
      gotoNextLocation.id.isEmpty) {
    throw StateError('common icons failed to initialize');
  }
}

/// 1:1: `export function registerIcon(...)`
ThemeIcon registerIcon(
  String id,
  IconDefaults defaults,
  String description, [
  String? deprecationMessage,
]) {
  _ensureInitialized();
  return iconRegistry.registerIcon(id, defaults, description, deprecationMessage);
}

/// 1:1: `export function getIconRegistry(): IIconRegistry`
IIconRegistry getIconRegistry() {
  _ensureInitialized();
  return iconRegistry;
}

/// 1:1: `function initialize()` — must run after codicon font map is filled.
void _initialize() {
  // Dart is lazy: force codiconsLibrary registration before reading the map.
  if (Codicon.isEmpty) throw StateError('codiconsLibrary failed to initialize');
  final Map<String, int> codiconFontCharacters = getCodiconFontCharacters();
  for (final String icon in codiconFontCharacters.keys) {
    final String fontCharacter = '\\' + codiconFontCharacters[icon]!.toRadixString(16);
    iconRegistry.registerIcon(icon, IconDefinitionCarrier(fontCharacter: fontCharacter));
  }
}

/// 1:1: `export const iconsSchemaId = 'vscode://schemas/icons';`
const String iconsSchemaId = 'vscode://schemas/icons';

/// 1:1: module-level schema registration + delayer wiring (called via gate).
bool _schemaRegistered = false;
void _schemaRegistrationGate() {
  if (_schemaRegistered) return;
  _schemaRegistered = true;
  // Dart lazy init: Registry.add may not have run; fall back to the singleton.
  final IJSONContributionRegistry schemaRegistry =
      (Registry.as(JSONContributionRegistry.Extensions.JSONContribution)
          as IJSONContributionRegistry?) ?? jsonContributionRegistry;
  schemaRegistry.registerSchema(iconsSchemaId, iconRegistry.getIconSchema());
  final RunOnceScheduler delayer = RunOnceScheduler(
      () => schemaRegistry.notifySchemaChanged(iconsSchemaId), 200);
  iconRegistry.onDidChange((_) {
    if (!delayer.isScheduled()) {
      delayer.schedule();
    }
  });
}

// common icons
final ThemeIcon widgetClose = registerIcon(
    'widget-close', Codicon['close']!,
    localize('widgetClose', 'Icon for the close action in widgets.'));
final ThemeIcon gotoPreviousLocation = registerIcon(
    'goto-previous-location', Codicon['arrowUp']!,
    localize('previousChangeIcon', 'Icon for goto previous editor location.'));
final ThemeIcon gotoNextLocation = registerIcon(
    'goto-next-location', Codicon['arrowDown']!,
    localize('nextChangeIcon', 'Icon for goto next editor location.'));

final ThemeIcon syncing = ThemeIcon.modify(Codicon['sync']!, 'spin');
final ThemeIcon spinningLoading = ThemeIcon.modify(Codicon['loading']!, 'spin');
