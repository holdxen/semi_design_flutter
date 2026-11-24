// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/extensionManagement/common/extensionManagement.ts
// Translated 1:1. `const enum` -> class of static const values; string enums ->
// class of static const String. `enum` -> Dart enum. Interfaces -> abstract
// classes (a `Type` suffix disambiguates const/interface name collisions).
// Runtime truth: tool/ts2dart/_batch150_truth.cjs (real transpiled source with
// stubbed deps). Errors extend `Error` with a mutable `name` carrier, matching
// the files.dart convention (`Dart Error.name` is get-only in the base class).
// ---------------------------------------------------------------------------

import 'dart:async' show Future;

import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/event.dart' show Event;
import '../../../base/common/paging.dart' show IPager;
import '../../../base/common/platform.dart' show Platform_;
import '../../../base/common/policy.dart' show PolicyCategory;
import '../../../base/common/uri.dart' show URI;
import '../../../nls.dart' show ILocalizedString, localize, localize2;
import '../../configuration/common/configurationRegistry.dart'
    show
        ConfigurationScope,
        Extensions,
        IConfigurationNode,
        IConfigurationPropertySchema,
        IConfigurationRegistryType,
        IStringDictionary,
        configurationRegistry;
import '../../extensions/common/extensions.dart'
    show IExtensionManifest, TargetPlatform;
import '../../files/common/files.dart' show FileOperationError, FileOperationResult, IFileServiceType;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../registry/common/platform.dart' show Registry;
import 'extensionGalleryManifest.dart' show IExtensionGalleryManifest;

/// 1:1: `export const EXTENSION_IDENTIFIER_PATTERN`.
const String EXTENSION_IDENTIFIER_PATTERN = r'^([a-z0-9A-Z][a-z0-9-A-Z]*)\.([a-z0-9A-Z][a-z0-9-A-Z]*)$';

/// 1:1: `export const EXTENSION_IDENTIFIER_REGEX`.
final RegExp EXTENSION_IDENTIFIER_REGEX = RegExp(EXTENSION_IDENTIFIER_PATTERN);

/// 1:1: `export const EXTENSION_PUBLISHER_IDENTIFIER_PATTERN`.
const String EXTENSION_PUBLISHER_IDENTIFIER_PATTERN = r'^([a-z0-9A-Z][a-z0-9-A-Z]*)$';

/// 1:1: `export const WEB_EXTENSION_TAG`.
const String WEB_EXTENSION_TAG = '__web_extension';

/// 1:1: `export const LANGUAGE_MODEL_CHAT_PROVIDER_EXTENSION_TAG`.
const String LANGUAGE_MODEL_CHAT_PROVIDER_EXTENSION_TAG = 'language-models';

/// 1:1: `export const EXTENSION_INSTALL_SKIP_WALKTHROUGH_CONTEXT`.
const String EXTENSION_INSTALL_SKIP_WALKTHROUGH_CONTEXT = 'skipWalkthrough';

/// 1:1: `export const EXTENSION_INSTALL_SKIP_PUBLISHER_TRUST_CONTEXT`.
const String EXTENSION_INSTALL_SKIP_PUBLISHER_TRUST_CONTEXT = 'skipPublisherTrust';

/// 1:1: `export const EXTENSION_INSTALL_SOURCE_CONTEXT`.
const String EXTENSION_INSTALL_SOURCE_CONTEXT = 'extensionInstallSource';

/// 1:1: `export const EXTENSION_INSTALL_DEP_PACK_CONTEXT`.
const String EXTENSION_INSTALL_DEP_PACK_CONTEXT = 'dependecyOrPackExtensionInstall';

/// 1:1: `export const EXTENSION_INSTALL_CLIENT_TARGET_PLATFORM_CONTEXT`.
const String EXTENSION_INSTALL_CLIENT_TARGET_PLATFORM_CONTEXT = 'clientTargetPlatform';

/// 1:1: `export const enum ExtensionInstallSource`.
class ExtensionInstallSource {
  static const String COMMAND = 'command';
  static const String SETTINGS_SYNC = 'settingsSync';
}

/// 1:1: `export interface IProductVersion`.
class IProductVersion {
  IProductVersion({required this.version, this.date});
  final String version;
  final String? date;
}

/// 1:1: `export function TargetPlatformToString`.
String? TargetPlatformToString(String targetPlatform) {
  switch (targetPlatform) {
    case TargetPlatform.WIN32_X64:
      return 'Windows 64 bit';
    case TargetPlatform.WIN32_ARM64:
      return 'Windows ARM';
    case TargetPlatform.LINUX_X64:
      return 'Linux 64 bit';
    case TargetPlatform.LINUX_ARM64:
      return 'Linux ARM 64';
    case TargetPlatform.LINUX_ARMHF:
      return 'Linux ARM';
    case TargetPlatform.ALPINE_X64:
      return 'Alpine Linux 64 bit';
    case TargetPlatform.ALPINE_ARM64:
      return 'Alpine ARM 64';
    case TargetPlatform.DARWIN_X64:
      return 'Mac';
    case TargetPlatform.DARWIN_ARM64:
      return 'Mac Silicon';
    case TargetPlatform.WEB:
      return 'Web';
    case TargetPlatform.UNIVERSAL:
      return TargetPlatform.UNIVERSAL;
    case TargetPlatform.UNKNOWN:
      return TargetPlatform.UNKNOWN;
    case TargetPlatform.UNDEFINED:
      return TargetPlatform.UNDEFINED;
  }
  return null;
}

/// 1:1: `export function toTargetPlatform`.
String toTargetPlatform(String targetPlatform) {
  switch (targetPlatform) {
    case TargetPlatform.WIN32_X64:
      return TargetPlatform.WIN32_X64;
    case TargetPlatform.WIN32_ARM64:
      return TargetPlatform.WIN32_ARM64;
    case TargetPlatform.LINUX_X64:
      return TargetPlatform.LINUX_X64;
    case TargetPlatform.LINUX_ARM64:
      return TargetPlatform.LINUX_ARM64;
    case TargetPlatform.LINUX_ARMHF:
      return TargetPlatform.LINUX_ARMHF;
    case TargetPlatform.ALPINE_X64:
      return TargetPlatform.ALPINE_X64;
    case TargetPlatform.ALPINE_ARM64:
      return TargetPlatform.ALPINE_ARM64;
    case TargetPlatform.DARWIN_X64:
      return TargetPlatform.DARWIN_X64;
    case TargetPlatform.DARWIN_ARM64:
      return TargetPlatform.DARWIN_ARM64;
    case TargetPlatform.WEB:
      return TargetPlatform.WEB;
    case TargetPlatform.UNIVERSAL:
      return TargetPlatform.UNIVERSAL;
    default:
      return TargetPlatform.UNKNOWN;
  }
}

/// 1:1: `export function getTargetPlatform(platform: Platform | 'alpine', arch)`.
/// `Platform` is [Platform_] in Dart; 'alpine' is passed as the string 'alpine'.
String getTargetPlatform(Object platform, String? arch) {
  // TS switch on Platform (numeric const enum) or the literal 'alpine'.
  final Object p = platform;
  if (p == 'alpine') {
    if (arch == 'x64') return TargetPlatform.ALPINE_X64;
    if (arch == 'arm64') return TargetPlatform.ALPINE_ARM64;
    return TargetPlatform.UNKNOWN;
  }
  final int pv = p is int ? p : -1;
  switch (pv) {
    case 0: // Platform.Web
      return TargetPlatform.WEB;
    case 1: // Platform.Mac
      if (arch == 'x64') return TargetPlatform.DARWIN_X64;
      if (arch == 'arm64') return TargetPlatform.DARWIN_ARM64;
      return TargetPlatform.UNKNOWN;
    case 2: // Platform.Linux
      if (arch == 'x64') return TargetPlatform.LINUX_X64;
      if (arch == 'arm64') return TargetPlatform.LINUX_ARM64;
      if (arch == 'arm') return TargetPlatform.LINUX_ARMHF;
      return TargetPlatform.UNKNOWN;
    case 3: // Platform.Windows
      if (arch == 'x64') return TargetPlatform.WIN32_X64;
      if (arch == 'arm64') return TargetPlatform.WIN32_ARM64;
      return TargetPlatform.UNKNOWN;
  }
  return TargetPlatform.UNKNOWN;
}

/// 1:1: `export function isNotWebExtensionInWebTargetPlatform`.
bool isNotWebExtensionInWebTargetPlatform(
    List<String> allTargetPlatforms, String productTargetPlatform) {
  return productTargetPlatform == TargetPlatform.WEB &&
      !allTargetPlatforms.contains(TargetPlatform.WEB);
}

/// 1:1: `export function isTargetPlatformCompatible`.
bool isTargetPlatformCompatible(String extensionTargetPlatform,
    List<String> allTargetPlatforms, String productTargetPlatform) {
  if (isNotWebExtensionInWebTargetPlatform(
      allTargetPlatforms, productTargetPlatform)) {
    return false;
  }
  if (extensionTargetPlatform == TargetPlatform.UNDEFINED) return true;
  if (extensionTargetPlatform == TargetPlatform.UNIVERSAL) return true;
  if (extensionTargetPlatform == TargetPlatform.UNKNOWN) return false;
  if (extensionTargetPlatform == productTargetPlatform) return true;
  return false;
}

/// 1:1: `export interface IGalleryExtensionProperties`.
class IGalleryExtensionProperties {
  IGalleryExtensionProperties({
    this.dependencies,
    this.extensionPack,
    this.engine,
    this.enabledApiProposals,
    this.localizedLanguages,
    required this.targetPlatform,
    required this.isPreReleaseVersion,
    this.executesCode,
  });
  final List<String>? dependencies;
  final List<String>? extensionPack;
  final String? engine;
  final List<String>? enabledApiProposals;
  final List<String>? localizedLanguages;
  final String targetPlatform;
  final bool isPreReleaseVersion;
  final bool? executesCode;
}

/// 1:1: `export const enum ExtensionBlockingOrigin`.
class ExtensionBlockingOrigin {
  static const String Service = 'service';
  static const String Policy = 'policy';
}

/// 1:1: `export const enum ExtensionBlockingScope`.
class ExtensionBlockingScope {
  static const String Extension = 'extension';
  static const String Version = 'version';
}

/// 1:1: `export interface IExtensionBlockingInfo`.
class IExtensionBlockingInfo {
  IExtensionBlockingInfo({required this.origin, required this.scope});
  final String origin;
  final String scope;
}

/// 1:1: `export interface IGalleryExtensionAsset`.
class IGalleryExtensionAsset {
  IGalleryExtensionAsset({required this.uri, required this.fallbackUri});
  final String uri;
  final String fallbackUri;
}

/// 1:1: `export interface IGalleryExtensionAssets`.
class IGalleryExtensionAssets {
  IGalleryExtensionAssets({
    this.manifest,
    this.readme,
    this.changelog,
    this.license,
    this.repository,
    required this.download,
    this.icon,
    this.signature,
    required this.coreTranslations,
  });
  final IGalleryExtensionAsset? manifest;
  final IGalleryExtensionAsset? readme;
  final IGalleryExtensionAsset? changelog;
  final IGalleryExtensionAsset? license;
  final IGalleryExtensionAsset? repository;
  final IGalleryExtensionAsset download;
  final IGalleryExtensionAsset? icon;
  final IGalleryExtensionAsset? signature;
  final List<List<Object>> coreTranslations; // [string, IGalleryExtensionAsset][]
}

/// 1:1: `export function isIExtensionIdentifier`.
bool isIExtensionIdentifier(Object? obj) {
  final Object? thing = obj;
  if (thing == null) return false;
  if (thing is! Map && thing is! IExtensionIdentifier) return false;
  final Object? id;
  final Object? uuid;
  if (thing is Map) {
    id = thing['id'];
    uuid = thing['uuid'];
  } else {
    id = (thing as IExtensionIdentifier).id;
    uuid = thing.uuid;
  }
  if (id is! String) return false;
  // TS: `(!thing.uuid || typeof thing.uuid === 'string')`
  final bool uuidOk = uuid == null || uuid == '' || uuid is String;
  return uuidOk;
}

/// 1:1: `export interface IExtensionIdentifier`.
class IExtensionIdentifier {
  IExtensionIdentifier({required this.id, this.uuid});
  final String id;
  final String? uuid;
}

/// 1:1: `export interface IGalleryExtensionIdentifier extends IExtensionIdentifier`.
/// TS narrows optional `uuid?` to required `uuid`; Dart cannot override a field
/// with a different type, so the required invariant is enforced by the ctor.
class IGalleryExtensionIdentifier extends IExtensionIdentifier {
  IGalleryExtensionIdentifier({required super.id, required String uuid})
      : super(uuid: uuid);
}

/// 1:1: `export interface IGalleryExtensionVersion`.
class IGalleryExtensionVersion {
  IGalleryExtensionVersion({
    required this.version,
    required this.date,
    required this.isPreReleaseVersion,
    required this.targetPlatforms,
  });
  final String version;
  final String date;
  final bool isPreReleaseVersion;
  final List<String> targetPlatforms;
}

/// 1:1: `export interface IGalleryExtension`.
class IGalleryExtension {
  IGalleryExtension({
    required this.type,
    required this.name,
    required this.identifier,
    required this.version,
    required this.displayName,
    required this.publisherId,
    required this.publisher,
    required this.publisherDisplayName,
    this.publisherDomain,
    this.publisherLink,
    this.publisherSponsorLink,
    required this.description,
    required this.installCount,
    required this.rating,
    required this.ratingCount,
    required this.categories,
    required this.tags,
    required this.releaseDate,
    required this.lastUpdated,
    required this.preview,
    required this.private,
    this.blockingInfo,
    required this.hasPreReleaseVersion,
    required this.hasReleaseVersion,
    required this.isSigned,
    required this.allTargetPlatforms,
    required this.assets,
    required this.properties,
    this.detailsLink,
    this.ratingLink,
    this.supportLink,
    this.telemetryData,
    this.queryContext,
  });
  final String type;
  final String name;
  final IGalleryExtensionIdentifier identifier;
  final String version;
  final String displayName;
  final String publisherId;
  final String publisher;
  final String publisherDisplayName;
  final Map<String, Object>? publisherDomain;
  final String? publisherLink;
  final String? publisherSponsorLink;
  final String description;
  final num installCount;
  final num rating;
  final num ratingCount;
  final List<String> categories;
  final List<String> tags;
  final num releaseDate;
  final num lastUpdated;
  final bool preview;
  final bool private;
  final IExtensionBlockingInfo? blockingInfo;
  final bool hasPreReleaseVersion;
  final bool hasReleaseVersion;
  final bool isSigned;
  final List<String> allTargetPlatforms;
  final IGalleryExtensionAssets assets;
  final IGalleryExtensionProperties properties;
  final String? detailsLink;
  final String? ratingLink;
  final String? supportLink;
  final IStringDictionary<Object?>? telemetryData;
  final IStringDictionary<Object?>? queryContext;
}

/// 1:1: `export type InstallSource`.
typedef InstallSource = String;

/// 1:1: `export interface IGalleryMetadata`.
class IGalleryMetadata {
  IGalleryMetadata({
    required this.id,
    required this.publisherId,
    required this.private,
    required this.publisherDisplayName,
    required this.isPreReleaseVersion,
    this.targetPlatform,
  });
  final String id;
  final String publisherId;
  final bool private;
  final String publisherDisplayName;
  final bool isPreReleaseVersion;
  final String? targetPlatform;
}

/// 1:1: `export type Metadata = Partial<...>` (carrier map).
typedef Metadata = Map<String, Object?>;

/// 1:1: `export interface ILocalExtension extends IExtension`.
abstract class ILocalExtension {
  bool get isWorkspaceScoped;
  bool get isMachineScoped;
  bool get isApplicationScoped;
  String? get publisherId;
  num? get installedTimestamp;
  bool get isPreReleaseVersion;
  bool get hasPreReleaseVersion;
  bool get private;
  bool get preRelease;
  bool get updated;
  bool get pinned;
  bool get forceAutoUpdate;
  InstallSource get source;
  num get size;
}

/// 1:1: `export const enum SortBy`.
class SortBy {
  static const String NoneOrRelevance = 'NoneOrRelevance';
  static const String LastUpdatedDate = 'LastUpdatedDate';
  static const String Title = 'Title';
  static const String PublisherName = 'PublisherName';
  static const String InstallCount = 'InstallCount';
  static const String PublishedDate = 'PublishedDate';
  static const String AverageRating = 'AverageRating';
  static const String WeightedRating = 'WeightedRating';
}

/// 1:1: `export const enum SortOrder`.
class SortOrder {
  static const int Default = 0;
  static const int Ascending = 1;
  static const int Descending = 2;
}

/// 1:1: `export const enum FilterType`.
class FilterType {
  static const String Category = 'Category';
  static const String ExtensionId = 'ExtensionId';
  static const String ExtensionName = 'ExtensionName';
  static const String ExcludeWithFlags = 'ExcludeWithFlags';
  static const String Featured = 'Featured';
  static const String SearchText = 'SearchText';
  static const String Tag = 'Tag';
  static const String Target = 'Target';
}

/// 1:1: `export interface IQueryOptions`.
class IQueryOptions {
  IQueryOptions({
    this.text,
    this.exclude,
    this.pageSize,
    this.sortBy,
    this.sortOrder,
    this.source,
    this.includePreRelease,
    this.productVersion,
  });
  final String? text;
  final List<String>? exclude;
  final num? pageSize;
  final String? sortBy;
  final int? sortOrder;
  final String? source;
  final bool? includePreRelease;
  final IProductVersion? productVersion;
}

/// 1:1: `export const enum StatisticType`.
class StatisticType {
  static const String Install = 'install';
  static const String Uninstall = 'uninstall';
}

/// 1:1: `export interface IDeprecationInfo`.
class IDeprecationInfo {
  IDeprecationInfo({
    this.disallowInstall,
    this.extension,
    this.settings,
    this.additionalInfo,
  });
  final bool? disallowInstall;
  final Map<String, Object?>? extension;
  final List<String>? settings;
  final String? additionalInfo;
}

/// 1:1: `export interface ISearchPrefferedResults`.
class ISearchPrefferedResults {
  ISearchPrefferedResults({this.query, this.preferredResults});
  final String? query;
  final List<String>? preferredResults;
}

/// 1:1: `export type MaliciousExtensionInfo`.
typedef MaliciousExtensionInfo = Map<String, Object?>;

/// 1:1: `export interface IExtensionsControlManifest`.
class IExtensionsControlManifest {
  IExtensionsControlManifest({
    required this.malicious,
    required this.deprecated,
    required this.search,
    this.autoUpdate,
  });
  final List<MaliciousExtensionInfo> malicious;
  final IStringDictionary<IDeprecationInfo> deprecated;
  final List<ISearchPrefferedResults> search;
  final IStringDictionary<String>? autoUpdate;
}

/// 1:1: `export const enum InstallOperation`.
class InstallOperation {
  static const int None = 1;
  static const int Install = 2;
  static const int Update = 3;
  static const int Migrate = 4;
}

/// 1:1: `export interface ITranslation`.
class ITranslation {
  ITranslation({required this.contents});
  final Map<String, Map<String, Object?>> contents;
}

/// 1:1: `export interface IExtensionInfo`.
class IExtensionInfo {
  IExtensionInfo({
    required this.id,
    this.uuid,
    this.version,
    this.preRelease,
    this.hasPreRelease,
    this.currentVersion,
  });
  final String id;
  final String? uuid;
  final String? version;
  final bool? preRelease;
  final bool? hasPreRelease;
  final String? currentVersion;
}

/// 1:1: `export interface IExtensionQueryOptions`.
class IExtensionQueryOptions {
  IExtensionQueryOptions({
    this.targetPlatform,
    this.productVersion,
    this.compatible,
    this.queryAllVersions,
    this.includeBlockedVersions,
    this.source,
  });
  final String? targetPlatform;
  final IProductVersion? productVersion;
  final bool? compatible;
  final bool? queryAllVersions;
  final bool? includeBlockedVersions;
  final String? source;
}

/// 1:1: `export interface IExtensionGalleryCapabilities`.
class IExtensionGalleryCapabilities {
  IExtensionGalleryCapabilities({required this.query, required this.allRepositorySigned});
  final Map<String, Object?> query;
  final bool allRepositorySigned;
}

/// 1:1: `export const IExtensionGalleryService = createDecorator(...)`.
final ServiceIdentifier<IExtensionGalleryServiceType> IExtensionGalleryService =
    createDecorator<IExtensionGalleryServiceType>('extensionGalleryService');

/// 1:1: `export interface IExtensionGalleryService` (Type-suffixed).
abstract class IExtensionGalleryServiceType {
  bool isEnabled();
  Future<IPager<IGalleryExtension>> query(IQueryOptions options, CancellationToken token);
  Future<List<IGalleryExtension>> getExtensions(List<IExtensionInfo> extensionInfos, CancellationToken token);
  Future<bool> isExtensionCompatible(IGalleryExtension extension, bool includePreRelease,
      String targetPlatform, [IProductVersion? productVersion]);
  Future<IGalleryExtension?> getCompatibleExtension(IGalleryExtension extension,
      bool includePreRelease, String targetPlatform, [IProductVersion? productVersion]);
  Future<List<IGalleryExtensionVersion>> getAllCompatibleVersions(
      IExtensionIdentifier extensionIdentifier, bool includePreRelease, String targetPlatform);
  Future<List<IGalleryExtensionVersion>> getAllVersions(IExtensionIdentifier extensionIdentifier);
  Future<void> download(IGalleryExtension extension, URI location, int operation);
  Future<void> downloadSignatureArchive(IGalleryExtension extension, URI location);
  Future<void> reportStatistic(String publisher, String name, String version, String type);
  Future<String> getReadme(IGalleryExtension extension, CancellationToken token);
  Future<IExtensionManifest?> getManifest(IGalleryExtension extension, CancellationToken token);
  Future<String> getChangelog(IGalleryExtension extension, CancellationToken token);
  Future<ITranslation?> getCoreTranslation(IGalleryExtension extension, String languageId);
  Future<IExtensionsControlManifest> getExtensionsControlManifest();
}

/// 1:1: `export interface InstallExtensionEvent`.
class InstallExtensionEvent {
  InstallExtensionEvent({
    required this.identifier,
    required this.source,
    required this.profileLocation,
    this.applicationScoped,
    this.workspaceScoped,
  });
  final IExtensionIdentifier identifier;
  final Object source; // URI | IGalleryExtension
  final URI profileLocation;
  final bool? applicationScoped;
  final bool? workspaceScoped;
}

/// 1:1: `export interface InstallExtensionResult`.
class InstallExtensionResult {
  InstallExtensionResult({
    required this.identifier,
    required this.operation,
    this.source,
    this.local,
    this.error,
    this.context,
    required this.profileLocation,
    this.applicationScoped,
    this.workspaceScoped,
  });
  final IExtensionIdentifier identifier;
  final int operation;
  final Object? source;
  final ILocalExtension? local;
  final Object? error;
  final IStringDictionary<Object?>? context;
  final URI profileLocation;
  final bool? applicationScoped;
  final bool? workspaceScoped;
}

/// 1:1: `export interface UninstallExtensionEvent`.
class UninstallExtensionEvent {
  UninstallExtensionEvent({
    required this.identifier,
    required this.profileLocation,
    this.applicationScoped,
    this.workspaceScoped,
  });
  final IExtensionIdentifier identifier;
  final URI profileLocation;
  final bool? applicationScoped;
  final bool? workspaceScoped;
}

/// 1:1: `export interface DidUninstallExtensionEvent`.
class DidUninstallExtensionEvent {
  DidUninstallExtensionEvent({
    required this.identifier,
    this.error,
    required this.profileLocation,
    this.applicationScoped,
    this.workspaceScoped,
  });
  final IExtensionIdentifier identifier;
  final String? error;
  final URI profileLocation;
  final bool? applicationScoped;
  final bool? workspaceScoped;
}

/// 1:1: `export interface DidUpdateExtensionMetadata`.
class DidUpdateExtensionMetadata {
  DidUpdateExtensionMetadata({required this.profileLocation});
  final URI profileLocation;
}

/// 1:1: `export const enum ExtensionGalleryErrorCode`.
class ExtensionGalleryErrorCode {
  static const String Timeout = 'Timeout';
  static const String Cancelled = 'Cancelled';
  static const String ClientError = 'ClientError';
  static const String ServerError = 'ServerError';
  static const String Failed = 'Failed';
  static const String DownloadFailedWriting = 'DownloadFailedWriting';
  static const String Offline = 'Offline';
}

/// 1:1: `export class ExtensionGalleryError extends Error`.
class ExtensionGalleryError extends Error {
  ExtensionGalleryError(String message, this.code)
      : _message = message,
        name = code;
  final String _message;
  @override
  String toString() => _message;
  final String code;
  String name;
}

/// 1:1: `export const enum ExtensionManagementErrorCode`.
class ExtensionManagementErrorCode {
  static const String NotFound = 'NotFound';
  static const String Unsupported = 'Unsupported';
  static const String Deprecated = 'Deprecated';
  static const String Malicious = 'Malicious';
  static const String Incompatible = 'Incompatible';
  static const String IncompatibleApi = 'IncompatibleApi';
  static const String IncompatibleTargetPlatform = 'IncompatibleTargetPlatform';
  static const String ReleaseVersionNotFound = 'ReleaseVersionNotFound';
  static const String Invalid = 'Invalid';
  static const String Download = 'Download';
  static const String DownloadSignature = 'DownloadSignature';
  static const String DownloadFailedWriting = ExtensionGalleryErrorCode.DownloadFailedWriting;
  static const String UpdateMetadata = 'UpdateMetadata';
  static const String Extract = 'Extract';
  static const String Scanning = 'Scanning';
  static const String ScanningExtension = 'ScanningExtension';
  static const String ReadRemoved = 'ReadRemoved';
  static const String UnsetRemoved = 'UnsetRemoved';
  static const String Delete = 'Delete';
  static const String Rename = 'Rename';
  static const String IntializeDefaultProfile = 'IntializeDefaultProfile';
  static const String AddToProfile = 'AddToProfile';
  static const String InstalledExtensionNotFound = 'InstalledExtensionNotFound';
  static const String PostInstall = 'PostInstall';
  static const String CorruptZip = 'CorruptZip';
  static const String IncompleteZip = 'IncompleteZip';
  static const String PackageNotSigned = 'PackageNotSigned';
  static const String SignatureVerificationInternal = 'SignatureVerificationInternal';
  static const String SignatureVerificationFailed = 'SignatureVerificationFailed';
  static const String NotAllowed = 'NotAllowed';
  static const String Gallery = 'Gallery';
  static const String Cancelled = 'Cancelled';
  static const String Unknown = 'Unknown';
  static const String Internal = 'Internal';
}

/// 1:1: `export enum ExtensionSignatureVerificationCode` (real string enum).
enum ExtensionSignatureVerificationCode {
  NotSigned,
  Success,
  RequiredArgumentMissing,
  InvalidArgument,
  PackageIsUnreadable,
  UnhandledException,
  SignatureManifestIsMissing,
  SignatureManifestIsUnreadable,
  SignatureIsMissing,
  SignatureIsUnreadable,
  CertificateIsUnreadable,
  SignatureArchiveIsUnreadable,
  FileAlreadyExists,
  SignatureArchiveIsInvalidZip,
  SignatureArchiveHasSameSignatureFile,
  PackageIntegrityCheckFailed,
  SignatureIsInvalid,
  SignatureManifestIsInvalid,
  SignatureIntegrityCheckFailed,
  EntryIsMissing,
  EntryIsTampered,
  Untrusted,
  CertificateRevoked,
  SignatureIsNotValid,
  UnknownError,
  PackageIsInvalidZip,
  SignatureArchiveHasTooManyEntries,
}

/// 1:1: `export class ExtensionManagementError extends Error`.
class ExtensionManagementError extends Error {
  ExtensionManagementError(String message, this.code)
      : _message = message,
        name = code;
  final String _message;
  @override
  String toString() => _message;
  final String code;
  String name;
}

/// 1:1: `export interface InstallExtensionSummary`.
class InstallExtensionSummary {
  InstallExtensionSummary({required this.failed});
  final List<Map<String, Object>> failed; // { id, installOptions }
}

/// 1:1: `export type InstallOptions`.
typedef InstallOptions = Map<String, Object?>;

/// 1:1: `export type UninstallOptions`.
typedef UninstallOptions = Map<String, Object?>;

/// 1:1: `export interface IExtensionManagementParticipant`.
abstract class IExtensionManagementParticipant {
  Future<void> postInstall(ILocalExtension local, Object source,
      InstallOptions options, CancellationToken token);
  Future<void> postUninstall(ILocalExtension local,
      UninstallOptions options, CancellationToken token);
}

/// 1:1: `export type InstallExtensionInfo`.
typedef InstallExtensionInfo = Map<String, Object>;

/// 1:1: `export type UninstallExtensionInfo`.
typedef UninstallExtensionInfo = Map<String, Object?>;

/// 1:1: `export const IExtensionManagementService = createDecorator(...)`.
final ServiceIdentifier<IExtensionManagementServiceType> IExtensionManagementService =
    createDecorator<IExtensionManagementServiceType>('extensionManagementService');

/// 1:1: `export interface IExtensionManagementService` (Type-suffixed).
abstract class IExtensionManagementServiceType {
  bool get preferPreReleases;
  Event<InstallExtensionEvent> get onInstallExtension;
  Event<List<InstallExtensionResult>> get onDidInstallExtensions;
  Event<UninstallExtensionEvent> get onUninstallExtension;
  Event<DidUninstallExtensionEvent> get onDidUninstallExtension;
  Event<DidUpdateExtensionMetadata> get onDidUpdateExtensionMetadata;
  Future<URI> zip(ILocalExtension extension);
  Future<IExtensionManifest> getManifest(URI vsix);
  Future<ILocalExtension> install(URI vsix, [InstallOptions? options]);
  Future<Object> canInstall(IGalleryExtension extension); // true | IMarkdownString
  Future<ILocalExtension> installFromGallery(IGalleryExtension extension, [InstallOptions? options]);
  Future<List<InstallExtensionResult>> installGalleryExtensions(List<InstallExtensionInfo> extensions);
  Future<ILocalExtension> installFromLocation(URI location, URI profileLocation);
  Future<List<ILocalExtension>> installExtensionsFromProfile(
      List<IExtensionIdentifier> extensions, URI fromProfileLocation, URI toProfileLocation);
  Future<void> uninstall(ILocalExtension extension, [UninstallOptions? options]);
  Future<void> uninstallExtensions(List<UninstallExtensionInfo> extensions);
  Future<ILocalExtension> toggleApplicationScope(ILocalExtension extension, URI fromProfileLocation);
  Future<List<ILocalExtension>> getInstalled([
    int? type,
    URI? profileLocation,
    IProductVersion? productVersion,
    String? language,
  ]);
  Future<IExtensionsControlManifest> getExtensionsControlManifest();
  Future<void> copyExtensions(URI fromProfileLocation, URI toProfileLocation);
  Future<ILocalExtension> updateMetadata(
      ILocalExtension local, Metadata metadata, URI profileLocation);
  Future<void> resetPinnedStateForAllUserExtensions(bool pinned);
  Future<URI> download(IGalleryExtension extension, int operation, bool donotVerifySignature);
  void registerParticipant(IExtensionManagementParticipant pariticipant);
  Future<String> getTargetPlatform();
  Future<void> cleanUp();
}

/// 1:1: `export const DISABLED_EXTENSIONS_STORAGE_PATH`.
const String DISABLED_EXTENSIONS_STORAGE_PATH = 'extensionsIdentifiers/disabled';

/// 1:1: `export const ENABLED_EXTENSIONS_STORAGE_PATH`.
const String ENABLED_EXTENSIONS_STORAGE_PATH = 'extensionsIdentifiers/enabled';

/// 1:1: `export const IGlobalExtensionEnablementService = createDecorator(...)`.
final ServiceIdentifier<IGlobalExtensionEnablementServiceType>
    IGlobalExtensionEnablementService =
    createDecorator<IGlobalExtensionEnablementServiceType>(
        'IGlobalExtensionEnablementService');

/// 1:1: `export interface IGlobalExtensionEnablementService` (Type-suffixed).
abstract class IGlobalExtensionEnablementServiceType {
  Event<Map<String, Object?>> get onDidChangeEnablement;
  List<IExtensionIdentifier> getDisabledExtensions();
  Future<bool> enableExtension(IExtensionIdentifier extension, [String? source]);
  Future<bool> disableExtension(IExtensionIdentifier extension, [String? source]);
}

/// 1:1: `export type IConfigBasedExtensionTip`.
typedef IConfigBasedExtensionTip = Map<String, Object?>;

/// 1:1: `export type IExecutableBasedExtensionTip`.
typedef IExecutableBasedExtensionTip = Map<String, Object?>;

/// 1:1: `export const IExtensionTipsService = createDecorator(...)`.
final ServiceIdentifier<IExtensionTipsServiceType> IExtensionTipsService =
    createDecorator<IExtensionTipsServiceType>('IExtensionTipsService');

/// 1:1: `export interface IExtensionTipsService` (Type-suffixed).
abstract class IExtensionTipsServiceType {
  Future<List<IConfigBasedExtensionTip>> getConfigBasedTips(URI folder);
  Future<List<IExecutableBasedExtensionTip>> getImportantExecutableBasedTips();
  Future<List<IExecutableBasedExtensionTip>> getOtherExecutableBasedTips();
}

/// 1:1: `export type AllowedExtensionsConfigValueType`.
typedef AllowedExtensionsConfigValueType = Map<String, Object?>;

/// 1:1: `export const IAllowedExtensionsService = createDecorator(...)`.
final ServiceIdentifier<IAllowedExtensionsServiceType> IAllowedExtensionsService =
    createDecorator<IAllowedExtensionsServiceType>('IAllowedExtensionsService');

/// 1:1: `export interface IAllowedExtensionsService` (Type-suffixed).
abstract class IAllowedExtensionsServiceType {
  AllowedExtensionsConfigValueType? get allowedExtensionsConfigValue;
  Event<void> get onDidChangeAllowedExtensionsConfigValue;
  Object isAllowed(Object extension); // true | IMarkdownString
}

/// Minimal carrier of the TS `IFileStat` fields used by [computeSize].
/// (files.dart does not yet export IFileStat; kept local to avoid inventing a
/// cross-module port while preserving the exact algorithm.)
abstract class IFileStat {
  URI get resource;
  num? get size;
  List<IFileStat>? get children;
}

/// 1:1: `export async function computeSize(location, fileService)`.
Future<num> computeSize(URI location, IFileServiceType fileService) async {
  late IFileStat stat;
  try {
    // IFileServiceType.resolve is not yet part of the ported interface; the TS
    // algorithm calls it here. Use a dynamic dispatch so callers that provide
    // a concrete service with `resolve` behave 1:1.
    stat = await (fileService as dynamic).resolve(location) as IFileStat;
  } catch (e) {
    if (e is FileOperationError &&
        e.fileOperationResult == FileOperationResult.FILE_NOT_FOUND) {
      return 0;
    }
    rethrow;
  }
  final List<IFileStat>? children = stat.children;
  if (children != null) {
    final List<num> sizes = await Future.wait(
        children.map((c) => computeSize(c.resource, fileService)));
    return sizes.fold<num>(0, (r, s) => r + s);
  }
  return stat.size ?? 0;
}

/// 1:1: `export const ExtensionsLocalizedLabel = localize2(...)`.
final ILocalizedString ExtensionsLocalizedLabel =
    localize2('extensions', 'Extensions');

/// 1:1: `export const PreferencesLocalizedLabel = localize2(...)`.
final ILocalizedString PreferencesLocalizedLabel =
    localize2('preferences', 'Preferences');

/// 1:1: `export const AllowedExtensionsConfigKey`.
const String AllowedExtensionsConfigKey = 'extensions.allowed';

/// 1:1: `export const VerifyExtensionSignatureConfigKey`.
const String VerifyExtensionSignatureConfigKey = 'extensions.verifySignature';

/// 1:1: `export const ExtensionRequestsTimeoutConfigKey`.
const String ExtensionRequestsTimeoutConfigKey = 'extensions.requestTimeout';

bool _configRegistered = false;

/// 1:1: top-level `Registry.as<IConfigurationRegistry>(Extensions.Configuration)
/// .registerConfiguration({...})` side effect. Dart has no top-level statements,
/// so it is triggered lazily and exposed for verification.
IConfigurationNode? _registeredConfiguration;

IConfigurationNode? ensureConfigurationRegistered() {
  if (_configRegistered) return _registeredConfiguration;
  _configRegistered = true;
  final node = IConfigurationNode(
    id: 'extensions',
    order: 30,
    type: 'object',
    title: localize('extensionsConfigurationTitle', 'Extensions'),
    properties: <String, IConfigurationPropertySchema>{
      AllowedExtensionsConfigKey: <String, Object?>{
        'type': 'object',
        'markdownDescription': localize('extensions.allowed',
            'Specify a list of extensions that are allowed to use. This helps maintain a secure and consistent development environment by restricting the use of unauthorized extensions. For more information on how to configure this setting, please visit the [Configure Allowed Extensions](https://aka.ms/vscode/enterprise/extensions/allowed) section.'),
        'default': '*',
        'scope': ConfigurationScope.APPLICATION,
        'policy': <String, Object?>{
          'name': 'AllowedExtensions',
          'category': PolicyCategory.Extensions,
          'minimumVersion': '1.96',
        },
        'additionalProperties': false,
        'patternProperties': <String, Object?>{
          EXTENSION_IDENTIFIER_PATTERN: <String, Object?>{
            'anyOf': <Object?>[],
          },
          EXTENSION_PUBLISHER_IDENTIFIER_PATTERN: <String, Object?>{
            'type': <Object?>['boolean', 'string'],
            'enum': <Object?>[true, false, 'stable'],
          },
          r'\*': <String, Object?>{
            'type': 'boolean',
            'enum': <Object?>[true, false],
          },
        },
      },
    },
  );
  // TS `Registry.as<IConfigurationRegistry>(Extensions.Configuration)` resolves
  // to the singleton registered by configurationRegistry's top-level side effect.
  // Dart top-level initializers are lazy, so force that registration here if it
  // has not fired yet.
  if (!Registry.knows(Extensions.Configuration)) {
    Registry.add(Extensions.Configuration, configurationRegistry);
  }
  (Registry.as(Extensions.Configuration) as IConfigurationRegistryType)
      .registerConfiguration(node);
  _registeredConfiguration = node;
  return node;
}

/// 1:1: `export function shouldRequireRepositorySignatureFor`.
bool shouldRequireRepositorySignatureFor(
    bool isPrivate, IExtensionGalleryManifest? galleryManifest) {
  if (isPrivate) {
    return _manifestSigningValue(galleryManifest, 'allPrivateRepositorySigned') == true;
  }
  return _manifestSigningValue(galleryManifest, 'allPublicRepositorySigned') == true;
}

Object? _manifestSigningValue(
    IExtensionGalleryManifest? manifest, String key) {
  if (manifest == null) return null;
  final Object? capabilities = manifest.capabilities;
  if (capabilities == null) return null;
  final Object? signing = _readField(capabilities, 'signing');
  if (signing == null) return null;
  return _readField(signing, key);
}

Object? _readField(Object obj, String key) {
  if (obj is Map) return obj[key];
  // Nested capability carriers may be concrete Dart objects; support reflective
  // read via a `toJson`-style map when present.
  final dynamic d = obj;
  try {
    final dynamic fn = d.toJson;
    if (fn is Function) {
      final Object? m = fn();
      if (m is Map) return m[key];
    }
  } catch (_) {}
  return null;
}
