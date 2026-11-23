// Carrier for `@hediet/json-rpc` TypedChannel, referenced by
// monaco-lsp-client adapters but not ported (external package). Preserves the
// `registerRequestHandler(method, handler)` surface used by LspCapabilitiesRegistry.
import '../types.dart' as T;
import '../utils.dart';

/// Payload shape of `client/registerCapability`.
class RegistrationParams {
  final List<dynamic> registrations;
  RegistrationParams(this.registrations);
}

/// Payload shape of `client/unregisterCapability`.
class UnregistrationParams {
  final List<dynamic> unregisterations; // TS typo is intentional (1:1).
  UnregistrationParams(this.unregisterations);
}

/// Result shape `{ ok: null }` returned by the request handlers.
class OkResult {
  final Object? ok;
  const OkResult(this.ok);
}

/// 1:1 carrier of the `TypedChannel` surface used in this codebase.
/// Handlers are registered per LspApiMethod key and invoked via [handleRequest].
abstract class TypedChannel {
  /// 1:1: `registerRequestHandler(method, async (params) => result): IDisposable`
  IDisposable registerRequestHandler(
    T.LspApiMethod method,
    Future<Object?> Function(Object? params) handler,
  );

  /// 1:1: `registerNotificationHandler(method, handler): IDisposable`
  IDisposable registerNotificationHandler(
    T.LspApiMethod method,
    void Function(Object? params) handler,
  );

  /// Test/driver hook: invoke a previously registered handler by method key.
  Future<Object?> handleRequest(String method, Object? params);

  /// Test/driver hook: invoke a previously registered notification handler.
  void handleNotification(String method, Object? params);
}

/// In-memory [TypedChannel] used by tests and as a default carrier.
class InMemoryTypedChannel implements TypedChannel {
  final Map<String, Future<Object?> Function(Object?)> _handlers = <String, Future<Object?> Function(Object?)>{};

  @override
  IDisposable registerRequestHandler(
    T.LspApiMethod method,
    Future<Object?> Function(Object?) handler,
  ) {
    _handlers[method.method] = handler;
    return _HandlerDisposable(method.method, _handlers);
  }

  final Map<String, void Function(Object?)> _notificationHandlers =
      <String, void Function(Object?)>{};

  @override
  IDisposable registerNotificationHandler(
    T.LspApiMethod method,
    void Function(Object? params) handler,
  ) {
    _notificationHandlers[method.method] = handler;
    return _HandlerDisposable(method.method, _handlers);
  }

  @override
  Future<Object?> handleRequest(String method, Object? params) {
    final h = _handlers[method];
    if (h == null) {
      throw StateError('No handler for method $method');
    }
    return h(params);
  }

  @override
  void handleNotification(String method, Object? params) {
    final h = _notificationHandlers[method];
    if (h == null) {
      throw StateError('No notification handler for method $method');
    }
    h(params);
  }
}

/// Disposable that removes a handler on dispose.
class _HandlerDisposable implements IDisposable {
  final String method;
  final Map<String, Future<Object?> Function(Object?)> handlers;
  _HandlerDisposable(this.method, this.handlers);

  @override
  void dispose() {
    handlers.remove(method);
  }
}
