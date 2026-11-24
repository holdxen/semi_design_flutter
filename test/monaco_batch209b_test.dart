// Truth replay for batch209b (editorOptions.ts segment 3a/4):
//   `editor/common/config/editorOptions.ts` — source lines 1527–2555
//   (option classes: comments, cursorBlinking, cursorStyle, editorClassName,
//   emptySelectionClipboard, find, fontLigatures, fontVariations, fontInfo,
//   effective* computed options, fontSize, fontWeight, gotoLocation, hover,
//   markdownImages).
//
// Expectations come from `tool/ts2dart/batch209b_truth.json`, produced by
// `tool/ts2dart/_batch209b_truth.cjs` (the REAL transpiled editorOptions.ts,
// with `nls`/`platform` stubbed; non-exported classes reached through a
// probe tail).
//
// NOTE: `editorOptions.ts` has no official unit test of its own; truth comes
// from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/editor/common/config/fontInfo.dart'
    show FontInfo, FontInfoOptions;
import '../lib/src/monaco/base/common/platform.dart' as platform;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;

/// The truth is recorded per host platform (`EDITOR_FONT_DEFAULTS.fontSize`
/// and the find/hover schema platform hints differ); pick the matching run.
Map<String, dynamic> _truth() {
  final Map<String, dynamic> variants = _map(jsonDecode(
      File('tool/ts2dart/batch209b_truth.json').readAsStringSync()));
  final String key = platform.isMacintosh
      ? 'mac'
      : (platform.isWindows ? 'win' : 'linux');
  return _map(variants[key]);
}

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

FontInfo _fontInfo({bool isMonospace = true}) => FontInfo(
      FontInfoOptions(
        pixelRatio: 1,
        fontFamily: 'monospace',
        fontWeight: 'normal',
        fontSize: 17,
        fontFeatureSettings: '',
        fontVariationSettings: "'wght' 500",
        lineHeight: 20,
        letterSpacing: 0,
        isMonospace: isMonospace,
        typicalHalfwidthCharacterWidth: 8,
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
  _FakeEnv({
    this.inputMode = 'insert',
    this.accessibilitySupport = AccessibilitySupport.Enabled,
    this.editContextSupported = true,
    this.emptySelectionClipboard = true,
    FontInfo? fontInfo,
  })  : fontInfo = fontInfo ?? _fontInfo(),
        extraEditorClassName = 'env-class';

  @override
  int accessibilitySupport;
  @override
  bool editContextSupported;
  @override
  bool emptySelectionClipboard;
  @override
  String extraEditorClassName;
  @override
  FontInfo fontInfo;
  @override
  String inputMode;
  @override
  opts.ComputeOptionsMemory? get memory => null;
  @override
  bool get isDominatedByLongLines => false;
  @override
  num get viewLineCount => 0;
  @override
  num get lineNumbersDigitCount => 1;
  @override
  double get pixelRatio => 1;
  @override
  bool get tabFocusMode => false;
  @override
  num get glyphMarginDecorationLaneCount => 0;
  @override
  double get outerHeight => 800;
  @override
  double get outerWidth => 1000;
}

class _FakeOptions implements opts.IComputedEditorOptions {
  _FakeOptions(this.values);

  final Map<int, Object?> values;

  @override
  Object? get(Object id) => values[id];
}

Map<String, Object?> _normComments(opts.EditorCommentsOptions o) =>
    <String, Object?>{
      'insertSpace': o.insertSpace,
      'ignoreEmptyLines': o.ignoreEmptyLines,
    };

Map<String, Object?> _normFind(opts.EditorFindOptions o) => <String, Object?>{
      'cursorMoveOnType': o.cursorMoveOnType,
      'findOnType': o.findOnType,
      'seedSearchStringFromSelection': o.seedSearchStringFromSelection,
      'autoFindInSelection': o.autoFindInSelection,
      'globalFindClipboard': o.globalFindClipboard,
      'addExtraSpaceOnTop': o.addExtraSpaceOnTop,
      'loop': o.loop,
      'closeOnResult': o.closeOnResult,
      'history': o.history,
      'replaceHistory': o.replaceHistory,
    };

Map<String, Object?> _normGoto(opts.GoToLocationOptions o) =>
    <String, Object?>{
      'multiple': o.multiple,
      'multipleDefinitions': o.multipleDefinitions,
      'multipleTypeDefinitions': o.multipleTypeDefinitions,
      'multipleDeclarations': o.multipleDeclarations,
      'multipleImplementations': o.multipleImplementations,
      'multipleReferences': o.multipleReferences,
      'multipleTests': o.multipleTests,
      'alternativeDefinitionCommand': o.alternativeDefinitionCommand,
      'alternativeTypeDefinitionCommand': o.alternativeTypeDefinitionCommand,
      'alternativeDeclarationCommand': o.alternativeDeclarationCommand,
      'alternativeImplementationCommand': o.alternativeImplementationCommand,
      'alternativeReferenceCommand': o.alternativeReferenceCommand,
      'alternativeTestsCommand': o.alternativeTestsCommand,
    };

Map<String, Object?> _normHover(opts.EditorHoverOptions o) =>
    <String, Object?>{
      'enabled': o.enabled,
      'delay': o.delay,
      'sticky': o.sticky,
      'hidingDelay': o.hidingDelay,
      'above': o.above,
      'showLongLineWarning': o.showLongLineWarning,
    };

Map<String, Object?> _normImages(opts.EditorMarkdownImagesOptions o) =>
    <String, Object?>{'allowedOrigins': o.allowedOrigins};

void main() {
  final Map<String, dynamic> truth = _truth();

  test('EditorComments.validate', () {
    final opts.EditorComments option = opts.EditorComments();
    final Map<String, dynamic> expected = _map(truth['comments']);
    expect(_normComments(option.validate(null)), _exp(expected['defaults']));
    expect(
      _normComments(option.validate(<String, Object?>{
        'insertSpace': false,
        'ignoreEmptyLines': false,
      })),
      _exp(expected['off']),
    );
    expect(
      _normComments(option.validate(<String, Object?>{'insertSpace': 'x'})),
      _exp(expected['truthyString']),
    );
    expect(
      _normComments(option.validate(<String, Object?>{'ignoreEmptyLines': 0})),
      _exp(expected['falsyNumber']),
    );
    expect(_normComments(option.validate(<String, Object?>{})),
        _exp(expected['empty']));
    expect(_normComments(option.validate(5)), _exp(expected['nonObject']));
    // typed carrier input
    expect(
      _normComments(option.validate(opts.IEditorCommentsOptions(
        insertSpace: false,
        ignoreEmptyLines: true,
      ))),
      <String, Object?>{'insertSpace': false, 'ignoreEmptyLines': true},
    );
  });

  test('cursor enums + conversions', () {
    final Map<String, dynamic> blink =
        _map(truth['cursorBlinkingStyleFromString']);
    expect(opts.cursorBlinkingStyleFromString('blink'), _exp(blink['blink']));
    expect(opts.cursorBlinkingStyleFromString('smooth'), _exp(blink['smooth']));
    expect(opts.cursorBlinkingStyleFromString('phase'), _exp(blink['phase']));
    expect(opts.cursorBlinkingStyleFromString('expand'), _exp(blink['expand']));
    expect(opts.cursorBlinkingStyleFromString('solid'), _exp(blink['solid']));

    final Map<String, dynamic> expected = _map(truth['cursorStyle']);
    expect(opts.TextEditorCursorStyle.Line,
        _exp(_map(expected['values'])['Line']));
    expect(opts.TextEditorCursorStyle.Block,
        _exp(_map(expected['values'])['Block']));
    expect(opts.TextEditorCursorStyle.Underline,
        _exp(_map(expected['values'])['Underline']));
    expect(opts.TextEditorCursorStyle.LineThin,
        _exp(_map(expected['values'])['LineThin']));
    expect(opts.TextEditorCursorStyle.BlockOutline,
        _exp(_map(expected['values'])['BlockOutline']));
    expect(opts.TextEditorCursorStyle.UnderlineThin,
        _exp(_map(expected['values'])['UnderlineThin']));
    expect(
      <String>[
        opts.cursorStyleToString(opts.TextEditorCursorStyle.Line),
        opts.cursorStyleToString(opts.TextEditorCursorStyle.Block),
        opts.cursorStyleToString(opts.TextEditorCursorStyle.Underline),
        opts.cursorStyleToString(opts.TextEditorCursorStyle.LineThin),
        opts.cursorStyleToString(opts.TextEditorCursorStyle.BlockOutline),
        opts.cursorStyleToString(opts.TextEditorCursorStyle.UnderlineThin),
      ],
      _exp(expected['toString']),
    );
    expect(
      <int>[
        opts.cursorStyleFromString('line'),
        opts.cursorStyleFromString('block'),
        opts.cursorStyleFromString('underline'),
        opts.cursorStyleFromString('line-thin'),
        opts.cursorStyleFromString('block-outline'),
        opts.cursorStyleFromString('underline-thin'),
      ],
      _exp(expected['fromString']),
    );
  });

  test('EditorClassName.compute', () {
    final opts.EditorClassName option = opts.EditorClassName();
    final Map<String, dynamic> expected = _map(truth['editorClassName']);
    expect(
      option.compute(
        _FakeEnv(),
        _FakeOptions(<int, Object?>{
          opts.EditorOption.extraEditorClassName: 'my-class',
          opts.EditorOption.mouseStyle: 'copy',
          opts.EditorOption.showUnused: true,
          opts.EditorOption.showDeprecated: true,
        }),
        null,
      ),
      _exp(expected['allOn']),
    );
    expect(
      option.compute(_FakeEnv(),
          _FakeOptions(<int, Object?>{opts.EditorOption.mouseStyle: 'default'}), null),
      _exp(expected['mouseDefault']),
    );
    expect(
      option.compute(
          _FakeEnv()..extraEditorClassName = '', _FakeOptions(<int, Object?>{}), null),
      _exp(expected['minimal']),
    );
  });

  test('EditorEmptySelectionClipboard', () {
    final opts.EditorEmptySelectionClipboard option =
        opts.EditorEmptySelectionClipboard();
    final Map<String, dynamic> expected = _map(truth['emptySelectionClipboard']);
    expect(option.validate(null), _exp(expected['validateUndefined']));
    expect(option.validate(false), _exp(expected['validateFalse']));
    expect(option.validate('false'), _exp(expected['validateFalseString']));
    expect(
      option.compute(_FakeEnv(), _FakeOptions(<int, Object?>{}), true),
      _exp(expected['computeEnvOn']),
    );
    expect(
      option.compute(
          _FakeEnv()..emptySelectionClipboard = false,
          _FakeOptions(<int, Object?>{}),
          true),
      _exp(expected['computeEnvOff']),
    );
  });

  test('EditorFind.validate', () {
    final opts.EditorFind option = opts.EditorFind();
    final Map<String, dynamic> expected = _map(truth['find']);
    expect(_normFind(option.validate(null)), _exp(expected['defaults']));
    expect(
      _normFind(option.validate(<String, Object?>{
        'cursorMoveOnType': false,
        'findOnType': false,
        'addExtraSpaceOnTop': false,
        'loop': false,
        'closeOnResult': true,
      })),
      _exp(expected['allOff']),
    );
    expect(
      _normFind(option.validate(<String, Object?>{
        'seedSearchStringFromSelection': false,
        'autoFindInSelection': true,
      })),
      _exp(expected['boolCoercion']),
    );
    expect(
      _normFind(option.validate(<String, Object?>{
        'seedSearchStringFromSelection': 'selection',
        'autoFindInSelection': 'multiline',
        'history': 'never',
      })),
      _exp(expected['stringOverride']),
    );
    expect(
      _normFind(option.validate(<String, Object?>{
        'seedSearchStringFromSelection': 'bogus',
        'autoFindInSelection': 'bogus',
        'history': 'bogus',
        'replaceHistory': 'bogus',
      })),
      _exp(expected['invalidFallback']),
    );
    expect(_normFind(option.validate(5)), _exp(expected['nonObject']));
    // typed carrier input
    expect(
      _normFind(option.validate(opts.IEditorFindOptions(
        findOnType: false,
        history: 'never',
      ))),
      <String, Object?>{
        'cursorMoveOnType': true,
        'findOnType': false,
        'seedSearchStringFromSelection': 'always',
        'autoFindInSelection': 'never',
        'globalFindClipboard': false,
        'addExtraSpaceOnTop': true,
        'loop': true,
        'closeOnResult': false,
        'history': 'never',
        'replaceHistory': 'workspace',
      },
    );
  });

  test('EditorFontLigatures.validate', () {
    final opts.EditorFontLigatures option = opts.EditorFontLigatures();
    final Map<String, dynamic> expected = _map(truth['fontLigatures']);
    expect(option.validate(null), _exp(expected['undefined']));
    expect(option.validate('false'), _exp(expected['falseString']));
    expect(option.validate(''), _exp(expected['empty']));
    expect(option.validate('true'), _exp(expected['trueString']));
    expect(option.validate('"ss01" on'), _exp(expected['passthrough']));
    expect(option.validate(true), _exp(expected['trueValue']));
    expect(option.validate(false), _exp(expected['falseValue']));
    expect(option.validate(0), _exp(expected['zero']));
    expect(option.validate(1), _exp(expected['one']));
  });

  test('EditorFontVariations.validate + compute', () {
    final opts.EditorFontVariations option = opts.EditorFontVariations();
    final Map<String, dynamic> expected = _map(truth['fontVariations']);
    expect(option.validate(null), _exp(expected['undefined']));
    expect(option.validate('false'), _exp(expected['falseString']));
    expect(option.validate('true'), _exp(expected['trueString']));
    expect(option.validate("'wght' 300"), _exp(expected['passthrough']));
    expect(option.validate(true), _exp(expected['trueValue']));
    expect(option.validate(false), _exp(expected['falseValue']));
    expect(option.validate(0), _exp(expected['zero']));
    expect(
      option.compute(_FakeEnv(), _FakeOptions(<int, Object?>{}), 'x'),
      _exp(expected['compute']),
    );
  });

  test('EditorFontInfo.compute', () {
    final opts.EditorFontInfo option = opts.EditorFontInfo();
    final Map<String, dynamic> expected = _map(truth['fontInfoOption']);
    final _FakeEnv env = _FakeEnv();
    expect(
        identical(option.compute(env, _FakeOptions(<int, Object?>{}), null),
            env.fontInfo),
        isTrue);
    expect(option.defaultValue.isMonospace, _exp(expected['defaultIsMonospace']));
  });

  test('EffectiveCursorStyle.compute', () {
    final opts.EffectiveCursorStyle option = opts.EffectiveCursorStyle();
    final Map<String, dynamic> expected = _map(truth['effectiveCursorStyle']);
    expect(
      option.compute(
        _FakeEnv(inputMode: 'overtype'),
        _FakeOptions(<int, Object?>{
          opts.EditorOption.overtypeCursorStyle:
              opts.TextEditorCursorStyle.BlockOutline,
          opts.EditorOption.cursorStyle: opts.TextEditorCursorStyle.Line,
        }),
        null,
      ),
      _exp(expected['overtype']),
    );
    expect(
      option.compute(
        _FakeEnv(inputMode: 'insert'),
        _FakeOptions(<int, Object?>{
          opts.EditorOption.overtypeCursorStyle:
              opts.TextEditorCursorStyle.BlockOutline,
          opts.EditorOption.cursorStyle: opts.TextEditorCursorStyle.UnderlineThin,
        }),
        null,
      ),
      _exp(expected['insert']),
    );
  });

  test('EffectiveEditContextEnabled.compute', () {
    final opts.EffectiveEditContextEnabled option =
        opts.EffectiveEditContextEnabled();
    final Map<String, dynamic> expected = _map(truth['effectiveEditContext']);
    expect(
      option.compute(_FakeEnv(editContextSupported: true),
          _FakeOptions(<int, Object?>{opts.EditorOption.editContext: true}), null),
      _exp(expected['bothTrue']),
    );
    expect(
      option.compute(_FakeEnv(editContextSupported: false),
          _FakeOptions(<int, Object?>{opts.EditorOption.editContext: true}), null),
      _exp(expected['envFalse']),
    );
  });

  test('EffectiveAllowVariableFonts.compute', () {
    final opts.EffectiveAllowVariableFonts option =
        opts.EffectiveAllowVariableFonts();
    final Map<String, dynamic> expected =
        _map(truth['effectiveAllowVariableFonts']);
    expect(
      option.compute(
        _FakeEnv(accessibilitySupport: AccessibilitySupport.Enabled),
        _FakeOptions(<int, Object?>{
          opts.EditorOption.allowVariableFontsInAccessibilityMode: true,
          opts.EditorOption.allowVariableFonts: false,
        }),
        null,
      ),
      _exp(expected['screenReaderOn']),
    );
    expect(
      option.compute(
        _FakeEnv(accessibilitySupport: AccessibilitySupport.Disabled),
        _FakeOptions(<int, Object?>{
          opts.EditorOption.allowVariableFontsInAccessibilityMode: true,
          opts.EditorOption.allowVariableFonts: false,
        }),
        null,
      ),
      _exp(expected['screenReaderOff']),
    );
  });

  test('EffectiveFullwidthCharacterWidth.compute', () {
    final opts.EffectiveFullwidthCharacterWidth option =
        opts.EffectiveFullwidthCharacterWidth();
    final Map<String, dynamic> expected =
        _map(truth['effectiveFullwidthCharacterWidth']);
    expect(
      option.compute(_FakeEnv(),
          _FakeOptions(<int, Object?>{opts.EditorOption.fullwidthCharacterWidth: 'twoCells'}), null),
      _exp(expected['twoCellsMonospace']),
    );
    expect(
      option.compute(
          _FakeEnv(fontInfo: _fontInfo(isMonospace: false)),
          _FakeOptions(<int, Object?>{opts.EditorOption.fullwidthCharacterWidth: 'twoCells'}),
          null),
      _exp(expected['twoCellsProportional']),
    );
    expect(
      option.compute(_FakeEnv(),
          _FakeOptions(<int, Object?>{opts.EditorOption.fullwidthCharacterWidth: 'font'}), null),
      _exp(expected['font']),
    );
  });

  test('EditorFontSize.validate + compute', () {
    final opts.EditorFontSize option = opts.EditorFontSize();
    final Map<String, dynamic> expected = _map(truth['fontSize']);
    expect(option.validate(null), _exp(expected['undefined']));
    expect(option.validate(0), _exp(expected['zero']));
    expect(option.validate('12'), _exp(expected['string']));
    expect(option.validate(200), _exp(expected['clampMax']));
    expect(option.validate(3), _exp(expected['clampMin']));
    expect(option.validate(12.5), _exp(expected['fractional']));
    expect(
      option.compute(_FakeEnv(), _FakeOptions(<int, Object?>{}), 0),
      _exp(expected['compute']),
    );
  });

  test('EditorFontWeight.validate', () {
    final opts.EditorFontWeight option = opts.EditorFontWeight();
    final Map<String, dynamic> expected = _map(truth['fontWeight']);
    expect(option.validate('normal'), _exp(expected['normal']));
    expect(option.validate('bold'), _exp(expected['bold']));
    expect(option.validate(400), _exp(expected['number']));
    expect(option.validate('400'), _exp(expected['string']));
    expect(option.validate(2000), _exp(expected['clamp']));
    expect(option.validate('abc'), _exp(expected['invalid']));
    expect(option.validate(12.7), _exp(expected['fractional']));
  });

  test('EditorGoToLocation.validate', () {
    final opts.EditorGoToLocation option = opts.EditorGoToLocation();
    final Map<String, dynamic> expected = _map(truth['gotoLocation']);
    expect(_normGoto(option.validate(null)), _exp(expected['defaults']));
    expect(
      _normGoto(option.validate(<String, Object?>{
        'multiple': 'goto',
        'multipleDefinitions': 'gotoAndPeek',
        'alternativeImplementationCommand': 'custom.cmd',
      })),
      _exp(expected['overrides']),
    );
    expect(
      _normGoto(option.validate(<String, Object?>{
        'multiple': 'bogus',
        'multipleDefinitions': 'bogus',
        'multipleTests': 'bogus',
      })),
      _exp(expected['invalidFallback']),
    );
    expect(_normGoto(option.validate(5)), _exp(expected['nonObject']));
    final Map<String, dynamic> schema =
        _map(expected['schemaMultipleDefs']);
    expect(schema['enum'], <String>['peek', 'gotoAndPeek', 'goto']);
    expect(schema['default'], 'peek');
    expect(schema, contains('description'));
    // typed carrier input
    expect(
      _normGoto(option.validate(opts.IGotoLocationOptions(
        multiple: 'goto',
        multipleTests: 'goto',
      ))),
      <String, Object?>{
        'multiple': 'goto',
        'multipleDefinitions': 'peek',
        'multipleTypeDefinitions': 'peek',
        'multipleDeclarations': 'peek',
        'multipleImplementations': 'peek',
        'multipleReferences': 'peek',
        'multipleTests': 'goto',
        'alternativeDefinitionCommand': 'editor.action.goToReferences',
        'alternativeTypeDefinitionCommand': 'editor.action.goToReferences',
        'alternativeDeclarationCommand': 'editor.action.goToReferences',
        'alternativeImplementationCommand': '',
        'alternativeReferenceCommand': '',
        'alternativeTestsCommand': '',
      },
    );
  });

  test('EditorHover.validate', () {
    final opts.EditorHover option = opts.EditorHover();
    final Map<String, dynamic> expected = _map(truth['hover']);
    expect(_normHover(option.validate(null)), _exp(expected['defaults']));
    expect(
      _normHover(option.validate(<String, Object?>{
        'enabled': 'off',
        'delay': 500,
        'hidingDelay': 50,
        'sticky': false,
        'above': false,
        'showLongLineWarning': false,
      })),
      _exp(expected['overrides']),
    );
    expect(
      _normHover(option.validate(
          <String, Object?>{'delay': 20000, 'hidingDelay': -5})),
      _exp(expected['clamp']),
    );
    expect(_normHover(option.validate(<String, Object?>{'delay': '750'})),
        _exp(expected['stringDelay']));
    expect(_normHover(option.validate(<String, Object?>{'enabled': 'bogus'})),
        _exp(expected['invalidFallback']));
  });

  test('getUrlOrigin / isMarkdownImageAllowed / EditorMarkdownImages', () {
    final Map<String, dynamic> expectedOrigin = _map(truth['getUrlOrigin']);
    expect(opts.getUrlOrigin('https://example.com/path?x=1'),
        _exp(expectedOrigin['https']));
    expect(opts.getUrlOrigin('data:image/png;base64,xx'),
        _exp(expectedOrigin['dataUrl']));
    expect(opts.getUrlOrigin('not a url'), _exp(expectedOrigin['invalid']));
    expect(opts.getUrlOrigin('http://localhost:3000/x'), _exp(expectedOrigin['port']));

    final Map<String, dynamic> expectedAllowed =
        _map(truth['isMarkdownImageAllowed']);
    bool allowed(opts.EditorMarkdownImagesOptions options, String url) =>
        opts.isMarkdownImageAllowed(options, url);
    expect(
      allowed(
          opts.EditorMarkdownImagesOptions(allowedOrigins: true),
          'https://whatever.com/x.png'),
      _exp(expectedAllowed['allowAll']),
    );
    expect(
      allowed(
          opts.EditorMarkdownImagesOptions(
              allowedOrigins: <String>['https://a.com']),
          'https://a.com/x.png'),
      _exp(expectedAllowed['listed']),
    );
    expect(
      allowed(
          opts.EditorMarkdownImagesOptions(
              allowedOrigins: <String>['https://a.com']),
          'https://b.com/x.png'),
      _exp(expectedAllowed['notListed']),
    );
    expect(
      allowed(
          opts.EditorMarkdownImagesOptions(
              allowedOrigins: <String>['https://a.com']),
          'data:image/png;base64,xx'),
      _exp(expectedAllowed['dataUrl']),
    );

    final opts.EditorMarkdownImages option = opts.EditorMarkdownImages();
    final Map<String, dynamic> expectedImages = _map(truth['markdownImages']);
    expect(_normImages(option.validate(null)), _exp(expectedImages['defaults']));
    expect(
      _normImages(option.validate(<String, Object?>{'allowedOrigins': true})),
      _exp(expectedImages['allowAll']),
    );
    expect(
      _normImages(option.validate(<String, Object?>{
        'allowedOrigins': <Object?>[
          'https://a.com/x',
          'https://a.com',
          'data:x',
          5,
        ],
      })),
      _exp(expectedImages['normalize']),
    );
    expect(
      _normImages(
          option.validate(<String, Object?>{'allowedOrigins': 'nope'})),
      _exp(expectedImages['invalidType']),
    );
    expect(_normImages(option.validate(5)), _exp(expectedImages['nonObject']));
  });
}