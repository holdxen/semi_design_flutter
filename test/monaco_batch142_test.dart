import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/animations/animations.dart'
    as a;
import 'package:semi_design_flutter/src/monaco/base/common/themables.dart' as themables;

final Map<String, Object?> _truth =
    json.decode(File('tool/ts2dart/batch142_truth.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> _list(Object? v) => (v as List).cast<Object?>();

num _num(Object? v) => v as num;

/// Recording fake element.
class _El {
  _El(this.description);

  final String description;
  final Map<String, String> styles = <String, String>{};
  final List<String> classes = <String>[];
  final List<_El> children = <_El>[];
  dom.DomRect? rect;
  Object? closestResult;
}

class _Recorder {
  final List<Map<String, Object?>> animateCalls = <Map<String, Object?>>[];
  final List<int> timeouts = <int>[];
  final List<String> appended = <String>[];
  final List<String> removed = <String>[];
  final Map<String, _El> elements = <String, _El>{};

  _El el(String description) =>
      elements.putIfAbsent(description, () => _El(description));

  void reset() {
    animateCalls.clear();
    timeouts.clear();
    appended.clear();
    removed.clear();
    elements.clear();
  }
}

void _install(_Recorder rec, {List<double> rand = const <double>[]}) {
  int randIdx = 0;
  a.randomProvider = () {
    if (randIdx >= rand.length) return 0.5;
    return rand[randIdx++];
  };
  a.animateProvider = (Object element, List<a.Keyframe> frames,
          a.AnimationOptions options) =>
      rec.animateCalls.add(<String, Object?>{
        'el': (element as _El).description,
        'frames': frames,
        'opts': options,
      });
  a.setTimeoutProvider = (Object node, void Function() fn, int ms) {
    rec.timeouts.add(ms);
    return 0;
  };
  a.removeProvider = (Object element) => rec.removed.add((element as _El).description);
  a.elementCreateProvider = (String d) => rec.el(d);
  a.setStyleProvider = (Object element, String name, String value) =>
      (element as _El).styles[name] = value;
  a.appendChildProvider = (Object parent, Object child) {
    final _El p = parent as _El;
    final _El c = child as _El;
    p.children.add(c);
    rec.appended.add('${p.description}->${c.description}');
  };
  a.addClassesProvider = (Object element, List<String> classes) =>
      (element as _El).classes.addAll(classes);
  a.getBoundingClientRectProvider = (Object element) =>
      (element as _El).rect ?? dom.DomRect();
  a.windowBodyProvider = (Object element) => rec.el('body');
  a.closestProvider = (Object element, String selector) =>
      (element as _El).closestResult;
  a.isHTMLElementProvider = (Object target) => target is _El;
}

void main() {
  final _Recorder rec = _Recorder();

  setUp(() {
    rec.reset();
    _install(rec);
  });

  test('captureAnimationTarget body fallback', () {
    final _El target = rec.el('target')
      ..rect = dom.DomRect(left: 10, top: 20, width: 100, height: 50)
      ..closestResult = null;
    final a.IAnimationTarget captured = a.captureAnimationTarget(target);
    final Map<String, Object?> e = _map(_truth['captureBody']);
    expect((captured.rect.width), _num(e['w']));
    expect((captured.rect.height), _num(e['h']));
    expect((captured.container as _El).description, e['container']);
    expect((captured.element as _El).description, e['element']);
  });

  test('captureAnimationTarget closest workbench', () {
    final _El target = rec.el('target')
      ..rect = dom.DomRect(left: 10, top: 20, width: 100, height: 50)
      ..closestResult = rec.el('.monaco-workbench');
    final a.IAnimationTarget captured = a.captureAnimationTarget(target);
    expect((captured.container as _El).description,
        _map(_truth['captureClosest'])['container']);
  });

  test('bounceElement no steps', () {
    a.bounceElement(rec.el('b'));
    expect(rec.animateCalls.length, _truth['bounceNoSteps']);
  });

  test('bounceElement multi-step frames + options', () {
    a.bounceElement(rec.el('b'),
        scale: <num>[1, 1.3],
        rotate: <num>[0, -10, 10, 0],
        translateY: <num>[0, -6, 0],
        duration: 500);
    final List<Object?> expected = _list(_truth['bounceFrames']);
    final List<a.Keyframe> frames =
        rec.animateCalls.single['frames'] as List<a.Keyframe>;
    expect(frames.length, expected.length);
    for (int i = 0; i < frames.length; i++) {
      final Map<String, Object?> ef = _map(expected[i]);
      expect((frames[i]['offset'] as num).toDouble(),
          closeTo(_num(ef['offset']).toDouble(), 1e-12),
          reason: 'frame $i offset');
      expect(frames[i]['transform'], ef['transform'], reason: 'frame $i transform');
    }
    final Map<String, Object?> eo = _map(_truth['bounceOpts']);
    final a.AnimationOptions opts = rec.animateCalls.single['opts'] as a.AnimationOptions;
    expect(opts['duration'], eo['duration']);
    expect(opts['easing'], eo['easing']);
    expect(opts['fill'], eo['fill']);
  });

  test('bounceElement single-step offset', () {
    a.bounceElement(rec.el('b'), scale: <num>[2]);
    final a.Keyframe frame =
        (rec.animateCalls.single['frames'] as List<a.Keyframe>).single;
    expect(frame['offset'], _list(_truth['bounceSingle']).isNotEmpty ? 1 : -1);
    expect(frame['transform'], 'scale(2)');
  });

  test('triggerClickAnimation dispatch counts', () {
    final List<Object?> rows = _list(_truth['dispatch']);
    final List<int> anims = <int>[1, 2, 3, 4, 999];
    for (int i = 0; i < anims.length; i++) {
      rec.reset();
      _install(rec, rand: List<double>.filled(1000, 0.5));
      a.triggerClickAnimation(rec.el('t'), anims[i]);
      final Map<String, Object?> e = _map(rows[i]);
      expect(rec.animateCalls.length, e['animateCount'], reason: 'dispatch ${anims[i]} animate');
      expect(rec.timeouts, _list(e['timeouts']), reason: 'dispatch ${anims[i]} timeouts');
    }
  });

  test('floating icons with icon', () {
    _install(rec, rand: List<double>.filled(1000, 0.5));
    a.triggerClickAnimation(rec.el('t'), a.ClickAnimation.floatingIcons,
        themables.ThemeIcon('check~spin'));
    final Map<String, Object?> e = _map(_truth['floatIcons']);
    expect(rec.animateCalls.length, e['animateCount']);
    expect(rec.timeouts, _list(e['timeouts']));
    expect(
      (rec.animateCalls[0]['frames'] as List<a.Keyframe>).length,
      e['firstFrames'],
    );
  });

  test('confetti structure', () {
    _install(rec, rand: List<double>.filled(2000, 0.5));
    a.triggerClickAnimation(rec.el('t'), a.ClickAnimation.confetti);
    final Map<String, Object?> e = _map(_truth['confetti']);
    expect(rec.animateCalls.length, e['animateCount']);
    expect(rec.timeouts, _list(e['timeouts']));
    final int particles = rec.appended
        .where((String s) =>
            s.endsWith('->.animation-particle.animation-confetti-particle'))
        .length;
    expect(particles, e['particleCount']);
    expect(
      rec.animateCalls
          .map((Map<String, Object?> c) =>
              (c['frames'] as List<a.Keyframe>).length)
          .toList(),
      _list(e['keyframeCounts']),
    );
  });

  test('pulse wave structure', () {
    _install(rec, rand: List<double>.filled(1000, 0.5));
    a.triggerClickAnimation(rec.el('t'), a.ClickAnimation.pulseWave);
    final Map<String, Object?> e = _map(_truth['pulse']);
    expect(rec.animateCalls.length, e['animateCount']);
    expect(rec.timeouts, _list(e['timeouts']));
    final int particles = rec.appended
        .where((String s) => s.endsWith('->.animation-particle'))
        .length;
    expect(particles, e['particleCount']);
  });

  test('radiant lines structure', () {
    _install(rec, rand: List<double>.filled(1000, 0.5));
    a.triggerClickAnimation(rec.el('t'), a.ClickAnimation.radiantLines);
    final Map<String, Object?> e = _map(_truth['radiant']);
    expect(rec.animateCalls.length, e['animateCount']);
    expect(rec.timeouts, _list(e['timeouts']));
    final int particles = rec.appended
        .where((String s) => s.endsWith('->.animation-particle'))
        .length;
    expect(particles, e['particleCount']);
  });
}
