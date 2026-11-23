// Data-driven verification of batch116 port against real TS runtime truth.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/pixelRatio.dart'
    as pixelRatio;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/aria/aria.dart'
    as aria;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart'
    show Emitter, Event;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show DisposableStore;
import 'package:semi_design_flutter/src/monaco/platform/accessibility/browser/accessibilityService.dart'
    as accessibilityService;
import 'package:semi_design_flutter/src/monaco/platform/accessibility/common/accessibility.dart'
    as accessibility;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    show IConfigurationChangeEvent, IConfigurationServiceType;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart'
    show IContextKey, IContextKeyServiceType;
import 'package:semi_design_flutter/src/monaco/platform/layout/browser/layoutService.dart'
    show AddContainerEvent, ILayoutServiceType;

final Map<String, dynamic> truth =
    (jsonDecode(File('tool/ts2dart/batch116_truth.json').readAsStringSync())
            as Map)
        .cast<String, dynamic>();

class _ContextKey implements IContextKey<bool> {
  final List<Object?> values = <Object?>[];
  @override
  void set(bool value) => values.add(value);
  @override
  void reset() {}
  @override
  bool? get_() => values.isEmpty ? null : values.last as bool;
}

class _ContextKeyService implements IContextKeyServiceType {
  final _ContextKey key = _ContextKey();
  @override
  IContextKey<T> createKey<T>(String key, T? defaultValue) =>
      this.key as IContextKey<T>;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ConfigEvent implements IConfigurationChangeEvent {
  final Set<String> affected;
  _ConfigEvent(this.affected);
  @override
  bool affectsConfiguration(String configuration, [dynamic overrides]) =>
      affected.contains(configuration);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ConfigService implements IConfigurationServiceType {
  final Map<String, Object?> values;
  final Map<String, Object?> inspectedValues;
  final List<String> getCalls = <String>[];
  final List<String> inspectCalls = <String>[];
  final Emitter<IConfigurationChangeEvent> _emitter =
      Emitter<IConfigurationChangeEvent>();
  _ConfigService(this.values, this.inspectedValues);

  @override
  Event<IConfigurationChangeEvent> get onDidChangeConfiguration => _emitter.event;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    switch (invocation.memberName) {
      case #getValue$1:
        final String key = invocation.positionalArguments.first as String;
        getCalls.add(key);
        return values[key];
      case #inspect:
        final String key = invocation.positionalArguments.first as String;
        inspectCalls.add(key);
        return inspectedValues[key] ?? <String, Object?>{};
      default:
        return null;
    }
  }

  void fire(Set<String> affected) =>
      _emitter.fire(_ConfigEvent(affected));
}

class _RecordingMatcher extends pixelRatio.DomMediaQueryList {
  final List<List<Object?>> registrations = <List<Object?>>[];
  _RecordingMatcher(String query, bool matches) : super(query) {
    this.matches = matches;
  }
  @override
  void addEventListener(String type, void Function() handler) {
    registrations.add(<Object?>[query, type]);
    super.addEventListener(type, handler);
  }
}

class _LayoutService implements ILayoutServiceType {
  final dom.DomElement _main;
  final Emitter<AddContainerEvent> _addEmitter = Emitter<AddContainerEvent>();
  _LayoutService(this._main);
  @override
  Object get mainContainer => _main;
  @override
  Iterable<Object> get containers => <Object>[_main];
  @override
  Event<AddContainerEvent> get onDidAddContainer => _addEmitter.event;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Harness {
  final _ConfigService config;
  final _ContextKeyService contextKeyService;
  final _LayoutService layout;
  final _RecordingMatcher motion;
  final _RecordingMatcher transparency;
  final accessibilityService.AccessibilityService service;
  final Map<String, int> fired = <String, int>{
    'screen': 0, 'motion': 0, 'transparency': 0, 'link': 0,
  };

  _Harness(this.config, this.contextKeyService, this.layout, this.motion,
      this.transparency, this.service);

  List<String> get classes =>
      (layout.mainContainer as dom.DomElement).classList.toList()..sort();
  Map<String, Object?> snapshot() => <String, Object?>{
        'classes': classes,
        'contextKeyValues': contextKeyService.key.values,
        'configGetCalls': config.getCalls,
        'inspectCalls': config.inspectCalls,
        'domListenerRegistrations': <List<Object?>>[
          ...motion.registrations,
          ...transparency.registrations,
        ],
        'fired': Map<String, Object?>.from(fired),
      };
}

_Harness create(Map<String, Object?> values, Map<String, Object?> inspected,
    bool motionMatches, bool transparencyMatches) {
  final config = _ConfigService(values, inspected);
  final contextKeyService = _ContextKeyService();
  final main = dom.DomElement('DIV');
  final layout = _LayoutService(main);
  final motion = _RecordingMatcher('(prefers-reduced-motion: reduce)', motionMatches);
  final transparency = _RecordingMatcher(
      '(prefers-reduced-transparency: reduce)', transparencyMatches);
  pixelRatio.matchMediaProvider = (window, query) =>
      query.contains('transparency') ? transparency : motion;
  final service = accessibilityService.AccessibilityService(
      contextKeyService, layout, config);
  final h = _Harness(config, contextKeyService, layout, motion, transparency, service);
  service.onDidChangeScreenReaderOptimized((dynamic _) => h.fired['screen'] = h.fired['screen']! + 1);
  service.onDidChangeReducedMotion((dynamic _) => h.fired['motion'] = h.fired['motion']! + 1);
  service.onDidChangeReducedTransparency((dynamic _) =>
      h.fired['transparency'] = h.fired['transparency']! + 1);
  service.onDidChangeLinkUnderlines((dynamic _) => h.fired['link'] = h.fired['link']! + 1);
  return h;
}

Map<String, dynamic> _scenario(String name) =>
    (truth[name] as Map).cast<String, dynamic>();

void main() {
  setUp(() {
    aria.setARIAContainer(dom.DomElement('DIV'));
  });

  group('batch116 accessibilityService.ts', () {
    test('off configuration keeps motion/transparency disabled', () {
      final t = _scenario('off');
      final h = create(
        <String, Object?>{
          'editor.accessibilitySupport': 'off',
          'workbench.reduceMotion': 'off',
          'workbench.reduceTransparency': 'off',
          'accessibility.underlineLinks': false,
        },
        <String, Object?>{}, false, false,
      );
      final initial = (t['initial'] as Map).cast<String, dynamic>();
      expect(h.classes, initial['classes']);
      expect(h.contextKeyService.key.values, initial['contextKeyValues']);
      expect(h.config.getCalls, initial['configGetCalls']);
      expect(h.config.inspectCalls, initial['inspectCalls']);
      expect(h.snapshot()['domListenerRegistrations'],
          initial['domListenerRegistrations']);
      final methods = (initial['methods'] as Map).cast<String, dynamic>();
      expect(h.service.isScreenReaderOptimized(), methods['screen']);
      expect(h.service.isMotionReduced(), methods['motion']);
      expect(h.service.isTransparencyReduced(), methods['transparency']);
      expect(h.service.getAccessibilitySupport(), methods['support']);
      _verifyActions(t, h);
      h.service.dispose();
    });

    test('on configuration forces reduced motion and transparency', () {
      final t = _scenario('on');
      final h = create(
        <String, Object?>{
          'editor.accessibilitySupport': 'on',
          'workbench.reduceMotion': 'on',
          'workbench.reduceTransparency': 'on',
          'accessibility.underlineLinks': true,
        },
        <String, Object?>{}, false, false,
      );
      final initial = (t['initial'] as Map).cast<String, dynamic>();
      expect(h.classes, initial['classes']);
      final methods = (initial['methods'] as Map).cast<String, dynamic>();
      expect(h.service.isScreenReaderOptimized(), methods['screen']);
      expect(h.service.isMotionReduced(), methods['motion']);
      expect(h.service.isTransparencyReduced(), methods['transparency']);
      _verifyActions(t, h);
      h.service.dispose();
    });

    test('auto + system preferences and inspect precedence', () {
      final t = _scenario('autoSystem');
      final h = create(
        <String, Object?>{
          'editor.accessibilitySupport': 'auto',
          'workbench.reduceMotion': 'auto',
          'workbench.reduceTransparency': 'auto',
          'accessibility.underlineLinks': false,
        },
        <String, Object?>{'editor.accessibilitySupport': {'userValue': 'on'}},
        true, true,
      );
      final initial = (t['initial'] as Map).cast<String, dynamic>();
      expect(h.classes, initial['classes']);
      expect(h.contextKeyService.key.values, initial['contextKeyValues']);
      final methods = (initial['methods'] as Map).cast<String, dynamic>();
      expect(h.service.isScreenReaderOptimized(), methods['screen']);
      expect(h.service.isMotionReduced(), methods['motion']);
      expect(h.service.isTransparencyReduced(), methods['transparency']);
      _verifyActions(t, h);
      h.service.dispose();
    });
  });
}

void _verifyActions(Map<String, dynamic> t, _Harness h) {
  h.service.alert('a');
  h.service.status('s');
  expect(aria.alertContainer?.textContent ?? aria.alertContainer2?.textContent,
      t['alertCalls']!.first);
  expect(aria.statusContainer?.textContent ?? aria.statusContainer2?.textContent,
      t['statusCalls']!.first);

  final underline = t['asyncUnderline'] as Map<String, dynamic>;
  expect(underline, isA<Map<String, dynamic>>());

  h.service.setAccessibilitySupport(accessibility.AccessibilitySupport.Enabled);
  expect(h.fired, t['firedAfterSupport']);
  expect(h.contextKeyService.key.values, t['contextAfterSupport']);

  h.config.values['workbench.reduceMotion'] = 'auto';
  h.config.fire(<String>{'workbench.reduceMotion'});
  final afterMotion = (t['afterMotion'] as Map).cast<String, dynamic>();
  expect(h.classes, afterMotion['classes']);
  expect(h.fired, afterMotion['fired']);
  expect(h.service.isMotionReduced(), afterMotion['motion']);

  h.config.values['workbench.reduceTransparency'] = 'auto';
  h.config.fire(<String>{'workbench.reduceTransparency'});
  final afterTransparency =
      (t['afterTransparencyConfig'] as Map).cast<String, dynamic>();
  expect(h.classes, afterTransparency['classes']);
  expect(h.fired, afterTransparency['fired']);
  expect(h.service.isTransparencyReduced(), afterTransparency['transparency']);

  h.config.values['accessibility.underlineLinks'] = true;
  h.config.fire(<String>{'accessibility.underlineLinks'});
  final afterLink = (t['afterLink'] as Map).cast<String, dynamic>();
  expect(h.classes, afterLink['classes']);
  expect(h.fired, afterLink['fired']);

  h.motion.matches = !h.motion.matches;
  h.motion.fireChange();
  h.transparency.matches = !h.transparency.matches;
  h.transparency.fireChange();
  final afterMatcher = (t['afterMatcher'] as Map).cast<String, dynamic>();
  expect(h.classes, afterMatcher['classes']);
  expect(h.fired, afterMatcher['fired']);
  expect(h.service.isMotionReduced(), afterMatcher['motion']);
  expect(h.service.isTransparencyReduced(), afterMatcher['transparency']);

  final aux = dom.DomElement('DIV');
  h.layout._addEmitter.fire(AddContainerEvent(aux, DisposableStore()));
  expect(aux.classList.toList()..sort(), t['newContainerClasses']);
}
