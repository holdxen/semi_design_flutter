import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/descriptors.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/extensions.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/serviceCollection.dart';

class _SvcA {}

/// batch55: 1:1 port of the instantiation hub (3-file cycle):
///   instantiation.ts / serviceCollection.ts / extensions.ts
/// Real runtime truth is captured by tool/ts2dart/_inst_truth.cjs (TS transpile
/// + vm) into tool/ts2dart/inst_truth.json. Each assertion below mirrors one
/// truth field so behavior matches the TS source exactly.
void main() {
  final truth = jsonDecode(File('tool/ts2dart/inst_truth.json').readAsStringSync()) as Map<String, dynamic>;

  group('batch55 / instantiation hub 1:1', () {
    test('_util constants + createDecorator memoization match TS truth', () {
      final t = truth['createDecorator'] as Map<String, dynamic>;
      expect(Util.DI_TARGET, truth['DI_TARGET']);
      expect(Util.DI_DEPENDENCIES, truth['DI_DEPENDENCIES']);

      final a = createDecorator<Object>('svcA');
      final a2 = createDecorator<Object>('svcA');
      final b = createDecorator<Object>('svcB');
      expect(identical(a, a2), t['memoizedSame']);
      expect(identical(a, b), !t['distinctDifferent'] as bool);
      expect(a.toString(), t['toStringA']);
      expect(b.toString(), t['toStringB']);
      expect(Util.serviceIds.containsKey('svcA'), true);
      expect(Util.serviceIds.containsKey('svcB'), true);
      expect((truth['createDecorator']['serviceIdsKeys'] as List).contains('instantiationService'), true);
    });

    test('decorator records service dependencies on target', () {
      final a = createDecorator<Object>('svcDep');
      final target = Object();
      a.call(target, 'key', 2);
      a.call(target, 'key', 3);
      final deps = Util.getServiceDependencies(target);
      expect(deps.length, (truth['getServiceDependencies']['deps'] as List).length);
      expect(deps.map((d) => d.id.toString()).toList(), <String>['svcDep', 'svcDep']);
      expect(deps.map((d) => d.index).toList(), <int>[2, 3]);
    });

    test('refineServiceDecorator is identity; IInstantiationService id matches', () {
      final a = createDecorator<Object>('refine');
      expect(identical(refineServiceDecorator<Object, Object>(a), a), truth['refineIdentity']);
      expect(IInstantiationService.toString(), truth['IInstantiationService']);
    });

    test('ServiceCollection set/has/get/clone match TS truth', () {
      final t = truth['serviceCollection'] as Map<String, dynamic>;
      final a = createDecorator<Object>('colA');
      final b = createDecorator<Object>('colB');
      final sc = ServiceCollection(<List<Object?>>[<Object?>[a, 'instA']]);
      expect(sc.has(a), t['hasA']);
      expect(sc.has(b), t['hasB']);
      expect(sc.get(a), t['getA']);
      expect(sc.set(a, 'replaced'), t['setReplacePrev']);
      expect(sc.get(a), t['getAfter']);
      expect(sc.set(b, 'instB'), null);
      expect(t['setNewPrev'], true);
      final clone = sc.clone();
      expect(clone.has(a), t['cloneHasA']);
      expect(clone.has(b), t['cloneHasB']);
      expect(identical(clone, sc), !t['cloneIsDistinct'] as bool);
    });

    test('InstantiationType values + registerSingleton wrap/store match TS truth', () {
      expect(InstantiationType.Eager, truth['InstantiationType']['Eager']);
      expect(InstantiationType.Delayed, truth['InstantiationType']['Delayed']);

      // Reset module registry is not exposed (matches TS: module-level const);
      // use fresh identifiers and check the appended entries by identity.
      final a = createDecorator<Object>('svcA');
      final b = createDecorator<Object>('svcB');
      registerSingleton(a, () => _SvcA(), InstantiationType.Delayed);
      final regs = getSingletonServiceDescriptors();
      final entryA = regs.firstWhere((e) => identical(e[0], a));
      expect(entryA[0].toString(), truth['registerSingleton']['firstIdToString']);
      expect(entryA[1] is SyncDescriptor, truth['registerSingleton']['firstIsSyncDescriptor']);
      expect((entryA[1] as SyncDescriptor).supportsDelayedInstantiation,
          truth['registerSingleton']['firstSupportsDelayed']);
      expect((entryA[1] as SyncDescriptor).staticArguments,
          truth['registerSingleton']['firstStaticArgs']);

      final desc = SyncDescriptor(() => _SvcA(), <Object?>[1, 2], true);
      registerSingleton(b, desc);
      final entryB = regs.firstWhere((e) => identical(e[0], b));
      expect(identical(entryB[1], desc), truth['registerSingleton']['descriptorPathSame']);
    });
  });
}
