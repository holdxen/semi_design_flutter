// 1:1 port of vscode/src/vs/editor/browser/gpu/atlas/textureAtlasPage.ts
//
// Dart has no DOM OffscreenCanvas; the canvas is the [AtlasCanvas] carrier from
// the allocators, created through the existing injectable `atlasCanvasFactory`.

import 'dart:math' as math;

import '../../../../base/common/lifecycle.dart'
    show Disposable, toDisposable;
import '../../../../base/common/map.dart' show NKeyMap;
import '../../../../platform/log/common/log.dart'
    show ILogServiceType, LogLevel;
import '../../../../platform/theme/common/themeService.dart'
    show IThemeServiceType;
import '../raster/raster.dart'
    show
        IBoundingBox,
        IGlyphRasterizer,
        IRasterizedGlyph,
        OffscreenCanvas;
import 'atlas.dart'
    show
        Blob,
        GlyphMap,
        IReadableTextureAtlasPage,
        ITextureAtlasAllocator,
        ITextureAtlasPageGlyph;
import 'textureAtlasShelfAllocator.dart'
    show AtlasCanvas, TextureAtlasShelfAllocator, atlasCanvasFactory;
import 'textureAtlasSlabAllocator.dart' show TextureAtlasSlabAllocator;

/// 1:1: `export type AllocatorType = 'shelf' | 'slab' | ((canvas, textureIndex) => ITextureAtlasAllocator)`
/// A Dart union carrier: either [AllocatorTypes] strings or an [AllocatorFactory].
typedef AllocatorType = Object;

class AllocatorTypes {
  static const String shelf = 'shelf';
  static const String slab = 'slab';
}

typedef AllocatorFactory = ITextureAtlasAllocator Function(
    AtlasCanvas canvas, int textureIndex);

class _MutableBoundingBox implements IBoundingBox {
  @override
  num left = 0;
  @override
  num top = 0;
  @override
  num right = 0;
  @override
  num bottom = 0;
}

/// 1:1: `export class TextureAtlasPage extends Disposable implements IReadableTextureAtlasPage`
class TextureAtlasPage extends Disposable implements IReadableTextureAtlasPage {
  int _version = 0;

  @override
  int get version => _version;

  /// The maximum number of glyphs that can be drawn to the page.
  static const int maximumGlyphCount = 5000;

  final _MutableBoundingBox _usedArea = _MutableBoundingBox();

  @override
  IBoundingBox get usedArea => _usedArea;

  late final AtlasCanvas _canvas;

  /// 1:1: `get source(): OffscreenCanvas`
  @override
  OffscreenCanvas get source => OffscreenCanvas(_canvas);

  final GlyphMap<ITextureAtlasPageGlyph> _glyphMap =
      NKeyMap<ITextureAtlasPageGlyph, List<Object>>();
  final Set<ITextureAtlasPageGlyph> _glyphInOrderSet =
      <ITextureAtlasPageGlyph>{};

  @override
  Iterable<ITextureAtlasPageGlyph> get glyphs => _glyphInOrderSet;

  late final ITextureAtlasAllocator _allocator;
  final ILogServiceType _logService;
  late List<String> _colorMap;

  TextureAtlasPage(
    int textureIndex,
    int pageSize,
    AllocatorType allocatorType,
    this._logService,
    IThemeServiceType themeService,
  ) : super() {
    _canvas = atlasCanvasFactory(pageSize, pageSize);
    _colorMap = themeService.getColorTheme().tokenColorMap;

    if (allocatorType == AllocatorTypes.shelf) {
      _allocator = TextureAtlasShelfAllocator(_canvas, textureIndex);
    } else if (allocatorType == AllocatorTypes.slab) {
      _allocator = TextureAtlasSlabAllocator(_canvas, textureIndex);
    } else {
      _allocator = (allocatorType as AllocatorFactory)(_canvas, textureIndex);
    }

    // Reduce impact of a memory leak if this object is not released
    register(toDisposable(() {
      _canvas.width = 1;
      _canvas.height = 1;
    }));
  }

  ITextureAtlasPageGlyph? getGlyph(IGlyphRasterizer rasterizer, String chars,
      int tokenMetadata, int decorationStyleSetId) {
    // IMPORTANT: There are intentionally no intermediate variables here to aid
    // in runtime optimization as it's a very hot function.
    return _glyphMap.get(<Object>[
          chars,
          tokenMetadata,
          decorationStyleSetId,
          rasterizer.cacheKey,
        ]) ??
        _createGlyph(rasterizer, chars, tokenMetadata, decorationStyleSetId);
  }

  ITextureAtlasPageGlyph? _createGlyph(IGlyphRasterizer rasterizer,
      String chars, int tokenMetadata, int decorationStyleSetId) {
    if (_glyphInOrderSet.length >= maximumGlyphCount) {
      return null;
    }

    final IRasterizedGlyph rasterizedGlyph = rasterizer.rasterizeGlyph(
        chars, tokenMetadata, decorationStyleSetId, _colorMap);
    final ITextureAtlasPageGlyph? glyph = _allocator.allocate(rasterizedGlyph);
    if (glyph == null) {
      return null;
    }

    _glyphMap.set(glyph, <Object>[
      chars,
      tokenMetadata,
      decorationStyleSetId,
      rasterizer.cacheKey,
    ]);
    _glyphInOrderSet.add(glyph);

    _version++;
    _usedArea.right = math.max(_usedArea.right, glyph.x + glyph.w - 1);
    _usedArea.bottom = math.max(_usedArea.bottom, glyph.y + glyph.h - 1);

    if (_logService.getLevel() == LogLevel.Trace) {
      _logService.trace('New glyph', <Object?>[
        <String, Object?>{
          'chars': chars,
          'tokenMetadata': tokenMetadata,
          'decorationStyleSetId': decorationStyleSetId,
          'rasterizedGlyph': rasterizedGlyph,
          'glyph': glyph,
        }
      ]);
    }

    return glyph;
  }

  @override
  Future<Blob> getUsagePreview() => _allocator.getUsagePreview();

  @override
  String getStats() => _allocator.getStats();
}
