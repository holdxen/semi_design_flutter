// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspSemanticTokensFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspSemanticTokensFeature extends Disposable`
class LspSemanticTokensFeature extends Disposable {
  LspSemanticTokensFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'semanticTokens': <String, dynamic>{
          'dynamicRegistration': true,
          'requests': <String, dynamic>{
            'range': true,
            'full': <String, dynamic>{'delta': true},
          },
          'tokenTypes': <Object?>[
            'namespace', 'type', 'class', 'enum', 'interface', 'struct',
            'typeParameter', 'parameter', 'variable', 'property', 'enumMember',
            'event', 'function', 'method', 'macro', 'keyword', 'modifier',
            'comment', 'string', 'number', 'regexp', 'operator', 'decorator',
          ],
          'tokenModifiers': <Object?>[
            'declaration', 'definition', 'readonly', 'static', 'deprecated',
            'abstract', 'async', 'modification', 'documentation', 'defaultLibrary',
          ],
          'formats': <Object?>[T.TokenFormat.Relative],
          'overlappingTokenSupport': false,
          'multilineTokenSupport': true,
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentSemanticTokensFull']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerDocumentSemanticTokensProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspSemanticTokensProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspSemanticTokensProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspSemanticTokensProvider(this._client, this._capabilities);

  /// 1:1: `getLegend`
  Map<String, Object?> getLegend() {
    final legend = _capabilities['legend'] as Map<String, Object?>;
    return <String, Object?>{
      'tokenTypes': legend['tokenTypes'],
      'tokenModifiers': legend['tokenModifiers'],
    };
  }

  /// 1:1: `releaseDocumentSemanticTokens` (no-op in source).
  void releaseDocumentSemanticTokens(Object? resultId) {}

  /// 1:1: `provideDocumentSemanticTokens`
  Future<Object?> provideDocumentSemanticTokens(
    IMonacoTextModel model,
    Object? lastResultId,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, model.getPositionAt(0));

    final full = _capabilities['full'];
    if (lastResultId != null &&
        full is Map<String, Object?> &&
        full['delta'] == true) {
      final deltaResult = await _client.server
          .textDocumentSemanticTokensFullDelta(<String, Object?>{
        'textDocument': translated.textDocument,
        'previousResultId': lastResultId,
      });
      if (deltaResult == null) return null;
      final d = deltaResult as Map<String, Object?>;
      if (d.containsKey('edits')) {
        // Delta
        return <String, Object?>{
          'resultId': d['resultId'],
          'edits': (d['edits'] as List).map<Object?>((edit) {
            final e = edit as Map<String, Object?>;
            return <String, Object?>{
              'start': e['start'],
              'deleteCount': e['deleteCount'],
              'data': e['data'] == null ? null : _toUint32Array(e['data']),
            };
          }).toList(),
        };
      }
      // Full result
      return <String, Object?>{
        'resultId': d['resultId'],
        'data': _toUint32Array(d['data']),
      };
    }

    // Full request
    final result = await _client.server
        .textDocumentSemanticTokensFull(<String, Object?>{
      'textDocument': translated.textDocument,
    });
    if (result == null) return null;
    final r = result as Map<String, Object?>;
    return <String, Object?>{
      'resultId': r['resultId'],
      'data': _toUint32Array(r['data']),
    };
  }

  /// 1:1: `provideDocumentSemanticTokensEdits` — delegates to full.
  Future<Object?> provideDocumentSemanticTokensEdits(
    IMonacoTextModel model,
    String previousResultId,
    Object? token,
  ) async {
    return provideDocumentSemanticTokens(model, previousResultId, token);
  }

  /// 1:1 carrier of `new Uint32Array(data)`.
  List<int> _toUint32Array(Object? data) =>
      (data as List).map((v) => (v as num).toInt() & 0xFFFFFFFF).toList();
}
