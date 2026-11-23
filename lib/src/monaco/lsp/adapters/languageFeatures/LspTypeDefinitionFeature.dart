// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspTypeDefinitionFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspTypeDefinitionFeature extends Disposable`
class LspTypeDefinitionFeature extends Disposable {
  LspTypeDefinitionFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'typeDefinition': <String, dynamic>{
          'dynamicRegistration': true,
          'linkSupport': true,
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentTypeDefinition']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerTypeDefinitionProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspTypeDefinitionProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspTypeDefinitionProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspTypeDefinitionProvider(this._client, this._capabilities);

  /// 1:1: `provideTypeDefinition`
  Future<Object?> provideTypeDefinition(
    IMonacoTextModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentTypeDefinition(
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
