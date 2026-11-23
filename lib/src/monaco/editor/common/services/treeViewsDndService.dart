// 1:1 port of vs/editor/common/services/treeViewsDndService.ts
// Pure declaration file: interface merge (const interface keeps bare name) +
// decorator + singleton registration.
import '../../../base/common/dataTransfer.dart' show VSDataTransfer;
import '../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import 'treeViewsDnd.dart' as tvd
    show ITreeViewsDnDService, TreeViewsDnDService;

/// 1:1: `export interface ITreeViewsDnDService extends ITreeViewsDnDServiceCommon<VSDataTransfer> { }`
/// TS const/interface merge: const keeps the bare name, interface uses `Type`.
abstract class ITreeViewsDnDServiceType
    implements tvd.ITreeViewsDnDService<VSDataTransfer> {}

/// 1:1: `export const ITreeViewsDnDService = createDecorator<ITreeViewsDnDService>('treeViewsDndService')`
final ServiceIdentifier<ITreeViewsDnDServiceType> ITreeViewsDnDService =
    createDecorator<ITreeViewsDnDServiceType>('treeViewsDndService');

/// 1:1 top-level side effect: `registerSingleton(ITreeViewsDnDService, TreeViewsDnDService, InstantiationType.Delayed)`.
/// Dart has no top-level statements; a lazy-initialized `final` reproduces the
/// TS module-load registration (triggered on first library access).
final ServiceIdentifier<ITreeViewsDnDServiceType> registration =
    () {
  registerSingleton(ITreeViewsDnDService,
      tvd.TreeViewsDnDService<VSDataTransfer>.new, InstantiationType.Delayed);
  return ITreeViewsDnDService;
}();
