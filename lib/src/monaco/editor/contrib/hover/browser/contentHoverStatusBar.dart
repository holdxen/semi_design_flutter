// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/hover/browser/contentHoverStatusBar.ts
// Translated 1:1. DOM, HoverAction rendering, hover/keybinding services are
// injected as narrow contracts (Dart has no browser DOM).
// ---------------------------------------------------------------------------
import '../../../../base/common/lifecycle.dart' show Disposable, IDisposable;

/// 1:1: DOM node surface used by the status bar.
abstract class IStatusBarNode {
  String get description;
  set tabIndex(int value);
  int get tabIndex;
  IStatusBarNode appendChild(IStatusBarNode child);
  List<IStatusBarNode> get children;
}

/// 1:1: `$` / `dom.append` environment.
class StatusBarDomEnvironment {
  final IStatusBarNode Function(String description) createNode;
  final IStatusBarNode Function(IStatusBarNode parent, IStatusBarNode child)
      append;

  StatusBarDomEnvironment({
    required this.createNode,
    required this.append,
  });
}

/// 1:1: keybinding label carrier.
abstract class IStatusBarKeybinding {
  String getLabel();
}

/// 1:1: `IKeybindingService.lookupKeybinding` member.
abstract class IKeybindingServiceForHoverBar {
  IStatusBarKeybinding? lookupKeybinding(String commandId);
}

/// 1:1: `IHoverService.setupManagedHover` member.
abstract class IHoverServiceForHoverBar {
  IDisposable setupManagedHover(Object delegate, Object container, Object label);
}

/// 1:1: `getDefaultHoverDelegate` member.
abstract class IHoverDelegateFactoryForHoverBar {
  Object getDefaultHoverDelegate(String kind);
}

/// 1:1: rendered hover action carrier.
class HoverBarAction implements IDisposable {
  final Object actionContainer;
  final Object actionRenderedLabel;
  final IDisposable disposeAction;

  HoverBarAction(this.actionContainer, this.actionRenderedLabel, this.disposeAction);

  @override
  void dispose() => disposeAction.dispose();
}

/// 1:1: `addAction` options.
class HoverBarActionOptions {
  final String label;
  final String? iconClass;
  final void Function(Object target) run;
  final String commandId;

  HoverBarActionOptions({
    required this.label,
    this.iconClass,
    required this.run,
    required this.commandId,
  });
}

/// 1:1: `HoverAction.render` bridge.
typedef HoverBarActionRenderer = HoverBarAction Function(
  Object parent,
  HoverBarActionOptions options,
  String? keybindingLabel,
);

/// 1:1: `export class EditorHoverStatusBar`.
class EditorHoverStatusBar extends Disposable {
  final IStatusBarNode hoverElement;
  final List<HoverBarAction> actions = <HoverBarAction>[];

  final IStatusBarNode _actionsElement;
  bool _hasContent = false;

  final IKeybindingServiceForHoverBar _keybindingService;
  final IHoverServiceForHoverBar _hoverService;
  final IHoverDelegateFactoryForHoverBar _delegateFactory;
  final HoverBarActionRenderer _actionRenderer;
  final StatusBarDomEnvironment _dom;

  EditorHoverStatusBar(
    this._keybindingService,
    this._hoverService,
    this._delegateFactory,
    this._actionRenderer,
    this._dom,
  )   : hoverElement = _dom.createNode('div.hover-row.status-bar'),
        _actionsElement = _dom.createNode('div.actions') {
    hoverElement.tabIndex = 0;
    _dom.append(hoverElement, _actionsElement);
  }

  bool get hasContent => _hasContent;

  HoverBarAction addAction(HoverBarActionOptions actionOptions) {
    final IStatusBarKeybinding? keybinding =
        _keybindingService.lookupKeybinding(actionOptions.commandId);
    final String? keybindingLabel = keybinding?.getLabel();
    _hasContent = true;
    final HoverBarAction action = register(_actionRenderer(
        _actionsElement, actionOptions, keybindingLabel));
    register(_hoverService.setupManagedHover(
      _delegateFactory.getDefaultHoverDelegate('element'),
      action.actionContainer,
      action.actionRenderedLabel,
    ));
    actions.add(action);
    return action;
  }

  IStatusBarNode append(IStatusBarNode element) {
    final IStatusBarNode result = _dom.append(_actionsElement, element);
    _hasContent = true;
    return result;
  }
}
