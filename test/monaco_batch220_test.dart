// Truth replay for batch220 (editorOptions.ts segment 3b chunk 3):
//   minimap: IEditorMinimapOptions, EditorMinimapOptions alias, EditorMinimap.
//
// Expectations come from `tool/ts2dart/batch220_truth.json`, produced by
// `tool/ts2dart/_batch220_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private classes exposed through a probe tail).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth(String name) => _map(
    jsonDecode(File('tool/ts2dart/$name').readAsStringSync()));

Map<String, Object?> _project(opts.EditorMinimapOptions value) =>
    <String, Object?>{
      'enabled': value.enabled,
      'autohide': value.autohide,
      'size': value.size,
      'side': value.side,
      'showSlider': value.showSlider,
      'renderCharacters': value.renderCharacters,
      'maxColumn': value.maxColumn,
      'scale': value.scale,
      'showRegionSectionHeaders': value.showRegionSectionHeaders,
      'showMarkSectionHeaders': value.showMarkSectionHeaders,
      'markSectionHeaderRegex': value.markSectionHeaderRegex,
      'sectionHeaderFontSize': value.sectionHeaderFontSize,
      'sectionHeaderLetterSpacing': value.sectionHeaderLetterSpacing,
    };

class _Options implements opts.IComputedEditorOptions {
  final Map<int, Object?> values;
  _Options(this.values);
  @override
  Object? get(Object id) => values[id];
}

opts.EditorLayoutInfo _layout(Map<int, Object?> values) =>
    opts.EditorLayoutInfoComputer.computeLayout(_Options(values),
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
        glyphMarginDecorationLaneCount: 1);

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

void main() {
  final Map<String, dynamic> truth = _truth('batch220_truth.json');

  test('batch220 EditorMinimap matches source defaults and full schema', () {
    final Map<String, dynamic> expected = _map(truth['minimap']);
    final opts.EditorMinimap option = opts.EditorMinimap();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_project(option.defaultValue), _map(expected['defaultValue']));

    final Object? schema = expected['schema'];
    expect(_map(option.schema), _map(schema));
    // No `platform.isMacintosh` branch exists in this source region.
    expect(expected['macSchema'], schema);

    final Map<String, dynamic> s = _map(schema);
    expect(s.keys, <String>[
      'editor.minimap.enabled',
      'editor.minimap.autohide',
      'editor.minimap.size',
      'editor.minimap.side',
      'editor.minimap.showSlider',
      'editor.minimap.scale',
      'editor.minimap.renderCharacters',
      'editor.minimap.maxColumn',
      'editor.minimap.showRegionSectionHeaders',
      'editor.minimap.showMarkSectionHeaders',
      'editor.minimap.markSectionHeaderRegex',
      'editor.minimap.sectionHeaderFontSize',
      'editor.minimap.sectionHeaderLetterSpacing',
    ]);
    expect(_map(s['editor.minimap.scale'])['enum'], <Object?>[1, 2, 3]);
    expect(_map(s['editor.minimap.side'])['enum'], <Object?>['left', 'right']);
    expect(_map(s['editor.minimap.autohide'])['enumDescriptions'],
        hasLength(3));
    expect(_map(s['editor.minimap.size'])['enumDescriptions'], hasLength(3));
  });

  test('batch220 EditorMinimap validation matches real source', () {
    final Map<String, dynamic> expected = _map(truth['minimap']);
    final opts.EditorMinimap option = opts.EditorMinimap();
    final Map<String, dynamic> validate = _map(expected['validate']);

    void check(String key, Object? input) =>
        expect(_project(option.validate(input)), _map(validate[key]));

    check('undefined', null);
    check('null', null);
    check('number', 42);
    check('emptyObject', <String, Object?>{});

    check('enabledTrue', <String, Object?>{'enabled': true});
    check('enabledFalse', <String, Object?>{'enabled': false});
    check('enabledStringFalse', <String, Object?>{'enabled': 'false'});
    check('enabledBogus', <String, Object?>{'enabled': 'bogus'});

    check('autohideMouseover', <String, Object?>{'autohide': 'mouseover'});
    check('autohideScroll', <String, Object?>{'autohide': 'scroll'});
    check('autohideBogus', <String, Object?>{'autohide': 'bogus'});
    check('autohideNumber', <String, Object?>{'autohide': 1});

    check('sizeFill', <String, Object?>{'size': 'fill'});
    check('sizeFit', <String, Object?>{'size': 'fit'});
    check('sizeBogus', <String, Object?>{'size': 'bogus'});

    check('sideLeft', <String, Object?>{'side': 'left'});
    check('sideBogus', <String, Object?>{'side': 'bogus'});

    check('showSliderAlways', <String, Object?>{'showSlider': 'always'});
    check('showSliderBogus', <String, Object?>{'showSlider': 'bogus'});

    check('renderCharactersFalse',
        <String, Object?>{'renderCharacters': false});
    check('renderCharactersStringFalse',
        <String, Object?>{'renderCharacters': 'false'});

    check('scaleLow', <String, Object?>{'scale': 0});
    check('scaleHigh', <String, Object?>{'scale': 4});
    check('scaleFractional', <String, Object?>{'scale': 2.9});
    check('scaleString', <String, Object?>{'scale': '2'});
    check('scaleBogus', <String, Object?>{'scale': 'bogus'});

    check('maxColumnLow', <String, Object?>{'maxColumn': 0});
    check('maxColumnHigh', <String, Object?>{'maxColumn': 20000});
    check('maxColumnFractional', <String, Object?>{'maxColumn': 100.9});
    check('maxColumnString', <String, Object?>{'maxColumn': '200'});
    check('maxColumnBogus', <String, Object?>{'maxColumn': 'bogus'});

    check('showRegionSectionHeadersFalse',
        <String, Object?>{'showRegionSectionHeaders': false});
    check('showMarkSectionHeadersFalse',
        <String, Object?>{'showMarkSectionHeaders': false});

    check('markRegexValid', <String, Object?>{
      'markSectionHeaderRegex': r'^CUSTOM:\s*(?<label>.*)$'
    });
    check('markRegexNoLabel',
        <String, Object?>{'markSectionHeaderRegex': 'plain'});
    check('markRegexInvalid',
        <String, Object?>{'markSectionHeaderRegex': '(?<label>'});
    check('markRegexEmpty', <String, Object?>{'markSectionHeaderRegex': ''});
    check('markRegexNonString',
        <String, Object?>{'markSectionHeaderRegex': 123});

    check('fontSizeLow', <String, Object?>{'sectionHeaderFontSize': 1});
    check('fontSizeHigh', <String, Object?>{'sectionHeaderFontSize': 40});
    check('fontSizeFractional',
        <String, Object?>{'sectionHeaderFontSize': 12.5});
    check('fontSizeString', <String, Object?>{'sectionHeaderFontSize': '11.5'});
    check('fontSizeBogus',
        <String, Object?>{'sectionHeaderFontSize': 'bogus'});

    check('letterSpacingLow',
        <String, Object?>{'sectionHeaderLetterSpacing': -1});
    check('letterSpacingHigh',
        <String, Object?>{'sectionHeaderLetterSpacing': 10});
    check('letterSpacingFractional',
        <String, Object?>{'sectionHeaderLetterSpacing': 2.5});
    check('letterSpacingString',
        <String, Object?>{'sectionHeaderLetterSpacing': '3.5'});
    check('letterSpacingBogus',
        <String, Object?>{'sectionHeaderLetterSpacing': 'bogus'});

    check(
        'all',
        <String, Object?>{
          'enabled': false,
          'autohide': 'scroll',
          'size': 'fit',
          'side': 'left',
          'showSlider': 'always',
          'renderCharacters': false,
          'scale': 3,
          'maxColumn': 240,
          'showRegionSectionHeaders': false,
          'showMarkSectionHeaders': false,
          'markSectionHeaderRegex': r'^TODO\s*(?<label>.*)$',
          'sectionHeaderFontSize': 14,
          'sectionHeaderLetterSpacing': 2,
        });

    expect(truth['editorOptionsRegistryLength'], 180);
  });

  test('batch210 layout carrier remains intact with full minimap shape', () {
    final Map<String, dynamic> batch210 =
        _truth('batch210_truth.json');
    final opts.EditorMinimapOptions carrier = opts.EditorMinimapOptions(
      enabled: true,
      size: 'proportional',
      side: 'right',
      showSlider: 'mouseover',
      renderCharacters: true,
      maxColumn: 120,
      scale: 1,
    );
    final Map<String, dynamic> defaults =
        _map(_map(truth['minimap'])['defaultValue']);
    for (final String key in <String>[
      'autohide',
      'showRegionSectionHeaders',
      'showMarkSectionHeaders',
      'markSectionHeaderRegex',
      'sectionHeaderFontSize',
      'sectionHeaderLetterSpacing',
    ]) {
      expect(_project(carrier)[key], defaults[key], reason: key);
    }

    // The reconciled full-shape object (the option's defaultValue) must still
    // drive the batch210 layout computation identically.
    final Map<int, Object?> values = <int, Object?>{
      opts.EditorOption.glyphMargin: true,
      opts.EditorOption.lineNumbers:
          const opts.InternalEditorRenderLineNumbersOptions(1),
      opts.EditorOption.lineNumbersMinChars: 5,
      opts.EditorOption.scrollBeyondLastLine: true,
      opts.EditorOption.padding:
          const opts.EditorPaddingOptions(top: 10, bottom: 20),
      opts.EditorOption.lineDecorationsWidth: 10,
      opts.EditorOption.minimap: opts.EditorMinimap().defaultValue,
      opts.EditorOption.scrollbar: const opts.InternalEditorScrollbarOptions(
          arrowSize: 11,
          verticalScrollbarSize: 14,
          horizontalScrollbarSize: 12,
          verticalHasArrows: false),
      opts.EditorOption.folding: true,
      opts.EditorOption.showFoldingControls: 'mouseover',
      opts.EditorOption.wordWrapOverride2: 'inherit',
      opts.EditorOption.wordWrapOverride1: 'inherit',
      opts.EditorOption.wordWrap: 'off',
      opts.EditorOption.wordWrapColumn: 80,
      opts.EditorOption.wordWrapIndicator: false,
      opts.EditorOption.accessibilitySupport: AccessibilitySupport.Unknown,
    };
    expect(_mini(_layout(values).minimap),
        _map(_map(batch210['proportional'])['minimap']));
  });
}
