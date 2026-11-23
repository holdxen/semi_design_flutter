// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/gpu/raster/glyphRasterizer.ts
// Translated 1:1 from TypeScript. DOM is expressed via injectable carriers:
//   - `OffscreenCanvas` / `OffscreenCanvasRenderingContext2D` -> interfaces
//     (`GlyphCanvas`, `GlyphContext2D`) with a factory provider.
//   - `ImageData` -> `GlyphImageData` (width/height/data).
//   - `@memoize get cacheKey` -> lazy cached field (same observable semantics).
//   - `isMacintosh` -> injectable `glyphRasterizerIsMacintosh` override.
//   - `DecorationStyleCache.getStyleSet` -> injected via constructor (carrier).
// ---------------------------------------------------------------------------

import 'dart:typed_data' show Uint8List;

import '../../../../base/common/lifecycle.dart' show Disposable;
import '../../../../base/common/platform.dart' as platform show isMacintosh;
import '../../../common/core/stringBuilder.dart' show StringBuilder;
import '../../../common/encodedTokenAttributes.dart'
    show ColorId, FontStyle, TokenMetadata;
import '../css/decorationStyleCache.dart' show DecorationStyleCache, IDecorationStyleSet;
import '../gpuUtils.dart' show ensureNonNullable;
import 'raster.dart'
    show
        IBoundingBox,
        IGlyphRasterizer,
        IRasterizedGlyph,
        OffscreenCanvas,
        OriginOffset,
        TextMetrics;

/// 1:1: `ImageData` carrier.
class GlyphImageData {
  GlyphImageData(this.width, this.height, this.data);
  final int width;
  final int height;
  final Uint8List data;
}

/// 1:1: `OffscreenCanvasRenderingContext2D` surface consumed by the rasterizer.
abstract class GlyphContext2D {
  set textBaseline(String value);
  set fillStyle(String value);
  set font(String value);
  set globalAlpha(num value);
  void save();
  void restore();
  void fillRect(num x, num y, num w, num h);
  void clearRect(num x, num y, num w, num h);
  void fillText(String text, num x, num y);
  TextMetrics measureText(String text);
  GlyphImageData getImageData(int x, int y, int w, int h);
  void putImageData(GlyphImageData imageData, int x, int y);
}

/// 1:1: `OffscreenCanvas` surface consumed by the rasterizer.
abstract class GlyphCanvas {
  int get width;
  set width(int value);
  int get height;
  set height(int value);
  GlyphContext2D getContext(String type, [Map<String, Object?>? options]);
}

/// Injectable canvas constructor: `new OffscreenCanvas(w, h)`.
GlyphCanvas Function(int width, int height) createGlyphCanvas =
    (int width, int height) => throw UnsupportedError(
          'createGlyphCanvas must be supplied by the embedding platform',
        );

/// 1:1: `allow isMacintosh` override for tests.
bool glyphRasterizerIsMacintosh = platform.isMacintosh;

int _nextId = 0;

/// 1:1: mutable work glyph (reused; only safe for synchronous access).
class _WorkGlyph implements IRasterizedGlyph {
  @override
  OffscreenCanvas source = OffscreenCanvas(_placeholderHandle);
  static final Object _placeholderHandle = Object();
  @override
  IBoundingBox boundingBox = _BoundingBox();
  @override
  OriginOffset originOffset = const OriginOffset(x: 0, y: 0);
  @override
  num fontBoundingBoxAscent = 0;
  @override
  num fontBoundingBoxDescent = 0;
}

class _BoundingBox implements IBoundingBox {
  @override
  num left = 0;
  @override
  num bottom = 0;
  @override
  num right = 0;
  @override
  num top = 0;
}

/// 1:1: `export class GlyphRasterizer extends Disposable implements IGlyphRasterizer`
class GlyphRasterizer extends Disposable implements IGlyphRasterizer {
  GlyphRasterizer(
    this.fontSize,
    this.fontFamily,
    this.devicePixelRatio,
    this._decorationStyleCache,
  ) : _antiAliasing = glyphRasterizerIsMacintosh ? 'greyscale' : 'subpixel' {
    final int devicePixelFontSize =
        (fontSize * devicePixelRatio).ceil();
    _canvas = createGlyphCanvas(devicePixelFontSize * 3, devicePixelFontSize * 3);
    _ctx = ensureNonNullable(_canvas.getContext('2d', <String, Object?>{
      'willReadFrequently': true,
      'alpha': _antiAliasing == 'greyscale',
    }));
    _ctx.textBaseline = 'top';
    _ctx.fillStyle = '#FFFFFF';
    _ctx.font = '${devicePixelFontSize}px $fontFamily';
    _textMetrics = _ctx.measureText('A');
  }

  @override
  final int id = _nextId++;

  final num fontSize;
  final String fontFamily;
  final num devicePixelRatio;
  final DecorationStyleCache _decorationStyleCache;

  String? _cacheKey;
  @override
  String get cacheKey => _cacheKey ??= '${fontFamily}_${fontSize}px';

  late final GlyphCanvas _canvas;
  late final GlyphContext2D _ctx;
  late final TextMetrics _textMetrics;

  final _WorkGlyph _workGlyph = _WorkGlyph();
  final Map<String, Object?> _workGlyphConfig = <String, Object?>{
    'chars': null,
    'tokenMetadata': 0,
    'decorationStyleSetId': 0,
  };

  final String _antiAliasing;

  /// 1:1: `rasterizeGlyph(chars, tokenMetadata, decorationStyleSetId, colorMap)`
  @override
  IRasterizedGlyph rasterizeGlyph(
    String chars,
    int tokenMetadata,
    int decorationStyleSetId,
    List<String> colorMap,
  ) {
    if (chars.isEmpty) {
      return _EmptyGlyph(_canvas);
    }
    if (_workGlyphConfig['chars'] == chars &&
        _workGlyphConfig['tokenMetadata'] == tokenMetadata &&
        _workGlyphConfig['decorationStyleSetId'] == decorationStyleSetId) {
      return _workGlyph;
    }
    _workGlyphConfig['chars'] = chars;
    _workGlyphConfig['tokenMetadata'] = tokenMetadata;
    _workGlyphConfig['decorationStyleSetId'] = decorationStyleSetId;
    return _rasterizeGlyph(chars, tokenMetadata, decorationStyleSetId, colorMap);
  }

  /// 1:1: `_rasterizeGlyph(...)`
  IRasterizedGlyph _rasterizeGlyph(
    String chars,
    int tokenMetadata,
    int decorationStyleSetId,
    List<String> colorMap,
  ) {
    final int devicePixelFontSize = (fontSize * devicePixelRatio).ceil();
    final int canvasDim = devicePixelFontSize * 3;
    if (_canvas.width != canvasDim) {
      _canvas.width = canvasDim;
      _canvas.height = canvasDim;
    }

    _ctx.save();

    // Sub-pixel x offset from the fractional part of the metadata low nibble.
    final num subPixelXOffset = (tokenMetadata & 15) / 10;

    final int bgId = TokenMetadata.getBackground(tokenMetadata);
    final String bg = bgId < colorMap.length
        ? (colorMap[bgId])
        : colorMap[ColorId.defaultBackground];

    final IDecorationStyleSet? decorationStyleSet =
        _decorationStyleCache.getStyleSet(decorationStyleSetId);

    if (_antiAliasing == 'subpixel') {
      _ctx.fillStyle = bg;
      _ctx.fillRect(0, 0, _canvas.width, _canvas.height);
    } else {
      _ctx.clearRect(0, 0, _canvas.width, _canvas.height);
    }

    final StringBuilder fontSb = StringBuilder(200);
    final int fontStyle = TokenMetadata.getFontStyle(tokenMetadata);
    if ((fontStyle & FontStyle.italic) != 0) {
      fontSb.appendString('italic ');
    }
    final bool? decoBold = decorationStyleSet?.bold;
    if (decoBold != null) {
      if (decoBold) {
        fontSb.appendString('bold ');
      }
    } else if ((fontStyle & FontStyle.bold) != 0) {
      fontSb.appendString('bold ');
    }
    fontSb.appendString('${devicePixelFontSize}px $fontFamily');
    _ctx.font = fontSb.build();

    final num originX = devicePixelFontSize;
    final num originY = devicePixelFontSize;

    final int? decoColor = decorationStyleSet?.color;
    if (decoColor != null) {
      _ctx.fillStyle = '#${decoColor.toRadixString(16).padLeft(8, '0')}';
    } else {
      final int fg = TokenMetadata.getForeground(tokenMetadata);
      _ctx.fillStyle = fg < colorMap.length ? colorMap[fg] : '';
    }

    final num? decoOpacity = decorationStyleSet?.opacity;
    if (decoOpacity != null) {
      _ctx.globalAlpha = decoOpacity;
    }

    _ctx.textBaseline = 'top';
    _ctx.fillText(chars, originX + subPixelXOffset, originY);

    if (decorationStyleSet?.strikethrough ?? false) {
      final num strikethroughY =
          (originY - _textMetrics.alphabeticBaseline * 0.65).round();
      final num lineWidth =
          decorationStyleSet?.strikethroughThickness != null
              ? (decorationStyleSet!.strikethroughThickness! * devicePixelRatio).round()
              : (devicePixelFontSize / 10).floor() < 1
                  ? 1
                  : (devicePixelFontSize / 10).floor();
      final int? strikeColor = decorationStyleSet?.strikethroughColor;
      if (strikeColor != null) {
        _ctx.fillStyle = '#${strikeColor.toRadixString(16).padLeft(8, '0')}';
      }
      _ctx.fillRect(
        originX,
        strikethroughY - (lineWidth / 2).floor(),
        _textMetrics.width.ceil(),
        lineWidth,
      );
    }

    _ctx.restore();

    final GlyphImageData imageData =
        _ctx.getImageData(0, 0, _canvas.width, _canvas.height);
    if (_antiAliasing == 'subpixel') {
      final int bgR = int.parse(bg.substring(1, 3), radix: 16);
      final int bgG = int.parse(bg.substring(3, 5), radix: 16);
      final int bgB = int.parse(bg.substring(5, 7), radix: 16);
      _clearColor(imageData, bgR, bgG, bgB);
      _ctx.putImageData(imageData, 0, 0);
    }

    _findGlyphBoundingBox(imageData, _workGlyph.boundingBox as _BoundingBox);

    _workGlyph.source = OffscreenCanvas(_canvas);
    _workGlyph.originOffset = OriginOffset(
      x: _workGlyph.boundingBox.left - originX,
      y: _workGlyph.boundingBox.top - originY,
    );
    _workGlyph.fontBoundingBoxAscent = _textMetrics.fontBoundingBoxAscent;
    _workGlyph.fontBoundingBoxDescent = _textMetrics.fontBoundingBoxDescent;

    return _workGlyph;
  }

  /// 1:1: `_clearColor(imageData, r, g, b)`
  void _clearColor(GlyphImageData imageData, int r, int g, int b) {
    for (int offset = 0; offset < imageData.data.length; offset += 4) {
      if (imageData.data[offset] == r &&
          imageData.data[offset + 1] == g &&
          imageData.data[offset + 2] == b) {
        imageData.data[offset + 3] = 0;
      }
    }
  }

  /// 1:1: `_findGlyphBoundingBox(imageData, outBoundingBox)`
  void _findGlyphBoundingBox(GlyphImageData imageData, _BoundingBox out) {
    final int height = _canvas.height;
    final int width = _canvas.width;
    bool found = false;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int alphaOffset = y * width * 4 + x * 4 + 3;
        if (imageData.data[alphaOffset] != 0) {
          out.top = y;
          found = true;
          break;
        }
      }
      if (found) {
        break;
      }
    }
    out.left = 0;
    found = false;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int alphaOffset = y * width * 4 + x * 4 + 3;
        if (imageData.data[alphaOffset] != 0) {
          out.left = x;
          found = true;
          break;
        }
      }
      if (found) {
        break;
      }
    }
    out.right = width;
    found = false;
    for (int x = width - 1; x >= out.left; x--) {
      for (int y = 0; y < height; y++) {
        final int alphaOffset = y * width * 4 + x * 4 + 3;
        if (imageData.data[alphaOffset] != 0) {
          out.right = x;
          found = true;
          break;
        }
      }
      if (found) {
        break;
      }
    }
    out.bottom = out.top;
    found = false;
    for (int y = height - 1; y >= 0; y--) {
      for (int x = 0; x < width; x++) {
        final int alphaOffset = y * width * 4 + x * 4 + 3;
        if (imageData.data[alphaOffset] != 0) {
          out.bottom = y;
          found = true;
          break;
        }
      }
      if (found) {
        break;
      }
    }
  }

  /// 1:1: `getTextMetrics(text)`
  @override
  TextMetrics getTextMetrics(String text) => _ctx.measureText(text);
}

/// 1:1: the empty-chars glyph (canvas source, inverted bounding box).
class _EmptyGlyph implements IRasterizedGlyph {
  _EmptyGlyph(this.canvas);
  final GlyphCanvas canvas;
  @override
  OffscreenCanvas get source => OffscreenCanvas(canvas);
  @override
  IBoundingBox get boundingBox => const _ConstBoundingBox();
  @override
  OriginOffset get originOffset => const OriginOffset(x: 0, y: 0);
  @override
  num get fontBoundingBoxAscent => 0;
  @override
  num get fontBoundingBoxDescent => 0;
}

class _ConstBoundingBox implements IBoundingBox {
  const _ConstBoundingBox();
  @override
  num get top => 0;
  @override
  num get left => 0;
  @override
  num get bottom => -1;
  @override
  num get right => -1;
}
