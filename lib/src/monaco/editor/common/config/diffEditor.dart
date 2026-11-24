// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/config/diffEditor.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * The two inline object literals (`experimental`, `hideUnchangedRegions`)
//    are carried by value classes with the same fields. In the source
//    `ValidDiffEditorBaseOptions` types them as inline object types; the Dart
//    interface (`editorOptions.dart`) carries them as `Object?`, and these
//    concrete classes are what `diffEditorDefaultOptions` stores there.
//  * TS `... satisfies ValidDiffEditorBaseOptions` -> `implements` on a
//    concrete class (Dart has no `satisfies`); the exported constant keeps its
//    name and is statically typed as that concrete class so nested fields
//    remain typed for callers.
//  * `renderSideBySideInlineBreakpoint` is `number | undefined` in the source
//    interface; the default is the concrete value 900.
// ---------------------------------------------------------------------------
import 'editorOptions.dart' show ValidDiffEditorBaseOptions;

/// 1:1: the inline `experimental` object literal of `diffEditorDefaultOptions`.
class DiffEditorExperimentalOptions {
  const DiffEditorExperimentalOptions({
    required this.showMoves,
    required this.showEmptyDecorations,
    required this.useTrueInlineView,
  });

  final bool showMoves;
  final bool showEmptyDecorations;
  final bool useTrueInlineView;
}

/// 1:1: the inline `hideUnchangedRegions` object literal of
/// `diffEditorDefaultOptions`.
class DiffEditorHideUnchangedRegionsOptions {
  const DiffEditorHideUnchangedRegionsOptions({
    required this.enabled,
    required this.contextLineCount,
    required this.minimumLineCount,
    required this.revealLineCount,
  });

  final bool enabled;
  final int contextLineCount;
  final int minimumLineCount;
  final int revealLineCount;
}

/// 1:1: the object literal exported as `diffEditorDefaultOptions`, typed so it
/// satisfies [ValidDiffEditorBaseOptions] (TS `satisfies` -> Dart `implements`).
class DiffEditorDefaultOptions implements ValidDiffEditorBaseOptions {
  const DiffEditorDefaultOptions();

  @override
  bool get enableSplitViewResizing => true;
  @override
  num get splitViewDefaultRatio => 0.5;
  @override
  bool get renderSideBySide => true;
  @override
  num get renderSideBySideInlineBreakpoint => 900;
  @override
  bool get useInlineViewWhenSpaceIsLimited => true;
  @override
  bool get compactMode => false;
  @override
  bool get hideOriginalLineNumbers => false;
  @override
  num get maxComputationTime => 5000;
  @override
  num get maxFileSize => 50;
  @override
  bool get ignoreTrimWhitespace => true;
  @override
  bool get renderIndicators => true;
  @override
  bool get renderMarginRevertIcon => true;
  @override
  bool get renderGutterMenu => true;
  @override
  bool get originalEditable => false;
  @override
  bool get diffCodeLens => false;
  @override
  bool get renderOverviewRuler => true;
  @override
  String get diffWordWrap => 'inherit';
  @override
  String get diffAlgorithm => 'advanced';
  @override
  bool get accessibilityVerbose => false;
  @override
  Object? get experimental => const DiffEditorExperimentalOptions(
        showMoves: false,
        showEmptyDecorations: true,
        useTrueInlineView: false,
      );
  @override
  bool get isInEmbeddedEditor => false;
  @override
  bool get onlyShowAccessibleDiffViewer => false;
  @override
  Object? get hideUnchangedRegions =>
      const DiffEditorHideUnchangedRegionsOptions(
        enabled: false,
        contextLineCount: 3,
        minimumLineCount: 3,
        revealLineCount: 20,
      );
}

/// 1:1: `export const diffEditorDefaultOptions = { ... } satisfies ...`.
const DiffEditorDefaultOptions diffEditorDefaultOptions =
    DiffEditorDefaultOptions();
