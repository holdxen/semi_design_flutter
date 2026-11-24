// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/config/editorOptions.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// SEGMENTED PORT (FILE COMPLETE — all four segments translated):
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
//   segment 3b/4 (complete): chunk 1 (batch218: wrappingStrategy,
//     lightbulb, stickyScroll), chunk 2 (batch219: inlayHints,
//     lineDecorationsWidth, lineHeight), chunk 3 (batch220: minimap;
//     IEditorMinimapOptions/EditorMinimapOptions + EditorMinimap) and chunk 4
//     (batch221: multiCursorModifier helper, padding, parameterHints,
//     pixelRatio, placeholder), chunk 5 (batch222: quickSuggestions,
//     renderLineNumbers, renderValidationDecorations, filterFontDecorations)
//     and chunk 6 (batch223: rulers/IRulerOption/EditorRulers, readonly/
//     ReadonlyMessage) and chunk 7 (batch224: scrollbar/IEditorScrollbarOptions,
//     InternalEditorScrollbarOptions, _scrollbarVisibilityFromString,
//     EditorScrollbar), chunk 8 (batch225: InUntrustedWorkspace,
//     IUnicodeHighlightOptions/InternalUnicodeHighlightOptions,
//     unicodeHighlightConfigKeys, primitiveSet helper, UnicodeHighlight) and
//     chunk 9 (batch226: IInlineSuggestOptions/InternalInlineSuggestOptions +
//     nested edits/experimental carriers, InlineEditorSuggest — defaults,
//     schema, validate/_validateEdits/_validateExperimental) and chunk 10
//     (batch227: bracketPairColorization + guides —
//     IBracketPairColorizationOptions/InternalBracketPairColorizationOptions/
//     BracketPairColorization and IGuidesOptions/InternalGuidesOptions/
//     GuideOptions — defaults, full schemas, validate, plus the shared
//     primitiveSet helper), chunk 11 (batch228: suggest —
//     ISuggestOptions/InternalSuggestOptions + EditorSuggest — defaults,
//     full schema, validate, including the source's
//     `snippetsPreventQuickSuggestions` → `filterGraceful` default quirk and
//     the JS-array-is-an-object branch; plus the shared `stringSet` and
//     `boolean` helper truth tables), chunk 12 (batch229: smartSelect —
//     ISmartSelectOptions/SmartSelectOptions + SmartSelect — defaults, full
//     schema, validate; tabFocusMode — EditorTabFocusMode with its `compute`
//     override returning `env.tabFocusMode`; wordSegmenterLocales —
//     WordSegmenterLocales — defaults, full schema, validate with the
//     `Intl.Segmenter.supportedLocalesOf` carrier), chunk 13 (batch230:
//     wrappingIndent — WrappingIndent enum +
//     WrappingIndentOption defaults, full schema, validate switch,
//     accessibility-aware compute; wrappingInfo — EditorWrappingInfo +
//     EditorWrappingInfoComputer computed option with its layoutInfo
//     dependency; dropIntoEditor — IDropIntoEditorOptions/
//     EditorDropIntoEditorOptions + EditorDropIntoEditor defaults, full schema,
//     validate; pasteAs — IPasteAsOptions/EditorPasteAsOptions + EditorPasteAs
//     defaults, full schema, validate) done — source lines 2556–5947;
//     segment 3b COMPLETE.
//   segment 3/4 (done): lines 2556–5947 (all option classes in segment 3b).
//   segment 4/4 (complete): batch231 — EditorOptions slice 1, source lines
//     6144–6499 (the `EditorOptions` object literal from
//     `acceptSuggestionOnCommitCharacter` through `folding`, 59 entries) DONE;
//     batch232 — EditorOptions slice 2, source lines 6500–6801
//     (`foldingStrategy` through `roundedSelection`, 64 entries) DONE;
//     batch233 — EditorOptions slice 3 (final), source lines 6802–7102
//     (`rulers` through `effectiveFullwidthCharacterWidth`, 57 entries, plus
//     the erased trailing type-level helpers) DONE. 180/180 registry slots
//     now filled; segment 4 COMPLETE and the whole file COMPLETE.
//   batch231 also fixes the registry to mirror the source's
//     `editorOptionsRegistry[option.id] = option` sparse indexed write:
//     `editorOptionsRegistry` is now a nullable growable list with `register`
//     writing at `option.id` (growing with `null` holes as needed).
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

import 'dart:math' as math;

import '../../../base/common/arrays.dart' as arrays;
import '../../../nls.dart' show localize;
import '../../../platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;
import '../../../platform/configuration/common/configurationRegistry.dart'
    show IConfigurationPropertySchema;
import '../../../base/common/objects.dart' as objects;
import '../../../base/common/platform.dart' as platform;
import '../../../base/common/scrollable.dart' show ScrollbarVisibility;
import '../../../base/common/uint.dart' show Constants;
import '../core/wordHelper.dart' show USUAL_WORD_SEPARATORS;
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

  /// 1:1 source member names (`EditorAutoIndentStrategy.Full` etc.), used by
  /// the `EditorOptions.autoIndent` construction; the lower-cased aliases
  /// above are kept for the existing segment-1 call sites.
  static const int None = 0;
  static const int Keep = 1;
  static const int Brackets = 2;
  static const int Advanced = 3;
  static const int Full = 4;

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
  EditorMinimapLayoutInput? stableMinimapLayoutInput;
  num stableFitMaxMinimapScale = 0;
  num stableFitRemainingWidth = 0;

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

class OverviewRulerPosition {
  final num width, height, top, right;
  const OverviewRulerPosition({required this.width, required this.height, required this.top, required this.right});
}

class RenderMinimap {
  static const int none = 0;
  static const int text = 1;
  static const int blocks = 2;
  const RenderMinimap._();
}

class EditorMinimapLayoutInfo {
  final int renderMinimap;
  final num minimapLeft, minimapWidth;
  final bool minimapHeightIsEditorHeight, minimapIsSampling;
  final num minimapScale, minimapLineHeight;
  final num minimapCanvasInnerWidth, minimapCanvasInnerHeight;
  final num minimapCanvasOuterWidth, minimapCanvasOuterHeight;
  const EditorMinimapLayoutInfo({required this.renderMinimap, required this.minimapLeft, required this.minimapWidth, required this.minimapHeightIsEditorHeight, required this.minimapIsSampling, required this.minimapScale, required this.minimapLineHeight, required this.minimapCanvasInnerWidth, required this.minimapCanvasInnerHeight, required this.minimapCanvasOuterWidth, required this.minimapCanvasOuterHeight});
}

class EditorLayoutInfo {
  final num width, height, glyphMarginLeft, glyphMarginWidth, glyphMarginDecorationLaneCount;
  final num lineNumbersLeft, lineNumbersWidth, decorationsLeft, decorationsWidth;
  final num contentLeft, contentWidth, viewportColumn;
  final bool isWordWrapMinified, isViewportWrapping;
  final num wrappingColumn, verticalScrollbarWidth, horizontalScrollbarHeight;
  final EditorMinimapLayoutInfo minimap;
  final OverviewRulerPosition overviewRuler;
  const EditorLayoutInfo({required this.width, required this.height, required this.glyphMarginLeft, required this.glyphMarginWidth, required this.glyphMarginDecorationLaneCount, required this.lineNumbersLeft, required this.lineNumbersWidth, required this.decorationsLeft, required this.decorationsWidth, required this.contentLeft, required this.contentWidth, required this.minimap, required this.viewportColumn, required this.isWordWrapMinified, required this.isViewportWrapping, required this.wrappingColumn, required this.verticalScrollbarWidth, required this.horizontalScrollbarHeight, required this.overviewRuler});
}

class EditorMinimapLayoutInput {
  final num outerWidth, outerHeight, lineHeight, typicalHalfwidthCharacterWidth, pixelRatio;
  final bool scrollBeyondLastLine;
  final num paddingTop, paddingBottom;
  final EditorMinimapOptions minimap;
  final num verticalScrollbarWidth, viewLineCount, remainingWidth;
  final bool isViewportWrapping;
  const EditorMinimapLayoutInput({required this.outerWidth, required this.outerHeight, required this.lineHeight, required this.typicalHalfwidthCharacterWidth, required this.pixelRatio, required this.scrollBeyondLastLine, required this.paddingTop, required this.paddingBottom, required this.minimap, required this.verticalScrollbarWidth, required this.viewLineCount, required this.remainingWidth, required this.isViewportWrapping});
}

/// 1:1: `IEditorMinimapOptions` plus its `Readonly<Required<...>>` alias
/// `EditorMinimapOptions`. The six fields added after the batch210 carrier
/// default to the source `defaults` values so existing layout callers (which
/// supply only the original seven) remain source-faithful.
class EditorMinimapOptions {
  final bool enabled;
  final String autohide;
  final String side;
  final String size;
  final String showSlider;
  final bool renderCharacters;
  final num maxColumn;
  final num scale;
  final bool showRegionSectionHeaders;
  final bool showMarkSectionHeaders;
  final String markSectionHeaderRegex;
  final num sectionHeaderFontSize;
  final num sectionHeaderLetterSpacing;

  const EditorMinimapOptions({
    required this.enabled,
    this.autohide = 'none',
    required this.side,
    required this.size,
    required this.showSlider,
    required this.renderCharacters,
    required this.maxColumn,
    required this.scale,
    this.showRegionSectionHeaders = true,
    this.showMarkSectionHeaders = true,
    this.markSectionHeaderRegex = r'\bMARK:\s*(?<separator>-?)\s*(?<label>.*)$',
    this.sectionHeaderFontSize = 9,
    this.sectionHeaderLetterSpacing = 1,
  });
}

/// 1:1: `IEditorScrollbarOptions` (source input interface) plus its computed
/// `InternalEditorScrollbarOptions` shape. The ten fields absent from the
/// original batch210 layout carrier default to the source `defaults` values so
/// those callers stay source-faithful; `EditorScrollbar.validate` always
/// resolves the exact shape (including slider fallback to scrollbar size).
class InternalEditorScrollbarOptions {
  final num arrowSize;
  final int vertical; // ScrollbarVisibility
  final int horizontal; // ScrollbarVisibility
  final bool useShadows;
  final bool verticalHasArrows;
  final bool horizontalHasArrows;
  final bool handleMouseWheel;
  final bool alwaysConsumeMouseWheel;
  final num horizontalScrollbarSize;
  final num horizontalSliderSize;
  final num verticalScrollbarSize;
  final num verticalSliderSize;
  final bool scrollByPage;
  final bool ignoreHorizontalScrollbarInContentHeight;

  const InternalEditorScrollbarOptions({
    required this.arrowSize,
    this.vertical = ScrollbarVisibility.Auto,
    this.horizontal = ScrollbarVisibility.Auto,
    this.useShadows = true,
    required this.verticalHasArrows,
    this.horizontalHasArrows = false,
    this.handleMouseWheel = true,
    this.alwaysConsumeMouseWheel = true,
    required this.horizontalScrollbarSize,
    this.horizontalSliderSize = 12,
    required this.verticalScrollbarSize,
    this.verticalSliderSize = 14,
    this.scrollByPage = false,
    this.ignoreHorizontalScrollbarInContentHeight = false,
  });
}

/// 1:1: `export interface InternalEditorRenderLineNumbersOptions`.
/// The source's optional `renderFn` is the custom line-number callback; the
/// positional `renderType` constructor argument is retained so the earlier
/// layoutInfo callers keep working unchanged.
class InternalEditorRenderLineNumbersOptions {
  final int renderType;
  final String Function(int lineNumber)? renderFn;
  const InternalEditorRenderLineNumbersOptions(this.renderType, [this.renderFn]);
}

/// 1:1: `IEditorPaddingOptions` + `InternalEditorPaddingOptions`
/// (`Readonly<Required<IEditorPaddingOptions>>`). The batch210 layout carrier
/// is evolved in place with the source defaults: existing layout callers (which
/// pass both fields explicitly) keep working, while it doubles as the validated
/// internal type for batch221's `EditorPadding`.
class EditorPaddingOptions {
  final num top, bottom;
  const EditorPaddingOptions({this.top = 0, this.bottom = 0});
}

/// 1:1: `export type InternalEditorPaddingOptions = Readonly<Required<IEditorPaddingOptions>>`.
typedef InternalEditorPaddingOptions = EditorPaddingOptions;

/// 1:1: `export class EditorLayoutInfoComputer extends
/// ComputedEditorOption<EditorOption.layoutInfo, EditorLayoutInfo>`.
/// The option half (constructor default + `compute`) was added in batch233;
/// the pre-existing static layout helpers are kept unchanged.
class EditorLayoutInfoComputer extends ComputedEditorOption<EditorLayoutInfo> {
  EditorLayoutInfoComputer()
      : super(
          EditorOption.layoutInfo,
          const EditorLayoutInfo(
            width: 0,
            height: 0,
            glyphMarginLeft: 0,
            glyphMarginWidth: 0,
            glyphMarginDecorationLaneCount: 0,
            lineNumbersLeft: 0,
            lineNumbersWidth: 0,
            decorationsLeft: 0,
            decorationsWidth: 0,
            contentLeft: 0,
            contentWidth: 0,
            minimap: EditorMinimapLayoutInfo(
              renderMinimap: RenderMinimap.none,
              minimapLeft: 0,
              minimapWidth: 0,
              minimapHeightIsEditorHeight: false,
              minimapIsSampling: false,
              minimapScale: 1,
              minimapLineHeight: 1,
              minimapCanvasInnerWidth: 0,
              minimapCanvasInnerHeight: 0,
              minimapCanvasOuterWidth: 0,
              minimapCanvasOuterHeight: 0,
            ),
            viewportColumn: 0,
            isWordWrapMinified: false,
            isViewportWrapping: false,
            wrappingColumn: -1,
            verticalScrollbarWidth: 0,
            horizontalScrollbarHeight: 0,
            overviewRuler: OverviewRulerPosition(
              top: 0,
              width: 0,
              height: 0,
              right: 0,
            ),
          ),
        );

  @override
  EditorLayoutInfo compute(IEnvironmentalOptions env,
      IComputedEditorOptions options, EditorLayoutInfo _) {
    return computeLayout(
      options,
      memory: env.memory,
      outerWidth: env.outerWidth,
      outerHeight: env.outerHeight,
      isDominatedByLongLines: env.isDominatedByLongLines,
      lineHeight: env.fontInfo.lineHeight,
      viewLineCount: env.viewLineCount,
      lineNumbersDigitCount: env.lineNumbersDigitCount,
      typicalHalfwidthCharacterWidth: env.fontInfo.typicalHalfwidthCharacterWidth,
      maxDigitWidth: env.fontInfo.maxDigitWidth,
      pixelRatio: env.pixelRatio,
      glyphMarginDecorationLaneCount: env.glyphMarginDecorationLaneCount,
    );
  }

  static Map<String, num> computeContainedMinimapLineCount({required num viewLineCount, required bool scrollBeyondLastLine, required num paddingTop, required num paddingBottom, required num height, required num lineHeight, required num pixelRatio}) {
    final num typicalViewportLineCount = height / lineHeight;
    final num extraLinesBeforeFirstLine = (paddingTop / lineHeight).floor();
    num extraLinesBeyondLastLine = (paddingBottom / lineHeight).floor();
    if (scrollBeyondLastLine) extraLinesBeyondLastLine = math.max(extraLinesBeyondLastLine, typicalViewportLineCount - 1);
    final num desiredRatio = (extraLinesBeforeFirstLine + viewLineCount + extraLinesBeyondLastLine) / (pixelRatio * height);
    return {'typicalViewportLineCount': typicalViewportLineCount, 'extraLinesBeforeFirstLine': extraLinesBeforeFirstLine, 'extraLinesBeyondLastLine': extraLinesBeyondLastLine, 'desiredRatio': desiredRatio, 'minimapLineCount': (viewLineCount / desiredRatio).floor()};
  }

  static num _computeMinimapScale(num configuredScale, num pixelRatio) => pixelRatio >= 2 ? (configuredScale * 2).round() : math.max(configuredScale, (configuredScale * pixelRatio + .125).floor());

  static EditorMinimapLayoutInfo _computeMinimapLayout(EditorMinimapLayoutInput input, ComputeOptionsMemory memory) {
    final num pixelRatio = input.pixelRatio;
    if (!input.minimap.enabled) return EditorMinimapLayoutInfo(renderMinimap: RenderMinimap.none, minimapLeft: 0, minimapWidth: 0, minimapHeightIsEditorHeight: false, minimapIsSampling: false, minimapScale: 1, minimapLineHeight: 1, minimapCanvasInnerWidth: 0, minimapCanvasInnerHeight: (pixelRatio * input.outerHeight).floor(), minimapCanvasOuterWidth: 0, minimapCanvasOuterHeight: input.outerHeight);
    final EditorMinimapLayoutInput? stable = memory.stableMinimapLayoutInput;
    final bool couldUseMemory = stable != null && input.outerHeight == stable.outerHeight && input.lineHeight == stable.lineHeight && input.typicalHalfwidthCharacterWidth == stable.typicalHalfwidthCharacterWidth && input.pixelRatio == stable.pixelRatio && input.scrollBeyondLastLine == stable.scrollBeyondLastLine && input.paddingTop == stable.paddingTop && input.paddingBottom == stable.paddingBottom && input.minimap.enabled == stable.minimap.enabled && input.minimap.side == stable.minimap.side && input.minimap.size == stable.minimap.size && input.minimap.showSlider == stable.minimap.showSlider && input.minimap.renderCharacters == stable.minimap.renderCharacters && input.minimap.maxColumn == stable.minimap.maxColumn && input.minimap.scale == stable.minimap.scale && input.verticalScrollbarWidth == stable.verticalScrollbarWidth && input.isViewportWrapping == stable.isViewportWrapping;
    final num baseCharHeight = input.minimap.renderCharacters ? 2 : 3;
    num canvasInnerHeight = (pixelRatio * input.outerHeight).floor();
    final num canvasOuterHeight = canvasInnerHeight / pixelRatio;
    bool heightIsEditor = false, sampling = false;
    num minimapScale = _computeMinimapScale(input.minimap.scale, pixelRatio), minimapLineHeight = baseCharHeight * minimapScale;
    num minimapCharWidth = minimapScale / pixelRatio, widthMultiplier = 1;
    if (input.minimap.size == 'fill' || input.minimap.size == 'fit') {
      final c = computeContainedMinimapLineCount(viewLineCount: input.viewLineCount, scrollBeyondLastLine: input.scrollBeyondLastLine, paddingTop: input.paddingTop, paddingBottom: input.paddingBottom, height: input.outerHeight, lineHeight: input.lineHeight, pixelRatio: pixelRatio);
      final num ratio = input.viewLineCount / c['minimapLineCount']!;
      if (ratio > 1) { heightIsEditor = true; sampling = true; minimapScale = 1; minimapLineHeight = 1; minimapCharWidth = 1 / pixelRatio; }
      else {
        bool fitBecomesFill = false; num maxScale = minimapScale + 1;
        if (input.minimap.size == 'fit') {
          final num effectiveHeight = ((c['extraLinesBeforeFirstLine']! + input.viewLineCount + c['extraLinesBeyondLastLine']!) * minimapLineHeight).ceil();
          if (input.isViewportWrapping && couldUseMemory && input.remainingWidth <= memory.stableFitRemainingWidth) { fitBecomesFill = true; maxScale = memory.stableFitMaxMinimapScale; } else fitBecomesFill = effectiveHeight > canvasInnerHeight;
        }
        if (input.minimap.size == 'fill' || fitBecomesFill) {
          heightIsEditor = true; final num configuredScale = minimapScale;
          minimapLineHeight = math.min(input.lineHeight * pixelRatio, math.max(1, (1 / c['desiredRatio']!).floor()));
          if (input.isViewportWrapping && couldUseMemory && input.remainingWidth <= memory.stableFitRemainingWidth) maxScale = memory.stableFitMaxMinimapScale;
          minimapScale = math.min(maxScale, math.max(1, (minimapLineHeight / baseCharHeight).floor()));
          if (minimapScale > configuredScale) widthMultiplier = math.min(2, minimapScale / configuredScale);
          minimapCharWidth = minimapScale / pixelRatio / widthMultiplier;
          canvasInnerHeight = (math.max(c['typicalViewportLineCount']!, c['extraLinesBeforeFirstLine']! + input.viewLineCount + c['extraLinesBeyondLastLine']!) * minimapLineHeight).ceil();
          if (input.isViewportWrapping) { memory.stableMinimapLayoutInput = input; memory.stableFitRemainingWidth = input.remainingWidth; memory.stableFitMaxMinimapScale = minimapScale; } else { memory.stableMinimapLayoutInput = null; memory.stableFitRemainingWidth = 0; }
        }
      }
    }
    final num maxWidth = (input.minimap.maxColumn * minimapCharWidth).floor();
    final num width = math.min(maxWidth, math.max(0, (((input.remainingWidth - input.verticalScrollbarWidth - 2) * minimapCharWidth) / (input.typicalHalfwidthCharacterWidth + minimapCharWidth)).floor()) + MINIMAP_GUTTER_WIDTH);
    num canvasInnerWidth = (pixelRatio * width).floor(); final num canvasOuterWidth = canvasInnerWidth / pixelRatio; canvasInnerWidth = (canvasInnerWidth * widthMultiplier).floor();
    return EditorMinimapLayoutInfo(renderMinimap: input.minimap.renderCharacters ? RenderMinimap.text : RenderMinimap.blocks, minimapLeft: input.minimap.side == 'left' ? 0 : input.outerWidth - width - input.verticalScrollbarWidth, minimapWidth: width, minimapHeightIsEditorHeight: heightIsEditor, minimapIsSampling: sampling, minimapScale: minimapScale, minimapLineHeight: minimapLineHeight, minimapCanvasInnerWidth: canvasInnerWidth, minimapCanvasInnerHeight: canvasInnerHeight, minimapCanvasOuterWidth: canvasOuterWidth, minimapCanvasOuterHeight: canvasOuterHeight);
  }

  static EditorLayoutInfo computeLayout(IComputedEditorOptions options, {required ComputeOptionsMemory? memory, required num outerWidth, required num outerHeight, required bool isDominatedByLongLines, required num lineHeight, required num viewLineCount, required num lineNumbersDigitCount, required num typicalHalfwidthCharacterWidth, required num maxDigitWidth, required num pixelRatio, required num glyphMarginDecorationLaneCount}) {
    final int width = outerWidth.toInt(), height = outerHeight.toInt(), lh = lineHeight.toInt(), digits = lineNumbersDigitCount.toInt();
    final String? override2 = options.get(EditorOption.wordWrapOverride2) as String?;
    final String? override1 = override2 == 'inherit' ? options.get(EditorOption.wordWrapOverride1) as String? : override2;
    final String? wordWrap = override1 == 'inherit' ? options.get(EditorOption.wordWrap) as String? : override1;
    final num wordWrapColumn = (options.get(EditorOption.wordWrapColumn) as num?) ?? 80;
    final bool indicator = (options.get(EditorOption.wordWrapIndicator) as bool?) ?? false;
    final bool glyph = (options.get(EditorOption.glyphMargin) as bool?) ?? false;
    final bool numbers = (options.get(EditorOption.lineNumbers) as InternalEditorRenderLineNumbersOptions).renderType != 0;
    final num minChars = (options.get(EditorOption.lineNumbersMinChars) as num?) ?? 5;
    // 1:1: source reads the raw computed slot; an unwritten slot is `undefined`
    // there (falsy), so the Dart fallback must be `false`, not the option's
    // declared default. All callers that need `true` write it explicitly.
    final bool beyond = (options.get(EditorOption.scrollBeyondLastLine) as bool?) ?? false;
    final EditorPaddingOptions padding = options.get(EditorOption.padding) as EditorPaddingOptions;
    final EditorMinimapOptions minimap = options.get(EditorOption.minimap) as EditorMinimapOptions;
    final InternalEditorScrollbarOptions scrollbar = options.get(EditorOption.scrollbar) as InternalEditorScrollbarOptions;
    final bool folding = (options.get(EditorOption.folding) as bool?) ?? true;
    num decorations = (options.get(EditorOption.lineDecorationsWidth) as num?) ?? 10;
    if (folding && options.get(EditorOption.showFoldingControls) != 'never') decorations += 16;
    final num numbersWidth = numbers ? (math.max(digits, minChars) * maxDigitWidth).round() : 0;
    final num glyphWidth = glyph ? lh * glyphMarginDecorationLaneCount : 0;
    num glyphLeft = 0, numbersLeft = glyphWidth, decorationsLeft = numbersLeft + numbersWidth, contentLeft = decorationsLeft + decorations;
    final num remaining = width - glyphWidth - numbersWidth - decorations;
    bool minified = false, viewport = false; num wrapping = -1;
    if ((options.get(EditorOption.accessibilitySupport) == AccessibilitySupport.Enabled) && override1 == 'inherit' && isDominatedByLongLines) { minified = true; viewport = true; } else if (wordWrap == 'on' || wordWrap == 'bounded') viewport = true; else if (wordWrap == 'wordWrapColumn') wrapping = wordWrapColumn;
    final EditorMinimapLayoutInfo mini = _computeMinimapLayout(EditorMinimapLayoutInput(outerWidth: width, outerHeight: height, lineHeight: lh, typicalHalfwidthCharacterWidth: typicalHalfwidthCharacterWidth, pixelRatio: pixelRatio, scrollBeyondLastLine: beyond, paddingTop: padding.top, paddingBottom: padding.bottom, minimap: minimap, verticalScrollbarWidth: scrollbar.verticalScrollbarSize, viewLineCount: viewLineCount, remainingWidth: remaining, isViewportWrapping: viewport), memory ?? ComputeOptionsMemory());
    if (mini.renderMinimap != RenderMinimap.none && mini.minimapLeft == 0) { glyphLeft += mini.minimapWidth; numbersLeft += mini.minimapWidth; decorationsLeft += mini.minimapWidth; contentLeft += mini.minimapWidth; }
    final num contentWidth = remaining - mini.minimapWidth;
    final num viewportColumn = math.max(1, ((contentWidth - scrollbar.verticalScrollbarSize - 2) / typicalHalfwidthCharacterWidth).floor());
    if (viewport) { wrapping = math.max(1, viewportColumn - (indicator ? 1 : 0)); if (wordWrap == 'bounded') wrapping = math.min(wrapping, wordWrapColumn); }
    final num arrow = scrollbar.verticalHasArrows ? scrollbar.arrowSize : 0;
    return EditorLayoutInfo(width: width, height: height, glyphMarginLeft: glyphLeft, glyphMarginWidth: glyphWidth, glyphMarginDecorationLaneCount: glyphMarginDecorationLaneCount, lineNumbersLeft: numbersLeft, lineNumbersWidth: numbersWidth, decorationsLeft: decorationsLeft, decorationsWidth: decorations, contentLeft: contentLeft, contentWidth: contentWidth, minimap: mini, viewportColumn: viewportColumn, isWordWrapMinified: minified, isViewportWrapping: viewport, wrappingColumn: wrapping, verticalScrollbarWidth: scrollbar.verticalScrollbarSize, horizontalScrollbarHeight: scrollbar.horizontalScrollbarSize, overviewRuler: OverviewRulerPosition(top: arrow, width: scrollbar.verticalScrollbarSize, height: height - 2 * arrow, right: 0));
  }
}

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
///
/// The source writes `editorOptionsRegistry[option.id] = option` (a sparse
/// indexed write), not `push`, so the list must be growable and nullable:
/// ids whose `EditorOptions` property has not been registered yet stay `null`
/// holes. A plain `List<IEditorOption<Object?>>` would either reject the
/// holes or require dense insertion, neither of which matches the source.
final List<IEditorOption<Object?>?> editorOptionsRegistry =
    <IEditorOption<Object?>?>[];

/// 1:1: `function register<K extends EditorOption, V>(option)`.
IEditorOption<V> register<V>(IEditorOption<V> option) {
  final int id = option.id;
  if (editorOptionsRegistry.length <= id) {
    // Dart grows a growable list with `null` slots when `length` is raised,
    // mirroring the holes JS leaves from `array[index] = value`.
    editorOptionsRegistry.length = id + 1;
  }
  editorOptionsRegistry[id] = option as IEditorOption<Object?>;
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

//#region wrappingStrategy

/// 1:1: `class WrappingStrategy extends BaseEditorOption<...>`.
class WrappingStrategy extends BaseEditorOption<String> {
  WrappingStrategy()
      : super(
          EditorOption.wrappingStrategy,
          'wrappingStrategy',
          'simple',
          <String, dynamic>{
            'editor.wrappingStrategy': <String, Object?>{
              'enumDescriptions': <Object?>[
                localize('wrappingStrategy.simple',
                    'Assumes that all characters are of the same width. This is a fast algorithm that works correctly for monospace fonts and certain scripts (like Latin characters) where glyphs are of equal width.'),
                localize('wrappingStrategy.advanced',
                    'Delegates wrapping points computation to the browser. This is a slow algorithm, that might cause freezes for large files, but it works correctly in all cases.'),
              ],
              'type': 'string',
              'enum': <Object?>['simple', 'advanced'],
              'default': 'simple',
              'description': localize('wrappingStrategy',
                  'Controls the algorithm that computes wrapping points. Note that when in accessibility mode, advanced will be used for the best experience.'),
            },
          },
        );

  @override
  String validate(Object? input) {
    return stringSet<String>(
        input, 'simple', <String>['simple', 'advanced']);
  }

  @override
  String compute(IEnvironmentalOptions env, IComputedEditorOptions options,
      String value) {
    final int accessibilitySupport =
        options.get(EditorOption.accessibilitySupport) as int;
    if (accessibilitySupport == AccessibilitySupport.Enabled) {
      // if we know for a fact that a screen reader is attached, we switch our
      // strategy to advanced to help that the editor's wrapping points match
      // the textarea's wrapping points
      return 'advanced';
    }
    return value;
  }
}

//#endregion

//#region lightbulb

/// 1:1: `export enum ShowLightbulbIconMode`.
class ShowLightbulbIconMode {
  static const String Off = 'off';
  static const String OnCode = 'onCode';
  static const String On = 'on';

  const ShowLightbulbIconMode._();
}

/// 1:1: `export interface IEditorLightbulbOptions` plus its
/// `Readonly<Required<...>>` alias: the port carries one value class with the
/// required field (defaults are always complete).
class EditorLightbulbOptions {
  final String enabled;
  const EditorLightbulbOptions({required this.enabled});
}

/// 1:1: `class EditorLightbulb extends BaseEditorOption<...>`.
class EditorLightbulb extends BaseEditorOption<EditorLightbulbOptions> {
  EditorLightbulb()
      : super(
          EditorOption.lightbulb,
          'lightbulb',
          const EditorLightbulbOptions(
              enabled: ShowLightbulbIconMode.OnCode),
          <String, dynamic>{
            'editor.lightbulb.enabled': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                ShowLightbulbIconMode.Off,
                ShowLightbulbIconMode.OnCode,
                ShowLightbulbIconMode.On,
              ],
              'default': ShowLightbulbIconMode.OnCode,
              'enumDescriptions': <Object?>[
                localize('editor.lightbulb.enabled.off',
                    'Disable the code action menu.'),
                localize('editor.lightbulb.enabled.onCode',
                    'Show the code action menu when the cursor is on lines with code.'),
                localize('editor.lightbulb.enabled.on',
                    'Show the code action menu when the cursor is on lines with code or on empty lines.'),
              ],
              'description': localize('enabled',
                  'Enables the Code Action lightbulb in the editor.'),
            },
          },
        );

  @override
  EditorLightbulbOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    return EditorLightbulbOptions(
      enabled: stringSet<String>(
        _input['enabled'],
        defaultValue.enabled,
        <String>[
          ShowLightbulbIconMode.Off,
          ShowLightbulbIconMode.OnCode,
          ShowLightbulbIconMode.On,
        ],
      ),
    );
  }
}

//#endregion

//#region stickyScroll

/// 1:1: `export interface IEditorStickyScrollOptions` (resolved form; defaults
/// are always complete, so the port carries the required fields).
class EditorStickyScrollOptions {
  final bool enabled;
  final num maxLineCount;
  final String defaultModel;
  final bool scrollWithEditor;

  const EditorStickyScrollOptions({
    required this.enabled,
    required this.maxLineCount,
    required this.defaultModel,
    required this.scrollWithEditor,
  });
}

/// The three values accepted by `defaultModel`.
class EditorStickyScrollDefaultModel {
  static const String outlineModel = 'outlineModel';
  static const String foldingProviderModel = 'foldingProviderModel';
  static const String indentationModel = 'indentationModel';

  const EditorStickyScrollDefaultModel._();
}

/// 1:1: `class EditorStickyScroll extends BaseEditorOption<...>`.
class EditorStickyScroll extends BaseEditorOption<EditorStickyScrollOptions> {
  EditorStickyScroll()
      : super(
          EditorOption.stickyScroll,
          'stickyScroll',
          const EditorStickyScrollOptions(
            enabled: true,
            maxLineCount: 5,
            defaultModel: EditorStickyScrollDefaultModel.outlineModel,
            scrollWithEditor: true,
          ),
          <String, dynamic>{
            'editor.stickyScroll.enabled': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('editor.stickyScroll.enabled',
                  'Shows the nested current scopes during the scroll at the top of the editor.'),
            },
            'editor.stickyScroll.maxLineCount': <String, Object?>{
              'type': 'number',
              'default': 5,
              'minimum': 1,
              'maximum': 20,
              'description': localize('editor.stickyScroll.maxLineCount',
                  'Defines the maximum number of sticky lines to show.'),
            },
            'editor.stickyScroll.defaultModel': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                EditorStickyScrollDefaultModel.outlineModel,
                EditorStickyScrollDefaultModel.foldingProviderModel,
                EditorStickyScrollDefaultModel.indentationModel,
              ],
              'default': EditorStickyScrollDefaultModel.outlineModel,
              'description': localize('editor.stickyScroll.defaultModel',
                  'Defines the model to use for determining which lines to stick. If the outline model does not exist, it will fall back on the folding provider model which falls back on the indentation model. This order is respected in all three cases.'),
            },
            'editor.stickyScroll.scrollWithEditor': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'description': localize('editor.stickyScroll.scrollWithEditor',
                  "Enable scrolling of Sticky Scroll with the editor's horizontal scrollbar."),
            },
          },
        );

  @override
  EditorStickyScrollOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    return EditorStickyScrollOptions(
      enabled: boolean(_input['enabled'], defaultValue.enabled),
      maxLineCount: EditorIntOption.clampedIntStatic(
          _input['maxLineCount'], defaultValue.maxLineCount, 1, 20) as num,
      defaultModel: stringSet<String>(
        _input['defaultModel'],
        defaultValue.defaultModel,
        <String>[
          EditorStickyScrollDefaultModel.outlineModel,
          EditorStickyScrollDefaultModel.foldingProviderModel,
          EditorStickyScrollDefaultModel.indentationModel,
        ],
      ),
      scrollWithEditor:
          boolean(_input['scrollWithEditor'], defaultValue.scrollWithEditor),
    );
  }
}

//#endregion

//#region inlayHints

/// 1:1: `export interface IEditorInlayHintsOptions` plus its
/// `Readonly<Required<...>>` alias `EditorInlayHintsOptions`: the port carries
/// one value class with the required fields (defaults are always complete).
class EditorInlayHintsOptions {
  final String enabled;
  final num fontSize;
  final String fontFamily;
  final bool padding;
  final num maximumLength;

  const EditorInlayHintsOptions({
    required this.enabled,
    required this.fontSize,
    required this.fontFamily,
    required this.padding,
    required this.maximumLength,
  });
}

/// 1:1: `class EditorInlayHints extends BaseEditorOption<...>`.
class EditorInlayHints extends BaseEditorOption<EditorInlayHintsOptions> {
  EditorInlayHints()
      : super(
          EditorOption.inlayHints,
          'inlayHints',
          const EditorInlayHintsOptions(
            enabled: 'on',
            fontSize: 0,
            fontFamily: '',
            padding: false,
            maximumLength: 43,
          ),
          <String, dynamic>{
            'editor.inlayHints.enabled': <String, Object?>{
              'type': 'string',
              'default': 'on',
              'description': localize('inlayHints.enable',
                  'Enables the inlay hints in the editor.'),
              'enum': <Object?>[
                'on',
                'onUnlessPressed',
                'offUnlessPressed',
                'off',
              ],
              'markdownEnumDescriptions': <Object?>[
                localize('editor.inlayHints.on', 'Inlay hints are enabled'),
                localize(
                    'editor.inlayHints.onUnlessPressed',
                    'Inlay hints are showing by default and hide when holding {0}',
                    <Object?>[
                      platform.isMacintosh ? 'Ctrl+Option' : 'Ctrl+Alt'
                    ]),
                localize(
                    'editor.inlayHints.offUnlessPressed',
                    'Inlay hints are hidden by default and show when holding {0}',
                    <Object?>[
                      platform.isMacintosh ? 'Ctrl+Option' : 'Ctrl+Alt'
                    ]),
                localize('editor.inlayHints.off', 'Inlay hints are disabled'),
              ],
            },
            'editor.inlayHints.fontSize': <String, Object?>{
              'type': 'number',
              'default': 0,
              'markdownDescription': localize(
                  'inlayHints.fontSize',
                  'Controls font size of inlay hints in the editor. As default the {0} is used when the configured value is less than {1} or greater than the editor font size.',
                  <Object?>['`#editor.fontSize#`', '`5`']),
            },
            'editor.inlayHints.fontFamily': <String, Object?>{
              'type': 'string',
              'default': '',
              'markdownDescription': localize(
                  'inlayHints.fontFamily',
                  'Controls font family of inlay hints in the editor. When set to empty, the {0} is used.',
                  <Object?>['`#editor.fontFamily#`']),
            },
            'editor.inlayHints.padding': <String, Object?>{
              'type': 'boolean',
              'default': false,
              'description': localize('inlayHints.padding',
                  'Enables the padding around the inlay hints in the editor.'),
            },
            'editor.inlayHints.maximumLength': <String, Object?>{
              'type': 'number',
              'default': 43,
              'markdownDescription': localize(
                  'inlayHints.maximumLength',
                  'Maximum overall length of inlay hints, for a single line, before they get truncated by the editor. Set to `0` to never truncate'),
            },
          },
        );

  @override
  EditorInlayHintsOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    Object? enabled = _input['enabled'];
    if (enabled is bool) {
      // TS coerces the deprecated boolean form before validating the enum.
      enabled = enabled ? 'on' : 'off';
    }
    return EditorInlayHintsOptions(
      enabled: stringSet<String>(enabled, defaultValue.enabled, <String>[
        'on',
        'off',
        'offUnlessPressed',
        'onUnlessPressed',
      ]),
      fontSize: EditorIntOption.clampedIntStatic(
          _input['fontSize'], defaultValue.fontSize, 0, 100) as num,
      fontFamily: EditorStringOption.string(
          _input['fontFamily'], defaultValue.fontFamily),
      padding: boolean(_input['padding'], defaultValue.padding),
      maximumLength: EditorIntOption.clampedIntStatic(_input['maximumLength'],
          defaultValue.maximumLength, 0, 9007199254740991) as num,
    );
  }
}

//#endregion

//#region lineDecorationsWidth

/// 1:1: `class EditorLineDecorationsWidth extends BaseEditorOption<...>`.
class EditorLineDecorationsWidth extends BaseEditorOption<num> {
  EditorLineDecorationsWidth()
      : super(EditorOption.lineDecorationsWidth, 'lineDecorationsWidth', 10);

  @override
  num validate(Object? input) {
    if (input is String && RegExp(r'^\d+(\.\d+)?ch$').hasMatch(input)) {
      final double multiple =
          _jsParseFloat(input.substring(0, input.length - 2))!;
      return -multiple; // negative numbers signal a multiple
    }
    return EditorIntOption.clampedIntStatic(
        input, defaultValue, 0, 1000) as num;
  }

  @override
  num compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, num value) {
    if (value < 0) {
      // negative numbers signal a multiple
      return EditorIntOption.clampedIntStatic(
              -value * env.fontInfo.typicalHalfwidthCharacterWidth,
              defaultValue,
              0,
              1000) as num;
    }
    return value;
  }
}

//#endregion

//#region lineHeight

/// 1:1: `class EditorLineHeight extends EditorFloatOption<...>`.
class EditorLineHeight extends EditorFloatOption {
  EditorLineHeight()
      : super(
          EditorOption.lineHeight,
          'lineHeight',
          EDITOR_FONT_DEFAULTS.lineHeight,
          (num x) => EditorFloatOption.clamp(x, 0, 150),
          <String, Object?>{
            'markdownDescription': localize(
                'lineHeight',
                'Controls the line height. \n - Use 0 to automatically compute the line height from the font size.\n - Values between 0 and 8 will be used as a multiplier with the font size.\n - Values greater than or equal to 8 will be used as effective values.'),
          },
          0,
          150,
        );

  @override
  num compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, num value) {
    // The lineHeight is computed from the fontSize if it is 0.
    // Moreover, the final lineHeight respects the editor zoom level.
    // So take the result from env.fontInfo
    return env.fontInfo.lineHeight;
  }
}

//#endregion

//#region minimap

/// 1:1: `class EditorMinimap extends BaseEditorOption<...>`.
class EditorMinimap extends BaseEditorOption<EditorMinimapOptions> {
  /// TS: `const defaults: EditorMinimapOptions = { ... }`.
  static const EditorMinimapOptions _defaults = EditorMinimapOptions(
    enabled: true,
    autohide: 'none',
    size: 'proportional',
    side: 'right',
    showSlider: 'mouseover',
    renderCharacters: true,
    maxColumn: 120,
    scale: 1,
    showRegionSectionHeaders: true,
    showMarkSectionHeaders: true,
    markSectionHeaderRegex: r'\bMARK:\s*(?<separator>-?)\s*(?<label>.*)$',
    sectionHeaderFontSize: 9,
    sectionHeaderLetterSpacing: 1,
  );

  EditorMinimap()
      : super(
          EditorOption.minimap,
          'minimap',
          _defaults,
          <String, dynamic>{
            'editor.minimap.enabled': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.enabled,
              'description': localize(
                  'minimap.enabled', 'Controls whether the minimap is shown.'),
            },
            'editor.minimap.autohide': <String, Object?>{
              'type': 'string',
              'enum': <Object?>['none', 'mouseover', 'scroll'],
              'enumDescriptions': <Object?>[
                localize('minimap.autohide.none',
                    'The minimap is always shown.'),
                localize(
                    'minimap.autohide.mouseover',
                    'The minimap is hidden when mouse is not over the minimap and shown when mouse is over the minimap.'),
                localize('minimap.autohide.scroll',
                    'The minimap is only shown when the editor is scrolled'),
              ],
              'default': _defaults.autohide,
              'description': localize('minimap.autohide',
                  'Controls whether the minimap is hidden automatically.'),
            },
            'editor.minimap.size': <String, Object?>{
              'type': 'string',
              'enum': <Object?>['proportional', 'fill', 'fit'],
              'enumDescriptions': <Object?>[
                localize(
                    'minimap.size.proportional',
                    'The minimap has the same size as the editor contents (and might scroll).'),
                localize(
                    'minimap.size.fill',
                    'The minimap will stretch or shrink as necessary to fill the height of the editor (no scrolling).'),
                localize(
                    'minimap.size.fit',
                    'The minimap will shrink as necessary to never be larger than the editor (no scrolling).'),
              ],
              'default': _defaults.size,
              'description': localize(
                  'minimap.size', 'Controls the size of the minimap.'),
            },
            'editor.minimap.side': <String, Object?>{
              'type': 'string',
              'enum': <Object?>['left', 'right'],
              'default': _defaults.side,
              'description': localize('minimap.side',
                  'Controls the side where to render the minimap.'),
            },
            'editor.minimap.showSlider': <String, Object?>{
              'type': 'string',
              'enum': <Object?>['always', 'mouseover'],
              'default': _defaults.showSlider,
              'description': localize('minimap.showSlider',
                  'Controls when the minimap slider is shown.'),
            },
            'editor.minimap.scale': <String, Object?>{
              'type': 'number',
              'default': _defaults.scale,
              'minimum': 1,
              'maximum': 3,
              'enum': <Object?>[1, 2, 3],
              'description': localize('minimap.scale',
                  'Scale of content drawn in the minimap: 1, 2 or 3.'),
            },
            'editor.minimap.renderCharacters': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.renderCharacters,
              'description': localize(
                  'minimap.renderCharacters',
                  'Render the actual characters on a line as opposed to color blocks.'),
            },
            'editor.minimap.maxColumn': <String, Object?>{
              'type': 'number',
              'default': _defaults.maxColumn,
              'description': localize(
                  'minimap.maxColumn',
                  'Limit the width of the minimap to render at most a certain number of columns.'),
            },
            'editor.minimap.showRegionSectionHeaders': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.showRegionSectionHeaders,
              'description': localize(
                  'minimap.showRegionSectionHeaders',
                  'Controls whether named regions are shown as section headers in the minimap.'),
            },
            'editor.minimap.showMarkSectionHeaders': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.showMarkSectionHeaders,
              'description': localize(
                  'minimap.showMarkSectionHeaders',
                  'Controls whether MARK: comments are shown as section headers in the minimap.'),
            },
            'editor.minimap.markSectionHeaderRegex': <String, Object?>{
              'type': 'string',
              'default': _defaults.markSectionHeaderRegex,
              'description': localize(
                  'minimap.markSectionHeaderRegex',
                  'Defines the regular expression used to find section headers in comments. The regex must contain a named match group `label` (written as `(?<label>.+)`) that encapsulates the section header, otherwise it will not work. Optionally you can include another match group named `separator`. Use \\n in the pattern to match multi-line headers.'),
            },
            'editor.minimap.sectionHeaderFontSize': <String, Object?>{
              'type': 'number',
              'default': _defaults.sectionHeaderFontSize,
              'description': localize(
                  'minimap.sectionHeaderFontSize',
                  'Controls the font size of section headers in the minimap.'),
            },
            'editor.minimap.sectionHeaderLetterSpacing': <String, Object?>{
              'type': 'number',
              'default': _defaults.sectionHeaderLetterSpacing,
              'description': localize(
                  'minimap.sectionHeaderLetterSpacing',
                  'Controls the amount of space (in pixels) between characters of section header. This helps the readability of the header in small font sizes.'),
            },
          },
        );

  @override
  EditorMinimapOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    final Map input = _input;

    // Validate mark section header regex
    String markSectionHeaderRegex = defaultValue.markSectionHeaderRegex;
    final Object? inputRegex = input['markSectionHeaderRegex'];
    if (inputRegex is String) {
      try {
        // TS: `new RegExp(inputRegex, 'd')`; Dart RegExp uses the same
        // ECMAScript pattern syntax (the `d` flag only adds match indices).
        RegExp(inputRegex);
        markSectionHeaderRegex = inputRegex;
      } catch (_) {}
    }

    return EditorMinimapOptions(
      enabled: boolean(input['enabled'], defaultValue.enabled),
      autohide: stringSet<String>(input['autohide'], defaultValue.autohide,
          <String>['none', 'mouseover', 'scroll']),
      size: stringSet<String>(input['size'], defaultValue.size,
          <String>['proportional', 'fill', 'fit']),
      side: stringSet<String>(
          input['side'], defaultValue.side, <String>['right', 'left']),
      showSlider: stringSet<String>(input['showSlider'], defaultValue.showSlider,
          <String>['always', 'mouseover']),
      renderCharacters: boolean(
          input['renderCharacters'], defaultValue.renderCharacters),
      // TS passes a literal `1` default for scale (not `defaults.scale`).
      scale: EditorIntOption.clampedIntStatic(input['scale'], 1, 1, 3) as num,
      maxColumn: EditorIntOption.clampedIntStatic(
          input['maxColumn'], defaultValue.maxColumn, 1, 10000) as num,
      showRegionSectionHeaders: boolean(input['showRegionSectionHeaders'],
          defaultValue.showRegionSectionHeaders),
      showMarkSectionHeaders: boolean(
          input['showMarkSectionHeaders'], defaultValue.showMarkSectionHeaders),
      markSectionHeaderRegex: markSectionHeaderRegex,
      sectionHeaderFontSize: EditorFloatOption.clamp(
          EditorFloatOption.float(input['sectionHeaderFontSize'],
              defaultValue.sectionHeaderFontSize),
          4,
          32),
      sectionHeaderLetterSpacing: EditorFloatOption.clamp(
          EditorFloatOption.float(input['sectionHeaderLetterSpacing'],
              defaultValue.sectionHeaderLetterSpacing),
          0,
          5),
    );
  }
}

//#endregion

//#region multiCursorModifier

/// 1:1: `function _multiCursorModifierFromString(multiCursorModifier)`.
String _multiCursorModifierFromString(String multiCursorModifier) {
  if (multiCursorModifier == 'ctrlCmd') {
    return platform.isMacintosh ? 'metaKey' : 'ctrlKey';
  }
  return 'altKey';
}

/// Public test-facing accessor for the source-private helper above (Dart
/// library privacy otherwise hides `_multiCursorModifierFromString`).
String multiCursorModifierFromString(String multiCursorModifier) =>
    _multiCursorModifierFromString(multiCursorModifier);

//#endregion

//#region padding

/// 1:1: `class EditorPadding extends BaseEditorOption<...>`.
class EditorPadding extends BaseEditorOption<InternalEditorPaddingOptions> {
  /// TS: `{ top: 0, bottom: 0 }`.
  static const InternalEditorPaddingOptions _defaults =
      EditorPaddingOptions(top: 0, bottom: 0);

  EditorPadding()
      : super(
          EditorOption.padding,
          'padding',
          _defaults,
          <String, dynamic>{
            'editor.padding.top': <String, Object?>{
              'type': 'number',
              'default': 0,
              'minimum': 0,
              'maximum': 1000,
              'description': localize(
                  'padding.top',
                  'Controls the amount of space between the top edge of the editor and the first line.'),
            },
            'editor.padding.bottom': <String, Object?>{
              'type': 'number',
              'default': 0,
              'minimum': 0,
              'maximum': 1000,
              'description': localize(
                  'padding.bottom',
                  'Controls the amount of space between the bottom edge of the editor and the last line.'),
            },
          },
        );

  @override
  InternalEditorPaddingOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    final Map input = _input;

    return EditorPaddingOptions(
      top: EditorIntOption.clampedIntStatic(input['top'], 0, 0, 1000) as num,
      bottom:
          EditorIntOption.clampedIntStatic(input['bottom'], 0, 0, 1000) as num,
    );
  }
}

//#endregion

//#region parameterHints

/// 1:1: `IEditorParameterHintOptions` plus its `Readonly<Required<...>>` alias
/// `InternalParameterHintOptions`.
class EditorParameterHintsOptions {
  final bool enabled, cycle;
  const EditorParameterHintsOptions({required this.enabled, required this.cycle});
}

/// 1:1: `export type InternalParameterHintOptions = Readonly<Required<IEditorParameterHintOptions>>`.
typedef InternalParameterHintOptions = EditorParameterHintsOptions;

/// 1:1: `class EditorParameterHints extends BaseEditorOption<...>`.
class EditorParameterHints extends BaseEditorOption<InternalParameterHintOptions> {
  /// TS: `const defaults: InternalParameterHintOptions = { enabled: true, cycle: true }`.
  /// (The interface comment claims cycle defaults to false; the code — and the
  /// source-executed truth — use `true`.)
  static const InternalParameterHintOptions _defaults =
      EditorParameterHintsOptions(enabled: true, cycle: true);

  EditorParameterHints()
      : super(
          EditorOption.parameterHints,
          'parameterHints',
          _defaults,
          <String, dynamic>{
            'editor.parameterHints.enabled': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.enabled,
              'description': localize(
                  'parameterHints.enabled',
                  'Enables a pop-up that shows parameter documentation and type information as you type.'),
            },
            'editor.parameterHints.cycle': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.cycle,
              'description': localize(
                  'parameterHints.cycle',
                  'Controls whether the parameter hints menu cycles or closes when reaching the end of the list.'),
            },
          },
        );

  @override
  InternalParameterHintOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    final Map input = _input;
    return EditorParameterHintsOptions(
      enabled: boolean(input['enabled'], defaultValue.enabled),
      cycle: boolean(input['cycle'], defaultValue.cycle),
    );
  }
}

//#endregion

//#region pixelRatio

/// 1:1: `class EditorPixelRatio extends ComputedEditorOption<...>`.
class EditorPixelRatio extends ComputedEditorOption<num> {
  EditorPixelRatio() : super(EditorOption.pixelRatio, 1);

  @override
  num compute(IEnvironmentalOptions env, IComputedEditorOptions options,
      Object? _) {
    return env.pixelRatio;
  }
}

//#endregion

//#region placeholder

/// 1:1: `class PlaceholderOption extends BaseEditorOption<..., string | undefined, string | undefined>`.
/// Dart has no `undefined`; the source default is represented as `null`.
class PlaceholderOption extends BaseEditorOption<String?> {
  PlaceholderOption()
      : super(EditorOption.placeholder, 'placeholder', null);

  @override
  String? validate(Object? input) {
    if (input is! String) {
      return defaultValue;
    }
    return input;
  }
}

//#endregion

//#region quickSuggestions

/// 1:1: `export type QuickSuggestionsValue`.
class QuickSuggestionsValue {
  static const String on = 'on';
  static const String inline = 'inline';
  static const String off = 'off';
  static const String offWhenInlineCompletions = 'offWhenInlineCompletions';

  const QuickSuggestionsValue._();
}

/// 1:1: `export interface IQuickSuggestionsOptions` — the structural user
/// input (`other`/`comments`/`strings` are `boolean | QuickSuggestionsValue`).
class IQuickSuggestionsOptions {
  IQuickSuggestionsOptions({this.other, this.comments, this.strings});

  Object? other, comments, strings;
}

/// 1:1: `export interface InternalQuickSuggestionsOptions`.
class InternalQuickSuggestionsOptions {
  const InternalQuickSuggestionsOptions({
    required this.other,
    required this.comments,
    required this.strings,
  });

  final String other, comments, strings;
}

/// 1:1: `class EditorQuickSuggestions extends BaseEditorOption<...>`.
class EditorQuickSuggestions
    extends BaseEditorOption<InternalQuickSuggestionsOptions> {
  /// TS: `const defaults: InternalQuickSuggestionsOptions = { ... }`.
  static const InternalQuickSuggestionsOptions _defaults =
      InternalQuickSuggestionsOptions(
    other: QuickSuggestionsValue.offWhenInlineCompletions,
    comments: QuickSuggestionsValue.off,
    strings: QuickSuggestionsValue.off,
  );

  static const List<String> _allowedValues = <String>[
    QuickSuggestionsValue.on,
    QuickSuggestionsValue.inline,
    QuickSuggestionsValue.off,
    QuickSuggestionsValue.offWhenInlineCompletions,
  ];

  /// TS: `const types: IJSONSchema[] = [...]`, shared by the three property
  /// schemas below.
  static List<Object?> _types() => <Object?>[
        <String, Object?>{'type': 'boolean'},
        <String, Object?>{
          'type': 'string',
          'enum': List<Object?>.of(_allowedValues),
          'enumDescriptions': <Object?>[
            localize('on', 'Quick suggestions show inside the suggest widget'),
            localize('inline', 'Quick suggestions show as ghost text'),
            localize('off', 'Quick suggestions are disabled'),
            localize('offWhenInlineCompletions',
                'Quick suggestions are disabled when inline completions are showing'),
          ],
        },
      ];

  static IConfigurationPropertySchema _buildSchema() {
    final List<Object?> types = _types();
    return <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{'type': 'boolean'},
        <String, Object?>{
          'type': 'string',
          'enum': List<Object?>.of(_allowedValues),
          'enumDescriptions': <Object?>[
            localize('quickSuggestions.topLevel.on',
                'Quick suggestions are enabled for all token types'),
            localize('quickSuggestions.topLevel.inline',
                'Quick suggestions show as ghost text for all token types'),
            localize('quickSuggestions.topLevel.off',
                'Quick suggestions are disabled for all token types'),
            localize('quickSuggestions.topLevel.offWhenInlineCompletions',
                'Quick suggestions are disabled for all token types when inline completions are showing'),
          ],
        },
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'strings': <String, Object?>{
              'anyOf': types,
              'default': QuickSuggestionsValue.off,
              'description': localize(
                  'quickSuggestions.strings',
                  'Enable quick suggestions inside strings.'),
            },
            'comments': <String, Object?>{
              'anyOf': types,
              'default': QuickSuggestionsValue.off,
              'description': localize(
                  'quickSuggestions.comments',
                  'Enable quick suggestions inside comments.'),
            },
            'other': <String, Object?>{
              'anyOf': types,
              'default': QuickSuggestionsValue.offWhenInlineCompletions,
              'description': localize(
                  'quickSuggestions.other',
                  'Enable quick suggestions outside of strings and comments.'),
            },
          },
        },
      ],
      // TS: `default: defaults` — the same object, serialized as its fields.
      'default': <String, Object?>{
        'other': QuickSuggestionsValue.offWhenInlineCompletions,
        'comments': QuickSuggestionsValue.off,
        'strings': QuickSuggestionsValue.off,
      },
      'markdownDescription': localize(
        'quickSuggestions',
        'Controls whether suggestions should automatically show up while typing. This can be controlled for typing in comments, strings, and other code. Quick suggestion can be configured to show as ghost text or with the suggest widget. Also be aware of the {0}-setting which controls if suggestions are triggered by special characters.',
        <Object?>['`#editor.suggestOnTriggerCharacters#`'],
      ),
      'experiment': <String, Object?>{'mode': 'auto'},
    };
  }

  EditorQuickSuggestions()
      : super(
          EditorOption.quickSuggestions,
          'quickSuggestions',
          _defaults,
          _buildSchema(),
        );

  @override
  InternalQuickSuggestionsOptions validate(Object? input) {
    if (input is bool) {
      // boolean -> all on/off
      final String value = input ? QuickSuggestionsValue.on : QuickSuggestionsValue.off;
      return InternalQuickSuggestionsOptions(
        other: value, comments: value, strings: value);
    }
    if (input is String) {
      // string shorthand -> apply same value to all token types
      final String validated = stringSet<String>(
          input, defaultValue.other, _allowedValues);
      return InternalQuickSuggestionsOptions(
        other: validated, comments: validated, strings: validated);
    }
    if (input is! Map) {
      // invalid input
      return defaultValue;
    }
    final Map values = input;
    final Object? other = values['other'];
    final Object? comments = values['comments'];
    final Object? strings = values['strings'];
    final String validatedOther = other is bool
        ? (other ? QuickSuggestionsValue.on : QuickSuggestionsValue.off)
        : stringSet<String>(other, defaultValue.other, _allowedValues);
    final String validatedComments = comments is bool
        ? (comments ? QuickSuggestionsValue.on : QuickSuggestionsValue.off)
        : stringSet<String>(comments, defaultValue.comments, _allowedValues);
    final String validatedStrings = strings is bool
        ? (strings ? QuickSuggestionsValue.on : QuickSuggestionsValue.off)
        : stringSet<String>(strings, defaultValue.strings, _allowedValues);
    return InternalQuickSuggestionsOptions(
      other: validatedOther,
      comments: validatedComments,
      strings: validatedStrings,
    );
  }
}

//#endregion

//#region renderLineNumbers

/// 1:1: `export type LineNumbersType`; the last alternative is the custom
/// `String Function(int lineNumber)` callback.
class LineNumbersType {
  static const String on = 'on';
  static const String off = 'off';
  static const String relative = 'relative';
  static const String interval = 'interval';

  const LineNumbersType._();
}

/// 1:1: `export const enum RenderLineNumbersType`.
class RenderLineNumbersType {
  static const int off = 0;
  static const int on = 1;
  static const int relative = 2;
  static const int interval = 3;
  static const int custom = 4;

  const RenderLineNumbersType._();
}

/// Dart stand-in for the source's `undefined`: Dart has no `undefined`, and
/// `null` must replay the source's explicit `null` branch (which validates to
/// `Off`), so an omitted argument carries the `undefined` case instead.
const Object _undefinedLineNumbers = Object();

/// 1:1: `class EditorRenderLineNumbersOption extends BaseEditorOption<...>`.
class EditorRenderLineNumbersOption
    extends BaseEditorOption<InternalEditorRenderLineNumbersOptions> {
  EditorRenderLineNumbersOption()
      : super(
          EditorOption.lineNumbers,
          'lineNumbers',
          const InternalEditorRenderLineNumbersOptions(RenderLineNumbersType.on),
          <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              LineNumbersType.off,
              LineNumbersType.on,
              LineNumbersType.relative,
              LineNumbersType.interval,
            ],
            'enumDescriptions': <Object?>[
              localize('lineNumbers.off', 'Line numbers are not rendered.'),
              localize('lineNumbers.on',
                  'Line numbers are rendered as absolute number.'),
              localize('lineNumbers.relative',
                  'Line numbers are rendered as distance in lines to cursor position.'),
              localize('lineNumbers.interval',
                  'Line numbers are rendered every 10 lines.'),
            ],
            'default': LineNumbersType.on,
            'description':
                localize('lineNumbers', 'Controls the display of line numbers.'),
          },
        );

  /// Omitting the argument replays the source's `undefined` branch
  /// (`_undefinedLineNumbers`); passing Dart `null` replays the source's
  /// explicit `null` branch.
  @override
  InternalEditorRenderLineNumbersOptions
      validate([Object? lineNumbers = _undefinedLineNumbers]) {
    int renderType = defaultValue.renderType;
    String Function(int)? renderFn = defaultValue.renderFn;

    if (!identical(lineNumbers, _undefinedLineNumbers)) {
      if (lineNumbers is String Function(int)) {
        renderType = RenderLineNumbersType.custom;
        renderFn = lineNumbers;
      } else if (lineNumbers == LineNumbersType.interval) {
        renderType = RenderLineNumbersType.interval;
      } else if (lineNumbers == LineNumbersType.relative) {
        renderType = RenderLineNumbersType.relative;
      } else if (lineNumbers == LineNumbersType.on) {
        renderType = RenderLineNumbersType.on;
      } else {
        renderType = RenderLineNumbersType.off;
      }
    }

    return InternalEditorRenderLineNumbersOptions(renderType, renderFn);
  }
}

//#endregion

//#region renderValidationDecorations

/// @internal
/// 1:1: `export function filterValidationDecorations(options)`.
bool filterValidationDecorations(IComputedEditorOptions options) {
  final Object? value = options.get(EditorOption.renderValidationDecorations);
  if (value == 'editable') {
    return options.get(EditorOption.readOnly) as bool;
  }
  return value == 'on' ? false : true;
}

//#endregion

//#region filterFontDecorations

/// @internal
/// 1:1: `export function filterFontDecorations(options)`.
bool filterFontDecorations(IComputedEditorOptions options) {
  return !(options.get(EditorOption.effectiveAllowVariableFonts) as bool? ??
      false);
}

//#endregion

//#region rulers

/// 1:1: `export interface IRulerOption`.
class IRulerOption {
  const IRulerOption({required this.column, required this.color});

  /// TS: number
  final num column;

  /// TS: `string | null`. Kept as `Object?` so the source's unchecked
  /// `color: element.color` assignment forwards the value verbatim.
  final Object? color;
}

/// 1:1: `class EditorRulers extends BaseEditorOption<...>`.
class EditorRulers extends BaseEditorOption<List<IRulerOption>> {
  /// TS constructor-local `defaults`, shared with `schema.default`.
  static const List<IRulerOption> _defaults = <IRulerOption>[];

  /// TS constructor-local `columnSchema`, shared by `anyOf[0]` and
  /// `properties.column`; `static final` because `localize` is not const.
  static final Map<String, Object?> _columnSchema = <String, Object?>{
    'type': 'number',
    'description': localize(
        'rulers.size',
        'Number of monospace characters at which this editor ruler will render.'),
  };

  EditorRulers()
      : super(
          EditorOption.rulers,
          'rulers',
          _defaults,
          <String, Object?>{
            'type': 'array',
            'items': <String, Object?>{
              'anyOf': <Object?>[
                _columnSchema,
                <String, Object?>{
                  'type': <Object?>['object'],
                  'properties': <String, Object?>{
                    'column': _columnSchema,
                    'color': <String, Object?>{
                      'type': 'string',
                      'description': localize(
                          'rulers.color', 'Color of this editor ruler.'),
                      'format': 'color-hex',
                    },
                  },
                },
              ],
            },
            'default': _defaults,
            'description': localize(
                'rulers',
                'Render vertical rulers after a certain number of monospace characters. Use multiple values for multiple rulers. No rulers are drawn if array is empty.'),
          },
        );

  @override
  List<IRulerOption> validate(Object? input) {
    if (input is List) {
      final List<IRulerOption> rulers = <IRulerOption>[];
      for (final Object? element in input) {
        if (element is num) {
          rulers.add(IRulerOption(
            column:
                EditorIntOption.clampedIntStatic(element, 0, 0, 10000) as num,
            color: null,
          ));
        } else if (element != null &&
            (element is Map ||
                element is IRulerOption ||
                element is List)) {
          // TS: `_element && typeof _element === 'object'`, then a cast to
          // `IRulerOption`; `column`/`color` are read without validation.
          final Object? column = element is Map
              ? element['column']
              : (element is IRulerOption ? element.column : null);
          final Object? color = element is Map
              ? element['color']
              : (element is IRulerOption ? element.color : null);
          rulers.add(IRulerOption(
            column:
                EditorIntOption.clampedIntStatic(column, 0, 0, 10000) as num,
            color: color,
          ));
        }
      }
      // JS `Array.prototype.sort` is stable; duplicate columns are avoided in
      // the replay cases so Dart's sort yields the same visible order.
      rulers.sort((IRulerOption a, IRulerOption b) =>
          a.column.compareTo(b.column));
      return rulers;
    }
    return defaultValue;
  }
}

//#endregion

//#region readonly

/// 1:1: `class ReadonlyMessage extends BaseEditorOption<...>`.
/// The value type `IMarkdownString | undefined` is carried as `Object?` (the
/// same mapping used by `IEditorOptions.readOnlyMessage`).
class ReadonlyMessage extends BaseEditorOption<Object?> {
  ReadonlyMessage()
      : super(EditorOption.readOnlyMessage, 'readOnlyMessage', null);

  @override
  Object? validate(Object? input) {
    // TS: `if (!_input || typeof _input !== 'object') return defaultValue;`
    // Falsy primitives (`''`, `0`, `false`, `undefined`, `null`) and all other
    // primitives fall back; any object is forwarded unchanged.
    if (input == null || input is String || input is num || input is bool) {
      return defaultValue;
    }
    return input;
  }
}

//#endregion

//#region scrollbar

/// 1:1: `function _scrollbarVisibilityFromString(visibility, defaultValue)`.
/// Only the source strings `'hidden'` and `'visible'` are recognised; every
/// other string (and every non-string) falls through to `Auto` / `defaultValue`.
int _scrollbarVisibilityFromString(Object? visibility, int defaultValue) {
  if (visibility is! String) {
    return defaultValue;
  }
  switch (visibility) {
    case 'hidden':
      return ScrollbarVisibility.Hidden;
    case 'visible':
      return ScrollbarVisibility.Visible;
    default:
      return ScrollbarVisibility.Auto;
  }
}

/// 1:1: `class EditorScrollbar extends BaseEditorOption<...>` (source lines
/// 4305–4397). The schema is recorded verbatim from the real source (no
/// platform-dependent strings in this region).
class EditorScrollbar extends BaseEditorOption<InternalEditorScrollbarOptions> {
  /// TS: `const defaults: InternalEditorScrollbarOptions = { ... }`.
  static const InternalEditorScrollbarOptions _defaults =
      InternalEditorScrollbarOptions(
    vertical: ScrollbarVisibility.Auto,
    horizontal: ScrollbarVisibility.Auto,
    arrowSize: 11,
    useShadows: true,
    verticalHasArrows: false,
    horizontalHasArrows: false,
    horizontalScrollbarSize: 12,
    horizontalSliderSize: 12,
    verticalScrollbarSize: 14,
    verticalSliderSize: 14,
    handleMouseWheel: true,
    alwaysConsumeMouseWheel: true,
    scrollByPage: false,
    ignoreHorizontalScrollbarInContentHeight: false,
  );

  EditorScrollbar()
      : super(
          EditorOption.scrollbar,
          'scrollbar',
          _defaults,
          <String, Object?>{
            'editor.scrollbar.vertical': <String, Object?>{
              'type': 'string',
              'enum': <Object?>['auto', 'visible', 'hidden'],
              'enumDescriptions': <Object?>[
                localize('scrollbar.vertical.auto',
                    'The vertical scrollbar will be visible only when necessary.'),
                localize('scrollbar.vertical.visible',
                    'The vertical scrollbar will always be visible.'),
                localize('scrollbar.vertical.fit',
                    'The vertical scrollbar will always be hidden.'),
              ],
              'default': 'auto',
              'description': localize('scrollbar.vertical',
                  'Controls the visibility of the vertical scrollbar.'),
            },
            'editor.scrollbar.horizontal': <String, Object?>{
              'type': 'string',
              'enum': <Object?>['auto', 'visible', 'hidden'],
              'enumDescriptions': <Object?>[
                localize('scrollbar.horizontal.auto',
                    'The horizontal scrollbar will be visible only when necessary.'),
                localize('scrollbar.horizontal.visible',
                    'The horizontal scrollbar will always be visible.'),
                localize('scrollbar.horizontal.fit',
                    'The horizontal scrollbar will always be hidden.'),
              ],
              'default': 'auto',
              'description': localize('scrollbar.horizontal',
                  'Controls the visibility of the horizontal scrollbar.'),
            },
            'editor.scrollbar.verticalScrollbarSize': <String, Object?>{
              'type': 'number',
              'default': _defaults.verticalScrollbarSize,
              'description': localize('scrollbar.verticalScrollbarSize',
                  'The width of the vertical scrollbar.'),
            },
            'editor.scrollbar.horizontalScrollbarSize': <String, Object?>{
              'type': 'number',
              'default': _defaults.horizontalScrollbarSize,
              'description': localize('scrollbar.horizontalScrollbarSize',
                  'The height of the horizontal scrollbar.'),
            },
            'editor.scrollbar.scrollByPage': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.scrollByPage,
              'description': localize('scrollbar.scrollByPage',
                  'Controls whether clicks scroll by page or jump to click position.'),
            },
            'editor.scrollbar.ignoreHorizontalScrollbarInContentHeight':
                <String, Object?>{
              'type': 'boolean',
              'default': _defaults.ignoreHorizontalScrollbarInContentHeight,
              'description': localize(
                  'scrollbar.ignoreHorizontalScrollbarInContentHeight',
                  "When set, the horizontal scrollbar will not increase the size of the editor's content."),
            },
          },
        );

  @override
  InternalEditorScrollbarOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    final Map input = _input;

    // Slider sizes default to the *validated* scrollbar sizes (source lines
    // 4378-4392), so clamp those two first and reuse them as fallbacks.
    final Object horizontalScrollbarSize = EditorIntOption.clampedIntStatic(
        input['horizontalScrollbarSize'],
        defaultValue.horizontalScrollbarSize,
        0,
        1000);
    final Object verticalScrollbarSize = EditorIntOption.clampedIntStatic(
        input['verticalScrollbarSize'],
        defaultValue.verticalScrollbarSize,
        0,
        1000);
    return InternalEditorScrollbarOptions(
      arrowSize: EditorIntOption.clampedIntStatic(
          input['arrowSize'], defaultValue.arrowSize, 0, 1000) as num,
      vertical: _scrollbarVisibilityFromString(
          input['vertical'], defaultValue.vertical),
      horizontal: _scrollbarVisibilityFromString(
          input['horizontal'], defaultValue.horizontal),
      useShadows: boolean(input['useShadows'], defaultValue.useShadows),
      verticalHasArrows: boolean(
          input['verticalHasArrows'], defaultValue.verticalHasArrows),
      horizontalHasArrows: boolean(
          input['horizontalHasArrows'], defaultValue.horizontalHasArrows),
      handleMouseWheel: boolean(
          input['handleMouseWheel'], defaultValue.handleMouseWheel),
      alwaysConsumeMouseWheel: boolean(
          input['alwaysConsumeMouseWheel'],
          defaultValue.alwaysConsumeMouseWheel),
      horizontalScrollbarSize: horizontalScrollbarSize as num,
      horizontalSliderSize: EditorIntOption.clampedIntStatic(
          input['horizontalSliderSize'], horizontalScrollbarSize, 0, 1000) as num,
      verticalScrollbarSize: verticalScrollbarSize as num,
      verticalSliderSize: EditorIntOption.clampedIntStatic(
          input['verticalSliderSize'], verticalScrollbarSize, 0, 1000) as num,
      scrollByPage: boolean(input['scrollByPage'], defaultValue.scrollByPage),
      ignoreHorizontalScrollbarInContentHeight: boolean(
          input['ignoreHorizontalScrollbarInContentHeight'],
          defaultValue.ignoreHorizontalScrollbarInContentHeight),
    );
  }
}

//#endregion

//#region UnicodeHighlight

/// 1:1: `export type InUntrustedWorkspace = 'inUntrustedWorkspace'`.
class InUntrustedWorkspace {
  static const String value = 'inUntrustedWorkspace';

  const InUntrustedWorkspace._();
}

/// 1:1: `export const inUntrustedWorkspace: InUntrustedWorkspace =
/// 'inUntrustedWorkspace'`.
const String inUntrustedWorkspace = InUntrustedWorkspace.value;

/// Configuration options for unicode highlighting.
/// 1:1: `export interface IUnicodeHighlightOptions`.
///
/// `boolean | InUntrustedWorkspace` erases to `Object?` (a `bool` or the
/// `inUntrustedWorkspace` string); `Record<string, true>` erases to
/// `Map<String, Object?>` so raw updates can be carried unchanged.
class IUnicodeHighlightOptions {
  IUnicodeHighlightOptions({
    this.nonBasicASCII,
    this.invisibleCharacters,
    this.ambiguousCharacters,
    this.includeComments,
    this.includeStrings,
    this.allowedCharacters,
    this.allowedLocales,
  });

  /// Controls whether all non-basic ASCII characters are highlighted. Only
  /// characters between U+0020 and U+007E, tab, line-feed and carriage-return
  /// are considered basic ASCII.
  Object? nonBasicASCII;

  /// Controls whether characters that just reserve space or have no width at
  /// all are highlighted.
  bool? invisibleCharacters;

  /// Controls whether characters are highlighted that can be confused with
  /// basic ASCII characters, except those that are common in the current user
  /// locale.
  bool? ambiguousCharacters;

  /// Controls whether characters in comments should also be subject to unicode
  /// highlighting.
  Object? includeComments;

  /// Controls whether characters in strings should also be subject to unicode
  /// highlighting.
  Object? includeStrings;

  /// Defines allowed characters that are not being highlighted.
  Map<String, Object?>? allowedCharacters;

  /// Unicode characters that are common in allowed locales are not being
  /// highlighted.
  Map<String, Object?>? allowedLocales;
}

/// @internal
/// 1:1: `export type InternalUnicodeHighlightOptions = Required<Readonly<IUnicodeHighlightOptions>>`.
class InternalUnicodeHighlightOptions {
  const InternalUnicodeHighlightOptions({
    required this.nonBasicASCII,
    required this.invisibleCharacters,
    required this.ambiguousCharacters,
    required this.includeComments,
    required this.includeStrings,
    required this.allowedCharacters,
    required this.allowedLocales,
  });

  final Object nonBasicASCII;
  final bool invisibleCharacters;
  final bool ambiguousCharacters;
  final Object includeComments;
  final Object includeStrings;
  final Map<String, Object?> allowedCharacters;
  final Map<String, Object?> allowedLocales;
}

/// @internal
/// 1:1: `export const unicodeHighlightConfigKeys = { ... }`.
const Map<String, String> unicodeHighlightConfigKeys = <String, String>{
  'allowedCharacters': 'editor.unicodeHighlight.allowedCharacters',
  'invisibleCharacters': 'editor.unicodeHighlight.invisibleCharacters',
  'nonBasicASCII': 'editor.unicodeHighlight.nonBasicASCII',
  'ambiguousCharacters': 'editor.unicodeHighlight.ambiguousCharacters',
  'includeComments': 'editor.unicodeHighlight.includeComments',
  'includeStrings': 'editor.unicodeHighlight.includeStrings',
  'allowedLocales': 'editor.unicodeHighlight.allowedLocales',
};

/// JS truthiness (used by the source's `update.allowedCharacters && value`
/// gates). Unlike [boolean], the string `'false'` is truthy here.
bool _jsTruthy(Object? value) {
  if (value == null) {
    return false;
  }
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

/// 1:1: `function primitiveSet` (source line 5074, used by this region's
/// validate): `T extends string | boolean`, `value`, `defaultValue`,
/// `allowedValues`.
/// `T` erases to `Object`; the loop mirrors `allowedValues.indexOf(value)`'s
/// strict equality without a cast (non-primitive values just miss).
T primitiveSet<T extends Object>(
    Object? value, T defaultValue, List<T> allowedValues) {
  for (final T candidate in allowedValues) {
    if (candidate == value) {
      return candidate;
    }
  }
  return defaultValue;
}

/// Representation helper: the resolved carrier is the Dart stand-in for the
/// source's plain object value; `applyUpdate` works on an equivalent map.
Map<Object?, Object?> _unicodeHighlightCarrierToMap(
        InternalUnicodeHighlightOptions value) =>
    <Object?, Object?>{
      'nonBasicASCII': value.nonBasicASCII,
      'invisibleCharacters': value.invisibleCharacters,
      'ambiguousCharacters': value.ambiguousCharacters,
      'includeComments': value.includeComments,
      'includeStrings': value.includeStrings,
      'allowedCharacters': value.allowedCharacters,
      'allowedLocales': value.allowedLocales,
    };

/// 1:1: `class UnicodeHighlight extends BaseEditorOption<...>` (source lines
/// 4451–4593). `V` is `Object?` so `applyUpdate` can return the raw source
/// values (including non-object updates) exactly as JS does.
class UnicodeHighlight extends BaseEditorOption<Object?> {
  /// TS: `const defaults: InternalUnicodeHighlightOptions = { ... }`.
  static const InternalUnicodeHighlightOptions _defaults =
      InternalUnicodeHighlightOptions(
    nonBasicASCII: inUntrustedWorkspace,
    invisibleCharacters: true,
    ambiguousCharacters: true,
    includeComments: inUntrustedWorkspace,
    includeStrings: true,
    allowedCharacters: <String, Object?>{},
    allowedLocales: <String, Object?>{'_os': true, '_vscode': true},
  );

  UnicodeHighlight()
      : super(
          EditorOption.unicodeHighlighting,
          'unicodeHighlight',
          _defaults,
          <String, Object?>{
            'editor.unicodeHighlight.nonBasicASCII': <String, Object?>{
              'restricted': true,
              'type': <Object?>['boolean', 'string'],
              'enum': <Object?>[true, false, inUntrustedWorkspace],
              'default': _defaults.nonBasicASCII,
              'description': localize(
                  'unicodeHighlight.nonBasicASCII',
                  'Controls whether all non-basic ASCII characters are highlighted. Only characters between U+0020 and U+007E, tab, line-feed and carriage-return are considered basic ASCII.'),
            },
            'editor.unicodeHighlight.invisibleCharacters': <String, Object?>{
              'restricted': true,
              'type': 'boolean',
              'default': _defaults.invisibleCharacters,
              'description': localize(
                  'unicodeHighlight.invisibleCharacters',
                  'Controls whether characters that just reserve space or have no width at all are highlighted.'),
            },
            'editor.unicodeHighlight.ambiguousCharacters': <String, Object?>{
              'restricted': true,
              'type': 'boolean',
              'default': _defaults.ambiguousCharacters,
              'description': localize(
                  'unicodeHighlight.ambiguousCharacters',
                  'Controls whether characters are highlighted that can be confused with basic ASCII characters, except those that are common in the current user locale.'),
            },
            'editor.unicodeHighlight.includeComments': <String, Object?>{
              'restricted': true,
              'type': <Object?>['boolean', 'string'],
              'enum': <Object?>[true, false, inUntrustedWorkspace],
              'default': _defaults.includeComments,
              'description': localize('unicodeHighlight.includeComments',
                  'Controls whether characters in comments should also be subject to Unicode highlighting.'),
            },
            'editor.unicodeHighlight.includeStrings': <String, Object?>{
              'restricted': true,
              'type': <Object?>['boolean', 'string'],
              'enum': <Object?>[true, false, inUntrustedWorkspace],
              'default': _defaults.includeStrings,
              'description': localize('unicodeHighlight.includeStrings',
                  'Controls whether characters in strings should also be subject to Unicode highlighting.'),
            },
            'editor.unicodeHighlight.allowedCharacters': <String, Object?>{
              'restricted': true,
              'type': 'object',
              'default': _defaults.allowedCharacters,
              'description': localize('unicodeHighlight.allowedCharacters',
                  'Defines allowed characters that are not being highlighted.'),
              'additionalProperties': <String, Object?>{'type': 'boolean'},
            },
            'editor.unicodeHighlight.allowedLocales': <String, Object?>{
              'restricted': true,
              'type': 'object',
              'additionalProperties': <String, Object?>{'type': 'boolean'},
              'default': _defaults.allowedLocales,
              'description': localize('unicodeHighlight.allowedLocales',
                  'Unicode characters that are common in allowed locales are not being highlighted.'),
            },
          },
        );

  @override
  ApplyUpdateResult<Object?> applyUpdate(Object? value, Object? update) {
    var didChange = false;
    Map<Object?, Object?>? resolvedValue;
    if (value is InternalUnicodeHighlightOptions) {
      resolvedValue = _unicodeHighlightCarrierToMap(value);
    } else if (value is Map) {
      // Source spreads `value` when a map is replaced atomically.
      resolvedValue = Map<Object?, Object?>.from(value as Map<Object?, Object?>);
    }

    if (resolvedValue != null && update is Map && _jsTruthy(value)) {
      final Object? allowedCharacters = update['allowedCharacters'];
      if (_jsTruthy(allowedCharacters) &&
          !objects.equals(
              resolvedValue['allowedCharacters'], allowedCharacters)) {
        // Treat allowedCharacters atomically.
        resolvedValue['allowedCharacters'] = allowedCharacters;
        didChange = true;
      }
      final Object? allowedLocales = update['allowedLocales'];
      if (_jsTruthy(allowedLocales) &&
          !objects.equals(resolvedValue['allowedLocales'], allowedLocales)) {
        // Treat allowedLocales atomically.
        resolvedValue['allowedLocales'] = allowedLocales;
        didChange = true;
      }
    }

    final ApplyUpdateResult<Object?> result =
        super.applyUpdate(resolvedValue, update);
    if (didChange) {
      return ApplyUpdateResult<Object?>(result.newValue, true);
    }
    return result;
  }

  @override
  Object? validate(Object? _input) {
    // JS arrays are objects too; they carry none of the source's named keys.
    if (_input is! Map && _input is! List) {
      return defaultValue;
    }
    final Map<Object?, Object?> input = _input is Map
        ? _input as Map<Object?, Object?>
        : <Object?, Object?>{};
    final InternalUnicodeHighlightOptions defaults =
        defaultValue as InternalUnicodeHighlightOptions;
    return InternalUnicodeHighlightOptions(
      nonBasicASCII: primitiveSet<Object>(input['nonBasicASCII'],
          inUntrustedWorkspace, <Object>[true, false, inUntrustedWorkspace]),
      invisibleCharacters: boolean(
          input['invisibleCharacters'], defaults.invisibleCharacters),
      ambiguousCharacters: boolean(
          input['ambiguousCharacters'], defaults.ambiguousCharacters),
      includeComments: primitiveSet<Object>(input['includeComments'],
          inUntrustedWorkspace, <Object>[true, false, inUntrustedWorkspace]),
      includeStrings: primitiveSet<Object>(input['includeStrings'],
          inUntrustedWorkspace, <Object>[true, false, inUntrustedWorkspace]),
      allowedCharacters: validateBooleanMap(
          input['allowedCharacters'], defaults.allowedCharacters),
      allowedLocales:
          validateBooleanMap(input['allowedLocales'], defaults.allowedLocales),
    );
  }

  /// Source-private instance helper, kept with the same name so the truth
  /// harness can probe it directly.
  Map<String, Object?> validateBooleanMap(
      Object? map, Map<String, Object?> defaultValue) {
    if (map == null || (map is! Map && map is! List)) {
      return defaultValue;
    }
    final Map<Object?, Object?> entries = <Object?, Object?>{};
    if (map is Map) {
      map.forEach((Object? key, Object? value) => entries[key] = value);
    } else {
      // `Object.entries` on a JS array exposes its index keys.
      final List<Object?> list = map as List<Object?>;
      for (int i = 0; i < list.length; i++) {
        entries['$i'] = list[i];
      }
    }
    final Map<String, Object?> result = <String, Object?>{};
    entries.forEach((Object? key, Object? value) {
      if (value is bool && value) {
        result['$key'] = true;
      }
    });
    return result;
  }
}

//#endregion

//#region inlineSuggest

/// 1:1: `export interface IInlineSuggestOptions` (source lines 4597–4655).
/// String-literal unions erase to `String`; `number` to `num`; the two inline
/// object literals (`edits`, `experimental`) become named Dart interfaces.
class IInlineSuggestOptions {
  IInlineSuggestOptions({
    this.enabled,
    this.mode,
    this.showToolbar,
    this.syntaxHighlightingEnabled,
    this.suppressSuggestions,
    this.minShowDelay,
    this.suppressInSnippetMode,
    this.keepOnBlur,
    this.fontFamily,
    this.edits,
    this.triggerCommandOnProviderChange,
    this.experimental,
  });

  /// Enable or disable the rendering of automatic inline completions.
  bool? enabled;

  /// `prefix` | `subword` | `subwordSmart`.
  String? mode;

  /// `always` | `onHover` | `never`.
  String? showToolbar;

  bool? syntaxHighlightingEnabled;
  bool? suppressSuggestions;

  /// number
  num? minShowDelay;
  bool? suppressInSnippetMode;

  /// Does not clear active inline suggestions when the editor loses focus.
  bool? keepOnBlur;

  /// Font family for inline suggestions (`string` | `default`).
  String? fontFamily;

  IInlineSuggestEditsOptions? edits;

  /// @internal
  bool? triggerCommandOnProviderChange;

  /// @internal
  IInlineSuggestExperimentalOptions? experimental;
}

/// 1:1: the inline `edits?: { ... }` object literal of `IInlineSuggestOptions`.
class IInlineSuggestEditsOptions {
  IInlineSuggestEditsOptions({
    this.allowCodeShifting,
    this.renderSideBySide,
    this.showCollapsed,
    this.showLongDistanceHint,
    this.longDistanceHintContextLineCount,
    this.enabled,
  });

  /// `always` | `horizontal` | `never`.
  String? allowCodeShifting;

  /// `never` | `auto`.
  String? renderSideBySide;

  bool? showCollapsed;
  bool? showLongDistanceHint;

  /// number
  num? longDistanceHintContextLineCount;

  /// @internal
  bool? enabled;
}

/// 1:1: the inline `experimental?: { ... }` object literal of
/// `IInlineSuggestOptions`.
class IInlineSuggestExperimentalOptions {
  IInlineSuggestExperimentalOptions({
    this.suppressInlineSuggestions,
    this.emptyResponseInformation,
    this.showOnSuggestConflict,
  });

  /// @internal
  String? suppressInlineSuggestions;

  /// @internal
  bool? emptyResponseInformation;

  /// `always` | `never` | `whenSuggestListIsIncomplete`.
  String? showOnSuggestConflict;
}

/// 1:1: the resolved (required) carrier for `edits`.
/// `RequiredRecursive<IInlineSuggestOptions>['edits']`.
class InternalInlineSuggestEditsOptions {
  const InternalInlineSuggestEditsOptions({
    required this.enabled,
    required this.showCollapsed,
    required this.renderSideBySide,
    required this.allowCodeShifting,
    required this.showLongDistanceHint,
    required this.longDistanceHintContextLineCount,
  });

  final bool enabled;
  final bool showCollapsed;
  final String renderSideBySide;
  final String allowCodeShifting;
  final bool showLongDistanceHint;
  final num longDistanceHintContextLineCount;
}

/// 1:1: the resolved (required) carrier for `experimental`.
/// `RequiredRecursive<IInlineSuggestOptions>['experimental']`.
class InternalInlineSuggestExperimentalOptions {
  const InternalInlineSuggestExperimentalOptions({
    required this.suppressInlineSuggestions,
    required this.showOnSuggestConflict,
    required this.emptyResponseInformation,
  });

  final String suppressInlineSuggestions;
  final String showOnSuggestConflict;
  final bool emptyResponseInformation;
}

/// @internal
/// 1:1: `export type InternalInlineSuggestOptions = Readonly<RequiredRecursive<IInlineSuggestOptions>>` (source lines 4661–4667).
class InternalInlineSuggestOptions {
  const InternalInlineSuggestOptions({
    required this.enabled,
    required this.mode,
    required this.showToolbar,
    required this.suppressSuggestions,
    required this.keepOnBlur,
    required this.fontFamily,
    required this.syntaxHighlightingEnabled,
    required this.minShowDelay,
    required this.suppressInSnippetMode,
    required this.edits,
    required this.triggerCommandOnProviderChange,
    required this.experimental,
  });

  final bool enabled;
  final String mode;
  final String showToolbar;
  final bool suppressSuggestions;
  final bool keepOnBlur;
  final String fontFamily;
  final bool syntaxHighlightingEnabled;
  final num minShowDelay;
  final bool suppressInSnippetMode;
  final InternalInlineSuggestEditsOptions edits;
  final bool triggerCommandOnProviderChange;
  final InternalInlineSuggestExperimentalOptions experimental;
}

/// 1:1: `class InlineEditorSuggest extends BaseEditorOption<
/// EditorOption.inlineSuggest, IInlineSuggestOptions,
/// InternalInlineSuggestOptions>` (source lines 4670–4890). `V` is the
/// resolved carrier; like `EditorScrollbar`, the base `applyUpdate`/`compute`
/// are inherited unchanged (the source does not override them here).
class InlineEditorSuggest extends BaseEditorOption<InternalInlineSuggestOptions> {
  /// TS: `const defaults: InternalInlineSuggestOptions = { ... }`.
  static const InternalInlineSuggestOptions _defaults =
      InternalInlineSuggestOptions(
    enabled: true,
    mode: 'subwordSmart',
    showToolbar: 'onHover',
    suppressSuggestions: false,
    keepOnBlur: false,
    fontFamily: 'default',
    syntaxHighlightingEnabled: true,
    minShowDelay: 0,
    suppressInSnippetMode: true,
    edits: InternalInlineSuggestEditsOptions(
      enabled: true,
      showCollapsed: false,
      renderSideBySide: 'auto',
      allowCodeShifting: 'always',
      showLongDistanceHint: true,
      longDistanceHintContextLineCount: 0,
    ),
    triggerCommandOnProviderChange: false,
    experimental: InternalInlineSuggestExperimentalOptions(
      suppressInlineSuggestions: '',
      showOnSuggestConflict: 'never',
      emptyResponseInformation: true,
    ),
  );

  InlineEditorSuggest()
      : super(
          EditorOption.inlineSuggest,
          'inlineSuggest',
          _defaults,
          <String, Object?>{
            'editor.inlineSuggest.enabled': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.enabled,
              'description': localize('inlineSuggest.enabled',
                  'Controls whether to automatically show inline suggestions in the editor.'),
            },
            'editor.inlineSuggest.showToolbar': <String, Object?>{
              'type': 'string',
              'default': _defaults.showToolbar,
              'enum': <Object?>['always', 'onHover', 'never'],
              'enumDescriptions': <Object?>[
                localize('inlineSuggest.showToolbar.always',
                    'Show the inline suggestion toolbar whenever an inline suggestion is shown.'),
                localize('inlineSuggest.showToolbar.onHover',
                    'Show the inline suggestion toolbar when hovering over an inline suggestion.'),
                localize('inlineSuggest.showToolbar.never',
                    'Never show the inline suggestion toolbar.'),
              ],
              'description': localize('inlineSuggest.showToolbar',
                  'Controls when to show the inline suggestion toolbar.'),
            },
            'editor.inlineSuggest.syntaxHighlightingEnabled': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.syntaxHighlightingEnabled,
              'description': localize('inlineSuggest.syntaxHighlightingEnabled',
                  'Controls whether to show syntax highlighting for inline suggestions in the editor.'),
            },
            'editor.inlineSuggest.suppressSuggestions': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.suppressSuggestions,
              'description': localize('inlineSuggest.suppressSuggestions',
                  'Controls how inline suggestions interact with the suggest widget. If enabled, the suggest widget is not shown automatically when inline suggestions are available.'),
            },
            'editor.inlineSuggest.suppressInSnippetMode': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.suppressInSnippetMode,
              'description': localize('inlineSuggest.suppressInSnippetMode',
                  'Controls whether inline suggestions are suppressed when in snippet mode.'),
            },
            'editor.inlineSuggest.minShowDelay': <String, Object?>{
              'type': 'number',
              'default': 0,
              'minimum': 0,
              'maximum': 10000,
              'description': localize('inlineSuggest.minShowDelay',
                  'Controls the minimal delay in milliseconds after which inline suggestions are shown after typing.'),
            },
            'editor.inlineSuggest.experimental.suppressInlineSuggestions':
                <String, Object?>{
              'type': 'string',
              'default': _defaults.experimental.suppressInlineSuggestions,
              'tags': <Object?>['experimental'],
              'description': localize('inlineSuggest.suppressInlineSuggestions',
                  'Suppresses inline completions for specified extension IDs -- comma separated.'),
              'experiment': <String, Object?>{'mode': 'auto'},
            },
            'editor.inlineSuggest.experimental.emptyResponseInformation':
                <String, Object?>{
              'type': 'boolean',
              'default': _defaults.experimental.emptyResponseInformation,
              'tags': <Object?>['experimental'],
              'description': localize('inlineSuggest.emptyResponseInformation',
                  'Controls whether to send request information from the inline suggestion provider.'),
              'experiment': <String, Object?>{'mode': 'auto'},
            },
            'editor.inlineSuggest.triggerCommandOnProviderChange':
                <String, Object?>{
              'type': 'boolean',
              'default': _defaults.triggerCommandOnProviderChange,
              'tags': <Object?>['experimental'],
              'description': localize(
                  'inlineSuggest.triggerCommandOnProviderChange',
                  'Controls whether to trigger a command when the inline suggestion provider changes.'),
              'experiment': <String, Object?>{'mode': 'auto'},
            },
            'editor.inlineSuggest.experimental.showOnSuggestConflict':
                <String, Object?>{
              'type': 'string',
              'default': _defaults.experimental.showOnSuggestConflict,
              'tags': <Object?>['experimental'],
              'enum': <Object?>[
                'always',
                'never',
                'whenSuggestListIsIncomplete'
              ],
              'description': localize('inlineSuggest.showOnSuggestConflict',
                  'Controls whether to show inline suggestions when there is a suggest conflict.'),
              'experiment': <String, Object?>{'mode': 'auto'},
            },
            'editor.inlineSuggest.fontFamily': <String, Object?>{
              'type': 'string',
              'default': _defaults.fontFamily,
              'restricted': true,
              'description': localize('inlineSuggest.fontFamily',
                  'Controls the font family of the inline suggestions.'),
            },
            'editor.inlineSuggest.edits.allowCodeShifting': <String, Object?>{
              'type': 'string',
              'default': _defaults.edits.allowCodeShifting,
              'description': localize('inlineSuggest.edits.allowCodeShifting',
                  'Controls whether showing a suggestion will shift the code to make space for the suggestion inline.'),
              'enum': <Object?>['always', 'horizontal', 'never'],
              'tags': <Object?>['nextEditSuggestions'],
            },
            'editor.inlineSuggest.edits.showLongDistanceHint': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.edits.showLongDistanceHint,
              'description': localize('inlineSuggest.edits.showLongDistanceHint',
                  'Controls whether long distance inline suggestions are shown.'),
              'tags': <Object?>['nextEditSuggestions', 'experimental'],
            },
            'editor.inlineSuggest.edits.longDistanceHintContextLineCount':
                <String, Object?>{
              'type': 'number',
              'default': _defaults.edits.longDistanceHintContextLineCount,
              'minimum': 0,
              'maximum': 10,
              'description': localize(
                  'inlineSuggest.edits.longDistanceHintContextLineCount',
                  'Controls how many lines of surrounding context are shown above and below the target line in the long distance inline suggestion preview. Set to 0 to only show the target line.'),
              'tags': <Object?>['nextEditSuggestions', 'experimental'],
              'experiment': <String, Object?>{'mode': 'auto'},
            },
            'editor.inlineSuggest.edits.renderSideBySide': <String, Object?>{
              'type': 'string',
              'default': _defaults.edits.renderSideBySide,
              'description': localize('inlineSuggest.edits.renderSideBySide',
                  'Controls whether larger suggestions can be shown side by side.'),
              'enum': <Object?>['auto', 'never'],
              'enumDescriptions': <Object?>[
                localize('editor.inlineSuggest.edits.renderSideBySide.auto',
                    'Larger suggestions will show side by side if there is enough space, otherwise they will be shown below.'),
                localize('editor.inlineSuggest.edits.renderSideBySide.never',
                    'Larger suggestions are never shown side by side and will always be shown below.'),
              ],
              'tags': <Object?>['nextEditSuggestions'],
            },
            'editor.inlineSuggest.edits.showCollapsed': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.edits.showCollapsed,
              'description': localize('inlineSuggest.edits.showCollapsed',
                  'Controls whether the suggestion will show as collapsed until jumping to it.'),
              'tags': <Object?>['nextEditSuggestions'],
            },
          },
        );

  @override
  InternalInlineSuggestOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    final Map<Object?, Object?> input = _input as Map<Object?, Object?>;
    final InternalInlineSuggestOptions defaults = defaultValue;
    return InternalInlineSuggestOptions(
      enabled: boolean(input['enabled'], defaults.enabled),
      mode: stringSet<String>(
          input['mode'], defaults.mode, <String>['prefix', 'subword', 'subwordSmart']),
      showToolbar: stringSet<String>(input['showToolbar'], defaults.showToolbar,
          <String>['always', 'onHover', 'never']),
      suppressSuggestions: boolean(
          input['suppressSuggestions'], defaults.suppressSuggestions),
      keepOnBlur: boolean(input['keepOnBlur'], defaults.keepOnBlur),
      fontFamily: EditorStringOption.string(
          input['fontFamily'], defaults.fontFamily),
      syntaxHighlightingEnabled: boolean(
          input['syntaxHighlightingEnabled'], defaults.syntaxHighlightingEnabled),
      // Source uses the literal default 0 here (not `defaults.minShowDelay`).
      minShowDelay: EditorIntOption.clampedIntStatic(
          input['minShowDelay'], 0, 0, 10000) as num,
      suppressInSnippetMode: boolean(
          input['suppressInSnippetMode'], defaults.suppressInSnippetMode),
      edits: validateEdits(input['edits']),
      triggerCommandOnProviderChange: boolean(
          input['triggerCommandOnProviderChange'],
          defaults.triggerCommandOnProviderChange),
      experimental: validateExperimental(input['experimental']),
    );
  }

  /// Source-private instance method (`private _validateEdits`), kept with the
  /// same name so the truth harness / replay can probe it directly.
  InternalInlineSuggestEditsOptions validateEdits(Object? _input) {
    if (_input is! Map) {
      return defaultValue.edits;
    }
    final Map<Object?, Object?> input = _input as Map<Object?, Object?>;
    final InternalInlineSuggestEditsOptions defaults = defaultValue.edits;
    return InternalInlineSuggestEditsOptions(
      enabled: boolean(input['enabled'], defaults.enabled),
      showCollapsed: boolean(input['showCollapsed'], defaults.showCollapsed),
      allowCodeShifting: stringSet<String>(input['allowCodeShifting'],
          defaults.allowCodeShifting,
          <String>['always', 'horizontal', 'never']),
      showLongDistanceHint: boolean(
          input['showLongDistanceHint'], defaults.showLongDistanceHint),
      longDistanceHintContextLineCount: EditorIntOption.clampedIntStatic(
          input['longDistanceHintContextLineCount'],
          defaults.longDistanceHintContextLineCount,
          0,
          10) as num,
      renderSideBySide: stringSet<String>(input['renderSideBySide'],
          defaults.renderSideBySide, <String>['never', 'auto']),
    );
  }

  /// Source-private instance method (`private _validateExperimental`), kept
  /// with the same name so the truth harness / replay can probe it directly.
  InternalInlineSuggestExperimentalOptions validateExperimental(Object? _input) {
    if (_input is! Map) {
      return defaultValue.experimental;
    }
    final Map<Object?, Object?> input = _input as Map<Object?, Object?>;
    final InternalInlineSuggestExperimentalOptions defaults =
        defaultValue.experimental;
    return InternalInlineSuggestExperimentalOptions(
      suppressInlineSuggestions: EditorStringOption.string(
          input['suppressInlineSuggestions'],
          defaults.suppressInlineSuggestions),
      showOnSuggestConflict: stringSet<String>(
          input['showOnSuggestConflict'],
          defaults.showOnSuggestConflict,
          <String>['always', 'never', 'whenSuggestListIsIncomplete']),
      emptyResponseInformation: boolean(input['emptyResponseInformation'],
          defaults.emptyResponseInformation),
    );
  }
}

//#endregion

//#region bracketPairColorization

/// 1:1: `export interface IBracketPairColorizationOptions` (source lines
/// 4896–4906).
class IBracketPairColorizationOptions {
  IBracketPairColorizationOptions({
    this.enabled,
    this.independentColorPoolPerBracketType,
  });

  /// Enable or disable bracket pair colorization.
  bool? enabled;

  /// Use independent color pool per bracket type.
  bool? independentColorPoolPerBracketType;
}

/// @internal
/// 1:1: `export type InternalBracketPairColorizationOptions = Readonly<Required<IBracketPairColorizationOptions>>` (source line 4911).
class InternalBracketPairColorizationOptions {
  const InternalBracketPairColorizationOptions({
    required this.enabled,
    required this.independentColorPoolPerBracketType,
  });

  final bool enabled;
  final bool independentColorPoolPerBracketType;
}

/// 1:1: `class BracketPairColorization extends BaseEditorOption<
/// EditorOption.bracketPairColorization, IBracketPairColorizationOptions,
/// InternalBracketPairColorizationOptions>` (source lines 4916–4950).
/// Like `InlineEditorSuggest`, the base `applyUpdate`/`compute` are inherited
/// unchanged (the source does not override them here).
class BracketPairColorization
    extends BaseEditorOption<InternalBracketPairColorizationOptions> {
  /// TS: `const defaults: InternalBracketPairColorizationOptions = { ... }`.
  /// Values come from `EDITOR_MODEL_DEFAULTS.bracketPairColorizationOptions`
  /// (`enabled: true`, `independentColorPoolPerBracketType: false`).
  static const InternalBracketPairColorizationOptions _defaults =
      InternalBracketPairColorizationOptions(
    enabled: true,
    independentColorPoolPerBracketType: false,
  );

  BracketPairColorization()
      : super(
          EditorOption.bracketPairColorization,
          'bracketPairColorization',
          _defaults,
          <String, Object?>{
            'editor.bracketPairColorization.enabled': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.enabled,
              'markdownDescription': localize(
                  'bracketPairColorization.enabled',
                  'Controls whether bracket pair colorization is enabled or not. Use {0} to override the bracket highlight colors.',
                  <Object?>['`#workbench.colorCustomizations#`']),
            },
            'editor.bracketPairColorization.independentColorPoolPerBracketType':
                <String, Object?>{
              'type': 'boolean',
              'default': _defaults.independentColorPoolPerBracketType,
              'description': localize(
                  'bracketPairColorization.independentColorPoolPerBracketType',
                  'Controls whether each bracket type has its own independent color pool.'),
            },
          },
        );

  @override
  InternalBracketPairColorizationOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    final Map<Object?, Object?> input = _input as Map<Object?, Object?>;
    final InternalBracketPairColorizationOptions defaults = defaultValue;
    return InternalBracketPairColorizationOptions(
      enabled: boolean(input['enabled'], defaults.enabled),
      independentColorPoolPerBracketType: boolean(
          input['independentColorPoolPerBracketType'],
          defaults.independentColorPoolPerBracketType),
    );
  }
}

//#endregion

//#region guides

/// 1:1: `export interface IGuidesOptions` (source lines 4956–4986).
/// String-literal unions `boolean | 'active'` / `boolean | 'always'` erase to
/// `Object` (both a `bool` and a `String` are carried).
class IGuidesOptions {
  IGuidesOptions({
    this.bracketPairs,
    this.bracketPairsHorizontal,
    this.highlightActiveBracketPair,
    this.indentation,
    this.highlightActiveIndentation,
  });

  /// `boolean | 'active'`. Enable rendering of bracket pair guides.
  Object? bracketPairs;

  /// `boolean | 'active'`. Enable rendering of vertical bracket pair guides.
  Object? bracketPairsHorizontal;

  /// Enable highlighting of the active bracket pair.
  bool? highlightActiveBracketPair;

  /// Enable rendering of indent guides.
  bool? indentation;

  /// `boolean | 'always'`. Enable highlighting of the active indent guide.
  Object? highlightActiveIndentation;
}

/// @internal
/// 1:1: `export type InternalGuidesOptions = Readonly<Required<IGuidesOptions>>` (source line 4991).
class InternalGuidesOptions {
  const InternalGuidesOptions({
    required this.bracketPairs,
    required this.bracketPairsHorizontal,
    required this.highlightActiveBracketPair,
    required this.indentation,
    required this.highlightActiveIndentation,
  });

  final Object bracketPairs;
  final Object bracketPairsHorizontal;
  final bool highlightActiveBracketPair;
  final bool indentation;
  final Object highlightActiveIndentation;
}

/// 1:1: `class GuideOptions extends BaseEditorOption<
/// EditorOption.guides, IGuidesOptions, InternalGuidesOptions>` (source lines
/// 4996–5072).
class GuideOptions extends BaseEditorOption<InternalGuidesOptions> {
  /// TS: `const defaults: InternalGuidesOptions = { ... }`.
  static const InternalGuidesOptions _defaults = InternalGuidesOptions(
    bracketPairs: false,
    bracketPairsHorizontal: 'active',
    highlightActiveBracketPair: true,
    indentation: true,
    highlightActiveIndentation: true,
  );

  GuideOptions()
      : super(
          EditorOption.guides,
          'guides',
          _defaults,
          <String, Object?>{
            'editor.guides.bracketPairs': <String, Object?>{
              'type': <Object?>['boolean', 'string'],
              'enum': <Object?>[true, 'active', false],
              'enumDescriptions': <Object?>[
                localize('editor.guides.bracketPairs.true',
                    'Enables bracket pair guides.'),
                localize('editor.guides.bracketPairs.active',
                    'Enables bracket pair guides only for the active bracket pair.'),
                localize('editor.guides.bracketPairs.false',
                    'Disables bracket pair guides.'),
              ],
              'default': _defaults.bracketPairs,
              'description': localize('editor.guides.bracketPairs',
                  'Controls whether bracket pair guides are enabled or not.'),
            },
            'editor.guides.bracketPairsHorizontal': <String, Object?>{
              'type': <Object?>['boolean', 'string'],
              'enum': <Object?>[true, 'active', false],
              'enumDescriptions': <Object?>[
                localize('editor.guides.bracketPairsHorizontal.true',
                    'Enables horizontal guides as addition to vertical bracket pair guides.'),
                localize('editor.guides.bracketPairsHorizontal.active',
                    'Enables horizontal guides only for the active bracket pair.'),
                localize('editor.guides.bracketPairsHorizontal.false',
                    'Disables horizontal bracket pair guides.'),
              ],
              'default': _defaults.bracketPairsHorizontal,
              'description': localize('editor.guides.bracketPairsHorizontal',
                  'Controls whether horizontal bracket pair guides are enabled or not.'),
            },
            'editor.guides.highlightActiveBracketPair': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.highlightActiveBracketPair,
              'description': localize('editor.guides.highlightActiveBracketPair',
                  'Controls whether the editor should highlight the active bracket pair.'),
            },
            'editor.guides.indentation': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.indentation,
              'description': localize('editor.guides.indentation',
                  'Controls whether the editor should render indent guides.'),
            },
            'editor.guides.highlightActiveIndentation': <String, Object?>{
              'type': <Object?>['boolean', 'string'],
              'enum': <Object?>[true, 'always', false],
              'enumDescriptions': <Object?>[
                localize('editor.guides.highlightActiveIndentation.true',
                    'Highlights the active indent guide.'),
                localize('editor.guides.highlightActiveIndentation.always',
                    'Highlights the active indent guide even if bracket guides are highlighted.'),
                localize('editor.guides.highlightActiveIndentation.false',
                    'Do not highlight the active indent guide.'),
              ],
              'default': _defaults.highlightActiveIndentation,
              'description': localize('editor.guides.highlightActiveIndentation',
                  'Controls whether the editor should highlight the active indent guide.'),
            },
          },
        );

  @override
  InternalGuidesOptions validate(Object? _input) {
    if (_input is! Map) {
      return defaultValue;
    }
    final Map<Object?, Object?> input = _input as Map<Object?, Object?>;
    final InternalGuidesOptions defaults = defaultValue;
    return InternalGuidesOptions(
      bracketPairs: primitiveSet<Object>(input['bracketPairs'],
          defaults.bracketPairs, <Object>[true, false, 'active']),
      bracketPairsHorizontal: primitiveSet<Object>(
          input['bracketPairsHorizontal'],
          defaults.bracketPairsHorizontal,
          <Object>[true, false, 'active']),
      highlightActiveBracketPair: boolean(input['highlightActiveBracketPair'],
          defaults.highlightActiveBracketPair),
      indentation: boolean(input['indentation'], defaults.indentation),
      highlightActiveIndentation: primitiveSet<Object>(
          input['highlightActiveIndentation'],
          defaults.highlightActiveIndentation,
          <Object>[true, false, 'always']),
    );
  }
}

//#endregion

//#region suggest

/// Configuration options for editor suggest widget.
/// 1:1: `export interface ISuggestOptions` (source lines 5089–5256).
class ISuggestOptions {
  ISuggestOptions({
    this.insertMode,
    this.filterGraceful,
    this.snippetsPreventQuickSuggestions,
    this.localityBonus,
    this.shareSuggestSelections,
    this.selectionMode,
    this.showIcons,
    this.showStatusBar,
    this.preview,
    this.previewMode,
    this.showInlineDetails,
    this.fitWidthToDetails,
    this.showMethods,
    this.showFunctions,
    this.showConstructors,
    this.showDeprecated,
    this.matchOnWordStartOnly,
    this.showFields,
    this.showVariables,
    this.showClasses,
    this.showStructs,
    this.showInterfaces,
    this.showModules,
    this.showProperties,
    this.showEvents,
    this.showOperators,
    this.showUnits,
    this.showValues,
    this.showConstants,
    this.showEnums,
    this.showEnumMembers,
    this.showKeywords,
    this.showWords,
    this.showColors,
    this.showFiles,
    this.showReferences,
    this.showFolders,
    this.showTypeParameters,
    this.showIssues,
    this.showUsers,
    this.showSnippets,
  });

  /// Overwrite word ends on accept. Default to false.
  String? insertMode;

  /// Enable graceful matching. Defaults to true.
  bool? filterGraceful;

  /// Prevent quick suggestions when a snippet is active. Defaults to true.
  bool? snippetsPreventQuickSuggestions;

  /// Favors words that appear close to the cursor.
  bool? localityBonus;

  /// Enable using global storage for remembering suggestions.
  bool? shareSuggestSelections;

  /// Select suggestions when triggered via quick suggest or trigger characters.
  String? selectionMode;

  /// Enable or disable icons in suggestions. Defaults to true.
  bool? showIcons;

  /// Enable or disable the suggest status bar.
  bool? showStatusBar;

  /// Enable or disable the rendering of the suggestion preview.
  bool? preview;

  /// Configures the mode of the preview.
  String? previewMode;

  /// Show details inline with the label. Defaults to true.
  bool? showInlineDetails;

  /// Grow the suggest widget's preferred width to fit the inline detail text
  /// so it is not truncated. Defaults to false. @internal
  bool? fitWidthToDetails;

  /// Show method-suggestions.
  bool? showMethods;

  /// Show function-suggestions.
  bool? showFunctions;

  /// Show constructor-suggestions.
  bool? showConstructors;

  /// Show deprecated-suggestions.
  bool? showDeprecated;

  /// Controls whether suggestions allow matches in the middle of the word
  /// instead of only at the beginning.
  bool? matchOnWordStartOnly;

  /// Show field-suggestions.
  bool? showFields;

  /// Show variable-suggestions.
  bool? showVariables;

  /// Show class-suggestions.
  bool? showClasses;

  /// Show struct-suggestions.
  bool? showStructs;

  /// Show interface-suggestions.
  bool? showInterfaces;

  /// Show module-suggestions.
  bool? showModules;

  /// Show property-suggestions.
  bool? showProperties;

  /// Show event-suggestions.
  bool? showEvents;

  /// Show operator-suggestions.
  bool? showOperators;

  /// Show unit-suggestions.
  bool? showUnits;

  /// Show value-suggestions.
  bool? showValues;

  /// Show constant-suggestions.
  bool? showConstants;

  /// Show enum-suggestions.
  bool? showEnums;

  /// Show enumMember-suggestions.
  bool? showEnumMembers;

  /// Show keyword-suggestions.
  bool? showKeywords;

  /// Show text-suggestions.
  bool? showWords;

  /// Show color-suggestions.
  bool? showColors;

  /// Show file-suggestions.
  bool? showFiles;

  /// Show reference-suggestions.
  bool? showReferences;

  /// Show folder-suggestions.
  bool? showFolders;

  /// Show typeParameter-suggestions.
  bool? showTypeParameters;

  /// Show issue-suggestions.
  bool? showIssues;

  /// Show user-suggestions.
  bool? showUsers;

  /// Show snippet-suggestions.
  bool? showSnippets;
}

/// @internal
/// 1:1: `export type InternalSuggestOptions = Readonly<Required<ISuggestOptions>>` (source line 5261).
class InternalSuggestOptions {
  const InternalSuggestOptions({
    required this.insertMode,
    required this.filterGraceful,
    required this.snippetsPreventQuickSuggestions,
    required this.localityBonus,
    required this.shareSuggestSelections,
    required this.selectionMode,
    required this.showIcons,
    required this.showStatusBar,
    required this.preview,
    required this.previewMode,
    required this.showInlineDetails,
    required this.fitWidthToDetails,
    required this.showMethods,
    required this.showFunctions,
    required this.showConstructors,
    required this.showDeprecated,
    required this.matchOnWordStartOnly,
    required this.showFields,
    required this.showVariables,
    required this.showClasses,
    required this.showStructs,
    required this.showInterfaces,
    required this.showModules,
    required this.showProperties,
    required this.showEvents,
    required this.showOperators,
    required this.showUnits,
    required this.showValues,
    required this.showConstants,
    required this.showEnums,
    required this.showEnumMembers,
    required this.showKeywords,
    required this.showWords,
    required this.showColors,
    required this.showFiles,
    required this.showReferences,
    required this.showFolders,
    required this.showTypeParameters,
    required this.showIssues,
    required this.showUsers,
    required this.showSnippets,
  });

  final String insertMode;
  final bool filterGraceful;
  final bool snippetsPreventQuickSuggestions;
  final bool localityBonus;
  final bool shareSuggestSelections;
  final String selectionMode;
  final bool showIcons;
  final bool showStatusBar;
  final bool preview;
  final String previewMode;
  final bool showInlineDetails;
  final bool fitWidthToDetails;
  final bool showMethods;
  final bool showFunctions;
  final bool showConstructors;
  final bool showDeprecated;
  final bool matchOnWordStartOnly;
  final bool showFields;
  final bool showVariables;
  final bool showClasses;
  final bool showStructs;
  final bool showInterfaces;
  final bool showModules;
  final bool showProperties;
  final bool showEvents;
  final bool showOperators;
  final bool showUnits;
  final bool showValues;
  final bool showConstants;
  final bool showEnums;
  final bool showEnumMembers;
  final bool showKeywords;
  final bool showWords;
  final bool showColors;
  final bool showFiles;
  final bool showReferences;
  final bool showFolders;
  final bool showTypeParameters;
  final bool showIssues;
  final bool showUsers;
  final bool showSnippets;
}

/// 1:1: `class EditorSuggest extends BaseEditorOption<
/// EditorOption.suggest, ISuggestOptions, InternalSuggestOptions>` (source
/// lines 5263–5581). Like the other option classes in this region, the base
/// `applyUpdate`/`compute` are inherited unchanged (the source does not
/// override them here).
class EditorSuggest extends BaseEditorOption<InternalSuggestOptions> {
  /// TS: `const defaults: InternalSuggestOptions = { ... }` (source lines
  /// 5266–5308).
  static const InternalSuggestOptions _defaults = InternalSuggestOptions(
    insertMode: 'insert',
    filterGraceful: true,
    snippetsPreventQuickSuggestions: false,
    localityBonus: false,
    shareSuggestSelections: false,
    selectionMode: 'always',
    showIcons: true,
    showStatusBar: false,
    preview: false,
    previewMode: 'subwordSmart',
    showInlineDetails: true,
    fitWidthToDetails: false,
    showMethods: true,
    showFunctions: true,
    showConstructors: true,
    showDeprecated: true,
    matchOnWordStartOnly: true,
    showFields: true,
    showVariables: true,
    showClasses: true,
    showStructs: true,
    showInterfaces: true,
    showModules: true,
    showProperties: true,
    showEvents: true,
    showOperators: true,
    showUnits: true,
    showValues: true,
    showConstants: true,
    showEnums: true,
    showEnumMembers: true,
    showKeywords: true,
    showWords: true,
    showColors: true,
    showFiles: true,
    showReferences: true,
    showFolders: true,
    showTypeParameters: true,
    showSnippets: true,
    showUsers: true,
    showIssues: true,
  );

  EditorSuggest()
      : super(
          EditorOption.suggest,
          'suggest',
          _defaults,
          <String, Object?>{
            'editor.suggest.insertMode': <String, Object?>{
              'type': 'string',
              'enum': <Object?>['insert', 'replace'],
              'enumDescriptions': <Object?>[
                localize('suggest.insertMode.insert',
                    'Insert suggestion without overwriting text right of the cursor.'),
                localize('suggest.insertMode.replace',
                    'Insert suggestion and overwrite text right of the cursor.'),
              ],
              'default': _defaults.insertMode,
              'description': localize('suggest.insertMode',
                  'Controls whether words are overwritten when accepting completions. Note that this depends on extensions opting into this feature.'),
            },
            'editor.suggest.filterGraceful': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.filterGraceful,
              'description': localize('suggest.filterGraceful',
                  'Controls whether filtering and sorting suggestions accounts for small typos.'),
            },
            'editor.suggest.localityBonus': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.localityBonus,
              'description': localize('suggest.localityBonus',
                  'Controls whether sorting favors words that appear close to the cursor.'),
            },
            'editor.suggest.shareSuggestSelections': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.shareSuggestSelections,
              'markdownDescription': localize('suggest.shareSuggestSelections',
                  'Controls whether remembered suggestion selections are shared between multiple workspaces and windows (needs `#editor.suggestSelection#`).'),
            },
            'editor.suggest.selectionMode': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'always',
                'never',
                'whenTriggerCharacter',
                'whenQuickSuggestion'
              ],
              'enumDescriptions': <Object?>[
                localize('suggest.insertMode.always',
                    'Always select a suggestion when automatically triggering IntelliSense.'),
                localize('suggest.insertMode.never',
                    'Never select a suggestion when automatically triggering IntelliSense.'),
                localize('suggest.insertMode.whenTriggerCharacter',
                    'Select a suggestion only when triggering IntelliSense from a trigger character.'),
                localize('suggest.insertMode.whenQuickSuggestion',
                    'Select a suggestion only when triggering IntelliSense as you type.'),
              ],
              'default': _defaults.selectionMode,
              'markdownDescription': localize('suggest.selectionMode',
                  'Controls whether a suggestion is selected when the widget shows. Note that this only applies to automatically triggered suggestions ({0} and {1}) and that a suggestion is always selected when explicitly invoked, e.g via `Ctrl+Space`.',
                  <Object?>[
                    '`#editor.quickSuggestions#`',
                    '`#editor.suggestOnTriggerCharacters#`'
                  ]),
            },
            'editor.suggest.snippetsPreventQuickSuggestions': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.snippetsPreventQuickSuggestions,
              'description': localize('suggest.snippetsPreventQuickSuggestions',
                  'Controls whether an active snippet prevents quick suggestions.'),
            },
            'editor.suggest.showIcons': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.showIcons,
              'description': localize('suggest.showIcons',
                  'Controls whether to show or hide icons in suggestions.'),
            },
            'editor.suggest.showStatusBar': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.showStatusBar,
              'description': localize('suggest.showStatusBar',
                  'Controls the visibility of the status bar at the bottom of the suggest widget.'),
            },
            'editor.suggest.preview': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.preview,
              'description': localize('suggest.preview',
                  'Controls whether to preview the suggestion outcome in the editor.'),
            },
            'editor.suggest.showInlineDetails': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.showInlineDetails,
              'description': localize('suggest.showInlineDetails',
                  'Controls whether suggest details show inline with the label or only in the details widget.'),
            },
            'editor.suggest.filteredTypes': <String, Object?>{
              'type': 'object',
              'deprecationMessage': localize('deprecated',
                  "This setting is deprecated, please use separate settings like 'editor.suggest.showKeywords' or 'editor.suggest.showSnippets' instead."),
            },
            'editor.suggest.showMethods': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showMethods',
                  'When enabled IntelliSense shows `method`-suggestions.'),
            },
            'editor.suggest.showFunctions': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showFunctions',
                  'When enabled IntelliSense shows `function`-suggestions.'),
            },
            'editor.suggest.showConstructors': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showConstructors',
                  'When enabled IntelliSense shows `constructor`-suggestions.'),
            },
            'editor.suggest.showDeprecated': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showDeprecated',
                  'When enabled IntelliSense shows `deprecated`-suggestions.'),
            },
            'editor.suggest.matchOnWordStartOnly': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.matchOnWordStartOnly',
                  'When enabled IntelliSense filtering requires that the first character matches on a word start. For example, `c` on `Console` or `WebContext` but _not_ on `description`. When disabled IntelliSense will show more results but still sorts them by match quality.'),
            },
            'editor.suggest.showFields': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showFields',
                  'When enabled IntelliSense shows `field`-suggestions.'),
            },
            'editor.suggest.showVariables': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showVariables',
                  'When enabled IntelliSense shows `variable`-suggestions.'),
            },
            'editor.suggest.showClasses': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showClasss',
                  'When enabled IntelliSense shows `class`-suggestions.'),
            },
            'editor.suggest.showStructs': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showStructs',
                  'When enabled IntelliSense shows `struct`-suggestions.'),
            },
            'editor.suggest.showInterfaces': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showInterfaces',
                  'When enabled IntelliSense shows `interface`-suggestions.'),
            },
            'editor.suggest.showModules': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showModules',
                  'When enabled IntelliSense shows `module`-suggestions.'),
            },
            'editor.suggest.showProperties': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showPropertys',
                  'When enabled IntelliSense shows `property`-suggestions.'),
            },
            'editor.suggest.showEvents': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showEvents',
                  'When enabled IntelliSense shows `event`-suggestions.'),
            },
            'editor.suggest.showOperators': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showOperators',
                  'When enabled IntelliSense shows `operator`-suggestions.'),
            },
            'editor.suggest.showUnits': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showUnits',
                  'When enabled IntelliSense shows `unit`-suggestions.'),
            },
            'editor.suggest.showValues': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showValues',
                  'When enabled IntelliSense shows `value`-suggestions.'),
            },
            'editor.suggest.showConstants': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showConstants',
                  'When enabled IntelliSense shows `constant`-suggestions.'),
            },
            'editor.suggest.showEnums': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showEnums',
                  'When enabled IntelliSense shows `enum`-suggestions.'),
            },
            'editor.suggest.showEnumMembers': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showEnumMembers',
                  'When enabled IntelliSense shows `enumMember`-suggestions.'),
            },
            'editor.suggest.showKeywords': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showKeywords',
                  'When enabled IntelliSense shows `keyword`-suggestions.'),
            },
            'editor.suggest.showWords': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showTexts',
                  'When enabled IntelliSense shows `text`-suggestions.'),
            },
            'editor.suggest.showColors': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showColors',
                  'When enabled IntelliSense shows `color`-suggestions.'),
            },
            'editor.suggest.showFiles': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showFiles',
                  'When enabled IntelliSense shows `file`-suggestions.'),
            },
            'editor.suggest.showReferences': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showReferences',
                  'When enabled IntelliSense shows `reference`-suggestions.'),
            },
            'editor.suggest.showCustomcolors': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showCustomcolors',
                  'When enabled IntelliSense shows `customcolor`-suggestions.'),
            },
            'editor.suggest.showFolders': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showFolders',
                  'When enabled IntelliSense shows `folder`-suggestions.'),
            },
            'editor.suggest.showTypeParameters': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showTypeParameters',
                  'When enabled IntelliSense shows `typeParameter`-suggestions.'),
            },
            'editor.suggest.showSnippets': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showSnippets',
                  'When enabled IntelliSense shows `snippet`-suggestions.'),
            },
            'editor.suggest.showUsers': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showUsers',
                  'When enabled IntelliSense shows `user`-suggestions.'),
            },
            'editor.suggest.showIssues': <String, Object?>{
              'type': 'boolean',
              'default': true,
              'markdownDescription': localize('editor.suggest.showIssues',
                  'When enabled IntelliSense shows `issues`-suggestions.'),
            }
          },
        );

  @override
  InternalSuggestOptions validate(Object? _input) {
    // JS `typeof [] === 'object'`, so the source's object branch also runs for
    // arrays (all named properties missing). A Dart `List` is not a `Map`, so
    // mirror that path with an empty carrier; the result equals `validate({})`.
    final Object? inputValue = _input is List ? <Object?, Object?>{} : _input;
    if (inputValue is! Map) {
      return defaultValue;
    }
    final Map<Object?, Object?> input = inputValue as Map<Object?, Object?>;
    final InternalSuggestOptions defaults = defaultValue;
    return InternalSuggestOptions(
      insertMode: stringSet<String>(input['insertMode'], defaults.insertMode,
          <String>['insert', 'replace']),
      filterGraceful: boolean(input['filterGraceful'], defaults.filterGraceful),
      // 1:1: source uses `this.defaultValue.filterGraceful` here, not
      // `snippetsPreventQuickSuggestions` (faithful to the upstream source).
      snippetsPreventQuickSuggestions: boolean(
          input['snippetsPreventQuickSuggestions'], defaults.filterGraceful),
      localityBonus: boolean(input['localityBonus'], defaults.localityBonus),
      shareSuggestSelections: boolean(
          input['shareSuggestSelections'], defaults.shareSuggestSelections),
      selectionMode: stringSet<String>(
          input['selectionMode'],
          defaults.selectionMode,
          <String>[
            'always',
            'never',
            'whenQuickSuggestion',
            'whenTriggerCharacter'
          ]),
      showIcons: boolean(input['showIcons'], defaults.showIcons),
      showStatusBar: boolean(input['showStatusBar'], defaults.showStatusBar),
      preview: boolean(input['preview'], defaults.preview),
      previewMode: stringSet<String>(input['previewMode'], defaults.previewMode,
          <String>['prefix', 'subword', 'subwordSmart']),
      showInlineDetails:
          boolean(input['showInlineDetails'], defaults.showInlineDetails),
      fitWidthToDetails:
          boolean(input['fitWidthToDetails'], defaults.fitWidthToDetails),
      showMethods: boolean(input['showMethods'], defaults.showMethods),
      showFunctions: boolean(input['showFunctions'], defaults.showFunctions),
      showConstructors:
          boolean(input['showConstructors'], defaults.showConstructors),
      showDeprecated: boolean(input['showDeprecated'], defaults.showDeprecated),
      matchOnWordStartOnly:
          boolean(input['matchOnWordStartOnly'], defaults.matchOnWordStartOnly),
      showFields: boolean(input['showFields'], defaults.showFields),
      showVariables: boolean(input['showVariables'], defaults.showVariables),
      showClasses: boolean(input['showClasses'], defaults.showClasses),
      showStructs: boolean(input['showStructs'], defaults.showStructs),
      showInterfaces: boolean(input['showInterfaces'], defaults.showInterfaces),
      showModules: boolean(input['showModules'], defaults.showModules),
      showProperties: boolean(input['showProperties'], defaults.showProperties),
      showEvents: boolean(input['showEvents'], defaults.showEvents),
      showOperators: boolean(input['showOperators'], defaults.showOperators),
      showUnits: boolean(input['showUnits'], defaults.showUnits),
      showValues: boolean(input['showValues'], defaults.showValues),
      showConstants: boolean(input['showConstants'], defaults.showConstants),
      showEnums: boolean(input['showEnums'], defaults.showEnums),
      showEnumMembers:
          boolean(input['showEnumMembers'], defaults.showEnumMembers),
      showKeywords: boolean(input['showKeywords'], defaults.showKeywords),
      showWords: boolean(input['showWords'], defaults.showWords),
      showColors: boolean(input['showColors'], defaults.showColors),
      showFiles: boolean(input['showFiles'], defaults.showFiles),
      showReferences: boolean(input['showReferences'], defaults.showReferences),
      showFolders: boolean(input['showFolders'], defaults.showFolders),
      showTypeParameters:
          boolean(input['showTypeParameters'], defaults.showTypeParameters),
      showSnippets: boolean(input['showSnippets'], defaults.showSnippets),
      showUsers: boolean(input['showUsers'], defaults.showUsers),
      showIssues: boolean(input['showIssues'], defaults.showIssues),
    );
  }
}

//#endregion

//#region smart select

/// 1:1: `export interface ISmartSelectOptions` (source lines 5588–5591).
class ISmartSelectOptions {
  ISmartSelectOptions({
    this.selectLeadingAndTrailingWhitespace,
    this.selectSubwords,
  });

  bool? selectLeadingAndTrailingWhitespace;
  bool? selectSubwords;
}

/// @internal
/// 1:1: `export type SmartSelectOptions = Readonly<Required<ISmartSelectOptions>>`
/// (source line 5596).
class SmartSelectOptions {
  const SmartSelectOptions({
    required this.selectLeadingAndTrailingWhitespace,
    required this.selectSubwords,
  });

  final bool selectLeadingAndTrailingWhitespace;
  final bool selectSubwords;
}

/// 1:1: `class SmartSelect extends BaseEditorOption<EditorOption.smartSelect, ISmartSelectOptions, SmartSelectOptions>`
/// (source lines 5598–5630).
class SmartSelect extends BaseEditorOption<SmartSelectOptions> {
  /// TS: constructor defaults (source lines 5602–5605).
  static const SmartSelectOptions _defaults = SmartSelectOptions(
    selectLeadingAndTrailingWhitespace: true,
    selectSubwords: true,
  );

  SmartSelect()
      : super(
          EditorOption.smartSelect,
          'smartSelect',
          _defaults,
          <String, Object?>{
            'editor.smartSelect.selectLeadingAndTrailingWhitespace':
                <String, Object?>{
              'description': localize(
                  'selectLeadingAndTrailingWhitespace',
                  'Whether leading and trailing whitespace should always be selected.'),
              'default': true,
              'type': 'boolean',
            },
            'editor.smartSelect.selectSubwords': <String, Object?>{
              'description': localize('selectSubwords',
                  "Whether subwords (like 'foo' in 'fooBar' or 'foo_bar') should be selected."),
              'default': true,
              'type': 'boolean',
            },
          },
        );

  @override
  SmartSelectOptions validate(Object? _input) {
    // JS `typeof [] === 'object'`, so the source's object branch also runs for
    // arrays (all named properties missing). Mirror that with an empty map.
    final Object? inputValue = _input is List ? <Object?, Object?>{} : _input;
    if (inputValue is! Map) {
      return defaultValue;
    }
    final Map<Object?, Object?> input = inputValue as Map<Object?, Object?>;
    final SmartSelectOptions defaults = defaultValue;
    return SmartSelectOptions(
      selectLeadingAndTrailingWhitespace: boolean(
          input['selectLeadingAndTrailingWhitespace'],
          defaults.selectLeadingAndTrailingWhitespace),
      selectSubwords: boolean(input['selectSubwords'], defaults.selectSubwords),
    );
  }
}

//#endregion

//#region tabFocusMode

/// 1:1: `class EditorTabFocusMode extends EditorBooleanOption<EditorOption.tabFocusMode>`
/// (source lines 5636–5649). The inherited `validate` uses `boolean` and the
/// inherited schema mutation adds `type`/`default` (see `EditorBooleanOption`).
class EditorTabFocusMode extends EditorBooleanOption {
  EditorTabFocusMode()
      : super(
          EditorOption.tabFocusMode,
          'tabFocusMode',
          false,
          <String, Object?>{
            'markdownDescription': localize('tabFocusMode',
                'Controls whether the editor receives tabs or defers them to the workbench for navigation.'),
          },
        );

  @override
  bool compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, bool value) {
    return env.tabFocusMode;
  }
}

//#endregion

//#region wordSegmenterLocales

/// Base languages for which a full-ICU runtime (Node v22, the runtime used by
/// `tool/ts2dart/_batch229_truth.cjs`) reports word-break data through
/// `Intl.Segmenter.supportedLocalesOf`. Dart has no `Intl.Segmenter`, so this
/// set is the carrier for that runtime call; `batch229_truth.json` verifies it
/// against the real source for every locale exercised by the port.
///
/// 1:1 adaptation of `Intl.Segmenter.supportedLocalesOf(locale).length > 0`.
const Set<String> _icuSegmenterLanguages = <String>{
  'af', 'ak', 'am', 'ar', 'as', 'az', 'ba', 'be', 'bg', 'bm', 'bn', 'bo', 'br',
  'bs', 'ca', 'ce', 'cs', 'cv', 'cy', 'da', 'de', 'dz', 'ee', 'el', 'en', 'eo',
  'es', 'et', 'eu', 'fa', 'ff', 'fi', 'fo', 'fr', 'fy', 'ga', 'gd', 'gl', 'gu',
  'gv', 'ha', 'he', 'hi', 'hr', 'hu', 'hy', 'ia', 'id', 'ie', 'ig', 'ii', 'is',
  'it', 'ja', 'yi', 'jv', 'ka', 'ki', 'kk', 'kl', 'km', 'kn', 'ko', 'ks', 'ku',
  'kw', 'ky', 'lb', 'lg', 'ln', 'lo', 'lt', 'lu', 'lv', 'mg', 'mi', 'mk', 'ml',
  'mn', 'ro', 'mr', 'ms', 'mt', 'my', 'nb', 'nd', 'ne', 'nl', 'nn', 'no', 'oc',
  'om', 'or', 'os', 'pa', 'pl', 'ps', 'pt', 'qu', 'rm', 'rn', 'ru', 'rw', 'sa',
  'sc', 'sd', 'se', 'sg', 'sr', 'si', 'sk', 'sl', 'sn', 'so', 'sq', 'st', 'su',
  'sv', 'sw', 'ta', 'te', 'tg', 'th', 'ti', 'tk', 'fil', 'tl', 'tn', 'to',
  'tr', 'tt', 'ug', 'uk', 'ur', 'uz', 'vi', 'wo', 'xh', 'yo', 'za', 'zh', 'zu',
};

/// Returns the base language of a BCP 47 tag that ICU canonicalizes, or
/// `null` when `Intl.getCanonicalLocales` would throw. ICU rejects 3-letter
/// extlang/variant subtags (e.g. `zh-min-nan`, `en-GB-oed`), which is why a
/// 3-letter non-initial subtag is treated as malformed here.
String? _bcp47BaseLanguage(String tag) {
  if (tag.isEmpty) {
    return null;
  }
  final List<String> parts = tag.split('-');
  if (parts.any((String part) => part.isEmpty)) {
    return null;
  }
  final String language = parts[0];
  if (!RegExp(r'^[A-Za-z]{2,3}$').hasMatch(language) &&
      !RegExp(r'^[A-Za-z]{5,8}$').hasMatch(language)) {
    return null;
  }
  int i = 1;
  while (i < parts.length) {
    final String part = parts[i];
    if (RegExp(r'^[A-Za-z]{3}$').hasMatch(part)) {
      return null;
    }
    if (part.length == 1) {
      // Singleton: an extension (`u`, `a`, ...) or private use (`x`). Its
      // payload subtags are 2–8 alphanumeric.
      i++;
      while (i < parts.length &&
          RegExp(r'^[A-Za-z0-9]{2,8}$').hasMatch(parts[i])) {
        i++;
      }
      break;
    }
    if (!(RegExp(r'^[A-Za-z]{4}$').hasMatch(part) || // script
        RegExp(r'^[A-Za-z]{2}$').hasMatch(part) || // region
        RegExp(r'^[0-9]{3}$').hasMatch(part) || // numeric region
        RegExp(r'^[A-Za-z0-9]{5,8}$').hasMatch(part))) { // variant
      return null;
    }
    i++;
  }
  return language.toLowerCase();
}

/// 1:1: `Intl.Segmenter.supportedLocalesOf(locales)` as consumed by
/// `WordSegmenterLocales.validate` (only its length is observed). `undefined`
/// and non-string/non-array values yield an empty list in JS (or throw and are
/// swallowed by the source's `try`/`catch`), which all map to `[]` here.
List<String> _segmenterSupportedLocalesOf(Object? locales) {
  if (locales is! String && locales is! List) {
    return const <String>[];
  }
  final Iterable<Object?> requested =
      locales is String ? <Object?>[locales] : locales as List<Object?>;
  final List<String> result = <String>[];
  for (final Object? item in requested) {
    if (item is! String) {
      continue;
    }
    final String? base = _bcp47BaseLanguage(item);
    if (base != null && _icuSegmenterLanguages.contains(base)) {
      result.add(item);
    }
  }
  return result;
}

/// Locales used for segmenting lines into words when doing word related
/// navigations or operations.
///
/// Specify the BCP 47 language tag of the word you wish to recognize (e.g.,
/// ja, zh-CN, zh-Hant-TW, etc.).
/// 1:1: `class WordSegmenterLocales extends BaseEditorOption<EditorOption.wordSegmenterLocales, string | string[], string[]>`
/// (source lines 5662–5709).
class WordSegmenterLocales extends BaseEditorOption<List<String>> {
  /// TS: `const defaults: string[] = []` (source line 5664).
  static const List<String> _defaults = <String>[];

  WordSegmenterLocales()
      : super(
          EditorOption.wordSegmenterLocales,
          'wordSegmenterLocales',
          _defaults,
          <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'string',
              },
              <String, Object?>{
                'type': 'array',
                'items': <String, Object?>{
                  'type': 'string',
                },
              },
            ],
            'description': localize('wordSegmenterLocales',
                'Locales to be used for word segmentation when doing word related navigations or operations. Specify the BCP 47 language tag of the word you wish to recognize (e.g., ja, zh-CN, zh-Hant-TW, etc.).'),
            'type': 'array',
            'items': <String, Object?>{
              'type': 'string',
            },
            'default': _defaults,
          },
        );

  @override
  List<String> validate(Object? input) {
    Object? value = input;
    if (value is String) {
      value = <String>[value];
    }
    if (value is List) {
      final List<String> validLocales = <String>[];
      for (final Object? locale in value) {
        if (locale is String) {
          try {
            if (_segmenterSupportedLocalesOf(locale).isNotEmpty) {
              validLocales.add(locale);
            }
          } catch (_) {
            // ignore invalid locales
          }
        }
      }
      return validLocales;
    }
    return defaultValue;
  }
}

//#endregion

//#region wrappingIndent

/// Describes how to indent wrapped lines.
/// 1:1: `export const enum WrappingIndent` (source lines 5718–5735).
class WrappingIndent {
  /// No indentation => wrapped lines begin at column 1.
  static const int None = 0;
  /// Same => wrapped lines get the same indentation as the parent.
  static const int Same = 1;
  /// Indent => wrapped lines get +1 indentation toward the parent.
  static const int Indent = 2;
  /// DeepIndent => wrapped lines get +2 indentation toward the parent.
  static const int DeepIndent = 3;

  const WrappingIndent._();
}

/// 1:1: `class WrappingIndentOption extends BaseEditorOption<EditorOption.wrappingIndent, 'none' | 'same' | 'indent' | 'deepIndent', WrappingIndent>`
/// (source lines 5737–5777).
class WrappingIndentOption extends BaseEditorOption<int> {
  WrappingIndentOption()
      : super(
          EditorOption.wrappingIndent,
          'wrappingIndent',
          WrappingIndent.Same,
          <String, Object?>{
            'editor.wrappingIndent': <String, Object?>{
              'type': 'string',
              'enum': <Object?>['none', 'same', 'indent', 'deepIndent'],
              'enumDescriptions': <Object?>[
                localize('wrappingIndent.none',
                    'No indentation. Wrapped lines begin at column 1.'),
                localize('wrappingIndent.same',
                    'Wrapped lines get the same indentation as the parent.'),
                localize('wrappingIndent.indent',
                    'Wrapped lines get +1 indentation toward the parent.'),
                localize('wrappingIndent.deepIndent',
                    'Wrapped lines get +2 indentation toward the parent.'),
              ],
              'description': localize(
                  'wrappingIndent', 'Controls the indentation of wrapped lines.'),
              'default': 'same',
            },
          },
        );

  @override
  int validate(Object? input) {
    if (input == 'none') return WrappingIndent.None;
    if (input == 'same') return WrappingIndent.Same;
    if (input == 'indent') return WrappingIndent.Indent;
    if (input == 'deepIndent') return WrappingIndent.DeepIndent;
    return WrappingIndent.Same;
  }

  @override
  int compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, int value) {
    final Object? accessibilitySupport =
        options.get(EditorOption.accessibilitySupport);
    if (accessibilitySupport == AccessibilitySupport.Enabled) {
      // if we know for a fact that a screen reader is attached, we use no indent wrapping to
      // help that the editor's wrapping points match the textarea's wrapping points
      return WrappingIndent.None;
    }
    return value;
  }
}

//#endregion

//#region wrappingInfo

/// 1:1: `export interface EditorWrappingInfo` (source lines 5783–5788).
class EditorWrappingInfo {
  const EditorWrappingInfo({
    required this.isDominatedByLongLines,
    required this.isWordWrapMinified,
    required this.isViewportWrapping,
    required this.wrappingColumn,
  });

  final bool isDominatedByLongLines;
  final bool isWordWrapMinified;
  final bool isViewportWrapping;
  final num wrappingColumn;
}

/// 1:1: `class EditorWrappingInfoComputer extends ComputedEditorOption<EditorOption.wrappingInfo, EditorWrappingInfo>`
/// (source lines 5790–5811). A computed option: its output is derived from
/// `env.isDominatedByLongLines` plus the computed `layoutInfo` option.
class EditorWrappingInfoComputer extends ComputedEditorOption<EditorWrappingInfo> {
  static const EditorWrappingInfo _defaults = EditorWrappingInfo(
    isDominatedByLongLines: false,
    isWordWrapMinified: false,
    isViewportWrapping: false,
    wrappingColumn: -1,
  );

  EditorWrappingInfoComputer() : super(EditorOption.wrappingInfo, _defaults);

  @override
  EditorWrappingInfo compute(IEnvironmentalOptions env,
      IComputedEditorOptions options, EditorWrappingInfo _) {
    final EditorLayoutInfo layoutInfo =
        options.get(EditorOption.layoutInfo) as EditorLayoutInfo;
    return EditorWrappingInfo(
      isDominatedByLongLines: env.isDominatedByLongLines,
      isWordWrapMinified: layoutInfo.isWordWrapMinified,
      isViewportWrapping: layoutInfo.isViewportWrapping,
      wrappingColumn: layoutInfo.wrappingColumn,
    );
  }
}

//#endregion

//#region dropIntoEditor

/// Configuration options for editor drop into behavior.
/// 1:1: `export interface IDropIntoEditorOptions` (source lines 5820–5832).
class IDropIntoEditorOptions {
  IDropIntoEditorOptions({this.enabled, this.showDropSelector});

  /// Enable dropping into editor. Defaults to true.
  bool? enabled;

  /// Controls if a widget is shown after a drop. Defaults to 'afterDrop'.
  String? showDropSelector;
}

/// @internal
/// 1:1: `export type EditorDropIntoEditorOptions = Readonly<Required<IDropIntoEditorOptions>>`
/// (source line 5837).
class EditorDropIntoEditorOptions {
  const EditorDropIntoEditorOptions({
    required this.enabled,
    required this.showDropSelector,
  });

  final bool enabled;
  final String showDropSelector;
}

/// 1:1: `class EditorDropIntoEditor extends BaseEditorOption<EditorOption.dropIntoEditor, IDropIntoEditorOptions, EditorDropIntoEditorOptions>`
/// (source lines 5839–5878).
class EditorDropIntoEditor extends BaseEditorOption<EditorDropIntoEditorOptions> {
  static const EditorDropIntoEditorOptions _defaults =
      EditorDropIntoEditorOptions(enabled: true, showDropSelector: 'afterDrop');

  EditorDropIntoEditor()
      : super(
          EditorOption.dropIntoEditor,
          'dropIntoEditor',
          _defaults,
          <String, Object?>{
            'editor.dropIntoEditor.enabled': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.enabled,
              'markdownDescription': localize(
                  'dropIntoEditor.enabled',
                  'Controls whether you can drag and drop a file into a text editor by holding down the `Shift` key (instead of opening the file in an editor).'),
            },
            'editor.dropIntoEditor.showDropSelector': <String, Object?>{
              'type': 'string',
              'markdownDescription': localize(
                  'dropIntoEditor.showDropSelector',
                  'Controls if a widget is shown when dropping files into the editor. This widget lets you control how the file is dropped.'),
              'enum': <Object?>['afterDrop', 'never'],
              'enumDescriptions': <Object?>[
                localize(
                    'dropIntoEditor.showDropSelector.afterDrop',
                    'Show the drop selector widget after a file is dropped into the editor.'),
                localize(
                    'dropIntoEditor.showDropSelector.never',
                    'Never show the drop selector widget. Instead the default drop provider is always used.'),
              ],
              'default': 'afterDrop',
            },
          },
        );

  @override
  EditorDropIntoEditorOptions validate(Object? _input) {
    // JS `typeof [] === 'object'`, so the source's object branch also runs for
    // arrays (all named properties missing). Mirror that with an empty map.
    final Object? inputValue = _input is List ? <Object?, Object?>{} : _input;
    if (inputValue is! Map) {
      return defaultValue;
    }
    final Map<Object?, Object?> input = inputValue as Map<Object?, Object?>;
    final EditorDropIntoEditorOptions defaults = defaultValue;
    return EditorDropIntoEditorOptions(
      enabled: boolean(input['enabled'], defaults.enabled),
      showDropSelector: stringSet<String>(input['showDropSelector'],
          defaults.showDropSelector, const <String>['afterDrop', 'never']),
    );
  }
}

//#endregion

//#region pasteAs

/// Configuration options for editor pasting as into behavior.
/// 1:1: `export interface IPasteAsOptions` (source lines 5887–5899).
class IPasteAsOptions {
  IPasteAsOptions({this.enabled, this.showPasteSelector});

  /// Enable paste as functionality in editors. Defaults to true.
  bool? enabled;

  /// Controls if a widget is shown after a drop. Defaults to 'afterPaste'.
  String? showPasteSelector;
}

/// @internal
/// 1:1: `export type EditorPasteAsOptions = Readonly<Required<IPasteAsOptions>>`
/// (source line 5904).
class EditorPasteAsOptions {
  const EditorPasteAsOptions({
    required this.enabled,
    required this.showPasteSelector,
  });

  final bool enabled;
  final String showPasteSelector;
}

/// 1:1: `class EditorPasteAs extends BaseEditorOption<EditorOption.pasteAs, IPasteAsOptions, EditorPasteAsOptions>`
/// (source lines 5906–5945).
class EditorPasteAs extends BaseEditorOption<EditorPasteAsOptions> {
  static const EditorPasteAsOptions _defaults =
      EditorPasteAsOptions(enabled: true, showPasteSelector: 'afterPaste');

  EditorPasteAs()
      : super(
          EditorOption.pasteAs,
          'pasteAs',
          _defaults,
          <String, Object?>{
            'editor.pasteAs.enabled': <String, Object?>{
              'type': 'boolean',
              'default': _defaults.enabled,
              'markdownDescription': localize(
                  'pasteAs.enabled',
                  'Controls whether you can paste content in different ways.'),
            },
            'editor.pasteAs.showPasteSelector': <String, Object?>{
              'type': 'string',
              'markdownDescription': localize(
                  'pasteAs.showPasteSelector',
                  'Controls if a widget is shown when pasting content in to the editor. This widget lets you control how the file is pasted.'),
              'enum': <Object?>['afterPaste', 'never'],
              'enumDescriptions': <Object?>[
                localize(
                    'pasteAs.showPasteSelector.afterPaste',
                    'Show the paste selector widget after content is pasted into the editor.'),
                localize(
                    'pasteAs.showPasteSelector.never',
                    'Never show the paste selector widget. Instead the default pasting behavior is always used.'),
              ],
              'default': 'afterPaste',
            },
          },
        );

  @override
  EditorPasteAsOptions validate(Object? _input) {
    // JS `typeof [] === 'object'`, so the source's object branch also runs for
    // arrays (all named properties missing). Mirror that with an empty map.
    final Object? inputValue = _input is List ? <Object?, Object?>{} : _input;
    if (inputValue is! Map) {
      return defaultValue;
    }
    final Map<Object?, Object?> input = inputValue as Map<Object?, Object?>;
    final EditorPasteAsOptions defaults = defaultValue;
    return EditorPasteAsOptions(
      enabled: boolean(input['enabled'], defaults.enabled),
      showPasteSelector: stringSet<String>(input['showPasteSelector'],
          defaults.showPasteSelector, const <String>['afterPaste', 'never']),
    );
  }
}

//#endregion

//#region EditorOptions (segment 4, slices 1-3 — source lines 6144-7102)

/// 1:1: `export const EditorOptions = { ... }` — slices 1-3, source lines
/// 6144–7102 (`acceptSuggestionOnCommitCharacter` through
/// `effectiveFullwidthCharacterWidth`).
///
/// Dart has no object-literal `const`, so each property is a `static final`
/// field initialized with `register(...)` exactly as in the source. Fields are
/// lazily initialized (Dart semantics), so the replay test touches every field
/// before asserting the registry's sparse layout; this does not change which
/// option lands at which `EditorOption.id`.
class EditorOptions {
  EditorOptions._();

  static final IEditorOption<bool> acceptSuggestionOnCommitCharacter = register(
      EditorBooleanOption(
          EditorOption.acceptSuggestionOnCommitCharacter,
          'acceptSuggestionOnCommitCharacter',
          true,
          <String, Object?>{
            'markdownDescription': localize(
                'acceptSuggestionOnCommitCharacter',
                'Controls whether suggestions should be accepted on commit characters. For example, in JavaScript, the semi-colon (`;`) can be a commit character that accepts a suggestion and types that character.'),
          }));

  static final IEditorOption<String> acceptSuggestionOnEnter = register(
      EditorStringEnumOption<String>(
          EditorOption.acceptSuggestionOnEnter,
          'acceptSuggestionOnEnter',
          'on',
          <String>['on', 'smart', 'off'],
          <String, Object?>{
            'markdownEnumDescriptions': <String>[
              '',
              localize(
                  'acceptSuggestionOnEnterSmart',
                  'Only accept a suggestion with `Enter` when it makes a textual change.'),
              '',
            ],
            'markdownDescription': localize(
                'acceptSuggestionOnEnter',
                'Controls whether suggestions should be accepted on `Enter`, in addition to `Tab`. Helps to avoid ambiguity between inserting new lines or accepting suggestions.'),
          }));

  static final IEditorOption<int> accessibilitySupport =
      register(EditorAccessibilitySupport());

  static final IEditorOption<num> accessibilityPageSize = register(
      EditorIntOption(
          EditorOption.accessibilityPageSize,
          'accessibilityPageSize',
          500,
          1,
          Constants.MAX_SAFE_SMALL_INTEGER,
          <String, Object?>{
            'description': localize(
                'accessibilityPageSize',
                'Controls the number of lines in the editor that can be read out by a screen reader at once. When we detect a screen reader we automatically set the default to be 500. Warning: this has a performance implication for numbers larger than the default.'),
            'tags': <String>['accessibility'],
          }));

  static final IEditorOption<bool> allowOverflow = register(EditorBooleanOption(
      EditorOption.allowOverflow, 'allowOverflow', true));

  static final IEditorOption<bool> allowVariableLineHeights = register(
      EditorBooleanOption(
          EditorOption.allowVariableLineHeights,
          'allowVariableLineHeights',
          true,
          <String, Object?>{
            'description': localize('allowVariableLineHeights',
                'Controls whether to allow using variable line heights in the editor.'),
          }));

  static final IEditorOption<bool> allowVariableFonts = register(
      EditorBooleanOption(
          EditorOption.allowVariableFonts,
          'allowVariableFonts',
          true,
          <String, Object?>{
            'description': localize('allowVariableFonts',
                'Controls whether to allow using variable fonts in the editor.'),
          }));

  static final IEditorOption<bool> allowVariableFontsInAccessibilityMode =
      register(EditorBooleanOption(
          EditorOption.allowVariableFontsInAccessibilityMode,
          'allowVariableFontsInAccessibilityMode',
          false,
          <String, Object?>{
            'description': localize(
                'allowVariableFontsInAccessibilityMode',
                'Controls whether to allow using variable fonts in the editor in the accessibility mode.'),
            'tags': <String>['accessibility'],
          }));

  static final IEditorOption<String> ariaLabel = register(EditorStringOption(
      EditorOption.ariaLabel,
      'ariaLabel',
      localize('editorViewAccessibleLabel', 'Editor content')));

  static final IEditorOption<bool> ariaRequired = register(EditorBooleanOption(
      EditorOption.ariaRequired, 'ariaRequired', false, null));

  static final IEditorOption<bool> screenReaderAnnounceInlineSuggestion =
      register(EditorBooleanOption(
          EditorOption.screenReaderAnnounceInlineSuggestion,
          'screenReaderAnnounceInlineSuggestion',
          true,
          <String, Object?>{
            'description': localize('screenReaderAnnounceInlineSuggestion',
                'Control whether inline suggestions are announced by a screen reader.'),
            'tags': <String>['accessibility'],
          }));

  static final IEditorOption<String> autoClosingBrackets = register(
      EditorStringEnumOption<String>(
          EditorOption.autoClosingBrackets,
          'autoClosingBrackets',
          'languageDefined',
          <String>[
            'always',
            'languageDefined',
            'beforeWhitespace',
            'never'
          ],
          <String, Object?>{
            'enumDescriptions': <String>[
              '',
              localize(
                  'editor.autoClosingBrackets.languageDefined',
                  'Use language configurations to determine when to autoclose brackets.'),
              localize(
                  'editor.autoClosingBrackets.beforeWhitespace',
                  'Autoclose brackets only when the cursor is to the left of whitespace.'),
              '',
            ],
            'description': localize(
                'autoClosingBrackets',
                'Controls whether the editor should automatically close brackets after the user adds an opening bracket.'),
          }));

  static final IEditorOption<String> autoClosingComments = register(
      EditorStringEnumOption<String>(
          EditorOption.autoClosingComments,
          'autoClosingComments',
          'languageDefined',
          <String>[
            'always',
            'languageDefined',
            'beforeWhitespace',
            'never'
          ],
          <String, Object?>{
            'enumDescriptions': <String>[
              '',
              localize(
                  'editor.autoClosingComments.languageDefined',
                  'Use language configurations to determine when to autoclose comments.'),
              localize(
                  'editor.autoClosingComments.beforeWhitespace',
                  'Autoclose comments only when the cursor is to the left of whitespace.'),
              '',
            ],
            'description': localize(
                'autoClosingComments',
                'Controls whether the editor should automatically close comments after the user adds an opening comment.'),
          }));

  static final IEditorOption<String> autoClosingDelete = register(
      EditorStringEnumOption<String>(
          EditorOption.autoClosingDelete,
          'autoClosingDelete',
          'auto',
          <String>['always', 'auto', 'never'],
          <String, Object?>{
            'enumDescriptions': <String>[
              '',
              localize(
                  'editor.autoClosingDelete.auto',
                  'Remove adjacent closing quotes or brackets only if they were automatically inserted.'),
              '',
            ],
            'description': localize('autoClosingDelete',
                'Controls whether the editor should remove adjacent closing quotes or brackets when deleting.'),
          }));

  static final IEditorOption<String> autoClosingOvertype = register(
      EditorStringEnumOption<String>(
          EditorOption.autoClosingOvertype,
          'autoClosingOvertype',
          'auto',
          <String>['always', 'auto', 'never'],
          <String, Object?>{
            'enumDescriptions': <String>[
              '',
              localize(
                  'editor.autoClosingOvertype.auto',
                  'Type over closing quotes or brackets only if they were automatically inserted.'),
              '',
            ],
            'description': localize('autoClosingOvertype',
                'Controls whether the editor should type over closing quotes or brackets.'),
          }));

  static final IEditorOption<String> autoClosingQuotes = register(
      EditorStringEnumOption<String>(
          EditorOption.autoClosingQuotes,
          'autoClosingQuotes',
          'languageDefined',
          <String>[
            'always',
            'languageDefined',
            'beforeWhitespace',
            'never'
          ],
          <String, Object?>{
            'enumDescriptions': <String>[
              '',
              localize('editor.autoClosingQuotes.languageDefined',
                  'Use language configurations to determine when to autoclose quotes.'),
              localize(
                  'editor.autoClosingQuotes.beforeWhitespace',
                  'Autoclose quotes only when the cursor is to the left of whitespace.'),
              '',
            ],
            'description': localize(
                'autoClosingQuotes',
                'Controls whether the editor should automatically close quotes after the user adds an opening quote.'),
          }));

  static final IEditorOption<int> autoIndent = register(EditorEnumOption<String,
      int>(
      EditorOption.autoIndent,
      'autoIndent',
      EditorAutoIndentStrategy.Full,
      'full',
      <String>['none', 'keep', 'brackets', 'advanced', 'full'],
      _autoIndentFromString,
      <String, Object?>{
        'enumDescriptions': <String>[
          localize('editor.autoIndent.none',
              "The editor will not insert indentation automatically."),
          localize('editor.autoIndent.keep',
              "The editor will keep the current line's indentation."),
          localize(
              'editor.autoIndent.brackets',
              "The editor will keep the current line's indentation and honor language defined brackets."),
          localize(
              'editor.autoIndent.advanced',
              "The editor will keep the current line's indentation, honor language defined brackets and invoke special onEnterRules defined by languages."),
          localize(
              'editor.autoIndent.full',
              "The editor will keep the current line's indentation, honor language defined brackets, invoke special onEnterRules defined by languages, and honor indentationRules defined by languages."),
        ],
        'description': localize('autoIndent',
            'Controls whether the editor should automatically adjust the indentation when users type, paste, move or indent lines.'),
      }));

  static final IEditorOption<bool> autoIndentOnPaste = register(
      EditorBooleanOption(
          EditorOption.autoIndentOnPaste,
          'autoIndentOnPaste',
          false,
          <String, Object?>{
            'description': localize('autoIndentOnPaste',
                'Controls whether the editor should automatically auto-indent the pasted content.'),
          }));

  static final IEditorOption<bool> autoIndentOnPasteWithinString = register(
      EditorBooleanOption(
          EditorOption.autoIndentOnPasteWithinString,
          'autoIndentOnPasteWithinString',
          true,
          <String, Object?>{
            'description': localize(
                'autoIndentOnPasteWithinString',
                'Controls whether the editor should automatically auto-indent the pasted content when pasted within a string. This takes effect when autoIndentOnPaste is true.'),
          }));

  static final IEditorOption<bool> automaticLayout = register(
      EditorBooleanOption(
          EditorOption.automaticLayout, 'automaticLayout', false));

  static final IEditorOption<String> autoSurround = register(
      EditorStringEnumOption<String>(
          EditorOption.autoSurround,
          'autoSurround',
          'languageDefined',
          <String>['languageDefined', 'quotes', 'brackets', 'never'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize(
                  'editor.autoSurround.languageDefined',
                  'Use language configurations to determine when to automatically surround selections.'),
              localize('editor.autoSurround.quotes',
                  'Surround with quotes but not brackets.'),
              localize('editor.autoSurround.brackets',
                  'Surround with brackets but not quotes.'),
              '',
            ],
            'description': localize('autoSurround',
                'Controls whether the editor should automatically surround selections when typing quotes or brackets.'),
          }));

  static final IEditorOption<Object?> bracketPairColorization =
      register(BracketPairColorization());

  static final IEditorOption<Object?> bracketPairGuides =
      register(GuideOptions());

  static final IEditorOption<bool> stickyTabStops = register(
      EditorBooleanOption(
          EditorOption.stickyTabStops,
          'stickyTabStops',
          false,
          <String, Object?>{
            'description': localize('stickyTabStops',
                'Emulate selection behavior of tab characters when using spaces for indentation. Selection will stick to tab stops.'),
          }));

  static final IEditorOption<bool> codeLens = register(EditorBooleanOption(
      EditorOption.codeLens,
      'codeLens',
      true,
      <String, Object?>{
        'description':
            localize('codeLens', 'Controls whether the editor shows CodeLens.'),
      }));

  static final IEditorOption<String> codeLensFontFamily = register(
      EditorStringOption(
          EditorOption.codeLensFontFamily,
          'codeLensFontFamily',
          '',
          <String, Object?>{
            'description': localize('codeLensFontFamily',
                'Controls the font family for CodeLens.'),
          }));

  static final IEditorOption<num> codeLensFontSize = register(EditorIntOption(
      EditorOption.codeLensFontSize,
      'codeLensFontSize',
      0,
      0,
      100,
      <String, Object?>{
        'type': 'number',
        'default': 0,
        'minimum': 0,
        'maximum': 100,
        'markdownDescription': localize('codeLensFontSize',
            'Controls the font size in pixels for CodeLens. When set to 0, 90% of `#editor.fontSize#` is used.'),
      }));

  static final IEditorOption<bool> colorDecorators = register(
      EditorBooleanOption(
          EditorOption.colorDecorators,
          'colorDecorators',
          true,
          <String, Object?>{
            'description': localize(
                'colorDecorators',
                'Controls whether the editor should render the inline color decorators and color picker.'),
          }));

  static final IEditorOption<String> colorDecoratorActivatedOn = register(
      EditorStringEnumOption<String>(
          EditorOption.colorDecoratorsActivatedOn,
          'colorDecoratorsActivatedOn',
          'clickAndHover',
          <String>['clickAndHover', 'hover', 'click'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize(
                  'editor.colorDecoratorActivatedOn.clickAndHover',
                  'Make the color picker appear both on click and hover of the color decorator'),
              localize(
                  'editor.colorDecoratorActivatedOn.hover',
                  'Make the color picker appear on hover of the color decorator'),
              localize(
                  'editor.colorDecoratorActivatedOn.click',
                  'Make the color picker appear on click of the color decorator'),
            ],
            'description': localize('colorDecoratorActivatedOn',
                'Controls the condition to make a color picker appear from a color decorator.'),
          }));

  static final IEditorOption<num> colorDecoratorsLimit = register(
      EditorIntOption(
          EditorOption.colorDecoratorsLimit,
          'colorDecoratorsLimit',
          500,
          1,
          1000000,
          <String, Object?>{
            'markdownDescription': localize('colorDecoratorsLimit',
                'Controls the max number of color decorators that can be rendered in an editor at once.'),
          }));

  static final IEditorOption<bool> columnSelection = register(
      EditorBooleanOption(
          EditorOption.columnSelection,
          'columnSelection',
          false,
          <String, Object?>{
            'description': localize('columnSelection',
                'Enable that the selection with the mouse and keys is doing column selection.'),
          }));

  static final IEditorOption<Object?> comments = register(EditorComments());

  static final IEditorOption<bool> contextmenu = register(EditorBooleanOption(
      EditorOption.contextmenu, 'contextmenu', true));

  static final IEditorOption<bool> copyWithSyntaxHighlighting = register(
      EditorBooleanOption(
          EditorOption.copyWithSyntaxHighlighting,
          'copyWithSyntaxHighlighting',
          true,
          <String, Object?>{
            'description': localize('copyWithSyntaxHighlighting',
                'Controls whether syntax highlighting should be copied into the clipboard.'),
          }));

  static final IEditorOption<int> cursorBlinking = register(
      EditorEnumOption<String, int>(
          EditorOption.cursorBlinking,
          'cursorBlinking',
          TextEditorCursorBlinkingStyle.Blink,
          'blink',
          <String>['blink', 'smooth', 'phase', 'expand', 'solid'],
          cursorBlinkingStyleFromString,
          <String, Object?>{
            'description':
                localize('cursorBlinking', 'Control the cursor animation style.'),
          }));

  static final IEditorOption<String> cursorSmoothCaretAnimation = register(
      EditorStringEnumOption<String>(
          EditorOption.cursorSmoothCaretAnimation,
          'cursorSmoothCaretAnimation',
          'off',
          <String>['off', 'explicit', 'on'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('cursorSmoothCaretAnimation.off',
                  'Smooth caret animation is disabled.'),
              localize(
                  'cursorSmoothCaretAnimation.explicit',
                  'Smooth caret animation is enabled only when the user moves the cursor with an explicit gesture.'),
              localize('cursorSmoothCaretAnimation.on',
                  'Smooth caret animation is always enabled.'),
            ],
            'description': localize('cursorSmoothCaretAnimation',
                'Controls whether the smooth caret animation should be enabled.'),
          }));

  static final IEditorOption<int> cursorStyle = register(
      EditorEnumOption<String, int>(
          EditorOption.cursorStyle,
          'cursorStyle',
          TextEditorCursorStyle.Line,
          'line',
          <String>[
            'line',
            'block',
            'underline',
            'line-thin',
            'block-outline',
            'underline-thin'
          ],
          cursorStyleFromString,
          <String, Object?>{
            'description': localize('cursorStyle',
                'Controls the cursor style in insert input mode.'),
          }));

  static final IEditorOption<int> overtypeCursorStyle = register(
      EditorEnumOption<String, int>(
          EditorOption.overtypeCursorStyle,
          'overtypeCursorStyle',
          TextEditorCursorStyle.Block,
          'block',
          <String>[
            'line',
            'block',
            'underline',
            'line-thin',
            'block-outline',
            'underline-thin'
          ],
          cursorStyleFromString,
          <String, Object?>{
            'description': localize('overtypeCursorStyle',
                'Controls the cursor style in overtype input mode.'),
          }));

  static final IEditorOption<num> cursorSurroundingLines = register(
      EditorIntOption(
          EditorOption.cursorSurroundingLines,
          'cursorSurroundingLines',
          0,
          0,
          Constants.MAX_SAFE_SMALL_INTEGER,
          <String, Object?>{
            'description': localize(
                'cursorSurroundingLines',
                "Controls the minimal number of visible leading lines (minimum 0) and trailing lines (minimum 1) surrounding the cursor. Known as 'scrollOff' or 'scrollOffset' in some other editors."),
          }));

  static final IEditorOption<String> cursorSurroundingLinesStyle = register(
      EditorStringEnumOption<String>(
          EditorOption.cursorSurroundingLinesStyle,
          'cursorSurroundingLinesStyle',
          'default',
          <String>['default', 'all'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize(
                  'cursorSurroundingLinesStyle.default',
                  '`cursorSurroundingLines` is enforced only when triggered via the keyboard or API.'),
              localize('cursorSurroundingLinesStyle.all',
                  '`cursorSurroundingLines` is enforced always.'),
            ],
            'markdownDescription': localize('cursorSurroundingLinesStyle',
                'Controls when `#editor.cursorSurroundingLines#` should be enforced.'),
          }));

  static final IEditorOption<num> cursorWidth = register(EditorIntOption(
      EditorOption.cursorWidth,
      'cursorWidth',
      0,
      0,
      Constants.MAX_SAFE_SMALL_INTEGER,
      <String, Object?>{
        'markdownDescription': localize('cursorWidth',
            'Controls the width of the cursor when `#editor.cursorStyle#` is set to `line`.'),
      }));

  static final IEditorOption<num> cursorHeight = register(EditorIntOption(
      EditorOption.cursorHeight,
      'cursorHeight',
      0,
      0,
      Constants.MAX_SAFE_SMALL_INTEGER,
      <String, Object?>{
        'markdownDescription': localize(
            'cursorHeight',
            "Controls the height of the cursor when `#editor.cursorStyle#` is set to `line`. Cursor's max height depends on line height."),
      }));

  static final IEditorOption<bool> disableLayerHinting = register(
      EditorBooleanOption(
          EditorOption.disableLayerHinting, 'disableLayerHinting', false));

  static final IEditorOption<bool> disableMonospaceOptimizations = register(
      EditorBooleanOption(EditorOption.disableMonospaceOptimizations,
          'disableMonospaceOptimizations', false));

  static final IEditorOption<bool> domReadOnly = register(EditorBooleanOption(
      EditorOption.domReadOnly, 'domReadOnly', false));

  static final IEditorOption<bool> doubleClickSelectsBlock = register(
      EditorBooleanOption(
          EditorOption.doubleClickSelectsBlock,
          'doubleClickSelectsBlock',
          true,
          <String, Object?>{
            'description': localize('doubleClickSelectsBlock',
                'Controls whether double-clicking next to a bracket or quote selects the content inside.'),
          }));

  static final IEditorOption<bool> dragAndDrop = register(EditorBooleanOption(
      EditorOption.dragAndDrop,
      'dragAndDrop',
      true,
      <String, Object?>{
        'description': localize('dragAndDrop',
            'Controls whether the editor should allow moving selections via drag and drop.'),
      }));

  static final IEditorOption<bool> emptySelectionClipboard =
      register(EditorEmptySelectionClipboard());

  static final IEditorOption<Object?> dropIntoEditor =
      register(EditorDropIntoEditor());

  static final IEditorOption<bool> editContext = register(EditorBooleanOption(
      EditorOption.editContext,
      'editContext',
      true,
      <String, Object?>{
        'description': localize('editContext',
            'Sets whether the EditContext API should be used instead of the text area to power input in the editor.'),
        'included': platform.isChrome || platform.isEdge || platform.isNative,
      }));

  static final IEditorOption<bool> renderRichScreenReaderContent = register(
      EditorBooleanOption(
          EditorOption.renderRichScreenReaderContent,
          'renderRichScreenReaderContent',
          false,
          <String, Object?>{
            'markdownDescription': localize(
                'renderRichScreenReaderContent',
                'Whether to render rich screen reader content when the `#editor.editContext#` setting is enabled.'),
          }));

  static final IEditorOption<Object?> stickyScroll =
      register(EditorStickyScroll());

  static final IEditorOption<String> experimentalGpuAcceleration = register(
      EditorStringEnumOption<String>(
          EditorOption.experimentalGpuAcceleration,
          'experimentalGpuAcceleration',
          'off',
          <String>['off', 'on'],
          <String, Object?>{
            'tags': <String>['experimental'],
            'enumDescriptions': <String>[
              localize('experimentalGpuAcceleration.off',
                  'Use regular DOM-based rendering.'),
              localize(
                  'experimentalGpuAcceleration.on', 'Use GPU acceleration.'),
            ],
            'description': localize('experimentalGpuAcceleration',
                'Controls whether to use the experimental GPU acceleration to render the editor.'),
          }));

  static final IEditorOption<String> experimentalWhitespaceRendering = register(
      EditorStringEnumOption<String>(
          EditorOption.experimentalWhitespaceRendering,
          'experimentalWhitespaceRendering',
          'svg',
          <String>['svg', 'font', 'off'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('experimentalWhitespaceRendering.svg',
                  'Use a new rendering method with svgs.'),
              localize('experimentalWhitespaceRendering.font',
                  'Use a new rendering method with font characters.'),
              localize('experimentalWhitespaceRendering.off',
                  'Use the stable rendering method.'),
            ],
            'description': localize('experimentalWhitespaceRendering',
                'Controls whether whitespace is rendered with a new, experimental method.'),
          }));

  static final IEditorOption<String> extraEditorClassName = register(
      EditorStringOption(
          EditorOption.extraEditorClassName, 'extraEditorClassName', ''));

  static final IEditorOption<num> fastScrollSensitivity = register(
      EditorFloatOption(
          EditorOption.fastScrollSensitivity,
          'fastScrollSensitivity',
          5,
          (num x) => x <= 0 ? 5 : x,
          <String, Object?>{
            'markdownDescription': localize('fastScrollSensitivity',
                'Scrolling speed multiplier when pressing `Alt`.'),
          }));

  static final IEditorOption<Object?> find = register(EditorFind());

  static final IEditorOption<bool> fixedOverflowWidgets = register(
      EditorBooleanOption(
          EditorOption.fixedOverflowWidgets, 'fixedOverflowWidgets', false));

  static final IEditorOption<bool> folding = register(EditorBooleanOption(
      EditorOption.folding,
      'folding',
      true,
      <String, Object?>{
        'description': localize(
            'folding', 'Controls whether the editor has code folding enabled.'),
      }));

  // ---- batch232: source lines 6500-6801 ------------------------------------

  static final IEditorOption<String> foldingStrategy = register(
      EditorStringEnumOption<String>(
          EditorOption.foldingStrategy,
          'foldingStrategy',
          'auto',
          <String>['auto', 'indentation'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize(
                  'foldingStrategy.auto',
                  'Use a language-specific folding strategy if available, else the indentation-based one.'),
              localize('foldingStrategy.indentation',
                  'Use the indentation-based folding strategy.'),
            ],
            'description': localize('foldingStrategy',
                'Controls the strategy for computing folding ranges.'),
          }));

  static final IEditorOption<bool> foldingHighlight = register(
      EditorBooleanOption(
          EditorOption.foldingHighlight,
          'foldingHighlight',
          true,
          <String, Object?>{
            'description': localize('foldingHighlight',
                'Controls whether the editor should highlight folded ranges.'),
          }));

  static final IEditorOption<bool> foldingImportsByDefault = register(
      EditorBooleanOption(
          EditorOption.foldingImportsByDefault,
          'foldingImportsByDefault',
          false,
          <String, Object?>{
            'description': localize('foldingImportsByDefault',
                'Controls whether the editor automatically collapses import ranges.'),
          }));

  static final IEditorOption<num> foldingMaximumRegions = register(
      EditorIntOption(
          EditorOption.foldingMaximumRegions,
          'foldingMaximumRegions',
          5000,
          10,
          65000,
          <String, Object?>{
            'description': localize(
                'foldingMaximumRegions',
                'The maximum number of foldable regions. Increasing this value may result in the editor becoming less responsive when the current source has a large number of foldable regions.'),
          }));

  static final IEditorOption<bool> unfoldOnClickAfterEndOfLine = register(
      EditorBooleanOption(
          EditorOption.unfoldOnClickAfterEndOfLine,
          'unfoldOnClickAfterEndOfLine',
          false,
          <String, Object?>{
            'description': localize('unfoldOnClickAfterEndOfLine',
                'Controls whether clicking on the empty content after a folded line will unfold the line.'),
          }));

  static final IEditorOption<String> fontFamily = register(EditorStringOption(
      EditorOption.fontFamily,
      'fontFamily',
      EDITOR_FONT_DEFAULTS.fontFamily,
      <String, Object?>{
        'description': localize('fontFamily', 'Controls the font family.'),
      }));

  static final IEditorOption<FontInfo> fontInfo =
      register(EditorFontInfo());

  static final IEditorOption<String> fontLigatures2 =
      register(EditorFontLigatures());

  static final IEditorOption<num> fontSize = register(EditorFontSize());

  static final IEditorOption<String> fontWeight = register(EditorFontWeight());

  static final IEditorOption<String> fontVariations =
      register(EditorFontVariations());

  static final IEditorOption<bool> formatOnPaste = register(
      EditorBooleanOption(
          EditorOption.formatOnPaste,
          'formatOnPaste',
          false,
          <String, Object?>{
            'description': localize('formatOnPaste',
                'Controls whether the editor should automatically format the pasted content. A formatter must be available and the formatter should be able to format a range in a document.'),
          }));

  static final IEditorOption<bool> formatOnType = register(
      EditorBooleanOption(
          EditorOption.formatOnType,
          'formatOnType',
          false,
          <String, Object?>{
            'description': localize('formatOnType',
                'Controls whether the editor should automatically format the line after typing.'),
          }));

  static final IEditorOption<String> fullwidthCharacterWidth = register(
      EditorStringEnumOption<String>(
          EditorOption.fullwidthCharacterWidth,
          'fullwidthCharacterWidth',
          'font',
          <String>['font', 'twoCells'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('fullwidthCharacterWidth.font',
                  'Render full-width characters using the width defined by the font.'),
              localize(
                  'fullwidthCharacterWidth.twoCells',
                  'Render full-width characters centered in exactly two character cells. Only applies to monospace fonts when font ligatures are disabled. Does not apply to multi codepoint full-width characters or to GPU rendering. This has a performance impact on line rendering.'),
            ],
            'description': localize('fullwidthCharacterWidth',
                'Controls the width used to render full-width characters.'),
          }));

  static final IEditorOption<bool> glyphMargin = register(EditorBooleanOption(
      EditorOption.glyphMargin,
      'glyphMargin',
      true,
      <String, Object?>{
        'description': localize('glyphMargin',
            'Controls whether the editor should render the vertical glyph margin. Glyph margin is mostly used for debugging.'),
      }));

  static final IEditorOption<Object?> gotoLocation =
      register(EditorGoToLocation());

  static final IEditorOption<bool> hideCursorInOverviewRuler = register(
      EditorBooleanOption(
          EditorOption.hideCursorInOverviewRuler,
          'hideCursorInOverviewRuler',
          false,
          <String, Object?>{
            'description': localize('hideCursorInOverviewRuler',
                'Controls whether the cursor should be hidden in the overview ruler.'),
          }));

  static final IEditorOption<Object?> hover = register(EditorHover());

  static final IEditorOption<bool> inDiffEditor = register(EditorBooleanOption(
      EditorOption.inDiffEditor, 'inDiffEditor', false));

  static final IEditorOption<bool> inertialScroll = register(
      EditorBooleanOption(
          EditorOption.inertialScroll,
          'inertialScroll',
          false,
          <String, Object?>{
            'description': localize('inertialScroll',
                'Make scrolling inertial - mostly useful with touchpad on linux.'),
          }));

  static final IEditorOption<num> letterSpacing = register(EditorFloatOption(
      EditorOption.letterSpacing,
      'letterSpacing',
      EDITOR_FONT_DEFAULTS.letterSpacing,
      (num x) => EditorFloatOption.clamp(x, -5, 20),
      <String, Object?>{
        'description': localize('letterSpacing',
            'Controls the letter spacing in pixels.'),
      }));

  static final IEditorOption<Object?> lightbulb = register(EditorLightbulb());

  static final IEditorOption<num> lineDecorationsWidth =
      register(EditorLineDecorationsWidth());

  static final IEditorOption<num> lineHeight = register(EditorLineHeight());

  static final IEditorOption<Object?> lineNumbers =
      register(EditorRenderLineNumbersOption());

  static final IEditorOption<num> lineNumbersMinChars = register(
      EditorIntOption(
          EditorOption.lineNumbersMinChars, 'lineNumbersMinChars', 5, 1, 300));

  static final IEditorOption<bool> linkedEditing = register(
      EditorBooleanOption(
          EditorOption.linkedEditing,
          'linkedEditing',
          false,
          <String, Object?>{
            'description': localize('linkedEditing',
                'Controls whether the editor has linked editing enabled. Depending on the language, related symbols such as HTML tags, are updated while editing.'),
          }));

  static final IEditorOption<bool> links = register(EditorBooleanOption(
      EditorOption.links,
      'links',
      true,
      <String, Object?>{
        'description': localize('links',
            'Controls whether the editor should detect links and make them clickable.'),
      }));

  static final IEditorOption<Object?> markdownImages =
      register(EditorMarkdownImages());

  static final IEditorOption<String> matchBrackets = register(
      EditorStringEnumOption<String>(
          EditorOption.matchBrackets,
          'matchBrackets',
          'always',
          <String>['always', 'near', 'never'],
          <String, Object?>{
            'description': localize(
                'matchBrackets', 'Highlight matching brackets.'),
          }));

  static final IEditorOption<Object?> minimap = register(EditorMinimap());

  static final IEditorOption<String> mouseStyle = register(
      EditorStringEnumOption<String>(EditorOption.mouseStyle, 'mouseStyle',
          'text', <String>['text', 'default', 'copy']));

  static final IEditorOption<num> mouseWheelScrollSensitivity = register(
      EditorFloatOption(
          EditorOption.mouseWheelScrollSensitivity,
          'mouseWheelScrollSensitivity',
          1,
          (num x) => x == 0 ? 1 : x,
          <String, Object?>{
            'markdownDescription': localize('mouseWheelScrollSensitivity',
                'A multiplier to be used on the `deltaX` and `deltaY` of mouse wheel scroll events.'),
          }));

  static final IEditorOption<bool> mouseWheelZoom = register(
      EditorBooleanOption(EditorOption.mouseWheelZoom, 'mouseWheelZoom', false,
          <String, Object?>{
            'markdownDescription': platform.isMacintosh
                ? localize('mouseWheelZoom.mac',
                    'Zoom the font of the editor when using mouse wheel and holding `Cmd`.')
                : localize('mouseWheelZoom',
                    'Zoom the font of the editor when using mouse wheel and holding `Ctrl`.'),
          }));

  static final IEditorOption<bool> multiCursorMergeOverlapping = register(
      EditorBooleanOption(
          EditorOption.multiCursorMergeOverlapping,
          'multiCursorMergeOverlapping',
          true,
          <String, Object?>{
            'description': localize('multiCursorMergeOverlapping',
                'Merge multiple cursors when they are overlapping.'),
          }));

  static final IEditorOption<String> multiCursorModifier = register(
      EditorEnumOption<String, String>(
          EditorOption.multiCursorModifier,
          'multiCursorModifier',
          'altKey',
          'alt',
          <String>['ctrlCmd', 'alt'],
          multiCursorModifierFromString,
          <String, Object?>{
            'markdownEnumDescriptions': <String>[
              localize('multiCursorModifier.ctrlCmd',
                  'Maps to `Control` on Windows and Linux and to `Command` on macOS.'),
              localize('multiCursorModifier.alt',
                  'Maps to `Alt` on Windows and Linux and to `Option` on macOS.'),
            ],
            'markdownDescription': localize(
                <String, Object?>{
                  'key': 'multiCursorModifier',
                  'comment': <String>[
                    '- `ctrlCmd` refers to a value the setting can take and should not be localized.',
                    '- `Control` and `Command` refer to the modifier keys Ctrl or Cmd on the keyboard and can be localized.'
                  ],
                },
                'The modifier to be used to add multiple cursors with the mouse. The Go to Definition and Open Link mouse gestures will adapt such that they do not conflict with the [multicursor modifier](https://code.visualstudio.com/docs/editor/codebasics#_multicursor-modifier).'),
          }));

  static final IEditorOption<String> mouseMiddleClickAction = register(
      EditorStringEnumOption<String>(
          EditorOption.mouseMiddleClickAction,
          'mouseMiddleClickAction',
          'default',
          <String>['default', 'openLink', 'ctrlLeftClick'],
          <String, Object?>{
            'description': localize('mouseMiddleClickAction',
                'Controls what happens when middle mouse button is clicked in the editor.'),
          }));

  static final IEditorOption<String> multiCursorPaste = register(
      EditorStringEnumOption<String>(
          EditorOption.multiCursorPaste,
          'multiCursorPaste',
          'spread',
          <String>['spread', 'full'],
          <String, Object?>{
            'markdownEnumDescriptions': <String>[
              localize('multiCursorPaste.spread',
                  'Each cursor pastes a single line of the text. When pasting column selections into a single cursor, each copied line is pasted on a successive destination line and padded with spaces to form a rectangle.'),
              localize('multiCursorPaste.full', 'Each cursor pastes the full text.'),
            ],
            'markdownDescription': localize('multiCursorPaste',
                'Controls pasting when the line count of the pasted text matches the cursor count, or when pasting column selections into a single cursor.'),
          }));

  static final IEditorOption<num> multiCursorLimit = register(EditorIntOption(
      EditorOption.multiCursorLimit,
      'multiCursorLimit',
      10000,
      1,
      100000,
      <String, Object?>{
        'markdownDescription': localize('multiCursorLimit',
            'Controls the max number of cursors that can be in an active editor at once.'),
      }));

  static final IEditorOption<String> occurrencesHighlight = register(
      EditorStringEnumOption<String>(
          EditorOption.occurrencesHighlight,
          'occurrencesHighlight',
          'singleFile',
          <String>['off', 'singleFile', 'multiFile'],
          <String, Object?>{
            'markdownEnumDescriptions': <String>[
              localize('occurrencesHighlight.off',
                  'Does not highlight occurrences.'),
              localize('occurrencesHighlight.singleFile',
                  'Highlights occurrences only in the current file.'),
              localize('occurrencesHighlight.multiFile',
                  'Experimental: Highlights occurrences across all valid open files.'),
            ],
            'markdownDescription': localize('occurrencesHighlight',
                'Controls whether occurrences should be highlighted across open files.'),
          }));

  static final IEditorOption<num> occurrencesHighlightDelay = register(
      EditorIntOption(
          EditorOption.occurrencesHighlightDelay,
          'occurrencesHighlightDelay',
          0,
          0,
          2000,
          <String, Object?>{
            'description': localize('occurrencesHighlightDelay',
                'Controls the delay in milliseconds after which occurrences are highlighted.'),
            'tags': <String>['preview'],
          }));

  static final IEditorOption<bool> occurrencesHighlightFromAllProviders =
      register(EditorBooleanOption(
          EditorOption.occurrencesHighlightFromAllProviders,
          'occurrencesHighlightFromAllProviders',
          false,
          <String, Object?>{
            'description': localize('occurrencesHighlightFromAllProviders',
                'Controls whether single-document highlights from all matching providers are merged. When enabled, basic word-based highlighting is only used if no other provider matches.'),
          }));

  static final IEditorOption<bool> overtypeOnPaste = register(
      EditorBooleanOption(
          EditorOption.overtypeOnPaste,
          'overtypeOnPaste',
          true,
          <String, Object?>{
            'description': localize(
                'overtypeOnPaste', 'Controls whether pasting should overtype.'),
          }));

  static final IEditorOption<bool> overviewRulerBorder = register(
      EditorBooleanOption(
          EditorOption.overviewRulerBorder,
          'overviewRulerBorder',
          true,
          <String, Object?>{
            'description': localize('overviewRulerBorder',
                'Controls whether a border should be drawn around the overview ruler.'),
          }));

  static final IEditorOption<num> overviewRulerLanes = register(
      EditorIntOption(
          EditorOption.overviewRulerLanes, 'overviewRulerLanes', 3, 0, 3));

  static final IEditorOption<Object?> padding = register(EditorPadding());

  static final IEditorOption<Object?> pasteAs = register(EditorPasteAs());

  static final IEditorOption<Object?> parameterHints =
      register(EditorParameterHints());

  static final IEditorOption<String> peekWidgetDefaultFocus = register(
      EditorStringEnumOption<String>(
          EditorOption.peekWidgetDefaultFocus,
          'peekWidgetDefaultFocus',
          'tree',
          <String>['tree', 'editor'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('peekWidgetDefaultFocus.tree',
                  'Focus the tree when opening peek'),
              localize('peekWidgetDefaultFocus.editor',
                  'Focus the editor when opening peek'),
            ],
            'description': localize('peekWidgetDefaultFocus',
                'Controls whether to focus the inline editor or the tree in the peek widget.'),
          }));

  static final IEditorOption<String?> placeholder =
      register(PlaceholderOption());

  static final IEditorOption<bool> definitionLinkOpensInPeek = register(
      EditorBooleanOption(
          EditorOption.definitionLinkOpensInPeek,
          'definitionLinkOpensInPeek',
          false,
          <String, Object?>{
            'description': localize('definitionLinkOpensInPeek',
                'Controls whether the Go to Definition mouse gesture always opens the peek widget.'),
          }));

  static final IEditorOption<Object?> quickSuggestions =
      register(EditorQuickSuggestions());

  static final IEditorOption<num> quickSuggestionsDelay = register(
      EditorIntOption(
          EditorOption.quickSuggestionsDelay,
          'quickSuggestionsDelay',
          10,
          0,
          Constants.MAX_SAFE_SMALL_INTEGER,
          <String, Object?>{
            'description': localize('quickSuggestionsDelay',
                'Controls the delay in milliseconds after which quick suggestions will show up.'),
            'experiment': <String, Object?>{'mode': 'auto'},
          }));

  static final IEditorOption<bool> readOnly = register(
      EditorBooleanOption(EditorOption.readOnly, 'readOnly', false));

  static final IEditorOption<Object?> readOnlyMessage =
      register(ReadonlyMessage());

  static final IEditorOption<bool> renameOnType = register(
      EditorBooleanOption(
          EditorOption.renameOnType,
          'renameOnType',
          false,
          <String, Object?>{
            'description': localize(
                'renameOnType', 'Controls whether the editor auto renames on type.'),
            'markdownDeprecationMessage': localize('renameOnTypeDeprecate',
                'Deprecated, use `#editor.linkedEditing#` instead.'),
          }));

  static final IEditorOption<bool> renderControlCharacters = register(
      EditorBooleanOption(
          EditorOption.renderControlCharacters,
          'renderControlCharacters',
          true,
          <String, Object?>{
            'description': localize('renderControlCharacters',
                'Controls whether the editor should render control characters.'),
            'restricted': true,
          }));

  static final IEditorOption<String> renderFinalNewline = register(
      EditorStringEnumOption<String>(
          EditorOption.renderFinalNewline,
          'renderFinalNewline',
          platform.isLinux ? 'dimmed' : 'on',
          <String>['off', 'on', 'dimmed'],
          <String, Object?>{
            'description': localize('renderFinalNewline',
                'Render last line number when the file ends with a newline.'),
          }));

  static final IEditorOption<String> renderLineHighlight = register(
      EditorStringEnumOption<String>(
          EditorOption.renderLineHighlight,
          'renderLineHighlight',
          'line',
          <String>['none', 'gutter', 'line', 'all'],
          <String, Object?>{
            'enumDescriptions': <String>[
              '',
              '',
              '',
              localize('renderLineHighlight.all',
                  'Highlights both the gutter and the current line.'),
            ],
            'description': localize('renderLineHighlight',
                'Controls how the editor should render the current line highlight.'),
          }));

  static final IEditorOption<bool> renderLineHighlightOnlyWhenFocus = register(
      EditorBooleanOption(
          EditorOption.renderLineHighlightOnlyWhenFocus,
          'renderLineHighlightOnlyWhenFocus',
          false,
          <String, Object?>{
            'description': localize('renderLineHighlightOnlyWhenFocus',
                'Controls if the editor should render the current line highlight only when the editor is focused.'),
          }));

  static final IEditorOption<String> renderValidationDecorations = register(
      EditorStringEnumOption<String>(EditorOption.renderValidationDecorations,
          'renderValidationDecorations', 'editable',
          <String>['editable', 'on', 'off']));

  static final IEditorOption<String> renderWhitespace = register(
      EditorStringEnumOption<String>(
          EditorOption.renderWhitespace,
          'renderWhitespace',
          'selection',
          <String>['none', 'boundary', 'selection', 'trailing', 'all'],
          <String, Object?>{
            'enumDescriptions': <String>[
              '',
              localize('renderWhitespace.boundary',
                  'Render whitespace characters except for single spaces between words.'),
              localize('renderWhitespace.selection',
                  'Render whitespace characters only on selected text.'),
              localize('renderWhitespace.trailing',
                  'Render only trailing whitespace characters.'),
              '',
            ],
            'description': localize('renderWhitespace',
                'Controls how the editor should render whitespace characters.'),
          }));

  static final IEditorOption<num> revealHorizontalRightPadding = register(
      EditorIntOption(EditorOption.revealHorizontalRightPadding,
          'revealHorizontalRightPadding', 15, 0, 1000));

  static final IEditorOption<bool> roundedSelection = register(
      EditorBooleanOption(
          EditorOption.roundedSelection,
          'roundedSelection',
          true,
          <String, Object?>{
            'description': localize('roundedSelection',
                'Controls whether selections should have rounded corners.'),
          }));

  // ---- batch233: source lines 6802-7102 ------------------------------------

  static final IEditorOption<List<IRulerOption>> rulers =
      register(EditorRulers());

  static final IEditorOption<InternalEditorScrollbarOptions> scrollbar =
      register(EditorScrollbar());

  static final IEditorOption<num> scrollBeyondLastColumn = register(
      EditorIntOption(
          EditorOption.scrollBeyondLastColumn,
          'scrollBeyondLastColumn',
          4,
          0,
          Constants.MAX_SAFE_SMALL_INTEGER,
          <String, Object?>{
            'description': localize('scrollBeyondLastColumn',
                'Controls the number of extra characters beyond which the editor will scroll horizontally.'),
          }));

  static final IEditorOption<bool> scrollBeyondLastLine = register(
      EditorBooleanOption(
          EditorOption.scrollBeyondLastLine,
          'scrollBeyondLastLine',
          true,
          <String, Object?>{
            'description': localize('scrollBeyondLastLine',
                'Controls whether the editor will scroll beyond the last line.'),
          }));

  static final IEditorOption<bool> scrollOnMiddleClick = register(
      EditorBooleanOption(
          EditorOption.scrollOnMiddleClick,
          'scrollOnMiddleClick',
          false,
          <String, Object?>{
            'description': localize('scrollOnMiddleClick',
                'Controls whether the editor will scroll when the middle button is pressed.'),
          }));

  static final IEditorOption<bool> scrollPredominantAxis = register(
      EditorBooleanOption(
          EditorOption.scrollPredominantAxis,
          'scrollPredominantAxis',
          true,
          <String, Object?>{
            'description': localize('scrollPredominantAxis',
                'Scroll only along the predominant axis when scrolling both vertically and horizontally at the same time. Prevents horizontal drift when scrolling vertically on a trackpad.'),
          }));

  static final IEditorOption<bool> selectionClipboard = register(
      EditorBooleanOption(
          EditorOption.selectionClipboard,
          'selectionClipboard',
          true,
          <String, Object?>{
            'description': localize('selectionClipboard',
                'Controls whether the Linux primary clipboard should be supported.'),
            'included': platform.isLinux,
          }));

  static final IEditorOption<bool> selectionHighlight = register(
      EditorBooleanOption(
          EditorOption.selectionHighlight,
          'selectionHighlight',
          true,
          <String, Object?>{
            'description': localize('selectionHighlight',
                'Controls whether the editor should highlight matches similar to the selection.'),
          }));

  static final IEditorOption<num> selectionHighlightMaxLength = register(
      EditorIntOption(
          EditorOption.selectionHighlightMaxLength,
          'selectionHighlightMaxLength',
          200,
          0,
          Constants.MAX_SAFE_SMALL_INTEGER,
          <String, Object?>{
            'description': localize('selectionHighlightMaxLength',
                'Controls how many characters can be in the selection before similar matches are not highlighted. Set to zero for unlimited.'),
          }));

  static final IEditorOption<bool> selectionHighlightMultiline = register(
      EditorBooleanOption(
          EditorOption.selectionHighlightMultiline,
          'selectionHighlightMultiline',
          false,
          <String, Object?>{
            'description': localize('selectionHighlightMultiline',
                'Controls whether the editor should highlight selection matches that span multiple lines.'),
          }));

  static final IEditorOption<String> selectedTextMatchMode = register(
      EditorStringEnumOption<String>(
          EditorOption.selectedTextMatchMode,
          'selectedTextMatchMode',
          'findOptions',
          <String>['findOptions', 'caseSensitive', 'caseInsensitive'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('selectedTextMatchMode.findOptions',
                  "Use the Find widget's match case and whole word settings."),
              localize('selectedTextMatchMode.caseSensitive',
                  'Match occurrences case-sensitively and independently of the Find widget.'),
              localize('selectedTextMatchMode.caseInsensitive',
                  'Match occurrences case-insensitively and independently of the Find widget.'),
            ],
            'markdownDescription': localize('selectedTextMatchMode',
                'Controls how occurrences of selected text are matched when selecting the next, previous, or all occurrences and when highlighting selection matches. `caseSensitive` and `caseInsensitive` match substrings independently of the Find widget. An empty selection always starts a whole-word, case-sensitive search.'),
          }));

  static final IEditorOption<bool> selectOnLineNumbers = register(
      EditorBooleanOption(
          EditorOption.selectOnLineNumbers, 'selectOnLineNumbers', true));

  static final IEditorOption<String> showFoldingControls = register(
      EditorStringEnumOption<String>(
          EditorOption.showFoldingControls,
          'showFoldingControls',
          'mouseover',
          <String>['always', 'never', 'mouseover'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('showFoldingControls.always',
                  'Always show the folding controls.'),
              localize('showFoldingControls.never',
                  'Never show the folding controls and reduce the gutter size.'),
              localize('showFoldingControls.mouseover',
                  'Only show the folding controls when the mouse is over the gutter.'),
            ],
            'description': localize('showFoldingControls',
                'Controls when the folding controls on the gutter are shown.'),
          }));

  static final IEditorOption<bool> showUnused = register(
      EditorBooleanOption(
          EditorOption.showUnused,
          'showUnused',
          true,
          <String, Object?>{
            'description':
                localize('showUnused', 'Controls fading out of unused code.'),
          }));

  static final IEditorOption<bool> showDeprecated = register(
      EditorBooleanOption(
          EditorOption.showDeprecated,
          'showDeprecated',
          true,
          <String, Object?>{
            'description': localize('showDeprecated',
                'Controls strikethrough deprecated variables.'),
          }));

  static final IEditorOption<EditorInlayHintsOptions> inlayHints =
      register(EditorInlayHints());

  static final IEditorOption<String> snippetSuggestions = register(
      EditorStringEnumOption<String>(
          EditorOption.snippetSuggestions,
          'snippetSuggestions',
          'inline',
          <String>['top', 'bottom', 'inline', 'none'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('snippetSuggestions.top',
                  'Show snippet suggestions on top of other suggestions.'),
              localize('snippetSuggestions.bottom',
                  'Show snippet suggestions below other suggestions.'),
              localize('snippetSuggestions.inline',
                  'Show snippets suggestions with other suggestions.'),
              localize(
                  'snippetSuggestions.none', 'Do not show snippet suggestions.'),
            ],
            'description': localize('snippetSuggestions',
                'Controls whether snippets are shown with other suggestions and how they are sorted.'),
          }));

  static final IEditorOption<SmartSelectOptions> smartSelect =
      register(SmartSelect());

  static final IEditorOption<bool> smoothScrolling = register(
      EditorBooleanOption(
          EditorOption.smoothScrolling,
          'smoothScrolling',
          false,
          <String, Object?>{
            'description': localize('smoothScrolling',
                'Controls whether the editor will scroll using an animation.'),
          }));

  static final IEditorOption<num> stopRenderingLineAfter = register(
      EditorIntOption(EditorOption.stopRenderingLineAfter,
          'stopRenderingLineAfter', 10000, -1, Constants.MAX_SAFE_SMALL_INTEGER));

  static final IEditorOption<InternalSuggestOptions> suggest =
      register(EditorSuggest());

  static final IEditorOption<InternalInlineSuggestOptions> inlineSuggest =
      register(InlineEditorSuggest());

  static final IEditorOption<bool> inlineCompletionsAccessibilityVerbose =
      register(EditorBooleanOption(
          EditorOption.inlineCompletionsAccessibilityVerbose,
          'inlineCompletionsAccessibilityVerbose',
          false,
          <String, Object?>{
            'description': localize('inlineCompletionsAccessibilityVerbose',
                'Controls whether the accessibility hint should be provided to screen reader users when an inline completion is shown.'),
          }));

  static final IEditorOption<num> suggestFontSize = register(
      EditorIntOption(
          EditorOption.suggestFontSize,
          'suggestFontSize',
          0,
          0,
          1000,
          <String, Object?>{
            'markdownDescription': localize('suggestFontSize',
                'Font size for the suggest widget. When set to {0}, the value of {1} is used.',
                <Object?>['`0`', '`#editor.fontSize#`']),
          }));

  static final IEditorOption<num> suggestLineHeight = register(
      EditorIntOption(
          EditorOption.suggestLineHeight,
          'suggestLineHeight',
          0,
          0,
          1000,
          <String, Object?>{
            'markdownDescription': localize('suggestLineHeight',
                'Line height for the suggest widget. When set to {0}, the value of {1} is used. The minimum value is 8.',
                <Object?>['`0`', '`#editor.lineHeight#`']),
          }));

  static final IEditorOption<bool> suggestOnTriggerCharacters = register(
      EditorBooleanOption(
          EditorOption.suggestOnTriggerCharacters,
          'suggestOnTriggerCharacters',
          true,
          <String, Object?>{
            'description': localize('suggestOnTriggerCharacters',
                'Controls whether suggestions should automatically show up when typing trigger characters.'),
          }));

  static final IEditorOption<String> suggestSelection = register(
      EditorStringEnumOption<String>(
          EditorOption.suggestSelection,
          'suggestSelection',
          'first',
          <String>['first', 'recentlyUsed', 'recentlyUsedByPrefix'],
          <String, Object?>{
            'markdownEnumDescriptions': <String>[
              localize('suggestSelection.first',
                  'Always select the first suggestion.'),
              localize('suggestSelection.recentlyUsed',
                  'Select recent suggestions unless further typing selects one, e.g. `console.| -> console.log` because `log` has been completed recently.'),
              localize('suggestSelection.recentlyUsedByPrefix',
                  'Select suggestions based on previous prefixes that have completed those suggestions, e.g. `co -> console` and `con -> const`.'),
            ],
            'description': localize('suggestSelection',
                'Controls how suggestions are pre-selected when showing the suggest list.'),
          }));

  static final IEditorOption<String> tabCompletion = register(
      EditorStringEnumOption<String>(
          EditorOption.tabCompletion,
          'tabCompletion',
          'off',
          <String>['on', 'off', 'onlySnippets'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('tabCompletion.on',
                  'Tab complete will insert the best matching suggestion when pressing tab.'),
              localize('tabCompletion.off', 'Disable tab completions.'),
              localize('tabCompletion.onlySnippets',
                  "Tab complete snippets when their prefix match. Works best when 'quickSuggestions' aren't enabled."),
            ],
            'description':
                localize('tabCompletion', 'Enables tab completions.'),
          }));

  static final IEditorOption<num> tabIndex = register(EditorIntOption(
      EditorOption.tabIndex, 'tabIndex', 0, -1, Constants.MAX_SAFE_SMALL_INTEGER));

  static final IEditorOption<bool> trimWhitespaceOnDelete = register(
      EditorBooleanOption(
          EditorOption.trimWhitespaceOnDelete,
          'trimWhitespaceOnDelete',
          false,
          <String, Object?>{
            'description': localize('trimWhitespaceOnDelete',
                "Controls whether the editor will also delete the next line's indentation whitespace when deleting a newline."),
          }));

  static final IEditorOption<Object?> unicodeHighlight =
      register(UnicodeHighlight());

  static final IEditorOption<String> unusualLineTerminators = register(
      EditorStringEnumOption<String>(
          EditorOption.unusualLineTerminators,
          'unusualLineTerminators',
          'prompt',
          <String>['auto', 'off', 'prompt'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('unusualLineTerminators.auto',
                  'Unusual line terminators are automatically removed.'),
              localize('unusualLineTerminators.off',
                  'Unusual line terminators are ignored.'),
              localize('unusualLineTerminators.prompt',
                  'Unusual line terminators prompt to be removed.'),
            ],
            'description': localize('unusualLineTerminators',
                'Remove unusual line terminators that might cause problems.'),
          }));

  static final IEditorOption<bool> useShadowDOM = register(
      EditorBooleanOption(
          EditorOption.useShadowDOM, 'useShadowDOM', true));

  static final IEditorOption<bool> useTabStops = register(
      EditorBooleanOption(
          EditorOption.useTabStops,
          'useTabStops',
          true,
          <String, Object?>{
            'description': localize('useTabStops',
                'Spaces and tabs are inserted and deleted in alignment with tab stops.'),
          }));

  static final IEditorOption<String> wordBreak = register(
      EditorStringEnumOption<String>(
          EditorOption.wordBreak,
          'wordBreak',
          'normal',
          <String>['normal', 'keepAll'],
          <String, Object?>{
            'markdownEnumDescriptions': <String>[
              localize('wordBreak.normal', 'Use the default line break rule.'),
              localize('wordBreak.keepAll',
                  'Word breaks should not be used for Chinese/Japanese/Korean (CJK) text. Non-CJK text behavior is the same as for normal.'),
            ],
            'description': localize('wordBreak',
                'Controls the word break rules used for Chinese/Japanese/Korean (CJK) text.'),
          }));

  static final IEditorOption<List<String>> wordSegmenterLocales =
      register(WordSegmenterLocales());

  static final IEditorOption<String> wordSeparators = register(
      EditorStringOption(
          EditorOption.wordSeparators,
          'wordSeparators',
          USUAL_WORD_SEPARATORS,
          <String, Object?>{
            'description': localize('wordSeparators',
                'Characters that will be used as word separators when doing word related navigations or operations.'),
          }));

  static final IEditorOption<String> wordWrap = register(
      EditorStringEnumOption<String>(
          EditorOption.wordWrap,
          'wordWrap',
          'off',
          <String>['off', 'on', 'wordWrapColumn', 'bounded'],
          <String, Object?>{
            'markdownEnumDescriptions': <String>[
              localize('wordWrap.off', 'Lines will never wrap.'),
              localize('wordWrap.on', 'Lines will wrap at the viewport width.'),
              localize(
                  <String, Object?>{
                    'key': 'wordWrap.wordWrapColumn',
                    'comment': <String>[
                      '- `editor.wordWrapColumn` refers to a different setting and should not be localized.'
                    ],
                  },
                  'Lines will wrap at `#editor.wordWrapColumn#`.'),
              localize(
                  <String, Object?>{
                    'key': 'wordWrap.bounded',
                    'comment': <String>[
                      '- viewport means the edge of the visible window size.',
                      '- `editor.wordWrapColumn` refers to a different setting and should not be localized.'
                    ],
                  },
                  'Lines will wrap at the minimum of viewport and `#editor.wordWrapColumn#`.'),
            ],
            'description': localize(
                <String, Object?>{
                  'key': 'wordWrap',
                  'comment': <String>[
                    '- \'off\', \'on\', \'wordWrapColumn\' and \'bounded\' refer to values the setting can take and should not be localized.',
                    '- `editor.wordWrapColumn` refers to a different setting and should not be localized.'
                  ],
                },
                'Controls how lines should wrap.'),
          }));

  static final IEditorOption<bool> wordWrapIndicator = register(
      EditorBooleanOption(
          EditorOption.wordWrapIndicator,
          'wordWrapIndicator',
          false,
          <String, Object?>{
            'markdownDescription': localize(
                <String, Object?>{
                  'key': 'wordWrapIndicator',
                  'comment': <String>[],
                },
                'Controls whether an indicator is rendered at the wrapping column of lines that wrap. Only has an effect when `#editor.wordWrap#` is enabled.'),
          }));

  static final IEditorOption<String> wordWrapBreakAfterCharacters = register(
      EditorStringOption(
          EditorOption.wordWrapBreakAfterCharacters,
          'wordWrapBreakAfterCharacters',
          ' \t})]?|/&.,;¢°′″‰℃、。｡､￠，．：；？！％・･ゝゞヽヾーァィゥェォッャュョヮヵヶぁぃぅぇぉっゃゅょゎゕゖㇰㇱㇲㇳㇴㇵㇶㇷㇸㇹㇺㇻㇼㇽㇾㇿ々〻ｧｨｩｪｫｬｭｮｯｰ”〉》」』】〕）］｝｣'));

  static final IEditorOption<String> wordWrapBreakBeforeCharacters = register(
      EditorStringOption(
          EditorOption.wordWrapBreakBeforeCharacters,
          'wordWrapBreakBeforeCharacters',
          '([{‘“〈《「『【〔（［｛｢£¥＄￡￥+＋'));

  static final IEditorOption<num> wordWrapColumn = register(
      EditorIntOption(
          EditorOption.wordWrapColumn,
          'wordWrapColumn',
          80,
          1,
          Constants.MAX_SAFE_SMALL_INTEGER,
          <String, Object?>{
            'markdownDescription': localize(
                <String, Object?>{
                  'key': 'wordWrapColumn',
                  'comment': <String>[
                    '- `editor.wordWrap` refers to a different setting and should not be localized.',
                    '- \'wordWrapColumn\' and \'bounded\' refer to values the different setting can take and should not be localized.'
                  ],
                },
                'Controls the wrapping column of the editor when `#editor.wordWrap#` is `wordWrapColumn` or `bounded`.'),
          }));

  static final IEditorOption<String> wordWrapOverride1 = register(
      EditorStringEnumOption<String>(EditorOption.wordWrapOverride1,
          'wordWrapOverride1', 'inherit', <String>['off', 'on', 'inherit']));

  static final IEditorOption<String> wordWrapOverride2 = register(
      EditorStringEnumOption<String>(EditorOption.wordWrapOverride2,
          'wordWrapOverride2', 'inherit', <String>['off', 'on', 'inherit']));

  static final IEditorOption<bool> wrapOnEscapedLineFeeds = register(
      EditorBooleanOption(
          EditorOption.wrapOnEscapedLineFeeds,
          'wrapOnEscapedLineFeeds',
          false,
          <String, Object?>{
            'markdownDescription': localize('wrapOnEscapedLineFeeds',
                'Controls whether literal `\\n` shall trigger a wordWrap when `#editor.wordWrap#` is enabled.\n\nFor example:\n```c\nchar* str="hello\\nworld"\n```\nwill be displayed as\n```c\nchar* str="hello\\n\n           world"\n```'),
          }));

  // Leave these at the end (because they have dependencies!)
  static final IEditorOption<int> effectiveCursorStyle =
      register(EffectiveCursorStyle());

  static final IEditorOption<String> editorClassName =
      register(EditorClassName());

  static final IEditorOption<String> defaultColorDecorators = register(
      EditorStringEnumOption<String>(
          EditorOption.defaultColorDecorators,
          'defaultColorDecorators',
          'auto',
          <String>['auto', 'always', 'never'],
          <String, Object?>{
            'enumDescriptions': <String>[
              localize('editor.defaultColorDecorators.auto',
                  'Show default color decorators only when no extension provides colors decorators.'),
              localize('editor.defaultColorDecorators.always',
                  'Always show default color decorators.'),
              localize('editor.defaultColorDecorators.never',
                  'Never show default color decorators.'),
            ],
            'description': localize('defaultColorDecorators',
                'Controls whether inline color decorations should be shown using the default document color provider.'),
          }));

  static final IEditorOption<num> pixelRatio = register(EditorPixelRatio());

  static final IEditorOption<bool> tabFocusMode =
      register(EditorTabFocusMode());

  static final IEditorOption<EditorLayoutInfo> layoutInfo =
      register(EditorLayoutInfoComputer());

  static final IEditorOption<EditorWrappingInfo> wrappingInfo =
      register(EditorWrappingInfoComputer());

  static final IEditorOption<int> wrappingIndent =
      register(WrappingIndentOption());

  static final IEditorOption<String> wrappingStrategy =
      register(WrappingStrategy());

  static final IEditorOption<bool> effectiveEditContextEnabled =
      register(EffectiveEditContextEnabled());

  static final IEditorOption<bool> effectiveAllowVariableFonts =
      register(EffectiveAllowVariableFonts());

  static final IEditorOption<String> effectiveFullwidthCharacterWidth =
      register(EffectiveFullwidthCharacterWidth());
}

// Trailing type-level declarations of editorOptions.ts (source lines 7095-7102)
// are erased under the documented Dart convention: `EditorOptionsType`,
// `FindEditorOptionsKeyById`, `ComputedEditorOptionValue`,
// `FindComputedEditorOptionValueById` and `MouseMiddleClickAction` exist only
// in TypeScript's type space and have no runtime counterpart. Their runtime
// effect is already carried by the `IEditorOption` generics and the
// `EditorStringEnumOption<String>` used by `mouseMiddleClickAction` above.

//#endregion
