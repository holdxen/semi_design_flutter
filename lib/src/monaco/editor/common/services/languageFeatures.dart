// 1:1 port of vs/editor/common/services/languageFeatures.ts
// Declaration-only module: 1 decorator + 1 interface with 32 provider
// registries. Provider interfaces come from `../languages.ts` (pending), so
// every registry is carried as `LanguageFeatureRegistry<Object?>`.
// Runtime truth: tool/ts2dart/_batch265_truth.cjs (recursive TS transpile+vm).

import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../languageFeatureRegistry.dart'
    show LanguageFeatureRegistry, NotebookInfoResolver;

/// 1:1: `export const ILanguageFeaturesService = createDecorator(...)`
final ServiceIdentifier<ILanguageFeaturesServiceType> ILanguageFeaturesService =
    createDecorator<ILanguageFeaturesServiceType>('ILanguageFeaturesService');

/// 1:1: `export interface ILanguageFeaturesService` (phantom/type carrier)
abstract class ILanguageFeaturesServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  LanguageFeatureRegistry<Object?> get referenceProvider;
  LanguageFeatureRegistry<Object?> get definitionProvider;
  LanguageFeatureRegistry<Object?> get typeDefinitionProvider;
  LanguageFeatureRegistry<Object?> get declarationProvider;
  LanguageFeatureRegistry<Object?> get implementationProvider;
  LanguageFeatureRegistry<Object?> get codeActionProvider;
  LanguageFeatureRegistry<Object?> get documentPasteEditProvider;
  LanguageFeatureRegistry<Object?> get renameProvider;
  LanguageFeatureRegistry<Object?> get newSymbolNamesProvider;
  LanguageFeatureRegistry<Object?> get documentFormattingEditProvider;
  LanguageFeatureRegistry<Object?> get documentRangeFormattingEditProvider;
  LanguageFeatureRegistry<Object?> get onTypeFormattingEditProvider;
  LanguageFeatureRegistry<Object?> get documentSymbolProvider;
  LanguageFeatureRegistry<Object?> get structuralDiffProvider;
  LanguageFeatureRegistry<Object?> get inlayHintsProvider;
  LanguageFeatureRegistry<Object?> get colorProvider;
  LanguageFeatureRegistry<Object?> get codeLensProvider;
  LanguageFeatureRegistry<Object?> get signatureHelpProvider;
  LanguageFeatureRegistry<Object?> get hoverProvider;
  LanguageFeatureRegistry<Object?> get documentHighlightProvider;
  LanguageFeatureRegistry<Object?> get multiDocumentHighlightProvider;
  LanguageFeatureRegistry<Object?> get documentRangeSemanticTokensProvider;
  LanguageFeatureRegistry<Object?> get documentSemanticTokensProvider;
  LanguageFeatureRegistry<Object?> get selectionRangeProvider;
  LanguageFeatureRegistry<Object?> get foldingRangeProvider;
  LanguageFeatureRegistry<Object?> get linkProvider;
  LanguageFeatureRegistry<Object?> get inlineCompletionsProvider;
  LanguageFeatureRegistry<Object?> get completionProvider;
  LanguageFeatureRegistry<Object?> get linkedEditingRangeProvider;
  LanguageFeatureRegistry<Object?> get inlineValuesProvider;
  LanguageFeatureRegistry<Object?> get evaluatableExpressionProvider;
  LanguageFeatureRegistry<Object?> get documentDropEditProvider;

  /// 1:1: `setNotebookTypeResolver(resolver): void`
  void setNotebookTypeResolver(NotebookInfoResolver? resolver);
}
