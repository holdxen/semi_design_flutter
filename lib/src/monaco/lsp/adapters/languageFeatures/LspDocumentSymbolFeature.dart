// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspDocumentSymbolFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../TextDocumentSynchronizer.dart' show LspTextDocumentIdentifier;
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspDocumentSymbolFeature extends Disposable`
class LspDocumentSymbolFeature extends Disposable {
  LspDocumentSymbolFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'documentSymbol': <String, dynamic>{
          'dynamicRegistration': true,
          'hierarchicalDocumentSymbolSupport': true,
          'symbolKind': <String, dynamic>{
            'valueSet': C.lspSymbolKindToMonacoSymbolKind.keys.toList(),
          },
          'tagSupport': <String, dynamic>{
            'valueSet': <Object?>[T.SymbolTag.Deprecated],
          },
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentDocumentSymbol']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerDocumentSymbolProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspDocumentSymbolProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspDocumentSymbolProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspDocumentSymbolProvider(this._client, this._capabilities);

  /// 1:1: `provideDocumentSymbols`
  Future<Object?> provideDocumentSymbols(
    IMonacoTextModel model,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, const MonacoPosition(1, 1));
    final result = await _client.server.textDocumentDocumentSymbol(
      <String, Object?>{'textDocument': translated.textDocument},
    );
    if (result == null) return null;
    final list = result as List;
    if (list.isNotEmpty) {
      final first = list[0] as Map<String, Object?>;
      if (first.containsKey('location')) {
        // SymbolInformation[]
        return list
            .map((symbol) => _toMonacoSymbolInformation(
                  symbol as Map<String, Object?>,
                  _client,
                ))
            .toList();
      }
      // DocumentSymbol[]
      return list
          .map((symbol) => _toMonacoDocumentSymbol(
                symbol as Map<String, Object?>,
                _client,
                translated.textDocument,
              ))
          .toList();
    }
    return <Object?>[];
  }
}

/// 1:1: `toMonacoDocumentSymbol`
Map<String, Object?> _toMonacoDocumentSymbol(
  Map<String, Object?> symbol,
  LspConnection client,
  T.TextDocumentIdentifier textDocument,
) {
  final tags = symbol['tags'];
  final children = symbol['children'];
  return <String, Object?>{
    'name': symbol['name'],
    'detail': symbol['detail'] ?? '',
    'kind': C.toMonacoSymbolKind(symbol['kind']),
    'tags': tags == null
        ? <Object?>[]
        : (tags as List)
            .map((tag) => C.toMonacoSymbolTag(tag))
            .where((tag) => tag != null)
            .toList(),
    'range': client.bridge
        .translateBackRange(textDocument, C.lspRangeFromMap(symbol['range']))
        .range,
    'selectionRange': client.bridge
        .translateBackRange(
          textDocument,
          C.lspRangeFromMap(symbol['selectionRange']),
        )
        .range,
    'children': children == null
        ? <Object?>[]
        : (children as List)
            .map((child) => _toMonacoDocumentSymbol(
                  child as Map<String, Object?>,
                  client,
                  textDocument,
                ))
            .toList(),
  };
}

/// 1:1: `toMonacoSymbolInformation`
Map<String, Object?> _toMonacoSymbolInformation(
  Map<String, Object?> symbol,
  LspConnection client,
) {
  final tags = symbol['tags'];
  final location = symbol['location'] as Map<String, Object?>;
  final td = LspTextDocumentIdentifier(location['uri'] as String);
  final locRange = C.lspRangeFromMap(location['range']);
  return <String, Object?>{
    'name': symbol['name'],
    'detail': '',
    'kind': C.toMonacoSymbolKind(symbol['kind']),
    'tags': tags == null
        ? <Object?>[]
        : (tags as List)
            .map((tag) => C.toMonacoSymbolTag(tag))
            .where((tag) => tag != null)
            .toList(),
    'range': client.bridge.translateBackRange(td, locRange).range,
    'selectionRange': client.bridge.translateBackRange(td, locRange).range,
    'children': <Object?>[],
  };
}
