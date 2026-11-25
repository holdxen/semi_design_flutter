// batch305: bracketRules.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/test/common/modes/supports/bracketRules.dart'
    as rules;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch305_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> expected =
      truth['rules'] as Map<String, dynamic>;

  test('standard tables are shared and match truth', () {
    expect(
      rules.rubyBracketRules,
      same(rules.standardBracketRules),
    );
    expect(rules.standardBracketRules, truth['standardBracketRules']);
    for (final String name in <String>['ruby', 'cpp', 'go', 'php', 'vb', 'lua']) {
      expect(rules.standardBracketRules, expected[name], reason: name);
    }
  });

  test('language-specific tables match truth', () {
    expect(rules.htmlBracketRules, expected['html']);
    expect(rules.typescriptBracketRules, expected['typescript']);
    expect(rules.latexBracketRules, expected['latex']);
  });
}
