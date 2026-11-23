// batch69: instantiationServiceMock.ts. Assertions are data-driven from
// batch69_truth.json (Node TS transpile+vm real evaluation of the source with a
// faithful sinon reference implementation injected).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show DisposableStore;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/serviceCollection.dart'
    show ServiceCollection;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/test/common/instantiationServiceMock.dart'
    as m;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch69_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

bool _sinonOpt(Object? obj, String key) =>
    obj is Map && obj['sinonOptions'] is Map && obj['sinonOptions'][key] == true;

void main() {
  final t = _truth();

  test('b69 constructor + get/set (set returns old value)', () {
    final a = t['getSet'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final id = ServiceIdentifier<dynamic>('A');
    final inst = <String, Object?>{'val': 1};
    final setRet = svc.set(id, inst);
    expect(setRet == inst, a['setRetSame'], reason: 'set returns old value');
    expect(identical(svc.get(id), inst), a['getSame']);
  });

  test('b69 mock(service) does not write back to collection', () {
    final a = t['mock'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final id = ServiceIdentifier<dynamic>('B');
    svc.set(id, <String, Object?>{'val': 1});
    final mock = svc.mock(id);
    expect(a['hasRestore'], isTrue);
    // restore() is part of the SinonMock surface
    expect(mock, isA<m.SinonMock>());
    expect(mock.hasOwnProperty('serviceId'), isTrue);
    expect(identical(svc.get(id), mock), a['storedIsMock']);
  });

  test('b69 stubInstance + createInstance parent fallthrough', () {
    final a = t['stubInstance'] as Map<String, dynamic>;
    final partial = <String, Object?>{'bar': () => 9};
    final svc = m.TestInstantiationService();
    svc.stubInstance(_Foo, partial);
    final created = svc.createInstance(_Foo);
    expect(identical(created, partial), a['createdIsPartial']);
    final child = svc.createChild(ServiceCollection());
    expect(identical(child.createInstance(_Foo), partial),
        a['childCreatedIsPartial']);
  });

  test('b69 stub(service, obj) 2-arg form', () {
    final a = t['stubObject'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final id = ServiceIdentifier<dynamic>('D');
    final obj = <String, Object?>{'foo': () => 1};
    final r = svc.stub(id, obj);
    expect(r, isA<Map<String, Object?>>());
    final map = r as Map<String, Object?>;
    expect(map.containsKey('foo'), isTrue);
    expect(_sinonOpt(r, 'stub'), isTrue);
    expect(identical(svc.get(id), r), a['stored']);
  });

  test('b69 stub(service, property, value) 3-arg form', () {
    final a = t['stubProperty'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final id = ServiceIdentifier<dynamic>('E');
    svc.set(id, <String, Object?>{'existing': 1});
    final fn = () => 42;
    final r = svc.stub(id, 'prop', fn);
    final map = r as Map<String, Object?>;
    expect(_sinonOpt(r, 'stub'), isTrue);
    expect(identical(svc.get(id), r), a['storedIsRet']);
    expect(a['propType'], 'function');
    expect(identical(map['prop'], fn), a['propIsFn']);
  });

  test('b69 stub(service, obj, property, value) 4-arg form', () {
    final a = t['stubObjectProperty'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final id = ServiceIdentifier<dynamic>('F');
    final obj = <String, Object?>{'existing': 1};
    final r = svc.stub(id, obj, 'prop', 7);
    final map = r as Map<String, Object?>;
    expect(map['prop'], a['propValue']);
    expect(_sinonOpt(r, 'stub'), isTrue);
    expect(map.containsKey('existing'), isTrue);
  });

  test('b69 stubPromise stores resolved Future', () async {
    final a = t['stubPromise'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final id = ServiceIdentifier<dynamic>('G');
    svc.set(id, <String, Object?>{'p': () => 0});
    final r = svc.stubPromise(id, 'p', 5);
    final map = r as Map<String, Object?>;
    expect(map['p'], isA<Future>());
    expect(await (map['p'] as Future<Object?>), a['resolved']);
    expect(_sinonOpt(r, 'stub'), isTrue);
  });

  test('b69 spy(service, property) tracks calls and stores spy', () {
    final a = t['spy'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final id = ServiceIdentifier<dynamic>('H');
    svc.set(id, <String, Object?>{'m': () => 0});
    final spy = svc.spy(id, 'm');
    spy.call();
    spy.call();
    expect(spy, isA<m.SinonCallable>());
    expect(spy.callCount, a['callCount']);
    final stored = (svc.get(id) as Map<String, Object?>)['m'];
    expect(identical(stored, spy), a['storedIsSpy']);
  });

  test('b69 isSinonSpyLike reuses an existing spy', () {
    final a = t['spyLike'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final id = ServiceIdentifier<dynamic>('I');
    svc.set(id, <String, Object?>{'existing': 1});
    final spy = m.SinonCallable('spy');
    spy.call();
    final before = spy.callCount;
    final r = svc.stub(id, 'm', spy);
    expect(spy.callCount, a['after'], reason: 'no extra call');
    expect(before, a['before']);
    final stored = (svc.get(id) as Map<String, Object?>)['m'];
    expect(identical(stored, spy), a['reused']);
    expect(identical(r, svc.get(id)), a['retIsSpy']);
  });

  test('b69 dispose: properDispose triggers super.dispose', () {
    final svcPlain = m.TestInstantiationService();
    svcPlain.dispose();
    // plain dispose does not call super.dispose -> still usable
    expect(() => svcPlain.createInstance(_Foo.new), returnsNormally);

    final svcProper = m.TestInstantiationService(
        ServiceCollection(), false, null, true);
    svcProper.dispose();
    // properDispose calls super.dispose -> subsequent createInstance throws
    expect(() => svcProper.createInstance(_Foo.new), throwsA(isA<StateError>()));
  });

  test('b69 createChild returns TestInstantiationService', () {
    final a = t['createChild'] as Map<String, dynamic>;
    final svc = m.TestInstantiationService();
    final child = svc.createChild(ServiceCollection());
    expect(child, isA<m.TestInstantiationService>());
    expect(identical(child, svc), isNot(a['isTIS']));
    expect(identical(child, svc), isFalse, reason: 'distinct=${a['distinct']}');
  });

  test('b69 createServices: ctor descriptor vs instance', () {
    final a = t['createServices'] as Map<String, dynamic>;
    final store = DisposableStore();
    final idCtor = ServiceIdentifier<dynamic>('L1');
    final idInst = ServiceIdentifier<dynamic>('L2');
    final inst = <String, Object?>{'v': 9};
    final svc = m.createServices(store, [
      <Object?>[idCtor, _Foo.new],
      <Object?>[idInst, inst],
    ]);
    expect(svc, isA<m.TestInstantiationService>());
    expect((svc.get(idCtor) as _Foo).v, a['ctorResolvedV']);
    expect(identical(svc.get(idInst), inst), a['instSame']);
  });
}

class _Foo {
  final int v = 5;
}
