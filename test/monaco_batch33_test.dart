import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/editor/test/browser/gpu/bufferDirtyTracker.test.dart'
    as bdt;
import 'package:semi_design_flutter/src/monaco/editor/test/browser/view/minimapDirtyRows.test.dart'
    as mdr;
import 'package:semi_design_flutter/src/monaco/editor/test/common/view/overviewZoneManager.test.dart'
    as ozone;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/range.test.dart'
    as range;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/textEdit.test.dart'
    as te;

void main() {
  group('batch33 / ported mocha suites', () {
    test('BufferDirtyTracker flag(index)', () {
      bdt.testFlagIndex();
    });
    test('BufferDirtyTracker flag(index, length)', () {
      bdt.testFlagIndexLength();
    });

    test('Minimap RowSignatures finds band of rows', () {
      mdr.testFindsBandOfRowsDrawnDifferently();
    });

    test('OverviewZoneManager pixel ratio 1 dom 600', () {
      ozone.testPixelRatio1DomHeight600();
    });
    test('OverviewZoneManager pixel ratio 1 dom 300', () {
      ozone.testPixelRatio1DomHeight300();
    });
    test('OverviewZoneManager pixel ratio 2 dom 300', () {
      ozone.testPixelRatio2DomHeight300();
    });

    test('Range empty/swap/no-swap', () {
      range.testEmptyRange();
      range.testSwapStartAndStopSameLine();
      range.testSwapStartAndStop();
      range.testNoSwapSameLine();
      range.testNoSwap();
    });
    test('Range compareRangesUsingEnds', () {
      range.testCompareRangesUsingEnds();
    });
    test('Range containsPosition', () {
      range.testContainsPosition();
    });
    test('Range containsRange', () {
      range.testContainsRange();
    });
    test('Range areIntersecting', () {
      range.testAreIntersecting();
    });

    test('TextEdit inverse explicit surrogate cases', () {
      te.testInsertionOfSurrogatePair();
      te.testMultilineReplacementEndingInSurrogatePairs();
      te.testMultipleReplacementsSurrogatePairsSameLine();
    });
    test('TextEdit inverse seeded fuzz (20 cases)', () {
      te.runInverseFuzzCases();
    });
    test('TextEdit removeCommonPrefixAndSuffix surrogate pairs', () {
      te.testRemoveCommonPrefixAndSuffixSurrogatePairs();
    });
    test('TextEdit compose seeded fuzz (100 cases)', () {
      te.runComposeFuzzCases();
    });
  });
}
