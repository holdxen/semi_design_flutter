// 1:1 port of vscode/src/vs/platform/hover/browser/updatableHoverWidget.ts
import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/ui/hover/hover.dart' as h;
import '../../../base/browser/ui/hover/hoverDelegate.dart' as d;
import '../../../base/browser/ui/hover/hoverWidget.dart'
    show HoverPosition;
import '../../../base/common/cancellation.dart' as cancellation;
import '../../../base/common/htmlContent.dart' as htmlContent;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/types.dart' as types;
import '../../../nls.dart' as nls;

class _HoverTarget implements d.IHoverDelegateTarget {
  _HoverTarget(this.targetElements, this.x, this.onDispose);

  @override
  final List<dom.DomElement> targetElements;

  @override
  num? x;

  final void Function() onDispose;

  @override
  void dispose() => onDispose();
}

/// 1:1: `export class ManagedHoverWidget implements IDisposable`.
class ManagedHoverWidget implements lifecycle.IDisposable {
  ManagedHoverWidget(
    this.hoverDelegate,
    this.target,
    this.fadeInAnimation,
  );

  final d.IHoverDelegate hoverDelegate;
  final Object target;
  final bool fadeInAnimation;

  h.IHoverWidget? _hoverWidget;
  cancellation.CancellationTokenSource? _cancellationTokenSource;
  bool? _focus;

  bool get isDisposed => _hoverWidget?.isDisposed ?? false;

  /// 1:1: `onDidHide()`.
  void onDidHide() {
    if (_cancellationTokenSource != null) {
      _cancellationTokenSource!.dispose(true);
      _cancellationTokenSource = null;
    }
  }

  /// 1:1: `async update(content, focus?, options?)`.
  Future<void> update(
    Object? content, [
    bool? focus,
    h.IManagedHoverOptions? options,
  ]) async {
    if (_cancellationTokenSource != null) {
      _cancellationTokenSource!.dispose(true);
      _cancellationTokenSource = null;
    }
    if (isDisposed) {
      return;
    }

    final bool contentOwnsPadding = h.isManagedHoverTooltipHTMLElement(content) &&
        (content as Map)['contentOwnsPadding'] == true;
    Object? resolvedContent;
    if (types.isString(content) ||
        dom.isHTMLElement(content) ||
        content == null) {
      resolvedContent = content;
    } else {
      _cancellationTokenSource = cancellation.CancellationTokenSource();
      final cancellation.CancellationToken token =
          _cancellationTokenSource!.token;

      Object? managedContent;
      final Map<Object?, Object?> map = content as Map<Object?, Object?>;
      if (h.isManagedHoverTooltipMarkdownString(content)) {
        final Object? markdown = map['markdown'];
        if (types.isFunction(markdown)) {
          final Object? value = Function.apply(markdown as Function, <Object?>[token]);
          managedContent = (value as Object?).toString() == 'null'
              ? null
              : value is Future<Object?>
                  ? value.then((Object? resolved) =>
                      resolved ?? map['markdownNotSupportedFallback'])
                  : Future<Object?>.value(
                      value ?? map['markdownNotSupportedFallback']);
        } else {
          managedContent =
              markdown ?? map['markdownNotSupportedFallback'];
        }
      } else {
        managedContent = Function.apply(
            map['element'] as Function, <Object?>[token]);
      }

      if (managedContent is Future) {
        if (_hoverWidget == null) {
          _show(nls.localize('iconLabel.loading', 'Loading...'), focus, options, false);
        }
        resolvedContent = await managedContent as Object?;
      } else {
        resolvedContent = managedContent;
      }

      if (isDisposed || token.isCancellationRequested) {
        return;
      }
    }

    _show(resolvedContent, focus, options, contentOwnsPadding);
  }

  void _show(
    Object? content,
    bool? focus,
    h.IManagedHoverOptions? options,
    bool contentOwnsPadding,
  ) {
    final h.IHoverWidget? oldHoverWidget = _hoverWidget;
    _hoverWidget = null;
    focus ??= _focus;
    _focus = focus;
    oldHoverWidget?.dispose();

    if (!_hasContent(content)) {
      return;
    }

    final List<dom.DomElement> targetElements;
    num? x;
    if (dom.isHTMLElement(target)) {
      targetElements = <dom.DomElement>[target as dom.DomElement];
      x = null;
    } else {
      final dynamic targetObject = target;
      targetElements =
          (targetObject.targetElements as List<dom.DomElement>);
      x = targetObject.x as num?;
    }

    h.IHoverWidget? hoverWidgetRef;
    final _HoverTarget hoverTarget = _HoverTarget(targetElements, x, () {
      if (!dom.isHTMLElement(target)) {
        (target as dynamic).dispose();
      }
      if (identical(_hoverWidget, hoverWidgetRef)) {
        onDidHide();
      }
    });

    final List<String> additionalClasses = <String>[
      ...(options?.additionalClasses ?? const <String>[]),
      if (contentOwnsPadding) 'managed-hover-content-owns-padding',
    ];

    final d.IHoverDelegateOptions hoverOptions = d.IHoverDelegateOptions(
      content: content as Object,
      target: hoverTarget,
      actions: options?.actions,
      linkHandler: options?.linkHandler,
      trapFocus: options?.trapFocus ?? focus,
      onDidShow: options?.onDidShow,
      additionalClasses: additionalClasses,
      appearance: h.IHoverAppearanceOptions(
        showPointer: hoverDelegate.placement == 'element',
        skipFadeInAnimation: !fadeInAnimation || oldHoverWidget != null,
        showHoverHint: options?.appearance?.showHoverHint,
      ),
      position: h.IHoverPositionOptions(
        hoverPosition: HoverPosition.BELOW,
        anchorAlignment: options?.position?.anchorAlignment,
      ),
    );

    hoverWidgetRef = hoverDelegate.showHover(hoverOptions, focus);
    _hoverWidget = hoverWidgetRef;
  }

  bool _hasContent(Object? content) {
    if (content == null || content == false) {
      return false;
    }
    if (htmlContent.isMarkdownString(content)) {
      return (content as dynamic).value != null &&
          (content as dynamic).value.toString().isNotEmpty;
    }
    return true;
  }

  @override
  void dispose() {
    _hoverWidget?.dispose();
    _cancellationTokenSource?.dispose(true);
    _cancellationTokenSource = null;
  }
}
