// Truth-driven tests for batch178b: editor/test/browser/gpu/atlas/testUtil.ts
// Truth source: tool/ts2dart/batch178b_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/atlas.dart' as atlas;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/textureAtlas.dart' as ta;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/raster/raster.dart' as raster;
import 'package:semi_design_flutter/src/monaco/editor/test/browser/gpu/atlas/testUtil.dart' as util;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch178b_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _Canvas {
  _Canvas(this.width, this.height, [this.opaque = true]);
  final int width;
  final int height;
  final bool opaque;
  final List<List<int>> calls = <List<int>>[];

  Object getContext(String id) => _Context(this);
}

class _Context {
  _Context(this.canvas);
  final _Canvas canvas;

  Object getImageData(int x, int y, int w, int h) {
    canvas.calls.add(<int>[x, y, w, h]);
    final List<int> data = List<int>.filled(w * h, canvas.opaque ? 0xFF000001 : 0);
    return _ImageData(data);
  }
}

class _ImageData {
  _ImageData(this.data);
  final List<int> data;
}

class _FakeAtlas implements ta.TextureAtlas {
  @override
  int get pageSize => 16;
  @override
  List<atlas.IReadableTextureAtlasPage> get pages =>
      <atlas.IReadableTextureAtlasPage>[_FakePage(raster.OffscreenCanvas(source))];
  final OffscreenCanvasSource source;
  _FakeAtlas(this.source);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// The page source is an OffscreenCanvas carrier whose handle exposes
// getContext, mirroring the DOM bridge used by the port.
class OffscreenCanvasSource {
  OffscreenCanvasSource(this.canvas);
  final _Canvas canvas;
  Object getContext(String id) => canvas.getContext(id);
}

class _FakePage implements atlas.IReadableTextureAtlasPage {
  _FakePage(this.source);
  @override
  final raster.OffscreenCanvas source;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final atlas.TextureAtlasPageGlyph valid = atlas.TextureAtlasPageGlyph(
  pageIndex: 0,
  glyphIndex: 0,
  x: 2,
  y: 3,
  w: 4,
  h: 5,
  originOffsetX: 0,
  originOffsetY: 0,
  fontBoundingBoxAscent: 0,
  fontBoundingBoxDescent: 0,
);

Object? capture(void Function() fn) {
  try {
    fn();
    return null;
  } catch (e) {
    return e;
  }
}

void main() {
  group('testUtil.ts (truth-driven)', () {
    test('exports match truth', () {
      expect(truth['exports'], <dynamic>['assertIsValidGlyph']);
    });

    test('valid glyph reads the four outer edges from an atlas page', () {
      final _Canvas canvas = _Canvas(16, 16);
      final _FakeAtlas fakeAtlas = _FakeAtlas(OffscreenCanvasSource(canvas));
      util.assertIsValidGlyph(valid, fakeAtlas);
      expect(canvas.calls, (truth['valid'] as Map<String, dynamic>)['calls']);
    });

    test('canvas branch uses width for both page dimensions', () {
      final _Canvas canvas = _Canvas(16, 8);
      util.assertIsValidGlyph(
          atlas.TextureAtlasPageGlyph(
            pageIndex: 0,
            glyphIndex: 0,
            x: 2,
            y: 10,
            w: 4,
            h: 5,
            originOffsetX: 0,
            originOffsetY: 0,
            fontBoundingBoxAscent: 0,
            fontBoundingBoxDescent: 0,
          ),
          canvas);
      expect(canvas.calls, (truth['canvasBranch'] as Map<String, dynamic>)['calls']);
    });

    test('invalid glyphs and transparent edges fail like truth', () {
      final _Canvas canvas = _Canvas(16, 16);
      final Object? undefinedError =
          capture(() => util.assertIsValidGlyph(null, canvas));
      expect(undefinedError, isA<StateError>());
      expect((undefinedError as StateError).message,
          truth['undefinedGlyph']);

      for (final String key in <String>[
        'badX', 'badW', 'notNumber', 'outOfBounds'
      ]) {
        final atlas.TextureAtlasPageGlyph candidate =
            atlas.TextureAtlasPageGlyph(
          pageIndex: 0,
          glyphIndex: 0,
          x: key == 'badX' ? -1 : key == 'notNumber' ? double.nan : valid.x,
          y: valid.y,
          w: key == 'badW' ? 99 : valid.w,
          h: valid.h,
          originOffsetX: 0,
          originOffsetY: 0,
          fontBoundingBoxAscent: 0,
          fontBoundingBoxDescent: 0,
        );
        if (key == 'outOfBounds') {
          expect(
              capture(() => util.assertIsValidGlyph(
                  atlas.TextureAtlasPageGlyph(
                    pageIndex: 0,
                    glyphIndex: 0,
                    x: 12,
                    y: 3,
                    w: 6,
                    h: 5,
                    originOffsetX: 0,
                    originOffsetY: 0,
                    fontBoundingBoxAscent: 0,
                    fontBoundingBoxDescent: 0,
                  ),
                  canvas)),
              isA<StateError>());
        } else {
          expect(capture(() => util.assertIsValidGlyph(candidate, canvas)),
              isA<StateError>(),
              reason: key);
        }
        expect(truth[key], 'assertion failed');
      }

      final Object? transparent = capture(() =>
          util.assertIsValidGlyph(valid, _Canvas(16, 16, false)));
      expect(transparent, isA<StateError>());
      expect(truth['transparentEdges'], 'assertion failed');
    });
  });
}
