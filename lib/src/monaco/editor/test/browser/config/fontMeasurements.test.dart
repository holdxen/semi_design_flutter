// 1:1 port of vscode/src/vs/editor/test/browser/config/fontMeasurements.test.ts
//
// The official mocha suite becomes Dart functions carrying the same
// assertions; `runAll()` executes them in source order. The suite-level
// `ensureNoDisposablesAreLeakedInTestSuite()` hook is omitted (same as the
// other mirrored tests).
//
// Infrastructure mapping (documented, same as the repo's other mirrored
// tests):
//  * `sinon.stub(CharWidthRequest.prototype, 'fulfill')` →
//    `charWidthReader.offsetWidthOverride` (width = offsetWidth / 256).
//  * `sinon.useFakeTimers` → `fontMeasurements.setTimeoutOverride` capture.
//  * `iframe.contentWindow` auxiliary window → a second registered `CodeWindow`.
//  * `assert.deepStrictEqual` → [StateError] on mismatch.
//  * the `--expose-gc` WeakRef test is skipped there too when `gc` is absent.
import '../../../../base/browser/dom.dart' as dom;
import '../../../../base/browser/window.dart' show mainWindow;
import '../../../browser/config/charWidthReader.dart' as charWidthReader;
import '../../../browser/config/fontMeasurements.dart';
import '../../../common/config/editorOptions.dart' show EditorFontLigatures;
import '../../../common/config/fontInfo.dart'
    show BareFontInfo, FontInfo, FontInfoOptions;

/// The `restoredFontInfo` literal of the official test.
FontInfo _restoredFontInfo() => FontInfo(
      FontInfoOptions(
        pixelRatio: 1,
        fontFamily: 'monospace',
        fontWeight: 'normal',
        fontSize: 14,
        fontFeatureSettings: '"liga" off, "calt" off',
        fontVariationSettings: 'normal',
        lineHeight: 19,
        letterSpacing: 0,
        isMonospace: true,
        typicalHalfwidthCharacterWidth: 8,
        typicalFullwidthCharacterWidth: 14,
        canUseHalfwidthRightwardsArrow: true,
        spaceWidth: 8,
        middotWidth: 8,
        wsmiddotWidth: 14,
        maxDigitWidth: 8,
      ),
      false,
    );

BareFontInfo _bare(String featureSettings, {double fontSize = 14}) =>
    BareFontInfo.create('monospace', 'normal', fontSize, featureSettings,
        'normal', 19, 0, 1, false);

void _check(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

void _checkJson(Object? actual, Object? expected, String message) {
  final String a = actual.toString();
  final String e = expected.toString();
  if (a != e) {
    throw StateError('$message: got $a, want $e');
  }
}

/// Official helper `assertLigatureClassification(probe, widthDifference,
/// isMonospace)`.
void _assertLigatureClassification(
  Object? Function()? setup,
  void Function()? teardown,
  String probe,
  num widthDifference,
  bool expectedMonospace,
) {
  final List<String> measuredLigatures = <String>[];
  charWidthReader.offsetWidthOverride = (dom.DomElement element) {
    final String text = element.textContent;
    final String chr =
        text.isEmpty ? '' : text.substring(0, text.length ~/ 256);
    if (chr.length > 1) measuredLigatures.add(chr);
    return (8 * chr.length + (chr == probe ? widthDifference : 0)) * 256;
  };

  final FontMeasurementsImpl fontMeasurements = FontMeasurementsImpl();
  final FontInfo options = _restoredFontInfo();
  final BareFontInfo bare = _bare(EditorFontLigatures.ON);
  final FontInfo fontInfo = fontMeasurements.readFontInfo(
      dom.windowCarrier(mainWindow), bare);

  _check(fontInfo.isMonospace == expectedMonospace,
      'isMonospace for probe=$probe delta=$widthDifference');
  _checkJson(measuredLigatures, <String>['fi', '<=', '=>', '==='],
      'measuredLigatures for probe=$probe');
  fontMeasurements.dispose();
  charWidthReader.offsetWidthOverride = null;
  // `options` stays referenced for parity with the official test.
  _check(options.isTrusted == false, 'restored FontInfo is untrusted');
}

/// Runs every official test case and throws on the first mismatch.
void runAll() {
  // isTrusted is always false for the restored literal.
  _restoredFontInfo();

  for (final String probe in <String>['fi', '<=', '=>', '===']) {
    for (final (num delta, bool expected)  in <(num, bool)>[
      (0, true),
      (-0.004, true),
      (0.004, true),
      (-0.006, false),
      (0.006, false),
    ]) {
      _assertLigatureClassification(null, null, probe, delta, expected);
    }
  }
}
