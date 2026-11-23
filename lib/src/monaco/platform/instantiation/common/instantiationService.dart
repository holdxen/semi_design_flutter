// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/instantiation/common/instantiationService.ts
// Translated 1:1 from TypeScript (475 lines). Key JS↔Dart carriers:
//   * `Reflect.construct(ctor, args)` -> `Function.apply(ctor, args)`. The TS
//     `ctor: any` is a Dart `Function` (a constructor tear-off / function).
//   * `instanceof SyncDescriptor` -> `is SyncDescriptor`.
//   * JS `Set<ServiceIdentifier>` identity -> Dart `Set` (ServiceIdentifier
//     has identity-based ==/hashCode, see instantiation.dart).
//   * the lazy Proxy for delayed instantiation -> [LazyProxy], an explicit
//     carrier exposing `get`/`set`/`getPrototypeOf` traps (Dart has no Proxy).
//   * `console.trace`/`console.warn` -> provider hooks, default no-op.
// ---------------------------------------------------------------------------

import '../../../base/common/async.dart' show GlobalIdleValue;
import '../../../base/common/errors.dart' show illegalState;
import '../../../base/common/lifecycle.dart'
    show DisposableStore, IDisposable, isDisposable, toDisposable;
import '../../../base/common/lifecycle.dart' as lifecycle show dispose;
import '../../../base/common/linkedList.dart' show LinkedList;
import 'descriptors.dart' show SyncDescriptor, SyncDescriptor0;
import 'graph.dart' show Graph, Node;
import 'instantiation.dart'
    show
        IInstantiationService,
        IInstantiationServiceType,
        ServiceDependency,
        ServiceIdentifier,
        ServicesAccessor,
        Util;
import 'serviceCollection.dart' show ServiceCollection;

// Console hooks: 1:1 observation of `console.trace` / `console.warn` calls.
void Function(String message)? consoleTraceHook;
void Function(String message)? consoleWarnHook;

void _consoleTrace(String message) => consoleTraceHook?.call(message);
void _consoleWarn(String message) => consoleWarnHook?.call(message);

/// 1:1: `const _enableAllTracing = false`
const bool _enableAllTracing = false;

/// 1:1: `class CyclicDependencyError extends Error`
/// TS `super('cyclic dependency between services'); this.message = graph...`
/// Dart `Error` has no settable `message`, so both strings are carried.
class CyclicDependencyError extends Error {
  final String baseMessage = 'cyclic dependency between services';
  final String graphMessage;
  CyclicDependencyError(Graph<Object?> graph)
      : graphMessage = graph.findCycleSlow() ??
            'UNABLE to detect cycle, dumping graph: \n${graph.toString()}';

  @override
  String toString() => 'CyclicDependencyError: $baseMessage\n$graphMessage';
}

// 1:1 carrier for the `EaryListenerData` record inside delayed instantiation.
class _EarlyListenerData {
  /// `Parameters<Event<any>>` -> [listener, thisArg, disposables]
  final List<Object?> listener;
  IDisposable? disposable;
  // ignore: unused_element_parameter
  _EarlyListenerData(this.listener, [this.disposable]);
}

/// 1:1 carrier for the JS lazy `Proxy` returned by delayed instantiation.
/// Dart has no `Proxy`, so the three traps are exposed as explicit methods;
/// the semantics (early event capture, method binding, idle value) are kept.
class LazyProxy<T> {
  final GlobalIdleValue<T> _idle;
  final Map<Object, Object?> _target = <Object, Object?>{};
  final Map<String, LinkedList<_EarlyListenerData>> _earlyListeners =
      <String, LinkedList<_EarlyListenerData>>{};
  final Map<Object, _EarlyListenerData> _earlyEntryByDisposable =
      <Object, _EarlyListenerData>{};

  LazyProxy(this._idle);

  /// `get(target, key)` trap.
  Object? get(Object key) {
    if (!_idle.isInitialized &&
        key is String &&
        (key.startsWith('onDid') || key.startsWith('onWill'))) {
      LinkedList<_EarlyListenerData>? list = _earlyListeners[key];
      if (list == null) {
        list = LinkedList<_EarlyListenerData>();
        _earlyListeners[key] = list;
      }
      final LinkedList<_EarlyListenerData> capturedList = list;
      final String capturedKey = key;

      // The synthesized `event` function.
      IDisposable event(dynamic listener, [dynamic thisArg, dynamic disposables]) {
        if (_idle.isInitialized) {
          final Object? candidate = _idle.value;
          final Object? fn = _readProperty(candidate, capturedKey);
          if (fn is Function) {
            return Function.apply(fn, <Object?>[listener, thisArg, disposables])
                as IDisposable;
          }
          // TS: `idle.value[key](...)` would throw if not callable. Mirror it.
          throw StateError('idle.value[$capturedKey] is not a function');
        } else {
          final entry = _EarlyListenerData(<Object?>[listener, thisArg, disposables]);
          final void Function() rm = capturedList.push(entry);
          final IDisposable result = toDisposable(() {
            rm();
            entry.disposable?.dispose();
          });
          _earlyEntryByDisposable[result] = entry;
          return result;
        }
      }

      return event;
    }

    // value already exists
    if (_target.containsKey(key)) {
      return _target[key];
    }

    // create value: `const obj = idle.value; let prop = obj[key]; ...`
    final Object obj = _idle.value as Object;
    final Object? prop = _readProperty(obj, key);
    if (prop is! Function) {
      return prop;
    }
    // `prop.bind(obj)` — Dart method tear-offs are already bound to the
    // receiver, so we store the function as-is (the object is captured by the
    // property getter, matching the JS bound semantics for our carriers).
    final Object? bound = prop;
    _target[key] = bound;
    return bound;
  }

  /// `set(_target, p, value)` trap.
  bool set(Object key, Object? value) {
    _writeProperty(_idle.value as Object, key, value);
    return true;
  }

  /// `getPrototypeOf(_target)` trap — Dart has no prototype chain; the
  /// original `ctor.prototype` is retained as an opaque carrier.
  Object? getPrototypeOf() => _prototype;

  Object? _prototype;
  void setPrototype(Object? prototype) => _prototype = prototype;

  /// Replay the early event listeners once the real service is created.
  /// 1:1 with the loop inside the `GlobalIdleValue` executor.
  void replayEarlyListeners(Object result) {
    for (final MapEntry<String, LinkedList<_EarlyListenerData>> entry
        in _earlyListeners.entries) {
      final Object? candidate = _readProperty(result, entry.key);
      if (candidate is Function) {
        for (final _EarlyListenerData value in entry.value.iterable) {
          value.disposable = Function.apply(
              candidate, value.listener) as IDisposable;
        }
      }
    }
    _earlyListeners.clear();
  }

  // Property access on an arbitrary Dart object. Providers let downstream
  // carriers expose dynamic JS-like `obj[key]` access; default uses common
  // Map/record-ish shapes. This is the only place `obj[key]` is emulated.
  static Object? Function(Object object, Object key)? propertyGetProvider;
  static void Function(Object object, Object key, Object? value)?
      propertySetProvider;

  static Object? _readProperty(Object? object, Object key) {
    if (object == null) return null;
    final provider = propertyGetProvider;
    if (provider != null) return provider(object, key);
    if (object is Map && object.containsKey(key)) return object[key];
    return null;
  }

  static void _writeProperty(Object? object, Object key, Object? value) {
    if (object == null) return;
    final provider = propertySetProvider;
    if (provider != null) {
      provider(object, key, value);
    } else if (object is Map) {
      object[key] = value;
    }
  }
}

/// 1:1: `export class InstantiationService implements IInstantiationService`
class InstantiationService implements IInstantiationServiceType, IDisposable {
  // ignore: unused_element, override_on_non_overriding_member
  Object? get _serviceBrand => null;

  /// 1:1: `readonly _globalGraph?: Graph<string>`
  late final Graph<String>? _globalGraph;

  /// 1:1: `private _globalGraphImplicitDependency?: string`
  String? _globalGraphImplicitDependency;

  bool _isDisposed = false;

  /// 1:1: `private readonly _servicesToMaybeDispose = new Set<any>()`
  final Set<Object> _servicesToMaybeDispose = <Object>{};

  /// 1:1: `private readonly _children = new Set<InstantiationService>()`
  final Set<InstantiationService> _children = <InstantiationService>{};

  /// 1:1: `private readonly _services: ServiceCollection`
  final ServiceCollection _services;

  /// 1:1: `private readonly _strict: boolean`
  final bool _strict;

  /// 1:1: `private readonly _parent?: InstantiationService`
  final InstantiationService? _parent;

  /// 1:1: `private readonly _enableTracing: boolean`
  final bool _enableTracing;

  InstantiationService([
    ServiceCollection? services,
    this._strict = false,
    this._parent,
    this._enableTracing = _enableAllTracing,
  ]) : _services = services ?? ServiceCollection() {
    // 1:1: `this._services.set(IInstantiationService, this)`
    _services.set(IInstantiationService, this);
    // 1:1: `_globalGraph = _enableTracing ? _parent?._globalGraph ?? new Graph(e => e) : undefined`
    _globalGraph = _enableTracing
        ? (_parent?._globalGraph ?? Graph<String>((String e) => e))
        : null;
  }

  /// 1:1: `dispose(): void`
  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      // dispose all child services. `dispose(this._children)` in TS iterates
      // the Set while each child's dispose removes itself from it — safe in JS,
      // but Dart throws concurrent-modification, so snapshot to a List first.
      lifecycle.dispose(List<Object>.from(_children));
      _children.clear();

      // dispose all services created by this service
      for (final Object candidate in _servicesToMaybeDispose) {
        if (isDisposable(candidate)) {
          (candidate as IDisposable).dispose();
        }
      }
      _servicesToMaybeDispose.clear();
    }
  }

  /// 1:1: `private _throwIfDisposed(): void`
  void _throwIfDisposed() {
    if (_isDisposed) {
      throw StateError('InstantiationService has been disposed');
    }
  }

  /// 1:1: `createChild(services, store?): IInstantiationService`
  @override
  InstantiationService createChild(ServiceCollection services,
      [DisposableStore? store]) {
    _throwIfDisposed();

    final InstantiationService that = this;
    late final InstantiationService result;
    result = _ChildInstantiationService(
      that,
      () => result,
      services,
      _strict,
      this,
      _enableTracing,
    );
    _children.add(result);

    store?.add(result);
    return result;
  }

  /// 1:1: `invokeFunction<R, TS>(fn, ...args): R`
  @override
  Object? invokeFunction(Object fn, [List<Object?>? args]) {
    _throwIfDisposed();

    final Trace trace = Trace.traceInvocation(_enableTracing, fn);
    bool done = false;
    try {
      final ServicesAccessor accessor = _Accessor(this, trace, () => done);
      final List<Object?> callArgs = <Object?>[accessor, ...(args ?? <Object?>[])];
      return Function.apply(fn as Function, callArgs);
    } finally {
      done = true;
      trace.stop();
    }
  }

  /// 1:1: `createInstance<T>(descriptor: SyncDescriptor0<T>): T`
  @override
  Object? createInstanceFromDescriptor(SyncDescriptor0 descriptor) {
    return createInstance(descriptor);
  }

  /// 1:1: `createInstance<Ctor,...>(ctor, ...args): R`
  @override
  Object? createInstance(Object ctorOrDescriptor, [List<Object?>? args]) {
    _throwIfDisposed();

    final List<Object?> rest = args ?? <Object?>[];
    late final Trace trace;
    Object? result;
    if (ctorOrDescriptor is SyncDescriptor) {
      trace = Trace.traceCreation(_enableTracing, ctorOrDescriptor.ctor);
      result = _createInstance(
        ctorOrDescriptor.ctor,
        <Object?>[...ctorOrDescriptor.staticArguments, ...rest],
        trace,
      );
    } else {
      trace = Trace.traceCreation(_enableTracing, ctorOrDescriptor);
      result = _createInstance(ctorOrDescriptor, rest, trace);
    }
    trace.stop();
    return result;
  }

  /// 1:1: `private _createInstance<T>(ctor, args = [], _trace): T`
  Object? _createInstance(Object ctor, [List<Object?>? args, Trace? trace]) {
    final List<Object?> actualArgs = args ?? <Object?>[];
    final Trace actualTrace = trace ?? Trace.traceCreation(false, ctor);

    // arguments defined by service decorators
    final List<ServiceDependency> serviceDependencies =
        Util.getServiceDependencies(ctor)..sort((a, b) => a.index - b.index);
    final List<Object?> serviceArgs = <Object?>[];
    for (final ServiceDependency dependency in serviceDependencies) {
      final Object? service =
          _getOrCreateServiceInstance(dependency.id, actualTrace);
      if (service == null) {
        _throwIfStrict(
          '[createInstance] ${_ctorName(ctor)} depends on UNKNOWN service ${dependency.id}.',
          false,
        );
      }
      serviceArgs.add(service);
    }

    final int firstServiceArgPos = serviceDependencies.isNotEmpty
        ? serviceDependencies.first.index
        : actualArgs.length;

    // check for argument mismatches, adjust static args if needed
    if (actualArgs.length != firstServiceArgPos) {
      _consoleTrace(
        '[createInstance] First service dependency of ${_ctorName(ctor)} at position ${firstServiceArgPos + 1} conflicts with ${actualArgs.length} static arguments',
      );
      final int delta = firstServiceArgPos - actualArgs.length;
      if (delta > 0) {
        actualArgs.addAll(List<Object?>.filled(delta, null));
      } else {
        actualArgs.removeRange(firstServiceArgPos, actualArgs.length);
      }
    }

    // now create the instance: `Reflect.construct(ctor, args.concat(serviceArgs))`
    return Function.apply(ctor as Function, <Object?>[...actualArgs, ...serviceArgs]);
  }

  /// 1:1: `private _setCreatedServiceInstance<T>(id, instance): void`
  void _setCreatedServiceInstance(ServiceIdentifier id, Object? instance) {
    if (_services.get(id) is SyncDescriptor) {
      _services.set(id, instance);
    } else if (_parent != null) {
      _parent._setCreatedServiceInstance(id, instance);
    } else {
      throw StateError('illegalState - setting UNKNOWN service instance');
    }
  }

  /// 1:1: `private _getServiceInstanceOrDescriptor<T>(id): T | SyncDescriptor<T>`
  Object? _getServiceInstanceOrDescriptor(ServiceIdentifier id) {
    final Object? instanceOrDesc = _services.get(id);
    if (instanceOrDesc == null && _parent != null) {
      return _parent._getServiceInstanceOrDescriptor(id);
    }
    return instanceOrDesc;
  }

  /// 1:1: `protected _getOrCreateServiceInstance<T>(id, _trace): T`
  ///
  /// TS `protected` has no Dart equivalent; the trailing underscore makes this
  /// library-private, so cross-library subclasses (e.g. TestInstantiationService)
  /// cannot call it. [getOrCreateServiceInstance] is the public forwarding slot.
  Object? getOrCreateServiceInstance(ServiceIdentifier id, Trace trace) =>
      _getOrCreateServiceInstance(id, trace);

  Object? _getOrCreateServiceInstance(ServiceIdentifier id, Trace trace) {
    final String? implicitDep = _globalGraphImplicitDependency;
    if (_globalGraph != null && implicitDep != null) {
      _globalGraph.insertEdge(implicitDep, id.toString());
    }
    final Object? thing = _getServiceInstanceOrDescriptor(id);
    if (thing is SyncDescriptor) {
      return _safeCreateAndCacheServiceInstance(
          id, thing, trace.branch(id, true));
    } else {
      trace.branch(id, false);
      return thing;
    }
  }

  /// 1:1: `private readonly _activeInstantiations = new Set<ServiceIdentifier<any>>()`
  final Set<ServiceIdentifier> _activeInstantiations = <ServiceIdentifier>{};

  /// 1:1: `private _safeCreateAndCacheServiceInstance<T>(id, desc, _trace): T`
  Object? _safeCreateAndCacheServiceInstance(
      ServiceIdentifier id, SyncDescriptor desc, Trace trace) {
    if (_activeInstantiations.contains(id)) {
      throw StateError(
          "illegal state - RECURSIVELY instantiating service '$id'");
    }
    _activeInstantiations.add(id);
    try {
      return _createAndCacheServiceInstance(id, desc, trace);
    } finally {
      _activeInstantiations.remove(id);
    }
  }

  /// 1:1 record `{ id, desc, _trace }` used by the dependency graph.
  _Triple _tripleOf(ServiceIdentifier id, SyncDescriptor desc, Trace trace) =>
      _Triple(id, desc, trace);

  /// 1:1: `private _createAndCacheServiceInstance<T>(id, desc, _trace): T`
  Object? _createAndCacheServiceInstance(
      ServiceIdentifier id, SyncDescriptor desc, Trace trace) {
    final Graph<_Triple> graph = Graph<_Triple>((_Triple data) => data.id.toString());

    int cycleCount = 0;
    final List<_Triple> stack = <_Triple>[_tripleOf(id, desc, trace)];
    final Set<String> seen = <String>{};
    while (stack.isNotEmpty) {
      final _Triple item = stack.removeLast();

      if (seen.contains(item.id.toString())) {
        continue;
      }
      seen.add(item.id.toString());

      graph.lookupOrInsertNode(item);

      // a weak but working heuristic for cycle checks
      if (cycleCount++ > 1000) {
        throw CyclicDependencyError(graph);
      }

      // check all dependencies for existence and if they need to be created first
      for (final ServiceDependency dependency
          in Util.getServiceDependencies(item.desc.ctor)) {
        final Object? instanceOrDesc =
            _getServiceInstanceOrDescriptor(dependency.id);
        if (instanceOrDesc == null) {
          _throwIfStrict(
            '[createInstance] $id depends on ${dependency.id} which is NOT registered.',
            true,
          );
        }

        // take note of all service dependencies
        _globalGraph?.insertEdge(item.id.toString(), dependency.id.toString());

        if (instanceOrDesc is SyncDescriptor) {
          final _Triple d = _tripleOf(
            dependency.id,
            instanceOrDesc,
            item.trace.branch(dependency.id, true),
          );
          graph.insertEdge(item, d);
          stack.add(d);
        }
      }
    }

    while (true) {
      final List<Node<_Triple>> roots = graph.roots();

      // if there is no more roots but still nodes in the graph we have a cycle
      if (roots.isEmpty) {
        if (!graph.isEmpty()) {
          throw CyclicDependencyError(graph);
        }
        break;
      }

      for (final Node<_Triple> root in roots) {
        final _Triple data = root.data;
        // Repeat the check for this still being a service sync descriptor.
        final Object? instanceOrDesc = _getServiceInstanceOrDescriptor(data.id);
        if (instanceOrDesc is SyncDescriptor) {
          final Object? instance = _createServiceInstanceWithOwner(
            data.id,
            data.desc.ctor,
            data.desc.staticArguments,
            data.desc.supportsDelayedInstantiation,
            data.trace,
          );
          _setCreatedServiceInstance(data.id, instance);
        }
        graph.removeNode(data);
      }
    }
    return _getServiceInstanceOrDescriptor(id);
  }

  /// 1:1: `private _createServiceInstanceWithOwner<T>(id, ctor, args, supportsDelayedInstantiation, _trace): T`
  Object? _createServiceInstanceWithOwner(
    ServiceIdentifier id,
    Object ctor, [
    List<Object?>? args,
    bool supportsDelayedInstantiation = false,
    Trace? trace,
  ]) {
    if (_services.get(id) is SyncDescriptor) {
      return _createServiceInstance(
        id,
        ctor,
        args,
        supportsDelayedInstantiation,
        trace,
        _servicesToMaybeDispose,
      );
    } else if (_parent != null) {
      return _parent._createServiceInstanceWithOwner(
        id,
        ctor,
        args,
        supportsDelayedInstantiation,
        trace,
      );
    } else {
      throw StateError(
          'illegalState - creating UNKNOWN service instance ${_ctorName(ctor)}');
    }
  }

  /// 1:1: `private _createServiceInstance<T>(id, ctor, args, supportsDelayedInstantiation, _trace, disposeBucket): T`
  Object? _createServiceInstance(
    ServiceIdentifier id,
    Object ctor, [
    List<Object?>? args,
    bool supportsDelayedInstantiation = false,
    Trace? trace,
    Set<Object>? disposeBucket,
  ]) {
    final Set<Object> bucket = disposeBucket ?? <Object>{};
    final Trace actualTrace = trace ?? Trace.traceCreation(false, ctor);
    if (!supportsDelayedInstantiation) {
      // eager instantiation
      final Object? result = _createInstance(ctor, args, actualTrace);
      if (result != null) bucket.add(result);
      return result;
    } else {
      final InstantiationService child = InstantiationService(
          null, _strict, this, _enableTracing);
      child._globalGraphImplicitDependency = id.toString();

      // Return a proxy object backed by an idle value. The early-listener map
      // lives inside [LazyProxy] (its `get` trap captures it, 1:1 with the TS
      // closure over `earlyListeners`).
      late final LazyProxy<Object?> proxy;
      final GlobalIdleValue<Object?> idle = GlobalIdleValue<Object?>(() {
        final Object? result = child._createInstance(ctor, args, actualTrace);

        // early listeners that we kept are now being subscribed to the real service
        if (result != null) {
          proxy.replayEarlyListeners(result);
          bucket.add(result);
        }
        return result;
      });
      proxy = LazyProxy<Object?>(idle);
      // `getPrototypeOf(_target) => ctor.prototype`
      proxy.setPrototype(ctor);
      return proxy;
    }
  }

  /// Observation hook (1:1 read-only view of the private `_globalGraph`):
  /// exposes the traced service-dependency cycle for verification, matching
  /// how the official test reads `insta2._globalGraph?.findCycleSlow()`.
  String? debugGlobalGraphCycle() => _globalGraph?.findCycleSlow();

  /// 1:1: `private _throwIfStrict(msg, printWarning): void`
  void _throwIfStrict(String msg, bool printWarning) {
    if (printWarning) {
      _consoleWarn(msg);
    }
    if (_strict) {
      throw StateError(msg);
    }
  }
}

// 1:1: `const type Triple = { id, desc, _trace }`
class _Triple {
  final ServiceIdentifier id;
  final SyncDescriptor desc;
  final Trace trace;
  _Triple(this.id, this.desc, this.trace);
}

/// The anonymous subclass created in `createChild`:
/// `new class extends InstantiationService { override dispose() { that._children.delete(result); super.dispose(); } }`
class _ChildInstantiationService extends InstantiationService {
  final InstantiationService _that;
  final InstantiationService Function() _result;

  _ChildInstantiationService(
    this._that,
    this._result,
    ServiceCollection services,
    bool strict,
    InstantiationService parent,
    bool enableTracing,
  ) : super(services, strict, parent, enableTracing);

  @override
  void dispose() {
    _that._children.remove(_result());
    super.dispose();
  }
}

/// 1:1: `const accessor: ServicesAccessor = { get: <T>(id) => { ... } }`
class _Accessor implements ServicesAccessor {
  final InstantiationService _service;
  final Trace _trace;
  final bool Function() _done;

  _Accessor(this._service, this._trace, this._done);

  @override
  Object? get(ServiceIdentifier id) {
    if (_done()) {
      throw illegalState(
          'service accessor is only valid during the invocation of its target method');
    }
    final Object? result = _service._getOrCreateServiceInstance(id, _trace);
    if (result == null) {
      _service._throwIfStrict("[invokeFunction] unknown service '$id'", false);
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Tracing
// ---------------------------------------------------------------------------

/// 1:1: `const enum TraceType`
class TraceType {
  static const int None = 0;
  static const int Creation = 1;
  static const int Invocation = 2;
  static const int Branch = 3;
  const TraceType._();
}

/// 1:1: `private readonly _dep: [ServiceIdentifier<any>, boolean, Trace?][]`
class _TraceDep {
  final ServiceIdentifier id;
  final bool first;
  final Trace? child;
  _TraceDep(this.id, this.first, this.child);
}

/// 1:1: `export class Trace`
class Trace {
  /// 1:1: `static all = new Set<string>()`
  static final Set<String> all = <String>{};

  static final Trace _None = _NoneTrace();

  /// 1:1: `static traceInvocation(_enableTracing, ctor): Trace`
  static Trace traceInvocation(bool enableTracing, Object ctor) {
    if (!enableTracing) return _None;
    final String name = _ctorName(ctor).isNotEmpty
        ? _ctorName(ctor)
        : 'unknown'; // `new Error().stack` carrier — Dart has no stack line index
    return Trace(TraceType.Invocation, name);
  }

  /// 1:1: `static traceCreation(_enableTracing, ctor): Trace`
  static Trace traceCreation(bool enableTracing, Object ctor) {
    if (!enableTracing) return _None;
    return Trace(TraceType.Creation, _ctorName(ctor));
  }

  /// 1:1: `private static _totals: number = 0`
  static int _totals = 0;

  /// 1:1: `private readonly _start: number = Date.now()`
  final int _start;

  /// 1:1: `readonly type: TraceType`
  final int type;

  /// 1:1: `readonly name: string | null`
  final String? name;

  /// 1:1: `private readonly _dep: [...]`
  final List<_TraceDep> _dep = <_TraceDep>[];

  Trace(this.type, this.name) : _start = DateTime.now().millisecondsSinceEpoch;

  /// 1:1: `branch(id, first): Trace`
  Trace branch(ServiceIdentifier id, bool first) {
    final Trace child = Trace(TraceType.Branch, id.toString());
    _dep.add(_TraceDep(id, first, child));
    return child;
  }

  /// 1:1: `stop(): void`
  void stop() {
    final int dur = DateTime.now().millisecondsSinceEpoch - _start;
    _totals += dur;

    bool causedCreation = false;

    String printChild(int n, Trace trace) {
      final List<String> res = <String>[];
      final String prefix = '\t' * n;
      for (final _TraceDep dep in trace._dep) {
        if (dep.first && dep.child != null) {
          causedCreation = true;
          res.add('${prefix}CREATES -> ${dep.id}');
          final String nested = printChild(n + 1, dep.child!);
          if (nested.isNotEmpty) {
            res.add(nested);
          }
        } else {
          res.add('${prefix}uses -> ${dep.id}');
        }
      }
      return res.join('\n');
    }

    final String childText = printChild(1, this);
    final List<String> lines = <String>[
      '${type == TraceType.Creation ? 'CREATE' : 'CALL'} $name',
      childText,
      'DONE, took ${dur.toDouble().toStringAsFixed(2)}ms (grand total ${_totals.toDouble().toStringAsFixed(2)}ms)',
    ];

    if (dur > 2 || causedCreation) {
      all.add(lines.join('\n'));
    }
  }
}

/// `_None` trace: `override stop() {}` and `override branch() { return this; }`
class _NoneTrace extends Trace {
  _NoneTrace() : super(TraceType.None, null);

  @override
  void stop() {}

  @override
  Trace branch(ServiceIdentifier id, bool first) => this;
}

/// 1:1 carrier for JS `ctor.name` (Dart `Function` has no `.name` field).
String _ctorName(Object ctor) {
  if (ctor is Function) {
    final String s = ctor.toString();
    // `Function.toString()` for a tear-off is stable enough for messages;
    // keep the shortest meaningful token.
    return s;
  }
  return ctor.runtimeType.toString();
}
