// 1:1 port of vs/editor/browser/gpu/atlas/textureAtlasShelfAllocator.ts
//
// The source operates on a DOM `OffscreenCanvas` / `OffscreenCanvasRenderingContext2D`.
// Dart has no DOM, so those surfaces are represented as injectable carriers:
// [AtlasCanvas] (width/height + getContext + convertToBlob), [AtlasContext2D]
// (drawImage/fillRect/fillStyle) and [AtlasBlob]. The allocation math (row
// packing, glyph placement, usage stats) is transcribed verbatim.

import 'dart:math' as math;

import '../../../../base/common/errors.dart' show BugIndicatingError;
import '../gpuUtils.dart' show ensureNonNullable;
import '../raster/raster.dart'
    show IBoundingBox, IRasterizedGlyph, OffscreenCanvas;
import 'atlas.dart'
    show
        Blob,
        ITextureAtlasAllocator,
        ITextureAtlasPageGlyph,
        TextureAtlasPageGlyph,
        UsagePreviewColors;

/// DOM bridge of `OffscreenCanvasRenderingContext2D` (subset used here).
/// The embedder supplies a concrete context; the allocator only calls these.
abstract class AtlasContext2D {
  set fillStyle(String value);

  /// Source `ctx.globalAlpha` used by the slab allocator's usage preview.
  /// Default no-op keeps existing carriers source-compatible.
  set globalAlpha(num value) {}

  void drawImage(
    OffscreenCanvas source,
    num sx,
    num sy,
    num sw,
    num sh,
    num dx,
    num dy,
    num dw,
    num dh,
  );
  void fillRect(num x, num y, num w, num h);
}

/// DOM bridge of `OffscreenCanvas`: dimensions + 2D context + blob export.
class AtlasCanvas {
  final int width;
  final int height;
  final AtlasContext2D Function(String contextId,
      [Map<String, Object?>? options]) getContext;
  final Future<Blob> Function() convertToBlob;

  AtlasCanvas({
    required this.width,
    required this.height,
    required this.getContext,
    required this.convertToBlob,
  });
}

/// Factory for `new OffscreenCanvas(w, h)` in [TextureAtlasShelfAllocator.getUsagePreview].
/// The embedder swaps this to obtain a real canvas; a no-op default keeps the
/// allocator usable in pure-Dart contexts.
typedef AtlasCanvasFactory = AtlasCanvas Function(int width, int height);

AtlasCanvasFactory _atlasCanvasFactory = (int w, int h) => AtlasCanvas(
      width: w,
      height: h,
      getContext: (_, [__]) => throw Exception('no 2d context'),
      convertToBlob: () async => Blob(Object()),
    );

AtlasCanvasFactory get atlasCanvasFactory => _atlasCanvasFactory;
set atlasCanvasFactory(AtlasCanvasFactory factory) => _atlasCanvasFactory = factory;

/// 1:1: `export class TextureAtlasShelfAllocator implements ITextureAtlasAllocator`
class TextureAtlasShelfAllocator implements ITextureAtlasAllocator {
  final AtlasContext2D _ctx;

  final ITextureAtlasShelf _currentRow = ITextureAtlasShelf(0, 0, 0);

  /// A set of all glyphs allocated, only tracked to enable debug functionality.
  final Set<ITextureAtlasPageGlyph> _allocatedGlyphs = <ITextureAtlasPageGlyph>{};

  int _nextIndex = 0;

  final AtlasCanvas _canvas;
  final int _textureIndex;

  TextureAtlasShelfAllocator(this._canvas, this._textureIndex)
      : _ctx = ensureNonNullable<AtlasContext2D>(
          _canvas.getContext('2d', {'willReadFrequently': true}),
        );

  @override
  ITextureAtlasPageGlyph? allocate(IRasterizedGlyph rasterizedGlyph) {
    // The glyph does not fit into the atlas page
    final IBoundingBox bb = rasterizedGlyph.boundingBox;
    final num glyphWidth = bb.right - bb.left + 1;
    final num glyphHeight = bb.bottom - bb.top + 1;
    if (glyphWidth > _canvas.width || glyphHeight > _canvas.height) {
      throw BugIndicatingError('Glyph is too large for the atlas page');
    }

    // Finalize and increment row if it doesn't fit horizontally
    if (bb.right - bb.left + 1 > _canvas.width - _currentRow.x) {
      _currentRow.x = 0;
      _currentRow.y += _currentRow.h;
      _currentRow.h = 1;
    }

    // Return undefined if there isn't any room left
    if (_currentRow.y + bb.bottom - bb.top + 1 > _canvas.height) {
      return null;
    }

    // Draw glyph
    _ctx.drawImage(
      rasterizedGlyph.source,
      bb.left,
      bb.top,
      glyphWidth,
      glyphHeight,
      _currentRow.x,
      _currentRow.y,
      glyphWidth,
      glyphHeight,
    );

    // Create glyph object
    final ITextureAtlasPageGlyph glyph = TextureAtlasPageGlyph(
      pageIndex: _textureIndex,
      glyphIndex: _nextIndex++,
      x: _currentRow.x,
      y: _currentRow.y,
      w: glyphWidth,
      h: glyphHeight,
      originOffsetX: rasterizedGlyph.originOffset.x,
      originOffsetY: rasterizedGlyph.originOffset.y,
      fontBoundingBoxAscent: rasterizedGlyph.fontBoundingBoxAscent,
      fontBoundingBoxDescent: rasterizedGlyph.fontBoundingBoxDescent,
    );

    // Shift current row
    _currentRow.x += glyphWidth;
    _currentRow.h = math.max(_currentRow.h, glyphHeight);

    // Set the glyph
    _allocatedGlyphs.add(glyph);

    return glyph;
  }

  @override
  Future<Blob> getUsagePreview() async {
    final int w = _canvas.width;
    final int h = _canvas.height;
    final AtlasCanvas canvas = atlasCanvasFactory(w, h);
    final AtlasContext2D ctx = ensureNonNullable<AtlasContext2D>(
      canvas.getContext('2d'),
    );
    ctx.fillStyle = UsagePreviewColors.Unused;
    ctx.fillRect(0, 0, w, h);

    final Map<num, num> rowHeight = <num, num>{}; // y -> h
    final Map<num, num> rowWidth = <num, num>{}; // y -> w
    for (final ITextureAtlasPageGlyph g in _allocatedGlyphs) {
      rowHeight[g.y] = math.max(rowHeight[g.y] ?? 0, g.h);
      rowWidth[g.y] = math.max(rowWidth[g.y] ?? 0, g.x + g.w);
    }
    for (final ITextureAtlasPageGlyph g in _allocatedGlyphs) {
      ctx.fillStyle = UsagePreviewColors.Used;
      ctx.fillRect(g.x, g.y, g.w, g.h);
      ctx.fillStyle = UsagePreviewColors.Wasted;
      ctx.fillRect(g.x, g.y + g.h, g.w, rowHeight[g.y]! - g.h);
    }
    for (final MapEntry<num, num> entry in rowWidth.entries) {
      final num rowY = entry.key;
      final num rowW = entry.value;
      if (rowY != _currentRow.y) {
        ctx.fillStyle = UsagePreviewColors.Wasted;
        ctx.fillRect(rowW, rowY, w - rowW, rowHeight[rowY]!);
      }
    }
    return canvas.convertToBlob();
  }

  @override
  String getStats() {
    final int w = _canvas.width;
    final int h = _canvas.height;

    num usedPixels = 0;
    num wastedPixels = 0;
    final num totalPixels = w * h;

    final Map<num, num> rowHeight = <num, num>{}; // y -> h
    final Map<num, num> rowWidth = <num, num>{}; // y -> w
    for (final ITextureAtlasPageGlyph g in _allocatedGlyphs) {
      rowHeight[g.y] = math.max(rowHeight[g.y] ?? 0, g.h);
      rowWidth[g.y] = math.max(rowWidth[g.y] ?? 0, g.x + g.w);
    }
    for (final ITextureAtlasPageGlyph g in _allocatedGlyphs) {
      usedPixels += g.w * g.h;
      wastedPixels += g.w * (rowHeight[g.y]! - g.h);
    }
    for (final MapEntry<num, num> entry in rowWidth.entries) {
      final num rowY = entry.key;
      final num rowW = entry.value;
      if (rowY != _currentRow.y) {
        wastedPixels += (w - rowW) * rowHeight[rowY]!;
      }
    }
    return [
      'page$_textureIndex:',
      '     Total: $totalPixels (${w}x${h})',
      '      Used: $usedPixels (${((usedPixels / totalPixels) * 100).toStringAsPrecision(2)}%)',
      '    Wasted: $wastedPixels (${((wastedPixels / totalPixels) * 100).toStringAsPrecision(2)}%)',
      'Efficiency: ${((usedPixels / (usedPixels + wastedPixels)) * 100).toStringAsPrecision(2)}%',
    ].join('\n');
  }
}

/// 1:1: `interface ITextureAtlasShelf`
class ITextureAtlasShelf {
  num x;
  num y;
  num h;

  ITextureAtlasShelf(this.x, this.y, this.h);
}
