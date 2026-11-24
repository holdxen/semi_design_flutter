import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart' as errors;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/policy.dart'
    as base_policy;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configurationModels.dart'
    as models;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configurations.dart'
    as c;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configurationRegistry.dart'
    as registry;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart'
    as log;
import 'package:semi_design_flutter/src/monaco/platform/policy/common/policy.dart'
    as policy;

final Map<String, dynamic> T =
    jsonDecode(File('tool/ts2dart/batch157_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Object? _plain(Object? value) {
  if (value is Map) {
    return value.map<String, Object?>(
      (Object? key, Object? v) => MapEntry<String, Object?>(key.toString(), _plain(v)),
    );
  }
  if (value is List) return value.map(_plain).toList();
  return value;
}

String _typeResult(Object? value) => value == null ? 'undef' : value as String;

class _RecordingLogService extends log.NullLogService {
  final List<List<Object?>> calls = <List<Object?>>[];

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    calls.add(<Object?>['trace', <Object?>[
      message,
      if (args.isNotEmpty) _plain(args),
    ]]);
  }

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    calls.add(<Object?>['warn', <Object?>[
      message.toString(),
      if (args.isNotEmpty) _plain(args),
    ]]);
  }

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    // Dart ILogger.error takes a List<Object?> where TS passes a direct value;
    // flatten a single argument so the carrier matches the TS truth shape.
    calls.add(<Object?>['error', <Object?>[
      message.toString(),
      if (args.length == 1) _plain(args.first),
      if (args.length > 1) _plain(args),
    ]]);
  }
}

class _FakePolicyService implements policy.IPolicyServiceType {
  final event.Emitter<List<base_policy.PolicyName>> _emitter =
      event.Emitter<List<base_policy.PolicyName>>();

  @override
  late final event.Event<List<base_policy.PolicyName>> onDidChange =
      _emitter.event;

  final Map<base_policy.PolicyName, policy.PolicyValue> values =
      <base_policy.PolicyName, policy.PolicyValue>{};

  final List<Map<String, Object?>> submitted = <Map<String, Object?>>[];

  // TS `declare readonly _serviceBrand: undefined` has no Dart override target.
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  Map<String, policy.PolicyDefinition> policyDefinitions =
      <String, policy.PolicyDefinition>{};

  @override
  Future<Map<String, policy.PolicyValue>> updatePolicyDefinitions(
      Map<String, policy.PolicyDefinition> definitions) async {
    submitted.add(definitions.map<String, Object?>(
      (String key, policy.PolicyDefinition value) =>
          MapEntry<String, Object?>(key, _snapshot(value)),
    ));
    return <String, policy.PolicyValue>{};
  }

  Map<String, Object?> _snapshot(policy.PolicyDefinition definition) =>
      <String, Object?>{
        'type': definition.type,
        'value': definition.value == null ? 'undef' : 'function',
        'managedSettings': definition.managedSettings ?? 'undef',
        'restrictedValue': definition.restrictedValue ?? 'undef',
      };

  @override
  policy.PolicyValue? getPolicyValue(base_policy.PolicyName name) => values[name];

  @override
  String? getPolicyValueSource(base_policy.PolicyName name) => null;

  @override
  Map<String, Map<String, Object?>>? serialize() => null;

  void fire(List<base_policy.PolicyName> names) => _emitter.fire(names);
}

class _DefaultWithOverrides extends c.DefaultConfiguration {
  _DefaultWithOverrides(super.logService);

  @override
  Map<String, Object?> getConfigurationDefaultOverrides() =>
      <String, Object?>{'a': 99};

  @override
  Object? getDefaultValue(String key,
          registry.IRegisteredConfigurationPropertySchema propertySchema) =>
      'custom:${propertySchema['default']}';
}

registry.ConfigurationRegistry get _reg => registry.configurationRegistry;

void _resetRegistry() {
  _reg.getConfigurationProperties().clear();
  _reg.getExcludedConfigurationProperties().clear();
  _reg.getPolicyConfigurations().clear();
  _reg.getPolicyReferenceConfigurations().clear();
}

void _setupDefaultProps() {
  _reg.getConfigurationProperties().addAll(<String, Map<String, Object?>>{
    'a': <String, Object?>{'default': 1, 'type': 'number'},
    'obj': <String, Object?>{'default': <String, Object?>{'nested': <int>[1, 2]}, 'type': 'object'},
    'helper': <String, Object?>{'default': 'H', 'type': 'string'},
  });
  _reg.getExcludedConfigurationProperties().addAll(<String, Map<String, Object?>>{
    'exp.on': <String, Object?>{
      'default': 'E',
      'experiment': <String, Object?>{'name': 'e'},
    },
    'exp.off': <String, Object?>{'default': 'N'},
  });
}

Object? Function(Object?) _fn(Object? value) => (Object? _) => value;

void _setupPolicyProps() {
  _reg.getConfigurationProperties().addAll(<String, Map<String, Object?>>{
    'p.num': <String, Object?>{
      'type': 'number',
      'policy': <String, Object?>{
        'name': 'numPol',
        'value': _fn(0),
        'managedSettings': <String, Object?>{'m': 1},
        'restrictedValue': 7,
      },
      'default': 0,
    },
    'p.bool': <String, Object?>{
      'type': 'boolean',
      'policy': <String, Object?>{
        'name': 'boolPol',
        'value': _fn(false),
        'restrictedValue': false,
      },
      'default': false,
    },
    'p.str': <String, Object?>{
      'type': <String>['array', 'null'],
      'policy': <String, Object?>{
        'name': 'strPol',
        'value': _fn(<Object?>[]),
        'restrictedValue': <Object?>[],
      },
      'default': <Object?>[],
    },
    'p.ref': <String, Object?>{
      'type': 'string',
      'policyReference': <String, Object?>{'name': 'refPol'},
    },
    'p.owner': <String, Object?>{
      'type': 'string',
      'policy': <String, Object?>{
        'name': 'shared',
        'value': _fn('x'),
        'managedSettings': 'ms',
      },
      'default': 'x',
    },
    'p.refShared': <String, Object?>{
      'type': 'string',
      'policyReference': <String, Object?>{'name': 'shared'},
    },
    'p.unsupported': <String, Object?>{
      'type': <String>['object', 'null'],
      'policy': <String, Object?>{
        'name': 'unsupPol',
        'value': _fn(<String, Object?>{}),
      },
      'default': <String, Object?>{},
    },
    'plain': <String, Object?>{'type': 'string', 'default': 'x'},
  });
  _reg.getExcludedConfigurationProperties().addAll(<String, Map<String, Object?>>{
    'ex.pol': <String, Object?>{
      'type': 'string',
      'policy': <String, Object?>{'name': 'exPol', 'value': _fn('e')},
    },
    'ex.plain': <String, Object?>{'type': 'string', 'default': 'n'},
  });
  _reg.getPolicyConfigurations().addAll(<String, String>{
    'numPol': 'p.num',
    'boolPol': 'p.bool',
    'strPol': 'p.str',
    'shared': 'p.owner',
    'exPol': 'ex.pol',
  });
  _reg.getPolicyReferenceConfigurations().addAll(<String, Set<String>>{
    'refPol': <String>{'p.ref'},
    'shared': <String>{'p.refShared'},
  });
}

_FakePolicyService _setupPolicyValues() {
  final _FakePolicyService ps = _FakePolicyService();
  ps.values.addAll(<String, Object?>{
    'numPol': 42,
    'boolPol': true,
    'strPol': '{"x":1}',
    'refPol': 'hello',
    'shared': 's',
    'exPol': '{"a":[1,2]}',
  });
  return ps;
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() => _resetRegistry());

  test('DefaultConfiguration builds defaults, fires updates and reloads', () async {
    final Map<String, dynamic> t = T['default'] as Map<String, dynamic>;
    _setupDefaultProps();
    final _RecordingLogService logger = _RecordingLogService();
    final c.DefaultConfiguration dc = c.DefaultConfiguration(logger);

    final Map<String, dynamic> before = t['before'] as Map<String, dynamic>;
    expect(dc.configurationModel.isEmpty(), before['empty']);
    expect(_plain(dc.configurationModel.contents), before['contents']);
    expect(dc.configurationModel.keys, before['keys']);

    final List<Map<String, Object?>> events = <Map<String, Object?>>[];
    dc.onDidChangeConfiguration((dynamic e) {
      final c.DefaultConfigurationChange change = e as c.DefaultConfigurationChange;
      events.add(<String, Object?>{
        'properties': change.properties,
        'contents': _plain(change.defaults.contents),
      });
    });

    final models.ConfigurationModel initialized = await dc.initialize();
    final Map<String, dynamic> afterInit = t['afterInit'] as Map<String, dynamic>;
    expect(initialized.keys, afterInit['keys']);
    expect(_plain(initialized.contents), afterInit['contents']);
    expect(events.length, afterInit['events']);

    dc.onDidUpdateConfiguration(<String>['a', 'removed', 'exp.on']);
    final Map<String, dynamic> afterFire = t['afterFire'] as Map<String, dynamic>;
    expect(events, afterFire['events']);
    expect(dc.configurationModel.keys, afterFire['keys']);
    expect(_plain(dc.configurationModel.contents), afterFire['contents']);

    final models.ConfigurationModel reloaded = dc.reload();
    final Map<String, dynamic> afterReload = t['afterReload'] as Map<String, dynamic>;
    expect(reloaded.keys, afterReload['keys']);
    expect(_plain(reloaded.contents), afterReload['contents']);
    expect(events.length, afterReload['events']);
  });

  test('DefaultConfiguration honours overridden defaults', () async {
    final Map<String, dynamic> t = T['defaultOverrides'] as Map<String, dynamic>;
    _reg.getConfigurationProperties().addAll(<String, Map<String, Object?>>{
      'a': <String, Object?>{'default': 1},
      'b': <String, Object?>{'default': 2},
    });
    final c.DefaultConfiguration dc =
        _DefaultWithOverrides(_RecordingLogService());
    await dc.initialize();
    expect(dc.configurationModel.keys, t['keys']);
    expect(_plain(dc.configurationModel.contents), t['contents']);
  });

  test('PolicyConfiguration type normalization follows runtime truth', () async {
    final Map<String, dynamic> t = T['policyTypes'] as Map<String, dynamic>;
    final _RecordingLogService logger = _RecordingLogService();
    final _FakePolicyService ps = _FakePolicyService();
    final c.DefaultConfiguration dc = c.DefaultConfiguration(logger);
    await dc.initialize();
    final c.PolicyConfiguration pc = c.PolicyConfiguration(dc, ps, logger);

    final List<Object?> inputs = <Object?>[
      null,
      'string',
      'number',
      'boolean',
      'array',
      'object',
      <String>['array', 'null'],
      <String>['null'],
      <String>['boolean', 'number'],
    ];
    final List<String> results = inputs
        .map((Object? input) => _typeResult(pc.toPolicyDefinitionType(input, 'p')))
        .toList();
    expect(results, t['results']);
    expect(
      logger.calls.where((List<Object?> call) => call.first == 'warn').toList(),
      t['warns'],
    );
  });

  test('PolicyConfiguration initialize submits definitions and applies values', () async {
    final Map<String, dynamic> t = T['policyInit'] as Map<String, dynamic>;
    _setupPolicyProps();
    final _RecordingLogService logger = _RecordingLogService();
    final _FakePolicyService ps = _setupPolicyValues();
    final c.DefaultConfiguration dc = c.DefaultConfiguration(logger);
    await dc.initialize();
    final c.PolicyConfiguration pc = c.PolicyConfiguration(dc, ps, logger);
    final List<Object?> events = <Object?>[];
    pc.onDidChangeConfiguration((dynamic model) =>
        events.add(_plain((model as models.ConfigurationModel).contents)));

    final models.ConfigurationModel model = await pc.initialize();
    expect(_plain(model.contents), t['contents']);
    expect(model.keys, t['keys']);
    expect(events, t['events']);
    expect(ps.submitted, t['submitted']);
    expect(logger.calls, t['logs']);
  });

  test('PolicyConfiguration reacts to policy and default changes', () async {
    final Map<String, dynamic> t = T['followups'] as Map<String, dynamic>;
    _setupPolicyProps();
    final _RecordingLogService logger = _RecordingLogService();
    final _FakePolicyService ps = _setupPolicyValues();
    final c.DefaultConfiguration dc = c.DefaultConfiguration(logger);
    await dc.initialize();
    final c.PolicyConfiguration pc = c.PolicyConfiguration(dc, ps, logger);
    final List<Object?> events = <Object?>[];
    pc.onDidChangeConfiguration((dynamic model) =>
        events.add(_plain((model as models.ConfigurationModel).contents)));
    await pc.initialize();

    final int beforePolicyDefinitions = ps.submitted.length;
    ps.values['numPol'] = 7;
    ps.values['refPol'] = 'world';
    ps.fire(<String>['numPol', 'refPol', 'shared', 'unsupPol']);
    await _flush();
    final Map<String, dynamic> policyChange =
        (t['afterPolicyChange'] as Map<String, dynamic>);
    expect(_plain(pc.configurationModel.contents), policyChange['contents']);
    expect(events, policyChange['events']);
    expect(ps.submitted.length - beforePolicyDefinitions,
        policyChange['submittedGrowth']);
    expect(
      logger.calls
          .where((List<Object?> call) =>
              call.first == 'trace' &&
              call[1].toString().contains('onDidChangePolicies'))
          .toList(),
      policyChange['logs'],
    );

    final int beforeDefaultDefinitions = ps.submitted.length;
    ps.values['boolPol'] = false;
    dc.onDidUpdateConfiguration(<String>['p.bool', 'plain', 'gone']);
    await _flush();
    await _flush();
    final Map<String, dynamic> defaultChange =
        (t['afterDefaultChange'] as Map<String, dynamic>);
    expect(_plain(pc.configurationModel.contents), defaultChange['contents']);
    expect(events, defaultChange['events']);
    expect(ps.submitted.length - beforeDefaultDefinitions,
        defaultChange['submittedGrowth']);

    final Map<String, dynamic> parseResults =
        (t['parseResults'] as Map<String, dynamic>);
    final Map<String, Object?> actualParse = <String, Object?>{};
    for (final String content in <String>[
      '{"y":9}',
      '[1,{"z":2}]',
      '{"a":1,"a":2}',
      '{bad',
    ]) {
      final String key = <String, String>{
        '{"y":9}': 'obj',
        '[1,{"z":2}]': 'arr',
        '{"a":1,"a":2}': 'dup',
        '{bad': 'bad',
      }[content]!;
      try {
        actualParse[key] = _plain(pc.parse(content));
      } catch (e) {
        actualParse[key] = 'ERR:${errors.getErrorMessage(e)}';
      }
    }
    expect(actualParse, parseResults);

    _reg.getConfigurationProperties()['p.bad'] = <String, Object?>{
      'type': <String>['array', 'null'],
      'policy': <String, Object?>{
        'name': 'badPol',
        'value': _fn(<Object?>[]),
      },
    };
    ps.values['badPol'] = '{bad';
    final Object? beforeBad = _plain(pc.configurationModel.contents);
    pc.update(<String>['p.bad'], false);
    final Map<String, dynamic> badPolicy =
        (t['badPolicy'] as Map<String, dynamic>);
    expect(_plain(pc.configurationModel.contents), badPolicy['afterBad']);
    expect(beforeBad, badPolicy['beforeBad']);
    expect(
      logger.calls.where((List<Object?> call) => call.first == 'error').toList(),
      badPolicy['badLogs'],
    );

    _reg.getConfigurationProperties().remove('p.num');
    final int beforeDereg = ps.submitted.length;
    final List<String> deregKeys =
        await pc.updatePolicyDefinitions(<String>['p.num']);
    final Map<String, dynamic> afterDereg =
        (t['afterDereg'] as Map<String, dynamic>);
    expect(deregKeys, afterDereg['keys']);
    expect(ps.submitted.length - beforeDereg, afterDereg['submittedGrowth']);

    final Map<String, Object?> managed = <String, Object?>{'m': 1};
    final policy.PolicyDefinition defA = policy.PolicyDefinition(
      type: 'number',
      value: _fn(1),
      managedSettings: managed,
      restrictedValue: 0,
    );
    final policy.PolicyDefinition defB = policy.PolicyDefinition(
      type: 'number',
      value: defA.value,
      managedSettings: managed,
      restrictedValue: 0,
    );
    final policy.PolicyDefinition defC = policy.PolicyDefinition(
      type: 'number',
      value: _fn(2),
      managedSettings: managed,
      restrictedValue: 0,
    );
    expect(
      <Object?>[
        pc.isSamePolicyDefinition(null, defA),
        pc.isSamePolicyDefinition(defA, defB),
        pc.isSamePolicyDefinition(defA, defC),
        pc.isSamePolicyDefinition(
          policy.PolicyDefinition(
            type: 'number',
            value: _fn(1),
            restrictedValue: 0,
          ),
          defA,
        ),
      ],
      (t['same'] as Map<String, dynamic>).values.toList(),
    );
  });

  test('NullPolicyConfiguration is an empty no-op implementation', () async {
    final Map<String, dynamic> t = T['nullPolicy'] as Map<String, dynamic>;
    final c.NullPolicyConfiguration np = c.NullPolicyConfiguration();
    final List<Object?> events = <Object?>[];
    final Object disposable =
        np.onDidChangeConfiguration((dynamic _) => events.add(1));
    final models.ConfigurationModel model = await np.initialize();
    expect(model.isEmpty(), t['isEmpty']);
    expect(_plain(model.contents), t['contents']);
    expect(model.keys, t['keys']);
    expect(events, t['events']);
    expect(disposable, isNotNull);
  });
}
