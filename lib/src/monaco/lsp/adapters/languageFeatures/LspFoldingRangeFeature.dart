// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspFoldingRangeFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspFoldingRangeFeature extends Disposable`
class LspFoldingRangeFeature extends Disposable {
  LspFoldingRangeFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'foldingRange': <String, dynamic>{
          'dynamicRegistration': true,
          'rangeLimit': 5000,
          'lineFoldingOnly': false,
          'foldingRangeKind': <String, dynamic>{
            'valueSet': <Object?>[
              T.FoldingRangeKind.Comment,
              T.FoldingRangeKind.Imports,
              T.FoldingRangeKind.Region,
            ],
          },
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentFoldingRange']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerFoldingRangeProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspFoldingRangeProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspFoldingRangeProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspFoldingRangeProvider(this._client, this._capabilities);

  /// 1:1: `provideFoldingRanges`
  Future<Object?> provideFoldingRanges(
    IMonacoTextModel model,
    Object? context,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, const MonacoPosition(1, 1));
    final result = await _client.server.textDocumentFoldingRange(
      <String, Object?>{'textDocument': translated.textDocument},
    );
    if (result == null) return null;
    return (result as List).map<Object?>((range) {
      final r = range as Map<String, Object?>;
      return <String, Object?>{
        'start': (r['startLine'] as num) + 1,
        'end': (r['endLine'] as num) + 1,
        'kind': C.toMonacoFoldingRangeKind(r['kind']),
      };
    }).toList();
  }
}
