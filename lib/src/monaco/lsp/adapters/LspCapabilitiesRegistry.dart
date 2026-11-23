// 1:1 port of monaco-lsp-client/src/adapters/LspCapabilitiesRegistry.ts
// Bridges: TypedChannel (@hediet/json-rpc) -> typedChannel.dart carrier;
// monaco types -> types.dart; Disposable/IDisposable -> ../utils.dart.
import '../types.dart' as T;
import '../utils.dart';
import 'typedChannel.dart';

/// 1:1: `export interface ILspCapabilitiesRegistry`
/// Carrier: the pure-declaration `ClientCapabilities`/`ServerCapabilities`
/// abstract classes have no runtime shape in Dart, so registry data flows as
/// `Map<String, dynamic>` (matching TS structural objects).
typedef ClientCapabilitiesMap = Map<String, dynamic>;
typedef ServerCapabilitiesMap = Map<String, dynamic>;

abstract class ILspCapabilitiesRegistry {
  IDisposable addStaticClientCapabilities(ClientCapabilitiesMap capability);

  IDisposable registerCapabilityHandler<Tcap>(
    T.Capability<Tcap> capability,
    bool handleStaticCapability,
    IDisposable Function(Tcap capability) handler,
  );
}

/// 1:1: `class CapabilityHandler<T>`
class CapabilityHandler<Tcap> {
  final T.Capability<Tcap> capability;
  final bool handleStaticCapability;
  final IDisposable Function(Tcap capabilityOptions) handler;

  CapabilityHandler(this.capability, this.handleStaticCapability, this.handler);
}

/// 1:1: `class CapabilityRegistration<T>`
class CapabilityRegistration<Tcap> {
  final Map<CapabilityHandler<dynamic>, IDisposable> handlerDisposables =
      <CapabilityHandler<dynamic>, IDisposable>{};

  final String id;
  final T.Capability<Tcap> capability;
  final Tcap options;
  final bool isFromStatic;

  CapabilityRegistration(this.id, this.capability, this.options, this.isFromStatic);
}

/// 1:1: lookup table `capabilitiesByMethod`
final Map<String, T.Capability<dynamic>> _capabilitiesByMethod =
    <String, T.Capability<dynamic>>{
  for (final c in T.capabilities.values) c.method: c,
};

/// 1:1: `function getCapabilityByMethod(method)`
T.Capability<dynamic> getCapabilityByMethod(String method) {
  final c = _capabilitiesByMethod[method];
  if (c == null) {
    throw StateError('No capability found for method $method');
  }
  return c;
}

/// 1:1: `class CapabilityInfo<T>`
class CapabilityInfo<Tcap> {
  final Set<CapabilityHandler<Tcap>> handlers = <CapabilityHandler<Tcap>>{};
  final Map<String, CapabilityRegistration<Tcap>> registrations =
      <String, CapabilityRegistration<Tcap>>{};
}

/// 1:1: `class DynamicFromStaticOptions`
class DynamicFromStaticOptions {
  final Map<String, Object? Function(ServerCapabilitiesMap)> _mappings =
      <String, Object? Function(ServerCapabilitiesMap)>{};

  /// 1:1: `static create(): DynamicFromStaticOptions`
  static DynamicFromStaticOptions create() {
    final o = DynamicFromStaticOptions();

    o.set(T.capabilities['textDocumentDidChange']!, (dynamic s) {
      final sc = s as Map<String, dynamic>;
      final tds = sc['textDocumentSync'];
      if (tds == null) {
        return null;
      }
      if (tds is Map) {
        return <String, Object?>{
          'syncKind': tds['change'] ?? T.TextDocumentSyncKind.None,
          'documentSelector': null,
        };
      }
      return <String, Object?>{
        'syncKind': tds,
        'documentSelector': null,
      };
    });

    // 1:1: each `o.set(capabilities.X, s => s.<provider>)` mapping.
    void setSimple(T.Capability<dynamic> cap, String field) {
      o.set(cap, (dynamic s) => (s as Map<String, dynamic>)[field]);
    }

    setSimple(T.capabilities['textDocumentCompletion']!, 'completionProvider');
    setSimple(T.capabilities['textDocumentHover']!, 'hoverProvider');
    setSimple(T.capabilities['textDocumentSignatureHelp']!, 'signatureHelpProvider');
    setSimple(T.capabilities['textDocumentDefinition']!, 'definitionProvider');
    setSimple(T.capabilities['textDocumentReferences']!, 'referencesProvider');
    setSimple(T.capabilities['textDocumentDocumentHighlight']!, 'documentHighlightProvider');
    setSimple(T.capabilities['textDocumentDocumentSymbol']!, 'documentSymbolProvider');
    setSimple(T.capabilities['textDocumentCodeAction']!, 'codeActionProvider');
    setSimple(T.capabilities['textDocumentCodeLens']!, 'codeLensProvider');
    setSimple(T.capabilities['textDocumentDocumentLink']!, 'documentLinkProvider');
    setSimple(T.capabilities['textDocumentFormatting']!, 'documentFormattingProvider');
    setSimple(T.capabilities['textDocumentRangeFormatting']!, 'documentRangeFormattingProvider');
    setSimple(T.capabilities['textDocumentOnTypeFormatting']!, 'documentOnTypeFormattingProvider');
    setSimple(T.capabilities['textDocumentRename']!, 'renameProvider');
    setSimple(T.capabilities['textDocumentFoldingRange']!, 'foldingRangeProvider');
    setSimple(T.capabilities['textDocumentDeclaration']!, 'declarationProvider');
    setSimple(T.capabilities['textDocumentTypeDefinition']!, 'typeDefinitionProvider');
    setSimple(T.capabilities['textDocumentImplementation']!, 'implementationProvider');
    setSimple(T.capabilities['textDocumentDocumentColor']!, 'colorProvider');
    setSimple(T.capabilities['textDocumentSelectionRange']!, 'selectionRangeProvider');
    setSimple(T.capabilities['textDocumentLinkedEditingRange']!, 'linkedEditingRangeProvider');
    setSimple(T.capabilities['textDocumentPrepareCallHierarchy']!, 'callHierarchyProvider');
    setSimple(T.capabilities['textDocumentSemanticTokensFull']!, 'semanticTokensProvider');
    setSimple(T.capabilities['textDocumentInlayHint']!, 'inlayHintProvider');
    setSimple(T.capabilities['textDocumentInlineValue']!, 'inlineValueProvider');
    setSimple(T.capabilities['textDocumentDiagnostic']!, 'diagnosticProvider');
    setSimple(T.capabilities['textDocumentMoniker']!, 'monikerProvider');
    setSimple(T.capabilities['textDocumentPrepareTypeHierarchy']!, 'typeHierarchyProvider');
    setSimple(T.capabilities['workspaceSymbol']!, 'workspaceSymbolProvider');
    setSimple(T.capabilities['workspaceExecuteCommand']!, 'executeCommandProvider');
    return o;
  }

  /// 1:1: `set<T>(capability, getOptionsFromStatic)`
  void set<Tcap>(
    T.Capability<Tcap> capability,
    Object? Function(ServerCapabilitiesMap) getOptionsFromStatic,
  ) {
    if (_mappings.containsKey(capability.method)) {
      throw StateError('Capability for method ${capability.method} already registered');
    }
    _mappings[capability.method] = getOptionsFromStatic;
  }

  /// 1:1: `getOptions<T>(capability, serverCapabilities)`
  Object? getOptions<Tcap>(
    T.Capability<Tcap> capability,
    ServerCapabilitiesMap serverCapabilities,
  ) {
    final getter = _mappings[capability.method];
    if (getter == null) {
      return null;
    }
    return getter(serverCapabilities);
  }
}

/// 1:1: `function deepAssign(target, source)`
void deepAssign(Map<String, dynamic> target, Map<String, dynamic> source) {
  for (final key in source.keys) {
    final srcValue = source[key];
    if (srcValue == null) {
      // TS: `undefined` values are skipped. Dart maps distinguish null from
      // absent; a present null is treated as JS undefined (skip).
      continue;
    }
    final tgtValue = target[key];
    if (tgtValue == null) {
      target[key] = srcValue;
      continue;
    }
    // TS: `typeof srcValue !== 'object' || srcValue === null` -> assign.
    if (srcValue is! Map) {
      target[key] = srcValue;
      continue;
    }
    if (tgtValue is! Map) {
      target[key] = srcValue;
      continue;
    }
    deepAssign(target[key] as Map<String, dynamic>, srcValue as Map<String, dynamic>);
  }
}

/// 1:1: `export class LspCapabilitiesRegistry extends Disposable`
class LspCapabilitiesRegistry extends Disposable implements ILspCapabilitiesRegistry {
  final Set<Map<String, dynamic>> _staticCapabilities = <Map<String, dynamic>>{};
  final DynamicFromStaticOptions _dynamicFromStatic = DynamicFromStaticOptions.create();
  final Map<T.Capability<dynamic>, CapabilityInfo<dynamic>> _registrations =
      <T.Capability<dynamic>, CapabilityInfo<dynamic>>{};
  Map<String, dynamic>? _serverCapabilities;

  final TypedChannel _connection;

  LspCapabilitiesRegistry(this._connection) : super() {
    register(_connection.registerRequestHandler(
      T.api.client['clientRegisterCapability']!,
      (params) async {
        final p = params as RegistrationParams;
        for (final registration in p.registrations) {
          final rmap = registration as Map<String, dynamic>;
          final capability = getCapabilityByMethod(rmap['method'] as String);
          final r = CapabilityRegistration<dynamic>(
            rmap['id'] as String,
            capability,
            rmap['registerOptions'],
            false,
          );
          _registerCapabilityOptions(r);
        }
        return OkResult(null);
      },
    ));

    register(_connection.registerRequestHandler(
      T.api.client['clientUnregisterCapability']!,
      (params) async {
        final p = params as UnregistrationParams;
        for (final unregistration in p.unregisterations) {
          final umap = unregistration as Map<String, dynamic>;
          final capability = getCapabilityByMethod(umap['method'] as String);
          final info = _registrations[capability];
          final handlerInfo = info?.registrations[umap['id'] as String];
          if (handlerInfo == null) {
            throw StateError(
              'No registration for method ${umap['method']} with id ${umap['id']}',
            );
          }
          for (final d in handlerInfo.handlerDisposables.values) {
            d.dispose();
          }
          info?.registrations.remove(umap['id'] as String);
        }
        return OkResult(null);
      },
    ));
  }

  /// 1:1: `private _registerCapabilityOptions<T>(registration)`
  void _registerCapabilityOptions<Tcap>(CapabilityRegistration<Tcap> registration) {
    var registrationForMethod = _registrations[registration.capability];
    if (registrationForMethod == null) {
      registrationForMethod = CapabilityInfo<dynamic>();
      _registrations[registration.capability] = registrationForMethod;
    }
    if (registrationForMethod.registrations.containsKey(registration.id)) {
      throw StateError(
        'Handler for method ${registration.capability.method} with id ${registration.id} already registered',
      );
    }
    registrationForMethod.registrations[registration.id] = registration;
    for (final h in registrationForMethod.handlers) {
      if (!h.handleStaticCapability && registration.isFromStatic) {
        continue;
      }
      registration.handlerDisposables[h] = h.handler(registration.options);
    }
  }

  /// 1:1: `setServerCapabilities(serverCapabilities)`
  void setServerCapabilities(Map<String, dynamic> serverCapabilities) {
    if (_serverCapabilities != null) {
      throw StateError('Server capabilities already set');
    }
    _serverCapabilities = serverCapabilities;
    for (final cap in T.capabilities.values) {
      final options = _dynamicFromStatic.getOptions(cap, serverCapabilities);
      if (options != null) {
        _registerCapabilityOptions(
          CapabilityRegistration<dynamic>(cap.method, cap, options, true),
        );
      }
    }
  }

  /// 1:1: `getClientCapabilities(): ClientCapabilities`
  Map<String, dynamic> getClientCapabilities() {
    final result = <String, dynamic>{};
    for (final c in _staticCapabilities) {
      deepAssign(result, c);
    }
    return result;
  }

  @override
  IDisposable addStaticClientCapabilities(ClientCapabilitiesMap capability) {
    final obj = capability;
    _staticCapabilities.add(obj);
    return _LambdaDisposable(() {
      _staticCapabilities.remove(obj);
    });
  }

  @override
  IDisposable registerCapabilityHandler<Tcap>(
    T.Capability<Tcap> capability,
    bool handleStaticCapability,
    IDisposable Function(Tcap capability) handler,
  ) {
    var info = _registrations[capability];
    if (info == null) {
      info = CapabilityInfo<dynamic>();
      _registrations[capability] = info;
    }
    final infoRef = info; // captured in closure below (no promotion there)
    final handlerInfo = CapabilityHandler<Tcap>(capability, handleStaticCapability, handler);
    info.handlers.add(handlerInfo);

    for (final registration in info.registrations.values) {
      if (!handlerInfo.handleStaticCapability && registration.isFromStatic) {
        continue;
      }
      registration.handlerDisposables[handlerInfo] = handler(registration.options as Tcap);
    }

    return _LambdaDisposable(() {
      infoRef.handlers.remove(handlerInfo);
      for (final registration in infoRef.registrations.values) {
        final disposable = registration.handlerDisposables[handlerInfo];
        if (disposable != null) {
          disposable.dispose();
          registration.handlerDisposables.remove(handlerInfo);
        }
      }
    });
  }
}

/// Anonymous disposable from a lambda (TS object literal `{ dispose: () => {} }`).
class _LambdaDisposable implements IDisposable {
  final void Function() _dispose;
  _LambdaDisposable(this._dispose);

  @override
  void dispose() => _dispose();
}
