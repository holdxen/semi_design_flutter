// 1:1 port of vs/platform/undoRedo/common/undoRedo.ts
// A service declaration + small runtime classes (UndoRedoGroup / UndoRedoSource).
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IUndoRedoService = createDecorator<IUndoRedoService>('undoRedoService')`
final ServiceIdentifier<IUndoRedoServiceType> IUndoRedoService =
    createDecorator<IUndoRedoServiceType>('undoRedoService');

/// 1:1: `export const enum UndoRedoElementType { Resource, Workspace }`
/// Numeric const enum -> class with static const int (Resource = 0, Workspace = 1).
class UndoRedoElementType {
  const UndoRedoElementType._();
  static const int Resource = 0;
  static const int Workspace = 1;
}

/// 1:1: `export interface IResourceUndoRedoElement`
abstract class IResourceUndoRedoElement {
  /// 1:1: `readonly type: UndoRedoElementType.Resource`
  int get type;

  /// 1:1: `readonly resource: URI`
  URI get resource;

  /// 1:1: `readonly label: string`
  String get label;

  /// 1:1: `readonly code: string`
  String get code;

  /// 1:1: `readonly confirmBeforeUndo?: boolean`
  bool? get confirmBeforeUndo;

  /// 1:1: `undo(): Promise<void> | void`
  Future<void>? undo();

  /// 1:1: `redo(): Promise<void> | void`
  Future<void>? redo();
}

/// 1:1: `export interface IWorkspaceUndoRedoElement`
abstract class IWorkspaceUndoRedoElement {
  /// 1:1: `readonly type: UndoRedoElementType.Workspace`
  int get type;

  /// 1:1: `readonly resources: readonly URI[]`
  List<URI> get resources;

  /// 1:1: `readonly label: string`
  String get label;

  /// 1:1: `readonly code: string`
  String get code;

  /// 1:1: `readonly confirmBeforeUndo?: boolean`
  bool? get confirmBeforeUndo;

  /// 1:1: `undo(): Promise<void> | void`
  Future<void>? undo();

  /// 1:1: `redo(): Promise<void> | void`
  Future<void>? redo();

  /// 1:1: `split?(): IResourceUndoRedoElement[]`
  List<IResourceUndoRedoElement>? split();

  /// 1:1: `prepareUndoRedo?(): Promise<IDisposable> | IDisposable | void`
  /// TS union -> Object? carrier.
  Object? prepareUndoRedo();
}

/// 1:1: `export type IUndoRedoElement = IResourceUndoRedoElement | IWorkspaceUndoRedoElement`
/// TS union -> Object? carrier (documented; kept as typedef for readability).
typedef IUndoRedoElement = Object;

/// 1:1: `export interface IPastFutureElements`
abstract class IPastFutureElements {
  List<IUndoRedoElement> get past;
  List<IUndoRedoElement> get future;
}

/// 1:1: `export interface UriComparisonKeyComputer`
abstract class UriComparisonKeyComputer {
  String getComparisonKey(URI uri);
}

/// 1:1: `export class ResourceEditStackSnapshot`
class ResourceEditStackSnapshot {
  /// 1:1: `public readonly resource: URI`
  final URI resource;

  /// 1:1: `public readonly elements: number[]`
  final List<int> elements;

  ResourceEditStackSnapshot(this.resource, this.elements);
}

/// 1:1: `export class UndoRedoGroup`
class UndoRedoGroup {
  /// 1:1: `private static _ID = 0`
  static int _ID = 0;

  /// 1:1: `public readonly id: number`
  final int id;

  /// 1:1: `private order: number`
  int order;

  /// 1:1 constructor: `this.id = UndoRedoGroup._ID++; this.order = 1;`
  UndoRedoGroup()
      : id = _ID++,
        order = 1;

  /// 1:1: `public nextOrder(): number { if (this.id === 0) return 0; return this.order++; }`
  int nextOrder() {
    if (id == 0) {
      return 0;
    }
    return order++;
  }

  /// 1:1: `public static None = new UndoRedoGroup();`
  /// Created once at class initialization, so it takes id 0 and subsequent
  /// instances get id >= 1 (matches the TS module-load order).
  static final UndoRedoGroup None = UndoRedoGroup();
}

/// 1:1: `export class UndoRedoSource`
class UndoRedoSource {
  /// 1:1: `private static _ID = 0`
  static int _ID = 0;

  /// 1:1: `public readonly id: number`
  final int id;

  /// 1:1: `private order: number`
  int order;

  /// 1:1 constructor: `this.id = UndoRedoSource._ID++; this.order = 1;`
  UndoRedoSource()
      : id = _ID++,
        order = 1;

  /// 1:1: `public nextOrder(): number { if (this.id === 0) return 0; return this.order++; }`
  int nextOrder() {
    if (id == 0) {
      return 0;
    }
    return order++;
  }

  /// 1:1: `public static None = new UndoRedoSource();`
  static final UndoRedoSource None = UndoRedoSource();
}

/// 1:1: `export interface IUndoRedoService` (const keeps the bare name).
abstract class IUndoRedoServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `registerUriComparisonKeyComputer(scheme, computer): IDisposable`
  IDisposable registerUriComparisonKeyComputer(
      String scheme, UriComparisonKeyComputer uriComparisonKeyComputer);

  /// 1:1: `getUriComparisonKey(resource): string`
  String getUriComparisonKey(URI resource);

  /// 1:1: `pushElement(element, group?, source?): void`
  void pushElement(IUndoRedoElement element,
      [UndoRedoGroup? group, UndoRedoSource? source]);

  /// 1:1: `getLastElement(resource): IUndoRedoElement | null`
  IUndoRedoElement? getLastElement(URI resource);

  /// 1:1: `getElements(resource): IPastFutureElements`
  IPastFutureElements getElements(URI resource);

  /// 1:1: `setElementsValidFlag(resource, isValid, filter): void`
  void setElementsValidFlag(URI resource, bool isValid,
      bool Function(IUndoRedoElement) filter);

  /// 1:1: `removeElements(resource): void`
  void removeElements(URI resource);

  /// 1:1: `createSnapshot(resource): ResourceEditStackSnapshot`
  ResourceEditStackSnapshot createSnapshot(URI resource);

  /// 1:1: `restoreSnapshot(snapshot): void`
  void restoreSnapshot(ResourceEditStackSnapshot snapshot);

  /// 1:1: `canUndo(resource: URI | UndoRedoSource): boolean`
  /// TS union -> Object? carrier.
  bool canUndo(Object resource);

  /// 1:1: `undo(resource): Promise<void> | void`
  Future<void>? undo(Object resource);

  /// 1:1: `canRedo(resource: URI | UndoRedoSource): boolean`
  bool canRedo(Object resource);

  /// 1:1: `redo(resource): Promise<void> | void`
  Future<void>? redo(Object resource);
}
