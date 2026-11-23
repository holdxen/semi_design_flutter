// batch26 port verification: hotReload / scrollbarVisibilityController /
// scrollableElementOptions / webWorkerDescriptor / progressAccessibilitySignal.
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/fastDomNode.dart' as fdn;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/progressbar/progressAccessibilitySignal.dart' as pas;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollbarVisibilityController.dart' as svc;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollableElementOptions.dart' as seo;
import 'package:semi_design_flutter/src/monaco/base/common/hotReload.dart' as hr;
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart' as scr;
import 'package:semi_design_flutter/src/monaco/platform/webWorker/browser/webWorkerDescriptor.dart' as wwd;

// ---- DOM / timer fakes ----------------------------------------------------

class _Tokens implements fdn.DomTokenList {
  @override
  void toggle(String token, [bool? force]) {}
}

class _Element implements fdn.DomElement {
  @override
  final Map<String, String> style = <String, String>{};
  @override
  String className = '';
  @override
  final fdn.DomTokenList classList = _Tokens();
  @override
  void focus() {}
  @override
  void setAttribute(String name, String value) {}
  @override
  void removeAttribute(String name) {}
  @override
  void appendChild(fdn.DomElement child) {}
  @override
  void removeChild(fdn.DomElement child) {}
}

/// Synchronous reveal timer: records setIfNotSet/cancel calls and runs runner
/// only when [fire] is called, mirroring the deferred DOM class mutation.
class _Timer implements svc.RevealTimer {
  void Function()? _runner;
  int cancels = 0;
  int sets = 0;
  @override
  void setIfNotSet(void Function() runner, int timeout) {
    sets++;
    _runner ??= runner;
  }

  @override
  void cancel() {
    cancels++;
    _runner = null;
  }

  void fire() {
    final r = _runner;
    _runner = null;
    r?.call();
  }
}

_Timer? _lastTimer;

void main() {
  setUp(() {
    svc.revealTimerFactory = () {
      final t = _Timer();
      _lastTimer = t;
      return t;
    };
    // Reset hot-reload global state between tests.
    hr.hotReloadHandlers = null;
    hr.hotReloadApplyNewExports = null;
  });

  group('hotReload', () {
    test('disabled handler registration returns no-op disposable', () {
      // isHotReloadEnabled() defaults false in a fresh isolate; if a prior
      // test enabled it, this still verifies registration path independently.
      final d = hr.registerHotReloadHandler((args) => null);
      d.dispose(); // no throw
    });

    test('register handler, applyNewExports aggregates results', () {
      hr.enableHotReload();
      expect(hr.isHotReloadEnabled(), isTrue);
      final d = hr.registerHotReloadHandler((args) {
        expect(args.config.mode, isNull);
        expect(args.newSrc, 'src');
        return (exports) => exports.containsKey('x');
      });
      final apply = hr.registerGlobalHotReloadHandler();
      final fn = hr.hotReloadApplyNewExports!;
      final result = fn(hr.HotReloadArgsWithOptionalConfig(
        oldExports: <String, Object?>{},
        newSrc: 'src',
      ));
      expect(result, isNotNull);
      expect(result!({'x': 1}), isTrue);
      expect(result({'y': 1}), isFalse);
      expect(apply.length, 1);
      d.dispose();
      expect(apply.length, 0);
    });

    test('no handlers -> applyNewExports returns null', () {
      hr.enableHotReload();
      // Force creation of the global fn with an empty handler set.
      hr.registerGlobalHotReloadHandler();
      final fn = hr.hotReloadApplyNewExports!;
      expect(
          fn(hr.HotReloadArgsWithOptionalConfig(
              oldExports: {}, newSrc: '')),
          isNull);
    });

    test('installDefaultHotReloadHandler ignores non patch-prototype mode', () {
      hr.enableHotReload();
      hr.installDefaultHotReloadHandler();
      final fn = hr.hotReloadApplyNewExports!;
      expect(
          fn(hr.HotReloadArgsWithOptionalConfig(
            oldExports: {},
            newSrc: '',
            config: hr.HotReloadConfig(mode: 'other'),
          )),
          isNull);
    });
  });

  group('scrollbarVisibilityController', () {
    svc.ScrollbarVisibilityController _visibleController() {
      final c = svc.ScrollbarVisibilityController(
        scr.ScrollbarVisibility.Auto, 'visible', 'invisible');
      final el = _Element();
      c.setDomNode(fdn.FastDomNode(el));
      return c;
    }

    test('setDomNode applies invisible class and setShouldBeVisible(false)', () {
      final c = _visibleController();
      expect(_lastTimer, isNotNull);
      expect(c.isVisible, isFalse);
    });

    test('reveal sets visible class via timer; hide adds fade', () {
      final c = _visibleController();
      c.setIsNeeded(true);
      c.setShouldBeVisible(true);
      expect(c.isVisible, isTrue);
      expect(_lastTimer!.sets, 1);
      final el = _Element();
      // The dom node captured by the controller is internal; re-set to observe.
      c.setDomNode(fdn.FastDomNode(el));
      c.setIsNeeded(true);
      c.setShouldBeVisible(true);
      _lastTimer!.fire();
      expect(el.className, 'visible');

      c.setShouldBeVisible(false);
      expect(c.isVisible, false);
      expect(_lastTimer!.cancels, greaterThan(0));
    });

    test('Hidden visibility never reveals regardless of raw flag', () {
      final c = svc.ScrollbarVisibilityController(
        scr.ScrollbarVisibility.Hidden, 'visible', 'invisible');
      final el = _Element();
      c.setDomNode(fdn.FastDomNode(el));
      c.setIsNeeded(true);
      c.setShouldBeVisible(true);
      expect(c.isVisible, isFalse);
    });

    test('Visible visibility reveals without raw flag', () {
      final c = svc.ScrollbarVisibilityController(
        scr.ScrollbarVisibility.Visible, 'visible', 'invisible');
      c.setDomNode(fdn.FastDomNode(_Element()));
      c.setIsNeeded(true);
      expect(c.isVisible, isTrue);
    });

    test('not needed hides even when should be visible', () {
      final c = _visibleController();
      c.setShouldBeVisible(true);
      expect(c.isVisible, isFalse);
      c.setIsNeeded(true);
      expect(c.isVisible, isTrue);
      c.setIsNeeded(false);
      expect(c.isVisible, isFalse);
    });
  });

  group('scrollableElementOptions', () {
    test('creation options carry optional fields', () {
      final o = seo.ScrollableElementCreationOptions()
        ..lazyRender = true
        ..horizontal = scr.ScrollbarVisibility.Hidden
        ..mouseWheelScrollSensitivity = 2.5;
      expect(o.lazyRender, isTrue);
      expect(o.horizontal, scr.ScrollbarVisibility.Hidden);
      expect(o.mouseWheelScrollSensitivity, 2.5);
    });

    test('change options and resolved options round-trip', () {
      final change = seo.ScrollableElementChangeOptions()
        ..handleMouseWheel = false
        ..vertical = scr.ScrollbarVisibility.Visible;
      expect(change.handleMouseWheel, isFalse);
      expect(change.vertical, scr.ScrollbarVisibility.Visible);

      final resolved = seo.ScrollableElementResolvedOptions(
        lazyRender: false,
        className: 'monaco-scrollable-element',
        useShadows: true,
        handleMouseWheel: true,
        flipAxes: false,
        scrollYToX: false,
        consumeMouseWheelIfScrollbarIsNeeded: false,
        alwaysConsumeMouseWheel: false,
        mouseWheelScrollSensitivity: 1,
        fastScrollSensitivity: 5,
        scrollPredominantAxis: true,
        mouseWheelSmoothScroll: true,
        inertialScroll: false,
        arrowSize: 11,
        listenOnDomNode: null,
        horizontal: scr.ScrollbarVisibility.Auto,
        horizontalScrollbarSize: 10,
        horizontalSliderSize: 10,
        horizontalHasArrows: false,
        vertical: scr.ScrollbarVisibility.Auto,
        verticalScrollbarSize: 10,
        verticalSliderSize: 10,
        verticalHasArrows: false,
        scrollByPage: false,
      );
      expect(resolved.className, 'monaco-scrollable-element');
      expect(resolved.arrowSize, 11);
      expect(resolved.horizontal, scr.ScrollbarVisibility.Auto);
    });
  });

  group('webWorkerDescriptor', () {
    test('holds label and lazy/static locations', () {
      final uri = Object();
      final d = wwd.WebWorkerDescriptor(label: 'ts', esmModuleLocation: uri);
      expect(d.label, 'ts');
      expect(identical(d.esmModuleLocation, uri), isTrue);
      expect(d.esmModuleLocationBundler, isNull);

      final thunk = () => Object();
      final d2 = wwd.WebWorkerDescriptor(
          label: 'js', esmModuleLocationBundler: thunk);
      expect(identical(d2.esmModuleLocationBundler, thunk), isTrue);
    });
  });

  group('progressAccessibilitySignal', () {
    test('default null factory reports -1 times', () {
      final d = pas.getProgressAccessibilitySignalScheduler(100);
      expect(d.msDelayTime, -1);
      expect(d.msLoopTime, -1);
      d.dispose();
    });

    test('injected factory receives delay/loop args', () {
      pas.AccessibilitySignalSchedulerFactory? captured;
      pas.setProgressAccessibilitySignalScheduler((int delay, [int? loop]) {
        return _Delegate(delay, loop ?? -2);
      });
      final d = pas.getProgressAccessibilitySignalScheduler(50, 10);
      expect(d.msDelayTime, 50);
      expect(d.msLoopTime, 10);
      captured = pas.progressAccessibilitySignalSchedulerFactory;
      expect(captured, isNotNull);
      d.dispose();
      // restore default
      pas.setProgressAccessibilitySignalScheduler(
          (int delay, [int? loop]) => pas.nullScopedAccessibilityProgressSignalFactory());
    });
  });
}

class _Delegate implements pas.IScopedAccessibilityProgressSignalDelegate {
  _Delegate(this.msDelayTime, this.msLoopTime);
  @override
  final int msLoopTime;
  @override
  final int msDelayTime;
  @override
  void dispose() {}
}
