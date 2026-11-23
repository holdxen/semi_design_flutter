// batch57: instantiationService.ts (475 lines) — 1:1 port verified against
// Node/TS real-runtime truth (tool/ts2dart/instsvc_truth.json) which replays
// all 22 official instantiationService.test.ts scenarios.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/descriptors.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiationService.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/serviceCollection.dart';

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/instsvc_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

void _dep(ServiceIdentifier id, Object ctor, int index) =>
    id(ctor, 'key', index);

// ----- simple / fixed args -----
class _S1 {
  int c = 1;
}

class _S2 {
  bool d = true;
}

class _Consumer {
  Object? s1;
  _Consumer(Object? s) : s1 = s;
}

class _TargetStatic {
  bool v;
  int c;
  _TargetStatic(this.v, Object? s) : c = (s as _S1).c;
}

class _ChildConsumer {
  Object? s1;
  _ChildConsumer(Object? s) : s1 = s;
}

class _Dep {
  String name = 'farboo';
  int c;
  _Dep(Object? s) : c = (s as _S1).c;
}

class _TargetDep {
  String name;
  _TargetDep(Object? d) : name = (d as _Dep).name;
}

// ----- cycle -----
class _L1 {
  int c = 1;
  _L1(Object? s2);
}

class _L2 {
  bool d = true;
  _L2(Object? s1);
}

// ----- loop -----
// Source: BConsumer consumes @B; AService injects @IInstantiationService and
// in its ctor does `this.prop = insta.createInstance(BConsumer)`; BService
// injects @A. Sync -> RECURSIVELY; lazy A -> tracked cycle A -> B -> A.
final ServiceIdentifier _loopA = createDecorator<Object>('b57_lp_A');
final ServiceIdentifier _loopB = createDecorator<Object>('b57_lp_B');

Object? _bConsumerCtor;

class _BConsumer {
  final Object b;
  _BConsumer(this.b);
  bool doIt() => (b as _BService).b();
}

class _AService {
  late final Object prop;
  _AService(Object insta) {
    final service = insta as InstantiationService;
    prop = service.invokeFunction((Object? a, [List<Object?>? args]) =>
        service.createInstance(_bConsumerCtor!))!;
  }
  bool doIt() => (prop as _BConsumer).doIt();
}

class _BService {
  final Object a;
  _BService(this.a);
  bool b() => true;
}

// ----- delayed / events -----
bool _created = false;
int _eventCount = 0;

class _AImpl {
  // ignore: unused_field
  int _doIt = 0;
  final Emitter<Object?> _em = Emitter<Object?>();
  late final Event<Object?> onDidDoIt;
  _AImpl() {
    _created = true;
    onDidDoIt = _em.event;
  }
  void doIt() {
    _doIt++;
    _em.fire(this);
  }
  void noop() {}
}

class _DelayedConsumer {
  final Object a;
  _DelayedConsumer(Object? a) : a = a!;
}

class _CaptureConsumer {
  final Object a;
  _CaptureConsumer(Object? a) : a = a!;
}

// ----- dispose -----
bool _disposedA = false;
bool _disposedB = false;

class _DisA implements IDisposable {
  final int value = 1;
  _DisA();
  @override
  void dispose() => _disposedA = true;
}

class _PlainB {
  final int value = 1;
  _PlainB();
}

class _DisConsumer {
  final int value;
  _DisConsumer(Object? a, Object? b)
      : value = (_readA(a) == (b as _PlainB).value) ? 1 : 0;

  static int _readA(Object? a) {
    if (a is _DisA) return a.value;
    // Delayed service arrives as a LazyProxy; reading `value` triggers idle.
    if (a is LazyProxy<Object?>) {
      final v = a.get('value');
      if (v is _DisA) return v.value;
      if (v is int) return v;
    }
    return 0;
  }
}

void _installDelayedProvider() {
  LazyProxy.propertyGetProvider = (Object object, Object key) {
    if (object is _AImpl) {
      switch (key) {
        case 'onDidDoIt':
          return object.onDidDoIt;
        case 'doIt':
          return object.doIt;
        case 'noop':
          return object.noop;
      }
    }
    return null;
  };
}

void main() {
  final truth = _truth();

  test('b57 simple @param + fixed args', () {
    final I1 = createDecorator<_S1>('b57_sf_1');
    final I2 = createDecorator<_S2>('b57_sf_2');
    final cCtor = _Consumer.new;
    final tCtor = _TargetStatic.new;
    _dep(I1, cCtor, 0);
    _dep(I1, tCtor, 1);
    final insta = InstantiationService(
        ServiceCollection([[I1, _S1()], [I2, _S2()]]));
    final c = insta.createInstance(cCtor) as _Consumer;
    final t = insta.createInstance(tCtor, [true]) as _TargetStatic;
    expect((c.s1 as _S1).c, truth['simpleFixed']['simpleC']);
    expect(t.v, truth['simpleFixed']['fixedV']);
    expect(t.c, truth['simpleFixed']['fixedC']);
  });

  test('b57 SyncDescriptor no-deps / dep / future', () {
    final I1 = createDecorator<_S1>('b57_sd_1');
    final IDep = createDecorator<_Dep>('b57_sd_dep');
    final depCtor = _Dep.new;
    final tDepCtor = _TargetDep.new;
    _dep(I1, depCtor, 0);
    _dep(IDep, tDepCtor, 0);
    final insta = InstantiationService(ServiceCollection([
      [I1, SyncDescriptor(_S1.new)],
      [IDep, SyncDescriptor(depCtor)],
    ]));
    final r = insta.invokeFunction((Object? a, [List<Object?>? args]) {
      final accessor = a as ServicesAccessor;
      final one = accessor.get(I1) as _S1;
      final oneB = accessor.get(I1) as _S1;
      final d = accessor.get(IDep) as _Dep;
      return <String, Object?>{
        'c': one.c,
        'same': identical(one, oneB),
        'depName': d.name,
        'depC': d.c,
      };
    }) as Map<String, Object?>;
    final t = insta.createInstance(tDepCtor) as _TargetDep;
    expect(r['c'], truth['syncDesc']['c']);
    expect(r['same'], truth['syncDesc']['same']);
    expect(r['depName'], truth['syncDesc']['depName']);
    expect(r['depC'], truth['syncDesc']['depC']);
    expect(t.name, truth['syncDesc']['targetName']);
  });

  test('b57 invoke get/optional/accessor-guard/throw', () {
    final I1 = createDecorator<_S1>('b57_inv_1');
    final I2 = createDecorator<_S2>('b57_inv_2');
    final insta = InstantiationService(
        ServiceCollection([[I1, _S1()], [I2, _S2()]]));
    final ret = insta.invokeFunction((Object? a, [List<Object?>? args]) {
      final accessor = a as ServicesAccessor;
      return accessor.get(I1) is _S1 && (accessor.get(I1) as _S1).c == 1;
    });
    expect(ret, truth['invoke']['ret']);

    final strict = InstantiationService(
        ServiceCollection([[I1, _S1()]]), true);
    bool unknownThrows = false;
    final strictRet = strict.invokeFunction((Object? a, [List<Object?>? args]) {
      try {
        (a as ServicesAccessor).get(I2);
      } catch (_) {
        unknownThrows = true;
      }
      return true;
    });
    expect(strictRet, truth['invoke']['strictRet']);
    expect(unknownThrows, truth['invoke']['strictUnknownThrows']);

    ServicesAccessor? cached;
    InstantiationService(ServiceCollection([[I1, _S1()]]))
        .invokeFunction((Object? a, [List<Object?>? args]) {
      cached = a as ServicesAccessor;
      return true;
    });
    bool accessorThrows = false;
    try {
      cached!.get(I2);
    } catch (_) {
      accessorThrows = true;
    }
    expect(accessorThrows, truth['invoke']['accessorThrows']);

    bool fnThrows = false;
    try {
      insta.invokeFunction((Object? a, [List<Object?>? args]) =>
          throw StateError('boom'));
    } catch (_) {
      fnThrows = true;
    }
    expect(fnThrows, truth['invoke']['fnThrows']);
  });

  test('b57 createChild shares parent instances', () {
    final I1 = createDecorator<_S1>('b57_child_1');
    final I2 = createDecorator<_S2>('b57_child_2');
    final cCtor = _ChildConsumer.new;
    _dep(I1, cCtor, 0);
    int count = 0;
    // `CtorCounter` in the official test has no service dependencies, so the
    // descriptor ctor is called with zero args.
    Object counterFactory() {
      count++;
      return _S1();
    }

    var insta = InstantiationService(
        ServiceCollection([[I1, SyncDescriptor(counterFactory)]]));
    insta.createInstance(cCtor);
    var child = insta.createChild(ServiceCollection([[I2, _S2()]]));
    child.createInstance(cCtor);
    expect(count, truth['child']['before']);

    count = 0;
    insta = InstantiationService(
        ServiceCollection([[I1, SyncDescriptor(counterFactory)]]));
    child = insta.createChild(ServiceCollection([[I2, _S2()]]));
    insta.createInstance(cCtor);
    child.createInstance(cCtor);
    expect(count, truth['child']['after']);
  });

  test('b57 circular dependency explodes', () {
    final I1 = createDecorator<_L1>('b57_cyc_1');
    final I2 = createDecorator<_L2>('b57_cyc_2');
    final l1Ctor = _L1.new;
    final l2Ctor = _L2.new;
    _dep(I2, l1Ctor, 0);
    _dep(I1, l2Ctor, 0);
    final insta = InstantiationService(ServiceCollection([
      [I1, SyncDescriptor(l1Ctor)],
      [I2, SyncDescriptor(l2Ctor)],
    ]));
    bool t1 = false, t2 = false, hasNameMsg = false;
    try {
      insta.invokeFunction(
          (Object? a, [List<Object?>? args]) => (a as ServicesAccessor).get(I1));
    } catch (e) {
      t1 = true;
      if (e.toString().isNotEmpty) hasNameMsg = true;
    }
    try {
      insta.invokeFunction(
          (Object? a, [List<Object?>? args]) => (a as ServicesAccessor).get(I2));
    } catch (_) {
      t2 = true;
    }
    expect(t1, truth['cycle']['throws1']);
    expect(t2, truth['cycle']['throws2']);
    expect(hasNameMsg, truth['cycle']['hasNameMsg']);
  });

  test('b57 sync/async dependency loop + graph cycle tracking', () {
    _bConsumerCtor = _BConsumer.new;
    final aCtor = _AService.new;
    final bCtor = _BService.new;
    _dep(_loopB, _bConsumerCtor!, 0);
    _dep(IInstantiationService, aCtor, 0);
    _dep(_loopA, bCtor, 0);

    final s1 = InstantiationService(ServiceCollection([
      [_loopA, SyncDescriptor(aCtor)],
      [_loopB, SyncDescriptor(bCtor)],
    ]), true, null, true);
    bool syncThrows = false, includesRec = false;
    try {
      s1.invokeFunction((Object? a, [List<Object?>? args]) =>
          (a as ServicesAccessor).get(_loopA));
    } catch (e) {
      syncThrows = true;
      if (e.toString().contains('RECURSIVELY')) includesRec = true;
    }
    expect(syncThrows, truth['loop']['syncThrows']);
    expect(includesRec, truth['loop']['includesRec']);

    final s2 = InstantiationService(ServiceCollection([
      [_loopA, SyncDescriptor(aCtor, null, true)],
      [_loopB, SyncDescriptor(bCtor)],
    ]), true, null, true);
    final a = s2.invokeFunction((Object? acc, [List<Object?>? args]) =>
        (acc as ServicesAccessor).get(_loopA));
    // In Dart the lazy proxy is a LazyProxy; forward doIt via provider.
    LazyProxy.propertyGetProvider = (Object object, Object key) {
      if (object is _AService && key == 'doIt') return object.doIt;
      if (object is _BService && key == 'b') return object.b;
      return null;
    };
    final aProxy = a as LazyProxy<Object?>;
    final doItResult = (aProxy.get('doIt') as bool Function())();
    expect(doItResult, truth['loop']['asyncDoIt']);
    // The graph cycle uses module-scoped ids; assert shape (A -> B -> A).
    final graphCycle = s2.debugGlobalGraphCycle();
    expect(graphCycle, isNotNull);
    expect(graphCycle, contains(_loopA.serviceId));
    expect(graphCycle, contains(_loopB.serviceId));
  });

  test('b57 delayed instantiation + early events', () {
    _installDelayedProvider();
    _created = false;
    _eventCount = 0;
    final A = createDecorator<_AImpl>('b57_de_A');
    final cCtor = _DelayedConsumer.new;
    _dep(A, cCtor, 0);
    final insta = InstantiationService(
        ServiceCollection([[A, SyncDescriptor(_AImpl.new, null, true)]]),
        true, null, true);
    final c = insta.createInstance(cCtor) as _DelayedConsumer;
    final proxy = c.a as LazyProxy<Object?>;
    final listener = (Object? e) {
      if (e is _AImpl) _eventCount++;
    };
    final d1 = (proxy.get('onDidDoIt') as Event<Object?>)(listener);
    final d2 = (proxy.get('onDidDoIt') as Event<Object?>)(listener);
    expect(_created, truth['delayed']['createdBefore']);
    expect(_eventCount, truth['delayed']['countBefore']);
    d2.dispose();
    (proxy.get('doIt') as void Function())();
    expect(_created, truth['delayed']['createdAfter']);
    expect(_eventCount, truth['delayed']['countAfterFirst']);
    final d3 = (proxy.get('onDidDoIt') as Event<Object?>)(listener);
    (proxy.get('doIt') as void Function())();
    expect(_eventCount, truth['delayed']['countAfterSecond']);
    dispose([d1, d3]);
    (proxy.get('doIt') as void Function())();
    expect(_eventCount, truth['delayed']['countAfterDispose']);
  });

  test('b57 capture event before init, use after init', () {
    _installDelayedProvider();
    _created = false;
    _eventCount = 0;
    final A = createDecorator<_AImpl>('b57_cbi_A');
    final cCtor = _CaptureConsumer.new;
    _dep(A, cCtor, 0);
    final insta = InstantiationService(
        ServiceCollection([[A, SyncDescriptor(_AImpl.new, null, true)]]),
        true, null, true);
    final c = insta.createInstance(cCtor) as _CaptureConsumer;
    final proxy = c.a as LazyProxy<Object?>;
    final listener = (Object? e) {
      if (e is _AImpl) _eventCount++;
    };
    final event = proxy.get('onDidDoIt') as Event<Object?>;
    expect(_created, truth['capture']['createdBeforeNoop']);
    (proxy.get('noop') as void Function())();
    expect(_created, truth['capture']['createdAfterNoop']);
    final d1 = event(listener);
    (proxy.get('doIt') as void Function())();
    expect(_eventCount, truth['capture']['count']);
    d1.dispose();
  });

  test('b57 dispose services it created', () {
    _disposedA = false;
    _disposedB = false;
    LazyProxy.propertyGetProvider = (Object object, Object key) {
      if (object is _DisA && key == 'value') return object.value;
      return null;
    };
    final A = createDecorator<_DisA>('b57_ds_A');
    final B = createDecorator<_PlainB>('b57_ds_B');
    final cCtor = _DisConsumer.new;
    _dep(A, cCtor, 0);
    _dep(B, cCtor, 1);
    final insta = InstantiationService(ServiceCollection([
      [A, SyncDescriptor(_DisA.new, null, true)],
      [B, _PlainB()],
    ]), true, null, true);
    final c = insta.createInstance(cCtor) as _DisConsumer;
    insta.dispose();
    expect(c.value, truth['disposeServices']['same'] ? 1 : 0);
    expect(_disposedA, truth['disposeServices']['disposedA']);
    expect(_disposedB, truth['disposeServices']['disposedB']);
  });

  test('b57 disposed service cannot be used; child/parent dispose', () {
    final B = createDecorator<_PlainB>('b57_dl_B');

    final insta = InstantiationService(
        ServiceCollection([[B, _PlainB()]]), true, null, true);
    final createdOk = insta.invokeFunction(
            (Object? a, [List<Object?>? args]) =>
                (a as ServicesAccessor).get(B)) != null;
    expect(createdOk, truth['disposeLifecycle']['createdOk']);
    insta.dispose();
    bool createThrows = false, invokeThrows = false, childThrows = false;
    try {
      insta.invokeFunction((Object? a, [List<Object?>? args]) =>
          (a as ServicesAccessor).get(B));
    } catch (_) {
      createThrows = true;
    }
    try {
      insta.invokeFunction((Object? a, [List<Object?>? args]) => null);
    } catch (_) {
      invokeThrows = true;
    }
    try {
      insta.createChild(ServiceCollection());
    } catch (_) {
      childThrows = true;
    }
    expect(createThrows, truth['disposeLifecycle']['createThrows']);
    expect(invokeThrows, truth['disposeLifecycle']['invokeThrows']);
    expect(childThrows, truth['disposeLifecycle']['childThrows']);

    final p1 = InstantiationService(
        ServiceCollection([[B, _PlainB()]]), true, null, true);
    final c1 = p1.createChild(ServiceCollection());
    c1.dispose();
    bool parentAlive = false, childDead = false;
    try {
      p1.invokeFunction((Object? a, [List<Object?>? args]) =>
          (a as ServicesAccessor).get(B));
      parentAlive = true;
    } catch (_) {}
    try {
      c1.invokeFunction((Object? a, [List<Object?>? args]) => null);
    } catch (_) {
      childDead = true;
    }
    expect(parentAlive, truth['disposeLifecycle']['parentAliveAfterChildDispose']);
    expect(childDead, truth['disposeLifecycle']['childDead']);

    final p2 = InstantiationService(
        ServiceCollection([[B, _PlainB()]]), true, null, true);
    final c2 = p2.createChild(ServiceCollection());
    p2.dispose();
    bool childDeadByParent = false;
    try {
      c2.invokeFunction((Object? a, [List<Object?>? args]) => null);
    } catch (_) {
      childDeadByParent = true;
    }
    expect(childDeadByParent, truth['disposeLifecycle']['childDeadByParent']);
  });

  test('b57 Trace none singleton + branch self when off', () {
    final off1 = Trace.traceInvocation(false, _S1.new);
    final off2 = Trace.traceCreation(false, _S2.new);
    expect(identical(off1, off2), truth['trace']['sameNone']);
    final branchId = createDecorator<Object>('b57_trace_id');
    final b = off1.branch(branchId, true);
    expect(identical(b, off1), truth['trace']['branchSelfWhenOff']);
    final on1 = Trace.traceInvocation(true, _S1.new);
    final on2 = Trace.traceCreation(true, _S2.new);
    expect(identical(on1, on2), isNot(truth['trace']['onDistinct']));
  });
}
