// 1:1 port of vs/platform/label/common/label.ts
// Declaration-only module: 1 decorator, 1 const enum, 7 interfaces.
// Adaptations (consistent with earlier batches):
//   structural types (options literals) -> Map<String, Object?> carriers;
//   union `IWorkspaceIdentifier | ... | URI | IWorkspace` -> Object? carrier;
//   string-literal unions ('/' | '\\' | '') -> String;
//   const enum in type position -> int.
import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const ILabelService = createDecorator<ILabelService>('labelService')`
final ServiceIdentifier<ILabelServiceType> ILabelService =
    createDecorator<ILabelServiceType>('labelService');

/// 1:1: `export interface ILabelService` (const keeps the bare name).
abstract class ILabelServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `getUriLabel(resource, options?)`
  /// options: `{ relative?, noPrefix?, separator?, appendWorkspaceSuffix? }`
  String getUriLabel(URI resource, [Map<String, Object?>? options]);

  /// 1:1: `getUriBasenameLabel(resource: URI): string`
  String getUriBasenameLabel(URI resource);

  /// 1:1: `getWorkspaceLabel(workspace, options?)`
  /// workspace: `IWorkspaceIdentifier | ISingleFolderWorkspaceIdentifier | URI | IWorkspace`
  /// options: `{ verbose?: Verbosity, withLocation?: boolean }`
  String getWorkspaceLabel(Object workspace, [Map<String, Object?>? options]);

  /// 1:1: `getFolderLocationLabel(folder: URI): string | undefined`
  String? getFolderLocationLabel(URI folder);

  /// 1:1: `registerWorkspaceLabelDecorator(decorator): IDisposable`
  IDisposable registerWorkspaceLabelDecorator(IWorkspaceLabelDecorator decorator);

  /// 1:1: `getHostLabel(scheme: string, authority?: string): string`
  String getHostLabel(String scheme, [String? authority]);

  /// 1:1: `getHostTooltip(scheme: string, authority?: string): string | undefined`
  String? getHostTooltip(String scheme, [String? authority]);

  /// 1:1: `getSeparator(scheme: string, authority?: string): '/' | '\\'`
  String getSeparator(String scheme, [String? authority]);

  /// 1:1: `getUriHome(resource: URI): URI | undefined`
  URI? getUriHome(URI resource);

  /// 1:1: `registerFormatter(formatter): IDisposable`
  IDisposable registerFormatter(
      Object formatter); // ResourceLabelFormatter | ResourceLabelTemplateFormatter

  /// 1:1: `readonly onDidChangeFormatters: Event<IFormatterChangeEvent>`
  Event<IFormatterChangeEvent> get onDidChangeFormatters;

  /// 1:1: `registerCachedFormatter(formatter): IDisposable`
  IDisposable registerCachedFormatter(ResourceLabelFormatter formatter);
}

/// 1:1: `export const enum Verbosity { SHORT, MEDIUM, LONG }`
class Verbosity {
  static const int SHORT = 0;
  static const int MEDIUM = 1;
  static const int LONG = 2;
}

/// 1:1: `export interface IWorkspaceLabelDecorator`
abstract class IWorkspaceLabelDecorator {
  /// 1:1: `readonly onDidChange: Event<URI>`
  Event<URI> get onDidChange;

  /// 1:1: `getFolderLocationLabel(folder: URI): string | undefined`
  String? getFolderLocationLabel(URI folder);
}

/// 1:1: `export interface IFormatterChangeEvent`
abstract class IFormatterChangeEvent {
  String get scheme;
}

/// 1:1: `export interface ResourceLabelFormatter`
abstract class ResourceLabelFormatter {
  String get scheme;
  String? get authority;
  String? get home; // URI path used as display home (string literal)
  bool? get priority;
  ResourceLabelFormatting get formatting;
}

/// 1:1: `export interface ResourceLabelTemplateFormatter`
abstract class ResourceLabelTemplateFormatter {
  /// 1:1: `home: URI`
  URI get home;

  /// 1:1: `onDidChangeFormatting: Event<void>`
  Event<void> get onDidChangeFormatting;

  /// 1:1: `formatting(context): ResourceLabelFormatting | undefined`
  ResourceLabelFormatting? formatting(ResourceLabelFormattingContext context);
}

/// 1:1: `export interface ResourceLabelFormattingContext`
abstract class ResourceLabelFormattingContext {
  URI get resource;
  URI get home;

  /// 1:1: `ReadonlyMap<string, string>` -> `Map<String, String>`
  Map<String, String> get parameters;
}

/// 1:1: `export interface ResourceLabelFormatting`
abstract class ResourceLabelFormatting {
  String get label; // myLabel:/${path}

  /// 1:1: `separator: '/' | '\\' | ''` -> String
  String get separator;
  bool? get tildify;
  bool? get normalizeDriveLetter;
  String? get workspaceSuffix;
  String? get workspaceTooltip;
  String? get authorityPrefix;
  bool? get stripPathStartingSeparator;
  int? get stripPathSegments;
}
