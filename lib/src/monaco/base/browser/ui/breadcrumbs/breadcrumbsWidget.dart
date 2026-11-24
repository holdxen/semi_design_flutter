// 1:1 port of vscode/src/vs/base/browser/ui/breadcrumbs/breadcrumbsWidget.ts
import '../../dom.dart' as dom;
import '../../domStylesheets.dart' as ds;
import '../../mouseEvent.dart' as mouse;
import '../../window.dart' show CodeWindow;
import '../scrollbar/scrollableElement.dart' as scrollable;
import '../scrollbar/scrollableElementOptions.dart'
    show ScrollableElementChangeOptions, ScrollableElementCreationOptions;
import '../../../common/arrays.dart' as arrays;
import '../../../common/themables.dart' as themables;
import '../../../common/event.dart' as event;
import '../../../common/lifecycle.dart' as lc;
import '../../../common/scrollable.dart' as scr;

/// 1:1: `abstract class BreadcrumbsItem`
abstract class BreadcrumbsItem {
  void dispose();
  bool equals(BreadcrumbsItem other);
  void render(dom.DomElement container);
}

/// 1:1: `interface IBreadcrumbsWidgetStyles`
class IBreadcrumbsWidgetStyles {
  IBreadcrumbsWidgetStyles({
    this.breadcrumbsBackground,
    this.breadcrumbsForeground,
    this.breadcrumbsHoverForeground,
    this.breadcrumbsFocusForeground,
    this.breadcrumbsFocusAndSelectionForeground,
  });

  final String? breadcrumbsBackground;
  final String? breadcrumbsForeground;
  final String? breadcrumbsHoverForeground;
  final String? breadcrumbsFocusForeground;
  final String? breadcrumbsFocusAndSelectionForeground;
}

/// 1:1: `interface IBreadcrumbsItemEvent`
class IBreadcrumbsItemEvent {
  IBreadcrumbsItemEvent({
    required this.type,
    required this.item,
    required this.node,
    required this.payload,
  });

  /// 1:1: `'select' | 'focus'`
  final String type;
  final BreadcrumbsItem? item;
  final dom.DomElement? node;
  final Object? payload;
}

/// 1:1: shape of the `DomScrollableElement` methods used by the widget.
/// The narrow interface is the test seam; the default factory returns the
/// real ported class.
abstract class IBreadcrumbsScrollable implements lc.IDisposable {
  dom.DomElement getDomNode();
  void updateOptions(ScrollableElementChangeOptions newOptions);
  void setRevealOnScroll(bool value);
  void scanDomNode();
  scr.IScrollDimensions getScrollDimensions();
  scr.IScrollPosition getScrollPosition();
  void setScrollPosition(scr.NewScrollPosition update);
}

/// 1:1: `dom.measure` / `dom.modify` signature.
typedef BreadcrumbsFrameScheduler = lc.IDisposable Function(
    CodeWindow targetWindow, void Function() callback);

/// Adapter exposing the real `DomScrollableElement` through the narrow seam.
class _RealBreadcrumbsScrollable implements IBreadcrumbsScrollable {
  _RealBreadcrumbsScrollable(this._inner);

  final scrollable.DomScrollableElement _inner;

  @override
  dom.DomElement getDomNode() => _inner.getDomNode();

  @override
  void updateOptions(ScrollableElementChangeOptions newOptions) =>
      _inner.updateOptions(newOptions);

  @override
  void setRevealOnScroll(bool value) => _inner.setRevealOnScroll(value);

  @override
  void scanDomNode() => _inner.scanDomNode();

  @override
  scr.IScrollDimensions getScrollDimensions() => _inner.getScrollDimensions();

  @override
  scr.IScrollPosition getScrollPosition() => _inner.getScrollPosition();

  @override
  void setScrollPosition(scr.NewScrollPosition update) =>
      _inner.setScrollPosition(update);

  @override
  void dispose() => _inner.dispose();
}

/// Injectable boundaries (test seams). Defaults call the real ported code.
BreadcrumbsFrameScheduler breadcrumbsMeasureFactory = dom.measure;
BreadcrumbsFrameScheduler breadcrumbsModifyFactory = dom.modify;
dom.IFocusTracker Function(Object element) breadcrumbsTrackFocusFactory =
    (Object element) => dom.trackFocus(element);
dom.DomElement Function(dom.DomElement container)
    breadcrumbsCreateStyleSheetFactory = (dom.DomElement container) =>
        ds.createStyleSheet(container);
IBreadcrumbsScrollable Function(
        dom.DomElement element, ScrollableElementCreationOptions options)
    breadcrumbsScrollableFactory =
    (dom.DomElement element, ScrollableElementCreationOptions options) =>
        _RealBreadcrumbsScrollable(
            scrollable.DomScrollableElement(element, options));
lc.IDisposable Function(
        dom.DomElement node, String type, void Function(Object event) handler)
    breadcrumbsClickListenerFactory = (dom.DomElement node, String type,
            void Function(Object event) handler) =>
        dom.addStandardDisposableListener(node, type, handler);

/// 1:1: browser `console.error` used by `_renderItem` error handling.
void Function(Object error) breadcrumbsConsoleError = print;

/// 1:1: the wrapped error thrown by `setItems` when an item operation fails.
class BreadcrumbsSetItemsError implements Exception {
  BreadcrumbsSetItemsError(this.original, this.message)
      : name = _nameOf(original),
        stackTrace = original is Error ? original.stackTrace : null;

  final Object original;
  final String message;
  String? name;
  StackTrace? stackTrace;

  static String? _nameOf(Object e) {
    try {
      final Object? n = (e as dynamic).name;
      return n is String ? n : null;
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => name == null ? message : '$name: $message';
}

/// 1:1: `export class BreadcrumbsWidget`
class BreadcrumbsWidget {
  BreadcrumbsWidget(
    dom.DomElement container,
    num horizontalScrollbarSize, [
    int horizontalScrollbarVisibility = scr.ScrollbarVisibility.Auto,
    themables.ThemeIcon? separatorIcon,
    IBreadcrumbsWidgetStyles? styles,
    BreadcrumbsFrameScheduler? measure,
  ])  : _separatorIcon = separatorIcon ?? themables.ThemeIcon(''),
        _measure = measure ?? dom.measure {
    _domNode = dom.document.createElement('div');
    _domNode.className = 'monaco-breadcrumbs';
    _domNode.tabIndex = 0;
    _domNode.setAttribute('role', 'list');
    _scrollable = breadcrumbsScrollableFactory(
        _domNode,
        ScrollableElementCreationOptions()
          ..vertical = scr.ScrollbarVisibility.Hidden
          ..horizontal = horizontalScrollbarVisibility
          ..horizontalScrollbarSize = horizontalScrollbarSize
          ..useShadows = false
          ..scrollYToX = true);
    _disposables.add(_scrollable);
    _disposables.add(breadcrumbsClickListenerFactory(
        _domNode, dom.EventType.CLICK, (Object e) {
      _onClick(e as mouse.IMouseEvent);
    }));
    container.appendChild(_scrollable.getDomNode());

    final dom.DomElement styleElement =
        breadcrumbsCreateStyleSheetFactory(_domNode);
    _style(styleElement, styles ?? IBreadcrumbsWidgetStyles());

    final dom.IFocusTracker focusTracker = breadcrumbsTrackFocusFactory(_domNode);
    _disposables.add(focusTracker);
    _disposables.add(focusTracker.onDidBlur((dynamic _) {
      _onDidChangeFocus.fire(false);
    }));
    _disposables.add(focusTracker.onDidFocus((dynamic _) {
      _onDidChangeFocus.fire(true);
    }));
  }

  final lc.DisposableStore _disposables = lc.DisposableStore();
  late final dom.DomElement _domNode;
  late final IBreadcrumbsScrollable _scrollable;

  final event.Emitter<IBreadcrumbsItemEvent> _onDidSelectItem =
      event.Emitter<IBreadcrumbsItemEvent>();
  final event.Emitter<IBreadcrumbsItemEvent> _onDidFocusItem =
      event.Emitter<IBreadcrumbsItemEvent>();
  final event.Emitter<bool> _onDidChangeFocus = event.Emitter<bool>();

  late final event.Event<IBreadcrumbsItemEvent> onDidSelectItem =
      _onDidSelectItem.event;
  late final event.Event<IBreadcrumbsItemEvent> onDidFocusItem =
      _onDidFocusItem.event;
  late final event.Event<bool> onDidChangeFocus = _onDidChangeFocus.event;

  final List<BreadcrumbsItem> _items = <BreadcrumbsItem>[];
  final List<dom.DomElement> _nodes = <dom.DomElement>[];
  final List<dom.DomElement> _freeNodes = <dom.DomElement>[];
  final themables.ThemeIcon _separatorIcon;

  bool _enabled = true;
  int _focusedItemIdx = -1;
  int _selectedItemIdx = -1;

  lc.IDisposable? _pendingDimLayout;
  lc.IDisposable? _pendingLayout;
  late final lc.MutableDisposable<lc.IDisposable> _pendingReveal =
      _disposables.add(lc.MutableDisposable<lc.IDisposable>());
  dom.Dimension? _dimension;
  final BreadcrumbsFrameScheduler _measure;

  /// Test seam: the real DOM node owned by the widget.
  dom.DomElement get debugDomNode => _domNode;

  /// Test seam: the scrollable instance produced by [breadcrumbsScrollableFactory].
  IBreadcrumbsScrollable get debugScrollable => _scrollable;

  /// Test seam: rendered item nodes, mirroring the TS private `_nodes`.
  List<dom.DomElement> get debugNodes => _nodes;

  /// Test seam: recycled item nodes, mirroring the TS private `_freeNodes`.
  List<dom.DomElement> get debugFreeNodes => _freeNodes;

  /// Test seam: last layout dimension, mirroring the TS private `_dimension`.
  dom.Dimension? get debugDimension => _dimension;

  /// Test seam: current focus/selection indices.
  int get debugFocusedItemIdx => _focusedItemIdx;
  int get debugSelectedItemIdx => _selectedItemIdx;

  void setHorizontalScrollbarSize(num size) {
    _scrollable.updateOptions(ScrollableElementChangeOptions()
      ..horizontalScrollbarSize = size);
  }

  void setHorizontalScrollbarVisibility(int visibility) {
    _scrollable.updateOptions(ScrollableElementChangeOptions()
      ..horizontal = visibility);
  }

  void dispose() {
    _disposables.dispose();
    _pendingLayout?.dispose();
    _pendingDimLayout?.dispose();
    _onDidSelectItem.dispose();
    _onDidFocusItem.dispose();
    _onDidChangeFocus.dispose();
    _domNode.remove();
    lc.dispose(_items);
    _items.clear();
    _nodes.clear();
    _freeNodes.clear();
  }

  void layout(dom.Dimension? dim) {
    if (dim != null && dom.Dimension.equals(dim, _dimension)) return;
    if (dim != null) {
      _pendingDimLayout?.dispose();
      _pendingDimLayout = _updateDimensions(dim);
    } else {
      _pendingLayout?.dispose();
      _pendingLayout = _updateScrollbar();
    }
  }

  lc.IDisposable _updateDimensions(dom.Dimension dim) {
    final lc.DisposableStore disposables = lc.DisposableStore();
    disposables.add(breadcrumbsModifyFactory(
        dom.getWindow(_domNode), () {
      _dimension = dim;
      _domNode.style['width'] = '${dim.width}px';
      _domNode.style['height'] = '${dim.height}px';
      disposables.add(_updateScrollbar());
    }));
    return disposables;
  }

  lc.IDisposable _updateScrollbar() {
    return breadcrumbsMeasureFactory(dom.getWindow(_domNode), () {
      breadcrumbsMeasureFactory(dom.getWindow(_domNode), () {
        // double RAF
        _scrollable.setRevealOnScroll(false);
        _scrollable.scanDomNode();
        _scrollable.setRevealOnScroll(true);
      });
    });
  }

  void _style(dom.DomElement styleElement, IBreadcrumbsWidgetStyles style) {
    final StringBuffer content = StringBuffer();
    if (style.breadcrumbsBackground != null) {
      content.writeln(
          '.monaco-breadcrumbs { background-color: ${style.breadcrumbsBackground}}');
    }
    if (style.breadcrumbsForeground != null) {
      content.writeln(
          '.monaco-breadcrumbs .monaco-breadcrumb-item { color: ${style.breadcrumbsForeground}}');
    }
    if (style.breadcrumbsFocusForeground != null) {
      content.writeln(
          '.monaco-breadcrumbs .monaco-breadcrumb-item.focused { color: ${style.breadcrumbsFocusForeground}}');
    }
    if (style.breadcrumbsFocusAndSelectionForeground != null) {
      content.writeln(
          '.monaco-breadcrumbs .monaco-breadcrumb-item.focused.selected { color: ${style.breadcrumbsFocusAndSelectionForeground}}');
    }
    if (style.breadcrumbsHoverForeground != null) {
      content.writeln(
          '.monaco-breadcrumbs:not(.disabled) .monaco-breadcrumb-item:hover:not(.focused):not(.selected) { color: ${style.breadcrumbsHoverForeground}}');
    }
    styleElement.textContent = content.toString();
  }

  void setEnabled(bool value) {
    _enabled = value;
    _domNode.classList.toggle('disabled', !_enabled);
  }

  void domFocus() {
    final int idx =
        _focusedItemIdx >= 0 ? _focusedItemIdx : _items.length - 1;
    if (idx >= 0 && idx < _items.length) {
      _focus(idx, null);
    } else {
      _domNode.focus();
    }
  }

  bool isDOMFocused() => dom.isAncestorOfActiveElement(_domNode);

  BreadcrumbsItem? getFocused() => _focusedItemIdx >= 0 &&
          _focusedItemIdx < _items.length
      ? _items[_focusedItemIdx]
      : null;

  void setFocused(BreadcrumbsItem? item, [Object? payload]) =>
      _focus(item == null ? -1 : _items.indexOf(item), payload);

  void focusPrev([Object? payload]) {
    if (_focusedItemIdx > 0) {
      _focus(_focusedItemIdx - 1, payload);
    }
  }

  void focusNext([Object? payload]) {
    if (_focusedItemIdx + 1 < _nodes.length) {
      _focus(_focusedItemIdx + 1, payload);
    }
  }

  void _focus(int nth, Object? payload) {
    _focusedItemIdx = -1;
    for (int i = 0; i < _nodes.length; i++) {
      final dom.DomElement node = _nodes[i];
      if (i != nth) {
        node.classList.remove('focused');
      } else {
        _focusedItemIdx = i;
        node.classList.add('focused');
        node.focus();
      }
    }
    _reveal(_focusedItemIdx, true);
    _onDidFocusItem.fire(IBreadcrumbsItemEvent(
      type: 'focus',
      item: _focusedItemIdx >= 0 && _focusedItemIdx < _items.length
          ? _items[_focusedItemIdx]
          : null,
      node: _focusedItemIdx >= 0 && _focusedItemIdx < _nodes.length
          ? _nodes[_focusedItemIdx]
          : null,
      payload: payload,
    ));
  }

  void reveal(BreadcrumbsItem item) {
    final int idx = _items.indexOf(item);
    if (idx >= 0) _reveal(idx, false);
  }

  void revealLast() => _reveal(_items.length - 1, false);

  void _reveal(int nth, bool minimal) {
    _pendingReveal.clear();
    if (nth < 0 || nth >= _nodes.length) return;
    final dom.DomElement node = _nodes[nth];
    if (!minimal) {
      _pendingReveal.value = _measure(dom.getWindow(_domNode), () {
        if (nth < _nodes.length && identical(_nodes[nth], node)) {
          _revealNode(node, false);
        }
      });
      return;
    }
    _revealNode(node, true);
  }

  void _revealNode(dom.DomElement node, bool minimal) {
    final scr.IScrollDimensions dimensions = _scrollable.getScrollDimensions();
    final scr.IScrollPosition position = _scrollable.getScrollPosition();
    final num nodeOffsetLeft = node.offsetLeft;
    if (!minimal ||
        nodeOffsetLeft > position.scrollLeft + dimensions.width ||
        nodeOffsetLeft < position.scrollLeft) {
      _scrollable.setRevealOnScroll(false);
      _scrollable.setScrollPosition(
          scr.NewScrollPosition(scrollLeft: nodeOffsetLeft));
      _scrollable.setRevealOnScroll(true);
    }
  }

  BreadcrumbsItem? getSelection() => _selectedItemIdx >= 0 &&
          _selectedItemIdx < _items.length
      ? _items[_selectedItemIdx]
      : null;

  void setSelection(BreadcrumbsItem? item, [Object? payload]) =>
      _select(item == null ? -1 : _items.indexOf(item), payload);

  void _select(int nth, Object? payload) {
    _selectedItemIdx = -1;
    for (int i = 0; i < _nodes.length; i++) {
      final dom.DomElement node = _nodes[i];
      if (i != nth) {
        node.classList.remove('selected');
      } else {
        _selectedItemIdx = i;
        node.classList.add('selected');
      }
    }
    _onDidSelectItem.fire(IBreadcrumbsItemEvent(
      type: 'select',
      item: _selectedItemIdx >= 0 && _selectedItemIdx < _items.length
          ? _items[_selectedItemIdx]
          : null,
      node: _selectedItemIdx >= 0 && _selectedItemIdx < _nodes.length
          ? _nodes[_selectedItemIdx]
          : null,
      payload: payload,
    ));
  }

  List<BreadcrumbsItem> getItems() => List<BreadcrumbsItem>.unmodifiable(_items);

  void setItems(List<BreadcrumbsItem> items) {
    int? prefix;
    List<BreadcrumbsItem> removed = <BreadcrumbsItem>[];
    try {
      prefix = arrays.commonPrefixLength<BreadcrumbsItem>(
          _items, items, (BreadcrumbsItem a, BreadcrumbsItem b) => a.equals(b));
      removed = _items.sublist(prefix);
      _items.removeRange(prefix, _items.length);
      _items.addAll(items.skip(prefix));
      _render(prefix);
      lc.dispose(removed);
      lc.dispose(items.sublist(0, prefix));
      _focus(-1, null);
    } catch (e) {
      throw BreadcrumbsSetItemsError(
        e,
        'BreadcrumbsItem#setItems: newItems: ${items.length}, prefix: $prefix, removed: ${removed.length}',
      );
    }
  }

  void _render(int start) {
    bool didChange = false;
    for (; start < _items.length && start < _nodes.length; start++) {
      _renderItem(_items[start], _nodes[start]);
      didChange = true;
    }
    while (start < _nodes.length) {
      final dom.DomElement free = _nodes.removeLast();
      _freeNodes.add(free);
      free.remove();
      didChange = true;
    }
    for (; start < _items.length; start++) {
      final dom.DomElement node = _freeNodes.isNotEmpty
          ? _freeNodes.removeLast()
          : dom.document.createElement('div');
      _renderItem(_items[start], node);
      _domNode.appendChild(node);
      _nodes.add(node);
      didChange = true;
    }
    if (didChange) layout(null);
  }

  void _renderItem(BreadcrumbsItem item, dom.DomElement container) {
    dom.clearNode(container);
    container.className = '';
    try {
      item.render(container);
    } catch (err) {
      container.textContent = '<<RENDER ERROR>>';
      breadcrumbsConsoleError(err);
    }
    container.tabIndex = -1;
    container.setAttribute('role', 'listitem');
    container.classList.add('monaco-breadcrumb-item');
    final dom.DomElement iconContainer =
        dom.$(themables.ThemeIcon.asCSSSelector(_separatorIcon));
    container.appendChild(iconContainer);
  }

  void _onClick(mouse.IMouseEvent event) {
    if (!_enabled) return;
    Object? el = event.target;
    while (el is dom.DomElement) {
      final int idx = _nodes.indexOf(el);
      if (idx >= 0) {
        _focus(idx, event);
        _select(idx, event);
        break;
      }
      el = el.parentElement;
    }
  }
}
