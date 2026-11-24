// Truth replay for batch233 (editorOptions.ts lines 6802-7102):
//   `EditorOptions` slice 3 (final) — the object literal from `rulers`
//   through `effectiveFullwidthCharacterWidth` (57 entries), plus the
//   trailing type-level declarations (erased in Dart per the documented
//   convention).
//
// Expectations come from `tool/ts2dart/batch233_truth.json`, produced by
// `tool/ts2dart/_batch233_truth.cjs`, which transpiles and executes the REAL
// `editorOptions.ts` (`nls` + `platform` stubbed) and reads each option from
// the real `EditorOptions` object / `editorOptionsRegistry`. The harness also
// asserts the source's sparse indexed write
// (`editorOptionsRegistry[option.id] === option`) for every covered entry and
// records the owner property of all 180 registry slots.
//
// JS `undefined` is replayed as Dart `null` (documented port convention); the
// harness deliberately omits a raw JS `null` input because `boolean(null)`
// differs between JS and Dart. Each validate case carries its own input.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch233_truth.json').readAsStringSync()));

/// Serializes the value carriers used by the nested option classes in this
/// slice to the same JSON shape the truth harness captured.
Object? _ser(Object? value) {
  if (value == null || value is bool || value is num || value is String) {
    return value;
  }
  if (value is Map) {
    return value.map<Object?, Object?>((Object? k, Object? v) =>
        MapEntry<Object?, Object?>(k as String, _ser(v)));
  }
  if (value is List) {
    return value.map<Object?>(_ser).toList();
  }
  if (value is opts.IRulerOption) {
    return <String, Object?>{'column': value.column, 'color': _ser(value.color)};
  }
  if (value is opts.InternalEditorScrollbarOptions) {
    return <String, Object?>{
      'arrowSize': value.arrowSize,
      'vertical': value.vertical,
      'horizontal': value.horizontal,
      'useShadows': value.useShadows,
      'verticalHasArrows': value.verticalHasArrows,
      'horizontalHasArrows': value.horizontalHasArrows,
      'handleMouseWheel': value.handleMouseWheel,
      'alwaysConsumeMouseWheel': value.alwaysConsumeMouseWheel,
      'horizontalScrollbarSize': value.horizontalScrollbarSize,
      'horizontalSliderSize': value.horizontalSliderSize,
      'verticalScrollbarSize': value.verticalScrollbarSize,
      'verticalSliderSize': value.verticalSliderSize,
      'scrollByPage': value.scrollByPage,
      'ignoreHorizontalScrollbarInContentHeight':
          value.ignoreHorizontalScrollbarInContentHeight,
    };
  }
  if (value is opts.EditorInlayHintsOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'fontSize': value.fontSize,
      'fontFamily': value.fontFamily,
      'padding': value.padding,
      'maximumLength': value.maximumLength,
    };
  }
  if (value is opts.SmartSelectOptions) {
    return <String, Object?>{
      'selectLeadingAndTrailingWhitespace':
          value.selectLeadingAndTrailingWhitespace,
      'selectSubwords': value.selectSubwords,
    };
  }
  if (value is opts.InternalSuggestOptions) {
    return <String, Object?>{
      'insertMode': value.insertMode,
      'filterGraceful': value.filterGraceful,
      'snippetsPreventQuickSuggestions': value.snippetsPreventQuickSuggestions,
      'localityBonus': value.localityBonus,
      'shareSuggestSelections': value.shareSuggestSelections,
      'selectionMode': value.selectionMode,
      'showIcons': value.showIcons,
      'showStatusBar': value.showStatusBar,
      'preview': value.preview,
      'previewMode': value.previewMode,
      'showInlineDetails': value.showInlineDetails,
      'fitWidthToDetails': value.fitWidthToDetails,
      'showMethods': value.showMethods,
      'showFunctions': value.showFunctions,
      'showConstructors': value.showConstructors,
      'showDeprecated': value.showDeprecated,
      'matchOnWordStartOnly': value.matchOnWordStartOnly,
      'showFields': value.showFields,
      'showVariables': value.showVariables,
      'showClasses': value.showClasses,
      'showStructs': value.showStructs,
      'showInterfaces': value.showInterfaces,
      'showModules': value.showModules,
      'showProperties': value.showProperties,
      'showEvents': value.showEvents,
      'showOperators': value.showOperators,
      'showUnits': value.showUnits,
      'showValues': value.showValues,
      'showConstants': value.showConstants,
      'showEnums': value.showEnums,
      'showEnumMembers': value.showEnumMembers,
      'showKeywords': value.showKeywords,
      'showWords': value.showWords,
      'showColors': value.showColors,
      'showFiles': value.showFiles,
      'showReferences': value.showReferences,
      'showFolders': value.showFolders,
      'showTypeParameters': value.showTypeParameters,
      'showIssues': value.showIssues,
      'showUsers': value.showUsers,
      'showSnippets': value.showSnippets,
    };
  }
  if (value is opts.InternalInlineSuggestOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'mode': value.mode,
      'showToolbar': value.showToolbar,
      'suppressSuggestions': value.suppressSuggestions,
      'keepOnBlur': value.keepOnBlur,
      'fontFamily': value.fontFamily,
      'syntaxHighlightingEnabled': value.syntaxHighlightingEnabled,
      'minShowDelay': value.minShowDelay,
      'suppressInSnippetMode': value.suppressInSnippetMode,
      'edits': _ser(value.edits),
      'triggerCommandOnProviderChange': value.triggerCommandOnProviderChange,
      'experimental': _ser(value.experimental),
    };
  }
  if (value is opts.InternalInlineSuggestEditsOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'showCollapsed': value.showCollapsed,
      'renderSideBySide': value.renderSideBySide,
      'allowCodeShifting': value.allowCodeShifting,
      'showLongDistanceHint': value.showLongDistanceHint,
      'longDistanceHintContextLineCount': value.longDistanceHintContextLineCount,
    };
  }
  if (value is opts.InternalInlineSuggestExperimentalOptions) {
    return <String, Object?>{
      'suppressInlineSuggestions': value.suppressInlineSuggestions,
      'showOnSuggestConflict': value.showOnSuggestConflict,
      'emptyResponseInformation': value.emptyResponseInformation,
    };
  }
  if (value is opts.InternalUnicodeHighlightOptions) {
    return <String, Object?>{
      'nonBasicASCII': value.nonBasicASCII,
      'invisibleCharacters': value.invisibleCharacters,
      'ambiguousCharacters': value.ambiguousCharacters,
      'includeComments': value.includeComments,
      'includeStrings': value.includeStrings,
      'allowedCharacters': _ser(value.allowedCharacters),
      'allowedLocales': _ser(value.allowedLocales),
    };
  }
  if (value is opts.EditorLayoutInfo) {
    return <String, Object?>{
      'width': value.width,
      'height': value.height,
      'glyphMarginLeft': value.glyphMarginLeft,
      'glyphMarginWidth': value.glyphMarginWidth,
      'glyphMarginDecorationLaneCount': value.glyphMarginDecorationLaneCount,
      'lineNumbersLeft': value.lineNumbersLeft,
      'lineNumbersWidth': value.lineNumbersWidth,
      'decorationsLeft': value.decorationsLeft,
      'decorationsWidth': value.decorationsWidth,
      'contentLeft': value.contentLeft,
      'contentWidth': value.contentWidth,
      'minimap': _ser(value.minimap),
      'viewportColumn': value.viewportColumn,
      'isWordWrapMinified': value.isWordWrapMinified,
      'isViewportWrapping': value.isViewportWrapping,
      'wrappingColumn': value.wrappingColumn,
      'verticalScrollbarWidth': value.verticalScrollbarWidth,
      'horizontalScrollbarHeight': value.horizontalScrollbarHeight,
      'overviewRuler': _ser(value.overviewRuler),
    };
  }
  if (value is opts.EditorMinimapLayoutInfo) {
    return <String, Object?>{
      'renderMinimap': value.renderMinimap,
      'minimapLeft': value.minimapLeft,
      'minimapWidth': value.minimapWidth,
      'minimapHeightIsEditorHeight': value.minimapHeightIsEditorHeight,
      'minimapIsSampling': value.minimapIsSampling,
      'minimapScale': value.minimapScale,
      'minimapLineHeight': value.minimapLineHeight,
      'minimapCanvasInnerWidth': value.minimapCanvasInnerWidth,
      'minimapCanvasInnerHeight': value.minimapCanvasInnerHeight,
      'minimapCanvasOuterWidth': value.minimapCanvasOuterWidth,
      'minimapCanvasOuterHeight': value.minimapCanvasOuterHeight,
    };
  }
  if (value is opts.OverviewRulerPosition) {
    return <String, Object?>{
      'top': value.top,
      'width': value.width,
      'height': value.height,
      'right': value.right,
    };
  }
  if (value is opts.EditorWrappingInfo) {
    return <String, Object?>{
      'isDominatedByLongLines': value.isDominatedByLongLines,
      'isWordWrapMinified': value.isWordWrapMinified,
      'isViewportWrapping': value.isViewportWrapping,
      'wrappingColumn': value.wrappingColumn,
    };
  }
  // No other carrier type occurs in this slice; fail loudly on source drift.
  throw StateError('unexpected value carrier: ${value.runtimeType}');
}

// Mirrors the harness's platform-token schema scan.
final RegExp _platformToken = RegExp(
    r'\b(linux|macintosh|macos|windows|web|native|browser|electron)\b',
    caseSensitive: false);

void _collectPlatformStrings(Object? value, String path, List<Object?> out) {
  if (value is String) {
    if (_platformToken.hasMatch(value)) {
      out.add(<String, Object?>{'path': path, 'value': value});
    }
  } else if (value is List) {
    for (int i = 0; i < value.length; i++) {
      _collectPlatformStrings(value[i], '$path[$i]', out);
    }
  } else if (value is Map) {
    value.forEach((Object? key, Object? v) {
      _collectPlatformStrings(v, path.isEmpty ? '$key' : '$path.$key', out);
    });
  }
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<String> order = (truth['order'] as List).cast<String>();

  // Touching every field forces Dart's lazily-initialized static fields, so
  // `register` has run for the whole slice before the registry assertions.
  final Map<String, opts.IEditorOption<Object?>> covered =
      <String, opts.IEditorOption<Object?>>{
    'rulers': opts.EditorOptions.rulers,
    'scrollbar': opts.EditorOptions.scrollbar,
    'scrollBeyondLastColumn': opts.EditorOptions.scrollBeyondLastColumn,
    'scrollBeyondLastLine': opts.EditorOptions.scrollBeyondLastLine,
    'scrollOnMiddleClick': opts.EditorOptions.scrollOnMiddleClick,
    'scrollPredominantAxis': opts.EditorOptions.scrollPredominantAxis,
    'selectionClipboard': opts.EditorOptions.selectionClipboard,
    'selectionHighlight': opts.EditorOptions.selectionHighlight,
    'selectionHighlightMaxLength':
        opts.EditorOptions.selectionHighlightMaxLength,
    'selectionHighlightMultiline':
        opts.EditorOptions.selectionHighlightMultiline,
    'selectedTextMatchMode': opts.EditorOptions.selectedTextMatchMode,
    'selectOnLineNumbers': opts.EditorOptions.selectOnLineNumbers,
    'showFoldingControls': opts.EditorOptions.showFoldingControls,
    'showUnused': opts.EditorOptions.showUnused,
    'showDeprecated': opts.EditorOptions.showDeprecated,
    'inlayHints': opts.EditorOptions.inlayHints,
    'snippetSuggestions': opts.EditorOptions.snippetSuggestions,
    'smartSelect': opts.EditorOptions.smartSelect,
    'smoothScrolling': opts.EditorOptions.smoothScrolling,
    'stopRenderingLineAfter': opts.EditorOptions.stopRenderingLineAfter,
    'suggest': opts.EditorOptions.suggest,
    'inlineSuggest': opts.EditorOptions.inlineSuggest,
    'inlineCompletionsAccessibilityVerbose':
        opts.EditorOptions.inlineCompletionsAccessibilityVerbose,
    'suggestFontSize': opts.EditorOptions.suggestFontSize,
    'suggestLineHeight': opts.EditorOptions.suggestLineHeight,
    'suggestOnTriggerCharacters': opts.EditorOptions.suggestOnTriggerCharacters,
    'suggestSelection': opts.EditorOptions.suggestSelection,
    'tabCompletion': opts.EditorOptions.tabCompletion,
    'tabIndex': opts.EditorOptions.tabIndex,
    'trimWhitespaceOnDelete': opts.EditorOptions.trimWhitespaceOnDelete,
    'unicodeHighlight': opts.EditorOptions.unicodeHighlight,
    'unusualLineTerminators': opts.EditorOptions.unusualLineTerminators,
    'useShadowDOM': opts.EditorOptions.useShadowDOM,
    'useTabStops': opts.EditorOptions.useTabStops,
    'wordBreak': opts.EditorOptions.wordBreak,
    'wordSegmenterLocales': opts.EditorOptions.wordSegmenterLocales,
    'wordSeparators': opts.EditorOptions.wordSeparators,
    'wordWrap': opts.EditorOptions.wordWrap,
    'wordWrapIndicator': opts.EditorOptions.wordWrapIndicator,
    'wordWrapBreakAfterCharacters':
        opts.EditorOptions.wordWrapBreakAfterCharacters,
    'wordWrapBreakBeforeCharacters':
        opts.EditorOptions.wordWrapBreakBeforeCharacters,
    'wordWrapColumn': opts.EditorOptions.wordWrapColumn,
    'wordWrapOverride1': opts.EditorOptions.wordWrapOverride1,
    'wordWrapOverride2': opts.EditorOptions.wordWrapOverride2,
    'wrapOnEscapedLineFeeds': opts.EditorOptions.wrapOnEscapedLineFeeds,
    'effectiveCursorStyle': opts.EditorOptions.effectiveCursorStyle,
    'editorClassName': opts.EditorOptions.editorClassName,
    'defaultColorDecorators': opts.EditorOptions.defaultColorDecorators,
    'pixelRatio': opts.EditorOptions.pixelRatio,
    'tabFocusMode': opts.EditorOptions.tabFocusMode,
    'layoutInfo': opts.EditorOptions.layoutInfo,
    'wrappingInfo': opts.EditorOptions.wrappingInfo,
    'wrappingIndent': opts.EditorOptions.wrappingIndent,
    'wrappingStrategy': opts.EditorOptions.wrappingStrategy,
    'effectiveEditContextEnabled':
        opts.EditorOptions.effectiveEditContextEnabled,
    'effectiveAllowVariableFonts':
        opts.EditorOptions.effectiveAllowVariableFonts,
    'effectiveFullwidthCharacterWidth':
        opts.EditorOptions.effectiveFullwidthCharacterWidth,
  };

  test('EditorOptions slice 3 covers exactly the captured 57 entries', () {
    expect(order.length, 57);
    expect(covered.keys.toSet(), order.toSet());
  });

  test('every entry id, name, defaultValue and schema match the real source',
      () {
    for (final String name in order) {
      final Map<String, dynamic> expected = _map(truth['entries'][name]);
      final opts.IEditorOption<Object?> option = covered[name]!;
      expect(option.id, expected['id'], reason: '$name.id');
      expect(option.name, expected['name'], reason: '$name.name');
      expect(_ser(option.defaultValue), expected['defaultValue'],
          reason: '$name.defaultValue');
      expect(option.schema, expected['schema'], reason: '$name.schema');
    }
  });

  test('validate matches every captured input/result pair', () {
    for (final String name in order) {
      final Map<String, dynamic> expected = _map(truth['entries'][name]);
      final opts.IEditorOption<Object?> option = covered[name]!;
      final List<Object?> cases = (expected['validate'] as List).cast<Object?>();
      for (final Object? entry in cases) {
        final Map<String, dynamic> c = _map(entry);
        final Object? result = option.validate(c['input']);
        expect(_ser(result), c['result'],
            reason: '$name.validate/${c['label']}');
      }
    }
  });

  test('registry length and slots reflect indexed registration with holes', () {
    final Set<int> ids = order
        .map((String name) => _map(truth['entries'][name])['id'] as int)
        .toSet();
    int maxId = 0;
    for (final int id in ids) {
      if (id > maxId) maxId = id;
    }
    final int expectedLength = maxId + 1;

    expect(opts.editorOptionsRegistry.length, expectedLength);
    for (final String name in order) {
      final Map<String, dynamic> expected = _map(truth['entries'][name]);
      final int id = expected['id'] as int;
      final opts.IEditorOption<Object?>? slot = opts.editorOptionsRegistry[id];
      expect(slot, isNotNull, reason: '$name must occupy slot $id');
      expect(slot, same(covered[name]), reason: '$name identity at slot $id');
      expect(slot!.name, expected['name'], reason: '$name.name at slot $id');
      expect(expected['registrySlotIsSelf'], true, reason: name);
    }
    for (int id = 0; id < expectedLength; id++) {
      if (!ids.contains(id)) {
        expect(opts.editorOptionsRegistry[id], isNull,
            reason: 'uncovered id $id must stay a null hole');
      }
    }
    expect(truth['editorOptionsRegistryLength'], 180);
    expect(expectedLength, 180);
  });

  test('platform-token schema strings match the real source', () {
    final List<Object?> captured = <Object?>[];
    for (final String name in order) {
      _collectPlatformStrings(covered[name]!.schema, name, captured);
    }
    expect(captured, truth['platformSchemaStrings']);
  });

  // Every EditorOptions static field, keyed by its source property name.
  // This is the whole 180-entry registry; the map literal also forces every
  // lazily-initialized static field before the completeness assertions run.
  // Declared as a function so the 180 fields are only touched by the
  // completeness test, after the hole-layout test above has run.
  Map<String, opts.IEditorOption<Object?>> allOptions() {
    return <String, opts.IEditorOption<Object?>>{
    'acceptSuggestionOnCommitCharacter':
        opts.EditorOptions.acceptSuggestionOnCommitCharacter,
    'acceptSuggestionOnEnter': opts.EditorOptions.acceptSuggestionOnEnter,
    'accessibilitySupport': opts.EditorOptions.accessibilitySupport,
    'accessibilityPageSize': opts.EditorOptions.accessibilityPageSize,
    'allowOverflow': opts.EditorOptions.allowOverflow,
    'allowVariableLineHeights': opts.EditorOptions.allowVariableLineHeights,
    'allowVariableFonts': opts.EditorOptions.allowVariableFonts,
    'allowVariableFontsInAccessibilityMode':
        opts.EditorOptions.allowVariableFontsInAccessibilityMode,
    'ariaLabel': opts.EditorOptions.ariaLabel,
    'ariaRequired': opts.EditorOptions.ariaRequired,
    'autoClosingBrackets': opts.EditorOptions.autoClosingBrackets,
    'autoClosingComments': opts.EditorOptions.autoClosingComments,
    'screenReaderAnnounceInlineSuggestion':
        opts.EditorOptions.screenReaderAnnounceInlineSuggestion,
    'autoClosingDelete': opts.EditorOptions.autoClosingDelete,
    'autoClosingOvertype': opts.EditorOptions.autoClosingOvertype,
    'autoClosingQuotes': opts.EditorOptions.autoClosingQuotes,
    'autoIndent': opts.EditorOptions.autoIndent,
    'autoIndentOnPaste': opts.EditorOptions.autoIndentOnPaste,
    'autoIndentOnPasteWithinString':
        opts.EditorOptions.autoIndentOnPasteWithinString,
    'automaticLayout': opts.EditorOptions.automaticLayout,
    'autoSurround': opts.EditorOptions.autoSurround,
    'bracketPairColorization': opts.EditorOptions.bracketPairColorization,
    'bracketPairGuides': opts.EditorOptions.bracketPairGuides,
    'codeLens': opts.EditorOptions.codeLens,
    'codeLensFontFamily': opts.EditorOptions.codeLensFontFamily,
    'codeLensFontSize': opts.EditorOptions.codeLensFontSize,
    'colorDecorators': opts.EditorOptions.colorDecorators,
    'colorDecoratorsLimit': opts.EditorOptions.colorDecoratorsLimit,
    'columnSelection': opts.EditorOptions.columnSelection,
    'comments': opts.EditorOptions.comments,
    'contextmenu': opts.EditorOptions.contextmenu,
    'copyWithSyntaxHighlighting': opts.EditorOptions.copyWithSyntaxHighlighting,
    'cursorBlinking': opts.EditorOptions.cursorBlinking,
    'cursorSmoothCaretAnimation': opts.EditorOptions.cursorSmoothCaretAnimation,
    'cursorStyle': opts.EditorOptions.cursorStyle,
    'cursorSurroundingLines': opts.EditorOptions.cursorSurroundingLines,
    'cursorSurroundingLinesStyle':
        opts.EditorOptions.cursorSurroundingLinesStyle,
    'cursorWidth': opts.EditorOptions.cursorWidth,
    'cursorHeight': opts.EditorOptions.cursorHeight,
    'disableLayerHinting': opts.EditorOptions.disableLayerHinting,
    'disableMonospaceOptimizations':
        opts.EditorOptions.disableMonospaceOptimizations,
    'domReadOnly': opts.EditorOptions.domReadOnly,
    'dragAndDrop': opts.EditorOptions.dragAndDrop,
    'dropIntoEditor': opts.EditorOptions.dropIntoEditor,
    'editContext': opts.EditorOptions.editContext,
    'emptySelectionClipboard': opts.EditorOptions.emptySelectionClipboard,
    'experimentalGpuAcceleration':
        opts.EditorOptions.experimentalGpuAcceleration,
    'experimentalWhitespaceRendering':
        opts.EditorOptions.experimentalWhitespaceRendering,
    'extraEditorClassName': opts.EditorOptions.extraEditorClassName,
    'fastScrollSensitivity': opts.EditorOptions.fastScrollSensitivity,
    'find': opts.EditorOptions.find,
    'fixedOverflowWidgets': opts.EditorOptions.fixedOverflowWidgets,
    'folding': opts.EditorOptions.folding,
    'foldingStrategy': opts.EditorOptions.foldingStrategy,
    'foldingHighlight': opts.EditorOptions.foldingHighlight,
    'foldingImportsByDefault': opts.EditorOptions.foldingImportsByDefault,
    'foldingMaximumRegions': opts.EditorOptions.foldingMaximumRegions,
    'unfoldOnClickAfterEndOfLine':
        opts.EditorOptions.unfoldOnClickAfterEndOfLine,
    'fontFamily': opts.EditorOptions.fontFamily,
    'fontInfo': opts.EditorOptions.fontInfo,
    'fontLigatures2': opts.EditorOptions.fontLigatures2,
    'fontSize': opts.EditorOptions.fontSize,
    'fontWeight': opts.EditorOptions.fontWeight,
    'fontVariations': opts.EditorOptions.fontVariations,
    'formatOnPaste': opts.EditorOptions.formatOnPaste,
    'formatOnType': opts.EditorOptions.formatOnType,
    'glyphMargin': opts.EditorOptions.glyphMargin,
    'gotoLocation': opts.EditorOptions.gotoLocation,
    'hideCursorInOverviewRuler': opts.EditorOptions.hideCursorInOverviewRuler,
    'hover': opts.EditorOptions.hover,
    'inDiffEditor': opts.EditorOptions.inDiffEditor,
    'inlineSuggest': opts.EditorOptions.inlineSuggest,
    'letterSpacing': opts.EditorOptions.letterSpacing,
    'lightbulb': opts.EditorOptions.lightbulb,
    'lineDecorationsWidth': opts.EditorOptions.lineDecorationsWidth,
    'lineHeight': opts.EditorOptions.lineHeight,
    'lineNumbers': opts.EditorOptions.lineNumbers,
    'lineNumbersMinChars': opts.EditorOptions.lineNumbersMinChars,
    'linkedEditing': opts.EditorOptions.linkedEditing,
    'links': opts.EditorOptions.links,
    'markdownImages': opts.EditorOptions.markdownImages,
    'matchBrackets': opts.EditorOptions.matchBrackets,
    'minimap': opts.EditorOptions.minimap,
    'mouseStyle': opts.EditorOptions.mouseStyle,
    'mouseWheelScrollSensitivity':
        opts.EditorOptions.mouseWheelScrollSensitivity,
    'mouseWheelZoom': opts.EditorOptions.mouseWheelZoom,
    'multiCursorMergeOverlapping':
        opts.EditorOptions.multiCursorMergeOverlapping,
    'multiCursorModifier': opts.EditorOptions.multiCursorModifier,
    'mouseMiddleClickAction': opts.EditorOptions.mouseMiddleClickAction,
    'multiCursorPaste': opts.EditorOptions.multiCursorPaste,
    'multiCursorLimit': opts.EditorOptions.multiCursorLimit,
    'occurrencesHighlight': opts.EditorOptions.occurrencesHighlight,
    'occurrencesHighlightDelay': opts.EditorOptions.occurrencesHighlightDelay,
    'occurrencesHighlightFromAllProviders':
        opts.EditorOptions.occurrencesHighlightFromAllProviders,
    'overtypeCursorStyle': opts.EditorOptions.overtypeCursorStyle,
    'overtypeOnPaste': opts.EditorOptions.overtypeOnPaste,
    'overviewRulerBorder': opts.EditorOptions.overviewRulerBorder,
    'overviewRulerLanes': opts.EditorOptions.overviewRulerLanes,
    'padding': opts.EditorOptions.padding,
    'pasteAs': opts.EditorOptions.pasteAs,
    'parameterHints': opts.EditorOptions.parameterHints,
    'peekWidgetDefaultFocus': opts.EditorOptions.peekWidgetDefaultFocus,
    'placeholder': opts.EditorOptions.placeholder,
    'definitionLinkOpensInPeek': opts.EditorOptions.definitionLinkOpensInPeek,
    'quickSuggestions': opts.EditorOptions.quickSuggestions,
    'quickSuggestionsDelay': opts.EditorOptions.quickSuggestionsDelay,
    'readOnly': opts.EditorOptions.readOnly,
    'readOnlyMessage': opts.EditorOptions.readOnlyMessage,
    'renameOnType': opts.EditorOptions.renameOnType,
    'renderRichScreenReaderContent':
        opts.EditorOptions.renderRichScreenReaderContent,
    'renderControlCharacters': opts.EditorOptions.renderControlCharacters,
    'renderFinalNewline': opts.EditorOptions.renderFinalNewline,
    'renderLineHighlight': opts.EditorOptions.renderLineHighlight,
    'renderLineHighlightOnlyWhenFocus':
        opts.EditorOptions.renderLineHighlightOnlyWhenFocus,
    'renderValidationDecorations':
        opts.EditorOptions.renderValidationDecorations,
    'renderWhitespace': opts.EditorOptions.renderWhitespace,
    'revealHorizontalRightPadding':
        opts.EditorOptions.revealHorizontalRightPadding,
    'roundedSelection': opts.EditorOptions.roundedSelection,
    'rulers': opts.EditorOptions.rulers,
    'scrollbar': opts.EditorOptions.scrollbar,
    'scrollBeyondLastColumn': opts.EditorOptions.scrollBeyondLastColumn,
    'scrollBeyondLastLine': opts.EditorOptions.scrollBeyondLastLine,
    'scrollPredominantAxis': opts.EditorOptions.scrollPredominantAxis,
    'selectionClipboard': opts.EditorOptions.selectionClipboard,
    'selectionHighlight': opts.EditorOptions.selectionHighlight,
    'selectionHighlightMaxLength':
        opts.EditorOptions.selectionHighlightMaxLength,
    'selectionHighlightMultiline':
        opts.EditorOptions.selectionHighlightMultiline,
    'selectedTextMatchMode': opts.EditorOptions.selectedTextMatchMode,
    'selectOnLineNumbers': opts.EditorOptions.selectOnLineNumbers,
    'showFoldingControls': opts.EditorOptions.showFoldingControls,
    'showUnused': opts.EditorOptions.showUnused,
    'snippetSuggestions': opts.EditorOptions.snippetSuggestions,
    'smartSelect': opts.EditorOptions.smartSelect,
    'smoothScrolling': opts.EditorOptions.smoothScrolling,
    'stickyScroll': opts.EditorOptions.stickyScroll,
    'stickyTabStops': opts.EditorOptions.stickyTabStops,
    'stopRenderingLineAfter': opts.EditorOptions.stopRenderingLineAfter,
    'suggest': opts.EditorOptions.suggest,
    'suggestFontSize': opts.EditorOptions.suggestFontSize,
    'suggestLineHeight': opts.EditorOptions.suggestLineHeight,
    'suggestOnTriggerCharacters': opts.EditorOptions.suggestOnTriggerCharacters,
    'suggestSelection': opts.EditorOptions.suggestSelection,
    'tabCompletion': opts.EditorOptions.tabCompletion,
    'tabIndex': opts.EditorOptions.tabIndex,
    'trimWhitespaceOnDelete': opts.EditorOptions.trimWhitespaceOnDelete,
    'unicodeHighlight': opts.EditorOptions.unicodeHighlight,
    'unusualLineTerminators': opts.EditorOptions.unusualLineTerminators,
    'useShadowDOM': opts.EditorOptions.useShadowDOM,
    'useTabStops': opts.EditorOptions.useTabStops,
    'wordBreak': opts.EditorOptions.wordBreak,
    'wordSegmenterLocales': opts.EditorOptions.wordSegmenterLocales,
    'wordSeparators': opts.EditorOptions.wordSeparators,
    'wordWrap': opts.EditorOptions.wordWrap,
    'wordWrapBreakAfterCharacters':
        opts.EditorOptions.wordWrapBreakAfterCharacters,
    'wordWrapBreakBeforeCharacters':
        opts.EditorOptions.wordWrapBreakBeforeCharacters,
    'wordWrapColumn': opts.EditorOptions.wordWrapColumn,
    'wordWrapOverride1': opts.EditorOptions.wordWrapOverride1,
    'wordWrapOverride2': opts.EditorOptions.wordWrapOverride2,
    'wrappingIndent': opts.EditorOptions.wrappingIndent,
    'wrappingStrategy': opts.EditorOptions.wrappingStrategy,
    'showDeprecated': opts.EditorOptions.showDeprecated,
    'inertialScroll': opts.EditorOptions.inertialScroll,
    'inlayHints': opts.EditorOptions.inlayHints,
    'wrapOnEscapedLineFeeds': opts.EditorOptions.wrapOnEscapedLineFeeds,
    'wordWrapIndicator': opts.EditorOptions.wordWrapIndicator,
    'effectiveCursorStyle': opts.EditorOptions.effectiveCursorStyle,
    'editorClassName': opts.EditorOptions.editorClassName,
    'pixelRatio': opts.EditorOptions.pixelRatio,
    'tabFocusMode': opts.EditorOptions.tabFocusMode,
    'layoutInfo': opts.EditorOptions.layoutInfo,
    'wrappingInfo': opts.EditorOptions.wrappingInfo,
    'defaultColorDecorators': opts.EditorOptions.defaultColorDecorators,
    'colorDecoratorActivatedOn': opts.EditorOptions.colorDecoratorActivatedOn,
    'inlineCompletionsAccessibilityVerbose':
        opts.EditorOptions.inlineCompletionsAccessibilityVerbose,
    'effectiveEditContextEnabled':
        opts.EditorOptions.effectiveEditContextEnabled,
    'scrollOnMiddleClick': opts.EditorOptions.scrollOnMiddleClick,
    'effectiveAllowVariableFonts':
        opts.EditorOptions.effectiveAllowVariableFonts,
    'doubleClickSelectsBlock': opts.EditorOptions.doubleClickSelectsBlock,
    'fullwidthCharacterWidth': opts.EditorOptions.fullwidthCharacterWidth,
    'effectiveFullwidthCharacterWidth':
        opts.EditorOptions.effectiveFullwidthCharacterWidth,
    };
  }

  test('full registry completeness: 180 slots, all non-null, self-indexed', () {
    final Map<String, opts.IEditorOption<Object?>> allOptionsMap = allOptions();
    final List<Object?> slots = (truth['registrySlots'] as List).cast<Object?>();
    expect(slots.length, 180);
    expect(allOptionsMap.length, 180);
    expect(allOptionsMap.keys.toSet(), slots.toSet());
    expect(opts.editorOptionsRegistry.length, 180);

    for (int id = 0; id < 180; id++) {
      final String propertyName = slots[id] as String;
      final opts.IEditorOption<Object?> option = allOptionsMap[propertyName]!;
      expect(option.id, id, reason: '$propertyName.id must be $id');
      final opts.IEditorOption<Object?>? slot = opts.editorOptionsRegistry[id];
      expect(slot, isNotNull, reason: 'slot $id must not be null');
      expect(slot, same(option),
          reason: 'slot $id must be $propertyName itself');
    }
    final List<Object?> owners =
        (truth['registrySlotOwners'] as List).cast<Object?>();
    expect(owners.length, 180);
    for (final Object? owner in owners) {
      final Map<String, dynamic> o = _map(owner);
      final opts.IEditorOption<Object?> option =
          allOptionsMap[o['propertyName'] as String]!;
      expect(option.id, o['id'], reason: '${o['propertyName']}.id');
      expect(option.name, o['name'], reason: '${o['propertyName']}.name');
    }
  });
}
