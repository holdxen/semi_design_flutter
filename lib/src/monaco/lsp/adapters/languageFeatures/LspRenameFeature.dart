// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspRenameFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../TextDocumentSynchronizer.dart' show LspTextDocumentIdentifier;
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspRenameFeature extends Disposable`
class LspRenameFeature extends Disposable {
  LspRenameFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'rename': <String, dynamic>{
          'dynamicRegistration': true,
          'prepareSupport': true,
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentRename']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerRenameProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspRenameProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspRenameProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;
  _LspRenameProvider(this._client, this._capabilities);

  /// 1:1: `provideRenameEdits`
  Future<Object?> provideRenameEdits(
    IMonacoTextModel model,
    MonacoPosition position,
    String newName,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentRename(<String, Object?>{
      'textDocument': translated.textDocument,
      'position': translated.position,
      'newName': newName,
    });
    if (result == null) return null;
    return _toMonacoWorkspaceEdit(result, _client);
  }

  /// 1:1: `resolveRenameLocation`
  Future<Object?> resolveRenameLocation(
    IMonacoTextModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    if (_capabilities['prepareProvider'] != true) return null;

    final translated = _client.bridge.translate(model, position);
    final result = await _client.server.textDocumentPrepareRename(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'position': translated.position,
      },
    );
    if (result == null) return null;
    final r = result as Map<String, Object?>;

    if (r.containsKey('range') && r.containsKey('placeholder')) {
      return <String, Object?>{
        'range': _client.bridge
            .translateBackRange(
              translated.textDocument,
              C.lspRangeFromMap(r['range']),
            )
            .range,
        'text': r['placeholder'],
      };
    } else if (r.containsKey('defaultBehavior')) {
      return null;
    } else if (r.containsKey('start') && r.containsKey('end')) {
      final range = _client.bridge
          .translateBackRange(translated.textDocument, C.lspRangeFromMap(r))
          .range;
      return <String, Object?>{
        'range': range,
        'text': model.getValueInRange(range),
      };
    }
    return null;
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
        // TextDocumentEdit
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
            'versionId': textDocument['version'],
            'textEdit': <String, Object?>{
              'range': translated.range,
              'text': te['newText'],
            },
          });
        }
      }
      // TODO: Handle CreateFile, RenameFile, DeleteFile (1:1 with source).
    }
  }

  return <String, Object?>{'edits': edits};
}
