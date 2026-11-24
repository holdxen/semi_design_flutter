// 1:1 port of vscode/src/vs/editor/browser/gpu/atlas/textureAtlas.ts
//
// DOM (window/DPR), task queue and instantiation remain injectable seams in
// the surrounding ports; the page management / metadata / warm-up algorithm is
// transcribed verbatim.

import 'dart:math' as math;

import '../../../../base/browser/dom.dart' show getActiveWindow, windowCarrier;
import '../../../../base/common/charCode.dart' show CharCode;
import '../../../../base/common/errors.dart' show BugIndicatingError;
import '../../../../base/common/event.dart' show Emitter, Event, eventRunAndSubscribe;
import '../../../../base/common/lifecycle.dart'
    show Disposable, MutableDisposable, dispose, toDisposable;
import '../../../../base/common/map.dart' show NKeyMap;
import '../../../../platform/instantiation/common/instantiation.dart'
    show IInstantiationServiceType;
import '../../../../platform/theme/common/themeService.dart'
    show IThemeServiceType;
import '../../../common/encodedTokenAttributes.dart' show MetadataConsts;
import '../css/decorationStyleCache.dart' show DecorationStyleCache;
import '../raster/glyphRasterizer.dart' show GlyphRasterizer;
import '../raster/raster.dart' show IGlyphRasterizer;
import '../taskQueue.dart' show ITaskQueue, IdleTaskQueue;
import 'atlas.dart'
    show Blob, GlyphMap, IReadableTextureAtlasPage, ITextureAtlasPageGlyph;
import 'textureAtlasPage.dart'
    show AllocatorType, AllocatorTypes, TextureAtlasPage;

/// 1:1: `export interface ITextureAtlasOptions`
class ITextureAtlasOptions {
  AllocatorType? allocatorType;
}

/// 1:1: `export class TextureAtlas extends Disposable`
class TextureAtlas extends Disposable {
  List<String>? _colorMap;
  final MutableDisposable<ITaskQueue> _warmUpTask =
      MutableDisposable<ITaskQueue>();
  final Set<int> _warmedUpRasterizers = <int>{};
  final AllocatorType _allocatorType;

  /// The maximum number of texture atlas pages.
  static const int maximumPageCount = 16;

  final List<TextureAtlasPage> _pages = <TextureAtlasPage>[];

  List<IReadableTextureAtlasPage> get pages =>
      _pages.cast<IReadableTextureAtlasPage>();

  late final int pageSize;

  final GlyphMap<int> _glyphPageIndex = NKeyMap<int, List<Object>>();

  final Emitter<void> _onDidDeleteGlyphs;

  late final Event<void> onDidDeleteGlyphs;

  final int _maxTextureSize;
  final DecorationStyleCache _decorationStyleCache;
  final IThemeServiceType _themeService;
  final IInstantiationServiceType _instantiationService;

  TextureAtlas(
    this._maxTextureSize,
    ITextureAtlasOptions? options,
    this._decorationStyleCache,
    this._themeService,
    this._instantiationService,
  ) : _allocatorType = options?.allocatorType ?? AllocatorTypes.slab,
      _onDidDeleteGlyphs = Emitter<void>() {
    register(_warmUpTask);
    register(_onDidDeleteGlyphs);
    onDidDeleteGlyphs = _onDidDeleteGlyphs.event;

    register(eventRunAndSubscribe(
      _themeService.onDidColorThemeChange,
      (_) {
        if (_colorMap != null) {
          clear();
        }
        _colorMap = _themeService.getColorTheme().tokenColorMap;
      },
    ));

    final int dprFactor =
        math.max(1, windowCarrier(getActiveWindow()).devicePixelRatio.floor());
    pageSize = math.min(1024 * dprFactor, _maxTextureSize);
    _initFirstPage();

    register(toDisposable(() => dispose(_pages)));
  }

  void _initFirstPage() {
    final TextureAtlasPage firstPage = _instantiationService.createInstance(
        TextureAtlasPage, <Object?>[0, pageSize, _allocatorType]) as TextureAtlasPage;
    _pages.add(firstPage);

    // The first glyph on the first page must be an empty glyph such that
    // zeroed out cells end up rendering nothing.
    final GlyphRasterizer nullRasterizer =
        GlyphRasterizer(1, '', 1, _decorationStyleCache);
    firstPage.getGlyph(nullRasterizer, '', 0, 0);
    nullRasterizer.dispose();
  }

  void clear() {
    for (final TextureAtlasPage page in _pages) {
      page.dispose();
    }
    _pages.length = 0;
    _glyphPageIndex.clear();
    _warmedUpRasterizers.clear();
    _warmUpTask.clear();

    _initFirstPage();

    _onDidDeleteGlyphs.fire(null);
  }

  ITextureAtlasPageGlyph getGlyph(IGlyphRasterizer rasterizer, String chars,
      int tokenMetadata, int decorationStyleSetId, num x) {
    tokenMetadata &= ~(MetadataConsts.languageIdMask |
        MetadataConsts.tokenTypeMask |
        MetadataConsts.balancedBracketsMask);

    tokenMetadata |= ((x % 1) * 10).floor();

    if (!_warmedUpRasterizers.contains(rasterizer.id)) {
      _warmUpAtlas(rasterizer);
      _warmedUpRasterizers.add(rasterizer.id);
    }

    return _tryGetGlyph(
      _glyphPageIndex.get(<Object>[
          chars,
          tokenMetadata,
          decorationStyleSetId,
          rasterizer.cacheKey,
        ]) ?? 0,
      rasterizer,
      chars,
      tokenMetadata,
      decorationStyleSetId,
    );
  }

  ITextureAtlasPageGlyph _tryGetGlyph(int pageIndex,
      IGlyphRasterizer rasterizer, String chars, int tokenMetadata,
      int decorationStyleSetId) {
    _glyphPageIndex.set(pageIndex, <Object>[
      chars,
      tokenMetadata,
      decorationStyleSetId,
      rasterizer.cacheKey,
    ]);
    return (_pages[pageIndex].getGlyph(
          rasterizer,
          chars,
          tokenMetadata,
          decorationStyleSetId,
        ) ??
        (pageIndex + 1 < _pages.length
            ? _tryGetGlyph(pageIndex + 1, rasterizer, chars, tokenMetadata,
                decorationStyleSetId)
            : null)) ??
        _getGlyphFromNewPage(
            rasterizer, chars, tokenMetadata, decorationStyleSetId);
  }

  ITextureAtlasPageGlyph _getGlyphFromNewPage(IGlyphRasterizer rasterizer,
      String chars, int tokenMetadata, int decorationStyleSetId) {
    if (_pages.length >= maximumPageCount) {
      throw BugIndicatingError(
          'Attempt to create a texture atlas page past the limit $maximumPageCount');
    }
    _pages.add(_instantiationService.createInstance(
        TextureAtlasPage,
        <Object?>[
          _pages.length,
          pageSize,
          _allocatorType
        ]) as TextureAtlasPage);
    _glyphPageIndex.set(_pages.length - 1, <Object>[
      chars,
      tokenMetadata,
      decorationStyleSetId,
      rasterizer.cacheKey,
    ]);
    return _pages[_pages.length - 1].getGlyph(
        rasterizer, chars, tokenMetadata, decorationStyleSetId)!;
  }

  Future<List<Blob>> getUsagePreview() =>
      Future.wait(_pages.map((TextureAtlasPage e) => e.getUsagePreview()));

  List<String> getStats() =>
      _pages.map((TextureAtlasPage e) => e.getStats()).toList();

  /// Warms up the atlas by rasterizing all printable ASCII characters for each
  /// token color, distributed over multiple idle callbacks.
  void _warmUpAtlas(IGlyphRasterizer rasterizer) {
    final List<String>? colorMap = _colorMap;
    if (colorMap == null) {
      throw BugIndicatingError('Cannot warm atlas without color map');
    }
    _warmUpTask.value?.clear();
    final ITaskQueue taskQueue =
        _instantiationService.createInstance(IdleTaskQueue, <Object?>[])
            as ITaskQueue;
    _warmUpTask.value = taskQueue;
    // Warm up using roughly the larger glyphs first to help optimize atlas
    // allocation: A-Z, a-z, then remaining ascii.
    for (final List<int> range in <List<int>>[
      <int>[CharCode.A, CharCode.Z],
      <int>[CharCode.a, CharCode.z],
      <int>[CharCode.ExclamationMark, CharCode.Tilde],
    ]) {
      for (int code = range[0]; code <= range[1]; code++) {
        for (int fgColor = 0; fgColor < colorMap.length; fgColor++) {
          taskQueue.enqueue(() {
            for (double x = 0; x < 1; x += 0.1) {
              getGlyph(
                rasterizer,
                String.fromCharCode(code),
                (fgColor << MetadataConsts.foregroundOffset) &
                    MetadataConsts.foregroundMask,
                0,
                x,
              );
            }
            return null;
          });
        }
      }
    }
  }
}
