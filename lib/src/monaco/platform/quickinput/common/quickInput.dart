// 1:1 port of vscode/src/vs/platform/quickinput/common/quickInput.ts
//
// This file is almost entirely type surface: every `interface` is carried as
// an abstract or data class with the same members, and the runtime pieces
// (`isKeyModified`, `NO_KEY_MODS`, the enums, `QuickPickItemScorerAccessor`,
// the `IQuickInputService` decorator) are translated verbatim.
//
// Adaptations (documented inline):
//  * TS unions (`T | IQuickPickSeparator`, `string | IMarkdownString`,
//    `HTMLElement | {x, y}`) → `Object`/`Object?` carriers.
//  * readonly tuples (`[number, number]`) → `List<num>`.
//  * `IQuickPick<T, O>`'s conditional `items` type → `List<Object>` (T or
//    separator), matching the port-wide union treatment.
//  * `Promise<T> | T` → `Object` (the caller awaits either shape).
import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/event.dart' show Event;
import '../../../base/common/filters.dart' show IMatch;
import '../../../base/common/fuzzyScorer.dart' show IItemAccessor;
import '../../../base/common/keybindings.dart' show ResolvedKeybinding;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/severity.dart' show Severity;
import '../../../base/common/themables.dart' show ThemeColor;
import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import './quickAccess.dart' show IQuickAccessController;

/// 1:1: `export interface IQuickItemHighlights`.
class IQuickItemHighlights {
  IQuickItemHighlights({this.label, this.description});

  List<IMatch>? label;
  List<IMatch>? description;
}

/// 1:1: `export interface IQuickPickItemHighlights extends IQuickItemHighlights`.
class IQuickPickItemHighlights extends IQuickItemHighlights {
  IQuickPickItemHighlights({super.label, super.description, this.detail});

  List<IMatch>? detail;
}

/// 1:1: `export type QuickPickItem = IQuickPickSeparator | IQuickPickItem`.
typedef QuickPickItem = Object;

/// Base properties for a quick pick and quick tree item.
///
/// 1:1: `export interface IQuickItem`.
class IQuickItem {
  IQuickItem({
    this.id,
    required this.label,
    this.ariaLabel,
    this.description,
    this.italic,
    this.strikethrough,
    this.iconClasses,
    this.iconPath,
    this.iconClass,
    this.iconColor,
    this.highlights,
    this.buttons,
    this.disabled,
  });

  String? id;
  String label;
  String? ariaLabel;
  String? description;

  /// Whether the item is displayed in italics.
  bool? italic;

  /// Whether the item is displayed with a strikethrough.
  bool? strikethrough;

  /// Icon classes to be passed on as `IIconLabelValueOptions` to the
  /// underlying `IconLabel` widget.
  List<String>? iconClasses;

  /// `{ dark: URI; light?: URI }`.
  Object? iconPath;

  /// Icon class to be assigned to the quick item container directly.
  String? iconClass;
  ThemeColor? iconColor;
  IQuickItemHighlights? highlights;
  List<IQuickInputButton>? buttons;

  /// Used when we're in multi-select mode. Renders a disabled checkbox.
  bool? disabled;
}

/// Represents a quick pick item used in the quick pick UI.
///
/// 1:1: `export interface IQuickPickItem extends IQuickItem`.
class IQuickPickItem extends IQuickItem {
  IQuickPickItem({
    super.id,
    required super.label,
    super.ariaLabel,
    super.description,
    super.italic,
    super.strikethrough,
    super.iconClasses,
    super.iconPath,
    super.iconClass,
    super.iconColor,
    super.highlights,
    super.buttons,
    super.disabled,
    this.type,
    this.detail,
    this.tooltip,
    this.pickHighlights,
    this.keybinding,
    this.picked,
    this.alwaysShow,
    this.pickable,
  });

  /// `'item'`.
  String? type;
  String? detail;

  /// `string | IMarkdownString`.
  Object? tooltip;

  /// TS re-declares `highlights` as [IQuickPickItemHighlights].
  IQuickPickItemHighlights? pickHighlights;

  ResolvedKeybinding? keybinding;
  bool? picked;
  bool? alwaysShow;

  /// Defaults to true with `IQuickPick.canSelectMany`, can be false to disable
  /// picks for a single item.
  bool? pickable;
}

/// 1:1: `export interface IQuickPickSeparator`.
class IQuickPickSeparator {
  IQuickPickSeparator({
    this.type = 'separator',
    this.id,
    this.label,
    this.description,
    this.ariaLabel,
    this.buttons,
    this.tooltip,
  });

  /// Used to distinguish between 'item' and 'separator'.
  final String type;
  String? id;
  String? label;
  String? description;
  String? ariaLabel;
  List<IQuickInputButton>? buttons;

  /// `string | IMarkdownString`.
  Object? tooltip;
}

/// 1:1: `export interface IKeyMods`.
class IKeyMods {
  const IKeyMods({
    required this.ctrlCmd,
    required this.alt,
    required this.shift,
  });

  final bool ctrlCmd;
  final bool alt;
  final bool shift;
}

bool isKeyModified(IKeyMods keyMods) =>
    keyMods.ctrlCmd || keyMods.alt || keyMods.shift;

const IKeyMods NO_KEY_MODS =
    IKeyMods(ctrlCmd: false, alt: false, shift: false);

/// 1:1: `export interface IQuickNavigateConfiguration`.
class IQuickNavigateConfiguration {
  IQuickNavigateConfiguration({required this.keybindings});

  List<ResolvedKeybinding> keybindings;
}

/// 1:1: `export interface IPickOptions<T extends IQuickPickItem>`.
class IPickOptions<T extends IQuickPickItem> {
  IPickOptions({
    this.title,
    this.value,
    this.placeHolder,
    this.prompt,
    this.matchOnDescription,
    this.matchOnDetail,
    this.matchOnLabel,
    this.sortByLabel,
    this.ignoreFocusLost,
    this.canPickMany,
    this.quickNavigate,
    this.hideInput,
    this.contextKey,
    this.activeItem,
    this.anchor,
    this.anchorPosition,
    this.onKeyMods,
    this.onDidFocus,
    this.onDidTriggerItemButton,
    this.onDidTriggerSeparatorButton,
  });

  String? title;
  String? value;
  String? placeHolder;
  String? prompt;
  bool? matchOnDescription;
  bool? matchOnDetail;
  bool? matchOnLabel;
  bool? sortByLabel;
  bool? ignoreFocusLost;
  bool? canPickMany;
  IQuickNavigateConfiguration? quickNavigate;
  bool? hideInput;
  String? contextKey;

  /// `Promise<T> | T`.
  Object? activeItem;

  /// `HTMLElement | { x: number; y: number }`.
  Object? anchor;

  /// `'above' | 'below' | 'overlay'`.
  String? anchorPosition;
  void Function(IKeyMods keyMods)? onKeyMods;
  void Function(T entry)? onDidFocus;
  void Function(IQuickPickItemButtonContext<T> context)?
      onDidTriggerItemButton;
  void Function(IQuickPickSeparatorButtonEvent context)?
      onDidTriggerSeparatorButton;
}

/// 1:1: `export interface IInputOptions`.
class IInputOptions {
  IInputOptions({
    this.title,
    this.value,
    this.valueSelection,
    this.prompt,
    this.placeHolder,
    this.password,
    this.ignoreFocusLost,
    this.validateInput,
    this.anchor,
    this.anchorPosition,
  });

  String? title;
  String? value;

  /// `readonly [number, number]`.
  List<num>? valueSelection;
  String? prompt;
  String? placeHolder;
  bool? password;
  bool? ignoreFocusLost;

  /// TS returns `string | null | undefined | { content; severity }`.
  Object? Function(String input)? validateInput;

  /// `HTMLElement | { x: number; y: number }`.
  Object? anchor;

  /// `'above' | 'overlay'`.
  String? anchorPosition;
}

/// 1:1: `export enum QuickInputHideReason`.
class QuickInputHideReason {
  /// Focus moved away from the quick input.
  static const int Blur = 1;

  /// An explicit user gesture, e.g. pressing Escape key.
  static const int Gesture = 2;

  /// Anything else.
  static const int Other = 3;

  const QuickInputHideReason._();
}

/// 1:1: `export interface IQuickInputHideEvent`.
class IQuickInputHideEvent {
  IQuickInputHideEvent({required this.reason});

  int reason;
}

/// A collection of the different types of QuickInput.
///
/// 1:1: `export const enum QuickInputType`.
class QuickInputType {
  static const String QuickPick = 'quickPick';
  static const String InputBox = 'inputBox';
  static const String QuickWidget = 'quickWidget';
  static const String QuickTree = 'quickTree';

  const QuickInputType._();
}

/// Represents a quick input control that allows users to make selections or
/// provide input quickly.
///
/// 1:1: `export interface IQuickInput extends IDisposable`.
abstract class IQuickInput implements IDisposable {
  /// The type of the quick input.
  String get type;
  set type(String value);

  /// An event that is fired when the quick input is hidden.
  Event<IQuickInputHideEvent> get onDidHide;
  set onDidHide(Event<IQuickInputHideEvent> value);

  /// An event that is fired when the quick input will be hidden.
  Event<IQuickInputHideEvent> get onWillHide;
  set onWillHide(Event<IQuickInputHideEvent> value);

  /// An event that is fired when the quick input is disposed.
  Event<void> get onDispose;
  set onDispose(Event<void> value);

  String? get title;
  set title(String? value);
  String? get description;
  set description(String? value);
  int? get step;
  set step(int? value);
  int? get totalSteps;
  set totalSteps(int? value);
  List<IQuickInputButton> get buttons;
  set buttons(List<IQuickInputButton> value);
  Event<IQuickInputButton> get onDidTriggerButton;
  set onDidTriggerButton(Event<IQuickInputButton> value);
  bool get enabled;
  set enabled(bool value);
  String? get contextKey;
  set contextKey(String? value);
  bool get busy;
  set busy(bool value);
  bool get ignoreFocusOut;
  set ignoreFocusOut(bool value);

  /// `HTMLElement | { x: number; y: number }`.
  Object? get anchor;
  set anchor(Object? value);

  /// `'above' | 'below' | 'overlay'`.
  String? get anchorPosition;
  set anchorPosition(String? value);

  void show();

  void hide();

  void didHide([int? reason]);

  void willHide([int? reason]);
}

/// 1:1: `export interface IQuickWidget extends IQuickInput`.
abstract class IQuickWidget implements IQuickInput {
  @override
  String get type;
  set type(String value);

  /// `unknown | undefined`.
  Object? get widget;
  set widget(Object? value);
}

/// 1:1: `export interface IQuickPickWillAcceptEvent`.
abstract class IQuickPickWillAcceptEvent {
  void veto();
}

/// 1:1: `export interface IQuickPickDidAcceptEvent`.
class IQuickPickDidAcceptEvent {
  IQuickPickDidAcceptEvent({required this.inBackground});

  bool inBackground;
}

/// Represents the activation behavior for items in a quick input. This means
/// which item will be "active" (aka focused).
///
/// 1:1: `export enum ItemActivation`.
class ItemActivation {
  /// No item will be active.
  static const int NONE = 0;

  /// First item will be active.
  static const int FIRST = 1;

  /// Second item will be active.
  static const int SECOND = 2;

  /// Last item will be active.
  static const int LAST = 3;

  const ItemActivation._();
}

/// Represents the focus options for a quick pick.
///
/// 1:1: `export enum QuickPickFocus`.
class QuickPickFocus {
  /// Focus the first item in the list.
  static const int First = 1;
  static const int Second = 2;
  static const int Last = 3;
  static const int Next = 4;
  static const int Previous = 5;
  static const int NextPage = 6;
  static const int PreviousPage = 7;

  /// Focus the first item under the next separator.
  static const int NextSeparator = 8;

  /// Focus the first item under the current separator.
  static const int PreviousSeparator = 9;

  const QuickPickFocus._();
}

/// Represents a quick pick control that allows users to select an item from a
/// list of options.
///
/// 1:1: `export interface IQuickPick<T extends IQuickPickItem, O extends {
/// useSeparators: boolean } = { useSeparators: false }> extends IQuickInput`.
/// The `O` parameter only shapes `items`, carried here as `List<Object>`.
abstract class IQuickPick<T extends IQuickPickItem> implements IQuickInput {
  @override
  String get type;
  set type(String value);

  /// The current value of the quick pick input.
  String get value;
  set value(String value);

  /// A method that allows to massage the value used for filtering.
  String Function(String value) get filterValue;
  set filterValue(String Function(String value) value);
  String? get ariaLabel;
  set ariaLabel(String? value);
  String? get placeholder;
  set placeholder(String? value);
  String? get prompt;
  set prompt(String? value);
  Event<String> get onDidChangeValue;
  set onDidChangeValue(Event<String> value);
  Event<IQuickPickWillAcceptEvent> get onWillAccept;
  set onWillAccept(Event<IQuickPickWillAcceptEvent> value);
  Event<IQuickPickDidAcceptEvent> get onDidAccept;
  set onDidAccept(Event<IQuickPickDidAcceptEvent> value);
  bool get canAcceptInBackground;
  set canAcceptInBackground(bool value);

  /// `boolean | 'default'`.
  Object get ok;
  set ok(Object value);
  String? get okLabel;
  set okLabel(String? value);
  Event<void> get onDidCustom;
  set onDidCustom(Event<void> value);
  bool get customButton;
  set customButton(bool value);
  String? get customLabel;
  set customLabel(String? value);
  String? get customHover;
  set customHover(String? value);
  bool? get customButtonSecondary;
  set customButtonSecondary(bool? value);
  Event<IQuickPickItemButtonEvent<T>> get onDidTriggerItemButton;
  set onDidTriggerItemButton(Event<IQuickPickItemButtonEvent<T>> value);
  Event<IQuickPickSeparatorButtonEvent> get onDidTriggerSeparatorButton;
  set onDidTriggerSeparatorButton(Event<IQuickPickSeparatorButtonEvent> value);

  /// `ReadonlyArray<T | IQuickPickSeparator>` / `ReadonlyArray<T>`.
  List<Object> get items;
  set items(List<Object> value);
  bool get canSelectMany;
  set canSelectMany(bool value);
  bool get matchOnDescription;
  set matchOnDescription(bool value);
  bool get matchOnDetail;
  set matchOnDetail(bool value);
  bool get matchOnLabel;
  set matchOnLabel(bool value);

  /// `'fuzzy' | 'contiguous'`.
  String get matchOnLabelMode;
  set matchOnLabelMode(String value);
  bool get sortByLabel;
  set sortByLabel(bool value);
  bool get keepScrollPosition;
  set keepScrollPosition(bool value);
  IQuickNavigateConfiguration? get quickNavigate;
  set quickNavigate(IQuickNavigateConfiguration? value);
  List<T> get activeItems;
  set activeItems(List<T> value);
  Event<List<T>> get onDidChangeActive;
  set onDidChangeActive(Event<List<T>> value);
  int get itemActivation;
  set itemActivation(int value);
  List<T> get selectedItems;
  set selectedItems(List<T> value);
  Event<List<T>> get onDidChangeSelection;
  set onDidChangeSelection(Event<List<T>> value);
  IKeyMods get keyMods;
  set keyMods(IKeyMods value);

  /// `Readonly<[number, number]>`.
  List<num>? get valueSelection;
  set valueSelection(List<num>? value);
  String? get validationMessage;
  set validationMessage(String? value);
  Severity get severity;
  set severity(Severity value);
  bool inputHasFocus();
  void focusOnInput();
  bool get hideInput;
  set hideInput(bool value);
  bool get hideCountBadge;
  set hideCountBadge(bool value);
  bool get hideCheckAll;
  set hideCheckAll(bool value);
  void focus(int focus);
  void accept([bool? inBackground]);
}

/// 1:1: `export interface IInputBox extends IQuickInput`.
abstract class IInputBox implements IQuickInput {
  @override
  String get type;
  set type(String value);

  String get value;
  set value(String value);

  /// `Readonly<[number, number]>`.
  List<num>? get valueSelection;
  set valueSelection(List<num>? value);
  String? get placeholder;
  set placeholder(String? value);
  bool get password;
  set password(bool value);
  Event<String> get onDidChangeValue;
  set onDidChangeValue(Event<String> value);
  Event<void> get onDidAccept;
  set onDidAccept(Event<void> value);
  String? get prompt;
  set prompt(String? value);
  String? get validationMessage;
  set validationMessage(String? value);
  Severity get severity;
  set severity(Severity value);
  void accept();
}

/// 1:1: `export enum QuickInputButtonLocation`.
class QuickInputButtonLocation {
  /// In the title bar.
  static const int Title = 1;

  /// To the right of the input box.
  static const int Inline = 2;

  /// At the far end inside the input box.
  static const int Input = 3;

  const QuickInputButtonLocation._();
}

/// `{ dark: URI; light?: URI }` icon-path bag used by quick input items and
/// buttons.
class IconPath {
  IconPath({required this.dark, this.light});

  final URI dark;
  final URI? light;
}

/// `{ checked: boolean }` toggle bag used by quick input buttons.
class QuickInputToggle {
  QuickInputToggle({this.checked = false});

  bool checked;
}

/// 1:1: `export interface IQuickInputButton`.
class IQuickInputButton {
  IQuickInputButton({
    this.iconPath,
    this.iconClass,
    this.tooltip,
    this.alwaysVisible,
    this.location,
    this.toggle,
    this.label,
    this.secondary,
  });

  IconPath? iconPath;
  String? iconClass;
  String? tooltip;
  bool? alwaysVisible;
  int? location;

  QuickInputToggle? toggle;
  String? label;
  bool? secondary;
}

/// 1:1: `export interface IQuickInputButtonWithToggle extends
/// IQuickInputButton`.
class IQuickInputButtonWithToggle extends IQuickInputButton {
  IQuickInputButtonWithToggle({
    super.iconPath,
    super.iconClass,
    super.tooltip,
    super.alwaysVisible,
    super.location,
    super.label,
    super.secondary,
    required QuickInputToggle this.toggleState,
  }) : super(toggle: toggleState);

  /// `readonly toggle: { checked: boolean }`.
  final QuickInputToggle toggleState;
}

/// 1:1: `export interface IQuickPickItemButtonEvent<T extends IQuickPickItem>`.
class IQuickPickItemButtonEvent<T extends IQuickPickItem> {
  IQuickPickItemButtonEvent({required this.button, required this.item});

  IQuickInputButton button;
  T item;
}

/// 1:1: `export interface IQuickPickSeparatorButtonEvent`.
class IQuickPickSeparatorButtonEvent {
  IQuickPickSeparatorButtonEvent({required this.button, required this.separator});

  IQuickInputButton button;
  IQuickPickSeparator separator;
}

/// 1:1: `export interface IQuickPickItemButtonContext<T extends
/// IQuickPickItem> extends IQuickPickItemButtonEvent<T>`.
abstract class IQuickPickItemButtonContext<T extends IQuickPickItem>
    implements IQuickPickItemButtonEvent<T> {
  /// Removes the associated item from the quick pick.
  void removeItem();
}

/// 1:1: `export type QuickPickInput<T = IQuickPickItem> = T |
/// IQuickPickSeparator`.
typedef QuickPickInput = Object;

/// 1:1: `export type IQuickPickItemWithResource = IQuickPickItem & {
/// resource?: URI }`.
class IQuickPickItemWithResource extends IQuickPickItem {
  IQuickPickItemWithResource({
    super.id,
    required super.label,
    super.ariaLabel,
    super.description,
    super.italic,
    super.strikethrough,
    super.iconClasses,
    super.iconPath,
    super.iconClass,
    super.iconColor,
    super.highlights,
    super.buttons,
    super.disabled,
    super.type,
    super.detail,
    super.tooltip,
    super.keybinding,
    super.picked,
    super.alwaysShow,
    super.pickable,
    this.resource,
  });

  URI? resource;
}

//#region Fuzzy Scorer Support

class QuickPickItemScorerAccessor
    implements IItemAccessor<IQuickPickItemWithResource> {
  QuickPickItemScorerAccessor([this.options]);

  /// `{ skipDescription?: boolean; skipPath?: boolean }`.
  final QuickPickItemScorerOptions? options;

  @override
  String getItemLabel(IQuickPickItemWithResource entry) {
    return entry.label;
  }

  @override
  String? getItemDescription(IQuickPickItemWithResource entry) {
    if (options?.skipDescription == true) {
      return null;
    }

    return entry.description;
  }

  @override
  String? getItemPath(IQuickPickItemWithResource entry) {
    if (options?.skipPath == true) {
      return null;
    }

    if (entry.resource?.scheme == Schemas.file) {
      return entry.resource!.fsPath;
    }

    return entry.resource?.path;
  }
}

/// `{ skipDescription?: boolean; skipPath?: boolean }` option bag.
class QuickPickItemScorerOptions {
  QuickPickItemScorerOptions({this.skipDescription, this.skipPath});

  bool? skipDescription;
  bool? skipPath;
}

final QuickPickItemScorerAccessor quickPickItemScorerAccessor =
    QuickPickItemScorerAccessor();

//#endregion

/// 1:1: `export type Omit<T, K extends keyof T>` — type-level only.
typedef Omit<T, K> = T;

/// 1:1: `export type QuickInputAlignment = 'top' | 'center' | 'custom'`.
typedef QuickInputAlignment = String;

/// 1:1: `export interface IQuickInputService`.
abstract class IQuickInputServiceType {
  /// 1:1: `readonly _serviceBrand: undefined` (private in TS).
  Object? get serviceBrand;
  set serviceBrand(Object? value);

  /// Provides access to the back button in quick input.
  IQuickInputButton get backButton;
  set backButton(IQuickInputButton value);

  /// Provides access to the quick access providers.
  IQuickAccessController get quickAccess;
  set quickAccess(IQuickAccessController value);
  Event<void> get onShow;
  set onShow(Event<void> value);
  Event<void> get onHide;
  set onHide(Event<void> value);
  IObservableAlignment get alignment;
  set alignment(IObservableAlignment value);
  Future<T> withQuickInputAnchor<T>(
    Object? anchor,
    String? anchorPosition,
    Future<T> Function() operation,
  );
  Future<Object?> pick(
    Object picks, [
    Object? options,
    CancellationToken? token,
  ]);
  Future<String?> input([IInputOptions? options, CancellationToken? token]);
  IQuickPick<IQuickPickItem> createQuickPick([Object? options]);
  IInputBox createInputBox();
  IQuickWidget createQuickWidget();
  IQuickTree<IQuickTreeItem> createQuickTree();
  void focus();
  void toggle();
  void navigate(bool next, [IQuickNavigateConfiguration? quickNavigate]);
  Future<void> back();
  Future<void> accept([IKeyMods? keyMods]);
  Future<void> cancel([int? reason]);
  void toggleHover();
  IQuickInput? get currentQuickInput;
  set currentQuickInput(IQuickInput? value);
  void setAlignment(Object alignment);
}

/// `IObservable<QuickInputAlignment>` — carried as the observable interface.
typedef IObservableAlignment = Object;

/// 1:1: `export const IQuickInputService =
/// createDecorator<IQuickInputServiceType>('quickInputService')`.
final ServiceIdentifier<IQuickInputServiceType> IQuickInputService =
    createDecorator<IQuickInputServiceType>('quickInputService');

/// 1:1: `export interface IQuickTree<T extends IQuickTreeItem> extends
/// IQuickInput`.
abstract class IQuickTree<T extends IQuickTreeItem> implements IQuickInput {
  @override
  String get type;
  set type(String value);

  String get value;
  set value(String value);
  String? get ariaLabel;
  set ariaLabel(String? value);
  String? get placeholder;
  set placeholder(String? value);
  Event<String> get onDidChangeValue;
  set onDidChangeValue(Event<String> value);
  Event<void> get onDidAccept;
  set onDidAccept(Event<void> value);
  bool get matchOnDescription;
  set matchOnDescription(bool value);
  bool get matchOnLabel;
  set matchOnLabel(bool value);
  bool get sortByLabel;
  set sortByLabel(bool value);
  List<T> get activeItems;
  set activeItems(List<T> value);
  String? get validationMessage;
  set validationMessage(String? value);
  Severity get severity;
  set severity(Severity value);
  List<List<T>> get itemTree;
  set itemTree(List<List<T>> value);
  List<T> get checkedLeafItems;
  set checkedLeafItems(List<T> value);
  T? getParent(T element);
  Event<List<T>> get onDidChangeActive;
  set onDidChangeActive(Event<List<T>> value);
  Event<List<T>> get onDidChangeCheckedLeafItems;
  set onDidChangeCheckedLeafItems(Event<List<T>> value);
  Event<T> get onDidChangeCheckboxState;
  set onDidChangeCheckboxState(Event<T> value);
  Event<IQuickTreeItemButtonEvent<T>> get onDidTriggerItemButton;
  set onDidTriggerItemButton(Event<IQuickTreeItemButtonEvent<T>> value);
  void setItemTree(List<T> itemTree);
  void expand(T element);
  void collapse(T element);
  bool isCollapsed(T element);
  void focusOnInput();
  void reveal(T element);
  void focus(int focus);
  void accept([bool? inBackground]);
}

/// 1:1: `export interface IQuickTreeItem extends IQuickItem`.
class IQuickTreeItem extends IQuickItem {
  IQuickTreeItem({
    super.id,
    required super.label,
    super.ariaLabel,
    super.description,
    super.italic,
    super.strikethrough,
    super.iconClasses,
    super.iconPath,
    super.iconClass,
    super.iconColor,
    super.highlights,
    super.buttons,
    super.disabled,
    this.checked,
    this.collapsed,
    this.children,
    this.pickable,
  });

  /// `boolean | 'mixed'`.
  Object? checked;
  bool? collapsed;
  List<IQuickTreeItem>? children;
  bool? pickable;
}

/// 1:1: `export interface IQuickTreeCheckboxEvent<T extends
/// IQuickTreeItem>`.
class IQuickTreeCheckboxEvent<T extends IQuickTreeItem> {
  IQuickTreeCheckboxEvent({required this.item, required this.checked});

  T item;

  /// `boolean | 'mixed'`.
  Object checked;
}

/// 1:1: `export interface IQuickTreeItemButtonEvent<T extends
/// IQuickTreeItem>`.
class IQuickTreeItemButtonEvent<T extends IQuickTreeItem> {
  IQuickTreeItemButtonEvent({required this.button, required this.item});

  IQuickInputButton button;
  T item;
}