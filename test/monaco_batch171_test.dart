// Truth-driven tests for batch171: base/browser/ui/splitview/splitview.ts.
// Truth source: tool/ts2dart/batch171_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/sash/sash.dart' as sash;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollableElementOptions.dart' as opts;
import 'package:semi_design_flutter/src/monaco/base/common/color.dart' as color;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/splitview/splitview.dart' as sp;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart' as scr;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch171_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> t(String key) => truth[key] as Map<String, dynamic>;
List<dynamic> l(String key) => truth[key] as List<dynamic>;

List<num> nums(Object? value) =>
    (value as List<dynamic>).map((Object? e) => e as num).toList();
List<num?> numsOrNull(Object? value) => (value as List<dynamic>)
    .map((Object? e) => e == null ? null : e as num)
    .toList();

class ZeroScrollPosition implements scr.IScrollPosition {
  @override
  num get scrollLeft => 0;
  @override
  num get scrollTop => 0;
}
List<int> ints(Object? value) =>
    (value as List<dynamic>).map((Object? e) => (e as num).round()).toList();
List<String> strs(Object? value) =>
    (value as List<dynamic>).map((Object? e) => e as String).toList();

List<String> classes(dom.DomElement el) => el.className
    .split(RegExp(r'\s+'))
    .where((String s) => s.isNotEmpty)
    .toList();

List<dom.DomElement> children(dom.DomElement el) =>
    el.childNodes.whereType<dom.DomElement>().toList();

class FakeSash implements sp.ISplitViewSash, lifecycle.IDisposable {
  FakeSash(dom.DomElement container, this.options) {
    el = dom.document.createElement('div')..className = 'monaco-sash';
    container.appendChild(el);
    _start = event.Emitter<sash.SashEvent>();
    _change = event.Emitter<sash.SashEvent>();
    _end = event.Emitter<void>();
    _reset = event.Emitter<void>();
  }

  final sp.SplitViewSashOptions options;
  late final dom.DomElement el;
  late final event.Emitter<sash.SashEvent> _start;
  late final event.Emitter<sash.SashEvent> _change;
  late final event.Emitter<void> _end;
  late final event.Emitter<void> _reset;

  @override
  int state = -1;
  @override
  sp.ISplitViewSash? orthogonalStartSash;
  @override
  sp.ISplitViewSash? orthogonalEndSash;
  int layoutCalls = 0;
  bool disposed = false;

  @override
  event.Event<sash.SashEvent> get onDidStart => _start.event;
  @override
  event.Event<sash.SashEvent> get onDidChange => _change.event;
  @override
  event.Event<void> get onDidEnd => _end.event;
  @override
  event.Event<void> get onDidReset => _reset.event;
  @override
  void layout() => layoutCalls++;
  @override
  void dispose() {
    disposed = true;
    el.remove();
  }

  void fireStart(num x, num y, bool alt) => _start.fire(sash.SashEvent(
      startX: x, currentX: x, startY: y, currentY: y, altKey: alt));
  void fireChange(num x, num y, bool alt) => _change.fire(sash.SashEvent(
      startX: x, currentX: x, startY: y, currentY: y, altKey: alt));
  void fireEnd() => _end.fire(null);
  void fireReset() => _reset.fire(null);
}

class FakeScrollable implements sp.ISplitViewScrollable {
  FakeScrollable(this.element) {
    wrapper = dom.document.createElement('div')..className = 'monaco-scrollable-element';
    wrapper.appendChild(element);
  }

  final dom.DomElement element;
  late final dom.DomElement wrapper;
  final List<Map<String, Object?>> dimensions = <Map<String, Object?>>[];
  final List<scr.NewScrollPosition> positions = <scr.NewScrollPosition>[];
  final event.Emitter<scr.ScrollEvent> _onScroll = event.Emitter<scr.ScrollEvent>();
  bool disposed = false;

  @override
  dom.DomElement getDomNode() => wrapper;
  @override
  scr.IScrollPosition getScrollPosition() => ZeroScrollPosition();
  @override
  void setScrollPosition(scr.NewScrollPosition update) => positions.add(update);
  @override
  void setScrollDimensions(scr.NewScrollDimensions dims) => dimensions.add(<String, Object?>{
        'height': dims.height,
        'scrollHeight': dims.scrollHeight,
        'width': dims.width,
        'scrollWidth': dims.scrollWidth,
      });
  @override
  event.Event<scr.ScrollEvent> get onScroll => _onScroll.event;
  @override
  void dispose() => disposed = true;
}

class TestView implements sp.IView<int> {
  TestView(this.minimumSize, this.maximumSize,
      [this.priority = sp.LayoutPriority.Normal, this.pathIndependent = false]);

  @override
  num minimumSize;
  @override
  num maximumSize;
  @override
  int priority;
  @override
  bool pathIndependent;
  @override
  bool? get pathIndependentLayout => pathIndependent;
  @override
  bool? get snap => null;
  @override
  bool? proportionalLayout;

  final event.Emitter<num?> _onDidChange = event.Emitter<num?>();
  @override
  event.Event<num?> get onDidChange => _onDidChange.event;

  final event.Emitter<void> _onDidGetElement = event.Emitter<void>();
  event.Event<void> get onDidGetElement => _onDidGetElement.event;

  final dom.DomElement _element = dom.document.createElement('div');
  @override
  dom.DomElement get element {
    _onDidGetElement.fire(null);
    return _element;
  }

  num size = 0;
  int? context;
  final List<num> layouts = <num>[];
  final List<bool> visibleEvents = <bool>[];

  @override
  void layout(num viewSize, num offset, int? inContext) {
    size = viewSize;
    context = inContext;
    layouts.add(viewSize);
  }

  void Function(bool)? setVisibleImpl;

  @override
  void setVisible(bool visible) {
    visibleEvents.add(visible);
    if (setVisibleImpl != null) setVisibleImpl!(visible);
  }

  void change() => _onDidChange.fire(null);
}

late final sp.SplitViewSashFactory _originalSashFactory = sp.splitViewSashFactory;
late final sp.SplitViewScrollableFactory _originalScrollableFactory =
    sp.splitViewScrollableFactory;

final List<FakeSash> fakeSashes = <FakeSash>[];
final List<FakeScrollable> fakeScrollables = <FakeScrollable>[];

dom.DomElement newContainer() {
  final dom.DomElement c = dom.document.createElement('div');
  c.style.setProperty('position', 'absolute');
  return c;
}

sp.SplitView<int, TestView> newSplitView(
    [sp.SplitViewOptions<int, TestView>? options]) {
  return sp.SplitView<int, TestView>(newContainer(), options);
}

TestView view(num min, num max,
        [int priority = sp.LayoutPriority.Normal, bool pathIndependent = false]) =>
    TestView(min, max, priority, pathIndependent);

List<num> sizes(List<TestView> views) =>
    views.map((TestView v) => v.size).toList();
List<List<num>> drainLayouts(List<TestView> views) {
  final List<List<num>> out = views
      .map((TestView v) => v.layouts.toList(growable: false))
      .toList(growable: false);
  for (final TestView v in views) {
    v.layouts.clear();
  }
  return out;
}

List<int> sashStates(sp.SplitView<int, TestView> sv) =>
    fakeSashes.map((FakeSash s) => s.state).toList();

void main() {
  setUp(() {
    fakeSashes.clear();
    fakeScrollables.clear();
    sp.splitViewSashFactory = (dom.DomElement container, Object provider,
        sp.SplitViewSashOptions options) {
      final FakeSash s = FakeSash(container, options);
      fakeSashes.add(s);
      return s;
    };
    sp.splitViewScrollableFactory = (dom.DomElement element,
        opts.ScrollableElementCreationOptions options, scr.Scrollable scrollable) {
      final FakeScrollable s = FakeScrollable(element);
      fakeScrollables.add(s);
      return s;
    };
  });

  tearDown(() {
    sp.splitViewSashFactory = _originalSashFactory;
    sp.splitViewScrollableFactory = _originalScrollableFactory;
  });

  test('exports and enums', () {
    expect(strs(truth['exports']), containsAll(<String>[
      'LayoutPriority',
      'Orientation',
      'Sizing',
      'SplitView',
    ]));
    final Map<String, dynamic> enums = t('enums');
    expect(sp.LayoutPriority.Normal, enums['LayoutPriority']['Normal']);
    expect(sp.LayoutPriority.Low, enums['LayoutPriority']['Low']);
    expect(sp.LayoutPriority.High, enums['LayoutPriority']['High']);
    expect(sash.Orientation.VERTICAL, enums['Orientation']['VERTICAL']);
    expect(sash.Orientation.HORIZONTAL, enums['Orientation']['HORIZONTAL']);
    expect(sash.SashState.Disabled, enums['SashState']['Disabled']);
    expect(sash.SashState.AtMinimum, enums['SashState']['AtMinimum']);
    expect(sash.SashState.AtMaximum, enums['SashState']['AtMaximum']);
    expect(sash.SashState.Enabled, enums['SashState']['Enabled']);
    expect(sp.Sizing.Distribute.type,
        (enums['Distribute'] as Map<String, dynamic>)['type']);
    expect(sp.Sizing.Split(2).index, (enums['Split'] as Map<String, dynamic>)['index']);
    expect(sp.Sizing.Auto(1).index, (enums['Auto'] as Map<String, dynamic>)['index']);
    expect(sp.Sizing.Invisible(33).cachedVisibleSize,
        (enums['Invisible'] as Map<String, dynamic>)['cachedVisibleSize']);
  });

  test('empty splitview has empty DOM', () {
    final Map<String, dynamic> e = t('emptyDom');
    final dom.DomElement c = newContainer();
    final sp.SplitView<int, TestView> sv = sp.SplitView<int, TestView>(c);
    expect(c.childNodes.length, e['containerChildren']);
    final dom.DomElement el = c.childNodes.single as dom.DomElement;
    expect(classes(el), strs(e['elClasses']));
    final List<dom.DomElement> els = children(el);
    expect(els.length, (e['elChildren'] as List<dynamic>).length);
    for (int i = 0; i < els.length; i++) {
      expect(classes(els[i]), strs((e['elChildren'] as List<dynamic>)[i]));
    }
    expect(
        children(els.firstWhere((dom.DomElement d) =>
                classes(d).contains('sash-container'))).length,
        e['sashContainerChildren']);
    final Map<String, dynamic> opts = (e['scrollableOptions'] as Map<String, dynamic>);
    final dynamic recorded = fakeScrollables.single;
    expect(recorded, isNotNull);
    expect(opts['vertical'], scr.ScrollbarVisibility.Auto);
    expect(opts['horizontal'], scr.ScrollbarVisibility.Hidden);
    expect(sv.length, e['length']);
    expect(sv.minimumSize, e['min']);
    expect(sv.maximumSize, double.infinity);
    expect(sv.contentSize, e['contentSize']);
    sv.dispose();
  });

  test('constructor options, style and descriptor', () {
    final Map<String, dynamic> e = t('constructor');
    final TestView v1 = view(10, 100), v2 = view(20, 200);
    final sp.SplitView<int, TestView> sv = newSplitView(sp.SplitViewOptions<int, TestView>(
      orientation: sash.Orientation.HORIZONTAL,
      styles: sp.SplitViewStyles(separatorBorder: color.Color.red),
      scrollbarVisibility: scr.ScrollbarVisibility.Hidden,
      getSashOrthogonalSize: () => 7,
      descriptor: sp.SplitViewDescriptor<int, TestView>(
        size: 100,
        views: <sp.SplitViewDescriptorView<int, TestView>>[
          sp.SplitViewDescriptorView<int, TestView>(size: 40, view: v1),
          sp.SplitViewDescriptorView<int, TestView>(
              size: 60, visible: false, view: v2),
        ],
      ),
    ));
    expect(classes(sv.el), strs(e['classes']));
    expect(sv.el.style.getPropertyValue('--separator-border'),
        (e['style'] as Map<String, dynamic>)['props']['--separator-border']);
    expect(fakeSashes.single.options.orientation,
        ((e['sashes'] as List<dynamic>).single as Map<String, dynamic>)['orientation']);
    expect(sv.length, e['length']);
    expect(sizes(<TestView>[v1, v2]), nums(e['sizes']));
    expect(<bool>[sv.isViewVisible(0), sv.isViewVisible(1)],
        (e['visible'] as List<dynamic>).cast<bool>());
    expect(<num?>[sv.getViewCachedVisibleSize(0), sv.getViewCachedVisibleSize(1)],
        numsOrNull(e['cached']));
    expect(sv.contentSize, e['contentSize']);
    expect(sv.minimumSize, e['min']);
    expect(sv.maximumSize, e['max']);
    sv.layout(200);
    final Map<String, dynamic> after = e['afterLayout'] as Map<String, dynamic>;
    expect(sizes(<TestView>[v1, v2]), nums(after['sizes']));
    expect(drainLayouts(<TestView>[v1, v2]),
        (after['layouts'] as List<dynamic>).map(nums).toList());
    expect(sv.contentSize, after['contentSize']);
    expect(sashStates(sv), ints(after['sashStates']));
    final sp.SplitView<int, TestView> sv2 = newSplitView(
        sp.SplitViewOptions<int, TestView>(
            styles: sp.SplitViewStyles(
                separatorBorder: color.Color.transparentColor)));
    expect(classes(sv2.el), strs((e['transparentStyle'] as Map<String, dynamic>)['classes']));
    expect(sv2.el.style.getPropertyValue('--separator-border'), '');
    sv.dispose();
    sv2.dispose();
  });

  test('views and sashes are added/removed', () {
    final Map<String, dynamic> e = t('addRemove');
    final dom.DomElement c = newContainer();
    final List<TestView> views = <TestView>[view(20, 20), view(20, 20), view(20, 20)];
    final sp.SplitView<int, TestView> sv = sp.SplitView<int, TestView>(c);
    for (final TestView v in views) {
      sv.addView(v, 20);
    }
    final dom.DomElement scrollable = children(sv.el)
        .firstWhere((dom.DomElement d) => classes(d).contains('monaco-scrollable-element'));
    final dom.DomElement viewContainer = children(scrollable)
        .firstWhere((dom.DomElement d) => classes(d).contains('split-view-container'));
    final dom.DomElement sashContainer = children(sv.el)
        .firstWhere((dom.DomElement d) => classes(d).contains('sash-container'));
    Map<String, dynamic> count() => <String, dynamic>{
          'views': children(viewContainer)
              .where((dom.DomElement d) => classes(d).contains('split-view-view'))
              .length,
          'sashes': children(sashContainer).length,
        };
    expect(count(), e['initial']);
    sv.removeView(2);
    expect(count(), e['afterRemove2']);
    sv.removeView(0);
    expect(count(), e['afterRemove0']);
    sv.removeView(0);
    expect(count(), e['afterRemoveLast']);
    expect(sizes(views), nums(e['finalSizes']));
    sv.dispose();
  });

  test('stretches view to viewport', () {
    final List<dynamic> e = l('stretch');
    final TestView v = view(20, double.infinity);
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(200);
    sv.addView(v, 20);
    final List<num> seq = <num>[v.size];
    for (final num s in <num>[200, 100, 20, 10, 200]) {
      sv.layout(s);
      seq.add(v.size);
    }
    expect(seq, nums(e));
    sv.dispose();
  });

  test('can resize views', () {
    final List<TestView> views = <TestView>[
      view(20, double.infinity), view(20, double.infinity), view(20, double.infinity)
    ];
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(200);
    for (final TestView v in views) {
      sv.addView(v, 20);
    }
    final List<List<num>> steps = <List<num>>[sizes(views)];
    sv.resizeView(1, 40);
    steps.add(sizes(views));
    sv.resizeView(0, 70);
    steps.add(sizes(views));
    sv.resizeView(2, 40);
    steps.add(sizes(views));
    final List<dynamic> e = l('resizeViews');
    for (int i = 0; i < e.length; i++) {
      expect(steps[i], nums(e[i]));
    }
    sv.dispose();
  });

  test('reacts to view changes', () {
    final List<TestView> views = <TestView>[
      view(20, double.infinity), view(20, double.infinity), view(20, double.infinity)
    ];
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(200);
    for (final TestView v in views) {
      sv.addView(v, 20);
    }
    final List<List<num>> steps = <List<num>>[sizes(views)];
    views[0].maximumSize = 20;
    views[0].change();
    steps.add(sizes(views));
    views[2].maximumSize = 40;
    views[2].change();
    steps.add(sizes(views));
    views[1].maximumSize = 200;
    views[1].change();
    steps.add(sizes(views));
    views[2].maximumSize = double.infinity;
    views[2].minimumSize = 100;
    views[2].change();
    steps.add(sizes(views));
    final List<dynamic> e = l('reactsToViewChanges');
    for (int i = 0; i < e.length; i++) {
      expect(steps[i], nums(e[i]));
    }
    sv.dispose();
  });

  test('sashes are properly enabled/disabled', () {
    final List<TestView> views = <TestView>[
      view(20, double.infinity), view(20, double.infinity), view(20, double.infinity)
    ];
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(200);
    for (final TestView v in views) {
      sv.addView(v, sp.Sizing.Distribute);
    }
    final List<List<int>> steps = <List<int>>[sashStates(sv)];
    for (final num s in <num>[60, 20, 200]) {
      sv.layout(s);
      steps.add(sashStates(sv));
    }
    views[0].maximumSize = 20;
    views[0].change();
    steps.add(sashStates(sv));
    views[1].maximumSize = 20;
    views[1].change();
    steps.add(sashStates(sv));
    views[0].maximumSize = 300;
    views[0].change();
    steps.add(sashStates(sv));
    views[1].maximumSize = 200;
    views[1].change();
    steps.add(sashStates(sv));
    sv.resizeView(0, 40);
    steps.add(sashStates(sv));
    final List<dynamic> e = l('sashEnablement');
    for (int i = 0; i < e.length; i++) {
      expect(steps[i], ints(e[i]));
    }
    sv.dispose();
  });

  test('issue #35497', () {
    final Map<String, dynamic> e = t('issue35497');
    final TestView v1 = view(160, double.infinity), v2 = view(66, 66);
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(986);
    sv.addView(v1, 142, 0);
    int threw = 0;
    v2.onDidGetElement((dynamic v) {
      for (int i = 0; i < 2; i++) {
        try {
          sv.resizeView(1, 922);
        } catch (_) {
          threw++;
        }
      }
    });
    sv.addView(v2, 66, 0);
    final dom.DomElement scrollable = children(sv.el)
        .firstWhere((dom.DomElement d) => classes(d).contains('monaco-scrollable-element'));
    final dom.DomElement viewContainer = children(scrollable)
        .firstWhere((dom.DomElement d) => classes(d).contains('split-view-container'));
    expect(threw, e['threw']);
    expect(sizes(<TestView>[v1, v2]), nums(e['sizes']));
    expect(children(viewContainer)
        .map((dom.DomElement d) => d.style.getPropertyValue('height'))
        .toList(), e['heights']);
    sv.dispose();
  });

  test('automatic size distribution', () {
    final List<TestView> views = <TestView>[
      view(20, double.infinity), view(20, double.infinity), view(20, double.infinity)
    ];
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(200);
    sv.addView(views[0], sp.Sizing.Distribute);
    final List<List<num>> steps = <List<num>>[sizes(views)];
    sv.addView(views[1], 50);
    steps.add(sizes(views));
    sv.addView(views[2], sp.Sizing.Distribute);
    steps.add(sizes(views));
    sv.removeView(1, sp.Sizing.Distribute);
    steps.add(<num>[views[0].size, views[2].size]);
    final List<dynamic> e = l('automaticDistribution');
    for (int i = 0; i < e.length; i++) {
      expect(steps[i], nums(e[i]));
    }
    sv.dispose();
  });

  test('path independent layout skips intermediate layouts', () {
    final Map<String, dynamic> e = t('pathIndependent');
    for (final int orientation in <int>[
      sash.Orientation.HORIZONTAL,
      sash.Orientation.VERTICAL
    ]) {
      for (final sp.Sizing sizing in <sp.Sizing>[
        sp.Sizing.Distribute,
        sp.Sizing.Auto(0)
      ]) {
        final String key = '${sizing.type}_$orientation';
        final List<TestView> views = <TestView>[
          view(220, double.infinity, sp.LayoutPriority.Normal, true),
          view(220, double.infinity, sp.LayoutPriority.Normal, true),
          view(220, double.infinity, sp.LayoutPriority.Normal, true),
        ];
        final sp.SplitView<int, TestView> sv = newSplitView(
            sp.SplitViewOptions<int, TestView>(orientation: orientation));
        sv.layout(1200);
        sv.addView(views[0], 1200);
        drainLayouts(views);
        sv.addView(views[1], sizing);
        final List<List<num>> addedSecond = drainLayouts(views);
        sv.addView(views[2], sizing);
        final List<List<num>> addedThird = drainLayouts(views);
        sv.removeView(2, sizing);
        final List<List<num>> removedThird = drainLayouts(views);
        sv.layout(600);
        final Map<String, dynamic> expected = e[key] as Map<String, dynamic>;
        expect(addedSecond,
            (expected['addedSecond'] as List<dynamic>).map(nums).toList());
        expect(addedThird,
            (expected['addedThird'] as List<dynamic>).map(nums).toList());
        expect(removedThird,
            (expected['removedThird'] as List<dynamic>).map(nums).toList());
        expect(drainLayouts(views),
            (expected['resized'] as List<dynamic>).map(nums).toList());
        sv.dispose();
      }
    }
  });

  test('distribution retains intermediate layout unless all path independent', () {
    final TestView first = view(220, double.infinity, sp.LayoutPriority.Normal, true);
    final TestView second = view(220, double.infinity);
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(1200);
    sv.addView(first, 1200);
    drainLayouts(<TestView>[first, second]);
    sv.addView(second, sp.Sizing.Distribute);
    expect(drainLayouts(<TestView>[first, second]),
        (l('distributionIntermediate')).map(nums).toList());
    sv.dispose();
  });

  test('distributed additions preserve fixed/capped/hidden/prioritized sizes', () {
    final Map<String, dynamic> e = t('distributedSpecials');
    final TestView fixed = view(100, 100, sp.LayoutPriority.Normal, true);
    final TestView capped = view(100, 200, sp.LayoutPriority.Normal, true);
    final TestView flexible =
        view(100, double.infinity, sp.LayoutPriority.High, true);
    final TestView hidden = view(100, double.infinity, sp.LayoutPriority.Normal, true);
    final TestView added = view(100, double.infinity, sp.LayoutPriority.Normal, true);
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(1000);
    sv.addView(fixed, 100);
    sv.addView(capped, 200);
    sv.addView(flexible, 700);
    sv.addView(hidden, sp.Sizing.Invisible(250));
    final List<TestView> all = <TestView>[fixed, capped, flexible, hidden, added];
    drainLayouts(all);
    sv.addView(added, sp.Sizing.Distribute);
    expect(drainLayouts(all), (e['layouts'] as List<dynamic>).map(nums).toList());
    expect(sizes(all), nums(e['sizes']));
    expect(sv.isViewVisible(3), e['hiddenVisible']);
    expect(sv.getViewCachedVisibleSize(3), e['hiddenCached']);
    expect(sv.contentSize, e['contentSize']);
    sv.dispose();
  });

  test('skipLayout defers a distributed addition', () {
    final Map<String, dynamic> e = t('skipLayout');
    final TestView first = view(20, double.infinity), second = view(20, double.infinity);
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(200);
    sv.addView(first, 200);
    drainLayouts(<TestView>[first, second]);
    sv.addView(second, sp.Sizing.Distribute, 1, true);
    expect(drainLayouts(<TestView>[first, second]),
        (e['deferred'] as List<dynamic>).map(nums).toList());
    sv.layout(200);
    expect(drainLayouts(<TestView>[first, second]),
        (e['calls'] as List<dynamic>).map(nums).toList());
    expect(sv.contentSize, e['contentSize']);
    expect(sizes(<TestView>[first, second]), nums(e['sizes']));
    sv.dispose();
  });

  test('add views before layout', () {
    final List<TestView> views = <TestView>[
      view(20, double.infinity), view(20, double.infinity), view(20, double.infinity)
    ];
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.addView(views[0], 100);
    sv.addView(views[1], 75);
    sv.addView(views[2], 25);
    sv.layout(200);
    expect(sizes(views), nums(l('addBeforeLayout')));
    sv.dispose();
  });

  test('split sizing', () {
    for (final String name in <String>['splitSizing', 'splitSizing2']) {
      final List<TestView> views = <TestView>[
        view(20, double.infinity), view(20, double.infinity), view(20, double.infinity)
      ];
      final sp.SplitView<int, TestView> sv = newSplitView();
      sv.layout(200);
      sv.addView(views[0], sp.Sizing.Distribute);
      final List<List<num>> steps = <List<num>>[sizes(views)];
      sv.addView(views[1], sp.Sizing.Split(0));
      steps.add(sizes(views));
      sv.addView(
          views[2], sp.Sizing.Split(name == 'splitSizing' ? 1 : 0));
      steps.add(sizes(views));
      final List<dynamic> e = l(name);
      for (int i = 0; i < e.length; i++) {
        expect(steps[i], nums(e[i]));
      }
      sv.dispose();
    }
  });

  test('proportional layout variants', () {
    Map<String, dynamic> run(Map<String, dynamic> expected,
        {bool descriptor = false, bool proportional = true}) {
      final List<TestView> views;
      final sp.SplitView<int, TestView> sv;
      if (descriptor) {
        views = <TestView>[
          view(30, 30), view(20, double.infinity), view(20, double.infinity)
        ];
        views[0].proportionalLayout = false;
        sv = newSplitView(sp.SplitViewOptions<int, TestView>(
          descriptor: sp.SplitViewDescriptor<int, TestView>(
            size: 300,
            views: views
                .map((TestView v) => sp.SplitViewDescriptorView<int, TestView>(
                    size: 100, view: v))
                .toList(),
          ),
        ));
        final dynamic initial = sizes(views);
        expect(initial, nums(expected['initial']));
        sv.layout(300);
        expect(sizes(views), nums(expected['after']));
        sv.layout(600);
        expect(sizes(views), nums(expected['grown']));
      } else {
        views = <TestView>[view(20, double.infinity), view(20, double.infinity)];
        sv = newSplitView(sp.SplitViewOptions<int, TestView>(
            proportionalLayout: proportional));
        sv.layout(200);
        for (final TestView v in views) {
          sv.addView(v, sp.Sizing.Distribute);
        }
        expect(sizes(views), nums(expected['initial']));
        sv.layout(100);
        expect(sizes(views), nums(expected['after']));
        sv.layout(proportional ? 200 : 100);
        expect(sizes(views), nums(expected['grown']));
      }
      sv.dispose();
      return expected;
    }

    run(t('proportional'));
    run(t('fixedProportional'), descriptor: true);
    run(t('disableProportional'), proportional: false);
  });

  test('high and low layout priority', () {
    for (final String name in <String>['highPriority', 'lowPriority']) {
      final List<TestView> views = <TestView>[
        view(20, double.infinity),
        view(20,
            double.infinity,
            name == 'highPriority' ? sp.LayoutPriority.High : sp.LayoutPriority.Low),
        view(20, double.infinity),
      ];
      final sp.SplitView<int, TestView> sv = newSplitView(
          sp.SplitViewOptions<int, TestView>(proportionalLayout: false));
      sv.layout(200);
      for (final TestView v in views) {
        sv.addView(v, sp.Sizing.Distribute);
      }
      final List<List<num>> steps = <List<num>>[sizes(views)];
      final List<num> layoutSizes = name == 'highPriority'
          ? <num>[180, 124, 60, 200]
          : <num>[180, 132, 60, 200];
      for (final num s in layoutSizes) {
        sv.layout(s);
        steps.add(sizes(views));
      }
      final List<dynamic> e = l(name);
      for (int i = 0; i < e.length; i++) {
        expect(steps[i], nums(e[i]));
      }
      sv.dispose();
    }
  });

  test('context propagates to views', () {
    final List<TestView> views = <TestView>[
      view(20, double.infinity),
      view(20, double.infinity),
      view(20, double.infinity, sp.LayoutPriority.Low),
    ];
    final sp.SplitView<int, TestView> sv = newSplitView(
        sp.SplitViewOptions<int, TestView>(proportionalLayout: false));
    sv.layout(200);
    for (final TestView v in views) {
      sv.addView(v, sp.Sizing.Distribute);
    }
    sv.layout(200, 100);
    expect(views.map((TestView v) => v.context).toList(), ints(l('context')));
    sv.dispose();
  });

  test('view changing constraints while sibling toggles keeps it', () {
    final Map<String, dynamic> e = t('visibility');
    final TestView editor =
        view(20, double.infinity, sp.LayoutPriority.High);
    final TestView sideBar =
        view(20, double.infinity, sp.LayoutPriority.Low);
    final TestView activityBar = view(10, 10);
    final sp.SplitView<int, TestView> sv = newSplitView(
        sp.SplitViewOptions<int, TestView>(proportionalLayout: false));
    sv.layout(200);
    sv.addView(editor, 120);
    sv.addView(sideBar, 70);
    sv.addView(activityBar, 10);
    sv.resizeView(1, 70);
    expect(sizes(<TestView>[editor, sideBar, activityBar]),
        nums(e['initial']));
    final List<bool> events = <bool>[];
    // Mirror the source test's sideBar.onDidSetVisible listener.
    sideBar.setVisibleImpl = (bool visible) {
      events.add(visible);
      activityBar.minimumSize = visible ? 10 : 12;
      activityBar.maximumSize = visible ? 10 : 12;
      activityBar.change();
    };
    sv.setViewVisible(1, false);
    final Map<String, dynamic> hidden = e['hidden'] as Map<String, dynamic>;
    expect(sizes(<TestView>[editor, sideBar, activityBar]), nums(hidden['sizes']));
    expect(sv.isViewVisible(1), hidden['visible']);
    expect(sv.getViewCachedVisibleSize(1), hidden['cached']);
    sv.setViewVisible(1, true);
    final Map<String, dynamic> shown = e['shown'] as Map<String, dynamic>;
    expect(sizes(<TestView>[editor, sideBar, activityBar]), nums(shown['sizes']));
    expect(sv.isViewVisible(1), shown['visible']);
    expect(events, (e['events'] as List<dynamic>).cast<bool>());
    sv.dispose();
  });

  test('sash drag fires resize and events', () {
    final Map<String, dynamic> e = t('sashDrag');
    final List<TestView> views = <TestView>[
      view(20, double.infinity), view(20, double.infinity), view(20, double.infinity)
    ];
    final sp.SplitView<int, TestView> sv = newSplitView();
    sv.layout(200);
    for (final TestView v in views) {
      sv.addView(v, sp.Sizing.Distribute);
    }
    final List<int> changes = <int>[], resets = <int>[];
    sv.onDidSashChange((dynamic v) => changes.add(v as int));
    sv.onDidSashReset((dynamic v) => resets.add(v as int));
    final FakeSash s = fakeSashes.first;
    s.fireStart(100, 100, false);
    final Map<String, dynamic> afterStart = e['afterStart'] as Map<String, dynamic>;
    expect(sizes(views), nums(afterStart['sizes']));
    expect(
        sv.viewItems
            .map((dynamic i) => (i.container as dom.DomElement).style.getPropertyValue('pointerEvents'))
            .toList(),
        strs(afterStart['enabled']));
    s.fireChange(130, 130, false);
    expect(sizes(views), nums(e['afterChange']));
    s.fireEnd();
    expect(sizes(views), nums(e['afterEnd']));
    s.fireReset();
    expect(changes, ints(e['changeEvents']));
    expect(resets, ints(e['resetEvents']));
    sv.dispose();
  });

  test('dispose releases views and sashes', () {
    final Map<String, dynamic> e = t('dispose');
    final List<TestView> views = <TestView>[view(20, 20), view(20, 20)];
    final sp.SplitView<int, TestView> sv = newSplitView();
    for (final TestView v in views) {
      sv.addView(v, 20);
    }
    final FakeSash s = fakeSashes.single;
    sv.dispose();
    expect(sv.length, e['length']);
    expect(sv.sashItems.length, e['sashes']);
    expect(s.disposed, e['sashDisposed']);
    expect(fakeScrollables.single.disposed, isTrue);
  });
}
