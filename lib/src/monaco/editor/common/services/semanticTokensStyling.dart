// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/semanticTokensStyling.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * TS value/type namespace split: the `ISemanticTokensStylingService`
//    const keeps its name; the interface type is suffixed `Type`.
//  * `DocumentTokensProvider` is a union of two erased interfaces -> `Object`.
//  * `_serviceBrand` is a TS-only structural brand field (erased).
// ---------------------------------------------------------------------------
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, Util, createDecorator;
import './semanticTokensProviderStyling.dart'
    show SemanticTokensProviderStyling;

/// 1:1: `export const ISemanticTokensStylingService = createDecorator<...>(
/// 'semanticTokensStylingService')`
final ServiceIdentifier<ISemanticTokensStylingServiceType>
    ISemanticTokensStylingService =
    createDecorator<ISemanticTokensStylingServiceType>(
        'semanticTokensStylingService');

/// 1:1: `export type DocumentTokensProvider`.
typedef DocumentTokensProvider = Object;

/// 1:1: `export interface ISemanticTokensStylingService`.
abstract class ISemanticTokensStylingServiceType {
  SemanticTokensProviderStyling getStyling(DocumentTokensProvider provider);
}

/// Replay-only view of the decorator registration (mirrors TS `_util`).
bool get isSemanticTokensStylingServiceRegistered {
  // Dart top-level finals are lazy; TS initializes them at module load.
  final ServiceIdentifier<ISemanticTokensStylingServiceType> id =
      ISemanticTokensStylingService;
  return identical(Util.serviceIds['semanticTokensStylingService'], id);
}
