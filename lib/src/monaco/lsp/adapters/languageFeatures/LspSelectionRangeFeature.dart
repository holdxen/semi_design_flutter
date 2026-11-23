// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspSelectionRangeFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspSelectionRangeFeature extends Disposable`
class LspSelectionRangeFeature extends Disposable {
  LspSelectionRangeFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'selectionRange': <String, dynamic>{'dynamicRegistration': true},
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentSelectionRange']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerSelectionRangeProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspSelectionRangeProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspSelectionRangeProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspSelectionRangeProvider(this._client, this._capabilities);

  /// 1:1: `provideSelectionRanges`
  Future<Object?> provideSelectionRanges(
    IMonacoTextModel model,
    List<MonacoPosition> positions,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, positions[0]);
    final result = await _client.server.textDocumentSelectionRange(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'positions': positions
            .map((pos) => _client.bridge.translate(model, pos).position)
            .toList(),
      },
    );
    if (result == null) return null;
    return (result as List)
        .map((selRange) => _convertSelectionRange(
              selRange,
              translated.textDocument,
            ))
        .toList();
  }

  /// 1:1: `convertSelectionRange` — while (current) walk `.parent` chain.
  List<Object?> _convertSelectionRange(
    Object? range,
    T.TextDocumentIdentifier textDocument,
  ) {
    final result = <Object?>[];
    Map<String, Object?>? current = range as Map<String, Object?>;
    while (current != null) {
      result.add(<String, Object?>{
        'range': _client.bridge
            .translateBackRange(textDocument, C.lspRangeFromMap(current['range']))
            .range,
      });
      current = current['parent'] as Map<String, Object?>?;
    }
    return result;
  }
}
