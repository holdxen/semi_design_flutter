// 1:1 port of vs/platform/layout/browser/layoutService.ts
//
// Purely declarative module: the runtime surface is the `ILayoutService`
// decorator id plus interface shapes. No implementation logic in source.

import '../../../base/browser/dom.dart' show IDimension;
import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show DisposableStore;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const ILayoutService = createDecorator<ILayoutService>('layoutService')`
final ServiceIdentifier<ILayoutServiceType> ILayoutService =
    createDecorator<ILayoutServiceType>('layoutService');

/// 1:1: `export interface ILayoutOffsetInfo`
class ILayoutOffsetInfo {
  final num top;
  final num quickPickTop;
  const ILayoutOffsetInfo({required this.top, required this.quickPickTop});
}

/// 1:1: `export interface ILayoutService` (phantom/type carrier)
abstract class ILayoutServiceType {
  Object? get _serviceBrand;
  Event<IDimension> get onDidLayoutMainContainer;
  Event<LayoutContainerEvent> get onDidLayoutContainer;
  Event<IDimension> get onDidLayoutActiveContainer;
  Event<AddContainerEvent> get onDidAddContainer;
  Event<void> get onDidChangeActiveContainer;
  IDimension get mainContainerDimension;
  IDimension get activeContainerDimension;
  Object get mainContainer;
  Object get activeContainer;
  Iterable<Object> get containers;
  Object getContainer(Object window);
  Future<void>? whenContainerStylesLoaded(Object window);
  ILayoutOffsetInfo get mainContainerOffset;
  ILayoutOffsetInfo get activeContainerOffset;
  void focus();
}

/// Event payload: `{ readonly container: HTMLElement; readonly dimension: IDimension }`.
class LayoutContainerEvent {
  final Object container;
  final IDimension dimension;
  const LayoutContainerEvent(this.container, this.dimension);
}

/// Event payload: `{ readonly container: HTMLElement; readonly disposables: DisposableStore }`.
class AddContainerEvent {
  final Object container;
  final DisposableStore disposables;
  const AddContainerEvent(this.container, this.disposables);
}
