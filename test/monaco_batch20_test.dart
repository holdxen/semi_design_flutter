import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/errors.dart'
    show BugIndicatingError;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/virtualClock.dart'
    as vc;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/atlas.dart'
    as atlas;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/textureAtlasShelfAllocator.dart'
    as shelf;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/raster/raster.dart'
    as raster;
import 'package:semi_design_flutter/src/monaco/editor/common/services/textModelSync/textModelSync.protocol.dart'
    as sync;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/controller/commandIds.dart'
    as cmd;
import 'package:semi_design_flutter/src/monaco/editor/contrib/stickyScroll/browser/stickyScrollElement.dart'
    as sticky;

/// Records draw calls so the shelf allocator's row-packing can be verified.
class _RecordingContext implements shelf.AtlasContext2D {
  final List<String> draws = <String>[];
  final List<String> rects = <String>[];
  String _fillStyle = '';
  @override
  set fillStyle(String value) => _fillStyle = value;

  @override
  void drawImage(raster.OffscreenCanvas source, num sx, num sy, num sw, num sh,
      num dx, num dy, num dw, num dh) {
    draws.add('$sx,$sy,$sw,$sh->$dx,$dy,$dw,$dh');
  }

  @override
  void fillRect(num x, num y, num w, num h) {
    rects.add('$_fillStyle:$x,$y,$w,$h');
  }
}

shelf.AtlasCanvas _canvas(int w, int h, shelf.AtlasContext2D ctx) =>
    shelf.AtlasCanvas(
      width: w,
      height: h,
      getContext: (_, [__]) => ctx,
      convertToBlob: () async => atlas.Blob(Object()),
    );

raster.IRasterizedGlyph _glyph(int w, int h) => raster.RasterizedGlyph(
      source: raster.OffscreenCanvas(Object()),
      boundingBox: raster.BoundingBox(
        left: 0,
        top: 0,
        right: w - 1,
        bottom: h - 1,
      ),
      originOffset: raster.OriginOffset(x: 0, y: 0),
      fontBoundingBoxAscent: 0,
      fontBoundingBoxDescent: 0,
    );

void _expectRect(
  atlas.ITextureAtlasPageGlyph? g,
  int x,
  int y,
  int w,
  int h,
) {
  expect(g, isNotNull);
  expect({'x': g!.x, 'y': g.y, 'w': g.w, 'h': g.h},
      {'x': x, 'y': y, 'w': w, 'h': h});
}

void main() {
  group('TextureAtlasShelfAllocator', () {
    test('single allocation', () {
      final ctx = _RecordingContext();
      final allocator = shelf.TextureAtlasShelfAllocator(_canvas(2, 2, ctx), 0);
      _expectRect(allocator.allocate(_glyph(1, 1)), 0, 0, 1, 1);
      expect(ctx.draws, ['0,0,1,1->0,0,1,1']);
    });

    test('glyph too large for canvas throws', () {
      final ctx = _RecordingContext();
      final allocator = shelf.TextureAtlasShelfAllocator(_canvas(1, 1, ctx), 0);
      expect(() => allocator.allocate(_glyph(2, 1)),
          throwsA(isA<BugIndicatingError>()));
    });

    test('wrapping (source: textureAtlasAllocator.test.ts)', () {
      final ctx = _RecordingContext();
      final allocator = shelf.TextureAtlasShelfAllocator(_canvas(5, 4, ctx), 0);
      _expectRect(allocator.allocate(_glyph(1, 1)), 0, 0, 1, 1);
      _expectRect(allocator.allocate(_glyph(1, 2)), 1, 0, 1, 2);
      _expectRect(allocator.allocate(_glyph(2, 1)), 2, 0, 2, 1);
      _expectRect(allocator.allocate(_glyph(2, 1)), 0, 2, 2, 1);
      _expectRect(allocator.allocate(_glyph(2, 1)), 2, 2, 2, 1);
      _expectRect(allocator.allocate(_glyph(1, 1)), 4, 2, 1, 1);
      _expectRect(allocator.allocate(_glyph(1, 1)), 0, 3, 1, 1);
    });

    test('full canvas returns null', () {
      final ctx = _RecordingContext();
      final allocator = shelf.TextureAtlasShelfAllocator(_canvas(3, 2, ctx), 0);
      _expectRect(allocator.allocate(_glyph(1, 2)), 0, 0, 1, 2);
      _expectRect(allocator.allocate(_glyph(2, 1)), 1, 0, 2, 1);
      expect(allocator.allocate(_glyph(1, 1)), isNull);
    });

    test('getStats matches source format', () {
      final ctx = _RecordingContext();
      final allocator = shelf.TextureAtlasShelfAllocator(_canvas(3, 2, ctx), 0);
      _expectRect(allocator.allocate(_glyph(1, 2)), 0, 0, 1, 2);
      _expectRect(allocator.allocate(_glyph(2, 1)), 1, 0, 2, 1);
      final stats = allocator.getStats();
      expect(stats, contains('page0:'));
      expect(stats, contains('Total: 6 (3x2)'));
      expect(stats, contains('Used: 4 (67%)'));
      expect(stats, contains('Wasted: 2 (33%)'));
      expect(stats, contains('Efficiency: 67%'));
    });

    test('getUsagePreview fills canvas through injected factory', () async {
      final ctx = _RecordingContext();
      final allocator = shelf.TextureAtlasShelfAllocator(_canvas(2, 2, ctx), 0);
      _expectRect(allocator.allocate(_glyph(1, 1)), 0, 0, 1, 1);
      final previewCtx = _RecordingContext();
      final old = shelf.atlasCanvasFactory;
      shelf.atlasCanvasFactory = (w, h) => _canvas(w, h, previewCtx);
      try {
        final blob = await allocator.getUsagePreview();
        expect(blob, isA<atlas.Blob>());
        expect(previewCtx.rects.first, startsWith(atlas.UsagePreviewColors.Unused));
      } finally {
        shelf.atlasCanvasFactory = old;
      }
    });
  });

  group('VirtualClock', () {
    test('schedule/peek/runNext advances now and respects order', () {
      final clock = vc.VirtualClock();
      final order = <String>[];
      void scheduleAt(int t, String id) => clock.schedule(vc.QueuedEvent(
            time: t,
            source: _Source(id),
            trace: null,
            preferRealAnimationFrame: false,
            runFn: () => order.add(id),
            id: 0,
          ));
      scheduleAt(10, 'b');
      scheduleAt(5, 'a');
      expect(clock.hasEvents, isTrue);
      expect(clock.peekNext()!.source.toString(), 'a');
      expect(clock.runNext()!.source.toString(), 'a');
      expect(clock.now, 5);
      expect(clock.runNext()!.source.toString(), 'b');
      expect(clock.now, 10);
      expect(clock.hasEvents, isFalse);
      expect(order, ['a', 'b']);
    });

    test('equal times are tie-broken by insertion id', () {
      final clock = vc.VirtualClock();
      final order = <String>[];
      for (final id in ['first', 'second', 'third']) {
        clock.schedule(vc.QueuedEvent(
          time: 7,
          source: _Source(id),
          trace: null,
          preferRealAnimationFrame: false,
          runFn: () => order.add(id),
          id: 0,
        ));
      }
      clock.runNext();
      clock.runNext();
      clock.runNext();
      expect(order, ['first', 'second', 'third']);
    });

    test('schedule before now throws', () {
      final clock = vc.VirtualClock(100);
      expect(
        () => clock.schedule(vc.QueuedEvent(
          time: 50,
          source: _Source('x'),
          trace: null,
          preferRealAnimationFrame: false,
          runFn: () {},
          id: 0,
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('dispose removes a queued event', () {
      final clock = vc.VirtualClock();
      var ran = false;
      final d = clock.schedule(vc.QueuedEvent(
        time: 1,
        source: _Source('x'),
        trace: null,
        preferRealAnimationFrame: false,
        runFn: () => ran = true,
        id: 0,
      ));
      d.dispose();
      expect(clock.hasEvents, isFalse);
      expect(clock.runNext(), isNull);
      expect(ran, isFalse);
    });

    test('onEventScheduled fires the original event', () {
      final clock = vc.VirtualClock();
      vc.VirtualEvent? observed;
      clock.onEventScheduled((dynamic e) => observed = e as vc.VirtualEvent);
      final event = vc.QueuedEvent(
        time: 1,
        source: _Source('x'),
        trace: null,
        preferRealAnimationFrame: false,
        runFn: () {},
        id: 0,
      );
      clock.schedule(event);
      expect(observed, same(event));
    });

    test('getEvents returns sorted snapshot', () {
      final clock = vc.VirtualClock();
      clock.schedule(vc.QueuedEvent(
        time: 3, source: _Source('a'), trace: null,
        preferRealAnimationFrame: false, runFn: () {}, id: 0));
      clock.schedule(vc.QueuedEvent(
        time: 1, source: _Source('b'), trace: null,
        preferRealAnimationFrame: false, runFn: () {}, id: 0));
      expect(clock.getEvents().map((e) => e.source.toString()), ['b', 'a']);
    });
  });

  group('small files', () {
    test('commandIds keep exact source strings', () {
      expect(cmd.inlineSuggestCommitId, 'editor.action.inlineSuggest.commit');
      expect(cmd.inlineSuggestCommitAlternativeActionId,
          'editor.action.inlineSuggest.commitAlternativeAction');
      expect(cmd.showPreviousInlineSuggestionActionId,
          'editor.action.inlineSuggest.showPrevious');
      expect(cmd.showNextInlineSuggestionActionId,
          'editor.action.inlineSuggest.showNext');
      expect(cmd.jumpToNextInlineEditId, 'editor.action.inlineSuggest.jump');
      expect(cmd.hideInlineCompletionId, 'editor.action.inlineSuggest.hide');
      expect(cmd.toggleShowCollapsedId,
          'editor.action.inlineSuggest.toggleShowCollapsed');
      expect(cmd.renameSymbolCommandId,
          'editor.action.inlineSuggest.renameSymbol');
    });

    test('sticky scroll carriers keep fields', () {
      final range = sticky.StickyRange(1, 5);
      final parent = sticky.StickyElement(range, const <sticky.StickyElement>[], null);
      final child = sticky.StickyElement(range, const <sticky.StickyElement>[], parent);
      final model = sticky.StickyModel(URI.parse('file:///a.ts'), 3, child, 'outline');
      expect(range.startLineNumber, 1);
      expect(range.endLineNumber, 5);
      expect(child.parent, same(parent));
      expect(model.version, 3);
      expect(model.outlineProviderId, 'outline');
    });

    test('textModelSync protocol raw data carrier', () {
      final data = sync.RawModelData(
        url: 'file:///m.ts',
        versionId: 2,
        lines: const ['a', 'b'],
        EOL: '\n',
      );
      expect(data.url, 'file:///m.ts');
      expect(data.versionId, 2);
      expect(data.lines, ['a', 'b']);
      expect(data.EOL, '\n');
    });
  });
}

class _Source implements vc.EventSource {
  final String label;
  _Source(this.label);
  @override
  String toString() => label;

  @override
  String? get stackTrace => null;
}
