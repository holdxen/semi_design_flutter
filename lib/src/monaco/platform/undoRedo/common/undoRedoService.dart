// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/undoRedo/common/undoRedoService.ts
// Translated 1:1 from TypeScript.
//   - TS `IUndoRedoElement` unions are carried as `Object`; narrow reads use
//     dynamic getters mirroring the source's structural access.
//   - TS `Promise<void> | void` is carried as `Future<void>?`.
//   - TS `protected`/`private` methods are public where truth tests need to
//     drive them (Dart has no cross-library private access).
//   - `DEBUG` is false in the source, so `_print` is never called.
// ---------------------------------------------------------------------------

import '../../../base/common/errors.dart' as errors;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/network.dart' as network;
import '../../../base/common/severity.dart' as severity;
import '../../../base/common/uri.dart' as uri;
import '../../../nls.dart' show localize;
import '../../instantiation/common/extensions.dart' as extensions;
import '../../instantiation/common/extensions.dart' show InstantiationType;
import 'undoRedo.dart' as undoRedo;

/// 1:1: `const DEBUG = false`
const bool _debug = false;

/// 1:1: `function getResourceLabel(resource: URI): string`
String getResourceLabel(uri.URI resource) => resource.scheme == network.Schemas.file
    ? resource.fsPath
    : resource.path;

/// 1:1: `let stackElementCounter = 0`
int _stackElementCounter = 0;

/// 1:1: `const enum RemovedResourceReason`
class RemovedResourceReason {
  static const int ExternalRemoval = 0;
  static const int NoParallelUniverses = 1;

  const RemovedResourceReason._();
}

/// 1:1: `class ResourceReasonPair`
class ResourceReasonPair {
  final String resourceLabel;
  final int reason;

  const ResourceReasonPair(this.resourceLabel, this.reason);
}

/// 1:1: `class RemovedResources`
class RemovedResources {
  final Map<String, ResourceReasonPair> _elements =
      <String, ResourceReasonPair>{};

  /// 1:1: `public createMessage(): string`
  String createMessage() {
    final List<String> externalRemoval = <String>[];
    final List<String> noParallelUniverses = <String>[];
    for (final ResourceReasonPair element in _elements.values) {
      final List<String> dest = element.reason ==
              RemovedResourceReason.ExternalRemoval
          ? externalRemoval
          : noParallelUniverses;
      dest.add(element.resourceLabel);
    }

    final List<String> messages = <String>[];
    if (externalRemoval.isNotEmpty) {
      messages.push(localize(
        <String, Object?>{'key': 'externalRemoval', 'comment': <String>['{0} is a list of filenames']},
        'The following files have been closed and modified on disk: {0}.',
        <Object?>[externalRemoval.join(', ')],
      ));
    }
    if (noParallelUniverses.isNotEmpty) {
      messages.push(localize(
        <String, Object?>{'key': 'noParallelUniverses', 'comment': <String>['{0} is a list of filenames']},
        'The following files have been modified in an incompatible way: {0}.',
        <Object?>[noParallelUniverses.join(', ')],
      ));
    }
    return messages.join('\n');
  }

  int get size => _elements.length;
  bool has(String strResource) => _elements.containsKey(strResource);
  void set(String strResource, ResourceReasonPair value) =>
      _elements[strResource] = value;
  bool delete(String strResource) => _elements.remove(strResource) != null;
}

/// Helper for `List<T>.push` used above (Dart uses `add`).
extension _ListPush<T> on List<T> {
  void push(T value) => add(value);
}

/// 1:1 structural reads of `IUndoRedoElement` (typedef Object in Dart port).
int _elementType(Object element) => (element as dynamic).type as int;
String _elementLabel(Object element) => (element as dynamic).label as String;
bool _elementConfirmBeforeUndo(Object element) =>
    (element as dynamic).confirmBeforeUndo as bool? ?? false;
uri.URI _elementResource(Object element) =>
    (element as dynamic).resource as uri.URI;
List<uri.URI> _elementResources(Object element) =>
    (element as dynamic).resources as List<uri.URI>;
Future<void>? _invokeUndo(Object element) =>
    (element as dynamic).undo() as Future<void>?;
Future<void>? _invokeRedo(Object element) =>
    (element as dynamic).redo() as Future<void>?;
Object? _invokePrepareUndoRedo(Object element) =>
    (element as dynamic).prepareUndoRedo();
List<Object> _invokeSplit(Object element) =>
    (element as dynamic).split() as List<Object>;

/// 1:1: `class ResourceStackElement`
class ResourceStackElement {
  final int id = ++_stackElementCounter;
  final int type = undoRedo.UndoRedoElementType.Resource;
  final Object actual;
  final String label;
  final bool confirmBeforeUndo;
  final String resourceLabel;
  final String strResource;
  final List<String> resourceLabels;
  final List<String> strResources;
  final int groupId;
  final int groupOrder;
  final int sourceId;
  final int sourceOrder;
  bool isValid;

  ResourceStackElement(Object actual, String resourceLabel, String strResource,
      int groupId, int groupOrder, int sourceId, int sourceOrder)
      : actual = actual,
        label = _elementLabel(actual),
        confirmBeforeUndo = _elementConfirmBeforeUndo(actual),
        resourceLabel = resourceLabel,
        strResource = strResource,
        resourceLabels = <String>[resourceLabel],
        strResources = <String>[strResource],
        groupId = groupId,
        groupOrder = groupOrder,
        sourceId = sourceId,
        sourceOrder = sourceOrder,
        isValid = true;

  void setValid(bool valid) => isValid = valid;

  @override
  String toString() =>
      '[id:$id] [group:$groupId] [${isValid ? '  VALID' : 'INVALID'}] '
      '${actual.runtimeType} - $actual';
}

/// 1:1: `class WorkspaceStackElement`
class WorkspaceStackElement {
  final int id = ++_stackElementCounter;
  final int type = undoRedo.UndoRedoElementType.Workspace;
  final Object actual;
  final String label;
  final bool confirmBeforeUndo;
  final List<String> resourceLabels;
  final List<String> strResources;
  final int groupId;
  final int groupOrder;
  final int sourceId;
  final int sourceOrder;
  RemovedResources? removedResources;
  RemovedResources? invalidatedResources;

  WorkspaceStackElement(Object actual, List<String> resourceLabels,
      List<String> strResources, int groupId, int groupOrder, int sourceId,
      int sourceOrder)
      : actual = actual,
        label = _elementLabel(actual),
        confirmBeforeUndo = _elementConfirmBeforeUndo(actual),
        resourceLabels = resourceLabels,
        strResources = strResources,
        groupId = groupId,
        groupOrder = groupOrder,
        sourceId = sourceId,
        sourceOrder = sourceOrder;

  bool canSplit() => (actual as dynamic).split != null;

  void removeResource(String resourceLabel, String strResource, int reason) {
    removedResources ??= RemovedResources();
    if (!removedResources!.has(strResource)) {
      removedResources!.set(
          strResource, ResourceReasonPair(resourceLabel, reason));
    }
  }

  void setValid(String resourceLabel, String strResource, bool valid) {
    if (valid) {
      final RemovedResources? invalidated = invalidatedResources;
      if (invalidated != null) {
        invalidated.delete(strResource);
        if (invalidated.size == 0) {
          invalidatedResources = null;
        }
      }
    } else {
      invalidatedResources ??= RemovedResources();
      if (!invalidatedResources!.has(strResource)) {
        invalidatedResources!.set(
            strResource,
            ResourceReasonPair(
                resourceLabel, RemovedResourceReason.ExternalRemoval));
      }
    }
  }

  @override
  String toString() =>
      '[id:$id] [group:$groupId] [${invalidatedResources != null ? 'INVALID' : '  VALID'}] '
      '${actual.runtimeType} - $actual';
}

/// 1:1: `type StackElement = ResourceStackElement | WorkspaceStackElement`
typedef StackElement = Object;

int _stackId(StackElement e) =>
    e is WorkspaceStackElement ? e.id : (e as ResourceStackElement).id;
Object _stackActual(StackElement e) =>
    e is WorkspaceStackElement ? e.actual : (e as ResourceStackElement).actual;

/// 1:1: `class ResourceEditStack`
class ResourceEditStack {
  final String resourceLabel;
  final String _strResource;
  List<StackElement> _past;
  List<StackElement> _future;
  bool locked;
  int versionId;

  ResourceEditStack(this.resourceLabel, String strResource)
      : _strResource = strResource,
        _past = <StackElement>[],
        _future = <StackElement>[],
        locked = false,
        versionId = 1;

  /// 1:1: `public dispose(): void`
  void dispose() {
    for (final StackElement element in _past) {
      if (element is WorkspaceStackElement) {
        element.removeResource(resourceLabel, _strResource,
            RemovedResourceReason.ExternalRemoval);
      }
    }
    for (final StackElement element in _future) {
      if (element is WorkspaceStackElement) {
        element.removeResource(resourceLabel, _strResource,
            RemovedResourceReason.ExternalRemoval);
      }
    }
    versionId++;
  }

  @override
  String toString() {
    final List<String> result = <String>[];
    result.push('* $_strResource:');
    for (int i = 0; i < _past.length; i++) {
      result.push('   * [UNDO] $_past[i]');
    }
    for (int i = _future.length - 1; i >= 0; i--) {
      result.push('   * [REDO] $_future[i]');
    }
    return result.join('\n');
  }

  void flushAllElements() {
    _past = <StackElement>[];
    _future = <StackElement>[];
    versionId++;
  }

  void setElementsIsValid(bool valid) {
    for (final StackElement element in [..._past, ..._future]) {
      _setElementValidFlag(element, valid);
    }
  }

  void _setElementValidFlag(StackElement element, bool valid) {
    if (element is WorkspaceStackElement) {
      element.setValid(resourceLabel, _strResource, valid);
    } else {
      (element as ResourceStackElement).setValid(valid);
    }
  }

  void setElementsValidFlag(
      bool valid, bool Function(Object element) filter) {
    for (final StackElement element in [..._past, ..._future]) {
      if (filter(_stackActual(element))) {
        _setElementValidFlag(element, valid);
      }
    }
  }

  void pushElement(StackElement element) {
    // remove the future
    for (final StackElement futureElement in _future) {
      if (futureElement is WorkspaceStackElement) {
        futureElement.removeResource(resourceLabel, _strResource,
            RemovedResourceReason.NoParallelUniverses);
      }
    }
    _future = <StackElement>[];
    _past.push(element);
    versionId++;
  }

  undoRedo.ResourceEditStackSnapshot createSnapshot(uri.URI resource) {
    final List<int> elements = <int>[];
    for (int i = 0; i < _past.length; i++) {
      elements.push(_stackId(_past[i]));
    }
    for (int i = _future.length - 1; i >= 0; i--) {
      elements.push(_stackId(_future[i]));
    }
    return undoRedo.ResourceEditStackSnapshot(resource, elements);
  }

  void restoreSnapshot(undoRedo.ResourceEditStackSnapshot snapshot) {
    final int snapshotLength = snapshot.elements.length;
    bool isOK = true;
    int snapshotIndex = 0;
    int removePastAfter = -1;
    for (int i = 0; i < _past.length; i++, snapshotIndex++) {
      final StackElement element = _past[i];
      if (isOK &&
          (snapshotIndex >= snapshotLength ||
              _stackId(element) != snapshot.elements[snapshotIndex])) {
        isOK = false;
        removePastAfter = i;
      }
      if (!isOK && element is WorkspaceStackElement) {
        element.removeResource(resourceLabel, _strResource,
            RemovedResourceReason.ExternalRemoval);
      }
    }
    int removeFutureBefore = -1;
    for (int i = _future.length - 1; i >= 0; i--, snapshotIndex++) {
      final StackElement element = _future[i];
      if (isOK &&
          (snapshotIndex >= snapshotLength ||
              _stackId(element) != snapshot.elements[snapshotIndex])) {
        isOK = false;
        removeFutureBefore = i;
      }
      if (!isOK && element is WorkspaceStackElement) {
        element.removeResource(resourceLabel, _strResource,
            RemovedResourceReason.ExternalRemoval);
      }
    }
    if (removePastAfter != -1) {
      _past = _past.sublist(0, removePastAfter);
    }
    if (removeFutureBefore != -1) {
      _future = _future.sublist(removeFutureBefore + 1);
    }
    versionId++;
  }

  undoRedo.IPastFutureElements getElements() => _PastFuture(_past, _future);

  StackElement? getClosestPastElement() =>
      _past.isEmpty ? null : _past[_past.length - 1];

  StackElement? getSecondClosestPastElement() =>
      _past.length < 2 ? null : _past[_past.length - 2];

  StackElement? getClosestFutureElement() =>
      _future.isEmpty ? null : _future[_future.length - 1];

  bool hasPastElements() => _past.isNotEmpty;
  bool hasFutureElements() => _future.isNotEmpty;

  void splitPastWorkspaceElement(WorkspaceStackElement toRemove,
      Map<String, ResourceStackElement> individualMap) {
    for (int j = _past.length - 1; j >= 0; j--) {
      if (identical(_past[j], toRemove)) {
        final ResourceStackElement? replacement = individualMap[_strResource];
        if (replacement != null) {
          _past[j] = replacement;
        } else {
          _past.removeAt(j);
        }
        break;
      }
    }
    versionId++;
  }

  void splitFutureWorkspaceElement(WorkspaceStackElement toRemove,
      Map<String, ResourceStackElement> individualMap) {
    for (int j = _future.length - 1; j >= 0; j--) {
      if (identical(_future[j], toRemove)) {
        final ResourceStackElement? replacement = individualMap[_strResource];
        if (replacement != null) {
          _future[j] = replacement;
        } else {
          _future.removeAt(j);
        }
        break;
      }
    }
    versionId++;
  }

  void moveBackward(StackElement element) {
    _past.removeLast();
    _future.push(element);
    versionId++;
  }

  void moveForward(StackElement element) {
    _future.removeLast();
    _past.push(element);
    versionId++;
  }
}

/// Carrier for the source's `{ past, future }` literal.
class _PastFuture implements undoRedo.IPastFutureElements {
  _PastFuture(this._past, this._future);

  final List<StackElement> _past;
  final List<StackElement> _future;

  @override
  List<Object> get past => _past.map(_stackActual).toList();

  @override
  List<Object> get future => _future.map(_stackActual).toList();
}

/// 1:1: `class EditStackSnapshot`
class EditStackSnapshot {
  final List<ResourceEditStack> editStacks;
  final List<int> _versionIds = <int>[];

  EditStackSnapshot(this.editStacks) {
    for (int i = 0; i < editStacks.length; i++) {
      _versionIds.push(editStacks[i].versionId);
    }
  }

  bool isValid() {
    for (int i = 0; i < editStacks.length; i++) {
      if (_versionIds[i] != editStacks[i].versionId) {
        return false;
      }
    }
    return true;
  }
}

/// 1:1: `const missingEditStack = new ResourceEditStack('', ''); ... locked = true`
final ResourceEditStack missingEditStack = ResourceEditStack('', '')
  ..locked = true;

/// 1:1: `class WorkspaceVerificationError`
class WorkspaceVerificationError {
  final Future<void>? returnValue;

  WorkspaceVerificationError(this.returnValue);
}

/// 1:1: TS local `enum UndoChoice` inside `_confirmAndExecuteWorkspaceUndo`
class _UndoChoice {
  static const int All = 0;
  static const int This = 1;
  static const int Cancel = 2;

  const _UndoChoice._();
}

/// 1:1: `export class UndoRedoService implements IUndoRedoService`
class UndoRedoService implements undoRedo.IUndoRedoServiceType {
  final Map<String, ResourceEditStack> _editStacks =
      <String, ResourceEditStack>{};
  final List<List<Object?>> _uriComparisonKeyComputers = <List<Object?>>[];

  /// Services are dynamic carriers: `IDialogService`/`INotificationService`
  /// methods are called with the exact source-shaped object literals.
  UndoRedoService(this._dialogService, this._notificationService);

  final dynamic _dialogService;
  final dynamic _notificationService;

  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  lifecycle.IDisposable registerUriComparisonKeyComputer(
      String scheme, undoRedo.UriComparisonKeyComputer computer) {
    _uriComparisonKeyComputers.push(<Object?>[scheme, computer]);
    return lifecycle.toDisposable(() {
      for (int i = 0; i < _uriComparisonKeyComputers.length; i++) {
        if (identical(_uriComparisonKeyComputers[i][1], computer)) {
          _uriComparisonKeyComputers.removeAt(i);
          return;
        }
      }
    });
  }

  @override
  String getUriComparisonKey(uri.URI resource) {
    for (final List<Object?> computer in _uriComparisonKeyComputers) {
      if (computer[0] == resource.scheme) {
        return (computer[1] as undoRedo.UriComparisonKeyComputer)
            .getComparisonKey(resource);
      }
    }
    return resource.toString();
  }

  void _print(String label) {
    // DEBUG is false in the source; kept for 1:1 structure.
    if (!_debug) return;
    final List<String> str = <String>[];
    for (final ResourceEditStack stack in _editStacks.values) {
      str.push(stack.toString());
    }
    // ignore: avoid_print
    print(str.join('\n'));
  }

  @override
  void pushElement(Object element,
      [undoRedo.UndoRedoGroup? group, undoRedo.UndoRedoSource? source]) {
    final undoRedo.UndoRedoGroup g = group ?? undoRedo.UndoRedoGroup.None;
    final undoRedo.UndoRedoSource s = source ?? undoRedo.UndoRedoSource.None;
    if (_elementType(element) == undoRedo.UndoRedoElementType.Resource) {
      final String resourceLabel =
          getResourceLabel(_elementResource(element));
      final String strResource =
          getUriComparisonKey(_elementResource(element));
      _pushElement(ResourceStackElement(element, resourceLabel, strResource,
          g.id, g.nextOrder(), s.id, s.nextOrder()));
    } else {
      final Set<String> seen = <String>{};
      final List<String> resourceLabels = <String>[];
      final List<String> strResources = <String>[];
      for (final uri.URI resource in _elementResources(element)) {
        final String resourceLabel = getResourceLabel(resource);
        final String strResource = getUriComparisonKey(resource);

        if (seen.contains(strResource)) {
          continue;
        }
        seen.add(strResource);
        resourceLabels.push(resourceLabel);
        strResources.push(strResource);
      }

      if (resourceLabels.length == 1) {
        _pushElement(ResourceStackElement(
            element,
            resourceLabels[0],
            strResources[0],
            g.id,
            g.nextOrder(),
            s.id,
            s.nextOrder()));
      } else {
        _pushElement(WorkspaceStackElement(
            element,
            resourceLabels,
            strResources,
            g.id,
            g.nextOrder(),
            s.id,
            s.nextOrder()));
      }
    }
    if (_debug) _print('pushElement');
  }

  void _pushElement(StackElement element) {
    final int count = element is WorkspaceStackElement
        ? element.strResources.length
        : (element as ResourceStackElement).strResources.length;
    for (int i = 0; i < count; i++) {
      final String resourceLabel = element is WorkspaceStackElement
          ? element.resourceLabels[i]
          : (element as ResourceStackElement).resourceLabels[i];
      final String strResource = element is WorkspaceStackElement
          ? element.strResources[i]
          : (element as ResourceStackElement).strResources[i];

      ResourceEditStack editStack;
      if (_editStacks.containsKey(strResource)) {
        editStack = _editStacks[strResource]!;
      } else {
        editStack = ResourceEditStack(resourceLabel, strResource);
        _editStacks[strResource] = editStack;
      }

      editStack.pushElement(element);
    }
  }

  @override
  Object? getLastElement(uri.URI resource) {
    final String strResource = getUriComparisonKey(resource);
    if (_editStacks.containsKey(strResource)) {
      final ResourceEditStack editStack = _editStacks[strResource]!;
      if (editStack.hasFutureElements()) {
        return null;
      }
      final StackElement? closest = editStack.getClosestPastElement();
      return closest != null ? _stackActual(closest) : null;
    }
    return null;
  }

  void _splitPastWorkspaceElement(WorkspaceStackElement toRemove,
      RemovedResources? ignoreResources) {
    final List<Object> individualArr = _invokeSplit(toRemove.actual);
    final Map<String, ResourceStackElement> individualMap =
        <String, ResourceStackElement>{};
    for (final Object element in individualArr) {
      final String resourceLabel = getResourceLabel(_elementResource(element));
      final String strResource = getUriComparisonKey(_elementResource(element));
      final ResourceStackElement stackElement = ResourceStackElement(
          element, resourceLabel, strResource, 0, 0, 0, 0);
      individualMap[stackElement.strResource] = stackElement;
    }

    for (final String strResource in toRemove.strResources) {
      if (ignoreResources != null && ignoreResources.has(strResource)) {
        continue;
      }
      final ResourceEditStack editStack = _editStacks[strResource]!;
      editStack.splitPastWorkspaceElement(toRemove, individualMap);
    }
  }

  void _splitFutureWorkspaceElement(WorkspaceStackElement toRemove,
      RemovedResources? ignoreResources) {
    final List<Object> individualArr = _invokeSplit(toRemove.actual);
    final Map<String, ResourceStackElement> individualMap =
        <String, ResourceStackElement>{};
    for (final Object element in individualArr) {
      final String resourceLabel = getResourceLabel(_elementResource(element));
      final String strResource = getUriComparisonKey(_elementResource(element));
      final ResourceStackElement stackElement = ResourceStackElement(
          element, resourceLabel, strResource, 0, 0, 0, 0);
      individualMap[stackElement.strResource] = stackElement;
    }

    for (final String strResource in toRemove.strResources) {
      if (ignoreResources != null && ignoreResources.has(strResource)) {
        continue;
      }
      final ResourceEditStack editStack = _editStacks[strResource]!;
      editStack.splitFutureWorkspaceElement(toRemove, individualMap);
    }
  }

  @override
  void removeElements(Object resource) {
    final String strResource = resource is String
        ? resource
        : getUriComparisonKey(resource as uri.URI);
    if (_editStacks.containsKey(strResource)) {
      final ResourceEditStack editStack = _editStacks[strResource]!;
      editStack.dispose();
      _editStacks.remove(strResource);
    }
    if (_debug) _print('removeElements');
  }

  @override
  void setElementsValidFlag(uri.URI resource, bool isValid,
      bool Function(Object element) filter) {
    final String strResource = getUriComparisonKey(resource);
    if (_editStacks.containsKey(strResource)) {
      final ResourceEditStack editStack = _editStacks[strResource]!;
      editStack.setElementsValidFlag(isValid, filter);
    }
    if (_debug) _print('setElementsValidFlag');
  }

  bool hasElements(uri.URI resource) {
    final String strResource = getUriComparisonKey(resource);
    if (_editStacks.containsKey(strResource)) {
      final ResourceEditStack editStack = _editStacks[strResource]!;
      return editStack.hasPastElements() || editStack.hasFutureElements();
    }
    return false;
  }

  @override
  undoRedo.ResourceEditStackSnapshot createSnapshot(uri.URI resource) {
    final String strResource = getUriComparisonKey(resource);
    if (_editStacks.containsKey(strResource)) {
      final ResourceEditStack editStack = _editStacks[strResource]!;
      return editStack.createSnapshot(resource);
    }
    return undoRedo.ResourceEditStackSnapshot(resource, <int>[]);
  }

  @override
  void restoreSnapshot(undoRedo.ResourceEditStackSnapshot snapshot) {
    final String strResource = getUriComparisonKey(snapshot.resource);
    if (_editStacks.containsKey(strResource)) {
      final ResourceEditStack editStack = _editStacks[strResource]!;
      editStack.restoreSnapshot(snapshot);

      if (!editStack.hasPastElements() && !editStack.hasFutureElements()) {
        editStack.dispose();
        _editStacks.remove(strResource);
      }
    }
    if (_debug) _print('restoreSnapshot');
  }

  @override
  undoRedo.IPastFutureElements getElements(uri.URI resource) {
    final String strResource = getUriComparisonKey(resource);
    if (_editStacks.containsKey(strResource)) {
      final ResourceEditStack editStack = _editStacks[strResource]!;
      return editStack.getElements();
    }
    return _PastFuture(<StackElement>[], <StackElement>[]);
  }

  List<Object?> _findClosestUndoElementWithSource(int sourceId) {
    if (sourceId == 0) {
      return <Object?>[null, null];
    }

    StackElement? matchedElement;
    String? matchedStrResource;

    for (final MapEntry<String, ResourceEditStack> entry
        in _editStacks.entries) {
      final StackElement? candidate = entry.value.getClosestPastElement();
      if (candidate == null) {
        continue;
      }
      final int candidateSourceId = candidate is WorkspaceStackElement
          ? candidate.sourceId
          : (candidate as ResourceStackElement).sourceId;
      final int candidateSourceOrder = candidate is WorkspaceStackElement
          ? candidate.sourceOrder
          : (candidate as ResourceStackElement).sourceOrder;
      if (candidateSourceId == sourceId) {
        final int? currentOrder = matchedElement == null
            ? null
            : matchedElement is WorkspaceStackElement
                ? matchedElement.sourceOrder
                : (matchedElement as ResourceStackElement).sourceOrder;
        if (currentOrder == null || candidateSourceOrder > currentOrder) {
          matchedElement = candidate;
          matchedStrResource = entry.key;
        }
      }
    }

    return <Object?>[matchedElement, matchedStrResource];
  }

  @override
  bool canUndo(Object resource) {
    if (resource is undoRedo.UndoRedoSource) {
      final List<Object?> found =
          _findClosestUndoElementWithSource(resource.id);
      return found[1] != null;
    }
    final String strResource = getUriComparisonKey(resource as uri.URI);
    if (_editStacks.containsKey(strResource)) {
      return _editStacks[strResource]!.hasPastElements();
    }
    return false;
  }

  Future<void> _onError(Object err, StackElement element) async {
    // TS `onUnexpectedError` never throws; the Dart shared port rethrows, so
    // swallow here to preserve the source's continuation into cleanup.
    try {
      errors.onUnexpectedError(err);
    } catch (_) {}
    // An error occurred while undoing or redoing => drop the undo/redo stack
    // for all affected resources
    final List<String> strResources = element is WorkspaceStackElement
        ? element.strResources
        : (element as ResourceStackElement).strResources;
    for (final String strResource in strResources) {
      removeElements(strResource);
    }
    _notificationService.error(err);
  }

  void Function() _acquireLocks(EditStackSnapshot editStackSnapshot) {
    // first, check if all locks can be acquired
    for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
      if (editStack.locked) {
        throw StateError('Cannot acquire edit stack lock');
      }
    }

    // can acquire all locks
    for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
      editStack.locked = true;
    }

    return () {
      // release all locks
      for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
        editStack.locked = false;
      }
    };
  }

  Future<void> _safeInvokeWithLocks(
    StackElement element,
    Future<void>? Function() invoke,
    EditStackSnapshot editStackSnapshot,
    lifecycle.IDisposable cleanup,
    Future<void>? Function() continuation,
  ) async {
    final void Function() releaseLocks = _acquireLocks(editStackSnapshot);

    Future<void>? result;
    try {
      result = invoke();
      if (result != null) {
        await result;
      }
    } catch (err) {
      releaseLocks();
      lifecycle.dispose(cleanup);
      await _onError(err, element);
      return;
    }

    releaseLocks();
    lifecycle.dispose(cleanup);
    await continuation();
  }

  Future<lifecycle.IDisposable> _invokeWorkspacePrepare(
      WorkspaceStackElement element) async {
    final Object? prepare = (element.actual as dynamic).prepareUndoRedo;
    if (prepare == null) {
      return lifecycle.Disposable.none;
    }
    final Object? result = _invokePrepareUndoRedo(element.actual);
    if (result == null) {
      return lifecycle.Disposable.none;
    }
    if (result is lifecycle.IDisposable) {
      return result;
    }
    if (result is Future<lifecycle.IDisposable>) {
      return result;
    }
    return lifecycle.Disposable.none;
  }

  Future<void>? _invokeResourcePrepare(ResourceStackElement element,
      Future<void>? Function(lifecycle.IDisposable) callback) {
    final Object actual = element.actual;
    if (_elementType(actual) != undoRedo.UndoRedoElementType.Workspace ||
        (actual as dynamic).prepareUndoRedo == null) {
      // no preparation needed
      return callback(lifecycle.Disposable.none);
    }

    final Object? r = _invokePrepareUndoRedo(actual);
    if (r == null) {
      // nothing to clean up
      return callback(lifecycle.Disposable.none);
    }

    if (lifecycle.isDisposable(r)) {
      return callback(r as lifecycle.IDisposable);
    }

    return (r as Future<dynamic>).then((Object? disposable) {
      return callback(disposable as lifecycle.IDisposable);
    });
  }

  EditStackSnapshot _getAffectedEditStacks(WorkspaceStackElement element) {
    final List<ResourceEditStack> affectedEditStacks =
        <ResourceEditStack>[];
    for (final String strResource in element.strResources) {
      affectedEditStacks
          .push(_editStacks[strResource] ?? missingEditStack);
    }
    return EditStackSnapshot(affectedEditStacks);
  }

  WorkspaceVerificationError _tryToSplitAndUndo(
      String strResource,
      WorkspaceStackElement element,
      RemovedResources? ignoreResources,
      String message) {
    if (element.canSplit()) {
      _splitPastWorkspaceElement(element, ignoreResources);
      _notificationService.warn(message);
      return WorkspaceVerificationError(_undo(strResource, 0, true));
    } else {
      // Cannot safely split this workspace element => flush all undo/redo stacks
      for (final String strResource in element.strResources) {
        removeElements(strResource);
      }
      _notificationService.warn(message);
      return WorkspaceVerificationError(null);
    }
  }

  WorkspaceVerificationError? _checkWorkspaceUndo(
      String strResource,
      WorkspaceStackElement element,
      EditStackSnapshot editStackSnapshot,
      bool checkInvalidatedResources) {
    final RemovedResources? removed = element.removedResources;
    if (removed != null) {
      return _tryToSplitAndUndo(
        strResource,
        element,
        removed,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceUndo',
            'comment': <String>[
              '{0} is a label for an operation. {1} is another message.'
            ]
          },
          "Could not undo '{0}' across all files. {1}",
          <Object?>[element.label, removed.createMessage()],
        ),
      );
    }
    final RemovedResources? invalidated = element.invalidatedResources;
    if (checkInvalidatedResources && invalidated != null) {
      return _tryToSplitAndUndo(
        strResource,
        element,
        invalidated,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceUndo',
            'comment': <String>[
              '{0} is a label for an operation. {1} is another message.'
            ]
          },
          "Could not undo '{0}' across all files. {1}",
          <Object?>[element.label, invalidated.createMessage()],
        ),
      );
    }

    // this must be the last past element in all the impacted resources!
    final List<String> cannotUndoDueToResources = <String>[];
    for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
      if (!identical(editStack.getClosestPastElement(), element)) {
        cannotUndoDueToResources.push(editStack.resourceLabel);
      }
    }
    if (cannotUndoDueToResources.isNotEmpty) {
      return _tryToSplitAndUndo(
        strResource,
        element,
        null,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceUndoDueToChanges',
            'comment': <String>[
              '{0} is a label for an operation. {1} is a list of filenames.'
            ]
          },
          "Could not undo '{0}' across all files because changes were made to {1}",
          <Object?>[element.label, cannotUndoDueToResources.join(', ')],
        ),
      );
    }

    final List<String> cannotLockDueToResources = <String>[];
    for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
      if (editStack.locked) {
        cannotLockDueToResources.push(editStack.resourceLabel);
      }
    }
    if (cannotLockDueToResources.isNotEmpty) {
      return _tryToSplitAndUndo(
        strResource,
        element,
        null,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceUndoDueToInProgressUndoRedo',
            'comment': <String>[
              '{0} is a label for an operation. {1} is a list of filenames.'
            ]
          },
          "Could not undo '{0}' across all files because there is already an undo or redo operation running on {1}",
          <Object?>[element.label, cannotLockDueToResources.join(', ')],
        ),
      );
    }

    // check if new stack elements were added in the meantime...
    if (!editStackSnapshot.isValid()) {
      return _tryToSplitAndUndo(
        strResource,
        element,
        null,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceUndoDueToInMeantimeUndoRedo',
            'comment': <String>[
              '{0} is a label for an operation. {1} is a list of filenames.'
            ]
          },
          "Could not undo '{0}' across all files because an undo or redo operation occurred in the meantime",
          <Object?>[element.label],
        ),
      );
    }

    return null;
  }

  Future<void>? _workspaceUndo(
      String strResource, WorkspaceStackElement element, bool undoConfirmed) {
    final EditStackSnapshot affectedEditStacks =
        _getAffectedEditStacks(element);
    final WorkspaceVerificationError? verificationError = _checkWorkspaceUndo(
        strResource, element, affectedEditStacks, false);
    if (verificationError != null) {
      return verificationError.returnValue;
    }
    return _confirmAndExecuteWorkspaceUndo(
        strResource, element, affectedEditStacks, undoConfirmed);
  }

  bool _isPartOfUndoGroup(WorkspaceStackElement element) {
    if (element.groupId == 0) {
      return false;
    }
    // check that there is at least another element with the same groupId
    // ready to be undone
    for (final ResourceEditStack editStack in _editStacks.values) {
      final StackElement? pastElement = editStack.getClosestPastElement();
      if (pastElement == null) {
        continue;
      }
      if (identical(pastElement, element)) {
        final StackElement? secondPastElement =
            editStack.getSecondClosestPastElement();
        if (secondPastElement != null &&
            (secondPastElement is WorkspaceStackElement
                ? secondPastElement.groupId
                : (secondPastElement as ResourceStackElement).groupId) ==
                element.groupId) {
          return true;
        }
      }
      final int pastGroupId = pastElement is WorkspaceStackElement
          ? pastElement.groupId
          : (pastElement as ResourceStackElement).groupId;
      if (pastGroupId == element.groupId) {
        return true;
      }
    }
    return false;
  }

  Future<void> _confirmAndExecuteWorkspaceUndo(
      String strResource,
      WorkspaceStackElement element,
      EditStackSnapshot editStackSnapshot,
      bool undoConfirmed) async {
    if (element.canSplit() && !_isPartOfUndoGroup(element)) {
      final Map<String, Object?> result =
          (await _dialogService.prompt(<String, Object?>{
        'type': severity.Severity.Info,
        'message': localize('confirmWorkspace',
            "Would you like to undo '{0}' across all files?", <Object?>[element.label]),
        'buttons': <Object?>[
          <String, Object?>{
            'label': localize(
              <String, Object?>{
                'key': 'ok',
                'comment': <String>[
                  '{0} denotes a number that is > 1, && denotes a mnemonic'
                ]
              },
              '&&Undo in {0} Files',
              <Object?>[editStackSnapshot.editStacks.length],
            ),
            'run': () => _UndoChoice.All,
          },
          <String, Object?>{
            'label': localize(
              <String, Object?>{
                'key': 'nok',
                'comment': <String>['&& denotes a mnemonic']
              },
              'Undo this &&File',
            ),
            'run': () => _UndoChoice.This,
          },
        ],
        'cancelButton': <String, Object?>{'run': () => _UndoChoice.Cancel},
      })) as Map<String, Object?>;

      final int choice = result['result'] as int;
      if (choice == _UndoChoice.Cancel) {
        return;
      }

      if (choice == _UndoChoice.This) {
        _splitPastWorkspaceElement(element, null);
        await _undo(strResource, 0, true);
        return;
      }

      // choice: undo in all files
      final WorkspaceVerificationError? verificationError1 =
          _checkWorkspaceUndo(strResource, element, editStackSnapshot, false);
      if (verificationError1 != null) {
        await verificationError1.returnValue;
        return;
      }

      undoConfirmed = true;
    }

    // prepare
    late final lifecycle.IDisposable cleanup;
    try {
      cleanup = await _invokeWorkspacePrepare(element);
    } catch (err) {
      await _onError(err, element);
      return;
    }

    // At this point, it is possible that the element has been made invalid
    // in the meantime (due to the prepare await)
    final WorkspaceVerificationError? verificationError2 =
        _checkWorkspaceUndo(strResource, element, editStackSnapshot, true);
    if (verificationError2 != null) {
      lifecycle.dispose(cleanup);
      await verificationError2.returnValue;
      return;
    }

    for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
      editStack.moveBackward(element);
    }
    await _safeInvokeWithLocks(
      element,
      () => _invokeUndo(element.actual),
      editStackSnapshot,
      cleanup,
      () => _continueUndoInGroup(element.groupId, undoConfirmed),
    );
  }

  Future<void>? _resourceUndo(ResourceEditStack editStack,
      ResourceStackElement element, bool undoConfirmed) {
    if (!element.isValid) {
      // invalid element => immediately flush edit stack!
      editStack.flushAllElements();
      return null;
    }
    if (editStack.locked) {
      final String message = localize(
        <String, Object?>{
          'key': 'cannotResourceUndoDueToInProgressUndoRedo',
          'comment': <String>['{0} is a label for an operation.']
        },
        "Could not undo '{0}' because there is already an undo or redo operation running.",
        <Object?>[element.label],
      );
      _notificationService.warn(message);
      return null;
    }
    return _invokeResourcePrepare(element, (cleanup) {
      editStack.moveBackward(element);
      return _safeInvokeWithLocks(
        element,
        () => _invokeUndo(element.actual),
        EditStackSnapshot(<ResourceEditStack>[editStack]),
        cleanup,
        () => _continueUndoInGroup(element.groupId, undoConfirmed),
      );
    });
  }

  List<Object?> _findClosestUndoElementInGroup(int groupId) {
    if (groupId == 0) {
      return <Object?>[null, null];
    }

    // find another element with the same groupId and with the highest
    // groupOrder ready to be undone
    StackElement? matchedElement;
    String? matchedStrResource;

    for (final MapEntry<String, ResourceEditStack> entry
        in _editStacks.entries) {
      final StackElement? candidate = entry.value.getClosestPastElement();
      if (candidate == null) {
        continue;
      }
      final int candidateGroupId = candidate is WorkspaceStackElement
          ? candidate.groupId
          : (candidate as ResourceStackElement).groupId;
      final int candidateGroupOrder = candidate is WorkspaceStackElement
          ? candidate.groupOrder
          : (candidate as ResourceStackElement).groupOrder;
      if (candidateGroupId == groupId) {
        final int? currentOrder = matchedElement == null
            ? null
            : matchedElement is WorkspaceStackElement
                ? matchedElement.groupOrder
                : (matchedElement as ResourceStackElement).groupOrder;
        if (currentOrder == null || candidateGroupOrder > currentOrder) {
          matchedElement = candidate;
          matchedStrResource = entry.key;
        }
      }
    }

    return <Object?>[matchedElement, matchedStrResource];
  }

  Future<void>? _continueUndoInGroup(int groupId, bool undoConfirmed) {
    if (groupId == 0) {
      return null;
    }

    final List<Object?> found = _findClosestUndoElementInGroup(groupId);
    final String? matchedStrResource = found[1] as String?;
    if (matchedStrResource != null) {
      return _undo(matchedStrResource, 0, undoConfirmed);
    }
    return null;
  }

  @override
  Future<void>? undo(Object resource) {
    if (resource is undoRedo.UndoRedoSource) {
      final List<Object?> found =
          _findClosestUndoElementWithSource(resource.id);
      final String? matchedStrResource = found[1] as String?;
      return matchedStrResource != null
          ? _undo(matchedStrResource, resource.id, false)
          : null;
    }
    if (resource is String) {
      return _undo(resource, 0, false);
    }
    return _undo(getUriComparisonKey(resource as uri.URI), 0, false);
  }

  Future<void>? _undo(String strResource,
      [int sourceId = 0, bool undoConfirmed = false]) {
    if (!_editStacks.containsKey(strResource)) {
      return null;
    }

    final ResourceEditStack editStack = _editStacks[strResource]!;
    final StackElement? element = editStack.getClosestPastElement();
    if (element == null) {
      return null;
    }

    final int elementGroupId = element is WorkspaceStackElement
        ? element.groupId
        : (element as ResourceStackElement).groupId;
    if (elementGroupId != 0) {
      // this element is a part of a group, we need to make sure undoing in a
      // group is in order
      final List<Object?> found = _findClosestUndoElementInGroup(elementGroupId);
      final StackElement? matchedElement = found[0];
      final String? matchedStrResource = found[1] as String?;
      if (!identical(element, matchedElement) && matchedStrResource != null) {
        return _undo(matchedStrResource, sourceId, undoConfirmed);
      }
    }

    final int elementSourceId = element is WorkspaceStackElement
        ? element.sourceId
        : (element as ResourceStackElement).sourceId;
    final bool confirmBeforeUndo = element is WorkspaceStackElement
        ? element.confirmBeforeUndo
        : (element as ResourceStackElement).confirmBeforeUndo;
    final bool shouldPromptForConfirmation =
        elementSourceId != sourceId || confirmBeforeUndo;
    if (shouldPromptForConfirmation && !undoConfirmed) {
      return _confirmAndContinueUndo(strResource, sourceId, element);
    }

    try {
      if (element is WorkspaceStackElement) {
        return _workspaceUndo(strResource, element, undoConfirmed);
      } else {
        return _resourceUndo(
            editStack, element as ResourceStackElement, undoConfirmed);
      }
    } finally {
      if (_debug) _print('undo');
    }
  }

  Future<void> _confirmAndContinueUndo(
      String strResource, int sourceId, StackElement element) async {
    final Map<String, Object?> result =
        (await _dialogService.confirm(<String, Object?>{
      'message': localize('confirmDifferentSource',
          "Would you like to undo '{0}'?", <Object?>[_elementLabel(_stackActual(element))]),
      'primaryButton': localize(
        <String, Object?>{
          'key': 'confirmDifferentSource.yes',
          'comment': <String>['&& denotes a mnemonic']
        },
        '&&Yes',
      ),
      'cancelButton': localize(
        <String, Object?>{
          'key': 'confirmDifferentSource.no',
          'comment': <String>['&& denotes a mnemonic']
        },
        'No',
      ),
    })) as Map<String, Object?>;

    if (result['confirmed'] != true) {
      return;
    }

    await _undo(strResource, sourceId, true);
  }

  List<Object?> _findClosestRedoElementWithSource(int sourceId) {
    if (sourceId == 0) {
      return <Object?>[null, null];
    }

    // find an element with sourceId and with the lowest sourceOrder ready
    // to be redone
    StackElement? matchedElement;
    String? matchedStrResource;

    for (final MapEntry<String, ResourceEditStack> entry
        in _editStacks.entries) {
      final StackElement? candidate = entry.value.getClosestFutureElement();
      if (candidate == null) {
        continue;
      }
      final int candidateSourceId = candidate is WorkspaceStackElement
          ? candidate.sourceId
          : (candidate as ResourceStackElement).sourceId;
      final int candidateSourceOrder = candidate is WorkspaceStackElement
          ? candidate.sourceOrder
          : (candidate as ResourceStackElement).sourceOrder;
      if (candidateSourceId == sourceId) {
        final int? currentOrder = matchedElement == null
            ? null
            : matchedElement is WorkspaceStackElement
                ? matchedElement.sourceOrder
                : (matchedElement as ResourceStackElement).sourceOrder;
        if (currentOrder == null || candidateSourceOrder < currentOrder) {
          matchedElement = candidate;
          matchedStrResource = entry.key;
        }
      }
    }

    return <Object?>[matchedElement, matchedStrResource];
  }

  @override
  bool canRedo(Object resource) {
    if (resource is undoRedo.UndoRedoSource) {
      final List<Object?> found =
          _findClosestRedoElementWithSource(resource.id);
      return found[1] != null;
    }
    final String strResource = getUriComparisonKey(resource as uri.URI);
    if (_editStacks.containsKey(strResource)) {
      return _editStacks[strResource]!.hasFutureElements();
    }
    return false;
  }

  WorkspaceVerificationError _tryToSplitAndRedo(
      String strResource,
      WorkspaceStackElement element,
      RemovedResources? ignoreResources,
      String message) {
    if (element.canSplit()) {
      _splitFutureWorkspaceElement(element, ignoreResources);
      _notificationService.warn(message);
      return WorkspaceVerificationError(_redo(strResource));
    } else {
      // Cannot safely split this workspace element => flush all undo/redo stacks
      for (final String strResource in element.strResources) {
        removeElements(strResource);
      }
      _notificationService.warn(message);
      return WorkspaceVerificationError(null);
    }
  }

  WorkspaceVerificationError? _checkWorkspaceRedo(
      String strResource,
      WorkspaceStackElement element,
      EditStackSnapshot editStackSnapshot,
      bool checkInvalidatedResources) {
    final RemovedResources? removed = element.removedResources;
    if (removed != null) {
      return _tryToSplitAndRedo(
        strResource,
        element,
        removed,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceRedo',
            'comment': <String>[
              '{0} is a label for an operation. {1} is another message.'
            ]
          },
          "Could not redo '{0}' across all files. {1}",
          <Object?>[element.label, removed.createMessage()],
        ),
      );
    }
    final RemovedResources? invalidated = element.invalidatedResources;
    if (checkInvalidatedResources && invalidated != null) {
      return _tryToSplitAndRedo(
        strResource,
        element,
        invalidated,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceRedo',
            'comment': <String>[
              '{0} is a label for an operation. {1} is another message.'
            ]
          },
          "Could not redo '{0}' across all files. {1}",
          <Object?>[element.label, invalidated.createMessage()],
        ),
      );
    }

    // this must be the last future element in all the impacted resources!
    final List<String> cannotRedoDueToResources = <String>[];
    for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
      if (!identical(editStack.getClosestFutureElement(), element)) {
        cannotRedoDueToResources.push(editStack.resourceLabel);
      }
    }
    if (cannotRedoDueToResources.isNotEmpty) {
      return _tryToSplitAndRedo(
        strResource,
        element,
        null,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceRedoDueToChanges',
            'comment': <String>[
              '{0} is a label for an operation. {1} is a list of filenames.'
            ]
          },
          "Could not redo '{0}' across all files because changes were made to {1}",
          <Object?>[element.label, cannotRedoDueToResources.join(', ')],
        ),
      );
    }

    final List<String> cannotLockDueToResources = <String>[];
    for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
      if (editStack.locked) {
        cannotLockDueToResources.push(editStack.resourceLabel);
      }
    }
    if (cannotLockDueToResources.isNotEmpty) {
      return _tryToSplitAndRedo(
        strResource,
        element,
        null,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceRedoDueToInProgressUndoRedo',
            'comment': <String>[
              '{0} is a label for an operation. {1} is a list of filenames.'
            ]
          },
          "Could not redo '{0}' across all files because there is already an undo or redo operation running on {1}",
          <Object?>[element.label, cannotLockDueToResources.join(', ')],
        ),
      );
    }

    // check if new stack elements were added in the meantime...
    if (!editStackSnapshot.isValid()) {
      return _tryToSplitAndRedo(
        strResource,
        element,
        null,
        localize(
          <String, Object?>{
            'key': 'cannotWorkspaceRedoDueToInMeantimeUndoRedo',
            'comment': <String>[
              '{0} is a label for an operation. {1} is a list of filenames.'
            ]
          },
          "Could not redo '{0}' across all files because an undo or redo operation occurred in the meantime",
          <Object?>[element.label],
        ),
      );
    }

    return null;
  }

  Future<void>? _workspaceRedo(
      String strResource, WorkspaceStackElement element) {
    final EditStackSnapshot affectedEditStacks =
        _getAffectedEditStacks(element);
    final WorkspaceVerificationError? verificationError = _checkWorkspaceRedo(
        strResource, element, affectedEditStacks, false);
    if (verificationError != null) {
      return verificationError.returnValue;
    }
    return _executeWorkspaceRedo(strResource, element, affectedEditStacks);
  }

  Future<void> _executeWorkspaceRedo(String strResource,
      WorkspaceStackElement element, EditStackSnapshot editStackSnapshot) async {
    // prepare
    late final lifecycle.IDisposable cleanup;
    try {
      cleanup = await _invokeWorkspacePrepare(element);
    } catch (err) {
      await _onError(err, element);
      return;
    }

    // At this point, it is possible that the element has been made invalid
    // in the meantime (due to the prepare await)
    final WorkspaceVerificationError? verificationError =
        _checkWorkspaceRedo(strResource, element, editStackSnapshot, true);
    if (verificationError != null) {
      lifecycle.dispose(cleanup);
      await verificationError.returnValue;
      return;
    }

    for (final ResourceEditStack editStack in editStackSnapshot.editStacks) {
      editStack.moveForward(element);
    }
    await _safeInvokeWithLocks(
      element,
      () => _invokeRedo(element.actual),
      editStackSnapshot,
      cleanup,
      () => _continueRedoInGroup(element.groupId),
    );
  }

  Future<void>? _resourceRedo(
      ResourceEditStack editStack, ResourceStackElement element) {
    if (!element.isValid) {
      // invalid element => immediately flush edit stack!
      editStack.flushAllElements();
      return null;
    }
    if (editStack.locked) {
      final String message = localize(
        <String, Object?>{
          'key': 'cannotResourceRedoDueToInProgressUndoRedo',
          'comment': <String>['{0} is a label for an operation.']
        },
        "Could not redo '{0}' because there is already an undo or redo operation running.",
        <Object?>[element.label],
      );
      _notificationService.warn(message);
      return null;
    }

    return _invokeResourcePrepare(element, (cleanup) {
      editStack.moveForward(element);
      return _safeInvokeWithLocks(
        element,
        () => _invokeRedo(element.actual),
        EditStackSnapshot(<ResourceEditStack>[editStack]),
        cleanup,
        () => _continueRedoInGroup(element.groupId),
      );
    });
  }

  List<Object?> _findClosestRedoElementInGroup(int groupId) {
    if (groupId == 0) {
      return <Object?>[null, null];
    }

    // find another element with the same groupId and with the lowest
    // groupOrder ready to be redone
    StackElement? matchedElement;
    String? matchedStrResource;

    for (final MapEntry<String, ResourceEditStack> entry
        in _editStacks.entries) {
      final StackElement? candidate = entry.value.getClosestFutureElement();
      if (candidate == null) {
        continue;
      }
      final int candidateGroupId = candidate is WorkspaceStackElement
          ? candidate.groupId
          : (candidate as ResourceStackElement).groupId;
      final int candidateGroupOrder = candidate is WorkspaceStackElement
          ? candidate.groupOrder
          : (candidate as ResourceStackElement).groupOrder;
      if (candidateGroupId == groupId) {
        final int? currentOrder = matchedElement == null
            ? null
            : matchedElement is WorkspaceStackElement
                ? matchedElement.groupOrder
                : (matchedElement as ResourceStackElement).groupOrder;
        if (currentOrder == null || candidateGroupOrder < currentOrder) {
          matchedElement = candidate;
          matchedStrResource = entry.key;
        }
      }
    }

    return <Object?>[matchedElement, matchedStrResource];
  }

  Future<void>? _continueRedoInGroup(int groupId) {
    if (groupId == 0) {
      return null;
    }

    final List<Object?> found = _findClosestRedoElementInGroup(groupId);
    final String? matchedStrResource = found[1] as String?;
    if (matchedStrResource != null) {
      return _redo(matchedStrResource);
    }
    return null;
  }

  @override
  Future<void>? redo(Object resource) {
    if (resource is undoRedo.UndoRedoSource) {
      final List<Object?> found =
          _findClosestRedoElementWithSource(resource.id);
      final String? matchedStrResource = found[1] as String?;
      return matchedStrResource != null ? _redo(matchedStrResource) : null;
    }
    if (resource is String) {
      return _redo(resource);
    }
    return _redo(getUriComparisonKey(resource as uri.URI));
  }

  Future<void>? _redo(String strResource) {
    if (!_editStacks.containsKey(strResource)) {
      return null;
    }

    final ResourceEditStack editStack = _editStacks[strResource]!;
    final StackElement? element = editStack.getClosestFutureElement();
    if (element == null) {
      return null;
    }

    final int elementGroupId = element is WorkspaceStackElement
        ? element.groupId
        : (element as ResourceStackElement).groupId;
    if (elementGroupId != 0) {
      // this element is a part of a group, we need to make sure redoing in a
      // group is in order
      final List<Object?> found = _findClosestRedoElementInGroup(elementGroupId);
      final StackElement? matchedElement = found[0];
      final String? matchedStrResource = found[1] as String?;
      if (!identical(element, matchedElement) && matchedStrResource != null) {
        return _redo(matchedStrResource);
      }
    }

    try {
      if (element is WorkspaceStackElement) {
        return _workspaceRedo(strResource, element);
      } else {
        return _resourceRedo(
            editStack, element as ResourceStackElement);
      }
    } finally {
      if (_debug) _print('redo');
    }
  }
}

/// 1:1: `registerSingleton(IUndoRedoService, UndoRedoService, InstantiationType.Delayed)`
void registerUndoRedoService() {
  extensions.registerSingleton<undoRedo.IUndoRedoServiceType>(
    undoRedo.IUndoRedoService,
    UndoRedoService,
    InstantiationType.Delayed,
  );
}
