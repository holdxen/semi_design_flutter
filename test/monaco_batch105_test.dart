// Data-driven port test for batch105: base/browser/animatedValue.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/animatedValue.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart'
    show windowCarrier;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart'
    show mainWindow;
import 'package:semi_design_flutter/src/monaco/base/common/observable.dart'
    show IObservableWithChange, IReader;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch105_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _CountingReader implements IReader {
  int count = 0;

  @override
  T readObservable<T>(IObservableWithChange<T, Object?> observable) {
    count++;
    return null as T;
  }
}

void main() {
  late int Function() originalNow;

  setUp(() {
    originalNow = animatedValueDateNow;
    animatedValueDateNow = () => 1000;
    windowCarrier(mainWindow).flushAnimationFrame();
  });

  tearDown(() {
    windowCarrier(mainWindow).flushAnimationFrame();
    animatedValueDateNow = originalNow;
  });

  test('exports and constant animated value', () {
    expect(truth['exports'], <dynamic>[
      'AnimatedValue',
      'AnimationFrameScheduler',
      'LoopingAnimatedValue',
      'ObservableAnimatedValue',
      'easeOutCubic',
      'easeOutExpo',
      'linear',
    ]);
    final AnimatedValue v = AnimatedValue.constant(5);
    final Map<String, dynamic> t = truth['constValue'] as Map<String, dynamic>;
    expect([v.startValue, v.endValue, v.durationMs, v.startTimeMs],
        [t['startValue'], t['endValue'], t['durationMs'], t['startTimeMs']]);
    expect(v.isFinished(1000), t['finished']);
    expect(v.getValue(1000), t['value']);
  });

  test('interpolation functions match JS floating point truth', () {
    for (final String name in ['linear', 'easeOutExpo', 'easeOutCubic']) {
      final num Function(num, num, num, num) fn = switch (name) {
        'linear' => linear,
        'easeOutExpo' => easeOutExpo,
        _ => easeOutCubic,
      };
      final List<dynamic> expected = truth['${name}Values'] as List<dynamic>;
      const List<int> times = <int>[0, 100, 500, 1000];
      for (int i = 0; i < expected.length; i++) {
        expect(fn(times[i], 0, 100, 1000), closeTo(expected[i], 1e-9),
            reason: '$name at ${times[i]}');
      }
    }
  });

  test('AnimatedValue samples and same-value duration reset', () {
    final AnimatedValue animated = AnimatedValue.startNow(0, 100, 1000);
    final Map<String, dynamic> t = truth['animatedStart'] as Map<String, dynamic>;
    expect(animated.durationMs, t['durationMs']);
    expect(animated.startTimeMs, t['startTimeMs']);
    for (final dynamic sample in t['samples'] as List<dynamic>) {
      final List<dynamic> s = sample as List<dynamic>;
      final int now = (s[0] as num).toInt();
      expect(animated.isFinished(now), s[1], reason: 'finished at $now');
      expect(animated.getValue(now), closeTo(s[2], 1e-9),
          reason: 'value at $now');
    }
    final AnimatedValue same = AnimatedValue.startNow(7, 7, 500);
    expect(same.durationMs, truth['sameValue']['durationMs']);
    expect(same.getValue(1000), truth['sameValue']['value']);
    expect(same.isFinished(1000), truth['sameValue']['finished']);
  });

  test('LoopingAnimatedValue never finishes', () {
    final LoopingAnimatedValue looping = LoopingAnimatedValue.startNow(
        0, 100, 1000, linear);
    for (final dynamic sample in truth['looping']['samples'] as List<dynamic>) {
      final List<dynamic> s = sample as List<dynamic>;
      final int now = (s[0] as num).toInt();
      expect(looping.isFinished(now), s[1]);
      expect(looping.getValue(now), closeTo(s[2], 1e-9),
          reason: 'looping value at $now');
    }
  });

  test('ObservableAnimatedValue schedules one rAF per pending animation', () {
    final _CountingReader reader = _CountingReader();
    final ObservableAnimatedValue<AnimatedValue> constValue =
        ObservableAnimatedValue.constant(7);
    expect(constValue.getValue(reader), truth['observableConst']['value']);
    expect(constValue.isFinished(reader), truth['observableConst']['finished']);
    expect(reader.count, 0);
    expect(windowCarrier(mainWindow).rafCount, 0);

    final ObservableAnimatedValue<AnimatedValue> unfinished =
        ObservableAnimatedValue<AnimatedValue>(AnimatedValue.startNow(0, 100, 1000));
    expect(unfinished.getValue(reader),
        truth['observableUnfinishedFirst']['value']);
    expect(reader.count, 1);
    expect(windowCarrier(mainWindow).rafCount,
        truth['observableUnfinishedFirst']['rafCount']);

    expect(unfinished.isFinished(reader),
        truth['observableUnfinishedSecond']['finished']);
    expect(reader.count, 2);
    expect(windowCarrier(mainWindow).rafCount,
        truth['observableUnfinishedSecond']['rafCount']);

    windowCarrier(mainWindow).flushAnimationFrame();
    expect(windowCarrier(mainWindow).rafCount,
        truth['afterRaf']['rafCount']);
    expect(AnimationFrameScheduler.instance ==
        AnimationFrameScheduler.instance, truth['schedulerIsSingleton']);
  });
}
