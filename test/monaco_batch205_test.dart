// Truth replay for batch205:
//   `editor/common/config/fontInfo.ts`
//
// Expectations come from `tool/ts2dart/batch205_truth.json`, produced by
// `tool/ts2dart/_batch205_truth.cjs` (the real transpiled source + the real
// `editorZoom` singleton, with `platform.ts` stubbed to a Linux host).
//
// NOTE: `fontInfo.ts` has no official unit test of its own; truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/platform.dart' as platform;
import '../lib/src/monaco/editor/common/config/editorZoom.dart'
    show EditorZoom;
import '../lib/src/monaco/editor/common/config/fontInfo.dart'
    show
        BareFontInfo,
        DEFAULT_LINUX_FONT_FAMILY,
        DEFAULT_MAC_FONT_FAMILY,
        DEFAULT_WINDOWS_FONT_FAMILY,
        EDITOR_FONT_DEFAULTS,
        FONT_VARIATION_OFF,
        FONT_VARIATION_TRANSLATE,
        FontInfo,
        FontInfoOptions,
        GOLDEN_LINE_HEIGHT_RATIO,
        MINIMUM_LINE_HEIGHT,
        SERIALIZED_FONT_INFO_VERSION,
        sanitizeFontFamily;

/// The truth is recorded once per host platform (`EDITOR_FONT_DEFAULTS` and
/// `GOLDEN_LINE_HEIGHT_RATIO` are platform dependent); pick the run that
/// matches this machine.
Map<String, dynamic> _truth() {
  final Map<String, dynamic> variants = _map(jsonDecode(
      File('tool/ts2dart/batch205_truth.json').readAsStringSync()));
  final String key = platform.isMacintosh
      ? 'mac'
      : (platform.isWindows ? 'win' : 'linux');
  return _map(variants[key]);
}

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, Object?> _info(BareFontInfo fontInfo) => <String, Object?>{
      'pixelRatio': fontInfo.pixelRatio,
      'fontFamily': fontInfo.fontFamily,
      'fontWeight': fontInfo.fontWeight,
      'fontSize': fontInfo.fontSize,
      'fontFeatureSettings': fontInfo.fontFeatureSettings,
      'fontVariationSettings': fontInfo.fontVariationSettings,
      'lineHeight': fontInfo.lineHeight,
      'letterSpacing': fontInfo.letterSpacing,
      'id': fontInfo.getId(),
    };

BareFontInfo _create({
  String fontFamily = 'monospace',
  String fontWeight = 'normal',
  double fontSize = 14,
  String fontFeatureSettings = '',
  String fontVariationSettings = 'normal',
  double lineHeight = 0,
  double letterSpacing = 0,
  double pixelRatio = 1,
  bool ignoreEditorZoom = false,
}) =>
    BareFontInfo.create(fontFamily, fontWeight, fontSize, fontFeatureSettings,
        fontVariationSettings, lineHeight, letterSpacing, pixelRatio,
        ignoreEditorZoom);

FontInfoOptions _fontInfoOptions({double spaceWidth = 8}) => FontInfoOptions(
      pixelRatio: 1,
      fontFamily: 'monospace',
      fontWeight: 'normal',
      fontSize: 14,
      fontFeatureSettings: '',
      fontVariationSettings: 'normal',
      lineHeight: 19,
      letterSpacing: 0,
      isMonospace: true,
      typicalHalfwidthCharacterWidth: 8,
      typicalFullwidthCharacterWidth: 14,
      canUseHalfwidthRightwardsArrow: true,
      spaceWidth: spaceWidth,
      middotWidth: 4,
      wsmiddotWidth: 6,
      maxDigitWidth: 8,
    );

void main() {
  final Map<String, dynamic> truth = _truth();

  test('fontInfo: constants and platform defaults', () {
    final Map<String, dynamic> constants = _map(truth['constants']);
    expect(GOLDEN_LINE_HEIGHT_RATIO, _exp(constants['golden']));
    expect(MINIMUM_LINE_HEIGHT, _exp(constants['minimumLineHeight']));
    expect(SERIALIZED_FONT_INFO_VERSION, _exp(constants['serializedVersion']));
    expect(FONT_VARIATION_OFF, _exp(constants['fontVariationOff']));
    expect(FONT_VARIATION_TRANSLATE, _exp(constants['fontVariationTranslate']));
    expect(DEFAULT_WINDOWS_FONT_FAMILY, _exp(constants['windowsFamily']));
    expect(DEFAULT_MAC_FONT_FAMILY, _exp(constants['macFamily']));
    expect(DEFAULT_LINUX_FONT_FAMILY, _exp(constants['linuxFamily']));
    expect(
      <String, Object?>{
        'fontFamily': EDITOR_FONT_DEFAULTS.fontFamily,
        'fontWeight': EDITOR_FONT_DEFAULTS.fontWeight,
        'fontSize': EDITOR_FONT_DEFAULTS.fontSize,
        'lineHeight': EDITOR_FONT_DEFAULTS.lineHeight,
        'letterSpacing': EDITOR_FONT_DEFAULTS.letterSpacing,
      },
      _exp(constants['defaults']),
    );
  });

  test('BareFontInfo.create: line height, zoom and font variations', () {
    EditorZoom.setZoomLevel(0);

    expect(_info(_create()), _exp(truth['createZeroLineHeight']));
    expect(_info(_create(lineHeight: 1.5)), _exp(truth['createEmLineHeight']));
    expect(_info(_create(lineHeight: 3)),
        _exp(truth['createSmallPxLineHeight']));
    expect(_info(_create(lineHeight: 10)), _exp(truth['createPxLineHeight']));
    expect(
      _info(_create(pixelRatio: 2, lineHeight: 30, fontSize: 12)),
      _exp(truth['createSmallPixelRatio']),
    );
    expect(
      _info(_create(fontWeight: 'bold', fontVariationSettings: 'translate')),
      _exp(truth['createVariationBold']),
    );
    expect(
      _info(_create(fontWeight: '300', fontVariationSettings: 'translate')),
      _exp(truth['createVariationWeight']),
    );
    expect(
      _info(_create(fontVariationSettings: "'wght' 500")),
      _exp(truth['createVariationCustom']),
    );

    EditorZoom.setZoomLevel(2);
    expect(_info(_create()), _exp(truth['createZoomed']));
    expect(_info(_create(ignoreEditorZoom: true)),
        _exp(truth['createZoomIgnored']));
    EditorZoom.setZoomLevel(0);
  });

  test('BareFontInfo.getMassagedFontFamily', () {
    String massaged(String family) => _create(
          fontFamily: family,
          ignoreEditorZoom: true,
        ).getMassagedFontFamily();

    expect(
      <String, Object?>{
        'plain': massaged('monospace'),
        'defaultFamily': massaged(EDITOR_FONT_DEFAULTS.fontFamily),
        'withSpace': massaged('Fira Code'),
        'withPlus': massaged('Noto Sans+'),
        'alreadyQuoted': massaged('"Fira Code"'),
        'commaQuoted': massaged("'Fira Code', monospace"),
      },
      _exp(truth['massaged']),
    );
  });

  test('sanitizeFontFamily', () {
    expect(
      <String, Object?>{
        'simple': sanitizeFontFamily('Consolas, monospace'),
        'unicode': sanitizeFontFamily('Söhne Mono'),
        'cjk': sanitizeFontFamily('等宽 字体'),
        'invalid': sanitizeFontFamily('evil;font-family'),
        'invalidBrace': sanitizeFontFamily('a{b}'),
        'empty': sanitizeFontFamily(''),
      },
      _exp(truth['sanitize']),
    );
  });

  test('FontInfo: version, metrics and equality', () {
    final FontInfo a = FontInfo(_fontInfoOptions(), true);
    final FontInfo b = FontInfo(_fontInfoOptions(), false);
    final FontInfo c = FontInfo(_fontInfoOptions(spaceWidth: 9), true);

    expect(
      <String, Object?>{
        'version': a.version,
        'isTrusted': a.isTrusted,
        'isMonospace': a.isMonospace,
        'equalsSame': a.equals(a),
        'equalsOtherTrust': a.equals(b),
        'equalsDifferentMetrics': a.equals(c),
        'id': a.getId(),
      },
      _exp(truth['fontInfo']),
    );
  });
}