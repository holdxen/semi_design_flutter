// 1:1 port of vs/platform/extensionManagement/common/extensionGalleryManifest.ts
// Declaration module + one pure helper getExtensionGalleryManifestResourceUri.
import '../../../base/common/event.dart' show Event;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const enum ExtensionGalleryResourceType`
/// String const enum -> class with static const String; values read from runtime truth.
class ExtensionGalleryResourceType {
  const ExtensionGalleryResourceType._();
  static const String ExtensionQueryService = 'ExtensionQueryService';
  static const String ExtensionLatestVersionUri = 'ExtensionLatestVersionUriTemplate';
  static const String ExtensionStatisticsUri = 'ExtensionStatisticsUriTemplate';
  static const String PublisherViewUri = 'PublisherViewUriTemplate';
  static const String ExtensionDetailsViewUri = 'ExtensionDetailsViewUriTemplate';
  static const String ExtensionRatingViewUri = 'ExtensionRatingViewUriTemplate';
  static const String ExtensionResourceUri = 'ExtensionResourceUriTemplate';
  static const String ContactSupportUri = 'ContactSupportUri';
}

/// 1:1: `export const enum Flag`
class Flag {
  const Flag._();
  static const String None = 'None';
  static const String IncludeVersions = 'IncludeVersions';
  static const String IncludeFiles = 'IncludeFiles';
  static const String IncludeCategoryAndTags = 'IncludeCategoryAndTags';
  static const String IncludeSharedAccounts = 'IncludeSharedAccounts';
  static const String IncludeVersionProperties = 'IncludeVersionProperties';
  static const String ExcludeNonValidated = 'ExcludeNonValidated';
  static const String IncludeInstallationTargets = 'IncludeInstallationTargets';
  static const String IncludeAssetUri = 'IncludeAssetUri';
  static const String IncludeStatistics = 'IncludeStatistics';
  static const String IncludeLatestVersionOnly = 'IncludeLatestVersionOnly';
  static const String Unpublished = 'Unpublished';
  static const String IncludeNameConflictInfo = 'IncludeNameConflictInfo';
  static const String IncludeLatestPrereleaseAndStableVersionOnly =
      'IncludeLatestPrereleaseAndStableVersionOnly';
}

/// 1:1: `export type ExtensionGalleryManifestResource = { readonly id; readonly type }`
class ExtensionGalleryManifestResource {
  final String id;
  final String type;
  ExtensionGalleryManifestResource({required this.id, required this.type});
}

/// 1:1: `export type ExtensionQueryCapabilityValue = { readonly name; readonly value }`
class ExtensionQueryCapabilityValue {
  final String name;
  final num value;
  ExtensionQueryCapabilityValue({required this.name, required this.value});
}

/// 1:1: `export interface IExtensionGalleryManifest`
abstract class IExtensionGalleryManifest {
  String get version;
  List<ExtensionGalleryManifestResource> get resources;
  Object? get capabilities;
}

/// 1:1: `export const enum ExtensionGalleryManifestStatus`
class ExtensionGalleryManifestStatus {
  const ExtensionGalleryManifestStatus._();
  static const String Available = 'available';
  static const String RequiresSignIn = 'requiresSignIn';
  static const String AccessDenied = 'accessDenied';
  static const String Unavailable = 'unavailable';
}

/// 1:1: `export const IExtensionGalleryManifestService = createDecorator(...)`
final ServiceIdentifier<IExtensionGalleryManifestServiceType>
    IExtensionGalleryManifestService =
    createDecorator<IExtensionGalleryManifestServiceType>(
        'IExtensionGalleryManifestService');

/// 1:1: `export interface IExtensionGalleryManifestService` (const keeps bare name).
abstract class IExtensionGalleryManifestServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  String get extensionGalleryManifestStatus;
  Event<String> get onDidChangeExtensionGalleryManifestStatus;
  Event<IExtensionGalleryManifest?> get onDidChangeExtensionGalleryManifest;
  Future<IExtensionGalleryManifest?> getExtensionGalleryManifest();
  Future<String?> getAccessToken(String targetUrl);
}

/// 1:1: `export function getExtensionGalleryManifestResourceUri(manifest, type)`
/// Returns the resource id, or null (TS `undefined`) when no match.
String? getExtensionGalleryManifestResourceUri(
    IExtensionGalleryManifest manifest, String type) {
  // `const [name, version] = type.split('/')` — JS destructuring takes first 2.
  final parts = type.split('/');
  final name = parts.isNotEmpty ? parts[0] : null;
  final version = parts.length > 1 ? parts[1] : null;
  for (final resource in manifest.resources) {
    final rv = resource.type.split('/');
    final r = rv.isNotEmpty ? rv[0] : null;
    final v = rv.length > 1 ? rv[1] : null;
    if (r != name) {
      continue;
    }
    // `if (!version || v === version)` — JS truthiness: '' is falsy.
    final versionTruthy = version != null && version.isNotEmpty;
    if (!versionTruthy || v == version) {
      return resource.id;
    }
    break;
  }
  return null;
}

/// 1:1: `export const ExtensionGalleryServiceUrlConfigKey`
const String ExtensionGalleryServiceUrlConfigKey =
    'extensions.gallery.serviceUrl';

/// 1:1: `export const ExtensionGalleryAuthProviderConfigKey`
const String ExtensionGalleryAuthProviderConfigKey =
    'extensions.gallery.authProvider';
