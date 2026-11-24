// Truth-driven tests for batch178: editor/browser/gpu/atlas/textureAtlas.ts
// Truth source: tool/ts2dart/batch178_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart'
    show getActiveWindow, windowCarrier;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart' as errors;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/atlas.dart' as atlas;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/textureAtlas.dart' as ta;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/textureAtlasPage.dart' as page;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/textureAtlasShelfAllocator.dart' as shelf;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/css/decorationStyleCache.dart' as dsc;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/raster/glyphRasterizer.dart' as gr;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/raster/raster.dart' as raster;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/taskQueue.dart' as tq;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart' as inst;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart' as theme;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart' as ts;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch178_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _Recorder {
  final List<List<Object?>> createInstanceArgs = <List<Object?>>[];
  final List<TexturePageRecord> pages = <TexturePageRecord>[];
  final List<_FakeTaskQueue> queues = <_FakeTaskQueue>[];
  int capacity = 1000;
  List<String> colorMap = <String>['fg0'];
}

final _Recorder rec = _Recorder();

class TexturePageRecord {
  TexturePageRecord(this.textureIndex, this.pageSize, this.allocatorType);
  final int textureIndex;
  final int pageSize;
  final Object allocatorType;
  final List<RecordedGlyph> glyphs = <RecordedGlyph>[];
  bool disposed = false;
}

class RecordedGlyph implements raster.IRasterizedGlyph {
  RecordedGlyph(this.chars, this.tokenMetadata, this.decorationStyleSetId);
  final String chars;
  final int tokenMetadata;
  final int decorationStyleSetId;
  @override
  raster.OffscreenCanvas get source => raster.OffscreenCanvas(Object());
  @override
  raster.IBoundingBox get boundingBox =>
      const raster.BoundingBox(left: 0, top: 0, right: 1, bottom: 1);
  @override
  raster.OriginOffset get originOffset => const raster.OriginOffset(x: 0, y: 0);
  @override
  num get fontBoundingBoxAscent => 0;
  @override
  num get fontBoundingBoxDescent => 0;
}

class _CapacityAllocator implements atlas.ITextureAtlasAllocator {
  _CapacityAllocator(this.canvas, this.textureIndex, this.record);
  final shelf.AtlasCanvas canvas;
  final int textureIndex;
  final TexturePageRecord record;
  int allocated = 0;

  @override
  atlas.ITextureAtlasPageGlyph? allocate(raster.IRasterizedGlyph glyph) {
    if (allocated >= rec.capacity) return null;
    final int index = allocated++;
    final RecordedGlyph recorded = glyph is RecordedGlyph
        ? glyph
        : RecordedGlyph('', 0, 0);
    record.glyphs.add(recorded);
    return atlas.TextureAtlasPageGlyph(
      pageIndex: textureIndex,
      glyphIndex: index,
      x: index,
      y: 0,
      w: glyph.boundingBox.right - glyph.boundingBox.left,
      h: glyph.boundingBox.bottom - glyph.boundingBox.top,
      originOffsetX: 0,
      originOffsetY: 0,
      fontBoundingBoxAscent: 0,
      fontBoundingBoxDescent: 0,
    );
  }

  @override
  Future<atlas.Blob> getUsagePreview() async =>
      atlas.Blob(<String, Object?>{'page': textureIndex});

  @override
  String getStats() => 'page:$textureIndex:$allocated';
}

class _FakeContext implements gr.GlyphContext2D {
  @override
  set textBaseline(String value) {}
  @override
  set fillStyle(String value) {}
  @override
  set font(String value) {}
  @override
  set globalAlpha(num value) {}
  @override
  void save() {}
  @override
  void restore() {}
  @override
  void fillRect(num x, num y, num w, num h) {}
  @override
  void clearRect(num x, num y, num w, num h) {}
  @override
  void fillText(String text, num x, num y) {}
  @override
  raster.TextMetrics measureText(String text) => const raster.TextMetrics();
  @override
  gr.GlyphImageData getImageData(int x, int y, int w, int h) =>
      gr.GlyphImageData(w, h, Uint8List(w * h * 4));
  @override
  void putImageData(gr.GlyphImageData imageData, int x, int y) {}
}

class _FakeCanvas implements gr.GlyphCanvas {
  _FakeCanvas(this.width, this.height);
  @override
  int width;
  @override
  int height;
  @override
  gr.GlyphContext2D getContext(String type, [Map<String, Object?>? options]) =>
      _FakeContext();
}

class _FakeColorTheme implements ts.IColorTheme {
  @override
  List<String> get tokenColorMap => rec.colorMap;
  @override
  theme.ColorScheme get type => theme.ColorScheme.dark;
  @override
  String get label => 'test';
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeThemeService implements ts.IThemeServiceType {
  final event.Emitter<ts.IColorTheme> emitter = event.Emitter<ts.IColorTheme>();
  @override
  ts.IColorTheme getColorTheme() => _FakeColorTheme();
  @override
  event.Event<ts.IColorTheme> get onDidColorThemeChange => emitter.event;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeLog implements log.ILogServiceType {
  @override
  int getLevel() => log.LogLevel.Info;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeTaskQueue implements tq.ITaskQueue {
  final List<Object? Function()> tasks = <Object? Function()>[];
  @override
  void enqueue(Object? Function() task) => tasks.add(task);
  @override
  void flush() {
    for (final Object? Function() t in tasks) {
      t();
    }
  }

  @override
  void clear() => tasks.clear();
  @override
  void dispose() {}
}

class _FakeInstantiationService implements inst.IInstantiationServiceType {
  _FakeInstantiationService(this.themeService);
  final ts.IThemeServiceType themeService;
  @override
  Object? createInstance(Object ctor, List<Object?> args) {
    rec.createInstanceArgs.add(args);
    if (ctor == page.TextureAtlasPage) {
      final int textureIndex = args[0] as int;
      final int pageSize = args[1] as int;
      final TexturePageRecord record =
          TexturePageRecord(textureIndex, pageSize, args[2] as Object);
      rec.pages.add(record);
      return page.TextureAtlasPage(
        textureIndex,
        pageSize,
        (shelf.AtlasCanvas canvas, int index) =>
            _CapacityAllocator(canvas, index, record),
        _FakeLog(),
        themeService,
      );
    }
    if (ctor == tq.IdleTaskQueue) {
      final _FakeTaskQueue q = _FakeTaskQueue();
      rec.queues.add(q);
      return q;
    }
    throw StateError('unexpected createInstance($ctor)');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeRasterizer implements raster.IGlyphRasterizer {
  @override
  final int id;
  @override
  final String cacheKey;
  _FakeRasterizer(this.id, this.cacheKey);
  @override
  raster.IRasterizedGlyph rasterizeGlyph(String chars, int tokenMetadata,
          int decorationStyleSetId, List<String> colorMap) =>
      RecordedGlyph(chars, tokenMetadata, decorationStyleSetId);
  @override
  raster.TextMetrics getTextMetrics(String text) => const raster.TextMetrics();
}

final shelf.AtlasCanvasFactory _originalCanvasFactory = shelf.atlasCanvasFactory;
final gr.GlyphCanvas Function(int, int) _originalGlyphCanvas =
    gr.createGlyphCanvas;

void reset(int maxTextureSize, double ratio, List<String> colors) {
  rec.createInstanceArgs.clear();
  rec.pages.clear();
  rec.queues.clear();
  rec.capacity = 1000;
  rec.colorMap = colors;
  _service = _FakeThemeService();
  windowCarrier(getActiveWindow()).devicePixelRatio = ratio;
}

ta.TextureAtlas createAtlas(int maxTextureSize) => ta.TextureAtlas(
      maxTextureSize,
      null,
      dsc.DecorationStyleCache(),
      _service,
      _FakeInstantiationService(_service),
    );

late ts.IThemeServiceType _service;

void main() {
  setUp(() {
    shelf.atlasCanvasFactory = (int w, int h) => shelf.AtlasCanvas(
          width: w,
          height: h,
          getContext: (_, [__]) => throw StateError('no 2d context'),
          convertToBlob: () async => atlas.Blob(Object()),
        );
    gr.createGlyphCanvas = (int w, int h) => _FakeCanvas(w, h);
  });
  tearDown(() {
    shelf.atlasCanvasFactory = _originalCanvasFactory;
    gr.createGlyphCanvas = _originalGlyphCanvas;
  });

  group('TextureAtlas (truth-driven)', () {
    test('exports and constructor create one page with a null glyph', () {
      expect(truth['exports'], <dynamic>['TextureAtlas']);
      reset(512, 1, <String>['fg0']);
      final ta.TextureAtlas atlas = createAtlas(512);
      final Map<String, dynamic> e = truth['constructor'] as Map<String, dynamic>;
      expect(atlas.pageSize, e['pageSize']);
      expect(rec.pages.length, (e['pages'] as List<dynamic>).length);
      expect(<Object?>[
        rec.pages.first.textureIndex,
        rec.pages.first.pageSize,
        rec.pages.first.allocatorType,
      ], <Object?>[
        (e['pages'] as List<dynamic>)[0]['index'],
        (e['pages'] as List<dynamic>)[0]['size'],
        (e['pages'] as List<dynamic>)[0]['allocator'],
      ]);
      expect(rec.pages.first.glyphs.first.chars, '');
      reset(4096, 2, <String>['fg0']);
      expect(createAtlas(4096).pageSize, truth['highDprPageSize']);
    });

    test('getGlyph masks metadata, applies subpixel offset and caches', () {
      final Map<String, dynamic> e = truth['getGlyph'] as Map<String, dynamic>;
      reset(1024, 1, <String>['fg0']);
      final ta.TextureAtlas textureAtlas = createAtlas(1024);
      final raster.IGlyphRasterizer r = _FakeRasterizer(1, 'r1');
      final int metadata = e['metadataIn'] as int;
      final atlas.ITextureAtlasPageGlyph a =
          textureAtlas.getGlyph(r, 'x', metadata, 0, 0.75);
      final atlas.ITextureAtlasPageGlyph b =
          textureAtlas.getGlyph(r, 'x', metadata, 0, 0.75);
      expect(rec.pages.first.glyphs.last.tokenMetadata, e['expectedMetadata']);
      expect(identical(a, b), e['cached']);
      expect(a.glyphIndex, e['glyphIndex']);
      expect(a.pageIndex, e['pageIndex']);
    });

    test('overflow creates a new page and max page count throws', () {
      final Map<String, dynamic> e = truth['overflow'] as Map<String, dynamic>;
      reset(1024, 1, <String>['fg0']);
      rec.capacity = 1;
      final ta.TextureAtlas textureAtlas = createAtlas(1024);
      final atlas.ITextureAtlasPageGlyph g = textureAtlas.getGlyph(
          _FakeRasterizer(1, 'r1'), 'y', 0, 0, 0);
      expect(rec.pages.length, e['pages']);
      expect(g.pageIndex, e['glyphPageIndex']);
      expect(textureAtlas.getStats(), e['stats']);

      final Map<String, dynamic> m = truth['maxPages'] as Map<String, dynamic>;
      reset(1024, 1, <String>['fg0']);
      rec.capacity = 1;
      final ta.TextureAtlas limited = createAtlas(1024);
      final raster.IGlyphRasterizer r = _FakeRasterizer(1, 'r1');
      Object? thrown;
      try {
        for (int i = 0; i < 40; i++) {
          limited.getGlyph(r, 'z$i', 0, 0, 0);
        }
      } catch (error) {
        thrown = error;
      }
      expect(rec.pages.length, m['pages']);
      expect(thrown, isA<errors.BugIndicatingError>());
      expect(thrown.toString(), contains(m['message'] as String));
    });

    test('clear disposes pages, fires event and recreates page 0', () {
      final Map<String, dynamic> e = truth['clear'] as Map<String, dynamic>;
      reset(1024, 1, <String>['fg0']);
      final ta.TextureAtlas textureAtlas = createAtlas(1024);
      int fires = 0;
      textureAtlas.onDidDeleteGlyphs((dynamic _) => fires++);
      textureAtlas.getGlyph(_FakeRasterizer(1, 'r1'), 'x', 0, 0, 0);
      textureAtlas.clear();
      expect(fires, e['fires']);
      expect(rec.pages.length, e['pages']);
      expect(rec.pages.map((TexturePageRecord p) => p.textureIndex).toList(),
          e['indices']);
      expect(rec.pages.first.glyphs.length, e['glyphs'] - 1);
    });

    test('warm-up enqueues all printable ASCII glyphs per color', () {
      final Map<String, dynamic> e = truth['warmUp'] as Map<String, dynamic>;
      reset(1024, 1, <String>['fg0', 'fg1', 'fg2']);
      final ta.TextureAtlas textureAtlas = createAtlas(1024);
      final raster.IGlyphRasterizer r = _FakeRasterizer(2, 'r2');
      textureAtlas.getGlyph(r, 'x', 0, 0, 0);
      expect(rec.queues.length, e['queues']);
      expect(rec.queues.first.tasks.length, e['tasks']);
      rec.queues.first.tasks.first();
      final RecordedGlyph first = rec.pages.first.glyphs[2];
      final Map<String, dynamic> expected =
          (e['firstTask'] as Map<String, dynamic>);
      expect(<Object?>[first.chars, first.tokenMetadata, first.decorationStyleSetId],
          <Object?>[
            expected['chars'], expected['tokenMetadata'],
            expected['decorationStyleSetId'],
          ]);
    });

    test('theme change clears and usage preview delegates', () async {
      final Map<String, dynamic> e =
          truth['themeChange'] as Map<String, dynamic>;
      reset(1024, 1, <String>['fg0']);
      final _FakeThemeService service = _service as _FakeThemeService;
      final ta.TextureAtlas textureAtlas = createAtlas(1024);
      int fires = 0;
      textureAtlas.onDidDeleteGlyphs((dynamic _) => fires++);
      rec.colorMap = <String>['new0', 'new1', 'new2', 'new3'];
      service.emitter.fire(_FakeColorTheme());
      expect(fires, e['fires']);
      expect(rec.pages.length, e['pages']);

      reset(1024, 1, <String>['fg0']);
      final ta.TextureAtlas previewAtlas = createAtlas(1024);
      final List<atlas.Blob> previews = await previewAtlas.getUsagePreview();
      expect(previews.length, (truth['preview'] as List<dynamic>).length);
      expect((previews.first.handle as Map<String, Object?>)['page'],
          (truth['preview'] as List<dynamic>)[0]['page']);
    });
  });
}
