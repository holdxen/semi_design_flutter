// Truth replay for batch210: editorOptions.ts lines 2551–3165.
// batch210_truth.json is produced by executing the real transpiled TypeScript source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart' show AccessibilitySupport;

Map<String, dynamic> _truth() => (jsonDecode(File('tool/ts2dart/batch210_truth.json').readAsStringSync()) as Map).cast<String, dynamic>();
Map<String, dynamic> _map(Object? value) => (value as Map).cast<String, dynamic>();

class _Options implements opts.IComputedEditorOptions {
  final Map<int, Object?> values;
  _Options(this.values);
  @override Object? get(Object id) => values[id];
}

opts.EditorLayoutInfo _layout(Map<int, Object?> values, {opts.ComputeOptionsMemory? memory, double width = 1000, double height = 800, bool dominated = false, double lines = 100, double ratio = 1}) => opts.EditorLayoutInfoComputer.computeLayout(_Options(values), memory: memory, outerWidth: width, outerHeight: height, isDominatedByLongLines: dominated, lineHeight: 20, viewLineCount: lines, lineNumbersDigitCount: 3, typicalHalfwidthCharacterWidth: 8, maxDigitWidth: 8, pixelRatio: ratio, glyphMarginDecorationLaneCount: 1);

Map<String, Object?> _mini(opts.EditorMinimapLayoutInfo v) => <String, Object?>{'renderMinimap': v.renderMinimap, 'minimapLeft': v.minimapLeft, 'minimapWidth': v.minimapWidth, 'minimapHeightIsEditorHeight': v.minimapHeightIsEditorHeight, 'minimapIsSampling': v.minimapIsSampling, 'minimapScale': v.minimapScale, 'minimapLineHeight': v.minimapLineHeight, 'minimapCanvasInnerWidth': v.minimapCanvasInnerWidth, 'minimapCanvasInnerHeight': v.minimapCanvasInnerHeight, 'minimapCanvasOuterWidth': v.minimapCanvasOuterWidth, 'minimapCanvasOuterHeight': v.minimapCanvasOuterHeight};
Map<String, Object?> _json(opts.EditorLayoutInfo v) => <String, Object?>{'width': v.width, 'height': v.height, 'glyphMarginLeft': v.glyphMarginLeft, 'glyphMarginWidth': v.glyphMarginWidth, 'glyphMarginDecorationLaneCount': v.glyphMarginDecorationLaneCount, 'lineNumbersLeft': v.lineNumbersLeft, 'lineNumbersWidth': v.lineNumbersWidth, 'decorationsLeft': v.decorationsLeft, 'decorationsWidth': v.decorationsWidth, 'contentLeft': v.contentLeft, 'contentWidth': v.contentWidth, 'minimap': _mini(v.minimap), 'viewportColumn': v.viewportColumn, 'isWordWrapMinified': v.isWordWrapMinified, 'isViewportWrapping': v.isViewportWrapping, 'wrappingColumn': v.wrappingColumn, 'verticalScrollbarWidth': v.verticalScrollbarWidth, 'horizontalScrollbarHeight': v.horizontalScrollbarHeight, 'overviewRuler': <String, Object?>{'top': v.overviewRuler.top, 'width': v.overviewRuler.width, 'height': v.overviewRuler.height, 'right': v.overviewRuler.right}};

Map<int, Object?> _values({bool minimap = true, String size = 'proportional', String side = 'right', bool chars = true, String wrap = 'off', int accessibility = AccessibilitySupport.Unknown, bool longLines = false}) => <int, Object?>{
  opts.EditorOption.glyphMargin: true, opts.EditorOption.lineNumbers: const opts.InternalEditorRenderLineNumbersOptions(1), opts.EditorOption.lineNumbersMinChars: 5, opts.EditorOption.scrollBeyondLastLine: true, opts.EditorOption.padding: const opts.EditorPaddingOptions(top: 10, bottom: 20), opts.EditorOption.lineDecorationsWidth: 10, opts.EditorOption.minimap: opts.EditorMinimapOptions(enabled: minimap, size: size, side: side, showSlider: 'mouseover', renderCharacters: chars, maxColumn: 120, scale: 1), opts.EditorOption.scrollbar: const opts.InternalEditorScrollbarOptions(arrowSize: 11, verticalScrollbarSize: 14, horizontalScrollbarSize: 12, verticalHasArrows: false), opts.EditorOption.folding: true, opts.EditorOption.showFoldingControls: 'mouseover', opts.EditorOption.wordWrapOverride2: 'inherit', opts.EditorOption.wordWrapOverride1: 'inherit', opts.EditorOption.wordWrap: wrap, opts.EditorOption.wordWrapColumn: 80, opts.EditorOption.wordWrapIndicator: false, opts.EditorOption.accessibilitySupport: accessibility,
};

Map<int, Object?> _boundedValues() => <int, Object?>{..._values(wrap: 'bounded', accessibility: AccessibilitySupport.Enabled),
  // Must mirror the truth harness inputs: `wordWrapColumn: 40` and
  // `wordWrapIndicator: true` (the bounded clamp + indicator offset).
  opts.EditorOption.wordWrapOverride1: 'inherit', opts.EditorOption.wordWrapColumn: 40, opts.EditorOption.wordWrapIndicator: true};

void main() {
  final truth = _truth();
  test('layoutInfo and minimap match real source scenarios', () {
    final base = _values();
    expect(_json(_layout(base)), truth['proportional']);
    expect(_json(_layout(_values(minimap: false), width: 640, height: 480, ratio: 2)), truth['noMinimap']);
    expect(_json(_layout(_values(size: 'fill', side: 'left', chars: false, wrap: 'on'), width: 900, height: 500, lines: 300, ratio: 2)), truth['leftFill']);
    expect(_json(_layout(_boundedValues(), width: 700, dominated: true)), truth['bounded']);
  });

  test('contained minimap calculation matches source', () {
    expect(opts.EditorLayoutInfoComputer.computeContainedMinimapLineCount(viewLineCount: 100, scrollBeyondLastLine: true, paddingTop: 10, paddingBottom: 20, height: 800, lineHeight: 20, pixelRatio: 1), truth['contained']);
  });

  test('fit minimap preserves source cache behavior', () {
    final memory = opts.ComputeOptionsMemory();
    final values = _values(size: 'fit', wrap: 'on');
    expect(_json(_layout(values, width: 900, height: 500, lines: 300, memory: memory)), _map(truth['memory'])['first']);
    expect(_json(_layout(values, width: 880, height: 500, lines: 280, memory: memory)), _map(truth['memory'])['second']);
    expect(memory.stableFitMaxMinimapScale, _map(truth['memory'])['stableFitMaxMinimapScale']);
  });
}
