// 1:1 translation of
// vscode/src/vs/base/common/observableInternal/logging/debugger/debuggerRpc.ts
// Mirrors registerDebugChannel, GlobalObj, IHost and
// createChannelFactoryFromDebugChannel file-for-file.
// Adaptations: `globalThis` -> a top-level map; TS indexed-access types
// (`T['host']`, `T['client']`, `T['channelId']`) have no Dart equivalent, so
// they are represented by their runtime counterparts at the call boundary;
// abstract IChannel/IHandler from rpc.dart are given concrete implementations.

import 'rpc.dart';

/// Top-level stand-in for `globalThis.$$debugValueEditor_debugChannels`.
final Map<String, DebugChannelRegistrar> $$debugValueEditor_debugChannels =
    <String, DebugChannelRegistrar>{};

/// 1:1: `(host: IHost) => { handleRequest }`
typedef DebugChannelRegistrar = HandlerHandle Function(IHost host);

/// 1:1: `interface IHost { sendNotification(data): void }`
class IHost {
  final void Function(Object data) sendNotification;
  IHost(this.sendNotification);
}

/// 1:1: `{ handleRequest: (data) => unknown }`
class HandlerHandle {
  final Object? Function(Object data) handleRequest;
  HandlerHandle(this.handleRequest);
}

/// 1:1: `export function registerDebugChannel<T ...>(channelId, createClient)`
SimpleTypedRpcConnection<MakeSideAsync> registerDebugChannel<T extends API>(
  String channelId,
  Object Function() createClient,
) {
  final List<Object?> queuedNotifications = <Object?>[];
  IHost? curHost;

  final DebugChannelFactoryResult factory =
      createChannelFactoryFromDebugChannel(IHost((Object data) {
    final IHost? host = curHost;
    if (host != null) {
      host.sendNotification(data);
    } else {
      queuedNotifications.add(data);
    }
  }));

  Object? curClient;

  ($$debugValueEditor_debugChannels[channelId] ??= (IHost host) {
    curClient = createClient();
    curHost = host;
    for (final Object? n in queuedNotifications) {
      host.sendNotification(n as Object);
    }
    queuedNotifications.clear();
    return factory.handler;
  });

  return SimpleTypedRpcConnection.createClient(factory.channel, () {
    final Object? client = curClient;
    if (client == null) {
      throw StateError('Not supported');
    }
    // Dart cannot carry T['client'] through the proxy; the runtime value is
    // the created client object (a Side in the rpc.dart model).
    return client as Side;
  });
}

/// 1:1 return shape `{ channel: ChannelFactory; handler: { handleRequest } }`
class DebugChannelFactoryResult {
  final ChannelFactory channel;
  final HandlerHandle handler;
  DebugChannelFactoryResult(this.channel, this.handler);
}

/// Concrete `IChannel` returned by the factory, mirroring the TS object
/// literal `{ sendNotification, sendRequest }`.
class _DebugChannel implements IChannel {
  final IHost _host;
  _DebugChannel(this._host);

  @override
  void sendNotification(Object data) => _host.sendNotification(data);

  @override
  Future<RpcRequestResult> sendRequest(Object data) {
    throw StateError('not supported');
  }
}

/// 1:1: `function createChannelFactoryFromDebugChannel(host: IHost)`
DebugChannelFactoryResult createChannelFactoryFromDebugChannel(IHost host) {
  IChannelHandler? h;
  final ChannelFactory channel = (IChannelHandler handler) {
    h = handler;
    return _DebugChannel(host);
  };
  return DebugChannelFactoryResult(
    channel,
    HandlerHandle((Object data) {
      final Map<String, Object?> m = data as Map<String, Object?>;
      if (m['type'] == 'notification') {
        h?.handleNotification(m['data'] as Object);
        return null;
      } else {
        return h?.handleRequest(m['data'] as Object);
      }
    }),
  );
}
