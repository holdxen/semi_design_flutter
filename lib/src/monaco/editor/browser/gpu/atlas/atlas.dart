// 1:1 port of vs/editor/browser/gpu/atlas/atlas.ts
//
// Type-only in the source (interfaces + const enum + type alias). Dart has no
// DOM `Blob` / `OffscreenCanvas` / `IterableIterator`, so they are bridged with
// carrier types; the interface shapes are preserved as abstract classes.

import '../../../../base/common/map.dart' show NKeyMap;
import '../raster/raster.dart' show IBoundingBox, IRasterizedGlyph, OffscreenCanvas;

/// The DOM `Blob` returned by usage previews. Dart has no DOM; the embedder
/// supplies an opaque handle.
class Blob {
  final Object handle;
  const Blob(this.handle);
}

/// 1:1: `export interface ITextureAtlasPageGlyph`
abstract class ITextureAtlasPageGlyph {
  /// The page index of the texture atlas page the glyph was drawn to.
  int get pageIndex;
  /// The index of the glyph in the texture atlas page.
  int get glyphIndex;
  /// The x coordinate of the glyph on the texture atlas page.
  num get x;
  /// The y coordinate of the glyph on the texture atlas page.
  num get y;
  /// The width of the glyph in pixels.
  num get w;
  /// The height of the glyph in pixels.
  num get h;
  /// The x offset from [x] of the glyph's origin.
  num get originOffsetX;
  /// The y offset from [y] of the glyph's origin.
  num get originOffsetY;
  /// Distance from the glyph baseline to the top of the highest bounding rect.
  num get fontBoundingBoxAscent;
  /// Distance from the glyph baseline to the bottom of the bounding rect.
  num get fontBoundingBoxDescent;
}

/// Default value carrier implementing [ITextureAtlasPageGlyph].
class TextureAtlasPageGlyph implements ITextureAtlasPageGlyph {
  @override
  final int pageIndex;
  @override
  final int glyphIndex;
  @override
  final num x;
  @override
  final num y;
  @override
  final num w;
  @override
  final num h;
  @override
  final num originOffsetX;
  @override
  final num originOffsetY;
  @override
  final num fontBoundingBoxAscent;
  @override
  final num fontBoundingBoxDescent;

  const TextureAtlasPageGlyph({
    required this.pageIndex,
    required this.glyphIndex,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.originOffsetX,
    required this.originOffsetY,
    required this.fontBoundingBoxAscent,
    required this.fontBoundingBoxDescent,
  });
}

/// 1:1: `export interface ITextureAtlasAllocator`
abstract class ITextureAtlasAllocator {
  /// Allocates a rasterized glyph to the canvas, returning its position, or
  /// null (source: `undefined`) if the glyph does not fit.
  ITextureAtlasPageGlyph? allocate(IRasterizedGlyph rasterizedGlyph);

  /// Gets a usage preview of the atlas for debugging purposes.
  Future<Blob> getUsagePreview();

  /// Gets statistics about the allocator's current state for debugging.
  String getStats();
}

/// 1:1: `export interface IReadableTextureAtlasPage`
abstract class IReadableTextureAtlasPage {
  /// A unique identifier for the current state of the page; increments
  /// whenever a glyph is drawn to the page.
  int get version;

  /// A bounding box representing the area currently in use.
  IBoundingBox get usedArea;

  /// An iterator over all glyphs drawn to the page, in draw order.
  /// Source: `IterableIterator<Readonly<ITextureAtlasPageGlyph>>`.
  Iterable<ITextureAtlasPageGlyph> get glyphs;

  /// The source canvas for the texture atlas page.
  OffscreenCanvas get source;

  /// Gets a usage preview of the atlas for debugging purposes.
  Future<Blob> getUsagePreview();

  /// Gets statistics about the allocator's current state for debugging.
  String getStats();
}

/// 1:1: `export const enum UsagePreviewColors`
class UsagePreviewColors {
  static const String Unused = '#808080';
  static const String Used = '#4040FF';
  static const String Wasted = '#FF0000';
  static const String Restricted = '#FF000088';
}

/// 1:1: `export type GlyphMap<T> = NKeyMap<T, [chars, tokenMetadata, decorationStyleSetId, rasterizerCacheKey]>`
///
/// The 4-element key tuple is carried as `List<Object>`.
typedef GlyphMap<T> = NKeyMap<T, List<Object>>;
