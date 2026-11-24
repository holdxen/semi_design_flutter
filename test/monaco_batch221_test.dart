// Truth replay for batch221 (editorOptions.ts lines 3721-3884):
//   multiCursorModifier helper, padding, parameterHints, pixelRatio, placeholder.
//
// Expectations come from `tool/ts2dart/batch221_truth.json`, produced by
// `tool/ts2dart/_batch221_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private classes/functions exposed through a probe
// tail). `_multiCursorModifierFromString` is platform-dependent: the harness
// records both the mac and non-mac results and the replay selects the one
// matching the host's `platform.isMacintosh`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/platform.dart' as platform;
import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch221_truth.json').readAsStringSync()));

Map<String, Object?> _padding(opts.EditorPaddingOptions value) =>
    <String, Object?>{'top': value.top, 'bottom': value.bottom};

Map<String, Object?> _parameterHints(opts.EditorParameterHintsOptions value) =>
    <String, Object?>{'enabled': value.enabled, 'cycle': value.cycle};

class _Options implements opts.IComputedEditorOptions {
  final Map<int, Object?> values;
  _Options(this.values);
  @override
  Object? get(Object id) => values[id];
}

class _PixelRatioEnv implements opts.IEnvironmentalOptions {
  _PixelRatioEnv(this.ratio);
  final double ratio;
  @override
  double get pixelRatio => ratio;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
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

Map<int, Object?> _layoutValues(opts.EditorPaddingOptions padding,
        {String size = 'proportional'}) =>
    <int, Object?>{
      opts.EditorOption.glyphMargin: true,
      opts.EditorOption.lineNumbers:
          const opts.InternalEditorRenderLineNumbersOptions(1),
      opts.EditorOption.lineNumbersMinChars: 5,
      opts.EditorOption.scrollBeyondLastLine: true,
      opts.EditorOption.padding: padding,
      opts.EditorOption.lineDecorationsWidth: 10,
      opts.EditorOption.minimap: opts.EditorMinimapOptions(
        enabled: true,
        size: size,
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
  // Dart has no `undefined`. For every validator ported here the TS `undefined`
  // and `null` inputs take the same branch, so the harness's `undefined` cases
  // are replayed with Dart `null` (exactly as batch219/batch220 do).

  test('multiCursorModifier helper matches real source on this host', () {
    final Map<String, dynamic> variants =
        _map(truth['multiCursorModifier']);
    final Map<String, dynamic> expected =
        _map(platform.isMacintosh ? variants['mac'] : variants['nonMac']);

    expect(expected['isMacintosh'], platform.isMacintosh);
    expect(opts.multiCursorModifierFromString('ctrlCmd'), expected['ctrlCmd']);
    expect(opts.multiCursorModifierFromString('alt'), expected['alt']);
    expect(opts.multiCursorModifierFromString('bogus'), expected['bogus']);
  });

  test('EditorPadding matches source defaults, schema and validation', () {
    final Map<String, dynamic> expected = _map(truth['padding']);
    final opts.EditorPadding option = opts.EditorPadding();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_padding(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);

    final Map<String, dynamic> cases = _map(expected['validate']);
    expect(_padding(option.validate(null)), cases['undefined']);
    expect(_padding(option.validate(null)), cases['null']);
    expect(_padding(option.validate(42)), cases['number']);
    expect(_padding(option.validate(<String, Object?>{})), cases['emptyObject']);
    expect(_padding(option.validate(<String, Object?>{'top': 20})),
        cases['topOnly']);
    expect(_padding(option.validate(<String, Object?>{'bottom': 30})),
        cases['bottomOnly']);
    expect(_padding(option.validate(<String, Object?>{'top': -5})),
        cases['topLow']);
    expect(_padding(option.validate(<String, Object?>{'top': 2000})),
        cases['topHigh']);
    expect(_padding(option.validate(<String, Object?>{'bottom': -1})),
        cases['bottomLow']);
    expect(_padding(option.validate(<String, Object?>{'bottom': 1001})),
        cases['bottomHigh']);
    expect(_padding(option.validate(<String, Object?>{
      'top': 12.9,
      'bottom': 7.2,
    })), cases['fractional']);
    expect(_padding(option.validate(<String, Object?>{
      'top': '40',
      'bottom': '50',
    })), cases['stringNumber']);
    expect(_padding(option.validate(<String, Object?>{
      'top': 'bogus',
      'bottom': 'bogus',
    })), cases['stringBogus']);
    expect(_padding(option.validate(<String, Object?>{
      'top': 15,
      'bottom': 25,
    })), cases['all']);
  });

  test('EditorParameterHints matches source defaults, schema and validation',
      () {
    final Map<String, dynamic> expected = _map(truth['parameterHints']);
    final opts.EditorParameterHints option = opts.EditorParameterHints();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_parameterHints(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);

    final Map<String, dynamic> cases = _map(expected['validate']);
    expect(_parameterHints(option.validate(null)), cases['undefined']);
    expect(_parameterHints(option.validate(null)), cases['null']);
    expect(_parameterHints(option.validate(42)), cases['number']);
    expect(
        _parameterHints(option.validate(<String, Object?>{})), cases['emptyObject']);
    expect(_parameterHints(option.validate(<String, Object?>{'enabled': false})),
        cases['enabledFalse']);
    expect(
        _parameterHints(option.validate(<String, Object?>{'enabled': 'false'})),
        cases['enabledStringFalse']);
    expect(
        _parameterHints(option.validate(<String, Object?>{'enabled': 'bogus'})),
        cases['enabledBogus']);
    expect(_parameterHints(option.validate(<String, Object?>{'cycle': false})),
        cases['cycleFalse']);
    expect(_parameterHints(option.validate(<String, Object?>{'cycle': 'false'})),
        cases['cycleStringFalse']);
    expect(_parameterHints(option.validate(<String, Object?>{
      'enabled': false,
      'cycle': false,
    })), cases['all']);
  });

  test('EditorPixelRatio computes from env.pixelRatio', () {
    final Map<String, dynamic> expected = _map(truth['pixelRatio']);
    final opts.EditorPixelRatio option = opts.EditorPixelRatio();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, expected['schema']);

    final List<Object?> computeCases =
        (expected['compute'] as List<Object?>?) ?? <Object?>[];
    expect(computeCases.length, 4);
    for (int i = 0; i < computeCases.length; i++) {
      final double ratio = (computeCases[i] as num).toDouble();
      expect(
        option.compute(_PixelRatioEnv(ratio), _Options(<int, Object?>{}), 1),
        computeCases[i],
      );
    }
  });

  test('PlaceholderOption matches source undefined/string validation', () {
    final Map<String, dynamic> expected = _map(truth['placeholder']);
    final opts.PlaceholderOption option = opts.PlaceholderOption();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, expected['schema']);

    final Map<String, dynamic> cases = _map(expected['validate']);
    expect(option.validate(null), cases['undefined']);
    expect(option.validate(null), cases['null']);
    expect(option.validate(''), cases['emptyString']);
    expect(option.validate('Type something'), cases['string']);
    expect(option.validate(42), cases['number']);
    expect(option.validate(<String, Object?>{}), cases['object']);
    expect(option.validate(true), cases['boolean']);
  });

  test('evolved padding carrier preserves batch210 layoutInfo output', () {
    final Map<String, dynamic> expected = _map(truth['layoutInfo']);

    // The carrier constructed without arguments now carries the source
    // default padding (top: 0, bottom: 0).
    const opts.EditorPaddingOptions defaults = opts.EditorPaddingOptions();
    expect(defaults.top, 0);
    expect(defaults.bottom, 0);
    expect(_layout(_computeLayout(_layoutValues(defaults))),
        expected['defaultPadding']);

    // Explicit padding (as batch210 supplies) still feeds the real layout
    // computation; `fill` exercises the padding-dependent minimap path.
    expect(
        _layout(_computeLayout(_layoutValues(
          const opts.EditorPaddingOptions(top: 10, bottom: 20),
          size: 'fill',
        ))),
        expected['explicitPaddingFill']);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
