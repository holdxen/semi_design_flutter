// 1:1 port of vs/editor/common/services/languageFeaturesService.ts
// 32 registries share the same `_score` resolver. Provider interfaces come
// from `../languages.ts` (pending), so registries carry `Object?`.
// NOTE: ILanguageFeaturesServiceType (in languageFeatures.dart) has a private
// `_serviceBrand`, so Dart cannot `implements` it across libraries; the class
// below reproduces its full public surface structurally.
// Runtime truth: tool/ts2dart/_batch267_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/uri.dart' show URI;
import '../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../languageFeatureRegistry.dart'
    show LanguageFeatureRegistry, NotebookInfo, NotebookInfoResolver;
import 'languageFeatures.dart' show ILanguageFeaturesService;

/// 1:1: `LanguageFeaturesService implements ILanguageFeaturesService`
class LanguageFeaturesService {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  late final LanguageFeatureRegistry<Object?> referenceProvider;
  late final LanguageFeatureRegistry<Object?> renameProvider;
  late final LanguageFeatureRegistry<Object?> newSymbolNamesProvider;
  late final LanguageFeatureRegistry<Object?> codeActionProvider;
  late final LanguageFeatureRegistry<Object?> definitionProvider;
  late final LanguageFeatureRegistry<Object?> typeDefinitionProvider;
  late final LanguageFeatureRegistry<Object?> declarationProvider;
  late final LanguageFeatureRegistry<Object?> implementationProvider;
  late final LanguageFeatureRegistry<Object?> documentSymbolProvider;
  late final LanguageFeatureRegistry<Object?> structuralDiffProvider;
  late final LanguageFeatureRegistry<Object?> inlayHintsProvider;
  late final LanguageFeatureRegistry<Object?> colorProvider;
  late final LanguageFeatureRegistry<Object?> codeLensProvider;
  late final LanguageFeatureRegistry<Object?> documentFormattingEditProvider;
  late final LanguageFeatureRegistry<Object?> documentRangeFormattingEditProvider;
  late final LanguageFeatureRegistry<Object?> onTypeFormattingEditProvider;
  late final LanguageFeatureRegistry<Object?> signatureHelpProvider;
  late final LanguageFeatureRegistry<Object?> hoverProvider;
  late final LanguageFeatureRegistry<Object?> documentHighlightProvider;
  late final LanguageFeatureRegistry<Object?> multiDocumentHighlightProvider;
  late final LanguageFeatureRegistry<Object?> selectionRangeProvider;
  late final LanguageFeatureRegistry<Object?> foldingRangeProvider;
  late final LanguageFeatureRegistry<Object?> linkProvider;
  late final LanguageFeatureRegistry<Object?> inlineCompletionsProvider;
  late final LanguageFeatureRegistry<Object?> completionProvider;
  late final LanguageFeatureRegistry<Object?> linkedEditingRangeProvider;
  late final LanguageFeatureRegistry<Object?> inlineValuesProvider;
  late final LanguageFeatureRegistry<Object?> evaluatableExpressionProvider;
  late final LanguageFeatureRegistry<Object?> documentRangeSemanticTokensProvider;
  late final LanguageFeatureRegistry<Object?> documentSemanticTokensProvider;
  late final LanguageFeatureRegistry<Object?> documentDropEditProvider;
  late final LanguageFeatureRegistry<Object?> documentPasteEditProvider;

  NotebookInfoResolver? _notebookTypeResolver;

  LanguageFeaturesService() {
    referenceProvider = _registry();
    renameProvider = _registry();
    newSymbolNamesProvider = _registry();
    codeActionProvider = _registry();
    definitionProvider = _registry();
    typeDefinitionProvider = _registry();
    declarationProvider = _registry();
    implementationProvider = _registry();
    documentSymbolProvider = _registry();
    structuralDiffProvider = _registry();
    inlayHintsProvider = _registry();
    colorProvider = _registry();
    codeLensProvider = _registry();
    documentFormattingEditProvider = _registry();
    documentRangeFormattingEditProvider = _registry();
    onTypeFormattingEditProvider = _registry();
    signatureHelpProvider = _registry();
    hoverProvider = _registry();
    documentHighlightProvider = _registry();
    multiDocumentHighlightProvider = _registry();
    selectionRangeProvider = _registry();
    foldingRangeProvider = _registry();
    linkProvider = _registry();
    inlineCompletionsProvider = _registry();
    completionProvider = _registry();
    linkedEditingRangeProvider = _registry();
    inlineValuesProvider = _registry();
    evaluatableExpressionProvider = _registry();
    documentRangeSemanticTokensProvider = _registry();
    documentSemanticTokensProvider = _registry();
    documentDropEditProvider = _registry();
    documentPasteEditProvider = _registry();
  }

  LanguageFeatureRegistry<Object?> _registry() =>
      LanguageFeatureRegistry<Object?>(_score);

  /// 1:1: `setNotebookTypeResolver(resolver)`
  void setNotebookTypeResolver(NotebookInfoResolver? resolver) {
    _notebookTypeResolver = resolver;
  }

  /// 1:1: `_score(uri)`
  NotebookInfo? _score(URI uri) => _notebookTypeResolver?.call(uri);
}

/// 1:1 top-level side effect: `registerSingleton(...)`.
final Object registration = () {
  registerSingleton(ILanguageFeaturesService, LanguageFeaturesService.new,
      InstantiationType.Delayed);
  return ILanguageFeaturesService;
}();
