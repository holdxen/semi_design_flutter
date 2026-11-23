// 1:1 port of monaco-lsp-client/src/adapters/TextDocumentSynchronizer.ts
// Bridges: monaco editor API -> monacoEditorApi.dart provider slots;
// api.TServerInterface -> IServerInterface; ITextModelBridge -> ported file.
import '../types.dart' as T;
import '../utils.dart';
import 'ITextModelBridge.dart' show ITextModelBridge;
import 'LspCapabilitiesRegistry.dart' show ILspCapabilitiesRegistry;
import 'monacoBridge.dart';
import 'monacoEditorApi.dart';

/// 1:1: LSP range carrier `{start:{line,character}, end:{...}}`.
class LspRange implements T.Range {
  @override
  final T.Position start;
  @override
  final T.Position end;
  LspRange(this.start, this.end);
}

/// 1:1: LSP position `{line, character}` — implements the types.dart
/// declaration so runtime values satisfy the ITextModelBridge signature.
class LspPos implements T.Position {
  @override
  final int line;
  @override
  final int character;
  const LspPos(this.line, this.character);
  Map<String, Object?> toJson() => <String, Object?>{'line': line, 'character': character};
}

/// 1:1: LSP `TextDocumentIdentifier { uri }` value carrier.
class LspTextDocumentIdentifier implements T.TextDocumentIdentifier {
  @override
  final String uri;
  LspTextDocumentIdentifier(this.uri);
}

/// 1:1: LSP `Range { start, end }` value carrier.
class LspRangeValue implements T.Range {
  @override
  final T.Position start;
  @override
  final T.Position end;
  LspRangeValue(this.start, this.end);
}

/// 1:1: `function toLspRange(range: monaco.IRange): Range`
LspRange toLspRange(MonacoRange range) {
  return LspRange(
    LspPos(range.startLineNumber - 1, range.startColumn - 1),
    LspPos(range.endLineNumber - 1, range.endColumn - 1),
  );
}

/// 1:1: `function toLspTextDocumentContentChangeEvent(change)`
Map<String, Object?> toLspTextDocumentContentChangeEvent(ModelContentChange change) {
  return <String, Object?>{
    'range': toLspRange(change.range!),
    'rangeLength': change.rangeLength,
    'text': change.text,
  };
}

/// 1:1: `class ManagedModel extends Disposable`
class ManagedModel extends Disposable {
  final IManagedTextModel _textModel;
  final IServerInterface _api;
  final String _uri;

  ManagedModel(this._textModel, this._api)
      : _uri = _textModel.uriString(true).toLowerCase(),
        super() {
    _api.textDocumentDidOpen(<String, Object?>{
      'textDocument': <String, Object?>{
        'languageId': _textModel.getLanguageId(),
        'uri': _uri,
        'version': _textModel.getVersionId(),
        'text': _textModel.getValue(),
      },
    });

    register(_textModel.onDidChangeContent((e) {
      final contentChanges = e.changes.map(toLspTextDocumentContentChangeEvent).toList();
      _api.textDocumentDidChange(<String, Object?>{
        'textDocument': <String, Object?>{'uri': _uri, 'version': _textModel.getVersionId()},
        'contentChanges': contentChanges,
      });
    }));

    register(_LambdaDisposable(() {
      _api.textDocumentDidClose(<String, Object?>{
        'textDocument': <String, Object?>{'uri': _uri},
      });
    }));
  }
}

/// 1:1: `export class TextDocumentSynchronizer extends Disposable implements ITextModelBridge`
class TextDocumentSynchronizer extends Disposable implements ITextModelBridge {
  final Map<IMonacoTextModel, ManagedModel> _managedModels =
      <IMonacoTextModel, ManagedModel>{};
  final Map<String, IMonacoTextModel> _managedModelsReverse =
      <String, IMonacoTextModel>{};
  bool _started = false;

  final IServerInterface _server;
  final ILspCapabilitiesRegistry _capabilities;

  TextDocumentSynchronizer(this._server, this._capabilities) : super() {
    register(_capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'synchronization': <String, dynamic>{
          'dynamicRegistration': true,
          'willSave': false,
          'willSaveWaitUntil': false,
          'didSave': false,
        },
      },
    }));

    register(_capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentDidChange']!,
      true,
      (e) {
        if (_started) {
          return _LambdaDisposable(() {});
        }
        _started = true;
        register(onDidCreateModelProvider((m) {
          _getOrCreateManagedModel(m);
        }));
        for (final m in getModelsProvider()) {
          _getOrCreateManagedModel(m);
        }
        return _LambdaDisposable(() {});
      },
    ));
  }

  /// 1:1: `private _getOrCreateManagedModel(m)`
  ManagedModel _getOrCreateManagedModel(IManagedTextModel m) {
    if (!_started) {
      throw StateError('Not started');
    }
    final uriStr = m.uriString(true).toLowerCase();
    var mm = _managedModels[m];
    if (mm == null) {
      mm = ManagedModel(m, _server);
      _managedModels[m] = mm;
      _managedModelsReverse[uriStr] = m;
    }
    m.onWillDispose(() {
      mm!.dispose();
      _managedModels.remove(m);
      _managedModelsReverse.remove(uriStr);
    });
    return mm;
  }

  /// test hook: start synchronization manually (TS starts on didChange handler).
  void startForTest() {
    _started = true;
  }

  /// test hook: manage a model directly.
  ManagedModel getOrCreateManagedModelForTest(IManagedTextModel m) =>
      _getOrCreateManagedModel(m);

  @override
  ({IMonacoTextModel textModel, MonacoPosition position}) translateBack(
    T.TextDocumentIdentifier textDocument,
    T.Position position,
  ) {
    final uri = (_uriOf(textDocument)).toLowerCase();
    final textModel = _managedModelsReverse[uri];
    if (textModel == null) {
      throw StateError('No text model for uri $uri');
    }
    // LSP (0-based) -> monaco (1-based)
    final monacoPosition = MonacoPosition(
      (position.line as num).toInt() + 1,
      (position.character as num).toInt() + 1,
    );
    return (textModel: textModel, position: monacoPosition);
  }

  @override
  ({IMonacoTextModel textModel, MonacoRange range}) translateBackRange(
    T.TextDocumentIdentifier textDocument,
    T.Range range,
  ) {
    final uri = (_uriOf(textDocument)).toLowerCase();
    final textModel = _managedModelsReverse[uri];
    if (textModel == null) {
      throw StateError('No text model for uri $uri');
    }
    final start = _posOf(range.start);
    final end = _posOf(range.end);
    final monacoRange = MonacoRange(
      start.line + 1,
      start.character + 1,
      end.line + 1,
      end.character + 1,
    );
    return (textModel: textModel, range: monacoRange);
  }

  @override
  ({T.TextDocumentIdentifier textDocument, T.Position position}) translate(
    IMonacoTextModel textModel,
    MonacoPosition monacoPos,
  ) {
    return (
      textDocument: LspTextDocumentIdentifier(textModel.uriString(true)),
      position: LspPos(monacoPos.lineNumber - 1, monacoPos.column - 1),
    );
  }

  @override
  T.Range translateRange(IMonacoTextModel textModel, MonacoRange monacoRange) =>
      toLspRange(monacoRange);

  String _uriOf(T.TextDocumentIdentifier id) => (id.uri is String) ? id.uri as String : '';

  LspPos _posOf(Object? p) {
    if (p is LspPos) return p;
    if (p is Map) return LspPos((p['line'] as int?) ?? 0, (p['character'] as int?) ?? 0);
    // types.dart Position getter surface: read via dynamic for runtime carriers.
    final dyn = p as dynamic;
    return LspPos(dyn.line as int, dyn.character as int);
  }
}

class _LambdaDisposable implements IDisposable {
  final void Function() _d;
  _LambdaDisposable(this._d);
  @override
  void dispose() => _d();
}
