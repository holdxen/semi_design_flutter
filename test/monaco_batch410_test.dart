// 1:1 replay of `editor/contrib/hover/browser/hoverOperation.ts`.
// Truth: `tool/ts2dart/_batch410_truth.cjs` -> `batch410_truth.json`.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/async.dart'
    show IAsyncIterable, IAsyncIterator, IteratorResult, RunOnceScheduler;
import '../lib/src/monaco/base/common/cancellation.dart' show CancellationToken;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/contrib/hover/browser/hoverOperation.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch410_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _Scheduler implements RunOnceScheduler {
  @override
  void Function()? runner;
  @override
  Timer? timeoutToken;
  @override
  int timeout;
  @override
  late final void Function() timeoutHandler;

  final List<int> delays = <int>[];
  int cancels = 0;

  _Scheduler(this.timeout);

  @override
  void schedule([int? newDelay]) {
    if (newDelay != null) timeout = newDelay;
    delays.add(timeout);
  }

  @override
  void cancel() => cancels++;

  @override
  void dispose() {}

  @override
  void onTimeout() => runner?.call();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  void fire() => runner?.call();
}

class _Editor {
  final int delay;
  _Editor(this.delay);
  Object getOption(Object id) =>
      id == EditorOption.hover ? _Hover(delay) : Object();
}

class _Hover {
  final int delay;
  _Hover(this.delay);
}

/// Async iterable that yields a fixed list then optionally waits for completion.
class _Items implements IAsyncIterable<String> {
  final List<String> items;
  final Completer<void>? gate;
  _Items(this.items, [this.gate]);

  @override
  IAsyncIterator<String> asyncIterator() => _Iterator(this);
}

class _Iterator implements IAsyncIterator<String> {
  final _Items source;
  int _index = 0;
  bool _gateAwaited = false;
  _Iterator(this.source);

  @override
  Future<IteratorResult<String>> next() async {
    if (_index < source.items.length) {
      final String value = source.items[_index++];
      await Future<void>.value();
      return IteratorResult<String>(false, value);
    }
    if (source.gate != null && !_gateAwaited) {
      _gateAwaited = true;
      await source.gate!.future;
    }
    return IteratorResult<String>(true, null);
  }

  @override
  Future<IteratorResult<String>>? throwError(Object e) => null;

  @override
  Future<IteratorResult<String>>? returnValue() => null;
}

class _Computer implements IHoverComputer<Map<String, Object?>, String> {
  final _Items? asyncItems;
  final List<String>? sync;
  _Computer(this.asyncItems, this.sync);

  @override
  IAsyncIterable<String>? computeAsync(
    Map<String, Object?> args,
    CancellationToken token,
  ) =>
      asyncItems;

  @override
  List<String>? computeSync(Map<String, Object?> args) => sync;
}

Future<void> _flush() async {
  for (int i = 0; i < 60; i++) {
    await Future<void>.value();
  }
  await Future<void>.delayed(Duration.zero);
}

Map<String, Object?> _resultJson(HoverResult<Map<String, Object?>, String> r) =>
    <String, Object?>{
      'value': r.value,
      'isComplete': r.isComplete,
      'hasLoadingMessage': r.hasLoadingMessage,
      'options': r.options,
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('hover operation replay TS truth', () async {
    final Map<String, Object?> actual = <String, Object?>{};

    // Case 1: delayed start, async completes.
    {
      final List<Map<String, Object?>> events = <Map<String, Object?>>[];
      final List<_Scheduler> schedulers = <_Scheduler>[];
      RunOnceScheduler factory(void Function() runner, int delay) {
        final _Scheduler s = _Scheduler(delay);
        s.runner = runner;
        schedulers.add(s);
        return s;
      }

      final HoverOperation<Map<String, Object?>, String> op =
          HoverOperation<Map<String, Object?>, String>(
        _Editor(300),
        _Computer(_Items(<String>['async1', 'async2']), <String>['sync1']),
        factory,
      );
      op.onResult((r) => events.add(_resultJson(r)));
      op.start(HoverStartMode.Delayed, <String, Object?>{'id': 1});
      actual['delayed'] = <String, Object?>{
        'afterStart': <String, Object?>{
          'delays': <Object?>[
            List<int>.from(schedulers[0].delays),
            List<int>.from(schedulers[1].delays),
            List<int>.from(schedulers[2].delays),
          ],
          'events': events.toList(),
          'options': op.options,
        },
      };
      schedulers[0].fire();
      await _flush();
      (actual['delayed'] as Map<String, Object?>)['afterAsync'] =
          <String, Object?>{
        'events': events.toList(),
        'options': op.options,
      };
      schedulers[1].fire();
      await _flush();
      (actual['delayed'] as Map<String, Object?>)['afterSync'] =
          <String, Object?>{
        'events': events.toList(),
        'options': op.options,
      };
      op.dispose();
    }

    // Case 2: immediate from idle.
    {
      final List<Map<String, Object?>> events = <Map<String, Object?>>[];
      final List<_Scheduler> schedulers = <_Scheduler>[];
      RunOnceScheduler factory(void Function() runner, int delay) {
        final _Scheduler s = _Scheduler(delay);
        s.runner = runner;
        schedulers.add(s);
        return s;
      }

      final HoverOperation<Map<String, Object?>, String> op =
          HoverOperation<Map<String, Object?>, String>(
        _Editor(300),
        _Computer(null, <String>['s']),
        factory,
      );
      op.onResult((r) => events.add(_resultJson(r)));
      op.start(HoverStartMode.Immediate, <String, Object?>{'id': 2});
      await _flush();
      actual['immediate-idle'] = <String, Object?>{
        'delays': <Object?>[
          schedulers[0].delays,
          schedulers[1].delays,
          schedulers[2].delays,
        ],
        'cancels': <Object?>[
          schedulers[0].cancels,
          schedulers[1].cancels,
          schedulers[2].cancels,
        ],
        'events': events.toList(),
        'options': op.options,
      };
      op.dispose();
    }

    // Case 3: immediate from SecondWait.
    {
      final List<Map<String, Object?>> events = <Map<String, Object?>>[];
      final List<_Scheduler> schedulers = <_Scheduler>[];
      RunOnceScheduler factory(void Function() runner, int delay) {
        final _Scheduler s = _Scheduler(delay);
        s.runner = runner;
        schedulers.add(s);
        return s;
      }

      final HoverOperation<Map<String, Object?>, String> op =
          HoverOperation<Map<String, Object?>, String>(
        _Editor(300),
        _Computer(_Items(<String>['a']), <String>['s']),
        factory,
      );
      op.onResult((r) => events.add(_resultJson(r)));
      op.start(HoverStartMode.Delayed, <String, Object?>{'id': 3});
      schedulers[0].fire();
      await _flush();
      final List<Map<String, Object?>> before = events.toList();
      op.start(HoverStartMode.Immediate, <String, Object?>{'id': 3});
      await _flush();
      actual['immediate-second-wait'] = <String, Object?>{
        'beforeSecond': before,
        'afterSecond': events.toList(),
        'syncCancels': schedulers[1].cancels,
      };
      op.dispose();
    }

    // Case 4: loading message.
    {
      final List<Map<String, Object?>> events = <Map<String, Object?>>[];
      final List<_Scheduler> schedulers = <_Scheduler>[];
      RunOnceScheduler factory(void Function() runner, int delay) {
        final _Scheduler s = _Scheduler(delay);
        s.runner = runner;
        schedulers.add(s);
        return s;
      }

      final Completer<void> gate = Completer<void>();
      final HoverOperation<Map<String, Object?>, String> op =
          HoverOperation<Map<String, Object?>, String>(
        _Editor(300),
        _Computer(_Items(<String>['a'], gate), <String>['s']),
        factory,
      );
      op.onResult((r) => events.add(_resultJson(r)));
      op.start(HoverStartMode.Delayed, <String, Object?>{'id': 4});
      schedulers[0].fire();
      await _flush();
      schedulers[1].fire();
      await _flush();
      final List<Map<String, Object?>> beforeLoading = events.toList();
      schedulers[2].fire();
      await _flush();
      final List<Map<String, Object?>> afterLoading = events.toList();
      gate.complete();
      await _flush();
      actual['loading'] = <String, Object?>{
        'beforeLoading': beforeLoading,
        'afterLoading': afterLoading,
        'afterComplete': events.toList(),
      };
      op.dispose();
    }

    // Case 5: cancel after delayed start.
    {
      final List<Map<String, Object?>> events = <Map<String, Object?>>[];
      final List<_Scheduler> schedulers = <_Scheduler>[];
      RunOnceScheduler factory(void Function() runner, int delay) {
        final _Scheduler s = _Scheduler(delay);
        s.runner = runner;
        schedulers.add(s);
        return s;
      }

      final HoverOperation<Map<String, Object?>, String> op =
          HoverOperation<Map<String, Object?>, String>(
        _Editor(300),
        _Computer(null, <String>['s']),
        factory,
      );
      op.onResult((r) => events.add(_resultJson(r)));
      op.start(HoverStartMode.Delayed, <String, Object?>{'id': 5});
      op.cancel();
      actual['cancel'] = <String, Object?>{
        'events': events.toList(),
        'cancels': <Object?>[
          schedulers[0].cancels,
          schedulers[1].cancels,
          schedulers[2].cancels,
        ],
      };
      op.dispose();
    }

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
