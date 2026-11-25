// batch304: autoClosingPairsRules.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/test/common/modes/supports/autoClosingPairsRules.dart'
    show
      IAutoClosingPair,
      IAutoClosingPairConditional,
      javascriptAutoClosingPairsRules,
      latexAutoClosingPairsRules;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch304_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final Map<String, dynamic> truth = _truth();
  test('javascript auto closing pairs match truth', () {
    expect(
      javascriptAutoClosingPairsRules
          .map((IAutoClosingPairConditional p) => p.toJson())
          .toList(),
      truth['javascriptAutoClosingPairsRules'],
    );
  });
  test('latex auto closing pairs match truth', () {
    expect(
      latexAutoClosingPairsRules.map((IAutoClosingPair p) => p.toJson()).toList(),
      truth['latexAutoClosingPairsRules'],
    );
  });
}
