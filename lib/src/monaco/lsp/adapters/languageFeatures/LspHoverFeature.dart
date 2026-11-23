// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspHoverFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspHoverFeature extends Disposable`
class LspHoverFeature extends Disposable {
  LspHoverFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'hover': <String, dynamic>{
          'dynamicRegistration': true,
          'contentFormat': <Object?>[
            T.MarkupKind.Markdown,
            T.MarkupKind.PlainText,
          ],
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentHover']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerHoverProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspHoverProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspHoverProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspHoverProvider(this._client, this._capabilities);

  /// 1:1: `provideHover`
  Future<Object?> provideHover(
    IMonacoTextModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentHover(<String, Object?>{
      'textDocument': translated.textDocument,
      'position': translated.position,
    });
    if (result == null) return null;
    final r = result as Map<String, Object?>;
    if (r['contents'] == null) return null;
    final rangeResult = r['range'];
    return <String, Object?>{
      'contents': _toMonacoMarkdownString(r['contents']),
      'range': rangeResult == null
          ? null
          : _client.bridge
              .translateBackRange(
                translated.textDocument,
                C.lspRangeFromMap(rangeResult),
              )
              .range,
    };
  }
}

/// 1:1: `toMonacoMarkdownString`
List<Object?> _toMonacoMarkdownString(Object? contents) {
  if (contents is List) {
    return contents.map((c) => _toSingleMarkdownString(c)).toList();
  }
  return <Object?>[_toSingleMarkdownString(contents)];
}

/// 1:1: `toSingleMarkdownString`
Map<String, Object?> _toSingleMarkdownString(Object? content) {
  if (content is String) {
    return C.toUntrustedMarkdownString(content);
  }
  final c = content as Map<String, Object?>;
  if (c.containsKey('kind')) {
    // MarkupContent
    return C.toUntrustedMarkdownString(c['value'] as String);
  }
  // MarkedString with language
  return C.toUntrustedMarkdownString(
    '\`\`\`${c['language']}\n${c['value']}\n\`\`\`',
  );
}
