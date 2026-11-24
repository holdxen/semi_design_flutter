// 1:1 port of vscode/src/vs/platform/window/common/window.ts
// Runtime helpers are translated verbatim; type-only surfaces are carried as
// Dart classes. URLSearchParams uses a small deterministic carrier matching
// the browser API used by the source.
import 'dart:math' as math;

import '../../../base/common/buffer.dart' show VSBuffer;
import '../../../base/common/network.dart' show AGENTS_AUTHORITY;
import '../../../base/common/performance.dart' show PerformanceMark;
import '../../../base/common/platform.dart' as platform;
import '../../../base/common/uri.dart' show URI, UriChange, UriComponents;
import '../../../base/parts/sandbox/common/sandboxTypes.dart'
    show ISandboxConfiguration;
import '../../configuration/common/configuration.dart'
    show IConfigurationServiceType;
import '../../environment/common/argv.dart' show NativeParsedArgs;
import '../../files/common/files.dart' show FileType;
import '../../log/common/log.dart' show ILoggerResource, LogLevel;
import '../../policy/common/policy.dart'
    show PolicyDefinition, PolicyValue;
import '../../theme/common/themeService.dart' show IPartsSplash;
import '../../userDataProfile/common/userDataProfile.dart'
    show IUserDataProfile;
import '../../workspace/common/workspace.dart'
    show
        IAnyWorkspaceIdentifier,
        ISingleFolderWorkspaceIdentifier,
        IWorkspaceIdentifier;
import '../../editor/common/editor.dart' show IEditorOptions;

/// TS `IConfigurationService` interface (the bare const name is reserved).
typedef IConfigurationService = IConfigurationServiceType;

// Platform seams: source reads imported bindings directly; Dart keeps
// replaceable getters so truth scenarios can drive the same control flow.
bool Function() windowIsWeb = () => platform.isWeb;
bool Function() windowIsMacintosh = () => platform.isMacintosh;
bool Function() windowIsNative = () => platform.isNative;
bool Function(String version) windowIsTahoeOrNewer = _defaultIsTahoeOrNewer;

bool _defaultIsTahoeOrNewer(String version) =>
    (double.tryParse(version.split('.').first) ?? 0) >= 25;

/// 1:1: `export const WindowMinimumSize`.
class WindowMinimumSize {
  static const int WIDTH = 400;
  static const int WIDTH_WITH_VERTICAL_PANEL = 600;
  static const int HEIGHT = 270;
}

/// 1:1: `export interface IPoint`.
class IPoint {
  const IPoint({required this.x, required this.y});

  final num x;
  final num y;

  Map<String, num> toMap() => <String, num>{'x': x, 'y': y};
}

/// 1:1: `export interface IRectangle extends IPoint`.
class IRectangle extends IPoint {
  const IRectangle({
    required super.x,
    required super.y,
    required this.width,
    required this.height,
  });

  final num width;
  final num height;

  @override
  Map<String, num> toMap() => <String, num>{
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
}

/// 1:1: `export interface IBaseOpenWindowsOptions`.
class IBaseOpenWindowsOptions {
  IBaseOpenWindowsOptions({
    this.forceReuseWindow,
    this.remoteAuthority,
    this.forceProfile,
    this.forceTempProfile,
  });

  final bool? forceReuseWindow;
  final String? remoteAuthority;
  final String? forceProfile;
  final bool? forceTempProfile;
}

/// 1:1: `export interface IOpenWindowOptions`.
class IOpenWindowOptions extends IBaseOpenWindowsOptions {
  IOpenWindowOptions({
    super.forceReuseWindow,
    super.remoteAuthority,
    super.forceProfile,
    super.forceTempProfile,
    this.forceNewWindow,
    this.preferNewWindow,
    this.noRecentEntry,
    this.addMode,
    this.removeMode,
    this.diffMode,
    this.mergeMode,
    this.gotoLineMode,
    this.waitMarkerFileURI,
    this.chatSessionToOpen,
  });

  final bool? forceNewWindow;
  final bool? preferNewWindow;
  final bool? noRecentEntry;
  final bool? addMode;
  final bool? removeMode;
  final bool? diffMode;
  final bool? mergeMode;
  final bool? gotoLineMode;
  final URI? waitMarkerFileURI;
  final URI? chatSessionToOpen;
}

/// 1:1: `export interface IAddRemoveFoldersRequest`.
class IAddRemoveFoldersRequest {
  IAddRemoveFoldersRequest({
    required this.foldersToAdd,
    required this.foldersToRemove,
  });

  final List<UriComponents> foldersToAdd;
  final List<UriComponents> foldersToRemove;
}

/// 1:1: `interface IOpenedWindow`.
class IOpenedWindow {
  IOpenedWindow({
    required this.id,
    required this.title,
    this.filename,
  });

  final int id;
  final String title;
  final String? filename;
}

/// 1:1: `export interface IOpenedMainWindow`.
class IOpenedMainWindow extends IOpenedWindow {
  IOpenedMainWindow({
    required super.id,
    required super.title,
    super.filename,
    this.workspace,
    required this.dirty,
    this.iconPath,
  });

  final IAnyWorkspaceIdentifier? workspace;
  final bool dirty;
  final URI? iconPath;
}

/// 1:1: `export interface IOpenedAuxiliaryWindow`.
class IOpenedAuxiliaryWindow extends IOpenedWindow {
  IOpenedAuxiliaryWindow({
    required super.id,
    required super.title,
    super.filename,
    required this.parentId,
  });

  final int parentId;
}

/// 1:1: `export function isOpenedAuxiliaryWindow(candidate)`.
bool isOpenedAuxiliaryWindow(Object candidate) {
  final dynamic c = candidate;
  return c.parentId is num;
}

/// 1:1: `export interface IOpenEmptyWindowOptions`.
class IOpenEmptyWindowOptions extends IBaseOpenWindowsOptions {}

/// 1:1: `export interface IAgentsWindowDraft`.
class IAgentsWindowDraft {
  IAgentsWindowDraft({
    required this.inputText,
    required this.attachments,
  });

  final String inputText;
  final String attachments;

  Map<String, Object?> toMap() => <String, Object?>{
        'inputText': inputText,
        'attachments': attachments,
      };
}

/// 1:1: `export function isAgentsWindowDraft(value)`.
bool isAgentsWindowDraft(Object? value) {
  final dynamic draft = value;
  return draft != null &&
      draft.inputText is String &&
      draft.attachments is String;
}

/// 1:1: `export interface IAgentsWindowNewSessionLink`.
class IAgentsWindowNewSessionLink {
  IAgentsWindowNewSessionLink({
    this.workspaceUri,
    required this.draft,
  });

  final URI? workspaceUri;
  final IAgentsWindowDraft draft;

  Map<String, Object?> toMap() => <String, Object?>{
        'workspaceUri': workspaceUri?.toString(true),
        'draft': draft.toMap(),
      };
}

class _UrlSearchParams {
  _UrlSearchParams(String query) {
    if (query.isEmpty) return;
    for (final String part in query.split('&')) {
      if (part.isEmpty) continue;
      final int eq = part.indexOf('=');
      final String key = eq < 0 ? part : part.substring(0, eq);
      final String value = eq < 0 ? '' : part.substring(eq + 1);
      _entries.add(MapEntry<String, String>(
        _decode(key),
        _decode(value),
      ));
    }
  }

  _UrlSearchParams.fromMap(Map<String, String> values) {
    values.forEach((String key, String value) {
      _entries.add(MapEntry<String, String>(key, value));
    });
  }

  final List<MapEntry<String, String>> _entries = <MapEntry<String, String>>[];

  static String _decode(String value) => Uri.decodeComponent(
        value.replaceAll('+', ' '),
      );

  static String _encode(String value) => Uri.encodeComponent(value)
      .replaceAll('%20', '+')
      .replaceAll('*', '%2A');

  String? get(String key) {
    for (final MapEntry<String, String> entry in _entries) {
      if (entry.key == key) return entry.value;
    }
    return null;
  }

  void delete(String key) => _entries.removeWhere((MapEntry<String, String> e) => e.key == key);

  @override
  String toString() => _entries
      .map((MapEntry<String, String> e) => '${_encode(e.key)}=${_encode(e.value)}')
      .join('&');
}

/// 1:1: `export function parseExternalAgentsWindowNewSessionLinkUri(uri, productUrlProtocol)`.
IAgentsWindowNewSessionLink? parseExternalAgentsWindowNewSessionLinkUri(
  Object uri,
  String productUrlProtocol,
) {
  final URI parsed = uri is String ? URI.parse(uri) : uri as URI;
  if (parsed.scheme != productUrlProtocol ||
      parsed.authority != AGENTS_AUTHORITY ||
      parsed.path != '/new') {
    return null;
  }

  final _UrlSearchParams params = _UrlSearchParams(parsed.query);
  final String? workspace = params.get('workspace');
  final String? prompt = params.get('prompt');
  if (prompt == null || prompt.isEmpty || workspace == '') {
    return null;
  }

  try {
    return IAgentsWindowNewSessionLink(
      workspaceUri:
          workspace == null ? null : URI.parse(workspace, true),
      draft: IAgentsWindowDraft(inputText: prompt, attachments: '[]'),
    );
  } catch (_) {
    return null;
  }
}

/// 1:1: `export const CHAT_SESSION_LINK_QUERY_PARAM`.
const String CHAT_SESSION_LINK_QUERY_PARAM = 'session';

/// 1:1: `export const COPILOT_CLI_SESSION_LINK_QUERY_PARAM`.
const String COPILOT_CLI_SESSION_LINK_QUERY_PARAM = 'copilotCliSession';

/// 1:1: `export type ChatSessionToOpen`.
class ChatSessionToOpen {
  ChatSessionToOpen._({this.kind, this.resource, this.sessionId});

  factory ChatSessionToOpen.resource(String resource) => ChatSessionToOpen._(
        kind: 'resource',
        resource: resource,
      );

  factory ChatSessionToOpen.copilotCli(String sessionId) =>
      ChatSessionToOpen._(kind: 'copilotCli', sessionId: sessionId);

  final String? kind;
  final String? resource;
  final String? sessionId;

  Map<String, Object?> toMap() => <String, Object?>{
        'kind': kind,
        if (resource != null) 'resource': resource,
        if (sessionId != null) 'sessionId': sessionId,
      };
}

/// 1:1: `export function isValidCopilotCliSessionId(sessionId)`.
bool isValidCopilotCliSessionId(String sessionId) =>
    RegExp(r'^[A-Za-z0-9_-]{1,256}$').hasMatch(sessionId);

class IExtractChatSessionResult {
  IExtractChatSessionResult({
    required this.uri,
    required this.chatSessionToOpen,
  });

  final URI uri;
  final ChatSessionToOpen? chatSessionToOpen;

  Map<String, Object?> toMap([bool skipEncoding = true]) => <String, Object?>{
        'uri': uri.toString(skipEncoding),
        if (chatSessionToOpen != null)
          'chatSessionToOpen': chatSessionToOpen!.toMap(),
      };
}

/// 1:1: `export function extractChatSessionToOpen(uri)`.
IExtractChatSessionResult extractChatSessionToOpen(URI uri) {
  final _UrlSearchParams params = _UrlSearchParams(uri.query);
  final String? resource = params.get(CHAT_SESSION_LINK_QUERY_PARAM);
  final String? copilotCliSessionId =
      params.get(COPILOT_CLI_SESSION_LINK_QUERY_PARAM);
  if (resource == null && copilotCliSessionId == null) {
    return IExtractChatSessionResult(uri: uri, chatSessionToOpen: null);
  }

  params.delete(CHAT_SESSION_LINK_QUERY_PARAM);
  params.delete(COPILOT_CLI_SESSION_LINK_QUERY_PARAM);
  final URI uriWithoutChatSession =
      uri.withChanges(UriChange(query: params.toString()));

  if (resource != null && resource.isNotEmpty) {
    return IExtractChatSessionResult(
      uri: uriWithoutChatSession,
      chatSessionToOpen: ChatSessionToOpen.resource(resource),
    );
  }

  if (copilotCliSessionId != null &&
      copilotCliSessionId.isNotEmpty &&
      isValidCopilotCliSessionId(copilotCliSessionId)) {
    return IExtractChatSessionResult(
      uri: uriWithoutChatSession,
      chatSessionToOpen: ChatSessionToOpen.copilotCli(copilotCliSessionId),
    );
  }

  return IExtractChatSessionResult(
    uri: uriWithoutChatSession,
    chatSessionToOpen: null,
  );
}

/// 1:1: `export const enum AgentsWindowOpenSource`.
class AgentsWindowOpenSource {
  static const String CommandPalette = 'commandPalette';
  static const String KeyboardShortcut = 'keyboardShortcut';
  static const String TitleBar = 'titleBar';
  static const String ChatTitleBar = 'chatTitleBar';
  static const String ChatViewTitle = 'chatViewTitle';
  static const String CurrentChatHandoff = 'currentChatHandoff';
  static const String EmptyWorkspaceCurrentChatHandoff =
      'emptyWorkspaceCurrentChatHandoff';
  static const String ParallelWorkEmptyChatHandoff =
      'parallelWorkEmptyChatHandoff';
  static const String ContinueInAgentsWindow = 'continueInAgentsWindow';
  static const String ParallelWorkSameWindow = 'parallelWorkSameWindow';
  static const String ParallelWorkAllWindows = 'parallelWorkAllWindows';
  static const String WelcomeTryOut = 'welcomeTryOut';
  static const String CommandLine = 'commandLine';
  static const String Link = 'link';
  static const String AgentsLauncher = 'agentsLauncher';
  static const String Unknown = 'unknown';
}

/// 1:1: `export const AGENTS_LAUNCHER_IPC_CHANNEL`.
const String AGENTS_LAUNCHER_IPC_CHANNEL = 'vscode:showAgentsLauncher';

/// 1:1: `export interface IAgentsLauncherOptions`.
class IAgentsLauncherOptions {
  IAgentsLauncherOptions({this.workspace});

  final String? workspace;
}

/// 1:1: `export function isAgentsWindowOpenSource(value)`.
bool isAgentsWindowOpenSource(Object? value) => const <String>{
      AgentsWindowOpenSource.CommandPalette,
      AgentsWindowOpenSource.KeyboardShortcut,
      AgentsWindowOpenSource.TitleBar,
      AgentsWindowOpenSource.ChatTitleBar,
      AgentsWindowOpenSource.ChatViewTitle,
      AgentsWindowOpenSource.CurrentChatHandoff,
      AgentsWindowOpenSource.EmptyWorkspaceCurrentChatHandoff,
      AgentsWindowOpenSource.ParallelWorkEmptyChatHandoff,
      AgentsWindowOpenSource.ContinueInAgentsWindow,
      AgentsWindowOpenSource.ParallelWorkSameWindow,
      AgentsWindowOpenSource.ParallelWorkAllWindows,
      AgentsWindowOpenSource.WelcomeTryOut,
      AgentsWindowOpenSource.CommandLine,
      AgentsWindowOpenSource.Link,
      AgentsWindowOpenSource.AgentsLauncher,
      AgentsWindowOpenSource.Unknown,
    }.contains(value);

/// 1:1: `export type IWindowOpenable`.
typedef IWindowOpenable = Object;

/// 1:1: `export interface IBaseWindowOpenable`.
class IBaseWindowOpenable {
  IBaseWindowOpenable({this.label});

  String? label;
}

/// 1:1: `export interface IWorkspaceToOpen`.
class IWorkspaceToOpen extends IBaseWindowOpenable {
  IWorkspaceToOpen({super.label, required this.workspaceUri});

  final URI workspaceUri;
}

/// 1:1: `export interface IFolderToOpen`.
class IFolderToOpen extends IBaseWindowOpenable {
  IFolderToOpen({super.label, required this.folderUri});

  final URI folderUri;
}

/// 1:1: `export interface IFileToOpen`.
class IFileToOpen extends IBaseWindowOpenable {
  IFileToOpen({super.label, required this.fileUri});

  final URI fileUri;
}

/// 1:1: `export function isWorkspaceToOpen(uriToOpen)`.
bool isWorkspaceToOpen(IWindowOpenable uriToOpen) {
  final dynamic candidate = uriToOpen;
  return candidate.workspaceUri != null;
}

/// 1:1: `export function isFolderToOpen(uriToOpen)`.
bool isFolderToOpen(IWindowOpenable uriToOpen) {
  final dynamic candidate = uriToOpen;
  return candidate.folderUri != null;
}

/// 1:1: `export function isFileToOpen(uriToOpen)`.
bool isFileToOpen(IWindowOpenable uriToOpen) {
  final dynamic candidate = uriToOpen;
  return candidate.fileUri != null;
}

/// 1:1: `export const enum MenuSettings`.
class MenuSettings {
  static const String MenuStyle = 'window.menuStyle';
  static const String MenuBarVisibility = 'window.menuBarVisibility';
}

/// 1:1: `export const enum MenuStyleConfiguration`.
class MenuStyleConfiguration {
  static const String CUSTOM = 'custom';
  static const String NATIVE = 'native';
  static const String INHERIT = 'inherit';
}

Map<String, Object?>? _windowConfig(IConfigurationService service) {
  final Object? value = service.getValue$1('window');
  return value is Map ? value.cast<String, Object?>() : null;
}

Object? _configValue(IConfigurationService service, String key) =>
    service.getValue$1(key);

/// 1:1: `export function hasNativeContextMenu(configurationService, titleBarStyle?)`.
bool hasNativeContextMenu(
  IConfigurationService configurationService, [
  String? titleBarStyle,
]) {
  if (windowIsWeb()) {
    return false;
  }

  final bool nativeTitle =
      hasNativeTitlebar(configurationService, titleBarStyle);
  final Map<String, Object?>? windowConfigurations =
      _windowConfig(configurationService);

  if (windowConfigurations?['menuStyle'] == MenuStyleConfiguration.NATIVE) {
    if (!windowIsMacintosh() && !nativeTitle) {
      return false;
    }
    return true;
  }

  if (windowConfigurations?['menuStyle'] == MenuStyleConfiguration.CUSTOM) {
    return false;
  }

  return nativeTitle;
}

/// 1:1: `export function hasNativeMenu(configurationService, titleBarStyle?)`.
bool hasNativeMenu(
  IConfigurationService configurationService, [
  String? titleBarStyle,
]) {
  if (windowIsWeb()) {
    return false;
  }
  if (windowIsMacintosh()) {
    return true;
  }
  return hasNativeContextMenu(configurationService, titleBarStyle);
}

/// 1:1: `export type MenuBarVisibility`.
typedef MenuBarVisibility = String;

/// 1:1: `export function getMenuBarVisibility(configurationService)`.
String? getMenuBarVisibility(IConfigurationService configurationService) {
  final Object? raw =
      _configValue(configurationService, MenuSettings.MenuBarVisibility);
  final String? menuBarVisibility = raw is String ? raw : null;

  if (menuBarVisibility == 'default' ||
      (menuBarVisibility == 'compact' &&
          hasNativeMenu(configurationService)) ||
      (windowIsMacintosh() && windowIsNative())) {
    return 'classic';
  }
  return menuBarVisibility;
}

/// 1:1: `export interface IWindowsConfiguration`.
class IWindowsConfiguration {
  IWindowsConfiguration({required this.window});

  final IWindowSettings window;
}

/// 1:1: `export interface IWindowSettings`.
class IWindowSettings {
  IWindowSettings({
    required this.openFilesInNewWindow,
    required this.openFoldersInNewWindow,
    required this.openWithoutArgumentsInNewWindow,
    required this.restoreWindows,
    required this.restoreFullscreen,
    required this.zoomLevel,
    required this.titleBarStyle,
    required this.controlsStyle,
    required this.menuStyle,
    required this.autoDetectHighContrast,
    required this.autoDetectColorScheme,
    required this.menuBarVisibility,
    required this.newWindowDimensions,
    required this.nativeTabs,
    required this.nativeFullScreen,
    required this.enableMenuBarMnemonics,
    required this.closeWhenEmpty,
    required this.clickThroughInactive,
    required this.newWindowProfile,
    required this.density,
    required this.border,
  });

  final String openFilesInNewWindow;
  final String openFoldersInNewWindow;
  final String openWithoutArgumentsInNewWindow;
  final String restoreWindows;
  final bool restoreFullscreen;
  final num zoomLevel;
  final String titleBarStyle;
  final String controlsStyle;
  final String menuStyle;
  final bool autoDetectHighContrast;
  final bool autoDetectColorScheme;
  final String menuBarVisibility;
  final String newWindowDimensions;
  final bool nativeTabs;
  final bool nativeFullScreen;
  final bool enableMenuBarMnemonics;
  final bool closeWhenEmpty;
  final bool clickThroughInactive;
  final String newWindowProfile;
  final IDensitySettings density;
  final String border;
}

/// 1:1: `export interface IDensitySettings`.
class IDensitySettings {
  IDensitySettings({required this.editorTabHeight, required this.layout});

  final String editorTabHeight;
  final String layout;
}

/// 1:1: `export const enum TitleBarSetting`.
class TitleBarSetting {
  static const String TITLE_BAR_STYLE = 'window.titleBarStyle';
  static const String CUSTOM_TITLE_BAR_VISIBILITY =
      'window.customTitleBarVisibility';
}

/// 1:1: `export const enum TitlebarStyle`.
class TitlebarStyle {
  static const String NATIVE = 'native';
  static const String CUSTOM = 'custom';
}

/// 1:1: `export const enum WindowControlsStyle`.
class WindowControlsStyle {
  static const String NATIVE = 'native';
  static const String CUSTOM = 'custom';
  static const String HIDDEN = 'hidden';
}

/// 1:1: `export const enum CustomTitleBarVisibility`.
class CustomTitleBarVisibility {
  static const String AUTO = 'auto';
  static const String WINDOWED = 'windowed';
  static const String NEVER = 'never';
}

/// 1:1: `export function hasCustomTitlebar(configurationService, titleBarStyle?)`.
bool hasCustomTitlebar(
  IConfigurationService configurationService, [
  String? titleBarStyle,
]) =>
    true;

/// 1:1: `export function hasNativeTitlebar(configurationService, titleBarStyle?)`.
bool hasNativeTitlebar(
  IConfigurationService configurationService, [
  String? titleBarStyle,
]) {
  final String? resolved =
      titleBarStyle ?? getTitleBarStyle(configurationService);
  return resolved == TitlebarStyle.NATIVE;
}

/// 1:1: `export function getTitleBarStyle(configurationService)`.
String getTitleBarStyle(IConfigurationService configurationService) {
  if (windowIsWeb()) {
    return TitlebarStyle.CUSTOM;
  }

  final Map<String, Object?>? configuration =
      _windowConfig(configurationService);
  if (configuration != null) {
    final bool useNativeTabs = windowIsMacintosh() &&
        configuration['nativeTabs'] == true;
    if (useNativeTabs) {
      return TitlebarStyle.NATIVE;
    }

    final bool useSimpleFullScreen = windowIsMacintosh() &&
        configuration['nativeFullScreen'] == false;
    if (useSimpleFullScreen) {
      return TitlebarStyle.NATIVE;
    }

    final Object? styleRaw = configuration['titleBarStyle'];
    final String? style = styleRaw is String ? styleRaw : null;
    if (style == TitlebarStyle.NATIVE || style == TitlebarStyle.CUSTOM) {
      return style!;
    }
  }

  return TitlebarStyle.CUSTOM;
}

/// 1:1: `export function getWindowControlsStyle(configurationService)`.
String getWindowControlsStyle(IConfigurationService configurationService) {
  if (windowIsWeb() ||
      windowIsMacintosh() ||
      getTitleBarStyle(configurationService) == TitlebarStyle.NATIVE) {
    return WindowControlsStyle.NATIVE;
  }

  final Map<String, Object?>? configuration =
      _windowConfig(configurationService);
  final Object? styleRaw = configuration?['controlsStyle'];
  final String? style = styleRaw is String ? styleRaw : null;
  if (style == WindowControlsStyle.CUSTOM ||
      style == WindowControlsStyle.HIDDEN) {
    return style!;
  }

  return WindowControlsStyle.NATIVE;
}

/// 1:1: `export const DEFAULT_CUSTOM_TITLEBAR_HEIGHT`.
const int DEFAULT_CUSTOM_TITLEBAR_HEIGHT = 35;

/// 1:1: `export function getMacOSWindowControlsPosition(height, osVersion, horizontalInset?)`.
IPoint? getMacOSWindowControlsPosition(
  num height,
  String osVersion, [
  num? horizontalInset,
]) {
  final int buttonHeight =
      windowIsTahoeOrNewer(osVersion) ? 14 : 16;
  final int offset = ((height - buttonHeight) / 2).floor();
  if (offset == 0 && horizontalInset == null) {
    return null;
  }
  return IPoint(x: horizontalInset ?? offset + 1, y: offset);
}

/// 1:1: `export function useWindowControlsOverlay(configurationService)`.
bool useWindowControlsOverlay(IConfigurationService configurationService) {
  if (windowIsWeb()) {
    return false;
  }
  if (hasNativeTitlebar(configurationService)) {
    return false;
  }
  if (!windowIsMacintosh()) {
    final String setting = getWindowControlsStyle(configurationService);
    if (setting == WindowControlsStyle.CUSTOM ||
        setting == WindowControlsStyle.HIDDEN) {
      return false;
    }
  }
  return true;
}

/// 1:1: `export function useNativeFullScreen(configurationService)`.
bool useNativeFullScreen(IConfigurationService configurationService) {
  final Map<String, Object?>? windowConfig =
      _windowConfig(configurationService);
  if (windowConfig == null ||
      windowConfig['nativeFullScreen'] is! bool) {
    return true;
  }
  if (windowConfig['nativeTabs'] == true) {
    return true;
  }
  return windowConfig['nativeFullScreen'] != false;
}

/// 1:1: `export interface IPath<T = IEditorOptions> extends IPathData<T>`.
class IPath<T extends Object> extends IPathData<T> {
  IPath({
    super.fileUri,
    super.options,
    super.exists,
    super.type,
    super.openOnlyIfExists,
    this.uri,
  });

  URI? uri;
}

/// 1:1: `export interface IPathData<T = IEditorOptions>`.
class IPathData<T extends Object> {
  IPathData({
    this.fileUri,
    this.options,
    this.exists,
    this.type,
    this.openOnlyIfExists,
  });

  UriComponents? fileUri;
  T? options;
  bool? exists;
  FileType? type;
  bool? openOnlyIfExists;
}

/// 1:1: `export interface IPathsToWaitFor extends IPathsToWaitForData`.
class IPathsToWaitFor extends IPathsToWaitForData {
  IPathsToWaitFor({
    required super.paths,
    required super.waitMarkerFileUri,
    this.resolvedWaitMarkerFileUri,
  });

  /// TS narrows `waitMarkerFileUri` from `UriComponents` to `URI`; Dart keeps
  /// the narrowed value in a separate carrier because nominal types differ.
  URI? resolvedWaitMarkerFileUri;
}

/// 1:1: `interface IPathsToWaitForData`.
class IPathsToWaitForData {
  IPathsToWaitForData({
    required this.paths,
    required this.waitMarkerFileUri,
  });

  final List<IPathData<IEditorOptions>> paths;
  final UriComponents waitMarkerFileUri;
}

/// 1:1: `export interface IOpenFileRequest`.
class IOpenFileRequest {
  IOpenFileRequest({
    this.filesToOpenOrCreate,
    this.filesToDiff,
    this.filesToMerge,
  });

  final List<IPathData<IEditorOptions>>? filesToOpenOrCreate;
  final List<IPathData<IEditorOptions>>? filesToDiff;
  final List<IPathData<IEditorOptions>>? filesToMerge;
}

/// 1:1: `export interface INativeOpenFileRequest`.
class INativeOpenFileRequest extends IOpenFileRequest {
  INativeOpenFileRequest({
    super.filesToOpenOrCreate,
    super.filesToDiff,
    super.filesToMerge,
    this.termProgram,
    this.filesToWait,
  });

  final String? termProgram;
  final IPathsToWaitForData? filesToWait;
}

/// 1:1: `export interface INativeRunActionInWindowRequest`.
class INativeRunActionInWindowRequest {
  INativeRunActionInWindowRequest({
    required this.id,
    required this.from,
    this.args,
  });

  final String id;
  final String from;
  final List<Object?>? args;
}

/// 1:1: `export interface INativeRunKeybindingInWindowRequest`.
class INativeRunKeybindingInWindowRequest {
  INativeRunKeybindingInWindowRequest({required this.userSettingsLabel});

  final String userSettingsLabel;
}

/// 1:1: `export interface IColorScheme`.
class IColorScheme {
  IColorScheme({required this.dark, required this.highContrast});

  final bool dark;
  final bool highContrast;
}

/// 1:1: `export interface IWindowConfiguration`.
class IWindowConfiguration {
  IWindowConfiguration({
    this.remoteAuthority,
    this.filesToOpenOrCreate,
    this.filesToDiff,
    this.filesToMerge,
  });

  String? remoteAuthority;
  List<IPath<IEditorOptions>>? filesToOpenOrCreate;
  List<IPath<IEditorOptions>>? filesToDiff;
  List<IPath<IEditorOptions>>? filesToMerge;
}

/// 1:1: `export interface IOSConfiguration`.
class IOSConfiguration {
  IOSConfiguration({
    required this.release,
    required this.hostname,
    required this.arch,
  });

  final String release;
  final String hostname;
  final String arch;
}

/// 1:1: `export interface IWindowFolderLocation`.
class IWindowFolderLocation {
  IWindowFolderLocation({required this.uri, required this.label, required this.providerId});

  final String uri;
  final String label;
  final String providerId;
}

/// 1:1: `export interface INativeWindowConfiguration`.
class INativeWindowConfiguration extends IWindowConfiguration {
  INativeWindowConfiguration({
    super.remoteAuthority,
    super.filesToOpenOrCreate,
    super.filesToDiff,
    super.filesToMerge,
    required this.mainPid,
    this.handle,
    required this.machineId,
    required this.sqmId,
    required this.devDeviceId,
    required this.isPortable,
    required this.execPath,
    this.backupPath,
    required this.profiles,
    required this.homeDir,
    required this.tmpDir,
    required this.userDataDir,
    this.partsSplash,
    this.workspace,
    this.folderLocation,
    this.folderLocationMissing,
    this.isInitialStartup,
    required this.logLevel,
    required this.loggers,
    this.fullscreen,
    this.maximized,
    this.accessibilitySupport,
    required this.colorScheme,
    this.autoDetectHighContrast,
    this.autoDetectColorScheme,
    this.isCustomZoomLevel,
    required this.perfMarks,
    this.filesToWait,
    required this.os,
    this.policiesData,
    this.isSessionsWindow,
  });

  int mainPid;
  VSBuffer? handle;
  String machineId;
  String sqmId;
  String devDeviceId;
  bool isPortable;
  String execPath;
  String? backupPath;
  Map<String, Object?> profiles;
  String homeDir;
  String tmpDir;
  String userDataDir;
  IPartsSplash? partsSplash;
  IWorkspaceIdentifier? workspace;
  ISingleFolderWorkspaceIdentifier? singleFolderWorkspace;
  IWindowFolderLocation? folderLocation;
  Map<String, Object?>? folderLocationMissing;
  bool? isInitialStartup;
  LogLevel logLevel;
  List<ILoggerResource> loggers;
  bool? fullscreen;
  bool? maximized;
  bool? accessibilitySupport;
  IColorScheme colorScheme;
  bool? autoDetectHighContrast;
  bool? autoDetectColorScheme;
  bool? isCustomZoomLevel;
  List<PerformanceMark> perfMarks;
  IPathsToWaitFor? filesToWait;
  IOSConfiguration os;
  Map<String, Map<String, Object?>>? policiesData;
  bool? isSessionsWindow;
}

/// 1:1: `export function zoomLevelToZoomFactor(zoomLevel = 0)`.
num zoomLevelToZoomFactor([num zoomLevel = 0]) => math.pow(1.2, zoomLevel);

/// 1:1: `export const DEFAULT_EMPTY_WINDOW_SIZE`.
const Map<String, int> DEFAULT_EMPTY_WINDOW_SIZE = <String, int>{
  'width': 1200,
  'height': 800,
};

/// 1:1: `export const DEFAULT_WORKSPACE_WINDOW_SIZE`.
const Map<String, int> DEFAULT_WORKSPACE_WINDOW_SIZE = <String, int>{
  'width': 1440,
  'height': 900,
};

/// 1:1: `export const DEFAULT_AUX_WINDOW_SIZE`.
const Map<String, int> DEFAULT_AUX_WINDOW_SIZE = <String, int>{
  'width': 1024,
  'height': 768,
};
