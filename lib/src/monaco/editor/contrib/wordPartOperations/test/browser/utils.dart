// 1:1 port of vs/editor/contrib/wordPartOperations/test/browser/utils.ts
import '../../../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, ServicesAccessor;

/// 1:1: `export class StaticServiceAccessor implements ServicesAccessor`
/// TS `Map<ServiceIdentifier<unknown>, unknown>` — key identity semantics match
/// Dart's default Map with `ServiceIdentifier` (identity == / identityHashCode).
class StaticServiceAccessor implements ServicesAccessor {
  final Map<ServiceIdentifier<dynamic>, dynamic> _services =
      <ServiceIdentifier<dynamic>, dynamic>{};

  /// 1:1: `public withService<T>(id, service): this`
  StaticServiceAccessor withService<T>(ServiceIdentifier<T> id, T service) {
    _services[id] = service;
    return this;
  }

  /// 1:1: `public get<T>(id): T` — JS `if (!value) throw new Error('Service does not exist')`.
  /// Falsy JS values (0, '', false, null) also throw; use JS truthiness.
  /// Dart interface `ServicesAccessor.get` is non-generic; a typed helper is
  /// provided via [getTyped] while the override keeps the base signature.
  @override
  Object? get(ServiceIdentifier id) {
    final value = _services[id];
    if (_jsFalsy(value)) {
      throw StateError('Service does not exist');
    }
    return value;
  }

  /// 1:1 generic form of `get<T>`.
  T getTyped<T>(ServiceIdentifier<T> id) => get(id) as T;
}

/// JS truthiness check (mirrors project convention in batch60/62).
bool _jsFalsy(Object? v) =>
    v == null || v == false || v == 0 || v == '';
