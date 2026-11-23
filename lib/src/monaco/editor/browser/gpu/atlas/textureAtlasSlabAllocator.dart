// 1:1 port of vs/editor/browser/gpu/atlas/textureAtlasSlabAllocator.ts
//
// The source operates on a DOM `OffscreenCanvas` / `OffscreenCanvasRenderingContext2D`.
// Dart has no DOM, so those surfaces reuse the carriers already introduced by
// textureAtlasShelfAllocator.dart: [AtlasCanvas], [AtlasContext2D], [AtlasBlob]
// via [atlasCanvasFactory]. The slab packing math is transcribed verbatim,
// including the source's exact `r.h === 0` checks in the open-region branches.

import 'dart:math' as math;

import '../../../../base/browser/dom.dart' show getActiveWindow, windowCarrier;
import '../../../../base/common/errors.dart' show BugIndicatingError;
import '../../../../base/common/map.dart' show NKeyMap;
import '../gpuUtils.dart' show ensureNonNullable;
import '../raster/raster.dart' show IRasterizedGlyph, OffscreenCanvas;
import 'atlas.dart'
    show
        Blob,
        ITextureAtlasAllocator,
        ITextureAtlasPageGlyph,
        TextureAtlasPageGlyph,
        UsagePreviewColors;
import 'textureAtlasShelfAllocator.dart' show AtlasCanvas, AtlasContext2D, atlasCanvasFactory;

/// JS `Math.floor`: Dart `num.floor()` matches for all sign cases.
int _jsFloor(num value) => value.floor();

/// 1:1: `export interface TextureAtlasSlabAllocatorOptions`
class TextureAtlasSlabAllocatorOptions {
  final num? slabW;
  final num? slabH;
  const TextureAtlasSlabAllocatorOptions({this.slabW, this.slabH});
}

/// 1:1: `interface ITextureAtlasSlab`
class ITextureAtlasSlab {
  num x;
  num y;
  num entryH;
  num entryW;
  int count;
  ITextureAtlasSlab(this.x, this.y, this.entryH, this.entryW, this.count);
}

/// 1:1: `interface ITextureAtlasSlabUnusedRect`
class ITextureAtlasSlabUnusedRect {
  num x;
  num y;
  num w;
  num h;
  ITextureAtlasSlabUnusedRect(this.x, this.y, this.w, this.h);
}

/// Helper mirroring `function addEntryToMapArray<K, V>(map, key, entry)`.
void _addEntryToMapArray<K, V>(Map<K, List<V>> map, K key, V entry) {
  final List<V>? list = map[key];
  if (list == null) {
    map[key] = <V>[entry];
  } else {
    list.add(entry);
  }
}

/// 1:1: `export class TextureAtlasSlabAllocator implements ITextureAtlasAllocator`
class TextureAtlasSlabAllocator implements ITextureAtlasAllocator {
  final AtlasContext2D _ctx;

  final List<ITextureAtlasSlab> _slabs = <ITextureAtlasSlab>[];
  final NKeyMap<ITextureAtlasSlab, List<Object>> _activeSlabsByDims =
      NKeyMap<ITextureAtlasSlab, List<Object>>();

  final List<ITextureAtlasSlabUnusedRect> _unusedRects =
      <ITextureAtlasSlabUnusedRect>[];

  final Map<num, List<ITextureAtlasSlabUnusedRect>> _openRegionsByHeight =
      <num, List<ITextureAtlasSlabUnusedRect>>{};
  final Map<num, List<ITextureAtlasSlabUnusedRect>> _openRegionsByWidth =
      <num, List<ITextureAtlasSlabUnusedRect>>{};

  /// A set of all glyphs allocated, only tracked to enable debug functionality.
  final Set<ITextureAtlasPageGlyph> _allocatedGlyphs =
      <ITextureAtlasPageGlyph>{};

  num _slabW;
  num _slabH;
  num _slabsPerRow;
  num _slabsPerColumn;
  int _nextIndex = 0;

  final AtlasCanvas _canvas;
  final int _textureIndex;

  TextureAtlasSlabAllocator(this._canvas, this._textureIndex,
      [TextureAtlasSlabAllocatorOptions? options])
      : _ctx = ensureNonNullable<AtlasContext2D>(
            _canvas.getContext('2d', <String, Object?>{'willReadFrequently': true}),
          ),
        _slabW = math.min(
            options?.slabW ??
                (64 <<
                    math.max(
                        _jsFloor(windowCarrier(getActiveWindow()).devicePixelRatio) - 1,
                        0)),
            _canvas.width),
        _slabH = 0,
        _slabsPerRow = 0,
        _slabsPerColumn = 0 {
    // Dart initializer lists cannot reference sibling instance fields, so the
    // dependent fields are assigned here, carrying over the exact TS expressions.
    if (options != null && options.slabH != null) {
      _slabH = math.min(options.slabH!, _canvas.height);
    } else {
      _slabH = math.min(_slabW, _canvas.height);
    }
    _slabsPerRow = _jsFloor(_canvas.width / _slabW);
    _slabsPerColumn = _jsFloor(_canvas.height / _slabH);
  }

  @override
  ITextureAtlasPageGlyph? allocate(IRasterizedGlyph rasterizedGlyph) {
    // Find ideal slab, creating it if there is none suitable
    final num glyphWidth = rasterizedGlyph.boundingBox.right -
        rasterizedGlyph.boundingBox.left +
        1;
    final num glyphHeight = rasterizedGlyph.boundingBox.bottom -
        rasterizedGlyph.boundingBox.top +
        1;

    // The glyph does not fit into the atlas page, glyphs should never be this large in practice
    if (glyphWidth > _canvas.width || glyphHeight > _canvas.height) {
      throw BugIndicatingError('Glyph is too large for the atlas page');
    }

    // The glyph does not fit into a slab
    if (glyphWidth > _slabW || glyphHeight > _slabH) {
      // Only if this is the allocator's first glyph, resize the slab size to fit the glyph.
      if (_allocatedGlyphs.isNotEmpty) {
        return null;
      }
      // Find the largest power of 2 devisor that the glyph fits into.
      num sizeCandidate = _canvas.width;
      while (glyphWidth < sizeCandidate / 2 && glyphHeight < sizeCandidate / 2) {
        sizeCandidate /= 2;
      }
      _slabW = sizeCandidate;
      _slabH = sizeCandidate;
      _slabsPerRow = _jsFloor(_canvas.width / _slabW);
      _slabsPerColumn = _jsFloor(_canvas.height / _slabH);
    }

    // Exact number only (desiredSlabSize = { w: glyphWidth, h: glyphHeight })
    final num desiredW = glyphWidth;
    final num desiredH = glyphHeight;

    // Get any existing slab
    ITextureAtlasSlab? slab = _activeSlabsByDims.get(<Object>[desiredW, desiredH]);

    // Check if the slab is full
    if (slab != null) {
      final num glyphsPerSlab = _jsFloor(_slabW / slab.entryW) *
          _jsFloor(_slabH / slab.entryH);
      if (slab.count >= glyphsPerSlab) {
        slab = null;
      }
    }

    num? dx;
    num? dy;

    // Search for suitable space in unused rectangles
    if (slab == null) {
      // Only check availability for the smallest side
      if (glyphWidth < glyphHeight) {
        final List<ITextureAtlasSlabUnusedRect>? openRegions =
            _openRegionsByWidth[glyphWidth];
        if (openRegions != null && openRegions.isNotEmpty) {
          for (int i = openRegions.length - 1; i >= 0; i--) {
            final ITextureAtlasSlabUnusedRect r = openRegions[i];
            if (r.w >= glyphWidth && r.h >= glyphHeight) {
              dx = r.x;
              dy = r.y;
              if (glyphWidth < r.w) {
                _unusedRects.add(ITextureAtlasSlabUnusedRect(
                    r.x + glyphWidth, r.y, r.w - glyphWidth, glyphHeight));
              }
              r.y += glyphHeight;
              r.h -= glyphHeight;
              if (r.h == 0) {
                if (i == openRegions.length - 1) {
                  openRegions.removeLast();
                } else {
                  _unusedRects.removeAt(i);
                }
              }
              break;
            }
          }
        }
      } else {
        final List<ITextureAtlasSlabUnusedRect>? openRegions =
            _openRegionsByHeight[glyphHeight];
        if (openRegions != null && openRegions.isNotEmpty) {
          for (int i = openRegions.length - 1; i >= 0; i--) {
            final ITextureAtlasSlabUnusedRect r = openRegions[i];
            if (r.w >= glyphWidth && r.h >= glyphHeight) {
              dx = r.x;
              dy = r.y;
              if (glyphHeight < r.h) {
                _unusedRects.add(ITextureAtlasSlabUnusedRect(
                    r.x, r.y + glyphHeight, glyphWidth, r.h - glyphHeight));
              }
              r.x += glyphWidth;
              r.w -= glyphWidth;
              // 1:1: source checks `r.h === 0` here even though width was changed.
              if (r.h == 0) {
                if (i == openRegions.length - 1) {
                  openRegions.removeLast();
                } else {
                  _unusedRects.removeAt(i);
                }
              }
              break;
            }
          }
        }
      }
    }

    // Create a new slab
    if (dx == null || dy == null) {
      if (slab == null) {
        if (_slabs.length >= _slabsPerRow * _slabsPerColumn) {
          return null;
        }

        slab = ITextureAtlasSlab(
            _jsFloor(_slabs.length % _slabsPerRow) * _slabW,
            _jsFloor(_slabs.length / _slabsPerRow) * _slabH,
            desiredH,
            desiredW,
            0);

        // Track unused regions to use for small glyphs
        final num unusedW = _slabW % slab.entryW;
        final num unusedH = _slabH % slab.entryH;
        if (unusedW != 0) {
          _addEntryToMapArray(_openRegionsByWidth, unusedW,
              ITextureAtlasSlabUnusedRect(slab.x + _slabW - unusedW, slab.y, unusedW,
                  _slabH - (unusedH != 0 ? unusedH : 0)));
        }
        if (unusedH != 0) {
          _addEntryToMapArray(_openRegionsByHeight, unusedH,
              ITextureAtlasSlabUnusedRect(
                  slab.x, slab.y + _slabH - unusedH, _slabW, unusedH));
        }
        _slabs.add(slab);
        _activeSlabsByDims.set(slab, <Object>[desiredW, desiredH]);
      }

      final num glyphsPerRow = _jsFloor(_slabW / slab.entryW);
      dx = slab.x + _jsFloor(slab.count % glyphsPerRow) * slab.entryW;
      dy = slab.y + _jsFloor(slab.count / glyphsPerRow) * slab.entryH;

      // Shift current row
      slab.count++;
    }

    // Draw glyph
    _ctx.drawImage(
      rasterizedGlyph.source,
      rasterizedGlyph.boundingBox.left,
      rasterizedGlyph.boundingBox.top,
      glyphWidth,
      glyphHeight,
      dx!,
      dy!,
      glyphWidth,
      glyphHeight,
    );

    // Create glyph object
    final ITextureAtlasPageGlyph glyph = TextureAtlasPageGlyph(
      pageIndex: _textureIndex,
      glyphIndex: _nextIndex++,
      x: dx!,
      y: dy!,
      w: glyphWidth,
      h: glyphHeight,
      originOffsetX: rasterizedGlyph.originOffset.x,
      originOffsetY: rasterizedGlyph.originOffset.y,
      fontBoundingBoxAscent: rasterizedGlyph.fontBoundingBoxAscent,
      fontBoundingBoxDescent: rasterizedGlyph.fontBoundingBoxDescent,
    );

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

    final num slabW =
        64 << (_jsFloor(windowCarrier(getActiveWindow()).devicePixelRatio) - 1);
    final num slabH = slabW;

    // Draw wasted underneath glyphs first
    for (final ITextureAtlasSlab slab in _slabs) {
      num x = 0;
      num y = 0;
      for (int i = 0; i < slab.count; i++) {
        if (x + slab.entryW > slabW) {
          x = 0;
          y += slab.entryH;
        }
        ctx.fillStyle = UsagePreviewColors.Wasted;
        ctx.fillRect(slab.x + x, slab.y + y, slab.entryW, slab.entryH);
        x += slab.entryW;
      }
    }

    // Draw glyphs
    for (final ITextureAtlasPageGlyph g in _allocatedGlyphs) {
      ctx.fillStyle = UsagePreviewColors.Used;
      ctx.fillRect(g.x, g.y, g.w, g.h);
    }

    // Draw unused space on side
    final List<ITextureAtlasSlabUnusedRect> unusedRegions = <ITextureAtlasSlabUnusedRect>[
      ..._openRegionsByWidth.values.expand((List<ITextureAtlasSlabUnusedRect> e) => e),
      ..._openRegionsByHeight.values.expand((List<ITextureAtlasSlabUnusedRect> e) => e),
    ];
    for (final ITextureAtlasSlabUnusedRect r in unusedRegions) {
      ctx.fillStyle = UsagePreviewColors.Restricted;
      ctx.fillRect(r.x, r.y, r.w, r.h);
    }

    // Overlay actual glyphs on top. 1:1 source calls
    // `ctx.drawImage(this._canvas, 0, 0)`; the carrier uses the full 9-arg form
    // with the source canvas as handle, destination (0,0) and full dimensions.
    ctx.globalAlpha = 0.5;
    ctx.drawImage(
        OffscreenCanvas(_canvas), 0, 0, w, h, 0, 0, w, h);
    ctx.globalAlpha = 1;

    return canvas.convertToBlob();
  }

  @override
  String getStats() {
    final int w = _canvas.width;
    final int h = _canvas.height;

    num slabEntryPixels = 0;
    num usedPixels = 0;
    num slabEdgePixels = 0;
    num wastedPixels = 0;
    num restrictedPixels = 0;
    final num totalPixels = w * h;
    final num slabW =
        64 << (_jsFloor(windowCarrier(getActiveWindow()).devicePixelRatio) - 1);
    final num slabH = slabW;

    // Draw wasted underneath glyphs first
    for (final ITextureAtlasSlab slab in _slabs) {
      num x = 0;
      num y = 0;
      for (int i = 0; i < slab.count; i++) {
        if (x + slab.entryW > slabW) {
          x = 0;
          y += slab.entryH;
        }
        slabEntryPixels += slab.entryW * slab.entryH;
        x += slab.entryW;
      }
      final num entriesPerRow = _jsFloor(slabW / slab.entryW);
      final num entriesPerCol = _jsFloor(slabH / slab.entryH);
      final num thisSlabPixels =
          slab.entryW * entriesPerRow * slab.entryH * entriesPerCol;
      slabEdgePixels += (slabW * slabH) - thisSlabPixels;
    }

    // Draw glyphs
    for (final ITextureAtlasPageGlyph g in _allocatedGlyphs) {
      usedPixels += g.w * g.h;
    }

    // Draw unused space on side
    final List<ITextureAtlasSlabUnusedRect> unusedRegions = <ITextureAtlasSlabUnusedRect>[
      ..._openRegionsByWidth.values.expand((List<ITextureAtlasSlabUnusedRect> e) => e),
      ..._openRegionsByHeight.values.expand((List<ITextureAtlasSlabUnusedRect> e) => e),
    ];
    for (final ITextureAtlasSlabUnusedRect r in unusedRegions) {
      restrictedPixels += r.w * r.h;
    }

    final num edgeUsedPixels = slabEdgePixels - restrictedPixels;
    wastedPixels = slabEntryPixels - (usedPixels - edgeUsedPixels);

    final num efficiency = usedPixels / (usedPixels + wastedPixels + restrictedPixels);

    return <String>[
      'page[$_textureIndex]:',
      '     Total: ${totalPixels}px (${w}x${h})',
      '      Used: ${usedPixels}px (${_jsPercent(usedPixels / totalPixels)}%)',
      '    Wasted: ${wastedPixels}px (${_jsPercent(wastedPixels / totalPixels)}%)',
      'Restricted: ${restrictedPixels}px (${_jsPercent(restrictedPixels / totalPixels)}%) (hard to allocate)',
      'Efficiency: ${efficiency == 1 ? '100' : _jsPercent(efficiency)}%',
      '     Slabs: ${_slabs.length} of ${_jsFloor(_canvas.width / slabW) * _jsFloor(_canvas.height / slabH)}',
    ].join('\n');
  }
}

/// Mirrors JS `Number.prototype.toFixed(2)` for finite numbers, including the
/// exact integer rendering (`100.00` rather than Dart's `100.00` in all cases).
String _jsPercent(num ratio) => (ratio * 100).toStringAsFixed(2);
