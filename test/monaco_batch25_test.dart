// batch25 port verification: keyboardEvent / mouseEvent / canIUse /
// trustedTypes / fonts — translated 1:1 from vscode/src/vs/base/browser.
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/browser.dart' as browser;
import 'package:semi_design_flutter/src/monaco/base/browser/canIUse.dart' as ciu;
import 'package:semi_design_flutter/src/monaco/base/browser/fonts.dart' as fonts;
import 'package:semi_design_flutter/src/monaco/base/browser/iframe.dart' as iframe;
import 'package:semi_design_flutter/src/monaco/base/browser/keyboardEvent.dart' as ke;
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart' as me;
import 'package:semi_design_flutter/src/monaco/base/browser/trustedTypes.dart' as tt;
import 'package:semi_design_flutter/src/monaco/base/common/keyCodes.dart' as kc;
import 'package:semi_design_flutter/src/monaco/base/common/keybindings.dart' as kb;

// ---- fakes ---------------------------------------------------------------

class _Frame implements iframe.IframeWindow {
  _Frame({this.parent, this.scrollY = 0, this.scrollX = 0});
  @override
  final iframe.IframeWindow? parent;
  @override
  final num scrollY;
  @override
  final num scrollX;
  @override
  iframe.IframeLocation get location => _Loc('https://example.test');
  @override
  iframe.IframeElement? get frameElement => null;
}

class _Loc implements iframe.IframeLocation {
  _Loc(this.origin);
  @override
  final String origin;
}

void main() {
  setUp(() {
    // Isolate browser-flag probes from the process-wide user-agent snapshot.
    ke.isFirefoxOverride = () => false;
    ke.isWebKitOverride = () => false;
    me.isFirefoxOverride = () => false;
    me.isChromeOverride = () => false;
    me.isSafariOverride = () => false;
    ciu.isStandaloneOverride = () => false;
    ciu.isSafariOverride = () => false;
    // Neutralize compile-time platform flags (test host is mac/native).
    ke.isMacintoshOverride = () => false;
    ke.isLinuxOverride = () => false;
    me.isMacintoshOverride = () => false;
    me.isWindowsOverride = () => false;
    ciu.isNativeOverride = () => false;
  });

  group('keyboardEvent', () {
    test('extractKeyCode uses charCode for keypress events', () {
      final e = ke.KeyboardEvent(charCode: 65, keyCode: 0); // 'A'
      expect(ke.extractKeyCode(e), kc.KeyCode.KeyA);
      final lower = ke.KeyboardEvent(charCode: 97, keyCode: 0); // 'a' -> upper
      expect(ke.extractKeyCode(lower), kc.KeyCode.KeyA);
    });

    test('extractKeyCode browser quirk keyCode 3 = PauseBreak', () {
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 3)), kc.KeyCode.PauseBreak);
    });

    test('extractKeyCode cross-browser map and unknown fallback', () {
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 13)), kc.KeyCode.Enter);
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 65)), kc.KeyCode.KeyA);
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 27)), kc.KeyCode.Escape);
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 9999)), kc.KeyCode.Unknown);
    });

    test('extractKeyCode Firefox quirks (59/107/109/173)', () {
      ke.isFirefoxOverride = () => true;
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 59)), kc.KeyCode.Semicolon);
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 107)), kc.KeyCode.NumpadAdd);
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 109)), kc.KeyCode.NumpadSubtract);
      expect(ke.extractKeyCode(ke.KeyboardEvent(keyCode: 173)), kc.KeyCode.Minus);
    });

    test('StandardKeyboardEvent computes keybinding and chord with modifiers', () {
      // Ctrl+A on non-Mac: modifier = CtrlCmd (2048), key = KeyA (31).
      final e = ke.StandardKeyboardEvent(ke.KeyboardEvent(
        keyCode: 65,
        ctrlKey: true,
        code: 'KeyA',
        key: 'a',
      ));
      expect(e.keyCode, kc.KeyCode.KeyA);
      expect(e.equals(kc.KeyMod.CtrlCmd | kc.KeyCode.KeyA), isTrue);
      expect(e.equals(0), isFalse);
      final chord = e.toKeyCodeChord();
      expect(chord, isA<kb.KeyCodeChord>());
      expect((chord as kb.KeyCodeChord).ctrlKey, isTrue);
      expect(chord.keyCode, kc.KeyCode.KeyA);
    });

    test('StandardKeyboardEvent normalizes modifier keys to themselves', () {
      // DOM keyCode 17 maps to internal KeyCode.Ctrl; with no flags ctrlKey
      // becomes true and the normalized key becomes Unknown.
      final e = ke.StandardKeyboardEvent(ke.KeyboardEvent(keyCode: 17));
      expect(e.ctrlKey, isTrue);
      expect(e.equals(kc.KeyMod.CtrlCmd), isTrue); // key=Unknown so no extra bits
    });

    test('StandardKeyboardEvent IME composition forces KEY_IN_COMPOSITION', () {
      final e = ke.StandardKeyboardEvent(ke.KeyboardEvent(
        keyCode: 65,
        isComposing: true,
      ));
      expect(e.keyCode, kc.KeyCode.KEY_IN_COMPOSITION);
    });

    test('altGraphKey reads getModifierState', () {
      final e = ke.StandardKeyboardEvent(ke.KeyboardEvent(
        keyCode: 65,
        getModifierState: (m) => m == 'AltGraph',
      ));
      expect(e.altGraphKey, isTrue);
      final e2 = ke.StandardKeyboardEvent(ke.KeyboardEvent(keyCode: 65));
      expect(e2.altGraphKey, isFalse);
    });

    test('preventDefault / stopPropagation call carrier fns', () {
      int prevented = 0, stopped = 0;
      final raw = ke.KeyboardEvent(
        keyCode: 65,
        preventDefaultFn: () => prevented++,
        stopPropagationFn: () => stopped++,
      );
      final e = ke.StandardKeyboardEvent(raw);
      e.preventDefault();
      e.stopPropagation();
      expect(prevented, 1);
      expect(stopped, 1);
    });

    test('print helpers and hasModifierKeys', () {
      final raw = ke.KeyboardEvent(
        keyCode: 65,
        code: 'KeyA',
        key: 'a',
        ctrlKey: true,
        shiftKey: true,
      );
      expect(ke.printKeyboardEvent(raw),
          'modifiers: [ctrl,shift], code: KeyA, keyCode: 65, key: a');
      final std = ke.StandardKeyboardEvent(raw);
      expect(ke.printStandardKeyboardEvent(std),
          contains('keyCode: 31 ('));
      expect(ke.hasModifierKeys(
          ctrlKey: false, shiftKey: false, altKey: false, metaKey: false), isFalse);
      expect(ke.hasModifierKeys(
          ctrlKey: false, shiftKey: false, altKey: false, metaKey: true), isTrue);
    });
  });

  group('mouseEvent', () {
    test('StandardMouseEvent button/detail/timestamp and iframe offset', () {
      // targetWindow and view are the same frame -> getPosition returns (0,0).
      final frame = _Frame();
      final e = me.StandardMouseEvent(frame, me.MouseEvent(
        button: 0,
        buttons: 1,
        detail: 0, // -> 1
        type: 'click',
        view: frame,
        pageX: 100,
        pageY: 200,
        ctrlKey: true,
      ));
      expect(e.leftButton, isTrue);
      expect(e.middleButton, isFalse);
      expect(e.rightButton, isFalse);
      expect(e.detail, 1);
      expect(e.posx, 100);
      expect(e.posy, 200);
      expect(e.ctrlKey, isTrue);
      expect(e.timestamp, greaterThan(0));
    });

    test('StandardMouseEvent dblclick forces detail=2', () {
      final frame = _Frame();
      final e = me.StandardMouseEvent(frame, me.MouseEvent(
        type: 'dblclick', detail: 1, view: frame,
      ));
      expect(e.detail, 2);
    });

    test('DragMouseEvent carries dataTransfer', () {
      final frame = _Frame();
      final dt = Object();
      final e = me.DragMouseEvent(frame, me.MouseEvent(view: frame, dataTransfer: dt));
      expect(identical(e.dataTransfer, dt), isTrue);
    });

    test('StandardWheelEvent webkit wheelDeltaY / 120', () {
      final e = me.StandardWheelEvent(me.MouseEvent(wheelDeltaY: 240));
      expect(e.deltaY, 2.0);
      expect(e.deltaX, 0);
    });

    test('StandardWheelEvent gecko vertical axis -> -detail/3', () {
      final e = me.StandardWheelEvent(me.MouseEvent(
        detail: 9,
        geckoVerticalAxis: 1,
        geckoAxis: 1,
      ));
      expect(e.deltaY, -3.0);
    });

    test('StandardWheelEvent modern wheel non-line -> -deltaY/40', () {
      final e = me.StandardWheelEvent(me.MouseEvent(
        type: 'wheel', deltaY: 80, deltaX: 40, deltaMode: 0,
      ));
      expect(e.deltaY, -2.0);
      expect(e.deltaX, -1.0);
    });

    test('StandardWheelEvent line mode, firefox non-mac -> -delta/3', () {
      me.isFirefoxOverride = () => true;
      final e = me.StandardWheelEvent(me.MouseEvent(
        type: 'wheel', deltaY: 9, deltaX: 6, deltaMode: 1, DOM_DELTA_LINE: 1,
      ));
      expect(e.deltaY, -3.0);
      expect(e.deltaX, -2.0);
    });

    test('StandardWheelEvent chrome<123 factors devicePixelRatio', () {
      me.isChromeOverride = () => true;
      me.userAgentProvider = () => 'Chrome/120.0';
      final e = me.StandardWheelEvent(me.MouseEvent(
        wheelDeltaY: 240, devicePixelRatio: 2,
      ));
      // 240 / (120 * 2) = 1.0
      expect(e.deltaY, 1.0);
      me.userAgentProvider = () => browser.userAgentProvider();
    });

    test('StandardWheelEvent wheelDelta fallback when deltas stayed zero', () {
      final e = me.StandardWheelEvent(me.MouseEvent(wheelDelta: 120));
      expect(e.deltaY, 1.0);
    });

    test('StandardWheelEvent null event -> zero deltas and null target', () {
      final e = me.StandardWheelEvent(null);
      expect(e.deltaY, 0);
      expect(e.deltaX, 0);
      expect(e.target, isNull);
    });
  });

  group('canIUse', () {
    test('clipboard writeText from queryCommandSupported / navigator', () {
      ciu.queryCommandSupportedProvider = (cmd) => cmd == 'copy';
      ciu.navigatorProvider = () => const ciu.NavigatorCapabilities(
        clipboardReadText: true,
      );
      final f = ciu.computeBrowserFeatures();
      expect(f.clipboard.writeText, isTrue);
      expect(f.clipboard.readText, isTrue);
      ciu.queryCommandSupportedProvider = null;
      ciu.navigatorProvider = () => const ciu.NavigatorCapabilities();
    });

    test('keyboard Always when standalone', () {
      ciu.isStandaloneOverride = () => true;
      expect(ciu.computeBrowserFeatures().keyboard, ciu.KeyboardSupport.Always);
      ciu.isStandaloneOverride = () => false;
    });

    test('keyboard FullScreen with navigator.keyboard', () {
      ciu.navigatorProvider = () => const ciu.NavigatorCapabilities(keyboard: true);
      expect(ciu.computeBrowserFeatures().keyboard, ciu.KeyboardSupport.FullScreen);
      ciu.navigatorProvider = () => const ciu.NavigatorCapabilities();
    });

    test('keyboard FullScreen on Safari, None otherwise', () {
      ciu.isSafariOverride = () => true;
      expect(ciu.computeBrowserFeatures().keyboard, ciu.KeyboardSupport.FullScreen);
      ciu.isSafariOverride = () => false;
      expect(ciu.computeBrowserFeatures().keyboard, ciu.KeyboardSupport.None);
    });

    test('touch and pointerEvents combination', () {
      ciu.navigatorProvider = () => const ciu.NavigatorCapabilities(maxTouchPoints: 1);
      ciu.hasPointerEventProvider = (_) => true;
      final f = ciu.computeBrowserFeatures();
      expect(f.touch, isTrue);
      expect(f.pointerEvents, isTrue);
      ciu.hasPointerEventProvider = (_) => false;
      ciu.navigatorProvider = () => const ciu.NavigatorCapabilities();
    });
  });

  group('trustedTypes', () {
    test('uses MonacoEnvironment.createTrustedTypesPolicy when present', () {
      final env = browser.IMonacoEnvironment(
        createTrustedTypesPolicy: (name, opts) => 'policy:$name',
      );
      browser.monacoEnvironmentGlobal = env;
      expect(tt.createTrustedTypesPolicy('x'), 'policy:x');
      browser.monacoEnvironmentGlobal = null;
    });

    test('falls back to globalThis.trustedTypes.createPolicy', () {
      tt.createTrustedTypesPolicyProvider =
          (name, opts) => 'global:$name';
      expect(tt.createTrustedTypesPolicy('y'), 'global:y');
      tt.createTrustedTypesPolicyProvider = null;
    });

    test('returns null when neither env nor global provider is set', () {
      browser.monacoEnvironmentGlobal = null;
      tt.createTrustedTypesPolicyProvider = null;
      expect(tt.createTrustedTypesPolicy('z'), isNull);
    });
  });

  group('fonts', () {
    test('DEFAULT_FONT_FAMILY is a non-empty platform string', () {
      expect(fonts.DEFAULT_FONT_FAMILY, isNotEmpty);
    });

    test('getFonts maps family names', () async {
      fonts.queryLocalFontsProvider = () async => const [
        fonts.FontData(family: 'Arial'),
        fonts.FontData(family: 'Menlo'),
      ];
      expect(await fonts.getFonts(), ['Arial', 'Menlo']);
    });

    test('getFonts returns [] and logs on provider error', () async {
      String? logged;
      fonts.fontsConsoleError = (m) => logged = m;
      fonts.queryLocalFontsProvider = () => throw StateError('boom');
      expect(await fonts.getFonts(), isEmpty);
      expect(logged, contains('Failed to query fonts'));
      fonts.queryLocalFontsProvider = null;
      fonts.fontsConsoleError = (_) {};
    });

    test('getFonts returns [] when provider absent', () async {
      fonts.queryLocalFontsProvider = null;
      expect(await fonts.getFonts(), isEmpty);
    });
  });
}
