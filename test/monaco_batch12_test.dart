// 1:1 port parity tests for batch 12:
//   platform/theme/common/theme.ts
//   editor/common/inputMode.ts
//   base/browser/window.ts
//   base/browser/cssValue.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart'
    as theme;
import 'package:semi_design_flutter/src/monaco/editor/common/inputMode.dart'
    as im;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart' as win;
import 'package:semi_design_flutter/src/monaco/base/browser/cssValue.dart' as css;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;

void main() {
  group('theme', () {
    test('ColorScheme values match TS strings', () {
      expect(theme.ColorScheme.dark.value, 'dark');
      expect(theme.ColorScheme.light.value, 'light');
      expect(theme.ColorScheme.highContrastDark.value, 'hcDark');
      expect(theme.ColorScheme.highContrastLight.value, 'hcLight');
    });

    test('ThemeTypeSelector values match TS strings', () {
      expect(theme.ThemeTypeSelector.vs.value, 'vs');
      expect(theme.ThemeTypeSelector.vsDark.value, 'vs-dark');
      expect(theme.ThemeTypeSelector.hcBlack.value, 'hc-black');
      expect(theme.ThemeTypeSelector.hcLight.value, 'hc-light');
    });

    test('isHighContrast / isDark', () {
      expect(theme.isHighContrast(theme.ColorScheme.highContrastDark), isTrue);
      expect(theme.isHighContrast(theme.ColorScheme.highContrastLight), isTrue);
      expect(theme.isHighContrast(theme.ColorScheme.dark), isFalse);
      expect(theme.isHighContrast(theme.ColorScheme.light), isFalse);

      expect(theme.isDark(theme.ColorScheme.dark), isTrue);
      expect(theme.isDark(theme.ColorScheme.highContrastDark), isTrue);
      expect(theme.isDark(theme.ColorScheme.light), isFalse);
      expect(theme.isDark(theme.ColorScheme.highContrastLight), isFalse);
    });
  });

  group('inputMode', () {
    test('default is insert', () {
      expect(im.InputMode.getInputMode(), im.InputModeType.insert);
    });

    test('set fires event and updates mode', () {
      final List<im.InputModeType> seen = <im.InputModeType>[];
      im.InputMode.onDidChangeInputMode((dynamic v) => seen.add(v));
      im.InputMode.setInputMode(im.InputModeType.overtype);
      expect(im.InputMode.getInputMode(), im.InputModeType.overtype);
      expect(seen, <im.InputModeType>[im.InputModeType.overtype]);
      // restore
      im.InputMode.setInputMode(im.InputModeType.insert);
    });

    test('fromValue maps TS strings', () {
      expect(im.InputModeType.fromValue('insert'), im.InputModeType.insert);
      expect(im.InputModeType.fromValue('overtype'), im.InputModeType.overtype);
      expect(im.InputModeType.fromValue('x'), isNull);
      expect(im.InputModeType.insert.value, 'insert');
    });
  });

  group('window', () {
    test('ensureCodeWindow assigns fallback id', () {
      final win.CodeWindow w = win.ensureCodeWindow(Object(), 42);
      expect(w.vscodeWindowId, 42);
    });

    test('ensureCodeWindow preserves existing id', () {
      final win.CodeWindow w = win.CodeWindow(Object(), 7);
      final win.CodeWindow w2 = win.ensureCodeWindow(w, 99);
      expect(identical(w, w2), isTrue);
      expect(w2.vscodeWindowId, 7);
    });

    test('ensureCodeWindow fills id when carrier has none', () {
      final win.CodeWindow w = win.CodeWindow(Object());
      win.ensureCodeWindow(w, 5);
      expect(w.vscodeWindowId, 5);
    });

    test('isAuxiliaryWindow excludes mainWindow', () {
      expect(win.isAuxiliaryWindow(win.mainWindow), isFalse);
    });

    test('isAuxiliaryWindow detects id-bearing carriers', () {
      final win.CodeWindow aux = win.CodeWindow(Object(), 1);
      expect(win.isAuxiliaryWindow(aux), isTrue);
      expect(win.isAuxiliaryWindow(Object()), isFalse);
    });
  });

  group('cssValue', () {
    test('asCssValueWithDefault passthrough / default', () {
      expect(css.asCssValueWithDefault('red', 'blue'), 'red');
      expect(css.asCssValueWithDefault(null, 'blue'), 'blue');
    });

    test('asCssValueWithDefault resolves var() fallback', () {
      expect(
          css.asCssValueWithDefault('var(--x)', 'fallback'),
          'var(--x, fallback)');
      expect(
          css.asCssValueWithDefault('var(--x, green)', 'fallback'),
          'var(--x, green)');
      // nested recursive default
      expect(
          css.asCssValueWithDefault('var(--x, var(--y))', 'fallback'),
          'var(--x, var(--y, fallback))');
    });

    test('sizeValue strips unsafe chars', () {
      expect(css.sizeValue('10px'), '10px');
      expect(css.sizeValue('1.5em'), '1.5em');
      expect(css.sizeValue('calc(1px; x)'), 'calc1pxx');
    });

    test('hexColorValue strips non-hex (JS regex quirk preserved)', () {
      expect(css.hexColorValue('#a1B2c3'), '#a1B2c3');
      expect(css.hexColorValue('[x]'), '[');
      expect(css.hexColorValue('rgb(1,2,3)'), 'rgb(1,2,3)'); // no ']' to match
    });

    test('identValue strips unsafe chars', () {
      expect(css.identValue('foo_bar-1'), 'foo_bar-1');
      expect(css.identValue('a b.c'), 'abc');
    });

    test('stringValue wraps in quotes and escapes single quote', () {
      expect(css.stringValue('abc'), "'abc'");
      // JS '\000027' == NUL + "027" (code units verified against node).
      expect(css.stringValue("a'b").codeUnits, <int>[39, 97, 0, 48, 50, 55, 98, 39]);
    });

    test('inline joins static strings and values', () {
      expect(
          css.inline(<String>['a', 'b', 'c'], <Object?>[1, 2]),
          'a1b2c');
      expect(css.inline(<String>['x', 'y'], <Object?>[null]), 'xy');
    });

    test('Builder pushes and joins', () {
      final css.Builder b = css.Builder();
      b.push(<String>['a', 'b']);
      b.push(<String>['c']);
      expect(b.join(), 'a\nb\nc');
      expect(b.join(','), 'a,b,c');
    });

    test('asCSSUrl wraps uri in url(...)', () {
      final String Function(String) prev = css.cssEscape;
      try {
        css.cssEscape = (String v) => 'E[$v]';
        final uri.URI u = uri.URI.parse('file:///a/b.png');
        // uriToBrowserUri rewrites file:// via the registered vscode-file
        // provider; assert the wrapper + that cssEscape was applied.
        final String out = css.asCSSUrl(u);
        expect(out.startsWith("url('E["), isTrue);
        expect(out.endsWith("]')"), isTrue);
      } finally {
        css.cssEscape = prev;
      }
    });

    test('asCSSUrl of null is empty url', () {
      expect(css.asCSSUrl(null), "url('')");
    });

    test('className uses cssEscape bridge', () {
      final String Function(String) prev = css.cssEscape;
      try {
        css.cssEscape = (String v) => 'ESC($v)';
        expect(css.className('foo'), 'ESC(foo)');
        expect(css.className('foo', true), 'ESC(foo)');
      } finally {
        css.cssEscape = prev;
      }
    });

    test('default cssEscape escapes digits at start and special chars', () {
      expect(css.cssEscape('1abc'), r'\31 abc');
      expect(css.cssEscape('a b'), r'a\ b');
      expect(css.cssEscape('a-b'), 'a-b');
    });
  });
}
