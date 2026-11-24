// Truth replay for batch219 (editorOptions.ts segment 3b chunk 2):
//   inlayHints, lineDecorationsWidth, lineHeight.
//
// Expectations come from `tool/ts2dart/batch219_truth.json`, produced by
// `tool/ts2dart/_batch219_truth.cjs` (the REAL `editorOptions.ts` with `nls`
// and `platform` stubbed; private classes exposed through a probe tail).
//
// NOTE: editorOptions.ts has no official unit test; truth comes from executing
// the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/editor/common/config/fontInfo.dart'
    show FontInfo, FontInfoOptions;
import '../lib/src/monaco/base/common/platform.dart' as platform;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch219_truth.json').readAsStringSync()));

class _Options implements opts.IComputedEditorOptions {
  @override
  Object? get(Object id) => null;
}

FontInfo _fontInfo({double halfWidth = 8, double lineHeight = 37}) => FontInfo(
      FontInfoOptions(
        pixelRatio: 1,
        fontFamily: 'monospace',
        fontWeight: 'normal',
        fontSize: 17,
        fontFeatureSettings: '',
        fontVariationSettings: "'wght' 500",
        lineHeight: lineHeight,
        letterSpacing: 0,
        isMonospace: true,
        typicalHalfwidthCharacterWidth: halfWidth,
        typicalFullwidthCharacterWidth: 16,
        canUseHalfwidthRightwardsArrow: true,
        spaceWidth: 4,
        middotWidth: 4,
        wsmiddotWidth: 6,
        maxDigitWidth: 8,
      ),
      true,
    );

class _FakeEnv implements opts.IEnvironmentalOptions {
  _FakeEnv({this.halfWidth = 8, this.lineHeight = 37});

  final double halfWidth;
  final double lineHeight;

  @override
  FontInfo get fontInfo =>
      _fontInfo(halfWidth: halfWidth, lineHeight: lineHeight);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Map<String, Object?> _project(opts.EditorInlayHintsOptions value) =>
    <String, Object?>{
      'enabled': value.enabled,
      'fontSize': value.fontSize,
      'fontFamily': value.fontFamily,
      'padding': value.padding,
      'maximumLength': value.maximumLength,
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch219 EditorInlayHints matches source defaults, schema and validation',
      () {
    final Map<String, dynamic> expected = _map(truth['inlayHints']);
    final opts.EditorInlayHints option = opts.EditorInlayHints();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(_project(option.defaultValue), _map(expected['defaultValue']));
    expect(option.schema,
        _map(platform.isMacintosh ? expected['macSchema'] : expected['schema']));

    final Map<String, dynamic> validate = _map(expected['validate']);
    void check(String key, Object? input) =>
        expect(_project(option.validate(input)), _map(validate[key]));

    check('undefined', null);
    check('null', null);
    check('number', 42);
    check('emptyObject', <String, Object?>{});
    check('enabledTrue', <String, Object?>{'enabled': true});
    check('enabledFalse', <String, Object?>{'enabled': false});
    check('enabledOnUnlessPressed',
        <String, Object?>{'enabled': 'onUnlessPressed'});
    check('enabledBogus', <String, Object?>{'enabled': 'bogus'});
    check('fontSizeLow', <String, Object?>{'fontSize': -5});
    check('fontSizeHigh', <String, Object?>{'fontSize': 101});
    check('fontSizeString', <String, Object?>{'fontSize': '14'});
    check('fontFamily', <String, Object?>{'fontFamily': 'Fira Code'});
    check('paddingTrue', <String, Object?>{'padding': true});
    check('paddingString', <String, Object?>{'padding': 'false'});
    check('maximumLengthLow', <String, Object?>{'maximumLength': -1});
    check('maximumLengthHigh',
        <String, Object?>{'maximumLength': 9007199254740991});
    check('maximumLengthZero', <String, Object?>{'maximumLength': 0});
    check('maximumLengthString', <String, Object?>{'maximumLength': '17'});
    check(
        'all',
        <String, Object?>{
          'enabled': false,
          'fontSize': 12.9,
          'fontFamily': 'Menlo',
          'padding': true,
          'maximumLength': 99,
        });
  });

  test('batch219 EditorLineDecorationsWidth validates ch-suffix and computes',
      () {
    final Map<String, dynamic> expected =
        _map(truth['lineDecorationsWidth']);
    final opts.EditorLineDecorationsWidth option =
        opts.EditorLineDecorationsWidth();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, isNull);

    final Map<String, dynamic> validate = _map(expected['validate']);
    void check(String key, Object? input) =>
        expect(option.validate(input), validate[key]);

    check('undefined', null);
    check('number', 20);
    check('stringNumber', '20');
    check('ch', '8ch');
    check('chDecimal', '8.5ch');
    check('chNegative', '-8ch');
    check('chBare', '8');
    check('chSpace', ' 8ch');
    check('low', -5);
    check('high', 2000);

    final Map<String, dynamic> compute = _map(expected['compute']);
    final _FakeEnv env = _FakeEnv(halfWidth: 8);
    expect(option.compute(env, _Options(), 20), compute['plain']);
    expect(option.compute(env, _Options(), -8), compute['multiple']);
    expect(option.compute(env, _Options(), -8.5), compute['multipleDecimal']);
    expect(option.compute(env, _Options(), -1000), compute['multipleHigh']);
  });

  test('batch219 EditorLineHeight matches source float option and env compute',
      () {
    final Map<String, dynamic> expected = _map(truth['lineHeight']);
    final opts.EditorLineHeight option = opts.EditorLineHeight();

    expect(option.id, expected['id']);
    expect(option.name, expected['name']);
    expect(option.defaultValue, expected['defaultValue']);
    expect(option.schema, _map(expected['schema']));
    expect(expected['fontDefaultLineHeight'], 0);

    final Map<String, dynamic> validate = _map(expected['validate']);
    void check(String key, Object? input) =>
        expect(option.validate(input), validate[key]);

    check('undefined', null);
    check('zero', 0);
    check('normal', 21);
    check('low', -4);
    check('high', 200);
    check('stringNumber', '23');
    check('bogus', 'bogus');
    check('fractional', 21.5);

    final Map<String, dynamic> compute = _map(expected['compute']);
    expect(option.compute(_FakeEnv(lineHeight: 37), _Options(), 0),
        compute['fromEnv']);

    expect(truth['editorOptionsRegistryLength'], 180);
    expect(opts.editorOptionsRegistry, isA<List<Object?>>());
  });
}
