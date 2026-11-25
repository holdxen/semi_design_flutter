// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/semanticTokens/common/getSemanticTokens.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `SemanticTokens` / `SemanticTokensEdits` / `SemanticTokensLegend` and the
//     provider interfaces (from languages.ts) -> file-local opaque carriers.
//   - `ITextModel` (pending ../model.ts) -> ILanguageFeatureModel for registry
//     queries; narrow [ISemanticTokensModel] for provider calls.
//   - `Promise<R>` -> `Future<R>`.
// ---------------------------------------------------------------------------

import 'dart:typed_data' show Uint32List;

import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart' show onUnexpectedExternalError;
import '../../../../base/common/types.dart' show assertType;
import '../../../../base/common/uri.dart' show URI;
import '../../../common/core/range.dart' show Range;
import '../../../common/languageFeatureRegistry.dart'
    show ILanguageFeatureModel, LanguageFeatureRegistry;
import '../../../common/services/model.dart' show IModelService, IModelServiceType;
import '../../../common/services/semanticTokensDto.dart'
    show IFullSemanticTokensDto, encodeSemanticTokensDto;
import '../../../../platform/commands/common/commands.dart'
    show CommandsRegistry, ICommandService, ICommandServiceType;
import '../../../../base/common/buffer.dart' show VSBuffer;
import '../../../common/services/languageFeatures.dart'
    show ILanguageFeaturesService, ILanguageFeaturesServiceType;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServicesAccessor;

/// 1:1: `SemanticTokens` carrier.
/// [label] is a replay aid mirroring the truth harness's fake token tag; not
/// part of the TS interface and never read by port logic.
class SemanticTokens {
  SemanticTokens(this.data, [this.resultId, this.label]);
  final List<int> data;
  final String? resultId;
  final String? label;
}

/// 1:1: `SemanticTokensEdits` carrier. [label] is a replay aid.
class SemanticTokensEdits {
  SemanticTokensEdits(this.edits, [this.label]);
  final List<Object?> edits;
  final String? label;
}

/// 1:1: `SemanticTokensLegend` carrier.
class SemanticTokensLegend {
  SemanticTokensLegend(this.tokenTypes, this.tokenModifiers);
  final List<String> tokenTypes;
  final List<String> tokenModifiers;
}

/// 1:1: `DocumentSemanticTokensProvider` contract.
abstract class IDocumentSemanticTokensProvider {
  Future<Object?> provideDocumentSemanticTokens(
    Object model,
    String? lastResultId,
    CancellationToken token,
  );

  void releaseDocumentSemanticTokens(String resultId) {}

  SemanticTokensLegend getLegend() => SemanticTokensLegend(<String>[], <String>[]);
}

/// 1:1: `DocumentRangeSemanticTokensProvider` contract.
abstract class IDocumentRangeSemanticTokensProvider {
  Future<SemanticTokens?> provideDocumentRangeSemanticTokens(
    Object model,
    Range range,
    CancellationToken token,
  );

  SemanticTokensLegend getLegend() => SemanticTokensLegend(<String>[], <String>[]);
}

/// 1:1: `ITextModel` subset for semantic tokens.
abstract class ISemanticTokensModel implements ILanguageFeatureModel {}

/// 1:1: `isSemanticTokens(v): v is SemanticTokens`.
/// JS `v && !!(v.data)` yields null/undefined for falsy v; Dart returns false.
bool isSemanticTokens(Object? v) => v is SemanticTokens;

/// 1:1: `isSemanticTokensEdits(v): v is SemanticTokensEdits`.
bool isSemanticTokensEdits(Object? v) => v is SemanticTokensEdits;

/// 1:1: `export class DocumentSemanticTokensResult`.
class DocumentSemanticTokensResult {
  DocumentSemanticTokensResult(this.provider, this.tokens, this.error);
  final IDocumentSemanticTokensProvider provider;
  final Object? tokens; // SemanticTokens | SemanticTokensEdits | null
  final Object? error;
}

/// 1:1: `hasDocumentSemanticTokensProvider`.
bool hasDocumentSemanticTokensProvider(
  LanguageFeatureRegistry<IDocumentSemanticTokensProvider> registry,
  ISemanticTokensModel model,
) =>
    registry.has(model);

/// 1:1: `getDocumentSemanticTokensProviders` (highest group).
List<IDocumentSemanticTokensProvider> _getDocProviders(
  LanguageFeatureRegistry<IDocumentSemanticTokensProvider> registry,
  ISemanticTokensModel model,
) {
  final List<List<IDocumentSemanticTokensProvider>> groups =
      registry.orderedGroups(model);
  return groups.isNotEmpty ? groups[0] : <IDocumentSemanticTokensProvider>[];
}

/// 1:1: `getDocumentSemanticTokens(...)`.
Future<DocumentSemanticTokensResult?> getDocumentSemanticTokens(
  LanguageFeatureRegistry<IDocumentSemanticTokensProvider> registry,
  ISemanticTokensModel model,
  IDocumentSemanticTokensProvider? lastProvider,
  String? lastResultId,
  CancellationToken token,
) async {
  final List<IDocumentSemanticTokensProvider> providers =
      _getDocProviders(registry, model);

  // Get tokens from all providers at the same time.
  final List<Future<DocumentSemanticTokensResult>> futures =
      <Future<DocumentSemanticTokensResult>>[];
  for (final IDocumentSemanticTokensProvider provider in providers) {
    futures.add((() async {
      Object? result;
      Object? error;
      try {
        result = await provider.provideDocumentSemanticTokens(
          model,
          identical(provider, lastProvider) ? lastResultId : null,
          token,
        );
      } catch (err) {
        error = err;
        result = null;
      }

      if (result == null ||
          (!isSemanticTokens(result) && !isSemanticTokensEdits(result))) {
        result = null;
      }

      return DocumentSemanticTokensResult(provider, result, error);
    })());
  }
  final List<DocumentSemanticTokensResult> results =
      await Future.wait(futures);

  // Try to return the first result with actual tokens or the first result
  // which threw an error (!!).
  for (final DocumentSemanticTokensResult result in results) {
    if (result.error != null) {
      throw result.error!;
    }
    if (result.tokens != null) {
      return result;
    }
  }

  // Return the first result, even if it doesn't have tokens
  if (results.isNotEmpty) {
    return results[0];
  }
  return null;
}

/// 1:1: `_getDocumentSemanticTokensProviderHighestGroup`.
List<IDocumentSemanticTokensProvider>? _getDocHighestGroup(
  LanguageFeatureRegistry<IDocumentSemanticTokensProvider> registry,
  ISemanticTokensModel model,
) {
  final List<List<IDocumentSemanticTokensProvider>> result =
      registry.orderedGroups(model);
  return result.isNotEmpty ? result[0] : null;
}

/// 1:1: `DocumentRangeSemanticTokensResult`.
class DocumentRangeSemanticTokensResult {
  DocumentRangeSemanticTokensResult(this.provider, this.tokens);
  final IDocumentRangeSemanticTokensProvider provider;
  final SemanticTokens? tokens;
}

/// 1:1: `hasDocumentRangeSemanticTokensProvider`.
bool hasDocumentRangeSemanticTokensProvider(
  LanguageFeatureRegistry<IDocumentRangeSemanticTokensProvider> providers,
  ISemanticTokensModel model,
) =>
    providers.has(model);

/// 1:1: `getDocumentRangeSemanticTokensProviders` (highest group).
List<IDocumentRangeSemanticTokensProvider> _getRangeProviders(
  LanguageFeatureRegistry<IDocumentRangeSemanticTokensProvider> providers,
  ISemanticTokensModel model,
) {
  final List<List<IDocumentRangeSemanticTokensProvider>> groups =
      providers.orderedGroups(model);
  return groups.isNotEmpty ? groups[0] : <IDocumentRangeSemanticTokensProvider>[];
}

/// 1:1: `getDocumentRangeSemanticTokens(...)`.
Future<DocumentRangeSemanticTokensResult?> getDocumentRangeSemanticTokens(
  LanguageFeatureRegistry<IDocumentRangeSemanticTokensProvider> registry,
  ISemanticTokensModel model,
  Range range,
  CancellationToken token,
) async {
  final List<IDocumentRangeSemanticTokensProvider> providers =
      _getRangeProviders(registry, model);

  final List<Future<DocumentRangeSemanticTokensResult>> futures =
      <Future<DocumentRangeSemanticTokensResult>>[];
  for (final IDocumentRangeSemanticTokensProvider provider in providers) {
    futures.add((() async {
      SemanticTokens? result;
      try {
        result = await provider.provideDocumentRangeSemanticTokens(
            model, range, token);
      } catch (err) {
        onUnexpectedExternalError(err);
        result = null;
      }

      if (result == null || !isSemanticTokens(result)) {
        result = null;
      }
      return DocumentRangeSemanticTokensResult(provider, result);
    })());
  }
  final List<DocumentRangeSemanticTokensResult> results =
      await Future.wait(futures);

  for (final DocumentRangeSemanticTokensResult result in results) {
    if (result.tokens != null) {
      return result;
    }
  }
  if (results.isNotEmpty) {
    return results[0];
  }
  return null;
}

/// 1:1: `_provideDocumentSemanticTokensLegend` command.
void _registerLegendCommand() {
  CommandsRegistry.registerCommand(
      '_provideDocumentSemanticTokensLegend',
      (ServicesAccessor accessor, List<Object?> args) async {
    final Object? uri = args.isNotEmpty ? args[0] : null;
    assertType(uri is URI);
    final dynamic model =
        (accessor.get(IModelService) as IModelServiceType).getModel(uri as URI);
    if (model == null) return null;
    final ILanguageFeaturesServiceType ls = accessor.get(ILanguageFeaturesService)
        as ILanguageFeaturesServiceType;
    final List<IDocumentSemanticTokensProvider>? providers = _getDocHighestGroup(
        ls.documentSemanticTokensProvider
            as LanguageFeatureRegistry<IDocumentSemanticTokensProvider>,
        model as ISemanticTokensModel);
    if (providers == null) {
      return (accessor.get(ICommandService) as ICommandServiceType)
          .executeCommand('_provideDocumentRangeSemanticTokensLegend', <Object?>[uri]);
    }
    return providers[0].getLegend();
  });
}

/// 1:1: `_provideDocumentSemanticTokens` command.
void _registerSemanticTokensCommand() {
  CommandsRegistry.registerCommand(
      '_provideDocumentSemanticTokens',
      (ServicesAccessor accessor, List<Object?> args) async {
    final Object? uri = args.isNotEmpty ? args[0] : null;
    assertType(uri is URI);
    final dynamic model =
        (accessor.get(IModelService) as IModelServiceType).getModel(uri as URI);
    if (model == null) return null;
    final ILanguageFeaturesServiceType ls = accessor.get(ILanguageFeaturesService)
        as ILanguageFeaturesServiceType;
    final LanguageFeatureRegistry<IDocumentSemanticTokensProvider> registry =
        ls.documentSemanticTokensProvider
            as LanguageFeatureRegistry<IDocumentSemanticTokensProvider>;
    if (!hasDocumentSemanticTokensProvider(registry, model)) {
      return (accessor.get(ICommandService) as ICommandServiceType).executeCommand(
          '_provideDocumentRangeSemanticTokens', <Object?>[uri, model.getFullModelRange()]);
    }
    final DocumentSemanticTokensResult? r = await getDocumentSemanticTokens(
        registry, model, null, null, CancellationToken.none);
    if (r == null) return null;
    final Object? tokens = r.tokens;
    if (tokens == null || !isSemanticTokens(tokens)) return null;
    final VSBuffer buff = encodeSemanticTokensDto(IFullSemanticTokensDto(
        0, Uint32List.fromList((tokens as SemanticTokens).data)));
    if (tokens.resultId != null) {
      r.provider.releaseDocumentSemanticTokens(tokens.resultId!);
    }
    return buff;
  });
}

/// 1:1: `_provideDocumentRangeSemanticTokensLegend` command.
void _registerRangeLegendCommand() {
  CommandsRegistry.registerCommand(
      '_provideDocumentRangeSemanticTokensLegend',
      (ServicesAccessor accessor, List<Object?> args) async {
    final Object? uri = args.isNotEmpty ? args[0] : null;
    final Object? range = args.length > 1 ? args[1] : null;
    assertType(uri is URI);
    final dynamic model =
        (accessor.get(IModelService) as IModelServiceType).getModel(uri as URI);
    if (model == null) return null;
    final ILanguageFeaturesServiceType ls = accessor.get(ILanguageFeaturesService)
        as ILanguageFeaturesServiceType;
    final LanguageFeatureRegistry<IDocumentRangeSemanticTokensProvider> registry =
        ls.documentRangeSemanticTokensProvider
            as LanguageFeatureRegistry<IDocumentRangeSemanticTokensProvider>;
    final List<IDocumentRangeSemanticTokensProvider> providers =
        _getRangeProviders(registry, model);
    if (providers.isEmpty) return null;
    if (providers.length == 1) return providers[0].getLegend();
    if (range == null || range is! Range) {
      return providers[0].getLegend();
    }
    final DocumentRangeSemanticTokensResult? result =
        await getDocumentRangeSemanticTokens(
            registry, model, range, CancellationToken.none);
    if (result == null) return null;
    return result.provider.getLegend();
  });
}

/// 1:1: `_provideDocumentRangeSemanticTokens` command.
void _registerRangeSemanticTokensCommand() {
  CommandsRegistry.registerCommand(
      '_provideDocumentRangeSemanticTokens',
      (ServicesAccessor accessor, List<Object?> args) async {
    final Object? uri = args.isNotEmpty ? args[0] : null;
    final Object? range = args.length > 1 ? args[1] : null;
    assertType(uri is URI);
    assertType(range is Range);
    final dynamic model =
        (accessor.get(IModelService) as IModelServiceType).getModel(uri as URI);
    if (model == null) return null;
    final ILanguageFeaturesServiceType ls = accessor.get(ILanguageFeaturesService)
        as ILanguageFeaturesServiceType;
    final DocumentRangeSemanticTokensResult? result =
        await getDocumentRangeSemanticTokens(
            ls.documentRangeSemanticTokensProvider
                as LanguageFeatureRegistry<IDocumentRangeSemanticTokensProvider>,
            model,
            range as Range,
            CancellationToken.none);
    if (result == null || result.tokens == null) return null;
    return encodeSemanticTokensDto(IFullSemanticTokensDto(
        0, Uint32List.fromList(result.tokens!.data)));
  });
}

/// Dart top-level initializers are lazy; the TS module registers eagerly.
final bool _commandsRegistered = () {
  _registerLegendCommand();
  _registerSemanticTokensCommand();
  _registerRangeLegendCommand();
  _registerRangeSemanticTokensCommand();
  return true;
}();

/// 1:1: forces evaluation of the module-level command registration.
bool ensureRegistered() => _commandsRegistered;
