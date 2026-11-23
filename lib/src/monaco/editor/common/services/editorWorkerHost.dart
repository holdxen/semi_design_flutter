// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/editorWorkerHost.ts
// Translated 1:1 from TypeScript.
//   - `IWebWorkerClient<unknown>` -> non-generic `IWebWorkerClient` in the
//     Dart worker port.
//   - generic `getChannel<T>` / `setChannel<T>` -> runtime `as` cast (the
//     Dart surface returns/stores `Object`).
// ---------------------------------------------------------------------------

import '../../../base/common/worker/webWorker.dart'
    show IWebWorkerClient, IWebWorkerServer;

/// 1:1: `export abstract class EditorWorkerHost`
abstract class EditorWorkerHost {
  /// 1:1: `public static CHANNEL_NAME = 'editorWorkerHost'`
  static const String CHANNEL_NAME = 'editorWorkerHost';

  /// 1:1: `public static getChannel(workerServer)`
  static EditorWorkerHost getChannel(IWebWorkerServer workerServer) =>
      workerServer.getChannel(CHANNEL_NAME) as EditorWorkerHost;

  /// 1:1: `public static setChannel(workerClient, obj)`
  static void setChannel(IWebWorkerClient workerClient, EditorWorkerHost obj) =>
      workerClient.setChannel(CHANNEL_NAME, obj);

  /// 1:1: foreign host request. `abstract $fhr(method, args): Promise<unknown>`
  Future<Object?> $fhr(String method, List<Object?> args);
}
