// 1:1 port of vscode/src/vs/base/browser/ui/hover/hoverDelegate2.ts
import '../../../common/lifecycle.dart' show Disposable;
import '../../dom.dart' show DomElement;
import 'hover.dart'
    show
        IHoverDelegate2,
        IHoverLifecycleOptions,
        IHoverOptions,
        IHoverWidget,
        IManagedHover,
        IManagedHoverContentOrFactory,
        IManagedHoverOptions;
import 'hoverDelegate.dart' show IHoverDelegate;

class _DefaultManagedHover implements IManagedHover {
  const _DefaultManagedHover();

  @override
  void show([bool? focus]) {}

  @override
  void hide() {}

  @override
  void update(Object? tooltip, [IManagedHoverOptions? options]) {}

  @override
  void dispose() {}
}

class _DefaultBaseLayerHoverDelegate implements IHoverDelegate2 {
  const _DefaultBaseLayerHoverDelegate();

  @override
  IHoverWidget? showInstantHover(IHoverOptions options, [bool? focus]) => null;

  @override
  IHoverWidget? showDelayedHover(
    IHoverOptions options,
    IHoverLifecycleOptions lifecycleOptions,
  ) =>
      null;

  @override
  Object? setupDelayedHover(
    DomElement target,
    Object hoverOptions, [
    IHoverLifecycleOptions? lifecycleOptions,
  ]) =>
      Disposable.none;

  @override
  Object? setupDelayedHoverAtMouse(
    DomElement target,
    Object hoverOptions, [
    IHoverLifecycleOptions? lifecycleOptions,
  ]) =>
      Disposable.none;

  @override
  void hideHover([bool? force]) {}

  @override
  void showAndFocusLastHover() {}

  @override
  IManagedHover setupManagedHover(
    IHoverDelegate hoverDelegate,
    DomElement targetElement,
    IManagedHoverContentOrFactory content, [
    IManagedHoverOptions? options,
  ]) =>
      const _DefaultManagedHover();

  @override
  void showManagedHover(DomElement targetElement) {}
}

IHoverDelegate2 _baseHoverDelegate = const _DefaultBaseLayerHoverDelegate();

/// 1:1: `setBaseLayerHoverDelegate(hoverDelegate)`.
void setBaseLayerHoverDelegate(IHoverDelegate2 hoverDelegate) {
  _baseHoverDelegate = hoverDelegate;
}

/// 1:1: `getBaseLayerHoverDelegate()`.
IHoverDelegate2 getBaseLayerHoverDelegate() => _baseHoverDelegate;
