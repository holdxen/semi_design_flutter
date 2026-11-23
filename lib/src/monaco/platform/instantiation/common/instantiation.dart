// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/instantiation/common/instantiation.ts
// Translated 1:1 from TypeScript. The TS callable `ServiceIdentifier<T>` is
// represented as a callable Dart class (identity-based ==/hashCode, so it can
// be a Map key exactly like the JS function object). `createDecorator` keeps
// the serviceId-string memoization and decorator dependency recording.
// Structural/phantom TS interfaces (IConstructorSignature, ServicesAccessor,
// IInstantiationService, DI_TARGET_OBJ) become abstract type declarations.
// ---------------------------------------------------------------------------

import 'descriptors.dart';
import 'serviceCollection.dart' show ServiceCollection;
import '../../../base/common/lifecycle.dart' show DisposableStore;

/// 1:1: `export namespace _util { ... }`
/// The TS name begins with `_` but is `export`ed; Dart uses [Util] as the
/// public class name so downstream ports can reach the exported namespace.
class Util {
  /// 1:1: `export const serviceIds = new Map<string, ServiceIdentifier<any>>()`
  static final Map<String, ServiceIdentifier> serviceIds = <String, ServiceIdentifier>{};

  /// 1:1: `export const DI_TARGET = '$di$target';`
  static const String DI_TARGET = '\$di\$target';

  /// 1:1: `export const DI_DEPENDENCIES = '$di$dependencies';`
  static const String DI_DEPENDENCIES = '\$di\$dependencies';

  /// 1:1: `getServiceDependencies(ctor): { id, index }[]`
  static List<ServiceDependency> getServiceDependencies(Object ctor) {
    // 1:1: the JS metadata keys; kept referenced for parity with `_util`.
    final diTarget = DI_TARGET; // ignore: unused_local_variable
    final diDeps = DI_DEPENDENCIES; // ignore: unused_local_variable
    final recorded = _ServiceDependencyRegistry.recorded[ctor];
    return recorded == null ? <ServiceDependency>[] : List<ServiceDependency>.from(recorded);
  }
}

/// 1:1 carrier: `{ id: ServiceIdentifier<any>; index: number }`
class ServiceDependency {
  final ServiceIdentifier id;
  final int index;
  const ServiceDependency(this.id, this.index);
}

/// 1:1: `export interface DI_TARGET_OBJ extends Function { [DI_TARGET]: Function; [DI_DEPENDENCIES]: {...}[] }`
abstract class DI_TARGET_OBJ {
  Object get target;
  List<ServiceDependency> get dependencies;
}

/// 1:1: `export type BrandedService = { _serviceBrand: undefined }`
abstract class BrandedService {
  // ignore: unused_element
  Object? get _serviceBrand;
}

/// 1:1: `export interface IConstructorSignature<T, Args extends any[] = []>`
abstract class IConstructorSignature<T, Args extends List<Object?>> {
  T construct(List<Object?> services);
}

/// 1:1: `export interface ServicesAccessor { get<T>(id: ServiceIdentifier<T>): T }`
abstract class ServicesAccessor {
  Object? get(ServiceIdentifier id);
}

/// 1:1: `export type GetLeadingNonServiceArgs<TArgs>` — conditional carrier.
/// TS peels trailing branded-service args; Dart has no variadic type pruning,
/// so the resolved arg list is an opaque `List<Object?>` carrier.
typedef GetLeadingNonServiceArgs<TArgs extends List<Object?>> = List<Object?>;

/// 1:1: `export interface ServiceIdentifier<T> { (...args:any[]): void; type: T }`
/// Callable + identity-keyed. The generic `T` is a phantom carried as `Object?`
/// because the identifier alone never materializes a service instance.
class ServiceIdentifier<T> {
  final String serviceId;

  ServiceIdentifier(this.serviceId);

  /// 1:1: `ServiceIdentifier.type: T` (phantom; materialized by consumers).
  T? get type => null;

  /// 1:1 decorator call: `id(target, key, index)` / `id(target, index)`.
  /// The TS body throws unless exactly 3 arguments are passed.
  void call(Object target, [Object? key, Object? index]) {
    // TS: `if (arguments.length !== 3) throw ...`
    if (key == null || index == null) {
      throw StateError('@IServiceName-decorator can only be used to decorate a parameter');
    }
    _storeServiceDependency(this, target, index is int ? index : int.parse(index.toString()));
  }

  @override
  String toString() => serviceId;

  // Identity semantics match the JS function object used as a Map key.
  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

/// Module-level record of decorator dependency metadata keyed by target object
/// identity. Mirrors the TS pattern of attaching `_util.DI_TARGET` /
/// `_util.DI_DEPENDENCIES` properties onto the target function object.
class _ServiceDependencyRegistry {
  static final Map<Object, List<ServiceDependency>> recorded = <Object, List<ServiceDependency>>{};
}

/// 1:1: `function storeServiceDependency(id, target, index)`
void _storeServiceDependency(ServiceIdentifier id, Object target, int index) {
  final deps = _ServiceDependencyRegistry.recorded[target];
  final targetMark = _TargetMarks.marked[target];
  if (targetMark == target) {
    deps!.add(ServiceDependency(id, index));
  } else {
    _ServiceDependencyRegistry.recorded[target] = <ServiceDependency>[ServiceDependency(id, index)];
    _TargetMarks.marked[target] = target;
  }
}

class _TargetMarks {
  static final Map<Object, Object> marked = <Object, Object>{};
}

/// 1:1: `export const IInstantiationService = createDecorator<IInstantiationService>('instantiationService')`
final ServiceIdentifier<IInstantiationServiceType> IInstantiationService =
    createDecorator<IInstantiationServiceType>('instantiationService');

/// 1:1: `export interface IInstantiationService`
/// (TS value/type namespace split: the const of the same name is kept as the
///  identifier value below; the interface type is suffixed `Type` for Dart.)
abstract class IInstantiationServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// `createInstance<T>(descriptor: SyncDescriptor0<T>): T`
  Object? createInstanceFromDescriptor(SyncDescriptor0 descriptor);

  /// `createInstance<Ctor,...>(ctor, ...args): R`
  Object? createInstance(Object ctor, List<Object?> args);

  /// `invokeFunction<R,TS>(fn, ...args): R`
  Object? invokeFunction(Object fn, List<Object?> args);

  /// `createChild(services, store?): IInstantiationService`
  IInstantiationServiceType createChild(ServiceCollection services, [DisposableStore? store]);

  void dispose();
}

/// 1:1: `export function createDecorator<T>(serviceId: string): ServiceIdentifier<T>`
ServiceIdentifier<T> createDecorator<T>(String serviceId) {
  final existing = Util.serviceIds[serviceId];
  if (existing != null) return existing as ServiceIdentifier<T>;

  final id = ServiceIdentifier<T>(serviceId);
  Util.serviceIds[serviceId] = id;
  return id;
}

/// 1:1: `export function refineServiceDecorator<T1, T extends T1>(id): ServiceIdentifier<T>`
ServiceIdentifier<T> refineServiceDecorator<T1, T extends T1>(ServiceIdentifier<T1> serviceIdentifier) {
  return serviceIdentifier as ServiceIdentifier<T>;
}
