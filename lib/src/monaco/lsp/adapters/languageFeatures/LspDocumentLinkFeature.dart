// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspDocumentLinkFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspCommandPolicy.dart' show isCommandUri;
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspDocumentLinkFeature extends Disposable`
class LspDocumentLinkFeature extends Disposable {
  LspDocumentLinkFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'documentLink': <String, dynamic>{
          'dynamicRegistration': true,
          'tooltipSupport': true,
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentDocumentLink']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerLinkProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspDocumentLinkProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspDocumentLinkProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspDocumentLinkProvider(this._client, this._capabilities);

  /// 1:1: `provideLinks`
  Future<Object?> provideLinks(
    IMonacoTextModel model,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, const MonacoPosition(1, 1));
    final result = await _client.server.textDocumentDocumentLink(
      <String, Object?>{'textDocument': translated.textDocument},
    );
    if (result == null) return null;
    return <String, Object?>{
      'links': (result as List).where((link) {
        final l = link as Map<String, Object?>;
        final target = l['target'];
        // 1:1: `link.target === undefined || !isCommandUri(link.target)`
        return target == null || !isCommandUri(target as String);
      }).map<Object?>((link) {
        final l = link as Map<String, Object?>;
        return <String, Object?>{
          'range': _client.bridge
              .translateBackRange(
                translated.textDocument,
                C.lspRangeFromMap(l['range']),
              )
              .range,
          'url': l['target'],
          'tooltip': l['tooltip'],
        };
      }).toList(),
    };
  }

  /// 1:1: `resolveLink` — TODO in source, returns link unchanged.
  Future<Object?> resolveLink(Object? link, Object? token) async {
    if (_capabilities['resolveProvider'] != true) return link;
    // TODO: Implement resolve (1:1 with source).
    return link;
  }
}
