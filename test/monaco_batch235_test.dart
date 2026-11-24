// Truth replay for batch235: editor/common/config/diffEditor.ts (whole file).
//
// Expectations come from `tool/ts2dart/batch235_truth.json`, produced by
// `tool/ts2dart/_batch235_truth.cjs`, which transpiles and executes the REAL
// `diffEditor.ts` and captures every own field of the real exported
// `diffEditorDefaultOptions` object (including the two nested literals).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/diffEditor.dart' as diff;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch235_truth.json').readAsStringSync()));

/// Serialize `diffEditorDefaultOptions` to the same shape the harness captured.
Map<String, Object?> _snap() {
  final o = diff.diffEditorDefaultOptions;
  return <String, Object?>{
    'enableSplitViewResizing': o.enableSplitViewResizing,
    'splitViewDefaultRatio': o.splitViewDefaultRatio,
    'renderSideBySide': o.renderSideBySide,
    'renderMarginRevertIcon': o.renderMarginRevertIcon,
    'renderGutterMenu': o.renderGutterMenu,
    'maxComputationTime': o.maxComputationTime,
    'maxFileSize': o.maxFileSize,
    'ignoreTrimWhitespace': o.ignoreTrimWhitespace,
    'renderIndicators': o.renderIndicators,
    'originalEditable': o.originalEditable,
    'diffCodeLens': o.diffCodeLens,
    'renderOverviewRuler': o.renderOverviewRuler,
    'diffWordWrap': o.diffWordWrap,
    'diffAlgorithm': o.diffAlgorithm,
    'accessibilityVerbose': o.accessibilityVerbose,
    'experimental': <String, Object?>{
      'showMoves': (o.experimental as diff.DiffEditorExperimentalOptions).showMoves,
      'showEmptyDecorations':
          (o.experimental as diff.DiffEditorExperimentalOptions).showEmptyDecorations,
      'useTrueInlineView':
          (o.experimental as diff.DiffEditorExperimentalOptions).useTrueInlineView,
    },
    'hideUnchangedRegions': <String, Object?>{
      'enabled':
          (o.hideUnchangedRegions as diff.DiffEditorHideUnchangedRegionsOptions).enabled,
      'contextLineCount':
          (o.hideUnchangedRegions as diff.DiffEditorHideUnchangedRegionsOptions).contextLineCount,
      'minimumLineCount':
          (o.hideUnchangedRegions as diff.DiffEditorHideUnchangedRegionsOptions).minimumLineCount,
      'revealLineCount':
          (o.hideUnchangedRegions as diff.DiffEditorHideUnchangedRegionsOptions).revealLineCount,
    },
    'isInEmbeddedEditor': o.isInEmbeddedEditor,
    'onlyShowAccessibleDiffViewer': o.onlyShowAccessibleDiffViewer,
    'renderSideBySideInlineBreakpoint': o.renderSideBySideInlineBreakpoint,
    'useInlineViewWhenSpaceIsLimited': o.useInlineViewWhenSpaceIsLimited,
    'compactMode': o.compactMode,
    'hideOriginalLineNumbers': o.hideOriginalLineNumbers,
  };
}

void main() {
  final truth = _truth();
  final snap = _snap();

  test('batch235: diffEditorDefaultOptions key set matches the real source', () {
    final expectedKeys = (truth['keys'] as List).cast<String>();
    expect(snap.keys.toSet(), expectedKeys.toSet());
    expect(snap.length, expectedKeys.length);
  });

  test('batch235: every field matches the real source default', () {
    expect(snap, _map(truth['result']));
  });
}
