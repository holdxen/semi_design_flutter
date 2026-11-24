// Truth replay for batch222 (editorOptions.ts lines 3886-4099):
//   quickSuggestions, renderLineNumbers, renderValidationDecorations,
//   filterFontDecorations.
//
// Expectations come from `tool/ts2dart/batch222_truth.json`, produced by
// `tool/ts2dart/_batch222_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private classes exposed through a probe tail).
// Dart cannot share a TS function object: the custom line-number callback is
// a Dart closure here, and the harness records its presence plus its result
// for sample line number 7. TS `undefined` is replayed by omitting the
// optional argument to `EditorRenderLineNumbersOption.validate`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch222_truth.json').readAsStringSync()));

Map<String, Object?> _quick(opts.InternalQuickSuggestionsOptions value) =>
    <String, Object?>{
      'other': value.other,
      'comments': value.comments,
      'strings': value.strings,
    };

Map<String, Object?> _lineNumbers(
        opts.InternalEditorRenderLineNumbersOptions value) =>
    <String, Object?>{
      'renderType': value.renderType,
      'hasRenderFn': value.renderFn != null,
    };

class _Options implements opts.IComputedEditorOptions {
  _Options(this.values);
  final Map<int, Object?> values;
  @override
  Object? get(Object id) => values[id];
}

Map<String, Object?> _mini(opts.EditorMinimapLayoutInfo v) =>
    <String, Object?>{
      'renderMinimap': v.renderMinimap,
      'minimapLeft': v.minimapLeft,
      'minimapWidth': v.minimapWidth,
      'minimapHeightIsEditorHeight': v.minimapHeightIsEditorHeight,
      'minimapIsSampling': v.minimapIsSampling,
      'minimapScale': v.minimapScale,
      'minimapLineHeight': v.minimapLineHeight,
      'minimapCanvasInnerWidth': v.minimapCanvasInnerWidth,
      'minimapCanvasInnerHeight': v.minimapCanvasInnerHeight,
      'minimapCanvasOuterWidth': v.minimapCanvasOuterWidth,
      'minimapCanvasOuterHeight': v.minimapCanvasOuterHeight,
    };

Map<String, Object?> _layout(opts.EditorLayoutInfo v) => <String, Object?>{
      'width': v.width,
      'height': v.height,
      'glyphMarginLeft': v.glyphMarginLeft,
      'glyphMarginWidth': v.glyphMarginWidth,
      'glyphMarginDecorationLaneCount': v.glyphMarginDecorationLaneCount,
      'lineNumbersLeft': v.lineNumbersLeft,
      'lineNumbersWidth': v.lineNumbersWidth,
      'decorationsLeft': v.decorationsLeft,
      'decorationsWidth': v.decorationsWidth,
      'contentLeft': v.contentLeft,
      'contentWidth': v.contentWidth,
      'minimap': _mini(v.minimap),
      'viewportColumn': v.viewportColumn,
      'isWordWrapMinified': v.isWordWrapMinified,
      'isViewportWrapping': v.isViewportWrapping,
      'wrappingColumn': v.wrappingColumn,
      'verticalScrollbarWidth': v.verticalScrollbarWidth,
      'horizontalScrollbarHeight': v.horizontalScrollbarHeight,
      'overviewRuler': <String, Object?>{
        'top': v.overviewRuler.top,
        'width': v.overviewRuler.width,
        'height': v.overviewRuler.height,
        'right': v.overviewRuler.right,
      },
    };

Map<int, Object?> _layoutValues(
        opts.InternalEditorRenderLineNumbersOptions lineNumbers) =>
    <int, Object?>{
      opts.EditorOption.glyphMargin: true,
      opts.EditorOption.lineNumbers: lineNumbers,
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
      opts.EditorOption.scrollbar: const opts.InternalEditorScrollbarOptions(
        arrowSize: 11,
        verticalScrollbarSize: 14,
        horizontalScrollbarSize: 12,
        verticalHasArrows: false,
      ),
      opts.EditorOption.folding: true,
      opts.EditorOption.showFoldingControls: 'mouseover',
      opts.EditorOption.wordWrapIndicator: false,
      opts.EditorOption.wordWrapOverride2: 'inherit',
      opts.EditorOption.wordWrapOverride1: 'inherit',
      opts.EditorOption.wordWrap: 'off',
      opts.EditorOption.wordWrapColumn: 80,
      opts.EditorOption.accessibilitySupport: 0,
    };

opts.EditorLayoutInfo _computeLayout(Map<int, Object?> values) =>
    opts.EditorLayoutInfoComputer.computeLayout(
      _Options(values),
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
  final Map<String, dynamic> truth = _truth();

  test('QuickSuggestionsValue and IQuickSuggestionsOptions match source', () {
    final Map<String, dynamic> expected = _map(truth['quickSuggestions']);
    final List<Object?> anyOf = (_map(expected['schema'])['anyOf'] as List<Object?>);
    final List<Object?> enumValues = _map(anyOf[1])['enum'] as List<Object?>;

    expect(
      <Object?>[
        opts.QuickSuggestionsValue.on,
        opts.QuickSuggestionsValue.inline,
        opts.QuickSuggestionsValue.off,
        opts.QuickSuggestionsValue.offWhenInlineCompletions,
      ],
      enumValues,
    );

    final opts.IQuickSuggestionsOptions input = opts.IQuickSuggestionsOptions(
      other: true,
      comments: opts.QuickSuggestionsValue.on,
      strings: opts.QuickSuggestionsValue.off,
    );
    expect(input.other, true);
    expect(input.comments, opts.QuickSuggestionsValue.on);
    expect(input.strings, opts.QuickSuggestionsValue.off);
  });

  test('EditorQuickSuggestions matches source defaults, schema and validation',
      () {
    final Map<String, dynamic> expected = _map(truth['quickSuggestions']);
    final opts.EditorQuickSuggestions option = opts.EditorQuickSuggestions();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_quick(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);

    final Map<String, dynamic> cases = _map(expected['validate']);
    expect(_quick(option.validate(null)), cases['undefined']);
    expect(_quick(option.validate(null)), cases['null']);
    expect(_quick(option.validate(true)), cases['booleanTrue']);
    expect(_quick(option.validate(false)), cases['booleanFalse']);
    expect(_quick(option.validate('on')), cases['on']);
    expect(_quick(option.validate('inline')), cases['inline']);
    expect(_quick(option.validate('off')), cases['off']);
    expect(_quick(option.validate('offWhenInlineCompletions')),
        cases['offWhenInlineCompletions']);
    expect(_quick(option.validate('bogus')), cases['bogusString']);
    expect(_quick(option.validate(42)), cases['number']);
    expect(_quick(option.validate(<String, Object?>{})), cases['emptyObject']);
    expect(
      _quick(option.validate(<String, Object?>{
        'other': 'inline',
        'comments': 'on',
        'strings': 'offWhenInlineCompletions',
      })),
      cases['objectStrings'],
    );
    expect(
      _quick(option.validate(<String, Object?>{
        'other': true,
        'comments': false,
        'strings': true,
      })),
      cases['objectBooleans'],
    );
    expect(
      _quick(option.validate(<String, Object?>{
        'other': 'bogus',
        'comments': true,
        'strings': 'off',
      })),
      cases['objectMixed'],
    );
    expect(
      _quick(option.validate(<String, Object?>{'unknown': 'value'})),
      cases['objectUnknownKeys'],
    );
  });

  test('LineNumbersType and RenderLineNumbersType match source', () {
    final Map<String, dynamic> expected = _map(truth['renderLineNumbers']);
    final Map<String, dynamic> enumValues =
        _map(expected['renderLineNumbersType']);

    expect(opts.RenderLineNumbersType.off, enumValues['Off']);
    expect(opts.RenderLineNumbersType.on, enumValues['On']);
    expect(opts.RenderLineNumbersType.relative, enumValues['Relative']);
    expect(opts.RenderLineNumbersType.interval, enumValues['Interval']);
    expect(opts.RenderLineNumbersType.custom, enumValues['Custom']);

    final String alias = expected['lineNumbersTypeSource'] as String;
    for (final String literal in <String>[
      opts.LineNumbersType.on,
      opts.LineNumbersType.off,
      opts.LineNumbersType.relative,
      opts.LineNumbersType.interval,
    ]) {
      expect(alias.contains("'$literal'"), isTrue);
    }
    expect(alias.contains('(lineNumber: number) => string'), isTrue);
  });

  test('EditorRenderLineNumbersOption matches source defaults, schema and validation',
      () {
    final Map<String, dynamic> expected = _map(truth['renderLineNumbers']);
    final opts.EditorRenderLineNumbersOption option =
        opts.EditorRenderLineNumbersOption();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_lineNumbers(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);

    final Map<String, dynamic> cases = _map(expected['validate']);
    expect(_lineNumbers(option.validate()), cases['undefined']);
    expect(_lineNumbers(option.validate(null)), cases['null']);
    expect(_lineNumbers(option.validate('on')), cases['on']);
    expect(_lineNumbers(option.validate('off')), cases['off']);
    expect(_lineNumbers(option.validate('relative')), cases['relative']);
    expect(_lineNumbers(option.validate('interval')), cases['interval']);
    expect(_lineNumbers(option.validate('bogus')), cases['bogusString']);
    expect(_lineNumbers(option.validate(42)), cases['number']);
    expect(_lineNumbers(option.validate(true)), cases['boolean']);
    expect(
        _lineNumbers(option.validate(<String, Object?>{})), cases['emptyObject']);

    // Dart stands in for the TS callback with a closure; the harness records
    // the expected presence flag and the result for the sample line number.
    final Map<String, dynamic> customCase = _map(cases['custom']);
    String customRenderFn(int lineNumber) => 'custom:$lineNumber';
    final opts.InternalEditorRenderLineNumbersOptions custom =
        option.validate(customRenderFn);
    expect(_lineNumbers(custom), <String, Object?>{
      'renderType': customCase['renderType'],
      'hasRenderFn': customCase['hasRenderFn'],
    });
    expect(custom.renderFn, isNotNull);
    expect(custom.renderFn!(customCase['sampleLineNumber'] as int),
        customCase['sampleResult']);
  });

  test('filterValidationDecorations truth table matches source', () {
    final List<Object?> cases =
        (truth['filterValidationDecorations'] as List<Object?>?) ??
            <Object?>[];
    expect(cases.length, 12);
    for (final Object? raw in cases) {
      final Map<String, dynamic> entry = _map(raw);
      final String? value = entry['renderValidationDecorations'] as String?;
      final bool readOnly = entry['readOnly'] as bool;
      expect(
        opts.filterValidationDecorations(_Options(<int, Object?>{
          opts.EditorOption.renderValidationDecorations: value,
          opts.EditorOption.readOnly: readOnly,
        })),
        entry['result'],
      );
    }
  });

  test('filterFontDecorations truth table matches source', () {
    final List<Object?> cases =
        (truth['filterFontDecorations'] as List<Object?>?) ?? <Object?>[];
    expect(cases.length, 4);
    for (final Object? raw in cases) {
      final Map<String, dynamic> entry = _map(raw);
      expect(
        opts.filterFontDecorations(_Options(<int, Object?>{
          opts.EditorOption.effectiveAllowVariableFonts:
              entry['effectiveAllowVariableFonts'],
        })),
        entry['result'],
      );
    }
  });

  test('evolved line-numbers carrier preserves layoutInfo output', () {
    final Map<String, dynamic> expected = _map(truth['layoutInfo']);

    const opts.InternalEditorRenderLineNumbersOptions defaultLineNumbers =
        opts.InternalEditorRenderLineNumbersOptions(
            opts.RenderLineNumbersType.on);
    expect(defaultLineNumbers.renderFn, isNull);
    expect(_layout(_computeLayout(_layoutValues(defaultLineNumbers))),
        expected['default']);

    String customRenderFn(int lineNumber) => 'custom:$lineNumber';
    final opts.InternalEditorRenderLineNumbersOptions customLineNumbers =
        opts.InternalEditorRenderLineNumbersOptions(
            opts.RenderLineNumbersType.custom, customRenderFn);
    expect(_layout(_computeLayout(_layoutValues(customLineNumbers))),
        expected['custom']);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
