// batch306: characterPair.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/languages/supports/characterPair.dart'
    show
      CharacterPairSupport,
      ElectricCharacterSupport,
      IAutoClosingPair,
      IAutoClosingPairConditional,
      IDocComment,
      LanguageConfiguration,
      StandardAutoClosingPairConditional;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch306_truth.json').readAsStringSync())
    as Map<String, dynamic>;

IAutoClosingPairConditional _conditional(Map<String, dynamic> d) =>
    IAutoClosingPairConditional(
      open: d['open'] as String,
      close: d['close'] as String,
      notIn: d['notIn'] == null
          ? null
          : (d['notIn'] as List<dynamic>).map((e) => e as String).toList(),
    );

LanguageConfiguration _config(Map<String, dynamic> d) {
  final Object? electric = d['__electricCharacterSupport'];
  final Object? doc = electric is Map<String, dynamic>
      ? electric['docComment']
      : null;
  return LanguageConfiguration(
    autoClosingPairs: d['autoClosingPairs'] == null
        ? null
        : (d['autoClosingPairs'] as List<dynamic>)
            .map((e) => _conditional(e as Map<String, dynamic>))
            .toList(),
    brackets: d['brackets'] == null
        ? null
        : (d['brackets'] as List<dynamic>)
            .map((e) => (e as List<dynamic>).map((x) => x as String).toList())
            .toList(),
    electricCharacterSupport: doc == null
        ? null
        : ElectricCharacterSupport(
            docComment: IDocComment(
              (doc as Map<String, dynamic>)['open'] as String,
              (doc as Map<String, dynamic>)['close'] as String,
            ),
          ),
    autoCloseBefore: d['autoCloseBefore'] as String?,
    surroundingPairs: d['surroundingPairs'] == null
        ? null
        : (d['surroundingPairs'] as List<dynamic>)
            .map((e) {
              final Map<String, dynamic> m = e as Map<String, dynamic>;
              return IAutoClosingPair(m['open'] as String, m['close'] as String);
            })
            .toList(),
  );
}

Map<String, Object?> _pairJson(IAutoClosingPair p) {
  final Map<String, Object?> out = <String, Object?>{
    'open': p.open,
    'close': p.close,
  };
  if (p is IAutoClosingPairConditional) {
    out['inString'] = p.inString;
    out['inComment'] = p.inComment;
    out['inRegEx'] = p.inRegEx;
    out['hasBeforeText'] = p.beforeText != null;
  } else {
    out['hasBeforeText'] = false;
  }
  return out;
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> constants =
      truth['constants'] as Map<String, dynamic>;

  test('constants match truth', () {
    expect(
      CharacterPairSupport
          .DEFAULT_AUTOCLOSE_BEFORE_LANGUAGE_DEFINED_QUOTES,
      constants['quotes'],
    );
    expect(
      CharacterPairSupport
          .DEFAULT_AUTOCLOSE_BEFORE_LANGUAGE_DEFINED_BRACKETS,
      constants['brackets'],
    );
    expect(CharacterPairSupport.DEFAULT_AUTOCLOSE_BEFORE_WHITESPACE,
        constants['whitespace']);
  });

  group('batch306 characterPair truth replay', () {
    for (final dynamic raw in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      test(c['name'] as String, () {
        final CharacterPairSupport support =
            CharacterPairSupport(_config(c['config'] as Map<String, dynamic>));
        final List<StandardAutoClosingPairConditional> auto =
            support.getAutoClosingPairs();
        final List<IAutoClosingPair> surrounding = support.getSurroundingPairs();
        expect(
          <String, Object?>{
            'auto': auto.map(_pairJson).toList(),
            'surrounding': surrounding.map(_pairJson).toList(),
            'surroundingIsAuto': identical(surrounding, auto),
            'beforeQuotes': support.getAutoCloseBeforeSet(true),
            'beforeBrackets': support.getAutoCloseBeforeSet(false),
          },
          c['result'],
        );
      });
    }
  });
}
