// Truth-driven replay of the official diff fixtures test (batch182b).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/test/node/diffing/fixtures.test.dart'
    as fixtures_test;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch182b_truth.json').readAsStringSync())
        as Map<String, dynamic>;

const String fixturesSrcDir =
    '/Users/zhouguiqing/Documents/Code/Html/vscode/src/vs/editor/test/node/diffing/fixtures';

void main() {
  group('batch182b (official fixtures truth-driven)', () {
    test('skipped external-package cases match TypeScript record', () {
      final List<Object?> actual = fixtures_test.skippedFixtureCases
          .map((fixtures_test.SkippedFixtureCase s) => <String, Object?>{
                'suite': s.suite,
                'name': s.name,
                'reason': s.reason,
              })
          .toList()
        ..sort((Object? a, Object? b) =>
            (a as Map<String, Object?>)['name'].toString().compareTo(
                (b as Map<String, Object?>)['name'].toString()));
      expect(actual, truth['skipped']);
    });

    test('all fixture cases match TypeScript truth', () {
      final List<Map<String, Object?>> actual =
          fixtures_test.runFixtureOfficialCases(fixturesSrcDir);
      expect(actual, truth['cases']);
    });
  });
}
