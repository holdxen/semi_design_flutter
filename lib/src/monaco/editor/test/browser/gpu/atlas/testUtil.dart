// 1:1 port of vscode/src/vs/editor/test/browser/gpu/atlas/testUtil.ts
//
// The source reads a DOM OffscreenCanvas 2D context. In Dart the canvas is an
// opaque carrier whose `getContext('2d')` is called dynamically (the same
// carrier convention used by the atlas/raster ports).

import '../../../../../base/common/types.dart' show isNumber;
import '../../../../browser/gpu/atlas/atlas.dart' show ITextureAtlasPageGlyph;
import '../../../../browser/gpu/atlas/textureAtlas.dart' show TextureAtlas;
import '../../../../browser/gpu/gpuUtils.dart' show ensureNonNullable;

void _fail(String message) => throw StateError(message);
void _ok(bool value) {
  if (!value) _fail('assertion failed');
}

/// 1:1: `export function assertIsValidGlyph(glyph, atlasOrSource)`
void assertIsValidGlyph(
    ITextureAtlasPageGlyph? glyph, Object atlasOrSource) {
  if (glyph == null) {
    throw StateError('glyph is undefined');
  }
  final bool isAtlas = atlasOrSource is TextureAtlas;
  final TextureAtlas? atlas = isAtlas ? atlasOrSource : null;
  final dynamic canvasSource = isAtlas ? null : atlasOrSource;
  final num pageW = isAtlas
      ? atlas!.pageSize
      : canvasSource.width as num;
  // Source intentionally uses `.width` for both dimensions on the canvas branch.
  final num pageH = isAtlas
      ? atlas!.pageSize
      : canvasSource.width as num;
  final dynamic source = isAtlas
      ? atlas!.pages[glyph.pageIndex].source.handle
      : atlasOrSource;

  // (x,y) are valid coordinates
  _ok(isNumber(glyph.x));
  _ok(glyph.x >= 0);
  _ok(glyph.x < pageW);
  _ok(isNumber(glyph.y));
  _ok(glyph.y >= 0);
  _ok(glyph.y < pageH);

  // (w,h) are valid dimensions
  _ok(isNumber(glyph.w));
  _ok(glyph.w > 0);
  _ok(glyph.w <= pageW);
  _ok(isNumber(glyph.h));
  _ok(glyph.h > 0);
  _ok(glyph.h <= pageH);

  // (originOffsetX, originOffsetY) are valid offsets
  _ok(isNumber(glyph.originOffsetX));
  _ok(isNumber(glyph.originOffsetY));

  // (x,y) + (w,h) are within the bounds of the atlas
  _ok(glyph.x + glyph.w <= pageW);
  _ok(glyph.y + glyph.h <= pageH);

  // Each of the glyph's outer pixel edges contains at least 1 non-transparent
  // pixel.
  final dynamic ctx = ensureNonNullable(source.getContext('2d'));
  final List<dynamic> edges = <dynamic>[
    ctx.getImageData(glyph.x, glyph.y, glyph.w, 1).data,
    ctx.getImageData(glyph.x, glyph.y + glyph.h - 1, glyph.w, 1).data,
    ctx.getImageData(glyph.x, glyph.y, 1, glyph.h).data,
    ctx.getImageData(glyph.x + glyph.w - 1, glyph.y, 1, glyph.h).data,
  ];
  for (final dynamic edge in edges) {
    bool hasOpaquePixel = false;
    for (final dynamic color in edge as Iterable<dynamic>) {
      if ((color as int) & 0xFF != 0) {
        hasOpaquePixel = true;
        break;
      }
    }
    _ok(hasOpaquePixel);
  }
}
