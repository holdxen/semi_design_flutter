// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/treeSitter/treeSitterLibraryService.ts
// Translated 1:1 from TypeScript. The value/type namespace clash
// (`ITreeSitterLibraryService` const + interface) is resolved by keeping the
// const name and renaming the interface to `ITreeSitterLibraryServiceType`.
// The `@vscode/tree-sitter-wasm` types (`Language`, `Parser`, `Query`) have no
// Dart equivalent; they are carried as `Object?` (Dart has no union/nominal
// external module types here).
// ---------------------------------------------------------------------------

import 'dart:async' show Future;

import '../../../../base/common/observable.dart' show IReader;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const ITreeSitterLibraryService = createDecorator<ITreeSitterLibraryService>('treeSitterLibraryService')`
final ServiceIdentifier<ITreeSitterLibraryServiceType>
    ITreeSitterLibraryService =
    createDecorator<ITreeSitterLibraryServiceType>('treeSitterLibraryService');

/// 1:1: `export interface ITreeSitterLibraryService`
abstract class ITreeSitterLibraryServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `getParserClass(): Promise<typeof Parser>`
  Future<Object?> getParserClass();

  /// 1:1: `supportsLanguage(languageId: string, reader: IReader | undefined): boolean`
  bool supportsLanguage(String languageId, IReader? reader);

  /// 1:1: `getLanguage(languageId: string, ignoreSupportsCheck: boolean, reader: IReader | undefined): Language | undefined`
  Object? getLanguage(
      String languageId, bool ignoreSupportsCheck, IReader? reader);

  /// 1:1: `getLanguagePromise(languageId: string): Promise<Language | undefined>`
  Future<Object?> getLanguagePromise(String languageId);

  /// 1:1: `getInjectionQueries(languageId: string, reader: IReader | undefined): Query | null | undefined`
  Object? getInjectionQueries(String languageId, IReader? reader);

  /// 1:1: `getHighlightingQueries(languageId: string, reader: IReader | undefined): Query | null | undefined`
  Object? getHighlightingQueries(String languageId, IReader? reader);

  /// 1:1: `createQuery(language: Language, querySource: string): Promise<Query>`
  Future<Object?> createQuery(Object language, String querySource);
}
