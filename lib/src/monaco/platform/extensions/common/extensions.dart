// 1:1 port of vs/platform/extensions/common/extensions.ts
// Truth: tool/ts2dart/batch129_truth.json — real transpiled extensions.ts +
// strings.ts + charCode.ts + remoteHosts.ts; type-only boundaries stubbed.
// ---------------------------------------------------------------------------

import '../../../base/common/strings.dart' as strings;
import '../../../base/common/uri.dart' as uri;
import '../../environment/common/environment.dart' show ExtensionKind;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../remote/common/remoteHosts.dart' as remoteHosts;

const String USER_MANIFEST_CACHE_FILE_PREFIX = 'extensions.user';
const String BUILTIN_MANIFEST_CACHE_FILE_PREFIX = 'extensions.builtin';
const String UNDEFINED_PUBLISHER = 'undefined_publisher';

/// 1:1: `const SCAN_LANGUAGE_PATTERN`.
final RegExp _scanLanguagePattern =
    RegExp(r'^[a-z0-9]([a-z0-9-]{0,30}[a-z0-9])?$');

/// 1:1: `getManifestCacheFilePrefix(type)`.
String _getManifestCacheFilePrefix(int type) => type == ExtensionType.System
    ? BUILTIN_MANIFEST_CACHE_FILE_PREFIX
    : USER_MANIFEST_CACHE_FILE_PREFIX;

/// 1:1: `getManifestCacheFileName(type, language)`.
String getManifestCacheFileName(int type, String? language) {
  final String prefix = _getManifestCacheFilePrefix(type);
  final String? normalized = language?.toLowerCase();
  if (normalized == null ||
      normalized.isEmpty ||
      !_scanLanguagePattern.hasMatch(normalized)) {
    return '$prefix.cache';
  }
  return '$prefix.$normalized.cache';
}

/// 1:1: `isManifestCacheFileName(name, type, ignorePathCasing)`.
bool isManifestCacheFileName(
    String name, int type, bool ignorePathCasing) {
  final String candidate = ignorePathCasing ? name.toLowerCase() : name;
  return candidate.startsWith('${_getManifestCacheFilePrefix(type)}.') &&
      candidate.endsWith('.cache');
}

// ---- contribution interfaces (data carriers, 1:1 member shapes) ----------

/// 1:1: `export interface ICommand`.
class ICommand {
  ICommand({
    required this.command,
    required this.title,
    this.category,
  });

  final String command;
  final Object title; // string | ILocalizedString
  final Object? category; // string | ILocalizedString | undefined
}

/// 1:1: `export interface IDebugger`.
class IDebugger {
  IDebugger({this.label, required this.type, this.runtime});
  final String? label;
  final String type;
  final String? runtime;
}

/// 1:1: `export interface IGrammar`.
class IGrammar {
  IGrammar({this.language});
  final String? language;
}

/// 1:1: `export interface IJSONValidation`.
class IJSONValidation {
  IJSONValidation({required this.fileMatch, required this.url});
  final Object fileMatch; // string | string[]
  final String url;
}

/// 1:1: `export interface IJSONValidationRegistry`.
class IJSONValidationRegistry {
  IJSONValidationRegistry({required this.url});
  final String url;
}

/// 1:1: `export interface IKeyBinding`.
class IKeyBinding {
  IKeyBinding({
    required this.command,
    required this.key,
    this.when,
    this.mac,
    this.linux,
    this.win,
  });
  final String command;
  final String key;
  final String? when;
  final String? mac;
  final String? linux;
  final String? win;
}

/// 1:1: `export interface ILanguage`.
class ILanguage {
  ILanguage({
    required this.id,
    required this.extensions,
    required this.aliases,
  });
  final String id;
  final List<String> extensions;
  final List<String> aliases;
}

/// 1:1: `export interface IMenu`.
class IMenu {
  IMenu({required this.command, this.alt, this.when, this.group});
  final String command;
  final String? alt;
  final String? when;
  final String? group;
}

/// 1:1: `export interface ISnippet`.
class ISnippet {
  ISnippet({required this.language});
  final String language;
}

/// 1:1: `export interface ITheme`.
class ITheme {
  ITheme({required this.label});
  final String label;
}

/// 1:1: `export interface IViewContainer`.
class IViewContainer {
  IViewContainer({required this.id, required this.title});
  final String id;
  final String title;
}

/// 1:1: `export interface IView`.
class IView {
  IView({required this.id, required this.name});
  final String id;
  final String name;
}

/// 1:1: `export interface IColor`.
class IColor {
  IColor({
    required this.id,
    required this.description,
    required this.defaults,
  });
  final String id;
  final String description;
  final Map<String, String> defaults; // light / dark / highContrast
}

/// 1:1: `interface IWebviewEditor` (not exported in TS, kept for 1:1 shape).
class IWebviewEditor {
  IWebviewEditor({
    required this.viewType,
    required this.priority,
    required this.selector,
  });
  final String viewType;
  final String priority;
  final List<Map<String, String?>> selector; // { filenamePattern? }[]
}

/// 1:1: `export interface ICodeActionContributionAction`.
class ICodeActionContributionAction {
  ICodeActionContributionAction({
    required this.kind,
    required this.title,
    this.description,
  });
  final String kind;
  final String title;
  final String? description;
}

/// 1:1: `export interface ICodeActionContribution`.
class ICodeActionContribution {
  ICodeActionContribution({
    required this.languages,
    required this.actions,
  });
  final List<String> languages;
  final List<ICodeActionContributionAction> actions;
}

/// 1:1: `export interface IAuthenticationContribution`.
class IAuthenticationContribution {
  IAuthenticationContribution({
    required this.id,
    required this.label,
    this.authorizationServerGlobs,
  });
  final String id;
  final String label;
  final List<String>? authorizationServerGlobs;
}

/// 1:1: `export interface IWalkthroughStep` (media is a tagged union carrier).
class IWalkthroughStep {
  IWalkthroughStep({
    required this.id,
    required this.title,
    required this.description,
    required this.media,
    this.completionEvents,
    this.doneOn,
    this.when,
  });
  final String id;
  final String title;
  final String? description;
  final Object media;
  final List<String>? completionEvents;
  final Map<String, String>? doneOn; // { command }
  final String? when;
}

/// 1:1: `export interface IWalkthrough`.
class IWalkthrough {
  IWalkthrough({
    required this.id,
    required this.title,
    this.icon,
    required this.description,
    required this.steps,
    required this.featuredFor,
    this.when,
  });
  final String id;
  final String title;
  final String? icon;
  final String description;
  final List<IWalkthroughStep> steps;
  final List<String>? featuredFor;
  final String? when;
}

/// 1:1: `export interface IStartEntry`.
class IStartEntry {
  IStartEntry({
    required this.title,
    required this.description,
    required this.command,
    this.when,
    required this.category,
  });
  final String title;
  final String description;
  final String command;
  final String? when;
  final String category; // 'file' | 'folder' | 'notebook'
}

/// 1:1: `export interface INotebookEntry`.
class INotebookEntry {
  INotebookEntry({required this.type, required this.displayName});
  final String type;
  final String displayName;
}

/// 1:1: `export interface INotebookRendererContribution`.
class INotebookRendererContribution {
  INotebookRendererContribution({
    required this.id,
    required this.displayName,
    required this.mimeTypes,
  });
  final String id;
  final String displayName;
  final List<String> mimeTypes;
}

/// 1:1: `export interface IDebugVisualizationContribution`.
class IDebugVisualizationContribution {
  IDebugVisualizationContribution({required this.id, required this.when});
  final String id;
  final String when;
}

/// 1:1: `export interface ITranslation`.
class ITranslation {
  ITranslation({required this.id, required this.path});
  final String id;
  final String path;
}

/// 1:1: `export interface ILocalizationContribution`.
class ILocalizationContribution {
  ILocalizationContribution({
    required this.languageId,
    this.languageName,
    this.localizedLanguageName,
    required this.translations,
    this.minimalTranslations,
  });
  final String languageId;
  final String? languageName;
  final String? localizedLanguageName;
  final List<ITranslation> translations;
  final Map<String, String>? minimalTranslations;
}

/// 1:1: `export interface IChatParticipantContribution`.
class IChatParticipantContribution {
  IChatParticipantContribution({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    this.isDefault,
    this.commands,
  });
  final String id;
  final String name;
  final String fullName;
  final String? description;
  final bool? isDefault;
  final List<Map<String, String>>? commands; // { name }[]
}

/// 1:1: `export interface IToolContribution`.
class IToolContribution {
  IToolContribution({
    required this.name,
    required this.displayName,
    required this.modelDescription,
    this.userDescription,
  });
  final String name;
  final String displayName;
  final String modelDescription;
  final String? userDescription;
}

/// 1:1: `export interface IToolSetContribution`.
class IToolSetContribution {
  IToolSetContribution({
    required this.name,
    required this.referenceName,
    required this.description,
    this.icon,
    required this.tools,
  });
  final String name;
  final String referenceName;
  final String description;
  final String? icon;
  final List<String> tools;
}

/// 1:1: `export interface IMcpCollectionContribution`.
class IMcpCollectionContribution {
  IMcpCollectionContribution({
    required this.id,
    required this.label,
    this.when,
  });
  final String id;
  final String label;
  final String? when;
}

/// 1:1: `export interface IChatFileContribution`.
class IChatFileContribution {
  IChatFileContribution({
    required this.path,
    this.name,
    this.description,
    this.when,
    this.sessionTypes,
  });
  final String path;
  final String? name;
  final String? description;
  final String? when;
  final List<String>? sessionTypes;
}

/// 1:1: `export interface IExtensionContributions`.
class IExtensionContributions {
  IExtensionContributions({
    this.commands,
    this.configuration,
    this.configurationDefaults,
    this.debuggers,
    this.grammars,
    this.jsonValidation,
    this.jsonValidationRegistry,
    this.keybindings,
    this.languages,
    this.menus,
    this.snippets,
    this.themes,
    this.iconThemes,
    this.productIconThemes,
    this.viewsContainers,
    this.views,
    this.colors,
    this.localizations,
    this.customEditors,
    this.codeActions,
    this.authentication,
    this.walkthroughs,
    this.startEntries,
    this.notebooks,
    this.notebookRenderer,
    this.debugVisualizers,
    this.chatParticipants,
    this.chatPromptFiles,
    this.chatInstructions,
    this.chatAgents,
    this.chatSkills,
    this.chatPlugins,
    this.languageModelTools,
    this.languageModelToolSets,
    this.mcpServerDefinitionProviders,
  });

  final List<ICommand>? commands;
  final Object? configuration;
  final Object? configurationDefaults;
  final List<IDebugger>? debuggers;
  final List<IGrammar>? grammars;
  final List<IJSONValidation>? jsonValidation;
  final List<IJSONValidationRegistry>? jsonValidationRegistry;
  final List<IKeyBinding>? keybindings;
  final List<ILanguage>? languages;
  final Map<String, List<IMenu>>? menus;
  final List<ISnippet>? snippets;
  final List<ITheme>? themes;
  final List<ITheme>? iconThemes;
  final List<ITheme>? productIconThemes;
  final Map<String, List<IViewContainer>>? viewsContainers;
  final Map<String, List<IView>>? views;
  final List<IColor>? colors;
  final List<ILocalizationContribution>? localizations;
  final List<IWebviewEditor>? customEditors;
  final List<ICodeActionContribution>? codeActions;
  final List<IAuthenticationContribution>? authentication;
  final List<IWalkthrough>? walkthroughs;
  final List<IStartEntry>? startEntries;
  final List<INotebookEntry>? notebooks;
  final List<INotebookRendererContribution>? notebookRenderer;
  final List<IDebugVisualizationContribution>? debugVisualizers;
  final List<IChatParticipantContribution>? chatParticipants;
  final List<IChatFileContribution>? chatPromptFiles;
  final List<IChatFileContribution>? chatInstructions;
  final List<IChatFileContribution>? chatAgents;
  final List<IChatFileContribution>? chatSkills;
  final List<IChatFileContribution>? chatPlugins;
  final List<IToolContribution>? languageModelTools;
  final List<IToolSetContribution>? languageModelToolSets;
  final List<IMcpCollectionContribution>? mcpServerDefinitionProviders;
}

/// 1:1: `export interface IExtensionCapabilities`.
class IExtensionCapabilities {
  IExtensionCapabilities({
    this.virtualWorkspaces,
    this.untrustedWorkspaces,
    this.agentsWindow,
  });
  final Object? virtualWorkspaces; // ExtensionVirtualWorkspaceSupport
  final Object? untrustedWorkspaces; // ExtensionUntrustedWorkspaceSupport
  final Map<String, bool>? agentsWindow; // { supported: boolean }
}

// ---- constants ------------------------------------------------------------

const String EXTENSIONS_AGENTS_WINDOW_MANAGEMENT =
    'extensions.experimental.agentsWindowManagement';
const String EXTENSIONS_AGENTS_WINDOW_AUTO_ENABLE =
    'extensions.experimental.agentsWindowAutoEnable';
const String MANAGE_EXTENSION_COMMAND_ID = '_extensions.manage';
const String EXTENSIONS_AGENTS_WINDOW_AUTO_ENABLE_EXTENSIONS =
    'extensions.experimental.agentsWindowAutoEnableExtensions';

/// 1:1: `export const ALL_EXTENSION_KINDS: readonly ExtensionKind[]`.
const List<ExtensionKind> ALL_EXTENSION_KINDS = <ExtensionKind>[
  'ui',
  'workspace',
  'web',
];

/// 1:1: `LimitedWorkspaceSupportType = 'limited'`.
typedef LimitedWorkspaceSupportType = String;

/// 1:1: `ExtensionUntrustedWorkspaceSupportType`.
/// TS `boolean | 'limited'` -> Object? carrier (bool | String).
typedef ExtensionUntrustedWorkspaceSupportType = Object;

/// 1:1: `ExtensionUntrustedWorkspaceSupport` union -> Object? carrier.
typedef ExtensionUntrustedWorkspaceSupport = Object;

/// 1:1: `ExtensionVirtualWorkspaceSupportType`.
typedef ExtensionVirtualWorkspaceSupportType = Object;

/// 1:1: `ExtensionVirtualWorkspaceSupport` union -> Object? carrier.
typedef ExtensionVirtualWorkspaceSupport = Object;

/// 1:1: `getWorkspaceSupportTypeMessage(supportType)`.
String? getWorkspaceSupportTypeMessage(Object? supportType) {
  if (supportType is Map && supportType['supported'] != true) {
    return supportType['description'] as String?;
  }
  return null;
}

/// 1:1: `export interface IExtensionIdentifier`.
class IExtensionIdentifier {
  IExtensionIdentifier({required this.id, this.uuid});
  final String id;
  final String? uuid;
}

/// 1:1: `export const EXTENSION_CATEGORIES`.
const List<String> EXTENSION_CATEGORIES = <String>[
  'AI',
  'Azure',
  'Chat',
  'Data Science',
  'Debuggers',
  'Extension Packs',
  'Education',
  'Formatters',
  'Keymaps',
  'Language Packs',
  'Linters',
  'Machine Learning',
  'Notebooks',
  'Programming Languages',
  'SCM Providers',
  'Snippets',
  'Testing',
  'Themes',
  'Visualization',
  'Other',
];

/// 1:1: `export interface IRelaxedExtensionManifest`.
class IRelaxedExtensionManifest {
  IRelaxedExtensionManifest({
    this.name = '',
    this.displayName,
    this.publisher = '',
    this.version = '',
    Map<String, String>? engines,
    this.description,
    this.main,
    this.type,
    this.browser,
    this.preview,
    this.l10n,
    this.icon,
    this.categories,
    this.keywords,
    this.activationEvents,
    this.extensionDependencies,
    this.extensionAffinity,
    this.extensionPack,
    this.extensionKind,
    this.contributes,
    this.repository,
    this.bugs,
    this.originalEnabledApiProposals,
    this.enabledApiProposals,
    this.api,
    this.scripts,
    this.capabilities,
  }) : engines = engines ?? <String, String>{};

  final String name;
  final String? displayName;
  final String publisher;
  final String version;
  final Map<String, String> engines; // { readonly vscode: string }
  final String? description;
  final String? main;
  final String? type;
  final String? browser;
  final bool? preview;
  final String? l10n;
  final String? icon;
  final List<String>? categories;
  final List<String>? keywords;
  final List<String>? activationEvents;
  final List<String>? extensionDependencies;
  final List<String>? extensionAffinity;
  final List<String>? extensionPack;
  final Object? extensionKind; // ExtensionKind | ExtensionKind[]
  final IExtensionContributions? contributes;
  final Map<String, String>? repository; // { url }
  final Map<String, String>? bugs; // { url }
  final List<String>? originalEnabledApiProposals;
  final List<String>? enabledApiProposals;
  final String? api;
  final Map<String, String>? scripts;
  final IExtensionCapabilities? capabilities;
}

/// 1:1: `export type IExtensionManifest = Readonly<IRelaxedExtensionManifest>`.
typedef IExtensionManifest = IRelaxedExtensionManifest;

/// 1:1: `export const enum ExtensionType` (System = 0, User = 1).
class ExtensionType {
  static const int System = 0;
  static const int User = 1;
}

/// 1:1: `export const enum TargetPlatform`.
class TargetPlatform {
  static const String WIN32_X64 = 'win32-x64';
  static const String WIN32_ARM64 = 'win32-arm64';
  static const String LINUX_X64 = 'linux-x64';
  static const String LINUX_ARM64 = 'linux-arm64';
  static const String LINUX_ARMHF = 'linux-armhf';
  static const String ALPINE_X64 = 'alpine-x64';
  static const String ALPINE_ARM64 = 'alpine-arm64';
  static const String DARWIN_X64 = 'darwin-x64';
  static const String DARWIN_ARM64 = 'darwin-arm64';
  static const String WEB = 'web';
  static const String UNIVERSAL = 'universal';
  static const String UNKNOWN = 'unknown';
  static const String UNDEFINED = 'undefined';
}

/// 1:1: `export interface IExtension`.
class IExtension {
  IExtension({
    required this.type,
    required this.isBuiltin,
    required this.identifier,
    required this.manifest,
    required this.location,
    required this.targetPlatform,
    this.publisherDisplayName,
    this.readmeUrl,
    this.changelogUrl,
    required this.isValid,
    required this.validations,
    required this.preRelease,
  });

  final int type;
  final bool isBuiltin;
  final IExtensionIdentifier identifier;
  final IExtensionManifest manifest;
  final uri.URI location;
  final String targetPlatform;
  final String? publisherDisplayName;
  final uri.URI? readmeUrl;
  final uri.URI? changelogUrl;
  final bool isValid;
  final List<List<Object>> validations; // [Severity, string][]
  final bool preRelease;
}

/// 1:1: `export class ExtensionIdentifier`.
/// `_lower` is public in TS (avoids mangling); exposed here as `lower`.
class ExtensionIdentifier {
  ExtensionIdentifier(String value)
      : value = value,
        lower = value.toLowerCase();

  final String value;
  final String lower;

  @override
  String toString() => value;

  /// 1:1: `ExtensionIdentifier.equals(a, b)`.
  static bool equals(Object? a, Object? b) {
    if (a == null) {
      return b == null;
    }
    if (b == null) {
      return false;
    }
    if (a is String || b is String) {
      final String aValue = a is String ? a : (a as ExtensionIdentifier).value;
      final String bValue = b is String ? b : (b as ExtensionIdentifier).value;
      return strings.equalsIgnoreCase(aValue, bValue);
    }
    return (a as ExtensionIdentifier).lower == (b as ExtensionIdentifier).lower;
  }

  /// 1:1: `ExtensionIdentifier.toKey(id)`.
  static String toKey(Object id) =>
      id is String ? id.toLowerCase() : (id as ExtensionIdentifier).lower;
}

/// 1:1: `export class ExtensionIdentifierSet`.
class ExtensionIdentifierSet {
  ExtensionIdentifierSet([Iterable<Object>? iterable]) {
    if (iterable != null) {
      for (final Object value in iterable) {
        add(value);
      }
    }
  }

  final Set<String> _set = <String>{};

  int get size => _set.length;

  void add(Object id) => _set.add(ExtensionIdentifier.toKey(id));

  bool delete(ExtensionIdentifier extensionId) =>
      _set.remove(ExtensionIdentifier.toKey(extensionId));

  bool has(Object id) => _set.contains(ExtensionIdentifier.toKey(id));
}

/// 1:1: `export class ExtensionIdentifierMap<T>`.
class ExtensionIdentifierMap<T> {
  final Map<String, T> _map = <String, T>{};

  void clear() => _map.clear();

  void delete(Object id) => _map.remove(ExtensionIdentifier.toKey(id));

  T? get(Object id) => _map[ExtensionIdentifier.toKey(id)];

  bool has(Object id) => _map.containsKey(ExtensionIdentifier.toKey(id));

  void set(Object id, T value) =>
      _map[ExtensionIdentifier.toKey(id)] = value;

  Iterable<T> values() => _map.values;

  void forEach(void Function(T value, String key, Map<String, T> map) cb) =>
      _map.forEach((String key, T value) => cb(value, key, _map));

  /// 1:1: `[Symbol.iterator](): IterableIterator<[string, T]>`.
  Map<String, T> get iterable => _map;
}

/// Carrier for the JS `Error` cause passed to [ExtensionError]: exposes the
/// `message` and `stack` fields that TS reads off `cause`.
abstract class ExtensionErrorCause {
  String? get message;
  String? get stack;
}

/// 1:1: `export class ExtensionError extends Error`.
/// Dart `Error` has no settable `message`/`stack`, so they are carried.
class ExtensionError extends Error {
  ExtensionError(
    ExtensionIdentifier extensionIdentifier,
    ExtensionErrorCause cause, [
    String? message,
  ])  : extension = extensionIdentifier,
        message = _buildMessage(extensionIdentifier, cause, message),
        stack = cause.stack {
    name = 'ExtensionError';
  }

  final ExtensionIdentifier extension;
  final String message;
  final String? stack;
  late final String name;

  @override
  String toString() => '$name: $message';

  static String _buildMessage(
    ExtensionIdentifier id,
    ExtensionErrorCause cause,
    String? message,
  ) {
    final String? causeMessage = cause.message;
    final String? detail = (message != null &&
            causeMessage != null &&
            causeMessage.isNotEmpty)
        ? '$message: $causeMessage'
        : (message ?? causeMessage);
    return 'Error in extension ${ExtensionIdentifier.toKey(id)}: $detail';
  }
}

/// 1:1: `export interface IRelaxedExtensionDescription`.
class IRelaxedExtensionDescription extends IRelaxedExtensionManifest {
  IRelaxedExtensionDescription({
    required String name,
    String? displayName,
    required String publisher,
    required String version,
    Map<String, String>? engines,
    String? description,
    String? main,
    String? type,
    String? browser,
    bool? preview,
    String? l10n,
    String? icon,
    List<String>? categories,
    List<String>? keywords,
    List<String>? activationEvents,
    List<String>? extensionDependencies,
    List<String>? extensionAffinity,
    List<String>? extensionPack,
    Object? extensionKind,
    IExtensionContributions? contributes,
    Map<String, String>? repository,
    Map<String, String>? bugs,
    List<String>? originalEnabledApiProposals,
    List<String>? enabledApiProposals,
    String? api,
    Map<String, String>? scripts,
    IExtensionCapabilities? capabilities,
    this.id,
    required this.identifier,
    this.uuid,
    this.publisherDisplayName,
    required this.targetPlatform,
    required this.isBuiltin,
    required this.isUserBuiltin,
    required this.isUnderDevelopment,
    required this.extensionLocation,
    required this.preRelease,
  }) : super(
          name: name,
          displayName: displayName,
          publisher: publisher,
          version: version,
          engines: engines,
          description: description,
          main: main,
          type: type,
          browser: browser,
          preview: preview,
          l10n: l10n,
          icon: icon,
          categories: categories,
          keywords: keywords,
          activationEvents: activationEvents,
          extensionDependencies: extensionDependencies,
          extensionAffinity: extensionAffinity,
          extensionPack: extensionPack,
          extensionKind: extensionKind,
          contributes: contributes,
          repository: repository,
          bugs: bugs,
          originalEnabledApiProposals: originalEnabledApiProposals,
          enabledApiProposals: enabledApiProposals,
          api: api,
          scripts: scripts,
          capabilities: capabilities,
        );

  final String? id;
  final ExtensionIdentifier identifier;
  final String? uuid;
  final String? publisherDisplayName;
  final String targetPlatform;
  final bool isBuiltin;
  final bool isUserBuiltin;
  final bool isUnderDevelopment;
  final uri.URI extensionLocation;
  final bool preRelease;
}

/// 1:1: `export type IExtensionDescription = Readonly<IRelaxedExtensionDescription>`.
typedef IExtensionDescription = IRelaxedExtensionDescription;

/// 1:1: `isApplicationScopedExtension(manifest)`.
bool isApplicationScopedExtension(IExtensionManifest manifest) =>
    isLanguagePackExtension(manifest);

/// 1:1: `isLanguagePackExtension(manifest)`.
bool isLanguagePackExtension(IExtensionManifest manifest) {
  final IExtensionContributions? c = manifest.contributes;
  final List<ILocalizationContribution>? l = c?.localizations;
  return l != null && l.isNotEmpty;
}

/// 1:1: `isAuthenticationProviderExtension(manifest)`.
bool isAuthenticationProviderExtension(IExtensionManifest manifest) {
  final IExtensionContributions? c = manifest.contributes;
  final List<IAuthenticationContribution>? a = c?.authentication;
  return a != null && a.isNotEmpty;
}

/// 1:1: `isResolverExtension(manifest, remoteAuthority)`.
bool isResolverExtension(
    IExtensionManifest manifest, String? remoteAuthority) {
  if (remoteAuthority != null && remoteAuthority.isNotEmpty) {
    final String activationEvent =
        'onResolveRemoteAuthority:${remoteHosts.getRemoteName(remoteAuthority)}';
    return manifest.activationEvents?.contains(activationEvent) ?? false;
  }
  return false;
}

/// 1:1: `parseEnabledApiProposalNames(enabledApiProposals)`.
List<String> parseEnabledApiProposalNames(List<String> enabledApiProposals) =>
    enabledApiProposals
        .map((String proposal) => proposal.split('@')[0])
        .toList();

/// 1:1: `export const IBuiltinExtensionsScannerService`.
final ServiceIdentifier<IBuiltinExtensionsScannerServiceType>
    IBuiltinExtensionsScannerService =
    createDecorator<IBuiltinExtensionsScannerServiceType>(
        'IBuiltinExtensionsScannerService');

/// 1:1: `export interface IBuiltinExtensionsScannerService`.
abstract class IBuiltinExtensionsScannerServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Future<List<IExtension>> scanBuiltinExtensions();
}
