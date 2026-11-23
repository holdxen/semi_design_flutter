// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspImplementationFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspImplementationFeature extends Disposable`
class LspImplementationFeature extends Disposable {
  LspImplementationFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'implementation': <String, dynamic>{
          'dynamicRegistration': true,
          'linkSupport': true,
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentImplementation']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerImplementationProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspImplementationProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspImplementationProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspImplementationProvider(this._client, this._capabilities);

  /// 1:1: `provideImplementation`
  Future<Object?> provideImplementation(
    IMonacoTextModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentImplementation(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'position': translated.position,
      },
    );
    if (result == null) return null;
    if (result is List) {
      return result.map((loc) => C.toMonacoLocation(loc, _client)).toList();
    }
    return C.toMonacoLocation(result, _client);
  }
}
