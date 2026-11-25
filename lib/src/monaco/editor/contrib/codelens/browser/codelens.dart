// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/codelens/browser/codelens.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `CodeLens` / `CodeLensList` / `CodeLensProvider` (erased TS interfaces
//     from languages.ts) -> file-local opaque carriers.
//   - `ITextModel` (pending ../model.ts) -> ILanguageFeatureModel usage for
//     registry ordering; narrow `ICodeLensModel` carrier for providers.
//   - `Promise<R>` -> `Future<R>`.
// ---------------------------------------------------------------------------

import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart'
    show illegalArgument, onUnexpectedExternalError;
import '../../../../base/common/lifecycle.dart'
    show DisposableStore, IDisposable, isDisposable;
import '../../../../base/common/types.dart' show assertType;
import '../../../../base/common/uri.dart' show URI;
import '../../../common/core/range.dart' show Range;
import '../../../common/languageFeatureRegistry.dart'
    show ILanguageFeatureModel, LanguageFeatureRegistry;
import '../../../common/services/languageFeatures.dart'
    show ILanguageFeaturesService, ILanguageFeaturesServiceType;
import '../../../common/services/model.dart' show IModelService, IModelServiceType;
import '../../../../platform/commands/common/commands.dart'
    show CommandsRegistry;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServicesAccessor;

/// 1:1: `CodeLens` from languages.ts (opaque carrier).
/// [label] is a replay aid mirroring the truth harness's fake symbol tag; it
/// is not part of the TS interface and is never read by port logic.
class CodeLens {
  CodeLens(this.range, [this.command, this.label]);
  final Range range;
  final Object? command;
  final String? label;
}

/// 1:1: `CodeLensList` from languages.ts (opaque carrier).
/// A list may also be [IDisposable] (checked via [isDisposable]).
class CodeLensList {
  CodeLensList(this.lenses);
  final List<CodeLens> lenses;
}

/// 1:1: `CodeLensProvider` contract (opaque carrier).
abstract class ICodeLensProvider {
  Future<CodeLensList?> provideCodeLenses(
    Object model,
    CancellationToken token,
  );

  /// 1:1: optional `resolveCodeLens` — nullable function carrier for TS's
  /// optional method. Null resolved value mirrors TS `symbol || item.symbol`.
  Future<CodeLens?> Function(
    Object model,
    CodeLens symbol,
    CancellationToken token,
  )? get resolveCodeLens;
}

/// 1:1: `ITextModel` subset used by getCodeLensModel. Extends the registry's
/// erased model surface so [LanguageFeatureRegistry.ordered] accepts it.
abstract class ICodeLensModel implements ILanguageFeatureModel {}

/// 1:1: `export interface CodeLensItem`.
class CodeLensItem {
  CodeLensItem(this.symbol, this.provider);
  final CodeLens symbol;
  final ICodeLensProvider provider;
}

/// 1:1: `export class CodeLensModel`.
class CodeLensModel implements IDisposable {
  static final CodeLensModel Empty = CodeLensModel();

  final List<CodeLensItem> lenses = <CodeLensItem>[];
  DisposableStore? _store;

  @override
  void dispose() => _store?.dispose();

  bool get isDisposed => _store?.isDisposed ?? false;

  void add(CodeLensList list, ICodeLensProvider provider) {
    if (isDisposable(list)) {
      _store ??= DisposableStore();
      _store!.add(list as IDisposable);
    }
    for (final CodeLens symbol in list.lenses) {
      lenses.add(CodeLensItem(symbol, provider));
    }
  }
}

/// 1:1: `getCodeLensModel(registry, model, token)`.
Future<CodeLensModel> getCodeLensModel(
  LanguageFeatureRegistry<ICodeLensProvider> registry,
  ICodeLensModel model,
  CancellationToken token,
) async {
  final List<ICodeLensProvider> provider = registry.ordered(model);
  final Map<ICodeLensProvider, int> providerRanks =
      <ICodeLensProvider, int>{};
  final CodeLensModel result = CodeLensModel();

  final List<Future<void>> promises = <Future<void>>[];
  for (int i = 0; i < provider.length; i++) {
    final ICodeLensProvider p = provider[i];
    promises.add((() async {
      providerRanks[p] = i;
      try {
        final CodeLensList? list = await Future<CodeLensList?>.value(
            await p.provideCodeLenses(model, token));
        if (list != null) {
          result.add(list, p);
        }
      } catch (err) {
        onUnexpectedExternalError(err);
      }
    })());
  }

  await Future.wait(promises);

  if (token.isCancellationRequested) {
    result.dispose();
    return CodeLensModel.Empty;
  }

  result.lenses.sort((CodeLensItem a, CodeLensItem b) {
    // sort by lineNumber, provider-rank, and column
    if (a.symbol.range.startLineNumber < b.symbol.range.startLineNumber) {
      return -1;
    } else if (a.symbol.range.startLineNumber > b.symbol.range.startLineNumber) {
      return 1;
    } else if ((providerRanks[a.provider]!) < (providerRanks[b.provider]!)) {
      return -1;
    } else if ((providerRanks[a.provider]!) > (providerRanks[b.provider]!)) {
      return 1;
    } else if (a.symbol.range.startColumn < b.symbol.range.startColumn) {
      return -1;
    } else if (a.symbol.range.startColumn > b.symbol.range.startColumn) {
      return 1;
    } else {
      return 0;
    }
  });
  return result;
}

/// 1:1: `CommandsRegistry.registerCommand('_executeCodeLensProvider', ...)`.
void _registerExecuteCodeLensProviderCommand() {
  CommandsRegistry.registerCommand(
      '_executeCodeLensProvider',
      (ServicesAccessor accessor, List<Object?> args) async {
    final Object? uri = args.isNotEmpty ? args[0] : null;
    final Object? itemResolveCount = args.length > 1 ? args[1] : null;
    assertType(URI.isUri(uri));
    assertType(itemResolveCount is num || itemResolveCount == null);

    final ILanguageFeaturesServiceType languageFeaturesService =
        accessor.get(ILanguageFeaturesService) as ILanguageFeaturesServiceType;
    final IModelServiceType modelService =
        accessor.get(IModelService) as IModelServiceType;
    final ICodeLensModel? model = modelService.getModel(uri as URI)
        as ICodeLensModel?;
    if (model == null) {
      throw illegalArgument();
    }

    final CodeLensModel value = await getCodeLensModel(
      languageFeaturesService.codeLensProvider as LanguageFeatureRegistry<ICodeLensProvider>,
      model,
      CancellationToken.none,
    );
    final DisposableStore disposables = DisposableStore();
    disposables.add(value);

    final List<CodeLens> result = <CodeLens>[];
    final List<Future<void>> resolve = <Future<void>>[];
    int remaining = itemResolveCount is num ? itemResolveCount.toInt() : 0;

    for (final CodeLensItem item in value.lenses) {
      if (itemResolveCount == null || item.symbol.command != null) {
        result.add(item.symbol);
      } else if (remaining > 0 && item.provider.resolveCodeLens != null) {
        final resolver = item.provider.resolveCodeLens!;
        remaining--;
        resolve.add((() async {
          final CodeLens? resolved = await resolver(
              model, item.symbol, CancellationToken.none);
          result.add(resolved ?? item.symbol);
        })());
      }
    }

    await Future.wait(resolve);
    Future<void>.delayed(
        const Duration(milliseconds: 100), () => disposables.dispose());
    return result;
  });
}

/// Dart top-level initializers are lazy; the TS module registers eagerly.
final bool _commandRegistered = () {
  _registerExecuteCodeLensProviderCommand();
  return true;
}();

/// 1:1: forces evaluation of the module-level command registration.
bool ensureRegistered() => _commandRegistered;
