// 1:1 translated from editor/common/editorContextKeys.ts
import '../../nls.dart' show localize;
import '../../platform/contextkey/common/contextkey.dart' show RawContextKey;

/// 1:1: `export namespace EditorContextKeys`
class EditorContextKeys {
  static final editorSimpleInput = RawContextKey<bool>('editorSimpleInput', false, true);
  ///  A context key that is set when the editor's text has focus (cursor is blinking).
  ///  Is false when focus is in simple editor widgets (repl input, scm commit input).
  static final editorTextFocus = RawContextKey<bool>('editorTextFocus', false, localize('editorTextFocus', "Whether the editor text has focus (cursor is blinking)"));
  ///  A context key that is set when the editor's text or an editor's widget has focus.
  static final focus = RawContextKey<bool>('editorFocus', false, localize('editorFocus', "Whether the editor or an editor widget has focus (e.g. focus is in the find widget)"));
  ///  A context key that is set when any editor input has focus (regular editor, repl input...).
  static final textInputFocus = RawContextKey<bool>('textInputFocus', false, localize('textInputFocus', "Whether an editor or a rich text input has focus (cursor is blinking)"));
  static final readOnly = RawContextKey<bool>('editorReadonly', false, localize('editorReadonly', "Whether the editor is read-only"));
  static final inDiffEditor = RawContextKey<bool>('inDiffEditor', false, localize('inDiffEditor', "Whether the context is a diff editor"));
  static final isEmbeddedDiffEditor = RawContextKey<bool>('isEmbeddedDiffEditor', false, localize('isEmbeddedDiffEditor', "Whether the context is an embedded diff editor"));
  static final inMultiDiffEditor = RawContextKey<bool>('inMultiDiffEditor', false, localize('inMultiDiffEditor', "Whether the context is a multi diff editor"));
  static final multiDiffEditorAllCollapsed = RawContextKey<bool>('multiDiffEditorAllCollapsed', null, localize('multiDiffEditorAllCollapsed', "Whether all files in multi diff editor are collapsed"));
  static final multiDiffEditorItemAllUnchangedRegionsShown = RawContextKey<bool>('multiDiffEditorItemAllUnchangedRegionsShown', false, localize('multiDiffEditorItemAllUnchangedRegionsShown', "Whether all unchanged regions of a multi diff editor file are revealed"));
  static final multiDiffEditorRenderSideBySide = RawContextKey<bool>('multiDiffEditorRenderSideBySide', true, localize('multiDiffEditorRenderSideBySide', "Whether the multi diff editor renders diffs side by side instead of inline"));
  static final hasChanges = RawContextKey<bool>('diffEditorHasChanges', false, localize('diffEditorHasChanges', "Whether the diff editor has changes"));
  static final comparingMovedCode = RawContextKey<bool>('comparingMovedCode', false, localize('comparingMovedCode', "Whether a moved code block is selected for comparison"));
  static final accessibleDiffViewerVisible = RawContextKey<bool>('accessibleDiffViewerVisible', false, localize('accessibleDiffViewerVisible', "Whether the accessible diff viewer is visible"));
  static final diffEditorRenderSideBySideInlineBreakpointReached = RawContextKey<bool>('diffEditorRenderSideBySideInlineBreakpointReached', false, localize('diffEditorRenderSideBySideInlineBreakpointReached', "Whether the diff editor render side by side inline breakpoint is reached"));
  static final diffEditorInlineMode = RawContextKey<bool>('diffEditorInlineMode', false, localize('diffEditorInlineMode', "Whether inline mode is active"));
  static final diffEditorTemporaryInlineMode = RawContextKey<bool>('diffEditorTemporaryInlineMode', false, localize('diffEditorTemporaryInlineMode', "Whether inline mode is temporarily active after manually resizing the diff editor"));
  static final diffEditorAutomaticRenderSideBySide = RawContextKey<bool>('diffEditorAutomaticRenderSideBySide', true, localize('diffEditorAutomaticRenderSideBySide', "Whether automatic diff editor layout would render side by side"));
  static final diffEditorOriginalWritable = RawContextKey<bool>('diffEditorOriginalWritable', false, localize('diffEditorOriginalWritable', "Whether modified is writable in the diff editor"));
  static final diffEditorModifiedWritable = RawContextKey<bool>('diffEditorModifiedWritable', false, localize('diffEditorModifiedWritable', "Whether modified is writable in the diff editor"));
  static final diffEditorOriginalUri = RawContextKey<String>('diffEditorOriginalUri', '', localize('diffEditorOriginalUri', "The uri of the original document"));
  static final diffEditorModifiedUri = RawContextKey<String>('diffEditorModifiedUri', '', localize('diffEditorModifiedUri', "The uri of the modified document"));
  static final columnSelection = RawContextKey<bool>('editorColumnSelection', false, localize('editorColumnSelection', "Whether `editor.columnSelection` is enabled"));
  static final writable = readOnly.toNegated();
  static final hasNonEmptySelection = RawContextKey<bool>('editorHasSelection', false, localize('editorHasSelection', "Whether the editor has text selected"));
  static final hasOnlyEmptySelection = hasNonEmptySelection.toNegated();
  static final hasMultipleSelections = RawContextKey<bool>('editorHasMultipleSelections', false, localize('editorHasMultipleSelections', "Whether the editor has multiple selections"));
  static final hasSingleSelection = hasMultipleSelections.toNegated();
  static final tabMovesFocus = RawContextKey<bool>('editorTabMovesFocus', false, localize('editorTabMovesFocus', "Whether `Tab` will move focus out of the editor"));
  static final tabDoesNotMoveFocus = tabMovesFocus.toNegated();
  static final isInEmbeddedEditor = RawContextKey<bool>('isInEmbeddedEditor', false, true);
  static final canUndo = RawContextKey<bool>('canUndo', false, true);
  static final canRedo = RawContextKey<bool>('canRedo', false, true);
  static final hoverVisible = RawContextKey<bool>('editorHoverVisible', false, localize('editorHoverVisible', "Whether the editor hover is visible"));
  static final hoverFocused = RawContextKey<bool>('editorHoverFocused', false, localize('editorHoverFocused', "Whether the editor hover is focused"));
  static final stickyScrollFocused = RawContextKey<bool>('stickyScrollFocused', false, localize('stickyScrollFocused', "Whether the sticky scroll is focused"));
  static final stickyScrollVisible = RawContextKey<bool>('stickyScrollVisible', false, localize('stickyScrollVisible', "Whether the sticky scroll is visible"));
  static final standaloneColorPickerVisible = RawContextKey<bool>('standaloneColorPickerVisible', false, localize('standaloneColorPickerVisible', "Whether the standalone color picker is visible"));
  static final standaloneColorPickerFocused = RawContextKey<bool>('standaloneColorPickerFocused', false, localize('standaloneColorPickerFocused', "Whether the standalone color picker is focused"));
  static final isComposing = RawContextKey<bool>('isComposing', false, localize('isComposing', "Whether the editor is in the composition mode"));
  ///  A context key that is set when an editor is part of a larger editor, like notebooks or
  ///  (future) a diff editor
  static final inCompositeEditor = RawContextKey<bool>('inCompositeEditor', null, localize('inCompositeEditor', "Whether the editor is part of a larger editor (e.g. notebooks)"));
  static final notInCompositeEditor = inCompositeEditor.toNegated();
  // -- mode context keys
  static final languageId = RawContextKey<String>('editorLangId', '', localize('editorLangId', "The language identifier of the editor"));
  static final hasCompletionItemProvider = RawContextKey<bool>('editorHasCompletionItemProvider', false, localize('editorHasCompletionItemProvider', "Whether the editor has a completion item provider"));
  static final hasCodeActionsProvider = RawContextKey<bool>('editorHasCodeActionsProvider', false, localize('editorHasCodeActionsProvider', "Whether the editor has a code actions provider"));
  static final hasCodeLensProvider = RawContextKey<bool>('editorHasCodeLensProvider', false, localize('editorHasCodeLensProvider', "Whether the editor has a code lens provider"));
  static final hasDefinitionProvider = RawContextKey<bool>('editorHasDefinitionProvider', false, localize('editorHasDefinitionProvider', "Whether the editor has a definition provider"));
  static final hasDeclarationProvider = RawContextKey<bool>('editorHasDeclarationProvider', false, localize('editorHasDeclarationProvider', "Whether the editor has a declaration provider"));
  static final hasImplementationProvider = RawContextKey<bool>('editorHasImplementationProvider', false, localize('editorHasImplementationProvider', "Whether the editor has an implementation provider"));
  static final hasTypeDefinitionProvider = RawContextKey<bool>('editorHasTypeDefinitionProvider', false, localize('editorHasTypeDefinitionProvider', "Whether the editor has a type definition provider"));
  static final hasHoverProvider = RawContextKey<bool>('editorHasHoverProvider', false, localize('editorHasHoverProvider', "Whether the editor has a hover provider"));
  static final hasDocumentHighlightProvider = RawContextKey<bool>('editorHasDocumentHighlightProvider', false, localize('editorHasDocumentHighlightProvider', "Whether the editor has a document highlight provider"));
  static final hasDocumentSymbolProvider = RawContextKey<bool>('editorHasDocumentSymbolProvider', false, localize('editorHasDocumentSymbolProvider', "Whether the editor has a document symbol provider"));
  static final hasReferenceProvider = RawContextKey<bool>('editorHasReferenceProvider', false, localize('editorHasReferenceProvider', "Whether the editor has a reference provider"));
  static final hasRenameProvider = RawContextKey<bool>('editorHasRenameProvider', false, localize('editorHasRenameProvider', "Whether the editor has a rename provider"));
  static final hasSignatureHelpProvider = RawContextKey<bool>('editorHasSignatureHelpProvider', false, localize('editorHasSignatureHelpProvider', "Whether the editor has a signature help provider"));
  static final hasInlayHintsProvider = RawContextKey<bool>('editorHasInlayHintsProvider', false, localize('editorHasInlayHintsProvider', "Whether the editor has an inline hints provider"));
  // -- mode context keys: formatting
  static final hasDocumentFormattingProvider = RawContextKey<bool>('editorHasDocumentFormattingProvider', false, localize('editorHasDocumentFormattingProvider', "Whether the editor has a document formatting provider"));
  static final hasDocumentSelectionFormattingProvider = RawContextKey<bool>('editorHasDocumentSelectionFormattingProvider', false, localize('editorHasDocumentSelectionFormattingProvider', "Whether the editor has a document selection formatting provider"));
  static final hasMultipleDocumentFormattingProvider = RawContextKey<bool>('editorHasMultipleDocumentFormattingProvider', false, localize('editorHasMultipleDocumentFormattingProvider', "Whether the editor has multiple document formatting providers"));
  static final hasMultipleDocumentSelectionFormattingProvider = RawContextKey<bool>('editorHasMultipleDocumentSelectionFormattingProvider', false, localize('editorHasMultipleDocumentSelectionFormattingProvider', "Whether the editor has multiple document selection formatting providers"));
  static final selectionHasDiagnostics = RawContextKey<bool>('editorSelectionHasDiagnostics', false, localize('editorSelectionHasDiagnostics', "Whether any diagnostic is present in the current editor selection"));
}
