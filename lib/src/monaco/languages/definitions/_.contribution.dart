// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/_.contribution.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//   - `Promise<T>` -> `Future<T>`; the deferred resolve/reject pair held by
//     LazyLanguageLoader -> `Completer<T>`.
//   - `languages.*` / `editor.*` runtime calls (imported from `../../editor`,
//     whose API facade `editor.api.ts` is still pending) -> injectable
//     provider slots, same convention as initialize.dart / workers.dart. Tests
//     can install spies and drive every registration branch without the
//     not-yet-ported editor API.
// ---------------------------------------------------------------------------

import 'dart:async' show Completer, Future;

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart'
    show IMonarchLanguage;

/// 1:1: `interface ILangImpl { conf: languages.LanguageConfiguration; language: languages.IMonarchLanguage; }`
class ILangImpl {
  ILangImpl(this.conf, this.language);

  /// 1:1: `conf: languages.LanguageConfiguration`
  final Map<String, Object?> conf;

  /// 1:1: `language: languages.IMonarchLanguage`
  final IMonarchLanguage language;
}

/// 1:1: `type ILangTokensProviderFactory = { create: async (): Promise<languages.IMonarchLanguage> }`
typedef ILangTokensProviderFactoryCreate = Future<IMonarchLanguage> Function();

/// 1:1: `interface ILang extends languages.ILanguageExtensionPoint { loader: () => Promise<ILangImpl>; }`
/// `configuration` is the TS `URI`, kept opaque (Object?) until URI is ported.
class ILang {
  ILang({
    required this.id,
    this.extensions,
    this.filenames,
    this.filenamePatterns,
    this.firstLine,
    this.aliases,
    this.mimetypes,
    this.configuration,
    required this.loader,
  });

  final String id;
  final List<String>? extensions;
  final List<String>? filenames;
  final List<String>? filenamePatterns;
  final String? firstLine;
  final List<String>? aliases;
  final List<String>? mimetypes;
  final Object? configuration;
  final Future<ILangImpl> Function() loader;
}

// ---- injectable `languages.*` / `editor.*` runtime (from `../../editor`) ----

/// 1:1: `languages.register(def)`
void Function(ILang def) languagesRegister = (ILang def) {};

/// 1:1: `languages.registerTokensProviderFactory(languageId, { create })`
void Function(String languageId, ILangTokensProviderFactoryCreate create)
    languagesRegisterTokensProviderFactory =
    (String languageId, ILangTokensProviderFactoryCreate create) {};

/// 1:1: `languages.onLanguageEncountered(languageId, callback)`
void Function(String languageId, Future<void> Function() callback)
    languagesOnLanguageEncountered =
    (String languageId, Future<void> Function() callback) {};

/// 1:1: `languages.setLanguageConfiguration(languageId, conf)`
void Function(String languageId, Map<String, Object?> conf)
    languagesSetLanguageConfiguration =
    (String languageId, Map<String, Object?> conf) {};

/// 1:1: the disposable model returned by `editor.createModel('', languageId)`.
/// `editor.api.ts` is pending; an opaque carrier preserves the `dispose()` call.
class ILangModel {
  void dispose() {}
}

/// 1:1: `editor.createModel('', languageId)`
ILangModel Function(String value, String languageId) editorCreateModel =
    (String value, String languageId) => ILangModel();

// ---- module state ---------------------------------------------------------

/// 1:1: `const languageDefinitions: { [languageId: string]: ILang } = {}`
final Map<String, ILang> languageDefinitions = <String, ILang>{};

/// 1:1: `const lazyLanguageLoaders: { [languageId: string]: LazyLanguageLoader } = {}`
final Map<String, LazyLanguageLoader> lazyLanguageLoaders =
    <String, LazyLanguageLoader>{};

/// 1:1: `class LazyLanguageLoader`
class LazyLanguageLoader {
  LazyLanguageLoader(this._languageId);

  /// 1:1: `public static getOrCreate(languageId: string): LazyLanguageLoader`
  static LazyLanguageLoader getOrCreate(String languageId) {
    final existing = lazyLanguageLoaders[languageId];
    if (existing == null) {
      final created = LazyLanguageLoader(languageId);
      lazyLanguageLoaders[languageId] = created;
    }
    return lazyLanguageLoaders[languageId]!;
  }

  final String _languageId;
  bool _loadingTriggered = false;
  Completer<ILangImpl>? _completer;

  /// 1:1: `public load(): Promise<ILangImpl>`
  Future<ILangImpl> load() {
    final completer = _completer ??= Completer<ILangImpl>();
    if (!_loadingTriggered) {
      _loadingTriggered = true;
      languageDefinitions[_languageId]!.loader().then(
        (ILangImpl mod) => completer.complete(mod),
        onError: (Object err) => completer.completeError(err),
      );
    }
    return completer.future;
  }
}

/// 1:1: `export async function loadLanguage(languageId: string): Promise<void>`
Future<void> loadLanguage(String languageId) async {
  await LazyLanguageLoader.getOrCreate(languageId).load();

  // trigger tokenizer creation by instantiating a model
  final model = editorCreateModel('', languageId);
  model.dispose();
}

/// 1:1: `export function registerLanguage(def: ILang): void`
void registerLanguage(ILang def) {
  final languageId = def.id;

  languageDefinitions[languageId] = def;
  languagesRegister(def);

  final lazyLanguageLoader = LazyLanguageLoader.getOrCreate(languageId);
  languagesRegisterTokensProviderFactory(languageId, () async {
    final mod = await lazyLanguageLoader.load();
    return mod.language;
  });
  languagesOnLanguageEncountered(languageId, () async {
    final mod = await lazyLanguageLoader.load();
    languagesSetLanguageConfiguration(languageId, mod.conf);
  });
}

/// Test hook: reset the module-level registries between tests.
void resetLanguageContributionForTest() {
  languageDefinitions.clear();
  lazyLanguageLoaders.clear();
}
