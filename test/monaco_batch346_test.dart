// 1:1 replay of
//   `editor/browser/viewParts/viewLinesGpu/viewLinesGpu.ts` (797 lines).
// Truth: `tool/ts2dart/_batch346_truth.cjs` -> `batch346_truth.json`.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show Float32List;

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewLinesGpu/viewLinesGpu.dart'
    show
        FullFileRenderStrategyForViewLines,
        IGpuRenderStrategyForViewLines,
        IViewGpuContextStaticsForViewLines,
        IViewLinesGpuAtlas,
        IViewLinesGpuAtlasPage,
        IViewLinesGpuCanvas,
        IViewLinesGpuContextForViewLines,
        IViewLinesGpuGlyphRasterizer,
        IViewLinesGpuObservable,
        IViewLineOptionsForViewLinesGpu,
        ViewLinesGpu,
        configureViewLinesGpuAutorunForReplay,
        configureViewLinesGpuDevicePixelRatioForReplay,
        configureViewLinesGpuGlyphRasterizerFactoryForReplay,
        configureViewLinesGpuLogForReplay,
        configureViewLinesGpuPreferredFormatForReplay,
        configureViewLinesGpuRunOnChangeForReplay,
        configureViewLinesGpuSegmenterFactoryForReplay,
        configureViewLinesGpuSetTimeoutForReplay,
        configureViewLinesGpuStaticsFactoryForReplay,
        configureViewLinesGpuViewLineOptionsFactoryForReplay;
import 'package:semi_design_flutter/src/monaco/editor/browser/view/renderingContext.dart'
    show LineVisibleRanges;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart'
    show
        IPartialViewLinesViewportData,
        IViewModelForViewportData,
        ViewportData;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel/viewContext.dart'
    show
        IEditorConfigurationForViewContext,
        IViewLayoutForViewContext,
        IViewModelForViewContext,
        ViewContext;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable, MutableDisposable;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/contentSegmenter.dart'
    show IContentSegmenter, SegmentData;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;

Map<String, dynamic> _truth() => (jsonDecode(
      File('tool/ts2dart/batch346_truth.json').readAsStringSync(),
    ) as Map)
    .cast<String, dynamic>();

Map<String, dynamic> _truthMap(Object value) => (value as Map).cast<String, dynamic>();

List<Object?> _truthList(Object value) => (value as List).cast<Object?>();

num _jsNum(num value) =>
    value == value.truncateToDouble() ? value.toInt() : value;

Object _summary(Object values) {
  List<num>? numeric;
  if (values is Float32List) {
    numeric = values.cast<num>().toList();
  } else if (values is Map) {
    numeric = values.values.cast<num>().toList();
  } else if (values is Iterable) {
    numeric = values.cast<num>().toList();
  }
  if (numeric == null) return values;
  return <Object?>[
    '<Float32Array>',
    numeric.length,
    numeric.take(6).map(_jsNum).toList(),
  ];
}

class _Disposable implements IDisposable {
  const _Disposable();
  @override
  void dispose() {}
}

class _LayoutInfoForGpu {
  const _LayoutInfoForGpu(this.contentLeft);
  final num contentLeft;
}

class _Options {
  _Options(this.values);
  final Map<int, Object?> values;
  Object? get(Object id) => values[id as int];
}

class _Configuration implements IEditorConfigurationForViewContext {
  _Configuration(this.options);
  final _Options options;
}

class _Layout implements IDisposable, IViewLayoutForViewContext {
  _Layout(this.state);
  final _Harness state;
  void setMaxLineWidth(num width) => state.calls.add(<Object?>['setMaxLineWidth', width]);
  @override
  void dispose() {}
}

class _Model implements IViewModelForViewContext {
  _Model(this.state, this.viewLayout);
  final _Harness state;
  @override
  final _Layout viewLayout;
  final List<Object> handlers = <Object>[];

  int getLineMaxColumn(int lineNumber) => state.lineData[lineNumber]?.maxColumn ?? 20;
  Object get coordinatesConverter => _CoordinatesConverter();

  @override
  void addViewEventHandler(Object eventHandler) => handlers.add(eventHandler);

  @override
  void removeViewEventHandler(Object eventHandler) => handlers.remove(eventHandler);
}

class _CoordinatesConverter {
  Position convertViewPositionToModelPosition(Position position) => position;
}

class _LineData {
  _LineData(this.lineNumber, this.content, {int? maxColumn})
      : _maxColumn = maxColumn;

  final int lineNumber;
  final String content;
  final int? _maxColumn;

  int get maxColumn => _maxColumn ?? content.length + 1;
  int get tabSize => 4;
  bool get isBasicASCII => true;

  Map<String, Object?> toJson() => <String, Object?>{
        'lineNumber': lineNumber,
        'content': content,
        'maxColumn': maxColumn,
        'tabSize': 4,
        'isBasicASCII': true,
      };
}

class _ViewportModel implements IViewModelForViewportData {
  const _ViewportModel(this.state);
  final _Harness state;

  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => 20;

  @override
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber) =>
      state.lineData[lineNumber]!;

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) => false;

  @override
  List<Object> getDecorationsInViewport(Range visibleRange) => const <Object>[];
}

ViewportData _viewportData(_Harness state, int start, int end) => ViewportData(
      <Object>[].cast(),
      IPartialViewLinesViewportData(
        startLineNumber: start,
        endLineNumber: end,
        relativeVerticalOffset: const <num>[0, 20],
        bigNumbersDelta: 0,
        lineHeight: 20,
      ),
      const <Object>[],
      _ViewportModel(state),
    );

class _Glyph {
  const _Glyph(this.x, this.y, this.w, this.h, this.originOffsetX, this.originOffsetY);
  final int x, y, w, h, originOffsetX, originOffsetY;
}

class _AtlasPage implements IViewLinesGpuAtlasPage {
  _AtlasPage(this.version, this.glyphs, this.usedArea, this.source);
  @override
  final int version;
  @override
  final List<Object> glyphs;
  @override
  final Map<String, num> usedArea;
  @override
  final Object source;
}

class _Atlas implements IViewLinesGpuAtlas {
  _Atlas(this.state);
  final _Harness state;
  @override
  int get pageSize => 1024;
  @override
  List<IViewLinesGpuAtlasPage> get pages => <IViewLinesGpuAtlasPage>[
        _AtlasPage(
          1,
          <Object>[const _Glyph(1, 2, 3, 4, 5, 6)],
          <String, num>{'left': 0, 'top': 0, 'right': 7, 'bottom': 9},
          Object(),
        ),
      ];
  @override
  Object Function(void Function()) get onDidDeleteGlyphs => (void Function() cb) {
        state.atlasDeleteCallback = cb;
        return const _Disposable();
      };
}

class _Observable implements IViewLinesGpuObservable {
  const _Observable(this.value);
  final Object? value;
  @override
  Object? read(Object reader) => value;
  @override
  Object? get() => value;
}

class _CanvasNode {
  const _CanvasNode();
  int get width => 800;
  int get height => 600;
}

class _Canvas implements IViewLinesGpuCanvas {
  const _Canvas();
  @override
  Object get domNode => const _CanvasNode();
  @override
  int get width => 800;
  @override
  int get height => 600;
}

class _CanvasContext {
  _CanvasContext(this.state);
  final _Harness state;
  void configure(Object descriptor) {
    final dynamic d = descriptor;
    state.calls.add(<Object?>['ctx.configure', d['format'], d['alphaMode']]);
  }

  Object getCurrentTexture() => _TextureView();
}

class _TextureView {
  Object createView([Object? descriptor]) => Object();
}

class _RectangleRenderer {
  _RectangleRenderer(this.state);
  final _Harness state;
  void draw(Object viewportData) => state.calls.add(<Object?>[
        'rectangleRenderer.draw',
        (viewportData as ViewportData).startLineNumber,
      ]);
}

class _GpuContextForViewLines implements IViewLinesGpuContextForViewLines {
  _GpuContextForViewLines(this.state);
  final _Harness state;
  @override
  final IViewLinesGpuCanvas canvas = const _Canvas();

  @override
  IViewLinesGpuObservable get canvasDevicePixelDimensions =>
      const _Observable(<String, int>{'width': 800, 'height': 600});

  @override
  IViewLinesGpuObservable get contentLeft => const _Observable(10);

  @override
  IViewLinesGpuObservable get devicePixelRatio => const _Observable(2);

  @override
  Object get ctx => _CanvasContext(state);

  @override
  Object get rectangleRenderer => _RectangleRenderer(state);

  @override
  bool canRender(Object viewLineOptions, ViewportData viewportData, int lineNumber) =>
      state.canRenderLines == null || state.canRenderLines!.contains(lineNumber);
}

class _GpuStatics implements IViewGpuContextStaticsForViewLines {
  _GpuStatics(this.state);
  final _Harness state;
  @override
  Object? get deviceSync => state.device;
  @override
  Future<Object> get device => Future<Object>.value(state.device);
  @override
  Object get atlas => state.atlas;
  @override
  Object get decorationStyleCache => Object();
}

class _GlyphRasterizer implements IViewLinesGpuGlyphRasterizer {
  _GlyphRasterizer(this.state, this.fontSize, this.fontFamily, this.devicePixelRatio);
  final _Harness state;
  @override
  final num fontSize;
  @override
  final String fontFamily;
  @override
  final num devicePixelRatio;

  @override
  Map<String, num> getTextMetrics(String chars) => <String, num>{
        'width': chars == '\t' ? 8 : (chars.length > 1 ? 16 : 8),
      };

  @override
  void dispose() {}
}

class _Strategy implements IGpuRenderStrategyForViewLines {
  _Strategy(this.state, this.type, IViewLinesGpuGlyphRasterizer glyphRasterizer)
      : _glyphRasterizer = glyphRasterizer;
  final _Harness state;
  @override
  final String type;

  @override
  IViewLinesGpuGlyphRasterizer get glyphRasterizer => _glyphRasterizer!;
  IViewLinesGpuGlyphRasterizer? _glyphRasterizer;
  set glyphRasterizer(IViewLinesGpuGlyphRasterizer value) => _glyphRasterizer = value;

  @override
  String get wgsl => 'wgsl-$type';

  @override
  List<Object> get bindGroupEntries => <Object>[
        <String, Object>{
          'binding': 20,
          'resource': <String, Object>{'buffer': 'strategy-buffer'},
        },
      ];

  @override
  Object get onDidChangeBindGroupEntries => (void Function() cb) {
        state.strategyChangeCallback = cb;
        return const _Disposable();
      };

  @override
  void update(ViewportData viewportData, Object options) => state.calls.add(
        <Object?>['strategy.update', type, viewportData.startLineNumber,
            viewportData.endLineNumber, (options as _OptionsForGpu).spaceWidth],
      );

  @override
  void draw(Object pass, ViewportData viewportData) =>
      state.calls.add(<Object?>['strategy.draw', type, viewportData.startLineNumber]);

  @override
  void reset() => state.calls.add(<Object?>['strategy.reset', type]);

  @override
  void dispose() {}
}

class _InstantiationService {
  _InstantiationService(this.state);
  final _Harness state;

  Object createInstance(Object marker, Object context, Object gpuContext,
      Object device, Object rasterizer) {
    final IViewLinesGpuGlyphRasterizer glyph =
        (rasterizer as MutableDisposable<IViewLinesGpuGlyphRasterizer>).value!;
    if (identical(marker, FullFileRenderStrategyForViewLines)) {
      state.strategies.add('full');
      return _Strategy(state, 'full', glyph);
    }
    state.strategies.add('viewport');
    return _Strategy(state, 'viewport', glyph);
  }
}

class _LogService {
  _LogService(this.state);
  final _Harness state;
  void trace(Object? a, [Object? b, Object? c, Object? d, Object? e, Object? f]) {
    final List<Object?> values = <Object?>[a, b, c, d, e, f];
    while (values.isNotEmpty && values.last == null) {
      values.removeLast();
    }
    state.logs.add(values);
  }
}

class _Buffer {
  const _Buffer(this.label);
  final String label;
  void destroy() {}
}

class _Texture {
  _Texture(this.state, this.label);
  final _Harness state;
  final String label;
  Object createView([Object? descriptor]) => Object();
  void destroy() {}
}

class _Queue {
  _Queue(this.state);
  final _Harness state;

  void writeBuffer(Object buffer, int offset, Object values,
      [Object? extra1, Object? extra2]) {
    final List<Object?> record = <Object?>[
      'queue.writeBuffer',
      (buffer as _Buffer).label,
      offset,
      _summary(values),
    ];
    if (extra1 != null) record.add(extra1);
    if (extra2 != null) record.add(extra2);
    state.calls.add(record);
  }

  void copyExternalImageToTexture(
      Object source, Object destination, Object size) {
    final dynamic d = destination;
    final dynamic s = size;
    state.calls.add(<Object?>[
      'queue.copyExternalImageToTexture',
      d['origin'],
      <String, Object?>{'width': s['width'], 'height': s['height']},
    ]);
  }

  void submit(List<Object?> commands) => state.calls.add(<Object?>[
        'queue.submit',
        commands.map((Object? c) => (c as _CommandBuffer).label).toList(),
      ]);
}

class _CommandBuffer {
  const _CommandBuffer(this.label);
  final String label;
}

class _RenderPass {
  _RenderPass(this.state);
  final _Harness state;
  void setPipeline(Object? pipeline) =>
      state.calls.add(<Object?>['pass.setPipeline', (pipeline as _Pipeline).label]);
  void setVertexBuffer(int slot, Object? buffer) => state.calls.add(<Object?>[
        'pass.setVertexBuffer', slot, (buffer as _Buffer).label,
      ]);
  void setScissorRect(int x, int y, int width, int height) =>
      state.calls.add(<Object?>['pass.setScissorRect', x, y, width, height]);
  void setBindGroup(int slot, Object? group) => state.calls.add(<Object?>[
        'pass.setBindGroup', slot, (group as _BindGroup).label,
      ]);
  void draw([Object? a, Object? b, Object? c, Object? d, Object? e, Object? f]) =>
      state.calls.add(<Object?>['pass.draw']);
  void end() => state.calls.add(<Object?>['pass.end']);
}

class _Encoder {
  _Encoder(this.state, this.label);
  final _Harness state;
  final String label;
  Object beginRenderPass(Object descriptor) {
    final dynamic d = descriptor;
    state.calls.add(<Object?>['encoder.beginRenderPass', d['label']]);
    return _RenderPass(state);
  }

  Object finish() {
    state.calls.add(<Object?>['encoder.finish']);
    return _CommandBuffer('commandBuffer');
  }
}

class _Pipeline {
  const _Pipeline(this.label);
  final String label;
  Object getBindGroupLayout(int index) => Object();
}

class _BindGroup {
  const _BindGroup(this.label);
  final String label;
}

class _Device {
  _Device(this.state);
  final _Harness state;
  late final _Queue queue = _Queue(state);

  void destroy() {}

  Object createBuffer(Object descriptor) {
    final dynamic d = descriptor;
    final _Buffer buffer = _Buffer(d['label'] as String);
    state.calls.add(<Object?>[
      'createBuffer', buffer.label, d['size'], d['usage'],
    ]);
    return buffer;
  }

  Object createTexture(Object descriptor) {
    final dynamic d = descriptor;
    final dynamic size = d['size'];
    final _Texture texture = _Texture(state, d['label'] as String);
    state.calls.add(<Object?>[
      'createTexture',
      texture.label,
      size['width'],
      size['height'],
      size['depthOrArrayLayers'],
      d['usage'],
    ]);
    return texture;
  }

  Object createShaderModule(Object descriptor) {
    final dynamic d = descriptor;
    state.calls.add(<Object?>['createShaderModule', d['label'], d['code']]);
    return Object();
  }

  Object createRenderPipeline(Object descriptor) {
    final dynamic d = descriptor;
    state.calls.add(<Object?>[
      'createRenderPipeline',
      d['label'],
      (d['vertex'] as Map)['buffers'][0]['arrayStride'],
      (d['fragment'] as Map)['targets'][0]['format'],
    ]);
    return const _Pipeline('Monaco render pipeline');
  }

  Object createBindGroup(Object descriptor) {
    final dynamic d = descriptor;
    state.calls.add(<Object?>[
      'createBindGroup',
      d['label'],
      (d['entries'] as List).map((Object? e) => (e as Map)['binding']).toList(),
    ]);
    return _BindGroup(d['label'] as String);
  }

  Object createSampler(Object descriptor) {
    final dynamic d = descriptor;
    state.calls.add(<Object?>['createSampler', d['label'], d['magFilter'], d['minFilter']]);
    return Object();
  }

  Object createCommandEncoder(Object descriptor) {
    final dynamic d = descriptor;
    state.calls.add(<Object?>['createCommandEncoder', d['label']]);
    return _Encoder(state, d['label'] as String);
  }
}

class _OptionsForGpu implements IViewLineOptionsForViewLinesGpu {
  const _OptionsForGpu(this.spaceWidth, this.useMonospaceOptimizations);
  @override
  final num spaceWidth;
  @override
  final bool useMonospaceOptimizations;
}

class _Segmenter implements IContentSegmenter {
  const _Segmenter(this.lineData);
  final Object lineData;
  @override
  String? getSegmentAtIndex(int index) {
    final dynamic ld = lineData;
    final String content = ld.content as String;
    if (index < 0 || index >= content.length) return null;
    return content[index];
  }

  @override
  SegmentData? getSegmentData(int index) => null;
}

class _Harness {
  _Harness() {
    device = _Device(this);
    atlas = _Atlas(this);
    layout = _Layout(this);
    config = _Configuration(_Options(<int, Object?>{
      EditorOption.fontFamily: "Menlo, Monaco, 'Courier New', monospace",
      EditorOption.fontSize: 14,
      EditorOption.layoutInfo: const _LayoutInfoForGpu(10),
      40: false,
    }));
    model = _Model(this, layout);
    context = ViewContext(config, _FakeTheme(), model);
    gpuContext = _GpuContextForViewLines(this);
    statics = _GpuStatics(this);
    instantiationService = _InstantiationService(this);
    logService = _LogService(this);

    configureViewLinesGpuStaticsFactoryForReplay(() => statics);
    configureViewLinesGpuAutorunForReplay((void Function(Object reader) cb) {
      cb(Object());
    });
    configureViewLinesGpuRunOnChangeForReplay((
      Object observable,
      void Function(dynamic value) handler,
    ) {
      handler((observable as IViewLinesGpuObservable).get());
      return const _Disposable();
    });
    configureViewLinesGpuSetTimeoutForReplay((void Function() cb) => cb());
    configureViewLinesGpuDevicePixelRatioForReplay(() => 2);
    configureViewLinesGpuPreferredFormatForReplay(() => 'bgra8unorm');
    configureViewLinesGpuGlyphRasterizerFactoryForReplay((
      num fontSize,
      String fontFamily,
      num devicePixelRatio,
      Object cache,
    ) {
      calls.add(<Object?>['GlyphRasterizer', fontSize, fontFamily, devicePixelRatio]);
      return _GlyphRasterizer(this, fontSize, fontFamily, devicePixelRatio);
    });
    configureViewLinesGpuViewLineOptionsFactoryForReplay((ViewContext context) =>
        const _OptionsForGpu(8, true));
    configureViewLinesGpuSegmenterFactoryForReplay((Object lineData, Object options) =>
        _Segmenter(lineData));
    configureViewLinesGpuLogForReplay((Object message) {});

    viewLines = ViewLinesGpu(context, gpuContext, instantiationService, logService);
  }

  late final _Device device;
  late final _Atlas atlas;
  late final _Layout layout;
  late final _Configuration config;
  late final _Model model;
  late final ViewContext context;
  late final _GpuContextForViewLines gpuContext;
  late final _GpuStatics statics;
  late final _InstantiationService instantiationService;
  late final _LogService logService;
  late final ViewLinesGpu viewLines;

  final List<List<Object?>> calls = <List<Object?>>[];
  final List<List<Object?>> logs = <List<Object?>>[];
  final List<String> strategies = <String>[];
  final Map<int, _LineData> lineData = <int, _LineData>{};
  Set<int>? canRenderLines;
  void Function()? atlasDeleteCallback;
  void Function()? strategyChangeCallback;

  ViewportData viewport(int start, int end) => _viewportData(this, start, end);
}

List<Object?> _serializeRanges(List<LineVisibleRanges>? ranges) {
  if (ranges == null) return const <Object?>[];
  return ranges
      .map((LineVisibleRanges r) => <String, Object?>{
            'outsideRenderedLine': r.outsideRenderedLine,
            'lineNumber': r.lineNumber,
            'ranges': r.ranges
                .map((dynamic h) => <Object?>[_jsNum(h.left), _jsNum(h.width)])
                .toList(),
            'continuesOnNextLine': r.continuesOnNextLine,
          })
      .toList();
}

void main() {
  final Map<String, dynamic> truth = _truth();

  group('viewLinesGpu.ts initialization', () {
    test('GPU resources, atlas upload and bind group', () {
      final _Harness h = _Harness();
      expect(h.calls, equals(_truthList(_truthMap(truth['init']!)['calls']!)));
      expect(h.logs, equals(_truthList(_truthMap(truth['init']!)['logs']!)));
      expect(h.strategies, equals(_truthList(_truthMap(truth['init']!)['strategies']!)));
      expect(h.model.handlers.length, _truthMap(truth['init']!)['handlers']);
    });
  });

  group('viewLinesGpu.ts events', () {
    test('all handlers report true and render', () {
      final _Harness h = _Harness();
      final Map<String, dynamic> expected =
          _truthMap(_truthMap(truth['events']!)['results']!);
      expect(h.viewLines.onConfigurationChanged(Object()),
          expected['configuration']);
      expect(h.viewLines.onCursorStateChanged(Object()), expected['cursor']);
      expect(h.viewLines.onDecorationsChanged(Object()), expected['decorations']);
      expect(h.viewLines.onFlushed(Object()), expected['flushed']);
      expect(h.viewLines.onLinesChanged(Object()), expected['linesChanged']);
      expect(h.viewLines.onLinesDeleted(Object()), expected['linesDeleted']);
      expect(h.viewLines.onLinesInserted(Object()), expected['linesInserted']);
      expect(h.viewLines.onLineMappingChanged(Object()), expected['lineMapping']);
      expect(h.viewLines.onRevealRangeRequest(Object()), expected['reveal']);
      expect(h.viewLines.onScrollChanged(Object()), expected['scroll']);
      expect(h.viewLines.onThemeChanged(Object()), expected['theme']);
      expect(h.viewLines.onZonesChanged(Object()), expected['zones']);
      h.lineData[1] = _LineData(1, 'abc');
      h.lineData[2] = _LineData(2, 'abc');
      h.viewLines.renderText(h.viewport(1, 2));
      expect(h.calls, equals(_truthList(_truthMap(truth['events']!)['calls']!)));
    });
  });

  group('viewLinesGpu.ts render + ranges', () {
    test('width computation, visible ranges and coordinate mapping', () {
      final _Harness h = _Harness();
      h.lineData[1] = _LineData(1, 'a\tbcd');
      h.lineData[2] = _LineData(2, 'abcdefgh');
      h.viewLines.onDidRender();
      h.viewLines.renderText(h.viewport(1, 2));
      final Map<String, dynamic> expected = _truthMap(truth['render']!);
      expect(
        _serializeRanges(
          h.viewLines.linesVisibleRangesForRange(Range(1, 2, 2, 5), false),
        ),
        equals(_truthList(expected['ranges']!)),
      );
      expect(_jsNum(h.viewLines.getLineWidth(1)!), expected['lineWidth']);
      final Position? position = h.viewLines.getPositionAtCoordinate(1, 12);
      expect(
        position == null ? null : <Object?>[position.lineNumber, position.column],
        equals(_truthList(expected['position']!)),
      );
      expect(h.calls, equals(_truthList(expected['calls']!)));
    });
  });

  group('viewLinesGpu.ts strategy switch', () {
    test('large file switches to viewport strategy', () {
      final _Harness h = _Harness();
      h.lineData[1] = _LineData(1, 'abc');
      h.lineData[2] = _LineData(
        2,
        'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz',
        maxColumn: 300,
      );
      h.viewLines.onDidRender();
      h.viewLines.renderText(h.viewport(1, 2));
      final Map<String, dynamic> expected = _truthMap(truth['switchStrategy']!);
      expect(h.strategies, equals(_truthList(expected['strategies']!)));
      expect(h.calls, equals(_truthList(expected['calls']!)));
    });
  });
}

class _FakeTheme implements IColorTheme {
  const _FakeTheme();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
