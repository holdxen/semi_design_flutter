// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/ui/splitview/splitview.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS carriers / adapters:
//   - `HTMLElement` -> `dom.DomElement`; `$()` -> local `_dollar`.
//   - `Event<T>` / `Emitter<T>` -> `event.Event<T>` / `event.Emitter<T>`.
//   - `Event.map` -> `event.eventMap`.
//   - `Sash` -> `ISplitViewSash` (real `sash.Sash` by default).
//   - `SmoothScrollableElement` -> `ISplitViewScrollable` (real by default).
//   - `Infinity` -> `double.infinity`.
//   - `style.removeProperty` -> `style.remove` on the CSS carrier.
// ---------------------------------------------------------------------------

import '../../../common/arrays.dart' as arrays;
import '../../../common/color.dart' as color;
import '../../../common/event.dart' as event;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/numbers.dart' as numbers;
import '../../../common/scrollable.dart' as scr;
import '../../dom.dart' as dom;
import '../../event.dart' as browserEvent;
import '../sash/sash.dart' as sash;
import '../scrollbar/scrollableElement.dart' as se;
import '../scrollbar/scrollableElementOptions.dart' as opts;

/// 1:1: `export interface ISplitViewStyles`.
class SplitViewStyles {
  SplitViewStyles({required this.separatorBorder});

  final color.Color separatorBorder;
}

final SplitViewStyles _defaultStyles =
    SplitViewStyles(separatorBorder: color.Color.transparentColor);

/// 1:1: `export const enum LayoutPriority`.
class LayoutPriority {
  static const int Normal = 0;
  static const int Low = 1;
  static const int High = 2;
}

/// 1:1: `export interface IView<TLayoutContext>`.
abstract class IView<TLayoutContext> {
  dom.DomElement get element;
  num get minimumSize;
  num get maximumSize;
  int? get priority => null;
  bool? get proportionalLayout => null;
  bool? get pathIndependentLayout => null;
  bool? get snap => null;
  event.Event<num?> get onDidChange;
  void layout(num size, num offset, TLayoutContext? context);
  void setVisible(bool visible) {}
}

/// 1:1: `export interface ISplitViewDescriptor`.
class SplitViewDescriptor<TLayoutContext, TView extends IView<TLayoutContext>> {
  SplitViewDescriptor({required this.size, required this.views});

  final num size;
  final List<SplitViewDescriptorView<TLayoutContext, TView>> views;
}

/// 1:1: descriptor's `views[]` entry.
class SplitViewDescriptorView<TLayoutContext, TView extends IView<TLayoutContext>> {
  SplitViewDescriptorView({this.visible, required this.size, required this.view});

  final bool? visible;
  final num size;
  final TView view;
}

/// 1:1: `export interface ISplitViewOptions`.
class SplitViewOptions<TLayoutContext, TView extends IView<TLayoutContext>> {
  SplitViewOptions({
    this.orientation,
    this.styles,
    this.inverseAltBehavior,
    this.proportionalLayout,
    this.descriptor,
    this.scrollbarVisibility,
    this.getSashOrthogonalSize,
  });

  int? orientation;
  SplitViewStyles? styles;
  bool? inverseAltBehavior;
  bool? proportionalLayout;
  SplitViewDescriptor<TLayoutContext, TView>? descriptor;
  int? scrollbarVisibility;
  num Function()? getSashOrthogonalSize;
}

/// 1:1: `interface ISashEvent`.
class SplitSashEvent {
  SplitSashEvent({
    required this.sash,
    required this.start,
    required this.current,
    required this.alt,
  });

  final ISplitViewSash sash;
  final num start;
  final num current;
  final bool alt;
}

/// 1:1: `type ViewItemSize = number | { cachedVisibleSize: number }`.
class ViewItemSize {
  ViewItemSize._(this.size, this.cachedVisibleSize);

  factory ViewItemSize.size(num value) => ViewItemSize._(value, null);
  factory ViewItemSize.invisible(num cached) => ViewItemSize._(0, cached);

  final num size;
  final num? cachedVisibleSize;
}

/// 1:1: `export type Sizing` union, flattened into one carrier.
class Sizing {
  const Sizing._(this.type, {this.index, this.cachedVisibleSize});

  static const Sizing Distribute = Sizing._('distribute');
  static Sizing Split(int index) => Sizing._('split', index: index);
  static Sizing Auto(int index) => Sizing._('auto', index: index);
  static Sizing Invisible(num cachedVisibleSize) =>
      Sizing._('invisible', cachedVisibleSize: cachedVisibleSize);

  final String type;
  final int? index;
  final num? cachedVisibleSize;
}

/// 1:1: `interface ISashItem`.
class SashItem {
  SashItem({required this.sash, required this.disposable});

  ISplitViewSash sash;
  lifecycle.IDisposable disposable;
}

/// 1:1: `interface ISashDragSnapState`.
class SashDragSnapState {
  SashDragSnapState({
    required this.index,
    required this.limitDelta,
    required this.size,
  });

  final int index;
  final num limitDelta;
  final num size;
}

/// 1:1: `interface ISashDragState`.
class SashDragState {
  SashDragState({
    required this.index,
    required this.start,
    required this.current,
    required this.sizes,
    required this.minDelta,
    required this.maxDelta,
    required this.alt,
    this.snapBefore,
    this.snapAfter,
    required this.disposable,
  });

  int index;
  num start;
  num current;
  List<num> sizes;
  num minDelta;
  num maxDelta;
  bool alt;
  SashDragSnapState? snapBefore;
  SashDragSnapState? snapAfter;
  lifecycle.IDisposable disposable;
}

/// 1:1: `enum State`.
class SplitViewState {
  static const int Idle = 0;
  static const int Busy = 1;
}

/// Test seam mirroring the `Sash` surface used by `SplitView`.
abstract class ISplitViewSash {
  int get state;
  set state(int value);
  ISplitViewSash? get orthogonalStartSash;
  set orthogonalStartSash(ISplitViewSash? value);
  ISplitViewSash? get orthogonalEndSash;
  set orthogonalEndSash(ISplitViewSash? value);
  event.Event<sash.SashEvent> get onDidStart;
  event.Event<sash.SashEvent> get onDidChange;
  event.Event<void> get onDidEnd;
  event.Event<void> get onDidReset;
  void layout();
  void dispose();
}

/// 1:1: `SashOptions` subset consumed by [ISplitViewSash].
class SplitViewSashOptions {
  SplitViewSashOptions({
    required this.orientation,
    this.orthogonalStartSash,
    this.orthogonalEndSash,
  });

  final int orientation;
  final ISplitViewSash? orthogonalStartSash;
  final ISplitViewSash? orthogonalEndSash;
}

class _RealSplitViewSash implements ISplitViewSash {
  _RealSplitViewSash(dom.DomElement container, Object layoutProvider,
      SplitViewSashOptions options)
      : real = sash.Sash(
            container,
            layoutProvider,
            sash.SashOptions(
              orientation: options.orientation,
              orthogonalStartSash: options.orthogonalStartSash == null
                  ? null
                  : (options.orthogonalStartSash as _RealSplitViewSash).real,
              orthogonalEndSash: options.orthogonalEndSash == null
                  ? null
                  : (options.orthogonalEndSash as _RealSplitViewSash).real,
            )) {
    _orthogonalStartSash = options.orthogonalStartSash;
    _orthogonalEndSash = options.orthogonalEndSash;
  }

  final sash.Sash real;
  ISplitViewSash? _orthogonalStartSash;
  ISplitViewSash? _orthogonalEndSash;

  @override
  int get state => real.state;
  @override
  set state(int value) => real.state = value;

  @override
  ISplitViewSash? get orthogonalStartSash => _orthogonalStartSash;
  @override
  set orthogonalStartSash(ISplitViewSash? value) {
    _orthogonalStartSash = value;
    real.orthogonalStartSash =
        value == null ? null : (value as _RealSplitViewSash).real;
  }

  @override
  ISplitViewSash? get orthogonalEndSash => _orthogonalEndSash;
  @override
  set orthogonalEndSash(ISplitViewSash? value) {
    _orthogonalEndSash = value;
    real.orthogonalEndSash =
        value == null ? null : (value as _RealSplitViewSash).real;
  }

  @override
  event.Event<sash.SashEvent> get onDidStart => real.onDidStart;
  @override
  event.Event<sash.SashEvent> get onDidChange => real.onDidChange;
  @override
  event.Event<void> get onDidEnd => real.onDidEnd;
  @override
  event.Event<void> get onDidReset => real.onDidReset;
  @override
  void layout() => real.layout();
  @override
  void dispose() => real.dispose();
}

/// Injectable boundary for `new Sash(...)`.
typedef SplitViewSashFactory = ISplitViewSash Function(
    dom.DomElement container, Object layoutProvider, SplitViewSashOptions options);

/// Injectable boundary for `new SmoothScrollableElement(...)`.
typedef SplitViewScrollableFactory = ISplitViewScrollable Function(
    dom.DomElement element,
    opts.ScrollableElementCreationOptions options,
    scr.Scrollable scrollable);

SplitViewSashFactory splitViewSashFactory =
    (dom.DomElement container, Object layoutProvider,
            SplitViewSashOptions options) =>
        _RealSplitViewSash(container, layoutProvider, options);

/// Test seam mirroring the `SmoothScrollableElement` surface used here.
abstract class ISplitViewScrollable implements lifecycle.IDisposable {
  dom.DomElement getDomNode();
  scr.IScrollPosition getScrollPosition();
  void setScrollPosition(scr.NewScrollPosition update);
  void setScrollDimensions(scr.NewScrollDimensions dimensions);
  event.Event<scr.ScrollEvent> get onScroll;
  void dispose();
}

class _RealSplitViewScrollable implements ISplitViewScrollable {
  _RealSplitViewScrollable(this.real);

  final se.SmoothScrollableElement real;

  @override
  dom.DomElement getDomNode() => real.getDomNode();
  @override
  scr.IScrollPosition getScrollPosition() => real.getScrollPosition();
  @override
  void setScrollPosition(scr.NewScrollPosition update) =>
      real.setScrollPosition(update);
  @override
  void setScrollDimensions(scr.NewScrollDimensions dimensions) =>
      real.setScrollDimensions(dimensions);
  @override
  event.Event<scr.ScrollEvent> get onScroll => real.onScroll;
  @override
  void dispose() => real.dispose();
}

SplitViewScrollableFactory splitViewScrollableFactory =
    (dom.DomElement element,
            opts.ScrollableElementCreationOptions options,
            scr.Scrollable scrollable) =>
        _RealSplitViewScrollable(se.SmoothScrollableElement(element, options, scrollable));

dom.DomElement _dollar(String description) {
  final List<String> parts = description.split('.');
  final dom.DomElement el =
      dom.document.createElement(parts.first.isEmpty ? 'div' : parts.first);
  if (parts.length > 1) el.className = parts.skip(1).join(' ');
  return el;
}

List<dom.DomElement> _childElements(dom.DomElement el) =>
    el.childNodes.whereType<dom.DomElement>().toList();

void _removeProperty(dom.DomElement el, String name) => el.style.remove(name);

/// 1:1: `abstract class ViewItem<TLayoutContext, TView>`.
abstract class ViewItem<TLayoutContext, TView extends IView<TLayoutContext>>
    implements lifecycle.IDisposable {
  ViewItem(this.container, this.view, ViewItemSize itemSize, this.disposable) {
    if (itemSize.cachedVisibleSize == null) {
      _size = itemSize.size;
      _cachedVisibleSize = null;
      container.classList.add('visible');
    } else {
      _size = 0;
      _cachedVisibleSize = itemSize.cachedVisibleSize;
    }
  }

  final dom.DomElement container;
  final TView view;
  final lifecycle.IDisposable disposable;

  num _size = 0;
  num? _cachedVisibleSize;

  num get size => _size;
  set size(num value) => _size = value;

  num? get cachedVisibleSize => _cachedVisibleSize;

  bool get visible => _cachedVisibleSize == null;

  void setVisible(bool visible, [num? size]) {
    if (visible == this.visible) return;

    if (visible) {
      this.size = numbers.clamp(_cachedVisibleSize!, viewMinimumSize, viewMaximumSize);
      _cachedVisibleSize = null;
    } else {
      _cachedVisibleSize = size ?? this.size;
      this.size = 0;
    }

    container.classList.toggle('visible', visible);

    try {
      view.setVisible(visible);
    } catch (e) {
      // ignore: avoid_print
      print('Splitview: Failed to set visible view');
      // ignore: avoid_print
      print(e);
    }
  }

  num get minimumSize => visible ? view.minimumSize : 0;
  num get viewMinimumSize => view.minimumSize;
  num get maximumSize => visible ? view.maximumSize : 0;
  num get viewMaximumSize => view.maximumSize;
  int? get priority => view.priority;
  bool get proportionalLayout => view.proportionalLayout ?? true;
  bool get snap => view.snap ?? false;

  set enabled(bool value) => container.style.setProperty('pointerEvents', value ? '' : 'none');

  void layout(num offset, TLayoutContext? layoutContext) {
    layoutContainer(offset);
    try {
      view.layout(size, offset, layoutContext);
    } catch (e) {
      // ignore: avoid_print
      print('Splitview: Failed to layout view');
      // ignore: avoid_print
      print(e);
    }
  }

  void layoutContainer(num offset);

  @override
  void dispose() => disposable.dispose();
}

/// 1:1: `class VerticalViewItem`.
class VerticalViewItem<TLayoutContext, TView extends IView<TLayoutContext>>
    extends ViewItem<TLayoutContext, TView> {
  VerticalViewItem(dom.DomElement container, TView view, ViewItemSize itemSize,
      lifecycle.IDisposable disposable)
      : super(container, view, itemSize, disposable);

  @override
  void layoutContainer(num offset) {
    container.style.setProperty('top', '${offset}px');
    container.style.setProperty('height', '${size}px');
  }
}

/// 1:1: `class HorizontalViewItem`.
class HorizontalViewItem<TLayoutContext, TView extends IView<TLayoutContext>>
    extends ViewItem<TLayoutContext, TView> {
  HorizontalViewItem(dom.DomElement container, TView view, ViewItemSize itemSize,
      lifecycle.IDisposable disposable)
      : super(container, view, itemSize, disposable);

  @override
  void layoutContainer(num offset) {
    container.style.setProperty('left', '${offset}px');
    container.style.setProperty('width', '${size}px');
  }
}

/// 1:1: `export class SplitView<TLayoutContext, TView>`.
class SplitView<TLayoutContext, TView extends IView<TLayoutContext>>
    extends lifecycle.Disposable {
  SplitView(dom.DomElement container,
      [SplitViewOptions<TLayoutContext, TView>? inOptions])
      : options = inOptions ?? SplitViewOptions<TLayoutContext, TView>() {
    orientation = options.orientation ?? sash.Orientation.VERTICAL;
    inverseAltBehavior = options.inverseAltBehavior ?? false;
    proportionalLayout = options.proportionalLayout ?? true;
    getSashOrthogonalSize = options.getSashOrthogonalSize;

    el = dom.document.createElement('div');
    el.classList.add('monaco-split-view2');
    el.classList.add(orientation == sash.Orientation.VERTICAL ? 'vertical' : 'horizontal');
    container.appendChild(el);

    sashContainer = dom.appendNode(el, _dollar('.sash-container'));
    viewContainer = _dollar('.split-view-container');

    scrollable = register(scr.Scrollable(scr.ScrollableOptions(
      forceIntegerValues: true,
      smoothScrollDuration: 125,
      scheduleAtNextAnimationFrame: (void Function() callback) =>
          dom.scheduleAtNextAnimationFrame(dom.getWindow(el), callback),
    )));

    scrollableElement = register(splitViewScrollableFactory(
        viewContainer,
        opts.ScrollableElementCreationOptions()
          ..vertical = orientation == sash.Orientation.VERTICAL
              ? (options.scrollbarVisibility ?? scr.ScrollbarVisibility.Auto)
              : scr.ScrollbarVisibility.Hidden
          ..horizontal = orientation == sash.Orientation.HORIZONTAL
              ? (options.scrollbarVisibility ?? scr.ScrollbarVisibility.Auto)
              : scr.ScrollbarVisibility.Hidden,
        scrollable));

    final onDidScrollViewContainer = register(browserEvent
        .DomEmitter<dom.DomEvent>(viewContainer, dom.EventType.SCROLL));
    register(onDidScrollViewContainer.event((Object? e) {
      final scr.IScrollPosition position = scrollableElement.getScrollPosition();
      final num? scrollLeft = (viewContainer.scrollLeft - position.scrollLeft).abs() <= 1
          ? null
          : viewContainer.scrollLeft;
      final num? scrollTop = (viewContainer.scrollTop - position.scrollTop).abs() <= 1
          ? null
          : viewContainer.scrollTop;

      if (scrollLeft != null || scrollTop != null) {
        scrollableElement.setScrollPosition(scr.NewScrollPosition(
            scrollLeft: scrollLeft, scrollTop: scrollTop));
      }
    }));

    onDidScroll = scrollableElement.onScroll;
    register(onDidScroll((dynamic value) {
      final scr.ScrollEvent e = value as scr.ScrollEvent;
      if (e.scrollTopChanged) viewContainer.scrollTop = e.scrollTop.round();
      if (e.scrollLeftChanged) viewContainer.scrollLeft = e.scrollLeft.round();
    }));

    dom.appendNode(el, scrollableElement.getDomNode());

    style(options.styles ?? _defaultStyles);

    final descriptor = options.descriptor;
    if (descriptor != null) {
      size = descriptor.size;
      for (int i = 0; i < descriptor.views.length; i++) {
        final viewDescriptor = descriptor.views[i];
        final Object sizing =
            viewDescriptor.visible == null || viewDescriptor.visible == true
                ? viewDescriptor.size
                : Sizing.Invisible(viewDescriptor.size);
        final TView view = viewDescriptor.view;
        doAddView(view, sizing, i, true);
      }

      _contentSize = viewItems.fold<num>(0, (num r, ViewItem<TLayoutContext, TView> i) => r + i.size);
      saveProportions();
    }
  }

  final SplitViewOptions<TLayoutContext, TView> options;

  late final int orientation;
  late final dom.DomElement el;
  late final dom.DomElement sashContainer;
  late final dom.DomElement viewContainer;
  late final scr.Scrollable scrollable;
  late final ISplitViewScrollable scrollableElement;
  num size = 0;
  TLayoutContext? layoutContext;
  num _contentSize = 0;
  List<num?>? proportions;
  final List<ViewItem<TLayoutContext, TView>> viewItems =
      <ViewItem<TLayoutContext, TView>>[];
  final List<SashItem> sashItems = <SashItem>[]; // used in tests
  SashDragState? sashDragState;
  int state = SplitViewState.Idle;
  late final bool inverseAltBehavior;
  late final bool proportionalLayout;
  late final num Function()? getSashOrthogonalSize;

  final event.Emitter<num> _onDidSashChange = event.Emitter<num>();
  final event.Emitter<num> _onDidSashReset = event.Emitter<num>();
  ISplitViewSash? _orthogonalStartSash;
  ISplitViewSash? _orthogonalEndSash;
  bool _startSnappingEnabled = true;
  bool _endSnappingEnabled = true;

  num get contentSize => _contentSize;
  event.Event<num> get onDidSashChange => _onDidSashChange.event;
  event.Event<num> get onDidSashReset => _onDidSashReset.event;
  late final event.Event<scr.ScrollEvent> onDidScroll;

  int get length => viewItems.length;

  num get minimumSize =>
      viewItems.fold<num>(0, (num r, ViewItem<TLayoutContext, TView> item) => r + item.minimumSize);

  num get maximumSize => length == 0
      ? double.infinity
      : viewItems.fold<num>(0, (num r, ViewItem<TLayoutContext, TView> item) => r + item.maximumSize);

  ISplitViewSash? get orthogonalStartSash => _orthogonalStartSash;
  ISplitViewSash? get orthogonalEndSash => _orthogonalEndSash;
  bool get startSnappingEnabled => _startSnappingEnabled;
  bool get endSnappingEnabled => _endSnappingEnabled;

  set orthogonalStartSash(ISplitViewSash? sash) {
    for (final SashItem sashItem in sashItems) {
      sashItem.sash.orthogonalStartSash = sash;
    }
    _orthogonalStartSash = sash;
  }

  set orthogonalEndSash(ISplitViewSash? sash) {
    for (final SashItem sashItem in sashItems) {
      sashItem.sash.orthogonalEndSash = sash;
    }
    _orthogonalEndSash = sash;
  }

  List<ISplitViewSash> get sashes =>
      sashItems.map((SashItem s) => s.sash).toList(growable: false);

  set startSnappingEnabled(bool value) {
    if (_startSnappingEnabled == value) return;
    _startSnappingEnabled = value;
    updateSashEnablement();
  }

  set endSnappingEnabled(bool value) {
    if (_endSnappingEnabled == value) return;
    _endSnappingEnabled = value;
    updateSashEnablement();
  }

  /// 1:1: `style(styles)`.
  void style(SplitViewStyles styles) {
    if (styles.separatorBorder.isTransparent()) {
      el.classList.remove('separator-border');
      _removeProperty(el, '--separator-border');
    } else {
      el.classList.add('separator-border');
      el.style.setProperty('--separator-border', styles.separatorBorder.toString());
    }
  }

  /// 1:1: `addView(view, size, index, skipLayout)`.
  void addView(TView view, Object size, [int? index, bool? skipLayout]) =>
      doAddView(view, size, index ?? viewItems.length, skipLayout);

  /// 1:1: `removeView(index, sizing)`.
  TView removeView(int index, [Sizing? sizing]) {
    if (index < 0 || index >= viewItems.length) {
      throw StateError('Index out of bounds');
    }
    if (state != SplitViewState.Idle) {
      throw StateError('Cant modify splitview');
    }
    state = SplitViewState.Busy;
    try {
      if (sizing != null && sizing.type == 'auto') {
        sizing = areViewsDistributed()
            ? Sizing.Distribute
            : Sizing.Split(sizing.index ?? 0);
      }

      final ViewItem<TLayoutContext, TView>? referenceViewItem =
          sizing != null && sizing.type == 'split'
              ? viewItems[sizing.index ?? 0]
              : null;

      final ViewItem<TLayoutContext, TView> viewItemToRemove =
          viewItems.removeAt(index);

      if (referenceViewItem != null) {
        referenceViewItem.size += viewItemToRemove.size;
      }

      if (viewItems.length >= 1) {
        final int sashIndex = index - 1 > 0 ? index - 1 : 0;
        final SashItem sashItem = sashItems.removeAt(sashIndex);
        sashItem.disposable.dispose();
      }

      final bool distribute = sizing != null && sizing.type == 'distribute';
      relayout(null, null, distribute);
      if (distribute) distributeViewSizes();

      final TView result = viewItemToRemove.view;
      viewItemToRemove.dispose();
      return result;
    } finally {
      state = SplitViewState.Idle;
    }
  }

  /// 1:1: `removeAllViews()`.
  List<TView> removeAllViews() {
    if (state != SplitViewState.Idle) {
      throw StateError('Cant modify splitview');
    }
    state = SplitViewState.Busy;
    try {
      final List<ViewItem<TLayoutContext, TView>> items =
          viewItems.toList(growable: false);
      viewItems.clear();
      for (final ViewItem<TLayoutContext, TView> item in items) {
        item.dispose();
      }
      final List<SashItem> itemsToDispose = sashItems.toList(growable: false);
      sashItems.clear();
      for (final SashItem sashItem in itemsToDispose) {
        sashItem.disposable.dispose();
      }
      relayout();
      return items.map((ViewItem<TLayoutContext, TView> i) => i.view).toList();
    } finally {
      state = SplitViewState.Idle;
    }
  }

  /// 1:1: `moveView(from, to)`.
  void moveView(int from, int to) {
    if (state != SplitViewState.Idle) {
      throw StateError('Cant modify splitview');
    }
    final num? cachedVisibleSize = getViewCachedVisibleSize(from);
    final Object sizing = cachedVisibleSize == null
        ? getViewSize(from)
        : Sizing.Invisible(cachedVisibleSize);
    final TView view = removeView(from);
    addView(view, sizing, to);
  }

  /// 1:1: `swapViews(from, to)`.
  void swapViews(int from, int to) {
    if (state != SplitViewState.Idle) {
      throw StateError('Cant modify splitview');
    }
    if (from > to) return swapViews(to, from);
    final num fromSize = getViewSize(from);
    final num toSize = getViewSize(to);
    final TView toView = removeView(to);
    final TView fromView = removeView(from);
    addView(toView, fromSize, from);
    addView(fromView, toSize, to);
  }

  /// 1:1: `isViewVisible(index)`.
  bool isViewVisible(int index) {
    if (index < 0 || index >= viewItems.length) {
      throw StateError('Index out of bounds');
    }
    return viewItems[index].visible;
  }

  /// 1:1: `setViewVisible(index, visible)`.
  void setViewVisible(int index, bool visible) {
    if (index < 0 || index >= viewItems.length) {
      throw StateError('Index out of bounds');
    }
    final ViewItem<TLayoutContext, TView> viewItem = viewItems[index];
    viewItem.setVisible(visible);
    distributeEmptySpace(index);
    layoutViews();
    saveProportions();
  }

  /// 1:1: `getViewCachedVisibleSize(index)`.
  num? getViewCachedVisibleSize(int index) {
    if (index < 0 || index >= viewItems.length) {
      throw StateError('Index out of bounds');
    }
    return viewItems[index].cachedVisibleSize;
  }

  /// 1:1: `layout(size, layoutContext)`.
  void layout(num layoutSize, [TLayoutContext? inContext]) {
    final num previousSize = size > _contentSize ? size : _contentSize;
    size = layoutSize;
    layoutContext = inContext;

    if (proportions == null) {
      final List<int> indexes = arrays.range(viewItems.length);
      final List<int> lowPriorityIndexes = indexes
          .where((int i) => viewItems[i].priority == LayoutPriority.Low)
          .toList();
      final List<int> highPriorityIndexes = indexes
          .where((int i) => viewItems[i].priority == LayoutPriority.High)
          .toList();
      resize(viewItems.length - 1, layoutSize - previousSize, null,
          lowPriorityIndexes, highPriorityIndexes);
    } else {
      num total = 0;
      for (int i = 0; i < viewItems.length; i++) {
        final ViewItem<TLayoutContext, TView> item = viewItems[i];
        final num? proportion = _proportionAt(i);
        if (proportion != null) {
          total += proportion;
        } else {
          item.size = numbers.clamp(item.size, item.minimumSize, item.maximumSize);
          layoutSize -= item.size;
        }
      }
      for (int i = 0; i < viewItems.length; i++) {
        final ViewItem<TLayoutContext, TView> item = viewItems[i];
        final num? proportion = _proportionAt(i);
        if (proportion != null && total > 0) {
          item.size = numbers.clamp(
              (proportion * layoutSize / total).round(),
              item.minimumSize,
              item.maximumSize);
        }
      }
    }

    distributeEmptySpace();
    layoutViews();
  }

  num? _proportionAt(int index) =>
      proportions != null && index < proportions!.length ? proportions![index] : null;

  void saveProportions() {
    if (proportionalLayout && _contentSize > 0) {
      proportions = viewItems
          .map<num?>((ViewItem<TLayoutContext, TView> v) =>
              v.proportionalLayout && v.visible ? v.size / _contentSize : null)
          .toList();
    }
  }

  void onSashStart(SplitSashEvent event) {
    for (final ViewItem<TLayoutContext, TView> item in viewItems) {
      item.enabled = false;
    }

    final ISplitViewSash sash = event.sash;
    final int index = sashItems.indexWhere((SashItem item) => identical(item.sash, sash));

    late final lifecycle.IDisposable disposable;

    void resetSashDragState(num startValue, bool alt) {
      final List<num> sizes = viewItems
          .map<num>((ViewItem<TLayoutContext, TView> i) => i.size)
          .toList();
      num minDelta = double.negativeInfinity;
      num maxDelta = double.infinity;

      if (inverseAltBehavior) alt = !alt;

      if (alt) {
        final bool isLastSash = index == sashItems.length - 1;
        if (isLastSash) {
          final ViewItem<TLayoutContext, TView> viewItem = viewItems[index];
          minDelta = (viewItem.minimumSize - viewItem.size) / 2;
          maxDelta = (viewItem.maximumSize - viewItem.size) / 2;
        } else {
          final ViewItem<TLayoutContext, TView> viewItem = viewItems[index + 1];
          minDelta = (viewItem.size - viewItem.maximumSize) / 2;
          maxDelta = (viewItem.size - viewItem.minimumSize) / 2;
        }
      }

      SashDragSnapState? snapBefore;
      SashDragSnapState? snapAfter;

      if (!alt) {
        final List<int> upIndexes = arrays.range(index, -1);
        final List<int> downIndexes = arrays.range(index + 1, viewItems.length);
        final num minDeltaUp = upIndexes.fold<num>(0,
            (num r, int i) => r + (viewItems[i].minimumSize - sizes[i]));
        final num maxDeltaUp = upIndexes.fold<num>(0,
            (num r, int i) => r + (viewItems[i].viewMaximumSize - sizes[i]));
        final num maxDeltaDown = downIndexes.isEmpty
            ? double.infinity
            : downIndexes.fold<num>(
                0, (num r, int i) => r + (sizes[i] - viewItems[i].minimumSize));
        final num minDeltaDown = downIndexes.isEmpty
            ? double.negativeInfinity
            : downIndexes.fold<num>(
                0, (num r, int i) => r + (sizes[i] - viewItems[i].viewMaximumSize));
        final num localMinDelta =
            minDeltaUp > minDeltaDown ? minDeltaUp : minDeltaDown;
        final num localMaxDelta =
            maxDeltaDown < maxDeltaUp ? maxDeltaDown : maxDeltaUp;
        final int? snapBeforeIndex = findFirstSnapIndex(upIndexes);
        final int? snapAfterIndex = findFirstSnapIndex(downIndexes);

        if (snapBeforeIndex != null) {
          final ViewItem<TLayoutContext, TView> viewItem = viewItems[snapBeforeIndex];
          final int halfSize = (viewItem.viewMinimumSize / 2).floor();
          snapBefore = SashDragSnapState(
            index: snapBeforeIndex,
            limitDelta: viewItem.visible
                ? localMinDelta - halfSize
                : localMinDelta + halfSize,
            size: viewItem.size,
          );
        }
        if (snapAfterIndex != null) {
          final ViewItem<TLayoutContext, TView> viewItem = viewItems[snapAfterIndex];
          final int halfSize = (viewItem.viewMinimumSize / 2).floor();
          snapAfter = SashDragSnapState(
            index: snapAfterIndex,
            limitDelta: viewItem.visible
                ? localMaxDelta + halfSize
                : localMaxDelta - halfSize,
            size: viewItem.size,
          );
        }
      }

      sashDragState = SashDragState(
        index: index,
        start: startValue,
        current: startValue,
        sizes: sizes,
        minDelta: minDelta,
        maxDelta: maxDelta,
        alt: alt,
        snapBefore: snapBefore,
        snapAfter: snapAfter,
        disposable: disposable,
      );
    }

    final dom.DomElement body = el.ownerDocument?.body ?? dom.document.body;
    disposable = lifecycle.combinedDisposable(<lifecycle.IDisposable>[
      dom.addDisposableListener(body, dom.EventType.KEY_DOWN,
          (dom.DomEvent e) =>
              resetSashDragState(sashDragState!.current, e.altKey)),
      dom.addDisposableListener(body, dom.EventType.KEY_UP,
          (dom.DomEvent e) => resetSashDragState(sashDragState!.current, false)),
    ]);
    resetSashDragState(event.start, event.alt);
  }

  void onSashChange(SplitSashEvent event) {
    final SashDragState dragState = sashDragState!;
    final int index = dragState.index;
    final num start = dragState.start;
    final List<num> sizes = dragState.sizes;
    final bool alt = dragState.alt;
    final num minDelta = dragState.minDelta;
    final num maxDelta = dragState.maxDelta;
    final SashDragSnapState? snapBefore = dragState.snapBefore;
    final SashDragSnapState? snapAfter = dragState.snapAfter;
    dragState.current = event.current;

    final num delta = event.current - start;
    final num newDelta = resize(index, delta, sizes, null, null, minDelta,
        maxDelta, snapBefore, snapAfter);

    if (alt) {
      final bool isLastSash = index == sashItems.length - 1;
      final List<num> newSizes = viewItems
          .map<num>((ViewItem<TLayoutContext, TView> i) => i.size)
          .toList();
      final int viewItemIndex = isLastSash ? index : index + 1;
      final ViewItem<TLayoutContext, TView> viewItem = viewItems[viewItemIndex];
      final num newMinDelta = viewItem.size - viewItem.maximumSize;
      final num newMaxDelta = viewItem.size - viewItem.minimumSize;
      final int resizeIndex = isLastSash ? index - 1 : index + 1;
      resize(resizeIndex, -newDelta, newSizes, null, null, newMinDelta, newMaxDelta);
    }

    distributeEmptySpace();
    layoutViews();
  }

  void onSashEnd(int index) {
    _onDidSashChange.fire(index);
    sashDragState!.disposable.dispose();
    saveProportions();
    for (final ViewItem<TLayoutContext, TView> item in viewItems) {
      item.enabled = true;
    }
  }

  void onViewChange(ViewItem<TLayoutContext, TView> item, num? inSize) {
    final int index = viewItems.indexOf(item);
    if (index < 0 || index >= viewItems.length) return;

    num resolved = inSize ?? item.size;
    resolved = numbers.clamp(resolved, item.minimumSize, item.maximumSize);

    if (inverseAltBehavior && index > 0) {
      resize(index - 1, ((item.size - resolved) / 2).floor());
      distributeEmptySpace();
      layoutViews();
    } else {
      item.size = resolved;
      final List<int> indexes = arrays
          .range(viewItems.length)
          .where((int i) => i != index)
          .toList();
      final List<int> lowPriorityIndexes = <int>[
        ...indexes.where((int i) => viewItems[i].priority == LayoutPriority.Low),
        index,
      ];
      final List<int> highPriorityIndexes = indexes
          .where((int i) => viewItems[i].priority == LayoutPriority.High)
          .toList();
      relayout(lowPriorityIndexes, highPriorityIndexes);
    }
  }

  /// 1:1: `resizeView(index, size)`.
  void resizeView(int index, num viewSize) {
    if (index < 0 || index >= viewItems.length) return;
    if (state != SplitViewState.Idle) {
      throw StateError('Cant modify splitview');
    }
    state = SplitViewState.Busy;
    try {
      final List<int> indexes = arrays
          .range(viewItems.length)
          .where((int i) => i != index)
          .toList();
      final List<int> lowPriorityIndexes = <int>[
        ...indexes.where((int i) => viewItems[i].priority == LayoutPriority.Low),
        index,
      ];
      final List<int> highPriorityIndexes = indexes
          .where((int i) => viewItems[i].priority == LayoutPriority.High)
          .toList();
      final ViewItem<TLayoutContext, TView> item = viewItems[index];
      final num resolved = numbers.clamp(viewSize.round(), item.minimumSize,
          item.maximumSize > size ? size : item.maximumSize);
      item.size = resolved;
      relayout(lowPriorityIndexes, highPriorityIndexes);
    } finally {
      state = SplitViewState.Idle;
    }
  }

  /// 1:1: `isViewExpanded(index)`.
  bool isViewExpanded(int index) {
    if (index < 0 || index >= viewItems.length) return false;
    for (final ViewItem<TLayoutContext, TView> item in viewItems) {
      if (!identical(item, viewItems[index]) && item.size > item.minimumSize) {
        return false;
      }
    }
    return true;
  }

  /// 1:1: `distributeViewSizes()`.
  void distributeViewSizes() {
    final List<ViewItem<TLayoutContext, TView>> flexibleViewItems =
        <ViewItem<TLayoutContext, TView>>[];
    num flexibleSize = 0;
    for (final ViewItem<TLayoutContext, TView> item in viewItems) {
      if (item.maximumSize - item.minimumSize > 0) {
        flexibleViewItems.add(item);
        flexibleSize += item.size;
      }
    }
    if (flexibleViewItems.isEmpty) return;
    final num distributed = (flexibleSize / flexibleViewItems.length).floor();
    for (final ViewItem<TLayoutContext, TView> item in flexibleViewItems) {
      item.size = numbers.clamp(distributed, item.minimumSize, item.maximumSize);
    }
    final List<int> indexes = arrays.range(viewItems.length);
    final List<int> lowPriorityIndexes = indexes
        .where((int i) => viewItems[i].priority == LayoutPriority.Low)
        .toList();
    final List<int> highPriorityIndexes = indexes
        .where((int i) => viewItems[i].priority == LayoutPriority.High)
        .toList();
    relayout(lowPriorityIndexes, highPriorityIndexes);
  }

  /// 1:1: `getViewSize(index)`.
  num getViewSize(int index) {
    if (index < 0 || index >= viewItems.length) return -1;
    return viewItems[index].size;
  }

  void doAddView(TView view, Object inSize,
      [int? inIndex, bool? skipLayout]) {
    if (state != SplitViewState.Idle) {
      throw StateError('Cant modify splitview');
    }
    state = SplitViewState.Busy;
    final int index = inIndex ?? viewItems.length;
    try {
      final dom.DomElement container = _dollar('.split-view-view');

      if (index == viewItems.length) {
        viewContainer.appendChild(container);
      } else {
        final List<dom.DomElement> children = _childElements(viewContainer);
        viewContainer.insertBefore(
            container, index < children.length ? children[index] : null);
      }

      late final ViewItem<TLayoutContext, TView> item;
      final lifecycle.IDisposable onChangeDisposable =
          view.onDidChange((dynamic value) =>
              onViewChange(item, value == null ? null : value as num));
      final lifecycle.IDisposable containerDisposable =
          lifecycle.toDisposable(() => container.remove());
      final lifecycle.IDisposable disposable = lifecycle.combinedDisposable(
          <lifecycle.IDisposable>[onChangeDisposable, containerDisposable]);

      ViewItemSize viewSize;
      Object sizing = inSize;
      if (sizing is num) {
        viewSize = ViewItemSize.size(sizing);
      } else {
        final Sizing typed = sizing as Sizing;
        if (typed.type == 'auto') {
          sizing = areViewsDistributed()
              ? Sizing.Distribute
              : Sizing.Split(typed.index ?? 0);
        }
        final Sizing resolved = sizing;
        if (resolved.type == 'split') {
          viewSize = ViewItemSize.size(getViewSize(resolved.index ?? 0) / 2);
        } else if (resolved.type == 'invisible') {
          viewSize = ViewItemSize.invisible(resolved.cachedVisibleSize ?? 0);
        } else {
          viewSize = ViewItemSize.size(view.minimumSize);
        }
      }

      item = orientation == sash.Orientation.VERTICAL
          ? VerticalViewItem<TLayoutContext, TView>(container, view, viewSize, disposable)
          : HorizontalViewItem<TLayoutContext, TView>(container, view, viewSize, disposable);

      viewItems.insert(index, item);

      if (viewItems.length > 1) {
        final Object layoutProvider = orientation == sash.Orientation.VERTICAL
            ? _VerticalSashLayoutProvider(this)
            : _HorizontalSashLayoutProvider(this);
        final ISplitViewSash newSash = splitViewSashFactory(
            sashContainer,
            layoutProvider,
            SplitViewSashOptions(
              orientation: orientation == sash.Orientation.VERTICAL
                  ? sash.Orientation.HORIZONTAL
                  : sash.Orientation.VERTICAL,
              orthogonalStartSash: _orthogonalStartSash,
              orthogonalEndSash: _orthogonalEndSash,
            ));

        sash.SashEvent Function(dynamic e) sashEventMapper =
            orientation == sash.Orientation.VERTICAL
                ? (dynamic e) {
                    final sash.SashEvent ev = e as sash.SashEvent;
                    return sash.SashEvent(
                      startX: ev.startX,
                      currentX: ev.currentX,
                      startY: ev.startY,
                      currentY: ev.currentY,
                      altKey: ev.altKey,
                    );
                  }
                : (dynamic e) {
                    final sash.SashEvent ev = e as sash.SashEvent;
                    return sash.SashEvent(
                      startX: ev.startX,
                      currentX: ev.currentX,
                      startY: ev.startY,
                      currentY: ev.currentY,
                      altKey: ev.altKey,
                    );
                  };

        final event.Event<SplitSashEvent> onStart = event.eventMap<sash.SashEvent, SplitSashEvent>(
            newSash.onDidStart, (sash.SashEvent e) {
          final sash.SashEvent mapped = sashEventMapper(e);
          return SplitSashEvent(
            sash: newSash,
            start: orientation == sash.Orientation.VERTICAL
                ? mapped.startY
                : mapped.startX,
            current: orientation == sash.Orientation.VERTICAL
                ? mapped.currentY
                : mapped.currentX,
            alt: mapped.altKey,
          );
        });
        final lifecycle.IDisposable onStartDisposable =
            onStart((dynamic value) => onSashStart(value as SplitSashEvent));
        final event.Event<SplitSashEvent> onChange = event.eventMap<sash.SashEvent, SplitSashEvent>(
            newSash.onDidChange, (sash.SashEvent e) {
          final sash.SashEvent mapped = sashEventMapper(e);
          return SplitSashEvent(
            sash: newSash,
            start: orientation == sash.Orientation.VERTICAL
                ? mapped.startY
                : mapped.startX,
            current: orientation == sash.Orientation.VERTICAL
                ? mapped.currentY
                : mapped.currentX,
            alt: mapped.altKey,
          );
        });
        final lifecycle.IDisposable onChangeDisposableForSash =
            onChange((dynamic value) => onSashChange(value as SplitSashEvent));
        final event.Event<int> onEnd =
            event.eventMap<void, int>(newSash.onDidEnd, (void e) =>
                sashItems.indexWhere((SashItem item) => identical(item.sash, newSash)));
        final lifecycle.IDisposable onEndDisposable =
            onEnd((dynamic value) => onSashEnd(value as int));

        final lifecycle.IDisposable onDidResetDisposable =
            newSash.onDidReset((dynamic e) {
          final int sashIndex =
              sashItems.indexWhere((SashItem item) => identical(item.sash, newSash));
          final List<int> upIndexes = arrays.range(sashIndex, -1);
          final List<int> downIndexes =
              arrays.range(sashIndex + 1, viewItems.length);
          final int? snapBeforeIndex = findFirstSnapIndex(upIndexes);
          final int? snapAfterIndex = findFirstSnapIndex(downIndexes);

          if (snapBeforeIndex != null && !viewItems[snapBeforeIndex].visible) return;
          if (snapAfterIndex != null && !viewItems[snapAfterIndex].visible) return;
          _onDidSashReset.fire(sashIndex);
        });

        final lifecycle.IDisposable sashWholeDisposable = lifecycle.combinedDisposable(
            <lifecycle.IDisposable>[
          onStartDisposable,
          onChangeDisposableForSash,
          onEndDisposable,
          onDidResetDisposable,
          lifecycle.toDisposable(() => newSash.dispose()),
        ]);
        int sashInsertionIndex = index - 1;
        if (sashInsertionIndex < 0) {
          sashInsertionIndex = sashItems.length + sashInsertionIndex;
        }
        if (sashInsertionIndex < 0) sashInsertionIndex = 0;
        sashItems.insert(
            sashInsertionIndex, SashItem(sash: newSash, disposable: sashWholeDisposable));
      }

      container.appendChild(view.element);

      List<int>? highPriorityIndexes;
      if (sizing is Sizing && sizing.type == 'split') {
        highPriorityIndexes = <int>[sizing.index ?? 0];
      }

      if (skipLayout != true) {
        final bool distribute = sizing is Sizing && sizing.type == 'distribute';
        relayout(<int>[index], highPriorityIndexes, distribute);
        if (distribute) distributeViewSizes();
      }
    } finally {
      state = SplitViewState.Idle;
    }
  }

  void relayout([List<int>? lowPriorityIndexes, List<int>? highPriorityIndexes,
      bool skipLayout = false]) {
    final num contentSize =
        viewItems.fold<num>(0, (num r, ViewItem<TLayoutContext, TView> i) => r + i.size);
    resize(viewItems.length - 1, size - contentSize, null,
        lowPriorityIndexes, highPriorityIndexes);
    distributeEmptySpace();
    if (!skipLayout ||
        !viewItems.every((ViewItem<TLayoutContext, TView> item) =>
            item.view.pathIndependentLayout ?? false)) {
      layoutViews();
      saveProportions();
    }
  }

  num resize(
    int index,
    num delta, [
    List<num>? inSizes,
    List<int>? lowPriorityIndexes,
    List<int>? highPriorityIndexes,
    num? overloadMinDelta,
    num? overloadMaxDelta,
    SashDragSnapState? snapBefore,
    SashDragSnapState? snapAfter,
  ]) {
    if (index < 0 || index >= viewItems.length) return 0;
    final List<num> sizes = inSizes ??
        viewItems.map<num>((ViewItem<TLayoutContext, TView> i) => i.size).toList();

    final num minOverload = overloadMinDelta ?? double.negativeInfinity;
    final num maxOverload = overloadMaxDelta ?? double.infinity;

    final List<int> upIndexes = arrays.range(index, -1);
    final List<int> downIndexes = arrays.range(index + 1, viewItems.length);

    if (highPriorityIndexes != null) {
      for (final int i in highPriorityIndexes) {
        arrays.pushToStart(upIndexes, i);
        arrays.pushToStart(downIndexes, i);
      }
    }
    if (lowPriorityIndexes != null) {
      for (final int i in lowPriorityIndexes) {
        arrays.pushToEnd(upIndexes, i);
        arrays.pushToEnd(downIndexes, i);
      }
    }

    final List<ViewItem<TLayoutContext, TView>> upItems =
        upIndexes.map((int i) => viewItems[i]).toList();
    final List<num> upSizes = upIndexes.map((int i) => sizes[i]).toList();
    final List<ViewItem<TLayoutContext, TView>> downItems =
        downIndexes.map((int i) => viewItems[i]).toList();
    final List<num> downSizes = downIndexes.map((int i) => sizes[i]).toList();

    final num minDeltaUp = upIndexes.fold<num>(
        0, (num r, int i) => r + (viewItems[i].minimumSize - sizes[i]));
    final num maxDeltaUp = upIndexes.fold<num>(
        0, (num r, int i) => r + (viewItems[i].maximumSize - sizes[i]));
    final num maxDeltaDown = downIndexes.isEmpty
        ? double.infinity
        : downIndexes.fold<num>(
            0, (num r, int i) => r + (sizes[i] - viewItems[i].minimumSize));
    final num minDeltaDown = downIndexes.isEmpty
        ? double.negativeInfinity
        : downIndexes.fold<num>(
            0, (num r, int i) => r + (sizes[i] - viewItems[i].maximumSize));
    final num minDelta = [minDeltaUp, minDeltaDown, minOverload].reduce((num a, num b) => a > b ? a : b);
    final num maxDelta = [maxDeltaDown, maxDeltaUp, maxOverload].reduce((num a, num b) => a < b ? a : b);

    bool snapped = false;
    if (snapBefore != null) {
      final ViewItem<TLayoutContext, TView> snapView = viewItems[snapBefore.index];
      final bool isVisible = delta >= snapBefore.limitDelta;
      snapped = isVisible != snapView.visible;
      snapView.setVisible(isVisible, snapBefore.size);
    }
    if (!snapped && snapAfter != null) {
      final ViewItem<TLayoutContext, TView> snapView = viewItems[snapAfter.index];
      final bool isVisible = delta < snapAfter.limitDelta;
      snapped = isVisible != snapView.visible;
      snapView.setVisible(isVisible, snapAfter.size);
    }
    if (snapped) {
      return resize(index, delta, sizes, lowPriorityIndexes, highPriorityIndexes,
          minOverload, maxOverload);
    }

    final num clamped = numbers.clamp(delta, minDelta, maxDelta);
    num deltaUp = clamped;
    for (int i = 0; i < upItems.length; i++) {
      final ViewItem<TLayoutContext, TView> item = upItems[i];
      final num itemSize = numbers.clamp(upSizes[i] + deltaUp, item.minimumSize, item.maximumSize);
      final num viewDelta = itemSize - upSizes[i];
      deltaUp -= viewDelta;
      item.size = itemSize;
    }
    num deltaDown = clamped;
    for (int i = 0; i < downItems.length; i++) {
      final ViewItem<TLayoutContext, TView> item = downItems[i];
      final num itemSize = numbers.clamp(downSizes[i] - deltaDown, item.minimumSize, item.maximumSize);
      final num viewDelta = itemSize - downSizes[i];
      deltaDown += viewDelta;
      item.size = itemSize;
    }
    return clamped;
  }

  void distributeEmptySpace([int? lowPriorityIndex]) {
    final num contentSize =
        viewItems.fold<num>(0, (num r, ViewItem<TLayoutContext, TView> i) => r + i.size);
    num emptyDelta = size - contentSize;

    final List<int> indexes = arrays.range(viewItems.length - 1, -1);
    final List<int> lowPriorityIndexes = indexes
        .where((int i) => viewItems[i].priority == LayoutPriority.Low)
        .toList();
    final List<int> highPriorityIndexes = indexes
        .where((int i) => viewItems[i].priority == LayoutPriority.High)
        .toList();

    for (final int i in highPriorityIndexes) {
      arrays.pushToStart(indexes, i);
    }
    for (final int i in lowPriorityIndexes) {
      arrays.pushToEnd(indexes, i);
    }
    if (lowPriorityIndex != null) {
      arrays.pushToEnd(indexes, lowPriorityIndex);
    }

    for (int i = 0; emptyDelta != 0 && i < indexes.length; i++) {
      final ViewItem<TLayoutContext, TView> item = viewItems[indexes[i]];
      final num itemSize =
          numbers.clamp(item.size + emptyDelta, item.minimumSize, item.maximumSize);
      final num viewDelta = itemSize - item.size;
      emptyDelta -= viewDelta;
      item.size = itemSize;
    }
  }

  void layoutViews() {
    _contentSize =
        viewItems.fold<num>(0, (num r, ViewItem<TLayoutContext, TView> i) => r + i.size);
    num offset = 0;
    for (final ViewItem<TLayoutContext, TView> viewItem in viewItems) {
      viewItem.layout(offset, layoutContext);
      offset += viewItem.size;
    }
    for (final SashItem item in sashItems) {
      item.sash.layout();
    }
    updateSashEnablement();
    updateScrollableElement();
  }

  void updateScrollableElement() {
    if (orientation == sash.Orientation.VERTICAL) {
      scrollableElement.setScrollDimensions(scr.NewScrollDimensions(
        height: size,
        scrollHeight: _contentSize,
      ));
    } else {
      scrollableElement.setScrollDimensions(scr.NewScrollDimensions(
        width: size,
        scrollWidth: _contentSize,
      ));
    }
  }

  void updateSashEnablement() {
    bool previous = false;
    final List<bool> collapsesDown = viewItems.map((ViewItem<TLayoutContext, TView> i) {
      previous = (i.size - i.minimumSize > 0) || previous;
      return previous;
    }).toList();

    previous = false;
    final List<bool> expandsDown = viewItems.map((ViewItem<TLayoutContext, TView> i) {
      previous = (i.maximumSize - i.size > 0) || previous;
      return previous;
    }).toList();

    final List<ViewItem<TLayoutContext, TView>> reverseViews =
        viewItems.reversed.toList();
    previous = false;
    final List<bool> collapsesUp = reverseViews
        .map((ViewItem<TLayoutContext, TView> i) {
          previous = (i.size - i.minimumSize > 0) || previous;
          return previous;
        })
        .toList()
        .reversed
        .toList();
    previous = false;
    final List<bool> expandsUp = reverseViews
        .map((ViewItem<TLayoutContext, TView> i) {
          previous = (i.maximumSize - i.size > 0) || previous;
          return previous;
        })
        .toList()
        .reversed
        .toList();

    num position = 0;
    for (int index = 0; index < sashItems.length; index++) {
      final ISplitViewSash itemSash = sashItems[index].sash;
      final ViewItem<TLayoutContext, TView> viewItem = viewItems[index];
      position += viewItem.size;

      final bool min = !(collapsesDown[index] && expandsUp[index + 1]);
      final bool max = !(expandsDown[index] && collapsesUp[index + 1]);

      if (min && max) {
        final List<int> upIndexes = arrays.range(index, -1);
        final List<int> downIndexes = arrays.range(index + 1, viewItems.length);
        final int? snapBeforeIndex = findFirstSnapIndex(upIndexes);
        final int? snapAfterIndex = findFirstSnapIndex(downIndexes);
        final bool snappedBefore = snapBeforeIndex != null && !viewItems[snapBeforeIndex].visible;
        final bool snappedAfter = snapAfterIndex != null && !viewItems[snapAfterIndex].visible;

        if (snappedBefore &&
            collapsesUp[index] &&
            (position > 0 || startSnappingEnabled)) {
          itemSash.state = sash.SashState.AtMinimum;
        } else if (snappedAfter &&
            collapsesDown[index] &&
            (position < _contentSize || endSnappingEnabled)) {
          itemSash.state = sash.SashState.AtMaximum;
        } else {
          itemSash.state = sash.SashState.Disabled;
        }
      } else if (min && !max) {
        itemSash.state = sash.SashState.AtMinimum;
      } else if (!min && max) {
        itemSash.state = sash.SashState.AtMaximum;
      } else {
        itemSash.state = sash.SashState.Enabled;
      }
    }
  }

  num getSashPosition(ISplitViewSash targetSash) {
    num position = 0;
    for (int i = 0; i < sashItems.length; i++) {
      position += viewItems[i].size;
      if (identical(sashItems[i].sash, targetSash)) return position;
    }
    return 0;
  }

  int? findFirstSnapIndex(List<int> indexes) {
    for (final int index in indexes) {
      final ViewItem<TLayoutContext, TView> viewItem = viewItems[index];
      if (!viewItem.visible) continue;
      if (viewItem.snap) return index;
    }
    for (final int index in indexes) {
      final ViewItem<TLayoutContext, TView> viewItem = viewItems[index];
      if (viewItem.visible &&
          viewItem.maximumSize - viewItem.minimumSize > 0) {
        return null;
      }
      if (!viewItem.visible && viewItem.snap) return index;
    }
    return null;
  }

  bool areViewsDistributed() {
    num? min, max;
    for (final ViewItem<TLayoutContext, TView> view in viewItems) {
      min = min == null ? view.size : (min < view.size ? min : view.size);
      max = max == null ? view.size : (max > view.size ? max : view.size);
      if (max - min > 2) return false;
    }
    return true;
  }

  @override
  void dispose() {
    sashDragState?.disposable.dispose();
    lifecycle.dispose(viewItems);
    viewItems.clear();
    for (final SashItem i in sashItems) {
      i.disposable.dispose();
    }
    sashItems.clear();
    super.dispose();
  }
}

class _VerticalSashLayoutProvider implements sash.IVerticalSashLayoutProvider {
  _VerticalSashLayoutProvider(this.splitView);

  final SplitView<dynamic, dynamic> splitView;

  @override
  num getVerticalSashLeft(sash.Sash sashValue) =>
      splitView.getSashPosition(_wrap(sashValue));

  @override
  num? getVerticalSashTop(sash.Sash sashValue) => null;
  @override
  num? getVerticalSashHeight(sash.Sash sashValue) =>
      splitView.getSashOrthogonalSize?.call();

  ISplitViewSash _wrap(sash.Sash value) => _SashIdentity(value);
}

class _HorizontalSashLayoutProvider implements sash.IHorizontalSashLayoutProvider {
  _HorizontalSashLayoutProvider(this.splitView);

  final SplitView<dynamic, dynamic> splitView;

  @override
  num getHorizontalSashTop(sash.Sash sashValue) =>
      splitView.getSashPosition(_wrap(sashValue));

  @override
  num? getHorizontalSashLeft(sash.Sash sashValue) => null;
  @override
  num? getHorizontalSashWidth(sash.Sash sashValue) =>
      splitView.getSashOrthogonalSize?.call();

  ISplitViewSash _wrap(sash.Sash value) => _SashIdentity(value);
}

/// Identity-only carrier so layout providers can look up the real sash without
/// owning it. Only [identical] matters in `getSashPosition`.
class _SashIdentity implements ISplitViewSash {
  _SashIdentity(this.real);

  final sash.Sash real;

  @override
  int get state => real.state;
  @override
  set state(int value) => real.state = value;
  @override
  ISplitViewSash? get orthogonalStartSash => null;
  @override
  set orthogonalStartSash(ISplitViewSash? value) {}
  @override
  ISplitViewSash? get orthogonalEndSash => null;
  @override
  set orthogonalEndSash(ISplitViewSash? value) {}
  @override
  event.Event<sash.SashEvent> get onDidStart => real.onDidStart;
  @override
  event.Event<sash.SashEvent> get onDidChange => real.onDidChange;
  @override
  event.Event<void> get onDidEnd => real.onDidEnd;
  @override
  event.Event<void> get onDidReset => real.onDidReset;
  @override
  void layout() {}
  @override
  void dispose() {}
}
