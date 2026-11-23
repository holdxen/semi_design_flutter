// 1:1 translation of
// vscode/src/vs/base/common/observableInternal/logging/debugger/rpc.ts
// Mirrors interfaces, types and SimpleTypedRpcConnection file-for-file.
// Dart has no JS `Proxy`, so the dynamic api object is carried by noSuchMethod.

import 'dart:async';

/// 1:1: `type ChannelFactory = (handler) => IChannel`
typedef ChannelFactory = IChannel Function(IChannelHandler handler);

/// 1:1: `interface IChannel`
abstract class IChannel {
  void sendNotification(Object data);
  Future<RpcRequestResult> sendRequest(Object data);
}

/// 1:1: `interface IChannelHandler`
abstract class IChannelHandler {
  void handleNotification(Object notificationData);
  FutureOr<RpcRequestResult> handleRequest(Object requestData);
}

/// 1:1: `type RpcRequestResult = { type: 'result'; value } | { type: 'error'; value }`
abstract class RpcRequestResult {
  Object? get value;
}

class RpcResult extends RpcRequestResult {
  @override
  final Object? value;
  RpcResult(this.value);
}

class RpcError extends RpcRequestResult {
  @override
  final Object? value;
  RpcError(this.value);
}

/// 1:1: `type API = { host: Side; client: Side }`
abstract class API {
  Side get host;
  Side get client;
}

/// 1:1: `type Side = { notifications, requests }`
abstract class Side {
  Map<String, Function> get notifications;
  Map<String, Function> get requests;
}

/// 1:1: `type OutgoingMessage = [method: string, args: unknown[]]`
/// Carried as a plain two-element list, matching the TS tuple at runtime.
typedef OutgoingMessage = List<Object?>;

/// Dynamic api proxy. In TS this is `new Proxy({}, { get })` whose `get`
/// returns a function per property; `then` is explicitly unanswered so the
/// proxy is not thenable. Dart's `noSuchMethod` reproduces both the method
/// call and the property-get forms.
class _ApiProxy {
  final bool _isRequest;
  final IChannel _channel;

  _ApiProxy(this._isRequest, this._channel);

  static String _name(Symbol symbol) {
    final String s = symbol.toString();
    const String prefix = 'Symbol("';
    if (s.startsWith(prefix) && s.endsWith('")')) {
      return s.substring(prefix.length, s.length - 2);
    }
    return s;
  }

  Future<Object?> _callRequest(String key, List<dynamic> args) async {
    // 1:1: `const result = await this._channel.sendRequest([key, args])`
    final RpcRequestResult result =
        await _channel.sendRequest(<Object?>[key, args]);
    if (result is RpcError) {
      throw result.value ?? StateError('rpc error');
    } else {
      return result.value;
    }
  }

  void _callNotification(String key, List<dynamic> args) {
    // 1:1: `this._channel.sendNotification([key, args])`
    _channel.sendNotification(<Object?>[key, args]);
  }

  @override
  dynamic noSuchMethod(Invocation inv) {
    final String name = _name(inv.memberName);
    // Answering `then` makes this proxy a thenable, so `await` would send a
    // bogus request/notification and never settle.
    if (name == 'then') {
      return null;
    }
    if (_isRequest) {
      if (inv.isMethod) {
        return _callRequest(name, inv.positionalArguments);
      }
      if (inv.isGetter) {
        return (List<dynamic> args) => _callRequest(name, args);
      }
    } else {
      if (inv.isMethod) {
        _callNotification(name, inv.positionalArguments);
        return null;
      }
      if (inv.isGetter) {
        return (List<dynamic> args) => _callNotification(name, args);
      }
    }
    return null;
  }
}

/// 1:1: `class SimpleTypedRpcConnection<T extends Side>`
class SimpleTypedRpcConnection<T extends Side> {
  /// 1:1: `static createHost(channelFactory, getHandler)`
  static SimpleTypedRpcConnection<MakeSideAsync> createHost(
      ChannelFactory channelFactory, Side Function() getHandler) {
    return SimpleTypedRpcConnection<MakeSideAsync>(channelFactory, getHandler);
  }

  /// 1:1: `static createClient(channelFactory, getHandler)`
  static SimpleTypedRpcConnection<MakeSideAsync> createClient(
      ChannelFactory channelFactory, Side Function() getHandler) {
    return SimpleTypedRpcConnection<MakeSideAsync>(channelFactory, getHandler);
  }

  /// 1:1: `public readonly api: T`
  late final dynamic api;

  late final IChannel _channel;

  final ChannelFactory _channelFactory;
  final Side Function() _getHandler;

  SimpleTypedRpcConnection(this._channelFactory, this._getHandler) {
    _channel = _channelFactory(_Handler(_getHandler));
    api = _Api(_ApiProxy(true, _channel), _ApiProxy(false, _channel));
  }
}

/// Carrier for the two dynamic api members (TS: `{ notifications, requests }`).
class _Api {
  final dynamic requests;
  final dynamic notifications;
  _Api(this.requests, this.notifications);
}

/// The handler handed to the channel factory. 1:1 with the object literal in
/// the TS constructor.
class _Handler implements IChannelHandler {
  final Side Function() _getHandler;
  _Handler(this._getHandler);

  @override
  void handleNotification(Object notificationData) {
    final OutgoingMessage m = notificationData as OutgoingMessage;
    final String method = m[0] as String;
    final List<dynamic> args = m[1] as List<dynamic>;
    final Function? fn = _getHandler().notifications[method];
    if (fn == null) {
      throw StateError('Unknown notification "$method"!');
    }
    Function.apply(fn, args);
  }

  @override
  FutureOr<RpcRequestResult> handleRequest(Object requestData) {
    final OutgoingMessage m = requestData as OutgoingMessage;
    final String method = m[0] as String;
    final List<dynamic> args = m[1] as List<dynamic>;
    try {
      final Object? result = Function.apply(_getHandler().requests[method]!, args);
      return RpcResult(result);
    } catch (e) {
      return RpcError(e);
    }
  }
}

/// 1:1: `MakeSideAsync<T>` mapped type — Dart has no mapped types; kept as a
/// marker class so the generic signatures mirror the TS declarations.
class MakeSideAsync extends Side {
  @override
  Map<String, Function> get notifications => <String, Function>{};
  @override
  Map<String, Function> get requests => <String, Function>{};
}
