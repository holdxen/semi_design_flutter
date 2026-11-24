// Truth replay for batch237: editor/browser/config/editorConfiguration.ts
// (the whole 358-line file): digitCount, getExtraEditorClassName,
// ValidatedEditorOptions, ComputedEditorOptions, EditorOptionsUtil
// (validateOptions / computeOptions / _deepEquals / checkEquals / applyUpdate)
// and deepCloneAndMigrateOptions.
//
// Expectations come from `tool/ts2dart/batch237_truth.json`, produced by
// `tool/ts2dart/_batch237_truth.cjs`, which transpiles and executes the REAL
// editorConfiguration.ts through a custom loader. `editorOptions.ts` (all 180
// real options + registry), arrays.ts, objects.ts, event.ts, lifecycle.ts,
// fontInfo.ts, fontInfoFromSettings.ts and migrateOptions.ts are executed for
// real; only the DOM/browser coupling is stubbed. Every captured value comes
// from the real source, never from a handmade expected list.
//
// The DOM-coupled `EditorConfiguration` class itself is compile-checked only
// (it needs a live browser/DOM); all pure-logic members are truth-replayed.
// `digitCount(-5)` is non-terminating in the source (Math.floor(-0.5) === -1
// and Math.floor(-0.1) === -1), so it is recorded in the truth file but not
// executed — the Dart port reproduces the same non-terminating behavior.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/config/editorConfiguration.dart' as ec;
import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;
import '../lib/src/monaco/editor/common/config/fontInfo.dart'
    show FontInfo, FontInfoOptions;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch237_truth.json').readAsStringSync()));

Map<String, Object?> _raw(Object? value) =>
    (value as Map).cast<String, Object?>();

/// Mirrors the harness's `normalize`/`valueType` tagging. Dart `null` carries
/// both JS `undefined` and `null`; the two affected slots are `undefined` in
/// the real source, so `null` is reported as `undefined` here.
String _valueType(Object? value) {
  if (value == null) return 'undefined';
  if (value is bool) return 'boolean';
  if (value is num) return 'number';
  if (value is String) return 'string';
  if (value is Function) return 'function';
  if (value is List) return 'array';
  if (value is Map) return 'object';
  return 'object';
}

/// Serializes computed/validated value carriers to the same JSON shape the
/// harness captured (JSON.stringify on the real TS objects, with
/// `undefined` -> `null` and functions -> `'<function>'`).
Object? _ser(Object? value) {
  if (value == null || value is bool || value is num || value is String) {
    return value;
  }
  if (value is Function) return '<function>';
  if (value is List) return value.map<Object?>(_ser).toList();
  if (value is Map) {
    return value.map<String, Object?>((Object? k, Object? v) =>
        MapEntry<String, Object?>(k as String, _ser(v)));
  }
  if (value is opts.InternalBracketPairColorizationOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'independentColorPoolPerBracketType':
          value.independentColorPoolPerBracketType,
    };
  }
  if (value is opts.InternalGuidesOptions) {
    return <String, Object?>{
      'bracketPairs': value.bracketPairs,
      'bracketPairsHorizontal': value.bracketPairsHorizontal,
      'highlightActiveBracketPair': value.highlightActiveBracketPair,
      'indentation': value.indentation,
      'highlightActiveIndentation': value.highlightActiveIndentation,
    };
  }
  if (value is opts.EditorCommentsOptions) {
    return <String, Object?>{
      'insertSpace': value.insertSpace,
      'ignoreEmptyLines': value.ignoreEmptyLines,
    };
  }
  if (value is opts.EditorDropIntoEditorOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'showDropSelector': value.showDropSelector,
    };
  }
  if (value is opts.EditorFindOptions) {
    return <String, Object?>{
      'cursorMoveOnType': value.cursorMoveOnType,
      'findOnType': value.findOnType,
      'seedSearchStringFromSelection': value.seedSearchStringFromSelection,
      'autoFindInSelection': value.autoFindInSelection,
      'globalFindClipboard': value.globalFindClipboard,
      'addExtraSpaceOnTop': value.addExtraSpaceOnTop,
      'loop': value.loop,
      'closeOnResult': value.closeOnResult,
      'history': value.history,
      'replaceHistory': value.replaceHistory,
    };
  }
  if (value is FontInfo) {
    // The two `Brand` fields are `undefined` on the TS instance and are
    // normalized to `null` by the harness; Dart's port has private equivalents.
    return <String, Object?>{
      '_bareFontInfoBrand': null,
      'pixelRatio': value.pixelRatio,
      'fontFamily': value.fontFamily,
      'fontWeight': value.fontWeight,
      'fontSize': value.fontSize,
      'fontFeatureSettings': value.fontFeatureSettings,
      'fontVariationSettings': value.fontVariationSettings,
      'lineHeight': value.lineHeight,
      'letterSpacing': value.letterSpacing,
      '_editorStylingBrand': null,
      'version': value.version,
      'isTrusted': value.isTrusted,
      'isMonospace': value.isMonospace,
      'typicalHalfwidthCharacterWidth': value.typicalHalfwidthCharacterWidth,
      'typicalFullwidthCharacterWidth': value.typicalFullwidthCharacterWidth,
      'canUseHalfwidthRightwardsArrow': value.canUseHalfwidthRightwardsArrow,
      'spaceWidth': value.spaceWidth,
      'middotWidth': value.middotWidth,
      'wsmiddotWidth': value.wsmiddotWidth,
      'maxDigitWidth': value.maxDigitWidth,
    };
  }
  if (value is opts.GoToLocationOptions) {
    return <String, Object?>{
      'multiple': value.multiple,
      'multipleDefinitions': value.multipleDefinitions,
      'multipleTypeDefinitions': value.multipleTypeDefinitions,
      'multipleDeclarations': value.multipleDeclarations,
      'multipleImplementations': value.multipleImplementations,
      'multipleReferences': value.multipleReferences,
      'multipleTests': value.multipleTests,
      'alternativeDefinitionCommand': value.alternativeDefinitionCommand,
      'alternativeTypeDefinitionCommand': value.alternativeTypeDefinitionCommand,
      'alternativeDeclarationCommand': value.alternativeDeclarationCommand,
      'alternativeImplementationCommand': value.alternativeImplementationCommand,
      'alternativeReferenceCommand': value.alternativeReferenceCommand,
      'alternativeTestsCommand': value.alternativeTestsCommand,
    };
  }
  if (value is opts.IGotoLocationOptions) {
    return <String, Object?>{
      'multiple': value.multiple,
      'multipleDefinitions': value.multipleDefinitions,
      'multipleTypeDefinitions': value.multipleTypeDefinitions,
      'multipleDeclarations': value.multipleDeclarations,
      'multipleImplementations': value.multipleImplementations,
      'multipleReferences': value.multipleReferences,
      'multipleTests': value.multipleTests,
      'alternativeDefinitionCommand': value.alternativeDefinitionCommand,
      'alternativeTypeDefinitionCommand': value.alternativeTypeDefinitionCommand,
      'alternativeDeclarationCommand': value.alternativeDeclarationCommand,
      'alternativeImplementationCommand': value.alternativeImplementationCommand,
      'alternativeReferenceCommand': value.alternativeReferenceCommand,
      'alternativeTestsCommand': value.alternativeTestsCommand,
    };
  }
  if (value is opts.EditorHoverOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'delay': value.delay,
      'sticky': value.sticky,
      'hidingDelay': value.hidingDelay,
      'above': value.above,
      'showLongLineWarning': value.showLongLineWarning,
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
  if (value is opts.EditorLightbulbOptions) {
    return <String, Object?>{'enabled': value.enabled};
  }
  if (value is opts.InternalEditorRenderLineNumbersOptions) {
    return <String, Object?>{
      'renderType': value.renderType,
      'renderFn': value.renderFn == null ? null : '<function>',
    };
  }
  if (value is opts.EditorMarkdownImagesOptions) {
    return <String, Object?>{'allowedOrigins': _ser(value.allowedOrigins)};
  }
  if (value is opts.EditorMinimapOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'autohide': value.autohide,
      'size': value.size,
      'side': value.side,
      'showSlider': value.showSlider,
      'renderCharacters': value.renderCharacters,
      'scale': value.scale,
      'maxColumn': value.maxColumn,
      'showRegionSectionHeaders': value.showRegionSectionHeaders,
      'showMarkSectionHeaders': value.showMarkSectionHeaders,
      'markSectionHeaderRegex': value.markSectionHeaderRegex,
      'sectionHeaderFontSize': value.sectionHeaderFontSize,
      'sectionHeaderLetterSpacing': value.sectionHeaderLetterSpacing,
    };
  }
  if (value is opts.EditorPaddingOptions) {
    return <String, Object?>{'top': value.top, 'bottom': value.bottom};
  }
  if (value is opts.EditorPasteAsOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'showPasteSelector': value.showPasteSelector,
    };
  }
  if (value is opts.EditorParameterHintsOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'cycle': value.cycle,
    };
  }
  if (value is opts.InternalQuickSuggestionsOptions) {
    return <String, Object?>{
      'other': value.other,
      'comments': value.comments,
      'strings': value.strings,
    };
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
  if (value is opts.SmartSelectOptions) {
    return <String, Object?>{
      'selectLeadingAndTrailingWhitespace':
          value.selectLeadingAndTrailingWhitespace,
      'selectSubwords': value.selectSubwords,
    };
  }
  if (value is opts.EditorStickyScrollOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'maxLineCount': value.maxLineCount,
      'defaultModel': value.defaultModel,
      'scrollWithEditor': value.scrollWithEditor,
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
  if (value is opts.EditorInlayHintsOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'fontSize': value.fontSize,
      'fontFamily': value.fontFamily,
      'padding': value.padding,
      'maximumLength': value.maximumLength,
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
  throw StateError('unexpected value carrier: ${value.runtimeType}');
}

void _expectSlot(Object? actual, Object? expected, String label) {
  final Map<String, dynamic> e = _map(expected);
  expect(_valueType(actual), e['type'], reason: 'type of $label');
  expect(_ser(actual), e['value'], reason: 'value of $label');
}

/// Dart replay of the JS `IEnvironmentalOptions` object literal the harness
/// passed to the real `computeOptions`.
class _Env implements opts.IEnvironmentalOptions {
  _Env(this._fields, [FontInfo? sharedFontInfo])
      : fontInfo = sharedFontInfo ?? FontInfo(
          FontInfoOptions(
            pixelRatio:
                ((_fields['fontInfo'] as Map)['pixelRatio'] as num? ?? 1).toDouble(),
            fontFamily: (_fields['fontInfo'] as Map)['fontFamily'] as String? ?? '',
            fontWeight: (_fields['fontInfo'] as Map)['fontWeight'] as String? ?? '',
            fontSize:
                ((_fields['fontInfo'] as Map)['fontSize'] as num? ?? 0).toDouble(),
            fontFeatureSettings:
                (_fields['fontInfo'] as Map)['fontFeatureSettings'] as String? ?? '',
            fontVariationSettings:
                (_fields['fontInfo'] as Map)['fontVariationSettings'] as String? ?? '',
            lineHeight:
                ((_fields['fontInfo'] as Map)['lineHeight'] as num? ?? 0).toDouble(),
            letterSpacing:
                ((_fields['fontInfo'] as Map)['letterSpacing'] as num? ?? 0).toDouble(),
            isMonospace:
                (_fields['fontInfo'] as Map)['isMonospace'] as bool? ?? false,
            typicalHalfwidthCharacterWidth:
                ((_fields['fontInfo'] as Map)['typicalHalfwidthCharacterWidth']
                    as num? ??
                    0).toDouble(),
            typicalFullwidthCharacterWidth:
                ((_fields['fontInfo'] as Map)['typicalFullwidthCharacterWidth']
                    as num? ??
                    0).toDouble(),
            canUseHalfwidthRightwardsArrow:
                (_fields['fontInfo'] as Map)['canUseHalfwidthRightwardsArrow']
                    as bool? ??
                    false,
            spaceWidth: ((_fields['fontInfo'] as Map)['spaceWidth'] as num? ?? 0).toDouble(),
            middotWidth:
                ((_fields['fontInfo'] as Map)['middotWidth'] as num? ?? 0).toDouble(),
            wsmiddotWidth:
                ((_fields['fontInfo'] as Map)['wsmiddotWidth'] as num? ?? 0).toDouble(),
            maxDigitWidth:
                ((_fields['fontInfo'] as Map)['maxDigitWidth'] as num? ?? 0).toDouble(),
          ),
          (_fields['fontInfo'] as Map)['isTrusted'] as bool? ?? false,
        );

  final Map<String, Object?> _fields;

  /// 1:1: the harness passes one `new ComputeOptionsMemory()` instance;
  /// computed options mutate it, so it must be stable across reads.
  @override
  opts.ComputeOptionsMemory? memory = opts.ComputeOptionsMemory();

  @override
  double get outerWidth => (_fields['outerWidth'] as num).toDouble();

  @override
  double get outerHeight => (_fields['outerHeight'] as num).toDouble();

  @override
  FontInfo fontInfo;

  @override
  String get extraEditorClassName => _fields['extraEditorClassName'] as String;

  @override
  bool get isDominatedByLongLines => _fields['isDominatedByLongLines'] as bool;

  @override
  num get viewLineCount => _fields['viewLineCount'] as num;

  @override
  num get lineNumbersDigitCount => _fields['lineNumbersDigitCount'] as num;

  @override
  bool get emptySelectionClipboard => _fields['emptySelectionClipboard'] as bool;

  @override
  double get pixelRatio => (_fields['pixelRatio'] as num).toDouble();

  @override
  bool get tabFocusMode => _fields['tabFocusMode'] as bool;

  @override
  String get inputMode => _fields['inputMode'] as String;

  @override
  int get accessibilitySupport => _fields['accessibilitySupport'] as int;

  @override
  num get glyphMarginDecorationLaneCount =>
      _fields['glyphMarginDecorationLaneCount'] as num;

  @override
  bool get editContextSupported => _fields['editContextSupported'] as bool;
}

ec.ValidatedEditorOptions _validate(Object? rawInput) {
  final Map<String, Object?> migrated =
      ec.deepCloneAndMigrateOptions(_raw(rawInput));
  return ec.EditorOptionsUtil.validateOptions(migrated);
}

ec.ComputedEditorOptions _compute(
  Object? rawInput,
  Map<String, dynamic> env, [
  FontInfo? sharedFontInfo,
]) {
  final ec.ValidatedEditorOptions validated = _validate(rawInput);
  return ec.EditorOptionsUtil.computeOptions(validated, _Env(env, sharedFontInfo));
}

FontInfo _fontInfoFromEnv(Map<String, dynamic> env) =>
    _Env(env).fontInfo;

void main() {
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
  // Force Dart's lazily-initialized EditorOptions static fields so the real
  // 180-slot registry is fully populated before any util call (same as the
  // batch233 completeness test).
  allOptions();

  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> scenario =
      _map((truth['scenarios'] as List).first);

  group('batch237 truth replay - digitCount', () {
    for (final entry in (scenario['digitCount'] as Map)['cases'] as List) {
      final Map<String, dynamic> c = _map(entry);
      test('digitCount(${c['input']})', () {
        expect(ec.digitCount(c['input'] as num), c['result']);
      });
    }
    test('negative input is non-terminating in the real source', () {
      final Map<String, dynamic> nt = _map(
        ((scenario['digitCount'] as Map)['nonTerminating'] as List).first,
      );
      expect(nt['input'], -5);
      expect(nt['note'], contains('loops forever'));
      // The Dart port intentionally has no guard, so it loops identically;
      // calling it here would hang the test, exactly as in the TS source.
    });
  });

  group('batch237 truth replay - getExtraEditorClassName', () {
    for (final entry in truth['extraEditorClassNameScenarios'] as List) {
      final Map<String, dynamic> c = _map(entry);
      final Map<String, dynamic> platformStub = _map(c['platformStub']);
      final Map<String, dynamic> browserStub = _map(c['browserStub']);
      test('extra class: ${c['label']}', () {
        expect(
          ec.getExtraEditorClassName(
            isSafari: browserStub['isSafari'] as bool,
            isWebkitWebView: browserStub['isWebkitWebView'] as bool,
            isMacintosh: platformStub['isMacintosh'] as bool,
          ),
          c['result'],
        );
      });
    }
  });

  group('batch237 truth replay - validateOptions', () {
    final Map<String, dynamic> expected = _map(scenario['validated']);
    final Object? input = scenario['validatedInput'];
    test('every registry slot matches the real validated value', () {
      final ec.ValidatedEditorOptions validated = _validate(input);
      for (final MapEntry<String, dynamic> e in expected.entries) {
        final int id = int.parse(e.key);
        _expectSlot(validated.get(id), e.value, 'validated slot $id');
      }
    });
  });

  group('batch237 truth replay - computeOptions', () {
    final Map<String, dynamic> c = _map(scenario['computeOptions']);
    final Map<String, dynamic> expected = _map(c['result']);
    final Map<String, dynamic> env = _map(c['env']);
    test('every registry slot matches the real computed value', () {
      final ec.ComputedEditorOptions computed = _compute(c['input'], env);
      for (final MapEntry<String, dynamic> e in expected.entries) {
        final int id = int.parse(e.key);
        _expectSlot(computed.get(id), e.value, 'computed slot $id');
      }
    });
    test('uninitialized read throws', () {
      final ec.ComputedEditorOptions empty = ec.ComputedEditorOptions();
      expect(() => empty.get(0), throwsStateError);
    });
  });

  group('batch237 truth replay - checkEquals', () {
    final Map<String, dynamic> c = _map(scenario['computeOptions']);
    final Map<String, dynamic> env = _map(c['env']);
    for (final entry in scenario['checkEquals'] as List) {
      final Map<String, dynamic> t = _map(entry);
      test('checkEquals: ${t['label']}', () {
        final FontInfo sharedFontInfo = _fontInfoFromEnv(env);
        final ec.ComputedEditorOptions a = _compute(t['aInput'], env, sharedFontInfo);
        final ec.ComputedEditorOptions b = _compute(t['bInput'], env, sharedFontInfo);
        final opts.ConfigurationChangedEvent? event =
            ec.EditorOptionsUtil.checkEquals(a, b);
        if (t['result'] == null) {
          expect(event, isNull);
        } else {
          final Map<String, dynamic> expected = _map(t['result']);
          expect(event, isNotNull);
          for (final MapEntry<String, dynamic> e in expected.entries) {
            final int id = int.parse(e.key);
            expect(event!.hasChanged(id), e.value,
                reason: 'changed flag for slot $id');
          }
        }
      });
    }
  });

  group('batch237 truth replay - applyUpdate', () {
    for (final entry in scenario['applyUpdate'] as List) {
      final Map<String, dynamic> c = _map(entry);
      test('applyUpdate: ${c['label']}', () {
        final Map<String, Object?> base =
            ec.deepCloneAndMigrateOptions(_raw(c['base']));
        final bool didChange =
            ec.EditorOptionsUtil.applyUpdate(base, _raw(c['update']));
        expect(didChange, c['didChange']);
        final Map<String, Object?> expected = _raw(c['result']);
        expect(base.keys.toSet(), expected.keys.toSet());
        for (final MapEntry<String, Object?> e in expected.entries) {
          expect(_ser(base[e.key]), _ser(e.value),
              reason: 'mutated option ${e.key}');
        }
      });
    }
  });

  group('batch237 truth replay - deepCloneAndMigrateOptions', () {
    for (final entry in scenario['deepCloneAndMigrateOptions'] as List) {
      final Map<String, dynamic> c = _map(entry);
      test('migrate: ${c['label']}', () {
        final Map<String, Object?> result =
            ec.deepCloneAndMigrateOptions(_raw(c['input']));
        expect(result, _raw(c['result']));
      });
    }
  });
}
