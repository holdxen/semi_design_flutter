// 1:1 port of vscode/src/vs/platform/accessibility/browser/accessibleView.ts
//
// The TS file is mostly declarations (three string enums, the service
// identifier and a set of interfaces); the runtime surface is the two content
// provider classes and the `isIAccessibleViewContentProvider` predicate.
//
// Adaptations (documented inline):
//  * TS `const enum` with string values -> a class of `static const String`s.
//  * TS interfaces with *field* function members (`provideContent: () => string`)
//    are declared as getters returning the function type, so the concrete
//    classes can expose plain fields.
//  * `AccesibleViewContentProvider` union -> `Object` (Dart has no unions).
//  * `isIAccessibleViewContentProvider` performs the same duck-typing for
//    `Map` payloads (JS plain objects) and for typed instances.
import '../../../base/common/actions.dart' show IAction;
import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/types.dart' show isFunction;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../../platform/keybinding/common/keybinding.dart'
    show IKeyboardEvent;
import '../../../platform/quickinput/browser/pickerQuickAccess.dart'
    show IPickerQuickAccessItem;
import '../../../platform/quickinput/common/quickInput.dart'
    show IQuickPickItem;

/// 1:1: `export const IAccessibleViewService =
/// createDecorator<IAccessibleViewService>('accessibleViewService')`.
final ServiceIdentifier<IAccessibleViewServiceType> IAccessibleViewService =
    createDecorator<IAccessibleViewServiceType>('accessibleViewService');

/// 1:1: `export const enum AccessibleViewProviderId`.
class AccessibleViewProviderId {
  static const String Terminal = 'terminal';
  static const String TerminalChat = 'terminal-chat';
  static const String TerminalHelp = 'terminal-help';
  static const String DiffEditor = 'diffEditor';
  static const String MultiDiffEditorFileList = 'multiDiffEditorFileList';
  static const String MergeEditor = 'mergeEditor';
  static const String PanelChat = 'panelChat';
  static const String ChatHtmlPreview = 'chatHtmlPreview';
  static const String CustomizationMigrations = 'customizationMigrations';
  static const String CustomizationDiscovery = 'customizationDiscovery';
  static const String Remotes = 'remotes';
  static const String McpServerConfiguration = 'mcpServerConfiguration';
  static const String ChatTerminalOutput = 'chatTerminalOutput';
  static const String ChatBackgroundShellOutput = 'chatBackgroundShellOutput';
  static const String ChatThinking = 'chatThinking';
  static const String InlineChat = 'inlineChat';
  static const String AgentChat = 'agentChat';
  static const String QuickChat = 'quickChat';
  static const String InlineCompletions = 'inlineCompletions';
  static const String KeybindingsEditor = 'keybindingsEditor';
  static const String Notebook = 'notebook';
  static const String ReplEditor = 'replEditor';
  static const String Editor = 'editor';
  static const String Hover = 'hover';
  static const String Notification = 'notification';
  static const String EmptyEditorHint = 'emptyEditorHint';
  static const String Comments = 'comments';
  static const String CommentThread = 'commentThread';
  static const String Repl = 'repl';
  static const String ReplHelp = 'replHelp';
  static const String RunAndDebug = 'runAndDebug';
  static const String Walkthrough = 'walkthrough';
  static const String ReleaseNotes = 'releaseNotes';
  static const String SourceControl = 'scm';
  static const String EditorFindHelp = 'editorFindHelp';
  static const String SearchHelp = 'searchHelp';
  static const String TerminalFindHelp = 'terminalFindHelp';
  static const String WebviewFindHelp = 'webviewFindHelp';
  static const String OutputFindHelp = 'outputFindHelp';
  static const String ChatFindHelp = 'chatFindHelp';
  static const String ChatViewSessionsList = 'chatViewSessionsList';
  static const String ProblemsFilterHelp = 'problemsFilterHelp';
  static const String SessionsChat = 'sessionsChat';
  static const String ArtifactDetails = 'artifactDetails';
  static const String SessionsStorageCleanup = 'sessionsStorageCleanup';
  static const String SessionsChanges = 'sessionsChanges';
  static const String EmptyFileEditorSearch = 'emptyFileEditorSearch';
  static const String SessionsListNotification = 'sessionsListNotification';
  static const String SessionsGetStarted = 'sessionsGetStarted';
  static const String SessionCanvas = 'sessionCanvas';
  static const String Survey = 'survey';
  static const String Automations = 'automations';
  static const String AgentsWindowExtensions = 'agentsWindowExtensions';
  static const String ConnectionDiagnostics = 'connectionDiagnostics';
  static const String BrowserElementCommenting = 'browserElementCommenting';
  static const String ScreenshotTool = 'screenshotTool';
  static const String ChatPetAchievements = 'chatPetAchievements';
  static const String ChatPetJumpGame = 'chatPetJumpGame';

  const AccessibleViewProviderId._();
}

/// 1:1: `export const enum AccessibleViewType`.
class AccessibleViewType {
  static const String Help = 'help';
  static const String View = 'view';

  const AccessibleViewType._();
}

/// 1:1: `export const enum NavigationType`.
class NavigationType {
  static const String Previous = 'previous';
  static const String Next = 'next';

  const NavigationType._();
}

/// 1:1: `export interface IAccessibleViewOptions`.
class IAccessibleViewOptions {
  IAccessibleViewOptions({
    this.readMoreUrl,
    this.language,
    required this.type,
    this.position,
    this.customHelp,
    this.id,
    this.configureKeybindingItems,
    this.configuredKeybindingItems,
  });

  String? readMoreUrl;

  /// Defaults to markdown.
  String? language;

  String type;

  /// `'bottom' | 'initial-bottom' | 'initial-bottom-preserve'`.
  String? position;

  /// A string that will be used as the content of the help dialog instead of
  /// the one provided by default.
  String Function()? customHelp;

  /// If this provider might want to request to be shown again, provide an ID.
  String? id;

  /// Keybinding items to configure.
  List<IQuickPickItem>? configureKeybindingItems;

  /// Keybinding items that are already configured.
  List<IQuickPickItem>? configuredKeybindingItems;
}

/// 1:1: `export interface IBasicContentProvider extends IDisposable`.
abstract class IBasicContentProvider implements lifecycle.IDisposable {
  String get id;
  IAccessibleViewOptions get options;
  void Function() get onClose;
  String Function() get provideContent;

  /// May return resources that are released when this showing of the view
  /// ends.
  Object? Function()? get onOpen;
  List<IAction>? get actions;
  String? Function()? get providePreviousContent;
  String? Function()? get provideNextContent;
  Event<void>? get onDidChangeContent;
}

/// 1:1: `export interface IAccessibleViewContentProvider extends
/// IBasicContentProvider, IDisposable`.
abstract class IAccessibleViewContentProvider implements IBasicContentProvider {
  @override
  String get id;
  @override
  IAccessibleViewOptions get options;

  /// The provider identifier.
  String get providerId;

  String get verbositySettingKey;

  /// Note that a Codicon class should be provided for each action.
  /// If not, a default will be used.
  void Function(IKeyboardEvent e)? get onKeyDown;

  /// When the language is markdown, this is provided by default.
  List<IAccessibleViewSymbol> Function()? get getSymbols;

  /// Note that this will only take effect if the provider has an ID.
  Event<String>? get onDidRequestClearLastProvider;
}

/// 1:1: `export interface IAccessibleViewSymbol extends
/// IPickerQuickAccessItem`.
class IAccessibleViewSymbol extends IPickerQuickAccessItem {
  IAccessibleViewSymbol({
    required super.label,
    super.id,
    super.ariaLabel,
    super.description,
    this.markdownToParse,
    this.firstListItem,
    this.lineNumber,
    this.endLineNumber,
  });

  String? markdownToParse;
  String? firstListItem;
  int? lineNumber;
  int? endLineNumber;
}

/// 1:1: `export interface IPosition`.
class IPosition {
  IPosition({required this.lineNumber, required this.column});

  int lineNumber;
  int column;
}

/// 1:1: `export interface ICodeBlockActionContext`.
class ICodeBlockActionContext {
  ICodeBlockActionContext({
    required this.code,
    this.languageId,
    required this.codeBlockIndex,
    required this.element,
  });

  String code;
  String? languageId;
  int codeBlockIndex;
  Object? element;
}

/// 1:1: `export interface IAccessibleViewService`.
abstract class IAccessibleViewServiceType {
  /// 1:1: `readonly _serviceBrand: undefined`.
  Object? get serviceBrand;

  /// The provider will be disposed when the view is closed.
  void show(Object provider, [IPosition? position]);
  void showLastProvider(String id);
  void showAccessibleViewHelp();
  void next();
  void previous();
  void navigateToCodeBlock(String type);
  void goToSymbol();
  void disableHint();
  IPosition? getPosition(String id);
  void setPosition(IPosition position, [bool? reveal, bool? select]);
  IPosition? getLastPosition();

  /// If the setting is enabled, provides the open accessible view hint as a
  /// localized string.
  String? getOpenAriaHint(String verbositySettingKey);
  ICodeBlockActionContext? getCodeBlockContext();
  void configureKeybindings(bool unassigned);
  void openHelpLink();
}

/// 1:1: `export type AccesibleViewContentProvider = AccessibleContentProvider |
/// ExtensionContentProvider`.
typedef AccesibleViewContentProvider = Object;

/// 1:1: `export class AccessibleContentProvider extends Disposable implements
/// IAccessibleViewContentProvider`.
class AccessibleContentProvider extends lifecycle.Disposable
    implements IAccessibleViewContentProvider {
  AccessibleContentProvider(
    this.id,
    this.options,
    this.provideContent,
    this.onClose,
    this.verbositySettingKey, [
    this.onOpen,
    this.actions,
    this.provideNextContent,
    this.providePreviousContent,
    this.onDidChangeContent,
    this.onKeyDown,
    this.getSymbols,
    this.onDidRequestClearLastProvider,
  ]) : super() {
    register(lifecycle.toDisposable(() => onDispose?.call()));
  }

  /// Releases caller-owned state on teardown, including context-view
  /// replacement without onClose.
  void Function()? onDispose;

  @override
  final String id;
  @override
  final IAccessibleViewOptions options;
  @override
  final String Function() provideContent;
  @override
  final void Function() onClose;
  @override
  final String verbositySettingKey;
  @override
  final Object? Function()? onOpen;
  @override
  final List<IAction>? actions;
  @override
  final String? Function()? provideNextContent;
  @override
  final String? Function()? providePreviousContent;
  @override
  final Event<void>? onDidChangeContent;
  @override
  final void Function(IKeyboardEvent e)? onKeyDown;
  @override
  final List<IAccessibleViewSymbol> Function()? getSymbols;
  @override
  final Event<String>? onDidRequestClearLastProvider;

  @override
  String get providerId => id;
}

/// 1:1: `export class ExtensionContentProvider extends Disposable implements
/// IBasicContentProvider`.
class ExtensionContentProvider extends lifecycle.Disposable
    implements IBasicContentProvider {
  ExtensionContentProvider(
    this.id,
    this.options,
    this.provideContent,
    this.onClose, [
    this.onOpen,
    this.provideNextContent,
    this.providePreviousContent,
    this.actions,
    this.onDidChangeContent,
  ]) : super();

  @override
  final String id;
  @override
  final IAccessibleViewOptions options;
  @override
  final String Function() provideContent;
  @override
  final void Function() onClose;
  @override
  final Object? Function()? onOpen;
  @override
  final String? Function()? provideNextContent;
  @override
  final String? Function()? providePreviousContent;
  @override
  final List<IAction>? actions;
  @override
  final Event<void>? onDidChangeContent;
}

/// 1:1: `export function isIAccessibleViewContentProvider(obj: unknown):
/// obj is IAccessibleViewContentProvider`.
bool isIAccessibleViewContentProvider(Object? obj) {
  if (obj == null) {
    return false;
  }
  if (obj is Map) {
    return _truthy(obj['id']) &&
        _truthy(obj['options']) &&
        isFunction(obj['provideContent']) &&
        isFunction(obj['onClose']) &&
        obj['verbositySettingKey'] is String;
  }
  if (obj is IAccessibleViewContentProvider) {
    final dynamic candidate = obj;
    return _truthy(candidate.id) &&
        _truthy(candidate.options) &&
        isFunction(candidate.provideContent) &&
        isFunction(candidate.onClose) &&
        candidate.verbositySettingKey is String;
  }
  return false;
}

/// JS truthiness for the predicate's `!!candidate.id` / `!!candidate.options`.
bool _truthy(Object? value) {
  if (value == null || value == false) return false;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}
