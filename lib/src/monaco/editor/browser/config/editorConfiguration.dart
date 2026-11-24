// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/browser/config/editorConfiguration.ts
// (all 358 lines). Members appear in source order: the construction-options
// interface, EditorConfiguration (40-221), digitCount/getExtraEditorClassName
// (223-246), IEnvConfiguration (248-256), ValidatedEditorOptions (258-269),
// ComputedEditorOptions (271-285), EditorOptionsUtil (287-352) and
// deepCloneAndMigrateOptions (354-358).
//
// Adaptations (documented inline):
//  * TS `IEditorConstructionOptions extends IEditorOptions` -> a Dart subclass
//    adding `dimension` / `overflowWidgetsDomNode` carriers.
//  * TS `IEditorOptions` is a structural object indexed by `option.name`;
//    Dart's `IEditorOptions` is a nominal class. [EditorOptionsByName] bridges
//    the two by generating one `read`/`write` case per real option field.
//  * Raw options inside `EditorOptionsUtil` are carried as
//    `Map<String, Object?>` because `objects.deepClone` and `migrateOptions`
//    are map-based in this port; `EditorConfiguration` converts at the API
//    boundary. `hasOwnProperty` maps to `Map.containsKey`.
//  * JS sparse arrays (`_values[option] = value`) -> growable nullable Dart
//    lists grown with `null` slots.
//  * `FindComputedEditorOptionValueById<T>` is a type-level helper -> erased;
//    `get(Object id)` returns `Object?` (same convention as editorOptions.dart).
//  * `ComputedEditorOptions._read` throws `StateError` where TS throws `Error`.
//  * `_deepEquals` projects Dart's nominal option carriers to the same
//    JSON-safe field maps TS objects expose before the structural walk, so
//    two structurally equal carriers compare equal (Dart `==` is identity).
//  * `applyUpdate` repeats TS's erased-`T` merge with `Object?`: reusing
//    `BaseEditorOption.applyUpdate` would cast a raw structural `Map` to a
//    concrete carrier type and throw.
//  * `HTMLElement` -> `DomElement`; `getWindowById(id, true).window` ->
//    `getWindowById(id, true)!.window` (CodeWindow) and, where the TS passes a
//    `Window` to `FontMeasurements`, Dart's `windowCarrier(...)`.
//  * `@IAccessibilityService` -> `IAccessibilityServiceType` (the const in
//    accessibility.dart is the ServiceIdentifier/decorator itself).
//  * `getExtraEditorClassName` takes optional `isSafari`/`isWebkitWebView`/
//    `isMacintosh` overrides that default to the real browser/platform
//    globals — a pure test seam; runtime behaviour with no arguments is 1:1.
//  * `typeof globalThis.EditContext === 'function'` -> an injectable
//    `editContextSupportedProvider` slot (no `globalThis` in Dart).
//  * TS module-load migration registration -> lazily forced by
//    [deepCloneAndMigrateOptions] (Dart top-level initializers are lazy).
// ---------------------------------------------------------------------------

import '../../../base/browser/browser.dart' as browser;
import '../../../base/browser/dom.dart'
    show DomElement, getWindow, getWindowById, windowCarrier;
import '../../../base/browser/window.dart' show CodeWindow;
import '../../../base/browser/pixelRatio.dart' show PixelRatio;
import '../../../base/common/arrays.dart' as arrays;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable;
import '../../../base/common/objects.dart' as objects;
import '../../../base/common/platform.dart' as platform;
import '../../../platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport, IAccessibilityServiceType;
import '../../../platform/actions/common/actions.dart' show MenuId;
import '../../common/config/editorConfiguration.dart' show IEditorConfiguration;
import '../../common/config/editorOptions.dart' as opts;
import '../../common/config/editorOptions.dart'
    show
        ComputeOptionsMemory,
        ApplyUpdateResult,
        ConfigurationChangedEvent,
        EditorOption,
        IComputedEditorOptions,
        IEditorOption,
        IEditorOptions,
        IEnvironmentalOptions,
        editorOptionsRegistry;
import '../../common/config/editorZoom.dart' show EditorZoom;
import '../../common/config/fontInfo.dart'
    show BareFontInfo, FontInfo, IValidatedEditorOptions;
import '../../common/config/fontInfoFromSettings.dart'
    show createBareFontInfoFromValidatedSettings;
import '../../common/core/2d/dimension.dart' show IDimension;
import '../../common/inputMode.dart' show InputMode;
import './elementSizeObserver.dart' show ElementSizeObserver;
import './fontMeasurements.dart' show FontMeasurements;
import './migrateOptions.dart'
    show EditorSettingMigration, editorSettingMigrations, migrateOptions;
import './tabFocus.dart' show TabFocus;

/// 1:1: `typeof (globalThis as any).EditContext === 'function'`.
/// A Dart-side seam for the browser global; defaults to `false`.
bool Function() editContextSupportedProvider = () => false;

/// 1:1: `export interface IEditorConstructionOptions extends IEditorOptions`.
class IEditorConstructionOptions extends IEditorOptions {
  IEditorConstructionOptions({this.dimension, this.overflowWidgetsDomNode});

  /// The initial editor dimension (to avoid measuring the container).
  IDimension? dimension;

  /// Place overflow widgets inside an external DOM node.
  /// Defaults to an internal DOM node.
  DomElement? overflowWidgetsDomNode;
}

/// 1:1: the structural read `(options as Record<string, unknown>)[name]`
/// and write `options[name] = value` used by the port's `IEditorOptions` <-> map
/// bridge. One case per real `IEditorOptions` field, generated from the port of
/// `editorOptions.ts` (173 fields + the 7 `_never_` computed slots -> null).
extension EditorOptionsByName on IEditorOptions {
  Object? read(String name) {
    switch (name) {
      case 'inDiffEditor':
        return inDiffEditor;
      case 'allowVariableLineHeights':
        return allowVariableLineHeights;
      case 'allowVariableFonts':
        return allowVariableFonts;
      case 'allowVariableFontsInAccessibilityMode':
        return allowVariableFontsInAccessibilityMode;
      case 'ariaLabel':
        return ariaLabel;
      case 'ariaRequired':
        return ariaRequired;
      case 'screenReaderAnnounceInlineSuggestion':
        return screenReaderAnnounceInlineSuggestion;
      case 'tabIndex':
        return tabIndex;
      case 'rulers':
        return rulers;
      case 'wordSegmenterLocales':
        return wordSegmenterLocales;
      case 'wordSeparators':
        return wordSeparators;
      case 'selectionClipboard':
        return selectionClipboard;
      case 'lineNumbers':
        return lineNumbers;
      case 'cursorSurroundingLines':
        return cursorSurroundingLines;
      case 'cursorSurroundingLinesStyle':
        return cursorSurroundingLinesStyle;
      case 'renderFinalNewline':
        return renderFinalNewline;
      case 'unusualLineTerminators':
        return unusualLineTerminators;
      case 'selectOnLineNumbers':
        return selectOnLineNumbers;
      case 'lineNumbersMinChars':
        return lineNumbersMinChars;
      case 'glyphMargin':
        return glyphMargin;
      case 'lineDecorationsWidth':
        return lineDecorationsWidth;
      case 'revealHorizontalRightPadding':
        return revealHorizontalRightPadding;
      case 'roundedSelection':
        return roundedSelection;
      case 'extraEditorClassName':
        return extraEditorClassName;
      case 'readOnly':
        return readOnly;
      case 'readOnlyMessage':
        return readOnlyMessage;
      case 'domReadOnly':
        return domReadOnly;
      case 'linkedEditing':
        return linkedEditing;
      case 'renameOnType':
        return renameOnType;
      case 'renderValidationDecorations':
        return renderValidationDecorations;
      case 'scrollbar':
        return scrollbar;
      case 'stickyScroll':
        return stickyScroll;
      case 'minimap':
        return minimap;
      case 'find':
        return find;
      case 'fixedOverflowWidgets':
        return fixedOverflowWidgets;
      case 'allowOverflow':
        return allowOverflow;
      case 'overviewRulerLanes':
        return overviewRulerLanes;
      case 'overviewRulerBorder':
        return overviewRulerBorder;
      case 'cursorBlinking':
        return cursorBlinking;
      case 'mouseWheelZoom':
        return mouseWheelZoom;
      case 'mouseStyle':
        return mouseStyle;
      case 'cursorSmoothCaretAnimation':
        return cursorSmoothCaretAnimation;
      case 'cursorStyle':
        return cursorStyle;
      case 'overtypeCursorStyle':
        return overtypeCursorStyle;
      case 'overtypeOnPaste':
        return overtypeOnPaste;
      case 'cursorWidth':
        return cursorWidth;
      case 'cursorHeight':
        return cursorHeight;
      case 'fontLigatures':
        return fontLigatures;
      case 'fontVariations':
        return fontVariations;
      case 'defaultColorDecorators':
        return defaultColorDecorators;
      case 'disableLayerHinting':
        return disableLayerHinting;
      case 'disableMonospaceOptimizations':
        return disableMonospaceOptimizations;
      case 'hideCursorInOverviewRuler':
        return hideCursorInOverviewRuler;
      case 'scrollBeyondLastLine':
        return scrollBeyondLastLine;
      case 'scrollOnMiddleClick':
        return scrollOnMiddleClick;
      case 'scrollBeyondLastColumn':
        return scrollBeyondLastColumn;
      case 'smoothScrolling':
        return smoothScrolling;
      case 'automaticLayout':
        return automaticLayout;
      case 'wordWrap':
        return wordWrap;
      case 'wordWrapIndicator':
        return wordWrapIndicator;
      case 'wordWrapOverride1':
        return wordWrapOverride1;
      case 'wordWrapOverride2':
        return wordWrapOverride2;
      case 'wordWrapColumn':
        return wordWrapColumn;
      case 'wrappingIndent':
        return wrappingIndent;
      case 'wrappingStrategy':
        return wrappingStrategy;
      case 'wrapOnEscapedLineFeeds':
        return wrapOnEscapedLineFeeds;
      case 'wordWrapBreakBeforeCharacters':
        return wordWrapBreakBeforeCharacters;
      case 'wordWrapBreakAfterCharacters':
        return wordWrapBreakAfterCharacters;
      case 'wordBreak':
        return wordBreak;
      case 'stopRenderingLineAfter':
        return stopRenderingLineAfter;
      case 'hover':
        return hover;
      case 'markdownImages':
        return markdownImages;
      case 'links':
        return links;
      case 'colorDecorators':
        return colorDecorators;
      case 'colorDecoratorsActivatedOn':
        return colorDecoratorsActivatedOn;
      case 'colorDecoratorsLimit':
        return colorDecoratorsLimit;
      case 'comments':
        return comments;
      case 'contextmenu':
        return contextmenu;
      case 'mouseWheelScrollSensitivity':
        return mouseWheelScrollSensitivity;
      case 'fastScrollSensitivity':
        return fastScrollSensitivity;
      case 'scrollPredominantAxis':
        return scrollPredominantAxis;
      case 'inertialScroll':
        return inertialScroll;
      case 'columnSelection':
        return columnSelection;
      case 'multiCursorModifier':
        return multiCursorModifier;
      case 'multiCursorMergeOverlapping':
        return multiCursorMergeOverlapping;
      case 'multiCursorPaste':
        return multiCursorPaste;
      case 'multiCursorLimit':
        return multiCursorLimit;
      case 'mouseMiddleClickAction':
        return mouseMiddleClickAction;
      case 'accessibilitySupport':
        return accessibilitySupport;
      case 'accessibilityPageSize':
        return accessibilityPageSize;
      case 'suggest':
        return suggest;
      case 'inlineSuggest':
        return inlineSuggest;
      case 'smartSelect':
        return smartSelect;
      case 'gotoLocation':
        return gotoLocation;
      case 'quickSuggestions':
        return quickSuggestions;
      case 'quickSuggestionsDelay':
        return quickSuggestionsDelay;
      case 'padding':
        return padding;
      case 'parameterHints':
        return parameterHints;
      case 'autoClosingBrackets':
        return autoClosingBrackets;
      case 'autoClosingComments':
        return autoClosingComments;
      case 'autoClosingQuotes':
        return autoClosingQuotes;
      case 'autoClosingDelete':
        return autoClosingDelete;
      case 'autoClosingOvertype':
        return autoClosingOvertype;
      case 'autoSurround':
        return autoSurround;
      case 'autoIndent':
        return autoIndent;
      case 'autoIndentOnPaste':
        return autoIndentOnPaste;
      case 'autoIndentOnPasteWithinString':
        return autoIndentOnPasteWithinString;
      case 'stickyTabStops':
        return stickyTabStops;
      case 'formatOnType':
        return formatOnType;
      case 'formatOnPaste':
        return formatOnPaste;
      case 'fullwidthCharacterWidth':
        return fullwidthCharacterWidth;
      case 'doubleClickSelectsBlock':
        return doubleClickSelectsBlock;
      case 'dragAndDrop':
        return dragAndDrop;
      case 'suggestOnTriggerCharacters':
        return suggestOnTriggerCharacters;
      case 'acceptSuggestionOnEnter':
        return acceptSuggestionOnEnter;
      case 'acceptSuggestionOnCommitCharacter':
        return acceptSuggestionOnCommitCharacter;
      case 'snippetSuggestions':
        return snippetSuggestions;
      case 'emptySelectionClipboard':
        return emptySelectionClipboard;
      case 'copyWithSyntaxHighlighting':
        return copyWithSyntaxHighlighting;
      case 'suggestSelection':
        return suggestSelection;
      case 'suggestFontSize':
        return suggestFontSize;
      case 'suggestLineHeight':
        return suggestLineHeight;
      case 'tabCompletion':
        return tabCompletion;
      case 'selectionHighlight':
        return selectionHighlight;
      case 'selectionHighlightMultiline':
        return selectionHighlightMultiline;
      case 'selectionHighlightMaxLength':
        return selectionHighlightMaxLength;
      case 'selectedTextMatchMode':
        return selectedTextMatchMode;
      case 'occurrencesHighlight':
        return occurrencesHighlight;
      case 'occurrencesHighlightDelay':
        return occurrencesHighlightDelay;
      case 'occurrencesHighlightFromAllProviders':
        return occurrencesHighlightFromAllProviders;
      case 'codeLens':
        return codeLens;
      case 'codeLensFontFamily':
        return codeLensFontFamily;
      case 'codeLensFontSize':
        return codeLensFontSize;
      case 'lightbulb':
        return lightbulb;
      case 'codeActionsOnSaveTimeout':
        return codeActionsOnSaveTimeout;
      case 'folding':
        return folding;
      case 'foldingStrategy':
        return foldingStrategy;
      case 'foldingHighlight':
        return foldingHighlight;
      case 'foldingImportsByDefault':
        return foldingImportsByDefault;
      case 'foldingMaximumRegions':
        return foldingMaximumRegions;
      case 'showFoldingControls':
        return showFoldingControls;
      case 'unfoldOnClickAfterEndOfLine':
        return unfoldOnClickAfterEndOfLine;
      case 'matchBrackets':
        return matchBrackets;
      case 'experimentalGpuAcceleration':
        return experimentalGpuAcceleration;
      case 'experimentalWhitespaceRendering':
        return experimentalWhitespaceRendering;
      case 'renderWhitespace':
        return renderWhitespace;
      case 'renderControlCharacters':
        return renderControlCharacters;
      case 'renderLineHighlight':
        return renderLineHighlight;
      case 'renderLineHighlightOnlyWhenFocus':
        return renderLineHighlightOnlyWhenFocus;
      case 'useTabStops':
        return useTabStops;
      case 'trimWhitespaceOnDelete':
        return trimWhitespaceOnDelete;
      case 'fontFamily':
        return fontFamily;
      case 'fontWeight':
        return fontWeight;
      case 'fontSize':
        return fontSize;
      case 'lineHeight':
        return lineHeight;
      case 'letterSpacing':
        return letterSpacing;
      case 'showUnused':
        return showUnused;
      case 'peekWidgetDefaultFocus':
        return peekWidgetDefaultFocus;
      case 'placeholder':
        return placeholder;
      case 'definitionLinkOpensInPeek':
        return definitionLinkOpensInPeek;
      case 'showDeprecated':
        return showDeprecated;
      case 'matchOnWordStartOnly':
        return matchOnWordStartOnly;
      case 'inlayHints':
        return inlayHints;
      case 'useShadowDOM':
        return useShadowDOM;
      case 'guides':
        return guides;
      case 'unicodeHighlight':
        return unicodeHighlight;
      case 'bracketPairColorization':
        return bracketPairColorization;
      case 'dropIntoEditor':
        return dropIntoEditor;
      case 'editContext':
        return editContext;
      case 'renderRichScreenReaderContent':
        return renderRichScreenReaderContent;
      case 'pasteAs':
        return pasteAs;
      case 'tabFocusMode':
        return tabFocusMode;
      case 'inlineCompletionsAccessibilityVerbose':
        return inlineCompletionsAccessibilityVerbose;
      default:
        return null; // `_never_` computed slots and unknown names.
    }
  }

  void write(String name, Object? value) {
    switch (name) {
      case 'inDiffEditor':
        inDiffEditor = value as bool?;
        break;
      case 'allowVariableLineHeights':
        allowVariableLineHeights = value as bool?;
        break;
      case 'allowVariableFonts':
        allowVariableFonts = value as bool?;
        break;
      case 'allowVariableFontsInAccessibilityMode':
        allowVariableFontsInAccessibilityMode = value as bool?;
        break;
      case 'ariaLabel':
        ariaLabel = value as String?;
        break;
      case 'ariaRequired':
        ariaRequired = value as bool?;
        break;
      case 'screenReaderAnnounceInlineSuggestion':
        screenReaderAnnounceInlineSuggestion = value as bool?;
        break;
      case 'tabIndex':
        tabIndex = value as num?;
        break;
      case 'rulers':
        rulers = value;
        break;
      case 'wordSegmenterLocales':
        wordSegmenterLocales = value;
        break;
      case 'wordSeparators':
        wordSeparators = value as String?;
        break;
      case 'selectionClipboard':
        selectionClipboard = value as bool?;
        break;
      case 'lineNumbers':
        lineNumbers = value;
        break;
      case 'cursorSurroundingLines':
        cursorSurroundingLines = value as num?;
        break;
      case 'cursorSurroundingLinesStyle':
        cursorSurroundingLinesStyle = value as String?;
        break;
      case 'renderFinalNewline':
        renderFinalNewline = value as String?;
        break;
      case 'unusualLineTerminators':
        unusualLineTerminators = value as String?;
        break;
      case 'selectOnLineNumbers':
        selectOnLineNumbers = value as bool?;
        break;
      case 'lineNumbersMinChars':
        lineNumbersMinChars = value as num?;
        break;
      case 'glyphMargin':
        glyphMargin = value as bool?;
        break;
      case 'lineDecorationsWidth':
        lineDecorationsWidth = value;
        break;
      case 'revealHorizontalRightPadding':
        revealHorizontalRightPadding = value as num?;
        break;
      case 'roundedSelection':
        roundedSelection = value as bool?;
        break;
      case 'extraEditorClassName':
        extraEditorClassName = value as String?;
        break;
      case 'readOnly':
        readOnly = value as bool?;
        break;
      case 'readOnlyMessage':
        readOnlyMessage = value;
        break;
      case 'domReadOnly':
        domReadOnly = value as bool?;
        break;
      case 'linkedEditing':
        linkedEditing = value as bool?;
        break;
      case 'renameOnType':
        renameOnType = value as bool?;
        break;
      case 'renderValidationDecorations':
        renderValidationDecorations = value as String?;
        break;
      case 'scrollbar':
        scrollbar = value;
        break;
      case 'stickyScroll':
        stickyScroll = value;
        break;
      case 'minimap':
        minimap = value;
        break;
      case 'find':
        find = value;
        break;
      case 'fixedOverflowWidgets':
        fixedOverflowWidgets = value as bool?;
        break;
      case 'allowOverflow':
        allowOverflow = value as bool?;
        break;
      case 'overviewRulerLanes':
        overviewRulerLanes = value as num?;
        break;
      case 'overviewRulerBorder':
        overviewRulerBorder = value as bool?;
        break;
      case 'cursorBlinking':
        cursorBlinking = value as String?;
        break;
      case 'mouseWheelZoom':
        mouseWheelZoom = value as bool?;
        break;
      case 'mouseStyle':
        mouseStyle = value as String?;
        break;
      case 'cursorSmoothCaretAnimation':
        cursorSmoothCaretAnimation = value as String?;
        break;
      case 'cursorStyle':
        cursorStyle = value as String?;
        break;
      case 'overtypeCursorStyle':
        overtypeCursorStyle = value as String?;
        break;
      case 'overtypeOnPaste':
        overtypeOnPaste = value as bool?;
        break;
      case 'cursorWidth':
        cursorWidth = value as num?;
        break;
      case 'cursorHeight':
        cursorHeight = value as num?;
        break;
      case 'fontLigatures':
        fontLigatures = value;
        break;
      case 'fontVariations':
        fontVariations = value;
        break;
      case 'defaultColorDecorators':
        defaultColorDecorators = value as String?;
        break;
      case 'disableLayerHinting':
        disableLayerHinting = value as bool?;
        break;
      case 'disableMonospaceOptimizations':
        disableMonospaceOptimizations = value as bool?;
        break;
      case 'hideCursorInOverviewRuler':
        hideCursorInOverviewRuler = value as bool?;
        break;
      case 'scrollBeyondLastLine':
        scrollBeyondLastLine = value as bool?;
        break;
      case 'scrollOnMiddleClick':
        scrollOnMiddleClick = value as bool?;
        break;
      case 'scrollBeyondLastColumn':
        scrollBeyondLastColumn = value as num?;
        break;
      case 'smoothScrolling':
        smoothScrolling = value as bool?;
        break;
      case 'automaticLayout':
        automaticLayout = value as bool?;
        break;
      case 'wordWrap':
        wordWrap = value as String?;
        break;
      case 'wordWrapIndicator':
        wordWrapIndicator = value as bool?;
        break;
      case 'wordWrapOverride1':
        wordWrapOverride1 = value as String?;
        break;
      case 'wordWrapOverride2':
        wordWrapOverride2 = value as String?;
        break;
      case 'wordWrapColumn':
        wordWrapColumn = value as num?;
        break;
      case 'wrappingIndent':
        wrappingIndent = value as String?;
        break;
      case 'wrappingStrategy':
        wrappingStrategy = value as String?;
        break;
      case 'wrapOnEscapedLineFeeds':
        wrapOnEscapedLineFeeds = value as bool?;
        break;
      case 'wordWrapBreakBeforeCharacters':
        wordWrapBreakBeforeCharacters = value as String?;
        break;
      case 'wordWrapBreakAfterCharacters':
        wordWrapBreakAfterCharacters = value as String?;
        break;
      case 'wordBreak':
        wordBreak = value as String?;
        break;
      case 'stopRenderingLineAfter':
        stopRenderingLineAfter = value as num?;
        break;
      case 'hover':
        hover = value;
        break;
      case 'markdownImages':
        markdownImages = value;
        break;
      case 'links':
        links = value as bool?;
        break;
      case 'colorDecorators':
        colorDecorators = value as bool?;
        break;
      case 'colorDecoratorsActivatedOn':
        colorDecoratorsActivatedOn = value as String?;
        break;
      case 'colorDecoratorsLimit':
        colorDecoratorsLimit = value as num?;
        break;
      case 'comments':
        comments = value;
        break;
      case 'contextmenu':
        contextmenu = value as bool?;
        break;
      case 'mouseWheelScrollSensitivity':
        mouseWheelScrollSensitivity = value as num?;
        break;
      case 'fastScrollSensitivity':
        fastScrollSensitivity = value as num?;
        break;
      case 'scrollPredominantAxis':
        scrollPredominantAxis = value as bool?;
        break;
      case 'inertialScroll':
        inertialScroll = value as bool?;
        break;
      case 'columnSelection':
        columnSelection = value as bool?;
        break;
      case 'multiCursorModifier':
        multiCursorModifier = value as String?;
        break;
      case 'multiCursorMergeOverlapping':
        multiCursorMergeOverlapping = value as bool?;
        break;
      case 'multiCursorPaste':
        multiCursorPaste = value as String?;
        break;
      case 'multiCursorLimit':
        multiCursorLimit = value as num?;
        break;
      case 'mouseMiddleClickAction':
        mouseMiddleClickAction = value;
        break;
      case 'accessibilitySupport':
        accessibilitySupport = value as String?;
        break;
      case 'accessibilityPageSize':
        accessibilityPageSize = value as num?;
        break;
      case 'suggest':
        suggest = value;
        break;
      case 'inlineSuggest':
        inlineSuggest = value;
        break;
      case 'smartSelect':
        smartSelect = value;
        break;
      case 'gotoLocation':
        gotoLocation = value;
        break;
      case 'quickSuggestions':
        quickSuggestions = value;
        break;
      case 'quickSuggestionsDelay':
        quickSuggestionsDelay = value as num?;
        break;
      case 'padding':
        padding = value;
        break;
      case 'parameterHints':
        parameterHints = value;
        break;
      case 'autoClosingBrackets':
        autoClosingBrackets = value;
        break;
      case 'autoClosingComments':
        autoClosingComments = value;
        break;
      case 'autoClosingQuotes':
        autoClosingQuotes = value;
        break;
      case 'autoClosingDelete':
        autoClosingDelete = value;
        break;
      case 'autoClosingOvertype':
        autoClosingOvertype = value;
        break;
      case 'autoSurround':
        autoSurround = value;
        break;
      case 'autoIndent':
        autoIndent = value as String?;
        break;
      case 'autoIndentOnPaste':
        autoIndentOnPaste = value as bool?;
        break;
      case 'autoIndentOnPasteWithinString':
        autoIndentOnPasteWithinString = value as bool?;
        break;
      case 'stickyTabStops':
        stickyTabStops = value as bool?;
        break;
      case 'formatOnType':
        formatOnType = value as bool?;
        break;
      case 'formatOnPaste':
        formatOnPaste = value as bool?;
        break;
      case 'fullwidthCharacterWidth':
        fullwidthCharacterWidth = value as String?;
        break;
      case 'doubleClickSelectsBlock':
        doubleClickSelectsBlock = value as bool?;
        break;
      case 'dragAndDrop':
        dragAndDrop = value as bool?;
        break;
      case 'suggestOnTriggerCharacters':
        suggestOnTriggerCharacters = value as bool?;
        break;
      case 'acceptSuggestionOnEnter':
        acceptSuggestionOnEnter = value as String?;
        break;
      case 'acceptSuggestionOnCommitCharacter':
        acceptSuggestionOnCommitCharacter = value as bool?;
        break;
      case 'snippetSuggestions':
        snippetSuggestions = value as String?;
        break;
      case 'emptySelectionClipboard':
        emptySelectionClipboard = value as bool?;
        break;
      case 'copyWithSyntaxHighlighting':
        copyWithSyntaxHighlighting = value as bool?;
        break;
      case 'suggestSelection':
        suggestSelection = value as String?;
        break;
      case 'suggestFontSize':
        suggestFontSize = value as num?;
        break;
      case 'suggestLineHeight':
        suggestLineHeight = value as num?;
        break;
      case 'tabCompletion':
        tabCompletion = value as String?;
        break;
      case 'selectionHighlight':
        selectionHighlight = value as bool?;
        break;
      case 'selectionHighlightMultiline':
        selectionHighlightMultiline = value as bool?;
        break;
      case 'selectionHighlightMaxLength':
        selectionHighlightMaxLength = value as num?;
        break;
      case 'selectedTextMatchMode':
        selectedTextMatchMode = value as String?;
        break;
      case 'occurrencesHighlight':
        occurrencesHighlight = value as String?;
        break;
      case 'occurrencesHighlightDelay':
        occurrencesHighlightDelay = value as num?;
        break;
      case 'occurrencesHighlightFromAllProviders':
        occurrencesHighlightFromAllProviders = value as bool?;
        break;
      case 'codeLens':
        codeLens = value as bool?;
        break;
      case 'codeLensFontFamily':
        codeLensFontFamily = value as String?;
        break;
      case 'codeLensFontSize':
        codeLensFontSize = value as num?;
        break;
      case 'lightbulb':
        lightbulb = value;
        break;
      case 'codeActionsOnSaveTimeout':
        codeActionsOnSaveTimeout = value as num?;
        break;
      case 'folding':
        folding = value as bool?;
        break;
      case 'foldingStrategy':
        foldingStrategy = value as String?;
        break;
      case 'foldingHighlight':
        foldingHighlight = value as bool?;
        break;
      case 'foldingImportsByDefault':
        foldingImportsByDefault = value as bool?;
        break;
      case 'foldingMaximumRegions':
        foldingMaximumRegions = value as num?;
        break;
      case 'showFoldingControls':
        showFoldingControls = value as String?;
        break;
      case 'unfoldOnClickAfterEndOfLine':
        unfoldOnClickAfterEndOfLine = value as bool?;
        break;
      case 'matchBrackets':
        matchBrackets = value as String?;
        break;
      case 'experimentalGpuAcceleration':
        experimentalGpuAcceleration = value as String?;
        break;
      case 'experimentalWhitespaceRendering':
        experimentalWhitespaceRendering = value as String?;
        break;
      case 'renderWhitespace':
        renderWhitespace = value as String?;
        break;
      case 'renderControlCharacters':
        renderControlCharacters = value as bool?;
        break;
      case 'renderLineHighlight':
        renderLineHighlight = value as String?;
        break;
      case 'renderLineHighlightOnlyWhenFocus':
        renderLineHighlightOnlyWhenFocus = value as bool?;
        break;
      case 'useTabStops':
        useTabStops = value as bool?;
        break;
      case 'trimWhitespaceOnDelete':
        trimWhitespaceOnDelete = value as bool?;
        break;
      case 'fontFamily':
        fontFamily = value as String?;
        break;
      case 'fontWeight':
        fontWeight = value as String?;
        break;
      case 'fontSize':
        fontSize = value as num?;
        break;
      case 'lineHeight':
        lineHeight = value as num?;
        break;
      case 'letterSpacing':
        letterSpacing = value as num?;
        break;
      case 'showUnused':
        showUnused = value as bool?;
        break;
      case 'peekWidgetDefaultFocus':
        peekWidgetDefaultFocus = value as String?;
        break;
      case 'placeholder':
        placeholder = value;
        break;
      case 'definitionLinkOpensInPeek':
        definitionLinkOpensInPeek = value as bool?;
        break;
      case 'showDeprecated':
        showDeprecated = value as bool?;
        break;
      case 'matchOnWordStartOnly':
        matchOnWordStartOnly = value as bool?;
        break;
      case 'inlayHints':
        inlayHints = value;
        break;
      case 'useShadowDOM':
        useShadowDOM = value as bool?;
        break;
      case 'guides':
        guides = value;
        break;
      case 'unicodeHighlight':
        unicodeHighlight = value;
        break;
      case 'bracketPairColorization':
        bracketPairColorization = value;
        break;
      case 'dropIntoEditor':
        dropIntoEditor = value;
        break;
      case 'editContext':
        editContext = value as bool?;
        break;
      case 'renderRichScreenReaderContent':
        renderRichScreenReaderContent = value as bool?;
        break;
      case 'pasteAs':
        pasteAs = value;
        break;
      case 'tabFocusMode':
        tabFocusMode = value as bool?;
        break;
      case 'inlineCompletionsAccessibilityVerbose':
        inlineCompletionsAccessibilityVerbose = value as bool?;
        break;
    }
  }
}

/// 1:1: `class EditorConfiguration extends Disposable implements IEditorConfiguration`.
class EditorConfiguration extends Disposable implements IEditorConfiguration {
  late final Emitter<ConfigurationChangedEvent> _onDidChange;

  @override
  late final Event<ConfigurationChangedEvent> onDidChange;

  late final Emitter<ConfigurationChangedEvent> _onDidChangeFast;

  @override
  late final Event<ConfigurationChangedEvent> onDidChangeFast;

  @override
  final bool isSimpleWidget;

  @override
  final MenuId contextMenuId;

  late final ElementSizeObserver _containerObserver;

  bool _isDominatedByLongLines = false;
  int _viewLineCount = 1;
  int _lineNumbersDigitCount = 1;
  num _reservedHeight = 0;
  int _glyphMarginDecorationLaneCount = 1;
  late final int _targetWindowId;

  final ComputeOptionsMemory _computeOptionsMemory = ComputeOptionsMemory();

  /// Raw options as they were passed in and merged with all `updateOptions`.
  /// 1:1: `private readonly _rawOptions: IEditorOptions` carried as a map (see
  /// the header note).
  late final Map<String, Object?> _rawOptions;

  /// Validated version of [_rawOptions].
  late ValidatedEditorOptions _validatedOptions;

  /// Complete options (passed-in options plus env values).
  @override
  late ComputedEditorOptions options;

  /// 1:1: `@IAccessibilityService private readonly _accessibilityService`.
  final IAccessibilityServiceType _accessibilityService;

  EditorConfiguration(
    this.isSimpleWidget,
    this.contextMenuId,
    IEditorConstructionOptions options,
    DomElement? container,
    this._accessibilityService,
  ) {
    _onDidChange = register(Emitter<ConfigurationChangedEvent>());
    onDidChange = _onDidChange.event;
    _onDidChangeFast = register(Emitter<ConfigurationChangedEvent>());
    onDidChangeFast = _onDidChangeFast.event;

    _containerObserver =
        register(ElementSizeObserver(container, options.dimension));
    _targetWindowId = getWindow(container).vscodeWindowId;

    _rawOptions = deepCloneAndMigrateOptions(_optionsToMap(options));
    _validatedOptions = EditorOptionsUtil.validateOptions(_rawOptions);
    this.options = _computeOptions();

    if (this.options.get(EditorOption.automaticLayout) as bool) {
      _containerObserver.startObserving();
    }

    register(EditorZoom.onDidChangeZoomLevel((_) => _recomputeOptions()));
    register(TabFocus.onDidChangeTabFocus((_) => _recomputeOptions()));
    register(_containerObserver.onDidChange((_) => _recomputeOptions()));
    register(FontMeasurements.onDidChange((_) => _recomputeOptions()));
    register(PixelRatio.getInstance(getWindowById(_targetWindowId, true)!.window)
        .onDidChange((_) => _recomputeOptions()));
    register(_accessibilityService.onDidChangeScreenReaderOptimized(
        (_) => _recomputeOptions()));
    register(InputMode.onDidChangeInputMode((_) => _recomputeOptions()));
  }

  /// 1:1: `private _recomputeOptions(): void`.
  void _recomputeOptions() {
    final ComputedEditorOptions newOptions = _computeOptions();
    final ConfigurationChangedEvent? changeEvent =
        EditorOptionsUtil.checkEquals(options, newOptions);
    if (changeEvent == null) {
      // nothing changed!
      return;
    }
    options = newOptions;
    _onDidChangeFast.fire(changeEvent);
    _onDidChange.fire(changeEvent);
  }

  /// 1:1: `private _computeOptions(): ComputedEditorOptions`.
  ComputedEditorOptions _computeOptions() {
    final IEnvConfiguration partialEnv = _readEnvConfiguration();
    final BareFontInfo bareFontInfo = createBareFontInfoFromValidatedSettings(
      _validatedOptions,
      partialEnv.pixelRatio.toDouble(),
      isSimpleWidget,
    );
    final FontInfo fontInfo = _readFontInfo(bareFontInfo);
    final IEnvironmentalOptions env = _EnvironmentalOptionsImpl(
      memory: _computeOptionsMemory,
      outerWidth: partialEnv.outerWidth.toDouble(),
      outerHeight: (partialEnv.outerHeight - _reservedHeight).toDouble(),
      fontInfo: fontInfo,
      extraEditorClassName: partialEnv.extraEditorClassName,
      isDominatedByLongLines: _isDominatedByLongLines,
      viewLineCount: _viewLineCount,
      lineNumbersDigitCount: _lineNumbersDigitCount,
      emptySelectionClipboard: partialEnv.emptySelectionClipboard,
      pixelRatio: partialEnv.pixelRatio.toDouble(),
      // 1:1: `... || TabFocus.getTabFocusMode()` (JS `||`, not `??`).
      tabFocusMode: (_validatedOptions.get(EditorOption.tabFocusMode) as bool) ||
          TabFocus.getTabFocusMode(),
      inputMode: InputMode.getInputMode().value,
      accessibilitySupport: partialEnv.accessibilitySupport,
      glyphMarginDecorationLaneCount: _glyphMarginDecorationLaneCount,
      editContextSupported: partialEnv.editContextSupported,
    );
    return EditorOptionsUtil.computeOptions(_validatedOptions, env);
  }

  /// 1:1: `protected _readEnvConfiguration(): IEnvConfiguration`.
  IEnvConfiguration _readEnvConfiguration() {
    return IEnvConfiguration(
      extraEditorClassName: getExtraEditorClassName(),
      outerWidth: _containerObserver.getWidth(),
      outerHeight: _containerObserver.getHeight(),
      emptySelectionClipboard: browser.isWebKit || browser.isFirefox,
      pixelRatio: PixelRatio.getInstance(getWindowById(_targetWindowId, true)!.window)
          .value,
      editContextSupported: editContextSupportedProvider(),
      accessibilitySupport: _accessibilityService.isScreenReaderOptimized()
          ? AccessibilitySupport.Enabled
          : _accessibilityService.getAccessibilitySupport(),
    );
  }

  /// 1:1: `protected _readFontInfo(bareFontInfo: BareFontInfo): FontInfo`.
  FontInfo _readFontInfo(BareFontInfo bareFontInfo) {
    final CodeWindow targetWindow = getWindowById(_targetWindowId, true)!.window;
    return FontMeasurements.readFontInfo(windowCarrier(targetWindow), bareFontInfo);
  }

  @override
  IEditorOptions getRawOptions() => _mapToOptions(_rawOptions);

  @override
  void updateOptions(IEditorOptions newOptions) {
    final Map<String, Object?> newRaw =
        deepCloneAndMigrateOptions(_optionsToMap(newOptions));
    final bool didChange = EditorOptionsUtil.applyUpdate(_rawOptions, newRaw);
    if (!didChange) {
      return;
    }
    _validatedOptions = EditorOptionsUtil.validateOptions(_rawOptions);
    _recomputeOptions();
  }

  @override
  void observeContainer([IDimension? dimension]) {
    _containerObserver.observe(dimension);
  }

  @override
  void setIsDominatedByLongLines(bool isDominatedByLongLines) {
    if (_isDominatedByLongLines == isDominatedByLongLines) {
      return;
    }
    _isDominatedByLongLines = isDominatedByLongLines;
    _recomputeOptions();
  }

  @override
  void setModelLineCount(int modelLineCount) {
    final int lineNumbersDigitCount = digitCount(modelLineCount);
    if (_lineNumbersDigitCount == lineNumbersDigitCount) {
      return;
    }
    _lineNumbersDigitCount = lineNumbersDigitCount;
    _recomputeOptions();
  }

  @override
  void setViewLineCount(int viewLineCount) {
    if (_viewLineCount == viewLineCount) {
      return;
    }
    _viewLineCount = viewLineCount;
    _recomputeOptions();
  }

  @override
  void setReservedHeight(num reservedHeight) {
    if (_reservedHeight == reservedHeight) {
      return;
    }
    _reservedHeight = reservedHeight;
    _recomputeOptions();
  }

  @override
  void setGlyphMarginDecorationLaneCount(int decorationLaneCount) {
    if (_glyphMarginDecorationLaneCount == decorationLaneCount) {
      return;
    }
    _glyphMarginDecorationLaneCount = decorationLaneCount;
    _recomputeOptions();
  }

  /// Convert the nominal Dart [IEditorOptions] into the structural map shape
  /// used by the port's raw-options utilities.
  static Map<String, Object?> _optionsToMap(IEditorOptions options) {
    final Map<String, Object?> result = <String, Object?>{};
    for (final IEditorOption<Object?>? option in editorOptionsRegistry) {
      if (option == null || option.name == '_never_') continue;
      result[option.name] = options.read(option.name);
    }
    return result;
  }

  /// Inverse of [_optionsToMap] for the public `getRawOptions()` API.
  static IEditorOptions _mapToOptions(Map<String, Object?> map) {
    final IEditorOptions result = IEditorOptions();
    map.forEach(result.write);
    return result;
  }
}

/// 1:1: `function digitCount(n: number): number`.
///
/// Negative inputs are intentionally NOT guarded: the real source loops
/// forever for them (`Math.floor(-0.5) === -1`), and so does this port.
int digitCount(num n) {
  int r = 0;
  while (n != 0) {
    n = (n / 10).floor();
    r++;
  }
  return r != 0 ? r : 1;
}

/// 1:1: `function getExtraEditorClassName(): string`.
String getExtraEditorClassName({
  bool? isSafari,
  bool? isWebkitWebView,
  bool? isMacintosh,
}) {
  String extra = '';
  if ((isSafari ?? browser.isSafari) ||
      (isWebkitWebView ?? browser.isWebkitWebView)) {
    // See https://github.com/microsoft/vscode/issues/108822
    extra += 'no-minimap-shadow ';
    extra += 'enable-user-select ';
  } else {
    // Use user-select: none in all browsers except Safari and native macOS WebView
    extra += 'no-user-select ';
  }
  if (isMacintosh ?? platform.isMacintosh) {
    extra += 'mac ';
  }
  return extra;
}

/// 1:1: `export interface IEnvConfiguration`.
class IEnvConfiguration {
  IEnvConfiguration({
    required this.extraEditorClassName,
    required this.outerWidth,
    required this.outerHeight,
    required this.emptySelectionClipboard,
    required this.pixelRatio,
    required this.accessibilitySupport,
    required this.editContextSupported,
  });

  final String extraEditorClassName;
  final num outerWidth;
  final num outerHeight;
  final bool emptySelectionClipboard;
  final num pixelRatio;
  final int accessibilitySupport;
  final bool editContextSupported;
}

/// 1:1: `class ValidatedEditorOptions implements IValidatedEditorOptions`.
class ValidatedEditorOptions implements IValidatedEditorOptions {
  final List<Object?> _values = <Object?>[];

  T _read<T>(int option) => _values[option] as T;

  @override
  Object? get(Object id) => _values[id as int];

  void _write<T>(int option, T value) {
    while (_values.length <= option) {
      _values.add(null); // JS sparse array hole.
    }
    _values[option] = value;
  }
}

/// 1:1: `export class ComputedEditorOptions implements IComputedEditorOptions`.
class ComputedEditorOptions implements IComputedEditorOptions {
  final List<Object?> _values = <Object?>[];

  T _read<T>(int id) {
    if (id >= _values.length) {
      // 1:1: `throw new Error('Cannot read uninitialized value')`.
      throw StateError('Cannot read uninitialized value');
    }
    return _values[id] as T;
  }

  @override
  Object? get(Object id) => _read(id as int);

  void _write<T>(int id, T value) {
    while (_values.length <= id) {
      _values.add(null); // JS sparse array hole.
    }
    _values[id] = value;
  }

  /// Public spelling of [_write] for 1:1 test ports in other libraries: the TS
  /// tests call `options._write(...)` directly, but Dart's leading underscore
  /// is library-private. Semantics are identical.
  void write(int id, Object? value) => _write(id, value);
}

/// 1:1: `class EditorOptionsUtil`.
class EditorOptionsUtil {
  /// 1:1: `static validateOptions(options: IEditorOptions): ValidatedEditorOptions`.
  static ValidatedEditorOptions validateOptions(Map<String, Object?> options) {
    final ValidatedEditorOptions result = ValidatedEditorOptions();
    for (final IEditorOption<Object?>? editorOption in editorOptionsRegistry) {
      if (editorOption == null) continue;
      final Object? value = editorOption.name == '_never_'
          ? null
          : options[editorOption.name];
      result._write(editorOption.id, editorOption.validate(value));
    }
    return result;
  }

  /// 1:1: `static computeOptions(options, env): ComputedEditorOptions`.
  static ComputedEditorOptions computeOptions(
    ValidatedEditorOptions options,
    IEnvironmentalOptions env,
  ) {
    final ComputedEditorOptions result = ComputedEditorOptions();
    for (final IEditorOption<Object?>? editorOption in editorOptionsRegistry) {
      if (editorOption == null) continue;
      result._write(
        editorOption.id,
        editorOption.compute(env, result, options._read(editorOption.id)),
      );
    }
    return result;
  }


  /// 1:1 adaptation of TS `_deepEquals`: TS walks every object's named
  /// properties, but Dart's option carriers are nominal classes. Convert each
  /// carrier to the same JSON-safe field map the TS object exposes (see the
  /// harness `normalize`); functions stay identity-comparable.
  static Object? _jsValue(Object? value) {
    if (value == null ||
        value is bool ||
        value is num ||
        value is String ||
        value is Function) {
      return value;
    }
    if (value is List) {
      return value.map<Object?>(_jsValue).toList();
    }
    if (value is Map) {
      return value.map<Object?, Object?>(
          (Object? k, Object? v) => MapEntry<Object?, Object?>(k, _jsValue(v)));
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
        'edits': _jsValue(value.edits),
        'triggerCommandOnProviderChange': value.triggerCommandOnProviderChange,
        'experimental': _jsValue(value.experimental),
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
      return <String, Object?>{'allowedOrigins': _jsValue(value.allowedOrigins)};
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
        'allowedCharacters': _jsValue(value.allowedCharacters),
        'allowedLocales': _jsValue(value.allowedLocales),
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
        'minimap': _jsValue(value.minimap),
        'viewportColumn': value.viewportColumn,
        'isWordWrapMinified': value.isWordWrapMinified,
        'isViewportWrapping': value.isViewportWrapping,
        'wrappingColumn': value.wrappingColumn,
        'verticalScrollbarWidth': value.verticalScrollbarWidth,
        'horizontalScrollbarHeight': value.horizontalScrollbarHeight,
        'overviewRuler': _jsValue(value.overviewRuler),
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
    return value; // unknown carrier: identity comparison
  }

  static bool _jsEquals(Object? a, Object? b) {
    if (a is List || b is List) {
      if (a is! List || b is! List || a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_jsEquals(a[i], b[i])) return false;
      }
      return true;
    }
    if (a is Map || b is Map) {
      if (a is! Map || b is! Map || a.length != b.length) return false;
      for (final Object? key in a.keys) {
        if (!b.containsKey(key) || !_jsEquals(a[key], b[key])) return false;
      }
      return true;
    }
    return a == b;
  }

  /// 1:1: `private static _deepEquals<T>(a: T, b: T): boolean`.
  /// TS walks every object's named properties; Dart option carriers are
  /// nominal classes, so [_jsValue] first projects them to the same JSON-safe
  /// shape the harness observes, then [_jsEquals] does the structural walk.
  static bool _deepEquals(Object? a, Object? b) =>
      _jsEquals(_jsValue(a), _jsValue(b));

  /// 1:1: `static checkEquals(a, b): ConfigurationChangedEvent | null`.
  static ConfigurationChangedEvent? checkEquals(
    ComputedEditorOptions a,
    ComputedEditorOptions b,
  ) {
    final List<bool> result = <bool>[];
    bool somethingChanged = false;
    for (final IEditorOption<Object?>? editorOption in editorOptionsRegistry) {
      if (editorOption == null) continue;
      final bool changed = !_deepEquals(
        a._read(editorOption.id),
        b._read(editorOption.id),
      );
      while (result.length <= editorOption.id) {
        result.add(false);
      }
      result[editorOption.id] = changed;
      if (changed) {
        somethingChanged = true;
      }
    }
    return somethingChanged ? ConfigurationChangedEvent(result) : null;
  }

  /// 1:1: `function applyUpdate<T>(value, update)` from `editorOptions.ts`.
  /// `BaseEditorOption.applyUpdate` cannot be reused here: its erased `T` is a
  /// concrete carrier type in Dart, so casting a raw structural `Map` to it
  /// throws. This is the same algorithm with `Object?` instead of erased `T`.
  static ApplyUpdateResult<Object?> _applyUpdateRaw(
    Object? value,
    Object? update,
  ) {
    final bool valueIsObject = (value is Map || value is List) && value != null;
    final bool updateIsObject =
        (update is Map || update is List) && update != null;
    if (!valueIsObject || !updateIsObject) {
      return ApplyUpdateResult<Object?>(update, value != update);
    }
    if (value is List || update is List) {
      final bool arrayEquals = value is List &&
          update is List &&
          arrays.equals<Object?>(value, update);
      return ApplyUpdateResult<Object?>(update, !arrayEquals);
    }
    bool didChange = false;
    final Map<Object?, Object?> valueMap = value as Map<Object?, Object?>;
    final Map<Object?, Object?> updateMap = update as Map<Object?, Object?>;
    for (final Object? key in updateMap.keys) {
      final ApplyUpdateResult<Object?> result =
          _applyUpdateRaw(valueMap[key], updateMap[key]);
      if (result.didChange) {
        valueMap[key] = result.newValue;
        didChange = true;
      }
    }
    return ApplyUpdateResult<Object?>(value, didChange);
  }

  /// 1:1: `static applyUpdate(options, update): boolean` — mutates [options].
  static bool applyUpdate(
    Map<String, Object?> options,
    Map<String, Object?> update,
  ) {
    bool changed = false;
    for (final IEditorOption<Object?>? editorOption in editorOptionsRegistry) {
      if (editorOption == null) continue;
      final String name = editorOption.name;
      // 1:1: `update.hasOwnProperty(editorOption.name)`.
      if (update.containsKey(name)) {
        final ApplyUpdateResult<Object?> result =
            _applyUpdateRaw(options[name], update[name]);
        options[name] = result.newValue;
        changed = changed || result.didChange;
      }
    }
    return changed;
  }
}

/// 1:1: `function deepCloneAndMigrateOptions(_options): IEditorOptions`.
Map<String, Object?> deepCloneAndMigrateOptions(
  Map<String, Object?> options,
) {
  final Object? cloned = objects.deepClone(options);
  final Map<String, Object?> result = (cloned as Map).cast<String, Object?>();
  // TS registers migrations at module load; Dart's top-level final is lazy,
  // so touch it here to replay that side effect exactly once.
  final List<EditorSettingMigration> registered = editorSettingMigrations;
  migrateOptions(result);
  assert(registered.isNotEmpty);
  return result;
}

/// 1:1: the `IEnvironmentalOptions` object literal built by `_computeOptions`.
class _EnvironmentalOptionsImpl implements IEnvironmentalOptions {
  _EnvironmentalOptionsImpl({
    required this.memory,
    required this.outerWidth,
    required this.outerHeight,
    required this.fontInfo,
    required this.extraEditorClassName,
    required this.isDominatedByLongLines,
    required this.viewLineCount,
    required this.lineNumbersDigitCount,
    required this.emptySelectionClipboard,
    required this.pixelRatio,
    required this.tabFocusMode,
    required this.inputMode,
    required this.accessibilitySupport,
    required this.glyphMarginDecorationLaneCount,
    required this.editContextSupported,
  });

  @override
  final ComputeOptionsMemory? memory;

  @override
  final double outerWidth;

  @override
  final double outerHeight;

  @override
  final FontInfo fontInfo;

  @override
  final String extraEditorClassName;

  @override
  final bool isDominatedByLongLines;

  @override
  final num viewLineCount;

  @override
  final num lineNumbersDigitCount;

  @override
  final bool emptySelectionClipboard;

  @override
  final double pixelRatio;

  @override
  final bool tabFocusMode;

  @override
  final String inputMode;

  @override
  final int accessibilitySupport;

  @override
  final num glyphMarginDecorationLaneCount;

  @override
  final bool editContextSupported;
}
