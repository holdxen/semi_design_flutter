// 1:1 port of vs/editor/common/services/textResourceConfiguration.ts
// Declaration-only module: 2 decorators, 3 interfaces.
// Adaptations (consistent with earlier batches):
//   TS overloads -> $n suffix; `ReadonlySet<string>` -> Set<String>;
//   `IConfigurationValue<Readonly<T>>` -> IConfigurationValue<Object?> carrier;
//   `unknown` value -> Object?; const enum ConfigurationTarget in type
//   position -> int.
import '../../../base/common/event.dart' show Event;
import '../../../base/common/uri.dart' show URI;
import '../../../platform/configuration/common/configuration.dart'
    show IConfigurationValue;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../core/position.dart' show IPosition;

/// 1:1: `export const ITextResourceConfigurationService = createDecorator(...)`
final ServiceIdentifier<ITextResourceConfigurationServiceType>
    ITextResourceConfigurationService =
    createDecorator<ITextResourceConfigurationServiceType>(
        'textResourceConfigurationService');

/// 1:1: `export interface ITextResourceConfigurationChangeEvent`
abstract class ITextResourceConfigurationChangeEvent {
  /// 1:1: `readonly affectedKeys: ReadonlySet<string>`
  Set<String> get affectedKeys;

  /// 1:1: `affectsConfiguration(resource: URI | undefined, section: string): boolean`
  bool affectsConfiguration(URI? resource, String section);
}

/// 1:1: `export interface ITextResourceConfigurationService` (const keeps bare name).
abstract class ITextResourceConfigurationServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `readonly onDidChangeConfiguration: Event<ITextResourceConfigurationChangeEvent>`
  Event<ITextResourceConfigurationChangeEvent> get onDidChangeConfiguration;

  /// 1:1 overloads:
  ///   `getValue<T>(resource, section?): T`
  ///   `getValue<T>(resource, position?, section?): T`
  /// Return type `T` is a type-level generic -> Object? carrier.
  Object? getValue$1(URI? resource, [String? section]);
  Object? getValue$2(URI? resource, [IPosition? position, String? section]);

  /// 1:1: `inspect<T>(resource, position: IPosition | null, section): IConfigurationValue<Readonly<T>>`
  IConfigurationValue<Object?> inspect(
      URI? resource, IPosition? position, String section);

  /// 1:1: `updateValue(resource, key, value: unknown, configurationTarget?): Promise<void>`
  Future<void> updateValue(URI? resource, String key, Object value,
      [int? configurationTarget]);
}

/// 1:1: `export const ITextResourcePropertiesService = createDecorator(...)`
final ServiceIdentifier<ITextResourcePropertiesServiceType>
    ITextResourcePropertiesService =
    createDecorator<ITextResourcePropertiesServiceType>(
        'textResourcePropertiesService');

/// 1:1: `export interface ITextResourcePropertiesService` (const keeps bare name).
abstract class ITextResourcePropertiesServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `getEOL(resource: URI, language?: string): string`
  String getEOL(URI resource, [String? language]);
}
