// Data-driven port test for batch102: base/browser/ui/progressbar/progressbar.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/ui/progressbar/progressAccessibilitySignal.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/ui/progressbar/progressbar.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart';

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch102_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _SpyDelegate implements IScopedAccessibilityProgressSignalDelegate {
  final int delay;
  final int? loop;
  int disposeCount = 0;

  _SpyDelegate(this.delay, this.loop);

  @override
  int get msDelayTime => delay;

  @override
  int get msLoopTime => loop ?? -1;

  @override
  void dispose() => disposeCount++;
}

Map<String, dynamic> _snapEl(DomElement e) {
  final Map<String, String> attrs = <String, String>{};
  for (final MapEntry<String, String> a in e.attributes) {
    if (a.key == 'aria-hidden') continue; // truth show/hide stub is black-box
    attrs[a.key] = a.value;
  }
  final Map<String, String> style = <String, String>{};
  for (final String k in e.style.keys) {
    if (k == 'display') continue; // truth show/hide stub is black-box
    style[k] = e.style.getPropertyValue(k);
  }
  final List<String> classes = e.classList.toList()..sort();
  return <String, dynamic>{
    'tag': e.localName,
    'classes': classes,
    'attrs': attrs,
    'style': style,
    'childCount': e.childNodes.length,
  };
}

void _expectSnap(ProgressBar bar, String key) {
  final Map<String, dynamic> t = truth[key] as Map<String, dynamic>;
  final Map<String, dynamic> container = t['container'] as Map<String, dynamic>;
  final Map<String, dynamic> bit = t['bit'] as Map<String, dynamic>;
  expect(_snapEl(bar.element), <String, dynamic>{
    'tag': container['tag'],
    'classes': container['classes'],
    'attrs': container['attrs'],
    'style': container['style'],
    'childCount': (container['children'] as List<dynamic>).length,
  }, reason: 'container snapshot at $key');
  expect(_snapEl(bar.bit), <String, dynamic>{
    'tag': bit['tag'],
    'classes': bit['classes'],
    'attrs': bit['attrs'],
    'style': bit['style'],
    'childCount': (bit['children'] as List<dynamic>).length,
  }, reason: 'bit snapshot at $key');
  expect(bar.hasTotal(), t['hasTotal'], reason: 'hasTotal at $key');
  expect(bar.showDelayedScheduler.isScheduled(), t['showScheduled'],
      reason: 'showScheduled at $key');
  expect(bar.longRunningScheduler.isScheduled(), t['longScheduled'],
      reason: 'longScheduled at $key');
  expect(bar.longRunningScheduler.delay, t['longDelay'] ?? 10000,
      reason: 'longRunning delay at $key');
}

void main() {
  late AccessibilitySignalSchedulerFactory originalFactory;
  late ProgressBarTimeoutHandle Function(void Function(), int) originalTimeout;
  final List<_SpyDelegate> delegates = <_SpyDelegate>[];
  final List<ProgressBarTimeoutHandle> timeouts =
      <ProgressBarTimeoutHandle>[];

  setUp(() {
    originalFactory = progressAccessibilitySignalSchedulerFactory;
    originalTimeout = progressBarSetTimeout;
    delegates.clear();
    timeouts.clear();
    progressAccessibilitySignalSchedulerFactory =
        (int msDelayTime, [int? msLoopTime]) {
      final _SpyDelegate d = _SpyDelegate(msDelayTime, msLoopTime);
      delegates.add(d);
      return d;
    };
    progressBarSetTimeout = (void Function() callback, int ms) {
      final ProgressBarTimeoutHandle h = ProgressBarTimeoutHandle(callback, ms);
      timeouts.add(h);
      return h;
    };
  });

  tearDown(() {
    progressAccessibilitySignalSchedulerFactory = originalFactory;
    progressBarSetTimeout = originalTimeout;
  });

  test('exports and unthemed options', () {
    expect(truth['exports'], <dynamic>['ProgressBar', 'unthemedProgressBarOptions']);
    const IProgressBarOptions options = unthemedProgressBarOptions;
    expect(options.progressBarBackground, isNull);
    expect(options.ariaLabel, isNull);
  });

  test('initial/finite progress state machine matches runtime truth', () {
    final DomElement fixture = document.createElement('div');
    final ProgressBar bar = ProgressBar(fixture);
    expect(fixture.childNodes.length, 1);
    _expectSnap(bar, 'initialDefault');

    bar.infinite();
    _expectSnap(bar, 'afterInfinite');

    bar.longRunningScheduler.flush();
    _expectSnap(bar, 'afterLongRunning');

    bar.total(100);
    _expectSnap(bar, 'afterTotal');

    bar.worked(50);
    _expectSnap(bar, 'afterWorked50');

    bar.setWorked(70);
    _expectSnap(bar, 'afterSetWorked70');

    bar.worked(30);
    _expectSnap(bar, 'afterWorked30Capped');

    bar.worked('20');
    _expectSnap(bar, 'afterWorkedString');

    bar.setWorked(0);
    _expectSnap(bar, 'afterSetWorked0');

    bar.dispose();
  });

  test('done discrete and infinite defer off by 200ms', () {
    final DomElement fixture = document.createElement('div');
    final ProgressBar bar = ProgressBar(fixture);
    bar.infinite();
    bar.longRunningScheduler.flush();
    bar.total(100);
    bar.worked(1);

    bar.done();
    _expectSnap(bar, 'afterDoneDiscrete');
    expect(timeouts.last.ms,
        (truth['doneDiscreteTimeouts'] as List<dynamic>).single);
    timeouts.last.fire();
    _expectSnap(bar, 'afterDoneDiscreteTimeout');

    bar.total(100);
    bar.infinite();
    bar.done();
    _expectSnap(bar, 'afterDoneInfinite');
    expect(timeouts.last.ms,
        (truth['doneInfiniteTimeouts'] as List<dynamic>).single);
    timeouts.last.fire();
    _expectSnap(bar, 'afterDoneInfiniteTimeout');

    bar.total(100);
    bar.worked(70);
    bar.stop();
    _expectSnap(bar, 'afterStop');

    bar.dispose();
  });

  test('show/hide schedule, signal delegate and dispose match truth', () {
    final DomElement fixture = document.createElement('div');
    final ProgressBar bar = ProgressBar(fixture);
    bar.total(100);
    bar.worked(70);
    bar.stop();

    bar.show();
    _expectSnap(bar, 'afterShowImmediate');
    expect(delegates.length, 1);
    expect(delegates.single.msDelayTime, 3000);
    expect(delegates.single.msLoopTime, -1);

    bar.show(50);
    _expectSnap(bar, 'afterShowDelayed');
    expect(delegates.length, 2);

    bar.showDelayedScheduler.flush();
    _expectSnap(bar, 'afterShowDelayedFlush');
    expect(delegates.length, 2);

    bar.hide();
    _expectSnap(bar, 'afterHide');

    bar.dispose();
    expect(delegates.where((d) => d.disposeCount > 0).length,
        (truth['afterDispose']['signalDisposes'] as List<dynamic>).length);
  });

  test('custom options preserve untrimmed aria label', () {
    final DomElement fixture = document.createElement('div');
    final ProgressBar bar = ProgressBar(
      fixture,
      const IProgressBarOptions(
        ariaLabel: '  Custom label  ',
        progressBarBackground: '#abcdef',
      ),
    );
    _expectSnap(bar, 'initialCustom');
    bar.dispose();
  });
}
