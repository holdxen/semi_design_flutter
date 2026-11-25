// 1:1 replay of `editor/browser/gpu/gpu.ts` (41 lines).
// Truth: `tool/ts2dart/_batch402_truth.cjs` -> `batch402_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/gpu/gpu.dart' as gpu;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch402_truth.json').readAsStringSync()));

void main() {
  final truth = _truth();

  test('BindingId values and member order match the const enum', () {
    final expected = _map(truth['bindingId']);
    final actual = <String, int>{
      'GlyphInfo': gpu.BindingId.GlyphInfo,
      'Cells': gpu.BindingId.Cells,
      'TextureSampler': gpu.BindingId.TextureSampler,
      'Texture': gpu.BindingId.Texture,
      'LayoutInfoUniform': gpu.BindingId.LayoutInfoUniform,
      'AtlasDimensionsUniform': gpu.BindingId.AtlasDimensionsUniform,
      'ScrollOffset': gpu.BindingId.ScrollOffset,
    };
    expect(actual, expected);
    expect(actual.keys.toList(), truth['keys']);
  });
}
