import 'dart:typed_data' show Float32List;

import '../../../../base/common/errors.dart' show BugIndicatingError;
import '../../../../base/common/lifecycle.dart'
    show IDisposable, MutableDisposable;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/core/cursorColumns.dart' show CursorColumns;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;
import '../../../common/viewLayout/viewLinesViewportData.dart'
    show ViewportData;
import '../../../common/viewModel/viewContext.dart' show ViewContext;
import '../../gpu/atlas/textureAtlas.dart' show TextureAtlas;
import '../../gpu/atlas/textureAtlasPage.dart' show TextureAtlasPage;
import '../../gpu/contentSegmenter.dart'
    show IContentSegmenter, createContentSegmenter;
import '../../gpu/gpu.dart' show BindingId;
import '../../gpu/gpuUtils.dart' show quadVertices;
import '../../view/renderingContext.dart'
    show
        FloatHorizontalRange,
        HorizontalPosition,
        HorizontalRange,
        IViewLines,
        LineVisibleRanges,
        RenderingContext,
        RestrictedRenderingContext,
        VisibleRanges;
import '../../view/viewPart.dart' show ViewPart;
import '../viewLines/viewLineOptions.dart' show ViewLineOptions;

class GPUBufferUsageForViewLines {
  static const int COPY_DST = 8;
  static const int UNIFORM = 64;
  static const int STORAGE = 128;
  static const int VERTEX = 32;
  const GPUBufferUsageForViewLines._();
}

class GPUTextureUsageForViewLines {
  static const int COPY_DST = 2;
  static const int TEXTURE_BINDING = 4;
  static const int RENDER_ATTACHMENT = 16;
  const GPUTextureUsageForViewLines._();
}

class FullFileRenderStrategyForViewLines {
  static const int maxSupportedLines = 3000;
  static const int maxSupportedColumns = 200;
  const FullFileRenderStrategyForViewLines._();
}

class ViewportRenderStrategyForViewLines {
  const ViewportRenderStrategyForViewLines._();
}

abstract class IViewLinesGpuObservable {
  Object? read(Object reader);
  Object? get();
}

abstract class IViewLinesGpuCanvas {
  Object get domNode;
  int get width;
  int get height;
}

abstract class IViewLinesGpuContextForViewLines {
  IViewLinesGpuCanvas get canvas;
  IViewLinesGpuObservable get canvasDevicePixelDimensions;
  IViewLinesGpuObservable get contentLeft;
  IViewLinesGpuObservable get devicePixelRatio;
  Object get ctx;
  Object get rectangleRenderer;
  bool canRender(Object viewLineOptions, ViewportData viewportData, int lineNumber);
}

abstract class IViewGpuContextStaticsForViewLines {
  Object? get deviceSync;
  Future<Object> get device;
  Object get atlas;
  Object get decorationStyleCache;
}

abstract class IViewLinesGpuGlyphRasterizer implements IDisposable {
  String get fontFamily;
  num get fontSize;
  num get devicePixelRatio;
  Map<String, num> getTextMetrics(String chars);
}

abstract class IGpuRenderStrategyForViewLines implements IDisposable {
  String get type;
  String get wgsl;
  List<Object> get bindGroupEntries;
  IViewLinesGpuGlyphRasterizer get glyphRasterizer;
  Object get onDidChangeBindGroupEntries;
  void update(ViewportData viewportData, Object options);
  void draw(Object pass, ViewportData viewportData);
  void reset();
}

abstract class IViewLinesGpuAtlasPage {
  int get version;
  List<Object> get glyphs;
  Map<String, num> get usedArea;
  Object get source;
}

abstract class IViewLinesGpuAtlas {
  int get pageSize;
  List<IViewLinesGpuAtlasPage> get pages;
  Object Function(void Function()) get onDidDeleteGlyphs;
}

abstract class IViewLineOptionsForViewLinesGpu {
  num get spaceWidth;
  bool get useMonospaceOptimizations;
}

class _ViewLineOptionsForViewLinesGpu implements IViewLineOptionsForViewLinesGpu {
  _ViewLineOptionsForViewLinesGpu(this._options);
  final ViewLineOptions _options;
  @override
  num get spaceWidth => _options.spaceWidth;
  @override
  bool get useMonospaceOptimizations => _options.useMonospaceOptimizations;
}

class _ViewGpuResource implements IDisposable {
  _ViewGpuResource(this.object);
  final Object object;
  @override
  void dispose() => (object as dynamic).destroy();
}

typedef ViewLinesGpuAutorunForReplay = void Function(
  void Function(Object reader) callback,
);
typedef ViewLinesGpuRunOnChangeForReplay = Object Function(
  Object observable,
  void Function(dynamic value) handler,
);
typedef ViewLinesGpuSetTimeoutForReplay = void Function(void Function() callback);
typedef ViewLinesGpuDevicePixelRatioForReplay = num Function();
typedef ViewLinesGpuPreferredFormatForReplay = String Function();
typedef ViewLinesGpuStaticsFactoryForReplay = IViewGpuContextStaticsForViewLines
    Function();
typedef ViewLinesGpuGlyphRasterizerFactoryForReplay
    = IViewLinesGpuGlyphRasterizer Function(
  num fontSize,
  String fontFamily,
  num devicePixelRatio,
  Object decorationStyleCache,
);
typedef ViewLinesGpuViewLineOptionsFactoryForReplay
    = IViewLineOptionsForViewLinesGpu Function(ViewContext context);
typedef ViewLinesGpuSegmenterFactoryForReplay = IContentSegmenter Function(
  Object lineData,
  Object options,
);
typedef ViewLinesGpuLogForReplay = void Function(Object message);

ViewLinesGpuAutorunForReplay? _autorunForReplay;
ViewLinesGpuRunOnChangeForReplay? _runOnChangeForReplay;
ViewLinesGpuSetTimeoutForReplay? _setTimeoutForReplay;
ViewLinesGpuDevicePixelRatioForReplay? _devicePixelRatioForReplay;
ViewLinesGpuPreferredFormatForReplay? _preferredFormatForReplay;
ViewLinesGpuStaticsFactoryForReplay? _staticsFactoryForReplay;
ViewLinesGpuGlyphRasterizerFactoryForReplay? _glyphRasterizerFactoryForReplay;
ViewLinesGpuViewLineOptionsFactoryForReplay? _viewLineOptionsFactoryForReplay;
ViewLinesGpuSegmenterFactoryForReplay? _segmenterFactoryForReplay;
ViewLinesGpuLogForReplay? _logForReplay;

void configureViewLinesGpuAutorunForReplay(ViewLinesGpuAutorunForReplay factory) =>
    _autorunForReplay = factory;
void configureViewLinesGpuRunOnChangeForReplay(
        ViewLinesGpuRunOnChangeForReplay factory) =>
    _runOnChangeForReplay = factory;
void configureViewLinesGpuSetTimeoutForReplay(
        ViewLinesGpuSetTimeoutForReplay factory) =>
    _setTimeoutForReplay = factory;
void configureViewLinesGpuDevicePixelRatioForReplay(
        ViewLinesGpuDevicePixelRatioForReplay factory) =>
    _devicePixelRatioForReplay = factory;
void configureViewLinesGpuPreferredFormatForReplay(
        ViewLinesGpuPreferredFormatForReplay factory) =>
    _preferredFormatForReplay = factory;
void configureViewLinesGpuStaticsFactoryForReplay(
        ViewLinesGpuStaticsFactoryForReplay factory) =>
    _staticsFactoryForReplay = factory;
void configureViewLinesGpuGlyphRasterizerFactoryForReplay(
        ViewLinesGpuGlyphRasterizerFactoryForReplay factory) =>
    _glyphRasterizerFactoryForReplay = factory;
void configureViewLinesGpuViewLineOptionsFactoryForReplay(
        ViewLinesGpuViewLineOptionsFactoryForReplay factory) =>
    _viewLineOptionsFactoryForReplay = factory;
void configureViewLinesGpuSegmenterFactoryForReplay(
        ViewLinesGpuSegmenterFactoryForReplay factory) =>
    _segmenterFactoryForReplay = factory;
void configureViewLinesGpuLogForReplay(ViewLinesGpuLogForReplay factory) =>
    _logForReplay = factory;

IViewGpuContextStaticsForViewLines _createStatics() =>
    _staticsFactoryForReplay?.call() ??
    (() => throw StateError('ViewGpuContext statics are not configured'))();

class GlyphStorageBufferInfo {
  static const int FloatsPerEntry = 2 + 2 + 2;
  static const int BytesPerEntry = FloatsPerEntry * 4;
  static const int Offset_TexturePosition = 0;
  static const int Offset_TextureSize = 2;
  static const int Offset_OriginPosition = 4;
  const GlyphStorageBufferInfo._();
}

class ViewLinesGpu extends ViewPart implements IViewLines {
  ViewLinesGpu(
    ViewContext context,
    this._viewGpuContext,
    this._instantiationService,
    this._logService,
  )   : _disposedForReplay = false,
        _gpuContext = context,
        _statics = _createStatics(),
        super(context) {
    final dynamic canvas = _viewGpuContext.canvas.domNode;
    _canvas = canvas as Object;
    (_autorunForReplay ??
            ((void Function(Object reader) callback) => callback(Object())))
        .call((Object reader) {
      _viewGpuContext.canvasDevicePixelDimensions.read(reader);
      final Object? last = _lastViewportData;
      if (last != null) {
        (_setTimeoutForReplay ?? (void Function() cb) => cb()).call(() {
          if (identical(last, _lastViewportData)) {
            renderText(last as ViewportData);
          }
        });
      }
    });
    initWebgpu();
  }

  final IViewGpuContextStaticsForViewLines _statics;
  final IViewLinesGpuContextForViewLines _viewGpuContext;
  late final ViewContext _gpuContext;
  final Object _instantiationService;
  final Object _logService;
  bool _disposedForReplay;
  late final Object _canvas;

  List<ViewportData>? _initViewportData;
  ViewportData? _lastViewportData;
  IViewLineOptionsForViewLinesGpu? _lastViewLineOptions;
  num _maxLineWidth = 0;

  Object? _device;
  Object? _renderPassDescriptor;
  Object? _renderPassColorAttachment;
  Object? _bindGroup;
  Object? _pipeline;
  Object? _vertexBuffer;
  Object? _glyphStorageBuffer;
  Object? _atlasGpuTexture;
  final List<int> _atlasGpuTextureVersions = <int>[];
  bool _initialized = false;
  void Function()? _rebuildBindGroup;

  late final MutableDisposable<IViewLinesGpuGlyphRasterizer> _glyphRasterizer;
  late final MutableDisposable<IGpuRenderStrategyForViewLines> _renderStrategy;

  Future<void> initWebgpu() async {
    final Object? syncDevice = _statics.deviceSync;
    final Object device = syncDevice ?? await _statics.device;
    if (_disposedForReplay) return;
    _initialize(device);
  }

  void _initialize(Object device) {
    _device = device;
    final IViewLinesGpuAtlas atlas = _statics.atlas as IViewLinesGpuAtlas;
    register((atlas.onDidDeleteGlyphs(() {
      _atlasGpuTextureVersions
        ..clear()
        ..add(0)
        ..add(0);
      _renderStrategy.value?.reset();
    })) as IDisposable);

    final String presentationFormat = _preferredFormatForReplay?.call() ?? 'bgra8unorm';
    final dynamic ctx = _viewGpuContext.ctx;
    ctx.configure(<String, Object?>{
      'device': device,
      'format': presentationFormat,
      'alphaMode': 'premultiplied',
    });
    _renderPassColorAttachment = <String, Object?>{
      'view': null,
      'loadOp': 'load',
      'storeOp': 'store',
    };
    _renderPassDescriptor = <String, Object?>{
      'label': 'Monaco render pass',
      'colorAttachments': <Object?>[_renderPassColorAttachment],
    };

    final List<num> layoutBufferValues = List<num>.filled(6, 0);
    num updateLayout([num? width, num? height]) {
      final dynamic canvas = _canvas;
      final num w = width ?? canvas.width;
      final num h = height ?? canvas.height;
      layoutBufferValues[0] = w;
      layoutBufferValues[1] = h;
      final num layoutInfoContentLeft =
          ((_gpuContext.configuration as dynamic).options
                  .get(EditorOption.layoutInfo) as dynamic)
              .contentLeft as num;
      final num contentLeft = layoutInfoContentLeft *
          (_devicePixelRatioForReplay?.call() ?? 1);
      layoutBufferValues[2] = contentLeft.ceil();
      layoutBufferValues[3] = 0;
      layoutBufferValues[4] = layoutBufferValues[0] - layoutBufferValues[2];
      layoutBufferValues[5] = layoutBufferValues[1] - layoutBufferValues[3];
      return layoutBufferValues[0];
    }

    final _ViewGpuResource layoutInfoUniformBuffer = register(_createBuffer(
      device,
      <String, Object?>{
        'label': 'Monaco uniform buffer',
        'size': 6 * 4,
        'usage': GPUBufferUsageForViewLines.UNIFORM |
            GPUBufferUsageForViewLines.COPY_DST,
      },
      () {
        updateLayout();
        return layoutBufferValues;
      },
    ));
    register((_runOnChangeForReplay ?? ((Object o, void Function(dynamic v) h) {
          h((o as IViewLinesGpuObservable).get());
          return _ViewGpuResource(Object());
        })).call(_viewGpuContext.canvasDevicePixelDimensions, (dynamic value) {
      final dynamic dims = value;
      final dynamic dpr = _devicePixelRatioForReplay?.call() ?? 1;
      updateLayout(dims['width'] ?? dpr, dims['height'] ?? dpr);
      (device as dynamic).queue.writeBuffer(
        layoutInfoUniformBuffer.object,
        0,
        layoutBufferValues,
      );
    }) as IDisposable);
    register((_runOnChangeForReplay ?? ((Object o, void Function(dynamic v) h) {
          h((o as IViewLinesGpuObservable).get());
          return _ViewGpuResource(Object());
        })).call(_viewGpuContext.contentLeft, (dynamic _) {
      updateLayout();
      (device as dynamic).queue.writeBuffer(
        layoutInfoUniformBuffer.object,
        0,
        layoutBufferValues,
      );
    }) as IDisposable);

    final _ViewGpuResource atlasInfoUniformBuffer = register(_createBuffer(
      device,
      <String, Object?>{
        'label': 'Monaco atlas info uniform buffer',
        'size': 2 * 4,
        'usage': GPUBufferUsageForViewLines.UNIFORM |
            GPUBufferUsageForViewLines.COPY_DST,
      },
      () => <int>[atlas.pageSize, atlas.pageSize],
    ));

    final options = (_gpuContext.configuration as dynamic).options;
    final String fontFamily = options.get(EditorOption.fontFamily) as String;
    final num fontSize = options.get(EditorOption.fontSize) as num;
    _glyphRasterizer = register(MutableDisposable<IViewLinesGpuGlyphRasterizer>());
    _glyphRasterizer.value = _glyphRasterizerFactoryForReplay?.call(
          fontSize,
          fontFamily,
          _viewGpuContext.devicePixelRatio.get() as num,
          _statics.decorationStyleCache,
        ) ??
        (() => throw StateError('glyph rasterizer factory is not configured'))();
    register((_runOnChangeForReplay ?? ((Object o, void Function(dynamic v) h) {
          h((o as IViewLinesGpuObservable).get());
          return _ViewGpuResource(Object());
        })).call(_viewGpuContext.devicePixelRatio, (dynamic _) {
      _refreshGlyphRasterizer();
    }) as IDisposable);

    _renderStrategy = register(
        MutableDisposable<IGpuRenderStrategyForViewLines>());
    _renderStrategy.value =
        ( _instantiationService as dynamic).createInstance(
              FullFileRenderStrategyForViewLines,
              _gpuContext,
              _viewGpuContext,
              device,
              _glyphRasterizer,
            ) as IGpuRenderStrategyForViewLines;

    _glyphStorageBuffer = register(_createBuffer(
      device,
      <String, Object?>{
        'label': 'Monaco glyph storage buffer',
        'size': TextureAtlas.maximumPageCount *
            TextureAtlasPage.maximumGlyphCount *
            GlyphStorageBufferInfo.BytesPerEntry,
        'usage': GPUBufferUsageForViewLines.STORAGE |
            GPUBufferUsageForViewLines.COPY_DST,
      },
    )).object;
    _atlasGpuTextureVersions
      ..clear()
      ..add(0)
      ..add(0);
    _atlasGpuTexture = register(_createTexture(
      device,
      <String, Object?>{
        'label': 'Monaco atlas texture',
        'format': 'rgba8unorm',
        'size': <String, Object?>{
          'width': atlas.pageSize,
          'height': atlas.pageSize,
          'depthOrArrayLayers': TextureAtlas.maximumPageCount,
        },
        'dimension': '2d',
        'usage': GPUTextureUsageForViewLines.TEXTURE_BINDING |
            GPUTextureUsageForViewLines.COPY_DST |
            GPUTextureUsageForViewLines.RENDER_ATTACHMENT,
      },
    )).object;
    _updateAtlasStorageBufferAndTexture();

    _vertexBuffer = register(_createBuffer(
      device,
      <String, Object?>{
        'label': 'Monaco vertex buffer',
        'size': quadVertices.lengthInBytes,
        'usage': GPUBufferUsageForViewLines.VERTEX |
            GPUBufferUsageForViewLines.COPY_DST,
      },
      quadVertices,
    )).object;

    final Object module = (device as dynamic).createShaderModule(<String, Object?>{
      'label': 'Monaco shader module',
      'code': _renderStrategy.value!.wgsl,
    });
    _pipeline = (device as dynamic).createRenderPipeline(<String, Object?>{
      'label': 'Monaco render pipeline',
      'layout': 'auto',
      'vertex': <String, Object?>{
        'module': module,
        'buffers': <Object?>[
          <String, Object?>{
            'arrayStride': 2 * 4,
            'attributes': <Object?>[
              <String, Object?>{
                'shaderLocation': 0,
                'offset': 0,
                'format': 'float32x2',
              },
            ],
          },
        ],
      },
      'fragment': <String, Object?>{
        'module': module,
        'targets': <Object?>[
          <String, Object?>{
            'format': presentationFormat,
            'blend': <String, Object?>{
              'color': <String, Object?>{
                'srcFactor': 'src-alpha',
                'dstFactor': 'one-minus-src-alpha',
              },
              'alpha': <String, Object?>{
                'srcFactor': 'src-alpha',
                'dstFactor': 'one-minus-src-alpha',
              },
            },
          },
        ],
      },
    });
    _rebuildBindGroup = () {
      _bindGroup = (device as dynamic).createBindGroup(<String, Object?>{
        'label': 'Monaco bind group',
        'layout': (_pipeline as dynamic).getBindGroupLayout(0),
        'entries': <Object?>[
          <String, Object?>{
            'binding': BindingId.GlyphInfo,
            'resource': <String, Object?>{'buffer': _glyphStorageBuffer},
          },
          <String, Object?>{
            'binding': BindingId.TextureSampler,
            'resource': (device as dynamic).createSampler(<String, Object?>{
              'label': 'Monaco atlas sampler',
              'magFilter': 'nearest',
              'minFilter': 'nearest',
            }),
          },
          <String, Object?>{
            'binding': BindingId.Texture,
            'resource': (_atlasGpuTexture as dynamic)
                .createView(<String, Object?>{'label': 'Monaco atlas view'}),
          },
          <String, Object?>{
            'binding': BindingId.LayoutInfoUniform,
            'resource': <String, Object?>{
              'buffer': layoutInfoUniformBuffer.object,
            },
          },
          <String, Object?>{
            'binding': BindingId.AtlasDimensionsUniform,
            'resource': <String, Object?>{
              'buffer': atlasInfoUniformBuffer.object,
            },
          },
          ..._renderStrategy.value!.bindGroupEntries,
        ],
      });
    };
    _rebuildBindGroup!();
    _initialized = true;
    final List<ViewportData>? pending = _initViewportData;
    if (pending != null) {
      for (final ViewportData viewportData in pending) {
        renderText(viewportData);
      }
      _initViewportData = null;
    }
  }

  _ViewGpuResource _createBuffer(
    Object device,
    Object descriptor, [
    Object? initialValues,
  ]) {
    final Object buffer = (device as dynamic).createBuffer(descriptor);
    if (initialValues != null) {
      final Object values = initialValues is Function
          ? initialValues() as Object
          : initialValues;
      (device as dynamic).queue.writeBuffer(buffer, 0, values);
    }
    return _ViewGpuResource(buffer);
  }

  _ViewGpuResource _createTexture(Object device, Object descriptor) =>
      _ViewGpuResource((device as dynamic).createTexture(descriptor));

  void _refreshRenderStrategy(ViewportData viewportData) {
    if (_renderStrategy.value?.type == 'viewport') return;
    if (viewportData.endLineNumber <
            FullFileRenderStrategyForViewLines.maxSupportedLines &&
        _viewportMaxColumn(viewportData) <
            FullFileRenderStrategyForViewLines.maxSupportedColumns) {
      return;
    }
    (_logService as dynamic).trace(
        'File is larger than ${FullFileRenderStrategyForViewLines.maxSupportedLines} lines or ${FullFileRenderStrategyForViewLines.maxSupportedColumns} columns, switching to viewport render strategy');
    final IGpuRenderStrategyForViewLines viewportRenderStrategy =
        (_instantiationService as dynamic).createInstance(
              ViewportRenderStrategyForViewLines,
              _gpuContext,
              _viewGpuContext,
              _device,
              _glyphRasterizer,
            ) as IGpuRenderStrategyForViewLines;
    _renderStrategy.value = viewportRenderStrategy;
    register((viewportRenderStrategy.onDidChangeBindGroupEntries as Function)(
            () => _rebuildBindGroup?.call()) as IDisposable);
    _rebuildBindGroup?.call();
  }

  int _viewportMaxColumn(ViewportData viewportData) {
    int maxColumn = 0;
    for (int i = viewportData.startLineNumber;
        i <= viewportData.endLineNumber;
        i++) {
      final dynamic lineData = viewportData.getViewLineRenderingData(i);
      final int value = lineData.maxColumn as int;
      if (value > maxColumn) maxColumn = value;
    }
    return maxColumn;
  }

  void _updateAtlasStorageBufferAndTexture() {
    final IViewLinesGpuAtlas atlas = _statics.atlas as IViewLinesGpuAtlas;
    for (int layerIndex = 0; layerIndex < atlas.pages.length; layerIndex++) {
      if (layerIndex >= TextureAtlas.maximumPageCount) {
        _logForReplay?.call(
            'Attempt to upload atlas page [$layerIndex], only ${TextureAtlas.maximumPageCount} are supported currently');
        continue;
      }
      final IViewLinesGpuAtlasPage page = atlas.pages[layerIndex];
      if (page.version == _atlasGpuTextureVersions[layerIndex]) continue;
      (_logService as dynamic).trace('Updating atlas page[', layerIndex,
          '] from version ', _atlasGpuTextureVersions[layerIndex],
          ' to version ', page.version);
      final int entryCount = GlyphStorageBufferInfo.FloatsPerEntry *
          TextureAtlasPage.maximumGlyphCount;
      final Float32List values = Float32List(entryCount);
      int entryOffset = 0;
      for (final Object glyph in page.glyphs) {
        final dynamic g = glyph;
        values[entryOffset + GlyphStorageBufferInfo.Offset_TexturePosition] =
            (g.x as num).toDouble();
        values[entryOffset +
                GlyphStorageBufferInfo.Offset_TexturePosition +
                1] = (g.y as num).toDouble();
        values[entryOffset + GlyphStorageBufferInfo.Offset_TextureSize] =
            (g.w as num).toDouble();
        values[entryOffset + GlyphStorageBufferInfo.Offset_TextureSize + 1] =
            (g.h as num).toDouble();
        values[entryOffset + GlyphStorageBufferInfo.Offset_OriginPosition] =
            (g.originOffsetX as num).toDouble();
        values[entryOffset +
                GlyphStorageBufferInfo.Offset_OriginPosition +
                1] = (g.originOffsetY as num).toDouble();
        entryOffset += GlyphStorageBufferInfo.FloatsPerEntry;
      }
      if (entryOffset ~/ GlyphStorageBufferInfo.FloatsPerEntry >
          TextureAtlasPage.maximumGlyphCount) {
        throw StateError(
            'Attempting to write more glyphs (${entryOffset ~/ GlyphStorageBufferInfo.FloatsPerEntry}) than the GPUBuffer can hold (${TextureAtlasPage.maximumGlyphCount})');
      }
      (device as dynamic).queue.writeBuffer(
            _glyphStorageBuffer,
            layerIndex *
                GlyphStorageBufferInfo.FloatsPerEntry *
                TextureAtlasPage.maximumGlyphCount *
                4,
            values,
            0,
            GlyphStorageBufferInfo.FloatsPerEntry *
                TextureAtlasPage.maximumGlyphCount,
          );
      final Map<String, num> usedArea = page.usedArea;
      if ((usedArea['right']! - usedArea['left']!) > 0 &&
          (usedArea['bottom']! - usedArea['top']!) > 0) {
        (_device as dynamic).queue.copyExternalImageToTexture(
              <String, Object?>{'source': page.source},
              <String, Object?>{
                'texture': _atlasGpuTexture,
                'origin': <String, Object?>{
                  'x': usedArea['left'],
                  'y': usedArea['top'],
                  'z': layerIndex,
                },
              },
              <String, Object?>{
                'width': usedArea['right']! - usedArea['left']! + 1,
                'height': usedArea['bottom']! - usedArea['top']! + 1,
              },
            );
      }
      _atlasGpuTextureVersions[layerIndex] = page.version;
    }
  }

  @override
  void prepareRender(RenderingContext ctx) =>
      throw BugIndicatingError('Should not be called');

  @override
  void render(RestrictedRenderingContext ctx) =>
      throw BugIndicatingError('Should not be called');

  @override
  bool onConfigurationChanged(Object e) {
    _refreshGlyphRasterizer();
    _maxLineWidth = 0;
    return true;
  }

  @override
  bool onCursorStateChanged(Object e) => true;

  @override
  bool onDecorationsChanged(Object e) => true;

  @override
  bool onFlushed(Object e) {
    _maxLineWidth = 0;
    return true;
  }

  @override
  bool onLinesChanged(Object e) => true;

  @override
  bool onLinesDeleted(Object e) {
    _maxLineWidth = 0;
    return true;
  }

  @override
  bool onLinesInserted(Object e) => true;

  @override
  bool onLineMappingChanged(Object e) => true;

  @override
  bool onRevealRangeRequest(Object e) => true;

  @override
  bool onScrollChanged(Object e) => true;

  @override
  bool onThemeChanged(Object e) => true;

  @override
  bool onZonesChanged(Object e) => true;

  void _refreshGlyphRasterizer() {
    final IViewLinesGpuGlyphRasterizer? glyphRasterizer =
        _glyphRasterizer.value;
    if (glyphRasterizer == null) return;
    final options = (_gpuContext.configuration as dynamic).options;
    final String fontFamily = options.get(EditorOption.fontFamily) as String;
    final num fontSize = options.get(EditorOption.fontSize) as num;
    final num devicePixelRatio =
        _viewGpuContext.devicePixelRatio.get() as num;
    if (glyphRasterizer.fontFamily != fontFamily ||
        glyphRasterizer.fontSize != fontSize ||
        glyphRasterizer.devicePixelRatio != devicePixelRatio) {
      _glyphRasterizer.value = _glyphRasterizerFactoryForReplay?.call(
            fontSize,
            fontFamily,
            devicePixelRatio,
            _statics.decorationStyleCache,
          ) ??
          glyphRasterizer;
    }
  }

  void renderText(ViewportData viewportData) {
    if (_initialized) {
      _refreshRenderStrategy(viewportData);
      _renderText(viewportData);
    } else {
      _initViewportData ??= <ViewportData>[];
      _initViewportData!.add(viewportData);
    }
  }

  void _renderText(ViewportData viewportData) {
    (_viewGpuContext.rectangleRenderer as dynamic).draw(viewportData);
    final IViewLineOptionsForViewLinesGpu options =
        _viewLineOptionsFactoryForReplay?.call(_gpuContext) ??
            _ViewLineOptionsForViewLinesGpu(
                ViewLineOptions((_gpuContext.configuration as dynamic),
                    _gpuContext.theme.type));
    _renderStrategy.value!.update(viewportData, options);
    _updateAtlasStorageBufferAndTexture();
    final dynamic encoder =
        (device as dynamic).createCommandEncoder(<String, Object?>{
      'label': 'Monaco command encoder',
    });
    final Map<String, Object?> colorAttachment =
        _renderPassColorAttachment as Map<String, Object?>;
    colorAttachment['view'] = (_viewGpuContext.ctx as dynamic)
        .getCurrentTexture()
        .createView(<String, Object?>{'label': 'Monaco canvas texture view'});
    final dynamic pass = encoder.beginRenderPass(_renderPassDescriptor);
    pass.setPipeline(_pipeline);
    pass.setVertexBuffer(0, _vertexBuffer);
    final num contentLeft = (_viewGpuContext.contentLeft.get() as num) *
        (_viewGpuContext.devicePixelRatio.get() as num);
    final int left = contentLeft.ceil();
    final dynamic canvas = _canvas;
    pass.setScissorRect(left, 0, canvas.width - left, canvas.height);
    pass.setBindGroup(0, _bindGroup);
    _renderStrategy.value!.draw(pass, viewportData);
    pass.end();
    final Object commandBuffer = encoder.finish();
    (device as dynamic).queue.submit(<Object?>[commandBuffer]);
    _lastViewportData = viewportData;
    _lastViewLineOptions = options;
    _updateMaxLineWidth(viewportData, options);
  }

  Object get device => _device ?? (() => throw StateError('not initialized'))();

  void _updateMaxLineWidth(
    ViewportData viewportData,
    IViewLineOptionsForViewLinesGpu viewLineOptions,
  ) {
    final num dpr = _devicePixelRatioForReplay?.call() ?? 1;
    num localMaxLineWidth = 0;
    for (int lineNumber = viewportData.startLineNumber;
        lineNumber <= viewportData.endLineNumber;
        lineNumber++) {
      if (!_viewGpuContext.canRender(
          viewLineOptions, viewportData, lineNumber)) {
        continue;
      }
      final dynamic lineData = viewportData.getViewLineRenderingData(lineNumber);
      final num lineWidth =
          _computeLineWidth(lineData as Object, viewLineOptions, dpr);
      if (lineWidth > localMaxLineWidth) localMaxLineWidth = lineWidth;
    }
    final int iLineWidth = localMaxLineWidth.ceil();
    if (iLineWidth > _maxLineWidth) {
      _maxLineWidth = iLineWidth;
      (_gpuContext.viewModel as dynamic).viewLayout.setMaxLineWidth(_maxLineWidth);
    }
  }

  num _computeLineWidth(
    Object lineData,
    IViewLineOptionsForViewLinesGpu viewLineOptions,
    num dpr,
  ) {
    final dynamic ld = lineData;
    final String content = ld.content as String;
    final bool basicAscii = ld.isBasicASCII as bool;
    final bool mono = viewLineOptions.useMonospaceOptimizations;
    final IContentSegmenter? segmenter = (basicAscii && mono)
        ? null
        : (_segmenterFactoryForReplay ?? createContentSegmenter)(
            lineData, viewLineOptions);
    num width = 0;
    int tabXOffset = 0;
    for (int x = 0; x < content.length; x++) {
      String? chars;
      if (basicAscii && mono) {
        chars = content[x];
      } else {
        chars = segmenter!.getSegmentAtIndex(x);
        if (chars == null) continue;
      }
      if (chars == '\t') {
        final int offsetBefore = x + tabXOffset;
        tabXOffset = CursorColumns.nextRenderTabStop(
            x + tabXOffset, ld.tabSize as int);
        width += viewLineOptions.spaceWidth * (tabXOffset - offsetBefore);
        tabXOffset -= x + 1;
      } else if (basicAscii && mono) {
        width += viewLineOptions.spaceWidth;
      } else {
        width += _textMetrics(chars)[
              'width']! /
            dpr;
      }
    }
    return width;
  }

  Map<String, num> _textMetrics(String chars) =>
      _renderStrategy.value!.glyphRasterizer.getTextMetrics(chars);

  @override
  List<LineVisibleRanges>? linesVisibleRangesForRange(
    Range range,
    bool includeNewLines,
  ) {
    final ViewportData? lastViewportData = _lastViewportData;
    if (lastViewportData == null) return null;
    final int originalEndLineNumber = range.endLineNumber;
    final Range? intersection =
        range.intersectRanges(lastViewportData.visibleRange);
    if (intersection == null) return null;
    final int rendStartLineNumber = lastViewportData.startLineNumber;
    final int rendEndLineNumber = lastViewportData.endLineNumber;
    final IViewLineOptionsForViewLinesGpu? viewLineOptions =
        _lastViewLineOptions;
    if (viewLineOptions == null) return null;
    final List<LineVisibleRanges> visibleRanges = <LineVisibleRanges>[];
    int nextLineModelLineNumber = 0;
    if (includeNewLines) {
      nextLineModelLineNumber = _convertToModelLineNumber(
          Position(intersection.startLineNumber, 1));
    }
    for (int lineNumber = intersection.startLineNumber;
        lineNumber <= intersection.endLineNumber;
        lineNumber++) {
      if (lineNumber < rendStartLineNumber || lineNumber > rendEndLineNumber) {
        continue;
      }
      final int startColumn = lineNumber == intersection.startLineNumber
          ? intersection.startColumn
          : 1;
      final bool continuesInNextLine = lineNumber != originalEndLineNumber;
      final int endColumn = continuesInNextLine
          ? (_gpuContext.viewModel as dynamic).getLineMaxColumn(lineNumber) as int
          : intersection.endColumn;
      final VisibleRanges? visibleRangesForLine =
          _visibleRangesForLineRange(lineNumber, startColumn, endColumn);
      if (visibleRangesForLine == null) continue;
      if (includeNewLines && lineNumber < originalEndLineNumber) {
        final int currentLineModelLineNumber = nextLineModelLineNumber;
        nextLineModelLineNumber = _convertToModelLineNumber(
            Position(lineNumber + 1, 1));
        if (currentLineModelLineNumber != nextLineModelLineNumber) {
          visibleRangesForLine.ranges.last.width +=
              viewLineOptions.spaceWidth;
        }
      }
      visibleRanges.add(LineVisibleRanges(
        visibleRangesForLine.outsideRenderedLine,
        lineNumber,
        HorizontalRange.from(visibleRangesForLine.ranges),
        continuesInNextLine,
      ));
    }
    if (visibleRanges.isEmpty) return null;
    return visibleRanges;
  }

  VisibleRanges? _visibleRangesForLineRange(
    int lineNumber,
    int startColumn,
    int endColumn,
  ) {
    if (shouldRender()) return null;
    final ViewportData? viewportData = _lastViewportData;
    final IViewLineOptionsForViewLinesGpu? viewLineOptions =
        _lastViewLineOptions;
    if (viewportData == null ||
        viewLineOptions == null ||
        lineNumber < viewportData.startLineNumber ||
        lineNumber > viewportData.endLineNumber) {
      return null;
    }
    final dynamic lineData = viewportData.getViewLineRenderingData(lineNumber);
    final String content = lineData.content as String;
    final bool basicAscii = (lineData as dynamic).isBasicASCII as bool;
    final bool mono = viewLineOptions.useMonospaceOptimizations;
    final IContentSegmenter? segmenter = (basicAscii && mono)
        ? null
        : (_segmenterFactoryForReplay ?? createContentSegmenter)(
            lineData as Object, viewLineOptions);
    String? chars = '';
    int resolvedStartColumn = 0;
    num resolvedStartCssPixelOffset = 0;
    final num dpr = _devicePixelRatioForReplay?.call() ?? 1;
    for (int x = 0; x < startColumn - 1; x++) {
      if (basicAscii && mono) {
        chars = content[x];
      } else {
        chars = segmenter!.getSegmentAtIndex(x);
        if (chars == null) continue;
        resolvedStartCssPixelOffset +=
            _textMetrics(chars)['width']! / dpr -
                viewLineOptions.spaceWidth;
      }
      if (chars == '\t') {
        resolvedStartColumn = CursorColumns.nextRenderTabStop(
            resolvedStartColumn, (lineData as dynamic).tabSize as int);
      } else {
        resolvedStartColumn++;
      }
    }
    int resolvedEndColumn = resolvedStartColumn;
    num resolvedEndCssPixelOffset = 0;
    for (int x = startColumn - 1; x < endColumn - 1; x++) {
      if (basicAscii && mono) {
        chars = content[x];
      } else {
        chars = segmenter!.getSegmentAtIndex(x);
        if (chars == null) continue;
        resolvedEndCssPixelOffset += _textMetrics(chars)['width']! / dpr -
            viewLineOptions.spaceWidth;
      }
      if (chars == '\t') {
        resolvedEndColumn = CursorColumns.nextRenderTabStop(
            resolvedEndColumn, (lineData as dynamic).tabSize as int);
      } else {
        resolvedEndColumn++;
      }
    }
    return VisibleRanges(false, <FloatHorizontalRange>[
      FloatHorizontalRange(
        resolvedStartColumn * viewLineOptions.spaceWidth +
            resolvedStartCssPixelOffset,
        (resolvedEndColumn - resolvedStartColumn) *
                viewLineOptions.spaceWidth +
            resolvedEndCssPixelOffset,
      ),
    ]);
  }

  int _convertToModelLineNumber(Position position) {
    final dynamic converter = (_gpuContext.viewModel as dynamic).coordinatesConverter;
    return (converter.convertViewPositionToModelPosition(position) as Position)
        .lineNumber;
  }

  @override
  HorizontalPosition? visibleRangeForPosition(Position position) {
    final VisibleRanges? visibleRanges = _visibleRangesForLineRange(
      position.lineNumber,
      position.column,
      position.column,
    );
    if (visibleRanges == null) return null;
    return HorizontalPosition(
      visibleRanges.outsideRenderedLine,
      visibleRanges.ranges[0].left,
    );
  }

  num? getLineWidth(int lineNumber) {
    final ViewportData? lastViewportData = _lastViewportData;
    final IViewLineOptionsForViewLinesGpu? viewLineOptions =
        _lastViewLineOptions;
    if (lastViewportData == null || viewLineOptions == null) return null;
    if (!_viewGpuContext.canRender(
        viewLineOptions, lastViewportData, lineNumber)) {
      return null;
    }
    final dynamic lineData =
        lastViewportData.getViewLineRenderingData(lineNumber);
    final VisibleRanges? lineRange = _visibleRangesForLineRange(
      lineNumber,
      1,
      lineData.maxColumn as int,
    );
    final List<FloatHorizontalRange>? ranges = lineRange?.ranges;
    if (ranges == null || ranges.isEmpty) return null;
    final FloatHorizontalRange lastRange = ranges[ranges.length - 1];
    return lastRange.left + lastRange.width;
  }

  Position? getPositionAtCoordinate(
    int lineNumber,
    num mouseContentHorizontalOffset,
  ) {
    final ViewportData? lastViewportData = _lastViewportData;
    final IViewLineOptionsForViewLinesGpu? viewLineOptions =
        _lastViewLineOptions;
    if (lastViewportData == null || viewLineOptions == null) return null;
    if (!_viewGpuContext.canRender(
        viewLineOptions, lastViewportData, lineNumber)) {
      return null;
    }
    final dynamic lineData =
        lastViewportData.getViewLineRenderingData(lineNumber);
    final String content = lineData.content as String;
    final num dpr = _devicePixelRatioForReplay?.call() ?? 1;
    final num mouseContentHorizontalOffsetDevicePixels =
        mouseContentHorizontalOffset * dpr;
    final num spaceWidthDevicePixels = viewLineOptions.spaceWidth * dpr;
    final IContentSegmenter segmenter =
        (_segmenterFactoryForReplay ?? createContentSegmenter)(
            lineData as Object, viewLineOptions);
    num widthSoFar = 0;
    num charWidth = 0;
    int tabXOffset = 0;
    int column = 0;
    for (int x = 0; x < content.length; x++) {
      final String? chars = segmenter.getSegmentAtIndex(x);
      if (chars == null) {
        column++;
        continue;
      }
      if (chars == '\t') {
        final int offsetBefore = x + tabXOffset;
        tabXOffset = CursorColumns.nextRenderTabStop(
            x + tabXOffset, (lineData as dynamic).tabSize as int);
        charWidth = spaceWidthDevicePixels * (tabXOffset - offsetBefore);
        tabXOffset -= x + 1;
      } else if ((lineData as dynamic).isBasicASCII as bool &&
          viewLineOptions.useMonospaceOptimizations) {
        charWidth = spaceWidthDevicePixels;
      } else {
        charWidth = _textMetrics(chars)['width']!;
      }
      if (mouseContentHorizontalOffsetDevicePixels <
          widthSoFar + charWidth / 2) {
        break;
      }
      widthSoFar += charWidth;
      column++;
    }
    return Position(lineNumber, column + 1);
  }

  @override
  void dispose() {
    _disposedForReplay = true;
    super.dispose();
  }
}
