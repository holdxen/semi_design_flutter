// 1:1 port of vscode/src/vs/base/common/network.ts
// 严格 1:1 翻译，勿改类名/API。
import 'errors.dart' as errors;
import 'lifecycle.dart' show IDisposable, IReference, toDisposable;
import 'path.dart' as paths;
import 'platform.dart' as platform;
import 'strings.dart' show equalsIgnoreCase, startsWithIgnoreCase;
import 'uri.dart' show URI, UriChange, UriComponents;

/// 1:1: `export namespace Schemas`
class Schemas {
  static const String inMemory = 'inmemory';
  static const String vscode = 'vscode';
  static const String internal = 'private';
  static const String walkThrough = 'walkThrough';
  static const String walkThroughSnippet = 'walkThroughSnippet';
  static const String vscodeOnboardingSample = 'vscode-onboarding-sample';
  static const String http = 'http';
  static const String https = 'https';
  static const String file = 'file';
  static const String mailto = 'mailto';
  static const String untitled = 'untitled';
  static const String data = 'data';
  static const String command = 'command';
  static const String vscodeRemote = 'vscode-remote';
  static const String vscodeRemoteResource = 'vscode-remote-resource';
  static const String vscodeManagedRemoteResource = 'vscode-managed-remote-resource';
  static const String vscodeUserData = 'vscode-userdata';
  static const String vscodeCustomEditor = 'vscode-custom-editor';
  static const String vscodeWindowCanvas = 'vscode-window-canvas';
  static const String vscodeNotebookCell = 'vscode-notebook-cell';
  static const String vscodeNotebookCellMetadata = 'vscode-notebook-cell-metadata';
  static const String vscodeNotebookCellMetadataDiff = 'vscode-notebook-cell-metadata-diff';
  static const String vscodeNotebookCellOutput = 'vscode-notebook-cell-output';
  static const String vscodeNotebookCellOutputDiff = 'vscode-notebook-cell-output-diff';
  static const String vscodeNotebookMetadata = 'vscode-notebook-metadata';
  static const String vscodeInteractiveInput = 'vscode-interactive-input';
  static const String vscodeSettings = 'vscode-settings';
  static const String vscodeWorkspaceTrust = 'vscode-workspace-trust';
  static const String vscodeTerminal = 'vscode-terminal';
  static const String vscodeImageCarousel = 'vscode-image-carousel';
  static const String vscodeChatCodeBlock = 'vscode-chat-code-block';
  static const String vscodeChatCodeCompareBlock = 'vscode-chat-code-compare-block';
  static const String vscodeChatEditor = 'vscode-chat-editor';
  static const String vscodeChatInput = 'chatSessionInput';
  static const String sessionsChatInput = 'sessions-chat';
  static const String vscodeLocalChatSession = 'vscode-chat-session';
  static const String vscodeChatResponseResource = 'vscode-chat-response-resource';
  static const String agentHostTerminal = 'agenthost-terminal';
  static const String vscodeChatTerminalOutput = 'vscode-chat-terminal-output';
  static const String webviewPanel = 'webview-panel';
  static const String vscodeWebview = 'vscode-webview';
  static const String vscodeBrowser = 'vscode-browser';
  static const String extension = 'extension';
  static const String vscodeFileResource = 'vscode-file';
  static const String tmp = 'tmp';
  static const String vsls = 'vsls';
  static const String git = 'git';
  static const String vscodeSourceControl = 'vscode-scm';
  static const String commentsInput = 'comment';
  static const String codeSetting = 'code-setting';
  static const String outputChannel = 'output';
  static const String accessibleView = 'accessible-view';
  static const String chatEditingSnapshotScheme = 'chat-editing-snapshot-text-model';
  static const String chatEditingModel = 'chat-editing-text-model';
  static const String copilotPr = 'copilot-pr';
}

/// 1:1: `export function matchesScheme`
bool matchesScheme(dynamic target, String scheme) {
  if (URI.isUri(target)) {
    return equalsIgnoreCase((target as URI).scheme, scheme);
  } else {
    return startsWithIgnoreCase(target as String, '$scheme:');
  }
}

/// 1:1: `export function matchesSomeScheme`
bool matchesSomeScheme(dynamic target, List<String> schemes) =>
    schemes.any((String scheme) => matchesScheme(target, scheme));

/// 1:1: `export const connectionTokenCookieName`
const String connectionTokenCookieName = 'vscode-tkn';
/// 1:1: `export const connectionTokenQueryName`
const String connectionTokenQueryName = 'tkn';

/// 1:1: `class RemoteAuthoritiesImpl`
class RemoteAuthoritiesImpl {
  final Map<String, String> _hosts = <String, String>{};
  final Map<String, num> _ports = <String, num>{};
  final Map<String, String> _connectionTokens = <String, String>{};
  String _preferredWebSchema = 'http';
  URI Function(URI)? _delegate;
  String _serverRootPath = '/';

  void setPreferredWebSchema(String schema) {
    _preferredWebSchema = schema;
  }

  void setDelegate(URI Function(URI) delegate) {
    _delegate = delegate;
  }

  void setServerRootPath(Map<String, Object?> product, String? serverBasePath) {
    _serverRootPath = paths.posix.join(<String>[
      serverBasePath ?? '/',
      getServerProductSegment(product),
    ]);
  }

  String getServerRootPath() => _serverRootPath;

  String get _remoteResourcesPath =>
      paths.posix.join(<String>[_serverRootPath, Schemas.vscodeRemoteResource]);

  void set(String authority, String host, num port) {
    _hosts[authority] = host;
    _ports[authority] = port;
  }

  void setConnectionToken(String authority, String connectionToken) {
    _connectionTokens[authority] = connectionToken;
  }

  String getPreferredWebSchema() => _preferredWebSchema;

  URI rewrite(URI uri) {
    if (_delegate != null) {
      try {
        return _delegate!(uri);
      } catch (err) {
        errors.onUnexpectedExternalError(err);
        return uri;
      }
    }
    final String authority = uri.authority;
    String? host = _hosts[authority];
    if (host != null && host.contains(':') && !host.contains('[')) {
      host = '[$host]';
    }
    final num? port = _ports[authority];
    final String? connectionToken = _connectionTokens[authority];
    String query = 'path=${encodeURIComponent(uri.path)}';
    if (connectionToken != null) {
      query += '&$connectionTokenQueryName=${encodeURIComponent(connectionToken)}';
    }
    return URI.from(UriComponents(
      scheme: platform.isWeb ? _preferredWebSchema : Schemas.vscodeRemoteResource,
      authority: '$host:$port',
      path: _remoteResourcesPath,
      query: query,
    ));
  }
}

/// 1:1: `export const RemoteAuthorities`
final RemoteAuthoritiesImpl RemoteAuthorities = RemoteAuthoritiesImpl();

/// 1:1: `export function getServerProductSegment`
String getServerProductSegment(Map<String, Object?> product) =>
    '${product['quality'] ?? 'oss'}-${product['commit'] ?? 'dev'}';

/// 1:1: `export type AppResourcePath` — TS template literal type 无法表达，用 String 承载。
typedef AppResourcePath = String;

const String builtinExtensionsPath = 'vs/../../extensions';
const String nodeModulesPath = 'vs/../../node_modules';
const String nodeModulesAsarPath = 'vs/../../node_modules.asar';
const String nodeModulesAsarUnpackedPath = 'vs/../../node_modules.asar.unpacked';

const String AGENTS_AUTHORITY = 'agents';
const String VSCODE_AUTHORITY = 'vscode-app';

/// 1:1: `interface BrowserUriProvider`
class BrowserUriProvider {
  URI Function(URI)? uriToBrowserUri;
  final Future<IReference<URI>> Function(URI) resolve;
  BrowserUriProvider({this.uriToBrowserUri, required this.resolve});
}

/// 1:1: `class FileAccessImpl`
class FileAccessImpl {
  static const String _FALLBACK_AUTHORITY = VSCODE_AUTHORITY;
  final Map<String, BrowserUriProvider> _browserUriProviders =
      <String, BrowserUriProvider>{};

  /// 1:1: `registerBrowserUriProvider`
  IDisposable registerBrowserUriProvider(String scheme, BrowserUriProvider provider) {
    if (_browserUriProviders.containsKey(scheme)) {
      throw Exception('Browser URI provider already registered for $scheme');
    }
    _browserUriProviders[scheme] = provider;
    return toDisposable(() => _browserUriProviders.remove(scheme));
  }

  /// 1:1: `resolveBrowserUri`
  Future<IReference<URI>>? resolveBrowserUri(URI uri) =>
      _browserUriProviders[uri.scheme]?.resolve(uri);

  /// 1:1: `asBrowserUri`
  URI asBrowserUri(String resourcePath) => uriToBrowserUri(toUri(resourcePath));

  /// 1:1: `uriToBrowserUri`
  URI uriToBrowserUri(URI uri) {
    final BrowserUriProvider? provider = _browserUriProviders[uri.scheme];
    if (provider?.uriToBrowserUri != null) {
      return provider!.uriToBrowserUri!(uri);
    }
    // Handle remote URIs via `RemoteAuthorities`
    if (uri.scheme == Schemas.vscodeRemote) {
      return RemoteAuthorities.rewrite(uri);
    }

    // Convert to `vscode-file` resource..
    if (
      // ...only ever for `file` resources
      uri.scheme == Schemas.file &&
      (
        // ...and we run in native environments
        platform.isNative ||
        // ...or web worker extensions on desktop
        (platform.webWorkerOrigin ==
            '${Schemas.vscodeFileResource}://$_FALLBACK_AUTHORITY')
      )
    ) {
      return uri.withChanges(UriChange(
        scheme: Schemas.vscodeFileResource,
        authority: uri.authority.isNotEmpty ? uri.authority : _FALLBACK_AUTHORITY,
        query: null,
        fragment: null,
      ));
    }

    return uri;
  }

  /// 1:1: `asFileUri`
  URI asFileUri(String resourcePath) => uriToFileUri(toUri(resourcePath));

  /// 1:1: `uriToFileUri`
  URI uriToFileUri(URI uri) {
    // Only convert the URI if it is `vscode-file:` scheme
    if (uri.scheme == Schemas.vscodeFileResource) {
      return uri.withChanges(UriChange(
        scheme: Schemas.file,
        authority: uri.authority != _FALLBACK_AUTHORITY ? uri.authority : null,
        query: null,
        fragment: null,
      ));
    }

    return uri;
  }

  /// 1:1: `toUri` — 源码用 globalThis._VSCODE_FILE_ROOT；Dart 用顶层可注入变量。
  URI toUri(dynamic uriOrModule) {
    if (URI.isUri(uriOrModule)) {
      return uriOrModule as URI;
    }

    final String? rootUriOrPath = globalVSCodeFileRoot;
    if (rootUriOrPath != null) {
      final String moduleId = uriOrModule as String;
      // File URL (with scheme)
      if (RegExp(r'^\w[\w\d+.-]*:\/\/').hasMatch(rootUriOrPath)) {
        return URI.joinPath(URI.parse(rootUriOrPath, true), <String>[moduleId]);
      }

      // File Path (no scheme)
      final String modulePath = paths.join(<String>[rootUriOrPath, moduleId]);
      return URI.file(modulePath);
    }

    throw StateError('Cannot determine URI for module id!');
  }
}

/// 1:1: `export const FileAccess`
final FileAccessImpl FileAccess = FileAccessImpl();

/// 1:1: `export const CacheControlheaders`
final Map<String, String> CacheControlheaders =
    Map<String, String>.unmodifiable(<String, String>{
  'Cache-Control': 'no-cache, no-store',
});

/// 1:1: `export const DocumentPolicyheaders`
final Map<String, String> DocumentPolicyheaders =
    Map<String, String>.unmodifiable(<String, String>{
  'Document-Policy': 'include-js-call-stacks-in-crash-reports',
});

/// 1:1: `export namespace COI`
class COI {
  static final Map<String, Map<String, String>> _coiHeaders =
      <String, Map<String, String>>{
    '1': <String, String>{'Cross-Origin-Opener-Policy': 'same-origin'},
    '2': <String, String>{'Cross-Origin-Embedder-Policy': 'require-corp'},
    '3': <String, String>{
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp',
    },
  };

  static final Map<String, String> CoopAndCoep =
      Map<String, String>.unmodifiable(_coiHeaders['3']!);

  static const String _coiSearchParamName = 'vscode-coi';

  /// 1:1: `getHeadersFromQuery`
  static Map<String, String>? getHeadersFromQuery(dynamic url) {
    Map<String, String>? params;
    if (url is Uri) {
      params = url.queryParameters;
    } else if (url is URI) {
      params = Uri.parse(url.toString(true)).queryParameters;
    } else if (url is String) {
      params = Uri.parse(url).queryParameters;
    }
    final String? value = params?[_coiSearchParamName];
    if (value == null || value.isEmpty) {
      return null;
    }
    return _coiHeaders[value];
  }

  /// 1:1: `addSearchParam`
  static void addSearchParam(dynamic urlOrSearch, bool coop, bool coep) {
    if (!crossOriginIsolated) {
      // depends on the current context being COI
      return;
    }
    final String value = coop && coep ? '3' : coep ? '2' : '1';
    if (urlOrSearch is Uri) {
      final Map<String, String> existing = urlOrSearch.queryParameters;
      existing[_coiSearchParamName] = value;
      // URLSearchParams.set in-place；Dart Uri 不可变，这里承载语义靠外部读取 params。
      // 源码返回 void，故此处仅更新传入的 Map（见下方 Map 分支）。
      _lastParams = existing;
    } else if (urlOrSearch is Map<String, String>) {
      urlOrSearch[_coiSearchParamName] = value;
    }
  }

  /// 供 Uri 分支测试读取最近一次 set 结果（承载 URLSearchParams 的可变语义）。
  static Map<String, String>? _lastParams;
  static Map<String, String>? get lastParams => _lastParams;
}

/// 1:1: `globalThis._VSCODE_FILE_ROOT` — Dart 无 globalThis，用顶层可注入变量承载。
String? globalVSCodeFileRoot;

/// 1:1: `globalThis.crossOriginIsolated`
bool crossOriginIsolated = false;

/// 1:1: JS `encodeURIComponent` 语义（源码用原生 encodeURIComponent）。
String encodeURIComponent(String value) => Uri.encodeComponent(value);
