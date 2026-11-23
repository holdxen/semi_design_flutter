// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/standalone/standaloneEnums.ts
// THIS IS A GENERATED FILE (mirrors the generated TypeScript source).
// Translated 1:1: TypeScript `enum` -> Dart class with `static const` members.
// Numeric enums use `int`, string enums (ShowLightbulbIconMode) use `String`.
// ---------------------------------------------------------------------------

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// THIS IS A GENERATED FILE. DO NOT EDIT DIRECTLY.
class AccessibilitySupport {
  /// This should be the browser case where it is not known if a screen reader is attached or no.
  static const int Unknown = 0;
  static const int Disabled = 1;
  static const int Enabled = 2;
}

class CodeActionTriggerType {
  static const int Invoke = 1;
  static const int Auto = 2;
}

class CompletionItemInsertTextRule {
  static const int None = 0;
  /// Adjust whitespace/indentation of multiline insert texts to
  /// match the current line indentation.
  static const int KeepWhitespace = 1;
  /// `insertText` is a snippet.
  static const int InsertAsSnippet = 4;
}

class CompletionItemKind {
  static const int Method = 0;
  static const int Function = 1;
  static const int Constructor = 2;
  static const int Field = 3;
  static const int Variable = 4;
  static const int Class = 5;
  static const int Struct = 6;
  static const int Interface = 7;
  static const int Module = 8;
  static const int Property = 9;
  static const int Event = 10;
  static const int Operator = 11;
  static const int Unit = 12;
  static const int Value = 13;
  static const int Constant = 14;
  static const int Enum = 15;
  static const int EnumMember = 16;
  static const int Keyword = 17;
  static const int Text = 18;
  static const int Color = 19;
  static const int File = 20;
  static const int Reference = 21;
  static const int Customcolor = 22;
  static const int Folder = 23;
  static const int TypeParameter = 24;
  static const int User = 25;
  static const int Issue = 26;
  static const int Tool = 27;
  static const int Snippet = 28;
}

class CompletionItemTag {
  static const int Deprecated = 1;
}

///
/// How a suggest provider was triggered.
class CompletionTriggerKind {
  static const int Invoke = 0;
  static const int TriggerCharacter = 1;
  static const int TriggerForIncompleteCompletions = 2;
}

///
/// A positioning preference for rendering content widgets.
class ContentWidgetPositionPreference {
  /// Place the content widget exactly at a position
  static const int EXACT = 0;
  /// Place the content widget above a position
  static const int ABOVE = 1;
  /// Place the content widget below a position
  static const int BELOW = 2;
}

///
/// Describes the reason the cursor has changed its position.
class CursorChangeReason {
  /// Unknown or not set.
  static const int NotSet = 0;
  /// A `model.setValue()` was called.
  static const int ContentFlush = 1;
  /// The `model` has been changed outside of this cursor and the cursor recovers its position from associated markers.
  static const int RecoverFromMarkers = 2;
  /// There was an explicit user gesture.
  static const int Explicit = 3;
  /// There was a Paste.
  static const int Paste = 4;
  /// There was an Undo.
  static const int Undo = 5;
  /// There was a Redo.
  static const int Redo = 6;
}

///
/// The default end of line to use when instantiating models.
class DefaultEndOfLine {
  /// Use line feed (\n) as the end of line character.
  static const int LF = 1;
  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const int CRLF = 2;
}

///
/// A document highlight kind.
class DocumentHighlightKind {
  /// A textual occurrence.
  static const int Text = 0;
  /// Read-access of a symbol, like reading a variable.
  static const int Read = 1;
  /// Write-access of a symbol, like writing to a variable.
  static const int Write = 2;
}

///
/// Configuration options for auto indentation in the editor
class EditorAutoIndentStrategy {
  static const int None = 0;
  static const int Keep = 1;
  static const int Brackets = 2;
  static const int Advanced = 3;
  static const int Full = 4;
}

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
}

///
/// End of line character preference.
class EndOfLinePreference {
  /// Use the end of line character identified in the text buffer.
  static const int TextDefined = 0;
  /// Use line feed (\n) as the end of line character.
  static const int LF = 1;
  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const int CRLF = 2;
}

///
/// End of line character preference.
class EndOfLineSequence {
  /// Use line feed (\n) as the end of line character.
  static const int LF = 0;
  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const int CRLF = 1;
}

///
/// Vertical Lane in the glyph margin of the editor.
class GlyphMarginLane {
  static const int Left = 1;
  static const int Center = 2;
  static const int Right = 3;
}

class HoverVerbosityAction {
  /// Increase the verbosity of the hover
  static const int Increase = 0;
  /// Decrease the verbosity of the hover
  static const int Decrease = 1;
}

///
/// Describes what to do with the indentation when pressing Enter.
class IndentAction {
  /// Insert new line and copy the previous line's indentation.
  static const int None = 0;
  /// Insert new line and indent once (relative to the previous line's indentation).
  static const int Indent = 1;
  /// Insert two new lines:
  /// - the first one indented which will hold the cursor
  /// - the second one at the same indentation level
  static const int IndentOutdent = 2;
  /// Insert new line and outdent once (relative to the previous line's indentation).
  static const int Outdent = 3;
}

class InjectedTextCursorStops {
  static const int Both = 0;
  static const int Right = 1;
  static const int Left = 2;
  static const int None = 3;
}

class InlayHintKind {
  static const int Type = 1;
  static const int Parameter = 2;
}

class InlineCompletionEndOfLifeReasonKind {
  static const int Accepted = 0;
  static const int Rejected = 1;
  static const int Ignored = 2;
}

class InlineCompletionHintStyle {
  static const int Code = 1;
  static const int Label = 2;
}

///
/// How an {@link InlineCompletionsProvider inline completion provider} was triggered.
class InlineCompletionTriggerKind {
  /// Completion was triggered automatically while editing.
  /// It is sufficient to return a single completion item in this case.
  static const int Automatic = 0;
  /// Completion was triggered explicitly by a user gesture.
  /// Return multiple completion items to enable cycling through them.
  static const int Explicit = 1;
}

///
/// Virtual Key Codes, the value does not hold any inherent meaning.
/// Inspired somewhat from https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
/// But these are "more general", as they should work across browsers & OS`s.
class KeyCode {
  static const int DependsOnKbLayout = -1;
  /// Placed first to cover the 0 value of the enum.
  static const int Unknown = 0;
  static const int Backspace = 1;
  static const int Tab = 2;
  static const int Enter = 3;
  static const int Shift = 4;
  static const int Ctrl = 5;
  static const int Alt = 6;
  static const int PauseBreak = 7;
  static const int CapsLock = 8;
  static const int Escape = 9;
  static const int Space = 10;
  static const int PageUp = 11;
  static const int PageDown = 12;
  static const int End = 13;
  static const int Home = 14;
  static const int LeftArrow = 15;
  static const int UpArrow = 16;
  static const int RightArrow = 17;
  static const int DownArrow = 18;
  static const int Insert = 19;
  static const int Delete = 20;
  static const int Digit0 = 21;
  static const int Digit1 = 22;
  static const int Digit2 = 23;
  static const int Digit3 = 24;
  static const int Digit4 = 25;
  static const int Digit5 = 26;
  static const int Digit6 = 27;
  static const int Digit7 = 28;
  static const int Digit8 = 29;
  static const int Digit9 = 30;
  static const int KeyA = 31;
  static const int KeyB = 32;
  static const int KeyC = 33;
  static const int KeyD = 34;
  static const int KeyE = 35;
  static const int KeyF = 36;
  static const int KeyG = 37;
  static const int KeyH = 38;
  static const int KeyI = 39;
  static const int KeyJ = 40;
  static const int KeyK = 41;
  static const int KeyL = 42;
  static const int KeyM = 43;
  static const int KeyN = 44;
  static const int KeyO = 45;
  static const int KeyP = 46;
  static const int KeyQ = 47;
  static const int KeyR = 48;
  static const int KeyS = 49;
  static const int KeyT = 50;
  static const int KeyU = 51;
  static const int KeyV = 52;
  static const int KeyW = 53;
  static const int KeyX = 54;
  static const int KeyY = 55;
  static const int KeyZ = 56;
  static const int Meta = 57;
  static const int ContextMenu = 58;
  static const int F1 = 59;
  static const int F2 = 60;
  static const int F3 = 61;
  static const int F4 = 62;
  static const int F5 = 63;
  static const int F6 = 64;
  static const int F7 = 65;
  static const int F8 = 66;
  static const int F9 = 67;
  static const int F10 = 68;
  static const int F11 = 69;
  static const int F12 = 70;
  static const int F13 = 71;
  static const int F14 = 72;
  static const int F15 = 73;
  static const int F16 = 74;
  static const int F17 = 75;
  static const int F18 = 76;
  static const int F19 = 77;
  static const int F20 = 78;
  static const int F21 = 79;
  static const int F22 = 80;
  static const int F23 = 81;
  static const int F24 = 82;
  static const int NumLock = 83;
  static const int ScrollLock = 84;
  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the ';:' key
  static const int Semicolon = 85;
  /// For any country/region, the '+' key
  /// For the US standard keyboard, the '=+' key
  static const int Equal = 86;
  /// For any country/region, the ',' key
  /// For the US standard keyboard, the ',<' key
  static const int Comma = 87;
  /// For any country/region, the '-' key
  /// For the US standard keyboard, the '-_' key
  static const int Minus = 88;
  /// For any country/region, the '.' key
  /// For the US standard keyboard, the '.>' key
  static const int Period = 89;
  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the '/?' key
  static const int Slash = 90;
  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the '`~' key
  static const int Backquote = 91;
  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the '[{' key
  static const int BracketLeft = 92;
  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the '\|' key
  static const int Backslash = 93;
  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the ']}' key
  static const int BracketRight = 94;
  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the ''"' key
  static const int Quote = 95;
  /// Used for miscellaneous characters; it can vary by keyboard.
  static const int OEM_8 = 96;
  /// Either the angle bracket key or the backslash key on the RT 102-key keyboard.
  static const int IntlBackslash = 97;
  static const int Numpad0 = 98;
  // VK_NUMPAD0, 0x60, Numeric keypad 0 key
  static const int Numpad1 = 99;
  // VK_NUMPAD1, 0x61, Numeric keypad 1 key
  static const int Numpad2 = 100;
  // VK_NUMPAD2, 0x62, Numeric keypad 2 key
  static const int Numpad3 = 101;
  // VK_NUMPAD3, 0x63, Numeric keypad 3 key
  static const int Numpad4 = 102;
  // VK_NUMPAD4, 0x64, Numeric keypad 4 key
  static const int Numpad5 = 103;
  // VK_NUMPAD5, 0x65, Numeric keypad 5 key
  static const int Numpad6 = 104;
  // VK_NUMPAD6, 0x66, Numeric keypad 6 key
  static const int Numpad7 = 105;
  // VK_NUMPAD7, 0x67, Numeric keypad 7 key
  static const int Numpad8 = 106;
  // VK_NUMPAD8, 0x68, Numeric keypad 8 key
  static const int Numpad9 = 107;
  // VK_NUMPAD9, 0x69, Numeric keypad 9 key
  static const int NumpadMultiply = 108;
  // VK_MULTIPLY, 0x6A, Multiply key
  static const int NumpadAdd = 109;
  // VK_ADD, 0x6B, Add key
  static const int NUMPAD_SEPARATOR = 110;
  // VK_SEPARATOR, 0x6C, Separator key
  static const int NumpadSubtract = 111;
  // VK_SUBTRACT, 0x6D, Subtract key
  static const int NumpadDecimal = 112;
  // VK_DECIMAL, 0x6E, Decimal key
  static const int NumpadDivide = 113;
  // VK_DIVIDE, 0x6F,
  /// Cover all key codes when IME is processing input.
  static const int KEY_IN_COMPOSITION = 114;
  static const int ABNT_C1 = 115;
  // Brazilian (ABNT) Keyboard
  static const int ABNT_C2 = 116;
  // Brazilian (ABNT) Keyboard
  static const int AudioVolumeMute = 117;
  static const int AudioVolumeUp = 118;
  static const int AudioVolumeDown = 119;
  static const int BrowserSearch = 120;
  static const int BrowserHome = 121;
  static const int BrowserBack = 122;
  static const int BrowserForward = 123;
  static const int MediaTrackNext = 124;
  static const int MediaTrackPrevious = 125;
  static const int MediaStop = 126;
  static const int MediaPlayPause = 127;
  static const int LaunchMediaPlayer = 128;
  static const int LaunchMail = 129;
  static const int LaunchApp2 = 130;
  /// VK_CLEAR, 0x0C, CLEAR key
  static const int Clear = 131;
  /// Placed last to cover the length of the enum.
  /// Please do not depend on this value!
  static const int MAX_VALUE = 132;
}

class MarkerSeverity {
  static const int Hint = 1;
  static const int Info = 2;
  static const int Warning = 4;
  static const int Error = 8;
}

class MarkerTag {
  static const int Unnecessary = 1;
  static const int Deprecated = 2;
}

///
/// Position in the minimap to render the decoration.
class MinimapPosition {
  static const int Inline = 1;
  static const int Gutter = 2;
}

///
/// Section header style.
class MinimapSectionHeaderStyle {
  static const int Normal = 1;
  static const int Underlined = 2;
}

///
/// Type of hit element with the mouse in the editor.
class MouseTargetType {
  /// Mouse is on top of an unknown element.
  static const int UNKNOWN = 0;
  /// Mouse is on top of the textarea used for input.
  static const int TEXTAREA = 1;
  /// Mouse is on top of the glyph margin
  static const int GUTTER_GLYPH_MARGIN = 2;
  /// Mouse is on top of the line numbers
  static const int GUTTER_LINE_NUMBERS = 3;
  /// Mouse is on top of the line decorations
  static const int GUTTER_LINE_DECORATIONS = 4;
  /// Mouse is on top of the whitespace left in the gutter by a view zone.
  static const int GUTTER_VIEW_ZONE = 5;
  /// Mouse is on top of text in the content.
  static const int CONTENT_TEXT = 6;
  /// Mouse is on top of empty space in the content (e.g. after line text or below last line)
  static const int CONTENT_EMPTY = 7;
  /// Mouse is on top of a view zone in the content.
  static const int CONTENT_VIEW_ZONE = 8;
  /// Mouse is on top of a content widget.
  static const int CONTENT_WIDGET = 9;
  /// Mouse is on top of the decorations overview ruler.
  static const int OVERVIEW_RULER = 10;
  /// Mouse is on top of a scrollbar.
  static const int SCROLLBAR = 11;
  /// Mouse is on top of an overlay widget.
  static const int OVERLAY_WIDGET = 12;
  /// Mouse is outside of the editor.
  static const int OUTSIDE_EDITOR = 13;
}

class NewSymbolNameTag {
  static const int AIGenerated = 1;
}

class NewSymbolNameTriggerKind {
  static const int Invoke = 0;
  static const int Automatic = 1;
}

///
/// A positioning preference for rendering overlay widgets.
class OverlayWidgetPositionPreference {
  /// Position the overlay widget in the top right corner
  static const int TOP_RIGHT_CORNER = 0;
  /// Position the overlay widget in the bottom right corner
  static const int BOTTOM_RIGHT_CORNER = 1;
  /// Position the overlay widget in the top center
  static const int TOP_CENTER = 2;
}

///
/// Vertical Lane in the overview ruler of the editor.
class OverviewRulerLane {
  static const int Left = 1;
  static const int Center = 2;
  static const int Right = 4;
  static const int Full = 7;
}

///
/// How a partial acceptance was triggered.
class PartialAcceptTriggerKind {
  static const int Word = 0;
  static const int Line = 1;
  static const int Suggest = 2;
}

class PositionAffinity {
  /// Prefers the left most position.
  static const int Left = 0;
  /// Prefers the right most position.
  static const int Right = 1;
  /// No preference.
  static const int None = 2;
  /// If the given position is on injected text, prefers the position left of it.
  static const int LeftOfInjectedText = 3;
  /// If the given position is on injected text, prefers the position right of it.
  static const int RightOfInjectedText = 4;
}

class RenderLineNumbersType {
  static const int Off = 0;
  static const int On = 1;
  static const int Relative = 2;
  static const int Interval = 3;
  static const int Custom = 4;
}

class RenderMinimap {
  static const int None = 0;
  static const int Text = 1;
  static const int Blocks = 2;
}

class ScrollType {
  static const int Smooth = 0;
  static const int Immediate = 1;
}

class ScrollbarVisibility {
  static const int Auto = 1;
  static const int Hidden = 2;
  static const int Visible = 3;
}

///
/// The direction of a selection.
class SelectionDirection {
  /// The selection starts above where it ends.
  static const int LTR = 0;
  /// The selection starts below where it ends.
  static const int RTL = 1;
}

class ShowLightbulbIconMode {
  static const String Off = 'off';
  static const String OnCode = 'onCode';
  static const String On = 'on';
}

class SignatureHelpTriggerKind {
  static const int Invoke = 1;
  static const int TriggerCharacter = 2;
  static const int ContentChange = 3;
}

///
/// A symbol kind.
class SymbolKind {
  static const int File = 0;
  static const int Module = 1;
  static const int Namespace = 2;
  static const int Package = 3;
  static const int Class = 4;
  static const int Method = 5;
  static const int Property = 6;
  static const int Field = 7;
  static const int Constructor = 8;
  static const int Enum = 9;
  static const int Interface = 10;
  static const int Function = 11;
  static const int Variable = 12;
  static const int Constant = 13;
  static const int String = 14;
  static const int Number = 15;
  static const int Boolean = 16;
  static const int Array = 17;
  static const int Object = 18;
  static const int Key = 19;
  static const int Null = 20;
  static const int EnumMember = 21;
  static const int Struct = 22;
  static const int Event = 23;
  static const int Operator = 24;
  static const int TypeParameter = 25;
}

class SymbolTag {
  static const int Deprecated = 1;
}

///
/// Text Direction for a decoration.
class TextDirection {
  static const int LTR = 0;
  static const int RTL = 1;
}

///
/// The kind of animation in which the editor's cursor should be rendered.
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
}

///
/// The style in which the editor's cursor should be rendered.
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
}

///
/// Describes the behavior of decorations when typing/editing near their edges.
/// Note: Please do not edit the values, as they very carefully match `DecorationRangeBehavior`
class TrackedRangeStickiness {
  static const int AlwaysGrowsWhenTypingAtEdges = 0;
  static const int NeverGrowsWhenTypingAtEdges = 1;
  static const int GrowsOnlyWhenTypingBefore = 2;
  static const int GrowsOnlyWhenTypingAfter = 3;
}

///
/// Describes how to indent wrapped lines.
class WrappingIndent {
  /// No indentation => wrapped lines begin at column 1.
  static const int None = 0;
  /// Same => wrapped lines get the same indentation as the parent.
  static const int Same = 1;
  /// Indent => wrapped lines get +1 indentation toward the parent.
  static const int Indent = 2;
  /// DeepIndent => wrapped lines get +2 indentation toward the parent.
  static const int DeepIndent = 3;
}

