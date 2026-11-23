// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspSignatureHelpFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspSignatureHelpFeature extends Disposable`
class LspSignatureHelpFeature extends Disposable {
  LspSignatureHelpFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'signatureHelp': <String, dynamic>{
          'dynamicRegistration': true,
          'contextSupport': true,
          'signatureInformation': <String, dynamic>{
            'documentationFormat': <Object?>[
              T.MarkupKind.Markdown,
              T.MarkupKind.PlainText,
            ],
            'parameterInformation': <String, dynamic>{
              'labelOffsetSupport': true,
            },
            'activeParameterSupport': true,
          },
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentSignatureHelp']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerSignatureHelpProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspSignatureHelpProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspSignatureHelpProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;

  /// 1:1: `signatureHelpTriggerCharacters` / `signatureHelpRetriggerCharacters`
  List<String>? signatureHelpTriggerCharacters;
  List<String>? signatureHelpRetriggerCharacters;

  _LspSignatureHelpProvider(this._client, this._capabilities) {
    signatureHelpTriggerCharacters =
        (_capabilities['triggerCharacters'] as List?)?.cast<String>();
    signatureHelpRetriggerCharacters =
        (_capabilities['retriggerCharacters'] as List?)?.cast<String>();
  }

  /// 1:1: `provideSignatureHelp`
  Future<Object?> provideSignatureHelp(
    IMonacoTextModel model,
    MonacoPosition position,
    Object? token,
    Map<String, Object?> context,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentSignatureHelp(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'position': translated.position,
        'context': <String, Object?>{
          'triggerKind': C.toLspSignatureHelpTriggerKind(context['triggerKind']),
          'triggerCharacter': context['triggerCharacter'],
          'isRetrigger': context['isRetrigger'],
        },
      },
    );
    if (result == null) return null;
    final r = result as Map<String, Object?>;
    return <String, Object?>{
      'value': <String, Object?>{
        'signatures': (r['signatures'] as List).map<Object?>((sig) {
          final s = sig as Map<String, Object?>;
          final params = s['parameters'];
          return <String, Object?>{
            'label': s['label'],
            'documentation': _toMonacoDocumentation(s['documentation']),
            'parameters': params == null
                ? <Object?>[]
                : (params as List).map<Object?>((param) {
                    final p = param as Map<String, Object?>;
                    return <String, Object?>{
                      'label': p['label'],
                      'documentation': _toMonacoDocumentation(p['documentation']),
                    };
                  }).toList(),
            'activeParameter': s['activeParameter'],
          };
        }).toList(),
        'activeSignature': r['activeSignature'] ?? 0,
        'activeParameter': r['activeParameter'] ?? 0,
      },
      'dispose': () {},
    };
  }
}

/// 1:1: `toMonacoDocumentation`
Object? _toMonacoDocumentation(Object? doc) {
  if (doc == null) return null;
  if (doc is String) return doc;
  return C.toUntrustedMarkdownString((doc as Map<String, Object?>)['value'] as String);
}
