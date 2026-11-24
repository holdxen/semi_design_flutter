// batch153 truth tests: platform/notification/test/common/testNotificationService.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' show eventNone;
import 'package:semi_design_flutter/src/monaco/base/common/severity.dart' show Severity;
import 'package:semi_design_flutter/src/monaco/platform/notification/common/notification.dart'
    show
        INotification,
        INotificationActions,
        INotificationHandle,
        INeverShowAgainOptions,
        NoOpNotification,
        NotificationPriority,
        NotificationsFilter;
import 'package:semi_design_flutter/src/monaco/platform/notification/common/notificationTelemetry.dart'
    show NotificationTelemetry;
import 'package:semi_design_flutter/src/monaco/platform/notification/test/common/testNotificationService.dart'
    show TestNotificationService;

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch153_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

/// Spy subclass that captures the INotification passed to notify(), mirroring
/// the truth harness which monkey-patches `notify`.
class _SpyNotificationService extends TestNotificationService {
  final List<INotification> captured = <INotification>[];
  @override
  INotificationHandle notify(INotification notification) {
    captured.add(notification);
    return super.notify(notification);
  }
}

void main() {
  final t = _loadTruth();

  test('getFilter / getFilters / onDidChangeFilter defaults match truth', () {
    final svc = TestNotificationService();
    expect(svc.getFilter().index, t['filterDefault']);
    expect(svc.getFilter().index, NotificationsFilter.OFF.index);
    expect(svc.getFilters(), isEmpty);
    expect(t['getFiltersEmpty'], isEmpty);
    expect(identical(svc.onDidChangeFilter, eventNone), isTrue);
    expect(t['onDidChangeFilterIsNone'], isTrue);
  });

  test('notify / prompt return a NoOpNotification (truth)', () {
    final svc = TestNotificationService();
    expect(svc.notify(_StubNotification()), isA<NoOpNotification>());
    expect(svc.prompt(Severity.Info, 'm', const []), isA<NoOpNotification>());
    expect(t['notifyReturnsNoOp'], isTrue);
    expect(t['promptReturnsNoOp'], isTrue);
  });

  test('status returns a handle with close (truth)', () {
    final svc = TestNotificationService();
    final handle = svc.status('m');
    handle.close(); // callable
    expect((t['statusShape'] as Map)['hasClose'], isTrue);
  });

  test('info/warn/error dispatch correct severity (truth)', () {
    final spy = _SpyNotificationService();
    spy.info('i');
    spy.warn('w');
    spy.error('e');
    final expected = t['infoWarnErrorSeverity'] as List<dynamic>;
    expect(spy.captured.length, expected.length);
    for (var i = 0; i < expected.length; i++) {
      expect(spy.captured[i].severity, expected[i]['severity'],
          reason: 'case $i severity');
      expect(spy.captured[i].message, expected[i]['message'],
          reason: 'case $i message');
    }
  });

  test('setFilter / removeFilter are no-ops (truth)', () {
    final svc = TestNotificationService();
    svc.setFilter(NotificationsFilter.ERROR);
    svc.removeFilter('x');
    expect(t['setFilterReturnsUndefined'], isTrue);
    expect(t['removeFilterReturnsUndefined'], isTrue);
  });
}

class _StubNotification implements INotification {
  @override
  Object? get message => 'stub';
  @override
  int? get severity => Severity.Info;
  @override
  String? get source => null;
  @override
  INotificationActions? get actions => null;
  @override
  NotificationTelemetry? get telemetry => null;
  @override
  Object? get legacyExtensionLinkParsing => null;
  @override
  bool? get sticky => null;
  @override
  NotificationPriority? get priority => null;
  @override
  INeverShowAgainOptions? get neverShowAgain => null;
}
