// batch59: accessibility.ts + telemetry.ts
// All assertions are data-driven from svcplatform_truth.json (Node TS real eval).
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/accessibility/common/accessibility.dart';
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/telemetry.dart';

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/svcplatform_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

/// Decode truth sentinels for null/undefined into Dart null.
Object? _dec(Object? v) =>
    (v == '__undefined__' || v == '__null__') ? null : v;

class _LevelService implements ITelemetryServiceType {
  final int level;
  _LevelService(this.level);
  // ignore: unused_element
  Object? get _serviceBrand => null;
  @override int get telemetryLevel => level;
  @override String get sessionId => '';
  @override String get machineId => '';
  @override String get sqmId => '';
  @override String get devDeviceId => '';
  @override String get firstSessionDate => '';
  @override bool? get msftInternal => null;
  @override bool get sendErrorTelemetry => false;
  @override void publicLog(String e, [Object? d]) {}
  @override void publicLog2(String e, [Object? d]) {}
  @override void publicLogError(String e, [Object? d]) {}
  @override void publicLogError2(String e, [Object? d]) {}
  @override void setExperimentProperty(String n, String v) {}
  @override void setCommonProperty(String n, Object? v) {}
}

void main() {
  final truth = _truth();

  test('b59 accessibility: decorator id, enums, constants match truth', () {
    final a = truth['accessibility'] as Map<String, dynamic>;
    expect(IAccessibilityService.toString(), a['IAccessibilityService_id']);
    final e = a['AccessibilitySupport'] as Map<String, dynamic>;
    expect(AccessibilitySupport.Unknown, e['Unknown']);
    expect(AccessibilitySupport.Disabled, e['Disabled']);
    expect(AccessibilitySupport.Enabled, e['Enabled']);
    final ctx = a['CONTEXT_ACCESSIBILITY_MODE_ENABLED'] as Map<String, dynamic>;
    expect(CONTEXT_ACCESSIBILITY_MODE_ENABLED.key, ctx['key']);
    expect(CONTEXT_ACCESSIBILITY_MODE_ENABLED.serialize(), ctx['key']);
    expect(ACCESSIBLE_VIEW_SHOWN_STORAGE_PREFIX,
        a['ACCESSIBLE_VIEW_SHOWN_STORAGE_PREFIX']);
  });

  test('b59 isAccessibilityInformation: all 12 cases match truth', () {
    final a = truth['accessibility'] as Map<String, dynamic>;
    final cases = (a['isAccessibilityInformation_cases'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final c in cases) {
      final input = _dec(c['input']);
      final result = isAccessibilityInformation(input);
      expect(result, c['result'], reason: 'isAccessibilityInformation($input)');
    }
    expect(cases.length, 12);
  });

  test('b59 telemetry: decorator ids, enums, constants match truth', () {
    final t = truth['telemetry'] as Map<String, dynamic>;
    expect(ITelemetryService.toString(), t['ITelemetryService_id']);
    expect(ICustomEndpointTelemetryService.toString(),
        t['ICustomEndpointTelemetryService_id']);
    final lv = t['TelemetryLevel'] as Map<String, dynamic>;
    expect(TelemetryLevel.NONE, lv['NONE']);
    expect(TelemetryLevel.CRASH, lv['CRASH']);
    expect(TelemetryLevel.ERROR, lv['ERROR']);
    expect(TelemetryLevel.USAGE, lv['USAGE']);
    final cf = t['TelemetryConfiguration'] as Map<String, dynamic>;
    expect(TelemetryConfiguration.OFF, cf['OFF']);
    expect(TelemetryConfiguration.CRASH, cf['CRASH']);
    expect(TelemetryConfiguration.ERROR, cf['ERROR']);
    expect(TelemetryConfiguration.ON, cf['ON']);
    final c = t['constants'] as Map<String, dynamic>;
    expect(MODEL_ROUTER_TELEMETRY_ID, c['MODEL_ROUTER_TELEMETRY_ID']);
    expect(currentSessionDateStorageKey, c['currentSessionDateStorageKey']);
    expect(firstSessionDateStorageKey, c['firstSessionDateStorageKey']);
    expect(lastSessionDateStorageKey, c['lastSessionDateStorageKey']);
    expect(machineIdKey, c['machineIdKey']);
    expect(sqmIdKey, c['sqmIdKey']);
    expect(devDeviceIdKey, c['devDeviceIdKey']);
    expect(TELEMETRY_SECTION_ID, c['TELEMETRY_SECTION_ID']);
    expect(TELEMETRY_SETTING_ID, c['TELEMETRY_SETTING_ID']);
    expect(TELEMETRY_CRASH_REPORTER_SETTING_ID,
        c['TELEMETRY_CRASH_REPORTER_SETTING_ID']);
    expect(TELEMETRY_OLD_SETTING_ID, c['TELEMETRY_OLD_SETTING_ID']);
  });

  test('b59 telemetryLevelEnabled: all 8 cases match truth', () {
    final t = truth['telemetry'] as Map<String, dynamic>;
    final cases = (t['telemetryLevelEnabled_cases'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final c in cases) {
      final level = c['level'] as int;
      final cmp = c['cmp'] as int;
      expect(telemetryLevelEnabled(_LevelService(level), cmp), c['result'],
          reason: 'telemetryLevelEnabled($level, $cmp)');
    }
    expect(cases.length, 8);
  });

  test('b59 normalizeModelRouterTelemetryId: all 10 cases match truth', () {
    final t = truth['telemetry'] as Map<String, dynamic>;
    final cases = (t['normalizeModelRouterTelemetryId_cases'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final c in cases) {
      final result = normalizeModelRouterTelemetryId(_dec(c['input']));
      expect(_dec(result), _dec(c['result']),
          reason: 'normalizeModelRouterTelemetryId(${c['input']})');
    }
    expect(cases.length, 10);
  });

  test('b59 escapeModelIdForTelemetry: all 9 cases match truth', () {
    final t = truth['telemetry'] as Map<String, dynamic>;
    final cases = (t['escapeModelIdForTelemetry_cases'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final c in cases) {
      final result = escapeModelIdForTelemetry(_dec(c['input']));
      expect(result, _dec(c['result']),
          reason: 'escapeModelIdForTelemetry(${c['input']})');
    }
    expect(cases.length, 9);
  });
}
