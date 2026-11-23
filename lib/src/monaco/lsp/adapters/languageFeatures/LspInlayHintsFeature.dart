// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspInlayHintsFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../ITextModelBridge.dart' show assertRangeTarget, assertPositionTarget;
import '../LspConnection.dart' show CommandCarrier, LspConnection;
import '../TextDocumentSynchronizer.dart' show LspTextDocumentIdentifier;
import '../monacoBridge.dart';
import '../monacoEditorApi.dart';
import 'common.dart' as C;

/// 1:1: `export class LspInlayHintsFeature extends Disposable`
class LspInlayHintsFeature extends Disposable {
  final Set<_LspInlayHintsProvider> _providers = <_LspInlayHintsProvider>{};

  LspInlayHintsFeature(LspConnection connection) : super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'inlayHint': <String, dynamic>{
          'dynamicRegistration': true,
          'resolveSupport': <String, dynamic>{
            'properties': <Object?>[
              'tooltip',
              'textEdits',
              'label.tooltip',
              'label.location',
              'label.command',
            ],
          },
        },
      },
      'workspace': <String, dynamic>{
        'inlayHint': <String, dynamic>{'refreshSupport': true},
      },
    }));

    register(connection.connection.registerRequestHandler(
      T.api.client['workspaceInlayHintRefresh']!,
      (params) async {
        // Fire onDidChangeInlayHints for all providers.
        for (final provider in _providers) {
          provider.refresh();
        }
        return <String, Object?>{'ok': null};
      },
    ));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentInlayHint']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        final provider = _LspInlayHintsProvider(connection, cap);
        _providers.add(provider);
        final disposable = registerMonacoProvider(
          'registerInlayHintsProvider',
          C.toMonacoLanguageSelector(cap['documentSelector']),
          provider,
        );
        return _LambdaDisposable(() {
          _providers.remove(provider);
          disposable.dispose();
        });
      },
    ));
  }
}

/// Anonymous disposable from a lambda (TS object literal `{ dispose: () => {} }`).
class _LambdaDisposable implements IDisposable {
  final void Function() _dispose;
  _LambdaDisposable(this._dispose);
  @override
  void dispose() => _dispose();
}

class _LspInlayHintsProvider {
  final LspConnection _client;
  final Map<String, Object?> _capabilities;

  final MonacoEmitter<void> _onDidChangeInlayHints = MonacoEmitter<void>();
  late final void Function(void Function(void)) onDidChangeInlayHints;

  /// 1:1: `resolveInlayHint` assigned only when resolveProvider is set.
  Future<Map<String, Object?>?> Function(Map<String, Object?>, Object?)?
      resolveInlayHint;

  _LspInlayHintsProvider(this._client, this._capabilities) {
    onDidChangeInlayHints = _onDidChangeInlayHints.event;
    if (_capabilities['resolveProvider'] == true) {
      resolveInlayHint = (hint, token) async {
        final lspHint = hint['_lspInlayHint'] as Map<String, Object?>;
        final resolved = await _client.server.inlayHintResolve(lspHint);
        if (resolved == null) return hint;
        final r = resolved as Map<String, Object?>;
        if (r['tooltip'] != null) {
          hint['tooltip'] = _toMonacoTooltip(r['tooltip']);
        }
        if (r['label'] != lspHint['label']) {
          hint['label'] = _toLspInlayHintLabel(r['label'], _client);
        }
        if (r['textEdits'] != null) {
          hint['textEdits'] = (r['textEdits'] as List).map<Object?>((edit) {
            final e = edit as Map<String, Object?>;
            final translated = _client.bridge.translateBackRange(
              LspTextDocumentIdentifier(hint['_targetUri'] as String),
              C.lspRangeFromMap(e['range']),
            );
            return <String, Object?>{
              'range': translated.range,
              'text': e['newText'],
            };
          }).toList();
        }
        return hint;
      };
    }
  }

  /// 1:1: `refresh`
  void refresh() => _onDidChangeInlayHints.fire(null);

  /// 1:1: `provideInlayHints`
  Future<Object?> provideInlayHints(
    IMonacoTextModel model,
    MonacoRange range,
    Object? token,
  ) async {
    final translated = _client.bridge.translate(model, range.getStartPosition());
    final result = await _retryOnContentModified(() =>
        _client.server.textDocumentInlayHint(<String, Object?>{
          'textDocument': translated.textDocument,
          'range': _client.bridge.translateRange(model, range),
        }));
    if (result == null) return null;
    return <String, Object?>{
      'hints': (result as List).map<Object?>((hint) {
        final h = hint as Map<String, Object?>;
        final textEdits = h['textEdits'];
        return <String, Object?>{
          'label': _toLspInlayHintLabel(h['label'], _client),
          'position': assertPositionTarget(
            _client.bridge.translateBack(
              translated.textDocument,
              C.lspPositionFromMap(h['position']),
            ),
            model,
          ),
          'kind': C.toMonacoInlayHintKind(h['kind']),
          'tooltip': _toMonacoTooltip(h['tooltip']),
          'paddingLeft': h['paddingLeft'],
          'paddingRight': h['paddingRight'],
          'textEdits': textEdits == null
              ? null
              : (textEdits as List).map<Object?>((edit) {
                  final e = edit as Map<String, Object?>;
                  return <String, Object?>{
                    'range': assertRangeTarget(
                      _client.bridge.translateBackRange(
                        translated.textDocument,
                        C.lspRangeFromMap(e['range']),
                      ),
                      model,
                    ),
                    'text': e['newText'],
                  };
                }).toList(),
          '_lspInlayHint': h,
          '_targetUri': (translated.textDocument as T.TextDocumentIdentifier).uri,
        };
      }).toList(),
      'dispose': () {},
    };
  }
}

/// 1:1: `retryOnContentModified` — 3 retries on 'content modified'.
Future<T> _retryOnContentModified<T>(Future<T> Function() cb) async {
  const nRetries = 3;
  var triesLeft = nRetries;
  while (true) {
    try {
      return await cb();
    } catch (e) {
      final message = e is Map ? e['message'] : e.toString();
      if (message == 'content modified' && triesLeft > 0) {
        triesLeft--;
        continue;
      }
      rethrow;
    }
  }
}

/// 1:1: `toLspInlayHintLabel`
Object? _toLspInlayHintLabel(Object? label, LspConnection client) {
  if (label is String) return label;
  return (label as List).map<Object?>((part) {
    final p = part as Map<String, Object?>;
    final monacoLabelPart = <String, Object?>{
      'label': p['value'],
      'tooltip': _toMonacoTooltip(p['tooltip']),
      'command': p['command'] == null
          ? null
          : client.commands.toMonacoCommand(CommandCarrier(p['command'] as Map<String, Object?>)),
    };
    final location = p['location'];
    if (location != null) {
      final loc = location as Map<String, Object?>;
      final r = loc['range'] as Map<String, Object?>;
      final start = r['start'] as Map<String, Object?>;
      final end = r['end'] as Map<String, Object?>;
      monacoLabelPart['location'] = <String, Object?>{
        'uri': parseUri(loc['uri'] as String),
        'range': MonacoRange(
          (start['line'] as num).toInt() + 1,
          (start['character'] as num).toInt() + 1,
          (end['line'] as num).toInt() + 1,
          (end['character'] as num).toInt() + 1,
        ),
      };
    }
    return monacoLabelPart;
  }).toList();
}

/// 1:1: `toMonacoTooltip`
Object? _toMonacoTooltip(Object? tooltip) {
  if (tooltip == null) return null;
  if (tooltip is String) return tooltip;
  return C.toUntrustedMarkdownString((tooltip as Map<String, Object?>)['value'] as String);
}
