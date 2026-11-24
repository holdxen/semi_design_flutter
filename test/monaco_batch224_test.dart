// Truth replay for batch224 (editorOptions.ts lines 4191-4397):
//   scrollbar: IEditorScrollbarOptions, InternalEditorScrollbarOptions,
//   _scrollbarVisibilityFromString, EditorScrollbar.
//
// Expectations come from `tool/ts2dart/batch224_truth.json`, produced by
// `tool/ts2dart/_batch224_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private class/helper exposed through a probe tail).
// JS `undefined` is replayed as Dart `null` for optional inputs, per the
// convention documented in editorOptions.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/scrollable.dart' show ScrollbarVisibility;
import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth(String file) =>
    _map(jsonDecode(File('tool/ts2dart/$file').readAsStringSync()));

Map<String, Object?> _scrollbar(
        opts.InternalEditorScrollbarOptions value) =>
    <String, Object?>{
      'arrowSize': value.arrowSize,
      'vertical': value.vertical,
      'horizontal': value.horizontal,
      'useShadows': value.useShadows,
      'verticalHasArrows': value.verticalHasArrows,
      'horizontalHasArrows': value.horizontalHasArrows,
      'handleMouseWheel': value.handleMouseWheel,
      'alwaysConsumeMouseWheel': value.alwaysConsumeMouseWheel,
      'horizontalScrollbarSize': value.horizontalScrollbarSize,
      'horizontalSliderSize': value.horizontalSliderSize,
      'verticalScrollbarSize': value.verticalScrollbarSize,
      'verticalSliderSize': value.verticalSliderSize,
      'scrollByPage': value.scrollByPage,
      'ignoreHorizontalScrollbarInContentHeight':
          value.ignoreHorizontalScrollbarInContentHeight,
    };

// Inputs for every captured validation branch of `EditorScrollbar.validate`.
Map<String, Object?> _validationInputs() => <String, Object?>{
      'undefined': null,
      'null': null,
      'number': 42,
      'string': 'scrollbar',
      'boolean': true,
      'array': <Object?>[],
      'emptyObject': <String, Object?>{},
      'visibilityHidden': <String, Object?>{
        'vertical': 'hidden',
        'horizontal': 'visible',
      },
      'visibilityAuto': <String, Object?>{
        'vertical': 'auto',
        'horizontal': 'auto',
      },
      'visibilityBogus': <String, Object?>{
        'vertical': 'bogus',
        'horizontal': '',
      },
      'visibilityNonString': <String, Object?>{
        'vertical': 0,
        'horizontal': null,
      },
      'clampsLow': <String, Object?>{
        'arrowSize': -5,
        'horizontalScrollbarSize': -1,
        'verticalScrollbarSize': -1000,
        'horizontalSliderSize': -5,
        'verticalSliderSize': -99999,
      },
      'clampsHigh': <String, Object?>{
        'arrowSize': 1000,
        'horizontalScrollbarSize': 1001,
        'verticalScrollbarSize': 99999,
        'horizontalSliderSize': 1000,
        'verticalSliderSize': 5000,
      },
      'clampsFloat': <String, Object?>{
        'arrowSize': 11.9,
        'horizontalScrollbarSize': 12.9,
        'verticalScrollbarSize': 14.9,
      },
      'numericStrings': <String, Object?>{
        'arrowSize': '7px',
        'horizontalScrollbarSize': '20',
        'verticalScrollbarSize': '30px',
      },
      'bogusNumbers': <String, Object?>{
        'arrowSize': 'abc',
        'horizontalScrollbarSize': null,
        'verticalScrollbarSize': true,
      },
      'sliderFallback': <String, Object?>{
        'horizontalScrollbarSize': 20,
        'verticalScrollbarSize': 30,
      },
      'sliderOverride': <String, Object?>{
        'horizontalScrollbarSize': 20,
        'verticalScrollbarSize': 30,
        'horizontalSliderSize': 100,
        'verticalSliderSize': 200,
      },
      'sliderClamped': <String, Object?>{
        'horizontalScrollbarSize': 40,
        'verticalScrollbarSize': 50,
        'horizontalSliderSize': -5,
        'verticalSliderSize': 5000,
      },
      'booleansFalse': <String, Object?>{
        'useShadows': false,
        'verticalHasArrows': false,
        'horizontalHasArrows': false,
        'handleMouseWheel': false,
        'alwaysConsumeMouseWheel': false,
        'scrollByPage': false,
        'ignoreHorizontalScrollbarInContentHeight': false,
      },
      'booleansTrue': <String, Object?>{
        'useShadows': true,
        'verticalHasArrows': true,
        'horizontalHasArrows': true,
        'handleMouseWheel': true,
        'alwaysConsumeMouseWheel': true,
        'scrollByPage': true,
        'ignoreHorizontalScrollbarInContentHeight': true,
      },
      'booleansStringFalse': <String, Object?>{
        'useShadows': 'false',
        'verticalHasArrows': 'false',
        'horizontalHasArrows': 'false',
        'handleMouseWheel': 'false',
        'alwaysConsumeMouseWheel': 'false',
        'scrollByPage': 'false',
        'ignoreHorizontalScrollbarInContentHeight': 'false',
      },
      'booleansCoerced': <String, Object?>{
        'useShadows': 0,
        'verticalHasArrows': 1,
        'horizontalHasArrows': '',
        'handleMouseWheel': 'yes',
        'alwaysConsumeMouseWheel': 0,
        'scrollByPage': 1,
        'ignoreHorizontalScrollbarInContentHeight': '',
      },
      'booleansUndefined': <String, Object?>{
        'useShadows': null,
        'verticalHasArrows': null,
        'horizontalHasArrows': null,
        'handleMouseWheel': null,
        'alwaysConsumeMouseWheel': null,
        'scrollByPage': null,
        'ignoreHorizontalScrollbarInContentHeight': null,
      },
      'allFields': <String, Object?>{
        'arrowSize': 9,
        'vertical': 'visible',
        'horizontal': 'hidden',
        'useShadows': false,
        'verticalHasArrows': true,
        'horizontalHasArrows': true,
        'handleMouseWheel': false,
        'alwaysConsumeMouseWheel': false,
        'horizontalScrollbarSize': 22,
        'verticalScrollbarSize': 33,
        'horizontalSliderSize': 44,
        'verticalSliderSize': 55,
        'scrollByPage': true,
        'ignoreHorizontalScrollbarInContentHeight': true,
      },
    };

class _Options implements opts.IComputedEditorOptions {
  final Map<int, Object?> values;
  _Options(this.values);
  @override
  Object? get(Object id) => values[id];
}

Map<String, Object?> _json(opts.EditorLayoutInfo value) =>
    <String, Object?>{
      'width': value.width,
      'height': value.height,
      'glyphMarginLeft': value.glyphMarginLeft,
      'glyphMarginWidth': value.glyphMarginWidth,
      'glyphMarginDecorationLaneCount': value.glyphMarginDecorationLaneCount,
      'lineNumbersLeft': value.lineNumbersLeft,
      'lineNumbersWidth': value.lineNumbersWidth,
      'decorationsLeft': value.decorationsLeft,
      'decorationsWidth': value.decorationsWidth,
      'contentLeft': value.contentLeft,
      'contentWidth': value.contentWidth,
      'minimap': _mini(value.minimap),
      'viewportColumn': value.viewportColumn,
      'isWordWrapMinified': value.isWordWrapMinified,
      'isViewportWrapping': value.isViewportWrapping,
      'wrappingColumn': value.wrappingColumn,
      'verticalScrollbarWidth': value.verticalScrollbarWidth,
      'horizontalScrollbarHeight': value.horizontalScrollbarHeight,
      'overviewRuler': <String, Object?>{
        'top': value.overviewRuler.top,
        'width': value.overviewRuler.width,
        'height': value.overviewRuler.height,
        'right': value.overviewRuler.right,
      },
    };

Map<String, Object?> _mini(opts.EditorMinimapLayoutInfo value) =>
    <String, Object?>{
      'renderMinimap': value.renderMinimap,
      'minimapLeft': value.minimapLeft,
      'minimapWidth': value.minimapWidth,
      'minimapHeightIsEditorHeight': value.minimapHeightIsEditorHeight,
      'minimapIsSampling': value.minimapIsSampling,
      'minimapScale': value.minimapScale,
      'minimapLineHeight': value.minimapLineHeight,
      'minimapCanvasInnerWidth': value.minimapCanvasInnerWidth,
      'minimapCanvasInnerHeight': value.minimapCanvasInnerHeight,
      'minimapCanvasOuterWidth': value.minimapCanvasOuterWidth,
      'minimapCanvasOuterHeight': value.minimapCanvasOuterHeight,
    };

Map<int, Object?> _layoutValues(opts.InternalEditorScrollbarOptions scrollbar) =>
    <int, Object?>{
      opts.EditorOption.glyphMargin: true,
      opts.EditorOption.lineNumbers:
          const opts.InternalEditorRenderLineNumbersOptions(1),
      opts.EditorOption.lineNumbersMinChars: 5,
      opts.EditorOption.scrollBeyondLastLine: true,
      opts.EditorOption.padding:
          const opts.EditorPaddingOptions(top: 10, bottom: 20),
      opts.EditorOption.lineDecorationsWidth: 10,
      opts.EditorOption.minimap: opts.EditorMinimapOptions(
        enabled: true,
        size: 'proportional',
        side: 'right',
        showSlider: 'mouseover',
        renderCharacters: true,
        maxColumn: 120,
        scale: 1,
      ),
      opts.EditorOption.scrollbar: scrollbar,
      opts.EditorOption.folding: true,
      opts.EditorOption.showFoldingControls: 'mouseover',
      opts.EditorOption.wordWrapOverride2: 'inherit',
      opts.EditorOption.wordWrapOverride1: 'inherit',
      opts.EditorOption.wordWrap: 'off',
      opts.EditorOption.wordWrapColumn: 80,
      opts.EditorOption.wordWrapIndicator: false,
      opts.EditorOption.accessibilitySupport: AccessibilitySupport.Unknown,
    };

opts.EditorLayoutInfo _layout(
        opts.InternalEditorScrollbarOptions scrollbar) =>
    opts.EditorLayoutInfoComputer.computeLayout(
      _Options(_layoutValues(scrollbar)),
      memory: null,
      outerWidth: 1000,
      outerHeight: 800,
      isDominatedByLongLines: false,
      lineHeight: 20,
      viewLineCount: 100,
      lineNumbersDigitCount: 3,
      typicalHalfwidthCharacterWidth: 8,
      maxDigitWidth: 8,
      pixelRatio: 1,
      glyphMarginDecorationLaneCount: 1,
    );

void main() {
  final Map<String, dynamic> truth = _truth('batch224_truth.json');
  final Map<String, dynamic> expected = _map(truth['scrollbar']);
  final opts.EditorScrollbar option = opts.EditorScrollbar();

  test('ScrollbarVisibility constants match source', () {
    final Map<String, dynamic> constants =
        _map(truth['scrollbarVisibility']);
    expect(ScrollbarVisibility.Auto, constants['Auto']);
    expect(ScrollbarVisibility.Hidden, constants['Hidden']);
    expect(ScrollbarVisibility.Visible, constants['Visible']);
  });

  test('EditorScrollbar id, name, defaults and full schema match source', () {
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_scrollbar(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);
    // The scrollbar schema region has no platform-dependent strings.
    expect(truth['platformSchemaStrings'], isEmpty);
  });

  test('visibility string branches match source', () {
    final Map<String, dynamic> branches =
        _map(expected['visibilityFromString']);
    const Map<String, Object?> inputs = <String, Object?>{
      'hidden': 'hidden',
      'visible': 'visible',
      'auto': 'auto',
      'unknown': 'bogus',
      'empty': '',
      'undefined': null,
      'null': null,
      'number': 42,
      'boolean': true,
    };
    inputs.forEach((String key, Object? input) {
      // Dart carries JS `undefined` as `null`; the option's default is Auto.
      expect(
        option.validate(<String, Object?>{'vertical': input}).vertical,
        branches[key],
        reason: key,
      );
    });
    // `hiddenDefaultVisible` exercises a non-Auto helper default; that helper
    // is library-private, so its truth is recorded but not replayed here.
  });

  test('EditorScrollbar validation matches every source branch', () {
    final Map<String, dynamic> cases = _map(expected['validate']);
    final Map<String, Object?> inputs = _validationInputs();
    cases.forEach((String key, Object? value) {
      expect(inputs.containsKey(key), isTrue, reason: key);
      expect(_scrollbar(option.validate(inputs[key])), value, reason: key);
    });
  });

  test('layoutInfo is unchanged with the evolved scrollbar carrier', () {
    final Map<String, dynamic> truth210 = _truth('batch210_truth.json');
    // Fully populated carrier (all 14 source fields) vs. the minimal carrier
    // used by batch210: layoutInfo reads only the same three fields.
    final opts.InternalEditorScrollbarOptions full =
        option.validate(<String, Object?>{});
    expect(_scrollbar(full), expected['defaultValue']);
    expect(_json(_layout(full)), truth210['proportional']);

    final opts.InternalEditorScrollbarOptions arrows = option.validate(
        <String, Object?>{'verticalHasArrows': true, 'arrowSize': 5});
    final opts.EditorLayoutInfo withArrows = _layout(arrows);
    expect(withArrows.overviewRuler.top, 5);
    expect(withArrows.overviewRuler.height, 800 - 2 * 5);
    expect(withArrows.verticalScrollbarWidth, arrows.verticalScrollbarSize);
    expect(
        withArrows.horizontalScrollbarHeight, arrows.horizontalScrollbarSize);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
