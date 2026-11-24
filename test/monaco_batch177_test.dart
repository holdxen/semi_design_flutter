// Truth-driven tests for batch177: editor/browser/gpu/atlas/textureAtlasPage.ts
// Truth source: tool/ts2dart/batch177_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/atlas.dart' as atlas;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/textureAtlasPage.dart' as page;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/textureAtlasShelfAllocator.dart' as shelf;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/raster/raster.dart' as raster;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart' as ts;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch177_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _FakeContext2D implements shelf.AtlasContext2D {
  @override
  set fillStyle(String value) {}
  @override
  set globalAlpha(num value) {}
  @override
  void drawImage(raster.OffscreenCanvas source, num sx, num sy, num sw, num sh,
      num dx, num dy, num dw, num dh) {}
  @override
  void fillRect(num x, num y, num w, num h) {}
}

class _FakeAllocator implements atlas.ITextureAtlasAllocator {
  _FakeAllocator(this.canvas, this.textureIndex);
  final shelf.AtlasCanvas canvas;
  final int textureIndex;
  final List<atlas.ITextureAtlasPageGlyph> allocations =
      <atlas.ITextureAtlasPageGlyph>[];
  bool fail = false;

  @override
  atlas.ITextureAtlasPageGlyph? allocate(raster.IRasterizedGlyph glyph) {
    if (fail) return null;
    final raster.IBoundingBox box = glyph.boundingBox;
    final atlas.TextureAtlasPageGlyph result = atlas.TextureAtlasPageGlyph(
      pageIndex: textureIndex,
      glyphIndex: allocations.length,
      x: allocations.length * 11,
      y: (allocations.length % 3) * 13,
      w: box.right - box.left,
      h: box.bottom - box.top,
      originOffsetX: glyph.originOffset.x,
      originOffsetY: glyph.originOffset.y,
      fontBoundingBoxAscent: glyph.fontBoundingBoxAscent,
      fontBoundingBoxDescent: glyph.fontBoundingBoxDescent,
    );
    allocations.add(result);
    return result;
  }

  @override
  Future<atlas.Blob> getUsagePreview() async =>
      atlas.Blob(<String, Object?>{'tag': 'preview', 'index': textureIndex});

  @override
  String getStats() => 'stats:$textureIndex:${allocations.length}';
}

class _FakeRasterizedGlyph implements raster.IRasterizedGlyph {
  _FakeRasterizedGlyph(this.box, this.origin, this.ascent, this.descent);
  final raster.IBoundingBox box;
  @override
  raster.IBoundingBox get boundingBox => box;
  final raster.OriginOffset origin;
  @override
  raster.OriginOffset get originOffset => origin;
  final num ascent;
  @override
  num get fontBoundingBoxAscent => ascent;
  final num descent;
  @override
  num get fontBoundingBoxDescent => descent;
  @override
  raster.OffscreenCanvas get source => raster.OffscreenCanvas(Object());
}

class _FakeRasterizer implements raster.IGlyphRasterizer {
  _FakeRasterizer(this.id, this.cacheKey, this.box);
  @override
  final int id;
  @override
  final String cacheKey;
  final raster.IBoundingBox box;
  List<String>? lastColorMap;

  @override
  raster.IRasterizedGlyph rasterizeGlyph(String chars, int tokenMetadata,
      int decorationStyleSetId, List<String> colorMap) {
    lastColorMap = colorMap;
    return _FakeRasterizedGlyph(box, const raster.OriginOffset(x: 1, y: 2), 8, -2);
  }

  @override
  raster.TextMetrics getTextMetrics(String text) => const raster.TextMetrics();
}

class _FakeColorTheme implements ts.IColorTheme {
  _FakeColorTheme(this.tokens);
  @override
  List<String> get tokenColorMap => tokens;
  final List<String> tokens;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeThemeService implements ts.IThemeServiceType {
  @override
  ts.IColorTheme getColorTheme() => _FakeColorTheme(<String>['a', 'b']);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeLog implements log.ILogServiceType {
  int level = log.LogLevel.Info;
  final List<String> messages = <String>[];
  @override
  int getLevel() => level;
  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) =>
      messages.add(message);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final shelf.AtlasCanvasFactory _originalFactory = shelf.atlasCanvasFactory;
final List<shelf.AtlasCanvas> _createdCanvases = <shelf.AtlasCanvas>[];
final List<_FakeAllocator> _allocators = <_FakeAllocator>[];

shelf.AtlasCanvas _factory(int w, int h) {
  final shelf.AtlasCanvas canvas = shelf.AtlasCanvas(
    width: w,
    height: h,
    getContext: (_, [__]) => _FakeContext2D(),
    convertToBlob: () async => atlas.Blob(Object()),
  );
  _createdCanvases.add(canvas);
  return canvas;
}

_FakeAllocator _customAllocator(shelf.AtlasCanvas canvas, int textureIndex) {
  final _FakeAllocator allocator = _FakeAllocator(canvas, textureIndex);
  _allocators.add(allocator);
  return allocator;
}

void main() {
  setUp(() {
    _createdCanvases.clear();
    _allocators.clear();
    shelf.atlasCanvasFactory = _factory;
  });
  tearDown(() => shelf.atlasCanvasFactory = _originalFactory);

  group('TextureAtlasPage (truth-driven)', () {
    test('exports and constructor variants', () {
      expect(truth['exports'], <dynamic>['TextureAtlasPage']);
      final Map<String, dynamic> e =
          truth['shelfCtor'] as Map<String, dynamic>;
      final _FakeThemeService themeService = _FakeThemeService();
      final log.ILogServiceType logger = _FakeLog();
      final page.TextureAtlasPage shelfPage = page.TextureAtlasPage(
          0, 128, page.AllocatorTypes.shelf, logger, themeService);
      final shelf.AtlasCanvas canvas =
          shelfPage.source.handle as shelf.AtlasCanvas;
      expect(<int>[canvas.width, canvas.height], e['canvas']);
      expect(shelfPage.version, e['version']);
      expect(<num>[
        shelfPage.usedArea.left,
        shelfPage.usedArea.top,
        shelfPage.usedArea.right,
        shelfPage.usedArea.bottom,
      ], <num>[
        (e['usedArea'] as Map<String, dynamic>)['left'] as num,
        (e['usedArea'] as Map<String, dynamic>)['top'] as num,
        (e['usedArea'] as Map<String, dynamic>)['right'] as num,
        (e['usedArea'] as Map<String, dynamic>)['bottom'] as num,
      ]);
      expect(page.TextureAtlasPage.maximumGlyphCount,
          e['maximumGlyphCount']);

      final Map<String, dynamic> s = truth['slabCtor'] as Map<String, dynamic>;
      final page.TextureAtlasPage slabPage = page.TextureAtlasPage(
          3, 64, page.AllocatorTypes.slab, logger, themeService);
      final shelf.AtlasCanvas slabCanvas =
          slabPage.source.handle as shelf.AtlasCanvas;
      expect(<int>[slabCanvas.width, slabCanvas.height], s['canvas']);

      final Map<String, dynamic> c = truth['customCtor'] as Map<String, dynamic>;
      final page.TextureAtlasPage customPage = page.TextureAtlasPage(
          9, 32, _customAllocator, logger, themeService);
      expect(
          _allocators
              .map((_FakeAllocator a) => <int>[a.canvas.width, a.textureIndex])
              .toList(),
          (c['calls'] as List<dynamic>)
              .map((dynamic l) => (l as List<dynamic>).cast<int>())
              .toList());
      expect(customPage.version, 0);
    });

    test('getGlyph caches, tracks version/used area and preserves order', () {
      final Map<String, dynamic> e = truth['getGlyph'] as Map<String, dynamic>;
      final page.TextureAtlasPage atlasPage = page.TextureAtlasPage(
          0, 256, _customAllocator, _FakeLog(), _FakeThemeService());
      final _FakeAllocator allocator = _allocators.single;
      final _FakeRasterizer rasA = _FakeRasterizer(
          1, 'keyA', const raster.BoundingBox(left: 0, top: 0, right: 7, bottom: 9));
      final _FakeRasterizer rasB = _FakeRasterizer(
          2, 'keyB', const raster.BoundingBox(left: 0, top: 0, right: 5, bottom: 4));

      final atlas.ITextureAtlasPageGlyph? first =
          atlasPage.getGlyph(rasA, 'a', 0, 0);
      final atlas.ITextureAtlasPageGlyph? cached =
          atlasPage.getGlyph(rasA, 'a', 0, 0);
      atlasPage.getGlyph(rasA, 'b', 0, 0);
      final atlas.ITextureAtlasPageGlyph? differentCacheKey =
          atlasPage.getGlyph(rasB, 'a', 0, 0);

      final Map<String, dynamic> expectedFirst =
          (e['first'] as Map<String, dynamic>);
      expect(<num?>[
        first!.x, first.y, first.w, first.h,
        first.originOffsetX, first.originOffsetY,
        first.fontBoundingBoxAscent, first.fontBoundingBoxDescent,
      ], <num?>[
        expectedFirst['x'] as num,
        expectedFirst['y'] as num,
        expectedFirst['w'] as num,
        expectedFirst['h'] as num,
        expectedFirst['originOffsetX'] as num,
        expectedFirst['originOffsetY'] as num,
        expectedFirst['fontBoundingBoxAscent'] as num,
        expectedFirst['fontBoundingBoxDescent'] as num,
      ]);
      expect(identical(first, cached), e['cachedIsSame']);
      expect(allocator.allocations.length, e['allocations']);
      expect(atlasPage.version, e['version']);
      expect(<num>[
        atlasPage.usedArea.right,
        atlasPage.usedArea.bottom,
      ], <num>[
        (e['usedArea'] as Map<String, dynamic>)['right'] as num,
        (e['usedArea'] as Map<String, dynamic>)['bottom'] as num,
      ]);
      expect(differentCacheKey!.glyphIndex,
          (e['differentCacheKey'] as Map<String, dynamic>)['glyphIndex']);
      expect(atlasPage.glyphs.map((atlas.ITextureAtlasPageGlyph g) => g.glyphIndex).toList(),
          e['glyphOrder']);
      expect(atlasPage.getStats(), e['stats']);
      expect(rasA.lastColorMap, <String>['a', 'b']);
    });

    test('allocation failure, trace, usage preview and dispose', () async {
      final Map<String, dynamic> e = truth['getGlyph'] as Map<String, dynamic>;
      final _FakeLog logger = _FakeLog();
      final page.TextureAtlasPage atlasPage = page.TextureAtlasPage(
          0, 256, _customAllocator, logger, _FakeThemeService());
      final _FakeAllocator allocator = _allocators.single;
      final _FakeRasterizer ras = _FakeRasterizer(
          1, 'keyA', const raster.BoundingBox(left: 0, top: 0, right: 7, bottom: 9));

      atlasPage.getGlyph(ras, 'a', 0, 0);
      atlasPage.getGlyph(ras, 'a', 0, 0);
      atlasPage.getGlyph(ras, 'b', 0, 0);
      final _FakeRasterizer rasB = _FakeRasterizer(
          2, 'keyB', const raster.BoundingBox(left: 0, top: 0, right: 5, bottom: 4));
      atlasPage.getGlyph(rasB, 'a', 0, 0);
      allocator.fail = true;
      expect(atlasPage.getGlyph(ras, 'c', 0, 0), isNull);
      expect(atlasPage.version, e['versionAfterFailure']);
      allocator.fail = false;
      logger.level = log.LogLevel.Trace;
      atlasPage.getGlyph(ras, 'd', 0, 0);
      final Map<String, dynamic> t = truth['trace'] as Map<String, dynamic>;
      expect(logger.messages.length, t['count']);
      expect(logger.messages.first, t['message']);

      final atlas.Blob preview = await atlasPage.getUsagePreview();
      expect((preview.handle as Map<String, Object?>)['tag'],
          (truth['preview'] as Map<String, dynamic>)['tag']);
      atlasPage.dispose();
      final shelf.AtlasCanvas canvas = atlasPage.source.handle as shelf.AtlasCanvas;
      expect(<int>[canvas.width, canvas.height], truth['afterDispose']);
    });

    test('hard cap of 5000 glyphs per page', () {
      final Map<String, dynamic> e = truth['maxGlyphs'] as Map<String, dynamic>;
      final page.TextureAtlasPage atlasPage = page.TextureAtlasPage(
          0, 512, _customAllocator, _FakeLog(), _FakeThemeService());
      final _FakeRasterizer ras = _FakeRasterizer(
          1, 'keyA', const raster.BoundingBox(left: 0, top: 0, right: 7, bottom: 9));
      for (int i = 0; i < (e['cap'] as int); i++) {
        atlasPage.getGlyph(ras, 'g$i', 0, 0);
      }
      expect(atlasPage.version, e['version']);
      expect(atlasPage.getGlyph(ras, 'overflow', 0, 0), isNull);
    });
  });
}
