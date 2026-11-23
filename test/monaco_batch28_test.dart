import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' show Emitter, Event;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart' show SerializedError;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable, toDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/worker/webWorker.dart'
    as ww;
import 'package:semi_design_flutter/src/monaco/editor/browser/controller/editContext/native/editContextFactory.dart'
    as ecf;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/minimap/minimapPreBaked.dart'
    as mpb;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewLines/domReadingContext.dart'
    as drc;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/index.dart'
    as sched;

// ---- fakes -----------------------------------------------------------------

class _FakeWebWorker implements ww.IWebWorker {
  int _id;
  final List<Object?> sent = <Object?>[];
  late final Emitter<Object?> _onMessage = Emitter<Object?>();
  late final Emitter<Object?> _onError = Emitter<Object?>();

  _FakeWebWorker(this._id);

  @override
  int getId() => _id;

  @override
  Event<ww.Message> get onMessage => _onMessage.event;

  @override
  Event<Object?> get onError => _onError.event;

  @override
  void postMessage(Object? message, List<Object?> transfer) {
    sent.add(message);
  }

  @override
  void dispose() {
    _onMessage.dispose();
    _onError.dispose();
  }

  void deliverMessage(Object? msg) => _onMessage.fire(msg);
}

/// Records outgoing messages and lets tests inject replies.
class _RecordingHandler implements ww.IMessageHandler {
  final List<Object?> sent = <Object?>[];
  Future<Object?> Function(String, String, List<Object?>)? onHandleMessage;
  Event<Object?> Function(String, String, Object?)? onHandleEvent;

  @override
  void sendMessage(Object? msg, [List<Object?> transfer = const []]) {
    sent.add(msg);
  }

  @override
  Future<Object?> handleMessage(String channel, String method, List<Object?> args) {
    final fn = onHandleMessage;
    if (fn != null) {
      return fn(channel, method, args);
    }
    return Future<Object?>.value(null);
  }

  @override
  Event<Object?> handleEvent(String channel, String eventName, Object? arg) {
    final fn = onHandleEvent;
    if (fn != null) {
      return fn(channel, eventName, arg);
    }
    return (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
        toDisposable(() {});
  }
}

IDisposable _noopDisposable() => toDisposable(() {});

void main() {
  group('batch28 / webWorker constants + predicates', () {
    test('MessageType const enum values are 1:1', () {
      expect(ww.MessageType.Request, 0);
      expect(ww.MessageType.Reply, 1);
      expect(ww.MessageType.SubscribeEvent, 2);
      expect(ww.MessageType.Event, 3);
      expect(ww.MessageType.UnsubscribeEvent, 4);
      expect(ww.DEFAULT_CHANNEL, 'default');
      expect(ww.INITIALIZE, r'$initialize');
    });

    test('propertyIsEvent / propertyIsDynamicEvent mirror source regex', () {
      expect(ww.propertyIsEvent('onDidChange'), isTrue);
      expect(ww.propertyIsEvent('onX'), isTrue);
      expect(ww.propertyIsEvent('ondidChange'), isFalse);
      expect(ww.propertyIsEvent('on'), isFalse);
      expect(ww.propertyIsEvent('o'), isFalse);
      expect(ww.propertyIsDynamicEvent('onDynamicFoo'), isTrue);
      expect(ww.propertyIsDynamicEvent('onDynamicfoo'), isFalse);
      expect(ww.propertyIsDynamicEvent('onFoo'), isFalse);
    });

    test('message carriers carry type + fields', () {
      final req = ww.RequestMessage(1, '2', 'ch', 'm', <Object?>[3]);
      expect(req.type, ww.MessageType.Request);
      expect(req.vsWorker, 1);
      expect(req.req, '2');
      expect(req.args, <Object?>[3]);
      final reply = ww.ReplyMessage(1, '2', 'ok', null);
      expect(reply.type, ww.MessageType.Reply);
      expect(reply.res, 'ok');
      expect(ww.UnsubscribeEventMessage(1, '2').type,
          ww.MessageType.UnsubscribeEvent);
    });
  });

  group('batch28 / logOnceWebWorkerWarning', () {
    setUp(() {
      ww.isWebOverride = () => false;
      ww.webWorkerConsoleWarn = (_) {};
      ww.webWorkerWarningLogged = false;
    });
    tearDown(() {
      ww.isWebOverride = () => false;
    });

    test('does nothing when not web', () {
      final warnings = <Object?>[];
      ww.webWorkerConsoleWarn = (m) => warnings.add(m);
      ww.logOnceWebWorkerWarning(StateError('x'));
      expect(warnings, isEmpty);
    });

    test('logs informational warning once + err message on web', () {
      final warnings = <Object?>[];
      ww.isWebOverride = () => true;
      ww.webWorkerConsoleWarn = (m) => warnings.add(m);
      ww.logOnceWebWorkerWarning(StateError('first'));
      ww.logOnceWebWorkerWarning(StateError('second'));
      expect(warnings, hasLength(3));
      expect(
        warnings[0],
        contains('Could not create web worker(s)'),
      );
      expect(warnings[1], isNotNull);
      expect(warnings[2], isNotNull);
    });
  });

  group('batch28 / WebWorkerProtocol', () {
    late _RecordingHandler handler;
    late ww.WebWorkerProtocol protocol;

    setUp(() {
      handler = _RecordingHandler();
      protocol = ww.WebWorkerProtocol(handler);
      protocol.setWorkerId(7);
    });

    test('sendMessage sends RequestMessage and resolve on matching reply', () async {
      final future = protocol.sendMessage('ch', 'method', <Object?>[1, 2]);
      expect(handler.sent, hasLength(1));
      final req = handler.sent.single as ww.RequestMessage;
      expect(req.vsWorker, 7);
      expect(req.req, '1');
      expect(req.channel, 'ch');
      expect(req.method, 'method');
      expect(req.args, <Object?>[1, 2]);

      protocol.handleMessage(ww.ReplyMessage(7, '1', 'ok', null));
      expect(await future, 'ok');
    });

    test('handleMessage ignores messages from other workers / missing vsWorker',
        () async {
      final future = protocol.sendMessage('ch', 'm', <Object?>[]);
      protocol.handleMessage(ww.ReplyMessage(99, '1', 'wrong', null));
      protocol.handleMessage(null);
      expect(handler.sent, hasLength(1)); // only the request, no reply consumed
      protocol.handleMessage(ww.ReplyMessage(7, '1', 'right', null));
      expect(await future, 'right');
    });

    test('reply with SerializedError rejects the pending reply', () async {
      final future = protocol.sendMessage('ch', 'm', <Object?>[]);
      final se = SerializedError(
          name: 'StateError', message: 'boom', stack: '', noTelemetry: false);
      protocol.handleMessage(ww.ReplyMessage(7, '1', null, se));
      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('incoming RequestMessage is dispatched to handler, reply sent', () async {
      handler.onHandleMessage = (channel, method, args) async => 'result:${args[0]}';
      final req = ww.RequestMessage(7, 'r1', 'ch', 'm', <Object?>[42]);
      protocol.handleMessage(req);
      // allow the Future.then to flush
      await Future<void>.delayed(Duration.zero);
      expect(handler.sent, hasLength(1));
      final reply = handler.sent.single as ww.ReplyMessage;
      expect(reply.seq, 'r1');
      expect(reply.res, 'result:42');
    });

    test('listen subscribes on first listener and unsubscribes on last', () {
      final event = protocol.listen('ch', 'onDidX', null);
      expect(handler.sent, isEmpty);
      final l1 = event((dynamic _) {});
      expect(handler.sent, hasLength(1));
      expect(handler.sent.single, isA<ww.SubscribeEventMessage>());
      l1.dispose();
      expect(handler.sent, hasLength(2));
      expect(handler.sent.last, isA<ww.UnsubscribeEventMessage>());
    });

    test('proxy carrier lazily fills event and dollar-method names', () async {
      final proxy = protocol.createProxyToRemoteChannel('ch') as ww.RemoteChannelProxy;
      final onDid = proxy('onDidFoo');
      expect(onDid, isA<Function>()); // Event is callable
      final method = proxy(r'$echo') as Future<Object?> Function(List<Object?>);
      final fut = method(<Object?>[9]);
      await Future<void>.delayed(Duration.zero);
      expect(handler.sent, isNotEmpty);
      final req = handler.sent.first as ww.RequestMessage;
      expect(req.method, r'$echo');
    });
  });

  group('batch28 / WebWorkerClient + Server', () {
    test('client sends initialize with worker id on construction', () async {
      final worker = _FakeWebWorker(11);
      final client = ww.WebWorkerClient(worker);
      await Future<void>.delayed(Duration.zero);
      expect(worker.sent, hasLength(1));
      final init = worker.sent.single as ww.RequestMessage;
      expect(init.channel, ww.DEFAULT_CHANNEL);
      expect(init.method, ww.INITIALIZE);
      expect(init.args, <Object?>[11]);
      client.dispose();
    });

    test('client setChannel handles local RPC method dispatch', () async {
      final worker = _FakeWebWorker(1);
      final client = ww.WebWorkerClient(worker);
      client.setChannel('local', <String, dynamic>{
        'double': (int x) => x * 2,
      });
      // Drive the handler through a fresh protocol wired to the same channel.
      final handler = ww.WorkerClientMessageHandler(client);
      final result = await handler.handleMessage('local', 'double', <Object?>[3]);
      expect(result, 6);
      client.dispose();
    });

    test('server initializes worker id via INITIALIZE message', () async {
      final server = ww.WebWorkerServer(
        (msg, [List<Object?> transfer = const []]) {},
        (s) => <String, dynamic>{'ping': () => 'pong'},
      );
      server.onmessage(ww.RequestMessage(7, '1', ww.DEFAULT_CHANNEL,
          ww.INITIALIZE, <Object?>[55]));
      await Future<void>.delayed(Duration.zero);
      expect(server.requestHandler, isA<Map>());
    });

    test('server dispatches RPC to request handler', () async {
      final sent = <Object?>[];
      final server = ww.WebWorkerServer(
        (msg, [List<Object?> transfer = const []]) => sent.add(msg),
        (s) => <String, dynamic>{
          'greet': (String name) => 'hi $name',
        },
      );
      final handler = ww.WorkerServerMessageHandler(server);
      final result = await handler.handleMessage(
          ww.DEFAULT_CHANNEL, 'greet', <Object?>['Bob']);
      expect(result, 'hi Bob');
    });
  });

  group('batch28 / DomReadingContext', () {
    test('lazy reads rect once and computes scale', () {
      int readCount = 0;
      final el = drc.DomReadElement(
        rectProvider: () {
          readCount++;
          return <String, num>{'left': 12, 'width': 80};
        },
        offsetWidth: 40,
      );
      final ctx = drc.DomReadingContext(el, 'end');
      expect(ctx.didDomLayout, isFalse);
      expect(readCount, 0);
      expect(ctx.clientRectDeltaLeft, 12);
      expect(readCount, 1);
      expect(ctx.didDomLayout, isTrue);
      expect(ctx.clientRectScale, 2);
      expect(readCount, 1); // cached
    });

    test('zero offsetWidth yields scale 1', () {
      final el = drc.DomReadElement(
        rectProvider: () => <String, num>{'left': 0, 'width': 100},
        offsetWidth: 0,
      );
      final ctx = drc.DomReadingContext(el, 'end');
      expect(ctx.clientRectScale, 1);
      expect(ctx.endNode, 'end');
    });

    test('markDidDomLayout can be called explicitly', () {
      final el = drc.DomReadElement(
        rectProvider: () => <String, num>{'left': 0, 'width': 0},
        offsetWidth: 1,
      );
      final ctx = drc.DomReadingContext(el, 'end');
      ctx.markDidDomLayout();
      expect(ctx.didDomLayout, isTrue);
    });
  });

  group('batch28 / minimapPreBaked', () {
    test('scale 1 decodes to 192 bytes; scale 2 to 768 bytes', () {
      final d1 = mpb.prebakedMiniMaps[1]!();
      final d2 = mpb.prebakedMiniMaps[2]!();
      expect(d1.length, 192);
      expect(d2.length, 768);
      expect(d1[0], 0x00);
      expect(d1[1], 0x00);
      expect(d1[2], 0x51);
      expect(d2[0], 0x00);
    });

    test('single-call decode returns identical cached instance', () {
      final a = mpb.prebakedMiniMaps[1]!();
      final b = mpb.prebakedMiniMaps[1]!();
      expect(identical(a, b), isTrue);
    });
  });

  group('batch28 / editContextFactory', () {
    test('create forwards options to window.EditContext constructor', () {
      Object? captured;
      final win = ecf.EditContextWindow((options) {
        captured = options;
        return <String, dynamic>{'made': true};
      });
      final ctx = ecf.EditContext.create(win, 'opts');
      expect(captured, 'opts');
      expect(ctx.raw, isA<Map>());
    });
  });

  group('batch28 / virtualScheduling barrel', () {
    test('re-exports core scheduling symbols', () {
      // Compile-time verification that the barrel surfaces the same API.
      final clock = sched.VirtualClock(0);
      expect(clock.now, 0);
      expect(sched.untilIdle, isNotNull);
      expect(sched.ROOT_TRACE, isNotNull);
      expect(sched.createVirtualTimeApi, isA<Function>());
      expect(sched.runWithFakedTimers, isA<Function>());
    });
  });
}
