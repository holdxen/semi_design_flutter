// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspOnTypeFormattingFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspOnTypeFormattingFeature extends Disposable`
class LspOnTypeFormattingFeature extends Disposable {
  LspOnTypeFormattingFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'onTypeFormatting': <String, dynamic>{'dynamicRegistration': true},
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentOnTypeFormatting']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerOnTypeFormattingEditProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspOnTypeFormattingProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspOnTypeFormattingProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;

  /// 1:1: `autoFormatTriggerCharacters`
  late final List<String> autoFormatTriggerCharacters;

  _LspOnTypeFormattingProvider(this._client, this._capabilities) {
    // 1:1: `[firstTriggerCharacter, ...(moreTriggerCharacter || [])]`
    autoFormatTriggerCharacters = <String>[
      _capabilities['firstTriggerCharacter'] as String,
      ...((_capabilities['moreTriggerCharacter'] as List?) ?? const <Object?>[])
          .cast<String>(),
    ];
  }

  /// 1:1: `provideOnTypeFormattingEdits`
  Future<Object?> provideOnTypeFormattingEdits(
    IMonacoTextModel model,
    MonacoPosition position,
    String ch,
    Map<String, Object?> options,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentOnTypeFormatting(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'position': translated.position,
        'ch': ch,
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
