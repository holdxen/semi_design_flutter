// Truth replay for batch230 (editorOptions.ts lines 5713–5947):
//   wrappingIndent region: WrappingIndent enum + WrappingIndentOption
//     (defaults, full schema, validate switch, accessibility-aware compute);
//   wrappingInfo region: EditorWrappingInfo + EditorWrappingInfoComputer,
//     replayed through `compute` with injected layoutInfo values (including
//     the dependency-regression scenarios) plus a real computeLayout-based
//     regression check;
//   dropIntoEditor region: IDropIntoEditorOptions / EditorDropIntoEditorOptions
//     + EditorDropIntoEditor (defaults, full schema, validate via the shared
//     `boolean` + `stringSet` helpers);
//   pasteAs region: IPasteAsOptions / EditorPasteAsOptions + EditorPasteAs
//     (defaults, full schema, validate via the same helpers).
//
// Expectations come from `tool/ts2dart/batch230_truth.json`, produced by
// `tool/ts2dart/_batch230_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private classes exposed via a probe tail). Every
// validate case carries its own normalized input, so this replay needs no
// hand-mirrored input table. JS `undefined` is replayed as Dart `null`, per the
// convention documented in editorOptions.dart.
//
// None of the four regions reads `platform.*`; `platformSchemaStrings` guards
// that assumption against future source drift.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth(String file) =>
    _map(jsonDecode(File('tool/ts2dart/$file').readAsStringSync()));

Map<String, Object?> _drop(opts.EditorDropIntoEditorOptions value) =>
    <String, Object?>{
      'enabled': value.enabled,
      'showDropSelector': value.showDropSelector,
    };

Map<String, Object?> _paste(opts.EditorPasteAsOptions value) =>
    <String, Object?>{
      'enabled': value.enabled,
      'showPasteSelector': value.showPasteSelector,
    };

Map<String, Object?> _wrappingInfo(opts.EditorWrappingInfo value) =>
    <String, Object?>{
      'isDominatedByLongLines': value.isDominatedByLongLines,
      'isWordWrapMinified': value.isWordWrapMinified,
      'isViewportWrapping': value.isViewportWrapping,
      'wrappingColumn': value.wrappingColumn,
    };

/// Only `isDominatedByLongLines` is read by
/// `EditorWrappingInfoComputer.compute`; every other member is unused.
class _FakeEnv implements opts.IEnvironmentalOptions {
  _FakeEnv(this.isDominatedByLongLines);

  @override
  bool isDominatedByLongLines;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeComputedOptions implements opts.IComputedEditorOptions {
  _FakeComputedOptions(this.values);

  final Map<int, Object?> values;

  @override
  Object? get(Object id) => values[id];
}

/// Builds a real `EditorLayoutInfo` carrying only the three fields the
/// wrappingInfo compute reads; all other fields are neutral placeholders.
opts.EditorLayoutInfo _layoutInfo(Map<String, dynamic> values) =>
    opts.EditorLayoutInfo(
      width: 0,
      height: 0,
      glyphMarginLeft: 0,
      glyphMarginWidth: 0,
      glyphMarginDecorationLaneCount: 0,
      lineNumbersLeft: 0,
      lineNumbersWidth: 0,
      decorationsLeft: 0,
      decorationsWidth: 0,
      contentLeft: 0,
      contentWidth: 0,
      minimap: const opts.EditorMinimapLayoutInfo(
        renderMinimap: 0,
        minimapLeft: 0,
        minimapWidth: 0,
        minimapHeightIsEditorHeight: false,
        minimapIsSampling: false,
        minimapScale: 1,
        minimapLineHeight: 1,
        minimapCanvasInnerWidth: 0,
        minimapCanvasInnerHeight: 0,
        minimapCanvasOuterWidth: 0,
        minimapCanvasOuterHeight: 0,
      ),
      viewportColumn: 0,
      isWordWrapMinified: values['isWordWrapMinified'] as bool,
      isViewportWrapping: values['isViewportWrapping'] as bool,
      wrappingColumn: values['wrappingColumn'] as num,
      verticalScrollbarWidth: 0,
      horizontalScrollbarHeight: 0,
      overviewRuler: const opts.OverviewRulerPosition(
          top: 0, width: 0, height: 0, right: 0),
    );

Map<int, Object?> _layoutOptions({required String wordWrap, required int accessibility}) =>
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
      opts.EditorOption.scrollbar: const opts.InternalEditorScrollbarOptions(
        arrowSize: 11,
        verticalScrollbarSize: 14,
        horizontalScrollbarSize: 12,
        verticalHasArrows: false,
      ),
      opts.EditorOption.folding: true,
      opts.EditorOption.showFoldingControls: 'mouseover',
      opts.EditorOption.wordWrapOverride2: 'inherit',
      opts.EditorOption.wordWrapOverride1: 'inherit',
      opts.EditorOption.wordWrap: wordWrap,
      opts.EditorOption.wordWrapColumn: 80,
      opts.EditorOption.wordWrapIndicator: false,
      opts.EditorOption.accessibilitySupport: accessibility,
    };

opts.EditorLayoutInfo _realLayout(String wordWrap, {int accessibility = AccessibilitySupport.Unknown}) =>
    opts.EditorLayoutInfoComputer.computeLayout(
      _FakeComputedOptions(_layoutOptions(
          wordWrap: wordWrap, accessibility: accessibility)),
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

/// Mirrors the truth harness's platform-token scan so any token-bearing schema
/// string captured from the real source must also be present in the Dart port.
final RegExp _platformToken = RegExp(
    r'\b(linux|macintosh|macos|windows|web|native|browser|electron)\b',
    caseSensitive: false);

void _collectPlatformStrings(Object? value, String path, List<Object?> out) {
  if (value is String) {
    if (_platformToken.hasMatch(value)) {
      out.add(<String, Object?>{'path': path, 'value': value});
    }
  } else if (value is List) {
    for (int i = 0; i < value.length; i++) {
      _collectPlatformStrings(value[i], '$path[$i]', out);
    }
  } else if (value is Map) {
    value.forEach((Object? key, Object? v) {
      _collectPlatformStrings(v, path.isEmpty ? '$key' : '$path.$key', out);
    });
  }
}

void main() {
  final Map<String, dynamic> truth = _truth('batch230_truth.json');

  test('WrappingIndentOption id, name, defaults and full schema match source',
      () {
    final Map<String, dynamic> expected = _map(truth['wrappingIndent']);
    final opts.WrappingIndentOption option = opts.WrappingIndentOption();
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, expected['schema']);
  });

  test('WrappingIndentOption validate matches every captured branch', () {
    final List<Object?> cases =
        (_map(truth['wrappingIndent'])['validate'] as List).cast<Object?>();
    final opts.WrappingIndentOption option = opts.WrappingIndentOption();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      expect(option.validate(c['input']), c['result'],
          reason: c['label'] as String);
    }
  });

  test('WrappingIndentOption compute matches every captured branch', () {
    final List<Object?> cases =
        (_map(truth['wrappingIndent'])['compute'] as List).cast<Object?>();
    final opts.WrappingIndentOption option = opts.WrappingIndentOption();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      final Map<int, Object?> values = <int, Object?>{
        opts.EditorOption.accessibilitySupport: c['accessibilitySupport'],
      };
      expect(
        option.compute(
            _FakeEnv(false), _FakeComputedOptions(values), c['value'] as int),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('EditorWrappingInfoComputer id, name, defaults and schema match source',
      () {
    final Map<String, dynamic> expected = _map(truth['wrappingInfo']);
    final opts.EditorWrappingInfoComputer option =
        opts.EditorWrappingInfoComputer();
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_wrappingInfo(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);
  });

  test('EditorWrappingInfoComputer compute matches every captured scenario',
      () {
    final List<Object?> cases =
        (_map(truth['wrappingInfo'])['compute'] as List).cast<Object?>();
    final opts.EditorWrappingInfoComputer option =
        opts.EditorWrappingInfoComputer();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      final opts.EditorLayoutInfo layout = _layoutInfo(_map(c['layoutInfo']));
      final Map<int, Object?> values = <int, Object?>{
        opts.EditorOption.layoutInfo: layout,
      };
      expect(
        _wrappingInfo(option.compute(
            _FakeEnv(c['isDominatedByLongLines'] as bool),
            _FakeComputedOptions(values),
            option.defaultValue)),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('wrappingInfo tracks a real layoutInfo (dependency regression)', () {
    final opts.EditorWrappingInfoComputer option =
        opts.EditorWrappingInfoComputer();
    // Two real layouts computed through `EditorLayoutInfoComputer.computeLayout`
    // give different isViewportWrapping / wrappingColumn values. The wrapping
    // info must read through to whichever layoutInfo is injected, and must not
    // reuse the option's frozen defaultValue from a previous compute call.
    final opts.EditorLayoutInfo off = _realLayout('off');
    final opts.EditorLayoutInfo on = _realLayout('on');
    expect(off.isViewportWrapping, false);
    expect(on.isViewportWrapping, true);

    final opts.EditorWrappingInfo first = option.compute(_FakeEnv(false),
        _FakeComputedOptions(<int, Object?>{opts.EditorOption.layoutInfo: off}),
        option.defaultValue);
    expect(first.isWordWrapMinified, off.isWordWrapMinified);
    expect(first.isViewportWrapping, off.isViewportWrapping);
    expect(first.wrappingColumn, off.wrappingColumn);
    expect(first.isDominatedByLongLines, false);

    final opts.EditorWrappingInfo second = option.compute(_FakeEnv(true),
        _FakeComputedOptions(<int, Object?>{opts.EditorOption.layoutInfo: on}),
        option.defaultValue);
    expect(second.isWordWrapMinified, on.isWordWrapMinified);
    expect(second.isViewportWrapping, on.isViewportWrapping);
    expect(second.wrappingColumn, on.wrappingColumn);
    expect(second.isDominatedByLongLines, true);
    expect(second.isViewportWrapping, isNot(first.isViewportWrapping));
  });

  test('EditorDropIntoEditor id, name, defaults and full schema match source',
      () {
    final Map<String, dynamic> expected = _map(truth['dropIntoEditor']);
    final opts.EditorDropIntoEditor option = opts.EditorDropIntoEditor();
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_drop(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);
  });

  test('EditorDropIntoEditor validate matches every captured branch', () {
    final List<Object?> cases =
        (_map(truth['dropIntoEditor'])['validate'] as List).cast<Object?>();
    final opts.EditorDropIntoEditor option = opts.EditorDropIntoEditor();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      expect(_drop(option.validate(c['input'])), c['result'],
          reason: c['label'] as String);
    }
  });

  test('EditorPasteAs id, name, defaults and full schema match source', () {
    final Map<String, dynamic> expected = _map(truth['pasteAs']);
    final opts.EditorPasteAs option = opts.EditorPasteAs();
    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_paste(option.defaultValue), expected['defaultValue']);
    expect(option.schema, expected['schema']);
  });

  test('EditorPasteAs validate matches every captured branch', () {
    final List<Object?> cases =
        (_map(truth['pasteAs'])['validate'] as List).cast<Object?>();
    final opts.EditorPasteAs option = opts.EditorPasteAs();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      expect(_paste(option.validate(c['input'])), c['result'],
          reason: c['label'] as String);
    }
  });

  test('boolean matches the real-source truth table', () {
    final List<Object?> cases = (truth['boolean'] as List).cast<Object?>();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      expect(opts.boolean(c['value'], c['defaultValue'] as bool), c['result'],
          reason: c['label'] as String);
    }
  });

  test('stringSet matches the real-source truth table', () {
    final List<Object?> cases = (truth['stringSet'] as List).cast<Object?>();
    for (final Object? entry in cases) {
      final Map<String, dynamic> c = _map(entry);
      expect(
        opts.stringSet<String>(c['value'], c['defaultValue'] as String,
            (c['allowedValues'] as List).cast<String>()),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('platform-token schema strings match the real source', () {
    final List<Object?> captured = <Object?>[];
    _collectPlatformStrings(opts.WrappingIndentOption().schema, '', captured);
    _collectPlatformStrings(
        opts.EditorWrappingInfoComputer().schema, '', captured);
    _collectPlatformStrings(opts.EditorDropIntoEditor().schema, '', captured);
    _collectPlatformStrings(opts.EditorPasteAs().schema, '', captured);
    expect(captured, truth['platformSchemaStrings']);
  });

  test('registry length truth is the real-source value', () {
    expect(truth['editorOptionsRegistryLength'], 180);
  });
}
