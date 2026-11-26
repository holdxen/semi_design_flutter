// 1:1 port of vscode/src/vs/editor/contrib/hover/browser/glyphHoverComputer.ts
// Adaptations:
//   - `ICodeEditor`, `IModelDecoration`, `IModelDecorationOptions` are erased
//     file-local carriers; only the members read by computeSync are declared.
//   - `LaneOrLineNumber` (int | 'lineNo') -> `Object`.
// Runtime truth: tool/ts2dart/_batch338_truth.cjs.

import '../../../../base/common/arrays.dart' show asArray;
import '../../../../base/common/async.dart' show IAsyncIterable;
import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/htmlContent.dart'
    show IMarkdownString, isEmptyMarkdownString;
import '../../../common/model.dart' show GlyphMarginLane;
import 'hoverOperation.dart' show IHoverComputer;

/// 1:1: `export type LaneOrLineNumber = GlyphMarginLane | 'lineNo'`.
typedef LaneOrLineNumber = Object;

/// 1:1: `export interface IHoverMessage`.
class IHoverMessage {
  final IMarkdownString value;

  IHoverMessage(this.value);
}

/// 1:1: `export interface GlyphHoverComputerOptions`.
class GlyphHoverComputerOptions {
  final int lineNumber;
  final LaneOrLineNumber laneOrLine;

  const GlyphHoverComputerOptions({
    required this.lineNumber,
    required this.laneOrLine,
  });
}

/// 1:1: `options.glyphMargin` (carrier).
class GlyphMarginOption {
  final int position;

  GlyphMarginOption(this.position);
}

/// 1:1: `IModelDecorationOptions` subset used here (opaque carrier).
abstract class IModelDecorationOptionsForGlyphHover {
  GlyphMarginOption? get glyphMargin;
  Object? get lineNumberHoverMessage;
  Object? get glyphMarginHoverMessage;
}

/// 1:1: `IModelDecoration` subset used here (opaque carrier).
abstract class IModelDecorationForGlyphHover {
  IModelDecorationOptionsForGlyphHover get options;
}

/// 1:1: `ICodeEditor` subset used here (opaque carrier).
abstract class ICodeEditorForGlyphHover {
  List<IModelDecorationForGlyphHover>? getLineDecorations(int lineNumber);
}

/// 1:1: `export class GlyphHoverComputer`.
class GlyphHoverComputer
    implements IHoverComputer<GlyphHoverComputerOptions, IHoverMessage> {
  final ICodeEditorForGlyphHover _editor;

  GlyphHoverComputer(this._editor);

  /// No async computation in TS (only `computeSync` is defined).
  @override
  IAsyncIterable<IHoverMessage>? computeAsync(
          GlyphHoverComputerOptions args, CancellationToken token) =>
      null;

  @override
  List<IHoverMessage> computeSync(GlyphHoverComputerOptions opts) {
    IHoverMessage toHoverMessage(IMarkdownString contents) =>
        IHoverMessage(contents);

    final List<IModelDecorationForGlyphHover>? lineDecorations =
        _editor.getLineDecorations(opts.lineNumber);

    final List<IHoverMessage> result = <IHoverMessage>[];
    final bool isLineHover = opts.laneOrLine == 'lineNo';
    if (lineDecorations == null) {
      return result;
    }

    for (final IModelDecorationForGlyphHover d in lineDecorations) {
      final int lane =
          d.options.glyphMargin?.position ?? GlyphMarginLane.Center;
      if (!isLineHover && lane != opts.laneOrLine) {
        continue;
      }

      final Object? hoverMessage = isLineHover
          ? d.options.lineNumberHoverMessage
          : d.options.glyphMarginHoverMessage;
      if (hoverMessage == null || isEmptyMarkdownString(hoverMessage)) {
        continue;
      }

      result.addAll(asArray<Object?>(hoverMessage).map((Object? item) =>
          toHoverMessage(item as IMarkdownString)));
    }

    return result;
  }
}
