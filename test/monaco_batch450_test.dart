// 1:1 replay of
// `editor/browser/gpu/renderStrategy/fullFileRenderStrategy.wgsl.ts` (93 lines).
// Truth: `tool/ts2dart/_batch450_truth.cjs` -> `batch450_truth.json`.
//
// NOTE: parked at 450; numbers 403/404 are owned by a concurrent session.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/gpu/renderStrategy/fullFileRenderStrategy.wgsl.dart'
    as wgsl;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch450_truth.json').readAsStringSync()));

void main() {
  final truth = _truth();
  final value = wgsl.fullFileRenderStrategyWgsl;
  final lines = value.split('\n');

  test('template length / line count / boundaries match', () {
    expect(value.length, truth['length']);
    expect(lines.length, truth['lineCount']);
    expect(lines.first, truth['firstLine']);
    expect(lines.last, truth['lastLine']);
    expect(value.startsWith('\n'), truth['startsWithNewline']);
  });

  test('every @binding line resolves the same indices', () {
    final bindings = lines
        .where((line) => line.contains('@binding('))
        .map((line) => line.trim())
        .toList();
    expect(bindings, truth['bindings']);
    expect(value.contains(', 16>'), truth['hasMaximumPageCount']);
    expect(value.contains(', 5000>'), truth['hasMaximumGlyphCount']);
  });

  test('binding ids are exactly 0..6', () {
    final unique = <String>{};
    for (final match in RegExp(r'@binding\((\d+)\)').allMatches(value)) {
      unique.add('@binding(${match.group(1)})');
    }
    final expected =
        (truth['uniqueBindingNumbers'] as List).cast<String>().toList()..sort();
    expect(unique.toList()..sort(), expected);
  });
}
