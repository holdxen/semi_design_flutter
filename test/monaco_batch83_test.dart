// batch83: hotReloadHelpers.ts + platformObservableUtils.ts — data-driven
// from batch83_truth.json (Node vm against real TS sources with faithful
// configuration/contextkey service stubs).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart'
    show Event;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable, toDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/hotReloadHelpers.dart'
    as h;
import 'package:semi_design_flutter/src/monaco/base/common/observable.dart'
    show IReader, autorun;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    show
        IConfigurationChange,
        IConfigurationChangeEvent,
        IConfigurationOverrides,
        IConfigurationServiceType,
        IConfigurationUpdateOptions;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart'
    show
        ContextKeyExpression,
        IContext,
        IContextKey,
        IContextKeyServiceTarget,
        IContextKeyServiceType,
        IScopedContextKeyService;
import 'package:semi_design_flutter/src/monaco/platform/observable/common/platformObservableUtils.dart'
    as p;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch83_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

class _ChangeEvent implements IConfigurationChangeEvent {
  final bool Function(String) _affects;
  _ChangeEvent(this._affects);
  @override
  bool affectsConfiguration(String configuration,
          [IConfigurationOverrides? overrides]) =>
      _affects(configuration);
  @override
  Set<String> get affectedKeys => const <String>{};
  @override
  bool get hasChanges => true;
  @override
  IConfigurationChange get change => throw UnimplementedError();
  @override
  int get source => 0;
}

class _ConfigMock implements IConfigurationServiceType {
  final Map<String, Object?> values;
  final List<dynamic> listeners = [];
  _ConfigMock(this.values);
  // ignore: unused_element, override_on_non_overriding_member
  Object? get _serviceBrand => null;

  void fire(IConfigurationChangeEvent e) {
    for (final l in listeners) {
      (l as dynamic)(e);
    }
  }

  @override
  Event<IConfigurationChangeEvent> get onDidChangeConfiguration =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
        listeners.add(listener);
        return toDisposable(() {
          listeners.remove(listener);
        });
      };
  @override
  Map<String, Object?>? getConfigurationData() => values;
  @override
  Object? getValue$0() => null;
  @override
  Object? getValue$1(String section) => values[section];
  @override
  Object? getValue$2(IConfigurationOverrides overrides) => null;
  @override
  Object? getValue$3(String section, IConfigurationOverrides overrides) => null;
  @override
  Future<void> updateValue$2(String key, Object? value) async {}
  @override
  Future<void> updateValue$3(String key, Object? value, int target) async {}
  @override
  Future<void> updateValue$4(
      String key, Object? value, Object? overrides) async {}
  @override
  Future<void> updateValue$5(String key, Object? value, Object? overrides,
      int target, [IConfigurationUpdateOptions? options]) async {}
  @override
  Map<String, Object?> inspect(String key,
          [IConfigurationOverrides? overrides]) =>
      <String, Object?>{};
  @override
  Future<void> reloadConfiguration([Object? target]) async {}
  @override
  Map<String, Object?> keys() => values.keys.toList().asMap().map((k, v) =>
      MapEntry<String, Object?>(v as String, null));
}

class _CtxKey<T> implements IContextKey<T> {
  T? _value;
  @override
  void set(T value) => _value = value;
  @override
  void reset() => _value = null;
  @override
  T? get_() => _value;
}

class _CtxService implements IContextKeyServiceType {
  final Map<String, Object?> values;
  final List<dynamic> listeners = [];
  final Map<String, Object?> bound = {};
  _CtxService(this.values);
  // ignore: unused_element, override_on_non_overriding_member
  Object? get _serviceBrand => null;
  @override
  Object get onDidChangeContext =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
        listeners.add(listener);
        return toDisposable(() {
          listeners.remove(listener);
        });
      };
  void fire() {
    for (final l in listeners) {
      (l as dynamic)(<String, Object?>{});
    }
  }

  @override
  void bufferChangeEvents(void Function() callback) => callback();
  @override
  IContextKey<T> createKey<T>(String key, T? defaultValue) =>
      _CtxKey<T>();
  @override
  bool contextMatchesRules(ContextKeyExpression? rules) => false;
  @override
  T? getContextKeyValue<T>(String key) => values[key] as T?;
  @override
  IScopedContextKeyService createScoped(IContextKeyServiceTarget target) =>
      throw UnimplementedError();
  @override
  IContextKeyServiceType createOverlay(Iterable<List<Object?>> overlay) =>
      throw UnimplementedError();
  @override
  IContext getContext(IContextKeyServiceTarget? target) =>
      throw UnimplementedError();
  @override
  void updateParent(IContextKeyServiceType parentContextKeyService) {}
}

void main() {
  group('hotReloadHelpers (disabled path)', () {
    test('readHotReloadableExport returns value; createHotClass observable reads clazz', () {
      final t = _truth()['hotDisabled'] as Map<String, dynamic>;
      final clazz = Object();
      expect(h.readHotReloadableExport(clazz, null) == clazz,
          t['readReturnsSame']);
      final oc = h.createHotClass<Object>(clazz);
      Object? read;
      final d = autorun((IReader reader) {
        read = oc.read(reader);
      });
      expect(t['createReturnsObservable'], isTrue);
      expect(read == clazz, t['readIsClazz']);
      d.dispose();
    });
  });

  group('observableConfigValue', () {
    test('filters by affectsConfiguration and applies default on undefined', () {
      final t = _truth()['configValue'] as List;
      final values = <String, Object?>{'a': 1};
      final svc = _ConfigMock(values);
      final obs = p.observableConfigValue<int>('a', 99, svc);
      Object? value;
      final d = autorun((IReader reader) {
        value = obs.read(reader);
      });
      expect(value, t[0]['value']); // initial = 1
      values['a'] = 2;
      svc.fire(_ChangeEvent((_) => false));
      expect(value, t[1]['value']); // unrelated change -> unchanged 1
      values['a'] = 3;
      svc.fire(_ChangeEvent((_) => true));
      expect(value, t[2]['value']); // affecting change -> 3
      values.remove('a');
      svc.fire(_ChangeEvent((_) => true));
      expect(value, t[3]['value']); // deleted -> default 99
      d.dispose();
    });
  });

  group('observableContextKey', () {
    test('reads value and updates on context change', () {
      final t = _truth()['contextKey'] as List;
      final values = <String, Object?>{'k': 'v1'};
      final svc = _CtxService(values);
      final obs = p.observableContextKey<String>('k', svc);
      Object? value;
      final d = autorun((IReader reader) {
        value = obs.read(reader);
      });
      expect(value, t[0]['value']); // initial v1
      values['k'] = 'v2';
      svc.fire();
      expect(value, t[1]['value']); // changed v2
      values.remove('k');
      svc.fire();
      expect(value, isNull); // deleted -> undefined -> null
      d.dispose();
    });
  });
}
