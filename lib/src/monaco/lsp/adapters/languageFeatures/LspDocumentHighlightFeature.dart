// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspDocumentHighlightFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspDocumentHighlightFeature extends Disposable`
class LspDocumentHighlightFeature extends Disposable {
  LspDocumentHighlightFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'documentHighlight': <String, dynamic>{'dynamicRegistration': true},
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentDocumentHighlight']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerDocumentHighlightProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspDocumentHighlightProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspDocumentHighlightProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspDocumentHighlightProvider(this._client, this._capabilities);

  /// 1:1: `provideDocumentHighlights`
  Future<Object?> provideDocumentHighlights(
    IMonacoTextModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentDocumentHighlight(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'position': translated.position,
      },
    );
    if (result == null) return null;
    final highlights = result as List;
    return highlights.map<Object?>((highlight) {
      final h = highlight as Map<String, Object?>;
      return <String, Object?>{
        'range': _client.bridge
            .translateBackRange(
              translated.textDocument,
              C.lspRangeFromMap(h['range']),
            )
            .range,
        'kind': C.toMonacoDocumentHighlightKind(h['kind']),
      };
    }).toList();
  }
}
