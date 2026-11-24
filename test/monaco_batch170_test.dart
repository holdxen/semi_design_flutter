// Truth-driven tests for base/browser/ui/breadcrumbs/breadcrumbsWidget.ts.
// Truth: tool/ts2dart/batch170_truth.json (real transpiled TypeScript module).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart'
    as mouse;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/breadcrumbs/breadcrumbsWidget.dart'
    as bw;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollableElementOptions.dart'
    show ScrollableElementChangeOptions, ScrollableElementCreationOptions;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as ev;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as lc;
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart'
    as scr;
import 'package:semi_design_flutter/src/monaco/base/common/themables.dart'
    as themables;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart'
    show CodeWindow;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch170_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _map(Object? v) => (v as Map).cast<String, dynamic>();
List<dynamic> _list(Object? v) => (v as List).cast<dynamic>();
List<String> _strings(Object? v) =>
    _list(v).map((Object? e) => e as String).toList();
List<int> _ints(Object? v) => _list(v).map((Object? e) => e as int).toList();
List<bool> _bools(Object? v) =>
    _list(v).map((Object? e) => e as bool).toList();

final bw.BreadcrumbsFrameScheduler _initialMeasure = dom.measure;
final bw.BreadcrumbsFrameScheduler _initialModify = dom.modify;
final dom.IFocusTracker Function(Object) _initialTrackFocus = dom.trackFocus;
final dom.DomElement Function(dom.DomElement) _initialStyleSheet =
    bw.breadcrumbsCreateStyleSheetFactory;
final bw.IBreadcrumbsScrollable Function(
        dom.DomElement, ScrollableElementCreationOptions) _initialScrollable =
    bw.breadcrumbsScrollableFactory;
final lc.IDisposable Function(
        dom.DomElement, String, void Function(Object))
    _initialClickListener = bw.breadcrumbsClickListenerFactory;
final void Function(Object) _initialConsoleError =
    bw.breadcrumbsConsoleError;

void _resetSeams() {
  bw.breadcrumbsMeasureFactory = _initialMeasure;
  bw.breadcrumbsModifyFactory = _initialModify;
  bw.breadcrumbsTrackFocusFactory = _initialTrackFocus;
  bw.breadcrumbsCreateStyleSheetFactory = _initialStyleSheet;
  bw.breadcrumbsScrollableFactory = _initialScrollable;
  bw.breadcrumbsClickListenerFactory = _initialClickListener;
  bw.breadcrumbsConsoleError = _initialConsoleError;
}

class FrameScheduler {
  FrameScheduler({this.invoke = false});

  final bool invoke;
  final List<String> ops = <String>[];

  lc.IDisposable call(CodeWindow _window, void Function() callback) {
    ops.add('schedule');
    if (invoke) callback();
    return lc.toDisposable(() => ops.add('cancel'));
  }
}

class FakeScrollable implements bw.IBreadcrumbsScrollable {
  FakeScrollable(this.options, this.domNode);

  final ScrollableElementCreationOptions options;
  final dom.DomElement domNode;
  final List<List<Object?>> calls = <List<Object?>>[];
  num width = 100;
  num scrollLeft = 0;
  bool disposed = false;

  @override
  dom.DomElement getDomNode() {
    calls.add(<Object?>['getDomNode']);
    return domNode;
  }

  @override
  void updateOptions(ScrollableElementChangeOptions newOptions) {
    final Map<String, Object?> seen = <String, Object?>{};
    if (newOptions.horizontalScrollbarSize != null) {
      seen['horizontalScrollbarSize'] = newOptions.horizontalScrollbarSize;
    }
    if (newOptions.horizontal != null) {
      seen['horizontal'] = newOptions.horizontal;
    }
    calls.add(<Object?>['updateOptions', seen]);
  }

  @override
  void setRevealOnScroll(bool value) =>
      calls.add(<Object?>['setRevealOnScroll', value]);

  @override
  void scanDomNode() => calls.add(<Object?>['scanDomNode']);

  @override
  scr.IScrollDimensions getScrollDimensions() =>
      scr.ScrollState(false, width, width, scrollLeft, 0, 0, 0);

  @override
  scr.IScrollPosition getScrollPosition() =>
      scr.ScrollState(false, width, width, scrollLeft, 0, 0, 0);

  @override
  void setScrollPosition(scr.NewScrollPosition update) {
    calls.add(<Object?>[
      'setScrollPosition',
      <String, Object?>{'scrollLeft': update.scrollLeft}
    ]);
    if (update.scrollLeft != null) scrollLeft = update.scrollLeft!;
  }

  @override
  void dispose() {
    disposed = true;
    calls.add(<Object?>['dispose']);
  }
}

class FakeFocusTracker implements dom.IFocusTracker {
  final ev.Emitter<void> focusEmitter = ev.Emitter<void>();
  final ev.Emitter<void> blurEmitter = ev.Emitter<void>();
  Object? element;
  bool disposed = false;

  @override
  ev.Event<void> get onDidFocus => focusEmitter.event;

  @override
  ev.Event<void> get onDidBlur => blurEmitter.event;

  @override
  void refreshState() {}

  @override
  void dispose() {
    disposed = true;
    focusEmitter.dispose();
    blurEmitter.dispose();
  }
}

class TagMouseEvent implements mouse.IMouseEvent {
  TagMouseEvent(this.tag, this.target);

  final String tag;

  @override
  Object? target;

  @override
  mouse.MouseEvent get browserEvent => mouse.MouseEvent();

  @override
  bool leftButton = true;
  @override
  bool middleButton = false;
  @override
  bool rightButton = false;
  @override
  int buttons = 1;
  @override
  int detail = 0;
  @override
  num posx = 0;
  @override
  num posy = 0;
  @override
  bool ctrlKey = false;
  @override
  bool shiftKey = false;
  @override
  bool altKey = false;
  @override
  bool metaKey = false;
  @override
  int timestamp = 0;
  @override
  bool defaultPrevented = false;

  @override
  void preventDefault() {}
  @override
  void stopPropagation() {}

  @override
  String toString() => tag;
}

class TestRenderError implements Exception {
  TestRenderError(this.label);
  final String label;
  @override
  String toString() => 'Error: boom-$label';
}

class TestItem extends bw.BreadcrumbsItem implements lc.IDisposable {
  TestItem(this.label, [this.renderError = false]);

  final String label;
  final bool renderError;
  bool disposed = false;
  int renderCalls = 0;

  @override
  void dispose() => disposed = true;

  @override
  bool equals(bw.BreadcrumbsItem other) =>
      other is TestItem && other.label == label;

  @override
  void render(dom.DomElement container) {
    renderCalls++;
    if (renderError) throw TestRenderError(label);
    container.textContent = label;
  }
}

class Harness {
  Harness({
    bw.BreadcrumbsFrameScheduler? injectedMeasure,
    bool invokeFrames = false,
    bw.IBreadcrumbsWidgetStyles? styles,
  }) {
    container = dom.document.createElement('div');
    scrollDom = dom.document.createElement('div');
    globalMeasure = FrameScheduler(invoke: invokeFrames);
    globalModify = FrameScheduler(invoke: invokeFrames);
    tracker = FakeFocusTracker();

    bw.breadcrumbsMeasureFactory = globalMeasure.call;
    bw.breadcrumbsModifyFactory = globalModify.call;
    bw.breadcrumbsTrackFocusFactory = (Object element) {
      tracker.element = element;
      return tracker;
    };
    bw.breadcrumbsCreateStyleSheetFactory = (dom.DomElement c) {
      final dom.DomElement style = dom.document.createElement('style');
      c.appendChild(style);
      styleSheets.add(style);
      return style;
    };
    bw.breadcrumbsScrollableFactory = (element, options) {
      scrollable = FakeScrollable(options, scrollDom);
      return scrollable;
    };
    bw.breadcrumbsClickListenerFactory =
        (dom.DomElement node, String type, void Function(Object e) handler) {
      listenerTypes.add(type);
      clickHandler = handler;
      return lc.toDisposable(() => clickHandler = null);
    };

    widget = bw.BreadcrumbsWidget(
      container,
      3,
      scr.ScrollbarVisibility.Auto,
      themables.ThemeIcon('chevron-right'),
      styles ?? bw.IBreadcrumbsWidgetStyles(),
      injectedMeasure ?? globalMeasure.call,
    );
  }

  late final dom.DomElement container;
  late final dom.DomElement scrollDom;
  late final FrameScheduler globalMeasure;
  late final FrameScheduler globalModify;
  late final FakeFocusTracker tracker;
  late final FakeScrollable scrollable;
  late final bw.BreadcrumbsWidget widget;
  final List<dom.DomElement> styleSheets = <dom.DomElement>[];
  final List<String> listenerTypes = <String>[];
  void Function(Object)? clickHandler;
}

Map<String, dynamic> _serialEvent(Object? e) {
  if (e is bw.IBreadcrumbsItemEvent) {
    return <String, dynamic>{
      'type': e.type,
      'payload': e.payload?.toString(),
    };
  }
  final Map<String, dynamic> m = _map(e);
  final Object? payload = m['payload'];
  return <String, dynamic>{
    'type': m['type'],
    'payload': payload?.toString(),
  };
}

Map<String, dynamic> _optionMap(ScrollableElementCreationOptions o) =>
    <String, dynamic>{
      'vertical': o.vertical,
      'horizontal': o.horizontal,
      'horizontalScrollbarSize': o.horizontalScrollbarSize,
      'useShadows': o.useShadows,
      'scrollYToX': o.scrollYToX,
    };

List<String> _classes(dom.DomElement e) => e.classList.toList();

void main() {
  tearDown(_resetSeams);

  group('breadcrumbsWidget', () {
    test('exports match truth', () {
      expect(
        <String>['BreadcrumbsItem', 'BreadcrumbsWidget'],
        _strings(T['exports']),
      );
    });

    test('constructor, styles, setEnabled and options match truth', () {
      final Map<String, dynamic> t = _map(T['constructor']);
      final Harness h = Harness();
      expect(h.widget.debugDomNode.className, t['domClass']);
      expect(_classes(h.widget.debugDomNode), _strings(t['domClasses']));
      expect(h.widget.debugDomNode.tabIndex, t['tabIndex']);
      expect(h.widget.debugDomNode.getAttribute('role'), t['role']);
      expect(
          h.container.childNodes.map((dom.DomNode n) => n is dom.DomElement),
          <bool>[true]);
      expect(identical(h.container.childNodes.single, h.scrollDom), isTrue);
      expect(_optionMap(h.scrollable.options), _map(t['scrollOptions']));
      expect(h.listenerTypes, _strings(_list(t['listenerLog']).map(
          (Object? e) => (_map(e)['type'] as String).toLowerCase()).toList()));
      expect(identical(h.tracker.element, h.widget.debugDomNode), isTrue);
      expect(h.styleSheets.length, 1);
      expect(h.styleSheets.first.textContent, t['styleElements'][0]['text']);
      expect(identical(h.styleSheets.first.parentNode, h.widget.debugDomNode),
          isTrue);
      expect(h.widget.getItems(), isEmpty);
      expect(h.widget.getFocused(), isNull);
      expect(h.widget.getSelection(), isNull);

      final List<bool> changeFocus = <bool>[];
      h.widget.onDidChangeFocus((dynamic v) => changeFocus.add(v as bool));
      h.tracker.focusEmitter.fire(null);
      h.tracker.blurEmitter.fire(null);
      expect(changeFocus, _bools(t['changeFocus']));

      h.widget.setHorizontalScrollbarSize(7);
      h.widget.setHorizontalScrollbarVisibility(3);
      expect(h.scrollable.calls.where((List<Object?> c) => c.first == 'updateOptions').toList(),
          _list(t['updateOptions']).map((Object? e) => _list(e)).toList());

      h.widget.setEnabled(false);
      expect(_classes(h.widget.debugDomNode), _strings(t['disabledClasses']));
      h.widget.setEnabled(true);
      expect(_classes(h.widget.debugDomNode), _strings(t['reenabledClasses']));
    });

    test('style content matches truth', () {
      final Map<String, dynamic> t = _map(T['style']);
      final Harness h = Harness(
        styles: bw.IBreadcrumbsWidgetStyles(
          breadcrumbsBackground: '#fff',
          breadcrumbsForeground: '#111',
          breadcrumbsFocusForeground: '#222',
          breadcrumbsFocusAndSelectionForeground: '#333',
          breadcrumbsHoverForeground: '#444',
        ),
      );
      expect(h.styleSheets.single.textContent, t['text']);
    });

    test('setItems rendering and node reuse match truth', () {
      final Map<String, dynamic> t = _map(T['setItems']);
      final Harness h = Harness();
      final List<Object?> focusEvents = <Object?>[];
      final List<Object?> selectEvents = <Object?>[];
      h.widget.onDidFocusItem((dynamic e) => focusEvents.add(e));
      h.widget.onDidSelectItem((dynamic e) => selectEvents.add(e));

      final TestItem a = TestItem('a'), b = TestItem('b'), c = TestItem('c');
      h.widget.setItems(<bw.BreadcrumbsItem>[a, b, c]);
      expect(h.widget.getItems().map((bw.BreadcrumbsItem i) => (i as TestItem).label).toList(),
          _strings(t['items']));
      for (int i = 0; i < h.widget.debugNodes.length; i++) {
        final Map<String, dynamic> expected = _map(_list(t['nodes'])[i]);
        final dom.DomElement node = h.widget.debugNodes[i];
        expect(_classes(node), _strings(expected['classes']));
        expect(node.textContent, expected['text']);
        expect(node.getAttribute('role'), _map(expected['attrs'])['role']);
        expect(identical(node.parentNode, h.widget.debugDomNode), isTrue);
      }
      final Map<String, dynamic> sep = _map(t['separator']);
      expect(
          _classes(h.widget.debugNodes.first.childNodes
              .whereType<dom.DomElement>()
              .first),
          _strings(sep['classes']));
      expect(<int>[a.renderCalls, b.renderCalls, c.renderCalls],
          _ints(t['renderCalls']));
      expect(focusEvents.map(_serialEvent).toList(),
          _list(t['focusEvents']).map(_serialEvent).toList());
      expect(selectEvents, isEmpty);
      expect(h.globalMeasure.ops, _strings(t['layoutMeasureCalls']));

      final List<dom.DomElement> before = List<dom.DomElement>.from(h.widget.debugNodes);
      final TestItem a2 = TestItem('a'), b2 = TestItem('b'), x = TestItem('x');
      final Map<String, dynamic> reuse = _map(T['prefixReuse']);
      h.widget.setItems(<bw.BreadcrumbsItem>[a2, b2, x]);
      expect(identical(h.widget.debugNodes[0], before[0]), reuse['sameFirstNode']);
      expect(identical(h.widget.debugNodes[1], before[1]), reuse['sameSecondNode']);
      expect(identical(h.widget.debugNodes[2], before[2]),
          !(reuse['thirdIsNew'] as bool));
      expect(<int>[a2.renderCalls, b2.renderCalls, x.renderCalls],
          _ints(reuse['renderCalls']));
      expect(<bool>[a.disposed, b.disposed, c.disposed],
          _bools(reuse['oldRemovedDisposed']));
      expect(<bool>[a2.disposed, b2.disposed, x.disposed],
          _bools(reuse['newPrefixDisposed']));
      expect(h.widget.debugNodes.length, reuse['nodesCount']);
      expect(h.widget.debugFreeNodes.length, reuse['freeNodesCount']);
    });

    test('focus navigation and selection match truth', () {
      final Map<String, dynamic> t = _map(T['focusNav']);
      final Harness h = Harness();
      final TestItem a = TestItem('a'), b = TestItem('b'), c = TestItem('c');
      h.widget.setItems(<bw.BreadcrumbsItem>[a, b, c]);
      for (int i = 0; i < h.widget.debugNodes.length; i++) {
        h.widget.debugNodes[i].offsetLeft = i * 50;
      }
      final List<Object?> focusEvents = <Object?>[];
      final List<Object?> selectEvents = <Object?>[];
      h.widget.onDidFocusItem((dynamic e) => focusEvents.add(e));
      h.widget.onDidSelectItem((dynamic e) => selectEvents.add(e));

      h.widget.setFocused(b, 'focus-b');
      expect((h.widget.getFocused() as TestItem).label, t['afterSetFocused']);
      expect(h.widget.debugNodes.map(_classes).toList(),
          _list(t['classes']).map((Object? e) => _strings(e)).toList());
      expect(identical(dom.document.activeElement, h.widget.debugNodes[1]), isTrue);
      expect(focusEvents.map(_serialEvent).toList(),
          _list(t['events']).map(_serialEvent).toList());

      h.widget.focusPrev('prev');
      h.widget.focusNext('next');
      h.widget.setFocused(null, 'clear');
      h.widget.domFocus();
      expect((h.widget.getFocused() as TestItem).label, t['afterDomFocus']);
      expect(h.widget.debugNodes.map(_classes).toList(),
          _list(t['afterClasses']).map((Object? e) => _strings(e)).toList());
      expect(focusEvents.map(_serialEvent).toList(),
          _list(t['afterEvents']).map(_serialEvent).toList());

      h.widget.setSelection(c, 'sel-c');
      expect((h.widget.getSelection() as TestItem).label, t['selection']);
      expect(selectEvents.map(_serialEvent).toList(),
          _list(t['selectEvents']).map(_serialEvent).toList());

      h.widget.reveal(a);
      h.widget.revealLast();
      expect(h.scrollable.calls, _list(t['afterRevealCalls']).map((Object? e) => _list(e)).toList());
    });

    test('deferred reveals are cancelled on focus (official test)', () {
      final Map<String, dynamic> t = _map(T['officialReveal']);
      final FrameScheduler injected = FrameScheduler();
      final Harness h = Harness(injectedMeasure: injected.call);
      final TestItem first = TestItem('first'), last = TestItem('last');
      h.widget.setItems(<bw.BreadcrumbsItem>[first, last]);
      h.widget.revealLast();
      h.widget.reveal(first);
      h.widget.domFocus();
      expect(injected.ops, _strings(t['operations']));
    });

    test('layout and scrollbar scan match truth', () {
      final Map<String, dynamic> t = _map(T['layout']);
      final Harness h = Harness(invokeFrames: true);
      h.widget.layout(dom.Dimension(10, 20));
      final Map<String, dynamic> first = _map(t['afterFirst']);
      expect(h.widget.debugDomNode.style['width'],
          _map(first['styles'])['width']);
      expect(h.widget.debugDomNode.style['height'],
          _map(first['styles'])['height']);
      expect(h.globalModify.ops, _strings(first['modify']));
      expect(h.globalMeasure.ops, _strings(first['measure']));
      expect(h.scrollable.calls,
          _list(first['scrollable']).map((Object? e) => _list(e)).toList());

      final int measureCount = h.globalMeasure.ops.length;
      final int modifyCount = h.globalModify.ops.length;
      final int scrollableCount = h.scrollable.calls.length;
      h.widget.layout(dom.Dimension(10, 20));
      expect(h.globalMeasure.ops.length, measureCount);
      expect(h.globalModify.ops.length, modifyCount);
      expect(h.scrollable.calls.length, scrollableCount);

      h.widget.layout(null);
      final Map<String, dynamic> undef = _map(t['afterUndefined']);
      expect(h.globalModify.ops, _strings(undef['modify']));
      expect(h.globalMeasure.ops, _strings(undef['measure']));
      expect(h.scrollable.calls,
          _list(undef['scrollable']).map((Object? e) => _list(e)).toList());
      expect(h.widget.debugDimension!.width, _map(t['dimension'])['width']);
      expect(h.widget.debugDimension!.height, _map(t['dimension'])['height']);
    });

    test('click routing honors enabled state', () {
      final Map<String, dynamic> t = _map(T['click']);
      final Harness h = Harness();
      h.widget.setItems(<bw.BreadcrumbsItem>[TestItem('a'), TestItem('b')]);
      final List<Object?> focusEvents = <Object?>[];
      final List<Object?> selectEvents = <Object?>[];
      h.widget.onDidFocusItem((dynamic e) => focusEvents.add(e));
      h.widget.onDidSelectItem((dynamic e) => selectEvents.add(e));

      final dom.DomElement target = h.widget.debugNodes[1].childNodes
          .whereType<dom.DomElement>()
          .first;
      h.clickHandler!(TagMouseEvent('clickEvent', target));
      final Map<String, dynamic> enabled = _map(t['enabled']);
      expect(focusEvents.map(_serialEvent).toList(),
          _list(enabled['focus']).map(_serialEvent).toList());
      expect(selectEvents.map(_serialEvent).toList(),
          _list(enabled['select']).map(_serialEvent).toList());

      h.widget.setEnabled(false);
      h.clickHandler!(TagMouseEvent('clickDisabled', h.widget.debugNodes[0]));
      final Map<String, dynamic> disabled = _map(t['disabled']);
      expect(focusEvents.map(_serialEvent).toList(),
          _list(disabled['focus']).map(_serialEvent).toList());
      expect(selectEvents.map(_serialEvent).toList(),
          _list(disabled['select']).map(_serialEvent).toList());
    });

    test('render errors are contained', () {
      final Map<String, dynamic> t = _map(T['renderError']);
      final Harness h = Harness();
      final List<Object> errors = <Object>[];
      bw.breadcrumbsConsoleError = errors.add;
      h.widget.setItems(<bw.BreadcrumbsItem>[TestItem('bad', true)]);
      expect(h.widget.debugNodes.single.textContent, t['text']);
      expect(_classes(h.widget.debugNodes.single), _strings(t['classes']));
      expect(errors.map((Object e) => e.toString()).toList(),
          _strings(t['errors']));
    });

    test('dispose releases items, nodes and trackers', () {
      final Map<String, dynamic> t = _map(T['dispose']);
      final Harness h = Harness();
      final TestItem a = TestItem('a'), b = TestItem('b');
      h.widget.setItems(<bw.BreadcrumbsItem>[a, b]);
      h.widget.dispose();
      expect(<bool>[a.disposed, b.disposed], _bools(t['itemsDisposed']));
      expect(h.widget.getItems().length, t['itemsLength']);
      expect(h.widget.debugNodes.length, t['nodesLength']);
      expect(h.widget.debugFreeNodes.length, t['freeNodesLength']);
      expect(h.widget.debugDomNode.parentNode, isNull);
      expect(h.scrollable.disposed, t['scrollableDisposed']);
      expect(h.tracker.disposed, t['focusTrackerDisposed']);
    });
  });
}
