// Truth replay for batch208:
//   `editor/browser/config/domFontInfo.ts` (official `tokenization.test.ts`
//   cases run in `test/monaco_batch208_test.dart` via the 1:1 mirror).
//
// Expectations come from `tool/ts2dart/batch208_truth.json`, produced by
// `tool/ts2dart/_batch208_truth.cjs` (the real transpiled source executed with
// a fake `FastDomNode` and a fake raw element carrier).
//
// NOTE: `domFontInfo.ts` has no official unit test of its own; truth comes
// from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/fastDomNode.dart'
    show DomElement, DomTokenList, FastDomNode;
import '../lib/src/monaco/editor/browser/config/domFontInfo.dart'
    as domFontInfo;
import '../lib/src/monaco/editor/common/config/fontInfo.dart'
    show BareFontInfo;
import '../lib/src/monaco/editor/test/common/modes/supports/tokenization.test.dart'
    as tokenization_test;

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch208_truth.json').readAsStringSync()));

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

BareFontInfo _fontInfo() => BareFontInfo.create(
      'Fira Code',
      '300',
      14,
      '"ss01"',
      "'wght' 400",
      20,
      0.5,
      1,
      true,
    );

/// JS `String(number)` semantics (the node harness records `String(v)`).
String _jsNum(num value) {
  if (value is int) {
    return value.toString();
  }
  final double asDouble = value.toDouble();
  if (asDouble.isFinite && asDouble == asDouble.truncateToDouble()) {
    return asDouble.toInt().toString();
  }
  return asDouble.toString();
}

class _RecordingFastDomNode extends FastDomNode<DomElement> {
  _RecordingFastDomNode() : super(_FakeElement());

  final Map<String, String?> calls = <String, String?>{};

  @override
  void setFontFamily(String fontFamily) {
    calls['fontFamily'] = fontFamily;
  }

  @override
  void setFontWeight(String fontWeight) {
    calls['fontWeight'] = fontWeight;
  }

  @override
  void setFontSize(Object fontSize) {
    calls['fontSize'] = _jsNum(fontSize as num);
  }

  @override
  void setLineHeight(Object lineHeight) {
    calls['lineHeight'] = _jsNum(lineHeight as num);
  }

  @override
  void setLetterSpacing(Object letterSpacing) {
    calls['letterSpacing'] = _jsNum(letterSpacing as num);
  }

  @override
  void setFontFeatureSettings(String fontFeatureSettings) {
    calls['fontFeatureSettings'] = fontFeatureSettings;
  }

  @override
  void setFontVariationSettings(String fontVariationSettings) {
    calls['fontVariationSettings'] = fontVariationSettings;
  }
}

class _FakeElement implements DomElement {
  final Map<String, String> style = <String, String>{};

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('tokenization.test.ts official suites', () {
    // Runs every mocha case of the official test file in source order; any
    // failed assertion throws inside the mirror.
    tokenization_test.runAll();
  });

  test('applyFontInfo: FastDomNode branch', () {
    final _RecordingFastDomNode domNode = _RecordingFastDomNode();
    domFontInfo.applyFontInfo(domNode, _fontInfo());

    expect(domNode.calls, _exp(truth['fastDomNode']));
  });

  test('applyFontInfo: raw element branch (style writes with JS numbers)', () {
    final _FakeElement element = _FakeElement();
    domFontInfo.applyFontInfo(element, _fontInfo());

    expect(element.style, _exp(truth['rawElement']));
  });
}