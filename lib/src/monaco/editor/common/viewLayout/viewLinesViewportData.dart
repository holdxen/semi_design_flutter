// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewLayout/viewLinesViewportData.ts
// Translated 1:1. `IViewModel` / `ViewLineRenderingData` / decoration types are
// erased interfaces and are carried locally as opaque objects.
// ---------------------------------------------------------------------------
import '../core/range.dart' show Range;
import '../core/selection.dart' show Selection;

/// 1:1: JS `| 0` (signed 32-bit truncation).
int _int32(int value) =>
    ((value + 0x80000000) % 0x100000000).toInt() - 0x80000000;

/// 1:1: `IPartialViewLinesViewportData` carrier.
class IPartialViewLinesViewportData {
  final int startLineNumber;
  final int endLineNumber;
  final List<num> relativeVerticalOffset;
  final int bigNumbersDelta;
  final int lineHeight;

  IPartialViewLinesViewportData({
    required this.startLineNumber,
    required this.endLineNumber,
    required this.relativeVerticalOffset,
    required this.bigNumbersDelta,
    required this.lineHeight,
  });
}

/// 1:1: `IViewModel` members read here.
abstract class IViewModelForViewportData {
  int getLineMinColumn(int lineNumber);
  int getLineMaxColumn(int lineNumber);
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber);
  bool getViewLineContinuesWithWrappedLine(int lineNumber);
  List<Object> getDecorationsInViewport(Range visibleRange);
}

/// Contains all data needed to render at a specific viewport.
class ViewportData {
  final List<Selection> selections;
  final int startLineNumber;
  final int endLineNumber;
  final List<num> relativeVerticalOffset;
  final Range visibleRange;
  final int bigNumbersDelta;
  final List<Object> whitespaceViewportData;
  final int lineHeight;

  final IViewModelForViewportData _model;

  ViewportData(
    this.selections,
    IPartialViewLinesViewportData partialData,
    this.whitespaceViewportData,
    this._model,
  )   : startLineNumber = _int32(partialData.startLineNumber),
        endLineNumber = _int32(partialData.endLineNumber),
        relativeVerticalOffset = partialData.relativeVerticalOffset,
        bigNumbersDelta = _int32(partialData.bigNumbersDelta),
        lineHeight = _int32(partialData.lineHeight),
        visibleRange = Range(
          partialData.startLineNumber,
          _model.getLineMinColumn(partialData.startLineNumber),
          partialData.endLineNumber,
          _model.getLineMaxColumn(partialData.endLineNumber),
        );

  Object getViewLineRenderingData(int lineNumber) =>
      _model.getViewportViewLineRenderingData(visibleRange, lineNumber);

  bool getViewLineContinuesWithWrappedLine(int lineNumber) =>
      _model.getViewLineContinuesWithWrappedLine(lineNumber);

  List<Object> getDecorationsInViewport() =>
      _model.getDecorationsInViewport(visibleRange);
}
