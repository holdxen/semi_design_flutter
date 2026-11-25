// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/services/codeEditorService.ts
// Translated 1:1. Erased interface types are carried as `Object?`; the
// TS call-signature interface becomes a Dart `call` contract.
// ---------------------------------------------------------------------------
import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, Util, createDecorator;
import '../../../base/common/uri.dart' show URI;

/// 1:1: `export const ICodeEditorService = createDecorator<...>
/// ('codeEditorService')`.
final ServiceIdentifier<ICodeEditorServiceType> ICodeEditorService =
    createDecorator<ICodeEditorServiceType>('codeEditorService');

/// 1:1: `export interface ICodeEditorOpenHandler`.
abstract class ICodeEditorOpenHandler {
  Future<Object?> call(Object input, Object? source, [bool? sideBySide]);
}

/// 1:1: `export interface ICodeEditorService`.
abstract class ICodeEditorServiceType {
  Event<void> get onWillCreateCodeEditor;
  Event<Object?> get onCodeEditorAdd;
  Event<Object?> get onCodeEditorRemove;
  Event<void> get onWillCreateDiffEditor;
  Event<Object?> get onDiffEditorAdd;
  Event<Object?> get onDiffEditorRemove;
  Event<Object?> get onDidChangeTransientModelProperty;
  Event<String> get onDecorationTypeRegistered;

  void willCreateCodeEditor();
  void addCodeEditor(Object editor);
  void removeCodeEditor(Object editor);
  List<Object> listCodeEditors();

  void willCreateDiffEditor();
  void addDiffEditor(Object editor);
  void removeDiffEditor(Object editor);
  List<Object> listDiffEditors();

  Object? getFocusedCodeEditor();

  IDisposable registerDecorationType(
      String description, String key, Object options,
      [String? parentTypeKey, Object? editor]);
  List<String> listDecorationTypes();
  void removeDecorationType(String key);
  Object resolveDecorationOptions(String typeKey, bool writable);
  Object? resolveDecorationCSSRules(String decorationTypeKey);

  void setModelProperty(URI resource, String key, Object? value);
  Object? getModelProperty(URI resource, String key);

  void setTransientModelProperty(Object model, String key, Object? value);
  Object? getTransientModelProperty(Object model, String key);
  List<List<Object?>>? getTransientModelProperties(Object model);

  Object? getActiveCodeEditor();
  Future<Object?> openCodeEditor(Object input, Object? source,
      [bool? sideBySide]);
  IDisposable registerCodeEditorOpenHandler(ICodeEditorOpenHandler handler);
}

/// Replay-only registration view (mirrors TS `_util.serviceIds`).
bool get isCodeEditorServiceRegistered {
  final ServiceIdentifier<ICodeEditorServiceType> id = ICodeEditorService;
  return identical(Util.serviceIds['codeEditorService'], id);
}
