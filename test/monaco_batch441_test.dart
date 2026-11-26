// 1:1 replay of `editor/browser/viewParts/gpuMark/gpuMark.ts`.
// Truth: `tool/ts2dart/_batch441_truth.cjs` -> `batch441_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/event.dart' show Event;
import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/gpuMark/gpuMark.dart';
import '../lib/src/monaco/editor/browser/viewParts/viewLines/viewLineOptions.dart'
    show ViewLineOptions;
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
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;
import '../lib/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart'
    show
        IPartialViewLinesViewportData,
        IViewModelForViewportData,
        ViewportData;
import '../lib/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import '../lib/src/monaco/platform/actions/common/actions.dart' show MenuId;
import '../lib/src/monaco/platform/theme/common/theme.dart' show ColorScheme;

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Object? _norm(Object? v) => v is num && v == v.round() ? v.toInt() : v;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch441_truth.json').readAsStringSync()),
  );
  final Map<String, dynamic> out = <String, dynamic>{};
  for (final dynamic r in root['results'] as List<dynamic>) {
    final Map raw = r as Map;
    final Map<String, dynamic> value = <String, dynamic>{};
    raw.forEach((Object? k, Object? v) {
      if (k != 'label') value[k as String] = v;
    });
    out[raw['label'] as String] = value;
  }
  return out;
}

ColorScheme _theme(String s) => switch (s) {
      'dark' => ColorScheme.dark,
      'light' => ColorScheme.light,
      'hcDark' => ColorScheme.highContrastDark,
      'hcLight' => ColorScheme.highContrastLight,
      _ => throw ArgumentError(s),
    };

String _themeName(ColorScheme c) => switch (c) {
      ColorScheme.dark => 'dark',
      ColorScheme.light => 'light',
      ColorScheme.highContrastDark => 'hcDark',
      ColorScheme.highContrastLight => 'hcLight',
    };

FontInfo _fontInfo() => FontInfo(
      FontInfoOptions(
        pixelRatio: 1,
        fontFamily: 'monospace',
        fontWeight: 'normal',
        fontSize: 14,
        fontFeatureSettings: '',
        fontVariationSettings: '',
        lineHeight: 19,
        letterSpacing: 0,
        isMonospace: true,
        typicalHalfwidthCharacterWidth: 7,
        typicalFullwidthCharacterWidth: 14,
        canUseHalfwidthRightwardsArrow: false,
        spaceWidth: 7,
        middotWidth: 4,
        wsmiddotWidth: 5,
        maxDigitWidth: 7,
      ),
      true,
    );

class _Options implements IComputedEditorOptions {
  final Map<int, Object?> byId = <int, Object?>{
    EditorOption.fontInfo: _fontInfo(),
    EditorOption.renderWhitespace: 'selection',
    EditorOption.experimentalWhitespaceRendering: 'off',
    EditorOption.renderControlCharacters: true,
    EditorOption.disableMonospaceOptimizations: false,
    EditorOption.lineHeight: 19,
    EditorOption.stopRenderingLineAfter: -1,
    EditorOption.fontLigatures: '',
    EditorOption.scrollbar: InternalEditorScrollbarOptions(
      arrowSize: 0,
      verticalHasArrows: false,
      horizontalScrollbarSize: 0,
      verticalScrollbarSize: 10,
    ),
    EditorOption.experimentalGpuAcceleration: 'on',
    EditorOption.effectiveFullwidthCharacterWidth: 'twoCells',
  };

  @override
  Object? get(Object id) => byId[id as int];
}

class _Disposable implements IDisposable {
  @override
  void dispose() {}
}

class _Config implements IEditorConfiguration {
  @override
  IComputedEditorOptions get options => _Options();
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
  void observeContainer([dimension]) {}
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

class _Theme implements IGpuMarkTheme {
  @override
  final ColorScheme type;
  _Theme(this.type);
}

class _Context implements IGpuMarkViewContext {
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];
  final _Config config;
  final _Theme _themeValue;
  _Context(String themeName)
      : config = _Config(),
        _themeValue = _Theme(_theme(themeName));

  @override
  IEditorConfiguration get configuration => config;
  @override
  IGpuMarkTheme get theme => _themeValue;
  @override
  void addEventHandler(ViewEventHandler h) => handlers.add(h);
  @override
  void removeEventHandler(ViewEventHandler h) => handlers.remove(h);
}

class _Gpu implements IGpuMarkGpuContext {
  final Map<int, List<String>> reasons;
  final List<Map<String, Object?>> seen = <Map<String, Object?>>[];
  _Gpu(this.reasons);

  @override
  List<String> canRenderDetailed(
    ViewLineOptions options,
    Object? viewportData,
    int lineNumber,
  ) {
    final ViewportData vp = viewportData! as ViewportData;
    seen.add(<String, Object?>{
      'lineNumber': lineNumber,
      'viewportData': <String, Object?>{
        'startLineNumber': vp.startLineNumber,
        'endLineNumber': vp.endLineNumber,
      },
      'themeType': _themeName(options.themeType),
      'spaceWidth': _norm(options.spaceWidth),
      'lineHeight': _norm(options.lineHeight),
      'useGpu': options.useGpu,
      'renderWhitespace': options.renderWhitespace,
    });
    return reasons[lineNumber] ?? const <String>[];
  }
}

class _ViewportModel implements IViewModelForViewportData {
  @override
  int getLineMinColumn(int lineNumber) => 1;
  @override
  int getLineMaxColumn(int lineNumber) => 100;
  @override
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber) =>
      Object();
  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) => false;
  @override
  List<Object> getDecorationsInViewport(Range visibleRange) =>
      const <Object>[];
}

class _RenderCtx implements RenderingContext {
  final int start, end;
  _RenderCtx(this.start, this.end);

  final ViewportData _vp = ViewportData(
    const <Selection>[],
    IPartialViewLinesViewportData(
      startLineNumber: 10,
      endLineNumber: 20,
      relativeVerticalOffset: const <num>[],
      bigNumbersDelta: 0,
      lineHeight: 19,
    ),
    const <Object>[],
    _ViewportModel(),
  );

  @override
  Range get visibleRange => Range(start, 1, end, 1);

  @override
  ViewportData get viewportData => _vp;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Object _renderCase(
  String themeName,
  int start,
  int end,
  Map<int, List<String>> reasons,
) {
  final _Context ctx = _Context(themeName);
  final _Gpu gpu = _Gpu(reasons);
  final GpuMarkOverlay overlay = GpuMarkOverlay(ctx, gpu);
  final _RenderCtx renderCtx = _RenderCtx(start, end);
  final int vStart = renderCtx.visibleRange.startLineNumber;
  final int vEnd = renderCtx.visibleRange.endLineNumber;
  final int added = ctx.handlers.length;
  final String before = overlay.render(vStart, vStart);
  overlay.prepareRender(renderCtx);
  final List<String> rendered = <String>[];
  for (int ln = vStart; ln <= vEnd; ln++) {
    rendered.add(overlay.render(vStart, ln));
  }
  final String oob = overlay.render(vStart, vEnd + 2);
  overlay.dispose();
  return <String, Object>{
    'value': <String, Object>{
      'added': added,
      'before': before,
      'rendered': rendered,
      'oob': oob,
      'removed': ctx.handlers.length,
      'afterDispose': overlay.render(vStart, vStart),
      'seen': gpu.seen,
    },
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('gpu mark overlay replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    actual['construct'] = _renderCase('dark', 1, 1, const <int, List<String>>{});
    actual['all-gpu'] = _renderCase('dark', 1, 3, const <int, List<String>>{});
    actual['reasons'] = _renderCase('light', 1, 4, <int, List<String>>{
      2: <String>['long line', 'decorations'],
      4: <String>['unsupported'],
    });
    actual['range-normalized'] =
        _renderCase('hcDark', 5, 4, const <int, List<String>>{});

    {
      final _Context ctx = _Context('dark');
      final _Gpu gpu = _Gpu(const <int, List<String>>{});
      final GpuMarkOverlay overlay = GpuMarkOverlay(ctx, gpu);
      actual['events'] = <String, Object?>{
        'value': <String, Object?>{
          'configuration':
              overlay.onConfigurationChanged(<Object, Object?>{}),
          'cursorState': overlay.onCursorStateChanged(<Object, Object?>{}),
          'flushed': overlay.onFlushed(<Object, Object?>{}),
          'linesChanged': overlay.onLinesChanged(<Object, Object?>{}),
          'linesDeleted': overlay.onLinesDeleted(<Object, Object?>{}),
          'linesInserted': overlay.onLinesInserted(<Object, Object?>{}),
          'scrollTrue': overlay.onScrollChanged(<String, Object?>{
            'scrollTopChanged': true,
          }),
          'scrollFalse': overlay.onScrollChanged(<String, Object?>{
            'scrollTopChanged': false,
          }),
          'zones': overlay.onZonesChanged(<Object, Object?>{}),
          'decorations': overlay.onDecorationsChanged(<Object, Object?>{}),
        },
      };
      overlay.dispose();
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
