// ---------------------------------------------------------------------------
// 1:1 Dart port of vscode/src/vs/editor/test/browser/config/
// editorLayoutProvider.test.ts (whole file, 810 lines).
//
// Adaptations (semantics unchanged):
//   * mocha `test(...)` cases become top-level Dart functions; every
//     `assert.deepStrictEqual` becomes an `assert` with a descriptive message.
//   * `ensureNoDisposablesAreLeakedInTestSuite()` is a suite harness hook and
//     is intentionally omitted (as in common/core/range.test.dart).
//   * TS object literals are Dart `Map<String, Object?>` literals. The TS
//     spreads `{...base, ...input}` are realized as Dart map spreads in the
//     case tables and by `Map.of(base)..addAll(patch)` in `doTest` callers.
//   * TS `options._write(...)` becomes `options.write(...)`: Dart's leading
//     underscore is library-private, so ComputedEditorOptions gained a public
//     alias with identical semantics.
//   * `RenderMinimap.None/Text` are the Dart ints `RenderMinimap.none/text`.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:math' as math;

import '../../../browser/config/editorConfiguration.dart'
    show ComputedEditorOptions;
import '../../../common/config/editorOptions.dart'
    show
        EditorLayoutInfo,
        EditorLayoutInfoComputer,
        EditorMinimapLayoutInfo,
        EditorMinimapOptions,
        EditorOption,
        EditorOptions,
        EditorPaddingOptions,
        InternalEditorRenderLineNumbersOptions,
        InternalEditorScrollbarOptions,
        OverviewRulerPosition,
        RenderLineNumbersType,
        RenderMinimap;

/// 1:1: `interface IEditorLayoutProviderOpts`.
class IEditorLayoutProviderOpts {
  final num outerWidth;
  final num outerHeight;

  final bool showGlyphMargin;
  final num lineHeight;

  final bool showLineNumbers;
  final num lineNumbersMinChars;
  final num lineNumbersDigitCount;
  final num? maxLineNumber;

  final num lineDecorationsWidth;

  final num typicalHalfwidthCharacterWidth;
  final num maxDigitWidth;

  final num verticalScrollbarWidth;
  final bool verticalScrollbarHasArrows;
  final num scrollbarArrowSize;
  final num horizontalScrollbarHeight;

  final bool minimap;
  /// `'left' | 'right'` (TS string-literal union).
  final String minimapSide;
  final bool minimapRenderCharacters;
  final num minimapMaxColumn;
  /// `'proportional' | 'fill' | 'fit'`.
  final String? minimapSize;
  final num? minimapScale;
  final num pixelRatio;

  /// `'off' | 'on' | 'wordWrapColumn' | 'bounded'`; defaults to `'off'`.
  final String? wordWrap;
  final num? wordWrapColumn;
  final bool? wordWrapIndicator;

  const IEditorLayoutProviderOpts({
    required this.outerWidth,
    required this.outerHeight,
    required this.showGlyphMargin,
    required this.lineHeight,
    required this.showLineNumbers,
    required this.lineNumbersMinChars,
    required this.lineNumbersDigitCount,
    this.maxLineNumber,
    required this.lineDecorationsWidth,
    required this.typicalHalfwidthCharacterWidth,
    required this.maxDigitWidth,
    required this.verticalScrollbarWidth,
    required this.verticalScrollbarHasArrows,
    required this.scrollbarArrowSize,
    required this.horizontalScrollbarHeight,
    required this.minimap,
    required this.minimapSide,
    required this.minimapRenderCharacters,
    required this.minimapMaxColumn,
    this.minimapSize,
    this.minimapScale,
    required this.pixelRatio,
    this.wordWrap,
    this.wordWrapColumn,
    this.wordWrapIndicator,
  });
}

/// JSON-safe deep equality. A missing key and an explicit `null` normalize
/// alike, and `num` compares by value (matching JS numbers).
bool _jsonEqual(Object? a, Object? b) {
  if (a == null || b == null) return a == null && b == null;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    final Set<String> keys = <String>{
      ...a.keys.map((Object? k) => k.toString()),
      ...b.keys.map((Object? k) => k.toString()),
    };
    for (final String key in keys) {
      if (!_jsonEqual(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_jsonEqual(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

String _describe(Object? value) => jsonEncode(value);

/// 1:1: `computeLayoutInfo(input)`.
EditorLayoutInfo computeLayoutInfo(IEditorLayoutProviderOpts input) {
  final ComputedEditorOptions options = ComputedEditorOptions();
  options.write(EditorOption.glyphMargin, input.showGlyphMargin);
  options.write(EditorOption.lineNumbersMinChars, input.lineNumbersMinChars);
  options.write(EditorOption.lineDecorationsWidth, input.lineDecorationsWidth);
  options.write(EditorOption.folding, false);
  options.write(EditorOption.padding, const EditorPaddingOptions(top: 0, bottom: 0));
  final EditorMinimapOptions minimapOptions = EditorMinimapOptions(
    enabled: input.minimap,
    autohide: 'none',
    size: input.minimapSize ?? 'proportional',
    side: input.minimapSide,
    renderCharacters: input.minimapRenderCharacters,
    maxColumn: input.minimapMaxColumn,
    showSlider: 'mouseover',
    scale: input.minimapScale ?? 1,
    showRegionSectionHeaders: true,
    showMarkSectionHeaders: true,
    sectionHeaderFontSize: 9,
    sectionHeaderLetterSpacing: 1,
    markSectionHeaderRegex: r'\bMARK:\s*(?<separator>-?)\s*(?<label>.*)$',
  );
  options.write(EditorOption.minimap, minimapOptions);
  final InternalEditorScrollbarOptions defaults =
      EditorOptions.scrollbar.defaultValue;
  final InternalEditorScrollbarOptions scrollbarOptions =
      InternalEditorScrollbarOptions(
    arrowSize: input.scrollbarArrowSize,
    vertical: defaults.vertical,
    horizontal: defaults.horizontal,
    useShadows: defaults.useShadows,
    verticalHasArrows: input.verticalScrollbarHasArrows,
    horizontalHasArrows: false,
    handleMouseWheel: defaults.handleMouseWheel,
    alwaysConsumeMouseWheel: true,
    horizontalScrollbarSize: input.horizontalScrollbarHeight,
    horizontalSliderSize: defaults.horizontalSliderSize,
    verticalScrollbarSize: input.verticalScrollbarWidth,
    verticalSliderSize: defaults.verticalSliderSize,
    scrollByPage: defaults.scrollByPage,
    ignoreHorizontalScrollbarInContentHeight: false,
  );
  options.write(EditorOption.scrollbar, scrollbarOptions);
  final InternalEditorRenderLineNumbersOptions lineNumbersOptions =
      InternalEditorRenderLineNumbersOptions(
    input.showLineNumbers
        ? RenderLineNumbersType.on
        : RenderLineNumbersType.off,
    null,
  );
  options.write(EditorOption.lineNumbers, lineNumbersOptions);

  options.write(EditorOption.wordWrap, input.wordWrap ?? 'off');
  options.write(EditorOption.wordWrapColumn, input.wordWrapColumn ?? 80);
  options.write(EditorOption.wordWrapIndicator, input.wordWrapIndicator ?? false);
  options.write(EditorOption.wordWrapOverride1, 'inherit');
  options.write(EditorOption.wordWrapOverride2, 'inherit');
  options.write(EditorOption.accessibilitySupport, 'auto');

  // TS: `input.maxLineNumber || Math.pow(10, input.lineNumbersDigitCount) - 1`.
  final num viewLineCount = (input.maxLineNumber != null &&
          input.maxLineNumber != 0)
      ? input.maxLineNumber!
      : math.pow(10, input.lineNumbersDigitCount) - 1;

  return EditorLayoutInfoComputer.computeLayout(
    options,
    memory: null,
    outerWidth: input.outerWidth,
    outerHeight: input.outerHeight,
    isDominatedByLongLines: false,
    lineHeight: input.lineHeight,
    viewLineCount: viewLineCount,
    lineNumbersDigitCount: input.lineNumbersDigitCount,
    typicalHalfwidthCharacterWidth: input.typicalHalfwidthCharacterWidth,
    maxDigitWidth: input.maxDigitWidth,
    pixelRatio: input.pixelRatio,
    glyphMarginDecorationLaneCount: 1,
  );
}

/// Public helper used by `test/monaco_batch239_test.dart`.
EditorLayoutInfo computeLayoutInfoForTest(IEditorLayoutProviderOpts input) =>
    computeLayoutInfo(input);

/// JSON shape used by the truth harness's `normalize()` and by `doTest`.
Map<String, Object?> editorLayoutInfoToJson(EditorLayoutInfo info) {
  final EditorMinimapLayoutInfo m = info.minimap;
  final OverviewRulerPosition r = info.overviewRuler;
  return <String, Object?>{
    'width': info.width,
    'height': info.height,
    'glyphMarginLeft': info.glyphMarginLeft,
    'glyphMarginWidth': info.glyphMarginWidth,
    'glyphMarginDecorationLaneCount': info.glyphMarginDecorationLaneCount,
    'lineNumbersLeft': info.lineNumbersLeft,
    'lineNumbersWidth': info.lineNumbersWidth,
    'decorationsLeft': info.decorationsLeft,
    'decorationsWidth': info.decorationsWidth,
    'contentLeft': info.contentLeft,
    'contentWidth': info.contentWidth,
    'minimap': <String, Object?>{
      'renderMinimap': m.renderMinimap,
      'minimapLeft': m.minimapLeft,
      'minimapWidth': m.minimapWidth,
      'minimapHeightIsEditorHeight': m.minimapHeightIsEditorHeight,
      'minimapIsSampling': m.minimapIsSampling,
      'minimapScale': m.minimapScale,
      'minimapLineHeight': m.minimapLineHeight,
      'minimapCanvasInnerWidth': m.minimapCanvasInnerWidth,
      'minimapCanvasInnerHeight': m.minimapCanvasInnerHeight,
      'minimapCanvasOuterWidth': m.minimapCanvasOuterWidth,
      'minimapCanvasOuterHeight': m.minimapCanvasOuterHeight,
    },
    'viewportColumn': info.viewportColumn,
    'isWordWrapMinified': info.isWordWrapMinified,
    'isViewportWrapping': info.isViewportWrapping,
    'wrappingColumn': info.wrappingColumn,
    'verticalScrollbarWidth': info.verticalScrollbarWidth,
    'horizontalScrollbarHeight': info.horizontalScrollbarHeight,
    'overviewRuler': <String, Object?>{
      'top': r.top,
      'width': r.width,
      'height': r.height,
      'right': r.right,
    },
  };
}

/// 1:1: `doTest(input, expected)` — `assert.deepStrictEqual(...)`.
void doTest(IEditorLayoutProviderOpts input, Map<String, Object?> expected) {
  final Object actual = editorLayoutInfoToJson(computeLayoutInfo(input));
  assert(
    _jsonEqual(actual, expected),
    'deepStrictEqual mismatch\n'
    '  actual:   ${_describe(actual)}\n'
    '  expected: ${_describe(expected)}',
  );
}

/// 1:1: materialize `{...base, ...input}` into the typed options carrier.
IEditorLayoutProviderOpts _optsFromMap(Map<String, Object?> m) =>
    IEditorLayoutProviderOpts(
      outerWidth: m['outerWidth']! as num,
      outerHeight: m['outerHeight']! as num,
      showGlyphMargin: m['showGlyphMargin']! as bool,
      lineHeight: m['lineHeight']! as num,
      showLineNumbers: m['showLineNumbers']! as bool,
      lineNumbersMinChars: m['lineNumbersMinChars']! as num,
      lineNumbersDigitCount: m['lineNumbersDigitCount']! as num,
      maxLineNumber: m['maxLineNumber'] as num?,
      lineDecorationsWidth: m['lineDecorationsWidth']! as num,
      typicalHalfwidthCharacterWidth:
          m['typicalHalfwidthCharacterWidth']! as num,
      maxDigitWidth: m['maxDigitWidth']! as num,
      verticalScrollbarWidth: m['verticalScrollbarWidth']! as num,
      verticalScrollbarHasArrows: m['verticalScrollbarHasArrows']! as bool,
      scrollbarArrowSize: m['scrollbarArrowSize']! as num,
      horizontalScrollbarHeight: m['horizontalScrollbarHeight']! as num,
      minimap: m['minimap']! as bool,
      minimapSide: m['minimapSide']! as String,
      minimapRenderCharacters: m['minimapRenderCharacters']! as bool,
      minimapMaxColumn: m['minimapMaxColumn']! as num,
      minimapSize: m['minimapSize'] as String?,
      minimapScale: m['minimapScale'] as num?,
      pixelRatio: m['pixelRatio']! as num,
      wordWrap: m['wordWrap'] as String?,
      wordWrapColumn: m['wordWrapColumn'] as num?,
      wordWrapIndicator: m['wordWrapIndicator'] as bool?,
    );

/// The `{...base, ...input}` spreads of the two case loops.
Map<String, Object?> _merge(
        Map<String, Object?> base, Map<String, Object?> patch) =>
    <String, Object?>{...base, ...patch};

// ---------------------------------------------------------------------------
// noMinimap cases (source lines 126-417).
// ---------------------------------------------------------------------------

const Map<String, Object?> noMinimapInput = <String, Object?>{
  'showGlyphMargin': false,
  'lineHeight': 16,
  'lineDecorationsWidth': 10,
  'minimap': false,
  'minimapSide': 'right',
  'minimapRenderCharacters': true,
  'minimapMaxColumn': 150,
  'pixelRatio': 1,
};

const Map<String, Object?> noMinimapExpected = <String, Object?>{
  'glyphMarginLeft': 0,
  'glyphMarginWidth': 0,
  'glyphMarginDecorationLaneCount': 1,
  'lineNumbersLeft': 0,
  'decorationsWidth': 10,
  'isWordWrapMinified': false,
  'isViewportWrapping': false,
  'wrappingColumn': -1,
};

const Map<String, Object?> noMinimapLayout = <String, Object?>{
  'renderMinimap': RenderMinimap.none,
  'minimapLeft': 0,
  'minimapWidth': 0,
  'minimapHeightIsEditorHeight': false,
  'minimapIsSampling': false,
  'minimapScale': 1,
  'minimapLineHeight': 1,
  'minimapCanvasInnerWidth': 0,
  'minimapCanvasOuterWidth': 0,
};

typedef LayoutCase = ({
  String name,
  Map<String, Object?> input,
  Map<String, Object?> expected
});

const List<LayoutCase> noMinimapCases = <LayoutCase>[
  (
    name: 'EditorLayoutProvider 1',
    input: <String, Object?>{
      'outerWidth': 1000,
      'outerHeight': 800,
      'showLineNumbers': false,
      'lineNumbersMinChars': 0,
      'lineNumbersDigitCount': 1,
      'typicalHalfwidthCharacterWidth': 10,
      'maxDigitWidth': 10,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 1000,
      'height': 800,
      'lineNumbersWidth': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 990,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 800,
        'minimapCanvasOuterHeight': 800,
      },
      'viewportColumn': 98,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 800,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 1.1',
    input: <String, Object?>{
      'outerWidth': 1000,
      'outerHeight': 800,
      'showLineNumbers': false,
      'lineNumbersMinChars': 0,
      'lineNumbersDigitCount': 1,
      'typicalHalfwidthCharacterWidth': 10,
      'maxDigitWidth': 10,
      'verticalScrollbarWidth': 11,
      'horizontalScrollbarHeight': 12,
      'scrollbarArrowSize': 13,
      'verticalScrollbarHasArrows': true,
    },
    expected: <String, Object?>{
      'width': 1000,
      'height': 800,
      'lineNumbersWidth': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 990,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 800,
        'minimapCanvasOuterHeight': 800,
      },
      'viewportColumn': 97,
      'verticalScrollbarWidth': 11,
      'horizontalScrollbarHeight': 12,
      'overviewRuler': <String, Object?>{
        'top': 13,
        'width': 11,
        'height': 800 - 2 * 13,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 2',
    input: <String, Object?>{
      'outerWidth': 900,
      'outerHeight': 800,
      'showLineNumbers': false,
      'lineNumbersMinChars': 0,
      'lineNumbersDigitCount': 1,
      'typicalHalfwidthCharacterWidth': 10,
      'maxDigitWidth': 10,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 900,
      'height': 800,
      'lineNumbersWidth': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 890,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 800,
        'minimapCanvasOuterHeight': 800,
      },
      'viewportColumn': 88,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 800,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 3',
    input: <String, Object?>{
      'outerWidth': 900,
      'outerHeight': 900,
      'showLineNumbers': false,
      'lineNumbersMinChars': 0,
      'lineNumbersDigitCount': 1,
      'typicalHalfwidthCharacterWidth': 10,
      'maxDigitWidth': 10,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 900,
      'height': 900,
      'lineNumbersWidth': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 890,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 900,
        'minimapCanvasOuterHeight': 900,
      },
      'viewportColumn': 88,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 900,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 4',
    input: <String, Object?>{
      'outerWidth': 900,
      'outerHeight': 900,
      'showLineNumbers': false,
      'lineNumbersMinChars': 5,
      'lineNumbersDigitCount': 1,
      'typicalHalfwidthCharacterWidth': 10,
      'maxDigitWidth': 10,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 900,
      'height': 900,
      'lineNumbersWidth': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 890,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 900,
        'minimapCanvasOuterHeight': 900,
      },
      'viewportColumn': 88,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 900,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 5',
    input: <String, Object?>{
      'outerWidth': 900,
      'outerHeight': 900,
      'showLineNumbers': true,
      'lineNumbersMinChars': 5,
      'lineNumbersDigitCount': 1,
      'typicalHalfwidthCharacterWidth': 10,
      'maxDigitWidth': 10,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 900,
      'height': 900,
      'lineNumbersWidth': 50,
      'decorationsLeft': 50,
      'contentLeft': 60,
      'contentWidth': 840,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 900,
        'minimapCanvasOuterHeight': 900,
      },
      'viewportColumn': 83,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 900,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 6',
    input: <String, Object?>{
      'outerWidth': 900,
      'outerHeight': 900,
      'showLineNumbers': true,
      'lineNumbersMinChars': 5,
      'lineNumbersDigitCount': 5,
      'typicalHalfwidthCharacterWidth': 10,
      'maxDigitWidth': 10,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 900,
      'height': 900,
      'lineNumbersWidth': 50,
      'decorationsLeft': 50,
      'contentLeft': 60,
      'contentWidth': 840,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 900,
        'minimapCanvasOuterHeight': 900,
      },
      'viewportColumn': 83,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 900,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 7',
    input: <String, Object?>{
      'outerWidth': 900,
      'outerHeight': 900,
      'showLineNumbers': true,
      'lineNumbersMinChars': 5,
      'lineNumbersDigitCount': 6,
      'typicalHalfwidthCharacterWidth': 10,
      'maxDigitWidth': 10,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 900,
      'height': 900,
      'lineNumbersWidth': 60,
      'decorationsLeft': 60,
      'contentLeft': 70,
      'contentWidth': 830,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 900,
        'minimapCanvasOuterHeight': 900,
      },
      'viewportColumn': 82,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 900,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 8',
    input: <String, Object?>{
      'outerWidth': 900,
      'outerHeight': 900,
      'showLineNumbers': true,
      'lineNumbersMinChars': 5,
      'lineNumbersDigitCount': 6,
      'typicalHalfwidthCharacterWidth': 5,
      'maxDigitWidth': 5,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 900,
      'height': 900,
      'lineNumbersWidth': 30,
      'decorationsLeft': 30,
      'contentLeft': 40,
      'contentWidth': 860,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 900,
        'minimapCanvasOuterHeight': 900,
      },
      'viewportColumn': 171,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 900,
        'right': 0,
      },
    },
  ),
  (
    name: 'EditorLayoutProvider 8 - rounds floats',
    input: <String, Object?>{
      'outerWidth': 900,
      'outerHeight': 900,
      'showLineNumbers': true,
      'lineNumbersMinChars': 5,
      'lineNumbersDigitCount': 6,
      'typicalHalfwidthCharacterWidth': 5.05,
      'maxDigitWidth': 5.05,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'scrollbarArrowSize': 0,
      'verticalScrollbarHasArrows': false,
    },
    expected: <String, Object?>{
      'width': 900,
      'height': 900,
      'lineNumbersWidth': 30,
      'decorationsLeft': 30,
      'contentLeft': 40,
      'contentWidth': 860,
      'minimap': <String, Object?>{
        ...noMinimapLayout,
        'minimapCanvasInnerHeight': 900,
        'minimapCanvasOuterHeight': 900,
      },
      'viewportColumn': 169,
      'verticalScrollbarWidth': 0,
      'horizontalScrollbarHeight': 0,
      'overviewRuler': <String, Object?>{
        'top': 0,
        'width': 0,
        'height': 900,
        'right': 0,
      },
    },
  ),
];

/// 1:1: the `for (const [name, input, expected] of noMinimapCases)` loop.
void testNoMinimapCases() {
  for (final LayoutCase c in noMinimapCases) {
    doTest(
      _optsFromMap(_merge(noMinimapInput, c.input)),
      _merge(noMinimapExpected, c.expected),
    );
  }
}

// ---------------------------------------------------------------------------
// minimap cases (source lines 419-665).
// ---------------------------------------------------------------------------

const Map<String, Object?> minimapInput = <String, Object?>{
  'outerWidth': 1000,
  'outerHeight': 800,
  'showGlyphMargin': false,
  'lineHeight': 16,
  'showLineNumbers': false,
  'lineNumbersMinChars': 0,
  'lineDecorationsWidth': 10,
  'typicalHalfwidthCharacterWidth': 10,
  'maxDigitWidth': 10,
  'verticalScrollbarWidth': 0,
  'horizontalScrollbarHeight': 0,
  'scrollbarArrowSize': 0,
  'verticalScrollbarHasArrows': false,
  'minimap': true,
  'minimapRenderCharacters': true,
  'minimapMaxColumn': 150,
};

const Map<String, Object?> minimapExpected = <String, Object?>{
  'width': 1000,
  'height': 800,
  'glyphMarginWidth': 0,
  'glyphMarginDecorationLaneCount': 1,
  'lineNumbersWidth': 0,
  'decorationsWidth': 10,
  'isWordWrapMinified': false,
  'isViewportWrapping': false,
  'wrappingColumn': -1,
  'verticalScrollbarWidth': 0,
  'horizontalScrollbarHeight': 0,
  'overviewRuler': <String, Object?>{
    'top': 0,
    'width': 0,
    'height': 800,
    'right': 0,
  },
};

const Map<String, Object?> minimapLayout = <String, Object?>{
  'renderMinimap': RenderMinimap.text,
  'minimapCanvasOuterHeight': 800,
};

const List<LayoutCase> minimapCases = <LayoutCase>[
  (
    name: 'EditorLayoutProvider 9 - render minimap',
    input: <String, Object?>{
      'lineNumbersDigitCount': 1,
      'minimapSide': 'right',
      'pixelRatio': 1,
    },
    expected: <String, Object?>{
      'glyphMarginLeft': 0,
      'lineNumbersLeft': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 893,
      'minimap': <String, Object?>{
        ...minimapLayout,
        'minimapLeft': 903,
        'minimapWidth': 97,
        'minimapHeightIsEditorHeight': false,
        'minimapIsSampling': false,
        'minimapScale': 1,
        'minimapLineHeight': 2,
        'minimapCanvasInnerWidth': 97,
        'minimapCanvasInnerHeight': 800,
        'minimapCanvasOuterWidth': 97,
      },
      'viewportColumn': 89,
    },
  ),
  (
    name: 'EditorLayoutProvider 9 - render minimap with pixelRatio = 2',
    input: <String, Object?>{
      'lineNumbersDigitCount': 1,
      'minimapSide': 'right',
      'pixelRatio': 2,
    },
    expected: <String, Object?>{
      'glyphMarginLeft': 0,
      'lineNumbersLeft': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 893,
      'minimap': <String, Object?>{
        ...minimapLayout,
        'minimapLeft': 903,
        'minimapWidth': 97,
        'minimapHeightIsEditorHeight': false,
        'minimapIsSampling': false,
        'minimapScale': 2,
        'minimapLineHeight': 4,
        'minimapCanvasInnerWidth': 194,
        'minimapCanvasInnerHeight': 1600,
        'minimapCanvasOuterWidth': 97,
      },
      'viewportColumn': 89,
    },
  ),
  (
    name: 'EditorLayoutProvider 9 - render minimap with pixelRatio = 4',
    input: <String, Object?>{
      'lineNumbersDigitCount': 1,
      'minimapSide': 'right',
      'pixelRatio': 4,
    },
    expected: <String, Object?>{
      'glyphMarginLeft': 0,
      'lineNumbersLeft': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 935,
      'minimap': <String, Object?>{
        ...minimapLayout,
        'minimapLeft': 945,
        'minimapWidth': 55,
        'minimapHeightIsEditorHeight': false,
        'minimapIsSampling': false,
        'minimapScale': 2,
        'minimapLineHeight': 4,
        'minimapCanvasInnerWidth': 220,
        'minimapCanvasInnerHeight': 3200,
        'minimapCanvasOuterWidth': 55,
      },
      'viewportColumn': 93,
    },
  ),
  (
    name: 'EditorLayoutProvider 10 - render minimap to left',
    input: <String, Object?>{
      'lineNumbersDigitCount': 1,
      'minimapSide': 'left',
      'pixelRatio': 4,
    },
    expected: <String, Object?>{
      'glyphMarginLeft': 55,
      'lineNumbersLeft': 55,
      'decorationsLeft': 55,
      'contentLeft': 65,
      'contentWidth': 935,
      'minimap': <String, Object?>{
        ...minimapLayout,
        'minimapLeft': 0,
        'minimapWidth': 55,
        'minimapHeightIsEditorHeight': false,
        'minimapIsSampling': false,
        'minimapScale': 2,
        'minimapLineHeight': 4,
        'minimapCanvasInnerWidth': 220,
        'minimapCanvasInnerHeight': 3200,
        'minimapCanvasOuterWidth': 55,
      },
      'viewportColumn': 93,
    },
  ),
  (
    name: 'EditorLayoutProvider 11 - minimap mode cover without sampling',
    input: <String, Object?>{
      'lineNumbersDigitCount': 3,
      'maxLineNumber': 120,
      'minimapSide': 'right',
      'minimapSize': 'fill',
      'pixelRatio': 2,
    },
    expected: <String, Object?>{
      'glyphMarginLeft': 0,
      'lineNumbersLeft': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 893,
      'minimap': <String, Object?>{
        ...minimapLayout,
        'minimapLeft': 903,
        'minimapWidth': 97,
        'minimapHeightIsEditorHeight': true,
        'minimapIsSampling': false,
        'minimapScale': 3,
        'minimapLineHeight': 13,
        'minimapCanvasInnerWidth': 291,
        'minimapCanvasInnerHeight': 1560,
        'minimapCanvasOuterWidth': 97,
      },
      'viewportColumn': 89,
    },
  ),
  (
    name: 'EditorLayoutProvider 12 - minimap mode cover with sampling',
    input: <String, Object?>{
      'lineNumbersDigitCount': 4,
      'maxLineNumber': 2500,
      'minimapSide': 'right',
      'minimapSize': 'fill',
      'pixelRatio': 2,
    },
    expected: <String, Object?>{
      'glyphMarginLeft': 0,
      'lineNumbersLeft': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 935,
      'minimap': <String, Object?>{
        ...minimapLayout,
        'minimapLeft': 945,
        'minimapWidth': 55,
        'minimapHeightIsEditorHeight': true,
        'minimapIsSampling': true,
        'minimapScale': 1,
        'minimapLineHeight': 1,
        'minimapCanvasInnerWidth': 110,
        'minimapCanvasInnerHeight': 1600,
        'minimapCanvasOuterWidth': 55,
      },
      'viewportColumn': 93,
    },
  ),
  (
    name: 'EditorLayoutProvider 13 - minimap mode contain without sampling',
    input: <String, Object?>{
      'lineNumbersDigitCount': 3,
      'maxLineNumber': 120,
      'minimapSide': 'right',
      'minimapSize': 'fit',
      'pixelRatio': 2,
    },
    expected: <String, Object?>{
      'glyphMarginLeft': 0,
      'lineNumbersLeft': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 893,
      'minimap': <String, Object?>{
        ...minimapLayout,
        'minimapLeft': 903,
        'minimapWidth': 97,
        'minimapHeightIsEditorHeight': false,
        'minimapIsSampling': false,
        'minimapScale': 2,
        'minimapLineHeight': 4,
        'minimapCanvasInnerWidth': 194,
        'minimapCanvasInnerHeight': 1600,
        'minimapCanvasOuterWidth': 97,
      },
      'viewportColumn': 89,
    },
  ),
  (
    name: 'EditorLayoutProvider 14 - minimap mode contain with sampling',
    input: <String, Object?>{
      'lineNumbersDigitCount': 4,
      'maxLineNumber': 2500,
      'minimapSide': 'right',
      'minimapSize': 'fit',
      'pixelRatio': 2,
    },
    expected: <String, Object?>{
      'glyphMarginLeft': 0,
      'lineNumbersLeft': 0,
      'decorationsLeft': 0,
      'contentLeft': 10,
      'contentWidth': 935,
      'minimap': <String, Object?>{
        ...minimapLayout,
        'minimapLeft': 945,
        'minimapWidth': 55,
        'minimapHeightIsEditorHeight': true,
        'minimapIsSampling': true,
        'minimapScale': 1,
        'minimapLineHeight': 1,
        'minimapCanvasInnerWidth': 110,
        'minimapCanvasInnerHeight': 1600,
        'minimapCanvasOuterWidth': 55,
      },
      'viewportColumn': 93,
    },
  ),
];

/// 1:1: the `for (const [name, input, expected] of minimapCases)` loop.
void testMinimapCases() {
  for (final LayoutCase c in minimapCases) {
    doTest(
      _optsFromMap(_merge(minimapInput, c.input)),
      _merge(minimapExpected, c.expected),
    );
  }
}

// ---------------------------------------------------------------------------
// Standalone tests (source lines 667-810).
// ---------------------------------------------------------------------------

const List<num> _pixelRatios = <num>[1, 1.25, 1.5, 1.75, 1.96, 1.9999998, 2, 2.5];

/// 1:1: the `actual` array of
/// `test('issue #236999: the minimap scale does not jump ...')`.
List<List<num>> minimapScaleMatrixForTest() => <List<num>>[
      for (final num minimapScale in const <num>[1, 2, 3])
        <num>[
          for (final num pixelRatio in _pixelRatios)
            computeLayoutInfo(_optsFromMap(<String, Object?>{
              ...minimapInput,
              'lineNumbersDigitCount': 1,
              'minimapSide': 'right',
              'minimapScale': minimapScale,
              'pixelRatio': pixelRatio,
            })).minimap.minimapScale,
        ],
    ];

/// 1:1: `test('issue #236999: the minimap scale does not jump ...')`.
void testIssue236999MinimapScale() {
  const Object expected = <Object?>[
    <num>[1, 1, 1, 1, 2, 2, 2, 2],
    <num>[2, 2, 3, 3, 4, 4, 4, 4],
    <num>[3, 3, 4, 5, 6, 6, 6, 6],
  ];
  final Object actual = minimapScaleMatrixForTest();
  assert(
    _jsonEqual(actual, expected),
    'deepStrictEqual mismatch\n'
    '  actual:   ${_describe(actual)}\n'
    '  expected: ${_describe(expected)}',
  );
}

/// 1:1: the input literal of `test('issue #31312: When wrapping, leave 2px ...')`.
IEditorLayoutProviderOpts issue31312InputForTest() =>
    IEditorLayoutProviderOpts(
      outerWidth: 1201,
      outerHeight: 422,
      showGlyphMargin: true,
      lineHeight: 30,
      showLineNumbers: true,
      lineNumbersMinChars: 3,
      lineNumbersDigitCount: 1,
      lineDecorationsWidth: 26,
      typicalHalfwidthCharacterWidth: 12.04296875,
      maxDigitWidth: 12.04296875,
      verticalScrollbarWidth: 14,
      horizontalScrollbarHeight: 10,
      scrollbarArrowSize: 11,
      verticalScrollbarHasArrows: false,
      minimap: true,
      minimapSide: 'right',
      minimapRenderCharacters: true,
      minimapMaxColumn: 120,
      pixelRatio: 2,
    );

/// 1:1: `test('issue #31312: When wrapping, leave 2px for the cursor')`.
void testIssue31312LeaveTwoPixelsForCursor() {
  doTest(issue31312InputForTest(), const <String, Object?>{
    'width': 1201,
    'height': 422,
    'glyphMarginLeft': 0,
    'glyphMarginWidth': 30,
    'glyphMarginDecorationLaneCount': 1,
    'lineNumbersLeft': 30,
    'lineNumbersWidth': 36,
    'decorationsLeft': 66,
    'decorationsWidth': 26,
    'contentLeft': 92,
    'contentWidth': 1018,
    'minimap': <String, Object?>{
      'renderMinimap': RenderMinimap.text,
      'minimapLeft': 1096,
      'minimapWidth': 91,
      'minimapHeightIsEditorHeight': false,
      'minimapIsSampling': false,
      'minimapScale': 2,
      'minimapLineHeight': 4,
      'minimapCanvasInnerWidth': 182,
      'minimapCanvasInnerHeight': 844,
      'minimapCanvasOuterWidth': 91,
      'minimapCanvasOuterHeight': 422,
    },
    'viewportColumn': 83,
    'isWordWrapMinified': false,
    'isViewportWrapping': false,
    'wrappingColumn': -1,
    'verticalScrollbarWidth': 14,
    'horizontalScrollbarHeight': 10,
    'overviewRuler': <String, Object?>{
      'top': 0,
      'width': 14,
      'height': 422,
      'right': 0,
    },
  });
}

/// 1:1: the `wrappingOf` closure of the word-wrap-indicator test.
Map<String, Object?> _wrappingOf(
  String wordWrap,
  bool wordWrapIndicator, [
  num wordWrapColumn = 40,
]) {
  final EditorLayoutInfo layoutInfo = computeLayoutInfo(
    IEditorLayoutProviderOpts(
      outerWidth: 1000,
      outerHeight: 800,
      showGlyphMargin: false,
      lineHeight: 16,
      showLineNumbers: false,
      lineNumbersMinChars: 0,
      lineNumbersDigitCount: 1,
      lineDecorationsWidth: 10,
      typicalHalfwidthCharacterWidth: 10,
      maxDigitWidth: 10,
      verticalScrollbarWidth: 0,
      verticalScrollbarHasArrows: false,
      scrollbarArrowSize: 0,
      horizontalScrollbarHeight: 0,
      minimap: false,
      minimapSide: 'right',
      minimapRenderCharacters: true,
      minimapMaxColumn: 150,
      pixelRatio: 1,
      wordWrap: wordWrap,
      wordWrapColumn: wordWrapColumn,
      wordWrapIndicator: wordWrapIndicator,
    ),
  );
  // `viewportColumn` keeps describing how many columns the viewport holds.
  return <String, Object?>{
    'viewportColumn': layoutInfo.viewportColumn,
    'wrappingColumn': layoutInfo.wrappingColumn,
  };
}

/// 1:1: the `actual` object of
/// `test('leaves the rightmost column for the word wrap indicator ...')`.
Map<String, Object?> wordWrapIndicatorMatrixForTest() =>
    <String, Object?>{
      'off': _wrappingOf('off', true),
      'on': _wrappingOf('on', false),
      'onWithIndicator': _wrappingOf('on', true),
      'bounded': _wrappingOf('bounded', false),
      'boundedWithIndicator': _wrappingOf('bounded', true),
      'wordWrapColumnWithIndicator': _wrappingOf('wordWrapColumn', true),
      'wideWordWrapColumnWithIndicator':
          _wrappingOf('wordWrapColumn', true, 120),
    };

/// 1:1: `test('leaves the rightmost column for the word wrap indicator ...')`.
void testWordWrapIndicatorLeavesRightmostColumn() {
  const Object expected = <String, Object?>{
    'off': <String, Object?>{'viewportColumn': 98, 'wrappingColumn': -1},
    'on': <String, Object?>{'viewportColumn': 98, 'wrappingColumn': 98},
    'onWithIndicator': <String, Object?>{
      'viewportColumn': 98,
      'wrappingColumn': 97,
    },
    'bounded': <String, Object?>{'viewportColumn': 98, 'wrappingColumn': 40},
    'boundedWithIndicator': <String, Object?>{
      'viewportColumn': 98,
      'wrappingColumn': 40,
    },
    'wordWrapColumnWithIndicator': <String, Object?>{
      'viewportColumn': 98,
      'wrappingColumn': 40,
    },
    'wideWordWrapColumnWithIndicator': <String, Object?>{
      'viewportColumn': 98,
      'wrappingColumn': 120,
    },
  };
  final Object actual = wordWrapIndicatorMatrixForTest();
  assert(
    _jsonEqual(actual, expected),
    'deepStrictEqual mismatch\n'
    '  actual:   ${_describe(actual)}\n'
    '  expected: ${_describe(expected)}',
  );
}

/// Public helpers for `test/monaco_batch239_test.dart`: resolve the JSON form
/// of a named case's real computed value and of its source expected literal.
Object? actualForCaseNameForTest(String name) {
  for (final LayoutCase c in noMinimapCases) {
    if (c.name == name) {
      return editorLayoutInfoToJson(
        computeLayoutInfo(_optsFromMap(_merge(noMinimapInput, c.input))),
      );
    }
  }
  for (final LayoutCase c in minimapCases) {
    if (c.name == name) {
      return editorLayoutInfoToJson(
        computeLayoutInfo(_optsFromMap(_merge(minimapInput, c.input))),
      );
    }
  }
  if (name ==
      'issue #236999: the minimap scale does not jump when the pixel ratio crosses 2') {
    return minimapScaleMatrixForTest();
  }
  if (name == 'issue #31312: When wrapping, leave 2px for the cursor') {
    return editorLayoutInfoToJson(
      computeLayoutInfo(issue31312InputForTest()),
    );
  }
  if (name ==
      'leaves the rightmost column for the word wrap indicator when wrapping to the viewport') {
    return wordWrapIndicatorMatrixForTest();
  }
  return null;
}

Object? expectedForCaseNameForTest(String name) {
  for (final LayoutCase c in noMinimapCases) {
    if (c.name == name) return _merge(noMinimapExpected, c.expected);
  }
  for (final LayoutCase c in minimapCases) {
    if (c.name == name) return _merge(minimapExpected, c.expected);
  }
  return null;
}

/// Run all 21 ported mocha cases (10 + 8 data-driven + 3 standalone).
void runAllEditorLayoutProviderTests() {
  testNoMinimapCases();
  testMinimapCases();
  testIssue236999MinimapScale();
  testIssue31312LeaveTwoPixelsForCursor();
  testWordWrapIndicatorLeavesRightmostColumn();
}
