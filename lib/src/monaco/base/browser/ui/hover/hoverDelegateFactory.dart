// 1:1 port of vscode/src/vs/base/browser/ui/hover/hoverDelegateFactory.ts
import '../../../common/lazy.dart' show Lazy;
import 'hover.dart' show IHoverWidget;
import 'hoverDelegate.dart'
    show IHoverDelegate, IHoverDelegateOptions, IScopedHoverDelegate;

/// 1:1: inline factory signature used by `hoverDelegateFactory`.
typedef HoverDelegateFactory = IScopedHoverDelegate Function(
  String placement,
  bool enableInstantHover,
);

class _NullHoverDelegate implements IScopedHoverDelegate {
  _NullHoverDelegate();

  @override
  IHoverWidget? showHover(IHoverDelegateOptions options, [bool? focus]) => null;

  @override
  void Function()? onDidHideHover;

  @override
  Object get delay => -1;

  @override
  String? get placement => null;

  @override
  bool? get showNativeHover => null;

  @override
  void dispose() {}
}

IScopedHoverDelegate _nullHoverDelegateFactory(
  String placement,
  bool enableInstantHover,
) =>
    _NullHoverDelegate();

HoverDelegateFactory _hoverDelegateFactory = _nullHoverDelegateFactory;

final Lazy<IHoverDelegate> _defaultHoverDelegateMouse =
    Lazy<IHoverDelegate>(() => _hoverDelegateFactory('mouse', false));

final Lazy<IHoverDelegate> _defaultHoverDelegateElement =
    Lazy<IHoverDelegate>(() => _hoverDelegateFactory('element', false));

/// 1:1: `setHoverDelegateFactory(hoverDelegateProvider)`.
void setHoverDelegateFactory(HoverDelegateFactory hoverDelegateProvider) {
  _hoverDelegateFactory = hoverDelegateProvider;
}

/// 1:1: `getDefaultHoverDelegate(placement)`.
IHoverDelegate getDefaultHoverDelegate(String placement) {
  if (placement == 'element') {
    return _defaultHoverDelegateElement.value;
  }
  return _defaultHoverDelegateMouse.value;
}

/// 1:1: `createInstantHoverDelegate()`.
IScopedHoverDelegate createInstantHoverDelegate() {
  return _hoverDelegateFactory('element', true);
}
