// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/telemetry/common/gdprTypings.ts
// This is a type-only file: no runtime logic exists in the source, so none is
// added here. TS interfaces -> Dart classes mirroring every field; string
// literal unions -> class static consts; TS compile-time type-level operators
// (`Omit`, `keyof`, mapped/conditional types, `extends` constraints) have no
// Dart equivalent and are carried as typedefs documenting the source shape.
// ---------------------------------------------------------------------------

/// 1:1: `classification` union members of `IPropertyData`.
class PropertyClassification {
  static const String systemMetaData = 'SystemMetaData';
  static const String callstackOrException = 'CallstackOrException';
  static const String customerContent = 'CustomerContent';
  static const String publicNonPersonalData = 'PublicNonPersonalData';
  static const String endUserPseudonymizedInformation =
      'EndUserPseudonymizedInformation';
}

/// 1:1: `purpose` union members of `IPropertyData`.
class PropertyPurpose {
  static const String performanceAndHealth = 'PerformanceAndHealth';
  static const String featureInsight = 'FeatureInsight';
  static const String businessInsight = 'BusinessInsight';
}

/// 1:1: `export interface IPropertyData`
class IPropertyData {
  final String classification;
  final String purpose;
  final String comment;
  final String? expiration;
  final String? endpoint;

  IPropertyData({
    required this.classification,
    required this.purpose,
    required this.comment,
    this.expiration,
    this.endpoint,
  });
}

/// 1:1: `export interface IGDPRProperty`
/// `readonly [name: string]: IPropertyData | undefined | IGDPRProperty | string`
/// -> an open string-keyed map of the union (Dart has no index-signature
/// interface; a `Map<String, Object?>` carries it, with `owner`/`comment`/
/// `expiration` surfaced as named fields).
class IGDPRProperty {
  final String owner;
  final String comment;
  final String? expiration;
  final Map<String, Object?> extra;

  IGDPRProperty({
    required this.owner,
    required this.comment,
    this.expiration,
    Map<String, Object?>? extra,
  }) : extra = extra ?? <String, Object?>{};
}

/// 1:1: `type IGDPRPropertyWithoutMetadata = Omit<IGDPRProperty, 'owner' | 'comment' | 'expiration'>`
/// Compile-time Omit: carried as the metadata-free part of [IGDPRProperty].
typedef IGDPRPropertyWithoutMetadata = Map<String, Object?>;

/// 1:1: `export type OmitMetadata<T> = Omit<T, 'owner' | 'comment' | 'expiration'>`
/// Dart cannot apply `Omit` at the type level; the carrier documents it.
typedef OmitMetadata = Map<String, Object?>;

/// 1:1: `export type ClassifiedEvent<T extends IGDPRPropertyWithoutMetadata> = { [k in keyof T]: unknown }`
/// A mapped type whose every property is `unknown` -> an open string-keyed map.
typedef ClassifiedEvent = Map<String, Object?>;

/// 1:1: `export type StrictPropertyCheckError = { error: 'Type of classified event does not match event properties' }`
class StrictPropertyCheckError {
  static const String error =
      'Type of classified event does not match event properties';
  final String value;
  const StrictPropertyCheckError([this.value = error]);
}

/// 1:1: `export type StrictPropertyChecker<TEvent, TClassification, TError> = ...`
/// A compile-time conditional type selecting either `TEvent` or `TError`.
/// Carried as a typedef over `Object?`; the selection itself is enforced by
/// the TS compiler and has no Dart runtime representation.
typedef StrictPropertyChecker<TEvent, TClassification, TError> = Object?;

/// 1:1: `export type StrictPropertyCheck<T extends IGDPRProperty, E> = StrictPropertyChecker<E, ClassifiedEvent<OmitMetadata<T>>, StrictPropertyCheckError>`
typedef StrictPropertyCheck<T extends IGDPRProperty, E> = Object?;
