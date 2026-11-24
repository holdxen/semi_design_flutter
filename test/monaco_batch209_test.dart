// Truth replay for batch209 (editorOptions.ts segment 1/4):
//   `editor/common/config/editorOptions.ts` — source lines 1–52, 1055–1526,
//   5952–6143.
//
// Expectations come from `tool/ts2dart/batch209_truth.json`, produced by
// `tool/ts2dart/_batch209_truth.cjs` (the REAL transpiled editorOptions.ts,
// with `nls`/`platform` stubbed; the full module loads, so the option
// registry from segments 2–4 executes there — the Dart registry is empty
// until segment 4, which is asserted instead of the count).
//
// NOTE: `editorOptions.ts` has no official unit test of its own; truth comes
// from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    as opts;
import '../lib/src/monaco/editor/common/config/fontInfo.dart' show FontInfo;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch209_truth.json').readAsStringSync()));

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

extension _ApplyUpdateResultJson<T> on opts.ApplyUpdateResult<T> {
  Map<String, Object?> toJson() =>
      <String, Object?>{'newValue': newValue, 'didChange': didChange};
}

class _FakeEnv implements opts.IEnvironmentalOptions {
  @override
  int get accessibilitySupport => AccessibilitySupport.Enabled;
  @override
  bool get editContextSupported => false;
  @override
  bool get emptySelectionClipboard => false;
  @override
  String get extraEditorClassName => '';
  @override
  FontInfo get fontInfo => throw UnimplementedError('unused in this test');
  @override
  num get glyphMarginDecorationLaneCount => 0;
  @override
  String get inputMode => 'insert';
  @override
  bool get isDominatedByLongLines => false;
  @override
  num get lineNumbersDigitCount => 1;
  @override
  opts.ComputeOptionsMemory? get memory => null;
  @override
  double get outerHeight => 800;
  @override
  double get outerWidth => 1000;
  @override
  double get pixelRatio => 1;
  @override
  bool get tabFocusMode => false;
  @override
  num get viewLineCount => 0;
}

class _FakeOptions implements opts.IComputedEditorOptions {
  @override
  Object? get(Object id) => null;
}

/// TS erases `applyUpdate<T>`'s type argument at runtime, so the JS harness
/// can call the module-private function with arbitrary values. The Dart port
/// keeps the contractual `as V` cast, so the replay drives it through a
/// concrete option whose `V` is `Object?` — same runtime behaviour, no cast
/// violations.
class _ProbeOption extends opts.SimpleEditorOption<Object?> {
  _ProbeOption()
      : super(opts.EditorOption.ariaLabel, 'ariaLabel', null);

  @override
  Object? validate(Object? input) => defaultValue;
}

/// Same mapping as the source's `_autoIndentFromString` (used as the convert
/// function of the [opts.EditorEnumOption] probe; the private function itself
/// is exercised through the `EditorAutoIndent` option class in segment 2).
int _autoIndentFromString(String autoIndent) {
  switch (autoIndent) {
    case 'none':
      return opts.EditorAutoIndentStrategy.none;
    case 'keep':
      return opts.EditorAutoIndentStrategy.keep;
    case 'brackets':
      return opts.EditorAutoIndentStrategy.brackets;
    case 'advanced':
      return opts.EditorAutoIndentStrategy.advanced;
    case 'full':
      return opts.EditorAutoIndentStrategy.full;
  }
  return opts.EditorAutoIndentStrategy.none;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('EditorOption enum values (auto-increment from the source table)', () {
    final Map<String, dynamic> expected = _map(truth['editorOption']);
    expect(opts.EditorOption.acceptSuggestionOnCommitCharacter,
        _exp(expected['acceptSuggestionOnCommitCharacter']));
    expect(opts.EditorOption.accessibilitySupport,
        _exp(expected['accessibilitySupport']));
    expect(opts.EditorOption.fontFamily, _exp(expected['fontFamily']));
    expect(opts.EditorOption.suggest, _exp(expected['suggest']));
    expect(opts.EditorOption.wrappingStrategy,
        _exp(expected['wrappingStrategy']));
    expect(opts.EditorOption.effectiveCursorStyle,
        _exp(expected['effectiveCursorStyle']));
    expect(opts.EditorOption.effectiveFullwidthCharacterWidth,
        _exp(expected['effectiveFullwidthCharacterWidth']));
  });

  test('boolean()', () {
    expect(
      <String, Object?>{
        'undefined': opts.boolean(null, true),
        'falseString': opts.boolean('false', true),
        'trueValue': opts.boolean(true, false),
        'falseValue': opts.boolean(false, true),
        'zero': opts.boolean(0, true),
        'emptyString': opts.boolean('', true),
        'nonEmptyString': opts.boolean('x', false),
        'object': opts.boolean(Object(), false),
      },
      _exp(truth['boolean']),
    );
  });

  test('clampedInt() (string parse, NaN guard, clamps, ToInt32 wrap)', () {
    expect(
      <String, Object?>{
        'string': opts.clampedInt('15', 5, 1, 10),
        'stringParseLeading': opts.clampedInt('9abc', 5, 1, 10),
        'invalid': opts.clampedInt('abc', 5, 1, 10),
        'nan': opts.clampedInt(double.nan, 5, 1, 10),
        'undefined': opts.clampedInt(null, 5, 1, 10),
        'clampMax': opts.clampedInt(100, 5, 1, 10),
        'clampMin': opts.clampedInt(-5, 5, 1, 10),
        'floatTruncates': opts.clampedInt(3.7, 5, 0, 10),
        'toInt32Wrap': opts.clampedInt(3000000000, 5, 0, 4000000000),
      },
      _exp(truth['clampedInt']),
    );
  });

  test('clampedFloat() + option statics', () {
    expect(
      <String, Object?>{
        'undefined': opts.clampedFloat(null, 2.5, 0, 10),
        'string': opts.clampedFloat('1.5', 2.5, 0, 10),
        'clampMax': opts.clampedFloat(99, 2.5, 0, 10),
        'invalid': opts.clampedFloat('abc', 2.5, 0, 10),
      },
      _exp(truth['clampedFloat']),
    );

    expect(
      <String, Object?>{
        'clamp': <num>[
          opts.EditorFloatOption.clamp(5, 1, 3),
          opts.EditorFloatOption.clamp(0, 1, 3),
          opts.EditorFloatOption.clamp(2, 1, 3),
        ],
        'floatString': opts.EditorFloatOption.float('2.25', 1),
        'floatInvalid': opts.EditorFloatOption.float('abc', 1),
      },
      _map(truth['floatStatics']),
    );

    expect(
      <String, Object?>{
        'valid': opts.EditorStringOption.string('monospace', 'default'),
        'invalid': opts.EditorStringOption.string(42, 'default'),
      },
      _map(truth['stringStatics']),
    );
  });

  test('stringSet()', () {
    expect(
      <String, Object?>{
        'valid': opts.stringSet<String>('advanced', 'none',
            <String>['none', 'keep', 'brackets', 'advanced', 'full']),
        'invalid':
            opts.stringSet<String>('bogus', 'none', <String>['none', 'keep']),
        'nonString': opts.stringSet<String>(5, 'none', <String>['none']),
        'renamed': opts.stringSet<String>(
            'oldName', 'none', <String>['newName'],
            <String, String>{'oldName': 'newName'}),
      },
      _exp(truth['stringSet']),
    );
  });

  test('applyUpdate() (primitives, arrays, nested mutation)', () {
    // The source's module-private `applyUpdate` is reached through a concrete
    // option instance (the harness probes it the same way).
    final _ProbeOption probe = _ProbeOption();
    final Map<String, dynamic> expected = _map(truth['applyUpdate']);

    final Map<String, Object?> primitiveChange =
        _map(probe.applyUpdate(1, 2).toJson());
    final Map<String, Object?> primitiveSame =
        _map(probe.applyUpdate(1, 1).toJson());
    expect(primitiveChange, _exp(expected['primitiveChange']));
    expect(primitiveSame, _exp(expected['primitiveSame']));

    // object case mutates `value` in place
    final Map<String, Object?> value = <String, Object?>{'insertSpace': true};
    probe.applyUpdate(value, <String, Object?>{'insertSpace': false});
    expect(value, _exp(expected['objectMutatesInPlace']));

    expect(
      <String, Object?>{
        'didChange': probe
            .applyUpdate(<Object?>[1, 2, 3], <Object?>[1, 2, 3])
            .didChange,
      },
      _exp(expected['arrayEqual']),
    );
    expect(
      <String, Object?>{
        'didChange': probe
            .applyUpdate(<Object?>[1, 2, 3], <Object?>[1, 2, 4])
            .didChange,
      },
      _exp(expected['arrayChanged']),
    );

    final Map<String, Object?> nestedValue = <String, Object?>{
      'a': <String, Object?>{'b': 1},
      'c': 2,
    };
    final opts.ApplyUpdateResult<Object?> nested = probe
        .applyUpdate(nestedValue, <String, Object?>{
      'a': <String, Object?>{'b': 5},
      'c': 2,
    });
    expect(
      <String, Object?>{'didChange': nested.didChange, 'value': nestedValue},
      _exp(expected['nested']),
    );

    final Map<String, Object?> emptyValue = <String, Object?>{};
    final opts.ApplyUpdateResult<Object?> missing =
        probe.applyUpdate(emptyValue, <String, Object?>{'a': 1});
    expect(
      <String, Object?>{'didChange': missing.didChange, 'value': emptyValue},
      _exp(expected['missingKeyInValue']),
    );
  });

  test('ConfigurationChangedEvent', () {
    final opts.ConfigurationChangedEvent event =
        opts.ConfigurationChangedEvent(<bool>[false, true, false, false, true]);
    expect(
      <String, Object?>{
        'changed1': event.hasChanged(1),
        'changed4': event.hasChanged(4),
        'unchanged0': event.hasChanged(0),
      },
      _exp(truth['configurationChangedEvent']),
    );
  });

  test('EditorAccessibilitySupport', () {
    final opts.EditorAccessibilitySupport acc = opts.EditorAccessibilitySupport();
    final _FakeEnv env = _FakeEnv();
    final _FakeOptions options = _FakeOptions();
    final Map<String, dynamic> expected = _map(truth['accessibilitySupport']);

    expect(acc.defaultValue, _exp(expected['default']));
    expect(acc.validate('auto'), _exp(expected['validateAuto']));
    expect(acc.validate('off'), _exp(expected['validateOff']));
    expect(acc.validate('on'), _exp(expected['validateOn']));
    expect(acc.validate('bogus'), _exp(expected['validateBogus']));
    expect(acc.compute(env, options, 0),
        _exp(expected['computeUnknownReadsEnv']));
    expect(acc.compute(env, options, 1), _exp(expected['computeExplicit']));
    expect(acc.schema, _exp(expected['schema']));
  });

  test('EditorEnumOption (autoIndent mapping)', () {
    final opts.EditorEnumOption<String, int> option =
        opts.EditorEnumOption<String, int>(
      opts.EditorOption.autoIndent,
      'autoIndent',
      3,
      'advanced',
      <String>['none', 'keep', 'brackets', 'advanced', 'full'],
      _autoIndentFromString,
    );
    final Map<String, dynamic> expected = _map(truth['editorEnumOption']);

    expect(option.defaultValue, _exp(expected['default']));
    expect(option.validate('advanced'), _exp(expected['validateAdvanced']));
    expect(option.validate('keep'), _exp(expected['validateKeep']));
    expect(option.validate('bogus'), _exp(expected['validateBogus']));
    expect(option.validate(5), _exp(expected['validateNonString']));
  });

  test('registry stays empty until segment 4 registers the options', () {
    expect(opts.editorOptionsRegistry, isEmpty);
  });
}