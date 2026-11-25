// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/services/markerDecorations.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * `ICodeEditor` / `IMarkerDecorationsService` / `IEditorContribution` are
//    erased interfaces; the contribution implements a local contract and the
//    constructor arguments are opaque carriers (the source ignores both).
// ---------------------------------------------------------------------------

/// 1:1: `IEditorContribution.dispose` contract.
abstract class IEditorContributionForMarkerDecorations {
  void dispose();
}

/// 1:1: `export class MarkerDecorationsContribution`.
class MarkerDecorationsContribution
    implements IEditorContributionForMarkerDecorations {
  /// 1:1: `public static readonly ID`.
  static const String ID = 'editor.contrib.markerDecorations';

  MarkerDecorationsContribution(
    Object editor,
    Object markerDecorationsService,
  ) {
    // Doesn't do anything, just requires `IMarkerDecorationsService` to make
    // sure it gets instantiated.
  }

  @override
  void dispose() {}
}
