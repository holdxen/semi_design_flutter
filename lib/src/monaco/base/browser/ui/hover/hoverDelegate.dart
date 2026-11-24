// 1:1 port of vscode/src/vs/base/browser/ui/hover/hoverDelegate.ts
// The file has no runtime exports in TypeScript; all declarations are carried
// as Dart interfaces/classes for downstream base-layer hover services.
import '../../../common/lifecycle.dart' show IDisposable;
import '../../dom.dart' show DomElement;
import 'hover.dart' show IHoverWidget, IManagedHoverOptions;

/// 1:1: `export interface IHoverDelegateTarget extends IDisposable`.
abstract class IHoverDelegateTarget implements IDisposable {
  List<DomElement> get targetElements;
  num? x;
}

/// 1:1: `export interface IHoverDelegateOptions extends IManagedHoverOptions`.
class IHoverDelegateOptions extends IManagedHoverOptions {
  IHoverDelegateOptions({
    required this.content,
    required this.target,
    this.container,
    super.actions,
    super.additionalClasses,
    super.linkHandler,
    super.trapFocus,
    super.onDidShow,
    super.position,
    super.appearance,
  });

  /// TS: `IMarkdownString | string | HTMLElement`.
  final Object content;

  /// TS: `IHoverDelegateTarget | HTMLElement`.
  final Object target;
  final DomElement? container;
}

/// 1:1: `export interface IHoverDelegate`.
abstract class IHoverDelegate {
  IHoverWidget? showHover(IHoverDelegateOptions options, [bool? focus]);

  void Function()? onDidHideHover;

  /// TS: `number | ((content?: IManagedHoverContentOrFactory) => number)`.
  Object get delay;

  /// TS: `'mouse' | 'element'`.
  String? get placement;

  bool? get showNativeHover;
}

/// 1:1: `export interface IScopedHoverDelegate extends IHoverDelegate, IDisposable`.
abstract class IScopedHoverDelegate implements IHoverDelegate, IDisposable {}
