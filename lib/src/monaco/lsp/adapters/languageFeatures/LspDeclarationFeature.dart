// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspDeclarationFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspDeclarationFeature extends Disposable`
class LspDeclarationFeature extends Disposable {
  LspDeclarationFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'declaration': <String, dynamic>{
          'dynamicRegistration': true,
          'linkSupport': true,
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentDeclaration']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerDeclarationProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspDeclarationProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspDeclarationProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspDeclarationProvider(this._client, this._capabilities);

  /// 1:1: `provideDeclaration`
  Future<Object?> provideDeclaration(
    IMonacoTextModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentDeclaration(
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
