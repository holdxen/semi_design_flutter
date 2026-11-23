// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/standalone/browser/standaloneTreeSitterLibraryService.ts
// Translated 1:1 from TypeScript. The `@vscode/tree-sitter-wasm` types
// (`Parser`, `Language`, `Query`) have no Dart equivalent; carried as Object?.
// ---------------------------------------------------------------------------

import 'dart:async' show Future;

import '../../../base/common/observable.dart' show IReader;
import '../../common/services/treeSitter/treeSitterLibraryService.dart'
    show ITreeSitterLibraryServiceType;

/// 1:1: `export class StandaloneTreeSitterLibraryService implements ITreeSitterLibraryService`
class StandaloneTreeSitterLibraryService
    implements ITreeSitterLibraryServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  Future<Object?> getParserClass() => throw StateError(
      'not implemented in StandaloneTreeSitterLibraryService');

  @override
  bool supportsLanguage(String languageId, IReader? reader) => false;

  @override
  Object? getLanguage(
          String languageId, bool ignoreSupportsCheck, IReader? reader) =>
      null;

  @override
  Future<Object?> getLanguagePromise(String languageId) async => null;

  @override
  Object? getInjectionQueries(String languageId, IReader? reader) => null;

  @override
  Object? getHighlightingQueries(String languageId, IReader? reader) => null;

  @override
  Future<Object?> createQuery(Object language, String querySource) =>
      throw StateError(
          'not implemented in StandaloneTreeSitterLibraryService');
}
