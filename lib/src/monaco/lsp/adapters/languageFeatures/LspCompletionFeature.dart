// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspCompletionFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../ITextModelBridge.dart' show assertRangeTarget, assertPositionTarget;
import '../LspConnection.dart' show CommandCarrier, LspConnection;
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspCompletionFeature extends Disposable`
class LspCompletionFeature extends Disposable {
  LspCompletionFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'completion': <String, dynamic>{
          'dynamicRegistration': true,
          'contextSupport': true,
          'completionItemKind': <String, dynamic>{
            'valueSet': C.lspCompletionItemKindToMonacoCompletionItemKind.keys.toList(),
          },
          'completionItem': <String, dynamic>{
            'tagSupport': <String, dynamic>{
              'valueSet': C.lspCompletionItemTagToMonacoCompletionItemTag.keys.toList(),
            },
            'commitCharactersSupport': true,
            'deprecatedSupport': true,
            'preselectSupport': true,
          },
        },
      },
    }));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentCompletion']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        return registerMonacoProvider(
          'registerCompletionItemProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          _LspCompletionProvider(connection, cap),
        );
      },
    ));
  }
}

class _LspCompletionProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;

  /// 1:1: `resolveCompletionItem` assigned only when resolveProvider is set.
  Future<Map<String, Object?>?> Function(Map<String, Object?>, Object?)?
      resolveCompletionItem;

  _LspCompletionProvider(this._client, this._capabilities) {
    if (_capabilities['resolveProvider'] == true) {
      resolveCompletionItem = (item, token) async {
        final lspItem = item['_lspItem'] as Map<String, Object?>;
        final resolved = await _client.server
            .completionItemResolve(lspItem);
        if (resolved != null) {
          _applyLspCompletionItemProperties(
            item,
            resolved as Map<String, Object?>,
            _client,
            item['_translated'],
            item['_model'] as IMonacoTextModel,
          );
        }
        return item;
      };
    }
  }

  /// 1:1: `triggerCharacters` getter.
  List<String>? get triggerCharacters =>
      (_capabilities['triggerCharacters'] as List?)?.cast<String>();

  /// 1:1: `provideCompletionItems`
  Future<Object?> provideCompletionItems(
    IMonacoTextModel model,
    MonacoPosition position,
    Map<String, Object?> context,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, position);
    final triggerCharacter = context['triggerCharacter'];
    final result = await _client.server.textDocumentCompletion(
      <String, Object?>{
        'textDocument': translated.textDocument,
        'position': translated.position,
        'context': triggerCharacter == null
            ? null
            : <String, Object?>{
                'triggerKind': C.toLspCompletionTriggerKind(context['triggerKind']),
                'triggerCharacter': triggerCharacter,
              },
      },
    );
    if (result == null) {
      return <String, Object?>{'suggestions': <Object?>[]};
    }

    final items = result is List
        ? result
        : (result as Map<String, Object?>)['items'] as List;
    return <String, Object?>{
      'suggestions': items.map<Object?>((i) {
        final lspItem = i as Map<String, Object?>;
        final item = _convertLspToMonacoCompletionItem(
          lspItem,
          _client,
          translated.textDocument,
          model,
          position,
        );
        item['_lspItem'] = lspItem;
        item['_translated'] = translated;
        item['_model'] = model;
        return item;
      }).toList(),
    };
  }
}

/// 1:1: `convertLspToMonacoCompletionItem`
Map<String, Object?> _convertLspToMonacoCompletionItem(
  Map<String, Object?> lspItem,
  LspConnection client,
  T.TextDocumentIdentifier textDocument,
  IMonacoTextModel model,
  MonacoPosition position,
) {
  final bridge = client.bridge;
  Object? insertText = lspItem['insertText'] ?? lspItem['label'];
  Object? range;

  final textEdit = lspItem['textEdit'];
  if (textEdit != null) {
    final te = textEdit as Map<String, Object?>;
    if (te.containsKey('range')) {
      insertText = te['newText'];
      range = assertRangeTarget(
        bridge.translateBackRange(textDocument, C.lspRangeFromMap(te['range'])),
        model,
      );
    } else {
      insertText = te['newText'];
      range = <String, Object?>{
        'insert': assertRangeTarget(
          bridge.translateBackRange(textDocument, C.lspRangeFromMap(te['insert'])),
          model,
        ),
        'replace': assertRangeTarget(
          bridge.translateBackRange(textDocument, C.lspRangeFromMap(te['replace'])),
          model,
        ),
      };
    }
  }

  if (range == null) {
    range = monacoRangeFromPositions(position, position);
  }

  final item = <String, Object?>{
    'label': lspItem['label'],
    'kind': C.toMonacoCompletionItemKind(lspItem['kind']),
    'insertText': insertText,
    'sortText': lspItem['sortText'],
    'filterText': lspItem['filterText'],
    'preselect': lspItem['preselect'],
    'commitCharacters': lspItem['commitCharacters'],
    'range': range,
  };

  _applyLspCompletionItemProperties(item, lspItem, client, textDocument, model);
  return item;
}

/// 1:1: `applyLspCompletionItemProperties`
void _applyLspCompletionItemProperties(
  Map<String, Object?> monacoItem,
  Map<String, Object?> lspItem,
  LspConnection client,
  Object? translated,
  IMonacoTextModel targetModel,
) {
  final bridge = client.bridge;
  // 1:1: `translated: TextDocumentPositionParams` — either the bridge record
  // (`{textDocument, position}`) or a bare TextDocumentIdentifier carrier.
  final T.TextDocumentIdentifier td;
  if (translated is T.TextDocumentIdentifier) {
    td = translated;
  } else if (translated is ({T.TextDocumentIdentifier textDocument, T.Position position})) {
    td = translated.textDocument;
  } else {
    td = (translated as Map<String, Object?>)['textDocument']
        as T.TextDocumentIdentifier;
  }

  if (lspItem.containsKey('detail')) {
    monacoItem['detail'] = lspItem['detail'];
  }
  if (lspItem.containsKey('documentation')) {
    monacoItem['documentation'] = _toMonacoDocumentation(lspItem['documentation']);
  }
  if (lspItem.containsKey('insertTextFormat')) {
    monacoItem['insertTextRules'] =
        C.toMonacoInsertTextRules(lspItem['insertTextFormat']);
  }
  final tags = lspItem['tags'];
  if (tags is List && tags.isNotEmpty) {
    monacoItem['tags'] = tags
        .map((tag) => C.toMonacoCompletionItemTag(tag))
        .where((tag) => tag != null)
        .toList();
  }
  final additional = lspItem['additionalTextEdits'];
  if (additional is List && additional.isNotEmpty) {
    monacoItem['additionalTextEdits'] = additional.map<Object?>((edit) {
      final e = edit as Map<String, Object?>;
      return <String, Object?>{
        'range': assertRangeTarget(
          bridge.translateBackRange(td, C.lspRangeFromMap(e['range'])),
          targetModel,
        ),
        'text': e['newText'],
      };
    }).toList();
  }
  if (lspItem['command'] != null) {
    monacoItem['command'] =
        client.commands.toMonacoCommand(CommandCarrier(lspItem['command'] as Map<String, Object?>));
  }
}

/// 1:1: `toMonacoDocumentation`
Object? _toMonacoDocumentation(Object? doc) {
  if (doc == null) return null;
  if (doc is String) return doc;
  return C.toUntrustedMarkdownString((doc as Map<String, Object?>)['value'] as String);
}
