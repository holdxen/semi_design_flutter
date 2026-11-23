import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/marked/marked.d.dart' as marked;
import 'package:semi_design_flutter/src/monaco/base/common/worker/webWorker.dart' as ww;
import 'package:semi_design_flutter/src/monaco/base/test/common/timeTravelScheduler.dart' as tts;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/index.dart' as sched;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/minimap/minimapCharRendererFactory.dart' as mcf;
import 'package:semi_design_flutter/src/monaco/editor/common/services/editorWorkerHost.dart' as ewh;
import 'package:semi_design_flutter/src/monaco/lsp/utils.dart' as lsp;

// ---- fakes -----------------------------------------------------------------

class _FakeServer implements ww.IWebWorkerServer {
  final Map<String, Object> channels = <String, Object>{};
  @override
  void setChannel(String channel, Object handler) => channels[channel] = handler;
  @override
  Object getChannel(String channel) => channels[channel]!;
}

class _FakeClient implements ww.IWebWorkerClient {
  final Map<String, Object> channels = <String, Object>{};
  @override
  Object get proxy => this;
  @override
  void dispose() {}
  @override
  void setChannel(String channel, Object handler) => channels[channel] = handler;
  @override
  Object getChannel(String channel) => channels[channel]!;
}

class _FakeWorkerHost implements ewh.EditorWorkerHost {
  @override
  Future<Object?> $fhr(String method, List<Object?> args) async => '$method:${args.length}';
}

class _RecordingCanvas2D implements mcf.MinimapCanvas2D {
  final List<String> glyphs = <String>[];
  final List<num> xs = <num>[];
  String? lastFont;
  String? lastBaseline;
  String? lastFill;
  @override
  set fillStyle(String value) => lastFill = value;
  @override
  set font(String value) => lastFont = value;
  @override
  set textBaseline(String value) => lastBaseline = value;
  @override
  void fillText(String text, num x, num y) {
    glyphs.add(text);
    xs.add(x);
  }

  @override
  Uint8List getImageData(int x, int y, int w, int h) => Uint8List(w * h * 4);
}

void main() {
  setUp(() {
    mcf.createMinimapCanvas = () => mcf.MinimapCanvas(_RecordingCanvas2D());
    lsp.DisposableStore.DISABLE_DISPOSED_WARNING = true;
  });

  group('batch29 / timeTravelScheduler barrel', () {
    test('aliases originalGlobalValues and TimeTravelScheduler', () {
      expect(tts.originalGlobalValues, same(sched.realTimeApi));
      // typedef alias: a VirtualClock is a TimeTravelScheduler.
      final tts.TimeTravelScheduler clock = tts.TimeTravelScheduler(7);
      expect(clock.now, 7);
    });

    test('re-exports scheduling functions', () {
      expect(tts.captureGlobalTimeApi, isA<Function>());
      expect(tts.createVirtualTimeApi, isA<Function>());
      expect(tts.createLoggingTimeApi, isA<Function>());
      expect(tts.pushGlobalTimeApi, isA<Function>());
      expect(tts.runWithFakedTimers, isA<Function>());
    });
  });

  group('batch29 / lsp utils', () {
    test('Disposable.None is a no-op disposable', () {
      expect(lsp.Disposable.None, isA<lsp.IDisposable>());
      lsp.Disposable.None.dispose(); // no throw
    });

    test('DisposableStore disposes all registered items once', () {
      final store = lsp.DisposableStore();
      int a = 0;
      int b = 0;
      store.add(toDisposeTest(() => a++));
      store.add(toDisposeTest(() => b++));
      store.dispose();
      expect(a, 1);
      expect(b, 1);
      store.dispose(); // idempotent
      expect(a, 1);
      expect(b, 1);
    });

    test('DisposableStore.clear disposes then empties', () {
      final store = lsp.DisposableStore();
      int n = 0;
      store.add(toDisposeTest(() => n++));
      store.clear();
      expect(n, 1);
      store.clear();
      expect(n, 1);
    });

    test('DisposableStore rejects registering itself', () {
      final store = lsp.DisposableStore();
      expect(() => store.add(store), throwsStateError);
    });

    test('Disposable dispose is idempotent via its store', () {
      final d = lsp.Disposable();
      d.dispose();
      d.dispose(); // no throw — underlying store dispose is idempotent
    });
  });

  group('batch29 / editorWorkerHost', () {
    test('setChannel/getChannel use CHANNEL_NAME', () {
      final server = _FakeServer();
      final host = _FakeWorkerHost();
      ewh.EditorWorkerHost.setChannel(_FakeServerClient(server), host);
      expect(server.channels[ewh.EditorWorkerHost.CHANNEL_NAME], same(host));
      // getChannel on the server side reads back what the client set.
      expect(ewh.EditorWorkerHost.getChannel(server), same(host));
    });
  });

  group('batch29 / minimapCharRendererFactory', () {
    test('create caches by scale and font family', () {
      final r1 = mcf.MinimapCharRendererFactory.create(1, 'monospace');
      final r2 = mcf.MinimapCharRendererFactory.create(1, 'monospace');
      expect(identical(r1, r2), isTrue);
      final r3 = mcf.MinimapCharRendererFactory.create(1, 'serif');
      expect(identical(r1, r3), isFalse);
    });

    test('createSampleData paints every char code and sets font', () {
      final canvas = _RecordingCanvas2D();
      mcf.createMinimapCanvas = () => mcf.MinimapCanvas(canvas);
      final image = mcf.MinimapCharRendererFactory.createSampleData('Arial');
      expect(canvas.lastFill, '#ffffff');
      expect(canvas.lastBaseline, 'middle');
      expect(canvas.lastFont, contains('Arial'));
      expect(canvas.glyphs.length, greaterThan(90));
      expect(canvas.xs.first, 0);
      expect(image.data.length, greaterThan(0));
    });

    test('createFromSampleData rejects wrong length', () {
      expect(
        () => mcf.MinimapCharRendererFactory.createFromSampleData(
          Uint8List(4),
          1,
        ),
        throwsStateError,
      );
    });

    test('createFromSampleData builds a renderer from correct-length data', () {
      const int len = 16 * 10 * 4 * 96;
      final data = Uint8List(len);
      for (int i = 0; i < len; i += 4) {
        data[i] = 255;
        data[i + 3] = 255;
      }
      final r = mcf.MinimapCharRendererFactory.createFromSampleData(data, 1);
      expect(r.scale, 1);
      expect(r.charDataNormal.length, greaterThan(0));
    });
  });

  group('batch29 / marked declarations', () {
    test('token carriers expose source type discriminants', () {
      expect(marked.TokensSpace().type, 'space');
      expect(marked.TokensCode().type, 'code');
      expect(marked.TokensHeading().type, 'heading');
      expect(marked.TokensLink().type, 'link');
      expect(marked.TokensGeneric()['x'], isNull);
    });

    test('TokensList is a list with a links map', () {
      final list = marked.TokensList(<Object?>['a', 'b']);
      expect(list.length, 2);
      expect(list[0], 'a');
      list.add('c');
      expect(list.length, 3);
      list.links['k'] = <String, Object?>{'href': 'v'};
      expect(list.links['k']!['href'], 'v');
    });

    test('regex tables and merged namespace carriers exist', () {
      expect(marked.block.normal, isA<Map<String, RegExp>>());
      expect(marked.inline.gfm, isA<Map<String, RegExp>>());
      expect(marked.marked.call('x'), isA<String>());
      expect(marked.getDefaults(), isA<marked.MarkedOptions>());
    });
  });
}

/// Helper: wrap a callback into an IDisposable without importing lifecycle's
/// `toDisposable` (which has a different type in this standalone LSP copy).
class _FnDisposable extends lsp.IDisposable {
  _FnDisposable(this._fn);
  final void Function() _fn;
  @override
  void dispose() => _fn();
}

lsp.IDisposable toDisposeTest(void Function() fn) => _FnDisposable(fn);


/// A client that forwards channel writes to the given server.
class _FakeServerClient extends _FakeClient {
  _FakeServerClient(this._server);
  final _FakeServer _server;
  @override
  void setChannel(String channel, Object handler) =>
      _server.setChannel(channel, handler);
}
