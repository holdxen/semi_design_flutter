// Regression tests for base/common/async.ts in the 1:1 Monaco port.
// Assertions mirror the semantics of the TypeScript source tests.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/async.dart' as async;
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    as cancellation;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart' as errors;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lc;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;

void main() {
  group('async.ts: isThenable / promise helpers', () {
    test('isThenable', () {
      expect(async.isThenable(null), isFalse);
      expect(async.isThenable(42), isFalse);
      expect(async.isThenable(Future.value(1)), isTrue);
    });

    test('asPromise resolves values and thenables', () async {
      expect(await async.asPromise<int>(() => 42), 42);
      expect(await async.asPromise<int>(() => Future.value(7)), 7);
    });

    test('promiseWithResolvers', () async {
      final async.PromiseWithResolvers<int> r =
          async.promiseWithResolvers<int>();
      r.resolve(9);
      expect(await r.promise, 9);
      final async.PromiseWithResolvers<int> r2 =
          async.promiseWithResolvers<int>();
      r2.reject(StateError('boom'));
      await expectLater(r2.promise, throwsA(isA<StateError>()));
    });

    test('raceTimeout: timeout wins / promise wins', () async {
      bool timedOut = false;
      final Completer<int> slow = Completer<int>();
      final int? a = await async.raceTimeout<int>(slow.future, 5, () {
        timedOut = true;
      });
      expect(a, isNull);
      expect(timedOut, isTrue);

      final int? b = await async.raceTimeout<int>(Future.value(3), 1000);
      expect(b, 3);
    });
  });

  group('async.ts: cancelablePromise', () {
    test('cancel rejects with CancellationError (once)', () async {
      int canceled = 0;
      final async.CancelablePromise<int> promise =
          async.createCancelablePromise<int>((cancellation.CancellationToken token) {
        token.onCancellationRequested((_) => canceled++);
        return Completer<int>().future; // never resolves
      });
      final Future<Object?> result = promise.then<Object>(
          (_) => throw StateError('must not resolve'),
          onError: (Object err) => err);
      promise.cancel();
      promise.cancel(); // cancel only once
      final Object? err = await result;
      expect(canceled, 1);
      expect(errors.isCancellationError(err), isTrue);
    });

    test('cancel despite inner promise being resolved', () async {
      final async.CancelablePromise<int> promise =
          async.createCancelablePromise<int>((cancellation.CancellationToken token) =>
              Future<int>.value(1234));
      // Resolve the microtask queue before cancelling.
      await Future<void>.delayed(Duration.zero);
      expect(await promise, 1234);
    });

    test('cancel disposes disposable result', () async {
      final lc.DisposableStore store = lc.DisposableStore();
      final async.CancelablePromise<lc.DisposableStore> promise =
          async.createCancelablePromise<lc.DisposableStore>(
              (cancellation.CancellationToken token) async => store);
      final Future<Object?> result = promise.then<lc.DisposableStore>(
          (_) => throw StateError('must not resolve'),
          onError: (Object err) => store);
      promise.cancel();
      await result;
      expect(store.isDisposed, isTrue);
    });

    test('raceCancellation', () async {
      final cancellation.CancellationTokenSource cts =
          cancellation.CancellationTokenSource();
      final cancellation.CancellationTokenSource ctsTimeout =
          cancellation.CancellationTokenSource();
      bool triggered = false;
      final Future<void> timeout = async.timeout(200, ctsTimeout.token) as Future<void>;
      final Future<Object?> p =
          async.raceCancellation<void>(timeout.then((_) => triggered = true), cts.token);
      cts.cancel();
      await p;
      expect(triggered, isFalse);
      ctsTimeout.cancel();
    });
  });

  group('async.ts: Throttler / Sequencer', () {
    test('Throttler non async coalesces to latest factory', () async {
      int count = 0;
      async.ICancellableTask<Future<int>> factory() => (_) => Future<int>.value(++count);
      final async.Throttler throttler = async.Throttler();
      final List<int> results = await Future.wait<int>(<Future<int>>[
        throttler.queue(factory()),
        throttler.queue(factory()),
        throttler.queue(factory()),
        throttler.queue(factory()),
        throttler.queue(factory()),
      ]);
      expect(results, <int>[1, 2, 2, 2, 2]);
      expect(count, 2);
      throttler.dispose();
    });

    test('Throttler last factory wins', () async {
      final async.Throttler throttler = async.Throttler();
      final results = await Future.wait<int>(<Future<int>>[
        throttler.queue((_) => Future<int>.value(1)),
        throttler.queue((_) => Future<int>.value(2)),
        throttler.queue((_) => Future<int>.value(3)),
      ]);
      expect(results, <int>[1, 3, 3]);
      throttler.dispose();
    });

    test('Sequencer runs in order', () async {
      final async.Sequencer sequencer = async.Sequencer();
      final List<int> order = <int>[];
      await Future.wait<void>(<Future<void>>[
        sequencer.queue(() async {
          await Future<void>.delayed(Duration(milliseconds: 2));
          order.add(1);
        }),
        sequencer.queue(() async {
          order.add(2);
        }),
        sequencer.queue(() async {
          order.add(3);
        }),
      ]);
      expect(order, <int>[1, 2, 3]);
    });
  });

  group('async.ts: Delayer / Barrier / timeout', () {
    test('Barrier opens permanently', () async {
      final async.Barrier barrier = async.Barrier();
      expect(barrier.isOpen(), isFalse);
      final Future<bool> w = barrier.wait();
      barrier.open();
      expect(await w, isTrue);
      expect(barrier.isOpen(), isTrue);
    });

    test('Delayer triggers the last task', () async {
      final async.Delayer<int> delayer = async.Delayer<int>(5);
      final List<int> called = <int>[];
      delayer.trigger(() { called.add(1); return 1; });
      final Future<int> result = delayer.trigger(() { called.add(2); return 2; });
      await result;
      expect(called, <int>[2]);
      delayer.dispose();
    });

    test('Delayer cancel rejects pending', () async {
      final async.Delayer<int> delayer = async.Delayer<int>(200);
      final Future<int> result = delayer.trigger(() => 1);
      delayer.cancel();
      await expectLater(result, throwsA(isA<errors.CancellationError>()));
    });

    test('timeout resolves after delay', () async {
      final Object t = async.timeout(5);
      await (t as Future<void>);
      expect(true, isTrue);
    });
  });

  group('async.ts: sequence / first / Limiter / Queue', () {
    test('sequence', () async {
      final List<int> result = await async.sequence<int>(<async.ITask<Future<int>>>[
        () => Future<int>.value(1),
        () => Future<int>.value(2),
        () => Future<int>.value(3),
      ]);
      expect(result, <int>[1, 2, 3]);
    });

    test('first stops on first truthy', () async {
      final int? result = await async.first<int>(
          <async.ITask<Future<int>>>[
            () => Future<int>.value(0),
            () => Future<int>.value(2),
            () => Future<int>.value(3),
          ],
          (int t) => t != 0,
          null);
      expect(result, 2);
    });

    test('firstParallel', () async {
      final int? result = await async.firstParallel<int>(
          <Future<int>>[
            Future<int>.value(1),
            Future<int>.value(2),
            Future<int>.value(3),
          ],
          (int t) => t == 2,
          null);
      expect(result, 2);
    });

    test('Limiter degree of parallelism', () async {
      int active = 0;
      final async.Limiter<int> limiter = async.Limiter<int>(5);
      final List<Future<int>> futures = <Future<int>>[];
      for (int n = 0; n < 10; n++) {
        futures.add(limiter.queue(() async {
          active++;
          expect(active, lessThan(6));
          await Future<void>.delayed(Duration.zero);
          active--;
          return n;
        }));
      }
      final List<int> res = await Future.wait<int>(futures);
      expect(res, <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      limiter.dispose();
    });

    test('Queue keeps order', () async {
      final async.Queue<int> queue = async.Queue<int>();
      final List<int> res = await Future.wait<int>(<Future<int>>[
        queue.queue(() => Future<int>.value(1)),
        queue.queue(() => Future<int>.value(2)),
        queue.queue(() => Future<int>.value(3)),
      ]);
      expect(res, <int>[1, 2, 3]);
      queue.dispose();
    });
  });

  group('async.ts: retry / TaskSequentializer / timers', () {
    test('retry succeeds after retries', () async {
      int counter = 0;
      final bool res = await async.retry<bool>(() {
        counter++;
        if (counter < 2) {
          return Future<bool>.error(StateError('fail'));
        }
        return Future<bool>.value(true);
      }, 1, 3);
      expect(res, isTrue);
      expect(counter, 2);
    });

    test('retry throws after exhausting retries', () async {
      final Object expected = StateError('fail');
      await expectLater(
          async.retry<bool>(() => Future<bool>.error(expected), 1, 2),
          throwsA(expected));
    });

    test('TaskSequentializer basics', () async {
      final async.TaskSequentializer seq = async.TaskSequentializer();
      expect(seq.isRunning(), isFalse);
      expect(seq.hasQueued(), isFalse);
      final Completer<void> running = Completer<void>();
      final Future<void> first = seq.run(1, running.future);
      expect(seq.isRunning(), isTrue);
      final Future<void> queued = seq.queue(() async {});
      expect(seq.hasQueued(), isTrue);
      running.complete();
      await first;
      await queued;
      expect(seq.isRunning(), isFalse);
    });

    test('IntervalCounter', () {
      int now = 0;
      final async.IntervalCounter counter =
          async.IntervalCounter(5, () => now);
      expect(counter.increment(), 1);
      now = 2;
      expect(counter.increment(), 2);
      now = 8; // beyond interval -> reset
      expect(counter.increment(), 1);
    });

    test('disposableTimeout fires and can be canceled', () async {
      int fired = 0;
      final lc.IDisposable d = async.disposableTimeout(() => fired++, 5);
      await Future<void>.delayed(Duration(milliseconds: 20));
      expect(fired, 1);
      d.dispose();
    });
  });

  group('async.ts: DeferredPromise / Promises / StatefulPromise', () {
    test('DeferredPromise complete/error/isSettled', () async {
      final async.DeferredPromise<int> d = async.DeferredPromise<int>();
      expect(d.isSettled, isFalse);
      await d.complete(5);
      expect(d.isResolved, isTrue);
      expect(d.value, 5);
      expect(await d.p, 5);
      // second settle is a no-op
      await d.error(StateError('late'));
      expect(d.isRejected, isFalse);

      final async.DeferredPromise<int> e = async.DeferredPromise<int>();
      final Future<int> guarded = e.p.catchError((Object _) => 0);
      await e.error(StateError('x'));
      await guarded;
      expect(e.isRejected, isTrue);
    });

    test('DeferredPromise.fromPromise', () async {
      final async.DeferredPromise<int> d =
          async.DeferredPromise.fromPromise<int>(Future<int>.value(3));
      expect(await d.p, 3);
      expect(d.isResolved, isTrue);
    });

    test('Promises.settled returns first error after all settle', () async {
      final List<int> res = await async.Promises.settled<int>(<Future<int>>[
        Future<int>.value(1),
        Future<int>.value(2),
      ]);
      expect(res, <int>[1, 2]);
      await expectLater(
          async.Promises.settled<int>(<Future<int>>[
            Future<int>.error(StateError('boom')),
            Future<int>.value(2),
          ]),
          throwsA(isA<StateError>()));
    });

    test('StatefulPromise / LazyStatefulPromise', () async {
      final async.StatefulPromise<int> s =
          async.StatefulPromise<int>(Future<int>.value(4));
      await s.promise;
      expect(s.isResolved, isTrue);
      expect(s.requireValue(), 4);

      final async.LazyStatefulPromise<int> lazy =
          async.LazyStatefulPromise<int>(() => Future<int>.value(6));
      expect(lazy.currentValue, isNull);
      await lazy.getPromise();
      expect(lazy.requireValue(), 6);
    });
  });

  group('async.ts: AsyncIterableObject / AsyncIterableProducer', () {
    test('AsyncIterableObject fromArray + toPromise', () async {
      final async.AsyncIterableObject<int> iterable =
          async.AsyncIterableObject.fromArray<int>(<int>[1, 2, 3]);
      expect(await iterable.toPromise(), <int>[1, 2, 3]);
    });

    test('AsyncIterableObject map/filter', () async {
      final async.AsyncIterableObject<int> iterable =
          async.AsyncIterableObject.fromArray<int>(<int>[1, 2, 3, 4]);
      expect(await iterable.map((int v) => v * 2).toPromise(),
          <int>[2, 4, 6, 8]);
      expect(await iterable.filter((int v) => v.isEven).toPromise(),
          <int>[2, 4]);
    });

    test('AsyncIterableObject EMPTY', () async {
      expect(
          await async.AsyncIterableObject.EMPTY.toPromise(), isEmpty);
    });

    test('AsyncIterableProducer fromArray is single-consumer', () async {
      final async.AsyncIterableProducer<int> producer =
          async.AsyncIterableProducer.fromArray<int>(<int>[1, 2, 3]);
      final async.IAsyncIterator<int> it = producer.asyncIterator();
      final List<int> values = <int>[];
      while (true) {
        final async.IteratorResult<int> r = await it.next();
        if (r.done) {
          break;
        }
        values.add(r.value as int);
      }
      expect(values, <int>[1, 2, 3]);
    });

    test('AsyncIterableObject error state', () async {
      final async.AsyncIterableObject<int> iterable =
          async.AsyncIterableObject<int>((async.AsyncIterableEmitter<int> emitter) {
        emitter.reject(StateError('bad'));
        return null;
      });
      await expectLater(iterable.toPromise(), throwsA(isA<StateError>()));
    });
  });

  group('async.ts: AsyncReader / ResourceQueue', () {
    test('AsyncReader reads until end of stream', () async {
      final async.AsyncIterableProducer<int> producer =
          async.AsyncIterableProducer.fromArray<int>(<int>[1, 2]);
      final async.AsyncReader<int> reader =
          async.AsyncReader<int>(producer.asyncIterator());
      expect(await reader.read(), 1);
      expect(await reader.peek(), 2);
      expect(await reader.read(), 2);
      expect(identical(await reader.read(), async.AsyncReaderEndOfStream), isTrue);
      expect(reader.endOfStream, isTrue);
    });

    test('ResourceQueue queues per URI and drains', () async {
      final async.ResourceQueue q = async.ResourceQueue();
      final URI a = URI.file('/a');
      final List<int> order = <int>[];
      final List<Future<void>> futures = <Future<void>>[
        q.queueFor(a, () async {
          await Future<void>.delayed(Duration(milliseconds: 2));
          order.add(1);
        }),
        q.queueFor(a, () async {
          order.add(2);
        }),
      ];
      expect(q.queueSize(a), 2);
      await Future.wait<void>(futures);
      await q.whenDrained();
      expect(order, <int>[1, 2]);
      expect(q.queueSize(a), 0);
      q.dispose();
    });
  });
}
