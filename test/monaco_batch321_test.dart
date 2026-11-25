// batch321: electricCharacter.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/languages/supports/electricCharacter.dart'
    show
      BracketElectricCharacterSupport,
      IScopedLineTokensForElectric,
      IRichBracketsForElectric,
      ProcessedBracketPairForElectric;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch321_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Brackets implements IRichBracketsForElectric {
  @override
  final List<ProcessedBracketPairForElectric> brackets =
      <ProcessedBracketPairForElectric>[
    ProcessedBracketPairForElectric('{', '}', RegExp(r'\{'), RegExp(r'\}')),
    ProcessedBracketPairForElectric('BEGIN', 'END', RegExp('BEGIN'), RegExp('END')),
  ];

  @override
  RegExp get reversedRegex => RegExp(r'[}DNE]');

  @override
  Map<String, bool> get textIsOpenBracket => <String, bool>{
        '{': true,
        'begin': true,
      };
}

class _Context implements IScopedLineTokensForElectric {
  _Context(this.line, this.tokenType);

  final String line;
  final int tokenType;

  @override
  int findTokenIndexAtOffset(int offset) => 0;

  @override
  int getStandardTokenType(int tokenIndex) => tokenType;

  @override
  String getLineContent() => line;

  @override
  String getActualLineContentBefore(int offset) => line.substring(0, offset);
}

void main() {
  final Map<String, dynamic> truth = _truth();

  group('batch321 electricCharacter truth replay', () {
    for (final dynamic raw in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      test(c['label'] as String, () {
        final BracketElectricCharacterSupport support =
            BracketElectricCharacterSupport(
                c['label'] == 'null-brackets' ? null : _Brackets());
        expect(support.getElectricCharacters(), c['electric']);
        final List<Object?> results = <Object?>[];
        for (final dynamic rawCall in c['results'] as List<dynamic>) {
          final Map<String, dynamic> call = rawCall as Map<String, dynamic>;
          final action = support.onElectricCharacter(
            call['character'] as String,
            _Context(call['line'] as String, call['tokenType'] as int),
            call['column'] as int,
          );
          results.add(<String, Object?>{
            'label': call['label'],
            'character': call['character'],
            'line': call['line'],
            'column': call['column'],
            'tokenType': call['tokenType'],
            'result': action?.matchOpenBracket,
          });
        }
        expect(results, c['results']);
      });
    }
  });
}
