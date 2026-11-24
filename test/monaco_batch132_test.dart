// Truth-driven tests for platform/contextkey/browser/contextKeyService.ts.
// Truth: tool/ts2dart/batch132_truth.json
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart' as window;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as events;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as lifecycle;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart'
    as commands;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    as configuration;
import 'package:semi_design_flutter/src/monaco/platform/configuration/test/common/testConfigurationService.dart'
    as testConfig;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/browser/contextKeyService.dart'
    as service;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart'
    as contextkey;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch132_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Object? _n(Object? value) => value ?? '__undefined__';

testConfig.TestConfigurationService _config([
  Map<String, Object?> values = const <String, Object?>{},
]) =>
    testConfig.TestConfigurationService(Map<String, Object?>.from(values));

void main() {
  late events.Event<dom.IRegisteredCodeWindow> savedOnDidRegisterWindow;
  late dom.IRegisteredCodeWindow Function() savedInitialRegistration;
  late lifecycle.IDisposable Function(
    Object,
    String,
    void Function(dynamic), [
    Object?,
  ]) savedAddListener;
  late Object? Function(Object) savedActiveElement;
  late bool Function(Object) savedIsEditable;
  late window.CodeWindow Function() savedGetActiveWindow;
  late Object Function(window.CodeWindow) savedWindowDocument;
  late dom.IFocusTracker Function(Object) savedTrackFocus;
  late void Function(String) savedConsoleError;

  setUp(() {
    savedOnDidRegisterWindow = service.onDidRegisterWindowProvider;
    savedInitialRegistration = service.initialWindowRegistrationProvider;
    savedAddListener = service.addDisposableListenerProvider;
    savedActiveElement = service.activeElementProvider;
    savedIsEditable = service.isEditableElementProvider;
    savedGetActiveWindow = service.getActiveWindowProvider;
    savedWindowDocument = service.windowDocumentProvider;
    savedTrackFocus = service.trackFocusProvider;
    savedConsoleError = service.consoleErrorProvider;

    // Keep constructor focus tracking inert for the truth probes.
    service.onDidRegisterWindowProvider =
        (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
            lifecycle.Disposable.none;
    service.initialWindowRegistrationProvider = () => dom.IRegisteredCodeWindow(
        window.CodeWindow(Object(), 0), lifecycle.DisposableStore());
    service.addDisposableListenerProvider = (
      Object target,
      String type,
      void Function(dynamic e) handler, [
      Object? options,
    ]) =>
        lifecycle.Disposable.none;
    service.activeElementProvider = (Object document) => null;
    service.isEditableElementProvider = (Object element) => false;
    service.getActiveWindowProvider = () => window.CodeWindow(Object(), 0);
    service.windowDocumentProvider = (window.CodeWindow targetWindow) => Object();
    service.trackFocusProvider = (Object element) =>
        throw StateError('trackFocus must not be called in this probe');
    service.consoleErrorProvider = (String message) {};
  });

  tearDown(() {
    service.onDidRegisterWindowProvider = savedOnDidRegisterWindow;
    service.initialWindowRegistrationProvider = savedInitialRegistration;
    service.addDisposableListenerProvider = savedAddListener;
    service.activeElementProvider = savedActiveElement;
    service.isEditableElementProvider = savedIsEditable;
    service.getActiveWindowProvider = savedGetActiveWindow;
    service.windowDocumentProvider = savedWindowDocument;
    service.trackFocusProvider = savedTrackFocus;
    service.consoleErrorProvider = savedConsoleError;
  });

  group('batch132 / contextKeyService.ts', () {
    test('Context set/get/remove/collect/updateParent', () {
      final Map<String, dynamic> e = _truth['context'] as Map<String, dynamic>;
      final service.Context c0 = service.Context(0, null);
      final service.Context c1 = service.Context(1, c0);

      expect(c0.value['_contextId'], e['idValue']);
      expect(c0.setValue('a', 1), e['setA']);
      expect(c0.setValue('a', 1), e['setASame']);
      expect(c0.setValue('a', 2), e['setAChanged']);
      expect(c0.getValue('a'), e['getA']);
      expect(c1.getValue('a'), e['childGetA']);
      expect(c1.hasOwnValue('a'), e['hasOwnA']);
      expect(c0.removeValue('a'), e['removeA']);
      expect(c0.removeValue('a'), e['removeMissing']);
      expect(_n(c1.getValue('a')), e['childGetAfterRemove']);
      expect(c0.collectAllValues(), e['collectAll']);

      final service.Context p1 = service.Context(10, null);
      p1.setValue('x', 1);
      final service.Context p2 = service.Context(20, null);
      p2.setValue('x', 2);
      p2.setValue('y', 3);
      final service.Context child = service.Context(2, p1);
      expect(child.updateParent(p2), e['updateParent']);
    });

    test('ContextKey + service values and change events', () {
      final Map<String, dynamic> e = _truth['service'] as Map<String, dynamic>;
      final testConfig.TestConfigurationService config = _config(<String, Object?>{
        'str': 'v',
        'num': 5,
        'bool': true,
        'arr': <Object?>[1, 2],
        'obj': <String, Object?>{'a': 1},
      });
      final service.ContextKeyService svc = service.ContextKeyService(config);

      final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
      final contextkey.IContextKey<String> k =
          svc.createKey<String>('myKey', 'default');
      rows.add(<String, dynamic>{'op': 'create-default', 'value': _n(k.get_())});
      k.set('one');
      rows.add(<String, dynamic>{'op': 'set', 'value': _n(k.get_())});
      k.reset();
      rows.add(<String, dynamic>{'op': 'reset', 'value': _n(k.get_())});
      svc.setContext('direct', 42);
      rows.add(<String, dynamic>{
        'op': 'setContext',
        'value': _n(svc.getContextKeyValue('direct')),
      });
      svc.removeContext('direct');
      rows.add(<String, dynamic>{
        'op': 'removeContext',
        'value': _n(svc.getContextKeyValue('direct')),
      });
      for (final String key in <String>[
        'config.str',
        'config.num',
        'config.bool',
        'config.arr',
        'config.obj',
      ]) {
        rows.add(<String, dynamic>{
          'op': key.replaceFirst('config.', 'config-'),
          'value': _n(svc.getContextKeyValue(key)),
        });
      }

      final List<Map<String, dynamic>> fired = <Map<String, dynamic>>[];
      (svc.onDidChangeContext as events.Event<contextkey.IContextKeyChangeEvent>)((dynamic ev) {
        final Map<String, dynamic> row = <String, dynamic>{};
        if (ev is service.SimpleContextKeyChangeEvent) {
          row['simple'] = ev.key;
        }
        if (ev is service.ArrayContextKeyChangeEvent) {
          row['array'] = ev.keys;
        }
        if (ev is service.CompositeContextKeyChangeEvent) {
          row['composite'] = ev.events.length;
        }
        fired.add(row);
      });
      svc.setContext('evt', 1);
      svc.setContext('evt', 1);
      svc.removeContext('evt');

      expect(rows, e['rows']);
      expect(fired, e['fired']);
      expect(svc.contextId, e['contextId']);
    });

    test('config DEFAULT change clears cached config keys', () {
      final testConfig.TestConfigurationService config =
          _config(<String, Object?>{'str': 'v'});
      final service.ContextKeyService svc = service.ContextKeyService(config);
      final List<Object?> fired = <Object?>[];
      (svc.onDidChangeContext as events.Event<contextkey.IContextKeyChangeEvent>)((dynamic e) {
        fired.add(e is service.ArrayContextKeyChangeEvent ? e.keys : e);
      });

      svc.getContextKeyValue('config.str');
      config.onDidChangeConfigurationEmitter
          .fire(_ConfigChangeEvent(configuration.ConfigurationTarget.DEFAULT));

      expect(fired, _truth['configChange']);
    });

    test('disposed service guards', () {
      final Map<String, dynamic> e = _truth['disposed'] as Map<String, dynamic>;
      final service.ContextKeyService svc = service.ContextKeyService(_config());
      svc.dispose();
      expect(_n(svc.getContextKeyValue('x')), e['getKeyValue']);
      svc.setContext('x', 1);
      expect(_n(svc.getContextKeyValue('x')), e['setNoop']);
      expect(() => svc.createKey<int>('k', 1), throwsStateError);
      expect(e['createKeyThrows'], isTrue);
    });

    test('child contexts', () {
      final Map<String, dynamic> e = _truth['child'] as Map<String, dynamic>;
      final service.ContextKeyService svc = service.ContextKeyService(_config());
      svc.setContext('shared', 1);
      final int childId = svc.createChildContext();
      expect(childId, e['childId']);
      expect(svc.getContextValuesContainer(childId).getValue('shared'),
          e['containerValue']);
      svc.disposeContext(childId);
      expect(_n(svc.getContextValuesContainer(childId).getValue('shared')),
          e['afterDispose']);
    });

    test('scoped service writes and clears context attribute', () {
      final Map<String, dynamic> e = _truth['scoped'] as Map<String, dynamic>;
      final service.ContextKeyService svc = service.ContextKeyService(_config());
      final _Target target = _Target();
      final contextkey.IScopedContextKeyService scoped =
          svc.createScoped(target);

      expect(target.attributes[service.KEYBINDING_CONTEXT_ATTR], e['attr']);
      expect((scoped as service.AbstractContextKeyService).contextId, e['contextId']);
      expect(
        _n(scoped.getContextKeyValue<dynamic>('x')),
        e['containerValue'],
      );
      scoped.dispose();
      expect(
        _n(target.attributes[service.KEYBINDING_CONTEXT_ATTR]),
        e['afterDisposeAttr'],
      );
    });

    test('overlay values shadow parent', () {
      final Map<String, dynamic> e = _truth['overlay'] as Map<String, dynamic>;
      final service.ContextKeyService svc = service.ContextKeyService(_config());
      svc.setContext('a', 1);
      final service.OverlayContextKeyService overlay =
          service.OverlayContextKeyService(svc, <List<Object?>>[
        <Object?>['a', 99],
        <Object?>['b', 2],
      ]);

      expect(overlay.getContextKeyValue('a'), e['a']);
      expect(overlay.getContextKeyValue('b'), e['b']);
      expect(overlay.contextId, e['contextId']);
      expect(overlay.contextMatchesRules(null), e['matchesTrue']);
    });

    test('module-load command registrations', () {
      service.ensureContextKeyCommandsRegistered();
      final List<Object?> ids = _truth['commands'] as List<Object?>;
      for (final Object? id in ids) {
        expect(commands.CommandsRegistry.getCommand(id as String), isNotNull,
            reason: 'missing command $id');
      }
    });
  });
}

class _ConfigChangeEvent implements configuration.IConfigurationChangeEvent {
  _ConfigChangeEvent(this.source, [Set<String>? affectedKeys])
      : affectedKeys = affectedKeys ?? <String>{};

  @override
  final int source;

  @override
  final Set<String> affectedKeys;

  @override
  configuration.IConfigurationChange get change =>
      _ConfigChange(affectedKeys.toList());

  @override
  bool affectsConfiguration(String configuration,
          [configuration.IConfigurationOverrides? overrides]) =>
      affectedKeys.contains(configuration);
}

class _ConfigChange implements configuration.IConfigurationChange {
  _ConfigChange(this.keys);

  @override
  final List<String> keys;

  @override
  List<List<Object?>> get overrides => const <List<Object?>>[];
}

class _Target implements contextkey.IContextKeyServiceTarget {
  _Target() : parentElement = null;

  @override
  contextkey.IContextKeyServiceTarget? parentElement;

  final Map<String, String> attributes = <String, String>{};

  @override
  void setAttribute(String attr, String value) => attributes[attr] = value;

  @override
  void removeAttribute(String attr) => attributes.remove(attr);

  @override
  bool hasAttribute(String attr) => attributes.containsKey(attr);

  @override
  String? getAttribute(String attr) => attributes[attr];
}
