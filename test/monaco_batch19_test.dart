import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/loggingTimeApi.dart'
    as logApi;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/timeApi.dart'
    as api;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/trace.dart'
    as trace;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/atlas.dart'
    as atlas;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/rectangleRenderer.wgsl.dart'
    as wgsl;
import 'package:semi_design_flutter/src/monaco/editor/common/standaloneStrings.dart'
    as strings;

/// A minimal in-memory TimeApi for testing the logging wrapper.
class _FakeTimeApi implements api.TimeApi {
  final List<String> calls = <String>[];

  @override
  api.TimeoutId setTimeout(void Function() handler, [int timeout = 0]) {
    calls.add('setTimeout:$timeout');
    return api.TimeoutId(1);
  }

  @override
  void clearTimeout(api.TimeoutId id) => calls.add('clearTimeout');

  @override
  api.IntervalId setInterval(void Function() handler, int interval) {
    calls.add('setInterval:$interval');
    return api.IntervalId(2);
  }

  @override
  void clearInterval(api.IntervalId id) => calls.add('clearInterval');

  @override
  api.ImmediateId? Function(void Function() handler)? get setImmediate =>
      (void Function() handler) {
        calls.add('setImmediate');
        return api.ImmediateId(3);
      };

  @override
  void Function(api.ImmediateId id)? get clearImmediate =>
      (api.ImmediateId id) => calls.add('clearImmediate');

  @override
  api.AnimationFrameId? Function(void Function(num time) cb)?
      get requestAnimationFrame => (void Function(num time) cb) {
            calls.add('requestAnimationFrame');
            return api.AnimationFrameId(4);
          };

  @override
  void Function(api.AnimationFrameId id)? get cancelAnimationFrame =>
      (api.AnimationFrameId id) => calls.add('cancelAnimationFrame');

  @override
  DateTime Function() get Date => () => DateTime(2020);

  @override
  num Function() get performanceNow => () => 42;

  @override
  num get performanceTimeOrigin => 7;
}

void main() {
  group('batch19 · atlas', () {
    test('UsagePreviewColors matches source hex values', () {
      expect(atlas.UsagePreviewColors.Unused, '#808080');
      expect(atlas.UsagePreviewColors.Used, '#4040FF');
      expect(atlas.UsagePreviewColors.Wasted, '#FF0000');
      expect(atlas.UsagePreviewColors.Restricted, '#FF000088');
    });

    test('GlyphMap stores by 4-key tuple and retrieves', () {
      final atlas.GlyphMap<String> map = atlas.GlyphMap<String>();
      map.set('glyph', <Object>['ab', 3, 4, 'cache-key']);
      expect(map.get(<Object>['ab', 3, 4, 'cache-key']), 'glyph');
      expect(map.get(<Object>['ab', 3, 4, 'other']), isNull);
    });

    test('TextureAtlasPageGlyph carrier preserves all fields', () {
      final atlas.ITextureAtlasPageGlyph g = atlas.TextureAtlasPageGlyph(
        pageIndex: 1,
        glyphIndex: 2,
        x: 3,
        y: 4,
        w: 5,
        h: 6,
        originOffsetX: 7,
        originOffsetY: 8,
        fontBoundingBoxAscent: 9,
        fontBoundingBoxDescent: 10,
      );
      expect(g.pageIndex, 1);
      expect(g.glyphIndex, 2);
      expect(g.x, 3);
      expect(g.y, 4);
      expect(g.w, 5);
      expect(g.h, 6);
      expect(g.originOffsetX, 7);
      expect(g.originOffsetY, 8);
      expect(g.fontBoundingBoxAscent, 9);
      expect(g.fontBoundingBoxDescent, 10);
    });

    test('Blob carrier wraps opaque handle', () {
      final Object handle = Object();
      expect(atlas.Blob(handle).handle, same(handle));
    });
  });

  group('batch19 · rectangleRenderer.wgsl', () {
    test('binding ids', () {
      expect(wgsl.RectangleRendererBindingId.Shapes, 0);
      expect(wgsl.RectangleRendererBindingId.LayoutInfoUniform, 1);
      expect(wgsl.RectangleRendererBindingId.ScrollOffset, 2);
    });

    test('wgsl source contains interpolated bindings and shader stages', () {
      expect(wgsl.rectangleRendererWgsl,
          contains('var<uniform>       layoutInfo'));
      expect(wgsl.rectangleRendererWgsl,
          contains('var<storage, read> shapes'));
      expect(wgsl.rectangleRendererWgsl,
          contains('var<uniform>       scrollOffset'));
      expect(wgsl.rectangleRendererWgsl, contains('@vertex fn vs('));
      expect(wgsl.rectangleRendererWgsl, contains('@fragment fn fs('));
    });
  });

  group('batch19 · standaloneStrings', () {
    test('namespace constants localize to source messages', () {
      expect(strings.AccessibilityHelpNLS.accessibilityHelpTitle,
          'Accessibility Help');
      expect(strings.AccessibilityHelpNLS.readonlyEditor,
          'You are in a read-only code editor.');
      expect(strings.InspectTokensNLS.inspectTokensAction,
          'Developer: Inspect Tokens');
      expect(strings.GoToLineNLS.gotoLineActionLabel, 'Go to Line/Column...');
      expect(strings.QuickCommandNLS.quickCommandActionLabel, 'Command Palette');
      expect(strings.StandaloneCodeEditorNLS.editorViewAccessibleLabel,
          'Editor content');
      expect(strings.ToggleHighContrastNLS.toggleHighContrast,
          'Toggle High Contrast Theme');
      expect(strings.StandaloneServicesNLS.bulkEditServiceSummary,
          'Made {0} edits in {1} files');
    });

    test('keybinding arguments are interpolated into {0}/{1}', () {
      expect(
        strings.AccessibilityHelpNLS.tabFocusModeOnMsg,
        'Pressing Tab in the current editor will move focus to the next '
        'focusable element. Toggle this behavior'
        '<keybinding:editor.action.toggleTabFocusMode>.',
      );
      expect(
        strings.AccessibilityHelpNLS.toggleSuggestionFocus,
        contains('<keybinding:focusSuggestion>'),
      );
      expect(
        strings.AccessibilityHelpNLS.toggleSuggestionFocus,
        contains('<keybinding:toggleSuggestionFocus>'),
      );
      expect(
        strings.AccessibilityHelpNLS.chatEditActions,
        contains('<keybinding:chatEditor.action.acceptAllEdits>'),
      );
    });
  });

  group('batch19 · trace', () {
    test('child chain root/depth/describe', () {
      final trace.Trace root = trace.createTraceRoot('root');
      final trace.Trace child = root.child('child');
      final trace.Trace grand = child.child('grand');

      expect(grand.parent, same(child));
      expect(grand.root, same(root));
      expect(grand.depth, 2);
      expect(root.depth, 0);
      expect(grand.describe(), contains('#'));
      expect(grand.describe(), contains('grand'));
      expect(grand.describe(), contains(' \u2190 '));
      expect(grand.toString(), grand.describe());
    });

    test('ROOT_TRACE is a root with label <root>', () {
      expect(trace.ROOT_TRACE.label, '<root>');
      expect(trace.ROOT_TRACE.parent, isNull);
      expect(trace.ROOT_TRACE.root, same(trace.ROOT_TRACE));
      final trace.Trace x = trace.createTraceRoot('x');
      expect(x.parent, isNull);
      expect(x.root, same(x));
    });

    test('stack getter handles string and CapturedStack', () {
      final trace.Trace a = trace.Trace(null, 'a', 'stack-str');
      expect(a.stack, 'stack-str');
      final trace.Trace b =
          trace.Trace(null, 'b', const trace.CapturedStack('captured'));
      expect(b.stack, 'captured');
      expect(trace.Trace(null, 'c').stack, isNull);
    });

    test('TraceContext.runWithTrace installs and restores, nestable', () {
      final trace.TraceContext ctx = trace.TraceContext();
      final trace.Trace a = trace.createTraceRoot('a');
      final trace.Trace b = trace.createTraceRoot('b');
      expect(ctx.currentTrace(), same(trace.ROOT_TRACE));

      final int result = ctx.runWithTrace<int>(a, () {
        expect(ctx.currentTrace(), same(a));
        return ctx.runWithTrace<int>(b, () {
          expect(ctx.currentTrace(), same(b));
          return 7;
        });
      });
      expect(result, 7);
      expect(ctx.currentTrace(), same(trace.ROOT_TRACE));
    });

    test('runAsHandler defers reset via sink and guards reentry', () {
      final trace.TraceContext ctx = trace.TraceContext();
      final List<void Function()> sinks = <void Function()>[];
      final trace.RunAsHandlerOptions options = (void Function() reset) {
        sinks.add(reset);
      };
      final trace.Trace t = trace.createTraceRoot('handler');

      final int value = ctx.runAsHandler<int>(t, () {
        expect(ctx.currentTrace(), same(t));
        return 9;
      }, options);
      expect(value, 9);
      // Reset is deferred; still current until sink fires.
      expect(ctx.currentTrace(), same(t));
      expect(sinks.length, 1);
      sinks.first();
      expect(ctx.currentTrace(), same(trace.ROOT_TRACE));
    });

    test('runAsHandler rejects re-entrant invocation', () {
      final trace.TraceContext ctx = trace.TraceContext();
      final trace.Trace t = trace.createTraceRoot('t');
      expect(
        () => ctx.runAsHandler<int>(t, () {
          return ctx.runAsHandler<int>(t, () => 1, (void Function() r) {});
        }, (void Function() r) {}),
        throwsA(isA<StateError>()),
      );
      ctx.resetForTesting();
      expect(ctx.currentTrace(), same(trace.ROOT_TRACE));
    });
  });

  group('batch19 · loggingTimeApi', () {
    test('wraps timer registration calls and delegates', () {
      final _FakeTimeApi underlying = _FakeTimeApi();
      final List<String> names = <String>[];
      final api.TimeApi logging = logApi.createLoggingTimeApi(
        underlying,
        (String name, String? stack, [Object? handler]) {
          names.add(name);
        },
      );

      logging.setTimeout(() {}, 5);
      logging.clearTimeout(api.TimeoutId(1));
      logging.setInterval(() {}, 10);
      logging.clearInterval(api.IntervalId(2));
      logging.setImmediate!(() {});
      logging.clearImmediate!(api.ImmediateId(3));
      logging.requestAnimationFrame!((num t) {});
      logging.cancelAnimationFrame!(api.AnimationFrameId(4));

      expect(
        names,
        <String>[
          'setTimeout',
          'setInterval',
          'setImmediate',
          'requestAnimationFrame'
        ],
      );
      expect(
        underlying.calls,
        <String>[
          'setTimeout:5',
          'clearTimeout',
          'setInterval:10',
          'clearInterval',
          'setImmediate',
          'clearImmediate',
          'requestAnimationFrame',
          'cancelAnimationFrame'
        ],
      );
    });

    test('passes stack and handler to onCall', () {
      final _FakeTimeApi underlying = _FakeTimeApi();
      String? capturedStack;
      Object? capturedHandler;
      final void Function() handler = () {};
      logApi.debugStackProvider = () => 'the-stack';
      final api.TimeApi logging = logApi.createLoggingTimeApi(
        underlying,
        (String name, String? stack, [Object? h]) {
          capturedStack = stack;
          capturedHandler = h;
        },
      );
      logging.setTimeout(handler, 0);
      expect(capturedStack, 'the-stack');
      expect(capturedHandler, same(handler));
      logApi.debugStackProvider = () => null;
    });

    test('passes through fields when optional APIs absent', () {
      final _FakeTimeApi underlying = _FakeTimeApi();
      final api.TimeApi logging = logApi.createLoggingTimeApi(
        underlying,
        (String name, String? stack, [Object? h]) {},
      );
      expect(logging.Date(), DateTime(2020));
      expect(logging.performanceNow(), 42);
      expect(logging.performanceTimeOrigin, 7);
      expect(logging.setImmediate, isNotNull);
      expect(logging.requestAnimationFrame, isNotNull);
    });
  });
}
