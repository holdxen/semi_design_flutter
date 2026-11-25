// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/languageService.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * `IObservable.map(this, selector)` -> `map((_, __) => selector())`;
//    `Event.fromObservable` -> `eventFromObservable` helper.
//  * `ILanguageService._serviceBrand` is a TS-only brand field (erased).
//  * `ILanguageSelection` carrier comes from `../languages/language.dart`.
//  * `Array.at(0) ?? null` -> explicit empty check.
// ---------------------------------------------------------------------------
import '../../../base/common/event.dart'
    show Emitter, EmitterOptions, Event, eventFromObservable;
import '../../../base/common/lifecycle.dart' show Disposable, IDisposable;
import '../../../base/common/observable.dart'
    show IObservable, observableSignalFromEvent;
import '../../../base/common/observableInternal/observables/derived.dart'
    show ensureDerivedOptsRegistered;
import '../../../base/common/uri.dart' show URI;
import '../languages.dart' show TokenizationRegistry;
import '../languages/language.dart'
    show
        ILanguageExtensionPoint,
        ILanguageIcon,
        ILanguageNameIdPair,
        ILanguageSelection;
import '../languages/modesRegistry.dart' show PLAINTEXT_LANGUAGE_ID;
import 'languagesRegistry.dart' show LanguageIdCodec, LanguagesRegistry;

/// Provides tokenization related language services of the editor.
class LanguageService extends Disposable {
  // TS: `_serviceBrand: undefined` is a structural brand only.

  static int instanceCount = 0;

  final Emitter<String> _onDidRequestBasicLanguageFeatures =
      Emitter<String>();
  late final Event<String> onDidRequestBasicLanguageFeatures;

  final Emitter<String> _onDidRequestRichLanguageFeatures = Emitter<String>();
  late final Event<String> onDidRequestRichLanguageFeatures;

  final Emitter<void> _onDidChange = Emitter<void>(EmitterOptions(
    leakWarningThreshold: 200,
    leakWarningName: 'LanguageService._onDidChange',
  ));
  late final Event<void> onDidChange;

  // Observed language selections share one subscription to the registry.
  late final IObservable<void> _languagesChanged;

  final Set<String> _requestedBasicLanguages = <String>{};
  final Set<String> _requestedRichLanguages = <String>{};

  late final LanguagesRegistry _registry;
  late final LanguageIdCodec languageIdCodec;

  LanguageService([bool warnOnOverwrite = false]) {
    LanguageService.instanceCount++;
    onDidRequestBasicLanguageFeatures =
        _onDidRequestBasicLanguageFeatures.event;
    onDidRequestRichLanguageFeatures = _onDidRequestRichLanguageFeatures.event;
    onDidChange = _onDidChange.event;
    _registry = register(LanguagesRegistry(true, warnOnOverwrite));
    languageIdCodec = _registry.languageIdCodec;
    register(_registry.onDidChange((_) {
      _onDidChange.fire(null); // Dart Emitter<void> still takes its event argument
    }));
    _languagesChanged = observableSignalFromEvent(this, onDidChange);
  }

  @override
  void dispose() {
    LanguageService.instanceCount--;
    super.dispose();
  }

  IDisposable registerLanguage(ILanguageExtensionPoint def) {
    return _registry.registerLanguage(def);
  }

  bool isRegisteredLanguageId(String? languageId) {
    return _registry.isRegisteredLanguageId(languageId);
  }

  List<String> getRegisteredLanguageIds() {
    return _registry.getRegisteredLanguageIds();
  }

  List<ILanguageNameIdPair> getSortedRegisteredLanguageNames() {
    return _registry.getSortedRegisteredLanguageNames();
  }

  String? getLanguageName(String languageId) {
    return _registry.getLanguageName(languageId);
  }

  String? getMimeType(String languageId) {
    return _registry.getMimeType(languageId);
  }

  ILanguageIcon? getIcon(String languageId) {
    return _registry.getIcon(languageId);
  }

  List<String> getExtensions(String languageId) {
    return _registry.getExtensions(languageId);
  }

  List<String> getFilenames(String languageId) {
    return _registry.getFilenames(languageId);
  }

  List<URI> getConfigurationFiles(String languageId) {
    return _registry.getConfigurationFiles(languageId);
  }

  String? getLanguageIdByLanguageName(String languageName) {
    return _registry.getLanguageIdByLanguageName(languageName);
  }

  String? getLanguageIdByMimeType(String? mimeType) {
    return _registry.getLanguageIdByMimeType(mimeType);
  }

  String? guessLanguageIdByFilepathOrFirstLine(URI? resource,
      [String? firstLine]) {
    final List<String> languageIds = _registry
        .guessLanguageIdByFilepathOrFirstLine(resource, firstLine);
    return languageIds.isEmpty ? null : languageIds.first;
  }

  ILanguageSelection createById(String? languageId) {
    return LanguageSelection(_languagesChanged, () {
      return _createAndGetLanguageIdentifier(languageId);
    });
  }

  ILanguageSelection createByMimeType(String? mimeType) {
    return LanguageSelection(_languagesChanged, () {
      final String? languageId = getLanguageIdByMimeType(mimeType);
      return _createAndGetLanguageIdentifier(languageId);
    });
  }

  ILanguageSelection createByFilepathOrFirstLine(URI? resource,
      [String? firstLine]) {
    return LanguageSelection(_languagesChanged, () {
      final String? languageId =
          guessLanguageIdByFilepathOrFirstLine(resource, firstLine);
      return _createAndGetLanguageIdentifier(languageId);
    });
  }

  String _createAndGetLanguageIdentifier(String? languageId) {
    if (languageId == null ||
        languageId.isEmpty ||
        !isRegisteredLanguageId(languageId)) {
      // Fall back to plain text if language is unknown
      languageId = PLAINTEXT_LANGUAGE_ID;
    }

    return languageId;
  }

  void requestBasicLanguageFeatures(String languageId) {
    if (!_requestedBasicLanguages.contains(languageId)) {
      _requestedBasicLanguages.add(languageId);
      _onDidRequestBasicLanguageFeatures.fire(languageId);
    }
  }

  void requestRichLanguageFeatures(String languageId) {
    if (!_requestedRichLanguages.contains(languageId)) {
      _requestedRichLanguages.add(languageId);

      // Ensure basic features are requested
      requestBasicLanguageFeatures(languageId);

      // Ensure tokenizers are created
      TokenizationRegistry.getOrCreate(languageId);

      _onDidRequestRichLanguageFeatures.fire(languageId);
    }
  }
}

class LanguageSelection implements ILanguageSelection {
  late final IObservable<String> _value;
  @override
  late final Event<String> onDidChange;

  LanguageSelection(IObservable<void> onDidChangeLanguages,
      String Function() selector) {
    // Dart: TS `onDidChangeLanguages.map(this, selector)` passes the owner as
    // the map's first argument; `IObservable.map` here takes (value, reader).
    // The derived-opts bridge is a TS module-load side effect; Dart installs it
    // explicitly before the first `map` call.
    ensureDerivedOptsRegistered();
    _value = onDidChangeLanguages.map<String>((_, _) => selector());
    onDidChange = eventFromObservable<String>(_value);
  }

  @override
  String get languageId {
    return _value.get();
  }
}
