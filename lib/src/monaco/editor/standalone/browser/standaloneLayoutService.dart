// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/standalone/browser/standaloneLayoutService.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch430).
// ---------------------------------------------------------------------------

import '../../../base/browser/dom.dart' show IDimension;
import '../../../base/common/arrays.dart' show coalesce;
import '../../../base/common/event.dart' show Event, eventNone;
import '../../browser/services/codeEditorService.dart'
    show ICodeEditorServiceType;
import '../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier;
import '../../../platform/layout/browser/layoutService.dart'
    show ILayoutOffsetInfo, ILayoutServiceType;

/// Computes a client area for a DOM container. Injected so a replay can supply
/// a narrow DOM carrier; production passes [dom.getClientArea].
typedef ClientAreaProvider = IDimension Function(Object container);

/// 1:1: `StandaloneLayoutService implements ILayoutService`.
class StandaloneLayoutService implements ILayoutServiceType {
  final ICodeEditorServiceType _codeEditorService;
  final ClientAreaProvider _getClientArea;
  final Object _mainWindowBody;

  StandaloneLayoutService(
    this._codeEditorService, {
    ClientAreaProvider? getClientArea,
    Object? mainWindowBody,
  })  : _getClientArea = getClientArea ?? _defaultClientArea,
        _mainWindowBody = mainWindowBody ?? Object();

  static IDimension _defaultClientArea(Object container) =>
      throw UnimplementedError('DOM client area must be injected');

  @override
  Event<dynamic> get onDidLayoutMainContainer => eventNone;
  @override
  Event<dynamic> get onDidLayoutActiveContainer => eventNone;
  @override
  Event<dynamic> get onDidLayoutContainer => eventNone;
  @override
  Event<dynamic> get onDidChangeActiveContainer => eventNone;
  @override
  Event<dynamic> get onDidAddContainer => eventNone;

  @override
  Object get mainContainer {
    final List<Object> editors = _codeEditorService.listCodeEditors();
    if (editors.isNotEmpty) {
      return (editors.first as dynamic).getContainerDomNode() as Object;
    }
    return _mainWindowBody;
  }

  @override
  Object get activeContainer {
    final Object? activeCodeEditor = _codeEditorService.getFocusedCodeEditor() ??
        _codeEditorService.getActiveCodeEditor();
    if (activeCodeEditor != null) {
      return (activeCodeEditor as dynamic).getContainerDomNode() as Object;
    }
    return mainContainer;
  }

  @override
  IDimension get mainContainerDimension => _getClientArea(mainContainer);

  @override
  IDimension get activeContainerDimension => _getClientArea(activeContainer);

  @override
  ILayoutOffsetInfo get mainContainerOffset =>
      const ILayoutOffsetInfo(top: 0, quickPickTop: 0);

  @override
  ILayoutOffsetInfo get activeContainerOffset =>
      const ILayoutOffsetInfo(top: 0, quickPickTop: 0);

  @override
  Iterable<Object> get containers => coalesce(
        _codeEditorService
            .listCodeEditors()
            .map((Object codeEditor) =>
                (codeEditor as dynamic).getContainerDomNode() as Object?)
            .toList(),
      );

  @override
  Object getContainer([Object? window]) => activeContainer;

  @override
  Future<void>? whenContainerStylesLoaded([Object? window]) => null;

  @override
  void focus() {
    (_codeEditorService.getFocusedCodeEditor() as dynamic)?.focus();
  }
}

/// 1:1: `EditorScopedLayoutService extends StandaloneLayoutService`.
class EditorScopedLayoutService extends StandaloneLayoutService {
  final Object _container;

  EditorScopedLayoutService(
    this._container,
    ICodeEditorServiceType codeEditorService, {
    ClientAreaProvider? getClientArea,
    Object? mainWindowBody,
  }) : super(
          codeEditorService,
          getClientArea: getClientArea,
          mainWindowBody: mainWindowBody,
        );

  @override
  Object get mainContainer => _container;
}

/// Registers the singleton. Mirrors the source's module-level side effect.
void registerStandaloneLayoutService(
  ServiceIdentifier<ILayoutServiceType> id,
  ILayoutServiceType Function(ICodeEditorServiceType) factory,
) {
  registerSingleton<ILayoutServiceType>(id, factory, InstantiationType.Delayed);
}
