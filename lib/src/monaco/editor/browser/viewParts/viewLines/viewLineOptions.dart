// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/viewLines/viewLineOptions.ts
// @bfbf12b. Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `IComputedEditorOptions.get(EditorOption.X)` returns `Object?` in the
//    Dart port; each read is cast to the exact runtime type the real option
//    produces (bool / num / String / FontInfo / InternalEditorScrollbarOptions).
//  * `ColorScheme` is the imported enum from `platform/theme/common/theme.dart`.
// ---------------------------------------------------------------------------
import '../../../../platform/theme/common/theme.dart' show ColorScheme;
import '../../../common/config/editorConfiguration.dart'
    show IEditorConfiguration;
import '../../../common/config/editorOptions.dart'
    show EditorOption, InternalEditorScrollbarOptions;
import '../../../common/config/fontInfo.dart' show FontInfo;

/// 1:1: `export class ViewLineOptions`.
class ViewLineOptions {
  ViewLineOptions(IEditorConfiguration config, this.themeType) {
    final options = config.options;
    final FontInfo fontInfo = options.get(EditorOption.fontInfo) as FontInfo;
    renderWhitespace = options.get(EditorOption.renderWhitespace) as String;
    experimentalWhitespaceRendering =
        options.get(EditorOption.experimentalWhitespaceRendering) as String;
    renderControlCharacters =
        options.get(EditorOption.renderControlCharacters) as bool;
    spaceWidth = fontInfo.spaceWidth;
    middotWidth = fontInfo.middotWidth;
    wsmiddotWidth = fontInfo.wsmiddotWidth;
    useMonospaceOptimizations = (fontInfo.isMonospace &&
        !(options.get(EditorOption.disableMonospaceOptimizations) as bool));
    canUseHalfwidthRightwardsArrow = fontInfo.canUseHalfwidthRightwardsArrow;
    lineHeight = options.get(EditorOption.lineHeight) as num;
    stopRenderingLineAfter =
        options.get(EditorOption.stopRenderingLineAfter) as num;
    fontLigatures = options.get(EditorOption.fontLigatures) as String;
    verticalScrollbarSize = (options.get(EditorOption.scrollbar)
            as InternalEditorScrollbarOptions)
        .verticalScrollbarSize;
    useGpu = options.get(EditorOption.experimentalGpuAcceleration) == 'on';
    useTwoCellFullwidthCharacters =
        options.get(EditorOption.effectiveFullwidthCharacterWidth) ==
            'twoCells';
  }

  final ColorScheme themeType;
  late final String renderWhitespace;
  late final String experimentalWhitespaceRendering;
  late final bool renderControlCharacters;
  late final num spaceWidth;
  late final num middotWidth;
  late final num wsmiddotWidth;
  late final bool useMonospaceOptimizations;
  late final bool canUseHalfwidthRightwardsArrow;
  late final num lineHeight;
  late final num stopRenderingLineAfter;
  late final String fontLigatures;
  late final num verticalScrollbarSize;
  late final bool useGpu;
  late final bool useTwoCellFullwidthCharacters;

  /// 1:1: `equals(other)`.
  bool equals(ViewLineOptions other) {
    return themeType == other.themeType &&
        renderWhitespace == other.renderWhitespace &&
        experimentalWhitespaceRendering == other.experimentalWhitespaceRendering &&
        renderControlCharacters == other.renderControlCharacters &&
        spaceWidth == other.spaceWidth &&
        middotWidth == other.middotWidth &&
        wsmiddotWidth == other.wsmiddotWidth &&
        useMonospaceOptimizations == other.useMonospaceOptimizations &&
        canUseHalfwidthRightwardsArrow == other.canUseHalfwidthRightwardsArrow &&
        lineHeight == other.lineHeight &&
        stopRenderingLineAfter == other.stopRenderingLineAfter &&
        fontLigatures == other.fontLigatures &&
        verticalScrollbarSize == other.verticalScrollbarSize &&
        useGpu == other.useGpu &&
        useTwoCellFullwidthCharacters == other.useTwoCellFullwidthCharacters;
  }
}
