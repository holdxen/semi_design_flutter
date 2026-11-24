// batch152 truth tests: platform/notification/common/notification.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/severity.dart' show Severity;
import 'package:semi_design_flutter/src/monaco/platform/notification/common/notification.dart' as n;

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch152_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  final t = _loadTruth();
  final enums = t['enums'] as Map<String, dynamic>;

  test('numeric enums match truth', () {
    final pri = enums['NotificationPriority'] as Map<String, dynamic>;
    expect(n.NotificationPriority.DEFAULT.index, pri['DEFAULT']);
    expect(n.NotificationPriority.OPTIONAL.index, pri['OPTIONAL']);
    expect(n.NotificationPriority.SILENT.index, pri['SILENT']);
    expect(n.NotificationPriority.URGENT.index, pri['URGENT']);

    final scope = enums['NeverShowAgainScope'] as Map<String, dynamic>;
    expect(n.NeverShowAgainScope.WORKSPACE.index, scope['WORKSPACE']);
    expect(n.NeverShowAgainScope.PROFILE.index, scope['PROFILE']);
    expect(n.NeverShowAgainScope.APPLICATION.index, scope['APPLICATION']);

    final filter = enums['NotificationsFilter'] as Map<String, dynamic>;
    expect(n.NotificationsFilter.OFF.index, filter['OFF']);
    expect(n.NotificationsFilter.ERROR.index, filter['ERROR']);
  });

  test('INotificationService serviceId matches truth', () {
    expect(n.INotificationService.serviceId, t['serviceId']);
  });

  test('isNotificationSource matches truth', () {
    final cases = t['isNotificationSource'] as List<dynamic>;
    for (final c in cases) {
      final i = c['i'] as int;
      expect(n.isNotificationSource(_sourceInputs[i]), c['result'],
          reason: 'isNotificationSource case $i (${c['val']})');
    }
  });

  test('withSeverityPrefix matches truth', () {
    final p = t['withSeverityPrefix'] as Map<String, dynamic>;
    expect(n.withSeverityPrefix('oops', Severity.Error), p['error']);
    expect(n.withSeverityPrefix('oops', Severity.Warning), p['warning']);
    expect(n.withSeverityPrefix('oops', Severity.Info), p['info']);
    expect(n.withSeverityPrefix('oops', Severity.Ignore), p['ignore']);
  });

  test('NoOpNotification / NoOpProgress behavior matches truth', () {
    final noop = t['noop'] as Map<String, dynamic>;
    final notification = n.NoOpNotification();
    final progress = notification.progress;

    expect(progress, isA<n.NoOpProgress>(), reason: 'progress is NoOpProgress');
    expect(noop['progressIsNoOp'], isTrue);

    // methods are present and callable (TS void -> Dart void). Calling them
    // as statements verifies they exist and don't throw.
    notification.updateSeverity(Severity.Error);
    notification.updateMessage('x');
    notification.updateActions(null);
    notification.close();
    progress.infinite();
    progress.done();
    progress.total(5);
    progress.worked(5);

    expect(noop['closeReturnsUndefined'], isTrue);
    expect(noop['updateSeverityReturnsUndefined'], isTrue);
    expect(noop['infiniteReturnsUndefined'], isTrue);
    expect(noop['doneReturnsUndefined'], isTrue);
    expect(noop['totalReturnsUndefined'], isTrue);
    expect(noop['workedReturnsUndefined'], isTrue);
    expect((noop['notificationMethods'] as List).length, 4);
    expect((noop['progressMethods'] as List).length, 4);
  });
}

final List<Object?> _sourceInputs = <Object?>[
  null,
  null,
  1,
  'x',
  <String, Object?>{},
  <String, Object?>{'id': 'a'},
  <String, Object?>{'label': 'b'},
  <String, Object?>{'id': 'a', 'label': 'b'},
  <String, Object?>{'id': 1, 'label': 'b'},
  <String, Object?>{'id': 'a', 'label': 1},
  <String, Object?>{'id': '', 'label': ''},
];
