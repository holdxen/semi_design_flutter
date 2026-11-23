import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    as config;
import 'package:semi_design_flutter/src/monaco/platform/configuration/test/common/testConfigurationService.dart'
    as tcs;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch118_truth.json').readAsStringSync())
        as Map<String, dynamic>;

/// Mirror the truth `enc()` carrier: JS `undefined` is sent as a marker.
Object? _norm(Object? value) {
  if (identical(value, tcs.jsUndefined)) {
    return <String, Object?>{'__undefined__': true};
  }
  if (value is Map) {
    return value.map<String, Object?>((Object? key, Object? v) =>
        MapEntry<String, Object?>(key.toString(), _norm(v)));
  }
  if (value is List) {
    return value.map<dynamic>(_norm).toList();
  }
  return value;
}

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

class _Overrides implements config.IConfigurationOverrides {
  @override
  final String? overrideIdentifier;
  @override
  final uri.URI? resource;

  _Overrides({this.overrideIdentifier, this.resource});
}

class _ChangeEvent implements config.IConfigurationChangeEvent {
  _ChangeEvent(this.affectedKeys);

  @override
  final Set<String> affectedKeys;

  @override
  int get source => 0;

  @override
  config.IConfigurationChange get change => throw UnimplementedError();

  @override
  bool affectsConfiguration(String configuration,
          [config.IConfigurationOverrides? overrides]) =>
      affectedKeys.contains(configuration);

  Map<String, Object?> toTruth() => <String, Object?>{
        'affectedKeys': affectedKeys.toList(),
      };
}

void main() {
  test('empty configuration, reload and keys', () async {
    final t = _section('empty');
    final service = tcs.TestConfigurationService();

    expect(_norm(service.getValue$0()), t['value']);
    expect(_norm(await service.reloadConfigurationData()), t['reload']);
    expect(_norm(service.keys()), t['keys']);
    expect(service.getConfigurationData(), isNull);
  });

  test('nested paths, null/0 values, missing keys and overrides-only arg', () {
    final t = _section('nested');
    final service = tcs.TestConfigurationService(<String, Object?>{
      'editor.fontSize': 14,
      'workbench.colorTheme': 'Dark+',
      'nested': <String, Object?>{
        'deep': <String, Object?>{'value': 'deep-value'},
      },
      'zero': 0,
      'nil': null,
    });

    expect(_norm(service.getValue$0()), t['all']);
    expect(_norm(service.getValue$1('editor.fontSize')), t['direct']);
    expect(_norm(service.getValue$1('nested.deep.value')), t['path']);
    expect(_norm(service.getValue$1('zero')), t['zero']);
    expect(_norm(service.getValue$1('nil')), t['nil']);
    expect(_norm(service.getValue$1('missing')), t['missing']);
    expect(_norm(service.getValue$1('nested.missing.value')), t['missingPath']);
    expect(
      _norm(service.getValue$2(_Overrides(overrideIdentifier: '[python]'))),
      t['overridesArg'],
    );
    expect(_norm(service.keys()), t['keys']);
  });

  test('root-scoped override via TernarySearchTree.findSubstr', () async {
    final t = _section('rootOverride');
    final service = tcs.TestConfigurationService(<String, Object?>{
      'editor.fontSize': 14,
    });
    await service.setUserConfiguration(
        'editor.fontSize', 20, uri.URI.file('/workspace/project'));
    await service.setUserConfiguration('files.autoSave', 'afterDelay');

    expect(
      _norm(service.getValue$3('editor.fontSize',
          _Overrides(resource: uri.URI.file('/workspace/project')))),
      t['exact'],
    );
    expect(
      _norm(service.getValue$3(
        'editor.fontSize',
        _Overrides(resource: uri.URI.file('/workspace/project/src/a.txt')),
      )),
      t['child'],
    );
    expect(
      _norm(service.getValue$3('editor.fontSize',
          _Overrides(resource: uri.URI.file('/workspace/other')))),
      t['sibling'],
    );
    expect(
      _norm(service.getValue$3(
        'editor.fontSize',
        _Overrides(
          resource: uri.URI.file('/workspace/project/src/a.txt'),
          overrideIdentifier: '[python]',
        ),
      )),
      t['withOverrideId'],
    );
    expect(
      _norm(service.getValueDynamic('editor.fontSize', <String, Object?>{
        'resource': <String, Object?>{'fsPath': '/workspace/project'},
      })),
      t['invalidResource'],
    );
    expect(
      _norm(service.getValueDynamic('editor.fontSize', <String, Object?>{
        'overrideIdentifier': 42,
      })),
      t['invalidOverrideId'],
    );
    expect(
      _norm(service.getValue$3(
        'files.autoSave',
        _Overrides(resource: uri.URI.file('/workspace/project/src/a.txt')),
      )),
      t['twoArgs'],
    );
    expect(
      _norm(service.getValue$2(_Overrides(
          resource: uri.URI.file('/workspace/project/src/a.txt')))),
      t['all'],
    );
    expect(_norm(service.keys()), t['keys']);
  });

  test('inspect and overrideIdentifiers', () async {
    final t = _section('inspect');
    final service = tcs.TestConfigurationService(<String, Object?>{
      'editor.fontSize': 14,
    });
    await service.setUserConfiguration(
        'editor.fontSize', 22, uri.URI.file('/workspace/project'));
    service.setOverrideIdentifiers(
        'editor.fontSize', <String>['[python]', '[typescript]']);

    expect(
      _norm(service.inspect(
        'editor.fontSize',
        _Overrides(resource: uri.URI.file('/workspace/project/src/a.txt')),
      )),
      t['root'],
    );
    expect(_norm(service.inspect('editor.fontSize')), t['global']);
    expect(_norm(service.inspect('missing.key')), t['missing']);
  });

  test('event emitter, dispose and no-op updateValue', () async {
    final t = _section('events');
    final service = tcs.TestConfigurationService(<String, Object?>{'a': 1});
    _ChangeEvent? fired;
    final disposable = service.onDidChangeConfiguration((event) {
      fired = event as _ChangeEvent;
    });

    service.onDidChangeConfigurationEmitter.fire(_ChangeEvent(<String>{'a'}));
    final before = _norm(service.getValue$0());
    await service.updateValue$2('a', 2);

    final captured = fired;
    expect(captured, isNotNull);
    expect(_norm(captured!.toTruth()), t['fired']);
    expect(before, t['before']);
    expect(_norm(service.getValue$0()), t['after']);
    await service.updateValue$2('a', 2);
    expect(_norm(tcs.jsUndefined), t['update']);

    disposable.dispose();
    service.onDidChangeConfigurationEmitter.fire(_ChangeEvent(<String>{'b'}));
    expect(fired, same(captured));
  });
}
