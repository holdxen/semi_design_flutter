// Truth replay for batch200:
//   `platform/accessibility/browser/accessibleViewRegistry.ts`.
//
// Expectations come from `tool/ts2dart/batch200_truth.json`, produced by
// `tool/ts2dart/_batch200_truth.cjs` (real transpiled registry + the real
// `accessibleView.ts`; every other import is type-only).
//
// NOTE: `accessibleViewRegistry.ts` has no official test of its own (the
// STRICT+test match is the usual stem heuristic false positive); truth comes
// from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/platform/accessibility/browser/accessibleView.dart'
    as av;
import '../lib/src/monaco/platform/accessibility/browser/accessibleViewRegistry.dart'
    as registry;
import '../lib/src/monaco/platform/contextkey/common/contextkey.dart'
    as contextkey;
import '../lib/src/monaco/platform/instantiation/common/instantiation.dart'
    show ServicesAccessor;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch200_truth.json').readAsStringSync()));

class _ProviderStub {
  _ProviderStub(this.label);

  final String label;
}

class _Accessor implements ServicesAccessor {
  @override
  Object? get(Object id) => null;
}

/// `implSnapshot` from the harness: type/priority/name/when/provider label.
Map<String, Object?> _snapshot(registry.IAccessibleViewImplementation impl) {
  final Object? provider = impl.getProvider(_Accessor());
  return <String, Object?>{
    'type': impl.type,
    'priority': impl.priority,
    'name': impl.name,
    'when': impl.when == null ? null : 'set',
    'providerLabel': provider is _ProviderStub ? provider.label : null,
  };
}

List<String> _names() => registry.AccessibleViewRegistry.getImplementations()
    .map((registry.IAccessibleViewImplementation i) => i.name)
    .toList();

registry.IAccessibleViewImplementation _makeImplementation(
    String name, int priority) {
  return registry.IAccessibleViewImplementation(
    type: av.AccessibleViewType.View,
    priority: priority,
    name: name,
    getProvider: (ServicesAccessor accessor) => _ProviderStub('provider:$name'),
  );
}

void main() {
  final Map<String, dynamic> truth = _truth();

  // The registry is a process-wide singleton; each case starts from the same
  // empty state the harness used for its first group.
  setUp(() => registry.AccessibleViewRegistry.getImplementations().clear());

  test('batch200 registry starts empty', () {
    final Map<String, dynamic> expected = _map(truth['empty']);
    expect(registry.AccessibleViewRegistry.getImplementations().length,
        expected['implementations']);
    expect(registry.AccessibleViewRegistry.getImplementations(), isA<List<Object?>>());
    expect(expected['isArray'], isTrue);
  });

  test('batch200 register keeps insertion order and exposes the live list', () {
    final Map<String, dynamic> afterRegister = _map(truth['afterRegister']);
    final Map<String, dynamic> liveArray = _map(truth['liveArray']);

    final registry.IAccessibleViewImplementation first =
        _makeImplementation('first', 10);
    final registry.IAccessibleViewImplementation second =
        _makeImplementation('second', 20);
    final registry.IAccessibleViewImplementation third =
        _makeImplementation('third', 5);
    final lifecycle.IDisposable firstHandle =
        registry.AccessibleViewRegistry.register(first);
    registry.AccessibleViewRegistry.register(second);
    final lifecycle.IDisposable thirdHandle =
        registry.AccessibleViewRegistry.register(third);

    expect(_names(), _exp(_list(afterRegister['names'])));
    expect(
        registry.AccessibleViewRegistry.getImplementations()
            .map(_snapshot)
            .toList(),
        _exp(_list(afterRegister['snapshots'])));

    // `getImplementations()` hands back the live list (no copy).
    final List<registry.IAccessibleViewImplementation> live =
        registry.AccessibleViewRegistry.getImplementations();
    expect(identical(live,
            registry.AccessibleViewRegistry.getImplementations()),
        liveArray['sameReference']);

    firstHandle.dispose();
    thirdHandle.dispose();
  });

  test('batch200 dispose removes the matching entry once', () {
    final registry.IAccessibleViewImplementation first =
        _makeImplementation('first', 10);
    final registry.IAccessibleViewImplementation second =
        _makeImplementation('second', 20);
    final registry.IAccessibleViewImplementation third =
        _makeImplementation('third', 5);
    final lifecycle.IDisposable firstHandle =
        registry.AccessibleViewRegistry.register(first);
    final lifecycle.IDisposable secondHandle =
        registry.AccessibleViewRegistry.register(second);
    final lifecycle.IDisposable thirdHandle =
        registry.AccessibleViewRegistry.register(third);

    secondHandle.dispose();
    expect(_names(), _exp(_list(_map(truth['afterMiddleDispose'])['names'])));

    // A second dispose must neither throw nor remove another entry.
    secondHandle.dispose();
    expect(_names(), _exp(_list(_map(truth['afterDoubleDispose'])['names'])));

    firstHandle.dispose();
    thirdHandle.dispose();
  });

  test('batch200 duplicate registrations remove the first occurrence', () {
    final registry.IAccessibleViewImplementation first =
        _makeImplementation('first', 10);
    final registry.IAccessibleViewImplementation third =
        _makeImplementation('third', 5);
    final lifecycle.IDisposable firstHandle =
        registry.AccessibleViewRegistry.register(first);
    final lifecycle.IDisposable thirdHandle =
        registry.AccessibleViewRegistry.register(third);

    final lifecycle.IDisposable duplicateA =
        registry.AccessibleViewRegistry.register(first);
    final lifecycle.IDisposable duplicateB =
        registry.AccessibleViewRegistry.register(first);
    expect(_names(),
        _exp(_list(_map(truth['afterDuplicateRegister'])['names'])));

    // `indexOf` removes the FIRST occurrence, so the second copy survives.
    duplicateA.dispose();
    expect(_names(),
        _exp(_list(_map(truth['afterFirstDuplicateDispose'])['names'])));
    duplicateB.dispose();
    expect(_names(),
        _exp(_list(_map(truth['afterSecondDuplicateDispose'])['names'])));

    firstHandle.dispose();
    thirdHandle.dispose();
  });

  test('batch200 implementation carries the optional when expression', () {
    final registry.IAccessibleViewImplementation withWhen =
        registry.IAccessibleViewImplementation(
      type: av.AccessibleViewType.Help,
      priority: 1,
      name: 'conditional',
      when: contextkey.ContextKeyExpr.true_(),
      getProvider: (ServicesAccessor accessor) => null,
    );
    final lifecycle.IDisposable handle =
        registry.AccessibleViewRegistry.register(withWhen);
    final Map<String, dynamic> expected = _map(truth['withWhen']);
    final Map<String, Object?> snapshot = _snapshot(withWhen);
    expect(snapshot['type'], expected['type']);
    expect(snapshot['priority'], expected['priority']);
    expect(snapshot['name'], expected['name']);
    expect(snapshot['when'], _exp(expected['when']));
    expect(snapshot['providerLabel'], _exp(expected['providerLabel']));
    handle.dispose();
  });

  test('batch200 cleanup leaves the registry empty', () {
    final Map<String, dynamic> expected = _map(truth['afterCleanup']);
    final lifecycle.IDisposable a =
        registry.AccessibleViewRegistry.register(_makeImplementation('a', 1));
    final lifecycle.IDisposable b =
        registry.AccessibleViewRegistry.register(_makeImplementation('b', 2));
    a.dispose();
    b.dispose();
    expect(registry.AccessibleViewRegistry.getImplementations().length,
        expected['implementations']);
  });
}