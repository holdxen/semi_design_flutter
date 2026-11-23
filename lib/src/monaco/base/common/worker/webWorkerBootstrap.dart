// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/worker/webWorkerBootstrap.ts
// Translated 1:1 from TypeScript.
//   - `declare const globalThis: { postMessage, onmessage }` -> injectable
//     `bootstrapGlobalThis` carrier.
//   - `MessageEvent` -> `BootstrapMessageEvent` shape.
//   - generic `<T extends IWebWorkerServerRequestHandler>` -> `Object` handler
//     (the Dart worker port erases the handler type parameter).
// ---------------------------------------------------------------------------

import 'webWorker.dart'
    show IWebWorkerServerRequestHandlerFactory, WebWorkerServer;

/// 1:1: `type MessageEvent = { data: unknown }`
class BootstrapMessageEvent {
  BootstrapMessageEvent(this.data);
  final Object? data;
}

/// 1:1: worker `globalThis` with `postMessage`/`onmessage`.
class BootstrapGlobalThis {
  BootstrapGlobalThis({
    void Function(Object? message)? postMessage,
    void Function(BootstrapMessageEvent event)? onmessage,
  })  : postMessage = postMessage ?? ((Object? message) {}),
        onmessage = onmessage;

  void Function(Object? message) postMessage;
  void Function(BootstrapMessageEvent event)? onmessage;

  /// Deliver a raw message to the installed handler.
  void deliver(Object? data) => onmessage?.call(BootstrapMessageEvent(data));
}

/// Injectable `globalThis` (defaults to a carrier; tests can observe calls).
BootstrapGlobalThis bootstrapGlobalThis = BootstrapGlobalThis();

bool _initialized = false;

/// 1:1: `export function initialize<T>(factory)`
WebWorkerServer initializeBootstrap(
  IWebWorkerServerRequestHandlerFactory factory,
) {
  if (_initialized) {
    throw StateError('WebWorker already initialized!');
  }
  _initialized = true;

  final WebWorkerServer webWorkerServer = WebWorkerServer(
    (Object? msg, [List<Object?> transfer = const <Object?>[]]) =>
        bootstrapGlobalThis.postMessage(msg),
    factory,
  );

  bootstrapGlobalThis.onmessage = (BootstrapMessageEvent e) {
    webWorkerServer.onmessage(e.data);
  };

  return webWorkerServer;
}

/// 1:1: `export function bootstrapWebWorker(factory)`
void bootstrapWebWorker(IWebWorkerServerRequestHandlerFactory factory) {
  bootstrapGlobalThis.onmessage = (BootstrapMessageEvent _e) {
    // Ignore first message; initialize if not yet initialized.
    if (!_initialized) {
      initializeBootstrap(factory);
    }
  };
}

/// Test hook: reset the module-level `initialized` flag.
void resetBootstrapInitializedForTest() {
  _initialized = false;
  bootstrapGlobalThis = BootstrapGlobalThis();
}
