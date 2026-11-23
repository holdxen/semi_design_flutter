// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspCodeActionFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart' show CommandCarrier, LspConnection;
import '../TextDocumentSynchronizer.dart' show LspTextDocumentIdentifier;
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspCodeActionFeature extends Disposable`
class LspCodeActionFeature extends Disposable {
  LspCodeActionFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'codeAction': <String, dynamic>{
          'dynamicRegistration': true,
          'codeActionLiteralSupport': <String, dynamic>{
            'codeActionKind': <String, dynamic>{
              'valueSet': C.lspCodeActionKindToMonacoCodeActionKind.keys.toList(),
            },
          },
          'isPreferredSupport': true,
          'disabledSupport': true,
          'dataSupport': true,
          'resolveSupport': <String, dynamic>{
            'properties': <Object?>['edit'],
          },
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentCodeAction']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerCodeActionProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspCodeActionProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspCodeActionProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;

  /// 1:1: `resolveCodeAction` assigned only when resolveProvider is set.
  Future<Map<String, Object?>?> Function(Map<String, Object?>, Object?)?
      resolveCodeAction;

  _LspCodeActionProvider(this._client, this._capabilities) {
    if (_capabilities['resolveProvider'] == true) {
      resolveCodeAction = (codeAction, token) async {
        final lspAction = codeAction['_lspAction'];
        if (lspAction != null) {
          final resolved = await _client.server
              .codeActionResolve(lspAction as Map<String, Object?>);
          if (resolved == null) return codeAction;
          final r = resolved as Map<String, Object?>;
          if (r['edit'] != null) {
            codeAction['edit'] = _toMonacoWorkspaceEdit(r['edit'], _client);
          }
          if (r['command'] != null) {
            codeAction['command'] =
                _client.commands.toMonacoCommand(CommandCarrier(r['command'] as Map<String, Object?>));
          }
        }
        return codeAction;
      };
    }
  }

  /// 1:1: `provideCodeActions`
  Future<Object?> provideCodeActions(
    IMonacoTextModel model,
    MonacoRange range,
    Map<String, Object?> context,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, range.getStartPosition());
    final diagnostics = context['markers'] as List?;
    final result = await _client.server.textDocumentCodeAction(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'range': _client.bridge.translateRange(model, range),
        'context': <String, Object?>{
          'diagnostics': diagnostics == null
              ? <Object?>[]
              : diagnostics.map<Object?>((marker) {
                  final m = marker as Map<String, Object?>;
                  return <String, Object?>{
                    'range': _client.bridge.translateRange(
                      model,
                      monacoRangeLift(m),
                    ),
                    'message': m['message'],
                    'severity': C.toLspDiagnosticSeverity(m['severity']),
                  };
                }).toList(),
          'triggerKind': C.toLspCodeActionTriggerKind(context['trigger']),
        },
      },
    );
    if (result == null) return null;

    // 1:1: `Array.isArray(result) ? result : [result]`
    final actions = result is List ? result : <Object?>[result];
    final output = <Object?>[];
    for (final action in actions) {
      final a = action as Map<String, Object?>;
      if (a.containsKey('title') && !a.containsKey('kind')) {
        // Command
        final command = _client.commands.toMonacoCommand(CommandCarrier(a));
        if (command == null) continue;
        output.add(<String, Object?>{
          'title': a['title'],
          'command': command,
        });
      } else {
        // CodeAction
        final edit = a['edit'];
        output.add(<String, Object?>{
          'title': a['title'],
          'kind': C.toMonacoCodeActionKind(a['kind']),
          'isPreferred': a['isPreferred'],
          'disabled': a['disabled'] == null
              ? null
              : (a['disabled'] as Map<String, Object?>)['reason'],
          'edit': edit == null ? null : _toMonacoWorkspaceEdit(edit, _client),
          'command': _client.commands.toMonacoCommand(CommandCarrier(a['command'] as Map<String, Object?>)),
          '_lspAction': a,
        });
      }
    }
    return <String, Object?>{
      'actions': output,
      'dispose': () {},
    };
  }
}

/// 1:1: `toMonacoWorkspaceEdit`
Map<String, Object?> _toMonacoWorkspaceEdit(
  Object? edit,
  LspConnection client,
) {
  final e = edit as Map<String, Object?>;
  final edits = <Object?>[];

  final changes = e['changes'];
  if (changes != null) {
    for (final entry in (changes as Map<String, Object?>).entries) {
      final uri = entry.key;
      for (final textEdit in entry.value as List) {
        final te = textEdit as Map<String, Object?>;
        final translated = client.bridge.translateBackRange(
          LspTextDocumentIdentifier(uri),
          C.lspRangeFromMap(te['range']),
        );
        edits.add(<String, Object?>{
          'resource': translated.textModel.getUri(),
          'versionId': null,
          'textEdit': <String, Object?>{
            'range': translated.range,
            'text': te['newText'],
          },
        });
      }
    }
  }

  final documentChanges = e['documentChanges'];
  if (documentChanges != null) {
    for (final change in documentChanges as List) {
      final c = change as Map<String, Object?>;
      if (c.containsKey('textDocument')) {
        final textDocument = c['textDocument'] as Map<String, Object?>;
        final uri = textDocument['uri'] as String;
        for (final textEdit in c['edits'] as List) {
          final te = textEdit as Map<String, Object?>;
          final translated = client.bridge.translateBackRange(
            LspTextDocumentIdentifier(uri),
            C.lspRangeFromMap(te['range']),
          );
          edits.add(<String, Object?>{
            'resource': translated.textModel.getUri(),
            'versionId': textDocument['version'] ?? null,
            'textEdit': <String, Object?>{
              'range': translated.range,
              'text': te['newText'],
            },
          });
        }
      }
    }
  }

  return <String, Object?>{'edits': edits};
}
