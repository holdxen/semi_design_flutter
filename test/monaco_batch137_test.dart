// Truth-driven tests for batch137: editor/browser/gpu/taskQueue.ts
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/taskQueue.dart'
    as q;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;

final Map<String, Object?> _truth =
    jsonDecode(File('tool/ts2dart/batch137_truth.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _section(String key) =>
    _truth[key] as Map<String, Object?>;

List<Object?> _list(Object? value) => (value as List).cast<Object?>();

class _RecordingLogService extends log.NullLogService {
  final List<String> warnings = <String>[];

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    warnings.add(message.toString());
  }
}

class _SteppingDeadline implements q.ITaskDeadline {
  _SteppingDeadline(this._values);

  final List<num> _values;
  int _i = 0;

  @override
  num timeRemaining() => _values[_i++];
}

void main() {
  late int seq;
  late Map<int, void Function()> timers;
  late Map<int, q.CallbackWithDeadline> idles;
  late List<int> cancelled;
  late List<int> idleCancelled;
  late _RecordingLogService logger;
  late int now;

  setUp(() {
    seq = 0;
    timers = <int, void Function()>{};
    idles = <int, q.CallbackWithDeadline>{};
    cancelled = <int>[];
    idleCancelled = <int>[];
    logger = _RecordingLogService();
    now = 1000;

    final q.TaskQueueEnvironment env = q.taskQueueEnvironment;
    env.setTimeout = (void Function() cb) {
      final int id = ++seq;
      timers[id] = cb;
      return id;
    };
    env.clearTimeout = (int id) {
      timers.remove(id);
      cancelled.add(id);
    };
    env.requestIdleCallback = null;
    env.cancelIdleCallback = null;
    env.now = () => now;
  });

  q.PriorityTaskQueue newPriority() => q.PriorityTaskQueue(logger);

  test('priority queue schedules then flushes', () {
    final q.PriorityTaskQueue queue = newPriority();
    final List<String> calls = <String>[];
    queue.enqueue(() {
      calls.add('a');
      return false;
    });
    queue.enqueue(() {
      calls.add('b');
      return false;
    });
    final Map<String, Object?> scheduled = _section('priorityScheduled');
    expect(timers.length, scheduled['timers']);
    expect(calls, _list(scheduled['calls']));
    queue.flush();
    final Map<String, Object?> flushed = _section('priorityFlush');
    expect(calls, _list(flushed['calls']));
    expect(timers.length, flushed['timers']);
  });

  test('flush repeats truthy tasks', () {
    final q.PriorityTaskQueue queue = newPriority();
    final List<String> calls = <String>[];
    queue.enqueue(() {
      calls.add('x');
      return calls.length < 4;
    });
    queue.flush();
    expect(calls, _list(_section('priorityRepeat')['calls']));
  });

  test('clear cancels pending callback and drops tasks', () {
    final List<String> calls = <String>[];
    final q.PriorityTaskQueue first = newPriority();
    first.enqueue(() { calls.add('a'); return false; });
    first.flush();
    final q.PriorityTaskQueue second = newPriority();
    second.enqueue(() { calls.add('b'); return false; });
    second.flush();
    final q.PriorityTaskQueue third = newPriority();
    third.enqueue(() { calls.add('c'); return false; });
    third.clear();
    third.flush();
    final Map<String, Object?> e = _section('priorityClear');
    expect(calls.where((String x) => x == 'c').toList(), _list(e['calls']));
    expect(cancelled, _list(e['cancelled']));
  });

  test('deadline overrun warns and reschedules', () {
    final q.PriorityTaskQueue queue = newPriority();
    final List<String> calls = <String>[];
    queue.enqueue(() {
      calls.add('slow');
      now += 134;
      return false;
    });
    q.taskQueueEnvironment.createDeadline =
        (int duration) => _SteppingDeadline(<num>[50, 49]);
    final int id = timers.keys.first;
    timers[id]!();
    final Map<String, Object?> e = _section('deadlineYield');
    expect(calls, _list(e['calls']));
    expect(logger.warnings, _list(e['logs']));
    expect(timers.length, e['timersAfter']);
  });

  test('idle queue uses requestIdleCallback', () {
    q.taskQueueEnvironment.requestIdleCallback = (q.CallbackWithDeadline cb) {
      final int id = ++seq;
      idles[id] = cb;
      return id;
    };
    q.taskQueueEnvironment.cancelIdleCallback = (int id) {
      idles.remove(id);
      idleCancelled.add(id);
    };
    final q.IdleTaskQueue queue = q.IdleTaskQueue(logger);
    final List<String> calls = <String>[];
    queue.enqueue(() {
      calls.add('idle');
      return false;
    });
    final Map<String, Object?> scheduled = _section('idleScheduled');
    expect(idles.length, scheduled['idles']);
    expect(timers.length, scheduled['timers']);
    final int id = idles.keys.first;
    idles[id]!(_SteppingDeadline(<num>[50, 49]));
    expect(calls, _list(_section('idleRun')['calls']));

    final q.IdleTaskQueue queue2 = q.IdleTaskQueue(logger);
    queue2.enqueue(() => false);
    queue2.clear();
    expect(idleCancelled, _list(_section('idleClear')['cancelled']));
  });

  test('debounced idle task keeps only latest', () {
    q.taskQueueEnvironment.requestIdleCallback = (q.CallbackWithDeadline cb) {
      final int id = ++seq;
      idles[id] = cb;
      return id;
    };
    q.taskQueueEnvironment.cancelIdleCallback = (int id) {
      idles.remove(id);
      idleCancelled.add(id);
    };
    final q.DebouncedIdleTask debounced =
        q.DebouncedIdleTask(q.TaskInstantiationService(logger));
    final List<String> calls = <String>[];
    debounced.set(() {
      calls.add('first');
      return false;
    });
    debounced.set(() {
      calls.add('second');
      return false;
    });
    final List<String> ids =
        idles.keys.map((int x) => x.toString()).toList(growable: false);
    for (final int id in idles.keys.toList(growable: false)) {
      idles[id]!(_SteppingDeadline(<num>[50, 49]));
    }
    final Map<String, Object?> e = _section('debounced');
    expect(calls, _list(e['calls']));
    expect(ids, _list(e['ids']));
  });
}
