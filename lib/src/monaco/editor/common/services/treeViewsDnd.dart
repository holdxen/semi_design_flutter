// 1:1 port of vs/editor/common/services/treeViewsDnd.ts

/// 1:1: `export interface ITreeViewsDnDService<T>`
abstract class ITreeViewsDnDService<T> {
  Future<T?>? removeDragOperationTransfer(String? uuid);
  void addDragOperationTransfer(String uuid, Future<T?> transferPromise);
}

/// 1:1: `export class TreeViewsDnDService<T>`
class TreeViewsDnDService<T> implements ITreeViewsDnDService<T> {
  final Map<String, Future<T?>> _dragOperations = <String, Future<T?>>{};

  @override
  Future<T?>? removeDragOperationTransfer(String? uuid) {
    if (uuid != null && uuid.isNotEmpty && _dragOperations.containsKey(uuid)) {
      final Future<T?>? operation = _dragOperations[uuid];
      _dragOperations.remove(uuid);
      return operation;
    }
    return null;
  }

  @override
  void addDragOperationTransfer(String uuid, Future<T?> transferPromise) {
    _dragOperations[uuid] = transferPromise;
  }
}

/// 1:1: `export class DraggedTreeItemsIdentifier`
class DraggedTreeItemsIdentifier {
  final String identifier;
  DraggedTreeItemsIdentifier(this.identifier);
}
