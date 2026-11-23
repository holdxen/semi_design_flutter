// 1:1 port of vs/editor/common/standaloneStrings.ts
//
// Each TS `export namespace` is carried as a Dart class with static members.
// `nls.localize(key, message, ...args)` maps to `localize(key, message, args)`.

import '../../nls.dart' show localize;

/// 1:1: `export namespace AccessibilityHelpNLS`
class AccessibilityHelpNLS {
  static final String accessibilityHelpTitle =
      localize('accessibilityHelpTitle', 'Accessibility Help');
  static final String openingDocs =
      localize('openingDocs', 'Opening the Accessibility documentation page.');
  static final String readonlyDiffEditor = localize(
      'readonlyDiffEditor', 'You are in a read-only pane of a diff editor.');
  static final String editableDiffEditor =
      localize('editableDiffEditor', 'You are in a pane of a diff editor.');
  static final String readonlyEditor =
      localize('readonlyEditor', 'You are in a read-only code editor.');
  static final String editableEditor =
      localize('editableEditor', 'You are in a code editor.');
  static final String defaultWindowTitleIncludesEditorState = localize(
      'defaultWindowTitleIncludesEditorState',
      'activeEditorState - such as modified, problems, and more, is included as a part of the window.title setting by default. Disable it with accessibility.windowTitleOptimized.');
  static final String defaultWindowTitleExcludingEditorState = localize(
      'defaultWindowTitleExcludingEditorState',
      'activeEditorState - such as modified, problems, and more, is currently not included as a part of the window.title setting by default. Enable it with accessibility.windowTitleOptimized.');
  static final String toolbar = localize(
      'toolbar',
      "Around the workbench, when the screen reader announces you've landed in a toolbar, use narrow keys to navigate between the toolbar's actions.");
  static final String changeConfigToOnMac = localize('changeConfigToOnMac',
      'Configure the application to be optimized for usage with a Screen Reader (Command+E).');
  static final String changeConfigToOnWinLinux = localize(
      'changeConfigToOnWinLinux',
      'Configure the application to be optimized for usage with a Screen Reader (Control+E).');
  static final String auto_on = localize('auto_on',
      'The application is configured to be optimized for usage with a Screen Reader.');
  static final String auto_off = localize('auto_off',
      'The application is configured to never be optimized for usage with a Screen Reader.');
  static final String screenReaderModeEnabled = localize(
      'screenReaderModeEnabled', 'Screen Reader Optimized Mode enabled.');
  static final String screenReaderModeDisabled = localize(
      'screenReaderModeDisabled', 'Screen Reader Optimized Mode disabled.');
  static final String tabFocusModeOnMsg = localize(
      'tabFocusModeOnMsg',
      'Pressing Tab in the current editor will move focus to the next focusable element. Toggle this behavior{0}.',
      <Object?>['<keybinding:editor.action.toggleTabFocusMode>']);
  static final String tabFocusModeOffMsg = localize(
      'tabFocusModeOffMsg',
      'Pressing Tab in the current editor will insert the tab character. Toggle this behavior{0}.',
      <Object?>['<keybinding:editor.action.toggleTabFocusMode>']);
  static final String stickScroll = localize(
      'stickScrollKb',
      'Focus Sticky Scroll{0} to focus the currently nested scopes.',
      <Object?>['<keybinding:editor.action.focusStickyDebugConsole>']);
  static final String suggestActions = localize(
      'suggestActionsKb',
      'Trigger the suggest widget{0} to show possible inline suggestions.',
      <Object?>['<keybinding:editor.action.triggerSuggest>']);
  static final String acceptSuggestAction = localize(
      'acceptSuggestAction',
      'Accept suggestion{0} to accept the currently selected suggestion.',
      <Object?>['<keybinding:acceptSelectedSuggestion>']);
  static final String toggleSuggestionFocus = localize(
      'toggleSuggestionFocus',
      'Toggle focus between the suggest widget and the editor{0} and toggle details focus with{1} to learn more about the suggestion.',
      <Object?>[
        '<keybinding:focusSuggestion>',
        '<keybinding:toggleSuggestionFocus>'
      ]);
  static final String codeFolding = localize(
      'codeFolding',
      "Use code folding to collapse blocks of code and focus on the code you're interested in via the Toggle Folding Command{0}.",
      <Object?>['<keybinding:editor.toggleFold>']);
  static final String intellisense = localize(
      'intellisense',
      'Use Intellisense to improve coding efficiency and reduce errors. Trigger suggestions{0}.',
      <Object?>['<keybinding:editor.action.triggerSuggest>']);
  static final String showOrFocusHover = localize(
      'showOrFocusHover',
      'Show or focus the hover{0} to read information about the current symbol.',
      <Object?>['<keybinding:editor.action.showHover>']);
  static final String goToSymbol = localize(
      'goToSymbol',
      'Go to Symbol{0} to quickly navigate between symbols in the current file.',
      <Object?>['<keybinding:workbench.action.gotoSymbol>']);
  static final String showAccessibilityHelpAction = localize(
      'showAccessibilityHelpAction', 'Show Accessibility Help');
  static final String listSignalSounds = localize('listSignalSoundsCommand',
      'Run the command: List Signal Sounds for an overview of all sounds and their current status.');
  static final String listAlerts = localize('listAnnouncementsCommand',
      'Run the command: List Signal Announcements for an overview of announcements and their current status.');
  static final String announceCursorPosition = localize(
      'announceCursorPosition',
      'Run the command: Announce Cursor Position{0} to hear the current line and column.',
      <Object?>['<keybinding:editor.action.announceCursorPosition>']);
  static final String focusNotifications = localize(
      'focusNotifications',
      'Focus notification toasts{0} to navigate them with the keyboard. Accept the primary action of a focused notification{1}.',
      <Object?>[
        '<keybinding:notifications.focusToasts>',
        '<keybinding:notification.acceptPrimaryAction>'
      ]);
  static final String quickChat = localize(
      'quickChatCommand',
      'Toggle quick chat{0} to open or close a chat session.',
      <Object?>['<keybinding:workbench.action.quickchat.toggle>']);
  static final String startInlineChat = localize(
      'startInlineChatCommand',
      'Start inline chat{0} to create an in editor chat session.',
      <Object?>['<keybinding:inlineChat.start>']);
  static final String startDebugging = localize(
      'debug.startDebugging',
      'The Debug: Start Debugging command{0} will start a debug session.',
      <Object?>['<keybinding:workbench.action.debug.start>']);
  static final String setBreakpoint = localize(
      'debugConsole.setBreakpoint',
      'The Debug: Inline Breakpoint command{0} will set or unset a breakpoint at the current cursor position in the active editor.',
      <Object?>['<keybinding:editor.debug.action.toggleInlineBreakpoint>']);
  static final String addToWatch = localize(
      'debugConsole.addToWatch',
      'The Debug: Add to Watch command{0} will add the selected text to the watch view.',
      <Object?>['<keybinding:editor.debug.action.selectionToWatch>']);
  static final String debugExecuteSelection = localize(
      'debugConsole.executeSelection',
      'The Debug: Execute Selection command{0} will execute the selected text in the debug console.',
      <Object?>['<keybinding:editor.debug.action.selectionToRepl>']);
  static final String chatEditorModification = localize('chatEditorModification',
      'The editor contains pending modifications that have been made by chat.');
  static final String chatEditorRequestInProgress = localize(
      'chatEditorRequestInProgress',
      'The editor is currently waiting for modifications to be made by chat.');
  static final String chatEditActions = localize(
      'chatEditing.navigation',
      'Navigate between edits in the editor with navigate previous{0} and next{1} and accept{2}, reject{3} or view the diff{4} for the current change. Accept edits across all files{5}.',
      <Object?>[
        '<keybinding:chatEditor.action.navigatePrevious>',
        '<keybinding:chatEditor.action.navigateNext>',
        '<keybinding:chatEditor.action.acceptHunk>',
        '<keybinding:chatEditor.action.undoHunk>',
        '<keybinding:chatEditor.action.toggleDiff>',
        '<keybinding:chatEditor.action.acceptAllEdits>'
      ]);
  static final String editorDictation = localize(
      'editorDictation', 'Start or stop dictation in the editor{0}.',
      <Object?>['<keybinding:workbench.action.editorDictation.start>']);
}

/// 1:1: `export namespace InspectTokensNLS`
class InspectTokensNLS {
  static final String inspectTokensAction =
      localize('inspectTokens', 'Developer: Inspect Tokens');
}

/// 1:1: `export namespace GoToLineNLS`
class GoToLineNLS {
  static final String gotoLineActionLabel =
      localize('gotoLineActionLabel', 'Go to Line/Column...');
  static final String gotoOffsetActionLabel =
      localize('gotoOffsetActionLabel', 'Go to Offset...');
}

/// 1:1: `export namespace QuickHelpNLS`
class QuickHelpNLS {
  static final String helpQuickAccessActionLabel =
      localize('helpQuickAccess', 'Show all Quick Access Providers');
}

/// 1:1: `export namespace QuickCommandNLS`
class QuickCommandNLS {
  static final String quickCommandActionLabel =
      localize('quickCommandActionLabel', 'Command Palette');
  static final String quickCommandHelp =
      localize('quickCommandActionHelp', 'Show And Run Commands');
}

/// 1:1: `export namespace QuickOutlineNLS`
class QuickOutlineNLS {
  static final String quickOutlineActionLabel =
      localize('quickOutlineActionLabel', 'Go to Symbol...');
  static final String quickOutlineByCategoryActionLabel = localize(
      'quickOutlineByCategoryActionLabel', 'Go to Symbol by Category...');
}

/// 1:1: `export namespace StandaloneCodeEditorNLS`
class StandaloneCodeEditorNLS {
  static final String editorViewAccessibleLabel =
      localize('editorViewAccessibleLabel', 'Editor content');
}

/// 1:1: `export namespace ToggleHighContrastNLS`
class ToggleHighContrastNLS {
  static final String toggleHighContrast =
      localize('toggleHighContrast', 'Toggle High Contrast Theme');
}

/// 1:1: `export namespace StandaloneServicesNLS`
class StandaloneServicesNLS {
  static final String bulkEditServiceSummary =
      localize('bulkEditServiceSummary', 'Made {0} edits in {1} files');
}
