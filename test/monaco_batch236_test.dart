// Truth replay for batch236: viewLineOptions.ts (ViewLineOptions class).
//
// Expectations come from `tool/ts2dart/batch236_truth.json`, produced by
// `tool/ts2dart/_batch236_truth.cjs`, which transpiles and executes the REAL
// `viewLineOptions.ts` with the REAL `EditorOption` ids (from the real
// transpiled `editorOptions.ts`). Each case carries its own raw inputs, so the
// Dart replay feeds exactly what the real constructor received. Every field /
// equals result comes from the real class, never from a handmade list.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/event.dart' show Event;
import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/browser/viewParts/viewLines/viewLineOptions.dart'
    as vlo;
import '../lib/src/monaco/editor/common/config/editorConfiguration.dart'
    show IEditorConfiguration;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show
        ConfigurationChangedEvent,
        EditorOption,
        IComputedEditorOptions,
        IEditorOptions,
        InternalEditorScrollbarOptions;
import '../lib/src/monaco/editor/common/config/fontInfo.dart'
    show FontInfo, FontInfoOptions;
import '../lib/src/monaco/platform/actions/common/actions.dart' show MenuId;
import '../lib/src/monaco/platform/theme/common/theme.dart' show ColorScheme;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch236_truth.json').readAsStringSync()));

/// Minimal real FontInfo carrying the width/monospace fields the class reads.
FontInfo _fontInfo(Map<String, dynamic> f) => FontInfo(
      FontInfoOptions(
        pixelRatio: 1,
        fontFamily: 'monospace',
        fontWeight: 'normal',
        fontSize: 14,
        fontFeatureSettings: '',
        fontVariationSettings: '',
        lineHeight: 19,
        letterSpacing: 0,
        isMonospace: f['isMonospace'] as bool,
        typicalHalfwidthCharacterWidth: (f['spaceWidth'] as num).toDouble(),
        typicalFullwidthCharacterWidth: (f['spaceWidth'] as num).toDouble() * 2,
        canUseHalfwidthRightwardsArrow:
            f['canUseHalfwidthRightwardsArrow'] as bool,
        spaceWidth: (f['spaceWidth'] as num).toDouble(),
        middotWidth: (f['middotWidth'] as num).toDouble(),
        wsmiddotWidth: (f['wsmiddotWidth'] as num).toDouble(),
        maxDigitWidth: (f['spaceWidth'] as num).toDouble(),
      ),
      true,
    );

class _Options implements IComputedEditorOptions {
  _Options(this._byId);
  final Map<int, Object?> _byId;
  @override
  Object? get(Object id) => _byId[id as int];
}

class _Disposable implements IDisposable {
  @override
  void dispose() {}
}

class _Config implements IEditorConfiguration {
  _Config(this._byId);
  final Map<int, Object?> _byId;

  @override
  IComputedEditorOptions get options => _Options(_byId);
  @override
  bool get isSimpleWidget => false;
  @override
  MenuId get contextMenuId => MenuId.EditorContext;
  @override
  Event<ConfigurationChangedEvent> get onDidChangeFast =>
      (listener, [thisArgs, disposables]) => _Disposable();
  @override
  Event<ConfigurationChangedEvent> get onDidChange => onDidChangeFast;
  @override
  IEditorOptions getRawOptions() => throw UnimplementedError();
  @override
  void updateOptions(IEditorOptions newOptions) {}
  @override
  void observeContainer([c]) {}
  @override
  void setIsDominatedByLongLines(bool v) {}
  @override
  void setModelLineCount(int v) {}
  @override
  void setViewLineCount(int v) {}
  @override
  void setReservedHeight(num v) {}
  @override
  void setGlyphMarginDecorationLaneCount(int v) {}
  @override
  void dispose() {}
}

ColorScheme _theme(String s) => switch (s) {
      'dark' => ColorScheme.dark,
      'light' => ColorScheme.light,
      'hcDark' => ColorScheme.highContrastDark,
      'hcLight' => ColorScheme.highContrastLight,
      _ => throw ArgumentError(s),
    };

/// Build the option-by-id table from a case's raw inputs (harness style).
Map<int, Object?> _byId(Map<String, dynamic> v) => <int, Object?>{
      EditorOption.fontInfo: _fontInfo(_map(v['fontInfo'])),
      EditorOption.renderWhitespace: v['renderWhitespace'],
      EditorOption.experimentalWhitespaceRendering:
          v['experimentalWhitespaceRendering'],
      EditorOption.renderControlCharacters: v['renderControlCharacters'],
      EditorOption.disableMonospaceOptimizations:
          v['disableMonospaceOptimizations'],
      EditorOption.lineHeight: v['lineHeight'],
      EditorOption.stopRenderingLineAfter: v['stopRenderingLineAfter'],
      EditorOption.fontLigatures: v['fontLigatures'],
      EditorOption.scrollbar: InternalEditorScrollbarOptions(
        arrowSize: 0,
        verticalHasArrows: false,
        horizontalScrollbarSize: 0,
        verticalScrollbarSize:
            (_map(v['scrollbar'])['verticalScrollbarSize'] as num),
      ),
      EditorOption.experimentalGpuAcceleration: v['experimentalGpuAcceleration'],
      EditorOption.effectiveFullwidthCharacterWidth:
          v['effectiveFullwidthCharacterWidth'],
    };

Map<String, Object?> _snap(vlo.ViewLineOptions o) => <String, Object?>{
      'themeType': switch (o.themeType) {
        ColorScheme.dark => 'dark',
        ColorScheme.light => 'light',
        ColorScheme.highContrastDark => 'hcDark',
        ColorScheme.highContrastLight => 'hcLight',
      },
      'renderWhitespace': o.renderWhitespace,
      'experimentalWhitespaceRendering': o.experimentalWhitespaceRendering,
      'renderControlCharacters': o.renderControlCharacters,
      'spaceWidth': o.spaceWidth,
      'middotWidth': o.middotWidth,
      'wsmiddotWidth': o.wsmiddotWidth,
      'useMonospaceOptimizations': o.useMonospaceOptimizations,
      'canUseHalfwidthRightwardsArrow': o.canUseHalfwidthRightwardsArrow,
      'lineHeight': o.lineHeight,
      'stopRenderingLineAfter': o.stopRenderingLineAfter,
      'fontLigatures': o.fontLigatures,
      'verticalScrollbarSize': o.verticalScrollbarSize,
      'useGpu': o.useGpu,
      'useTwoCellFullwidthCharacters': o.useTwoCellFullwidthCharacters,
    };

void main() {
  final truth = _truth();
  final cases = truth['cases'] as List;

  // Build each instance once so constructor and equals replay share objects.
  final built = <String, vlo.ViewLineOptions>{};
  for (final entry in cases) {
    final c = _map(entry);
    built[c['label'] as String] = vlo.ViewLineOptions(
      _Config(_byId(_map(c['input']))),
      _theme(c['themeType'] as String),
    );
  }

  group('batch236 truth replay - ViewLineOptions constructor', () {
    for (final entry in cases) {
      final c = _map(entry);
      test('construct: ${c['label']}', () {
        expect(_snap(built[c['label'] as String]!), _map(c['result']));
      });
    }
  });

  group('batch236 truth replay - ViewLineOptions.equals', () {
    for (final entry in truth['equals'] as List) {
      final e = _map(entry);
      test('equals: ${e['a']} / ${e['b']}', () {
        expect(
          built[e['a'] as String]!.equals(built[e['b'] as String]!),
          e['result'] as bool,
        );
      });
    }
  });
}
