// ---------------------------------------------------------------------------
// 1:1 port of
// vscode/src/vs/editor/contrib/documentSymbols/browser/documentSymbols.ts
// (26 lines).
//
// Registers the `_executeDocumentSymbolProvider` command: resolve the resource,
// create a model reference, obtain its outline through `IOutlineModelService`,
// return the top-level symbols and always dispose the reference.
//
// Adaptations:
//   - TS runs `CommandsRegistry.registerCommand(...)` as a module-level
//     statement; Dart has no top-level statements, so the registration is
//     parked in the lazy `final` below (repo convention for TS side effects).
//   - The rest-args handler becomes `(ServicesAccessor, List<Object?> args)`.
//   - `assertType(URI.isUri(resource))` is the ported `types.assertType`.
// ---------------------------------------------------------------------------

import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/lifecycle.dart'
    show IReference;
import '../../../../base/common/types.dart' show assertType;
import '../../../../base/common/uri.dart' show URI;
import '../../../../platform/commands/common/commands.dart' show CommandsRegistry;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServicesAccessor;
import '../../../common/services/resolverService.dart'
    show IResolvedTextEditorModel, ITextModelService, ITextModelServiceType;
import 'outlineModel.dart'
    show IOutlineModelService, IOutlineModelServiceType, OutlineModel;

final bool documentSymbolsCommandRegistered =
    _registerExecuteDocumentSymbolProvider();

bool _registerExecuteDocumentSymbolProvider() {
  CommandsRegistry.registerCommand('_executeDocumentSymbolProvider',
      (ServicesAccessor accessor, List<Object?> args) async {
    final Object? resource = args.isEmpty ? null : args[0];
    assertType(URI.isUri(resource));

    final IOutlineModelServiceType outlineService =
        accessor.get(IOutlineModelService) as IOutlineModelServiceType;
    final ITextModelServiceType modelService =
        accessor.get(ITextModelService) as ITextModelServiceType;

    final IReference<IResolvedTextEditorModel> reference =
        await modelService.createModelReference(resource as URI);
    try {
      final OutlineModel outlineModel = await outlineService.getOrCreate(
          reference.object.textEditorModel, CancellationToken.none);
      return outlineModel.getTopLevelSymbols();
    } finally {
      reference.dispose();
    }
  });
  return true;
}
