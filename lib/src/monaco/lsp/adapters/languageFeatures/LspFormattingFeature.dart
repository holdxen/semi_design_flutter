// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspFormattingFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspFormattingFeature extends Disposable`
class LspFormattingFeature extends Disposable {
  LspFormattingFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'formatting': <String, dynamic>{'dynamicRegistration': true},
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentFormatting']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerDocumentFormattingEditProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspDocumentFormattingProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspDocumentFormattingProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspDocumentFormattingProvider(this._client, this._capabilities);

  /// 1:1: `provideDocumentFormattingEdits`
  Future<Object?> provideDocumentFormattingEdits(
    IMonacoTextModel model,
    Map<String, Object?> options,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, const MonacoPosition(1, 1));
    final result = await _client.server.textDocumentFormatting(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'options': <String, Object?>{
          'tabSize': options['tabSize'],
          'insertSpaces': options['insertSpaces'],
        },
      },
    );
    if (result == null) return null;
    return (result as List).map<Object?>((edit) {
      final e = edit as Map<String, Object?>;
      return <String, Object?>{
        'range': _client.bridge
            .translateBackRange(
              translated.textDocument,
              C.lspRangeFromMap(e['range']),
            )
            .range,
        'text': e['newText'],
      };
    }).toList();
  }
}
