// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/inMemoryTextModelService.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `ITextModel` (from pending ../model.ts) -> local [IInMemoryTextModel]
//     carrying only dispose/getLanguageId/createSnapshot.
//   - `IModelService.getModel/createModel` -> local [IInMemoryModelService].
//   - `ReferenceCollection` / `Lazy` / `IReference` are reused from the port.
//   - `ITextSnapshot`, `ITextBufferFactory`, `ILanguageSelection` opaque.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lazy.dart' show Lazy;
import '../../../base/common/lifecycle.dart'
    show Disposable, IDisposable, IReference, ReferenceCollection;
import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/uri.dart' show URI, UriComponents;
import '../../../base/common/uuid.dart' show generateUuid;
import '../languages/language.dart' show ILanguageSelection;
import 'resolverService.dart'
    show
        IResolvedTextEditorModel,
        ITextModelContentProvider,
        ITextModelForResolver,
        ITextModelServiceType;

/// 1:1: `ITextModel` subset used here (from pending ../model.ts).
abstract class IInMemoryTextModel implements ITextModelForResolver {
  void dispose();

  String getLanguageId();

  Object? createSnapshot();
}

/// 1:1: `IModelService` subset used here.
abstract class IInMemoryModelService {
  IInMemoryTextModel? getModel(URI resource);

  IInMemoryTextModel createModel(
    Object value,
    ILanguageSelection? languageSelection,
    URI resource,
  );
}

/// 1:1: `InMemoryTextModelService implements ITextModelService`.
class InMemoryTextModelService implements ITextModelServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  late final InMemoryModelCollection _models;

  InMemoryTextModelService(IInMemoryModelService modelService) {
    _models = InMemoryModelCollection(modelService);
  }

  @override
  Future<IReference<IResolvedTextEditorModel>> createModelReference(
    URI resource,
  ) =>
      _acquire(resource);

  @override
  Future<IReference<IResolvedTextEditorModel>> createSyntheticDocument(
    Object value,
    ILanguageSelection? languageSelection,
  ) {
    final URI resource = URI.from(UriComponents(
      scheme: Schemas.inMemory,
      path: '/synthetic/${generateUuid()}',
    ));
    return _acquire(resource, value, languageSelection);
  }

  Future<IReference<IResolvedTextEditorModel>> _acquire(
    URI resource, [
    Object? value,
    ILanguageSelection? languageSelection,
  ]) async {
    final IReference<Lazy<SimpleModel>> reference = _models.acquire(
      resource.toString(),
      <Object?>[value, languageSelection],
    );
    try {
      // The entry must exist before model creation, and reentrant opens must
      // wait for its lazy factory to finish.
      await Future<void>.value();
      return _SimpleModelReference(
          reference.object.value, () => reference.dispose());
    } catch (error) {
      reference.dispose();
      rethrow;
    }
  }

  @override
  IDisposable registerTextModelContentProvider(
    String scheme,
    ITextModelContentProvider provider,
  ) =>
      Disposable.none;

  @override
  bool canHandleResource(URI resource) => false;
}

/// 1:1: returned reference `{ object, dispose }`.
class _SimpleModelReference implements IReference<IResolvedTextEditorModel> {
  _SimpleModelReference(this.object, this._dispose);

  @override
  final IResolvedTextEditorModel object;
  final void Function() _dispose;

  @override
  void dispose() => _dispose();
}

/// 1:1: `InMemoryModelCollection extends ReferenceCollection<Lazy<SimpleModel>>`.
class InMemoryModelCollection extends ReferenceCollection<Lazy<SimpleModel>> {
  InMemoryModelCollection(this._modelService);

  final IInMemoryModelService _modelService;

  @override
  Lazy<SimpleModel> createReferencedObject(String key, List<Object?> args) {
    final Object? value = args.isNotEmpty ? args[0] : null;
    final ILanguageSelection? languageSelection =
        args.length > 1 ? args[1] as ILanguageSelection? : null;
    return Lazy<SimpleModel>(() {
      final URI resource = URI.parse(key);
      final IInMemoryTextModel? model = value == null
          ? _modelService.getModel(resource)
          : _modelService.createModel(value, languageSelection, resource);
      if (model == null) {
        throw StateError('Model not found');
      }
      return SimpleModel(model, value != null);
    });
  }

  @override
  void destroyReferencedObject(String key, Lazy<SimpleModel> model) {
    model.rawValue?.dispose();
  }
}

/// 1:1: `SimpleModel extends Disposable implements IResolvedTextEditorModel`.
class SimpleModel extends Disposable implements IResolvedTextEditorModel {
  final Emitter<void> _onWillDispose = Emitter<void>();

  @override
  late final Event<void> onWillDispose;

  @override
  final IInMemoryTextModel textEditorModel;
  final bool _ownsModel;
  bool _disposed = false;

  SimpleModel(this.textEditorModel, this._ownsModel) {
    register(_onWillDispose);
    onWillDispose = _onWillDispose.event;
  }

  @override
  Future<void> resolve() async {}

  @override
  Object? createSnapshot() => textEditorModel.createSnapshot();

  @override
  Object isReadonly() => false;

  @override
  void dispose() {
    if (isDisposed()) {
      return;
    }
    _onWillDispose.fire(null);
    _disposed = true;
    super.dispose();
    if (_ownsModel) {
      textEditorModel.dispose();
    }
  }

  @override
  bool isDisposed() => _disposed;

  @override
  bool isResolved() => true;

  @override
  String? getLanguageId() => textEditorModel.getLanguageId();
}
