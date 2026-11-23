// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/worker/webWorker.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS-only mechanisms bridged 1:1 by behaviour:
//   - `const enum MessageType` -> class with static const int members
//   - `new Proxy(target, handler)` (dynamic property get) -> RemoteChannelProxy
//     callable carrier that lazily fills a name->value map on `call(name)`,
//     mirroring the source `get` trap exactly.
//   - `ArrayBuffer[]` transfer list -> Object? carrier list
// ---------------------------------------------------------------------------

import 'dart:async' show Completer;

import '../charCode.dart' show CharCode;
import '../errors.dart'
    show
        SerializedError,
        onUnexpectedError,
        transformErrorForSerialization;
import '../event.dart' show Emitter, EmitterOptions, Event;
import '../lifecycle.dart' show Disposable, IDisposable;
import '../platform.dart' show isWeb;
import '../strings.dart' show isUpperAsciiLetter;

const String DEFAULT_CHANNEL = 'default';
const String INITIALIZE = r'$initialize';

/// 1:1: `const enum MessageType`
class MessageType {
  static const int Request = 0;
  static const int Reply = 1;
  static const int SubscribeEvent = 2;
  static const int Event = 3;
  static const int UnsubscribeEvent = 4;
}

/// 1:1: `class RequestMessage`
class RequestMessage {
  RequestMessage(this.vsWorker, this.req, this.channel, this.method, this.args);

  final int type = MessageType.Request;
  final int vsWorker;
  final String req;
  final String channel;
  final String method;
  final List<Object?> args;
}

/// 1:1: `class ReplyMessage`
class ReplyMessage {
  ReplyMessage(this.vsWorker, this.seq, this.res, this.err);

  final int type = MessageType.Reply;
  final int vsWorker;
  final String seq;
  final Object? res;
  final Object? err;
}

/// 1:1: `class SubscribeEventMessage`
class SubscribeEventMessage {
  SubscribeEventMessage(this.vsWorker, this.req, this.channel, this.eventName, this.arg);

  final int type = MessageType.SubscribeEvent;
  final int vsWorker;
  final String req;
  final String channel;
  final String eventName;
  final Object? arg;
}

/// 1:1: `class EventMessage`
class EventMessage {
  EventMessage(this.vsWorker, this.req, this.event);

  final int type = MessageType.Event;
  final int vsWorker;
  final String req;
  final Object? event;
}

/// 1:1: `class UnsubscribeEventMessage`
class UnsubscribeEventMessage {
  UnsubscribeEventMessage(this.vsWorker, this.req);

  final int type = MessageType.UnsubscribeEvent;
  final int vsWorker;
  final String req;
}

/// 1:1: `export type Message = ...` (union carrier).
typedef Message = Object;

/// 1:1: `interface IWebWorker`
abstract class IWebWorker implements IDisposable {
  int getId();
  Event<Message> get onMessage;
  Event<Object?> get onError;
  void postMessage(Message message, List<Object?> transfer);
}

/// 1:1: `let webWorkerWarningLogged = false`
bool webWorkerWarningLogged = false;

/// Injectable `console.warn` (webWorker variant).
void Function(Object? message) webWorkerConsoleWarn = (Object? message) {};

/// Injectable `isWeb` flag (defaults to the platform constant).
bool Function() isWebOverride = () => isWeb;

/// 1:1: `export function logOnceWebWorkerWarning(err): void`
void logOnceWebWorkerWarning(Object? err) {
  if (!isWebOverride()) {
    // running tests
    return;
  }
  if (!webWorkerWarningLogged) {
    webWorkerWarningLogged = true;
    webWorkerConsoleWarn(
        'Could not create web worker(s). Falling back to loading web worker code in main thread, which might cause UI freezes. Please see https://github.com/microsoft/monaco-editor#faq');
  }
  final Object error = err ?? 'undefined';
  webWorkerConsoleWarn(_messageOf(error));
}

String _messageOf(Object error) {
  if (error is Error) {
    return error.toString();
  }
  return error.toString();
}

/// 1:1: `interface IMessageReply`
class IMessageReply {
  IMessageReply({required this.resolve, required this.reject});
  void Function(Object? value) resolve;
  void Function(Object? error) reject;
}

/// 1:1: `interface IMessageHandler`
abstract class IMessageHandler {
  void sendMessage(Object? msg, [List<Object?> transfer = const []]);
  Future<Object?> handleMessage(String channel, String method, List<Object?> args);
  Event<Object?> handleEvent(String channel, String eventName, Object? arg);
}

/// 1:1: JS `Proxy` carrier for `createProxyToRemoteChannel`.
///
/// Mirrors the source `get` trap: an unknown string property is lazily filled
/// with a dynamic-event / event / `$`-method closure, then returned. Access
/// via [call], which is the Dart equivalent of `proxy[propertyKey]`.
class RemoteChannelProxy {
  RemoteChannelProxy(this._get);

  final Object? Function(String name) _get;
  Object? call(String name) => _get(name);
}

/// 1:1: `class WebWorkerProtocol`
class WebWorkerProtocol {
  late int _workerId;
  int _lastSentReq = 0;
  final Map<String, IMessageReply> _pendingReplies = <String, IMessageReply>{};
  final Map<String, Emitter<Object?>> _pendingEmitters = <String, Emitter<Object?>>{};
  final Map<String, IDisposable> _pendingEvents = <String, IDisposable>{};
  final IMessageHandler _handler;

  WebWorkerProtocol(IMessageHandler handler) : _handler = handler {
    _workerId = -1;
  }

  void setWorkerId(int workerId) {
    _workerId = workerId;
  }

  /// 1:1: `async sendMessage(...): Promise<unknown>`
  Future<Object?> sendMessage(String channel, String method, List<Object?> args) {
    final String req = (++_lastSentReq).toString();
    final Completer<Object?> c = Completer<Object?>();
    _pendingReplies[req] = IMessageReply(
      resolve: (Object? value) => c.complete(value),
      reject: (Object? error) => c.completeError(error ?? StateError('rejected')),
    );
    _send(RequestMessage(_workerId, req, channel, method, args));
    return c.future;
  }

  /// 1:1: `listen(channel, eventName, arg): Event<unknown>`
  Event<Object?> listen(String channel, String eventName, Object? arg) {
    String? req;
    late final Emitter<Object?> emitter;
    emitter = Emitter<Object?>(
      EmitterOptions(
        onWillAddFirstListener: () {
          req = (++_lastSentReq).toString();
          _pendingEmitters[req!] = emitter;
          _send(SubscribeEventMessage(_workerId, req!, channel, eventName, arg));
        },
        onDidRemoveLastListener: () {
          _pendingEmitters.remove(req);
          _send(UnsubscribeEventMessage(_workerId, req!));
          req = null;
        },
      ),
    );
    return emitter.event;
  }

  /// 1:1: `handleMessage(message: unknown): void`
  void handleMessage(Object? message) {
    if (message == null || _vsWorkerOf(message) == null || _vsWorkerOf(message) == 0) {
      return;
    }
    final int msgWorker = _vsWorkerOf(message)!;
    if (_workerId != -1 && msgWorker != _workerId) {
      return;
    }
    _handleMessage(message);
  }

  int? _vsWorkerOf(Object? message) {
    if (message is RequestMessage ||
        message is ReplyMessage ||
        message is SubscribeEventMessage ||
        message is EventMessage ||
        message is UnsubscribeEventMessage) {
      return (message as dynamic).vsWorker as int;
    }
    return null;
  }

  int _typeOf(Object? message) => (message as dynamic).type as int;

  /// 1:1: `createProxyToRemoteChannel<T>(channel, sendMessageBarrier?): T`
  Object createProxyToRemoteChannel(String channel,
      [Future<void> Function()? sendMessageBarrier]) {
    Object? getTarget(String name) {
      // 1:1: `typeof name === 'string' && !target[name]`
      if (_proxyTargets[channel] == null) {
        _proxyTargets[channel] = <String, Object?>{};
      }
      final Map<String, Object?> target = _proxyTargets[channel]!;
      if (target[name] == null) {
        if (propertyIsDynamicEvent(name)) {
          target[name] = (Object? arg) => listen(channel, name, arg);
        } else if (propertyIsEvent(name)) {
          target[name] = listen(channel, name, null);
        } else if (name.isNotEmpty && name.codeUnitAt(0) == CharCode.DollarSign) {
          target[name] = (List<Object?> myArgs) async {
            if (sendMessageBarrier != null) {
              await sendMessageBarrier();
            }
            return sendMessage(channel, name, myArgs);
          };
        }
      }
      return target[name];
    }

    return RemoteChannelProxy(getTarget);
  }

  final Map<String, Map<String, Object?>> _proxyTargets =
      <String, Map<String, Object?>>{};

  void _handleMessage(Object? msg) {
    switch (_typeOf(msg)) {
      case MessageType.Reply:
        return _handleReplyMessage(msg as ReplyMessage);
      case MessageType.Request:
        return _handleRequestMessage(msg as RequestMessage);
      case MessageType.SubscribeEvent:
        return _handleSubscribeEventMessage(msg as SubscribeEventMessage);
      case MessageType.Event:
        return _handleEventMessage(msg as EventMessage);
      case MessageType.UnsubscribeEvent:
        return _handleUnsubscribeEventMessage(msg as UnsubscribeEventMessage);
    }
  }

  void _handleReplyMessage(ReplyMessage replyMessage) {
    final IMessageReply? reply = _pendingReplies[replyMessage.seq];
    if (reply == null) {
      webWorkerConsoleWarn('Got reply to unknown seq');
      return;
    }

    _pendingReplies.remove(replyMessage.seq);

    if (replyMessage.err != null) {
      Object err = replyMessage.err!;
      if (err is SerializedError && err.$isError) {
        // 1:1: reconstruct an Error with name/message/stack from serialized form
        final SerializedError se = err;
        err = StateError(se.message);
      }
      reply.reject(err);
      return;
    }

    reply.resolve(replyMessage.res);
  }

  void _handleRequestMessage(RequestMessage requestMessage) {
    final String req = requestMessage.req;
    final Future<Object?> result = _handler.handleMessage(
        requestMessage.channel, requestMessage.method, requestMessage.args);
    result.then((Object? r) {
      _send(ReplyMessage(_workerId, req, r, null));
    }, onError: (Object e) {
      _send(ReplyMessage(_workerId, req, null, transformErrorForSerialization(e)));
    });
  }

  void _handleSubscribeEventMessage(SubscribeEventMessage msg) {
    final String req = msg.req;
    final IDisposable disposable = _handler.handleEvent(
        msg.channel, msg.eventName, msg.arg)((Object? event) {
      _send(EventMessage(_workerId, req, event));
    });
    _pendingEvents[req] = disposable;
  }

  void _handleEventMessage(EventMessage msg) {
    final Emitter<Object?>? emitter = _pendingEmitters[msg.req];
    if (emitter == null) {
      webWorkerConsoleWarn('Got event for unknown req');
      return;
    }
    emitter.fire(msg.event);
  }

  void _handleUnsubscribeEventMessage(UnsubscribeEventMessage msg) {
    final IDisposable? event = _pendingEvents[msg.req];
    if (event == null) {
      webWorkerConsoleWarn('Got unsubscribe for unknown req');
      return;
    }
    event.dispose();
    _pendingEvents.remove(msg.req);
  }

  void _send(Object? msg) {
    final List<Object?> transfer = <Object?>[];
    final int type = _typeOf(msg);
    if (type == MessageType.Request) {
      final List<Object?> args = (msg as RequestMessage).args;
      for (int i = 0; i < args.length; i++) {
        final Object? arg = args[i];
        if (arg is List<int> || arg is Map) {
          transfer.add(arg);
        }
      }
    } else if (type == MessageType.Reply) {
      final Object? res = (msg as ReplyMessage).res;
      if (res is List<int> || res is Map) {
        transfer.add(res);
      }
    }
    _handler.sendMessage(msg, transfer);
  }
}

/// 1:1: `type ProxiedMethodName = ...` (type-only; compile-time concept).
/// 1:1: `export type Proxied<T>` (type-only; Dart uses [RemoteChannelProxy] carrier).
typedef Proxied = RemoteChannelProxy;

/// 1:1: `function propertyIsEvent(name): boolean`
bool propertyIsEvent(String name) {
  // 1:1: `name[0] === 'o' && name[1] === 'n' && isUpperAsciiLetter(name.charCodeAt(2))`
  return name.length >= 3 &&
      name[0] == 'o' &&
      name[1] == 'n' &&
      isUpperAsciiLetter(name.codeUnitAt(2));
}

/// 1:1: `function propertyIsDynamicEvent(name): boolean`
bool propertyIsDynamicEvent(String name) {
  // 1:1: `/^onDynamic/.test(name) && isUpperAsciiLetter(name.charCodeAt(9))`
  return RegExp(r'^onDynamic').hasMatch(name) &&
      name.length > 9 &&
      isUpperAsciiLetter(name.codeUnitAt(9));
}

/// 1:1: `interface IWebWorkerClient<TProxy>`
abstract class IWebWorkerClient {
  Object get proxy;
  void dispose();
  void setChannel(String channel, Object handler);
  Object getChannel(String channel);
}

/// 1:1: `interface IWebWorkerServer`
abstract class IWebWorkerServer {
  void setChannel(String channel, Object handler);
  Object getChannel(String channel);
}

/// Injectable `console.error` / `console.info` for client error reporting.
void Function(Object? message) webWorkerConsoleError = (Object? message) {};
void Function(Object? info) webWorkerConsoleInfo = (Object? info) {};

/// 1:1: `WebWorkerClient<W> extends Disposable implements IWebWorkerClient<W>`
class WebWorkerClient extends Disposable implements IWebWorkerClient {
  late final IWebWorker _worker;
  late final Future<void> _onModuleLoaded;
  late final WebWorkerProtocol _protocol;
  late final Object _proxy;
  final Map<String, Object> _localChannels = <String, Object>{};
  final Map<String, Object> _remoteChannels = <String, Object>{};

  WebWorkerClient(IWebWorker worker) {
    _worker = register<IWebWorker>(worker);
    register(_worker.onMessage((dynamic msg) {
      _protocol.handleMessage(msg as Object?);
    }));
    register(_worker.onError((dynamic err) {
      logOnceWebWorkerWarning(err);
      onUnexpectedError(err);
    }));

    _protocol = WebWorkerProtocol(WorkerClientMessageHandler(this));
    _protocol.setWorkerId(_worker.getId());

    // Send initialize message
    _onModuleLoaded = _protocol
        .sendMessage(DEFAULT_CHANNEL, INITIALIZE, <Object?>[_worker.getId()])
        .then((_) {});

    _proxy = _protocol.createProxyToRemoteChannel(DEFAULT_CHANNEL, () async {
      await _onModuleLoaded;
    });
    _onModuleLoaded.catchError((Object e) {
      _onError('Worker failed to load ', e);
    });
  }

  @override
  Object get proxy => _proxy;

  Future<Object?> _handleMessage(String channelName, String method, List<Object?> args) {
    final Object? channel = _localChannels[channelName];
    if (channel == null) {
      return Future<Object?>.error(StateError('Missing channel $channelName on main thread'));
    }

    final Object? fn = _getProp(channel, method);
    if (fn is! Function) {
      return Future<Object?>.error(StateError(
          'Missing method $method on main thread channel $channelName'));
    }

    try {
      return Future<Object?>.value(_apply(fn, channel, args));
    } catch (e) {
      return Future<Object?>.error(e);
    }
  }

  Event<Object?> _handleEvent(String channelName, String eventName, Object? arg) {
    final Object? channel = _localChannels[channelName];
    if (channel == null) {
      throw StateError('Missing channel $channelName on main thread');
    }
    if (propertyIsDynamicEvent(eventName)) {
      final Object? fn = _getProp(channel, eventName);
      if (fn is! Function) {
        throw StateError(
            'Missing dynamic event $eventName on main thread channel $channelName.');
      }
      final Object? event = _applyOne(fn, channel, arg);
      if (event is! Function) {
        throw StateError(
            'Missing dynamic event $eventName on main thread channel $channelName.');
      }
      return event as Event<Object?>;
    }
    if (propertyIsEvent(eventName)) {
      final Object? event = _getProp(channel, eventName);
      if (event is! Function) {
        throw StateError('Missing event $eventName on main thread channel $channelName.');
      }
      return event as Event<Object?>;
    }
    throw StateError('Malformed event name $eventName');
  }

  @override
  void setChannel(String channel, Object handler) {
    _localChannels[channel] = handler;
  }

  @override
  Object getChannel(String channel) {
    Object? inst = _remoteChannels[channel];
    if (inst == null) {
      inst = _protocol.createProxyToRemoteChannel(channel, () async {
        await _onModuleLoaded;
      });
      _remoteChannels[channel] = inst;
    }
    return inst;
  }

  void _onError(String message, [Object? error]) {
    webWorkerConsoleError(message);
    webWorkerConsoleInfo(error);
  }
}

/// 1:1: handler wiring for `WebWorkerClient._protocol`.
class WorkerClientMessageHandler implements IMessageHandler {
  WorkerClientMessageHandler(this._client);
  final WebWorkerClient _client;

  @override
  void sendMessage(Object? msg, [List<Object?> transfer = const []]) {
    // access via a small bridge on the client
    _client._worker.postMessage(msg as Message, transfer);
  }

  @override
  Future<Object?> handleMessage(String channel, String method, List<Object?> args) =>
      _client._handleMessage(channel, method, args);

  @override
  Event<Object?> handleEvent(String channel, String eventName, Object? arg) =>
      _client._handleEvent(channel, eventName, arg);
}

/// 1:1: `interface IWebWorkerServerRequestHandler`
typedef IWebWorkerServerRequestHandler = Object;

/// 1:1: `interface IWebWorkerServerRequestHandlerFactory<T>`
typedef IWebWorkerServerRequestHandlerFactory = Object Function(IWebWorkerServer server);

/// 1:1: `WebWorkerServer<T> implements IWebWorkerServer`
class WebWorkerServer implements IWebWorkerServer {
  WebWorkerServer(
    void Function(Message msg, [List<Object?> transfer]) postMessage,
    IWebWorkerServerRequestHandlerFactory requestHandlerFactory,
  ) {
    _postMessage = postMessage;
    _protocol = WebWorkerProtocol(WorkerServerMessageHandler(this));
    requestHandler = requestHandlerFactory(this);
  }

  late final void Function(Message msg, [List<Object?> transfer]) _postMessage;
  late final WebWorkerProtocol _protocol;
  late final Object requestHandler;
  final Map<String, Object> _localChannels = <String, Object>{};
  final Map<String, Object> _remoteChannels = <String, Object>{};

  /// 1:1: `onmessage(msg): void`
  void onmessage(Object? msg) {
    _protocol.handleMessage(msg);
  }

  Future<Object?> _handleMessage(String channel, String method, List<Object?> args) {
    if (channel == DEFAULT_CHANNEL && method == INITIALIZE) {
      return _initialize(args[0] as int);
    }

    final Object? requestHandler = channel == DEFAULT_CHANNEL
        ? this.requestHandler
        : _localChannels[channel];
    if (requestHandler == null) {
      return Future<Object?>.error(StateError('Missing channel $channel on worker thread'));
    }

    final Object? fn = _getProp(requestHandler, method);
    if (fn is! Function) {
      return Future<Object?>.error(StateError(
          'Missing method $method on worker thread channel $channel'));
    }

    try {
      return Future<Object?>.value(_apply(fn, requestHandler, args));
    } catch (e) {
      return Future<Object?>.error(e);
    }
  }

  Event<Object?> _handleEvent(String channel, String eventName, Object? arg) {
    final Object? requestHandler = channel == DEFAULT_CHANNEL
        ? this.requestHandler
        : _localChannels[channel];
    if (requestHandler == null) {
      throw StateError('Missing channel $channel on worker thread');
    }
    if (propertyIsDynamicEvent(eventName)) {
      final Object? fn = _getProp(requestHandler, eventName);
      if (fn is! Function) {
        throw StateError('Missing dynamic event $eventName on request handler.');
      }
      final Object? event = _applyOne(fn, requestHandler, arg);
      if (event is! Function) {
        throw StateError('Missing dynamic event $eventName on request handler.');
      }
      return event as Event<Object?>;
    }
    if (propertyIsEvent(eventName)) {
      final Object? event = _getProp(requestHandler, eventName);
      if (event is! Function) {
        throw StateError('Missing event $eventName on request handler.');
      }
      return event as Event<Object?>;
    }
    throw StateError('Malformed event name $eventName');
  }

  @override
  void setChannel(String channel, Object handler) {
    _localChannels[channel] = handler;
  }

  @override
  Object getChannel(String channel) {
    Object? inst = _remoteChannels[channel];
    if (inst == null) {
      inst = _protocol.createProxyToRemoteChannel(channel);
      _remoteChannels[channel] = inst;
    }
    return inst;
  }

  Future<void> _initialize(int workerId) async {
    _protocol.setWorkerId(workerId);
  }
}

/// 1:1: handler wiring for `WebWorkerServer._protocol`.
class WorkerServerMessageHandler implements IMessageHandler {
  WorkerServerMessageHandler(this._server);
  final WebWorkerServer _server;

  @override
  void sendMessage(Object? msg, [List<Object?> transfer = const []]) {
    _server._postMessage(msg as Message, transfer);
  }

  @override
  Future<Object?> handleMessage(String channel, String method, List<Object?> args) =>
      _server._handleMessage(channel, method, args);

  @override
  Event<Object?> handleEvent(String channel, String eventName, Object? arg) =>
      _server._handleEvent(channel, eventName, arg);
}

// --- reflection helpers bridging JS `(obj as Record)[name]` / `fn.apply(obj, args)` ---

Object? _getProp(Object obj, String name) {
  if (obj is Map) {
    return obj[name];
  }
  // Opaque object carriers expose members through an optional accessor.
  if (obj is WebWorkerPropProvider) {
    return obj.prop(name);
  }
  return null;
}

/// Optional accessor for opaque request-handler / channel objects that are not
/// plain Maps, standing in for JS `record[propertyKey]`.
abstract class WebWorkerPropProvider {
  Object? prop(String name);
}

Object? _apply(Function fn, Object receiver, List<Object?> args) =>
    Function.apply(fn, args);

Object? _applyOne(Function fn, Object receiver, Object? arg) =>
    Function.apply(fn, <Object?>[arg]);
