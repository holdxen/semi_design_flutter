// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/actions/common/actions.ts
// Translated 1:1. Interfaces -> abstract classes; const `IMenuService` keeps
// name, interface gets `Type` suffix. `MenuId` static constants are all 266
// real identifiers from the source (name != id where the source differs).
// `MicrotaskEmitter`/`LinkedList` are the real ported base implementations.
// `ContextKeyExpression` carried as Object? through the action options.
// Runtime truth: tool/ts2dart/_batch144_truth.cjs (real actions + recursive
// deps; createDecorator stubbed).
// ---------------------------------------------------------------------------

import 'dart:async' show Future;

import '../../../base/common/actions.dart'
    show IAction, SubmenuAction;
import '../../../base/common/event.dart'
    show Event, EmitterOptionsWithMerge, MicrotaskEmitter;
import '../../../base/common/lifecycle.dart'
    show IDisposable, DisposableStore, dispose, markAsSingleton, toDisposable;
import '../../../base/common/linkedList.dart' show LinkedList;
import '../../../base/common/themables.dart' show ThemeIcon;
import '../../action/common/action.dart'
    show ICommandAction, ICommandActionTitle, Icon, ILocalizedString;
// ignore: unused_import
import '../../action/common/actionCommonCategories.dart' show Categories;
import '../../commands/common/commands.dart'
    show
        CommandsRegistry,
        ICommand,
        ICommandMetadata,
        ICommandServiceType;
import '../../contextkey/common/contextkey.dart'
    show ContextKeyExpr, ContextKeyExpression, IContextKeyServiceType;
import '../../instantiation/common/instantiation.dart'
    show ServicesAccessor, ServiceIdentifier, createDecorator;
import '../../keybinding/common/keybindingsRegistry.dart'
    show IKeybindingRule, KeybindingsRegistry;

/// 1:1: `export interface IMenuItem`
abstract class IMenuItem {
  ICommandAction get command;
  ICommandAction? get alt;
  ContextKeyExpression? get when;
  String? get group; // 'navigation' | string
  num? get order;
  bool? get isHiddenByDefault;
}

/// 1:1: `export interface ISubmenuItem`
abstract class ISubmenuItem {
  Object get title; // String | ICommandActionTitle
  MenuId get submenu;
  Icon? get icon;
  ContextKeyExpression? get when;
  ContextKeyExpression? get toggled;
  String? get group;
  num? get order;
  bool? get isSelection;
  bool? get isAlwaysShown;
  Object? get isSplitButton; // bool | split-button options map
}

/// 1:1: `export function isIMenuItem(item: unknown)`
bool isIMenuItem(Object? item) {
  if (item == null) return false;
  if (item is Map) return item['command'] != null;
  final dynamic d = item;
  try {
    return d.command != null;
  } catch (_) {
    return false;
  }
}

/// 1:1: `export function isISubmenuItem(item: unknown)`
bool isISubmenuItem(Object? item) {
  if (item == null) return false;
  if (item is Map) return item['submenu'] != null;
  final dynamic d = item;
  try {
    return d.submenu != null;
  } catch (_) {
    return false;
  }
}

/// 1:1: `export interface IMenuGroup`
abstract class IMenuGroup {
  String get group;
  String get title;
}

/// 1:1: `export class MenuId`
class MenuId {
  static final Map<String, MenuId> _instances = <String, MenuId>{};

  static final MenuId CommandPalette = MenuId('CommandPalette');
  static final MenuId DebugBreakpointsContext = MenuId('DebugBreakpointsContext');
  static final MenuId DebugCallStackContext = MenuId('DebugCallStackContext');
  static final MenuId DebugConsoleContext = MenuId('DebugConsoleContext');
  static final MenuId DebugVariablesContext = MenuId('DebugVariablesContext');
  static final MenuId NotebookVariablesContext = MenuId('NotebookVariablesContext');
  static final MenuId DebugHoverContext = MenuId('DebugHoverContext');
  static final MenuId DebugWatchContext = MenuId('DebugWatchContext');
  static final MenuId DebugToolBar = MenuId('DebugToolBar');
  static final MenuId DebugToolBarStop = MenuId('DebugToolBarStop');
  static final MenuId DebugDisassemblyContext = MenuId('DebugDisassemblyContext');
  static final MenuId DebugCallStackToolbar = MenuId('DebugCallStackToolbar');
  static final MenuId DebugCreateConfiguration = MenuId('DebugCreateConfiguration');
  static final MenuId DebugScopesContext = MenuId('DebugScopesContext');
  static final MenuId EditorContext = MenuId('EditorContext');
  static final MenuId SimpleEditorContext = MenuId('SimpleEditorContext');
  static final MenuId EditorContent = MenuId('EditorContent');
  static final MenuId EditorLineNumberContext = MenuId('EditorLineNumberContext');
  static final MenuId EditorContextCopy = MenuId('EditorContextCopy');
  static final MenuId EditorContextPeek = MenuId('EditorContextPeek');
  static final MenuId EditorContextShare = MenuId('EditorContextShare');
  static final MenuId EditorTitle = MenuId('EditorTitle');
  static final MenuId EditorTitleLayout = MenuId('EditorTitleLayout');
  static final MenuId ModalEditorTitle = MenuId('ModalEditorTitle');
  static final MenuId ModalEditorTitleContext = MenuId('ModalEditorTitleContext');
  static final MenuId ModalEditorEditorTitle = MenuId('ModalEditorEditorTitle');
  static final MenuId CompactWindowEditorTitle = MenuId('CompactWindowEditorTitle');
  static final MenuId EditorTitleRun = MenuId('EditorTitleRun');
  static final MenuId EditorTitleContext = MenuId('EditorTitleContext');
  static final MenuId EditorTitleContextShare = MenuId('EditorTitleContextShare');
  static final MenuId EmptyEditorGroup = MenuId('EmptyEditorGroup');
  static final MenuId EmptyEditorGroupContext = MenuId('EmptyEditorGroupContext');
  static final MenuId EditorGroupWatermarkToolbar = MenuId('EditorGroupWatermarkToolbar');
  static final MenuId EditorTabsBarContext = MenuId('EditorTabsBarContext');
  static final MenuId EditorTabsBarShowTabsSubmenu = MenuId('EditorTabsBarShowTabsSubmenu');
  static final MenuId EditorTabsBarAddTab = MenuId('EditorTabsBarAddTab');
  static final MenuId EditorTabsBarShowTabsZenModeSubmenu = MenuId('EditorTabsBarShowTabsZenModeSubmenu');
  static final MenuId EditorActionsPositionSubmenu = MenuId('EditorActionsPositionSubmenu');
  static final MenuId DiffEditorViewSubmenu = MenuId('DiffEditorViewSubmenu');
  static final MenuId EditorRenderWhitespaceSubmenu = MenuId('EditorRenderWhitespaceSubmenu');
  static final MenuId EditorSplitMoveSubmenu = MenuId('EditorSplitMoveSubmenu');
  static final MenuId ExplorerContext = MenuId('ExplorerContext');
  static final MenuId ExplorerContextShare = MenuId('ExplorerContextShare');
  static final MenuId ExtensionContext = MenuId('ExtensionContext');
  static final MenuId ExtensionEditorContextMenu = MenuId('ExtensionEditorContextMenu');
  static final MenuId GlobalActivity = MenuId('GlobalActivity');
  static final MenuId CommandCenter = MenuId('CommandCenter');
  static final MenuId CommandCenterCenter = MenuId('CommandCenterCenter');
  static final MenuId LayoutControlMenuSubmenu = MenuId('LayoutControlMenuSubmenu');
  static final MenuId LayoutControlMenu = MenuId('LayoutControlMenu');
  static final MenuId MenubarMainMenu = MenuId('MenubarMainMenu');
  static final MenuId MenubarAppearanceMenu = MenuId('MenubarAppearanceMenu');
  static final MenuId MenubarDebugMenu = MenuId('MenubarDebugMenu');
  static final MenuId MenubarEditMenu = MenuId('MenubarEditMenu');
  static final MenuId MenubarCopy = MenuId('MenubarCopy');
  static final MenuId MenubarFileMenu = MenuId('MenubarFileMenu');
  static final MenuId MenubarGoMenu = MenuId('MenubarGoMenu');
  static final MenuId MenubarHelpMenu = MenuId('MenubarHelpMenu');
  static final MenuId MenubarLayoutMenu = MenuId('MenubarLayoutMenu');
  static final MenuId MenubarNewBreakpointMenu = MenuId('MenubarNewBreakpointMenu');
  static final MenuId PanelAlignmentMenu = MenuId('PanelAlignmentMenu');
  static final MenuId PanelPositionMenu = MenuId('PanelPositionMenu');
  static final MenuId ActivityBarPositionMenu = MenuId('ActivityBarPositionMenu');
  static final MenuId NotificationsCenterPositionMenu = MenuId('NotificationsCenterPositionMenu');
  static final MenuId MenubarPreferencesMenu = MenuId('MenubarPreferencesMenu');
  static final MenuId MenubarRecentMenu = MenuId('MenubarRecentMenu');
  static final MenuId MenubarSelectionMenu = MenuId('MenubarSelectionMenu');
  static final MenuId MenubarShare = MenuId('MenubarShare');
  static final MenuId MenubarSwitchEditorMenu = MenuId('MenubarSwitchEditorMenu');
  static final MenuId MenubarSwitchGroupMenu = MenuId('MenubarSwitchGroupMenu');
  static final MenuId MenubarTerminalMenu = MenuId('MenubarTerminalMenu');
  static final MenuId MenubarTerminalSuggestStatusMenu = MenuId('MenubarTerminalSuggestStatusMenu');
  static final MenuId MenubarViewMenu = MenuId('MenubarViewMenu');
  static final MenuId MenubarHomeMenu = MenuId('MenubarHomeMenu');
  static final MenuId OpenEditorsContext = MenuId('OpenEditorsContext');
  static final MenuId OpenEditorsContextShare = MenuId('OpenEditorsContextShare');
  static final MenuId ProblemsPanelContext = MenuId('ProblemsPanelContext');
  static final MenuId SCMInputBox = MenuId('SCMInputBox');
  static final MenuId SCMChangeContext = MenuId('SCMChangeContext');
  static final MenuId SCMResourceContext = MenuId('SCMResourceContext');
  static final MenuId SCMResourceContextShare = MenuId('SCMResourceContextShare');
  static final MenuId SCMResourceFolderContext = MenuId('SCMResourceFolderContext');
  static final MenuId SCMResourceGroupContext = MenuId('SCMResourceGroupContext');
  static final MenuId SCMSourceControl = MenuId('SCMSourceControl');
  static final MenuId SCMSourceControlInline = MenuId('SCMSourceControlInline');
  static final MenuId SCMSourceControlTitle = MenuId('SCMSourceControlTitle');
  static final MenuId SCMHistoryTitle = MenuId('SCMHistoryTitle');
  static final MenuId SCMHistoryItemContext = MenuId('SCMHistoryItemContext');
  static final MenuId SCMHistoryItemChangeContext = MenuId('SCMHistoryItemChangeContext');
  static final MenuId SCMHistoryItemRefContext = MenuId('SCMHistoryItemRefContext');
  static final MenuId SCMArtifactGroupContext = MenuId('SCMArtifactGroupContext');
  static final MenuId SCMArtifactContext = MenuId('SCMArtifactContext');
  static final MenuId SCMQuickDiffDecorations = MenuId('SCMQuickDiffDecorations');
  static final MenuId SCMTitle = MenuId('SCMTitle');
  static final MenuId SearchContext = MenuId('SearchContext');
  static final MenuId SearchActionMenu = MenuId('SearchActionContext');
  static final MenuId StatusBarWindowIndicatorMenu = MenuId('StatusBarWindowIndicatorMenu');
  static final MenuId StatusBarRemoteIndicatorMenu = MenuId('StatusBarRemoteIndicatorMenu');
  static final MenuId StickyScrollContext = MenuId('StickyScrollContext');
  static final MenuId TestItem = MenuId('TestItem');
  static final MenuId TestItemGutter = MenuId('TestItemGutter');
  static final MenuId TestProfilesContext = MenuId('TestProfilesContext');
  static final MenuId TestMessageContext = MenuId('TestMessageContext');
  static final MenuId TestMessageContent = MenuId('TestMessageContent');
  static final MenuId TestPeekElement = MenuId('TestPeekElement');
  static final MenuId TestPeekTitle = MenuId('TestPeekTitle');
  static final MenuId TestCallStack = MenuId('TestCallStack');
  static final MenuId TestCoverageFilterItem = MenuId('TestCoverageFilterItem');
  static final MenuId TouchBarContext = MenuId('TouchBarContext');
  static final MenuId TitleBar = MenuId('TitleBar');
  static final MenuId TitleBarAdjacentCenter = MenuId('TitleBarAdjacentCenter');
  static final MenuId TitleBarUpdate = MenuId('TitleBarUpdate');
  static final MenuId TitleBarContext = MenuId('TitleBarContext');
  static final MenuId TitleBarTitleContext = MenuId('TitleBarTitleContext');
  static final MenuId TunnelContext = MenuId('TunnelContext');
  static final MenuId TunnelPrivacy = MenuId('TunnelPrivacy');
  static final MenuId TunnelProtocol = MenuId('TunnelProtocol');
  static final MenuId TunnelPortInline = MenuId('TunnelInline');
  static final MenuId TunnelTitle = MenuId('TunnelTitle');
  static final MenuId TunnelLocalAddressInline = MenuId('TunnelLocalAddressInline');
  static final MenuId TunnelOriginInline = MenuId('TunnelOriginInline');
  static final MenuId ViewItemContext = MenuId('ViewItemContext');
  static final MenuId ViewContainerTitle = MenuId('ViewContainerTitle');
  static final MenuId ViewContainerTitleContext = MenuId('ViewContainerTitleContext');
  static final MenuId ViewTitle = MenuId('ViewTitle');
  static final MenuId ViewTitleContext = MenuId('ViewTitleContext');
  static final MenuId CommentEditorActions = MenuId('CommentEditorActions');
  static final MenuId CommentThreadTitle = MenuId('CommentThreadTitle');
  static final MenuId CommentThreadActions = MenuId('CommentThreadActions');
  static final MenuId CommentThreadAdditionalActions = MenuId('CommentThreadAdditionalActions');
  static final MenuId CommentThreadTitleContext = MenuId('CommentThreadTitleContext');
  static final MenuId CommentThreadCommentContext = MenuId('CommentThreadCommentContext');
  static final MenuId CommentTitle = MenuId('CommentTitle');
  static final MenuId CommentActions = MenuId('CommentActions');
  static final MenuId CommentsViewThreadActions = MenuId('CommentsViewThreadActions');
  static final MenuId InteractiveToolbar = MenuId('InteractiveToolbar');
  static final MenuId InteractiveCellTitle = MenuId('InteractiveCellTitle');
  static final MenuId InteractiveCellDelete = MenuId('InteractiveCellDelete');
  static final MenuId InteractiveCellExecute = MenuId('InteractiveCellExecute');
  static final MenuId InteractiveInputExecute = MenuId('InteractiveInputExecute');
  static final MenuId InteractiveInputConfig = MenuId('InteractiveInputConfig');
  static final MenuId ReplInputExecute = MenuId('ReplInputExecute');
  static final MenuId IssueReporter = MenuId('IssueReporter');
  static final MenuId NotebookToolbar = MenuId('NotebookToolbar');
  static final MenuId NotebookToolbarContext = MenuId('NotebookToolbarContext');
  static final MenuId NotebookStickyScrollContext = MenuId('NotebookStickyScrollContext');
  static final MenuId NotebookCellTitle = MenuId('NotebookCellTitle');
  static final MenuId NotebookCellDelete = MenuId('NotebookCellDelete');
  static final MenuId NotebookCellInsert = MenuId('NotebookCellInsert');
  static final MenuId NotebookCellBetween = MenuId('NotebookCellBetween');
  static final MenuId NotebookCellListTop = MenuId('NotebookCellTop');
  static final MenuId NotebookCellExecute = MenuId('NotebookCellExecute');
  static final MenuId NotebookCellExecuteGoTo = MenuId('NotebookCellExecuteGoTo');
  static final MenuId NotebookCellExecutePrimary = MenuId('NotebookCellExecutePrimary');
  static final MenuId NotebookDiffCellInputTitle = MenuId('NotebookDiffCellInputTitle');
  static final MenuId NotebookDiffDocumentMetadata = MenuId('NotebookDiffDocumentMetadata');
  static final MenuId NotebookDiffCellMetadataTitle = MenuId('NotebookDiffCellMetadataTitle');
  static final MenuId NotebookDiffCellOutputsTitle = MenuId('NotebookDiffCellOutputsTitle');
  static final MenuId NotebookOutputToolbar = MenuId('NotebookOutputToolbar');
  static final MenuId NotebookOutlineFilter = MenuId('NotebookOutlineFilter');
  static final MenuId NotebookOutlineActionMenu = MenuId('NotebookOutlineActionMenu');
  static final MenuId NotebookEditorLayoutConfigure = MenuId('NotebookEditorLayoutConfigure');
  static final MenuId NotebookKernelSource = MenuId('NotebookKernelSource');
  static final MenuId BulkEditTitle = MenuId('BulkEditTitle');
  static final MenuId BulkEditContext = MenuId('BulkEditContext');
  static final MenuId TimelineItemContext = MenuId('TimelineItemContext');
  static final MenuId TimelineTitle = MenuId('TimelineTitle');
  static final MenuId TimelineTitleContext = MenuId('TimelineTitleContext');
  static final MenuId TimelineFilterSubMenu = MenuId('TimelineFilterSubMenu');
  static final MenuId AccountsContext = MenuId('AccountsContext');
  static final MenuId SidebarTitle = MenuId('SidebarTitle');
  static final MenuId PanelTitle = MenuId('PanelTitle');
  static final MenuId AuxiliaryBarTitle = MenuId('AuxiliaryBarTitle');
  static final MenuId TerminalInstanceContext = MenuId('TerminalInstanceContext');
  static final MenuId TerminalEditorInstanceContext = MenuId('TerminalEditorInstanceContext');
  static final MenuId TerminalNewDropdownContext = MenuId('TerminalNewDropdownContext');
  static final MenuId TerminalTabContext = MenuId('TerminalTabContext');
  static final MenuId TerminalTabEmptyAreaContext = MenuId('TerminalTabEmptyAreaContext');
  static final MenuId TerminalStickyScrollContext = MenuId('TerminalStickyScrollContext');
  static final MenuId WebviewContext = MenuId('WebviewContext');
  static final MenuId InlineCompletionsActions = MenuId('InlineCompletionsActions');
  static final MenuId InlineEditsActions = MenuId('InlineEditsActions');
  static final MenuId NewFile = MenuId('NewFile');
  static final MenuId MergeInput1Toolbar = MenuId('MergeToolbar1Toolbar');
  static final MenuId MergeInput2Toolbar = MenuId('MergeToolbar2Toolbar');
  static final MenuId MergeBaseToolbar = MenuId('MergeBaseToolbar');
  static final MenuId MergeInputResultToolbar = MenuId('MergeToolbarResultToolbar');
  static final MenuId InlineSuggestionToolbar = MenuId('InlineSuggestionToolbar');
  static final MenuId InlineEditToolbar = MenuId('InlineEditToolbar');
  static final MenuId ChatContext = MenuId('ChatContext');
  static final MenuId ChatCodeBlock = MenuId('ChatCodeblock');
  static final MenuId ChatCompareBlock = MenuId('ChatCompareBlock');
  static final MenuId ChatMessageTitle = MenuId('ChatMessageTitle');
  static final MenuId ChatWelcomeContext = MenuId('ChatWelcomeContext');
  static final MenuId ChatMessageFooter = MenuId('ChatMessageFooter');
  static final MenuId ChatSubagentContent = MenuId('ChatSubagentContent');
  static final MenuId ChatExecute = MenuId('ChatExecute');
  static final MenuId ChatExecuteQueue = MenuId('ChatExecuteQueue');
  static final MenuId ChatExecuteSecondary = MenuId('ChatExecuteSecondary');
  static final MenuId ChatInput = MenuId('ChatInput');
  static final MenuId ChatScheduledExecute = MenuId('ChatScheduledExecute');
  static final MenuId ChatInputSecondary = MenuId('ChatInputSecondary');
  static final MenuId ChatInputStatus = MenuId('ChatInputStatus');
  static final MenuId ChatInputSide = MenuId('ChatInputSide');
  static final MenuId AutomationsDialogInput = MenuId('AutomationsDialogInput');
  static final MenuId ChatModePicker = MenuId('ChatModePicker');
  static final MenuId ChatEditingWidgetToolbar = MenuId('ChatEditingWidgetToolbar');
  static final MenuId ChatEditingSessionChangesToolbar = MenuId('ChatEditingSessionChangesToolbar');
  static final MenuId ChatEditingSessionTitleToolbar = MenuId('ChatEditingSessionTitleToolbar');
  static final MenuId ChatEditingSessionChangesVersionsSubmenu = MenuId('ChatEditingSessionChangesVersionsSubmenu');
  static final MenuId ChatEditingSessionChangesFileHeaderToolbar = MenuId('ChatEditingSessionChangesFileHeaderToolbar');
  static final MenuId ChatEditingSessionChangesFileHeaderRightToolbar = MenuId('ChatEditingSessionChangesFileHeaderRightToolbar');
  static final MenuId ChatEditingEditorContent = MenuId('ChatEditingEditorContent');
  static final MenuId ChatEditingEditorHunk = MenuId('ChatEditingEditorHunk');
  static final MenuId ChatEditingDeletedNotebookCell = MenuId('ChatEditingDeletedNotebookCell');
  static final MenuId ChatInputAttachmentToolbar = MenuId('ChatInputAttachmentToolbar');
  static final MenuId ChatEditingWidgetModifiedFilesToolbar = MenuId('ChatEditingWidgetModifiedFilesToolbar');
  static final MenuId ChatInputResourceAttachmentContext = MenuId('ChatInputResourceAttachmentContext');
  static final MenuId ChatImageContext = MenuId('ChatImageContext');
  static final MenuId ChatInputSymbolAttachmentContext = MenuId('ChatInputSymbolAttachmentContext');
  static final MenuId ChatInlineResourceAnchorContext = MenuId('ChatInlineResourceAnchorContext');
  static final MenuId ChatInlineSymbolAnchorContext = MenuId('ChatInlineSymbolAnchorContext');
  static final MenuId ChatNewMenu = MenuId('ChatNewMenu');
  static final MenuId ChatEditingCodeBlockContext = MenuId('ChatEditingCodeBlockContext');
  static final MenuId ChatTitleBarMenu = MenuId('ChatTitleBarMenu');
  static final MenuId ChatViewMode = MenuId('ChatViewMode');
  static final MenuId ChatAttachmentsContext = MenuId('ChatAttachmentsContext');
  static final MenuId ChatTipContext = MenuId('ChatTipContext');
  static final MenuId ChatTipToolbar = MenuId('ChatTipToolbar');
  static final MenuId ChatToolOutputResourceToolbar = MenuId('ChatToolOutputResourceToolbar');
  static final MenuId ChatTextEditorMenu = MenuId('ChatTextEditorMenu');
  static final MenuId ChatToolOutputResourceContext = MenuId('ChatToolOutputResourceContext');
  static final MenuId ChatMultiDiffContext = MenuId('ChatMultiDiffContext');
  static final MenuId ChatConfirmationMenu = MenuId('ChatConfirmationMenu');
  static final MenuId ChatEditorInlineMenu = MenuId('ChatEditorInlineGutter');
  static final MenuId ChatEditorInlineExecute = MenuId('ChatEditorInputExecute');
  static final MenuId ChatEditorInlineInputSide = MenuId('ChatEditorInputSide');
  static final MenuId InlineChatEditorAffordance = MenuId('InlineChatEditorAffordance');
  static final MenuId AccessibleView = MenuId('AccessibleView');
  static final MenuId MultiDiffEditorContent = MenuId('MultiDiffEditorContent');
  static final MenuId MultiDiffEditorFileToolbar = MenuId('MultiDiffEditorFileToolbar');
  static final MenuId DiffEditorHunkToolbar = MenuId('DiffEditorHunkToolbar');
  static final MenuId DiffEditorSelectionToolbar = MenuId('DiffEditorSelectionToolbar');
  static final MenuId BrowserNavigationToolbar = MenuId('BrowserNavigationToolbar');
  static final MenuId BrowserActionsToolbar = MenuId('BrowserActionsToolbar');
  static final MenuId BrowserChatActionsMenu = MenuId('BrowserChatActionsMenu');
  static final MenuId BrowserEmulationToolbar = MenuId('BrowserEmulationToolbar');
  static final MenuId AgentSessionsViewerFilterSubMenu = MenuId('AgentSessionsViewerFilterSubMenu');
  static final MenuId AgentSessionsExternalFilterSubMenu = MenuId('AgentSessionsExternalFilterSubMenu');
  static final MenuId AgentSessionsContext = MenuId('AgentSessionsContext');
  static final MenuId AgentSessionSectionContext = MenuId('AgentSessionSectionContext');
  static final MenuId AgentSessionsCreateSubMenu = MenuId('AgentSessionsCreateSubMenu');
  static final MenuId AgentSessionsToolbar = MenuId('AgentSessionsToolbar');
  static final MenuId AgentSessionItemToolbar = MenuId('AgentSessionItemToolbar');
  static final MenuId AgentSessionSectionToolbar = MenuId('AgentSessionSectionToolbar');
  static final MenuId SessionItemContextMenu = MenuId('SessionItemContextMenu');
  static final MenuId SessionHeaderContext = MenuId('SessionsSessionHeaderContext');
  static final MenuId AgentsTitleBarControlMenu = MenuId('AgentsTitleBarControlMenu');
  static final MenuId AgentsTitleBar = MenuId('AgentsTitleBar');
  static final MenuId AgentsChangesToolbar = MenuId('AgentsChangesToolbar');
  static final MenuId AgentsChangesPrimaryActionSubMenu = MenuId('AgentsChangesPrimaryActionSubMenu');
  static final MenuId AgentsChangeInlineToolbar = MenuId('AgentsChangeInlineToolbar');
  static final MenuId ChatViewSessionTitleNavigationToolbar = MenuId('ChatViewSessionTitleNavigationToolbar');
  static final MenuId ChatViewSessionTitleToolbar = MenuId('ChatViewSessionTitleToolbar');
  static final MenuId ChatContextUsageActions = MenuId('ChatContextUsageActions');
  static final MenuId MarkerHoverStatusBar = MenuId('MarkerHoverParticipant.StatusBar');

  /// 1:1: `static for(identifier: string): MenuId`
  static MenuId forId(String identifier) =>
      _instances[identifier] ?? MenuId(identifier);

  final String id;

  /// 1:1: `constructor(identifier: string)`
  MenuId(String identifier) : id = identifier {
    if (_instances.containsKey(identifier)) {
      throw StateError(
          "TypeError: MenuId with identifier '$identifier' already exists. Use MenuId.for(ident) or a unique identifier");
    }
    _instances[identifier] = this;
  }

  @override
  String toString() => id;
}

/// 1:1: `export interface IMenuActionOptions`
abstract class IMenuActionOptions {
  Object? get arg;
  List<Object?>? get args;
  bool? get shouldForwardArgs;
  bool? get renderShortTitle;
}

/// 1:1: `export interface IMenuItemActionOptions extends IMenuActionOptions`
abstract class IMenuItemActionOptions implements IMenuActionOptions {
  String? get groupTitle;
}

/// 1:1: `export interface IMenuChangeEvent`
abstract class IMenuChangeEvent {
  IMenu get menu;
  bool get isStructuralChange;
  bool get isToggleChange;
  bool get isEnablementChange;
}

/// 1:1: `export interface IMenu extends IDisposable`
abstract class IMenu implements IDisposable {
  Event<IMenuChangeEvent> get onDidChange;
  List<List<Object>> getActions([IMenuActionOptions? options]);
  // [string, Array<MenuItemAction | SubmenuItemAction>][]
}

/// 1:1: `export interface IMenuData`
abstract class IMenuData {
  Set<String> get contexts;
  List<List<Object>> get actions;
}

/// 1:1: `export const IMenuService = createDecorator<IMenuService>('menuService')`
final ServiceIdentifier<IMenuServiceType> IMenuService =
    createDecorator<IMenuServiceType>('menuService');

/// 1:1: `export interface IMenuCreateOptions`
abstract class IMenuCreateOptions {
  bool? get emitEventsForSubmenuChanges;
  bool? get eventDebounceMs;
}

/// 1:1: `export interface IMenuService`
abstract class IMenuServiceType {
  IMenu createMenu(MenuId id, IContextKeyServiceType contextKeyService,
      [IMenuCreateOptions? options]);
  void addMenuItems(
      MenuId id, List<IMenuItem> items, IContextKeyServiceType contextKeyService);
  List<MenuItemAction> getMenuActions(
      MenuId id, IContextKeyServiceType contextKeyService);
}

/// 1:1: `type ICommandsMap = Map<string, ICommandAction>`
typedef ICommandsMap = Map<String, ICommandAction>;

/// 1:1: `export interface IMenuRegistryChangeEvent`
abstract class IMenuRegistryChangeEvent {
  bool has(MenuId id);
}

/// 1:1: `class MenuRegistryChangeEvent`
class MenuRegistryChangeEvent implements IMenuRegistryChangeEvent {
  static final Map<MenuId, MenuRegistryChangeEvent> _all =
      <MenuId, MenuRegistryChangeEvent>{};

  static MenuRegistryChangeEvent forId(MenuId id) =>
      _all[id] ??= MenuRegistryChangeEvent._(id);

  /// 1:1: `static merge(events)` — returns a Set<MenuId> (JS Set has .has()).
  static IMenuRegistryChangeEvent merge(List<IMenuRegistryChangeEvent> events) {
    final Set<MenuId> ids = <MenuId>{};
    for (final item in events) {
      if (item is MenuRegistryChangeEvent) {
        ids.add(item._id);
      }
    }
    return _MenuIdSetEvent(ids);
  }

  final MenuId _id;

  MenuRegistryChangeEvent._(this._id);

  @override
  bool has(MenuId candidate) => candidate == _id;
}

class _MenuIdSetEvent implements IMenuRegistryChangeEvent {
  _MenuIdSetEvent(this._ids);
  final Set<MenuId> _ids;
  @override
  bool has(MenuId id) => _ids.contains(id);
}

/// 1:1: `export interface IMenuRegistry`
abstract class IMenuRegistry {
  Event<IMenuRegistryChangeEvent> get onDidChangeMenu;
  IDisposable addCommand(ICommandAction userCommand);
  ICommandAction? getCommand(String id);
  ICommandsMap getCommands();
  IDisposable appendMenuItems(
      Iterable<({MenuId id, Object item})> items);
  IDisposable appendMenuItem(MenuId menu, Object item); // IMenuItem | ISubmenuItem
  List<Object> getMenuItems(MenuId loc);
  IDisposable appendMenuGroup(MenuId menu, IMenuGroup group);
  IMenuGroup? getMenuGroup(MenuId menu, String group);
}

/// 1:1: `export const MenuRegistry: IMenuRegistry`
final IMenuRegistry MenuRegistry = _MenuRegistryImpl();

class _MenuRegistryImpl implements IMenuRegistry {
  final Map<String, ICommandAction> _commands = <String, ICommandAction>{};
  final Map<MenuId, LinkedList<Object>> _menuItems =
      <MenuId, LinkedList<Object>>{};
  final Map<MenuId, LinkedList<IMenuGroup>> _menuGroups =
      <MenuId, LinkedList<IMenuGroup>>{};
  final MicrotaskEmitter<IMenuRegistryChangeEvent> _onDidChangeMenu =
      MicrotaskEmitter<IMenuRegistryChangeEvent>(EmitterOptionsWithMerge(
          (List<IMenuRegistryChangeEvent> input) =>
              MenuRegistryChangeEvent.merge(input)));

  @override
  Event<IMenuRegistryChangeEvent> get onDidChangeMenu => _onDidChangeMenu.event;

  @override
  IDisposable addCommand(ICommandAction command) {
    _commands[command.id] = command;
    _onDidChangeMenu.fire(MenuRegistryChangeEvent.forId(MenuId.CommandPalette));
    return markAsSingleton(toDisposable(() {
      if (_commands.remove(command.id) != null) {
        _onDidChangeMenu.fire(
            MenuRegistryChangeEvent.forId(MenuId.CommandPalette));
      }
    }));
  }

  @override
  ICommandAction? getCommand(String id) => _commands[id];

  @override
  ICommandsMap getCommands() {
    final ICommandsMap map = <String, ICommandAction>{};
    _commands.forEach((key, value) => map[key] = value);
    return map;
  }

  @override
  IDisposable appendMenuItem(MenuId id, Object item) {
    LinkedList<Object>? list = _menuItems[id];
    if (list == null) {
      list = LinkedList<Object>();
      _menuItems[id] = list;
    }
    final void Function() rm = list.push(item);
    _onDidChangeMenu.fire(MenuRegistryChangeEvent.forId(id));
    return markAsSingleton(toDisposable(() {
      rm();
      _onDidChangeMenu.fire(MenuRegistryChangeEvent.forId(id));
    }));
  }

  @override
  IDisposable appendMenuItems(Iterable<({MenuId id, Object item})> items) {
    final DisposableStore result = DisposableStore();
    for (final e in items) {
      result.add(appendMenuItem(e.id, e.item));
    }
    return result;
  }

  @override
  List<Object> getMenuItems(MenuId id) {
    late final List<Object> result;
    final LinkedList<Object>? list = _menuItems[id];
    if (list != null) {
      result = List<Object>.from(list.iterable);
    } else {
      result = <Object>[];
    }
    if (id == MenuId.CommandPalette) {
      _appendImplicitItems(result);
    }
    return result;
  }

  @override
  IDisposable appendMenuGroup(MenuId id, IMenuGroup group) {
    LinkedList<IMenuGroup>? list = _menuGroups[id];
    if (list == null) {
      list = LinkedList<IMenuGroup>();
      _menuGroups[id] = list;
    }
    // Latest first, so that it applies until disposed
    final void Function() rm = list.unshift(group);
    _onDidChangeMenu.fire(MenuRegistryChangeEvent.forId(id));
    return markAsSingleton(toDisposable(() {
      rm();
      _onDidChangeMenu.fire(MenuRegistryChangeEvent.forId(id));
    }));
  }

  @override
  IMenuGroup? getMenuGroup(MenuId id, String group) {
    for (final candidate in _menuGroups[id]?.iterable ?? <IMenuGroup>[]) {
      if (candidate.group == group) {
        return candidate;
      }
    }
    return null;
  }

  void _appendImplicitItems(List<Object> result) {
    final Set<String> set = <String>{};
    for (final item in result) {
      if (isIMenuItem(item)) {
        final Object? command;
        final Object? alt;
        if (item is Map) {
          command = item['command'];
          alt = item['alt'];
        } else {
          final IMenuItem mi = item as IMenuItem;
          command = mi.command;
          alt = mi.alt;
        }
        set.add((command as ICommandAction).id);
        if (alt != null) {
          set.add((alt as ICommandAction).id);
        }
      }
    }
    _commands.forEach((String id, ICommandAction command) {
      if (!set.contains(id)) {
        result.add(_ImplicitMenuItem(command));
      }
    });
  }
}

// 1:1: implicit items are added as `{ command }` structural objects.
class _ImplicitMenuItem implements IMenuItem {
  _ImplicitMenuItem(this.command);
  @override
  final ICommandAction command;
  @override
  ICommandAction? get alt => null;
  @override
  ContextKeyExpression? get when => null;
  @override
  String? get group => null;
  @override
  num? get order => null;
  @override
  bool? get isHiddenByDefault => null;
}

/// 1:1: `export interface IMenuItemHide`
abstract class IMenuItemHide {
  bool get isHidden;
  bool get isModifiedFromDefault;
  IAction get hide;
  IAction get toggle;
}

/// 1:1: `export class SubmenuItemAction extends SubmenuAction`
class SubmenuItemAction extends SubmenuAction {
  SubmenuItemAction(
    this.item,
    this.hideActions,
    List<IAction> actions, [
    bool? checked,
    this.groupTitle,
  ]) : super('submenuitem.${item.submenu.id}',
            item.title is String ? item.title as String : (item.title as ICommandActionTitle).value,
            actions, 'submenu', checked);

  // ignore: override_on_non_overriding_member
  @override
  final ISubmenuItem item;
  final IMenuItemHide? hideActions;
  final String? groupTitle;
}

/// JS reads `.value` on a String | ILocalizedString | plain `{value}` carrier.
String _localizedValue(Object? v) {
  if (v is String) return v;
  if (v is ILocalizedString) return v.value;
  if (v is Map) return v['value'] as String? ?? '';
  return '';
}

/// 1:1: `export class MenuItemAction implements IAction`
class MenuItemAction implements IAction {
  /// 1:1: `static label(action, options?)` (renamed: static/instance clash).
  static String labelStatic(ICommandAction action,
      [IMenuActionOptions? options]) {
    final bool short = (options?.renderShortTitle ?? false) &&
        action.shortTitle != null;
    if (short) {
      return _localizedValue(action.shortTitle);
    }
    return _localizedValue(action.title);
  }

  MenuItemAction(
    ICommandAction item,
    ICommandAction? alt,
    IMenuItemActionOptions? options,
    this.hideActions,
    this.menuKeybinding,
    IContextKeyServiceType contextKeyService,
    ICommandServiceType commandService,
  )   : id = item.id,
        label = MenuItemAction.labelStatic(item, options),
        tooltip = ((item.tooltip is String
                ? item.tooltip as String
                : (item.tooltip as ILocalizedString?)?.value) ??
            ''),
        enabled = !(item.precondition != null) ||
            contextKeyService.contextMatchesRules(item.precondition),
        checked = null,
        item = item,
        alt = alt != null
            ? MenuItemAction(alt, null, options, hideActions, null,
                contextKeyService, commandService)
            : null,
        groupTitle = options?.groupTitle,
        _options = options,
        _commandService = commandService {
    Icon? icon;
    final Object? toggledRaw = item.toggled;
    if (toggledRaw != null) {
      final Map<String, Object?> toggled;
      if (toggledRaw is Map && toggledRaw.containsKey('condition')) {
        toggled = toggledRaw.cast<String, Object?>();
      } else {
        toggled = <String, Object?>{'condition': toggledRaw};
      }
      final ContextKeyExpression? condition =
          toggled['condition'] as ContextKeyExpression?;
      checked = contextKeyService.contextMatchesRules(condition);
      final Object? tt = toggled['tooltip'];
      if (checked == true && tt != null) {
        tooltip = tt is String ? tt : (tt as ILocalizedString).value;
      }
      if (checked == true && ThemeIcon.isThemeIcon(toggled['icon'])) {
        icon = toggled['icon'] as Icon;
      }
      final Object? ti = toggled['title'];
      if (checked == true && ti != null) {
        label = ti is String ? ti : (ti as ILocalizedString).value;
      }
    }
    if (icon == null) {
      icon = ThemeIcon.isThemeIcon(item.icon) ? item.icon : null;
    }
    cssClass = icon != null ? ThemeIcon.asClassName(icon as ThemeIcon) : null;
  }

  @override
  final String id;
  @override
  String label;
  @override
  String tooltip;
  @override
  String? cssClass;
  @override
  final bool enabled;
  @override
  bool? checked;

  final ICommandAction item;
  final MenuItemAction? alt;
  final String? groupTitle;
  final IMenuItemHide? hideActions;
  final IAction? menuKeybinding;
  final IMenuItemActionOptions? _options;
  final ICommandServiceType _commandService;

  @override
  Future<void> run([Object? event, Object? data]) {
    List<Object?> runArgs = <Object?>[];
    final List<Object?>? args = _options?.args;
    if (args != null) {
      runArgs = <Object?>[...runArgs, ...args];
    } else {
      final Object? arg = _options?.arg;
      if (arg != null) {
        runArgs = <Object?>[...runArgs, arg];
      }
    }
    if (_options?.shouldForwardArgs == true) {
      final List<Object?>? forwarded = (event is List) ? event.cast<Object?>() : null;
      if (forwarded != null) {
        runArgs = <Object?>[...runArgs, ...forwarded];
      }
    }
    return _commandService.executeCommand(id, runArgs);
  }
}

/// 1:1: `export function getMenuActionGroupTitle(action)`
String? getMenuActionGroupTitle(IAction action) {
  if (action is MenuItemAction) {
    return action.groupTitle;
  }
  if (action is SubmenuItemAction) {
    return action.groupTitle;
  }
  return null;
}

// #region --- IAction2

/// 1:1: `type OneOrN<T> = T | T[]`
typedef OneOrN<T> = Object; // T | List<T>

/// 1:1: `interface IAction2CommonOptions extends ICommandAction`
abstract class IAction2CommonOptions implements ICommandAction {
  Object? get menu;
  Object? get keybinding;
}

/// 1:1: `interface IBaseAction2Options extends IAction2CommonOptions`
abstract class IBaseAction2Options implements IAction2CommonOptions {
  bool? get f1;
}

/// 1:1: `export interface ICommandPaletteOptions extends IAction2CommonOptions`
abstract class ICommandPaletteOptions implements IAction2CommonOptions {
  @override
  ICommandActionTitle get title;
  Object? get category; // keyof typeof Categories | ILocalizedString
  // ignore: override_on_non_overriding_member
  @override
  bool get f1;
}

/// 1:1: `export type IAction2Options`
typedef IAction2Options = Object; // ICommandPaletteOptions | IBaseAction2Options

/// 1:1: `export interface IAction2F1RequiredOptions`
abstract class IAction2F1RequiredOptions {
  ICommandActionTitle get title;
  Object? get category;
}

/// 1:1: `export abstract class Action2`
abstract class Action2 {
  Action2(this.desc);
  final IAction2Options desc;
  void run(ServicesAccessor accessor, [List<Object?> args = const <Object?>[]]);
}

/// 1:1: `export function registerAction2(ctor)`
IDisposable registerAction2(Action2 Function() ctor) {
  final List<IDisposable> disposables = <IDisposable>[];
  final Action2 action = ctor();

  final dynamic desc = action.desc;
  final Object? f1 = desc.f1;
  final Object? menu = desc.menu;
  final Object? keybinding = desc.keybinding;
  final String id = desc.id as String;
  final Object? precondition = desc.precondition;
  final Object? title = desc.title;
  final String titleValue = title is String
      ? title
      : (title as ILocalizedString?)?.value ?? '';

  if (CommandsRegistry.getCommand(id) != null) {
    throw StateError('Cannot register two commands with the same id: $id');
  }

  // command
  disposables.add(CommandsRegistry.registerCommand(ICommand(
    id: id,
    handler: (ServicesAccessor accessor, List<Object?> args) =>
        action.run(accessor, args),
    metadata:
        desc.metadata ?? ICommandMetadata(description: titleValue),
  )));

  // menu
  void appendOne(Object m) {
    final dynamic md = m;
    final Object? prec = md.precondition;
    final Map<String, Object?> command = <String, Object?>{
      'id': id,
      'title': title,
      if (precondition != null) 'precondition': precondition,
    };
    if (identical(prec, null)) {
      command.remove('precondition');
    }
    final Map<String, Object?> item = <String, Object?>{...command};
    if (m is Map) {
      item.addAll(m.cast<String, Object?>());
    }
    disposables.add(MenuRegistry.appendMenuItem(md.id as MenuId, item));
  }

  if (menu is List) {
    for (final item in menu) {
      appendOne(item as Object);
    }
  } else if (menu != null) {
    appendOne(menu);
  }
  if (f1 == true) {
    disposables.add(MenuRegistry.appendMenuItem(
        MenuId.CommandPalette, <String, Object?>{
      'command': <String, Object?>{
        'id': id,
        'title': title,
        if (precondition != null) 'precondition': precondition,
      },
      'when': precondition,
    }));
    disposables.add(MenuRegistry.addCommand(desc as ICommandAction));
  }

  // keybinding
  void registerKb(Object kb) {
    final dynamic kd = kb;
    final Object? when = kd.when;
    final Object? combined = precondition != null
        ? ContextKeyExpr.and(<ContextKeyExpression?>[
            precondition as ContextKeyExpression,
            when as ContextKeyExpression?
          ])
        : when;
    final Map<String, Object?> rule = <String, Object?>{
      'id': id,
      if (combined != null) 'when': combined,
    };
    if (kb is Map) {
      rule.addAll(kb.cast<String, Object?>());
      rule['id'] = id;
    }
    disposables.add(KeybindingsRegistry.registerKeybindingRule(
        _keybindingRuleFromMap(rule)));
  }

  if (keybinding is List) {
    for (final item in keybinding) {
      registerKb(item as Object);
    }
  } else if (keybinding != null) {
    registerKb(keybinding);
  }

  return toDisposable(() => dispose(disposables));
}

/// 1:1 structural carrier: spread `{...item, id, when}` into IKeybindingRule.
IKeybindingRule _keybindingRuleFromMap(Map<String, Object?> m) {
  final int? primary = (m['primary'] as num?)?.toInt();
  final int weight = (m['weight'] as num?)?.toInt() ?? 0;
  return IKeybindingRule(
    id: m['id'] as String,
    weight: weight,
    when: m['when'],
    args: m['args'],
    systemWide: m['systemWide'] as bool?,
    primary: primary,
  );
}

// #endregion
