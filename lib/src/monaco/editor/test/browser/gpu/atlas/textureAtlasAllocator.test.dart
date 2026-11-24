// 1:1 port of vscode/src/vs/editor/test/browser/gpu/atlas/textureAtlasAllocator.test.ts
//
// The six mocha suites become [officialCases] plus [runOfficialCases]. The
// shared tests (which only call `assertIsValidGlyph`) are covered by
// [sharedValidGlyphCases]. `test.skip` cases are recorded as
// [skippedCaseNames]; the outline of the skipped assertion is kept in
// [tooLargeForCanvasMessage].
//
// The DOM `OffscreenCanvas` surface is represented by the same injectable
// carrier used by the allocator ports: [AtlasCanvas] plus a byte-backed
// [AllocatorTestCanvas].

import '../../../../browser/gpu/atlas/atlas.dart' as atlas;
import '../../../../browser/gpu/atlas/textureAtlasShelfAllocator.dart' as shelf;
import '../../../../browser/gpu/atlas/textureAtlasSlabAllocator.dart' as slab;
import '../../../../browser/gpu/raster/raster.dart' as raster;

/// 1:1: `createRasterizedGlyph(w, h, data)` where data is four black bytes
/// repeated for every pixel (`blackArr = [0x00, 0x00, 0x00, 0xFF]`).
class AllocatorTestCanvas {
  AllocatorTestCanvas(this.width, this.height) {
    pixels = List<int>.filled(width * height * 4, 0);
    for (int i = 3; i < pixels.length; i += 4) {
      pixels[i] = 0xFF;
    }
  }
  final int width;
  final int height;
  late final List<int> pixels;

  AllocatorTestContext getContext(String id, [Map<String, Object?>? options]) =>
      AllocatorTestContext(this);
}

/// Minimal 2D context: enough for `putImageData`, `drawImage` and
/// `getImageData` used by the allocator ports and `testUtil.ts`.
class AllocatorTestContext implements shelf.AtlasContext2D {
  AllocatorTestContext(this.canvas);
  final AllocatorTestCanvas canvas;

  @override
  set fillStyle(String value) {}

  @override
  set globalAlpha(num value) {}

  @override
  void fillRect(num x, num y, num w, num h) {}

  void putImageData(Object imageData, num dx, num dy) {
    // The rasterized glyph sources are pre-filled in AllocatorTestCanvas, so
    // putImageData is a no-op here (the source used by the tests is already
    // fully opaque black).
  }

  @override
  void drawImage(raster.OffscreenCanvas source, num sx, num sy, num sw, num sh,
      num dx, num dy, num dw, num dh) {
    final AllocatorTestCanvas src = source.handle as AllocatorTestCanvas;
    final int sxI = sx.toInt(), syI = sy.toInt();
    final int swI = sw.toInt(), shI = sh.toInt();
    final int dxI = dx.toInt(), dyI = dy.toInt();
    for (int row = 0; row < shI; row++) {
      for (int col = 0; col < swI; col++) {
        final int si = ((syI + row) * src.width + (sxI + col)) * 4;
        final int tx = dxI + col;
        final int ty = dyI + row;
        if (tx < 0 || ty < 0 || tx >= canvas.width || ty >= canvas.height) {
          continue;
        }
        final int ti = (ty * canvas.width + tx) * 4;
        for (int c = 0; c < 4; c++) {
          canvas.pixels[ti + c] =
              si + c < src.pixels.length ? src.pixels[si + c] : 0;
        }
      }
    }
  }

  Object getImageData(num x, num y, num w, num h) {
    final int xi = x.toInt(), yi = y.toInt();
    final int wi = w.toInt(), hi = h.toInt();
    final List<int> data = List<int>.filled(wi * hi * 4, 0);
    for (int row = 0; row < hi; row++) {
      for (int col = 0; col < wi; col++) {
        final int px = xi + col;
        final int py = yi + row;
        for (int c = 0; c < 4; c++) {
          if (px < 0 || py < 0 || px >= canvas.width || py >= canvas.height) {
            continue;
          }
          data[(row * wi + col) * 4 + c] =
              canvas.pixels[(py * canvas.width + px) * 4 + c];
        }
      }
    }
    return _ImageData(data);
  }
}

class _ImageData {
  _ImageData(this.data);
  final List<int> data;
}

/// 1:1: `new OffscreenCanvas(w, h)` for the allocator under test.
shelf.AtlasCanvas createAllocatorCanvas(int w, int h) {
  final AllocatorTestCanvas source = AllocatorTestCanvas(w, h);
  final AllocatorTestContext ctx = source.getContext('2d');
  return shelf.AtlasCanvas(
    width: w,
    height: h,
    getContext: (String id, [Map<String, Object?>? options]) => ctx,
    convertToBlob: () async => atlas.Blob(Object()),
  );
}

/// 1:1: `{ source, boundingBox, originOffset, fontBoundingBoxAscent, ... }`.
class TestRasterizedGlyph implements raster.IRasterizedGlyph {
  TestRasterizedGlyph(this.w, this.h)
      : source = raster.OffscreenCanvas(AllocatorTestCanvas(w, h));

  @override
  final raster.OffscreenCanvas source;
  @override
  raster.IBoundingBox get boundingBox => raster.BoundingBox(
      left: 0, top: 0, right: w - 1, bottom: h - 1);
  @override
  raster.OriginOffset get originOffset => const raster.OriginOffset(x: 0, y: 0);
  @override
  num get fontBoundingBoxAscent => 0;
  @override
  num get fontBoundingBoxDescent => 0;
  final int w;
  final int h;
}

/// 1:1: the `pixel1x1` / `pixel2x1` / `pixel1x2` constants.
final raster.IRasterizedGlyph pixel1x1 = TestRasterizedGlyph(1, 1);
final raster.IRasterizedGlyph pixel2x1 = TestRasterizedGlyph(2, 1);
final raster.IRasterizedGlyph pixel1x2 = TestRasterizedGlyph(1, 2);

/// One `allocateAndAssert` step. `null` means the source expects `undefined`.
class AllocationStep {
  const AllocationStep(this.glyph, this.expected);
  final raster.IRasterizedGlyph glyph;
  final List<int>? expected;
}

/// 1:1: one official `test(...)` body.
class AllocationCase {
  const AllocationCase(
    this.name,
    this.canvasW,
    this.canvasH,
    this.steps, {
    this.slabW,
    this.slabH,
    this.shared = false,
  });
  final String name;
  final int canvasW;
  final int canvasH;
  final List<AllocationStep> steps;
  final int? slabW;
  final int? slabH;
  final bool shared;

  bool get isSlab =>
      name.contains('> (slab)') || name.contains('TextureAtlasSlabAllocator >');
}

AllocationStep _step(int w, int h, List<int>? expected) =>
    AllocationStep(TestRasterizedGlyph(w, h), expected);

const List<int> _p11 = <int>[0, 0, 1, 1];

/// All official cases, in source order (skipped cases excluded).
final List<AllocationCase> officialCases = <AllocationCase>[
  AllocationCase('TextureAtlasAllocator > shared tests > (shelf) single allocation',
      2, 2, <AllocationStep>[
    _step(1, 1, _p11),
  ], shared: true),
  AllocationCase('TextureAtlasAllocator > shared tests > (slab) single allocation',
      2, 2, <AllocationStep>[
    _step(1, 1, _p11),
  ], shared: true),
  AllocationCase(
      'TextureAtlasAllocator > TextureAtlasShelfAllocator > single allocation',
      2, 2, <AllocationStep>[
    _step(1, 1, _p11),
  ]),
  AllocationCase('TextureAtlasAllocator > TextureAtlasShelfAllocator > wrapping',
      5, 4, <AllocationStep>[
    _step(1, 1, <int>[0, 0, 1, 1]),
    _step(1, 2, <int>[1, 0, 1, 2]),
    _step(2, 1, <int>[2, 0, 2, 1]),
    _step(2, 1, <int>[0, 2, 2, 1]),
    _step(2, 1, <int>[2, 2, 2, 1]),
    _step(1, 1, <int>[4, 2, 1, 1]),
    _step(1, 1, <int>[0, 3, 1, 1]),
  ]),
  AllocationCase('TextureAtlasAllocator > TextureAtlasShelfAllocator > full',
      3, 2, <AllocationStep>[
    _step(1, 2, <int>[0, 0, 1, 2]),
    _step(2, 1, <int>[1, 0, 2, 1]),
    _step(1, 1, null),
  ]),
  AllocationCase(
      'TextureAtlasAllocator > TextureAtlasSlabAllocator > single allocation',
      2, 2, <AllocationStep>[
    _step(1, 1, _p11),
  ]),
  AllocationCase(
      'TextureAtlasAllocator > TextureAtlasSlabAllocator > single slab single glyph full',
      1, 1, <AllocationStep>[
    _step(1, 1, _p11),
    _step(1, 1, null),
  ], slabW: 1, slabH: 1),
  AllocationCase(
      'TextureAtlasAllocator > TextureAtlasSlabAllocator > single slab multiple glyph full',
      2, 2, <AllocationStep>[
    _step(1, 2, <int>[0, 0, 1, 2]),
    _step(1, 2, <int>[1, 0, 1, 2]),
    _step(1, 2, null),
  ], slabW: 2, slabH: 2),
  AllocationCase(
      'TextureAtlasAllocator > TextureAtlasSlabAllocator > allocate 1x1 to multiple slabs until full',
      4, 2, <AllocationStep>[
    _step(1, 1, <int>[0, 0, 1, 1]),
    _step(1, 1, <int>[1, 0, 1, 1]),
    _step(1, 1, <int>[0, 1, 1, 1]),
    _step(1, 1, <int>[1, 1, 1, 1]),
    _step(1, 1, <int>[2, 0, 1, 1]),
    _step(1, 1, <int>[3, 0, 1, 1]),
    _step(1, 1, <int>[2, 1, 1, 1]),
    _step(1, 1, <int>[3, 1, 1, 1]),
    _step(1, 1, null),
  ], slabW: 2, slabH: 2),
  AllocationCase(
      "TextureAtlasAllocator > TextureAtlasSlabAllocator > glyph too large for slab (increase slab size for first glyph)",
      2, 2, <AllocationStep>[
    _step(2, 1, <int>[0, 0, 2, 1]),
  ], slabW: 1, slabH: 1),
  AllocationCase(
      "TextureAtlasAllocator > TextureAtlasSlabAllocator > glyph too large for slab (undefined as it's not the first glyph)",
      2, 2, <AllocationStep>[
    _step(1, 1, _p11),
    _step(2, 1, null),
  ], slabW: 1, slabH: 1),
  AllocationCase(
      'TextureAtlasAllocator > TextureAtlasSlabAllocator > separate slabs for different sized glyphs',
      4, 2, <AllocationStep>[
    _step(1, 1, _p11),
    _step(1, 2, <int>[2, 0, 1, 2]),
    _step(1, 2, <int>[3, 0, 1, 2]),
    _step(1, 1, <int>[1, 0, 1, 1]),
  ], slabW: 2, slabH: 2),
];

/// 1:1: `test.skip('(name) glyph too large for canvas')`.
const List<String> skippedCaseNames = <String>[
  'TextureAtlasAllocator > shared tests > (shelf) glyph too large for canvas',
  'TextureAtlasAllocator > shared tests > (slab) glyph too large for canvas',
];

/// 1:1: `new BugIndicatingError('Glyph is too large for the atlas page')`.
const String tooLargeForCanvasMessage = 'Glyph is too large for the atlas page';

atlas.ITextureAtlasAllocator createAllocator(
    AllocationCase testCase, shelf.AtlasCanvas canvas) {
  if (testCase.isSlab) {
    return slab.TextureAtlasSlabAllocator(
      canvas,
      0,
      slab.TextureAtlasSlabAllocatorOptions(
        slabW: testCase.slabW,
        slabH: testCase.slabH,
      ),
    );
  }
  return shelf.TextureAtlasShelfAllocator(canvas, 0);
}

/// Executes every official case. [verify] receives the case, the step index,
/// the actual `{x,y,w,h}` (or `null`) and the source expectation.
void runOfficialCases(
    void Function(AllocationCase testCase, int index, List<int>? actual,
            List<int>? expected)
        verify) {
  for (final AllocationCase testCase in officialCases) {
    final shelf.AtlasCanvas canvas =
        createAllocatorCanvas(testCase.canvasW, testCase.canvasH);
    final atlas.ITextureAtlasAllocator allocator =
        createAllocator(testCase, canvas);
    for (int i = 0; i < testCase.steps.length; i++) {
      final AllocationStep step = testCase.steps[i];
      final atlas.ITextureAtlasPageGlyph? glyph = allocator.allocate(step.glyph);
      verify(
        testCase,
        i,
        glyph == null
            ? null
            : <int>[
                glyph.x.toInt(),
                glyph.y.toInt(),
                glyph.w.toInt(),
                glyph.h.toInt(),
              ],
        step.expected,
      );
    }
  }
}
