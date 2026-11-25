// 1:1 port of vs/editor/common/services/resolverService.ts
// Declaration module plus the runtime `isResolvedTextEditorModel` guard.
// Erased model types are opaque carriers; the guard reproduces JS truthiness.
// Runtime truth: tool/ts2dart/_batch274_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show IDisposable, IReference;
import '../../../base/common/uri.dart' show URI;
import '../../../platform/editor/common/editor.dart' show IResolvableEditorModel;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../languages/language.dart' show ILanguageSelection;

/// 1:1: `export const ITextModelService = createDecorator<...>('textModelService')`
final ServiceIdentifier<ITextModelServiceType> ITextModelService =
    createDecorator<ITextModelServiceType>('textModelService');

/// 1:1: `ITextModel` (from `../model.ts`, pending) — opaque carrier.
abstract class ITextModelForResolver {}

/// 1:1: `ITextModelService`
abstract class ITextModelServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Future<IReference<IResolvedTextEditorModel>> createModelReference(URI resource);

  Future<IReference<IResolvedTextEditorModel>> createSyntheticDocument(
    Object value,
    ILanguageSelection? languageSelection,
  );

  IDisposable registerTextModelContentProvider(
      String scheme, ITextModelContentProvider provider);

  bool canHandleResource(URI resource);
}

/// 1:1: `ITextModelContentProvider`
abstract class ITextModelContentProvider {
  Future<ITextModelForResolver?>? provideTextContent(URI resource);
}

/// 1:1: `ITextEditorModel extends IResolvableEditorModel`
abstract class ITextEditorModel implements IResolvableEditorModel {
  Event<void> get onWillDispose;
  Object? get textEditorModel;
  Object? createSnapshot();
  Object isReadonly();
  String? getLanguageId();
  bool isDisposed();
}

/// 1:1: `IResolvedTextEditorModel extends ITextEditorModel`
abstract class IResolvedTextEditorModel implements ITextEditorModel {
  @override
  ITextModelForResolver get textEditorModel;
}

bool _jsTruthy(Object? value) {
  if (value == null || value == false || value == 0 || value == '') {
    return false;
  }
  return true;
}

/// 1:1: `isResolvedTextEditorModel(model)` — JS `!!candidate.textEditorModel`
bool isResolvedTextEditorModel(ITextEditorModel model) =>
    _jsTruthy(model.textEditorModel);
