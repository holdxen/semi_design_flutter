import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/ui/mouseCursor/mouseCursor.dart'
    as mc;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/cursorColumns.test.dart'
    as cc;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/stringEdit.test.dart'
    as se;
import 'package:semi_design_flutter/src/monaco/editor/test/common/model/textChange.test.dart'
    as tc;

void main() {
  group('batch35 / ported mocha suites + lightweight ported files', () {
    test('mouseCursor class-name constant', () {
      expect(mc.MOUSE_CURSOR_TEXT_CSS_CLASS_NAME, 'monaco-mouse-cursor-text');
    });

    test('CursorColumns visibleColumnFromColumn', () {
      cc.testVisibleColumnFromColumn();
    });
    test('CursorColumns toStatusbarColumn', () {
      cc.testToStatusbarColumn();
    });
    test('CursorColumns columnFromVisibleColumn', () {
      cc.testColumnFromVisibleColumn();
    });
    test('CursorColumns nextTabStops', () {
      cc.testNextTabStops();
    });
    test('CursorColumns prevTabStops', () {
      cc.testPrevTabStops();
    });

    test('StringEdit basic', () {
      se.testStringEditBasic();
    });
    test('StringEdit inverse (seeded fuzz)', () {
      se.runInverseCases();
    });
    test('StringEdit compose (seeded fuzz)', () {
      se.runComposeCases();
    });
    test('StringEdit equals', () {
      se.testStringEditEquals();
    });
    test('StringEdit getNewRanges', () {
      se.testStringEditGetNewRanges();
    });
    test('StringEdit getJoinedReplaceRange', () {
      se.testStringEditGetJoinedReplaceRange();
    });
    test('StringEdit getLengthDelta', () {
      se.testStringEditGetLengthDelta();
    });
    test('StringEdit rebase variants', () {
      se.testAdjacentEditAndInsertRebase();
      se.testConcurrentInsertsConflict();
      se.testTryRebaseNonDisjointNegativeOffset();
      se.testTryRebaseSucceedsDisjoint();
      se.testRebaseSkipConflicting();
    });
    test('ArrayEdit basic + compose (seeded fuzz)', () {
      se.testArrayEditBasic();
      se.runArrayComposeCases();
    });
    test('tryRebase invariants (seeded fuzz)', () {
      se.runInvariantCases();
    });

    test('TextChangeCompressor simple/complex/gen cases', () {
      tc.testSimple1();
      tc.testSimple2();
      tc.testComplex1();
      tc.testGen1();
      tc.testGen2();
      tc.testGen3();
      tc.testGen4();
      tc.testGen5();
      tc.testGen6();
    });
    test('TextChange unicode write/read round-trip', () {
      tc.testUnicodeCharacterUndoBug();
    });
  });
}
