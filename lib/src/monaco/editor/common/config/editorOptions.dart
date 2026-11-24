// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/config/editorOptions.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// SEGMENTED PORT (file in progress; PORT_PROGRESS keeps `pending` until the
// whole source file is translated):
//   segment 1/4 (this commit): source lines 1–52 (string-union types +
//     EditorAutoIndentStrategy), 1055–1467 (option framework:
//     ConfigurationChangedEvent, IEditorOption/BaseEditorOption/
//     ComputedEditorOption/SimpleEditorOption, ApplyUpdateResult/applyUpdate,
//     validation helpers), 1468–1526 (_autoIndentFromString,
//     EditorAccessibilitySupport), 5952–5957 (editorOptionsRegistry),
//     5959–6143 (EditorOption enum).
//   segment 2/4 (this commit): lines 53–1054 (IEditorOptions — generated
//     by `tool/ts2dart/_gen_editor_options.py` — MINIMAP_GUTTER_WIDTH,
//     diff editor options, ValidDiffEditorBaseOptions).
//   segment 3a/4 (this commit): option classes 1527–2555 (comments,
//     cursorBlinking, cursorStyle, editorClassName, emptySelectionClipboard,
//     find, fontLigatures, fontVariations, fontInfo, the five effective*
//     computed options, fontSize, fontWeight, gotoLocation, hover,
//     markdownImages + getUrlOrigin/isMarkdownImageAllowed).
//   segment 3b/4 (pending): lines 2556–5958 (layoutInfo computer, minimap,
//     suggest, scrollbar, unicodeHighlight, inlineSuggest, ...).
//   segment 3/4 (pending): lines 2600–5958 (option classes cont.).
//   segment 4/4 (pending): lines 6144–7102 (EditorOptions registry object +
//     type-level helpers).
//
// Adaptations (documented inline):
//  * `const enum` → class of `static const int` (same convention as
//    `keyCodes.dart`); EditorOption values are generated from the source
//    table to avoid transcription drift.
//  * `PossibleKeyName<T>` / `Unknown<T>` are type-level computed key types →
//    erased; `name` is a `String` carrying the same value.
//  * TS instantiates `BaseEditorOption<K extends EditorOption, ...>` with
//    const-enum member *literal types* (`EditorOption.accessibilitySupport`);
//    Dart has no literal-type generics → `K` erases to `int id`
//    (`IEditorOption<V>`, `BaseEditorOption<V>`, ...).
//  * `IConfigurationPropertySchema | { [path]: ... }` → the ported
//    `IConfigurationPropertySchema` typedef (`Map<String, Object?>`);
//    constructor mutations become key writes.
//  * `ComputeOptionsMemory.stableMinimapLayoutInput` references
//    `IMinimapLayoutInput` (defined later in the source) → `Object?` carrier
//    until segment 2 lands.
//  * JS `parseInt`/`parseFloat` parse leading numeric prefixes of strings;
//    Dart `int.tryParse`/`double.tryParse` reject the whole string →
//    `_jsParseInt`/`_jsParseFloat` helpers.
//  * `IEnvironmentalOptions`/`IComputedEditorOptions` are interfaces →
//    abstract classes; `get<T extends EditorOption>` erases to
//    `Object? get(Object id)`.
// ---------------------------------------------------------------------------

import '../../../base/common/arrays.dart' as arrays;
import '../../../nls.dart' show localize;
import '../../../platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;
import '../../../platform/configuration/common/configurationRegistry.dart'
    show IConfigurationPropertySchema;
import '../../../base/common/platform.dart' as platform;
import 'fontInfo.dart'
    show
        EDITOR_FONT_DEFAULTS,
        FONT_VARIATION_OFF,
        FONT_VARIATION_TRANSLATE,
        FontInfo,
        FontInfoOptions;

//#region typed options

/// Configuration options for auto closing quotes and brackets
/// 1:1: `export type EditorAutoClosingStrategy`.
class EditorAutoClosingStrategy {
  static const String always = 'always';
  static const String languageDefined = 'languageDefined';
  static const String beforeWhitespace = 'beforeWhitespace';
  static const String never = 'never';

  const EditorAutoClosingStrategy._();
}

/// Configuration options for auto wrapping quotes and brackets
/// 1:1: `export type EditorAutoSurroundStrategy`.
class EditorAutoSurroundStrategy {
  static const String languageDefined = 'languageDefined';
  static const String quotes = 'quotes';
  static const String brackets = 'brackets';
  static const String never = 'never';

  const EditorAutoSurroundStrategy._();
}

/// Configuration options for typing over closing quotes or brackets
/// 1:1: `export type EditorAutoClosingEditStrategy`.
class EditorAutoClosingEditStrategy {
  static const String always = 'always';
  static const String auto = 'auto';
  static const String never = 'never';

  const EditorAutoClosingEditStrategy._();
}

/// 1:1: `type Unknown<T> = { [K in keyof T]: unknown }` — type-level only.
// typedef Unknown<T> = ...; (erased)

/// Configuration options for auto indentation in the editor
/// 1:1: `export const enum EditorAutoIndentStrategy`.
class EditorAutoIndentStrategy {
  static const int none = 0;
  static const int keep = 1;
  static const int brackets = 2;
  static const int advanced = 3;
  static const int full = 4;

  const EditorAutoIndentStrategy._();
}

//#endregion

//#region IEditorOptions

/// Configuration options for the editor.
///
/// 1:1: `export interface IEditorOptions` — generated from the source
/// table by `tool/ts2dart/_gen_editor_options.py` (same precedent as
/// `themes.dart` / `keyCodes.dart`): field names, optionality, doc
/// comments and order are 1:1 (the generator asserts full coverage).
/// Type mapping: `boolean`/`string`/`number` and pure string-literal
/// unions map to `bool?`/`String?`/`num?`/`List<String?>?`; every other
/// type (nested option interfaces, function types, imported types, mixed
/// unions) is carried as `Object?` with the original type in a `// TS:`
/// comment — these fields are structural user input, and the option
/// classes in the following segments validate them with fully typed
/// carriers.
class IEditorOptions {
  IEditorOptions();

  /// This editor is used inside a diff editor.
  bool? inDiffEditor;

  /// This editor is allowed to use variable line heights.
  bool? allowVariableLineHeights;

  /// This editor is allowed to use variable font-sizes and font-families
  bool? allowVariableFonts;

  /// This editor is allowed to use variable font-sizes and font-families in accessibility mode
  bool? allowVariableFontsInAccessibilityMode;

  /// The aria label for the editor's textarea (when it is focused).
  String? ariaLabel;

  /// Whether the aria-required attribute should be set on the editors textarea.
  bool? ariaRequired;

  /// Control whether a screen reader announces inline suggestion content immediately.
  bool? screenReaderAnnounceInlineSuggestion;

  /// The `tabindex` property of the editor's textarea
  num? tabIndex;

  /// Render vertical lines at the specified columns.
  /// Defaults to empty array.
  // TS: (number | IRulerOption)[]
  Object? rulers;

  /// Locales used for segmenting lines into words when doing word related navigations or operations.
  /// Specify the BCP 47 language tag of the word you wish to recognize (e.g., ja, zh-CN, zh-Hant-TW, etc.).
  /// Defaults to empty array
  // TS: string | string[]
  Object? wordSegmenterLocales;

  /// A string containing the word separators used when doing word navigation.
  /// Defaults to `~!@#$%^&*()-=+[{]}\\|;:\'",.<>/?
  String? wordSeparators;

  /// Enable Linux primary clipboard.
  /// Defaults to true.
  bool? selectionClipboard;

  /// Control the rendering of line numbers.
  /// If it is a function, it will be invoked when rendering a line number and the return value will be rendered.
  /// Otherwise, if it is a truthy, line numbers will be rendered normally (equivalent of using an identity function).
  /// Otherwise, line numbers will not be rendered.
  /// Defaults to `on`.
  // TS: LineNumbersType
  Object? lineNumbers;

  /// Controls the minimal number of visible leading and trailing lines surrounding the cursor.
  /// Defaults to 0.
  num? cursorSurroundingLines;

  /// Controls when `cursorSurroundingLines` should be enforced
  /// Defaults to `default`, `cursorSurroundingLines` is not enforced when cursor position is changed
  /// by mouse.
  String? cursorSurroundingLinesStyle;

  /// Render last line number when the file ends with a newline.
  /// Defaults to 'on' for Windows and macOS and 'dimmed' for Linux.
  String? renderFinalNewline;

  /// Remove unusual line terminators like LINE SEPARATOR (LS), PARAGRAPH SEPARATOR (PS).
  /// Defaults to 'prompt'.
  String? unusualLineTerminators;

  /// Should the corresponding line be selected when clicking on the line number?
  /// Defaults to true.
  bool? selectOnLineNumbers;

  /// Control the width of line numbers, by reserving horizontal space for rendering at least an amount of digits.
  /// Defaults to 5.
  num? lineNumbersMinChars;

  /// Enable the rendering of the glyph margin.
  /// Defaults to true in vscode and to false in monaco-editor.
  bool? glyphMargin;

  /// The width reserved for line decorations (in px).
  /// Line decorations are placed between line numbers and the editor content.
  /// You can pass in a string in the format floating point followed by "ch". e.g. 1.3ch.
  /// Defaults to 10.
  // TS: number | string
  Object? lineDecorationsWidth;

  /// When revealing the cursor, a virtual padding (px) is added to the cursor, turning it into a rectangle.
  /// This virtual padding ensures that the cursor gets revealed before hitting the edge of the viewport.
  /// Defaults to 30 (px).
  num? revealHorizontalRightPadding;

  /// Render the editor selection with rounded borders.
  /// Defaults to true.
  bool? roundedSelection;

  /// Class name to be added to the editor.
  String? extraEditorClassName;

  /// Should the editor be read only. See also `domReadOnly`.
  /// Defaults to false.
  bool? readOnly;

  /// The message to display when the editor is readonly.
  // TS: IMarkdownString
  Object? readOnlyMessage;

  /// Should the textarea used for input use the DOM `readonly` attribute.
  /// Defaults to false.
  bool? domReadOnly;

  /// Enable linked editing.
  /// Defaults to false.
  bool? linkedEditing;

  /// deprecated, use linkedEditing instead
  bool? renameOnType;

  /// Should the editor render validation decorations.
  /// Defaults to editable.
  String? renderValidationDecorations;

  /// Control the behavior and rendering of the scrollbars.
  // TS: IEditorScrollbarOptions
  Object? scrollbar;

  /// Control the behavior of sticky scroll options
  // TS: IEditorStickyScrollOptions
  Object? stickyScroll;

  /// Control the behavior and rendering of the minimap.
  // TS: IEditorMinimapOptions
  Object? minimap;

  /// Control the behavior of the find widget.
  // TS: IEditorFindOptions
  Object? find;

  /// Display overflow widgets as `fixed`.
  /// Defaults to `false`.
  bool? fixedOverflowWidgets;

  /// Allow content widgets and overflow widgets to overflow the editor viewport.
  /// Defaults to `true`.
  bool? allowOverflow;

  /// The number of vertical lanes the overview ruler should render.
  /// Defaults to 3.
  num? overviewRulerLanes;

  /// Controls if a border should be drawn around the overview ruler.
  /// Defaults to `true`.
  bool? overviewRulerBorder;

  /// Control the cursor animation style, possible values are 'blink', 'smooth', 'phase', 'expand' and 'solid'.
  /// Defaults to 'blink'.
  String? cursorBlinking;

  /// Zoom the font in the editor when using the mouse wheel in combination with holding Ctrl.
  /// Defaults to false.
  bool? mouseWheelZoom;

  /// Control the mouse pointer style, either 'text' or 'default' or 'copy'
  /// Defaults to 'text'
  String? mouseStyle;

  /// Enable smooth caret animation.
  /// Defaults to 'off'.
  String? cursorSmoothCaretAnimation;

  /// Control the cursor style in insert mode.
  /// Defaults to 'line'.
  String? cursorStyle;

  /// Control the cursor style in overtype mode.
  /// Defaults to 'block'.
  String? overtypeCursorStyle;

  /// Controls whether paste in overtype mode should overwrite or insert.
  bool? overtypeOnPaste;

  /// Control the width of the cursor when cursorStyle is set to 'line'
  num? cursorWidth;

  /// Control the height of the cursor when cursorStyle is set to 'line'
  num? cursorHeight;

  /// Enable font ligatures.
  /// Defaults to false.
  // TS: boolean | string
  Object? fontLigatures;

  /// Enable font variations.
  /// Defaults to false.
  // TS: boolean | string
  Object? fontVariations;

  /// Controls whether to use default color decorations or not using the default document color provider
  String? defaultColorDecorators;

  /// Disable the use of `transform: translate3d(0px, 0px, 0px)` for the editor margin and lines layers.
  /// The usage of `transform: translate3d(0px, 0px, 0px)` acts as a hint for browsers to create an extra layer.
  /// Defaults to false.
  bool? disableLayerHinting;

  /// Disable the optimizations for monospace fonts.
  /// Defaults to false.
  bool? disableMonospaceOptimizations;

  /// Should the cursor be hidden in the overview ruler.
  /// Defaults to false.
  bool? hideCursorInOverviewRuler;

  /// Enable that scrolling can go one screen size after the last line.
  /// Defaults to true.
  bool? scrollBeyondLastLine;

  /// Scroll editor on middle click
  bool? scrollOnMiddleClick;

  /// Enable that scrolling can go beyond the last column by a number of columns.
  /// Defaults to 5.
  num? scrollBeyondLastColumn;

  /// Enable that the editor animates scrolling to a position.
  /// Defaults to false.
  bool? smoothScrolling;

  /// Enable that the editor will install a ResizeObserver to check if its container dom node size has changed.
  /// Defaults to false.
  bool? automaticLayout;

  /// Control the wrapping of the editor.
  /// When `wordWrap` = "off", the lines will never wrap.
  /// When `wordWrap` = "on", the lines will wrap at the viewport width.
  /// When `wordWrap` = "wordWrapColumn", the lines will wrap at `wordWrapColumn`.
  /// When `wordWrap` = "bounded", the lines will wrap at min(viewport width, wordWrapColumn).
  /// Defaults to "off".
  String? wordWrap;

  /// Control whether an indicator is rendered at the wrapping column of soft wrapped lines.
  /// Defaults to false.
  bool? wordWrapIndicator;

  /// Override the `wordWrap` setting.
  String? wordWrapOverride1;

  /// Override the `wordWrapOverride1` setting.
  String? wordWrapOverride2;

  /// Control the wrapping of the editor.
  /// When `wordWrap` = "off", the lines will never wrap.
  /// When `wordWrap` = "on", the lines will wrap at the viewport width.
  /// When `wordWrap` = "wordWrapColumn", the lines will wrap at `wordWrapColumn`.
  /// When `wordWrap` = "bounded", the lines will wrap at min(viewport width, wordWrapColumn).
  /// Defaults to 80.
  num? wordWrapColumn;

  /// Control indentation of wrapped lines. Can be: 'none', 'same', 'indent' or 'deepIndent'.
  /// Defaults to 'same' in vscode and to 'none' in monaco-editor.
  String? wrappingIndent;

  /// Controls the wrapping strategy to use.
  /// Defaults to 'simple'.
  String? wrappingStrategy;

  /// Create a softwrap on every quoted "\n" literal.
  /// Defaults to false.
  bool? wrapOnEscapedLineFeeds;

  /// Configure word wrapping characters. A break will be introduced before these characters.
  String? wordWrapBreakBeforeCharacters;

  /// Configure word wrapping characters. A break will be introduced after these characters.
  String? wordWrapBreakAfterCharacters;

  /// Sets whether line breaks appear wherever the text would otherwise overflow its content box.
  /// When wordBreak = 'normal', Use the default line break rule.
  /// When wordBreak = 'keepAll', Word breaks should not be used for Chinese/Japanese/Korean (CJK) text. Non-CJK text behavior is the same as for normal.
  String? wordBreak;

  /// Performance guard: Stop rendering a line after x characters.
  /// Defaults to 10000.
  /// Use -1 to never stop rendering
  num? stopRenderingLineAfter;

  /// Configure the editor's hover.
  // TS: IEditorHoverOptions
  Object? hover;

  /// Controls which remote images Markdown rendered by the editor may load,
  /// for example in hovers, suggestion details and parameter hints.
  // TS: IEditorMarkdownImagesOptions
  Object? markdownImages;

  /// Enable detecting links and making them clickable.
  /// Defaults to true.
  bool? links;

  /// Enable inline color decorators and color picker rendering.
  bool? colorDecorators;

  /// Controls what is the condition to spawn a color picker from a color dectorator
  String? colorDecoratorsActivatedOn;

  /// Controls the max number of color decorators that can be rendered in an editor at once.
  num? colorDecoratorsLimit;

  /// Control the behaviour of comments in the editor.
  // TS: IEditorCommentsOptions
  Object? comments;

  /// Enable custom contextmenu.
  /// Defaults to true.
  bool? contextmenu;

  /// A multiplier to be used on the `deltaX` and `deltaY` of mouse wheel scroll events.
  /// Defaults to 1.
  num? mouseWheelScrollSensitivity;

  /// FastScrolling mulitplier speed when pressing `Alt`
  /// Defaults to 5.
  num? fastScrollSensitivity;

  /// Enable that the editor scrolls only the predominant axis. Prevents horizontal drift when scrolling vertically on a trackpad.
  /// Defaults to true.
  bool? scrollPredominantAxis;

  /// Make scrolling inertial - mostly useful with touchpad on linux.
  bool? inertialScroll;

  /// Enable that the selection with the mouse and keys is doing column selection.
  /// Defaults to false.
  bool? columnSelection;

  /// The modifier to be used to add multiple cursors with the mouse.
  /// Defaults to 'alt'
  String? multiCursorModifier;

  /// Merge overlapping selections.
  /// Defaults to true
  bool? multiCursorMergeOverlapping;

  /// Configure the behaviour when pasting text with a line count equal to the cursor count or when pasting column selections into a single cursor.
  /// Defaults to 'spread'.
  String? multiCursorPaste;

  /// Controls the max number of text cursors that can be in an active editor at once.
  num? multiCursorLimit;

  /// Enables middle mouse button to open links and Go To Definition
  // TS: MouseMiddleClickAction
  Object? mouseMiddleClickAction;

  /// Configure the editor's accessibility support.
  /// Defaults to 'auto'. It is best to leave this to 'auto'.
  String? accessibilitySupport;

  /// Controls the number of lines in the editor that can be read out by a screen reader
  num? accessibilityPageSize;

  /// Suggest options.
  // TS: ISuggestOptions
  Object? suggest;

  // TS: IInlineSuggestOptions
  Object? inlineSuggest;

  /// Smart select options.
  // TS: ISmartSelectOptions
  Object? smartSelect;

  // TS: IGotoLocationOptions
  Object? gotoLocation;

  /// Enable quick suggestions (shadow suggestions)
  /// Defaults to true.
  // TS: boolean | QuickSuggestionsValue | IQuickSuggestionsOptions
  Object? quickSuggestions;

  /// Quick suggestions show delay (in ms)
  /// Defaults to 10 (ms)
  num? quickSuggestionsDelay;

  /// Controls the spacing around the editor.
  // TS: IEditorPaddingOptions
  Object? padding;

  /// Parameter hint options.
  // TS: IEditorParameterHintOptions
  Object? parameterHints;

  /// Options for auto closing brackets.
  /// Defaults to language defined behavior.
  // TS: EditorAutoClosingStrategy
  Object? autoClosingBrackets;

  /// Options for auto closing comments.
  /// Defaults to language defined behavior.
  // TS: EditorAutoClosingStrategy
  Object? autoClosingComments;

  /// Options for auto closing quotes.
  /// Defaults to language defined behavior.
  // TS: EditorAutoClosingStrategy
  Object? autoClosingQuotes;

  /// Options for pressing backspace near quotes or bracket pairs.
  // TS: EditorAutoClosingEditStrategy
  Object? autoClosingDelete;

  /// Options for typing over closing quotes or brackets.
  // TS: EditorAutoClosingEditStrategy
  Object? autoClosingOvertype;

  /// Options for auto surrounding.
  /// Defaults to always allowing auto surrounding.
  // TS: EditorAutoSurroundStrategy
  Object? autoSurround;

  /// Controls whether the editor should automatically adjust the indentation when users type, paste, move or indent lines.
  /// Defaults to advanced.
  String? autoIndent;

  /// Boolean which controls whether to autoindent on paste
  bool? autoIndentOnPaste;

  /// Boolean which controls whether to autoindent on paste within a string when autoIndentOnPaste is enabled.
  bool? autoIndentOnPasteWithinString;

  /// Emulate selection behaviour of tab characters when using spaces for indentation.
  /// This means selection will stick to tab stops.
  bool? stickyTabStops;

  /// Enable format on type.
  /// Defaults to false.
  bool? formatOnType;

  /// Enable format on paste.
  /// Defaults to false.
  bool? formatOnPaste;

  /// Controls the width used to render full-width characters.
  /// Defaults to 'font'.
  String? fullwidthCharacterWidth;

  /// Controls whether double-clicking next to a bracket or quote selects the content inside.
  /// Defaults to true.
  bool? doubleClickSelectsBlock;

  /// Controls if the editor should allow to move selections via drag and drop.
  /// Defaults to false.
  bool? dragAndDrop;

  /// Enable the suggestion box to pop-up on trigger characters.
  /// Defaults to true.
  bool? suggestOnTriggerCharacters;

  /// Accept suggestions on ENTER.
  /// Defaults to 'on'.
  String? acceptSuggestionOnEnter;

  /// Accept suggestions on provider defined characters.
  /// Defaults to true.
  bool? acceptSuggestionOnCommitCharacter;

  /// Enable snippet suggestions. Default to 'true'.
  String? snippetSuggestions;

  /// Copying without a selection copies the current line.
  bool? emptySelectionClipboard;

  /// Syntax highlighting is copied.
  bool? copyWithSyntaxHighlighting;

  /// The history mode for suggestions.
  String? suggestSelection;

  /// The font size for the suggest widget.
  /// Defaults to the editor font size.
  num? suggestFontSize;

  /// The line height for the suggest widget.
  /// Defaults to the editor line height.
  num? suggestLineHeight;

  /// Enable tab completion.
  String? tabCompletion;

  /// Enable selection highlight.
  /// Defaults to true.
  bool? selectionHighlight;

  /// Enable selection highlight for multiline selections.
  /// Defaults to false.
  bool? selectionHighlightMultiline;

  /// Maximum length (in characters) for selection highlights.
  /// Set to 0 to have an unlimited length.
  num? selectionHighlightMaxLength;

  /// Controls how occurrences of selected text are matched for occurrence selection and highlighting.
  /// Defaults to 'findOptions', which uses the Find widget's match case and whole word settings.
  String? selectedTextMatchMode;

  /// Enable semantic occurrences highlight.
  /// Defaults to 'singleFile'.
  /// 'off' disables occurrence highlighting
  /// 'singleFile' triggers occurrence highlighting in the current document
  /// 'multiFile'  triggers occurrence highlighting across valid open documents
  String? occurrencesHighlight;

  /// Controls delay for occurrences highlighting
  /// Defaults to 250.
  /// Minimum value is 0
  /// Maximum value is 2000
  num? occurrencesHighlightDelay;

  /// Merge single-document highlights from all matching providers.
  /// Defaults to false.
  bool? occurrencesHighlightFromAllProviders;

  /// Show code lens
  /// Defaults to true.
  bool? codeLens;

  /// Code lens font family. Defaults to editor font family.
  String? codeLensFontFamily;

  /// Code lens font size. Default to 90% of the editor font size
  num? codeLensFontSize;

  /// Control the behavior and rendering of the code action lightbulb.
  // TS: IEditorLightbulbOptions
  Object? lightbulb;

  /// Timeout for running code actions on save.
  num? codeActionsOnSaveTimeout;

  /// Enable code folding.
  /// Defaults to true.
  bool? folding;

  /// Selects the folding strategy. 'auto' uses the strategies contributed for the current document, 'indentation' uses the indentation based folding strategy.
  /// Defaults to 'auto'.
  String? foldingStrategy;

  /// Enable highlight for folded regions.
  /// Defaults to true.
  bool? foldingHighlight;

  /// Auto fold imports folding regions.
  /// Defaults to true.
  bool? foldingImportsByDefault;

  /// Maximum number of foldable regions.
  /// Defaults to 5000.
  num? foldingMaximumRegions;

  /// Controls whether the fold actions in the gutter stay always visible or hide unless the mouse is over the gutter.
  /// Defaults to 'mouseover'.
  String? showFoldingControls;

  /// Controls whether clicking on the empty content after a folded line will unfold the line.
  /// Defaults to false.
  bool? unfoldOnClickAfterEndOfLine;

  /// Enable highlighting of matching brackets.
  /// Defaults to 'always'.
  String? matchBrackets;

  /// Enable experimental rendering using WebGPU.
  /// Defaults to 'off'.
  String? experimentalGpuAcceleration;

  /// Enable experimental whitespace rendering.
  /// Defaults to 'svg'.
  String? experimentalWhitespaceRendering;

  /// Enable rendering of whitespace.
  /// Defaults to 'selection'.
  String? renderWhitespace;

  /// Enable rendering of control characters.
  /// Defaults to true.
  bool? renderControlCharacters;

  /// Enable rendering of current line highlight.
  /// Defaults to all.
  String? renderLineHighlight;

  /// Control if the current line highlight should be rendered only the editor is focused.
  /// Defaults to false.
  bool? renderLineHighlightOnlyWhenFocus;

  /// Inserting and deleting whitespace follows tab stops.
  bool? useTabStops;

  /// Controls whether the editor should automatically remove indentation whitespace when joining lines with Delete.
  /// Defaults to false.
  bool? trimWhitespaceOnDelete;

  /// The font family
  String? fontFamily;

  /// The font weight
  String? fontWeight;

  /// The font size
  num? fontSize;

  /// The line height
  num? lineHeight;

  /// The letter spacing
  num? letterSpacing;

  /// Controls fading out of unused variables.
  bool? showUnused;

  /// Controls whether to focus the inline editor in the peek widget by default.
  /// Defaults to false.
  String? peekWidgetDefaultFocus;

  /// Sets a placeholder for the editor.
  /// If set, the placeholder is shown if the editor is empty.
  // TS: string | undefined
  Object? placeholder;

  /// Controls whether the definition link opens element in the peek widget.
  /// Defaults to false.
  bool? definitionLinkOpensInPeek;

  /// Controls strikethrough deprecated variables.
  bool? showDeprecated;

  /// Controls whether suggestions allow matches in the middle of the word instead of only at the beginning
  bool? matchOnWordStartOnly;

  /// Control the behavior and rendering of the inline hints.
  // TS: IEditorInlayHintsOptions
  Object? inlayHints;

  /// Control if the editor should use shadow DOM.
  bool? useShadowDOM;

  /// Controls the behavior of editor guides.
  // TS: IGuidesOptions
  Object? guides;

  /// Controls the behavior of the unicode highlight feature
  /// (by default, ambiguous and invisible characters are highlighted).
  // TS: IUnicodeHighlightOptions
  Object? unicodeHighlight;

  /// Configures bracket pair colorization (disabled by default).
  // TS: IBracketPairColorizationOptions
  Object? bracketPairColorization;

  /// Controls dropping into the editor from an external source.
  /// When enabled, this shows a preview of the drop location and triggers an `onDropIntoEditor` event.
  // TS: IDropIntoEditorOptions
  Object? dropIntoEditor;

  /// Sets whether the new experimental edit context should be used instead of the text area.
  bool? editContext;

  /// Controls whether to render rich HTML screen reader content when the EditContext is enabled
  bool? renderRichScreenReaderContent;

  /// Controls support for changing how content is pasted into the editor.
  // TS: IPasteAsOptions
  Object? pasteAs;

  /// Controls whether the editor / terminal receives tabs or defers them to the workbench for navigation.
  bool? tabFocusMode;

  /// Controls whether the accessibility hint should be provided to screen reader users when an inline completion is shown.
  bool? inlineCompletionsAccessibilityVerbose;

}

//#endregion

//#region diff editor options

/// 1:1: `export const MINIMAP_GUTTER_WIDTH = 8`.
const int MINIMAP_GUTTER_WIDTH = 8;

/// 1:1: `export type DiffEditorViewMode = 'inline' | 'sideBySide' | 'automatic'`.
class DiffEditorViewMode {
  static const String inline = 'inline';
  static const String sideBySide = 'sideBySide';
  static const String automatic = 'automatic';

  const DiffEditorViewMode._();
}

/// 1:1: `export interface IDiffEditorBaseOptions`. The two inline object
/// types (`experimental`, `hideUnchangedRegions`) are carried as `Object?`
/// (structural input; the diff-editor option classes in
/// `browser/widget/diffEditor/diffEditorOptions.ts` read them dynamically).
class IDiffEditorBaseOptions {
  IDiffEditorBaseOptions();

  /// Allow the user to resize the diff editor split view.
  /// Defaults to true.
  bool? enableSplitViewResizing;

  /// The default ratio when rendering side-by-side editors.
  /// Must be a number between 0 and 1, min sizes apply.
  /// Defaults to 0.5
  num? splitViewDefaultRatio;

  /// Render the differences in two side-by-side editors.
  /// Defaults to true.
  bool? renderSideBySide;

  /// When `renderSideBySide` is enabled, `useInlineViewWhenSpaceIsLimited` is set,
  /// and the diff editor has a width less than `renderSideBySideInlineBreakpoint`, the inline view is used.
  // TS: number | undefined
  num? renderSideBySideInlineBreakpoint;

  /// When `renderSideBySide` is enabled, `useInlineViewWhenSpaceIsLimited` is set,
  /// and the diff editor has a width less than `renderSideBySideInlineBreakpoint`, the inline view is used.
  bool? useInlineViewWhenSpaceIsLimited;

  /// If set, the diff editor is optimized for small views.
  /// Defaults to `false`.
  bool? compactMode;

  /// If set, the original editor's line numbers are hidden in the inline view.
  /// Defaults to `false`.
  /// @internal
  bool? hideOriginalLineNumbers;

  /// Timeout in milliseconds after which diff computation is cancelled.
  /// Defaults to 5000.
  num? maxComputationTime;

  /// Maximum supported file size in MB.
  /// Defaults to 50.
  num? maxFileSize;

  /// Compute the diff by ignoring leading/trailing whitespace
  /// Defaults to true.
  bool? ignoreTrimWhitespace;

  /// Render +/- indicators for added/deleted changes.
  /// Defaults to true.
  bool? renderIndicators;

  /// Shows icons in the glyph margin to revert changes.
  /// Default to true.
  bool? renderMarginRevertIcon;

  /// Indicates if the gutter menu should be rendered.
  bool? renderGutterMenu;

  /// Original model should be editable?
  /// Defaults to false.
  bool? originalEditable;

  /// Should the diff editor enable code lens?
  /// Defaults to false.
  bool? diffCodeLens;

  /// Is the diff editor should render overview ruler
  /// Defaults to true
  bool? renderOverviewRuler;

  /// Control the wrapping of the diff editor.
  String? diffWordWrap;

  /// Diff Algorithm
  String? diffAlgorithm;

  /// Whether the diff editor aria label should be verbose.
  bool? accessibilityVerbose;

  /// TS: `{ showMoves?: boolean; showEmptyDecorations?: boolean;
  /// useTrueInlineView?: boolean; }`
  Object? experimental;

  /// Is the diff editor inside another editor
  /// Defaults to false
  bool? isInEmbeddedEditor;

  /// If the diff editor should only show the difference review mode.
  bool? onlyShowAccessibleDiffViewer;

  /// TS: `{ enabled?: boolean; revealLineCount?: number; minimumLineCount?:
  /// number; contextLineCount?: number; }`
  Object? hideUnchangedRegions;
}

/// Configuration options for the diff editor.
///
/// 1:1: `export interface IDiffEditorOptions extends IEditorOptions,
/// IDiffEditorBaseOptions` — TS interface multi-extension has no Dart
/// equivalent, so the concrete carrier extends [IEditorOptions] and unions
/// the [IDiffEditorBaseOptions] fields inline (documented adaptation).
class IDiffEditorOptions extends IEditorOptions {
  IDiffEditorOptions();

  bool? enableSplitViewResizing;
  num? splitViewDefaultRatio;
  bool? renderSideBySide;
  num? renderSideBySideInlineBreakpoint;
  bool? useInlineViewWhenSpaceIsLimited;
  bool? compactMode;
  bool? hideOriginalLineNumbers;
  num? maxComputationTime;
  num? maxFileSize;
  bool? ignoreTrimWhitespace;
  bool? renderIndicators;
  bool? renderMarginRevertIcon;
  bool? renderGutterMenu;
  bool? originalEditable;
  bool? diffCodeLens;
  bool? renderOverviewRuler;
  String? diffWordWrap;
  String? diffAlgorithm;
  bool? accessibilityVerbose;
  Object? experimental;
  bool? isInEmbeddedEditor;
  bool? onlyShowAccessibleDiffViewer;
  Object? hideUnchangedRegions;
}

/// @internal
/// 1:1: `export type ValidDiffEditorBaseOptions = Readonly<Required<IDiffEditorBaseOptions>>`
/// — the `Required<>` resolution makes every field non-optional; getters are
/// non-nullable for the primitive fields, and the two inline object types
/// stay `Object?` carriers.
abstract class ValidDiffEditorBaseOptions {
  bool get enableSplitViewResizing;
  num get splitViewDefaultRatio;
  bool get renderSideBySide;
  num get renderSideBySideInlineBreakpoint;
  bool get useInlineViewWhenSpaceIsLimited;
  bool get compactMode;
  bool get hideOriginalLineNumbers;
  num get maxComputationTime;
  num get maxFileSize;
  bool get ignoreTrimWhitespace;
  bool get renderIndicators;
  bool get renderMarginRevertIcon;
  bool get renderGutterMenu;
  bool get originalEditable;
  bool get diffCodeLens;
  bool get renderOverviewRuler;
  String get diffWordWrap;
  String get diffAlgorithm;
  bool get accessibilityVerbose;
  Object? get experimental;
  bool get isInEmbeddedEditor;
  bool get onlyShowAccessibleDiffViewer;
  Object? get hideUnchangedRegions;
}

//#endregion

//#region IEditorOption

/// 1:1: `export class ConfigurationChangedEvent`.
class ConfigurationChangedEvent {
  ConfigurationChangedEvent(List<bool> values) : _values = values;

  final List<bool> _values;

  bool hasChanged(int id) {
    return _values[id];
  }
}

/// All computed editor options.
/// 1:1: `export interface IComputedEditorOptions`.
abstract class IComputedEditorOptions {
  Object? get(Object id);
}

//#region IEditorOption

/// @internal
/// 1:1: `export interface IEnvironmentalOptions`.
abstract class IEnvironmentalOptions {
  ComputeOptionsMemory? get memory;
  double get outerWidth;
  double get outerHeight;
  FontInfo get fontInfo;
  String get extraEditorClassName;
  bool get isDominatedByLongLines;
  num get viewLineCount;
  num get lineNumbersDigitCount;
  bool get emptySelectionClipboard;
  double get pixelRatio;
  bool get tabFocusMode;

  /// `'insert' | 'overtype'`.
  String get inputMode;
  int get accessibilitySupport;
  num get glyphMarginDecorationLaneCount;
  bool get editContextSupported;
}

/// @internal
/// 1:1: `export class ComputeOptionsMemory`.
class ComputeOptionsMemory {
  /// TS: `IMinimapLayoutInput | null` — carrier until segment 2.
  Object? stableMinimapLayoutInput;
  double stableFitMaxMinimapScale = 0;
  double stableFitRemainingWidth = 0;

  ComputeOptionsMemory() {
    stableMinimapLayoutInput = null;
    stableFitMaxMinimapScale = 0;
    stableFitRemainingWidth = 0;
  }
}

/// 1:1: `export interface IEditorOption<K extends EditorOption, V>`
/// (K erased to `int id` — see the header note).
abstract class IEditorOption<V> {
  int get id;
  String get name;

  // TS: non-readonly field; implementations keep it fixed after construction.
  V get defaultValue;

  /// @internal
  IConfigurationPropertySchema? get schema;

  /// @internal
  V validate(Object? input);

  /// @internal
  V compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, V value);

  /// Might modify `value`.
  ApplyUpdateResult<V> applyUpdate(Object? value, Object? update);
}

/// 1:1: `type PossibleKeyName0<V>` / `PossibleKeyName<V>` — type-level
/// computed key names; erased, `name` is the same string.
// typedef PossibleKeyName<V> = String;

/// @internal
/// 1:1: `abstract class BaseEditorOption<K extends EditorOption, T, V>`
/// (`T` exists only in the erased `PossibleKeyName<T>` name type).
abstract class BaseEditorOption<V> implements IEditorOption<V> {
  BaseEditorOption(this.id, this.name, this.defaultValue,
      [IConfigurationPropertySchema? schema])
      : schema = schema;

  final int id;
  @override
  final String name;
  @override
  final V defaultValue;
  @override
  final IConfigurationPropertySchema? schema;

  @override
  ApplyUpdateResult<V> applyUpdate(Object? value, Object? update) {
    return _applyUpdate<V>(value, update);
  }

  @override
  V validate(Object? input);

  @override
  V compute(
          IEnvironmentalOptions env, IComputedEditorOptions options, V value) =>
      value;
}

/// 1:1: `export class ApplyUpdateResult<T>`.
class ApplyUpdateResult<T> {
  ApplyUpdateResult(this.newValue, this.didChange);

  final T newValue;
  final bool didChange;
}

/// 1:1: `function applyUpdate<T>(value, update)`.
ApplyUpdateResult<T> _applyUpdate<T>(Object? value, Object? update) {
  final bool valueIsObject = (value is Map || value is List) && value != null;
  final bool updateIsObject =
      (update is Map || update is List) && update != null;
  if (!valueIsObject || !updateIsObject) {
    return ApplyUpdateResult<T>(update as T, value != update);
  }
  if (value is List || update is List) {
    final bool arrayEquals = value is List &&
        update is List &&
        arrays.equals<Object?>(value, update);
    return ApplyUpdateResult<T>(update as T, !arrayEquals);
  }
  bool didChange = false;
  final Map<Object?, Object?> valueMap = value as Map<Object?, Object?>;
  final Map<Object?, Object?> updateMap = update as Map<Object?, Object?>;
  for (final Object? key in updateMap.keys) {
    final ApplyUpdateResult<Object?> result =
        _applyUpdate<Object?>(valueMap[key], updateMap[key]);
    if (result.didChange) {
      valueMap[key] = result.newValue;
      didChange = true;
    }
  }
  return ApplyUpdateResult<T>(value as T, didChange);
}

/// @internal
/// 1:1: `abstract class ComputedEditorOption<K extends EditorOption, V>`
/// (K erased — see the header note).
abstract class ComputedEditorOption<V> implements IEditorOption<V> {
  ComputedEditorOption(this.id, this.defaultValue);

  final int id;
  @override
  final String name = '_never_';
  @override
  final V defaultValue;
  @override
  final IConfigurationPropertySchema? schema = null;

  @override
  ApplyUpdateResult<V> applyUpdate(Object? value, Object? update) {
    return _applyUpdate<V>(value, update);
  }

  @override
  V validate(Object? input) {
    return defaultValue;
  }

  @override
  V compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, V value);
}

/// 1:1: `abstract class SimpleEditorOption<K extends EditorOption, V>`
/// (K erased — see the header note).
abstract class SimpleEditorOption<V> implements IEditorOption<V> {
  SimpleEditorOption(this.id, this.name, this.defaultValue,
      [IConfigurationPropertySchema? schema])
      : schema = schema;

  final int id;
  @override
  final String name;
  @override
  final V defaultValue;
  @override
  final IConfigurationPropertySchema? schema;

  @override
  ApplyUpdateResult<V> applyUpdate(Object? value, Object? update) {
    return _applyUpdate<V>(value, update);
  }

  @override
  V validate(Object? input);

  @override
  V compute(
          IEnvironmentalOptions env, IComputedEditorOptions options, V value) =>
      value;
}

//#endregion

//#region validation functions

/// JS `parseInt(value, 10)`: parses the leading decimal prefix of a string.
int? _jsParseInt(String value) {
  final RegExpMatch? match =
      RegExp(r'^\s*([+-]?\d+)').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

/// JS `parseFloat(value)`: parses the leading decimal prefix of a string.
double? _jsParseFloat(String value) {
  final RegExpMatch? match = RegExp(
          r'^\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)')
      .firstMatch(value);
  if (match == null) {
    return null;
  }
  return double.tryParse(match.group(1)!);
}

/// 1:1: `export function boolean(value, defaultValue)`.
/// JS distinguishes `undefined` (→ default) from `null` (→ `Boolean(null) ===
/// false`); the Dart carrier merges both into `null`, so null takes the
/// `undefined` branch (same convention as the rest of this port).
bool boolean(Object? value, bool defaultValue) {
  if (value == null) {
    return defaultValue;
  }
  if (value == 'false') {
    // treat the string 'false' as false
    return false;
  }
  // JS `Boolean(value)`: everything except `undefined`/`null`/`false`/`0`/`NaN`/`''` is truthy.
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0 && !value.isNaN;
  }
  if (value is String) {
    return value.isNotEmpty;
  }
  return true;
}

/// 1:1: `class EditorBooleanOption<K extends EditorOption>`.
class EditorBooleanOption extends SimpleEditorOption<bool> {
  EditorBooleanOption(int id, String name, bool defaultValue,
      [IConfigurationPropertySchema? schema])
      : super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'boolean';
      schema['default'] = defaultValue;
    }
  }

  @override
  bool validate(Object? input) {
    return boolean(input, defaultValue);
  }
}

/// @internal
/// JS `r | 0` — ToInt32 (wraps modulo 2^32, unlike Dart `truncate()`).
int _toInt32(num r) {
  final int v = r.truncate();
  final int unsigned = v & 0xFFFFFFFF;
  return unsigned < 0x80000000 ? unsigned : unsigned - 0x100000000;
}

/// 1:1: `export function clampedInt<T = number>(value, defaultValue, minimum, maximum)`.
Object clampedInt(Object? value, Object defaultValue, num minimum, num maximum) {
  if (value is String) {
    value = _jsParseInt(value);
  }
  if (value is! num || value.isNaN) {
    return defaultValue;
  }
  num r = value;
  r = minimum > r ? minimum : r;
  r = maximum < r ? maximum : r;
  return _toInt32(r);
}

/// 1:1: `class EditorIntOption<K extends EditorOption>`.
class EditorIntOption extends SimpleEditorOption<num> {
  /// TS: `public static clampedInt` — suffixed `Static` (source name in the
  /// comment) because it would shadow the top-level `clampedInt` here.
  static Object clampedIntStatic(
      Object? value, Object defaultValue, num minimum, num maximum) {
    return clampedInt(value, defaultValue, minimum, maximum);
  }

  EditorIntOption(int id, String name, num defaultValue, this.minimum,
      this.maximum,
      [IConfigurationPropertySchema? schema])
      : super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'integer';
      schema['default'] = defaultValue;
      schema['minimum'] = minimum;
      schema['maximum'] = maximum;
    }
  }

  final num minimum;
  final num maximum;

  @override
  num validate(Object? input) {
    return EditorIntOption.clampedIntStatic(
            input, defaultValue, minimum, maximum) as num;
  }
}

/// @internal
/// 1:1: `export function clampedFloat<T extends number>(value, defaultValue, minimum, maximum)`.
num clampedFloat(Object? value, num defaultValue, num minimum, num maximum) {
  if (value == null) {
    return defaultValue;
  }
  final num r = EditorFloatOption.float(value, defaultValue);
  return EditorFloatOption.clamp(r, minimum, maximum);
}

/// 1:1: `class EditorFloatOption<K extends EditorOption>`.
class EditorFloatOption extends SimpleEditorOption<num> {
  EditorFloatOption(int id, String name, num defaultValue,
      num Function(num value) validationFn,
      [IConfigurationPropertySchema? schema, num? minimum, num? maximum])
      : validationFn = validationFn,
        minimum = minimum,
        maximum = maximum,
        super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'number';
      schema['default'] = defaultValue;
      if (minimum != null) {
        schema['minimum'] = minimum;
      }
      if (maximum != null) {
        schema['maximum'] = maximum;
      }
    }
  }

  /// TS: `number | undefined`.
  final num? minimum;
  final num? maximum;

  static num clamp(num n, num min, num max) {
    if (n < min) {
      return min;
    }
    if (n > max) {
      return max;
    }
    return n;
  }

  static num float(Object? value, num defaultValue) {
    if (value is String) {
      value = _jsParseFloat(value);
    }
    if (value is! num || value.isNaN) {
      return defaultValue;
    }
    return value;
  }

  final num Function(num value) validationFn;

  @override
  num validate(Object? input) {
    return validationFn(EditorFloatOption.float(input, defaultValue));
  }
}

/// 1:1: `class EditorStringOption<K extends EditorOption>`.
class EditorStringOption extends SimpleEditorOption<String> {
  EditorStringOption(int id, String name, String defaultValue,
      [IConfigurationPropertySchema? schema])
      : super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'string';
      schema['default'] = defaultValue;
    }
  }

  static String string(Object? value, String defaultValue) {
    if (value is! String) {
      return defaultValue;
    }
    return value;
  }

  @override
  String validate(Object? input) {
    return EditorStringOption.string(input, defaultValue);
  }
}

/// @internal
/// 1:1: `export function stringSet<T extends string>(value, defaultValue, allowedValues, renamedValues?)`.
T stringSet<T extends String>(Object? value, T defaultValue,
    List<T> allowedValues,
    [Map<String, T>? renamedValues]) {
  if (value is! String) {
    return defaultValue;
  }
  if (renamedValues != null && renamedValues.containsKey(value)) {
    return renamedValues[value]!;
  }
  if (!allowedValues.contains(value)) {
    return defaultValue;
  }
  return value as T;
}

/// 1:1: `class EditorStringEnumOption<K extends EditorOption, V extends string>`.
class EditorStringEnumOption<V extends String>
    extends SimpleEditorOption<V> {
  EditorStringEnumOption(int id, String name, V defaultValue,
      List<V> allowedValues,
      [IConfigurationPropertySchema? schema])
      : _allowedValues = allowedValues,
        super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'string';
      schema['enum'] = List<V>.of(allowedValues);
      schema['default'] = defaultValue;
    }
  }

  final List<V> _allowedValues;

  @override
  V validate(Object? input) {
    return stringSet<V>(input, defaultValue, _allowedValues);
  }
}

/// 1:1: `class EditorEnumOption<K extends EditorOption, T extends string, V>`.
class EditorEnumOption<T extends String, V> extends BaseEditorOption<V> {
  EditorEnumOption(int id, String name, V defaultValue, String defaultStringValue,
      List<T> allowedValues, V Function(T value) convert,
      [IConfigurationPropertySchema? schema])
      : _allowedValues = allowedValues,
        _convert = convert,
        super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'string';
      schema['enum'] = allowedValues;
      schema['default'] = defaultStringValue;
    }
  }

  final List<T> _allowedValues;
  final V Function(T value) _convert;

  @override
  V validate(Object? input) {
    if (input is! String) {
      return defaultValue;
    }
    if (!_allowedValues.contains(input)) {
      return defaultValue;
    }
    return _convert(input as T);
  }
}

//#endregion

//#region autoIndent

// ignore: unused_element
int _autoIndentFromString(
    // used by the EditorAutoIndent option class in segment 2
    String autoIndent) {
  switch (autoIndent) {
    case 'none':
      return EditorAutoIndentStrategy.none;
    case 'keep':
      return EditorAutoIndentStrategy.keep;
    case 'brackets':
      return EditorAutoIndentStrategy.brackets;
    case 'advanced':
      return EditorAutoIndentStrategy.advanced;
    case 'full':
      return EditorAutoIndentStrategy.full;
  }
  return EditorAutoIndentStrategy.none;
}

//#endregion

//#region segment 3a: option classes (source lines 1527-2555)

/// JS truthiness helper (`Boolean(value)`): `undefined`/`null`/`false`/`0`/
/// `NaN`/`''` are falsy, everything else truthy. The Dart carrier merges
/// `undefined` and `null` into one `null` (same convention as `boolean`).
bool _truthy(Object? value) {
  if (value == null || value == false) {
    return false;
  }
  if (value is num) {
    return value != 0 && !value.isNaN;
  }
  if (value is String) {
    return value.isNotEmpty;
  }
  return true;
}

/// JS `String(number)` semantics: integer-valued numbers carry no `.0`
/// (third reuse of this helper — see `fontInfo.dart`, `domFontInfo.dart`).
String _jsNum(num value) {
  if (value is int) {
    return value.toString();
  }
  final double asDouble = value.toDouble();
  if (asDouble.isFinite && asDouble == asDouble.truncateToDouble()) {
    return asDouble.toInt().toString();
  }
  return asDouble.toString();
}

/// The option `validate` implementations read the structural user input
/// (`Unknown<T>` in TS — every field `unknown`) through plain property
/// access. User settings arrive as JSON maps and programmatic use passes the
/// typed carrier class, so both carriers are normalized to a field map here
/// (TS structural typing makes the two interchangeable; Dart needs the
/// explicit union read).
Map<String, Object?> _readOptionFields(
    Object? input, Map<String, Object?> Function() fromCarrier) {
  if (input is Map) {
    return input.cast<String, Object?>();
  }
  // Lazy: the typed-carrier conversion must only run for carrier inputs —
  // Dart evaluates call arguments eagerly, unlike the TS `?:` fallback this
  // mirrors (found by the truth replay: eager cast crashed on map inputs).
  return fromCarrier();
}

//#region comments

/// 1:1: `export interface IEditorCommentsOptions`.
class IEditorCommentsOptions {
  IEditorCommentsOptions({this.insertSpace, this.ignoreEmptyLines});

  /// Insert a space after the line comment token and inside the block comments tokens.
  /// Defaults to true.
  bool? insertSpace;

  /// Ignore empty lines when inserting line comments.
  /// Defaults to true.
  bool? ignoreEmptyLines;

  Map<String, Object?> _fields() => <String, Object?>{
        'insertSpace': insertSpace,
        'ignoreEmptyLines': ignoreEmptyLines,
      };
}

/// @internal
/// 1:1: `export type EditorCommentsOptions = Readonly<Required<IEditorCommentsOptions>>`.
class EditorCommentsOptions {
  EditorCommentsOptions({required this.insertSpace, required this.ignoreEmptyLines});

  final bool insertSpace;
  final bool ignoreEmptyLines;
}

/// 1:1: `class EditorComments extends BaseEditorOption<...>`.
class EditorComments extends BaseEditorOption<EditorCommentsOptions> {
  EditorComments()
      : super(
          EditorOption.comments,
          'comments',
          EditorCommentsOptions(insertSpace: true, ignoreEmptyLines: true),
          <String, Object?>{
            'editor.comments.insertSpace': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('comments.insertSpace',
                  'Controls whether a space character is inserted when commenting.'),
            },
            'editor.comments.ignoreEmptyLines': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('comments.ignoreEmptyLines',
                  'Controls if empty lines should be ignored with toggle, add or remove actions for line comments.'),
            },
          },
        );

  @override
  EditorCommentsOptions validate(Object? _input) {
    if (_input == null || (_input is! Map && _input is! IEditorCommentsOptions)) {
      return defaultValue;
    }
    final Map<String, Object?> input =
        _readOptionFields(_input, () => (_input as IEditorCommentsOptions)._fields());
    return EditorCommentsOptions(
      insertSpace: boolean(input['insertSpace'], defaultValue.insertSpace),
      ignoreEmptyLines:
          boolean(input['ignoreEmptyLines'], defaultValue.ignoreEmptyLines),
    );
  }
}

//#endregion

//#region cursorBlinking

/// The kind of animation in which the editor's cursor should be rendered.
/// 1:1: `export const enum TextEditorCursorBlinkingStyle`.
class TextEditorCursorBlinkingStyle {
  /// Hidden
  static const int Hidden = 0;

  /// Blinking
  static const int Blink = 1;

  /// Blinking with smooth fading
  static const int Smooth = 2;

  /// Blinking with prolonged filled state and smooth fading
  static const int Phase = 3;

  /// Expand collapse animation on the y axis
  static const int Expand = 4;

  /// No-Blinking
  static const int Solid = 5;

  const TextEditorCursorBlinkingStyle._();
}

/// @internal
/// 1:1: `export function cursorBlinkingStyleFromString`. TS's exhaustive
/// switch over the string union has no runtime fallthrough; the Dart switch
/// is non-exhaustive over `String`, so the impossible branch throws.
int cursorBlinkingStyleFromString(String cursorBlinkingStyle) {
  switch (cursorBlinkingStyle) {
    case 'blink':
      return TextEditorCursorBlinkingStyle.Blink;
    case 'smooth':
      return TextEditorCursorBlinkingStyle.Smooth;
    case 'phase':
      return TextEditorCursorBlinkingStyle.Phase;
    case 'expand':
      return TextEditorCursorBlinkingStyle.Expand;
    case 'solid':
      return TextEditorCursorBlinkingStyle.Solid;
  }
  throw StateError('Unexpected cursor blinking style: $cursorBlinkingStyle');
}

//#endregion

//#region cursorStyle

/// The style in which the editor's cursor should be rendered.
/// 1:1: `export enum TextEditorCursorStyle`.
class TextEditorCursorStyle {
  /// As a vertical line (sitting between two characters).
  static const int Line = 1;

  /// As a block (sitting on top of a character).
  static const int Block = 2;

  /// As a horizontal line (sitting under a character).
  static const int Underline = 3;

  /// As a thin vertical line (sitting between two characters).
  static const int LineThin = 4;

  /// As an outlined block (sitting on top of a character).
  static const int BlockOutline = 5;

  /// As a thin horizontal line (sitting under a character).
  static const int UnderlineThin = 6;

  const TextEditorCursorStyle._();
}

/// @internal
/// 1:1: `export function cursorStyleToString`.
String cursorStyleToString(int cursorStyle) {
  switch (cursorStyle) {
    case TextEditorCursorStyle.Line:
      return 'line';
    case TextEditorCursorStyle.Block:
      return 'block';
    case TextEditorCursorStyle.Underline:
      return 'underline';
    case TextEditorCursorStyle.LineThin:
      return 'line-thin';
    case TextEditorCursorStyle.BlockOutline:
      return 'block-outline';
    case TextEditorCursorStyle.UnderlineThin:
      return 'underline-thin';
  }
  throw StateError('Unexpected cursor style: $cursorStyle');
}

/// @internal
/// 1:1: `export function cursorStyleFromString`.
int cursorStyleFromString(String cursorStyle) {
  switch (cursorStyle) {
    case 'line':
      return TextEditorCursorStyle.Line;
    case 'block':
      return TextEditorCursorStyle.Block;
    case 'underline':
      return TextEditorCursorStyle.Underline;
    case 'line-thin':
      return TextEditorCursorStyle.LineThin;
    case 'block-outline':
      return TextEditorCursorStyle.BlockOutline;
    case 'underline-thin':
      return TextEditorCursorStyle.UnderlineThin;
  }
  throw StateError('Unexpected cursor style: $cursorStyle');
}

//#endregion

//#region editorClassName

/// 1:1: `class EditorClassName extends ComputedEditorOption<...>`.
class EditorClassName extends ComputedEditorOption<String> {
  EditorClassName() : super(EditorOption.editorClassName, '');

  @override
  String compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, Object? _) {
    final List<String> classNames = <String>['monaco-editor'];
    if (_truthy(options.get(EditorOption.extraEditorClassName))) {
      classNames.add(options.get(EditorOption.extraEditorClassName) as String);
    }
    if (_truthy(env.extraEditorClassName)) {
      classNames.add(env.extraEditorClassName);
    }
    if (options.get(EditorOption.mouseStyle) == 'default') {
      classNames.add('mouse-default');
    } else if (options.get(EditorOption.mouseStyle) == 'copy') {
      classNames.add('mouse-copy');
    }

    if (_truthy(options.get(EditorOption.showUnused))) {
      classNames.add('showUnused');
    }

    if (_truthy(options.get(EditorOption.showDeprecated))) {
      classNames.add('showDeprecated');
    }

    return classNames.join(' ');
  }
}

//#endregion

//#region emptySelectionClipboard

/// 1:1: `class EditorEmptySelectionClipboard extends EditorBooleanOption<...>`.
class EditorEmptySelectionClipboard extends EditorBooleanOption {
  EditorEmptySelectionClipboard()
      : super(
          EditorOption.emptySelectionClipboard,
          'emptySelectionClipboard',
          true,
          <String, Object?>{
            'description': localize('emptySelectionClipboard',
                'Controls whether copying without a selection copies the current line.'),
          },
        );

  @override
  bool compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, bool value) {
    return value && env.emptySelectionClipboard;
  }
}

//#endregion

//#region find

/// Configuration options for editor find widget
/// 1:1: `export interface IEditorFindOptions`.
class IEditorFindOptions {
  IEditorFindOptions({
    this.cursorMoveOnType,
    this.findOnType,
    this.seedSearchStringFromSelection,
    this.autoFindInSelection,
    this.addExtraSpaceOnTop,
    this.globalFindClipboard,
    this.loop,
    this.closeOnResult,
    this.history,
    this.replaceHistory,
  });

  /// Controls whether the cursor should move to find matches while typing.
  bool? cursorMoveOnType;

  /// Controls whether the find widget should search as you type.
  bool? findOnType;

  /// Controls if we seed search string in the Find Widget with editor selection.
  String? seedSearchStringFromSelection;

  /// Controls if Find in Selection flag is turned on in the editor.
  String? autoFindInSelection;

  /// Controls whether the Find Widget should add extra lines on top of the editor.
  bool? addExtraSpaceOnTop;

  /// @internal
  /// Controls if the Find Widget should read or modify the shared find clipboard on macOS
  bool? globalFindClipboard;

  /// Controls whether the search result and diff result automatically restarts from the beginning (or the end) when no further matches can be found
  bool? loop;

  /// Controls whether to close the Find Widget after an explicit find navigation command lands on a match.
  bool? closeOnResult;

  /// @internal
  /// Controls how the find widget search history should be stored
  String? history;

  /// @internal
  /// Controls how the replace widget search history should be stored
  String? replaceHistory;

  Map<String, Object?> _fields() => <String, Object?>{
        'cursorMoveOnType': cursorMoveOnType,
        'findOnType': findOnType,
        'seedSearchStringFromSelection': seedSearchStringFromSelection,
        'autoFindInSelection': autoFindInSelection,
        'addExtraSpaceOnTop': addExtraSpaceOnTop,
        'globalFindClipboard': globalFindClipboard,
        'loop': loop,
        'closeOnResult': closeOnResult,
        'history': history,
        'replaceHistory': replaceHistory,
      };
}

/// @internal
/// 1:1: `export type EditorFindOptions = Readonly<Required<IEditorFindOptions>>`.
class EditorFindOptions {
  EditorFindOptions({
    required this.cursorMoveOnType,
    required this.findOnType,
    required this.seedSearchStringFromSelection,
    required this.autoFindInSelection,
    required this.globalFindClipboard,
    required this.addExtraSpaceOnTop,
    required this.loop,
    required this.closeOnResult,
    required this.history,
    required this.replaceHistory,
  });

  final bool cursorMoveOnType;
  final bool findOnType;
  final String seedSearchStringFromSelection;
  final String autoFindInSelection;
  final bool globalFindClipboard;
  final bool addExtraSpaceOnTop;
  final bool loop;
  final bool closeOnResult;
  final String history;
  final String replaceHistory;
}

/// 1:1: `class EditorFind extends BaseEditorOption<...>`.
class EditorFind extends BaseEditorOption<EditorFindOptions> {
  EditorFind()
      : super(
          EditorOption.find,
          'find',
          EditorFindOptions(
            cursorMoveOnType: true,
            findOnType: true,
            seedSearchStringFromSelection: 'always',
            autoFindInSelection: 'never',
            globalFindClipboard: false,
            addExtraSpaceOnTop: true,
            loop: true,
            closeOnResult: false,
            history: 'workspace',
            replaceHistory: 'workspace',
          ),
          <String, Object?>{
            'editor.find.cursorMoveOnType': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('find.cursorMoveOnType',
                  'Controls whether the cursor should jump to find matches while typing.'),
            },
            'editor.find.seedSearchStringFromSelection': <String, Object?>{
              'type': 'string',
              'enum': <String>['never', 'always', 'selection'],
              'default': 'always',
              'enumDescriptions': <String>[
                localize('editor.find.seedSearchStringFromSelection.never',
                    'Never seed search string from the editor selection.'),
                localize('editor.find.seedSearchStringFromSelection.always',
                    'Always seed search string from the editor selection, including word at cursor position.'),
                localize('editor.find.seedSearchStringFromSelection.selection',
                    'Only seed search string from the editor selection.'),
              ],
              'description': localize('find.seedSearchStringFromSelection',
                  'Controls whether the search string in the Find Widget is seeded from the editor selection.'),
            },
            'editor.find.autoFindInSelection': <String, Object?>{
              'type': 'string',
              'enum': <String>['never', 'always', 'multiline'],
              'default': 'never',
              'enumDescriptions': <String>[
                localize('editor.find.autoFindInSelection.never',
                    'Never turn on Find in Selection automatically (default).'),
                localize('editor.find.autoFindInSelection.always',
                    'Always turn on Find in Selection automatically.'),
                localize('editor.find.autoFindInSelection.multiline',
                    'Turn on Find in Selection automatically when multiple lines of content are selected.'),
              ],
              'description': localize('find.autoFindInSelection',
                  'Controls the condition for turning on Find in Selection automatically.'),
            },
            'editor.find.globalFindClipboard': <String, Object?>{
              'type': 'boolean',
              'default': false,
              'description': localize('find.globalFindClipboard',
                  'Controls whether the Find Widget should read or modify the shared find clipboard on macOS.'),
              'included': platform.isMacintosh,
            },
            'editor.find.addExtraSpaceOnTop': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('find.addExtraSpaceOnTop',
                  'Controls whether the Find Widget should add extra lines on top of the editor. When true, you can scroll beyond the first line when the Find Widget is visible.'),
            },
            'editor.find.loop': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('find.loop',
                  'Controls whether the search automatically restarts from the beginning (or the end) when no further matches can be found.'),
            },
            'editor.find.closeOnResult': <String, Object?>{
              'type': 'boolean',
              'default': false,
              'description': localize('find.closeOnResult',
                  'Controls whether the Find Widget closes after an explicit find navigation command lands on a result.'),
            },
            'editor.find.history': <String, Object?>{
              'type': 'string',
              'enum': <String>['never', 'workspace'],
              'default': 'workspace',
              'enumDescriptions': <String>[
                localize('editor.find.history.never',
                    'Do not store search history from the find widget.'),
                localize('editor.find.history.workspace',
                    'Store search history across the active workspace'),
              ],
              'description': localize('find.history',
                  'Controls how the find widget history should be stored'),
            },
            'editor.find.replaceHistory': <String, Object?>{
              'type': 'string',
              'enum': <String>['never', 'workspace'],
              'default': 'workspace',
              'enumDescriptions': <String>[
                localize('editor.find.replaceHistory.never',
                    'Do not store history from the replace widget.'),
                localize('editor.find.replaceHistory.workspace',
                    'Store replace history across the active workspace'),
              ],
              'description': localize('find.replaceHistory',
                  'Controls how the replace widget history should be stored'),
            },
            'editor.find.findOnType': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('find.findOnType',
                  'Controls whether the Find Widget should search as you type.'),
            },
          },
        );

  /// TS: `typeof input.x === 'boolean' ? (input.x ? 'always' : 'never') :
  /// stringSet(...)`.
  static String _stringOrBool(
      Object? raw, String defaultValue, List<String> allowed) {
    if (raw is bool) {
      return raw ? 'always' : 'never';
    }
    return stringSet<String>(raw, defaultValue, allowed);
  }

  @override
  EditorFindOptions validate(Object? _input) {
    if (_input == null || (_input is! Map && _input is! IEditorFindOptions)) {
      return defaultValue;
    }
    final Map<String, Object?> input =
        _readOptionFields(_input, () => (_input as IEditorFindOptions)._fields());

    return EditorFindOptions(
      cursorMoveOnType:
          boolean(input['cursorMoveOnType'], defaultValue.cursorMoveOnType),
      findOnType: boolean(input['findOnType'], defaultValue.findOnType),
      seedSearchStringFromSelection: _stringOrBool(
          input['seedSearchStringFromSelection'],
          defaultValue.seedSearchStringFromSelection,
          <String>['never', 'always', 'selection']),
      autoFindInSelection: _stringOrBool(
          input['autoFindInSelection'],
          defaultValue.autoFindInSelection,
          <String>['never', 'always', 'multiline']),
      globalFindClipboard:
          boolean(input['globalFindClipboard'], defaultValue.globalFindClipboard),
      addExtraSpaceOnTop:
          boolean(input['addExtraSpaceOnTop'], defaultValue.addExtraSpaceOnTop),
      loop: boolean(input['loop'], defaultValue.loop),
      closeOnResult: boolean(input['closeOnResult'], defaultValue.closeOnResult),
      history: stringSet<String>(
          input['history'], defaultValue.history, <String>['never', 'workspace']),
      replaceHistory: stringSet<String>(input['replaceHistory'],
          defaultValue.replaceHistory, <String>['never', 'workspace']),
    );
  }
}

//#endregion

//#region fontLigatures

/// @internal
/// 1:1: `export class EditorFontLigatures extends BaseEditorOption<...>`.
class EditorFontLigatures extends BaseEditorOption<String> {
  static const String OFF = '"liga" off, "calt" off';
  static const String ON = '"liga" on, "calt" on';

  EditorFontLigatures()
      : super(
          EditorOption.fontLigatures,
          'fontLigatures',
          EditorFontLigatures.OFF,
          <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'boolean',
                'description': localize('fontLigatures',
                    "Enables/Disables font ligatures ('calt' and 'liga' font features). Change this to a string for fine-grained control of the 'font-feature-settings' CSS property."),
              },
              <String, Object?>{
                'type': 'string',
                'description': localize('fontFeatureSettings',
                    "Explicit 'font-feature-settings' CSS property. A boolean can be passed instead if one only needs to turn on/off ligatures."),
              },
            ],
            'description': localize('fontLigaturesGeneral',
                "Configures font ligatures or font features. Can be either a boolean to enable/disable ligatures or a string for the value of the CSS 'font-feature-settings' property."),
            'default': false,
          },
        );

  @override
  String validate(Object? input) {
    if (input == null) {
      return defaultValue;
    }
    if (input is String) {
      if (input == 'false' || input.isEmpty) {
        return EditorFontLigatures.OFF;
      }
      if (input == 'true') {
        return EditorFontLigatures.ON;
      }
      return input;
    }
    if (_truthy(input)) {
      return EditorFontLigatures.ON;
    }
    return EditorFontLigatures.OFF;
  }
}

//#endregion

//#region fontVariations

/// @internal
/// 1:1: `export class EditorFontVariations extends BaseEditorOption<...>`.
class EditorFontVariations extends BaseEditorOption<String> {
  // Text is laid out using default settings.
  static const String OFF = FONT_VARIATION_OFF;

  // Translate `fontWeight` config to the `font-variation-settings` CSS property.
  static const String TRANSLATE = FONT_VARIATION_TRANSLATE;

  EditorFontVariations()
      : super(
          EditorOption.fontVariations,
          'fontVariations',
          EditorFontVariations.OFF,
          <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'boolean',
                'description': localize('fontVariations',
                    "Enables/Disables the translation from font-weight to font-variation-settings. Change this to a string for fine-grained control of the 'font-variation-settings' CSS property."),
              },
              <String, Object?>{
                'type': 'string',
                'description': localize('fontVariationSettings',
                    "Explicit 'font-variation-settings' CSS property. A boolean can be passed instead if one only needs to translate font-weight to font-variation-settings."),
              },
            ],
            'description': localize('fontVariationsGeneral',
                "Configures font variations. Can be either a boolean to enable/disable the translation from font-weight to font-variation-settings or a string for the value of the CSS 'font-variation-settings' property."),
            'default': false,
          },
        );

  @override
  String validate(Object? input) {
    if (input == null) {
      return defaultValue;
    }
    if (input is String) {
      if (input == 'false') {
        return EditorFontVariations.OFF;
      }
      if (input == 'true') {
        return EditorFontVariations.TRANSLATE;
      }
      return input;
    }
    if (_truthy(input)) {
      return EditorFontVariations.TRANSLATE;
    }
    return EditorFontVariations.OFF;
  }

  @override
  String compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, String value) {
    // The value is computed from the fontWeight if it is true.
    // So take the result from env.fontInfo
    return env.fontInfo.fontVariationSettings;
  }
}

//#endregion

//#region fontInfo

/// 1:1: `class EditorFontInfo extends ComputedEditorOption<...>`.
class EditorFontInfo extends ComputedEditorOption<FontInfo> {
  EditorFontInfo()
      : super(
          EditorOption.fontInfo,
          FontInfo(
            FontInfoOptions(
              pixelRatio: 0,
              fontFamily: '',
              fontWeight: '',
              fontSize: 0,
              fontFeatureSettings: '',
              fontVariationSettings: '',
              lineHeight: 0,
              letterSpacing: 0,
              isMonospace: false,
              typicalHalfwidthCharacterWidth: 0,
              typicalFullwidthCharacterWidth: 0,
              canUseHalfwidthRightwardsArrow: false,
              spaceWidth: 0,
              middotWidth: 0,
              wsmiddotWidth: 0,
              maxDigitWidth: 0,
            ),
            false,
          ),
        );

  @override
  FontInfo compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, Object? _) {
    return env.fontInfo;
  }
}

//#endregion

//#region effectiveCursorStyle

/// 1:1: `class EffectiveCursorStyle extends ComputedEditorOption<...>`.
class EffectiveCursorStyle extends ComputedEditorOption<int> {
  EffectiveCursorStyle()
      : super(EditorOption.effectiveCursorStyle, TextEditorCursorStyle.Line);

  @override
  int compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, Object? _) {
    return env.inputMode == 'overtype'
        ? options.get(EditorOption.overtypeCursorStyle) as int
        : options.get(EditorOption.cursorStyle) as int;
  }
}

//#endregion

//#region effectiveExperimentalEditContext

/// 1:1: `class EffectiveEditContextEnabled extends ComputedEditorOption<...>`.
class EffectiveEditContextEnabled extends ComputedEditorOption<bool> {
  EffectiveEditContextEnabled()
      : super(EditorOption.effectiveEditContext, false);

  @override
  bool compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, Object? _) {
    return env.editContextSupported &&
        _truthy(options.get(EditorOption.editContext));
  }
}

//#endregion

//#region effectiveAllowVariableFonts

/// 1:1: `class EffectiveAllowVariableFonts extends ComputedEditorOption<...>`.
class EffectiveAllowVariableFonts extends ComputedEditorOption<bool> {
  EffectiveAllowVariableFonts()
      : super(EditorOption.effectiveAllowVariableFonts, false);

  @override
  bool compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, Object? _) {
    final int accessibilitySupport = env.accessibilitySupport;
    if (accessibilitySupport == AccessibilitySupport.Enabled) {
      return _truthy(
          options.get(EditorOption.allowVariableFontsInAccessibilityMode));
    } else {
      return _truthy(options.get(EditorOption.allowVariableFonts));
    }
  }
}

//#endregion

//#region effectiveFullwidthCharacterWidth

/// 1:1: `class EffectiveFullwidthCharacterWidth extends ComputedEditorOption<...>`.
class EffectiveFullwidthCharacterWidth extends ComputedEditorOption<String> {
  EffectiveFullwidthCharacterWidth()
      : super(EditorOption.effectiveFullwidthCharacterWidth, 'font');

  @override
  String compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, Object? _) {
    if (options.get(EditorOption.fullwidthCharacterWidth) == 'twoCells' &&
        env.fontInfo.isMonospace) {
      return 'twoCells';
    }
    return 'font';
  }
}

//#endregion

//#region fontSize

/// 1:1: `class EditorFontSize extends SimpleEditorOption<...>`.
class EditorFontSize extends SimpleEditorOption<num> {
  EditorFontSize()
      : super(
          EditorOption.fontSize,
          'fontSize',
          EDITOR_FONT_DEFAULTS.fontSize,
          <String, Object?>{
            'type': 'number',
            'minimum': 6,
            'maximum': 100,
            'default': EDITOR_FONT_DEFAULTS.fontSize,
            'description': localize('fontSize', 'Controls the font size in pixels.'),
          },
        );

  @override
  num validate(Object? input) {
    final num r = EditorFloatOption.float(input, defaultValue);
    if (r == 0) {
      return EDITOR_FONT_DEFAULTS.fontSize;
    }
    return EditorFloatOption.clamp(r, 6, 100);
  }

  @override
  num compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, num value) {
    // The final fontSize respects the editor zoom level.
    // So take the result from env.fontInfo
    return env.fontInfo.fontSize;
  }
}

//#endregion

//#region fontWeight

/// 1:1: `class EditorFontWeight extends BaseEditorOption<...>`.
class EditorFontWeight extends BaseEditorOption<String> {
  static const List<String> SUGGESTION_VALUES = <String>[
    'normal',
    'bold',
    '100',
    '200',
    '300',
    '400',
    '500',
    '600',
    '700',
    '800',
    '900',
  ];
  static const int MINIMUM_VALUE = 1;
  static const int MAXIMUM_VALUE = 1000;

  EditorFontWeight()
      : super(
          EditorOption.fontWeight,
          'fontWeight',
          EDITOR_FONT_DEFAULTS.fontWeight,
          <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'number',
                'minimum': MINIMUM_VALUE,
                'maximum': MAXIMUM_VALUE,
                'errorMessage': localize('fontWeightErrorMessage',
                    'Only "normal" and "bold" keywords or numbers between 1 and 1000 are allowed.'),
              },
              <String, Object?>{
                'type': 'string',
                'pattern': r'^(normal|bold|1000|[1-9][0-9]{0,2})$',
              },
              <String, Object?>{
                'enum': SUGGESTION_VALUES,
              },
            ],
            'default': EDITOR_FONT_DEFAULTS.fontWeight,
            'description': localize('fontWeight',
                'Controls the font weight. Accepts "normal" and "bold" keywords or numbers between 1 and 1000.'),
          },
        );

  @override
  String validate(Object? input) {
    if (input == 'normal' || input == 'bold') {
      return input as String;
    }
    final Object r = EditorIntOption.clampedIntStatic(input,
        EDITOR_FONT_DEFAULTS.fontWeight, MINIMUM_VALUE, MAXIMUM_VALUE);
    // JS `String(clampedInt(...))`: the clamped number goes through the JS
    // number stringification; an invalid input returns the string default
    // ('normal') unchanged. A blanket `as num` cast would throw there.
    return r is num ? _jsNum(r) : r.toString();
  }
}

//#endregion

//#region gotoLocation

/// 1:1: `export type GoToLocationValues = 'peek' | 'gotoAndPeek' | 'goto'`.
class GoToLocationValues {
  static const String peek = 'peek';
  static const String gotoAndPeek = 'gotoAndPeek';
  static const String goto = 'goto';

  const GoToLocationValues._();
}

/// Configuration options for go to location
/// 1:1: `export interface IGotoLocationOptions`.
class IGotoLocationOptions {
  IGotoLocationOptions({
    this.multiple,
    this.multipleDefinitions,
    this.multipleTypeDefinitions,
    this.multipleDeclarations,
    this.multipleImplementations,
    this.multipleReferences,
    this.multipleTests,
    this.alternativeDefinitionCommand,
    this.alternativeTypeDefinitionCommand,
    this.alternativeDeclarationCommand,
    this.alternativeImplementationCommand,
    this.alternativeReferenceCommand,
    this.alternativeTestsCommand,
  });

  String? multiple;
  String? multipleDefinitions;
  String? multipleTypeDefinitions;
  String? multipleDeclarations;
  String? multipleImplementations;
  String? multipleReferences;
  String? multipleTests;
  String? alternativeDefinitionCommand;
  String? alternativeTypeDefinitionCommand;
  String? alternativeDeclarationCommand;
  String? alternativeImplementationCommand;
  String? alternativeReferenceCommand;
  String? alternativeTestsCommand;

  Map<String, Object?> _fields() => <String, Object?>{
        'multiple': multiple,
        'multipleDefinitions': multipleDefinitions,
        'multipleTypeDefinitions': multipleTypeDefinitions,
        'multipleDeclarations': multipleDeclarations,
        'multipleImplementations': multipleImplementations,
        'multipleReferences': multipleReferences,
        'multipleTests': multipleTests,
        'alternativeDefinitionCommand': alternativeDefinitionCommand,
        'alternativeTypeDefinitionCommand': alternativeTypeDefinitionCommand,
        'alternativeDeclarationCommand': alternativeDeclarationCommand,
        'alternativeImplementationCommand': alternativeImplementationCommand,
        'alternativeReferenceCommand': alternativeReferenceCommand,
        'alternativeTestsCommand': alternativeTestsCommand,
      };
}

/// @internal
/// 1:1: `export type GoToLocationOptions = Readonly<Required<IGotoLocationOptions>>`.
class GoToLocationOptions {
  GoToLocationOptions({
    required this.multiple,
    required this.multipleDefinitions,
    required this.multipleTypeDefinitions,
    required this.multipleDeclarations,
    required this.multipleImplementations,
    required this.multipleReferences,
    required this.multipleTests,
    required this.alternativeDefinitionCommand,
    required this.alternativeTypeDefinitionCommand,
    required this.alternativeDeclarationCommand,
    required this.alternativeImplementationCommand,
    required this.alternativeReferenceCommand,
    required this.alternativeTestsCommand,
  });

  final String multiple;
  final String multipleDefinitions;
  final String multipleTypeDefinitions;
  final String multipleDeclarations;
  final String multipleImplementations;
  final String multipleReferences;
  final String multipleTests;
  final String alternativeDefinitionCommand;
  final String alternativeTypeDefinitionCommand;
  final String alternativeDeclarationCommand;
  final String alternativeImplementationCommand;
  final String alternativeReferenceCommand;
  final String alternativeTestsCommand;
}

/// 1:1: `class EditorGoToLocation extends BaseEditorOption<...>`.
class EditorGoToLocation extends BaseEditorOption<GoToLocationOptions> {
  EditorGoToLocation()
      : super(
          EditorOption.gotoLocation,
          'gotoLocation',
          GoToLocationOptions(
            multiple: 'peek',
            multipleDefinitions: 'peek',
            multipleTypeDefinitions: 'peek',
            multipleDeclarations: 'peek',
            multipleImplementations: 'peek',
            multipleReferences: 'peek',
            multipleTests: 'peek',
            alternativeDefinitionCommand: 'editor.action.goToReferences',
            alternativeTypeDefinitionCommand: 'editor.action.goToReferences',
            alternativeDeclarationCommand: 'editor.action.goToReferences',
            alternativeImplementationCommand: '',
            alternativeReferenceCommand: '',
            alternativeTestsCommand: '',
          ),
          _buildSchema(),
        );

  static Map<String, Object?> _buildSchema() {
    final Map<String, Object?> jsonSubset = <String, Object?>{
      'type': 'string',
      'enum': <String>['peek', 'gotoAndPeek', 'goto'],
      'default': 'peek',
      'enumDescriptions': <String>[
        localize('editor.gotoLocation.multiple.peek',
            'Show Peek view of the results (default)'),
        localize('editor.gotoLocation.multiple.gotoAndPeek',
            'Go to the primary result and show a Peek view'),
        localize('editor.gotoLocation.multiple.goto',
            'Go to the primary result and enable Peek-less navigation to others'),
      ],
    };
    const List<String> alternativeCommandOptions = <String>[
      '',
      'editor.action.referenceSearch.trigger',
      'editor.action.goToReferences',
      'editor.action.peekImplementation',
      'editor.action.goToImplementation',
      'editor.action.peekTypeDefinition',
      'editor.action.goToTypeDefinition',
      'editor.action.peekDeclaration',
      'editor.action.revealDeclaration',
      'editor.action.peekDefinition',
      'editor.action.revealDefinitionAside',
      'editor.action.revealDefinition',
    ];

    // TS: `{ description, ...jsonSubset }` — the spread keeps `description`
    // from the outer literal; Dart has no spread, so build the merged map.
    Map<String, Object?> subset(String description) => <String, Object?>{
          ...jsonSubset,
          'description': description,
        };

    return <String, Object?>{
      'editor.gotoLocation.multiple': <String, Object?>{
        'deprecationMessage': localize('editor.gotoLocation.multiple.deprecated',
            "This setting is deprecated, please use separate settings like 'editor.editor.gotoLocation.multipleDefinitions' or 'editor.editor.gotoLocation.multipleImplementations' instead."),
      },
      'editor.gotoLocation.multipleDefinitions': subset(localize(
          'editor.editor.gotoLocation.multipleDefinitions',
          "Controls the behavior the 'Go to Definition'-command when multiple target locations exist.")),
      'editor.gotoLocation.multipleTypeDefinitions': subset(localize(
          'editor.editor.gotoLocation.multipleTypeDefinitions',
          "Controls the behavior the 'Go to Type Definition'-command when multiple target locations exist.")),
      'editor.gotoLocation.multipleDeclarations': subset(localize(
          'editor.editor.gotoLocation.multipleDeclarations',
          "Controls the behavior the 'Go to Declaration'-command when multiple target locations exist.")),
      'editor.gotoLocation.multipleImplementations': subset(localize(
          'editor.editor.gotoLocation.multipleImplemenattions',
          "Controls the behavior the 'Go to Implementations'-command when multiple target locations exist.")),
      'editor.gotoLocation.multipleReferences': subset(localize(
          'editor.editor.gotoLocation.multipleReferences',
          "Controls the behavior the 'Go to References'-command when multiple target locations exist.")),
      'editor.gotoLocation.alternativeDefinitionCommand': <String, Object?>{
        'type': 'string',
        'default': 'editor.action.goToReferences',
        'enum': alternativeCommandOptions,
        'description': localize('alternativeDefinitionCommand',
            "Alternative command id that is being executed when the result of 'Go to Definition' is the current location."),
      },
      'editor.gotoLocation.alternativeTypeDefinitionCommand': <String, Object?>{
        'type': 'string',
        'default': 'editor.action.goToReferences',
        'enum': alternativeCommandOptions,
        'description': localize('alternativeTypeDefinitionCommand',
            "Alternative command id that is being executed when the result of 'Go to Type Definition' is the current location."),
      },
      'editor.gotoLocation.alternativeDeclarationCommand': <String, Object?>{
        'type': 'string',
        'default': 'editor.action.goToReferences',
        'enum': alternativeCommandOptions,
        'description': localize('alternativeDeclarationCommand',
            "Alternative command id that is being executed when the result of 'Go to Declaration' is the current location."),
      },
      'editor.gotoLocation.alternativeImplementationCommand': <String, Object?>{
        'type': 'string',
        'default': '',
        'enum': alternativeCommandOptions,
        'description': localize('alternativeImplementationCommand',
            "Alternative command id that is being executed when the result of 'Go to Implementation' is the current location."),
      },
      'editor.gotoLocation.alternativeReferenceCommand': <String, Object?>{
        'type': 'string',
        'default': '',
        'enum': alternativeCommandOptions,
        'description': localize('alternativeReferenceCommand',
            "Alternative command id that is being executed when the result of 'Go to Reference' is the current location."),
      },
    };
  }

  @override
  GoToLocationOptions validate(Object? _input) {
    if (_input == null || (_input is! Map && _input is! IGotoLocationOptions)) {
      return defaultValue;
    }
    final Map<String, Object?> input =
        _readOptionFields(_input, () => (_input as IGotoLocationOptions)._fields());

    return GoToLocationOptions(
      multiple: stringSet<String>(
          input['multiple'], defaultValue.multiple,
          <String>['peek', 'gotoAndPeek', 'goto']),
      multipleDefinitions: stringSet<String>(input['multipleDefinitions'],
          'peek', <String>['peek', 'gotoAndPeek', 'goto']),
      multipleTypeDefinitions: stringSet<String>(
          input['multipleTypeDefinitions'], 'peek',
          <String>['peek', 'gotoAndPeek', 'goto']),
      multipleDeclarations: stringSet<String>(input['multipleDeclarations'],
          'peek', <String>['peek', 'gotoAndPeek', 'goto']),
      multipleImplementations: stringSet<String>(
          input['multipleImplementations'], 'peek',
          <String>['peek', 'gotoAndPeek', 'goto']),
      multipleReferences: stringSet<String>(input['multipleReferences'],
          'peek', <String>['peek', 'gotoAndPeek', 'goto']),
      multipleTests: stringSet<String>(input['multipleTests'], 'peek',
          <String>['peek', 'gotoAndPeek', 'goto']),
      alternativeDefinitionCommand: EditorStringOption.string(
          input['alternativeDefinitionCommand'],
          defaultValue.alternativeDefinitionCommand),
      alternativeTypeDefinitionCommand: EditorStringOption.string(
          input['alternativeTypeDefinitionCommand'],
          defaultValue.alternativeTypeDefinitionCommand),
      alternativeDeclarationCommand: EditorStringOption.string(
          input['alternativeDeclarationCommand'],
          defaultValue.alternativeDeclarationCommand),
      alternativeImplementationCommand: EditorStringOption.string(
          input['alternativeImplementationCommand'],
          defaultValue.alternativeImplementationCommand),
      alternativeReferenceCommand: EditorStringOption.string(
          input['alternativeReferenceCommand'],
          defaultValue.alternativeReferenceCommand),
      alternativeTestsCommand: EditorStringOption.string(
          input['alternativeTestsCommand'], defaultValue.alternativeTestsCommand),
    );
  }
}

//#endregion

//#region hover

/// Configuration options for editor hover
/// 1:1: `export interface IEditorHoverOptions`.
class IEditorHoverOptions {
  IEditorHoverOptions({
    this.enabled,
    this.delay,
    this.sticky,
    this.hidingDelay,
    this.above,
    this.showLongLineWarning,
  });

  /// Enable the hover.
  /// Defaults to 'on'.
  String? enabled;

  /// Delay for showing the hover.
  /// Defaults to 300.
  num? delay;

  /// Is the hover sticky such that it can be clicked and its contents selected?
  /// Defaults to true.
  bool? sticky;

  /// Controls how long the hover is visible after you hovered out of it.
  /// Require sticky setting to be true.
  num? hidingDelay;

  /// Should the hover be shown above the line if possible?
  /// Defaults to false.
  bool? above;

  /// Should long line warning hovers be shown (tokenization skipped, rendering paused)?
  /// Defaults to true.
  bool? showLongLineWarning;

  Map<String, Object?> _fields() => <String, Object?>{
        'enabled': enabled,
        'delay': delay,
        'sticky': sticky,
        'hidingDelay': hidingDelay,
        'above': above,
        'showLongLineWarning': showLongLineWarning,
      };
}

/// @internal
/// 1:1: `export type EditorHoverOptions = Readonly<Required<IEditorHoverOptions>>`.
class EditorHoverOptions {
  EditorHoverOptions({
    required this.enabled,
    required this.delay,
    required this.sticky,
    required this.hidingDelay,
    required this.above,
    required this.showLongLineWarning,
  });

  final String enabled;
  final num delay;
  final bool sticky;
  final num hidingDelay;
  final bool above;
  final bool showLongLineWarning;
}

/// 1:1: `class EditorHover extends BaseEditorOption<...>`.
class EditorHover extends BaseEditorOption<EditorHoverOptions> {
  EditorHover()
      : super(
          EditorOption.hover,
          'hover',
          EditorHoverOptions(
            enabled: 'on',
            delay: 300,
            hidingDelay: 300,
            sticky: true,
            above: true,
            showLongLineWarning: true,
          ),
          <String, Object?>{
            'editor.hover.enabled': <String, Object?>{
              'type': 'string',
              'enum': <String>['on', 'off', 'onKeyboardModifier'],
              'default': 'on',
              'markdownEnumDescriptions': <String>[
                localize('hover.enabled.on', 'Hover is enabled.'),
                localize('hover.enabled.off', 'Hover is disabled.'),
                localize('hover.enabled.onKeyboardModifier',
                    'Hover is shown when holding `{0}` or `Alt` (the opposite modifier of `#editor.multiCursorModifier#`)',
                    <Object?>[platform.isMacintosh ? 'Command' : 'Control']),
              ],
              'description':
                  localize('hover.enabled', 'Controls whether the hover is shown.'),
              'keywords': <String>['hint', 'info', 'tooltip'],
            },
            'editor.hover.delay': <String, Object?>{
              'type': 'number',
              'default': 300,
              'minimum': 0,
              'maximum': 10000,
              'description': localize('hover.delay',
                  'Controls the delay in milliseconds after which the hover is shown.'),
            },
            'editor.hover.sticky': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('hover.sticky',
                  'Controls whether the hover should remain visible when mouse is moved over it.'),
            },
            'editor.hover.hidingDelay': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'default': 300,
              'markdownDescription': localize('hover.hidingDelay',
                  'Controls the delay in milliseconds after which the hover is hidden. Requires `#editor.hover.sticky#` to be enabled.'),
            },
            'editor.hover.above': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('hover.above',
                  "Prefer showing hovers above the line, if there's space."),
            },
            'editor.hover.showLongLineWarning': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('hover.showLongLineWarning',
                  'Controls whether long line warning hovers are shown, such as when tokenization is skipped or rendering is paused.'),
            },
          },
        );

  @override
  EditorHoverOptions validate(Object? _input) {
    if (_input == null || (_input is! Map && _input is! IEditorHoverOptions)) {
      return defaultValue;
    }
    final Map<String, Object?> input =
        _readOptionFields(_input, () => (_input as IEditorHoverOptions)._fields());

    return EditorHoverOptions(
      enabled: stringSet<String>(input['enabled'], defaultValue.enabled,
          <String>['on', 'off', 'onKeyboardModifier']),
      delay: EditorIntOption.clampedIntStatic(
              input['delay'], defaultValue.delay, 0, 10000) as num,
      sticky: boolean(input['sticky'], defaultValue.sticky),
      hidingDelay: EditorIntOption.clampedIntStatic(
              input['hidingDelay'], defaultValue.hidingDelay, 0, 600000) as num,
      above: boolean(input['above'], defaultValue.above),
      showLongLineWarning:
          boolean(input['showLongLineWarning'], defaultValue.showLongLineWarning),
    );
  }
}

//#endregion

//#region markdownImages

/// Configuration options for images in Markdown rendered by the editor
/// 1:1: `export interface IEditorMarkdownImagesOptions`.
class IEditorMarkdownImagesOptions {
  IEditorMarkdownImagesOptions({this.allowedOrigins});

  /// Origins from which remote images may be loaded, for example `['https://img.shields.io']`,
  /// or `true` to allow images from all origins. An origin consists of scheme, host and port.
  /// `data:` images are always allowed.
  /// Defaults to `true`, except in the standalone editor, where it defaults to `[]`.
  // TS: true | string[]
  Object? allowedOrigins;
}

/// The `allowedOrigins` are `true` or normalized origins (see [getUrlOrigin]).
/// @internal
/// 1:1: `export type EditorMarkdownImagesOptions = Readonly<Required<IEditorMarkdownImagesOptions>>`.
class EditorMarkdownImagesOptions {
  EditorMarkdownImagesOptions({required this.allowedOrigins});

  // TS: true | string[] (Required<> makes it non-optional)
  Object? allowedOrigins;
}

/// Returns the origin of an absolute URL, or `undefined` if it has none (for
/// example `data:` URLs).
/// @internal
/// 1:1: `export function getUrlOrigin`. JS `new URL(...)` throws for
/// unparseable URLs and yields the literal `'null'` origin for opaque URLs;
/// Dart's `Uri.parse` is lenient and `Uri.origin` throws `StateError` in the
/// same cases — both funnel to the `null` return.
String? getUrlOrigin(String url) {
  try {
    final String origin = Uri.parse(url).origin;
    return origin == 'null' ? null : origin;
  } catch (_) {
    return null;
  }
}

/// @internal
/// 1:1: `export function isMarkdownImageAllowed`.
bool isMarkdownImageAllowed(EditorMarkdownImagesOptions options, String url) {
  if (options.allowedOrigins == true) {
    return true;
  }
  final String? origin = getUrlOrigin(url);
  final Object? allowed = options.allowedOrigins;
  return origin != null && allowed is List && allowed.contains(origin);
}

/// 1:1: `class EditorMarkdownImages extends BaseEditorOption<...>`.
class EditorMarkdownImages extends BaseEditorOption<EditorMarkdownImagesOptions> {
  EditorMarkdownImages()
      : super(EditorOption.markdownImages, 'markdownImages',
          EditorMarkdownImagesOptions(allowedOrigins: true));

  @override
  EditorMarkdownImagesOptions validate(Object? _input) {
    if (_input == null ||
        (_input is! Map && _input is! IEditorMarkdownImagesOptions)) {
      return defaultValue;
    }
    final Object? rawAllowedOrigins = _input is Map
        ? _input['allowedOrigins'] // promoted to Map by the condition
        : (_input as IEditorMarkdownImagesOptions).allowedOrigins;
    if (rawAllowedOrigins == true) {
      return EditorMarkdownImagesOptions(allowedOrigins: true);
    }
    if (rawAllowedOrigins is! List) {
      return defaultValue;
    }
    final List<String> allowedOrigins = <String>[];
    for (final Object? value in rawAllowedOrigins) {
      final String? origin = value is String ? getUrlOrigin(value) : null;
      if (origin != null && !allowedOrigins.contains(origin)) {
        allowedOrigins.add(origin);
      }
    }
    return EditorMarkdownImagesOptions(allowedOrigins: allowedOrigins);
  }
}

//#endregion

//#endregion (segment 3a ends; layoutInfo region follows in segment 3b)

//#region EditorOption enum

/// 1:1: `export const enum EditorOption` (auto-increment values, generated
/// from the source table).
class EditorOption {
  static const int acceptSuggestionOnCommitCharacter = 0;
  static const int acceptSuggestionOnEnter = 1;
  static const int accessibilitySupport = 2;
  static const int accessibilityPageSize = 3;
  static const int allowOverflow = 4;
  static const int allowVariableLineHeights = 5;
  static const int allowVariableFonts = 6;
  static const int allowVariableFontsInAccessibilityMode = 7;
  static const int ariaLabel = 8;
  static const int ariaRequired = 9;
  static const int autoClosingBrackets = 10;
  static const int autoClosingComments = 11;
  static const int screenReaderAnnounceInlineSuggestion = 12;
  static const int autoClosingDelete = 13;
  static const int autoClosingOvertype = 14;
  static const int autoClosingQuotes = 15;
  static const int autoIndent = 16;
  static const int autoIndentOnPaste = 17;
  static const int autoIndentOnPasteWithinString = 18;
  static const int automaticLayout = 19;
  static const int autoSurround = 20;
  static const int bracketPairColorization = 21;
  static const int guides = 22;
  static const int codeLens = 23;
  static const int codeLensFontFamily = 24;
  static const int codeLensFontSize = 25;
  static const int colorDecorators = 26;
  static const int colorDecoratorsLimit = 27;
  static const int columnSelection = 28;
  static const int comments = 29;
  static const int contextmenu = 30;
  static const int copyWithSyntaxHighlighting = 31;
  static const int cursorBlinking = 32;
  static const int cursorSmoothCaretAnimation = 33;
  static const int cursorStyle = 34;
  static const int cursorSurroundingLines = 35;
  static const int cursorSurroundingLinesStyle = 36;
  static const int cursorWidth = 37;
  static const int cursorHeight = 38;
  static const int disableLayerHinting = 39;
  static const int disableMonospaceOptimizations = 40;
  static const int domReadOnly = 41;
  static const int dragAndDrop = 42;
  static const int dropIntoEditor = 43;
  static const int editContext = 44;
  static const int emptySelectionClipboard = 45;
  static const int experimentalGpuAcceleration = 46;
  static const int experimentalWhitespaceRendering = 47;
  static const int extraEditorClassName = 48;
  static const int fastScrollSensitivity = 49;
  static const int find = 50;
  static const int fixedOverflowWidgets = 51;
  static const int folding = 52;
  static const int foldingStrategy = 53;
  static const int foldingHighlight = 54;
  static const int foldingImportsByDefault = 55;
  static const int foldingMaximumRegions = 56;
  static const int unfoldOnClickAfterEndOfLine = 57;
  static const int fontFamily = 58;
  static const int fontInfo = 59;
  static const int fontLigatures = 60;
  static const int fontSize = 61;
  static const int fontWeight = 62;
  static const int fontVariations = 63;
  static const int formatOnPaste = 64;
  static const int formatOnType = 65;
  static const int glyphMargin = 66;
  static const int gotoLocation = 67;
  static const int hideCursorInOverviewRuler = 68;
  static const int hover = 69;
  static const int inDiffEditor = 70;
  static const int inlineSuggest = 71;
  static const int letterSpacing = 72;
  static const int lightbulb = 73;
  static const int lineDecorationsWidth = 74;
  static const int lineHeight = 75;
  static const int lineNumbers = 76;
  static const int lineNumbersMinChars = 77;
  static const int linkedEditing = 78;
  static const int links = 79;
  static const int markdownImages = 80;
  static const int matchBrackets = 81;
  static const int minimap = 82;
  static const int mouseStyle = 83;
  static const int mouseWheelScrollSensitivity = 84;
  static const int mouseWheelZoom = 85;
  static const int multiCursorMergeOverlapping = 86;
  static const int multiCursorModifier = 87;
  static const int mouseMiddleClickAction = 88;
  static const int multiCursorPaste = 89;
  static const int multiCursorLimit = 90;
  static const int occurrencesHighlight = 91;
  static const int occurrencesHighlightDelay = 92;
  static const int occurrencesHighlightFromAllProviders = 93;
  static const int overtypeCursorStyle = 94;
  static const int overtypeOnPaste = 95;
  static const int overviewRulerBorder = 96;
  static const int overviewRulerLanes = 97;
  static const int padding = 98;
  static const int pasteAs = 99;
  static const int parameterHints = 100;
  static const int peekWidgetDefaultFocus = 101;
  static const int placeholder = 102;
  static const int definitionLinkOpensInPeek = 103;
  static const int quickSuggestions = 104;
  static const int quickSuggestionsDelay = 105;
  static const int readOnly = 106;
  static const int readOnlyMessage = 107;
  static const int renameOnType = 108;
  static const int renderRichScreenReaderContent = 109;
  static const int renderControlCharacters = 110;
  static const int renderFinalNewline = 111;
  static const int renderLineHighlight = 112;
  static const int renderLineHighlightOnlyWhenFocus = 113;
  static const int renderValidationDecorations = 114;
  static const int renderWhitespace = 115;
  static const int revealHorizontalRightPadding = 116;
  static const int roundedSelection = 117;
  static const int rulers = 118;
  static const int scrollbar = 119;
  static const int scrollBeyondLastColumn = 120;
  static const int scrollBeyondLastLine = 121;
  static const int scrollPredominantAxis = 122;
  static const int selectionClipboard = 123;
  static const int selectionHighlight = 124;
  static const int selectionHighlightMaxLength = 125;
  static const int selectionHighlightMultiline = 126;
  static const int selectedTextMatchMode = 127;
  static const int selectOnLineNumbers = 128;
  static const int showFoldingControls = 129;
  static const int showUnused = 130;
  static const int snippetSuggestions = 131;
  static const int smartSelect = 132;
  static const int smoothScrolling = 133;
  static const int stickyScroll = 134;
  static const int stickyTabStops = 135;
  static const int stopRenderingLineAfter = 136;
  static const int suggest = 137;
  static const int suggestFontSize = 138;
  static const int suggestLineHeight = 139;
  static const int suggestOnTriggerCharacters = 140;
  static const int suggestSelection = 141;
  static const int tabCompletion = 142;
  static const int tabIndex = 143;
  static const int trimWhitespaceOnDelete = 144;
  static const int unicodeHighlighting = 145;
  static const int unusualLineTerminators = 146;
  static const int useShadowDOM = 147;
  static const int useTabStops = 148;
  static const int wordBreak = 149;
  static const int wordSegmenterLocales = 150;
  static const int wordSeparators = 151;
  static const int wordWrap = 152;
  static const int wordWrapBreakAfterCharacters = 153;
  static const int wordWrapBreakBeforeCharacters = 154;
  static const int wordWrapColumn = 155;
  static const int wordWrapOverride1 = 156;
  static const int wordWrapOverride2 = 157;
  static const int wrappingIndent = 158;
  static const int wrappingStrategy = 159;
  static const int showDeprecated = 160;
  static const int inertialScroll = 161;
  static const int inlayHints = 162;
  static const int wrapOnEscapedLineFeeds = 163;
  static const int wordWrapIndicator = 164;
  static const int effectiveCursorStyle = 165;
  static const int editorClassName = 166;
  static const int pixelRatio = 167;
  static const int tabFocusMode = 168;
  static const int layoutInfo = 169;
  static const int wrappingInfo = 170;
  static const int defaultColorDecorators = 171;
  static const int colorDecoratorsActivatedOn = 172;
  static const int inlineCompletionsAccessibilityVerbose = 173;
  static const int effectiveEditContext = 174;
  static const int scrollOnMiddleClick = 175;
  static const int effectiveAllowVariableFonts = 176;
  static const int doubleClickSelectsBlock = 177;
  static const int fullwidthCharacterWidth = 178;
  static const int effectiveFullwidthCharacterWidth = 179;

  const EditorOption._();
}

//#endregion

//#region registry

/// 1:1: `export const editorOptionsRegistry: IEditorOption<EditorOption, unknown>[]`.
final List<IEditorOption<Object?>> editorOptionsRegistry =
    <IEditorOption<Object?>>[];

/// 1:1: `function register<K extends EditorOption, V>(option)`.
IEditorOption<V> register<V>(IEditorOption<V> option) {
  editorOptionsRegistry.add(option as IEditorOption<Object?>);
  return option;
}

//#endregion

//#region accessibilitySupport

/// 1:1: `class EditorAccessibilitySupport extends
/// BaseEditorOption<EditorOption.accessibilitySupport, 'auto' | 'off' | 'on',
/// AccessibilitySupport>` (K erased — see the header note).
class EditorAccessibilitySupport extends BaseEditorOption<int> {
  EditorAccessibilitySupport()
      : super(
          EditorOption.accessibilitySupport,
          'accessibilitySupport',
          AccessibilitySupport.Unknown,
          <String, Object?>{
            'type': 'string',
            'enum': <String>['auto', 'on', 'off'],
            'enumDescriptions': <String>[
              localize('accessibilitySupport.auto',
                  'Use platform APIs to detect when a Screen Reader is attached.'),
              localize('accessibilitySupport.on',
                  'Optimize for usage with a Screen Reader.'),
              localize('accessibilitySupport.off',
                  'Assume a screen reader is not attached.'),
            ],
            'default': 'auto',
            'tags': <String>['accessibility'],
            'description': localize('accessibilitySupport',
                'Controls if the UI should run in a mode where it is optimized for screen readers.'),
          },
        );

  @override
  int validate(Object? input) {
    switch (input) {
      case 'auto':
        return AccessibilitySupport.Unknown;
      case 'off':
        return AccessibilitySupport.Disabled;
      case 'on':
        return AccessibilitySupport.Enabled;
    }
    return defaultValue;
  }

  @override
  int compute(IEnvironmentalOptions env, IComputedEditorOptions options,
      int value) {
    if (value == AccessibilitySupport.Unknown) {
      // The editor reads the `accessibilitySupport` from the environment
      return env.accessibilitySupport;
    }
    return value;
  }
}

//#endregion
