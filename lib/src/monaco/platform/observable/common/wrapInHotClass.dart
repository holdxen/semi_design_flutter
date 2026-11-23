// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/observable/common/wrapInHotClass.ts
// Translated 1:1 from TypeScript.
//   - `@IInstantiationService` DI parameter decorators have no Dart equivalent;
//     the constructor takes the service explicitly.
//   - `IObservable<Result>` read via `.get()` / `.read(reader)` maps to the
//     Dart IObservable API. The wrapper is created via `createInstance`.
// ---------------------------------------------------------------------------

import '../../../base/common/hotReload.dart' show isHotReloadEnabled;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/observable.dart'
    show IObservable, autorunWithStore;
import '../../instantiation/common/instantiation.dart'
    show IInstantiationServiceType;

/// 1:1: `type Result<TArgs extends any[]> = new (...args: TArgs) => IDisposable`
typedef Result = Object Function(List<Object?> args);

/// 1:1: `export function hotClassGetOriginalInstance<T>(value: T): T`
/// If `value` is a wrapper, return the underlying instance, else value itself.
Object? hotClassGetOriginalInstance(Object? value) {
  if (value is WrapperBase) {
    return value._instance;
  }
  return value;
}

/// 1:1: `class BaseClass`
class WrapperBase {
  Object? _instance;
  final IInstantiationServiceType instantiationService;
  WrapperBase(this.instantiationService);
  void init(List<Object?> params) {}
}

/// 1:1: shared `createWrapper` class body.
class HotClassWrapper extends WrapperBase implements IDisposable {
  final IObservable<Object> clazz;
  IDisposable? _autorun;

  HotClassWrapper(IInstantiationServiceType instantiationService, this.clazz)
      : super(instantiationService);

  @override
  void init(List<Object?> params) {
    _autorun = autorunWithStore((reader, store) {
      final clazz_ = clazz.read(reader);
      _instance = store.add(
          instantiationService.createInstance(clazz_ as Function, params) as IDisposable);
    });
  }

  @override
  void dispose() {
    _autorun?.dispose();
  }
}

/// 1:1: `function createWrapper(clazz, B)` — dispatches on constructor kind.
Object createWrapper(IObservable<Object> clazz, int kind) {
  switch (kind) {
    case 0:
      return (IInstantiationServiceType i) =>
          HotClassWrapper(i, clazz)..init(const <Object?>[]);
    case 1:
      return (IInstantiationServiceType i, Object param1) =>
          HotClassWrapper(i, clazz)..init(<Object?>[param1]);
    default:
      throw StateError('unknown wrapper kind');
  }
}

/// 1:1: `export function wrapInHotClass0(clazz): Result<TArgs>`
/// In the disabled hot-reload path (the default), returns `clazz.get()`.
Object wrapInHotClass0(IObservable<Object> clazz) {
  return !isHotReloadEnabled() ? clazz.get() : createWrapper(clazz, 0);
}

/// 1:1: `export function wrapInHotClass1(clazz): Result<GetLeadingNonServiceArgs<TArgs>>`
Object wrapInHotClass1(IObservable<Object> clazz) {
  return !isHotReloadEnabled() ? clazz.get() : createWrapper(clazz, 1);
}
