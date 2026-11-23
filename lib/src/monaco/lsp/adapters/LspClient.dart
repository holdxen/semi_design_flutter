// 1:1 port of monaco-lsp-client/src/adapters/LspClient.ts
// The LSP client assembly hub: builds TypedChannel -> server -> registry ->
// bridge -> commands -> connection, creates the 22 language features, then
// initializes the server. External/unported dependencies (@hediet/json-rpc
// IMessageTransport/TypedChannel, api.getServer) are injected via provider
// slots so no behavior is invented.
import '../utils.dart';
import 'LspCapabilitiesRegistry.dart';
import 'LspCommands.dart';
import 'LspConnection.dart';
import 'TextDocumentSynchronizer.dart';
import 'languageFeatures/LspCodeActionFeature.dart';
import 'languageFeatures/LspCodeLensFeature.dart';
import 'languageFeatures/LspCompletionFeature.dart';
import 'languageFeatures/LspDeclarationFeature.dart';
import 'languageFeatures/LspDefinitionFeature.dart';
import 'languageFeatures/LspDiagnosticsFeature.dart';
import 'languageFeatures/LspDocumentHighlightFeature.dart';
import 'languageFeatures/LspDocumentLinkFeature.dart';
import 'languageFeatures/LspDocumentSymbolFeature.dart';
import 'languageFeatures/LspFoldingRangeFeature.dart';
import 'languageFeatures/LspFormattingFeature.dart';
import 'languageFeatures/LspHoverFeature.dart';
import 'languageFeatures/LspImplementationFeature.dart';
import 'languageFeatures/LspInlayHintsFeature.dart';
import 'languageFeatures/LspOnTypeFormattingFeature.dart';
import 'languageFeatures/LspRangeFormattingFeature.dart';
import 'languageFeatures/LspReferencesFeature.dart';
import 'languageFeatures/LspRenameFeature.dart';
import 'languageFeatures/LspSelectionRangeFeature.dart';
import 'languageFeatures/LspSemanticTokensFeature.dart';
import 'languageFeatures/LspSignatureHelpFeature.dart';
import 'languageFeatures/LspTypeDefinitionFeature.dart';
import 'monacoEditorApi.dart';
import 'typedChannel.dart';

// ---------------------------------------------------------------------------
// External dependency bridges (injected provider slots, no invented logic).
// ---------------------------------------------------------------------------

/// 1:1: `TypedChannel.fromTransport(transport)` (from @hediet/json-rpc).
TypedChannel Function(Object? transport)? typedChannelFromTransportProvider;

/// 1:1: `api.getServer(channel, options): { server: IServerInterface }`.
IServerInterface Function(TypedChannel channel, Map<String, Object?> options)?
    apiGetServerProvider;

/// 1:1: `channel.startListen()` (from @hediet/json-rpc).
void Function(TypedChannel channel)? channelStartListenProvider;

/// 1:1 extension of [IServerInterface] with the two lifecycle calls made in
/// `_init`: `server.initialize(...)` and `server.initialized(...)`. Both go
/// through an observable hook so tests can capture method + params.
Future<Object?> Function(String method, Map<String, Object?> params)?
    serverLifecycleHook;

/// Observation hook: invoked with each feature's source class name immediately
/// after it is added to the DisposableStore. Lets truth tests verify the exact
/// 22-feature construction order without altering any feature behavior.
void Function(String featureName)? featureConstructedHook;

Future<Object?> Function(String method, Map<String, Object?> params)
    get _serverLifecycle => serverLifecycleHook ??
        (String m, Map<String, Object?> p) async =>
            <String, Object?>{'capabilities': <String, dynamic>{}};

extension _ServerLifecycleExt on IServerInterface {
  Future<Object?> initialize(Map<String, Object?> params) =>
      _serverLifecycle('initialize', params);
  Future<Object?> initialized(Map<String, Object?> params) =>
      _serverLifecycle('initialized', params);
}

/// 1:1: `export interface MonacoLspClientOptions`
/// Holds `allowedLocalCommands?: readonly string[]`.
class MonacoLspClientOptions {
  final List<String>? allowedLocalCommands;
  const MonacoLspClientOptions({this.allowedLocalCommands});
}

/// 1:1: `export class MonacoLspClient`
class MonacoLspClient {
  /// 1:1: `private _connection: LspConnection`
  late final LspConnection _connection;

  /// 1:1: `private readonly _capabilitiesRegistry: LspCapabilitiesRegistry`
  late final LspCapabilitiesRegistry _capabilitiesRegistry;

  /// 1:1: `private readonly _bridge: TextDocumentSynchronizer`
  late final TextDocumentSynchronizer _bridge;

  /// 1:1: `private _initPromise: Promise<void>`
  late final Future<void> _initPromise;

  MonacoLspClient(
    Object? transport, [
    MonacoLspClientOptions options = const MonacoLspClientOptions(),
  ]) {
    // 1:1:
    //   const c = TypedChannel.fromTransport(transport);
    //   const s = api.getServer(c, {});
    //   c.startListen();
    //   this._capabilitiesRegistry = new LspCapabilitiesRegistry(c);
    //   this._bridge = new TextDocumentSynchronizer(s.server, this._capabilitiesRegistry);
    //   const commands = new LspCommands(s.server, this._capabilitiesRegistry, options.allowedLocalCommands);
    //   this._connection = new LspConnection(s.server, this._bridge, this._capabilitiesRegistry, c, commands);
    //   this.createFeatures();
    //   this._initPromise = this._init();
    final c = _channelFromTransport(transport);
    final s = _serverFromChannel(c);
    channelStartListenProvider?.call(c);

    _capabilitiesRegistry = LspCapabilitiesRegistry(c);
    _bridge = TextDocumentSynchronizer(s, _capabilitiesRegistry);
    final commands = LspCommands(s, _capabilitiesRegistry, options.allowedLocalCommands);
    _connection = LspConnection(
      server: s,
      bridge: _bridge,
      capabilities: _capabilitiesRegistry,
      connection: c,
      commands: commands,
    );
    createFeatures();
    _initPromise = _init();
  }

  /// 1:1: `private async _init()`
  Future<void> _init() async {
    // 1:1: await this._connection.server.initialize({ processId: null, capabilities: ..., rootUri: null });
    final result = await _connection.server.initialize(<String, Object?>{
      'processId': null,
      'capabilities': _capabilitiesRegistry.getClientCapabilities(),
      'rootUri': null,
    });
    // 1:1: this._connection.server.initialized({});
    await _connection.server.initialized(<String, Object?>{});
    // 1:1: this._capabilitiesRegistry.setServerCapabilities(result.capabilities);
    final caps = (result as Map)['capabilities'] as Map<String, dynamic>;
    _capabilitiesRegistry.setServerCapabilities(caps);
  }

  /// 1:1: `protected createFeatures(): IDisposable`
  /// Registers all 22 language features into a DisposableStore in source order.
  IDisposable createFeatures() {
    final store = DisposableStore();
    store.add(LspCompletionFeature(_connection));
    featureConstructedHook?.call('LspCompletionFeature');
    store.add(LspHoverFeature(_connection));
    featureConstructedHook?.call('LspHoverFeature');
    store.add(LspSignatureHelpFeature(_connection));
    featureConstructedHook?.call('LspSignatureHelpFeature');
    store.add(LspDefinitionFeature(_connection));
    featureConstructedHook?.call('LspDefinitionFeature');
    store.add(LspDeclarationFeature(_connection));
    featureConstructedHook?.call('LspDeclarationFeature');
    store.add(LspTypeDefinitionFeature(_connection));
    featureConstructedHook?.call('LspTypeDefinitionFeature');
    store.add(LspImplementationFeature(_connection));
    featureConstructedHook?.call('LspImplementationFeature');
    store.add(LspReferencesFeature(_connection));
    featureConstructedHook?.call('LspReferencesFeature');
    store.add(LspDocumentHighlightFeature(_connection));
    featureConstructedHook?.call('LspDocumentHighlightFeature');
    store.add(LspDocumentSymbolFeature(_connection));
    featureConstructedHook?.call('LspDocumentSymbolFeature');
    store.add(LspRenameFeature(_connection));
    featureConstructedHook?.call('LspRenameFeature');
    store.add(LspCodeActionFeature(_connection));
    featureConstructedHook?.call('LspCodeActionFeature');
    store.add(LspCodeLensFeature(_connection));
    featureConstructedHook?.call('LspCodeLensFeature');
    store.add(LspDocumentLinkFeature(_connection));
    featureConstructedHook?.call('LspDocumentLinkFeature');
    store.add(LspFormattingFeature(_connection));
    featureConstructedHook?.call('LspFormattingFeature');
    store.add(LspRangeFormattingFeature(_connection));
    featureConstructedHook?.call('LspRangeFormattingFeature');
    store.add(LspOnTypeFormattingFeature(_connection));
    featureConstructedHook?.call('LspOnTypeFormattingFeature');
    store.add(LspFoldingRangeFeature(_connection));
    featureConstructedHook?.call('LspFoldingRangeFeature');
    store.add(LspSelectionRangeFeature(_connection));
    featureConstructedHook?.call('LspSelectionRangeFeature');
    store.add(LspInlayHintsFeature(_connection));
    featureConstructedHook?.call('LspInlayHintsFeature');
    store.add(LspSemanticTokensFeature(_connection));
    featureConstructedHook?.call('LspSemanticTokensFeature');
    store.add(LspDiagnosticsFeature(_connection));
    featureConstructedHook?.call('LspDiagnosticsFeature');
    return store;
  }

  /// Test/driver hook: await the internal initialization promise.
  Future<void> get initPromise => _initPromise;

  static TypedChannel _channelFromTransport(Object? transport) =>
      (typedChannelFromTransportProvider ??
          (Object? t) => InMemoryTypedChannel())(transport);

  static IServerInterface _serverFromChannel(TypedChannel channel) =>
      (apiGetServerProvider ??
          (TypedChannel c, Map<String, Object?> o) => _NullServer())(
        channel,
        const <String, Object?>{},
      );
}

/// Default server carrier used when no [apiGetServerProvider] is injected.
class _NullServer implements IServerInterface {
  @override
  Future<Object?> workspaceExecuteCommand(Map<String, Object?> params) async => null;
  @override
  Future<Object?> textDocumentDidOpen(Map<String, Object?> params) async => null;
  @override
  Future<Object?> textDocumentDidChange(Map<String, Object?> params) async => null;
  @override
  Future<Object?> textDocumentDidClose(Map<String, Object?> params) async => null;
}
