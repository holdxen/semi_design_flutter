// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/LspDiagnosticsFeature.ts
library;

import '../../types.dart' as T;
import '../../utils.dart';
import '../LspConnection.dart';
import '../TextDocumentSynchronizer.dart' show LspTextDocumentIdentifier, LspPos, LspRange;
import '../monacoBridge.dart';
import '../monacoEditorApi.dart' as M;
import '../monacoEditorApi.dart' show IManagedTextModel;
import '../monacoEditorApi.dart' show setModelMarkers, setTimeout, clearTimeout, consoleDebug, consoleError;
import 'common.dart' as C;

/// 1:1: `export class LspDiagnosticsFeature extends Disposable`
class LspDiagnosticsFeature extends Disposable {
  /// 1:1: `private readonly _diagnosticsMarkerOwner = 'lsp'`
  final String _diagnosticsMarkerOwner = 'lsp';

  /// 1:1: `Map<ITextModel, ModelDiagnosticProvider>`
  final Map<IMonacoTextModel, _ModelDiagnosticProvider> _pullDiagnosticProviders =
      <IMonacoTextModel, _ModelDiagnosticProvider>{};

  /// The connection captured at construction for the provider factory.
  final LspConnection _lspConnection;

  LspDiagnosticsFeature(LspConnection connection)
      : _lspConnection = connection,
        super() {
    register(connection.capabilities.addStaticClientCapabilities(<String, dynamic>{
      'textDocument': <String, dynamic>{
        'publishDiagnostics': <String, dynamic>{
          'relatedInformation': true,
          'tagSupport': <String, dynamic>{
            'valueSet': C.lspDiagnosticTagToMonacoMarkerTag.keys.toList(),
          },
          'versionSupport': true,
          'codeDescriptionSupport': true,
          'dataSupport': true,
        },
        'diagnostic': <String, dynamic>{
          'dynamicRegistration': true,
          'relatedDocumentSupport': true,
        },
      },
    }));

    register(connection.connection.registerNotificationHandler(
      T.api.client['textDocumentPublishDiagnostics']!,
      (params) => _handlePublishDiagnostics(params),
    ));

    register(connection.capabilities.registerCapabilityHandler<dynamic>(
      T.capabilities['textDocumentDiagnostic']!,
      true,
      (capability) {
        final cap = capability as Map<String, Object?>;
        final disposables = DisposableStore();
        for (final model in M.getModels()) {
          _addPullDiagnosticProvider(model, cap, disposables);
        }
        disposables.add(M.onDidCreateModel((model) {
          _addPullDiagnosticProvider(model, cap, disposables);
        }));
        return disposables;
      },
    ));
  }

  /// 1:1: `_addPullDiagnosticProvider`
  void _addPullDiagnosticProvider(
    IMonacoTextModel model,
    Map<String, Object?> capability,
    DisposableStore disposables,
  ) {
    // 1:1: `const languageId = model.getLanguageId()` (read for parity).
    // ignore: unused_local_variable
    final languageId = model.getLanguageId();
    if (!C.matchesDocumentSelector(model, capability['documentSelector'])) {
      return;
    }

    final provider = _ModelDiagnosticProvider(
      model,
      _lspConnection,
      _diagnosticsMarkerOwner,
      capability,
    );
    _pullDiagnosticProviders[model] = provider;
    disposables.add(provider);
    if (model is IManagedTextModel) {
      disposables.add(model.onWillDispose(() {
        _pullDiagnosticProviders.remove(model);
      }));
    }
  }


  /// 1:1: `_handlePublishDiagnostics`
  void _handlePublishDiagnostics(Object? params) {
    final p = params as Map<String, Object?>;
    final uri = p['uri'] as String;
    try {
      final translated = _lspConnection.bridge.translateBack(
        LspTextDocumentIdentifier(uri),
        _zeroPosition,
      );
      final model = translated.textModel;
      if (model.isDisposed()) return;

      final markers = (p['diagnostics'] as List)
          .map((diagnostic) => C.toDiagnosticMarker(diagnostic))
          .toList();
      setModelMarkers(model, _diagnosticsMarkerOwner, markers);
    } catch (error) {
      // Model not found or already disposed — normal when files are closed.
      consoleDebug('Could not set diagnostics for $uri:', error);
    }
  }
}

/// 1:1: `ModelDiagnosticProvider extends Disposable`
class _ModelDiagnosticProvider extends Disposable {
  final IMonacoTextModel _model;
  final LspConnection _connection;
  final String _markerOwner;
  final Map<String, Object?> _capability;

  Object? _updateHandle;
  String? _previousResultId;

  _ModelDiagnosticProvider(
    this._model,
    this._connection,
    this._markerOwner,
    this._capability,
  ) {
    if (_model is IManagedTextModel) {
      register(_model.onDidChangeContent((event) {
        _scheduleDiagnosticUpdate();
      }));
    }
    _scheduleDiagnosticUpdate();
  }

  /// 1:1: `_scheduleDiagnosticUpdate` — 500ms debounce via injected timer.
  void _scheduleDiagnosticUpdate() {
    if (_updateHandle != null) {
      clearTimeout(_updateHandle!);
    }
    _updateHandle = setTimeout(() {
      _updateHandle = null;
      _requestDiagnostics();
    }, 500);
  }

  /// 1:1: `_requestDiagnostics`
  Future<void> _requestDiagnostics() async {
    if (_model.isDisposed()) return;
    try {
      final translated = _connection.bridge.translate(
        _model,
        const MonacoPosition(1, 1),
      );
      final result = await _connection.server.textDocumentDiagnostic(
        <String, Object?>{
          'textDocument': translated.textDocument,
          'identifier': _capability['identifier'],
          'previousResultId': _previousResultId,
        },
      );
      if (_model.isDisposed()) return;
      _handleDiagnosticReport(result);
    } catch (error) {
      consoleError('Error requesting diagnostics:', error);
    }
  }

  /// 1:1: `_handleDiagnosticReport`
  void _handleDiagnosticReport(Object? report) {
    if (report == null) return;
    final r = report as Map<String, Object?>;
    if (r['kind'] == 'full') {
      _previousResultId = r['resultId'] as String?;
      final markers = (r['items'] as List)
          .map((diagnostic) => C.toDiagnosticMarker(diagnostic))
          .toList();
      setModelMarkers(_model, _markerOwner, markers);
      final related = r['relatedDocuments'];
      if (related != null) {
        _handleRelatedDocuments(related as Map<String, Object?>);
      }
    } else if (r['kind'] == 'unchanged') {
      _previousResultId = r['resultId'] as String?;
      // No need to update markers.
    }
  }

  /// 1:1: `_handleRelatedDocuments`
  void _handleRelatedDocuments(Map<String, Object?> relatedDocuments) {
    for (final entry in relatedDocuments.entries) {
      final uri = entry.key;
      final report = entry.value;
      try {
        final translated = _connection.bridge.translateBack(
          LspTextDocumentIdentifier(uri),
          _zeroPosition,
        );
        final model = translated.textModel;
        if (model.isDisposed()) continue;
        final r = report as Map<String, Object?>;
        if (r['kind'] == 'full') {
          final markers = (r['items'] as List)
              .map((diagnostic) => C.toDiagnosticMarker(diagnostic))
              .toList();
          setModelMarkers(model, _markerOwner, markers);
        }
      } catch (error) {
        consoleDebug('Could not set related diagnostics for $uri:', error);
      }
    }
  }

  @override
  void dispose() {
    if (_updateHandle != null) {
      clearTimeout(_updateHandle!);
      _updateHandle = null;
    }
    super.dispose();
  }
}

/// 1:1: LSP `{line:0, character:0}` position carrier used for translateBack.
final T.Position _zeroPosition = LspPos(0, 0);
