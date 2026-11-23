// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspDefinitionFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspDefinitionFeature extends Disposable`
class LspDefinitionFeature extends Disposable {
  LspDefinitionFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'definition': <String, dynamic>{
          'dynamicRegistration': true,
          'linkSupport': true,
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentDefinition']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerDefinitionProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspDefinitionProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspDefinitionProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspDefinitionProvider(this._client, this._capabilities);

  /// 1:1: `provideDefinition`
  Future<Object?> provideDefinition(
    IMonacoTextModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentDefinition(
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
