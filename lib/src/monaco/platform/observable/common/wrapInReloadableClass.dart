// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/observable/common/wrapInReloadableClass.ts
// Translated 1:1 from TypeScript.
//   - `@IInstantiationService` DI parameter decorators have no Dart equivalent;
//     the constructor takes the service explicitly (see IInstantiationService).
//   - `new (...args: TArgs) => IDisposable` -> a Dart function type returning
//     Object (the wrapper is created via `createInstance` in production).
//   - `createWrapper` returns a Dart subclass built from a shared base.
// ---------------------------------------------------------------------------

import '../../../base/common/hotReload.dart' show isHotReloadEnabled;
import '../../../base/common/hotReloadHelpers.dart'
    show readHotReloadableExport;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/observable.dart' show autorunWithStore;
import '../../instantiation/common/instantiation.dart'
    show IInstantiationServiceType;

/// 1:1: `type Result<TArgs extends any[]> = new (...args: TArgs) => IDisposable`
typedef Result = Object Function(List<Object?> args);

/// 1:1: `class BaseClass`
class BaseClass {
  final IInstantiationServiceType instantiationService;
  BaseClass(this.instantiationService);
  void init(List<Object?> params) {}
}

/// 1:1: shared `createWrapper` class body.
class ReloadableWrapper extends BaseClass implements IDisposable {
  final Object Function() getClass;
  IDisposable? _autorun;

  ReloadableWrapper(IInstantiationServiceType instantiationService, this.getClass)
      : super(instantiationService);

  @override
  void init(List<Object?> params) {
    _autorun = autorunWithStore((reader, store) {
      final clazz = readHotReloadableExport(getClass(), reader);
      store.add(
          instantiationService.createInstance(clazz as Function, params) as IDisposable);
    });
  }

  @override
  void dispose() {
    _autorun?.dispose();
  }
}

/// 1:1: `class BaseClass0 extends BaseClass`
class BaseClass0 extends BaseClass {
  BaseClass0(IInstantiationServiceType i) : super(i) {
    init(const <Object?>[]);
  }
}

/// 1:1: `class BaseClass1 extends BaseClass`
class BaseClass1 extends BaseClass {
  BaseClass1(Object param1, IInstantiationServiceType i) : super(i) {
    init(<Object?>[param1]);
  }
}

/// 1:1: `function createWrapper(getClass, B)` — dispatches on the base class
/// constructor to reproduce the two TS wrapper variants.
Object createWrapper(Object Function() getClass, int kind) {
  switch (kind) {
    case 0:
      return (IInstantiationServiceType i) =>
          ReloadableWrapper(i, getClass)..init(const <Object?>[]);
    case 1:
      return (IInstantiationServiceType i, Object param1) =>
          ReloadableWrapper(i, getClass)..init(<Object?>[param1]);
    default:
      throw StateError('unknown wrapper kind');
  }
}

/// 1:1: `export function wrapInReloadableClass0(getClass): Result<TArgs>`
/// In the disabled hot-reload path (the default), returns `getClass()` itself.
Object wrapInReloadableClass0(Object Function() getClass) {
  return !isHotReloadEnabled()
      ? getClass()
      : createWrapper(getClass, 0);
}

/// 1:1: `export function wrapInReloadableClass1(getClass): Result<GetLeadingNonServiceArgs<TArgs>>`
Object wrapInReloadableClass1(Object Function() getClass) {
  return !isHotReloadEnabled()
      ? getClass()
      : createWrapper(getClass, 1);
}
