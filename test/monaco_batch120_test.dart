import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/sash/sash.dart'
    as sash;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/resizable/resizable.dart'
    as resizable;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as events;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch120_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

/// Recording Sash fake. Extends the real `sash.Sash` so layout/state/orthogonal
/// semantics stay real, but overrides the four event streams with injectable
/// emitters and counts layout/clear/dispose calls.
class _FakeSash extends sash.Sash {
  _FakeSash(dom.DomElement container, Object provider, sash.SashOptions options)
      : super(container, provider, options) {
    _provider = provider;
  }

  Object _provider = Object();
  int id = -1;
  bool counting = false;
  int layoutCount = 0;
  int clearCount = 0;
  bool disposedFlag = false;

  final events.Emitter<sash.SashEvent> _start = events.Emitter<sash.SashEvent>();
  final events.Emitter<sash.SashEvent> _change = events.Emitter<sash.SashEvent>();
  final events.Emitter<void> _reset = events.Emitter<void>();
  final events.Emitter<void> _end = events.Emitter<void>();

  @override
  events.Event<sash.SashEvent> get onDidStart => _start.event;
  @override
  events.Event<sash.SashEvent> get onDidChange => _change.event;
  @override
  events.Event<void> get onDidReset => _reset.event;
  @override
  events.Event<void> get onDidEnd => _end.event;

  void fireStart() => _start.fire(sash.SashEvent(
        startX: 0, currentX: 0, startY: 0, currentY: 0, altKey: false));
  void fireChange(num startX, num currentX, num startY, num currentY) =>
      _change.fire(sash.SashEvent(
          startX: startX,
          currentX: currentX,
          startY: startY,
          currentY: currentY,
          altKey: false));
  void fireReset() => _reset.fire(null);
  void fireEnd() => _end.fire(null);

  @override
  void layout() {
    if (counting) layoutCount++;
    super.layout();
  }

  @override
  void clearSashHoverState() {
    if (counting) clearCount++;
    super.clearSashHoverState();
  }

  @override
  void dispose() {
    disposedFlag = true;
    super.dispose();
  }

  Map<String, Object?> providerSnapshot() {
    if (_provider is sash.IVerticalSashLayoutProvider) {
      final p = _provider as sash.IVerticalSashLayoutProvider;
      return <String, Object?>{
        'getVerticalSashLeft': p.getVerticalSashLeft(this),
        'getVerticalSashTop': p.getVerticalSashTop(this),
        'getVerticalSashHeight': p.getVerticalSashHeight(this),
      };
    }
    final p = _provider as sash.IHorizontalSashLayoutProvider;
    return <String, Object?>{
      'getHorizontalSashTop': p.getHorizontalSashTop(this),
      'getHorizontalSashLeft': p.getHorizontalSashLeft(this),
      'getHorizontalSashWidth': p.getHorizontalSashWidth(this),
    };
  }

  Map<String, Object?> toSnapshot(sash.Sash? start, sash.Sash? end) {
    final options = _options!;
    return <String, Object?>{
      'id': id,
      'orientation': options.orientation,
      'edge': options.orthogonalEdge,
      'state': state,
      'orthogonalStartSash': start == null ? null : (start as _FakeSash).id,
      'orthogonalEndSash': end == null ? null : (end as _FakeSash).id,
      'layoutCount': layoutCount,
      'clearCount': clearCount,
      'disposed': disposedFlag,
      'provider': providerSnapshot(),
    };
  }

  sash.SashOptions? _options;
  void bindOptions(sash.SashOptions options) => _options = options;
}

final List<_FakeSash> _created = <_FakeSash>[];

sash.Sash _fakeFactory(dom.DomElement container, Object provider,
    sash.SashOptions options) {
  final fake = _FakeSash(container, provider, options)
    ..id = _created.length
    ..bindOptions(options);
  _created.add(fake);
  fake.counting = true;
  return fake;
}

void _reset() {
  _created.clear();
  resizable.sashFactory = _fakeFactory;
}

void _restore() {
  resizable.sashFactory = (dom.DomElement c, Object p, sash.SashOptions o) =>
      sash.Sash(c, p, o);
}

List<_FakeSash> get _lastFour => _created.sublist(_created.length - 4);

Map<String, Object?> _dim(dom.Dimension d) => <String, Object?>{
      'width': d.width,
      'height': d.height,
    };

Map<String, Object?> _resizeEvent(resizable.IResizeEvent e) =>
    <String, Object?>{
      'done': e.done,
      'dimension': _dim(e.dimension),
      'reset': e.reset ?? 'undefined',
      'north': e.north ?? false,
      'east': e.east ?? false,
      'south': e.south ?? false,
      'west': e.west ?? false,
    };

void main() {
  setUp(() => _reset());
  tearDown(() => _restore());

  test('construction: 4 sashes, orientations, orthogonal links, sizes', () {
    final expected = _section('construct');
    final r = resizable.ResizableHTMLElement();

    expect(r.domNode.localName, expected['domNodeTag']);
    final sashes = _created;
    expect(sashes.length, (expected['sashes'] as List).length);
    for (int i = 0; i < sashes.length; i++) {
      final exp = (expected['sashes'] as List)[i] as Map;
      final act = sashes[i].toSnapshot(
          sashes[i].orthogonalStartSash, sashes[i].orthogonalEndSash);
      for (final key in exp.keys) {
        expect(act[key], exp[key], reason: 'sash[$i].$key');
      }
    }
    expect(_dim(r.size), expected['size']);
    expect(_dim(r.maxSize), expected['maxSize']);
    expect(_dim(r.minSize), expected['minSize']);
    expect(r.preferredSize == null ? 'undefined' : 'set',
        expected['preferredSize']);
    r.dispose();
  });

  test('resize flow: will-resize guard, delta signs, done, ignore-after-end', () {
    final expected = _section('resizeFlow');
    final r = resizable.ResizableHTMLElement();
    final sashes = _lastFour;
    final east = sashes[0], west = sashes[1], north = sashes[2], south = sashes[3];

    final List<Map<String, Object?>> events = <Map<String, Object?>>[];
    r.onDidWillResize((_) => events.add(<String, Object?>{'type': 'will'}));
    r.onDidResize((dynamic e) {
      final m = _resizeEvent(e as resizable.IResizeEvent);
      m['type'] = 'resize';
      events.add(m);
    });

    r.layout(300, 400);
    events.clear();

    east.fireStart();
    east.fireChange(100, 110, 50, 50);
    east.fireChange(100, 130, 50, 50);
    west.fireStart();
    west.fireChange(200, 195, 50, 50);
    north.fireChange(0, 0, 80, 60);
    south.fireChange(0, 0, 80, 95);
    east.fireEnd();
    east.fireChange(100, 999, 50, 50);

    final expEvents = (expected['events'] as List).cast<Map>();
    expect(events.length, expEvents.length);
    for (int i = 0; i < events.length; i++) {
      for (final key in expEvents[i].keys) {
        expect(events[i][key], expEvents[i][key], reason: 'event[$i].$key');
      }
    }
    expect(_dim(r.size), expected['finalSize']);
    r.dispose();
  });

  test('layout: min/max clamp, style, sash relayout, no-op', () {
    final expected = _section('layout');
    final r = resizable.ResizableHTMLElement();
    final sashes = _lastFour;
    r.minSize = dom.Dimension(50, 40);
    r.maxSize = dom.Dimension(200, 180);

    final before = sashes.map((s) => s.layoutCount).toList();
    r.layout(500, 500);
    final expClamp = (expected['afterClamp'] as Map).cast<String, dynamic>();
    expect(_dim(r.size), expClamp['size']);
    expect(<String, Object?>{
      'width': r.domNode.style['width'],
      'height': r.domNode.style['height'],
    }, expClamp['style']);
    expect(
        sashes
            .map((s) => s.layoutCount - before[sashes.indexOf(s)])
            .toList(),
        expClamp['layoutDeltas']);

    final before2 = sashes.map((s) => s.layoutCount).toList();
    r.layout(100, 90);
    final expNormal = (expected['afterNormal'] as Map).cast<String, dynamic>();
    expect(_dim(r.size), expNormal['size']);
    expect(<String, Object?>{
      'width': r.domNode.style['width'],
      'height': r.domNode.style['height'],
    }, expNormal['style']);
    expect(
        sashes
            .map((s) => s.layoutCount - before2[sashes.indexOf(s)])
            .toList(),
        expNormal['layoutDeltas']);

    final before3 = sashes.map((s) => s.layoutCount).toList();
    r.layout(100, 90);
    expect(
        sashes
            .map((s) => s.layoutCount - before3[sashes.indexOf(s)])
            .toList(),
        expected['noopDeltas']);
    r.dispose();
  });

  test('enableSashes + clearSashHoverState', () {
    final expected = _section('enable');
    final r = resizable.ResizableHTMLElement();
    final sashes = _lastFour;
    final before = sashes.map((s) => s.clearCount).toList();
    r.enableSashes(true, false, true, false);
    expect(sashes.map((s) => s.state).toList(), expected['states']);
    r.clearSashHoverState();
    expect(
        sashes.map((s) => s.clearCount - before[sashes.indexOf(s)]).toList(),
        expected['clearDeltas']);
    r.dispose();
  });

  test('reset: preferredSize width/height, no-preferred no event', () {
    final expected = _section('reset');
    final r = resizable.ResizableHTMLElement();
    final sashes = _lastFour;
    final east = sashes[0], north = sashes[2], south = sashes[3];

    final List<Map<String, Object?>> events = <Map<String, Object?>>[];
    r.onDidResize((dynamic raw) {
      final resizable.IResizeEvent e = raw as resizable.IResizeEvent;
      events.add(<String, Object?>{
        'done': e.done,
        'reset': e.reset ?? 'undefined',
        'width': e.dimension.width,
        'height': e.dimension.height,
      });
    });

    r.layout(300, 400);
    r.preferredSize = dom.Dimension(120, 160);
    events.clear();
    east.fireReset();
    south.fireReset();
    r.preferredSize = null;
    north.fireReset();

    final expEvents = (expected['events'] as List).cast<Map>();
    expect(events.length, expEvents.length);
    for (int i = 0; i < events.length; i++) {
      for (final key in expEvents[i].keys) {
        expect(events[i][key], expEvents[i][key], reason: 'reset event[$i].$key');
      }
    }
    expect(_dim(r.size), expected['size']);
    expect(r.preferredSize == null ? 'undefined' : 'set',
        expected['preferredSizeAfter']);
    r.dispose();
  });

  test('dispose: all sashes disposed + DOM node detached', () {
    final expected = _section('dispose');
    final container = dom.document.createElement('div');
    final r = resizable.ResizableHTMLElement();
    container.appendChild(r.domNode);
    final sashes = _lastFour;
    r.dispose();
    expect(sashes.map((s) => s.disposedFlag).toList(),
        expected['sashDisposed']);
    expect(r.domNode.parentNode == null ? 'null' : 'attached',
        expected['domNodeParent']);
  });
}
