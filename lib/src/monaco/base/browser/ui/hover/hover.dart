// 1:1 port of vscode/src/vs/base/browser/ui/hover/hover.ts
// TS type-only surface is carried by concrete Dart classes so downstream
// hover services can implement the same contracts. Runtime exports are
// HoverStyle and the two managed-tooltip type guards.
import 'dart:async';

import '../../../common/cancellation.dart' show CancellationToken;
import '../../../common/lifecycle.dart' show IDisposable;
import '../../dom.dart' show DomElement;
import 'hoverDelegate.dart' show IHoverDelegate;

/// 1:1: `const enum HoverStyle`.
class HoverStyle {
  const HoverStyle._();

  /// The hover is anchored below the element with a pointer above it.
  static const int Pointer = 1;

  /// The hover is anchored to the bottom right of the cursor's location.
  static const int Mouse = 2;
}

/// 1:1: `export interface IHoverWidget extends IDisposable`.
abstract class IHoverWidget implements IDisposable {
  bool get isDisposed;
}

/// 1:1: `export interface IHoverTarget extends Partial<IDisposable>`.
abstract class IHoverTarget {
  List<DomElement> get targetElements;
  num? get x;
  num? get y;
}

/// 1:1: `export interface IHoverAction`.
abstract class IHoverAction {
  String get label;
  String get commandId;
  String? get iconClass;
  void Function(DomElement target) get run;
}

/// 1:1: `export interface IHoverPositionOptions`.
class IHoverPositionOptions {
  IHoverPositionOptions({
    this.hoverPosition,
    this.anchorAlignment,
    this.forcePosition,
    this.clippingElement,
  });

  /// TS: `HoverPosition | MouseEvent`.
  Object? hoverPosition;

  /// TS `AnchorAlignment` is a `const enum`; the port carries its numeric
  /// value, matching every other const-enum field in this translation.
  int? anchorAlignment;
  bool? forcePosition;
  DomElement? clippingElement;
}

/// 1:1: `export interface IHoverPersistenceOptions`.
class IHoverPersistenceOptions {
  IHoverPersistenceOptions({
    this.hideOnHover,
    this.hideOnKeyDown,
    this.sticky,
  });

  bool? hideOnHover;
  bool? hideOnKeyDown;
  bool? sticky;
}

/// 1:1: `export interface IHoverAppearanceOptions`.
class IHoverAppearanceOptions {
  IHoverAppearanceOptions({
    this.showPointer,
    this.compact,
    this.showHoverHint,
    this.skipFadeInAnimation,
    this.maxHeightRatio,
  });

  bool? showPointer;
  bool? compact;
  bool? showHoverHint;
  bool? skipFadeInAnimation;
  num? maxHeightRatio;
}

/// 1:1: `export interface IHoverOptions`.
class IHoverOptions {
  IHoverOptions({
    required this.content,
    required this.target,
    this.container,
    this.id,
    this.actions,
    this.additionalClasses,
    this.linkHandler,
    this.trapFocus,
    this.style,
    this.position,
    this.persistence,
    this.appearance,
    this.onDidShow,
    this.onDidHide,
  });

  Object content;
  Object target;
  DomElement? container;
  String? id;
  List<IHoverAction>? actions;
  List<String>? additionalClasses;
  void Function(String url)? linkHandler;
  bool? trapFocus;
  int? style;
  IHoverPositionOptions? position;
  IHoverPersistenceOptions? persistence;
  IHoverAppearanceOptions? appearance;
  void Function()? onDidShow;
  void Function()? onDidHide;
}

/// 1:1: `export type IDelayedHoverOptions = Omit<IHoverOptions, 'target'>`.
class IDelayedHoverOptions {
  IDelayedHoverOptions({
    required this.content,
    this.container,
    this.id,
    this.actions,
    this.additionalClasses,
    this.linkHandler,
    this.trapFocus,
    this.style,
    this.position,
    this.persistence,
    this.appearance,
    this.onDidShow,
    this.onDidHide,
  });

  Object content;
  DomElement? container;
  String? id;
  List<IHoverAction>? actions;
  List<String>? additionalClasses;
  void Function(String url)? linkHandler;
  bool? trapFocus;
  int? style;
  IHoverPositionOptions? position;
  IHoverPersistenceOptions? persistence;
  IHoverAppearanceOptions? appearance;
  void Function()? onDidShow;
  void Function()? onDidHide;
}

/// 1:1: `IDelayedHoverAtMouseOptions`.
class IDelayedHoverAtMouseOptions {
  IDelayedHoverAtMouseOptions({
    required this.content,
    this.container,
    this.id,
    this.actions,
    this.additionalClasses,
    this.linkHandler,
    this.trapFocus,
    this.style,
    this.persistence,
    this.appearance,
    this.onDidShow,
    this.onDidHide,
  });

  Object content;
  DomElement? container;
  String? id;
  List<IHoverAction>? actions;
  List<String>? additionalClasses;
  void Function(String url)? linkHandler;
  bool? trapFocus;
  int? style;
  IHoverPersistenceOptions? persistence;
  IHoverAppearanceOptions? appearance;
  void Function()? onDidShow;
  void Function()? onDidHide;
}

/// 1:1: `export interface IHoverLifecycleOptions`.
class IHoverLifecycleOptions {
  IHoverLifecycleOptions({
    this.groupId,
    this.reducedDelay,
    this.setupKeyboardEvents,
  });

  String? groupId;
  bool? reducedDelay;
  bool? setupKeyboardEvents;
}

/// 1:1: `IManagedHoverTooltipMarkdownString`.
class IManagedHoverTooltipMarkdownString {
  IManagedHoverTooltipMarkdownString({
    required this.markdown,
    required this.markdownNotSupportedFallback,
  });

  /// TS union: `IMarkdownString | string | undefined | ((token) => Promise<...>)`.
  Object? markdown;
  String? markdownNotSupportedFallback;
}

/// 1:1 runtime: `isManagedHoverTooltipMarkdownString(obj)`.
///
/// JS `'key' in candidate` is carried by `Map.containsKey`. Dart `null`
/// carries JS `undefined` in this port, so it returns `false`.
bool isManagedHoverTooltipMarkdownString(Object? obj) {
  if (obj is! Map) {
    return false;
  }
  return obj.containsKey('markdown') &&
      obj.containsKey('markdownNotSupportedFallback');
}

/// 1:1: `export interface IManagedHoverTooltipHTMLElement`.
class IManagedHoverTooltipHTMLElement {
  IManagedHoverTooltipHTMLElement({
    required this.element,
    this.contentOwnsPadding,
  });

  FutureOr<DomElement> Function(CancellationToken token) element;
  bool? contentOwnsPadding;
}

/// 1:1 runtime: `isManagedHoverTooltipHTMLElement(obj)`.
bool isManagedHoverTooltipHTMLElement(Object? obj) {
  if (obj is! Map) {
    return false;
  }
  return obj.containsKey('element');
}

/// 1:1: `IManagedHoverContent` union carrier.
typedef IManagedHoverContent = Object?;

/// 1:1: `IManagedHoverContentOrFactory` union carrier.
typedef IManagedHoverContentOrFactory = Object?;

/// 1:1: `export interface IManagedHoverOptions`.
class IManagedHoverOptions {
  IManagedHoverOptions({
    this.actions,
    this.additionalClasses,
    this.linkHandler,
    this.trapFocus,
    this.onDidShow,
    this.appearance,
    this.position,
  });

  List<IHoverAction>? actions;
  List<String>? additionalClasses;
  void Function(String url)? linkHandler;
  bool? trapFocus;
  void Function()? onDidShow;
  IHoverAppearanceOptions? appearance;
  IHoverPositionOptions? position;
}

/// 1:1: `export interface IManagedHover extends IDisposable`.
abstract class IManagedHover implements IDisposable {
  void show([bool? focus]);
  void hide();
  void update(IManagedHoverContent tooltip, [IManagedHoverOptions? options]);
}

/// 1:1: `export interface IHoverDelegate2`.
abstract class IHoverDelegate2 {
  IHoverWidget? showDelayedHover(
    IHoverOptions options,
    IHoverLifecycleOptions lifecycleOptions,
  );

  /// TS returns `IHoverWidget | undefined`; the base-layer default actually
  /// returns `Disposable.None`, so the carrier is `Object?`.
  Object? setupDelayedHover(
    DomElement target,
    Object hoverOptions, [
    IHoverLifecycleOptions? lifecycleOptions,
  ]);

  Object? setupDelayedHoverAtMouse(
    DomElement target,
    Object hoverOptions, [
    IHoverLifecycleOptions? lifecycleOptions,
  ]);

  IHoverWidget? showInstantHover(IHoverOptions options, [bool? focus]);

  void hideHover([bool? force]);

  void showAndFocusLastHover();

  IManagedHover setupManagedHover(
    IHoverDelegate hoverDelegate,
    DomElement targetElement,
    IManagedHoverContentOrFactory content, [
    IManagedHoverOptions? options,
  ]);

  void showManagedHover(DomElement targetElement);
}
