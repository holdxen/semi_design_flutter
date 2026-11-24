// batch151 truth tests: platform/notification/common/notificationTelemetry.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/actions.dart' show IAction;
import 'package:semi_design_flutter/src/monaco/platform/notification/common/notificationTelemetry.dart' as nt;

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch151_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

/// Minimal IAction stub (identity is what matters for the telemetry WeakMap).
class _Action implements IAction {
  const _Action(this.id);
  @override
  final String id;
  @override
  String get label => id;
  @override
  String get tooltip => id;
  @override
  String? get cssClass => null;
  @override
  bool get enabled => true;
  @override
  bool? get checked => null;
  @override
  IAction? get alt => null;
  @override
  Never run([Object? event, Object? data]) => throw UnimplementedError();
}

void main() {
  final t = _loadTruth();
  final enums = t['enums'] as Map<String, dynamic>;

  test('NotificationTelemetryId values match truth', () {
    final m = enums['NotificationTelemetryId'] as Map<String, dynamic>;
    for (final e in nt.NotificationTelemetryId.values) {
      expect(e.name, isIn(m.keys), reason: '${e.name} present in truth');
      expect(e.value, m[e.name], reason: '${e.name} value');
    }
    expect(nt.NotificationTelemetryId.values.length, m.length);
  });

  test('NotificationActionTelemetryId values match truth', () {
    final m = enums['NotificationActionTelemetryId'] as Map<String, dynamic>;
    for (final e in nt.NotificationActionTelemetryId.values) {
      expect(e.value, m[e.name], reason: '${e.name} value');
    }
    expect(nt.NotificationActionTelemetryId.values.length, m.length);
  });

  test('ExtensionNotificationTelemetryId values match truth', () {
    final m = enums['ExtensionNotificationTelemetryId'] as Map<String, dynamic>;
    for (final e in nt.ExtensionNotificationTelemetryId.values) {
      expect(e.value, m[e.name], reason: '${e.name} value');
    }
    expect(nt.ExtensionNotificationTelemetryId.values.length, m.length);
  });

  test('extensionNotificationTelemetry sources match truth', () {
    final cases = t['extensionTelemetry'] as List<dynamic>;
    for (final c in cases) {
      final i = c['i'] as int;
      final args = _extArgs[i];
      final tel = nt.extensionNotificationTelemetry(
          args[0] as String?, args[1] as String, args[2] as String?);
      expect((tel as nt.IExtensionNotificationTelemetry).branded, c['hasBrand'],
          reason: 'case $i branded');
      final src = nt.getNotificationTelemetrySource(tel);
      final expected = c['source'] as Map<String, dynamic>;
      expect(src.origin, expected['origin'], reason: 'case $i origin');
      expect(src.notificationId, expected['notificationId'], reason: 'case $i notificationId');
      expect(src.extensionId, expected['extensionId'], reason: 'case $i extensionId');
    }
  });

  test('extension notification IDs map covers all audited IDs (truth)', () {
    final cov = t['mapCoverage'] as List<dynamic>;
    for (final c in cov) {
      final g = c['g'] as int;
      final i = c['i'] as int;
      final id = c['id'] as String;
      final args = _mapGroups[g];
      final tel = nt.extensionNotificationTelemetry(args[0], args[1], id);
      final src = nt.getNotificationTelemetrySource(tel);
      expect(src.notificationId, c['notificationId'], reason: 'group $g id $i');
      expect(src.origin, c['origin'], reason: 'group $g id $i origin');
      expect(src.extensionId, c['extensionId'], reason: 'group $g id $i extId');
    }
  });

  test('getNotificationTelemetrySource for core / unknown matches truth', () {
    final cases = t['telemetrySource'] as List<dynamic>;
    for (final c in cases) {
      final i = c['i'] as int;
      final input = _srcInputs[i];
      final src = nt.getNotificationTelemetrySource(input);
      final expected = c['source'] as Map<String, dynamic>;
      expect(src.origin, expected['origin'], reason: 'src case $i origin');
      expect(src.notificationId, expected['notificationId'], reason: 'src case $i notificationId');
      expect(src.extensionId, expected['extensionId'], reason: 'src case $i extensionId');
    }
  });

  test('withNotificationActionTelemetry / get match truth', () {
    final cases = t['actionTelemetry'] as List<dynamic>;
    for (final c in cases) {
      final i = c['i'] as int;
      final action = _Action('a$i');
      final tel = _actionInputs[i];
      final ret = nt.withNotificationActionTelemetry(action, tel);
      expect(identical(ret, action), c['sameAction'], reason: 'case $i same action');
      final got = nt.getNotificationActionTelemetry(action);
      Object? serialized;
      if (got is String) {
        serialized = got;
      } else if (got is Map) {
        serialized = <String, Object?>{'extensionButtonIndex': got['extensionButtonIndex']};
      }
      final expected = c['got'];
      if (expected == null) {
        expect(got, isNull, reason: 'case $i expected no telemetry');
      } else if (expected is String) {
        expect(serialized, expected, reason: 'case $i string telemetry');
      } else {
        expect(serialized, expected is Map
            ? <String, Object?>{'extensionButtonIndex': (expected as Map)['extensionButtonIndex']}
            : expected, reason: 'case $i button telemetry');
      }
    }
  });

  test('fresh action returns undefined telemetry (truth)', () {
    final fresh = _Action('fresh');
    expect(nt.getNotificationActionTelemetry(fresh), isNull);
    expect(t['actionGet'][0]['fresh'], 'undef');
  });
}

// Mirrors harness extCases order exactly.
final List<List<Object?>> _extArgs = <List<Object?>>[
  <Object?>[null, 'message', null],
  <Object?>['', 'message', null],
  <Object?>['vscode.github-authentication', 'message', 'githubAuthentication.signIn.failed'],
  <Object?>['vscode.github-authentication', 'progress', 'githubAuthentication.signIn.browser'],
  <Object?>['vscode.github-authentication', 'message', 'unknown.id'],
  <Object?>['vscode.git', 'message', 'git.missing'],
  <Object?>['vscode.git', 'progress', null],
  <Object?>['VSCODE.GIT', 'message', 'git.missing'],
  <Object?>['pub.ext', 'message', null],
  <Object?>['a' * 256, 'message', null],
  <Object?>['a' * 255, 'message', null],
  <Object?>['no_dot', 'message', null],
  <Object?>['a.b-c.d', 'message', null],
];

// Mirrors allExtCases order: [extensionId, kind] per group.
const List<List<String>> _mapGroups = <List<String>>[
  <String>['vscode.github-authentication', 'message'],
  <String>['vscode.github-authentication', 'progress'],
  <String>['vscode.git', 'message'],
  <String>['vscode.typescript-language-features', 'message'],
];

// Mirrors telemetrySource inputs (TS string enum values are plain strings).
final List<Object?> _srcInputs = <Object?>[
  nt.NotificationTelemetryId.ExtensionInstall.value,
  nt.NotificationTelemetryId.AgentHostProgress.value,
  nt.NotificationActionTelemetryId.Copy.value,
  'bogus',
  null,
  null,
];

// Mirrors actionCases telemetry inputs. `null` here means undefined.
final List<Object?> _actionInputs = <Object?>[
  nt.NotificationActionTelemetryId.Copy.value,
  nt.NotificationActionTelemetryId.Reload.value,
  'bogus',
  <String, Object?>{'extensionButtonIndex': 0},
  <String, Object?>{'extensionButtonIndex': 1000},
  <String, Object?>{'extensionButtonIndex': 1001},
  <String, Object?>{'extensionButtonIndex': -1},
  <String, Object?>{'extensionButtonIndex': 1.5},
  <String, Object?>{'extensionButtonIndex': double.nan},
  null,
];
