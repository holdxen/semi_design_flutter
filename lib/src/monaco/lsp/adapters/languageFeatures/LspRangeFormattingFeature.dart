// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspRangeFormattingFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspRangeFormattingFeature extends Disposable`
class LspRangeFormattingFeature extends Disposable {
  LspRangeFormattingFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'rangeFormatting': <String, dynamic>{'dynamicRegistration': true},
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentRangeFormatting']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerDocumentRangeFormattingEditProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspDocumentRangeFormattingProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspDocumentRangeFormattingProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspDocumentRangeFormattingProvider(this._client, this._capabilities);

  /// 1:1: `provideDocumentRangeFormattingEdits`
  Future<Object?> provideDocumentRangeFormattingEdits(
    IMonacoTextModel model,
    MonacoRange range,
    Map<String, Object?> options,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, range.getStartPosition());
    final result = await _client.server.textDocumentRangeFormatting(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'range': _client.bridge.translateRange(model, range),
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
