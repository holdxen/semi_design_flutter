// Data-driven verification of batch110 port against real TS runtime truth.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart'
    show DomDocument, DomElement, DomEvent, EventType, ModifierKeyEmitter;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show DisposableStore;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/descriptors.dart'
    show SyncDescriptor;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/extensions.dart'
    show InstantiationType, getSingletonServiceDescriptors;
import 'package:semi_design_flutter/src/monaco/platform/userInteraction/browser/userInteractionServiceImpl.dart'
    as impl;


Map<String, Object?> _statusJson(Object s) {
  final dynamic d = s;
  return <String, Object?>{
    'ctrlKey': d.ctrlKey,
    'shiftKey': d.shiftKey,
    'altKey': d.altKey,
    'metaKey': d.metaKey,
  };
}

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch110_truth.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('UserInteractionService (truth-driven)', () {
    test('readModifierKeyStatus caches per window & reads live status', () {
      final Map<String, dynamic> t =
          (truth['readModifierKeyStatus'] as Map<String, dynamic>);
      final svc = impl.UserInteractionService();
      final emitter = ModifierKeyEmitter.getInstance();

      // fresh status
      emitter.resetKeyStatus();
      final doc = DomDocument();
      final el = doc.createElement('div');
      final statusA1 = svc.readModifierKeyStatus(el, null);
      expect(_statusJson(statusA1), t['initial'] as Map<String, dynamic>);

      emitter.keyStatus.ctrlKey = true;
      final statusA2 = svc.readModifierKeyStatus(el, null);
      expect(_statusJson(statusA2), t['afterCtrl'] as Map<String, dynamic>);

      emitter.keyStatus.shiftKey = true;
      final statusA3 = svc.readModifierKeyStatus(el, null);
      expect(_statusJson(statusA3), t['afterShift'] as Map<String, dynamic>);
    });

    test('createFocusTracker initial + focus/blur via DOM events', () async {
      final Map<String, dynamic> t =
          (truth['focusTracker'] as Map<String, dynamic>);
      final svc = impl.UserInteractionService();
      final doc = DomDocument();
      final el = doc.createElement('div');
      doc.appendChild(el);
      doc.activeElement = el; // initial focus within => true
      final store = DisposableStore();

      final obs = svc.createFocusTracker(el, store);
      expect(obs.read(null), t['initial']);

      // blur then focus transitions
      doc.activeElement = null;
      el.dispatchEvent(EventType.BLUR, DomEvent(EventType.BLUR, target: el));
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(obs.read(null), t['afterBlur']);

      doc.activeElement = el;
      el.dispatchEvent(EventType.FOCUS, DomEvent(EventType.FOCUS, target: el));
      expect(obs.read(null), t['afterFocus']);
    });

    test('createHoverTracker via mouseenter/mouseleave', () {
      final Map<String, dynamic> t =
          (truth['hoverTracker'] as Map<String, dynamic>);
      final svc = impl.UserInteractionService();
      final doc = DomDocument();
      final el = doc.createElement('div');
      final store = DisposableStore();

      final obs = svc.createHoverTracker(el, store);
      expect(obs.read(null), t['initial']);

      el.dispatchEvent('mouseenter', DomEvent('mouseenter', target: el));
      expect(obs.read(null), t['afterEnter']);

      el.dispatchEvent('mouseleave', DomEvent('mouseleave', target: el));
      expect(obs.read(null), t['afterLeave']);
    });

    test('createDomFocusTracker delegates to trackFocus', () {
      expect(truth['domTrackerDelegates'], isTrue);
      final svc = impl.UserInteractionService();
      final doc = DomDocument();
      final el = doc.createElement('div');
      final tracker = svc.createDomFocusTracker(el);
      expect(tracker, isNotNull);
    });

    test('registerSingleton side effect', () {
      final Map<String, dynamic> t =
          (truth['registerSingleton'] as List<dynamic>).first as Map<String, dynamic>;
      // Touch the lazy top-level registration initializer.
      expect(impl.registration, isNotNull);
      final descriptors = getSingletonServiceDescriptors();
      final found = descriptors.where((List<Object?> d) {
        final Object? descriptor = d[1];
        return descriptor is SyncDescriptor &&
            descriptor.ctor == impl.UserInteractionService.new;
      }).toList();
      expect(found, isNotEmpty);
      expect((found.first[1] as SyncDescriptor).supportsDelayedInstantiation,
          isTrue);
      expect(t['type'], InstantiationType.Delayed);
    });
  });
}
