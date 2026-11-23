// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspCodeLensFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../ITextModelBridge.dart' show assertRangeTarget, assertPositionTarget;
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspCodeLensFeature extends Disposable`
class LspCodeLensFeature extends Disposable {
  LspCodeLensFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'codeLens': <String, dynamic>{'dynamicRegistration': true},
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentCodeLens']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerCodeLensProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspCodeLensProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspCodeLensProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspCodeLensProvider(this._client, this._capabilities);

  /// 1:1: `provideCodeLenses`
  Future<Object?> provideCodeLenses(
    IMonacoTextModel model,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, const MonacoPosition(1, 1));
    final result = await _client.server.textDocumentCodeLens(
      <String, Object?>{'textDocument': translated.textDocument},
    );
    if (result == null) return null;
    return <String, Object?>{
      'lenses': (result as List).map<Object?>((lens) {
        final l = lens as Map<String, Object?>;
        return <String, Object?>{
          'range': assertRangeTarget(
            _client.bridge.translateBackRange(
              translated.textDocument,
              C.lspRangeFromMap(l['range']),
            ),
            model,
          ),
          'command': _toMonacoCodeLensCommand(l['command'], _client),
          '_lspCodeLens': l,
        };
      }).toList(),
      'dispose': () {},
    };
  }

  /// 1:1: `resolveCodeLens`
  Future<Object?> resolveCodeLens(
    IMonacoTextModel model,
    Map<String, Object?> codeLens,
    Object? token,
  ) async {
    final lspLens = codeLens['_lspCodeLens'];
    if (_capabilities['resolveProvider'] != true || lspLens == null) {
      return codeLens;
    }
    final resolved = await _client.server
        .codeLensResolve(lspLens as Map<String, Object?>);
    if (resolved == null) return codeLens;
    final r = resolved as Map<String, Object?>;
    if (r['command'] != null) {
      codeLens['command'] = _toMonacoCodeLensCommand(r['command'], _client);
    }
    return codeLens;
  }
}

/// 1:1: `toMonacoCodeLensCommand` — keeps the title for non-executable commands.
Object? _toMonacoCodeLensCommand(Object? command, LspConnection client) {
  if (command == null) return null;
  return client.commands.toMonacoCommand(command as T.Command) ??
      <String, Object?>{
        'id': '',
        'title': (command as Map<String, Object?>)['title'],
      };
}
