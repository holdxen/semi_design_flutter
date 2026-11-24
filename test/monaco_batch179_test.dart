// Truth-driven tests for batch179:
// editor/test/browser/gpu/atlas/textureAtlasAllocator.test.ts (official test).
// Truth source: tool/ts2dart/batch179_truth.json — executes the real transpiled
// shelf/slab allocator, gpuUtils, testUtil and the official test with a DOM seam.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/atlas.dart' as atlas;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/atlas/textureAtlasShelfAllocator.dart' as shelf;
import 'package:semi_design_flutter/src/monaco/editor/test/browser/gpu/atlas/textureAtlasAllocator.test.dart' as official;
import 'package:semi_design_flutter/src/monaco/editor/test/browser/gpu/atlas/testUtil.dart' as util;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch179_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> resultByName(String name) {
  final List<dynamic> results = truth['results'] as List<dynamic>;
  return results.firstWhere((dynamic r) => r['name'] == name) as Map<String, dynamic>;
}

List<int>? truthExpectation(Map<String, dynamic> assertion) {
  final Map<String, dynamic> expected =
      assertion['expected'] as Map<String, dynamic>;
  if (expected.containsKey('__undefined')) {
    return null;
  }
  return <int>[
    (expected['x'] as num).toInt(),
    (expected['y'] as num).toInt(),
    (expected['w'] as num).toInt(),
    (expected['h'] as num).toInt(),
  ];
}

void main() {
  group('textureAtlasAllocator.test.ts (truth-driven)', () {
    test('skipped tests are recorded from the official suite', () {
      final List<dynamic> results = truth['results'] as List<dynamic>;
      final List<dynamic> skipped =
          results.where((dynamic r) => r['skipped'] == true).toList();
      expect(skipped.length, 2);
      expect(
        skipped.map((dynamic r) => r['name']),
        official.skippedCaseNames,
      );
    });

    test('every official case is present in the truth snapshot', () {
      final List<dynamic> names =
          (truth['results'] as List<dynamic>).map((dynamic r) => r['name']).toList();
      for (final official.AllocationCase testCase in official.officialCases) {
        expect(names, contains(testCase.name));
        expect(resultByName(testCase.name)['error'], isNull);
      }
    });

    test('shared tests call assertIsValidGlyph on the allocator canvas', () {
      for (final official.AllocationCase testCase in official.officialCases) {
        if (!testCase.shared) continue;
        final shelf.AtlasCanvas canvas = official.createAllocatorCanvas(
            testCase.canvasW, testCase.canvasH);
        final atlas.ITextureAtlasAllocator allocator =
            official.createAllocator(testCase, canvas);
        for (final official.AllocationStep step in testCase.steps) {
          util.assertIsValidGlyph(
            allocator.allocate(step.glyph),
            (canvas.getContext('2d') as official.AllocatorTestContext).canvas,
          );
        }
        final int okCount = (resultByName(testCase.name)['assertions'] as List<dynamic>)
            .where((dynamic a) => a['kind'] == 'ok')
            .length;
        expect(okCount, 20);
      }
    });

    test('all allocations match truth and the 1:1 ported expectations', () {
      int checked = 0;
      official.runOfficialCases(
        (official.AllocationCase testCase, int index, List<int>? actual,
            List<int>? expected) {
          expect(actual, expected,
              reason: '${testCase.name} allocation $index');
          if (testCase.shared) return;

          final List<dynamic> assertions =
              (resultByName(testCase.name)['assertions'] as List<dynamic>)
                  .where((dynamic a) =>
                      a['kind'] == 'deepStrictEqual' || a['kind'] == 'strictEqual')
                  .toList();
          expect(assertions.length, testCase.steps.length);
          expect(truthExpectation(assertions[index] as Map<String, dynamic>),
              expected,
              reason: 'truth disagrees at ${testCase.name} allocation $index');
          checked++;
        },
      );
      expect(checked, greaterThan(20));
    });

    test('glyph too large for canvas throws BugIndicatingError', () {
      final shelf.AtlasCanvas canvas = official.createAllocatorCanvas(1, 1);
      final atlas.ITextureAtlasAllocator allocator =
          shelf.TextureAtlasShelfAllocator(canvas, 0);
      expect(
        () => allocator.allocate(official.TestRasterizedGlyph(2, 1)),
        throwsA(isA<Exception>().having(
          (Exception e) => e.toString(),
          'message',
          contains(official.tooLargeForCanvasMessage),
        )),
      );
    });
  });
}
