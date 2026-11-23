import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/css/decorationStyleCache.dart'
    show DecorationStyleCache;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/raster/glyphRasterizer.dart'
    as gr;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/raster/raster.dart'
    show TextMetrics;
import 'package:semi_design_flutter/src/monaco/editor/common/encodedTokenAttributes.dart'
    show ColorId;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/lineRange.test.dart'
    as lr;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/stringBuilder.test.dart'
    as sb;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/textLength.test.dart'
    as tl;

// ---- fake canvas -----------------------------------------------------------

class _FakeContext implements gr.GlyphContext2D {
  _FakeContext(this.metrics);

  final TextMetrics metrics;
  final List<String> fills = <String>[];
  final List<String> texts = <String>[];
  int saveCount = 0;
  int restoreCount = 0;
  int clearCount = 0;
  int putCount = 0;
  String? lastFont;
  String? lastFill;
  String? lastBaseline;
  num? lastAlpha;
  final List<List<Object?>> rects = <List<Object?>>[];

  @override
  set textBaseline(String v) => lastBaseline = v;
  @override
  set fillStyle(String v) {
    lastFill = v;
    fills.add(v);
  }

  @override
  set font(String v) => lastFont = v;
  @override
  set globalAlpha(num v) => lastAlpha = v;
  @override
  void save() => saveCount++;
  @override
  void restore() => restoreCount++;
  @override
  void fillRect(num x, num y, num w, num h) => rects.add(<Object?>[x, y, w, h]);
  @override
  void clearRect(num x, num y, num w, num h) {
    clearCount++;
  }

  @override
  void fillText(String text, num x, num y) => texts.add(text);
  @override
  TextMetrics measureText(String text) => metrics;
  @override
  gr.GlyphImageData getImageData(int x, int y, int w, int h) {
    // One bright pixel at (1,1); rest transparent — bounding box = [1,2)x[1,2).
    final Uint8List data = Uint8List(w * h * 4);
    final int off = (1 * w + 1) * 4;
    data[off] = 255;
    data[off + 1] = 255;
    data[off + 2] = 255;
    data[off + 3] = 255;
    return gr.GlyphImageData(w, h, data);
  }

  @override
  void putImageData(gr.GlyphImageData imageData, int x, int y) => putCount++;
}

class _FakeCanvas implements gr.GlyphCanvas {
  _FakeCanvas(this.width, this.height, this.context);
  @override
  int width;
  @override
  int height;
  final gr.GlyphContext2D context;
  @override
  gr.GlyphContext2D getContext(String type, [Map<String, Object?>? options]) =>
      context;
}

void main() {
  _FakeContext? lastCtx;

  setUp(() {
    gr.glyphRasterizerIsMacintosh = false; // subpixel path
    gr.createGlyphCanvas = (int w, int h) {
      final ctx = _FakeContext(const TextMetrics(
        width: 10,
        fontBoundingBoxAscent: 8,
        fontBoundingBoxDescent: 2,
        alphabeticBaseline: 7,
      ));
      lastCtx = ctx;
      return _FakeCanvas(w, h, ctx);
    };
  });

  gr.GlyphRasterizer makeRasterizer([DecorationStyleCache? cache]) =>
      gr.GlyphRasterizer(10, 'monospace', 2.0, cache ?? DecorationStyleCache());

  group('batch31 / glyphRasterizer', () {
    test('id increments and cacheKey is family_size', () {
      final a = makeRasterizer();
      final b = makeRasterizer();
      expect(b.id, a.id + 1);
      expect(a.cacheKey, 'monospace_10px');
      expect(a.cacheKey, same(a.cacheKey)); // memoized
    });

    test('empty chars returns inverted bounding box glyph', () {
      final r = makeRasterizer();
      final g = r.rasterizeGlyph('', 0, 0, <String>[]);
      expect(g.boundingBox.top, 0);
      expect(g.boundingBox.bottom, -1);
      expect(g.boundingBox.right, -1);
    });

    test('rasterizeGlyph computes bounding box and origin offset', () {
      final r = makeRasterizer();
      final colorMap = List<String>.filled(256, '#000000');
      colorMap[ColorId.defaultBackground] = '#102030';
      final g = r.rasterizeGlyph('A', 0, 0, colorMap);
      // getImageData paints a pixel at (1,1): box [1,2), offset = 1-30 = -29.
      expect(g.boundingBox.left, 1);
      expect(g.boundingBox.top, 1);
      expect(g.boundingBox.right, 1);
      expect(g.boundingBox.bottom, 1);
      expect(g.originOffset.x, 1 - 20);
      expect(g.originOffset.y, 1 - 20);
      expect(lastCtx!.texts, contains('A'));
      expect(lastCtx!.saveCount, 1);
      expect(lastCtx!.restoreCount, 1);
    });

    test('work glyph is reused for identical config', () {
      final r = makeRasterizer();
      final colorMap = List<String>.filled(256, '#000000');
      colorMap[ColorId.defaultBackground] = '#102030';
      final g1 = r.rasterizeGlyph('A', 0, 0, colorMap);
      final g2 = r.rasterizeGlyph('A', 0, 0, colorMap);
      expect(identical(g1, g2), isTrue);
      final before = lastCtx!.texts.length;
      r.rasterizeGlyph('A', 0, 0, colorMap);
      expect(lastCtx!.texts.length, before); // no re-rasterize
    });

    test('greyscale path uses clearRect and no putImageData', () {
      gr.glyphRasterizerIsMacintosh = true;
      final r = makeRasterizer();
      final colorMap = List<String>.filled(256, '#000000');
      r.rasterizeGlyph('A', 0, 0, colorMap);
      expect(lastCtx!.clearCount, 1);
      expect(lastCtx!.putCount, 0);
    });

    test('strikethrough draws a rect using alphabeticBaseline', () {
      final cache = DecorationStyleCache();
      final styleId = cache.getOrCreateEntry(
        null,
        false,
        null,
        true,
        4,
        0xFF0000FF,
      );
      final r = makeRasterizer(cache);
      final colorMap = List<String>.filled(256, '#000000');
      colorMap[ColorId.defaultBackground] = '#102030';
      r.rasterizeGlyph('A', 0, styleId, colorMap);
      // fillRect calls: background + strikethrough (2 rects).
      expect(lastCtx!.rects.length, 2);
    });

    test('getTextMetrics forwards to context', () {
      final r = makeRasterizer();
      final m = r.getTextMetrics('XYZ');
      expect(m.width, 10);
      expect(m.alphabeticBaseline, 7);
    });

    test('foreground color from colorMap when no decoration', () {
      final r = makeRasterizer();
      final colorMap = List<String>.filled(256, '#000000');
      colorMap[ColorId.defaultBackground] = '#102030';
      colorMap[0] = '#050505';
      r.rasterizeGlyph('A', 0, 0, colorMap);
      expect(lastCtx!.fills, contains('#050505'));
    });
  });

  group('batch31 / translated mocha suites', () {
    test('textLength cases pass', () => tl.runAll());
    test('lineRange cases pass', () => lr.runAll());
    test('stringBuilder cases pass', () => sb.runAll());
  });
}
