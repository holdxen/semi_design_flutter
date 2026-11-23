import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/sash/sash.dart'
    as sash;
import 'package:semi_design_flutter/src/monaco/base/browser/touch.dart' as touch;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch119_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

Map<String, Object?> _elState(dom.DomElement el) {
  final Map<String, Object?> state = <String, Object?>{
    'tag': el.localName,
    'classes': el.classList.toList(),
    'style': <String, Object?>{
      'left': el.style['left'] ?? '',
      'top': el.style['top'] ?? '',
      'width': el.style['width'] ?? '',
      'height': el.style['height'] ?? '',
    },
  };
  if (el.localName == 'style') {
    state['textContent'] = el.textContent;
  }
  state['children'] = el.childNodes
      .whereType<dom.DomElement>()
      .map<dynamic>((dom.DomElement child) => _elState(child))
      .toList();
  return state;
}

dom.DomElement _childWithClass(dom.DomElement el, List<String> tokens) {
  for (final dom.DomNode child in el.childNodes) {
    if (child is! dom.DomElement) continue;
    if (tokens.every(child.classList.contains)) return child;
    final dom.DomElement? nested = _findChild(child, tokens);
    if (nested != null) return nested;
  }
  throw StateError('child with $tokens not found');
}

dom.DomElement? _findChild(dom.DomElement el, List<String> tokens) {
  for (final dom.DomNode child in el.childNodes) {
    if (child is! dom.DomElement) continue;
    if (tokens.every(child.classList.contains)) return child;
    final dom.DomElement? nested = _findChild(child, tokens);
    if (nested != null) return nested;
  }
  return null;
}

String _styleTextOf(dom.DomElement el) {
  for (final dom.DomNode child in el.childNodes.reversed) {
    if (child is dom.DomElement && child.localName == 'style') {
      return child.textContent;
    }
  }
  return '';
}

class _VerticalProvider implements sash.IVerticalSashLayoutProvider {
  @override
  num getVerticalSashLeft(sash.Sash sash) => 80;
  @override
  num getVerticalSashTop(sash.Sash sash) => 10;
  @override
  num getVerticalSashHeight(sash.Sash sash) => 200;
}

class _HorizontalProvider implements sash.IHorizontalSashLayoutProvider {
  @override
  num getHorizontalSashTop(sash.Sash sash) => 40;
  @override
  num getHorizontalSashLeft(sash.Sash sash) => 5;
  @override
  num getHorizontalSashWidth(sash.Sash sash) => 120;
}

dom.DomMouseEvent _mouse(dom.DomNode target, String type,
    {double pageX = 0,
    double pageY = 0,
    bool altKey = false,
    Object? initialTarget}) {
  final dom.DomMouseEvent e = dom.DomMouseEvent(type)
    ..pageX = pageX
    ..pageY = pageY
    ..altKey = altKey
    ..target = target
    ..initialTarget = initialTarget;
  target.dispatchEvent(type, e);
  return e;
}

num _jsNum(num value) =>
    value is double && value == value.toInt() ? value.toInt() : value;

Map<String, Object?> _event(sash.SashEvent e) => <String, Object?>{
      'startX': _jsNum(e.startX),
      'currentX': _jsNum(e.currentX),
      'startY': _jsNum(e.startY),
      'currentY': _jsNum(e.currentY),
      'altKey': e.altKey,
    };

void main() {
  setUp(() {
    sash.setGlobalSashSize(4);
    sash.setGlobalHoverDelay(300);
  });
  tearDown(() {
    sash.setGlobalSashSize(4);
    sash.setGlobalHoverDelay(300);
  });

  test('constructor layout and classes', () {
    final t = _section('construct');
    final dom.DomElement vContainer = dom.document.createElement('div');
    final dom.DomElement hContainer = dom.document.createElement('div');
    final sash.Sash v = sash.Sash(
        vContainer,
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final sash.Sash h = sash.Sash(
        hContainer,
        _HorizontalProvider(),
        sash.SashOptions(orientation: sash.Orientation.HORIZONTAL, size: 8));
    final dom.DomElement edgeContainer = dom.document.createElement('div');
    final sash.Sash edge = sash.Sash(
        edgeContainer,
        _VerticalProvider(),
        sash.SashOptions(
          orientation: sash.Orientation.VERTICAL,
          size: 6,
          orthogonalEdge: sash.OrthogonalEdge.North,
        ));

    expect(_elState(vContainer), t['vertical']);
    expect(_elState(hContainer), t['horizontal']);
    expect(_elState(edge.el), t['orthogonalEdge']);
    expect(<String, Object?>{'vertical': v.state, 'horizontal': h.state},
        t['states']);

    v.dispose();
    h.dispose();
    edge.dispose();
  });

  test('global size and hover delay', () {
    final t = _section('globals');
    final dom.DomElement container = dom.document.createElement('div');
    final sash.Sash s = sash.Sash(
        container,
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));

    sash.setGlobalSashSize(12);
    expect(_elState(s.el), t['afterGlobalSize']);
    s.layout();
    expect(_elState(s.el), t['afterLayout']);
    sash.setGlobalHoverDelay(0);

    s.dispose();
  });

  test('state toggles classes', () {
    final List<dynamic> t = _truth['state'] as List<dynamic>;
    final sash.Sash s = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final sash.Sash peer = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    s.orthogonalStartSash = peer;

    final List<Object?> states = <Object?>[];
    void snap() => states.add(<String, Object?>{
          'state': s.state,
          'classes': s.el.classList.toList(),
          'handles': s.el.childNodes.whereType<dom.DomElement>().length,
        });
    snap();
    s.state = sash.SashState.Disabled;
    snap();
    s.state = sash.SashState.AtMinimum;
    snap();
    s.state = sash.SashState.AtMaximum;
    snap();
    s.state = sash.SashState.Enabled;
    snap();

    expect(states, t);
    s.dispose();
    peer.dispose();
  });

  test('addClass leasing', () {
    final t = _section('addClass');
    final sash.Sash s = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));

    final lifecycle.IDisposable first = s.addClass('leased');
    final lifecycle.IDisposable second = s.addClass('leased');
    final lifecycle.IDisposable pre = s.addClass('vertical');
    final List<Object?> states = <Object?>[s.el.classList.contains('leased')];
    first.dispose();
    states.add(s.el.classList.contains('leased'));
    second.dispose();
    states.add(s.el.classList.contains('leased'));
    pre.dispose();

    expect(<String, Object?>{
      'leasedClassStates': states,
      'preExistingClassAfterRelease': s.el.classList.contains('vertical'),
    }, t);
    s.dispose();
  });

  test('orthogonal handles follow peer enablement', () {
    final List<dynamic> t = _truth['orthogonal'] as List<dynamic>;
    final sash.Sash main = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final sash.Sash peer = sash.Sash(
        dom.document.createElement('div'),
        _HorizontalProvider(),
        sash.SashOptions(orientation: sash.Orientation.HORIZONTAL));
    main.orthogonalStartSash = peer;
    main.orthogonalEndSash = peer;

    List<Object?> snap() => main.el.childNodes
        .whereType<dom.DomElement>()
        .map<dynamic>((dom.DomElement e) => e.classList.toList())
        .toList();
    final List<Object?> seq = <Object?>[snap()];
    peer.state = sash.SashState.Disabled;
    seq.add(snap());
    peer.state = sash.SashState.Enabled;
    seq.add(snap());
    main.orthogonalStartSash = null;
    seq.add(snap());
    main.orthogonalEndSash = null;
    seq.add(snap());

    expect(seq, t);
    main.dispose();
    peer.dispose();
  });

  test('mouse drag starts, moves, ends and forwards to linked/orthogonal', () {
    final t = _section('drag');
    sash.setGlobalHoverDelay(0);
    final dom.DomElement container = dom.document.createElement('div');
    dom.document.body.appendChild(container);
    final dom.DomElement iframe = dom.document.createElement('iframe');
    container.appendChild(iframe);
    final sash.Sash s = sash.Sash(
        container,
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final sash.Sash linked = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final sash.Sash ortho = sash.Sash(
        dom.document.createElement('div'),
        _HorizontalProvider(),
        sash.SashOptions(orientation: sash.Orientation.HORIZONTAL));
    s.linkedSash = linked;
    s.orthogonalStartSash = ortho;

    final List<Object?> events = <Object?>[];
    s.onDidStart((Object? e) => events.add(<Object?>['s-start', _event(e as sash.SashEvent)]));
    s.onDidChange((Object? e) => events.add(<Object?>['s-change', _event(e as sash.SashEvent)]));
    s.onDidEnd((Object? e) => events.add(<Object?>['s-end']));
    linked.onDidStart((Object? e) => events.add(<Object?>['l-start', _event(e as sash.SashEvent)]));
    linked.onDidChange((Object? e) => events.add(<Object?>['l-change', _event(e as sash.SashEvent)]));
    linked.onDidEnd((Object? e) => events.add(<Object?>['l-end']));
    ortho.onDidStart((Object? e) => events.add(<Object?>['o-start', _event(e as sash.SashEvent)]));
    ortho.onDidChange((Object? e) => events.add(<Object?>['o-change', _event(e as sash.SashEvent)]));
    ortho.onDidEnd((Object? e) => events.add(<Object?>['o-end']));

    final dom.DomElement handle =
        _childWithClass(s.el, <String>['orthogonal-drag-handle', 'start']);
    _mouse(s.el, dom.EventType.MOUSE_DOWN,
        pageX: 100, pageY: 20, altKey: true, initialTarget: handle);
    expect(<String, Object?>{
      'events': events,
      'sashClasses': s.el.classList.toList(),
      'styleText': _styleTextOf(s.el),
      'iframeClasses': iframe.classList.toList(),
    }, (t['duringStart'] as Map).cast<String, dynamic>());

    _mouse(dom.document, dom.EventType.MOUSE_MOVE,
        pageX: 130, pageY: 25, altKey: true);
    expect(<String, Object?>{
      'events': events,
      'iframeClasses': iframe.classList.toList(),
    }, (t['afterMove'] as Map).cast<String, dynamic>());

    _mouse(dom.document, dom.EventType.MOUSE_UP,
        pageX: 130, pageY: 25, altKey: true);
    expect(<String, Object?>{
      'events': events,
      'sashClasses': s.el.classList.toList(),
      'styleText': _styleTextOf(s.el),
      'iframeClasses': iframe.classList.toList(),
    }, (t['afterUp'] as Map).cast<String, dynamic>());

    s.dispose();
    linked.dispose();
    ortho.dispose();
    container.remove();
  });

  test('double click resets local and linked sash', () {
    final List<dynamic> t = _truth['doubleClick'] as List<dynamic>;
    final sash.Sash s = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final sash.Sash linked = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final sash.Sash ortho = sash.Sash(
        dom.document.createElement('div'),
        _HorizontalProvider(),
        sash.SashOptions(orientation: sash.Orientation.HORIZONTAL));
    s.linkedSash = linked;
    s.orthogonalStartSash = ortho;
    final List<Object?> resets = <Object?>[];
    s.onDidReset((Object? e) => resets.add('s'));
    linked.onDidReset((Object? e) => resets.add('l'));
    ortho.onDidReset((Object? e) => resets.add('o'));

    _mouse(s.el, dom.EventType.DBLCLICK, pageX: 1, pageY: 2);

    expect(resets, t);
    s.dispose();
    linked.dispose();
    ortho.dispose();
  });

  test('hover enter/leave with linked propagation', () async {
    final t = _section('hover');
    sash.setGlobalHoverDelay(0);
    final sash.Sash s = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final sash.Sash linked = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    s.linkedSash = linked;

    _mouse(s.el, dom.EventType.MOUSE_ENTER);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(<String, Object?>{
      's': s.el.classList.toList(),
      'linked': linked.el.classList.toList(),
    }, t['afterEnter']);

    _mouse(s.el, dom.EventType.MOUSE_LEAVE);
    expect(<String, Object?>{
      's': s.el.classList.toList(),
      'linked': linked.el.classList.toList(),
    }, t['afterLeave']);

    s.clearSashHoverState();
    expect(<String, Object?>{
      's': s.el.classList.toList(),
      'linked': linked.el.classList.toList(),
    }, t['afterClear']);

    s.dispose();
    linked.dispose();
  });

  test('gesture start/change/end path', () {
    final List<dynamic> t = _truth['gesture'] as List<dynamic>;
    final sash.Sash s = sash.Sash(
        dom.document.createElement('div'),
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final List<Object?> events = <Object?>[];
    s.onDidStart((Object? e) => events.add(<Object?>['start', _event(e as sash.SashEvent)]));
    s.onDidChange((Object? e) => events.add(<Object?>['change', _event(e as sash.SashEvent)]));
    s.onDidEnd((Object? e) => events.add(<Object?>['end']));

    _mouse(s.el, touch.EventType.Start, pageX: 7, pageY: 9);
    _mouse(s.el, touch.EventType.Change, pageX: 17, pageY: 19);
    _mouse(s.el, touch.EventType.End, pageX: 17, pageY: 19);

    expect(events, t);
    s.dispose();
  });

  test('dispose removes the sash element', () {
    final t = _section('dispose');
    final dom.DomElement container = dom.document.createElement('div');
    final sash.Sash s = sash.Sash(
        container,
        _VerticalProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    final int before = container.childNodes.whereType<dom.DomElement>().length;
    s.dispose();
    final int after = container.childNodes.whereType<dom.DomElement>().length;
    expect(<String, Object?>{'before': before, 'after': after}, t);
  });
}
