// Truth-driven tests for batch136:
// platform/telemetry/common/telemetryUtils.ts
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/telemetry.dart'
    as telemetry;
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/telemetryUtils.dart'
    as t;

final Map<String, Object?> _truth =
    jsonDecode(File('tool/ts2dart/batch136_truth.json').readAsStringSync())
        as Map<String, Object?>;

List<Object?> _list(Object? value) => (value as List).cast<Object?>();

Map<String, Object?> _obj(Object? value) =>
    (value as Map).cast<String, Object?>();

t.TelemetryProductInfo _prod(bool? enable,
        [String? key, List<String> domains = const <String>[]]) =>
    t.TelemetryProductInfo(
        enableTelemetry: enable, ariaKey: key, msftInternalDomains: domains);

t.TelemetryEnvironmentInfo _env(bool built, bool disable, [Object? loc]) =>
    t.TelemetryEnvironmentInfo(
        isBuilt: built, disableTelemetry: disable, extensionTestsLocationURI: loc);

t.TelemetryConfigReader _config(Map<String, Object?> values) =>
    t.TelemetryConfigReader((String key) => values[key]);

void main() {
  final List<Object?> supports = _list(_truth['supportsTelemetry']);
  final List<Object?> logging = _list(_truth['isLoggingOnly']);

  test('TelemetryTrustedValue', () {
    final Map<String, Object?> e = _obj(_truth['trust']);
    final t.TelemetryTrustedValue<String> v =
        t.TelemetryTrustedValue<String>('safe');
    expect(v.isTrustedTelemetryValue, e['isTrusted']);
    expect(v.value, e['value']);
  });

  test('NullTelemetryService / NullEndpointTelemetryService', () {
    final Map<String, Object?> e = _obj(_truth['nullService']);
    final t.NullTelemetryServiceShape s = t.NullTelemetryService;
    expect(s.telemetryLevel, e['level']);
    expect(s.sessionId, e['sessionId']);
    expect(s.machineId, e['machineId']);
    expect(s.sqmId, e['sqmId']);
    expect(s.devDeviceId, e['devDeviceId']);
    expect(s.firstSessionDate, e['firstSessionDate']);
    expect(s.sendErrorTelemetry, e['sendErrorTelemetry']);
    expect(_obj(_truth['nullEndpoint']), isEmpty);
  });

  test('constants and NullAppender', () {
    final Map<String, Object?> e = _obj(_truth['consts']);
    expect(t.telemetryLogId, e['telemetryLogId']);
    expect(t.TelemetryLogGroup.id, _obj(e['group'])['id']);
    expect(t.TelemetryLogGroup.name, _obj(e['group'])['name']);
    t.NullAppender.log('x', <String, Object?>{});
    expect(e['nullAppenderLog'], isNull);
  });

  test('supportsTelemetry matrix', () {
    final List<t.TelemetryProductInfo> products = <t.TelemetryProductInfo>[
      _prod(true), _prod(false), _prod(true), _prod(true), _prod(true),
    ];
    final List<t.TelemetryEnvironmentInfo> envs =
        <t.TelemetryEnvironmentInfo>[
      _env(false, false),
      _env(false, false),
      _env(true, false),
      _env(true, true),
      _env(false, true),
    ];
    for (int i = 0; i < supports.length; i++) {
      expect(t.supportsTelemetry(products[i], envs[i]), supports[i],
          reason: 'supportsTelemetry case $i');
    }
  });

  test('isLoggingOnly matrix', () {
    final List<t.TelemetryProductInfo> products = <t.TelemetryProductInfo>[
      _prod(true, 'key'),
      _prod(false),
      _prod(true, 'key'),
      _prod(false),
      _prod(true, 'key'),
      _prod(true),
    ];
    final List<t.TelemetryEnvironmentInfo> envs =
        <t.TelemetryEnvironmentInfo>[
      _env(false, false),
      _env(false, false),
      _env(true, false),
      _env(false, true),
      _env(false, false, 'loc'),
      _env(false, false, 'loc'),
    ];
    for (int i = 0; i < logging.length; i++) {
      expect(t.isLoggingOnly(products[i], envs[i]), logging[i],
          reason: 'isLoggingOnly case $i');
    }
  });

  test('getTelemetryLevel matrix', () {
    final List<Map<String, Object?>> configs = <Map<String, Object?>>[
      <String, Object?>{telemetry.TELEMETRY_SETTING_ID: 'all'},
      <String, Object?>{telemetry.TELEMETRY_SETTING_ID: 'error'},
      <String, Object?>{telemetry.TELEMETRY_SETTING_ID: 'crash'},
      <String, Object?>{telemetry.TELEMETRY_SETTING_ID: 'off'},
      <String, Object?>{},
      <String, Object?>{
        telemetry.TELEMETRY_SETTING_ID: 'all',
        telemetry.TELEMETRY_CRASH_REPORTER_SETTING_ID: false,
      },
      <String, Object?>{
        telemetry.TELEMETRY_SETTING_ID: 'all',
        telemetry.TELEMETRY_OLD_SETTING_ID: false,
      },
      <String, Object?>{telemetry.TELEMETRY_SETTING_ID: 'bogus'},
    ];
    final List<Object?> levels = _list(_truth['telemetryLevel']);
    for (int i = 0; i < configs.length; i++) {
      expect(t.getTelemetryLevel(_config(configs[i])), levels[i],
          reason: 'level case $i');
    }
  });

  test('validateTelemetryData', () {
    final List<String> warnings = <String>[];
    t.consoleWarnProvider = (Object message) => warnings.add(message.toString());
    final Object? data = <String, Object?>{
      'a': 1,
      'b': true,
      'c': 'x',
      'nil': null,
      'arr': <int>[1, 2],
      'nested': <String, Object?>{
        'deep': <String, Object?>{
          'deeper': <String, Object?>{'x': 'y'},
        },
      },
      'date': DateTime.utc(2020, 1, 2, 3, 4, 5),
      'longKey': <String, Object?>{'k' * 160: 'v'},
      'longString': 'z' * 8200,
    };
    final Map<String, Object?> result = t.validateTelemetryData(data);
    final Map<String, Object?> expected = _obj(_truth['validate']);
    expect(_obj(result['properties']), _obj(expected['properties']));
    expect(_obj(result['measurements']), _obj(expected['measurements']));
    expect(warnings, _list(_truth['validateWarnings']));
  });

  test('cleanRemoteAuthority', () {
    final t.RemoteAuthoringConfig config = t.RemoteAuthoringConfig(
      remoteExtensionTips: <String, Object?>{'ssh': <String, Object?>{}},
      virtualWorkspaceExtensionTips: <String, Object?>{
        'vscode_vsp': <String, Object?>{},
      },
    );
    expect(
      <Object?>[
        t.cleanRemoteAuthority(null, config),
        t.cleanRemoteAuthority('ssh+remote', config),
        t.cleanRemoteAuthority('vscode_vsp+remote', config),
        t.cleanRemoteAuthority('unknown+remote', config),
      ],
      _list(_truth['cleanAuthority']),
    );
  });

  test('isInternalTelemetry', () {
    t.userDnsDomainProvider = () => null;
    expect(t.isInternalTelemetry(_prod(false),
        _config(<String, Object?>{'telemetry.internalTesting': true})),
        _truth['internalOne']);
    t.userDnsDomainProvider = () => 'CORP';
    expect(t.isInternalTelemetry(_prod(false, null, <String>['corp']),
        _config(<String, Object?>{})),
        _truth['internalDomain']);
    t.userDnsDomainProvider = () => null;
  });

  test('PII paths from environment', () {
    final t.IPathEnvironment paths = t.IPathEnvironment(
      appRoot: '/app',
      extensionsPath: '/ext',
      userDataPath: '/data',
      userHome: uri.URI.file('/home'),
      tmpDir: uri.URI.file('/tmp'),
    );
    expect(t.getPiiPathsFromEnvironment(paths), _list(_truth['piiPaths']));
    expect(t.getUserContentPathsFromEnvironment(paths),
        _list(_truth['userContentPaths']));
  });

  test('cleanData', () {
    final List<t.TelemetryPattern> patterns = <t.TelemetryPattern>[
      t.TelemetryPattern(RegExp(r'Users/test/workspace/')),
      t.TelemetryPattern(RegExp(r'C:\\\\home\\\\')),
    ];
    final List<Object?> inputs = <Object?>[
      <String, Object?>{'p': '/Users/test/workspace/file.txt'},
      <String, Object?>{'p': r'C:\home\secret'},
      <String, Object?>{'p': 'https://example.com/a'},
      <String, Object?>{'p': 'AIza' + 'A' * 21},
      <String, Object?>{'p': 'OneDrive - Contoso/Users/test/workspace/x'},
      <String, Object?>{'p': '/home/user/node_modules/pkg/lib/a.js'},
      <String, Object?>{'p': 'C:/Users/u/.vscode/extensions/ext/a.js'},
      <String, Object?>{'p': 'token=abc'},
      <String, Object?>{'p': 'line1\ngetStorageKey\nline3'},
      <String, Object?>{'p': t.TelemetryTrustedValue<String>('/keep/me')},
      <String, Object?>{'p': 'a%20b'},
    ];
    final List<Object?> expected = _list(_truth['clean']);
    for (int i = 0; i < inputs.length; i++) {
      expect(_obj(t.cleanData(inputs[i], patterns)), _obj(expected[i]),
          reason: 'cleanData case $i');
    }
    expect(_truth['cleanWarnings'], isEmpty);
  });
}
