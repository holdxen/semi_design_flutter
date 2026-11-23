// Carrier bridges for `monaco-editor-core` editor API + the LSP
// `api.TServerInterface` referenced by LspCommands / TextDocumentSynchronizer
// but not ported into the Dart tree. No behavior is invented: these are opaque
// function slots / value carriers mirroring the TS surface.
import '../utils.dart';
import 'monacoBridge.dart';

/// 1:1 carrier of `api.TServerInterface` methods used by the adapters.
abstract class IServerInterface {
  Future<Object?> workspaceExecuteCommand(Map<String, Object?> params);
  Future<Object?> textDocumentDidOpen(Map<String, Object?> params);
  Future<Object?> textDocumentDidChange(Map<String, Object?> params);
  Future<Object?> textDocumentDidClose(Map<String, Object?> params);
}

/// A model content change (`monaco.editor.IModelContentChange`).
class ModelContentChange {
  final MonacoRange? range; // null for full-document sync
  final int? rangeLength;
  final String text;
  ModelContentChange(this.range, this.rangeLength, this.text);
}

/// Content-change event payload.
class ModelContentChangedEvent {
  final List<ModelContentChange> changes;
  ModelContentChangedEvent(this.changes);
}

/// ITextModel surface used by ManagedModel (extends the minimal bridge).
abstract class IManagedTextModel implements IMonacoTextModel {
  /// uri.toString(true)
  String uriString(bool verbose);

  /// model value
  String getValue();

  /// register onWillDispose listener
  IDisposable onWillDispose(void Function() listener);

  /// register onDidChangeContent listener
  IDisposable onDidChangeContent(void Function(ModelContentChangedEvent e) listener);
}

/// Simple testable managed model.
class SimpleManagedModel implements IManagedTextModel {
  @override
  final String languageId;
  @override
  final int versionId;
  final String _uri;
  String value;
  final List<void Function()> _disposeListeners = <void Function()>[];
  final List<void Function(ModelContentChangedEvent)> _changeListeners =
      <void Function(ModelContentChangedEvent)>[];

  SimpleManagedModel({required this.languageId, required String uri, this.value = '', this.versionId = 1})
      : _uri = uri;

  @override
  String getLanguageId() => languageId;

  @override
  int getVersionId() => versionId;

  @override
  Object? getUri() => _uri;

  @override
  String uriString(bool verbose) => _uri;

  @override
  String getValue() => value;

  @override
  IDisposable onWillDispose(void Function() listener) {
    _disposeListeners.add(listener);
    return _ListenerDisposable(_disposeListeners, listener);
  }

  @override
  IDisposable onDidChangeContent(void Function(ModelContentChangedEvent e) listener) {
    _changeListeners.add(listener);
    return _ChangeListenerDisposable(_changeListeners, listener);
  }

  /// test helper: emit a content change to all listeners
  void emitChange(ModelContentChangedEvent e) {
    for (final l in List<void Function(ModelContentChangedEvent)>.from(_changeListeners)) {
      l(e);
    }
  }

  /// test helper: fire dispose listeners
  void fireWillDispose() {
    for (final l in List<void Function()>.from(_disposeListeners)) {
      l();
    }
  }
}

class _ListenerDisposable implements IDisposable {
  final List<void Function()> list;
  final void Function() cb;
  _ListenerDisposable(this.list, this.cb);
  @override
  void dispose() => list.remove(cb);
}

class _ChangeListenerDisposable implements IDisposable {
  final List<void Function(ModelContentChangedEvent)> list;
  final void Function(ModelContentChangedEvent) cb;
  _ChangeListenerDisposable(this.list, this.cb);
  @override
  void dispose() => list.remove(cb);
}

/// bridge: `monaco.editor.registerCommand(id, handler): IDisposable`
IDisposable Function(String id, Object? Function(Object? accessor, Object? command, Object? args) handler)
    registerCommandProvider = (id, handler) => Disposable();

/// bridge: `monaco.editor.onDidCreateModel(cb): IDisposable`
IDisposable Function(void Function(IManagedTextModel model) cb) onDidCreateModelProvider =
    (cb) => Disposable();

/// bridge: `monaco.editor.getModels(): ITextModel[]`
List<IManagedTextModel> Function() getModelsProvider = () => <IManagedTextModel>[];

/// Test helper: look up a registered command handler by id (via provider override).
Object? Function(Object? accessor, Object? command, Object? args)? commandHandlerFor(String id) => null;

// ===========================================================================
// batch50: monaco-editor-core carrier slots for language features.
// All TS `monaco.*` calls are preserved 1:1 at the call+argument level; the
// concrete editor implementation is not ported, so each call routes through an
// injectable slot/hook. Extensions are used (not interface members) so no
// already-tested class (SimpleTextModel / _Server / SimpleManagedModel) needs
// to change — Dart instance members always win over an extension of the same
// name, which is exactly the intended override behaviour.
// ===========================================================================

/// 1:1 carrier of `monaco.Uri.parse(value)` — the Uri object is represented by
/// its string form so marker/location data stays serialisable in truth checks.
String parseUri(String value) => value;

/// 1:1: `new monaco.Range(a, b, c, d)` / value methods on `MonacoRange`.
extension MonacoRangeFeatureExt on MonacoRange {
  /// 1:1: `range.getStartPosition()`
  MonacoPosition getStartPosition() => MonacoPosition(startLineNumber, startColumn);

  /// 1:1: `range.getEndPosition()`
  MonacoPosition getEndPosition() => MonacoPosition(endLineNumber, endColumn);
}

/// 1:1: `monaco.Range.fromPositions(a, b)`
MonacoRange monacoRangeFromPositions(MonacoPosition a, MonacoPosition b) =>
    MonacoRange(a.lineNumber, a.column, b.lineNumber, b.column);

/// 1:1: `monaco.Range.lift(marker: IMarkerData)`
MonacoRange monacoRangeLift(Map<String, Object?> marker) => MonacoRange(
      (marker['startLineNumber'] as num).toInt(),
      (marker['startColumn'] as num).toInt(),
      (marker['endLineNumber'] as num).toInt(),
      (marker['endColumn'] as num).toInt(),
    );

/// 1:1 carrier of `new monaco.Emitter<T>()`. `event` is a listener-registration
/// function; `fire` dispatches to a snapshot of listeners (JS Event semantics).
class MonacoEmitter<T> implements IDisposable {
  final List<void Function(T)> _listeners = <void Function(T)>[];

  /// 1:1: `emitter.event`
  late final void Function(void Function(T) listener) event =
      (void Function(T) listener) => _listeners.add(listener);

  /// 1:1: `emitter.fire(value)`
  void fire(T value) {
    for (final l in List<void Function(T)>.from(_listeners)) {
      l(value);
    }
  }

  @override
  void dispose() => _listeners.clear();
}

/// 1:1 injection hook for the `api.TServerInterface` request methods used by
/// language features. Test/drivers set this to capture calls and supply
/// canned responses; the default mirrors an unresolved request (null result).
Future<Object?> Function(String method, Map<String, Object?> params)?
    serverRequestHook;

/// The 1:1 set of LSP server methods invoked by the 22 language features.
/// Each method forwards `[method, params]` to [serverRequestHook] so every
/// call and argument stays observable (TS interface has all these members).
extension ServerFeatureExt on IServerInterface {
  Future<Object?> _call(String method, Map<String, Object?> params) =>
      (serverRequestHook ?? (String m, Map<String, Object?> p) async => null)(
          method, params);

  Future<Object?> textDocumentHover(Map<String, Object?> p) =>
      _call('textDocumentHover', p);
  Future<Object?> textDocumentDefinition(Map<String, Object?> p) =>
      _call('textDocumentDefinition', p);
  Future<Object?> textDocumentDeclaration(Map<String, Object?> p) =>
      _call('textDocumentDeclaration', p);
  Future<Object?> textDocumentImplementation(Map<String, Object?> p) =>
      _call('textDocumentImplementation', p);
  Future<Object?> textDocumentTypeDefinition(Map<String, Object?> p) =>
      _call('textDocumentTypeDefinition', p);
  Future<Object?> textDocumentReferences(Map<String, Object?> p) =>
      _call('textDocumentReferences', p);
  Future<Object?> textDocumentDocumentHighlight(Map<String, Object?> p) =>
      _call('textDocumentDocumentHighlight', p);
  Future<Object?> textDocumentDocumentSymbol(Map<String, Object?> p) =>
      _call('textDocumentDocumentSymbol', p);
  Future<Object?> textDocumentCodeAction(Map<String, Object?> p) =>
      _call('textDocumentCodeAction', p);
  Future<Object?> codeActionResolve(Map<String, Object?> p) =>
      _call('codeActionResolve', p);
  Future<Object?> textDocumentCodeLens(Map<String, Object?> p) =>
      _call('textDocumentCodeLens', p);
  Future<Object?> codeLensResolve(Map<String, Object?> p) =>
      _call('codeLensResolve', p);
  Future<Object?> textDocumentDocumentLink(Map<String, Object?> p) =>
      _call('textDocumentDocumentLink', p);
  Future<Object?> textDocumentFormatting(Map<String, Object?> p) =>
      _call('textDocumentFormatting', p);
  Future<Object?> textDocumentRangeFormatting(Map<String, Object?> p) =>
      _call('textDocumentRangeFormatting', p);
  Future<Object?> textDocumentOnTypeFormatting(Map<String, Object?> p) =>
      _call('textDocumentOnTypeFormatting', p);
  Future<Object?> textDocumentFoldingRange(Map<String, Object?> p) =>
      _call('textDocumentFoldingRange', p);
  Future<Object?> textDocumentSelectionRange(Map<String, Object?> p) =>
      _call('textDocumentSelectionRange', p);
  Future<Object?> textDocumentSignatureHelp(Map<String, Object?> p) =>
      _call('textDocumentSignatureHelp', p);
  Future<Object?> textDocumentRename(Map<String, Object?> p) =>
      _call('textDocumentRename', p);
  Future<Object?> textDocumentPrepareRename(Map<String, Object?> p) =>
      _call('textDocumentPrepareRename', p);
  Future<Object?> textDocumentCompletion(Map<String, Object?> p) =>
      _call('textDocumentCompletion', p);
  Future<Object?> completionItemResolve(Map<String, Object?> p) =>
      _call('completionItemResolve', p);
  Future<Object?> textDocumentSemanticTokensFull(Map<String, Object?> p) =>
      _call('textDocumentSemanticTokensFull', p);
  Future<Object?> textDocumentSemanticTokensFullDelta(Map<String, Object?> p) =>
      _call('textDocumentSemanticTokensFullDelta', p);
  Future<Object?> textDocumentInlayHint(Map<String, Object?> p) =>
      _call('textDocumentInlayHint', p);
  Future<Object?> inlayHintResolve(Map<String, Object?> p) =>
      _call('inlayHintResolve', p);
  Future<Object?> textDocumentDiagnostic(Map<String, Object?> p) =>
      _call('textDocumentDiagnostic', p);
}

/// Test hook: `model.getPositionAt(offset)`.
MonacoPosition Function(IMonacoTextModel model, int offset)?
    modelGetPositionAtHook;

/// Test hook: `model.getValueInRange(range)`.
String Function(IMonacoTextModel model, MonacoRange range)?
    modelGetValueInRangeHook;

/// Test hook: `model.isDisposed()`.
bool Function(IMonacoTextModel model)? modelIsDisposedHook;

/// 1:1 model methods used by language features. Instance members declared on
/// [IManagedTextModel] (onWillDispose / onDidChangeContent) take precedence.
extension MonacoModelFeatureExt on IMonacoTextModel {
  MonacoPosition getPositionAt(int offset) =>
      (modelGetPositionAtHook ?? (IMonacoTextModel m, int o) => const MonacoPosition(1, 1))(
          this, offset);
  String getValueInRange(MonacoRange range) =>
      (modelGetValueInRangeHook ?? (IMonacoTextModel m, MonacoRange r) => '')(this, range);
  bool isDisposed() =>
      (modelIsDisposedHook ?? (IMonacoTextModel m) => false)(this);
}

/// 1:1 carrier of the `monaco.languages.register*Provider` family. A single
/// slot keyed by provider kind keeps every registration observable; the kind
/// string maps 1:1 to the TS method name (e.g. `registerHoverProvider`).
final Map<String, IDisposable Function(Object? selector, Object provider)>
    monacoProviderSlots = <String, IDisposable Function(Object?, Object)>{};

/// 1:1: `monaco.languages.registerXxxProvider(selector, provider)`.
IDisposable registerMonacoProvider(String kind, Object? selector, Object provider) {
  final slot = monacoProviderSlots[kind];
  return slot == null ? Disposable() : slot(selector, provider);
}

/// Test hook for `monaco.editor.setModelMarkers(model, owner, markers)`.
void Function(IMonacoTextModel model, String owner, List<Object?> markers)?
    setModelMarkersHook;

/// 1:1: `monaco.editor.setModelMarkers(...)`.
void setModelMarkers(IMonacoTextModel model, String owner, List<Object?> markers) =>
    (setModelMarkersHook ?? (IMonacoTextModel m, String o, List<Object?> ms) {})(model, owner, markers);

/// Test hooks for browser timer / console calls in the diagnostics feature.
void Function(void Function() cb, int ms)? setTimeoutHook;
void Function(Object handle)? clearTimeoutHook;
void Function(String message, Object? error)? consoleDebugHook;
void Function(String message, Object? error)? consoleErrorHook;

/// 1:1: `window.setTimeout(cb, 500)` -> opaque handle.
Object setTimeout(void Function() cb, int ms) {
  (setTimeoutHook ?? (void Function() c, int m) {})(cb, ms);
  return Object();
}

/// 1:1: `clearTimeout(handle)`.
void clearTimeout(Object handle) => (clearTimeoutHook ?? (Object h) {})(handle);

/// 1:1: `console.debug(message, error)`.
void consoleDebug(String message, Object? error) =>
    (consoleDebugHook ?? (String m, Object? e) {})(message, error);

/// 1:1: `console.error(message, error)`.
void consoleError(String message, Object? error) =>
    (consoleErrorHook ?? (String m, Object? e) {})(message, error);
