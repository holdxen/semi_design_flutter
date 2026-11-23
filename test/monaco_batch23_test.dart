import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/ui/contextview/windowControlsOverlay.dart'
    as wco;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as life;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/base/test/common/mock.dart' as mock;
import 'package:semi_design_flutter/src/monaco/base/test/common/utils.dart' as utils;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/recordingTimeApi.dart'
    as rec;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/runWithFakedTimers.dart'
    as rwft;
import 'package:semi_design_flutter/src/monaco/editor/test/common/modes/supports/indentationRules.dart'
    as indent;

// ---------------------------------------------------------------------------
// indentationRules
// ---------------------------------------------------------------------------

void main() {
  group('batch23 / indentationRules', () {
    test('javascript patterns are present and match/decline', () {
      final r = indent.javascriptIndentationRules;
      expect(r.decreaseIndentPattern, isNotNull);
      expect(r.increaseIndentPattern, isNotNull);
      expect(r.unIndentedLinePattern, isNotNull);
      expect(r.indentNextLinePattern, isNotNull);
      expect(r.decreaseIndentPattern!.hasMatch('  }'), isTrue);
      expect(r.decreaseIndentPattern!.hasMatch('  const x = 1;'), isFalse);
      expect(r.increaseIndentPattern!.hasMatch('function f() {'), isTrue);
      expect(r.indentNextLinePattern!.hasMatch('if (x)'), isTrue);
    });

    test('all eight language rule sets are defined', () {
      expect(indent.javascriptIndentationRules, isNotNull);
      expect(indent.rubyIndentationRules.decreaseIndentPattern, isNotNull);
      expect(indent.phpIndentationRules.increaseIndentPattern, isNotNull);
      expect(indent.goIndentationRules.decreaseIndentPattern, isNotNull);
      expect(indent.htmlIndentationRules.increaseIndentPattern, isNotNull);
      expect(indent.latexIndentationRules.increaseIndentPattern, isNotNull);
      expect(indent.luaIndentationRules.decreaseIndentPattern, isNotNull);
      expect(indent.vbIndentationRules.decreaseIndentPattern, isNotNull);
    });

    test('latex / html / ruby rules match representative lines', () {
      expect(
          indent.latexIndentationRules.decreaseIndentPattern!.hasMatch(r'\end{itemize}'),
          isTrue);
      expect(
          indent.latexIndentationRules.decreaseIndentPattern!.hasMatch(r'\end{document}'),
          isFalse);
      expect(
          indent.htmlIndentationRules.decreaseIndentPattern!.hasMatch('</div>'),
          isTrue);
      expect(
          indent.rubyIndentationRules.decreaseIndentPattern!.hasMatch('  end'),
          isTrue);
      // vb rules are case-insensitive (source `/i`).
      expect(
          indent.vbIndentationRules.decreaseIndentPattern!.hasMatch('  End If'),
          isTrue);
      expect(
          indent.vbIndentationRules.decreaseIndentPattern!.hasMatch('  end if'),
          isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // windowControlsOverlay
  // -------------------------------------------------------------------------

  group('batch23 / windowControlsOverlay', () {
    wco.IWindowControlsOverlayPosition pos(num t, num l) =>
        wco.WindowControlsOverlayPosition(top: t, left: l);

    test('returns the same position when overlay absent', () {
      final p = pos(10, 20);
      expect(
        identical(
          wco.avoidWindowControlsOverlay(
            null,
            wco.WindowControlsOverlayViewport(
                top: 0, left: 0, width: 1000, height: 800),
            wco.WindowControlsOverlaySize(width: 100, height: 30),
            p,
          ),
          p,
        ),
        isTrue,
      );
    });

    test('returns same position with non-finite values or non-positive height', () {
      final viewport = wco.WindowControlsOverlayViewport(
          top: 0, left: 0, width: 1000, height: 800);
      final view = wco.WindowControlsOverlaySize(width: 100, height: 30);
      final p = pos(10, 20);
      expect(
        identical(
          wco.avoidWindowControlsOverlay(
            wco.WindowControlsOverlayTitlebarRect(
                x: double.nan, y: 0, width: 100, height: 40),
            viewport,
            view,
            p,
          ),
          p,
        ),
        isTrue,
      );
      expect(
        identical(
          wco.avoidWindowControlsOverlay(
            wco.WindowControlsOverlayTitlebarRect(
                x: 0, y: 0, width: 100, height: 0),
            viewport,
            view,
            p,
          ),
          p,
        ),
        isTrue,
      );
    });

    test('pushes view below the band when it fits', () {
      // band height = min(40, 800) = 40; bandBottom = 0 + 40 = 40.
      // bandBottom + view.height (40+30=70) <= 0 + 800 => push down.
      final result = wco.avoidWindowControlsOverlay(
        wco.WindowControlsOverlayTitlebarRect(
            x: 400, y: 0, width: 200, height: 40),
        wco.WindowControlsOverlayViewport(
            top: 0, left: 0, width: 1000, height: 800),
        wco.WindowControlsOverlaySize(width: 100, height: 30),
        pos(0, 10), // overlaps left strip [0,400)
      );
      expect(result.top, 40);
      expect(result.left, 10);
    });

    test('no overlap leaves position unchanged', () {
      final p = pos(200, 500); // not in the titlebar band at all
      final result = wco.avoidWindowControlsOverlay(
        wco.WindowControlsOverlayTitlebarRect(
            x: 400, y: 0, width: 200, height: 40),
        wco.WindowControlsOverlayViewport(
            top: 0, left: 0, width: 1000, height: 800),
        wco.WindowControlsOverlaySize(width: 100, height: 30),
        p,
      );
      expect(identical(result, p), isTrue);
    });

    test('shifts horizontally clear of a single strip when it cannot fit below', () {
      // bandBottom (40) + view.height (770) = 810 > 800, so step 1 fails.
      // left strip [0, 400); view width 100; overlap at left=10.
      // Shift to strip.end = 400, fits [400, 500] within [0, 1000].
      final result = wco.avoidWindowControlsOverlay(
        wco.WindowControlsOverlayTitlebarRect(
            x: 400, y: 0, width: 200, height: 40),
        wco.WindowControlsOverlayViewport(
            top: 0, left: 0, width: 1000, height: 800),
        wco.WindowControlsOverlaySize(width: 100, height: 770),
        pos(0, 10),
      );
      expect(result.top, 0);
      expect(result.left, 400);
    });
  });

  // -------------------------------------------------------------------------
  // mock
  // -------------------------------------------------------------------------

  group('batch23 / mock', () {
    test('mock() returns a callable empty constructor', () {
      final ctor = mock.mock<Object>();
      final instance = ctor();
      expect(instance, isA<Object>());
    });

    test('SinonStub tracks calls and applies returns/callsFake/throws', () {
      final s = mock.SinonStub();
      expect(s.callCount, 0);
      expect(s.call(1, 2), isNull);
      expect(s.callCount, 1);
      expect(s.firstArg, 1);

      s.returns(42);
      expect(s.call('x'), 42);

      s.callsFake((args) => (args[0] as int) * 2);
      expect(s.call(5), 10);

      s.throws(StateError('boom'));
      expect(() => s.call(), throwsStateError);
    });

    test('mockObject proxy lazily creates stubs and honors explicit properties', () {
      final factory = mock.mockObject<Map<String, Object?>>();
      final dynamic obj = factory({'name': 'fixed'});
      expect(obj['name'], 'fixed');
      expect(obj.hasOwnProperty('name'), isTrue);
      expect(obj.hasOwnProperty('foo'), isFalse);

      final first = obj['foo'];
      expect(first, isA<mock.SinonStub>());
      expect(obj.hasOwnProperty('foo'), isTrue);
      expect(identical(obj['foo'], first), isTrue);

      obj['foo'] = 'overwritten';
      expect(obj['foo'], 'overwritten');
    });

    test('upcast helpers cast through', () {
      final Object partial = <String, Object?>{'a': 1};
      expect(mock.upcastPartial<Map<String, Object?>>(partial)['a'], 1);
      expect(mock.upcastDeepPartial<Map<String, Object?>>(partial)['a'], 1);
    });
  });

  // -------------------------------------------------------------------------
  // runWithFakedTimers
  // -------------------------------------------------------------------------

  group('batch23 / runWithFakedTimers', () {
    test('bypass path (useFakeTimers=false) runs fn and returns its value',
        () async {
      final value = await rwft.runWithFakedTimers<int>(
        const rwft.RunWithFakedTimersOptions(useFakeTimers: false),
        () async => 7,
      );
      expect(value, 7);
    });

    test('bypass path collects history through recording API when onHistory set',
        () async {
      List<rec.RecordedTimerEvent>? captured;
      final value = await rwft.runWithFakedTimers<int>(
        rwft.RunWithFakedTimersOptions(
          useFakeTimers: false,
          onHistory: (h) => captured = h,
        ),
        () async => 9,
      );
      expect(value, 9);
      expect(captured, isNotNull);
    });

    test('virtual path resolves fn result and drains the queue', () async {
      final value = await rwft.runWithFakedTimers<String>(
        const rwft.RunWithFakedTimersOptions(),
        () async => 'ok',
      );
      expect(value, 'ok');
    });

    test('virtual path rethrows fn error without surfacing a drain rejection',
        () async {
      expect(
        () => rwft.runWithFakedTimers<int>(
          const rwft.RunWithFakedTimersOptions(),
          () async => throw StateError('fn failed'),
        ),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'fn failed')),
      );
    });

    test('onHistory is invoked on the virtual path', () async {
      int calls = 0;
      await rwft.runWithFakedTimers<int>(
        rwft.RunWithFakedTimersOptions(onHistory: (_) => calls++),
        () async => 1,
      );
      expect(calls, 1);
    });
  });

  // -------------------------------------------------------------------------
  // utils
  // -------------------------------------------------------------------------

  group('batch23 / test utils', () {
    tearDown(() {
      utils.mochaSuite = null;
      utils.mochaTest = null;
      utils.mochaSetup = null;
      utils.mochaTeardown = null;
      utils.btoaFn = (s) => s;
      utils.consoleErrorFn = (_) {};
    });

    test('assertThrowsAsync passes when block throws and fails otherwise',
        () async {
      await expectLater(
        utils.assertThrowsAsync(() async => throw StateError('x')),
        completes,
      );
      await expectLater(
        utils.assertThrowsAsync(() async => null, 'expected boom'),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'expected boom')),
      );
    });

    test('suiteRepeat and testRepeat honor n and iteration labels', () {
      final suites = <String>[];
      final tests = <String>[];
      utils.mochaSuite = (d, cb) => suites.add(d);
      utils.mochaTest = (d, cb) => tests.add(d);
      utils.suiteRepeat(3, 'suite', () {});
      utils.testRepeat(2, 'case', () => null);
      expect(suites, [
        'suite (iteration 0)',
        'suite (iteration 1)',
        'suite (iteration 2)',
      ]);
      expect(tests, ['case (iteration 0)', 'case (iteration 1)']);
    });

    test('toResource builds a file URI from the btoa-encoded full title', () {
      utils.btoaFn = (s) => 'ENC';
      final r = utils.toResource(
        utils.MochaThis(utils.TestContext(() => 'My Test')),
        'file.txt',
      );
      final String path = r.path;
      expect(path.endsWith('/ENC/file.txt'), isTrue);
      expect(r, isA<uri.URI>());
    });

    test('throwIfDisposablesAreLeaked throws on an undisposed disposable', () {
      utils.consoleErrorFn = (_) {};
      expect(
        () => utils.throwIfDisposablesAreLeaked(() {
          final d = life.toDisposable(() {});
          // Register it with the active tracker by touching the store path.
          final store = life.DisposableStore();
          store.add(d);
          // Deliberately do not dispose `store`.
        }, false),
        throwsA(isA<StateError>()),
      );
      // Reset the tracker so subsequent tests are not polluted.
      life.setDisposableTracker(null);
    });

    test('throwIfDisposablesAreLeakedAsync completes when nothing leaks',
        () async {
      await utils.throwIfDisposablesAreLeakedAsync(() async {});
      life.setDisposableTracker(null);
    });
  });
}
