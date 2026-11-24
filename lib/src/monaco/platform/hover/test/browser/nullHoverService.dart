// 1:1 port of vscode/src/vs/platform/hover/test/browser/nullHoverService.ts
import '../../../../base/browser/dom.dart' as dom;
import '../../../../base/browser/ui/hover/hover.dart' as h;
import '../../../../base/browser/ui/hover/hoverDelegate.dart' as d;
import '../../../../base/common/lifecycle.dart' as lifecycle;
import '../../browser/hover.dart' show IHoverServiceType;

class _NullManagedHover implements h.IManagedHover {
  const _NullManagedHover();

  @override
  void show([bool? focus]) {}

  @override
  void hide() {}

  @override
  void update(Object? tooltip, [h.IManagedHoverOptions? options]) {}

  @override
  void dispose() {}
}

/// 1:1: `export const NullHoverService: IHoverService`.
final IHoverServiceType NullHoverService = _NullHoverService();

class _NullHoverService implements IHoverServiceType {
  const _NullHoverService();

  @override
  Object? get serviceBrand => null;

  @override
  h.IHoverWidget? getStickyHover(dom.DomElement targetElement) => null;

  @override
  void hideHover([bool? force]) {}

  @override
  h.IHoverWidget? showInstantHover(h.IHoverOptions options, [bool? focus]) => null;

  @override
  h.IHoverWidget? showDelayedHover(
    h.IHoverOptions options,
    h.IHoverLifecycleOptions lifecycleOptions,
  ) =>
      null;

  @override
  Object? setupDelayedHover(
    dom.DomElement target,
    Object hoverOptions, [
    h.IHoverLifecycleOptions? lifecycleOptions,
  ]) =>
      lifecycle.Disposable.none;

  @override
  Object? setupDelayedHoverAtMouse(
    dom.DomElement target,
    Object hoverOptions, [
    h.IHoverLifecycleOptions? lifecycleOptions,
  ]) =>
      lifecycle.Disposable.none;

  @override
  h.IManagedHover setupManagedHover(
    d.IHoverDelegate hoverDelegate,
    dom.DomElement targetElement,
    Object? content, [
    h.IManagedHoverOptions? options,
  ]) =>
      const _NullManagedHover();

  @override
  void showAndFocusLastHover() {}

  @override
  void showManagedHover(dom.DomElement targetElement) {}
}
