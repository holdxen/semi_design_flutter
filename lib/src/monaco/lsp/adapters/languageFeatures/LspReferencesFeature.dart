// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspReferencesFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../TextDocumentSynchronizer.dart' show LspTextDocumentIdentifier;
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspReferencesFeature extends Disposable`
class LspReferencesFeature extends Disposable {
  LspReferencesFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'references': <String, dynamic>{'dynamicRegistration': true},
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentReferences']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerReferenceProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspReferenceProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspReferenceProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspReferenceProvider(this._client, this._capabilities);

  /// 1:1: `provideReferences`
  Future<Object?> provideReferences(
    IMonacoTextModel model,
    MonacoPosition position,
    Map<String, Object?> context,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentReferences(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'position': translated.position,
        'context': <String, Object?>{
          'includeDeclaration': context['includeDeclaration'],
        },
      },
    );
    if (result == null) return null;
    return (result as List).map<Object?>((loc) {
      final l = loc as Map<String, Object?>;
      final translated = _client.bridge.translateBackRange(
        LspTextDocumentIdentifier(l['uri'] as String),
        C.lspRangeFromMap(l['range']),
      );
      return <String, Object?>{
        'uri': translated.textModel.getUri(),
        'range': translated.range,
      };
    }).toList();
  }
}
