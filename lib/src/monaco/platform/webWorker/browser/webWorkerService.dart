// 1:1 port of vs/platform/webWorker/browser/webWorkerService.ts
// Pure declaration file: decorator + interface.
import '../../../base/common/worker/webWorker.dart' show IWebWorkerClient;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import 'webWorkerDescriptor.dart' show WebWorkerDescriptor;

/// 1:1: `export const IWebWorkerService = createDecorator<IWebWorkerService>('IWebWorkerService')`
final ServiceIdentifier<IWebWorkerServiceType> IWebWorkerService =
    createDecorator<IWebWorkerServiceType>('IWebWorkerService');

/// 1:1: `export interface IWebWorkerService` (const keeps bare name).
abstract class IWebWorkerServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `createWorkerClient<T extends object>(workerDescriptor: WebWorkerDescriptor | Worker | Promise<Worker>): IWebWorkerClient<T>`
  /// TS union -> `Object?` carrier.
  IWebWorkerClient createWorkerClient(Object workerDescriptor);

  /// 1:1: `getWorkerUrl(descriptor: WebWorkerDescriptor): string`
  String getWorkerUrl(WebWorkerDescriptor descriptor);
}
