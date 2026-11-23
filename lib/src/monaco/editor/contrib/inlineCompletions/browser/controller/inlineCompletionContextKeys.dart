// 1:1: port of vs/editor/contrib/inlineCompletions/browser/controller/inlineCompletionContextKeys.ts
import '../../../../../nls.dart' show localize;
import '../../../../../platform/contextkey/common/contextkey.dart'
    show RawContextKey;

/// 1:1: `export abstract class InlineCompletionContextKeys`
abstract class InlineCompletionContextKeys {
  static final inlineSuggestionVisible = RawContextKey<bool>(
      'inlineSuggestionVisible',
      false,
      localize('inlineSuggestionVisible', "Whether an inline suggestion is visible"));

  static final inlineSuggestionAlternativeActionVisible = RawContextKey<bool>(
      'inlineSuggestionAlternativeActionVisible',
      false,
      localize('inlineSuggestionAlternativeActionVisible',
          "Whether an alternative action for the inline suggestion is visible."));

  static final inlineSuggestionHasIndentation = RawContextKey<bool>(
      'inlineSuggestionHasIndentation',
      false,
      localize('inlineSuggestionHasIndentation',
          "Whether the inline suggestion starts with whitespace"));

  static final inlineSuggestionHasIndentationLessThanTabSize = RawContextKey<bool>(
      'inlineSuggestionHasIndentationLessThanTabSize',
      true,
      localize('inlineSuggestionHasIndentationLessThanTabSize',
          "Whether the inline suggestion starts with whitespace that is less than what would be inserted by tab"));

  static final suppressSuggestions = RawContextKey<dynamic>(
      'inlineSuggestionSuppressSuggestions',
      null,
      localize('suppressSuggestions',
          "Whether suggestions should be suppressed for the current suggestion"));

  static final cursorBeforeGhostText = RawContextKey<dynamic>(
      'cursorBeforeGhostText',
      false,
      localize('cursorBeforeGhostText', "Whether the cursor is at ghost text"));

  static final cursorInIndentation = RawContextKey<dynamic>(
      'cursorInIndentation',
      false,
      localize('cursorInIndentation', "Whether the cursor is in indentation"));

  static final hasSelection = RawContextKey<dynamic>(
      'editor.hasSelection',
      false,
      localize('editor.hasSelection', "Whether the editor has a selection"));

  static final cursorAtInlineEdit = RawContextKey<dynamic>(
      'cursorAtInlineEdit',
      false,
      localize('cursorAtInlineEdit', "Whether the cursor is at an inline edit"));

  static final inlineEditVisible = RawContextKey<bool>(
      'inlineEditIsVisible',
      false,
      localize('inlineEditVisible', "Whether an inline edit is visible"));

  static final tabShouldJumpToInlineEdit = RawContextKey<dynamic>(
      'tabShouldJumpToInlineEdit',
      false,
      localize('tabShouldJumpToInlineEdit',
          "Whether tab should jump to an inline edit."));

  static final tabShouldAcceptInlineEdit = RawContextKey<dynamic>(
      'tabShouldAcceptInlineEdit',
      false,
      localize('tabShouldAcceptInlineEdit',
          "Whether tab should accept the inline edit."));

  static final inInlineEditsPreviewEditor = RawContextKey<bool>(
      'inInlineEditsPreviewEditor',
      true,
      localize('inInlineEditsPreviewEditor',
          "Whether the current code editor is showing an inline edits preview"));
}
