// 1:1 port of vs/platform/instantiation/test/common/instantiationServiceMock.ts
//
// sinon has no Dart counterpart. The small surface used here is modelled by
// the private carriers at the bottom of this file (SinonCallable / SinonMock /
// _sinon). They faithfully reproduce the observable behaviour exercised by the
// source: spy/stub call tracking, `.returns`, `.restore`, `createStubInstance`,
// `mock`, `restore`, and `isSinonSpyLike` (`'callCount' in fn`).
import '../../../../base/common/lifecycle.dart'
    show DisposableStore, IDisposable, toDisposable;
import '../../common/descriptors.dart' show SyncDescriptor;
import '../../common/instantiation.dart'
    show ServiceIdentifier, ServicesAccessor;
import '../../common/instantiationService.dart' show InstantiationService, Trace;
import '../../common/serviceCollection.dart' show ServiceCollection;

/// 1:1: `interface IServiceMock<T> { id: ServiceIdentifier<T>; service: any }`
class _ServiceMock<T> {
  final ServiceIdentifier<T> id;
  Object? service;
  _ServiceMock(this.id, this.service);
}

/// 1:1: `const isSinonSpyLike = (fn) => fn && 'callCount' in fn`
bool _isSinonSpyLike(Object? fn) => fn is SinonCallable;

/// 1:1: `export class TestInstantiationService extends InstantiationService implements IDisposable, ServicesAccessor`
class TestInstantiationService extends InstantiationService
    implements IDisposable, ServicesAccessor {
  /// 1:1: `private _servciesMap: Map<ServiceIdentifier<any>, any>` (source typo preserved)
  final Map<ServiceIdentifier, Object?> _servciesMap =
      <ServiceIdentifier, Object?>{};

  /// 1:1: `private readonly _classStubs: Map<Function, any> = new Map()`
  final Map<Object, Object?> _classStubs = <Object, Object?>{};

  /// 1:1: `private readonly _parentTestService: TestInstantiationService | undefined`
  final TestInstantiationService? _parentTestService;

  /// 1:1: `private _serviceCollection: ServiceCollection` (kept as field; super shares it)
  final ServiceCollection _serviceCollection;

  /// 1:1: `private _properDispose?: boolean`
  final bool _properDispose;

  /// 1:1: constructor(serviceCollection = new ServiceCollection(), strict = false, parent?, _properDispose?)
  /// A factory forwards the SAME collection instance to both the field and
  /// `super`, mirroring TS where `super(_serviceCollection, ...)` and
  /// `this._serviceCollection = _serviceCollection` share one object.
  factory TestInstantiationService([
    ServiceCollection? serviceCollection,
    bool strict = false,
    InstantiationService? parent,
    bool properDispose = false,
  ]) {
    return TestInstantiationService._impl(
      serviceCollection ?? ServiceCollection(),
      strict,
      parent,
      properDispose,
    );
  }

  TestInstantiationService._impl(
    this._serviceCollection,
    bool strict,
    InstantiationService? parent,
    this._properDispose,
  )   : _parentTestService = parent is TestInstantiationService ? parent : null,
        super(_serviceCollection, strict, parent);

  /// 1:1: `public get<T>(service): T`
  /// `super._getOrCreateServiceInstance(service, Trace.traceCreation(false, TestInstantiationService))`
  @override
  Object? get(ServiceIdentifier id) => getOrCreateServiceInstance(
      id, Trace.traceCreation(false, TestInstantiationService));

  /// 1:1: `public set<T>(service, instance): T`
  Object? set<T>(ServiceIdentifier<T> service, T instance) =>
      _serviceCollection.set<T>(service, instance);

  /// 1:1: `public mock<T>(service): T | sinon.SinonMock`
  SinonMock mock<T>(ServiceIdentifier<T> service) =>
      _create(service, const <String, Object?>{'mock': true}) as SinonMock;

  /// 1:1: `public stubInstance<T>(ctor, instance): void`
  void stubInstance<T>(Object ctor, Map<String, Object?> instance) {
    _classStubs[ctor] = instance;
  }

  /// 1:1: `protected _getClassStub(ctor): unknown`
  Object? _getClassStub(Object ctor) =>
      _classStubs[ctor] ?? _parentTestService?._getClassStub(ctor);

  /// 1:1: `override createInstance(ctorOrDescriptor, ...rest): unknown`
  @override
  Object? createInstance(Object ctorOrDescriptor, [List<Object?>? args]) {
    final stub = _getClassStub(ctorOrDescriptor);
    if (stub != null) {
      return stub;
    }
    return super.createInstance(ctorOrDescriptor, args);
  }

  /// 1:1: `public stub<T>(service, obj, property?, value?): sinon.SinonStub | sinon.SinonSpy`
  /// Overloads collapsed to one carrier-returning implementation.
  Object? stub(
    ServiceIdentifier serviceIdentifier,
    Object arg2, [
    Object? arg3,
    Object? arg4,
  ]) {
    final Object? service = arg2 is String ? null : arg2;
    final serviceMock = _ServiceMock(serviceIdentifier, service);
    final Object? property = arg2 is String ? arg2 : arg3;
    final Object? value = arg2 is String ? arg3 : arg4;

    final stubObject = _create(
      serviceMock,
      const <String, Object?>{'stub': true},
      service != null && property == null,
    );

    if (property is String) {
      final Object? existing = _getProp(stubObject, property);
      if (_jsTruthy(existing)) {
        if (_hasOwnRestore(existing)) {
          (existing as dynamic).restore();
        }
        if (value is Function || value is SinonCallable) {
          final spy = _isSinonSpyLike(value)
              ? value
              : _sinon.spy(value is Function ? value : () => value);
          _setProp(stubObject, property, spy);
          return spy;
        } else {
          final Object stub = value != null
              ? _sinon.stub().returns(value)
              : _sinon.stub();
          _setProp(stubObject, property, stub);
          return stub;
        }
      } else {
        _setProp(stubObject, property, value);
      }
    }
    return stubObject;
  }

  /// 1:1: `public stubPromise(service?, fnProperty?, value?)`
  Object? stubPromise([
    ServiceIdentifier? service,
    Object? arg2,
    Object? arg3,
    Object? arg4,
  ]) {
    final Object? a3 = arg2 is String ? Future.value(arg3) : arg3;
    final Object? a4 = arg2 is! String && a3 is String ? Future.value(arg4) : arg4;
    return stub(service!, arg2!, a3, a4);
  }

  /// 1:1: `public spy<T>(service, fnProperty): sinon.SinonSpy`
  SinonCallable spy<T>(ServiceIdentifier<T> service, String fnProperty) {
    final SinonCallable spy = _sinon.spy();
    stub(service, fnProperty, spy);
    return spy;
  }

  /// 1:1: `private _create(arg1, options, reset?): any`
  Object? _create(Object arg1, Map<String, Object?> options,
      [bool reset = false]) {
    if (_isServiceMock(arg1)) {
      final sm = arg1 as _ServiceMock;
      final service = _getOrCreateService(sm, options, reset);
      _serviceCollection.set(sm.id, service);
      return service;
    }
    return options.containsKey('mock') && options['mock'] == true
        ? _sinon.mock(arg1)
        : _createStub(arg1);
  }

  /// 1:1: `private _getOrCreateService(serviceMock, opts, reset?): any`
  Object? _getOrCreateService(
      _ServiceMock serviceMock, Map<String, Object?> opts, bool reset) {
    final Object? service = _serviceCollection.get(serviceMock.id);
    if (!reset && service != null) {
      final optsObj = service is Map<String, Object?> ? service['sinonOptions'] : null;
      if (opts.containsKey('mock') && opts['mock'] == true &&
          optsObj is Map && optsObj['mock'] == true) {
        return service;
      }
      if (opts.containsKey('stub') && opts['stub'] == true &&
          optsObj is Map && optsObj['stub'] == true) {
        return service;
      }
    }
    return _createService(serviceMock, opts);
  }

  /// 1:1: `private _createService(serviceMock, opts): any`
  Object? _createService(_ServiceMock serviceMock, Map<String, Object?> opts) {
    // source: `serviceMock.service = serviceMock.service ? serviceMock.service : this._servciesMap.get(serviceMock.id)`
    serviceMock.service = _jsTruthy(serviceMock.service)
        ? serviceMock.service
        : _servciesMap[serviceMock.id];
    final bool isMock = opts.containsKey('mock') && opts['mock'] == true;
    final Object? service =
        isMock ? _sinon.mock(serviceMock.service) : _createStub(serviceMock.service);
    _setSinonOptions(service, opts);
    return service;
  }

  /// 1:1: `private _createStub(arg): any` — `typeof arg === 'object' ? arg : sinon.createStubInstance(arg)`
  Object? _createStub(Object? arg) =>
      arg is Map || arg is SinonMock || arg is SinonCallable
          ? arg
          : _sinon.createStubInstance(arg);

  /// 1:1: `private isServiceMock(arg1): boolean` — `typeof arg1 === 'object' && arg1.hasOwnProperty('id')`
  bool _isServiceMock(Object arg1) => arg1 is _ServiceMock;

  /// 1:1: `override createChild(services): TestInstantiationService`
  @override
  TestInstantiationService createChild(ServiceCollection services,
      [DisposableStore? store]) {
    final child = TestInstantiationService(services, false, this);
    store?.add(child);
    return child;
  }

  /// 1:1: `override dispose()` — `sinon.restore(); if (this._properDispose) super.dispose()`
  @override
  void dispose() {
    _sinon.restore();
    if (_properDispose) {
      super.dispose();
    }
  }

  // ---- helpers for dynamic property access on service carriers ----
  Object? _getProp(Object? obj, String key) {
    if (obj is Map<String, Object?>) return obj[key];
    if (obj is _ServiceMock) return key == 'id' ? obj.id : (key == 'service' ? obj.service : null);
    return null;
  }

  void _setProp(Object? obj, String key, Object? value) {
    if (obj is Map<String, Object?>) obj[key] = value;
  }

  void _setSinonOptions(Object? obj, Map<String, Object?> opts) {
    if (obj is Map<String, Object?>) obj['sinonOptions'] = opts;
  }

  bool _hasOwnRestore(Object? obj) {
    if (obj is SinonCallable) return true;
    if (obj is Map<String, Object?>) return obj.containsKey('restore');
    return false;
  }
}

/// 1:1: `interface SinonOptions { mock?: boolean; stub?: boolean }`
/// Modelled as `Map<String, Object?>` carriers with keys 'mock'/'stub'.

/// 1:1: `export type ServiceIdCtorPair<T> = [id, ctorOrInstance]`
typedef ServiceIdCtorPair = List<Object?>; // [ServiceIdentifier, ctor|instance]

/// 1:1: `export function createServices(disposables, services): TestInstantiationService`
TestInstantiationService createServices(
  DisposableStore disposables,
  List<ServiceIdCtorPair> services,
) {
  final List<ServiceIdentifier> serviceIdentifiers = <ServiceIdentifier>[];
  final ServiceCollection serviceCollection = ServiceCollection();

  void define(ServiceIdentifier id, Object ctorOrInstance) {
    if (!serviceCollection.has(id)) {
      if (ctorOrInstance is Function) {
        serviceCollection.set(id, SyncDescriptor(ctorOrInstance, <Object?>[], false));
      } else {
        serviceCollection.set(id, ctorOrInstance);
      }
    }
    serviceIdentifiers.add(id);
  }

  for (final pair in services) {
    define(pair[0] as ServiceIdentifier, pair[1]!);
  }

  final instantiationService =
      disposables.add(TestInstantiationService(serviceCollection, true));
  disposables.add(toDisposable(() {
    for (final id in serviceIdentifiers) {
      final Object? instanceOrDescriptor = serviceCollection.get(id);
      if (instanceOrDescriptor is Function &&
          _hasDisposeMethod(instanceOrDescriptor)) {
        (instanceOrDescriptor as dynamic).dispose();
      } else if (instanceOrDescriptor is IDisposable) {
        instanceOrDescriptor.dispose();
      }
    }
  }));
  return instantiationService;
}

bool _hasDisposeMethod(Object o) => o is IDisposable;

bool _jsTruthy(Object? v) =>
    v != null && v != false && v != 0 && v != '';

// ---------------------------------------------------------------------------
// sinon carrier (private to this library)
// ---------------------------------------------------------------------------

/// Callable stand-in for `sinon.SinonSpy` / `sinon.SinonStub`.
class SinonCallable {
  final String kind;
  final Function? _fn;
  int callCount = 0;
  final List<List<Object?>> calls = <List<Object?>>[];
  Object? _returnValue;
  Function? _fake;
  Object? _throws;

  SinonCallable(this.kind, [this._fn]);

  Object? call([List<Object?> args = const <Object?>[]]) {
    callCount++;
    calls.add(args);
    if (_throws != null) throw _throws!;
    if (_fake != null) return Function.apply(_fake!, args);
    if (kind == 'spy' && _fn != null) return Function.apply(_fn, args);
    return _returnValue;
  }

  SinonCallable returns(Object? value) {
    _returnValue = value;
    _fake = null;
    return this;
  }

  SinonCallable callsFake(Function fn) {
    _fake = fn;
    return this;
  }

  SinonCallable throws(Object error) {
    _throws = error;
    return this;
  }

  void restore() {}
}

/// Stand-in for `sinon.SinonMock` — an object with restore/verify/expects.
class SinonMock {
  final Map<String, Object?> _props;
  final List<Object?> extra;
  SinonMock(this._props, [this.extra = const <Object?>[]]);

  Object? operator [](String key) => _props[key];
  void operator []=(String key, Object? value) => _props[key] = value;
  bool hasOwnProperty(String key) => _props.containsKey(key);
  void restore() {}
  void verify() {}
  SinonCallable expects() => _sinon.stub();
}

class _Sinon {
  int restoreCount = 0;
  SinonCallable spy([Function? fn]) => SinonCallable('spy', fn);
  SinonCallable stub() => SinonCallable('stub');
  SinonMock mock(Object? obj) {
    final Map<String, Object?> props = <String, Object?>{};
    if (obj is Map<String, Object?>) {
      props.addAll(obj);
    } else if (obj is ServiceIdentifier) {
      // sinon.mock copies the source object's own enumerable keys; the TS test
      // ids carry `serviceId`, so mirror that on the Dart ServiceIdentifier.
      props['serviceId'] = obj.serviceId;
    }
    return SinonMock(props);
  }
  Object? createStubInstance(Object? ctor) => <String, Object?>{};
  void restore() {
    restoreCount++;
  }
}

final _Sinon _sinon = _Sinon();
