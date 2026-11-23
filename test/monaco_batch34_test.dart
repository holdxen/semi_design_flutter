import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/editor/test/browser/gpu/objectCollectionBuffer.test.dart'
    as ocb;
import 'package:semi_design_flutter/src/monaco/editor/test/browser/view/minimapCharRenderer.test.dart'
    as mcr;
import 'package:semi_design_flutter/src/monaco/editor/test/common/controller/cursorAtomicMoveOperations.test.dart'
    as cam;
import 'package:semi_design_flutter/src/monaco/editor/test/common/modes/languageSelector.test.dart'
    as ls;
import 'package:semi_design_flutter/src/monaco/editor/contrib/find/test/browser/replacePattern.test.dart'
    as rp;

void main() {
  group('batch34 / ported mocha suites', () {
    test('ObjectCollectionBuffer createEntry', () {
      ocb.testCreateEntry();
    });
    test('ObjectCollectionBuffer createEntry beyond capacity', () {
      ocb.testCreateEntryBeyondCapacity();
    });
    test('ObjectCollectionBuffer dispose entry', () {
      ocb.testDisposeEntry();
    });
    test('ObjectCollectionBuffer entryCount/viewUsedSize/bufferUsedSize', () {
      ocb.testEntryCountViewUsedSizeBufferUsedSize();
    });
    test('ObjectCollectionBuffer entry.get', () {
      ocb.testEntryGet();
    });
    test('ObjectCollectionBuffer entry.set', () {
      ocb.testEntrySet();
    });

    test('MinimapCharRenderer letter d @ 2x', () {
      mcr.testLetterD2x();
    });
    test('MinimapCharRenderer letter d @ 1x', () {
      mcr.testLetterD1x();
    });

    test('CursorAtomicMoveOperations whitespaceVisibleColumn', () {
      cam.testWhitespaceVisibleColumn();
    });
    test('CursorAtomicMoveOperations atomicPosition', () {
      cam.testAtomicPosition();
    });

    test('LanguageSelector score cases', () {
      ls.testScoreInvalidSelector();
      ls.testScoreAnyLanguage();
      ls.testScoreDefaultSchemes();
      ls.testScoreFilter();
      ls.testScoreMaxFilters();
      ls.testScoreHasAccessToAllModels();
      ls.testScoreNotebookType();
      ls.testSnippetChoicesLost149363();
      ls.testDocumentSelectorUnexpected60232();
      ls.testDocumentSelectorPlatformPaths99938();
      ls.testNotebookTypeWithoutNotebook();
    });
    test('LanguageSelector selectLanguageIds', () {
      ls.testSelectLanguageIds();
    });

    test('ReplacePattern parse replace string', () {
      rp.testParseReplaceString();
    });
    test('ReplacePattern parse with case modifiers', () {
      rp.testParseReplaceStringWithCaseModifiers();
    });
    test('ReplacePattern JavaScript semantics', () {
      rp.testReplaceHasJavaScriptSemantics();
    });
    test('ReplacePattern complete match', () {
      rp.testGetReplaceStringCompleteMatch();
    });
    test('ReplacePattern substring match', () {
      rp.testGetReplaceStringSubstringMatch();
    });
    test('ReplacePattern issue #19740', () {
      rp.testIssue19740CaptureGroupUndefined();
    });
    test('ReplacePattern buildReplaceStringWithCasePreserved', () {
      rp.testBuildReplaceStringWithCasePreserved();
    });
    test('ReplacePattern preserve case', () {
      rp.testPreserveCase();
    });
  });
}
