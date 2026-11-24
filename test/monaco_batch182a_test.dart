// Truth-driven replay of the official diff tests in batch182a.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/test/node/diffing/defaultLinesDiffComputer.test.dart'
    as default_lines_diff_computer_test;
import 'package:semi_design_flutter/src/monaco/editor/test/node/diffing/verifyLinesDiff.test.dart'
    as verify_lines_diff_test;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch182a_truth.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('batch182a (official truth-driven)', () {
    test('all official cases match TypeScript truth', () {
      final List<Map<String, Object?>> actual =
          <Map<String, Object?>>[
        ...verify_lines_diff_test.runVerifyLinesDiffOfficialCases(),
        ...default_lines_diff_computer_test
            .runDefaultLinesDiffComputerOfficialCases(),
      ];
      expect(actual, truth['cases']);
    });
  });
}
