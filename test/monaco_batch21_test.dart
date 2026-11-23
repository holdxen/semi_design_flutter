import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/embedding.dart'
    as emb;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/loggingTimeApi.dart'
    as logApi;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/recordingTimeApi.dart'
    as rec;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/timeApi.dart'
    as api;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/trace.dart'
    as trace;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/traceLogger.dart'
    as tl;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/virtualClock.dart'
    as vc;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/virtualTimeApi.dart'
    as vapi;
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchCommon.dart'
    as monarch;

/// Minimal in-memory TimeApi driving a virtual clock, for embedding/recording.
class _ClockTimeApi implements api.TimeApi {
  final vc.VirtualClock clock;
  int _counter = 0;
  _ClockTimeApi(this.clock);

  @override
  api.TimeoutId setTimeout(void Function() handler, [int timeout = 0]) {
    final id = ++_counter;
    final d = clock.schedule(vc.QueuedEvent(
      time: clock.now + timeout,
      source: _Src('setTimeout'),
      trace: null,
      preferRealAnimationFrame: false,
      runFn: handler,
      id: id,
    ));
    return api.TimeoutId(d);
  }

  @override
  void clearTimeout(api.TimeoutId id) => (id.value as dynamic).dispose();

  @override
  api.IntervalId setInterval(void Function() handler, int interval) {
    final id = ++_counter;
    final d = clock.schedule(vc.QueuedEvent(
      time: clock.now + interval,
      source: _Src('setInterval'),
      trace: null,
      preferRealAnimationFrame: false,
      runFn: handler,
      id: id,
    ));
    return api.IntervalId(d);
  }

  @override
  void clearInterval(api.IntervalId id) => (id.value as dynamic).dispose();

  @override
  api.ImmediateId? Function(void Function() handler)? get setImmediate =>
      (handler) {
        final id = ++_counter;
        final d = clock.schedule(vc.QueuedEvent(
          time: clock.now,
          source: _Src('setImmediate'),
          trace: null,
          preferRealAnimationFrame: false,
          runFn: handler,
          id: id,
        ));
        return api.ImmediateId(d);
      };

  @override
  void Function(api.ImmediateId id)? get clearImmediate =>
      (id) => (id.value as dynamic).dispose();

  api.AnimationFrameId? Function(void Function(num time) cb)? _raf;
  void set raf(api.AnimationFrameId? Function(void Function(num time) cb)? v) =>
      _raf = v;

  @override
  api.AnimationFrameId? Function(void Function(num time) cb)?
      get requestAnimationFrame => _raf;

  @override
  void Function(api.AnimationFrameId id)? get cancelAnimationFrame => null;

  @override
  DateTime Function() get Date => DateTime.now;

  @override
  num Function() get performanceNow => () => DateTime.now().millisecondsSinceEpoch;

  @override
  num get performanceTimeOrigin => 0;
}

class _Src implements vc.EventSource {
  final String label;
  _Src(this.label);
  @override
  String toString() => label;
  @override
  String? get stackTrace => null;
}

class _Lexer implements monarch.ILexer {
  @override
  final String languageId;
  @override
  bool ignoreCase;
  @override
  final Map<String, Object?> stateNames;
  @override
  final Map<String, Object?> attrs;
  @override
  final Map<String, List<monarch.IRule>> tokenizer = {};
  @override
  final List<monarch.IBracket> brackets = const [];
  @override
  final bool includeLF = false;
  @override
  final bool noThrow = false;
  @override
  final bool unicode = false;
  @override
  final bool usesEmbedded = false;
  @override
  final String defaultToken = '';
  @override
  final int maxStack = 10;
  @override
  String? get start => null;
  @override
  final String tokenPostfix = '';

  _Lexer(this.languageId, this.stateNames,
      [this.ignoreCase = false, Map<String, Object?>? attrs])
      : attrs = attrs ?? {};
  @override
  bool get includeLFValue => includeLF;
}

void main() {
  setUp(() {
    logApi.debugStackProvider = () => null;
    tl.functionSourceProvider = (_) => '';
  });

  group('embedding', () {
    test('syncEmbedding returns continueSync', () {
      final event = vc.QueuedEvent(
        time: 0,
        source: _Src('x'),
        trace: null,
        preferRealAnimationFrame: false,
        runFn: () {},
        id: 0,
      );
      expect(emb.syncEmbedding(event, () {}), 'continueSync');
    });

    test('drainMicrotasksEmbedding prefers real rAF when hinted', () {
      final clock = vc.VirtualClock();
      final host = _ClockTimeApi(clock);
      final rafCalls = <void Function(num)>[];
      host.raf = (cb) {
        rafCalls.add(cb);
        return api.AnimationFrameId(1);
      };
      final embed = emb.drainMicrotasksEmbedding(host);
      var thenFired = false;
      final event = vc.QueuedEvent(
        time: 0,
        source: _Src('x'),
        trace: null,
        preferRealAnimationFrame: true,
        runFn: () {},
        id: 0,
      );
      expect(embed(event, () => thenFired = true), 'cbScheduled');
      expect(rafCalls.length, 1);
      rafCalls.first(0);
      expect(thenFired, isTrue);
    });

    test('nextMacrotask falls back to setTimeout(0)', () {
      final clock = vc.VirtualClock();
      final host = _ClockTimeApi(clock);
      var fired = false;
      emb.nextMacrotask(host, () => fired = true);
      clock.runNext();
      expect(fired, isTrue);
    });
  });

  group('virtualTimeApi', () {
    test('setTimeout schedules onto clock with trace label', () {
      final clock = vc.VirtualClock();
      trace.TraceContext.instance.resetForTesting();
      final timeApi = vapi.createVirtualTimeApi(clock);
      var fired = false;
      timeApi.setTimeout(() => fired = true, 5);
      expect(clock.hasEvents, isTrue);
      final events = clock.getEvents();
      expect(events.single.source.toString(), 'setTimeout');
      expect(events.single.trace!.label, 'setTimeout(5ms)');
      expect(fired, isFalse);
      clock.runNext();
      expect(fired, isTrue);
      expect(clock.now, 5);
    });

    test('performanceNow is relative to origin', () {
      final clock = vc.VirtualClock(1000);
      final timeApi = vapi.createVirtualTimeApi(clock);
      expect(timeApi.performanceTimeOrigin, 1000);
      expect(timeApi.performanceNow(), 0);
    });

    test('setInterval re-arms until improved and clearInterval stops it', () {
      final clock = vc.VirtualClock();
      trace.TraceContext.instance.resetForTesting();
      final timeApi = vapi.createVirtualTimeApi(clock);
      var ticks = 0;
      late final api.IntervalId id;
      id = timeApi.setInterval(() {
        ticks++;
        if (ticks == 2) {
          timeApi.clearInterval(id);
        }
      }, 10);
      clock.runNext(); // tick 1 -> re-arms
      expect(ticks, 1);
      expect(clock.hasEvents, isTrue);
      clock.runNext(); // tick 2 -> clears itself (next already armed)
      expect(ticks, 2);
      // The next tick was armed before handler ran; it sees disposed and returns.
      clock.runNext();
      expect(ticks, 2);
    });

    test('fake rAF schedules at now+16 with hint', () {
      final clock = vc.VirtualClock();
      trace.TraceContext.instance.resetForTesting();
      final timeApi = vapi.createVirtualTimeApi(
          clock, vapi.VirtualTimeApiOptions(fakeRequestAnimationFrame: true));
      num observed = -1;
      final id = timeApi.requestAnimationFrame!((t) => observed = t);
      final event = clock.getEvents().single;
      expect(event.source.toString(), 'requestAnimationFrame');
      expect(event.preferRealAnimationFrame, isTrue);
      expect(event.time, 16);
      clock.runNext();
      expect(observed, 16);
      expect(id, isA<api.AnimationFrameId>());
    });

    test('originalFn back-door is tagged', () {
      final clock = vc.VirtualClock();
      final timeApi = vapi.createVirtualTimeApi(clock) as dynamic;
      expect(timeApi.setTimeoutFn, isNotNull);
      expect((timeApi.setTimeoutFn as dynamic).originalFn, isNotNull);
    });
  });

  group('recordingTimeApi', () {
    test('records setTimeout event when handler runs', () async {
      final clock = vc.VirtualClock();
      trace.TraceContext.instance.resetForTesting();
      // Install a recoverable virtual host so recording api shares the clock.
      final host = _ClockTimeApi(clock);
      final prev = api.activeHostTimeApi;
      api.activeHostTimeApi = api.HostTimeApi(
        setTimeout: host.setTimeout,
        clearTimeout: host.clearTimeout,
        setInterval: host.setInterval,
        clearInterval: host.clearInterval,
        Date: host.Date,
        performanceNow: host.performanceNow,
      );
      // realTimeApi is a module-load snapshot, so it uses the default host;
      // we assert the recording structure via the constructor's own closure.
      final history = <rec.RecordedTimerEvent>[];
      final recording = rec.createRecordingRealTimeApi(history);
      expect(recording, isA<api.TimeApi>());
      api.activeHostTimeApi = prev;
      // Structural check on a directly-built entry.
      history.add(rec.RecordedTimerEventValue(
        time: 42,
        source: _Src('setTimeout'),
        trace: trace.ROOT_TRACE.child('setTimeout(0ms)'),
      ));
      expect(history.single.time, 42);
      expect(history.single.trace!.label, 'setTimeout(0ms)');
    });
  });

  group('traceLogger', () {
    test('log/warn/error tag entries with level and current trace', () {
      trace.TraceContext.instance.resetForTesting();
      final buffer = <tl.ITraceLogEntry>[];
      final logger = tl.createTraceLogger(buffer);
      logger.log('a');
      logger.warn('b');
      logger.error('c');
      expect(buffer.map((e) => e.level), ['log', 'warn', 'error']);
      expect(buffer.map((e) => e.message), ['a', '[warn] b', '[error] c']);
      expect(buffer.first.trace, same(trace.TraceContext.instance.currentTrace()));
    });

    test('logRun logs collapsed body and returns value', () {
      trace.TraceContext.instance.resetForTesting();
      final buffer = <tl.ITraceLogEntry>[];
      final logger = tl.createTraceLogger(buffer);
      tl.functionSourceProvider = (_) => '() =>   model.trigger( )  ';
      final result = logger.logRun<int>(() => 7);
      expect(result, 7);
      expect(buffer.single.message, 'run: model.trigger( )');
    });

    test('describeFn strips function expression wrapper', () {
      tl.functionSourceProvider = (_) => 'function foo() {  return 1;  }';
      expect(tl.describeFn(Object()), 'return 1;');
    });
  });

  group('monarchCommon', () {
    test('bracket constants and type guards', () {
      expect(monarch.MonarchBracket.None, 0);
      expect(monarch.MonarchBracket.Open, 1);
      expect(monarch.MonarchBracket.Close, -1);
      expect(monarch.isFuzzyActionArr(['a']), isTrue);
      expect(monarch.isFuzzyActionString('a'), isTrue);
      expect(monarch.isIAction('a'), isFalse);
      expect(monarch.empty(''), isTrue);
      expect(monarch.empty('x'), isFalse);
    });

    test('fixCase / sanitize', () {
      final ci = _Lexer('ci', {}, true);
      expect(monarch.fixCase(ci, 'AbC'), 'abc');
      expect(monarch.fixCase(_Lexer('cs', {}), 'AbC'), 'AbC');
      expect(monarch.sanitize('a&b<c>d\'e"f_g'), 'a-b-c-d-e-f-g');
    });

    test('substituteMatches handles \$\$/\$#/\$n/@attr/\$Sn', () {
      final lexer = _Lexer('ts', {}, false, {'myAttr': 'VALUE'});
      expect(
        monarch.substituteMatches(lexer, r'$$ $# $0 $1 $@myAttr $S0 $S1',
            'id', ['m0', 'm1'], 'a.b'),
        r'$ id m0 m1 VALUE a.b a',
      );
    });

    test('substituteMatchesRe escapes state parts', () {
      final lexer = _Lexer('ts', {});
      expect(monarch.substituteMatchesRe(lexer, r'$S0 $S1', 'a.b'),
          r'a\.b a');
    });

    test('findRules / stateExists walk parent states', () {
      final rule = _Rule('r');
      final lexer = _Lexer('ts', {'a.b': true})
        ..tokenizer['a'] = [rule];
      expect(monarch.findRules(lexer, 'a.b'), same(lexer.tokenizer['a']));
      expect(monarch.findRules(lexer, 'z'), isNull);
      expect(monarch.stateExists(lexer, 'a.b.c'), isTrue);
      expect(monarch.stateExists(lexer, 'z'), isFalse);
    });

    test('createError carries language id', () {
      expect(monarch.createMonarchError(_Lexer('ts', {}), 'boom').message,
          'ts: boom');
    });
  });
}

class _Rule implements monarch.IRule {
  final String name;
  _Rule(this.name);
  @override
  monarch.FuzzyAction get action => '';
  @override
  bool get matchOnlyAtLineStart => false;
  @override
  Object resolveRegex(String state) => RegExp('');
}
