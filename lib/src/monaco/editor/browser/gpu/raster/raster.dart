// 1:1 port of vs/editor/browser/gpu/raster/raster.ts
//
// This file is type-only in the source (interfaces describing the glyph
// rasterizer contract). Dart has no DOM `TextMetrics` / `OffscreenCanvas`, so
// they are represented as carrier classes; the interface shapes are preserved
// as abstract classes.

/// The DOM `TextMetrics` surface used by [IGlyphRasterizer.getTextMetrics].
/// Only the fields relevant to a rasterizer contract are carried.
class TextMetrics {
  final num width;
  final num fontBoundingBoxAscent;
  final num fontBoundingBoxDescent;
  final num actualBoundingBoxAscent;
  final num actualBoundingBoxDescent;

  const TextMetrics({
    this.width = 0,
    this.fontBoundingBoxAscent = 0,
    this.fontBoundingBoxDescent = 0,
    this.actualBoundingBoxAscent = 0,
    this.actualBoundingBoxDescent = 0,
  });
}

/// The DOM `OffscreenCanvas` an [IRasterizedGlyph] was rasterized to. Dart has
/// no canvas; the embedder supplies an opaque handle.
class OffscreenCanvas {
  final Object handle;
  const OffscreenCanvas(this.handle);
}

/// 1:1: `export interface IGlyphRasterizer`
abstract class IGlyphRasterizer {
  /// A unique identifier for the rasterizer.
  int get id;

  /// A key identifying rendering properties inherent to this rasterizer.
  String get cacheKey;

  /// Rasterizes a glyph.
  ///
  /// [chars] can be a single character, a ligature, an emoji, etc.
  /// [tokenMetadata] is the token metadata (see `MetadataConsts`).
  /// [decorationStyleSetId] is the decoration style sheet id; zero means none.
  /// [colorMap] is a theme's color map.
  IRasterizedGlyph rasterizeGlyph(
    String chars,
    int tokenMetadata,
    int decorationStyleSetId,
    List<String> colorMap,
  );

  TextMetrics getTextMetrics(String text);
}

/// 1:1: `export interface IBoundingBox` — a simple bounding box in a 2D plane.
abstract class IBoundingBox {
  /// The left x coordinate (inclusive).
  num get left;

  /// The top y coordinate (inclusive).
  num get top;

  /// The right x coordinate (inclusive).
  num get right;

  /// The bottom y coordinate (inclusive).
  num get bottom;
}

/// 1:1: `export interface IRasterizedGlyph` — a glyph rasterized to a canvas.
abstract class IRasterizedGlyph {
  /// The source canvas the glyph was rasterized to.
  OffscreenCanvas get source;

  /// The bounding box of the glyph within [source].
  IBoundingBox get boundingBox;

  /// The offset to the glyph's origin (where it should be drawn to).
  OriginOffset get originOffset;

  /// Distance from the baseline to the top of the highest bounding rectangle.
  num get fontBoundingBoxAscent;

  /// Distance from the baseline to the bottom of the bounding rectangle.
  num get fontBoundingBoxDescent;
}

/// 1:1: `{ x: number; y: number }` used by [IRasterizedGlyph.originOffset].
class OriginOffset {
  final num x;
  final num y;
  const OriginOffset({required this.x, required this.y});
}

/// Default value carrier implementing [IBoundingBox].
class BoundingBox implements IBoundingBox {
  @override
  final num left;
  @override
  final num top;
  @override
  final num right;
  @override
  final num bottom;

  const BoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}

/// Default value carrier implementing [IRasterizedGlyph].
class RasterizedGlyph implements IRasterizedGlyph {
  @override
  final OffscreenCanvas source;
  @override
  final IBoundingBox boundingBox;
  @override
  final OriginOffset originOffset;
  @override
  final num fontBoundingBoxAscent;
  @override
  final num fontBoundingBoxDescent;

  const RasterizedGlyph({
    required this.source,
    required this.boundingBox,
    required this.originOffset,
    required this.fontBoundingBoxAscent,
    required this.fontBoundingBoxDescent,
  });
}
